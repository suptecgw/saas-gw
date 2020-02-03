<%@ page contentType="text/html; charset=iso-8859-1" language="java"
          import="java.sql.ResultSet,
                  conhecimento.coleta.*,
                  conhecimento.romaneio.*,
                  java.text.*,
                  java.util.Date,
                  java.util.Hashtable,
                  java.util.Enumeration,
                  nucleo.Apoio" errorPage="" %>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>


<% 
   int nivelUserColeta = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadcoleta") : 0);
   int nivelUserRomaneio = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadromaneio") : 0);

   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || ( nivelUserColeta==0) || ( nivelUserRomaneio==0))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA

  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
  BeanConsultaColeta conColeta = null;
  BeanConsultaRomaneio conRomaneio = null;
  BeanCadColeta cadColeta = null;
  BeanCadRomaneio cadRomaneio = null;
  if (!acao.equals("iniciar")){
  }
  //exportacao da Cartafrete para arquivo .pdf
  if (acao.equals("consultar"))
  {
    conColeta = new BeanConsultaColeta();
    conColeta.setConexao( Apoio.getUsuario(request).getConexao() );
    conRomaneio = new BeanConsultaRomaneio();
    conRomaneio.setConexao( Apoio.getUsuario(request).getConexao() );
	conColeta.setValorDaConsulta(request.getParameter("idmotorista"));
	conColeta.setDtEmissao1( Apoio.paraDate(request.getParameter("dtinicial")));
	conColeta.setDtEmissao2( Apoio.paraDate(request.getParameter("dtfinal")));
	conColeta.setBaixando(false);
	conRomaneio.setValorDaConsulta(request.getParameter("idmotorista"));
	conRomaneio.setDtEmissao1( Apoio.paraDate(request.getParameter("dtinicial")));
	conRomaneio.setDtEmissao2( Apoio.paraDate(request.getParameter("dtfinal")));
  }
  else if (acao.equals("salvar")){
	cadColeta = new BeanCadColeta();
    cadColeta.setConexao( Apoio.getUsuario(request).getConexao() );
    cadColeta.setExecutor(Apoio.getUsuario(request));
    cadRomaneio = new BeanCadRomaneio();
    cadRomaneio.setConexao( Apoio.getUsuario(request).getConexao() );
    cadRomaneio.setExecutor(Apoio.getUsuario(request));

    //Preenchendo o array das coletas
    String coletas = request.getParameter("coletas");
    int qtdCols = coletas.split(";").length;
    BeanColeta[] arrayCol = new BeanColeta[qtdCols];
    if( !coletas.trim().equals("") ){
        for (int k = 0; k < qtdCols; ++k){
            BeanColeta col = new BeanColeta();
            col.setId(Integer.parseInt((coletas.split(";")[k].split("_")[0]).equals("") ? "0" : coletas.split(";")[k].split("_")[0]));
            col.setValorRateioDiaria(Float.parseFloat(coletas.split(";")[k].split("_")[1].equals("") ? "0.0" : coletas.split(";")[k].split("_")[1]));
            arrayCol[k] = col;
        }
        cadColeta.setArrayColetas(arrayCol);
    }


    //Preenchendo o array dos romaneios
    String romaneios = request.getParameter("romaneios");
    int qtdRoms = (romaneios.equals("") ? 0 : romaneios.split(";").length);
    BeanRomaneio[] arrayRom = new BeanRomaneio[qtdRoms];
    for (int k = 0; k < qtdRoms; ++k){
        BeanRomaneio rom = new BeanRomaneio();
        rom.setIdRomaneio(Integer.parseInt(romaneios.split(";")[k].split("_")[0]));
        rom.setVlRateioDiaria(Float.parseFloat(romaneios.split(";")[k].split("_")[1]));
        arrayRom[k] = rom;
    }
    cadRomaneio.setArrayRoma(arrayRom);
    
    boolean erroSalvar = cadColeta.AtualizaDiaria();
    boolean erroSalvarRomaneio = cadRomaneio.AtualizaDiaria();
    //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
    if(erroSalvar) {
      response.getWriter().append("err<=>"+cadColeta.getErros());
    }else if(erroSalvarRomaneio){
        response.getWriter().append("err<=>"+cadRomaneio.getErros());
    }else{
      response.getWriter().append("err<=>");
    }
    response.getWriter().close();
  }
  
  boolean carregaColeta = (conColeta != null && (!acao.equals("consultar")));
%>


<script language="javascript" type="">
  var qtdCol =0;
  var qtdRom =0;

  function habilitaSalvar(opcao){
     getObj("salvar").disabled = !opcao;
     getObj("salvar").value = (opcao ? "Salvar" : "Enviando...");
  }

  function verColeta(id){
    window.open("./cadcoleta?acao=editar&id="+id+"&ex=false", "Coleta" , "top=0,resizable=yes");
  }

  function verRomaneio(id){
    window.open("./cadromaneio?acao=editar&id="+id+"&ex=false", "Romaneio" , "top=0,resizable=yes");
  }

  function ratear(qtdCol,qtdRom){
    var totalLinhas = qtdCol + qtdRom; 
    var valor = $('valor_diaria').value;
    var valorRateio = parseFloat(valor / totalLinhas); 
    var valorRateioUltima = parseFloat(valor - formatoMoeda((valor / totalLinhas)) * (totalLinhas - 1) ); 
    if (valor != 0){
      var co = 0;
      var ro = 0;
      for (i = 0; i <= totalLinhas - 1; ++i){
        if (co < qtdCol){
          if (i == totalLinhas - 1){
             $('valorC_'+co).value=formatoMoeda(valorRateioUltima);
          }else{
             $('valorC_'+co).value=formatoMoeda(valorRateio);
          }
          co++;
        }else{
          if (i == totalLinhas - 1){
             $('valorR_'+ro).value=formatoMoeda(valorRateioUltima);
          }else{
             $('valorR_'+ro).value=formatoMoeda(valorRateio);
          }
          ro++;
        }
      }
    }
  }

  function salvar(linhasC,linhasR)
  {

    function ev(resp, codstatus) {
      habilitaSalvar(true);
        if (codstatus==200 && resp=="err<=>"){
            location.replace("./atualiza_diaria_motorista.jsp?acao=iniciar");
        }else {
            if (resp.split("<=>").lenght > 1) {
                alert(resp.split("<=>")[1]);
            }else{
                alert("ATENÇÃO: Ocorreu um erro, favor entrar em contato com o suporte.");
            }
        }
    }
 
    var id;
    var coletas = "";
    //resgatando as coletas
    for (i = 0; i <= linhasC - 1; ++i){
      id = $("idcoleta_"+i).value
      //Começando a concatenação
      if (coletas != "")
        coletas += ";";

      coletas += id + "_" + $("valorC_"+i).value;
    }
    //resgatando os romaneios
    var romaneios = "";
    for (i = 0; i <= linhasR - 1; ++i){
      id = $("idromaneio_"+i).value
      //Começando a concatenação
      if (romaneios != "")
        romaneios += ";";

      romaneios += id + "_" + $("valorR_"+i).value;
    }
    if(romaneios == "" && coletas == ""){
        alert("Favor selecionar uma coleta ou um romaneio!");
        return false;
    }
    habilitaSalvar(false);
    requisitaAjax("./atualiza_diaria_motorista.jsp?acao=salvar&coletas="+coletas+"&romaneios="+romaneios,ev);
  }

  function aoClicarNoLocaliza(idjanela)
  {        
    if ((idjanela == "Motorista"))
    {
      location.replace("./atualiza_diaria_motorista.jsp?acao=consultar&"+concatFieldValue("idmotorista,motor_nome,dtinicial,dtfinal"));
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

<title>Webtrans - Lançar / Atualizar diária motorista</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body>
<div align="center"><img src="img/banner.gif"  alt="banner"> <br>
  <input type="hidden" name="idmotorista" id="idmotorista" value="<%=(request.getParameter("idmotorista")!= null?request.getParameter("idmotorista"):"0")%>">
</div>
<table width="50%" height="28" align="center" class="bordaFina" >
  <tr> 
    <td height="22"><b>Lan&ccedil;ar / Atualizar di&aacute;ria do motorista </b></td>
  </tr>
</table>

<br>

<table width="50%" border="0" class="bordaFina" align="center">
  <tr class="tabela"> 
    <td colspan="2"><div align="center">Filtros </div>
      <div align="center"></div></td>
  </tr>
  <tr>
    <td height="24" class="TextoCampos">Per&iacute;odo entre:</td>
    <td class="CelulaZebra2"><strong>
      <input name="dtinicial" type="text" id="dtinicial" style="font-size:8pt;" value="<%=(request.getParameter("dtinicial") != null?request.getParameter("dtinicial"):Apoio.getDataAtual())%>" size="9" maxlength="10" 
      		 onblur="alertInvalidDate(this)" onkeydown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onkeypress="fmtDate(this, event)" >
    </strong>e<strong>
    <input name="dtfinal" type="text" id="dtfinal" style="font-size:8pt;" value="<%=(request.getParameter("dtfinal") != null?request.getParameter("dtfinal"):Apoio.getDataAtual())%>" size="9" maxlength="10" 
		   onblur="alertInvalidDate(this)" onkeydown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onkeypress="fmtDate(this, event)" >
    </strong></td>
  </tr>
  <tr> 
    <td width="28%" height="24" class="TextoCampos">Escolha o motorista: </td>
    <td width="72%" class="CelulaZebra2"><strong>
      <input name="motor_nome" type="text" class="inputReadOnly" id="motor_nome" value="<%=(request.getParameter("motor_nome") != null?request.getParameter("motor_nome"):"")%>" size="45">
      <input name="localiza_forn" type="button" class="botoes" id="localiza_forn" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=10','Motorista')" value="...">
    </strong> <div align="left"></div></td>
  </tr>
  <tr>
    <td height="24" class="TextoCampos">Valor da di&aacute;ria: </td>
    <td class="CelulaZebra2"><font size="1">
      <input name="valor_diaria" type="text" id="valor_diaria" onChange="seNaoFloatReset(this,'0.00');" value="0.00" size="8" maxlength="12">
      <input name="ratear" type="button" class="botoes" id="ratear" value="Ratear di&aacute;ria" onClick="javascript:tryRequestToServer(function(){ratear(qtdCol,qtdRom);});">
    </font></td>
  </tr>
</table>
<table width="50%" border="0" class="bordaFina" align="center">
  <tr class="tabela">
    <td colspan="4"><div align="center">Coletas</div></td>
  </tr>
  <tr class="tabela"> 
    <td width="15%"><div align="left"><strong>Coleta</strong></div></td>
    <td width="15%"><strong>Data</strong></td>
    <td width="60%">Remetente</td>
    <td width="10%"><div align="right"><strong>Valor</strong></div></td>
  </tr>
  <% //variaveis da paginacao
      int linha = 0;
      // se conseguiu consultar
      if ( (acao.equals("consultar")) && (conColeta.consultaBx()) && (nivelUserColeta > 1) )
      {
          ResultSet rs = conColeta.getResultado();
	  while (rs.next())
          {
            //pega o resto da divisao e testa se é par ou impar
            %>
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" > 
              <td> <div class="linkEditar" onClick="" align="center"> 
                <input name="idcoleta_<%=linha%>" id="idcoleta_<%=linha%>" type="hidden" value="<%=rs.getString("idcoleta")%>">
              </div>
			  <div align="center" class="linkEditar" onClick="javascript:tryRequestToServer(function(){verColeta('<%=rs.getString("idcoleta")%>');});">
              <font size="1"><%=rs.getString("numcoleta")%></font>              </div></td>
              <td><font size="1"><%=new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("dtcoleta"))%></font></td>
              <td><font size="1"><%=rs.getString("razaosocial")%></font></td>
              <td><div align="right"><font size="1">
                <input name="valorC_<%=linha%>" type="text" id="valorC_<%=linha%>" onChange="seNaoFloatReset(this,'0.00');" value="0.00" size="7" maxlength="12">
              </font></div></td>
            </tr>
          <%linha++;
          }
      }%>
      <script language="javascript">
         qtdCol=<%=linha%>;
      </script>  
</table>
<table width="50%" border="0" class="bordaFina" align="center">
  <tr class="tabela">
    <td colspan="4"><div align="center">Romaneios</div></td>
  </tr>
  <tr class="tabela"> 
    <td width="15%"><div align="left"><strong>Romaneio</strong></div></td>
    <td width="15%"><strong>Data</strong></td>
    <td width="60%">CTRCs</td>
    <td width="10%"><div align="right"><strong>Valor </strong></div></td>
  </tr>
  <% //variaveis da paginacao
      int linhaR = 0;
      // se conseguiu consultar
      if ( (acao.equals("consultar")) && (conRomaneio.consultaAtualizaDiarias()) && (nivelUserRomaneio > 1) )
      {
          ResultSet rs = conRomaneio.getResultado();
	  while (rs.next())
          {
            //pega o resto da divisao e testa se é par ou impar
            %>
            <tr class="<%=((linhaR % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" > 
              <td> <div class="linkEditar" onClick="" align="center"> 
                <input name="idromaneio_<%=linhaR%>" id="idromaneio_<%=linhaR%>" type="hidden" value="<%=rs.getString("idromaneio")%>">
              </div>
			  <div align="center" class="linkEditar" onClick="javascript:tryRequestToServer(function(){verRomaneio('<%=rs.getString("idromaneio")%>');});">
              <font size="1"><%=rs.getString("numromaneio")%></font>              </div></td>
              <td><font size="1"><%=new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("dtentrega"))%></font></td>
              <td><font size="1"><%=rs.getString("ctrcs")%></font></td>
              <td><div align="right"><font size="1">
                <input name="valorR_<%=linhaR%>" type="text" id="valorR_<%=linhaR%>" onChange="seNaoFloatReset(this,'0.00');" value="0.00" size="7" maxlength="12">
              </font></div></td>
            </tr>
          <%linhaR++;
          }
      }%>
      <script language="javascript">
         qtdRom=<%=linhaR%>;
      </script>  
</table>
<table width="50%" border="0" class="bordaFina" align="center">
  <tr> 
    <td width="100%" class="TextoCampos"> <div align="center"> 
        <% if (nivelUserColeta >= 2 || nivelUserRomaneio >= 2){%>
        <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salvar(<%=linha%>,<%=linhaR%>);});">
        <%}%>
      </div></td>
  </tr>
</table>
</body>
</html>
