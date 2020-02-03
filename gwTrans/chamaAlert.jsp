<%-- 
    Document   : chamaAlert
    Created on : 02/06/2017, 09:15:19
    Author     : estagiario_manha
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
    <head>
        <script src="${homePath}/script/jQuery/jquery.js" type="text/javascript"></script>
        <script src="${homePath}/assets/alerts/alerts-min.js" type="text/javascript"></script>
        <jsp:include page="/gwTrans/consultas/importAlerts.jsp">
            <jsp:param name="caminhoImg" value="assets/img/gw-trans.png"/>
            <jsp:param name="nomeUsuario" value="${user.nome}"/>
        </jsp:include>
        <meta charset="ISO-8859-1">
        <meta name="viewport" content="width=device-width">
        <title>Alerta</title>
        <link href="${homePath}/assets/css/jquery-ui-min.css" rel="stylesheet" type="text/css"/>
        <script src="${homePath}/assets/js/jquery-ui.min.js" type="text/javascript"></script>
        <script defer src="${homePath}/assets/js/jquery.mask.min.js"></script>
        <script>
            jQuery(document).ready(function () {
                if (${msg != null && msg != undefined && msg != ""}) {
                    chamarAlert('${msg}', redirecionar);
                } else {
                    window.opener.location = '${link}';
                    window.close();
                }
            });
            function redirecionar() {
                if (${link != null && link != undefined && link != ""}) {
                    window.location.href = '${link}';
                } else {
                    window.close();
                }
            }
        </script>
    </head>
    <body>
    </body>
</html>
