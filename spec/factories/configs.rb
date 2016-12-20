FactoryGirl.define do
  factory :config do
    subject
    compatibility { Config::DEFAULT_COMPATIBILITY }
  end
end
