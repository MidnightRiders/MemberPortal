class Api::PurchasesController < ApiController
  def create_payment_intent
    payment_intent = Stripe::PaymentIntent.create(
      amount: price,
      currency: 'usd',
      automatic_payment_methods: {
        enabled: true,
      },
    )

    render json: {
      client_secret: payment_intent.client_secret,
      jwt: current_user.jwt,
    }, status: :ok
  end

  private

  def price
    params.require(:item).then do |item|
      case item
      when 'individual'
        Membership::COSTS[:Individual]
      when 'family'
        Membership::COSTS[:Family]
      else
        raise UnknownItemError, item
      end
    end
  end
end

class UnknownItemError < ApiError
  def initialize(item)
    super(:bad_request, "Unknown item #{item}")
  end
end
