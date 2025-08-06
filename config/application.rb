# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'

require 'active_support/core_ext/integer/time'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AvroSchemaRegistry
  class Application < Rails::Application
    config.load_defaults 7.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.x.disable_password = ENV['DISABLE_PASSWORD'] == 'true'
    config.x.app_password = ENV['SCHEMA_REGISTRY_PASSWORD'] || 'avro'

    config.x.allow_response_caching = ENV['ALLOW_RESPONSE_CACHING'] == 'true'
    config.x.cache_max_age = (ENV['CACHE_MAX_AGE'] || 30.days).to_i

    config.x.fingerprint_version = (ENV['FINGERPRINT_VERSION'] || '2').downcase
    config.x.disable_schema_registration = ENV['DISABLE_SCHEMA_REGISTRATION'] == 'true'

    config.x.read_only_mode = ENV['READ_ONLY_MODE'] == 'true'

    config.x.default_compatibility = ENV.fetch('DEFAULT_COMPATIBILITY', 'NONE')
  end
end
