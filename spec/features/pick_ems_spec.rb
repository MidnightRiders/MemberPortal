require 'rails_helper'

RSpec.feature 'PickEms', type: :feature do
  context 'page load' do
    it 'shows existing pick \'ems'
    it 'reflects pick \'em results'
    it 'creates new pick \'ems'
    it 'doesn\'t allow pick \'ems for past games'
  end

  context 'dynamic', :js do
    it 'shows existing pick \'ems'
    it 'reflects pick \'em results'
    it 'creates new pick \'ems'
    it 'doesn\'t allow pick \'ems for past games'
  end
end
