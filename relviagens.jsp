<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
          import="nucleo.BeanConfiguracao,
                  java.text.*,
                  java.util.Date,
                  nucleo.Apoio" errorPage="" %>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>

<% boolean temacesso = (Apoio.getUsuario(request) != null
                        && Apoio.getUsuario(request).getAcesso("relviagenstrans") > 0);
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (! temacesso))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA

  String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao") );

  //exportacao da Cartafrete para arquivo .pdf
  if (acao.equals("exportar"))
  {
    SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
    String cliente = "";
    String veiculo = (request.getParameter("idveiculo").equals("0") ? "" : " and v.idveiculo = " + request.getParameter("idveiculo"));
    StringBuilder motorista = new StringBuilder(); // (request.getParameter("idmotorista").equals("0") ? "" : " and idmotorista = " + request.getParameter("idmotorista"));
    String ajudante = ""; // (request.getParameter("idajudante").equals("0") ? "" : " and t.ajudante_id = " + request.getParameter("idajudante"));
    String funcionario = ""; //(request.getParameter("idfuncionario").equals("0") ? "" : " and t.fornecedor_id = " + request.getParameter("idfuncionario"));
    String filial = "";
    Date dtinicial = formatador.parse(request.getParameter("dtinicial"));
    Date dtfinal = formatador.parse(request.getParameter("dtfinal"));
    String status = request.getParameter("status");
    //Verificando se vai filtrar apenas um consignatário
    if(request.getParameter("modelo").equals("1")){
        if(request.getParameter("tipo_beneficiario").equals("m")){
            motorista.append(request.getParameter("idmotorista").equals("0") ? "" : " and v.idmotorista = " + request.getParameter("idmotorista"));
        }else if(request.getParameter("tipo_beneficiario").equals("a")){
            motorista.append(request.getParameter("idajudante").equals("0") ? "" : " and v.id_ajudante = " + request.getParameter("idajudante"));
        }else if(request.getParameter("tipo_beneficiario").equals("f")){
            motorista.append(request.getParameter("idfuncionario").equals("0") ? "" : " and v.id_funcionario = " + request.getParameter("idfuncionario"));
        }else if(request.getParameter("tipo_beneficiario").equals("todos")){

            motorista.append(" AND (CASE WHEN tipo_beneficiario  = 'Motorista' THEN "+(request.getParameter("idmotorista").equals("0") ? "TRUE " : "  v.idmotorista=" + request.getParameter("idmotorista")) );
            motorista.append(" WHEN  tipo_beneficiario = 'Ajudante' THEN ").append(request.getParameter("idajudante").equals("0")? " TRUE " : "  v.id_ajudante="+request.getParameter("idajudante"));
            motorista.append(" WHEN tipo_beneficiario  = 'Funcionário' THEN ").append(request.getParameter("idfuncionario").equals("0") ? "TRUE " : "  v.id_funcionario="+request.getParameter("idfuncionario")).append(" END)");
        }
    }else{
         if(request.getParameter("tipo_beneficiario").equals("m")){
            motorista.append(request.getParameter("idmotorista").equals("0") ? "" : " and mot.idmotorista = " + request.getParameter("idmotorista"));
        }else if(request.getParameter("tipo_beneficiario").equals("a")){
            motorista.append(request.getParameter("idajudante").equals("0") ? "" : " and t.ajudante_id = " + request.getParameter("idajudante"));
        }else if(request.getParameter("tipo_beneficiario").equals("f")){
            motorista.append(request.getParameter("idfuncionario").equals("0") ? "" : " and t.fornecedor_id = " + request.getParameter("idfuncionario"));
        }else if(request.getParameter("tipo_beneficiario").equals("todos")){

            motorista.append(" AND (CASE WHEN beneficiario = 'm' THEN "+(request.getParameter("idmotorista").equals("0") ? "TRUE " : "  mot.idmotorista=" + request.getParameter("idmotorista")) );
            motorista.append(" WHEN beneficiario = 'a' THEN ").append(request.getParameter("idajudante").equals("0")? " TRUE " : "  t.ajudante_id="+request.getParameter("idajudante"));
            motorista.append(" WHEN beneficiario = 'f' THEN ").append(request.getParameter("idfuncionario").equals("0") ? "TRUE " : "  t.fornecedor_id="+request.getParameter("idfuncionario")).append(" END)");
        }
    }
    
    
    if(request.getParameter("modelo").equals("2") || request.getParameter("modelo").equals("3") || request.getParameter("modelo").equals("4")){
       cliente = (!request.getParameter("idconsignatario").equals("0")?" AND sal.consignatario_id="+request.getParameter("idconsignatario"):"");
    }else {
       cliente = (!request.getParameter("idconsignatario").equals("0")?" AND idcliente="+request.getParameter("idconsignatario"):"");
    }
    
    //Verificando se vai filtrar apenas uma filial
    if(request.getParameter("modelo").equals("2") && request.getParameter("modelo")!= null){
       filial = (!request.getParameter("idfilial").equals("0")?" AND t.filial_id="+request.getParameter("idfilial"):"");
    }else {
       filial = (!request.getParameter("idfilial").equals("0")? (request.getParameter("modelo").equals("3")?" and t.filial_id="+request.getParameter("idfilial") : " and v.filial_id="+request.getParameter("idfilial")):  "");
    }
    
    String tipodata = "";
    if (request.getParameter("modelo").equals("1") && request.getParameter("tipodata").equals("emissao_em")) {
        tipodata = "emissao_ctrc";
    }else{
        tipodata = request.getParameter("tipodata");
    }
    
    //Verificando o critério de datas
    java.util.Map param = new java.util.HashMap(6);
    param.put("TIPODATA", tipodata);
    param.put("DATA_INI", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtinicial)+"'");
    param.put("DATA_FIM", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtfinal)+"'");
    param.put("IDCLIENTE", cliente);
    param.put("IDMOTORISTA", motorista.toString());
    param.put("IDAJUDANTE", ajudante);
    param.put("IDFUNCIONARIO", funcionario);
    param.put("IDVEICULO", veiculo);
    param.put("IDFILIAL", filial);
    param.put("ABERTA", !status.equals("todas") && !status.equals("cancelada") ? " and t.is_baixada = " + status + " AND NOT t.is_cancelada " : status.equals("cancelada") ? " AND t.is_cancelada = TRUE " : " ");
//    param.put("GRUPOS", (request.getParameter("grupos").equals("")?"":" and grupo_id IN("+request.getParameter("grupos")+")" ));
    param.put("OPCOES", "Período selecionado: " + 
            request.getParameter("dtinicial") + " até " + request.getParameter("dtfinal") +"."+
            (request.getParameter("idveiculo").equals("0") ? "" :
                "Apenas o veículo:" +request.getParameter("vei_placa").equals("0") + ".")+
                (request.getParameter("idmotorista").equals("0") ? "" :
                "Apenas o motorista:" +request.getParameter("motor_nome").equals("0") + ".")+
                (!status.equals("todas")?(status.equals("true")?"Apenas as viagens baixadas.":"Apenas as viagens em aberto."):""));
    
    param.put("USUARIO",Apoio.getUsuario(request).getNome());     
    param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
    request.setAttribute("map", param);
    request.setAttribute("rel", "relviagemmod"+request.getParameter("modelo"));
    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
    dispacher.forward(request, response);
    }else{
       request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_VIAGEM_RELATORIO.ordinal());
    }    
  
%>

<script language="javascript" type="text/javascript">
    function verMotorista(){
        var mostrar = false;
        var idMotorista = 0;
        if ($('idmotorista').value != '0'){
            idMotorista = $('idmotorista').value;
            mostrar = true;
        }
                 
        if (mostrar)
            window.open('./cadmotorista?acao=editar&id=' + idMotorista ,'Motorista','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
    }


    function verVeiculo(tipo){
        var mostrar = false;
        var idVeiculo = 0;
        if (tipo == 'V' && $('idveiculo').value != '0'){
            idVeiculo = $('idveiculo').value;
            mostrar = true;
        }else if (tipo == 'C' && $('idcarreta').value != '0'){
            idVeiculo = $('idcarreta').value;
            mostrar = true;
        }
                 
        if (mostrar)
            window.open('./cadveiculo?acao=editar&id=' + idVeiculo ,'Veículo','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
    }
	
  function voltar(){
     location.replace("./menu");
  }

  function modelos(modelo){
        $("divAberta").style.display = "none";
        //$("trCliente").style.display = "none";

        $("modelo1").checked = false;
        $("modelo2").checked = false;
        $("modelo3").checked = false;
        $("modelo4").checked = false;

//    $("modelo4").checked = false;
    
        $("modelo"+modelo).checked = true;

        
        if (modelo == "1"){
            //$("trCliente").style.display = "";
        }else if (modelo == "2"){
            $("divAberta").style.display = "";
            //$("trCliente").style.display = "";
        }else if (modelo == "3"){
            $("divAberta").style.display = "";
            //$("trCliente").style.display = "";
        }else{
            
        }
  }

  function localizacliente(){
     	post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=5','Cliente',
                        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
  }

  function limparclifor(){
    $("idconsignatario").value = "0";
    $("con_rzs").value = "";
  }

  function popRel(){
    var modelo; 
    
    if (! validaData($("dtinicial").value) || !validaData($("dtfinal").value))
      alert ("Informe o intervalo de datas corretamente.");
    else{
      if ($("modelo1").checked)
        modelo = '1';
      else if ($("modelo2").checked)
        modelo = '2';
      else if ($("modelo3").checked)
        modelo = '3';
        else if($("modelo4").checked)
        modelo = '4';

      var impressao;
      if ($("pdf").checked)
        impressao = "1";
        else if ($("excel").checked)
            impressao = "2";
        else
            impressao = "3";

    
      launchPDF('./relviagens.jsp?acao=exportar&modelo='+modelo+'&impressao='+impressao+
          '&idconsignatario='+$("idconsignatario").value+'&idfilial='+$("idfilial").value+
          '&tipodata='+$("tipodata").value+'&dtinicial='+$("dtinicial").value+
          '&dtfinal='+$("dtfinal").value+'&motor_nome='+$("motor_nome").value+
          '&idmotorista='+$("idmotorista").value+'&idveiculo='+$("idveiculo").value+
          '&idajudante='+jQuery('#idajudante').val()+'&idfuncionario='+jQuery('[name=idfuncionario]').val()+
          '&vei_placa='+$("vei_placa").value + '&status='+$("status").value + '&tipo_beneficiario='+$("tipo_beneficiario").value); 
    }
  }
  
  function tipoBeneficiario(e){
      $('idmotorista').value = 0;
      $('motor_nome').value = "";
      
      $('idajudante').value = 0;
      $('nome').value = '';
      $('idfornecedor').value = 0;
      $('fornecedor').value = '';
      jQuery('#tr-motorista').hide();
      jQuery('#tr-ajudante').hide();
      jQuery('#tr-funcionario').hide();
      
      switch(e.value){
          case "todos":
              jQuery('#tr-motorista').show();
              jQuery('#tr-ajudante').show();
              jQuery('#tr-funcionario').show();
              break;
          case "m":
              jQuery('#tr-motorista').show();
              break;
          case "a":
              jQuery('#tr-ajudante').show();
              break;
          case "f":
              jQuery('#tr-funcionario').show();
              break;
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

<title>Webtrans - Relatório de viagens</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="applyFormatter();AlternarAbasGenerico('tdAbaPrincipal','tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');">
<div align="center"><img src="img/banner.gif"  alt="banner"> <br>
  <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
  <input type="hidden" name="idfilial" id="idfilial" value="0">
  <input type="hidden" name="grupo_id" id="grupo_id" value="0">
  <input type="hidden" name="grupo" id="grupo" value="">
  <input type="hidden" id="idmotorista" value="0">
  <input type="hidden" id="idajudante" value="0">
  <input type="hidden" id="idfornecedor" name="idfuncionario" value="0">
          <input type="hidden" id="idveiculo" value="0">
</div>
<table width="90%" height="28" align="center" class="bordaFina" >
  <tr>
    <td height="22"><b>Relat&oacute;rio de viagens</b></td>
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
    <td width="77%" colspan="2" class="CelulaZebra2"> Relat&oacute;rio de viagens baixadas com as despesas </td>
  </tr>
  <tr>
    <td width="23%" height="24" class="TextoCampos"> <div align="left">
        <input name="modelo2" id="modelo2" type="radio" value="2" onClick="javascript:modelos(2);">
        Modelo 2</div></td>
    <td width="77%" colspan="2" class="CelulaZebra2"> Relat&oacute;rio de viagens </td>
  </tr>
  <tr>
    <td width="23%" height="24" class="TextoCampos"> <div align="left">
        <input name="modelo3" id="modelo3" type="radio" value="3" onClick="javascript:modelos(3);">
        Modelo 3</div></td>
    <td width="77%" colspan="2" class="CelulaZebra2"> Relat&oacute;rio de viagens </td>
  </tr>
  <tr>
    <td width="23%" height="24" class="TextoCampos"> <div align="left">
        <input name="modelo4" id="modelo4" type="radio" value="4" onClick="javascript:modelos(4);">
        Modelo 4</div></td>
    <td width="77%" colspan="2" class="CelulaZebra2"> Relat&oacute;rio das despesas de viagens </td>
  </tr>

  <tr class="tabela"> 
    <td colspan="3"><div align="center">Crit&eacute;rio de datas</div></td>
  </tr>
  <tr> 
    <td height="24" class="TextoCampos">Por data de:</td>
    <td colspan="2" class="CelulaZebra2"> <select id="tipodata" name="tipodata" class="inputtexto">
      <option value="saida_em" selected>Viagem (Saída)</option>
      <option value="chegada_em">Viagem (Chegada)</option>
      <option value="emissao_em">CT</option>
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
    <td height="18" colspan="3"> <div align="center">Filtros</div></td>
  </tr>
  <tr> 
    <td colspan="3">
        <table width="100%" border="0" >
            <tr id="trCliente">
          <td class="TextoCampos" width="50%"><div align="right">Apenas um cliente:</div></td>
          <td  class="TextoCampos" colspan="2"><div align="left"><strong>
              <input name="con_rzs" type="text" id="con_rzs" class="inputReadOnly" size="35" maxlength="80" readonly="true">
              <input name="localiza_clifor" type="button" class="botoes" id="localiza_clifor4" value="..." onClick="javascript:localizacliente();">
   	      <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:limparclifor();">
              </strong></div></td>
        </tr>
        <tr>
          <td class="TextoCampos"><div align="right">Apenas uma filial:</div></td>
          <td class="TextoCampos" colspan="2"><div align="left"><strong>
              <input name="fi_abreviatura" type="text" id="fi_abreviatura" value="" class="inputReadOnly" size="20" maxlength="60" readonly="true">
              <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=8','Filial','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
   	      <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:$('idfilial').value = 0; $('fi_abreviatura').value = '';">
              </strong></div></td>
        </tr>
        <tr>
            <td class="TextoCampos">Apenas os beneficiários:</td>
            <td class="CelulaZebra2" colspan="2">
                <select name="tipo_beneficiario" id="tipo_beneficiario" class="inputtexto" onchange="tipoBeneficiario(this);">
                    <option value="todos">Todos</option>
                    <option value="m">Motorista</option>
                    <option value="a">Ajudante</option>
                    <option value="f">Funcionario</option>
                </select>
            </td>
        </tr>
        <tr id="tr-motorista">
          <td  class="TextoCampos">Apenas o motorista:</td>
          <td class="CelulaZebra2" colspan="2">
            <input name="motor_nome" type="text" class="inputReadOnly" id="motor_nome" size="40" value="" readonly="true">
            <input name="button" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=10','Motorista')" value="...">
            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Motorista" onClick="javascript:getObj('idmotorista').value = 0;javascript:getObj('motor_nome').value = '';">
          </td>
        </tr>
        <tr id="tr-ajudante"> 
          <td  class="TextoCampos">Apenas o ajudante:</td>
          <td class="CelulaZebra2" colspan="2">
            <input name="nome" type="text" class="inputReadOnly" id="nome" size="40" value="" readonly="true">
            <input name="button" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=25','Ajudante')" value="...">
            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Ajudante" onClick="javascript:getObj('idajudante').value = 0;javascript:getObj('nome').value = '';">
          </td>
        </tr>
        <tr id="tr-funcionario">
          <td  class="TextoCampos">Apenas o funcionário:</td>
          <td class="CelulaZebra2" colspan="2">
            <input name="fornecedor" type="text" class="inputReadOnly" id="fornecedor" size="40" value="" readonly="true">
            <input name="button" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=21&paramaux2=1','Funcionário')" value="...">
            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Funcionário" onClick="javascript:getObj('idfornecedor').value = 0;javascript:getObj('fornecedor').value = '';">
          </td>
        </tr>
        <tr> 
          <td class="TextoCampos">Apenas o veiculo:</td>
          <td class="CelulaZebra2">
            <input name="vei_placa" type="text" class="inputReadOnly" id="vei_placa" value="" size="10" readonly="true">
            <input name="localiza_veiculo" type="button" class="botoes" id="localiza_veiculo" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=7','Veiculo')" value="...">
            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Ve&iacute;culo" onClick="javascript:getObj('idveiculo').value = 0;javascript:getObj('vei_placa').value = '';">
          </td>
          <td class="CelulaZebra2" >
              <div id="divAberta" style="display:none">
                  <select id="status" name="status" class="inputtexto">
                        <option value="todas" >Todas</option>
                        <option value="false" selected>Viagens abertas</option>
                        <option value="true" >Viagens fechadas</option>
                        <option value="cancelada" >Viagens canceladas</option>
                    </select>
              </div>
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
