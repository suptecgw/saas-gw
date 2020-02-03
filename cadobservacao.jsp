<%@ page contentType="text/html" language="java"
   import="observacao.CadObservacao,
           nucleo.Apoio" errorPage="" %>

<script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<% int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadobservacao") : 0);
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       response.sendError(response.SC_FORBIDDEN);
%>

<%
  String obs = "";
  String obs1 = "";
  String obs2 = "";
  String obs3 = "";
  String obs4 = "";
  String obs5 = "";


  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  boolean carregaObs = false;
  CadObservacao cadObs = null;

  if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar"))
  {     //instanciando o bean de cadastro
     cadObs = new CadObservacao();
     cadObs.setConexao(Apoio.getUsuario(request).getConexao());
     cadObs.setExecutor(Apoio.getUsuario(request));
  }

  //executando a acao desejada
  if ((acao.equals("editar")) && (request.getParameter("id") != null))
  {
     int id = Integer.parseInt(request.getParameter("id"));
     cadObs.getObs().setId(id);
     //carregando completo
     cadObs.LoadAllPropertys();
	 
	 obs = cadObs.getObs().getDescricao();
     int obs_sp_len = obs.split("\n").length;
	
     obs1 = (obs_sp_len  > 1? (obs.split("\n")[0] != null ? obs.split("\n")[0] : "" ): obs);
     obs2 = (obs_sp_len  >= 2? (obs.split("\n")[1] != null ? obs.split("\n")[1] : "") : "");
     obs3 = (obs_sp_len  >= 3? (obs.split("\n")[2] != null ? obs.split("\n")[2] : "") : "");
     obs4 = (obs_sp_len  >= 4? (obs.split("\n")[3] != null ? obs.split("\n")[3] : "") : "");
     obs5 = (obs_sp_len  >= 5? (obs.split("\n")[4] != null ? obs.split("\n")[4] : "") : "");


  }else
  if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir")))
  {
      //populando o JavaBean
      cadObs.getObs().setDescricao( request.getParameter("descricao") );
      if (acao.equals("atualizar"))
    	  cadObs.getObs().setId(Integer.parseInt(request.getParameter("id")));
      //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
      //3º teste de erro naquela acao executada.
      boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                      ? cadObs.Inclui() : cadObs.Atualiza());

//EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
      %><script language="javascript" type=""><%
         if (erro)
         {
             if(cadObs.getErros().contains("unk_descricao")){
                cadObs.setErros("Já existe uma Observação com essa descrição.");
             }
             acao = (acao.equals("atualizar") ? "editar" : "iniciar");
             %>alert('<%=(cadObs.getErros())%>');
             window.opener.document.getElementById("salvar").disabled = false;
             window.opener.document.getElementById("salvar").value = "Salvar";
        <%}else{%>
			if (window.opener != null)
               window.opener.document.getElementById("bt_consultar").onclick();
           location.replace("ConsultaControlador?codTela=43");
        <%}%>
        window.close();
       </script>

 <%}
   //variavel usada para saber se o usuario esta editando
   carregaObs = (cadObs != null && (!acao.equals("incluir") || !acao.equals("atualizar")));
 %>
 <script language="javascript" type="text/javascript">
    jQuery.noConflict();
    function voltar(){
     location.replace("ConsultaControlador?codTela=43");
  }

  function salva(acao){
     if ($v('obs_lin1')+""+$v('obs_lin2')+""+$v('obs_lin3')+""+$v('obs_lin4')+""+$v('obs_lin5') != "")
     {
		  document.getElementById("salvar").disabled = true;
		  document.getElementById("salvar").value = "Enviando...";
		  if (acao == "atualizar")
			 acao += "&id=<%=( carregaObs ? cadObs.getObs().getId(): 0)%>";

         requisitaPost("acao="+acao+"&descricao="+getObservacao(), "./cadobservacao.jsp");//
     }else
	   alert("Preencha pelo menos UMA linha!");
  }

  function excluir(id){
       if (confirm("Deseja mesmo excluir esta observacao?"))
	   {
	       location.replace("./consulta_observacao.jsp?acao=excluir&id="+id);
	   }
  }
  
  function getObservacao(){
	var ob = ""; 
	for (i = 1; i < 6; ++i)
		ob += $('obs_lin'+i).value.trim()+(i!=5? '\n' : '');

	return ob;
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
                var rotina = "observacao";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = $("id").value;
                console.log(id);
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
    
    function setDataAuditoria(){
        
     
        var data = "<%=Apoio.getDataAtual()%>";
        console.log("data : "+data);
        $("dataDeAuditoria").value="<%=carregaObs ? Apoio.getDataAtual() :  "" %>" ;   
        $("dataAteAuditoria").value="<%=carregaObs ? Apoio.getDataAtual() : "" %>" ;   
        
    }
    
    function incluirVariavel(elemento,contador){
        var tamanho = elemento.innerHTML.trim().length;
        
        //if((parseFloat(document.getElementById("obs_lin"+contador).value.length) + tamanho) <= 59){
            document.getElementById("obs_lin"+contador).value += elemento.innerHTML.trim();
        //}
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

<title>WebTrans - Cadastro de Observações</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {font-size: 10px}
.textfieldsObs{
	font-size:9px;
	clear: both;
	border: 0.3;
	padding: 1px;
}
-->
</style>
</head>

<body onload="setDataAuditoria();">
<img src="img/banner.gif" >
<br>
<table width="50%" align="center" class="bordaFina" >
  <tr >
    <td width="613"><div align="left"><b>Cadastro de Observa&ccedil;&otilde;es 
        para lançamentos</b></div></td>
    <%  //se o paramentro vier com valor entao nao pode excluir
        if ((acao.equals("editar")) && (nivelUser >= 4) && (request.getParameter("ex") == null))
	{%>
	   <td width="15"><input name="excluir" type="button" class="botoes" id="excluir" value="Excluir"
             onClick="javascript:excluir(<%=(carregaObs ? cadObs.getObs().getId(): 0)%>)"></td>
	<%}%>
    <td width="56" ><input  name="bt_consultar" id="bt_consultar" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:voltar();"></td>
  </tr>
</table>
<br>
<table width="50%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
  <tr class="tabela">
    <td colspan="2" align="center">Dados principais</td>
  </tr>
  <tr>
    <td width="98" class="TextoCampos">*Descri&ccedil;&atilde;o:</td>
    <td width="447" class="CelulaZebra2">
        <input name="obs_lin1" type="text" class="inputtexto" id="obs_lin1" 
			value="<%=obs1%>" 
                        size="99" maxlength="99" onclick="javascript: $('index').value = 1" >
        <input name="obs_lin2" type="text" class="inputtexto" id="obs_lin2" 
			value="<%=obs2%>" 
                  size="99" maxlength="99" onclick="javascript: $('index').value = 2" >
        <input name="obs_lin3" type="text" class="inputtexto" id="obs_lin3" 
			value="<%=obs3%>" 
                  size="99" maxlength="99" onclick="javascript: $('index').value = 3" >
        <input name="obs_lin4" type="text" class="inputtexto" id="obs_lin4" 
			value="<%=obs4%>" 
                  size="99" maxlength="99" onclick="javascript: $('index').value = 4" >
        <input name="obs_lin5" type="text" class="inputtexto" id="obs_lin5" 
			value="<%=obs5%>" 
                  size="99" maxlength="99" onclick="javascript: $('index').value = 5" >
        <input name="index" type="hidden" class="inputtexto" id="index" value="1">
    </td>
   </tr>
    <tr class="tabela">
        <td colspan="2" align="center">Variáveis para observação do CT-e</td>
    </tr>
    <tr class="CelulaZebra2">
        <td align="left">
            <label onclick="incluirVariavel(this,$('index').value)" class="linkEditar"> @@base_icms </label>
        </td>
        <td>
            <label>Base de cálculo do ICMS</label>
        </td>
    </tr>
    <tr class="CelulaZebra2">
        <td align="left">
            <label onclick="incluirVariavel(this,$('index').value)" class="linkEditar"> @@st_icms </label>
        </td>
        <td>
            <label>CST do ICMS</label>
        </td>
    </tr>
    <tr class="CelulaZebra2">
        <td align="left">
            <label onclick="incluirVariavel(this,$('index').value)" class="linkEditar"> @@cred_presumido_icms </label>
        </td>
        <td>
            <label>Crédito presumido</label>
        </td>
    </tr>
    <tr class="CelulaZebra2">
        <td align="left">
            <label onclick="incluirVariavel(this,$('index').value)" class="linkEditar"> @@valor_prestacao_icms </label>
        </td>
        <td>
            <label>Valor ICMS</label>
        </td>
    </tr>
    <tr class="CelulaZebra2">
        <td align="left">
            <label onclick="incluirVariavel(this,$('index').value)" class="linkEditar"> @@aliquota_icms </label>
        </td>
        <td>
            <label>Alíquota ICMS</label>
        </td>
    </tr>
    <tr class="CelulaZebra2">
        <td align="left">
            <label onclick="incluirVariavel(this,$('index').value)" class="linkEditar"> @@pedido </label>
        </td>
        <td>
            <label>Número do pedido</label>
        </td>
    </tr>
    <tr class="CelulaZebra2">
        <td align="left">
            <label onclick="incluirVariavel(this,$('index').value)" class="linkEditar"> @@carga </label>
        </td>
        <td>
            <label>Número da carga</label>
        </td>
    </tr>
    <tr class="CelulaZebra2">
        <td align="left">
            <label onclick="incluirVariavel(this,$('index').value)" class="linkEditar"> @@setor_entrega </label>
        </td>
        <td>
            <label>Setor de entrega</label>
        </td>
    </tr>
    <tr class="CelulaZebra2">
        <td align="left">
            <label onclick="incluirVariavel(this,$('index').value)" class="linkEditar"> @@placa </label>
        </td>
        <td>
            <label>Placa do veículo</label>
        </td>
    </tr>
    <tr class="CelulaZebra2">
        <td align="left">
            <label onclick="incluirVariavel(this,$('index').value)" class="linkEditar"> @@motorista </label>
        </td>
        <td>
            <label>Motorista do veículo</label>
        </td>
    </tr>
    <tr class="CelulaZebra2">
        <td align="left">
            <label onclick="incluirVariavel(this,$('index').value)" class="linkEditar"> @@seguradora </label>
        </td>
        <td>
            <label>Seguradora</label>
        </td>
    </tr>
    <tr class="CelulaZebra2">
        <td align="left">
            <label onclick="incluirVariavel(this,$('index').value)" class="linkEditar"> @@apolice </label>
        </td>
        <td>
            <label>Apolice de seguro</label>
        </td>
    </tr>
    <tr class="CelulaZebra2">
        <td align="left">
            <label onclick="incluirVariavel(this,$('index').value)" class="linkEditar"> @@previsao_entrega </label>
        </td>
        <td>
            <label>Previsão de entrega</label>
        </td>
    </tr>
    <tr class="tabela">
        <td colspan="2" align="center">Variáveis para observação do MDF-e</td>
    </tr>
    <tr class="CelulaZebra2">
        <td align="left">
            <label onclick="incluirVariavel(this,$('index').value)" class="linkEditar"> @@seguradora </label>
        </td>
        <td>
            <label>Seguradora</label>
        </td>
    </tr>
    <tr class="CelulaZebra2">
        <td align="left">
            <label onclick="incluirVariavel(this,$('index').value)" class="linkEditar"> @@apolice </label>
        </td>
        <td>
            <label>Apolice de seguro</label>
        </td>
    </tr>
    <tr class="CelulaZebra2">
        <td align="left">
            <label onclick="incluirVariavel(this,$('index').value)" class="linkEditar"> @@renavam </label>
        </td>
        <td>
            <label>Renavam</label>
        </td>
    </tr>
    <tr class="CelulaZebra2">
        <td align="left">
            <label onclick="incluirVariavel(this,$('index').value)" class="linkEditar"> @@CIOT </label>
        </td>
        <td>
            <label>CIOT</label>
        </td>
    </tr>
</table>
                  <table width="50%" align="center" cellpadding="2" cellspacing="1">
                    <tr>
                        <td width="100%">
                          <table align="left">
                               <tr>
                                                   
                                  <td style='display: <%=carregaObs && nivelUser == 4 ? "" : "none"%>' id="tdAbaAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>
                                    
                               </tr>
                            </table>
                        </td> 
                    </tr>
               </table>     
  <input type="hidden" value="<%=(carregaObs ? cadObs.getObs().getId() : 0)%>" id="id" name="id">
                 
                            
                             <table align="center"  width="50%" class="bordaFina" style='display: <%=carregaObs && nivelUser == 4 ? "" : "none"%>' >
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
                  <% if (nivelUser >= 2){%>       
                  <br/>
                  <table align="center"  width="50%" class="bordaFina" >                         
                    <tr class="CelulaZebra2">
                      <td colspan="4">
                       
                          <center>
                            <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir":"atualizar")%>');});">
                          </center>
                            <%}%>	</td>
                    </tr>
                    </table>
<br>

