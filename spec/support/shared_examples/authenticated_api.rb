# frozen_string_literal: true

ENDPOINT_DATA = {
  index: { method: :get },
  show: { method: :get, params: ->(obj, opts) { { "#{opts[:id]}": obj.public_send(opts[:id]) } } },
  create: { method: :post },
  update: { method: :put },
  destroy: { method: :delete, params: ->(obj, opts) { { "#{opts[:id]}": obj.public_send(opts[:id]) } } },
}.freeze

DEFAULT_ENDPOINTS = ENDPOINT_DATA.keys.freeze

RSpec.shared_examples_for 'authenticated API' do |user_proc, subject_proc, options = {}|
  opts = {
    additional: {},
    id: 'id',
    except: [],
    options: [],
  }.merge(options)

  endpoints = if opts[:only].any?
    DEFAULT_ENDPOINTS.select { _1.in?(opts[:only]) }
  elsif opts[:except].any?
    DEFAULT_ENDPOINTS.reject { _1.in?(opts[:except]) }
  else
    DEFAULT_ENDPOINTS
  end

  test_groups = ENDPOINT_DATA.select { |k| k.in?(endpoints) }.merge(opts[:additional])

  let(:user) { user_proc.call }
  let(:subject) { subject_proc.call }

  test_groups.each do |endpoint, cfg|
    describe "##{endpoint}" do
      render_views

      it 'is not allowed without authentication' do
        send(cfg[:method], endpoint, params: cfg[:params]&.call(subject, opts) || {}, format: :json)

        expect(response).to have_http_status(:unauthorized)
        expect(response.media_type).to eq 'application/json'
      end

      it 'is not allowed with invalid authentication' do
        request.headers['Authorization'] = 'Bearer invalid'
        send(cfg[:method], endpoint, params: cfg[:params]&.call(subject, opts) || {}, format: :json)

        expect(response).to have_http_status(:unauthorized)
        expect(response.media_type).to eq 'application/json'
      end

      it 'is allowed with valid authentication' do
        request.headers['Authorization'] = "Bearer #{user.jwt}"
        send(cfg[:method], endpoint, params: cfg[:params]&.call(subject, opts) || {}, format: :json)

        expect(response).to have_http_status(:success)
        expect(response.media_type).to eq 'application/json'
      end

      it 'returns a new JSON Web Token' do
        jwt = user.jwt
        request.headers['Authorization'] = "Bearer #{jwt}"
        send(cfg[:method], endpoint, params: cfg[:params]&.call(subject, opts) || {}, format: :json)

        body = JSON.parse(response.body, symbolize_names: true)
        expect(body).to have_key(:jwt)
      end
    end
  end
end
