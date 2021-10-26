# frozen_string_literal: true

module Schemas
  # This class is called to register a new version of a schema.
  # If the schema already exists, then the existing model object is returned.
  # Subjects and SchemaVersions are created as necessary.
  # Race conditions are protected against by relying on unique indexes on the
  # created models.
  # If a unique index error is raised, then the operation is retried once.
  class RegisterNewVersion
    include Procto.call

    attr_reader :subject_name, :json
    attr_accessor :schema

    private_attr_accessor :retried
    private_attr_reader :options

    def initialize(subject_name, json, **options)
      @subject_name = subject_name
      @json = json
      @options = options
    end

    # Retry once to make it easier to handle race conditions on the client,
    # i.e. the client should not need to retry.
    def call
      register_new_version
      schema
    rescue ActiveRecord::RecordNotUnique
      if retried
        raise
      else
        self.retried = true
        retry
      end
    end

    private

    def register_new_version
      self.schema = Schema.existing_schema(json)

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
          subject = new_subject!(schema.id)
          after_compatibility!(subject)
        end
      else
        # Create new schema version for subject
        SchemaVersion.transaction do
          SchemaRegistry.compatible!(json,
                                     version: latest_version,
                                     compatibility: options[:with_compatibility])
          yield if block_given?
          schema_version = new_schema_version_for_subject!(schema.id, latest_version)
          after_compatibility!(schema_version.subject)
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
      subject
    end

    def latest_version_for_subject
      SchemaVersion.eager_load(:schema, subject: [:config])
                   .latest_for_subject_name(subject_name).first
    end

    def version_exists_for_subject_schema?(schema_id)
      SchemaVersion.for_schema(schema_id)
                   .for_subject_name(subject_name).first.present?

    end

    def after_compatibility!(subject)
      compatibility = options[:after_compatibility]
      if compatibility
        subject.create_config! unless subject.config
        subject.config.update_compatibility!(compatibility)
      end
    end
  end
end
