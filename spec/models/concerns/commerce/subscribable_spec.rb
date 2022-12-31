require 'rails_helper'

describe Commerce::Subscribable do
  let(:subscribable) {
    class ExampleSubscribableClass
      include ActiveModel::Validations
      include Commerce::Subscribable
    rescue ArgumentError
      nil
    end

    ExampleSubscribableClass.new
  }

  describe 'defaulted methods' do
    it 'raises if no purchaser defined' do
      expect { subscribable.purchaser }.to raise_error('No purchaser defined for ExampleSubscribableClass')
    end
  end
end
