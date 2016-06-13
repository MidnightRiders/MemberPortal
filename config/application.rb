require File.expand_path('../boot', __FILE__)

require 'csv'
require 'iconv'
# Pick the frameworks you want:
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module MidnightRiders
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Eastern Time (US & Canada)'
    #config.active_record.default_timezone = 'Eastern Time (US & Canada)'

    config.week_start = :monday

    config.i18n.enforce_available_locales = true

    config.paperclip_defaults = {
      storage: :s3,
      s3_protocol: :https,
      s3_credentials: {
        bucket: Rails.application.secrets.s3_bucket_name,
        access_key_id: ENV['AWS_ACCESS_KEY_ID'] || Rails.application.secrets.aws_access_key_id,
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] || Rails.application.secrets.aws_secret_access_key
      }
    }

    Rails.application.assets.register_mime_type 'text/html', '.html'
    Rails.application.assets.register_engine '.haml', Tilt::HamlTemplate

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end
