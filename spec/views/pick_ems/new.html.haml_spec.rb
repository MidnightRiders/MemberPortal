require 'spec_helper'

describe "pick_ems/new" do
  before(:each) do
    assign(:pick_em, stub_model(PickEm,
      :match => nil,
      :user => nil,
      :result => 1
    ).as_new_record)
  end

  it "renders new pick_em form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", pick_ems_path, "post" do
      assert_select "input#pick_em_match[name=?]", "pick_em[match]"
      assert_select "input#pick_em_user[name=?]", "pick_em[user]"
      assert_select "input#pick_em_result[name=?]", "pick_em[result]"
    end
  end
end
