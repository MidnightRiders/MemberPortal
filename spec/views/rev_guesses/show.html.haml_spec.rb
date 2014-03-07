require 'spec_helper'

describe "rev_guesses/show" do
  before(:each) do
    @rev_guess = assign(:rev_guess, stub_model(RevGuess,
      :match => nil,
      :user => nil,
      :home_goals => 1,
      :away_goals => 2,
      :comment => "Comment"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/Comment/)
  end
end
