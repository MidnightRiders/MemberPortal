# frozen_string_literal: true
require 'rails_helper'
require 'support/shared_examples/authenticated_api'

RSpec.describe Api::ClubsController, type: :controller do
  describe 'non-admin current_user' do
    it_behaves_like 'authenticated API', ->{ FactoryBot.create(:user) }, ->{ FactoryBot.create(:club) }, only: %i[index show]
  end
end
