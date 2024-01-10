# frozen_string_literal: true

class SubjectAPI < Grape::API
  include BaseAPI

  INTEGER_FINGERPRINT_REGEXP = /^[0-9]+$/

  rescue_from ActiveRecord::RecordNotFound do
    subject_not_found!
  end

  rescue_from SchemaRegistry::InvalidAvroSchemaError do
    invalid_avro_schema!
  end

  rescue_from SchemaRegistry::IncompatibleAvroSchemaError do
    incompatible_avro_schema!
  end

  rescue_from :all do
    server_error!
  end

  helpers ::Helpers::SchemaVersionHelper
  helpers ::Helpers::CacheHelper

  desc 'Get a list of registered subjects'
  get '/' do
    Subject.order(:name).pluck(:name)
  end

  params { requires :name, type: String, desc: 'Subject name' }
  segment ':name', requirements: { name: Subject::NAME_REGEXP } do
    desc 'Get a list of versions registered under the specified subject.'
    get :versions do
      SchemaVersion.for_subject_name(params[:name])
        .order(:version)
        .pluck(:version)
        .tap do |result|
          raise ActiveRecord::RecordNotFound if result.empty?
        end
    end

    params do
      requires :version_id, types: [Integer, String],
               desc: 'version of the schema registered under the subject'
    end
    namespace '/versions/:version_id' do
      desc 'Get a specific version of the schema registered under this subject'
      get do
        with_schema_version(params[:name], params[:version_id]) do |schema_version|
          {
            id: schema_version.schema_id,
            name: schema_version.subject.name,
            version: schema_version.version,
            schema: schema_version.schema.json
          }
        end
      end

      desc 'Get the Avro schema for the specified version of this subject. Only the unescaped schema is returned.'
      get '/schema' do
        with_schema_version(params[:name], params[:version_id]) do |schema_version|
          JSON.parse(schema_version.schema.json)
        end
      end
    end

    desc 'Get the id of a specific version of the schema registered under a subject'
    params do
      requires :fingerprint, types: [String, Integer], desc: 'SHA256 fingerprint'
    end
    get '/fingerprints/:fingerprint' do
      fingerprint = if INTEGER_FINGERPRINT_REGEXP.match?(params[:fingerprint])
                      params[:fingerprint].to_i.to_s(16)
                    else
                      params[:fingerprint]
                    end

      schema_version = SchemaVersion.select(:schema_id)
                                    .for_subject_name(params[:name])
                                    .for_schema_fingerprint(fingerprint).first

      if schema_version
        cache_response!
        { id: schema_version.schema_id }
      else
        schema_not_found!
      end
    end

    desc 'Register a new schema under the specified subject'
    params do
      requires :schema, type: String, desc: 'The Avro schema string'
      optional :with_compatibility, type: String,
               desc: 'The compatibility level to use while registering the schema',
               values: Compatibility::Constants::VALUES
      optional :after_compatibility, type: String,
               desc: 'The compatibility level to set after registering the schema',
               values: Compatibility::Constants::VALUES
    end
    post '/versions' do
      read_only_mode! if Rails.configuration.x.read_only_mode

      error!({ message: 'Schema registration is disabled' }, 503) if Rails.configuration.x.disable_schema_registration

      new_schema_options = declared(params).slice(:with_compatibility, :after_compatibility).symbolize_keys
      schema = Schemas::RegisterNewVersion.call(params[:name], params[:schema], **new_schema_options)
      status 200
      { id: schema.id }
    end

    desc 'Check if a schema has been registered under the specified subject'
    params do
      requires :schema, type: String, desc: 'The Avro schema string'
    end
    post '/' do
      schema_version = SchemaVersion.eager_load(:schema, :subject)
                                    .for_subject_name(params[:name])
                                    .for_schema_json(params[:schema]).first
      if schema_version
        status 200
        {
          subject: schema_version.subject.name,
          id: schema_version.schema_id,
          version: schema_version.version,
          schema: schema_version.schema.json
        }
      elsif Subject.where(name: params[:name]).exists?
        schema_not_found!
      else
        subject_not_found!
      end
    end

  end
end
