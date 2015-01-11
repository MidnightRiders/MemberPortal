# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

stripeParams =
  number:   '#stripe_card_number'
  expMonth: '#stripe_exp_month'
  expYear:  '#stripe_exp_year'
  cvc:      '#stripe_cvc'

subscription =
  setUpForm: ->
    $('#stripe_card_number').closest('form').on 'submit', (e)->
      $(@).find(':submit').prop('disabled', true)
      unless $(@).find('#membership_info_override').prop('checked')
        e.preventDefault()
        card = {}
        card[key] = $(value).val() for key, value of stripeParams
        Stripe.createToken(card, subscription.handleStripeResponse)

  handleStripeResponse: (status, response)->
    if status == 200
      # handle success
      $('#membership_stripe_card_token').val(response.id)
        .closest('form')[0].submit()
    else
      # handle error
      $('#stripe_card_number').closest('form').find(':submit').prop('disabled', false)
      $('.field_with_errors [id^=stripe]').each ->
        $(@).closest('.field_with_errors').removeClass('field_with_errors').find('small.error').remove()
      $(stripeParams[response.error.param]).after('<small class="error">' + response.error.message + '</small>')
        .closest('.row').addClass('field_with_errors')

$ ->
  stripePublicKey = $('meta[name="stripe-public-key"]').attr('content')
#  console.log stripePublicKey
  $('#show-credit-card-info').on 'click', (e)->
    e.preventDefault()
    $('#credit-card-info').removeClass('hide').hide().slideDown(150)
    .find(':disabled').prop('disabled', false)
    $(@).fadeOut 150, ->
      $(@).remove()
      subscription.setUpForm()
  if stripePublicKey and $('#credit-card-info').is(':visible')
    Stripe.setPublishableKey(stripePublicKey)
    subscription.setUpForm()