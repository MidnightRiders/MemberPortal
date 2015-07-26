require 'spec_helper'

RSpec.describe "Relatives", type: :request do
  skip "GET /users/:user_id/memberships/:membership_id/relatives" do
    it "works! (now write some real specs)" do
      get user_membership_relatives_path
      expect(response).to have_http_status(200)
    end
  end
end
