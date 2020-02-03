<%-- 
    Document   : localizar
    Created on : 20/10/2016, 09:25:36
    Author     : Mateus
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="ISO-8859-9"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-9">
        <meta charset="ISO-8859-1">
        <meta name="viewport" content="width=device-width">
        <title>Web Trans - Localizar</title>
        <!-- CSS -->
        <link rel="stylesheet" href="${homePath}/assets/css/easyui.css">
        <link href="${homePath}/assets/css/bootstrap-custom-col.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/jquery-ui.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/inputs-gw.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/gwTrans/localizar/css/estilo_localizar_cidades.css" rel="stylesheet" type="text/css"/>
        <!-- JS -->
        <script>
            var homePath = '${homePath}';

            function localizarGruposUsuarios() {
                var grupos = jQuery('#inpt-filtrar-por-grupos-clientes').val();
                limparGruposResultado();
                jQuery.ajax({
                    url: '${homePath}/ClienteControlador?acao=localizarGrupoClientes&grupos=' + grupos + '&isIgual=' + jQuery('#chkIgualGruposClientes').prop('checked') + '&isDiferenciar=' + jQuery('#chkDiferenciarGruposClientes').prop('checked'),
                    dataType: "text",
                    method: "post",
                    async: false,
                    success: function (data, textStatus, jqXHR) {
                        if (data != null && data != undefined && data.trim().length > 0) {

                            var paginacao = data.split('!@!')[0];
                            var paginacaoObj = jQuery.parseJSON(jQuery.parseJSON(paginacao));

                            popularPaginacao(paginacaoObj);

                            var size = data.split('!@!').length;
                            for (var i = 1; i < size; i++) {
                                if (data.split('!@!')[i] != null && data.split('!@!')[i] != undefined && data.split('!@!')[i].trim() != '') {
                                    popularListaGrupos(jQuery.parseJSON(data.split('!@!')[i]).descricao);
                                }
                            }
                        }
                    },
                    complete: function (jqXHR, textStatus) {

                    }
                });
            }
        </script>
        <style>
            .searchButton{
                background: #13385c url("${homePath}/assets/img/icon-search.png") no-repeat;
                background-size: 13px;
                background-position: 7px 7px;
            }
            .okButton{
                background: #13385c url("${homePath}/assets/img/ok.png") no-repeat;
                background-size: 13px;
                background-position: 7px 7px;
            }
        </style>
        <script src="${homePath}/assets/js/jquery-1.9.1.min.js"></script>
        <script src="${homePath}/assets/js/jquery-ui.min.js" type="text/javascript"></script>
        <script src="${homePath}/assets/js/ElementsGW.js" type="text/javascript"></script>
        <script src="${homePath}/gwTrans/localizar/js/funcoes_localizar_cidades.js" type="text/javascript"></script>
        <script src="${homePath}/gwTrans/localizar/js/funcoes_localizar_grupos_clientes.js" type="text/javascript"></script>
    </head>
    <body>
        <div class="geral-localizar">
            <div class="topo-localizar">
                <img src="${homePath}/assets/img/logo.png" class="logo">
                <center>
                    <label>Localizar Grupos de ${param.tipoLocalizar != null ? "Fornecedores" : "Clientes"}</label>
                </center>
                <c:if test="${param.cadgrupo >= 3}">
                    <img src="${homePath}/assets/img/icones/novo-cadastro-tag.png" class="novo-cadastro" title="Novo Cadastro" onclick="javascript:window.open('./cadgrupo_cli_for.jsp?acao=iniciar', '', 'width=500px,height=400px,top=80,resizable=yes,status=1,scrollbars=1');">
                </c:if>
                <img src="${homePath}/assets/img/sair.png" class="fechar" title="Sair">
            </div>
            <div class="corpo-localizar">
                <div class="regra">
                    <div class="regra-div-select">
                        <select id="select-campo">
                            <option value="grupo">Grupo</option>
                        </select>
                    </div>
                    <div class="regra-div-inpt">
                        <div style="margin-left:10px;max-width: 350px;width: 350px;float: left;">
                            <input type="text" placeholder="Pesquisar por" class="inpt-filtrar-por-grupos-clientes" name="inpt-filtrar-por-grupos-clientes" id="inpt-filtrar-por-grupos-clientes">
                        </div>
                        <input type="checkbox" id="chkDiferenciarGruposClientes" name="chkDiferenciarGruposClientes"><label class="lb-checkbox">Considerar maiúsculas e minúsculas.</label>
                        <br>
                        <input type="checkbox" id="chkIgualGruposClientes" name="chkIgualGruposClientes"><label class="lb-checkbox">Localizar do jeito que digitei.</label>
                    </div>
                    <div style="width: 100%;float: left;">
                        <center><input type="button" value="Localizar Grupos" class="searchButton" id="search" onclick="localizarGruposUsuarios();"></center>
                    </div>
                </div>
            </div>
            <div class="opcoes-avancadas-grupo-cliente" marcado="false">
                <input type="checkbox" id="chkOpcoesAvancadasGrupoCli" name="chkOpcoesAvancadasGrupoCli">
                <label>Exibir opções avançadas</label>
            </div>
            <div class="colunas">
                <div class="coluna-pesquisa">
                    <div class="resultados">
                        <div class="envolve-topo">
                            <div class="topo-resultados-col1">Descrição</div>
                        </div>
                        <div class="envolve-resultados" style="">
                            <ul id="grupoCliente1" class="connectedSortableGrupoCliente">
                                <!--<li class="ui-state-default" onclick="marcarItemAdicionar(this);"><div class="grupo">Recife</div><div class="estado">PE</div></li>-->
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
                            <div class="topo-resultados-col1">Descrição</div>
                        </div>
                        <div class="envolve-resultados" style="overflow-y: scroll;">
                            <ul id="grupoCliente2" class="connectedSortableGrupoCliente">
                                <!--<li class="ui-state-highlight">Item 1</li>-->
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
            <div class="footer-localizar">
                <center><input type="button" value="Selecionar cidades escolhidas" class="okButton" id="search" style="margin-top: 0 !important;" onclick="enviarGruposSelecionadas();"></center>
            </div>
            <div class="paginacao">
                <input id="totalPaginas" name="totalPaginas" type="hidden" value="0">
                <input id="paginaAtual" name="paginaAtual" type="hidden" value="1">
                <div align="right" style="position: absolute;margin-left: 10px;color:#13385C;font-family: 'Century Gothic', CenturyGothic, AppleGothic, sans-serif;" id="divPaginacao">
                    <span>Página </span>
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

        function popularListaGrupos(descricao) {
            if (jQuery('#chkOpcoesAvancadasGrupoCli').prop('checked') == true) {
                jQuery('#grupoCliente1').append('<li class="ui-state-default" onclick="marcarItemAdicionar(this);"><div class="grupo">' + descricao + '</div></li>');
                jQuery('.grupo').css('text-decoration', 'none');
                jQuery('.grupo').css('color', '#444');
            } else {
                jQuery('#grupoCliente1').append('<li class="ui-state-default" onclick="parent.controleLocalizarGrupoCliente(' + "'" + "finalizado" + "'" + ',popularOnClick(this),true);"><div class="grupo">' + descricao + '</div></li>');
                jQuery('.grupo').css('text-decoration', 'underline');
                jQuery('.grupo').css('color', '#13385c');
            }
        }

        function popularListaGruposEscolhidos(descricao) {
            if (jQuery('#chkOpcoesAvancadasGrupoCli').prop('checked') == true) {
                jQuery('#grupoCliente2').append('<li class="ui-state-default" onclick="marcarItemAdicionar(this);"><div class="grupo">' + descricao + '</div></li>');
                jQuery('.grupo').css('text-decoration', 'none');
                jQuery('.grupo').css('color', '#444');

            } else {
                jQuery('#grupoCliente2').append('<li class="ui-state-default" onclick="parent.controleLocalizarGrupoCliente(' + "'" + "finalizado" + "'" + ',popularOnClick(this),true);"><div class="grupo">' + descricao + '</div></li>');
                jQuery('.grupo').css('text-decoration', 'underline');
                jQuery('.grupo').css('color', '#13385c');
            }
        }


        function proximaLocalizar() {
            var grupos = jQuery('#inpt-filtrar-por-grupos-clientes').val();
            var check = jQuery('#chkDiferenciarGruposClientes').prop('checked');
            var ckeckIgual = jQuery('#chkIgualGruposClientes').prop('checked');

            var paginaAtual = parseInt(jQuery('#paginaAtual').val()) + 1;
            var totalPaginas = parseInt(jQuery('#totalPaginas').val());

            limparGruposResultado();

            jQuery.ajax({
                url: '${homePath}/ClienteControlador?acao=localizarGrupoClientes&grupos=' + grupos + '&isDiferencia=' + check + '&isIgual=' + ckeckIgual + '&paginaAtual=' + paginaAtual + '&totalPaginas=' + totalPaginas,
                dataType: "text",
                method: "post",
                async: false,
                success: function (data, textStatus, jqXHR) {
                    if (data != null && data != undefined && data.trim().length > 0) {

                        var paginacao = data.split('!@!')[0];
                        var paginacaoObj = jQuery.parseJSON(jQuery.parseJSON(paginacao));

                        popularPaginacao(paginacaoObj);

                        var size = data.split('!@!').length;
                        for (var i = 1; i < size; i++) {
                            if (data.split('!@!')[i] != null && data.split('!@!')[i] != undefined && data.split('!@!')[i].trim() != '') {
                                popularListaGrupos(jQuery.parseJSON(data.split('!@!')[i]).descricao);
                            }
                        }
                    }
                }

            });
        }


        function anteriorLocalizar() {
            var grupos = jQuery('#inpt-filtrar-por-grupos-clientes').val();
            var check = jQuery('#chkDiferenciarGruposClientes').prop('checked');
            var ckeckIgual = jQuery('#chkIgualGruposClientes').prop('checked');

            var paginaAtual = parseInt(jQuery('#paginaAtual').val()) - 1;
            var totalPaginas = parseInt(jQuery('#totalPaginas').val());

            limparGruposResultado();

            jQuery.ajax({
                url: '${homePath}/ClienteControlador?acao=localizarGrupoClientes&grupos=' + grupos + '&isDiferencia=' + check + '&isIgual=' + ckeckIgual + '&paginaAtual=' + paginaAtual + '&totalPaginas=' + totalPaginas,
                dataType: "text",
                method: "post",
                async: false,
                success: function (data, textStatus, jqXHR) {
                    if (data != null && data != undefined && data.trim().length > 0) {

                        var paginacao = data.split('!@!')[0];
                        var paginacaoObj = jQuery.parseJSON(jQuery.parseJSON(paginacao));

                        popularPaginacao(paginacaoObj);

                        var size = data.split('!@!').length;
                        for (var i = 1; i < size; i++) {
                            if (data.split('!@!')[i] != null && data.split('!@!')[i] != undefined && data.split('!@!')[i].trim() != '') {
                                popularListaGrupos(jQuery.parseJSON(data.split('!@!')[i]).descricao);
                            }
                        }
                    }
                }

            });

        }

        function paginaEnter(evn, pagina) {
            if (evn.keyCode == 13) {
                var grupos = jQuery('#inpt-filtrar-por-grupos-clientes').val();
                var check = jQuery('#chkDiferenciarGruposClientes').prop('checked');
                var ckeckIgual = jQuery('#chkIgualGruposClientes').prop('checked');

                var paginaAtual = parseInt(jQuery('#pagina').val());
                var totalPaginas = parseInt(jQuery('#totalPaginas').val());

                limparCidadesResultado();

                jQuery.ajax({
                    url: '${homePath}/ClienteControlador?acao=localizarGrupoClientes&grupos=' + grupos + '&isDiferencia=' + check + '&isIgual=' + ckeckIgual + '&paginaAtual=' + paginaAtual + '&totalPaginas=' + totalPaginas,
                    dataType: "text",
                    method: "post",
                    async: false,
                    success: function (data, textStatus, jqXHR) {
                        if (data != null && data != undefined && data.trim().length > 0) {

                            var paginacao = data.split('!@!')[0];
                            var paginacaoObj = jQuery.parseJSON(jQuery.parseJSON(paginacao));

                            popularPaginacao(paginacaoObj);

                            var size = data.split('!@!').length;
                            for (var i = 1; i < size; i++) {
                                if (data.split('!@!')[i] != null && data.split('!@!')[i] != undefined && data.split('!@!')[i].trim() != '') {
                                    popularListaGrupos(jQuery.parseJSON(data.split('!@!')[i]).descricao);
                                }
                            }
                        }
                    }

                });
            }
        }

        //Validar o caractere de pagina
        function verificaCaracterePagina(element, paginas) {
            element.value = element.value.replace(/[^0-9,]/g, "");

            if (element.value != null && element.value != "" && parseFloat(element.value) > parseFloat(paginas)) {
                element.value = "";
                return true;
            }

            //nao enviar pagina caso seja 0 - já que 0 é menor
            // que a quantidade de paginas sempre e passa das validacoes acima
            if (element.value == "0" || element.value == 0) {
                element.value = "";
            }
        }

        function limparGrupos() {
            jQuery('#grupoCliente1').html('');
            jQuery('#grupoCliente2').html('');
        }

        function limparGruposResultado() {
            jQuery('#grupoCliente1').html('');
        }

        function limparGruposEscolhidas() {
            jQuery('#grupoCliente2').html('');
        }
        function recarregarLocalizarGrupoCliente() {
            window.location = 'ClienteControlador?acao=iniciar_localizar';
        }
    </script>
</html>
