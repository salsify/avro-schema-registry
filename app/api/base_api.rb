# This module provides shared configuration for the Schema Registry API
module BaseAPI
  extend ActiveSupport::Concern

  included do
    format :json

    helpers ::Helpers::ErrorHelper

    http_basic do |_username, password|
      password == Rails.configuration.x.app_password
    end
  end
end
