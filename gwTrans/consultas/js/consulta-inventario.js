var myConfObj = {
    iframeMouseOver: false
};

var containerVideo = null;

window.addEventListener('blur', function () {
    if (myConfObj.iframeMouseOver) {
        jQuery(containerVideo).trigger('change');
    }
});

function editar(position) {
    var id = jQuery("#hi_row_id_" + position).val();
    location.replace("CadastroControlador?codTela=" + codigo_tela_cadastro + "&modulo=editar&id=" + id+"&tema="+tema);
}

function consulta() {
    jQuery("#formConsulta").submit();
}

function excluir(item) {
    var index = 0;
    var ids = '';
    var nomes = '';

    if (item == undefined) {
        while (jQuery('input:checked[type=checkbox][name*=nCheck]')[index] != undefined) {
            var val = jQuery('input:checked[type=checkbox][name*=nCheck]')[index].value;
            var id = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().find('#hi_row_id_' + val).val();
            var nome = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().find('#hi_row_descricao_' + val).val();

            if (jQuery('input:checked[type=checkbox][name*=nCheck]')[index + 1] != undefined) {
                ids += id + ',';
            } else {
                ids += id;
            }

            nomes += '<li>' + nome + '</li>';

            index++;
        }
    } else if (item) {
        ids = jQuery('#hi_row_id_' + item).val();
        nomes = jQuery('#hi_row_descricao_' + item).val();
    }

    var texto = "";
    if (index > 1) {
        texto = "Deseja excluir os Invent�rios abaixo?";
    } else {
        texto = "Deseja excluir o Invent�rio abaixo?";
    }

    chamarConfirm(texto, 'aceitouExcluirInventario("' + ids + '")', '', 1, '<ul class="square">' + nomes + '</ul>');
}

function aceitouExcluirInventario(ids) {
    jQuery.ajax({
        url: 'InventarioControlador?acao=excluir&ids=' + ids,
        success: function (data, textStatus, jqXHR) {
            chamarAlert(data, function () {
                window.location.reload();
            });
        }
    });
}

function salvarPreferencias() {
    var json = getJsonPreferencias();
    jQuery.ajax({
        dataType: 'json',
        method: 'POST',
        url: 'ConsultaControlador?acao=salvarPreferencias&codigoTela=' + codigo_tela,
        data: {'json': json},
        sucess: function () {
        }
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

jQuery(document).ready(function () {
    jQuery('.cobre-tudo').click(function () {
        var container = jQuery('.container-salvar-filtros');
        if (jQuery('.container-salvar-filtros').css('display') == 'block') {
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

    });

    jQuery('span[class="bt bt-cadastro"]').on('click', function () {
        checkSession(function () {
            btnCadastrar('CadastroControlador?codTela=' + codigo_tela_cadastro + '&modulo=cadastro'+'&tema='+tema)
        }, false);
    });

    var iframe = document.getElementById('iframeSalvarFiltros');
    srcSalvarFiltroOriginal = iframe.src;
});

var srcSalvarFiltroOriginal = null;
var objCompleto;

function alerarFiltroPesquisa() {
    var iframe = document.getElementById('iframeSalvarFiltros');

    if (jQuery('#select-pesquisa').val() == 0) {
        iframe.src = srcSalvarFiltroOriginal;
    } else {
        iframe.src = srcSalvarFiltroOriginal + '?nomePesquisa=' + jQuery('#select-pesquisa').val() + '&isPrivada=' + true;
    }

    jQuery('.cobre-tudo').css('display', 'block');
    jQuery('.cobre-tudo').css('background', 'rgba(100, 100, 100, 0.4)');
    jQuery('.div-lb-filtros').css('z-index', '99');


    setTimeout(function () {
        jQuery.ajax({
            url: 'ConsultaControlador',
            type: 'POST',
            async: false,
            data: {
                acao: 'alterarFiltroPesquisa',
                nomeFiltro: jQuery('#select-pesquisa').val(),
                codigoTela: codigo_tela
            },
            success: function (data, textStatus, jqXHR) {
                jQuery('#createdMe').prop('checked', false);
                removerValorInput('inpSelectVal');

                objCompleto = jQuery.parseJSON(jQuery.parseJSON(data));

                var ordenarPor = objCompleto.ordenacao.trim().split(" ")[0];
                var tipoOrd = objCompleto.ordenacao.trim().split(" ")[1];

                var limiteResultados = objCompleto.limiteResultado;
                var operador = objCompleto.operador1;

                //seta o id da preferencia na variavel, (usada para update)
                idPreferencia = objCompleto.idPreferencia;

                //Operador
                jQuery('#select-oper option[value=' + operador + ']').prop('selected', true);
                jQuery("#select-oper").selectmenu("refresh");

                //Limite
                jQuery('#select-limite option[value=' + limiteResultados + ']').prop('selected', true);
                jQuery("#select-limite").selectmenu("refresh");


                //Ordenar por e se � rescente ou nao
                //------------------------------------------------------------------------------------------
                jQuery('#select-ordenacao option[value=' + ordenarPor + ']').prop('selected', true);
                jQuery("#select-ordenacao").selectmenu("refresh");

                jQuery('#select-order-tipo option[value=' + tipoOrd + ']').prop('selected', true);
                jQuery("#select-order-tipo").selectmenu("refresh");
                //------------------------------------------------------------------------------------------

                if (objCompleto.valor21 == 'null') {
                    jQuery('.container-campos-select').show();
                    jQuery('.container-data').hide();

                    jQuery("#dataAte").datebox({disabled: true});
                    jQuery("#dataDe").datebox({disabled: true});


                    jQuery('#select-abrev option[value=' + objCompleto.nome1 + ']').prop('selected', true);
                    jQuery("#select-abrev").selectmenu("refresh");


                    var valor1 = objCompleto.valor1.replace(/\[+/g, '').replace(/\]+/g, '');
                    valor1 = valor1.split(',');

                    for (var i = 0; i < valor1.length; i++) {
                        addValorAlphaInput('inpSelectVal', valor1[i]);
                    }

                }

                if (objCompleto.valor1 != null && objCompleto.valor1 != undefined && objCompleto.valor21 != 'null') {
                    jQuery('#select-abrev option[value=' + objCompleto.nome1 + ']').prop('selected', true);
                    jQuery("#select-abrev").selectmenu("refresh");

                    jQuery('.container-campos-select').hide();
                    jQuery('.container-data').show();
                    jQuery("#dataAte").datebox({disabled: false});
                    jQuery("#dataDe").datebox({disabled: false});

                    jQuery('#dataAte').datebox('setValue', objCompleto.valor21);
                    jQuery('#dataDe').datebox('setValue', objCompleto.valor1);

                    jQuery('.datebox').css('width', '93%');
                    jQuery('.textbox-text').css('width', '93%');
                    jQuery('.textbox-text').css('font-size', '14px');
                }

                if (objCompleto.nomeCreatedMe != null && objCompleto.nomeCreatedMe != undefined) {
                    jQuery('#createdMe').prop('checked', true);
                    jQuery('#filtros-adicionais-container').show();
                }


            },
            error: function (jqXHR, textStatus, errorThrown) {
                chamarAlert('Ocorreu um erro ao tentar carregar o filtro escolhido.');
            },
            complete: function (jqXHR, textStatus) {
                jQuery('#search').trigger('click');
            }

        });

    }, 500);
}

function gerenciarInpSelectVal(nome, valor, valor2) {
    if (jQuery('#select-abrev option[value=' + nome + ']').size() >= 1) {
        if (nome == 'data') {
            jQuery('.container-campos-select').hide(250, function () {
                jQuery('.container-data').show(250);
                jQuery("#dataAte").datebox({disabled: false});
                jQuery("#dataDe").datebox({disabled: false});

                jQuery('#dataAte').datebox('setValue', valor2);
                jQuery('#dataDe').datebox('setValue', valor);

                jQuery('.datebox').css('width', '93%');
                jQuery('.textbox-text').css('width', '93%');
                jQuery('.textbox-text').css('font-size', '14px');
            });
        } else {
            jQuery("#dataAte").datebox({disabled: true});
            jQuery("#dataDe").datebox({disabled: true});
            valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
            valor = valor.split(",");
            for (var i = 0; i < valor.length; i++) {
                addValorAlphaInput('inpSelectVal', valor[i].trim());
            }
        }
    }
}

function gerenciarCheckBox(nome, valor) {
    if (nome == 'criado_por') {
        jQuery('#createdMe').prop('checked', true);
        //jQuery('#filtros-adicionais-container').show();
    }
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
            url: 'ConsultaControlador?acao=cadPrefUsuPersonalizada&nomePesquisa=' + nomePesquisa + "&isPrivado=" + isPrivado + '&aoSalvar=' + aoSalvar + '&idPreferencia=' + idPreferencia + '&cod_tela=82&nomePesquisaOriginal=' + nomePesquisaOriginal,
            type: 'POST',
            async: false,
            data: jQuery('form').serialize(),
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

function launchPDF(url, idname) {
    var cf = 'top=0,left=0,height=600,width=800,resizable=yes,status=1,scrollbars=1';
    var pdf = window.open(url, idname, cf);
    pdf.window.resizeTo(screen.width, screen.height - 20);
    pdf.focus();
}

function mostrarImprimirInventario(index) {
    var index = jQuery(index).parent().parent().attr('ordem');
    var idInventario = jQuery('#hi_row_id_' + index).val();
    var numeroInventario = jQuery('#hi_row_numero_' + index).val();

    chamarConfirm('Deseja imprimir o relat�rio para o invent�rio ' + numeroInventario + "?", 'imprimir(' + idInventario + ')');
}

function imprimir(ids) {
    launchPDF('./RelatorioControlador?acao=imprimirRelatorioInventario&modelo=1&id=' + ids, 'inventario' + ids);
}

function imprimirInventarios() {
    var ids = '';
    var index = 0;

    while (jQuery('input:checked[type=checkbox][name*=nCheck]')[index] != undefined) {
        var val = jQuery('input:checked[type=checkbox][name*=nCheck]')[index].value;
        var id = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().parent().find('#hi_row_id_' + val).val();

        if (jQuery('input:checked[type=checkbox][name*=nCheck]')[index + 1] != undefined) {
            ids += id + ',';
        } else {
            ids += id;
        }

        index++;
    }
    if (ids == undefined || ids == "") {
        chamarAlert("Selecione pelo menos um Invent�rio!");
        return null;
    }
    imprimir(ids);
}

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