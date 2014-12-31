# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

subscription =
  setUpForm: ->
    $('form[id*=membership]').on 'submit', (e)->
      $(@).find(':submit').prop('disabled', true)
      unless $(@).find('#membership_info_override')[0].checked
        e.preventDefault()
        card =
          number:   $('#stripe_card_number').val()
          expMonth: $('#stripe_exp_month').val()
          expYear:  $('#stripe_exp_year').val()
          cvc:      $('#stripe_cvc').val()
        Stripe.createToken(card, subscription.handleStripeResponse)

  handleStripeRespone: (status, response)->
    if status == 200
      # handle success
    else
      # handle error
      $('form[id*=membership]').find(':submit').prop('disabled', false)

$ ->
  stripePublicKey = $('meta[name="stripe-public-key"]').attr('content')
  console.log stripePublicKey
  if stripePublicKey
    Stripe.setPublishableKey(stripePublicKey)
    subscription.setUpForm()