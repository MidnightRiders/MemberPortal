require 'rails_helper'

RSpec.describe "discussions/index", :type => :view do
  before(:each) do
    assign(:discussions, [
      Discussion.create!(),
      Discussion.create!()
    ])
  end

  it "renders a list of discussions" do
    render
  end
end
