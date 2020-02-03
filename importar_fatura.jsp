 <%@ page contentType="text/html; charset=iso-8859-1" language="java"
	import="java.sql.ResultSet,
           conhecimento.duplicata.fatura.*,
           java.text.*,
           com.sagat.bean.*,
           java.util.*,
           filial.*,
           nucleo.*"
%>
<% 
   int nivelUser = (Apoio.getUsuario(request) != null ?
                     Apoio.getUsuario(request).getAcesso("lanfatura") : 0);

   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || ( nivelUser<=2))
       response.sendError(HttpServletResponse.SC_FORBIDDEN);


  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  
  if (acao.equals("importar")){
    
    int qtdFaturas = Integer.parseInt(request.getParameter("qtdFaturas"));
    int qtdCtrc = Integer.parseInt(request.getParameter("qtdCtrc"));
    BeanCadFatura cadFat = new BeanCadFatura();
    cadFat.setConexao(Apoio.getUsuario(request).getConexao());
    cadFat.setExecutor(Apoio.getUsuario(request));
    BeanFatura fat;
    BeanFatura arFats[] = new BeanFatura[qtdFaturas+1];
    for (int x = 0; x <= qtdFaturas; x++){
        if (request.getParameter("idCliente_"+x) != null){
            fat = new BeanFatura();
            //Dados da coleta
            fat.setId(0);
            fat.setNumero("");
            fat.setAnoFatura(new SimpleDateFormat("yyyy").format(new Date()));
            fat.setEmissaoEm(new Date());
            Date vencimento =  Apoio.paraDate(request.getParameter("vencimentoFatura_"+x));
            fat.setVenceEm(vencimento == null ? new Date() : vencimento);
            fat.getCliente().setIdcliente(Integer.parseInt(request.getParameter("idCliente_"+x)));
            fat.setObservacao("Referente a pré-fatura " + request.getParameter("preFatura_"+x));
            fat.setNumeroPreFatura(request.getParameter("preFatura_"+x));
            fat.getFilialCobranca().setIdfilial(Integer.parseInt(request.getParameter("filialId")));
            
            fat.setContaDepositoPrefat(request.getParameter("contaDepositoPreFatura_"+x));
            fat.setNomeClientePrefat(request.getParameter("nomeClientePreFatura_"+x));
            fat.setCodigoTransportadoraPrefat(request.getParameter("codTranpPreFatura_"+x));
            fat.setDataInicioFechamentoPrefat(request.getParameter("dataInicioFechamentoPreFatura_"+x));
            fat.setDataFimFechamentoPrefat(request.getParameter("dataFimFechamentoPreFatura_"+x));
            fat.setValorBloqueioPrefat(request.getParameter("valorBloqueioPreFatura_"+x));

            fat.setGeraBoleto(false);
            fat.getConta().getBanco().setNumero("000");
            fat.setCodProtesto(3);

            String idsCtrc = "";
            String idsNotas = "";
            String numerosProtocolos = "";
            String numerosroteiros = "";
            for (int y = 0; y <= qtdCtrc; y++){
                if (request.getParameter("duplicataId_"+x+"_"+y) != null){
                    if (Boolean.parseBoolean(request.getParameter("importar_"+x+"_"+y))){
                        idsCtrc += (idsCtrc.equals("")?"":",") + request.getParameter("duplicataId_"+x+"_"+y);
                        idsNotas += (idsNotas.equals("")?"":",") + request.getParameter("notaFiscalIdPreFatura_"+x+"_"+y);
                        numerosProtocolos += (numerosProtocolos.equals("")?"":",") + request.getParameter("numeroProtocoloPreFatura_"+x+"_"+y);
                        numerosroteiros += (numerosroteiros.equals("")?"":",") + request.getParameter("numeroRoteiroPreFatura_"+x+"_"+y);
                        
                    }
                }
            }
            fat.setCtrcs(idsCtrc);
            fat.setNotaFiscalIdPreFatura(idsNotas);
            fat.setNumeroProtocoloPreFatura(numerosProtocolos);
            fat.setNumeroRoteiroPreFatura(numerosroteiros);
            arFats[x] = (idsCtrc.equals("")?null:fat);
        }
        cadFat.setArrayFatura(arFats);
    }

    boolean naoTemFatura = true;

    for (BeanFatura arFat : arFats) {
        if (arFat != null) {
            naoTemFatura = false;
            break;
        }
    }

    if (naoTemFatura) {
        response.getWriter().append("<script>alert('Não existem faturas para salvar!');window.close();</script>");
    } else {
        boolean salvou = false;
        salvou = cadFat.IncluiLoteFatura();
        if (!salvou) {
            response.getWriter().append("<script>alert('" + cadFat.getErros() + "');window.close();</script>");
        } else {
            String scr = "";
            scr = "<script>";
            scr += "window.opener.document.location.replace('./consultafatura?acao=iniciar');" +
                    "window.close();" +
                    "</script>";
            response.getWriter().append(scr);
        }
    }
    response.getWriter().close();
  }

%>

<script language="JavaScript" type="text/javascript">

  function voltar(){
      document.location.replace('./consultafatura?acao=iniciar');
  }

  function getFile(){
      if ($('file').value == ''){
          alert('Informe o arquivo corretamente!');         
      }else{
          document.getElementById('formFatura').action="ServletUploadFatura?layout="+$('layout').value;
          document.getElementById("formFatura").submit();
      }
  }
  
  function importar(){
      var tudoOK = true;
      if($('qtdFaturas') != null && parseFloat($('qtdFaturas').value) > 0){
        for (x = 0; x <= $('qtdFaturas').value; x++){
            for (y = 0; y <= $('qtdCtrc').value; y++){
                if ($('importar_'+x+'_'+y)!=null && $('importar_'+x+'_'+y).value=='false'){
                     tudoOK = false;
                }
            }
        }
        if (!tudoOK && !confirm("Existe algum CT com divergência, Deseja mesmo continuar?")){
            return false;
        }
        if ($('file')== null || $('file').value == '' && parseFloat($('qtdFaturas').value) <= 0){
            alert('Informe o arquivo corretamente!');
              return false;
        }
        submitPopupForm($('formImportar'));
      }else{
          alert("Não há faturas para importar!");
      }
  }  
      
</script>

<html>
<head>
<script language="JavaScript" src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript" src="script/notaFiscal-util.js" type="text/javascript"></script>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="pt" />
<meta http-equiv="cache-control" content="no-cache" />
<meta http-equiv="pragma" content="no-store" />
<meta http-equiv="expires" content="0" />
<meta name="language" content="pt-br" />

<title>Webtrans - Importar faturas</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="">
<div align="center"><img src="img/banner.gif" alt="banner"><br>
</div>
<table width="80%" height="28" align="center" class="bordaFina">
	<tr>
		<td width="86%" height="22"><b>Importa&ccedil;&atilde;o de  faturas (EDI) </b></td>
		<td width="14%"><b> <input name="Button" type="button"
                                           class="botoes" value="Consulta" onClick="javascript: tryRequestToServer(function (){voltar();})"> </b></td>
	</tr>
</table>

<br>
<table width="80%" border="0" class="bordaFina" align="center">
<form id="formFatura" name="formFatura" method="post" action="ServletUploadFatura" enctype="multipart/form-data">
	<tr class="tabela">
		<td height="18" colspan="4">
		<div align="center">Filtros</div>
		<div align="center"></div>		</td>
	</tr>
	<tr>
		<td width="111" class="TextoCampos">Informe o layout:</td>
	  <td width="121" colspan="-1" class="TextoCampos">
		<div align="left"><strong>
                        <select name="layout" id="layout" class="inputTexto">
		    <option value="proceda-1.0" selected>Proceda 1.0</option>
		    <option value="proceda-1.0">Proceda 1.2</option>
		    <option value="proceda-1.0">Proceda 5.0</option>
                    <option value="danzas">DANZAS</option>
                    <option value="tivit50">TIVIT 5.0</option>
                    <option value="cnova">CNova Comércio Eletrônicos S/A (Excel)</option>
                    <option value="dhl">DHL</option>
        </select> 
        </strong></div>		</td>
      <td class="TextoCampos">Selecione o arquivo: </td>
	  <td width="229" class="CelulaZebra2">
              <input name="file" type="file" id="file" class="inputtexto" style="font-size:8pt;" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" size="40" ><div align="center">
          </div></td>
    </tr>
    </form>    
	<tr>
	  <td colspan="4" class="TextoCampos"><div align="center">
	    <input name="visualizar" type="button"
			class="botoes" id="visualizar" value="Visualizar"
			onclick="javascript:tryRequestToServer(function(){getFile();});">
      </div></td>
    </tr>
</table>
<form method="post" id="formImportar" name="formImportar" action="./importar_fatura.jsp?acao=importar">
<table width="80%" border="0" class="bordaFina" align="center">
    <tbody id="tbColeta" name="tbColeta">
    <INPUT TYPE="hidden" ID="qtdFaturas" NAME="qtdFaturas" VALUE="<%=request.getSession().getAttribute("qtdFaturas")%>">
    <INPUT TYPE="hidden" ID="qtdCtrc" NAME="qtdCtrc" VALUE="<%=request.getSession().getAttribute("qtdCtrc")%>">
    <tr>
        <td width="35%" class="TextoCampos">Informe a filial respons&aacute;vel pela cobran&ccedil;a:</td>
  <td width="65%" class="CelulaZebra2">
      <select name="filialId" id="filialId" style="font-size:8pt;" class="inputtexto">
                <%BeanFilial fl = new BeanFilial();
    	      	ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());
        	while (rsFl.next()){%>
                        <option value="<%=rsFl.getString("idfilial")%>"  
            		<%=(Apoio.getUsuario(request).getFilial().getIdfilial()==rsFl.getInt("idfilial")?"selected":"")%>><%=rsFl.getString("abreviatura")%></option>
                <%}%>        
            </select>
        </td>
    </tr>    
    <tr id="trFatura" name="trFatura">
	  <td id="tdFatura" name="tdFatura" colspan="2"></td>
    </tr>
    <%if (acao.equals("carregar")){%>
         <script>
             $("trFatura").childNodes[(isIE()? 0 : 1)].innerHTML = "<%=request.getSession().getAttribute("importEdi") == null ? "" : request.getSession().getAttribute("importEdi") %>";
         </script>
    <%}
    request.getSession().removeAttribute("importEdi");
    request.getSession().removeAttribute("qtdFaturas");
    request.getSession().removeAttribute("qtdCtrc");
    %>
</table>
</form>
<table width="80%" border="0" class="bordaFina" align="center">
	<tr>
		<td width="100%" class="TextoCampos">
		<div align="center">
		<% if (nivelUser >= 2){%> 
		<input name="baixar" type="button"
			class="botoes" id="baixar" value="Importar"
			onclick="javascript:tryRequestToServer(function(){importar();});">
		<%}%>
		</div>
		</td>
	</tr>
</table>
<br>

</body>
</html>