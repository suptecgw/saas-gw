<%@ page contentType="text/html; charset=iso-8859-1" language="java"
   import="java.sql.*,
           usuario.BeanUsuario" errorPage="" %>
<%
  if (request.getSession().getAttribute("usuario") == null){
     response.sendError(response.SC_FORBIDDEN, "É preciso estar logado no sistema para ter acesso a esta página.");  
  }
%>

<%
  String acao = request.getParameter("acao");

  if ( (acao != null) && (acao.equals("gravar")) ) {
      String novasenha = request.getParameter("nova");

      HttpSession hs = request.getSession(false);
      BeanUsuario user = ((BeanUsuario)hs.getAttribute("usuario"));

      //se a senha atual estiver correta...
      if (user.getSenha().equals(request.getParameter("atual"))) {
            user.setSenha(novasenha);
            //se conseguiu alterar a senha fisicamente....
            if (user.AtualizaUsuario()){
            %>
             <script language="javascript" type="">
                alert("Sua senha foi alterada corretamente!");
                window.close();
              </script>
            <%
            }else{
              %>
              <script language="javascript" type="">
                alert("Erro ao tentar alterar sua senha!");
                window.close();
              </script>
             <%
             }
      }else {
        %>
          <script language="javascript" type="">
            alert("A senha atual não confere!");
            window.close();
          </script>
         <%
        }
  }//if (acao != null)

%>

<script language="javascript" type="">
 function check(){
	if ( document.form1.atual.value == "" ||
	     document.form1.nova.value ==  "" ||
		 document.form1.nova2.value == "" ) {
		alert("Preencha os campos corretamente!");
		return false;
	}else{
	    if (document.form1.nova.value != document.form1.nova2.value) {
		    alert('Os campos "Nova senha" e "Repetir nova senha" devem ter valores iguais!');
			return false;
		} else {
		  return true;
		  }
	}
 }

 function grava(){
    if ( check() ){
	   document.form1.submit();
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
<script src="${homePath}/assets/js/jquery-1.9.1.min.js"></script>
<link href="assets/css/bootstrap-custom-col.css" rel="stylesheet" type="text/css"/>
<meta name="viewport" content="width=device-width">
<link rel="stylesheet" href="${homePath}/assets/css/easyui.css">
<link rel="stylesheet" href="${homePath}/assets/css/consulta.css">

<!--<link href="./estilo.css" rel="stylesheet" type="text/css">-->
</head>

<body onload="javascript:document.form1.atual.focus();">
    <div>
        
    </div>
    <div style="padding: 10px;">
        <div class="dados-cadastrais">
            <div class="topo-dados">
                <label class="label-topo">Alteração de senha</label>
            </div>
            <!--<div class="container">-->
            <div class="row">
                <div class="col-md-4">
                    <label class="label-corpo ativa-helper" style="display: inline-block;width: 130px;">
                        Nome:<input type="hidden" value="Descrição: Nome do usuário cadastrado."></label>
                    <label>aaaaaaaaaaaaaaaaa</label>
                </div>
                <div class="col-md-4">
                    <label class="label-corpo ativa-helper" style="display: inline-block;width: 130px;">
                        Senha atual:<input type="hidden" value="Descrição: Login do usuário cadastrado."></label>
                    <input type="text" style="height: 25px;width: 70%;" class="input-dados">
                </div>
                <div class="col-md-4">
                    <label class="label-corpo ativa-helper" style="display: inline-block;width: 130px;">
                        Nova senha:<input type="hidden" value="Descrição: E-mail do usuário cadastrado."></label>
                    <input type="text" style="height: 25px;width: 70%;" class="input-dados">
                </div>
                <div class="col-md-4">
                    <label class="label-corpo ativa-helper" style="display: inline-block;width: 130px;">
                        Repetir Nova senha:<input type="hidden" value="Descrição: E-mail do usuário cadastrado.">
                    </label>
                    <input type="text" style="height: 25px;width: 70%;" class="input-dados">
                </div>
            </div>
            <!--</div>-->

            <div class="footer-dados"></div>

            <div style="padding-top: 10px;width: 100%;text-align: center;">
                <button id="btnSalvar" style="padding: 0;margin:0;width: 130px;"><img width="15" height="20" style="" src="${homePath}/assets/img/salvar_new.png"><label>Gravar</label></button>
                <button id="btnSalvar" style="padding: 0;margin:0;width: 130px;"><img width="15" height="20" style="" src="${homePath}/assets/img/salvar_new.png"><label>Cancelar</label></button>
            </div>

        </div>
    </div>
<form name="form1" method="post" action="./pass?acao=gravar">
  <h1>Alteração de senha</h1>
  <table width="292" border="1" align="center" cellpadding="1" cellspacing="0" class="bordaFina">
    <tr>
      <td width="151" class="TextoCampos">Senha atual</td>
      <td width="125"><input name="atual" type="password" id="atual" size="21" maxlength="13"></td>
    </tr>
    <tr>
      <td class="TextoCampos">Nova senha </td>
      <td><input name="nova" type="password" id="nova" size="21" maxlength="13"></td>
    </tr>
    <tr>
      <td class="TextoCampos">Repetir nova senha </td>
      <td><input name="nova2" type="password" id="nova2" size="21" maxlength="13"></td>
    </tr>
    <tr>
      <td colspan="2"><center>
        <input name="alterar" type="button" class="botoes" id="alterar" value="Gravar" onClick="javascript:grava();">
        &nbsp;
        <input name="cancelar" type="button" class="botoes" id="cancelar" onClick="javascript:window.close();" value="Cancelar">
      </center></td>
    </tr>
  </table>
</form>
</body>
</html>
