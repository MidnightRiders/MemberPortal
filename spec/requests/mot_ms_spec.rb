require 'rails_helper'

RSpec.describe 'MotMs' do
  let(:match) { FactoryBot.create(:match) }
  before(:each) do
    sign_in FactoryBot.create(:user, :admin)
  end

  pending 'GET /matches/:match_id/motms/new'
  pending 'GET /matches/:match_id/motms/:id/edit'
end
