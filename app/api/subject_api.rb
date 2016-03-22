class SubjectAPI < Grape::API
  format :json

  helpers ::Helpers::ErrorHelper

  LATEST_VERSION = 'latest'.freeze

  rescue_from ActiveRecord::RecordNotFound do
    subject_not_found!
  end

  rescue_from Schemas::FingerprintGenerator::InvalidAvroSchemaError do
    invalid_avro_schema!
  end

  rescue_from :all do |e|
    server_error!
  end

  helpers do
    def find_schema_version(subject_name, version)
      if version == LATEST_VERSION
        SchemaVersion.for_subject_name(subject_name)
          .latest
      else
        SchemaVersion.where(version: version)
          .for_subject_name(subject_name)
      end.first
    end
  end

  desc 'Get a list of registered subjects'
  get '/' do
    Subject.order(:name).pluck(:name)
  end

  params { requires :name, type: String, desc: 'Subject name' }
  segment ':name' do
    desc 'Get a list of versions registered under the specified subject.'
    get :versions do
      SchemaVersion.for_subject_name(params[:name])
        .order(:version)
        .pluck(:version)
        .tap do |result|
          raise ActiveRecord::RecordNotFound if result.empty?
         end
    end

    desc 'Get a specific version of the schema registered under this subject'
    params do
      requires :version_id, types: [Integer, String],
               desc: 'version of the schema registered under the subject'
    end
    get '/versions/:version_id' do
      schema_version = find_schema_version(params[:name], params[:version_id])
      if schema_version
        {
          name: schema_version.subject.name,
          version: schema_version.version,
          schema: schema_version.schema.json
        }
      elsif Subject.where(name: params[:name]).exists?
        version_not_found!
      else
        subject_not_found!
      end
    end

    desc 'Register a new schema under the specified subject'
    params do
      requires :schema, type: String, desc: 'The Avro schema string'
    end
    post '/versions' do
      schema = Schemas::RegisterNewVersion.call(params[:name], params[:schema])
      status 200
      { id: schema.id }
    end

    desc 'Check if a schema has been registered under the specified subject'
    params do
      requires :schema, type: String, desc: 'The Avro schema string'
    end
    post '/' do
      schema_version = SchemaVersion.for_subject_name(params[:name])
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
