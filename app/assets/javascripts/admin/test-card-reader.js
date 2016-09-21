window.testCardReader = (function($) {
  return function () {
    'use strict';
    var expDate   = new Date(new Date() + 60 * 1000 * 24 * 31),
        expString = expDate.getFullYear().toString().slice(-2) + String('00' + (expDate.getMonth() + 2)).slice(-2);
    document.getElementById('swipe-input').value = '%B4242424242424242^LASTNAME/FIRSTNAME ^' + expString + '201000000000012345678901234?;4242424242424242=' + expString + '12345678901234?';
  };
})(jQuery);
