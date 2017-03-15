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

FactoryGirl.define do
  factory :schema do
    sequence(:json) do |n|
      {
        type: :record,
        name: "rec#{n}",
        fields: [
          { name: "field#{n}", type: :string, default: '' }
        ]
      }.to_json
    end
  end

  factory :schema_without_default, class: Schema do
    sequence(:json) do |n|
      {
        type: :record,
        name: "rec#{n}",
        fields: [
          { name: "field#{n}", type: :int }
        ]
      }.to_json
    end
  end
end
