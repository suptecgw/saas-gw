 <%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
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
                        && Apoio.getUsuario(request).getAcesso("chequecliente") > 0);
   if ((Apoio.getUsuario(request) == null) || (! temacesso))
       response.sendError(response.SC_FORBIDDEN);
   
  String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao") );

  if (acao.equals("exportar")) {
    String cheques = request.getParameter("cheques");
    String condicaoCheques = " and cheque in (";
    if(cheques != null && !cheques.trim().isEmpty()){
        int cont = 0;
        for(String cheque : cheques.split(",")){
            cont++;
            condicaoCheques += (condicaoCheques.trim().equals("") ? "" : cont > 1 ? "," : "")+ "'" + cheque + "'";
        } 
        condicaoCheques += ") ";
        
    }else{
        condicaoCheques = "";
    }
   
    SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
    Date dtinicial = formatador.parse(request.getParameter("dtinicial"));
    Date dtfinal = formatador.parse(request.getParameter("dtfinal"));
    String modelo = request.getParameter("modelo");
    String tipoData = request.getParameter("tipoData");
    
    java.util.Map param = new java.util.HashMap(8);
    param.put("DATA_INI", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtinicial)+"'");
    param.put("DATA_FIM", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtfinal)+"'");
    param.put("IDCLIENTE",(request.getParameter("idconsignatario").equals("0")?"":" and idcliente = " + request.getParameter("idconsignatario")));
    param.put("OPCOES",("Período entre "+request.getParameter("dtinicial") + " e " + request.getParameter("dtfinal")));
    param.put("CHEQUES", condicaoCheques);
    param.put("TIPO_DATA", tipoData);
    param.put("USUARIO",Apoio.getUsuario(request).getNome());     
    param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
    
    
    request.setAttribute("map", param);
    request.setAttribute("rel", "relchequesmod"+modelo);
    
    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
    dispacher.forward(request, response);
   
   }else if (acao.equals("iniciar")){
                request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_CHEQUES_RELATORIO.ordinal());
   }    
  
%>


<script language="javascript" type="text/javascript">

  function modelos(modelo){
    getObj("modelo1").checked = false;
    getObj("modelo"+modelo).checked = true;
  }
  

  function popRel(){
    var cheques = $("cheques").value;
    var modelo; 
    if (! validaData(getObj("dtinicial").value) || ! validaData(getObj("dtfinal").value)){
      alert ("Informe o intervalo de datas corretamente.");
    } else {
      if (getObj("modelo1").checked)
        modelo = '1';
      var impressao;
      if ($("pdf").checked)
        impressao = "1";
      else if ($("excel").checked)
        impressao = "2";
      else
        impressao = "3";
        
      launchPDF('./relcheques?acao=exportar&modelo='+modelo+'&impressao='+impressao+'&'+concatFieldValue("dtinicial,dtfinal,idconsignatario,tipoData")+"&cheques="+ cheques);
    }
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

<title>Webtrans - Relatório de Cheques de clientes</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="applyFormatter();AlternarAbasGenerico('tdAbaPrincipal','tabPrincipal');aoCarregarTabReport(<c:out value='${rotinaRelatorio}'/>,'<c:out value="${param.modulo}"/>');">
<div align="center"><img src="img/banner.gif"  alt="banner"> <br>
  <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
</div>
<table width="90%" height="28" align="center" class="bordaFina" >
  <tr>
    <td height="22"><b>Relat&oacute;rio de Cheques</b></td>
  </tr>
</table>

<br>
<table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
            <tr>
                <td>
                    <table width="100%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="left">
                        <tr class="tabela" id="">
                            <td id="tdAbaPrincipal" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');"><center>Relatórios Principais</center></td>
                            <td id="tdAbaDinamico" class="menu" onclick="AlternarAbasGenerico('tdAbaDinamico', 'tabDinamico');">Relatórios Personalizados</td>
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
    <td width="99" height="24" class="TextoCampos"> <div align="left"> 
        <input type="radio" name="modelo1" id="modelo1" value="1" checked onClick="javascript:modelos('1');">
        Modelo 1 </div></td>
    <td width="378" colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de 
      cheques por cliente. </td>
  </tr>
  <tr class="tabela"> 
    <td colspan="3"><div align="center">Crit&eacute;rio de datas</div></td>
  </tr>
  <tr> 
    <td class="TextoCampos">
        <select name="tipoData" id="tipoData" class="inputTexto">
            <option value="data">Data do Cheque</option>
            <option value="data_pagamento">Data do Pagamento</option>
        </select> 
    </td>
    <td colspan="2" class="CelulaZebra2">Entre: <strong> 
      <input name="dtinicial" type="text" id="dtinicial" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
	  		 onblur="alertInvalidDate(this)" class="fieldDate" />
      </strong>e<strong> 
      <input name="dtfinal" type="text" id="dtfinal" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
	         onblur="alertInvalidDate(this)" class="fieldDate" />
      </strong>
      </td>
  </tr>
  <tr class="tabela"> 
    <td height="18" colspan="3"> 
      <div align="center">Filtros</div></td>
  </tr>
  <tr> 
    <td colspan="3"> <table width="100%" border="0" >
        <tr> 
          <td width="133" class="TextoCampos">Apenas o cliente:</td>
          <td width="338" colspan="0" class="CelulaZebra2"><strong> 
            <input name="con_rzs" type="text" id="con_rzs" class="inputReadOnly" value="" size="35" maxlength="80" readonly="true">
            <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." 
			       onClick="launchPopupLocate('./localiza?categoria=loc_cliente&acao=consultar&idlista=<%=BeanLocaliza.CONSIGNATARIO_DE_CONHECIMENTO%>', 'Vendedor')">
            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Vendedor" 
			     onClick="javascript:getObj('idconsignatario').value = '0';javascript:getObj('con_rzs').value = '';"> 
            </strong></td>
            
        </tr>
        <tr>
            <td width="133" class="TextoCampos">Apenas os cheques:</td>
            <td width="338" class="CelulaZebra2"><strong>
                    <input name="cheques" type="text" id="cheques" size="40" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar2').click();" value="<%= request.getParameter("cheques") != null ? request.getParameter("cheques") : "" %>" class="inputtexto"></td>
                </strong>          
            </td>
        </tr>
      </table></td>
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
        <% if (temacesso){%>
        <input name="imprimir" type="button" class="botoes" id="imprimir" value="Imprimir" onClick="javascript:tryRequestToServer(function(){popRel();});">
        <%}%>
      </div></td>
  </tr>
</table>
</div>
<div id="tabDinamico"></div>
</body>
</html>
