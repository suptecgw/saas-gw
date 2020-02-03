
jQuery(document).ready(function () {

    var jcrop_api;
//    set instance to our var
    jQuery('#img-resize').Jcrop({
        aspectRatio: 1,
        setSelect: [50, 0, 300, 300],
        allowResize: false
    }, function () {
        jcrop_api = this;
    });

    /*
     * isModuloReduzido (Essa variavel só existe nas telas reduzidas).
     * As telas que não possuem modo reduzido, essa variavel não será criada, com isso caira no catch;
     */
    try {
        if (isModuloReduzido == 'true') {
            jQuery('li[isModuloReduzido=false]').remove();
        }
    } catch (err) {
        console.error('Este menu não utiliza modo reduzido!');
    }

    jQuery('.menu-item-link').click(function () {
        if (jQuery('.menu-item-container').css('display') === "none") {
            jQuery('.menu-item-container').show('show');
            jQuery('.seta-menu-item').show('show');
            jQuery('.seta-menu-item-sombra').show('show');
            jQuery('#cobre-tudo-menu-item').css('display', 'block');
            jQuery('#cobre-tudo-menu-item').css('background', 'rgba(255,255,255,0.1)');
        } else {
            jQuery('.menu-item-container').hide('show');
            jQuery('.seta-menu-item').hide('show');
            jQuery('.seta-menu-item-sombra').hide('show');
            jQuery('#cobre-tudo-menu-item').css('display', 'none');
        }

    });
    jQuery('#cobre-tudo-menu-item').click(function () {
        if (jQuery('.menu-item-container').css('display') === "block") {
            jQuery('.menu-item-container').hide('show');
            jQuery('.seta-menu-item').hide('show');
            jQuery('.seta-menu-item-sombra').hide('show');
            jQuery('.cobre-tudo').css('display', 'none');
        }
    });

    // INICIO funcionar no IPHONE
    // A regra: como só queremos o TOUCH e o jQuery não tem apenas TOUCH, 
    //   quando o touchend for 0, significa que ele apenas CLICOU(pelo celular) no elemento
    //   pois se ele mover o campo moved recebe 1.
    jQuery('.li-menu-principal').on('touchstart touchmove touchend', function (e) {
            if (e.type === 'touchstart') {
                    jQuery(this).data('moved', '0');
            }else if(e.type === 'touchmove'){
                    jQuery(this).data('moved', '1');
            }else if(e.type === 'touchend'){
                    if(jQuery(this).data('moved') === '0'){
                            jQuery(event.target).trigger("click");
                    }
            }
    });
    // FIM funcionar no IPHONE

    jQuery('.li-menu-principal').click(function (event) {

        var alvo = event.target.nodeName == "LI" ? event.target : jQuery(event.target).parents('LI')[0];
        console.log(alvo.className == '');
        if (jQuery(window).width() < 1273 && alvo.className.indexOf('li-menu-principal') !== -1) {
            if (jQuery(jQuery(alvo).find('.ul-sub-menu')[0]).css('opacity') == '0') {
                jQuery(jQuery(alvo).find('.ul-sub-menu')[0]).css('opacity', 1);
                jQuery(jQuery(alvo).find('.ul-sub-menu')[0]).show(250);
                //Seta
                jQuery(jQuery(alvo).find('.seta-baixo')[0]).css('border-top', '5px solid #fff');
                jQuery(jQuery(alvo).find('.seta-baixo')[0]).css('border-bottom', '3px solid transparent');
            } else {
                jQuery(jQuery(alvo).find('.ul-sub-menu')[0]).css('opacity', 0);
                jQuery(jQuery(alvo).find('.ul-sub-menu')[0]).hide(250);
                //Seta
                jQuery(jQuery(alvo).find('.seta-baixo')[0]).css('border-bottom', '5px solid #fff');
                jQuery(jQuery(alvo).find('.seta-baixo')[0]).css('border-top', '3px solid transparent');
            }
        } else if (jQuery(window).width() < 1273 && alvo.className.indexOf('li-sub-menu') !== -1) {
            if (jQuery(alvo).find('ul')[0] != undefined && jQuery(jQuery(alvo).find('ul')[0]).css('opacity') == '0') {
                jQuery(jQuery(alvo).find('ul')[0]).css('opacity', 1);
                jQuery(jQuery(alvo).find('ul')[0]).show(250);

                jQuery(jQuery(alvo).find('.seta-lado')[0]).css('border-left', '5px solid transparent');
                jQuery(jQuery(alvo).find('.seta-lado')[0]).css('border-top', '5px solid #fff');
                jQuery(jQuery(alvo).find('.seta-lado')[0]).css('border-bottom', '3px solid transparent');
            } else {

                jQuery(jQuery(alvo).find('.seta-lado')[0]).css('border-left', '7px solid rgba(160,194,228,0.5)');
                jQuery(jQuery(alvo).find('.seta-lado')[0]).css('border-top', '4px solid transparent');
                jQuery(jQuery(alvo).find('.seta-lado')[0]).css('border-bottom', '4px solid transparent');

                jQuery(jQuery(alvo).find('ul')[0]).css('opacity', 0);
                jQuery(jQuery(alvo).find('ul')[0]).hide(250);
            }
        } else if (jQuery(window).width() < 1273 && alvo.className == '') {
            if (jQuery(alvo).find('ul')[0] != undefined && jQuery(jQuery(alvo).find('ul')[0]).css('opacity') == '0') {
                jQuery(jQuery(alvo).find('ul')[0]).css('opacity', 1);
                jQuery(jQuery(alvo).find('ul')[0]).show(250);

                jQuery(jQuery(alvo).find('.seta-lado')[0]).css('border-left', '5px solid transparent');
                jQuery(jQuery(alvo).find('.seta-lado')[0]).css('border-top', '5px solid #fff');
                jQuery(jQuery(alvo).find('.seta-lado')[0]).css('border-bottom', '3px solid transparent');
            } else {
                jQuery(jQuery(alvo).find('ul')[0]).css('opacity', 0);
                jQuery(jQuery(alvo).find('ul')[0]).hide(250);

                jQuery(jQuery(alvo).find('.seta-lado')[0]).css('border-left', '7px solid rgba(160,194,228,0.5)');
                jQuery(jQuery(alvo).find('.seta-lado')[0]).css('border-top', '4px solid transparent');
                jQuery(jQuery(alvo).find('.seta-lado')[0]).css('border-bottom', '4px solid transparent');
            }
        }
    });
    //Click para abrir modulos no scree tablet-mobile
    jQuery('.ul-mod').click(function (event) {
        if (jQuery(window).width() <= 985 && jQuery(window).width() > 409) {
            var alvo = event.target.nodeName == "UL" ? event.target : jQuery(event.target).parents('UL')[0];
            if (jQuery(alvo).css('max-height') == '85px') {
                jQuery(alvo).animate({
                    'max-height': '600px'
                }, 500);
                jQuery(alvo).css('background', '#fff');
                jQuery(alvo).css('box-shadow', '0px 0px 5px 0px rgba(0,0,0,0.75)');
            } else {
                jQuery(alvo).animate({
                    'max-height': '85px'
                }, 500, function () {
                    jQuery(alvo).css('background', 'transparent');
                    jQuery(alvo).css('box-shadow', 'none');
                });
            }
        }
    });
    jQuery('.menu-mobile').click(function () {
        if (jQuery('.container-menu-mobile').css('width') == '0px') {
            jQuery('.container-menu-mobile').animate({
                'width': '90%'
            }, 300, function () {
                jQuery('.menu-mobile').css('background', 'transparent url("assets/img/block-menu-mobile-white.png") no-repeat center center');
                jQuery('.container-menu-mobile div').show();
                jQuery('.perfil-user').show();
                jQuery('.ul-mod-mobile').show();
            });
        } else {
            jQuery('.container-menu-mobile div').hide();
            jQuery('.perfil-user').hide();
            jQuery('.ul-mod-mobile').hide();
            jQuery('.container-menu-mobile').animate({
                'width': '0%'
            }, 300, function () {
                jQuery('.menu-mobile').css('background', 'transparent url("assets/img/block-menu-mobile.png") no-repeat center center');
            });
        }
    });
    jQuery('.container-botoes > ul > li').hover(
            function () {
                if (jQuery(window).width() > 1273 && jQuery(this).css('margin-left') == '245px') {
                    jQuery(this).find('.botoes-label').show();
                    jQuery(this).animate({
                        'margin-left': '0px'
                    }, 250, function () {
                    });
                }
            },
            function () {
                if (jQuery(window).width() > 1273) {
                    jQuery(this).find('.botoes-label').hide();
                    jQuery(this).animate({
                        'margin-left': '245px'
                    }, 250, function () {
                    });
                }
            }
    );
    jQuery('.container-botoes > ul > li').click(function () {
        if (jQuery(window).width() < 1273) {
            if (jQuery(this).find('.botoes-label').css('display') == 'none') {
                jQuery(this).find('.botoes-label').show();
                jQuery(this).animate({
                    'margin-left': '0px'
                }, 250, function () {
                });
            } else {
                jQuery(this).find('.botoes-label').hide();
                jQuery(this).animate({
                    'margin-left': '245px'
                }, 250, function () {
                });
            }
        }
    });
    /*
     * VALIDACOES DE IMAGEM DO PERFIL
     * 
     */


    /*
     * FIM VALIDACAO
     */

    jQuery(".menu-sem-acesso").hover(
            function (event) {
                if (jQuery(window).width() > 1260) {
                    var top = jQuery(this).offset().top + 'px';
                    var left = jQuery(this).offset().left + jQuery(this).width() + 20 + 'px';
                    jQuery('.tool-sem-acesso').css('top', top);
                    jQuery('.tool-sem-acesso').css('left', left);
                    jQuery('.tool-sem-acesso').show();
                    jQuery('.tool-sem-acesso span').show();
                }
            },
            function () {
                if (jQuery(window).width() > 1260) {
                    jQuery('.tool-sem-acesso').hide();
                    jQuery('.tool-sem-acesso span').hide();
                }
            }
    );

    jQuery('#consulta-anexar-imagem').on('click', function(e) {
        if (jQuery(this).attr('data-tem-permissao') !== 'true') {
            e.preventDefault();
            e.stopImmediatePropagation();

            chamarAlert('Você não possui licença de uso para usar essa funcionalidade, se tiver interesse em contratar favor enviar e-mail para comercial@gwsistemas.com.br ou ligar para 81 2125-3752');
        }
    });

    jQuery('.menu-sem-acesso').click(function () {
        var texto = "Você não tem privilégios suficientes para executar essa ação. Para acessar essa rotina você deverá solicitar a permissão '" + jQuery(this).attr('codigoPermissao') + "' ao usuário administrador de sua empresa";
        chamarAlert(texto);
    });

    jQuery('.li-botoes-desconectar').click(function (e) {
        e.preventDefault();

        // example of calling the desconectar function
        // you must use a callback function to perform the "yes" action
        chamarConfirm("Deseja mesmo sair ?", 'efetuarLogOff();');

    });

    jQuery('.reload-pendencias').click(function (event) {
        recarregarPendencias();
    });

    jQuery('.pendencias-topo').click(function (event) {
        //Usado pra so funcionar se nao clicar no recarregar;
        if (event.target.nodeName == "IMG") {
            return false;
        }

        jQuery('.pendencias-corpo').slideToggle(250);
        setTimeout(function () {
            if (jQuery('.pendencias-corpo').css('display') == 'block') {
                jQuery('.lb-pendencias').html(jQuery('.lb-pendencias').html().replace('Mostrar', 'Ocultar'));
            } else {
                jQuery('.lb-pendencias').html(jQuery('.lb-pendencias').html().replace('Ocultar', 'Mostrar'));
            }
        }, 300);
    });

    jQuery('.corpo-b > ul > li').click(function (event) {
        if (jQuery(event.target).attr('id') != undefined) {
            return false;
        }
        jQuery(this).find('ul').slideToggle(250);
    });

    jQuery('.quadro-avisos-topo').click(function () {
        if (jQuery('.quadro-avisos-conteudo').css('display') == 'block') {
            jQuery('.quadro-avisos-topo span').css('-webkit-transform', 'rotate(180deg)');
            jQuery('.quadro-avisos-topo span').css('transform', 'rotate(180deg)');
            jQuery('.quadro-avisos-conteudo').hide(250);
        } else {
            jQuery('.quadro-avisos-topo span').css('-webkit-transform', 'rotate(0deg)');
            jQuery('.quadro-avisos-topo span').css('transform', 'rotate(0deg)');
            jQuery('.quadro-avisos-conteudo').show(250);
        }
    });

    jQuery('.h-a-logos a span').first().click(function () {
        window.open("./UsuarioControlador?acao=redirecionaProjeto&modulo=inicio", "", "width=400,height=300");
    });



    if (jQuery('span[nomeLogoCliente]').attr('nomeLogoCliente') != '') {
        var nomeLogo = jQuery('span[nomeLogoCliente]').attr('nomeLogoCliente');
        jQuery('span[nomeLogoCliente]').css('background', '#fff url(img/logoCliente/' + nomeLogo + ') no-repeat center center');
        jQuery('span[nomeLogoCliente]').css('background-size', '90px');
        jQuery('span[nomeLogoCliente]').attr('onerror', 'ImgError(this)');
    } else {
        jQuery('span[nomeLogoCliente]').hide();
        jQuery('.config-logo').show();
    }

    jQuery('.abrir-impressao-boleto').click(function () {
        jQuery('.cobre-tudo').css('background', 'rgba(0,0,0,1)');
        jQuery('.cobre-tudo').css('opacity', '0.5');
        jQuery('.cobre-tudo').show(250, function () {
            jQuery('.container-iframe-boletos').css('visibility', 'visible');
        });
    });
    jQuery('.fechar-iframe-boletos').click(function () {
        jQuery('.cobre-tudo').css('background', '');
        jQuery('.cobre-tudo').css('opacity', '');
        jQuery('.container-iframe-boletos').css('visibility', 'hidden');
        jQuery('.cobre-tudo').hide();
    });
    
    jQuery('#faleComSofia').on('click', function (e) {
        e.preventDefault();
        e.stopImmediatePropagation();

        var botaoSofia = jQuery('#blip-chat-open-iframe');
        
        if (!botaoSofia.hasClass('opened')) {
            botaoSofia.click();
        }
    });
    
    const listaComunicadosUl = jQuery('#lista-comunicados');

    // Carregar os comunidados
    jQuery.get(homePath + '/AnuncioControlador', {
        'acao': 'buscarAnuncios',
        'codTela': '4'
    }, function(data) { 
        if (data) {
            jQuery.each(data, function (index, elemento) {
                listaComunicadosUl.append(
                    jQuery('<li>', {
                        'class': 'li-sub-menu link-anuncio', 
                        'data-link-comunicado': elemento['local_arquivo_html']
                    }).append(jQuery('<div>', {'class': 'container-label-menu'}).text(elemento['descricao_anuncio']))
                )
            });

            listaComunicadosUl.append(
                jQuery('<li>', {
                    'class': 'li-sub-menu ver-todos-anuncios'
                }).append(jQuery('<div>', {'class': 'container-label-menu'}).text('Ver todos'))
            )
        }
    }, 'json');
    
    listaComunicadosUl.on('click', '.link-anuncio', function () {
        chamarAnuncio(jQuery(this).attr('data-link-comunicado'));
    }).on('click', '.ver-todos-anuncios', function () {
        checkSession(function () {
            let pop = window.open(homePath + '/ConsultaControlador?codTela=134', 'comunicado_listar_gwtrans', 'width=' + screen.width + ',height=' + screen.height + ",scrollbars=yes,top=0,left=0,resizable=yes");

            if (!pop) {
                chamarAlert('O Pop-up do seu navegador está bloqueado, para abrir está tela é necessário desbloquea-lo.')
            }
        }, true);
    });
    
    if (certificadoAtualizado === 'false') {
        chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');
    }
});


(function (i, s, o, g, r, a, m) {
    i['GoogleAnalyticsObject'] = r;
    i[r] = i[r] || function () {
        (i[r].q = i[r].q || []).push(arguments)
    }, i[r].l = 1 * new Date();
    a = s.createElement(o),
            m = s.getElementsByTagName(o)[0];
    a.async = 1;
    a.src = g;
    m.parentNode.insertBefore(a, m)
})(window, document, 'script', 'https://www.google-analytics.com/analytics.js', 'ga');
ga('create', 'UA-86105277-1', 'auto');
ga('send', 'pageview');

function openInNewTab(url) {
    var win = window.open(url, '_blank');
    win.focus();
}

function gerarSetarImagemPerfil(isGerarImagem, userId, imagemId) {
    if (isGerarImagem === 'true') {
        jQuery.ajax({
            url: 'UsuarioControlador?acao=gerarImagemPerfil&idUsuario=' + userId + '&idImagemPerfil=' + imagemId,
            dataType: "text",
            method: "post",
            complete: function (e, a) {
                if (e.responseText == 1) {
                    jQuery('#img-perfil').prop('src', homePath + '/img/usuario/default-perfil.png');
                    jQuery('#icon-perfil').prop('src', homePath + '/img/usuario/default-perfil.png');
                    jQuery('#icon-perfil').css("width", "60px");
                    jQuery('#icon-perfil').css("height", "60px");
                    jQuery('#img-perfil').css("width", "90px");
                    jQuery('#img-perfil').css("height", "90px");
                } else {
                    jQuery('#icon-perfil').prop('src', homePath + '/img/usuario/usuario' + userId + '/perfil_usuario_' + userId + '_' + imagemId + '.png');
                    jQuery('#icon-perfil').css("width", "75px");
                    jQuery('#icon-perfil').css("height", "75px");
                    jQuery('#img-perfil').prop('src', homePath + '/img/usuario/usuario' + userId + '/perfil_usuario_' + userId + '_' + imagemId + '.png');
                    jQuery('#img-perfil').css("width", "100px");
                    jQuery('#img-perfil').css("height", "100px");
                }
            }
        });
    } else {

        jQuery('#icon-perfil').prop('src', homePath + '/img/usuario/usuario' + userId + '/perfil_usuario_' + userId + '_' + imagemId + '.png');
        jQuery('#img-perfil').prop('src', homePath + '/img/usuario/usuario' + userId + '/perfil_usuario_' + userId + '_' + imagemId + '.png');
        jQuery('#icon-perfil').css("width", "75px");
        jQuery('#icon-perfil').css("height", "75px");
        jQuery('#img-perfil').css("width", "100px");
        jQuery('#img-perfil').css("height", "100px");
    }
}


function efetuarLogOff() {
    location.replace("UsuarioControlador?acao=logoff");
}

function desconectar(message, callback) {
    $('#desconectar').modal({
        closeHTML: "<a href='#' title='Close' class='modal-close'>x</a>",
        position: ["20%", ],
        overlayId: 'desconectar-overlay',
        containerId: 'desconectar-container',
        onShow: function (dialog) {
            var modal = this;

            $('.message', dialog.data[0]).append(message);

            // if the user clicks "yes"
            $('.yes', dialog.data[0]).click(function () {
                // call the callback
                if ($.isFunction(callback)) {
                    callback.apply();
                }
                // close the dialog
                modal.close(); // or $.modal.close();
            });
        }
    });
}

function recarregarPendencias() {
    jQuery('.reload-pendencias').attr('src', 'img/espere.gif');
    jQuery.ajax({
        url: 'UsuarioControlador?acao=recarregarPendencias',
        dataType: "text",
        method: "post",
        async: true,
        data: {
        },
        success: function (ret) {

            // EXEMPLO de retorno
            //{"cteNegado":35,"ctePendente":157,"cteContingencia":0,"mdfeNegado":690,"mdfePendente":5717,"tabelaVender":0,"tabelaVencida":10}
            var data = jQuery.parseJSON(ret);

            // somatorios:
            var ctes = data.cteNegado + data.ctePendente + data.cteContingencia + data.cteEnvioFtp;
            var mdfes = data.mdfeNegado + data.mdfePendente + data.MDFESemEncerramento
                + data.qtdMDFeConfirmadoSemAverbar + data.qtdMDFeCanceladosSemAverbar + data.qtdMDFeEncerradosSemAverbar + data.qtdMDFeCondutorAdicionaisSemAverbar;
            var tabelas = data.tabelaVencida + data.tabelaVencer;
            var totais = ctes + mdfes + tabelas;

            jQuery("#ctesNegadosMaior").text("(" + data.cteNegado + ")");
            jQuery("#ctesPendentesMaior").text("(" + data.ctePendente + ")");
            jQuery("#cteContingenciaMaior").text("(" + data.cteContingencia + ")");
            jQuery("#cteEnvioXMLFTP").text("(" + data.cteEnvioFtp + ")");
            jQuery("#mdfeNegadoMaior").text("(" + data.mdfeNegado + ")");
            jQuery("#mdfePendenteMaior").text("(" + data.mdfePendente + ")");
            jQuery("#tabelaPrecoVencidaMaior").text("(" + data.tabelaVencida + ")");
            jQuery("#tabelaprecovencerMaior").text("(" + data.tabelaVencer + ")");

            jQuery("#qtdMDFeConfirmadoSemAverbar").text("(" + data.qtdMDFeConfirmadoSemAverbar + ")");
            jQuery("#qtdMDFeCanceladosSemAverbar").text("(" + data.qtdMDFeCanceladosSemAverbar + ")");
            jQuery("#qtdMDFeEncerradosSemAverbar").text("(" + data.qtdMDFeEncerradosSemAverbar + ")");
            jQuery("#qtdMDFeCondutorAdicionaisSemAverbar").text("(" + data.qtdMDFeCondutorAdicionaisSemAverbar + ")");

            jQuery("#total-cte").text("(" + ctes + ")");
            jQuery("#total-mdfe").text("(" + mdfes + ")");
            jQuery("#total-tabela-preco").text("(" + tabelas + ")");

            jQuery(".span-qtd-pendencias").text("(" + totais + ")");
            jQuery("#total-dias-mdfe").text("(" + data.mdfeNaoEncerrado + ")");
            jQuery("#total-mdfe-nao-encerrados").text("(" + data.MDFESemEncerramento + ")");
        },
        complete: function (jqXHR, textStatus) {
            jQuery('.reload-pendencias').attr('src', 'assets/img/icones/reload.png');
        }
    });
}

function salvarImagemPerfil() {
    var form = $('#formImg');

    var x = document.getElementById("x").value;
    var x2 = document.getElementById("x2").value;
    var y = document.getElementById("y").value;
    var y2 = document.getElementById("y2").value;
    var w = document.getElementById("w").value;
    var h = document.getElementById("h").value;

    if (document.getElementById('input-perfil-upload').files.length === 0) {
        chamarAlert('Selecione uma imagem');
        return false;
    }

    form.attr("action", "UsuarioControlador?acao=alterarImagemPerfil&x=" + x + "&y=" + y + "&w=" + w + "&h=" + h + "&x2=" + x2 + "&y2=" + y2);
    form.submit();
}

function reloadMenu() {
    window.location.reload();
}

function abrirGerenciadorGWi(linkGWi, tokenGWi, cnpjFiliais, podeAcessarGWi) {    
    if (linkGWi === undefined || linkGWi === '') {
        chamarAlert("O link do GW-i é inválido!");
        
        return false;
    }

    if (tokenGWi === undefined || tokenGWi === null || tokenGWi === '') {
        chamarAlert("A filial em que você é responsável não tem acesso ao GW-i.");
        
        return false;
    }
    
    if (podeAcessarGWi === undefined || podeAcessarGWi === null || podeAcessarGWi === '' || podeAcessarGWi === 'false') {
        chamarAlert("Você não tem permissão para acessar o GW-i.");
        
        return false;
    }
    
    window.open(linkGWi + '/login/' + btoa(tokenGWi + '\0' + cnpjFiliais.replace(/\./g, '').replace(/\//g, '').replace(/ /g, '').replace(/-/g, '').replace(/,/g, '\0')));
}

function usuarioAceitouAtualizarCertificado() {
    $('.bloqueio-tela').show();
    $('.gif-bloq-tela').show();

    jQuery.post(`${homePath}/CertificadoDigitalMigracaoControlador`, {'acao': 'migrar'}, function retornoAjaxAtualizarCertificados(data) {
        $('.bloqueio-tela').hide();
        $('.gif-bloq-tela').hide();

        chamarAlert(data['mensagem'], function () {
            if (data['mensagem'].indexOf('Erro') === -1) {
                efetuarLogOff();
            }
        });
    }, 'json');
}

function usuarioNaoAceitouAtualizarCertificado() {
    chamarAlert('O envio dos documentos fiscais não irão funcionar até que essa atualização seja feita.');
}