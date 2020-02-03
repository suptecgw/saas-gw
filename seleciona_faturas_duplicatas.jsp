<%-- 
    Document   : seleciona_faturas
    Created on : 26/05/2014, 08:55:17
    Author     : paulo
--%>

<%@page import="java.util.Date"%>
<%@page import="conhecimento.duplicata.fatura.BeanConsultaFatura"%>
<%@page import="java.util.Collection"%>
<%@page import="nucleo.Apoio"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript" src="script/prototype.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<%
    if(Apoio.getUsuario(request) == null){
        response.sendError(response.SC_FORBIDDEN, "É preciso estar logado no sistema para ter acesso a esta página.");
    }
    
    Collection faturas = null;
    String acao = request.getParameter("acao");
    
    if(acao.equals("consultar")){       
        
        Date dataInicio = Apoio.paraDate(request.getParameter("dataInicio"));        
        Date dataFim = Apoio.paraDate(request.getParameter("dataFim"));
        String numeroFatura = request.getParameter("numeroFatura");
        
        BeanConsultaFatura consulta = new BeanConsultaFatura();
        faturas = consulta.localizarFaturasDuplicatas(dataInicio, dataFim, numeroFatura);        
        request.setAttribute("faturas", faturas);        
        
    }    
    
%>
<script language="javascript" type="text/javascript"> 
    function fechar(){
        window.close();
    }
    
    function localizaFatura(){
        
        var dataInicio = $("dataInicio").value;
        var dataFim = $("dataFim").value;
        var numeroFatura = $("numeroFatura").value;
        
        location.replace("./seleciona_faturas_duplicatas.jsp?acao=consultar&dataInicio="+dataInicio+"&dataFim="+dataFim+"&numeroFatura="+numeroFatura);
    }
    function checkTodasFaturas(){

        var max = $("max").value;
        if($("chkTodos").checked){
            for(var i = 1; i <= max; i++){                
                $("chk_"+i).checked = true;
            }
        }else{
            for(var i = 1; i <= max; i++){
                $("chk_"+i).checked = false;
            }
            
        }
    }
    
    function selecionarFaturas(){        
        if($("max") == null || $("max") == undefined){
            alert("Selecione no mínimo uma fatura!");
            return false;
        }
        var max = $("max").value;
        var idFatura;
        var numeroFatura;
        var cliente;
        var venceEm;
        var valorLiquido;
        var nossoNumero;
        var valor;
        var idConta;
        var retorno = 0;
            for(var i = 1; i <= max; i++){
                if($("chk_"+i).checked){
                    var campo = $("chk_"+i).value;                
                    for(var x = 0; x < campo.split("!!").length; x++){   
                        retorno++;
                        idFatura = campo.split("!!")[0];
                        numeroFatura = campo.split("!!")[1] + "/" + campo.split("!!")[2];
                        cliente = campo.split("!!")[3];
                        venceEm = campo.split("!!")[4];
                        valorLiquido = campo.split("!!")[5];
                        nossoNumero = campo.split("!!")[6];
                        valor = campo.split("!!")[7];
                        idConta = campo.split("!!")[8];                  
                    }                    
                     var faturaInclusa = window.opener.addFatura(idFatura,numeroFatura,cliente,venceEm,valorLiquido,nossoNumero,valor,idConta);
                     if(faturaInclusa == false){
                         return alert("A Fatura/Boleto "+numeroFatura+" já foi inclusa.");
                     }
                }
            }
            if(retorno == 0){
                alert("Selecione no mínimo uma fatura!");
                return false;
            }
            window.close();
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
        <meta http-equiv="content-language" content="pt">
        <meta name="language" content="pt-br">
        <title>WebTrans - Selecionar Faturas</title>
        <link href="./estilo.css" rel="stylesheet" type="text/css">        
    </head>
    <body>
        <img src="img/banner.gif">
        <br>
        <table align="center" width="95%" class="bordaFina">
            <tr>
                <td width="82%" align="left"><span class="style4">Selecionar Faturas para Duplicatas</span></td>
                <td>
                    <input id="cancelar" name="cancelar" type="button" value="Fechar" class="inputbotao" onclick="javascript:fechar();">
                </td>
            </tr>
        </table>        
        <br>
        <table align="center" width="95%" class="bordaFina">
            <tr class="CelulaZebra2">                
                <td class="TextoCampos">
                    <label>Intervalo de Data:</label>
                </td>
                <td>
                    <input type="text" id="dataInicio" name="dataInicio" class="fieldDate" value="<%=(request.getParameter("dataInicio") != null ? request.getParameter("dataInicio") : Apoio.getDataAtual())%>"
                           onblur="alertInvalidDate(this)" onkeydown="fmtDate(this, event)" onkeyup="fmtDate(this, event)" onkeypress="fmtDate(this, event)" size="8" maxlength="10">
                    <label>e</label>
                    <input type="text" id="dataFim" name="dataFim" class="fieldDate" value="<%=(request.getParameter("dataFim") != null ? request.getParameter("dataFim") : Apoio.getDataAtual())%>"
                           onblur="alertInvalidDate(this)" onkeydown="fmtDate(this, event)" onkeyup="fmtDate(this, event)" onkeypress="fmtDate(this, event)" size="8" maxlength="10">
                </td>                
                <td>
                    <input type="button" id="pesquisar" name="pesquisar" value="Pesquisar" class="inputbotao" onclick="javascript:localizaFatura();">
                </td>
            </tr>
            <tr class="CelulaZebra2">
                <td class="textoCampos">
                    <label>Numero Fatura:</label>
                </td>
                <td colspan="2">
                    <div align="left">
                        <input type="text" id="numeroFatura" name="numeroFatura" class="inputtexto" value="<%=(request.getParameter("numeroFatura") != null ? request.getParameter("numeroFatura") : "")%>">
                    </div>
                </td>
            </tr>
        </table>
        <br>
        <table align="center" width="95%" class="bordaFina">
            <tr>
                <td class="tabela"><input type="checkbox" id="chkTodos" name="chkTodos" onclick="javascript:checkTodasFaturas()"></td>
                <td class="tabela">Número</td>
                <td class="tabela">Emisão</td>
                <td class="tabela">Cliente</td>
                <td class="tabela">Vencimento</td>
                <td class="tabela">Conta Bancária</td>
                <td class="tabela">Valor</td>
            </tr>
            <c:forEach var="faturas" varStatus="status" items="${faturas}">
                <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}">
                    <td align="center">
                        <input type="checkbox" id="chk_${status.count}" name="chk_${status.count}" 
                               value="${faturas.id}!!${faturas.numero}!!${faturas.anoFatura}!!${faturas.cliente.razaosocial}!!${faturas.venceEm}!!${faturas.valorLiquido}!!${faturas.boletoNossoNumero}!!${faturas.valorLiquido}!!${faturas.conta.idConta}">
                    </td>
                    <td align="center">${faturas.numero}/${faturas.anoFatura}</td>
                    <td align="center"><fmt:formatDate pattern="dd/MM/yyyy" value="${faturas.emissaoEm}" /></td>
                    <td>${faturas.cliente.razaosocial}</td>
                    <td align="center"><fmt:formatDate pattern="dd/MM/yyyy" value="${faturas.venceEm}" /></td>
                    <td align="center">${faturas.conta.numero}</td>                    
                    <td align="right"><fmt:formatNumber value="${faturas.valorLiquido}" pattern="#,##0.00#"/></td>
                    <c:if test="${status.last}">
                        <input type="hidden" id="max" name="max" value="${status.count}"/>
                    </c:if>
                </tr>
            </c:forEach>
                <tr>
                    <td colspan="7" class="CelulaZebra1">
                        <div align="center">
                            <input type="button" id="selecionarFaturas" name="selecionarFaturas" class="inputbotao" value="Selecionar Faturas" onclick="javascript:selecionarFaturas()">
                        </div>
                    </td>
                </tr>
        </table>
    </body>
</html>
