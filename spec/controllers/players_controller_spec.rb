require 'spec_helper'

describe PlayersController do

  shared_examples_for 'unauthorized' do
    it 'rejects #index' do
      get :index
      expect(response).to redirect_to root_path
    end
    it 'rejects #show' do
      get :show, params: { id: FactoryBot.create(:player) }
      expect(response).to redirect_to root_path
    end
    it 'rejects #new' do
      get :new
      expect(response).to redirect_to root_path
    end
    it 'rejects #create' do
      expect { post :create, params: { player: FactoryBot.attributes_for(:player) } }.not_to change(Player, :count)
      expect(response).to redirect_to root_path
    end
    it 'rejects #edit' do
      get :edit, params: { id: FactoryBot.create(:player) }
      expect(response).to redirect_to root_path
    end
    it 'accepts #update' do
      p = FactoryBot.create(:player)
      new_name = FFaker::Name.first_name
      expect {
        patch :update, params: { id: p, player: { first_name: new_name } }
        p.reload
      }.not_to change(p, :first_name)
    end
  end
  context 'when signed out' do
    it_should_behave_like 'unauthorized'
  end
  context 'when signed in as normal user' do
    before :each do
      sign_in FactoryBot.create(:user)
    end
    it_should_behave_like 'unauthorized'
  end
  context 'when signed in as admin' do
    before do
      sign_in FactoryBot.create(:user, :admin)
    end
    it 'accepts #index' do
      get :index
      expect(response).to be_success
    end
    it 'accepts #new' do
      get :new
      expect(response).to be_success
    end
    it 'accepts #show' do
      player = FactoryBot.create(:player)
      get :show, params: { id: player }
      expect(response).to be_success
      expect(assigns(:player)).to eq player
    end
    it 'accepts #edit' do
      player = FactoryBot.create(:player)
      get :edit, params: { id: player }
      expect(response).to be_success
      expect(assigns(:player)).to eq player
    end
    it 'accepts #create' do
      expect { post :create, params: { player: FactoryBot.attributes_for(:player) } }.to change(Player, :count)
    end
    it 'accepts #update' do
      p = FactoryBot.create(:player)
      new_name = FFaker::Name.first_name
      expect {
        patch :update, params: { id: p, player: { first_name: new_name } }
        p.reload
      }.to change(p, :first_name).to(new_name)
    end
  end
end
