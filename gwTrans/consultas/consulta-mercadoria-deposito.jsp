<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="/WEB-INF/tld/custonTagLibrary.tld" prefix="cg" %>
<jsp:useBean id="random" class="java.util.Random" scope="application" />
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
    <c:if test="${user == null}">
        <c:redirect url="/login"/>
    </c:if>
    <c:if test="${nivelUser == null || nivelUser <= 0}">
        <c:redirect url="/401"/>
    </c:if>
    <head>
        <script src="${homePath}/script/jQuery/jquery.js" type="text/javascript"></script>
        <script src="${homePath}/assets/alerts/alerts-min.js" type="text/javascript"></script>
        <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${tema}.css?v=${random.nextInt()}">
        <jsp:include page="/importAlerts.jsp">
            <jsp:param name="caminhoImg" value="assets/img/gw-trans.png"/>
            <jsp:param name="nomeUsuario" value="${user.nome}"/>
        </jsp:include>
        <meta charset="ISO-8859-1">
        <meta name="viewport" content="width=device-width">
        <title>GW Trans - Consulta de Mercadoria em depósito</title>
        <link href="${homePath}/assets/css/jquery-ui-min.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/bootstrap-custom-col.css" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="${homePath}/assets/css/easyui.css">
        <link rel="stylesheet" href="${homePath}/assets/css/consulta.css?v=${random.nextInt()}">
        <link rel="stylesheet" href="${homePath}/assets/css/inputs-gw.css" type="text/css"/>
        <link rel="stylesheet" href="${homePath}/assets/css/font-roboto.css">	
        <script src="${homePath}/assets/js/coluna_ajuda_filtros.js?v=${random.nextInt()}"></script>
        <link href="${homePath}/gwTrans/consultas/css/consulta-mercadoria-deposito.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/select-multiplo-gw.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/select-multiplo-grupo-gw.css" rel="stylesheet" type="text/css"/>
        <script defer src="${homePath}/script/validarSessao.js?v=${random.nextInt()}" type="text/javascript"></script>

        <script defer>
            var codigoTela = 'T00069';
            var codigo_tela = '69';
            var idPreferencia = 0;
            var nivelUser = ${nivelUser};
            var homePath = '${homePath}';

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
        </script>
        <style>
            :root {
                --homePath: ${homePath};
            }
        </style>
    </head>
    <body>
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
                <h3>Consulta de Mercadoria em depósito <img src="${homePath}/assets/img/trans_white.png"></h3>
            </div>
            <div id="actions">
                <img id="logoCliente" width="68px" height="44px" src="">
                <!--<a href="javascript:;"><img src="${homePath}/assets/img/icon-question.png" class="right question"></a>-->
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
        <div id="sidebar" class="heightDoc">
            <div class="columnLeft" id="columnLeft">
                <div class="cobre-left"></div>
                <div class="content">
                    <form action="ConsultaControlador?codTela=69" method="POST" id="formConsulta" name="formConsulta">
                        <div class="item_form">
                            <label class="label-pesquisas-salvas">Pesquisas salvas dispóniveis</label>
                            <select class="input" id="select-pesquisa" name="select-pesquisa" onchange="">
                                <option value="0">Ultima pesquisa realizada</option>
                                <c:forEach var="listPrefPerso" items="${listaPreferenciasPersonalizadas}" varStatus="filtrosStatus" >
                                    <option value="${listPrefPerso}">${listPrefPerso}</option>
                                </c:forEach>
                            </select>
                            <!--<input type="button" value="Selecionar" class="searchButton" id="search" onclick="" style="width: 37%;margin-top: 0px;background: #057899;padding: 0;padding-top: 10px;padding-bottom: 10px;padding-left: 5px;padding-right: 5px;">-->
                        </div>
                        <div class="item_form filtro-pesquisa">
                            <label>Filtro</label>
                            <select class="input" id="select-abrev" name="select-abrev" onchange="">
                                <c:forEach var="columnFiltroSelect" items="${tela.targetXml.columnFiltroSelect}" varStatus="rowStatus" >
                                    <option value="${columnFiltroSelect.name}">${columnFiltroSelect.label}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="item_form container-campos-select">
                            <select class="input" id="select-oper" name="select-oper" onchange="">
                                <option value="1" >Todas as partes com</option>
                                <option value="3">Apenas com o início</option>
                                <option value="2">Apenas com o fim</option>
                                <option value="4">Igual à palavra/frase</option>
                            </select>
                        </div>
                        <div class="item_form container-campos-select input-boxes">
                            <input type="text" id="inpSelectVal" name="inpSelectVal" data-pesquisar-id="#search">
                            <!--Necessario para que ele não de subimit sozinho com apenas um input text : Mateus--> 
                            <input type="text" class="input-escondido" id="t">
                        </div>
                        <div class="item_form container-data">
                            <div class="item_form_half1">
                                <input class="easyui-datebox" id="dataDe" name="dataDe" value="${dataAtual}" style="width:100%;height:32px">
                            </div>
                            <div class="item_form_half2">
                                <input class="easyui-datebox" id="dataAte" name="dataAte" value="${dataAtual}" style="width:100%;height:32px">
                            </div>
                        </div>
                        <div class="item_form div-ordenacao">
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
                            <div class="item_form check-box-feitos-por-mim">
                                <label for="createdMe">
                                    <input type="checkbox" name="createdMe" id="createdMe">
                                    Criados por mim
                                </label>
                            </div>
                            <div class="item_form" style="margin-bottom: 10px;">
                                <div class="container-select-multiplo-grupos-gw" style="width: 100%;float: left;">
                                    <input id="mostrar-mercadoria-deposito">
                                </div>
                            </div>
                            <div class="item_form" style="margin-bottom: 10px;">
                                <select id="select-exceto-apenas-filial" name="select-exceto-apenas-filial">
                                    <option value="apenas">Apenas as filiais</option>
                                    <option value="exceto">Exceto as filiais</option>
                                </select>
                                <div style="width: 70%;float: left;" class="inputFilial">
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
                            <div class="item_form filtroFilial" style="margin-bottom: 10px;">
                                <select id="select-exceto-apenas-filial-destino" name="select-exceto-apenas-filial-destino">
                                    <option value="apenas">Apenas as filiais destino</option>
                                    <option value="exceto">Exceto as filiais destino</option>
                                </select>
                                <div style="width: 70%;float: left;" class="inputFilialDes">
                                    <input class="input" type="text" id="inptFilialDes" name="inptFilialDes" readonly="true" placeholder="">
                                </div>
                                <div class="btns">
                                    <a href="javascript:" onclick="checkSession(function () {
                                                removerValorInput('inptFilialDes', true);
                                            }, false);" class="btnDelete btnDeleteFilial" style="margin-top: 2px;"></a>
                                    <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarFilialDestino');},false);" class="btnMore btnMoreFilial" style="float: right !important;margin-right: 5px;"></a>
                                    <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                                </div>
                            </div>
                            <div class="item_form" style="margin-bottom: 10px;">
                                <select id="select-exceto-apenas-representante" name="select-exceto-apenas-representante">
                                    <option value="apenas">Apenas os representante destino</option>
                                    <option value="exceto">Exceto os representante destino</option>
                                </select>
                                <div style="width: 70%;float: left;">
                                    <input class="input" type="text" id="inptRepresentante" name="inptRepresentante" readonly="true" placeholder="">
                                </div>
                                <div class="btns">
                                    <a href="javascript:" onclick="checkSession(function () {
                                                    removerValorInput('inptRepresentante', true);
                                                }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                                    <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarRepresentante');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                                </div>
                            </div>
                            <div class="item_form" style="margin-bottom: 10px;">
                                <select id="select-exceto-apenas-cidade-des" name="select-exceto-apenas-cidade-des">
                                    <option value="apenas">Apenas cidades de destino</option>
                                    <option value="exceto">Exceto cidades de destino</option>
                                </select>
                                <div style="width: 70%;float: left;">
                                    <input class="input" type="text" id="inptCidadeDes" name="inptCidadeDes" readonly="true" placeholder="">
                                </div>
                                <div class="btns">
                                    <a href="javascript:" onclick="checkSession(function () {
                                                removerValorInput('inptCidadeDes', false);
                                            }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                                    <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarCidadeDestino');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                                    <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                                </div>
                            </div>
                            <div class="item_form" style="margin-bottom: 10px;">
                                <select id="select-exceto-apenas-remetente" name="select-exceto-apenas-remetente">
                                    <option value="apenas">Apenas os remetentes</option>
                                    <option value="exceto">Exceto os remetentes</option>
                                </select>
                                <div style="width: 70%;float: left;">
                                    <input class="input" type="text" id="inptRemetente" name="inptRemetente" readonly="true" placeholder="">
                                </div>
                                <div class="btns">
                                    <a href="javascript:" onclick="checkSession(function () {
                                                removerValorInput('inptRemetente', true);
                                            }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                                    <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarCliente');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                                    <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                                </div>
                            </div>
                            <div class="item_form" style="margin-bottom: 10px;">
                                <select id="select-exceto-apenas-destinatario" name="select-exceto-apenas-destinatario">
                                    <option value="apenas">Apenas os destinatários</option>
                                    <option value="exceto">Exceto os destinatários</option>
                                </select>
                                <div style="width: 70%;float: left;">
                                    <input class="input" type="text" id="inptDestinatario" name="inptDestinatario" readonly="true" placeholder="">
                                </div>
                                <div class="btns">
                                    <a href="javascript:" onclick="checkSession(function () {
                                                removerValorInput('inptDestinatario', true);
                                            }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                                    <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarDestinatario');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                                    <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                                </div>
                            </div>
                            <div class="item_form" style="margin-bottom: 10px;">
                                <select id="select-exceto-apenas-consignatario" name="select-exceto-apenas-consignatario">
                                    <option value="apenas">Apenas os consignatario</option>
                                    <option value="exceto">Exceto os consignatario</option>
                                </select>
                                <div style="width: 70%;float: left;">
                                    <input class="input" type="text" id="inptConsignatario" name="inptConsignatario" readonly="true" placeholder="">
                                </div>
                                <div class="btns">
                                    <a href="javascript:" onclick="checkSession(function () {
                                                removerValorInput('inptConsignatario', true);
                                            }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                                    <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarCliente');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                                    <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                                </div>
                            </div>
                        </div>
                        <div class="item_form" id="filtros-adicionais">
                            <!--<img src="${homePath}/assets/img/icon-seta-down.png" id="img-filtros-adicionais">-->
                            <span class="seta-exibir-filtros-adicionais"></span>
                            <a href="javascript:;" id="toogle_options_details">Exibir filtros adicionais</a>
                        </div>
                    </form>
                    <div class="centerContent">
                        <input type="button" value="Pesquisar" class="searchButton" id="search" onclick="checkSession(function () {
                                    consulta();
                                }, false);">
                    </div>
                    <div class="salvarPesquisaContainer">
                        <label id="salvarFiltros" nome="salvarFiltros">Salvar Pesquisa</label>
                    </div>
                </div>
            </div>
            <div class="columnRight">
                <button type="button" data-name="hide" id="toggle" name="toggle" style="margin-left: -70px !important;border-radius: 5px!important;min-width: 150px !important;width:150px !important;" class="toogleOn">Ocultar filtros</button>
                <button type="button" data-name="show" id="toggle" name="toggleAjuda" style="margin-top: 105px !important;min-width: 150px !important;width:150px !important;border-radius: 5px !important;margin-left: -72px !important;" class="toogleOnAjuda">Exibir Ajuda</button>
            </div>
            <style>#columnLeftAjuda::-webkit-scrollbar{display: none;-ms-overflow-style: none;overflow: auto;}</style>
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
                        <div class="item_form div-ajuda">
                            <div class="helper">
                                <div class="corpo_helper">
                                    <label class="campo-helper"><h2>Ajuda</h2></label>
                                    <hr>
                                    <label class="descri-helper"><h3>Passe o mouse sobre o campo que deseja ajuda.</h3></label>
                                </div>
                            </div>
                        </div>
                        <div class="item_form coluna-ajuda">
                            <div class="permissoes_tela">
                                <h3 class="h3-permissoes">Permissões de acesso desta tela</h3>
                                <hr class="hr-margin">
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
                            <center class="div-lb-videos-ajuda"><h3 class="h3-video">Vídeos de  Ajuda</h3></center>
                            <hr class="hr-margin">
                            <div class="item_form div-videos">
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
                            <hr class="hr-final" >
                        </c:if>

                    </form>
                </div>
            </div>
        </div>
        <div class="localiza">
            <iframe id="localizarRepresentante" input="inptRepresentante" name="localizarRepresentante" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarRepresentante&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>
        <div id="map" class="heightDoc">
            <div id="contentMap" style="">
                <script>
                    setTimeout(function () {
                        document.getElementById('progress-preferencias').value = 40;
                        document.getElementById('progress-porcentagem').innerHTML = '40%';
                    }, 10);
                </script>
                <%@ include file="grid-mercadoria-deposito.jsp"%>
                <script>
                    setTimeout(function () {
                        document.getElementById('progress-preferencias').value = 90;
                        document.getElementById('progress-porcentagem').innerHTML = '90%';
                    }, 10);
                </script>
            </div>
            <style>
                :root{
                    --tonalidade2: #13385C; 
                    --tonalidade7: #375471;
                    --icon-tonalidade1: none;
                }
                .footer-dados-container{
                    border-radius: 5px;
                    position: relative;
                    /*overflow: hidden;*/
                    float: left;
                    width: 98%;
                    margin-top: 10px;
                    height: 225px;
                    margin-left: 2px;
                    /*                    border: 1px dotted #95b8e7;*/
                    box-shadow: 0px 1px 1px 1px rgba(0,0,0,0.75);
                    background: #FFF; 
                    z-index: 9;
                }

                .icones{
                    position: absolute;
                    z-index: 99;
                    width: 40px;
                    height: 40px;
                    background-image: url(${homePath}/assets/img/icones/icones-topo.png);
                    background-repeat: no-repeat;
                    background-size: 230px;
                    -webkit-transition: all 0.5s ease;
                    -moz-transition: all 0.5s ease;
                    -o-transition: all 0.5s ease;
                    transition: all 0.5s ease;
                    filter: var(--icon-tonalidade1);
                }

                .icones:hover{
                    cursor: pointer;
                    transform: scale(0.9);
                }

                .maximizar{
                    transform: scale(0.8);
                    top: -45px;
                    left: -1px;
                    background-position-x: 1px;
                    background-position-y: 1px;
                }

                .restaurar{
                    transform: scale(0.8);
                    top: -45px;
                    left: 40px;
                    background-position-x: -37px;
                    background-position-y: 1px;
                }

                .minimizar{
                    transform: scale(0.8);
                    top: -45px;
                    left: 81px;
                    background-position-x: -73px;
                    background-position-y: 1px;
                }

                .icone-selecionado{
                    background-color: var(--tonalidade7);
                    border-radius: 5px;
                    filter:none;
                }

                .icone-selecionado-restaurar{
                    background-position-x: -143px;
                }

                .icone-selecionado-maxminizar{
                    background-position-x: -106px;
                }

                .icone-selecionado-minimizar{
                    background-position-x: -179px;
                }

                .separa{
                    /*height: 5px;*/
                    width: 95%;
                    float: left;
                    margin-left: 2.5%;
                    border-top: 1px dotted #666;
                }

                .container-footer-resultados{
                    border-radius: 5px;
                    float: left;
                    height: 225px;
                    width: 100%;
                    background: #FFF; 
                }

                .topo-footer-resultados{
                    width: 100%;
                    float: left;
                    padding-top: 4px;
                    padding-bottom: 4px;
                    background: var(--tonalidade2);
                    text-align: center;
                    -webkit-box-shadow: 0px 3px 2px 0px rgba(153,153,153,1);
                    -moz-box-shadow: 0px 3px 2px 0px rgba(153,153,153,1);
                    box-shadow: 0px 2px 2px 0px rgba(149,184,231,0.65);
                    font-family: Helvetica, Arial, sans-serif;
                    font-weight: bold;
                    color: #FFF;
                    /*text-shadow: 1px 4px 6px #13385c, 0 0 0 #a0c2e4, 1px 4px 6px #13385c;*/
                    font-size: 26px;
                    font-weight: bold;
                }

                .corpo-footer-resultados{
                    float: left;
                    width: 100%;
                    height: calc(225px - 39px);
                }

                .container-tabela-footer-resultados{
                    width: 49%;
                    height: 90%;
                    margin-top: 1%;
                    margin-left: 0.5%;
                    float: left;
                    border-radius: 5px;
                }

                .tabela-footer-resultados{
                    border-collapse: collapse;
                    width: 100%;
                    background: #e0ecff;
                    box-shadow: 0px 1px 1px 1px rgba(200,200,200,0.3);
                    border-radius: 5px;
                    border: 1px solid #777;
                }

                .tabela-footer-resultados > thead > tr {
                    box-shadow: 0px 1px 1px 0px rgba(0,0,0,0.4);
                    font-size: 15px;
                    color: #FFF;
                    background: var(--tonalidade2);
                }

                .tabela-footer-resultados > thead > tr > th {
                    border-right: 1px solid #95b8e7;
                    height: 30px;
                }

                .tabela-footer-resultados > thead > tr > th:first-child{
                    border-radius: 5px 0 0 0;
                }

                .tabela-footer-resultados > thead > tr > th:last-child{
                    border-radius: 0 5px 0 0;
                }

                .tabela-footer-resultados > thead > tr > th:last-child {
                    border-right: 0;
                }

                .tabela-footer-resultados > tbody {
                    text-align: center;
                    font-size: 14px;
                    padding-top: 2px;
                    padding-bottom: 2px;
                    color: #444;
                }

                .tabela-footer-resultados > tbody > tr{
                    background: #ECEEF1;
                }

                .tabela-footer-resultados > tbody > tr > td{
                    border-right: 1px solid #95b8e7;
                }

                .tabela-footer-resultados > tbody > tr > td:last-child{
                    border-right: 0;
                }

                .tabela-footer-resultados > tbody > tr:nth-child(odd){
                    background: #FFF;
                    box-shadow: inset 0px 0px 2px 0px rgba(0,0,0,0.75);
                }

            </style>
            <div class="footer-dados-container" id="testa">
                <span class="icones maximizar"></span>
                <span class="icones restaurar icone-selecionado icone-selecionado-restaurar"></span>
                <span class="icones minimizar"></span>
                <div class="container-footer-resultados">
                    <div class="topo-footer-resultados">Totais</div>
                    <div class="corpo-footer-resultados">
                        <div class="container-tabela-footer-resultados" style="width: 99%;height: 28%;">
                            <table class="tabela-footer-resultados">
                                <thead>
                                    <tr>
                                        <th width="15%">Volumes</th>
                                        <th width="15%">Cubagem</th>
                                        <th width="15%">Peso real</th>
                                        <th width="15%">Peso Taxado</th>
                                        <th width="20%">Valor da mercadoria</th>
                                        <th width="20%">R$.KG</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td volumes></td>
                                        <td cubagem></td>
                                        <td pesoReal></td>
                                        <td pesoTaxado></td>
                                        <td valorMercadoria></td>
                                        <td rsKG></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="container-tabela-footer-resultados">
                            <table class="tabela-footer-resultados">
                                <thead>
                                    <tr>
                                        <th width="20%">Frete</th>
                                        <th width="40%">Valor</th>
                                        <th width="20%">R$.KG</th>
                                        <th width="20%">Quantidade</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>CIF</td>
                                        <td valorFreteCif></td>
                                        <td valorRsKgCif></td>
                                        <td qtdCif></td>
                                    </tr>
                                    <tr>
                                        <td>FOB</td>
                                        <td valorFreteFob></td>
                                        <td valorRsKgFob></td>
                                        <td qtdFob></td>
                                    </tr>
                                    <tr>
                                        <td>Terceiro</td>
                                        <td valorFreteTerceiro></td>
                                        <td valorRsKgTerceiro></td>
                                        <td qtdTerceiro></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                    </div>
                </div>
                <span class="separa"></span>
                <div id="piechart_3d" style="margin-left: 5%;width: 90%;height: 270px;float: left;"></div>
            </div>
            <!--<div class="topo-dados"></div>-->
        </div>
    </div>
    <img class="gif-bloq-tela" src="${homePath}/img/espere_new.gif" alt=""/>
    <div class="bloqueio-tela"></div>
    <script src="${homePath}/assets/js/jquery-ui.min.js" type="text/javascript"></script>
    <script defer src="${homePath}/script/shortcut.js" type="text/javascript"></script>
    <script defer src="${homePath}/assets/js/jquery.mask.min.js"></script>
    <script defer src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script src="${homePath}/script/funcoesTelaConsulta.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script src="${homePath}/gwTrans/consultas/js/consulta-mercadoria-deposito.js?v=${random.nextInt()}"></script>
    <script defer src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script defer src="${homePath}/assets/js/jquery.easyui.min.js"></script>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script defer type='text/javascript' lang="JavaScript">
                    google.charts.load("current", {packages: ["corechart"]});
                    google.charts.setOnLoadCallback(drawChart);


                    function drawChart() {
                        var data = google.visualization.arrayToDataTable([
                            ['Dados', 'Dados selecionados'],
                            ['CIF', 1],
                            ['FOB', 1],
                            ['TERCEIRO', 1]
                        ]);


                        var options = {
                            title: 'Gráfico - Total do Frete',
                            titleTextStyle: {
                                color: '#000',
                                fontSize: '24',
                                bold: 'true',
                            },
                            is3D: true,
                            backgroundColor: '#FFF',
                            colors: ['#4e7fba', '#bf4f4d', '#81639f']
                        };

                        var chart = new google.visualization.PieChart(document.getElementById('piechart_3d'));
                        chart.draw(data, options);

                        changeValueGraficos = function (cif = 0, fob = 0, terceiro = 0) {
                            var arrayPizza = [['Dados', 'Dados selecionados'],
                                ['CIF', cif],
                                ['FOB', fob],
                                ['TERCEIRO', terceiro]];

                            var total = 0;
                            for (var i = 1; i < arrayPizza.length; i++) {
                                total += arrayPizza[i][1];
                            }
                            for (var i = 1; i < arrayPizza.length; i++) {
                                arrayPizza[i][0] = arrayPizza[i][0] + " - " + arredonda((arrayPizza[i][1] * 100 / total), 2) + "%";
                            }

                            var data = google.visualization.arrayToDataTable(arrayPizza);
                            chart.draw(data, options);
                        };
                    }

                    jQuery(document).ready(function () {
                        var alturaPaneReduzida = jQuery('#paneConsulta').height() - 60;
                        var alturaPane = jQuery('#paneConsulta').height();
                        var alturaFooter = jQuery('.footer-dados-container').height();
                        jQuery('span.icones').click(function () {
                            jQuery('.icone-selecionado').removeClass('icone-selecionado');
                            jQuery(this).addClass('icone-selecionado');
                            if (jQuery(this).hasClass('maximizar')) {
                                jQuery('.container-footer-resultados').show();
                                jQuery('.icone-selecionado-minimizar').removeClass('icone-selecionado-minimizar');
                                jQuery('.icone-selecionado-restaurar').removeClass('icone-selecionado-restaurar');
                                jQuery(this).addClass('icone-selecionado-maxminizar');

                                jQuery('#piechart_3d').show(150);
                                jQuery('#paneConsulta').animate({
                                    'height': '60px'
                                }, 250, function () {
                                    jQuery('.footer-dados-container').css('height', (alturaFooter + alturaPaneReduzida) + 'px');
                                });
                            } else if (jQuery(this).hasClass('restaurar')) {
                                jQuery('.container-footer-resultados').show();
                                jQuery('.icone-selecionado-minimizar').removeClass('icone-selecionado-minimizar');
                                jQuery('.icone-selecionado-maxminizar').removeClass('icone-selecionado-maxminizar');
                                jQuery(this).addClass('icone-selecionado-restaurar');

                                jQuery('#piechart_3d').hide(150);
                                jQuery('#paneConsulta').animate({
                                    'height': alturaPaneReduzida + 'px'
                                }, 250, function () {
                                    jQuery('.footer-dados-container').css('height', alturaFooter + 'px');
                                });
                            } else if (jQuery(this).hasClass('minimizar')) {
                                jQuery('.icone-selecionado-maxminizar').removeClass('icone-selecionado-maxminizar');
                                jQuery('.icone-selecionado-restaurar').removeClass('icone-selecionado-restaurar');
                                jQuery(this).addClass('icone-selecionado-minimizar');

                                jQuery('#piechart_3d').hide(150);
                                jQuery('#paneConsulta').animate({
                                    'height': (alturaPaneReduzida + alturaFooter) + 'px'
                                }, 250, function () {
                                    jQuery('.footer-dados-container').css('height', '0px');
                                    jQuery('.container-footer-resultados').hide();
                                });
                            }

                        });
                    });

                    var heightDoc = jQuery(window).height();

                    jQuery("#paneConsulta").css('height', heightDoc - 400);

                    function proxima() {
                        var parametros =
                                "&paginaAtual=" +${paginaAtual+1}
                        + "&select-limite=" +${consulta.paginacao.limiteResultados}
                        + "&paginas=" +${paginas}
                        + "&inpSelectVal=" +jQuery("#inpSelectVal").val()
                        + "&select-abrev=" +jQuery("#select-abrev").val()
                        + "&select-oper=" +jQuery("#select-oper").val()
                        + "&select-ordenacao=" +jQuery("#select-ordenacao").val()
                        + "&select-order-tipo=" +jQuery("#select-order-tipo").val()
                        + "&inpSelectVal=" +jQuery("#inpSelectVal").val();
                        location.replace("ConsultaControlador?codTela=" + codigo_tela + parametros);
                    }
                    function anterior() {
                        var parametros =
                                "&paginaAtual=" +${paginaAtual-1}
                        + "&select-limite=" +${consulta.paginacao.limiteResultados}
                        + "&paginas=" +${paginas}
                        + "&inpSelectVal=" +jQuery("#inpSelectVal").val()
                        + "&select-abrev=" +jQuery("#select-abrev").val()
                        + "&select-oper=" +jQuery("#select-oper").val()
                        + "&select-ordenacao=" +jQuery("#select-ordenacao").val()
                        + "&select-order-tipo=" +jQuery("#select-order-tipo").val()
                        + "&inpSelectVal=" +jQuery("#inpSelectVal").val();
                        location.replace("ConsultaControlador?codTela=" + codigo_tela + parametros);
                    }

                    function paginaEnter(evn, pagina) {
                        if (evn.keyCode == 13) {
                            var parametros =
                                    "&paginaAtual=" + pagina
                                    + "&select-limite=" +${consulta.paginacao.limiteResultados}
                            + "&paginas=" +${paginas};
                            location.replace("ConsultaControlador?codTela=" + codigo_tela + parametros);
                        }

                    }

                    var arredonda = function (numero, casasDecimais) {
                        casasDecimais = typeof casasDecimais !== 'undefined' ? casasDecimais : 2;
                        return +(Math.floor(numero + ('e+' + casasDecimais)) + ('e-' + casasDecimais));
                    };

                    var nomeLogoCliente = '${nomeLogoCliente}';
                    if (nomeLogoCliente !== 'null' && nomeLogoCliente != '') {
                        jQuery("#logoCliente").attr("src", "img/logoCliente/" + nomeLogoCliente);
                    } else {
                        jQuery("#logoCliente").attr("src", "${homePath}/assets/img/no-image.png");
                    }

                    jQuery(document).ready(function () {

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
                        gerenciarMostrarMercadoriaDeposito('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}');
                        gerenciarInpFilial('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                        gerenciarInpFilialDes('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                        gerenciarInpCidade('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                        gerenciarInpRemetente('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                        gerenciarInpDestinatario('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                        gerenciarInpConsignatario('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                        gerenciarRepresentante('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                        //                                addValorAlphaInput('inpSelectVal', '${filtros.colunaValor}');

            </c:forEach>
        </c:if>

        <c:if test="${filtroEscolhido != null}">
                        jQuery('#select-pesquisa').val('${filtroEscolhido}').change();
                        jQuery("#select-pesquisa").selectmenu("refresh");
        </c:if>

                        //Altera o src do salvarFiltros para passar por parametro o filtro escolhido.
                        jQuery('#iframeSalvarFiltros').attr('src', jQuery('#iframeSalvarFiltros').attr('src') + '?nomePesquisa=' + jQuery('#select-pesquisa').val() + '&isPrivada=' + true + '&tema=${tema}');
        <c:if test="${nivelFilial <= 0}">
                        removerValorInput('inptFilialDes');
                        jQuery('.btnMoreFilial').hide();
                        jQuery('.btnDeleteFilial').hide();
                        addValorAlphaInput('inptFilialDes', '${userFilial.abreviatura}', '${userFilial.idfilial}');
                        jQuery('.inptFilialDes').find('.gamma-li-chaves').css('background', '#c2c2c2');
                        jQuery('.inptFilialDes').find('.gamma-li-chaves-a').remove();
                        jQuery('#select-exceto-apenas-filial-destino').selectExcetoApenasGw({
                            width: '170px',
                            readOnly: true
                        });
        </c:if>
        <c:if test="${nivelFilial > 0}">
                        jQuery('#select-exceto-apenas-filial-destino').selectExcetoApenasGw({
                            width: '170px',
                        });
        </c:if>
                        //Adiciona os iframes.
                        setTimeout(function () {
                            jQuery('.visualizarDocumentos').html('<iframe id="iframeVisualizarDocumentos" name="iframeVisualizarDocumentos" src="" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                            jQuery(jQuery('.localiza')[0]).html('<iframe id="localizarFilial" input="inptFilial" name="localizarFilial" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarFilial&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                            jQuery(jQuery('.localiza')[1]).html('<iframe id="localizarFilialDestino" input="inptFilialDes" name="localizarFilialDestino" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarFilialDestino&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                            jQuery(jQuery('.localiza')[2]).html('<iframe id="localizarCidadeDestino" input="inptCidadeDes" name="localizarCidadeDestino" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarCidadeDestino&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                            jQuery(jQuery('.localiza')[3]).html('<iframe id="localizarCliente" input="inptRemetente" name="localizarCliente" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarCliente&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                            jQuery(jQuery('.localiza')[4]).html('<iframe id="localizarDestinatario" input="inptDestinatario" name="localizarDestinatario" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarDestinatario&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                            jQuery(jQuery('.localiza')[5]).html('<iframe id="localizarCliente" input="inptConsignatario" name="localizarCliente" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarCliente&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
}, 1);
                    });

                    setTimeout(function () {
                        document.getElementById('progress-preferencias').value = 100;
                        document.getElementById('progress-porcentagem').innerHTML = '100%';
                        jQuery('.load-preferencias').hide();
                    }, 1000);
    </script>
</body>
</html>