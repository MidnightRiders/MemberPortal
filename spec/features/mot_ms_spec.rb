require 'rails_helper'
require 'support/shared_examples/past_match_mot_m'
require 'support/shared_examples/future_match_mot_m'

RSpec.feature 'MotMs', type: :feature do
  context 'page load' do
    context 'past game' do
      it_behaves_like 'past match MotM'
    end

    context 'game happening currently' do
      it_behaves_like 'future match MotM'
    end

    context 'future game' do
      it_behaves_like 'future match MotM'
    end
  end

  context 'dynamic', :js do
    context 'past game' do
      it_behaves_like 'past match MotM'
    end

    context 'game happening currently' do
      it_behaves_like 'future match MotM'
    end

    context 'future game' do
      it_behaves_like 'future match MotM'
    end
  end
end
