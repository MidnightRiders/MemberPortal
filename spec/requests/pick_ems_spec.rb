require 'rails_helper'

RSpec.describe 'PickEms', type: :request do
  describe 'POST /matches/:match_id/pick_ems' do
    let(:match_to_pick) { FactoryGirl.create(:match) }
    let(:user) { FactoryGirl.create(:user).tap { |u| u.update(password: 'password', password_confirmation: 'password') } }

    before(:each) { sign_in(user) }

    it 'returns 202 Accepted for a new vote' do
      post pick_path(match_to_pick), pick_em: { result: 1 }
      expect(response).to have_http_status(202)
    end

    it 'returns 202 Accepted for an updated vote' do
      match_to_pick.pick_ems.create(user_id: user.id, result: -1)
      post pick_path(match_to_pick), pick_em: { result: 1 }
      expect(response).to have_http_status(202)
    end

    it 'returns JSON for acceptable vote' do
      post pick_path(match_to_pick), pick_em: { result: 1 }
      expect(response.content_type).to eq('application/json')
      expect(response.body).to eq({ result: PickEm.last.result_key }.to_json)
    end

    it 'returns 304 Not Modified for a redundant vote' do
      match_to_pick.pick_ems.create(user_id: user.id, result: 1)
      post pick_path(match_to_pick), pick_em: { result: 1 }
      expect(response).to have_http_status(304)
    end

    it 'returns 422 if result invalid' do
      post pick_path(match_to_pick), pick_em: { result: 4 }
      expect(response).to have_http_status(422)
    end

    it 'raises if params[:pick_em] empty' do
      expect {
        post pick_path(match_to_pick)
      }.to raise_error('param is missing or the value is empty: pick_em')
    end
  end
end
