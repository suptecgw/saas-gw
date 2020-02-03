<%@ page contentType="text/html" language="java"
         import="planocusto.unidadecusto.*,
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
            ? Apoio.getUsuario(request).getAcesso("cadundcusto") : 0);
    boolean souadm = Apoio.getUsuario(request).getSouAdm();
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(response.SC_FORBIDDEN);
    }
   //fim da MSA
%>

<%
    String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    boolean carregaUnd = false;
    CadUndCusto cadUnd = null;
    UndCusto und = null;

    if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar")) {     //instanciando o bean de cadastro
        und = new UndCusto();
        cadUnd = new CadUndCusto();
        cadUnd.setConexao(Apoio.getUsuario(request).getConexao());
        cadUnd.setExecutor(Apoio.getUsuario(request));
    }

    //executando a acao desejada
    if ((acao.equals("editar")) && (request.getParameter("id") != null)) {
        int id = Integer.parseInt(request.getParameter("id"));
        und.setId(id);
        cadUnd.setUnd(und);
        //carregando completo
        cadUnd.LoadAllPropertys();
    } else if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir"))) {
        //populando o JavaBean
        und.setSigla(request.getParameter("sigla"));
        und.setDescricao(request.getParameter("descricao"));
        if (acao.equals("atualizar")) {
            und.setId(Integer.parseInt(request.getParameter("id")));
        }
      //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
        //3º teste de erro naquela acao executada.
        cadUnd.setUnd(und);
        boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                ? cadUnd.Inclui() : cadUnd.Atualiza());

//EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
%><script language="javascript" type=""><%          if (erro) {
              acao = (acao.equals("atualizar") ? "editar" : "iniciar");
    %>alert('<%=(cadUnd.getErros())%>');
    <%} else {%>
    location.replace("ConsultaControlador?codTela=17");
    <%}%>
</script>

<%}
    //variavel usada para saber se o usuario esta editando
    carregaUnd = (cadUnd != null && (!acao.equals("incluir") || !acao.equals("atualizar")));
%>
<script language="javascript" type="text/javascript">

    jQuery.noConflict();

    arAbasGenerico = new Array();
    arAbasGenerico[0] = stAba('tdAbaAuditoria', 'divAuditoria');

    function voltar() {
        location.replace('ConsultaControlador?codTela=17');
    }

    function salva(acao) {
        if (!wasNull('sigla,descricao'))
        {
            $("salvar").disabled = true;
            $("salvar").value = "Enviando...";
            if (acao == "atualizar")
                acao += "&id=<%=(carregaUnd ? cadUnd.getUnd().getId() : 0)%>";
            document.location.replace("./cadunidade_custo.jsp?acao=" + acao + "&" + concatFieldValue("sigla,descricao"));
        } else
            alert("Preencha os campos corretamente!");
    }

    function excluir(id) {
        if (confirm("Deseja mesmo excluir esta unidade de custo?"))
        {
            location.replace("./consulta_unidade_custo.jsp?acao=excluir&id=" + id);
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
        var rotina = "coust_types";
        var dataDe = $("dataDeAuditoria").value;
        var dataAte = $("dataAteAuditoria").value;
        var id = <%=(carregaUnd ? cadUnd.getUnd().getId() : 0)%>;
        console.log(id);
        consultarLog(rotina, id, dataDe, dataAte);

    }

    function setDataAuditoria() {

        $("dataDeAuditoria").value = "<%=carregaUnd ? Apoio.getDataAtual() : ""%>";
        $("dataAteAuditoria").value = "<%=carregaUnd ? Apoio.getDataAtual() : ""%>";

    }
</script>
<%@page import="planocusto.unidadecusto.UndCusto"%>
<html>
    <head>
        <script language="javascript" src="script/funcoes.js" type=""></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">

        <title>WebTrans - Cadastro de unidades de custos</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style1 {font-size: 10px}
            -->
        </style>
    </head>

    <body onload="setDataAuditoria(), AlternarAbasGenerico('tdAbaAuditoria', 'divAuditoria')">
        <img src="img/banner.gif" >
        <br>
        <table width="40%" align="center" class="bordaFina" >
            <tr >
                <td width="268"><div align="left"><b>Cadastro de Unidades de custos</b></div></td>
                <%  //se o paramentro vier com valor entao nao pode excluir
        if ((acao.equals("editar")) && (nivelUser >= 4) && (Boolean.parseBoolean(request.getParameter("ex")))) {%>
                <td width="63"><input name="excluir" type="button" class="botoes" id="excluir" value="Excluir"
                                      onClick="javascript:excluir(<%=(carregaUnd ? cadUnd.getUnd().getId() : 0)%>)"></td>
                    <%}%>
                <td width="96" ><input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:voltar();"></td>
            </tr>
        </table>
        <br>
        <table width="40%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
            <tr class="tabela">
                <td colspan="4" align="center">Dados principais</td>
            </tr>
            <tr>
                <td width="15%" class="TextoCampos">Sigla:</td>
                <td width="20%" class="CelulaZebra2"><input name="sigla" type="text" id="sigla" value="<%=(carregaUnd ? cadUnd.getUnd().getSigla() : "")%>" size="8" maxlength="8" class="inputtexto">    </td>
                <td width="20%" class="TextoCampos">Descri&ccedil;&atilde;o:</td>
                <td width="45%" class="CelulaZebra2"><input name="descricao" type="text" id="descricao" value="<%=(carregaUnd ? cadUnd.getUnd().getDescricao() : "")%>" size="30" maxlength="40" class="inputtexto"></td>
            </tr>
        </table>
        <table align="center" width="40%" >
            <tr>
                <td width="100%">
                    <table align="left">
                        <tr>
                            <td style='display:<%= carregaUnd && nivelUser == 4 ? "" : "none"%>' id="tdAbaAuditoria" name="tdAbaAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAbaAuditoria', 'divAuditoria')"> Auditoria</td>
                        </tr>
                    </table>
                </td> 
            </tr>
        </table>
        <div id="divAuditoria" >

            <table width="40%" align="center" cellpadding="2" cellspacing="1" class="bordaFina" id="tableAuditoria" style='display: <%=carregaUnd && nivelUser == 4 ? "" : "none"%>'>
                <%@include file="/gwTrans/template_auditoria.jsp" %>

            </table>
        </div>

        <br>
        <table width="40%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
            <tr class="CelulaZebra2">
                <td colspan="6">
                    <% if (nivelUser >= 2) {%>
            <center>
                <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function () {
                      salva('<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>');
                  });">
            </center>
            <%}%>    </td>
    </tr>
</table>
    <br>
</body>
</html>