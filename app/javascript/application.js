import 'jquery-ujs';
import '@nathanvda/cocoon';

import LogRocket from 'logrocket';

import './vendor/modernizr';
import './vendor/foundation';
import './hex_functions';
import './pick_em';
import './users/memberships';

LogRocket.init('nqhpme/midnight-riders-member-portal');

(function () {
  jQuery(function ($) {
    if (window.userInfo) {
      LogRocket.identify(window.userInfo.id, {
        name: window.userInfo.name,
        email: window.userInfo.email,
      });
    }
    $(document).foundation();
    $.ajaxSettings.dataType = 'json';
    $('a.toggle-div').on('click', function (e) {
      var $target;
      e.preventDefault();
      $target = $(this).data('target')
        ? $($(this).data('target'))
        : $(this).parent().find('.toggle-target');
      return $target.slideToggle();
    });
    $(document).on('change', ':input[data-autosubmit]', function () {
      return (parent.location = $(this)
        .data('autosubmit')
        .replace('___', $(this).val()));
    });
    $(':input[name*=_color]')
      .on('change', function () {
        var $this, val;
        $this = $(this);
        val = $this.val() || 'efefef';
        val = '' + Array(6 - val.length + 1).join('0') + val;
        return $('.prefix[data-color-input=' + $this.attr('id')).css({
          'background-color': '#' + val,
          'border-color': '#' + darken(val),
          color: getContrastYIQ(val),
        });
      })
      .trigger('change');
    function transformFileInputs () {
      var $label, $row, $this, label;
      $(this).hide();
      $this = $(this);
      if ($this.next().is('.file-input')) return;
      $label = $('body').find('label[for=' + $this.attr('id') + ']');
      label = $label.length > 0 ? $label.html() : 'Select File';
      $row = $(
        '<div class="row collapse file-input">\n  <div class="medium-6 columns"><label for="' +
        $this.attr('id') +
        '" class="button small expand"><i class="fa fa-file"></i> ' +
        label +
        '</label></div>\n  <div class="medium-6 columns"><label for="' +
        $this.attr('id') +
        '" class="inline">No file selected</label></div>\n</div>',
      );
      $row.insertAfter($this);
      return $this.on('change', function () {
        return $row
          .find('label.inline')
          .text(
            $this.val().replace('C:\\fakepath\\', '') || 'No file selected',
          );
      });
    }
    $('input[type=file]').each(transformFileInputs);
    $(document.body).on('cocoon:after-insert', function () {
      $('input[type=file]').each(transformFileInputs);
    });
    $(document).on('ajax:send', function () {
      return $('body').addClass('wait');
    });
    $(document).on('ajax:complete', function () {
      return $('body').removeClass('wait');
    });
    return $(document).on('ajax:success', '[data-remote]', function (e, data) {
      $('body').removeClass('wait');
      if (data && data.selector && data.html) {
        return $(data.selector).html(data.html);
      }
    });
  });
}.call(this));
