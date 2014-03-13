require 'spec_helper'

describe StylesheetsController do
  describe 'GET "clubs"' do
    it 'returns CSS' do
      get 'club', format: 'css'
      response.headers.should include('Content-Type' => 'text/css; charset=utf-8')
    end
  end
end
