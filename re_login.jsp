<%-- 
    Document   : re_login
    Created on : 31/10/2016, 08:48:50
    Author     : marcus
--%> 

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="ISO-8859-9"%>
<!DOCTYPE html>
<html>
    <head>
        <jsp:include page="importAlerts.jsp">
            <jsp:param name="caminhoImg" value="assets/img/gw-trans.png"/>
            <jsp:param name="nomeUsuario" value="${user.nome}"/>
        </jsp:include>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-9">
        <title>Gw Sistemas | Re-login</title>
        <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
        <script src="assets/js/jquery-1.9.1.min.js" type="text/javascript"></script>
        <script src="assets/js/material.js" type="text/javascript"></script>
        <link href="assets/css/material.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/re-login.css" rel="stylesheet" type="text/css"/>
        <script>
            <c:if test="${param.acao == 'logado'}">
            parent.document.getElementById("divGeral").style.display = 'none';
            parent.document.getElementById("cortina").style.display = 'none';

            </c:if>

            <c:if test="${param.acao == 'errouSenha'}">
            parent.chamarAlert("A senha está incorreta, tente novamente");
            </c:if>

            <c:if test="${!param.isMenu && param.captcha}">
            parent.chamarAlert('Você errou a senha 3 vezes, a tela será fechada.', fecharTela);
            </c:if>

            <c:if test="${param.isMenu && param.captcha}">
            parent.chamarAlert('Você errou 3 vezes a senha, você será redirecionado para tela de login.', redirecionarLogin);
            </c:if>

            /**
             * Redirecionar
             */
            function fecharTela() {
                parent.window.close();
            }

            function redirecionar() {
                parent.chamarConfirmeReLogin('O que deseja fazer?', redirecionarLogin, permanecerPagina);
            }

            function redirecionarLogin() {
                parent.location = 'login';
            }

            function permanecerPagina() {
                parent.document.getElementById("divGeral").style.display = 'none';
                parent.document.getElementById("cortina").style.display = 'none';
            }

            function autenticar() {
                jQuery('.mdl-button--accent').hide();
                jQuery('#senha').hide();
                var pForm = document.createElement("FORM");
                pForm.appendChild(document.getElementById("login"));
                pForm.appendChild(document.getElementById("senha"));
                pForm.action = "./home?textmode=1&semPopUp=true&isMenu=" + '${param.isMenu}';
                pForm.method = "POST";
                pForm.id = "forumulario";
                document.body.appendChild(pForm);
                pForm.submit();
            }

            jQuery(document).ready(function () {
                jQuery("#senha").keypress(function (event) {
                    if (event.which == 13) {
                        event.preventDefault();
                        autenticar();
                    }
                });
                
                
                if (navigator.appVersion.indexOf('Chrome/5') !== -1) {
                    setTimeout(function(){
                        jQuery('#senha').val('0');
                        jQuery('#senha').val('');
                        jQuery('#senha').attr('autocomplete','off');
                    },200);
                }
                
                jQuery('#senha').focus();
                if (jQuery('#login').val().trim() === '') {
                    var ultLogin = sessionStorage.getItem('ultimoLogin');
                    jQuery('#login').val(ultLogin);
                    jQuery('.ultimoLogin').html(ultLogin);
                }
            });

        </script>
    </head>
    <body>
        <div class="container-re-login">
            <div class="topo-re-login">
                <img src="assets/img/logo.png" alt="" class="logo"/>
                <!--<img src="${homePath}/img/usuario/usuario1/perfil_usuario_1_1.png" class="perfil">-->
            </div>
            <div class="mdl-grid" style="float: left;">
                <div class="mdl-cell mdl-cell--12-col">
                    <center>
                        <label class="lb-autenticacao">Autenticação do Usuário</label>
                    </center>
                    <center>
                        <div class="div-usu-logado">
                            <label>Usuário logado: <b class="ultimoLogin">${ultLogin}</b></label>
                        </div>
                        <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label" style="width: 90%;display: none;">
                            <input class="mdl-textfield__input" type="text" id="login" name="login" value="${ultLogin}" style="color:#13385C">
                            <label class="mdl-textfield__label" for="login">Digite login</label>
                        </div>
                        <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label" style="width: 90%;">
                            <input class="mdl-textfield__input" type="password"id="senha" name="senha" style="color:#13385C">
                            <label class="mdl-textfield__label" for="senha">Digite a senha</label>
                        </div>
                    </center>
                </div>
                <div class="mdl-cell mdl-cell--12-col" style="margin-top:0px;margin-bottom:0px;">
                    <center>
                        <button class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--accent" style="background: #13385C;font-size: 11px !important;" onclick="autenticar();">
                            Autenticar
                        </button>
                        <button class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--accent" style="background: #13385C;font-size: 11px !important;" onclick="redirecionar();">
                            Cancelar
                        </button>
                    </center>
                </div>
            </div>
        </div>
    </body>
</html>
