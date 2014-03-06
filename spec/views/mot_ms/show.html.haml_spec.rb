require 'spec_helper'

describe "mot_ms/show" do
  before(:each) do
    @mot_m = assign(:mot_m, stub_model(MotM,
      :user_id => "User",
      :match_id => "Match",
      :first_id => "First",
      :second_id => "Second",
      :third_id => "Third"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/User/)
    rendered.should match(/Match/)
    rendered.should match(/First/)
    rendered.should match(/Second/)
    rendered.should match(/Third/)
  end
end
