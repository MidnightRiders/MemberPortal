require 'spec_helper'
require 'spree/testing_support/url_helpers'

class AuthFakesController < ApplicationController
  include Spree::Core::ControllerHelpers::Auth
  def index; render text: 'index'; end
end

describe Spree::Core::ControllerHelpers::Auth, type: :controller do
  controller(AuthFakesController) {}
  include Spree::TestingSupport::UrlHelpers

  describe '#current_ability' do
    it 'returns Spree::Ability instance' do
      expect(controller.current_ability.class).to eq Spree::Ability
    end
  end

  describe '#redirect_back_or_default' do
    controller(AuthFakesController) do
      def index; redirect_back_or_default('/'); end
    end
    it 'redirects to session url' do
      session[:spree_user_return_to] = '/redirect'
      get :index
      expect(response).to redirect_to('/redirect')
    end
    it 'redirects to HTTP_REFERER' do
      request.env['HTTP_REFERER'] = '/dummy_redirect'
      get :index
      expect(response).to redirect_to('/dummy_redirect')
    end
    it 'redirects to default page' do
      get :index
      expect(response).to redirect_to('/')
    end
  end

  describe '#set_guest_token' do
    controller(AuthFakesController) do
      def index
        set_guest_token
        render text: 'index'
      end
    end
    it 'sends cookie header' do
      get :index
      expect(response.cookies['guest_token']).not_to be_nil
    end
  end

  describe '#store_location' do
    it 'sets session return url' do
      allow(controller).to receive_messages(
        spree_signup_path: '',
        spree_login_path: '',
        spree_logout_path: '',
        request: double(fullpath: '/redirect'))
      controller.store_location
      expect(session[:spree_user_return_to]).to eq '/redirect'
    end
  end

  describe '#try_spree_current_user' do
    it 'calls spree_current_user when define spree_current_user method' do
      expect(controller).to receive(:spree_current_user)
      controller.try_spree_current_user
    end
    it 'returns nil' do
      expect(controller.try_spree_current_user).to eq nil
    end
  end

  describe '#redirect_unauthorized_access' do
    controller(AuthFakesController) do
      def index; redirect_unauthorized_access; end
    end
    context 'when logged in' do
      before do
        allow(controller).to receive_messages(try_spree_current_user: double('User', id: 1, last_incomplete_spree_order: nil))
      end
      it 'redirects forbidden path' do
        get :index
        expect(response).to redirect_to(spree.forbidden_path)
      end
    end
    context 'when guest user' do
      before do
        allow(controller).to receive_messages(try_spree_current_user: nil)
      end
      it 'redirects login path' do
        allow(controller).to receive_messages(spree_login_path: new_user_session_path)
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
