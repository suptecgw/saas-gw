<%@page contentType="text/html; charset=iso-8859-1" language="java" session="false"
        import="nucleo.Apoio"%>

<% //se existir uma sessão aberta então ele redireciona
    if (Apoio.getUsuario(request) != null) {
        response.sendRedirect("./menu");
    }
%>  



<html>     
    <head>   
        <link rel="icon" type="image/png" href="img/marca.png?v=2" />
        <script language="javascript" src="script/funcoes.js" type=""> </script> 
        <title>WebTrans - Sistema de automação para transportadoras online</title>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <META HTTP-EQUIV="Pragma-directive" CONTENT="no-cache"/>
        <META HTTP-EQUIV="cache-directive" CONTENT="no-cache"/>
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />
        <META content=Global name=distribution />
        <script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
        <script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
        <script language="JavaScript" src="script/jquery.js" type="text/javascript"></script>
        <script language="javascript">
            jQuery.noConflict();
            //parei no verificar a quantidade de acessos dento do metodo gerar captcha
            function ajaxCarregarCaptcha(atualiza) {
                atualiza = (atualiza != null && atualiza != undefined ? atualiza : false);
                document.form1.captcha.value = "";
                document.form1.imgCaptcha.src = "";
                new Ajax.Request("home?acao=gerarCaptcha", {method: 'post',
                    onSuccess: e,
                    onFailure: e
                });

                function e(transport) {
                    try {
                        console.log(transport);
                        var trObject = $("trCaptcha");
                        if (transport != null && transport.responseText != "") {
                            if (transport.responseText.indexOf("ERRO") > -1) {
                                alert(transport.responseText);
                                espereEnviar("Aguarde...", false);
                                return false;
                            } else {
                                var imgCaptcha = replaceAll(transport.responseText, "\\", "");
                                if (imgCaptcha != "") {
                                    visivel(trObject);
                                    document.form1.imgCaptcha.src = imgCaptcha;
                                }

                                espereEnviar("Aguarde...", false);
                                if (atualiza) {
                                    document.form1.imgCaptcha.src = "";
                                    document.location.reload();
                                }
                            }
                        }
                    } catch (e) {
                        alert(e);
                    }
                }
            }
            
            function reloadCaptcha(){
                $("imgCaptcha").src = "";
                document.location.reload();
            }
        </script>
    </head>

    <link href="estilo.css" rel="stylesheet" type="text/css">
    <style type="text/css">
        <!--
        .style3 {font-size: 9px}
        .erro {color: #FF0000}
        -->
    </style>

    <body onLoad="javascript:document.form1.login.focus();ajaxCarregarCaptcha();">
        <!--<body onLoad="javascript:document.form1.login.focus();">-->
        <!--
        <a class="twitter-timeline"  href="https://twitter.com/gwsistemas" data-widget-id="247164441249054721">Tweets de @gwsistemas</a>
            <script>
                !function(d,s,id){
                    var js,fjs=d.getElementsByTagName(s)[0];
                    if(!d.getElementById(id)){
                        js=d.createElement(s);
                        js.id=id;
                        js.src="//platform.twitter.com/widgets.js";
                        fjs.parentNode.insertBefore(js,fjs);
                    }
                }
                (document,"script","twitter-wjs");
            </script>
        -->

        <div  id="cortina" style="display:none; top:0; left:0;   position:absolute; width:100%; height:100%; 
              background-color:#000000; filter:alpha(opacity=15); opacity:0.2; " align="center">
        </div>


        <img src="img/banner.gif"  alt=""><br>
        <br>
        <br>
        <br>
        <h3>Autenticação do Sistema</h3>
        <form name="form1" method="post" action="./home">
            <table width="253" align="center" class="bordaFina">
                <tr>
                    <td class="tabela"><center>
                        <%=(request.getParameter("st") == null ? "Informe os dados de usuário" : (request.getParameter("st").equals("3") ? "<div class=erro>Erro nos caracteres!<div>" : "<div class=erro>Login falhou!<div>") )%>
                </center>
                </td>
                </tr>
            </table>
            <table width="253" height="77" align="center" cellspacing="1" class="bordaFina">
                <tr>
                    <td width="70" height="22" class="TextoCampos">Login: </td>
                    <td width="154" height="22" class="CelulaZebra2" >
                        <input name="login" type="text" id="login" size="17" maxlength="30" class="inputtexto"></td>
                </tr>
                <tr>
                    <td height="24" class="TextoCampos" >Senha: </td>
                    <td class="CelulaZebra2" >
                        <input name="senha" type="password" id="senha" size="17" maxlength="13" class="inputtexto">
                    </td>
                </tr>
                <tr>
                </tr>
                <tr id="trCaptcha" style="display: none">
                    <td width="20%" class="TextoCampos">Captcha:</td>                        
                    <td width="30%" class="TextoCampos">
                        <input name="captcha" id="captcha" type="text" maxlength="4" size="6" class="inputtexto" />
                        <img alt="Caracteres" src="" id="imgCaptcha" name="imgCaptcha" height="30"/>
                        <img src="img/atualiza.png" id="" onclick="reloadCaptcha();"/>
                    </td> 
            <!--<td width=""><label style="color: red ">${param.erro}</label></td>--> 
                </tr>
                <tr class="CelulaZebra2">
                    <td height="22" colspan="2">
                <center>
                    <input name="Button" type="submit" class="botoes" value="Autenticar">
                    <input name="Button" type="button" class="botoes" value="Cancelar" onClick="javascript: window.close()">
                </center></td>
                </tr>                
            </table>
        </form>
        <!--
       <h2>Atenção! Seu link de acesso mudou para:</h2>
       <h2><a style="font-size: 20px" href="http://cloud4.gwcloud.com.br/wt-dinamo/">http://cloud4.gwcloud.com.br/wt-dinamo/</a></h2>
        -->
        Vers&atilde;o <%=Apoio.WEBTRANS_VERSION%><br>  
        <a target="_blank" href="https://www.facebook.com/gwsistemas"><img src="img/curta_nossa_pagina_face.png" height="80px" width="200px"/></a>
        <br><br><br><label><%=(request.isSecure() ? "Site seguro - Transmissão criptografada" : "")%></label>
    </body>

</html>

