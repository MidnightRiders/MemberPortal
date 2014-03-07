require 'spec_helper'

describe "pick_ems/show" do
  before(:each) do
    @pick_em = assign(:pick_em, stub_model(PickEm,
      :match => nil,
      :user => nil,
      :result => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(/1/)
  end
end
