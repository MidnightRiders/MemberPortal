require 'rails_helper'
require 'support/share_db_connection'

RSpec.feature 'Matches', type: :feature do
  let(:user) { FactoryGirl.create(:user) }

  before :all do
    [
      Date.current.beginning_of_week - 1.week,
      Date.current.beginning_of_week,
      Date.current.beginning_of_week + 1.week
    ].each do |date|
      10.times do
        FactoryGirl.create(
          :match,
          :past,
          kickoff: (date + [2, 5, 6].sample.days).to_time.change(hour: [12, 19, 21].sample, min: [0, 30].sample)
        )
      end
    end
  end

  describe 'index' do
    before(:each) { login_as user }

    context 'page load' do
      it 'renders this week\'s matches' do
        visit matches_path

        expect(page).to have_content("Matches for the week of #{Date.current.beginning_of_week.strftime('%-m.%-d.%Y')}")
        Match.for_week(Date.current).each do |week_match|
          expect(page).to have_css("a[href='#{match_path(week_match)}']")
          expect(page).to have_css("li.match[data-match-id='#{week_match.id}']")
        end
      end

      it 'renders another week\'s matches' do
        next_week = Date.current + 1.week

        visit matches_path(date: next_week)

        expect(page).to have_content("Matches for the week of #{next_week.beginning_of_week.strftime('%-m.%-d.%Y')}")
        Match.for_week(next_week).each do |week_match|
          expect(page).to have_css("a[href='#{match_path(week_match)}']")
          expect(page).to have_css("li.match[data-match-id='#{week_match.id}']")
        end
      end

      it 'includes scores as provided' do
        last_week = Date.current - 1.week

        visit matches_path(date: last_week)

        expect(page).to have_content("Matches for the week of #{last_week.beginning_of_week.strftime('%-m.%-d.%Y')}")
        Match.for_week(last_week).each do |week_match|
          expect(page).to have_css "li.match[data-match-id='#{week_match.id}'] .home .pick-em-result-score", text: week_match.home_goals.to_s
          expect(page).to have_css "li.match[data-match-id='#{week_match.id}'] .away .pick-em-result-score", text: week_match.away_goals.to_s
        end
      end
    end

    context 'dynamic', :js do
      it 'changes week on navigation' do
        next_week = Date.current.beginning_of_week + 1.week

        visit matches_path

        expect(page).to have_css('html.js')

        click_link 'Next Game Week'

        expect(page).to have_content("Matches for the week of #{next_week.strftime('%-m.%-d.%Y')}")
        expect(page).to have_current_path(matches_path(date: next_week))
      end

      it 'updates state when the game starts' do
        with_wait_time(20) do
          match = FactoryGirl.create(:match, kickoff: 8.seconds.from_now)

          puts Time.current, match.kickoff
          visit matches_path(date: match.kickoff.to_date)
          puts page.evaluate_script('new Date();')

          expect(page.find("[data-match-id='#{match.id}']")[:class]).not_to include('live')
          expect(page.find("[data-match-id='#{match.id}']")[:class]).not_to include('completed')

          expect(page).to have_css("li.match.live:not(.completed)[data-match-id='#{match.id}']")
        end
      end

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
