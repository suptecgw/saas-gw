<%@ page contentType="text/html; charset=ISO-8859-1" language="java" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<LINK REL="stylesheet" HREF="../css/estilo.css" TYPE="text/css">
<script language="javascript" type="text/javascript" src="../script/prototype.js"></script>
<script language="javascript" type="text/javascript" src="../script/funcoes.js"></script>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>Visualização de Imagens</title>
    </head>
    <body>
        <table align="center">
            <tr>
                <td height="500px" width="600px" align="center">
                    <img src="<%=request.getParameter("imagem")%>" id="imagem"/>
                </td>
            </tr>
            <tr align="center">
                <td>
                    
                </td>
            </tr>
        </table>
    </body>
</html>
