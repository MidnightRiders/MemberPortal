RSpec.shared_examples_for 'Ignored Webhooks' do |event_code|
  let(:event) { JSON.parse(File.read(Rails.root.join('spec/fixtures/webhooks', "#{event_code}.json"))) }

  it 'returns 200 with logger warning that it was ignored' do
    allow(Rails.logger).to receive(:info)
    expect(Rails.logger).to receive(:warn).with(a_string_including('not in accepted webhooks'))

    post :webhooks, event

    expect(response).to have_http_status(:success)
  end
end

RSpec.shared_examples_for 'Non-Customer Webhooks' do |event_code|
  let(:event) { JSON.parse(File.read(Rails.root.join('spec/fixtures/webhooks', "#{event_code}.json"))) }

  it 'returns 200 with logger error for no Stripe::Customer' do
    expect(Rails.logger).to receive(:error).with('No Stripe::Customer attached to event.')

    post :webhooks, event

    expect(response).to have_http_status(:success)
  end
end
