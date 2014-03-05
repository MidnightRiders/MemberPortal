require 'spec_helper'

describe "clubs/edit" do
  before(:each) do
    @club = assign(:club, stub_model(Club,
      :name => "MyString",
      :conference => "MyString",
      :primary_color => "MyString",
      :secondary_color => "MyString",
      :accent_color => "MyString",
      :abbrv => "MyString"
    ))
  end

  it "renders the edit club form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", club_path(@club), "post" do
      assert_select "input#club_name[name=?]", "club[name]"
      assert_select "input#club_conference[name=?]", "club[conference]"
      assert_select "input#club_primary_color[name=?]", "club[primary_color]"
      assert_select "input#club_secondary_color[name=?]", "club[secondary_color]"
      assert_select "input#club_accent_color[name=?]", "club[accent_color]"
      assert_select "input#club_abbrv[name=?]", "club[abbrv]"
    end
  end
end
