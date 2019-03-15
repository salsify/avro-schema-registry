# frozen_string_literal: true

# == Schema Information
#
# Table name: schema_versions
#
#  id         :integer          not null, primary key
#  version    :integer          default(1)
#  subject_id :integer          not null
#  schema_id  :integer          not null
#

FactoryBot.define do
  factory :schema_version, aliases: [:version] do
    subject
    schema
  end
end
