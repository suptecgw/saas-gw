<%-- 
    Document   : consulta-fornecedor
    Created on : 05/12/2016, 10:12:49
    Author     : Mateus
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="/WEB-INF/tld/custonTagLibrary.tld" prefix="cg" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-9">
        <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${tema}.css?v=${random.nextInt()}">
        <script src="${homePath}/script/jQuery/jquery.js" type="text/javascript"></script>
        <script src="${homePath}/assets/alerts/alerts-min.js" type="text/javascript"></script>
        <jsp:include page="/importAlerts.jsp">
            <jsp:param name="caminhoImg" value="assets/img/gw-trans.png"/>
            <jsp:param name="nomeUsuario" value="${user.nome}"/>
        </jsp:include>
        <meta charset="ISO-8859-1">
        <meta name="viewport" content="width=device-width">
        <title>GW Trans - Consulta de Fornecedores</title>
        <link href="${homePath}/assets/css/jquery-ui-min.css" rel="stylesheet" type="text/css"/>
        <link href="assets/css/bootstrap-custom-col.css" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="${homePath}/assets/css/easyui.css">
        <link rel="stylesheet" href="${homePath}/assets/css/consulta.css?v=${random.nextInt()}">	
        <link href="${homePath}/assets/css/inputs-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="${homePath}/assets/css/font-roboto.css">	
        <script src="${homePath}/assets/js/coluna_ajuda_filtros.js?v=${random.nextInt()}"></script>
        <link src="${homePath}/gwTrans/consultas/css/consulta-fornecedor.css?v=${random.nextInt()}" type="text/css" />
        <link href="${homePath}/assets/css/select-multiplo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <script defer src="${homePath}/script/validarSessao.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script defer>
            var codigoTela = 'T00014';
            var codigo_tela = '14';
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
                <!--<p>Carregando prefer�ncias</p>-->
            </div>
        </div>
        <img class="gif-bloq-tela-left" src="${homePath}/img/espere_new.gif" alt=""/>
        <div class="container-salvar-filtros">
            <iframe id="iframeSalvarFiltros" name="iframeSalvarFiltros" src="${homePath}/gwTrans/consultas/salvar_filtros.jsp" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
            <span class="seta-baixo"></span>
        </div>
        <div id="topo">
            <div id="logo">
                <h3>Consulta de Fornecedores<img src="${homePath}/assets/img/trans_white.png"></h3>
            </div>
            <div id="actions">
                <img id="logoCliente" width="68px" height="44px" src="">
                <ul>
                    <li>
                        <c:if test="${nivelUser >= 3}">
                            <div class="bt bt-cadastro"  onclick="javascript:checkSession(function(){cadastrarFornecedor();},false);">Novo cadastro</div>
                        </c:if>
                    </li>

                    <li>
                        <div class="bt bt-relatorio"  onclick="javascript:checkSession(function(){relatorioFornecedor();},false);">Relat�rio</div>
                    </li>
                </ul>
                <!--<a href="javascript:;"><img src="${homePath}/assets/img/icon-question.png" class="right question"></a>-->
            </div>
        </div>
        <div class="localiza">
        </div>
        <div class="localiza">
        </div>
        <div class="cobre-tudo"></div>
        <div id="sidebar" class="heightDoc">
            <style>
                /*.columnLeft::-webkit-scrollbar{display: none;-ms-overflow-style: none;overflow: auto;}*/
                /*.columnLeft{-ms-overflow-style: none;};*/
            </style>
            <div class="columnLeft" id="columnLeft" style="z-index: 999;position: absolute;width: 25%;display: block;">
                <div class="cobre-left" style="width: 100%;height: 100%;background: #000;z-index: 999999999;position: absolute;display: none;"></div>
                <div class="content">
                    <form action="ConsultaControlador?codTela=14" method="POST" id="formConsulta" name="formConsulta">
                        <div class="item_form">
                            <label style="padding-bottom: 5px !important;">Pesquisas salvas dispon�veis</label>
                            <select class="input" id="select-pesquisa" name="select-pesquisa" onchange="">
                                <option value="0">Ultima pesquisa realizada</option>
                                <c:forEach var="listPrefPerso" items="${listaPreferenciasPersonalizadas}" varStatus="filtrosStatus" >
                                    <option value="${listPrefPerso}">${listPrefPerso}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="item_form" style="">
                            <label>Filtro</label>
                            <select class="input" id="select-abrev" name="select-abrev" onchange="">
                                <c:forEach var="columnFiltroSelect" items="${tela.targetXml.columnFiltroSelect}" varStatus="rowStatus" >
                                    <option value="${columnFiltroSelect.name}">${columnFiltroSelect.label}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="item_form" style="">
                            <select class="input" id="select-oper" name="select-oper" onchange="">
                                <option value="1" >Todas as partes com</option>
                                <option value="3">Apenas com o in�cio</option>
                                <option value="2">Apenas com o fim</option>
                                <option value="4">Igual � palavra/frase</option>
                            </select>
                        </div>
                        <div class="item_form container-campos-select" style="">
                            <input type="text" id="inpSelectVal" name="inpSelectVal" data-pesquisar-id="#search">
                            <!--Necessario para que ele n�o de subimit sozinho com apenas um input text : Mateus--> 
                            <input type="text" id="t" style="display: none;">
                        </div>

                        <div class="item_form container-data" style="">
                            <div class="item_form_half1">
                                <input class="easyui-datebox" id="dataDe" name="dataDe" value="${dataAtual}" style="width:100%;height:32px">
                            </div>
                            <div class="item_form_half2">
                                <input class="easyui-datebox" id="dataAte" name="dataAte" value="${dataAtual}" style="width:100%;height:32px">
                            </div>
                        </div>

                        <div class="item_form" style="">
                            <label>Ordena��o dos resultados</label>
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
                        </div>
                        <div class="item_form" style="">
                            <select class="input" name="select-limite" id="select-limite" onchange="">
                                <option value="10">Exibir 10 resultados por p�gina</option>
                                <option value="20">Exibir 20 resultados por p�gina</option>
                                <option value="30">Exibir 30 resultados por p�gina</option>
                                <option value="40">Exibir 40 resultados por p�gina</option>
                                <option value="50">Exibir 50 resultados por p�gina</option>
                            </select>
                        </div>
                        <div id="filtros-adicionais-container" style="display: none;">
                            <div class="item_form" style="margin-bottom: 10px;">
                                <label for="createdMe">
                                    <input type="checkbox" name="createdMe" id="createdMe">
                                    Criados por mim
                                </label>
                            </div>
                            <div class="item_form" style="margin-bottom: 5px;">
                                <label style="margin-left: 5px;">Mostrar Fornecedores</label>
                                <label for="ambosAtv" class="radio" style=""><input type="radio" name="mostrarFornecedoresAtv" value="0" id="ambosAtv" checked> Ambos</label>
                                <label for="ativos" class="radio" style=""><input type="radio" name="mostrarFornecedoresAtv" value="ativos" id="ativos"> Ativos</label>
                                <label for="inativos" class="radio" style=""><input type="radio" name="mostrarFornecedoresAtv" value="inativos" id="inativos"> Inativos</label>
                            </div>


                            <div class="item_form" style="">
                                <select id="select-exceto-apenas-cidade" name="select-exceto-apenas-cidade">
                                    <option value="apenas">Apenas as Cidades</option>
                                    <option value="exceto">Exceto as Cidades</option>
                                </select>
                                <div style="width: 70%;float: left;">
                                    <input class="input" type="text" id="inptCidade" name="inptCidade" readonly="true" placeholder="">
                                </div>
                                <div class="btns">
                                    <a href="javascript:" onclick="checkSession(function () {
                                                removerValorInput('inptCidade', true);
                                            }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                                    <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarCidade');},false);" class="btnMore"></a>
                                    <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                                </div>
                            </div>

                            <div class="item_form" style="">
                                <select id="select-exceto-apenas-grupo-fornecedor" name="select-exceto-apenas-grupo-fornecedor">
                                    <option value="apenas">Apenas os Grupos</option>
                                    <option value="exceto">Exceto os Grupos</option>
                                </select>
                                <div style="width: 70%;float: left;">
                                    <input class="input" type="text" id="inptGrupoFornecedor" name="inptGrupoFornecedor" readonly="true" placeholder="">
                                </div>
                                <div class="btns">
                                    <a href="javascript:" onclick="checkSession(function () {
                                                removerValorInput('inptGrupoFornecedor', true);
                                            }, false);" class="btnDelete" style="margin-top: 2px;"></a>
                                    <a href="javascript:checkSession(function(){controlador.acao('abrirLocalizar','localizarGrupoCliente');},false);" class="btnMore"></a>
                                </div>
                            </div>
                            <script>
                                jQuery(document).ready(function () {
                                    jQuery('#select-tipo-fornecedor').selectMultiploGw({
                                        'titulo': 'Apenas os Tipos'
                                    });
                                });
                            </script>
                            <div class="item_form" style="margin-bottom: 50px;margin-top: 10px;">
                                <select id="select-exceto-apenas-tipo-fornecedor" name="select-exceto-apenas-tipo-fornecedor">
                                    <option value="apenas">Apenas os Tipos</option>
                                    <option value="exceto">Exceto os Tipos</option>
                                </select>
                                <select id="select-tipo-fornecedor" name="select-tipo-fornecedor">
                                    <option value="is_ajudante">Ajudante</option>
                                    <option value="is_vendedor">Vendedor</option>
                                    <option value="is_agente_pagador">Agente pagador</option>
                                    <option value="is_seguradora">Seguradora</option>
                                    <option value="is_companhia_aerea">Companhia A�rea</option>
                                    <option value="is_fornecedor_combustivel">Fornecedor de Combust�vel</option>
                                    <option value="is_agente_carga">Agente de carga</option>
                                    <option value="is_proprietario">Propriet�rio</option>
                                    <option value="is_redespachante">Redespachante</option>
                                    <option value="is_gerenciador_risco">Gerenciador de risco</option>
                                </select>
                            </div>

                        </div>

                        <div class="item_form" id="filtros-adicionais">
                            <span class="seta-exibir-filtros-adicionais"></span>
                            <a href="javascript:;" id="toogle_options_details">Exibir filtros adicionais</a>
                        </div>
                    </form>
                    <div class="centerContent" style="">
                        <input type="button" value="Pesquisar" class="searchButton" id="search" onclick="checkSession(function () {
                                        consultaFornecedor();
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
                    <span>Notifica��o</span>
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
                                <h3 class="h3-permissoes" style="">Permiss�es de acesso desta tela</h3>
                                <hr style="margin:5px;padding:0;">
                                <div class="col-md-12">
                                    <table class="table_permissao" cellspacing="0">
                                        <thead>
                                            <tr>
                                                <th width="10%">C�digo</th>
                                                <th width="40%">Descri��o</th>
                                                <th width="40%">Observa��o</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <c:if test="${fn:length(listVideosTela) > 0}">
                            <center class="div-lb-videos-ajuda"><h3 class="h3-video" style="">V�deos de  Ajuda</h3></center>
                            <hr style="margin:5px;padding:0;">
                            <div class="item_form"  style="margin-bottom: 0px;">
                                <style>

                                </style>
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
            <input type="hidden" name="inp-auditoria" data-exclusao="true" data-rotina-auditoria="fornecedor">
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
                        <button id="removeCte" class="removeCteOff" disabled="true" onclick="checkSession(function () {
                                    excluir();
                                }, false);"><img src="${homePath}/assets/img/icon-remove-off.png">Excluir selecionados</button>
                    </div>
                </div>
            </div>
        </div>
        <img class="gif-bloq-tela" src="${homePath}/img/espere_new.gif" alt=""/>
        <div class="bloqueio-tela"></div>

        <script src="${homePath}/assets/js/jquery-ui.min.js" type="text/javascript"></script>
        <script defer src="${homePath}/script/shortcut.js" type="text/javascript"></script>
        <script defer src="${homePath}/assets/js/jquery.mask.min.js"></script>
        <script defer src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/script/funcoesTelaConsulta.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script defer src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script defer type='text/javascript' lang="JavaScript">
                            
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
                                jQuery("#logoCliente").attr("src", "assets/img/gw-sistemas.png");
                            }

                            jQuery(document).ready(function () {


                                jQuery('#inptGrupoFornecedor').inputMultiploGw({
                                    width: '96%',
                                    readOnly: 'true'
                                });

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
                                gerenciarInpGrupo('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.descricao}', '${filtros.colunaCondicaoLocalizar}');
                                gerenciarCheckBox('${filtros.colunaNome}', '${filtros.colunaValor}');
                                gerenciarRadioAtivo('${filtros.colunaNome}', '${filtros.colunaValor}');
                                gerenciarTipoFornecedor('${filtros.colunaNome}', '${filtros.colunaValor}', '${filtros.colunaCondicaoLocalizar}', '${filtros.descricao}');
                                //                                addValorAlphaInput('inpSelectVal', '${filtros.colunaValor}');

                </c:forEach>
            </c:if>

            <c:if test="${filtroEscolhido != null}">
                                jQuery('#select-pesquisa').val('${filtroEscolhido}').change();
                                jQuery("#select-pesquisa").selectmenu("refresh");
            </c:if>

                                jQuery('#select-exceto-apenas-cidade').selectExcetoApenasGw({
                                    width: '170px'
                                });
                                jQuery('#select-exceto-apenas-grupo-fornecedor').selectExcetoApenasGw({
                                    width: '200px'
                                });

                                jQuery('#select-exceto-apenas-tipo-fornecedor').selectExcetoApenasGw({
                                    width: '170px'
                                });


                                setTimeout(function () {
                                    jQuery('#dataDe').datebox('textbox').bind('focusout', function (e) {
                                        completarData(this, e);
                                    });

                                    jQuery('#dataAte').datebox('textbox').bind('focusout', function (e) {
                                        completarData(this, e);
                                    });
                                }, 1000);

                                setTimeout(function () {
                                    jQuery('.container-salvar-filtros').html('<iframe id="iframeSalvarFiltros" name="iframeSalvarFiltros" src="${homePath}/gwTrans/consultas/salvar_filtros.jsp?tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe><span class="seta-baixo"></span>');
                                    jQuery(jQuery('.localiza')[0]).html('<iframe id="localizarCidade" input="inptCidade" name="localizarCidade" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarCidade&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                                    jQuery(jQuery('.localiza')[1]).html('<iframe id="localizarGrupoCliente" input="inptGrupoFornecedor" name="localizarGrupoCliente" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarGrupoCliente&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
                                }, 1);

                            });

                            function gerenciarInpSelectVal(nome, valor, valor2) {
                                if (jQuery('#select-abrev option[value=' + nome + ']').size() >= 1) {
                                    if (nome == 'incluso_em') {
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
                                    } else if (nome == 'alterado_em') {
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
                                if (nome == 'cidade') {
                                    jQuery('#select-exceto-apenas-cidade option[value="' + condicao + '"]').attr('selected', 'selected');

                                    valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
                                    descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

                                    valor = valor.split(",");
                                    descricao = descricao.split(",");

                                    for (var i = 0; i < valor.length; i++) {
                                        jQuery('#filtros-adicionais-container').show();
                                        addValorAlphaInput('inptCidade', valor[i].trim(), descricao[i].trim());
                                    }
                                }
                            }

                            function gerenciarRadioAtivo(nome, valor) {
                                if (nome == 'fornecedor_ativo') {
                                    if (valor == 'Sim') {
                                        jQuery('#ativos').trigger('click');
                                        jQuery('#filtros-adicionais-container').show();
                                    } else if (valor == 'N�o') {
                                        jQuery('#inativos').trigger('click');
                                        jQuery('#filtros-adicionais-container').show();
                                    } else {
                                        jQuery('#ambosAtv').trigger('click');
                                    }
                                }
                            }

                            function gerenciarCheckBox(nome, valor) {
                                if (nome == 'incluso_por') {
                                    jQuery('#createdMe').prop('checked', true);
                                    jQuery('#filtros-adicionais-container').show();
                                }
                            }

                            function gerenciarInpGrupo(nome, valor, descricao, condicao) {
                                if (nome == 'grupos') {
                                    jQuery('#select-exceto-apenas-grupo-fornecedor option[value="' + condicao + '"]').attr('selected', 'selected');
                                    valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
                                    descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

                                    valor = valor.split(",");
                                    descricao = descricao.split(",");

                                    for (var i = 0; i < valor.length; i++) {
                                        jQuery('#filtros-adicionais-container').show();
                                        addValorAlphaInput('inptGrupoFornecedor', valor[i].trim(), descricao[i].trim());
                                    }
                                }
                            }

                            function gerenciarTipoFornecedor(nome, valor, condicao, descricao) {
                                var valorExiste = jQuery('#tipos-escolhidos').val();
                                var valorExisteId = jQuery('#id-tipos-escolhidos').val();

                                console.log(nome);
                                console.log(descricao);

                                if (nome == "is_ajudante") {
                                    jQuery('.container-select-multiplo-gw-A').find('#is_ajudante').trigger('click');
                                    jQuery('#filtros-adicionais-container').show();
                                    jQuery('#select-exceto-apenas-tipo-fornecedor option[value="' + condicao + '"]').attr('selected', 'selected');
                                } else if (nome == "is_vendedor") {
                                    jQuery('.container-select-multiplo-gw-A').find('#is_vendedor').trigger('click');
                                    jQuery('#filtros-adicionais-container').show();
                                    jQuery('#select-exceto-apenas-tipo-fornecedor option[value="' + condicao + '"]').attr('selected', 'selected');
                                } else if (nome == "is_agente_pagador") {
                                    jQuery('.container-select-multiplo-gw-A').find('#is_agente_pagador').trigger('click');
                                    jQuery('#filtros-adicionais-container').show();
                                    jQuery('#select-exceto-apenas-tipo-fornecedor option[value="' + condicao + '"]').attr('selected', 'selected');
                                } else if (nome == "is_seguradora") {
                                    jQuery('.container-select-multiplo-gw-A').find('#is_seguradora').trigger('click');
                                    jQuery('#filtros-adicionais-container').show();
                                    jQuery('#select-exceto-apenas-tipo-fornecedor option[value="' + condicao + '"]').attr('selected', 'selected');
                                } else if (nome == "is_companhia_aerea") {
                                    jQuery('.container-select-multiplo-gw-A').find('#is_companhia_aerea').trigger('click');
                                    jQuery('#filtros-adicionais-container').show();
                                    jQuery('#select-exceto-apenas-tipo-fornecedor option[value="' + condicao + '"]').attr('selected', 'selected');
                                } else if (nome == "is_fornecedor_combustivel") {
                                    jQuery('.container-select-multiplo-gw-A').find('#is_fornecedor_combustivel').trigger('click');
                                    jQuery('#filtros-adicionais-container').show();
                                    jQuery('#select-exceto-apenas-tipo-fornecedor option[value="' + condicao + '"]').attr('selected', 'selected');
                                } else if (nome == "is_agente_carga") {
                                    jQuery('.container-select-multiplo-gw-A').find('#is_agente_carga').trigger('click');
                                    jQuery('#filtros-adicionais-container').show();
                                    jQuery('#select-exceto-apenas-tipo-fornecedor option[value="' + condicao + '"]').attr('selected', 'selected');
                                } else if (nome == "is_proprietario") {
                                    jQuery('.container-select-multiplo-gw-A').find('#is_proprietario').trigger('click');
                                    jQuery('#filtros-adicionais-container').show();
                                    jQuery('#select-exceto-apenas-tipo-fornecedor option[value="' + condicao + '"]').attr('selected', 'selected');
                                } else if (nome == "is_redespachante") {
                                    jQuery('.container-select-multiplo-gw-A').find('#is_redespachante').trigger('click');
                                    jQuery('#filtros-adicionais-container').show();
                                    jQuery('#select-exceto-apenas-tipo-fornecedor option[value="' + condicao + '"]').attr('selected', 'selected');
                                } else if (nome == "is_gerenciador_risco") {
                                    jQuery('.container-select-multiplo-gw-A').find('#is_gerenciador_risco').trigger('click');
                                    jQuery('#filtros-adicionais-container').show();
                                    jQuery('#select-exceto-apenas-tipo-fornecedor option[value="' + condicao + '"]').attr('selected', 'selected');
                                }
                                jQuery('.container-li-valores').hide();
                            }


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


                            function controleLocalizarGrupoCliente(acao, parametros, apagarDadosInput) {
                                if (acao === 'fechar') {
                                    jQuery('.localizaGrupo').hide('show');
                                    jQuery('.cobre-tudo').hide('show');
                                    localizarGrupoFornecedor.voltarTodosItens();
                                    //Restaura o z-index do salvarPesquisaContainer para ele aparecer
                                    jQuery('.salvarPesquisaContainer').css('z-index', '999999');
                                } else if (acao === 'finalizado') {
                                    controleLocalizarGrupoCliente('fechar', null);
                                    if (apagarDadosInput === true) {
                                        removerValorInput('inptGrupoFornecedor');
                                    }
                                    addValorAlphaInput('inptGrupoFornecedor', parametros);
                                    localizarGrupoFornecedor.voltarTodosItens();
                                } else if (acao === 'mensagem') {
                                    chamarAlert(parametros, null);
                                    localizarGrupoFornecedor.voltarTodosItens();
                                }
                            }

                            setTimeout(function () {
                                document.getElementById('progress-preferencias').value = 100;
                                document.getElementById('progress-porcentagem').innerHTML = '100%';
                                jQuery('.load-preferencias').hide();
                            }, 1000);
                            
     <c:if test="${utilizacaoGwMobile ne  'N'}">
            var menuAtivarMobile = {
                nome: "Cadastrar/Ativar no GW Mobile",
                src: "${homePath}/img/smartphone.png",
                acao: "sincronizarGwMobile(this, 'a')"
            };
            addItemMenuGrid(menuAtivarMobile);
            
            var menuDesativarMobile = {
                nome: "Desativar no GW Mobile",
                src: "${homePath}/img/smartphone.png",
                acao: "sincronizarGwMobile(this, 'd')"
            };
            addItemMenuGrid(menuDesativarMobile);
                        </c:if>
            
        </script>
        <script src="${homePath}/gwTrans/consultas/js/consulta-fornecedor.js?v=${random.nextInt()}"></script>
        <script defer src="${homePath}/assets/js/jquery.easyui.min.js"></script>
    </body>
</html>
