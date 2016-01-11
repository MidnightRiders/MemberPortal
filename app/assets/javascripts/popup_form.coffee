jQuery ($)->
  if $('.popup-form').length > 0
    $('.popup-form').on 'ajax:success', ':input', (e, data) ->
      if data.flash != ""
        $(data.flash).insertBefore('.popup-form').hide().slideDown()
      $('.popup-form').addClass('success').slideUp ->
        $('.popup-form').remove()
