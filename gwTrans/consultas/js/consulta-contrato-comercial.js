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
    location.replace("ContratoComercialControlador?acao=carregar&modulo=editar&id=" + id + "&codTela=" + codigo_tela_cadastro+'&tema='+tema);
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
            var nome = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().find('#hi_row_numero_' + val).val();

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
        nomes = jQuery('#hi_row_numero_' + item).val();
    }

    var texto = "";
    if (index > 1) {
        texto = "Deseja excluir os contratos abaixo?";
    } else {
        texto = "Deseja excluir o contrato abaixo?";
    }
    chamarConfirm(texto, 'aceitouExcluirContrato("' + ids + '")', '', 1, '<ul class="square">' + nomes + '</ul>');
}

function aceitouExcluirContrato(ids) {
    jQuery.ajax({
        url: 'ContratoComercialControlador?acao=excluir&ids=' + ids,
        success: function (data, textStatus, jqXHR) {
            chamarAlert(data, reload);
        }
    });
}

function reload() {
    window.location.reload();
}

jQuery(document).ready(function () {
    jQuery('#select-exceto-apenas-cliente').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#inptCliente').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#select-exceto-apenas-filial').selectExcetoApenasGw({
        width: '170px'
    });
    
    jQuery('#inptFilial').inputMultiploGw({
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

    jQuery('span[class="bt bt-cadastro"]').on('click', function () {
        checkSession(function () {
            btnCadastrar('CadastroControlador?codTela=' + codigo_tela_cadastro + '&modulo=cadastro'+'&tema='+tema)
        }, false);
    });

    var iframe = jQuery('#iframeSalvarFiltros');
    srcSalvarFiltroOriginal = iframe.attr('src');
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
                removerValorInput('inptCliente');
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

                    console.log('hello!');
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
                
                if (objCompleto.nomeFilial != null && objCompleto.nomeFilial != undefined) {
                    var filial = objCompleto.valorFilial.replace(/\[+/g, '').replace(/\]+/g, '');
                    filial = filial.split(',');

                    var nomeFil = objCompleto.descricaoFilial.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeFil = nomeFil.split(',');

                    for (var i = 0; i < filial.length; i++) {
                        addValorAlphaInput('inptCliente', nomeFil[i], filial[i]);
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
        if (nome == 'data_emissao') {
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
        } else if (nome == 'validade') {
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

function gerenciarInpFilial(nome, valor, descricao, condicao) {
    if (nome == 'filial_id') {
        jQuery('#select-exceto-apenas-filial option[value="' + condicao + '"]').attr('selected', 'selected');

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

function gerenciarInpCliente(nome, valor, descricao, condicao) {
    if (nome == 'cliente_id') {
        jQuery('#select-exceto-apenas-cliente option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        setTimeout(function () {
            var i = 0;
            while (valor[i]) {
                jQuery('#filtros-adicionais-container').show();
                addValorAlphaInput('inptCliente', descricao[i], valor[i]);
                i++;
            }
        }, 500);
    }
}

function popRel(position) {
    var ordem = $(position).parent().parent().attr('ordem');
    var impressao = '1';
    var ids = '';

    if (!position) {
        var index = 0;
        var nomes = '';


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
            chamarAlert("Selecione pelo menos um contrato!");
            return null;
        }
    } else {
        ids = jQuery('#hi_row_id_' + ordem).val();
    }


    launchPDF('ContratoComercialControlador?acao=exportar&id=' + ids);
}

function launchPDF(url, idname) {
    var cf = 'top=0,left=0,height=600,width=800,resizable=yes,status=1,scrollbars=1';
    var pdf = window.open(url, idname, cf);
    pdf.window.resizeTo(screen.width, screen.height - 20);
    pdf.focus();
}

function visualizarDocumentos(e,tema) {
    var ordem = $(e).parent().parent().attr('ordem');
    
    jQuery('.visualizarDocumentos').css('height','');
    jQuery('.visualizarDocumentos').css('top','');
    
    jQuery('.cobre-tudo').show();
    jQuery('.salvarPesquisaContainer').css('z-index', '999996');

    jQuery('.visualizarDocumentos').css('display', 'block');
    var idcontrato = jQuery('#hi_row_id_' + ordem).val();
    var numero = jQuery('#hi_row_numero_' + ordem).val();
    var filial = jQuery('#hi_row_filial_' + ordem).val();
    jQuery('#iframeVisualizarDocumentos').attr('src', 'ImagemControlador?acao=carregar&numero=' + numero + '&filial=' + filial + '&idcontrato=' + idcontrato + '&isFoto=' + false+'&tema='+tema);
}

function fecharVisualizarContrato() {
    jQuery('.cobre-tudo').hide();
    jQuery('.salvarPesquisaContainer').css('z-index', '999999');
    jQuery('.visualizarDocumentos').css('display', 'none');
}

function excluirImagem() {
    var msg = 'Deseja mesmo excluir essa imagem no Cadastro de Contrato Comercial?';
    if (iframeVisualizarDocumentos.getValueCheckMarcados().split(',')[1] != undefined) {
        msg = 'Deseja mesmo excluir essas imagens no Cadastro de Contrato Comercial?';
    }
    chamarConfirm(msg, 'iframeVisualizarDocumentos.excluir()', 'null');
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

function popContratoComercialGeral(position) {
    var ids = '';
    if (!position) {
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
    } else {
        ids = jQuery('#hi_row_id_' + position).val();
    }
    launchPDF('ContratoComercialControlador?acao=exportar&id=' + ids);
}
