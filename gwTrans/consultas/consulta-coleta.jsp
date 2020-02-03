<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>
<%-- 
    Document   : consulta-coleta
    Created on : 05/01/2017, 10:58:41
    Author     : Mateus
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="/WEB-INF/tld/custonTagLibrary.tld" prefix="cg" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<jsp:useBean id="random" class="java.util.Random" scope="application" />
<%@page contentType="text/html" pageEncoding="ISO-8859-9"%>
<!DOCTYPE html>
<html>
    <head>
        <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${tema}.css?v=${random.nextInt()}">
        <!--<script src="../../assets/js/LAB.min.js" type="text/javascript"></script>-->
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-9">
        <title>GW Trans - Consulta de Coletas</title>
        <script src="${homePath}/script/jQuery/jquery.js" type="text/javascript"></script>
        <script src="${homePath}/assets/alerts/alerts-min.js" type="text/javascript"></script>
        <jsp:include page="/importAlerts.jsp">
            <jsp:param name="caminhoImg" value="assets/img/gw-trans.png"/>
            <jsp:param name="nomeUsuario" value="${user.nome}"/>
        </jsp:include>
        <link href="${homePath}/assets/css/jquery-ui-min.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/bootstrap-custom-col.css" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="${homePath}/assets/css/easyui.css">
        <link rel="stylesheet" href="${homePath}/assets/css/consulta.css?v=${random.nextInt()}">	
        <link rel="stylesheet" href="${homePath}/assets/css/inputs-gw.css" type="text/css"/>
        <link rel="stylesheet" href="${homePath}/assets/css/font-roboto.css">	
        <!--<link href='http://fonts.googleapis.com/css?family=Roboto' rel='stylesheet' type='text/css'>-->
        <link href="${homePath}/gwTrans/consultas/css/consulta-coleta.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/select-multiplo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/select-multiplo-grupo-gw.css" rel="stylesheet" type="text/css"/>
        <script src="${homePath}/assets/js/coluna_ajuda_filtros.js"></script>
        <script defer src="${homePath}/script/validarSessao.js" type="text/javascript"></script>
        <script defer>
            var codigoTela = 'T00024';
            var codigo_tela = '24';
            var idPreferencia = 0;
            var homePath = '${homePath}';
        </script>
    </head>
    <body>
        <ul class="menu">
            <li><a id="copier" href="#">Copiar</a></li>
        </ul>
        <div class="load-preferencias">
            <div class="container-progress">
                <img class="caminhao" id="caminhao" src="${homePath}/img/loading.gif">
                <div class="cs-loader">
                    <div class="cs-loader-inner">
                        <label>	C</label>
                        <label>	A</label>
                        <label>	R</label>
                        <label>	R</label>
                        <label>	E</label>
                        <label>	G</label>
                        <label>	A</label>
                        <label>	N</label>
                        <label>	D</label>
                        <label>	O</label>
                    </div>
                </div>
                <div class="progress-porcentagem" id="progress-porcentagem">15%</div>
                <progress max="100" value="15" class="progress-preferencias" id="progress-preferencias">
                </progress>
                <!--<p>Carregando preferências</p>-->
            </div>
        </div>
        <img class="gif-bloq-tela-left" src="${homePath}/img/espere_new.gif" alt=""/>
        <div class="container-salvar-filtros">
            <iframe id="iframeSalvarFiltros" name="iframeSalvarFiltros" src="${homePath}/gwTrans/consultas/salvar_filtros.jsp" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
            <span class="seta-baixo"></span>
        </div>
        <div id="topo">
            <div id="logo">
                <h3>Consulta de Coletas<img src="${homePath}/assets/img/trans_white.png"></h3>
            </div>
            <div id="actions">
                <img id="logoCliente" width="68px" height="44px" src="">
                <ul>
                    <c:if test="${nivelUser >= 3}">
                        <li>
                            <span class="bt bt-cadastro" onclick="checkSession(function () {
                                        document.location.replace('./cadcoleta?acao=iniciar');
                                    }, false);">Novo Cadastro</span>
                        </li>
                    </c:if>
                    <li>
                        <span class="bt bt-coleta" onclick="checkSession(function () {
                                    document.location.replace('./bxcoleta?acao=iniciar');
                                }, false)">Baixar Coletas</span>
                    </li>
                    <li>
                        <span class="bt bt-import-coleta" onclick="checkSession(function () {
                                    document.location.replace('./importar_coleta.jsp?acao=iniciar');
                                }, false)">Importar Coletas (EDI)</span>
                    </li>
                    <li>
                        <span class="bt bt-processando-coleta" onclick="checkSession(function () {
                                    window.open('./ColetasAutomaticasControlador?acao=visualizar', 'Processar', 'top=10,left=0,height=900,width=1200,resizable=yes,status=1,scrollbars=1');
                                }, false);">Processar Coletas automáticas</span>
                    </li>
                    <li>
                        <span class="bt bt-relatorio" onclick="checkSession(function () {
                                    window.open('./relcoleta.jsp?acao=iniciar&modulo=webtrans', '_blank', 'toolbar=yes,scrollbars=yes,resizable=yes,top=200,left=500,width=800,height=600');
                                }, false);">Relatório</span>
                    </li>
                </ul>
            </div>
        </div>
        <div class="cobre-tudo"></div>
        <div class="visualizarDocumentos">
        </div>
        <div class="localiza">
        </div>
        <div class="localiza">
        </div>
        <div class="localiza">
        </div>
        <div class="localiza">
        </div>
        <div class="localiza">
        </div>
        <div class="localiza">
        </div>
        <div class="localiza">
        </div>
        <div class="localiza">
        </div>
        <div id="sidebar" class="heightDoc">
            <style>
                .columnLeft::-webkit-scrollbar{display: none;-ms-overflow-style: none;overflow: auto;}
                .columnLeft{-ms-overflow-style: none;};
            </style>
            <div class="columnLeft" id="columnLeft" style="z-index: 999;position: absolute;width: 25%;display: block;">
                <div class="cobre-left" style="width: 100%;height: 100%;background: #000;z-index: 999999999;position: absolute;display: none;"></div>
                <div class="content">
                    <form action="ConsultaControlador?codTela=24" method="POST" id="formConsulta" name="formConsulta">
                        <div class="item_form">
                            <label style="padding-bottom: 5px !important;">Pesquisas salvas dispóniveis</label>
                            <select class="input" id="select-pesquisa" name="select-pesquisa" onchange="">
                                <option value="0">Ultima pesquisa realizada</option>
                                <c:forEach var="listPrefPerso" items="${listaPreferenciasPersonalizadas}" varStatus="filtrosStatus" >
                                    <option value="${listPrefPerso}">${listPrefPerso}</option>
                                </c:forEach>
                            </select>
                            <!--<input type="button" value="Selecionar" class="searchButton" id="search" onclick="" style="width: 37%;margin-top: 0px;background: #057899;padding: 0;padding-top: 10px;padding-bottom: 10px;padding-left: 5px;padding-right: 5px;">-->
                        </div>
                        <div class="item_form" style="margin-bottom: 5px;">
                            <label>Filtro</label>
                            <select class="input" id="select-abrev" name="select-abrev" onchange="">
                                <c:forEach var="columnFiltroSelect" items="${tela.targetXml.columnFiltroSelect}" varStatus="rowStatus" >
                                    <option value="${columnFiltroSelect.name}">${columnFiltroSelect.label}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="item_form container-campos-select" style="margin-bottom: 5px;">
                            <select class="input" id="select-oper" name="select-oper" onchange="">
                                <option value="1" >Todas as partes com</option>
                                <option value="2">Apenas com o início</option>
                                <option value="3">Apenas com o fim</option>
                                <option value="4">Igual à palavra/frase</option>
                            </select>
                        </div>
                        <div class="item_form container-campos-select" style="margin-bottom: 0;">
                            <input type="text" id="inpSelectVal" name="inpSelectVal" data-pesquisar-id="#search">
                            <!--Necessario para que ele não de subimit sozinho com apenas um input text : Mateus--> 
                            <input type="text" id="t" style="display: none;">
                        </div>

                        <div class="item_form container-data" style="margin-bottom: 5px;">
                            <div class="item_form_half1">
                                <input class="easyui-datebox" id="dataDe" name="dataDe" value="${dataAtual}" style="width:100%;height:32px">
                            </div>
                            <div class="item_form_half2">
                                <input class="easyui-datebox" id="dataAte" name="dataAte" value="${dataAtual}" style="width:100%;height:32px">
                            </div>
                        </div>

                        <div class="item_form" style="margin-top: 5px;margin-bottom: 5px;">
                            <label>Ordenação dos resultados</label>
                            <div class="item_form_half left">
                                <select class="input" id="select-ordenacao" name="select-ordenacao" onchange="">
                                    <option value="">Selecione</option>
                                    <c:forEach var="columnOrdenacaoSelect" items="${tela.targetXml.columnOrdenacaoSelect}" varStatus="rowStatus" >
                                        <option value="${columnOrdenacaoSelect.name}">${columnOrdenacaoSelect.label}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="item_form_half right">
                                <select class="input" id="select-order-tipo" name="select-order-tipo" onchange="">
                                    <option value="asc">Ordem crescente</option>
                                    <option value="desc">Ordem decrescente</option>
                                </select>
                            </div>
                            <select class="input" name="select-limite" id="select-limite" onchange="">
                                <option value="10">Exibir 10 resultados por página</option>
                                <option value="20">Exibir 20 resultados por página</option>
                                <option value="30">Exibir 30 resultados por página</option>
                                <option value="40">Exibir 40 resultados por página</option>
                                <option value="50">Exibir 50 resultados por página</option>
                            </select>
                        </div>
                        <div id="filtros-adicionais-container" style="display: none;">
                            <div class="item_form" style="margin-bottom: 10px;">
                                <label for="createdMe">
                                    <input type="checkbox" name="createdMe" id="createdMe">
                                    Criados por mim
                                </label>
                            </div>
                            <div class="item_form" style="margin-bottom: 50px;margin-top: 10px;">
                                <select id="select-exceto-apenas-mostrar-coleta" name="select-exceto-apenas-mostrar-coleta">
                                    <option value="apenas">Apenas as coletas</option>
                                    <option value="exceto">Exceto as coletas</option>
                                </select>
                                <select id="select-mostrar-coleta" name="select-mostrar-coleta">
                                </select>
                            </div>
                            <div class="item_form" style="margin-bottom: 50px;margin-top: 10px;">
                                <select id="select-exceto-apenas-tipo-coleta" name="select-exceto-apenas-tipo-coleta">
                                    <option value="apenas">Apenas os Tipos</option>
                                    <option value="exceto">Exceto os Tipos</option>
                                </select>
                                <select id="select-tipo-coleta" name="select-tipo-coleta">
                                </select>
                            </div>
                            <div class="item_form" style="margin-bottom: 10px;">
                                <select id="select-exceto-apenas-filial" name="select-exceto-apenas-filial">
                                    <option value="apenas">Apenas as filiais</option>
                                    <option value="exceto">Exceto as filiais</option>
                                </select>
                                <div style="width: 70%;float: left;">
                                    <input class="input" type="text" id="inptFilial" name="inptFilial" readonly="true" placeholder="">
                                </div>
                                <div class="btns">
                                    <a href="javascript:" onclick="checkSession(function () {
                                                removerValorInput('inptFilial', true);
                                            }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                                    <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarFilial');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                                    <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                                </div>
                            </div>

                            <div class="item_form filtroFilialDestino" style="margin-bottom: 10px;">
                                <select id="select-exceto-apenas-filial-destino" name="select-exceto-apenas-filial-destino">
                                    <option value="apenas">Apenas as filiais de destino</option>
                                    <option value="exceto">Exceto as filiais de destino</option>
                                </select>
                                <div style="width: 70%;float: left;">
                                    <input class="input" type="text" id="inptFilialDestino" name="inptFilialDestino" readonly="true" placeholder="">
                                </div>
                                <div class="btns" id="limparFilialDestino">
                                    <a href="javascript:" onclick="checkSession(function () {
                                                removerValorInput('inptFilialDestino', true);
                                            }, false);" class="btnDelete btnDeleteFilialDestino" style="margin-top: 2px;"></a>
                                    <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarFilialDestino');},false);" class="btnMore btnMoreFilialDestino" style="float: right !important;margin-right: 5px;"></a>
                                </div>
                            </div> 

                            <div class="item_form" style="margin-bottom: 10px;">
                                <select id="select-exceto-apenas-cliente" name="select-exceto-apenas-cliente">
                                    <option value="apenas">Apenas os clientes</option>
                                    <option value="exceto">Exceto os clientes</option>
                                </select>
                                <div style="width: 70%;float: left;">
                                    <input class="input" type="text" id="inptCliente" name="inptCliente" readonly="true" placeholder="">
                                </div>
                                <div class="btns">
                                    <a href="javascript:" onclick="checkSession(function () {
                                                removerValorInput('inptCliente', true);
                                            }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                                    <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarCliente');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                                    <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                                </div>
                            </div> 

                            <div class="item_form" style="margin-bottom: 10px;">
                                <select id="select-exceto-apenas-destinatarios" name="select-exceto-apenas-destinatarios">
                                    <option value="apenas">Apenas os destinatários</option>
                                    <option value="exceto">Exceto os destinatários</option>
                                </select>
                                <div style="width: 70%;float: left;">
                                    <input class="input" type="text" id="inptDestinatarios" name="inptDestinatarios" readonly="true" placeholder="">
                                </div>
                                <div class="btns">
                                    <a href="javascript:" onclick="checkSession(function () {
                                                removerValorInput('inptDestinatarios', true);
                                            }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                                    <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarDestinatario');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                                    <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                                </div>
                            </div>

                            <div class="item_form" style="margin-bottom: 10px;">
                                <select id="select-exceto-apenas-motorista" name="select-exceto-apenas-motorista">
                                    <option value="apenas">Apenas os motoristas</option>
                                    <option value="exceto">Exceto os motoristas</option>
                                </select>
                                <div style="width: 70%;float: left;">
                                    <input class="input" type="text" id="inptMotorista" name="inptMotorista" readonly="true" placeholder="">
                                </div>
                                <div class="btns">
                                    <a href="javascript:" onclick="checkSession(function () {
                                                removerValorInput('inptMotorista', true);
                                            }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                                    <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarMotorista');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                                    <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                                </div>
                            </div>

                            <div class="item_form" style="margin-bottom: 10px;">
                                <select id="select-exceto-apenas-veiculo" name="select-exceto-apenas-veiculo">
                                    <option value="apenas">Apenas os veículos</option>
                                    <option value="exceto">Exceto os veículos</option>
                                </select>
                                <div style="width: 70%;float: left;">
                                    <input class="input" type="text" id="inptVeiculo" name="inptVeiculo" readonly="true" placeholder="">
                                </div>
                                <div class="btns">
                                    <a href="javascript:" onclick="checkSession(function () {
                                                removerValorInput('inptVeiculo', true);
                                            }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                                    <a href="javascript:alterarTipo('veiculo');checkSession(function(){controlador.acao('abrirLocalizar','localizarVeiculoGeral');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                                    <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                                </div>
                            </div>

                            <div class="item_form" style="margin-bottom: 10px;">
                                <select id="select-exceto-apenas-cidade-co" name="select-exceto-apenas-cidade-co">
                                    <option value="apenas">Apenas as cidades de coleta</option>
                                    <option value="exceto">Exceto as cidades de coleta</option>
                                </select>
                                <div style="width: 70%;float: left;">
                                    <input class="input" type="text" id="inptCidade" name="inptCidadeCo" readonly="true" placeholder="">
                                </div>
                                <div class="btns">
                                    <a href="javascript:" onclick="checkSession(function () {
                                                removerValorInput('inptCidadeCo', false);
                                            }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                                    <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarCidade');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                                    <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                                </div>
                            </div>

                            <div class="item_form" style="margin-bottom: 10px;">
                                <select id="select-exceto-apenas-cidade-de" name="select-exceto-apenas-cidade-de">
                                    <option value="apenas">Apenas as cidades de destino</option>
                                    <option value="exceto">Exceto as cidades de destino</option>
                                </select>
                                <div style="width: 70%;float: left;">
                                    <input class="input" type="text" id="inptCidadeDe" name="inptCidadeDe" readonly="true" placeholder="">
                                </div>
                                <div class="btns">
                                    <a href="javascript:" onclick="checkSession(function () {
                                                removerValorInput('inptCidadeDe', false);
                                            }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                                    <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarCidadeDestino');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                                    <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                                </div>
                            </div>
                        </div>
                        <div class="item_form" id="filtros-adicionais" style="width: auto;">
                            <span class="seta-exibir-filtros-adicionais"></span>
                            <a href="javascript:;" id="toogle_options_details">Exibir filtros adicionais</a>
                        </div>
                    </form>
                    <div class="centerContent">
                        <input type="button" value="Pesquisar Coletas" class="searchButton" id="search" onclick="checkSession(function () {
                                        consulta();
                                    }, false);">
                    </div>
                    <div class="salvarPesquisaContainer validarSessao">
                        <label id="salvarFiltros" nome="salvarFiltros" class="validarSessao">Salvar Pesquisa</label>
                    </div>
                </div>
            </div>
            <div class="columnRight">
                <button type="button" data-name="hide" id="toggle" name="toggle" style="margin-left: -70px !important;border-radius: 5px!important;min-width: 150px !important;width:150px !important;" class="toogleOn">Ocultar filtros</button>
                <button type="button" data-name="show" id="toggle" name="toggleAjuda" style="margin-top: 105px !important;min-width: 150px !important;width:150px !important;border-radius: 5px !important;margin-left: -72px !important;" class="toogleOnAjuda">Exibir Ajuda</button>
                <button type="button" data-name="show" id="toggle" name="toggleAuditoria" style="margin-top: 115px !important;min-width: 170px !important;width:170px !important;border-radius: 5px !important;margin-left: -82px !important;" class="toggle">Exibir Auditoria</button>
            </div>
            <style>#columnLeftAjuda::-webkit-scrollbar{overflow: auto;}</style>
            <div class="notificacao" style="top: 397px !important;margin-left: 26.2% !important;"><center><label>0</label></center></div>
            <div class="seta-conteudo-notificacao" style="top: 412px !important;margin-left: 26% !important;"></div>
            <div class="conteudo-notificacao" style="top: 422px !important;margin-left: 25.8% !important;">
                <div>
                    <span>Notificação</span>
                    <p>Existem videos novos relacionados a tela.</p>
                </div>
            </div>
            <div class="columnLeft column-left-ajuda" id="columnLeftAjuda" style="z-index: 999;position: absolute;width:0px;">
                <div class="content">
                    <form action="${homePath}/FilialControlador?acao=listarFilial">
                        <div class="item_form" style="margin-bottom: 5px;margin-top: 30px;display: none;">
                            <div class="helper">
                                <div class="corpo_helper">
                                    <label class="campo-helper" style="margin-left: 5px;"><h2>Ajuda</h2></label>
                                    <hr>
                                    <label class="descri-helper"><h3>Passe o mouse sobre o campo que deseja ajuda.</h3></label>
                                </div>
                            </div>
                        </div>
                        <div class="item_form" style="">
                            <div class="permissoes_tela">
                                <h3 class="h3-permissoes" style="">Permissões de acesso desta tela</h3>
                                <hr style="margin:5px;padding:0;">
                                <div class="col-md-12">
                                    <table class="table_permissao" cellspacing="0">
                                        <thead>
                                            <tr>
                                                <th width="10%">Código</th>
                                                <th width="40%">Descrição</th>
                                                <th width="40%">Observação</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <c:if test="${fn:length(listVideosTela) > 0}">
                            <center class="div-lb-videos-ajuda"><h3 class="h3-video" style="">Vídeos de  Ajuda</h3></center>
                            <hr style="margin:5px;padding:0;">
                            <div class="item_form"  style="margin-bottom: 0px;">
                                <div class="conteudo-videos-relacionados">
                                    <c:forEach items="${listVideosTela}" var="video" varStatus="videoStatus">
                                        <div class="container-video" id="container-video">
                                            <div class="col-md-6">
                                                <c:if test="${video.isNovo}">
                                                    <script>
                                                        addNotificacao();
                                                    </script>
                                                    <img src="assets/img/novo_video.png" alt=""/>
                                                </c:if>
                                                <c:if test="${!video.isNovo}">
                                                    <img src="assets/img/ja_visto.png" alt=""/>
                                                </c:if>
                                                <input type="hidden" value="${video.id}" name="idVideo${videoStatus.count}" id="idVideo${videoStatus.count}">
                                                <iframe src="${video.url}" id="video${videoStatus.count}" class="videos-tela" scrolling="no" frameborder="0" allowfullscreen></iframe>
                                            </div>
                                            <div class="col-md-6">
                                                <span class="texto-video">${video.titulo}<p>${video.descricao}</p></span>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                            <hr style="margin:0;padding:0;margin-bottom: 100px;">
                        </c:if>

                    </form>
                </div>
            </div>
            <jsp:include page="auditoria.jsp" />
            <input type="hidden" name="inp-auditoria" data-exclusao="true" data-rotina-auditoria="pedidos">
        </div>
        <div id="map" class="heightDoc" style="overflow-y: hidden;">
            <div id="contentMap" style="">
                <div class="container-grid" style="display: block;">
                    <script>
                        setTimeout(function () {
                            document.getElementById('progress-preferencias').value = 40;
                            document.getElementById('progress-porcentagem').innerHTML = '40%';
                        }, 10);
                    </script>
                    <%@ include file="grid-consulta-coleta.jsp" %>
                    <script>
                        setTimeout(function () {
                            document.getElementById('progress-preferencias').value = 90;
                            document.getElementById('progress-porcentagem').innerHTML = '90%';
                        }, 10);
                    </script>
                </div>
            </div>
            <div id="footerTable" style="height: 145px;display: none;">

                <div class="footerTableImpressao">
                    <div class="footer01">
                        <c:if test="${nivelUser >= 4}">
                            <button id="removeCte" class="removeCteOff" style="margin-top: 45px;" disabled="true" onclick="checkSession(function () {
                                        excluirColetas();
                                    }, false);">
                                <img src="${homePath}/assets/img/icon-remove-off.png">Excluir selecionadas</button>
                            </c:if>
                    </div>
                    <div class="footer02">
                        <label class="footer02-topo-label">Ação</label>
                        <label for="impressaoN" class="radio" style="color: #888;"><input type="radio" name="formaImpressao" value="0" id="impressaoN" checked="">Imprimir PDF</label>
                        <label for="impressaoM" class="radio" style="color: #888;"><input type="radio" name="formaImpressao" value="1" id="impressaoM">Imprimir em Matricial</label>
                        <label for="exportar" class="radio" style="color: #888;"><input type="radio" name="formaImpressao" value="2" id="exportar">Exportar</label>
                    </div>
                    <div class="footer03">
                        <div class="footer03-01">
                            <label impressaoPDF="true">Modelo de Impressão</label>
                            <select name="cbmodelo" id="cbmodelo">
                                <option value="1" <c:if test="${config.getRelDefaultColeta() == '1'}">selected</c:if>>Modelo 1 (Coleta)</option>
                                <option value="2" <c:if test="${config.getRelDefaultColeta() == '2'}">selected</c:if>>Modelo 2 (Coleta)</option>
                                <option value="3" <c:if test="${config.getRelDefaultColeta() == '3'}">selected</c:if>>Modelo 3 (Coleta)</option>
                                <option value="4" <c:if test="${config.getRelDefaultColeta() == '4'}">selected</c:if>>Modelo 4 (Coleta)</option>
                                <option value="5" <c:if test="${config.getRelDefaultColeta() == '5'}">selected</c:if>>Modelo 5 (Coleta)</option>
                                <option value="6" <c:if test="${config.getRelDefaultColeta() == '6'}">selected</c:if>>Modelo 6 (OS)</option>
                                <option value="7" <c:if test="${config.getRelDefaultColeta() == '7'}">selected</c:if>>Modelo 7 (Coleta)</option>
                                <option value="8" <c:if test="${config.getRelDefaultColeta() == '8'}">selected</c:if>>Modelo 8 (Relatório de embarque)</option>
                                <option value="9" <c:if test="${config.getRelDefaultColeta() == '9'}">selected</c:if>>Modelo 9 (Coleta Container)</option>
                                <option value="10" <c:if test="${config.getRelDefaultColeta() == '10'}">selected</c:if>>Modelo 10 (Coleta Container)</option>
                                <option value="11" <c:if test="${config.getRelDefaultColeta() == '11'}">selected</c:if>>Modelo 11 (Coleta Container)</option>
                                <option value="12" <c:if test="${config.getRelDefaultColeta() == '12'}">selected</c:if>>Modelo 12 (Coleta Container)</option>
                                <option value="13" <c:if test="${config.getRelDefaultColeta() == '13'}">selected</c:if>>Modelo 13 (Coleta)</option>
                                <option value="14" <c:if test="${config.getRelDefaultColeta() == '14'}">selected</c:if>>Modelo 14 (Coleta BUNGE)</option>
                                <option value="15" <c:if test="${config.getRelDefaultColeta() == '15'}">selected</c:if>>Modelo 15 (Coleta)</option>
                                <option value="16" <c:if test="${config.getRelDefaultColeta() == '16'}">selected</c:if>>Modelo 16 (Paletização)</option>
                                <option value="17" <c:if test="${config.getRelDefaultColeta() == '17'}">selected</c:if>>Modelo 17 (Declaração das Condições da Carga)</option>
                                <option value="18" <c:if test="${config.getRelDefaultColeta() == '18'}">selected</c:if>>Modelo 18 (Coleta)</option>
                                <option value="19" <c:if test="${config.getRelDefaultColeta() == '19'}">selected</c:if>>Modelo 19 (Coleta Aérea)</option>
                                <c:if test="${config.isGeraGEMColeta()}">
                                    <option value="md" <c:if test="${config.getRelDefaultColeta() == 'md'}">selected</c:if>>Mapa de descarga(gwLogis)</option>
                                    <option value="cr" <c:if test="${config.getRelDefaultColeta() == 'cr'}">selected</c:if>>Comprovante de Recebimento(gwLogis)</option>
                                    <option value="co" <c:if test="${config.getRelDefaultColeta() == 'co'}">selected</c:if>>Controle de ocorrências(gwLogis)</option>
                                </c:if>

                                <c:forEach items="${relPersonalizadoColeta}" var="rel">
                                    <c:set var="relCompleto" value="doc_coleta_personalizado_${rel}" />
                                    <option value="doc_coleta_personalizado_${rel}" <c:if test="${config.getRelDefaultColeta() == relCompleto}">selected</c:if>>Modelo ${rel.toUpperCase()} (Personalizado)</option>
                                </c:forEach>

                            </select>
                            <label impressaoMatricial="true" style="margin-top: 5px !important;">Impressora</label>
                            <select name="impressora" id="impressora" >
                                <c:forEach items="${impressoras}" var="impressora">
                                    <option value="${impressora}" <c:if test="${impressora == impressoraUsuario}">selected</c:if> >${impressora}</option>
                                </c:forEach>
                            </select>
                            <label impressaoMatricial="true" style="margin-top: 5px !important;">Driver</label>
                            <select name="driverImpressora" id="driverImpressora">
                                <c:forEach items="${drivers}" var="driver">
                                    <option value="${driver}">${driver}</option>
                                </c:forEach>
                            </select>

                            <label exportar="true">Exportar para</label>
                            <select name="exportarPara" id="exportarPara">
                                <option value="ATM" Selected>Averba&ccedil;&atilde;o (AT&amp;M)</option>
                                <option value="APISUL">Averba&ccedil;&atilde;o (APISUL)</option>
                                <c:forEach items="${listaLayout}" var="layout">
                                    <option value="${layout.getId()}!!funcEdi">${layout.getDescricao()}</option>
                                </c:forEach>
                            </select>

                        </div>
                        <div class="footer03-02">
                            <div class="bt bt-impressao" onclick="popColeta();">Imprimir</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <img class="gif-bloq-tela" src="${homePath}/img/espere_new.gif" alt=""/>
        <div class="bloqueio-tela"></div>
        <input id="copy" value="" onclick="this.select();" readonly="true" style="display: none;">
        <script src="${homePath}/assets/js/jquery-ui.min.js" type="text/javascript"></script>
        <script defer src="${homePath}/script/shortcut.js" type="text/javascript"></script>
        <script defer src="${homePath}/assets/js/jquery.mask.min.js"></script>
        <script defer src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/script/funcoesTelaConsulta.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/gwTrans/consultas/js/consulta-coleta.js?v=${random.nextInt()}"></script>
        <script defer src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script defer src="${homePath}/assets/js/jquery.easyui.min.js"></script>
        <script defer type='text/javascript'>     
            var tipo = new filtro('veiculo');
            var tema = '${tema}';

            function alterarTipo(e) {
                tipo.setTipo(e);
            }

            function proxima() {
                var parametros =
                        "&paginaAtual=" +${consulta.paginacao.paginaAtual+1}
                + "&select-limite=" +${consulta.paginacao.limiteResultados}
                + "&paginas=" +${consulta.paginacao.paginas};

                location.replace("ConsultaControlador?codTela=" + codigo_tela + parametros);

            }
            function anterior() {
                var parametros =
                        "&paginaAtual=" +${consulta.paginacao.paginaAtual-1}
                + "&select-limite=" +${consulta.paginacao.limiteResultados}
                + "&paginas=" +${consulta.paginacao.paginas};

                location.replace("ConsultaControlador?codTela=" + codigo_tela + parametros);

            }
            function paginaEnter(evn, pagina) {
                if (evn.keyCode == 13) {
                    var parametros =
                            "&paginaAtual=" + pagina
                            + "&select-limite=" +${consulta.paginacao.limiteResultados}
                    + "&paginas=" +${consulta.paginacao.paginas};
                    location.replace("ConsultaControlador?codTela=" + codigo_tela + parametros);
                }

            }
            jQuery(document).ready(function () {
                //Ativa a footer pós carregamento:
                jQuery('#footerTable').show();

                document.getElementById('logoCliente').onerror = function () {
                    jQuery('#logoCliente').attr('src', '${homePath}/assets/img/no-image.png');
                };
            <c:if test="${pref != null}">
                <c:set var="ordenacao" value="${fn:split(pref.ordenacao, ' ')}" />
                jQuery('#select-ordenacao option[value=' + '${ordenacao[0]}' + ']').prop('selected', true);
                jQuery("#select-ordenacao").selectmenu("refresh");
                jQuery('#select-order-tipo option[value=' + '${ordenacao[1]}' + ']').prop('selected', true);
                jQuery("#select-order-tipo").selectmenu("refresh");
                jQuery('#select-limite option[value=' + '${pref.limiteResultados}' + ']').prop('selected', true);
                jQuery("#select-limite").selectmenu("refresh");
                <c:forEach var="filtros" items="${pref.filtros}" varStatus="filtrosStatus" >
                    <c:if test="${filtrosStatus.count == 1}">
                jQuery('#select-abrev option[value=' + '${filtros.colunaNome}' + ']').prop('selected', true);
                jQuery("#select-abrev").selectmenu("refresh");
                jQuery('#select-oper option[value=' + '${filtros.operador}' + ']').prop('selected', true);
                jQuery("#select-oper").selectmenu("refresh"); 
                    </c:if>
                </c:forEach>
                changeSelectAbrev();
                <c:forEach var="filtros" items="${pref.filtros}" varStatus="filtrosStatus" >
                gerenciarInpSelectVal('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.colunaValor2}');
                gerenciarCheckBox('${filtros.colunaNome}', '${filtros.colunaValor}');
                gerenciarMostrarColetas('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.colunaCondicaoLocalizar}', '${filtros.descricao}');
                gerenciarTipoColeta('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.colunaCondicaoLocalizar}', '${filtros.descricao}');
                gerenciarInpFilial('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                gerenciarInpFilialDestino('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                gerenciarInpCliente('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                gerenciarInpDestinatario('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                gerenciarInpMotorista('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                gerenciarInpVeiculo('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                gerenciarInpCidadeCo('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                gerenciarInpCidadeDe('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                    <c:if test="${filtrosStatus.last}">
                        ativarExcetosMultiplosGw();
                    </c:if>
                </c:forEach>
                    //ESTAVA ATULIZANDO A DATA PARA O DIA ATUAL
//                    changeSelectAbrev();
            </c:if>

            <c:if test="${filtroEscolhido != null}">
                jQuery('#select-pesquisa').val('${filtroEscolhido}').change();
                jQuery("#select-pesquisa").selectmenu("refresh");
            </c:if>


                jQuery('#select-exceto-apenas-vendedor').selectExcetoApenasGw({
                    width: '170px'
                });

                jQuery('#select-exceto-apenas-supervisor').selectExcetoApenasGw({
                    width: '170px'
                });
                <c:if test="${!temacessofiliaisDestino && isFranquia}">
                    removerValorInput('inptFilialDestino');
                    jQuery('.btnMoreFilialDestino').hide();
                    jQuery('.btnDeleteFilialDestino').hide();
                    addValorAlphaInput('inptFilialDestino', '${user.filial.abreviatura}', '${user.filial.idfilial}', true);
                    jQuery('.inputFilialDestino').find('.gamma-li-chaves').css('background', '#c2c2c2');
                    jQuery('.inputFilialDestino').find('.gamma-li-chaves-a').remove();
                    jQuery("#select-exceto-apenas-filial-destino").selectExcetoApenasGw({
                        width: '170px',
                        readOnly: true
                    });
                </c:if>
                <c:if test="${!isFranquia || (temacessofiliaisDestino && isFranquia)}">
                    jQuery('.btnMoreFilialDestino').show();
                    jQuery('.btnDeleteFilialDestino').show();
                    jQuery('#select-exceto-apenas-filial-destino').selectExcetoApenasGw({
                        width: '170px'
                    });
                </c:if> 
                   //COMENTEI ESTAVA ATULIZANDO A DATA PARA O DIA ATUAL
//                setTimeout(function () {
//                    jQuery('#dataDe').datebox().bind('focusout', function (e) {
//                        completarData(this, e);
//                    });
//
//                    jQuery('#dataAte').datebox('textbox').bind('focusout', function (e) {
//                        completarData(this, e);
//                    });
//                }, 1000);

                //Altera o src do salvarFiltros para passar por parametro o filtro escolhido.
                jQuery('#iframeSalvarFiltros').attr('src', jQuery('#iframeSalvarFiltros').attr('src') + '?nomePesquisa=' + jQuery('#select-pesquisa').val() + '&isPrivada=' + true);

                //Adiciona os iframes.
                setTimeout(function () {
                    jQuery('.visualizarDocumentos').html('<iframe id="iframeVisualizarDocumentos" name="iframeVisualizarDocumentos" src="" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                    jQuery(jQuery('.localiza')[0]).html('<iframe id="localizarFilial" input="inptFilial" name="localizarFilial" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarFilial&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                    jQuery(jQuery('.localiza')[1]).html('<iframe id="localizarCliente" input="inptCliente" name="localizarCliente" src="LocalizarControlador?acao=abrirLocalizar&tipoLocalizar=localizarCliente&idLocalizar=localizarCliente&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                    jQuery(jQuery('.localiza')[2]).html('<iframe id="localizarDestinatario" input="inptDestinatarios" name="localizarDestinatario" src="LocalizarControlador?acao=abrirLocalizar&tipoLocalizar=localizarDestinatario&idLocalizar=localizarDestinatario&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                    jQuery(jQuery('.localiza')[3]).html('<iframe id="localizarMotorista" input="inptMotorista" name="localizarMotorista" src="LocalizarControlador?acao=abrirLocalizar&tipoLocalizar=localizarMotorista&idLocalizar=localizarMotorista&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                    jQuery(jQuery('.localiza')[4]).html('<iframe id="localizarVeiculoGeral" input="inptVeiculo" name="localizarVeiculoGeral" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarVeiculoGeral&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                    jQuery(jQuery('.localiza')[5]).html('<iframe id="localizarCidade" input="inptCidade" name="localizarCidadeCo" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarCidade&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                    jQuery(jQuery('.localiza')[6]).html('<iframe id="localizarCidadeDestino" input="inptCidadeDe" name="localizarCidadeDestino" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarCidadeDestino&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                    jQuery(jQuery('.localiza')[7]).html('<iframe id="localizarFilialDestino" input="inptFilialDestino" name="localizarFilialDestino" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarFilialDestino&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                }, 1);

            <c:forEach items="${listaLayout}" var="layout">
                layoutsFunctionAll_o[idxAll_o++] = eval("({id:0, layoutEDI:{id:'${layout.id}', descricao:'${layout.descricao}',tipoEdi:'${layout.tipoEdi}', nomeArquivo:'${layout.nomeArquivo}',extencaoArquivo:'${layout.extencaoArquivo}', funcao:'${layout.funcao}',layoutFormatoAntigo:'', tipo:'${layout.tipoEdi}'}})");
            </c:forEach>
                dataAtualSistema = '${dataAtual}';
            });
            function recarregarVideos() {
                var iframes = jQuery(".container-video iframe");
                jQuery(jQuery('.container-video').find('div')).removeClass();
                jQuery(jQuery('.container-video').find('div')).addClass("col-md-6");
                jQuery(jQuery('.container-video').find('img')).css('right', '0');
                jQuery(iframes).css("max-width", "95%");
                jQuery(iframes).css("height", "100px");

            <c:forEach items="${listVideosTela}" var="video" varStatus="videoStatus">
                if (jQuery('#video${videoStatus.count}').prop('src') !== '${video.url}') {
                    jQuery('#video${videoStatus.count}').attr('src', '${video.url}');
                }
            </c:forEach>
            }

            jQuery(document).ready(function () {
                setTimeout(function () {
                    jQuery('.container-salvar-filtros').html('<iframe id="iframeSalvarFiltros" name="iframeSalvarFiltros" src="${homePath}/gwTrans/consultas/salvar_filtros.jsp?tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe><span class="seta-baixo"></span>');
                    document.getElementById('progress-preferencias').value = 100;
                    document.getElementById('progress-porcentagem').innerHTML = '100%';
                    jQuery('.load-preferencias').hide();

                    var menu = document.querySelectorAll(".menu");
                    if (document.getElementById('tabela-gwsistemas').addEventListener) {
                        document.getElementById('tabela-gwsistemas').addEventListener('contextmenu', function (e) {
                            menu[0].style.display = 'block';
                            menu[0].style.marginLeft = e.clientX + 'px';
                            menu[0].style.marginTop = e.clientY + 'px';

                            var alvo = e.target.nodeName == "LABEL" ? e.target : jQuery(e.target).parents('LABEL')[0];


                            e.preventDefault();
                        }, false);
                    } else {
                        document.getElementById('tabela-gwsistemas').attachEvent('oncontextmenu', function () {
                            menu[0].style.display = 'block';
                            menu[0].style.marginLeft = e.clientX + 'px';
                            menu[0].style.marginTop = e.clientY + 'px';
                            window.event.returnValue = false;
                        });
                    }

                    document.addEventListener('click', function (e) {
                        menu[0].style.display = 'none';
                    });
                    
                    adicionarLinkCadastro();
                }, 1000);
            });

            function copyText(elemento) {
                jQuery('#copy').val('Mateus');
                jQuery('#copy').trigger('click');
                var txt = '';
                if (window.getSelection)
                    txt = window.getSelection();
                else if (document.getSelection)
                    txt = document.getSelection();
                else
                    return;

                allCopied = document.createRange();
                allCopied.execCommand("RemoveFormat");
                allCopied.execCommand("Copy");
            }
        </script>
    </body>
</html>
