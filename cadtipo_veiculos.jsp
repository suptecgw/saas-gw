<%@page import="br.com.gwsistemas.cfe.repom.TipoVeiculoRepom"%>
<%@page import="br.com.gwsistemas.cfe.repom.TipoVeiculoRepomBO"%>
<%@page import="br.com.gwsistemas.cfe.expers.TipoVeiculoExpeRS"%>
<%@page import="br.com.gwsistemas.cfe.expers.TipoVeiculoExpeRSBO"%>
<%@page import="conhecimento.manifesto.gerenciandorrisco.TipoVeiculoBO"%>
<%@page import="conhecimento.manifesto.gerenciandorrisco.TipoVeiculo"%>
<%@ page contentType="text/html" language="java"
   import="tipo_veiculos.Tipo_veiculos,
           tipo_veiculos.CadTipo_veiculos,
           tipo_veiculos.TipoCarroceriaCte,
           tipo_veiculos.TipoVeiculoCte,
           nucleo.Apoio" errorPage="" %>

  <script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadtipoveiculo") : 0);
   boolean souadm = Apoio.getUsuario(request).getSouAdm();
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA
%>

<%

  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  boolean carregatipo = false;
  CadTipo_veiculos cadtipo = null;
  Tipo_veiculos tipo = null; 

  if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar"))
  {     //instanciando o bean de cadastro
        tipo = new Tipo_veiculos();
        cadtipo = new CadTipo_veiculos();
        cadtipo.setConexao(Apoio.getUsuario(request).getConexao());
        cadtipo.setExecutor(Apoio.getUsuario(request));
  }

  //executando a acao desejada
  if ((acao.equals("editar")) && (request.getParameter("id") != null))
  {
     int idtipo = Integer.parseInt(request.getParameter("id"));
     tipo.setId(idtipo);
     cadtipo.setTPV(tipo);
     //carregando completo
     cadtipo.LoadAllPropertys();
  }else
  if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir")))
  {
      //populando o JavaBean
      tipo.setDescricao( request.getParameter("descricao") );
      tipo.setIscarreta( Boolean.parseBoolean(request.getParameter("iscarreta")));
      tipo.setIstabelado( Boolean.parseBoolean(request.getParameter("istabelado")));
      if(!tipo.getIscarreta()){
          tipo.setObrigaCarreta(Boolean.parseBoolean(request.getParameter("isObrigaCarreta")));
      }
      tipo.getTipoPamcary().setId(Integer.parseInt(request.getParameter("tipoPamcary")));
      tipo.getTipoCarroceriaCte().setId(Integer.parseInt(request.getParameter("tipoCarroceriaCte")));
      tipo.getTipoVeiculoCte().setId(Integer.parseInt(request.getParameter("tipoVeiculoCte")));
      tipo.setQtdEixos(Apoio.parseInt(request.getParameter("qtdEixos")));
      tipo.getTipoVeiculoGerenciador().setCodigo(request.getParameter("tipoVeiculoGerenciador"));
      tipo.getTipoVeiculoGerenciadorExpeRS().setCodigo(request.getParameter("tipoVeiculoExpeRS"));
      tipo.getTipoVeiculoRepom().setCodigo(request.getParameter("tipoVeiculoRepom"));
      if (acao.equals("atualizar")){
          tipo.setId(Integer.parseInt(request.getParameter("id")));
    	  }
      //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
      //3º teste de erro naquela acao executada.
      cadtipo.setTPV(tipo);
      boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                      ? cadtipo.Inclui() : cadtipo.Atualiza());

//EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
      %><script language="javascript" type=""><%
         if (erro)
         {
             acao = (acao.equals("atualizar") ? "editar" : "iniciar");
             %>alert('<%=(cadtipo.getErros())%>');
        <%}else{%>
             location.replace("ConsultaControlador?codTela=53");
        <%}%>
       </script>

 <%}
   //variavel usada para saber se o usuario esta editando
   carregatipo = (cadtipo != null && (!acao.equals("incluir") || !acao.equals("atualizar")));
 %>
 <script language="javascript" type="text/javascript">

  //Em caso de alteração, o combo UF recebe o valor do BD
  //Está sendo utilizado no onload do body
  


    jQuery.noConflict(); 
     
     arAbasGenerico = new Array();
     arAbasGenerico[0] = new stAba('tdPrincipal','divInformacoes');
     arAbasGenerico[1] = new stAba('tdAbaAuditoria','divAuditoria');

  function voltar(){
     location.replace("ConsultaControlador?codTela=53");
  }

  function showObrigaCarreta(){
      if($("iscarreta").checked){
          invisivel($("trObrigaCarreta"));
      }else{
          visivel($("trObrigaCarreta"));
      }
  }

  function salva(acao){
     if (!wasNull('descricao')){
		  document.getElementById("salvar").disabled = true;
		  document.getElementById("salvar").value = "Enviando...";
		  if (acao == "atualizar")
			 acao += "&id=<%=( carregatipo ? cadtipo.getTpv().getId() : 0)%>";
  		     document.location.replace("./cadtipo_veiculos.jsp?acao="+acao+"&"+
                         concatFieldValue("descricao,tipoPamcary,tipoVeiculoCte,tipoCarroceriaCte")+
                         '&iscarreta='+getObj('iscarreta').checked +'&istabelado='+getObj('istabelado').checked+
                         "&isObrigaCarreta="+getObj('isObrigaCarreta').checked +
                         "&qtdEixos=" +$("qtdEixos").value+ "&tipoVeiculoGerenciador="+$("tipoVeiculoGerenciador").value
                           +"&tipoVeiculoExpeRS="+$("tipoVeiculoExpeRS").value
                         +"&tipoVeiculoRepom="+$("tipoVeiculoRepom").value);
     }else{
	   alert("Preencha os campos corretamente!");
     }
  }

  function excluir(idtipo){
       if (confirm("Deseja mesmo excluir este tipo de veículo?"))
	   {
	       location.replace("./consulta_tipo_veiculos.jsp?acao=excluir&id="+idtipo);
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
                var rotina = "tipo_veiculos";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = <%=(carregatipo ? cadtipo.getTpv().getId() : 0)%>;
                console.log(id);
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
    
    function setDataAuditoria(){
            $("dataDeAuditoria").value="<%=carregatipo ? Apoio.getDataAtual() :  "" %>" ;   
            $("dataAteAuditoria").value="<%=carregatipo ? Apoio.getDataAtual() : "" %>" ;   

        }
</script>
<%@page import="tipo_veiculos.TipoVeiculosPamcary"%>
<%@page import="java.sql.ResultSet"%>
<html>
    <head>
        <script language="javascript" src="script/funcoes.js" type=""></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">

        <title>WebTrans - Cadastro de tipos de veículos</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
        <!--
        .style1 {font-size: 10px}
        -->
        </style>
    </head>

    <body onload="showObrigaCarreta();setDataAuditoria();AlternarAbasGenerico('tdPrincipal','divInformacoes')">
        <img src="img/banner.gif" >
        <br>
        <table width="50%" align="center" class="bordaFina" >
            <tr >
                <td width="268"><div align="left"><b>Tipos de veículos</b></div></td>
                <%  //se o paramentro vier com valor entao nao pode excluir
        if ((acao.equals("editar")) && (nivelUser >= 4) && (Boolean.parseBoolean(request.getParameter("ex")))) {%>
                <td width="63"><input name="excluir" type="button" class="botoes" id="excluir" value="Excluir"
                                      onClick="javascript:excluir(<%=(carregatipo ? cadtipo.getTpv().getId() : 0)%>)"></td>
                    <%}%>
                <td width="74" ><input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:voltar();"></td>
            </tr>
        </table>
        <br>
        <table width="50%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
            <tr class="tabela">
                <td colspan="4" align="center">Dados principais</td>
            </tr>
            <tr>
                <td width="96" class="TextoCampos">*Descrição:</td>
                <td width="184" class="CelulaZebra2">
                    <input name="descricao" type="text" id="descricao" value="<%=(carregatipo ? cadtipo.getTpv().getDescricao() : "")%>" size="30" maxlength="20" class="inputtexto"></td>
                <td colspan="2" width="123" class="CelulaZebra2"><label>
                        <div align="center">
                            <input name="iscarreta" type="checkbox" id="iscarreta" value="checkbox" <%=(carregatipo && cadtipo.getTpv().getIscarreta() ? "checked" : "")%> onclick="showObrigaCarreta();">
                            Tipo Carreta</div>
                    </label>
                </td>
            </tr>
            <tr>
                <td colspan="4" class="TextoCampos"><label>
                        <div align="center">
                            <input name="istabelado" type="checkbox" id="istabelado" value="checkbox" <%=(carregatipo && cadtipo.getTpv().getIstabelado() ? "checked" : "")%>>
                            Faz parte da tabela de clientes 
                        </div>      </label></td>
            </tr>
           
           
            
        </table> 
        <table width="50%" align="center" cellpadding="2" cellspacing="1">
            <tr>
                <td width="100%">
                    <table align="left">
                        <tr>
                            <td id="tdPrincipal" class="menu-sel" onclick="AlternarAbasGenerico('tdPrincipal','divInformacoes')"> Informações </td>

                            <td style='display: <%=carregatipo && nivelUser == 4 ? "" : "none"%>' id="tdAbaAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>

                        </tr>
                    </table>
                </td> 
            </tr>
        </table>          
        <div id="divInformacoes">             
            <table width="50%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr class="tabela">
                    <td colspan="3">Informações do CT-e</td>
                </tr>
                <tr>
                    <td  class="TextoCampos">Tipo veículo:</td>
                    <td class="CelulaZebra2" colspan="2">
                        <select name="tipoVeiculoCte" id="tipoVeiculoCte" class="inputtexto">
                            <option value="0" selected>Não informado</option>
                            <%TipoVeiculoCte tv = new TipoVeiculoCte();
                            ResultSet rstv = tv.all(Apoio.getUsuario(request).getConexao());
                            while (rstv.next()){%>
                            <option value="<%=rstv.getString("id")%>" <%=(carregatipo && rstv.getInt("id")==tipo.getTipoVeiculoCte().getId()?"selected":"") %>><%=rstv.getString("cod") + "-" + rstv.getString("descricao")%></option>
                            <%} %>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos">Tipo carroceria:</td>
                    <td colspan="2" class="CelulaZebra2">
                        <select name="tipoCarroceriaCte" id="tipoCarroceriaCte" class="inputtexto">
                            <option value="0" selected>Não informado</option>
                            <%TipoCarroceriaCte tc = new TipoCarroceriaCte();
                            ResultSet rstc = tc.all(Apoio.getUsuario(request).getConexao());
                            while (rstc.next()){%>
                            <option value="<%=rstc.getString("id")%>" <%=(carregatipo && rstc.getInt("id")==tipo.getTipoCarroceriaCte().getId()?"selected":"") %>><%=rstc.getString("cod") + "-" + rstc.getString("descricao")%></option>
                            <%} %>
                        </select>
                    </td>
                </tr>

                <tr class="tabela">
                    <td colspan="4">Informações Contrato de Frete Eletrônico</td>
                </tr>
                <tr>
                    <td class="textoCampos">Qtd. eixos:</td>
                    <td class="celulaZebra2" colspan="2">
                        <input name="qtdEixos" id="qtdEixos" value="<%=(carregatipo?cadtipo.getTpv().getQtdEixos():"0")%>" type="text" size="2" maxlength="1" class="inputTexto">
                    </td>
                    
                </tr>
                 <tr id="trObrigaCarreta">
                <td colspan="4" class="TextoCampos"><label>
                        <div align="center">
                            <input name="isObrigaCarreta" type="checkbox" id="isObrigaCarreta" value="checkbox" <%=(carregatipo && cadtipo.getTpv().isObrigaCarreta() ? "checked" : "")%>>
                            Obrigar inclus&atilde;o de uma carreta ao lançar coleta, CTRC, manifesto e/ou contrato de frete.
                        </div>      </label>
                </td>
            </tr>
                
               
                
                <tr id="trExpers2" style="<%=Apoio.getUsuario(request).getFilial().getStUtilizacaoCfeS().equals("X")? "display:" : "display:none"%>">
                    <td class="textoCampos" colspan="1">Tipo de Veículo no ExpeRS:</td>
                   
                                           
                        <td colspan="1" class="CelulaZebra2">
                            <select name="tipoVeiculoExpeRS" id="tipoVeiculoExpeRS" class="inputtexto">
                                <option value="0" selected>Não informado</option>
                                <%
                                TipoVeiculoExpeRSBO tipoVeiculoExpeRSBO = new TipoVeiculoExpeRSBO();
                                                                
                                for (TipoVeiculoExpeRS tipoVeiculoExpeRS : tipoVeiculoExpeRSBO.listarExpeRS()){%>                               
                                <option value="<%=tipoVeiculoExpeRS.getCodigo()%>" <%=(carregatipo && tipoVeiculoExpeRS.getCodigo().equals(tipo.getTipoVeiculoGerenciadorExpeRS().getCodigo())?"selected":"") %>><%=tipoVeiculoExpeRS.getCodigo() + "-" + tipoVeiculoExpeRS.getDescricao()%></option>
                                <%} %>
                            </select>
                        </td>
                    </td>
                    <td class="textoCampos"></td>
                </tr>
                 <tr id="trExpers2" style="<%=Apoio.getUsuario(request).getFilial().getStUtilizacaoCfeS().equals("R")? "display:" : "display:none"%>">
                    <td class="textoCampos" colspan="1">Tipo de Veículo Repom:</td>
                   
                                           
                        <td colspan="1" class="CelulaZebra2">
                            <select name="tipoVeiculoRepom" id="tipoVeiculoRepom" class="inputtexto">
                                <option value="0" selected>Não informado</option>
                                <%
                                TipoVeiculoRepomBO tipoVeiculoRepomBO = new TipoVeiculoRepomBO();
                                                                
                                for (TipoVeiculoRepom tipoVeiculoRepom : tipoVeiculoRepomBO.listarRepom()){%>                               
                                <option value="<%=tipoVeiculoRepom.getCodigo()%>" <%=(carregatipo && tipoVeiculoRepom.getCodigo().equals(tipo.getTipoVeiculoRepom().getCodigo())?"selected":"") %>><%=tipoVeiculoRepom.getCodigo() + "-" + tipoVeiculoRepom.getDescricao()%></option>
                                <%} %>
                            </select>
                        </td>
                    </td>
                    <td class="textoCampos"></td>
                </tr>
                
                
                
                
                <tr class="tabela">
                    <td colspan="4">Gerenciador de Risco</td>
                </tr>
                <tr>
                    <td class="textoCampos" colspan="1">Tipo de Veículo no Gerenciador de Risco:</td>                  
                                           
                        <td colspan="1" class="CelulaZebra2">
                            <select name="tipoVeiculoGerenciador" id="tipoVeiculoGerenciador" class="inputtexto">
                                <option value="0" selected>Não informado</option>
                                <%
                                TipoVeiculoBO tipoVeiculoBO = new TipoVeiculoBO();
                                                                
                                for (TipoVeiculo tipoVeiculo : tipoVeiculoBO.listar()){%>                               
                                <option value="<%=tipoVeiculo.getCodigo()%>" <%=(carregatipo && tipoVeiculo.getCodigo().equals(tipo.getTipoVeiculoGerenciador().getCodigo())?"selected":"") %>><%=tipoVeiculo.getCodigo() + "-" + tipoVeiculo.getDescricao()%></option>
                                <%} %>
                            </select>
                        </td>
                    
                    <td class="textoCampos"></td>
                </tr>
                <tr>
                    
                <td class="TextoCampos">Tipo de Veículo Integra&ccedil;&atilde;o Averbação Pamcary:</td>
                <td  class="CelulaZebra2">
                    <select name="tipoPamcary" id="tipoPamcary" class="inputtexto">
                        <option value="0" selected>Não informado</option>
                        <%TipoVeiculosPamcary pam = new TipoVeiculosPamcary();
                  ResultSet rs = pam.all(Apoio.getUsuario(request).getConexao());
                  while (rs.next()) {%>
                        <option value="<%=rs.getString("id")%>" <%=(carregatipo && rs.getInt("id") == tipo.getTipoPamcary().getId() ? "selected" : "")%>><%=rs.getString("codigo") + "-" + rs.getString("descricao")%></option>
                        <%}%>
                    </select>
                </td>
                <td class="celulaZebra2"></td>
            </tr>
                
        
            
     
            
     
            </table>
        </div>
        <div id="divAuditoria" >

            <table width="50%" align="center" cellpadding="2" cellspacing="1" class="bordaFina" id="tableAuditoria" style='display: <%=carregatipo && nivelUser == 4 ? "" : "none"%>'>
                <%@include file="gwTrans/template_auditoria.jsp" %>

            </table>
        </div>

        <br>   
        <% if (nivelUser >= 2){%>
        <table width="50%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
            <tr class="CelulaZebra2">
                <td colspan="6">
               
            <center>
                <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir":"atualizar")%>');});">
            </center>
            <%}%>    </td>
    </tr>  

</table>
</body>
</html>