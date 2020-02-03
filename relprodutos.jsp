<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
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
            && Apoio.getUsuario(request).getAcesso("cadprodutotrans") > 0);
    if ((Apoio.getUsuario(request) == null) || (!temacesso)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    if (acao.equals("exportar")) {

        java.util.Map param = new java.util.HashMap(7);
        param.put("PRODUTO", (request.getParameter("produto_id").equals("0") ? "" : " and p.id=" + request.getParameter("produto_id")));
        param.put("CLIENTE", (request.getParameter("idremetente").equals("0") ? "" : " and cli.idcliente=" + request.getParameter("idremetente")));
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        request.setAttribute("map", param);
        request.setAttribute("rel", "produtomod1");
        
    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
    dispacher.forward(request, response);
    }else if(acao.equals("iniciar")){
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_PRODUTO_RELATORIO.ordinal());
    }

%>


<script language="javascript" type="text/javascript">



    function popRel(){
        var impressao;
        if ($("pdf").checked)
            impressao = "1";
        else if ($("excel").checked)
            impressao = "2";
        else
            impressao = "3";
        launchPDF('./relprodutos.jsp?acao=exportar&impressao='+impressao+'&'+concatFieldValue("produto_id")+'&'+concatFieldValue("idremetente"));
    }
    
    function localizaproduto(){
        post_cad = window.open('./localiza?acao=consultar&idlista=50&paramaux=cliente_id&paramaux2=pd.destinatario_id','Produto',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }
    function localizarCliente(){
       launchPopupLocate('./localiza?acao=consultar&idlista=3','Cliente');
    }


    function limparCliente(){
        $("rem_rzs").value = "";
        $("idremetente").value = "0";
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

    <body onload="AlternarAbasGenerico('tdAbaPrincipal','tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>

        </div>
        <table width="90%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Relat&oacute;rio de Produtos </b></td>
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
                    <div align="center">Filtros</div></td>
            </tr>
            <tr> 
                <td colspan="3">
                    <table width="100%" border="0"class="bordaFina" >
                        <tr>
                            <td class="TextoCampos">
                                Apenas o Produto:                     
                            </td>
                            <td class="CelulaZebra2">
                                <span class="CelulaZebra2">
                                    <input name="codigo_produto" type="text" class="inputReadOnly8pt" id="codigo_produto" size="10" value="" readonly="true">
                                    <input name="descricao_produto" type="text" class="inputReadOnly8pt" id="descricao_produto" size="28" value="" readonly="true">
                                    <input name="produto_id" type="hidden" class="inputReadOnly8pt" id="produto_id" size="5" value="0" readonly="true">
                                    <input name="button2" type="button" class="botoes" onClick="javascript:localizaproduto();" value="...">
                                    <strong> 
                                        <img src="img/borracha.gif" alt="" border="0" align="absbottom" class="imagemLink" title="Limpar tipo produto" onClick="javascript:getObj('produto_id').value = 0;javascript:getObj('descricao_produto').value = '';javascript:getObj('codigo_produto').value = '';">
                                    </strong> 
                                </span>                            
                            </td>
                        </tr>
                        
                        <tr>
                            <td class="TextoCampos">
                                Apenas Produtos do cliente:
                            </td>
                            <td class="CelulaZebra2">
                                <span class="CelulaZebra2">
                                    <input type="text" name="rem_rzs" id="rem_rzs" class="inputReadOnly8pt" size="43" value="" readonly="true">
                                    <input type="hidden" name="idremetente" id="idremetente" class="inputReadOnly8pt" size="5" value="0" readonly="true">
                                    <input type="button" name="button3" class="botoes" value="..." onClick="localizarCliente()">
                                    <strong>
                                        <img src="img/borracha.gif" alt="" border="0" align="absbottom" class="imagemLink" title="Limpar tipo cliente" onclick="limparCliente()">
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
                        <input name="imprimir" type="button" class="botoes" id="imprimir" value="Imprimir" onClick="javascript:tryRequestToServer(function(){popRel();});">
                        <%}%>
                    </div>
                </td>
            </tr>
        </table>
            
        </div>
                    
        <div id="tabDinamico"></div>

        
    </body>
</html>
