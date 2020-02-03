<%@ page contentType="text/html; charset=ISO-8859-1" language="java"
   import="venda.*,
           nucleo.Apoio,
           nucleo.BeanConfiguracao,
		   nucleo.BeanLocaliza" %>
 
<% int nivelUser = (Apoio.getUsuario(request) != null ?
                      Apoio.getUsuario(request).getAcesso("cadagencia") : 0);
   //testando se a sessao eh valida e se o usuario tem acesso
   if (Apoio.getUsuario(request) == null || nivelUser == 0)
       response.sendError(response.SC_FORBIDDEN);
%>
 
<%
  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
  BeanCadAgencia cadag = new BeanCadAgencia();
  %><jsp:useBean id="ag" class="venda.BeanAgencia" /><%
  boolean carregaag = false;

  if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar") || acao.equals("excluir"))
  {
      cadag.setConexao(Apoio.getUsuario(request).getConexao());
       
      if ((acao.equals("editar")) && (request.getParameter("id") != null))
      {
	  cadag.getAg().setId(Integer.parseInt(request.getParameter("id")));
	  carregaag = cadag.LoadAllPropertys();
          ag = (carregaag? cadag.getAg() : null);
      }else
        if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir") || acao.equals("excluir")))
	    {    
             %><jsp:setProperty name="ag" property="*" /><% 
             //setando os atributos que nao podem ser setados dinamicamente(acoes: atualizar/incluir)
             if (acao.equals("atualizar") || acao.equals("incluir"))
             {
                 ag.getCidade().setIdcidade(Integer.parseInt(request.getParameter("idcidade")));
                 ag.getFilial().setIdfilial(Integer.parseInt(request.getParameter("idfilial")));
             }    
             cadag.setAg(ag);
             cadag.setExecutor(Apoio.getUsuario(request));
                          
             if (acao.equals("atualizar"))
                 cadag.Atualiza();
             else if (acao.equals("incluir") && nivelUser >= 3)
                 cadag.Inclui();
             else if (acao.equals("excluir") && nivelUser >= 4)
                 cadag.Deleta();
             response.getWriter().append("err<=>"+cadag.getErros());
             response.getWriter().close();              
       }
  }
 %>
<script language="javascript" type="">

  function voltar(){
     var goValue = parseFloat(isIE()? -2 : -1);
     if ((isIE() && history.length == 0) || (!isIE() && history.length == 1))
         parent.document.location.replace("./consulta_agencia.jsp?acao=iniciar");
     else {
         history.back(); 
         history.go(goValue); 
     }
  }

  function salva(acao){
       function ev(resp, st){
            if (st == 200)
                if (resp.split("<=>")[1] != "")
                    alert(resp.split("<=>")[1]);
                else
                    voltar();
	        else 
               alert("Status "+st+"\n\nNão conseguiu realizar o acesso ao servidor!");
			   
			document.getElementById("salvar").disabled = false;
            document.getElementById("salvar").value = "Salvar";    
       }
	 
     /*Bloco de instrucoes
     */
     if (!wasNull("descricao,abreviatura") && $("idfilial").value != 0  && $("idcidadeorigem").value != 0 )
     {
           document.getElementById("salvar").disabled = true;
           document.getElementById("salvar").value = "Enviando...";
           if (acao == "atualizar")
                acao += "&id=<%=(carregaag ? cadag.getAg().getId() : 0)%>";
            console.log("aaaaaaaaaa " + acao);
           requisitaAjax("./cadagencia.jsp?acao="+acao+"&"+concatFieldValue("descricao,abreviatura,endereco,bairro,cep,telefone,idfilial,ctrc_de,ctrc_ate")+
                                              "&idcidade="+getObj("idcidadeorigem").value, ev);
                                              
     }else
	   alert("Preencha os campos corretamente!");
  }

  function excluir(id){ 
       function ev(resp, st){
            if (st == 200)
                if (resp.split("<=>")[1] != "")
                    alert(resp.split("<=>")[1]);
                else
                    voltar();
	        else 
               alert("Status "+st+"\n\nNão conseguiu realizar o acesso ao servidor!");
       }
  
       if (confirm("Deseja mesmo excluir esta agência?"))
	       requisitaAjax("./cadagencia.jsp?acao=excluir&id="+id, ev);
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

<title>Cadastro de ag&ecirc;ncias de apoio - Webtrans</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body>
    <!-- Campos ocultos -->
    <input type="hidden" id="idfilial" value="<%=(carregaag? ag.getFilial().getIdfilial() : 0)%>">
    <input type="hidden" id="idcidadeorigem" value="<%=(carregaag? ag.getCidade().getIdcidade() : 0)%>">
    <!-- Fim -->
    <img src="img/banner.gif" >
    <br>
    <table width="70%" align="center" class="bordaFina" >
        <tr>
            <td width="613">
                <div align="left">
                    <b>Cadastro de Ag&ecirc;ncia </b>
                </div>
            </td>
            <%  //se o paramentro vier com valor entao nao pode excluir
               if ((acao.equals("editar")) && (nivelUser >= 4) && (request.getParameter("ex") == null))
            {%>
                  <td width="15">
                      <input name="excluir" type="button" class="botoes" id="excluir" value="Excluir"
                             onClick="javascript:tryRequestToServer(function(){excluir(<%=(carregaag ? ag.getId() : 0)%>);});">
                  </td>
            <%}%>
            <td width="56" >
                <input  name="Button" type="button" class="botoes" value="Voltar para Consulta" onClick="javascript:voltar();">
            </td>
        </tr>
    </table>
    <br>
    <table width="70%" height="207" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
        <tr class="tabela"> 
            <td height="20" colspan="7" >
                <div align="center">Dados Principais </div>
            </td>
        </tr>
        <tr> 
            <td width="124" class="TextoCampos" >*Nome:</td>
            <td class="CelulaZebra2" colspan="6"> 
                <input name="descricao" type="text" id="descricao" size="50" maxlength="50" 
                       value="<%=(carregaag? ag.getDescricao() : "")%>" class="inputtexto">
            </td>
        </tr>
        <tr>
            <td class="TextoCampos">*Abreviatura</td>
            <td width="134" class="CelulaZebra2">
                <input name="abreviatura" type="text" id="abreviatura" size="20" maxlength="12" 
                       value="<%=(carregaag? ag.getAbreviatura() : "")%>" class="inputtexto">
            </td>
            <td width="137" class="TextoCampos">Telefone:</td>
            <td width="78" class="CelulaZebra2">
                <input name="telefone" type="text" id="telefone" size="13" maxlength="13" value="<%=(carregaag? ag.getTelefone() : "")%>" class="inputtexto">
            </td>
            <td class="TextoCampos">*Filial:</td>
            <td class="CelulaZebra2">
                <input name="fi_abreviatura" type="text" class="inputReadOnly" id="fi_abreviatura" value="<%=(carregaag? ag.getFilial().getAbreviatura() : "")%>" size="20" readonly>
                <input name="button" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FILIAL%>','Filial')" value="...">
            </td>
        </tr>
        <tr> 
            <td class="TextoCampos">Endere&ccedil;o:</td>
            <td colspan="3" class="CelulaZebra2">
                <input name="endereco" type="text" id="endereco" size="55" maxlength="70" 
                       value="<%=(carregaag? ag.getEndereco() : "")%>" class="inputtexto">
            </td>
            <td width="59" class="TextoCampos">Bairro:</td>
            <td width="150" class="CelulaZebra2">
                <input name="bairro" type="text" id="bairro" size="25" 
                       maxlength="25" value="<%=(carregaag? ag.getBairro() : "")%>" class="inputtexto">
            </td>
        </tr>
        <tr> 
            <td class="TextoCampos">*Cidade:</td>
            <td colspan="3" class="CelulaZebra2"> 
                <input type="text" class="inputReadOnly" id="cid_origem" size="25" readonly value="<%=(carregaag? ag.getCidade().getDescricaoCidade() : "")%>"> 
                &nbsp;UF: 
                <input type="text" class="inputReadOnly" id="uf_origem" size="2" readonly value="<%=(carregaag? ag.getCidade().getUf() : "")%>"> 
                <input type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CIDADE_ORIGEM%>','Cidade')" value="...">
            </td>
            <td class="TextoCampos">Cep:</td>
            <td class="CelulaZebra2">
                <input name="cep" class="inputtexto" type="text" id="cep" size="9" maxlength="9" value="<%=(carregaag? ag.getCep() : "")%>">
            </td>
        </tr>
        <tr>
            <td class="TextoCampos">Ctrcs liberados: </td>
            <td colspan="3" class="CelulaZebra2">De 
                <input name="ctrc_de" type="text" id="ctrc_de" size="7" maxlength="6" value="<%=(carregaag? ag.getCtrc_de() : "")%>" onBlur="javascript:seNaoIntReset(this,'0');" class="inputtexto"> 
                at&eacute; 
                <input name="ctrc_ate" type="text" id="ctrc_ate" size="7" maxlength="6" value="<%=(carregaag? ag.getCtrc_ate() : "")%>" onBlur="javascript:seNaoIntReset(this,'0');" class="inputtexto">
            </td>
            <td colspan="2" class="TextoCampos">&nbsp;</td>
        </tr>
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
  </body>
</html>