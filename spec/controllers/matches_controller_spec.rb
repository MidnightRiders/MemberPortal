require 'rails_helper'

RSpec.describe MatchesController do
  pending 'get #index'
  pending 'get #show'

  context 'admin actions' do
    before(:each) { sign_in FactoryGirl.create(:user, :admin) }

    pending 'get #new'
    pending 'get #edit'
    pending 'post #create'
    pending 'patch #update'
    pending 'delete #destroy'
    pending 'post #import'
    pending 'get #auto_update'
    pending 'post #bulk_update'
  end
end
