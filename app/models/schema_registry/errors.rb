module SchemaRegistry

  # This module contains error codes and messages defined by the Confluent
  # schema registry.
  module Errors
    SUBJECT_NOT_FOUND = { error_code: 40401, message: 'Subject not found' }.deep_freeze
    VERSION_NOT_FOUND = { error_code: 40402, message: 'Version not found' }.deep_freeze
    SCHEMA_NOT_FOUND = { error_code: 40403, message: 'Schema not found' }.deep_freeze
    INCOMPATIBLE_AVRO_SCHEMA = { error_code: 40901, message: 'Incompatible Avro schema' }.deep_freeze
    INVALID_AVRO_SCHEMA = { error_code: 42201, message: 'Invalid Avro schema' }.deep_freeze
    INVALID_COMPATIBILITY_LEVEL = { error_code: 44203, message: 'Invalid compatibility level' }.deep_freeze
    SERVER_ERROR = { error_code: 50001, message: 'Error in the backend datastore' }.deep_freeze
  end
end
