<%-- 
    Document   : salvar_filtros
    Created on : 11/11/2016, 11:56:59
    Author     : Mateus
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-9"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-9">
        <title>Gw Sistemas | Salvar Filtros</title>
        <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${param.tema}.css?v=${random.nextInt()}">
        <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
        <script src="${homePath}/assets/js/jquery-1.9.1.min.js" type="text/javascript"></script>
        <script defer src="${homePath}/assets/js/material-min.js" type="text/javascript"></script>
        <script defer src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
        <link href="${homePath}/assets/css/material-min.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/salvar-filtros.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <script defer src="${homePath}/script/validarSessao.js?v=${random.nextInt()}" type="text/javascript"></script>
        <style>
            /*.mdl-radio__inner-circle{background: red !important;}*/
        </style>
       
        <script>
            var homePath = '${homePath}';
            
            jQuery(document).ready(function () {
                if ('${param.nomePesquisa}' != null && '${param.nomePesquisa}'.trim() != '' && '${param.nomePesquisa}'.trim() != '0') {
                    jQuery('#nomePesquisa').val('${param.nomePesquisa}');
                    jQuery('#nomePesquisaOriginal').val('${param.nomePesquisa}');
                    jQuery('#sobrescrever').prop('checked', true);
                    jQuery("input[name='aoSalvar']").attr('disabled', false);
                } else {
                    jQuery('#nomePesquisa').val('');
                    jQuery('#criarNovo').prop('checked', true);
                    setTimeout(function () {
                        jQuery("input[name='aoSalvar']").attr('disabled', true);
                    }, 1000);
                }
                jQuery('#nomePesquisa').focus();
            });

            window.onload = function () {
                jQuery('#nomePesquisa').focus();
            };
        </script>
    </head>
    <body>
        <div class="container-re-login">
            <div class="topo-re-login">
                <img src="${homePath}/assets/img/logo.png" alt="" class="logo"/>
                <!--<img src="${homePath}/img/usuario/usuario1/perfil_usuario_1_1.png" class="perfil">-->
            </div>
            <div class="mdl-grid" style="float: left;">
                <div class="mdl-cell mdl-cell--12-col">
                    <center>
                        <label class="text-label">Salvar pesquisa</label>
                        <!--<img src="${homePath}/assets/img/icon-question.png" class="question">-->
                    </center>
                    <center>
                        <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label is-upgraded is-focused" style="width: 100%;margin-top: 10px;float: left;">
                            <input class="mdl-textfield__input" type="text" autocomplete="off" id="nomePesquisa" name="nomePesquisa">
                            <input type="hidden" value="" name="nomePesquisaOriginal" id="nomePesquisaOriginal">
                            <label class="mdl-textfield__label" for="nomePesquisa">Nome da pesquisa</label>
                        </div>
                        <!--<div id="tt1" class="icon material-icons">add</div>-->

                        <div style="width: 100%;float: left;">
                            <label id="tipo">Tipo:</label>
                            <label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="option-1" style="float: left;margin-left: 10px;width: 108px;">
                                <input type="radio" id="option-1" class="mdl-radio__button" name="options" value="1" checked>
                                <span class="mdl-radio__label radio-label" style="float: left;">Privada</span>
                            </label>
                            <div class="mdl-tooltip" data-mdl-for="option-1">
                                Apenas eu terei acesso
                            </div>
                            <label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="option-2" style="float: left;margin-left: 10px;">
                                <input type="radio" id="option-2" class="mdl-radio__button" name="options" value="2">
                                <span class="mdl-radio__label radio-label">Pública</span>
                            </label>
                        </div>

                        <div style="width: 100%;float: left;margin-top: 5px;" id="divAoSalvar">
                            <label id="acao-salvar">Ação ao salvar :</label>
                            <label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="sobrescrever" style="float: left;margin-left: 10px;">
                                <input type="radio" id="sobrescrever" class="mdl-radio__button" name="aoSalvar" value="sobrescrever" checked  disabled="disabled">
                                <span class="mdl-radio__label radio-label">Sobrescrever</span>
                            </label>

                            <label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="criarNovo" style="float: left;margin-left: 10px;">
                                <input type="radio" id="criarNovo" class="mdl-radio__button" name="aoSalvar" value="criarNovo" disabled="disabled">
                                <span class="mdl-radio__label radio-label">Criar uma nova</span>
                            </label>
                        </div>
                    </center>
                </div>

                <div class="mdl-cell mdl-cell--12-col" style="margin-top:20px;margin-bottom:0px;">
                    <center>
                        <button class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--accent" id="salvar" onclick="parent.checkSession(function(){parent.salvarPesquisa();}, false);" >
                            Salvar
                        </button>
                        <button class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--accent" id="cancelar" onclick="parent.cancelarSalvarPesquisa();">
                            Cancelar
                        </button>
                    </center>
                </div>
            </div>
        </div>
    </body>
</html>
