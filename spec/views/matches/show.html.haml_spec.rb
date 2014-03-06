require 'spec_helper'

describe "matches/show" do
  before(:each) do
    @match = assign(:match, stub_model(Match,
      :home_team_id => 1,
      :away_team_id => 2,
      :location => "Location",
      :home_goals => 3,
      :away_goals => 4
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/Location/)
    rendered.should match(/3/)
    rendered.should match(/4/)
  end
end
