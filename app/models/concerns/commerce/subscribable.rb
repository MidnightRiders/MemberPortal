module Commerce
  module Subscribable
    extend ActiveSupport::Concern

    included do
      validates :stripe_subscription_id, uniqueness: { scope: :year }, allow_nil: true
    end

    # Cancel current subscription
    def cancel(provide_refund = false)
      return false unless subscription?
      purchaser.stripe_customer.subscriptions.retrieve(stripe_subscription_id).delete
      update_attribute(:stripe_subscription_id, 'Stripe Subscription Canceled')
      refund if provide_refund
    rescue Stripe::StripeError => e
      logger.error "Stripe error while canceling subscription: #{e.message}"
      errors.add :base, 'There was a problem while canceling your subscription: ' + e.message
      false
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

    class_methods do
      def for_subscription(subscription_id, query = {})
        query[:stripe_subscription_id] = subscription_id
        where(query).order(created_at: :asc).last || raise(ActiveRecord::RecordNotFound,
          "Could not find record to renew for Stripe::Subscription ID #{subscription_id}")
      end

      def re_up!(subscription, query_attributes = {}, update_attributes = {})
        last_order = for_subscription(subscription, query_attributes)
        new_order = last_order.dup
        new_order.id = nil
        new_order.assign_attributes(update_attributes) if update_attributes.present?
        new_order.save!
        new_order
      end
    end
  end
end
