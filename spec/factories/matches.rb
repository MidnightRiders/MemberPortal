# == Schema Information
#
# Table name: matches
#
#  id           :integer          not null, primary key
#  home_team_id :integer
#  away_team_id :integer
#  kickoff      :datetime
#  location     :string(255)
#  home_goals   :integer
#  away_goals   :integer
#  created_at   :datetime
#  updated_at   :datetime
#  uid          :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :match do
    home_team { Club.all.sample || FactoryGirl.create(:club) }
    away_team { Club.where('id != ?', home_team.id).sample || FactoryGirl.create(:club) }
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
