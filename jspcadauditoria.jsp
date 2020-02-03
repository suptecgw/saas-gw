<%-- 
    Document   : jspcadauditoria
    Created on : 21/08/2015, 08:36:52
    Author     : danielcassimiro
--%>

<%@page import="nucleo.Apoio"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1" language="java" errorPage=""%>
<!DOCTYPE html>

<%
    //Permissões do usuário
    int nivelUser = Apoio.getUsuario(request).getAcesso("cadconhecimento");
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)){
       this.getServletContext().getRequestDispatcher("/menu").forward(request, response);
    }
    int idCte = Apoio.parseInt(request.getParameter("idConhecimento"));
    boolean isExclusao = Apoio.parseBoolean(request.getParameter("isExclusao"));
    boolean isViagem = Apoio.parseBoolean(request.getParameter("isViagem") != null ? request.getParameter("isViagem") : "false");
    boolean isDespesa = Apoio.parseBoolean(request.getParameter("isDespesa") != null ? request.getParameter("isDespesa") : "false");
    boolean isFatura = Apoio.parseBoolean(request.getParameter("isFatura") != null ? request.getParameter("isFatura") : "false");
%>


<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("builder.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("prototype_1_6.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("funcoes_gweb.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("jquery.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("LogAcoesAuditoria.js")%>" type="text/javascript"></script>
        <script language="javascript" type="text/javascript">
            jQuery.noConflict();

            function pesquisarAuditoria() {
                jQuery('[id^="tr1Log_"],[id^="tr2Log_"]').remove();
                countLog = 0;
                var rotina = "conhecimento";
                
                if ('<%= isExclusao %>' === 'true') {
                    rotina = 'cadvenda';
                    if('<%= isDespesa %>' === 'true'){
                        rotina = 'despesa';
                    }
                    if('<%= isFatura %>' === 'true'){
                            rotina = 'faturas'
                    }
                    if('<%= isViagem %>' === 'true'){
                        rotina = "trips";
                    }
                }
                
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                consultarLog(rotina, '<%= idCte %>', dataDe, dataAte, '<%= isExclusao %>');
            }
            
            function mostrarCampos(imgElement) {
                if (imgElement != null && imgElement != undefined) {
                    var idx = imgElement.id.split("_")[1];
                    var estado = imgElement.src;
                    if (estado.indexOf("plus.jpg") > -1) {
                        visivel($("tr2Log_" + idx));
                        imgElement.src = "img/minus.jpg";
                    } else if (estado.indexOf("minus.jpg") > -1) {
                        invisivel($("tr2Log_" + idx));
                        imgElement.src = "img/plus.jpg";
                    }
                }
            }
            
        </script>
        <title>WebTrans - Auditoria de Conhecimento</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <link rel="stylesheet" href="stylesheets/tabs.css" type="text/css" media="all">
    </head>
    <body>
        <center>
            <img src="img/banner.gif" >
                <table width="88%" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                    <tbody id="tbAuditoriaCabecalho" align="center">
                        <tr>
                            <td colspan="6"  class="tabela" ><div align="center">Auditoria</div></td>
                        </tr>
                        <tr class="celula">
                            <td colspan="3"  align="left">
                                <label for="dataDeAuditoria">Data da Ação:</label>&ApplyFunction;
                                <input type="text" class="fieldDate" id="dataDeAuditoria" maxlength="10" size="10" value="<%=Apoio.getDataAtual()%>" onBlur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)">
                                <label for="dataAteAuditoria"> Até </label>
                                <input type="text" class="fieldDate" id="dataAteAuditoria" maxlength="10" size="10" value="<%=Apoio.getDataAtual()%>" onBlur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)">
                            </td>
                            <td>
                                <input type="button" class="botoes" id="btPesquisarAuditoria" value=" Pesquisar " onclick="tryRequestToServer(function () {
                                            pesquisarAuditoria();
                                        });" >
                            </td>
                            <td colspan="2"  ></td>
                        </tr>
                        <tr class="celula">
                            <td width="3%"></td>
                            <td width="17%">Usuário</td>
                            <td width="15%">Data</td>
                            <td width="15%">Ação</td>
                            <td width="10%">IP</td>
                            <td width="50%"></td>
                        </tr>
                    </tbody>
                    <tbody id="tbAuditoriaConteudo">
                    </tbody>
                    <tr class="CelulaZebra2">
                        <td colspan="6">
                    <center>
                        <input name="fechar" type="button" class="botoes" id="gravar" value=" Fechar " onClick="tryRequestToServer(function(){window.close();});">
                    </center>
                    </td>
                    </tr>
                </table>
        </center>
    </body>
</html>
