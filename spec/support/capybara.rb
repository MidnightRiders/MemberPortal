require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist

Capybara.asset_host = MidnightRiders::Application.config.action_mailer.asset_host