require 'rails_helper'

describe Commerce::Purchasable do
  let(:purchasable) {
    class ExamplePurchasableClass
      include ActiveModel::Validations
      include Commerce::Purchasable
    rescue ArgumentError # Silence unknown validator: uniqueness
      nil
    end

    ExamplePurchasableClass.new
  }

  describe 'defaulted methods' do
    it 'returns a blank string for stripe_description' do
      expect(purchasable.stripe_description).to eq('')
    end

    it 'returns a blank string for stripe_statement_descriptor' do
      expect(purchasable.stripe_statement_descriptor).to eq('')
    end

    it 'returns an empty Hash for stripe_metadata' do
      expect(purchasable.stripe_metadata).to eq({})
    end

    it 'raises if no purchaser defined' do
      expect { purchasable.purchaser }.to raise_error('No purchaser defined for ExamplePurchasableClass')
    end
  end

end
