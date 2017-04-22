require 'rails_helper'
require 'support/share_db_connection'
require 'support/stripe_helper'

RSpec.describe 'Purchasing Membership', :js, type: :feature do
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

    it 'rejects an invalid card number with message' do
      fill_in 'stripe_card_number', with: '1212412321623163'
      click_button 'Purchase Membership'

      expect(page).to have_text('Your card number is incorrect.')
    end

    it 'rejects an expired card with message' do
      last_year = Date.current.year - 1
      page.evaluate_script("jQuery('#stripe_exp_year').append('<option value=#{last_year}>#{last_year}</option>');")

      fill_in 'stripe_card_number', with: '4242424242424242'
      select '1', from: 'stripe_exp_month'
      select last_year, from: 'stripe_exp_year'
      click_button 'Purchase Membership'

      expect(page).to have_text('Your card\'s expiration year is invalid.')
    end

    it 'confirms successful creation', :vcr do
      card = StripeHelper.valid_card
      fill_in 'stripe_card_number', with: card.card_number
      fill_in 'stripe_cvc', with: card.cvc
      select card.exp_date.month, from: 'stripe_exp_month'
      select card.exp_date.year, from: 'stripe_exp_year'
      click_button 'Purchase Membership'

      expect(page).to have_css('.alert-box.info', text: I18n.t(:payment_successful, scope: %i(memberships create)), wait: 10)
      expect(user.reload.current_member?).to be true
    end

    it 'rejects an unsuccessful charge creation', :vcr do
      card = StripeHelper.declined_card
      fill_in 'stripe_card_number', with: card.card_number
      fill_in 'stripe_cvc', with: card.cvc
      select card.exp_date.month, from: 'stripe_exp_month'
      select card.exp_date.year, from: 'stripe_exp_year'
      click_button 'Purchase Membership'

      expect(page).to have_css('.alert-box.alert', text: 'Your card was declined.', wait: 10)
      expect(user.reload.current_member?).to be false
    end
  end
end
