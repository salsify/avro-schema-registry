module Schemas
  # This module is used to standardize the fingerprint generation for an
  # Avro JSON schema
  module FingerprintGenerator

    def self.call(json)
      Schemas::Parse.call(json).sha256_fingerprint.to_s(16)
    end
  end
end
