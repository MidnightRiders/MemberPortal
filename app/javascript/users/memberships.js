// @ts-check
(function (/** @type {jQuery} */ $) {
  let stripePublicKey;

  const stripeParams = {
    number: '#stripe_card_number',
    exp_month: '#stripe_exp_month',
    exp_year: '#stripe_exp_year',
    cvc: '#stripe_cvc',
  };

  const subscription = {
    stripeInit: function () {
      window.Stripe.setPublishableKey(stripePublicKey);
      subscription.setUpForm();
    },
    setUpForm: function () {
      return $('#stripe_card_number')
        .closest('form')
        .on('submit', function (e) {
          $(this).find(':submit').prop('disabled', true);
          if (!$(this).find('#membership_info_override').prop('checked')) {
            e.preventDefault();
            const card = Object.entries(stripeParams).reduce(
              (o, [key, value]) => ({
                ...o,
                [key]: $(value).val(),
              }),
              /** @type {stripe.StripeCardTokenData} */ ({}),
            );
            window.Stripe.createToken(card, subscription.handleStripeResponse);
          }
        });
    },
    handleStripeResponse: function (status, response) {
      if (status === 200) {
        /** @type {HTMLFormElement} */ (
          $('#membership_stripe_card_token').val(response.id).closest('form')[0]
        ).submit();
      } else {
        $('#stripe_card_number').closest('form').find(':submit').prop('disabled', false);
        $('.field_with_errors [id^=stripe]').each(function () {
          $(this).closest('.field_with_errors').removeClass('field_with_errors').find('small.error').remove();
        });
        $(stripeParams[response.error.param])
          .after('<small class="error">' + response.error.message + '</small>')
          .closest('.row')
          .addClass('field_with_errors');
      }
    },
  };

  $(function () {
    stripePublicKey = $('meta[name="stripe-public-key"]').attr('content');
    $('#show-credit-card-info').on('click', function (e) {
      e.preventDefault();
      $('#credit-card-info').removeClass('hide').hide().slideDown(150).find(':disabled').prop('disabled', false);
      $(this).fadeOut(150, function () {
        $(this).remove();
        subscription.stripeInit();
      });
    });
    if (stripePublicKey && $('#credit-card-info').is(':visible')) {
      subscription.stripeInit();
    }

    $('#new-membership').on('submit', function (e) {
      const autoRenewCheckbox = /** @type {HTMLInputElement | undefined} */ (
        $(this).find('[type=checkbox][name*=subscribe]').get(0)
      );
      if (!autoRenewCheckbox || autoRenewCheckbox.checked) return;

      if (confirm('Are you sure you wish to continue without auto-renewal enabled?')) return;

      e.preventDefault();
      return false;
    });
  });
}).call(this, jQuery);
