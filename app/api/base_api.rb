# This module provides shared configuration for the Schema Registry API
module BaseAPI
  extend ActiveSupport::Concern

  SCHEMA_REGISTRY_V1_CONTENT_TYPE = 'application/vnd.schemaregistry.v1+json'.freeze
  SCHEMA_REGISTRY_CONTENT_TYPE = 'application/vnd.schemaregistry.json'.freeze

  included do
    default_format :json

    content_type :schema_registry_v1, SCHEMA_REGISTRY_V1_CONTENT_TYPE
    content_type :schema_registry, SCHEMA_REGISTRY_CONTENT_TYPE

    format :schema_registry_v1
    formatter :schema_registry_v1, Grape::Formatter::Json

    helpers ::Helpers::ErrorHelper

    http_basic do |_username, password|
      password == Rails.configuration.x.app_password
    end
  end
end
