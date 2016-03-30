(function($) {
  'use strict';

  var updateCart = function(e, data) {
    $('.top-bar .cart').replaceWith(data.html['menu']);
    $('.cart-count').text(data.items);
    $(this).find('[name*=amount]').val(1);
    $(document).foundation('reflow');
  };

  $(function() {
    $(document.body).on('ajax:success', '[data-cart]', updateCart);
  });
})(jQuery);
