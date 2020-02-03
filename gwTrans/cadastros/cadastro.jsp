<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="/WEB-INF/tld/custonTagLibrary.tld" prefix="cg" %>
<jsp:useBean id="random" class="java.util.Random" scope="application" />
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
    <head>
        <title>GW Sistemas - Cadastro</title>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <script src="${homePath}/script/jQuery/jquery.js" type="text/javascript"></script>
        <script src="${homePath}/assets/alerts/alerts-min.js" type="text/javascript"></script>
        <jsp:include page="/importAlerts.jsp">
            <jsp:param name="caminhoImg" value="assets/img/gw-trans.png"/>
            <jsp:param name="nomeUsuario" value="${user.nome}"/>
        </jsp:include>
        <script>
            var homePath = '${homePath}';
        </script>
        <link rel="stylesheet" href="${homePath}/assets/css/font-roboto.css?v=${random.nextInt()}">
        <link href="${homePath}/assets/css/inputs-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/jquery-ui-min.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/gwTrans/cadastros/css/cadastro.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/gwTrans/cadastros/css/estilo-input-form-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/gwTrans/cadastros/css/bootstrap-custom-col.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/gwTrans/cadastros/css/layout-dom/dom-tde.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/easyui.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
    </head>
    <body>
        <header class="header">
            <div class="cont-id-page">
                <div class="col-md-9">
                    <label class="lb-name-page"></label>
                </div>
                <img src="${homePath}/gwTrans/cadastros/img/trans_white.png" alt="" class="img-logo-mod"/>
            </div>
            <span class="bt bt-voltar">Voltar para consulta</span>
        </header>
        <aside class="aside-col-left" col-ajuda="active" style="display: none;">
            <div class="item_form" style="margin-bottom: 5px;margin-top: 30px;">
                <div class="helper">
                    <div class="corpo_helper">
                        <label class="campo-helper"><h2>Ajuda</h2></label>
                        <hr>
                        <label class="descri-helper"><h3>Passe o mouse sobre o campo que deseja ajuda.</h3></label>
                    </div>
                </div>
            </div>
            <div class="item_form">
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
                <div class="item_form"  style="margin-bottom: 0px;margin-top: 0px;">
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
            </c:if>
        </aside>
        <aside class="aside-col-left" col-auditoria="no-active" style="display: none;">
            <h1 class="title-auditoria">Auditoria</h1>
            <div class="container-auditoria">
                <table class="tb-auditoria" cellspacing="0">
                    <thead>
                        <tr>
                            <th>Usuário</th>
                            <th>Data</th>
                            <th>Ação</th>
                            <th>Ip</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                    <tfoot>
                        <tr>
                            <td colspan="4">&nbsp;</td>
                        </tr>
                    </tfoot>
                </table>
            </div>
            <div class="container-bt-auditoria">
                <table class="incluso-por" cellspacing="0">
                    <tr>
                        <td style="width: 10%; display: none;" class="incluso_td">Incluso:</td>
                        <td style="text-align: left; display: none;" class="incluso_td">
                            <div>
                                <label>em: </label><label id="inclusoEm"></label>
                            </div>
                            <div>
                                <label>por: </label><label id="inclusoPor"></label>
                            </div>
                        </td>
                        <td style="width: 10%; display: none;" class="alterado_td">Alterado:</td>
                        <td style="text-align: left; display: none;" class="alterado_td">
                            <div>
                                <label>em: </label><label id="atualizadoEm"></label>
                            </div>
                            <div>
                                <label>por: </label><label id="atualizadoPor"></label>
                            </div>
                        </td>
                    </tr>
                </table>
            </div>
            <div class="container-bt-auditoria">
                <div style="width: 125px;margin-top:20px;margin-left:calc(50% - 165px);margin-right: 30px;float: left;">
                    <span class="container-input-form-gw input-width-100">
                        <input class="input-form-gw input-width-100 ativa-helper" id="dataDe" type="text" value="${dataAtual}" data-input-data-auditoria="">
                    </span>
                </div>
                <label class="lb-ate">até</label>
                <div style="width: 125px;margin-top:20px;margin-left:10px;float: left;">
                    <span class="container-input-form-gw input-width-100">
                        <input class="input-form-gw input-width-100 ativa-helper" id="dataAte" type="text" value="${dataAtual}" data-input-data-auditoria>
                        <!--<input class="input-dom-gw input-width-100" id="origem" type="text" data />-->
                    </span>
                </div>
                <button data-label="Pesquisar" class="bt-pesquisar" style="margin-top: 15px;margin-left: calc(50% - 62px);">Pesquisar</button>
            </div>
        </aside>
        <section class="section-bt-aba">
            <button class="btn-aba btn-aba-ajuda">Exibir Ajuda</button>
            <button class="btn-aba btn-aba-auditoria">Exibir Auditoria</button>
        </section>

        <section class="section-geral">
            <div style="float: left;width: 100%;height: 100%;" id="formCadastro">
                <jsp:include page="${urlBody}" flush="true" />
            </div>
        </section>
        <section class="section-bt">
            <c:if test="${pode_salvar == null or pode_salvar}">
                <div class="container-bt">
                    <section class="section-check">
                        <input id="chk-ao-salvar" type="checkbox" class="chk-save" />
                        <label for="chk-ao-salvar">
                            <span></span>
                            Ao salvar continuar incluindo.
                            <ins><i>Ao salvar continuar incluindo.</i></ins>
                        </label>
                    </section>
                    <button data-label="Salvar [F8]" class="bt-salvar">Salvar [F8]</button>
                </div>
            </c:if>
            <!--<img src="img/clear-page.png" alt="Limpar Página" class="limpar-pagina"/>-->
        </section>
        <div class="cobre-tudo"></div>
        <div class="detalhes-auditoria">
            <div class="detalhes-auditoria-topo">Auditoria - Detalhes<img src="${homePath}/assets/img/sair.png" onclick="fecharAuditoria()"></div>
            <div class="detalhes-auditoria-corpo">
                <table class="tb-auditoria-detalhes">
                    <thead>
                        <tr>
                            <th>Campos</th>
                            <th>Antes</th>
                            <th>Depois</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Teste</td>
                            <td>123</td>
                            <td>321</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
        <script defer src="${homePath}/script/validarSessao.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script defer src="${homePath}/script/shortcut.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/assets/js/jquery-ui.min.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/assets/js/jquery.mask.min.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/script/shortcut.js?v=${random.nextInt()}" type="text/javascript"></script>
        <!-- Ordem de import (jQuery e config) nao pode mudar -->
        <script src="${homePath}/gwTrans/cadastros/js/config-tela-cadastro.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/gwTrans/cadastros/js/input-form-gw.js?v=${random.nextInt()}" type="text/javascript"></script>
        <!-- Ordem de import (jQuery e config) nao pode mudar -->
        <script src="${homePath}/gwTrans/cadastros/js/mapeamento-cadastros.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script defer src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/gwTrans/cadastros/js/prepare-form.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/gwTrans/cadastros/js/underscore-min.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script>
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
    </body>
</html>
