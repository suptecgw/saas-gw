<%-- 
    Document   : iframe_inscri_estadual_subistituta
    Created on : 23/03/2018, 14:56:56
    Author     : Rodolfo Gomes
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>IE Substituta</title>
        <!--CSS-->
        <link href="${homePath}/gwTrans/consultas/css/style-grid-coleta.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/jquery-ui-min.css" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="${homePath}/assets/css/consulta.css?v=${random.nextInt()}">
        <link href="${homePath}/gwTrans/cadastros/css/estilo-input-form-gw.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/css/estilo_iframe_inscri_estadual_subistituta.css" rel="stylesheet" type="text/css"/>
        <!--JS-->
        <script src="${homePath}/assets/js/jquery-1.9.1.min.js" type="text/javascript"></script>
        <script src="${homePath}/assets/alerts/alerts-min.js" type="text/javascript"></script>
        <jsp:include page="importAlerts.jsp">
            <jsp:param name="caminhoImg" value="${homePath}/assets/img/gw-trans.png"/>
            <jsp:param name="nomeUsuario" value="${param.nomeusuario}"/>
        </jsp:include>
        <script src="${homePath}/script/funcoes.js" type="text/javascript"></script>
        <script language="javascript" src="script/funcoes_gweb.js" type=""></script>
        <script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
        <script src="${homePath}/assets/js/jquery-ui.min.js" type="text/javascript"></script>
        <script src="${homePath}/assets/js/ElementsGW.js" type="text/javascript"></script>
        <script src="${homePath}/script/funcoes_iframe_inscri_estadual_subistituta.js" type="text/javascript"></script>
    </head>
    <body>
        <div class="geral-localizar">
            <div class="topo-localizar">
                <img src="${homePath}/assets/img/logo.png" class="logo">
                <center>
                    <label>Adicionar Inscrição Estadual Substituta</label>
                </center>
                <img src="${homePath}/assets/img/sair.png" class="fechar" title="Sair">
            </div>
            <div class="corpo-localizar">
                <div class="regra" >
                    <div class="envolve-topo">
                        <div class="titulo-add">
                            <img src="img/add.gif" title="Adicionar" id="imgAdd" class="imagemLink"> 
                        </div>
                        <div class="titulos-uf">
                            <label id="lb-uf">UF</label> 
                        </div>
                        <div class="titulos-ie" >
                            <label id="lb-ie">IE substituta</label>
                        </div>  
                    </div>
                    <div class="envolve-dom">
                        <input type="hidden" id="qtdIe" name="qtdIe" value="">
                        <table id="tbl-ie" width="100%" align="center" cellspacing="0" class="bordaFina">
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
                <input type="button" value="Salvar" class="addButton" id="buttonConfirma" onclick="">
            </div>
        </div>
    </body>
</html>
