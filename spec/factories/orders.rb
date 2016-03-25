# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :order do
    user nil
    info ""
    completed_at "2016-03-24 22:06:19"
    fulfilled false
  end
end
