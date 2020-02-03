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
    <link href="${homePath}/gwTrans/cadastros/css/cadastro-conferente.css?v=${random.nextInt()}" rel="stylesheet"
          type="text/css">
</head>
<body>
<div class="container-form">
    <form method="POST" id="formCadastro" name="formCadastro">
        <div class="col-md-12 celula-zebra">
            <div class="container-campos">
                <div class="col-md-3">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Nome</div>
                    </div>
                    <span class="container-input-form-gw input-width-100">
                        <input type="hidden" id="id" name="id" data-serialize-campo="id">
                        <input class="input-form-gw input-width-100 ativa-helper" name="nome" id="nome"
                               maxlength="40" required="required" type="text"
                               placeholder="Nome do conferente de carga" data-serialize-campo="nome"
                               data-validar="true" data-type="text"
                               data-erro-validacao="O campo Nome é de preenchimento obrigatório!">
                    </span>
                </div>
                <div class="col-md-3">
                    <div class="container-input-form-gw input-width-80 ativa-helper1 checkbox-input">
                        <div class="section-check-conferente">
                            <input id="ativo" name="ativo" type="checkbox" data-serialize-campo="ativo"
                                   class="chk-save">
                            <label for="ativo">
                                <span></span>
                                Ativo
                            </label>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>
<script src="${homePath}/gwTrans/cadastros/js/cadastro-conferente.js?v=${random.nextInt()}"
        type="text/javascript"></script>
</body>