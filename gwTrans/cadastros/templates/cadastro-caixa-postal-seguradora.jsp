<%@page contentType="text/html" pageEncoding="ISO-8859-1" %>
<!DOCTYPE html>
<head>
    <meta charset="ISO-8859-1">
    <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${tema}.css?v=${random.nextInt()}">
    <script src="${homePath}/gwTrans/cadastros/js/cadastro.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
    <link href="${homePath}/assets/css/select-multiplo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
    <link href="${homePath}/assets/css/select-multiplo-grupo-gw.css" rel="stylesheet" type="text/css">
    <link href="${homePath}/gwTrans/cadastros/css/cadastro-caixa-postal-seguradora.css" rel="stylesheet" type="text/css">
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
                           required="required" type="text" maxlength="40" data-serialize-campo="descricao"
                           placeholder="Descrição da Caixa Postal" data-validar="true" data-type="text"
                           data-erro-validacao="O campo Descrição é de preenchimento obrigatório!">
                </span>
            </div>
            <div class="col-md-3">
                <div class="identificacao-campo">
                    <div class="label-campo-identificacao">Código de averbação</div>
                </div>
                <span class="container-input-form-gw input-width-100">
                    <input class="input-form-gw input-width-100 ativa-helper" id="codigo_averbacao" name="codigo_averbacao"
                           required="required" type="text" maxlength="20" data-serialize-campo="codigo_averbacao"
                           placeholder="Código de Averbação" data-validar="true" data-type="text"
                           data-erro-validacao="O campo Código de Averbação é de preenchimento obrigatório!">
                </span>
            </div>
            <div class="col-md-3">
                <div class="identificacao-campo">
                    <div class="label-campo-identificacao">Login</div>
                </div>
                <span class="container-input-form-gw input-width-100">
                    <input class="input-form-gw input-width-100 ativa-helper" id="login_averbacao" name="login_averbacao"
                           required="required" type="text" maxlength="20" data-serialize-campo="login_averbacao"
                           placeholder="Login" data-validar="true" data-type="text"
                           data-erro-validacao="O campo Login é de preenchimento obrigatório!">
                </span>
            </div>
            <div class="col-md-3">
                <div class="identificacao-campo">
                    <div class="label-campo-identificacao">Senha</div>
                </div>
                <span class="container-input-form-gw input-width-100">
                    <input class="input-form-gw input-width-100 ativa-helper" id="senha_averbacao" name="senha_averbacao"
                           required="required" type="password" maxlength="20" data-serialize-campo="senha_averbacao"
                           placeholder="Senha" data-validar="true" data-type="text"
                           data-erro-validacao="O campo Senha é de preenchimento obrigatório!">
                </span>
            </div>
        </div>
        <div class="container-campos">
            <div class="col-md-3">
                <div class="identificacao-campo">
                    <div class="label-campo-identificacao">Empresa</div>
                </div>
                <select id="empresa_averbacao" name="empresa_averbacao" data-serialize-campo="empresa_averbacao" class="ativa-helper">
                    <option value="1">AT&M</option>
                    <option value="2">ELTSEG</option>
                    <option value="3">Porto Seguro</option>
                </select>
            </div>
            <div class="col-md-3" id="divVersaoAverbacao">
                <div class="identificacao-campo">
                    <div class="label-campo-identificacao">Versão</div>
                </div>
                <select id="versao_averbacao" name="versao_averbacao" data-serialize-campo="versao_averbacao" class="ativa-helper">
                    <option value="100">1.00</option>
                    <option value="300">3.00</option>
                </select>
            </div>
        </div>
    </div>
</div>
<script src="${homePath}/gwTrans/cadastros/js/cadastro-caixa-postal-seguradora.js?v=${random.nextInt()}"
        type="text/javascript"></script>
</body>