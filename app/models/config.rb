# == Schema Information
#
# Table name: configs
#
#  id            :integer          not null, primary key
#  compatibility :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  subject_id    :integer
#

class Config < ActiveRecord::Base

  # This default differs from the Confluent default of BACKWARD
  DEFAULT_COMPATIBILITY = 'BOTH'.freeze # TODO
  COMPATIBILITY_NAME = 'compatibility'.freeze

  belongs_to :subject

  validate :compatibility, :validate_compatibility_level

  def self.global
    find_by(id: 0) || create!(id: 0, compatibility: DEFAULT_COMPATIBILITY)
  end

  private

  def validate_compatibility_level
    unless Compatibility.valid?(compatibility)
      errors.add(:compatibility, "is invalid: #{compatibility}")
    end
  end
end
