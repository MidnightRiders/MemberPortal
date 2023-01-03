# frozen_string_literal: true
require 'rails_helper'
require 'support/shared_examples/authenticated_api'

RSpec.describe Api::UsersController, type: :controller do
  describe 'non-admin current_user' do
    it_behaves_like 'authenticated API', ->{ FactoryBot.create(:user) }, ->{ User.last }, only: %i[show], additional: {
      current: { method: :get }
    }
  end

  describe 'admin current_user' do
    it_behaves_like 'authenticated API', ->{ FactoryBot.create(:user, :admin) }, ->{ FactoryBot.create(:user) }, only: %i[index show], additional: {
      current: { method: :get }
    }
  end
end
