<%@ page contentType="text/html" language="java" 
         import="conhecimento.ocorrencia.BeanCadOcorrencia,  
         conhecimento.ocorrencia.BeanOcorrenciaCtrc,
         nucleo.Apoio" errorPage="" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="test/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
    // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
    int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadocorrencia") : 0);
    //testando se a sessao eh valida e se o usuario tem acesso
    if (Apoio.getUsuario(request) == null || nivelUser == 0) {
        response.sendError(response.SC_FORBIDDEN);
    }

    //fim da MSA
%>

<%
    
    String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    boolean carregaOco = false;
    BeanOcorrenciaCtrc oco = new BeanOcorrenciaCtrc();
    BeanCadOcorrencia cad = null;
    

    if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar")) {     //instanciando o bean de cadastro
        cad = new BeanCadOcorrencia();
        cad.setConexao(Apoio.getUsuario(request).getConexao());
        cad.setExecutor(Apoio.getUsuario(request));
    }

    //executando a acao desejada
    if ((acao.equals("editar")) && (request.getParameter("id") != null)) {
        int id = Integer.parseInt(request.getParameter("id"));
        oco.setId(id);
        cad.setOcorrenciaCtrc(oco);
        //carregando completo
        cad.LoadAllPropertys();
    } else if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir"))) {
        //populando o JavaBean
        oco.setCodigo(request.getParameter("codigo"));
        oco.setDescricao(request.getParameter("descricao"));
        oco.setColeta(request.getParameter("isColeta") != null ? true : false);
        oco.setConhecimento(request.getParameter("isConhecimento") != null ? true : false);
        oco.setBloqueiaDataLimiteEntrega(request.getParameter("isBloqueiaDataLimiteEntrega") != null ? true : false);
        oco.setObrigaResolucao(request.getParameter("isObrigaResolucao") != null ? true : false);
        oco.setOculta(request.getParameter("isOcultar")!= null ? true : false);
        oco.setContratoFrete(request.getParameter("isContratoFrete") != null ? true : false);
        oco.setGwMobile(request.getParameter("isGwMobile") != null ? true : false);
        oco.setEntregaRealizada(request.getParameter("isEntregaRealizada") != null ? true : false);
        oco.setEntregaNaoRealizada(request.getParameter("isEntregaNaoRealizada") != null ? true : false);
        oco.setDescricaoParaConsultaCliente(request.getParameter("descricaoParaConsulta"));
        oco.setComplementar(request.getParameter("isComplementar") != null ? true : false);
        oco.setReentegra(request.getParameter("isReentrega") != null ? true : false);
        oco.setDevolucao(request.getParameter("isDevolucao") != null ? true : false);
        oco.setDiaria(request.getParameter("isDiaria") != null ? true : false);
        oco.setPallet(request.getParameter("isPallet") != null ? true : false);
        oco.setLiberaPagamentoRepresentante(request.getParameter("isLiberaRepresentante") != null ? true : false);
        oco.setEnviarEmailOcorrenciaCTe(Apoio.parseBoolean(request.getParameter("chkEnviaEmailOcorrencia")));
        oco.setEnviarPushOcorrencias(Apoio.parseBoolean(request.getParameter("chkEnviarPushOcorrencias")));
        oco.setFornecedor(Apoio.parseBoolean(request.getParameter("isFornecedor")));
        oco.setMotorista(Apoio.parseBoolean(request.getParameter("isMotorista")));        
        if (acao.equals("atualizar")) {
            oco.setId(Integer.parseInt(request.getParameter("id")));
        }

        cad.setOcorrenciaCtrc(oco);

        //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
        //3º teste de erro naquela acao executada.
        boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                ? cad.Inclui() : cad.Atualiza());

        //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
%><script language="javascript" type=""><%
    if (erro) {
        acao = (acao.equals("atualizar") ? "editar" : "iniciar");
    %>alert('<%=(cad.getErros())%>');
    
    window.opener.document.getElementById("salvar").disabled = false;
    window.opener.document.getElementById("salvar").value = "Salvar";
    <%} else {%>
    if (window.opener != null)
    window.opener.document.location.replace("ConsultaControlador?codTela=44");
    <%}%>
    window.close();
</script>

<%}
    //variavel usada para saber se o usuario esta editando
    carregaOco = (cad != null && oco.getDescricao() != null);

    request.setAttribute("carregaOco", carregaOco);
    request.setAttribute("oco", oco);
%>
<script language="javascript" type="text/javascript">
    
   
     jQuery.noConflict(); 
     
     arAbasGenerico = new Array();
     arAbasGenerico[0] = new stAba('tdPrincipal','divDadosPrincipais');
     arAbasGenerico[1] = new stAba('tdAbaAuditoria','divAuditoria');
           
    function voltar(){
        document.location.replace("ConsultaControlador?codTela=44");
    }

    function utilizarGwMobile(){
        if ($("isGwMobile").checked) {
            //visivel($("dvRealizada"));
            //visivel($("dvNaoRealizada"));
        }else{
            //invisivel($("dvRealizada"));
            //invisivel($("dvNaoRealizada"));
        }
    }
    function salva(acao){
        if ($("codigo").value == null || $("codigo").value == "") {
            alert ("Informe o codigo corretamente.");
            $("codigo").focus();
            return false;
        }
        else if ( $("descricao").value == "") {
            alert ("Informe o codigo corretamente.");
            $("descricao").focus();
            return false;
        }

        document.getElementById("salvar").disabled = true;
        document.getElementById("salvar").value = "Enviando...";

        $("acao").value = '<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>';

        if (acao == "atualizar")
            acao += "&id=<%=(carregaOco ? oco.getId() : 0)%>";
        //requisitaPost("acao="+acao+"&descricao="+document.getElementById("descricao").value,"./cadocorrencia.jsp");

        window.open('about:blank', 'pop', 'width=210, height=100');
        $("formulario").submit();
     
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
                var rotina = "ocorrencia_ctrcs";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = $("id").value;
              
                
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
    
      function setAuditoria(){
        $("dataDeAuditoria").value="<%=carregaOco ? Apoio.getDataAtual() :  "" %>" ;   
        $("dataAteAuditoria").value="<%=carregaOco ? Apoio.getDataAtual() : "" %>" ;   
        
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

        <title>WebTrans - Cadastro de ocorrência</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        
        <style type="text/css">
            <!--
            .style1 {font-size: 10px}
            -->
        </style>
    </head>

    <body onload="setAuditoria();utilizarGwMobile();AlternarAbasGenerico('tdPrincipal','divDadosPrincipais')">
        <form method="post" action="./cadocorrencia.jsp" id="formulario" target="pop">
            <img src="img/banner.gif" >
            <br>
            <table width="50%" align="center" class="bordaFina" >
                <tr >
                    <td width="613"><div align="left"><b>Cadastro de Ocorrência</b></div></td>
                    <td width="56" ><input  name="Button" type="button" class="botoes" value="Voltar para Consulta" onClick="javascript:voltar();"></td>
                </tr>
            </table>
            <br>
            <table width="50%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr>
                    <td class="celulaZebra2">
                        <input type="hidden" name="id" id="id" value="<%=(carregaOco ? oco.getId() : "0")%>">
                        <input type="hidden" name="acao" id="acao" value="<%=acao%>">
                        <fieldset>
                            <legend>Dados principais</legend>
                            <table width="100%" class="tabelaZerada">
                                <tr>
                                    <td  class="TextoCampos" width="15%">*Código:</td>
                                    <td  class="CelulaZebra2" width="15%">
                                        <input name="codigo" type="text" id="codigo" value="<%=(carregaOco ? oco.getCodigo() : "")%>" size="3" maxlength="3" class="inputtexto">
                                    </td>
                                    <td  class="TextoCampos" width="17%">*Descri&ccedil;&atilde;o:</td>
                                    <td  class="CelulaZebra2" width="52%">
                                        <input name="descricao" type="text" id="descricao" value="<%=(carregaOco ? oco.getDescricao() : "")%>" size="40" maxlength="60" class="inputtexto">
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </td>
                </tr>    
            </table>
            <br>
                <table width="50%" align="center" cellpadding="2" cellspacing="1">
                    <tr>
                        <td width="100%">
                          <table align="left">
                               <tr>
                                  <td id="tdPrincipal" class="menu-sel" onclick="AlternarAbasGenerico('tdPrincipal','divDadosPrincipais')"> Dados Principais </td>
                                               
                                  <td  style='display: <%=carregaOco && nivelUser ==4 ? "" : "none" %>' id="tdAbaAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>
                            
                               </tr>
                            </table>
                        </td> 
                    </tr>
                </table>              
                                    
            <div id="divDadosPrincipais">         
               <table width="50%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina" >             
                                <tr>
                                    <td  class="TextoCampos" colspan="3">Descrição para a consulta do cliente:</td>
                                    <td  class="CelulaZebra2" colspan="1">
                                        <input name="descricaoParaConsulta" type="text" id="descricaoParaConsulta" value="<%=(carregaOco ? oco.getDescricaoParaConsultaCliente() : "")%>" size="40" maxlength="60" class="inputtexto">
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos" colspan="4">
                                        <div align="center">
                                            <label>
                                                <input name="isOcultar" type="checkbox" id="isOcultar" value="checkbox" <%=(carregaOco ? (oco.isOculta() ? "checked" : "") : "")%>>
                                                Ocultar essa ocorrência na tela de consulta de entrega do módulo do cliente e na geração do EDI OCOREN.
                                            </label>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos" >Utilizar:</td>
                                    <td class="CelulaZebra2NoAlign" colspan="3" align="center">
                                        <label>
                                            <input name="isColeta" type="checkbox" id="isColeta" value="checkbox" <%=(carregaOco ? (oco.isColeta() ? "checked" : "") : "")%>>
                                            Na Coleta
                                        </label>
                                        <label>
                                            <input name="isConhecimento" type="checkbox" id="isConhecimento" value="checkbox" <%=(carregaOco ? (oco.isConhecimento() ? "checked" : "") : "")%>>
                                            No Conhecimento
                                        </label>
                                        <label>
                                            <input name="isContratoFrete" type="checkbox" id="isContratoFrete" value="checkbox" <%=(carregaOco ? (oco.isContratoFrete() ? "checked" : "") : "")%>>
                                            No Contrato de Frete
                                        </label>
                                        <label>
                                            <input name="isFornecedor" type="checkbox" id="isFornecedor" value="checkbox" <%=(carregaOco ? (oco.isFornecedor() ? "checked" : "") : "")%>>
                                            No Fornecedor
                                        </label>
                                        <label>
                                            <input name="isMotorista" type="checkbox" id="isMotorista" value="checkbox" <%=(carregaOco ? (oco.isMotorista()? "checked" : "") : "")%>>
                                            No Motorista
                                        </label>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos" colspan="4">
                                        <div align="center">
                                            <label>
                                                <input name="isBloqueiaDataLimiteEntrega" type="checkbox" id="isBloqueiaDataLimiteEntrega" value="checkbox" <%=(carregaOco ? (oco.isBloqueiaDataLimiteEntrega() ? "checked" : "") : "")%>>
                                                Isentar transportadora em relação ao prazo de entrega (Ineficiência do Cliente)
                                            </label>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos" colspan="4">
                                        <div align="center">
                                            <label>
                                                <input name="isObrigaResolucao" type="checkbox" id="isObrigaResolucao" value="checkbox" <%=(carregaOco ? (oco.isObrigaResolucao() ? "checked" : "") : "")%>>
                                                Obrigar resolu&ccedil;&atilde;o do problema ao utilizar essa ocorr&ecirc;ncia
                                            </label>
                                        </div>
                                    </td>
                                </tr>
                                <tr>                                    
                                    <td class="TextoCampos" colspan="4" align="center">
                                        <div align="center">
                                        Ao utilizar essa ocorrência, deverá ser emitido um CT-e extra de:<br>
                                        <label>
                                        <input name="isComplementar" type="checkbox" id="isComplementar" value="checkbox" <%=(carregaOco ? (oco.isComplementar() ? "checked" : "") : "")%>> Complemento
                                        </label>
                                        <label>
                                        <input name="isReentrega" type="checkbox" id="isReentrega" value="checkbox" <%=(carregaOco ? (oco.isReentegra() ? "checked" : "") : "")%>> Reentrega
                                        </label>
                                        <label>
                                        <input name="isDevolucao" type="checkbox" id="isDevolucao" value="checkbox" <%=(carregaOco ? (oco.isDevolucao() ? "checked" : "") : "")%>> Devolução
                                        </label>
                                        <label>
                                        <input name="isDiaria" type="checkbox" id="isDiaria" value="checkbox" <%=(carregaOco ? (oco.isDiaria() ? "checked" : "") : "")%>> Diária
                                        </label>
                                        <label>
                                        <input name="isPallet" type="checkbox" id="isPallet" value="checkbox" <%=(carregaOco ? (oco.isPallet() ? "checked" : "") : "")%>> Pallet
                                        </label>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos" colspan="4">
                                        <div align="center">
                                            <label>
                                                <input name="isLiberaRepresentante" type="checkbox" id="isLiberaRepresentante" value="checkbox" <%=(carregaOco ? (oco.isLiberaPagamentoRepresentante()? "checked" : "") : "")%>>
                                                Liberar pagamento do representante de entrega caso no CT-e tenha essa ocorrência.
                                            </label>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos" colspan="4">
                                    <div align="center">
                                        <label>
                                            <input name="chkEnviaEmailOcorrencia" type="checkbox" id="chkEnviaEmailOcorrencia" value="checkbox" <%=(carregaOco ? (oco.isEnviarEmailOcorrenciaCTe()? "checked" : "") : "")%>>
                                            Enviar e-mail para o cliente ao utilizar essa ocorrência no CT-e.                                            
                                        </label>
                                    </div>
                                    </td>
                                </tr>
                               <tr>
                                   <td class="TextoCampos" colspan="4">
                                       <div align="center">
                                           <input type="checkbox" id="chkEnviarPushOcorrencias" name="chkEnviarPushOcorrencias" ${carregaOco ? (oco.enviarPushOcorrencias ? "checked" : "") : ""}>
                                           <label for="chkEnviarPushOcorrencias">Enviar notificações PUSH ao incluir essa ocorrência no CT-e</label>
                                       </div>
                                   </td>
                               </tr>
                             </table>
                            <table width="50%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina" >
                              
                                  <tbody id="tbAuditoriaCabecalho">
                            <tr>
                                <td colspan="6"  class="celulaZebra2"><legend>Configurações para Baixa de CT-e(s)</legend>  </td>
                            </tr>
                            <tr>
                                  <td class="TextoCampos" width="33%">
                                        <div align="center">
                                            <label>
                                                <input name="isGwMobile" type="checkbox" id="isGwMobile" onclick="" value="checkbox" <%=(carregaOco ? (oco.isGwMobile() ? "checked" : "") : "")%>>
                                                Utilizar no gwMobile
                                            </label>
                                        </div>
                                    </td>
                                    <td class="TextoCampos" width="33%">
                                        <div align="center" id="dvRealizada">
                                            <label>
                                                <input name="isEntregaRealizada" type="checkbox" id="isEntregaRealizada" value="checkbox" <%=(carregaOco ? (oco.isEntregaRealizada() ? "checked" : "") : "")%>>
                                                Utilizar Para Entrega(s) Realizada(s)
                                            </label>
                                        </div>
                                    </td>
                                    <td class="TextoCampos" width="33%">
                                        <div align="center" id="dvNaoRealizada">
                                            <label>
                                                <input name="isEntregaNaoRealizada" type="checkbox" id="isEntregaNaoRealizada" value="checkbox" <%=(carregaOco ? (oco.isEntregaNaoRealizada() ? "checked" : "") : "")%>>
                                                Utilizar Para Entrega(s) Não Realizada(s)
                                            </label>
                                        </div>
                                    </td>
                                </tr>
                            
                            </tbody>
               </table>
            </div>
             
            <div id="divAuditoria" width="50%"  >
                    
                     <table colspan="3" width="50%" align="center" cellpadding="1" cellspacing="1" class="bordaFina" id="tableAuditoria" style='display: <%=carregaOco && nivelUser ==4 ? "" : "none" %>'>
                        <%@include file="./gwTrans/template_auditoria.jsp" %>
                    </table>
                    
                </div> 
               
                    <br/>
                    <% if (nivelUser >= 2) {%>
                    <table width="50%" align="center" class="bordaFina" >
                    <tr class="CelulaZebra2">
                         <td colspan="4">
                                    
                            <center>
                                <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>');});">
                            </center>
                            <%}%>
                        </td>
                    </tr>
                 </table>
         </form>
    </body>
</html>