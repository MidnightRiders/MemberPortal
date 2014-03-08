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
#= require_tree .

$ ->
  $(document).foundation()

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
  $(document).on 'ajax:send', ->
    $('body').addClass 'wait'
  $(document).on 'ajax:complete', ->
    $('body').removeClass 'wait'