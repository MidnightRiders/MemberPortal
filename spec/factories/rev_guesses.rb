# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rev_guess do
    match nil
    user nil
    home_goals 1
    away_goals 1
    comment "MyString"
  end
end
