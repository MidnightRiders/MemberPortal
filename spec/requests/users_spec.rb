require 'rails_helper'

RSpec.describe 'Users' do
  describe 'GET /users/user' do
    let(:user) { FactoryBot.create(:user) }
    it 'rejects signed-out users' do
      get user_path(user)
      expect(response).to redirect_to(root_path)
    end
    it 'provides full data to the user' do
      login_as user
      visit user_path(user)
      expect(page).to have_content(user.address)
    end
    it 'provides full data to admins' do
      login_as FactoryBot.create(:user, :admin)
      visit user_path(user)
      expect(page).to have_content(user.address)
    end
    it 'provides partial data to other users' do
      login_as FactoryBot.create(:user)
      visit user_path(user)
      expect(page).to_not have_content(user.address)
      expect(page).to_not have_content(user.email)
      expect(page).to_not have_content(user.phone)
    end
  end
  describe 'GET /users/user.json' do
    let(:user) { FactoryBot.create(:user) }
    it 'rejects signed-out users' do
      get user_path(user, format: :json)
      expect(response).to redirect_to(root_path)
    end
    it 'provides full data to the user' do
      login_as user
      get user_path(user, format: :json)
      expect(JSON.parse(response.body)).to include('address', 'phone', 'email')
    end
    it 'provides full data to admins' do
      login_as FactoryBot.create(:user, :admin)
      get user_path(user, format: :json)
      expect(JSON.parse(response.body)).to include('address', 'phone', 'email')
    end
    it 'provides partial data to other users' do
      login_as FactoryBot.create(:user)
      get user_path(user, format: :json)
      expect(JSON.parse(response.body)).to_not include('address', 'phone', 'email')
    end
  end
end
