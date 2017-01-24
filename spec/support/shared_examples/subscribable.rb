require 'support/stripe_helper'

shared_examples_for 'Commerce::Subscribable' do
  it 'validates unique Stripe subscription' do
    product.update_attribute(:stripe_subscription_id, StripeHelper.subscription_id)
    new_product = product.dup
    new_product.user_id = FactoryGirl.create(:user).id

    expect(new_product).not_to be_valid
    expect(new_product.errors.messages.keys).to include(:stripe_subscription_id)
  end

  describe 'subscribe' do
    it 'converts "1" to true' do
      product.subscribe = '1'

      expect(product.subscribe?).to eq(true)
    end

    it 'converts "0" to false' do
      product.subscribe = '0'

      expect(product.subscribe?).to eq(false)
    end

    it 'converts 1 to true' do
      product.subscribe = 1

      expect(product.subscribe?).to eq(true)
    end

    it 'converts 0 to false' do
      product.subscribe = 0

      expect(product.subscribe?).to eq(false)
    end
  end

  describe 'cancel' do
    context 'without stripe_subscription_id' do
      it 'returns false' do
        expect(product.cancel).to be_falsey
      end
    end

    context 'with stripe_subscription_id' do
      before(:each) { product.update_attribute(:stripe_subscription_id, StripeHelper.subscription_id) }

      it 'calls delete on the Stripe::Subscription' do
        expect(product.purchaser).to receive_message_chain('stripe_customer.subscriptions.retrieve.delete')

        product.cancel
      end

      it 'replaces stripe_subscription_id with "Stripe Subscription Canceled"' do
        allow(product.purchaser).to receive_message_chain('stripe_customer.subscriptions.retrieve.delete')

        expect { product.cancel }.to change { product.stripe_subscription_id }.to 'Stripe Subscription Canceled'
      end

      it 'refunds if argument is true' do
        allow(product.purchaser).to receive_message_chain('stripe_customer.subscriptions.retrieve.delete')

        expect(product).to receive(:refund)

        product.cancel(true)
      end

      it 'does not refund if argument is false' do
        allow(product.purchaser).to receive_message_chain('stripe_customer.subscriptions.retrieve.delete')

        expect(product).not_to receive(:refund)

        product.cancel
      end

      it 'adds an error to base if Stripe::StripeError is raised while canceling' do
        allow(product.purchaser).to receive_message_chain('stripe_customer.subscriptions.retrieve.delete').and_raise(Stripe::StripeError.new('Message'))

        product.cancel
        expect(product.errors[:base]).to include('There was a problem while canceling your subscription: Message')
      end
    end
  end
end
