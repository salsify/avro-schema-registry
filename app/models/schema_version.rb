# == Schema Information
#
# Table name: schema_versions
#
#  id         :integer          not null, primary key
#  version    :integer          default("1")
#  subject_id :integer          not null
#  schema_id  :integer          not null
#

class SchemaVersion < ActiveRecord::Base
  include ImmutableModel

  belongs_to :subject
  belongs_to :schema

  scope :latest,
        -> { order(version: :desc).limit(1) }
  scope :for_subject_name,
        -> (subject_name) { joins(:subject).where('subjects.name = ?', subject_name) }
  scope :latest_for_subject_name,
        -> (subject_name) { for_subject_name(subject_name).latest }
  scope :for_schema,
        -> (schema_id) { where(schema_id: schema_id) }
  scope :for_schema_json,
        -> (json) { joins(:schema).where('schemas.fingerprint = ?', Schemas::FingerprintGenerator.call(json)) }
end
