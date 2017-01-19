class SchemaAPI < Grape::API
  include BaseAPI

  rescue_from ActiveRecord::RecordNotFound do
    schema_not_found!
  end

  rescue_from :all do
    server_error!
  end

  helpers ::Helpers::CacheHelper

  desc 'Get the schema string identified by the input id'
  params do
    requires :id, type: Integer, desc: 'Schema ID'
  end
  get '/ids/:id' do
    schema = ::Schema.find(params[:id])
    cache_response!
    { schema: schema.json }
  end
end
