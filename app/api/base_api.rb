# frozen_string_literal: true

require 'grape/middleware/optional_auth'

# This module provides shared configuration for the Schema Registry API
module BaseAPI
  extend ActiveSupport::Concern

  SCHEMA_REGISTRY_V1_CONTENT_TYPE = 'application/vnd.schemaregistry.v1+json'
  SCHEMA_REGISTRY_CONTENT_TYPE = 'application/vnd.schemaregistry.json'
  JSON_CONTENT_TYPE = 'application/json'

  included do
    content_type :json, JSON_CONTENT_TYPE
    content_type :schema_registry, SCHEMA_REGISTRY_CONTENT_TYPE
    content_type :schema_registry_v1, SCHEMA_REGISTRY_V1_CONTENT_TYPE

    [:json, :schema_registry, :schema_registry_v1].each do |content_type_sym|
      parser content_type_sym, Grape::Parser::Json
      formatter content_type_sym, Grape::Formatter::Json
    end

    default_format :schema_registry_v1

    helpers ::Helpers::ErrorHelper

    use Grape::Middleware::OptionalAuth,
        type: :http_basic,
        realm: 'API Authorization',
        proc: ->(_username, password) do
          ActiveSupport::SecurityUtils.secure_compare(password, Rails.configuration.x.app_password)
        end
  end
end
