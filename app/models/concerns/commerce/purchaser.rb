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
        update_payment_method(stripe_card_token).id if stripe_card_token
        update_stripe_customer
      else
        create_stripe_customer(stripe_card_token: stripe_card_token)
      end
    end

    # @return [Stripe::Customer, nil] Stripe customer associated with User
    def stripe_customer
      return unless stripe_customer_token
      @customer ||= Stripe::Customer.retrieve(stripe_customer_token)
    rescue Stripe::InvalidRequestError => e
      logger.error "Stripe::InvalidRequestError: #{e}"
      nil
    end

    def subscribe_to(product, card_id = stripe_customer.default_source)
      subscription = stripe_customer.subscriptions.create(
        plan: product.plan,
        trial_end: product.trial_end,
        source: card_id
      )
      product.stripe_subscription_id = subscription.id
    end

    # @param [String] stripe_card_token
    # @return [Stripe::Card]
    def update_payment_method(stripe_card_token)
      card = stripe_customer.sources.create(source: stripe_card_token)
      stripe_customer.default_source = card.id
      stripe_customer.save
      stripe_customer.sources.data.select { |c| c != card }.each(&:delete)
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

    def stripe_customer_info
      {}
    end

    def stripe_metadata
      {}
    end
  end
end
