require 'spec_helper'

describe "matches/edit" do
  before(:each) do
    @match = assign(:match, stub_model(Match,
      :home_team_id => 1,
      :away_team_id => 1,
      :location => "MyString",
      :home_goals => 1,
      :away_goals => 1
    ))
  end

  it "renders the edit match form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", match_path(@match), "post" do
      assert_select "input#match_home_team_id[name=?]", "match[home_team_id]"
      assert_select "input#match_away_team_id[name=?]", "match[away_team_id]"
      assert_select "input#match_location[name=?]", "match[location]"
      assert_select "input#match_home_goals[name=?]", "match[home_goals]"
      assert_select "input#match_away_goals[name=?]", "match[away_goals]"
    end
  end
end
