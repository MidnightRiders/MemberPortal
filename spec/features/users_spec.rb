require 'spec_helper'

feature 'User privileges and security' do

  subject(:user) { FactoryGirl.create(:user) }

  context 'no user logged in' do
    it 'should redirect root' do
      visit user_path(user)
      expect(current_path).to eq new_user_session_path
    end
  end
  context 'same user logged in' do
    before :each do
      login_as(user)
      visit user_path(user)
    end
    it { expect(current_path).to eq user_path(user) }
    it { expect(page).to have_content(user.address) }
  end
  context 'different, basic user logged in' do
    before :each do
      login_as(FactoryGirl.create(:user))
      visit user_path(user)
    end
    it { expect(current_path).to eq user_path(user) }
    it { expect(page).to_not have_content(user.address) }
  end
  context 'admin user logged in' do
    before :each do
      login_as(FactoryGirl.create(:user,:admin))
      visit user_path(user)
    end
    it { expect(current_path).to eq user_path(user) }
    it { expect(page).to have_content(user.address) }
  end
end

feature 'User signup' do
  let(:user) { FactoryGirl.build(:user) }
  let(:exp_string) { (Date.current + 2.months).strftime('%y%m') }

  context 'User has valid credit card' do
    it 'should allow a user to sign up', js: true do
      visit new_user_path

      click_link 'Swipe Card'

      sleep 1 # reveal.open clears input field

      find(:xpath, '//input[@id="swipe-input"]', visible: true).set "%B4242424242424242^#{user.last_name}/#{user.first_name}^#{exp_string}201000000000012345678901234?;4242424242424242=#{exp_string}12345678901234?"

      page.accept_prompt(with: '424', wait: 10) do
        click_button 'Done'
      end

      fill_in 'Email', with: user.email

      click_button 'Create'

      expect(page).to have_content('Congratulations')
      expect(User.find_by(email: user.email)).to exist
    end
  end
end
