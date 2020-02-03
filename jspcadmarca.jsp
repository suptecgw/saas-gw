<%@page contentType="text/html" language="java" import="marca.BeanCadMarca" %>
<%@ page contentType="text/html" language="java" import="nucleo.Apoio" errorPage="" %>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadmarca") : 0);
   //testando se a sessao eh valida e se o usuario tem acesso
   if (Apoio.getUsuario(request) == null || nivelUser == 0)
       response.sendError(response.SC_FORBIDDEN);

   //fim da MSA
%>

<%
  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  boolean carregamarca = false;
  marca.BeanCadMarca cadmarca = null;

  if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar"))
  {     //instanciando o bean de cadastro
        cadmarca = new BeanCadMarca();
        cadmarca.setConexao(Apoio.getUsuario(request).getConexao());
        cadmarca.setExecutor(Apoio.getUsuario(request));
  }

  //executando a acao desejada
  if ((acao.equals("editar")) && (request.getParameter("id") != null))
  {
     int idmarca = Integer.parseInt(request.getParameter("id"));
     cadmarca.setIdmarca(idmarca);
     //carregando completo
     cadmarca.LoadAllPropertys();
  }else
  if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir")))
  {
      //populando o JavaBean
      cadmarca.setDescricao( request.getParameter("desc") );
      if (acao.equals("atualizar"))
          cadmarca.setIdmarca(Integer.parseInt(request.getParameter("id")));
      //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
      //3º teste de erro naquela acao executada.
      boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                      ? cadmarca.Inclui() : cadmarca.Atualiza());

      //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
      %><script language="javascript" type=""><%
         if (erro)
         {
             acao = (acao.equals("atualizar") ? "editar" : "iniciar");
             %>alert('<%=(cadmarca.getErros())%>');
             <%//habilitando o botao salvar da pagina pai%>
             window.opener.document.getElementById("salvar").disabled = false;
             window.opener.document.getElementById("salvar").value = "Salvar";
        <%}else{%>
            if (window.opener != null)
               window.opener.document.location.replace("ConsultaControlador?codTela=54");
        <%}%>
        window.close();
       </script>

 <%}
   //variavel usada para saber se o usuario esta editando
   carregamarca = (cadmarca != null && cadmarca.getDescricao() != null);
 %>
 <script language="javascript" type="text/javascript">
 jQuery.noConflict();
    
     arAbasGenerico = new Array();
     arAbasGenerico[0] = new stAba('tdAbaAuditoria','divAuditoria');
 
    function pesquisarAuditoria() {  
        if(countLog!=null  && countLog!=undefined ){
                for (var i = 1; i <= countLog; i++) {
                    if ($("tr1Log_" + i) != null) {
                        Element.remove(("tr1Log_" + i));
                    }
                    if ($("tr2Log_" + i) != null) {
                        Element.remove(("tr2Log_" + i));
                    }
                }}
                countLog = 0;
                var rotina = "marca";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = <%=(carregamarca ? cadmarca.getIdmarca() : 0)%>;
                console.log(id);
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
    
        function setDataAuditoria(){


            var data = "<%=Apoio.getDataAtual()%>";
            console.log("data : "+data);
            $("dataDeAuditoria").value="<%=carregamarca ? Apoio.getDataAtual() :  "" %>" ;   
            $("dataAteAuditoria").value="<%=carregamarca ? Apoio.getDataAtual() : "" %>" ;   

        }
     
     
 </script>
 
 <script language="javascript" type="text/javascript">
  function voltar(){ 
     document.location.replace("ConsultaControlador?codTela=54");
  }

  function salva(acao){
     if (!wasNull('desc'))
     {
                  document.getElementById("salvar").disabled = true;
                  document.getElementById("salvar").value = "Enviando...";
                    if (acao == "atualizar")
                       acao += "&id=<%=( carregamarca ? cadmarca.getIdmarca() : 0)%>";
                  requisitaPost("acao="+acao+"&desc="+document.getElementById("desc").value,"./cadmarca");
     }else
	   alert("Preencha os campos corretamente!");
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
<meta http-equiv="Content-Type" content="text/html">
<meta http-equiv="content-language" content="pt">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="pragma" content="no-store">
<meta http-equiv="expires" content="0">
<meta name="language" content="pt-br">

<title>WebTrans - Cadastro</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {font-size: 10px}
-->
</style>
</head>

<body onload="setDataAuditoria();AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')">
<img src="img/banner.gif" >
<br>
<table width="50%" align="center" class="bordaFina" >
  <tr >
    <td width="613"><div align="left"><b>Cadastro de Marca de veículo</b></div></td>
    <%  //se o paramentro vier com valor entao nao pode excluir
        if ((acao.equals("editar")) && (nivelUser >= 4) && (request.getParameter("ex") == null))
	{%>
	   <td width="15"><input name="excluir" type="button" class="botoes" id="excluir" value="Excluir"
             onClick="javascript:tryRequestToServer(function(){excluir(<%=(carregamarca ? cadmarca.getIdmarca() : 0)%>);});"></td>
	<%}%>
    <td width="56" ><input  name="Button" type="button" class="botoes" value="Voltar para Consulta" onClick="javascript:voltar();"></td>
  </tr>
</table>
<br>
        <table width="50%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
          <tr class="tabela">
                <td colspan="2" align="center">Dados principais</td>
              </tr>
              <tr>
                <td width="145" class="TextoCampos" align="center" >*Descri&ccedil;&atilde;o:</td>
                <td width="145" class="CelulaZebra2" align="center" > <input name="desc" type="text" id="desc" value="<%=(carregamarca?cadmarca.getDescricao():"")%>" size="30" maxlength="25" class="inputtexto"></td>
          </tr>
        </table>
          
 <table align="center" width="50%" >
                        <tr>
                            <td width="100%">
                                <table align="left">
                                    <tr>
                                       
                                       <td style='display: <%=carregamarca && nivelUser == 4 ? "" : "none"%>' id="tdAbaAuditoria" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>
                                              
                                    </tr>
                                </table>
                            </td> 
                        </tr>
                    </table>
         
            <table align="center"  width="50%" class="bordaFina" style='display: <%=carregamarca && nivelUser == 4 ? "" : "none"%>'>
                    <tr>
                        <td>
                                 <div id="divAuditoria" width="80%" >
                                            <table colspan="3" width="100%" align="center" cellpadding="1" cellspacing="1" class="bordaFina" id="tableAuditoria">
                                             <%@include file="/gwTrans/template_auditoria.jsp" %>
                                           </table>
                                 </div> 
                        </td>    
                    </tr>
            </table>
                                          
<br>
        <table width="50%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
            <tr class="CelulaZebra2">
            <td colspan="4">
              <% if (nivelUser >= 2){%>
                <center>
                  <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir":"atualizar")%>');});">
                </center>
                  <%}%>
                </td>
          </tr>
        </table>
                
</body>
</html>