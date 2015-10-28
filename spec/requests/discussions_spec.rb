require 'rails_helper'

RSpec.describe "Discussions", :type => :request do
  describe "GET /discussions" do
    it "works! (now write some real specs)" do
      get discussions_path
      expect(response).to have_http_status(200)
    end
  end
end
