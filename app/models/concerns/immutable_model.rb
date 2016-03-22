# All of the models in this application are insert only. This concern
# is used to ensure that they remain immutable.
module ImmutableModel
  extend ActiveSupport::Concern

  included do
    before_update :read_only_model!
    before_destroy :read_only_model!
  end

  private

  def read_only_model!
    raise ActiveRecord::ReadOnlyRecord
  end
end
