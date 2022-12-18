/* global ga */

jQuery(function($) {
  'use strict';

  $(document).on({
    'ajax:beforeSend': function(e, xhr, settings) {
      var pick = decodeURIComponent(settings.data).match(/pick_em\[result\]=(\-?[01])/)[1];
      ga('send', 'event', 'Member Portal', 'Pick Em', pick);
    },
    'ajax:success': function(e, data, _status, xhr) {
      var error, errors, key,
          $pickEm = $(this).closest('.pick-em');
      if (xhr.status === 202) {
        $pickEm.find('.picked').removeClass('picked');
        return $pickEm.find('.' + data.result + ' a.choice').addClass('picked');
      } else if (data.errors) {
        errors = '  - ';
        for (key in data.errors) {
          if (!data.errors.hasOwnProperty(key)) continue;
          errors += data.errors[key].join('\n  - ');
        }
        error = 'The following error' + (Object.keys(data.errors).length > 1 ? 's' : '') + ' occurred:\n' + errors;
        alert(error);
      }
    }
  }, '.pick-em a');
});
