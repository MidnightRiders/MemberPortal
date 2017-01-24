class StripeHelper
  class << self
    def card_token
      'tok_' + chars(23)
    end

    def card_id
      'ca_' + chars
    end

    def charge_id
      'ch_' + chars
    end

    def customer_token
      'cus_' + chars(23)
    end

    def refund_id
      're_' + chars
    end

    def chars(n = 24)
      FFaker::Lorem.characters(n)
    end
  end
end
