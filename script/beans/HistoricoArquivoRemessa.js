/**
 *********************************************************************
 *************************** OBS MUITO IMPORTANTE ********************
 *********************************************************************
 * Quando acrescentar um codigo nessa rotina é preciso acrescentar o *
 * respectivo codigo no metodo de validação na classe de geração do  *
 * arquivo                                                           *
 *                                                                   *
 */


var callFmtData = "fmtDate(this, event)";
var callMascaraSoNumeros = "mascara(this, soNumeros);";
var callAlterarFaturaDtVencimento = "alterarFaturaDtVencimento(this.value);";
var callAlterarFaturaQtdDiasBaixa = "alterarFaturaQtdDiasBaixa(this.value);";
var callAlterarFaturaQtdDiasProtesto = "alterarFaturaQtdDiasProtesto(this.value);";
var callAlterarCodProtesto = "alterarFaturaCodProtesto(this.value);";

var countHist = 0;
function HistoricoArquivoRemessa(id, dtHrInclusao, codMov, dtVencimento, qtdDiasBaixaDevolucao, qtdDiasProtesto, codProtesto){
    this.indice = (++countHist);
    this.id = (id == null || id== undefined ? 0 : id);
    this.dtHrInclusao = (dtHrInclusao == null || dtHrInclusao== undefined ? "" : dtHrInclusao);
    this.codMov = (codMov == null || codMov == undefined ? "" : codMov);
    //Campos Dinamicos
    this.dtVencimento = (dtVencimento == null || dtVencimento== undefined ? "" : dtVencimento);
    this.qtdDiasBaixaDevolucao = (qtdDiasBaixaDevolucao == null || qtdDiasBaixaDevolucao == undefined ? "" : qtdDiasBaixaDevolucao);
    this.qtdDiasProtesto = (qtdDiasProtesto == null || qtdDiasProtesto == undefined ? "" : qtdDiasProtesto);
    this.codProtesto = (codProtesto == null || codProtesto == undefined ? 0 : codProtesto);
}

function addHistoricoArquivoRemessa(histArqRem, _tabela){
    try {
        if (histArqRem == null || histArqRem == undefined) {
            histArqRem = new HistoricoArquivoRemessa();
        }
        var callDefinirVisibilidade = "definirVisibilidadeCampos("+histArqRem.indice+");";    
        var classe = ((histArqRem.indice % 2) == 0 ? 'CelulaZebra1' : 'CelulaZebra2');
        
        var _tr1 = Builder.node("tr",{
            id:"trhistorico_"+histArqRem.indice, 
            className: classe
        });
        var _tdMov = new Element("td", {
            align:"left",
            colSpan: 1
        });
        var _tdDtInclusao = new Element("td", {
            align:"center"
        });
        var _tdVariado = new Element("td", {
            align:"left",
            colSpan: 3
        });
        var _tdLixo = new Element("td", {
            align:"center",
            colSpan: 1
        });
        
        var _slcMov = Builder.node('select', {
            name:'mov_' + histArqRem.indice, 
            id:'mov_' + histArqRem.indice, 
            className : 'fieldMin',
            onChange: callDefinirVisibilidade
        });
        
        povoarSelect(_slcMov, listaMomArquivoRemessa);
        
        if (histArqRem.codMov != 0) {
            _slcMov.value = histArqRem.codMov;
        }else{
            _slcMov.selectedIndex = 0;
        }
        
        var _inpId = Builder.node("input", {
            type:"hidden",
            name:"idHist_"+histArqRem.indice,
            id: "idHist_"+histArqRem.indice,
            value: histArqRem.id
        });
        var _inpDtInclusao = Builder.node("label", {
            id: "dtInclusao_"+histArqRem.indice
        }, histArqRem.dtHrInclusao);
        
        var _img1 = Builder.node('IMG', {
            src:'img/lixo.png', 
            title:'Excluir', 
            className:'imagemLink',
            onClick: "removerHistorico("+histArqRem.indice+")"
        });
        
        _tdMov.appendChild(_slcMov);
        _tdMov.appendChild(_inpId);
        _tdDtInclusao.appendChild(_inpDtInclusao);
        if (histArqRem.id == 0) {
            _tdLixo.appendChild(_img1);
        }



        /**
         * AQUI COMEÇAM OS CAMPOS QUE SERÃO ACRESCENTADOS NA MEDIDA QUE OS CODIGOS DE MOVIMENTAÇÃO FOREM ACRESCENTADOS A ROTINA
         */
        var _labDtVenc = Builder.node('label', {
            id: "labDtVenc_"+histArqRem.indice
        }, " Dt. Venc: ");
        var _labQtdDiasBaixaDev = Builder.node('label', {
            id: "labQtdDiasBaixaDev_"+histArqRem.indice
        }, " Dias Baixa/Devolução: ");
        var _labQtdDiasBaixaProtesto = Builder.node('label', {
            id: "labQtdDiasProtesto_"+histArqRem.indice
        }, " Dias Protesto: ");
        var _labCodProtesto = Builder.node('label', {
            id: "labCodProtesto_"+histArqRem.indice
        }, " Cod. Protesto: ");
        
        var _inpDtVenc = Builder.node("input", {
            type:"text",
            className: "fieldDateMin",
            maxlength: 10,
            onkeypress: callFmtData,         
            size: 9 ,
            name:"dtVenc_"+histArqRem.indice,
            id: "dtVenc_"+histArqRem.indice,
            onChange: callAlterarFaturaDtVencimento,
            value: histArqRem.dtVencimento
        });
        var _inpCodProtesto = Builder.node("select", {
            type:"text",
            className: "fieldMin",
            maxlength: 10,
            name:"codProtesto_"+histArqRem.indice,
            id: "codProtesto_"+histArqRem.indice,
            onChange: callAlterarCodProtesto
        });
        povoarSelect(_inpCodProtesto, listCodProtesto);
        if (histArqRem.codProtesto != 0 ) {
            _inpCodProtesto.value = histArqRem.codProtesto;
        }
        
        
        var _inpQtdDiasBaixaDev = Builder.node("input", {
            type:"text",
            className: "fieldMin",
            maxlength: 10,
            onkeypress: callMascaraSoNumeros,
            size: 9 ,
            name:"qtdDiasBaixaDev_"+histArqRem.indice,
            id: "qtdDiasBaixaDev_"+histArqRem.indice,
            onChange: callAlterarFaturaQtdDiasBaixa,
            value: histArqRem.qtdDiasBaixaDevolucao
        });
        var _inpQtdDiasProtesto = Builder.node("input", {
            type:"text",
            className: "fieldMin",
            maxlength: 10,
            onkeypress: callMascaraSoNumeros,
            size: 9 ,
            name:"qtdDiasProtesto_"+histArqRem.indice,
            id: "qtdDiasProtesto_"+histArqRem.indice,
            onChange: callAlterarFaturaQtdDiasProtesto,
            value: histArqRem.qtdDiasProtesto
        });


        _tdVariado.appendChild(_labDtVenc);
        _tdVariado.appendChild(_inpDtVenc);
        _tdVariado.appendChild(_labQtdDiasBaixaDev);
        _tdVariado.appendChild(_inpQtdDiasBaixaDev);
        _tdVariado.appendChild(_labCodProtesto);
        _tdVariado.appendChild(_inpCodProtesto);
        _tdVariado.appendChild(_labQtdDiasBaixaProtesto);
        _tdVariado.appendChild(_inpQtdDiasProtesto);
        
        _tr1.appendChild(_tdLixo);
        _tr1.appendChild(_tdMov);
        _tr1.appendChild(_tdDtInclusao);
        _tr1.appendChild(_tdVariado);
        
        _tabela.appendChild(_tr1);
        
        invisivel(_labDtVenc);
        invisivel(_inpDtVenc);
        invisivel(_labQtdDiasBaixaDev);
        invisivel(_inpQtdDiasBaixaDev);
        invisivel(_labQtdDiasBaixaProtesto);
        invisivel(_inpQtdDiasProtesto);
        invisivel(_labCodProtesto);
        invisivel(_inpCodProtesto);
        
        $("maxHistorico").value = histArqRem.indice;
        definirVisibilidadeCampos(histArqRem.indice);
        _slcMov.focus();
        
        if (histArqRem.id != 0) {
            desabilitar(_slcMov, "#DBE9F1");
            readOnly(_inpDtVenc, "inputReadOnly8pt");
            readOnly(_inpQtdDiasBaixaDev, "inputReadOnly8pt");
            readOnly(_inpQtdDiasProtesto, "inputReadOnly8pt");
            desabilitar(_inpCodProtesto, "#DBE9F1");
        }
        
    } catch (e) { 
        alert(e);
        console.log(e)
    }
}

function definirVisibilidadeCampos(index){
    try {
        var elemento = $("mov_" + index);
        var textSelected = getTextSelect(elemento);
        var cod = textSelected.split("-")[0].trim();
        cod = parseInt(cod, 10);
        
        invisivel($("labQtdDiasBaixaDev_" + index));
        invisivel($("qtdDiasBaixaDev_" + index));
        invisivel($("labDtVenc_" + index));
        invisivel($("dtVenc_" + index));
        invisivel($("labQtdDiasProtesto_" + index));
        invisivel($("qtdDiasProtesto_" + index));
        invisivel($("labCodProtesto_" + index));
        invisivel($("codProtesto_" + index));
        switch (cod){
            case 1://Entrada de titulos
                break
            case 2://Pedido de Baixa
                visivel($("labQtdDiasBaixaDev_" + index));
                visivel($("qtdDiasBaixaDev_" + index));
                break
            case 6://Alteração de data de vencimento
                visivel($("labDtVenc_" + index));
                visivel($("dtVenc_" + index));
                break
            case 9://PROTESTO
                visivel($("labQtdDiasProtesto_" + index));
                visivel($("qtdDiasProtesto_" + index));
                visivel($("labCodProtesto_" + index));
                visivel($("codProtesto_" + index));
                break
            case 41://CANCELAR PROTESTO
                alterarFaturaCodProtesto(9);
                break
        }
    } catch (e) { 
        alert(e);
    }
}

function carregarAjaxMovRemessa(_listaMov){
    new Ajax.Request("./fatura_cliente?acao=carregarMovRemessa",
    {
        method: "get",
        onSuccess: function(transport) {
            var response = transport.responseText;
            var listMovRemessa = jQuery.parseJSON(response).list[0].movRemessa;
            var movRemessa = null;
                
            var length = (listMovRemessa != undefined && listMovRemessa.length != undefined ? listMovRemessa.length : 1);
            var idx = 0;
                
            for (var i = 0; i <= length; i++) {
                if (length == 1) {
                    movRemessa = listMovRemessa;
                }else{
                    movRemessa = listMovRemessa[i];
                }

                _listaMov[idx++] = new Option(movRemessa.id, movRemessa.codigo + " - " + movRemessa.descricao);
            }
                
        },
        onFailure: function() {
        }
    });
}

function alterarCodMov(index){
    
}

function alterarFaturaDtVencimento(dtVencimento){
    if ($("dtvencimento") != null) {
        $("dtvencimento").value = dtVencimento;
    }
}

function alterarFaturaQtdDiasBaixa(qtdDiasBaixa){
    if ($("diasDevolucao") != null) {
        $("diasDevolucao").value = qtdDiasBaixa;
        $("codDevolucao").value = "1";
    }
}

function alterarFaturaQtdDiasProtesto(qtdDiasProtesto){
    if ($("diasProtesto") != null) {
        $("diasProtesto").value = qtdDiasProtesto;
    }
}

function alterarFaturaCodProtesto(codProtesto){
    if ($("codProtesto") != null) {
        $("codProtesto").value = codProtesto;
    }
}

function removerHistorico(indice){
    var mov = getMovHistorico(indice);
    var descricao = (mov == null || mov == undefined ? "" : mov.descricao);
    if(confirm("Deseja remover a ocorrencia ("+descricao+") do historico do arquivo de remessa?" )){
        if(confirm("Tem certeza?" )){
            if (mov != null) {
                switch(parseInt(mov.descricao.split("-")[0].trim(), 10)){
                    case 2://Pedido de Baixa
                        if ($("qtdDiasBaixaDevAuxHistorico") != null && $("qtdDiasBaixaDevAuxHistorico") != undefined) {
                            $("diasDevolucao").value = $("qtdDiasBaixaDevAuxHistorico").value;
                            $("codDevolucao").value = $("codBaixaDevAuxHistorico").value;
                        }
                        break;
                    case 6://Alteração de data de vencimento
                        if ($("dataVencAuxHistorico") != null && $("dataVencAuxHistorico") != undefined) {
                            $("dtvencimento").value = $("dataVencAuxHistorico").value;
                        }
                        break;
                    case 9://PROTESTO
                        if ($("codProtestoAuxHistorico") != null && $("codProtestoAuxHistorico") != undefined) {
                            $("codProtesto").value = $("codProtestoAuxHistorico").value;
                            $("diasProtesto").value = $("qtdDiasProtestoAuxHistorico").value;
                        }
                        break;
                    case 41://PROTESTO
                        if ($("codProtestoAuxHistorico") != null && $("codProtestoAuxHistorico") != undefined) {
                            $("codProtesto").value = $("codProtestoAuxHistorico").value;
                            $("diasProtesto").value = $("qtdDiasProtestoAuxHistorico").value;
                        }
                        break;
                }
            }
            Element.remove($("trhistorico_"+indice));
        }
    }
}

function getMovHistorico(indice){
    try {
        var mov = 0;
        
        if ($("mov_" + indice) != null && $("mov_" + indice) != undefined) {
            mov = $("mov_" + indice).value;
        }
        
        if (mov != null && listaMomArquivoRemessa != null && listaMomArquivoRemessa != undefined) {
            for (var i = 0; i < listaMomArquivoRemessa.size(); i++) {
                if (listaMomArquivoRemessa[i].valor == mov) {
                    return listaMomArquivoRemessa[i];
                }
            }
        }
        
        return null;
    } catch (e) { 
        alert(e);
    }
}