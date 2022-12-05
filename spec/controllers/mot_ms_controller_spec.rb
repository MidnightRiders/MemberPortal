require 'spec_helper'

describe MotMsController do
  let(:match) { FactoryBot.create(:match, kickoff: Time.current - 2.hours, home_team: Club.find_by(abbrv: 'NE')) }

  context 'when signed in' do
    let(:user) { FactoryBot.create(:user) }
    before :each do
      sign_in user
    end
    describe '#new' do
      it 'instantiates MotM' do
        get :new, params: { match_id: match }
        expect(assigns(:mot_m)).to be_an_instance_of(MotM)
      end
    end

    describe '#create' do
      it 'creates a new MotM if none exists' do
        expect { post :create, params: { mot_m: FactoryBot.attributes_for(:mot_m, user_id: user.id, match_id: match.id), match_id: match } }.to change(MotM, :count)
      end

      it 'will not create a second MotM vote for a user per match' do
        FactoryBot.create(:mot_m, user_id: user.id, match_id: match.id)
        expect { post :create, params: { mot_m: FactoryBot.attributes_for(:mot_m, user_id: user.id, match_id: match.id), match_id: match } }.not_to change(MotM, :count)
      end

      it 'will not create a MotM vote for a non-Revs match' do
        match.home_team = Club.where('abbrv NOT IN (?)', ['NE', match.away_team.abbrv]).first
        FactoryBot.create(:mot_m, user_id: user.id, match_id: match.id)
        expect { post :create, params: { mot_m: FactoryBot.attributes_for(:mot_m, user_id: user.id, match_id: match.id), match_id: match } }.not_to change(MotM, :count)
      end
    end

    describe '#edit' do
      it 'retrieves the MotM for editing' do
        mot_m = FactoryBot.create(:mot_m, match_id: match.id, user_id: user.id)
        get :edit, params: { id: mot_m, match_id: mot_m.match }
        expect(assigns(:mot_m)).to eq mot_m
      end
    end

    describe '#update' do
      it 'updates the provided MotM' do
        motm = FactoryBot.create(:mot_m, match_id: match.id, user_id: user.id)
        new_motm = Player.where('id NOT IN (?)', [motm.first.id, motm.second.id, motm.third.id]).sample || FactoryBot.create(:player)
        expect {
          patch :update, params: { id: motm, mot_m: { first_id: new_motm.id }, match_id: motm.match }
          motm.reload
        }.to change(motm, :first_id)
      end
    end
  end
  context 'when admin' do
    describe '#index' do
      it 'sets mot_ms' do
        sign_in FactoryBot.create(:user, :admin)
        get :index
        expect(assigns(:mot_ms)).to eq Player.includes(:mot_m_firsts, :mot_m_seconds, :mot_m_thirds).select { |x| x.mot_m_total > 0 }
      end
      pending 'ranks mot_ms properly'
    end
  end
end
