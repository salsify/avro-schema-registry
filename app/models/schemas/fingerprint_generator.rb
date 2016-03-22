module Schemas
  # This module is used to standardize the fingerprint generation for an
  # Avro JSON schema
  module FingerprintGenerator

    InvalidAvroSchemaError = Class.new(StandardError)

    def self.call(json)
      Avro::Schema.parse(json).sha256_fingerprint.to_s(16)
    rescue
      raise InvalidAvroSchemaError
    end
  end
end
