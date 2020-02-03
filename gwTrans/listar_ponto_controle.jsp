<%-- 
    Document   : listar_ponto_controle
    Created on : 12/04/2016, 12:24:28
    Author     : airton
--%>


<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">

<link href="estilo.css" rel="stylesheet" type="text/css">
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>

<script type="text/javascript" language="JavaScript" charset="Iso-8859-1">
    function desativarBotoes(){
        var atual = '<c:out value="${param.paginaAtual}"/>';
        var paginas = '<c:out value="${param.paginas}"/>';
                
                
        if(atual == '1'){   
            document.formularioAnt.botaoAnt.disabled = true;
        }   
        if(parseFloat(atual) >= parseFloat(paginas)){
            document.formularioProx.botaoProx.disabled = true;
        }
    }
            
    function setDefault(){
        document.formulario.valorConsulta.focus();
        document.formulario.limiteResultados.value = '<c:out value="${param.limiteResultados}"/>';                
        document.formulario.operadorConsulta.value = '<c:out value="${param.operadorConsulta}"/>';               
        document.formulario.campoConsulta.value = '<c:out value="${param.campoConsulta}"/>';
        document.formulario.valorConsulta.value = '<c:out value="${param.valorConsulta}"/>';

    }
       
    function abrirCadastro(){
        window.location = "PontoControleControlador?acao=novoCadastro&modulo=gwTrans";
    }          

    function excluir(id){       
        if(confirm("Deseja excluir a Ponto de Controle?" )){
            if(confirm("Tem certeza?" )){
                window.open("PontoControleControlador?acao=excluir&modulo=gwTrans&idPontoControle=" + id,
                "pop", "width=210, height=100");
            }
        }
    }
     
    function enviarPontoControle(acao) {
        var chkMarcados = marcados();
        if (chkMarcados == "") {
            alert("Selecione ao menos um Ponto de controle.");
            return false;
        }
        if (acao == "enviar") {
            window.open('MobileControlador?acao=sincronizarPontoControleGwMobile&idPontoControle='+chkMarcados,'popMobile',"width=210, height=100");
        }else{
            window.open('MobileControlador?acao=sincronizarPontoControleGwMobileBloqueio&idPontoControle='+chkMarcados,'popMobile',"width=210, height=100");
        }
    }
    
    function marcados(){
        var maxPC = $("maxPC").value;
        var retorno = "";
        for (var i = 1; i <= maxPC; i++) {
            if ($("checkAtivar_"+i).checked) {
                retorno = retorno + "," + $("checkAtivar_"+i).value;
            }
        }
        retorno = retorno.substr(1);
           
        return retorno;
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
        <title>Webtrans - Consulta de Ponto de Controle</title>
        
    </head>
    
    
    <body onload="desativarBotoes(), setDefault()"  > 
        <img src="img/banner.gif" width="30%" height="44">
        <table class="bordaFina" width="68%" align="center">
            <tr>
                <td width="82%" align="left"> <span class="style4">Consulta de Ponto de Controle</span></td>
                <td width="18%">
                    <c:if test="${param.nivel >= 3}">
                        <input name="cadastrar" type="button" class="inputbotao"  onclick="tryRequestToServer(function(){abrirCadastro();});" value="Novo Cadastro"/>
                    </c:if>
                </td>
            </tr>
        </table>
        <br>
        <table class="bordaFina" width="68%" align="center">
            <tr>
                <form action="PontoControleControlador?acao=listar&modulo=gwTrans" id="formulario" name="formulario" method="post">
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
                </form>
            </tr>
            
            
        </table>
        <%--listatudo--%>
        <table width="68%" border="0" cellpadding="2" cellspacing="1" class="bordaFina" align="center">
            <tr>  
                <td class="tabela" width="3%" align="left"></td>
                <td class="tabela" width="3%" align="left"></td>
                <td class="tabela" width="60%" align="left">Descrição</td>
                <td class="tabela" width="20%" align="left">Tipo</td>
                <td class="tabela" width="20%" align="left">Código Integração gwMobile</td>
                <td class="tabela" width="10%" align="left">Editável</td>
                <td class="tabela" width="10%" align="left"></td>                
                           
                
            </tr>
            <c:forEach var="pC" varStatus="status" items="${listaPontoControle}">             
                <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" >  
                    <c:if test="${status.last}">
                        <input type="hidden" name="maxPC" id="maxPC" value="${status.count}">
                    </c:if>
                        
                    <td>
                            <input type="checkbox" name="checkAtivar_${status.count}" id="checkAtivar_${status.count}" value="${pC.id}" ${pC.isEditavel == true ? "" : "style='display: none'"}/>
                        
                        
                    </td>
                    
                    <td>
                        <c:if test='${param.tipoMobile != "N" }'>
                            <c:choose>
                                <c:when test="${pC.is_enviado == true}">
                                    <img src="img/smart3.png" width="19" height="19" border="0" class="imagemLink" title="Já sincrozinado com GwMobile" >
                                </c:when>
                                <c:otherwise>
                                    <img src="img/smartphone.png" width="19" height="19" border="0" class="imagemLink" title="Não sincronizado o Ponto Controle no GwMobile">
                                </c:otherwise>
                            </c:choose>
                       </c:if>
                    </td>
                    
                    <td>
                        <c:choose>
                            <c:when test="${pC.isEditavel == true && pC.is_enviado != true}">
                                <a href="javascript: tryRequestToServer(function(){window.location='PontoControleControlador?acao=iniciarEditar&modulo=gwTrans&idPontoControle=${pC.id}';});" class="linkEditar">
                                    ${pC.descricao}
                                </a>
                            </c:when>
                            <c:otherwise>
                                ${pC.descricao}
                            </c:otherwise>
                        </c:choose>
                    </td>
                                        
                    <td>
                        ${pC.tipo}
                    </td>
                    
                    <td>
                        ${pC.codigoGwMobile}
                    </td>
                    
                    <td>
                        ${pC.isEditavel == true ? 'Sim' : "Não"}
                    </td>
                                        
                        <c:choose>
                            <c:when test="${param.nivel >= 4 && pC.is_enviado != true}">
                                <td align="center">
                               <a href="javascript: tryRequestToServer(function(){excluir('${pC.id}');});"> <img class="imagemLink" src="img/lixo.png"/> </a>
                                </td>
                            </c:when>
                            <c:otherwise>
                                <td align="center">                                    
                               <a href="javascript: tryRequestToServer(function(){excluir('${pC.id}');});"> <img class="imagemLink" src="img/lixo.png" style="display: none"/> </a>
                                </td>
                            </c:otherwise>
                        </c:choose>                      
                    
                </tr>
            </c:forEach>
        </table>
        <br>
        <table class="bordaFina" width="68%" align="center" >
            <tr class="CelulaZebra1">
                <td width="50%" align="center">  
                </td>
                <td width="25%" align="center">  
                    <input name="ativar" type="button" class="inputbotao" id="botaoProx" onclick="javascript: tryRequestToServer(function(){enviarPontoControle('enviar')});" value="Ativar GwMobile">
                </td>
                <td width="25%" align="center">  
                    <input name="desativar" type="button" class="inputbotao" id="botaoProx" onclick="javascript: tryRequestToServer(function(){enviarPontoControle('bloquear')});" value="Desativar GwMobile">
                </td>
            </tr>
        </table>
        <table class="bordaFina" width="68%" align="center" >
            <tr class="CelulaZebra1">
                <td width="50%" align="center">Total de Ocorr&ecirc;ncias: 
                  <c:out value="${param.qtdResultados}"/></td>
                <td width="20%" align="center">P&aacute;ginas: 
                  <c:out value="${param.paginaAtual} / ${param.paginas}"/></td>
                
                
                <form id="formularioAnt" name="formularioAnt" action="PontoControleControlador?acao=listar&modulo=gwTrans" method="post">
                    <td width="15%" align="center">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>"/>
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>"/>
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>"/>
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>"/>
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual - 1}'/>"/>
                        <input name="botaoAnt" type="button" class="inputbotao" id="botaoAnt" onclick="tryRequestToServer(function(){document.formularioAnt.submit();});" value="ANTERIOR"/>
                    </td>
                </form>
                <form id="formularioProx" name="formularioProx"  action="PontoControleControlador?acao=listar&modulo=gwTrans" method="post">
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
