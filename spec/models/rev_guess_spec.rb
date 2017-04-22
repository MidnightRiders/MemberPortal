require 'rails_helper'

RSpec.describe RevGuess do
  let (:user) { FactoryGirl.create(:user) }
  let (:revs) { Club.find_by(abbrv: 'NE') || FactoryGirl.create(:club, :ne) }
  let (:rev_guess) { FactoryGirl.build(:rev_guess) }

  before :each do
    rev_guess.match.home_team = revs unless rev_guess.match.teams.include? revs
  end

  describe 'predicted_score' do
    pending 'returns String with "# - #" style score if present'
    pending 'returns nil if blank'
  end

  describe 'result' do
    pending 'returns :home if home_team predicted to win'
    pending 'returns :away if away_team predicted to win'
    pending 'returns :draw if goals even'
    pending 'returns nil if goals blank'
  end

  describe 'revs_match?' do
    pending 'invalidates model if neither team is the Revs'
    pending 'does nothing if one team is the Revs'
  end

  describe 'guessing' do
    it 'accepts valid guesses' do
      rev_guess.user = user
      expect(rev_guess).to be_valid
    end

    it 'does not allow multiples from a user on a match' do
      rev_guess.user = user
      rev_guess.save
      rev_guess2 = FactoryGirl.build(:rev_guess)
      rev_guess2.match = rev_guess.match
      rev_guess2.user = user
      expect(rev_guess2).to_not be_valid
    end

    it 'does not accept blank fields' do
      rev_guess.home_goals = nil
      expect(rev_guess).to_not be_valid
    end

    it 'does not allow guesses on non-Revs games' do
      if rev_guess.match.home_team == revs
        rev_guess.match.home_team = Club.find_by('abbrv NOT IN (?)', ['NE', rev_guess.match.away_team.abbrv])
      else
        rev_guess.match.away_team = Club.find_by('abbrv NOT IN (?)', ['NE', rev_guess.match.home_team.abbrv])
      end
      expect(rev_guess).to_not be_valid
      expect(rev_guess.errors).to include(:match_id)
    end
  end

  describe 'class methods' do
    describe 'score' do
      pending
    end
  end
end
