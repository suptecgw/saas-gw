<%@ page contentType="text/html" language="java"
         import="despesa.especie.*,
         nucleo.Apoio" errorPage="" %>

<script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>

<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
    // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
    int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadespecie") : 0);
    boolean souadm = Apoio.getUsuario(request).getSouAdm();
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(response.SC_FORBIDDEN);
    }
   //fim da MSA
%>

<%
    String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    boolean carregaEs = false;
    CadEspecie cadEs = null;
    Especie es = null;

    if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar")) {     //instanciando o bean de cadastro
        es = new Especie();
        cadEs = new CadEspecie();
        cadEs.setConexao(Apoio.getUsuario(request).getConexao());
        cadEs.setExecutor(Apoio.getUsuario(request));
    }

    //executando a acao desejada
    if ((acao.equals("editar")) && (request.getParameter("id") != null)) {
        int id = Integer.parseInt(request.getParameter("id"));
        es.setId(id);
        cadEs.setEs(es);
        //carregando completo
        cadEs.LoadAllPropertys();
    } else if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir"))) {
        //populando o JavaBean
        es.setEspecie(request.getParameter("especie"));
        es.setDescricao(request.getParameter("descricao"));
        es.setContabilidade(Boolean.parseBoolean(request.getParameter("iscontabilidade")));
        es.setFiscal(Boolean.parseBoolean(request.getParameter("isfiscal")));
        es.setTipoPagamento(request.getParameter("tipoPagamento"));
        es.setModeloSintegraSped(request.getParameter("modelo"));
        if (acao.equals("atualizar")) {
            es.setId(Integer.parseInt(request.getParameter("id")));
        }
      //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
        //3º teste de erro naquela acao executada.
        cadEs.setEs(es);
        boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                ? cadEs.Inclui() : cadEs.Atualiza());

//EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
%><script language="javascript" type=""><%          if (erro) {
              acao = (acao.equals("atualizar") ? "editar" : "iniciar");
    %>alert('<%=(cadEs.getErros())%>');
    <%} else {%>
    location.replace("ConsultaControlador?codTela=23");
    <%}%>
</script>

<%}
    //variavel usada para saber se o usuario esta editando
    carregaEs = (cadEs != null && (!acao.equals("incluir") || !acao.equals("atualizar")));
%>
<script language="javascript" type="text/javascript">

    jQuery.noConflict();
    arAbasGenerico = new Array();
    arAbasGenerico[0] = stAba('tdAbaAuditoria', 'divAuditoria');

    function voltar() {
        location.replace("ConsultaControlador?codTela=23");
    }

    function salva(acao) {
        if (!wasNull('especie,descricao'))
        {
            $("salvar").disabled = true;
            $("salvar").value = "Enviando...";
            if (acao == "atualizar")
                acao += "&id=<%=(carregaEs ? cadEs.getEs().getId() : 0)%>";
            document.location.replace("./cadespecie.jsp?acao=" + acao + "&" + concatFieldValue("especie,descricao, tipoPagamento,modelo") +
                    "&iscontabilidade=" + $('iscontabilidade').checked +
                    "&isfiscal=" + $('isfiscal').checked);
        } else
            alert("Preencha os campos corretamente!");
    }

    function excluir(id) {
        if (confirm("Deseja mesmo excluir esta espécie?"))
        {
            location.replace("./consulta_especie.jsp?acao=excluir&id=" + id);
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
        var rotina = "species";
        var dataDe = $("dataDeAuditoria").value;
        var dataAte = $("dataAteAuditoria").value;
        var id = <%=(carregaEs ? cadEs.getEs().getId() : 0)%>;
        console.log(id);
        consultarLog(rotina, id, dataDe, dataAte);

    }

    function setDataAuditoria() {

        $("dataDeAuditoria").value = "<%=carregaEs ? Apoio.getDataAtual() : ""%>";
        $("dataAteAuditoria").value = "<%=carregaEs ? Apoio.getDataAtual() : ""%>";

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

        <title>WebTrans - Cadastro de esp&eacute;cies</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style1 {font-size: 10px}
            -->
        </style>
    </head>

    <body onload="AlternarAbasGenerico('tdAbaAuditoria', 'divAuditoria');
        setDataAuditoria()">
        <img src="img/banner.gif" >
        <br>
        <table width="40%" align="center" class="bordaFina" >
            <tr>
                <td width="268">
                    <div align="left">
                        <b>Esp&eacute;cies</b>
                    </div>
                </td>
                <%  //se o paramentro vier com valor entao nao pode excluir
                if ((acao.equals("editar")) && (nivelUser >= 4) && (Boolean.parseBoolean(request.getParameter("ex")))) {%>
                <td width="63">
                    <input name="excluir" type="button" class="botoes" id="excluir" value="Excluir"
                           onClick="javascript:excluir(<%=(carregaEs ? cadEs.getEs().getId() : 0)%>)">
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
                <td width="20%" class="TextoCampos">Esp&eacute;cie:</td>
                <td width="15%" class="CelulaZebra2">
                    <input name="especie" type="text" id="especie" value="<%=(carregaEs ? cadEs.getEs().getEspecie() : "")%>" size="6" maxlength="3" class="inputtexto">    
                </td>
                <td width="20%" class="TextoCampos">Descri&ccedil;&atilde;o:</td>
                <td width="45%" class="CelulaZebra2">
                    <input name="descricao" type="text" id="descricao" value="<%=(carregaEs ? cadEs.getEs().getDescricao() : "")%>" size="30" maxlength="20" class="inputtexto">
                </td>
            </tr>
            <tr>
                <td class="TextoCampos" colspan="2">Tipo de pagamento CNAB:</td>
                <td class="CelulaZebra2" colspan="2">
                    <select id="tipoPagamento" name="tipoPagamento"  class="inputtexto" >                               
                        <option value ="n" selected>Não Informado</option>
                        <option value ="g" <%= (carregaEs && cadEs.getEs().getTipoPagamento() != null && cadEs.getEs().getTipoPagamento().equals("g") ? "selected" : "")%>>GPS</option>
                        <option value ="d" <%= (carregaEs && cadEs.getEs().getTipoPagamento() != null && cadEs.getEs().getTipoPagamento().equals("d") ? "selected" : "")%>>DARF NORMAL</option>
                        <option value ="s" <%= (carregaEs && cadEs.getEs().getTipoPagamento() != null && cadEs.getEs().getTipoPagamento().equals("s") ? "selected" : "")%>>DARF SIMPLES</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td colspan="4" class="TextoCampos">
                    <div align="center">
                        <input name="iscontabilidade" type="checkbox" id="iscontabilidade" value="checkbox" <%=(carregaEs && cadEs.getEs().isContabilidade() ? "checked" : "")%>>
                        Gera integra&ccedil;&atilde;o com a contabilidade 
                    </div>
                </td>
            </tr>
            <tr>
                <td colspan="4" class="TextoCampos">
                    <div align="center">
                        <input name="isfiscal" type="checkbox" id="isfiscal" value="checkbox" <%=(carregaEs && cadEs.getEs().isFiscal() ? "checked" : "")%>>
                        Gera integra&ccedil;&atilde;o com o fiscal 
                    </div>
                </td>
            </tr>
            <tr>
                <td class="TextoCampos" colspan="3">Modelo Documento SINTEGRA/SPED</td>
                <td class="CelulaZebra2">
                    <input name="modelo" type="text" id="modelo" value="<%=(carregaEs ? cadEs.getEs().getModeloSintegraSped() : "")%>" size="2" maxlength="3" class="inputtexto">
                </td>
            </tr>
        </table> 
        <table align="center" width="40%" >
            <tr>
                <td width="100%">
                    <table align="left">
                        <tr>
                            <td style='display:<%= carregaEs && nivelUser == 4 ? "" : "none"%>' id="tdAbaAuditoria" name="tdAbaAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAbaAuditoria', 'divAuditoria')"> Auditoria</td>
                        </tr>
                    </table>
                </td> 
            </tr>
        </table>
        <div id="divAuditoria" >

            <table width="40%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina" id="tableAuditoria" style='display: <%=carregaEs && nivelUser == 4 ? "" : "none"%>'>
                <%@include file="/gwTrans/template_auditoria.jsp" %>

            </table>
        </div>

        <br>
        <% if (nivelUser >= 2) {%>
        <table width="40%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
            <tr class="CelulaZebra2">
                <td colspan="6">
             
            <center>
                <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function () {
                                salva('<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>');
                            });">
            </center>
            <%}%>    
        </td>
    </tr>
</table>
<br>
</body>
</html>
