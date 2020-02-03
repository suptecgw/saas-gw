<%--
    Document   : cadastro-contrato-comercial
    Created on : 15/01/2018, 14:10:06
    Author     : estagiario_manha
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page contentType="text/html" pageEncoding="ISO-8859-1" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="ISO-8859-1">
        <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${tema}.css?v=${random.nextInt()}">
        <!--<script src="${homePath}/gwTrans/cadastros/js/jquery-3.2.1.min.js" type="text/javascript"></script>-->
        <script src="${homePath}/gwTrans/cadastros/js/cadastro.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}"
        type="text/javascript"></script>
        <link href="${homePath}/assets/css/inputs-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
        <link href="${homePath}/assets/css/select-multiplo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
        <link href="${homePath}/assets/css/select-multiplo-grupo-gw.css" rel="stylesheet" type="text/css">
        <link href="${homePath}/assets/css/bootstrap-theme.css" rel="stylesheet" type="text/css">
        <link href="${homePath}/gwTrans/cadastros/css/cadastro-contrato-comercial.css?v=${random.nextInt()}"
              rel="stylesheet" type="text/css">
        <script defer src="${homePath}/script/validarSessao.js?v=${random.nextInt()}" type="text/javascript"></script>
    </head>
    <body>
        <div class="container-form">
            <form method="POST" id="formCadastro" name="formCadastro">
                <div class="col-md-12 celula-zebra">
                    <div class="localiza">
                    </div>
                    <div class="container-campos">
                        <div class="col-md-3">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">Número</div>
                            </div>
                            <span class="container-input-form-gw input-width-80">
                                <input type="hidden" id="excluidosDOM" name="excluidosDOM"  data-serialize-campo="excluidosDOM">
                                <input type="hidden" name="acao"
                                       value="${contrato.id == null ? "cadastrar" : "editar"}">
                                <input type="hidden" name="id" value="${contrato.id == null ? "0" : contrato.id}" data-serialize-campo="id">
                                <input class="input-form-gw input-width-100 ativa-helper input-readonly" name="numero" id="numero"
                                       required="required" type="text" placeholder="Campo obrigatório!"
                                       value="${contrato.numero == null ? novoNumero : contrato.numero}"
                                       readonly="readonly" data-serialize-campo="numero">
                                <!--<label for="numero">Número</label>-->
                            </span>
                        </div>
                        <div class="col-md-3">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">Emissão</div>
                            </div>
                            <span class="container-input-form-gw input-width-80">
                                <input class="input-form-gw input-width-100 ativa-helper" name="dataEmissao" id="emissao"
                                       required="required" type="text" placeholder="Campo obrigatório!"
                                       value="${contrato.dataEmissao == null ? dataAtual : contrato.dataEmissao}"
                                       data-validar="true" data-type="text" data-data="true" data-data-obrigatorio="true"
                                       data-erro-validacao="O campo Emissão é de preenchimento obrigatório!" data-serialize-campo="dataEmissao">
                                <!--<label for="emissao">Emissão</label>-->
                            </span>
                        </div>
                        <div class="col-md-3">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">Validade</div>
                            </div>
                            <span class="container-input-form-gw input-width-80">
                                <input class="input-form-gw input-width-100 ativa-helper" name="validade" id="validade"
                                       data-data="true" data-data-obrigatorio="false" placeholder="Validade" type="text" value="${contrato.validade}" data-serialize-campo="validade">
                                <!--<label for="validade">Validade</label>-->
                            </span>
                        </div>
                        <!--<div class="label-campo">Filial</div>-->
                        <div class="col-md-3">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">Filial</div>
                            </div>
                            <select name="filial" id="filial" class="ativa-helper" data-serialize-campo="filial">
                                <c:forEach items="${filiais}" var="filial">
                                    <c:choose>
                                        <c:when test="${contrato != null}">
                                            <option value="${filial.idfilial}"
                                                    <c:if test="${contrato.filial.id == filial.idfilial}">selected</c:if> >${filial.abreviatura}</option>
                                        </c:when>
                                        <c:otherwise>
                                            <option value="${filial.idfilial}"
                                                    <c:if test="${userFilial.idfilial == filial.idfilial}">selected</c:if> >${filial.abreviatura}</option>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-5" style="margin-top: -2px;">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">Cliente</div>
                            </div>
                            <input class="input ativa-helper" type="text" id="inptCliente" name="inptCliente" readonly="readonly"
                                   placeholder="" data-validar="true" data-type="text"
                                   data-erro-validacao="O campo Cliente é de preenchimento obrigatório!" data-serialize-campo="inptCliente">
                            <div class="btns" style="float: left; width: 30%;">
<!--                                <a href="javascript:" onclick="removerValorInput('inptCliente', true);" class="btnDelete"
                                   style="margin-top: 2px;"></a>-->
                                <a href="javascript:checkSession(function(){abrirLocalizarCliente()},false);"
                                   class="btnMore" style="float: left !important;margin-right: 10px;"></a>
                                <!--<img src="${homePath}/assets/img/pesquisar_por.jpg" class="img-visualizar">-->
                            </div>
                        </div>
                    </div>
                </div>
                <div class="container-dom">
                    <div class="container-abas noselect">
                        <div class="aba aba01 aba-selecionada">Tabelas de preços</div>
                        <div class="aba aba02">Observações do contrato</div>
                        <div class="aba aba03">Condições de pagamento</div>
                        <div class="aba aba04">Observações gerais</div>
                    </div>
                </div>
                <div class="col-md-12 conteudo-aba" id="conteudo-aba1">
                    <div class="container-dom">
                        <div class="container-lista">
                            <div class="label-campo-identificacao-ctes" style="margin-bottom: 5px;font-size: 14px;font-weight: bold;color: #444;">
                                Código:
                            </div>
                            <div class="col-md-2">
                                <span class="ui-selectmenu-button ui-widget ui-state-default ui-corner-all">
                                    <input id="codigoEnter" class="input-form-gw input-width-100" type="text">
                                </span>
                            </div>
                            <div class="col-md-2">
                                <div class="bt-pesquisar-tabela" id="bt-pesquisar-tabela">Pesquisar</div>
                            </div>
                        </div>
                        <div class="top-dom">
                            <div class="col-md-12">
                                <!--<input class="input-localizar-gw">-->
                                <div class="" style="margin-bottom: 0;width: 45px;float: left;">
                                    <div class="body-dom" style="padding-top: 5px;">
                                        <div class="header-dom">
                                            <img src="${homePath}/gwTrans/cadastros/img/plus-dom.png" alt="Novo grupo"/>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-2" style="margin-bottom: 0;">
                                    <div class="body-dom" style="">
                                        <label class="title-dom">Código</label>
                                    </div>
                                </div>
                                <div class="col-md-2" style="margin-bottom: 0;">
                                    <div class="body-dom" style="">
                                        <label class="title-dom">Origem</label>
                                    </div>
                                </div>
                                <div class="col-md-2" style="margin-bottom: 0;">
                                    <div class="body-dom" style="">
                                        <label class="title-dom">Destino</label>
                                    </div>
                                </div>
                                <div class="col-md-1" style="margin-bottom: 0;">
                                    <div class="body-dom" style="">
                                        <label class="title-dom">Tipo de produto</label>
                                    </div>
                                </div>
                                <div class="col-md-1" style="margin-bottom: 0;">
                                    <div class="body-dom" style="">
                                        <label class="title-dom">Frete/Kg</label>
                                    </div>
                                </div>
                                <div class="col-md-1" style="margin-bottom: 0;">
                                    <div class="body-dom" style="">
                                        <label class="title-dom">% NF</label>
                                    </div>
                                </div>
                                <div class="col-md-1" style="margin-bottom: 0;">
                                    <div class="body-dom" style="">
                                        <label class="title-dom">Frete mínimo</label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-12 conteudo-aba" id="conteudo-aba2" style="display: none;">
                    <div class="container-dom ativa-helper2" id="obs">
                        <div contenteditable="true" class="obs">${contrato.observacao == null ? config.observacoesContrato.replaceAll('[\\n\\r]', "<br>") : contrato.observacao.replaceAll('[\\n\\r]', "<br>")}</div>
                    </div>
                </div>
                <div class="col-md-12 conteudo-aba" id="conteudo-aba3" style="display: none;">
                    <div class="container-dom ativa-helper2" id="obs-condicoes">
                        <div contenteditable="true" class="obs">${contrato.condicoesPagamento == null ? config.condicoesPagamento.replaceAll('[\\n\\r]', "<br>") : contrato.condicoesPagamento.replaceAll('[\\n\\r]', "<br>")}</div>
                    </div>
                </div>
                <div class="col-md-12 conteudo-aba" id="conteudo-aba4" style="display: none;">
                    <div class="container-dom ativa-helper2" id="obs-gerais">
                        <div contenteditable="true" class="obs">${contrato.observacoesGerais == null ? config.observacoesGerais.replaceAll('[\\n\\r]', "<br>") : contrato.observacoesGerais.replaceAll('[\\n\\r]', "<br>")}</div>
                    </div>
                </div>
                <input type="hidden" name="obs" value="${contrato.observacao == null ? config.observacoesContrato.replaceAll('[\\n\\r]', "<br>") : contrato.observacao.replaceAll('[\\n\\r]', "<br>")}" data-serialize-campo="obs">
                <input type="hidden" name="obs-condicoes" value="${contrato.condicoesPagamento == null ? config.condicoesPagamento.replaceAll('[\\n\\r]', "<br>") : contrato.condicoesPagamento.replaceAll('[\\n\\r]', "<br>")}" data-serialize-campo="obs-condicoes">
                <input type="hidden" name="obs-gerais" value="${contrato.observacoesGerais == null ? config.observacoesGerais.replaceAll('[\\n\\r]', "<br>") : contrato.observacoesGerais.replaceAll('[\\n\\r]', "<br>")}" data-serialize-campo="obs-gerais">
            </form>
        </div>
        <script src="${homePath}/gwTrans/cadastros/js/cadastro-contrato-comercial.js?v=${random.nextInt()}"
        type="text/javascript"></script>
    </body>
    <script>
        var i = 100;
        var tema = '${tema}';
        jQuery(document).ready(function () {
            <c:if test="${contrato!=null}">
                addValorAlphaInput('inptCliente', '${contrato.cliente.razaosocial}', '${contrato.cliente.id}', true);

                criadoAlteradoAuditoria('${contrato.criadoPor.nome}', '${contrato.criadoEm}', '${contrato.editadoPor.nome}', '${contrato.editadoEm}');
            </c:if>
        });

        <c:forEach items="${contrato.tabelasPreco}" var="tabela">
            setTimeout(function () {
                var body = null;
                var containerDom = $('#conteudo-aba1');

                if (containerDom.find('.body')[0]) {
                    body = containerDom.find('.body');
                } else {
                    containerDom.append($('<div class="container-dom" id="body-container"><div class="body">'));
                    body = containerDom.find('.body');
                }
                var bodyDom = $('<div class="col-md-12 body-dom celula-zebra-2" style="padding-top:12px;">');
                $(body).append(bodyDom);
                $(bodyDom).load(homePath + '/gwTrans/cadastros/html-dom/dom-tabela-preco.jsp?v=0.1&tema=${tema}', function () {
                    idLocalizar = jQuery("input[id^='tabela']").last().attr('id');
                    addValorAlphaInput(idLocalizar, '${tabela.tabela.id}', '${tabela.tabela.id}', true);
                    jQuery("input[id^='origem']").last().val('${tabela.tabela.origem}');
                    jQuery("input[id^='destino']").last().val('${tabela.tabela.destino}');
                    jQuery("input[id^='tipoProduto']").last().val('${tabela.tabela.tipoProduto}');
                    jQuery("input[id^='valorFrete']").last().val('${tabela.tabela.valorFrete}');
                    jQuery("input[id^='porcentagemNF']").last().val('${tabela.tabela.porcentagemNF}');
                    jQuery("input[id^='freteMinimo']").last().val('${tabela.tabela.freteMinimo}');
                    jQuery("input[id^='idTabelaContrato']").last().val('${tabela.id}');
                });
            }, i);
            i = i + 100;
        </c:forEach>
    </script>
</html>
