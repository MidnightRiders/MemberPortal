require 'support/stripe_helper'

shared_examples_for 'Commerce::Subscribable' do
  it 'validates unique Stripe subscription' do
    product.update_attribute(:stripe_subscription_id, StripeHelper.subscription_id)
    new_product = product.dup
    new_product.user_id = FactoryBot.create(:user).id

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

  describe 'subscription?' do
    it 'returns false for never having been subscribed' do
      expect(product.subscription?).to be false
    end

    it 'returns false for having a canceled subscription' do
      allow(Stripe::Subscription).to receive(:update).with(/^sub_[a-z0-9]{23}$/, { cancel_at_period_end: true })

      stripe_subscription_id = StripeHelper.subscription_id
      product.update_attribute(:stripe_subscription_id, stripe_subscription_id)
      product.cancel

      expect(product.subscription?).to be false
    end

    it 'returns true for having an active subscription' do
      stripe_subscription_id = StripeHelper.subscription_id
      product.update_attribute(:stripe_subscription_id, stripe_subscription_id)

      expect(product.subscription?).to be true
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
        expect(Stripe::Subscription).to receive(:update).with(/^sub_[a-z0-9]{23}$/, { cancel_at_period_end: true })

        product.cancel
      end

      it 'replaces stripe_subscription_id with "Stripe Subscription [SUBSCRIPTION ID] Canceled"' do
        allow(Stripe::Subscription).to receive(:update).with(/^sub_[a-z0-9]{23}$/, { cancel_at_period_end: true })
        sub_id = product.stripe_subscription_id

        expect { product.cancel }
          .to change { product.stripe_subscription_id }
          .to "Stripe Subscription #{sub_id} Canceled"
      end

      it 'refunds if argument is true' do
        allow(Stripe::Subscription).to receive(:update).with(/^sub_[a-z0-9]{23}$/, { cancel_at_period_end: true })

        expect(product).to receive(:refund)

        product.cancel(true)
      end

      it 'does not refund if argument is false' do
        allow(Stripe::Subscription).to receive(:update).with(/^sub_[a-z0-9]{23}$/, { cancel_at_period_end: true })

        expect(product).not_to receive(:refund)

        product.cancel
      end

      it 'adds an error to base if Stripe::StripeError is raised while canceling' do
        allow(Stripe::Subscription)
          .to receive(:update).with(/^sub_[a-z0-9]{23}$/, { cancel_at_period_end: true })
          .and_raise(Stripe::StripeError.new('Message'))

        product.cancel
        expect(product.errors[:base]).to include('There was a problem while canceling your subscription: Message')
      end
    end
  end
end
