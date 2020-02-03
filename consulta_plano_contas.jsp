<%@ page contentType="text/html; charset=iso-8859-1" language="java"
  import="java.sql.ResultSet,
          planocusto.planocontas.*,
          cliente.*,
          usuario.BeanUsuario,
          nucleo.Apoio" %>

<% //ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadplanocontas") : 0);
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA
   
String campoConsulta = "";
String valorConsulta = "";
String operadorConsulta = "";
String limiteResultados = "";
Cookie consulta = null;
Cookie operador = null;
Cookie limite = null;

Cookie cookies[] = request.getCookies();
if (cookies != null){
	for(int i = 0; i < cookies.length; i++){
		if(cookies[i].getName().equals("consultaPlanoContas")){
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
		consulta = new Cookie("consultaPlanoContas","");
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
   	valorConsulta = (request.getParameter("valor") != null ? request.getParameter("valor") : (valor));
   	campoConsulta = (request.getParameter("campo") != null && !request.getParameter("campo").trim().equals("")
				? request.getParameter("campo") 
				: (campo.equals("")?"descricao":campo));
   	operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("") 
				? request.getParameter("operador") 
				: (operador.getValue().equals("")?"1":operador.getValue()));
   	limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("") 
			? request.getParameter("limite")
			: (limite.getValue().equals("")?"10":limite.getValue()));
	consulta.setValue(valorConsulta+"!!"+campoConsulta);
	operador.setValue(operadorConsulta);
	limite.setValue(limiteResultados);
    response.addCookie(consulta);
    response.addCookie(operador);
    response.addCookie(limite);
}else{
	campoConsulta = (request.getParameter("campo") != null && !request.getParameter("campo").trim().equals("") ? 
            request.getParameter("campo") : "descricao");
	valorConsulta = (request.getParameter("valor") != null && !request.getParameter("valor").trim().equals("") ? 
            request.getParameter("valor") : "");
	operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("") ? 
            request.getParameter("operador") : "1");
	limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("") ? 
            request.getParameter("limite") : "10");
}
   
%>

<%  // DECLARANDO e inicializando as variaveis usadas no JSP
    ConsultaPlanoContas pc = null;
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
        pc = new ConsultaPlanoContas();
        pc.setConexao( Apoio.getUsuario(request).getConexao() );
        pc.setCampoDeConsulta(campoConsulta);
        pc.setOperador(Integer.parseInt(operadorConsulta));
        pc.setValorDaConsulta(valorConsulta);
        pc.setLimiteResultados(Integer.parseInt(limiteResultados));
        if (acao.equals("proxima"))
        	pc.setPaginacao(ultimotitulo);
        // a chamada do método Consultar() está lá em mbaixo
    }

    if ((nivelUser == 4) && (acao.equals("excluir") && request.getParameter("id") != null))
    {
	    CadPlanoContas cadpc = new CadPlanoContas();
	    cadpc.setConexao(Apoio.getUsuario(request).getConexao());
	      cadpc.setExecutor(Apoio.getUsuario(request));
	        cadpc.getPc().setId(Integer.parseInt(request.getParameter("id")));
            %><script language="javascript"><%
               if (! cadpc.Deleta())
               {
                   %>alert("Erro ao tentar excluir!");<%
               }%>
               location.replace("./consulta_plano_contas.jsp?acao=iniciar");
             </script>
    <%}

%>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" type="" >
  function seleciona_campos(){
   <% //se for consultar agora, ele seleciona o campo q o usuario escolheu
      if ((campoConsulta != null) && (operadorConsulta!= null) && (valorConsulta != null) && (limiteResultados != null) )
      {%>
           $("valor_consulta").focus();
           document.getElementById("valor_consulta").value = "<%=valorConsulta %>";
           document.getElementById("campo_consulta").value = "<%=campoConsulta%>";
           document.getElementById("operador_consulta").value = "<%=operadorConsulta %>";
           document.getElementById("limite").value = "<%=limiteResultados %>";
    <%}%>
  }

  function consulta(campo, operador, valor, limite){
     location.replace("./consulta_plano_contas.jsp?campo="+campo+"&ope="+operador+"&valor="+valor+
                      "&limite="+limite+"&pag=1&acao=consultar");
  }

  function editar(id, podeexcluir){
     location.replace("./cadplano_contas.jsp?acao=editar&id="+id+(podeexcluir != null ? "&ex="+podeexcluir : ""));
  }

  function cadPlano(){
      location.replace("./cadplano_contas.jsp?acao=iniciar");
  }

  function proxima(ultimo_titulo){
     <%                                               //Somando a pag atual + 1 para a proxima pagina %>
     location.replace("./consulta_plano_contas.jsp?pag="+<%=(Integer.parseInt(pag) + 1)%>+
                      "&valor=<%=valorConsulta%>&limite=<%=limiteResultados%>&campo=<%=campoConsulta%>"+
                      "&ope=<%=operadorConsulta%>&ultimo="+ultimo_titulo+"&acao=proxima");
  }

  function excluir(id){
       if (confirm("Deseja mesmo excluir esta conta do plano de contas?"))
	   {
	       location.replace("./consulta_plano_contas.jsp?acao=excluir&id="+id);
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

<title>WebTrans - Consulta de plano de contas</title>
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

<body onLoad="javascript:seleciona_campos();">
<img src="img/banner.gif"  alt=""><br>
<table width="75%" align="center" class="bordaFina" >
  <tr >
    <td width="461"><div align="left"><b>Consulta de plano de contas </b></div></td>
    <% if (nivelUser >= 3)
	{%>
	<td width="102">
	  <input name="novo" type="button" class="botoes" id="novo" onClick="javascript:tryRequestToServer(function(){cadPlano();});" value="Novo cadastro">
    </td>
  <%}%>
  </tr>
</table>
<br>
  <table width="75%" align="center" cellspacing="1" class="bordaFina">

    <tr class="celula">
      
    <td height="20" width="85"><select name="campo_consulta" id="campo_consulta" class="inputtexto">
        <option value="codigo">Código</option>
        <option value="conta">Conta</option>
        <option value="descricao" selected >Descrição</option>
      </select> </td>
      <td width="141"><select name="operador_consulta" id="operador_consulta" class="inputtexto">
        <option value="1" selected>Todas as partes com</option>
        <option value="2">Apenas com in&iacute;cio</option>
          <option value="3">Apenas com o fim</option>
          <option value="4">Igual &agrave; palavra/frase</option>
      </select></td>
      <td colspan="2"><input name="valor_consulta" type="text" id="valor_consulta" size="30" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar2').click();" class="inputtexto"></td>
      
    <td width="76"> <input name="pesquisar" type="button" class="botoes" id="pesquisar2" value="Pesquisar" alt="Faz a pesquisa com os dados informados"
            onClick="javascript:tryRequestToServer(function(){consulta(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value);});"></td>
      <td width="191"><div align="right">
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
  <table width="75%" align="center" cellspacing="1" class="bordaFina">
    <tr>
      <td width="20%" class="tabela">Código</td>
      <td width="30%" class="tabela">Conta contábil</td>
      <td width="50%" class="tabela">Descrição</td>
      <td width="5" class="tabela"></td>
    </tr>
   <% //variaveis da paginacao
      int linha = 0;
      int linhatotal = 0;
      int qtde_pag = 0;

      String ultima_linha = "";
      // se conseguiu consultar
      if ( (acao.equals("consultar") || acao.equals("proxima")) && (pc.Consultar()) )
      {
          ResultSet rs = pc.getResultado();
	  while (rs.next())
          {
                            //pega o resto da divisao e testa se é par ou impar
             %> <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" >
                  <td>
                       <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editar(<%=rs.getString("id")+","+rs.getBoolean("podeexcluir")%>);});">
			  <%=rs.getString("codigo")%>
 		       </div>
                  </td>
                  <td><%=rs.getString("conta")%></td>
                  <td><%=rs.getString("descricao")%></td>
                     <% if ((nivelUser == 4) && (rs.getBoolean("podeexcluir")))
                        {
                           %><td width="21"><img src="img/lixo.png" alt="Excluir este registro" style="cursor:pointer "
                                  onclick="javascript:tryRequestToServer(function(){excluir(<%=rs.getString("id")%>);});"
                                  width="21" height="22" border="0" align="right"></td>
                    <%}else{%><td width="6"></td>
                    <%}%>
                </tr>
              <% //se for a ultima linha................
                 if (rs.isLast()) {
                     ultima_linha = rs.getString("conta");
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
  <table width="75%" align="center" cellspacing="1" class="bordaFina">
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
