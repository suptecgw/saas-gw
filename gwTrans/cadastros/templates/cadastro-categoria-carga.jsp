<%-- 
    Document   : cadastro-tde
    Created on : 28/12/2017, 12:01:19
    Author     : mateus
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1" %>
<!DOCTYPE html>
<head>
    <meta charset="ISO-8859-1">
    <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${tema}.css?v=${random.nextInt()}">
    <script src="${homePath}/gwTrans/cadastros/js/cadastro.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
    <link href="${homePath}/assets/css/select-multiplo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
    <link href="${homePath}/assets/css/select-multiplo-grupo-gw.css" rel="stylesheet" type="text/css">
</head>
<body>
<div class="container-form">
    <div class="col-md-12 celula-zebra">
        <div class="container-campos">
            <div class="col-md-3">
                <div class="identificacao-campo">
                    <div class="label-campo-identificacao">Descrição</div>
                </div>
                <span class="container-input-form-gw input-width-100">
                    <input type="hidden" id="acao" name="acao" value="cadastrar" data-serialize-campo="acao">
                    <input type="hidden" id="id" name="id" data-serialize-campo="id" value="0">
                    <input class="input-form-gw input-width-100 ativa-helper" id="descricao" name="descricao"
                           required="required" type="text" maxlength="50" data-serialize-campo="descricao"
                           placeholder="Descrição da categoria de carga" data-validar="true" data-type="text"
                           data-erro-validacao="O campo Descrição é de preenchimento obrigatório!">
                </span>
            </div>
        </div>
    </div>
</div>
<script src="${homePath}/gwTrans/cadastros/js/cadastro-categoria-carga.js?v=${random.nextInt()}"
        type="text/javascript"></script>
</body>