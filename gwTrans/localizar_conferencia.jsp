<%-- 
    Document   : listar_Saida
    Created on : 09/02/2009, 15:51:45
    Author     : Vladson Pontes
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<LINK REL="stylesheet" HREF="estilo.css" TYPE="text/css">
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>
<script type="text/javascript" language="JavaScript">
    var countRow = 0;

    function abrirCheckList(idMovimentacao, gem) {
        abrirLocaliza("${homePath}/CheckListControlador?acao=novoCadastro&idMovimentacao=" + idMovimentacao + "&gem=" + gem, "cadCheckList");
    }

    function pesq() {
//        document.formulario.filial.disabled = false;
        document.formulario.submit();
//        document.formulario.filial.disabled = true;
    }

    function limparCliente() {
        document.formulario.cliente.value = "Todos os Clientes";
        document.formulario.idCliente.value = "0";
    }

    function abrirLocalizarCliente() {
        tryRequestToServer(function(){
            popLocate(5, "Cliente","locClienteGSM");
        });
    }

    function habilitaConsultaDePeriodo(opcao) {
        document.getElementById("valorConsulta").style.display = (opcao ? "none" : "");
        document.getElementById("operadorConsulta").style.display = (opcao ? "none" : "");
        document.getElementById("div1").style.display = (opcao ? "" : "none");
        document.getElementById("div2").style.display = (opcao ? "" : "none");
    }

    function desativarBotoes() {
        var atual = '<c:out value="${param.paginaAtual}"/>';
        var paginas = '<c:out value="${param.paginas}"/>';

        if (atual == '1') {
            document.formularioAnt.botaoAnt.disabled = true;
        }

        if (parseFloat(atual) >= parseFloat(paginas)) {
            document.formularioProx.botaoProx.disabled = true;
        }
    }

    function getIndice(produtoId, vlUnitario){
        var pai = window.opener;
        var indice = 0;
        try {
            var maxItem = pai.$("max").value;
            
            for (var i = 1; i <= maxItem; i++) {
                if (pai.$("idProduto_"+i) != null && 
                        pai.$("idProduto_"+i).value == produtoId && 
                        parseFloat(colocarPonto(pai.$("valorUnt_"+i).value)) == parseFloat(vlUnitario)) {
                    indice = i;
                }
            }
            return indice;
        } catch (e) {
            alert("Erro ao pesquisar existencia do item.");
        }
    }

    function retornaPai(labOb) {
        var maxSaida = 0;
        var maxItem = 0;
        var numeroCte = "";
        var pai = window.opener;

        try {
            var index = labOb.id.split("_")[1];
            
            pai.$("idCarga").value = $("cargaId_" + index).value;
            pai.$("numeroCarga").value = $("numeroCarga_" + index).innerHTML;
            
            window.close();
            
        } catch (e) {
            alert("Erro ao adicionar um item." + e);
            console.log("Erro ao adicionar um item." + e);
            console.trace();
        }
    }
    function aoClicarNoLocaliza(idJanela){
        switch(idJanela){
            case "ClientelocClienteGSM":
                $("idCliente").value = $("idconsignatario").value;
                $("cliente").value = $("con_rzs").value;
                break;
        }
    }

    function setDefault() {
        document.formulario.limiteResultados.value = '<c:out value="${param.limiteResultados}"/>';
        document.formulario.operadorConsulta.value = '<c:out value="${param.operadorConsulta}"/>';
        var campoConsulta = '<c:out value="${param.campoConsulta}"/>';
        document.formulario.campoConsulta.value = campoConsulta;
        document.formulario.valorConsulta.value = '<c:out value="${param.valorConsulta}"/>';
        document.formulario.entradaDe.value = '<c:out value="${param.entradaDe}"/>';
        document.formulario.entradaAte.value = '<c:out value="${param.entradaAte}"/>';
        document.formulario.idCliente.value = '<c:out value="${param.idCliente}"/>';
        document.formulario.cliente.value = '<c:out value="${param.cliente}"/>';
//        document.formulario.filial.value = '<:out value="{autenticado.filial.id}"/>';

        if (campoConsulta == 'cc.transmitido_at') {
            habilitaConsultaDePeriodo(true);
        }
        var nivel = parseInt('<c:out value="${param.nivelFilial}"/>');
        if (nivel >= 1) {
//            document.formulario.filial.disabled = false;
//            document.formulario.filial.value = 'c:out value="{param.filial}"/>';
        }
    }

    function selecionarTudo() {
        if ($("cktudo").checked) {
            for (var i = 1; i <= $("max").value; i++) {
                $("chk_" + i).checked = true;
            }
        } else {
            for (var i = 1; i <= $("max").value; i++) {
                $("chk_" + i).checked = false;
            }
        }

    }

</script>
<style  type="text/css">
    <!--
    .style3 {color: #333333}
    .style4 {
        font-size: 14px;
        font-weight: bold;
    }

    .style5 {
        color:red;
    }
    -->
</style>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>Webtrans - Carga</title>
    </head>
    <body onload="desativarBotoes(), setDefault(), applyFormatter()"  >
        <img src="img/banner.gif" >
        <table class="bordaFina" width="70%" align="center">
            <tr>
                <td width="72%" align="left"> 
                    <span class="style4">Localizar Carga</span>
                </td>
            </tr>
        </table>
        <br>
        <form action="${homePath}/ConhecimentoControlador?acao=localizarCarga" id="formulario" name="formulario" method="post">
            <table class="bordaFina" width="70%" align="center">
                <tr>
                    <td width="15%" class="CelulaZebra1">
                        <select name="campoConsulta" class="inputtexto"  id="campoConsulta" onchange="habilitaConsultaDePeriodo(this.value == 'cc.transmitido_at')">
                            <option value="cc.numero_carga">Número Carga</option>
                            <option selected value="cc.transmitido_at">Dt. Transmissão</option>
                            <option value="rem.razaosocial">Remetente</option>
                            <option value="des.razaosocial">Destinatario</option>
                        </select>
                    </td>
                    <td width="25%" class="CelulaZebra1" height="20">
                        <div id="div1" style="display:none">
                            De:
                            <input name="entradaDe" type="text" id="entradaDe" size="10" maxlength="10"  class="fieldDate" onblur="alertInvalidDate(this)">
                        </div>
                        <select name="operadorConsulta" id="operadorConsulta" class="inputtexto">
                            <option value="1" selected>Todas as partes com</option>
                            <option value="2">Apenas com in&iacute;cio</option>
                            <option value="3">Apenas com o fim</option>
                            <option value="4">Igual &agrave; palavra/frase</option>
                        </select>
                    </td>
                    <td width="25%" class="CelulaZebra1">
                        <div id="div2" style="display:none ">
                            At&eacute;:
                            <input name="entradaAte" type="text" id="entradaAte" size="10" maxlength="10" onblur="alertInvalidDate(this)" class="fieldDate">
                        </div>
                        <input name="valorConsulta" type="text" class="inputtexto"  id="valorConsulta" size="25">
                    </td>
                    <td width="15%" class="CelulaZebra1">
                        <select   name="limiteResultados" class="inputtexto" >
                            <option value="10">10 Resultados</option>
                            <option value="20">20 Resultados</option>
                            <option value="30">30 Resultados</option>
                            <option value="40">40 Resultados</option>
                            <option value="50">50 Resultados</option>
                        </select>
                    </td>
                    <td width="20%" class="CelulaZebra1NoAlign" align="center" rowspan="2">
                        <input name="pesquisar" type="button" class="inputbotao" value="  Pesquisar  " onclick="tryRequestToServer(function(){
                                    pesq();
                                });" />
                    </td>
                </tr>
                <tr>
                    <td  class="CelulaZebra1" colspan="2">
                        <input name="cliente" id="cliente" class="inputReadOnly" value=" Cliente" size="30" type="text" readonly>
                        <input name="idCliente" id="idCliente" value="0" type="hidden">
                        <input name="idconsignatario" id="idconsignatario" value="0" type="hidden">
                        <input name="con_rzs" id="con_rzs" value="0" type="hidden">
                        <input value="..." class="inputBotaoMin" type="button" onclick="abrirLocalizarCliente()">
                        <img alt="borracha" src="${homePath}/img/borracha.gif" id="borracha" onclick="limparCliente()" class="imagemLink"/>
                    </td>
                    <td  class="CelulaZebra1" colspan="2">
                    </td>
                </tr>

            </table>
        </form>
        <form action=""  method="post" name="formMatricial" id="formMatricial">
            <table width="70%"  class="bordaFina" align="center" style="vertical-align:top">
                <tr>
                    <td class="tabela" width="3%" align="left">
                        <input type="checkbox" name="cktudo" id="cktudo" onclick="selecionarTudo()">
                    </td>
                    <td class="tabela" width="8%" align="left" >Nº Carga</td>
                    <td class="tabela" width="11%" align="left" >Dt. Transmissão</td>
                    <td class="tabela" width="10%" align="left"></td>
                    <td class="tabela" width="30%" align="left" >Remetente</td>
                    <td class="tabela" width="30%" align="left" >Destinatario</td>
                </tr>
                <c:forEach var="carga" varStatus="status" items="${listaListCargas}">
                    <tr id='trCarga_${status.count}' onclick="retornaPai(this)"
                        class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')} linkEditar" >
                        <td style="display:none ">
                            <script type="text/javscript">countRow++;</script>
                        </td>
                        <td >
                            <label id="numeroCarga_${status.count}">${carga.numeroCarga}</label>
                            <input type="hidden" name="cargaId_${status.count}" id="cargaId_${status.count}" value="${carga.id}" />
                        </td>
                        <td >${carga.transmitidoAt}</td>
                        <td>
                        </td>
                        <td >${carga.remetente.razaosocial}</td>
                        <td >${carga.destinatario.razaosocial}</td>
                    </tr>
                    <c:if test="${status.last}">
                        <tr style="display:none">
                            <td>
                                <input type="hidden" name="max" id="max" value="${status.count}">
                            </td>
                        </tr>
                    </c:if>
                </c:forEach>
            </table>
        </form>
        <table class="bordaFina" width="70%" align="center" >
            <tr class="CelulaZebra1">
                <td width="54%" align="center">
                    Total de Ocorr&ecirc;ncias
                    <c:out value="${param.qtdResultados}"/>
                </td>
                <td width="19%" align="center">
                    P&aacute;ginas
                    <c:out value="${param.paginaAtual} / ${param.paginas}"/>
                </td>
                <td width="13%" align="center">
                    <form id="formularioAnt" name="formularioAnt" action="${homePath}/ConhecimentoControlador?acao=localizarCarga" method="post">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>"/>
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>"/>
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>"/>
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>"/>
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual - 1}'/>"/>
                        <input type="hidden" name="entradade" value="<c:out value="${param.entradaDe}"/>">
                        <input type="hidden" name="entradaAte" value="<c:out value="${param.entradaAte}"/>">
                        <input name="botaoAnt" type="button" class="inputbotao" id="botaoAnt" onclick="javascript: tryRequestToServer(function() {
                                    document.formularioAnt.submit();
                                });" value="ANTERIOR"/>
                    </form>
                </td>
                <td width="14%" align="center">
                    <form id="formularioProx" name="formularioProx"  action="${homePath}/ConhecimentoControlador?acao=localizarCarga" method="post">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>">
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>">
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>">
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>">
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual+ 1}'/>">
                        <input type="hidden" name="entradade" value="<c:out value="${param.entradaDe}"/>">
                        <input type="hidden" name="entradaAte" value="<c:out value="${param.entradaAte}"/>">
                        <input name="botaoProx" type="button" class="inputbotao" id="botaoProx" onclick="javascript: tryRequestToServer(function(){
                                    document.formularioProx.submit();
                                });" value="PROXIMA">
                    </form>
                </td>
            </tr>
            <tr>
                <td  class="CelulaZebra1NoAlign" align="center" colspan="5">
                    <input value="SELECIONAR" class="inputbotao" type="button" onclick="retornaPai();">
                </td>
            </tr>
        </table>
    </body>
</html>