//------------ Trouxe algumas funcoes da tela de consulta evitando que a tela quebre futuramente por excesso de byte

var dtDe;
var dtAte;


jQuery(document).ready(function () {

    jQuery('#inpSelectVal').inputMultiploGw({
        width: '96.5%',
        readOnly: 'false',
        callBack: function () {
//            console.trace();
//            jQuery("#search").click();
        }
    });

    jQuery('#inptSerie').inputMultiploGw({
        width: '96.5%',
        readOnly: 'false'
    });

    jQuery('#inptCidade').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptGrupoCliente').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptVendedor').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery(jQuery('input[name="inptSupervisor"]')).inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#filtros-adicionais').click(function () {
        var divToogle = jQuery('#filtros-adicionais-container');

        if (divToogle.is(":visible")) {
            divToogle.hide(250, function () {
                atualizarSelect();
            });
            jQuery(".seta-exibir-filtros-adicionais").css('transform', '');
            jQuery("#toogle_options_details").html("Exibir filtros adicionais");
        } else {
            divToogle.show(250, function () {
                atualizarSelect();
            });
            jQuery(".seta-exibir-filtros-adicionais").css('transform', 'rotate(180deg)');
            jQuery("#toogle_options_details").html("Ocultar filtros adicionais");
        }
    });


    jQuery(".footerTable input[type='radio']").click(function () {
        if (jQuery(this).is(':checked')) {
            jQuery(".footerTable input[type='radio']").parent().css("color", "#a9aeb3");
            jQuery(this).parent().css("color", "#13385c");
        }
    });


    jQuery('.textbox-text').mask('00/00/0000');

    if (document.getElementById('dataDe') !== null) {

        dtDe = jQuery('#dataDe').datebox({
            disabled: true,
            formatter: function (date) {
                var y = date.getFullYear();
                var m = date.getMonth() + 1;
                var d = date.getDate();
                return (d < 10 ? ('0' + d) : d) + '/' + (m < 10 ? ('0' + m) : m) + '/' + y;
            },
            parser: function (s) {

                if (!s)
                    return new Date();
                var ss = s.split('/');
                var y = parseInt(ss[2], 10);
                var m = parseInt(ss[1], 10);
                var d = parseInt(ss[0], 10);
                if (!isNaN(y) && !isNaN(m) && !isNaN(d)) {
                    return new Date(y, m - 1, d);
                } else {
                    return new Date();
                }
            }
        });

        dtAte = jQuery('#dataAte').datebox({
            disabled: true,
            formatter: function (date) {
                var y = date.getFullYear();
                var m = date.getMonth() + 1;
                var d = date.getDate();
                return (d < 10 ? ('0' + d) : d) + '/' + (m < 10 ? ('0' + m) : m) + '/' + y;
            },
            parser: function (s) {

                if (!s)
                    return new Date();
                var ss = s.split('/');
                var y = parseInt(ss[2], 10);
                var m = parseInt(ss[1], 10);
                var d = parseInt(ss[0], 10);
                if (!isNaN(y) && !isNaN(m) && !isNaN(d)) {
                    return new Date(y, m - 1, d);
                } else {
                    return new Date();
                }
            }
        });

    }


    jQuery('.item_form_half1').find(".textbox-text").attr("placeholder", "Início");
    jQuery('.item_form_half2').find(".textbox-text").attr("placeholder", "Término");



    jQuery(".container-video").click(function () {
//                    jQuery(" iframe").css("width","100%");
        var iframe = jQuery(jQuery(this).context.firstElementChild);
        var texto = jQuery(jQuery(this).context.firstChild);

        var iframes = jQuery(".container-video iframe");
        jQuery(iframes).css("width", "45%");
        jQuery(iframes).css("height", "100px");

        jQuery("#video1")[0].contentWindow.postMessage('{"event":"command","func":"' + 'stopVideo' + '","args":""}', '*');
        jQuery("#video2")[0].contentWindow.postMessage('{"event":"command","func":"' + 'stopVideo' + '","args":""}', '*');

        jQuery(this).hover(function () {
            jQuery(this).css("transform", "scale(1.00)");
        });

        jQuery(iframe).css("width", "95%");
        jQuery(iframe).css("width", "95%");
        jQuery(iframe).css("height", "300px");
        jQuery(iframe)[0].src += "&autoplay=1";
    });

    ativarMascaraCampoData();

    jQuery('.img-menu-coleta').click(function (e) {
        jQuery('.container-menu-coleta').hide();
//        jQuery(this).parent().find('nav').fadeToggle("fast");
        
        var trPositionTop = $(this).parents('tr').position().top;
        var nav = jQuery(this).parent().find('nav');

        nav.css('top', (e.pageY - 57));

        if (nav.height() > (window.heightDoc - (trPositionTop + 80))) {
            nav.css('margin-top', '-350px');
        }
        nav.fadeToggle("fast");
    });
    jQuery(document).click(function (e) {
        var alvo = e.target.nodeName == "LI" ? e.target : jQuery(e.target).parents('LI')[0];
        if (jQuery(e.target).attr('class') != 'img-menu-coleta' && alvo === undefined) {
            var i = 0;
            while (jQuery('.container-menu-coleta')[i] !== undefined) {
                if (jQuery(jQuery('.container-menu-coleta')[i]).css('display') == "block") {
                    jQuery(jQuery('.container-menu-coleta')[i]).fadeToggle('fast');
                }
                i++;
            }
        }
    });

    jQuery("form").submit(function (event) {
        jQuery('#progress-preferencias').hide();
        jQuery('#progress-porcentagem').hide();

        jQuery('.load-preferencias').show();
        jQuery(this).find('.searchButton').attr('disabled', true);
    });

    jQuery('#salvarFiltros').click(function () {
        jQuery('.salvarPesquisaContainer').trigger('click');
    });

    jQuery('#formConsulta').on('paste', '.delta-input', function (e) {
        e.preventDefault();

        // Pegar o texto e cortar em novas linhas
        let data = e.originalEvent.clipboardData.getData('Text');
        let inputId = jQuery(this).parent().parent().parent().parent().find('input[type="hidden"]').attr('id');

        data.split(/\r?\n/).forEach(value => addValorAlphaInput(inputId, value));
    });
});

function ativarMascaraCampoData() {
    setTimeout(function () {
        if (document.getElementById('dataDe') !== null) {
            jQuery('#dataDe').datebox('textbox').bind('focusout', function (e) {
                completarData(this, e, 'dataDe');
            });

            jQuery('#dataAte').datebox('textbox').bind('focusout', function (e) {
                completarData(this, e, 'dataAte');
            });
        }
    }, 1000);
}

function changeSelectAbrev() {
    var selected = jQuery("#select-abrev option:selected").text();

    if (
            selected.includes("Data Inclusão") || selected.includes("Data Última Alteração") ||
            selected.includes("Data Criação") || selected.includes("Data Última Alteração") ||
            selected.includes("Data Solicitação") || selected.includes("Data Previsão") ||
            selected.includes("Data Program.") || selected.includes("Data Coleta") ||
            selected.includes("Data") || selected.includes("Prev. Chegada") ||
            selected.includes("Data Envio") || selected.includes("Emissão") ||
            selected.includes("Prev. Embarque") || selected.includes("Saída Manifesto") ||
            selected.includes("Validade") ||
            selected.includes("Prev. Embarque") || selected.includes("Saída Manifesto") ||
            selected.includes('Inicio') || selected.includes('Fim')
            ) {
        jQuery('.container-campos-select').hide(250, function () {
            jQuery('.container-data').show(250);
            jQuery('#select-oper-button').parent().hide(250);
            jQuery(dtDe).datebox({disabled: false});
            jQuery(dtAte).datebox({disabled: false});
            jQuery('.datebox').css('width', '93%');
            jQuery('.textbox-text').css('width', '93%');
            jQuery('.textbox-text').css('font-size', '14px');
            ativarMascaraCampoData();
        });
    } else {
        jQuery(dtDe).datebox({disabled: true});
        jQuery(dtAte).datebox({disabled: true});
        jQuery('.container-data').hide(250, function () {
            jQuery('#select-oper-button').parent().show(250);
            jQuery('.container-campos-select').show(250);
        });
    }
}


//-----------------------------------------------

function refreshSelected() {
    var selected = jQuery("#select-abrev option:selected").text();
    jQuery("#spanSelect").text(selected);
//                jQuery("#inpSelectVal").attr("placeholder", jQuery("#labDescSelect").text());
}

var elementoFoco;
jQuery("#select-ordenacao").selectmenu({
    open: function (event, ui) {
        elementoFoco = event.currentTarget;
        jQuery(elementoFoco).css("z-index", '999999');
        jQuery('.cobre-left').fadeTo("slow", 0.6);
    },
    close: function (event, ui) {
        jQuery(elementoFoco).css("z-index", '99');
        jQuery('.cobre-left').fadeTo("fast", 0.0, function () {
            jQuery('.cobre-left').css("display", "none");
        });
    }

}).selectmenu("menuWidget").addClass("selects-ui");

jQuery("#cbmodelo").selectmenu({
    change: function () {
    },
    open: function (event, ui) {
    },
    close: function (event, ui) {
    }
}).selectmenu("option", "position", {my: "top+15", at: "top center"}).selectmenu("menuWidget").addClass("selects-ui");

jQuery("#impressora").selectmenu({
    change: function () {
    },
    open: function (event, ui) {
    },
    close: function (event, ui) {
    }
}).selectmenu("option", "position", {my: "top+15", at: "top center"}).selectmenu("menuWidget").addClass("selects-ui");

jQuery("#caminho_impressora").selectmenu({
    change: function () {
    },
    open: function (event, ui) {
    },
    close: function (event, ui) {
    }
}).selectmenu("option", "position", {my: "top+15", at: "top center"}).selectmenu("menuWidget").addClass("selects-ui");

jQuery("#driverImpressora").selectmenu({
    change: function () {
    },
    open: function (event, ui) {
    },
    close: function (event, ui) {
    }
}).selectmenu("option", "position", {my: "top+15", at: "top center"}).selectmenu("menuWidget").addClass("selects-ui");

jQuery("#exportarPara").selectmenu({
    change: function () {
    },
    open: function (event, ui) {
    },
    close: function (event, ui) {
    }
}).selectmenu("option", "position", {my: "top+15", at: "top center"}).selectmenu("menuWidget").addClass("selects-ui");

jQuery("#select-abrev").selectmenu({
    change: function () {
        refreshSelected();
        changeSelectAbrev();
    },
    open: function (event, ui) {
        elementoFoco = event.currentTarget;
        jQuery(elementoFoco).css("z-index", '999999');
        jQuery('.cobre-left').fadeTo("slow", 0.6);
    },
    close: function (event, ui) {
        jQuery(elementoFoco).css("z-index", '99');
        jQuery('.cobre-left').fadeTo("fast", 0.0, function () {
            jQuery('.cobre-left').css("display", "none");
        });
    }
}).selectmenu("menuWidget").addClass("selects-ui");

jQuery("#select-order-tipo").selectmenu({
    open: function (event, ui) {
        elementoFoco = event.currentTarget;
        jQuery(elementoFoco).css("z-index", '999999');
        jQuery('.cobre-left').fadeTo("slow", 0.6);
    },
    close: function (event, ui) {
        jQuery(elementoFoco).css("z-index", '99');
        jQuery('.cobre-left').fadeTo("fast", 0.0, function () {
            jQuery('.cobre-left').css("display", "none");
        });
    }
}).selectmenu("menuWidget").addClass("selects-ui");

jQuery("#select-oper").selectmenu({
    open: function (event, ui) {
        elementoFoco = event.currentTarget;
        jQuery(elementoFoco).css("z-index", '999999');
        jQuery('.cobre-left').fadeTo("slow", 0.6);
    },
    close: function (event, ui) {
        jQuery(elementoFoco).css("z-index", '99');
        jQuery('.cobre-left').fadeTo("fast", 0.0, function () {
            jQuery('.cobre-left').css("display", "none");
        });
    }
}).selectmenu("menuWidget").addClass("selects-ui");

jQuery("#select-limite").selectmenu({
    open: function (event, ui) {
        elementoFoco = event.currentTarget;
        jQuery(elementoFoco).css("z-index", '999999');
        jQuery('.cobre-left').fadeTo("slow", 0.6);
    },
    close: function (event, ui) {
        jQuery(elementoFoco).css("z-index", '99');
        jQuery('.cobre-left').fadeTo("fast", 0.0, function () {
            jQuery('.cobre-left').css("display", "none");
        });
    }
}).selectmenu("menuWidget").addClass("selects-ui");

jQuery("#select-pesquisa").selectmenu({
    change: function () {
        alerarFiltroPesquisa();
    },
    open: function (event, ui) {
        elementoFoco = event.currentTarget;
        jQuery(elementoFoco).css("z-index", '999999');
        jQuery('.cobre-left').fadeTo("slow", 0.6);
    },
    close: function (event, ui) {
        jQuery(elementoFoco).css("z-index", '99');
        jQuery('.cobre-left').fadeTo("fast", 0.0, function () {
            jQuery('.cobre-left').css("display", "none");
        });
    }
}).selectmenu("menuWidget").addClass("selects-ui");

jQuery("#select-filial").selectmenu({
    open: function (event, ui) {
        elementoFoco = event.currentTarget;
        jQuery(elementoFoco).css("z-index", '999999');
        jQuery('.cobre-left').fadeTo("slow", 0.6);
    },
    close: function (event, ui) {
        jQuery(elementoFoco).css("z-index", '99');
        jQuery('.cobre-left').fadeTo("fast", 0.0, function () {
            jQuery('.cobre-left').css("display", "none");
        });
    }
}).selectmenu("menuWidget").addClass("selects-ui");

refreshSelected();

function completarData(ob, ev, elemento) {
    var tecla = (window.event ? event.keyCode : ev.which);

    var data = new Date();
    var dia = data.getDate();
    var mes = data.getMonth() + 1;
    var ano = data.getFullYear();

    if (ob && ob.value) {
        var valor = ob.value.match(/\/|[0-9]/g).join("");

        if (valor.length === 1) {
            ob.value = '0' + ob.value + '/' + (mes < 10 ? ('0' + mes) : mes) + '/' + ano;
        }

        if (valor.length === 2) {
            ob.value = ob.value + '/' + (mes < 10 ? ('0' + mes) : mes) + '/' + ano;
        }

        if (valor.length === 4) {
            var dia = valor.split("/")[0];
            var mes = valor.split("/")[1];
            ob.value = dia + '/0' + mes + '/' + ano;
        }

        if (valor.length > 4 && valor.length < 7) {
            if (valor.length === 6) {
                ob.value = ob.value + ano;
            } else {
                ob.value = ob.value + '/' + ano;
            }
        }

        if (elemento == 'dataDe') {
            jQuery('#dataDe').datebox('setValue', ob.value);
        } else if (elemento == 'dataAte') {
            jQuery('#dataAte').datebox('setValue', ob.value);
        }

    }


    if (!validaData(ob.value)) {
        chamarAlert('A data "' + ob.value + '" é inválida.');
        ob.value = (dia < 10 ? ('0' + dia) : dia) + '/' + (mes < 10 ? ('0' + mes) : mes) + '/' + ano;
        setarFoco(ob);
    }
}

function validaData(data) {
    barras = data.split("/");

    if (barras.length == 3) {
        var dia = barras[0];
        var mes = barras[1];
        var ano = barras[2];
        if (ano.length == 2) {
            if (ano >= 50 && ano <= 99)
                ano = "19" + ano;
            else
                ano = "20" + ano;
        }

        //Verificando se o dia e o mês é válido
        if ((mes < 1 || mes > 12) || (dia < 1 || dia > 31))
            return false;
        //Verificando se o dia está correto para os meses com 30 dias
        else if ((mes == 4 || mes == 6 || mes == 9 || mes == 11) && dia == 31)
            return false;
        //Verificando se o dia foi digitado corretamente para o mês 02
        else if (mes == 2 && dia > 29)
            return false;
        //Verificando a qtd de dígitos do ano
        else if (ano.length != 2 && ano.length != 4)
            return false;
        else
            return true;
    } else {
        return false;
    }
}

function completarCompetencia(ob, ev, elemento) {
    var tecla = (window.event ? event.keyCode : ev.which);

    var data = new Date();
    var mes = data.getMonth() + 1;
    var ano = data.getFullYear();

    if (ob && ob.value) {
        var valor = ob.value.match(/\/|[0-9]/g).join("");

        if (valor.length === 1) {
            ob.value = ('0' + ob.value) + '/' + ano;
        }

        if (valor.length === 2) {
            ob.value = ob.value + '/' + ano;
        }

        if (valor.length === 4) {
            var mes = valor.split("/")[0];
            ob.value = mes + '/' + ano;
        }

        if (elemento == 'competenciaDe') {
            jQuery('#competenciaDe').val(ob.value);
        } else if (elemento == 'competenciaAte') {
            jQuery('#competenciaAte').val(ob.value);
        }
    }

    if (!validaCompetencia(ob.value)) {
        chamarAlert('A competência "' + ob.value + '" é inválida.');
        ob.value = (mes < 10 ? ('0' + mes) : mes) + '/' + ano;
        setarFoco(ob);
    }
}

function validaCompetencia(data) {
    barras = data.split("/");

    if (barras.length == 2) {
        var mes = barras[0];
        var ano = barras[1];
        if (ano.length == 2) {
            if (ano >= 50 && ano <= 99)
                ano = "19" + ano;
            else
                ano = "20" + ano;
        }

        //Verificando se o dia e o mês é válido
        if (mes < 1 || mes > 12)
            return false;
        //Verificando a qtd de dígitos do ano
        else if (ano.length != 2 && ano.length != 4)
            return false;
        else
            return true;
    } else {
        return false;
    }
}

function mascaraCompetencia(competencia) {
    var no_alert_if_blank = (arguments.length > 1 && arguments[1] == true)
    var mes = (competencia.value.substring(0, 2));
    var ano = (competencia.value.substring(3, 7));
    var ponto = '';

    competencia.maxLength = "7";
    if (mes.length == 2) {
        ponto = "/";
    }
    competencia.value = mes + ponto + ano;

    if (!no_alert_if_blank && competencia.onblur == undefined) {
        validaCompetencia(competencia.value);
    }
}

function btnCadastrar(url) {
    location.replace(url);
}

function abrirPopConsulta(url) {
    window.open(url, '_blank', 'toolbar=no,scrollbars=yes,scrollbars=yes,resizable=yes,top=200,left=500,left=0,width=800,height=600');
}

function salvarPreferencias() {
    var json = getJsonPreferencias();
    jQuery.ajax({
        dataType: 'json',
        method: 'POST',
        url: 'ConsultaControlador?acao=salvarPreferencias&codigoTela=' + codigo_tela,
        data: {'json': json},
        sucess: function () {}
    });

}

var saveTimeOut;
var tempoEspera = 4000;

function monitorarPreferenciaUsuario() {
    if (saveTimeOut !== null && saveTimeOut !== undefined) {
        clearTimeout(saveTimeOut);
    }
    saveTimeOut = setTimeout(function () {
        salvarPreferencias();
    }, tempoEspera);
}

function getJsonPreferencias() {
    var index = 0;
    var ths = jQuery('.pode-setar-ordem');
    var jsonValores = {};
    while (ths[index] !== null && ths[index] !== undefined) {
        var obj = {
            nome_coluna: jQuery(jQuery('.pode-setar-ordem')[index]).attr('nome'),
            largura_coluna: jQuery(jQuery('.pode-setar-ordem')[index]).width() + 'px',
            ordem_coluna: jQuery(jQuery('.pode-setar-ordem')[index]).attr('ordem'),
            excluir_coluna: (jQuery(jQuery('.pode-setar-ordem')[index]).attr('oculta') !== undefined ? 'true' : 'false'),
            is_fixo: (jQuery(jQuery('.pode-setar-ordem')[index]).hasClass('nao') ? 'true' : 'false')
        };
        jsonValores[index] = obj;
        index++;
    }

    return JSON.stringify(jsonValores);
}

function salvarPesquisa() {
    if (iframeSalvarFiltros.document.getElementById('nomePesquisa').value.trim() === '') {
        chamarAlert('Insira um nome para pesquisa', iframeSalvarFiltros.habilitarBotaoSalvar);
    } else {
        var nomePesquisa = iframeSalvarFiltros.document.getElementById('nomePesquisa').value;
        var nomePesquisaOriginal = iframeSalvarFiltros.document.getElementById('nomePesquisaOriginal').value;
        var aoSalvar = iframeSalvarFiltros.jQuery("input[name='aoSalvar']:checked").val();
        var isPrivado = (iframeSalvarFiltros.jQuery('input[name=options]:checked').val() == 1 ? true : false);

        jQuery.ajax({
            url: 'ConsultaControlador?acao=cadPrefUsuPersonalizada',
            type: 'POST',
            async: false,
            data: jQuery('form').serialize() + '&nomePesquisa=' + nomePesquisa + "&isPrivado=" + isPrivado + '&aoSalvar=' + aoSalvar + '&idPreferencia=' + idPreferencia + '&cod_tela=' + codigo_tela + '&nomePesquisaOriginal=' + nomePesquisaOriginal,
            datatype: 'json',
            success: function (data, textStatus, jqXHR) {
                if (data.length > 0) {


                    var error = jQuery.parseJSON(jQuery.parseJSON(data));

                    if (error.erro != null && error.erro != undefined) {
                        chamarAlert(error.erro);
                        return false;
                    }

                }

                chamarAlert("Pesquisa salva com sucesso.");
                jQuery(iframeSalvarFiltros.document.getElementById('nomePesquisa')).val('');
                cancelarSalvarPesquisa();
            },
            error: function (jqXHR, textStatus, errorThrown) {
                chamarAlert("Ocorreu um erro ao tentar salvar a pesquisa.");
                cancelarSalvarPesquisa();
            }
        });

    }
}

function cancelarSalvarPesquisa() {
    var container = jQuery('.container-salvar-filtros');
    jQuery('.cobre-tudo').hide('low');
    //Alterando cor
    jQuery('.div-lb-filtros').css('background', 'rgba(12,37,62,0.4)');

    container.animate({
        'width': '0px'
    }, 200, function () {
        container.hide();
        container.animate({
            'height': '0px'
        }, 1);
    });
}

jQuery('.salvarPesquisaContainer').click(function () {
    checkSession(function () {
        var top = parseInt(jQuery('.salvarPesquisaContainer').offset().top) - 335;
//                    var top = 0;
        var container = jQuery('.container-salvar-filtros');

        if (container.css('width') == '0px') {
            container.show();



            jQuery('.cobre-tudo').show('low');
            container.css('margin-top', top + 'px');
            container.animate({
                'height': '315px'
            }, 200, function () {
                container.animate({
                    'width': '400px'
                }, 200);
            });


        } else {
            jQuery('.cobre-tudo').hide('low');
            //Alterando cor
            jQuery('.salvarPesquisaContainer').css('background', 'rgba(12,37,62,0.4)');

            container.animate({
                'width': '0px'
            }, 200, function () {
                container.hide();
                container.animate({
                    'height': '0px'
                }, 1);
            });

        }
    }, false);

});

class filtro {
    constructor(tipoLocalizar) {
        this.tipoLocalizar = tipoLocalizar;
    }

    getTipo() {
        return this.tipoLocalizar;
    }

    setTipo(tipoLocalizar) {
        this.tipoLocalizar = tipoLocalizar;
    }
}

function atualizarSelect() {
    // Atualizar tamanho dos select
    jQuery('.ui-selectmenu-button').each(function () {
        var elemento = $(this);
        var select = elemento.attr('id');
        if (select) {
            try{
                select = select.replace('-button', '');
                jQuery('#' + select).selectmenu('refresh');
            }catch(ex){
                console.error(ex);
            }
        }
    });
}