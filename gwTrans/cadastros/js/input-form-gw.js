//$(document).ready(function () {
//    if (qs["modulo"] === 'consulta') {
//        $.each($('.input-form-gw'), function(){
//            var d = $(this).parent('span').find('label').outerWidth();
//            console.log(d);
//            d = parseInt(d) - 13;
//            $(this).css('text-indent', d);
//            $(this).attr('disabled', 'true');
//        });
//    }
//
//    $('.input-form-gw').on('focusin focusout ', function (e) {
//        if (e.type === 'focusin') {
//            $(this).css('text-indent', '0px');
//            $($(this).parents()[2]).animate({
////               'padding': '31px 15px 8px 10px'
//            },150);
//        } else if (e.type === 'focusout') {
//            var d = $(this).parent('span').find('label').outerWidth();
//            d = parseInt(d) - 13;
//            $(this).css('text-indent', d);
//            $($(this).parents()[2]).animate({
////               'padding': '8px 15px 8px 10px'
//            },150);
//        }
//    });
//
//    $('.input-form-gw').mouseenter(function () {
//        $(this).attr('title', $(this).val());
//    });
//    
//});