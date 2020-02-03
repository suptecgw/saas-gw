<%@ page contentType="text/html; charset=iso-8859-1" language="java"
  import="java.sql.ResultSet,
          filial.BeanConsultaFilial,
          filial.BeanCadFilial,
          usuario.BeanUsuario,
          nucleo.Apoio" %>
<% //ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadfilial") : 0);
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
		if(cookies[i].getName().equals("consultaFiliais")){
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
		consulta = new Cookie("consultaFiliais","");
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
				: (campo.equals("")?"razaosocial":campo));
   	operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("") 
				? request.getParameter("ope") 
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
            request.getParameter("campo") : "razaosocial");
	valorConsulta = (request.getParameter("valor") != null && !request.getParameter("valor").trim().equals("") ? 
            request.getParameter("valor") : "");
	operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("") ? 
            request.getParameter("ope") : "1");
	limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("") ? 
            request.getParameter("limite") : "10");
}
   
%>

<%  // DECLARANDO e inicializando as variaveis usadas no JSP
    BeanConsultaFilial beanfilial = null;
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

    if ((acao.equals("consultar")) || (acao.equals("proxima")) || (acao.equals("anterior")))
    {   //instanciando o bean
        beanfilial = new BeanConsultaFilial();
        beanfilial.setConexao( Apoio.getUsuario(request).getConexao() );
        beanfilial.setCampoDeConsulta(campoConsulta);
        beanfilial.setOperador(Apoio.parseInt(operadorConsulta));
        beanfilial.setValorDaConsulta(valorConsulta);
        beanfilial.setLimiteResultados(Apoio.parseInt(limiteResultados));
        beanfilial.setPaginaResultados(Apoio.parseInt(pag));
        
        // a chamada do método Consultar() está lá em mbaixo
    }

	if ((nivelUser == 4) && (acao.equals("excluir") && request.getParameter("id") != null))
	{
	    BeanCadFilial cadfi = new BeanCadFilial();
	    cadfi.setConexao(Apoio.getUsuario(request).getConexao());
            cadfi.setExecutor(Apoio.getUsuario(request));
            cadfi.getFilial().setIdfilial(Apoio.parseInt(request.getParameter("id")));
            %><script language="javascript"><%
            if (! cadfi.Deleta())
            {
                %>alert("Erro ao tentar excluir!");<%
            }
	    %>location.replace("ConsultaControlador?codTela=1");
            </script><%
	}
%>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" >
    var paginaAtual = 0;
    var qtde_pag = 1;
    var linhatotal = 0;
  function seleciona_campos(){
   <% //se for consultar agora, ele seleciona o campo q o usuario escolheu
      if ((campoConsulta != null) && (operadorConsulta != null) && (valorConsulta != null) && (limiteResultados != null) )
      {%>
           $("valor_consulta").focus();
           document.getElementById("valor_consulta").value = "<%=valorConsulta %>";
           document.getElementById("campo_consulta").value = "<%=campoConsulta%>";
           document.getElementById("operador_consulta").value = "<%=operadorConsulta %>";
           document.getElementById("limite").value = "<%=limiteResultados %>";
           if(paginaAtual <= 1){
                desabilitar($("voltar"));
            }
            if(paginaAtual == qtde_pag){
                desabilitar($("avancar"));
            }
            if(linhatotal <= 10 && qtde_pag <=0){
                desabilitar($("voltar"));
                desabilitar($("avancar"));
            }
    <%}%>
  }

  function consulta(campo, operador, valor, limite){
     if (campo == "cnpj") valor = unformatNumber(valor);
     location.replace("./consultafilial?campo="+campo+"&ope="+operador+"&valor="+valor+
                      "&limite="+limite+"&pag=1&acao=consultar");
  }

  function editarfilial(idfilial, podeexcluir){
     location.replace("./cadfilial?acao=editar&id="+idfilial+(podeexcluir != null ? "&ex="+podeexcluir : ""));
  }

  function cadfilial(){
      location.replace("./cadfilial?acao=iniciar");
  }

  function proxima(ultimo_titulo){
     <%                                               //Somando a pag atual + 1 para a proxima pagina %>
     location.replace("./consultafilial?pag="+<%=(Apoio.parseInt(pag) + 1)%>+
                      "&valor=<%=valorConsulta%>&limite=<%=limiteResultados%>&campo=<%=campoConsulta%>"+
                      "&ope=<%=operadorConsulta%>&ultimo="+ultimo_titulo+"&acao=proxima");
  }

  function anterior(ultimo_titulo){
     location.replace("./consultafilial?pag="+<%=(Apoio.parseInt(pag) - 1)%>+
                      "&valor=<%=valorConsulta%>&limite=<%=limiteResultados%>&campo=<%=campoConsulta%>"+
                      "&ope=<%=operadorConsulta%>&ultimo="+ultimo_titulo+"&acao=anterior");
  }

  function excluirfilial(idfilial){
       if (confirm("Deseja mesmo excluir esta filial?"))
	   {
	       location.replace("./consultafilial?acao=excluir&id="+idfilial);
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

<title>WebTrans - Consulta de filial</title>
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
<table width="80%" align="center" class="bordaFina" >
  <tr >
    <td width="461"><div align="left"><b>Consulta de filial</b></div></td>
    <% if (nivelUser >= 3)
	{%>
	<td width="102">
	  <input name="novafilial" type="button" class="botoes" id="novafilial" onClick="javascript:cadfilial();" value="Novo cadastro">
    </td>
  <%}%>
  </tr>
</table>
<br>
  <table width="80%" align="center" cellspacing="1" class="bordaFina">

    <tr class="celula">
      <td width="111"  height="20"><select name="campo_consulta" id="campo_consulta" class="inputtexto">
        <option value="abreviatura">Abreviatura</option>
        <option value="razaosocial" selected>Raz&atilde;o Social</option>
        <option value="cidade">Cidade</option>
        <option value="endereco">Endere&ccedil;o</option>
        <option value="uf">UF</option>
        <option value="cep">Cep</option>
        <option value="cnpj">CNPJ</option>
        <option value="fone">Telefone</option>
        </select>
      </td>
      <td width="158"><select name="operador_consulta" id="operador_consulta" class="inputtexto">
        <option value="1" selected>Todas as partes com</option>
        <option value="2">Apenas com in&iacute;cio</option>
          <option value="3">Apenas com o fim</option>
          <option value="4">Igual &agrave; palavra/frase</option>
      </select></td>
      <td colspan="2"><input name="valor_consulta" type="text" id="valor_consulta" size="25" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" class="inputtexto"></td>
      <td width="82">
	  <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" alt="Faz a pesquisa com os dados informados"
            onClick="javascript:tryRequestToServer(function(){consulta(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value);});"></td>
      <td width="231"><div align="right">
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
  <table width="80%" align="center" cellspacing="1" class="bordaFina">
    <tr>
      <td width="13%"  class="tabela">Abreviatura</td>
      <td width="25%" class="tabela">Raz&atilde;o Social </td>
      <td width="20%" class="tabela">Cidade</td>
      <td width="3%" class="tabela">UF</td>
      <td width="9%" class="tabela">CEP</td>
      <td width="12%" class="tabela">Telefone</td>
      <td width="16%" class="tabela">CNPJ</td>
      <td width="2%" class="tabela"></td>
    </tr>
   <% //variaveis da paginacao
      int linha = 0;
      int linhatotal = 0;
      int qtde_pag = 0;

      String ultima_linha = "";
      // se conseguiu consultar
      if ( (acao.equals("consultar") || acao.equals("proxima")|| acao.equals("anterior")) && (beanfilial.Consultar()) )
      {
          ResultSet rs = beanfilial.getResultado();
	  while (rs.next())
          {
                            //pega o resto da divisao e testa se é par ou impar
             %> <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" >
                  <td>
                       <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editarfilial(<%=rs.getString("idfilial")+","+(rs.getBoolean("podeexcluir") ? "null" : "0")%>);});">
							<%=rs.getString("abreviatura")%>
					   </div>
                  </td>
                  <td><%=rs.getString("razaosocial")%></td>
                  <td><%=rs.getString("cidade")%></td>
                  <td><%=rs.getString("uf")%></td>
                  <td><%=rs.getString("cep")%></td>
                  <td><%=rs.getString("fone")%></td>
       		      <td><script language="javascript">
			        document.write(formatCpfCnpj("<%=rs.getString("cnpj")%>",true,true));
		          </script></td>

                     <% if((nivelUser == 4) && (rs.getBoolean("podeexcluir")))
                        {
                           %><td width="10"><img src="img/lixo.png" alt="Excluir este registro" style="cursor:pointer "
                                  onclick="javascript:tryRequestToServer(function(){excluirfilial(<%=rs.getString("idfilial")%>);});"></td>
                    <%}else{%><td></td><%}%>
                </tr>
              <% //se for a ultima linha................
                 if (rs.isLast()) {
                     ultima_linha = rs.getString("abreviatura");
                     //Quantidade geral de resultados da consulta
                     linhatotal = rs.getInt("qtde_linhas");
                 }
                 linha++;
          }//while
          //se os resultados forem divididos pelas paginas e sobrar, some mais uma pag
          qtde_pag = ((linhatotal % Apoio.parseInt(limiteResultados)) == 0
                       ? (linhatotal / Apoio.parseInt(limiteResultados))
                       : (linhatotal / Apoio.parseInt(limiteResultados)) + 1);
      }//if
      pag = ( qtde_pag == 0 ? "0" : pag );
	  %><script type="text/javascript" language="javascript" >paginaAtual= <%=beanfilial== null ? 1 :beanfilial.getPaginaResultados()%>;qtde_pag = <%=qtde_pag%>;linhatotal = <%=linhatotal%>;</script>
</table>
<br>
  <table width="80%" align="center" cellspacing="1" class="bordaFina">
   <tr class="celula">
      <td width="45%" height="22">
	  <center>
	     Ocorrências: <b><%=linha%> / <%=linhatotal%></b>
	  </center>
     </td>
      <td width="40%" align="center">Páginas: <b><%=pag %> / <%=qtde_pag %></b></td>
      <td width="15%"><div align="center">
			<input name="voltar" type="button" class="botoes" id="voltar"
              value="Anterior"  onClick="javascript:tryRequestToServer(function(){anterior('<%=ultima_linha%>');});">
			<input name="avancar" type="button" class="botoes" id="avancar"
              value="Próxima"  onClick="javascript:tryRequestToServer(function(){proxima('<%=ultima_linha%>');});">
			</div></td>

    </tr>
</table>
  <br>
<br>
<br>
<br>
</body>
</html>
