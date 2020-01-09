# frozen_string_literal: true

require Rails.root.join('config/environments/production')

Rails.application.configure do
  # Settings specified here will take precedence over those in
  # config/environments/production.rb.

  config.log_level = :info

  config.x.default_compatibility = ENV.fetch('DEFAULT_COMPATIBILITY', 'NONE')

  config.force_ssl = false
end
