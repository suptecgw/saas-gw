<%@ page contentType="text/html" language="java"
   import="historico.BeanCadHistorico,
           nucleo.Apoio" errorPage="" %>
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
                    ? Apoio.getUsuario(request).getAcesso("cadhist") : 0);
   boolean souadm = Apoio.getUsuario(request).getSouAdm();
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA
%>

<%

  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  boolean carregahist = false;
  historico.BeanCadHistorico cadhist = null;

  cadhist = new BeanCadHistorico();
  cadhist.setConexao(Apoio.getUsuario(request).getConexao());
  cadhist.setExecutor(Apoio.getUsuario(request));

  //executando a acao desejada
  if ((acao.equals("editar")) && (request.getParameter("id") != null))
  {
     int idhist = Integer.parseInt(request.getParameter("id"));
     cadhist.setIdhist(idhist);
     //carregando completo
     cadhist.LoadAllPropertys();
  }else
  if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir")))
  {
      //populando o JavaBean
      cadhist.setDeschist( request.getParameter("desc") );
      cadhist.setCodigo_historico( request.getParameter("codigo_historico") );
      if (acao.equals("atualizar"))
          cadhist.setIdhist(Integer.parseInt(request.getParameter("id")));
      //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
      //3º teste de erro naquela acao executada.
      boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                      ? cadhist.Inclui() : cadhist.Atualiza());

//EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
      %><script language="javascript" type="">
          <%
         if (erro)
         {%>
             if(<%=cadhist.getErros().indexOf("un_codigo") > -1%>){
                 alert("Já existe um Código "+<%=(request.getParameter("codigo_historico"))%>+ " cadastrado para o HISTÓRICO");
             }else if (<%=cadhist.getErros().indexOf("historico_deschist_key") > -1%>) {
                 alert("Já existe a Descrição "+'<%=cadhist.getDeschist()%>'+ " cadastrada para um HISTÓRICO");
             }else{
             <%
             acao = (acao.equals("atualizar") ? "editar" : "iniciar");
             %>
                 alert('<%=(cadhist.getErros())%>');
             }
        <%}else{%>
             location.replace("ConsultaControlador?codTela=15");
        <%}%>
       </script>

 <%}
   //variavel usada para saber se o usuario esta editando
   carregahist = (!acao.equals("iniciar") && (!acao.equals("incluir") || !acao.equals("atualizar")));
 %>
<script language="javascript" type="text/javascript">
    jQuery.noConflict();
    
    arAbasGenerico = new Array();
    arAbasGenerico[0] = stAba('tdAbaAuditoria','divAuditoria');
    
    function voltar(){
     location.replace("ConsultaControlador?codTela=15");
  }

  function salva(acao){
     if (!wasNull('desc,codigo_historico'))
     {
		  document.getElementById("salvar").disabled = true;
		  document.getElementById("salvar").value = "Enviando...";
		  if (acao == "atualizar")
			 acao += "&id=<%=( carregahist ? cadhist.getIdhist() : 0)%>";
		  document.location.replace("./cadhistorico?acao="+acao+"&desc="+$("desc").value+"&codigo_historico="+$("codigo_historico").value);
     }else
	   alert("Preencha os campos corretamente!");
  }

  function excluir(idhist){
       if (confirm("Deseja mesmo excluir este histórico?"))
	   {
	       location.replace("./consultahistorico?acao=excluir&id="+idhist);
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
                var rotina = "historico";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = <%=(carregahist ? cadhist.getIdhist(): 0)%>;
                console.log(id);
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
    
    function setDataAuditoria(){
           
            $("dataDeAuditoria").value="<%=carregahist? Apoio.getDataAtual() :  "" %>" ;   
            $("dataAteAuditoria").value="<%=carregahist ? Apoio.getDataAtual() : "" %>" ;   

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

        <title>WebTrans - Cadastro</title>
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
        <table width="40%" align="center" class="bordaFina" >
            <tr >
                <td width="613"><div align="left"><b>Cadastro de Histórico para lançamentos</b></div></td>
                <%  //se o paramentro vier com valor entao nao pode excluir
        if ((acao.equals("editar")) && (nivelUser >= 4) && (request.getParameter("ex") == null)) {%>
                <td width="15"><input name="excluir" type="button" class="botoes" id="excluir" value="Excluir"
                                      onClick="javascript:excluir(<%=(carregahist ? cadhist.getIdhist() : 0)%>)"></td>
                    <%}%>
                <td width="56" ><input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:voltar();"></td>
            </tr>
        </table>
        <br>
        <table width="40%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
            <tr class="tabela">
                <td colspan="2" align="center">Dados principais</td>
            </tr>
            <tr>
                <td class="TextoCampos">*C&oacute;digo:</td>
                <td class="CelulaZebra2"><input name="codigo_historico" type="text" id="codigo_historico" onBlur="javascript:seNaoIntReset(this,'0');" value="<%=(carregahist ? cadhist.getCodigo_historico() : cadhist.getProximoCodigo())%>" size="5" class="inputtexto"></td>
            </tr>
            <tr>
                <td width="64" class="TextoCampos">*Descri&ccedil;&atilde;o:</td>
                <td width="502" class="CelulaZebra2"> <textarea name="desc" cols="55" id="desc" class="inputtexto"><%=(carregahist ? cadhist.getDeschist() : "")%></textarea></td>
            </tr>
        </table>
        <table align="center" width="40%" >
            <tr>
                <td width="100%">
                    <table align="left">
                        <tr>
                            <td style='display:<%= carregahist && nivelUser == 4 ? "" : "none"%>' id="tdAbaAuditoria" name="tdAbaAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>
                        </tr>
                    </table>
                </td> 
            </tr>
        </table>
        <div id="divAuditoria" >

            <table width="40%" align="center" cellpadding="2" cellspacing="1" class="bordaFina" id="tableAuditoria" style='display: <%=carregahist && nivelUser == 4 ? "" : "none"%>'>
                <%@include file="/gwTrans/template_auditoria.jsp" %>

            </table>
        </div>

        <br>
        <table width="40%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
            <tr class="CelulaZebra2">
                <td colspan="4">
                    <% if (nivelUser >= 2) {%>
            <center>
                <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>');});">
            </center>
            <%}%>
        </td>
    </tr>
</table>

<br>
</body>
</html>
