# == Schema Information
#
# Table name: subjects
#
#  id         :integer          not null, primary key
#  name       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Subject < ApplicationRecord
  include ImmutableModel

  NAME_REGEXP = /[a-zA-Z_][\w\.]*/

  has_one :config
  has_many :versions, class_name: 'SchemaVersion'
  has_many :schemas, through: :versions

  validates :name, format: { with: NAME_REGEXP }
end
