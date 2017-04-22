require 'simplecov'
SimpleCov.start do
  add_filter '/vendor/'
  add_filter '/public/'
  add_filter '/spec/vcr/'
end

# save to CircleCI's artifacts directory if we're on CircleCI
if ENV['CIRCLE_ARTIFACTS']
  dir = File.join(ENV['CIRCLE_ARTIFACTS'], 'coverage')
  SimpleCov.coverage_dir(dir)
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rails_helper'
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'ffaker'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'cancan/matchers'
require 'paper_trail/frameworks/rspec'
require 'webmock/rspec'
require 'capybara-screenshot/rspec'
require 'support/controller_macros'
require 'support/database_cleaner'
require 'support/external_request_classes'
require 'support/request_spec_helper'
require 'support/vcr'
Capybara.save_path = ENV['CIRCLE_ARTIFACTS'] if ENV['CIRCLE_ARTIFACTS']

WebMock.disable_net_connect!(allow_localhost: true)

Capybara.javascript_driver = :poltergeist
Capybara.asset_host = MidnightRiders::Application.config.action_mailer.asset_host

Capybara.register_server :thin do |app, port|
  require 'rack/handler/thin'
  Rack::Handler::Thin.run(app, Port: port)
end

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.

# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|

  config.include Devise::TestHelpers, type: :controller
  config.include Devise::TestHelpers, type: :view
  config.extend ControllerMacros, type: :controller
  config.include RequestSpecHelper, type: :request
  config.include Warden::Test::Helpers
  config.include Capybara::DSL

  config.include Rails.application.routes.url_helpers

  config.infer_spec_type_from_file_location!

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # TODO: Investigate moving this to +true+
  config.use_transactional_fixtures = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end
