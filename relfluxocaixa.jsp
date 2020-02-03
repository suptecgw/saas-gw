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
                        && Apoio.getUsuario(request).getAcesso("relfluxocaixa") > 0);
   boolean temacessofiliais = (Apoio.getUsuario(request) != null
                        && Apoio.getUsuario(request).getAcesso("reloutrasfiliais") > 0);
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (! temacesso))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA
  boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
  int idUsuario = Apoio.getUsuario(request).getIdusuario();
  String modelo = request.getParameter("modelo");
  String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao") );

  //exportacao da Cartafrete para arquivo .pdf
  if (acao.equals("exportar"))
  {
    SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
    Date dtinicial = formatador.parse(request.getParameter("dtinicial"));
    Date dtfinal = formatador.parse(request.getParameter("dtfinal"));
    String tipoDataR = "";
    String tipoDataP = "";
    java.util.Map param = new java.util.HashMap(10);
    param.put("FILIAL_ID", (!request.getParameter("idfilial").equals("0")?" AND c.idfilial="+request.getParameter("idfilial"):""));
    if (modelo.equals("1")){
        param.put("FILIAL", (!request.getParameter("idfilial").equals("0")?" AND filial_id="+request.getParameter("idfilial"):""));
    }else if (modelo.equals("2")){
        param.put("FILIAL", (!request.getParameter("idfilial").equals("0")?" AND filial_id="+request.getParameter("idfilial"):""));
        param.put("FILIAL_ID", (!request.getParameter("idfilial").equals("0")?" AND idfilial="+request.getParameter("idfilial"):""));
    }else if (modelo.equals("3")){
        param.put("FILIAL", (!request.getParameter("idfilial").equals("0")?" AND filial_id="+request.getParameter("idfilial"):""));
        param.put("FILIAL_ID", (!request.getParameter("idfilial").equals("0")?" AND idfilial="+request.getParameter("idfilial"):""));
    }else{
        param.put("FILIAL", (!request.getParameter("idfilial").equals("0")?" AND idfilial="+request.getParameter("idfilial"):""));
    }
    param.put("CONCILIADO", (request.getParameter("tipolancamento").equals("todos") 
    		                 ? "" 
    		                 : (request.getParameter("tipolancamento").equals("conciliados") 
    		                	?" AND (mb.conciliado OR mb.conciliado is null) "
    		                	:" AND (not mb.conciliado OR mb.conciliado is null) ")));
    if (modelo.equals("2")){
        param.put("CONTAS", (request.getParameter("contas").equals("")?" AND c.idconta=0":" AND c.idconta IN ("+request.getParameter("contas")+")"));
    }else if (modelo.equals("3")){
        param.put("CONTAS", (request.getParameter("contas").equals("")?" AND mb.idconta=0":" AND mb.idconta IN ("+request.getParameter("contas")+")"));
        param.put("CONTAS_1", (request.getParameter("contas").equals("")?" AND r.idconta=0":" AND r.idconta IN ("+request.getParameter("contas")+")"));
        param.put("CONTAS_2", (request.getParameter("contas").equals("")?" AND p.idconta=0":" AND p.idconta IN ("+request.getParameter("contas")+")"));
        if (request.getParameter("tipodatamod3").equals("pagamento")){
            tipoDataR = "r.pago_em";
            tipoDataP = "p.dtpago";
        }else if (request.getParameter("tipodatamod3").equals("emissao_conciliacao")){
            tipoDataR = "emissao_conciliacao";
            tipoDataP = "dtemissao";
        }else if (request.getParameter("tipodatamod3").equals("entrada_conciliacao")){
            tipoDataR = "entrada_conciliacao";
            tipoDataP = "dtentrada";
        }
        param.put("TIPO_DATA_R", tipoDataR);
        param.put("TIPO_DATA_P", tipoDataP);
    }else{
        param.put("CONTAS", (request.getParameter("contas").equals("")?" AND mb.idconta=0":" AND mb.idconta IN ("+request.getParameter("contas")+")"));
    }
    param.put("DATA_INI", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtinicial)+"'");
    param.put("DATA_FIM", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtfinal)+"'");
    param.put("OPCOES", "Período selecionado: " + request.getParameter("dtinicial") + " até " + request.getParameter("dtfinal"));

    
    //INICIO DA NOVA ESTRUTURA DE PARAMETROS NOS RELATORIOS 
    param.put("TIPO_CREDITO",request.getParameter("tipoCredito")); //CONDICAO_CREDITO no JRXML
    
    param.put("USUARIO",Apoio.getUsuario(request).getNome());     
    param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
    //FIM DA NOVA ESTRUTURA DE PARAMETROS NOS RELATORIOS 
    
    request.setAttribute("map", param);
    request.setAttribute("rel", "relfluxocaixamod"+modelo);
    
    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
                dispacher.forward(request, response);
    
    }else if (acao.equals("iniciar")){
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_FLUXO_CAIXA_RELATORIO.ordinal());
    
    }
%>


<script language="javascript" type="text/javascript">
  function voltar(){
     location.replace("./menu");
  }

  function modelos(modelo){

    getObj("modelo1").checked = false;
    getObj("modelo2").checked = false;
    getObj("modelo3").checked = false;
    getObj("modelo4").checked = false;
    getObj("modelo5").checked = false;
    
    getObj("modelo"+modelo).checked = true;

    $('tipodata').disabled = false;
    $('tipodata').style.display = '';
    $('tipodatamod3').style.display = 'none';
    $('trCreditos').style.display = 'none';

    if (modelo == '1'){
        $('tipodata').value = 'vencimento';
        $('trCreditos').style.display = '';
    }else if (modelo == '2'){
        $('tipodata').value = 'pagamento';
    }else if (modelo == '3'){
        $('tipodata').style.display = 'none';
        $('tipodatamod3').style.display = '';
    }else if (modelo == '4'){
        $('tipodata').value = 'pagamento';
    }else if (modelo == '5'){
        $('tipodata').value = 'vencimento';
    }
    $('tipodata').disabled = true;

  }
  
  function localizafilial(){
      post_cad = window.open('./localiza?acao=consultar&idlista=8','Filial',
                     'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
  }

  function limparfilial(){
    document.getElementById("idfilial").value = 0;
    document.getElementById("fi_abreviatura").value = "";
  }

  function popRel(qtdlinhas){
    var modelo;
    
    if (! validaData($("dtinicial").value) || !validaData($("dtfinal").value))
      alert ("Informe o intervalo de datas corretamente.");
    else{
      if ($("modelo1").checked){
        modelo = '1';
      }if ($("modelo2").checked){
        modelo = '2';
      }if ($("modelo3").checked){
        modelo = '3';
      }if ($("modelo4").checked){
        modelo = '4';
      }if ($("modelo5").checked){
        modelo = '5';
      }

      var resultado = "";
      
      for (var i = 0; i <= qtdlinhas - 1; ++i){
          
         if ($("conta"+i) != null && $("conta"+i).checked){
            if (resultado != "")
               resultado += ",";
        
            resultado += $("conta"+i).value;
         
      }
      }
      
      var impressao;
      if ($("pdf").checked)
        impressao = "1";
      else if ($("excel").checked)
        impressao = "2";
      else
        impressao = "3";

      launchPDF('./relfluxocaixa.jsp?acao=exportar&modelo='+modelo+'&impressao='+impressao+'&contas='+resultado+'&'+concatFieldValue("idfilial,dtinicial,dtfinal,tipolancamento,tipoCredito,tipodatamod3"));


    }
  }

  function marcarDesrmarcarTodas(){
      var countLinhas = parseInt($('qtdContas').value);
      for (var i = 0; i <= countLinhas - 1; ++i){
          if ($("conta"+i) != null){
             $("conta"+i).checked = $('marcarTodas').checked;
          }
      }
  }
  
</script>

<%@page import="mov_banco.conta.BeanConsultaConta"%>
<%@page import="java.sql.ResultSet"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="pt" />
<meta http-equiv="cache-control" content="no-cache" />
<meta http-equiv="pragma" content="no-store" />
<meta http-equiv="expires" content="0" />
<meta name="language" content="pt-br" />

<title>Webtrans - Relatório de fluxo de caixa</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="applyFormatter();AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>);">
<div align="center"><img src="img/banner.gif"  alt="banner"> <br>
  <input type="hidden" name="idveiculo" id="idveiculo" value="0">
  <input type="hidden" name="idplanocusto" id="idplanocusto" value="0">
  <input type="hidden" name="idfilial" id="idfilial" value="<%=(temacessofiliais ? 0:Apoio.getUsuario(request).getFilial().getIdfilial())%>">
</div>
<table width="90%" height="28" align="center" class="bordaFina" >
  <tr>
    <td height="22"><b>Relat&oacute;rio de fluxo de caixa </b></td>
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
    <td width="23%" class="TextoCampos"> <div align="left"> 
        <input name="modelo1" id="modelo1" type="radio" value="1" checked onClick="javascript:modelos(1);">
        Modelo 1</div></td>
    <td colspan="2" class="CelulaZebra2"> Fluxo de caixa - A realizar (Sintético) </td>
  </tr>
  <tr>
    <td class="TextoCampos"> <div align="left">
        <input name="modelo2" id="modelo2" type="radio" value="2" onClick="javascript:modelos(2);">
        Modelo 2</div></td>
    <td colspan="2" class="CelulaZebra2"> Fluxo de caixa - Realizado (Analítico por cliente) </td>
  </tr>
  <tr>
    <td class="TextoCampos"> <div align="left">
        <input name="modelo3" id="modelo3" type="radio" value="3" onClick="javascript:modelos(3);">
        Modelo 3</div></td>
    <td colspan="2" class="CelulaZebra2"> Fluxo de caixa - Realizado (Relação de recebimentos e pagamentos) </td>
  </tr>
  <tr>
    <td class="TextoCampos"> <div align="left">
        <input name="modelo4" id="modelo4" type="radio" value="4" onClick="javascript:modelos(4);">
        Modelo 4</div></td>
    <td colspan="2" class="CelulaZebra2"> Fluxo de caixa - Realizado (Resumo de recebimentos no período) </td>
  </tr>
  <tr>
    <td class="TextoCampos"> <div align="left">
        <input name="modelo5" id="modelo5" type="radio" value="5" onClick="javascript:modelos(5);">
        Modelo 5</div></td>
    <td colspan="2" class="CelulaZebra2"> Fluxo de caixa - A realizar (Analítico) </td>
  </tr>
  <tr class="tabela"> 
    <td colspan="3"><div align="center">Crit&eacute;rio de datas</div></td>
  </tr>
  <tr> 
    <td height="24" class="TextoCampos">Por data de :</td>
    <td width="31%" class="CelulaZebra2">
    <select id="tipodata" name="tipodata" class="inputtexto" disabled>
      <option value="vencimento" selected>Vencimento</option>
      <option value="pagamento">Pagamento</option>
    </select> 
    <select id="tipodatamod3" name="tipodatamod3" class="inputtexto" style="display: none;">
      <option value="pagamento" selected>Pagamento</option>
      <option value="emissao_conciliacao" >Emissão (Conciliação)</option>
      <option value="entrada_conciliacao" >Entrada (Conciliação)</option>
    </select> 
     entre </td>
    <td width="46%" class="CelulaZebra2"> <strong> 
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
          <td width="23%" class="TextoCampos"><div align="right">Apenas uma filial:</div></td>
          <td width="393" class="TextoCampos"><div align="left"><strong> 
              <input name="fi_abreviatura" type="text" id="fi_abreviatura" value="<%=( temacessofiliais ? "":Apoio.getUsuario(request).getFilial().getAbreviatura())%>" class="inputReadOnly" size="35" maxlength="60" readonly="true">
              <% if (temacessofiliais) {%>
              <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." onClick="javascript:localizafilial();">
              <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:limparfilial();"> 
              <%}%>
              </strong></div></td>
        </tr>
        <tr>
          <td colspan="2" class="celula"><div align="center">Saldo inicial </div></td>
        </tr>
        <tr>
          <td class="TextoCampos">Apenas os lan&ccedil;amentos: </td>
          <td class="CelulaZebra2"><select id="tipolancamento" name="tipolancamento" class="inputtexto">
            <option value="todos" selected>Todos</option>
            <option value="conciliados">Conciliados</option>
            <option value="naoconciliados">N&atilde;o conciliados</option>
                              </select></td>
        </tr>
        <tr>
          <td class="TextoCampos">Apenas as contas: </td>
          <td class="CelulaZebra2">
              <input name="marcarTodas" id="marcarTodas" type="checkbox" checked onclick="marcarDesrmarcarTodas();">&nbsp;<b>Marcar/Desmarcar Todas</b><br>
          <% //Carregando todas as contas cadastradas
             BeanConsultaConta conta = new BeanConsultaConta();
             conta.setConexao(Apoio.getUsuario(request).getConexao());
             conta.mostraContas(0,false, limitarUsuarioVisualizarConta, idUsuario);
             ResultSet rsconta = conta.getResultado();
             int qtd = 0;
             while (rsconta.next()){%>
                <input name="conta<%=qtd%>" id="conta<%=qtd%>" type="checkbox" checked value="<%=rsconta.getString("idconta")%>">
			 <%=rsconta.getString("numero")+ " - " + rsconta.getString("banco") %><br>
                <%qtd++;
             }%>
             <input name="qtdContas" id="qtdContas" type="hidden" value="<%=qtd%>">
          </td>
        </tr>
        <tr id="trCreditos">
          <td class="TextoCampos">Considerar Créditos:</td>
          <td class="CelulaZebra2">
              <select id="tipoCredito" name="tipoCredito" class="inputtexto">
                 <option value="todos" selected>Todos</option>
                 <option value="com">Com fatura gerada</option>
                 <option value="sem">Sem fatura gerada</option>
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
        <input name="imprimir" type="button" class="botoes" id="imprimir" value="Imprimir" onClick="javascript:tryRequestToServer(function(){popRel(<%=qtd%>);});">
        <%}%>
      </div></td>
  </tr>
</table>
        </div>
      <div id="tabDinamico"></div>
</body>
</html>
