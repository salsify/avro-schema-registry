# == Schema Information
#
# Table name: schemas
#
#  id           :integer          not null, primary key
#  fingerprint  :string           not null
#  json         :text             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  fingerprint2 :string
#

class Schema < ApplicationRecord
  include ImmutableModel

  before_save :generate_fingerprints

  has_many :versions, class_name: 'SchemaVersion'
  has_many :subjects, through: :versions

  scope :with_fingerprints, -> (fingerprint, fingerprint2 = nil) do
    fingerprint2 ||= fingerprint
    case Rails.configuration.x.fingerprint_version
    when '1'
      where('schemas.fingerprint = ?', fingerprint)
    when '2'
      where('schemas.fingerprint2 = ?', fingerprint2)
    else
      where('schemas.fingerprint = ? OR schemas.fingerprint2 = ?', fingerprint, fingerprint2)
    end
  end

  scope :with_fingerprint, ->(fingerprint) do
    with_fingerprints(fingerprint)
  end

  scope :with_json, ->(json) do
    with_fingerprints(Schemas::FingerprintGenerator.include_v1? ? Schemas::FingerprintGenerator.generate_v1(json) : nil,
                      Schemas::FingerprintGenerator.include_v2? ? Schemas::FingerprintGenerator.generate_v2(json) : nil)
  end

  def self.existing_schema(json)
    if Schemas::FingerprintGenerator.include_v2?
      schema = find_by(fingerprint2: Schemas::FingerprintGenerator.generate_v2(json))
    end
    if Schemas::FingerprintGenerator.include_v1? && schema.nil?
      schema = find_by(fingerprint: Schemas::FingerprintGenerator.generate_v1(json))
    end

    schema
  end

  private

  def generate_fingerprints
    self.fingerprint = Schemas::FingerprintGenerator.generate_v1(json)

    if Schemas::FingerprintGenerator.include_v2?
      self.fingerprint2 = Schemas::FingerprintGenerator.generate_v2(json)
    end
  end
end
