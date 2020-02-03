<%--
    Document   : cadastrar_rateio
    Created on : 17/12/2008, 09:36:23
    Author     : Renan Vicente
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"
        import="nucleo.*"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<link REL="stylesheet" HREF="estilo.css" TYPE="text/css">
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script type="text/javascript" language="JavaScript">
    /* ultimo index vai servir para 
     * mandar a informação do localiza para linha certa
     */
    jQuery.noConflict();
    arAbasGenerico = new Array();
    arAbasGenerico[0] = stAba('tdAbaAuditoria', 'divAuditoria');

    ultIndexSelecionado = 0;
    function limparCliente() {
        document.formulario.cliente.value = "";
        document.formulario.idCliente.value = "0";
    }

    function popLocate(index, idlista, nomeJanela) {
        //altera o ultIndex para colocar a informacao na linha certo no aoClicar no localiza
        ultIndexSelecionado = index;
        launchPopupLocate("./localiza?acao=consultar&idlista=" + idlista, nomeJanela);
    }

    function carregar() {
        try {
            $("dataDeAuditoria").value = '<c:out value="${param.dataAtual}"/>';
            $("dataAteAuditoria").value = '<c:out value="${param.dataAtual}"/>';
            var action = '<c:out value="${param.acao}"/>';
            var form = document.formulario;

            if (action == 2) {
    <c:forEach var="item" varStatus="status" items="${cadRateio.itens}">
                addItems(new Item(${item.id},${item.planocusto.idconta}, "${item.planocusto.conta}",
        ${item.percentual},${item.veiculo.idveiculo}, "${item.veiculo.placa}",${item.filial.idfilial},
                        "${item.filial.abreviatura}",${item.unidadeCusto.id}, "${item.unidadeCusto.sigla}")
                        );
    </c:forEach>
                //                idPlanoCusto,planoCusto,percentual,idVeiculo,veiculo,idFilial,filial,idUndCusto,undCusto
            }
        } catch (e) {
            alert(e);
        }

    }
    function salvar() {
        if ($("descricao").value == "") {
            alert("O campo 'Descricão' não pode ficar em branco!")
            return false;
        }

        for (var i = 1; i <= countItems; i++) {
            if ($("planoCustoId_" + i) != undefined) {
                if ($("planoCustoId_" + i).value <= 0) {
                    alert("Informe os Planos Centro de Custo Corretamente!");
                    return false;
                }
                if ($("percentual_" + i).value <= 0) {
                    alert("Informe os percentuais Corretamente!");
                    return false;
                }
//                    if($("undCustoId_"+i).value <= 0){
//                        alert("Informe as Unidades de custo Corretamente!");
//                        return false;
//                    }            
            }
        }
        // testando o valor do percentual 
        var totPercentual = 0.00;
        for (var i = 1; i <= countItems; i++) {
            if ($("percentual_" + i) != undefined) {
                totPercentual =  roundABNT(parseFloat(totPercentual) +parseFloat(colocarPonto($("percentual_"+i).value)),2);;
            }
        }

        if (totPercentual != 100) {
            alert("O Total dos Percentuais tem que ser 100%!");
            return false;
        }

        setEnv();
        window.open('about:blank', 'pop', 'width=210, height=100');
        var form = $("formulario");
        form.submit();
    }

    function voltar() {
        location.replace('ConsultaControlador?codTela=18');
    }

    function aoClicarNoLocaliza(idJanela) {
        try {
            if (ultIndexSelecionado == 0) {
                if (idJanela == "Plano_Custo") {
                    $("lblPlanoCusto_" + countItems).innerHTML = "  " + $("plcusto_descricao_despesa").value;
                    $("planoCustoId_" + countItems).value = $("idplanocusto_despesa").value;
                }
            } else {
                if (idJanela == "Plano_Custo") {
                    $("lblPlanoCusto_" + ultIndexSelecionado).innerHTML = "  " + $("plcusto_descricao_despesa").value;
                    $("planoCustoId_" + ultIndexSelecionado).value = $("idplanocusto_despesa").value;
                }
                if (idJanela == "Veiculo") {
                    $("lblPlaca_" + ultIndexSelecionado).innerHTML = "  " + $("vei_placa").value;
                    $("veiculoId_" + ultIndexSelecionado).value = $("idveiculo").value;
                }
                if (idJanela == "Filial") {
                    $("lblFilial_" + ultIndexSelecionado).innerHTML = "  " + $("fi_abreviatura2").value;
                    $("filialId_" + ultIndexSelecionado).value = $("idfilial2").value;
                }
                if (idJanela == "Unidade_de_Custo") {
                    $("lblUndCusto_" + ultIndexSelecionado).innerHTML = "  " + $("sigla_und").value;
                    $("undCustoId_" + ultIndexSelecionado).value = $("id_und").value;
                }
            }
        } catch (e) {
            alert(e);
        }
    }

    function excluirAprop(index) {
        var id = $("itemId_" + index).value;
        var atualizadoPor = '<c:out value="${cadRateio.atualizadoPor.nome}"/>';
        var idRateio = '<c:out value="${cadRateio.id}"/>';
        if (confirm("Deseja mesmo excluir esta apropriação?")) {
            if (confirm("Tem certeza?")) {

                tryRequestToServer(function () {
                    new Ajax.Request("RateioControlador?acao=excluirItem&idItemRateio=" + id + "&idRateio=" + idRateio);
                });

                $("trAprop_" + index).parentNode.removeChild($("trAprop_" + index));
            }
        }
    }

    function Item(idItem, idPlanoCusto, planoCusto, percentual, idVeiculo, veiculo, idFilial, filial, idUndCusto, undCusto) {
        this.idItem = (idItem == null || idItem == undefined) ? 0 : idItem;
        this.idPlanoCusto = (idPlanoCusto == null || idPlanoCusto == undefined) ? 0 : idPlanoCusto;
        this.planoCusto = (planoCusto == null || planoCusto == undefined) ? "" : planoCusto;
        this.percentual = (percentual == null || percentual == undefined) ? 0.00 : percentual;
        this.idVeiculo = (idVeiculo == null || idVeiculo == undefined) ? 0 : idVeiculo;
        this.veiculo = (veiculo == null || veiculo == undefined) ? "" : veiculo;
        this.idFilial = (idFilial == null || idFilial == undefined) ?<%=Apoio.getUsuario(request).getFilial().getIdfilial()%> : idFilial;
        this.filial = (filial == null || filial == undefined) ? "<%=Apoio.getUsuario(request).getFilial().getAbreviatura()%>" : filial;
        this.idUndCusto = (idUndCusto == null || idUndCusto == undefined) ? 0 : idUndCusto;
        this.undCusto = (undCusto == null || undCusto == undefined) ? "" : undCusto;
    }
    var countItems = 0;
    function addItems(item) {
        try {
            if (item == null || item == undefined) {
                item = new Item();
                //chama a janela do localiza e zera o index da linha
                launchPopupLocate('./localiza?acao=consultar&idlista=20', 'Plano_Custo');
                ultIndexSelecionado = 0;
            }

            countItems++;

            var tbBase = $("tbBase");
            var tr = Builder.node("tr", {id: "trAprop_" + countItems, name: "trAprop_" + countItems});
            var td = Builder.node("td", {className: "CelulaZebra2", id: "", name: ""});
            var tdPlanCentroCusto = Builder.node("td", {className: "CelulaZebra2", id: "", name: ""});
            var tdPercentual = Builder.node("td", {className: "CelulaZebra2", id: "", name: ""});

            var tdVeiculo = Builder.node("td", {className: "CelulaZebra2", id: "", name: ""});
            var tdFilial = Builder.node("td", {className: "CelulaZebra2", id: "", name: ""});
            var tdUndCusto = Builder.node("td", {className: "CelulaZebra2", id: "", name: ""});

            var _idItem = Builder.node("input", {type: "hidden", id: "itemId_" + countItems, name: "itemId_" + countItems, value: item.idItem});

            var _btLocPlan = Builder.node("input", {className: "inputBotaoMin", type: "button", id: "btlocPlanCusto_" + countItems, value: "...", onclick: "popLocate(" + countItems + ",20,'Plano_Custo')"});
            var _lblPlanCusto = Builder.node("label", {id: "lblPlanoCusto_" + countItems, name: "lblPlanoCusto_" + countItems});
            _lblPlanCusto.innerHTML = item.planoCusto;
            var _inpPlanCustoId = Builder.node("input", {className: "inputTexto", type: "hidden", id: "planoCustoId_" + countItems, name: "planoCustoId_" + countItems, value: item.idPlanoCusto});

            var _inpPercentual = Builder.node("input", {className: "inputTexto", id: "percentual_" + countItems, name: "percentual_" + countItems, size: "8", maxlength: 6, value: colocarVirgula(item.percentual), onkeypress:"mascara(this, reais)"});
            
            var _lblVeiculo = Builder.node("label", {id: "lblPlaca_" + countItems, name: "lblPlaca_" + countItems, size: "8"});
            _lblVeiculo.innerHTML = "  " + item.veiculo;
            var _inpVeiculoId = Builder.node("input", {className: "fieldMin", type: "hidden", id: "veiculoId_" + countItems, name: "veiculoId_" + countItems, size: "8", value: item.idVeiculo});
            var _btLocVeiculo = Builder.node("input", {className: "inputBotaoMin", type: "button", id: "btlocVeiculo_" + countItems, name: "btlocVeiculo_" + countItems, value: "...", onclick: "popLocate(" + countItems + ",'24','Veiculo')"});
            var _limparVeiculo = Builder.node("img", {src: "img/borracha.gif", id: "limparVeiculo_" + countItems, name: "limparVeiculo_" + countItems, className: "imagemLink", onclick: "javascript:$('veiculoId_" + countItems + "').value = '0';$('lblPlaca_" + countItems + "').innerHTML = '';"});

            var _lblFilial = Builder.node("label", {id: "lblFilial_" + countItems, name: "lblFilial_" + countItems, size: "8"});
            _lblFilial.innerHTML = "  " + item.filial;
            var _inpFilialId = Builder.node("input", {className: "fieldMin", type: "hidden", id: "filialId_" + countItems, name: "filialId_" + countItems, size: "8", value: item.idFilial});
            var _btLocFilial = Builder.node("input", {className: "inputBotaoMin", type: "button", id: "btlocFilial_" + countItems, name: "btlocFilial_" + countItems, value: "...", onclick: "popLocate(" + countItems + ",'17','Filial')"});

            var _lblUndCusto = Builder.node("label", {id: "lblUndCusto_" + countItems, name: "lblUndCusto_" + countItems, size: "8"});
            _lblUndCusto.innerHTML = "  " + item.undCusto;
            var _inpUndCustoId = Builder.node("input", {className: "fieldMin", type: "hidden", id: "undCustoId_" + countItems, name: "undCustoId_" + countItems, size: "8", value: item.idUndCusto});
            var _btLocUndCusto = Builder.node("input", {className: "inputBotaoMin", type: "button", id: "btlocUndCusto_" + countItems, name: "btlocUndCusto_" + countItems, value: "...", onclick: "popLocate(" + countItems + ",'39','Unidade_de_Custo')"});
            var _limparUnd = Builder.node("img", {src: "img/borracha.gif", id: "limparUnd_" + countItems, name: "limparUnd_" + countItems, className: "imagemLink", onclick: "javascript:$('undCustoId_" + countItems + "').value = '0';$('lblUndCusto_" + countItems + "').innerHTML = '';"});

            var _delete = Builder.node("img", {className: "imagemLink", src: "img/lixo.png", title: "Excluir", onclick: "excluirAprop(" + countItems + ")"});

            tdPlanCentroCusto.appendChild(_idItem);
            tdPlanCentroCusto.appendChild(_btLocPlan);
            tdPlanCentroCusto.appendChild(_lblPlanCusto);
            tdPlanCentroCusto.appendChild(_inpPlanCustoId);

            tdPercentual.appendChild(_inpPercentual);

            tdVeiculo.appendChild(_btLocVeiculo);
            tdVeiculo.appendChild(_limparVeiculo);
            tdVeiculo.appendChild(_lblVeiculo);
            tdVeiculo.appendChild(_inpVeiculoId);

            tdFilial.appendChild(_btLocFilial);
            tdFilial.appendChild(_lblFilial);
            tdFilial.appendChild(_inpFilialId);

            tdUndCusto.appendChild(_btLocUndCusto);
            tdUndCusto.appendChild(_limparUnd);
            tdUndCusto.appendChild(_lblUndCusto);
            tdUndCusto.appendChild(_inpUndCustoId);

            td.appendChild(_delete);

            tr.appendChild(tdPlanCentroCusto);
            tr.appendChild(tdPercentual);
            tr.appendChild(tdVeiculo);
            tr.appendChild(tdFilial);
            tr.appendChild(tdUndCusto);
            tr.appendChild(td);
            tbBase.appendChild(tr);
            $("tbBase").appendChild(tr)
            $("max").value = countItems;

        } catch (e) {
            alert(e);
        }
    }
    function pesquisarAuditoria() {
        if (countLog != null && countLog != undefined) {
            for (var i = 1; i <= countLog; i++) {
                if ($("tr1Log_" + i) != null) {
                    Element.remove(("tr1Log_" + i));
                }
                if ($("tr2Log_" + i) != null) {
                    Element.remove(("tr2Log_" + i));
                }
            }
        }
        countLog = 0;
        var rotina = "rateio";
        var dataDe = $("dataDeAuditoria").value;
        var dataAte = $("dataAteAuditoria").value;
        var id = $("idRateio").value;
        console.log(id);
        consultarLog(rotina, id, dataDe, dataAte);

    }

</script>

<style type="text/css">
    <!--
    .style3 {color: #333333}
    .style4 {
        font-size: 14px;
        font-weight: bold;
    }
    .styleValor {
        text-align: right;
    }
    -->
</style>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>Webtrans - Cadastro de Rateio</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>
    <body onload="carregar();
            AlternarAbasGenerico('tdAbaAuditoria', 'divAuditoria')">
        <img alt="" src="img/banner.gif" width="30%" height="44" align="middle">
        <table class="bordaFina" width="80%" align="center">
            <tr>
                <td width="82%" align="left"> 
                    <span class="style4">Cadastro de Rateio</span>
                </td>
                <td>
                    <input type="button" value=" Voltar " class="inputBotao" onclick="voltar()"/>
                </td>
            </tr>
        </table>
        <br>
        <form action="RateioControlador?acao=${param.acao == 1 ? "cadastrar" : "editar"}" id="formulario" name="formulario" method="post" target="pop" >
            <input type="hidden" id="idplanocusto_despesa" name="idplanocusto_despesa" value="0"/>
            <input type="hidden" id="plcusto_descricao_despesa" name="plcusto_descricao_despesa" value=""/>
            <input type="hidden" id="idveiculo" name="idveiculo" value="0"/>
            <input type="hidden" id="vei_placa" name="vei_placa" value=""/>
            <input type="hidden" id="idfilial2" name="idfilial2" value="0"/>
            <input type="hidden" id="fi_abreviatura2" name="fi_abreviatura2" value=""/>
            <input type="hidden" id="id_und" name="id_und" value="0"/>
            <input type="hidden" id="sigla_und" name="sigla_und" value=""/>
            <input type="hidden" id="max" name="max" value="0"/>

   <table width="80%" align="center" class="bordaFina" >
                <tr class="tabela">
                    <td colspan="2" align="center">Dados principais</td>
                </tr>
                <tr>
                    <td class="CelulaZebra2" >           
                        <table aling ="right" width="80%" class="tabelaZerada">
                            <tr>
                            <input type="hidden" id="idRateio" name="idRateio" value="${cadRateio.id}">
                            <td width="10%" align="center" class="TextoCampos" >*Descri&ccedil;&atilde;o:</td>
                            <td width="10%" align="center" class="CelulaZebra2">
                                <input name="descricao" id="descricao" type="text" class="inputTexto" size="50" maxlength="120" value="${cadRateio.descricao}"/>
                            </td>
                </tr>
            </table>                       
        </td>
    </tr>
    <tr>
        <td>    
            <table class="bordaFina" align="center" width="100%" >
                <tbody id="tbBase" name="tbBase">
                    <tr>
                        <td class="CelulaZebra2" colspan="6">
                            <input id="btAddPl" class="botoes" type="button" value="Adicionar apropriações" onclick="addItems();">
                        </td>                    
                    </tr>
                    <tr class="tabela">                    
                        <td>Plano centro de custo</td>                    
                        <td>Perc %</td>
                        <td>Veículo</td>
                        <td>Filial</td>
                        <td>Filial 	Und. Custo</td>
                        <td></td>
                    </tr>
                </tbody>   
            </table>
        </td>
    </tr>    
</table>    
<table align="center" width="80%" >
    <tr>
        <td width="100%">
            <table align="left">
                <tr>
                    <td style='display:${ param.acao == 2 && param.nivel == 4 ? "" : "none"}' id="tdAbaAuditoria" name="tdAbaAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAbaAuditoria', 'divAuditoria')"> Auditoria</td>
                </tr>
            </table>
        </td> 
    </tr>
</table>
<div id="divAuditoria" >                    
    <table width="80%" class="bordaFina" align="center" style='display:${ param.acao == 2 && param.nivel == 4 ? "" : "none"}'>                         
        <tr>
            <td> 
                <%@include file="/gwTrans/template_auditoria.jsp" %>
            </td>
        </tr>
        <tr>
            <td colspan="8"> 
                <table width="100%" align="center" class="bordaFina">
                    <tr class="CelulaZebra2">
                        <td class="TextoCampos" width="15%"> Incluso:</td>

                        <td width="35%" class="CelulaZebra2"> em: ${cadRateio.criadoEm} <br>
                            por: ${cadRateio.criadoPor.nome} 
                        </td>

                        <td width="15%" class="TextoCampos"> Alterado:</td>
                        <td width="35%" class="CelulaZebra2"> em: ${cadRateio.atualizadoEm} <br>
                            por: ${cadRateio.atualizadoPor.nome}
                        </td>
                    </tr>   
                </table>                  
            </td>
        </tr>
    </table>
</div>  
<br/>                        
<table width="80%" class="bordaFina" align="center" style='display:${param.nivel >= 2 ? "" : "none"}'>                 
    <tr>
        <td class="CelulaZebra2" >
            <div align="center">
                <input type="button" value="  SALVAR  " id="botSalvar" class="inputbotao" onclick="tryRequestToServer(function () {
                            salvar()
                        })"/>
            </div>
        </td>
    </tr>
</table>
</form>
</body>
</html>

