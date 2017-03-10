module Schemas
  # This module is used to standardize the fingerprint generation for an
  # Avro JSON schema
  module FingerprintGenerator

    V1_VERSIONS = %w(1 all).freeze
    V2_VERSIONS = %w(2 all).freeze

    def self.generate_v1(json)
      Schemas::Parse.call(json).sha256_fingerprint.to_s(16)
    end

    def self.generate_v2(json)
      Schemas::Parse.call(json).sha256_resolution_fingerprint.to_s(16)
    end

    def self.include_v2?
      V2_VERSIONS.include?(Rails.configuration.x.fingerprint_version)
    end

    def self.include_v1?
      V1_VERSIONS.include?(Rails.configuration.x.fingerprint_version)
    end
  end
end
