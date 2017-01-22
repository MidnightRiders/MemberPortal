require 'spec_helper'

describe Relative do

  describe 'validation' do
    it 'strips whitespace from an invited email before validation' do
      relative = Relative.new(info: { invited_email: ' test.email@with-spaces.com ', pending_approval: true })

      relative.valid?

      expect(relative.info[:invited_email]).to eq('test.email@with-spaces.com')
    end
  end

  describe 'relatives' do
    skip 'returns array with Family & other relatives but not self'
  end

  describe 're_up_for' do
    skip 'creates new Relative for given year with same info'
  end

  describe 'notify_slack' do
    let!(:admin) { FactoryGirl.create(:user, :admin) }
    let(:relative) { FactoryGirl.create(:membership, :relative).becomes(Relative) }

    it 'generates the proper message for SlackBot' do
      expected_message = "#{relative.user.first_name} #{relative.user.last_name} (<#{user_url(relative.user)}|@#{relative.user.username}>) has accepted *#{relative.family.user.first_name} #{relative.family.user.last_name}’s Family Membership invitation*:\nThere are now *#{Membership.for_year(relative.year).size} registered #{relative.year} Memberships.*\n#{Membership.breakdown(relative.year)}"
      expect(SlackBot).to receive(:post_message).with(expected_message, 'membership')
      relative.notify_slack
    end
  end
end
