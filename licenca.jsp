<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">


<%  String WEBTRANS_STATUS = String.valueOf(getServletContext().getAttribute("WEBTRANS_LICENSE_STATUS"));
	boolean temAcesso = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("alterarlicenca") > 0 : false);
   //testando se a sessao eh valida e se o usuario tem acesso
   if (!temAcesso && !(WEBTRANS_STATUS.equals(""+HttpServletResponse.SC_SERVICE_UNAVAILABLE)))
       response.sendError(HttpServletResponse.SC_FORBIDDEN);
   
   String status_msg = "STATUS " + getServletContext().getAttribute("WEBTRANS_LICENSE_STATUS")+" - "+getServletContext().getAttribute("WEBTRANS_MESSAGE");
%>
<%@page import="nucleo.Apoio"%>

<script language="javascript" type="text/javascript">
<% if (request.getParameter("display_alert") != null){ %>
	alert("<%=status_msg%>");
<%}%>

<% if (request.getAttribute("status_chave") != null){ %>
	alert("<%=request.getAttribute("status_chave")%>");
<%}%>

</script>
<html>
<head>
	<script language="javascript" src="script/funcoes.js" type=""></script>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<meta http-equiv="content-language" content="pt">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="pragma" content="no-store">
	<meta http-equiv="expires" content="0">
	<meta name="language" content="pt-br">
	<title>Webtrans - Licenciamento</title>
	<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body>
	<img src="img/banner.gif" >
	<br>
	<table  width="550" align="center" class="bordaFina" >
	  <tr>
	    <td width="613"><div align="left"><b>Dados da Licença</b></div></td>
	  </tr>
	</table>
	<br>
	
	
	<table align="center" class="bordaFina" width="550" >
		<% if (Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ){ %>
		<tr>
			<td class="TextoCampos">Contratante:</td>
			<td  class="CelulaZebra2"><b><%= Apoio.getRazaoSocialContratante(this.getServletConfig()) %></b></td>
		</tr>
		<tr>
			<td class="TextoCampos">Alterar Chave:</td>
			<td  class="CelulaZebra2"><input type="text" name="chave" id="chave" maxlength="35" value="" />
				<input value="Alterar" type="button" class="botoes" onclick="location.href = './home?acao=salvar_chave&chave='+$('chave').value;"> 
			</td>
		</tr>
		<%} %>
		<tr>
			<td class="TextoCampos">Ultima verificação Online:</td>
			<td class="CelulaZebra2"><%=Apoio.coalesce(Apoio.getUltimaVerificacao(getServletConfig()), "<b>Não disponível</b>")%>&nbsp;&nbsp;&nbsp;<a href="./home?acao=verify_payment">[ Verificar agora ]</a></td>
		</tr>
		<tr>
			<td class="CelulaZebra2" colspan="2"><center><input value="    Fechar    " type="button" class="botoes" onclick="window.close();"></center></td>
		</tr>
	</table>
	<br />	
	<% 
	if (getServletContext().getAttribute("WEBTRANS_LICENSE_STATUS") != null && !getServletContext().getAttribute("WEBTRANS_LICENSE_STATUS").equals(""+HttpServletResponse.SC_OK)) {  %>
		<div style=" border-style: dotted; color: <%=WEBTRANS_STATUS.equals(""+HttpServletResponse.SC_SERVICE_UNAVAILABLE)? "red;" : "olive;"%> font-size: 10; width: 600; " align="center">
			<b>STATUS <%=getServletContext().getAttribute("WEBTRANS_LICENSE_STATUS") %> - <%=getServletContext().getAttribute("WEBTRANS_MESSAGE") %></b>
		</div>
	<%}%>
	
	
</body>

</html>