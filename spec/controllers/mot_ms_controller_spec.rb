require 'rails_helper'

RSpec.describe MotMsController do
  let(:match_for_mot_m) { FactoryGirl.create(:match, kickoff: Time.current - 2.hours, home_team: Club.find_by(abbrv: 'NE')) }

  context 'when signed in' do
    let(:user) { FactoryGirl.create(:user) }

    before :each do
      sign_in user
    end

    describe '#show' do
      it 'returns a new MotM if none exists' do
        get :show, match_id: match_for_mot_m.id

        expect(assigns(:mot_m)).to be_a(MotM).and have_attributes(id: nil, match_id: match_for_mot_m.id)
      end

      it 'returns an existing MotM if one exists' do
        mot_m = FactoryGirl.create(:mot_m, match_id: match_for_mot_m.id, user_id: user.id)
        get :show, match_id: match_for_mot_m.id

        expect(assigns(:mot_m)).to eq(mot_m)
      end
    end

    describe '#create' do
      it 'creates a new MotM if none exists' do
        expect {
          post :create, mot_m: FactoryGirl.attributes_for(:mot_m, user_id: user.id, match_id: match_for_mot_m.id), match_id: match_for_mot_m
        }.to change(MotM, :count)
      end

      it 'will not create a MotM vote for a non-Revs match' do
        match_for_mot_m.home_team = Club.where('abbrv NOT IN (?)', ['NE', match_for_mot_m.away_team.abbrv]).first
        FactoryGirl.create(:mot_m, user_id: user.id, match_id: match_for_mot_m.id)
        expect { post :create, mot_m: FactoryGirl.attributes_for(:mot_m, user_id: user.id, match_id: match_for_mot_m.id), match_id: match_for_mot_m }.not_to change(MotM, :count)
      end

      it 'updates the provided MotM if it exists' do
        mot_m = FactoryGirl.create(:mot_m, match_id: match_for_mot_m.id, user_id: user.id)
        new_mot_m = Player.where('id NOT IN (?)', [mot_m.first.id, mot_m.second.id, mot_m.third.id]).sample || FactoryGirl.create(:player)
        expect {
          post :create, id: mot_m, mot_m: { first_id: new_mot_m.id }, match_id: mot_m.match
          mot_m.reload
        }.to change(mot_m, :first_id)
      end
    end
  end

  context 'when admin' do
    describe '#index' do
      it 'sets mot_ms' do
        sign_in FactoryGirl.create(:user, :admin)
        get :index
        expect(assigns(:mot_ms)).to eq Player.includes(:mot_m_firsts, :mot_m_seconds, :mot_m_thirds).select { |x| x.mot_m_total > 0 }
      end

      pending 'ranks mot_ms properly'
    end
  end
end
