# Mailer for user stuff not covered by Devise mailer.
class MembershipMailer < ActionMailer::Base
  include ActionView::Helpers::UrlHelper
  include ActionView::Base::TagHelper

  default from: 'noreply@midnightriders.com'

  layout 'email'

  Haml::Template.options[:format] = :html4

  # Receipt for one-time membership purchase
  def new_membership_confirmation_email(user, membership)
    @user = user
    @membership = membership
    @title = "Congratulations on your #{@membership.year} #{@membership.type} Membership!"
    mail(to: @user.email, subject: @title)
  end

  # Receipt for one-time membership purchase
  def membership_subscription_confirmation_email(user, membership)
    @user = user
    @membership = membership
    @title = "Congratulations on your #{@membership.year} #{@membership.type} Membership!"
    mail(to: @user.email, subject: @title)
  end

  # Receipt for membership charge refund
  def membership_refund_email(user, membership)
    @user = user
    @membership = membership
    @title = "Your #{@membership.year} #{@membership.type} Membership has been refunded"
    mail(to: @user.email, subject: @title)
  end

  # Alert leadership to new memberships
  def new_membership_alert(user, membership)
    @user = user
    @membership = membership
    @title = "[MemberPortalAlert] New #{@membership.year} #{@membership.type} Membership for #{@user.first_name} #{@user.last_name}"
    mail(to: 'Membership Chair<membership@midnightriders.com>,President<president@midnightriders.com>,Member Portal Support<member-portal-support@midnightriders.com>', subject: @title)
  end

  # Alert leadership to refunds
  def membership_cancellation_alert(user, membership)
    @user = user
    @membership = membership
    @title = "[MemberPortalAlert] #{@membership.year} #{@membership.type} Membership Refunded for #{@user.first_name} #{@user.last_name}"
    mail(to: 'Membership Chair<membership@midnightriders.com>,President<president@midnightriders.com>,Member Portal Support<member-portal-support@midnightriders.com>', subject: @title)
  end

  # Invite existing user to join Family membership
  def invite_existing_user_to_family(user, family, relative)
    @user = user
    @family = family
    @relative = relative
    @title = "#{@user.first_name}, #{@family.user.first_name} has invited you to join a #{@family.year} Family Membership"
    mail(to: @user.email, subject: @title)
  end

  # Invite email to complete account and join Family membership
  def invite_new_user_to_family(user, family, relative)
    @user = user
    @family = family
    @relative = relative
    @title = "#{@family.user.first_name} has invited you to join a #{@family.year} Midnight Riders Family Membership"
    mail(to: @user.email, subject: @title)
  end

  private

  def styled_link_to(name = nil, options = nil, html_options = nil, &block)
    html_options, options, name = options, name, block if block_given?
    options ||= {}

    html_options = convert_options_to_data_attributes(options, html_options)

    url = url_for(options)
    html_options['href'] ||= url

    html_options['style'] ||= ''
    html_options['style'] = 'color:#881144;text-decoration:none;border-bottom:1px dashed #881144;margin-bottom:-1px;'

    content_tag(:a, name || url, html_options, &block)
  end
  helper_method :styled_link_to
end
