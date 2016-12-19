module SchemaRegistry
  InvalidAvroSchemaError = Class.new(StandardError)
  IncompatibleAvroSchemaError = Class.new(StandardError)

  def self.compatible?(compatibility, old_json, new_json)
    direction = compatibility || Compatibility.global
    old_schema = Schemas::Parse.call(old_json)
    new_schema = Schemas::Parse.call(new_json)
    case direction
    when Compatibility::Constants::NONE
      true
    when Compatibility::Constants::BACKWARD
      check(old_schema, new_schema)
    when Compatibility::Constants::FORWARD
      check(new_schema, old_schema)
    when Compatibility::Constants::BOTH
      check(old_schema, new_schema) && check(new_schema, old_schema)
    end
  end

  def self.compatible!(compatibility, old_json, new_json)
    unless compatible?(compatibility, old_json, new_json)
      raise IncompatibleAvroSchemaError
    end
  end

  # If a version/fork of avro that defines Avro::SchemaCompability is
  # present, use the full compatibility check, otherwise fall back to
  # match_schemas.
  def self.check(readers_schema, writers_schema)
    if defined?(Avro::SchemaCompatibility)
      Avro::SchemaCompatibility.can_read?(writers_schema, readers_schema)
    else
      Avro::IO::DatumReader.match_schemas(writers_schema, readers_schema)
    end
  end
  private_class_method :check
end
