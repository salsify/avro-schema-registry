# frozen_string_literal: true

Raven.configure do |config|
  config.current_environment = ENV.fetch('KUBE_ENVIRONMENT', ENV['RAILS_ENV'])
  config.release = ENV['APP_VERSION']
end
