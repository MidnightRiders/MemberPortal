class StripeWebhookService
  ACCEPTED_EVENTS = %w(charge.refunded invoice.payment_succeeded).freeze

  # @param [ActiveSupport::HashWithIndifferentAccess] event
  def initialize(event)
    @event = event
    @status = 500
  end

  # @return [Integer]
  def process
    return @status unless filter_event && customer_token && user
    return 200 if ignored?
    public_send(@event[:type].gsub(/[^a-z0-9]+/i, '_'))
    @status
  rescue => e
    Rails.logger.error e.message
    Rails.logger.info e.backtrace&.join("\n")
    @status
  end

  def charge_refunded
    membership = Membership.find_by!(stripe_charge_id: object[:id])
    membership.update!(refunded: 'true')
    @status = 200
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "No membership associated with Stripe Charge #{object[:id]}."
    SlackBot.post_message(":warning: *Warning:* No membership associated with Stripe Charge `#{object[:id]}.`", 'web-notifications')
    @status = 404
  end

  def invoice_payment_succeeded
    renew_subscription
    @status = 200
  rescue ActiveRecord::RecordInvalid => e
    if e.record.errors.messages.keys.include? :year
      Rails.logger.info "Skipping duplicate Membership for #{object[:subscription]}"
      @status = 200
      return
    end
    raise e
  rescue ActiveRecord::RecordNotFound => e
    formatted = e.message.gsub(/\b([a-z]{2,3}_[A-Za-z0-9]{24})\b/, '`\1`')
    SlackBot.post_message(":warning: *Warning:* #{formatted}", 'web-notifications')
    raise e
  end

  private

  def customer_token
    return @customer_token if @customer_token
    customer_token = object[:object] == 'customer' ? object[:id] : object[:customer]
    return @customer_token = customer_token if customer_token.present?
    Rails.logger.error 'No Stripe::Customer attached to event.'
    @status = 200
    false
  end

  def filter_event
    Rails.logger.debug @event[:type]
    return true if ACCEPTED_EVENTS.include? @event[:type]
    Rails.logger.warn "Stripe::Event type #{@event[:type]} not in accepted webhooks. Returning 200."
    @status = 200
    false
  end

  def object
    return @object if @object
    Rails.logger.info @event.dig(:data, :object).to_yaml
    @object = @event.dig(:data, :object)
  end

  def renew_subscription
    new_membership = Membership.re_up!(
      object[:subscription],
      { user_id: user.id },
      year: subscription_year,
      stripe_charge_id: object[:charge]
    )
    MembershipNotifier.new(user: user, membership: new_membership).notify_renewal
  end

  def user
    return @user if @user
    user = User.find_by(stripe_customer_token: customer_token)
    return @user = user if user
    Rails.logger.error "No User could be found with Stripe ID #{customer_token}\n  Event ID: #{@event[:id]}"
    @status = 404
    false
  end

  def subscription_year
    Time.zone.at(object[:lines][:data][0][:period][:start].to_i).year
  end

  def ignored?
    ENV['IGNORED_STRIPE_EVENT_IDS'].to_s.split(/\s*,\s*/).include? @event[:id]
  end
end
