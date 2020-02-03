jQuery(document).ready(function () {
    
});

function ocultarColumn(element) {
    var index = jQuery(jQuery(element).parents('th')).index() + 1;
    jQuery('.tabela-gwsistemas').children().find('> tr > th:nth-child(' + index + ')').attr('oculta', 'true');
    jQuery('.tabela-gwsistemas').children().find('> tr > td:nth-child(' + index + ')').hide('show');
    jQuery('.tabela-gwsistemas').children().find('> tr > th:nth-child(' + index + ')').hide('show');
}

function ordenar(elemento) {
    jQuery(jQuery(elemento).parents('th')[0]).trigger('click');
}

function redefinirColunas() {
    jQuery.ajax({
        url: 'ConsultaControlador',
        type: 'POST',
        async: false,
        data: {
            acao: 'redefinirColunas',
            codigoTela: codTela
        },
        success: function (data, textStatus, jqXHR) {
            location.reload();
        },
        error: function (jqXHR, textStatus, errorThrown) {
            chamarAlert('Ocorreu um erro ao tentar redefinir as colunas.');
        }
    });
}



function getColumnValue(nome) {
    var valorRetorno = '';
    var listaJson = jQuery.parseJSON(resultList);
    var index = 0;
    while (listaJson.resultList.rows[0].resultRow[index]) {
        var i = 0;
        while (listaJson.resultList.rows[0].resultRow[index].columns[0].resultCol[i] != undefined) {
            if (listaJson.resultList.rows[0].resultRow[index].columns[0].resultCol[i].nome == nome) {
                if (listaJson.resultList.rows[0].resultRow[index].columns[0].resultCol[i].valor) {
                    valorRetorno += listaJson.resultList.rows[0].resultRow[index].columns[0].resultCol[i].valor.$ + '!#!';
                }
            }
            i++;
        }
        index++;
    }

    return valorRetorno;
}

function adicionarColuna(nomeColuna, labelColuna, elemento) {
    var posicaoColuna = jQuery(jQuery(elemento).parents()[1])[0].cellIndex;
    var i = 0;
    while (jQuery('#tabela-gwsistemas thead tr th .nome-coluna')[i] != undefined) {
        if (jQuery(jQuery('#tabela-gwsistemas thead tr th .nome-coluna')[i]).html() == labelColuna) {
            chamarAlert('A coluna já existe na tabela.');
            return false;
        }
        i++;
    }
    var tr = jQuery('<th style="min-width: 180px;width:180px;" class="pode-setar-ordem" nome="' + nomeColuna.toUpperCase() + '">');
    var label = jQuery('<label class="nome-coluna">').append(labelColuna);
    tr.append(label);
    var img = jQuery('<img src="img/th-menu.png">');
    tr.append(img);

    jQuery('#tabela-gwsistemas thead tr th:eq(' + posicaoColuna + ')').after(tr);
    var i = 0;
    while (jQuery('#tabela-gwsistemas tbody tr')[i] != undefined) {
        var colunas = getColumnValue(nomeColuna);

        var td = jQuery('<td>').append(colunas.split('!#!')[i]);
        jQuery('#tabela-gwsistemas tbody tr:eq(' + i + ') td:eq(' + posicaoColuna + ')').after(td);
        i++;
    }

    var i = 0;
    while (jQuery('#tabela-gwsistemas thead tr .pode-setar-ordem')[i]) {
        var cellI = jQuery('#tabela-gwsistemas thead tr .pode-setar-ordem')[i].cellIndex - 1;
        jQuery(jQuery('#tabela-gwsistemas thead tr .pode-setar-ordem')[i]).attr('ordem', cellI);
        i++;
    }


    var i = 0;
    while (jQuery('.conteudo-colunas')[i] != undefined) {
        var ii = 0;
        while (jQuery(jQuery('.conteudo-colunas')[i]).find('label')[ii]) {


            ii++;
        }
        i++;
    }

}





jQuery('.menu-span-dropdown-content').on('click', function (event) {
    event.stopPropagation();
});


jQuery(document).ready(function () {
    
});

function trChecked(elemento, position) {
    var trSelecionadas = jQuery("input[type=checkbox][name*=nCheck]:checked");
    var removeCte = jQuery('#removeCte');
    var agruparMDFE = jQuery('#agruparMDFE');
    
    addRemoveClassTr(jQuery(jQuery(elemento).parents("tr")));

    if (trSelecionadas.size() > 0) {
        // Caso tenha pelo menos 1 checkbox marcados, ativar o botão removeCte
        removeCte.removeClass("removeCteOff").addClass("removeCteOn").prop('disabled', '');
        
        // Caso tenha pelo menos 2 checkbox marcados, ativar o botão agruparMDFE
        if (trSelecionadas.size() >= 2) {
            agruparMDFE.removeClass("agrupaMDFEOff").addClass("agrupaMDFEOn").prop('disabled', '');
        } else {
            agruparMDFE.removeClass("agrupaMDFEOn").addClass("agrupaMDFEOff").prop('disabled', 'true');
        }
    } else {
        // Desativar os botões
        removeCte.removeClass("removeCteOn").addClass("removeCteOff").prop('disabled', 'true');
        agruparMDFE.removeClass("agrupaMDFEOn").addClass("agrupaMDFEOff").prop('disabled', 'true');
    }
}

function addRemoveClassTr(elemento) {
    if (jQuery(jQuery(elemento).find("input[type=checkbox][name*=nCheck]")).is(':checked')) {
        jQuery(elemento).addClass("datagrid-row-checked").addClass("datagrid-row-selected");
    } else {
        jQuery(elemento).removeClass("datagrid-row-checked").removeClass("datagrid-row-selected");
    }

}

function marcarTodos(element) {
    if (element.checked) {
        jQuery("input[type=checkbox][name*=nCheck]").each(
                function (f, a) {
                    f = f + 1;
                    a.checked = true;
                    addRemoveClassTr(jQuery(jQuery(a).parents("tr")));
                    jQuery('#removeCte').removeClass("removeCteOff").addClass("removeCteOn");
                    jQuery('#agruparMDFE').removeClass("agrupaMDFEOff").addClass("agrupaMDFEOn");
                    jQuery('#removeCte').prop('disabled', '');
                    jQuery('#agruparMDFE').prop('disabled', '');
                });
    } else {
        jQuery("input[type=checkbox][name*=nCheck]").each(
                function (f, a) {
                    f = f + 1;
                    a.checked = false;
                    addRemoveClassTr(jQuery(jQuery(a).parents("tr")));
                    jQuery('#removeCte').removeClass("removeCteOn").addClass("removeCteOff");
                    jQuery('#agruparMDFE').removeClass("agrupaMDFEOn").addClass("agrupaMDFEOff");
                    jQuery('#removeCte').prop('disabled', 'true');
                    jQuery('#agruparMDFE').prop('disabled', 'true');
                });
    }
}

//Validar o caractere de pagina
function verificaCaracterePagina(element, paginas) {
    element.value = element.value.replace(/[^0-9,]/g, "");

    if (element.value != null && element.value != "" && parseFloat(element.value) > parseFloat(paginas)) {
        element.value = "";
        return true;
    }

    //nao enviar pagina caso seja 0 - já que 0 é menor
    // que a quantidade de paginas sempre e passa das validacoes acima
    if (element.value == "0" || element.value == 0) {
        element.value = "";
    }
}

function obterSales(id) {

    var retorno = '';

    jQuery.ajax({
        url: 'ColetaControlador',
        type: 'POST',
        async: false,
        data: {
            acao: 'obter_sales',
            idcoleta: id
        },
        success: function (data, textStatus, jqXHR) {
            retorno = data;
        },
        error: function (jqXHR, textStatus, errorThrown) {
            console.error(jqXHR);
        }
    });

    return retorno;
}

function visualizarCteNfe(elemento, position) {

    jQuery(jQuery('.container-sales')[0]).css('display', 'block');
    jQuery(jQuery('.container-sales')[0]).animate({'width': '350px'});

    var idSale = jQuery(jQuery(elemento).parents('tr')[0]).find('#hi_row_id_' + position).val();

    var r = obterSales(idSale).replace(/\n|\r/g, "");
    r = r.split('#@#');
    if (r[0] == undefined || r[0] == '') {
        chamarAlert('Não existe CT-e(s) ou NF-e(s) ligados a coleta.', null);
        return false;
    }

    if (jQuery(jQuery(elemento).parents('tr')[0]).next().hasClass('tr-cte-nfe')) {
        return false;
    }
    var colspan = jQuery(jQuery(elemento).parents('tr')[0]).find('td').length;


    var j = 0;
    while (r[j] != undefined) {
        if (r[j]) {

            var objCompleto = jQuery.parseJSON('{"' + (r[j].replace(/!@!/g, '","').replace(/:/g, '":"')) + '"}');
            colspan = parseInt(colspan) - 1;

            var newTR = jQuery('<tr class="tr-cte-nfe">');
            var newTD01 = jQuery('<td>');
            newTR.append(newTD01);
            var newTD02 = jQuery('<td colspan="' + colspan + '">');
            newTR.append(newTD02);

            var hidden = jQuery('<input type="hidden" name="id_sale" >').val(objCompleto.id_sale);
            newTD02.append(hidden);

            var div = jQuery('<div class="camposSales" id="doc_fiscal" >').html(objCompleto.doc_fiscal);
            newTD02.append(div);

            div = jQuery('<div class="camposSales" id="tipo">').html(objCompleto.tipo);
            newTD02.append(div);

            div = jQuery('<div class="camposSales" id="data-emissao" >').html(objCompleto.data_emissao);
            newTD02.append(div);

            div = jQuery('<div class="camposSales" id="remetente" title="' + objCompleto.remetente + '" >').html(objCompleto.remetente);
            newTD02.append(div);

            div = jQuery('<div class="camposSales" id="destinatario" title="' + objCompleto.destinatario + '">').html(objCompleto.destinatario);
            newTD02.append(div);

            var tr = jQuery(jQuery(elemento).parents('tr')[0]).after(newTR);

            tr.next().fadeToggle("slow", "linear");
        }
        j++;
    }
    //Inserindo a tr do cabeçalho

    var newTRTopo = jQuery('<tr class="tr-topo-cte-nfe">');
    var newTDTopo01 = jQuery('<td>');
    newTRTopo.append(newTDTopo01);
    var newTDTopo02 = jQuery('<td colspan="' + colspan + '">');
    newTRTopo.append(newTDTopo02);


    div = jQuery('<div class="doc_fiscal">').html('Número');
    newTDTopo02.append(div);

    div = jQuery('<div class="tipo">').html('Categoria');
    newTDTopo02.append(div);

    div = jQuery('<div class="data-emissao">').html('Emissão');
    newTDTopo02.append(div);

    div = jQuery('<div class="remetente">').html('Remetente');
    newTDTopo02.append(div);

    div = jQuery('<div class="destinatario">').html('Destinatário');
    newTDTopo02.append(div);

    jQuery(jQuery(elemento).parents('tr')[0]).after(newTRTopo);

    var i = 0;
    while (jQuery('.container-menu-coleta')[i] !== undefined) {
        if (jQuery(jQuery('.container-menu-coleta')[i]).css('display') == "block") {
            jQuery(jQuery('.container-menu-coleta')[i]).fadeToggle('fast');
        }
        i++;
    }

    jQuery(elemento).attr('onclick', 'ocultarCteNfe(this)');
    jQuery(elemento).find('span').html('Ocultar CT-e(s) / NFS-e(s)');

}

function ocultarCteNfe(elemento) {

    while (jQuery(jQuery(elemento).parents('tr')[0]).next().hasClass('tr-topo-cte-nfe')) {
        jQuery(jQuery(elemento).parents('tr')[0]).next().remove();
    }

    while (jQuery(jQuery(elemento).parents('tr')[0]).next().hasClass('tr-cte-nfe')) {
        jQuery(jQuery(elemento).parents('tr')[0]).next().remove();
    }

    var i = 0;
    while (jQuery('.container-menu-coleta')[i] !== undefined) {
        if (jQuery(jQuery('.container-menu-coleta')[i]).css('display') == "block") {
            jQuery(jQuery('.container-menu-coleta')[i]).fadeToggle('fast');
        }
        i++;
    }

    jQuery(elemento).attr('onclick', 'visualizarCteNfe(this)');
    jQuery(elemento).find('span').html('Visualizar CT-e(s) / NFS-e(s)');

}
