
/**
 * Controla toda a parte de cheque no java Script. \n
 * É necessario que a tela que usa este metodo importe a biblioteca jquery e funcoes ou funcoes_gweb
 * textoresposta : texto que contem os números dos documentos
 */
function gerarDocum(textoresposta, isControlaTalonario, objSelect, objInput, selectValue) {

    isControlaTalonario = (isControlaTalonario == "true" || isControlaTalonario == true ? true : false);
    //se deu algum erro na requisicao...
    if (textoresposta == "-1") {
        alert('Houve algum problema ao requistar o novo cheque, favor informar manualmente.');
        return false;
    } else {

        if (isControlaTalonario) {
            objInput.style.display = "none";
            objSelect.style.display = "";
            var lista = jQuery.parseJSON(textoresposta);

            var listCheque = lista.list[0].documento;

            var docum;
            var isPrimeiro = true;

            var slct = objSelect;

            var opt = null;

            Element.update(slct);
            opt = new Element("option", {
                value: ""
            })

            var valor = "";
            Element.update(opt, " ---- ");
            slct.appendChild(opt);

            var length = (listCheque != undefined && listCheque.length != undefined ? listCheque.length : 1);
            //Pegando o parametro vindo da consulta para colocar ele como primeiro elemento da lista
            if (selectValue != null && selectValue != undefined && selectValue != "") {
                //Adicionando o valor do parametro ao valor da consulta do ajax para que ele fique em primeiro
                valor = selectValue;
                slct.appendChild(Builder.node('OPTION', {value: selectValue}, selectValue));
                isPrimeiro = false;
            }
            //percorrendo a lista de cheques
            for (var i = 0; i < length; i++) {

                if (length > 1) {
                    docum = listCheque[i];
                } else {
                    docum = listCheque;
                }

                valor += (isPrimeiro ? docum : "");

                if (docum != null && docum != undefined) {

                    slct.appendChild(Builder.node('OPTION', {value: docum}, docum));
                }
                isPrimeiro = false;
            }

            slct.value = valor;

        } else {
            objInput.style.display = "";
            objSelect.display = "none";
            objInput.value = textoresposta;
        }
        return true;
    }
}


function controlarCheque(isControlaTalonario, objSelect, objInput, idConta, selectValue) {
    function e(transport) {
        gerarDocum(transport.responseText, isControlaTalonario, objSelect, objInput, selectValue);
    }
    tryRequestToServer(function() {
        new Ajax.Request("TalaoChequeControlador?acao=proxCheque&setor=o&idConta=" + idConta, {
            method: 'post',
            onSuccess: e
            ,
            onError: e
        });
    });


}