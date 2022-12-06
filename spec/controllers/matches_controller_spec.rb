require 'spec_helper'

describe MatchesController do
  pending 'get #index'
  pending 'get #show'

  context 'admin actions' do
    pending 'get #new'
    pending 'get #edit'
    pending 'post #create'
    pending 'patch #update'
    pending 'delete #destroy'
    pending 'post #import'
    pending 'get #auto_update'

    context 'get #sync', :vcr do
      before :each do
        Timecop.travel(Time.new(2021, 6, 15, 12))
      end

      # Note: this creates the user after Timecop.travel; if this gets
      # moved, the admin will or may not be able to access #sync
      before(:each) { sign_in FactoryBot.create(:user, :admin) }

      after :each do
        Timecop.return
      end

      it 'creates matches', :vcr do
        expect {
          get :sync
          puts flash[:error]
        }.to change(Match, :count).by(113)
      end
    end
  end
end
