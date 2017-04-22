require 'rails_helper'
require 'support/shared_examples/past_match_rev_guess'
require 'support/shared_examples/future_match_rev_guess'

RSpec.feature 'RevGuesses', type: :feature do
  context 'page load' do
    context 'past game' do
      it_behaves_like 'past match RevGuess'
    end

    context 'game happening currently' do
      it_behaves_like 'past match RevGuess'
    end

    context 'future game' do
      it_behaves_like 'future match RevGuess'
    end
  end

  context 'dynamic', :js do
    context 'past game' do
      it_behaves_like 'past match RevGuess'
    end

    context 'game happening currently' do
      it_behaves_like 'past match RevGuess'
    end

    context 'future game' do
      it_behaves_like 'future match RevGuess'
    end
  end
end
