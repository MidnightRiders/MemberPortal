require 'spec_helper'

describe RevGuess do
  let (:user) { FactoryGirl.create(:user) }
  let (:revs) { Club.find_by(abbrv: 'NE') || FactoryGirl.create(:club).abbrv = 'NE' }
  let (:rev_guess) { FactoryGirl.build(:rev_guess) }

  before :each do
    rev_guess.match.home_team = revs unless rev_guess.match.teams.include? revs
  end

  describe 'guessing' do
    it 'accepts valid guesses' do
      rev_guess.user = user
      rev_guess.should be_valid
    end
    it 'does not allow multiples from a user on a match' do
      rev_guess.user = user
      rev_guess.save
      rev_guess2 = FactoryGirl.build(:rev_guess)
      rev_guess2.match = rev_guess.match
      rev_guess2.user = user
      rev_guess2.should_not be_valid
    end
    it 'does not accept blank fields' do
      rev_guess.home_goals = nil
      rev_guess.should_not be_valid
    end
    it 'does not allow guesses on non-Revs games' do
      if rev_guess.match.home_team == revs
        rev_guess.match.home_team = Club.find_by('abbrv NOT IN (?)', ['NE',rev_guess.match.away_team.abbrv])
      else
        rev_guess.match.away_team = Club.find_by('abbrv NOT IN (?)', ['NE',rev_guess.match.home_team.abbrv])
      end
      rev_guess.should_not be_valid
      rev_guess.errors.should include(:match_id)
    end
  end
end
