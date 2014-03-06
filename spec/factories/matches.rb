# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :match do
    home_team_id 1
    away_team_id 1
    kickoff "2014-03-05 22:42:14"
    location "MyString"
    home_goals 1
    away_goals 1
  end
end
