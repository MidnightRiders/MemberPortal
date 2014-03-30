require 'spec_helper'

describe StaticPagesController do

  describe 'GET "home"' do
    it 'returns http success' do
      get 'home'
      response.should redirect_to new_user_session_path
    end
  end

  describe 'GET "faq"' do
    it 'returns http success' do
      get 'faq'
      response.should be_success
    end
  end

  describe 'GET "contact"' do
    it 'returns http success' do
      get 'contact'
      response.should be_success
    end
  end

  describe 'GET "standings"' do
    context 'signed in' do
      it 'should show' do
        sign_in FactoryGirl.create(:user)
        get 'standings'
        response.should be_success
      end
    end
    context 'signed out' do
      it 'should redirect' do
        get 'standings'
        response.should redirect_to(root_path)
      end
    end
  end

end
