require 'spec_helper'

describe "clubs/show" do
  before(:each) do
    @club = assign(:club, stub_model(Club,
      :name => "Name",
      :conference => "Conference",
      :primary_color => "Primary Color",
      :secondary_color => "Secondary Color",
      :accent_color => "Accent Color",
      :abbrv => "Abbrv"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/Conference/)
    rendered.should match(/Primary Color/)
    rendered.should match(/Secondary Color/)
    rendered.should match(/Accent Color/)
    rendered.should match(/Abbrv/)
  end
end
