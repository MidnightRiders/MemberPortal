require 'spec_helper'

describe "mot_ms/edit" do
  before(:each) do
    @mot_m = assign(:mot_m, stub_model(MotM,
      :user_id => "MyString",
      :match_id => "MyString",
      :first_id => "MyString",
      :second_id => "MyString",
      :third_id => "MyString"
    ))
  end

  it "renders the edit mot_m form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", mot_m_path(@mot_m), "post" do
      assert_select "input#mot_m_user_id[name=?]", "mot_m[user_id]"
      assert_select "input#mot_m_match_id[name=?]", "mot_m[match_id]"
      assert_select "input#mot_m_first_id[name=?]", "mot_m[first_id]"
      assert_select "input#mot_m_second_id[name=?]", "mot_m[second_id]"
      assert_select "input#mot_m_third_id[name=?]", "mot_m[third_id]"
    end
  end
end
