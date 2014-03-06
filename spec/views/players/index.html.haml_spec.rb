require 'spec_helper'

describe "players/index" do
  before(:each) do
    assign(:players, [
      stub_model(Player,
        :first_name => "First Name",
        :last_name => "Last Name",
        :club_id => 1,
        :position => "Position"
      ),
      stub_model(Player,
        :first_name => "First Name",
        :last_name => "Last Name",
        :club_id => 1,
        :position => "Position"
      )
    ])
  end

  it "renders a list of players" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "First Name".to_s, :count => 2
    assert_select "tr>td", :text => "Last Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Position".to_s, :count => 2
  end
end
