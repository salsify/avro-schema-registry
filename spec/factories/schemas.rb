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

FactoryGirl.define do
  factory :schema do
    sequence(:json) do |n|
      {
        type: :record,
        name: "rec#{n}",
        fields: [
          { name: "field#{n}", type: :string }
        ]
      }.to_json
    end

    after(:create) do |schema|
      FactoryGirl.create(:schema_version, schema: schema)
    end
  end
end
