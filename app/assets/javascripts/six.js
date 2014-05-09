//= require jquery
//= require jquery_ujs
//= require bootstrap-alert
//= require carousel
//*= require bootstrap-carousel

$(function(){
  $('.list-item').hover(function(){
    $(this).find('.hot-query-layer').show()
    $(this).addClass('learn-item-hover')
  },function(){
    $(this).find('.hot-query-layer').hide()
    $(this).removeClass('learn-item-hover')
  })
  //$('.carousel').carousel();
})
