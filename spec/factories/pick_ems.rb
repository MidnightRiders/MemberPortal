# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :pick_em do
    match nil
    user nil
    result 1
  end
end
