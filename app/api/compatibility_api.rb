# frozen_string_literal: true

class CompatibilityAPI < Grape::API
  include BaseAPI

  helpers ::Helpers::SchemaVersionHelper

  rescue_from SchemaRegistry::InvalidAvroSchemaError do
    invalid_avro_schema!
  end

  rescue_from Grape::Exceptions::ValidationErrors do |e|
    if e.errors.keys == [['with_compatibility']]
      invalid_compatibility_level!
    else
      error!({ message: e.message }, 422)
    end
  end

  rescue_from :all do
    server_error!
  end

  desc 'Test input schema against a particular version of a subject\’s schema '\
       'for compatibility'
  params do
    requires :subject, type: String, desc: 'Subject name'
    requires :version_id, types: [Integer, String],
             desc: 'Version of the schema registered under the subject'
    requires :schema, type: String, desc: 'New Avro schema to compare against'
    optional :with_compatibility, type: String, desc: 'The compatibility level to test',
             values: Compatibility::Constants::VALUES
  end
  post '/subjects/:subject/versions/:version_id', requirements: { subject: Subject::NAME_REGEXP } do
    with_schema_version(params[:subject], params[:version_id]) do |schema_version|
      status 200
      {
        is_compatible: SchemaRegistry.compatible?(params[:schema],
                                                  version: schema_version,
                                                  compatibility: params[:with_compatibility])
      }
    end
  end
end
