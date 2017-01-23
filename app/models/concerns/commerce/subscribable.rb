module Commerce
  module Subscribable
    extend ActiveSupport::Concern

    included do
      validates :stripe_charge_id, uniqueness: true, allow_nil: true
    end

    # Cancel current subscription
    def cancel(provide_refund = false)
      self.refunded = 'canceled' unless delete_stripe_subscription
      save!
      refund if provide_refund
    rescue Stripe::StripeError => e
      logger.error "Stripe error while canceling customer: #{e.message}"
      errors.add :base, 'There was a problem with your credit card: ' + e.message
      false
    end

    def delete_stripe_subscription
      return false unless subscription?
      purchaser.stripe_customer.subscriptions.retrieve(stripe_subscription_id).delete
      self.stripe_subscription_id = nil
    end

    # Purchaser must be defined in model
    def purchaser
      raise "No purchaser defined for #{self.class.name}"
    end

    def subscribe
      @subscribe ||= false
    end
    alias subscribe? subscribe

    def subscribe=(value)
      @subscribe = value.to_i == 1
    end

    def subscription?
      stripe_subscription_id.present?
    end
  end
end
