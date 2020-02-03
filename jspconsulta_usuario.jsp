<%@ page contentType="text/html; charset=iso-8859-1" language="java"
  import="java.sql.ResultSet,
          usuario.BeanConsultaUsuario,
          usuario.BeanCadUsuario,
          usuario.BeanUsuario,
          nucleo.Apoio" %>
<% //ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadusuario") : 0);
   //testando se a sessao eh valida e se o usuario tem acesso
   if (Apoio.getUsuario(request) == null || nivelUser == 0)
       response.sendError(response.SC_FORBIDDEN);
   
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
   		if(cookies[i].getName().equals("consultaUsuario")){
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
   		consulta = new Cookie("consultaUsuario","");
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
   				: (campo.equals("")?"nome":campo));
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
               request.getParameter("campo") : "nome");
   	valorConsulta = (request.getParameter("valor") != null && !request.getParameter("valor").trim().equals("") ? 
               request.getParameter("valor") : "");
   	operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("") ? 
               request.getParameter("ope") : "1");
   	limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("") ? 
               request.getParameter("limite") : "10");
   }
%>
<%  // DECLARANDO e inicializando as variaveis usadas no JSP
    BeanConsultaUsuario beanusuario = null;
    String acao     = request.getParameter("acao");
    acao = ((acao == null) || (nivelUser == 0) ? "" : acao);
    //variavel responsavel pela paginacao. Pega o ultimo titulo
    String ultimotitulo = request.getParameter("ultimo");
    String pag  = (request.getParameter("pag") != null ? request.getParameter("pag") : "0");

    if (acao.equals("iniciar")){
      acao = "consultar";
      pag = "1";
    }

    if ((acao.equals("consultar")) || (acao.equals("proxima")) || (acao.equals("anterior"))){   //instanciando o bean
        beanusuario = new BeanConsultaUsuario();
        //se naum é um administrador entaum vai ser carregado só os usuarios da filial
        if (nivelUser == 0){
              beanusuario.setRestricaoIdFilial(Apoio.getUsuario(request).getFilial().getIdfilial());
        }
        beanusuario.setConexao(Apoio.getUsuario(request).getConexao());
        beanusuario.setCampoDeConsulta(campoConsulta);
        beanusuario.setOperador(Integer.parseInt(operadorConsulta));
        beanusuario.setValorDaConsulta(valorConsulta);
        beanusuario.setLimiteResultados(Integer.parseInt(limiteResultados));
        beanusuario.setPaginaResultados(Integer.parseInt(pag));
        // a chamada do método Consultar() está lá em mbaixo
    }

	if ((nivelUser == 4) && (acao.equals("excluir") && request.getParameter("id") != null)){
	    BeanCadUsuario cadusu = new BeanCadUsuario();
	    cadusu.setConexao(Apoio.getUsuario(request).getConexao());
            cadusu.setExecutor(Apoio.getUsuario(request));
            cadusu.setIdusuario(Integer.parseInt(request.getParameter("id")));
            if (nivelUser < 4){
                 cadusu.setRestricaoidfilial(Apoio.getUsuario(request).getFilial().getIdfilial());
            }
            %><script language="javascript"><%
            if (! cadusu.Deleta())
            {
                %>alert("Erro ao tentar excluir!");<%
            }
	    %>location.replace("./consultausuario?acao=iniciar");
            </script><%
	}
%>

<script language="javascript" type="text/javascript" >
    var paginaAtual = 0;
    var qtde_pag = 1;
    var linhatotal = 0;
  function seleciona_campos(){
   <% //se for consultar agora, ele seleciona o campo q o usuario escolheu
      if ((campoConsulta != null) && (operadorConsulta != null) && (valorConsulta != null) && (limiteResultados != null) )
      {%>
           document.getElementById("valor_consulta").value = "<%=valorConsulta %>";
           document.getElementById("campo_consulta").value = "<%=campoConsulta%>";
           document.getElementById("operador_consulta").value = "<%=operadorConsulta%>";
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
     location.replace("./consultausuario?campo="+campo+"&ope="+operador+"&valor="+valor+
                      "&limite="+limite+"&pag=1&acao=consultar");
  }

  function editarusuario(idusuario){
     location.replace("./cadusuario?acao=editar&id="+idusuario);
  }

  function cadusuario(){
      location.replace("./cadusuario?acao=iniciar");
  }

  function proxima(campo, operador, valor, limite){
     <%/*Somando a pag atual + 1 para a proxima pagina */%>
     location.replace("./consultausuario?pag="+<%=(Integer.parseInt(pag) + 1)%>+
                      "&valor="+valor+"&limite="+limite+"&campo="+campo+
                      "&ope="+operador+"&ultimo=&acao=proxima");
  }

  function anterior(campo, operador, valor, limite){
     <%/*Somando a pag atual + 1 para a proxima pagina */%>
     location.replace("./consultausuario?pag="+<%=(Integer.parseInt(pag) - 1)%>+
                      "&valor="+valor+"&limite="+limite+"&campo="+campo+
                      "&ope="+operador+"&ultimo=&acao=anterior");
  }

  function excluirusuario(idusuario){
       if (confirm("Deseja mesmo excluir este usuario?"))
	   {
	       location.replace("./consultausuario?acao=excluir&id="+idusuario);
	   }
  }
</script>

<html>
<head>
<script language="javascript" src="script/funcoes.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="pt" />
<meta http-equiv="cache-control" content="no-cache" />
<meta http-equiv="pragma" content="no-store" />
<meta http-equiv="expires" content="0" />
<meta name="language" content="pt-br" />

<title>WebTrans - Consulta de usuário</title>
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
<table width="70%" align="center" class="bordaFina" >
  <tr >
    <td width="590"><div align="left"><b>Consulta de usu&aacute;rio </b></div></td>
    <% if (nivelUser >= 3)
	{%>
	<td width="98">
	  <input name="novousuario" type="button" class="botoes" id="novousuario" onClick="javascript:tryRequestToServer(function(){cadusuario();});" value="Novo cadastro">
    </td>
  <%}%>
  </tr>
</table>
<br>
  <table width="70%" align="center" cellspacing="1" class="bordaFina">

    <tr class="celula">
      <td width="71"  height="20"><select name="campo_consulta" id="campo_consulta" class="inputtexto">
        <option value="nome" selected>Nome</option>
        <option value="email">Email</option>
        <option value="abreviatura">Filial</option>
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
	  <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" title="Faz a pesquisa com os dados informados"
            onClick="javascript:tryRequestToServer(function(){consulta(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value);});"></td>
      <td width="202"><div align="right">
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
  <table width="70%" align="center" cellspacing="1" class="bordaFina">
    <tr>
      <td width="315" class="tabela">Nome</td>
      <td width="290"  class="tabela">E-Mail</td>
      <td width="288" class="tabela">Filial Abrev. </td>
      <td width="23" class="tabela"></td>
    </tr>
   <% //variaveis da paginacao
      int linha = 0;
      int linhatotal = 0;
      int qtde_pag = 0;

      String ultima_linha = "";
      // se conseguiu consultar
      if ( (acao.equals("consultar") || acao.equals("proxima") || acao.equals("anterior")) && (beanusuario.Consultar()) ){
          ResultSet rs = beanusuario.getResultado();
	  while (rs.next()){
                            //pega o resto da divisao e testa se é par ou impar
             %> <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" >
                  <td>
                       <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editarusuario(<%=rs.getString("idusuario")%>);});">
							<%=rs.getString("nome")%>
                       </div>
                  </td>
                  <td><%=rs.getString("email")%></td>
                  <td><%=rs.getString("filial")%></td>
                  <% if (nivelUser == 4)
                        {
                           %><td width="23"><img src="img/lixo.png" title="Excluir este registro" style="cursor:pointer "
                                  onclick="javascript:tryRequestToServer(function(){excluirusuario(<%=rs.getString("idusuario")%>);});"></td>
                    <%}else{%><td width="4"></td>
                    <%}%>
                </tr>
              <% //se for a ultima linha................
                 if (rs.isLast()) {
                     ultima_linha = rs.getString("nome");
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
	  %><script type="text/javascript" language="javascript" >paginaAtual= <%=beanusuario== null ? 1 :beanusuario.getPaginaResultados()%>;qtde_pag = <%=qtde_pag%>;linhatotal = <%=linhatotal%>;</script>
</table>
<br>
  <table width="70%" align="center" cellspacing="1" class="bordaFina">
   <tr class="celula">
      <td width="40%" height="22">
	  <center>
	     Ocorrências: <b><%=linha%> / <%=linhatotal%></b>
	  </center>
     </td>
      <td width="40%" align="center">Páginas: <b><%=pag %> / <%=qtde_pag %></b></td>
      <td width="20%"><div align="center">
			<input name="voltar" type="button" class="botoes" id="voltar"
              value="Anterior"  onClick="javascript:tryRequestToServer(function(){anterior('<%=campoConsulta%>','<%=operadorConsulta%>','<%=valorConsulta%>','<%=limiteResultados%>');});">
			<input name="avancar" type="button" class="botoes" id="avancar"
              value="Próxima"  onClick="javascript:tryRequestToServer(function(){proxima('<%=campoConsulta%>','<%=operadorConsulta%>','<%=valorConsulta%>','<%=limiteResultados%>');});">
			</div></td>

    </tr>
</table>
  <br>
<br>
<br>
<br>
</body>
</html>
