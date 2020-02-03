<%@ page contentType="text/html; charset=ISO-8859-1" language="java"
   import="venda.servico.*,
           nucleo.Apoio,
           java.sql.ResultSet" %>
		   
<%
	int nivelUser = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadtipo_servico") : 0);
	String acao = (request.getParameter("acao") != null && nivelUser > 0 ? request.getParameter("acao") : "");
	
	if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
    	response.sendError(HttpServletResponse.SC_FORBIDDEN);
	
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
			if(cookies[i].getName().equals("consultaServicos")){
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
			consulta = new Cookie("consultaServicos","");
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
	   	valorConsulta = (request.getParameter("valorDaConsulta") != null ? request.getParameter("valorDaConsulta") : (valor));
	   	campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("")
					? request.getParameter("campoDeConsulta") 
					: (campo.equals("")?"ts.descricao":campo));
	   	operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("") 
					? request.getParameter("operador") 
					: (operador.getValue().equals("")?"1":operador.getValue()));
	   	limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("") 
				? request.getParameter("limiteResultados")
				: (limite.getValue().equals("")?"10":limite.getValue()));
		consulta.setValue(valorConsulta+"!!"+campoConsulta);
		operador.setValue(operadorConsulta);
		limite.setValue(limiteResultados);
	    response.addCookie(consulta);
	    response.addCookie(operador);
	    response.addCookie(limite);
	}else{
		campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("") ? 
	            request.getParameter("campoDeConsulta") : "ts.descricao");
		valorConsulta = (request.getParameter("valorDaConsulta") != null && !request.getParameter("valorDaConsulta").trim().equals("") ? 
	            request.getParameter("valorDaConsulta") : "");
		operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("") ? 
	            request.getParameter("operador") : "1");
		limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("") ? 
	            request.getParameter("limiteResultados") : "10");
	}
	
%>

<jsp:useBean id="consTipoServico" class="venda.servico.BeanConsultaServico" />
<jsp:setProperty name="consTipoServico" property="*" />
<%
consTipoServico.setCampoDeConsulta(campoConsulta);
consTipoServico.setLimiteResultados(Integer.parseInt(limiteResultados));
consTipoServico.setOperador(Integer.parseInt(operadorConsulta));
consTipoServico.setValorDaConsulta(valorConsulta);

%>
<script type="text/javascript"  language="javascript">
    var paginaAtual = 0;
    var qtde_pag = 1;
    var linhatotal = 0;
    
function consultar(acao){
    document.location.replace("./consulta_servico.jsp?acao="+acao+"&paginaResultados="+(acao=='proxima'? <%=consTipoServico.getPaginaResultados() + 1%> : (acao=='anterior'? <%=consTipoServico.getPaginaResultados() - 1%>:1))+"&"+
                              concatFieldValue("campoDeConsulta,operador,valorDaConsulta,limiteResultados"));
}   

function excluir(id){
   function ev(resp, st){
       if (st == 200)
           location.href = location.href; 
       else 
          alert("Status "+st+"\n\nNão conseguiu realizar o acesso ao servidor!");
   } 
   
   if (!confirm("Deseja mesmo excluir este Serviço?"))
       return null;

   location.replace("./cadservico.jsp?acao=excluir&id="+id+"&telaListar=true", ev);
}    

function aoCarregar(){
    $("valorDaConsulta").focus();
    getObj("campoDeConsulta").value = "<%=(campoConsulta.equals("")? "ts.descricao" : campoConsulta)%>";
    getObj("operador").value = "<%=operadorConsulta%>";
    getObj("limiteResultados").value = "<%=limiteResultados%>";
    getObj("valorDaConsulta").value = "<%=valorConsulta%>";
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
}

function editar(id){
    location.href = "./cadservico.jsp?acao=editar&id="+id;
}
</script>
<html>
<head>
<script language="javascript" src="script/funcoes.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Webtrans - Consulta de Servi&ccedil;os</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="aoCarregar()">
<img src="img/banner.gif">
<br>
<table width="70%" align="center" class="bordaFina" >
  <tr >
    <td width="590" align="left"><b>Consulta de Servi&ccedil;os</b></td>
    <% if (nivelUser >= 3)
	{%>
      <td width="98">
      	<input name="novo" type="button" class="botoes" id="novo" 
               onClick="javascript:tryRequestToServer(function(){location.href  = './cadservico.jsp?acao=iniciar';});" 
               value="Novo cadastro">
      </td>
    <%}%>
  </tr>
</table>
<br>
<table width="70%" align="center" cellspacing="1" class="bordaFina">
  <tr class="celula">
    <td width="91"  height="20">
    <select name="campoDeConsulta" id="campoDeConsulta" class="inputtexto">
      <option value="ts.descricao" selected>Descri&ccedil;&atilde;o</option>
      <option value="tributacao">Tributa&ccedil;&atilde;o</option>
      <option value="ts.valor">valor</option>
    </select>
    </td>
    <td width="142"><select name="operador" id="operador" style="width:100% " class="inputtexto">
        <option value="1" selected>Todas as partes com</option>
        <option value="2">Apenas com in&iacute;cio</option>
        <option value="3">Apenas com o fim</option>
        <option value="4">Igual &agrave; palavra/frase</option>
    </select></td>
    <td colspan="2"><input name="valorDaConsulta" type="text" id="valorDaConsulta" size="25" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" class="inputtexto"></td>
    <td width="73"><input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" title="Faz a pesquisa com os dados informados"
                          onClick="javascript:tryRequestToServer(function(){consultar('consultar');});"></td>
    <td width="232"><div align="right"> Por p&aacute;g.:
            <select name="limiteResultados" id="limiteResultados" class="inputtexto">
              <option value="10" selected>10 resultados</option>
              <option value="20">20 resultados</option>
              <option value="30">30 resultados</option>
              <option value="40">40 resultados</option>
              <option value="50">50 resultados</option>
        </select>
    </div></td>
  </tr>
</table>
<table width="70%" border="0" class="bordaFina" align="center">
  <tr class="tabela">
    <td width="57%">Servi&ccedil;o </td>
    <td width="20%">Valor</td>
    <td width="20%">ISS</td>
    <td width="3%"></td>
  </tr>
  
<%int linha = 0;
  int linhatotal = 0;
  int qtde_pag = 0;
 
  if (acao.equals("iniciar") || acao.equals("consultar") || acao.equals("proxima")|| acao.equals("anterior"))
  {
      consTipoServico.setConexao(Apoio.getConnectionFromUser(request));
      //consultando
      if (consTipoServico.Consultar())
      {
          ResultSet r = consTipoServico.getResultado();
          while (r.next())
          {%>
              <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                <td><div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editar(<%=r.getInt("id")%>);});">
                    <%=r.getString("descricao")%></div>
                </td>
                 <td><%=r.getString("valor")%></td>
                 <td><%=r.getString("iss")%></td>
                 <td>
                 <%if((nivelUser == 4) && (/*r.getBoolean("podeexcluir")*/true))
                 {%>   
                 <img src="img/lixo.png" title="Excluir este registro" onClick="javascript:tryRequestToServer(function(){excluir(<%=r.getString("id")%>);});"
                                  class="imagemLink" align="right">    
                <%}%>                  
                 </td>
              </tr>
              <%if (r.isLast()) 
                 linhatotal = r.getInt("qtde_linhas");
              linha++;
          }
          
          int limit = consTipoServico.getLimiteResultados();
          qtde_pag = (linhatotal / limit) + (linhatotal % limit == 0 ? 0 : 1);          
      }
  }%>
  
  <script type="text/javascript" language="javascript" >paginaAtual= <%=consTipoServico== null ? 1 :consTipoServico.getPaginaResultados()%>;qtde_pag = <%=qtde_pag%>;linhatotal = <%=linhatotal%>;</script>
</table>
<br>
<table width="70%" align="center" cellspacing="1" class="bordaFina">
  <tr class="celula">
    <td width="40%" height="22"><center>
        Ocorr&ecirc;ncias: <b><%=linha%> / <%=linhatotal%></b>
    </center></td>
    <td width="40%" align="center">P&aacute;ginas: <b><%=(qtde_pag == 0 ? 0 : consTipoServico.getPaginaResultados())%> / <%=qtde_pag %></b></td>
    <td width="20%" align="center">
            <input name="voltar" type="button" class="botoes" id="voltar"
                   value="Anterior"  onClick="javascript:tryRequestToServer(function(){consultar('anterior');});">
            <input name="avancar" type="button" class="botoes" id="avancar"
                   value="Pr&oacute;xima"  onClick="javascript:tryRequestToServer(function(){consultar('proxima');});">
        </td>
  </tr>
</table>
</body>
</html>
