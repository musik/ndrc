//= require jquery
//= require jquery_ujs
//= require bootstrap-alert
//= require carousel
//*= require bootstrap-carousel

$(function(){
  $('.list-item').hover(function(){
    $(this).find('.hot-query-layer').show()
    $(this).toggleClass('learn-item-hover')
  },function(){
    $(this).find('.hot-query-layer').hide()
    $(this).toggleClass('learn-item-hover')
  })
  //$('.carousel').carousel();
})
