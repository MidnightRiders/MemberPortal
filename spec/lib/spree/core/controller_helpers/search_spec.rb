require 'spec_helper'

class SearchFakesController < ApplicationController
  include Spree::Core::ControllerHelpers::Search
end

describe Spree::Core::ControllerHelpers::Search, type: :controller do
  controller(SearchFakesController) {}

  describe '#build_searcher' do
    it 'returns Spree::Core::Search::Base instance' do
      allow(controller).to receive_messages(try_spree_current_user: create(:user),
                      current_currency: 'USD')
      expect(controller.build_searcher({}).class).to eq Spree::Core::Search::Base
    end
  end
end
