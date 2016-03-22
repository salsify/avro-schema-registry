# == Schema Information
#
# Table name: subjects
#
#  id         :integer          not null, primary key
#  name       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Subject < ActiveRecord::Base

  has_many :versions, class_name: 'SchemaVersion'
  has_many :schemas, through: :versions
end
