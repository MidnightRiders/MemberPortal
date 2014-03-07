require 'spec_helper'

describe "rev_guesses/index" do
  before(:each) do
    assign(:rev_guesses, [
      stub_model(RevGuess,
        :match => nil,
        :user => nil,
        :home_goals => 1,
        :away_goals => 2,
        :comment => "Comment"
      ),
      stub_model(RevGuess,
        :match => nil,
        :user => nil,
        :home_goals => 1,
        :away_goals => 2,
        :comment => "Comment"
      )
    ])
  end

  it "renders a list of rev_guesses" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Comment".to_s, :count => 2
  end
end
