module SchemaRegistry
  InvalidAvroSchemaError = Class.new(StandardError)
  IncompatibleAvroSchemaError = Class.new(StandardError)

  def self.compatible?(compatibility, old_json, new_json)
    direction = compatibility || Compatibility.global
    old_schema = Schemas::Parse.call(old_json)
    new_schema = Schemas::Parse.call(new_json)
    case direction
    when 'NONE'
      true
    when 'BACKWARD'
      check(old_schema, new_schema)
    when 'FORWARD'
      check(new_schema, old_schema)
    when 'BOTH'
      check(old_schema, new_schema) && check(new_schema, old_schema)
    end
  end

  def self.compatible!(compatibility, old_json, new_json)
    unless compatible?(compatibility, old_json, new_json)
      raise IncompatibleAvroSchemaError
    end
  end

  # This implements a very basic check of schema compatibility.
  # To implement the complete compatibility check something like this needs to
  # be ported to to the ruby gem:
  # https://github.com/apache/avro/blob/master/lang/java/avro/src/main/java/org/apache/avro/io/parsing/ResolvingGrammarGenerator.java
  def self.check(readers_schema, writers_schema)
    Avro::IO::DatumReader.match_schemas(writers_schema, readers_schema)
  end
  private_class_method :check
end
