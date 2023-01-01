require 'rails_helper'

RSpec.describe Match do
  # Capybara overwrites the +all+ matcher without this +include+
  include RSpec::Matchers.clone

  describe 'score' do
    pending 'returns # - # for completed games'
    pending 'returns – for incomplete games'
  end

  describe 'complete?' do
    pending 'returns whether scoring information has been filled in'
  end

  describe 'result' do
    pending 'returns :home for games where home team won'
    pending 'returns :away for games where away team won'
    pending 'returns :draw for games where neither team won'
    pending 'returns nil if game not complete'
  end

  describe 'winner' do
    pending 'returns Club for home_team if home team won'
    pending 'returns Club for away_team if away team won'
    pending 'returns nil if not complete'
    pending 'returns nil if draw'
  end

  describe 'loser' do
    pending 'returns Club for home_team if home team lost'
    pending 'returns Club for away_team if away team lost'
    pending 'returns nil if not complete'
    pending 'returns nil if draw'
  end

  describe 'voteable?' do
    pending 'returns true if MotM voting may begin'
    pending 'returns false if MotM voting may not begin'
  end

  describe 'in_future?' do
    pending 'returns whether the kickoff is in the future'
  end

  describe 'in_past?' do
    pending 'returns inverse of in_future?'
  end

  describe 'teams' do
    pending 'returns an Array with [home_team, away_team]'
  end

  describe 'update_games' do
    pending 'updates counters for Games'
  end

  describe 'check_for_season' do
    pending 'sets season to kickoff year if season not present'
  end

  describe 'scopes' do
    pending 'all_seasons'
    pending 'with_clubs'
    pending 'completed'
    pending 'upcoming'
  end
end
