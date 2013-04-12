# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :company_text do
    body "MyText"
    company nil
  end
end
