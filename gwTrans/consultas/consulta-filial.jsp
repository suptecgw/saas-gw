<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="/WEB-INF/tld/custonTagLibrary.tld" prefix="cg" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<jsp:useBean id="random" class="java.util.Random" scope="application" />
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
    <head>
        <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${tema}.css?v=${random.nextInt()}">
        <script src="${homePath}/script/jQuery/jquery.js" type="text/javascript"></script>
        <script src="${homePath}/assets/alerts/alerts-min.js" type="text/javascript"></script>
        <jsp:include page="/importAlerts.jsp">
            <jsp:param name="caminhoImg" value="assets/img/gw-trans.png"/>
            <jsp:param name="nomeUsuario" value="${user.nome}"/>
        </jsp:include>
        <meta charset="ISO-8859-1">
        <meta name="viewport" content="width=device-width">
        <title>GW Trans - Consulta de Filiais</title>
        <link href="${homePath}/assets/css/jquery-ui-min.css" rel="stylesheet" type="text/css"/>
        <link href="assets/css/bootstrap-custom-col.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="${homePath}/assets/css/easyui.css?v=${random.nextInt()}">
        <link rel="stylesheet" href="${homePath}/assets/css/consulta.css?v=${random.nextInt()}">
        <!--<link rel="stylesheet" href="${homePath}/assets/css/consulta.css?v=${random.nextInt()}">-->	
        <link rel="stylesheet" href="${homePath}/assets/css/inputs-gw.css" type="text/css"/>
        <link rel="stylesheet" href="${homePath}/assets/css/font-roboto.css">
        <link href="${homePath}/gwTrans/cadastros/css/estilo-input-form-gw.css" rel="stylesheet">
        <link rel="stylesheet" href="${homePath}/gwTrans/consultas/css/auditoria.css?v=${random.nextInt()}">
        <script src="${homePath}/assets/js/coluna_ajuda_filtros.js?v=${random.nextInt()}"></script>
        <!--<script src="${homePath}/script/validarSessao.js" type="text/javascript"></script>-->
        <script src="${homePath}/script/validarSessao.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script>
            var codigo_tela = '1';
        </script>
    </head>
    <body style="overflow: hidden;">
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
        <!--<img src="${homePath}/assets/img/save_filtros.png" class="salvarFiltros">-->

        <div id="topo">
            <div id="logo">
                <h3>Consulta de Filiais<img src="${homePath}/assets/img/trans_white.png"></h3>
            </div>
            <div id="actions">
                <img id="logoCliente" width="68px" height="44px" src="">
                <ul>
                    <c:if test="${nivelUser >= 3}">
                        <li>
                            <div class="bt bt-cadastro"  onclick="javascript:checkSession(function(){cadastrarFilial();},false);">Novo cadastro</div>
                        </li>
                    </c:if>
                    <li>
                        <div class="bt bt-relatorio"  onclick="javascript:checkSession(function(){relatorios();},false);">Relatório</div>
                    </li>
                </ul>
                <!--<a href="javascript:;"><img src="${homePath}/assets/img/icon-question.png" class="right question"></a>-->
            </div>
        </div>
        <div class="cobre-tudo"></div>
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
                    <form action="ConsultaControlador?codTela=1" method="POST" id="formConsulta" name="formConsulta">
                        <div class="item_form">
                            <label style="padding-bottom: 5px !important;">Pesquisas salvas disponíveis</label>
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
                                <option value="3">Apenas com o início</option>
                                <option value="2">Apenas com o fim</option>
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
                            <div class="item_form">
                                <select id="select-exceto-apenas-cidade" name="select-exceto-apenas-cidade">
                                    <option value="apenas">Apenas as Cidades</option>
                                    <option value="exceto">Exceto as Cidades</option>
                                </select>
                                <div style="width: 70%;float: left;margin-top: 5px;">
                                    <input class="input" type="text" id="inptCidade" name="inptCidade" readonly="true" placeholder="">
                                </div>
                                <div class="btns">
                                    <a href="javascript:" onclick="checkSession(function () {
                                                removerValorInput('inptCidade', true);
                                            }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                                    <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarCidade');},false);" class="btnMore" style="float: right !important;margin-right: 5px;"></a>
                                    <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
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
            <input type="hidden" name="inp-auditoria" data-exclusao="true" data-rotina-auditoria="filial">
        </div>
        <div id="map" class="heightDoc" style="overflow-y: hidden;">
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
            <div id="footerTable" style="width: 50%;">
                <div class="footerTable" style="width: 70%">
                    <div class="item_form">
                        <c:if test="${nivelUser >= 4}">
                            <button id="removeCte" class="removeCteOff" disabled="true" onclick="checkSession(function () {
                                        excluir();
                                    }, false);">
                                <img src="${homePath}/assets/img/icon-remove-off.png">Excluir selecionadas</button>
                            </c:if>
                    </div>
                </div>
            </div>
        </div>
        <img class="gif-bloq-tela" src="${homePath}/img/espere_new.gif" alt=""/>
        <div class="bloqueio-tela"></div>

        <!--<iframe id="iframeTest" scrolling="no" frameborder="0" allowfullscreen></iframe>-->

<!--<script src="${homePath}/script/jquery-1.11.2.min.js" type="text/javascript"></script>-->
        <script src="${homePath}/assets/js/jquery-ui.min.js" type="text/javascript"></script>
        <script src="${homePath}/script/shortcut.js" type="text/javascript"></script>
        <script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/assets/js/jquery.mask.min.js?v=${random.nextInt()}"></script>
        <script src="${homePath}/script/funcoesTelaConsulta.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script defer src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}" type="text/javascript"></script>
        <!--<script src="${homePath}/assets/js/sorttable.js" type="text/javascript"></script>-->
        <script type='text/javascript' lang="JavaScript">
                                
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
                                    gerenciarInpSelectVal('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.colunaValor2}');
                                    gerenciarInpCidade('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                                    gerenciarCheckBox('${filtros.colunaNome}', '${filtros.colunaValor}');
                                    //                                addValorAlphaInput('inpSelectVal', '${filtros.colunaValor}');

                </c:forEach>
            </c:if>

            <c:if test="${filtroEscolhido != null}">
                                    jQuery('#select-pesquisa').val('${filtroEscolhido}').change();
                                    jQuery("#select-pesquisa").selectmenu("refresh");
            </c:if>

                                    jQuery('#iframeSalvarFiltros').attr('src', jQuery('#iframeSalvarFiltros').attr('src') + '?nomePesquisa=' + jQuery('#select-pesquisa').val() + '&isPrivada=' + true);

                                    setTimeout(function () {
                                        jQuery(jQuery('.localiza')[0]).html('<iframe id="localizarCidade" input="inptCidade" name="localizarCidade" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarCidade&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                                    }, 1);
                                });

                                function gerenciarInpSelectVal(nome, valor, valor2) {
                                    if (jQuery('#select-abrev option[value=' + nome + ']').size() >= 1) {
                                        if (nome == 'created_at') {
                                            jQuery('.container-campos-select').hide(250, function () {
                                                jQuery('.container-data').show(250);
                                                jQuery("#dataAte").datebox({disabled: false});
                                                jQuery("#dataDe").datebox({disabled: false});

                                                jQuery('#dataAte').datebox('setValue', valor2);
                                                jQuery('#dataDe').datebox('setValue', valor);

                                                jQuery('.datebox').css('width', '93%');
                                                jQuery('.textbox-text').css('width', '93%');
                                                jQuery('.textbox-text').css('font-size', '14px');
                                            });
                                        } else if (nome == 'updated_at') {
                                            jQuery('.container-campos-select').hide(250, function () {
                                                jQuery('.container-data').show(250);

                                                jQuery("#dataAte").datebox({disabled: false});
                                                jQuery("#dataDe").datebox({disabled: false});

                                                jQuery('#dataAte').datebox('setValue', valor2);
                                                jQuery('#dataDe').datebox('setValue', valor);

                                                jQuery('.datebox').css('width', '93%');
                                                jQuery('.textbox-text').css('width', '93%');
                                                jQuery('.textbox-text').css('font-size', '14px');
                                            });
                                        } else {
                                            jQuery("#dataAte").datebox({disabled: true});
                                            jQuery("#dataDe").datebox({disabled: true});
                                            valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
                                            valor = valor.split(",");
                                            for (var i = 0; i < valor.length; i++) {
                                                addValorAlphaInput('inpSelectVal', valor[i].trim());
                                            }
                                        }
                                    }
                                }

                                function gerenciarInpCidade(nome, valor, descricao, condicao) {
                                    if (nome == 'cidade_id') {
                                        jQuery('#select-exceto-apenas-cidade option[value="' + condicao + '"]').attr('selected', 'selected');

                                        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
                                        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

                                        valor = valor.split(",");
                                        descricao = descricao.split(",");

                                        for (var i = 0; i < valor.length; i++) {
                                            jQuery('#filtros-adicionais-container').show();
                                            addValorAlphaInput('inptCidade', descricao[i].trim(), valor[i].trim());
                                        }
                                    }
                                }

                                function gerenciarCheckBox(nome, valor) {
                                    if (nome == 'created_by') {
                                        jQuery('#createdMe').prop('checked', true);
                                        jQuery('#filtros-adicionais-container').show();
                                    }
                                }

                                var codigoTela = 'T00001';
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

                                var myConfObj = {
                                    iframeMouseOver: false
                                };

                                var containerVideo = null;

                                window.addEventListener('blur', function () {
                                    if (myConfObj.iframeMouseOver) {
                                        jQuery(containerVideo).trigger('change');
                                    }
                                });
                                function cadastrarFilial() {
                                    location.replace("jspcadfilial.jsp?acao=iniciar");
                                }

                                function relatorios() {
                                    window.open('./relfilial.jsp?acao=iniciar&modulo=webtrans', "_blank", "toolbar=yes,scrollbars=yes,resizable=yes,top=200,left=500,width=800,height=600");
                                }

                                function editar(position) {
                                    var id = jQuery("#hi_row_idfilial_" + position).val();
                                    window.location.href = "./cadfilial?acao=editar&id=" + id;
                                }

                                function excluir(item) {
                                    var index = 0;
                                    var ids = '';
                                    var nomes = '';


                                    if (item == undefined) {
                                        while (jQuery('input:checked[type=checkbox][name*=nCheck]')[index] != undefined) {
                                            var val = jQuery('input:checked[type=checkbox][name*=nCheck]')[index].value;
                                            var id = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().find('#hi_row_idfilial_' + val).val();
                                            var nome = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().find('#hi_row_razaosocial_' + val).val();

                                            if (jQuery('input:checked[type=checkbox][name*=nCheck]')[index + 1] != undefined) {
                                                ids += id + ',';
                                            } else {
                                                ids += id;
                                            }

                                            nomes += '<li>' + nome + '</li>';

                                            index++;
                                        }
                                    } else if (item != undefined) {
                                        ids = jQuery('#hi_row_idfilial_' + item).val();
                                        nomes = jQuery('#hi_row_razaosocial_' + item).val();
                                    }

                                    var texto = "";
                                    if (index > 1) {
                                        texto = "Deseja excluir as filiais abaixo?";
                                    } else {
                                        texto = "Deseja excluir a filial abaixo?";
                                    }
                                    chamarConfirm(texto, 'aceitouExcluirFiliais("' + ids + '")', '', 1, '<ul class="square">' + nomes + '</ul>');

                                }

                                function aceitouExcluirFiliais(ids) {
                                    jQuery.ajax({
                                        url: 'FilialControlador?acao=excluir&ids=' + ids,
                                        success: function (data, textStatus, jqXHR) {
                                            if (data.indexOf("ERROR:") != -1) {
                                                data = "Ocorreu um erro ao tentar excluir a(s) filial(is)";
                                            }
                                            chamarAlert(data, reload);
                                        }
                                    });
                                }

                                function reload() {
                                    window.location.reload();
                                }

                                function consulta() {
                                    jQuery("#formConsulta").submit();
                                }

                                function salvarPreferencias() {
                                    var json = getJsonPreferencias();
                                    jQuery.ajax({
                                        dataType: 'json',
                                        method: 'POST',
                                        url: 'ConsultaControlador?acao=salvarPreferencias&codigoTela=1',
                                        data: {'json': json},
                                        sucess: function () {}
                                    });

                                }

                                var saveTimeOut;
                                var tempoEspera = 2000;

                                function monitorarPreferenciaUsuario() {
                                    if (saveTimeOut !== null && saveTimeOut !== undefined) {
                                        clearTimeout(saveTimeOut);
                                    }
                                    saveTimeOut = setTimeout(function () {
                                        salvarPreferencias();
                                    }, tempoEspera);
                                }


                                function getJsonPreferencias() {
                                    var index = 0;
                                    var ths = jQuery('.pode-setar-ordem');
                                    var jsonValores = {};
                                    while (ths[index] !== null && ths[index] !== undefined) {
                                        var obj = {
                                            nome_coluna: jQuery(jQuery('.pode-setar-ordem')[index]).attr('nome'),
                                            largura_coluna: jQuery(jQuery('.pode-setar-ordem')[index]).width() + 'px',
                                            ordem_coluna: jQuery(jQuery('.pode-setar-ordem')[index]).attr('ordem'),
                                            excluir_coluna: (jQuery(jQuery('.pode-setar-ordem')[index]).attr('oculta') !== undefined ? 'true' : 'false')
                                        };
                                        jsonValores[index] = obj;
                                        index++;
                                    }

                                    return JSON.stringify(jsonValores);
                                }

                                function abrirLocalizarCidade() {
                                    //Reduz o z-index do lb-filtros para ele nao parecer
                                    jQuery('.div-lb-filtros').css('z-index', '99');

                                    jQuery('.localiza').show('show');
                                    jQuery('.cobre-tudo').show('show');
                                    if (localizarCidade.document.getElementById('chkOpcoesAvancadas').checked && jQuery('#inptCidade').val() !== undefined && jQuery('#inptCidade').val().trim() !== '') {
                                        var i = 0;
                                        while (jQuery('#inptCidade').val().split('!@!')[i] != null) {
                                            localizarCidade.popularListaCidadesEscolhidas(jQuery('#inptCidade').val().split('!@!')[i], 'PE');
//                        jQuery(localizarCidade.document.getElementById('sortable2')).find('li').find('.cidade')
                                            i++;
                                        }
                                    }
                                }

                                function controleLocalizarCidades(acao, parametros, apagarDadosInput) {
                                    if (acao === 'fechar') {
                                        jQuery('.localiza').hide('show');
                                        jQuery('.cobre-tudo').hide('show');
                                        localizarCidade.voltarTodosItens();
                                        //Restaura o z-index do div-lb-filtros para ele aparecer
                                        jQuery('.div-lb-filtros').css('z-index', '999999');
                                    } else if (acao === 'finalizado') {
                                        controleLocalizarCidades('fechar', null);
                                        if (apagarDadosInput === true) {
                                            removerValorInput('inptCidade');
                                        }
                                        addValorAlphaInput('inptCidade', parametros.split("!@!")[0]);
                                        localizarCidade.voltarTodosItens();
                                    } else if (acao === 'mensagem') {
                                        chamarAlert(parametros, null);
                                        localizarCidade.voltarTodosItens();
                                    }
                                }

                                jQuery(document).ready(function () {

                                    jQuery('#select-exceto-apenas-cidade').selectExcetoApenasGw({
                                        width: '170px'
                                    });

                                    jQuery('.cobre-tudo').click(function () {
                                        var container = jQuery('.container-salvar-filtros');
                                        if (jQuery('.container-salvar-filtros').css('display') == 'block') {
                                            jQuery('.cobre-tudo').hide('low');
                                            //Alterando cor
                                            jQuery('.div-lb-filtros').css('background', 'rgba(12,37,62,0.4)');

                                            container.animate({
                                                'width': '0px'
                                            }, 200, function () {
                                                container.hide();
                                                container.animate({
                                                    'height': '0px'
                                                }, 1);
                                            });
                                        }

                                    });

                                    var iframe = document.getElementById('iframeSalvarFiltros');
                                    srcSalvarFiltroOriginal = iframe.src;
                                });

                                var srcSalvarFiltroOriginal = null;
                                var objCompleto;

                                function alerarFiltroPesquisa() {
                                    var iframe = document.getElementById('iframeSalvarFiltros');

                                    if (jQuery('#select-pesquisa').val() == 0) {
                                        iframe.src = srcSalvarFiltroOriginal;
                                    } else {
                                        iframe.src = srcSalvarFiltroOriginal + '?nomePesquisa=' + jQuery('#select-pesquisa').val() + '&isPrivada=' + true;
                                    }

                                    jQuery('.cobre-tudo').css('display', 'block');
                                    jQuery('.cobre-tudo').css('background', 'rgba(100, 100, 100, 0.4)');
                                    jQuery('.div-lb-filtros').css('z-index', '99');


                                    setTimeout(function () {
                                        jQuery.ajax({
                                            url: 'ConsultaControlador',
                                            type: 'POST',
                                            async: false,
                                            data: {
                                                acao: 'alterarFiltroPesquisa',
                                                nomeFiltro: jQuery('#select-pesquisa').val(),
                                                codigoTela: codigo_tela
                                            },
                                            success: function (data, textStatus, jqXHR) {
                                                jQuery('#createdMe').prop('checked', false);
                                                removerValorInput('inpSelectVal');
                                                removerValorInput('inptCidade');
                                                jQuery('#filtros-adicionais-container').hide();

                                                objCompleto = jQuery.parseJSON(jQuery.parseJSON(data));

                                                var ordenarPor = objCompleto.ordenacao.trim().split(" ")[0];
                                                var tipoOrd = objCompleto.ordenacao.trim().split(" ")[1];

                                                var limiteResultados = objCompleto.limiteResultado;
                                                var operador = objCompleto.operador1;

                                                //seta o id da preferencia na variavel, (usada para update)
                                                idPreferencia = objCompleto.idPreferencia;

                                                //Operador
                                                jQuery('#select-oper option[value=' + operador + ']').prop('selected', true);
                                                jQuery("#select-oper").selectmenu("refresh");

                                                //Limite
                                                jQuery('#select-limite option[value=' + limiteResultados + ']').prop('selected', true);
                                                jQuery("#select-limite").selectmenu("refresh");


                                                //Ordenar por e se é rescente ou nao
                                                //------------------------------------------------------------------------------------------
                                                jQuery('#select-ordenacao option[value=' + ordenarPor + ']').prop('selected', true);
                                                jQuery("#select-ordenacao").selectmenu("refresh");

                                                jQuery('#select-order-tipo option[value=' + tipoOrd + ']').prop('selected', true);
                                                jQuery("#select-order-tipo").selectmenu("refresh");
                                                //------------------------------------------------------------------------------------------

                                                if (objCompleto.valor21 == 'null') {
                                                    jQuery('.container-campos-select').show();
                                                    jQuery('.container-data').hide();

                                                    jQuery("#dataAte").datebox({disabled: true});
                                                    jQuery("#dataDe").datebox({disabled: true});


                                                    jQuery('#select-abrev option[value=' + objCompleto.nome1 + ']').prop('selected', true);
                                                    jQuery("#select-abrev").selectmenu("refresh");


                                                    var valor1 = objCompleto.valor1.replace(/\[+/g, '').replace(/\]+/g, '');
                                                    valor1 = valor1.split(',');

                                                    for (var i = 0; i < valor1.length; i++) {
                                                        addValorAlphaInput('inpSelectVal', valor1[i].trim());
                                                    }

                                                }

                                                if (objCompleto.valor1 != null && objCompleto.valor1 != undefined && objCompleto.valor21 != 'null') {
                                                    jQuery('#select-abrev option[value=' + objCompleto.nome1 + ']').prop('selected', true);
                                                    jQuery("#select-abrev").selectmenu("refresh");

                                                    jQuery('.container-campos-select').hide();
                                                    jQuery('.container-data').show();
                                                    jQuery("#dataAte").datebox({disabled: false});
                                                    jQuery("#dataDe").datebox({disabled: false});

                                                    jQuery('#dataAte').datebox('setValue', objCompleto.valor21);
                                                    jQuery('#dataDe').datebox('setValue', objCompleto.valor1);

                                                    jQuery('.datebox').css('width', '93%');
                                                    jQuery('.textbox-text').css('width', '93%');
                                                    jQuery('.textbox-text').css('font-size', '14px');
                                                }


                                                if (objCompleto.nomeCreatedMe != null && objCompleto.nomeCreatedMe != undefined) {
                                                    jQuery('#createdMe').prop('checked', true);
                                                    jQuery('#filtros-adicionais-container').show();
                                                }

                                                if (objCompleto.nomeCidade != null && objCompleto.nomeCidade != undefined) {
                                                    var cidades = objCompleto.valorCidade.replace(/\[+/g, '').replace(/\]+/g, '');
                                                    cidades = cidades.split(',');

                                                    for (var i = 0; i < cidades.length; i++) {
                                                        addValorAlphaInput('inptCidade', cidades[i]);
                                                    }
                                                    jQuery('#filtros-adicionais-container').show();
                                                }

                                            },
                                            error: function (jqXHR, textStatus, errorThrown) {
                                                chamarAlert('Ocorreu um erro ao tentar carregar o filtro escolhido.');
                                            },
                                            complete: function (jqXHR, textStatus) {
                                                jQuery('#search').trigger('click');
                                            }

                                        });

                                    }, 500);
                                }

                                function salvarPesquisa() {
                                    if (iframeSalvarFiltros.document.getElementById('nomePesquisa').value.trim() === '') {
                                        chamarAlert('Insira um nome para pesquisa', iframeSalvarFiltros.habilitarBotaoSalvar);
                                    } else {
                                        var nomePesquisa = iframeSalvarFiltros.document.getElementById('nomePesquisa').value;
                                        var nomePesquisaOriginal = iframeSalvarFiltros.document.getElementById('nomePesquisaOriginal').value;
                                        var aoSalvar = iframeSalvarFiltros.jQuery("input[name='aoSalvar']:checked").val();
                                        var isPrivado = (iframeSalvarFiltros.jQuery('input[name=options]:checked').val() == 1 ? true : false);

                                        jQuery.ajax({
                                            url: 'ConsultaControlador?acao=cadPrefUsuPersonalizada&nomePesquisa=' + nomePesquisa + "&isPrivado=" + isPrivado + '&aoSalvar=' + aoSalvar + '&idPreferencia=' + idPreferencia + '&cod_tela=1&nomePesquisaOriginal=' + nomePesquisaOriginal,
                                            type: 'POST',
                                            async: false,
                                            data: jQuery('form').serialize(),
                                            datatype: 'json',
                                            success: function (data, textStatus, jqXHR) {
                                                if (data.length > 0) {


                                                    var error = jQuery.parseJSON(jQuery.parseJSON(data));

                                                    if (error.erro != null && error.erro != undefined) {
                                                        chamarAlert(error.erro);
                                                        return false;
                                                    }

                                                }

                                                chamarAlert("Pesquisa salva com sucesso.");
                                                jQuery(iframeSalvarFiltros.document.getElementById('nomePesquisa')).val('');
                                                cancelarSalvarPesquisa();
                                            },
                                            error: function (jqXHR, textStatus, errorThrown) {
                                                chamarAlert("Ocorreu um erro ao tentar salvar a pesquisa.");
                                                cancelarSalvarPesquisa();
                                            }
                                        });

                                    }
                                }

                                function cancelarSalvarPesquisa() {
                                    var container = jQuery('.container-salvar-filtros');
                                    jQuery('.cobre-tudo').hide('low');
                                    //Alterando cor
                                    jQuery('.div-lb-filtros').css('background', 'rgba(12,37,62,0.4)');

                                    container.animate({
                                        'width': '0px'
                                    }, 200, function () {
                                        container.hide();
                                        container.animate({
                                            'height': '0px'
                                        }, 1);
                                    });
                                }

                                (function (i, s, o, g, r, a, m) {
                                    i['GoogleAnalyticsObject'] = r;
                                    i[r] = i[r] || function () {
                                        (i[r].q = i[r].q || []).push(arguments)
                                    }, i[r].l = 1 * new Date();
                                    a = s.createElement(o),
                                            m = s.getElementsByTagName(o)[0];
                                    a.async = 1;
                                    a.src = g;
                                    m.parentNode.insertBefore(a, m)
                                })(window, document, 'script', 'https://www.google-analytics.com/analytics.js', 'ga');
                                ga('create', 'UA-86105277-1', 'auto');
                                ga('send', 'pageview');

                                setTimeout(function () {
                                    jQuery('.container-salvar-filtros').html('<iframe id="iframeSalvarFiltros" name="iframeSalvarFiltros" src="${homePath}/gwTrans/consultas/salvar_filtros.jsp?tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe><span class="seta-baixo"></span>');
                                    document.getElementById('progress-preferencias').value = 100;
                                    document.getElementById('progress-porcentagem').innerHTML = '100%';
                                    jQuery('.load-preferencias').hide();
                                }, 1000);


        </script>
        <script src="${homePath}/assets/js/jquery.easyui.min.js"></script>
    </body>
</html>