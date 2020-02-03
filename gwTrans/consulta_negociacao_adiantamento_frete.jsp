<%-- 
    Document   : consulta_negociacao_adiantamento_frete
    Created on : 15/09/2016, 16:10:59
    Author     : Marcos Paulo
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<link href="estilo.css" rel="stylesheet" type="text/css">
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>

<script type="text/javascript" language="JavaScript">  
    jQuery.noConflict();
    
    function desativarBotoes(){
        var atual = '<c:out value="${param.paginaAtual}"/>';
        var paginas = '<c:out value="${param.paginas}"/>';
                
        if(atual == '1'){   
            document.formularioAnt.botaoAnt.disabled = true;
        }   
        if(parseFloat(atual) >= parseFloat(paginas)){
            document.formularioProx.botaoProx.disabled = true;
        }
        document.formulario.valorConsulta.focus();
    }
            
    function setDefault(){
        document.formulario.limiteResultados.value = '<c:out value="${param.limiteResultados}"/>';                
        document.formulario.operadorConsulta.value = '<c:out value="${param.operadorConsulta}"/>';               
        document.formulario.campoConsulta.value = '<c:out value="${param.campoConsulta}"/>';
        document.formulario.valorConsulta.value = '<c:out value="${param.valorConsulta}"/>';

    }
       
    function abrirCadastro(){
        window.location = "NegociacaoAdiantamentoFreteControlador?acao=novoCadastro";
    }          

    function excluir(id){       
        if(confirm("Deseja excluir a negociação?" )){
            if(confirm("Tem certeza?" )){
                window.open("NegociacaoAdiantamentoFreteControlador?acao=excluir&idNegociacao=" + id,
                "pop", "width=210, height=100");
            }
        }
    }
    
</script>
<style type="text/css">
        <!--
        .style3 {color: #333333}
        .style4 {
            font-size: 14px;
            font-weight: bold;
        }
        -->
    </style>
<html>
    <head>
        <title>Webtrans - Consulta de Negociação do Adiantamento de Frete</title>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    </head>
    <body onload="desativarBotoes(), setDefault()"  > 
        <img src="img/banner.gif" width="20%" height="44">
        <table class="bordaFina" width="60%" align="center">
            <tr>
                <td width="82%" align="left"><b><b><span class="style4">Consulta de Negociação do Adiantamento de Frete</span></b></td>
                <td width="18%">
                    <c:if test="${param.nivel >= 3}">
                        <input name="cadastrar" type="button" class="inputbotao"  onclick="tryRequestToServer(function(){abrirCadastro();});" value="Novo Cadastro"/>
                    </c:if> 
                </td>
            </tr>
        </table>
        <br>
        <form action="NegociacaoAdiantamentoFreteControlador?acao=listar" id="formulario" name="formulario" method="post">
            <table class="bordaFina" width="60%" align="center">
                <tr>
                    <td width="97" class="CelulaZebra1">
                        
                        <select name="campoConsulta"  id="campoConsulta" class="inputtexto">
                            <option value="descricao">Descrição</option>
                        </select>             
                    </td>
                    <td width="183" class="CelulaZebra1" height="20">
                        <select name="operadorConsulta" id="operadorConsulta" class="inputtexto">
                            <option value="1" selected>Todas as partes com</option>
                            <option value="2">Apenas com in&iacute;cio</option>
                            <option value="3">Apenas com o fim</option>
                            <option value="4">Igual &agrave; palavra/frase</option>
                        </select>
                    </td>
                    
                    <td width="183" class="CelulaZebra1">
                        <input name="valorConsulta" type="text" class="inputtexto"  id="valorConsulta" size="25" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();">
                    </td>
                    <td width="15" class="CelulaZebra1"><input name="pesquisar" id="pesquisar" type="button" class="inputbotao" value="  Pesquisar  " onclick="tryRequestToServer(function(){document.formulario.submit();});" /></td>
                    
                    <td width="186" class="CelulaZebra1">  
                        <select   name="limiteResultados"  class="inputtexto">
                            <option value="10">10 Resultados</option>
                            <option value="20">20 Resultados</option>
                            <option value="30">30 Resultados</option>
                            <option value="40">40 Resultados</option>
                            <option value="50">50 Resultados</option>
                        </select>
                        
                    </td>
                </tr>
            </table>
        </form>
        <table width="60%" border="0" cellpadding="2" cellspacing="1" class="bordaFina" align="center">
            <tr>                
                <td class="tabela" width="75%" align="left">DESCRIÇÃO</td>
                <td class="tabela" width="5%" align="left"></td>                
            </tr>
            <c:forEach var="negociacao" varStatus="status" items="${listaListNegociacao}">             
                <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" >                    
                    <td colspan="${ param.nivel >= 4 ? '' : "2"}">
                        <a href="javascript: tryRequestToServer(function(){window.location='NegociacaoAdiantamentoFreteControlador?acao=carregar&idNegociacao=${negociacao.id}';});" class="linkEditar">${negociacao.descricao}</a></td>
                    <td align="center" style="display:${ param.nivel >= 4 ? "" : "none"}">
                            <a href="javascript: tryRequestToServer(function(){excluir('${negociacao.id}');});"> <img class="imagemLink" src="img/lixo.png"/> </a>                     
                    </td>
                </tr>
            </c:forEach>
        </table>
        <br>
        <table class="bordaFina" width="60%" align="center" >
            <tr class="CelulaZebra1">
                <td width="50%" align="center">Total de Ocorr&ecirc;ncias: 
                  <c:out value="${param.qtdResultados}"/></td>
                <td width="20%" align="center">P&aacute;ginas: 
                  <c:out value="${param.paginaAtual} / ${param.paginas}"/></td>
                
                
                <form id="formularioAnt" name="formularioAnt" action="NegociacaoAdiantamentoFreteControlador?acao=listar" method="post">
                    <td width="15%" align="center">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>"/>
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>"/>
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>"/>
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>"/>
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual - 1}'/>"/>
                        <input name="botaoAnt" type="button" class="inputbotao" id="botaoAnt" onclick="tryRequestToServer(function(){document.formularioAnt.submit();});" value="ANTERIOR"/>
                    </td>
                </form>
                <form id="formularioProx" name="formularioProx"  action="NegociacaoAdiantamentoFreteControlador?acao=listar" method="post">
                    <td width="15%" align="center">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>">
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>">
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>">
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>">
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual + 1}'/>">
                        <input name="botaoProx" type="button" class="inputbotao" id="botaoProx" onclick="tryRequestToServer(function(){document.formularioProx.submit();});" value="PROXIMA">
                    </td>
                </form>
            </tr>
        </table>
    </body>
</html>