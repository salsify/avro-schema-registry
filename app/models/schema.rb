# == Schema Information
#
# Table name: schemas
#
#  id          :integer          not null, primary key
#  fingerprint :string           not null
#  json        :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Schema < ActiveRecord::Base

  before_save :generate_fingerprint

  before_update :read_only_model!
  before_destroy :read_only_model!

  has_many :versions, class_name: 'SchemaVersion'
  has_many :subjects, through: :versions

  def read_only_model!
    raise ActiveRecord::ReadOnlyRecord
  end

  def generate_fingerprint
    self.fingerprint = Schemas::FingerprintGenerator.call(json)
  end
end
