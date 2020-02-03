var isAtivaAjuda = false;
var isOcultaAjuda = false;

jQuery(document).ready(function () {
    var velocidade = 200;

    if (jQuery('.notificacao center label').html() === '0') {
        jQuery('.notificacao').css('display', 'none');
    }

    jQuery(document.getElementsByName('toggle')).click(function () {
        if (jQuery(document.getElementsByName('toggle')).data("name") == "show") {
            jQuery("#map").animate({
                width: '72%'
            });
            jQuery(document.getElementsByName('toggle')).data('name', 'hide');
            jQuery(document.getElementsByName('toggle')).text("Ocultar Filtros");

            jQuery(document.getElementsByName('toggleAjuda')).data('name', 'show');
            jQuery(document.getElementsByName('toggleAjuda')).text("Exibir Ajuda");
            jQuery(document.getElementsByName('toggleAjuda')).removeClass("toogleOffAjuda");
            jQuery(document.getElementsByName('toggleAjuda')).addClass("toogleOnAjuda");

            jQuery(document.getElementsByName('toggleAuditoria')).data('name', 'show');
            jQuery(document.getElementsByName('toggleAuditoria')).text("Exibir Auditoria");
            jQuery(document.getElementsByName('toggleAuditoria')).removeClass("on");

            if (jQuery(document.getElementsByName('toggle')).text() !== "Ocultar filtros") {
                jQuery(".notificacao").animate({
                    'margin-left': '2.5%'
                }, velocidade, function () {

                });
            }

            jQuery("#columnLeftAjuda,#columnLeftAuditoria").animate({
                width: '0px'
            }, velocidade, function () {
                jQuery("#columnLeftAjuda,#columnLeftAuditoria").css("width", "0px");

                jQuery("#columnLeft").animate({
                    width: '25%'
                }, velocidade, function () {
                    jQuery(".columnLeftAuditoria .content").show();
                    jQuery(".columnLeftAjuda .content").show();
                    jQuery(".columnLeft .content").show();

                    jQuery(document.getElementsByName('toggle')).removeClass("toogleOff");
                    jQuery(document.getElementsByName('toggle')).addClass("toogleOn");

                    jQuery(document.getElementsByName("toggle")).css("margin-left", "-70px");
                    jQuery(document.getElementsByName("toggleAjuda")).css("margin-left", "-72px");
                    jQuery(document.getElementsByName("toggleAuditoria")).css("margin-left", "-82px");


                });
            });

            jQuery('#sidebar').animate({
                width: '0px'
            }, velocidade, function () {
                jQuery(".notificacao").animate({
                    'margin-left': '26.2%'
                }, velocidade, function () {

                });

                jQuery(".conteudo-notificacao").css('margin-left', '25.8%');
                jQuery(".seta-conteudo-notificacao").css('margin-left', '26%');
                jQuery('#sidebar').animate({
                    width: '28%'
                }, velocidade, function () {


                });
            });



        } else if (jQuery(document.getElementsByName('toggle')).data("name") == "hide") {
            jQuery("#map").animate({
                width: '96%'
            });

            jQuery(document.getElementsByName('toggle')).data('name', 'show');
            jQuery(document.getElementsByName('toggle')).text("Exibir Filtros");

            jQuery(document.getElementsByName('toggleAjuda')).data('name', 'show');
            jQuery(document.getElementsByName('toggleAjuda')).text("Exibir Ajuda");
            jQuery(document.getElementsByName('toggleAjuda')).removeClass("toogleOffAjuda");
            jQuery(document.getElementsByName('toggleAjuda')).addClass("toogleOnAjuda");

            jQuery(document.getElementsByName('toggleAuditoria')).data('name', 'show');
            jQuery(document.getElementsByName('toggleAuditoria')).text("Exibir Auditoria");
            jQuery(document.getElementsByName('toggleAuditoria')).removeClass("on");

            jQuery(".columnLeftAuditoria .content").hide();
            jQuery(".columnLeftAjuda .content").hide();
            jQuery(".columnLeft .content").hide();

            jQuery(".notificacao").animate({
                'margin-left': '2.5%'
            }, velocidade, function () {

            });

            jQuery(".conteudo-notificacao").css('margin-left', '2.3%');
            jQuery(".seta-conteudo-notificacao").css('margin-left', '2.5%');


            jQuery("#columnLeft").animate({
                width: '1%'

            }, velocidade, function () {
                jQuery(document.getElementsByName("toggle")).css("margin-left", "-85px");
                jQuery(document.getElementsByName("toggleAjuda")).css("margin-left", "-85px");
                jQuery(document.getElementsByName("toggleAuditoria")).css("margin-left", "-95px");

                jQuery(document.getElementsByName('toggle')).removeClass("toogleOn");
                jQuery(document.getElementsByName('toggle')).addClass("toogleOff");

            });

            jQuery("#columnLeft").animate({
                width: '1%'
            }, velocidade, function () {
            });

            jQuery('#sidebar').animate({
                width: '2%'
            }, velocidade, function () {

            });

        }
    });

    jQuery(document.getElementsByName('toggleAjuda')).click(function () {

        jQuery(".container-video").css("display", "block");
        if (jQuery(document.getElementsByName('toggleAjuda')).data("name") == "show") {

//            if (jQuery(document.getElementsByName('toggle')).text() === "Ocultar filtros") {
            jQuery(".notificacao").animate({
                'margin-left': '2.5%'
            }, velocidade, function () {

            });
//            }

            jQuery("#map").animate({
                width: '72%'
            });
            jQuery(document.getElementsByName('toggleAjuda')).data('name', 'hide');
            jQuery(document.getElementsByName('toggleAjuda')).text("Ocultar Ajuda");

            jQuery(document.getElementsByName('toggle')).data('name', 'show');
            jQuery(document.getElementsByName('toggle')).text("Exibir Filtros");
            jQuery(document.getElementsByName('toggle')).removeClass("toogleOn");
            jQuery(document.getElementsByName('toggle')).addClass("toogleOff");

            jQuery(document.getElementsByName('toggleAuditoria')).data('name', 'show');
            jQuery(document.getElementsByName('toggleAuditoria')).text("Exibir Auditoria");
            jQuery(document.getElementsByName('toggleAuditoria')).removeClass("on");

            jQuery("#columnLeft,#columnLeftAuditoria").animate({
                width: '0px'
            }, velocidade, function () {
                jQuery("#columnLeft").css("width", "0px");

                jQuery("#columnLeftAjuda").animate({
                    width: '25%'
                }, velocidade, function () {
                    jQuery(".columnLeftAuditoria .content").show();
                    jQuery(".columnLeftAjuda .content").show();
                    jQuery(".columnLeft .content").show();

                    jQuery(document.getElementsByName('toggleAjuda')).removeClass("toogleOnAjuda");
                    jQuery(document.getElementsByName('toggleAjuda')).addClass("toogleOffAjuda");

                    jQuery(document.getElementsByName("toggle")).css("margin-left", "-70px");
                    jQuery(document.getElementsByName("toggleAjuda")).css("margin-left", "-72px");
                    jQuery(document.getElementsByName("toggleAuditoria")).css("margin-left", "-82px");
                });
            });

            jQuery('#sidebar').animate({
                width: '0px'
            }, velocidade, function () {
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

            });
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
            });

            jQuery(document.getElementsByName('toggle')).data('name', 'show');
            jQuery(document.getElementsByName('toggle')).text("Exibir Filtros");
            jQuery(document.getElementsByName('toggle')).removeClass("toogleOn");
            jQuery(document.getElementsByName('toggle')).addClass("toogleOff");

            jQuery(document.getElementsByName('toggleAuditoria')).data('name', 'show');
            jQuery(document.getElementsByName('toggleAuditoria')).text("Exibir Auditoria");
            jQuery(document.getElementsByName('toggleAuditoria')).removeClass("on");

            jQuery(".columnLeftAuditoria .content").hide();
            jQuery(".columnLeftAjuda .content").hide();
            jQuery(".columnLeft .content").hide();


            jQuery(".notificacao").animate({
                'margin-left': '2.5%'
            }, velocidade, function () {

            });

            jQuery(".conteudo-notificacao").css('margin-left', '2.3%');
            jQuery(".seta-conteudo-notificacao").css('margin-left', '2.5%');

            jQuery("#columnLeftAjuda,#columnLeftAuditoria").animate({
                width: '1%'
            }, velocidade, function () {
                jQuery(document.getElementsByName("toggle")).css("margin-left", "-85px");
                jQuery(document.getElementsByName("toggleAjuda")).css("margin-left", "-85px");
                jQuery(document.getElementsByName("toggleAuditoria")).css("margin-left", "-95px");

                jQuery(document.getElementsByName('toggleAjuda')).removeClass("toogleOffAjuda");
                jQuery(document.getElementsByName('toggleAjuda')).addClass("toogleOnAjuda");

            });

            jQuery("#columnLeft").animate({
                width: '1%'
            }, velocidade, function () {
            });

            jQuery('#sidebar').animate({
                width: '2%'
            }, velocidade, function () {
            });
            recarregarVideos();
        }
    });

    jQuery(document.getElementsByName('toggleAuditoria')).click(function () {
        jQuery(".container-video").css("display", "block");
        if (jQuery(document.getElementsByName('toggleAuditoria')).data("name") == "show") {
            jQuery(".notificacao").animate({
                'margin-left': '2.5%'
            }, velocidade, function () {
            });

            jQuery("#map").animate({
                width: '72%'
            });
            jQuery(document.getElementsByName('toggleAuditoria')).data('name', 'hide');
            jQuery(document.getElementsByName('toggleAuditoria')).text("Ocultar Auditoria");

            jQuery(document.getElementsByName('toggle')).data('name', 'show');
            jQuery(document.getElementsByName('toggle')).text("Exibir Filtros");
            jQuery(document.getElementsByName('toggle')).removeClass("toogleOn");
            jQuery(document.getElementsByName('toggle')).addClass("toogleOff");

            jQuery(document.getElementsByName('toggleAjuda')).data('name', 'show');
            jQuery(document.getElementsByName('toggleAjuda')).text("Exibir Ajuda");
            jQuery(document.getElementsByName('toggleAjuda')).removeClass("toogleOn");
            jQuery(document.getElementsByName('toggleAjuda')).addClass("toogleOff");

            jQuery("#columnLeft,#columnLeftAjuda").animate({
                width: '0px'
            }, velocidade, function () {
                jQuery("#columnLeft,#columnLeftAjuda").css("width", "0px");

                jQuery("#columnLeftAuditoria").animate({
                    width: '25%'
                }, velocidade, function () {
                    jQuery(".columnLeftAuditoria .content").show();
                    jQuery(".columnLeftAjuda .content").show();
                    jQuery(".columnLeft .content").show();

                    jQuery(document.getElementsByName('toggleAuditoria')).addClass("on");
                    jQuery(document.getElementsByName("toggle")).css("margin-left", "-70px");
                    jQuery(document.getElementsByName("toggleAjuda")).css("margin-left", "-72px");
                    jQuery(document.getElementsByName("toggleAuditoria")).css("margin-left", "-82px");
                });
            });

            jQuery('#sidebar').animate({
                width: '0px'
            }, velocidade, function () {
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

            });
        } else if (jQuery(document.getElementsByName('toggleAuditoria')).data("name") == "hide") {
            jQuery(document.getElementsByName('toggleAuditoria')).data('name', 'show');
            jQuery(document.getElementsByName('toggleAuditoria')).text("Exibir Auditoria");

            jQuery("#map").animate({
                width: '96%'
            });

            jQuery(document.getElementsByName('toggle')).data('name', 'show');
            jQuery(document.getElementsByName('toggle')).text("Exibir Filtros");
            jQuery(document.getElementsByName('toggle')).removeClass("toogleOn");
            jQuery(document.getElementsByName('toggle')).addClass("toogleOff");

            jQuery(document.getElementsByName('toggleAjuda')).data('name', 'show');
            jQuery(document.getElementsByName('toggleAjuda')).text("Exibir Ajuda");
            jQuery(document.getElementsByName('toggleAjuda')).removeClass("toogleOn");
            jQuery(document.getElementsByName('toggleAjuda')).addClass("toogleOff");

            jQuery(".columnLeftAuditoria .content").hide();
            jQuery(".columnLeftAjuda .content").hide();
            jQuery(".columnLeft .content").hide();

            jQuery(".notificacao").animate({
                'margin-left': '2.5%'
            }, velocidade, function () {

            });

            jQuery(".conteudo-notificacao").css('margin-left', '2.3%');
            jQuery(".seta-conteudo-notificacao").css('margin-left', '2.5%');

            jQuery("#columnLeftAuditoria").animate({
                width: '1%'
            }, velocidade, function () {
                jQuery(document.getElementsByName("toggle")).css("margin-left", "-85px");
                jQuery(document.getElementsByName("toggleAjuda")).css("margin-left", "-85px");
                jQuery(document.getElementsByName("toggleAuditoria")).css("margin-left", "-95px");

                jQuery(document.getElementsByName('toggleAuditoria')).removeClass("on");
            });

            jQuery("#columnLeft,#columnLeftAjuda").animate({
                width: '1%'
            }, velocidade, function () {
            });

            jQuery('#sidebar').animate({
                width: '2%'
            }, velocidade, function () {
            });
        }
    });


    var opt = {'type': 'keyup'};

    shortcut.add("f1", function (e) {
        jQuery(".container-video").css("display", "block");
        if (jQuery(document.getElementsByName('toggleAjuda')).data("name") == "show") {

//            if (jQuery(document.getElementsByName('toggle')).text() === "Ocultar filtros") {
            jQuery(".notificacao").animate({
                'margin-left': '2.5%'
            }, velocidade, function () {

            });
//            }

            jQuery("#map").animate({
                width: '72%'
            });
            jQuery(document.getElementsByName('toggleAjuda')).data('name', 'hide');
            jQuery(document.getElementsByName('toggleAjuda')).text("Ocultar Ajuda");

            jQuery(document.getElementsByName('toggle')).data('name', 'show');
            jQuery(document.getElementsByName('toggle')).text("Exibir Filtros");
            jQuery(document.getElementsByName('toggle')).removeClass("toogleOn");
            jQuery(document.getElementsByName('toggle')).addClass("toogleOff");



            jQuery("#columnLeft").animate({
                width: '0px'
            }, velocidade, function () {
                jQuery("#columnLeft").css("width", "0px");

                jQuery("#columnLeftAjuda").animate({
                    width: '25%'
                }, velocidade, function () {
                    jQuery(".columnLeftAjuda .content").show();
                    jQuery(".columnLeft .content").show();

                    jQuery(document.getElementsByName('toggleAjuda')).removeClass("toogleOnAjuda");
                    jQuery(document.getElementsByName('toggleAjuda')).addClass("toogleOffAjuda");

                    jQuery(document.getElementsByName("toggle")).css("margin-left", "-70px");
                    jQuery(document.getElementsByName("toggleAjuda")).css("margin-left", "-72px");
                    jQuery(document.getElementsByName("toggleAuditoria")).css("margin-left", "-82px");
                });
            });

            jQuery('#sidebar').animate({
                width: '0px'
            }, velocidade, function () {
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

            });
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
            });

            jQuery(document.getElementsByName('toggle')).data('name', 'show');
            jQuery(document.getElementsByName('toggle')).text("Exibir Filtros");
            jQuery(document.getElementsByName('toggle')).removeClass("toogleOn");
            jQuery(document.getElementsByName('toggle')).addClass("toogleOff");

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
                jQuery(document.getElementsByName("toggle")).css("margin-left", "-85px");
                jQuery(document.getElementsByName("toggleAjuda")).css("margin-left", "-85px");
                jQuery(document.getElementsByName("toggleAuditoria")).css("margin-left", "-95px");

                jQuery(document.getElementsByName('toggleAjuda')).removeClass("toogleOffAjuda");
                jQuery(document.getElementsByName('toggleAjuda')).addClass("toogleOnAjuda");

            });

            jQuery("#columnLeft").animate({
                width: '1%'
            }, velocidade, function () {
            });

            jQuery('#sidebar').animate({
                width: '2%'
            }, velocidade, function () {
            });
            recarregarVideos();
        }
    }, opt);


    shortcut.add("f2", function (e) {
        if (jQuery(document.getElementsByName('toggle')).data("name") == "show") {
            jQuery("#map").animate({
                width: '72%'
            });
            jQuery(document.getElementsByName('toggle')).data('name', 'hide');
            jQuery(document.getElementsByName('toggle')).text("Ocultar Filtros");

            jQuery(document.getElementsByName('toggleAjuda')).data('name', 'show');
            jQuery(document.getElementsByName('toggleAjuda')).text("Exibir Ajuda");
            jQuery(document.getElementsByName('toggleAjuda')).removeClass("toogleOffAjuda");
            jQuery(document.getElementsByName('toggleAjuda')).addClass("toogleOnAjuda");

            if (jQuery(document.getElementsByName('toggle')).text() !== "Ocultar filtros") {
                jQuery(".notificacao").animate({
                    'margin-left': '2.5%'
                }, velocidade, function () {

                });
            }

            jQuery("#columnLeftAjuda").animate({
                width: '0px'
            }, velocidade, function () {
                jQuery("#columnLeftAjuda").css("width", "0px");

                jQuery("#columnLeft").animate({
                    width: '25%'
                }, velocidade, function () {
                    jQuery(".columnLeftAjuda .content").show();
                    jQuery(".columnLeft .content").show();

                    jQuery(document.getElementsByName('toggle')).removeClass("toogleOff");
                    jQuery(document.getElementsByName('toggle')).addClass("toogleOn");

                    jQuery(document.getElementsByName("toggle")).css("margin-left", "-70px");
                    jQuery(document.getElementsByName("toggleAjuda")).css("margin-left", "-72px");
                    jQuery(document.getElementsByName("toggleAuditoria")).css("margin-left", "-82px");

                });
            });

            jQuery('#sidebar').animate({
                width: '0px'
            }, velocidade, function () {
                jQuery(".notificacao").animate({
                    'margin-left': '26.2%'
                }, velocidade, function () {

                });

                jQuery(".conteudo-notificacao").css('margin-left', '25.8%');
                jQuery(".seta-conteudo-notificacao").css('margin-left', '26%');
                jQuery('#sidebar').animate({
                    width: '28%'
                }, velocidade, function () {


                });
            });



        } else if (jQuery(document.getElementsByName('toggle')).data("name") == "hide") {
            jQuery("#map").animate({
                width: '96%'
            });

            jQuery(document.getElementsByName('toggle')).data('name', 'show');
            jQuery(document.getElementsByName('toggle')).text("Exibir Filtros");

            jQuery(document.getElementsByName('toggleAjuda')).data('name', 'show');
            jQuery(document.getElementsByName('toggleAjuda')).text("Exibir Ajuda");
            jQuery(document.getElementsByName('toggleAjuda')).removeClass("toogleOffAjuda");
            jQuery(document.getElementsByName('toggleAjuda')).addClass("toogleOnAjuda");

            jQuery(".columnLeftAjuda .content").hide();
            jQuery(".columnLeft .content").hide();

            jQuery(".notificacao").animate({
                'margin-left': '2.5%'
            }, velocidade, function () {

            });

            jQuery(".conteudo-notificacao").css('margin-left', '2.3%');
            jQuery(".seta-conteudo-notificacao").css('margin-left', '2.5%');


            jQuery("#columnLeft").animate({
                width: '1%'

            }, velocidade, function () {
                jQuery(document.getElementsByName("toggle")).css("margin-left", "-85px");
                jQuery(document.getElementsByName("toggleAjuda")).css("margin-left", "-85px");
                jQuery(document.getElementsByName("toggleAuditoria")).css("margin-left", "-95px");

                jQuery(document.getElementsByName('toggle')).removeClass("toogleOn");
                jQuery(document.getElementsByName('toggle')).addClass("toogleOff");

            });

            jQuery("#columnLeft").animate({
                width: '1%'
            }, velocidade, function () {
            });

            jQuery('#sidebar').animate({
                width: '2%'
            }, velocidade, function () {

            });

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

                        if (isOcultaAjuda) {
//                            jQuery('.campo-helper h2').html('Ajuda');
//                            jQuery(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
                        }

                    }, 5000);
                }
            }
    );

    adicionarLinkCadastro();
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

function adicionarLinkCadastro() {
    jQuery("label[data-url-cadastro][data-url-cadastro!='']")
        .addClass('lb-link')
        .on('click', function () {
            var elementoLink = jQuery(this);
            var link = elementoLink.attr('data-url-cadastro').replace('${homePath}', homePath);
            var indice = elementoLink.attr('data-indice');

            jQuery('input[type="hidden"][name^="hi_row_"][name$="_' + indice + '"]').each(function () {
                var elemento = $(this);
                var nomeInput = elemento.attr('name').replace('hi_row_', '').replace('_' + indice, '');
                var valor = elemento.val();

                link = link.replace('${' + nomeInput + '}', valor);
            });

            window.open(link, "_blank", "location=0, status=0, resizable=1, scrollbars=1, width=1368, height=768");
        });
}