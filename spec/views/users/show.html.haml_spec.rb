require 'spec_helper'

describe "users/show" do
  before(:each) do
    @user = assign(:user, stub_model(User,
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
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Last Name/)
    rendered.should match(/First Name/)
    rendered.should match(/Last Name/)
    rendered.should match(/Address/)
    rendered.should match(/City/)
    rendered.should match(/State/)
    rendered.should match(/Postal Code/)
    rendered.should match(/Phone/)
    rendered.should match(/Email/)
    rendered.should match(/Member Since/)
  end
end
