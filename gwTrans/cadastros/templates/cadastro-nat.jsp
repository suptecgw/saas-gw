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
                        <input type="hidden" name="acao" value="cadastrar" data-serialize-campo="acao">
                        <input type="hidden" name="id" value="0" data-serialize-campo="id">
                        <input class="input-form-gw input-width-100 ativa-helper" id="descricao" name="descricao"
                               required="required" type="text" maxlength="50" data-serialize-campo="descricao"
                               placeholder="Descrição NAT" data-validar="true" data-type="text"
                               data-erro-validacao="O campo Descrição é de preenchimento obrigatório!">
                    </span>
                </div>
                <div class="col-md-3">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Tipo de Acesso</div>
                    </div>
                    <select name="tipoAcesso" id="tipoAcesso" class="ativa-helper1" data-serialize-campo="tipoAcesso">
                        <option value="1" selected>Externo</option>
                        <option value="2">Interno</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">IP</div>           
                    </div>
                    <span class="container-input-form-gw input-width-100">
                        <input class="input-form-gw input-width-100 ativa-helper" id="ip" name="ip"
                               required="required" type="text" maxlength="50" data-serialize-campo="ip"
                               placeholder="Número do IP" data-validar="true" data-type="text"
                               data-erro-validacao="O campo IP é de preenchimento obrigatório!">
                    </span>  
                </div>
                  <div class="col-md-3" id="div-ip-final">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">IP Final</div>           
                    </div>
                    <span class="container-input-form-gw input-width-100">
                        <input class="input-form-gw input-width-100 ativa-helper" id="ipFinal" name="ipFinal"
                               required="required" type="text" maxlength="50"  data-serialize-campo="ipFinal"
                               placeholder="Número do IP final" data-validar="true" data-type="text"
                               data-erro-validacao="O campo IP FINAL é de preenchimento obrigatório!">
                    </span>            
                </div>
            </div>
        </div>
    </div>
    <img class="gif-bloq-tela" src="${homePath}/img/espere_new.gif" alt=""/>
    <div class="bloqueio-tela"></div>
    <script src="${homePath}/gwTrans/cadastros/js/cadastro-nat.js?v=${random.nextInt()}" type="text/javascript"></script>
</body>