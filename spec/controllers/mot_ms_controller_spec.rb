require 'spec_helper'

describe MotMsController do
  let(:match) { FactoryGirl.create(:match, kickoff: Time.now - 2.hours) }

  context 'when signed out' do
    it 'rejects #index' do
      get :index
      response.should redirect_to root_path
    end
    it 'rejects #new' do
      get :new, match_id: match
      response.should redirect_to root_path
    end
    it 'rejects #create' do
      expect{ post :create, mot_m: FactoryGirl.attributes_for(:mot_m, match_id: match.id), match_id: match }.not_to change(MotM, :count)
      response.should redirect_to root_path
    end
    it 'rejects #edit' do
      get :edit, id: FactoryGirl.create(:mot_m, match_id: match.id), match_id: match
      response.should redirect_to root_path
    end
    it 'accepts #update' do
      motm = FactoryGirl.create(:mot_m)
      new_motm = Player.where('id NOT IN (?)', [ motm.first.id, motm.second.id, motm.third.id]).sample || FactoryGirl.create(:player)
      expect{
        patch :update, id: motm, mot_m: { first_id: new_motm.id }, match_id: motm.match
        motm.reload
      }.not_to change(motm,:first_id)
    end
  end
  context 'when signed in' do
    let(:user) { FactoryGirl.create(:user) }
    before :each do
      sign_in user
    end
    it 'rejects #index' do
      get :index
      response.should redirect_to root_path
    end
    it 'allows #new' do
      get :new, match_id: match
      response.should be_success
    end
    it 'allows #create' do
      expect{ post :create, mot_m: FactoryGirl.attributes_for(:mot_m, user_id: user.id, match_id: match.id), match_id: match }.to change(MotM, :count)
    end
    it 'rejects #create if existing vote' do
      FactoryGirl.create(:mot_m,user_id: user.id, match_id: match.id)
      expect{ post :create, mot_m: FactoryGirl.attributes_for(:mot_m, user_id: user.id, match_id: match.id), match_id: match }.not_to change(MotM, :count)
    end
    it 'allows #edit' do
      mot_m = FactoryGirl.create(:mot_m)
      get :edit, id: mot_m, match_id: mot_m.match
      assigns(:mot_m).should eq mot_m
    end
    it 'accepts #update' do
      motm = FactoryGirl.create(:mot_m, match_id: match.id, user_id: user.id)
      new_motm = Player.where('id NOT IN (?)', [ motm.first.id, motm.second.id, motm.third.id]).sample || FactoryGirl.create(:player)
      expect{
        patch :update, id: motm, mot_m: { first_id: new_motm.id }, match_id: motm.match
        motm.reload
      }.to change(motm,:first_id)
    end
  end
  context 'when admin' do
    it 'allows #index' do
      sign_in FactoryGirl.create(:user, :admin)
      get :index
      assigns(:mot_ms).should eq Player.includes(:motm_firsts,:motm_seconds,:motm_thirds).select{|x| x.mot_m_total > 0 }
    end
  end
end
