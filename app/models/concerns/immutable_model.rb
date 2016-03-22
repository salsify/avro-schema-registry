# All of the models in this application are insert only. This concern
# is used to ensure that they remain immutable.
module ImmutableModel
  extend ActiveSupport::Concern

  included do
    delegate :read_only_model!, to: :class
    alias_method :delete, :read_only_model!
  end

  def readonly?
    persisted?
  end

  module ClassMethods
    def delete_all(*)
      read_only_model!
    end

    def read_only_model!
      raise ActiveRecord::ReadOnlyRecord
    end
  end
end
