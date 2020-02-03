<%-- 
    Document   : agrupar_mdfe
    Created on : 16/10/2017, 15:49:54
    Author     : anderson
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
    <head>
        <link href="${homePath}/gwTrans/consultas/css/style-grid-coleta.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="${homePath}/gwTrans/consultas/css/consulta-manifesto.css?v=${random.nextInt()}">
        <script src="${homePath}/script/jQuery/jquery.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/assets/alerts/alerts-min.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/script/funcoes.js" type="text/javascript"></script>
        <script src="${homePath}/gwTrans/consultas/js/agrupar_mdfe.js" type="text/javascript"></script>
        <link href="${homePath}/gwTrans/consultas/css/agrupar_mdfe.css" rel="stylesheet" type="text/css"/>


        <jsp:include page="importAlerts.jsp">
            <jsp:param name="caminhoImg" value="${homePath}/assets/img/gw-trans.png"/>
            <jsp:param name="nomeUsuario" value="${param.nomeusuario}"/>
        </jsp:include>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    </head>
    <body>
        <div class="geral-localizar">
            <div class="topo-localizar">
                <img src="${homePath}/assets/img/logo.png" class="logo">
                <center>
                    <label>Agrupar manifestos</label>
                </center>
                <img src="${homePath}/assets/img/sair.png" class="fechar" title="Sair">
            </div>
            <div class="corpo-localizar">
                <div class="regra">
                    <div class="divPrincipal">
                        <input type="hidden" name="idsAgrupar" id="idsAgrupar" value="">
                        <table class="tabela-gwsistemas ui-sortable ui-sortable-disabled" class="tableAgrup" id="tabelaManifestos">
                            <thead>
                                <tr>
                                    <th class="rowHead">Principal</th>
                                    <th class="rowHead">Nº Manif</th>
                                    <th class="rowHead">Data</th>
                                    <th class="rowHead">Série</th>
                                    <th class="rowHead">Cidade/UF Destino</th>
                                    <th class="rowHead">Status</th>
                                </tr>
                            </thead>
                        </table>
                    </div>
                </div>
            </div>
            <div class="paginacao">
                <center>
                    <button class="buttonAgruparMDFE confirmButton" id="buttonConfirma">Confirmar</button>
                </center>
            </div>
        </div>
        <script type="text/javascript">
            carregarJaAgrupados('${param.idPrincipal}', '${homePath}');
        </script>
    </body>
</html>
