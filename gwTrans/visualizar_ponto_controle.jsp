<%-- 
    Document   : visualizar_ponto_controle
    Created on : 25/05/2016, 11:17:36
    Author     : anderson
--%>


<%@page import="nucleo.BeanLocaliza"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">

<link href="estilo.css" rel="stylesheet" type="text/css">
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>

<script type="text/javascript" language="JavaScript" charset="Iso-8859-1">
    function localizar(idLista,nomeJanela){
            window.open('./localiza?acao=consultar&idlista='+idLista,nomeJanela,'top=80,left=150,height=400,width=800,resizable=yes,status=1,scrollbars=1');
    }
    
    function aoClicarNoLocaliza(janela){
        if (janela == 'motorista') {
            $("motoristaId").value = $("idmotorista").value;
            $("nomeMotorista").value = $("motor_nome").value;
    
        }
    }
  
  function submeter(){
      $("formulario").submit();
  }
  
  function abrirLocalizacaoMapa(latitude, longitude, precisao) {
    if (latitude == null || latitude == 0 || longitude == null || longitude == 0)
        return null;
    var url = "http://maps.google.com/maps?q=" + latitude + ",+" + longitude;
    window.open(url, "googMaps", "toolbar=no,location=no,scrollbars=no,resizable=no");
}


    function imprimir() {
        var dataDe = $("dataDe").value;
        var dataAte = $("dataAte").value;
        var motorista = $("motoristaId").value;
        var nCTe = $("numeroCTe").value;
        var nNFe = $("numeroNFe").value;
        var tipo = $("chkCTe").checked ? "cte" : ($("chkMotorista").checked ? "motorista" : "nfe");
        
        var impressao;
          if ($("pdf").checked)
            impressao = "1";
          else if ($("excel").checked)
            impressao = "2";
        
        var formulario = $("formularioImpressao");
        
        
        var janela = window.open('about:blank', 'pop1', 'titlebar=no, menubar=no, scrollbars=yes, status=yes,  resizable=yes, left=0, top=0');
        formulario.target = "pop1";
        formulario.action = '${homePath}/RelatorioControlador?acao=pontocontrole&modelo=pontoControle_mod1&dataDe='+dataDe+'&dataAte='+dataAte+
                '&motoristaId='+motorista+'&ncte='+nCTe+'&nnfe='+nNFe+"&tipoPesquisa="+tipo+"&impressao="+impressao;;
        formulario.method = 'post';
        formulario.submit();
    }

</script>

<html>
    <style type="text/css">
        <!--
        .style3 {color: #333333}
        .style4 {
            font-size: 14px;
            font-weight: bold;
        }
        -->
    </style>
    
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>Webtrans - Visualizar de Ponto de Controle</title>
        
    </head>
    
    <input type="hidden" name="motor_nome" id="motor_nome" value="">
    <input type="hidden" name="idmotorista" id="idmotorista" value="">
    <body onload=""  > 
        <img src="img/banner.gif" width="50%" height="44">
        <table class="bordaFina" width="95%" align="center">
            <tr>
                <td width="82%" align="left"> <span class="style4">Visualizar Pontos de Controle</span></td>
            </tr>
        </table>
        <br>
                <form action="PontoControleControlador?acao=visualizarPontoControle&modulo=gwTrans" id="formulario" name="formulario" method="post">
            <table class="bordaFina" width="95%" align="center">
                <tr class="tabela">
                    <td colspan="10">
                        <div align="center">
                            <strong>Pontos de Controle</strong>
                        </div>
                    </td>
                </tr>
                <tr class="CelulaZebra2">
                    <td>
                        Entre:
                    </td>
                    <td colspan="2">
                        <input type="text" name="dataDe" id="dataDe" value="${param.dataDe}" class="inputTexto" size="10" maxlength="10" onkeydown='fmtDate(this, event)' onblur='alertInvalidDate(this);'> e 
                        <input type="text" name="dataAte" id="dataAte" value="${param.dataAte}" class="inputTexto" size="10" maxlength="10" onkeydown='fmtDate(this, event)' onblur='alertInvalidDate(this);'>
                    </td>
                    <td colspan="7">
                        <input type="button" name="" id="" value=" Pesquisar " class="inputBotao" onclick="javascript:submeter();">
                    </td>
                </tr>
                <tr class="celulaZebra2">
                    <td width="6%"><!--motorista-->
                        <input type="radio" name="tipoPesquisa" id="chkMotorista" value="motorista" ${param.tipoConsulta == "motorista" || param.tipoConsulta == "" ? "checked" : ""}>Motorista
                    </td>
                    <td width="10%"><!--motorista-->
                        <input type="hidden" name="motoristaId" id="motoristaId" value="${param.idMotorista != "" ? param.idMotorista : ""}">
                        <input name="nomeMotorista" type="text" id="nomeMotorista" class="inputReadOnly" value="${param.nomeMotorista != "" && param.nomeMotorista != null && param.nomeMotorista != "null" ? param.nomeMotorista : ""}" size="20" readonly="true">
                        <input name="localiza_motorista" type="button" class="inputBotaoMin" id="localiza_motorista" value="..." onClick="javascript:localizar('10','motorista');">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Carreta" onClick="javascript:getObj('motoristaId').value = 0;javascript:getObj('nomeMotorista').value = '';">
                    </td>
                    <td width="5%"><!--numero cte-->
                        <input type="radio" name="tipoPesquisa" id="chkCTe" value="cte" ${param.tipoConsulta == "cte" ? "checked" : ""}>Nº CT-e
                    </td>
                    <td width="4%"><!--numero cte-->
                        <input type="text" name="numeroCTe" id="numeroCTe" value="${param.numeroCTe == "" || param.numeroCTe == null || param.numeroCTe == 'null' ? "" : param.numeroCTe}" class="inputTexto" size="8">
                    </td>
                    <td width="5%"><!--numero nfe-->
                        <input type="radio" name="tipoPesquisa" id="chkNFe" value="nfe" ${param.tipoConsulta == "nfe" ? "checked" : ""}>Nº NF-e
                    </td>
                    <td width="6%"><!--numero nfe-->
                        <input type="text" name="numeroNFe" id="numeroNFe" value="${param.numeroNFe == "" || param.numeroNFe == null || param.numeroNFe == 'null'  ? "" : param.numeroNFe}" class="inputTexto" size="8">
                    </td>
                    <td width="8%"><!--numero manifesto-->
                        <input type="radio" name="tipoPesquisa" id="chkManifesto" value="manif" ${param.tipoConsulta == "manif" ? "checked" : ""}>Nº Manifesto
                    </td>
                    <td width="6%"><!--numero manifesto-->
                        <input type="text" name="numeroManifesto" id="numeroManifesto" value="${param.numeroManifesto == "" || param.numeroManifesto == null || param.numeroManifesto == 'null'  ? "" : param.numeroManifesto}" class="inputTexto" size="8">
                    </td>
                    <td width="8%"><!--numero romaneio-->
                        <input type="radio" name="tipoPesquisa" id="chkRomaneio" value="roman" ${param.tipoConsulta == "roman" ? "checked" : ""}>Nº Romaneio
                    </td>
                    <td width="6%"><!--numero romaneio-->
                        <input type="text" name="numeroRomaneio" id="numeroRomaneio" value="${param.numeroRomaneio == "" || param.numeroRomaneio == null || param.numeroRomaneio == 'null'  ? "" : param.numeroRomaneio}" class="inputTexto" size="8">
                    </td>
                </tr>
            
            
            </table>
        </form>
        <%--listatudo--%>
        <table width="95%" border="0" cellpadding="2" cellspacing="1" class="bordaFina" align="center">
            <tr class="tabela">  
                <td width="6%">
                    Tipo
                </td>
                <td width="18%">
                    Motorista
                </td>
                <td width="15%">
                    Descrição
                </td>
                <td width="8%">
                    N. NF-e
                </td>
                <td width="8%">
                    N. CT-e
                </td>
                <td width="8%" align="center">
                    Data/Hora<br>Inicio
                </td>
                <td width="8%" align="center">
                    Data/Hora<br>Fim
                </td>
                <td width="10%" >
                    Duração
                </td>
                <td width="10%" >
                    N. Romaneio
                </td>
                <td width="10%" >
                    N. Manifesto
                </td>
            </tr>
            <c:forEach var="pC" varStatus="status" items="${listaPontoControleMobile}">
                <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" >  
                    <td>${pC.pontoControle.tipo == "m" ? "Motorista" : (pC.pontoControle.tipo == "r" ? "Romaneio" : "Entrega")}</td>
                    <td>${pC.motorista.nome}</td>
                    <td>${pC.pontoControle.descricao}</td>
                    <td>${pC.notaFiscal.numero}</td>
                    <td>${pC.sales.numero}</td>
                    <td align="center">${pC.dataInicio.split(" ")[0]}<br>${pC.dataInicio.split(" ")[1]} <img src="img/gmaps.png" width="19" height="19" border="0" class="imagemLink" 
                             title="Visualizar Rotas no Google Maps" onClick="javascript:tryRequestToServer(function () {
                                       abrirLocalizacaoMapa('${pC.latitudeInicio}','${pC.longitudeInicio}');
                                   });"> </td>
                    <td align="center">
                        <div style="display: ${pC.pontoControle.tipo != "m" ? "none" : ""}">
                            ${pC.dataFim.split(" ")[0]}<br>${pC.dataFim.split(" ")[1]} <img src="img/gmaps.png" width="19" height="19" border="0" class="imagemLink" 
                                 title="Visualizar Rotas no Google Maps" onClick="javascript:tryRequestToServer(function () {
                                           abrirLocalizacaoMapa('${pC.latitudeFim}','${pC.longitudeFim}');
                                       });">
                        </div>
                    </td>
                    <td>${pC.duracao}</td>
                    <td>${pC.numeroRomaneio}</td>
                    <td>${pC.numeroManifesto}</td>
                </tr>
            </c:forEach>
        </table>
        <br>
        <form id="formularioImpressao" >
            <table width="95%" border="0" cellpadding="2" cellspacing="1" class="bordaFina" align="center">
                <tr class="CelulaZebra2NoAlign" align="center">
                    <td width="50%">
                    </td>
                    <td>
                        <input type="button" value="Imprimir" class="botoes" onclick="javascript: imprimir();">
                    </td>
                    <td>
                        <div align="center">
                            <input type="radio" name="impressao" id="pdf" value="1" checked/>
                            <img src="./img/pdf.gif" width="19" height="20" style="vertical-align: middle">
                            <input type="radio" name="impressao" id="excel" value="2" />
                            <img src="./img/excel.gif" width="20" height="19"  style="vertical-align: middle">
                        </div>
                    </td>
                </tr>
            </table>        
        </form>
    </body>
</html>
