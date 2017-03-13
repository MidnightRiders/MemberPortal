require 'spec_helper'

feature 'Pick ’Em' do
  let(:user) { FactoryGirl.create(:user) }
  let!(:match) { FactoryGirl.create(:match, kickoff: Time.current + 2.hours) }
  before :each do
    login_as user
    visit matches_path(date: match.kickoff.to_date)
  end

  describe 'picking' do
    scenario 'user picks home team', js: true do
      click_link match.home_team.name
      expect(page).to have_css(".pick-em-picker.picked-home .#{match.home_team.abbrv.downcase}")
      expect(PickEm.where(user_id: user.id, match_id: match.id).count).to eq 1
    end
    scenario 'user picks away team', js: true do
      click_link match.away_team.name
      expect(page).to have_css(".pick-em-picker.picked-away .#{match.home_team.abbrv.downcase}")
      expect(PickEm.where(user_id: user.id, match_id: match.id).count).to eq 1
    end
    scenario 'user picks draw', js: true do
      click_link 'Draw'
      expect(page).to have_css(".pick-em-picker.picked-draw .#{match.home_team.abbrv.downcase}")
      expect(PickEm.where(user_id: user.id, match_id: match.id).count).to eq 1
    end
  end

  describe 'result feedback' do
    scenario 'user correctly picks home team' do
      match = FactoryGirl.create(:match, :past, :home_win)
      match.pick_ems.create(user: user, result: PickEm::RESULTS[:home]).save(validate: false)
      match.update_games
      visit matches_path(date: match.kickoff.to_date)
      expect(page).to have_css('.choice.correct', text: match.home_team.abbrv)
    end

    scenario 'user wrongly picks home team' do
      match = FactoryGirl.create(:match, :past, :away_win)
      match.pick_ems.build(user: user, result: PickEm::RESULTS[:home]).save(validate: false)
      match.update_games
      visit matches_path(date: match.kickoff.to_date)
      expect(page).to have_css('.choice.wrong', text: match.home_team.abbrv)
      expect(page).to have_css('.choice.actual', text: match.away_team.abbrv)
    end
  end
end
