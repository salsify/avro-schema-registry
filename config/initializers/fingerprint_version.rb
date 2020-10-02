# frozen_string_literal: true

# For Rails to reload this file when it reloads code in development
Rails.configuration.to_prepare do
  Schemas::FingerprintGenerator.valid_fingerprint_version!
end
