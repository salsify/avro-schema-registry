# frozen_string_literal: true

# For Rails to reload this file when it reloads code in development
Rails.configuration.to_prepare do
  if Compatibility::Constants::VALUES.exclude?(Rails.application.config.x.default_compatibility.upcase)
    raise "Default compatibility '#{Rails.application.config.x.default_compatibility}' is invalid"
  end
end
