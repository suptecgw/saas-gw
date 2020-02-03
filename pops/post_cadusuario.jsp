<%@page import="java.util.Enumeration"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
   import="nucleo.Apoio,
           usuario.BeanCadUsuario" errorPage="" %>

<% //ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadusuario") : 0);
   //boolean souadm = Apoio.getUsuario(request).getSouAdm();
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser < 2))
       getServletContext().getRequestDispatcher((Apoio.getUsuario(request) == null
                                                 ?"/login":"/menu")).forward(request, response);
   //usuario administrador??
   boolean adm = Apoio.getUsuario(request).getAcesso("cadusuario") == 4;
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="pt">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="pragma" content="no-store">
<meta http-equiv="expires" content="0">
<meta name="language" content="pt-br">
<style type="text/css">
<!--
body {
	margin-left: 0px;
	margin-top: 0px;
	margin-right: 0px;
	margin-bottom: 0px;
}
-->
</style></head>
<body>
<form id="frmcad" name="frmcad" method="post">
	<input id="nom" name="nom" type="hidden" value="asd">
	<input id="lo" name="lo" type="hidden" value="">
	<input id="ema" name="ema" type="hidden" value="">
	<input id="sh" name="sh" type="hidden" value="">
	<input id="idfi" name="idfi" type="hidden" value="">
	<input id="idps" name="idps" type="hidden" value="">
	<input id="idni" name="idni" type="hidden" value="">
	<input id="agencia" name="agencia" type="hidden" value="">
	<input id="grupo" name="grupo" type="hidden" value="">
        
        <input id="rod" name="rod" type="hidden" value="">
        <input id="aer" name="aer" type="hidden" value="">
        <input id="mar" name="mar" type="hidden" value="">
        <input id="flu" name="flu" type="hidden" value="">
</form>
</body>
</html>
<%
  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  if (!acao.equals("ini"))
  {
	  //executando a acao desejada
	  if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir")))
	  {
		  BeanCadUsuario cadusu = new BeanCadUsuario();
		  cadusu.setConexao(Apoio.getUsuario(request).getConexao());
                  cadusu.setExecutor(Apoio.getUsuario(request));

		  //populando o JavaBean
		  cadusu.setNome(request.getParameter("nom"));
		  cadusu.setEmail(request.getParameter("ema"));
		  cadusu.setLogin(request.getParameter("lo"));
		  cadusu.setSenha(request.getParameter("sh"));
		  cadusu.getAgencia().setId(Integer.parseInt(request.getParameter("agencia")));
		  cadusu.getGrupo().setId(Integer.parseInt(request.getParameter("grupo")));
    	          cadusu.setIdpermissoes(request.getParameter("idps").split(","));
	          cadusu.setNiveis(request.getParameter("idni").split(","));
                  
                  cadusu.setEmiteRodoviario(Boolean.parseBoolean(request.getParameter("rod")));
                  cadusu.setEmiteAereo(Boolean.parseBoolean((request.getParameter("aer"))));
                  cadusu.setEmiteAquaviario(Boolean.parseBoolean(request.getParameter("aqu")));
                  
                /*  
                    //  DUM
                    
                    Enumeration<String> param = request.getParameterNames();
                    while(param.hasMoreElements()){
                    }

                  int maxItens = Apoio.parseInt(request.getParameter("maxUsuario"));
                  
                  usuario.UsuarioVendedor usuarioV = new usuario.UsuarioVendedor();
                  
                  for (int i = 1; i <= maxItens; i++) {
                        usuarioV.getUsuario().setIdusuario(Apoio.parseInt(request.getParameter("idUsuario_" + i)));
                        usuarioV.getVendedor().setIdusuario(Apoio.parseInt(request.getParameter("idVendedor_" + i)));
                
                        cadusu.getItens().add(usuarioV);
                  }*/
                  
                  
                  if (acao.equals("incluir"))
                      cadusu.setIdfilial((adm ? Integer.parseInt(request.getParameter("idfi"))
                                          : Apoio.getUsuario(request).getFilial().getIdfilial()));

                  //setando o id do usuario...
		  if (acao.equals("atualizar"))
		     cadusu.setIdusuario(Integer.parseInt(request.getParameter("id")));

		  //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
		  //3º teste de erro naquela acao executada.
		  boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
				   ? cadusu.Inclui() : cadusu.Atualiza());
		  //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
                  %><script language="javascript" type=""><%
                  if (erro)
                  {
                     acao = (acao.equals("atualizar") ? "editar" : "iniciar");
                     %>alert('<%=(cadusu.getErros())%>');
                       window.opener.document.getElementById("salvar").disabled = false;
             	       window.opener.document.getElementById("salvar").value = "Salvar";
                 <%}else{%>
		      window.opener.document.location.replace("../consultausuario?acao=iniciar");
                  <%}%>
                      window.close();
		   </script>
	 <%}%>
  <%}else
       {%>
       <script language="javascript" type="text/javascript">
			  document.write("&nbsp; <b><br>  Aguarde, registrando usuário...");
                          document.getElementById("nom").value = window.opener.document.getElementById("nom").value;
			  document.getElementById("lo").value = window.opener.document.getElementById("lo").value;
			  document.getElementById("sh").value = window.opener.document.getElementById("sh").value;
			  document.getElementById("ema").value = window.opener.document.getElementById("ema").value;
			  document.getElementById("agencia").value = window.opener.document.getElementById("agencia").value;
			  document.getElementById("grupo").value = window.opener.document.getElementById("grupo").value;
                          document.getElementById("rod").value = window.opener.document.getElementById("rod").checked;
                          document.getElementById("aer").value = window.opener.document.getElementById("aer").checked;
                          document.getElementById("aqu").value = window.opener.document.getElementById("aqu").checked;
                          
                      <%if (adm && request.getParameter("acao2").equals("incluir"))
                          {%>
                             document.getElementById("idfi").value = window.opener.document.getElementById("idfi").value;
                        <%}%>
			  var ps = "";
			  var ni = "";
			  var i = 1;
			  while (window.opener.document.getElementById("cb"+i)!=null)
                          {
                            if ( (window.opener.document.getElementById("cb"+i) != null)
                                && (window.opener.document.getElementById("cb"+i).value != "0") )
                            {
                              ps += (ps != ""?",":"")+window.opener.document.getElementById("cb"+i).value.split(',')[0];
                              ni += (ni != ""?",":"")+window.opener.document.getElementById("cb"+i).value.split(',')[1];
                            }
                            i++;
                          }
			  document.getElementById("idps").value	= ps;
			  document.getElementById("idni").value	= ni;
			  document.frmcad.action = "./post_cadusuario.jsp?"+
                               "acao=<%=(request.getParameter("acao2").equals("atualizar")
                                         ?request.getParameter("acao2")+"&id="+request.getParameter("id")
                                         :request.getParameter("acao2"))%>";
                          document.frmcad.submit();
			</script>
	  <%}%>

