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
    sequence(:name) { |n| "subject_#{n}_value" }

    factory :key_subject do
      sequence(:name) { |n| "subject_#{n}_key" }
    end
  end

end
