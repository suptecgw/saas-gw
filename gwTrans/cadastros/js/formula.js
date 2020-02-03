$(function(){
   $('.formula').click(function(){
       $('#text-formula').val($('#text-formula').val() + $(this).text());
   });
});