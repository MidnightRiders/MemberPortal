require 'spec_helper'

describe UsersController do

  def valid_attributes
    FactoryGirl.attributes_for(:user,:admin)
  end

  describe '#index blocks unauthorized access' do
    it 'for signed-out users' do
      get :index
      response.should redirect_to root_path
    end

    it 'for individual users' do
      sign_in FactoryGirl.create(:user)
      get :index
      response.should redirect_to root_path
    end

    it 'for At Large Board users' do
      sign_in FactoryGirl.create(:user, :at_large_board)
      get :index
      response.should redirect_to root_path
    end

  end

  describe '#index allows authorized access' do
    it 'for admin users' do
      sign_in FactoryGirl.create(:user,:admin)
      get :index
      response.should be_success
      assigns(:users).should match_array(User.all)
    end
    it 'for Executive Board users' do
      sign_in FactoryGirl.create(:user,:executive_board)
      get :index
      response.should be_success
      assigns(:users).should match_array(User.all)
    end
  end

  describe '#show' do
    it 'will reject signed-out users' do
      u = FactoryGirl.create :user
      get :show, id: u.to_param
      response.should redirect_to root_path
    end
    it 'will not reject signed-in users' do
      u = FactoryGirl.create :user
      sign_in u
      get :show, id: u.to_param
      response.should be_success
      assigns(:user).should eq u
    end

  end

end
