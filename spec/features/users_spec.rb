require 'spec_helper'

feature 'User privileges and security' do

  subject(:user) { FactoryBot.create(:user) }

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
      login_as(FactoryBot.create(:user))
      visit user_path(user)
    end
    it { expect(current_path).to eq user_path(user) }
    it { expect(page).to_not have_content(user.address) }
  end
  context 'admin user logged in' do
    before :each do
      login_as(FactoryBot.create(:user, :admin))
      visit user_path(user)
    end
    it { expect(current_path).to eq user_path(user) }
    it { expect(page).to have_content(user.address) }
  end
end
