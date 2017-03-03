require 'spec_helper'

RSpec.describe RelativesController, type: :controller do
  let(:user) { FactoryGirl.create(:user, :without_membership) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:family) { FactoryGirl.create(:membership, :family, :paid_for, user_id: user.id) }

  before :each do
    sign_in user
  end

  describe '#new' do
    it 'creates a new relative for a given family' do
      get :new, membership_id: family.id, user_id: user.to_param, type: :Relative

      expect(assigns(:relative)).to be_a_new(Relative)
      expect(assigns(:relative).pending_approval).to eq(true)
      expect(assigns(:relative).invited_email).to eq('')
    end
  end

  describe '#create' do
    context 'failure' do
      it 'redirects with error if the invited user is already a member' do
        post :create, membership_id: family.id, user_id: user.to_param, type: :Relative, relative: { info: { invited_email: other_user.email } }

        expect(flash.now[:error]).to eq('There is already a user with a current membership for that email.')
        expect(response).to render_template(:new)
      end

      it 'redirects with error if the email is invalid' do
        post :create, membership_id: family.id, user_id: user.to_param, type: :Relative, relative: { info: { invited_email: 'asdf' } }

        expect(flash.now[:error]).to eq('Please enter a valid email')
        expect(response).to render_template(:new)
      end
    end

    context 'success' do
      it 'creates a pending Relative'
      it 'invites an existing user'
      it 'invites a new user'
      it 'redirects with success'
    end
  end

  describe '#destroy' do

  end

  describe '#accept_invitation' do

  end
end
