# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email do
    title "MyString"
    preheader "MyString"
    content "MyText"
    featured_shop "MyText"
    game ""
    viewings ""
  end
end
