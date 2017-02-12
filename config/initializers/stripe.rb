Stripe.api_key = Rails.env.test? ? 'sk_test_fake4oCLBfAnf9nXr0bOjHFL' : ENV['STRIPE_SECRET_KEY']

ENV['STRIPE_PUBLIC_KEY'] = if Rails.env.production?
  'pk_live_fPWFbD0LtW0JhOuGmtsWQz7l'
else
  'pk_test_4oCLBfAnf9nXr0bOjHFLbWI8'
end
