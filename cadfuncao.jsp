<%@ page contentType="text/html" language="java"
   import="funcao.*,
           nucleo.Apoio" errorPage="" %>


<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadfuncoes") : 0);
   boolean souadm = Apoio.getUsuario(request).getSouAdm();
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA
%>

<%

  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  boolean carregaFuncao = false;
  CadFuncao cad = null;
  Funcao fun = null;

  if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar"))
  {     //instanciando o bean de cadastro
        fun = new Funcao();
        cad = new CadFuncao();
        cad.setConexao(Apoio.getUsuario(request).getConexao());
        cad.setExecutor(Apoio.getUsuario(request));
  }

  //executando a acao desejada
  if ((acao.equals("editar")) && (request.getParameter("id") != null))
  {
     int idFun = Integer.parseInt(request.getParameter("id"));
     fun.setId(idFun);
     cad.setFun(fun);
     //carregando completo
     cad.LoadAllPropertys();
  }else
  if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir")))
  {
      //populando o JavaBean
      fun.setDescricao(request.getParameter("descricao").trim());
      if (acao.equals("atualizar"))
          fun.setId(Integer.parseInt(request.getParameter("id")));
      //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
      //3º teste de erro naquela acao executada.
      cad.setFun(fun);
      boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                      ? cad.Inclui() : cad.Atualiza());

//EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
      %><script language="javascript" type=""><%
         if (erro)
         {
             acao = (acao.equals("atualizar") ? "editar" : "iniciar");
             if(cad.getErros().indexOf("funcoes_descricao_key") > -1){
                 cad.setErros("ATENÇÃO: Função já cadastrada!");%>
                 alert('<%=(cad.getErros())%>');
             <%}else{%>
                 alert('<%=(cad.getErros())%>');
            <%}
         }else{%>
             location.replace("ConsultaControlador?codTela=36");
        <%}%>
       </script>

 <%}
   //variavel usada para saber se o usuario esta editando
   carregaFuncao = (cad != null && (!acao.equals("incluir") || !acao.equals("atualizar")));
 %>
 
 <script language="javascript" type="text/javascript">
     
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
                var rotina = "funcoes";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = <%=( carregaFuncao ? cad.getFun().getId() : 0)%>;
                console.log(id);
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
    
        function setDataAuditoria(){


            var data = "<%=Apoio.getDataAtual()%>";
            console.log("data : "+data);
            $("dataDeAuditoria").value="<%=carregaFuncao ? Apoio.getDataAtual() :  "" %>" ;   
            $("dataAteAuditoria").value="<%=carregaFuncao ? Apoio.getDataAtual() : "" %>" ;   

        }  
     
     
     
     
 </script> 
<script language="javascript" type="">

  //Em caso de alteração, o combo UF recebe o valor do BD
  //Está sendo utilizado no onload do body

  function voltar(){
     location.replace("ConsultaControlador?codTela=36");
  }

  function salva(acao){
     if (!wasNull('descricao'))
     {
		  document.getElementById("salvar").disabled = true;
		  document.getElementById("salvar").value = "Enviando...";
		  if (acao == "atualizar")
			 acao += "&id=<%=( carregaFuncao ? cad.getFun().getId() : 0)%>"; 
  		     document.location.replace("./cadfuncao.jsp?acao="+acao+"&"+concatFieldValue("descricao"));
     }else
	   alert("Preencha os campos corretamente!");
  }

  function excluir(idFun){
       if (confirm("Deseja mesmo excluir esta função?"))
	   {
	       location.replace("./consulta_funcao.jsp?acao=excluir&id="+idFun);
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

<title>WebTrans - Cadastro de fun&ccedil;&otilde;es</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {font-size: 10px}
-->
</style>
</head>

<body onload="setDataAuditoria()">
    <img src="img/banner.gif" >
    <br>
    <table width="50%" align="center" class="bordaFina" >
        <tr>
            <td width="268">
                <div align="left">
                    <b>Fun&ccedil;&otilde;es</b>
                </div>
            </td>
            <%  //se o paramentro vier com valor entao nao pode excluir
                if ((acao.equals("editar")) && (nivelUser >= 4) && (Boolean.parseBoolean(request.getParameter("ex"))))
                {%>
                    <td width="63">
                        <input name="excluir" type="button" class="botoes" id="excluir" value="Excluir"
                               onClick="javascript:excluir(<%=(carregaFuncao ? cad.getFun().getId() : 0)%>)">
                    </td>
                <%}%>
            <td width="74" >
                <input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:voltar();">
            </td>
        </tr>
    </table>
    <br>
    <table width="50%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
        <tr class="tabela">
            <td colspan="3" align="center">Dados principais</td>
        </tr>
        <tr>
            <td class="TextoCampos">*Descri&ccedil;&atilde;o:</td>
            <td colspan="2" class="CelulaZebra2">
                <input name="descricao" type="text" id="descricao" value="<%=(carregaFuncao?cad.getFun().getDescricao():"")%>" size="45" maxlength="40" class="inputtexto">
            </td>
        </tr>
        
    </table>
               
                    <table align="center" width="50%" >
                        <tr>
                            <td width="100%">
                                <table align="left">
                                    <tr>
                                        
                                       <td style='display: <%=carregaFuncao && nivelUser == 4 ? "" : "none"%>' id="tdAbaAuditoria" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>
                                      
                                    </tr>
                                </table>
                            </td> 
                        </tr>
                    </table>
               <div id="divAuditoria" >
                    
                    <table width="50%" align="center" cellpadding="2" cellspacing="1" class="bordaFina" id="tableAuditoria" style='display: <%=carregaFuncao && nivelUser == 4 ? "" : "none"%>'>
                        <tr>
                        <%@include file = "/gwTrans/template_auditoria.jsp" %>
                     
                                      
                       
                        </tr>
                    </table>
               </div>       
                       
                        <br/>
                    <table width="50%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                        <tr class="CelulaZebra2">
                            <td colspan="5">
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