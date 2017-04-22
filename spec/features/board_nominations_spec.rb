require 'rails_helper'
require 'support/share_db_connection'

RSpec.feature 'Board Nominations', type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user) }
  let(:positions) {
    %w(At-Large\ Board President Treasurer Membership\ Secretary Web\ Czar Recording\ Secretary Philanthropy\ Chair Merchandise\ Coordinator).sort + ['501(c)(3) Board of Directors']
  }

  before(:each) do
    Timecop.travel(Time.zone.local(Date.current.year, 1, 15))
    login_as user
    visit user_home_path

    click_on "Submit #{Date.current.year} Board Nomination"
  end

  after(:each) do
    Timecop.return
  end

  it 'shows the modal' do
    expect(page).to have_css('#nominate-modal', visible: true)
  end

  it 'accepts a completed form' do
    within '#nominate-modal' do
      fill_in 'nomination[name]', with: FFaker::Name.name
      select positions.sample, from: 'nomination[position]'
      find('input[type=submit]').click
    end

    expect(page).to have_text 'Thank you for your nomination.'
  end

  it 'rejects an incomplete form' do
    within '#nominate-modal' do
      find('input[type=submit]').click
    end

    expect(page).to have_text 'Need all information for nominee.'
  end
end
