<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Collection"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
          import="java.sql.ResultSet,
                  despesa.duplicata.*,
                  mov_banco.conta.*,
                  mov_banco.*,
                  java.text.*,
                  mov_banco.talaocheque.ConsultaTalaoCheque,
                  mov_banco.talaocheque.TalaoCheque,
                  nucleo.BeanConfiguracao,
                  java.util.Date,
                  java.util.Hashtable,
                  java.util.Enumeration,
				  java.util.Vector,
				  nucleo.impressora.*,
                  nucleo.Apoio" errorPage="" %>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<!--<script language="JavaScript"  src="script/jquery.js" type="text/javascript"></script>-->


<% 
   int linha = 0;
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("bxpagar") : 0);
   int nivelUserViagem = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("bxpagarviagem") : 0);
   int nivelUserFilial = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("landespfl") : 0);
   int nivelUserConta = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadconta") : 0);
   int nivelCopiaCheque = (Apoio.getUsuario(request) != null
           ? Apoio.getUsuario(request).getAcesso("impcopiacheque") : 0);
   
   boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
   int idUsuario = Apoio.getUsuario(request).getIdusuario();

   BeanConfiguracao cfg = null;
            cfg = new BeanConfiguracao();
            cfg.setConexao(Apoio.getUsuario(request).getConexao());
            //Carregando as configurações
            cfg.CarregaConfig();

    ConsultaTalaoCheque tc = new ConsultaTalaoCheque();
    tc.setConexao(Apoio.getUsuario(request).getConexao());
    int idConta = request.getParameter("conta") != null ? Apoio.parseInt(request.getParameter("conta")): cfg.getConta_padrao_id().getIdConta();
    Collection<String> cheques = tc.consultarDocDisponivel(idConta,Apoio.getUsuario(request).getFilial().getIdfilial(),"f",Apoio.getUsuario(request));
//    Collection<String> cheques = new ArrayList<String>();
//    if (tc.consultarDoc(idConta,Apoio.getUsuario(request).getFilial().getIdfilial(),"f",Apoio.getUsuario(request))){
//        ResultSet rsCT = tc.getResultado();
//        while (rsCT.next()){
//            cheques.add(rsCT.getString("docum"));
//        }
//    }

   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser==0 && nivelUserViagem==0))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA

  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
  BeanConsultaMov_Banco conMov = null;
  BeanCadMovBanco altMov = null;
  if (!acao.equals("iniciar")){
      conMov = new BeanConsultaMov_Banco();
      conMov.setConexao( Apoio.getUsuario(request).getConexao() );
      altMov = new BeanCadMovBanco();
      altMov.setConexao( Apoio.getUsuario(request).getConexao() );
      altMov.setExecutor(Apoio.getUsuario(request));
     
  }
  //exportacao da Cartafrete para arquivo .pdf
  if (acao.equals("consultar"))
  {
    conMov.setDtIni(Apoio.paraDate(request.getParameter("dtinicial")));
    conMov.setDtFim(Apoio.paraDate(request.getParameter("dtfinal")));
    conMov.setFornecedor(Apoio.parseInt(request.getParameter("idfornecedor")));
    conMov.setFilial(Apoio.parseInt(request.getParameter("idfilial")));
    conMov.getConta().setIdConta(Apoio.parseInt(request.getParameter("conta")));
    conMov.setDoc(request.getParameter("doc"));
    conMov.setDocDe(request.getParameter("docDe"));
    conMov.setDocAte(request.getParameter("docAte"));
    conMov.setTipoConsultaCheque(Apoio.parseInt(request.getParameter("tipoConsultaCheque")));
    conMov.setTipoData(request.getParameter("tipoData"));
    conMov.setChequeImpressos(Apoio.parseBoolean(request.getParameter("mostrarNaoImpressos")));
    
  }
  else if (acao.equals("salvar")){
    //Preenchendo o array dos mov_banco
    String valor = request.getParameter("dados");
    int qtdMovs = valor.split("_").length;
    BeanMovBanco[] arrayChq = new BeanMovBanco[qtdMovs];
    for (int k = 0; k < qtdMovs; ++k){
      BeanMovBanco bc = new BeanMovBanco();
      bc.setDocum(request.getParameter("docum_"+valor.split("_")[k]));
      //Usando o campo historico como campo auxiliar para informar o número do cheque que deverá ser alterado
      bc.setHistorico(valor.split("_")[k]);
      bc.setNominal(request.getParameter("nominal_"+valor.split("_")[k]));
      bc.setDtEmissao(Apoio.paraDate(request.getParameter("dtemissao_"+valor.split("_")[k])));
      bc.getConta().setIdConta(Apoio.parseInt(request.getParameter("conta")));
      arrayChq[k]=(bc);
    }
    altMov.setArrayBMovBanco(arrayChq);

    boolean erroSalvar = !altMov.AtualizaNaImpressao();
    //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
    if(erroSalvar) {
        response.getWriter().append("<script>alert('"+altMov.getErros()+"');</script>");
    }else{
    	response.getWriter().append("<script>window.opener.document.location.replace(window.opener.document.location);window.close();</script>");
    }
    response.getWriter().close();
  }
  
  boolean carregaConPagar = (conMov != null && (!acao.equals("consultar")));
%>

<script language="javascript" type="text/javascript">

  function habilitaSalvar(opcao){
     getObj("salvar").disabled = !opcao;
     getObj("salvar").value = (opcao ? "Salvar" : "Enviando...");
  }

  function salvar(linhas)
  {          

    var doc;
    var resultado = "";
    for (i = 0; i <= linhas - 1; ++i){
      doc = $("chk_"+i).value
      //Começando a concatenação
      if ($("chk_"+i).checked){
        if (resultado != "")
          resultado += "_";

        resultado += doc;
      }
    }
    if (resultado==""){
       alert('Escolha no mínimo 1 cheque.');
    }else{
       habilitaSalvar(false);
       $('formChq').action = "./impressaocheques.jsp?acao=salvar&dados="+resultado+"&conta="+$('conta').value;
//       submitPopupForm($('formChq'));
       window.open('about:blank', 'pop', 'width=210, height=100');
       $("formChq").submit();
    }
  }

  function imprimir(linhas){          
    if ($('driverImpressora').value.trim() == ""){
       alert("Para impressão de cheques informe o driver da impressora!");
    }else{
       var doc;
       var resultado = "";
       var jaImpressos = "";
       for (i = 0; i <= linhas - 1; ++i){
         doc = $("chk_"+i).value
         //Começando a concatenação
         if ($("chk_"+i).checked){
           if ($('impresso_'+doc).value == 't' || $('impresso_'+doc).value == 'true'){
               if (confirm("O cheque "+doc+" já foi impresso, deseja imprimi-lo novamente?")){
                   if (resultado != ""){
                      resultado += ",";
                   }
                   resultado += doc;
                   $('impresso_'+doc).value = 't';
               }
           }else{
               if (resultado != ""){
                  resultado += ",";
               }
               resultado += doc;
               $('impresso_'+doc).value = 't';
           }
         }
       }

       if (resultado==""){
          alert('Escolha no mínimo 1 cheque.');
       }else{
            var url =  "./matricidecheque.ctrc?idmovs="+resultado+"&"+concatFieldValue("driverImpressora,conta,caminho_impressora");
            tryRequestToServer(function(){document.location.href = url;});
       }
     }
   }
   
  function visualizar(){

    if (! validaData(getObj("dtinicial").value) || (! validaData(getObj("dtfinal").value))){
        alert ("Informe o intervalo de datas corretamente.");
        return false;
    }else if($("tipoConsultaCheque").value == "1" && ($("docDe").value=="" || $("docAte").value=="") ){
        alert ("Informe o intervalo entre os documentos corretamente.");
        return false;
    }else{
        location.replace("./impressaocheques.jsp?acao=consultar&"+concatFieldValue("dtinicial,dtfinal,idfornecedor,fornecedor,idfilial,fi_abreviatura,conta,tipoData")+"&doc="+$("doc").value+"&docDe="+$("docDe").value+"&docAte="+$("docAte").value+"&tipoConsultaCheque="+$("tipoConsultaCheque").value
            +"&mostrarNaoImpressos="+$("mostrarNaoImpressos").checked);
    }
}

  function verDup(chq){
     window.open("./conciliacaobanco?acao=consultar&tipodata=dtemissao&dtinicial="+$('dtinicial').value+"&dtfinal="+$('dtfinal').value +
	             "&conta="+$('conta').value+"&conciliado=todos&doc="+chq+"&idmotorista=0&motor_nome=&creditos=ambos&valor1=0&valor2=0" ,"Despesa" , "top=0,resizable=yes");
  }
  
  function copiacheque(docum, dtentrada)
  {          
     launchPDF('./conciliacaobanco?acao=exportar&modelo=1&docum='+docum+'&idconta='+getObj("conta").value+
               '&dtentrada='+dtentrada,
               'copiacheque'+docum);
  }

  function aoCarregar(){          
     $('tipoData').value = '<%=(request.getParameter("tipoData") == null ? "dtemissao" : request.getParameter("tipoData"))%>';
     
  }

  function slcTipoConsultaCheque(){
      if($("tipoConsultaCheque").value=="1"){
          $("divVlTpChq1").style.display = "none";
          $("divVlTpChq2").style.display = "";
      }else{
          $("divVlTpChq1").style.display = "";
          $("divVlTpChq2").style.display = "none";
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

<title>Webtrans - Impressão de cheques</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="javascript:aoCarregar();slcTipoConsultaCheque();">
<div align="center"><img src="img/banner.gif"  alt="banner"> <br>
  <input type="hidden" name="idfornecedor" id="idfornecedor" value="<%=(request.getParameter("idfornecedor") != null?request.getParameter("idfornecedor"):"0")%>">
  <input type="hidden" name="idfilial" id="idfilial" value="<%=(nivelUserFilial>=2?(request.getParameter("idfilial") != null?request.getParameter("idfilial"):"0"):Apoio.getUsuario(request).getFilial().getIdfilial())%>">
</div>
<table width="75%" height="28" align="center" class="bordaFina">
  <tr> 
    <td height="22"><b>Impress&atilde;o de cheques </b></td>
    <% if (nivelUser >= 3){%>
    <%}%>
  </tr>
</table>

<br>

<table width="75%" border="0" class="bordaFina" align="center">
  <tr class="tabela"> 
    <td colspan="4"><div align="center">Filtros </div>
      <div align="center"></div></td>
  </tr>
  <tr> 
    <td width="23%" height="24" class="TextoCampos">
      <select name="tipoData" id="tipoData" class="inputtexto">
        <option value="dtemissao" selected>Data do cheque entre</option>
        <option value="dtpago">Pagamento entre</option>
      </select>
    :</td>
    <td width="24%" class="Celulazebra2"><strong> 
      <input name="dtinicial" type="text" id="dtinicial" class="fieldDate"  style="font-size:8pt;" value="<%=(request.getParameter("dtinicial") != null?request.getParameter("dtinicial"):Apoio.getDataAtual())%>" size="9" maxlength="10"
	  onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
      </strong>e<strong> 
      <input name="dtfinal" type="text" id="dtfinal" class="fieldDate" style="font-size:8pt;" value="<%=(request.getParameter("dtfinal") != null?request.getParameter("dtfinal"):Apoio.getDataAtual())%>" size="9" maxlength="10"
	  onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
      </strong></td>
    <td width="18%" class="TextoCampos">Apenas o fornecedor:</td>
    <td width="35%" class="TextoCampos"> <div align="left"><strong> 
        <input name="fornecedor" type="text" class="inputReadOnly" id="fornecedor" value="<%=(request.getParameter("fornecedor") != null?request.getParameter("fornecedor"):"")%>" size="30">
        <input name="localiza_forn" type="button" class="botoes" id="localiza_forn" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=21','Fornecedor')" value="...">
        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:getObj('idfornecedor').value='0';javascript:getObj('fornecedor').value='';"> 
        </strong></div></td>
  </tr>
  <tr> 
    <td class="TextoCampos">Apenas a conta :</td>
    <td class="Celulazebra2"><select name="conta" id="conta" class="inputtexto">
          <% //variaveis da paginacao
      //Carregando todas as contas cadastradas
      BeanConsultaConta conta = new BeanConsultaConta();
      conta.setConexao(Apoio.getUsuario(request).getConexao());
      conta.mostraContas((nivelUserFilial>=3?0:Apoio.getUsuario(request).getFilial().getIdfilial()),false, limitarUsuarioVisualizarConta, idUsuario);
      ResultSet rsconta = conta.getResultado();
      while (rsconta.next()){%>
          <option value="<%=rsconta.getString("idconta")%>" <%=(rsconta.getString("idconta").equals(request.getParameter("conta"))?"selected":"")%>>
             <%=rsconta.getString("numero")%>
          </option>
          <%}%>
        </select></td>
    <td class="TextoCampos">Apenas a filial:</td>
    <td class="Celulazebra2"><strong> 
      <input name="fi_abreviatura" type="text" class="inputReadOnly" id="fi_abreviatura" value="<%=(nivelUserFilial>=2?(request.getParameter("fi_abreviatura") != null?request.getParameter("fi_abreviatura"):""):Apoio.getUsuario(request).getFilial().getAbreviatura())%>" size="20">
      <%if(nivelUserFilial>=2){%>
        <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=8','Filial')" value="...">
        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:getObj('idfilial').value='0';javascript:getObj('fi_abreviatura').value='';"> 
      <%}%>  
      </strong></td>
  </tr>
  <tr>
    <td class="TextoCampos"> 
        <select class="inputTexto" style="width: 160px" id="tipoConsultaCheque" name="tipoConsultaCheque" onchange="slcTipoConsultaCheque();">
            <option value="0" <%=(request.getParameter("tipoConsultaCheque") != null && request.getParameter("tipoConsultaCheque").equals("0") ? "selected":"")%>>Apenas o doc </option>
            <option value="1" <%=(request.getParameter("tipoConsultaCheque") != null && request.getParameter("tipoConsultaCheque").equals("1")? "selected":"")%>>Doc(s) entre</option>
            <option value="2" <%=(request.getParameter("tipoConsultaCheque") != null && request.getParameter("tipoConsultaCheque").equals("2")? "selected":"")%>>Vários docs (separados por vírgula)</option>
        </select>:
    </td>
    <td class="Celulazebra2"><strong>
            <div id="divVlTpChq1"><input name="doc" type="text" id="doc" class="inputtexto" value="<%=(request.getParameter("doc") != null?request.getParameter("doc"):"")%>" size="25" /></div>
            <div id="divVlTpChq2" style="display: none">
                <input name="docDe" type="text" id="docDe" class="inputtexto" value="<%=(request.getParameter("docDe") != null?request.getParameter("docDe"):"")%>" size="9" />&nbsp;a&nbsp;
                <input name="docAte" type="text" id="docAte" class="inputtexto" value="<%=(request.getParameter("docAte") != null?request.getParameter("docAte"):"")%>" size="9" />
            </div>
    </strong></td>
    <td class="Celulazebra2" colspan="2">
        <div align="center">
            <input name="mostrarNaoImpressos" type="checkbox" id="mostrarNaoImpressos" value="true" <%= Apoio.parseBoolean(request.getParameter("mostrarNaoImpressos")) ? "checked" : ""  %> >
            Mostrar apenas os cheques não impressos
        </div>
    </td>       
    
    
  </tr>
  <tr> 
    <td colspan="4" class="TextoCampos"> <div align="center"> 
        <% if (nivelUser >= 1 || nivelUserViagem >= 1){%>
        <input name="visualizar" type="button" class="botoes" id="visualizar" value="Visualizar" onClick="javascript:tryRequestToServer(function(){visualizar();});">
        <%}%>
      </div></td>
  </tr>
</table>
<form method="post" id="formChq" style="clear:none" target="pop">
<table width="75%" border="0" class="bordaFina" align="center">
  <tr class="tabela"> 
    <td width="8%"><div align="center"><strong>Imprimir</strong></div></td>
    <td width="8%"><div align="center"><strong>Cheque</strong></div></td>
    <td width="10%"><div align="center"><strong>Para</strong></div></td>
    <td width="47%"><strong>Nominal</strong></td>
    <td width="12%"><div align="right">Valor</div></td>
    <td width="10%"><div align="right"><strong>Qtd Duplic.</strong></div></td>
    <td width="5%"><strong></strong></td>
  </tr>
  <% //variaveis da paginacao
      
      // se conseguiu consultar
      if ( (acao.equals("consultar")) && (conMov.ConsultarCheques()) )
      {
          ResultSet rs = conMov.getResultado();
	  while (rs.next())
          {
            //pega o resto da divisao e testa se é par ou impar
            %>
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" > 
              <td> <div class="linkEditar" onClick="" align="center"> 
                <input name="chk_<%=linha%>" id="chk_<%=linha%>" type="checkbox" value="<%=rs.getString("docum")%>">
              </div></td>
              <td>
                  <input name="impresso_<%=rs.getString("docum")%>" id="impresso_<%=rs.getString("docum")%>" type="hidden" value="<%=rs.getString("is_cheque_impresso")%>">
                  <%if(!cfg.isControlarTalonario()){%>
                    <input name="docum_<%=rs.getString("docum")%>" id="docum_<%=rs.getString("docum")%>" type="text" value="<%=rs.getString("docum")%>" maxlength="8" size="5" <%=(nivelUser==4 || nivelUserViagem==4?"":"readonly")%> class="inputtexto">
                  <%}else{%>
                    <select name="docum_<%=rs.getString("docum")%>" id="docum_<%=rs.getString("docum")%>" class="fieldMin">
                        <option value="<%=rs.getString("docum")%>" selected><%=rs.getString("docum")%></option>
                        <%for(String cheque : cheques){%>
                            <option value="<%=cheque%>" ><%=cheque%></option>
                        <%}%>
                    </select>
                  <%}%>
              </td>
              <td>
                <input name="dtemissao_<%=rs.getString("docum")%>" class="fieldDate" id="dtemissao_<%=rs.getString("docum")%>" value="<%=new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("dtemissao"))%>" type="text" size="9" style="font-size:8pt;" maxlength="12"
				onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
              </td>
              <td>
                  <input name="nominal_<%=rs.getString("docum")%>" id="nominal_<%=rs.getString("docum")%>" type="text" value="<%=rs.getString("nominal")%>" maxlength="50" size="50" class="inputtexto">
              </td>
              <td><div align="right"><%=rs.getString("valorchq")%></div></td>
              <td>
                 <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verDup('<%=rs.getString("docum")%>');});">
			       <div align="center"><%=rs.getString("qtddupls")%></div>
                 </div>
			  </td>
              <td>
              	<%if (nivelCopiaCheque > 0){%>
                <img src="img/pdf.jpg" alt="Imprimir cópia de cheque" style="cursor:pointer" onClick="javascript:tryRequestToServer(function(){javascript:copiacheque('<%=rs.getString("docum")%>',$('dtemissao_<%=rs.getString("docum")%>').value)});"
                width="21" height="22" border="0" align="right">
                <%}%>
              </td>
            </tr>
          <%linha++;
          }
      }%>
</table>
</form>
<table width="75%" border="0" class="bordaFina" align="center">
  <tr> 
    <td width="26%" class="TextoCampos"> <div align="center"> 
        <% if (nivelUser >= 2 || nivelUserViagem>=2){%>
        <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar modificações" onClick="javascript:tryRequestToServer(function(){salvar(<%=linha%>);});">
        <%}%>
      </div></td>
    <td width="23%" class="TextoCampos"> <div align="center"> 
        <% if (nivelUser >= 2 || nivelUserViagem>=2){%>
        <input name="imprimir" type="button" class="botoes" id="imprimir" value="Imprimir cheques" onClick="javascript:tryRequestToServer(function(){imprimir(<%=linha%>);});">
        <%}%>
      </div></td>
    <td width="6%" class="TextoCampos"><div align="right">
        Driver:
	    
    </div></td>
    <td width="15%" class="TextoCampos"><div align="left"><span class="CelulaZebra2">
        <select name="driverImpressora" id="driverImpressora" class="inputtexto">
          <option value="">&nbsp;</option>
          <%                Vector drivers = Apoio.listFiles(Apoio.getDirDrivers(request), "chq.txt");
                  for (int i = 0; i < drivers.size(); ++i) {
                      String driv = (String)drivers.get(i);
                      driv = driv.substring(0,driv.lastIndexOf("."));
%>
          <option value="<%=driv%>"><%=driv%>&nbsp;</option>
          <%}%>
        </select>
    </span></div></td>
    <td width="12%" class="TextoCampos">Impressora:</td>
    <td width="18%" class="TextoCampos"><div align="left"><span class="CelulaZebra2">
        <select name="caminho_impressora" id="caminho_impressora" class="inputtexto">
          <option value="">&nbsp;&nbsp;</option>
          <%BeanConsultaImpressora impressoras = new BeanConsultaImpressora();
        impressoras.setConexao(Apoio.getUsuario(request).getConexao());
        impressoras.setLimiteResultados(50);
        if (impressoras.Consultar()){
            ResultSet rs = impressoras.getResultado();
  	        while (rs.next()){%>
          <option value="<%=rs.getString("descricao")%>" <%=(rs.getString("descricao").equals(Apoio.getUsuario(request).getFilial().getCaminhoImpressora())?"selected":"") %>><%=rs.getString("descricao")%></option>
          <%}%>
          <%}%>
        </select>
    </span></div></td>
  </tr>
</table>
</body>
</html>
