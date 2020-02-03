<%@ page contentType="text/html" language="java"
   import="conhecimento.coleta.terminal.*,
           nucleo.Apoio" errorPage="" %>

  <script language="javascript" type="text/javascript" src="script/builder.js"></script>
  <script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
  <script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
  <script language="javascript" type="text/javascript" src="script/jquery.js"></script>
  <script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>

<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadterminal") : 0);
   boolean souadm = Apoio.getUsuario(request).getSouAdm();
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA
%>

<%

  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  boolean carregaTerminal = false;
  CadTerminal cad = null;
  Terminal nv = null;

  if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar"))
  {     //instanciando o bean de cadastro
        nv = new Terminal();
        cad = new CadTerminal();
        cad.setConexao(Apoio.getUsuario(request).getConexao());
        cad.setExecutor(Apoio.getUsuario(request));
  }

  //executando a acao desejada
  if ((acao.equals("editar")) && (request.getParameter("id") != null))
  {
     int idNv = Integer.parseInt(request.getParameter("id"));
     nv.setId(idNv);
     cad.setTm(nv);
     //carregando completo
     cad.LoadAllPropertys();
  }else
  if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir")))
  {
      //populando o JavaBean
      nv.setDescricao( request.getParameter("descricao") );
      if (acao.equals("atualizar"))
          nv.setId(Integer.parseInt(request.getParameter("id")));
      //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
      //3º teste de erro naquela acao executada.
      cad.setTm(nv);
      boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                      ? cad.Inclui() : cad.Atualiza());

//EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
      %><script language="javascript" type=""><%
         if (erro)
         {
             acao = (acao.equals("atualizar") ? "editar" : "iniciar");
             %>alert('<%=(cad.getErros())%>');
        <%}else{%>
             location.replace("ConsultaControlador?codTela=41");
        <%}%>
       </script>

 <%}
   //variavel usada para saber se o usuario esta editando
   carregaTerminal = (cad != null && (!acao.equals("incluir") || !acao.equals("atualizar")));
 %>
 
 <script language='javascript' type="text/javascript"> 
    jQuery.noConflict();
 
    arAbasGenerico = new Array();
    arAbasGenerico[0] = stAba('tdAbaAuditoria','divAuditoria');
    
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
                var rotina = "terminal_container";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = <%=( carregaTerminal ? cad.getTm().getId() : 0)%>;
                console.log(id);
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
            
     function setDataAuditoria(){
        
     
        var data = "<%=Apoio.getDataAtual()%>";
        console.log("data : "+data);
        $("dataDeAuditoria").value="<%=carregaTerminal ? Apoio.getDataAtual() :  "" %>" ;   
        $("dataAteAuditoria").value="<%=carregaTerminal ? Apoio.getDataAtual() : "" %>" ;   
        
    } 
 
 
 
 </script>
<script language="javascript" type="">

  //Em caso de alteração, o combo UF recebe o valor do BD
  //Está sendo utilizado no onload do body

  function voltar(){
     location.replace("ConsultaControlador?codTela=41");
  } 

  function salva(acao){
     if (!wasNull('descricao')){
		  document.getElementById("salvar").disabled = true;
		  document.getElementById("salvar").value = "Enviando...";
		  if (acao == "atualizar")
			 acao += "&id=<%=( carregaTerminal ? cad.getTm().getId() : 0)%>";
  		     document.location.replace("./cadterminal.jsp?acao="+acao+"&"+concatFieldValue("descricao"));
     }else
	   alert("Preencha os campos corretamente!");
  }

  function excluir(idNv){
       if (confirm("Deseja mesmo excluir este navio?"))
	   {
	       location.replace("./consulta_terminal.jsp?acao=excluir&id="+idNv);
	   }
  }
</script>
<html>
<head>
<script language="javascript" src="script/funcoes.js" type=""></script>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="pt">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="pragma" content="no-store">
<meta http-equiv="expires" content="0">
<meta name="language" content="pt-br">

<title>WebTrans - Cadastro de Terminal</title>
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
    <td width="268"><div align="left"><b>Terminal</b></div></td>
    <%  //se o paramentro vier com valor entao nao pode excluir
        if ((acao.equals("editar")) && (nivelUser >= 4) && (Boolean.parseBoolean(request.getParameter("ex"))))
	{%>
    <td width="63"><input name="excluir" type="button" class="botoes" id="excluir" value="Excluir"
             onClick="javascript:excluir(<%=(carregaTerminal ? cad.getTm().getId() : 0)%>)"></td>
	<%}%>
    <td width="74" ><input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:voltar();"></td>
  </tr>
</table>
<br>
<table width="50%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
  <tr class="tabela">
    <td colspan="3" align="center">Dados principais</td>
  </tr>
  <tr>
    <td class="TextoCampos">*Descrição:</td>
    <td colspan="2" class="CelulaZebra2"><input name="descricao" type="text" id="descricao" value="<%=(carregaTerminal?cad.getTm().getDescricao():"")%>" size="45" maxlength="30" class="inputtexto"></td>
  </tr>
</table>
  
        <table align="center" width="50%" >
                        <tr>
                            <td width="100%">
                                <table align="left">
                                    <tr>
                                       
                                       <td style='display: <%=carregaTerminal && nivelUser == 4 ? "" : "none"%>' id="tdAbaAuditoria" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>
                                      
                                    </tr>
                                </table>
                            </td> 
                        </tr>
                    </table>
                    
                    <table style='display: <%=carregaTerminal && nivelUser == 4 ? "" : "none"%>' align="center"  width="50%" class="bordaFina" >
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
                    <br/>        
                        <% if (nivelUser >= 2){%>
                    <table class="bordaFina" width="50%" align="center">
                                  <tr class="CelulaZebra2">
                                    <td colspan="5">
                                     
                                            <center>
                                          <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir":"atualizar")%>');});">
                                        </center>
                                          <%}%>    </td>
                                  </tr>
                            </table>  
</body>
</html>
