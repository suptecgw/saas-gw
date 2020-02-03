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
    var id = jQuery("#hi_row_numero_" + position).val();
    location.replace("CadastroControlador?codTela=" + codigo_tela_cadastro + "&modulo=editar&id=" + id);
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
                var id = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().find('#hi_row_numero_' + val).val();
                var competencia = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().find('#hi_row_competencia_' + val).val();

                if (jQuery('input:checked[type=checkbox][name*=nCheck]')[index + 1] != undefined) {
                    ids += id + ',';
                } else {
                    ids += id;
                }

                nomes += '<li>' + id + ' - ' + competencia + '</li>';

                index++;
            }
        } else if (item) {
            ids = jQuery('#hi_row_id_' + item).val();
            nomes = jQuery('#hi_row_descricao_' + item).val();
        }

        var texto = "";
        if (index > 1) {
            texto = "Deseja excluir as Orçamentações abaixo?";
        } else {
            texto = "Deseja excluir a Orçamentação abaixo?";
        }
        chamarConfirm(texto, 'aceitouExcluirOrcamentacao("' + ids + '")', '', 1, '<ul class="square">' + nomes + '</ul>');
    
}

function aceitouExcluirOrcamentacao(ids) {
    jQuery.ajax({
        url: 'OrcamentacaoControlador?acao=excluir&ids=' + ids,
        success: function (data, textStatus, jqXHR) {
            chamarAlert(data, function () {
                window.location.reload();
            });
        }
    });
}

jQuery(document).ready(function () {    
    
    jQuery('#select-tipo-usuario').selectGrupoMultiploGw({
        input: 'select-tipo-usuario',
        grupos: {
            Tipo: {
                1: 'Ativo!!ativo!!Sim!!IGUAL',
                2: 'Inativo!!ativo!!Não!!IGUAL'
            }
        }
    });
    
    jQuery('#select-exceto-apenas-filial').selectExcetoApenasGw({
        width: '170px'
    });


    jQuery('#inptFilial').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery("#paneConsulta").css('height', jQuery(window).height() - 300);

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

    jQuery('span[class="bt bt-cadastro"]').on('click', function () {
        checkSession(function () {
            btnCadastrar('CadastroControlador?codTela=' + codigo_tela_cadastro)
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
                removerValorInput('inptFilial');

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

                    jQuery("#competenciaAte").attr('disabled',true);
                    jQuery("#competenciaDe").attr('disabled',true);


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
                    jQuery("#competenciaAte").attr('disabled',false);
                    jQuery("#competenciaDe").attr('disabled',false);

                    jQuery('#competenciaAte').val(convertDataToCompetencia(objCompleto.valor21));
                    jQuery('#competenciaDe').val(convertDataToCompetencia(objCompleto.valor1));

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

            },
            error: function (jqXHR, textStatus, errorThrown) {
                chamarAlert('Ocorreu um erro ao tentar carregar o filtro escolhido.');
            },
            complete: function (jqXHR, textStatus) {
                jQuery('#searchOrcamento').trigger('click');
            }

        });

    }, 500);
}

function gerenciarInpSelectVal(nome, valor, valor2) {
    if (jQuery('#select-abrev option[value=' + nome + ']').size() >= 1) {
        if (nome == 'competencia_data') {
            let data = new Date();
            let mes = data.getMonth() + 1;
            let ano = data.getFullYear();
            let competenciaAtual = (mes < 10 ? ('0' + mes) : mes) + '/' + ano;
            
            jQuery('.container-campos-select').hide(250, function () {
                jQuery('.container-data').show(250);
                jQuery("#competenciaAte").attr('disabled',false);
                jQuery("#competenciaDe").attr('disabled',false);
                
                jQuery('#competenciaAte').val(valor2 == undefined || valor2 == '' ? competenciaAtual : convertDataToCompetencia(valor2));
                jQuery('#competenciaDe').val(valor == undefined || valor == '[]'  ? competenciaAtual : convertDataToCompetencia(valor));

                jQuery('.datebox').css('width', '93%');
                jQuery('.textbox-text').css('width', '93%');
                jQuery('.textbox-text').css('font-size', '14px');
            });
        } else {
            jQuery("#competenciaAte").attr('disabled',true);
            jQuery("#competenciaDe").attr('disabled',true);
            valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
            valor = valor.split(",");
            for (var i = 0; i < valor.length; i++) {
                addValorAlphaInput('inpSelectVal', valor[i].trim());
            }
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

function convertDataToCompetencia(valor){
    if(valor != undefined && validaData(valor)){
        let data = valor.split("/");
        let mm = data[1];
        let yy = data[2]
        return mm+'/'+yy;
    }
}

function gerenciarCheckBox(nome, valor) {
    if (nome == 'criado_por') {
        jQuery('#createdMe').prop('checked', true);
        jQuery('#filtros-adicionais-container').show();
    }
}  