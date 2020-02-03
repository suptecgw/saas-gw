<%@page import="java.util.Date"%>
<%@page import="nucleo.BeanConfiguracao"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="conhecimento.awb.BeanCadAWB"%>
<%@page import="conhecimento.awb.BeanConsultaAWB"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
  import="java.sql.ResultSet,
          usuario.BeanUsuario,
          nucleo.Apoio" %>

<% //ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadawb") : 0);
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA
   SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
   BeanConfiguracao cfg = new BeanConfiguracao();
   cfg.setConexao(Apoio.getUsuario(request).getConexao());
   cfg.CarregaConfig();

   
String campoConsulta = "";
String valorConsulta = "";
String operadorConsulta = "";
String limiteResultados = "";
String dataInicial = "";
String dataFinal = "";
Cookie consulta = null;
Cookie operador = null;
Cookie limite = null;

Cookie cookies[] = request.getCookies();
if (cookies != null){
	for(int i = 0; i < cookies.length; i++){
		if(cookies[i].getName().equals("consultaAWB")){
			consulta = cookies[i];
		}else if(cookies[i].getName().equals("operadorConsulta")){
			operador = cookies[i]; 
		}else if(cookies[i].getName().equals("limiteConsulta")){
			limite = cookies[i]; 
		}
		if (consulta != null && operador != null && limite != null){ //se já encontrou os cookies então saia
			break;
		}
	}
	if (consulta == null){//se não achou o cookieu então inclua
		consulta = new Cookie("consultaAWB","");
	}
	if (operador == null){//se não achou o cookieu então inclua
		operador = new Cookie("operadorConsulta","");
	}
	if (limite == null){//se não achou o cookieu então inclua
		limite = new Cookie("limiteConsulta","");
	}
    consulta.setMaxAge(60 * 60 * 24 * 90);
    operador.setMaxAge(60 * 60 * 24 * 90);
    limite.setMaxAge(60 * 60 * 24 * 90);

    String valor = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[0]);
    String campo = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[1]);
    String dt1 = (consulta.getValue().equals("") ? fmt.format(new Date()) : consulta.getValue().split("!!")[2]);
    String dt2 = (consulta.getValue().equals("") ? fmt.format(new Date()) : consulta.getValue().split("!!")[3]);
   	valorConsulta = (request.getParameter("valor") != null ? request.getParameter("valor") : (valor));
   	campoConsulta = (request.getParameter("campo") != null && !request.getParameter("campo").trim().equals("")? request.getParameter("campo") : (campo.equals("")?"numero":campo));
        dataInicial = (request.getParameter("emissaoEm1") != null ? request.getParameter("emissaoEm1") : (dt1));
   	dataFinal = (request.getParameter("emissaoEm2") != null ? request.getParameter("emissaoEm2") : (dt2));
   	operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("") 
				? request.getParameter("ope") 
				: (operador.getValue().equals("")?"1":operador.getValue()));
   	limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("") 
			? request.getParameter("limite")
			: (limite.getValue().equals("")?"10":limite.getValue()));
	consulta.setValue(valorConsulta+"!!"+campoConsulta+"!!"+dataInicial+"!!"+dataFinal);
	operador.setValue(operadorConsulta);
	limite.setValue(limiteResultados);
    response.addCookie(consulta);
    response.addCookie(operador);
    response.addCookie(limite);
}else{
        dataInicial = (request.getParameter("emissaoEm1") != null ? request.getParameter("emissaoEm1"): Apoio.incData(fmt.format(new Date()),-30));
	dataFinal = (request.getParameter("emissaoEm2") != null ? request.getParameter("emissaoEm2") : fmt.format(new Date()));
	campoConsulta = (request.getParameter("campo") != null && !request.getParameter("campo").trim().equals("") ? 
            request.getParameter("campo") : "numero");
	valorConsulta = (request.getParameter("valor") != null && !request.getParameter("valor").trim().equals("") ? 
            request.getParameter("valor") : "");
	operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("") ? 
            request.getParameter("ope") : "1");
	limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("") ?
            request.getParameter("limite") : "10");
}
   
%>

<%  // DECLARANDO e inicializando as variaveis usadas no JSP
    BeanConsultaAWB awb = null;
    String acao     = request.getParameter("acao");
    acao = ((acao == null) || (nivelUser == 0) ? "" : acao);
    //variavel responsavel pela paginacao. Pega o ultimo titulo
    String ultimotitulo = request.getParameter("ultimo");
    String pag      = (request.getParameter("pag") != null ? request.getParameter("pag") : "0");

    if (acao.equals("iniciar"))
    {
      acao = "consultar";
      pag = "1";
    }

    if ((acao.equals("consultar")) || (acao.equals("proxima")) )
    {   //instanciando o bean
        awb = new BeanConsultaAWB();
        awb.setConexao( Apoio.getUsuario(request).getConexao() );
        awb.setCampoDeConsulta(campoConsulta);
        awb.setOperador(Integer.parseInt(operadorConsulta));
        awb.setValorDaConsulta(valorConsulta);
        awb.setLimiteResultados(Integer.parseInt(limiteResultados));
        awb.setDtInicial(Apoio.paraDate(dataInicial));
        awb.setDtFinal(Apoio.paraDate(dataFinal));
        if (acao.equals("proxima"))
        	awb.setPaginacao(ultimotitulo);
        // a chamada do método Consultar() está lá em mbaixo
    }
  
    if (acao.equals("exportar")){
        
        
        //Exportando  
        java.util.Map param = new java.util.HashMap(1);
        request.setAttribute("map", param);
            
        request.setAttribute("rel","awbmod1");
        
                
        param.put("CONDICAO", " a.id="+request.getParameter("id"));
        //param.put("USUARIO", Apoio.getUsuario(request).getNome());
        RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports");
        dispacher.forward(request, response);
        
    }
    
    if ((nivelUser == 4) && (acao.equals("excluir") && request.getParameter("id") != null))
    {
	    BeanCadAWB cadAWB = new BeanCadAWB();
	    cadAWB.setConexao(Apoio.getUsuario(request).getConexao());
	      cadAWB.setExecutor(Apoio.getUsuario(request));
	        cadAWB.getAwb().setId(Integer.parseInt(request.getParameter("id")));
            %><script language="javascript"><%
               if (! cadAWB.Deleta())
               {
                   %>alert("Erro ao tentar excluir!");<%
               }%>
               location.replace("./consulta_awb.jsp?acao=iniciar");
             </script>
    <%}

%>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript">
  
    function popAwb(id){
     
     if (id == null)
	return null;
     
        launchPDF('./consulta_awb.jsp?acao=exportar&id='+id);
     
    }
    
    function seleciona_campos(){
   <% //se for consultar agora, ele seleciona o campo q o usuario escolheu
      if ((campoConsulta != null) && (operadorConsulta != null) && (valorConsulta != null) && (limiteResultados != null) )
      {%>
           document.getElementById("valor_consulta").value = "<%=valorConsulta %>";
           document.getElementById("campo_consulta").value = "<%=campoConsulta%>";
           document.getElementById("operador_consulta").value = "<%=operadorConsulta %>";
           document.getElementById("limite").value = "<%=limiteResultados %>";
    <%}%>
    habilitaConsultaDePeriodo($("campo_consulta").value=="emissao_em");
  }

  function consulta(campo, operador, valor, limite){
     var data1 = $("emissaoEm1").value;
     var data2 = $("emissaoEm2").value;
     if (campo == "dtsaida" && !(validaData(data1) && validaData(data2) ))
	 {
	    alert("Datas inválidas para consulta. O formato correto é: \"dd/mm/aaaa\"");
	    return null;
	 }
     location.replace("./consulta_awb.jsp?campo="+campo+"&ope="+operador+"&valor="+valor+
         (data1 == "" ? "" : "&emissaoEm1="+data1+"&emissaoEm2="+data2)+
                      "&limite="+limite+"&pag=1&acao=consultar");
  }

  function habilitaConsultaDePeriodo(opcao)
  {
      $("valor_consulta").style.display = (opcao ? "none" : "");
      $("operador_consulta").style.display = (opcao ? "none" : "");
      $("div1").style.display = (opcao ? "" : "none");
      $("div2").style.display = (opcao ? "" : "none");
  }
  
  function editarAWB(id, podeexcluir){
     location.replace("./cadawb.jsp?acao=editar&id="+id+(podeexcluir != null ? "&ex="+podeexcluir : ""));
  }

  function cadAWB(){
      location.replace("./cadawb.jsp?acao=iniciar");
  }

  function proxima(ultimo_titulo){
     <%                                               //Somando a pag atual + 1 para a proxima pagina %>
     location.replace("./consulta_AWB.jsp?pag="+<%=(Integer.parseInt(pag) + 1)%>+
                      "&valor=<%=valorConsulta%>&limite=<%=limiteResultados%>&campo=<%=campoConsulta%>"+
                      "&ope=<%=operadorConsulta%>&ultimo="+ultimo_titulo+"&acao=proxima");
  }

  function setDefault(){
      $("valor_consulta").focus();
  }

  function excluirAWB(id){
       if (confirm("Deseja mesmo excluir este AWB?"))
	   {
	       location.replace("./consulta_awb.jsp?acao=excluir&id="+id);
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

<title>WebTrans - Consulta de AWBs</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style3 {font-size: 9px}
.style4 {	font-family: Arial, Helvetica, sans-serif;
	font-size: 13px;
}
-->
</style>
</head>

<body onLoad="javascript: setDefault(); seleciona_campos();">
<img src="img/banner.gif"  alt=""><br>
<table width="85%" align="center" class="bordaFina" >
  <tr >
    <td width="461"><div align="left"><b>Consulta de AWBs</b></div></td>
    <% if (nivelUser >= 3)
	{%>
	<td width="102">
	  <input name="novoAWB" type="button" class="botoes" id="novoAWB" onClick="javascript:tryRequestToServer(function(){cadAWB();});" value="Novo cadastro">
    </td>
  <%}%>
  </tr>
</table>
<br>
  <table width="85%" align="center" cellspacing="1" class="bordaFina">

    <tr class="celula">
      
    <td width="83"  height="20"><select name="campo_consulta" id="campo_consulta" class="inputtexto" onChange="javascript:habilitaConsultaDePeriodo(this.value=='emissao_em');">
        <option value="numero" >Movimento</option>
        <option value="numero_awb" selected>Número AWB</option>
        <option value="emissao_em" >Data de Emissão</option>
        <option value="ca.razaosocial" >Companhia Aérea</option>
        <option value="ori.cidade" >Cidade Origem</option>
        <option value="des.cidade" >Cidade Destino</option>
      </select> </td>
      <td width="141">
        <select name="operador_consulta" id="operador_consulta" class="inputtexto">
            <option value="1" selected>Todas as partes com</option>
            <option value="2">Apenas com in&iacute;cio</option>
            <option value="3">Apenas com o fim</option>
            <option value="4">Igual &agrave; palavra/frase</option>
            <option value="5" >Maior que</option>
            <option value="6">Maior ou igual &aacute;</option>
            <option value="7">Menor que</option>
            <option value="8">Menor ou igual &agrave;</option>
            <option value="9">Igual ao n&uacute;mero</option>
        </select>
    	    <!-- Campo somente para consulta de intervalo de datas -->
	    <div id="div1" style="display:none ">De:<input name="emissaoEm1" type="text" id="emissaoEm1" size="10" maxlength="10" value="<%=dataInicial%>"
			 class="fieldDate" onBlur="alertInvalidDate(this)"></div>
      </td>
      <td colspan="2" align="left">
          <!-- Campo somente para consulta de intervalo de datas -->
            <div id="div2" style="display:none ">Para:<input name="emissaoEm2" type="text" id="emissaoEm2" size="10" maxlength="10" value="<%=dataFinal%>"
				 class="fieldDate" onBlur="alertInvalidDate(this)" ></div>
          <input name="valor_consulta" type="text" id="valor_consulta" size="20" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar2').click();" class="inputtexto"></td>
      
    <td width="79"> <input name="pesquisar" type="button" class="botoes" id="pesquisar2" value="Pesquisar" alt="Faz a pesquisa com os dados informados"
            onClick="javascript:tryRequestToServer(function(){consulta(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value);});"></td>
      <td width="213"><div align="right">
        Por p&aacute;g.:
<select name="limite" id="limite" class="inputtexto">
              <option value="10" selected>10 resultados</option>
              <option value="20">20 resultados</option>
              <option value="30">30 resultados</option>
              <option value="40">40 resultados</option>
              <option value="50">50 resultados</option>
        </select>
      </div></td>
    </tr>
</table>
  <table width="85%" align="center" cellspacing="1" class="bordaFina">
    <tr>
        <td width="2%" class="tabela"></td>
        <td width="9%" class="tabela" align="center">Movimento</td>
      <td width="10%" class="tabela" align="center">Número</td>
      <td width="10%" class="tabela" align="center">Data Emissão</td>
      <td width="22%" class="tabela">Origem</td>
      <td width="22%" class="tabela">Destino</td>
      <td width="20%" class="tabela">Companhia Aérea</td>
      <td width="2%" class="tabela"></td>
    </tr>
   <% //variaveis da paginacao
      int linha = 0;
      int linhatotal = 0;
      int qtde_pag = 0;

      String ultima_linha = "";
      // se conseguiu consultar
      if ( (acao.equals("consultar") || acao.equals("proxima")) && (awb.Consultar()) )
      {
          ResultSet rs = awb.getResultado();
	  while (rs.next())
          {
                            //pega o resto da divisao e testa se é par ou impar
             %> <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" >
                 <td>
                     <div align="center"><img src="img/pdf.jpg" width="19" height="19" border="0" align="right" class="imagemLink" title="Formato PDF(usado para a impressão)"
					        onClick="javascript:tryRequestToServer(function(){popAwb(<%=rs.getString("id")%>);});">
                    </div>
                 </td> 
                 <td>
                      <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){editarAWB(<%=rs.getString("id")+","+rs.getBoolean("podeexcluir")%>);});">
			  <%=rs.getString("numero")%>
 		       </div>
                  </td>
                  <td align="center"><%=rs.getString("numero_awb")%></td>
                  <td align="center"><%=fmt.format(rs.getDate("emissao_em"))%></td>
                  <td><%=rs.getString("cidade_origem")%></td>
                  <td><%=rs.getString("cidade_destino")%></td>
                  <td><%=rs.getString("companhia_aerea")%></td>
                     <% if ((nivelUser == 4) && (rs.getBoolean("podeexcluir")))
                        {
                           %><td width="21"><img src="img/lixo.png" alt="Excluir este registro" style="cursor:pointer "
                                  onclick="javascript:tryRequestToServer(function(){excluirAWB(<%=rs.getString("id")%>);});">
                           </td>
                    <%}else{%><td width="6"></td>
                    <%}%>
                </tr>
              <% //se for a ultima linha................
                 if (rs.isLast()) {
                     ultima_linha = rs.getString("numero");
                     //Quantidade geral de resultados da consulta
                     linhatotal = rs.getInt("qtde_linhas");
                 }
                 linha++;
          }//while
          //se os resultados forem divididos pelas paginas e sobrar, some mais uma pag
          qtde_pag = ((linhatotal % Integer.parseInt(limiteResultados)) == 0
                       ? (linhatotal / Integer.parseInt(limiteResultados))
                       : (linhatotal / Integer.parseInt(limiteResultados)) + 1);
      }//if
      pag = ( qtde_pag == 0 ? "0" : pag );
	  %>
</table>
<br>
  <table width="85%" align="center" cellspacing="1" class="bordaFina">
   <tr class="celula">
      <td width="46%" height="22">
	  <center>
	     Ocorrências: <b><%=linha%> / <%=linhatotal%></b>
	  </center>
     </td>
      <td width="46%" align="center">Páginas: <b><%=pag %> / <%=qtde_pag %></b></td>
      <%
        //se tiver mais pags entao mostre o botao 'proxima'
        if (Integer.parseInt(pag) < qtde_pag)
        {%>
            <td width="8%"><div align="right">
			<input name="avancar" type="button" class="botoes" id="avancar"
              value="Próxima"  onClick="javascript:tryRequestToServer(function(){proxima('<%=ultima_linha%>');});">
			</div></td>
       <%}%>

    </tr>
</table>
<br>
<br>
<br>
<br>
</body>
</html>
