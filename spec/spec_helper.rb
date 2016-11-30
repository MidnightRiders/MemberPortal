# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'ffaker'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'cancan/matchers'
require 'paper_trail/frameworks/rspec'

require 'capybara-screenshot/rspec'
Capybara.save_path = Rails.root.join('tmp')

Capybara.javascript_driver = :poltergeist
Capybara.asset_host = MidnightRiders::Application.config.action_mailer.asset_host

Capybara.default_max_wait_time = 10

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f unless f.include?('user_factory') }

Capybara.register_server :thin do |app, port|
  require 'rack/handler/thin'
  Rack::Handler::Thin.run(app, Port: port)
end

require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/factories'
require 'spree/testing_support/preferences'
require 'spree/testing_support/controller_requests'
require 'spree/testing_support/flash'
require 'spree/testing_support/shoulda_matcher_configuration'
require 'spree/testing_support/url_helpers'
require 'spree/testing_support/order_walkthrough'
require 'spree/testing_support/capybara_ext'
require 'spree/testing_support/microdata'
require 'spree/api/testing_support/caching'
require 'spree/api/testing_support/helpers'
require 'spree/api/testing_support/setup'

require 'spree/core/controller_helpers/strong_parameters'

require 'paperclip/matchers'

require 'support/user_factory'

# Checks for skip migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|

  config.extend WithModel

  config.include FactoryGirl::Syntax::Methods
  config.include Spree::TestingSupport::Preferences
  config.include Spree::TestingSupport::UrlHelpers
  config.include Spree::TestingSupport::ControllerRequests, type: :controller
  config.include Spree::TestingSupport::Flash
  config.include Spree::Api::TestingSupport::Helpers, type: :controller
  config.extend Spree::Api::TestingSupport::Setup, type: :controller

  config.include Spree::Core::ControllerHelpers::StrongParameters, type: :controller

  config.include Devise::TestHelpers, type: :controller
  config.include Devise::TestHelpers, type: :view
  config.extend ControllerMacros, type: :controller
  config.include Warden::Test::Helpers
  config.include Capybara::DSL

  config.include Rails.application.routes.url_helpers

  config.backtrace_exclusion_patterns = [/gems\/activesupport/, /gems\/actionpack/, /gems\/rspec/]
  config.color = true
  config.fail_fast = ENV['FAIL_FAST'] || false
  config.infer_spec_type_from_file_location!
  config.mock_with :rspec

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.infer_base_class_for_anonymous_controllers = true

  config.order = 'random'

  config.before do
    Spree::Api::Config[:requires_authentication] = true
  end
end

module Spree
  module TestingSupport
    module Flash
      def assert_flash_success(flash)
        flash = convert_flash(flash)

        within('.alert-success') do
          expect(page).to have_content(flash)
        end
      end
    end
  end
end
