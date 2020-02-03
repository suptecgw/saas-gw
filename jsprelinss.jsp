<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
          import="nucleo.BeanConfiguracao,
                  java.text.*,
                  java.util.Date,
                  nucleo.Apoio" errorPage="" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>


<% boolean temacesso = (Apoio.getUsuario(request) != null
                        && Apoio.getUsuario(request).getAcesso("relimpostos") > 0);
   boolean temacessofiliais = (Apoio.getUsuario(request) != null && Apoio.getUsuario(request).getAcesso("lancartafl") > 0);
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (! temacesso))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA

  String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao") );

  //exportacao da Cartafrete para arquivo .pdf
  if (acao.equals("exportar"))
  {
    SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
    Date dtinicial = formatador.parse(request.getParameter("dtinicial"));
    Date dtfinal = formatador.parse(request.getParameter("dtfinal"));

    java.util.Map param = new java.util.HashMap(4);
    param.put("DATA_INI", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "'");
    param.put("DATA_FIM", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal)+ "'");
    param.put("FILIAL", request.getParameter("idfilial").equals("0") ? "" : " AND cf.idfilial="+request.getParameter("idfilial") );
    param.put("OPCOES", "Período selecionado:" + request.getParameter("dtinicial") + " até " + request.getParameter("dtfinal") + (request.getParameter("idfilial").equals("0")?". Todas as filiais ": ". Apenas a filial " + request.getParameter("fi_abreviatura")));
    param.put("USUARIO",Apoio.getUsuario(request).getNome());     
    param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
    request.setAttribute("map", param);
    request.setAttribute("rel", "inssmod"+request.getParameter("modelo"));
    
    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
    dispacher.forward(request, response);
    
    }else if (acao.equals("iniciar")){
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_INSS_IR_RELATORIO.ordinal());
    
    }    
  
%>


<script language="javascript" type="text/javascript">

  function popRel(){
    var modelo; 
    if (! validaData(document.getElementById("dtinicial").value) || !validaData(document.getElementById("dtfinal").value))
      alert ("Informe o intervalo de datas corretamente.");
    else{
//    if (document.getElementById("modelo1").checked)
        modelo = 1;

    var impressao;
    if ($("pdf").checked)
      impressao = "1";
    else if ($("excel").checked)
      impressao = "2";
    else
      impressao = "3";
        
      launchPDF('./relinss?acao=exportar&modelo='+modelo
          +'&impressao='+impressao
          +'&dtinicial='+document.getElementById("dtinicial").value
          +'&dtfinal='+document.getElementById("dtfinal").value
          +'&fi_abreviatura='+document.getElementById("fi_abreviatura").value
          +'&idfilial='+document.getElementById("idfilial").value
      );
    }
  }

    function localizafilial(){
        post_cad = window.open('./localiza?acao=consultar&idlista=8','Filial',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
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

<title>Webtrans - Relatório de INSS / IR</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body onload="applyFormatter();AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>);">
<div align="center"><img src="img/banner.gif"  alt="banner"> <br>
</div>
<table width="90%" height="28" align="center" class="bordaFina" >
  <tr>
    <td height="22"><b>Relat&oacute;rio de INSS / IR Carreteiro</b></td>
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
    <td width="23%" height="24" class="TextoCampos"> <div align="left"> 
        <input name="modelo1" type="radio" value="1" checked>
        Modelo 1</div></td>
    <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o de 
      INSS/IR,SEST/SENAT retidos por propriet&aacute;rio</td>
  </tr>
  <tr class="tabela"> 
    <td colspan="3"><div align="center">Crit&eacute;rio de datas</div></td>
  </tr>
  <tr> 
    <td height="24" colspan="3" class="TextoCampos"> <div align="center">Cartas 
        fretes entre<strong> 
        <input name="dtinicial" type="text" id="dtinicial" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
        		 onblur="alertInvalidDate(this)" class="fieldDate" />
        </strong>e<strong> 
        <input name="dtfinal" type="text" id="dtfinal" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
        		 onblur="alertInvalidDate(this)" class="fieldDate" />
        </strong></div></td>
  </tr>
  <tr class="tabela">
    <td colspan="3"><div align="center">Filtros</div></td>
  </tr>
                        <tr>
                            <td width="35%" class="TextoCampos">Apenas a filial:</td>
                            <td width="65%" class="CelulaZebra2"><strong>
                                    <input name="fi_abreviatura" type="text" id="fi_abreviatura" class="inputReadOnly" value="<%=(temacessofiliais ? "" : Apoio.getUsuario(request).getFilial().getAbreviatura())%>" size="20" readonly="true">
                                    <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." onClick="javascript:localizafilial();">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:getObj('idfilial').value = '0';javascript:getObj('fi_abreviatura').value = '';">
                                    <input type="hidden" name="idfilial" id="idfilial" value="<%=(temacessofiliais ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial())%>">
                                </strong></td>
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
    <td colspan="3" class="TextoCampos"> <div align="center"> 
        <% if (temacesso){%>
        <input name="imprimir" type="button" class="botoes" id="imprimir" value="Imprimir" onclick="javascript:tryRequestToServer(function(){popRel();});">
        <%}%>
      </div></td>
  </tr>
</table>
        </div>
        <div id="tabDinamico"></div>
</body>
</html>
