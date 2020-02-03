<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="nucleo.BeanConfiguracao,
         java.text.*,
         java.util.Date, 
         nucleo.Apoio" errorPage="" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>

<% boolean temacesso = (Apoio.getUsuario(request) != null
            && Apoio.getUsuario(request).getAcesso("cadarea") > 0);
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (!temacesso)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    //fim da MSA

    String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));

    //exportacao da Cartafrete para arquivo .pdf
    if (acao.equals("exportar")) {

        String opcoes = "";
        opcoes = (request.getParameter("area") == null || request.getParameter("area").equals("") ? "" : " Apenas a área: " + request.getParameter("area"));

        java.util.Map param = new java.util.HashMap(1);

        param.put("AREA", (request.getParameter("area_id").equals("0") ? "" : " WHERE ar.id = " + request.getParameter("area_id")));
        param.put("OPCOES", opcoes);
        param.put("USUARIO", Apoio.getUsuario(request).getNome());
        request.setAttribute("map", param);
        request.setAttribute("rel", "areasmod" + request.getParameter("modelo"));

    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
    dispacher.forward(request, response);
    } else if (acao.equals("iniciar")) {
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_AREA_CIDADE_RELATORIO.ordinal());
    }

%>


<script language="javascript" type="text/javascript">

    function modelos(modelo) {
        getObj("modelo1").checked = false;

        getObj("modelo" + modelo).checked = true;
    }

    function popRel() {
        var modelo;
        if ($("modelo1").checked)
            modelo = 1;
        var impressao;
        if ($("pdf").checked)
            impressao = "1";
        else if ($("excel").checked)
            impressao = "2";
        else
            impressao = "3";

        launchPDF('./relareas.jsp?acao=exportar&modelo=' + modelo + '&impressao=' + impressao + '&' + concatFieldValue("area_id,area"));
    }

</script>

<%@page import="nucleo.BeanLocaliza"%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>Webtrans - Relatório de Áreas</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onload="AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');
        aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');">
        <input type="hidden" name="area_id" id="area_id" value="0">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
        </div>
        <table width="90%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Relat&oacute;rio de &Aacute;reas e cidades</b></td>
            </tr>
        </table>
        <br>
        <table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
            <tr>
                <td>
                    <table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="left">
                        <tr class="tabela" id="">
                            <td id="tdAbaPrincipal" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');"> <center> Relatórios Principais </center></td>
                            <td id="tdAbaDinamico" class="menu" onclick="AlternarAbasGenerico('tdAbaDinamico', 'tabDinamico');"> Relatórios Personalizados </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>

<div id="tabPrincipal">
    <table width="90%" border="0" class="bordaFina" align="center">
        <tr class="tabela"> 
            <td colspan="3"><div align="center">Modelos</div></td>
        </tr>
        <tr> 
            <td width="50%" height="24" class="TextoCampos"> <div align="left"> 
                    <input name="modelo1" id="modelo1" type="radio" value="1" checked onClick="javascript:modelos(1);">
                    Modelo 1</div></td>
            <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das &aacute;reas e suas cidades </td>
        </tr>
        <tr>
            <td height="24" colspan="3" class="tabela"><div align="center">Filtros</div></td>
        </tr>
        <tr> 
            <td width="23%" height="24" class="TextoCampos">Apenas a &aacute;rea: </td>
            <td width="77%" colspan="2" class="CelulaZebra2"><strong>
                    <input name="area" type="text" id="area" class="inputReadOnly" value="" size="35" maxlength="80" readonly="true">
                    <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." 
                           onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.AREA%>', 'Area')">
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar àrea" 
                         onClick="javascript:$('area_id').value = '0';
                                     javascript:$('area').value = '';"></strong></td>
        </tr>
        <tr>
            <td colspan="3" class="tabela"><div align="center">Formato do relat&oacute;rio </div></td>
        </tr>
        <tr>
            <td colspan="3" class="TextoCampos"><div align="center">
                    <input type="radio" name="impressao" id="pdf" value="1" checked/>
                    <img src="./img/pdf.gif" width="19" height="20" style="vertical-align: middle">
                    <input type="radio" name="impressao" id="excel" value="2" />
                    <img src="./img/excel.gif" width="20" height="19"  style="vertical-align: middle">
                    <input type="radio" name="impressao" id="word" value="3" />
                    <img src="./img/word.gif" width="20" height="19"  style="vertical-align: middle">
                </div></td>
        </tr>
        <tr> 
            <td colspan="3" class="TextoCampos"> <div align="center"> 
                    <% if (temacesso) {%>
                    <input name="imprimir" type="button" class="botoes" id="imprimir" value="Imprimir" onClick="javascript:tryRequestToServer(function () {
                    popRel();
                });">
                    <%}%>
                </div></td>
        </tr>
    </table>
</div>

<div id="tabDinamico"></div>

</body>
</html>
