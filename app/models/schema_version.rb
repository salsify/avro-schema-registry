# == Schema Information
#
# Table name: schema_versions
#
#  id         :integer          not null, primary key
#  version    :integer          default(1)
#  subject_id :integer          not null
#  schema_id  :integer          not null
#

class SchemaVersion < ApplicationRecord
  include ImmutableModel

  belongs_to :subject
  belongs_to :schema

  scope :latest,
        -> { order(version: :desc).limit(1) }
  scope :for_subject_name,
        ->(subject_name) { joins(:subject).where('subjects.name = ?', subject_name) }
  scope :latest_for_subject_name,
        ->(subject_name) { for_subject_name(subject_name).latest }
  scope :for_schema,
        ->(schema_id) { where(schema_id: schema_id) }
  scope :for_schema_fingerprint,
        ->(fingerprint) do
          case Rails.configuration.x.fingerprint_version
          when '1'
            joins(:schema).where('schemas.fingerprint = ?', fingerprint)
          when '2'
            joins(:schema).where('schemas.fingerprint2 = ?', fingerprint)
          else
            joins(:schema).where('schemas.fingerprint = ? OR schemas.fingerprint2 = ?', fingerprint, fingerprint)
          end
        end
  scope :for_schema_json,
        ->(json) do
          case Rails.configuration.x.fingerprint_version
          when '1'
            joins(:schema).where('schemas.fingerprint = ?', Schemas::FingerprintGenerator.generate_v1(json))
          when '2'
            joins(:schema).where('schemas.fingerprint2 = ?', Schemas::FingerprintGenerator.generate_v2(json))
          else
            joins(:schema).where('schemas.fingerprint = ? OR schemas.fingerprint2 = ?',
                                 Schema::FingerprintGenerator.generate_v1(json),
                                 Schema::FingerprintGenerator.generate_v2(json))
          end
        end
end
