module Compatibility

  VALUES = Set.new(%w(BOTH BACKWARD FORWARD NONE)).deep_freeze

  class InvalidCompatibilityLevelError < StandardError
    def initialize(invalid_level)
      super("Invalid compatibility level #{invalid_level.inspect}")
    end
  end

  def self.global
    Config.compatibility.value
  end

  def self.update!(value)
    validate!(value)
    compatibility = Config.compatibility
    compatibility.update!(value: value.upcase)
    compatibility.value
  end

  def self.valid?(value)
    value.nil? || VALUES.include?(value.upcase)
  end

  def self.validate!(value)
    raise InvalidCompatibilityLevelError.new(value) unless valid?(value)
  end
end
