require 'rails_helper'

require 'support/stripe_helper'

RSpec.describe StripeWebhookService do
  describe '#process' do
    it 'returns 200 for non-accepted events' do
      event_file = nil
      loop do
        event_file = Dir[Rails.root.join('spec/fixtures/webhooks', '*.json')].sample
        break unless File.basename(event_file, '.json').in? StripeWebhookService::ACCEPTED_EVENTS
      end
      event = JSON.parse(File.read(event_file))
      webhook = StripeWebhookService.new(event)

      expect(Rails.logger).to receive(:warn).with(a_string_including('not in accepted webhooks'))
      expect(webhook).not_to receive(:customer_token)

      status = webhook.process

      expect(status).to eq(200)
    end

    it 'returns 200 for explicitly ignored Stripe::Event IDs' do
      ignored_id = StripeHelper.event_id
      ignored_ids = [ignored_id] + Array.new(5) { StripeHelper.event_id }
      allow(ENV).to receive(:[]).with('IGNORED_STRIPE_EVENT_IDS').and_return ignored_ids.join(',')

      event = { id: ignored_id, type: 'charge_refunded' }

      webhook = StripeWebhookService.new(event)

      expect(webhook).not_to receive(:charge_refunded)

      status = webhook.process

      expect(status).to eq(200)
    end

    StripeWebhookService::ACCEPTED_EVENTS.each do |event_name|
      context "event: #{event_name}" do
        it "returns 200 for events that don't have a Stripe::Customer" do
          event = JSON.parse(File.read(Rails.root.join("spec/fixtures/webhooks/#{event_name}.json"))).with_indifferent_access
          if event[:data][:object][:object] == 'customer'
            event[:data][:object][:id] = ''
          else
            event[:data][:object][:customer] = ''
          end
          webhook = StripeWebhookService.new(event)

          expect(Rails.logger).to receive(:error).with('No Stripe::Customer attached to event.')

          status = webhook.process

          expect(status).to eq(200)
        end

        it "returns 404 for events that don't have a user" do
          event = JSON.parse(File.read(Rails.root.join("spec/fixtures/webhooks/#{event_name}.json"))).with_indifferent_access
          webhook = StripeWebhookService.new(event)

          expect(Rails.logger).to receive(:error).with(a_string_including('No User could be found'))

          status = webhook.process

          expect(status).to eq(404)
        end
      end
    end

    it 'calls charge_refunded for charge.refunded event' do
      event = JSON.parse(File.read(Rails.root.join('spec/fixtures/webhooks/charge.refunded.json'))).with_indifferent_access
      FactoryBot.create(:user).tap do |u|
        u.update(stripe_customer_token: event[:data][:object][:customer])
        u.current_membership.update(stripe_charge_id: event[:data][:object][:id])
      end
      webhook = StripeWebhookService.new(event)

      expect(webhook).to receive(:charge_refunded)

      webhook.process
    end
    it 'calls invoice_payment_received for invoice.payment_succeeded event' do
      event = JSON.parse(File.read(Rails.root.join('spec/fixtures/webhooks/invoice.payment_succeeded.json'))).with_indifferent_access
      FactoryBot.create(:user, :without_membership).tap do |u|
        u.update(stripe_customer_token: event[:data][:object][:customer])
      end
      webhook = StripeWebhookService.new(event)

      expect(webhook).to receive(:invoice_payment_succeeded)

      webhook.process
    end
  end

  describe 'charge_refunded' do
    let!(:event) { JSON.parse(File.read(Rails.root.join('spec/fixtures/webhooks/charge.refunded.json'))).with_indifferent_access }
    let(:user) {
      FactoryBot.create(:user).tap do |u|
        u.update(stripe_customer_token: event[:data][:object][:customer])
        u.current_membership.update(stripe_charge_id: event[:data][:object][:id])
      end
    }

    it "logs an error if a Membership can't be found for the charge" do
      user.current_membership.destroy
      webhook = StripeWebhookService.new(event)

      expect(Rails.logger).to receive(:error).with(a_string_including('No membership associated'))

      status = webhook.process

      expect(status).to eq(404)
    end

    it 'marks a matching Membership as refunded' do
      webhook = StripeWebhookService.new(event)
      membership = user.current_membership
      status = nil

      expect(Rails.logger).not_to receive(:error)

      expect { status = webhook.process }.to change { membership.reload.refunded }.to 'true'
      expect(status).to eq(200)
    end
  end

  describe 'invoice_payment_succeeded' do
    let!(:event) { JSON.parse(File.read(Rails.root.join('spec/fixtures/webhooks/invoice.payment_succeeded.json'))).with_indifferent_access }
    let!(:user) {
      FactoryBot.create(:user, :without_membership).tap do |u|
        u.update(stripe_customer_token: event[:data][:object][:customer])
        u.memberships.new(
          year: Time.zone.at(event[:created]).year - 1,
          type: 'Individual',
          stripe_subscription_id: event[:data][:object][:subscription]
        ).save!(validate: false)
      end
    }

    before(:each) { Timecop.travel(Time.zone.at(event[:created])) }
    after(:each) { Timecop.return }

    it 'does not renew a membership if a membership already exists' do
      user.memberships.create(type: 'Individual', year: Date.current.year)
      webhook = StripeWebhookService.new(event)
      status = nil

      expect { status = webhook.process }.not_to change(Membership, :count)
      expect(status).to eq(200)
    end

    it 'does not renew a membership if no prior membership exists' do
      user.memberships.each(&:destroy)
      webhook = StripeWebhookService.new(event)
      status = nil

      expect(Rails.logger).to receive(:error).with(a_string_including('Could not find record to renew'))
      expect { status = webhook.process }.not_to change(Membership, :count)
      expect(status).to eq(500)
    end

    it 'renews a subscription-based membership' do
      webhook = StripeWebhookService.new(event)
      status = nil

      expect { status = webhook.process }.to change(Membership, :count).by 1
      expect(status).to eq(200)
    end
  end
end
