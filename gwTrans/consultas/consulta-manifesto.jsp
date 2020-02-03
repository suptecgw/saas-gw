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
        <title>GW Trans - Consulta de Manifesto</title>

        <link href="${homePath}/assets/css/jquery-ui-min.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/bootstrap-custom-col.css" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="${homePath}/assets/css/easyui.css">
        <link rel="stylesheet" href="${homePath}/assets/css/consulta.css?v=${random.nextInt()}">
        <link rel="stylesheet" href="${homePath}/assets/css/inputs-gw.css" type="text/css"/>
        <link rel="stylesheet" href="${homePath}/assets/css/font-roboto.css">	
        <script src="${homePath}/assets/js/coluna_ajuda_filtros.js?v=${random.nextInt()}"></script>
        <link href="${homePath}/gwTrans/consultas/css/consulta-manifesto.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/select-multiplo-gw.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/select-multiplo-grupo-gw.css" rel="stylesheet" type="text/css"/>
        <script defer src="${homePath}/script/validarSessao.js?v=${random.nextInt()}" type="text/javascript"></script>

        <script defer>
            var codigoTela = 'T00028';
            var codigo_tela = 28;
            var idPreferencia = 0;
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


            function rolarLeft() {
                jQuery(".topo-btns").animate({
                    scrollLeft: 999
                }, 600, function () {
                    moveuScroll();
                });
            }
            function rolarRight() {
                jQuery(".topo-btns").animate({
                    scrollLeft: -999
                }, 600, function () {
                    moveuScroll();
                });
            }


            jQuery(document).ready(function () {
                jQuery('.rolar-left').click(rolarRight);
                jQuery('.rolar-right').click(rolarLeft);

                jQuery('.topo-btns').scroll(function () {
                    moveuScroll();
                });
                jQuery(window).resize(function () {
                    moveuScroll();
                });

                $.fn.hasScrollBar = function () {
                    return jQuery('.topo-btns > table').width() > jQuery('.topo-btns').width();
                }

                moveuScroll();

            });


            function moveuScroll() {
                if (jQuery('.topo-btns').hasScrollBar()) {
                    if (jQuery('.topo-btns').scrollLeft() != 0) {
                        jQuery('.rolar-left').show();
                        jQuery('.rolar-right').hide();
                    } else {
                        jQuery('.rolar-left').hide();
                        jQuery('.rolar-right').show();
                    }
                } else {
                    jQuery('.rolar-left').hide();
                    jQuery('.rolar-right').hide();
                }
            }
            
        </script>
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
                <h3>Consulta de Manifesto<img src="${homePath}/assets/img/trans_white.png"></h3>
            </div>
            <div id="actions">
                <img id="logoCliente" width="68px" height="44px" src="">
                <img class="rolar-left" src="${homePath}/assets/img/icones/anterior.png">
                <img class="rolar-right" src="${homePath}/assets/img/icones/proximo.png">
                <div class="topo-btns" allowtransparency="true">
                    <table>
                        <tbody>
                            <tr>
                                <c:if test="${nivelUser >= 3}">
                                    <td style="min-width: 140px;max-width: 140px;width: 140px;">
                                        <div class="bt bt-cadastro"  onclick="checkSession(function () {
                                                    btnCadastrar('cadmanifesto?acao=iniciar');
                                                }, false);">Novo Manifesto
                                        </div>
                                    </td>
                                    <td style="min-width: 175px;max-width: 175px;width: 175px;" >
                                        <div class="bt bt-cadastro" onclick="checkSession(function () {
                                                    btnCadastrar('SeparacaoControlador?acao=novoCadastro');
                                                }, false);">Incluir Pré Manifesto
                                        </div>
                                    </td>
                                </c:if>
                                <c:if test="${nivelMDFE != 'N'.charAt(0) && envioMDFE == 4}">
                                    <td style="min-width: 150px;max-width: 150px;width: 150px;">    
                                        <div class="bt bt-mdfe"  onclick="checkSession(function () {
                                                    abrirPopConsulta('MDFeControlador?acao=listarMDFe');}, false);">Transmitir MDF-e
                                        </div>
                                    </td>
                                </c:if>
                                <c:if test="${nivelRoteirizador == 4}">
                                    <td style="min-width: 200px;max-width: 200px;width: 200px;">
                                        <div class="bt bt-roteirizacao" onclick="checkSession(function () {
                                                    abrirPopConsulta('RoteirizacaoControlador?acao=listar');
                                                }, false);">Roteirizador de entregas
                                        </div>
                                    </td>
                                </c:if>
                                <td>
                                    <div  id="agruparMDFE" class="bt agrupaMDFEOff" style="min-width: 110px;max-width: 110px;width: 110px;" onclick="checkSession(function () {
                                                abrirAgrupador();
                                            }
                                            , false);">Agrupar MDF-e(s)
                                    </div>
                                </td>
                                <td style="min-width: 100px;max-width: 100px;width: 100px;" >
                                    <div class="bt bt-relatorio" onclick="checkSession(function () {abrirPopConsulta('./relmanifesto.jsp?acao=iniciar&modulo=webtrans');}, false);">Relatório
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
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
        <div class="localiza"> 
        </div>
        <div class="localiza"> 
        </div>
        <div class="localiza"> 
        </div>
        <div class="localiza"> 
        </div>
        <div class="container-agrupar-mdfe">
        </div>    
        <div id="sidebar" class="heightDoc">
            <div class="columnLeft" id="columnLeft">
                <div class="cobre-left"></div>
                <div class="content">
                    <form action="ConsultaControlador?codTela=28" method="POST" id="formConsulta" name="formConsulta">
                        <div class="item_form">
                            <label class="label-pesquisas-salvas">Pesquisas salvas disponíveis</label>
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
                            <div id="filtros-adicionais-container" style="display: none;">
                                <div class="item_form check-box-feitos-por-mim">
                                    <label for="createdMe">
                                        <input type="checkbox" name="createdMe" id="createdMe">
                                        Criados por mim
                                    </label>
                                </div>
                                <div class="item_form" style="margin-bottom: 50px;margin-top: 10px;">
                                    <select id="select-exceto-apenas-tipo-manifesto" name="select-exceto-apenas-tipo-manifesto">
                                        <option value="apenas">Apenas os Tipos</option>
                                        <option value="exceto">Exceto os Tipos</option>
                                    </select>
                                    <select id="select-tipo-manifesto" name="select-tipo-manifesto">
                                    </select>
                                </div>
                                <div class="item_form" style="margin-bottom: 50px;margin-top: 10px;">
                                    <select id="select-exceto-apenas-status-mdfe" name="select-exceto-apenas-status-mdfe">
                                        <option value="apenas">Apenas os Status</option>
                                        <option value="exceto">Exceto os Status</option>
                                    </select>
                                    <select id="select-status-mdfe" name="select-status-mdfe">
                                        <option value="Pendente">Pendente</option>
                                        <option value="Enviado">Enviado</option>
                                        <option value="Negado">Negado</option>
                                        <option value="Confirmado">Confirmado</option>
                                        <option value="Cancelado">Cancelado</option>
                                        <option value="Encerrado">Encerrado</option>
                                    </select>
                                </div>
                                <div class="item_form filtroFilial" style="margin-bottom: 10px;">
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
                                                }, false);" class="btnDelete btnDeleteFilial" style="margin-top: 2px;"></a>
                                        <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarFilial');},false);" class="btnMore btnMoreFilial" style="float: right !important;margin-right: 5px;"></a>
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
                                    <select id="select-exceto-apenas-carreta" name="select-exceto-apenas-carreta">
                                        <option value="apenas">Apenas as carretas</option>
                                        <option value="exceto">Exceto as carretas</option>
                                    </select>
                                    <div style="width: 70%;float: left;">
                                        <input class="input" type="text" id="inptCarreta" name="inptCarreta" readonly="true" placeholder="">
                                    </div>
                                    <div class="btns">
                                        <a href="javascript:" onclick="checkSession(function () {
                                                    removerValorInput('inptCarreta', true);
                                                }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                                        <a href="javascript:alterarTipo('carreta');checkSession(function(){controlador.acao('abrirLocalizar','localizarCarreta',tipo);},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                                        <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                                    </div>
                                </div>
                                <div class="item_form" style="margin-bottom: 10px;">
                                    <select id="select-exceto-apenas-aerea" name="select-exceto-apenas-aerea">
                                        <option value="apenas">Apenas as companhias aéreas</option>
                                        <option value="exceto">Exceto as companhias aéreas</option>
                                    </select>
                                    <div style="width: 70%;float: left;">
                                        <input class="input" type="text" id="inptAerea" name="inptAerea" readonly="true" placeholder="">
                                    </div>
                                    <div class="btns">
                                        <a href="javascript:" onclick="checkSession(function () {
                                                    removerValorInput('inptAerea', true);
                                                }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                                        <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarAerea');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                                        <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                                    </div>
                                </div>
                                <div class="item_form" style="margin-bottom: 10px;">
                                    <select id="select-exceto-apenas-redespachante" name="select-exceto-apenas-redespachante">
                                        <option value="apenas">Apenas os redespachantes</option>
                                        <option value="exceto">Exceto os redespachantes</option>
                                    </select>
                                    <div style="width: 70%;float: left;">
                                        <input class="input" type="text" id="inptRedespachante" name="inptRedespachante" readonly="true" placeholder="">
                                    </div>
                                    <div class="btns">
                                        <a href="javascript:" onclick="checkSession(function () {
                                                    removerValorInput('inptRedespachante', true);
                                                }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                                        <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarRedespachante');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                                        <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                                    </div>
                                </div>
                                <div class="item_form" style="margin-bottom: 10px;">
                                    <select id="select-exceto-apenas-aero-origem" name="select-exceto-apenas-aero-origem">
                                        <option value="apenas">Apenas os aeroportos (origem)</option>
                                        <option value="exceto">Exceto os aeroportos (origem)</option>
                                    </select>
                                    <div style="width: 70%;float: left;">
                                        <input class="input" type="text" id="inptAeroOrigem" name="inptAeroOrigem" readonly="true" placeholder="">
                                    </div>
                                    <div class="btns">
                                        <a href="javascript:" onclick="checkSession(function () {
                                                    removerValorInput('inptAeroOrigem', true);
                                                }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                                        <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarAeroOrigem');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                                        <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                                    </div>
                                </div>
                                <div class="item_form" style="margin-bottom: 10px;">
                                    <select id="select-exceto-apenas-aero-destino" name="select-exceto-apenas-aero-destino">
                                        <option value="apenas">Apenas os aeroportos (destino)</option>
                                        <option value="exceto">Exceto os aeroportos (destino)</option>
                                    </select>
                                    <div style="width: 70%;float: left;">
                                        <input class="input" type="text" id="inptAeroDestino" name="inptAeroDestino" readonly="true" placeholder="">
                                    </div>
                                    <div class="btns">
                                        <a href="javascript:" onclick="checkSession(function () {
                                                    removerValorInput('inptAeroDestino', true);
                                                }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                                        <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarAeroDestino');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                                        <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                                    </div>
                                </div>
                                <div class="item_form" style="margin-bottom: 10px;">
                                    <select id="select-exceto-apenas-rota" name="select-exceto-apenas-rota">
                                        <option value="apenas">Apenas as rotas</option>
                                        <option value="exceto">Exceto as rotas</option>
                                    </select>
                                    <div style="width: 70%;float: left;">
                                        <input class="input" type="text" id="inptRota" name="inptRota" readonly="true" placeholder="">
                                    </div>
                                    <div class="btns">
                                        <a href="javascript:" onclick="checkSession(function () {
                                                    removerValorInput('inptRota', true);
                                                }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                                        <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarRota');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                                        <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                                    </div>
                                </div>
                            </div>
                        </div>
              
                        <div class="item_form" id="filtros-adicionais">
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
                <button type="button" data-name="show" id="toggle" name="toggleAuditoria" style="margin-top: 115px !important;min-width: 170px !important;width:170px !important;border-radius: 5px !important;margin-left: -82px !important;" class="toggle">Exibir Auditoria</button>
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
            <jsp:include page="auditoria.jsp" />
            <input type="hidden" name="inp-auditoria" data-exclusao="true" data-rotina-auditoria="manifesto">
        </div>

        <div id="map" class="heightDoc">
            <div id="contentMap" style="">
                <script>
                    setTimeout(function () {
                        document.getElementById('progress-preferencias').value = 40;
                        document.getElementById('progress-porcentagem').innerHTML = '40%';
                    }, 10);
                </script>
                <%@ include file="grid-consulta-manifesto.jsp" %>
                <script>
                    setTimeout(function () {
                        document.getElementById('progress-preferencias').value = 90;
                        document.getElementById('progress-porcentagem').innerHTML = '90%';
                    }, 10);
                </script>
            </div>
            <div id="footerTable" style="height: 145px;display: none;">

                <div class="footerTableImpressao">
                    <div class="footer01">
                        <c:if test="${nivelUser >= 4}">
                            <button id="removeCte" class="removeCteOff" style="margin-top: 45px;" disabled="true" onclick="checkSession(function () {
                                        excluir();
                                    }, false);">
                                <img src="${homePath}/assets/img/icon-remove-off.png">Excluir selecionados</button>
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
                            <label impressaoPDF="true">Modelo em PDF</label>
                            <select name="cbmodelo" id="cbmodelo">
                                <option value="1" <c:if test="${config.getRelDefaultManifesto() == '1'}">selected</c:if>>Modelo 1 (Rodoviário)</option>
                                <option value="2" <c:if test="${config.getRelDefaultManifesto() == '2'}">selected</c:if>>Modelo 2 (Rodoviário)</option>
                                <option value="3" <c:if test="${config.getRelDefaultManifesto() == '3'}">selected</c:if>>Modelo 3 (Rodoviário)</option>
                                <option value="4" <c:if test="${config.getRelDefaultManifesto() == '4'}">selected</c:if>>Modelo 4 (Rodoviário)</option>
                                <option value="5" <c:if test="${config.getRelDefaultManifesto() == '5'}">selected</c:if>>Modelo 5 (Rodoviário)</option>
                                <option value="6" <c:if test="${config.getRelDefaultManifesto() == '6'}">selected</c:if>>Modelo 6 (Rodoviário)</option>
                                <option value="7" <c:if test="${config.getRelDefaultManifesto() == '7'}">selected</c:if>>Modelo 7 (Marítimo)</option>
                                <option value="8" <c:if test="${config.getRelDefaultManifesto() == '8'}">selected</c:if>>Modelo 8 (Rodoviário)</option>
                                <option value="9" <c:if test="${config.getRelDefaultManifesto() == '9'}">selected</c:if>>Modelo 9 (Rodoviário)</option>
                                <option value="10" <c:if test="${config.getRelDefaultManifesto() == '10'}">selected</c:if>>Modelo 10 (Rodoviário)</option>
                                <option value="11" <c:if test="${config.getRelDefaultManifesto() == '11'}">selected</c:if>>Modelo 11 (Rodoviário)</option>
                                <option value="12" <c:if test="${config.getRelDefaultManifesto() == '12'}">selected</c:if>>Modelo 12 (Rodoviário)</option>
                                <option value="13" <c:if test="${config.getRelDefaultManifesto() == '13'}">selected</c:if>>Modelo 13 (Capa de Lote)</option>
                                <option value="14" <c:if test="${config.getRelDefaultManifesto() == '14'}">selected</c:if>>Modelo 14 (Aereo - Pré-Alerta)</option>
                                <option value="15" <c:if test="${config.getRelDefaultManifesto() == '15'}">selected</c:if>>Modelo 15 (Rodoviário/Aéreo)</option>
                                <option value="16" <c:if test="${config.getRelDefaultManifesto() == '16'}">selected</c:if>>Modelo 16 (Aéreo - Minuta de Despacho)</option>


                                <c:forEach items="${relPersonalizadoManifesto}" var="rel">
                                    <c:set var="relCompleto" value="doc_manifesto_personalizado_${rel}" />
                                    <option value="doc_manifesto_personalizado_${rel}" <c:if test="${config.getRelDefaultManifesto() == relCompleto}">selected</c:if>>Modelo ${rel.toUpperCase()} (Personalizado)</option>
                                </c:forEach>

                            </select>
                            <label impressaoMatricial="true" style="margin-top: 5px !important;">Impressora</label>
                            <select name="caminho_impressora" id="caminho_impressora" >
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
                            <label exportar="true">Exportar:</label>
                            <select name="exportarPara" id="exportarPara">
                                <option value="FRONTDIG" selected>SEFAZ - Fronteira Digital (PE)</option>
                                <option value="FRONTRAP">SEFAZ - Fronteira Rápida (PI)</option>
                                <option value="FRONTRAPRN">SEFAZ - Fronteira Rápida (RN)</option>
                                <option value="SUFRAMA">SEFAZ - Arquivo (SUFRAMA/PIN)</option>
                                <option value="-">- - - - - - - - - - - - - - - - - - - - - -</option>
                                <option value="APISUL">Averbação (APISUL)</option>
                                <option value="ATM">Averbação (AT&M) Dados do CT-e</option>
                                <option value="ATM-M">Averbação (AT&M) Dados do Manifesto</option>
                                <option value="PAMCARY">Averbação (PAMCARY)</option>
                                <option value="PORTOSEGURO">Averbação (PORTO SEGURO)</option>
                                <option value="ITAUSEGUROS">Averbação (ITAU SEGUROS)</option>
                                <option value="CITNET">Averbação (CITNET)</option>
                                <option value="-">- - - - - - - - - - - - - - - - - - - - - -</option>
                                <c:if test="${roteirizador != N}">
                                    <option value="BUONNY">Roteirizador (BUONNY WEBSERVICE)</option>
                                </c:if>
                            </select>
                        </div>
                        <div class="footer03-02">
                            <div class="bt bt-impressao" onclick="popManifestoGeral();">Imprimir</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <img class="gif-bloq-tela" src="${homePath}/img/espere_new.gif" alt=""/>
        <div class="bloqueio-tela"></div>
        <!--<iframe id="iframeTest" scrolling="no" frameborder="0" allowfullscreen></iframe>-->
        <script src="${homePath}/assets/js/jquery-ui.min.js" type="text/javascript"></script>
        <script defer src="${homePath}/script/shortcut.js" type="text/javascript"></script>
        <script defer src="${homePath}/assets/js/jquery.mask.min.js"></script>
        <script defer src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/script/funcoesTelaConsulta.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/gwTrans/consultas/js/consulta-manifesto.js?v=${random.nextInt()}"></script>
        <script defer src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script defer src="${homePath}/assets/js/jquery.easyui.min.js"></script>

        <script defer type='text/javascript' lang="JavaScript">
                                var tipo = new filtro('veiculo');

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
                                    $("#select-abrev").selectmenu("refresh");
                                    jQuery('#select-oper option[value=' + '${filtros.operador}' + ']').prop('selected', true);
                                    $("#select-oper").selectmenu("refresh");
                    </c:if>
                </c:forEach>
                    changeSelectAbrev();
                <c:forEach var="filtros" items="${pref.filtros}" varStatus="filtrosStatus" >
                                    gerenciarInpSelectVal('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.colunaValor2}');
                                    gerenciarCheckBox('${filtros.colunaNome}', '${filtros.colunaValor}');
                                    gerenciarMostrarManifestos('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.colunaCondicaoLocalizar}', '${filtros.descricao}');
                                    gerenciarStatusMDFE('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.colunaCondicaoLocalizar}', '${filtros.descricao}');
                                    gerenciarInpFilial('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                                    gerenciarInpMotorista('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                                    gerenciarInpVeiculo('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                                    gerenciarInpCarreta('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                                    gerenciarInpAerea('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                                    gerenciarInpRedespachante('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                                    gerenciarInpAeroOrigem('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                                    gerenciarInpAeroDestino('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                                    gerenciarInpRota('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                                    //                                addValorAlphaInput('inpSelectVal', '${filtros.colunaValor}');
                                    gerenciarInpFilialDestino('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');


                </c:forEach>
            </c:if>

            <c:if test="${filtroEscolhido != null}">
                                    jQuery('#select-pesquisa').val('${filtroEscolhido}').change();
                                    jQuery("#select-pesquisa").selectmenu("refresh");
            </c:if>

                                    //Altera o src do salvarFiltros para passar por parametro o filtro escolhido.
                                    jQuery('#iframeSalvarFiltros').attr('src', jQuery('#iframeSalvarFiltros').attr('src') + '?nomePesquisa=' + jQuery('#select-pesquisa').val() + '&isPrivada=' + true);

            <c:if test="${nivelFilial <= 0}">
                                    removerValorInput('inptFilial');
                                    jQuery('.btnMoreFilial').hide();
                                    jQuery('.btnDeleteFilial').hide();
                                    addValorAlphaInput('inptFilial', '${userFilial.abreviatura}', '${userFilial.idfilial}');
                                    jQuery('.inputFilial').find('.gamma-li-chaves').css('background', '#c2c2c2');
                                    jQuery('.inputFilial').find('.gamma-li-chaves-a').remove();
                                    jQuery('#select-exceto-apenas-filial').selectExcetoApenasGw({
                                        width: '170px',
                                        readOnly: true
                                    });
            </c:if>
            <c:if test="${nivelFilial > 0}">
                                    jQuery('#select-exceto-apenas-filial').selectExcetoApenasGw({
                                        width: '170px'
                                    });
            </c:if>    
            <c:if test="${(!temacessofiliaisDestino && isFranquia) || ((nivelFilial == 0) && !isFranquia)}">
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
            <c:if test="${(!isFranquia && ( nivelFilial > 0 ))|| (temacessofiliaisDestino && isFranquia)}">
                                    jQuery('.btnMoreFilialDestino').show();
                                    jQuery('.btnDeleteFilialDestino').show();
                                    jQuery('#select-exceto-apenas-filial-destino').selectExcetoApenasGw({
                                        width: '170px'
                                    });
            </c:if>     
            
                                    setTimeout(function () {
                                        jQuery('.container-salvar-filtros').html('<iframe id="iframeSalvarFiltros" name="iframeSalvarFiltros" src="${homePath}/gwTrans/consultas/salvar_filtros.jsp?tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe><span class="seta-baixo"></span>');
                                        jQuery('.visualizarDocumentos').html('<iframe id="iframeVisualizarDocumentos" name="iframeVisualizarDocumentos" src="" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                                        jQuery(jQuery('.localiza')[0]).html('<iframe id="localizarFilial" input="inptFilial" name="localizarFilial" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarFilial&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                                        jQuery(jQuery('.localiza')[1]).html('<iframe id="localizarMotorista" input="inptMotorista" name="localizarMotorista" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarMotorista&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                                        jQuery(jQuery('.localiza')[2]).html('<iframe id="localizarVeiculoGeral" input="inptVeiculo" name="localizarVeiculoGeral" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarVeiculoGeral&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                                        jQuery(jQuery('.localiza')[3]).html('<iframe id="localizarCarreta" input="inptCarreta" name="localizarCarreta" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarCarreta&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                                        jQuery(jQuery('.localiza')[4]).html('<iframe id="localizarAerea" input="inptAerea" name="localizarAerea" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarAerea&tipoLocalizar=aerea&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                                        jQuery(jQuery('.localiza')[5]).html('<iframe id="localizarRedespachante" input="inptRedespachante" name="localizarRedespachante" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarRedespachante&tipoLocalizar=redespachante&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                                        jQuery(jQuery('.localiza')[6]).html('<iframe id="localizarAeroOrigem" input="inptAeroOrigem" name="localizarAeroOrigem" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarAeroOrigem&tipoLocalizar=aeroOrigem&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                                        jQuery(jQuery('.localiza')[7]).html('<iframe id="localizarAeroDestino" input="inptAeroDestino" name="localizarAeroDestino" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarAeroDestino&tipoLocalizar=aeroDestino&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                                        jQuery(jQuery('.localiza')[8]).html('<iframe id="localizarRota" input="inptRota" name="localizarRota" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarRota&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                                        jQuery(jQuery('.localiza')[9]).html('<iframe id="localizarFilialDestino" input="inptFilialDestino" name="localizarFilialDestino" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarFilialDestino&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                                    }, 1);
                                    
                                    //Funcao para ativar os selects exceto multiplo
                                    ativarExcetosMultiplosGw();
                                });

                                setTimeout(function () {
                                    document.getElementById('progress-preferencias').value = 100;
                                    document.getElementById('progress-porcentagem').innerHTML = '100%';
                                    jQuery('.load-preferencias').hide();

                                    adicionarLinkCadastro();
                                }, 1000);

                                function ativarExportacao() {
                                    var roteirizador = '${roteirizador}';
                                    var filialCNPJ = '${filialCNPJ}';
                                    jQuery('span[aria-owns="cbmodelo-menu"]').hide(250);
                                    jQuery('span[aria-owns="caminho_impressora-menu"]').hide(250);
                                    jQuery('span[aria-owns="driverImpressora-menu"]').hide(250);
                                    var x = 0;
                                    while (jQuery('[impressaoMatricial]')[x]) {
                                        jQuery(jQuery('[impressaoMatricial]')[x]).hide();
                                        x++;
                                    }
                                    jQuery('[impressaoPDF]').hide(250, function () {
                                        jQuery('[exportar]').show(250);
                                        jQuery('span[aria-owns="exportarPara-menu"]').show(250);
                                    });
                                    jQuery('.bt-impressao').attr('onclick', 'exportar("' + roteirizador + '", "' + filialCNPJ + '");');
                                    jQuery('.bt-impressao').text('Exportar');

                                }
                                
                                function editarCartaFrete(index) {
                                    var id = jQuery('#hi_row_num_contrato_frete_' + index).val();
                                    var nivelUserCf = ${nivelUserCf == 4 ? true : false};
                                    var stutilizacaocfe = jQuery('#hi_row_st_utilizacao_cfe_' + index).val();
                                    var isCiot = (stutilizacaocfe === "N" ? false : true);
                                    
                                    if (!id || id === '') {
                                        chamarAlert('Não existe contrato de frete para esse manifesto.');
                                        return false;
                                    }
                                    
                                    if (!isCiot) {
                                        window.open("./cadcartafrete?acao=editar&id=" + id + "&ex=" + nivelUserCf, "CONTRATO", "top=0,resizable=yes");
                                    } else {
                                        window.open("./ContratoFreteControlador?acao=iniciarEditar&id=" + id + "&ex=" + nivelUserCf, "CONTRATO", "top=0,resizable=yes");
                                    }
                                }
                                
                                function chamarDesativarGWi(index){                                    
                                    var numeroManifesto = jQuery('#hi_row_num_manifesto_' + index).val();
                                    chamarConfirm("Deseja desativar o Manifesto " + numeroManifesto + " do GW-i?", 'chamarDesativarGWiCTe('+index+')');                                    
                                }
                                
                                function chamarDesativarGWiCTe(index){                                    
                                    var idManifesto = jQuery('#hi_row_id_' + index).val();
                                    var numeroManifesto = jQuery('#hi_row_num_manifesto_' + index).val();
                                    chamarConfirm("Deseja também desativar todos CT-e(s) do GW-i, desse manifesto " + numeroManifesto + " ?",'desativarMDFeCTeGWi('+idManifesto+','+true+')', 'desativarMDFeCTeGWi('+idManifesto+','+false+')');
                                }
                                
                                function desativarMDFeCTeGWi(idManifesto, desativarCTe = false){                                        
                                        jQuery('.load-preferencias').show(250);
                                        
                                        console.log(desativarCTe);
                                        
                                        jQuery.ajax({
                                            url: '<c:url value="/ManifestoControlador" />',
                                            dataType: "text",
                                            method: "post",
                                            data: {
                                                idManifesto : idManifesto,
                                                desativarCTe : desativarCTe,                        
                                                acao : "desativarMDFeCTeGWi"
                                            },
                                            success: function(data) {
                                                if(String(data).trim() == "ok"){
                                                    window.location.reload();                                                    
                                                } else {
                                                    jQuery('.load-preferencias').hide(250);                                                
                                                    chamarAlert(data);    
                                                }
                                            },
                                            error: function(data) {
                                                jQuery('.load-preferencias').hide(250);                                                
                                                chamarAlert(data);
                                            }
                                        });                
                                }
                                
                                
                                function desagruparManifestoConfirm(index){
                                    chamarConfirm("Deseja desagrupar o manifesto " + jQuery('#hi_row_num_manifesto_' + index).val(), "desagruparManifesto("+index+")");
                                }
                                
                                function desagruparManifesto(index){
                                    var id = jQuery("#hi_row_id_"+index).val();
                                    jQuery.ajax({
                                        url: 'ManifestoControlador',
                                        type: 'POST',
                                        data: {
                                            acao: 'desagruparManifesto',
                                            ids: id
                                        },
                                        success: function (data, textStatus, jqXHR) {
                                            if (data === 'sucesso') {
                                                chamarAlert("Manifesto desagrupado com sucesso.", reload);
                                            }else{
                                                chamarAlert(data);
                                            }
                                        },
                                        error: function (jqXHR, textStatus, errorThrown) {
                                            chamarAlert("Ocorreu algum erro.");
                                        }
                                    });
                                }
                                
                                function abrirAgrupador(){
                                    var manifestosSelecionados = jQuery('input:checked[type=checkbox][name*=nCheck]').length;
                                    
                                    if (manifestosSelecionados < 2) {
                                        return false;
                                    }
                                    
                                    var index = 0;
                                    var abrir = true;
                                    var contStatus = 0;
                                    var contPai = 0;
                                    var paiPrincipal = "";
                                    var paiPrincipalId = "";
                                    var todosAlerts = "";
                                    var erro = "";
                                    
                                    var valBase = jQuery('input:checked[type=checkbox][name*=nCheck]')[0].value;
                                    var numeroBase = jQuery('#hi_row_num_manifesto_'+valBase).val();
                                    var veiculoBase = jQuery('#hi_row_veiculo_id_' + valBase).val();
                                    var carretaBase = jQuery('#hi_row_carreta_id_' + valBase).val();
                                    var biTremBase = jQuery('#hi_row_bitrem_id_' + valBase).val();
                                    var terceiroReboqueBase = jQuery('#hi_row_tri_reboque_id_' + valBase).val();
                                    var motoristaBase = jQuery('#hi_row_motorista_id_' + valBase).val();
                                    var filialOrigemBase = jQuery('#hi_row_id_filial_' + valBase).val();
                                    var cidadeOrigemBase = jQuery('#hi_row_cidade_origem_id_' + valBase).val();
                                    var ufDestinoBase = jQuery('#hi_row_uf_destino_' + valBase).val();
                                    var statusBase = jQuery('#hi_row_status_mdfe_' + valBase).val();
                                    var numeroPaiBase = jQuery('#hi_row_numero_manifesto_agrupado_' + valBase).val();
                                    var isPaiBase = jQuery('#hi_row_is_pai_' + valBase).val();
                                    
                                    while (jQuery('input:checked[type=checkbox][name*=nCheck]')[index] !== undefined) {
                                        var val = jQuery('input:checked[type=checkbox][name*=nCheck]')[index].value;
                                        var id = jQuery('#hi_row_id_' + val).val();
                                        var status = jQuery('#hi_row_status_mdfe_' + val).val();
                                        var veiculo = jQuery('#hi_row_veiculo_id_' + val).val();
                                        var carreta = jQuery('#hi_row_carreta_id_' + val).val();
                                        var biTrem = jQuery('#hi_row_bitrem_id_' + val).val();
                                        var terceiroReboque = jQuery('#hi_row_tri_reboque_id_' + val).val();
                                        var motorista = jQuery('#hi_row_motorista_id_' + val).val();
                                        var filialOrigem = jQuery('#hi_row_id_filial_' + val).val();
                                        var cidadeOrigem = jQuery('#hi_row_cidade_origem_id_' + val).val();
                                        var ufDestino = jQuery('#hi_row_uf_destino_' + val).val();
                                        var numero = jQuery('#hi_row_num_manifesto_' + val).val();
                                        var numeroPai = jQuery('#hi_row_numero_manifesto_agrupado_' + val).val();
                                        var idDoPai = jQuery('#hi_row_mdfe_pai_id_' + val).val();
                                        var isPai = (jQuery('#hi_row_is_pai_' + val).val() === 'true');
                                        
//                                        console.log("validações start");
//                                        console.log(veiculo === veiculoBase);
//                                        console.log(carreta === carretaBase);
//                                        console.log(biTrem === biTremBase);
//                                        console.log(terceiroReboque === terceiroReboqueBase);
//                                        console.log(motorista === motoristaBase);
//                                        console.log(filialOrigem === filialOrigemBase);
//                                        console.log(cidadeOrigem === cidadeOrigemBase);
//                                        console.log(ufDestino === ufDestinoBase);
//                                        console.log("validações stop");
                                        if (idDoPai !== undefined && idDoPai !== "") {
                                            var paiMarcado = validarPaiMarcado(idDoPai);
                                            if (!paiMarcado) {
                                                todosAlerts = todosAlerts + ("O manifesto " + numero + " não pode ser agrupado por já pertencer ao manifesto " + numeroPai+".<br>");
                                                abrir = false;
                                            }
                                        }
                                        if (isPai) {
                                            if (paiPrincipal === "" || paiPrincipal === numero) {
                                                paiPrincipal = numero;
                                                paiPrincipalId = id;
                                            }else{
                                                contPai++;
                                            }
                                        }
                                        if (status && status !== "Pendente") {
                                            contStatus = contStatus+1;
                                        }
                                        if (!(veiculo === veiculoBase && carreta === carretaBase && biTrem === biTremBase &&
                                                terceiroReboque === terceiroReboqueBase && motorista === motoristaBase &&
                                                filialOrigem === filialOrigemBase && cidadeOrigem === cidadeOrigemBase && ufDestino === ufDestinoBase)) {
                                            
                                                erro = camposErro(veiculo,carreta,biTrem,terceiroReboque,motorista,filialOrigem,cidadeOrigem,ufDestino,
                                                        veiculoBase,carretaBase,biTremBase,terceiroReboqueBase,motoristaBase,filialOrigemBase,
                                                        cidadeOrigemBase,ufDestinoBase);
                                            todosAlerts = todosAlerts + "O manifesto " + numero + " difere em " + erro+ "<br>" ;
                                            abrir = false;
                                        }
                                        
                                        index++;
                                    }
                                    
                                    if (contPai > 0) {
                                        chamarAlert("Existe mais de um manifesto principal.");
                                    }else if(contStatus > 0) {
                                        chamarAlert("Apenas manifestos pendentes podem ser marcado para ser agrupado.");
                                    }else if (!abrir) {
                                        chamarAlert("Erro: <br>" + todosAlerts);
                                    }else{
                                        jQuery('.cobre-tudo').show('show');
                                        jQuery('.container-agrupar-mdfe').html('<iframe id="agruparMDFEs" name="agruparMDFEs" src="${homePath}/gwTrans/consultas/agrupar_mdfe.jsp?idPrincipal='+paiPrincipalId+'&nomeusuario=${user.nome}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                                        jQuery(".container-agrupar-mdfe").show();
                                        jQuery(".container-agrupar-mdfe").animate({"width":"800px", "height":"620px", "top":"50%", "left":"50%"},500);
                                    }
                                }
                                
                                function abrirAgrupador1(){
//                                    Veiculo,carreta, bi trem, 3º reboque, Motorista, Filial de Origem, Cidade de Origem e UF de destino
                                    if (jQuery('input:checked[type=checkbox][name*=nCheck]').length < 2) {
                                        chamarAlert("Selecione dois ou mais manifestos.");
                                        return false;
                                    }
                                    var index = 1;
                                    var abrir = true;
                                    var contStatus = 0;
                                    var todosAlerts = "";
                                    var erro = "";
                                    
                                    var valBase = jQuery('input:checked[type=checkbox][name*=nCheck]')[0].value;
                                    var numeroBase = jQuery('#hi_row_num_manifesto_'+valBase).val();
                                    var veiculoBase = jQuery('#hi_row_veiculo_id_' + valBase).val();
                                    var carretaBase = jQuery('#hi_row_carreta_id_' + valBase).val();
                                    var biTremBase = jQuery('#hi_row_bitrem_id_' + valBase).val();
                                    var terceiroReboqueBase = jQuery('#hi_row_tri_reboque_id_' + valBase).val();
                                    var motoristaBase = jQuery('#hi_row_motorista_id_' + valBase).val();
                                    var filialOrigemBase = jQuery('#hi_row_id_filial_' + valBase).val();
                                    var cidadeOrigemBase = jQuery('#hi_row_cidade_origem_id_' + valBase).val();
                                    var ufDestinoBase = jQuery('#hi_row_uf_destino_' + valBase).val();
                                    var statusBase = jQuery('#hi_row_status_mdfe_' + valBase).val();
                                    var numeroPaiBase = jQuery('#hi_row_numero_manifesto_agrupado_' + valBase).val();
                                    var isPaiBase = jQuery('#hi_row_is_pai_' + valBase).val();
                                    
                                    if (numeroPaiBase !== "") {
                                        todosAlerts = todosAlerts + ("O manifesto " + numeroBase + " já foi adicionado ao manifesto " + numeroPaiBase + ".<br>");
                                        abrir = false;
                                    }else if(isPaiBase){
                                        todosAlerts = todosAlerts + ("O manifesto " + numeroBase + "já tem outros")
                                    }else if (statusBase !== "Pendente") {
                                        contStatus = contStatus+1;
                                    }
                                    
                                    while (jQuery('input:checked[type=checkbox][name*=nCheck]')[index] !== undefined) {
                                        var val = jQuery('input:checked[type=checkbox][name*=nCheck]')[index].value;
                                        var status = jQuery('#hi_row_status_mdfe_' + val).val();
                                        var veiculo = jQuery('#hi_row_veiculo_id_' + val).val();
                                        var carreta = jQuery('#hi_row_carreta_id_' + val).val();
                                        var biTrem = jQuery('#hi_row_bitrem_id_' + val).val();
                                        var terceiroReboque = jQuery('#hi_row_tri_reboque_id_' + val).val();
                                        var motorista = jQuery('#hi_row_motorista_id_' + val).val();
                                        var filialOrigem = jQuery('#hi_row_id_filial_' + val).val();
                                        var cidadeOrigem = jQuery('#hi_row_cidade_origem_id_' + val).val();
                                        var ufDestino = jQuery('#hi_row_uf_destino_' + val).val();
                                        var numero = jQuery('#hi_row_num_manifesto_' + val).val();
                                        var numeroPai = jQuery('#hi_row_numero_manifesto_agrupado_' + val).val();
                                        
//                                        console.log("validações start");
//                                        console.log(veiculo === veiculoBase);
//                                        console.log(carreta === carretaBase);
//                                        console.log(biTrem === biTremBase);
//                                        console.log(terceiroReboque === terceiroReboqueBase);
//                                        console.log(motorista === motoristaBase);
//                                        console.log(filialOrigem === filialOrigemBase);
//                                        console.log(cidadeOrigem === cidadeOrigemBase);
//                                        console.log(ufDestino === ufDestinoBase);
//                                        console.log("validações stop");
                                    

                                        if (numeroPai !== "") {
                                            todosAlerts = todosAlerts + "O manifesto " + numero + " já é agrupado ao manifesto " + numeroPai +".<br>";
                                            abrir = false;
                                        }else if (status !== "Pendente") {
                                            contStatus = contStatus+1;
                                        }else if (!(veiculo === veiculoBase && carreta === carretaBase && biTrem === biTremBase &&
                                                terceiroReboque === terceiroReboqueBase && motorista === motoristaBase &&
                                                filialOrigem === filialOrigemBase && cidadeOrigem === cidadeOrigemBase && ufDestino === ufDestinoBase)) {
                                            
                                                erro = camposErro(veiculo,carreta,biTrem,terceiroReboque,motorista,filialOrigem,cidadeOrigem,ufDestino,
                                                        veiculoBase,carretaBase,biTremBase,terceiroReboqueBase,motoristaBase,filialOrigemBase,
                                                        cidadeOrigemBase,ufDestinoBase);
                                            todosAlerts = todosAlerts + "O manifesto " + numero + " difere em " + erro+ "<br>" ;
                                            abrir = false;
                                        }
                                        
                                        index++;
                                    }
                                    
                                    if(contStatus === 0) {
                                        chamarAlert("Apenas manifestos pendentes podem ser marcado para ser agrupado.");
                                    }else if (!abrir) {
                                        chamarAlert("Erro: <br>" + todosAlerts);
                                    }else{
                                        jQuery('.cobre-tudo').show('show');
                                        jQuery('.container-agrupar-mdfe').html('<iframe id="agruparMDFEs" name="agruparMDFEs" src="${homePath}/gwTrans/consultas/agrupar_mdfe.jsp" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                                        jQuery(".container-agrupar-mdfe").show();
                                        jQuery(".container-agrupar-mdfe").animate({"width":"800px", "height":"620px", "top":"25%", "left":"20%"},500);
                                    }
                                }
                                
                                var listaManifestoMarcadosAgrupar = "";
                                /**
                                 * Função para povoar uma lista com os manifestos marcados a serem recuperados na tela 'agrupar_mdfe.jsp'
                                 * @returns {String|listaManifestoMarcadosAgrupar}
                                 */
                                function manifestosMarcados(){
                                    var index = 0;
                                    listaManifestoMarcadosAgrupar = "";
                                    while (jQuery('input:checked[type=checkbox][name*=nCheck]')[index] !== undefined) {

                                        var val = jQuery('input:checked[type=checkbox][name*=nCheck]')[index].value;
                                        var id = jQuery('#hi_row_id_' + val).val();
                                        var numero = jQuery('#hi_row_num_manifesto_' + val).val();
                                        var serie = jQuery('#hi_row_serie_mdfe_' + val).val();
                                        var data = jQuery('#hi_row_data_saida_' + val).val();
                                        var cidade = jQuery('#hi_row_cidade_destino_' + val).val();
                                        var uf = jQuery('#hi_row_uf_destino_' + val).val();
                                        listaManifestoMarcadosAgrupar = listaManifestoMarcadosAgrupar +
                                                "@#$" + id + "!!" + numero + "!!" + data + "!!" + serie +"!!" + cidade + "!!" + uf;
                                        index++;
                                    }
                                    return listaManifestoMarcadosAgrupar.substring(3);
                                }
                                
                                function cancelarAgrupamento(){
                                    jQuery('.cobre-tudo').hide('slow');
                                    jQuery('.container-agrupar-mdfe').html("");
                                    jQuery('.container-agrupar-mdfe').hide();
                                }
                                
                                /**
                                 * Após a confirmação do agrupamento, chamar o ajax.
                                 * @param {type} ids
                                 * @param {type} pai
                                 * @returns {undefined}                                 */
                                function confirmarAgrupamento(ids, pai){
                                    jQuery.ajax({
                                        url: 'ManifestoControlador',
                                        type: 'POST',
                                        data: {
                                            acao: 'agruparManifesto',
                                            ids: ids,
                                            pai: pai
                                        },
                                        success: function (data, textStatus, jqXHR) {
                                            if (data === 'sucesso') {
                                                chamarAlert("Manifesto agrupado com sucesso.", reload);
                                            }else{
                                                chamarAlert(data);
                                            }
                                        },
                                        error: function (jqXHR, textStatus, errorThrown) {
                                            chamarAlert("Ocorreu algum erro.");
                                        }
                                    });
                                }
                                
                                function reload() {
                                    window.location.reload();
                                }

                                /**
                                 * @param {type} veiculo
                                 * @param {type} carreta
                                 * @param {type} biTrem
                                 * @param {type} terceiroReboque
                                 * @param {type} motorista
                                 * @param {type} filialOrigem
                                 * @param {type} cidadeOrigem
                                 * @param {type} ufDestino
                                 * @param {type} veiculoBase
                                 * @param {type} carretaBase
                                 * @param {type} biTremBase
                                 * @param {type} terceiroReboqueBase
                                 * @param {type} motoristaBase
                                 * @param {type} filialOrigemBase
                                 * @param {type} cidadeOrigemBase
                                 * @param {type} ufDestinoBase
                                 * @returns {String} */
                                function camposErro(veiculo,carreta,biTrem,terceiroReboque,motorista,filialOrigem,cidadeOrigem,ufDestino,
                                                veiculoBase,carretaBase,biTremBase,terceiroReboqueBase,motoristaBase,filialOrigemBase,
                                                    cidadeOrigemBase,ufDestinoBase){
                                    var retorno = "";
                                    if (veiculo !== veiculoBase) {
                                        retorno = retorno + ",veiculo";
                                    }
                                    if (carreta !== carretaBase) {
                                        retorno = retorno + ",carreta";
                                    }
                                    if (biTrem !== biTremBase) {
                                        retorno = retorno + ",bitrem";
                                    }
                                    if (terceiroReboque !== terceiroReboqueBase) {
                                        retorno = retorno + ",terceiro reboque";
                                    }
                                    if (motorista !== motoristaBase) {
                                        retorno = retorno + ",motorista";
                                    }
                                    if (filialOrigem !== filialOrigemBase) {
                                        retorno = retorno + ",filial de origem";
                                    }
                                    if (cidadeOrigem !== cidadeOrigemBase) {
                                        retorno = retorno + ",cidade de origem";
                                    }
                                    if (ufDestino !== ufDestinoBase) {
                                        retorno = retorno + ",UF de destino";
                                    }
                                    return retorno.substring(1);
                                }
                                
                                /**
                                 * Verifica se tem algum marcado que é pai.
                                 * @param {type} paiAtual
                                 * @returns {Boolean}                                 */
                                function validarPaiMarcado(paiAtual){
                                    var index = 0;
                                    var existe = false;
                                    while (jQuery('input:checked[type=checkbox][name*=nCheck]')[index] !== undefined) {
                                        var val = jQuery('input:checked[type=checkbox][name*=nCheck]')[index].value;
                                        var numero = jQuery('#hi_row_id_' + val).val();
                                        if (paiAtual === numero) {
                                            existe = true;
                                        }
                                        index++;
                                    }
                                    return existe;
                                }
        </script>
    </body>
</html>
