module SchemaRegistry
  InvalidAvroSchemaError = Class.new(StandardError)
  IncompatibleAvroSchemaError = Class.new(StandardError)

  extend self

  def compatible?(new_json, version:, compatibility: nil)
    compatibility ||= version.subject.config.try(:compatibility) || Compatibility.global

    if Compatibility::Constants::TRANSITIVE_VALUES.include?(compatibility)
      check_all_versions(compatibility, new_json, version.subject)
    else
      check_single_version(compatibility, version.schema.json, new_json)
    end
  end

  def compatible!(new_json, version:, compatibility: nil)
    unless compatible?(new_json, version: version, compatibility: compatibility)
      raise IncompatibleAvroSchemaError
    end
  end

  private

  # If a version/fork of avro that defines Avro::SchemaCompability is
  # present, use the full compatibility check, otherwise fall back to
  # match_schemas.
  def check(readers_schema, writers_schema)
    if defined?(Avro::SchemaCompatibility)
      Avro::SchemaCompatibility.can_read?(writers_schema, readers_schema)
    else
      Avro::IO::DatumReader.match_schemas(writers_schema, readers_schema)
    end
  end

  def check_single_version(compatibility, old_json, new_json)
    old_schema = Schemas::Parse.call(old_json)
    new_schema = Schemas::Parse.call(new_json)

    case compatibility
    when Compatibility::Constants::NONE
      true
    when Compatibility::Constants::BACKWARD
      check(old_schema, new_schema)
    when Compatibility::Constants::FORWARD
      check(new_schema, old_schema)
    when Compatibility::Constants::FULL, Compatibility::Constants::BOTH
      check(old_schema, new_schema) && check(new_schema, old_schema)
    end
  end

  def check_all_versions(compatibility, new_json, subject)
    new_schema = Schemas::Parse.call(new_json)
    json_schemas = subject.versions.order(version: :desc).joins(:schema).pluck('version', 'schemas.json').map(&:last)

    case compatibility
    when Compatibility::Constants::BACKWARD_TRANSITIVE
      json_schemas.all? { |json| check(Schemas::Parse.call(json), new_schema) }
    when Compatibility::Constants::FORWARD_TRANSITIVE
      json_schemas.all? { |json| check(new_schema, Schemas::Parse.call(json)) }
    when Compatibility::Constants::FULL_TRANSITIVE
      json_schemas.all? do |json|
        old_schema = Schemas::Parse.call(json)
        check(old_schema, new_schema) && check(new_schema, old_schema)
      end
    end
  end
end
