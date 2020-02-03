<%-- 
    Document   : listar_bairro
    Created on : 13/04/2015, 16:55:21
    Author     : marcus
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<html>

    <head>
        <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
        "http://www.w3.org/TR/html4/loose.dtd">

    <link href="estilo.css" rel="stylesheet" type="text/css">
    <script language="javascript" type="text/javascript" src="script/builder.js"></script>
    <script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
    <script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
    <script language="javascript" type="text/javascript" src="script/sessao.js"></script>

    <script type="text/javascript" language="JavaScript" charset="Iso-8859-1">
        function desativarBotoes() {
            var paginaAtual = '<c:out value="${param.paginaAtual}"/>';
            var paginas = '<c:out value="${param.paginas}"/>';

            if (paginaAtual == '1') {
                document.formularioAnterior.botaoAnterior.disabled = true;
            }
            if (parseFloat(paginaAtual) >= parseFloat(paginas)) {
                document.formularioProximo.botaoProximo.disabled = true;
            }
        }
        function carregar() {
            $("valorConsulta").focus();
            $("limiteResultados").value = '<c:out value="${param.limiteResultados}"/>';
            $("operadorConsulta").value = '<c:out value="${param.operadorConsulta}"/>';
            $("campoConsulta").value = '<c:out value="${param.campoConsulta}"/>';
            $("valorConsulta").value = '<c:out value="${param.valorConsulta}"/>';

        }
        function abrirCadastro() {
            window.location = "./BairroControlador?acao=novoCadastro";
        }
//        function excluirBairro(idBairro, descricao) {
//            if (confirm("Deseja excluir o Bairro?")) {
//                if (confirm("Tem certeza?!")) {
//                    if (idBairro != 0) {
//                        new Ajax.Request("./BairroControlador?acao=excluir&idBairro= " + idBairro + "&descricao=" + descricao,
//                                {
//                                    method: 'post',
//                                    onSuccess: function () {
//                                        alert("Bairro " + descricao + " excluído com sucesso!");
//                                        location.reload();
//                                    },
//                                    onFailure: function () {
//                                        alert('Erro ao excluir o bairro ' + descricao + '!')
//                                    }
//                                });
//                    }
//                }
//            }
//        }

        function excluirBairro(idBairro, descricao) {
            if (confirm("Deseja excluir o Bairro " + descricao + " ?")) {
                if (confirm("Tem certeza?")) {
                    window.open("${homePath}/BairroControlador?acao=excluir&idBairro=" + idBairro + "&descricao=" + descricao, "pop", "width=210, height=100");
                }
            }
        }
        function editarBairro(idBairro) {
            window.location = "./BairroControlador?acao=iniciarEditar&idBairro=" + idBairro;
        }

        function pesquisar() {
            $("formulario").submit();
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


    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>WebTrans - Consulta de Bairros</title>
</head>
<body onload="desativarBotoes(), carregar()">
    <img src="img/banner.gif" width="30%" height="44">
    <table class="bordaFina" width="68%" align="center">
        <tr>
            <td width="82%" align="left"><span class="style4">Consulta de Bairros</span></td>
            <td width="18%">
                <c:if test="${param.nivel >= 3}">
                    <input id="cadastrar" name="cadastrar" class="inputBotao" type="button" onclick="tryRequestToServer(function () {
                                abrirCadastro();
                            });" value="Novo Cadastro"/>
                </c:if>
            </td>
        </tr>            
    </table>
    <br/>
    <form action="BairroControlador?acao=listar" id="formulario" name="formulario" method="post">
        <table class="bordaFina" width="68%" align="center">
            <tr>
                <td width="97" class="CelulaZebra1">
                    <select id="campoConsulta" name="campoConsulta" class="inputtexto">
                        <option value="descricao">Bairro</option>
                        <option value="cidade">Cidade</option>
                    </select>
                </td>
                <td width="183" class="CelulaZebra1">
                    <select id="operadorConsulta" name="operadorConsulta" class="inputtexto">
                        <option value="1">Todas as partes com</option>
                        <option value="2">Apenas com o início</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4">Igual à palavra/frase</option>
                    </select>
                </td>
                <td width="183" class="CelulaZebra1">
                    <input id="valorConsulta" name="valorConsulta" type="text" class="inputtexto" size="25" onKeyUp="javascript:if (event.keyCode==13) $('pesquisarBairro').click();"/>
                </td>
                <td width="15" class="CelulaZebra1">
                    <input id="pesquisarBairro" name="pesquisarBairro"  class="inputbotao" type="button" value="  Pesquisar  " onclick="pesquisar();"/>
                </td>
                <td width="186" class="CelulaZebra1">
                    <select id="limiteResultados" name="limiteResultados" class="inputtexto">
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
    <table width="68%" class="bordaFina" align="center" cellpadding="2" cellspacing="1">
        <tr>
            <td width="75%" class="tabela" align="left">Bairro</td>
            <td width="17%" class="tabela" align="left">Cidade</td>
            <td width="3%" class="tabela" align="center">UF</td>
            <td width="5%" class="tabela"></td>
        </tr>
        <c:forEach var="bairro" varStatus="statusBairro" items="${listaBairro}">
            <tr class="${(statusBairro.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}">
                <td>
                    <a href="javascript: tryRequestToServer(function(){editarBairro('${bairro.idBairro}');});" class="linkEditar">${bairro.descricao}</a>
                </td>
                <td>
                    <label>${bairro.cidadeBairro.descricaoCidade}</label>
                </td>
                <td align="center">
                    <label>${bairro.cidadeBairro.uf}</label>
                </td>
                <td align="center"> 
                    <c:if test="${param.nivel >= 4}">
                        <a href="javascript: tryRequestToServer(function(){excluirBairro('${bairro.idBairro}', '${bairro.descricao}');});">
                            <img class="imagemLink" src="img/lixo.png" title="Excluir Bairro"/>                                
                        </a>
                    </c:if>
                </td>
            </tr>
        </c:forEach>
    </table>
    <br/>
    <table width="68%" class="bordaFina" align="center">
        <tr class="CelulaZebra1">
            <td width="50%" align="center">Total de Ocorrências:
                <c:out value="${param.qtdResultados}"/>
            </td>
            <td width="20%" align="center">Páginas:
                <c:out value="${param.paginaAtual} / ${param.paginas}"/>
            </td>
        <form id="formularioAnterior" name="formularioAnterior" action="BairroControlador?acao=listar" method="post">
            <td width="15%" align="center">
                <input id="limiteResultados" name="limiteResultados" type="hidden" value="<c:out value='${param.limiteResultados}'/>"/>
                <input id="operadorConsulta" name="operadorConsulta" type="hidden" value="<c:out value='${param.operadorConsulta}'/>"/>
                <input id="campoConsulta" name="campoConsulta" type="hidden" value="<c:out value='${param.campoConsulta}'/>"/>
                <input id="valorConsulta" name="valorConsulta" type="hidden" value="<c:out value='${param.valorConsulta}'/>"/>
                <input id="paginaAtual" name="paginaAtual" type="hidden" value="<c:out value='${param.paginaAtual -1}'/>"/>
                <input id="botaoAnterior" name="botaoAnterior" type="button" class="inputBotao" onclick="tryRequestToServer(function () {
                        document.formularioAnterior.submit();
                    });" value="ANTERIOR"/>
            </td>
        </form>
        <form id="formularioProximo" name="formularioProximo" action="BairroControlador?acao=listar" method="post">
            <td width="15%" align="center">
                <input id="limiteResultados" name="limiteResultados" type="hidden" value="<c:out value='${param.limiteResultados}'/>"/>
                <input id="operadorConsulta" name="operadorConsulta" type="hidden" value="<c:out value='${param.operadorConsulta}'/>"/>
                <input id="campoConsulta" name="campoConsulta" type="hidden" value="<c:out value='${param.campoConsulta}'/>"/>
                <input id="valorConsulta" name="valorConsulta" type="hidden" value="<c:out value='${param.valorConsulta}'/>"/>
                <input id="paginaAtual" name="paginaAtual" type="hidden" value="<c:out value='${param.paginaAtual +1}'/>"/>
                <input id="botaoProximo" name="botaoProximo" type="button" class="inputBotao" onclick="tryRequestToServer(function () {
                        document.formularioProximo.submit();
                    });" value="PRÓXIMO"/>
            </td>
        </form>
    </tr>
</table>
</body>
</html>
