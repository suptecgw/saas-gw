<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="ISO-8859-9"%>
<jsp:useBean id="random" class="java.util.Random" scope="application" />
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-9">
        <meta charset="ISO-8859-1">
        <meta name="viewport" content="width=device-width">
        <title>Gw Trans - Localizar</title>
        <!-- CSS -->
        <c:if test = "${param.tema != ''}">
            <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${param.tema}.css?v=${random.nextInt()}">
        </c:if>
        <link href="${homePath}/gwTrans/localizar/css/estilo_localizar_clientes.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="${homePath}/assets/css/easyui.css?v=${random.nextInt()}">
        <link href="${homePath}/assets/css/bootstrap-custom-col.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/jquery-ui.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="${homePath}/assets/css/inputs-gw.css?v=${random.nextInt()}" type="text/css"/>

        <!-- JS -->
        <script src="${homePath}/script/jQuery/jquery.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/assets/js/jquery-ui.min.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script defer src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>

        <script>
            var homePath = '${homePath}';
            var idLocalizar = '${param.idLocalizar}';
            var tipoLocalizar = '${param.tipoLocalizar}';
        </script>
    </head>
<body>
    <div class="geral-localizar">
        <div class="topo-localizar">
            <img src="${homePath}/assets/img/logo.png" class="logo">
            <center>
                <label class="nome-topo-localizar">Localizar</label>
            </center>
            <img src="${homePath}/assets/img/sair.png" class="fechar" title="Sair">
        </div>
        <div class="corpo-localizar">
            <div class="regra">
                <div class="regra-div-select">
                    <select id="select-campo"></select>
                </div>

                <div class="regra-div-inpt">
                    <input type="hidden" name="filtroId" id="filtroId" value="${param.filtroId}">
                    <div style="margin-left:10px;max-width: 350px;width: 350px;float: left;">
                        <input type="text" placeholder="Pesquisar por" class="inpt-filtrar-por" name="inpt-filtrar-por" id="inpt-filtrar-por">
                    </div>
                    <input type="checkbox" id="chkDiferenciar" name="chkDiferenciar"><label class="lb-checkbox">Considerar maiúsculas e minúsculas.</label>
                    <br>
                    <input type="checkbox" id="chkIgual" name="chkIgual"><label class="lb-checkbox">Localizar do jeito que digitei.</label>
                </div>
                <div class="regra-div-select filtro-especial">

                </div>
                <div class="btnLocalizar" style="margin-left:170px;max-width: 350px;width: 350px;float: left;">
                    <center><input type="button" value="Localizar" class="searchButton" id="search" onclick=""></center>
                </div>
            </div>
        </div>
        <c:if test="${param.ocultarOpcoesAvancadas ne 'true'}">
            <div class="opcoes-avancadas" marcado="false">
                <input type="checkbox" id="chkOpcoesAvancadas" name="chkOpcoesAvancadas" value="${param.idLocalizar}">
                <label for="chkOpcoesAvancadas">Exibir opções avançadas</label>
            </div>
        </c:if>

        <div class="colunas">
            <div class="coluna-pesquisa">
                <div class="resultados">
                    <div class="envolve-topo"></div>
                    <div class="envolve-resultados" style="">
                        <ul id="topo-resultados-col1" class="connectedSortable">
                            <!--<li class="ui-state-default" onclick="marcarItemAdicionar(this);"><div class="cidade">Recife</div><div class="estado">PE</div></li>-->
                        </ul>
                    </div>
                </div>
            </div>
            <div class="coluna-centro">
                <center>
                    <img src="${homePath}/assets/img/passar_item.png" title="Escolher itens selecionados." onclick="parent.controlador.acao('passarSelecionados', idLocalizar);">
                    <img src="${homePath}/assets/img/passar_todos_itens.png" title="Escolher todos os resultados." onclick="parent.controlador.acao('passarTodos', idLocalizar);">
                    <img src="${homePath}/assets/img/tirar_item.png" title="Retirar itens selecionados." onclick="parent.controlador.acao('voltarSelecionados', idLocalizar);">
                    <img src="${homePath}/assets/img/tirar_todos_itens.png" title="Retirar todos os itens." onclick="parent.controlador.acao('voltarTodos', idLocalizar);">
                </center>
            </div>
            <div class="coluna-escolhidas">
                <div class="resultados">
                    <div class="envolve-topo"></div>
                    <div class="envolve-resultados" style="overflow-y: scroll;">
                        <ul id="topo-resultados-col2" class="connectedSortable">
                            <!--<li class="ui-state-highlight">Item 1</li>-->
                        </ul>
                    </div>
                </div>
            </div>
        </div>
        <div class="footer-localizar">
            <center><input type="button" value="Selecionar clientes escolhidos" class="okButton" id="search" style="margin-top: 0 !important;" onclick="parent.controlador.acao('enviarSelecionados', idLocalizar)"></center>
        </div>
        <div class="paginacao">
            <input id="totalPaginas" name="totalPaginas" type="hidden" value="0">
            <input id="paginaAtual" name="paginaAtual" type="hidden" value="1">
            <div align="right" id="divPaginacao">
                <span>Página </span>
                <input type="text" size="2" id="pagina" name="pagina" value="0" onkeyup="verificaCaracterePagina(this, parseInt(jQuery('#totalPaginas').val()));" onchange="verificaCaracterePagina(this, parseInt(jQuery('#totalPaginas').val()));" onkeypress="paginaEnter(event, this.value);" class="pagination-num">
                <span id="span-total-paginas">de 0</span>
                <a href="javascript:;" class="l-btn l-btn-small l-btn-plain l-btn-disabled l-btn-plain-disabled"  group="" id="anterior" style="margin-right: -13px;">
                    <span class="l-btn-left l-btn-icon-left">
                        <span class="l-btn-text l-btn-empty">&nbsp;</span>
                        <span class="l-btn-icon pagination-prev">&nbsp;</span>
                    </span>
                </a>
                <a href="javascript:;" class="l-btn l-btn-small l-btn-plain l-btn-disabled l-btn-plain-disabled" style="z-index: 999999;" group="" id="proxima">
                    <span class="l-btn-left l-btn-icon-left">
                        <span class="l-btn-text l-btn-empty">&nbsp;</span>
                        <span class="l-btn-icon pagination-next">&nbsp;</span>
                    </span>
                </a>
            </div>
        </div>
    </div>
    <script src="${homePath}/gwTrans/localizar/js/funcoes_localizar_clientes.js?v=${random.nextInt()}" type="text/javascript"></script>
</body>
</html>