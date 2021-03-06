class MembershipNotifier
  def initialize(user:, membership:)
    @user = user
    @membership = membership
  end

  def notify_new
    MembershipMailer.new_membership_confirmation_email(@user, @membership).deliver_now
    MembershipMailer.new_membership_alert(@user, @membership).deliver_now
    slack_notify
  end

  def notify_renewal
    Rails.logger.info "#{@membership.year} Membership created for #{@user.first_name} #{@user.last_name}"
    MembershipMailer.membership_subscription_confirmation_email(@user, @membership).deliver_now
    slack_notify
  end

  def notify_relative
    slack_notify
  end

  private

  def slack_notify
    SlackBot.post_message("New #{@membership.type} Membership!\n" \
      "*#{@membership.year} Total: #{Membership.for_year(@membership.year).count}* | "\
      "#{Membership.breakdown(@membership.year)}", '#general')
    @membership.notify_slack
  end
end
