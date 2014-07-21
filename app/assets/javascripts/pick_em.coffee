$ ->
  $(document).on
    'ajax:beforeSend': (e,xhr,settings) ->
      pick = decodeURIComponent(settings.data).match(/pick_em\[result\]=(\-?[01])/)[1]
      ga('send','event','Member Portal','Pick Em',pick)
    'ajax:success': (e,xhr,status)->
      $pickem = $(@).closest('.pick-em')
      if xhr.status == 'success'
        $pickem.find('.picked').removeClass('picked')
        $pickem.find(".#{xhr.result} a.choice").addClass('picked')
      else if xhr.errors
        errors = '  - '
        errors += v.join('\n  - ') for k, v of xhr.errors
        error = "The following error#{if Object.keys(xhr.errors).length > 1 then 's' else ''} occurred:\n#{errors}"
        alert(error)
    '.pick-em a'