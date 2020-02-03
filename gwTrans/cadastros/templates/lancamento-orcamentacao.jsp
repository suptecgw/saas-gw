<%-- 
    Created on : 28/12/2017, 12:01:19
    Author     : mateus veloso
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="ISO-8859-1">
    <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${tema}.css?v=${random.nextInt()}">
    <link href="${homePath}/assets/css/select-multiplo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
    <link href="${homePath}/assets/css/select-multiplo-grupo-gw.css" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.7.2/css/all.css" integrity="sha384-fnmOCqbTlWIlj8LyTjo7mOUStjsKC4pOpQbqyi7RrhN7udi9RwhKkMHpvLbHG9Sr" crossorigin="anonymous">
    <link href="${homePath}/gwTrans/cadastros/css/lancamento-orcamentacao.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
</head>
<body>
    <script>
        let podeAlterar = '${pode_alterar}' === 'true';
    </script>
    <div class="container-form" style="overflow: hidden;">
        <form method="POST" id="formCadastro" name="formCadastro">
            <div class="col-md-12 celula-zebra">
                <div class="container-campos">
                    <div class="col-md-3">
                        <div class="identificacao-campo">
                            <div class="label-campo-identificacao">Competência</div>
                        </div>
                        <span class="container-input-form-gw input-width-100">
                            <input type="hidden" id="id" name="id" data-serialize-campo="id" value="0">
                            <input class="input-form-gw input-width-100 ativa-helper" name="competencia" id="competencia"
                                   maxlength="40" required="required" type="text"
                                   placeholder="Competência" data-serialize-campo="competencia"
                                   data-validar="true" data-type="text"
                                   data-erro-validacao="O campo Competência é de preenchimento obrigatório!"
                                   ${pode_alterar ? "" : "disabled"}>
                        </span>
                    </div>
                    <div class="col-md-2">
                        <div class="identificacao-campo">
                            <div class="label-campo-identificacao">Filial</div>
                        </div>
                        <select name="filial" id="filial" class="ativa-helper" data-serialize-campo="filial"
                                ${pode_alterar_filial ? (pode_alterar ? "" : "disabled") : "disabled"}>
                            <c:forEach items="${filiais}" var="filial">
                                <option value="${filial.idfilial}" ${user.filial.idfilial eq filial.idfilial ? "selected" : ""}>${filial.abreviatura}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-12">
                        <div class="container-tela-pl-custo effect2">
                            <div class="topo-pl-custo">
                                <div class="col-pl-custo">
                                    <label><i class="fas fa-sync-alt" style="font-size: x-large; cursor: pointer;" title="Atualizar Plano de Custo e Unidades de Custo" id="icone-atualizar"></i> Plano de Custo</label>
                                </div>
                                <div class="col-pl-tipo">Tipo</div>
                                <div class="col-pl-und-custo">
                                    <label>Unidades de Custos</label>
                                    <div id="col-pl-vl-total" class="col-pl-vl-total">Valor Total</div>
                                    <div class="col-pl-vl-total container-unidades"></div>
                                </div>
                            </div>
                            <div class="body-pl-custo">
                                <div class="col-body-pl-custo">

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <input type="hidden" name="plano_custo_ajuda" id="plano_custo_ajuda">
            <input type="hidden" name="tipo_ajuda" id="tipo_ajuda">
            <input type="hidden" name="valor_total_ajuda" id="valor_total_ajuda">
            <input type="hidden" name="valor_und_custo_ajuda" id="valor_und_custo_ajuda">
        </form>
        <input type="hidden" id="inputLocalizarOrcamentacao" name="inputLocalizarOrcamentacao" value="0">
    </div>
    <img class="gif-bloq-tela" src="${homePath}/img/espere_new.gif" alt=""/>
    <div class="bloqueio-tela"></div>
    <div class="cobre-tudo"></div>
    <div class="localiza">
        <iframe id="localizarOrcamentacao" input="inputLocalizarOrcamentacao" name="localizarOrcamentacao" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarOrcamentacao&tema=${tema}&ocultarOpcoesAvancadas=true" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
    </div>
    <script src="${homePath}/gwTrans/cadastros/js/cadastro.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script defer src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script src="${homePath}/gwTrans/cadastros/js/lancamento-orcamentacao.js?v=${random.nextInt()}" type="text/javascript"></script>
</body>
</html>