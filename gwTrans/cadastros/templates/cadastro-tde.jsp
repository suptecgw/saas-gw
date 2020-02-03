<%-- 
    Document   : cadastro-tde
    Created on : 28/12/2017, 12:01:19
    Author     : mateus
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<head>
    <meta charset="ISO-8859-1">
    <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${tema}.css?v=${random.nextInt()}">
    <script src="${homePath}/gwTrans/cadastros/js/cadastro.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script  src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script  src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}" type="text/javascript"></script>
    <link href="${homePath}/assets/css/select-multiplo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
    <link href="${homePath}/assets/css/select-multiplo-grupo-gw.css" rel="stylesheet" type="text/css"/>
</head>
<body>
    <div class="container-form">
        <form method="POST" id="formCadastro" name="formCadastro">
            <input type="hidden" name="id" id="id" value="0" data-serialize-campo="id">
            <div class="col-md-12">
                <div class="container-campos">
                    <div class="col-md-4">
                        <div class="identificacao-campo">
                            <div class="label-campo-identificacao">Descrição</div>
                        </div>
                        <span class="container-input-form-gw input-width-100">
                            <input class="input-form-gw input-width-100 ativa-helper" id="descricao"  name="descricao" data-serialize-campo="descricao" data-campo-gw="true" data-type="text" data-erro-validacao="O campo descrição é de preenchimento obrigatório" data-validar="true" required="required" type="text" placeholder="Campo obrigatório!">
                        </span>
                    </div>
                </div>
            </div>
            <div class="col-md-12 " style="padding: 0;border-bottom: 2px solid rgba(4, 44, 81,0.3);">
                <div class="container-abas noselect">
                    <div class="aba aba01 aba-selecionada">Grupo de Clientes / Destinatários</div>
                </div>
            </div>
            <div class="col-md-12">
                <div class="iframe-formula" style="">
                    <iframe src="${homePath}/gwTrans/cadastros/templates/formula.jsp?tema=${tema}" id="formula" frameborder="0" marginheight="0" marginwidth="0" scrolling="no"></iframe>
                </div>
            </div>
            <div class="col-md-12 ">
                <div class="container-dom">
                    <div class="top-dom">
                        <div style="margin-bottom: 0px;width: 45px;float: left;">
                            <div class="header-dom">
                                <img src="${homePath}/gwTrans/cadastros/img/plus-dom.png" alt="Novo grupo"/> 
                            </div>
                        </div>
                        <div class="col-md-11">
                            <!--<input class="input-localizar-gw">-->
                            <div class="col-md-2" style="margin-bottom: 0px;">
                                <div class="body-dom" style="">
                                    <label class="title-dom">Tipo</label>
                                </div>
                            </div>
                            <div class="col-md-3" style="margin-bottom: 0px;">
                                <div class="body-dom" style="">
                                    <label class="title-dom">Grupo / Destinatário</label>
                                </div>
                            </div>
                            <div class="col-md-2" style="margin-bottom: 0px;">
                                <div class="body-dom"  style="">
                                    <label class="title-dom">Valor TDE</label>
                                </div>
                            </div>
                            <div class="col-md-2" style="margin-bottom: 0px;">
                                <div class="body-dom"  style="">
                                    <label class="title-dom">Tipo de cálculo</label>
                                </div>
                            </div>
                            <div class="col-md-2" style="margin-bottom: 0px;">
                                <div class="body-dom"  style="">
                                    <label class="title-dom">Fórmula</label>
                                </div>
                            </div>
                            <div class="col-md-1">
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </div>
    <div class="localiza">
        <iframe id="localizarGrupoCliente" name="localizarGrupoCliente"
                src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarGrupoCliente&tema=${tema}"
                frameborder="0" marginheight="0" marginwidth="0" scrolling="no"></iframe>
        <iframe id="localizarCliente" name="localizarCliente"
                src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarCliente&tema=${tema}"
                frameborder="0" marginheight="0" marginwidth="0" scrolling="no"></iframe>
    </div>
    <img class="gif-bloq-tela" src="${homePath}/img/espere_new.gif" alt=""/>
    <div class="bloqueio-tela"></div>
    <script src="${homePath}/gwTrans/cadastros/js/cadastro-tabela-adicional-tde.js?v=${random.nextInt()}" type="text/javascript"></script>
</body>