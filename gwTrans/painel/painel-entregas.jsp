<%-- 
    Document   : painel-entregas
    Created on : 28/11/2018, 15:47:18
    Author     : mateus
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@ taglib uri="/WEB-INF/tld/custonTagLibrary.tld" prefix="cg" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>GW Sistemas - Painel de Entregas</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="author" content="Mateus Veloso">
        <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.4.1/css/all.css" crossorigin="anonymous">
        <link href="${homePath}/assets/css/jquery-ui-min.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/easyui.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="${homePath}/assets/css/inputs-gw.css" type="text/css"/>
        <link href="${homePath}/gwTrans/painel/css/painel.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
    </head>
    <body>
        <header>
            <div class="logo-title">
                <label>Painel de Entregas</label>
                <img src="${homePath}/gwTrans/painel/img/trans_white.png" class="logo-title-gw">
            </div>
            <div class="container-logo">
                <img id="logoCliente" class="logo-cliente" width="68px" height="44px" src="${homePath}/img/logoCliente/${nomeLogoCliente}">
            </div>
        </header>
        <nav class="nav-menu-lateral">
            <label class="title-filtros">Filtros</label>
            <i class="fechar-menu-lateral fa fa-times"></i>
            <ul class="ul-nav-menu-lateral">
                <li class="li-nav-menu-lateral" id="filtros">
                    <i class="fa fa-search" id="filtros"></i>
                </li>
                <li class="li-nav-menu-lateral" id="ajustes">
                    <i class="fa fa-cogs" id="ajustes"></i>
                </li>
            </ul>
            <div class="container-filtros container-filtros-ajustes">
                <label class="lb-filtros-ajustes">Modo de exibição</label>
                <div class="container-estilo-layout">
                    <input type="radio" class="radio-layout" name="estilo-layout" id="estilo-layout-card" checked value="card"/>
                    <label for="estilo-layout-card"><i class="fa fa-address-card icon-modo-layout" ></i></label>
                    <input type="radio" class="radio-layout" name="estilo-layout" id="estilo-layout-table" value="table"/>
                    <label for="estilo-layout-table"><i class="fa fa-table icon-modo-layout"></i></label>
                    <input type="radio" class="radio-layout" name="estilo-layout" id="estilo-layout-grafico" value="grafico"/>
                    <label for="estilo-layout-grafico"><i class="fa fa-chart-bar icon-modo-layout"></i></label>
                    <!--<label for="tipoImpressaoPendenciaMacroPdf"><img src="assets/img/btn_pdf.png" alt=""></label>-->

                    <!--<select id="estilo-layout">-->
                    <!--<option value="table">Tabela</option>-->
                    <!--<option value="card" selected="">Card</option>-->
                    <!--<option value="grafico">GrÃ¡ficos</option>-->
                    <!--</select>-->
                </div>
                <label class="lb-tempo-resultados">Tempo de atualização dos Resultados</label>
                <div class="container-estilo-layout">
                    <select class="select-atualizar-resultados" id="select-atualizar-resultados">
                        <option value="0" selected="">Não atualizar</option>
                        <option value="5">5 Minutos</option>
                        <option value="10">10 Minutos</option>
                        <option value="20">20 Minutos</option>
                        <option value="30">30 Minutos</option>
                        <option value="60">60 Minutos</option>
                    </select>
                </div>
            </div>
            <div class="container-filtros container-filtros-filtros">
                <div class="container-texto">
                    <label>Emissão Entre</label>
                </div>
                <div class="container-campo">
                    <div class="container-campo-data">
                        <input class="input-form-gw" name="emitidoEm" id="emitidoEm" type="text" value="${cg:getDataAtual()}" >
                    </div>
                    <div class="container-campo-data">
                        <input class="input-form-gw" name="emitidoAte" id="emitidoAte" type="text" value="${cg:getDataAtual()}" >
                    </div>
                </div>
                <div class="container-texto">
                    <label>Mostrar</label>
                </div>
                <div class="container-campo">
                    <div class="container-campo-radio">
                        <input type="radio" value="AMBOS" name="radio-mostrar" id="radio-mostrar-ambos" checked="">
                        <label for="radio-mostrar-ambos">Ambos</label>
                    </div>
                    <div class="container-campo-radio">
                        <input type="radio" value="MAN" name="radio-mostrar" id="radio-mostrar-manifestos">
                        <label for="radio-mostrar-manifestos">Manifestos</label>
                    </div>
                    <div class="container-campo-radio">
                        <input type="radio" value="ROM" name="radio-mostrar" id="radio-mostrar-romaneios">
                        <label for="radio-mostrar-romaneios">Romaneios</label>
                    </div>
                </div>
                <div class="container-texto">
                    <select id="select-exceto-apenas-filial" name="select-exceto-apenas-filial">
                        <option value="apenas">Apenas as filiais</option>
                        <option value="exceto">Exceto as filiais</option>
                    </select>
                </div>
                <div class="container-campo">
                    <div class="container-campo-inp-multiplo">
                        <input class="input" type="text" id="inptFilial" name="inptFilial" readonly="true" placeholder="">
                    </div>
                    <div class="container-campos-bt-input-multiplo">
                        <a href="javascript:" onclick="checkSession(function () {
                                    removerValorInput('inptFilial', true);
                                }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                        <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarFilial');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                        <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                    </div>
                </div>
                <div class="container-texto">
                    <select id="select-exceto-apenas-veiculo" name="select-exceto-apenas-veiculo">
                        <option value="apenas">Apenas os veículos</option>
                        <option value="exceto">Exceto os veículos</option>
                    </select>
                </div>
                <div class="container-campo">
                    <div class="container-campo-inp-multiplo">
                        <input class="input" type="text" id="inptVeiculo" name="inptVeiculo" readonly="true" placeholder="">
                    </div>
                    <div class="container-campos-bt-input-multiplo">
                        <a href="javascript:" onclick="checkSession(function () {
                                    removerValorInput('inptVeiculo', true);
                                }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                        <a href="javascript:alterarTipo('veiculo');checkSession(function(){controlador.acao('abrirLocalizar','localizarVeiculoGeral');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                    </div>
                </div>
                <div class="container-texto">
                    <select id="select-exceto-apenas-motorista" name="select-exceto-apenas-motorista">
                        <option value="apenas">Apenas os motoristas</option>
                        <option value="exceto">Exceto os motoristas</option>
                    </select>
                </div>
                <div class="container-campo">
                    <div class="container-campo-inp-multiplo">
                        <input class="input" type="text" id="inptMotorista" name="inptMotorista" readonly="true" placeholder="">
                    </div>
                    <div class="container-campos-bt-input-multiplo">
                        <a href="javascript:" onclick="checkSession(function () {
                                    removerValorInput('inptMotorista', true);
                                }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                        <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarMotorista');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                        <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                    </div>
                </div>
                <div class="container-texto">
                    <select id="select-exceto-apenas-setor" name="select-exceto-apenas-setor">
                        <option value="apenas">Apenas os setores de entrega</option>
                        <option value="exceto">Exceto os setores de entrega</option>
                    </select>
                </div>
                <div class="container-campo">
                    <div class="container-campo-inp-multiplo">
                        <input class="input" type="text" id="inptSetorEntrega" name="inptSetorEntrega" readonly="true" placeholder="">
                    </div>
                    <div class="container-campos-bt-input-multiplo">
                        <a href="javascript:" onclick="checkSession(function () {
                                    removerValorInput('inptSetorEntrega', true);
                                }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                        <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarSetorEntrega');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                        <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                    </div>
                </div>
                <div class="container-texto">
                    <select id="select-exceto-apenas-uf-destino" name="select-exceto-apenas-uf-destino">
                        <option value="apenas">Apenas as uf de destino</option>
                        <option value="exceto">Exceto as uf de destino</option>
                    </select>
                </div>
                <div class="container-campo">
                    <div class="container-campo-inp-multiplo">
                        <input class="input" type="text" id="inptUfDestino" name="inptUfDestino" readonly="true" placeholder="">
                    </div>
                    <div class="container-campos-bt-input-multiplo">
                        <a href="javascript:" onclick="checkSession(function () {
                                    removerValorInput('inptUfDestino', true);
                                }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                        <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarUfDestino');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                        <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                    </div>
                </div>
                <div class="container-texto">
                    <select id="select-exceto-apenas-cidades-destino" name="select-exceto-apenas-cidades-destino">
                        <option value="apenas">Apenas as cidades de destino</option>
                        <option value="exceto">Exceto as cidades de destino</option>
                    </select>
                </div>
                <div class="container-campo">
                    <div class="container-campo-inp-multiplo">
                        <input class="input" type="text" id="inptCidades" name="inptCidades" readonly="true" placeholder="">
                    </div>
                    <div class="container-campos-bt-input-multiplo">
                        <a href="javascript:" onclick="checkSession(function () {
                                    removerValorInput('inptCidades', true);
                                }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                        <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarCidade');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                        <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                    </div>
                </div>
                <div class="container-texto">
                    <select id="select-exceto-apenas-cliente" name="select-exceto-apenas-cliente">
                        <option value="apenas">Apenas os clientes</option>
                        <option value="exceto">Exceto os clientes</option>
                    </select>
                </div>
                <div class="container-campo">
                    <div class="container-campo-inp-multiplo">
                        <input class="input" type="text" id="inptCliente" name="inptCliente" readonly="true" placeholder="">
                    </div>
                    <div class="container-campos-bt-input-multiplo">
                        <a href="javascript:" onclick="checkSession(function () {
                                    removerValorInput('inptCliente', true);
                                }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                        <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarCliente');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                        <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                    </div>
                </div>
            </div>
            <div class="container-bt-consulta">
                <input type="button" value="Pesquisar" class="searchButton" id="search" onclick="pesquisar(true);">
            </div>
        </nav>
        <section class="section-dados sortable"></section>
        <section class="section-grafico">
            <div class="cobre-grafico"></div>


            <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
            <div class="container-graficos container-card-graf">
                <span class="bt-exportar-excel" id="bt-exportar-excel-card" onclick="gerarExcelGraficoCard();"></span>
                <div id="graf-card-performance" class="graf-card-performance" data-donut="0"></div>
                <div id="graf-card-ocupacao-peso" class="graf-card-ocupacao-peso" data-donut="0"></div>
                <div id="graf-card-ocupacao-cubagem" class="graf-card-ocupacao-cubagem" data-donut="0"></div>
            </div>
            <div class="container-graficos">
                <div class="bt-exportar-excel" id="bt-exportar-excel-pizza" onclick="gerarExcelGraficoPizza();"></div>
                <div id="graf-pizza-peso" style="width: 33.33%; height: 400px;float: left;"></div>
                <div id="graf-pizza-volume" style="width: 33.33%; height: 400px;float: left;"></div>
                <div id="graf-pizza-vl-carga" style="width: 33.33%; height: 400px;float: left;"></div>
            </div>
            <div class="container-graficos">
                <div class="bt-exportar-excel" id="bt-exportar-excel-barra" onclick="gerarExcelGraficoBar();"></div>
                <div id="graf-barra-qtd-entregas-cliente" style="width: 100%; height: 300px;float: left;"></div>
                <div id="graf-barra-qtd-entregas-destino" style="width: 100%; height: 300px;float: left;"></div>
                <div id="graf-barra-qtd-entregas-veiculo" style="width: 100%; height: 300px;float: left;"></div>
            </div>
        </section>
        <img class="gif-bloq-tela" src="${homePath}/img/espere_new.gif" alt=""/>
        <div class="bloqueio-tela"></div>
        <div class="cobre-tudo"></div>
        <div class="container-mais-informacao"></div>
        <div class="localiza"></div>
        <div class="localiza"></div>
        <div class="localiza"></div>
        <div class="localiza"></div>
        <div class="localiza"></div>
        <div class="localiza"></div>
        <div class="localiza"></div>
        <script>
                    const homePath = '${homePath}';
                    const usuario = '${user.nome}';
                    document.getElementById('logoCliente').onerror = function () {
                        jQuery('#logoCliente').attr('src', '${homePath}/assets/img/no-image.png');
                    };
        </script>
        <script src="https://code.jquery.com/jquery-3.3.1.min.js" crossorigin="anonymous"></script>
        <script src="${homePath}/assets/alerts/alerts-min.js" type="text/javascript"></script>
        <jsp:include page="/importAlerts.jsp">
            <jsp:param name="caminhoImg" value="assets/img/gw-trans.png"/>
            <jsp:param name="nomeUsuario" value="${user.nome}"/>
        </jsp:include>
        <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
        <script src="https://d3js.org/d3.v3.min.js"></script>
        <script src="${homePath}/assets/js/jquery.mask.min.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.11.6/xlsx.core.min.js"></script>
        <script src="https://cdn.jsdelivr.net/alasql/0.3/alasql.min.js"></script>
        <script src="${homePath}/gwTrans/painel/js/painel.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script defer src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/script/validarSessao.js" type="text/javascript"></script>
    </body>
</html>
