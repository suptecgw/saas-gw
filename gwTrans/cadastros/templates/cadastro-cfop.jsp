<%-- 
    Document   : cadastro-cfop
    Created on : 01/06/2018
    Author     : Rodolfo
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1" %>
<!DOCTYPE html>
<head>
    <meta charset="ISO-8859-1">
    <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${tema}.css?v=${random.nextInt()}">
    <link href="${homePath}/assets/css/select-multiplo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
    <link href="${homePath}/assets/css/select-multiplo-grupo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
    <link href="${homePath}/gwTrans/cadastros/css/cadastro-cfop.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
</head>
<body>
    <div class="container-form">
        <div class="col-md-12 celula-zebra">
            <div class="container-campos">
                <div class="col-md-3">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">CFOP</div>
                    </div>
                    <span class="container-input-form-gw input-width-100">
                        <input type="hidden" name="acao" value="cadastrar" data-serialize-campo="acao">
                        <input type="hidden" name="id" value="0" data-serialize-campo="id">
                        <input class="input-form-gw input-width-100 ativa-helper" id="cfop" name="cfop"
                               required="required" type="text" maxlength="5" data-serialize-campo="cfop"
                               placeholder="CFOP" data-validar="true" data-type="text" 
                               data-erro-validacao="O campo CFOP é de preenchimento obrigatório!">
                    </span>
                </div>
                <div class="col-md-3">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Descrição</div>
                    </div>
                    <span class="container-input-form-gw input-width-100">
                        <input type="hidden" name="acao" value="cadastrar" data-serialize-campo="acao">
                        <input type="hidden" name="id" value="0" data-serialize-campo="id">
                        <input class="input-form-gw input-width-100 ativa-helper" id="descricao" name="descricao"
                               required="required" type="text" maxlength="50" data-serialize-campo="descricao"
                               placeholder="Descrição CFOP" data-validar="true" data-type="text"
                               data-erro-validacao="O campo Descrição é de preenchimento obrigatório!">
                    </span>
                </div>
                <!--Plano de custo -->
                <div class="col-md-3">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Plano de Custo</div>
                    </div>
                    <span class="container-input-form-gw input-width-90">
                        <input class="input-width-100 ativa-helper" id="planoCusto" name="planoCusto" type="text" data-serialize-campo="planoCusto">
                    </span>
                    <img src="${homePath}/gwTrans/cadastros/img/icon-more.png" alt="" class="inp-localizar" onclick="toLocalizar('localizarPlanoCusto')"/>
                </div>         
                <div class="col-md-12">
                <div class="visualizarDocumentos">
                    <iframe id="iframeVisualizarDocumentos" name="iframeVisualizarDocumentos" src="" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
                </div>
                <div class="localiza">
                </div>    
            </div>
            </div>
        </div>
    </div>
    <img class="gif-bloq-tela" src="${homePath}/img/espere_new.gif" alt=""/>
    <div class="bloqueio-tela"></div>
    <div class="localiza">
        <iframe id="localizarPlanoCusto" input="planoCusto" name="localizarPlanoCusto" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarPlanoCusto&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
    </div>
    <script src="${homePath}/gwTrans/cadastros/js/cadastro.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script defer src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script src="${homePath}/gwTrans/cadastros/js/cadastro-cfop.js?v=${random.nextInt()}" type="text/javascript"></script>
</body>