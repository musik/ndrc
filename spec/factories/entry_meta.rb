# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :entry_metum, :class => 'EntryMeta' do
    mkey "MyString"
    mval "MyString"
    entry nil
  end
end
