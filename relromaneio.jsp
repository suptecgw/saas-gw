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
                        && Apoio.getUsuario(request).getAcesso("relromaneio") > 0);
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (! temacesso))
       response.sendError(response.SC_FORBIDDEN);

  String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  
  int acessoApenasFilial = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("lanromaneiofilial") : 0);

  //exportacao da Cartafrete para arquivo .pdf
  if (acao.equals("exportar")){
      
    SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
    Date dtinicial = formatador.parse(request.getParameter("dtinicial"));
    Date dtfinal = formatador.parse(request.getParameter("dtfinal"));
    String modelo = request.getParameter("modelo");
    String motoristaAjudante = "";
    String condicaoVeiculo = "";
    int idFilial = Integer.parseInt(request.getParameter("idfilial"));
    int idVeiculo = Integer.parseInt(request.getParameter("idveiculo"));
    StringBuilder condicaoFilial= new StringBuilder();
    String opcoes = "Romaneios emitidos entre "+request.getParameter("dtinicial")+ " e " +request.getParameter("dtfinal");

    opcoes += (idVeiculo == 0 ? ", Todos os veículos" : ", Apenas o veículo:" + request.getParameter("vei_placa"));

    if(idFilial != 0){
        
        if (modelo.equals("3") || modelo.equals("4") || modelo.equals("5")){
            condicaoFilial.append(" and r.idfilial = ").append(idFilial);
        }else{
            condicaoFilial.append(" and idfilial = ").append(idFilial);
        }
        
        
        opcoes += ", Apenas a filial:" + request.getParameter("fi_abreviatura");
    }

    if (modelo.equals("1")){ //verificando se vai filtrar o motorista ou o ajudante.
        motoristaAjudante = (!request.getParameter("idmotorista").equals("0")?" and idmotorista="+request.getParameter("idmotorista"):"");
        opcoes += (!request.getParameter("idmotorista").equals("0")?", Apenas o motorista:"+request.getParameter("motor_nome"):", Todos os motoristas");
        condicaoVeiculo = (idVeiculo == 0 ? "" : " and veiculo_romaneio_id = " + String.valueOf(idVeiculo));
    }else if (modelo.equals("3")){ //verificando se vai filtrar o motorista ou o ajudante.
        motoristaAjudante = (!request.getParameter("idmotorista").equals("0")?" and mot.idmotorista="+request.getParameter("idmotorista"):"");
        opcoes += (!request.getParameter("idmotorista").equals("0")?", Apenas o motorista:"+request.getParameter("motor_nome"):", Todos os motoristas");
        condicaoVeiculo = (idVeiculo == 0 ? "" : " and idcavalo = " + String.valueOf(idVeiculo));
    }else if (modelo.equals("4")){ //verificando se vai filtrar o motorista ou o ajudante.
        motoristaAjudante = (!request.getParameter("idmotorista").equals("0")?" and mot.idmotorista="+request.getParameter("idmotorista"):"");
        opcoes += (!request.getParameter("idmotorista").equals("0")?", Apenas o motorista:"+request.getParameter("motor_nome"):", Todos os motoristas");
        condicaoVeiculo = (idVeiculo == 0 ? "" : " and idcavalo = " + String.valueOf(idVeiculo));
    }else if(modelo.equals("5")){
        motoristaAjudante = (!request.getParameter("idmotorista").equals("0")?" and moto.idmotorista="+request.getParameter("idmotorista"):"");
        opcoes += (!request.getParameter("idmotorista").equals("0")?", Apenas o motorista:"+request.getParameter("motor_nome"):", Todos os motoristas");
        condicaoVeiculo = (idVeiculo == 0 ? "" : " and r.idcavalo = " + String.valueOf(idVeiculo));
    }else{
        motoristaAjudante = (!request.getParameter("idajudante").equals("0")?" and idajudante="+request.getParameter("idajudante"):"");
        opcoes += (!request.getParameter("idajudante").equals("0")?", Apenas o ajudante:"+request.getParameter("nome"):", Todos os ajudantes");
        condicaoVeiculo = (idVeiculo == 0 ? "" : " and veiculo_romaneio_id = " + String.valueOf(idVeiculo));
    }
    java.util.Map param = new java.util.HashMap(10);
    param.put("DATA_INI", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtinicial)+"'");
    param.put("DATA_FIM", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtfinal)+"'");
    param.put("IDMOTORISTA", motoristaAjudante);
    param.put("VEICULO", condicaoVeiculo);
    param.put("IDFILIAL", condicaoFilial.toString());
    param.put("OPCOES", opcoes);
    param.put("SITUACAO", request.getParameter("situacao"));
    param.put("USUARIO",Apoio.getUsuario(request).getNome());     
    param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
    
    request.setAttribute("map", param);
    request.setAttribute("rel", "relromaneiomod"+modelo);
    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
    dispacher.forward(request, response);
    }else if(acao.equals("iniciar")){
             request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_ROMANEIO_RELATORIO.ordinal());
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

    switch(parseInt(modelo)){
        case 1:
            getObj("trMotorista").style.display = "";
            getObj("trAjudante").style.display = "";
            break;
        case 2:
            getObj("trMotorista").style.display = "";
            getObj("trAjudante").style.display = "";
            break;
        case 3:
            getObj("trMotorista").style.display = "";
            getObj("trAjudante").style.display = "none";
            break;
        case 4:
            getObj("trMotorista").style.display = "none";
            getObj("trAjudante").style.display = "none";
            break;
        case 5:
            getObj("trMotorista").style.display = "";
            getObj("trAjudante").style.display = "none";
            break;
        }
  }

  function localizamotorista(){
      post_cad = window.open('./localiza?acao=consultar&idlista=10','Motorista',
                     'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
  }

  function localizaajudante(){
      post_cad = window.open('./localiza?acao=consultar&idlista=25','Ajudante',
                     'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
  }

  function popRel(){
    var modelo; 
    if (! validaData(getObj("dtinicial").value) || ! validaData(getObj("dtfinal").value))
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
      else if (getObj("modelo5").checked)
        modelo = '5';
      var impressao;
      if ($("pdf").checked)
        impressao = "1";
      else if ($("excel").checked)
        impressao = "2";
      else
        impressao = "3";

        
      launchPDF('./relromaneio?acao=exportar&modelo='+modelo+'&impressao='+impressao+'&'+concatFieldValue("dtinicial,dtfinal,idmotorista,motor_nome,idajudante,nome,idfilial,fi_abreviatura,idveiculo,vei_placa,situacao"));
    }
  }

    function localizaveiculo(){
        post_cad = window.open('./localiza?acao=consultar&idlista=7','Veiculo',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }
    
    function condicaoFilial(){
        if (<%=acessoApenasFilial == 0%>) {
            console.log("AAA chega aqui");
            $("localiza_filial").style.display = "none";
            $("btnLimparFilial").style.display = "none";
            $("fi_abreviatura").value = $("descFilialUsuario").value;
            $("idfilial").value = $("idFilialUsuario").value;
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

<title>Webtrans - Relatório de Romaneios</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="applyFormatter();AlternarAbasGenerico('tdAbaPrincipal','tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');condicaoFilial();">
<div align="center"><img src="img/banner.gif"  alt="banner"> <br>
  <input type="hidden" name="idmotorista" id="idmotorista" value="0">
  <input type="hidden" name="idajudante" id="idajudante" value="0">
  <input type="hidden" name="idfilial" id="idfilial" value="0">
  <input type="hidden" name="idFilialUsuario" id="idFilialUsuario" value="<%=(Apoio.getUsuario(request).getFilial().getIdfilial())%>">
  <input type="hidden" name="descFilialUsuario" id="descFilialUsuario" value="<%=(Apoio.getUsuario(request).getFilial().getAbreviatura())%>">
</div>
<table width="90%" height="28" align="center" class="bordaFina" >
  <tr>
    <td height="22"><b>Relat&oacute;rio de Romaneios</b></td>
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
        <input type="radio" name="modelo1" id="modelo1" value="1" checked onClick="javascript:modelos(1);">
        Modelo 1 </div></td>
    <td width="378" colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de 
      romaneios por motorista (Anal&iacute;tico).</td>
  </tr>
  <tr> 
    <td width="99" height="24" class="TextoCampos"> <div align="left">
        <input type="radio" name="modelo2" id="modelo2" value="2" onClick="javascript:modelos(2);">
        Modelo 2</div></td>
    <td width="378" colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de
      romaneios por ajudante (Sint&eacute;tico).</td>
  </tr>
  <tr>
    <td width="99" height="24" class="TextoCampos"> <div align="left">
        <input type="radio" name="modelo3" id="modelo3" value="3" onClick="javascript:modelos(3);">
        Modelo 3</div></td>
        <td width="378" colspan="2" class="CelulaZebra2">Relat&oacute;rio de
      romaneios.</td>
  </tr>
  <tr>
    <td width="99" height="24" class="TextoCampos"> <div align="left">
        <input type="radio" name="modelo4" id="modelo4" value="4" onClick="javascript:modelos(4);">
        Modelo 4</div></td>
        <td width="378" colspan="2" class="CelulaZebra2">Relat&oacute;rio diário de
      romaneios.</td>
  </tr>
  <tr>
    <td width="99" height="24" class="TextoCampos"> <div align="left">
        <input type="radio" name="modelo5" id="modelo5" value="5" onClick="javascript:modelos(5);">
        Modelo 5</div></td>
        <td width="378" colspan="2" class="CelulaZebra2">Relação de Romaneios com taxa de ocupação.</td>
  </tr>
  <tr class="tabela">
    <td colspan="3"><div align="center">Crit&eacute;rio de datas</div></td>
  </tr>
  <tr> 
    <td class="TextoCampos">Emitidos entre:</td>
    <td colspan="2" class="CelulaZebra2"> <strong> 
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
        <tr id="trMotorista">
          <td width="50%" class="TextoCampos">Apenas o motorista:</td>
          <td width="338" class="CelulaZebra2" colspan="2" ><strong> 
            <input name="motor_nome" type="text" id="motor_nome" class="inputReadOnly" value="" size="35" maxlength="80" readonly="true">
            <input name="localiza_motorista" type="button" class="botoes" id="localiza_motorista" value="..." onClick="javascript:localizamotorista();">
            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:getObj('idmotorista').value = '0';javascript:getObj('motor_nome').value = '';"> 
            </strong></td>
        </tr>
        <tr id="trVeiculo">
           <td class="TextoCampos">Apenas um ve&iacute;culo:</td>
           <td class="CelulaZebra2" colspan="1">    
              <input type="hidden" name="idveiculo" id="idveiculo" value="0">
              <input name="vei_placa" type="text" id="vei_placa" class="inputReadOnly" value="" size="10" maxlength="80" readonly="true">
              <input name="localiza_vei" type="button" class="botoes" id="localiza_vei" value="..." onClick="javascript:localizaveiculo();">
              <img src="img/borracha.gif" name="limpavei" border="0" align="absbottom" class="imagemLink" id="limpavei" title="Limpar Veículo" onClick="javascript:getObj('idveiculo').value = '0';javascript:getObj('vei_placa').value = '';">
           </td>
           
        </tr>
        <tr>
            <td height="24" class="TextoCampos"><div align="right">Apenas uma filial:</div></td>
            <td class="TextoCampos"  colspan="2">
                <div align="left">
                    <strong>
                        <input name="fi_abreviatura" type="text" id="fi_abreviatura" value="" class="inputReadOnly" size="20" maxlength="60" readonly="true">
                        <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=8','Filial','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                        <img  name="btnLimparFilial" id="btnLimparFilial"  src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:$('idfilial').value = 0; $('fi_abreviatura').value = '';">
                    </strong>
                </div>
            </td>
        </tr>

        <tr id="trAjudante">
          <td width="133" class="TextoCampos">Apenas o ajudante:</td>
          <td width="338" class="CelulaZebra2"  colspan="2"><strong> 
            <input name="nome" type="text" id="nome" class="inputReadOnly" value="" size="35" maxlength="80" readonly="true">
            <input name="localiza_ajud" type="button" class="botoes" id="localiza_ajud" value="..." onClick="javascript:localizaajudante();">
            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:getObj('idajudante').value = '0';javascript:getObj('nome').value = '';"> 
            </strong></td>
        </tr>
        <tr>
            <td class="TextoCampos">Apenas o status:</td>
            <td class="CelulaZebra2">
               <select name="situacao" id="situacao" class="fieldMin">
                   <option value="" selected>Todas</option>
                   <option value="a" >Em aberto</option>
                   <option value="f">Finalizadas</option>
               </select>
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
        </div>
    </td>
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
