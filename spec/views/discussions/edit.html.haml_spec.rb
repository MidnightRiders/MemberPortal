require 'rails_helper'

RSpec.describe "discussions/edit", :type => :view do
  before(:each) do
    @discussion = assign(:discussion, Discussion.create!())
  end

  it "renders the edit discussion form" do
    render

    assert_select "form[action=?][method=?]", discussion_path(@discussion), "post" do
    end
  end
end
