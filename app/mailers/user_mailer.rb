# Mailer for user stuff not covered by Devise mailer.
class UserMailer < ActionMailer::Base
  default from: 'noreply@midnightriders.com'

  layout 'email'

  Haml::Template.options[:format] = :html4

  # Email generated by user import script to notify a new user
  # that their account has been created and give them instructions.
  def new_user_creation_email(user, temp_pass)
    @user = user
    @title = 'Welcome to the Midnight Riders’ Members Portal'
    @temp_pass = temp_pass
    mail(to: @user.email, subject: @title)
  end

  def new_board_nomination_email(user, nomination = {})
    @user = user

    @nominee = nomination[:name]
    @position = nomination[:position]
    raise ArgumentError, 'Need all information for nominee.' unless @nominee.present? && @position.present?

    @title = "#{@user.first_name} #{@user.last_name} has nominated #{@nominee} to the #{Date.current.year} Board"
    mail(to: 'secretary@midnightriders.com, info@midnightriders.com, member-portal-support@midnightriders.com', subject: @title)
  end
end
