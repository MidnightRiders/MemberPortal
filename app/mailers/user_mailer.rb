class UserMailer < ActionMailer::Base
  default from: 'noreply@midnightriders.com'

  layout 'email'

  Haml::Template.options[:format] = :html4

  def new_user_creation_email(user, temp_pass)
    @user = user
    @title = 'Welcome to the Midnight Riders’ new Members Site'
    @temp_pass = temp_pass
    mail(to: @user.email, subject: @title)
  end
end
