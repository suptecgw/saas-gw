<%-- 
    Document   : cadastro-movimetacao-pallets
    Created on : 30/04/2019, 10:01:19
    Author     : manasses
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page contentType="text/html" pageEncoding="ISO-8859-1" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="ISO-8859-1">
        <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${tema}.css?v=${random.nextInt()}">
        <script src="${homePath}/gwTrans/cadastros/js/cadastro.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript" type="text/javascript"></script>
        <link href="${homePath}/assets/css/inputs-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
        <link href="${homePath}/assets/css/select-multiplo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
        <link href="${homePath}/assets/css/select-multiplo-grupo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
        <link href="${homePath}/gwTrans/cadastros/css/cadastro-movimentacao-pallets.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
        <script defer src="${homePath}/script/validarSessao.js?v=${random.nextInt()}" type="text/javascript"></script>
        <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css" rel="stylesheet">
    </head>   
    <body>
        <div class="container-form">
            <form method="POST" id="formCadastro" name="formCadastro">
                <input type="hidden" id="id" name="id" data-serialize-campo="id" value="0">
                <input type="hidden" id="userFilialId" name="userFilialId" value='${userFilial.idfilial}'>
                <input type="hidden" id="userFilialAbreviatura" name="userFilialAbreviatura" value='${userFilial.abreviatura}'>
                <div class="col-md-12">
                    <div class="container-campos">
                        <div class="col-md-3">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">N&uacute;mero</div>
                            </div>
                            <span class="container-input-form-gw input-width-100">
                                <input type="text" id="numero" name="numero" class="input-form-gw input-width-100 ativa-helper" data-serialize-campo="" readonly
                                       data-erro-validacao="Número da movimentação de pallet gerado automaticamente ao incluir uma nova movimentação."/>
                            </span>
                        </div>
                        <div class="col-md-3">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">Data</div>
                            </div>
                            <span class="container-input-form-gw input-width-80 data-span-emissao">
                                <input type="text" id="data" name="data" class="input-form-gw input-width-100 ativa-helper" data-serialize-campo="data" data-erro-validacao="Data da movimentação" value="${dataAtual}"/>
                            </span>
                        </div>
                        <div class="col-md-3">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">Filial</div>
                            </div>
                            <span class="container-input-form-gw input-width-80 localizar-tela-movimentacao">
                                <input type="hidden" id="filial_id" name="filial_id" data-serialize-campo="filial_id" data-validar="true" data-type="text"
                                       data-erro-validacao="Filial onde houve a movimentação de pallets">  
                            </span>
                            <img src="${homePath}/gwTrans/cadastros/img/icon-more.png" alt="" id="botao_localizar_cliente" class="inp-localizar" onclick="toLocalizar('filial')">
                        </div>
                    </div>
                    <div class="container-campos">
                        <div class="col-md-3">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">Tipo Lan&ccedil;amento</div>
                            </div>
                            <span class="input-width-100">
                                <select name="tipo_lancamento" id="tipo_lancamento" class="ativa-helper" data-serialize-campo="tipo_lancamento" data-erro-validacao="Tipo da movimentação, poderá ser Entrada ou
                                        Saída. O preenchimento correto desse campo é de fundamental importância para que o controle de estoque dos pallets seja efetivo.">                            
                                    <option value="c" selected>Entrada</option>
                                    <option value="d">Sa&iacute;da</option>
                                </select>    
                            </span>
                        </div>
                        <div class="col-md-3">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">Quantidade</div>
                            </div>
                            <span class="container-input-form-gw input-width-100">
                                <input type="text" id="quantidade" name="quantidade" class="input-form-gw input-width-100 ativa-helper" data-serialize-campo="quantidade"
                                       data-erro-validacao="Quantidade de pallets" value="0" />
                            </span>
                        </div> 
                        <div class="col-md-3">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">Cliente</div>
                            </div>
                            <span class="container-input-form-gw input-width-80 localizar-tela-movimentacao">
                                <input type="hidden" id="cliente_id" name="cliente_id" data-serialize-campo="cliente_id" data-validar="true" data-type="text"
                                       data-erro-validacao="Cliente ao qual os pallets pertencem">
                            </span>
                            <img src="${homePath}/gwTrans/cadastros/img/icon-more.png" alt="" id="botao_localizar_cliente" class="inp-localizar" onclick="toLocalizar('cliente')">
                            <span onclick="removerValorInput('cliente_id');" class="inp-localizar btnDelete" style="margin-top: 29px; margin-left: 56px;"></span>
                        </div>
                    </div>
                    <div class="container-campos">
                        <div class="col-md-3">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">Tipo de Pallet</div>
                            </div>
                            <span class="container-input-form-gw input-width-83 localizar-tela-movimentacao">
                                <input type="hidden" id="tipo_pallet_id" name="tipo_pallet_id" data-serialize-campo="tipo_pallet_id" data-validar="true" data-type="text"
                                       data-erro-validacao="O campo tipo de pallet é de preenchimento obrigatório!">
                            </span>
                            <img src="${homePath}/gwTrans/cadastros/img/icon-more.png" alt="" id="botao_localizar_pallets" class="inp-localizar" onclick="toLocalizar('pallet')">
                            <span onclick="removerValorInput('tipo_pallet_id');" class="inp-localizar btnDelete" style="margin-top: 28px; margin-left: 56px;"></span>
                        </div>
                        <div class="col-md-3">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">Nº Nota</div>
                            </div>
                            <span class="container-input-form-gw input-width-100">
                                <input type="text" id="numero_nota" name="numero_nota" class="input-form-gw input-width-100 ativa-helper" data-serialize-campo="numero_nota"
                                       data-erro-validacao="Número da nota que acompanhou o transporte dos pallets" maxlength="8"/>
                            </span>
                        </div>
                    </div>
                    <div class="container-campos" style="display: none" id="div_manifesto_coleta">
                        <div class="col-md-3">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">Nº Manifesto</div>
                            </div>
                            <span class="container-input-form-gw input-width-100">
                                <input type="text" id="numero_manifesto" name="numero_manifesto" class="input-form-gw input-width-100 ativa-helper" data-serialize-campo="numero_manifesto"
                                       data-erro-validacao="Nº do manifesto que houve a movimentação dos pallets. Esse campo será preenchido apenas se a movimentação for realizada pelo lançamento de manifestos" readonly />
                            </span>
                        </div>
                        <div class="col-md-3">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">Nº Coleta</div>
                            </div>
                            <span class="container-input-form-gw input-width-100">
                                <input type="text" id="numero_coleta" name="numero_coleta" class="input-form-gw input-width-100 ativa-helper" data-serialize-campo="numero_coleta"
                                       data-erro-validacao="Nº da coleta que houve a movimentação dos pallets. Esse campo será preenchido apenas se a movimentação for realizadas pelo lançamento de coletas" readonly/>
                            </span>
                        </div>
                    </div>
                    <div class="container-campos">
                        <div class="col-md-3">
                            <div class="container-input-form-gw input-width-80 ativa-helper1 checkbox-input">
                                <div class="section-check-cadastro">
                                    <input id="confirmado" name="confirmado" type="checkbox" data-serialize-campo="confirmado" class="chk-save">
                                    <label for="confirmado">
                                        <span></span>
                                        Confirmada
                                    </label>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>                        
            </form>
        </div>
        <div class="localiza">
            <iframe id="localizarFilial" input="filial_id" name="localizarFilial" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarFilial&tema=${tema}&ocultarOpcoesAvancadas=true" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>
        <div class="localiza"> 
            <iframe id="localizarCliente" input="cliente_id" name="localizarCliente" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarCliente&tema=${tema}&ocultarOpcoesAvancadas=true" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>
        <div class="localiza"> 
            <iframe id="localizarTipoPallet" input="tipo_pallet_id" name="localizarTipoPallet" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarTipoPallet&tema=${tema}&ocultarOpcoesAvancadas=true" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>
        <script defer src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/gwTrans/cadastros/js/cadastro-movimentacao-pallets.js?v=${random.nextInt()}" type="text/javascript"></script>
    </body>
</html>