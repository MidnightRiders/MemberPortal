require 'spec_helper'

describe 'Purchasing Membership', type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user, :without_membership) }

  it 'prompts for membership if user isn\'t a current member' do
    login_as user
    visit user_home_path
    expect(page).to have_text('You aren’t a current member!')
  end

  context 'sign up form' do
    before :each do
      login_as user
      visit new_user_membership_path(user)
    end

    it 'shows new membership form when Buy Membership button clicked' do
      expect(page).to have_css("form[action='#{user_memberships_path(user)}']")
    end

    it 'rejects an invalid card number with message', :vcr do
      fill_in 'stripe_card_number', with: '1212412321623163'
      click_button 'Purchase Membership'

      expect(page).to have_text('Your card number is incorrect.')
    end

    it 'rejects an expired card with message', :vcr do
      time = Time.current - 6.months
      Timecop.freeze(time)

      page.evaluate_script('window.location.reload()')

      select '1', from: 'stripe_exp_month'
      select Date.current.year, from: 'stripe_exp_year'
      click_button 'Purchase Membership'

      expect(page).to have_text('Your card\'s expiration year is invalid.')
    end

    it 'confirms successful creation', :vcr do
      expiration = Time.current + 6.months
      fill_in 'stripe_card_number', with: '4242424242424242'
      fill_in 'stripe_cvc', with: '424'
      select expiration.month, from: 'stripe_exp_month'
      select expiration.year, from: 'stripe_exp_year'
      click_button 'Purchase Membership'

      expect(page).to have_css('.alert-box.info', text: 'Thank you for your payment. Your card has been charged the amount below. Please print this page for your records.', wait: 5)
      expect(user.reload.current_member?).to be true
    end
  end
end
