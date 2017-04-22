require 'rails_helper'

RSpec.feature 'Matches', type: :feature do
  describe 'index' do
    context 'page load' do
      it 'renders this week\'s matches'
      it 'renders another week\'s matches'
      it 'includes scores as provided'
    end

    context 'dynamic', :js do
      it 'changes week on navigation'
      it 'reflects week change in URL'
      it 'updates state when the game starts'
      it 'updates state when the game ends'
    end
  end

  describe 'show' do
    context 'page load' do
      it 'shows the match details'
      it 'shows the other matches for the week'
      it 'can be exited'
    end

    context 'dynamic', :js do
      it 'shows the match details'
      it 'shows the other matches for the week'
      it 'can be exited'
    end
  end
end
