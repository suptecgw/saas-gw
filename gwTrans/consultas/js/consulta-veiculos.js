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
    location.replace("./cadveiculo?acao=editar&id=" + id);
}

function consulta() {
    jQuery("#formConsulta").submit();
}

function visualizarDocumentos(e,tema) {
    var ordem = $(e).parent().parent().attr('ordem');
    jQuery('.cobre-tudo').show();
    jQuery('.salvarPesquisaContainer').css('z-index', '999996');

    jQuery('.visualizarDocumentos').css('display', 'block');
    var idVeiculo = jQuery('#hi_row_id_' + ordem).val();
    var placa = jQuery('#hi_row_placa_' + ordem).val();
    
    jQuery('#iframeVisualizarDocumentos').attr('src', 'ImagemControlador?acao=carregar&placa=' + placa + '&idveiculo=' + idVeiculo+'&tema='+tema);
}

function fecharVisualizarCliente() {
    jQuery('.cobre-tudo').hide();
    jQuery('.salvarPesquisaContainer').css('z-index', '999999');
    jQuery('.visualizarDocumentos').css('display', 'none');
}

function excluirImagem() {
    var msg = 'Deseja mesmo excluir essa Imagem no Cadastro de Veículo?';
    if (iframeVisualizarDocumentos.getValueCheckMarcados().split(',')[1] != undefined) {
        msg = 'Deseja mesmo excluir essas Imagens no Cadastro de Veículo?';
    }
    chamarConfirm(msg, 'iframeVisualizarDocumentos.excluir()', 'null');
}

function excluir(item) {
    var index = 0;
    var ids = '';
    var nomes = '';
    if (item == undefined) {
        while (jQuery('input:checked[type=checkbox][name*=nCheck]')[index] != undefined) {

            var val = jQuery('input:checked[type=checkbox][name*=nCheck]')[index].value;
            var id = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().find('#hi_row_id_' + val).val();
            var nome = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().find('#hi_row_placa_' + val).val();

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
        nomes = jQuery('#hi_row_placa_' + item).val();
    }

    var texto = "";
    if (index > 1) {
        texto = "Deseja excluir os veiculos abaixo?";
    } else {
        texto = "Deseja excluir o veiculo abaixo?";
    }
    chamarConfirm(texto, 'aceitouExcluirVeiculo("' + ids + '")', '', 1, '<ul class="square">' + nomes + '</ul>');

}

function aceitouExcluirVeiculo(ids) {
    jQuery.ajax({
        url: 'VeiculoControlador?acao=excluir&ids=' + ids,
        success: function (data, textStatus, jqXHR) {
            chamarAlert(data, reload);
        }
    });
}

function reload() {
    window.location.reload();
}

function ativarExcetoApenas() {

    jQuery('#select-exceto-apenas-cidade').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-proprietario').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-marca').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-tipo-veiculo').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-veiculo').selectExcetoApenasGw({
        width: '170px'
    });
}

jQuery(document).ready(function () {

    jQuery('#select-tipo-veiculo').selectGrupoMultiploGw({
        input: 'select-tipo-veiculo',
        grupos: {
            Status: {
                1: 'Bloqueados!!bloqueado!!Sim!!IGUAL',
                2: 'Não Bloqueados!!bloqueado!!Não!!IGUAL'
            },
            Categoria: {
                1: 'Terrestres!!categoria!!Terrestre!!IGUAL',
                2: 'Aquaviários!!categoria!!Aquaviário!!IGUAL',
                3: 'Equipamentos!!categoria!!Equipamento!!IGUAL'
            },
            TipoFrota: {
                1: 'Próprios!!tipo_frota!!Próprio!!IGUAL',
                2: 'Agregados!!tipo_frota!!Agregado!!IGUAL',
                3: 'Carreteiros!!tipo_frota!!Carreteiro!!IGUAL'
            }
        }
    });


    jQuery('#inptProprietario').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptMarca').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptTipoVeiculo').inputMultiploGw({
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

    colorirColunasBloqueados();

    jQuery('.tabela-gwsistemas').on('coluna-adicionada', function() {
        colorirColunasBloqueados();
    });
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
                removerValorInput('select-tipo-veiculo');
                removerValorInput('inptCidade');
                removerValorInput('inptProprietario');

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


                if (objCompleto.nomeCreatedMe) {
                    jQuery('#createdMe').prop('checked', true);
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeCidadeOri && objCompleto.valorCidadeOri) {
                    var cidadeOri = objCompleto.valorCidadeOri.replace(/\[+/g, '').replace(/\]+/g, '');
                    cidadeOri = cidadeOri.split(',');

                    var nomeCidadeOri = objCompleto.descricaoCidadeOri.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeCidadeOri = nomeCidadeOri.split(',');

                    for (var i = 0; i < cidadeOri.length; i++) {
                        addValorAlphaInput('inptCidadeOri', nomeCidadeOri[i], cidadeOri[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeProp && objCompleto.valorProp) {
                    var proprietario = objCompleto.valorProp.replace(/\[+/g, '').replace(/\]+/g, '');
                    proprietario = proprietario.split(',');

                    var nomeProp = objCompleto.descricaoProp.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeProp = nomeProp.split(',');

                    for (var i = 0; i < proprietario.length; i++) {
                        addValorAlphaInput('inptProprietario', nomeProp[i], proprietario[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeMarca && objCompleto.valorMarca) {
                    var marca = objCompleto.valorMarca.replace(/\[+/g, '').replace(/\]+/g, '');
                    marca = marca.split(',');

                    var nomeMarca = objCompleto.descricaoMarca.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeMarca = nomeMarca.split(',');

                    for (var i = 0; i < marca.length; i++) {
                        addValorAlphaInput('inptMarca', nomeMarca[i], marca[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeTipoVei && objCompleto.valorTipoVei) {
                    var tipoVeiculo = objCompleto.valorTipoVei.replace(/\[+/g, '').replace(/\]+/g, '');
                    tipoVeiculo = tipoVeiculo.split(',');

                    var nomeTipoVei = objCompleto.descricaoTipoVei.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeTipoVei = nomeTipoVei.split(',');

                    for (var i = 0; i < tipoVeiculo.length; i++) {
                        addValorAlphaInput('inptTipoVeiculo', nomeTipoVei[i], tipoVeiculo[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeBloq && objCompleto.valorBloq) {
                    var valorBloq = objCompleto.valorBloq.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorBloq = valorBloq.split(',');
                    var descBloq = objCompleto.descricaoBloq.replace(/\[+/g, '').replace(/\]+/g, '');
                    descBloq = descBloq.split(',');
                    for (var i = 0; i < valorBloq.length; i++) {
                        gerenciarMostrarVeiculos(objCompleto.nomeBloq, valorBloq[i], objCompleto.condicaoBloq, descBloq[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeCat && objCompleto.valorCat) {
                    var valorCat = objCompleto.valorCat.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorCat = valorCat.split(',');
                    var descCat = objCompleto.descricaoCat.replace(/\[+/g, '').replace(/\]+/g, '');
                    descCat = descCat.split(',');
                    for (var i = 0; i < valorCat.length; i++) {
                        gerenciarMostrarVeiculos(objCompleto.nomeCat, valorCat[i], objCompleto.condicaoCat, descCat[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeTF && objCompleto.valorTF) {
                    var valorTF = objCompleto.valorTF.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorTF = valorTF.split(',');
                    var descTF = objCompleto.descricaoTF.replace(/\[+/g, '').replace(/\]+/g, '');
                    descTF = descTF.split(',');
                    for (var i = 0; i < valorTF.length; i++) {
                        gerenciarMostrarVeiculos(objCompleto.nomeTF, valorTF[i], objCompleto.condicaoTF, descTF[i]);
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

function gerenciarMostrarVeiculos(name, valor, condicao, descricao) {
    valor = valor.trim();
    if (name == 'bloqueado') {
        if (valor == 'Sim') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[1]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-veiculo option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'Não') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[2]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-veiculo option[value="' + condicao + '"]').attr('selected', 'selected');
        }
    }
    if (name == 'categoria') {
        if (valor == 'Terrestre') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[4]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-veiculo option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'Aquaviário') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[5]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-veiculo option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'Equipamento') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[6]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-veiculo option[value="' + condicao + '"]').attr('selected', 'selected');
        }
    }
    if (name == 'tipo_frota') {
        if (valor == 'Próprio') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[8]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-veiculo option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'Agregado') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[9]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-veiculo option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'Carreteiro') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[10]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-veiculo option[value="' + condicao + '"]').attr('selected', 'selected');
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

        setTimeout(function () {
            var i = 0;
            while (valor[i]) {
                jQuery('#filtros-adicionais-container').show();
                addValorAlphaInput('inptCidade', descricao[i].trim(), valor[i].trim());
                i++;
            }
        }, 500);
    }
}

function gerenciarInpProprietario(nome, valor, descricao, condicao) {
    if (nome == 'proprietario_id') {
        jQuery('#select-exceto-apenas-proprietario option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptProprietario', descricao[i].trim(), valor[i].trim());
        }
    }
}

function gerenciarInpMarca(nome, valor, descricao, condicao) {
    if (nome == 'marca_id') {
        jQuery('#select-exceto-apenas-marca option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptMarca', descricao[i].trim(), valor[i].trim());
        }
    }
}

function gerenciarInpTipoVeiculo(nome, valor, descricao, condicao) {
    if (nome == 'tipo_veiculo_id') {
        jQuery('#select-exceto-apenas-tipo-veiculo option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptTipoVeiculo', descricao[i].trim(), valor[i].trim());
        }
    }
}

function enviarMotoristaEfrete(e) {
    var ordem = $(e).parent().parent().attr('ordem');
    var id = $('#hi_row_id_' + ordem).val();

    $('.container-envio-motorista').show();
    $.ajax({
        url: 'EFreteControlador?acao=enviarVeiculo&idVeiculo=' + id,
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
        url: 'ExpersControlador?acao=enviarVeiculoExpers&idVeiculo=' + id,
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
        url: 'PagBemControlador?acao=enviarVeiculoPagBem&idVeiculo=' + id,
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
        url: 'RepomControlador?acao=enviarVeiculoRepom&idVeiculo=' + id,
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


// função para exclusão dos documentos do veiculo.
function excluirImagem() {
    var msg = 'Deseja mesmo excluir essa Imagem no Cadastro de Veiculo?';
    if (iframeVisualizarDocumentos.getValueCheckMarcados().split(',')[1] != undefined) {
        msg = 'Deseja mesmo excluir essas Imagens no Cadastro de Veiculo?';
    }
    chamarConfirm(msg, 'iframeVisualizarDocumentos.excluir()', 'null');
}

function colorirColunasBloqueados() {
    jQuery("input[id^='hi_row_bloqueado_'][value='Sim']")
        .parents("tr")
        .attr('style',"color: red !important;")
        .find("label")
        .attr('style', "color: inherit !important;");
}