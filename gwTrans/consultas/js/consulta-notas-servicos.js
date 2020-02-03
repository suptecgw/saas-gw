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
    location.replace("./cadvenda.jsp?acao=editar&id=" + id);
}

function abrirNFSeG2ka() {
    let idfilial = "";
    let idconsignatario = "";
    let cons_rzs = "";
    location.replace("./NFSeG2kaControlador?acao=listar&statusCte=P&idFilial=" + idfilial + "&idconsignatario=" + idconsignatario + "&con_rzs=" + cons_rzs);
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
            var nome = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().find('#hi_row_num_nfs_' + val).val();

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
        nomes = jQuery('#hi_row_num_nfs_' + item).val();
    }

    var texto = "";
    if (index > 1) {
        texto = "Deseja excluir as notas abaixo?";
    } else {
        texto = "Deseja excluir a nota abaixo?";
    }
    chamarConfirm(texto, 'aceitouExcluirNota("' + ids + '")', '', 1, '<ul class="square">' + nomes + '</ul>');

}

function aceitouExcluirNota(ids) {
    jQuery.ajax({
        url: 'NotaServicoControlador?acao=excluir&ids=' + ids,
        success: function (data, textStatus, jqXHR) {
            chamarAlert(data, reload);
        }
    });
}

function reload() {
    window.location.reload();
}

jQuery(document).ready(function () {

    jQuery('#select-tipo-nota').selectGrupoMultiploGw({
        input: 'select-tipo-nota',
        grupos: {
            Status: {
                1: 'Canceladas!!cancelado!!Sim!!IGUAL',
                2: 'Não Canceladas!!cancelado!!Não!!IGUAL'
            }
        }
    });

    jQuery('#select-exceto-apenas-tipo-nota').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-filial').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#inptFilial').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#select-exceto-apenas-cliente').selectExcetoApenasGw({
        width: '170px'
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

    jQuery("#paneConsulta").css('height', jQuery(window).height() - 300);

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
                jQuery('#naoImpressas').prop('checked', false);
                removerValorInput('inpSelectVal');
                removerValorInput('select-tipo-nota');
                removerValorInput('inptSerie');
                removerValorInput('inptFilial');
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

                if (objCompleto.nomeImpresso != null && objCompleto.nomeImpresso != undefined) {
                    jQuery('#naoImpressas').prop('checked', true);
                    jQuery('#filtros-adicionais-container').show();
                }
                
                if (objCompleto.nomeCanc != null && objCompleto.nomeCanc != undefined) {
                    var valorCanc = objCompleto.valorCanc.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorCanc = valorCanc.split(',');
                    var descCanc = objCompleto.descricaoCanc.replace(/\[+/g, '').replace(/\]+/g, '');
                    descCanc = descCanc.split(',');
                    for(var i = 0; i < valorCanc.length; i++){
                        gerenciarStatusNota(objCompleto.nomeCanc, valorCanc[i], objCompleto.condicaoCanc, descCanc[i]);
                    }
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
        if (nome == 'emissao') {
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

function gerenciarStatusNota(name, valor, condicao, descricao) {
    valor = valor.trim();
    if (name == 'cancelado') {
        if (valor == 'Sim') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[1]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-nota option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'Não') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[2]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-nota option[value="' + condicao + '"]').attr('selected', 'selected');
        }
    }
    jQuery('.container-li-valores').hide();
}

function gerenciarInpSerie(nome, valor) {
    if (nome == 'serie') {
        jQuery("#dataAte").datebox({disabled: true});
        jQuery("#dataDe").datebox({disabled: true});
        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        valor = valor.split(",");
        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptSerie', valor[i].trim());
        }
    }
}

function gerenciarCheckBox(nome, valor) {
    if (nome == 'is_impresso') {
        jQuery('#naoImpressas').prop('checked', true);
        jQuery('#filtros-adicionais-container').show();
    }
    if (nome == 'criado_por') {
        jQuery('#createdMe').prop('checked', true);
        jQuery('#filtros-adicionais-container').show();
    }
}

function gerenciarInpCliente(nome, valor, descricao, condicao) {
    if (nome == 'consignatario_id') {
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

function popNota(index) {
    var ordem = jQuery(index).parent().parent().attr('ordem');
    var id = jQuery("#hi_row_id_" + ordem).val();
    var modelo = jQuery('#cbmodelo').val();
    console.log("Modelo: " + modelo);
    if (id == null)
        return null;
    launchPDF('./consulta_venda.jsp?acao=exportar&idNota=' + id + "&modelo=" + modelo);

}

function launchPDF(url, idname) {
    var cf = 'top=0,left=0,height=600,width=800,resizable=yes,status=1,scrollbars=1';
    var pdf = window.open(url, idname, cf);
    pdf.window.resizeTo(screen.width, screen.height - 20);
    pdf.focus();
}

function popRel(index) {
    var ordem = jQuery(index).parent().parent().attr('ordem');
    let driver = jQuery('#driverImpressora').val();
    let id = jQuery("#hi_row_id_" + ordem).val();
    let impresso = jQuery("#hi_row_is_impresso_" + ordem).val();
    if (driver == '') {
        chamarAlert("Escolha o Driver de Impressão Corretamente!");
        return null;
    }
    if (impresso == 'true' && !confirm("Essa Nota Já Foi Impressa, Deseja Imprimi-la Novamente?")) {
        return null
    }
    var url = "./matricidevenda.ctrc?id=" + id + "&" + concatFieldValue("driverImpressora,impressora");
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