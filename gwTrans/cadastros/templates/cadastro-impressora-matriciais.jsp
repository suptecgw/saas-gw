<%-- 
    Document   : cadastro-Impressora(icescrum history 75 sprint 2)
    Created on : 20/06/2018, 09:30:19
    Author     : estagiario-manasses
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1" %>
<!DOCTYPE html>
<head>
    <meta charset="ISO-8859-1">
    <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${tema}.css?v=${random.nextInt()}">
    <script src="${homePath}/gwTrans/cadastros/js/cadastro.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
    <link href="${homePath}/assets/css/select-multiplo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
    <link href="${homePath}/assets/css/select-multiplo-grupo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
    <link href="${homePath}/gwTrans/cadastros/css/cadastro-impressora-matriciais.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
    <script defer src="${homePath}/script/validarSessao.js?v=${random.nextInt()}" type="text/javascript"></script>
    <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css?v=${random.nextInt()}"   rel="stylesheet">
</head>
<body>
    <div class="container-form">
        <div class="col-md-12 celula-zebra">
            <div class="container-campos">
                <div class="col-md-4">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Descrição</div>
                    </div>
                    <span class="container-input-form-gw input-width-100">
                        <input type="hidden" id="acao" name="acao" value="cadastrar" data-serialize-campo="acao">
                        <input type="hidden" id="idImpressora" name="idImpresssora" value="0" data-serialize-campo="idImpressora">
                        <input class="input-form-gw input-width-100 ativa-helper" id="descricao" name="descricao"
                               required="required" type="text" maxlength="50"
                               placeholder="Descrição da Impressora" data-validar="true" data-type="text"
                               data-erro-validacao="O campo Descrição é de preenchimento obrigatório!" 
                               data-serialize-campo="descricao">
                    </span>
                </div>
            </div>
        </div>
        <script src="${homePath}/gwTrans/cadastros/js/cadastro-impressora-matriciais.js?v=${random.nextInt()}"
        type="text/javascript"></script>
</body>