require 'spec_helper'

describe "matches/index" do
  before(:each) do
    assign(:matches, [
      stub_model(Match,
        :home_team_id => 1,
        :away_team_id => 2,
        :location => "Location",
        :home_goals => 3,
        :away_goals => 4
      ),
      stub_model(Match,
        :home_team_id => 1,
        :away_team_id => 2,
        :location => "Location",
        :home_goals => 3,
        :away_goals => 4
      )
    ])
  end

  it "renders a list of matches" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Location".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
  end
end
