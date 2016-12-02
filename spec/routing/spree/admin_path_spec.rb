require 'spec_helper'

module Spree
  module Admin
    RSpec.describe 'AdminPath', type: :routing do
      it 'should route to admin by default' do
        expect(spree.admin_path).to eq('/shop/admin')
      end

      it 'should route to the the configured path' do
        Spree.admin_path = '/secret'
        Rails.application.reload_routes!
        expect(spree.admin_path).to eq('/shop/secret')

        # restore the path for other tests
        Spree.admin_path = '/admin'
        Rails.application.reload_routes!
        expect(spree.admin_path).to eq('/shop/admin')
      end
    end
  end
end
