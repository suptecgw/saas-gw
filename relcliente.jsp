 <%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
          import="java.text.*,
                  java.util.Date,
                  nucleo.*" errorPage="" %>
 <%@ page import="br.com.gwsistemas.filial.FilialBO" %>

 <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>


<% boolean temacesso = (Apoio.getUsuario(request) != null
                        && Apoio.getUsuario(request).getAcesso("cadcliente") > 0);
   if ((Apoio.getUsuario(request) == null) || (! temacesso))
       response.sendError(response.SC_FORBIDDEN);
   
  String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao") );

  if (acao.equals("exportar"))
  {
    String modelo = request.getParameter("modelo");
    String condicaoDireto = "";
    if(request.getParameter("direto") != null && !request.getParameter("direto").equals("")){
        condicaoDireto = request.getParameter("direto").equals("true") ? " and cl.is_cliente_direto " : " and not cl.is_cliente_direto ";
    }
    // 25-10-2013 - Paulo
    String tipoData = request.getParameter("tipodata");
    SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
    Date dtinicial = formatador.parse(request.getParameter("dtinicial"));
    Date dtfinal = formatador.parse(request.getParameter("dtfinal"));    
    
    String sqlCriterioData = "";
    String condicaoData = "";
    int filialResponsavelId = Apoio.parseInt(request.getParameter("apenasFilial"));
    StringBuilder condicaoFiltroFilial = new StringBuilder();
    if(tipoData.equals("incluso_entre")){
        sqlCriterioData = " AND cl.dtlancamento BETWEEN '" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) 
                + "' AND '" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'";
    }else if(tipoData.equals("alterados_entre")){
        sqlCriterioData = " AND cl.dtalteracao BETWEEN '" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial)
                + "' AND '" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "' AND cl.idusuarioalteracao = cl.idusuariolancamento";
    }else if(tipoData.equals("primeiro_cte")){
        if(modelo.equals("1") || modelo.equals("2") || modelo.equals("3") || modelo.equals("4") || modelo.equals("5")){
             condicaoData = "JOIN (select sl.consignatario_id from sales sl group by sl.consignatario_id having min(sl.emissao_em) BETWEEN '" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial)
                    + "' AND '" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "' ) as sl on (sl.consignatario_id = cl.idcliente)";
        }
    }
    
    if (filialResponsavelId > 0) {
        condicaoFiltroFilial.append(" AND cl.filial_responsavel_id IN (").append(filialResponsavelId).append(") ");
    }
    
    java.util.Map param = new java.util.HashMap(10);
    param.put("IDCLIENTE", (request.getParameter("idconsignatario").equals("0")?"":" and idcliente="+request.getParameter("idconsignatario")));
    param.put("IDVENDEDOR", (request.getParameter("idvendedor").equals("0")?"":" and idvendedor="+request.getParameter("idvendedor")));
    param.put("IDGRUPO", (request.getParameter("grupo_id").equals("0")?"":" and grupo_id="+request.getParameter("grupo_id")));
    param.put("ATIVO", request.getParameter("ativo"));
    param.put("DIRETO", condicaoDireto);
    param.put("TIPODATA", sqlCriterioData);
    param.put("USUARIO", Apoio.getUsuario(request).getNome());
    param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
    param.put("CONDICAODATA", condicaoData);
    param.put("FILTRO_FILIAL_RESPONSAVEL", condicaoFiltroFilial.toString());

    request.setAttribute("map", param);
    request.setAttribute("rel", "clientesmod"+modelo);
    
    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
    dispacher.forward(request, response);
    }else if(acao.equals("iniciar")){
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_CLIENTE_RELATORIO.ordinal());
        request.setAttribute("filiais", new FilialBO().carregarFiliais());
    }
  
%>


<script language="javascript" type="text/javascript">

  function modelos(modelo){
    getObj("modelo1").checked = false;
    getObj("modelo2").checked = false;
    getObj("modelo3").checked = false;
    getObj("modelo4").checked = false;
    getObj("modelo5").checked = false;
    getObj("modelo"+modelo).checked = true;
  }

  function popRel(){
    var modelo; 
    if (getObj("modelo1").checked)
      modelo = '1';
    else if (getObj("modelo2").checked)
      modelo = '2';
    else if (getObj("modelo3").checked)
      modelo = '3';
    else if (getObj("modelo4").checked)
      modelo = '4';
    else if (getObj("modelo5").checked)
      modelo = '5';
    var impressao;
    if ($("pdf").checked)
      impressao = "1";
    else if ($("excel").checked)
      impressao = "2";
    else
      impressao = "3";
        
    launchPDF('./relcliente.jsp?acao=exportar&modelo='+modelo+'&impressao='+impressao+'&'+concatFieldValue("idvendedor,idconsignatario,grupo_id,ativo,direto,tipodata,dtinicial,dtfinal,apenasFilial"));
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

<title>Webtrans - Relatório de Clientes</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body onload="AlternarAbasGenerico('tdAbaPrincipal','tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');">
<div align="center"><img src="img/banner.gif"  alt="banner"> <br>
  <input type="hidden" name="idvendedor" id="idvendedor" value="0">
  <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
  <input type="hidden" name="grupo_id" id="grupo_id" value="0">
</div>
<table width="90%" height="28" align="center" class="bordaFina" >
  <tr>
    <td height="22"><b>Relat&oacute;rio de Clientes </b></td>
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
    <td width="50%" class="TextoCampos"> <div align="left">
        <input type="radio" name="modelo1" id="modelo1" value="1" checked onClick="javascript:modelos('1');">
        <label for="modelo1">Modelo 1</label></div></td>
    <td width="70%" colspan="2" class="CelulaZebra2">Ficha de clientes </td>
  </tr>
  <tr> 
    <td class="TextoCampos"> <div align="left"> 
        <input type="radio" name="modelo2" id="modelo2" value="2" onClick="javascript:modelos('2');">
        <label for="modelo2">Modelo 2</label></div></td>
    <td  colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de clientes por vendedor </td>
  </tr>
  <tr> 
    <td class="TextoCampos"> <div align="left"> 
        <input type="radio" name="modelo3" id="modelo3" value="3" onClick="javascript:modelos('3');">
        <label for="modelo3">Modelo 3</label></div></td>
    <td colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de clientes por grupo </td>
  </tr>
  <tr>
    <td class="TextoCampos"> <div align="left">
        <input type="radio" name="modelo4" id="modelo4" value="4" onClick="javascript:modelos('4');">
        <label for="modelo4">Modelo 4</label></div></td>
    <td colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de clientes</td>
  </tr>
  <tr>
    <td class="TextoCampos"> <div align="left">
        <input type="radio" name="modelo5" id="modelo5" value="5" onClick="javascript:modelos('5');">
        <label for="modelo5">Modelo 5</label></div></td>
    <td colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de clientes</td>
  </tr>
  <tr class="tabela"> 
    <td height="18" colspan="3"> 
      <div align="center">Filtros</div></td>
  </tr>
  <tr> 
      <td colspan="3"> <table width="100%" border="0"class="bordaFina" >
        <tr> 
          <td width="50%" class="TextoCampos">Apenas o Cliente:</td>
          <td width="338" class="CelulaZebra2"><strong> 
            <input name="con_rzs" type="text" id="con_rzs" class="inputReadOnly" value="" size="35" maxlength="80" readonly="true">
            <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." 
			       onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CONSIGNATARIO_DE_CONHECIMENTO%>', 'Cliente')">
            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Vendedor" 
			     onClick="javascript:getObj('idconsignatario').value = '0';javascript:getObj('con_rzs').value = '';"> 
            </strong></td>
        </tr>
        <tr> 
          <td width="133" class="TextoCampos">Apenas do vendedor:</td>
          <td width="338" class="CelulaZebra2"><strong> 
            <input name="ven_rzs" type="text" id="ven_rzs" class="inputReadOnly" value="" size="35" maxlength="80" readonly="true">
            <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." 
			       onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.VENDEDOR%>', 'Vendedor')">
            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Vendedor" 
			     onClick="javascript:getObj('idvendedor').value = '0';javascript:getObj('ven_rzs').value = '';"> 
            </strong></td>
        </tr>
        <input type="hidden" name="excetoGrupo" id="excetoGrupo" class="inputtexto" value="" />
        <tr> 
          <td width="133" class="TextoCampos">Apenas do grupo:</td>
          <td width="338" class="CelulaZebra2"><strong> 
            <input name="grupo" type="text" id="grupo" class="inputReadOnly" value="" size="35" maxlength="80" readonly="true">
            <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." 
			       onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.GRUPO_CLI_FOR%>', 'Vendedor')">
            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Vendedor" 
			     onClick="javascript:getObj('grupo_id').value = '0';javascript:getObj('grupo').value = '';"> 
            </strong></td>
        </tr>
        <tr> 
          <td width="133" class="TextoCampos">Apenas os clientes:</td>
          <td class="CelulaZebra2"><select id="ativo" name="ativo" class="inputtexto">
            <option value="true">Ativos</option>
            <option value="false">Inativos</option>
                    </select></td>
        </tr>
          <tr>
              <td class="TextoCampos">Apenas a filial responsável:</td>
              <td class="CelulaZebra2">
                  <select id="apenasFilial" name="apenasFilial" class="inputtexto">
                      <option value="0" selected>Todas</option>
    
                      <c:forEach items="${filiais}" var="filial">
                          <option value="${filial.id}">${filial.abreviatura}</option>
                      </c:forEach>
                  </select>
              </td>
          </tr>
        <tr>
          <td width="133" class="TextoCampos">Tipo:</td>
          <td class="CelulaZebra2">
              <select name="direto" id="direto" class="inputtexto">
              <option value="" selected >Ambos</option>
              <option value="true" >Apenas Diretos</option>
              <option value="false" >Apenas Indireto</option>
          </select>
          </td>
        </tr>
        <tr>
            <td width="133" class="TextoCampos">
                <select name="tipodata" id="tipodata" class="inputtexto">
                    <option value="nenhum" selected >Nao Filtrar Por Data</option>
                    <option value="incluso_entre" >Clientes inclusos entre</option>
                    <option value="alterados_entre" >Clientes alterados entre</option>
                    <option value="primeiro_cte" >Primeiro CT-e emitido entre</option>
                </select>                
            </td>
            <td class="CelulaZebra2">
                    entre<strong>
                          <input name="dtinicial" type="text" id="dtinicial" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
                               onblur="alertInvalidDate(this)" class="fieldDate" />
                    </strong>e<strong>
                          <input name="dtfinal" type="text" id="dtfinal" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
                               onblur="alertInvalidDate(this)" class="fieldDate" />
                    </strong>
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
    <td colspan="3" class="TextoCampos"> <div align="center"> 
        <%if (temacesso){%>
        <input name="imprimir" type="button" class="botoes" id="imprimir" value="Imprimir" onClick="javascript:tryRequestToServer(function(){popRel();});">
        <%}%>
      </div></td>
  </tr>
</table>
    
</div>
      
<div id="tabDinamico"></div>


</body>
</html>
