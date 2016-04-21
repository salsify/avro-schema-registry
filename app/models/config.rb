# == Schema Information
#
# Table name: configs
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  value      :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Config < ActiveRecord::Base

  # This default differs from the Confluent default of BACKWARD
  DEFAULT_COMPATIBILITY = :BOTH
  COMPATIBILITY_NAME = 'compatibility'.freeze

  def self.compatibility
    find_or_create_by!(name: COMPATIBILITY_NAME,
                       value: DEFAULT_COMPATIBILITY)
  end
end
