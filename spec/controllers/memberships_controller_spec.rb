require 'rails_helper'

describe MembershipsController do
  pending 'get #index'
  pending 'get #show'
  pending 'get #new'

  describe 'post #create' do
    let!(:user) { FactoryBot.create(:user, :without_membership) }

    context 'with errors' do
      before(:each) do
        sign_in user
      end

      it 'catches a payment error' do
        allow(Stripe::Customer).to receive(:create).and_return(double('Stripe::Customer', id: StripeHelper.customer_token, default_source: StripeHelper.card_token))
        allow(Stripe::Charge).to receive(:create).and_raise(Stripe::StripeError, 'Something went wrong')

        expect(Rails.logger).to receive(:error).with(a_string_including('Something went wrong'))
        expect(subject).to receive(:prepare_new_form)

        post :create, params: { type: 'Individual', user_id: user.username, membership: { year: Date.current.year, stripe_card_token: StripeHelper.card_token, type: 'Individual' } }

        expect(response).to have_http_status(:ok)
        expect(flash.now[:alert]).to eq('Something went wrong')
      end
    end

    context 'with valid payment info' do
      before(:each) do
        sign_in user

        allow(Stripe::Customer).to receive(:create).and_return(double('Stripe::Customer', id: StripeHelper.customer_token, default_source: StripeHelper.card_token))
        allow(Stripe::Charge).to receive(:create).and_return(double('Stripe::Charge', id: StripeHelper.charge_id))
      end

      it 'creates a new Membership' do
        expect {
          post :create, params: { type: 'Individual', user_id: user.username, membership: { year: Date.current.year, stripe_card_token: StripeHelper.card_token, type: 'Individual' } }
        }.to change { user.memberships.reload.size }.by(1)
      end

      it 'sends notification emails' do
        expect(MembershipMailer).to receive(:new_membership_confirmation_email).and_return(double(ActionMailer::MessageDelivery, deliver_now: true))
        expect(MembershipMailer).to receive(:new_membership_alert).and_return(double(ActionMailer::MessageDelivery, deliver_now: true))

        post :create, params: {
          type: 'Individual',
          user_id: user.username,
          membership: { year: Date.current.year, stripe_card_token: StripeHelper.card_token, type: 'Individual' },
        }
      end

      it 'notifies Slack' do
        allow(MembershipMailer).to receive(:new_membership_confirmation_email).and_return(double(ActionMailer::MessageDelivery, deliver_now: true))
        allow(MembershipMailer).to receive(:new_membership_alert).and_return(double(ActionMailer::MessageDelivery, deliver_now: true))

        expect(SlackBot).to receive(:post_message)

        post :create, params: {
          type: 'Individual',
          user_id: user.username,
          membership: { year: Date.current.year, stripe_card_token: StripeHelper.card_token, type: 'Individual' },
        }
      end
    end
  end

  pending 'patch #cancel'
  pending 'delete #destroy'

  describe 'any #webhooks' do
    context 'charge' do
      describe('succeeded') { it_behaves_like 'Ignored Webhooks', 'charge.succeeded' }
      describe('failed') { it_behaves_like 'Ignored Webhooks', 'charge.failed' }

      describe 'charge.refunded' do
        let!(:event) { JSON.parse(File.read(Rails.root.join('spec/fixtures/webhooks/charge.refunded.json'))).with_indifferent_access }

        context 'with valid user' do
          let!(:user) {
            FactoryBot.create(:user).tap do |u|
              u.update_attribute(:stripe_customer_token, event[:data][:object][:customer])
              u.current_membership.update(info: {}, stripe_charge_id: event[:data][:object][:id])
            end
          }

          it 'marks corresponding customer as refunded' do
            membership = user.current_membership
            expect {
              post :webhooks, params: event
            }.to change {
              membership.reload.refunded
            }.from nil
            expect(user.current_member?).to be_falsey
            expect(response).to have_http_status :success
          end

          it 'logs an error for no corresponding charge ID' do
            user.current_membership.destroy
            expect(Rails.logger).to receive(:error).with(a_string_including('No membership associated with Stripe Charge'))

            post :webhooks, params: event

            expect(response).to have_http_status :not_found
          end
        end

        context 'without valid user' do
          it 'logs an error for no corresponding user' do
            expect(Rails.logger).to receive(:error).with(a_string_including('No User could be found with Stripe ID'))

            post :webhooks, params: event

            expect(response).to have_http_status :not_found
          end
        end
      end
    end

    context 'customer' do
      describe('created') { it_behaves_like 'Ignored Webhooks', 'customer.created' }
      describe('updated') { it_behaves_like 'Ignored Webhooks', 'customer.updated' }

      context 'card' do
        describe('created') { it_behaves_like 'Ignored Webhooks', 'customer.card.created' }
        describe('deleted') { it_behaves_like 'Ignored Webhooks', 'customer.card.deleted' }
        describe('updated') { it_behaves_like 'Ignored Webhooks', 'customer.card.updated' }
      end

      context 'subscription' do
        describe('created') { it_behaves_like 'Ignored Webhooks', 'customer.subscription.created' }
        describe('deleted') { it_behaves_like 'Ignored Webhooks', 'customer.subscription.deleted' }
      end
    end

    context 'invoice' do
      describe('created') { it_behaves_like 'Ignored Webhooks', 'invoice.created' }

      describe 'payment_succeded' do
        let!(:event) { JSON.parse(File.read(Rails.root.join('spec/fixtures/webhooks/invoice.payment_succeeded.json'))).with_indifferent_access }

        context 'without valid user' do
          it 'logs an error for no corresponding user' do
            expect(Rails.logger).to receive(:error).with(a_string_including('No User could be found with Stripe ID'))

            post :webhooks, params: event

            expect(response).to have_http_status :not_found
          end
        end

        context 'with valid user' do
          let!(:user) {
            FactoryBot.create(:user, :without_membership).tap do |u|
              u.update_attribute(:stripe_customer_token, event[:data][:object][:customer])
              u.memberships.new(
                year: Time.zone.at(event[:created]).year - 1,
                type: 'Individual',
                stripe_subscription_id: event[:data][:object][:subscription]
              ).save(validate: false)
            end
          }

          before(:each) { Timecop.travel(Time.zone.at(event[:created])) }
          after(:each) { Timecop.return }

          before :each do
            allow(Stripe::Subscription).to receive(:retrieve) {
              double(
                'Stripe::Subscription',
                id: event.dig(:data, :object, :subscription),
                current_period_start: Time.current,
                plan: double('Stripe::Plan', id: 'individual')
              )
            }
          end

          it 'creates a new Membership for a corresponding user' do
            expect { post :webhooks, params: event }.to change(Membership, :count).by 1
            expect(user.current_member?).to be_truthy
            expect(response).to have_http_status(:success)
          end

          it 'sends notifications' do
            expect(MembershipNotifier).to receive(:new).with(user: user, membership: a_kind_of(Membership)).and_return(double('MembershipNotifier', notify_renewal: nil))

            post :webhooks, params: event
          end

          it 'doesn\'t create a duplicate membership' do
            user.memberships.create(type: 'Individual', year: Date.current.year)

            allow(Rails.logger).to receive(:info)
            expect(Rails.logger).to receive(:info).with(a_string_including('duplicate Membership'))
            expect { post :webhooks, params: event }.not_to change(Membership, :count)
            expect(response).to have_http_status(:success)
          end
        end
      end
    end

    describe 'non-customer events' do
      context 'transfer' do
        describe('created') { it_behaves_like 'Ignored Webhooks', 'transfer.created' }
        describe('paid') { it_behaves_like 'Ignored Webhooks', 'transfer.paid' }
      end

      context 'balance' do
        describe('available') { it_behaves_like 'Ignored Webhooks', 'balance.available' }
      end
    end
  end
end
