require 'spec_helper'

describe "rev_guesses/edit" do
  before(:each) do
    @rev_guess = assign(:rev_guess, stub_model(RevGuess,
      :match => nil,
      :user => nil,
      :home_goals => 1,
      :away_goals => 1,
      :comment => "MyString"
    ))
  end

  it "renders the edit rev_guess form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", rev_guess_path(@rev_guess), "post" do
      assert_select "input#rev_guess_match[name=?]", "rev_guess[match]"
      assert_select "input#rev_guess_user[name=?]", "rev_guess[user]"
      assert_select "input#rev_guess_home_goals[name=?]", "rev_guess[home_goals]"
      assert_select "input#rev_guess_away_goals[name=?]", "rev_guess[away_goals]"
      assert_select "input#rev_guess_comment[name=?]", "rev_guess[comment]"
    end
  end
end
