var CardReader = (function($) {
  'use strict';

  var inputString, timeout,
      maybeListening = false,
      listening = false;

  var char = function(keypress) { return String.fromCharCode(keypress.charCode); };
  var capitalize = function(str) {
    return str.toLowerCase().replace(
      /([^a-z])([a-z])(?=[a-z]{2})|^([a-z])/g,
      function(_, g1, g2, g3) {
        return (typeof g1 === 'undefined') ? g3.toUpperCase() : g1 + g2.toUpperCase();
      }
    );
  };
  var generateUserName = function(card) {
    $.get(
      '/users/username',
      { user: { first_name: card.firstName, last_name: card.lastName } },
      function(data) { $('[name*=username]').val(data.username); }
    );
  };

  var process = function(stripeInfo) {
    console.log(stripeInfo);
    var breakdown = stripeInfo.match(/^%B(\d+) *(.)(?=.{2,26})(.+?)\/(.+?) *\2(\d{2})(\d{2})/i);
    if (!breakdown) { return false; }
    var yr = parseInt('20' + breakdown[5], 10),
        mo = parseInt(breakdown[6], 10);
    var card = {
      num: breakdown[1],
      lastName: capitalize(breakdown[3]),
      firstName: capitalize(breakdown[4].replace(/ +\w$/,'')),
      exp: {
        date: new Date(yr, mo, 1),
        month: mo,
        year: yr
      }
    };
    console.log(card);
    $('[name*=first_name]').val(card.firstName);
    $('[name*=last_name]').val(card.lastName);
    $('#stripe_card_number').val(card.num);
    $('#stripe_exp_month').val(card.exp.month);
    $('#stripe_exp_year').val(card.exp.year);
    generateUserName(card);
  };

  var acceptInput = function(e) {
    inputString = inputString || '%B';
    inputString += char(e);
    clearTimeout(timeout);
    timeout = setTimeout(endInput, 50);
  };

  var endInput = function() {
    if (/^%B.+?\?/.test(inputString)) { process(inputString); }
    inputString = void 0;
    listening = false;
  };

  var listener = function(e) {
    if (!listening && char(e) == '%') {
      maybeListening = true;
    } else if (maybeListening) {
      maybeListening = false;
      listening = char(e) == 'B';
    } else if (listening) {
      acceptInput(e);
    } else {
      return;
    }
    e.preventDefault();
  };

  return {
    listen: function() { document.body.addEventListener('keypress', listener); }
  };
})(jQuery);

jQuery(function($) {
  'use strict';
  CardReader.listen();
});
