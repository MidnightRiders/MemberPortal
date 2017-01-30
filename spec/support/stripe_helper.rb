class StripeHelper
  class << self
    Struct.new('StripeCard', :card_number, :exp_date, :cvc)

    def card_token
      'tok_' + chars(23)
    end

    def card_id
      'ca_' + chars
    end

    def charge_id
      'ch_' + chars
    end

    def chars(n = 24)
      FFaker::Lorem.characters(n)
    end

    def customer_token
      'cus_' + chars(23)
    end

    def declined_card
      Struct::StripeCard.new(
        '4000000000000002',
        Date.current + 6.months,
        '424'
      )
    end

    def refund_id
      're_' + chars
    end

    def subscription_id
      'sub_' + chars(23)
    end

    def valid_card
      Struct::StripeCard.new(
        '4242424242424242',
        Date.current + 6.months,
        '424'
      )
    end
  end
end
