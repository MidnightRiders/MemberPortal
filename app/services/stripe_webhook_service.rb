class StripeWebhookService
  ACCEPTED_EVENTS = %w(charge.refunded invoice.payment_succeeded).freeze

  def initialize(event)
    @event = event.with_indifferent_access
    @response = { nothing: true, status: 500 }
  end

  def process
    return @response unless filter_event && customer_token && user
    return { nothing: true, status: 200 } if ignored?
    public_send(@event[:type].gsub(/[^a-z0-9]+/i, '_'))
    @response
  rescue => e
    ErrorNotifier.notify(e)
    @response
  end

  def charge_refunded
    membership = Membership.find_by(stripe_charge_id: object[:id])
    @response[:status] = 200
    raise StripeWebhooks::MissingRecord, "No membership associated with Stripe Charge #{object[:id]}." if membership.nil?
    membership.update!(refunded: 'true')
  end

  def invoice_payment_succeeded
    renew_subscription
    @response[:status] = 200
  rescue ActiveRecord::RecordInvalid => e
    if e.record.errors.messages.keys.include? :year
      Rails.logger.info "Skipping duplicate Membership for #{object[:subscription]}"
      return @response[:status] = 200
    end
    raise e
  end

  private

  def customer_token
    return @customer_token if @customer_token
    customer_token = object[:object] == 'customer' ? object[:id] : object[:customer]
    return @customer_token = customer_token if customer_token.present?
    @response[:status] = 200
    raise StripeWebhooks::Ignored, 'No Stripe::Customer attached to event.'
  end

  def filter_event
    Rails.logger.debug @event[:type]
    return true if ACCEPTED_EVENTS.include? @event[:type]
    Rails.logger.warn "Stripe::Event type #{@event[:type]} not in accepted webhooks. Returning 200."
    @response[:status] = 200
    false
  end

  def object
    return @object if @object
    Rails.logger.info @event.dig(:data, :object).to_yaml
    @object = @event.dig(:data, :object)
  end

  def renew_subscription
    new_membership = Membership.re_up!(object[:subscription], { user_id: user.id }, year: subscription_year)
    MembershipNotifier.new(user: user, membership: new_membership).notify_renewal
  end

  def user
    return @user if @user
    user = User.find_by(stripe_customer_token: customer_token)
    return @user = user if user
    @response[:status] = 404
    raise StripeWebhooks::MissingRecord, "No User could be found with Stripe ID #{customer_token}\n  Event ID: #{@event[:id]}"
  end

  def subscription_year
    Time.zone.at(object[:lines][:data][0][:period][:start].to_i).year
  end

  def ignored?
    ENV['IGNORED_STRIPE_EVENT_IDS'].to_s.split(/\s*,\s*/).include? @event[:id]
  end
end
