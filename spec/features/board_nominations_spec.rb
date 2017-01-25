require 'spec_helper'

feature 'Board Nominations', type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user) }
  before(:each) do
    login_as user
    visit user_home_path

    click_on 'Submit 2017 Board Nomination'
  end

  it 'shows the modal' do
    expect(page).to have_css('#nominate-modal', visible: true)
  end

  it 'accepts a completed form' do
    within '#nominate-modal' do
      fill_in 'nomination[name]', with: FFaker::Name.name
      find('input[type=submit]').click
    end

    expect(page).to have_text 'Thank you for your nomination.'
  end

  it 'rejects an incomplete form' do
    within '#nominate-modal' do
      find('input[type=submit]').click
    end

    expect(page).to have_text 'Please provide a name to nominate.'
  end
end
