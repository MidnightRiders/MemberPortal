require 'vcr'

VCR.configure do |config|
  config.default_cassette_options = { record: :new_episodes }
  config.cassette_library_dir = Rails.root.join('spec', 'vcr')
  config.hook_into :webmock
  config.configure_rspec_metadata!

  config.filter_sensitive_data('<STRIPE_SECRET_KEY>') { ENV['STRIPE_SECRET_KEY'] }
  config.filter_sensitive_data('<AWS_SECRET_ACCESS_KEY>') { ENV['AWS_SECRET_ACCESS_KEY'] }
  config.filter_sensitive_data('<API_FOOTBALL_KEY>') { ENV['API_FOOTBALL_KEY'] }
  config.ignore_localhost = true

  # config.ignore_hosts *%w(
  #   fonts.googleapis.com
  #   fonts.gstatic.com
  #   gravatar.com
  #   js.stripe.com
  # )
end

# RSpec.configure do |config|
#   config.around(:each, :vcr) do |example|
#     spec_vcr_path = example.metadata[:file_path].sub(/.*\/?spec\/(.+)(?:_spec)?\.rb/, '\1')
#     name = File.join(spec_vcr_path, example.metadata[:description].underscore.gsub(/[^\w\/]+/, '_'))
#     puts name
#     VCR.use_cassette(name) { example.call }
#   end
# end
