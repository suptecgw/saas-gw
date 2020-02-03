var myConfObj = {
    iframeMouseOver: false
};

var containerVideo = null;

window.addEventListener('blur', function () {
    if (myConfObj.iframeMouseOver) {
        jQuery(containerVideo).trigger('change');
    }
});

function consulta() {
    jQuery("#formConsulta").submit();
}

function visualizar(index, nivel, filialUser, podeexcluir) {
    var idmovimento = jQuery('#hi_row_id_' + index).val();
    filialCte = jQuery('#hi_row_filial_' + index).val();
    if (nivel > 0) {
//        location.href = "./frameset_conhecimento?acao=editar&id=" + idmovimento + (podeexcluir != null ? "&ex=" + podeexcluir : "");
        window.open("./frameset_conhecimento?acao=editar&id=" + idmovimento + (podeexcluir != null ? "&ex=" + podeexcluir : ""), "Localizar Conhecimento", 'top=10,left=0,height=700,width=1100,resizable=yes,status=1,scrollbars=1');
    } else if (filialCte = filialUser) {
        window.open("./frameset_conhecimento?acao=editar&id=" + idmovimento + (podeexcluir != null ? "&ex=" + podeexcluir : ""), "Localizar Conhecimento", 'top=10,left=0,height=700,width=1100,resizable=yes,status=1,scrollbars=1');
    } else {
        chamarAlert("Você não tem privilégios suficientes para executar essa ação. Para acessar essa rotina você deverá solicitar a permissão PM039 ao usuário administrador de sua empresa.");
        return null;
    }
}

jQuery(document).ready(function () {
    jQuery('#mostrar-mercadoria-deposito').selectMultiploGrupoGw({
        container: '.container-select-multiplo-grupos-gw',
        titulo: 'Mostrar Mercadorias em depósito',
        idInput: 'input-mostrar-mercadoria-deposito',
        width: '200px',
        grupos: {
            Status: {
                1: 'Entregue!!status!!Entregue',
                2: 'Pendente (No prazo)!!status!!Pendente (No prazo)',
                3: 'Pendente (Fora do prazo)!!status!!Pendente (Fora do prazo)'
            },
            SEFAZ: {
                1: 'Confirmao!!cte_confirmado!!Sim',
                2: 'Não Confirmado!!cte_confirmado!!Não'
            },
            Pagamento: {
                1: 'CIF!!tipo_pagto!!CIF',
                2: 'FOB!!tipo_pagto!!FOB',
                3: 'Terceiro!!tipo_pagto!!Terceiro'
            },
            Localização: {
                1: 'Depósito de Origem!!status_carga!!Depósito Origem!!IGUAL',
                2: 'Em Trânsito!!status_carga!!Em Trânsito!!Em Trânsito!!IGUAL',
                3: 'Depósito de Destino!!status_carga!!Depósito Destino!!IGUAL'
            }
        }
    });

    jQuery('#select-exceto-apenas-filial').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-cidade-des').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-remetente').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-destinatario').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-consignatario').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-representante').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#inptFilial').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptFilialDes').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptCidadeDes').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptRemetente').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptDestinatario').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptConsignatario').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptRepresentante').inputMultiploGw({
        width: '97%',
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


    jQuery('.salvarPesquisaContainer').click(function () {
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
    jQuery('.gif-bloq-tela-left').css('display', 'block');
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
                removerValorInput('inptFilial');
                removerValorInput('inputFilialDes');
                removerValorInput('inptCidadeDes');
                removerValorInput('inptRemetente');
                removerValorInput('inptDestinatario');
                removerValorInput('inptConsignatario');
                removerValorInput('input-mostrar-mercadoria-deposito');
                removerValorInput('inptRepresentante');

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

                if (objCompleto.nomeFilial != null && objCompleto.nomeFilial != undefined) {
                    var filial = objCompleto.valorFilial.replace(/\[+/g, '').replace(/\]+/g, '');
                    filial = filial.split(',');

                    var nomefilial = objCompleto.descricaoFilial.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomefilial = nomefilial.split(',');

                    for (var i = 0; i < filial.length; i++) {
                        addValorAlphaInput('inptFilial', nomefilial[i], filial[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeFilialDes != null && objCompleto.nomeFilialDes != undefined) {
                    var filialDes = objCompleto.valorFilialDes.replace(/\[+/g, '').replace(/\]+/g, '');
                    filialDes = filialDes.split(',');

                    var nomefilialDes = objCompleto.descricaoFilialDes.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomefilialDes = nomefilialDes.split(',');

                    for (var i = 0; i < filialDes.length; i++) {
                        addValorAlphaInput('inptFilialDes', nomefilialDes[i], filialDes[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeCidadeDes != null && objCompleto.nomeCidadeDes != undefined) {
                    var cidadeDes = objCompleto.valorCidadeDes.replace(/\[+/g, '').replace(/\]+/g, '');
                    cidadeDes = cidadeDes.split(',');

                    var nomecidadeDes = objCompleto.descricaoCidadeDes.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomecidadeDes = nomecidadeDes.split(',');

                    for (var i = 0; i < cidadeDes.length; i++) {
                        addValorAlphaInput('inptCidadeDes', nomecidadeDes[i], cidadeDes[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeRemetente != null && objCompleto.nomeRemetente != undefined) {
                    var remetente = objCompleto.valorRemetente.replace(/\[+/g, '').replace(/\]+/g, '');
                    remetente = remetente.split(',');

                    var nomeRemetente = objCompleto.descricaoRemetente.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeRemetente = nomeRemetente.split(',');

                    for (var i = 0; i < remetente.length; i++) {
                        addValorAlphaInput('inptRemetente', nomeRemetente[i], remetente[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeDestinatario != null && objCompleto.nomeDestinatario != undefined) {
                    var destinatario = objCompleto.valorDestinatario.replace(/\[+/g, '').replace(/\]+/g, '');
                    destinatario = destinatario.split(',');

                    var nomeDestnatario = objCompleto.descricaoDestinatario.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeDestnatario = nomeDestnatario.split(',');

                    for (var i = 0; i < destinatario.length; i++) {
                        addValorAlphaInput('inptDestinatario', nomeDestnatario[i], destinatario[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeConsignatario != null && objCompleto.nomeConsignatario != undefined) {
                    var consignatario = objCompleto.valorConsignatario.replace(/\[+/g, '').replace(/\]+/g, '');
                    consignatario = consignatario.split(',');

                    var nomeConsignatario = objCompleto.descricaoConsignatario.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeConsignatario = nomeConsignatario.split(',');

                    for (var i = 0; i < consignatario.length; i++) {
                        addValorAlphaInput('inptConsignatario', nomeConsignatario[i], consignatario[i]);
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
        if (nome == 'emissao_cte') {
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
        } else if (nome == 'data_saida') {
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
        } else if (nome == 'data_chegada') {
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
        } else if (nome == 'data_entrega') {
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
        } else if (nome == 'previsao_entrega') {
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

function gerenciarMostrarMercadoriaDeposito(name, valor, descricao) {
    if (name === 'status' || name === 'cte_confirmado' || name === 'tipo_pagto' || name === 'status_carga') {
        if (jQuery('#filtros-adicionais-container').css('display') === 'none') {
            jQuery('#filtros-adicionais').trigger('click');
        }

        addValorSelectMultiploGrupo('input-mostrar-mercadoria-deposito', valor, descricao);
    }
}

function gerenciarInpFilial(nome, valor, descricao, condicao) {
    if (nome == 'filial_id') {

        jQuery('#select-exceto-apenas-filial').parent().find('.container-li-valores').find(condicao === 'apenas' ? 'li:first-child' : 'li:last-child').trigger('click');
//        jQuery('#select-exceto-apenas-filial option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptFilial', descricao[i].trim(), valor[i].trim());
        }
    }
}

function gerenciarInpFilialDes(nome, valor, descricao, condicao) {
    if (nome == 'filial_destino_id') {
        jQuery('#select-exceto-apenas-filial-destino').parent().find('.container-li-valores').find(condicao === 'apenas' ? 'li:first-child' : 'li:last-child').trigger('click');
        jQuery('#select-exceto-apenas-filial-destino option[value="' + condicao + '"]').attr('selected', 'selected');
        
        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptFilialDes', descricao[i].trim(), valor[i].trim());
        }
    }
}


function gerenciarRepresentante(nome, valor, descricao, condicao) {
    if (nome == 'representante_destino_id') {
        jQuery('#select-exceto-apenas-representante').parent().find('.container-li-valores').find(condicao === 'apenas' ? 'li:first-child' : 'li:last-child').trigger('click');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptRepresentante', descricao[i].trim(), valor[i].trim());
        }
    }
}

function gerenciarInpCidade(nome, valor, descricao, condicao) {
    if (nome == 'cidade_destino_id') {
        jQuery('#select-exceto-apenas-cidade-des').parent().find('.container-li-valores').find(condicao === 'apenas' ? 'li:first-child' : 'li:last-child').trigger('click');
//        jQuery('#select-exceto-apenas-cidade-des option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptCidadeDes', descricao[i].trim(), valor[i].trim());
        }
    }
}

function gerenciarInpRemetente(nome, valor, descricao, condicao) {
    if (nome == 'remetente_id') {
        jQuery('#select-exceto-apenas-remetente').parent().find('.container-li-valores').find(condicao === 'apenas' ? 'li:first-child' : 'li:last-child').trigger('click');
//        jQuery('#select-exceto-apenas-remetente option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptRemetente', descricao[i].trim(), valor[i].trim());
        }
    }
}

function gerenciarInpDestinatario(nome, valor, descricao, condicao) {
    if (nome == 'destinatario_id') {
        jQuery('#select-exceto-apenas-destinatario').parent().find('.container-li-valores').find(condicao === 'apenas' ? 'li:first-child' : 'li:last-child').trigger('click');
//        jQuery('#select-exceto-apenas-destinatario option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptDestinatario', descricao[i].trim(), valor[i].trim());
        }
    }
}

function gerenciarInpConsignatario(nome, valor, descricao, condicao) {
    if (nome == 'consignatario_id') {
        jQuery('#select-exceto-apenas-consignatario').parent().find('.container-li-valores').find(condicao === 'apenas' ? 'li:first-child' : 'li:last-child').trigger('click');
//        jQuery('#select-exceto-apenas-consignatario option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptConsignatario', descricao[i].trim(), valor[i].trim());
        }
    }
}
