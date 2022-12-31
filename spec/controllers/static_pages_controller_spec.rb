require 'spec_helper'

describe StaticPagesController do
  describe 'GET "home"' do
    context 'signed in' do
      pending 'shows users/home'
    end

    context 'signed out' do
      it 'redirects to sign in' do
        get 'home'
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'GET "faq"' do
    it 'returns http success' do
      get 'faq'
      expect(response).to be_successful
    end
  end

  describe 'GET "contact"' do
    it 'returns http success' do
      get 'contact'
      expect(response).to be_successful
    end
  end

  describe 'GET "standings"' do
    context 'signed in' do
      it 'should show' do
        sign_in FactoryBot.create(:user)
        get 'standings'
        expect(response).to be_successful
      end
    end

    context 'signed out' do
      it 'should redirect' do
        get 'standings'
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'POST "nominate"' do
    let(:user) { FactoryBot.create(:user) }
    let!(:positions) {
      %w(At-Large\ Board President Treasurer Membership\ Secretary Web\ Czar Recording\ Secretary Philanthropy\ Chair Merchandise\ Coordinator).sort + ['501(c)(3) Board of Directors']
    }
    let(:nomination) { { name: FFaker::Name.name, position: positions.sample } }

    context 'signed out' do
      it 'should redirect to root without emailing' do
        post 'nominate', params: { nomination: nomination }

        expect(UserMailer).not_to receive(:new_board_nomination_email)
        expect(response).to redirect_to(root_path)
      end
    end

    context 'signed in' do
      it 'should send New Board Nomination Email' do
        sign_in user
        mail_double = double

        expect(UserMailer).to receive(:new_board_nomination_email).with(user, nomination).and_return(mail_double)
        expect(mail_double).to receive(:deliver_now)

        post 'nominate', params: { nomination: nomination }
      end

      it 'should redirect to user home' do
        sign_in user

        allow(UserMailer).to receive_message_chain('new_board_nomination_email.deliver_now')

        post 'nominate', params: { nomination: nomination }

        expect(response).to redirect_to(user_home_path)
        expect(flash[:notice]).to eq 'Thank you for your nomination.'
      end

      it 'should redirect without sending if name not provided' do
        sign_in user

        post 'nominate'

        expect(response).to redirect_to(user_home_path)
        expect(flash[:alert]).to eq 'Need all information for nominee.'
      end
    end
  end
end
