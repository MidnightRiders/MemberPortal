require 'spec_helper'

describe 'Users' do
  describe 'GET /users/user.json' do
    let(:user){ FactoryGirl.create(:user)}
    it 'rejects signed-out users' do
      get user_path(user, format: :json)
      response.should redirect_to(root_path)
    end
    it 'provides full data to the user' do
      login_as user
      get user_path(user, format: :json)
      JSON.parse(body).should include('address', 'phone', 'email')
    end
    it 'provides full data to admins' do
      login_as FactoryGirl.create(:user, :admin)
      get user_path(user, format: :json)
      JSON.parse(body).should include('address', 'phone', 'email')
    end
    it 'provides partial data to other users' do
      login_as FactoryGirl.create(:user)
      get user_path(user, format: :json)
      JSON.parse(body).should_not include('address', 'phone', 'email')
    end
  end
end
