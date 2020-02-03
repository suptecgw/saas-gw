<%@page import="br.com.gwsistemas.sistematiporelatorio.Sistema"%>
<%@page import="br.com.gwsistemas.reportbuilder.ReportBuilder"%>
<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@page import="br.com.gwsistemas.reportbuilder.ReportBuilderBO"%>
<%@page import="java.util.Collection"%>
<%@page import="br.com.gwsistemas.eutil.Consulta"%>
<%@page import="nucleo.Apoio"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.text.*,
         java.util.Date,
         nucleo.*" errorPage="" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>

<% boolean temacesso = (Apoio.getUsuario(request) != null
            && Apoio.getUsuario(request).getAcesso("cadrota") >= 1);
    if ((Apoio.getUsuario(request) == null) || (!temacesso)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    if (acao.equals("exportar")) {

        java.util.Map param = new java.util.HashMap(7);
        param.put("CIDADE_ORIGEM", (request.getParameter("idcidadeorigem").equals("0") ? "" : " and ori.idcidade=" + request.getParameter("idcidadeorigem")));
        param.put("CIDADE_DESTINO", (request.getParameter("idcidadedestino").equals("0") ? "" : " and des.idcidade=" + request.getParameter("idcidadedestino")));
        param.put("TIPO_PRODUTO", (request.getParameter("tipo_produto_id").equals("0") ? "" : " and pro.id=" + request.getParameter("tipo_produto_id")));
        param.put("TIPO_VEICULO", (request.getParameter("tipo_veiculo_id").equals("0") ? "" : " and tp.id=" + request.getParameter("tipo_veiculo_id")));
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));

        request.setAttribute("map", param);
        request.setAttribute("rel", "rota_mod1");

    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
    dispacher.forward(request, response);
    }else if(acao.equals("iniciar")){
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_ROTA_RELATORIO.ordinal());
    }

%>


<script language="javascript" type="text/javascript">

    function modelos(modelo) {
        getObj("modelo1").checked = false;

        getObj("modelo" + modelo).checked = true;
    }

    function popRel() {
        var impressao;
        if ($("pdf").checked)
            impressao = "1";
        else if ($("excel").checked)
            impressao = "2";
        else
            impressao = "3";
        launchPDF('./relrotas.jsp?acao=exportar&impressao=' + impressao + '&' + concatFieldValue("idcidadeorigem") + '&' + concatFieldValue("idcidadedestino") + '&' + concatFieldValue("tipo_produto_id") + '&' + concatFieldValue("tipo_veiculo_id"));
    }

    function localizarTipoProduto() {
        launchPopupLocate('./localiza?acao=consultar&idlista=37', 'Tipo_Produto');
    }

    function localizarCidadeDest() {
        launchPopupLocate('./localiza?acao=consultar&idlista=12', 'Cidade_Destino');
    }

    function localizarCidadeOri() {
        launchPopupLocate('./localiza?acao=consultar&idlista=11', 'Cidade_Origem');
    }

    function localizarTipoVeiculo() {
        launchPopupLocate('./localiza?acao=consultar&idlista=61', 'Tipo_Veiculo')
    }

    function limparProduto() {
        $("tipo_produto").value = "";
        $("tipo_produto_id").value = "0";
    }

    function limparCidadeOri() {
        $("cid_origem").value = "";
        $("idcidadeorigem").value = "0";
    }

    function limparCidadeDest() {
        $("cid_destino").value = "";
        $("idcidadedestino").value = "0";
    }

    function limparVeiculo() {
        $("tipo_veiculo_descricao").value = "";
        $("tipo_veiculo_id").value = "0";
    }

</script>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>Webtrans - Relatório de Produtos</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onload="AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>

        </div>
        <table width="90%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Relat&oacute;rio de Rotas </b></td>
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
                    <td height="18" colspan="3"> 
                        <div align="center">Modelos</div></td>
                </tr>
                <tr> 
                    <td width="50%" height="24" class="TextoCampos"> <div align="left"> 
                            <input name="modelo1" id="modelo1" type="radio" value="1" checked onclick="javascript:modelos(1);">
                            Modelo 1</div></td>
                            <td width="77%" colspan="2" class="CelulaZebra2"> Relat&oacute;rio de Rotas.</td>
                </tr>
                <tr class="tabela"> 
                    <td height="18" colspan="3"> 
                        <div align="center">Filtros</div></td>
                </tr>
                <tr> 
                    <td colspan="3">
                        <table width="100%" border="0"class="bordaFina" >
                            <tr>
                                <td class="TextoCampos" width="50%">
                                    Apenas a Cidade de Origem:                     
                                </td>
                                <td class="CelulaZebra2">
                                    <span class="CelulaZebra2">
                                        <input name="cid_origem" type="text" class="inputReadOnly8pt" id="cid_origem" size="28" value="" readonly="true">
                                        <input name="idcidadeorigem" type="hidden" class="inputReadOnly8pt" id="idcidadeorigem" value="0" readonly="true">
                                        <input name="button2" type="button" class="botoes" onClick="localizarCidadeOri()" value="...">
                                        <strong> 
                                            <img src="img/borracha.gif" alt="" border="0" align="absbottom" class="imagemLink" title="Limpar tipo produto" onClick="limparCidadeOri();">
                                        </strong> 
                                    </span>                            
                                </td>
                            </tr>

                            <tr>
                                <td class="TextoCampos">
                                    Apenas a Cidade de Destino:
                                </td>
                                <td class="CelulaZebra2">
                                    <span class="CelulaZebra2">
                                        <input type="text" name="cid_destino" id="cid_destino" class="inputReadOnly8pt" size="43" value="" readonly="true">
                                        <input type="hidden" name="idcidadedestino" id="idcidadedestino" class="inputReadOnly8pt" size="5" value="0" readonly="true">
                                        <input type="button" name="button3" class="botoes" value="..." onClick="localizarCidadeDest()">
                                        <strong>
                                            <img src="img/borracha.gif" alt="" border="0" align="absbottom" class="imagemLink" title="Limpar tipo cliente" onclick="limparCidadeDest()">
                                        </strong>
                                    </span>
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">
                                    Apenas o Tipo de Ve&iacute;culo:
                                </td>
                                <td class="CelulaZebra2">
                                    <span class="CelulaZebra2">
                                        <input type="text" name="tipo_veiculo_descricao" id="tipo_veiculo_descricao" class="inputReadOnly8pt" size="43" value="" readonly="true">
                                        <input type="hidden" name="tipo_veiculo_id" id="tipo_veiculo_id" class="inputReadOnly8pt" size="5" value="0" readonly="true">
                                        <input type="button" name="button4" class="botoes" value="..." onClick="localizarTipoVeiculo()">
                                        <strong>
                                            <img src="img/borracha.gif" alt="" border="0" align="absbottom" class="imagemLink" title="Limpar tipo cliente" onclick="limparVeiculo()">
                                        </strong>
                                    </span>
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">
                                    Apenas o Tipo de Produto:
                                </td>
                                <td class="CelulaZebra2">
                                    <span class="CelulaZebra2">
                                        <input type="text" name="tipo_produto" id="tipo_produto" class="inputReadOnly8pt" size="43" value="" readonly="true">
                                        <input type="hidden" name="tipo_produto_id" id="tipo_produto_id" class="inputReadOnly8pt" size="5" value="0" readonly="true">
                                        <input type="button" name="button5" class="botoes" value="..." onClick="localizarTipoProduto()">
                                        <strong>
                                            <img src="img/borracha.gif" alt="" border="0" align="absbottom" class="imagemLink" title="Limpar tipo cliente" onclick="limparProduto()">
                                        </strong>
                                    </span>
                                </td>
                            </tr>
                        </table>
                    </td>
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
                        </div>
                    </td>
                </tr>
                <tr> 
                    <td colspan="3" class="TextoCampos">
                        <div align="center">
                            <%if (temacesso) {%>
                            <input name="imprimir" type="button" class="botoes" id="imprimir" value="Imprimir" onClick="javascript:tryRequestToServer(function() {
                                        popRel();
                                    });">
                            <%}%>
                        </div>
                    </td>
                </tr>
            </table>
        </div>
        <div id="tabDinamico" width="90%">
            
        </div>
    </body>
</html>
