# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :company_metum, :class => 'CompanyMeta' do
    mkey "MyString"
    mval "MyString"
    company nil
  end
end
