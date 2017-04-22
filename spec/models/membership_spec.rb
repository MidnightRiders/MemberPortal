require 'rails_helper'
require 'support/shared_examples/purchasable'
require 'support/shared_examples/subscribable'

RSpec.describe Membership do
  let!(:admin) { FactoryGirl.create(:user, :admin) }
  let(:membership) { FactoryGirl.create(:membership) }

  describe 'scopes' do
    pending 'refunds'
    pending 'current'
    pending 'for_year'
  end

  it_behaves_like 'Commerce::Purchasable' do
    let(:product) { FactoryGirl.build(:membership).tap { |m| m.info = {} } }
  end

  it_behaves_like 'Commerce::Subscribable' do
    let(:product) { FactoryGirl.build(:membership).tap { |m| m.info = {} } }
  end

  describe 'notify_slack' do
    it 'generates the proper message for SlackBot' do
      expected_message = "New Individual Membership for #{membership.user.first_name} #{membership.user.last_name} (<#{user_url(membership.user)}|@#{membership.user.username}>):\n*#{Date.current.year} Total: #{Membership.for_year(membership.year).count}* | #{Membership.breakdown(membership.year)}"
      expect(SlackBot).to receive(:post_message).with(expected_message, 'membership')
      membership.notify_slack
    end
  end
end
