(function ($) {
  var stripeParams = {
    number: '#stripe_card_number',
    exp_month: '#stripe_exp_month',
    exp_year: '#stripe_exp_year',
    cvc: '#stripe_cvc'
  };

  var subscription = {
    stripe: undefined,
    stripeInit: function(publicKey) {
      this.stripe = Stripe(publicKey);
      subscription.setUpForm();
    },
    setUpForm: function () {
      return $('#stripe_card_number').closest('form').on('submit', function (e) {
        var card, key, value;
        $(this).find(':submit').prop('disabled', true);
        if (!$(this).find('#membership_info_override').prop('checked')) {
          e.preventDefault();
          card = {};
          for (key in stripeParams) {
            if (!stripeParams.hasOwnProperty(key)) continue;
            value = stripeParams[key];
            card[key] = $(value).val();
          }
          this.stripe.createToken(card).then(subscription.handleStripeResponse);
        }
      });
    },
    handleStripeResponse: function (result) {
      var token = result.token;
      var error = result.error;
      if (error) {
        $('#stripe_card_number').closest('form').find(':submit').prop('disabled', false);
        $('.field_with_errors [id^=stripe]').each(function () {
          $(this).closest('.field_with_errors').removeClass('field_with_errors').find('small.error').remove();
        });
        $(stripeParams[response.error.param]).after('<small class="error">' + error.message + '</small>').closest('.row').addClass('field_with_errors');
      } else {
        $('#membership_stripe_card_token').val(token).closest('form')[0].submit();
      }
    }
  };

  $(function () {
    var stripePublicKey = $('meta[name="stripe-public-key"]').attr('content');
    $('#show-credit-card-info').on('click', function (e) {
      e.preventDefault();
      $('#credit-card-info').removeClass('hide').hide().slideDown(150).find(':disabled').prop('disabled', false);
      $(this).fadeOut(150, function () {
        $(this).remove();
        subscription.stripeInit();
      });
    });
    if (stripePublicKey && $('#credit-card-info').is(':visible')) {
      subscription.stripeInit(stripePublicKey);
    }
  });

}).call(this, jQuery);
