$ ->
  $(document).on 'ajax:success', '.pick-em a', (e,xhr,status)->
    $pickem = $(@).closest('.pick-em')
    if xhr.status == 'success'
      $pickem.find('.picked').removeClass('picked')
      $pickem.find(".#{xhr.result} a.choice").addClass('picked')
    else if xhr.errors
      errors = '  - '
      errors += v.join('\n  - ') for k, v of xhr.errors
      error = "The following error#{if Object.keys(xhr.errors).length > 1 then 's' else ''} occurred:\n#{errors}"
      alert(error)