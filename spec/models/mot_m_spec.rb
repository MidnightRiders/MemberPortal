require 'spec_helper'

describe MotM do
  skip 'does not allow multiples from a user on a match'
  skip 'does not allow repeated players'
  skip 'does not allow votes before halftime'

  describe 'different_picks' do
    pending 'adds proper errors if players are not unique'
  end

  describe 'active_players' do
    pending 'adds proper errors if players are not active'
  end

  describe 'voteable?' do
    pending 'adds error to MotM if match isn\'t voteable'
    skip 'doesn\'t add error to MotM if match is voteable'
    pending 'returns false if match isn\'t voteable'
    pending 'returns true if match is voteable'
  end
end
