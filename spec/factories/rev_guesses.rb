# == Schema Information
#
# Table name: rev_guesses
#
#  id         :integer          not null, primary key
#  match_id   :integer
#  user_id    :integer
#  home_goals :integer
#  away_goals :integer
#  comment    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :rev_guess do
    match_id { (Match.first || FactoryGirl.create(:match)).id  }
    user_id { (User.first || FactoryGirl.create(:user)).id }
    home_goals { (Random.rand * 5).to_i }
    away_goals { (Random.rand * 5).to_i }
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
