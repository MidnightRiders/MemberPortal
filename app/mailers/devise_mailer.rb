# Mailer for Devise user stuff.
class DeviseMailer < Devise::Mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default from: 'noreply@midnightriders.com'
  layout 'email'
  Haml::Template.options[:format] = :html4
end