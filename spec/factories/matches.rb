# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :match do
    home_team { Club.all.sample }
    away_team { Club.where('id != ?', home_team.id).sample }
    kickoff { Time.now + (Random.rand*24).hours + (Random.rand * 30).days }
    location 'Stadium'
    home_goals {(Random.rand*5).to_i}
    away_goals {(Random.rand*5).to_i}
    trait :past do
      kickoff { Time.now - (Random.rand*24).hours - (Random.rand * 30).days }
    end
    trait :home_win do
      home_goals { (Random.rand * 5).to_i + 1}
      away_goals { (Random.rand * home_goals).to_i }
    end
    trait :home_win do
      away_goals { (Random.rand * 5).to_i + 1}
      home_goals { (Random.rand * away_goals).to_i }
    end
    trait :draw do
      away_goals { home_goals }
    end
  end
end
