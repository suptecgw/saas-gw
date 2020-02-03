<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
          import="nucleo.BeanConfiguracao,
                  java.text.*,
                  java.util.Date,
                  nucleo.Apoio" errorPage="" %>

<script language="JavaScript"  src="script/grupo-util.js" type=""></script>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>

<% boolean temacesso = (Apoio.getUsuario(request) != null
                        && Apoio.getUsuario(request).getAcesso("relcontaspagar") > 0);
   boolean temacessofiliais = (Apoio.getUsuario(request) != null
                        && Apoio.getUsuario(request).getAcesso("reloutrasfiliais") > 0);
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (! temacesso))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA

  String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao") );

  //exportacao da Cartafrete para arquivo .pdf
  if (acao.equals("exportar")){
    String modelo = request.getParameter("modelo");
    String fornecedor = "";
    if (modelo.equals("4")){
        fornecedor = (!request.getParameter("idfornecedor").equals("0")?" and d.idfornecedor="+request.getParameter("idfornecedor"):"");
    }
    //se modelo igual ao modelo 5 vai passar o parametro com query para a view vdespesa
    else if(modelo.equals("5")){
        fornecedor = (!request.getParameter("idfornecedor").equals("0")?" and vd.fo_id="+request.getParameter("idfornecedor"):"");
    }else if(modelo.equals("6")){
        fornecedor = (!request.getParameter("idfornecedor").equals("0")?" and f.idfornecedor="+request.getParameter("idfornecedor"):"");
    }else{
        fornecedor = (!request.getParameter("idfornecedor").equals("0")?" and idfornecedor="+request.getParameter("idfornecedor"):"");
    }
    SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
    Date dtinicial = formatador.parse(request.getParameter("dtinicial"));
    Date dtfinal = formatador.parse(request.getParameter("dtfinal"));
    java.util.Map param = new java.util.HashMap(6);
    param.put("FORNECEDOR", fornecedor);
    
    //Filtro de filial
    if(modelo.equals("4")){
        param.put("IDFILIAL", (!request.getParameter("idfilial").equals("0")?" and d.idfilial="+request.getParameter("idfilial"):""));
    }else if(modelo.equals("5")){
        param.put("IDFILIAL", (!request.getParameter("idfilial").equals("0")?" and fi_id="+request.getParameter("idfilial"):""));
    }else if(modelo.equals("6")){
        param.put("IDFILIAL", (!request.getParameter("idfilial").equals("0")?" and d.idfilial="+request.getParameter("idfilial"):""));
    } else{
        param.put("IDFILIAL", (!request.getParameter("idfilial").equals("0")?" and idfilial="+request.getParameter("idfilial"):""));
    }
    
    //se modelo igual ao modelo 5 passar parametros com query para a view vdespesa 
    if(modelo.equals("5")){
        param.put("TIPODATA", (request.getParameter("tipodata").equals("dtvenc")?"du_dtvenc":"dtemissao"));
        param.put("DATA_INI", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtinicial)+"'");
        param.put("DATA_FIM", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtfinal)+"'");
        param.put("GRUPOS", (request.getParameter("grupos").equals("")?"":" and idfornecedor in (select fgc.fornecedor_id from fornecedor_grupo_cliente fgc where fgc.grupo_cli_for_id in ("+request.getParameter("grupos") +"))" ));
    } else if(modelo.equals("4")){
        param.put("DATA_INI", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtinicial)+"'");
        param.put("DATA_FIM", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtfinal)+"'");
        param.put("TIPODATA", request.getParameter("tipodata"));
        param.put("GRUPOS", (request.getParameter("grupos").equals("")?"":" and d.idfornecedor in (select fgc.fornecedor_id from fornecedor_grupo_cliente fgc where fgc.grupo_cli_for_id in ("+request.getParameter("grupos") +"))" ));
    } else if(modelo.equals("6")){
        param.put("DATA_INI", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtinicial)+"'");
        param.put("DATA_FIM", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtfinal)+"'");
        param.put("TIPODATA", request.getParameter("tipodata"));
        param.put("GRUPOS", (request.getParameter("grupos").equals("")?"":" and d.idfornecedor in (select fgc.fornecedor_id from fornecedor_grupo_cliente fgc where fgc.grupo_cli_for_id in ("+request.getParameter("grupos") +"))" ));
    } else{
        param.put("DATA_INI", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtinicial)+"'");
        param.put("DATA_FIM", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtfinal)+"'");
        param.put("TIPODATA", request.getParameter("tipodata"));
        param.put("GRUPOS", (request.getParameter("grupos").equals("")?"":" and idfornecedor in (select fgc.fornecedor_id from fornecedor_grupo_cliente fgc where fgc.grupo_cli_for_id in ("+request.getParameter("grupos") +"))" ));
    }
    param.put("FROTA", Apoio.parseBoolean(request.getParameter("apenasFrota")) ? " AND modulo_lancamento = 'fr' " : "");
    
    
    //filtrando pela condição de mostrar despesas com imagem anexadas, sem imagem anexada ou ambos os casos
    if(modelo.equals("4")){
    param.put("IMAGEM_ANEXADA", (request.getParameter("ambas").equals("true")? "": request.getParameter("com_img_anexada").equals("true")? " AND (darq.despesa_id = d.idmovimento) ": " AND darq.despesa_id is null "));
    }else{
    param.put("IMAGEM_ANEXADA", (request.getParameter("ambas").equals("true")? "": request.getParameter("com_img_anexada").equals("true")? " AND (darq.despesa_id = idmovimento) ": " AND darq.despesa_id is null "));
    }
    param.put("USUARIO",Apoio.getUsuario(request).getNome());     
    param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
    
    String tipoFiltroDespesaCFe = request.getParameter("chkMostrarDespesasCFe");

    switch (tipoFiltroDespesaCFe) {
        case "sim":
            param.put("FILTRO_TIPO_DESPESA_CFE", " AND carta_frete_id <> 0 ");
            break;
        case "nao":
            param.put("FILTRO_TIPO_DESPESA_CFE", " AND carta_frete_id = 0 ");
            break;
        case "ambos":
        default:
            param.put("FILTRO_TIPO_DESPESA_CFE", "");
            break;
    }

    request.setAttribute("map", param);
    request.setAttribute("rel", "despesamod"+modelo);
    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
    dispacher.forward(request, response);
    }else if(acao.equals("iniciar")){
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_DESPESA_RELATORIO.ordinal());
    }    
  
%>


<script language="javascript" type="text/javascript">

  function modelos(modelo){
    getObj("modelo1").checked = false;
    getObj("modelo2").checked = false;
    getObj("modelo3").checked = false;
    getObj("modelo4").checked = false;
    getObj("modelo5").checked = false;
    getObj("modelo6").checked = false;
    getObj("modelo"+modelo).checked = true;
  }
  
  function localizaforn(){
     	post_cad = window.open('./localiza?acao=consultar&idlista=21&paramaux=1','Fornecedor',
                        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
  }

  function limparforn(){
    document.getElementById("idfornecedor").value = "0";
    document.getElementById("fornecedor").value = "";
  }

  function localizafilial(){
      post_cad = window.open('./localiza?acao=consultar&idlista=8','Filial',
                     'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
  }

  function limparfilial(){
    document.getElementById("idfilial").value = 0;
    document.getElementById("fi_abreviatura").value = "";
  }

  function popRel(){
    var modelo; 
    var grupos = getGrupos();
    if (! validaData(document.getElementById("dtinicial").value) || !validaData(document.getElementById("dtfinal").value))
      alert ("Informe o intervalo de datas corretamente.");
    else{
      if (getObj("modelo1").checked)
        modelo = '1';
      else if (getObj("modelo2").checked)
        modelo = '2';
      else if (getObj("modelo3").checked)
        modelo = '3';
      else if (getObj("modelo4").checked)
        modelo = '4';
      else if(getObj("modelo5").checked)
        modelo ='5';
      else if(getObj("modelo6").checked){
        modelo ='6';
        $('tipodata').value = 'dtemissao';
      }

      var impressao;
      if ($("pdf").checked)
        impressao = "1";
      else if ($("excel").checked)
        impressao = "2";
      else
        impressao = "3";
        
      launchPDF('./reldespesa?acao=exportar&modelo='+modelo
          +'&impressao='+impressao
          +'&'+concatFieldValue("idfornecedor,idfilial,tipodata,dtinicial,dtfinal")
          +'&apenasFrota='+$('chk_frota').checked
          +'&grupos='+grupos
          +'&ambas='+$('ambas').checked
          +'&com_img_anexada='+$('com_img_anexada').checked
          +'&sem_img_anexada='+$('sem_img_anexada').checked
          +'&chkMostrarDespesasCFe=' + jQuery('input[name="chkMostrarDespesasCFe"]:checked').val());
    }
  }

  function aoClicarNoLocaliza(idjanela)
  {          
     if (idjanela == "Grupo"){
        addGrupo(getObj('grupo_id').value,'node_grupos', getObj('grupo').value)
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

<title>Webtrans - Relatório de despesas</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="applyFormatter();AlternarAbasGenerico('tdAbaPrincipal','tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');">
<div align="center"><img src="img/banner.gif"  alt="banner"> <br>
  <input type="hidden" name="idfornecedor" id="idfornecedor" value="0">
  <input type="hidden" name="idfilial" id="idfilial" value="<%=(temacessofiliais ? 0:Apoio.getUsuario(request).getFilial().getIdfilial())%>">
  <input type="hidden" name="grupo_id" id="grupo_id" value="0">
  <input type="hidden" name="grupo" id="grupo" value="">
</div>
<table width="90%" height="28" align="center" class="bordaFina" >
  <tr>
    <td height="22"><b>Relat&oacute;rio de despesas</b></td>
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
        <input name="modelo1" id="modelo1" type="radio" value="1" checked onClick="javascript:modelos(1);">
        Modelo 1</div></td>
    <td width="77%" colspan="2" class="CelulaZebra2"> Relação das despesas com suas duplicatas</td>
  </tr>
  <tr> 
    <td width="23%" height="24" class="TextoCampos"> <div align="left"> 
        <input name="modelo2" id="modelo2" type="radio" value="2" onClick="javascript:modelos(2);">
        Modelo 2</div></td>
    <td width="77%" colspan="2" class="CelulaZebra2"> Relação das despesas (Sintético)</td>
  </tr>
  <tr> 
    <td width="23%" height="24" class="TextoCampos"> <div align="left"> 
        <input name="modelo3" id="modelo3" type="radio" value="3" onClick="javascript:modelos(3);">
        Modelo 3</div></td>
    <td width="77%" colspan="2" class="CelulaZebra2"> Relação das despesas com impostos retidos (Sintético)</td>
  </tr>
  <tr>
    <td width="23%" height="24" class="TextoCampos"> <div align="left">
        <input name="modelo4" id="modelo4" type="radio" value="4" onClick="javascript:modelos(4);">
        Modelo 4</div></td>
    <td width="77%" colspan="2" class="CelulaZebra2"> Relação das despesas com as apropriações</td>
  </tr>
  <tr> 
    <td width="23%" height="24" class="TextoCampos"> <div align="left"> 
        <input name="modelo5" id="modelo5" type="radio" value="5" onClick="javascript:modelos(5);">
        Modelo 5</div></td>
    <td width="77%" colspan="2" class="CelulaZebra2"> Espelho da nota fiscal</td>
  </tr>
  <tr>
    <td width="23%" height="24" class="TextoCampos"> <div align="left">
        <input name="modelo6" id="modelo6" type="radio" value="6" onClick="javascript:modelos(6);">
        Modelo 6</div></td>
    <td width="77%" colspan="2" class="CelulaZebra2"> Relação das despesas (Sintético)</td>
  </tr>
  <tr class="tabela"> 
    <td colspan="3"><div align="center">Crit&eacute;rio de datas</div></td>
  </tr>
  <tr> 
    <td height="24" class="TextoCampos">Por data de:</td>
    <td colspan="2" class="CelulaZebra2"> <select id="tipodata" name="tipodata" class="inputtexto">
        <option value="dtemissao">Emissão</option>
        <option value="dtvenc" selected>Vencimento</option>
      </select>
      entre<strong> 
      <input name="dtinicial" type="text" id="dtinicial" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
	  		 onblur="alertInvalidDate(this)" class="fieldDate" />
      </strong>e<strong> 
      <input name="dtfinal" type="text" id="dtfinal" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
	  onblur="alertInvalidDate(this)" class="fieldDate" />
      </strong></td>
  </tr>
  <tr class="tabela"> 
    <td height="18" colspan="3"> 
      <div align="center">Filtros</div></td>
  </tr>
  <tr> 
    <td colspan="3"> 
        <table width="100%" border="0" >
        <tr> 
          <td width="141" class="TextoCampos"><div align="right">Apenas um fornecedor:</div></td>
          <td width="316" class="TextoCampos"><div align="left"><strong> 
              <input name="fornecedor" type="text" id="fornecedor" size="30" maxlength="80" readonly="true" class="inputReadOnly">
              <input name="localiza_forn" type="button" class="botoes" id="localiza_forn" value="..." onClick="javascript:localizaforn();">
              <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:limparforn();"> 
              </strong></div></td>
        </tr>
        <tr> 
          <td class="TextoCampos"><div align="right">Apenas uma filial:</div></td>
          <td class="TextoCampos"><div align="left"><strong> 
              <input name="fi_abreviatura" type="text" id="fi_abreviatura" value="<%=( temacessofiliais ? "":Apoio.getUsuario(request).getFilial().getAbreviatura())%>" class="inputReadOnly" size="30" maxlength="60" readonly="true">
              <% if (temacessofiliais) {%>
              <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." onClick="javascript:localizafilial();">
              <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:limparfilial();"> 
              <%}%>
              </strong></div></td>
        </tr>
        <tr>
            <td class="TextoCampos"> Mostrar Despesas: </td>
            <td class="CelulaZebra2" colspan="2">
                <input type="radio" name="ambas" id="ambas" value="radiobutton" onclick="javascript:$('com_img_anexada').checked = false;$('sem_img_anexada').checked = false;this.checked = true;" checked>Ambas
                <input type="radio" name="com_img_anexada" id="com_img_anexada" value="radiobutton" onclick="javascript:$('ambas').checked = false;$('sem_img_anexada').checked = false;this.checked = true">Com imagem anexada
                <input type="radio" name="sem_img_anexada" id="sem_img_anexada" value="radiobutton" onclick="javascript:$('com_img_anexada').checked = false;$('ambas').checked = false;this.checked = true">Sem imagem anexada
            </td>    
        </tr>
        <tr>
            <td class="TextoCampos" colspan="2"><div align="center">
                        <input name="chk_frota" type="checkbox" id="chk_frota" value="checkbox">
                        Mostrar apenas as despesas do gwFrota
              </div></td>
        </tr>
        <tr>
            <td class="TextoCampos">
                Mostrar despesas de pagamentos de contrato de frete:
            </td>
            <td class="CelulaZebra2" colspan="2">
                <input type="radio" name="chkMostrarDespesasCFe" id="chkMostrarDespesasCFeAmbos" value="ambos" checked><label for="chkMostrarDespesasCFeAmbos">Ambos</label>
                <input type="radio" name="chkMostrarDespesasCFe" id="chkMostrarDespesasCFeSim" value="sim"><label for="chkMostrarDespesasCFeSim">Sim</label>
                <input type="radio" name="chkMostrarDespesasCFe" id="chkMostrarDespesasCFeNao" value="nao"><label for="chkMostrarDespesasCFeNao">Não</label>
            </td>
        </tr>
        <tr>
            <td class="TextoCampos">Mostrar Lançamentos:</td>
            <td class="CelulaZebra2" colspan="2">
                <input type="radio" name="ctbil_ambas" id="ctbil_ambas" value="radiobutton" onclick="javascript:$('ctbil_sim').checked = false;$('ctbil_nao').checked = false;this.checked = true;" checked>Ambos
                <input type="radio" name="ctbil_nao" id="ctbil_nao" value="radiobutton" onclick="javascript:$('ctbil_ambas').checked = false;$('ctbil_sim').checked = false;this.checked = true">Contabilizados Manualmente
                <input type="radio" name="ctbil_sim" id="ctbil_sim" value="radiobutton" onclick="javascript:$('ctbil_nao').checked = false;$('ctbil_ambas').checked = false;this.checked = true">Contabilizados pelo Webtrans
            </td>    
        </tr>
        
        <input type="hidden" name="excetoGrupo" id="excetoGrupo" class="inputtexto" value="" />
        <tr class="bordaFina"> 
          <td width="24%" class="CelulaZebra2">
              <div align="center">
                  <img src="img/add.gif" border="0" title="Adicionar um novo Grupo" class="imagemLink" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=33','Grupo')">          
              </div>
          </td>
          <td width="76%" class="CelulaZebra2" >
              <div align="center">Apenas os grupos</div>
          </td>
        </tr>
        <tr> 
            <td colspan="2">
                <table width="100%" border="0">
                    <tbody id="node_grupos"></tbody>
                </table>    
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
