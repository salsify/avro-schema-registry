module Compatibility

  module Constants
    BOTH = 'BOTH'.freeze
    BACKWARD = 'BACKWARD'.freeze
    FORWARD = 'FORWARD'.freeze
    NONE = 'NONE'.freeze
    VALUES = Set.new([BOTH, BACKWARD, FORWARD, NONE]).freeze
  end

  class InvalidCompatibilityLevelError < StandardError
    def initialize(invalid_level)
      super("Invalid compatibility level #{invalid_level.inspect}")
    end
  end

  def self.global
    Config.global.compatibility
  end
end
