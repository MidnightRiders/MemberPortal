require 'spec_helper'

describe MatchesController do
  skip 'get #index'
  skip 'get #show'

  context 'admin actions' do
    before(:each) { sign_in FactoryGirl.create(:user, :admin) }

    skip 'get #new'
    skip 'get #edit'
    skip 'post #create'
    skip 'patch #update'
    skip 'delete #destroy'
    skip 'post #import'
    skip 'get #auto_update'
    skip 'post #bulk_update'
  end
end
