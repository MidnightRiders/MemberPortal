require 'spec_helper'

describe "rev_guesses/new" do
  before(:each) do
    assign(:rev_guess, stub_model(RevGuess,
      :match => nil,
      :user => nil,
      :home_goals => 1,
      :away_goals => 1,
      :comment => "MyString"
    ).as_new_record)
  end

  it "renders new rev_guess form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", rev_guesses_path, "post" do
      assert_select "input#rev_guess_match[name=?]", "rev_guess[match]"
      assert_select "input#rev_guess_user[name=?]", "rev_guess[user]"
      assert_select "input#rev_guess_home_goals[name=?]", "rev_guess[home_goals]"
      assert_select "input#rev_guess_away_goals[name=?]", "rev_guess[away_goals]"
      assert_select "input#rev_guess_comment[name=?]", "rev_guess[comment]"
    end
  end
end
