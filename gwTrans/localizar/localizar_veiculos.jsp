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
        <link rel="stylesheet" href="${homePath}/assets/css/easyui.css">
        <link href="${homePath}/assets/css/bootstrap-custom-col.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/jquery-ui.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/inputs-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/gwTrans/localizar/css/estilo_localizar_veiculos.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <!-- JS -->
        <script>
            var jQuery = parent.jQuery;
            var homePath = '${homePath}';
        </script>
        <script src="${homePath}/assets/js/jquery-1.9.1.min.js"></script>
        <script src="${homePath}/assets/js/jquery-ui.min.js" type="text/javascript"></script>
        <script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/gwTrans/localizar/js/funcoes_localizar_veiculos.js?v=${random.nextInt()}" type="text/javascript"></script>
    </head>
    <body>
        <div class="geral-localizar">
            <div class="topo-localizar">
                <img src="${homePath}/assets/img/logo.png" class="logo">
                <center>
                    <label id="titulo-tela">Localizar Ve�culos</label>
                </center>
                <c:if test="${param.cadveiculo >= 3}">
                    <img src="${homePath}/assets/img/icones/novo-cadastro-tag.png" class="novo-cadastro" title="Novo Cadastro" onclick="javascript:window.open('./cadveiculo?acao=iniciar', '', 'top=80,resizable=yes,status=1,scrollbars=1');">
                </c:if>
                <img src="${homePath}/assets/img/sair.png" class="fechar" title="Sair">
            </div>
            <div class="corpo-localizar">
                <div class="regra">
                    <div class="regra-div-select">
                        <select id="select-campo">
                            <option value="placa">Placa</option>
                            <option value="num_frota">N� Frota</option>
                            <option value="tipofrota">Tipo Frota</option>
                            <option value="tipo">Tipo Ve�culo</option>
                            <option value="marca">Marca</option>
                            <option value="propriet�rio">Propriet�rio</option>
                        </select>
                    </div>
                    <div class="regra-div-inpt">
                        <div style="margin-left:10px;max-width: 350px;width: 350px;float: left;">
                            <input type="text" placeholder="Pesquisar por" class="inpt-filtrar-por" name="inpt-filtrar-por" id="inpt-filtrar-por">
                        </div>
                        <input type="checkbox" id="chkDiferenciar" name="chkDiferenciar"><label class="lb-checkbox">Considerar mai�sculas e min�sculas.</label>
                        <br>
                        <input type="checkbox" id="chkIgual" name="chkIgual"><label class="lb-checkbox">Localizar do jeito que digitei.</label>
                    </div>
                    <div style="width: 100%;float: left;">
                        <center><input type="button" value="Localizar" class="searchButton" id="searchVeiculo" onclick="localizarVeiculos(tipoLocalizar, jQuery('#inpt-filtrar-por').val(), jQuery('#select-campo').val(), jQuery('#chkDiferenciar').prop('checked'), jQuery('#chkIgual').prop('checked'));"></center>
                    </div>
                </div>
            </div>
            <div class="opcoes-avancadas" marcado="false">
                <input type="checkbox" id="chkOpcoesAvancadas" name="chkOpcoesAvancadas">
                <label for="chkOpcoesAvancadas">Exibir op��es avan�adas</label>
            </div>

            <div class="colunas">
                <div class="coluna-pesquisa">
                    <div class="resultados">
                        <div class="envolve-topo">
                            <div class="topo-resultados-col1">Placa</div><div class="topo-resultados-col2">N� Frota</div><div class="topo-resultados-col3">Tipo Frota</div><div class="topo-resultados-col4">Tipo Ve�culo</div><div class="topo-resultados-col5">Marca</div><div class="topo-resultados-col6">Propriet�rio</div>
                        </div>
                        <div class="envolve-resultados" style="">
                            <ul id="topo-resultados-col1" class="connectedSortable">
                                <!--<li class="ui-state-default" onclick="marcarItemAdicionar(this);"><div class="cidade">Recife</div><div class="estado">PE</div></li>-->
                            </ul>
                        </div>
                    </div>
                </div>
                <div class="coluna-centro">
                    <center>
                        <img src="${homePath}/assets/img/passar_item.png" title="Escolher itens selecionados." onclick="passarItensSelecionados();">
                        <img src="${homePath}/assets/img/passar_todos_itens.png" title="Escolher todos os resultados." onclick="passarTodosItens();">
                        <img src="${homePath}/assets/img/tirar_item.png" title="Retirar itens selecionados." onclick="voltarItensSelecionados();">
                        <img src="${homePath}/assets/img/tirar_todos_itens.png" title="Retirar todos os itens." onclick="voltarTodosItens();">
                    </center>
                </div>
                <div class="coluna-escolhidas">
                    <div class="resultados">
                        <div class="envolve-topo">
                            <div class="topo-resultados-col1">Placa</div><div class="topo-resultados-col2">N� Frota</div><div class="topo-resultados-col3">Tipo Frota</div><div class="topo-resultados-col4">Tipo Ve�culo</div><div class="topo-resultados-col5">Marca</div><div class="topo-resultados-col6">Propriet�rio</div>
                        </div>
                        <div class="envolve-resultados" style="overflow-y: scroll;">
                            <ul id="topo-resultados-col2" class="connectedSortable">
                                <!--<li class="ui-state-highlight">Item 1</li>-->
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
            <div class="footer-localizar">
                <center><input type="button" value="Selecionar ve�culos escolhidos" class="okButton" id="searchVeiculo" style="margin-top: 0 !important;" onclick="enviarVeiculosSelecionados();"></center>
            </div>
            <div class="paginacao">
                <input id="totalPaginas" name="totalPaginas" type="hidden" value="0">
                <input id="paginaAtual" name="paginaAtual" type="hidden" value="1">
                <div align="right" style="position: absolute;margin-left: 10px;color:#13385C;font-family: 'Century Gothic', CenturyGothic, AppleGothic, sans-serif;" id="divPaginacao">
                    <span>P�gina </span>
                    <input type="text" size="2" id="pagina" name="pagina" value="0" onkeyup="verificaCaracterePagina(this, parseInt(jQuery('#totalPaginas').val()));" onchange="verificaCaracterePagina(this, parseInt(jQuery('#totalPaginas').val()));" onkeypress="paginaEnter(event, this.value);" class="pagination-num" style="height: 30px;width: 25px;border:1px solid #8899aa;border-radius:5px;padding-left: 5px;color:#13385C;font-family: 'Century Gothic', CenturyGothic, AppleGothic, sans-serif;">
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
    </body>
    <script>
        var tipoLocalizar = '${param.tipoLocalizar}';
        var controleLocalizar = '';

        if (tipoLocalizar == 'veiculo') {
            controleLocalizar = 'controleLocalizarVeiculos';
            document.getElementById('titulo-tela').innerHTML = 'Localizar Veiculos';
        } else if (tipoLocalizar == 'carreta') {
            controleLocalizar = 'controleLocalizarCarretas';
            document.getElementById('titulo-tela').innerHTML = 'Localizar Carreta';
        }

    </script>
</html>
