require 'spec_helper'

describe "RevGuesses" do
  describe "GET /rev_guesses" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get rev_guesses_path
      response.status.should be(200)
    end
  end
end
