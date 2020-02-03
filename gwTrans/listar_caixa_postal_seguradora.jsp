<%-- 
    Document   : listar_caixa_postal_seguradora
    Created on : 26/05/2015, 09:56:58
    Author     : eli
--%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<LINK REL="stylesheet" HREF="../estilo.css" TYPE="text/css">
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/jquery.js" type="text/javascript"></script>
<script type="text/javascript" language="JavaScript">
    shortcut.add("enter",function() {pesquisa()});
    
    function pesquisa() {
        document.formulario.submit();
    }
    
    function excluir(id, descricao) {
        if(confirm("Deseja excluir a caixa postal de seguradora "+descricao+"?")){
            if(confirm("Tem certeza?")){
                window.open("CaixaPostalSeguradoraControlador?acao=excluir&id="+id+"&descricao="+descricao, "pop", "width=210, height=100");
            }
        }
    }
    
    function abrirCadastro() {
    window.location = "CaixaPostalSeguradoraControlador?acao=novoCadastro", "cadcaixapostalseg";
}

 function desativarBotoes(){
       
        var atual = '<c:out value="${param.paginaAtual}"/>';
        var paginas = '<c:out value="${param.paginas}"/>';
                
                
        if(atual == '1'){   
            desabilitar(document.formularioAnt.botaoAnt, "#2E76A6");
        }   
        if(parseFloat(atual) >= parseFloat(paginas)){
            desabilitar(document.formularioProx.botaoProx, "#2E76A6");
        }

        document.formulario.valorConsulta.focus();
        
    }
            
    function setDefault(){
        $("limiteResultados").value = '<c:out value="${param.limiteResultados}"/>';                
        $("operadorConsulta").value = '<c:out value="${param.operadorConsulta}"/>';               
        $("campoConsulta").value = '<c:out value="${param.campoConsulta}"/>';
        document.getElementById("valorConsulta").value = '<c:out value="${param.valorConsulta}"/>';
        $("dataDe").value = '<c:out value="${param.dataDe}"/>';
        $("dataAte").value = '<c:out value="${param.dataAte}"/>';
    }


</script>

<!DOCTYPE html>
<html>
    <style>
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
        <title>WebTrans - Consulta de Caixa Postal de Seguradora</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>
    <body onload="desativarBotoes();applyFormatter();setDefault();">
        <img alt="" src="img/banner.gif" width="25%" height="44" align="middle">
        <table class="bordaFina" width="60%" align="center">
            <tr>
                <td width="52%" align="left"> 
                    <span class="style4">Consulta de Caixa Postal de Seguradora</span>
                </td>
                <td width="18%" align="right">
                    <c:if test="${param.nivel > 2}">
                        <input name="cadastrar" type="button" class="inputbotao"  onclick="abrirCadastro();" value="Novo Cadastro"/>
                    </c:if>
                </td>
            </tr>
        </table>
        <br>
     <table class="bordaFina" width="60%" align="center">
     <form action="CaixaPostalSeguradoraControlador?acao=listar" id="formulario" name="formulario" method="post">
                <tr>
                    <td width="2%" class="CelulaZebra1">
                        <select name="campoConsulta" class="inputtexto"  id="campoConsulta"  style="width: 80px;">
                            <option value="cps.descricao">Descrição</option>
                        </select>
                        <input type="hidden" name="modulo" id="modulo" value="" />
                    </td>
                    <td width="5%" class="CelulaZebra1" height="20">
                        <select name="operadorConsulta" class="inputtexto" id="operadorConsulta" >
                            <option value="1" selected>Todas as partes com</option>
                            <option value="2">Apenas com in&iacute;cio</option>
                            <option value="3">Apenas com o fim</option>
                            <option value="4">Igual &agrave; palavra/frase</option>
                        </select>
                    </td>
                    <td class="CelulaZebra1">
                        <div id="div1" >
                            <input name="valorConsulta" type="text" class="inputtexto"  id="valorConsulta" size="24">
                        </div>
                    </td>
                    <td width="3%" class="CelulaZebra1NoAlign" align="center"><input name="pesquisar" type="button" class="inputbotao" value="Pesquisar" onclick="javascript: tryRequestToServer(function(){pesquisa();})"  /></td>
                    <td width="8%" class="CelulaZebra1">
                        <select id="limiteResultados"  name="limiteResultados" class="inputtexto"  >
                            <option value="10">10 Resultados</option>
                            <option value="20">20 Resultados</option>
                            <option value="30">30 Resultados</option>
                            <option value="40">40 Resultados</option>
                            <option value="50">50 Resultados</option>
                        </select>
                    </td>
                </tr>
            </form>
        </table>
        <table width="60%" border="0" cellpadding="2" cellspacing="1" class="bordaFina" align="center">
            <tr>                
                <td class="tabela" width="75%" align="left">Descrição</td>
                <td class="tabela" width="5%" align="left"></td>  
            </tr>
            
            <c:forEach var="caixaPostalSeguradora" varStatus="status" items="${listaCaixaPostalSeguradora}">             
                <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" > 
                    <td><a href="javascript: tryRequestToServer(function(){window.location='CaixaPostalSeguradoraControlador?acao=carregar&id=${caixaPostalSeguradora.id}';});" class="linkEditar">${caixaPostalSeguradora.descricao}</a></td>
                    <td align="center"> 
                         <c:if test="${param.nivel > 3}">
                            <a href="javascript: tryRequestToServer(function(){excluir('${caixaPostalSeguradora.id}', '${caixaPostalSeguradora.descricao}');});"> <img class="imagemLink" src="img/lixo.png"/> </a>
                         </c:if>
                    </td>
                </tr>
            </c:forEach>
            
        </table>
        <br>
        <table class="bordaFina" width="60%" align="center" >
            <tr class="CelulaZebra1">
                <td width="37%" align="center">Total de Ocorr&ecirc;ncias:
                    <c:out value="${param.qtdResultados}"/>
                </td>
                <td width="18%" align="center">P&aacute;ginas:
                    <c:out value="${param.paginaAtual} / ${param.paginas}"/>
                </td>
                <td width="15%" align="center">
                    <form id="formularioAnt" name="formularioAnt" action="CaixaPostalSeguradoraControlador?acao=listar" method="post">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>"/>
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>"/>
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>"/>
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>"/>
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual - 1}'/>"/>
                        <input name="botaoAnt" type="button" class="inputbotao" id="botaoAnt" onclick="javascript: tryRequestToServer(function(){document.formularioAnt.submit();});" value="ANTERIOR"/>
                    </form>
                </td>
                <td width="15%" align="center">
                    <form id="formularioProx" name="formularioProx"  action="CaixaPostalSeguradoraControlador?acao=listar" method="post">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>">
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>">
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>">
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>">
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual+ 1}'/>">
                        <input name="botaoProx" type="button" class="inputbotao" id="botaoProx" onclick="javascript: tryRequestToServer(function(){document.formularioProx.submit();});" value="PROXIMA">
                    </form>
                </td>
            </tr>
    </body>
</html>
