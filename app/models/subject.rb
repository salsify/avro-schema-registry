# == Schema Information
#
# Table name: subjects
#
#  id            :integer          not null, primary key
#  name          :text             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  compatibility :string
#

class Subject < ActiveRecord::Base
  include ImmutableModel

  NAME_REGEXP = /[a-zA-Z_][\w\.]*/
  COMPATIBILITY_CHANGED = %w(compatibility).deep_freeze

  has_many :versions, class_name: 'SchemaVersion'
  has_many :schemas, through: :versions

  validate :compatibility, :validate_compatibility_level
  validates :name, format: { with: NAME_REGEXP }

  def validate_compatibility_level
    unless Compatibility.valid?(compatibility)
      errors.add(:compatibility, "is invalid: #{compatibility}")
    end
  end

  def readonly?
    super && changed != COMPATIBILITY_CHANGED
  end
end
