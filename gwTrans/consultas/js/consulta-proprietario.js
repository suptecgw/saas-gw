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
    location.replace("cadproprietario?acao=editar&id=" + id);
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
            var nome = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().find('#hi_row_nome_' + val).val();

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
        nomes = jQuery('#hi_row_nome_' + item).val();
    }

    var texto = "";
    if (index > 1) {
        texto = "Deseja excluir os proprietários abaixo?";
    } else {
        texto = "Deseja excluir o proprietário abaixo?";
    }
    chamarConfirm(texto, 'aceitouExcluirProprietario("' + ids + '")', '', 1, '<ul class="square">' + nomes + '</ul>');

}

function aceitouExcluirProprietario(ids) {
    jQuery.ajax({
        url: 'ProprietarioControlador?acao=excluir&ids=' + ids,
        success: function (data, textStatus, jqXHR) {
            chamarAlert(data, reload);
        }
    });
}

function reload() {
    window.location.reload();
}

jQuery(document).ready(function () {
    jQuery('#select-tipo-proprietario').selectGrupoMultiploGw({
        input: 'select-tipo-proprietario',
        grupos: {
            Tipo: {
                1: 'Pessoa Física!!tipo_cgc!!F!!IGUAL',
                2: 'Pessoa Jurídica!!tipo_cgc!!J!!IGUAL'
            },
            Categoria: {
                1: 'TAC!!tac!!Sim!!IGUAL',
                2: 'Não TAC!!tac!!Não!!IGUAL'
            }
        }
    });

    jQuery('#select-exceto-apenas-tipo-proprietario').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#inptCidadeOri').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

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
                removerValorInput('inptCidadeOri');
                removerValorInput('input-mostrar-proprietarios');
                removerValorInput('select-tipo-proprietario');

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


                //Ordenar por e se é rescente ou nao
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
                        addValorAlphaInput('inpSelectVal', valor1[i].trim());
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

                if (objCompleto.nomeCidadeOri != null && objCompleto.nomeCidadeOri != undefined) {
                    var cidadeOri = objCompleto.valorCidadeOri.replace(/\[+/g, '').replace(/\]+/g, '');
                    cidadeOri = cidadeOri.split(',');

                    var nomeCidadeOri = objCompleto.descricaoCidadeOri.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeCidadeOri = nomeCidadeOri.split(',');

                    for (var i = 0; i < cidadeOri.length; i++) {
                        addValorAlphaInput('inptCidadeOri', nomeCidadeOri[i], cidadeOri[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeCgc != null && objCompleto.nomeCgc != undefined) {
                    var valorCgc = objCompleto.valorCgc.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorCgc = valorCgc.split(',');
                    var descCgc = objCompleto.descricaoCgc.replace(/\[+/g, '').replace(/\]+/g, '');
                    descCgc = descCgc.split(',');
                    for (var i = 0; i < valorCgc.length; i++) {
                        gerenciarMostrarProprietarios(objCompleto.nomeCgc, valorCgc[i], objCompleto.condicaoCgc, descCgc[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeTac != null && objCompleto.nomeTac != undefined) {
                    var valorTac = objCompleto.valorTac.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorTac = valorTac.split(',');
                    var descTac = objCompleto.descricaoTac.replace(/\[+/g, '').replace(/\]+/g, '');
                    descTac = descTac.split(',');
                    for (var i = 0; i < valorTac.length; i++) {
                        gerenciarMostrarProprietarios(objCompleto.nomeTac, valorTac[i], objCompleto.condicaoTac, descTac[i]);
                    }
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
        if (nome == 'data_criacao') {
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
        } else if (nome == 'data_ultima_alteracao') {
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
        jQuery('#filtros-adicionais-container').show();
    }
}

function gerenciarMostrarProprietarios(name, valor, condicao, descricao) {
    valor = valor.trim();
    if (name == 'tipo_cgc') {
        if (valor == 'F') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[1]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-proprietario option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'J') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[2]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-proprietario option[value="' + condicao + '"]').attr('selected', 'selected');
        }
    }
    if (name == 'tac') {
        if (valor == 'Sim') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[4]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-proprietario option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'Não') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[5]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-proprietario option[value="' + condicao + '"]').attr('selected', 'selected');
        }
    }
    jQuery('.container-li-valores').hide();
}

function gerenciarInpCidade(nome, valor, descricao, condicao) {
    if (nome == 'cidade_id') {
        jQuery('#select-exceto-apenas-cidade option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptCidadeOri', descricao[i].trim(), valor[i].trim());
        }
    }
}


function enviarMotoristaEfrete(e) {
    var ordem = $(e).parent().parent().attr('ordem');
    var id = $('#hi_row_id_' + ordem).val();

    $('.container-envio-motorista').show();
    $.ajax({
        url: 'EFreteControlador?acao=enviarProprietario&idProprietario=' + id,
        method: 'POST',
        complete: function (jqXHR, textStatus) {
            $('.container-envio-motorista').hide();
            chamarAlert(jqXHR.responseText);
        }
    });
}

function enviarMotoristaExpers(e) {

    var ordem = $(e).parent().parent().attr('ordem');
    var id = $('#hi_row_id_' + ordem).val();
    $('.cobre-tudo').show();
    $('.container-envio-motorista').show();
    $.ajax({
        url: 'ExpersControlador?acao=enviarProprietarioExpers&idProprietario=' + id,
        method: 'POST',
        complete: function (jqXHR, textStatus) {
            $('.container-envio-motorista').hide();
            $('.cobre-tudo').hide();
            chamarAlert(jqXHR.responseText);
        }
    });
}

function enviarMotoristaPagBem(e) {
    var ordem = $(e).parent().parent().attr('ordem');
    var id = $('#hi_row_id_' + ordem).val();
    $('.cobre-tudo').show();
    $('.container-envio-motorista').show();
    $.ajax({
        url: 'PagBemControlador?acao=enviarProprietarioPagBem&idProprietario=' + id,
        method: 'POST',
        complete: function (jqXHR, textStatus) {
            $('.container-envio-motorista').hide();
            $('.cobre-tudo').hide();
            chamarAlert(jqXHR.responseText);
        }
    });
}

function enviarMotoristaRepom(e) {
    var ordem = $(e).parent().parent().attr('ordem');
    var id = $('#hi_row_id_' + ordem).val();
    $('.cobre-tudo').show();
    $('.container-envio-motorista').show();
    $.ajax({
        url: 'RepomControlador?acao=enviarProprietarioRepom&idProprietario=' + id,
        method: 'POST',
        complete: function (jqXHR, textStatus) {
            $('.container-envio-motorista').hide();
            $('.cobre-tudo').hide();
            chamarAlert(jqXHR.responseText);
        }
    });
}

function enviarMotoristaTarget(e) {
    var ordem = $(e).parent().parent().attr('ordem');
    var id = $('#hi_row_id_' + ordem).val();
    $('.cobre-tudo').show();
    $('.container-envio-motorista').show();
    $.ajax({
        url: 'TargetControlador?acao=enviarProprietarioTarget&idProprietario=' + id,
        method: 'POST',
        complete: function (jqXHR, textStatus) {
            $('.container-envio-motorista').hide();
            $('.cobre-tudo').hide();
            chamarAlert(jqXHR.responseText);
        }
    });
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