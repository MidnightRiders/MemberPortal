module Commerce
  module Purchasable
    extend ActiveSupport::Concern

    included do
      attr_accessor :stripe_card_token
      validates :stripe_charge_id, uniqueness: true, allow_nil: true
      validate :paid_for?
    end

    def charge_information(card_id = nil)
      {
        amount: self.class.price,
        customer: purchaser.stripe_customer.id,
        receipt_email: purchaser.email,
        description: stripe_description,
        metadata: stripe_metadata,
        currency: 'usd',
        statement_descriptor: stripe_statement_descriptor,
        source: card_id || purchaser.stripe_customer.default_source
      }
    end

    def make_stripe_charge(card_id = nil)
      self.stripe_charge_id = Stripe::Charge.create(charge_information(card_id)).id
    rescue Stripe::StripeError => e
      logger.error "Stripe error while saving #{self.class.name.humanize} with payment: #{e.message}"
      errors.add :base, "There was a problem with your credit card: #{e.message}"
    end

    # Purchaser must be defined in model
    def purchaser
      raise "No purchaser defined for #{self.class.name}"
    end

    # Save with Stripe payment if applicable
    def save_with_payment(card_id = nil)
      return unless ready_to_pay?

      purchaser.create_or_update_stripe_customer(stripe_card_token)

      purchaser.subscribe_to(self) if self.class.include?(::Subscribable) && subscribe?
      make_stripe_charge(card_id)

      save
    end

    def stripe_description
      ''
    end

    def stripe_statement_descriptor
      ''
    end

    def stripe_metadata
      {}
    end

    # Refund payment if possible
    def refund
      stripe_refund if purchaser.stripe_customer.present?
      self.refunded ||= 'true'
      save
    rescue Stripe::StripeError => e
      logger.error "Stripe error while refunding customer: #{e.message}"
      errors.add :base, 'There was a problem refunding the transaction.'
      false
    end

    def stripe_refund
      return unless stripe_charge_id.present?
      self.refunded = stripe_charge&.refunds&.create.id
    rescue => e
      logger.error "Stripe Refund error: #{e.message}"
      logger.info e.backtrace.to_yaml
    end

    def stripe_charge
      purchaser.stripe_customer.charges.retrieve(stripe_charge_id)
    end

    private

    def ready_to_pay?
      valid?
    end

    def paid_for?
      errors.add(:base, 'must be paid for') unless stripe_charge_id || # Charge gone through
        stripe_card_token || # To keep model valid before charge
        purchaser.stripe_customer_token # To keep model valid before charge
    end
  end
end
