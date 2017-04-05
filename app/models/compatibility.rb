module Compatibility

  module Constants
    BOTH = 'BOTH'.freeze # deprecated
    BACKWARD = 'BACKWARD'.freeze
    BACKWARD_TRANSITIVE = 'BACKWARD_TRANSITIVE'.freeze
    FORWARD = 'FORWARD'.freeze
    FORWARD_TRANSITIVE = 'FORWARD_TRANSITIVE'.freeze
    FULL = 'FULL'.freeze
    FULL_TRANSITIVE = 'FULL_TRANSITIVE'.freeze
    NONE = 'NONE'.freeze

    VALUES = Set.new([BOTH, BACKWARD, BACKWARD_TRANSITIVE, FORWARD,
                      FORWARD_TRANSITIVE, FULL, FULL_TRANSITIVE, NONE]).freeze

    TRANSITIVE_VALUES = Set.new([BACKWARD_TRANSITIVE, FORWARD_TRANSITIVE, FULL_TRANSITIVE]).freeze
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
