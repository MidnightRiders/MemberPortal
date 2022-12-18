jQuery(function($) {
  if ($('.popup-form').length > 0) {
    return $('.popup-form').on('ajax:success', ':input', function(e, data) {
      if (data.flash !== "") {
        $(data.flash).insertBefore('.popup-form').hide().slideDown();
      }
      return $('.popup-form').addClass('success').slideUp(function() {
        return $('.popup-form').remove();
      });
    });
  }
});
