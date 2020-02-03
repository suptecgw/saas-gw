/**
 * @author Mateus <mateus@gwsistemas.com.br>
 */

/*  GGGGGGGGGGGG   WWW           WWW
 *  GGGGGGGGGGGG   WW             WW
 *  GG             WW      W      WW
 *  GG    GGGGGG   WWW    WWW    WWW  
 *  GG       GGG   WWWW WWW WWW WWWW
 *  GGGGGGGGGGGG   WWWWWWW   WWWWWWW
 */

/**
 * Controlador JAVASCRIPT
 * Responsavel por controlar todos os "localiza"
 */

var controlador = {
    /*
     * 
     * @param {String} acao
     * @param {Elementi} elemento
     * @param {String} parametros
     * @param {evento} evento
     * @returns {undefined}
     */
    acao: function (acao, elemento, parametros, evento) {
        switch (acao) {
            case 'fechar':
                fecharLocalizar(elemento, parametros);
                break;
            case 'abrirLocalizar':
                abrirLocalizar(elemento, parametros);
                break;
            case 'finalizar':
                finalizar(elemento, parametros);
                break;
            case 'mensagem':
                chamarAlert(elemento);
                break;
            case 'passarSelecionados':
                passarItensSelecionados(elemento);
                break;
            case 'voltarSelecionados':
                voltarItensSelecionados(elemento);
                break;
            case 'passarTodos':
                passarTodos(elemento);
                break;
            case 'voltarTodos':
                voltarTodos(elemento);
                break;
            case 'opcoesAvancadas':
                opcoesAvancadas(elemento);
                break;
            case 'ativarDraggable':
                ativarDraggable(elemento);
                break;
            case 'localizar':
                localizar(elemento, parametros, evento);
                break;
            case 'popularLista':
                popularLista();
                break;
            case 'enviarSelecionados':
                enviarSelecionados(elemento);
                break;
            case 'limparLocalizar':
                limparLocalizar(elemento);
                break;
        }
    }
};

/*
 * @param {Iframe} elemento
 * @param {Parametros para ações especificas} parametros
 * @returns {undefined}
 */
function fecharLocalizar(elemento, parametros) {
    if (typeof elemento === 'string') {
        elemento = jQuery('#' + elemento);
    }

    if (parametros) {
        if (parametros.indexOf('limparInput') !== -1) {
            var nomeInput = parametros.split(',')[0].split(':')[1];
            removerValorInput(nomeInput);
        }
    }

    jQuery(elemento).parent().hide();
    jQuery(elemento).hide();
    jQuery('#' + elemento.attr('input')).trigger('change');
    jQuery('.cobre-tudo').fadeOut('slow');
    jQuery('.div-lb-filtros').css('z-index', '999999');

    jQuery('body').scrollTop(lastScroll).css("overflow", "");
}

/**
 * @param {Elemento} elemento
 * @param {String} parametros 
 */
var lastScroll;

function abrirLocalizar(elemento, parametros) {
    lastScroll = jQuery('body').scrollTop();
    jQuery('body').scrollTop(0).css("overflow", "hidden");
    
    if (typeof elemento === 'string') {
        elemento = jQuery('#' + elemento);
    }

    var idElemento = jQuery(elemento).attr('id');
    var docEl = document.getElementById(idElemento).contentWindow.document;
    if (jQuery(docEl).find('.envolve-topo').html().trim() === '') {
        montarTopoLocalizar(elemento, docEl);
    }

    if (typeof parametros === 'object') {
        switch (parametros.getTipo()) {
            case 'veiculo':
                var select = jQuery('<select id="select-tipo">');
                var option = jQuery('<option value="ambos">').html('Mostrar veículos');
                select.append(option);
                var option = jQuery('<option value="tracao">').html('Do tipo tração');
                select.append(option);
                var option = jQuery('<option value="reboque">').html('Do tipo reboque');
                select.append(option);
                jQuery(docEl).find('.filtro-especial').html(select);
                break;
            case 'carreta':
                var select = jQuery('<select id="select-tipo">');
                var option = jQuery('<option value="reboque">').html('Do tipo reboque');
                select.append(option);
                jQuery(docEl).find('.filtro-especial').html(select);
                break;

        }
    }

    jQuery('.div-lb-filtros').css('z-index', '99');
    jQuery('.cobre-tudo').fadeIn("slow");

    jQuery(elemento).parent().show(250, function () {
        jQuery(elemento).show();
    });
}

/**
 * @param {Iframe} elemento
 * @param {parametros para a funcao} parametros
 */
function finalizar(elemento, parametros) {
    if (typeof elemento === 'string') {
        elemento = jQuery('#' + elemento);
    }
    var idElemento = jQuery(elemento).attr('id');

    fecharLocalizar(elemento);

    if (parametros.indexOf('limparInput') !== -1) {
        removerValorInput(parametros.split(';;')[0].split(':')[1]);
    }
    addValorAlphaInput(parametros.split(';;')[0].split(':')[1], parametros.split(';;')[1].split("!@!")[0], parametros.split(';;')[1].split('!@!')[1]);
    document.getElementById(idElemento).contentWindow.voltarTodosItens();
}

/**
 * @param {Iframe} elemento
 */
function passarItensSelecionados(elemento) {
    if (typeof elemento === 'string') {
        elemento = jQuery('#' + elemento);
    }
    var idElemento = jQuery(elemento).attr('id');
    var docEl = document.getElementById(idElemento).contentWindow.document;

    var cloneSelecionado = jQuery(docEl).find('.selecionado').clone();

    if (!podeEscolher(docEl, cloneSelecionado))
        return false;

    jQuery(docEl).find('.selecionado').remove();
    jQuery(cloneSelecionado).prependTo(jQuery(docEl).find('#topo-resultados-col2'));
    jQuery(cloneSelecionado).find('img').remove();
    jQuery(cloneSelecionado).removeClass('selecionado');
    jQuery(cloneSelecionado).attr('onclick', 'parent.marcarItemRemover(this);');
}

/**
 * @param {Iframe} elemento
 */
function voltarItensSelecionados(elemento) {
    if (typeof elemento === 'string') {
        elemento = jQuery('#' + elemento);
    }
    var idElemento = jQuery(elemento).attr('id');
    var docEl = document.getElementById(idElemento).contentWindow.document;

    var cloneSelecionado = jQuery(docEl).find('.remover-selecionado').clone();
    jQuery(docEl).find('.remover-selecionado').remove();
    jQuery(cloneSelecionado).prependTo(jQuery(docEl).find('#topo-resultados-col1'));
    jQuery(cloneSelecionado).find('img').remove();
    jQuery(cloneSelecionado).removeClass('remover-selecionado');
    jQuery(cloneSelecionado).attr('onclick', 'parent.marcarItemAdicionar(this);');
}

/**
 * @param {Iframe} elemento
 */
function passarTodos(elemento) {
    if (typeof elemento === 'string') {
        elemento = jQuery('#' + elemento);
    }
    var idElemento = jQuery(elemento).attr('id');
    var docEl = document.getElementById(idElemento).contentWindow.document;


    var cloneItens = jQuery(docEl).find('#topo-resultados-col1 li').clone();
    jQuery(docEl).find('#topo-resultados-col1 li').remove();
    jQuery(cloneItens).prependTo(jQuery(docEl).find('#topo-resultados-col2'));

    var index = 0;
    while (cloneItens[index] !== undefined) {
        jQuery(cloneItens[index]).removeClass('selecionado');
        jQuery(cloneItens[index]).removeClass('remover-selecionado');

        if (jQuery(cloneItens[index]).find('img') !== undefined) {
            jQuery(cloneItens[index]).find('img').remove();
        }

        ativarClickOpcoesAvancadasTrue(jQuery(cloneItens[index]), docEl);
        index++;
    }

}

/**
 * @param {Iframe} elemento
 */
function voltarTodos(elemento) {
    if (typeof elemento === 'string') {
        elemento = jQuery('#' + elemento);
    }
    var idElemento = jQuery(elemento).attr('id');
    var docEl = document.getElementById(idElemento).contentWindow.document;


    var cloneItens = jQuery(docEl).find('#topo-resultados-col2 li').clone();
    jQuery(docEl).find('#topo-resultados-col2 li').remove();
    jQuery(cloneItens).prependTo(jQuery(docEl).find('#topo-resultados-col1'));

    var index = 0;
    while (cloneItens[index] !== undefined) {
        jQuery(cloneItens[index]).removeClass('selecionado');
        jQuery(cloneItens[index]).removeClass('remover-selecionado');

        if (jQuery(cloneItens[index]).find('img') !== undefined) {
            jQuery(cloneItens[index]).find('img').remove();
        }

        ativarClickOpcoesAvancadasTrue(jQuery(cloneItens[index]), docEl);
        index++;
    }

}


/**
 * @param {Iframe} e
 */
function opcoesAvancadas(e) {
    var velocidade = 200;

    if (typeof e === 'string') {
        e = jQuery('#' + e);
    }

    var idElemento = jQuery(e).attr('id');
    var docEl = document.getElementById(idElemento).contentWindow.document;

    var elemento = jQuery(docEl).find('.opcoes-avancadas');
    var check = jQuery(docEl).find('#chkOpcoesAvancadas');
    check.attr('disabled', 'true');

    if (elemento.attr('marcado') === 'false') {
        var li = jQuery(docEl).find('#topo-resultados-col1 li');
        jQuery(li).find('div').css('text-decoration', 'none');
        jQuery(li).find('div').css('color', '#444');
        ativarClickOpcoesAvancadasTrue(li, docEl);

        elemento.attr('marcado', 'true');

        var i = 0;
        while (jQuery(docEl).find('#topo-resultados-col1 li')[i] !== undefined) {
            var abreviatura = jQuery(docEl).find(jQuery('#topo-resultados-col1 li')[i]).find('.abreviatura').html();
            jQuery(docEl).find(jQuery('#topo-resultados-col1 li')[i]).attr('onclick', "parent.marcarItemAdicionar(this);");
            i++;
        }


        jQuery(docEl).find('.coluna-pesquisa').animate({
            'width': '43%'
        }, velocidade, function () {
            jQuery(docEl).find('.coluna-centro').animate({
                'width': '8%'
            }, velocidade, function () {
                jQuery(docEl).find('.coluna-centro').show('fast');
            });
            jQuery(docEl).find('.coluna-escolhidas').animate({
                'width': '43%'
            }, velocidade, function () {
                jQuery(docEl).find('.coluna-escolhidas').show('fast');
                jQuery(docEl).find('.footer-localizar').show('fast');
            });
        });

        setTimeout(function () {
            check.removeAttr('disabled');
        }, 1000);


    } else if (elemento.attr('marcado') === 'true') {
        elemento.attr('marcado', 'false');

        var li = jQuery(docEl).find('#topo-resultados-col1 li');
        jQuery(li).find('div').css('text-decoration', 'underline');
        jQuery(li).find('div').css('color', 'var(--tonalidade2)');

        jQuery(docEl).find('.coluna-escolhidas').hide('fast');
        jQuery(docEl).find('.footer-localizar').hide('fast');

        jQuery(docEl).find('.topo-resultados-estado').css('margin-left', '25px');

        ativarClickOpcoesAvancadasFalse(li, e, docEl);


        jQuery(docEl).find('.coluna-pesquisa').animate({
            'width': '97%'
        }, velocidade, function () {

            jQuery(docEl).find('.coluna-centro').animate({
                'width': '1%'
            }, velocidade, function () {
                jQuery(docEl).find('.coluna-centro').hide('fast');
            });

            jQuery(docEl).find('.coluna-escolhidas').animate({
                'width': '44%'
            }, velocidade, function () {
            });
        });

        setTimeout(function () {
            check.removeAttr('disabled');
        }, 1000);


    }



}

function ativarDraggable(elemento) {
    if (typeof elemento === 'string') {
        elemento = jQuery('#' + elemento);
    }
    var idElemento = jQuery(elemento).attr('id');
    var docEl = document.getElementById(idElemento).contentWindow.document;

    jQuery(docEl).find("#topo-resultados-col1, #topo-resultados-col2").sortable({
        connectWith: ".connectedSortable",
        items: "li:not(.nao-arrastar)",
        start: function (e, item) {
            if (!jQuery(docEl).find('#chkOpcoesAvancadas').is(':checked')) {
                jQuery(e.target).find('li').addClass('nao-arrastar');
            }
        },
        helper: function (e, item) {
            if (jQuery(item).hasClass('selecionado')) {
                var helper = jQuery('<li/>');
                if (!item.hasClass('selecionado')) {
                    var a = item.addClass('selecionado').siblings().removeClass('selecionado');
                }
                var elements = item.parent().children('.selecionado').clone();
                item.data('multidrag', elements).siblings('.selecionado').remove();
                return helper.append(elements);
            } else {
                var helper = jQuery('<li/>');
                if (!item.hasClass('remover-selecionado')) {
                    var a = item.addClass('remover-selecionado').siblings().removeClass('remover-selecionado');
                }
                var elements = item.parent().children('.remover-selecionado').clone();
                item.data('multidrag', elements).siblings('.remover-selecionado').remove();
                return helper.append(elements);
            }

        },
        stop: function (e, info) {
            info.item.after(info.item.data('multidrag')).remove();
            var li = jQuery(e.target).find('li');
            jQuery(li).find('div').css('text-decoration', 'none');
            jQuery(li).find('div').css('color', '#444');
            ativarClickOpcoesAvancadasTrue(li, docEl);
        },
        update: function (event, ui) {
            if (jQuery(event.target).attr('id') === 'topo-resultados-col2') {
                setTimeout(function () {
                    var lis = jQuery(docEl).find('#topo-resultados-col2 li');
                    var i = 0;
                    while (lis[i] !== undefined) {
                        jQuery(lis[i]).removeClass('selecionado');
                        jQuery(lis[i]).removeClass('remover-selecionado');
                        var img = jQuery(lis[i]).find('img');
                        if (img !== undefined) {
                            jQuery(img).remove();
                        }
                        ativarClickOpcoesAvancadasTrue(lis[i], docEl);
                        i++;
                    }
                }, 300);

            } else if (jQuery(event.target).attr('id') === 'topo-resultados-col1') {
                setTimeout(function () {
                    var lis = jQuery(docEl).find('#topo-resultados-col1 li');
                    var i = 0;
                    while (lis[i] !== undefined) {
                        jQuery(lis[i]).removeClass('selecionado');
                        jQuery(lis[i]).removeClass('remover-selecionado');
                        var img = jQuery(lis[i]).find('img');
                        if (img !== undefined) {
                            jQuery(img).remove();
                        }

                        jQuery(lis[i]).attr('onclick', 'parent.marcarItemAdicionar(this);');
                        i++;
                    }
                }, 300);

            }
        }

    }).disableSelection();
}

var a = null;

function localizar(elemento, parametro, paramPersonalizado) {
    if (typeof elemento === 'string') {
        elemento = jQuery('#' + elemento);
    }
    var idElemento = jQuery(elemento).attr('id');
    var docEl = document.getElementById(idElemento).contentWindow.document;

    var paginaAtual = 0;
    var totalPaginas = 0;

    var filtroId = 0;

    //Mandar o nome do controlador e sua acao separada pelos caracteres  "!@!"
    //Exemplo : ConsultaControlador!@!localizar.

    var parametros = parametro.split('!@!');

    var controlador = parametros[0];
    var acao = parametros[1];


    //Caso venha paginação, exemplo para proximo ou anterior
    if (parametros[2]) {
        if (parametros[2] === 'proximo') {
            paginaAtual = parseInt(jQuery(docEl).find('#paginaAtual').val()) + 1;
            totalPaginas = parseInt(jQuery(docEl).find('#totalPaginas').val());
        } else if (parametros[2] === 'anterior') {
            paginaAtual = parseInt(jQuery(docEl).find('#paginaAtual').val()) - 1;
            totalPaginas = parseInt(jQuery(docEl).find('#totalPaginas').val());
        }
    }

    if (parametros[3]) {
        if (parametros[3].includes('filtroId')) {
            filtroId = parametros[3].split(':')[1];
        }
    }


    //Os campos no localizar devem ter exatamente esses ids para o funcionamento.
    var filtros = jQuery(docEl).find('#inpt-filtrar-por').val();
    var campo = jQuery(docEl).find('#select-campo').val();
    var campoTipo = jQuery(docEl).find('#select-tipo').val();
    var check = jQuery(docEl).find('#chkDiferenciar').prop('checked');
    var ckeckIgual = jQuery(docEl).find('#chkIgual').prop('checked');

    //Montagem da URL
    //OBS : Todos os controladores tem que esperar exatamente esses parametros para funcionar 100%
    //Tirar duvidas : Mateus.
    var url = homePath + '/' + controlador;
    //Ajax responsavel por fazer a consulta de acordo com os filtros e popular a tela do localizar.
    jQuery.ajax({
        url: removeQuebraLinha(url),
        data: {
            'acao': removeQuebraLinha(acao),
            'filtros': removeQuebraLinha(filtros),
            'campoTipo': removeQuebraLinha(campoTipo),
            'isDiferencia': removeQuebraLinha(check),
            'isIgual': removeQuebraLinha(ckeckIgual),
            'campo': removeQuebraLinha(campo),
            'paginaAtual': removeQuebraLinha(paginaAtual),
            'totalPaginas': removeQuebraLinha(totalPaginas),
            'filtroId': filtroId,
            'parametrosPersonalizados': paramPersonalizado
//            '&campoTipo=' + campoTipo + '&isDiferencia=' + check + '&isIgual=' + ckeckIgual + '&campo=' + campo + '&paginaAtual=' + paginaAtual + '&totalPaginas=' + totalPaginas
        },
        dataType: "text",
        method: "post",
        async: false,
        complete: function (jqXHR, textStatus) {
            
            jQuery(docEl).find('#topo-resultados-col1').html('');
            var paginacao = jqXHR.responseText.split('!@!')[0];
            var paginacaoObj = jQuery.parseJSON(jQuery.parseJSON(paginacao));
            popularPaginacao(paginacaoObj, docEl, idElemento, controlador, acao, paramPersonalizado);

            var index = 0;
            jqXHR.responseText.split('!@!').forEach(function (r) {
                if (r.trim().indexOf('pagina') == -1) {
                    try {
                        if (r && r.trim() !== '') {
                            ++index;
                            //Caso seja um verificar a quantidade de colunas e montar o localizar.
                            //Popular a lista com resultados
                            popularLista(jQuery.parseJSON(trim(r)), docEl, elemento);
                        }
                    } catch (err) {
                        console.info('Erro ao tentar adicionar um objeto no localizar.');
                    }
                }
            });
        }, erro:function(jqXHR, textStatus){ console.error(jqXHR)}

    });
}

function removeQuebraLinha(s) {
    return String(s).replace(/(\r\n|\n|\r)/gm, "");
}

function popularLista(obj, docLocalizar, localizar) {
    var topoR = jQuery(docLocalizar).find('#topo-resultados-col1');
    var li = jQuery('<li class="ui-state-default">');
    for (var i in obj) {
        var colInput = jQuery(docLocalizar).find('[colunaInput]').attr('colunaInput');
        if (i === colInput) {
            var input = jQuery('<input value="' + obj[i] + '" type="hidden" name="inputId" id="inputId">');
            li.append(input);
        } else {
            var width = jQuery(docLocalizar).find('[coluna=' + i + ']').css('width');
            if (typeof obj[i] === 'object') {
                obj[i] = '&nbsp;';
            } else if (typeof obj[i] === 'string' && obj[i] === '') {
                obj[i] = '&nbsp;';
            } else if (obj[i] === 'null' || obj[i] === null) {
                obj[i] = '&nbsp;';
            }

            var div = jQuery('<div class="' + i + '" style="max-width:' + width + ';width:' + width + ';margin-left: 10px;float:left;">').html(obj[i]);
            li.append(div);
        }
    }

    if (jQuery(docLocalizar).find('#chkOpcoesAvancadas').is(':checked')) {
        jQuery(li).find('div').css('text-decoration', 'none');
        jQuery(li).find('div').css('color', '#444');
        ativarClickOpcoesAvancadasTrue(li, docLocalizar);
    } else {
        jQuery(li).find('div').css('text-decoration', 'underline');
        jQuery(li).find('div').css('color', 'var(--tonalidade2)');
        ativarClickOpcoesAvancadasFalse(li, localizar, docLocalizar);
    }

    jQuery(topoR).append(li);
}
//Responsavel por montar as colunas do localizar
function montarTopoLocalizar(localizar, documentLocalizar) {
    switch (localizar[0].id) {
        case 'localizarCliente':
            //Lembrando que o nome da coluna deve ser igual do obj json
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:50px;margin-left: 10px;" coluna="codigo">').html('Código')).append(
                        jQuery('<div class="topo-resultados-col2" style="width:200px;margin-left: 10px;" colunaEscolha="razaosocial" coluna="razaosocial">').html('Razão Social')).append(
                        jQuery('<div class="topo-resultados-col3" style="width:200px;margin-left: 10px;" coluna="nomefantasia">').html('Nome Fantasia')).append(
                        jQuery('<div class="topo-resultados-col4" style="width:125px;margin-left: 10px;" coluna="cnpj">').html('CNPJ')).append(
                        jQuery('<div class="topo-resultados-col5" style="width:100px;margin-left: 10px;" coluna="cidade">').html('Cidade')).append(
                        jQuery('<div class="topo-resultados-col6" style="width:50px;margin-left: 10px;" coluna="uf">').html('UF'));
            }
            //Adicionando os values do select
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="idcliente">').html('Código')).append(
                        jQuery('<option value="razaosocial">').html('Razão Social')).append(
                        jQuery('<option value="nomefantasia">').html('Nome Fantasia')).append(
                        jQuery('<option value="cnpj_cliente">').html('CNPJ')).append(
                        jQuery('<option value="cidade">').html('Cidade')).append(
                        jQuery('<option value="uf">').html('Uf'));
            }
            //Nome do localizar no topo
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Clientes');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar clientes escolhidos');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./jspcadcliente.jsp?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarCliente', 'ClienteControlador!@!localizaClientesIframe');
            });

            break;
        case 'localizarGrupoCliente':
            //Lembrando que o nome da coluna deve ser igual do obj json
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:500px;margin-left: 10px;" colunaEscolha="descricao" coluna="descricao">').html('Grupo'));
            }
            //Adicionando os values do select
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="descricao">').html('Descrição'));
            }
            //Nome do localizar no topo
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Grupos de Clientes');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar grupos de clientes escolhidos');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./cadgrupo_cli_for.jsp?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarGrupoCliente', 'ClienteControlador!@!localizarGrupoClientes');
            });

            break;
        case 'localizarDestinatario':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:100px;margin-left: 10px;" coluna="codigo">').html('Código')).append(
                        jQuery('<div class="topo-resultados-col2" style="width:150px;margin-left: 10px;" colunaEscolha="razaosocial" coluna="razaosocial">').html('Razão Social')).append(
                        jQuery('<div class="topo-resultados-col3" style="width:200px;margin-left: 10px;" coluna="nomefantasia">').html('Nome Fantasia')).append(
                        jQuery('<div class="topo-resultados-col4" style="width:135px;margin-left: 10px;" coluna="cnpj">').html('CNPJ')).append(
                        jQuery('<div class="topo-resultados-col5" style="width:100px;margin-left: 10px;" coluna="cidade">').html('Cidade')).append(
                        jQuery('<div class="topo-resultados-col6" style="width:50px;margin-left: 10px;" coluna="uf">').html('UF'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="idcliente">').html('Código')).append(
                        jQuery('<option value="razaosocial">').html('Razão Social')).append(
                        jQuery('<option value="nomefantasia">').html('Nome Fantasia')).append(
                        jQuery('<option value="cgc">').html('CNPJ')).append(
                        jQuery('<option value="cidade">').html('Cidade')).append(
                        jQuery('<option value="uf">').html('Uf'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Destinatários');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar destinatários escolhidos');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./jspcadcliente.jsp?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarDestinatario', 'ClienteControlador!@!localizaClientesIframe');
            });
            break;
        case 'localizarFilial':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:100px;margin-left: 10px;" colunaEscolha="abreviatura" coluna="abreviatura">').html('Abreviatura')).append(
                        jQuery('<div class="topo-resultados-col2" style="width:250px;margin-left: 10px;" coluna="razaosocial">').html('Razão Social')).append(
                        jQuery('<div class="topo-resultados-col3" style="width:125px;margin-left: 10px;" coluna="cnpj">').html('CNPJ')).append(
                        jQuery('<div class="topo-resultados-col4" style="width:200px;margin-left: 10px;" coluna="cidade">').html('Cidade')).append(
                        jQuery('<div class="topo-resultados-col5" style="width:50px;margin-left: 10px;" coluna="uf">').html('UF'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="abreviatura">').html('Abreviatura')).append(
                        jQuery('<option value="razaosocial">').html('Razão Social')).append(
                        jQuery('<option value="cnpj">').html('CNPJ'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Filiais');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar filiais escolhidas');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./jspcadfilial.jsp?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarFilial', 'FilialControlador!@!localizar');
            });

            break;
        case 'localizarMotorista':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="idmotorista" coluna="idmotorista">').html('idmotorista')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:50px;margin-left: 10px;" coluna="codigomotorista">').html('Código')).append(
                        jQuery('<div class="topo-resultados-col2" style="width:250px;margin-left: 10px;" colunaEscolha="nome" coluna="nome">').html('Nome')).append(
                        jQuery('<div class="topo-resultados-col3" style="width:100px;margin-left: 10px;" coluna="cpf">').html('CPF')).append(
                        jQuery('<div class="topo-resultados-col4" style="width:100px;margin-left: 10px;" coluna="veiculo">').html('Veículo')).append(
                        jQuery('<div class="topo-resultados-col5" style="width:150px;margin-left: 10px;" coluna="vencimentocnh">').html('Vencimento CNH'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="id">').html('Código')).append(
                        jQuery('<option value="nome">').html('Nome')).append(
                        jQuery('<option value="cpf">').html('CPF')).append(
                        jQuery('<option value="cnh">').html('Nº CNH')).append(
                        jQuery('<option value="veiculo">').html('Veículo')).append(
                        jQuery('<option value="carreta">').html('Carreta')).append(
                        jQuery('<option value="bitrem">').html('Bi-Trem')).append(
                        jQuery('<option value="carreta3">').html('3º Reboque'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Motoristas');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar motoristas escolhidos');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./jspcadmotorista.jsp?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarMotorista', 'MotoristaControlador!@!localizar');
            });

            break;
        case 'localizarVendedor':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="idvendedor" coluna="idvendedor">').html('idvendedor')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:250px;margin-left: 10px;" colunaEscolha="razaosocial" coluna="razaosocial">').html('Nome')).append(
                        jQuery('<div class="topo-resultados-col2" style="width:150px;margin-left: 10px;" coluna="classe">').html('Classe'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="razaosocial">').html('Nome')).append(
                        jQuery('<option value="classe">').html('Classe'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Vendedores');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar vendedores escolhidos');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./cadfornecedor.jsp?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarVendedor', 'VendedorControlador!@!localizar');
            });

            break;
        case 'localizarSupervisor':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="idvendedor" coluna="idvendedor">').html('idvendedor')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:250px;margin-left: 10px;" colunaEscolha="razaosocial" coluna="razaosocial">').html('Nome')).append(
                        jQuery('<div class="topo-resultados-col2" style="width:150px;margin-left: 10px;" coluna="classe">').html('Classe'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="razaosocial">').html('Nome')).append(
                        jQuery('<option value="classe">').html('Classe'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Supervisores');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar supervisores escolhidos');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./cadfornecedor.jsp?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarSupervisor', 'VendedorControlador!@!localizar');
            });

            break;
        case 'localizarVeiculoGeral':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="idveiculo" coluna="idveiculo">').html('idveiculo')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:75px;margin-left: 10px;" colunaEscolha="placa" coluna="placa">').html('Placa')).append(
                        jQuery('<div class="topo-resultados-col2" style="width:75px;margin-left: 10px;" coluna="numeroFrota">').html('Nº Frota')).append(
                        jQuery('<div class="topo-resultados-col3" style="width:100px;margin-left: 10px;" coluna="tipoFrota">').html('Tipo Frota')).append(
                        jQuery('<div class="topo-resultados-col4" style="width:100px;margin-left: 10px;" coluna="tipo_veiculo">').html('Tipo Veículo')).append(
                        jQuery('<div class="topo-resultados-col5" style="width:100px;margin-left: 10px;" coluna="marcaRastreador">').html('Marca')).append(
                        jQuery('<div class="topo-resultados-col6" style="width:250px;margin-left: 10px;" coluna="proprietario">').html('Proprietário'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="placa">').html('Placa')).append(
                        jQuery('<option value="num_frota">').html('Nº Frota')).append(
                        jQuery('<option value="tipofrota">').html('Tipo Frota')).append(
                        jQuery('<option value="tipo">').html('Tipo Veículo')).append(
                        jQuery('<option value="marca">').html('Marca')).append(
                        jQuery('<option value="proprietario">').html('Proprietário'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Veículos');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar veículos escolhidos');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./cadveiculo?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });
            var tipoLocalizar = tipo.getTipo();
            if (tipoLocalizar == 'veiculo') {
                var select = jQuery('<select id="select-tipo">');
                var option = jQuery('<option value="ambos">').html('Mostrar veículos');
                select.append(option);
                var option = jQuery('<option value="tracao">').html('Do tipo tração');
                select.append(option);
                var option = jQuery('<option value="reboque">').html('Do tipo reboque');
                select.append(option);
            } else {
                var select = jQuery('<select id="select-tipo">');
                var option = jQuery('<option value="reboque">').html('Do tipo reboque');
                select.append(option);
            }

            if (!documentLocalizar.getElementById('select-tipo')) {
                jQuery(documentLocalizar.getElementsByClassName('filtro-especial')).append(select);
                jQuery(documentLocalizar.getElementsByClassName('btnLocalizar')).css({"margin-left": "10px", "max-width": "350px", "width": "350px", "float": "left"})
            }

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarVeiculoGeral', 'VeiculoControlador!@!localizarVeiculoGeral');
            });

//            if (jQuery('.nome-topo-localizar').html().trim() !== "Localizar Veículos Geral") {
//                console.log('a');
//                jQuery('#select-tipo').hide();
//                jQuery('.btnLocalizar').css({"margin-left": "170px", "max-width": "350px", "width": "350px", "float": "left"});
//            }

            break;
        case 'localizarVeiculo':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="idveiculo" coluna="idveiculo">').html('idveiculo')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:75px;margin-left: 10px;" colunaEscolha="placa" coluna="placa">').html('Placa')).append(
                        jQuery('<div class="topo-resultados-col2" style="width:75px;margin-left: 10px;" coluna="numeroFrota">').html('Nº Frota')).append(
                        jQuery('<div class="topo-resultados-col3" style="width:100px;margin-left: 10px;" coluna="tipoFrota">').html('Tipo Frota')).append(
                        jQuery('<div class="topo-resultados-col4" style="width:100px;margin-left: 10px;" coluna="tipo_veiculo">').html('Tipo Veículo')).append(
                        jQuery('<div class="topo-resultados-col5" style="width:100px;margin-left: 10px;" coluna="marcaRastreador">').html('Marca')).append(
                        jQuery('<div class="topo-resultados-col6" style="width:250px;margin-left: 10px;" coluna="proprietario">').html('Proprietário'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="placa">').html('Placa')).append(
                        jQuery('<option value="num_frota">').html('Nº Frota')).append(
                        jQuery('<option value="tipofrota">').html('Tipo Frota')).append(
                        jQuery('<option value="tipo">').html('Tipo Veículo')).append(
                        jQuery('<option value="marca">').html('Marca')).append(
                        jQuery('<option value="proprietario">').html('Proprietário'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Veículos');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar veículos escolhidos');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./cadveiculo?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarVeiculo', 'VeiculoControlador!@!localizarVeiculo');
            });

            break;
        case 'localizarCarreta':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="idveiculo" coluna="idveiculo">').html('idveiculo')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:75px;margin-left: 10px;" colunaEscolha="placa" coluna="placa">').html('Placa')).append(
                        jQuery('<div class="topo-resultados-col2" style="width:75px;margin-left: 10px;" coluna="numeroFrota">').html('Nº Frota')).append(
                        jQuery('<div class="topo-resultados-col3" style="width:100px;margin-left: 10px;" coluna="tipoFrota">').html('Tipo Frota')).append(
                        jQuery('<div class="topo-resultados-col4" style="width:100px;margin-left: 10px;" coluna="tipo_veiculo">').html('Tipo Veículo')).append(
                        jQuery('<div class="topo-resultados-col5" style="width:100px;margin-left: 10px;" coluna="marcaRastreador">').html('Marca')).append(
                        jQuery('<div class="topo-resultados-col6" style="width:250px;margin-left: 10px;" coluna="proprietario">').html('Proprietário'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="placa">').html('Placa')).append(
                        jQuery('<option value="num_frota">').html('Nº Frota')).append(
                        jQuery('<option value="tipofrota">').html('Tipo Frota')).append(
                        jQuery('<option value="tipo">').html('Tipo Veículo')).append(
                        jQuery('<option value="marca">').html('Marca')).append(
                        jQuery('<option value="proprietario">').html('Proprietário'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Carretas');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar carretas escolhidos');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./cadveiculo?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarCarreta', 'VeiculoControlador!@!localizarCarreta');
            });

            break;
        case 'localizarAerea':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="idfornecedor" coluna="idfornecedor">').html('idfornecedor')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:200px;margin-left: 10px;" colunaEscolha="razaosocial" coluna="razaosocial">').html('Razão Social')).append(
                        jQuery('<div class="topo-resultados-col2" style="width:200px;margin-left: 10px;" coluna="nomeFantasia">').html('Nome Fantasia')).append(
                        jQuery('<div class="topo-resultados-col3" style="width:100px;margin-left: 10px;" coluna="cpfCnpj">').html('CPF/CNPJ')).append(
                        jQuery('<div class="topo-resultados-col4" style="width:100px;margin-left: 10px;" coluna="cidade">').html('Cidade')).append(
                        jQuery('<div class="topo-resultados-col5" style="width:50px;margin-left: 10px;" coluna="uf">').html('UF'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="razaosocial">').html('Razão Social')).append(
                        jQuery('<option value="nomefantasia">').html('Nome Fantasia')).append(
                        jQuery('<option value="cpf_cnpj">').html('CPF/CNPJ')).append(
                        jQuery('<option value="cidade">').html('Cidade')).append(
                        jQuery('<option value="uf">').html('UF'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Companhias Aéreas');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar companhias aéreas escolhidos');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./cadfornecedor.jsp?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarAerea', 'FornecedorControlador!@!localizarAerea');
            });
            break;
        case 'localizarRedespachante':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="idfornecedor" coluna="idfornecedor">').html('idfornecedor')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:200px;margin-left: 10px;" colunaEscolha="razaosocial" coluna="razaosocial">').html('Razão Social')).append(
                        jQuery('<div class="topo-resultados-col2" style="width:200px;margin-left: 10px;" coluna="nomeFantasia">').html('Nome Fantasia')).append(
                        jQuery('<div class="topo-resultados-col3" style="width:100px;margin-left: 10px;" coluna="cpfCnpj">').html('CPF/CNPJ')).append(
                        jQuery('<div class="topo-resultados-col4" style="width:100px;margin-left: 10px;" coluna="cidade">').html('Cidade')).append(
                        jQuery('<div class="topo-resultados-col5" style="width:50px;margin-left: 10px;" coluna="uf">').html('UF'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="razaosocial">').html('Razão Social')).append(
                        jQuery('<option value="nomefantasia">').html('Nome Fantasia')).append(
                        jQuery('<option value="cpf_cnpj">').html('CPF/CNPJ')).append(
                        jQuery('<option value="cidade">').html('Cidade')).append(
                        jQuery('<option value="uf">').html('UF'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Redespachantes');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar redespachantes escolhidos');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./cadfornecedor.jsp?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarRedespachante', 'FornecedorControlador!@!localizarRedespachante');
            });
            break;
        case 'localizarAeroOrigem':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:200px;margin-left: 10px;" colunaEscolha="nome" coluna="nome">').html('Nome')).append(
                        jQuery('<div class="topo-resultados-col2" style="width:200px;margin-left: 10px;" coluna="iata">').html('IATA')).append(
                        jQuery('<div class="topo-resultados-col4" style="width:100px;margin-left: 10px;" coluna="cidade">').html('Cidade')).append(
                        jQuery('<div class="topo-resultados-col5" style="width:50px;margin-left: 10px;" coluna="uf">').html('UF'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="nome">').html('Nome')).append(
                        jQuery('<option value="iata">').html('IATA')).append(
                        jQuery('<option value="cidade">').html('Cidade')).append(
                        jQuery('<option value="uf">').html('UF'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Aeroporto Origem');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar aeroportos escolhidos');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./AeroportoControlador?acao=novoCadastro', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarAeroOrigem', 'AeroportoControlador!@!localizar');
            });
            break;
        case 'localizarAeroDestino':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:200px;margin-left: 10px;" colunaEscolha="nome" coluna="nome">').html('Nome')).append(
                        jQuery('<div class="topo-resultados-col2" style="width:200px;margin-left: 10px;" coluna="iata">').html('IATA')).append(
                        jQuery('<div class="topo-resultados-col4" style="width:100px;margin-left: 10px;" coluna="cidade">').html('Cidade')).append(
                        jQuery('<div class="topo-resultados-col5" style="width:50px;margin-left: 10px;" coluna="uf">').html('UF'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="nome">').html('Nome')).append(
                        jQuery('<option value="iata">').html('IATA')).append(
                        jQuery('<option value="cidade">').html('Cidade')).append(
                        jQuery('<option value="uf">').html('UF'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Aeroporto Destino');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar aeroportos escolhidos');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./AeroportoControlador?acao=novoCadastro', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarAeroDestino', 'AeroportoControlador!@!localizar');
            });
            break;
        case 'localizarRota':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:150px;margin-left: 10px;" colunaEscolha="descricao" coluna="descricao">').html('Descricao')).append(
                        jQuery('<div class="topo-resultados-col2" style="width:200px;margin-left: 10px;" coluna="cidade_origem">').html('Cidade Origem')).append(
                        jQuery('<div class="topo-resultados-col4" style="width:50px;margin-left: 10px;" coluna="uf_origem">').html('UF Origem')).append(
                        jQuery('<div class="topo-resultados-col4" style="width:200px;margin-left: 10px;" coluna="cidade_destino">').html('Cidade Destino')).append(
                        jQuery('<div class="topo-resultados-col5" style="width:50px;margin-left: 10px;" coluna="uf_destino">').html('UF Destino'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="descricao">').html('Descricao')).append(
                        jQuery('<option value="cidade_origem">').html('Cidade Origem')).append(
                        jQuery('<option value="uf_origem">').html('UF Origem')).append(
                        jQuery('<option value="cidade_destino">').html('Cidade Destino')).append(
                        jQuery('<option value="uf_destino">').html('UF Destino'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Rotas');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar rotas escolhidas');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./cadrota.jsp?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarRota', 'RotaControlador!@!localizar');
            });
            break;
        case 'localizarCidade':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:600px;margin-left: 10px;" colunaEscolha="cidade" coluna="cidade">').html('Cidade')).append(
                        jQuery('<div class="topo-resultados-col2" style="width:130px;margin-left: 10px;" coluna="uf">').html('UF'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="cidade">').html('Cidade')).append(
                        jQuery('<option value="uf">').html('UF'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Cidades');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar cidades escolhidas');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./cadcidade?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarCidade', 'CidadeControlador!@!localizar');
            });
            break;
        case 'localizarCidadeDestino':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:600px;margin-left: 10px;" colunaEscolha="cidade" coluna="cidade">').html('Cidade')).append(
                        jQuery('<div class="topo-resultados-col2" style="width:130px;margin-left: 10px;" coluna="uf">').html('UF'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="cidade">').html('Cidade')).append(
                        jQuery('<option value="uf">').html('UF'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Cidades de Destino');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar cidades escolhidas');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./cadcidade?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarCidadeDestino', 'CidadeControlador!@!localizar');
            });
            break;
        case 'localizarArea':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:500px;margin-left: 10px;" colunaEscolha="sigla" coluna="sigla">').html('Sigla')).append(
                        jQuery('<div class="topo-resultados-col2" style="width:200px;margin-left: 10px;" coluna="Descrição">').html('Descrição'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="sigla">').html('Sigla')).append(
                        jQuery('<option value="descricao">').html('Descrição'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Áreas');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar áreas escolhidas');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./cadarea.jsp?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarArea', 'AreaControlador!@!localizar');
            });
            break;
        case 'localizarTipoProduto':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:auto;margin-left: 10px;" colunaEscolha="descricao" coluna="Descrição">').html('Descrição'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="descricao">').html('Descrição'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Tipos de produtos');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar tipos de produtos escolhidos');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./cadtipoproduto.jsp?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarTipoProduto', 'TipoProdutoControlador!@!localizar');
            });
            break;
        case 'localizarProprietario':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:200px;margin-left: 10px;" colunaEscolha="nome" coluna="nome">').html('Nome')).append(
                        jQuery('<div class="topo-resultados-col2" style="width:200px;margin-left: 10px;" coluna="cnpj_cpf">').html('CNPJ/CPF')).append(
                        jQuery('<div class="topo-resultados-col3" style="width:150px;margin-left: 10px;" coluna="cidade">').html('Cidade')).append(
                        jQuery('<div class="topo-resultados-col4" style="width:20px;margin-left: 10px;" coluna="uf">').html('UF'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="nome">').html('Nome')).append(
                        jQuery('<option value="cnpj_cpf">').html('CNPJ/CPF'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Proprietários');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar proprietários escolhidos');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./cadfornecedor.jsp?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });


            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarProprietario', 'FornecedorControlador!@!localizarProprietario');
            });
            break;
        case 'localizarMarca':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:auto;margin-left: 10px;" colunaEscolha="descricao" coluna="Descrição">').html('Descrição'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="descricao">').html('Descrição'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Marcas');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar marcas escolhidos');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./cadmarca?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarMarca', 'MarcaControlador!@!localizar');
            });
            break;
        case 'localizarTipoVeiculo':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:auto;margin-left: 10px;" colunaEscolha="descricao" coluna="Descrição">').html('Descrição'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="descricao">').html('Descrição'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Tipos de Veículo');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar tipos de veículo escolhidos');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./cadtipo_veiculos.jsp?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarTipoVeiculo', 'TipoVeiculoControlador!@!localizar');
            });
            break;
        case 'localizarGrupoUsuario':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:auto;margin-left: 10px;" colunaEscolha="descricao" coluna="Descrição">').html('Descrição'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="descricao">').html('Descrição'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Grupos de Usuários');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar grupos de usuários escolhidos');

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarGrupoUsuario', 'GrupoUsuControlador!@!localizar');
            });
            break;
        case 'localizarFilialDestino':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id')).append(
                        jQuery('<div class="topo-resultados-col1" style="width:100px;margin-left: 10px;" colunaEscolha="abreviatura" coluna="abreviatura">').html('Abreviatura')).append(
                        jQuery('<div class="topo-resultados-col2" style="width:250px;margin-left: 10px;" coluna="razaosocial">').html('Razão Social')).append(
                        jQuery('<div class="topo-resultados-col3" style="width:125px;margin-left: 10px;" coluna="cnpj">').html('CNPJ')).append(
                        jQuery('<div class="topo-resultados-col4" style="width:200px;margin-left: 10px;" coluna="cidade">').html('Cidade')).append(
                        jQuery('<div class="topo-resultados-col5" style="width:50px;margin-left: 10px;" coluna="uf">').html('UF'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="abreviatura">').html('Abreviatura')).append(
                        jQuery('<option value="razaosocial">').html('Razão Social')).append(
                        jQuery('<option value="cnpj">').html('CNPJ'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Filiais');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar filiais escolhidas');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./jspcadfilial.jsp?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarFilialDestino', 'FilialControlador!@!localizar');
            });
            break;
        case 'localizarTabelaPreco':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                        jQuery('<div class="topo-resultados-col" style="display:none;" colunaInput="idtabela" coluna="idtabela">').html('idtabela')).append(
                        jQuery('<div class="topo-resultados-col" style="width:50px;margin-left: 10px;" colunaEscolha="codigo" coluna="codigo">').html('Código')).append(
                        jQuery('<div class="topo-resultados-col" style="width:100px;margin-left: 10px;" coluna="cliente">').html('Cliente')).append(
                        jQuery('<div class="topo-resultados-col" style="width:100px;margin-left: 10px;" coluna="origem">').html('Origem')).append(
                        jQuery('<div class="topo-resultados-col" style="width:100px;margin-left: 10px;" coluna="destino">').html('Destino')).append(
                        jQuery('<div class="topo-resultados-col" style="width:110px;margin-left: 10px;" coluna="tipoProduto">').html('Tipo Produto')).append(
                        jQuery('<div class="topo-resultados-col" style="width:50px;margin-left: 10px;" coluna="valorFrete">').html('Frete/kg')).append(
                        jQuery('<div class="topo-resultados-col" style="width:40px;margin-left: 10px;" coluna="porcentagemNF">').html('% NF')).append(
                        jQuery('<div class="topo-resultados-col" style="width:50px;margin-left: 10px;" coluna="seguro">').html('Seguro')).append(
                        jQuery('<div class="topo-resultados-col" style="width:80px;margin-left: 10px;" coluna="taxaFixa">').html('Taxa Fixa')).append(
                        jQuery('<div class="topo-resultados-col" style="width:50px;margin-left: 10px;" coluna="outros">').html('Outros')).append(
                        jQuery('<div class="topo-resultados-col" style="width:120px;margin-left: 10px;" coluna="freteMinimo">').html('Frete Mínimo'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                        jQuery('<option value="codigo">').html('Código')).append(
                        jQuery('<option value="origem">').html('Origem')).append(
                        jQuery('<option value="destino">').html('Destino')).append(
                        jQuery('<option value="tipoProduto">').html('Tipo Produto'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Tabela de Preço');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar tabelas de preços escolhidos');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open('./cadtabela_preco.jsp?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarTabelaPreco', 'TabelaPrecoControlador!@!localizar');
            });

            break;
        case 'localizarPlanoCusto':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo'))
                        .append(jQuery('<div class="topo-resultados-col" style="display:none;" colunaInput="id" coluna="id">').text('id'))
                        .append(jQuery('<div class="topo-resultados-col" style="width:100px;margin-left: 10px;" colunaEscolha="conta" coluna="conta">').text('Conta'))
                        .append(jQuery('<div class="topo-resultados-col" style="width:80%;margin-left: 10px;" coluna="descricao">').text('Descrição'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo'))
                        .append(jQuery('<option value="conta">').text('Conta'))
                        .append(jQuery('<option value="descricao">').text('Descrição'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).text('Localizar Plano de Custo');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar planos de custo escolhidos');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                window.open('./cadplanocusto?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarPlanoCusto', 'PlanoCustoControlador!@!localizar',sessionStorage.getItem('parametros'));
            });
            break
        case 'localizarProdutoRemetente':
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo'))
                        .append(jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').text('id'))
                        .append(jQuery('<div class="topo-resultados-col1" style="width:100px;margin-left: 10px;" colunaEscolha="codigo" coluna="codigo">').text('Código'))
                        .append(jQuery('<div class="topo-resultados-col2" style="width:150px;margin-left: 10px;" coluna="codigo_de_barras">').text('Cód de barras'))
                        .append(jQuery('<div class="topo-resultados-col3" style="width:350px;margin-left: 10px;" coluna="descricao">').text('Descrição'));
            }
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo'))
                        .append(jQuery('<option value="codigo">').text('Código'))
                        .append(jQuery('<option value="codigo_de_barras">').text('Cód. de barras'))
                        .append(jQuery('<option value="descricao">').text('Descrição'));
            }
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).text('Localizar Produtos');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar produtos escolhidos');

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarProdutoRemetente', 'ProdutoControlador!@!localizarProdutosRemetente', sessionStorage.getItem('parametros'));
            });
            break;
        case 'localizarRepresentante':
            jQuery(documentLocalizar).find('.envolve-topo,.envolve-resultados').css('width', '100%');
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo'))
                        .append(jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id'))
                        .append(jQuery('<div class="topo-resultados-col1" style="width:350px;margin-left: 10px;" colunaEscolha="nome" coluna="nome">').html('Nome'))
                        .append(jQuery('<div class="topo-resultados-col2" style="width:200px;margin-left: 10px;" coluna="cidade">').html('Cidade'))
                        .append(jQuery('<div class="topo-resultados-col3" style="width:100px;margin-left: 10px;" coluna="uf">').html('UF'));
            }
            
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo'))
                        .append(jQuery('<option value="nome">').html('Nome'))
                        .append(jQuery('<option value="cidade">').html('Cidade'))
                        .append(jQuery('<option value="uf">').html('Uf'));
            }
            
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Representante');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar representantes escolhidos');

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarRepresentante', 'RepresentanteControlador!@!localizar');
            });
            break;
        case 'localizarOcorrencia':
            //Lembrando que o nome da coluna deve ser igual do obj json
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                    jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id')).append(
                    jQuery('<div class="topo-resultados-col1" style="width:50px;margin-left: 10px;" coluna="codigo">').html('Código')).append(
                    jQuery('<div class="topo-resultados-col2" style="width:500px;margin-left: 10px;" colunaEscolha="descricao" coluna="descricao">').html('Descrição'));
            }
            //Adicionando os values do select
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                    jQuery('<option value="codigo">').html('Código')).append(
                    jQuery('<option value="descricao">').html('Descrição'));
            }
            //Nome do localizar no topo
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Ocorrencias');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar Ocorrencias escolhidas');

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarOcorrencia', 'OcorrenciaControlador!@!localizarOcorrencia');
            });

            break;
        case 'localizarSetorEntrega':
            //Lembrando que o nome da coluna deve ser igual do obj json
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                    jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id')).append(
                    jQuery('<div class="topo-resultados-col1" style="width:500px;margin-left: 10px;" colunaEscolha="descricao" coluna="descricao">').html('Descrição'));
            }
            //Adicionando os values do select
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                    jQuery('<option value="descricao">').html('Descrição'));
            }
            //Nome do localizar no topo
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Setor de Entrega');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar setores de entrega escolhidos');

            //Link para novo Cadastro
            jQuery(documentLocalizar.getElementsByClassName('novo-cadastro')).click(function () {
                javascript:window.open(homePath + '/SetorEntregaControlador?acao=novoCadastro', '', 'top=80,resizable=yes,status=1,scrollbars=1');
            });

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarSetorEntrega', 'SetorEntregaControlador!@!localizarSetorEntrega');
            });

            break;
        case 'localizarOrcamentacao':
            //Lembrando que o nome da coluna deve ser igual do obj json
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                    jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id')).append(
                    jQuery('<div class="topo-resultados-col1" style="width:100px;margin-left: 10px;" colunaEscolha="competencia" coluna="competencia">').html('Competência')).append(
                    jQuery('<div class="topo-resultados-col2" style="width:500px;margin-left: 10px;" coluna="filial">').html('Filial'));
            }
            //Adicionando os values do select
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                    jQuery('<option value="competencia">').html('Competência')).append(
                    jQuery('<option value="abreviatura">').html('Filial'));
            }
            //Nome do localizar no topo
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Orçamentações');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar Orçamentação escolhida');

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarOrcamentacao', 'OrcamentacaoControlador!@!localizarOrcamentacao');
            });

            break;
        case 'localizarServico':
            //Lembrando que o nome da coluna deve ser igual do obj json
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                    jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id')).append(
                    jQuery('<div class="topo-resultados-col1" style="width:500px;margin-left: 10px;" colunaEscolha="descricao" coluna="descricao">').html('Descrição')).append(
                    jQuery('<div class="topo-resultados-col2" style="width:100px;margin-left: 10px;" coluna="percentual_iss">').html('% ISS'));
            }
            //Adicionando os values do select
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                    jQuery('<option value="descricao">').html('Descrição'));
            }
            //Nome do localizar no topo
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Serviços');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar Serviço(s) escolhidos');

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarServico', 'ServicoControlador!@!localizarServico');
            });

            break;
            
        case 'localizarTipoPallet':
            //Lembrando que o nome da coluna deve ser igual do obj json
            if (jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).is(':empty')) {
                jQuery(documentLocalizar.getElementsByClassName('envolve-topo')).append(
                    jQuery('<div class="topo-resultados-col0" style="display:none;" colunaInput="id" coluna="id">').html('id')).append(
                    jQuery('<div class="topo-resultados-col1" style="width:500px;margin-left: 10px;" colunaEscolha="descricao" coluna="descricao">').html('Descrição')).append(
                    jQuery('<div class="topo-resultados-col2" style="width:100px;margin-left: 10px;" coluna="area">').html('Área'));
            }
            //Adicionando os values do select
            if (jQuery(documentLocalizar.getElementById('select-campo')).is(':empty')) {
                jQuery(documentLocalizar.getElementById('select-campo')).append(
                    jQuery('<option value="descricao">').html('Descrição'));
            }
            //Nome do localizar no topo
            jQuery(documentLocalizar.getElementsByClassName('nome-topo-localizar')).html('Localizar Tipos de Pallets');
            jQuery(documentLocalizar).find('.okButton').val('Selecionar Tipos de Pallets(s) escolhidos');

            jQuery(documentLocalizar.getElementById('search')).click(function () {
                jQuery(documentLocalizar).find('#topo-resultados-col1').html('');
                controlador.acao('localizar', 'localizarTipoPallet', 'TipoPalletControlador!@!localizarTipoPallet');
            });

            break;
    }
    jQuery(documentLocalizar).find('.fechar').click(function () {
        controlador.acao('fechar', localizar);
    });

    //removendo parametros do session
//    sessionStorage.removeItem('parametros');
}

function enviarSelecionados(localizar) {
    var docEl = document.getElementById(localizar).contentWindow.document;
    var lisEscolhidos = jQuery(docEl).find('#topo-resultados-col2 li');

    if (lisEscolhidos.size() <= 0) {
        chamarAlert('Escolha ao menos um resultado.');

        return;
    }

    localizar = jQuery('#' + localizar);
    var input = localizar.attr('input');
    
    if (typeof window[input] === 'function') {
        jQuery(lisEscolhidos).each(function forListaLocalizar(index, elementoEscolhido) {
            var obj_envio = {};
            jQuery.each(jQuery(elementoEscolhido).find('*'), function (index, element) {
                var e = jQuery(element);
                var name = (e.attr('class') ? e.attr('class') : e.attr('id'));
                if (e.is('div')) {
                    obj_envio[name] = e.text();
                } else if (e.is('input')) {
                    obj_envio[name] = e.val();
                }
            });
            window[input](obj_envio);
        });
    } else if (typeof input === 'string') {
        removerValorInput(input);
        jQuery.each(lisEscolhidos, function (key, value) {
            var vl = popularOnClick(value);
            addValorAlphaInput(input, vl.split("!@!")[0], vl.split('!@!')[1]);
        });
    }

    fecharLocalizar(localizar);
}


/*Funcoes gerais*/
function podeEscolher(docEl, clone) {
    var i = 0;
    while (jQuery(docEl).find('#topo-resultados-col2').find('li')[i]) {
        if (jQuery(jQuery(docEl).find('#topo-resultados-col2').find('li')[i]).find('input[type=hidden]').val() === jQuery(clone).find('input[type=hidden]').val()) {
            chamarAlert('A filial "' + jQuery(jQuery(docEl).find('#topo-resultados-col2').find('li')[i]).find('.razaosocial').html() + '" já foi selecionada.');
            return false;
        }
        i++;
    }
    return true;
}

function marcarItemAdicionar(e) {
    var elemento = jQuery(e);
    var div = elemento.find('div')[0];
    if (elemento.hasClass('selecionado')) {
        elemento.removeClass('selecionado');
        jQuery(div).find('img').remove();
    } else {
        elemento.addClass('selecionado');
        if (jQuery(div).find('img')[0] === undefined) {
            jQuery(div).append('<img src="' + homePath + '/assets/img/certo.png" width="15px" style="float: left; margin-right: 5px;">');
        }
    }
}

function marcarItemRemover(e) {
    var elemento = jQuery(e);
    elemento.removeClass('selecionado');
    var div = elemento.find('div')[0];
    if (elemento.hasClass('remover-selecionado')) {
        elemento.removeClass('remover-selecionado');
        jQuery(div).find('img').remove();
    } else {
        elemento.addClass('remover-selecionado');
        if (jQuery(div).find('img')[0] === undefined) {
            jQuery(div).append('<img src="' + homePath + '/assets/img/certo.png" width="15px" style="float: left; margin-right: 5px;">');
        }
    }
}

function popularPaginacao(paginacao, docLocalizar, localizar, controlador, acao, paramPersonalizado) {
    var paginas = parseInt(paginacao.paginas);
    jQuery(docLocalizar).find('#span-total-paginas').html('de ' + paginas);
    jQuery(docLocalizar).find('#pagina').val(paginacao.paginaAtual);

    jQuery(docLocalizar).find('#paginaAtual').val(paginacao.paginaAtual);
    jQuery(docLocalizar).find('#totalPaginas').val(paginas);

    if (paginacao.paginaAtual > 1) {
        jQuery(docLocalizar).find('#anterior').prop('href', "javascript:parent.controlador.acao('localizar','" + localizar + "','" + controlador + "!@!" + acao + "!@!anterior', '" + paramPersonalizado + "');");
        jQuery(docLocalizar).find('#anterior').prop('class', 'l-btn l-btn-small l-btn-plain l-btn l-btn-plain');
    } else {
        jQuery(docLocalizar).find('#anterior').prop('href', 'javascript:;');
        jQuery(docLocalizar).find('#anterior').prop('class', 'l-btn l-btn-small l-btn-plain l-btn-disabled l-btn-plain-disabled');
    }

    if (paginas >= 1 && paginacao.paginaAtual < paginas) {
        jQuery(docLocalizar).find('#proxima').prop('href', "javascript:parent.controlador.acao('localizar','" + localizar + "','" + controlador + "!@!" + acao + "!@!proximo', '" + paramPersonalizado + "');");
        jQuery(docLocalizar).find('#proxima').prop('class', 'l-btn l-btn-small l-btn-plain l-btn l-btn-plain');
    } else {
        jQuery(docLocalizar).find('#proxima').prop('href', 'javascript:;');
        jQuery(docLocalizar).find('#proxima').prop('class', 'l-btn l-btn-small l-btn-plain l-btn-disabled l-btn-plain-disabled');
    }
}

function trim(str) {
    return str.replace(/^\s+|\s+$/g, "");
}

function getInputLocalizar(idLocalizar) {
    switch (localizar[0].id) {
        case 'localizarCliente':
            return '';
            break;
    }
}

function popularOnClick(element) {
    var col = jQuery(element).parents(document).find('[colunaEscolha]').attr('colunaEscolha');
    // return jQuery(element).find('.' + col).text() + "!@!" + jQuery(element).find('input[name="inputId"]').val();
    return jQuery(element).find('div[class="' + col + '"]').text() + "!@!" + jQuery(element).find('input[name="inputId"]').val();
}

function ativarClickOpcoesAvancadasFalse(li, localizar, doc) {
    var input = localizar.attr('input');
    jQuery(li).attr('onclick', "parent.clickOpAvanFalse(this," + "'" + input + "'" + "," + "'" + localizar[0].id + "')");
}

function getTextColuna(element, classe) {
    return jQuery(element).find('.' + classe).text();
}

function clickOpAvanFalse(li, input, idLocalizar) {
    var vl = popularOnClick(li);
    //Tentando chamar o parametro "input" 
    try {
        var fun = eval(input);
        if (typeof fun === 'function') {
            var obj_envio = {};
            jQuery.each(jQuery(li).find('*'), function (index, element) {
                var e = jQuery(element);
                var name = (e.attr('class') ? e.attr('class') : e.attr('id'));
                if (e.is('div')) {
                    obj_envio[name] = e.text();
                } else if (e.is('input')) {
                    obj_envio[name] = e.val();
                }
            });
            fun(obj_envio);
            fecharLocalizar(idLocalizar);
            controlador.acao('limparLocalizar', idLocalizar);
        } else {
            throw 'No function';
        }
    } catch (ex) {
        /**
         * @deprecated Precisa ser removido em futuras versões observando onde é utilizada.
         * O autor foi João Carlos
         * Não recomendo utilizar essa parte do código.
         * Ass: Mateus
         */
        if (input.split(',').length > 1) {
            var arrayInputs = input.split(',');
            arrayInputs.forEach(function (element, index, array) {
                if (index === 0) {
                    removerValorInput(element.split(':')[0]);
                    addValorAlphaInput(element.split(':')[0], vl.split("!@!")[0], vl.split('!@!')[1]);
                } else {
                    jQuery('#' + element.split(':')[0]).val('');
                    jQuery('#' + element.split(':')[0]).val(getTextColuna(li, element.split(':')[1]));
                }
            });

            fecharLocalizar(idLocalizar);
            controlador.acao('limparLocalizar', idLocalizar);
        } else {
            removerValorInput(jQuery('#' + idLocalizar).attr('input'));
            addValorAlphaInput(input, vl.split("!@!")[0], vl.split('!@!')[1]);
            fecharLocalizar(idLocalizar);
            controlador.acao('limparLocalizar', idLocalizar);
        }
    }
}

function ativarClickOpcoesAvancadasTrue(li, doc) {
    jQuery(li).attr('onclick', 'parent.clickOpAvanTrue(this)');
}

function clickOpAvanTrue(li) {
    marcarItemAdicionar(li);
}

function limparLocalizar(e) {
    if (typeof e === 'object') {
        e = jQuery(e).attr('id');
    } else if (typeof e === 'string' && e.indexOf('#') === -1) {
        e = e.replace('#', '');
    } else {
        return null;
    }

    let doc = document.getElementById(e).contentWindow.document;

    jQuery(doc).find('#topo-resultados-col1').html('');
    jQuery(doc).find('#topo-resultados-col2').html('');
}
