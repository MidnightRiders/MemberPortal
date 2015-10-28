# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :post_view do
    user nil
    post nil
  end
end
