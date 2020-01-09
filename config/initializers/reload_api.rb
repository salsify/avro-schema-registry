# frozen_string_literal: true

# Grape reloading support
# https://github.com/ruby-grape/grape#reloading-api-changes-in-development
# Note: adding to explicitly_unloadable_constants caused problems with Spring
# so that recommendation from above is not followed.

if Rails.env.development?
  api_files = Dir[Rails.root.join('app', 'api', '**', '*.rb')]
  api_reloader = ActiveSupport::FileUpdateChecker.new(api_files) do
    Rails.application.reload_routes!
  end
  ActiveSupport::Reloader.to_prepare do
    api_reloader.execute_if_updated
  end
end
