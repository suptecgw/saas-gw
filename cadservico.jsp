
<%@page import="venda.servico.ExigibilidadeISS"%>
<%@page import="usuario.BeanUsuario"%>
<%@ page language="java" contentType="text/html"
    pageEncoding="ISO-8859-1" 
    import="nucleo.Apoio, 
    		venda.Tributacao,
    		java.sql.ResultSet" %>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<% 
 BeanUsuario autenticado = Apoio.getUsuario(request);
 int nivelUser = (autenticado != null ?
                      autenticado.getAcesso("cadtipo_servico") : 0);
  
   if (autenticado == null || nivelUser == 0)
       response.sendError(HttpServletResponse.SC_FORBIDDEN);
%>

<jsp:useBean id="tipo_servico" class="venda.servico.BeanTipoServico" />
<jsp:useBean id="cadTipoServico" class="venda.servico.BeanCadServico" />

<%
  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
   ResultSet rs2 = null; 
  if (acao != null){
    //instrucoes incomuns entre as acoes
    if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar") || acao.equals("excluir")){    
        //instanciando o bean de cadastro
        cadTipoServico.setConexao(autenticado.getConexao());
        cadTipoServico.setExecutor(autenticado);
    }

    //executando a acao desejada
    if ((acao.equals("editar")) && (request.getParameter("id") != null)){
      int id = Apoio.parseInt(request.getParameter("id"));
      tipo_servico.setId(id);
      cadTipoServico.setTipoServico(tipo_servico);
      //carregando os dados do conta por completo(atributos)
      cadTipoServico.LoadAllPropertys();
    }else if (acao.equals("atualizar") || acao.equals("incluir") || acao.equals("excluir")){
                
        %><jsp:setProperty name="tipo_servico" property="*" /><%
        
        if (!acao.equals("excluir")){
            tipo_servico.getTributacao().setId(Apoio.parseInt(request.getParameter("tax_id")));
            tipo_servico.getInssTributacao().setId(Apoio.parseInt(request.getParameter("inss_tax_id")));
            tipo_servico.getPisTributacao().setId(Apoio.parseInt(request.getParameter("pis_tax_id")));
            tipo_servico.getCofinsTributacao().setId(Apoio.parseInt(request.getParameter("cofins_tax_id")));
            tipo_servico.getIrTributacao().setId(Apoio.parseInt(request.getParameter("ir_tax_id")));
            tipo_servico.getCsslTributacao().setId(Apoio.parseInt(request.getParameter("cssl_tax_id")));
            tipo_servico.getPlanoCustoPadrao().setIdconta(Apoio.parseInt(request.getParameter("idplanocusto")));
            tipo_servico.getGrupoServicoNfse().setId(Apoio.parseInt(request.getParameter("grup_id")));
            tipo_servico.setQtdCasasDecimaisQuantidade(Apoio.parseInt(request.getParameter("casasDecimaisQuantidade")));
            tipo_servico.setQtdCasasDecimaisValor(Apoio.parseInt(request.getParameter("casasDecimaisValor")));
            tipo_servico.setExigibilidadeISS(Apoio.parseInt(request.getParameter("exigibilidadeISS")));
            tipo_servico.setLogistico(Apoio.parseBoolean(request.getParameter("logistico")));
        }	
        
        if (acao.equals("atualizar"))
          tipo_servico.setId(Apoio.parseInt(request.getParameter("id")));

       cadTipoServico.setTipoServico(tipo_servico);
       
       //Verificando se vai incluir ou alterar
       
       boolean erro = false;
       if (acao.equals("incluir"))
    	   erro = !cadTipoServico.Inclui();
       if (acao.equals("atualizar"))
    	   erro = !cadTipoServico.Atualiza();
       if (acao.equals("excluir")){
    	   erro = !cadTipoServico.Deleta();
       }
 
        %><script language="javascript" type="text/javascript"><%
       if (erro)
       {
           if (cadTipoServico.getErros().indexOf("sale_services_type_service_id_fkey") > -1) {
              %>alert("Não é possível excluir esse serviço, já foi feito um lançamento para o mesmo.");
                location.replace("./consulta_servico.jsp?acao=iniciar");
                window.opener.document.getElementById("salvar").disabled = false;
                window.opener.document.getElementById("salvar").value = "Salvar";
                <%
           }else{
                acao = (acao.equals("atualizar") ? "editar" : "iniciar");
                %>alert('<%=(cadTipoServico.getErros())%>');
                window.opener.document.getElementById("salvar").disabled = false;
                window.opener.document.getElementById("salvar").value = "Salvar";
     <%}
       }else{
       
       if (Apoio.parseBoolean(request.getParameter("telaListar"))){
           %> window.document.location.href = "ConsultaControlador?codTela=51"<%
       }else if (Apoio.parseBoolean(request.getParameter("telaCadastrar"))){
           %> window.document.location.href = "ConsultaControlador?codTela=51"<%
       }else{
  %>
        
          if (window.opener != null)
      window.opener.location.href = "ConsultaControlador?codTela=51";
      window.close();
     <%}%>
       <%}%>
    </script>
<%
       
       
	}
  }

  boolean carrega_tipo = acao.equals("editar");
%>   

<html>
<head>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" >
    jQuery.noConflict();
    
    arAbasGenerico = new Array();
    arAbasGenerico[0] = new stAba('tdPrincipal','divDadosPrincipais');
    arAbasGenerico[1] = new stAba('tdNfse','divNfse');
    arAbasGenerico[2] = new stAba('tdImposto','divImposto');
    arAbasGenerico[3] = new stAba('tdAbaAuditoria','divAuditoria');
    
    function habilitaSalvar(opcao){
     $("salvar").disabled = !opcao;
     $("salvar").value = (opcao ? "Salvar" : "Enviando...");
  }

  //Quando o usuário clica em voltar
  function voltar(){
     location.replace("ConsultaControlador?codTela=51");
  }

  //Salva as informações digitadas
  function salva(acao){
    if (!wasNull('valor,descricao,iss,tax_id')){
      habilitaSalvar(false);
      if (acao == "atualizar")
         acao += "&id=<%=( tipo_servico != null ? tipo_servico.getId() : 0)%>";
      $("formulario").target="pop";
      $("formulario").action = "./cadservico.jsp?acao="+acao+"&embutirISS="+$("embutirISS").checked+"&logistico="+$("logistico").checked;

      window.open('about:blank', 'pop', 'width=210, height=100');
      $('formulario').submit();

//      Comentado por que o metodo abaixo esta em desuso, e estava dando erro!;

//      requisitaPost(concatFieldValueUnescape("valor,descricao,iss,tax_id,idplanocusto,inss,inss_tax_id,pis,pis_tax_id,grup_id,cofins,cofins_tax_id,ir,ir_tax_id,cssl,cssl_tax_id,exigibilidadeISS")
//          +"&embutirISS="+$("embutirISS").checked+"&logistico="+$("logistico").checked
//      + "&qtdCasasDecimaisQuantidade="+$("casasDecimaisQuantidade").value+ "&qtdCasasDecimaisValor="+$("casasDecimaisValor").value
//      , "./cadservico.jsp?acao="+acao);
    }else{
      alert("Informe Todos os Dados Obrigatórios Corretamente.");         
    }
  }

  function excluir(id){
       if (confirm("Deseja mesmo excluir este serviço?"))
            location.replace("./cadservico.jsp?acao=excluir&id="+id+"&telaCadastrar=true");
  }

  function localizafilial(){
      post_cad = window.open('./localiza?acao=consultar&idlista=8','Filial',
                     'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
  }
  
  function localizarGrupoServico(){
      popLocate(72, "Grupo_Servico","");
  }

  function atribuicombos(){
     <%if (carrega_tipo) {%>
       //document.getElementById("tipo_conta").value = "";
     <%}%>
  }
  
  function localizaplano(){
     var post_cad = window.open('./localiza?acao=consultar&idlista=13','planocusto',
                        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
  }
  
  function limpaPlanoCusto(){
      $("idplanocusto").value = "0";
      $("plcusto_conta").value = "";
      $("plcusto_descricao").value = "";
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
                var rotina = "type_services";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = <%=(carrega_tipo ? tipo_servico.getId() : 0)%>;
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
    
    function setDataAuditoria(){
            var data = "<%=Apoio.getDataAtual()%>";
            console.log("data : "+data);
            $("dataDeAuditoria").value="<%=carrega_tipo ? Apoio.getDataAtual() :  "" %>" ;   
            $("dataAteAuditoria").value="<%=carrega_tipo ? Apoio.getDataAtual() : "" %>" ;   

        }
         
            function habilitarAba(){
              <% if (acao.equals("editar")) { %>
                    console.log("entrou 2");
                    $("tdAbaAuditoria").style.display = "";
                <% }else{ %>
                
                    console.log("entrou 1");
                    $("tdAbaAuditoria").style.display ="none"; 
                <%}%>
            }
</script>

<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta http-equiv="content-language" content="pt">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="pragma" content="no-store">
<meta http-equiv="expires" content="0">
<link href="estilo.css" rel="stylesheet" type="text/css">

<title>Webtrans - Cadastro de Servi&ccedil;os </title>
</head>
<body onload="setDataAuditoria();AlternarAbasGenerico('tdPrincipal','divDadosPrincipais');habilitarAba()">
        <img src="img/banner.gif" >
        <br>
        <table width="60%" align="center" class="bordaFina">
            <tr>
                <td width="265"><div align="left"><b>Cadastro de Servi&ccedil;o</b></div></td>
                <% if ((acao.equals("editar")) && (nivelUser >= 4) && (request.getParameter("ex") == null))
                    {%>
                    <td width="63">
                        <input name="excluir" type="button" class="botoes" id="excluir" value="Excluir"
                               onClick="javascript:tryRequestToServer(function(){excluir(<%=(carrega_tipo ? tipo_servico.getId() : 0)%>);});">
                    </td>
                    <%}%>
                <td width="119" >
                    <input  name="bt_consultar" id="bt_consultar" type="button" class="botoes" value="Voltar para Consulta"  onClick="javascript:voltar();">
                </td>
            </tr>
        </table>
        <br>
        <form method="post" id="formulario">
               <table width="60%" align="center" class="bordaFina">
                        <tr>
                            <td class="TextoCampos">Descri&ccedil;&atilde;o:</td>
                            <td class="CelulaZebra2" colspan="2">
                                <input name="descricao" type="text" id="descricao" value="<%=tipo_servico.getDescricao()%>" size="50" maxlength="50" class="inputtexto"/>
                            </td>		
                        </tr>
                    </table>
                            <br/>
                            <table width="60%" align="center" cellpadding="2" cellspacing="1">
                                <tr>
                                    <td width="100%">
                                      <table align="left">
                                           <tr>
                                              <td id="tdPrincipal" class="menu" onclick="AlternarAbasGenerico('tdPrincipal','divDadosPrincipais')"> Dados Principais </td>
                                              
                                              <td style="display: <%=(autenticado != null && autenticado.getFilial().getStUtilizacaoNfse() != 'S' 
                                                      && autenticado.getAcesso("cadtipo_servico") >= 1) ? "" : "none"%>"
                                                  id="tdNfse" class="menu" onclick="AlternarAbasGenerico('tdNfse','divNfse')"> NFS-E </td>
                                              
                                              <td id="tdImposto" class="menu" onclick="AlternarAbasGenerico('tdImposto','divImposto')"> Imposto </td>
                                             
                                              <td style='display: <%=carrega_tipo && nivelUser == 4 ? "" : "none"%>' id="tdAbaAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>
                                              
                                           </tr>
                                        </table>
                                    </td> 
                                </tr>
                            </table>     
                  <div id="divDadosPrincipais">         
                     <table width="60%" align="center" class="bordaFina" >      
                        <tr>
                            <td class="TextoCampos">Plano de Custo Padr&atilde;o</td>
                            <td class="CelulaZebra2" colspan="2">
                                <input type="hidden" name="idplanocusto" id="idplanocusto" 
                                    value="<%=(carrega_tipo ? tipo_servico.getPlanoCustoPadrao().getIdconta() : 0)%>">
                                <input name="plcusto_conta" type="text" id="plcusto_conta" class="inputReadOnly8pt" 
                                    value="<%=(carrega_tipo ? tipo_servico.getPlanoCustoPadrao().getConta() : "")%>" size="10" maxlength="25" readonly="true"> 
                                <input name="plcusto_descricao" type="text" id="plcusto_descricao" class="inputReadOnly8pt" 
                                    value="<%=(carrega_tipo ? tipo_servico.getPlanoCustoPadrao().getDescricao() : "")%>" size="25" maxlength="25" readonly="true">
                                <input name="localiza_plano" type="button" class="botoes" id="localiza_plano" value="..." onClick="javascript:localizaplano();">
                                <img src="img/borracha.gif" border="0" class="imagemLink" onClick="limpaPlanoCusto()">
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">Valor do Servi&ccedil;o:</td>
                            <td class="CelulaZebra2" >
                                <input name="valor" type="text" id="valor" onChange="seNaoFloatReset(this,'0.00')" value="<%=Apoio.fmt(tipo_servico.getValor())%>" size="10" maxlength="12" class="inputtexto"/>
                            </td>
                            <td class="CelulaZebra2">
                                <input name="logistico" type="checkbox" id="logistico" value="<%=tipo_servico.isLogistico()%>" <%=(tipo_servico.isLogistico() ? "checked" : "")%>  class="inputtexto"/>
                                <label for="isLogistico">
                                    Servico Logistico (GWLogis)
                                </label>
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos" colspan="2">Quantidade de Casas Decimais para Quantidade</td>
                            <td class="CelulaZebra2" >
                                <select class="fieldMin" name="casasDecimaisQuantidade" id="casasDecimaisQuantidade">
                                    <option value="2" <%=(carrega_tipo && tipo_servico.getQtdCasasDecimaisQuantidade()==2 ? "selected" : "")%>>Duas</option>
                                    <option value="3" <%=(carrega_tipo && tipo_servico.getQtdCasasDecimaisQuantidade()==3 ? "selected" : "")%>>Tr&ecirc;s</option>
                                    <option value="4" <%=(carrega_tipo && tipo_servico.getQtdCasasDecimaisQuantidade()==4 ? "selected" : "")%>>Quatro</option>
                                    <option value="5" <%=(carrega_tipo && tipo_servico.getQtdCasasDecimaisQuantidade()==5 ? "selected" : "")%>>Cinco</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos" colspan="2">Quantidade de Casas Decimais para Valores</td>
                            <td class="CelulaZebra2" >
                                <select class="fieldMin" name="casasDecimaisValor" id="casasDecimaisValor">
                                    <option value="2" <%=(carrega_tipo && tipo_servico.getQtdCasasDecimaisValor()==2 ? "selected" : "")%>>Duas</option>
                                    <option value="3" <%=(carrega_tipo && tipo_servico.getQtdCasasDecimaisValor()==3 ? "selected" : "")%>>Tr&ecirc;s</option>
                                    <option value="4" <%=(carrega_tipo && tipo_servico.getQtdCasasDecimaisValor()==4 ? "selected" : "")%>>Quatro</option>
                                    <option value="5" <%=(carrega_tipo && tipo_servico.getQtdCasasDecimaisValor()==5 ? "selected" : "")%>>Cinco</option>
                                </select>
                            </td>
                        </tr>
                    </table>
                  </div>
         <div id="divNfse">                      
          <table width="60%" align="center" class="bordaFina" >                       
            <tr style="display: <%=(autenticado != null && autenticado.getFilial().getStUtilizacaoNfse() != 'S' && autenticado.getAcesso("cadtipo_servico") >= 1) ? "" : "none"%>">
                            <td class="TextoCampos">Grupo NFS-e:</td>
                            <td class="CelulaZebra2">
                                <input name="grup_desc" id="grup_desc" type="text" class="inputReadOnly" size="30" readonly value="<%=(carrega_tipo ? tipo_servico.getGrupoServicoNfse().getDescricao():"")%>" />
                                <input type="hidden" name="grup_id" id="grup_id" value="<%=(carrega_tipo ? tipo_servico.getGrupoServicoNfse().getId():"0")%>"/>
                                <input type="button" class="inputbotao"  id="botaoGrupo"  onclick="localizarGrupoServico()" value="..."/>
                                <img alt="apagar" src="img/borracha.gif" id="borracha" onclick="limparGrupo()" class="imagemLink"/>
                            </td>
                        </tr>
                    </table>
          </div>  
             
         <div id="divImposto">                    
           <table width="60%" align="center" class="bordaFina" >   
            <tr>
                <td>
                    <table width="100%" class="bordaFina">
                        <tr>
                            <td class="TextoCampos">% ISS:</td>
                            <td class="CelulaZebra2" >
                                <input name="iss" type="text" id="iss" onChange="seNaoFloatReset(this,'0.00')" value="<%=Apoio.fmt(tipo_servico.getIss())%>" size="5" maxlength="12" class="inputtexto"/>
                            </td>
                            <td class="TextoCampos">Tributa&ccedil;&atilde;o:</td>
                            <td  class="CelulaZebra2" colspan="2">
                                <select name="tax_id" id="tax_id" class="inputtexto" style="width: 70px">
                                    <% rs2 = Tributacao.all("id,descricao, codigo", Apoio.getConnectionFromUser(request));
                                    while (rs2.next()) {%>
                                        <option <%=(rs2.getInt("id") == tipo_servico.getTributacao().getId() ? "selected=true" : "")%> 
                                            value="<%=rs2.getInt("id")%>"><%=rs2.getString("codigo") + " - " + rs2.getString("descricao")%></option>
                                    <%}
                                        rs2.close();
                                    %>
                                </select>
                            </td>
                            <td class="CelulaZebra2">
                                <input name="embutirISS" type="checkbox" id="embutirISS" value="<%=tipo_servico.isEmbutirISS()%>" <%=(tipo_servico.isEmbutirISS() ? "checked" : "")%>  class="inputtexto"/>
                                <label for="embutirISS">Embutir ISS no valor do serviço</label>

                            </td>
                            <td class="TextoCampos">Exigibilidade ISS: </td>
                            <td class="CelulaZebra2">
                                <select id="exigibilidadeISS" name="exigibilidadeISS" class="inputtexto" style="width: 70px">
                                    <option value="1" <%=(carrega_tipo && tipo_servico.getExigibilidadeISS()==1 ? "selected" : "selected")%>>Exigível</option>
                                    <option value="2" <%=(carrega_tipo && tipo_servico.getExigibilidadeISS()==2 ? "selected" : "")%>>Não Incidência</option>
                                    <option value="3" <%=(carrega_tipo && tipo_servico.getExigibilidadeISS()==3 ? "selected" : "")%>>Isenção</option>
                                    <option value="4" <%=(carrega_tipo && tipo_servico.getExigibilidadeISS()==4 ? "selected" : "")%>>Exportação</option>
                                    <option value="5" <%=(carrega_tipo && tipo_servico.getExigibilidadeISS()==5 ? "selected" : "")%>>Imunidade</option>
                                    <option value="6" <%=(carrega_tipo && tipo_servico.getExigibilidadeISS()==6 ? "selected" : "")%>>Exigibilidade suspensa por decisão judicial</option>
                                    <option value="7" <%=(carrega_tipo && tipo_servico.getExigibilidadeISS()==7 ? "selected" : "")%>>Exigibilidade suspensa por por procedimento administrativo</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">% INSS:</td>
                            <td class="CelulaZebra2" >
                                <input name="inss" type="text" id="inss" onChange="seNaoFloatReset(this,'0.00')" value="<%=Apoio.fmt(tipo_servico.getInss())%>" size="5" maxlength="12" class="inputtexto"/>
                            </td>
                            <td class="TextoCampos">Tributa&ccedil;&atilde;o:</td>
                            <td  class="CelulaZebra2" colspan="2">
                                <select name="inss_tax_id" id="inss_tax_id" class="inputtexto" style="width: 70px">
                                    <% rs2 = Tributacao.allGenericos("id,descricao, codigo", Apoio.getConnectionFromUser(request));
                                    while (rs2.next()) {%>
                                        <option <%=(rs2.getInt("id") == tipo_servico.getInssTributacao().getId() ? "selected=true" : "")%> 
                                            value="<%=rs2.getInt("id")%>"><%=rs2.getString("codigo") + " - " + rs2.getString("descricao")%></option>
                                    <%}
                                        rs2.close();
                                    %>
                                </select>
                            </td>
                            <td class="CelulaZebra2" colspan="3"></td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">% PIS:</td>
                            <td class="CelulaZebra2">
                                <input name="pis" type="text" id="pis" onChange="seNaoFloatReset(this,'0.00')" value="<%=Apoio.fmt(tipo_servico.getPis())%>" size="5" maxlength="12" class="inputtexto"/>
                            </td>
                            <td class="TextoCampos">Tributa&ccedil;&atilde;o:</td>
                            <td  class="CelulaZebra2" colspan="2">
                                <select name="pis_tax_id" id="pis_tax_id" class="inputtexto" style="width: 70px">
                                    <% rs2 = Tributacao.allGenericos("id,descricao, codigo", Apoio.getConnectionFromUser(request));
                                    while (rs2.next()) {%>
                                        <option <%=(rs2.getInt("id") == tipo_servico.getPisTributacao().getId() ? "selected=true" : "")%> 
                                            value="<%=rs2.getInt("id")%>"><%=rs2.getString("codigo") + " - " + rs2.getString("descricao")%></option>
                                    <%}
                                        rs2.close();
                                    %>
                                </select>
                            </td>
                            <td class="CelulaZebra2" colspan="3"></td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">% COFINS:</td>
                            <td class="CelulaZebra2" >
                                <input name="cofins" type="text" id="cofins" onChange="seNaoFloatReset(this,'0.00')" value="<%=Apoio.fmt(tipo_servico.getCofins())%>" size="5" maxlength="12" class="inputtexto"/>
                            </td>
                            <td class="TextoCampos">Tributa&ccedil;&atilde;o:</td>
                            <td  class="CelulaZebra2" colspan="2">
                                <select name="cofins_tax_id" id="cofins_tax_id" class="inputtexto" style="width: 70px">
                                    <% rs2 = Tributacao.allGenericos("id,descricao, codigo", Apoio.getConnectionFromUser(request));
                                    while (rs2.next()) {%>
                                        <option <%=(rs2.getInt("id") == tipo_servico.getCofinsTributacao().getId() ? "selected=true" : "")%> 
                                            value="<%=rs2.getInt("id")%>"><%=rs2.getString("codigo") + " - " + rs2.getString("descricao")%></option>
                                    <%}
                                        rs2.close();
                                    %>
                                </select>
                            </td>
                            <td class="CelulaZebra2" colspan="3"></td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">% IR:</td>
                            <td class="CelulaZebra2" >
                                <input name="ir" type="text" id="ir" onChange="seNaoFloatReset(this,'0.00')" value="<%=Apoio.fmt(tipo_servico.getIr())%>" size="5" maxlength="12" class="inputtexto"/>
                            </td>
                            <td class="TextoCampos">Tributa&ccedil;&atilde;o:</td>
                            <td  class="CelulaZebra2" colspan="2">
                                <select name="ir_tax_id" id="ir_tax_id" class="inputtexto" style="width: 70px">
                                    <% rs2 = Tributacao.allGenericos("id,descricao, codigo", Apoio.getConnectionFromUser(request));
                                    while (rs2.next()) {%>
                                        <option <%=(rs2.getInt("id") == tipo_servico.getCofinsTributacao().getId() ? "selected=true" : "")%> 
                                            value="<%=rs2.getInt("id")%>"><%=rs2.getString("codigo") + " - " + rs2.getString("descricao")%></option>
                                    <%}
                                        rs2.close();
                                    %>
                                </select>
                            </td>
                            <td class="CelulaZebra2" colspan="3"></td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">% CSSL:</td>
                            <td class="CelulaZebra2" >
                                <input name="cssl" type="text" id="cssl" onChange="seNaoFloatReset(this,'0.00')" value="<%=Apoio.fmt(tipo_servico.getCssl())%>" size="5" maxlength="12" class="inputtexto"/>
                            </td>
                            <td class="TextoCampos">Tributa&ccedil;&atilde;o:</td>
                            <td  class="CelulaZebra2" colspan="2">
                                <select name="cssl_tax_id" id="cssl_tax_id" class="inputtexto" style="width: 70px">
                                    <% rs2 = Tributacao.allGenericos("id,descricao, codigo", Apoio.getConnectionFromUser(request));
                                    while (rs2.next()) {%>
                                        <option <%=(rs2.getInt("id") == tipo_servico.getCofinsTributacao().getId() ? "selected=true" : "")%> 
                                            value="<%=rs2.getInt("id")%>"><%=rs2.getString("codigo") + " - " + rs2.getString("descricao")%></option>
                                    <%}
                                        rs2.close();
                                    %>
                                </select>
                            </td>
                            <td class="CelulaZebra2" colspan="3"></td>
                        </tr>
                    </table>
                </td>
            </tr>	
          </table>
      </div>          
    </form>
                            
                <div id="divAuditoria" name="divAuditoria" style="display: " >
              
                    <table width="60%" align="center" cellpadding="2" cellspacing="1" class="bordaFina" id="tableAuditoria" style='display: <%=carrega_tipo && nivelUser == 4 ? "" : "none"%>'>
                           <%@include file="gwTrans/template_auditoria.jsp" %>
                     
                    </table>
                       
                </div>
                           <br/>
               <table width="60%" align="center" class="bordaFina" >  
                      <tr class="CelulaZebra2"> 
                        <td colspan="3">
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