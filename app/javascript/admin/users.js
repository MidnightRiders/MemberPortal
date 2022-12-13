jQuery(function($) {
  return $('a.edit-membership').on('click', function(e) {
    e.preventDefault();
    $(this).closest('.row').slideUp(150);
    return $('#edit-membership').find(':input').removeProp('disabled').end().removeClass('hide').hide().slideDown(150);
  });
});
