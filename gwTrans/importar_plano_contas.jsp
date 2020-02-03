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
<c:if test="${nivelUser == null || nivelUser < 3}">
    <c:redirect url="/401"/>
</c:if>
<head>
    <title>GW Sistemas - Importação de plano de contas</title>
    <meta charset="ISO-8859-1">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <%-- Scripts --%>
    <script src="${homePath}/script/jQuery/jquery.js?v=${random.nextInt()}"></script>
    <script src="${homePath}/assets/alerts/alerts-min.js?v=${random.nextInt()}"></script>
    <script src="${homePath}/script/validarSessao.js?v=${random.nextInt()}"></script>
    <script src="${homePath}/script/shortcut.js?v=${random.nextInt()}"></script>
    <script defer src="${homePath}/assets/js/jquery-ui.min.js?v=${random.nextInt()}"></script>
    <script defer src="${homePath}/assets/js/jquery.mask.min.js?v=${random.nextInt()}"></script>
    <script defer src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}"></script>
    <script defer src="${homePath}/assets/js/importar-plano-contas.js?v=${random.nextInt()}"></script>

    <jsp:include page="/importAlerts.jsp">
        <jsp:param name="caminhoImg" value="assets/img/gw-trans.png"/>
        <jsp:param name="nomeUsuario" value="${user.nome}"/>
    </jsp:include>

    <%-- CSS --%>
    <link href="${homePath}/assets/css/font-roboto.css?v=${random.nextInt()}" rel="stylesheet">
    <link href="${homePath}/assets/css/jquery-ui-min.css?v=${random.nextInt()}" rel="stylesheet">
    <link href="${homePath}/assets/css/easyui.css?v=${random.nextInt()}" rel="stylesheet">
    <link href="${homePath}/assets/css/bootstrap-custom-col.css?v=${random.nextInt()}" rel="stylesheet">
    <link href="${homePath}/gwTrans/cadastros/css/cadastro.css?v=${random.nextInt()}" rel="stylesheet">
    <link href="${homePath}/css/style-grid-default.css?v=${random.nextInt()}" rel="stylesheet">
    <link href="${homePath}/assets/css/importar-plano-contas.css?v=${random.nextInt()}" rel="stylesheet">
    <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css" rel="stylesheet">
    <script>
        var homePath = '${homePath}';
        var codigoTela = 'T00133';
    </script>
</head>
<body>
<header class="header">
    <div class="cont-id-page">
        <div class="col-md-9">
            <label class="lb-name-page">Importar Plano de Contas</label>
        </div>
        <img src="${homePath}/assets/img/trans_white.png" alt="" class="img-logo-mod"/>
    </div>
    <span class="bt bt-voltar">Voltar</span>
</header>
<aside class="aside-col-left" col-ajuda="active">
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
</aside>
<section class="section-bt-aba">
    <button class="btn-aba btn-aba-ajuda">Exibir Ajuda</button>
</section>
<section class="section-geral">
    <div style="float: left;width: 100%;height: 100%;" id="formCadastro">
        <div class="container-form">
            <div class="container-campos">
                <div class="col-md-3">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Layout</div>
                    </div>

                    <select id="layout_plano_contas" name="layout_plano_contas" data-ajuda="layout_ajuda">
                        <c:forEach items="${layouts_plano_contas}" var="layout_plano_contas">
                            <option value="${layout_plano_contas.codigo}" ${layout_plano_contas.codigo eq 2 ? "selected" : ""}>${layout_plano_contas.descricao}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-3" style="height: 62px;">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Selecionar Arquivo</div>
                    </div>

                    <div class="container-input-file-layout ativa-helper-data-ajuda" data-ajuda="arquivo_ajuda">
                        <input type="file" id="arquivo_ocoren" class="input-file-layout">
                        <label for="arquivo_ocoren" class="btn btn-tertiary js-labelFile">
                            <i class="icon fa fa-check"></i>
                            <span class="js-fileName">Selecionar Arquivo</span>
                        </label>
                        <input type="hidden" name="arquivo_ocoren" id="arquivo_ocorenHidden">
                        <input type="hidden" name="nome_arquivo_ocoren" id="nome_arquivo_ocoren">
                    </div>
                </div>
                <div class="col-md-2">
                    <button class="bt-salvar" id="importar_edi" data-label="Visualizar">Visualizar</button>
                </div>
            </div>
            <div class="container-campos">
                <div id="container-dom-ocorrencias">
                    <table cellspacing="0" class="tabela-gwsistemas" id="tabela-gwsistemas">
                        <thead>
                        <tr>
                            <th width="3%"><input type="checkbox" id="marcar-todos" checked></th>
                            <th width="10%">Código</th>
                            <th width="10%">Conta</th>
                            <th width="77%">Descrição</th>
                        </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="container-campos qtd_ocorrencias">
                <label><strong>Qtd planos de contas: </strong><span id="qtd_ocorrencias">0</span></label>
            </div>
        </div>
    </div>
</section>
<section class="section-bt">
    <div class="container-bt">
        <button data-label="Salvar [F8]" id="bt-salvar" class="bt-salvar" style="margin-top: 20px">Salvar [F8]</button>
    </div>
</section>
<div class="cobre-tudo"></div>
<%-- Variáveis para o JavaScript --%>
<input type="hidden" id="layout_ajuda" name="layout_ajuda">
<input type="hidden" id="arquivo_ajuda" name="arquivo_ajuda">
</body>
</html>
