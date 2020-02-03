<%-- 
    Document   : listar_GrupoUsuario
    Created on : 19/11/2008, 08:53:13
    Author     : Vladson Pontes
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<link href="estilo.css" rel="stylesheet" type="text/css">
<script language="javascript" type="text/javascript" src="script/prototype.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery-1.11.2.min.js"></script>
<script language="javascript" type="text/javascript" src="script/validarSessao.js"></script>
<script type="text/javascript" language="JavaScript">
    var req;   
       
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
        window.location = "GrupoUsuarioControlador?acao=novoCadastro";       
    }          

    function excluir(id, nome){       
        if(confirm("Deseja excluir a filial '" + nome + "'?" )){
            if(confirm("Tem certeza?" )){                
                window.open("GrupoUsuarioControlador?acao=excluir&modulo=gWeb&idGrupo=" + id+ "&descricao=" + nome,
                "pop", "width=210, height=100");
            }
        }
        
        
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
        <title>gWeb - Consulta de Grupos de Usuários</title>
        
    </head>
    
    <body onload="desativarBotoes(), setDefault()" >
        <img alt="" src="img/banner.gif">
        <table class="bordaFina" width="70%" align="center">
            <tr>
                <td width="83%" align="left"> <span class="style4">Consulta de Grupos de Usuários 
                  
                </span></td>
                <td width="17%">
	                <c:if test="${param.nivel >= 3}">
                    <input name="cadastrar" type="button" class="inputbotao"  onclick="checkSession(function(){abrirCadastro();});" value="Novo Cadastro"/>
    	            </c:if> 
              </td>
            </tr>
        </table>
        <br>



        <table class="bordaFina" width="70%" align="center">
            <tr class="CelulaZebra1">
                
                
                <form action="GrupoUsuarioControlador?acao=listar" id="formulario" name="formulario" method="post">
                    <td width="101"><select name="campoConsulta" class="inputtexto" id="campoConsulta">
                      <option value="descricao">Descri&ccedil;&atilde;o</option>
                      <option value="abreviatura">Filial</option>
                    </select></td>
                    
                    <td width="168"  height="20"><select name="operadorConsulta" class="inputtexto" id="operadorConsulta" >
                      <option value="1" selected>Todas as partes com</option>
                      <option value="2">Apenas com in&iacute;cio</option>
                      <option value="3">Apenas com o fim</option>
                      <option value="4">Igual &agrave; palavra/frase</option>
                    </select></td>
                    
                    <td width="156"><input name="valorConsulta" type="text" class="inputtexto"  id="valorConsulta" size="25" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();"></td>
                    <td width="104"></input>
                    <input name="pesquisar" id="pesquisar" type="button" class="inputbotao" value="  Pesquisar  " onclick="javascript: checkSession(function(){document.formulario.submit();});" /></td>
                    
                    <td width="132"><span class="style4">
                      <select   name="limiteResultados" class="inputtexto" id="limiteResultados"  >
                        <option value="10">10 Resultados</option>
                        <option value="20">20 Resultados</option>
                        <option value="30">30 Resultados</option>
                        <option value="40">40 Resultados</option>
                        <option value="50">50 Resultados</option>
                    </select>
                    </span></td>
                </form>
            </tr>
            
            
    </table>
        <table width="70%" border="0" cellpadding="1" cellspacing="2" class="bordaFina" align="center">
            <tr class="tabela">                
                <td width="96%"><div align="left"><b>Descrição</b></div></td>
                <td width="4%">&nbsp;</td>
                
            </tr>
            <c:forEach var="grupo" varStatus="status" items="${listaListGrupo}">            
                <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}">                                        
                    <td><a href="javascript: checkSession(function(){window.location='GrupoUsuarioControlador?acao=iniciarEditar&idGrupo=${grupo.id}';});" class="linkEditar">${grupo.descricao}</a></td>
                    <c:if test="${param.nivel >= 4}">
                        <td><div align="center"><a href="javascript: checkSession(function(){excluir( '${grupo.id}','${grupo.descricao}');});"> <img class="imagemLink" src="img/lixo.png"/></a></div></td>
                    </c:if> 
                </tr>
            </c:forEach>
    </table><br>
        <table class="bordaFina" width="70%" align="center">
            <tr class="CelulaZebra1">
                <td width="50%" align="center">Total de Ocorr&ecirc;ncias: <c:out value="${param.qtdResultados}"/></td>
                <td width="20%" align="center">P&aacute;ginas:  <c:out value="${param.paginaAtual} / ${param.paginas}"/></td>
				<form id="formularioAnt" name="formularioAnt" action="GrupoUsuarioControlador?acao=listar" method="post">
				<td width="15%" align="center">
                        <input type="hidden" name="limiteResultados" value="<c:out value="${param.limiteResultados}"/>">
                        <input type="hidden" name="operadorConsulta" value="<c:out value="${param.operadorConsulta}"/>">
                        <input type="hidden" name="campoConsulta" value="<c:out value="${param.campoConsulta}"/>">
                        <input type="hidden" name="valorConsulta" value="<c:out value="${param.valorConsulta}"/>">
                        <input type="hidden" name="paginaAtual" value="<c:out value="${param.paginaAtual - 1}"/>">
                        <input name="botaoAnt" type="button" class="inputbotao" id="botaoAnt" onclick="javascript: checkSession(function(){document.formularioAnt.submit();});" value="ANTERIOR">
                </td>
                </form>
                    <form id="formularioProx" name="formularioProx"  action="GrupoUsuarioControlador?acao=listar" method="post">
					<td width="15%" align="center">
                        <input type="hidden" name="limiteResultados" value="<c:out value="${param.limiteResultados}"/>">
                        <input type="hidden" name="operadorConsulta" value="<c:out value="${param.operadorConsulta}"/>">
                        <input type="hidden" name="campoConsulta" value="<c:out value="${param.campoConsulta}"/>">
                        <input type="hidden" name="valorConsulta" value="<c:out value="${param.valorConsulta}"/>">
                        <input type="hidden" name="paginaAtual" value="<c:out value="${param.paginaAtual + 1}"/>">
                        <input name="botaoProx" type="button" class="inputbotao" id="botaoProx" onclick="javascript: checkSession(function(){document.formularioProx.submit();});" value="PROXIMA">
					</td>
                    </form>
            </tr>
    </table>
        
    </body>
</html>
