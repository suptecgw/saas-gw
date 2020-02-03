<%@ page contentType="text/html" language="java"
   import="cfop.BeanCadCfop,
           nucleo.Apoio" errorPage="" %>
<script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadcfop") : 0);
   boolean souadm = Apoio.getUsuario(request).getSouAdm();
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA
%>

<%

  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  boolean carregacfop = false;
  cfop.BeanCadCfop cadcfop = null;

  if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar"))
  {     //instanciando o bean de cadastro
        cadcfop = new BeanCadCfop();
        cadcfop.setConexao(Apoio.getUsuario(request).getConexao());
        cadcfop.setExecutor(Apoio.getUsuario(request));
  }

  //executando a acao desejada
  if ((acao.equals("editar")) && (request.getParameter("id") != null))
  {
     int idcfop = Integer.parseInt(request.getParameter("id"));
     cadcfop.setIdcfop(idcfop);
     //carregando completo
     cadcfop.LoadAllPropertys();
  }else
  if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir")))
  {
      //populando o JavaBean
      cadcfop.setCfop( request.getParameter("cfop") );
      cadcfop.setDescricao( request.getParameter("descricao"));
      cadcfop.getPlanoCusto().setIdconta(Integer.parseInt(request.getParameter("idPlanoCusto")));
      if (acao.equals("atualizar"))
          cadcfop.setIdcfop(Integer.parseInt(request.getParameter("id")));
      //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
      //3º teste de erro naquela acao executada.
      boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                      ? cadcfop.Inclui() : cadcfop.Atualiza());

//EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
      %><script language="javascript" type=""><%
         if (erro)
         {
             acao = (acao.equals("atualizar") ? "editar" : "iniciar");
             %>alert('<%=(cadcfop.getErros())%>');
        <%}else{%>
             location.replace("./consultacfop?acao=iniciar");
        <%}%>
       </script>

 <%}
   //variavel usada para saber se o usuario esta editando
   carregacfop = (cadcfop != null && (!acao.equals("incluir") || !acao.equals("atualizar")));
 %>
 
<html>
<head>
<script language="javascript" src="script/funcoes.js" type=""></script>

 
<script language="javascript" type="text/javascript">
  jQuery.noConflict();
    
    arAbasGenerico = new Array();
    arAbasGenerico[0] = stAba('tdAbaAuditoria','divAuditoria');
    
    
    function voltar(){
     location.replace("./consultacfop?acao=iniciar");
  }

  function salva(acao){
     if (!wasNull('cfop,descricao'))
     {
		  document.getElementById("salvar").disabled = true;
		  document.getElementById("salvar").value = "Enviando...";
		  if (acao == "atualizar")
			 acao += "&id=<%=( carregacfop ? cadcfop.getIdcfop() : 0)%>";
  		     document.location.replace("./cadcfop?acao="+acao+"&cfop="+document.getElementById("cfop").value+"&descricao="+document.getElementById("descricao").value+"&idPlanoCusto="+document.getElementById("idplanocusto").value);
     }else
	   alert("Preencha os campos corretamente!");
  }

  function excluir(idcfop){
       if (confirm("Deseja mesmo excluir este Cfop?"))
	   {
	       location.replace("./consultacfop?acao=excluir&id="+idcfop);
	   }
  }

    function localizaplano(){
    post_cad = window.open('./localiza?acao=consultar&idlista=13','planocusto',
    'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function limparPlano(){
        $('idplanocusto').value = 0;
        $('plcusto_conta').value = '';
        $('plcusto_descricao').value = '';
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
                var rotina = "cfop";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = $("idcfop").value;
                console.log(id);
                consultarLog(rotina, id, dataDe, dataAte);
                
    }
            
    function setDataAuditoria(){
         console.log("data : "+data);
     
        var data = "<%=Apoio.getDataAtual()%>";
        console.log("data : "+data);
        $("dataDeAuditoria").value="<%=carregacfop ? Apoio.getDataAtual() :  "" %>" ;   
        $("dataAteAuditoria").value="<%=carregacfop ? Apoio.getDataAtual() : "" %>" ;   
        
    }



</script>

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

<body  onload="setDataAuditoria();">
<img src="img/banner.gif" >
<br>
<table width="50%" align="center" class="bordaFina" >
  <tr >
    <td width="80%"><div align="left"><b>Cadastro de Código Fiscal</b></div></td>
    <%  //se o paramentro vier com valor entao nao pode excluir
        if ((acao.equals("editar")) && (nivelUser >= 4) && (Boolean.parseBoolean(request.getParameter("ex"))))
	{%>
	   <td width="15"><input name="excluir" type="button" class="botoes" id="excluir" value="Excluir"
             onClick="javascript:excluir(<%=(carregacfop ? cadcfop.getIdcfop() : 0)%>)"></td>
	<%}%>
    <td width="20%" ><input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:voltar();"></td>
  </tr>
</table>
<br>

<table width="50%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
  <tr class="tabela">
    <td colspan="2" align="center">Dados principais</td>
  </tr>
  <tr>
  
    <td class="TextoCampos">*Cfop:</td>
    <td class="CelulaZebra2"><input name="cfop" type="text" id="cfop" value="<%=(carregacfop?cadcfop.getCfop():"")%>" size="10" maxlength="5" class="inputtexto"></td>
  </tr>
  <tr>
    <td width="20%" class="TextoCampos">*Descri&ccedil;&atilde;o:</td>
    <td width="80%" class="CelulaZebra2"> <input name="descricao" type="text" id="descricao" value="<%=(carregacfop?cadcfop.getDescricao():"")%>" size="60" class="inputtexto"></td>
  </tr>
  <tr class="tabela">
    <td colspan="2" align="center">Dados padrões para lançamentos de CTRC</td>
  </tr>
  <tr>
    <td class="TextoCampos">Plano de custo:</td>
    <td class="CelulaZebra2">
        <input type="hidden" name="idplanocusto" id="idplanocusto" value="<%=(carregacfop? cadcfop.getPlanoCusto().getIdconta() : 0)%>">
        <input name="plcusto_conta" type="text" id="plcusto_conta" class="inputReadOnly" value="<%=(carregacfop ? cadcfop.getPlanoCusto().getConta() : "")%>" size="10" maxlength="25" readonly="true">
        <input name="plcusto_descricao" type="text" id="plcusto_descricao" class="inputReadOnly" value="<%=(carregacfop ? cadcfop.getPlanoCusto().getDescricao() : "")%>" size="25" maxlength="25" readonly="true">
        <input name="localiza_plano" type="button" class="botoes" id="localiza_plano" value="..." onClick="javascript:localizaplano();">
        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Plano de Custo" onClick="javascript:limparPlano();">
    </td>
  </tr>
  
</table>
    <input type="hidden" value="<%=(carregacfop ? cadcfop.getIdcfop() : 0)%>" id="idcfop" name="idcfop">
     
   
              <table align="center" width="50%" >
                 <tr>
                    <td width="100%">
                       <table align="left">
                           <tr>
                               
                               <td style='display: <%=carregacfop && nivelUser == 4 ? "" : "none"%>' id="tdAbaAuditoria" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>
                               
                              </tr>
                        </table>
                     </td> 
                   </tr>
                </table>
                             
            <table align="center"  width="50%" class="bordaFina" style='display: <%=carregacfop && nivelUser == 4 ? "" : "none"%>' >
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
<br>
</body>
</html>

