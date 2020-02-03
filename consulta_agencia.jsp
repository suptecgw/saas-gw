<%@ page contentType="text/html; charset=ISO-8859-1" language="java"
   import="venda.BeanAgencia,
           venda.BeanConsultaAgencia,
           nucleo.Apoio,
           java.sql.ResultSet" %>
		   
<%
int nivelUser = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadagencia") : 0);
String acao = (request.getParameter("acao") != null && nivelUser > 0 ? request.getParameter("acao") : "");
//testando se a sessao é válida e se o usuário tem acesso
if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
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
            if(cookies[i].getName().equals("consultaAgencia")){
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
		consulta = new Cookie("consultaAgencia","");
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
				: (campo.equals("")?"ag.abreviatura":campo));
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
            request.getParameter("campoDeConsulta") : "ag.abreviatura");
	valorConsulta = (request.getParameter("valorDaConsulta") != null && !request.getParameter("valorDaConsulta").trim().equals("") ? 
            request.getParameter("valorDaConsulta") : "");
	operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("") ? 
            request.getParameter("operador") : "1");
	operadorConsulta = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("") ? 
            request.getParameter("limiteResultados") : "10");
}


%>

<jsp:useBean id="consAg" class="venda.BeanConsultaAgencia" />
<jsp:setProperty name="consAg" property="*" />
<%
consAg.setCampoDeConsulta(campoConsulta);
consAg.setOperador(Integer.parseInt(operadorConsulta));
consAg.setLimiteResultados(Integer.parseInt(limiteResultados));
consAg.setValorDaConsulta(valorConsulta);
%>
<script type="text/javascript"  language="javascript">
    var paginaAtual = 0;
    var qtde_pag = 1;
    var linhatotal = 0;
    function consultar(acao){
        document.location.replace("./consulta_agencia.jsp?acao="+acao+"&paginaResultados="+(acao=='proxima'? <%=consAg.getPaginaResultados() + 1%> : (acao=='anterior'? <%=consAg.getPaginaResultados() + 1%> :1))+"&"+
                                concatFieldValue("campoDeConsulta,operador,valorDaConsulta,limiteResultados"));
    }   

    function excluir(id){
    function ev(resp, st){
        if (st == 200)
            if (resp.split("<=>")[1] != "")
                alert(resp.split("<=>")[1]);
            else
                consultar('consultar');
        else 
            alert("Status "+st+"\n\nNão conseguiu realizar o acesso ao servidor!");
    } 

    if (!confirm("Deseja mesmo excluir esta agência de apoio?"))
        return null;

    requisitaAjax("./cadagencia.jsp?acao=excluir&id="+id, ev);
    }    

    function aoCarregar(){
        
        $("valorDaConsulta").focus();
        getObj("campoDeConsulta").value = "<%=(consAg.getCampoDeConsulta().equals("")? "ag.abreviatura" : consAg.getCampoDeConsulta())%>";
        getObj("operador").value = "<%=consAg.getOperador()%>";
        getObj("limiteResultados").value = "<%=consAg.getLimiteResultados()%>";
        getObj("valorDaConsulta").value = "<%=consAg.getValorDaConsulta()%>";
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
    location.href = "./cadagencia.jsp?acao=editar&id="+id;

}
</script>
<html>
<head>
    <script language="javascript" src="script/funcoes.js"></script>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title>Webtrans - Consulta de Ag&ecirc;ncias de Apoio</title>
    <link href="estilo.css" rel="stylesheet" type="text/css">
</head>
<body onLoad="aoCarregar()">
    <img src="img/banner.gif" width="600" height="40">
    <br>
    <table width="75%" align="center" class="bordaFina" >
        <tr>
            <td width="590" align="left">
                <b>Consulta de Ag&ecirc;ncias de Apoio</b>
            </td>
            <% if (nivelUser >= 3)
                {%>
                <td width="98">
                    <input name="novo" type="button" class="botoes" id="novo" 
                           onClick="javascript:tryRequestToServer(function(){location.href  = './cadagencia.jsp?acao=iniciar';});" 
                           value="Novo cadastro">
                </td>
            <%}%>
        </tr>
    </table>
    <br>
    <table width="75%" align="center" cellspacing="1" class="bordaFina">
        <tr class="celula">
            <td width="15%"  height="20">
                <select name="campoDeConsulta" class="inputtexto" id="campoDeConsulta">
                    <option value="descricao">Nome da Ag&ecirc;ncia</option>
                    <option value="ag.abreviatura" selected>Abreviatura</option>
                    <option value="ag.telefone">Telefone</option>
                    <option value="f.abreviatura">Filial</option>
                </select>
            </td>
            <td width="15%">
                <select name="operador" id="operador" style="width:100%" class="inputtexto">
                    <option value="1" selected>Todas as partes com</option>
                    <option value="2">Apenas com in&iacute;cio</option>
                    <option value="3">Apenas com o fim</option>
                    <option value="4">Igual &agrave; palavra/frase</option>
                </select>
            </td>
            <td colspan="30" width="">
                <input name="valorDaConsulta" type="text" id="valorDaConsulta" size="20" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" class="inputtexto">
            </td>
            <td width="10%">
                <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" title="Faz a pesquisa com os dados informados"
                       onClick="javascript:tryRequestToServer(function(){consultar('consultar');});"></td>
            <td width="20%">
                <div align="right"> Por p&aacute;g.:
                    <select name="limiteResultados" id="limiteResultados" class="inputtexto">
                        <option value="10" selected>10 resultados</option>
                        <option value="20">20 resultados</option>
                        <option value="30">30 resultados</option>
                        <option value="40">40 resultados</option>
                        <option value="50">50 resultados</option>
                    </select>
                </div>
            </td>
        </tr>
    </table>
    <br>
    <table width="75%" align="center" border="0" class="bordaFina">
    <tr class="tabela">
        <td width="28%">Nome da Ag&ecirc;ncia</td>
        <td width="23%">Abreviatura</td>
        <td width="11%">Telefone</td>
        <td width="37%">Filial</td>
        <td width="1%">&nbsp;</td>
    </tr>

    <%int linha = 0;
    int linhatotal = 0;
    int qtde_pag = 0;

    if (acao.equals("iniciar") || acao.equals("consultar") || acao.equals("proxima")|| acao.equals("anterior"))
    {
        consAg.setConexao(Apoio.getConnectionFromUser(request));
        //consultando
        if (consAg.Consultar())
        {
            ResultSet r = consAg.getResultado();
            while (r.next())
            {%>
                <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                    <td><div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editar(<%=r.getInt("id")%>);});">
                        <%=r.getString("descricao")%></div>
                    </td>
                    <td><%=r.getString("abreviatura")%></td>
                    <td><%=r.getString("telefone")%></td>
                    <td><%=r.getString("filial")%></td>
                    <td>
                    <%if((nivelUser == 4) && (r.getBoolean("podeexcluir")))
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

            int limit = consAg.getLimiteResultados();
            qtde_pag = (linhatotal / limit) + (linhatotal % limit == 0 ? 0 : 1);          
        }
    }%>
    <script type="text/javascript" language="javascript" >paginaAtual= <%=consAg== null ? 1 :consAg.getPaginaResultados()%>;qtde_pag = <%=qtde_pag%>;linhatotal = <%=linhatotal%>;</script>

    </table>
    <br>
    <table width="75%" align="center" cellspacing="1" class="bordaFina">
        <tr class="celula">
            <td width="45%" height="22">
                <center>
                    Ocorr&ecirc;ncias: 
                    <b><%=linha%> / <%=linhatotal%></b>
                </center>
            </td>
            <td width="40%" align="center">P&aacute;ginas: 
                <b><%=(qtde_pag == 0 ? 0 : consAg.getPaginaResultados())%> / <%=qtde_pag %></b>
            </td>
            <td width="15%" align="center">
                <input name="voltar" type="button" class="botoes" id="voltar"
                        value="Anterior"  onClick="javascript:tryRequestToServer(function(){consultar('anterior');});">
                <input name="avancar" type="button" class="botoes" id="avancar"
                        value="Pr&oacute;xima"  onClick="javascript:tryRequestToServer(function(){consultar('proxima');});">
            </td>
        </tr>
    </table>
  </body>
</html>
