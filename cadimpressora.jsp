<%@ page contentType="text/html" language="java"
   import="nucleo.impressora.*,
           nucleo.Apoio" errorPage="" %>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes.js"></script>
<script language="JavaScript" src="script/jquery.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadimpressora") : 0);
   //testando se a sessao eh valida e se o usuario tem acesso
   if (Apoio.getUsuario(request) == null || nivelUser == 0)
       response.sendError(response.SC_FORBIDDEN);

   //fim da MSA
%>

<%
  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  boolean carregaimp = false;
  BeanCadImpressora cadimp = null;

  if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar")){     
        //instanciando o bean de cadastro
        cadimp = new BeanCadImpressora();
        cadimp.setConexao(Apoio.getUsuario(request).getConexao());
        cadimp.setExecutor(Apoio.getUsuario(request));
  }

  //executando a acao desejada
  if ((acao.equals("editar")) && (request.getParameter("id") != null)){
     int id = Apoio.parseInt(request.getParameter("id"));
     cadimp.setId(id);
     //carregando completo
     cadimp.LoadAllPropertys();
  }else if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir"))){
      //populando o JavaBean
      cadimp.setDescricao( request.getParameter("desc") );
      if (acao.equals("atualizar"))
          cadimp.setId(Apoio.parseInt(request.getParameter("id")));
      //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
      //3º teste de erro naquela acao executada.
      boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                      ? cadimp.Inclui() : cadimp.Atualiza());

      //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
      %><script language="javascript" type="text/javascript"><%
         if (erro){
             acao = (acao.equals("atualizar") ? "editar" : "iniciar");
             %>alert('<%=(cadimp.getErros())%>');
             <%//habilitando o botao salvar da pagina pai%>
             window.opener.document.getElementById("salvar").disabled = false;
             window.opener.document.getElementById("salvar").value = "Salvar";
        <%}else{%>
            if (window.opener != null)
               window.opener.document.location.replace("./consulta_impressora.jsp?acao=iniciar");
        <%}%>
        window.close();
       </script>

 <%}
   //variavel usada para saber se o usuario esta editando
   carregaimp = (cadimp != null && cadimp.getDescricao() != null);
 %>
<script language="javascript" type="text/javascript">
    jQuery.noConflict();
    
    function setAba(menu, conteudo)
    {
        this.menu = menu;
        this.conteudo = conteudo;
    }
    
    var arAbasGenerico = new Array();
    arAbasGenerico[0] = new setAba('tdAuditoria','divAuditoria');
    
    
   function AlternarAbasGenerico(menu, conteudo) {
    try {
        if (arAbasGenerico != null) {
            for (i = 0; i < arAbasGenerico.length; i++) {
                if (arAbasGenerico[i] != null && arAbasGenerico[i] != undefined) {
                    m = document.getElementById(arAbasGenerico[i].menu);
                    m.className = 'menu';
                    for (var j = 0, max = arAbasGenerico[i].conteudo.split(",").length; j < max; j++) {
                        c = document.getElementById(arAbasGenerico[i].conteudo.split(",")[j]);
                        if (c != null) {
                            invisivel(c, false);
                        } else if ($(arAbasGenerico[i].conteudo.split(",")[j].replace("div", "tr")) != null) {
                            invisivel($(arAbasGenerico[i].conteudo.split(",")[j].replace("div", "tr")), false);
                        }
                    }
                }
            }
            m = document.getElementById(menu);
            m.className = 'menu-sel';
            for (var i = 0, max = conteudo.split(",").length; i < max; i++) {
                c = document.getElementById(conteudo.split(",")[i]);
                if (c != null) {
                    visivel(c, false);
                } else if ($(conteudo.split(",")[i].replace("div", "tr")) != null) {
                    visivel($(conteudo.split(",")[i].replace("div", "tr")), false);
                }
            }
        } else {
            alert("Inicialize a variavel arAbasGenerico!");
        }
    } catch (e) {
        alert(e);
    }
}
    
    
    
    function voltar(){
     document.location.replace("./consulta_impressora.jsp?acao=iniciar");
  }

  function salva(acao){
     if (!wasNull('desc')){
        document.getElementById("salvar").disabled = true;
        document.getElementById("salvar").value = "Enviando...";
        if (acao == "atualizar")
            acao += "&id=<%=( carregaimp ? cadimp.getId() : 0)%>";
        requisitaPost("acao="+acao+"&desc="+document.getElementById("desc").value,"./cadimpressora.jsp");
     }else
        alert("Preencha os campos corretamente!");
  }

  function excluir(id){
       if (confirm("Deseja mesmo excluir esta impressora?")){
           location.replace("./consulta_impressora.jsp?acao=excluir&id="+id);
       }
  }
  
  function pesquisarAuditoria() {
    if (countLog != null && countLog != undefined) {
        for (var i = 1; i <= countLog; i++) {
            if ($("tr1Log_" + i) != null) {
                Element.remove(("tr1Log_" + i));
            }
            if ($("tr2Log_" + i) != null) {
                Element.remove(("tr2Log_" + i));
            }
        }
    }
    countLog = 0;
    var rotina = "printers";
    var dataDe = $("dataDeAuditoria").value;
    var dataAte = $("dataAteAuditoria").value;
    var id = <%=(carregaimp ? cadimp.getId() : 0)%>;
    consultarLog(rotina, id, dataDe, dataAte);
}

function setAuditoria() {
    $("dataDeAuditoria").value = "<%=carregaimp ? Apoio.getDataAtual() : ""%>";
    $("dataAteAuditoria").value = "<%=carregaimp ? Apoio.getDataAtual() : ""%>";

}
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

<title>WebTrans - Cadastro de Impressoras Matriciais</title>
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
            <td width="100%">
                <div align="left">
                    <b>Cadastro de Impressoras Matriciais</b>
                </div>
            </td>
            <%  //se o paramentro vier com valor entao nao pode excluir
                if ((acao.equals("editar")) && (nivelUser >= 4) && (request.getParameter("ex") == null)){%>
                    <td width="15">
                        <input name="excluir" type="button" class="botoes" id="excluir" value="Excluir"
                               onClick="javascript:tryRequestToServer(function(){excluir(<%=(carregaimp ? cadimp.getId() : 0)%>);});">
                    </td>
                <%}%>
            <td width="56">
                <input  name="Button" type="button" class="botoes" value="Voltar para Consulta" onClick="javascript:voltar();">
            </td>
        </tr>
    </table>
    <br>
    <br>
    <table width="40%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
        <tr class="tabela">
            <td colspan="2" align="center">Dados Principais</td>
        </tr>
        <tr>
            <td width="102" class="TextoCampos">*Descri&ccedil;&atilde;o:</td>
            <td width="308" class="CelulaZebra2"> 
                <input name="desc" type="text" id="desc" value="<%=(carregaimp?cadimp.getDescricao():"")%>" size="30" maxlength="50" class="inputtexto"></td>
        </tr>
    </table>
          <table width="40%" align="center" cellpadding="2" cellspacing="1">
                    <tr>
                        <td width="100%">
                          <table align="left">
                               <tr>
                                  <td style='display: <%=carregaimp && nivelUser ==4 ? "" : "none" %>' id="tdAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAuditoria','divAuditoria')"> Auditoria</td>
                            
                               </tr>
                            </table>
                        </td> 
                    </tr>
               </table>
                                    <div id="divAuditoria">
                                            <table colspan="3" width="40%" align="center" cellpadding="1" cellspacing="1" class="bordaFina" id="tableAuditoria"  style='display: <%=carregaimp && nivelUser ==4 ? "" : "none" %>'>
                                             <%@include file="/gwTrans/template_auditoria.jsp" %>
                                           </table>
                                 </div> 
          <br/>                        
        <table width="40%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
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