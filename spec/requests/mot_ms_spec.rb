require 'spec_helper'

describe 'MotMs' do
  let(:match) { FactoryGirl.create(:match) }
  before(:each) do
    sign_in FactoryGirl.create(:user, :admin)
  end

  skip 'GET /matches/:match_id/motms/new'
  skip 'GET /matches/:match_id/motms/:id/edit'
end
