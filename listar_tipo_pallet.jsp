

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<LINK REL="stylesheet" HREF="estilo.css" TYPE="text/css">
<script language="javascript" type="text/javascript" src="script/prototype.js"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/mascaras.js"></script>
<script language="javascript" type="text/javascript" src="script/collection.js"></script>
<script type="text/javascript" language="JavaScript">  
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
        window.location = "TipoPalletControlador?acao=novoCadastro";
    }          

    function excluir(id, descricao){
        if(confirm("Deseja excluir o Tipo do Pallet' " + descricao + "'?" )){
            if(confirm("Tem certeza?" )){                
                window.open("TipoPalletControlador?acao=excluir&id=" + id + "&descricao=" + descricao,
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
        <title>webtrans - Consulta do Tipo de Pallet</title>
    </head>

    <body onload="desativarBotoes(), setDefault()"  > 
        <img src="img/banner.gif" width="40%" height="44" align="middle">
        <table class="bordaFina" width="70%" align="center">
            <tr>
                <td width="82%" align="left"> 
                    <span class="style4">Consulta do Tipo de Pallet</span>
                </td>
                <td width="18%">
                    <c:if test="${param.nivel >= 3}">
                        <input name="cadastrar" type="button" class="inputbotao"  onclick="tryRequestToServer(function(){abrirCadastro()})" value="Novo Cadastro"/>
                    </c:if> 
                </td>
            </tr>
        </table>
        <br>
        <table class="bordaFina" width="70%" align="center">
            <tr>
            <form action="TipoPalletControlador?acao=listar" id="formulario" name="formulario" method="post">
                <td width="110" class="CelulaZebra1">
                    <select name="campoConsulta" class="inputtexto"  id="campoConsulta">
                        <option value="tp.descricao">Descri&ccedil;&atilde;o</option>
                    </select>                    
                </td>
                <td width="168" class="CelulaZebra1" height="20">
                    <select name="operadorConsulta" class="inputtexto" id="operadorConsulta" >
                        <option value="1" selected>Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4">Igual &agrave; palavra/frase</option>
                    </select>                    
                </td>
                <td class="CelulaZebra1">
                    <input name="valorConsulta" type="text" class="inputtexto"  id="valorConsulta" size="25" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();">
                    <label></label>
                </td>
                <td width="119" class="CelulaZebra1">
                    <input name="pesquisar" id="pesquisar" type="button" class="inputbotao" value="  Pesquisar  " onClick="document.formulario.submit();"  />
                </td>
                <td width="134" class="CelulaZebra1">
                    <select   name="limiteResultados" class="inputtexto"  >
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
    <table width="70%" border="0" cellpadding="2" cellspacing="1" class="bordaFina" align="center">
        <tr>
            <td class="tabela" width="68%" align="left">DESCRI&Ccedil;&Atilde;O</td>
            <td class="tabela" width="30%" align="left">&Aacute;rea</td>
            <td class="tabela" width="2%" align="left"></td>
        </tr>
        <c:forEach var="tPallet" varStatus="status" items="${listaTipoPallet}">
            <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" >
                <td>
                    <a href="javascript: window.location='TipoPalletControlador?acao=iniciarEditar&id=${tPallet.id}';" class="linkEditar">${tPallet.descricao}</a>
                </td>
                <td>
                    <script>document.write(colocarVirgula(${tPallet.area}))</script>
                </td>
                <td align="center">
                    <c:if test="${param.nivel >= 4}">
                        <a href="javascript: excluir( '${tPallet.id}','${tPallet.descricao}');"> 
                            <img id="excluirPallet" name="excluirPallet" class="imagemLink" src="img/lixo.png"/> 
                        </a>
                    </c:if>                    
                </td>
            </tr>
        </c:forEach>
    </table>
    <br>
    <table class="bordaFina" width="70%" align="center" >
        <tr class="CelulaZebra1">
            <td width="50%" align="center">Total de Ocorr&ecirc;ncias:
                <c:out value="${param.qtdResultados}"/>
            </td>
            <td width="20%" align="center">P&aacute;ginas:
                <c:out value="${param.paginaAtual} / ${param.paginas}"/>
            </td>

            <form id="formularioAnt" name="formularioAnt" action="TipoPalletControlador?acao=listar" method="post">
                <td width="15%" align="center">
                    <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>"/>
                    <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>"/>
                    <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>"/>
                    <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>"/>
                    <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual - 1}'/>"/>
                    <input name="botaoAnt" type="button" class="inputbotao" id="botaoAnt" onclick="javascript: validaSession(function(){document.formularioAnt.submit();});" value="ANTERIOR"/>
                </td>
            </form>
            <form id="formularioProx" name="formularioProx"  action="TipoPalletControlador?acao=listar" method="post">
                <td width="15%" align="center">
                    <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>">
                    <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>">
                    <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>">
                    <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>">
                    <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual + 1}'/>">
                    <input name="botaoProx" type="button" class="inputbotao" id="botaoProx" onclick="javascript: validaSession(function(){document.formularioProx.submit();});" value="PROXIMA">
                </td>
            </form>
       </tr>
    </table>
</body>
</html>


