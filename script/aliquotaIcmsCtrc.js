/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Para usar este js é necessario o jsp utilizar um js de jquery
 */
var listaUfAliq = null;
function getAliquotasIcmsAjax(idFilial){
    espereEnviar("",true);
    function e(transport){
        try{
            var textoResposta = transport.responseText;
            if (textoResposta == "-1") {
                alert('Houve algum problema ao requisitar a aliquota de ICMS, favor informar manualmente.');
                return false;
            } else {
                var lista = jQuery.parseJSON(textoResposta);

                if (lista !== null && lista !== undefined && lista.list !== null && lista.list !== undefined) {
                    listaUfAliq = lista.list[0].ufIcms;
                    return true;
                } else {
                    // alert('Não existe aliquota cadastrada, favor informar manualmente.');
                    return false;
                }
            }
        }catch (e){
            console.log(e);
        }
    }
    tryRequestToServer(function(){
        new Ajax.Request("ConhecimentoControlador?acao=ajaxCarregarAliquotasIcms&filial="+idFilial,{
            method:'post', 
            onSuccess: e
            ,
            onError: e
        });
    });
    espereEnviar("",false);
}
/**
 *Retorna o objeto UFIcms desejado.
 *Deve ser usado o outro metodo para recuperar a aliquota
 */
function getUfAliquotaIcmsCtrc(ufOrigem, ufDestino, idCidadeDestino, imprimirAlerta, tipoTributacaoCon){
    var ufAliq = null; 
    idCidadeDestino = (idCidadeDestino == null || idCidadeDestino == undefined ? 0 : idCidadeDestino);
    var ufAliqLista = "";
    
    if (listaUfAliq != null  && listaUfAliq != undefined) {
        var length = (listaUfAliq.length != undefined ? listaUfAliq.length : 1);
        for (i = 0; i < length; i++) {
            //descobrindo qual objeto será utilizado
            if (length != 1) {
                ufAliqLista = (listaUfAliq[i].uf == null || listaUfAliq[i].uf == undefined ? listaUfAliq[i].ufDestino.trim().toUpperCase(): listaUfAliq[i].uf.trim().toUpperCase());
                if (listaUfAliq[i].ufOrigem.trim().toUpperCase() == ufOrigem.trim().toUpperCase()
                        && ufAliqLista == ufDestino.trim().toUpperCase()
                        && (listaUfAliq[i].tipoTributacao === tipoTributacaoCon)
                        && (idCidadeDestino == listaUfAliq[i].cidade.idcidade || listaUfAliq[i].cidade.idcidade == 0)) {
                    ufAliq = listaUfAliq[i];
                    break;
                }
            }else{
                ufAliqLista = (listaUfAliq.uf == null || listaUfAliq.uf == undefined ? listaUfAliq.ufDestino.trim().toUpperCase(): listaUfAliq.uf.trim().toUpperCase());
                if (listaUfAliq.ufOrigem.trim().toUpperCase() == ufOrigem.trim().toUpperCase()
                        && ufAliqLista == ufDestino.trim().toUpperCase()
                        && (listaUfAliq.tipoTributacao === tipoTributacaoCon)
                        && (idCidadeDestino == listaUfAliq.cidade.idcidade || listaUfAliq.cidade.idcidade == 0)) {
                    ufAliq = listaUfAliq;
                    break;
                }
            }
            if (i == (length - 1)){
                if((imprimirAlerta==undefined || imprimirAlerta==true) && (tipoTributacaoCon != undefined && tipoTributacaoCon != "")){
                    alert(getMensagemAliquota(ufOrigem, ufDestino));
                }
            }
        }
    }
    return ufAliq;
}
/**
 * Coloca a aliquota, obervação e o percentual da redução dentro de um elemento do html.
 * @deprecated
 */
function definirValorAliquota(ufOrigem, ufDestino, cidadeDestinoId, objAliq, objObservacao, objReducao, tipoTransporte, isDestinatarioIsento, objStIcms, tipoTributacaoCon,
                              objObservacaoFisco){
    var ufAliq = getUfAliquotaIcmsCtrc(ufOrigem, ufDestino, cidadeDestinoId, undefined, tipoTributacaoCon);
    var aliquota = -1;
    if (ufAliq != null) {
        if (tipoTransporte != "a") {
            if (!isDestinatarioIsento) {
                aliquota = (ufAliq.aliq == null || ufAliq.aliq == undefined ? ufAliq.aliquota : ufAliq.aliq);
            }else{
                aliquota = (ufAliq.aliqCpf == null || ufAliq.aliqCpf == undefined ? ufAliq.aliquotaPessoaFisica : ufAliq.aliqCpf);
            }
        }else{
            if (!isDestinatarioIsento) {
                aliquota = ufAliq.aliquotaAereo;
            }else{
                aliquota = (ufAliq.aliquotaAereoCpf == null || ufAliq.aliquotaAereoCpf == undefined ? ufAliq.aliquotaAereoPessoaFisica : ufAliq.aliquotaAereoCpf);
            }
        }
        if (objStIcms != null) {
            objStIcms.value = ufAliq.situacaoTributavel.id;
        }
    }else{
        aliquota = -1;
        //alert("Não foi encontrado aliquota para esta origem e destino!");
    }
    //if (ufAliq != null && objAliq != null && objAliq != undefined) {
        objAliq.value = aliquota;    
    //}
    if (ufAliq != null && objObservacao != null && objObservacao != undefined && ufAliq.obs.descricao != undefined) {
        objObservacao.value = ufAliq.obs.descricao;    
    }
    if (ufAliq!= null && objReducao != null && objReducao != undefined) {
        objReducao.value = ufAliq.reducaoBaseIcms;    
    }
    if (ufAliq != null && objObservacaoFisco != null && objObservacaoFisco != undefined && ufAliq.obsFisco.descricao != undefined) {
        objObservacaoFisco.value = ufAliq.obsFisco.descricao;
    }
}

function getMensagemAliquota(ufOrigem, ufDestino){
    return "A T E N Ç Ã O \n\nNão foi possível localizar a alíquota de ICMS \nUF Origem: " + ufOrigem
           + "\nUF Destino: " + ufDestino + "\n\n"
           + "Para resolver esse problema você deverá acessar o menu (Configurações/Alterar alíquota ICMS) "
           + "e cadastrar a alíquota.";
}


