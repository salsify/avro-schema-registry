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
  include ImmutableModel

  before_save :generate_fingerprint

  has_many :versions, class_name: 'SchemaVersion'
  has_many :subjects, through: :versions

  private

  def generate_fingerprint
    self.fingerprint = Schemas::FingerprintGenerator.call(json)
  end
end
