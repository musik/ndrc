# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :entry do
    title "MyString"
    price "9.99"
    company nil
    location_name "MyString"
  end
end
