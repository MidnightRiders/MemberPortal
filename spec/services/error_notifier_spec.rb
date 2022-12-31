require 'rails_helper'

describe ErrorNotifier do
  describe 'notify' do
    let(:error) { StandardError.new('This is an error') }
    it 'outputs the error type and message to logger.error by default' do
      expect(Rails.logger).to receive(:error).with('StandardError: This is an error')
      ErrorNotifier.notify(error)
    end

    it 'outputs the error to logger.warn if directed to' do
      expect(Rails.logger).to receive(:warn).with('StandardError: This is an error')
      ErrorNotifier.notify(error, severity: :warn)
    end

    it 'outputs the backtrace to logger.info' do
      allow(Rails.logger).to receive(:info) do |output|
        expect { YAML.load(output) }.not_to raise_error
        expect(YAML.load(output)).not_to be(false)
      end

      ErrorNotifier.notify(error)
    end
  end
end
