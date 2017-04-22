require 'rails_helper'

RSpec.describe StylesheetsController do
  describe 'GET "clubs"' do
    it 'returns CSS' do
      get 'club', format: 'css'
      expect(response.headers['Content-Type']).to eq('text/css; charset=utf-8')
    end
  end
end
