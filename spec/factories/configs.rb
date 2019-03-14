# frozen_string_literal: true

# == Schema Information
#
# Table name: configs
#
#  id            :integer          not null, primary key
#  compatibility :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  subject_id    :integer
#

FactoryBot.define do
  factory :config do
    subject
    compatibility { Config::DEFAULT_COMPATIBILITY }
  end
end
