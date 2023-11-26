module Commerce
  module Purchaser
    extend ActiveSupport::Concern

    # Create Stripe customer
    def create_stripe_customer(stripe_card_token: nil)
      @customer = Stripe::Customer.create(stripe_customer_info.merge(card: stripe_card_token))
      update_attribute(:stripe_customer_token, @customer.id)
    end

    def create_or_update_stripe_customer(stripe_card_token = nil)
      if stripe_customer.present?
        update_payment_method(stripe_card_token) if stripe_card_token
        update_stripe_customer
      else
        create_stripe_customer(stripe_card_token: stripe_card_token)
      end
    end

    def refund(purchase)
      return unless purchase.stripe_charge_id.present?
      Stripe::Refund.create({ charge: purchase.stripe_charge_id })
    end

    # @return [Stripe::Customer, nil] Stripe customer associated with User
    def stripe_customer
      return unless stripe_customer_token
      @customer ||= Stripe::Customer.retrieve(stripe_customer_token)
    rescue Stripe::InvalidRequestError => e
      logger.error "Stripe::InvalidRequestError: #{e}"
      nil
    end

    def stripe_customer_info
      {}
    end

    def stripe_metadata
      {}
    end

    def subscribe_to(product)
      subscription = Stripe::Subscription.create(
        customer: stripe_customer,
        plan: product.stripe_price,
        trial_end: product.trial_end
      )
      product.stripe_subscription_id = subscription.id
    end

    # @param [String] stripe_card_token
    # @return [Stripe::Card]
    def update_payment_method(stripe_card_token)
      card = Stripe::Customer.create_source(stripe_customer_token, { source: stripe_card_token })
      Stripe::Customer.update(stripe_customer_token, { default_source: card.id })
      Stripe::Customer.list_sources(stripe_customer_token, { object: 'card' }).each do |c|
        Stripe::Customer.delete_source(stripe_customer_token, c.id) unless c.id == card.id
      end
      card
    end

    # Syncs local data to data in Stripe.
    # @return [Stripe::Customer]
    def update_stripe_customer
      stripe_customer_info.except(:metadata).each do |key, value|
        stripe_customer.public_send("#{key}=", value)
      end

      stripe_customer.metadata = stripe_customer.metadata.to_h.merge(stripe_customer_info[:metadata])

      stripe_customer.save
    end
  end
end
