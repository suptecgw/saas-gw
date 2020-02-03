<%@ page contentType="text/html; charset=iso-8859-1" language="java"
  import="java.sql.ResultSet,
          historico.BeanConsultaHistorico,
  	      historico.BeanCadHistorico,
          nucleo.Apoio" %>

<% //ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadhist") : 0);
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA

   String valorConsulta = "";
   String limiteResultados = "";
   Cookie consulta = null;
   Cookie limite = null;
   int linha = 0;
   int linhatotal = 0;
   int qtde_pag = 0;


   Cookie cookies[] = request.getCookies();
   if (cookies != null){
   	for(int i = 0; i < cookies.length; i++){
   		if(cookies[i].getName().equals("consultaHistorico")){
   			consulta = cookies[i];
   		}else if(cookies[i].getName().equals("limiteConsulta")){
   			limite = cookies[i]; 
   		}
   		if (consulta != null && limite != null){ //se já encontrou os cookies então saia
   			break;
   		}
   	}
   	if (consulta == null){//se não achou o cookieu então inclua
   		consulta = new Cookie("consultaHistorico","");
   	}
   	if (limite == null){//se não achou o cookieu então inclua
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
    BeanConsultaHistorico beanhist = null;
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
        beanhist = new BeanConsultaHistorico();
        beanhist.setConexao( Apoio.getUsuario(request).getConexao() );
        beanhist.setValorDaConsulta(valorConsulta);
        beanhist.setLimiteResultados(Integer.parseInt(limiteResultados));
        beanhist.setPaginacao(pag);
        //if (acao.equals("proxima"))   	       beanhist.setPaginacao(ultimotitulo);
        // a chamada do método Consultar() está lá em mbaixo
    }

	if ((nivelUser == 4) && (acao.equals("excluir") && request.getParameter("id") != null))
	{
	    BeanCadHistorico cadhist = new BeanCadHistorico();
	    cadhist.setConexao(Apoio.getUsuario(request).getConexao());
            cadhist.setExecutor(Apoio.getUsuario(request));
            cadhist.setIdhist(Integer.parseInt(request.getParameter("id")));
            %><script language="javascript"><%
            if (! cadhist.Deleta())
            {
                %>alert("Erro ao tentar excluir!");<%
            }
	    %>location.replace("ConsultaControlador?codTela=15");
            </script><%
	}
%>

<script language="javascript" src="script/funcoes.js" type=""></script>
<script language="javascript" type="text/javascript" >
var paginaAtual = <%=pag%>;
var qtde_pag = 1;
var linhatotal = 0;
  function seleciona_campos(){
   <% //se for consultar agora, ele seleciona o campo q o usuario escolheu
      if ((valorConsulta != null) && (limiteResultados != null) ){%>
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
     location.replace("./consultahistorico?valor="+valor+
                      "&limite="+limite+"&pag=1&acao=consultar");
  }

  function editar(idhist, podeexcluir){
     location.replace("./cadhistorico?acao=editar&id="+idhist+(podeexcluir != null ? "&ex="+podeexcluir : ""));
  }

  function novo(){
      location.replace("./cadhistorico?acao=iniciar");
  }

  function anterior(ultimo_titulo){
     <%                                               //Somando a pag atual + 1 para a proxima pagina %>
     location.replace("./consultahistorico?pag="+<%=(Integer.parseInt(pag) - 1)%>+
                      "&valor=<%=valorConsulta%>&limite=<%=limiteResultados%>&ultimo="+ultimo_titulo+"&acao=proxima");
  }

  function proxima(ultimo_titulo){
     <%                                               //Somando a pag atual + 1 para a proxima pagina %>
     location.replace("./consultahistorico?pag="+<%=(Integer.parseInt(pag) + 1)%>+
                      "&valor=<%=valorConsulta%>&limite=<%=limiteResultados%>&ultimo="+ultimo_titulo+"&acao=proxima");
  }

  function excluir(idhist){
       if (confirm("Deseja mesmo excluir este histórico?"))
	   {
	       location.replace("./consultahistorico?acao=excluir&id="+idhist);
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

<title>WebTrans - Consulta de Histórico para Lançamentos</title>
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
    <td width="461"><div align="left"><b>Consulta de Hist&oacute;rico para Lan&ccedil;amentos</b></div></td>
    <% if (nivelUser >= 3)
	{%>
	<td width="102">
	  <input name="novo" type="button" class="botoes" id="novo" onClick="javascript:novo();" value="Novo cadastro">
    </td>
  <%}%>
  </tr>
</table>
<br>
  <table width="50%" align="center" cellspacing="1" class="bordaFina">
    <tr class="celula">
        <td width="221"  height="20">      <input name="valor_consulta" type="text" id="valor_consulta"  size="35" maxlength="25" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" class="inputtexto"></td>
      <td width="116">
	  <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" alt="Faz a pesquisa com os dados informados"
            onClick="javascript:tryRequestToServer(function(){consulta(valor_consulta.value, limite.value);});"></td>
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
      <td width="10%" class="tabela">Código</td>
      <td width="80%" class="tabela">Histórico</td>
      <td width="10%" class="tabela"></td>
    </tr>
   <% //variaveis da paginacao
      
      String ultima_linha = "";
      // se conseguiu consultar
      if ( (acao.equals("consultar") || acao.equals("proxima")) && (beanhist.Consultar()) )
      {
          ResultSet rs = beanhist.getResultado();
	  while (rs.next())
          {
                            //pega o resto da divisao e testa se é par ou impar
             %> <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" >
                  <td>
                       <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editar(<%=rs.getString("idhist")+",true"%>);});">
                         <%=rs.getString("codigo_historico")%>
					   </div>
                  </td>
                  <td><%=rs.getString("deschist")%>
                  <% if(nivelUser == 4)
                        {
                           %><td width="21"><img src="img/lixo.png" alt="Excluir este registro" style="cursor:pointer "
                                  onclick="javascript:tryRequestToServer(function(){excluir(<%=rs.getString("idhist")%>);});"
                                  width="21" height="22" border="0" align="right"></td>
                    <%}else{%><td></td>
                    <%}%>
                </tr>
              <% //se for a ultima linha................
                 if (rs.isLast()) {
                     ultima_linha = rs.getString("deschist");
                     //Quantidade geral de resultados da consulta
                     linhatotal = rs.getInt("qtde_linhas");
                 }
                 linha++;
          }//while
          //se os resultados forem divididos pelas paginas e sobrar, some mais uma pag
          qtde_pag = ((linhatotal % Integer.parseInt(limiteResultados)) == 0
                       ? (linhatotal / Integer.parseInt(limiteResultados))
                       : (linhatotal / Integer.parseInt(limiteResultados)) + 1);
          %>
          <script type="text/javascript" language="javascript" >qtde_pag = <%=qtde_pag%>;linhatotal = <%=linhatotal%>;</script>
          <%

      }//if
      pag = ( qtde_pag == 0 ? "0" : pag );
	  %>
</table>
<br>
  <table width="50%" align="center" cellspacing="1" class="bordaFina">
   <tr class="celula">
      <td width="40%" height="22">
	  <center>
	     Ocorrências: <b><%=linha%> / <%=linhatotal%></b>
	  </center>
     </td>
      <td width="35%" align="center">Páginas: <b><%=pag %> / <%=qtde_pag %></b></td>
      
            <td width="25%">
                <div align="center">
			<input name="voltar" type="button" class="botoes" id="voltar" value="Anterior"  onClick="javascript:tryRequestToServer(function(){anterior('<%=ultima_linha%>');});">
			<input name="avancar" type="button" class="botoes" id="avancar" value="Próxima"  onClick="javascript:tryRequestToServer(function(){proxima('<%=ultima_linha%>');});">
                </div>
            </td>
      
    </tr>
</table>
  <br>
<br>
<br>
<br>
</body>
</html>
