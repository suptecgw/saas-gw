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
    location.replace("./cadmotorista?acao=editar&id=" + id + "&ex=" + (nivelUser <= 3 ? 'false' : 'true'));
}

function consulta() {
    jQuery("#formConsulta").submit();
}

function visualizarDocumentos(e) {
    var ordem = $(e).parent().parent().attr('ordem');

    jQuery('.visualizarDocumentos').css('height', '');
    jQuery('.visualizarDocumentos').css('top', '');

    jQuery('.cobre-tudo').show();
    jQuery('.salvarPesquisaContainer').css('z-index', '999996');

    jQuery('.visualizarDocumentos').css('display', 'block');
    var idmotorista = jQuery('#hi_row_id_' + ordem).val();
    var nome = jQuery('#hi_row_nome_' + ordem).val();
    var cpf = jQuery('#hi_row_cpf_' + ordem).val();
    jQuery('#iframeVisualizarDocumentos').attr('src', 'ImagemControlador?acao=carregar&nome=' + nome + '&cpf=' + cpf + '&idmotorista=' + idmotorista+'&tema='+tema);
}


function anexarFoto3x4(e) {
 
    var ordem = $(e).parent().parent().attr('ordem');

    jQuery('.visualizarDocumentos').css('height', '250px');
    jQuery('.visualizarDocumentos').css('top', 'calc(50% - 125px');

    jQuery('.cobre-tudo').show();
    jQuery('.salvarPesquisaContainer').css('z-index', '999996');
    jQuery('.visualizarDocumentos').css('display', 'block');
    var idmotorista = jQuery('#hi_row_id_' + ordem).val();
    var nome = jQuery('#hi_row_nome_' + ordem).val();
    var cpf = jQuery('#hi_row_cpf_' + ordem).val();
    jQuery('#iframeVisualizarDocumentos').attr('src', 'ImagemControlador?acao=carregar&isFoto=true&nome=' + nome + '&cpf=' + cpf + '&idmotorista=' + idmotorista+'&tema='+tema);
}

function sincronizarGwMobile(e, actionImport) {
  var ordem = $(e).parent().parent().attr('ordem');
  var idmotorista = jQuery('#hi_row_id_' + ordem).val();
window.open("./MobileControlador?acao=sincronizarGWMobileMotorista&idMotorista=" + idmotorista + "&actionImport="+ actionImport, "pop", 'top=10,left=0,height=50,width=50,resizable=yes,status=1,scrollbars=1');
}

function fecharVisualizarCliente() {
    jQuery('.cobre-tudo').hide();
    jQuery('.salvarPesquisaContainer').css('z-index', '999999');
    jQuery('.visualizarDocumentos').css('display', 'none');
}

function excluirImagem() {
    var msg = 'Deseja mesmo excluir essa Imagem no Cadastro de Motorista?';
    if (iframeVisualizarDocumentos.getValueCheckMarcados().split(',')[1] != undefined) {
        msg = 'Deseja mesmo excluir essas Imagens no Cadastro de Motorista?';
    }
    chamarConfirm(msg, 'iframeVisualizarDocumentos.excluir()', 'null');
}

function launchPDF(url, idname) {
    var cf = 'top=0,left=0,height=600,width=800,resizable=yes,status=1,scrollbars=1';
    var pdf = window.open(url, idname, cf);
    pdf.window.resizeTo(screen.width, screen.height - 20);
    pdf.focus();
}

function popRel(e) {
    var ordem = $(e).parent().parent().attr('ordem');
    var id = jQuery("#hi_row_id_" + ordem).val();
    var modelo = jQuery('#cbmodelo').val();
    launchPDF('./relmotoristas?acao=exportar&modelo=' + modelo + '&filial=0&desligado=&idmotorista=' + id + '&impressao=1&tipoMotorista=todos');
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
        texto = "Deseja excluir os motoristas abaixo?";
    } else {
        texto = "Deseja excluir o motorista abaixo?";
    }
    chamarConfirm(texto, 'aceitouExcluirMotorista("' + ids + '")', '', 1, '<ul class="square">' + nomes + '</ul>');

}

function aceitouExcluirMotorista(ids) {
    jQuery.ajax({
        url: 'MotoristaControlador?acao=excluir&ids=' + ids,
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

    jQuery('#select-exceto-apenas-veiculo').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-tipo-veiculo').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-cliente').selectExcetoApenasGw({
        width: '170px'
    });
}

jQuery(document).ready(function () {
    

    jQuery('#inptCidadeOri').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptVeiculo').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptTipoVeiculo').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptCliente').inputMultiploGw({
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
                removerValorInput('select-tipo-motorista');
                removerValorInput('inptCidadeOri');
                removerValorInput('inptVeiculo');
                removerValorInput('inptTipoVeiculo');
                removerValorInput('inptCliente');
                removerValorInput('input-mostrar-motoristas');
                console.log(data);

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

                if (objCompleto.nomeCidade != null && objCompleto.nomeCidade != undefined) {
                    var cidade = objCompleto.valorCidade.replace(/\[+/g, '').replace(/\]+/g, '');
                    cidade = cidade.split(',');

                    var nomeCidade = objCompleto.descricaoCidade.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeCidade = nomeCidade.split(',');

                    for (var i = 0; i < cidade.length; i++) {
                        addValorAlphaInput('inptCidadeOri', nomeCidade[i], cidade[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeVeiculo != null && objCompleto.nomeVeiculo != undefined) {
                    var veiculo = objCompleto.valorVeiculo.replace(/\[+/g, '').replace(/\]+/g, '');
                    veiculo = veiculo.split(',');

                    var nomeVeiculo = objCompleto.descricaoVeiculo.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeVeiculo = nomeVeiculo.split(',');

                    for (var i = 0; i < veiculo.length; i++) {
                        addValorAlphaInput('inptVeiculo', nomeVeiculo[i], veiculo[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeCarreta != null && objCompleto.nomeCarreta != undefined) {
                    var carreta = objCompleto.valorCarreta.replace(/\[+/g, '').replace(/\]+/g, '');
                    carreta = carreta.split(',');

                    var nomeCarreta = objCompleto.descricaoCarreta.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeCarreta = nomeCarreta.split(',');

                    for (var i = 0; i < carreta.length; i++) {
                        addValorAlphaInput('inptVeiculo', nomeCarreta[i], carreta[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeBitrem != null && objCompleto.nomeBitrem != undefined) {
                    var bitrem = objCompleto.valorBitrem.replace(/\[+/g, '').replace(/\]+/g, '');
                    bitrem = bitrem.split(',');

                    var nomeBitrem = objCompleto.descricaoBitrem.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeBitrem = nomeBitrem.split(',');

                    for (var i = 0; i < bitrem.length; i++) {
                        addValorAlphaInput('inptVeiculo', nomeBitrem[i], bitrem[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeCarreta3 != null && objCompleto.nomeCarreta3 != undefined) {
                    var carreta3 = objCompleto.valorCarreta3.replace(/\[+/g, '').replace(/\]+/g, '');
                    carreta3 = carreta3.split(',');

                    var nomeCarreta3 = objCompleto.descricaoCarreta3.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeCarreta3 = nomeCarreta3.split(',');

                    for (var i = 0; i < carreta3.length; i++) {
                        addValorAlphaInput('inptVeiculo', nomeCarreta3[i], carreta3[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeTipoVei != null && objCompleto.nomeTipoVei != undefined) {
                    var tipoVeiculo = objCompleto.valorTipoVei.replace(/\[+/g, '').replace(/\]+/g, '');
                    tipoVeiculo = tipoVeiculo.split(',');

                    var nomeTipoVei = objCompleto.descricaoTipoVei.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeTipoVei = nomeTipoVei.split(',');

                    for (var i = 0; i < tipoVeiculo.length; i++) {
                        addValorAlphaInput('inptTipoVeiculo', nomeTipoVei[i], tipoVeiculo[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeTipoVeiCar != null && objCompleto.nomeTipoVeiCar != undefined) {
                    var tipoVeiculoCar = objCompleto.valorTipoVeiCar.replace(/\[+/g, '').replace(/\]+/g, '');
                    tipoVeiculoCar = tipoVeiculoCar.split(',');

                    var nomeTipoVeiCar = objCompleto.descricaoTipoVeiCar.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeTipoVeiCar = nomeTipoVeiCar.split(',');

                    for (var i = 0; i < tipoVeiculoCar.length; i++) {
                        addValorAlphaInput('inptTipoVeiculo', nomeTipoVeiCar[i], tipoVeiculoCar[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeTipoVeiBit != null && objCompleto.nomeTipoVeiBit != undefined) {
                    var tipoVeiculoBit = objCompleto.valorTipoVeiBit.replace(/\[+/g, '').replace(/\]+/g, '');
                    tipoVeiculoBit = tipoVeiculoBit.split(',');

                    var nomeTipoVeiBit = objCompleto.descricaoTipoVeiBit.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeTipoVeiBit = nomeTipoVeiBit.split(',');

                    for (var i = 0; i < tipoVeiculoBit.length; i++) {
                        addValorAlphaInput('inptTipoVeiculo', nomeTipoVeiBit[i], tipoVeiculoBit[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeTipoVeiCa3 != null && objCompleto.nomeTipoVeiCa3 != undefined) {
                    var tipoVeiculoCa3 = objCompleto.valorTipoVeiCa3.replace(/\[+/g, '').replace(/\]+/g, '');
                    tipoVeiculoCa3 = tipoVeiculoCa3.split(',');

                    var nomeTipoVeiCa3 = objCompleto.descricaoTipoVeiCa3.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeTipoVeiCa3 = nomeTipoVeiCa3.split(',');

                    for (var i = 0; i < tipoVeiculoCa3.length; i++) {
                        addValorAlphaInput('inptTipoVeiculo', nomeTipoVeiCa3[i], tipoVeiculoCa3[i]);
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

                if (objCompleto.nomeBloq != null && objCompleto.nomeBloq != undefined) {
                    var valorBloq = objCompleto.valorBloq.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorBloq = valorBloq.split(',');
                    var descBloq = objCompleto.descricaoBloq.replace(/\[+/g, '').replace(/\]+/g, '');
                    descBloq = descBloq.split(',');
                    for (var i = 0; i < valorBloq.length; i++) {
                        gerenciarMostrarMotorista(objCompleto.nomeBloq, valorBloq[i], objCompleto.condicaoBloq, descBloq[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeDesli != null && objCompleto.nomeDesli != undefined) {
                    var valorDesli = objCompleto.valorDesli.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorDesli = valorDesli.split(',');
                    var descDesli = objCompleto.descricaoDesli.replace(/\[+/g, '').replace(/\]+/g, '');
                    descDesli = descDesli.split(',');
                    for (var i = 0; i < valorDesli.length; i++) {
                        gerenciarMostrarMotorista(objCompleto.nomeDesli, valorDesli[i], objCompleto.condicaoDesli, descDesli[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeMope != null && objCompleto.nomeMope != undefined) {
                    var valorMope = objCompleto.valorMope.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorMope = valorMope.split(',');
                    var descMope = objCompleto.descricaoMope.replace(/\[+/g, '').replace(/\]+/g, '');
                    descMope = descMope.split(',');
                    for (var i = 0; i < valorMope.length; i++) {
                        gerenciarMostrarMotorista(objCompleto.nomeMope, valorMope[i], objCompleto.condicaoMope, descMope[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeTipo != null && objCompleto.nomeTipo != undefined) {
                    var valorTipo = objCompleto.valorTipo.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorTipo = valorTipo.split(',');
                    var descTipo = objCompleto.descricaoTipo.replace(/\[+/g, '').replace(/\]+/g, '');
                    descTipo = descTipo.split(',');
                    for (var i = 0; i < valorTipo.length; i++) {
                        gerenciarMostrarMotorista(objCompleto.nomeTipo, valorTipo[i], objCompleto.condicaoTipo, descTipo[i]);
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

function gerenciarMostrarMotorista(name, valor, condicao, descricao) {
    valor = valor.trim();
    if (name == 'bloqueado') {
        if (valor == 'Sim') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[1]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-motorista option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'Não') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[2]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-motorista option[value="' + condicao + '"]').attr('selected', 'selected');
        }
    }
    if (name == 'desligado') {
        if (valor == 'Sim') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[4]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-motorista option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'Não') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[5]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-motorista option[value="' + condicao + '"]').attr('selected', 'selected');
        }
    }
    if (name == 'curso_mope') {
        if (valor == 'Sim') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[7]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-motorista option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'Não') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[8]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-motorista option[value="' + condicao + '"]').attr('selected', 'selected');
        }
    }
    if (name == 'tipo_motorista') {
        if (valor == 'Funcionário') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[10]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-motorista option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'Agregado') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[11]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-motorista option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'Carreteiro') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[12]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-motorista option[value="' + condicao + '"]').attr('selected', 'selected');
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

function gerenciarInpVeiculos(nome, valor, descricao, condicao) {
    if (nome == 'veiculo_id' || nome == 'carreta_id' || nome == 'bitrem_id' || nome == 'carreta3_id') {
        jQuery('#select-exceto-apenas-veiculo option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            if (jQuery(inptVeiculo).val() == "") {
                jQuery('#filtros-adicionais-container').show();
                addValorAlphaInput('inptVeiculo', descricao[i].trim(), valor[i].trim());
            }
        }
    }
}

function gerenciarInpTipoVeiculo(nome, valor, descricao, condicao) {
    if (nome == 'tipo_veiculo_id' || nome == 'tipo_veiculo_carreta_id' || nome == 'tipo_veiculo_bitrem_id' || nome == 'tipo_veiculo_carreta3_id') {
        jQuery('#select-exceto-apenas-tipo-veiculo option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            if (jQuery(inptTipoVeiculo).val() == "") {
                jQuery('#filtros-adicionais-container').show();
                addValorAlphaInput('inptTipoVeiculo', descricao[i].trim(), valor[i].trim());
            }
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

function enviarMotoristaEfrete(e) {
    var ordem = $(e).parent().parent().attr('ordem');
    var id = $('#hi_row_id_' + ordem).val();

    $('.container-envio-motorista').show();
    $.ajax({
        url: 'EFreteControlador?acao=enviarMotorista&idmotorista=' + id,
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
        url: 'ExpersControlador?acao=enviarMotoristaExpers&idmotorista=' + id,
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
        url: 'PagBemControlador?acao=enviarMotoristaPagBem&idmotorista=' + id,
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
        url: 'RepomControlador?acao=enviarMotoristaRepom&idmotorista=' + id,
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
        url: 'TargetControlador?acao=enviarMotoristaTarget&idmotorista=' + id,
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

function colorirColunasBloqueados() {
    jQuery("input[id^='hi_row_bloqueado_'][value='Sim']")
        .parents("tr")
        .attr('style',"color: red !important;")
        .find("label")
        .attr('style', "color: inherit !important;");
}