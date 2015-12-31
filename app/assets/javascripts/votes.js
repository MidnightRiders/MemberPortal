(function($) {
  $(function() {
    $(document.body).on('ajax:success', '.votes', function(e, data) {
      if (data.html) $(this).replaceWith(data.html);
    });
  });
})(jQuery);
