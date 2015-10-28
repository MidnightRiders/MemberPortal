require 'rails_helper'

RSpec.describe "discussions/show", :type => :view do
  before(:each) do
    @discussion = assign(:discussion, Discussion.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
