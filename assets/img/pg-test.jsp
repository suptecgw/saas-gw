<%-- 
    Document   : pg-test
    Created on : 06/11/2016, 23:47:59
    Author     : 30porcento
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
    <jsp:include page="/importAlerts.jsp">
        <jsp:param name="caminhoImg" value="img/gw-sistemas.png"/>
        <jsp:param name="nomeUsuario" value="Usuário"/>
    </jsp:include>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <script src="js/jquery.js" type="text/javascript"></script>
    </head>
    <body>
        <script>
            function abrir() {
                if (document.getElementById('iframeChat').style.height === '440px') {
                    jQuery(document.getElementById('iframeChat')).animate({
                        'height': '28px'
                    });
                } else {
                    jQuery(document.getElementById('iframeChat')).animate({
                        'height': '440px'
                    });
                }
            }
            
            var aceitouSair = false;
            function sair(){
                aceitouSair = true;
            }
            
            function getAceitouSair(){
                return aceitouSair;
            }

            function isAberto() {
                if (document.getElementById('iframeChat').style.height === '440px' || document.getElementById('iframeChat').style.height === '450px') {
                    return true;
                } else {
                    return false;
                }
            }

            function isMaxminizado() {
                if (document.getElementById('iframeChat').style.height === '450px') {
                    return true;
                } else {
                    return false;
                }
            }

            function minimizar() {
                jQuery(document.getElementById('iframeChat')).animate({
                    'height': '28px',
                    'width': '290px'
                });
            }

            function maxminizar() {
                jQuery(document.getElementById('iframeChat')).animate({
                    'width': '500px'
                }, 300, function () {
                    jQuery(document.getElementById('iframeChat')).animate({
                        'height': '450px'
                    });
                });
            }

            function restaurar() {
                jQuery(document.getElementById('iframeChat')).animate({
                    'width': '290px'
                }, 300, function () {
                    jQuery(document.getElementById('iframeChat')).animate({
                        'height': '440px'
                    });
                });
            }

        </script>
        <iframe id="iframeChat" src="http://54.94.238.154:8080/chat/login-cliente" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" style="box-shadow: 0px 0px 1px 1px rgba(0,0,0,0.3);position: absolute;bottom: 0;right: 30%;z-index: 9999999;width: 290px;height: 28px;border-radius: 7px 7px 0 0;"></iframe>
        <!--<embed src="http://192.168.0.124:8080/gwChat/login-cliente" id="embedChat" style="box-shadow: 0px 0px 2px 2px rgba(0,0,0,0.75);position: absolute;bottom: 0;right: 10%;z-index: 9999999999;width: 260px;height: 28px;border-radius: 7px 7px 0 0;">-->
        <!--<embed src="http://192.168.15.10:8084/gwChat/modelo-chat.jsp" id="embedChat" style="box-shadow: 0px 0px 2px 2px rgba(0,0,0,0.75);position: absolute;bottom: 0;right: 30%;z-index: 9999999999;width: 290px;height: 28px;border-radius: 7px 7px 0 0;">-->
    </body>
</html>
