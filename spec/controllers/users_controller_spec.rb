require 'spec_helper'

describe UsersController do

  describe '#index' do
    context 'unauthorized access' do
      it 'for signed-out users' do
        get :index
        expect(response).to redirect_to root_path
      end

      it 'for individual users' do
        sign_in FactoryBot.create(:user)
        get :index
        expect(response).to redirect_to root_path
      end

      it 'for At Large Board users' do
        sign_in FactoryBot.create(:user, :at_large_board)
        get :index
        expect(response).to redirect_to root_path
      end
    end
    context 'authorized access' do
      it 'for admin users' do
        sign_in FactoryBot.create(:user, :admin)
        get :index
        expect(response).to be_successful
        expect(assigns(:users)).to match_array(User.all)
      end
      it 'for Executive Board users' do
        sign_in FactoryBot.create(:user, :executive_board)
        get :index
        expect(response).to be_successful
        expect(assigns(:users)).to match_array(User.all)
      end
    end
  end
  describe '#create' do

  end

  describe '#show' do
    let(:user) { FactoryBot.create :user }
    it 'will reject signed-out users' do
      get :show, params: { id: user.to_param }
      expect(response).to redirect_to root_path
    end
    it 'will not reject signed-in users' do
      sign_in user
      get :show, params: { id: user }
      expect(response).to be_successful
      expect(assigns(:user)).to eq user
    end
  end

  describe '#edit' do
    let(:user) { FactoryBot.create :user }
    it 'rejects logged-out users' do
      get :edit, params: { id: user }
      expect(response).to redirect_to root_path
    end
    it 'rejects unauthorized users' do
      sign_in FactoryBot.create(:user)
      get :edit, params: { id: user }
      expect(response).to redirect_to root_path
    end
    it 'allows admin users' do
      sign_in FactoryBot.create(:user, :admin)
      get :edit, params: { id: user }
      expect(response).to be_successful
    end
    it 'redirects non-admins to Devise' do
      sign_in user
      get :edit, params: { id: user }
      expect(response).to redirect_to(edit_user_registration_path(user))
    end
  end

  describe '#import' do
    let(:file) { Rails.root.join('spec', 'data', 'user-import.csv') }
    context 'logged out' do
      it 'redirects users' do
        post :import, params: { file: fixture_file_upload('user-import.csv') }

        expect(response).to redirect_to root_path
      end
      it 'does not accept files' do
        expect {
          post :import, params: { file: fixture_file_upload('user-import.csv') }
        }.not_to change(User, :count)
      end
    end
    context 'logged in as regular user' do
      before(:each) { sign_in FactoryBot.create(:user) }
      it 'redirects users' do
        post :import, params: { file: fixture_file_upload('user-import.csv') }

        expect(response).to redirect_to root_path
      end
      it 'does not accept files' do
        expect {
          post :import, params: { file: fixture_file_upload('user-import.csv') }
        }.not_to change(User, :count)
      end
    end
    context 'logged in as at-large board user' do
      before(:each) { sign_in FactoryBot.create(:user, :at_large_board) }
      it 'redirects users' do
        post :import, params: { file: fixture_file_upload('user-import.csv') }

        expect(response).to redirect_to root_path
      end
      it 'does not accept files' do
        expect {
          post :import, params: { file: fixture_file_upload('user-import.csv') }
        }.not_to change(User, :count)
      end
    end
    context 'logged in as admin' do
      before(:each) { sign_in FactoryBot.create(:user, :admin) }
      it 'rejects if file missing' do
        post :import

        expect(flash[:alert]).to eq('No file was selected')
      end
      it 'imports Individual and Family users but not Relatives' do
        expect {
          post :import, params: { file: fixture_file_upload('user-import.csv') }
        }.to change(User, :count).by(2)
      end
      it 'emails new users' do
        expect(UserMailer).to receive(:new_user_creation_email).and_return(double(deliver_now: true)).exactly(2).times

        post :import, params: { file: fixture_file_upload('user-import.csv') }
      end
      it 'doesn\'t email existing users' do
        user_file = CSV.read(Rails.root.join('spec', 'fixtures', 'files', 'user-import.csv'), headers: true, header_converters: :symbol).map(&:to_h)
        user_file.each do |u|
          FactoryBot.build(:user).tap { |user|
            user.email = u[:email]
          }.save
        end

        expect(UserMailer).not_to receive(:new_user_creation_email)

        post :import, params: { file: fixture_file_upload('user-import.csv') }
      end
    end
  end

end
