FactoryBot.define do
  factory :match do
    home_team { Club.all.sample || FactoryBot.create(:club) }
    away_team { Club.where('id != ?', home_team.id).sample || FactoryBot.create(:club) }
    kickoff { Time.now + (Random.rand * 24).hours + (Random.rand * 30).days }
    location 'Stadium'
    home_goals nil
    away_goals nil
    trait :past do
      kickoff { Time.now - (Random.rand * 24).hours - (Random.rand * 30).days }
      home_goals { (Random.rand * 5).to_i }
      away_goals { (Random.rand * 5).to_i }
    end
    trait :home_win do
      home_goals { (Random.rand * 5).to_i + 1 }
      away_goals { (Random.rand * (home_goals - 1)).to_i }
    end
    trait :away_win do
      away_goals { (Random.rand * 5).to_i + 1 }
      home_goals { (Random.rand * (away_goals - 1)).to_i }
    end
    trait :draw do
      home_goals { (Random.rand * 5).to_i }
      away_goals { home_goals }
    end
  end
end
