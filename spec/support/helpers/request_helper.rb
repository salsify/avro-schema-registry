# frozen_string_literal: true

# Helper to set Basic authentication for requests.
module RequestHelper
  extend ActiveSupport::Concern

  GRAPE_ROUTE_METHODS = [:get, :post, :put, :head, :delete, :patch].freeze

  included do
    GRAPE_ROUTE_METHODS.each do |method|
      # Alias the original method so we can explicitly call it as unauthorized_<method>.
      alias_method("unauthorized_#{method}", method)

      # Overrides the http method to automatically set the authorization header
      # for HTTP Basic auth
      define_method(method) do |path, params: nil, headers: nil|
        request_headers = headers.try(:dup) || { 'CONTENT_TYPE' => 'application/json' }
        basic_auth = ActionController::HttpAuthentication::Basic
                       .encode_credentials('ignored', Rails.configuration.x.app_password)
        request_headers['Authorization'] ||= basic_auth
        request_params =
          if params && !params.is_a?(String)
            params.to_json
          else
            params
          end
        send("unauthorized_#{method}", path, params: request_params, headers: request_headers)
      end
    end
  end
end
