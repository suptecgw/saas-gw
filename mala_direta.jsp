<%@ page contentType="text/html; charset=iso-8859-1" language="java" 
import="java.sql.*,
        nucleo.Apoio" 
errorPage="" %>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype.js" type="text/javascript"></script>

<% 
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("enviomaladireta") : 0);
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || ( nivelUser==0))
       response.sendError(HttpServletResponse.SC_FORBIDDEN);
   //fim da MSA
   
   String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
   
   if (acao.equals("carregar_clientes")){
	   BeanConsultaCliente conCli = new BeanConsultaCliente();
	   conCli.setConexao(Apoio.getUsuario(request).getConexao());
	   conCli.getCliente().setIdcliente((request.getParameter("idcliente")==null ? 0 : Integer.parseInt(request.getParameter("idcliente"))));
	   conCli.getCliente().getVendedor().setIdfornecedor((request.getParameter("idvendedor")==null ? 0 : Integer.parseInt(request.getParameter("idvendedor"))));
	   conCli.getCliente().getCidade().setIdcidade((request.getParameter("idcidade")==null ? 0 : Integer.parseInt(request.getParameter("idcidade"))));
	   conCli.getCliente().getCidade().setUf((request.getParameter("ufs")==null ? "" : request.getParameter("ufs")));
	   if (conCli.consultarMalaDireta()){
		   ResultSet rs = conCli.getResultado();
		   String resultado = "";
		   int row = 0;
     	   resultado += "<tr>";
    	   resultado += "<td colspan='4' class='tabela'><div align='center'>Enviar para</div></td>";
    	   resultado += "</tr>";
  		   resultado += "<tr class='tabela'>";
    	   resultado += "<td width='6%'></td>";
   	 	   resultado += "<td width='43%'>Cliente</td>";
   	 	   resultado += "<td width='37%'><input type='button' value='Exportar e-mails' class='botoes' onClick='exportarEmail();'/></td>";
   	 	   resultado += "<td width='14%'></td>";
  		   resultado += "</tr>";
  		   boolean isOk = false;
		   while (rs.next()){
			    isOk = !rs.getString("email").equals("");
			    resultado += "<tr class="+((row % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")+">";
	   	   		resultado += "<td><input type='checkbox' id='chk"+row+"' name='chk"+row+"' value='"+rs.getString("idcliente")+"' "+(isOk ? "checked" : "")+"></td>";
	   	   		resultado += "<td colspan='2'>"+rs.getString("razaosocial");
	   	   		resultado += "<input type='hidden' id='mail"+rs.getString("idcliente")+"' id='mail"+rs.getString("idcliente")+"' value='"+rs.getString("email")+"'></td>";
	   	   		if (isOk){
		   	   		resultado += "<td align='center'>OK</td>";
	   	   		}else{
		   	   		resultado += "<td align='center'>Não OK</td>";
	   	   		}
	   	   		resultado += "</tr>";
	   	   		row++;
		   }
	       response.getWriter().append(resultado); 
	   }else{
	       response.getWriter().append("load=0"); 
	   }    
	   response.getWriter().close();
   }else if(acao.equals("enviar_email")){
   	   //Enviando e-mail para os clientes
       EnviaEmail m = new EnviaEmail();
       m.setCon(Apoio.getUsuario(request).getConexao());
       m.carregaCfg();
       BeanConsultaCliente cl = new BeanConsultaCliente();
       cl.setConexao(Apoio.getUsuario(request).getConexao());
       
       cl.consultarClienteEmail(request.getParameter("ids").replace(";",","));
       ResultSet rsCl = cl.getResultado();
       String msg = "";
       String msgErro = "";
       boolean deuCerto = true;
       
       while (rsCl.next()){
	       	m.setAssunto(request.getParameter("assuntoMsg"));
    		m.setMensagem(request.getParameter("mensagemMsg"));
    		m.setPara(rsCl.getString("email"));
        	deuCerto = m.EnviarEmail();
            if (!deuCerto){
            	msgErro += "Ocorreu o seguinte erro ao enviar e-mail: " + m.getErro() + "\\n" +
            	           "Cliente: " + rsCl.getString("razaosocial") + "\\n"+
            	           "Email: " + rsCl.getString("email") + "\\n";
            }
       }
       rsCl.close();
	   String  scr = "<script>";
	   if (!msgErro.equals("")){
		   scr += "alert('"+msgErro+"');";
	   }
	   scr += "window.close();"+
	          "</script>";
       response.getWriter().append(scr);
       response.getWriter().close();

   }
   
%>   
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<script>
  function localizacliente(){
     	post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=5','Cliente',
                        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
  }
  function localizacidade(){
     	post_cad = window.open('./localiza?acao=consultar&idlista=12','Cidade_destino',
                        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
  }
  function limparclifor(){
    document.getElementById("idconsignatario").value = "0";
    document.getElementById("con_rzs").value = "";
  }
  function limparcidade(){
    document.getElementById("idcidadedestino").value = "0";
    document.getElementById("cid_destino").value = "";
    document.getElementById("uf_destino").value = "";
  }
  function viewCliente(idcarta){
      if ($('idconsignatario').value == '0' && $('idcidadedestino').value == '0' && $('ufs').value == '' && $('idvendedor').value == '0'){
          alert('Escolha, no mínimo, um filtro!');
      }else{
	      function e(transport)
	  	  {
	  	  	var textoresposta = transport.responseText;
		    //se deu algum erro na requisicao...
	        if (textoresposta == "load=0") {
		  	   espereEnviar("",false);
 			   return false;
		    }else{
		       Element.update(document.getElementById("tb_cliente"),textoresposta);
		       espereEnviar("",false);
		    }
          }//funcao e()
	      espereEnviar("",true);
          new Ajax.Request("./mala_direta.jsp?acao=carregar_clientes&idcliente="+$('idconsignatario').value+"&idvendedor="+$('idvendedor').value+
	                   "&idcidade="+$('idcidadedestino').value+"&ufs="+$('ufs').value,{method:'post', onSuccess: e, onError: e});
      }
  }
  
  function getClientes(){
    var emails = '';
    var ids = ''; 
    var linha = '';
  	for (x=0; x<=10000; x++){
  	   if ($('chk'+x) == null){
  	   	  break;
  	   }else{
  	      if ($('chk'+x).checked){
  	        linha = $('chk'+x).value;
  	        ids+=(ids == '' ? '' : ';')+linha;
  	        emails+=(emails == '' ? '' : ';')+$('mail'+linha).value;
            }	
  	  }
  	}   
  	return ids;
  }

  function exportarEmail(){
    var emails = '';
    var linha = '';
  	for (x=0; x<=10000; x++){
  	   if ($('chk'+x) == null){
  	   	  break;
  	   }else{
  	      if ($('chk'+x).checked){
  	        linha = $('chk'+x).value;
  	        emails+=(emails == '' ? '' : ';')+$('mail'+linha).value;
          }
       }
    }
  	$('mensagem').value = emails;
  	alert('Todos os e-mails encontram-se no campo mensagem, favor copiar e colar onde desejar.');
  }
  
  function enviar(){
     if ($('assunto').value == ''){
	 	alert('Digite o Assunto corretamente!');
	 }else if ($('mensagem').value == ''){
	 	alert('Digite a mensagem corretamente!');
	 }else{
	     var mensagem = $('mensagem').value.replace(/\n/g,'<br>');
         $('formEmail').action = "./mala_direta.jsp?acao=enviar_email&ids="+getClientes()+"&assuntoMsg="+
                                 $('assunto').value+"&mensagemMsg="+mensagem;
         submitPopupForm($('formEmail'));
	 }
  }
  
  function addImagem(){
      $('mensagem').value += '<img>'+$('imagem').value+'<fim_img>';
  }
</script>  
<%@page import="nucleo.Apoio"%>
<%@page import="cliente.BeanCliente"%>
<%@page import="cliente.BeanConsultaCliente"%>
<%@page import="nucleo.EnviaEmail"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Envio de mala-direta para clientes</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {
	font-size: 14px;
	font-weight: bold;
}
.style2 {
	font-size: 12px;
	font-weight: bold;
}
.style3 {
	font-size: 12px;
	color: #0000FF;
}
.style4 {color: #000000}
.style6 {font-size: 12px}
-->
</style>
</head>

<body>
<div align="center"><img src="img/banner.gif" alt="banner"> <br>
  <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
  <input type="hidden" name="idvendedor" id="idvendedor" value="0">
  <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="0">
</div>
<table width="90%" height="28" align="center" class="bordaFina" >
  <tr> 
    <td height="22"><div align="left" class="style1">Envio de mala-direta para clientes</div></td>
  </tr>
</table>
<br>
<table width="90%"  border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
  <tr>
    <td colspan="6" class="tabela"><div align="center">Filtros</div></td>
  </tr>
  <tr>
    <td width="13%" class="TextoCampos">Apenas o cliente: </td>
    <td width="31%" class="CelulaZebra2"><strong>
      <input name="con_rzs" type="text" id="con_rzs" value="" size="30" maxlength="80" readonly="true" class="inputReadOnly">
      <input name="localiza_clifor" type="button" class="botoes" id="localiza_clifor" value="..." onClick="javascript:localizacliente();">
      <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cliente" onClick="javascript:limparclifor();"></strong></td>
    <td width="12%" class="TextoCampos">Apenas a cidade: </td>
    <td width="27%" class="CelulaZebra2"><input name="cid_destino" type="text" class="inputReadOnly" id="cid_destino" size="19" value="" readonly="true">
      <input name="uf_destino" type="text" class="inputReadOnly" id="uf_destino" size="1" value="" readonly="true">
      <input type="button" class="botoes" 
	         onClick="javascript:localizacidade();" value="...">
    <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cidade" onClick="javascript:limparcidade();"></strong></td>
    <td width="11%" class="TextoCampos">Apenas a UF: </td>
    <td width="6%" class="CelulaZebra2">
      <input name="ufs" type="text" id="ufs" size="5" value="">
	</td>
  </tr>
  <tr>
    <td class="TextoCampos">Apenas o vendedor: </td>
    <td class="CelulaZebra2"><input name="ven_rzs" type="text" id="ven_rzs" size="30" readonly class="inputReadOnly">
      <strong>
      <input name="localiza_vendedor" type="button" class="botoes" id="localiza_vendedor" value="..." 
		         onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=27&paramaux=1', 'Vendedor')">
      <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="$('ven_rzs').value = '';$('idvendedor').value=0;"></strong></td>
    <td class="CelulaZebra2">&nbsp;</td>
    <td class="CelulaZebra2">&nbsp;</td>
    <td class="CelulaZebra2">&nbsp;</td>
    <td class="CelulaZebra2">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="6" class="CelulaZebra2"><div align="center">
      <input name="visualizar" type="button" class="botoes" id="visualizar" value="Visualizar" onClick="javascript:tryRequestToServer(function(){viewCliente();});">
    </div></td>
  </tr>
</table>
<br>
<table width="90%"  border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
  <tr>
    <td colspan="2" class="tabela"><div align="center">Digita&ccedil;&atilde;o do e-mail </div></td>
  </tr>
  <tr>
    <td width="50%" style="vertical-align:top;" class="CelulaZebra2"><table width="100%"  border="0" cellspacing="1" cellpadding="2">
      <form method="post" id="formEmail">
      <tr>
        <td width="17%" class="TextoCampos">Assunto:</td>
        <td width="83%" class="CelulaZebra2"><span class="CelulaZebra2"><strong>
          <input name="assunto" type="text" id="assunto" value="" size="53" maxlength="150">
        </strong></span></td>
      </tr>
      <tr class="CelulaZebra2">
        <td colspan="2"><strong>
          <textarea name="mensagem" cols="50" rows="25" id="mensagem"></textarea>
        </strong></td>
        </tr>
      </form>
      <tr class="CelulaZebra2" style="display:none;">
        <td colspan="2"><div align="left">
          <input name="imagem" type="file" size="50">
          <input name="adicionarImagem" type="button" value="Adicionar Imagem" onclick="addImagem();" class="botoes">
        </div></td>
      </tr>
      <tr class="CelulaZebra2">
        <td colspan="2"><div align="center">
          <input name="enviar" type="button" class="botoes" id="enviar" value="Enviar" onClick="javascript:tryRequestToServer(function(){enviar();});">
        </div></td>
      </tr>
      <tr>
        <td colspan="2">
           <span class="style2">Como adicionar imagens ao corpo da mensagem:</span><br>
              <span class="style3"><span class="style4">Para fazer isso o usuário deverá informar a url da imagem, ou seja, onde a imagem está hospedada, Exemplo de digita&ccedil;&atilde;o de e-mail:</span><br>
              <br>
              Bom dia Sr. Ant&ocirc;nio,<br>
              Segue abaixo a nossa nova tabela de preço, favor analisá-la.<br>
		   &lt;img&gt;http://meuftp/img/novatabela.jpg&lt;fim_img&gt;<br>
		   Qualquer dúvida estaremos a disposição.</span>	<br><br>
		   <span class="style6">Veja que estamos utilizando o comando &lt;img&gt;
		   para informarmos que queremos adicionar uma imagem naquele local, ap&oacute;s o &lt;img&gt; deveremos digitar a url que encontra-se a imagem e para encerrar informamos &lt;fim_img&gt;.</span></td> 
      </tr> 
    </table></td>
    <td width="50%" style="vertical-align:top;" class="CelulaZebra2" >
	<table width="100%"  border="0" cellspacing="1" cellpadding="2">
	  <tbody id="tb_cliente">
	  </tbody>
    </table></td>
  </tr>
</table>
<br>

</body>
</html>
