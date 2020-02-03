
var myConfObj = {
    iframeMouseOver: false
};

var containerVideo = null;

window.addEventListener('blur', function () {
    if (myConfObj.iframeMouseOver) {
        jQuery(containerVideo).trigger('change');
    }
});
function cadastrarFornecedor() {
    location.replace("./cadfornecedor?acao=iniciar");
}

function relatorioFornecedor() {
    window.open('./relfornecedores.jsp?acao=iniciar&modulo=webtrans', "_blank", "toolbar=yes,scrollbars=yes,resizable=yes,top=200,left=500,width=800,height=600");
}

function editar(position) {
    var id = jQuery("#hi_row_codigo_" + position).val();
    window.location.href = "./cadfornecedor?acao=editar&id=" + id;
}


function consultaFornecedor() {
    jQuery("#formConsulta").submit();
}

function excluir(item) {
    var index = 0;
    var ids = '';
    var nomes = '';

    if (item == undefined) {
        while (jQuery('input:checked[type=checkbox][name*=nCheck]')[index] != undefined) {

            var val = jQuery('input:checked[type=checkbox][name*=nCheck]')[index].value;
            var id = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().find('#hi_row_codigo_' + val).val();
            var nome = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().find('#hi_row_razaosocial_' + val).val();

            if (jQuery('input:checked[type=checkbox][name*=nCheck]')[index + 1] != undefined) {
                ids += id + ',';
            } else {
                ids += id;
            }

            nomes += '<li>' + nome + '</li>';

            index++;
        }
    } else if (item != undefined) {
        ids = jQuery('#hi_row_codigo_' + item).val();
        nomes = jQuery('#hi_row_razaosocial_' + item).val();
    }

    var texto = "";
    if (index > 1) {
        texto = "Deseja excluir os fornecedores abaixo?";
    } else {
        texto = "Deseja excluir o fornecedor abaixo?";
    }
    chamarConfirm(texto, 'aceitouExcluirFornecedores("' + ids + '")', '', 1, '<ul class="square">' + nomes + '</ul>');

}

function aceitouExcluirFornecedores(ids) {
    jQuery.ajax({
        url: 'FornecedorControlador?acao=excluir_fornecedor&ids=' + ids,
        success: function (data, textStatus, jqXHR) {
            chamarAlert(data, reload);
        }
    });
}

function reload() {
    window.location.reload();
}



function abrirLocalizarCidade() {
    //Reduz o z-index do lb-filtros para ele nao parecer
    jQuery('.salvarPesquisaContainer').css('z-index', '99');

    jQuery('.localiza').show('show');
    jQuery('.cobre-tudo').show('show');
    if (localizarCidade.document.getElementById('chkOpcoesAvancadas').checked && jQuery('#inptCidade').val() !== undefined && jQuery('#inptCidade').val().trim() !== '') {
        var i = 0;
        while (jQuery('#inptCidade').val().split('!@!')[i] != null) {
            localizarCidade.popularListaCidadesEscolhidas(jQuery('#inptCidade').val().split('!@!')[i], '');
//                        jQuery(localizarCidade.document.getElementById('sortable2')).find('li').find('.cidade')
            i++;
        }
    }
}

function abrirLocalizarGrupoFornecedor() {
    //Reduz o z-index do lb-filtros para ele nao parecer
    jQuery('.salvarPesquisaContainer').css('z-index', '99');

    jQuery('.localizaGrupo').show('show');
    jQuery('.cobre-tudo').show('show');
    if (localizarGrupoFornecedor.document.getElementById('chkOpcoesAvancadasGrupoCli').checked && jQuery('#inptGrupoCliente').val() !== undefined && jQuery('#inptGrupoCliente').val().trim() !== '') {
        var i = 0;
        while (jQuery('#inptGrupoCliente').val().split('!@!')[i] != null) {
            localizarGrupoFornecedor.popularListaGruposEscolhidos(jQuery('#inptGrupoCliente').val().split('!@!')[i]);
//                        jQuery(localizarCidade.document.getElementById('sortable2')).find('li').find('.cidade')
            i++;
        }
    }
}

function controleLocalizarCidades(acao, parametros, apagarDadosInput) {
    if (acao === 'fechar') {
        jQuery('.localiza').hide('show');
        jQuery('.cobre-tudo').hide('show');
        localizarCidade.voltarTodosItens();
        //Restaura o z-index do salvarPesquisaContainer para ele aparecer
        jQuery('.salvarPesquisaContainer').css('z-index', '999999');
    } else if (acao === 'finalizado') {
        controleLocalizarCidades('fechar', null);
        if (apagarDadosInput === true) {
            removerValorInput('inptCidade');
        }
        addValorAlphaInput('inptCidade', parametros.split("!@!")[0]);
        localizarCidade.voltarTodosItens();
    } else if (acao === 'mensagem') {
        chamarAlert(parametros, null);
        localizarCidade.voltarTodosItens();
    }
}

function salvarPreferencias() {
    var json = getJsonPreferencias();
    jQuery.ajax({
        dataType: 'json',
        method: 'POST',
        url: 'ConsultaControlador?acao=salvarPreferencias&codigoTela=14',
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

    colorirColunasBloqueados();

    jQuery('.tabela-gwsistemas').on('coluna-adicionada', function() {
        colorirColunasBloqueados();
    });
});


var srcSalvarFiltroOriginal = null;
var objCompleto;

function sincronizarGwMobile(e, actionImport) {
    console.log(e);
  var ordem = $(e).parent().parent().attr('ordem');
  var idfornecedor = jQuery('#hi_row_codigo_' + ordem).val();
window.open("./MobileControlador?acao=sincronizarGWMobileFornecedor&idFornecedor=" + idfornecedor + "&actionImport="+ actionImport, "pop", 'top=10,left=0,height=50,width=50,resizable=yes,status=1,scrollbars=1');
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
                jQuery('#ambosAtv').trigger('click');

                jQuery('#id-tipos-escolhidos').val('');
                jQuery('#tipos-escolhidos').val('');

                removerValorInput('inpSelectVal');
                removerValorInput('inptCidade');
                removerValorInput('inptGrupoFornecedor');
                removerValorInput(jQuery('input[name="inptVendedor"]'));
                removerValorInput(jQuery('input[name="inptSupervisor"]'));

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
                    var cidades = objCompleto.valorCidade.replace(/\[+/g, '').replace(/\]+/g, '');
                    cidades = cidades.split(',');

                    for (var i = 0; i < cidades.length; i++) {
                        addValorAlphaInput('inptCidade', cidades[i]);
                    }

                    var condicao = (objCompleto.operadorCidade == 4 ? "apenas" : "exceto");
                    jQuery('#select-exceto-apenas-cidade option[value="' + condicao + '"]').attr('selected', 'selected');

                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeGrupo != null && objCompleto.nomeGrupo != undefined) {

                    var grupo = objCompleto.valorGrupo.replace(/\[+/g, '').replace(/\]+/g, '');
                    grupo = grupo.split(',');

                    for (var i = 0; i < grupo.length; i++) {
                        addValorAlphaInput('inptGrupoCliente', grupo[i]);
                    }

                    var condicao = (objCompleto.operadorGrupo == 4 ? "apenas" : "exceto");
                    jQuery('#select-exceto-apenas-grupo-cliente option[value="' + condicao + '"]').attr('selected', 'selected');

                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeVendedor != null && objCompleto.nomeVendedor != undefined) {
                    var vendedor = objCompleto.valorVendedor.replace(/\[+/g, '').replace(/\]+/g, '');
                    vendedor = vendedor.split(',');

                    for (var i = 0; i < vendedor.length; i++) {
                        addValorAlphaInput(jQuery('input[name="inptVendedor"]'), vendedor[i]);
                    }

                    var condicao = (objCompleto.operadorVendedor == 4 ? "apenas" : "exceto");
                    jQuery('#select-exceto-apenas-vendedor option[value="' + condicao + '"]').attr('selected', 'selected');

                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeSupervisor != null && objCompleto.nomeSupervisor != undefined) {
                    var supervisor = objCompleto.valorSupervisor.replace(/\[+/g, '').replace(/\]+/g, '');
                    supervisor = supervisor.split(',');

                    for (var i = 0; i < supervisor.length; i++) {
                        addValorAlphaInput(jQuery('input[name="inptSupervisor"]'), supervisor[i]);
                    }

                    var condicao = (objCompleto.operadorSupervisor == 4 ? "apenas" : "exceto");
                    jQuery('#select-exceto-apenas-supervisor option[value="' + condicao + '"]').attr('selected', 'selected');

                    jQuery('#filtros-adicionais-container').show();
                }
                if (objCompleto.nomeForAtv != null && objCompleto.nomeForAtv != undefined) {
                    if (objCompleto.valorForAtv == "Sim") {
                        jQuery('#ativos').prop('checked', true);
                        jQuery('#filtros-adicionais-container').show();
                    }

                    if (objCompleto.valorForAtv == "Não") {
                        jQuery('#inativos').prop('checked', true);
                        jQuery('#filtros-adicionais-container').show();
                    }
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
        var aoSalvar = iframeSalvarFiltros.jQuery("input[name='aoSalvar']:checked").val();
        var isPrivado = (iframeSalvarFiltros.jQuery('input[name=options]:checked').val() == 1 ? true : false);

        jQuery.ajax({
            url: 'ConsultaControlador?acao=cadPrefUsuPersonalizada&nomePesquisa=' + nomePesquisa + "&isPrivado=" + isPrivado + '&aoSalvar=' + aoSalvar + '&idPreferencia=' + idPreferencia + '&cod_tela=14',
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
    jQuery("input[id^='hi_row_fornecedor_ativo_'][value='Não']")
        .parents("tr")
        .attr('style',"color: red !important;")
        .find("label")
        .attr('style', "color: inherit !important;");
}