var myConfObj = {
    iframeMouseOver: false
};

var containerVideo = null;

window.addEventListener('blur', function () {
    if (myConfObj.iframeMouseOver) {
        jQuery(containerVideo).trigger('change');
    }
});

function cadastrarRota() {
    location.replace("cadrota.jsp?acao=iniciar");
}

function relatorioRotas() {
    window.open('relrotas.jsp?acao=iniciar&modulo=webtrans', "_blank", "toolbar=yes,scrollbars=yes,resizable=yes,top=200,left=500,width=800,height=600");
}

function editar(position) {
    var id = jQuery("#hi_row_id_" + position).val();
    location.replace("./cadrota.jsp?acao=editar&id=" + id + "&ex=" + (nivelUser <= 3 ? 'false' : 'true'));
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
        texto = "Deseja excluir as rotas abaixo?";
    } else {
        texto = "Deseja excluir a rota abaixo?";
    }
    chamarConfirm(texto, 'aceitouExcluirRota("' + ids + '")', '', 1, '<ul class="square">' + nomes + '</ul>');

}

function aceitouExcluirRota(ids) {
    jQuery.ajax({
        url: 'RotaControlador?acao=excluir&ids=' + ids,
        success: function (data, textStatus, jqXHR) {
            chamarAlert(data, reload);
        }
    });
}

function reload() {
    window.location.reload();
}

function ativarExcetoApenas() {
    jQuery('#select-exceto-apenas-tipo-rota').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-cidade').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-cidade-des').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-areas').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-cliente').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-tipo-produto').selectExcetoApenasGw({
        width: '170px'
    });

}

jQuery(document).ready(function () {

    jQuery('#select-tipo-rota').selectGrupoMultiploGw({
        input: 'select-tipo-rota',
        grupos: {
            Status: {
                1: 'Ativas!!ativa!!Sim!!IGUAL',
                2: 'Inativas!!ativa!!Não!!IGUAL'
            },
            Utilização: {
                1: 'Coleta!!rota_coleta!!Sim!!IGUAL',
                2: 'Manifesto!!rota_manifesto!!Sim!!IGUAL',
                3: 'Romaneio!!rota_romaneio!!Sim!!IGUAL'
            }
        }
    });


    jQuery('#inptCidadeOri').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptCidadeDes').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptArea').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptCliente').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptTipoProduto').inputMultiploGw({
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
                removerValorInput('select-tipo-rota');
                removerValorInput('inptCidadeOri');
                removerValorInput('inptCidadeDes');
                removerValorInput('inptArea');
                removerValorInput('inptCliente');
                removerValorInput('inptTipoProduto');

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

                if (objCompleto.nomeCidadeDes != null && objCompleto.nomeCidadeDes != undefined) {
                    var cidadeDes = objCompleto.valorCidadeDes.replace(/\[+/g, '').replace(/\]+/g, '');
                    cidadeDes = cidadeDes.split(',');

                    var nomeCidadeDes = objCompleto.descricaoCidadeDes.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeCidadeDes = nomeCidadeDes.split(',');

                    for (var i = 0; i < cidadeDes.length; i++) {
                        addValorAlphaInput('inptCidadeDes', nomeCidadeDes[i], cidadeDes[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeArea != null && objCompleto.nomeArea != undefined) {
                    var area = objCompleto.valorArea.replace(/\[+/g, '').replace(/\]+/g, '');
                    area = area.split(',');

                    var nomeArea = objCompleto.descricaoArea.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeArea = nomeArea.split(',');

                    for (var i = 0; i < area.length; i++) {
                        addValorAlphaInput('inptArea', nomeArea[i], area[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeCli != null && objCompleto.nomeCli != undefined) {
                    var cliente = objCompleto.valorCli.replace(/\[+/g, '').replace(/\]+/g, '');
                    cliente = cliente.split(',');

                    var nomeCli = objCompleto.descricaoCli.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeCli = nomeCli.split(',');

                    for (var i = 0; i < cliente.length; i++) {
                        addValorAlphaInput('inptCliente', nomeCli[i], cliente[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomePro != null && objCompleto.nomePro != undefined) {
                    var tipo = objCompleto.valorPro.replace(/\[+/g, '').replace(/\]+/g, '');
                    tipo = tipo.split(',');

                    var nomePro = objCompleto.descricaoPro.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomePro = nomePro.split(',');

                    for (var i = 0; i < tipo.length; i++) {
                        addValorAlphaInput('inptTipoProduto', nomePro[i], tipo[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeAtiva != null && objCompleto.nomeAtiva != undefined) {
                    var valorAtiva = objCompleto.valorAtiva.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorAtiva = valorAtiva.split(',');
                    var descAtiva = objCompleto.descricaoAtiva.replace(/\[+/g, '').replace(/\]+/g, '');
                    descAtiva = descAtiva.split(',');
                    for (var i = 0; i < valorAtiva.length; i++) {
                        gerenciarMostrarRotas(objCompleto.nomeAtiva, valorAtiva[i], objCompleto.condicaoAtiva, descAtiva[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeRotaC != null && objCompleto.nomeRotaC != undefined) {
                    var valorRotaC = objCompleto.valorRotaC.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorRotaC = valorRotaC.split(',');
                    var descRotaC = objCompleto.descricaoRotaC.replace(/\[+/g, '').replace(/\]+/g, '');
                    descRotaC = descRotaC.split(',');
                    for (var i = 0; i < valorRotaC.length; i++) {
                        gerenciarMostrarRotas(objCompleto.nomeRotaC, valorRotaC[i], objCompleto.condicaoRotaC, descRotaC[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeRotaM != null && objCompleto.nomeRotaM != undefined) {
                    var valorRotaM = objCompleto.valorRotaM.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorRotaM = valorRotaM.split(',');
                    var descRotaM = objCompleto.descricaoRotaM.replace(/\[+/g, '').replace(/\]+/g, '');
                    descRotaM = descRotaM.split(',');
                    for (var i = 0; i < valorRotaM.length; i++) {
                        gerenciarMostrarRotas(objCompleto.nomeRotaM, valorRotaM[i], objCompleto.condicaoRotaM, descRotaM[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeRotaR != null && objCompleto.nomeRotaR != undefined) {
                    var valorRotaR = objCompleto.valorRotaR.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorRotaR = valorRotaR.split(',');
                    var descRotaR = objCompleto.descricaoRotaR.replace(/\[+/g, '').replace(/\]+/g, '');
                    descRotaR = descRotaR.split(',');
                    for (var i = 0; i < valorRotaR.length; i++) {
                        gerenciarMostrarRotas(objCompleto.nomeRotaR, valorRotaR[i], objCompleto.condicaoRotaR, descRotaR[i]);
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

function gerenciarMostrarRotas(name, valor, condicao, descricao) {
    valor = valor.trim();
    if (name == 'ativa') {
        if (valor == 'Sim') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[1]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-rota option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'Não') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[2]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-rota option[value="' + condicao + '"]').attr('selected', 'selected');
        }
    }
    if (name == 'rota_coleta') {
        jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[4]).trigger('click');
        jQuery('#filtros-adicionais-container').show();
        jQuery('#select-exceto-apenas-tipo-rota option[value="' + condicao + '"]').attr('selected', 'selected');
    }
    if (name == 'rota_manifesto') {
        jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[5]).trigger('click');
        jQuery('#filtros-adicionais-container').show();
        jQuery('#select-exceto-apenas-tipo-rota option[value="' + condicao + '"]').attr('selected', 'selected');
    }
    if (name == 'rota_romaneio') {
        jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[6]).trigger('click');
        jQuery('#filtros-adicionais-container').show();
        jQuery('#select-exceto-apenas-tipo-rota option[value="' + condicao + '"]').attr('selected', 'selected');
    }
    jQuery('.container-li-valores').hide();
}

function gerenciarInpCidade(nome, valor, descricao, condicao) {
    if (nome == 'cidade_origem_id') {
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

function gerenciarInpCidadeDes(nome, valor, descricao, condicao) {
    if (nome == 'cidade_destino_id') {
        jQuery('#select-exceto-apenas-cidade-des option[value="' + condicao + '"]').attr('selected', 'selected');

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

function gerenciarInpArea(nome, valor, descricao, condicao) {
    if (nome == 'area_destino_id') {
        jQuery('#select-exceto-apenas-areas option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptArea', descricao[i].trim(), valor[i].trim());
        }
    }
}

function gerenciarInpCliente(nome, valor, descricao, condicao) {
    if (nome == 'cliente_id') {
        jQuery('#select-exceto-apenas-cliente option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptCliente', descricao[i].trim(), valor[i].trim());
        }
    }
}

function gerenciarInpTipoProduto(nome, valor, descricao, condicao) {
    if (nome == 'produto_id') {
        jQuery('#select-exceto-apenas-tipo-produto option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptTipoProduto', descricao[i].trim(), valor[i].trim());
        }
    }
}


function enviarMotoristaRepom(e) {
    var ordem = $(e).parent().parent().attr('ordem');
    var id = $('#hi_row_id_' + ordem).val();
    $('.cobre-tudo').show();
    $('.container-envio-motorista').show();
    $.ajax({
        url: 'RepomControlador?acao=enviarRotaRepom&idRota=' + id,
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
}
)(window, document, 'script', 'https://www.google-analytics.com/analytics.js', 'ga');
ga('create', 'UA-86105277-1', 'auto');
ga('send', 'pageview');