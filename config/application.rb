# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AvroSchemaRegistry
  class Application < Rails::Application
    config.load_defaults 6.0

    # Rollout Rails 6 with the class autoloader first
    config.autoloader = :classic
    config.active_record.dump_schema_after_migration = false
    config.hosts = nil

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Grape support
    config.paths.add(File.join('app', 'api'), glob: File.join('**', '*.rb'))
    config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]

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
