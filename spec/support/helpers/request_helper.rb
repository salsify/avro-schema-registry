# Helper to set Basic authentication for requests.
module RequestHelper
  extend ActiveSupport::Concern

  GRAPE_ROUTE_METHODS = %i(get post put head delete patch).freeze

  included do
    GRAPE_ROUTE_METHODS.each do |method|
      # Alias the original method so we can explicitly call it as unauthorized_<method>.
      alias_method("unauthorized_#{method}", method)

      # Overrides the http method to automatically set the authorization header
      # for HTTP Basic auth
      define_method(method) do |path, parameters = nil, headers_or_env = nil|
        headers = headers_or_env.try(:dup) || {}
        basic_auth = ActionController::HttpAuthentication::Basic
                       .encode_credentials('ignored', Rails.configuration.x.app_password)
        headers['Authorization'] ||= basic_auth
        send("unauthorized_#{method}", path, parameters, headers)
      end
    end
  end
end
