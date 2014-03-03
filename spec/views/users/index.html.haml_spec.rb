require 'spec_helper'

describe "users/index" do
  before(:each) do
    assign(:users, [
      stub_model(User,
        :type_id => 1,
        :last_name => "Last Name",
        :first_name => "First Name",
        :last_name => "Last Name",
        :address => "Address",
        :city => "City",
        :state => "State",
        :postal_code => "Postal Code",
        :phone => "Phone",
        :email => "Email",
        :member_since => "Member Since"
      ),
      stub_model(User,
        :type_id => 1,
        :last_name => "Last Name",
        :first_name => "First Name",
        :last_name => "Last Name",
        :address => "Address",
        :city => "City",
        :state => "State",
        :postal_code => "Postal Code",
        :phone => "Phone",
        :email => "Email",
        :member_since => "Member Since"
      )
    ])
  end

  it "renders a list of users" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Last Name".to_s, :count => 2
    assert_select "tr>td", :text => "First Name".to_s, :count => 2
    assert_select "tr>td", :text => "Last Name".to_s, :count => 2
    assert_select "tr>td", :text => "Address".to_s, :count => 2
    assert_select "tr>td", :text => "City".to_s, :count => 2
    assert_select "tr>td", :text => "State".to_s, :count => 2
    assert_select "tr>td", :text => "Postal Code".to_s, :count => 2
    assert_select "tr>td", :text => "Phone".to_s, :count => 2
    assert_select "tr>td", :text => "Email".to_s, :count => 2
    assert_select "tr>td", :text => "Member Since".to_s, :count => 2
  end
end
