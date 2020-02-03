<%-- 
    Document   : redireciona_relatorio
    Created on : 26/08/2009, 09:23:00
    Author     : Administrador
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>JSP Page</title>
        <script language='JavaScript'  src='script/jquery.js' type='text/javascript'></script>
        <script language='JavaScript'  src='script/shortcut.js' type='text/javascript'></script>
        <script language='JavaScript'  src='script/prototype.js' type='text/javascript'></script>
        <script type='text/javascript'>

            jQuery.noConflict();

            var bClose = false;
            function confirma_sair(e){
                if (!bClose)
                    ajaxConexao()
            }


            function ajaxConexao(){
                // new Ajax.Request('./ExporterReports?acao=derrubarSessionConexao', { method:'get' });
            }
            
            function init(){
                window.onbeforeunload = confirma_sair;
            }

            jQuery(document).ready(function(){
                jQuery('a').click(function()
                {
                    jQuery('body').removeAttr('onbeforeunload','');
                });
            });

            shortcut.add('F5', function()
            {
                jQuery('body').removeAttr('onbeforeunload','');
                history.go(0);
                return false;
            });

            init();

        </script>

        <style type="text/css">
            <%-- Faz o iframe pegar toda a página --%>
            body, html {
                margin: 0;
                padding: 0;
                height: 100%;
                overflow: hidden;
            }

            #content {
                position: absolute;
                left: 0;
                right: 0;
                bottom: 0;
                top: 0;
            }
        </style>
    </head>


    <body>
        <div id="content">
            <iframe src="${param.url}" width="100%" height="100%" frameborder="0"></iframe>
        </div>
    </body>
</html>
