# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    discussion nil
    user nil
    content "MyText"
    comment nil
  end
end
