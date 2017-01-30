require 'spec_helper'

describe MembershipsController do
  pending 'get #index'
  pending 'get #show'
  pending 'get #new'

  describe 'post #create' do
    let!(:user) { FactoryGirl.create(:user, :without_membership) }
    before(:each) do
      sign_in user

      allow(Stripe::Customer).to receive(:create).and_return(double('Stripe::Customer', id: StripeHelper.customer_token, default_source: StripeHelper.card_token))
      allow(Stripe::Charge).to receive(:create).and_return(double('Stripe::Charge', id: StripeHelper.charge_id))
    end

    context 'with valid payment info' do
      it 'creates a new Membership' do
        expect {
          post :create, type: :Individual, user_id: user.username, membership: { year: Date.current.year, stripe_card_token: StripeHelper.card_token, type: :Individual }
        }.to change { user.memberships.reload.size }.by(1)
      end

      it 'sends notification emails' do
        expect(MembershipMailer).to receive(:new_membership_confirmation_email).and_return(double(ActionMailer::MessageDelivery, deliver_now: true))
        expect(MembershipMailer).to receive(:new_membership_alert).and_return(double(ActionMailer::MessageDelivery, deliver_now: true))

        post :create, type: :Individual,
          user_id: user.username,
          membership: { year: Date.current.year, stripe_card_token: StripeHelper.card_token, type: :Individual }
      end

      it 'notifies Slack' do
        allow(MembershipMailer).to receive(:new_membership_confirmation_email).and_return(double(ActionMailer::MessageDelivery, deliver_now: true))
        allow(MembershipMailer).to receive(:new_membership_alert).and_return(double(ActionMailer::MessageDelivery, deliver_now: true))

        expect(SlackBot).to receive(:post_message)

        post :create, type: :Individual,
          user_id: user.username,
          membership: { year: Date.current.year, stripe_card_token: StripeHelper.card_token, type: :Individual }
      end
    end
  end

  pending 'patch #cancel'
  pending 'delete #destroy'
  pending 'any #webhooks'
end
