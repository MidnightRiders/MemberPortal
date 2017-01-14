if Rails.env.production?
  ActionMailer::Base.smtp_settings = {
    address:              'smtp.gmail.com',
    port:                 587,
    user_name:            ENV['gmail_user_name'],
    password:             ENV['gmail_password'],
    authentication:       'plain',
    enable_starttls_auto: :true
  }
end
