Stripe.api_key = ENV['STRIPE_SECRET_KEY']
Stripe.api_key ||= 'sk_test_fake4oCLBfAnf9nXr0bOjHFL' if Rails.env.test?

ENV['STRIPE_PUBLIC_KEY'] = if Rails.env.production?
  'pk_live_fPWFbD0LtW0JhOuGmtsWQz7l'
else
  'pk_test_4oCLBfAnf9nXr0bOjHFLbWI8'
end
