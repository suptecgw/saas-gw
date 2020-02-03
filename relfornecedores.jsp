<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
          import="nucleo.BeanConfiguracao,
                  java.text.*,
                  java.util.Date,
                  nucleo.*" errorPage="" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>


<% boolean temacesso = (Apoio.getUsuario(request) != null
                        && Apoio.getUsuario(request).getAcesso("cadfornecedor") > 0);
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (! temacesso))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA

  String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao") );

  //exportacao da Cartafrete para arquivo .pdf
  if (acao.equals("exportar")){
	String grupo = request.getParameter("grupo_id");
    java.util.Map param = new java.util.HashMap(2);
    param.put("OPCOES", (grupo != null && !grupo.equals("") && !grupo.equals("0") ? "Apenas fornecedores do grupo: " + request.getParameter("grupo"): "Todos os fornecedores"));
    param.put("GRUPO", (grupo != null && !grupo.equals("") && !grupo.equals("0") ? " WHERE idfornecedor in(select fornecedor_id from fornecedor_grupo_cliente where grupo_cli_for_id ="+grupo+")" :  ""));
    param.put("USUARIO",Apoio.getUsuario(request).getNome());     
    param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
    param.put("ID_AREA",(request.getParameter("area_id")));
    param.put("ID_FORNECEDOR",(request.getParameter("idfornecedor")));
    request.setAttribute("map", param);
    request.setAttribute("rel", "fornecedormod"+request.getParameter("modelo"));
    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
                dispacher.forward(request, response);
    }else if(acao.equals("iniciar")){
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_FORNECEDOR_RELATORIO.ordinal());
    }    
  
%>


<script language="javascript" type="text/javascript">
 /**
  * Função responsavel por exibir e ocultar os filtros na tela relfornecedores.
  */
function modeloSelecionado(){
    
        if($("modelo1").checked){
            
            $("trFiltroApenasGrupo").style.display = "";
            $('grupo_id').value = "";
            $('grupo').value = "";
            
            $("trFiltroArea").style.display = "none";
            $('area_id').value= "0";
            $('area').value = "";
            
            $("trFiltroFornecedor").style.display = "none";
            $('idfornecedor').value="0";
            $('fornecedor').value = "";
            
        }else if($("modelo2").checked){
            
            $("trFiltroApenasGrupo").style.display = "none";
            $('grupo_id').value = "";
            $('grupo').value = "";
            
            $("trFiltroArea").style.display = "";
            $('area_id').value= "0";
            $('area').value = "";
            
            $("trFiltroFornecedor").style.display = "";
            $('idfornecedor').value="0";
            $('fornecedor').value ="";
            
        }
    }

function popRel(){
    var modelo; 
    if ($("modelo1").checked){
      modelo = 1;
    }else if($("modelo2").checked){
        modelo = 2;
    }
    var impressao;
    if ($("pdf").checked)
      impressao = "1";
        else if ($("excel").checked)
            impressao = "2";
        else
            impressao = "3";
      
      launchPDF('./relfornecedores.jsp?acao=exportar&modelo='+modelo+'&impressao='+impressao+'&'+concatFieldValue("grupo_id,grupo,area_id,idfornecedor"));
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

<title>Webtrans - Relatório de Fornecedores</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body onload="javascript:modeloSelecionado();AlternarAbasGenerico('tdAbaPrincipal','tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');">
<div align="center"><img src="img/banner.gif"  alt="banner"> <br>
  <input type="hidden" name="grupo_id" id="grupo_id" value="0">
  <input type="hidden" name="area_id" id="area_id" value="0"/>
  <input type="hidden" id="idfornecedor" name="idfornecedor" value="0"/>

</div>
<table width="90%" height="28" align="center" class="bordaFina" >
  <tr>
    <td height="22"><b>Relat&oacute;rio de Fornecedores</b></td>
  </tr>
</table>

<br>

<table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
            <tr>
                <td>
                    <table width="95%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="left">
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
    <td width="23%" height="24" class="TextoCampos"> <div align="left"> 
        <input name="modelo1" id="modelo1" type="radio" value="1" checked onclick="javascript:modeloSelecionado();" >
        Modelo 1</div></td>
    <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o dos fornecedores</td>
  </tr>
  
  <tr> 
    <td width="23%" height="24" class="TextoCampos"> <div align="left"> 
            <input name="modelo1" id="modelo2" type="radio" value="2" onclick="javascript:modeloSelecionado();" >
        Modelo 2</div></td>
        <td width="77%" colspan="2" class="CelulaZebra2"> Tabelas de pre&ccedil;os dos representantes</td>
  </tr>
  
  <tr class="tabela"> 
    <td height="18" colspan="3"> 
      <div align="center">Filtros</div></td>
  </tr>
        <tr id="trFiltroApenasGrupo"> 
          <td width="133" class="TextoCampos">Apenas do grupo:</td>
          <td width="338" class="CelulaZebra2"><strong> 
            <input name="grupo" type="text" id="grupo" class="inputReadOnly" value="" size="35" maxlength="80" readonly="true">
            <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." 
			       onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.GRUPO_CLI_FOR%>', 'Grupo')">
            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Vendedor" 
			     onClick="javascript:$('grupo_id').value = '0';javascript:$('grupo').value = '';"> 
            </strong></td>
        </tr>
        <tr id="trFiltroArea" style="display: none">
            <td width="133" class="TextoCampos">Apenas as Areas:</td>
                <td width="338" class="CelulaZebra2">
                    <strong> 
                        
                        <input name="area" type="text" id="area" class="inputReadOnly" value="" size="35" maxlength="80" readonly="true">
                        <input name="localiza_area" type="button" class="botoes" id="localiza_area" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.AREA%>', 'Area')">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Area" onclick="javascript:$('area_id').value= '0'; javascript:$('area').value = '';"/> 
                    </strong>
                </td>
        </tr>
        <tr id="trFiltroFornecedor" style="display: none">
            <td width="133" class="TextoCampos">Apenas os Fornecedor:</td>
                <td width="338" class="CelulaZebra2">
                    <strong> 
                        <input name="fornecedor" type="text" id="fornecedor" class="inputReadOnly" value="" size="35" maxlength="80" readonly="true">
                        <input name="localiza_fornecedor" type="button" class="botoes" id="localiza_fornecedor" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FORNECEDOR%>', 'Area')">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Area" onclick="javascript:$('idfornecedor').value='0';javascript:$('fornecedor').value = '';"/> 
                    </strong>
                </td>
        </tr>
        
            <tr>
                <td colspan="3" class="tabela"><div align="center">Formato do relat&oacute;rio </div></td>
            </tr>
        <tr>
            <td colspan="3" class="TextoCampos">
                <div align="center">
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
                    <% if (temacesso){%>
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