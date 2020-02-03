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
    location.replace("cadocorrencia.jsp?acao=editar&id=" + id);
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
    } else if (item != undefined) {
        ids = jQuery('#hi_row_id_' + item).val();
        nomes = jQuery('#hi_row_descricao_' + item).val();
    }

    var texto = "";
    if (index > 1) {
        texto = "Deseja excluir as ocorrencias abaixo?";
    } else {
        texto = "Deseja excluir a ocorrencia abaixo?";
    }
    chamarConfirm(texto, 'aceitouExcluirOcorrencia("' + ids + '")', '', 1, '<ul class="square">' + nomes + '</ul>');

}

function aceitouExcluirOcorrencia(ids) {
    jQuery.ajax({
        url: 'OcorrenciaControlador?acao=excluir&ids=' + ids,
        success: function (data, textStatus, jqXHR) {
            chamarAlert(data, reload);
        }
    });
}

function reload() {
    window.location.reload();
}

jQuery(document).ready(function () {
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
                removerValorInput('inpSelectVal');
                jQuery('#createdMe').prop('checked', false);

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


                jQuery('.container-campos-select').show();

                jQuery('#select-abrev option[value=' + objCompleto.nome1 + ']').prop('selected', true);
                jQuery("#select-abrev").selectmenu("refresh");

                // houve alguma divergencia no nome do campo, assim, tem vezes que vem valor e tem vezes que vem valor1;
                var valor1;
                if ((objCompleto.valor1 === undefined || objCompleto.valor1 === null) && (objCompleto.valor !== null && objCompleto.valor !== undefined)) {
                    valor1 = objCompleto.valor.replace(/\[+/g, '').replace(/\]+/g, '');
                }else{
                    valor1 = objCompleto.valor1.replace(/\[+/g, '').replace(/\]+/g, '');
                }
                
                valor1 = valor1.split(',');

                for (var i = 0; i < valor1.length; i++) {
                    addValorAlphaInput('inpSelectVal', valor1[i].trim());
                }

                if (objCompleto.nomeColeta != null && objCompleto.nomeColeta != undefined) {
                    jQuery('#coleta').prop('checked', true);
                }

                if (objCompleto.nomeConhecimento != null && objCompleto.nomeConhecimento != undefined) {
                    jQuery('#conhecimento').prop('checked', true);
                }

                if (objCompleto.nomeContratoFrete != null && objCompleto.nomeContratoFrete != undefined) {
                    jQuery('#contrato_frete').prop('checked', true);
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
        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        valor = valor.split(",");
        for (var i = 0; i < valor.length; i++) {
            addValorAlphaInput('inpSelectVal', valor[i].trim());

        }
    }
}

function gerenciarCheckBoxColeta(nome, valor) {
    if (nome == 'is_coleta') {
        jQuery('#coleta').prop('checked', true);
    }
}

function gerenciarCheckBoxConhecimento(nome, valor) {
    if (nome == 'is_conhecimento') {
        jQuery('#conhecimento').prop('checked', true);
    }
}

function gerenciarCheckBoxContratoFrete(nome, valor) {
    if (nome == 'is_contrato_frete') {
        jQuery('#contrato_frete').prop('checked', true);
    }
}

var ocoCode = "";
function getCheckeds() {
    var ocorrencias = "";
    var i = 0;
    isSinc = "";
    jQuery("input[type=checkbox][name*=nCheck]").each(
            function (f, a) {
                f = f + 1;
                if (a.checked) {
                    if (jQuery("#hi_row_entrega_realizada_" + f).val() == "Sim") {
                        if (jQuery("#hi_row_entrega_nao_realizada_" + f).val() == "Sim") {
                            chamarAlert("Atenção a ocorrencia '" + jQuery("#hi_row_codigo_" + f).val() + "' foi configurada como de entrega e não entrega para o gwMobile só dever haver uma opção marcada.");
                            ocoCode = "";
                            return false;
                        }
                    }
                        ocoCode += "," + jQuery("#hi_row_codigo_" + f).val();

                }
            }
    );

    return true;
}
function sincronizarGWMobile() {
    // se estiver marcada como entregae não entrega deverá levantar excessao.
    var valido = getCheckeds();
    if (valido && ocoCode !== "" ) {
        window.open("./MobileControlador?acao=sincronizarGWMobileOcorrencia&ocoCode="+ocoCode.substr(1) , "pop", 'top=10,left=0,height=50,width=50,resizable=yes,status=1,scrollbars=1');
        ocoCode = "";
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