# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :membership do
    user { FactoryGirl.build(:user) }
    year { Date.today.year }
    info {}
  end
end
