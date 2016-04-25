module Schemas
  # This class is called to register a new version of a schema.
  # If the schema already exists, then the existing model object is returned.
  # Subjects and SchemaVersions are created as necessary.
  # Race conditions are protected against by relying on unique indexes on the
  # created models.
  # If a unique index error is raised, then the operation is retried once.
  class RegisterNewVersion

    attr_reader :subject_name, :json
    attr_accessor :schema
    private_attr_accessor :retried

    def self.call(subject_name, json)
      new(subject_name, json).call.schema
    end

    def initialize(subject_name, json)
      @subject_name = subject_name
      @json = json
    end

    # Retry once to make it easier to handle race conditions on the client,
    # i.e. the client should not need to retry.
    def call
      register_new_version
      self
    rescue ActiveRecord::RecordNotUnique
      if retried
        raise
      else
        self.retried = true
        retry
      end
    end

    private

    def fingerprint
      @fingerprint ||= Schemas::FingerprintGenerator.call(json)
    end

    def register_new_version
      self.schema = Schema.find_by(fingerprint: fingerprint)

      if schema
        create_new_version
      else
        create_new_schema
      end
    end

    def create_new_version
      create_version_with_optional_new_subject unless version_exists_for_subject_schema?(schema.id)
    end

    def create_new_schema
      create_version_with_optional_new_subject do
        self.schema = Schema.create!(json: json)
      end
    end

    def create_version_with_optional_new_subject
      latest_version = latest_version_for_subject

      if latest_version.nil?
        # Create new subject and version
        Subject.transaction do
          yield if block_given?
          new_subject!(schema.id)
        end
      else
        # Create new schema version for subject
        SchemaVersion.transaction do
          SchemaRegistry.compatible!(latest_version.subject.config.try(:compatibility),
                                     latest_version.schema.json,
                                     json)
          yield if block_given?
          new_schema_version_for_subject!(schema.id, latest_version)
        end
      end
    end

    def new_schema_version_for_subject!(schema_id, previous_version)
      SchemaVersion.create!(schema_id: schema_id,
                            subject_id: previous_version.subject_id,
                            version: previous_version.version + 1)

    end

    def new_subject!(schema_id)
      subject = Subject.create!(name: subject_name)
      subject.versions.create!(schema_id: schema_id)
    end

    def latest_version_for_subject
      SchemaVersion.eager_load(:schema, subject: [:config])
                   .latest_for_subject_name(subject_name).first
    end

    def version_exists_for_subject_schema?(schema_id)
      SchemaVersion.for_schema(schema_id)
                   .for_subject_name(subject_name).first.present?

    end
  end
end
