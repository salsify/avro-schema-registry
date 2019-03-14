# frozen_string_literal: true

if Compatibility::Constants::VALUES.exclude?(Rails.application.config.x.default_compatibility.upcase)
  raise "Default compatibility '#{Rails.application.config.x.default_compatibility}' is invalid"
end
