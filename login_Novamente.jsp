<%-- 
    Document   : login_Novamente
    Created on : 27/11/2008, 08:54:26
    Author     : Vladson Pontes
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">

<script type="text/javascript" src="script/jquery-1.11.2.min.js"></script>

<script type="text/javascript" language="javascript">
       
    function setDefault(){
        if (${param.acao == "iniciar"}) {
            window.location = "UsuarioControlador?acao=iniciarReLogin";
        }
        if (${param.acao == "redirecionarMenu"}) {
            window.close();
        }
        document.formulario.login.value = '<c:out value="${ultLogin}"/>';
        document.formulario.senha.focus();
    }
    
    
            //parei no verificar a quantidade de acessos dento do metodo gerar captcha
            function ajaxCarregarCaptcha(atualiza) {
                atualiza = (atualiza != null && atualiza != undefined ? atualiza : false);
                jQuery("#captcha").val("");
                jQuery("#imgCaptcha").attr("src","");
                jQuery("#trCaptcha").hide();
//                document.form1.imgCaptcha.src = "";
        jQuery.ajax({
            url: "UsuarioControlador?acao=gerarCaptcha", 
            method: 'post',
            success: function(transport){
                try {
                        var trObject = jQuery("#trCaptcha");
                        console.log(transport);
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
            
            
            jQuery(document).ready(function () {
        //colocando o foco no campo de id LOGIN
        jQuery("#senha").focus();
        
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
        window.open('about:blank', 'pop', 'width=200, height=200');
        jQuery("#formulario").submit();
    }
       
</script>
<html>
    <link href="estilo.css" rel="stylesheet" type="text/css">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>JSP Page</title>        
        
    </head>
    <body onload="setDefault();ajaxCarregarCaptcha();">
        <img src="img/banner.gif" width="90%" height="26" align="middle">
        <br><br>
        <form name="formulario" action="./home?acao=relogin" method="post" id="formulario">
            
            <table class="bordaFina" align="center" width="90%">
                <tr>
                    <td colspan="2" class="tabela"> Autenticação do Usuário </td>
                </tr>
                
                <tr>
                    <td align="right">
                        Login:
                    </td>
                    <td align="left">
                        <input class="inputtexto" name="login" type="text" value="" id="login" size="15" maxlength="13" readonly>
                    </td>
                </tr>
                <tr>
                    <td align="right">
                        Senha:
                    </td>
                    <td align="left"align="left">
                        <input class="inputtexto" name="senha" type="password" value="" id="senha" size="15" maxlength="13">
                    </td>
                </tr>
                <tr id="trCaptcha" class="form-group"  style="display: none">
                    <td align="right">Captcha:</td>
                    <td align="left">
                        <input name="captcha" id="captcha" type="text" maxlength="4" size="6" class="inputtexto" />
                        <img alt="Caracteres" src="" id="imgCaptcha" name="imgCaptcha" height="30"/>&nbsp;
                        <img src="img/atualiza.png" id="" onclick="reloadCaptcha();"/>
                    </td> 
                </tr>
                <tr>
                    <td colspan="2" align="center">
                        <input class="inputbotao" name="Button" type="submit"  value="Autenticar" > &nbsp;
                         <input class="inputbotao" name="Button" type="button"  value="Cancelar" onClick="javascript: window.close()">
                    </td>
                </tr>
            </table>
            <br>
        </form>
        
    </body>
</html>

