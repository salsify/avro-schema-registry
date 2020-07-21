# frozen_string_literal: true

module SchemaRegistry

  # This module contains error codes and messages defined by the Confluent
  # schema registry.
  module Errors
    SUBJECT_NOT_FOUND = { error_code: 40401, message: 'Subject not found' }.freeze
    VERSION_NOT_FOUND = { error_code: 40402, message: 'Version not found' }.freeze
    SCHEMA_NOT_FOUND = { error_code: 40403, message: 'Schema not found' }.freeze
    INCOMPATIBLE_AVRO_SCHEMA = { error_code: 40901, message: 'Incompatible Avro schema' }.freeze
    INVALID_AVRO_SCHEMA = { error_code: 42201, message: 'Invalid Avro schema' }.freeze
    INVALID_COMPATIBILITY_LEVEL = { error_code: 44203, message: 'Invalid compatibility level' }.freeze
    SERVER_ERROR = { error_code: 50001, message: 'Error in the backend datastore' }.freeze

    READ_ONLY_MODE = { message: 'Running in read-only mode' }.freeze
  end
end
