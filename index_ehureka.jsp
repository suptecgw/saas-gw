<%@page import="nucleo.Apoio"%>
<!DOCTYPE html>

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

<html lang="en">
<head>
	<meta charset="ISO-8859-1">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>GW Sistemas - Login</title>
        <link rel="icon" type="image/png" href="img/marca.png?v=2" />
	<link rel="stylesheet" href="assets/css/bootstrap.min.css">
	<link rel="stylesheet" href="assets/css/bootstrap.css">
	<link rel="stylesheet" href="assets/css/login.css">
	<link href='http://fonts.googleapis.com/css?family=Didact+Gothic' rel='stylesheet' type='text/css'>
</head>
<body onload="validacoes();ajaxCarregarCaptcha();" class="login">
<div class="container">

	<div id="login-box" class="form-box">

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
                    
                        
                    <form class="form-horizontal form-login" id="form_login" method="post" action="./home">
                            <div id="LabelTextoInformativo" style="color: #FF0000;margin-bottom: 10px" align="center">
                                <%= (request.getParameter("st") == null ? "Informe os dados de usuário" : (request.getParameter("st").equals("3") ? "Erro nos caracteres!" : "Login falhou!") ) %>
                            </div>
                            
			  <div class="form-group">
			    <label for="inputEmail3" class="col-sm-3 control-label">Usuário :</label>
			    <div class="col-sm-12 col-md-12 col-lg-9">
                                <input type="text" placeholder="Digite seu nome de usuário" class="form-control" name="login" id="login">
			    </div>
			  </div>

			  <div class="form-group">
			    <label for="inputPassword3" class="col-sm-3 control-label">Senha :</label>
			    <div class="col-sm-12 col-md-12 col-lg-9">
			      <input type="password" class="form-control" id="inputPassword3" placeholder="Digite sua senha" name="senha">
			    </div>
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
                              
                              
			      <!--<a type="submit" class="forget">Esqueci a senha</a>-->
			      <p class="help-block">Versão: </p>
			    </div><!--col-sm-offset-3-->
			  </div><!--desktop-->

			  <div class="form-group tablet">
			    <div class="col-sm-12">
			      <a type="submit" class="login" href="javascript: submit();">Entrar</a>
			      <!--<a type="submit" class="forget">Esqueci a senha</a>-->
                              
                              
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

		<img src="assets/img/icones_login.png" alt="" class="img-login">

	</div><!--form-box-->
</div><!--container-->

<!-- Bootstrap core JavaScript
================================================== -->
<!-- Placed at the end of the document so the pages load faster -->
<script src="assets/js/jquery-1.9.1.min.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.js" type="application/javascript"></script>
<script src="assets/js/bootstrap.min.js" type="application/javascript"></script>
<script src="assets/js/docs.min.js" type="application/javascript"></script>
<!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
<script src="assets/js/ie10-viewport-bug-workaround.js" type="application/javascript"></script>
<script>

    if (${param_relogar == true} ) {
        window.close();
    }

    jQuery.noConflict();
    
    function validacoes() {
        
        var std = "${param.st}";
        console.log("ST = " + std)
        if (std == "2") {
            jQuery("#msgErro").text("Falha na autenticação: Login ou senha incorretos");
        }
      
    }
    
    jQuery(document).ready(function () {
        //colocando o foco no campo de id LOGIN
        jQuery("#login") .focus();
        
        //colocando o evento de apertar ENTER(keycode = 13) para submeter(logar) em todos os input TEXTO
        jQuery("input[type=text]").keyup(function (e){
            if (e.keyCode == 13) {
                submit();
            }
        });
        
        //colocando o evento de apertar ENTER(keycode = 13) para submeter(logar) em todos os input SENHA
        jQuery("input[type=password]").keyup(function (e){
            if (e.keyCode == 13) {
                submit();
            }
        });
        
        //futuros códigos:
        
        jQuery(".help-block").text("Versão: ${VERSAO}");
        
        
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
