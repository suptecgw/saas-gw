<%@ page contentType="text/html; charset=ISO-8859-1" language="java"
  import="java.sql.ResultSet,
          marca.BeanConsultaMarca,
  	  marca.BeanCadMarca,
          nucleo.Apoio" %>    
   
<% //ATENCAO! Esta variavel vai ser usada em todo o JSP para o teste de
   // privilegio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadmarca") : 0);
   //testando se a sessao eh valida e se o usuario tem acesso
   if (Apoio.getUsuario(request) == null || nivelUser == 0)
       response.sendError(response.SC_FORBIDDEN);

   String valorConsulta = "";
   String limiteResultados = "";
   Cookie consulta = null;
   Cookie limite = null;

   Cookie cookies[] = request.getCookies();
   if (cookies != null){
   	for(int i = 0; i < cookies.length; i++){
   		if(cookies[i].getName().equals("consultaMarca")){
   			consulta = cookies[i];
   		}else if(cookies[i].getName().equals("limiteConsulta")){
   			limite = cookies[i]; 
   		}
   		if (consulta != null && limite != null){ //se j� encontrou os cookies ent�o saia
   			break;
   		}
   	}
   	if (consulta == null){//se n�o achou o cookieu ent�o inclua
   		consulta = new Cookie("consultaMarca","");
   	}
   	if (limite == null){//se n�o achou o cookieu ent�o inclua
   		limite = new Cookie("limiteConsulta","");
   	}
       consulta.setMaxAge(60 * 60 * 24 * 90);
       limite.setMaxAge(60 * 60 * 24 * 90);

       String valor = (consulta.getValue().equals("") ? "" : consulta.getValue());
      	valorConsulta = (request.getParameter("valor") != null ? request.getParameter("valor") : (valor));
      	limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("") 
   			? request.getParameter("limite")
   			: (limite.getValue().equals("")?"10":limite.getValue()));
   	consulta.setValue(valorConsulta);
   	limite.setValue(limiteResultados);
       response.addCookie(consulta);
       response.addCookie(limite);
   }else{
   	valorConsulta = (request.getParameter("valor") != null && !request.getParameter("valor").trim().equals("") ? 
               request.getParameter("valor") : "");
   	limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("") ? 
               request.getParameter("limite") : "10");
   }
%>

<%  // DECLARANDO e inicializando as variaveis usadas no JSP
    BeanConsultaMarca beanmarca = null;
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
        beanmarca = new BeanConsultaMarca();
        beanmarca.setConexao( Apoio.getUsuario(request).getConexao() );
        beanmarca.setValorDaConsulta(valorConsulta);
        beanmarca.setLimiteResultados(Integer.parseInt(limiteResultados));
        beanmarca.setPaginaResultados(Integer.parseInt(pag));
        
        // a chamada do metodo Consultar() esta la em mbaixo
    }

	if ((nivelUser == 4) && (acao.equals("excluir") && request.getParameter("id") != null))
	{
	    BeanCadMarca cadmarca = new BeanCadMarca();
	    cadmarca.setConexao(Apoio.getUsuario(request).getConexao());
            cadmarca.setExecutor(Apoio.getUsuario(request));
            cadmarca.setIdmarca(Integer.parseInt(request.getParameter("id")));
            %><script language="javascript"><%
            if (! cadmarca.Deleta())
            {
                %>alert("Erro ao tentar excluir!");<%
            }
	    %>location.replace("./consultamarca?acao=iniciar");
            </script><%
	}
%>
 
<script language="javascript" type="text/javascript" >
    console.log("asd");
    var paginaAtual = 0;
    var qtde_pag = 1;
    var linhatotal = 0;
  function seleciona_campos(){
   <% //se for consultar agora, ele seleciona o campo q o usuario escolheu
      if ((valorConsulta != null) && (limiteResultados != null) )
      {%>
           $("valor_consulta").focus();
           document.getElementById("valor_consulta").value = "<%=valorConsulta %>";
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

  function consulta(valor, limite){
     location.replace("./consultamarca?valor="+valor+
                      "&limite="+limite+"&pag=1&acao=consultar");
  }

  function editar(idmarca, podeexcluir){
     location.replace("./cadmarca?acao=editar&id="+idmarca+(podeexcluir != null ? "&ex="+podeexcluir : ""));
  }

  function novo(){
      location.replace("./cadmarca?acao=iniciar");
  }

  function proxima(ultimo_titulo){
				 <%                                               //Somando a pag atual + 1 para a proxima pagina %>
				 location.replace("./consultamarca?pag="+<%=(Integer.parseInt(pag) + 1)%>+
								  "&valor=<%=valorConsulta%>&limite=<%=limiteResultados%>&ultimo="+ultimo_titulo+"&acao=proxima");
  }

  function anterior(ultimo_titulo){
				 <%                                               //Somando a pag atual + 1 para a proxima pagina %>
				 location.replace("./consultamarca?pag="+<%=(Integer.parseInt(pag) - 1)%>+
								  "&valor=<%=valorConsulta%>&limite=<%=limiteResultados%>&ultimo="+ultimo_titulo+"&acao=anterior");
  }

  function excluir(idmarca){
	    if (confirm("Deseja mesmo excluir esta marca?"))
	    {
		    location.replace("./consultamarca?acao=excluir&id="+idmarca);
	    }
  }
</script>

<html>
<head>
<script language="javascript" src="script/funcoes.js" type=""></script>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta http-equiv="content-language" content="pt" />
<meta http-equiv="cache-control" content="no-cache" />
<meta http-equiv="pragma" content="no-store" />
<meta http-equiv="expires" content="0" />
<meta name="language" content="pt-br" />

<title>WebTrans - Consulta de Marcas</title>
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
<table width="50%" align="center" class="bordaFina" >
  <tr >
    <td width="590"><div align="left"><b>Consulta de Marcas </b></div></td>
    <% if (nivelUser >= 3)
	{%>
	<td width="98">
	  <input name="novo_b" type="button" class="botoes" id="novo_b" onClick="javascript:tryRequestToServer(novo);" value="Novo cadastro">
    </td>
  <%}%>
  </tr>
</table>
<br>
  <table width="50%" align="center" cellspacing="1" class="bordaFina">
    <tr class="celula">
      <td width="221"  height="20">      <input name="valor_consulta" type="text" id="valor_consulta"  size="30" maxlength="25" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" class="inputtexto"></td>
      <td width="116">
	  <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" alt="Faz a pesquisa com os dados informados"
            onClick="javascript:tryRequestToServer(function(){consulta(valor_consulta.value, limite.value);})"></td>
      <td width="101"><div align="right">
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
  <table width="50%" align="center" cellspacing="1" class="bordaFina">
    <tr>
      <td width="644" class="tabela">Marca</td>
      <td class="tabela"></td>
    </tr>
   <% //variaveis da paginacao
      int linha = 0;
      int linhatotal = 0;
      int qtde_pag = 0;

      String ultima_linha = "";
      // se conseguiu consultar
      if ( (acao.equals("consultar") || acao.equals("proxima")|| acao.equals("anterior")) && (beanmarca.Consultar()) )
      {
          ResultSet rs = beanmarca.getResultado();
	  while (rs.next())
          {
                            //pega o resto da divisao e testa se eh par ou impar
             %> <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" >
                  <td>
                       <a class="linkEditar" href="javascript:tryRequestToServer(function(){ editar(<%=rs.getString("idmarca")+","+(rs.getBoolean("podeexcluir") ? "null" : "0")%>);});">
							<%=rs.getString("descricao")%>
					   </a>
                  </td>
                  <% if((nivelUser == 4) && (rs.getBoolean("podeexcluir")))
                        {
                           %><td width="21"><img id="imgExcluir" src="img/lixo.png" alt="Excluir este registro" style="cursor:pointer "
                                  onclick="javascript:tryRequestToServer(function(){excluir(<%=rs.getString("idmarca")%>);});"
                                  width="21" height="22" border="0" align="right"></td>
                    <%}else{%><td></td>
                    <%}%>
                </tr>
              <% //se for a ultima linha................
                 if (rs.isLast()) {
                     ultima_linha = rs.getString("descricao");
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
	  %><script type="text/javascript" language="javascript" >paginaAtual= <%=beanmarca== null ? 1 :beanmarca.getPaginaResultados()%>;qtde_pag = <%=qtde_pag%>;linhatotal = <%=linhatotal%>;</script>
</table>
<br>
  <table width="50%" align="center" cellspacing="1" class="bordaFina">
   <tr class="celula">
      <td width="35%" height="22">
	  <center>
	     Ocorr&ecirc;ncias: <b><%=linha%> / <%=linhatotal%></b>
	  </center>
     </td>
      <td width="35%" align="center">P&oacute;ginas: <b><%=pag %> / <%=qtde_pag %></b></td>
      
      <td width="30%"><div align="center">
			<input name="voltar" type="button" class="botoes" id="voltar"
              value="Anterior"  onClick="javascript:tryRequestToServer(function(){anterior('<%=ultima_linha%>');});">
			<input name="avancar" type="button" class="botoes" id="avancar"
              value="Pr&oacute;xima"  onClick="javascript:tryRequestToServer(function(){proxima('<%=ultima_linha%>');});">
			</div></td>
      
    </tr>
</table>
  <br>
<br>
<br>
<br>
</body>
</html>
