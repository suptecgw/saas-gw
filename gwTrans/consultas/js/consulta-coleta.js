/* 
 Created on : 06/01/2017, 08:59:48
 Author     : Mateus Veloso
 */

var myConfObj = {
    iframeMouseOver: false
};

var containerVideo = null;

window.addEventListener('blur', function () {
    if (myConfObj.iframeMouseOver) {
        jQuery(containerVideo).trigger('change');
    }
});
function cadastrarCliente() {
    location.replace("./cadcliente?acao=iniciar");
}

function relatorioCliente() {
    window.open('./relcliente.jsp?acao=iniciar&modulo=webtrans', "_blank", "toolbar=yes,scrollbars=yes,resizable=yes,top=200,left=500,width=800,height=600");
}

function editar(position) {
    var id = jQuery("#hi_row_id_" + position).val();
    window.location.href = "./cadcoleta?acao=editar&id=" + id;
}

function visualizarDocumentos(index) {
    jQuery('.cobre-tudo').show();
    jQuery('.salvarPesquisaContainer').css('z-index', '999996');

    jQuery('.visualizarDocumentos').css('display', 'block');
    var idColeta = jQuery('#hi_row_id_' + index).val();
    jQuery('#iframeVisualizarDocumentos').attr('src', 'ImagemControlador?acao=carregar&idPedidoColeta=' + idColeta+"&tema="+tema);
}

function fecharVisualizarCliente() {
    jQuery('.cobre-tudo').hide();
    jQuery('.salvarPesquisaContainer').css('z-index', '999999');
    jQuery('.visualizarDocumentos').css('display', 'none');
}

function excluirImagem() {
    var msg = 'Deseja mesmo excluir essa Imagem no Cadastro de Coleta?';
    if (iframeVisualizarDocumentos.getValueCheckMarcados().split(',')[1] != undefined) {
        msg = 'Deseja mesmo excluir essas Imagens no Cadastro de Coleta?';
    }
    chamarConfirm(msg, 'iframeVisualizarDocumentos.excluir()', 'null');
}

function consulta() {
    var qtdCarac= 0;
    var valor = jQuery("#inpSelectVal").val();
    if(jQuery("#select-oper").val() == '1' || jQuery("#select-oper").val() == '2' || jQuery("#select-oper").val() == '3'){
        for (var i = 0; i < valor.split("!@!").length; i++) {
            if(valor.split("!@!")[i]){
                qtdCarac = valor.split("!@!")[i].length;
                if(qtdCarac < 3 ){
                    chamarAlert("Para filtros ( Todas as Partes , Apenas no fim, Apenas no inicio ) é necessário preencher ao menos 3 caractéries!");
                    return false;
                }
            }
        }
    }    
    jQuery("#formConsulta").submit();
}

function excluirColetas(item) {
    var index = 0;
    var ids = '';
    var nomes = '';

    if (item == undefined) {
        while (jQuery('input:checked[type=checkbox][name*=nCheck]')[index] != undefined) {

            var val = jQuery('input:checked[type=checkbox][name*=nCheck]')[index].value;
            var id = jQuery('#hi_row_id_' + val).val();
            var nome = jQuery('#hi_row_numero_' + val).val();

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
        nomes = jQuery('#hi_row_numero_' + item).val();
    }

    var texto = "";
    if (index > 1) {
        texto = "Deseja excluir as coletas abaixo?";
    } else {
        texto = "Deseja excluir a coleta abaixo?";
    }
    chamarConfirm(texto, 'aceitouExcluirColetas("' + ids + '")', '', 1, '<ul class="square">' + nomes + '</ul>');

}

function aceitouExcluirColetas(ids) {
    jQuery.ajax({
        url: 'ColetaControlador?acao=excluir&ids=' + ids,
        success: function (data, textStatus, jqXHR) {
            chamarAlert(data, reload);
        }
    });
}

function reload() {
    window.location.reload();
}

function salvarPreferencias() {
    var json = getJsonPreferencias();
    jQuery.ajax({
        dataType: 'json',
        method: 'POST',
        url: 'ConsultaControlador?acao=salvarPreferencias&codigoTela=24',
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
            excluir_coluna: (jQuery(jQuery('.pode-setar-ordem')[index]).attr('oculta') !== undefined ? 'true' : 'false')
        };
        jsonValores[index] = obj;
        index++;
    }

    return JSON.stringify(jsonValores);
}

function ativarExcetosMultiplosGw() {
    jQuery('#select-exceto-apenas-cidade').selectExcetoApenasGw({
        width: '180px'
    });

    jQuery('#select-exceto-apenas-grupo-cliente').selectExcetoApenasGw({
        width: '200px'
    });

    jQuery('#select-exceto-apenas-vendedor').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-supervisor').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-tipo-coleta').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-mostrar-coleta').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-filial').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-cliente').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-destinatarios').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-motorista').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-veiculo').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-cidade-co').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-cidade-de').selectExcetoApenasGw({
        width: '170px'
    });
}

jQuery(document).ready(function () {
    jQuery('#inptFilial').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptCliente').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptDestinatarios').inputMultiploGw({
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

    jQuery('[name=inptCidadeDe]').inputMultiploGw({
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

    jQuery('#select-mostrar-coleta').selectGrupoMultiploGw({
        input: 'select-mostrar-coleta',
        grupos: {
            Status: {
                1: 'Realizadas!!coleta_em!!IS NOT NULL!!IS_NULL',
                2: 'Não Realizadas!!coleta_em!!IS NULL!!IS_NULL'
            },
            Prazo: {
                1: 'No Prazo!!coleta_programada!!> CURRENT_TIMESTAMP!!MAIOR_QUE_CURRENT_TIMESTAMP',
                2: 'Atrasadas!!coleta_programada!!< CURRENT_TIMESTAMP!!MAIOR_QUE_CURRENT_TIMESTAMP'
            },
            Canceladas: {
                1: 'Canceladas!!cancelada!!Cancelada!!IGUAL',
                2: 'Não Canceladas!!cancelada!!Normal!!IGUAL'
            },
            "Finalizadas (Faturadas)": {
                1: 'Finalizadas!!finalizada!!true!!IGUAL',
                2: 'Não Finalizadas!!finalizada!!false!!IGUAL'
            },
            Impressas: {
                1: 'Impressas!!is_impresso!!true!!IGUAL',
                2: 'Não Impressas!!is_impresso!!false!!IGUAL'
            }
        }
    });

    jQuery('#select-tipo-coleta').selectGrupoMultiploGw({
        input: 'select-tipo-coleta',
        grupos: {
            Tipo: {
                1: 'Coletas!!categoria!!co!!IGUAL',
                2: 'Ordem de Serviço!!categoria!!os!!IGUAL',
                3: 'Ambas!!categoria!!am!!IGUAL'
            }
        }
    });


    //Float responsavel pelo alinhamento do modelo de impressão
    jQuery('span[aria-owns="cbmodelo-menu"]').css('float', 'left');
    jQuery('span[aria-owns="cbmodelo-menu"]').css('width', '97%');

    jQuery('span[aria-owns="impressora-menu"]').css('float', 'left');
    jQuery('span[aria-owns="impressora-menu"]').css('width', '97%');
    jQuery('span[aria-owns="impressora-menu"]').hide();

    jQuery('span[aria-owns="driverImpressora-menu"]').css('float', 'left');
    jQuery('span[aria-owns="driverImpressora-menu"]').css('width', '97%');
    jQuery('span[aria-owns="driverImpressora-menu"]').hide();

    jQuery('span[aria-owns="exportarPara-menu"]').css('float', 'left');
    jQuery('span[aria-owns="exportarPara-menu"]').css('width', '97%');
    jQuery('span[aria-owns="exportarPara-menu"]').hide();
    jQuery('[exportar]').hide();

    var x = 0;
    while (jQuery('[impressaoMatricial]')[x]) {
        jQuery(jQuery('[impressaoMatricial]')[x]).hide();
        x++;
    }


    jQuery('input[name=mostrarColetasStatus]').change(function () {
        if (this.value === '2') {
            jQuery('[container-coletas-aberto]').show(250);
        } else {
            jQuery('[container-coletas-aberto]').hide(250);
        }
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
    
    jQuery("#inptFilialDestino").inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });
    setTimeout(function () {
        var quantItens = jQuery("input[id^='hi_row_cancelada_']").length;
        for (var i = 1; i <= quantItens ; i++) {
            if (jQuery("#hi_row_cancelada_"+i).val() === "Cancelada") {
                jQuery("#hi_row_cancelada_"+i).parents("tr").find("label").css("color","red");
                jQuery("#hi_row_cancelada_"+i).parents("tr").find("label").attr('style',"color: red !important;");
            }
        }
    }, 1000);

});


var srcSalvarFiltroOriginal = null;
var objCompleto;

function gerenciarInpFilialDestino(nome, valor, descricao, condicao) {
    if (nome == 'filial_destino_id') {
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

function alerarFiltroPesquisa() {
    var iframe = document.getElementById('iframeSalvarFiltros');

    if (jQuery('#select-pesquisa').val() == 0) {
        iframe.src = srcSalvarFiltroOriginal;
    } else {
        iframe.src = srcSalvarFiltroOriginal + '?nomePesquisa=' + jQuery('#select-pesquisa').val() + '&isPrivada=' + true;
    }

    jQuery('.cobre-tudo').css('display', 'block');
    jQuery('.cobre-tudo').css('background', 'rgba(100, 100, 100, 0.4)');
//    jQuery('.gif-bloq-tela-left').css('display', 'block');
    jQuery('.salvarPesquisaContainer').css('z-index', '99');


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
                removerValorInput('input-mostrar-coletas');
                removerValorInput('tipo-coleta');
                removerValorInput('inpSelectVal');
                removerValorInput('inptFilial');
                removerValorInput('inptCliente');
                removerValorInput('inptDestinatarios');
                removerValorInput('inptMotorista');
                removerValorInput('inptVeiculo');
                removerValorInput('inptCidade');
                removerValorInput('inptCidadeDe');
                jQuery('#filtros-adicionais-container').hide();

                objCompleto = jQuery.parseJSON(jQuery.parseJSON(data));

                var ordenarPor = objCompleto.ordenacao.trim().split(" ")[0];
                var tipoOrd = objCompleto.ordenacao.trim().split(" ")[1];

                var limiteResultados = objCompleto.limiteResultado;

                //seta o id da preferencia na variavel, (usada para update)
                idPreferencia = objCompleto.idPreferencia;

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

                if (objCompleto.nomeCli != null && objCompleto.nomeCli != undefined) {
                    var clientes = objCompleto.valorCli.replace(/\[+/g, '').replace(/\]+/g, '');
                    clientes = clientes.split(',');

                    var nomeCliente = objCompleto.descricaoCli.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeCliente = nomeCliente.split(',');

                    for (var i = 0; i < clientes.length; i++) {
                        addValorAlphaInput('inptCliente', nomeCliente[i], clientes[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeDest != null && objCompleto.nomeDest != undefined) {
                    var destinatarios = objCompleto.valorDest.replace(/\[+/g, '').replace(/\]+/g, '');
                    destinatarios = destinatarios.split(',');

                    var nomeDestinatario = objCompleto.descricaoDest.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeDestinatario = nomeDestinatario.split(',');

                    for (var i = 0; i < destinatarios.length; i++) {
                        addValorAlphaInput('inptDestinatarios', nomeDestinatario[i], destinatarios[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeDest != null && objCompleto.nomeDest != undefined) {
                    var destinatarios = objCompleto.valorDest.replace(/\[+/g, '').replace(/\]+/g, '');
                    destinatarios = destinatarios.split(',');

                    var nomeDestinatario = objCompleto.descricaoDest.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeDestinatario = nomeDestinatario.split(',');

                    for (var i = 0; i < destinatarios.length; i++) {
                        addValorAlphaInput('inptDestinatarios', nomeDestinatario[i], destinatarios[i]);
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

                    for (var i = 0; i < motoristas.length; i++) {
                        addValorAlphaInput('inptVeiculo', nomeVeiculo[i], veiculos[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeOri != null && objCompleto.nomeOri != undefined) {
                    var origem = objCompleto.valorOri.replace(/\[+/g, '').replace(/\]+/g, '');
                    origem = origem.split(',');

                    var nomeOrigem = objCompleto.descricaoOri.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeOrigem = nomeOrigem.split(',');

                    for (var i = 0; i < origem.length; i++) {
                        addValorAlphaInput('inptCidade', nomeOrigem[i], origem[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeDes != null && objCompleto.nomeDes != undefined) {
                    var destino = objCompleto.valorDes.replace(/\[+/g, '').replace(/\]+/g, '');
                    destino = destino.split(',');

                    var nomeDestino = objCompleto.descricaoDes.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeDestino = nomeDestino.split(',');

                    for (var i = 0; i < destino.length; i++) {
                        addValorAlphaInput('inptCidadeDe', nomeDestino[i], destino[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeCol != null && objCompleto.nomeCol != undefined) {
                    var valorCol = objCompleto.valorCol.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorCol = valorCol.split(',');
                    var descCol = objCompleto.descricaoCol.replace(/\[+/g, '').replace(/\]+/g, '');
                    descCol = descCol.split(',');
                    for (var i = 0; i < valorCol.length; i++) {
                        gerenciarMostrarColetas(objCompleto.nomeCol, valorCol[i], objCompleto.condicaoCol, descCol[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                    addValorSelectMultiploGrupo('input-mostrar-coletas', objCompleto.valorCol, objCompleto.descricaoCol);
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeColPro != null && objCompleto.nomeColPro != undefined) {
                    var valorColPro = objCompleto.valorColPro.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorColPro = valorColPro.split(',');
                    var descColPro = objCompleto.descricaoColPro.replace(/\[+/g, '').replace(/\]+/g, '');
                    descColPro = descColPro.split(',');
                    for (var i = 0; i < valorColPro.length; i++) {
                        gerenciarMostrarColetas(objCompleto.nomeColPro, valorColPro[i], objCompleto.condicaoColPro, descColPro[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeCanc != null && objCompleto.nomeCanc != undefined) {
                    var valorCanc = objCompleto.valorCanc.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorCanc = valorCanc.split(',');
                    var descCanc = objCompleto.descricaoCanc.replace(/\[+/g, '').replace(/\]+/g, '');
                    descCanc = descCanc.split(',');
                    for (var i = 0; i < valorCanc.length; i++) {
                        gerenciarMostrarColetas(objCompleto.nomeCanc, valorCanc[i], objCompleto.condicaoCanc, descCanc[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeFina != null && objCompleto.nomeFina != undefined) {
                    var valorFina = objCompleto.valorFina.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorFina = valorFina.split(',');
                    var descFina = objCompleto.descricaoFina.replace(/\[+/g, '').replace(/\]+/g, '');
                    descFina = descFina.split(',');
                    for (var i = 0; i < valorFina.length; i++) {
                        gerenciarMostrarColetas(objCompleto.nomeFina, valorFina[i], objCompleto.condicaoFina, descFina[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeImp != null && objCompleto.nomeImp != undefined) {
                    var valorImp = objCompleto.valorImp.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorImp = valorImp.split(',');
                    var descImp = objCompleto.descricaoImp.replace(/\[+/g, '').replace(/\]+/g, '');
                    descImp = descImp.split(',');
                    for (var i = 0; i < valorImp.length; i++) {
                        gerenciarMostrarColetas(objCompleto.nomeImp, valorImp[i], objCompleto.condicaoImp, descImp[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeCat != null && objCompleto.nomeCat != undefined) {
                    var valorCat = objCompleto.valorCat.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorCat = valorCat.split(',');
                    var descCat = objCompleto.descricaoCat.replace(/\[+/g, '').replace(/\]+/g, '');
                    descCat = descCat.split(',');
                    for (var i = 0; i < valorCat.length; i++) {
                        gerenciarTipoColeta(objCompleto.nomeCat, valorCat[i], objCompleto.condicaoCat, descCat[i]);
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

function salvarPesquisa() {
    if (iframeSalvarFiltros.document.getElementById('nomePesquisa').value.trim() === '') {
        chamarAlert('Insira um nome para pesquisa', iframeSalvarFiltros.habilitarBotaoSalvar);
    } else {
        var nomePesquisa = iframeSalvarFiltros.document.getElementById('nomePesquisa').value;
        var nomePesquisaOriginal = iframeSalvarFiltros.document.getElementById('nomePesquisaOriginal').value;
        var aoSalvar = iframeSalvarFiltros.jQuery("input[name='aoSalvar']:checked").val();
        var isPrivado = (iframeSalvarFiltros.jQuery('input[name=options]:checked').val() == 1 ? true : false);

        jQuery.ajax({
            url: 'ConsultaControlador?acao=cadPrefUsuPersonalizada&nomePesquisa=' + nomePesquisa + "&isPrivado=" + isPrivado + '&aoSalvar=' + aoSalvar + '&idPreferencia=' + idPreferencia + '&cod_tela=24&nomePesquisaOriginal=' + nomePesquisaOriginal,
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
                console.log(jqXHR);
                chamarAlert("Ocorreu um erro ao tentar salvar a pesquisa.");
                cancelarSalvarPesquisa();
            }
        });

    }
}

function cancelarSalvarPesquisa() {
    var container = jQuery('.container-salvar-filtros');
    jQuery('.cobre-tudo').hide('low');
    
    container.animate({
        'width': '0px'
    }, 200, function () {
        container.hide();
        container.animate({
            'height': '0px'
        }, 1);
    });
}

function gerenciarInpSelectVal(nome, valor, valor2) {
    if (jQuery('#select-abrev option[value=' + nome + ']').size() >= 1) {
        if (nome == 'dtlancamento') {
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
        } else if (nome == 'dt_coleta') {
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
        } else if (nome == 'dt_socilitacao') {
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
        } else if (nome == 'dt_previsao') {
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
        } else if (nome == 'dt_programada') {
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
        if (jQuery('#filtros-adicionais-container').css('display') === 'none') {
            jQuery('#filtros-adicionais').trigger('click');
        }
    }
}

function gerenciarMostrarColetas(name, valor, condicao, descricao) {
    valor = valor.trim();
    if (name == 'coleta_em') {
        if (valor == 'IS NOT NULL') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[1]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-mostrar-coleta option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'IS NULL') {
            console.log('aaa');
            console.log(condicao);
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[2]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-mostrar-coleta option[value="' + condicao + '"]').attr('selected', 'selected');
        }
    }
    if (name == 'coleta_programada') {
        if (valor == '> CURRENT_TIMESTAMP') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[4]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-mostrar-coleta option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == '< CURRENT_TIMESTAMP') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[5]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-mostrar-coleta option[value="' + condicao + '"]').attr('selected', 'selected');
        }
    }
    if (name == 'cancelada') {
        if (valor == 'Cancelada') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[7]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-mostrar-coleta option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'Normal') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[8]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-mostrar-coleta option[value="' + condicao + '"]').attr('selected', 'selected');
        }
    }
    if (name == 'finalizada') {
        if (valor == 'true') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[10]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-mostrar-coleta option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'false') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[11]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-mostrar-coleta option[value="' + condicao + '"]').attr('selected', 'selected');
        }
    }
    if (name == 'is_impresso') {
        if (valor == 'true') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[13]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-mostrar-coleta option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'false') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[14]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-mostrar-coleta option[value="' + condicao + '"]').attr('selected', 'selected');
        }
    }
    jQuery('.container-li-valores').hide();
}

function gerenciarTipoColeta(name, valor, condicao, descricao) {
    valor = valor.trim();
    if (name == 'categoria') {
        if (valor == 'co') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[16]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-coleta option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'os') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[17]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-coleta option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'am') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[18]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-coleta option[value="' + condicao + '"]').attr('selected', 'selected');
        }
    }
    jQuery('.container-li-valores').hide();
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

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptCliente', descricao[i].trim(), valor[i].trim());
        }
    }
}

function gerenciarInpDestinatario(nome, valor, descricao, condicao) {
    if (nome == 'id_destinatario') {
        jQuery('#select-exceto-apenas-destinatarios option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptDestinatarios', descricao[i].trim(), valor[i].trim());
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

function gerenciarInpCidadeCo(nome, valor, descricao, condicao) {
    if (nome == 'origem') {
        jQuery('#select-exceto-apenas-cidade-co option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput(jQuery('[name=inptCidadeCo]'), descricao[i].trim(), valor[i].trim());
        }
    }
}

function gerenciarInpCidadeDe(nome, valor, descricao, condicao) {
    if (nome == 'id_cidade_destino') {
        console.log('log');
        console.log(jQuery('#select-exceto-apenas-cidade-de option[value="' + condicao + '"]'));
        jQuery('#select-exceto-apenas-cidade-de option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptCidadeDe', descricao[i].trim(), valor[i].trim());
        }
    }
}


function abrirImportacao(position, tipo) {
    if (tipo == '0' && screen.width <= 768) {
        launchPopupLocate("./ConferenciaControlador?acao=importarArquivoColetaMobile&idColeta=" + jQuery('#hi_row_id_' + position).val() + "&tipoOperacao=" + tipo, "Coleta");
    } else {
        launchPopupLocate("./ConferenciaControlador?acao=importarArquivoColeta&idColeta=" + jQuery('#hi_row_id_' + position).val() + "&tipoOperacao=" + tipo, "Coleta");
    }
}

function popColeta(position) {
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
            chamarAlert("Selecione pelo menos uma Coleta!");
            return null;
        }
    } else {
        ids = jQuery('#hi_row_id_' + position).val();
    }


    launchPDF('./consultacoleta?acao=exportar&impressao=' + impressao + '&modelo=' + jQuery('#cbmodelo').val() + '&campo=idcoleta&valorconsulta=' + ids, 'coleta' + ids);
}

function enviarEmailRepresentante(position) {
    var id_representante = parseInt($('#hi_row_representante_id_' + position).val());
    var coleta_id = parseInt($('#hi_row_id_' + position).val());
    if (id_representante) {
        var mensagem = '';

        if (jQuery('#hi_row_is_enviado_email_representante_' + position).val() === 'Sim') {
            mensagem = 'Tem certeza de que deseja enviar novamente o email para o representante?';
        } else {
            mensagem = 'Tem certeza de que deseja enviar o email para o representante?';
        }

        chamarConfirm(mensagem, 'enviarEmailConfirmado(' + coleta_id + ')');
    } else {
        chamarAlert('O E-mail não poderá ser enviado! Não foi informado representante para essa coleta.');
    }
}

function enviarEmailConfirmado(coleta_id) {
    jQuery.post(homePath + '/ColetaControlador', {
        'acao': 'enviarEmailRepresentante',
        'coleta_id': coleta_id
    }, function (data) {
        chamarAlert(data, function () {
            reload();
        });
    });
}

function launchPDF(url, idname) {
    var cf = 'top=0,left=0,height=600,width=800,resizable=yes,status=1,scrollbars=1';
    var pdf = window.open(url, idname, cf);
    pdf.window.resizeTo(screen.width, screen.height - 20);
    pdf.focus();
}


function launchPopupLocate(url, idname) {
    var wPop = screen.width * 0.80;
    var hPop = screen.height * 0.70;
    var cf = 'top=' + (((screen.height - hPop) / 2) - 15) + ',left=' + ((screen.width - wPop) / 2) +
            ',height=' + hPop + ',width=' + wPop + ',resizable=yes,status=1,scrollbars=1';
    var popup = window.open(url, idname, cf);
    return popup;
}

function printMatricideColeta() {

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
        chamarAlert("Selecione pelo menos uma Coleta!");
        return null;
    }
    var caminhoImpressoa = encodeURI(document.getElementById('impressora').value);
    var url = "./matricidecoleta.ctrc?idmovs=" + ids + "&" + concatFieldValue("driverImpressora") + "&caminho_impressora=" + caminhoImpressoa;
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

var layoutsFunctionAll_c = new Array();
var layoutsFunctionAll_f = new Array();
var layoutsFunctionAll_o = new Array();
var idxAll_o = 0;
var dataAtualSistema;

function exportar() {

    var index = 0;
    var coletas = '';


    while (jQuery('input:checked[type=checkbox][name*=nCheck]')[index] != undefined) {

        var val = jQuery('input:checked[type=checkbox][name*=nCheck]')[index].value;
        var id = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().parent().find('#hi_row_id_' + val).val();

        if (jQuery('input:checked[type=checkbox][name*=nCheck]')[index + 1] != undefined) {
            coletas += id + ',';
        } else {
            coletas += id;
        }
        index++;
    }


    var modelo = jQuery('#exportarPara').val();

    if (coletas == "") {
        chamarAlert("Selecione Pelo Menos uma Coleta!");
        return null;
    }

    if (modelo == 'ATM') {
        document.location.href = './averbacao.txt4?ids=' + coletas + '&modelo=COLETA';
    } else if (modelo == 'APISUL') {
        document.location.href = './averbacao.txt5?ids=' + coletas + '&modelo=COLETA';
    } else if (modelo.indexOf("funcEdi") > -1) {
        var layout = getFuncLayoutEDI(modelo.split("!!")[0], layoutsFunctionAll_c);
        if (layout == null) {
            layout = getFuncLayoutEDI(modelo.split("!!")[0], layoutsFunctionAll_o);
        }
        if (layout != null) {
            var nomeArquivo = layout.nomeArquivo;
            var horaAtualSistema = new Date();
            nomeArquivo = replaceAll(nomeArquivo, "@@dia", dataAtualSistema.split("/")[0]);
            nomeArquivo = replaceAll(nomeArquivo, "@@mes", dataAtualSistema.split("/")[1]);
            nomeArquivo = replaceAll(nomeArquivo, "@@ano", dataAtualSistema.split("/")[2]);
            nomeArquivo = replaceAll(nomeArquivo, "@@hora", horaAtualSistema.getHours());
            nomeArquivo = replaceAll(nomeArquivo, "@@minuto", horaAtualSistema.getMinutes());
            nomeArquivo = replaceAll(nomeArquivo, "@@segundo", horaAtualSistema.getSeconds());
            switch (layout.extencaoArquivo) {
                case "txt":
                    document.location.href = "./" + nomeArquivo + ".txt3?modelo=funcEDI&ids=" + coletas + "&layoutID=" + layout.id;
                    break;
            }
        } else {
        }
    }



}

function getFuncLayoutEDI(valor, layoutsCliente) {
    var retorno = null;
    for (i = 0; i < layoutsCliente.length; i++) {
        if (layoutsCliente[i].layoutEDI.id == valor) {
            retorno = layoutsCliente[i].layoutEDI;
            break;
        }
    }
    return retorno;
}


function ativarImpressaoPDF() {
    jQuery('span[aria-owns="impressora-menu"]').hide(250);
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
    jQuery('.bt-impressao').attr('onclick', 'popColeta();');
    jQuery('.bt-impressao').text('Imprimir');
    jQuery('.bt-impressao').css('margin-top', '36px');
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
        jQuery('span[aria-owns="impressora-menu"]').show(250);
        jQuery('span[aria-owns="driverImpressora-menu"]').show(250);
    });
    jQuery('.bt-impressao').attr('onclick', 'printMatricideColeta();');
    jQuery('.bt-impressao').text('Imprimir');
    jQuery('.bt-impressao').css('margin-top', '29px');
}

function ativarExportacao() {
    jQuery('span[aria-owns="cbmodelo-menu"]').hide(250);
    jQuery('span[aria-owns="impressora-menu"]').hide(250);
    jQuery('span[aria-owns="driverImpressora-menu"]').hide(250);
    var x = 0;
    while (jQuery('[impressaoMatricial]')[x]) {
        jQuery(jQuery('[impressaoMatricial]')[x]).hide();
        x++;
    }
    jQuery('[impressaoPDF]').hide(250, function () {
        jQuery('[exportar]').show(250);
        jQuery('span[aria-owns="exportarPara-menu"]').show(250);
    });
    jQuery('.bt-impressao').attr('onclick', 'exportar();');
    jQuery('.bt-impressao').text('Exportar');
    jQuery('.bt-impressao').css('margin-top', '36px');
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

// javascript não possui replaceall
function replaceAll(string, token, newtoken) {
    while (string.indexOf(token) != -1) {
        string = string.replace(token, newtoken);
    }
    return string;
}
