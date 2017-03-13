module Schemas
  # This module is used to standardize the fingerprint generation for an
  # Avro JSON schema
  module FingerprintGenerator

    VALID_FINGERPRINT_VERSIONS = Set.new(%w(1 2 all)).deep_freeze

    V1_VERSIONS = Set.new(%w(1 all)).deep_freeze
    V2_VERSIONS = Set.new(%w(2 all)).deep_freeze

    def self.valid_fingerprint_version!
      unless VALID_FINGERPRINT_VERSIONS.include?(Rails.configuration.x.fingerprint_version)
        raise "Invalid fingerprint version: #{Rails.configuration.x.fingerprint_version.inspect}"
      end
    end

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
