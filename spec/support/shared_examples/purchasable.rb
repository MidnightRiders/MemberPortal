shared_examples_for 'Commerce::Purchasable' do
  it 'validates unique stripe charge' do
    product.update_attributes(stripe_charge_id: 'ch_' + FFaker::Lorem.characters(24))
    new_product = product.dup

    expect(new_product).not_to be_valid
    expect(new_product.errors.messages).to include(stripe_charge_id: ['has already been taken'])
  end

  describe 'payment validation' do
    it 'adds an error if there\'s no charge or way to make a charge' do
      expect { product.__send__(:paid_for?) }.to change { product.errors.messages }
    end

    it 'does not add an error if stripe_card_token is present' do
      product.stripe_card_token = 'tok_' + FFaker::Lorem.characters(24)
      expect { product.__send__(:paid_for?) }.not_to change { product.errors.messages }
    end

    it 'does not add an error if purchaser\'s stripe_customer_token is present' do
      product.purchaser.update_attribute(:stripe_customer_token, 'cus_' + FFaker::Lorem.characters(24))
      expect { product.__send__(:paid_for?) }.not_to change { product.errors.messages }
    end
  end

  pending 'charge_information'
  pending 'make_stripe_charge'
  pending 'save_with_payment'
  pending 'refund'
  pending 'stripe_refund'
  pending 'stripe_charge'
end
