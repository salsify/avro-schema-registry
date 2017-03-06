module Helpers

  # This module defines helpers for the documented errors that the schema
  # registry may return.
  module ErrorHelper

    def server_error!
      error!(SchemaRegistry::Errors::SERVER_ERROR, 500)
    end

    def subject_not_found!
      error!(SchemaRegistry::Errors::SUBJECT_NOT_FOUND, 404)
    end

    def schema_not_found!
      error!(SchemaRegistry::Errors::SCHEMA_NOT_FOUND, 404)
    end

    def version_not_found!
      error!(SchemaRegistry::Errors::VERSION_NOT_FOUND, 404)
    end

    def incompatible_avro_schema!
      error!(SchemaRegistry::Errors::INCOMPATIBLE_AVRO_SCHEMA, 409)
    end

    def invalid_avro_schema!
      error!(SchemaRegistry::Errors::INVALID_AVRO_SCHEMA, 422)
    end

    def invalid_compatibility_level!
      error!(SchemaRegistry::Errors::INVALID_COMPATIBILITY_LEVEL, 422)
    end
  end
end
