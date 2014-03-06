require 'spec_helper'

describe "mot_ms/index" do
  before(:each) do
    assign(:mot_ms, [
      stub_model(MotM,
        :user_id => "User",
        :match_id => "Match",
        :first_id => "First",
        :second_id => "Second",
        :third_id => "Third"
      ),
      stub_model(MotM,
        :user_id => "User",
        :match_id => "Match",
        :first_id => "First",
        :second_id => "Second",
        :third_id => "Third"
      )
    ])
  end

  it "renders a list of mot_ms" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "User".to_s, :count => 2
    assert_select "tr>td", :text => "Match".to_s, :count => 2
    assert_select "tr>td", :text => "First".to_s, :count => 2
    assert_select "tr>td", :text => "Second".to_s, :count => 2
    assert_select "tr>td", :text => "Third".to_s, :count => 2
  end
end
