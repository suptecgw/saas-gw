jQuery(function () {
    jQuery('.fechar').on('click', function () {
        if (checkAlteracao()) {
            chamarConfirm('Existem alterações que não foram salvas e serão perdidas.<br>Deseja continuar?', "aceitarDescartarAlteracoes()");
        } else {
            aceitarDescartarAlteracoes();
        }
    });

    jQuery('#buttonConfirma').on('click', function () {
//                if (!enviaIEs()) {
//                    return false;
//                }
        var lista = enviarIEs();
        if (lista) {
            parent.recebeSubstitutas(lista);
            parent.esconderBloqTela();
            sessionStorage.clear();
            parent.fechaFrameSubstituta();
        } else {
            console.error('Erro na função enviarIEs');
        }
    });

    jQuery('.titulo-add').on('click', function () {
        addDom();
    });
});

/**
 * função a ser chamada pelo chamarConfirm quando o usuario escolher descartar as alterações.
 * @returns {undefined}
 */
function aceitarDescartarAlteracoes() {
    parent.esconderBloqTela();
    sessionStorage.clear();
    parent.fechaFrameSubstituta();
}

function pressionou(e) {
    var valor = e.value;
    var uf = jQuery(jQuery(jQuery(jQuery(jQuery(e).parents('tr')[0]).find('td')[1]).find('span')).find('span')[1]).html();
    sessionStorage.setItem(uf, valor);
}

function checkAlteracao() {
    var alterou = false;
    jQuery('[id^=trPrincipal]').each(function (index) {
        var uf = jQuery(this).find('#tdUf').find('#selectUf').val();
        var ie = jQuery(this).find('#tdIE').find('#inputIE').val();

        var storage = Object.assign({}, sessionStorage);
        if (storage[uf] && storage[uf] != ie) {
            alterou = true;
        }

    });
    return alterou;
}


function montaFrame() {
    if (parent.getSubstitutasFilial()) {
        var json = parent.getSubstitutasFilial();
        var list = JSON.parse(json).listaUf;
        jQuery.each(list, function (i, e) {
            addDom(e.uf, e.id, e.insc, e.isExcluido);
        });
    }
}

function addDom(uf, id, ie, isExcluido) {
    //Var principais
    var countDom = jQuery('.countTrDOM').size() + 1;

    var tbody = jQuery('#tbl-ie').find('tbody'),
            tr = jQuery('<tr>').attr('id', 'trPrincipal_' + countDom).attr('name', 'trPrincipal_' + countDom),
            td = null, selectUf = null, input = null, inputHidden = null, lixeira = null;
    //------TD VAZIA-------
    td = jQuery('<td>').addClass('TextoCampos padding-top-bottom td-vazia').html('&nbsp;');
    tr.append(td);
    //------TD UF-------
    td = jQuery('<td>').addClass('TextoCampos padding-top-bottom').attr('id', 'tdUf').attr('name', 'tdUf');
    selectUf = jQuery('<select>').addClass('inputtexto select-uf').attr('id', 'selectUf').attr('name', 'selectUf');
    //Populando Select UF
    popularSelect(selectUf);
    td.append(selectUf);
    tr.append(td);
    //------TD IE-------
    td = jQuery('<td>').addClass('TextoCampos padding-top-bottom').attr('id', 'tdIE').attr('name', 'tdIE');
    input = jQuery('<input>').addClass('input-form-gw').attr('maxlength', '12').attr('name', 'inputIE').attr('id', 'inputIE').attr('onkeydown', 'pressionou(this);').val(ie ? ie : '');
    inputHidden = jQuery('<input type="hidden">').attr('id', 'inputID').attr('name', 'inputID').val(id ? id : 0);
    td.append(input);
    td.append(inputHidden);
    tr.append(td);
    //------TD IE-------
    td = jQuery('<td>').addClass('TextoCampos padding-top-bottom');
    lixeira = jQuery('<img src="assets/img/icones/excluir.png">').addClass('imagemLink countTrDOM img-lixeira').attr('onclick', 'removeItemDom(' + countDom + ')');
    td.append(lixeira);
    tr.append(td);
    //adicionando a TR
    tbody.append(tr);
    //adicionando o TBODY
    //Adicionando o selectmenu
    jQuery(selectUf).selectmenu().selectmenu({width: '79px'}).selectmenu("option", "position", {my: "top+15", at: "top center"}).selectmenu("menuWidget").addClass("selects-ui").addClass("select");

    //Adicionando valores
    if (uf) {
        jQuery(selectUf).find('option[value=' + uf + ']').prop('selected', true);
        jQuery(selectUf).selectmenu("refresh");
    }
    if (isExcluido === 'true') {
        tr.hide();
        tr.attr('isExcluido', true);
    }
}

function popularSelect(select) {
    var opselecione = jQuery('<option value="">Selecione</option>');
    var ufs = ["AC", "AL", "AM", "AP", "BA", "CE", "DF", "ES", "MA", "MG", "MS", "MT", "PA", "PB", "PE", "PI", "PR", "RJ", "RN", "RO", "RR", "RS", "SC", "SE", "SP", "TO", "EX"];

    select.append(opselecione);
    jQuery.each(ufs, function (i, e) {
        var opt = jQuery("<option>").html(e).val(e);
        select.append(opt);
    });
}

function enviarIEs() {
    var jsonCompleto = {};
    var lista = new Array();
    var erro = null;
    jQuery('[name^=trPrincipal]').each(function (index) {
        var ie = {};
        ie["id"] = String(jQuery(this).find('#tdIE').find('#inputID').val());
        ie["insc"] = jQuery(this).find('#tdIE').find('#inputIE').val();
        ie["uf"] = jQuery(this).find('#tdUf').find('#selectUf').val();
        ie["isExcluido"] = (jQuery(this).attr('isExcluido') ? jQuery(this).attr('isExcluido') : false);
        if (ie["uf"].trim() == "") {
            erro = 'Preencha a UF!';
        }
        if (ie["insc"].trim() == "") {
            erro = 'Preencha a IE substituta!';
        }
        lista.push(ie);
    });
    if (erro) {
        chamarAlert(erro);
        return false;
    }
    
    Object.assign(jsonCompleto, {'listaUf': lista});
    return jQuery.stringify(jsonCompleto);
}


function removeItemDom(index) {
    chamarConfirm("Deseja mesmo excluir esta ie substituta?", "confirmarRemocaoIESub(" + index + ")");
}

function confirmarRemocaoIESub(index) {
    var tr = jQuery('#trPrincipal_' + index);
    jQuery(tr).hide().attr('isExcluido', true);
}
