require 'spec_helper'

describe 'Users' do
  describe 'GET /users/user' do
    let(:user){ FactoryGirl.create(:user)}
    it 'rejects signed-out users' do
      get user_path(user)
      response.should redirect_to(root_path)
    end
    it 'provides full data to the user' do
      login_as user
      visit user_path(user)
      page.should have_content(user.address)
    end
    it 'provides full data to admins' do
      login_as FactoryGirl.create(:user, :admin)
      visit user_path(user)
      page.should have_content(user.address)
    end
    it 'provides partial data to other users' do
      login_as FactoryGirl.create(:user)
      visit user_path(user)
      page.should_not have_content(user.address)
      page.should_not have_content(user.email)
      page.should_not have_content(user.phone)
    end
  end
  describe 'GET /users/user.json' do
    let(:user){ FactoryGirl.create(:user)}
    it 'rejects signed-out users' do
      get user_path(user, format: :json)
      response.should redirect_to(root_path)
    end
    it 'provides full data to the user' do
      login_as user
      get user_path(user, format: :json)
      JSON.parse(response.body).should include('address', 'phone', 'email')
    end
    it 'provides full data to admins' do
      login_as FactoryGirl.create(:user, :admin)
      get user_path(user, format: :json)
      JSON.parse(response.body).should include('address', 'phone', 'email')
    end
    it 'provides partial data to other users' do
      login_as FactoryGirl.create(:user)
      get user_path(user, format: :json)
      JSON.parse(response.body).should_not include('address', 'phone', 'email')
    end
  end
end
