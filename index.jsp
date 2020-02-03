<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="nucleo.Apoio"%>
<!DOCTYPE html>
<html lang="en">
<% //se existir uma sessão aberta então ele redireciona
    //explicando o que ocorre abaixo:
    // validando relogin = o parametro param_relogar vem do servletAPP quando a ação é RELOGIN executada pela tela de loginnovamente
    // se for nulo significa que não é relogin, então irá continuar como era antes.
    // pois ele estava abrindo o pop-up e o deixava aberto. existe também a validação JS mais abaixo, basta pesquisar "param_relogar"
    boolean validandoRelogin = request.getAttribute("param_relogar") != null ? Apoio.parseBoolean(request.getAttribute("param_relogar").toString()) : false;
    if (validandoRelogin) {        
    }else if (Apoio.getUsuario(request) != null) {
        response.sendRedirect("./menu");
    }

    request.setAttribute("VERSAO", Apoio.WEBTRANS_VERSION);
%>  
    <head>
        <meta name="robots" content="noindex">
        <meta name="googlebot" content="noindex">
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
	<title>GW Sistemas - Login</title>
        <link rel="stylesheet" href="assets/css/bootstrap.min.css">
        <link rel="stylesheet" href="assets/css/bootstrap.css">
        <link rel="stylesheet" href="assets/css/login.css">
        <link href='http://fonts.googleapis.com/css?family=Didact+Gothic' rel='stylesheet' type='text/css'>
        <style>
            .mostrar-senha{
                position: absolute;
                right: 9px;
                top: 102px;
                width: 28px;
                opacity: 0.4;
            }
        </style>
        <script>
            var homePath = '${homePath}';
        </script>
        <script src="${homePath}/assets/alerts/alerts-min.js" type="text/javascript"></script>
        <jsp:include page="/importAlerts.jsp">
            <jsp:param name="caminhoImg" value="assets/img/gw-trans.png"/>
            <jsp:param name="nomeUsuario" value="${param.nomeUsuario}"/>
        </jsp:include>
    </head>
    <body class="login_auth" onload="validacoes();ajaxCarregarCaptcha();" ondragstart='return false'>

        <div class="container">

            <img src="assets/img/topo_login.png" id="topo_login">

        </div><!--container-->

        <div id="container_login">

            <div class="container">

                <div id="login-box">

                    <div class="form-box-header">

                        <h1>
                            <a href="#">
                                <img src="assets/img/logo.png">
                            </a>
                        </h1>

                        <ul class="form-box-header-links">
                            <li><a href="http://www.gwsistemas.com.br/" target="_blank"><img src="assets/img/globo.png" alt=""></a></li>
                            <li><a href="https://www.facebook.com/gwsistemas" target="_blank"><img src="assets/img/facebook.png" alt=""></a></li>
                        </ul>

                    </div><!--form-box-header-->

                    <div class="form-box-body">

                        <form class="form-horizontal form-login" method="post" id="form_login" action="./home">
                            <div id="LabelTextoInformativo" style="color: #FF0000;margin-bottom: 10px" align="center">
                                <c:choose>
                                    <c:when test="${param.st == null}">
                                        Informe os dados de usuário
                                    </c:when>
                                    <c:when test="${param.st == '3'}">
                                        Erro nos caracteres!
                                    </c:when>
                                    <c:when test="${param.st == '001'}">
                                        Seu IP não está autorizado para acesso.
                                    </c:when>
                                    <c:when test="${param.st == '004'}">
                                        Por questões de segurança a sua senha deverá ser renovada.
                                    </c:when>
                                    <c:otherwise>
                                        Login falhou!
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            
                            <input type="hidden" name="ip" id="ip" value="">
                            <input type="hidden" name="cidade" id="cidade" value="">
                            <input type="hidden" name="estado" id="estado" value="">
                            <input type="hidden" name="operadora" id="operadora" value="">
                            <input type="hidden" name="lat" id="lat" value="">
                            <input type="hidden" name="lon" id="lon" value="">
                            
                            <div class="form-group">
                                <label for="login" class="col-sm-3 control-label">Usuário :</label>
                                <div class="col-sm-12 col-md-12 col-lg-9">
                                    <input type="text" placeholder="Digite seu nome de usuário" class="form-control" name="login" id="login">
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="inputPassword3" class="col-sm-3 control-label">Senha :</label>
                                <div class="col-sm-12 col-md-12 col-lg-9">
                                    <input type="password" class="form-control" id="inputPassword3" placeholder="Digite sua senha" name="senha">
                                </div>
                                <img src="${homePath}/img/mostrar-senha.png" style="" class="mostrar-senha">
                            </div>
                          <div id="trCaptcha" class="form-group" style="display: none">
                                <label class="col-sm-3 control-label">Captcha:</label>
                                <div class="col-sm-12 col-md-12 col-lg-9">
                                    <input name="captcha" id="captcha" type="text" maxlength="4" size="6" class="form-control" placeholder="Digite os Caracteres" style="width: 60%;float: left;margin-right: 5px"/>
                                    <img alt="Caracteres" src="" id="imgCaptcha" name="imgCaptcha" height="25"/>
                                    <img src="img/atualiza.png" id="" onclick="reloadCaptcha();"/>
                                </div>
                          </div>

                            <div class="form-group desktop">
                                <div class="col-sm-offset-3 col-sm-8">
                                    <a type="submit" class="login" href="javascript: submit();">Entrar</a>
                                    <p class="help-block">Versão: </p>
                                </div><!--col-sm-offset-3-->
                            </div><!--desktop-->

                            <div class="form-group tablet">
                                <div class="col-sm-12">
                                    <a type="submit" class="login" href="javascript: submit();">Entrar</a>
                                    <p class="help-block">Versão: </p>
                                </div>
                            </div><!--tablet-->
                        </form><!--form-horizontal form-login-->
                    </div><!--form-box-body-->

                    <div class="form-box-footer">

                        <div class="main-footer-box-form tablet">
                            <ul>
                                <li><a href="http://www.gwsistemas.com.br/" target="_blank"><img src="assets/img/globo.png" alt=""></a></li>
                                <li><a href="https://www.facebook.com/gwsistemas" target="_blank"><img src="assets/img/facebook.png" alt=""></a></li>
                            </ul>
                        </div><!--main-footer-box-form tablet-->

                    </div><!--form-box-footer-->

                </div><!--form-box-->

            </div>
        </div>
        <%--<jsp:include page="pops/alterarSenha.jsp" />--%>

        <!-- Bootstrap core JavaScript
        ================================================== -->
        <!-- Placed at the end of the document so the pages load faster -->
        <script src="assets/js/jquery-1.9.1.min.js"></script>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
        <script src="assets/js/bootstrap.min.js" type="application/javascript"></script>
        <script src="assets/js/docs.min.js"></script>
        <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
        <script src="assets/js/ie10-viewport-bug-workaround.js"></script>
        
    <jsp:include page="/pops/alterarSenha.jsp" />
        
    <script>
        
        jQuery('.mostrar-senha').each(function(){
            jQuery(this).on('mousedown touchstart', function(){
                jQuery('#inputPassword3').prop('type','text');            
            });

            jQuery(document).on('mouseup touchend',function(){
                jQuery('#inputPassword3').prop('type','password');            
            });
        });


        if (${param_relogar == true} ) {
            window.close();
        }

        jQuery.noConflict();

        function validacoes() {
            // a chamada abaixo é necessária para que não sobreponha os campos de login/senha da tela;
            jQuery(".div-mudar-senha").css("display", "none");

            var std = "${param.st}";
            console.log("ST = " + std)
            if (std == "2") {
                jQuery("#msgErro").text("Falha na autenticação: Login ou senha incorretos");
            }else if (std == "004") {
                alterarSenha();
            }

        }

        jQuery(document).ready(function () {
            //colocando o foco no campo de id LOGIN
            jQuery("#login").focus();

            //colocando o evento de apertar ENTER(keycode = 13) para submeter(logar) em todos os input TEXTO
            jQuery("#login, #inputPassword3").keyup(function (e){
                if (e.keyCode == 13) {
                    submit();
                }
            });

            //futuros códigos:

            jQuery(".help-block").text("Versão: ${VERSAO}");
            
            jQuery.ajax({
                url: "http://ip-api.com/json/",
                success: function (data, textStatus, jqXHR) {
                    try{
                        jQuery('#ip').val(data.query);
                        jQuery('#cidade').val(data.city);
                        jQuery('#estado').val(data.region);
                        jQuery('#operadora').val(data.org);
                        jQuery('#lat').val(data.lat);
                        jQuery('#lon').val(data.lon);
                        console.log(data);
                    }catch(ex){
                        console.info('Erro ao tentar capturar dados!');
                    }
                }
            })

        });



        function submit(){
           jQuery("#form_login").submit();
        }


                //parei no verificar a quantidade de acessos dento do metodo gerar captcha
                function ajaxCarregarCaptcha(atualiza) {
                    atualiza = (atualiza != null && atualiza != undefined ? atualiza : false);
                    jQuery("#captcha").val("");
                    jQuery("#imgCaptcha").attr("src","");
                    jQuery("#trCaptcha").hide();
    //                document.form1.imgCaptcha.src = "";
            jQuery.ajax({
                url: "home?acao=gerarCaptcha", 
                method: 'post',
                success: function(transport){
                    try {

                            var trObject = jQuery("#trCaptcha");
                            if (transport != null) {
                                if (transport.indexOf("ERRO") > -1) {
                                    alert(transport);
    //                                espereEnviar("Aguarde...", false);
                                    return false;
                                } else {
    //                                var imgCaptcha = replaceAll(transport.responseText, "\\", "");
                                    var imgCaptcha = transport;
                                    if (imgCaptcha != "") {
                                        jQuery(trObject).show();
                                        console.log(imgCaptcha);
                                        jQuery("#imgCaptcha").attr("src",imgCaptcha);
                                    }

    //                                espereEnviar("Aguarde...", false);
                                    if (atualiza) {
                                        jQuery("#imgCaptcha").attr("src", "");
                                        document.location.reload();
                                    }
                                }
                            }
                        } catch (e) {
                            alert(e);
                        }
                    }
            });
                }

                function reloadCaptcha(){
                    jQuery("imgCaptcha").src = "";
                    document.location.reload();
                }
                
    </script>
    </body>
</html>