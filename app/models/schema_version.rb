# frozen_string_literal: true

# == Schema Information
#
# Table name: schema_versions
#
#  id         :bigint           not null, primary key
#  version    :integer          default(1)
#  subject_id :bigint           not null
#  schema_id  :bigint           not null
#
# Indexes
#
#  index_schema_versions_on_subject_id_and_version  (subject_id,version) UNIQUE
#

class SchemaVersion < ApplicationRecord
  include ImmutableModel

  belongs_to :subject, inverse_of: :versions
  belongs_to :schema, inverse_of: :versions

  scope :latest,
        -> { order(version: :desc).limit(1) }
  scope :for_subject_name,
        ->(subject_name) { joins(:subject).where('subjects.name = ?', subject_name) }
  scope :latest_for_subject_name,
        ->(subject_name) { for_subject_name(subject_name).latest }
  scope :for_schema,
        ->(schema_id) { where(schema_id:) }
  scope :for_schema_fingerprint, ->(fingerprint) { joins(:schema).merge(Schema.with_fingerprint(fingerprint)) }
  scope :for_schema_json, ->(json) { joins(:schema).merge(Schema.with_json(json)) }
end
