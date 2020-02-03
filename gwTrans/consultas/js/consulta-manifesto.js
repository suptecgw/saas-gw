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
    location.replace("./cadmanifesto?acao=editar&id=" + id);
}

function consulta() {
    var qtdCarac = 0;
    var valor = jQuery("#inpSelectVal").val();
    if (jQuery("#select-oper").val() == '1' || jQuery("#select-oper").val() == '2' || jQuery("#select-oper").val() == '3') {
        for (var i = 0; i < valor.split("!@!").length; i++) {
            if (valor.split("!@!")[i]) {
                qtdCarac = valor.split("!@!")[i].length;
                if (qtdCarac < 3 ) {
                    chamarAlert("Para filtros ( Todas as Partes , Apenas no fim, Apenas no inicio ) é necessário preencher ao menos 3 caractéries!");
                    return false;
                }
            }
        }
    }
    jQuery("#formConsulta").submit();
}

function excluir(item) {
    var index = 0;
    var ids = '';
    var nomes = '';

    if (item == undefined) {
        while (jQuery('input:checked[type=checkbox][name*=nCheck]')[index] != undefined) {

            var val = jQuery('input:checked[type=checkbox][name*=nCheck]')[index].value;
            var id = jQuery('#hi_row_id_' + val).val();
            var nome = jQuery('#hi_row_num_manifesto_' + val).val();

            if (jQuery('input:checked[type=checkbox][name*=nCheck]')[index + 1] != undefined) {
                ids += id + ',';
            } else {
                ids += id;
            }

            nomes += '<li>' + nome + '</li>';

            index++;
        }
    } else if (item != undefined) {
        ids = jQuery('#hi_row_id_' + item).val();
        nomes = jQuery('#hi_row_num_manifesto_' + item).val();
    }

    var texto = "";
    if (index > 1) {
        texto = "Deseja excluir os manifestos abaixo?";
    } else {
        texto = "Deseja excluir o manifesto abaixo?";
    }
    chamarConfirm(texto, 'aceitouExcluirManifesto("' + ids + '")', '', 1, '<ul class="square">' + nomes + '</ul>');

}

function aceitouExcluirManifesto(ids) {
    jQuery.ajax({
        url: 'ManifestoControlador?acao=excluir&ids=' + ids,
        success: function (data, textStatus, jqXHR) {
            chamarAlert(data, reload);
        }
    });
}

function reload() {
    window.location.reload();
}

jQuery(document).ready(function () {

    jQuery('#select-tipo-manifesto').selectGrupoMultiploGw({
        input: 'select-tipo-manifesto',
        grupos: {
            Status: {
                1: 'Manifesto!!pre_manifesto!!Não!!IGUAL',
                2: 'Pré-Manifesto!!pre_manifesto!!Sim!!IGUAL'
            },
            Local: {
                1: 'Depósito de Origem!!status!!Depósito Origem!!IGUAL',
                2: 'Em Trânsito!!status!!Em Trânsito!!Em Trânsito!!IGUAL',
                3: 'Depósito de Destino!!status!!Depósito Destino!!IGUAL'
            },
            Modal: {
                1: 'Rodoviário!!modal!!Rodoviário!!IGUAL',
                2: 'Aéreo!!modal!!Aéreo!!IGUAL',
                3: 'Aquaviário!!modal!!Aquaviário!!IGUAL'
            }
        }
    });

    jQuery('#footerTable').show();

    jQuery('#select-status-mdfe').selectMultiploGw({
        'titulo': 'Apenas os Status'
    });

    jQuery('#inptFilial').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptMotorista').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptVeiculo').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptCarreta').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptAerea').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptRedespachante').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptAeroOrigem').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptAeroDestino').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptRota').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    }); 
    
    jQuery('#inptFilialDestino').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery("#paneConsulta").css('height', jQuery(window).height() - 300);

    jQuery('input[name="formaImpressao"]').change(function () {
        if (jQuery(this).val() === '0') {
            ativarImpressaoPDF();
        } else if (jQuery(this).val() === '1') {
            ativarImpressaoMatricial();
        } else if (jQuery(this).val() === '2') {
            ativarExportacao();
        }
    });


    //Float responsavel pelo alinhamento do modelo de impressão
    jQuery('span[aria-owns="cbmodelo-menu"]').css('float', 'left');
    jQuery('span[aria-owns="cbmodelo-menu"]').css('width', '97%');

    jQuery('span[aria-owns="caminho_impressora-menu"]').css('float', 'left');
    jQuery('span[aria-owns="caminho_impressora-menu"]').css('width', '97%');
    jQuery('span[aria-owns="caminho_impressora-menu"]').hide();

    jQuery('span[aria-owns="driverImpressora-menu"]').css('float', 'left');
    jQuery('span[aria-owns="driverImpressora-menu"]').css('width', '97%');
    jQuery('span[aria-owns="driverImpressora-menu"]').hide();

    jQuery('span[aria-owns="exportarPara-menu"]').css('float', 'left');
    jQuery('span[aria-owns="exportarPara-menu"]').css('width', '97%');
    jQuery('span[aria-owns="exportarPara-menu"]').hide(250);
    jQuery('[exportar]').hide();

    var x = 0;
    while (jQuery('[impressaoMatricial]')[x]) {
        jQuery(jQuery('[impressaoMatricial]')[x]).hide();
        x++;
    }

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

function ativarExcetosMultiplosGw() {
    jQuery('#select-exceto-apenas-tipo-manifesto').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-motorista').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-veiculo').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-carreta').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-status-mdfe').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-aerea').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-redespachante').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-aero-origem').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-aero-destino').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-rota').selectExcetoApenasGw({
        width: '170px'
    });
}

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
                removerValorInput('select-tipo-manifesto');
                removerValorInput('inpSelectVal');
                removerValorInput('inptFilial');
                removerValorInput('inptMotorista');
                removerValorInput('inptVeiculo');
                removerValorInput('inptCarreta');
                removerValorInput('inptAerea');
                removerValorInput('inptRedespachante');
                removerValorInput('inptAeroOrigem');
                removerValorInput('inptAeroDestino');
                removerValorInput('inptRota');
                jQuery('#filtros-adicionais-container').hide();

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
                    var filiais = objCompleto.valorFilial.replace(/\[+/g, '').replace(/\]+/g, '');
                    filiais = filiais.split(',');

                    var nomeFilial = objCompleto.descricaoFilial.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeFilial = nomeFilial.split(',');

                    for (var i = 0; i < filiais.length; i++) {
                        addValorAlphaInput('inptFilial', nomeFilial[i], filiais[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }
                
                if (objCompleto.nomeFilialDest != null && objCompleto.nomeFilialDest != undefined) {
                    var filiais = objCompleto.valorFilial.replace(/\[+/g, '').replace(/\]+/g, '');
                    filiais = filiais.split(',');

                    var nomeFilialDest = objCompleto.descricaoFilial.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeFilialDest = nomeFilialDest.split(',');

                    for (var i = 0; i < filiais.length; i++) {
                        addValorAlphaInput('inptFilialDestino', nomeFilialDest[i], filiais[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeMotorista != null && objCompleto.nomeMotorista != undefined) {
                    var motoristas = objCompleto.valorMotorista.replace(/\[+/g, '').replace(/\]+/g, '');
                    motoristas = motoristas.split(',');

                    var nomeMotorista = objCompleto.descricaoMotorista.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeMotorista = nomeMotorista.split(',');

                    for (var i = 0; i < motoristas.length; i++) {
                        addValorAlphaInput('inptMotorista', nomeMotorista[i], motoristas[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeVeiculo != null && objCompleto.nomeVeiculo != undefined) {
                    var veiculos = objCompleto.valorVeiculo.replace(/\[+/g, '').replace(/\]+/g, '');
                    veiculos = veiculos.split(',');

                    var nomeVeiculo = objCompleto.descricaoVeiculo.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeVeiculo = nomeVeiculo.split(',');

                    for (var i = 0; i < veiculos.length; i++) {
                        addValorAlphaInput('inptVeiculo', nomeVeiculo[i], veiculos[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeCarreta != null && objCompleto.nomeCarreta != undefined) {
                    var carretas = objCompleto.valorCarreta.replace(/\[+/g, '').replace(/\]+/g, '');
                    carretas = carretas.split(',');

                    var nomeCarreta = objCompleto.descricaoCarreta.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeCarreta = nomeCarreta.split(',');

                    for (var i = 0; i < carretas.length; i++) {
                        addValorAlphaInput('inptCarreta', nomeCarreta[i], carretas[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeAerea != null && objCompleto.nomeAerea != undefined) {
                    var aereas = objCompleto.valorAerea.replace(/\[+/g, '').replace(/\]+/g, '');
                    aereas = aereas.split(',');

                    var nomeAerea = objCompleto.descricaoAerea.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeAerea = nomeAerea.split(',');

                    for (var i = 0; i < aereas.length; i++) {
                        addValorAlphaInput('inptAerea', nomeAerea[i], aereas[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeRedespachante != null && objCompleto.nomeRedespachante != undefined) {
                    var redespachantes = objCompleto.valorRedespachante.replace(/\[+/g, '').replace(/\]+/g, '');
                    redespachantes = redespachantes.split(',');

                    var nomeRedespachante = objCompleto.descricaoRedespachante.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeRedespachante = nomeRedespachante.split(',');

                    for (var i = 0; i < redespachantes.length; i++) {
                        addValorAlphaInput('inptRedespachante', nomeRedespachante[i], redespachantes[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeAeroOrigem != null && objCompleto.nomeAeroOrigem != undefined) {
                    var aeroOrigem = objCompleto.valorAeroOrigem.replace(/\[+/g, '').replace(/\]+/g, '');
                    aeroOrigem = aeroOrigem.split(',');

                    var nomeAeroOrigem = objCompleto.descricaoAeroOrigem.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeAeroOrigem = nomeAeroOrigem.split(',');

                    for (var i = 0; i < aeroOrigem.length; i++) {
                        addValorAlphaInput('inptAeroOrigem', nomeAeroOrigem[i], aeroOrigem[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeAeroDestino != null && objCompleto.nomeAeroDestino != undefined) {
                    var aeroDestino = objCompleto.valorAeroDestino.replace(/\[+/g, '').replace(/\]+/g, '');
                    aeroDestino = aeroDestino.split(',');

                    var nomeAeroDestino = objCompleto.descricaoAeroDestino.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeAeroDestino = nomeAeroDestino.split(',');

                    for (var i = 0; i < aeroDestino.length; i++) {
                        addValorAlphaInput('inptAeroDestino', nomeAeroDestino[i], aeroDestino[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeRota != null && objCompleto.nomeRota != undefined) {
                    var rotas = objCompleto.valorRota.replace(/\[+/g, '').replace(/\]+/g, '');
                    rotas = rotas.split(',');

                    var nomeRota = objCompleto.descricaoRota.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeRota = nomeRota.split(',');

                    for (var i = 0; i < rotas.length; i++) {
                        addValorAlphaInput('inptRota', nomeRota[i], rotas[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeModal != null && objCompleto.nomeModal != undefined) {
                    var valorModal = objCompleto.valorModal.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorModal = valorModal.split(',');
                    var descModal = objCompleto.descricaoModal.replace(/\[+/g, '').replace(/\]+/g, '');
                    descModal = descModal.split(',');
                    for (var i = 0; i < valorModal.length; i++) {
                        gerenciarMostrarManifestos(objCompleto.nomeModal, valorModal[i], objCompleto.condicaoModal, descModal[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomePreManifesto != null && objCompleto.nomePreManifesto != undefined) {
                    var valorPreMani = objCompleto.valorPreManifesto.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorPreMani = valorPreMani.split(',');
                    var descPreMani = objCompleto.descricaoPreManifesto.replace(/\[+/g, '').replace(/\]+/g, '');
                    descPreMani = descPreMani.split(',');
                    for (var i = 0; i < valorPreMani.length; i++) {
                        gerenciarMostrarManifestos(objCompleto.nomePreManifesto, valorPreMani[i], objCompleto.condicaoPreManifesto, descPreMani[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeStatus != null && objCompleto.nomeStatus != undefined) {
                    var valorStatus = objCompleto.valorStatus.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorStatus = valorStatus.split(',');
                    var descStatus = objCompleto.descricaoStatus.replace(/\[+/g, '').replace(/\]+/g, '');
                    descStatus = descStatus.split(',');
                    for (var i = 0; i < valorStatus.length; i++) {
                        gerenciarMostrarManifestos(objCompleto.nomeStatus, valorStatus[i], objCompleto.condicaoStatus, descStatus[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeStatusMdfe != null && objCompleto.nomeStatusMdfe != undefined) {
                    var status = objCompleto.valorStatusMdfe.replace(/\[+/g, '').replace(/\]+/g, '');
                    status = status.split(',');

                    for (var i = 0; i < status.length; i++) {
                        jQuery('.container-select-multiplo-gw-A').find('#' + status[i]).trigger('click');
                        jQuery('.container-li-valores').hide();
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                jQuery('.container-select-multiplo-gw-A').find('#encerrado').trigger('click');

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
        if (nome == 'data_saida') {
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
        } else if (nome == 'prev_chegada') {
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
        } else if (nome == 'prev_embarque') {
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
        } else if (nome == 'criado_em') {
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
        } else if (nome == 'alterado_em') {
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
    if (nome == 'criado_por_id') {
        jQuery('#createdMe').prop('checked', true);
        jQuery('#filtros-adicionais-container').show();
    }
}

function gerenciarMostrarManifestos(name, valor, condicao, descricao) {
    valor = valor.trim();
    if (name == 'pre_manifesto') {
        if (valor == 'Não') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[1]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-manifesto option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'Sim') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[2]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-manifesto option[value="' + condicao + '"]').attr('selected', 'selected');
        }
    }
    if (name == 'status') {
        if (valor == 'Depósito Origem') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[4]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-manifesto option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'Em Trânsito') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[5]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-manifesto option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'Depósito Destino') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[6]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-manifesto option[value="' + condicao + '"]').attr('selected', 'selected');
        }
    }
    if (name == 'modal') {
        if (valor == 'Rodoviário') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[8]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-manifesto option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'Aéreo') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[9]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-manifesto option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'Aquaviário') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[10]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-manifesto option[value="' + condicao + '"]').attr('selected', 'selected');
        }
    }
    jQuery('.container-li-valores').hide();
}

function gerenciarStatusMDFE(nome, valor, condicao, descricao) {
    var valorExiste = jQuery('#tipos-escolhidos').val();
    var valorExisteId = jQuery('#id-tipos-escolhidos').val();
    
    sessionStorage.setItem('nao_mostrar_opcoes_select_multiplo', 'true');
    if (nome == 'status_mdfe') {
        if (valor == 'Pendente') {
            jQuery('.container-select-multiplo-gw-A').find('#Pendente').trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-status-mdfe option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == "Enviado") {
            jQuery('.container-select-multiplo-gw-A').find('#Enviado').trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-status-mdfe option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == "Negado") {
            jQuery('.container-select-multiplo-gw-A').find('#Negado').trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-status-mdfe option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == "Confirmado") {
            jQuery('.container-select-multiplo-gw-A').find('#Confirmado').trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-status-mdfe option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == "Cancelado") {
            jQuery('.container-select-multiplo-gw-A').find('#Cancelado').trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-status-mdfe option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == "Encerrado") {
            jQuery('.container-select-multiplo-gw-A').find('#Encerrado').trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-status-mdfe option[value="' + condicao + '"]').attr('selected', 'selected');
        }
        jQuery('.container-li-valores').hide();
    }
        sessionStorage.removeItem('nao_mostrar_opcoes_select_multiplo');
}


function gerenciarInpFilial(nome, valor, descricao, condicao) {
    if (nome == 'id_filial') {
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

function gerenciarInpFilialDestino(nome, valor, descricao, condicao) {
    if (nome == 'id_filial_destino') {
        jQuery('#select-exceto-apenas-filial-destino option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptFilialDestino', descricao[i].trim(), valor[i].trim());
        }
    }
}

function gerenciarInpMotorista(nome, valor, descricao, condicao) {
    if (nome == 'motorista_id') {
        jQuery('#select-exceto-apenas-motorista option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptMotorista', descricao[i].trim(), valor[i].trim());
        }
    }
}

function gerenciarInpVeiculo(nome, valor, descricao, condicao) {
    if (nome == 'veiculo_id') {
        jQuery('#select-exceto-apenas-veiculo option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptVeiculo', descricao[i].trim(), valor[i].trim());
        }
    }
}

function gerenciarInpCarreta(nome, valor, descricao, condicao) {
    if (nome == 'carreta_id') {
        jQuery('#select-exceto-apenas-carreta option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptCarreta', descricao[i].trim(), valor[i].trim());
        }
    }
}

function gerenciarInpAerea(nome, valor, descricao, condicao) {
    if (nome == 'companhia_aerea_id') {
        jQuery('#select-exceto-apenas-aerea option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptAerea', descricao[i].trim(), valor[i].trim());
        }
    }
}

function gerenciarInpRedespachante(nome, valor, descricao, condicao) {
    if (nome == 'redespachante_id') {
        jQuery('#select-exceto-apenas-redespachante option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptRedespachante', descricao[i].trim(), valor[i].trim());
        }
    }
}

function gerenciarInpAeroOrigem(nome, valor, descricao, condicao) {
    if (nome == 'aeroporto_origem_id') {
        jQuery('#select-exceto-apenas-aero-origem option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptAeroOrigem', descricao[i].trim(), valor[i].trim());
        }
    }
}

function gerenciarInpAeroDestino(nome, valor, descricao, condicao) {
    if (nome == 'aeroporto_destino_id') {
        jQuery('#select-exceto-apenas-aero-destino option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptAeroDestino', descricao[i].trim(), valor[i].trim());
        }
    }
}

function gerenciarInpRota(nome, valor, descricao, condicao) {
    if (nome == 'rota_id') {
        jQuery('#select-exceto-apenas-rota option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptRota', descricao[i].trim(), valor[i].trim());
        }
    }
}

function abrirLocalizarFilial() {
    //Reduz o z-index do lb-filtros para ele nao parecer
    jQuery('.div-lb-filtros').css('z-index', '99');
    var filial = jQuery('#inptFilial').val();

    jQuery('.localizarFilial').show('show');
    jQuery('.cobre-tudo').show('show');
    if (localizarFilial.document.getElementById('chkOpcoesAvancadas').checked && filial !== undefined && filial.trim() !== '') {
        var i = 0;
        while (filial.split('!@!')[i] != null) {
            localizarFilial.popularListaFiliaisEscolhidas(filial.split('!@!')[i]);
            i++;
        }
    }
}

function abrirLocalizarMotorista() {
    //Reduz o z-index do lb-filtros para ele nao parecer
    jQuery('.div-lb-filtros').css('z-index', '99');
    var motorista = jQuery('#inptMotorista').val();

    jQuery('.localizarMotorista').show('show');
    jQuery('.cobre-tudo').show('show');
    if (localizarMotorista.document.getElementById('chkOpcoesAvancadas').checked && motorista !== undefined && motorista.trim() !== '') {
        var i = 0;
        while (motorista.split('!@!')[i] != null) {
            localizarMotorista.popularListaMotoristasEscolhidos(motorista.split('!@!')[i]);
            i++;
        }
    }
}

function abrirLocalizarVeiculo() {
    //Reduz o z-index do lb-filtros para ele nao parecer
    jQuery('.div-lb-filtros').css('z-index', '99');
    var veiculo = jQuery('#inptVeiculo').val();

    jQuery('.localizarVeiculo').show('show');
    jQuery('.cobre-tudo').show('show');
    if (localizarVeiculo.document.getElementById('chkOpcoesAvancadas').checked && veiculo !== undefined && veiculo.trim() !== '') {
        var i = 0;
        while (veiculo.split('!@!')[i] != null) {
            localizarVeiculo.popularListaVeiculosEscolhidos(veiculo.split('!@!')[i]);
            i++;
        }
    }
}

function abrirLocalizarCarreta() {
    //Reduz o z-index do lb-filtros para ele nao parecer
    jQuery('.div-lb-filtros').css('z-index', '99');
    var carreta = jQuery('#inptCarreta').val();

    jQuery('.localizarCarreta').show('show');
    jQuery('.cobre-tudo').show('show');
    if (localizarCarreta.document.getElementById('chkOpcoesAvancadas').checked && carreta !== undefined && carreta.trim() !== '') {
        var i = 0;
        while (carreta.split('!@!')[i] != null) {
            localizarCarreta.popularListaVeiculosEscolhidos(carreta.split('!@!')[i]);
            i++;
        }
    }
}

function abrirLocalizarAerea() {
    console.log("CHEGOU NO ABRIR");
    //Reduz o z-index do lb-filtros para ele nao parecer
    jQuery('.div-lb-filtros').css('z-index', '99');
    var aerea = jQuery('#inptAerea').val();

    jQuery('.localizarAerea').show('show');
    jQuery('.cobre-tudo').show('show');
    // if (localizarAerea.document.getElementById('chkOpcoesAvancadas').checked && aerea !== undefined && aerea.trim() !== '') {
    //  var i = 0;
    //  while (aerea.split('!@!')[i] != null) {
    //   localizarAerea.popularListaAereasEscolhidas(aerea.split('!@!')[i]);
    //   i++;
    //    }
    // }
}

function abrirLocalizarRedespachante() {
    //Reduz o z-index do lb-filtros para ele nao parecer
    jQuery('.div-lb-filtros').css('z-index', '99');
    var redespachante = jQuery('#inptRedespachante').val();

    jQuery('.localizarRedespachante').show('show');
    jQuery('.cobre-tudo').show('show');
    if (localizarRedespachante.document.getElementById('chkOpcoesAvancadas').checked && redespachante !== undefined && redespachante.trim() !== '') {
        var i = 0;
        while (redespachante.split('!@!')[i] != null) {
            localizarRedespachante.popularListaAereasEscolhidas(redespachante.split('!@!')[i]);
            i++;
        }
    }
}

function abrirLocalizarAeroOrigem() {
    //Reduz o z-index do lb-filtros para ele nao parecer
    jQuery('.div-lb-filtros').css('z-index', '99');
    var aeroOrigem = jQuery('#inptAeroOrigem').val();

    jQuery('.localizarAeroOrigem').show('show');
    jQuery('.cobre-tudo').show('show');
    if (localizarAeroOrigem.document.getElementById('chkOpcoesAvancadas').checked && aeroOrigem !== undefined && aeroOrigem.trim() !== '') {
        var i = 0;
        while (aeroOrigem.split('!@!')[i] != null) {
            localizarAeroOrigem.popularListaAeroportosEscolhidos(aeroOrigem.split('!@!')[i]);
            i++;
        }
    }
}

function abrirLocalizarAeroDestino() {
    //Reduz o z-index do lb-filtros para ele nao parecer
    jQuery('.div-lb-filtros').css('z-index', '99');
    var aeroDestino = jQuery('#inptAeroDestino').val();

    jQuery('.localizarAeroDestino').show('show');
    jQuery('.cobre-tudo').show('show');
    if (localizarAeroDestino.document.getElementById('chkOpcoesAvancadas').checked && aeroDestino !== undefined && aeroDestino.trim() !== '') {
        var i = 0;
        while (aeroDestino.split('!@!')[i] != null) {
            localizarAeroDestino.popularListaAeroportosEscolhidos(aeroDestino.split('!@!')[i]);
            i++;
        }
    }
}

function abrirLocalizarRota() {
    //Reduz o z-index do lb-filtros para ele nao parecer
    jQuery('.div-lb-filtros').css('z-index', '99');
    var rota = jQuery('#inptRota').val();

    jQuery('.localizarRota').show('show');
    jQuery('.cobre-tudo').show('show');
    if (localizarRota.document.getElementById('chkOpcoesAvancadas').checked && rota !== undefined && rota.trim() !== '') {
        var i = 0;
        while (rota.split('!@!')[i] != null) {
            localizarRota.popularListaRotasEscolhidas(rota.split('!@!')[i]);
            i++;
        }
    }
}

function controleLocalizarFiliais(acao, parametros, apagarDadosInput) {
    if (acao === 'fechar') {
        jQuery('.localiza').hide('show');
        jQuery('.cobre-tudo').hide('show');
        //Restaura o z-index do div-lb-filtros para ele aparecer
        jQuery('.div-lb-filtros').css('z-index', '999999');
    } else if (acao === 'finalizado') {
        controleLocalizarFiliais('fechar', null);
        if (apagarDadosInput === true) {
            removerValorInput('inptFilial');
        }
        addValorAlphaInput('inptFilial', parametros.split("!@!")[0], parametros.split('!@!')[1]);
        localizarFilial.voltarTodosItens();
    } else if (acao === 'mensagem') {
        chamarAlert(parametros, null);
        localizarFilial.voltarTodosItens();
    }
}

function controleLocalizarMotoristas(acao, parametros, apagarDadosInput) {
    if (acao === 'fechar') {
        jQuery('.localiza').hide('show');
        jQuery('.cobre-tudo').hide('show');
        //Restaura o z-index do div-lb-filtros para ele aparecer
        jQuery('.div-lb-filtros').css('z-index', '999999');
    } else if (acao === 'finalizado') {
        controleLocalizarMotoristas('fechar', null);
        if (apagarDadosInput === true) {
            removerValorInput('inptMotorista');
        }
        addValorAlphaInput('inptMotorista', parametros.split("!@!")[0], parametros.split('!@!')[1]);
        localizarMotorista.voltarTodosItens();
    } else if (acao === 'mensagem') {
        chamarAlert(parametros, null);
        localizarMotorista.voltarTodosItens();
    }
}

function controleLocalizarVeiculos(acao, parametros, apagarDadosInput) {
    if (acao === 'fechar') {
        jQuery('.localiza').hide('show');
        jQuery('.cobre-tudo').hide('show');
        //Restaura o z-index do div-lb-filtros para ele aparecer
        jQuery('.div-lb-filtros').css('z-index', '999999');
    } else if (acao === 'finalizado') {
        controleLocalizarVeiculos('fechar', null);
        if (apagarDadosInput === true) {
            removerValorInput('inptVeiculo');
        }
        addValorAlphaInput('inptVeiculo', parametros.split("!@!")[0], parametros.split('!@!')[1]);
        localizarVeiculo.voltarTodosItens();
    } else if (acao === 'mensagem') {
        chamarAlert(parametros, null);
        localizarVeiculo.voltarTodosItens();
    }
}

function controleLocalizarCarretas(acao, parametros, apagarDadosInput) {
    if (acao === 'fechar') {
        jQuery('.localiza').hide('show');
        jQuery('.cobre-tudo').hide('show');
        //Restaura o z-index do div-lb-filtros para ele aparecer
        jQuery('.div-lb-filtros').css('z-index', '999999');
    } else if (acao === 'finalizado') {
        controleLocalizarCarretas('fechar', null);
        if (apagarDadosInput === true) {
            removerValorInput('inptCarreta');
        }
        addValorAlphaInput('inptCarreta', parametros.split("!@!")[0], parametros.split('!@!')[1]);
        localizarCarreta.voltarTodosItens();
    } else if (acao === 'mensagem') {
        chamarAlert(parametros, null);
        localizarCarreta.voltarTodosItens();
    }
}

function controleLocalizarAereas(acao, parametros, apagarDadosInput) {
    if (acao === 'fechar') {
        jQuery('.localiza').hide('show');
        jQuery('.cobre-tudo').hide('show');
        //Restaura o z-index do div-lb-filtros para ele aparecer
        jQuery('.div-lb-filtros').css('z-index', '999999');
    } else if (acao === 'finalizado') {
        controleLocalizarAereas('fechar', null);
        if (apagarDadosInput === true) {
            removerValorInput('inptAerea');
        }
        addValorAlphaInput('inptAerea', parametros.split("!@!")[0], parametros.split('!@!')[1]);
        localizarAerea.voltarTodosItens();
    } else if (acao === 'mensagem') {
        chamarAlert(parametros, null);
        localizarAerea.voltarTodosItens();
    }
}

function controleLocalizarRedespachantes(acao, parametros, apagarDadosInput) {
    if (acao === 'fechar') {
        jQuery('.localiza').hide('show');
        jQuery('.cobre-tudo').hide('show');
        //Restaura o z-index do div-lb-filtros para ele aparecer
        jQuery('.div-lb-filtros').css('z-index', '999999');
    } else if (acao === 'finalizado') {
        controleLocalizarRedespachantes('fechar', null);
        if (apagarDadosInput === true) {
            removerValorInput('inptRedespachante');
        }
        addValorAlphaInput('inptRedespachante', parametros.split("!@!")[0], parametros.split('!@!')[1]);
        localizarRedespachante.voltarTodosItens();
    } else if (acao === 'mensagem') {
        chamarAlert(parametros, null);
        localizarRedespachante.voltarTodosItens();
    }
}

function controleLocalizarAeroOrigem(acao, parametros, apagarDadosInput) {
    if (acao === 'fechar') {
        jQuery('.localiza').hide('show');
        jQuery('.cobre-tudo').hide('show');
        //Restaura o z-index do div-lb-filtros para ele aparecer
        jQuery('.div-lb-filtros').css('z-index', '999999');
    } else if (acao === 'finalizado') {
        controleLocalizarAeroOrigem('fechar', null);
        if (apagarDadosInput === true) {
            removerValorInput('inptAeroOrigem');
        }
        addValorAlphaInput('inptAeroOrigem', parametros.split("!@!")[0], parametros.split('!@!')[1]);
        localizarAeroOrigem.voltarTodosItens();
    } else if (acao === 'mensagem') {
        chamarAlert(parametros, null);
        localizarAeroOrigem.voltarTodosItens();
    }
}

function controleLocalizarAeroDestino(acao, parametros, apagarDadosInput) {
    if (acao === 'fechar') {
        jQuery('.localiza').hide('show');
        jQuery('.cobre-tudo').hide('show');
        //Restaura o z-index do div-lb-filtros para ele aparecer
        jQuery('.div-lb-filtros').css('z-index', '999999');
    } else if (acao === 'finalizado') {
        controleLocalizarAeroDestino('fechar', null);
        if (apagarDadosInput === true) {
            removerValorInput('inptAeroDestino');
        }
        addValorAlphaInput('inptAeroDestino', parametros.split("!@!")[0], parametros.split('!@!')[1]);
        localizarAeroDestino.voltarTodosItens();
    } else if (acao === 'mensagem') {
        chamarAlert(parametros, null);
        localizarAeroDestino.voltarTodosItens();
    }
}

function controleLocalizarRota(acao, parametros, apagarDadosInput) {
    if (acao === 'fechar') {
        jQuery('.localiza').hide('show');
        jQuery('.cobre-tudo').hide('show');
        //Restaura o z-index do div-lb-filtros para ele aparecer
        jQuery('.div-lb-filtros').css('z-index', '999999');
    } else if (acao === 'finalizado') {
        console.log("CHEGOU NA AÇÃO");
        controleLocalizarRota('fechar', null);
        if (apagarDadosInput === true) {
            removerValorInput('inptRota');
        }
        addValorAlphaInput('inptRota', parametros.split("!@!")[0], parametros.split('!@!')[1]);
        localizarRota.voltarTodosItens();
    } else if (acao === 'mensagem') {
        chamarAlert(parametros, null);
        localizarRota.voltarTodosItens();
    }
}

function abrirImportacao(index, tipo) {
    var id = jQuery('#hi_row_id_' + index).val();
    var numManifesto = jQuery('#hi_row_num_manifesto_' + index).val();
    launchPopupLocate("./ConferenciaControlador?acao=importarArquivo&id=" + id + "&tipo_operacao=" + tipo + "&layout=t", "Manifesto");
}

function popManifestoGeral(position) {
    var countDiferenca = 0;
    var modeloMinutaAtual = "";
    var companhia = "";
    var modelo = jQuery('#cbmodelo-button').find('.ui-selectmenu-text').html();
    var valorModelo = modelo.substring(7, 9).trim();
    if (modelo.indexOf('Personalizado') != -1) {
        valorModelo = jQuery('#cbmodelo').val();
    }
    var ids = '';

    if (!position) {
        var index = 0;
        var nomes = '';

        while (jQuery('input:checked[type=checkbox][name*=nCheck]')[index] != undefined) {
            var val = jQuery('input:checked[type=checkbox][name*=nCheck]')[index].value;
            var id = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().parent().find('#hi_row_id_' + val).val();
            var modeloMinuta = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().parent().find('#hi_row_modelo_minuta_' + val).val();
            if(modeloMinutaAtual != modeloMinuta) {
                countDiferenca = countDiferenca + 1;
                modeloMinutaAtual = modeloMinuta;
            }
            if(modeloMinuta != "") {
                if(modeloMinuta == 0) {
                    companhia = "tamcargo";
                } else if(modeloMinuta == 1) {
                    companhia = "azulcargo";
                } else if(modeloMinuta == 2) {
                    companhia = "aviancacargo";
                }
            }
            
            if (jQuery('input:checked[type=checkbox][name*=nCheck]')[index + 1] != undefined) {
                ids += id + ',';
            } else {
                ids += id;
            }
            index++;
        }
        if (ids == undefined || ids == "") {
            chamarAlert("Selecione pelo menos um manifesto!");
            return null;
        }
        if (valorModelo == 16 && countDiferenca > 1) {
            chamarAlert("Selecione AWBs da mesma companhia aérea");
            return null;
        }
        if(valorModelo == 16 && modeloMinutaAtual == "") {
            chamarAlert("Selecione pelo menos uma AWB");
            return null;
        }
    } else {
        ids = jQuery('#hi_row_id_' + position).val();
    }
    launchPDF('./consultamanifesto?acao=exportar&modelo=' + valorModelo + '&id=' + ids + '&modeloMinuta=' + companhia,
            'manifesto' + ids);
    jQuery.ajax({
        url: './consultamanifesto?acao=enviarEmail&idManif=' + ids,
        success: function (data) {
        }
    });
}

function launchPDF(url, idname) {
    var cf = 'top=0,left=0,height=600,width=800,resizable=yes,status=1,scrollbars=1';
    var pdf = window.open(url, idname, cf);
    pdf.window.resizeTo(screen.width, screen.height - 20);
    pdf.focus();
}



function exportar(roteirizador, filialCNPJ) {
    var primeiroManifesto = "";
    var index = 0;
    var manifestos = '';

    while (jQuery('input:checked[type=checkbox][name*=nCheck]')[index] != undefined) {

        var val = jQuery('input:checked[type=checkbox][name*=nCheck]')[index].value;
        var id = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().parent().find('#hi_row_id_' + val).val();
        var nmanifesto = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().parent().find('#hi_row_num_manifesto_' + val).val();

        if (primeiroManifesto == "") {
            primeiroManifesto = nmanifesto;
        }

        if (jQuery('input:checked[type=checkbox][name*=nCheck]')[index + 1] != undefined) {
            manifestos += id + ',';
        } else {
            manifestos += id;
        }
        index++;
    }

    var modelo = jQuery('#exportarPara').val();

    if (manifestos == "") {
        chamarAlert("Seleciona pelo menos um Manifesto");
        return null;
    }

    if (modelo == '-') {
        alert('Escolha um layout de exportação corretamente!');
        return false;
    } else if (modelo == 'FRONTDIG') {
        document.location.href = './manifesto' + primeiroManifesto + '.txt2?idmanifesto=' + manifestos + '&modelo=manif';
    } else if (modelo == 'ATM') {
        document.location.href = './averbacao.txt4?ids=' + manifestos + '&modelo=MANIF';
    } else if (modelo == 'ATM-M') {
        document.location.href = './averbacao.txt4?ids=' + manifestos + '&modelo=MANIF-M';
    } else if (modelo == 'APISUL') {
        document.location.href = './averbacao.txt5?ids=' + manifestos + '&modelo=MANIF';
    } else if (modelo == 'FRONTRAP') {
        document.location.href = './FR' + filialCNPJ + '' + primeiroManifesto + '.txt6?ids=' + manifestos + '&modelo=manif';
    } else if (modelo == 'FRONTRAPRN') {
        document.location.href = './ROMANEIO_' + primeiroManifesto + '.txt6?ids=' + manifestos + '&modelo=manifrn';
    } else if (modelo == 'PAMCARY') {
        document.location.href = './TIDN.txt7?ids=' + manifestos;
    } else if (modelo == 'PORTOSEGURO') {
        document.location.href = './averbacao.txt8?ids=' + manifestos + '&modelo=MANIF';
    } else if (modelo == 'ITAUSEGUROS') {
        document.location.href = './averbacao.txt11?ids=' + manifestos + '&modelo=MANIF&acao=itauSeguros';
    } else if (modelo == 'SUFRAMA') {
        launchPopupLocate('./Suframa.SIN?ids=' + manifestos + '&modelo=MANIF&acao=suframa', "Arquivo_SUFRAMA");
    } else if (modelo == 'CITNET') {
        document.location.href = './averbacao.txt10?ids=' + manifestos + '&modelo=MANIF';
    } else if (modelo == 'BUONNY') {
        var roteirizadorBuonny = roteirizador;
        if (manifestos != undefined) {
            window.open("ManifestoBuonnyControlador?acao=enviarManifestoBuonny&idManifesto=" + manifestos + "&roteirizadorBuonny=" + roteirizadorBuonny, "pop", "width=210, height=100");
        } else {
            alert("Selecione um manifesto!");
            return false;
        }
    }
}

function popSeparacao() {
    var manif = getCheckedManif();
    if (manif == "") {
        alert("Selecione pelo menos um Manifesto!");
        return null;
    }

    launchPDF('./consultamanifesto?acao=exportarSeparacao&modelo=' + document.getElementById("cbmodeloseparacao").value + '&id=' + manif,
            'manifesto' + manif);
}

function printMatricidadeManifesto() {
    var index = 0;
    var ids = '';

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
        chamarAlert("Selecione pelo menos um Manifesto!");
        return null;
    }

    var url = "./matricidemanifesto.ctrc?ids=" + ids + "&" + concatFieldValue("driverImpressora,caminho_impressora");
    console.log("URL: " + url);
    document.location.href = url;
}

function concatFieldValue(ids) {
    var str = "";
    for (i = 0; i < ids.split(",").length; ++i) {
        var idname = ids.split(",")[i].trim();
        if (document.getElementById(idname) == null) {
            alert("concatFieldValue()\n\nO objeto com o id \"" + idname + "\" não existe no escopo HTML!");
            return null;
        }

        str += idname + "=" + escape(document.getElementById(idname).value);
        //adicionando o delimitador de paametros
        str += ((i + 1) < ids.split(",").length ? "&" : "");
    }

    return str;
}

function getFuncLayoutEDI(valor, layoutsCliente) {
    var retorno = null;
    for (i = 0; i < layoutsCliente.size(); i++) {
        if (layoutsCliente[i].layoutEDI.id == valor) {
            retorno = layoutsCliente[i].layoutEDI;
            break;
        }
    }
    return retorno;
}

function ativarImpressaoPDF() {
    jQuery('span[aria-owns="caminho_impressora-menu"]').hide(250);
    jQuery('[exportar]').hide(250);
    jQuery('span[aria-owns="exportarPara-menu"]').hide(250);
    jQuery('span[aria-owns="driverImpressora-menu"]').hide(250, function () {
        jQuery('span[aria-owns="cbmodelo-menu"]').show(250);
        var x = 0;
        while (jQuery('[impressaoMatricial]')[x]) {
            jQuery(jQuery('[impressaoMatricial]')[x]).hide();
            x++;
        }
        jQuery('[impressaoPDF]').show();
    });
    jQuery('.bt-impressao').attr('onclick', 'popManifestoGeral();');
    jQuery('.bt-impressao').text('Imprimir');
}

function ativarImpressaoMatricial() {
    jQuery('[impressaoPDF]').hide();
    jQuery('[exportar]').hide(250);
    jQuery('span[aria-owns="exportarPara-menu"]').hide(250);
    jQuery('span[aria-owns="cbmodelo-menu"]').hide(250, function () {
        var x = 0;
        while (jQuery('[impressaoMatricial]')[x]) {
            jQuery(jQuery('[impressaoMatricial]')[x]).show();
            x++;
        }
        jQuery('span[aria-owns="caminho_impressora-menu"]').show(250);
        jQuery('span[aria-owns="driverImpressora-menu"]').show(250);
    });
    jQuery('.bt-impressao').attr('onclick', 'printMatricidadeManifesto();');
    jQuery('.bt-impressao').text('Imprimir');
}

function confirmUnicoRel(index) {
    var idManifesto = jQuery('#hi_row_id_' + index).val();
    var isUsaGenRisco = jQuery('#hi_row_fgr_st_utilizacao_' + index).val();
    var tipoBloqMonitoramento = jQuery('#hi_row_fgr_tipo_bloqueio_rastreamento_' + index).val();
    var nmanifesto = jQuery('#hi_row_num_manifesto_' + index).val();
    var dataUsoGoldenService = jQuery('#hi_row_fgr_data_inicio_uso_' + index).val();
    var dataDoManifesto = jQuery('#hi_row_data_saida_' + index).val();
    var protocolo = jQuery('#hi_row_protocolo_' + index).val();
    var idsTipoA = 0;
    var limite = document.getElementById("select-limite").value;

    for (var i = 0; i < limite; i++) {


        if (tipoBloqMonitoramento == '1') {
            idsTipoA++;
        }

        if (isUsaGenRisco != '0') {
            if (compareDate(dataDoManifesto, dataUsoGoldenService)) {
                if (tipoBloqMonitoramento == '1') {
                    if (confim("Deseja imprimir Relatório ? "))
                        popManifestoGeral(index);
                    break;
                } else if (protocolo == "") {
                    alert("Este manifesto: " + nmanifesto + " não possui protocolo de confirmação na Gerenciadora de Risco");
                    break;
                } else {
                    popManifestoGeral(index);
                    break;
                }
            } else {
                popManifestoGeral(index);
                break;
            }
        } else {
            popManifestoGeral(index);
            break;
        }

    }
}

function enviarEmailManifestoRepresentante(index) {
    var modelo = jQuery('#cbmodelo-button').find('.ui-selectmenu-text').html();
    var valorModelo = modelo.substring(7, 8);
    var idmanifesto = jQuery('#hi_row_id_' + index).val();
    if (idmanifesto == null) {
        return null;
    }
    window.open("./consultamanifesto?acao=enviarEmailManifestoRepresentante&idManif=" + idmanifesto + "&modelo=" + valorModelo, "pop", "width=210, height=100");
}

function sincronizarGwMobile(index) {
    var id = jQuery('#hi_row_id_' + index).val();
    var sincronizado = jQuery('#hi_row_is_sincronizado_mobile_' + index).val();
    var reenvia = jQuery('#hi_row_pode_reenviar_' + index).val();
    if (sincronizado == 'Sim') {
        if (reenvia == 'true') {
            window.open("./MobileControlador?acao=sincronizarGWMobileManifesto&idManifesto=" + id + "&actionImport=a", "pop", 'top=10,left=0,height=50,width=50,resizable=yes,status=1,scrollbars=1');
        } else {
            alert('Manifesto já sincronizado com o gwMobile.');
        }
    } else {
        window.open("./MobileControlador?acao=sincronizarGWMobileManifesto&idManifesto=" + id + "&actionImport=i", "pop", 'top=10,left=0,height=50,width=50,resizable=yes,status=1,scrollbars=1');
    }
}

function rotasNoMaps(index) {
    var origem = jQuery('#hi_row_origem_mapa_' + index).val();
    var destinos = jQuery('#hi_row_destinos_mapa_' + index).val();
    if (origem == null || destinos == null)
        return null;
    var url = "http://maps.google.com/maps?saddr=" + origem + "&daddr=" + destinos;
    window.open(url, "googMaps", "toolbar=no,location=no,scrollbars=no,resizable=no");

}

function launchPopupLocate(url, idname) {
    var wPop = screen.width * 0.80;
    var hPop = screen.height * 0.70;
    var cf = 'top=' + (((screen.height - hPop) / 2) - 15) + ',left=' + ((screen.width - wPop) / 2) +
            ',height=' + hPop + ',width=' + wPop + ',resizable=yes,status=1,scrollbars=1';
    var popup = window.open(url, idname, cf);
    return popup;
}

function enviarGerenciadorRisco(indice, gerenciadora) {
    var index = 0;
    var manifestos = "";
    var idmanifesto = "";
    var numeroManifesto = "";
    var confirmado = false;
    var roteirizado = false;

    if (indice != null) {
        idmanifesto = jQuery('#hi_row_id_' + indice).val();
        numeroManifesto = jQuery('#hi_row_num_manifesto_' + indice).val();
        manifestos = idmanifesto;
        confirmado = jQuery('#hi_row_status_mdfe_' + indice).val() === 'Confirmado';
        roteirizado = jQuery('#hi_row_roteirizado_' + indice).val() === 'Sim';
    } else {
        while (jQuery('input:checked[type=checkbox][name*=nCheck]')[index] != undefined) {
            var val = jQuery('input:checked[type=checkbox][name*=nCheck]')[index].value;
            var id = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().parent().find('#hi_row_id_' + val).val();

            if (jQuery('input:checked[type=checkbox][name*=nCheck]')[index + 1] != undefined) {
                chamarAlert("Selecione apenas um manifesto");
                return null;
            } else {
                manifestos += id;
            }

            index++;
        }
    }

    if (manifestos == "" || manifestos == null) {
        chamarAlert("Selecione um Manifesto");
        return null;
    }

    if (gerenciadora === "G") {
        if (confirm("Deseja enviar para Golden Service? ")) {
            window.open("./GerenciamentoRiscoControlador?acao=enviarGoldenService&idManifesto=" + manifestos, 'pop', 'width=400, height=200');
        }
    } else if (gerenciadora === "U") {
        if (!confirmado) {
            chamarAlert('O manifesto ' + numeroManifesto + ' não está confirmado com a Sefaz!');
        } else if (roteirizado) {
            chamarAlert('O manifesto ' + numeroManifesto + ' já foi roteirizado!');
        } else {
            chamarConfirm("Deseja enviar o manifesto " + numeroManifesto + " para a Upper?", 'enviarGerenciadorRiscoConfirmado("' + manifestos + '", "' + gerenciadora + '")');
        }
    }
}

function enviarGerenciadorRiscoConfirmado(manifestos, gerenciadora) {
    if (manifestos !== undefined && manifestos !== '' && gerenciadora !== undefined && gerenciadora !== '') {
        switch (gerenciadora) {
            case "U":
                jQuery(".gif-bloq-tela").css("display", "block");
                jQuery(".bloqueio-tela").css("display", "block");

                jQuery.post(homePath + '/GerenciamentoRiscoControlador', {
                    'acao': 'enviarUPPER',
                    'idManifesto': manifestos
                }, function (data) {
                    if (data) {
                        var json = JSON.parse(data);

                        jQuery(".gif-bloq-tela").css("display", "none");
                        jQuery(".bloqueio-tela").css("display", "none");

                        chamarAlert(json['mensagem'], function () {
                            reload();
                        });
                    }
                });
                break;
        }
    }
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
