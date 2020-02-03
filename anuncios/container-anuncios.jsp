<%-- 
    Document   : container-anuncios
    Created on : 20/01/2017, 09:01:04
    Author     : root
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>GW - Anúncios</title>
        <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${param.tema}.css?v=${random.nextInt()}">
        <script type='text/javascript' src="${homePath}/assets/js/jquery-1.9.1.min.js?v=${random.nextInt()}"></script>
       
        <script>
            function clickNovidade(numero){
                parent.clickNovidade(numero);
            }
        </script>
        <link href="css-anuncios/container-anuncios.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
    </head>
    <body>
        <header>
            <img src="${homePath}/assets/img/logo.png">
            <img src="${homePath}/assets/img/sair.png" onclick="parent.fecharAnuncio();">
        </header>
        <section>
            <c:choose>
                <c:when test="${param['htmlAnuncio'].startsWith('http')}">
                    <object data="${param['htmlAnuncio']}" width="100%" height="100%">
                        <embed src="${param['htmlAnuncio']}" width="100%" height="100%">
                    </object>
                </c:when>
                <c:otherwise>
                    <object data="${homePath}/${param['htmlAnuncio']}" width="100%" height="100%">
                        <embed src="${homePath}/${param['htmlAnuncio']}" width="100%" height="100%">
                    </object>
                </c:otherwise>
            </c:choose>
        </section>
        <footer>
            <span class="btn-entendi" onclick="parent.salvarAcao('${param.idAnuncio}');">Ok, entendi</span>
        </footer> 
    </body>
</html>
