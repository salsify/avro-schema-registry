# == Schema Information
#
# Table name: subjects
#
#  id         :integer          not null, primary key
#  name       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :subject, aliases: [:value_subject] do
    sequence(:name) { |n| "subject-#{n}-value" }

    factory :key_subject do
      sequence(:name) { |n| "subject-#{n}-key" }
    end
  end

end
