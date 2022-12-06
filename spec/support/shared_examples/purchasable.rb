require 'support/stripe_helper'

shared_examples_for 'Commerce::Purchasable' do
  it 'validates unique stripe charge' do
    product.update(stripe_charge_id: StripeHelper.charge_id)
    new_product = product.dup

    expect(new_product).not_to be_valid
    expect(new_product.errors.messages).to include(stripe_charge_id: ['has already been taken'])
  end

  describe 'payment validation' do
    it 'adds an error if there\'s no charge or way to make a charge' do
      expect { product.__send__(:paid_for?) }.to change { product.errors.messages }
    end

    it 'does not add an error if stripe_card_token is present' do
      product.stripe_card_token = StripeHelper.card_token

      expect { product.__send__(:paid_for?) }.not_to change { product.errors.messages }
    end

    it 'does not add an error if purchaser\'s stripe_customer_token is present' do
      product.purchaser.update_attribute(:stripe_customer_token, StripeHelper.customer_token)

      expect { product.__send__(:paid_for?) }.not_to change { product.errors.messages }
    end
  end

  describe 'charge_information' do
    let(:default_source) { StripeHelper.card_id }
    before(:each) do
      product.user.update_attribute(:stripe_customer_token, StripeHelper.customer_token)
      stripe_customer = double('Stripe::Customer', default_source: default_source, id: product.user.stripe_customer_token)
      allow(Stripe::Customer).to receive(:retrieve).and_return(stripe_customer)
    end

    it 'returns a Hash' do
      expect(product.charge_information).to be_a(Hash)
    end

    it 'returns the default source when no card token is passed' do
      expect(product.charge_information[:source]).to eq default_source
    end

    it 'returns the card token as source when it is passed' do
      card_token = StripeHelper.card_token

      expect(product.charge_information(card_token)[:source]).to eq card_token
    end
  end

  describe 'make_stripe_charge' do
    it 'sets stripe_charge_id' do
      charge_id = StripeHelper.charge_id
      allow(product).to receive(:charge_information).and_return({})
      allow(Stripe::Charge).to receive(:create).and_return(double('Stripe::Charge', id: charge_id))

      expect { product.make_stripe_charge }.to change { product.stripe_charge_id }.to(charge_id)
    end

    it 'passes the card_id to Stripe::Charge if present' do
      product.user.update_attribute(:stripe_customer_token, StripeHelper.customer_token)
      stripe_customer = double('Stripe::Customer', id: product.user.stripe_customer_token)
      allow(Stripe::Customer).to receive(:retrieve).and_return(stripe_customer)

      card_id = StripeHelper.card_id

      expect(Stripe::Charge).to receive(:create).with(hash_including(source: card_id)).and_return(double('Stripe::Charge', id: ''))

      product.make_stripe_charge(card_id)
    end
  end

  describe 'save_with_payment!' do
    let(:stripe_card_token) { StripeHelper.card_token }

    before(:each) do
      default_source = StripeHelper.card_id
      product.user.update_attribute(:stripe_customer_token, StripeHelper.customer_token)
      stripe_customer = double('Stripe::Customer', default_source: default_source, id: product.user.stripe_customer_token)
      allow(Stripe::Customer).to receive(:retrieve).and_return(stripe_customer)
    end

    it 'returns nil if not valid' do
      allow(product).to receive(:valid?).and_return(false)

      expect(product.save_with_payment!).to be_nil
    end

    it 'calls create_or_update_stripe_customer on the purchaser' do
      product.stripe_card_token = stripe_card_token

      expect(product.purchaser).to receive(:create_or_update_stripe_customer).with(stripe_card_token)

      allow(Stripe::Charge).to receive(:create).and_return(double('Stripe::Charge', id: nil))
      product.save_with_payment!
    end

    it 'makes stripe charge' do
      product.stripe_card_token = stripe_card_token

      expect(product).to receive(:make_stripe_charge).with(nil)

      allow(product.purchaser).to receive(:create_or_update_stripe_customer).and_return(double('Stripe::Customer'))
      product.save_with_payment!
    end

    it 'makes stripe charge with card_id if passed' do
      product.stripe_card_token = ''
      card_id = StripeHelper.card_id

      expect(product).to receive(:make_stripe_charge).with(card_id)

      allow(product.purchaser).to receive(:create_or_update_stripe_customer).and_return(double('Stripe::Customer'))
      product.save_with_payment!(card_id)
    end

    it 'ignores card_id if stripe_card_token is present' do
      product.stripe_card_token = stripe_card_token
      card_id = StripeHelper.card_id

      expect(product).to receive(:make_stripe_charge).with(nil)

      allow(product.purchaser).to receive(:create_or_update_stripe_customer).and_return(double('Stripe::Customer'))
      product.save_with_payment!(card_id)
    end

    it 'does not save if the Stripe Charge fails' do
      product.stripe_card_token = stripe_card_token
      allow(product).to receive(:make_stripe_charge).and_raise(Stripe::StripeError, 'Something broke')
      allow(product.purchaser).to receive(:create_or_update_stripe_customer).and_return(double('Stripe::Customer'))

      expect(product.class).not_to receive(:include?)
      expect(product.purchaser).not_to receive(:subscribe_to)

      expect { product.save_with_payment! }.to raise_error(Stripe::StripeError, 'Something broke')

      expect(product.persisted?).to be(false)
    end
  end

  describe 'refund' do
    it 'sets refund to true if there is not a stripe_charge_id' do
      expect { product.refund }.to change { product.refunded }.to 'true'
    end

    it 'saves the Stripe::Refund id to the refund attribute' do
      product.update_attribute(:stripe_charge_id, StripeHelper.charge_id)
      refund_id = StripeHelper.refund_id
      allow(product.purchaser)
        .to receive_message_chain('stripe_customer.charges.retrieve.refunds.create')
        .and_return(double('Stripe::Refund', id: refund_id))

      expect { product.refund }.to change { product.refunded }.to refund_id
    end

    it 'adds an error to :base if there is a Stripe Error' do
      product.update_attribute(:stripe_charge_id, StripeHelper.charge_id)
      error_message = 'The expiration date on your card is not valid'
      allow(product.purchaser)
        .to receive_message_chain('stripe_customer.charges.retrieve.refunds.create')
        .and_raise(Stripe::StripeError.new(error_message))

      expect { product.refund }.to change { product.errors[:base] }.to(['There was a problem refunding the transaction.'])
    end
  end
end
