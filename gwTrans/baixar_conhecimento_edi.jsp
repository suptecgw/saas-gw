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
<c:if test="${nivelUser == null || nivelUser < 4}">
    <c:redirect url="/401"/>
</c:if>
<head>
    <title>GW Sistemas - Baixar CT-e por Arquivo EDI</title>
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
    <script defer src="${homePath}/assets/js/baixar-conhecimento-edi.js?v=${random.nextInt()}"></script>

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
    <link href="${homePath}/assets/css/baixar-conhecimento-edi.css?v=${random.nextInt()}" rel="stylesheet">
    <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css" rel="stylesheet">
    <script>
        var homePath = '${homePath}';
        var codigoTela = 'T00088';
    </script>
</head>
<body>
<header class="header">
    <div class="cont-id-page">
        <div class="col-md-9">
            <label class="lb-name-page">Baixar CT-e por Arquivo EDI</label>
        </div>
        <img src="${homePath}/assets/img/trans_white.png" alt="" class="img-logo-mod"/>
    </div>
    <span class="bt bt-voltar">Fechar</span>
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
                        <div class="label-campo-identificacao">Layout OCOREN</div>
                    </div>

                    <select id="layout_ocoren" name="layout_ocoren" data-ajuda="importar_edi_ajuda">
                        <option value="0" selected>Selecione</option>
                        <c:forEach items="${layouts_ocoren}" var="layout_ocoren">
                            <option value="${layout_ocoren.codigo}">${layout_ocoren.descricao}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-3">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Escolha o arquivo</div>
                    </div>

                    <div class="container-input-file-layout ativa-helper-data-ajuda" data-ajuda="arquivo_ocoren_ajuda">
                        <input type="file" id="arquivo_ocoren" class="input-file-layout">
                        <label for="arquivo_ocoren" class="btn btn-tertiary js-labelFile">
                            <i class="icon fa fa-check"></i>
                            <span class="js-fileName">Selecionar Arquivo</span>
                        </label>
                        <input type="hidden" name="arquivo_ocoren" id="arquivo_ocorenHidden"
                               data-serialize-campo="arquivo_ocoren">
                        <input type="hidden" name="nome_arquivo_ocoren" id="nome_arquivo_ocoren"
                               data-serialize-campo="nome_arquivo_ocoren">
                    </div>
                </div>
                <div class="col-md-2">
                    <button class="bt-salvar ativa-helper-data-ajuda" id="importar_edi" data-label="Importar EDI" data-ajuda="importar_edi_ajuda">Importar EDI</button>
                </div>
            </div>
            <div class="container-campos">
                <div id="container-dom-ocorrencias">
                    <table cellspacing="0" class="tabela-gwsistemas" id="tabela-gwsistemas">
                        <thead>
                        <tr>
                            <th width="6%">N° CT-e</th>
                            <th width="14%">Filial</th>
                            <th width="7%">Emissão</th>
                            <th width="6%">N° NF-e</th>
                            <th width="14%">Remetente</th>
                            <th width="14%">Destinatário</th>
                            <th width="14%">Ocorrência</th>
                            <th width="10%">Data/Hora Ocorrência</th>
                            <th width="15%">Observação</th>
                        </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="container-campos qtd_ocorrencias">
                <label><strong>Qtd ocorrências: </strong><span id="qtd_ocorrencias">0</span></label>
            </div>
        </div>
    </div>
</section>
<section class="section-bt">
    <div class="container-bt">
        <button data-label="Salvar [F8]" id="bt-salvar" class="bt-salvar ativa-helper-data-ajuda" data-ajuda="bt_salvar_ajuda" style="margin-top: 20px">Salvar [F8]</button>
    </div>
</section>
<div class="cobre-tudo"></div>
<%-- Variáveis para o JavaScript --%>
<input type="hidden" id="cadconhecimento" name="cadconhecimento" value="${cadconhecimento}">
<input type="hidden" id="lanconhfl" name="lanconhfl" value="${lanconhfl}">
<input type="hidden" id="filial_id" name="filial_id" value="${filial_id}">
<input type="hidden" id="layout_ocoren_ajuda" name="layout_ocoren_ajuda">
<input type="hidden" id="arquivo_ocoren_ajuda" name="arquivo_ocoren_ajuda">
<input type="hidden" id="importar_edi_ajuda" name="importar_edi_ajuda">
<input type="hidden" id="bt_salvar_ajuda" name="bt_salvar_ajuda">
</body>
</html>
