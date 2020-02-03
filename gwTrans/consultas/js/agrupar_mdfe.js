/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */



function carregarJaAgrupados(id, homepath) {
    jQuery.ajax({
        url: homepath + '/ManifestoControlador',
        type: 'POST',
        data: {
            acao: 'carregarJaAgrupados',
            ids: id
        },
        success: function (data, textStatus, jqXHR) {
            jacarregado(data, id);
        },
        error: function (jqXHR, textStatus, errorThrown) {
            chamarAlert("não foi possivel ter conexão com o Servidor.");
        }
    });
}

function jacarregado(listaJaAgrupados, pai) {
    if (!validarParent()) {
        chamarAlert("Atenção: ocorreu um erro, recarregue a tela. Caso volte a acontecer entre em contato com o suporte");
        return false;
    }
    var lista = window.parent.manifestosMarcados();
    var array = listaJaAgrupados.split("$#$");
    var ids = "";
    var tr = "<tr class='comHover'>";
    var td = "<td>";
    var input = "<input type='radio' name='pai'>";
    var label = "<label>";
    var body = jQuery("<tbody>");

    jQuery.each(array, function (index, val) {
        if (val && val !== "\n") {
            var atual = val.split("!!");
            ids = ids + "," + atual[0];
            var valor = jQuery(input).attr('id', 'pai'+atual[0]).attr('disabled', true);
            var tdValor = jQuery(td).append(valor);
            var trGeral = jQuery(tr).append(tdValor);
            var texto = jQuery(label).text(atual[1]);
            var tdTexto = jQuery(td).append(texto);
            jQuery(trGeral).append(tdTexto);
            
            texto = jQuery(label).text(atual[2]);
            tdTexto = jQuery(td).append(texto);
            jQuery(trGeral).append(tdTexto);
            texto = jQuery(label).text(atual[3]);
            tdTexto = jQuery(td).append(texto);
            jQuery(trGeral).append(tdTexto);
            texto = jQuery(label).text(atual[4]);
            tdTexto = jQuery(td).append(texto);
            jQuery(trGeral).append(tdTexto);
            texto = jQuery(label).text("Agrupado");
            tdTexto = jQuery(td).append(texto);
            jQuery(trGeral).append(tdTexto);
            body.append(trGeral);
            
        }
    });
    
    array = lista.split("@#$");
    jQuery.each(array, function (index, val) {
        if (val) {
            var atual = val.split("!!");
            if (ids.indexOf(atual[0]) !== -1) {
                return true;
            }
            ids = ids + "," + atual[0];
            if (pai !== atual[0]) {
                ids = ids + "," + atual[0];
            }

            var valor = jQuery(input).attr('id', 'pai'+atual[0]);
            if (pai === atual[0]) {
                valor.attr('checked', true);
            }
            if (pai !== "") {
                valor.attr('disabled', true);
            }
            var tdValor = jQuery(td).append(valor);
            var trGeral = jQuery(tr).append(tdValor);
            var texto = jQuery(label).text(atual[1]);
            var tdTexto = jQuery(td).append(texto);
            jQuery(trGeral).append(tdTexto);

            texto = jQuery(label).text(converterDataBancoParaBR(atual[2]));
            tdTexto = jQuery(td).append(texto);
            jQuery(trGeral).append(tdTexto);
            texto = jQuery(label).text(atual[3]);
            tdTexto = jQuery(td).append(texto);
            jQuery(trGeral).append(tdTexto);
            texto = jQuery(label).text(atual[4]+"/"+atual[5]);
            tdTexto = jQuery(td).append(texto);
            jQuery(trGeral).append(tdTexto);
            var principalNovo = "";
            if (pai && pai === atual[0]) {
                principalNovo = "Principal";
            }else{
                principalNovo = "Novo";
            }
            texto = jQuery(label).text(principalNovo);
            tdTexto = jQuery(td).append(texto);
            jQuery(trGeral).append(tdTexto);
            body.append(trGeral);
        }
        
    });
    jQuery("#tabelaManifestos").append(body);
}

function cancelar() {
    if (!validarParent()) {
        chamarAlert("Atenção: ocorreu um erro, recarregue a tela. Caso volte a acontecer entre em contato com o suporte");
        return false;
    }
    window.parent.cancelarAgrupamento();
}

function pegaID(pegaPai) {
    var valor = "";
    jQuery("input[id^='pai']").each(function () {
        if (jQuery(this).is(':checked') && pegaPai) {
            valor = jQuery(this).prop('id').substring(3);
        } else if (jQuery(this).is(':checked') == false && pegaPai == false) {
            valor = valor + "," + jQuery(this).prop('id').substring(3);
        }
    });
    if (!pegaPai) {
        valor = valor.substring(1);
    }
    return valor;
}

function confirmar() {
    var idPai = pegaID(true);
    if (idPai === '') {
        chamarAlert("Selecione o manifesto principal.");
        return false;
    }
    var idFilhos = pegaID(false);
    if (!validarParent()) {
        chamarAlert("Atenção: ocorreu um erro, recarregue a tela. Caso volte a acontecer entre em contato com o suporte");
        return false;
    }
    window.parent.confirmarAgrupamento(idFilhos, idPai);
}

jQuery(document).ready(function () {
    jQuery(".fechar").on("click", cancelar);
    jQuery("#buttonConfirma").on("click", confirmar);
});

function validarParent(){
    return window.parent;
} 