
<%@page import="java.text.DecimalFormat"%>
<%@ page contentType="text/html" language="java"
   import="conhecimento.coleta.tipoContainer.*,
           nucleo.Apoio" errorPage="" %>

 
  <script language="javascript" type="text/javascript" src="script/builder.js"></script>
  <script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
  <script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
  <script language="javascript" type="text/javascript" src="script/jquery.js"></script>
  <script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadtipocontainer") : 0);
   boolean souadm = Apoio.getUsuario(request).getSouAdm();
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA
%>

<%

  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  boolean carregaTipoContainer = false;
  //Variavél para apontar que existe erro no controlador
  boolean erroControlador = false;
  
  CadTipoContainer cad= null;
  TipoContainer ntp = null;

  if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar"))
  {     //instanciando o bean de cadastro
        ntp = new TipoContainer();
        cad = new CadTipoContainer();
        cad.setConexao(Apoio.getUsuario(request).getConexao());
        cad.setExecutor(Apoio.getUsuario(request));
  }

  //executando a acao desejada
  if ((acao.equals("editar")) && (request.getParameter("id") != null))
  {
     int idTp = Integer.parseInt(request.getParameter("id"));
     ntp.setId(idTp);
     cad.setTp(ntp);
     //carregando completo
     cad.LoadAllPropertys();
  }else
  if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir")))
  {
      //populando o JavaBean
      ntp.setDescricao( request.getParameter("descricao") );
      double peso = 0;
      double valor = 0;
      
      try{
          
          peso = Double.parseDouble(request.getParameter("pesoContainer"));
          valor = Double.parseDouble(request.getParameter("valorContainer"));
          
      }catch(NumberFormatException ex){
          ex.printStackTrace();
          cad.setErros("ATENÇÃO : Os Campos de peso/valor só aceitam números, preencha corretamente!");
          erroControlador = true;
      }

          ntp.setPeso(peso);
          ntp.setValor(valor);
      
      
      if (acao.equals("atualizar"))
          ntp.setId(Integer.parseInt(request.getParameter("id")));
      //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
      //3º teste de erro naquela acao executada.
      cad.setTp(ntp);
      boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                      ? cad.Inclui() : cad.Atualiza());

//EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
%><script language="javascript" type="text/javascript"><%

         if (erro || erroControlador)
         {
             acao = (acao.equals("atualizar") ? "editar" : "iniciar");
             %>
                 alert('<%=(cad.getErros())%>');
                 
        <%}else{%>
             location.replace("ConsultaControlador?codTela=40");
        <%}%>
       </script>

 <%}
   //variavel usada para saber se o usuario esta editando
   carregaTipoContainer= (cad != null && (!acao.equals("incluir") || !acao.equals("atualizar")));
 %>
 <script language="javascript" type="text/javascript">

  //Em caso de alteração, o combo UF recebe o valor do BD
  //Está sendo utilizado no onload do body


    arAbasGenerico = new Array();
    arAbasGenerico[0] = stAba('tdAbaAuditoria','divAuditoria');
    
  function voltar(){
     location.replace("ConsultaControlador?codTela=40");
  }

  function salva(acao){
     if (!wasNull('descricao')){
		  document.getElementById("salvar").disabled = true;
		  document.getElementById("salvar").value = "Enviando...";
		  if (acao == "atualizar")
			 acao += "&id=<%=( carregaTipoContainer ? cad.getTp().getId() : 0)%>";
  		     document.location.replace("./cadtipo_container.jsp?acao="+acao+"&"+concatFieldValue("descricao")+"&pesoContainer="+$("pesoContainer").value+"&valorContainer="+$("valorContainer").value);
     }else
	   alert("Preencha os campos corretamente!");
  }

  function excluir(idNv){
       if (confirm("Deseja mesmo excluir este navio?"))
	   {
	       location.replace("./consulta_tipo_container.jsp?acao=excluir&id="+idNv);
	   }
  }
   jQuery.noConflict();
 
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
                var rotina = "tipo_container";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = <%=( carregaTipoContainer ? cad.getTp().getId() : 0)%>
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
            
     function setDataAuditoria(){
        
     
        var data = "<%=Apoio.getDataAtual()%>";
        console.log("data : "+data);
        $("dataDeAuditoria").value="<%=carregaTipoContainer ? Apoio.getDataAtual() :  "" %>" ;   
        $("dataAteAuditoria").value="<%=carregaTipoContainer ? Apoio.getDataAtual() : "" %>" ;   
        
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

<title>WebTrans - Cadastro de Tipo de Container</title>
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
    <td width="268"><div align="left"><b>Tipo de Container</b></div></td>
    <%  //se o paramentro vier com valor entao nao pode excluir
        if ((acao.equals("editar")) && (nivelUser >= 4) && (Boolean.parseBoolean(request.getParameter("ex"))))
	{%>
    <td width="63"><input name="excluir" type="button" class="botoes" id="excluir" value="Excluir"
             onClick="javascript:excluir(<%=(carregaTipoContainer ? cad.getTp().getId() : 0)%>)"></td>
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
    <td class="TextoCampos">*Descrição:</td>
    <td class="CelulaZebra2" colspan="4">
            <input name="descricao" type="text" id="descricao" value="<%=(carregaTipoContainer?cad.getTp().getDescricao():"")%>" size="45" maxlength="30" class="inputtexto">
    </td>
  </tr>
  <tr>
    <td class="TextoCampos">Peso:</td>
    <td class="CelulaZebra2">
        <input name="pesoContainer" type="text" id="pesoContainer" value="<%=(carregaTipoContainer?Apoio.to_curr(cad.getTp().getPeso()):"0.00")%>" size="15" maxlength="20" class="inputtexto" onblur="javascript:seNaoFloatReset(this,'0.00');" >
    </td>
    <td class="TextoCampos">Valor:</td>
    <td class="CelulaZebra2">
        <input name="valorContainer" type="text" id="valorContainer" value="<%=(carregaTipoContainer?Apoio.to_curr(cad.getTp().getValor()):"0.00")%>" size="15" maxlength="20" class="inputtexto" onblur="javascript:seNaoFloatReset(this,'0.00');" >
    </td>
  </tr>
  
</table>

        <table align="center" width="50%" >
                        <tr>
                            <td width="100%">
                                <table align="left">
                                    <tr>
                                       
                                       <td style='display: <%=carregaTipoContainer && nivelUser == 4 ? "" : "none"%>' id="tdAbaAuditoria" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>
                                       
                                    </tr>
                                </table>
                            </td> 
                        </tr>
                    </table>
                  
                    <table align="center"  width="50%" class="bordaFina" style='display: <%=carregaTipoContainer && nivelUser == 4 ? "" : "none"%>' >
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
                                               
                                                  <br>
                    <% if (nivelUser >= 2){%>
                <table class="bordaFina" width="50%" align="center">
                    <tr class="CelulaZebra2">
                        <td colspan="5">
                        
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
