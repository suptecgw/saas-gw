<%@ page contentType="text/html" language="java"
   import="cliente.faixaPeso.*,
           nucleo.Apoio" errorPage="" %>


<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadfaixa") : 0);
   boolean souadm = Apoio.getUsuario(request).getSouAdm();
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA
%>

<%

  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  boolean carregatp = false;
  CadFaixaPeso cadFx = null;
  FaixaPeso fx = null; 

  if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar"))
  {     //instanciando o bean de cadastro
        fx = new FaixaPeso();
        cadFx = new CadFaixaPeso();
        cadFx.setConexao(Apoio.getUsuario(request).getConexao());
        cadFx.setExecutor(Apoio.getUsuario(request));
  }

  //executando a acao desejada
  if ((acao.equals("editar")) && (request.getParameter("id") != null))
  {
     int id = Integer.parseInt(request.getParameter("id"));
     fx.setId(id);
     cadFx.setTp(fx);
     //carregando completo
     cadFx.LoadAllPropertys();
  }else
  if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir")))
  {
      //populando o JavaBean
      fx.setPesoInicial( Float.parseFloat(request.getParameter("de")));
      fx.setPesoFinal( Float.parseFloat(request.getParameter("ate")));
      if (acao.equals("atualizar"))
          fx.setId(Integer.parseInt(request.getParameter("id")));
      //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
      //3º teste de erro naquela acao executada.
      cadFx.setTp(fx);
      boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                      ? cadFx.Inclui() : cadFx.Atualiza());

//EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
      %><script language="javascript" type=""><%
         if (erro)
         {
             acao = (acao.equals("atualizar") ? "editar" : "iniciar");
             %>alert('<%=(cadFx.getErros())%>');
        <%}else{%>
             location.replace("./consulta_faixapeso.jsp?acao=iniciar");
        <%}%>
       </script>

 <%}
   //variavel usada para saber se o usuario esta editando
   carregatp = (cadFx != null && (!acao.equals("incluir") || !acao.equals("atualizar")));
 %>
<script language="javascript" type="text/javascript">
     jQuery.noConflict(); 
     
     arAbasGenerico = new Array();
     arAbasGenerico[0] = new stAba('tdAbaAuditoria','divAuditoria');
    
  function voltar(){
     location.replace("./consulta_faixapeso.jsp?acao=iniciar");
  }

  function salva(acao){
     if (!wasNull('de,ate'))
     {
		  $("salvar").disabled = true;
		  $("salvar").value = "Enviando...";
		  if (acao == "atualizar")
			 acao += "&id=<%=( carregatp ? cadFx.getFx().getId() : 0)%>";
  		     document.location.replace("./cadfaixapeso.jsp?acao="+acao+"&"+concatFieldValue("de,ate"));
     }else
	   alert("Preencha os campos corretamente!");
  }

  function excluir(id){
       if (confirm("Deseja mesmo excluir esta faixa de peso?"))
	   {
	       location.replace("./consulta_faixapeso.jsp?acao=excluir&id="+id);
	   }
  }
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
        var rotina = "weight_ranges";
        var dataDe = $("dataDeAuditoria").value;
        var dataAte = $("dataAteAuditoria").value;
        var id = <%=(carregatp ? cadFx.getFx().getId() : 0)%>;
        consultarLog(rotina, id, dataDe, dataAte);
        
    }
    
      function setAuditoria(){
        $("dataDeAuditoria").value="<%=carregatp ? Apoio.getDataAtual() :  "" %>" ;   
        $("dataAteAuditoria").value="<%=carregatp ? Apoio.getDataAtual() : "" %>" ;   
        
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

<title>WebTrans - Cadastro de faixas de peso</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {font-size: 10px}
-->
</style>
</head>

<body onload="setAuditoria()">
    <img src="img/banner.gif" >
    <br>
    <table width="40%" align="center" class="bordaFina" >
        <tr>
            <td width="268">
                <div align="left">
                    <b>Faixas de peso </b>
                </div>
            </td>
            <%  //se o paramentro vier com valor entao nao pode excluir
                if ((acao.equals("editar")) && (nivelUser >= 4) && (Boolean.parseBoolean(request.getParameter("ex"))))
                {%>
            <td width="63">
                <input name="excluir" type="button" class="botoes" id="excluir" value="Excluir"
                    onClick="javascript:excluir(<%=(carregatp ? cadFx.getFx().getId() : 0)%>)">
            </td>
                <%}%>
            <td width="96" >
                <input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:voltar();">
            </td>
        </tr>
    </table>
    <br>
    <table width="40%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
        <tr class="tabela">
            <td colspan="4" align="center">Dados principais</td>
        </tr>
        <tr>
            <td width="88" class="TextoCampos">*De:</td>
            <td width="114" class="CelulaZebra2">
                <input name="de" type="text" id="de" onChange="seNaoFloatReset(this,'0');" value="<%=(carregatp?cadFx.getFx().getPesoInicial(): 0)%>" size="10" maxlength="10" class="inputtexto">
                Kg
            </td>
            <td width="47" class="TextoCampos">*At&eacute;</td>
            <td width="149" class="CelulaZebra2">
                <input name="ate" type="text" id="ate" onChange="seNaoFloatReset(this,'0');" value="<%=(carregatp?cadFx.getFx().getPesoFinal() : 0)%>" size="10" maxlength="10" class="inputtexto">
                Kg
            </td>
        </tr>
        </table>  
        <table width="40%" align="center" cellpadding="2" cellspacing="1">
                <tr>
                    <td width="100%">
                        <table align="left">
                            <tr>
                                <td style='display: <%= carregatp && nivelUser == 4 ? "" : "none"%>' id="tdAbaAuditoria" name="tdAbaAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAbaAuditoria', 'divAuditoria')"> Auditoria</td>

                            </tr>
                        </table>
                    </td> 
                </tr>
         </table>
                                
                 <div  style='display: <%= carregatp && nivelUser == 4 ? "" : "none"%>' id="divAuditoria" name="divAuditoria" >
                    <table width="40%" align="center" class="bordaFina" id="tableAuditoria">
                     <%@include file = "./gwTrans/template_auditoria.jsp" %>
                    </table>
                </div> 
                    
                <br/>
                
    <table width="40%" align="center" class="bordaFina" >       
        <tr class="CelulaZebra2">
            <td colspan="6">
                <% if (nivelUser >= 2){%>
                    <center>
                        <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir":"atualizar")%>');});">
                    </center>
                <%}%>    
            </td>
        </tr>
    </table>
    <br>

