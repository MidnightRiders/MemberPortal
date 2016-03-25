# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product do
    name "MyString"
    member_cost 1
    non_member_cost 1
    active false
    stock 1
    description "MyText"
  end
end
