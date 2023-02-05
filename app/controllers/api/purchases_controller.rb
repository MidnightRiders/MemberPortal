class Api::PurchasesController < ApiController
  PRODUCTS = {
    memberships: {
      individual: {
        name: 'Individual',
        price: Membership::COSTS[:Individual],
        description: -> { "#{Membership.new_membership_year} Individual membership" },
        stripe_price: :individual,
      },
      family: {
        name: 'Family',
        price: Membership::COSTS[:Family],
        description: -> { "#{Membership.new_membership_year} Family membership" },
        stripe_price: :family,
      },
    },
  }.with_indifferent_access.freeze

  def products
    products = if params[:type].present?
      PRODUCTS[params[:type]]
    else
      PRODUCTS
    end.deep_transform_values do |v|
      v.is_a?(Proc) ? v.call : v
    end
    render json: { products: products || [] }.deep_transform_keys { _1.to_s.camelize(:lower) }, status: products.nil? ? :not_found : :ok
  end

  def create_payment_intent
    if current_user.nil?
      render json: {
        error: 'Unauthorized',
        jwt: nil,
      }, status: :unauthorized
      return
    end
    
    authorize! :create, Membership.new(user: current_user)

    payment_intent = Stripe::PaymentIntent.create(
      amount: (price * 100).to_i,
      currency: 'usd',
      automatic_payment_methods: {
        enabled: true,
      },
      customer: current_user.stripe_customer_token,
      setup_future_usage: 'off_session',
    )

    render json: {
      token: payment_intent.client_secret,
      jwt: current_user.jwt,
    }, status: :ok
  end

  private

  def price
    type = params.require(:type)
    item = params.require(:item)
    if PRODUCTS.dig(type, item).nil?
      raise UnknownItemError.new(type, item)
    end
    return PRODUCTS[type][item][:price]
  end
end

class UnknownItemError < ApiError
  def initialize(type, item)
    super(:bad_request, "Unknown item #{type}/#{item}")
  end
end
