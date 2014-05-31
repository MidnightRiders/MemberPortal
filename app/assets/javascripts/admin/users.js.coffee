$ ->
  $('a.edit-membership').on 'click', (e)->
    e.preventDefault()
    $(this).closest('.row').slideUp 150
    $('#edit-membership').find(':input').removeProp('disabled').end()
      .removeClass('hide').hide().slideDown 150