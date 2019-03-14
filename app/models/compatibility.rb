# frozen_string_literal: true

module Compatibility

  module Constants
    BOTH = 'BOTH' # deprecated
    BACKWARD = 'BACKWARD'
    BACKWARD_TRANSITIVE = 'BACKWARD_TRANSITIVE'
    FORWARD = 'FORWARD'
    FORWARD_TRANSITIVE = 'FORWARD_TRANSITIVE'
    FULL = 'FULL'
    FULL_TRANSITIVE = 'FULL_TRANSITIVE'
    NONE = 'NONE'

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
