// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https:#github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require modernizr
//= require jquery
//= require jquery_ujs
//= require noconflict
//= require foundation
//= require hex_functions
//= require pick_em
//= require users/memberships
//= require_self

(function() {
  jQuery(function($) {
    $(document).foundation();
    $.ajaxSettings.dataType = 'json';
    $('a.toggle-div').on('click', function(e) {
      var $target;
      e.preventDefault();
      $target = $(this).data('target') ? $($(this).data('target')) : $(this).parent().find('.toggle-target');
      return $target.slideToggle();
    });
    $(document).on('change', ':input[data-autosubmit]', function() {
      return parent.location = $(this).data('autosubmit').replace('___', $(this).val());
    });
    $(':input[name*=_color]').on('change', function() {
      var $this, val;
      $this = $(this);
      val = $this.val() || 'efefef';
      val = "" + (Array(6 - val.length + 1).join('0')) + val;
      return $(".prefix[data-color-input=" + ($this.attr('id'))).css({
        'background-color': "#" + val,
        'border-color': "#" + (darken(val)),
        'color': getContrastYIQ(val)
      });
    }).trigger('change');
    $('input[type=file]').each(function() {
      var $label, $row, $this, label;
      $(this).hide();
      $this = $(this);
      $label = $('body').find("label[for=" + ($this.attr('id')) + "]");
      label = $label.length > 0 ? $label.html() : 'Select File';
      $row = $("<div class=\"row collapse file-input\">\n  <div class=\"small-6 columns\"><label for=\"" + ($this.attr('id')) + "\" class=\"button small expand\"><i class=\"fa fa-file\" /> " + label + "</label></div>\n  <div class=\"small-6 columns\"><label for=\"" + ($this.attr('id')) + "\" class=\"inline\">No file selected</label></div>\n</div>");
      $row.insertAfter($this);
      return $this.on('change', function() {
        return $row.find('label.inline').text($this.val().replace('C:\\fakepath\\', '') || 'No file selected');
      });
    });
    $(document).on('ajax:send', function() {
      return $('body').addClass('wait');
    });
    $(document).on('ajax:complete', function() {
      return $('body').removeClass('wait');
    });
    return $(document).on('ajax:success', '[data-remote]', function(e, data) {
      $('body').removeClass('wait');
      if (data && data.selector && data.html) {
        return $(data.selector).html(data.html);
      }
    });
  });

}).call(this);
