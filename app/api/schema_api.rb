class SchemaAPI < Grape::API
  format :json

  helpers ::Helpers::ErrorHelper

  rescue_from ActiveRecord::RecordNotFound do
    schema_not_found!
  end

  rescue_from :all do
    server_error!
  end

  desc 'Get the schema string identified by the input id'
  params do
    requires :id, type: Integer, desc: 'Schema ID'
  end
  get '/ids/:id' do
    schema = ::Schema.find(params[:id])
    { schema: schema.json }
  end
end
