# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https:#github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require foundation
#= require hex_functions
#= require pick_em
#= require users/memberships
#= require_self

$ ->
  $(document).foundation()
  $.ajaxSettings.dataType = 'json'

  $(document).on 'change', ':input[data-autosubmit]', ->
    parent.location = $(this).data().autosubmit.replace('YYYY-MM-DD',$(this).val())

  $(':input[name*=_color]').on('change', ->
      $this = $(this)
      val = $this.val() || 'efefef'
      val = "#{Array(6 - val.length+1).join('0')}#{val}"
      console.log val, darken(val), getContrastYIQ(val)
      $(".prefix[data-color-input=#{$this.attr('id')}").css
        'background-color': "##{val}"
        'border-color': "##{darken(val)}"
        'color' : getContrastYIQ(val)
    ).trigger 'change'
  $('input[type=file]').each ->
    $(this).hide()
    $this = $(this)
    $label = $('body').find("label[for=#{$this.attr('id')}]")
    label = if $label.length > 0 then $label.html() else 'Select File'
    $row = $('<div class="row collapse file-input">
      <div class="small-6 columns"><label for=' + $this.attr('id') + ' class="button small expand"><i class="fa fa-file" /> ' + label + '</label></div>
      <div class="small-6 columns"><label for=' + $this.attr('id') + ' class="inline">No file selected</label></div>
    </div>');
    $row.insertAfter($this)
    $this.on 'change', ()->
      $row.find('label.inline').text($this.val().replace('C:\\fakepath\\','') or 'No file selected')

  $(document).on 'ajax:send', ->
    $('body').addClass 'wait'
  $(document).on 'ajax:complete', ->
    $('body').removeClass 'wait'
  $(document).on 'ajax:success', '[data-remote]', (e,data)->
    $('main > .row > .small-12.columns').html(data.html) if data.html
    $('body').removeClass 'wait'