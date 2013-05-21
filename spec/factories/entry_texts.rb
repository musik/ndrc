# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :entry_text do
    body "MyText"
    entry nil
  end
end
