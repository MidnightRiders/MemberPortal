require 'spec_helper'

describe StylesheetsController do
  describe 'GET "clubs"' do
    it 'returns CSS' do
      get 'club', format: 'css'
      expect(response.headers).to include('Content-Type' => 'text/css; charset=utf-8')
    end
  end
end
