require 'spec_helper'

describe "users/edit" do
  before(:each) do
    @user = assign(:user, stub_model(User,
      :type_id => 1,
      :last_name => "MyString",
      :first_name => "MyString",
      :last_name => "MyString",
      :address => "MyString",
      :city => "MyString",
      :state => "MyString",
      :postal_code => "MyString",
      :phone => "MyString",
      :email => "MyString",
      :member_since => "MyString"
    ))
  end

  it "renders the edit user form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", user_path(@user), "post" do
      assert_select "input#user_type_id[name=?]", "user[type_id]"
      assert_select "input#user_last_name[name=?]", "user[last_name]"
      assert_select "input#user_first_name[name=?]", "user[first_name]"
      assert_select "input#user_last_name[name=?]", "user[last_name]"
      assert_select "input#user_address[name=?]", "user[address]"
      assert_select "input#user_city[name=?]", "user[city]"
      assert_select "input#user_state[name=?]", "user[state]"
      assert_select "input#user_postal_code[name=?]", "user[postal_code]"
      assert_select "input#user_phone[name=?]", "user[phone]"
      assert_select "input#user_email[name=?]", "user[email]"
      assert_select "input#user_member_since[name=?]", "user[member_since]"
    end
  end
end
