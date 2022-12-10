# frozen_string_literals: true

Stripe.api_key = ENV['STRIPE_SECRET_KEY']
Stripe.api_version = '2022-11-15'
