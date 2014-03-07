require 'spec_helper'

describe "pick_ems/index" do
  before(:each) do
    assign(:pick_ems, [
      stub_model(PickEm,
        :match => nil,
        :user => nil,
        :result => 1
      ),
      stub_model(PickEm,
        :match => nil,
        :user => nil,
        :result => 1
      )
    ])
  end

  it "renders a list of pick_ems" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
