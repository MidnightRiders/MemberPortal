require 'spec_helper'

describe "RevGuesses" do
  skip 'GET /rev_guesses' do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get rev_guesses_path
      expect(response.status).to be(200)
    end
  end
end
