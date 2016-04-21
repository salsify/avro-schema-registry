module Schemas

  # This module is used to wrap Avro schema parsing to raise a standard error
  # if any exception is raised.
  module Parse
    def self.call(json)
      Avro::Schema.parse(json)
    rescue
      raise SchemaRegistry::InvalidAvroSchemaError
    end
  end
end
