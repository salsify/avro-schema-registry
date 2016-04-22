module Helpers

  # This module defines helpers for the documented errors that the schema
  # registry may return.
  module ErrorHelper

    # Note: The requirement to dup these constants was fixed in:
    #   https://github.com/ruby-grape/grape/pull/1336
    # Once a version of grape is released with this fix, the
    # dup can be dropped.

    def server_error!
      error!(SchemaRegistry::Errors::SERVER_ERROR.dup, 500)
    end

    def subject_not_found!
      error!(SchemaRegistry::Errors::SUBJECT_NOT_FOUND.dup, 404)
    end

    def schema_not_found!
      error!(SchemaRegistry::Errors::SCHEMA_NOT_FOUND.dup, 404)
    end

    def version_not_found!
      error!(SchemaRegistry::Errors::VERSION_NOT_FOUND.dup, 404)
    end

    def incompatible_avro_schema!
      error!(SchemaRegistry::Errors::INCOMPATIBLE_AVRO_SCHEMA.dup, 409)
    end

    def invalid_avro_schema!
      error!(SchemaRegistry::Errors::INVALID_AVRO_SCHEMA.dup, 422)
    end

    def invalid_compatibility_level!
      error!(SchemaRegistry::Errors::INVALID_COMPATIBILITY_LEVEL.dup, 422)
    end
  end
end
