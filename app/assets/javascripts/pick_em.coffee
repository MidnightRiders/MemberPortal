$ ->
  $(document).on 'ajax:success', '.pick-em a', (e,xhr,status)->
    $this = $(this)
    $pickem = $(this).closest('.pick-em')
    if xhr.status == 'success'
      $pickem.find('.picked').removeClass('picked')
      $pickem.find(".#{xhr.result} a.button").addClass('picked')