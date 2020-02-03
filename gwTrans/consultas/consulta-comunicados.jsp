<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="/WEB-INF/tld/custonTagLibrary.tld" prefix="cg" %>
<jsp:useBean id="random" class="java.util.Random" scope="application"/>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@page contentType="text/html" pageEncoding="ISO-8859-1" %>
<!DOCTYPE html>
<html>
<c:if test="${user == null}">
    <c:redirect url="/login"/>
</c:if>
<c:if test="${nivelUser == null || nivelUser <= 0}">
    <c:redirect url="/401"/>
</c:if>
<head>
    <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${tema}.css?v=${random.nextInt()}">
    <script src="${homePath}/script/jQuery/jquery.js?v=${random.nextInt()}"></script>
    <script src="${homePath}/assets/alerts/alerts-min.js?v=${random.nextInt()}"></script>
    <jsp:include page="/importAlerts.jsp">
        <jsp:param name="caminhoImg" value="assets/img/gw-trans.png"/>
        <jsp:param name="nomeUsuario" value="${user.nome}"/>
    </jsp:include>
    <meta charset="ISO-8859-1">
    <meta name="viewport" content="width=device-width">
    <title>GW Trans - Consulta de Comunicados</title>
    <link href="${homePath}/assets/css/jquery-ui-min.css?v=${random.nextInt()}" rel="stylesheet">
    <link href="${homePath}/assets/css/bootstrap-custom-col.css?v=${random.nextInt()}" rel="stylesheet">
    <link rel="stylesheet" href="${homePath}/assets/css/easyui.css?v=${random.nextInt()}">
    <link rel="stylesheet" href="${homePath}/assets/css/consulta.css?v=${random.nextInt()}">
    <link href="${homePath}/assets/css/inputs-gw.css?v=${random.nextInt()}" rel="stylesheet">
    <link rel="stylesheet" href="${homePath}/assets/css/font-roboto.css?v=${random.nextInt()}">
    <script src="${homePath}/assets/js/coluna_ajuda_filtros.js?v=${random.nextInt()}"></script>
    <link href="${homePath}/gwTrans/consultas/css/consulta-comunicados.css?v=${random.nextInt()}" rel="stylesheet">
    <link href="${homePath}/anuncios/css-anuncios/anuncio.css?v=${random.nextInt()}" rel="stylesheet">
    <script defer src="${homePath}/script/validarSessao.js?v=${random.nextInt()}"></script>
    <script defer>
        var codigoTela = 'T00134';
        var codigo_tela = 134;
        var idPreferencia = 0;
        var homePath = '${homePath}';
        var tema = '${tema}';

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
</head>
<body>
<div class="load-preferencias">
    <div class="container-progress">
        <img class="caminhao" id="caminhao" src="${homePath}/img/loading.gif">
        <div class="cs-loader">
            <div class="cs-loader-inner">
                <label> C</label>
                <label> A</label>
                <label> R</label>
                <label> R</label>
                <label> E</label>
                <label> G</label>
                <label> A</label>
                <label> N</label>
                <label> D</label>
                <label> O</label>
            </div>
        </div>
        <div class="progress-porcentagem" id="progress-porcentagem">15%</div>
        <progress max="100" value="15" class="progress-preferencias" id="progress-preferencias">
        </progress>
    </div>
</div>
<img class="gif-bloq-tela-left" src="${homePath}/img/espere_new.gif" alt=""/>
<div class="container-salvar-filtros">
    <iframe id="iframeSalvarFiltros" name="iframeSalvarFiltros" src="${homePath}/gwTrans/consultas/salvar_filtros.jsp"
            frameborder="0" marginheight="0" marginwidth="0" scrolling="no"></iframe>
    <span class="seta-baixo"></span>
</div>
<div id="topo">
    <div id="logo">
        <h3>Consulta de Comunicados<img src="${homePath}/assets/img/trans_white.png"></h3>
    </div>
    <div id="actions">
        <img id="logoCliente" width="68px" height="44px" src="">
    </div>
</div>
<div class="cobre-anuncio-escolhido"></div>
<iframe src="${homePath}/anuncios/container-anuncios.jsp?tema=${cfg.getTipoTema().getCor()}" class="iframe-anuncio-escolhido" frameborder="0" marginheight="0" marginwidth="0" scrolling="no"></iframe>
<div class="cobre-tudo"></div>
<div id="sidebar" class="heightDoc">
    <div class="columnLeft" id="columnLeft">
        <div class="cobre-left"></div>
        <div class="content">
            <form action="ConsultaControlador?codTela=134" method="POST" id="formConsulta" name="formConsulta">
                <div class="item_form">
                    <label class="label-pesquisas-salvas">Pesquisas salvas disponíveis</label>
                    <select class="input" id="select-pesquisa" name="select-pesquisa" onchange="">
                        <option value="0">Ultima pesquisa realizada</option>
                        <c:forEach var="listPrefPerso" items="${listaPreferenciasPersonalizadas}" varStatus="filtrosStatus">
                            <option value="${listPrefPerso}">${listPrefPerso}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="item_form filtro-pesquisa">
                    <label>Filtro</label>
                    <select class="input" id="select-abrev" name="select-abrev" onchange="">
                        <c:forEach var="columnFiltroSelect" items="${tela.targetXml.columnFiltroSelect}"
                                   varStatus="rowStatus">
                            <option value="${columnFiltroSelect.name}">${columnFiltroSelect.label}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="item_form container-campos-select">
                    <select class="input" id="select-oper" name="select-oper" onchange="">
                        <option value="1">Todas as partes com</option>
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
                            <c:forEach var="columnOrdenacaoSelect" items="${tela.targetXml.columnOrdenacaoSelect}"
                                       varStatus="rowStatus">
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
        <button type="button" data-name="hide" id="toggle" name="toggle"
                style="margin-left: -70px !important;border-radius: 5px!important;min-width: 150px !important;width:150px !important;"
                class="toogleOn">Ocultar filtros
        </button>
        <button type="button" data-name="show" id="toggle" name="toggleAjuda"
                style="margin-top: 105px !important;min-width: 150px !important;width:150px !important;border-radius: 5px !important;margin-left: -72px !important;"
                class="toogleOnAjuda">Exibir Ajuda
        </button>
    </div>
    <div class="notificacao" style="top: 397px !important;margin-left: 26.2% !important;">
        <center><label>0</label></center>
    </div>
    <div class="seta-conteudo-notificacao" style="top: 412px !important;margin-left: 26% !important;"></div>
    <div class="conteudo-notificacao" style="top: 422px !important;margin-left: 25.8% !important;">
        <div>
            <span>Notificação</span>
            <p>Existem videos novos relacionados a tela.</p>
        </div>
    </div>
    <div class="columnLeft column-left-ajuda" id="columnLeftAjuda" style="z-index: 999;position: absolute;width:0px;">
        <div class="content">
            <form>
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
                    <center class="div-lb-videos-ajuda"><h3 class="h3-video">Vídeos de Ajuda</h3></center>
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
                                        <input type="hidden" value="${video.id}" name="idVideo${videoStatus.count}"
                                               id="idVideo${videoStatus.count}">
                                        <iframe src="${video.url}" id="video${videoStatus.count}" class="videos-tela"
                                                scrolling="no" frameborder="0" allowfullscreen></iframe>
                                    </div>
                                    <div class="col-md-6">
                                        <span class="texto-video">${video.titulo}<p>${video.descricao}</p></span>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                    <hr class="hr-final">
                </c:if>

            </form>
        </div>
    </div>
</div>
<div id="map" class="heightDoc">
    <div id="contentMap" style="">
        <script>
            setTimeout(function () {
                document.getElementById('progress-preferencias').value = 40;
                document.getElementById('progress-porcentagem').innerHTML = '40%';
            }, 10);
        </script>
        <%@ include file="grid-default.jsp" %>
        <script>
            setTimeout(function () {
                document.getElementById('progress-preferencias').value = 90;
                document.getElementById('progress-porcentagem').innerHTML = '90%';
            }, 10);
        </script>
    </div>
</div>
<img class="gif-bloq-tela" src="${homePath}/img/espere_new.gif" alt=""/>
<div class="bloqueio-tela"></div>
<script src="${homePath}/assets/js/jquery-ui.min.js?v=${random.nextInt()}"></script>
<script defer src="${homePath}/script/shortcut.js?v=${random.nextInt()}"></script>
<script defer src="${homePath}/assets/js/jquery.mask.min.js?v=${random.nextInt()}"></script>
<script defer src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}"></script>
<script src="${homePath}/script/funcoesTelaConsulta.js?v=${random.nextInt()}"></script>
<script defer type='text/javascript' lang="JavaScript">
    function proxima() {
        var parametros =
            "&paginaAtual=" + ${consulta.paginacao.paginaAtual+1}
            +"&select-limite=" + ${consulta.paginacao.limiteResultados}
            +"&paginas=" +${consulta.paginacao.paginas};

        location.replace("ConsultaControlador?codTela=" + codigo_tela + parametros);

    }

    function anterior() {
        var parametros =
            "&paginaAtual=" + ${consulta.paginacao.paginaAtual-1}
            +"&select-limite=" + ${consulta.paginacao.limiteResultados}
            +"&paginas=" +${consulta.paginacao.paginas};

        location.replace("ConsultaControlador?codTela=" + codigo_tela + parametros);
    }

    function paginaEnter(evn, pagina) {
        if (evn.keyCode == 13) {
            var parametros =
                "&paginaAtual=" + pagina
                + "&select-limite=" + ${consulta.paginacao.limiteResultados}
                +"&paginas=" +${consulta.paginacao.paginas};

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
    
                gerenciarInpSelectVal('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.colunaValor2}');
            </c:forEach>
        </c:if>

        <c:if test="${filtroEscolhido != null}">
            jQuery('#select-pesquisa').val('${filtroEscolhido}').change();
            jQuery("#select-pesquisa").selectmenu("refresh");
        </c:if>

        //Altera o src do salvarFiltros para passar por parametro o filtro escolhido.
        jQuery('#iframeSalvarFiltros').attr('src', jQuery('#iframeSalvarFiltros').attr('src') + '?nomePesquisa=' + jQuery('#select-pesquisa').val() + '&isPrivada=' + true + '&tema=${tema}');
    });

    setTimeout(function () {
        document.getElementById('progress-preferencias').value = 100;
        document.getElementById('progress-porcentagem').innerHTML = '100%';
        jQuery('.load-preferencias').hide();
    }, 1000);
</script>
<script src="${homePath}/gwTrans/consultas/js/consulta-comunicados.js?v=${random.nextInt()}"></script>
<script defer src="${homePath}/assets/js/jquery.easyui.min.js?v=${random.nextInt()}"></script>
</body>
</html>