require 'spec_helper'

describe Commerce::Purchaser do
  let(:purchaser) {
    class ExamplePurchaserClass
      include ActiveModel::Validations
      include Commerce::Purchaser
    end

    ExamplePurchaserClass.new
  }

  describe 'defaulted methods' do
    it 'returns a blank string for stripe_customer_info' do
      expect(purchaser.stripe_customer_info).to eq({})
    end

    it 'returns a blank string for stripe_metadata' do
      expect(purchaser.stripe_metadata).to eq({})
    end
  end
end
