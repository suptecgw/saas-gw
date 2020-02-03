<%-- 
    Document   : listar_produto
    Created on : 09/08/2012, 11:45:58
    Author     : gleidson
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">

<LINK REL="stylesheet" HREF="${homePath}/css/estilo.css" TYPE="text/css">
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>

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
    }

    function setDefault(){
        document.formulario.valorConsulta.focus();
        document.formulario.limiteResultados.value = '<c:out value="${param.limiteResultados}"/>';
        document.formulario.operadorConsulta.value = '<c:out value="${param.operadorConsulta}"/>';
        document.formulario.campoConsulta.value = '<c:out value="${param.campoConsulta}"/>';
        document.formulario.valorConsulta.value = '<c:out value="${param.valorConsulta}"/>';
        $("idCliente").value = '${param.idCliente}';
        var clienteP = '${param.cliente}';
        $("cliente").value = (clienteP != 'null' ? clienteP : $("cliente").value);

    }

    function aoClicarNoLocaliza(idJanela){
        if (idJanela == "Cliente") {
            $("idCliente").value = $("idremetente").value;
            $("cliente").value = $("rem_rzs").value;
        }
    }

    function abrirCadastro(){
        window.location = "ProdutoControlador?acao=novoCadastro&modulo=gwTrans";
    }

    function excluir(id, nome){
        if(confirm("Deseja excluir o Produto '" + nome + "'?" )){
            if(confirm("Tem certeza?" )){
                window.open("ProdutoControlador?acao=excluir&modulo=gwTrans&idProduto=" + id + "&descricao=" + nome,
                "pop", "width=210, height=100");
            }
        }
    }
    function abrirLocalizarCliente(){
        popLocate(3, "Cliente","", "");
    }

    function limparCliente(){
        $("idCliente").value = "0";
        $("cliente").value = "TODOS";
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
        <title>Webtrans - Consulta de Produtos</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>
    <body onload="desativarBotoes(), setDefault()"  >
        <img alt="" src="img/banner.gif" />
        <table class="bordaFina" width="70%" align="center">
            <tr>
                <td width="82%" align="left"> <span class="style4">Consulta de Produtos</span></td>
                <td width="18%">
                    <c:if test="${param.nivel >= 3}">
                        <input name="cadastrar" type="button" class="inputbotao"  onclick="tryRequestToServer(function(){abrirCadastro();});" value="Novo Cadastro"/>
                    </c:if>
                </td>
            </tr>
        </table>
        <br>
        <form action="ProdutoControlador?acao=listar" id="formulario" name="formulario" method="post">
            <table class="bordaFina" width="70%" align="center">
                <tr class="CelulaZebra1">
                    <td width="85" >
                        <input type="hidden" name="modulo" value="gwTrans"/>
                        <input type="hidden" id="idremetente" value="0"/>
                        <input type="hidden" id="rem_rzs" value=""/>
                        <select name="campoConsulta"  id="campoConsulta" class="inputtexto">
                            <option value="p.descricao">Descrição</option>
                            <option value="codigo">Código</option>
                            <option value="referencia">Referência</option>
                        </select>
                    </td>
                    <td width="211" height="20">
                        <select name="operadorConsulta" id="operadorConsulta" class="inputtexto">
                            <option value="1" selected>Todas as partes com</option>
                            <option value="2">Apenas com in&iacute;cio</option>
                            <option value="3">Apenas com o fim</option>
                            <option value="4">Igual &agrave; palavra/frase</option>
                        </select>
                    </td>
                    <td width="183" >
                        <input name="valorConsulta" type="text" class="inputtexto"  id="valorConsulta" size="25" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();">
                    </td>
                    <td width="100" align="center" rowspan="2"><input name="pesquisar" id="pesquisar" type="button" class="inputbotao" value="  Pesquisar  " onclick="javascript: tryRequestToServer(function(){document.formulario.submit();});" /></td>

                    <td width="170" rowspan="2" align="center">
                        <select   name="limiteResultados"  class="inputtexto">
                            <option value="10">10 Resultados</option>
                            <option value="20">20 Resultados</option>
                            <option value="30">30 Resultados</option>
                            <option value="40">40 Resultados</option>
                            <option value="50">50 Resultados</option>
                        </select>

                    </td>
                </tr>
                <tr class="CelulaZebra1">
                    <td align="right">Cliente:</td>
                    <td colspan="2">
                        <input type="text" class="inputReadOnly" size="40" name="cliente" id="cliente" value="TODOS">
                        <input type="hidden" name="idCliente" id="idCliente" value="0">
                        <input type="button" onclick="abrirLocalizarCliente()" class="inputbotao" value="...">
                        <img src="img/borracha.gif" id="borracha" onclick="limparCliente()" class="imagemLink"/>
                    </td>
                </tr>
            </table>

        </form>
        <table width="70%" border="0" cellpadding="2" cellspacing="1" class="bordaFina" align="center">
            <tr>
                <td class="tabela" width="15%" align="left" >CÓDIGO</td>
                <td class="tabela" width="35%" align="left">DESCRIÇÃO</td>
                <td class="tabela" width="15%" align="left" >REFERÊNCIA</td>
                <td class="tabela" width="16%" align="left" >UND. ENTRADA</td>
                <td class="tabela" width="16%" align="left" >UND. SAIDA</td>
                <td class="tabela" width="3%" align="left"></td>
            </tr>
            <c:forEach var="produto" varStatus="status" items="${listaListProduto}">
                <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" >

                    <td><a href="javascript: tryRequestToServer(function(){window.location='ProdutoControlador?acao=iniciarEditar&modulo=gwTrans&idProduto=${produto.id}';});" class="linkEditar">${produto.codigo}</a></td>
                    <td>${produto.descricao}</td>
                    <td>${produto.referencia}</td>
                    <td>${produto.unidadeMedidaEstoque.sigla}</td>
                    <td>${produto.unidadeMedidaVenda.sigla}</td>

                    <td align="center">
                        <c:if test="${param.nivel >= 4}">
                            <a href="javascript: tryRequestToServer(function(){excluir( '${produto.id}','${produto.descricao}');});"> <img class="imagemLink" src="img/lixo.png"/> </a>
                        </c:if>
                    </td>

                </tr>
            </c:forEach>
        </table>
        <br>
        <table class="bordaFina" width="70%" align="center" >
            <tr class="CelulaZebra1">
                <td width="50%" align="center">Total de Ocorr&ecirc;ncias <c:out value="${param.qtdResultados}"/></td>
                <td width="20%" align="center">P&aacute;ginas <c:out value="${param.paginaAtual} / ${param.paginas}"/></td>


                <form id="formularioAnt" name="formularioAnt" action="ProdutoControlador?acao=listar" method="post">
                    <td width="15%" align="center">
                        <input type="hidden" name="modulo" value="gwTrans"/>
                        <input type="hidden" name="idCliente" id="idCliente" value="${param.idCliente}">
                        <input type="hidden" name="cliente" id="cliente" value="${param.cliente}">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>"/>
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>"/>
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>"/>
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>"/>
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual - 1}'/>"/>
                        <input name="botaoAnt" type="button" class="inputbotao" id="botaoAnt" onclick="javascript: tryRequestToServer(function(){document.formularioAnt.submit();});" value="ANTERIOR"/>
                    </td>
                </form>
                <form id="formularioProx" name="formularioProx"  action="ProdutoControlador?acao=listar" method="post">
                    <td width="15%" align="center">
                        <input type="hidden" name="modulo" value="gwTrans"/>
                        <input type="hidden" name="idCliente" id="idCliente" value="${param.idCliente}">
                        <input type="hidden" name="cliente" id="cliente" value="${param.cliente}">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>">
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>">
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>">
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>">
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual + 1}'/>">
                        <input name="botaoProx" type="button" class="inputbotao" id="botaoProx" onclick="javascript: tryRequestToServer(function(){document.formularioProx.submit();});" value="PROXIMA">
                    </td>
                </form>
            </tr>
        </table>
    </body>
</html>
