<%-- 
    Document   : relfuncaomaritimo
    Created on : 29/07/2015, 08:23:37
    Author     : gilson
--%>

<%@page import="nucleo.Apoio"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>
<!DOCTYPE html>
<%
    boolean temAcesso = (Apoio.getUsuario(request) != null && Apoio.getUsuario(request).getAcesso("cadfuncoes") > 0);

    if ((Apoio.getUsuario(request) == null) || (!temAcesso)) {
        response.sendError(response.SC_FORBIDDEN);
    }

    String acao = (temAcesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));

    if (acao.equals("iniciar")) {
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_FUNCOES_MARITIMO_RELATORIO.ordinal());
    }
%>
<html>
       <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />
        <title>Webtrans - Relat�rio de Fun��es (Mar�timo)</title>
    </head>
       <body onload="AlternarAbasGenerico('tdAbaDinamico', 'tabDinamico');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');" >

        <div align="center"><img src="img/banner.gif"  alt="banner"> <br /></div>

        <table width="90%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Relat&oacute;rio de Fun��es (Mar�timo)</b></td>
            </tr>
        </table>
        <br />
        <table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
            <tr>
                <td>
                    <table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="left">
                        <tr class="tabela" id="">
                            <td style="display: none" id="tdAbaPrincipal" class="menu" onclick="AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');">  Relat�rios Principais  </td>
                            <td id="tdAbaDinamico" class="menu" onclick="AlternarAbasGenerico('tdAbaDinamico', 'tabDinamico');"> Relat�rios Personalizados </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        <div id="tabPrincipal"></div>
        <div id="tabDinamico"></div>
        
    </body>
</html>