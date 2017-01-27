require 'vcr'

VCR.config do |config|
  config.cassette_library_dir = Rails.root.join('spec', 'vcr')
  config.hook_into :webmock

  config.filter_sensitive_data(ENV['STRIPE_SECRET_KEY'], '{{STRIPE_SECRET_KEY}}')
  config.filter_sensitive_data(ENV['AWS_SECRET_ACCESS_KEY'], '{{AWS_SECRET_ACCESS_KEY}}')
  config.ignore_localhost = true
end

RSpec.configure do |config|
  config.around(:each, :vcr) do |example|
    name = example.metadata[:full_description].split(/\s+/, 2).join('/').underscore.gsub(/[^\w\/]+/, '_')
    VCR.use_cassette(name) { example.call }
  end
end
