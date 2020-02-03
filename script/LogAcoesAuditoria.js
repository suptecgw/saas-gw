function consultarLog(rotina, tabelaId, dataDe, dataAte, isExclusao) {
    if (isExclusao === undefined) {
        isExclusao = false;
    }

    espereEnviar("Aguarde...", true);
    function e(transport) {
        try {
            
            if (transport.responseText == "-1") {
                alert('Não existe alterações nesse periodo.');
                return false;
            } else {
                var lista = jQuery.parseJSON(transport.responseText);
                var listAcoes = lista.list[0].logAcoesWebtrans;
                var length = (listAcoes != undefined && listAcoes.length != undefined ? listAcoes.length : 1);
                var log = null;


                if (length == 0) {
                    alert('Não existe alterações nesse periodo.');
                    espereEnviar("", false);
                    return false;
                }

                for (var i = 0; i < length; i++) {
                    if (length > 1) {
                        log = listAcoes[i];
                    } else {
                        log = listAcoes;
                    }

                    if (log == null || log == undefined) {
                        alert('Não existe alterações nesse periodo.');
                        espereEnviar("", false);
                        return false;
                    }
                    
                    if (window.addLogAuditoria != null) {
                        addLogAuditoria(log);
                    } else {
                        addLogAuditoriaGenerico(log);
                    }
                }
            }
            espereEnviar("Aguarde...", false);
        } catch (e) {
            console.log(e);
            console.trace();
        }

    }
    tryRequestToServer(function () {
        new Ajax.Request("AuditoriaControlador?acao=listarAuditoria&rotina=" + rotina
                + "&tabelaId=" + tabelaId
                + "&dataDe=" + dataDe
                + "&dataAte=" + dataAte
                + "&exclusao=" + isExclusao
                , {
                    method: 'post',
                    onSuccess: e
                    ,
                    onError: e
                });
    });
}
function mostrarCampos(imgElement) {
    if (imgElement != null && imgElement != undefined) {
        var idx = imgElement.id.split("_")[1];
        var estado = imgElement.src;
        if (estado.indexOf("plus.jpg") > -1) {
            visivel($("tr2Log_" + idx));
            imgElement.src = "img/minus.jpg";
        } else if (estado.indexOf("minus.jpg") > -1) {
            invisivel($("tr2Log_" + idx));
            imgElement.src = "img/plus.jpg";
        }
    }
}
var countLog = 0;
function addLogAuditoriaGenerico(log) {
    try {
        countLog++;
        var _tbody = $("tbAuditoriaConteudo");
        var classe = (countLog % 2 == 0 ? "CelulaZebra1NoAlign" : "CelulaZebra2NoAlign");
        var _tr1 = Builder.node("TR", {id: "tr1Log_" + countLog, className: classe});

        var _td1 = Builder.node("TD", {align: "center"});
        var _td2 = Builder.node("TD", {align: "center"});
        var _td3 = Builder.node("TD", {align: "center"});
        var _td4 = Builder.node("TD", {align: "center"});
        var _td5 = Builder.node("TD", {align: "center"});
        var _td6 = Builder.node("TD", {align: "center"});

        var _img1 = Builder.node('IMG', {src: 'img/plus.jpg', title: 'Mostrar Detalhes', className: 'imagemLink', onClick: 'mostrarCampos(this);', aling: "center", id: "imgCampos_" + countLog});

        var acao = "";

        switch (log.logAcao.action) {
            case "I":
                acao = "Incluiu";
                break;
            case "U":
                acao = "Atualizou";
                break;
            case "D":
                acao = "Deletou";
                break;
        }
        
        _td1.appendChild(_img1);
        Element.update(_td2, log.nomeUsuario);
        Element.update(_td3, log.dataAcao);
        Element.update(_td4, acao);
        Element.update(_td5, log.logAcao.clientAddr);


        _tr1.appendChild(_td1);
        _tr1.appendChild(_td2);
        _tr1.appendChild(_td3);
        _tr1.appendChild(_td4);
        _tr1.appendChild(_td5);
        _tr1.appendChild(_td6);

        _tbody.appendChild(_tr1);


        var _tr2 = Builder.node("TR", {id: "tr2Log_" + countLog, className: classe});
        var _td2_1 = Builder.node("TD", {align: "center", colSpan: 6});
        var _table2_1 = Builder.node("table", {width: "100%", id: "tableCampos_" + countLog, className:"tabelaZerada"});
        var _tbody2_1 = Builder.node("tbody", {id: "tabCampos_" + countLog});
        var _trDesCampo = Builder.node("TR", {id: "trDesCampo_" + countLog, className: "celula"});
        var _tdDescCampo = Builder.node("TD", {align: "center", width: "40%"}, "Campos");
        var _tdDescAntes = Builder.node("TD", {align: "center", width: "30%"}, "Antes");
        var _tdDescDepois = Builder.node("TD", {align: "center", width: "30%"}, "Depois");
        var _trValCampo = null;
        
        _trDesCampo.appendChild(_tdDescCampo);
        _trDesCampo.appendChild(_tdDescAntes);
        _trDesCampo.appendChild(_tdDescDepois);
        _tbody2_1.appendChild(_trDesCampo);
        
        var _tdValCampo = null;
        var _tdValAntes = null;
        var _tdValDepois = null;

        if (log.logAcao.campos != null && log.logAcao.campos != undefined) {

            var campos = log.logAcao.campos;
            var campo = log.logAcao.campos[0].campos;



            if (campo != null && campo != undefined) {
                for (var j = 0; j < campo.length; j++) {
                    _trValCampo = Builder.node("TR", {id: "trValCampo_" + countLog + "_" + j, className: classe});

                    _tdValCampo = Builder.node("TD", {align: "center", width: "40%"}, campo[j].descricao);
                    _tdValAntes = Builder.node("TD", {align: "center", width: "30%"}, campo[j].antes);
                    _tdValDepois = Builder.node("TD", {align: "center", width: "30%"}, campo[j].depois);

                    _trValCampo.appendChild(_tdValCampo);
                    _trValCampo.appendChild(_tdValAntes);
                    _trValCampo.appendChild(_tdValDepois);

                    _tbody2_1.appendChild(_trValCampo);
                }
            }
        }
        
        var _trErro = null;
        var _tdErro1 = null;
        var _tdErro2 = null;
        if (log.logAcao.erros != null && log.logAcao.erros != undefined) {

            var erros = log.logAcao.erros[0].erros;
            
            for (var e = 0; e < erros.length; e++) {
                _trErro = Builder.node("TR", {id: "trErro_" + countLog + "_" + e, className: classe});
                _tdErro1 = Builder.node("TD", {align: "center", colSpan:3}, erros[e].msg);
                
                _tdErro1.style = "color:red";
                
                _trErro.appendChild(_tdErro1);
                _tbody2_1.appendChild(_trErro);
            }
        }

        
        _table2_1.appendChild(_tbody2_1);
        _td2_1.appendChild(_table2_1);
        _tr2.appendChild(_td2_1);

        _tbody.appendChild(_tr2);

        invisivel(_tr2);
    } catch (e) {
        console.log(e);
    }
}