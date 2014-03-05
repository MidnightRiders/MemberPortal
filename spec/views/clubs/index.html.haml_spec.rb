require 'spec_helper'

describe "clubs/index" do
  before(:each) do
    assign(:clubs, [
      stub_model(Club,
        :name => "Name",
        :conference => "Conference",
        :primary_color => "Primary Color",
        :secondary_color => "Secondary Color",
        :accent_color => "Accent Color",
        :abbrv => "Abbrv"
      ),
      stub_model(Club,
        :name => "Name",
        :conference => "Conference",
        :primary_color => "Primary Color",
        :secondary_color => "Secondary Color",
        :accent_color => "Accent Color",
        :abbrv => "Abbrv"
      )
    ])
  end

  it "renders a list of clubs" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Conference".to_s, :count => 2
    assert_select "tr>td", :text => "Primary Color".to_s, :count => 2
    assert_select "tr>td", :text => "Secondary Color".to_s, :count => 2
    assert_select "tr>td", :text => "Accent Color".to_s, :count => 2
    assert_select "tr>td", :text => "Abbrv".to_s, :count => 2
  end
end
