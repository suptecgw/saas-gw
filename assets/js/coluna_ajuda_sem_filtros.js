var isAtivaAjuda = false;
var isOcultaAjuda = false;

var carregando = true;

jQuery(document).ready(function () {
    var velocidade = 200;

    if (jQuery('.notificacao center label').html() === '0') {
        jQuery('.notificacao').css('display', 'none');
    }

    //So executa quando carrega pela primeira vez a tela
    if (jQuery(document.getElementsByName('toggleAjuda')).data("name") === "hide" && carregando === true) {
        jQuery(document.getElementsByName('toggleAjuda')).data('name', 'show');
        jQuery(document.getElementsByName('toggleAjuda')).text("Exibir Ajuda");

        jQuery("#map").css('width', '96%');

        jQuery(".columnLeftAjuda .content").hide();
        jQuery(".columnLeft .content").hide();

        jQuery(".notificacao").css('margin-left', '2.5%');
        jQuery(".conteudo-notificacao").css('margin-left', '2.1%');
        jQuery(".seta-conteudo-notificacao").css('margin-left', '2.3%');

        jQuery("#columnLeftAjuda").css('width', '1%');
        jQuery(document.getElementsByName("toggleAjuda")).css("margin-left", "-85px");
        jQuery(document.getElementsByName('toggleAjuda')).removeClass("toogleOffAjuda");
        jQuery(document.getElementsByName('toggleAjuda')).addClass("toogleOnAjuda");

        jQuery('#sidebar').css('width', '2%');

        carregando = false;
    }


    jQuery(document.getElementsByName('toggleAjuda')).click(function () {

        jQuery(".container-video").css("display", "block");

        if (jQuery(document.getElementsByName('toggleAjuda')).data("name") === "show") {


            jQuery("#map").animate({
                width: '72%'
            }, velocidade, function () {

            });

            jQuery(document.getElementsByName('toggleAjuda')).data('name', 'hide');
            jQuery(document.getElementsByName('toggleAjuda')).text("Ocultar Ajuda");

            jQuery("#columnLeftAjuda").animate({
                width: '25%'
            }, velocidade, function () {
                jQuery(".columnLeftAjuda .content").show();
                jQuery(".columnLeft .content").show();

                jQuery(document.getElementsByName('toggleAjuda')).removeClass("toogleOnAjuda");
                jQuery(document.getElementsByName('toggleAjuda')).addClass("toogleOffAjuda");
                jQuery(document.getElementsByName("toggleAjuda")).css("margin-left", "-72px");
            });

            jQuery('#sidebar').animate({
                width: '28%'
            }, velocidade, function () {

            });

            jQuery(".notificacao").animate({
                'margin-left': '26.2%'
            }, velocidade, function () {

            });

            jQuery(".conteudo-notificacao").css('margin-left', '25.8%');
            jQuery(".seta-conteudo-notificacao").css('margin-left', '26%');

            recarregarVideos();

            if (isAtivaAjuda == false) {
                isAtivaAjuda = true;
                carregarAjuda();
            }

        } else if (jQuery(document.getElementsByName('toggleAjuda')).data("name") == "hide") {
            jQuery(document.getElementsByName('toggleAjuda')).data('name', 'show');
            jQuery(document.getElementsByName('toggleAjuda')).text("Exibir Ajuda");

            jQuery("#map").animate({
                width: '96%'
            }, velocidade, function () {

            });

            jQuery(".columnLeftAjuda .content").hide();
            jQuery(".columnLeft .content").hide();

            jQuery(".notificacao").animate({
                'margin-left': '2.5%'
            }, velocidade, function () {

            });

            jQuery(".conteudo-notificacao").css('margin-left', '2.1%');
            jQuery(".seta-conteudo-notificacao").css('margin-left', '2.3%');

            jQuery("#columnLeftAjuda").animate({
                width: '1%'
            }, velocidade, function () {
                jQuery(document.getElementsByName("toggleAjuda")).css("margin-left", "-85px");
                jQuery(document.getElementsByName('toggleAjuda')).removeClass("toogleOffAjuda");
                jQuery(document.getElementsByName('toggleAjuda')).addClass("toogleOnAjuda");
            });

            jQuery('#sidebar').animate({
                width: '2%'
            }, velocidade, function () {
            });
            recarregarVideos();
        }
    });


    var opt = {'type': 'keyup'};

    shortcut.add("f1", function (e) {
        jQuery(".container-video").css("display", "block");
        if (jQuery(document.getElementsByName('toggleAjuda')).data("name") == "show") {


            jQuery("#map").animate({
                width: '72%'
            }, velocidade, function () {

            });

            jQuery(document.getElementsByName('toggleAjuda')).data('name', 'hide');
            jQuery(document.getElementsByName('toggleAjuda')).text("Ocultar Ajuda");

            jQuery("#columnLeftAjuda").animate({
                width: '25%'
            }, velocidade, function () {
                jQuery(".columnLeftAjuda .content").show();
                jQuery(".columnLeft .content").show();
                jQuery(document.getElementsByName('toggleAjuda')).removeClass("toogleOnAjuda");
                jQuery(document.getElementsByName('toggleAjuda')).addClass("toogleOffAjuda");
                jQuery(document.getElementsByName("toggleAjuda")).css("margin-left", "-72px");
            });

            jQuery('#sidebar').animate({
                width: '28%'
            }, velocidade, function () {

            });

            jQuery(".notificacao").animate({
                'margin-left': '26.2%'
            }, velocidade, function () {

            });

            jQuery(".conteudo-notificacao").css('margin-left', '25.8%');
            jQuery(".seta-conteudo-notificacao").css('margin-left', '26%');

            recarregarVideos();

            if (isAtivaAjuda == false) {
                isAtivaAjuda = true;
                carregarAjuda();
            }

        } else if (jQuery(document.getElementsByName('toggleAjuda')).data("name") == "hide") {
            jQuery(document.getElementsByName('toggleAjuda')).data('name', 'show');
            jQuery(document.getElementsByName('toggleAjuda')).text("Exibir Ajuda");

            jQuery("#map").animate({
                width: '96%'
            }, velocidade, function () {

            });

            jQuery(".columnLeftAjuda .content").hide();
            jQuery(".columnLeft .content").hide();

            jQuery(".notificacao").animate({
                'margin-left': '2.5%'
            }, velocidade, function () {

            });

            jQuery(".conteudo-notificacao").css('margin-left', '2.3%');
            jQuery(".seta-conteudo-notificacao").css('margin-left', '2.5%');

            jQuery("#columnLeftAjuda").animate({
                width: '1%'
            }, velocidade, function () {
                jQuery(document.getElementsByName("toggleAjuda")).css("margin-left", "-85px");
                jQuery(document.getElementsByName('toggleAjuda')).removeClass("toogleOffAjuda");
                jQuery(document.getElementsByName('toggleAjuda')).addClass("toogleOnAjuda");

            });

            jQuery('#sidebar').animate({
                width: '2%'
            }, velocidade, function () {
            });
            recarregarVideos();
        }
    }, opt);


    var cancelKeypress = false;
    if ("onhelp" in window) {
        window.onhelp = function () {
            return false;
        };
    }
    jQuery(document).keydown(function (evt) {
        if (evt.keyCode === 112) {
            if (window.event) {
                window.event.keyCode = 0;
            }
            cancelKeypress = true;
            return false;
        }
    });
    jQuery(document).keypress(function (evt) {
        if (cancelKeypress) {
            cancelKeypress = false; // Only this keypress
            return false;
        }
    });

    jQuery('.notificacao').hover(
            function () {
                jQuery('.conteudo-notificacao').show("fast");
                jQuery('.seta-conteudo-notificacao').show("fast");
            },
            function () {
                jQuery('.conteudo-notificacao').hide("fast");
                jQuery('.seta-conteudo-notificacao').hide("fast");
            }

    );

    jQuery('.container-video').on('mouseover mouseout change', function (e, a) {
        if (e.type === 'mouseover') {
            myConfObj.iframeMouseOver = true;
            containerVideo = e.currentTarget;
        } else if (e.type === 'mouseout') {
            myConfObj.iframeMouseOver = false;
        } else if (e.type === 'change') {
            var target = jQuery(jQuery(e.currentTarget)[0]);

            var iframe = jQuery(jQuery(target).context).find('iframe');

            if (target.find('div')[0].className !== 'col-md-12') {

                jQuery(jQuery('.container-video').find('div')).removeClass();
                jQuery(jQuery('.container-video').find('div')).addClass("col-md-6");
                jQuery(jQuery('.container-video').find('img').css('right', '0'));

                jQuery(target.find('div')[0]).removeClass();
                jQuery(target.find('div')[1]).removeClass();

                jQuery(target.find('div')[0]).addClass("col-md-12");
                jQuery(target.find('div')[1]).addClass("col-md-12");


                jQuery(target.find('img').css('right', '10px'));

                var iframes = jQuery(".container-video div iframe");
                jQuery(iframes).css("max-width", "95%");
                jQuery(iframes).css("height", "100px");

                jQuery(iframe).css("max-width", "95%");
                jQuery(iframe).css("width", "95%");

                jQuery(iframe).css("height", parseFloat(jQuery(iframe).width()) - 50 + "px");
                jQuery(iframe)[0].src += "&autoplay=1";

                gravarAcaoUsuario('a', jQuery(jQuery(e.currentTarget)[0]).find('input:hidden').val());
                removeNotificacao(iframe);
                recarregarNotificacao();

                jQuery(document).focus();
            }
        }
    });


//    jQuery(".ativa-helper").hover(
//        function(){
//            if(isAtivaAjuda == true){
//                jQuery(".campo-helper h2").html(jQuery(this).html().replace(':',''));
//                jQuery(".descri-helper h3").html(jQuery(this).context.firstElementChild.value);
//            }
//        },
//        function(){
//            if(isAtivaAjuda == true){
//                setTimeout(function(){ jQuery('.campo-helper h2').html('Ajuda'); },300);
//                setTimeout(function() { jQuery(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.'); }, 300);
//            }
//        }
//    );

    jQuery(".ativa-helper").hover(
            function () {
                isOcultaAjuda = true;
                if (isAtivaAjuda == true) {
                    jQuery(".campo-helper h2").html(jQuery(this).html().replace(':', ''));
                    jQuery(".descri-helper h3").html(jQuery(this).context.firstElementChild.value);
                }
            },
            function () {
                isOcultaAjuda = false;
                if (isAtivaAjuda == true) {
//                setTimeout(function(){ jQuery('.campo-helper h2').html('Ajuda'); },300);
//                setTimeout(function() { jQuery(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.'); }, 300);
                    setTimeout(function () {

                        if (isOcultaAjuda == false) {
                            jQuery('.campo-helper h2').html('Ajuda');
                            jQuery(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
                        }

                    }, 1000);
                }
            }
    );

});

var index = 1;
function addNotificacao() {
    if (jQuery('.notificacao').css('display') === 'none') {
        jQuery('.notificacao').css('display', 'block');
    }
    jQuery('.notificacao center label').html(index++);
}

function removeNotificacao(iframe) {
    if ((parseInt(jQuery('.notificacao center label').html()) - 1) === 0) {
        jQuery('.notificacao').css('display', 'none');
    }

    jQuery(iframe).parent().find('img').attr('src', 'assets/img/ja_visto.png');
    jQuery('.notificacao center label').html(parseInt(jQuery('.notificacao center label').html()) - 1);
}



function gravarAcaoUsuario(acao, idVideo) {
    jQuery.ajax({
        url: 'VideoControlador',
        dataType: "text",
        method: "post",
        async: false,
        data: {
            acao: "gravarAcaoUsuario",
            videoId: idVideo,
            acaoNoVideo: acao
        },
        success: function (data) {

        }
    });
}

//Lembrar de usar a classe (ativa-helper) na label se nao vai da erro!
function addAjudaLabel(l, valueInputAjuda) {
    var label = jQuery('#' + l);
    var html = label.html();
    var createInputAjuda = ' <input type="hidden" value="' + valueInputAjuda + '"> ';

    label.html(html + createInputAjuda);
}

function addPermissoesTela(codigo, descricao, observacao) {
    jQuery('.table_permissao tbody').append('<tr><td>' + codigo + '</td><td>' + descricao + '</td><td>' + observacao + '</td></tr>');
}

function semPermissao() {
    jQuery('.table_permissao tbody').append('<tr><td colspan="3">Não existe permissões para esta tela.</td></tr>');
}


function carregarAjuda() {
    jQuery.ajax({
        url: "UsuarioControlador?acao=ativarAjuda&codigoTela=" + codigoTela,
        type: 'POST',
        dataType: 'text/html',
        beforeSend: function () {
            if (jQuery('.aguarde') !== undefined) {
                jQuery('.cobre-left').show('fast');
                jQuery('.aguarde').show('fast');
            }
        },
        complete: function (retorno) {
            if (jQuery('.aguarde') !== undefined) {
                jQuery('.aguarde').hide('fast');
                jQuery('.cobre-left').hide('fast');
            }

            if (retorno.responseText !== '') {

                var camposAjuda = JSON.parse(retorno.responseText.split(']')[0] + ']');
                var permissoes = JSON.parse(retorno.responseText.split(']')[1] + ']');

                console.log(camposAjuda);
                console.log(permissoes);

                for (var i = 0; i < camposAjuda.length; i++) {
                    var jsonCampos = camposAjuda[i];
                    addAjudaLabel(jsonCampos.name, jsonCampos.observacao);
                }

                for (var i = 0; i < permissoes.length; i++) {
                    var jsonPerm = permissoes[i];
                    addPermissoesTela(jsonPerm.codigo, jsonPerm.descricao, jsonPerm.observacao);
                }

                if (permissoes.length === 0) {
                    semPermissao();
                }

            } else {
                semPermissao();
            }
        }
    });
}