require 'spec_helper'

describe 'users/show' do

  it 'will show address for same user' do
    u = FactoryGirl.create :user
    sign_in u
    page.should have_content(u.address)
  end
end
