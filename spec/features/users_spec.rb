require 'spec_helper'

feature 'User roles and security' do

  subject(:user) { FactoryGirl.create(:user) }

  context 'no user logged in' do
    it 'should redirect root' do
      visit user_path(user)
      current_path.should eq root_path
    end

  end
  context 'same user logged in' do
    before :each do
      login_as(user)
      visit user_path(user)
    end
    it { current_path.should eq user_path(user) }
    it { page.should have_content(user.address) }
  end
  context 'different, basic user logged in' do
    before :each do
      login_as(FactoryGirl.create(:user))
      visit user_path(user)
    end
    it { current_path.should eq user_path(user) }
    it { page.should_not have_content(user.address) }
  end
  context 'admin user logged in' do
    before :each do
      login_as(FactoryGirl.create(:user,:admin))
      visit user_path(user)
    end
    it { current_path.should eq user_path(user) }
    it { page.should have_content(user.address) }
  end
end