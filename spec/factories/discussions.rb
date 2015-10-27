# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :discussion do
    title "MyString"
    content "MyText"
    match nil
    user nil
  end
end
