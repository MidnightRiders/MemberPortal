require 'spec_helper'

describe UsersController do

  # login_admin
  before(:each) do
    FactoryGirl.create(:revs)
  end

  def valid_attributes
    FactoryGirl.attributes_for(:user,:admin)
  end

  # describe 'GET index' do
  #   it 'assigns all users as @users' do
  #     get :index
  #     assigns(:users).should eq([subject.current_user])
  #   end
  # end
#
  # describe 'GET show' do
  #   it 'assigns the requested user as @user' do
  #     get :show, {id: subject.current_user.to_param}
  #     assigns(:user).should eq(subject.current_user)
  #   end
  # end

  describe '#index blocks unauthorized access' do
    it 'for signed-out users' do
      sign_in nil
      get :index
      response.should redirect_to root_path
    end

    it 'for individual users' do
      sign_in FactoryGirl.create(:user)
      get :index
      response.should redirect_to root_path
    end

  end

  describe '#index allows authorized access' do
    it 'for admin users' do
      sign_in FactoryGirl.create(:user,:admin)
      get :index
      response.should be_success
      assigns(:users).should eq(User.all)
    end
    it 'for Executive Board users' do
      sign_in FactoryGirl.create(:user,:executive_board)
      get :index
      response.should be_success
      assigns(:users).should eq(User.all)
    end
    it 'for At Large Board users' do
      sign_in FactoryGirl.create(:user, :at_large_board)
      get :index
      response.should be_success
      assigns(:users).should eq(User.all)
    end
  end

  describe '#show' do
    it 'will reject signed-out users' do
      user = FactoryGirl.create :user
      sign_in nil
      get :show, id: user.to_param
      response.should redirect_to root_path
    end
    it 'will not reject signed-out users' do
      u = FactoryGirl.create :user
      sign_in
      response.should redirect_to root_path
    end

  end

end
