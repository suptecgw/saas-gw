<%@ page contentType="text/html" language="java"
         import="cliente.tipoProduto.*,
         java.sql.ResultSet,
         nucleo.Apoio" errorPage="" %>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
    // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
    int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadtipoproduto") : 0);
    boolean souadm = Apoio.getUsuario(request).getSouAdm();
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    //fim da MSA
%>

<%
    String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    boolean carregatp = false;
    CadTipoProduto cadTp = null;
    TipoProduto tp = null;

    if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar")) {
        //instanciando o bean de cadastro
        tp = new TipoProduto();
        cadTp = new CadTipoProduto();
        cadTp.setConexao(Apoio.getUsuario(request).getConexao());
        cadTp.setExecutor(Apoio.getUsuario(request));
    }

    //executando a acao desejada
    if ((acao.equals("editar")) && (request.getParameter("id") != null)) {
        int id = Integer.parseInt(request.getParameter("id"));
        tp.setId(id);
        cadTp.setTp(tp);
        //carregando completo
        cadTp.LoadAllPropertys();
    } else if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir"))) {
        //populando o JavaBean
        tp.setDescricao(request.getParameter("descricao"));
        tp.setCodigoTarifaAereo(request.getParameter("codigo"));
        tp.setUtilizacao(request.getParameter("modalUtilizacao")); 
        
        if (acao.equals("atualizar")) {
            tp.setId(Integer.parseInt(request.getParameter("id")));
        }
        //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
        //3º teste de erro naquela acao executada.
        cadTp.setTp(tp);
        boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                ? cadTp.Inclui() : cadTp.Atualiza());

//EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
%><script language="javascript" type=""><%          if (erro) {
        acao = (acao.equals("atualizar") ? "editar" : "iniciar");
    %>alert('<%=(cadTp.getErros())%>');
    <%} else {%>
    location.replace("./consulta_tipoproduto.jsp?acao=iniciar");
    <%}%>
</script>

<%}

    if (acao.equals("carregaTipos")) {
        String resultado = "";
        int cliente = (request.getParameter("cliente") == null ? 0 : Integer.parseInt(request.getParameter("cliente")));
        ConsultaTipoProduto con = new ConsultaTipoProduto();
        con.setConexao(Apoio.getUsuario(request).getConexao());
        ResultSet rs = con.CarregaTiposCliente(cliente);
        if (rs == null) {
            resultado = "null";
        } else {
            resultado = "<option value=0>Nenhum</option>";
            while (rs.next()) {
                resultado += "<option value='" + rs.getString("id") + "'>" + rs.getString("descricao") + "</option>";
            }
        }
        response.getWriter().append(resultado);
        response.getWriter().close();
    }

    //variavel usada para saber se o usuario esta editando
    carregatp = (cadTp != null && (!acao.equals("incluir") || !acao.equals("atualizar")));
%>
<script language="javascript" type="text/javascript">
jQuery.noConflict();

arAbasGenerico = new Array();
arAbasGenerico[0] = new stAba('tdAbaAuditoria', 'divAuditoria');

function voltar() {
    location.replace("./consulta_tipoproduto.jsp?acao=iniciar");
}

function salva(acao) {
    if (!wasNull('descricao'))
    {
        document.getElementById("salvar").disabled = true;
        document.getElementById("salvar").value = "Enviando...";
        if (acao == "atualizar")
            acao += "&id=<%=(carregatp ? cadTp.getTp().getId() : 0)%>";
        document.location.replace("./cadtipoproduto.jsp?acao=" + acao + "&" + concatFieldValue("descricao,codigo,modalUtilizacao"));
    } else
        alert("Preencha os campos corretamente!");
}

function excluir(id) {
    if (confirm("Deseja mesmo excluir este tipo de produto?"))
    {
        location.replace("./consulta_tipoproduto.jsp?acao=excluir&id=" + id);
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
    var rotina = "product_types";
    var dataDe = $("dataDeAuditoria").value;
    var dataAte = $("dataAteAuditoria").value;
    var id = <%=(carregatp ? cadTp.getTp().getId() : 0)%>;
    consultarLog(rotina, id, dataDe, dataAte);

}

function setAuditoria() {
    $("dataDeAuditoria").value = "<%=carregatp ? Apoio.getDataAtual() : ""%>";
    $("dataAteAuditoria").value = "<%=carregatp ? Apoio.getDataAtual() : ""%>";

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

        <title>WebTrans - Cadastro de tipos de produtos / operações</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style1 {font-size: 10px}
            -->
        </style>
    </head>

    <body onload="setAuditoria();AlternarAbasGenerico('tdAbaAuditoria', 'divAuditoria')">
        <img src="img/banner.gif" >
        <br>
        <table width="40%" align="center" class="bordaFina" >
            <tr >
                <td width="268"><div align="left"><b>Tipos de produtos / operações</b></div></td>
                <%  //se o paramentro vier com valor entao nao pode excluir
                    if ((acao.equals("editar")) && (nivelUser >= 4) && (Boolean.parseBoolean(request.getParameter("ex")))) {%>
                <td width="63"><input name="excluir" type="button" class="botoes" id="excluir" value="Excluir"
                                      onClick="javascript:excluir(<%=(carregatp ? cadTp.getTp().getId() : 0)%>)"></td>
                    <%}%>
                <td width="74" ><input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:voltar();"></td>
            </tr>
        </table>
        <br>
        <table width="40%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
            <tr class="tabela">
                <td colspan="3" align="center">Dados principais</td>
            </tr>
            <tr>
                <td class="TextoCampos">*Descrição:</td>
                <td colspan="2" class="CelulaZebra2"><input name="descricao" type="text" id="descricao" value="<%=(carregatp ? cadTp.getTp().getDescricao() : "")%>" size="40" maxlength="60" class="inputtexto"></td>
            </tr>
            <tr>
                <td class="TextoCampos">Código:</td>
                <td colspan="2" class="CelulaZebra2"><input name="codigo" type="text" id="codigo" value="<%=(carregatp ? cadTp.getTp().getCodigoTarifaAereo() : "")%>" size="3" maxlength="3" class="inputtexto">
                    Código da tarifa, apenas para frete aéreo.</td>
            </tr>
            <tr>
                <td class="TextoCampos">Utilização:</td>
                <td colspan="2" class="CelulaZebra2">
                  <select  id="modalUtilizacao" name="modalUtilizacao" style="font-size:8px;" class="fieldMin">
                     <option value="0"<%=(carregatp ? (cadTp.getTp().getUtilizacao().equals("0") ? "selected" : "") : "")%>>Tabela de preço com o cliente</option>
                     <option value="1"<%=(carregatp ? (cadTp.getTp().getUtilizacao().equals("1") ? "selected" : "") : "")%>>Tabela de preço com a companhia aérea</option>
                     <option value="2"<%=(carregatp ? (cadTp.getTp().getUtilizacao().equals("2") ? "selected" : "") : "")%>>Ambos</option> 
                  </select>
                </td>
            </tr>
        </table>  
        <table width="40%" align="center" cellpadding="2" cellspacing="1">
            <tr>
                <td width="100%">
                    <table align="left">
                        <tr>
                            <td style='display: <%= carregatp && nivelUser == 4 ? "" : "none"%>' id="tdAbaAuditoria" name="tdAbaAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAbaAuditoria', 'divAuditoria')"> Auditoria</td>

                        </tr>
                    </table>
                </td> 
            </tr>
        </table>

        <div id="divAuditoria" name="divAuditoria" style='display: <%= carregatp && nivelUser == 4 ? "" : "none"%>' >
            <table width="40%" align="center" class="bordaFina" id="tableAuditoria">
                <%@include file = "./gwTrans/template_auditoria.jsp" %>
            </table>
        </div> 
        <br/>
        <table width="40%" align="center" class="bordaFina" >                  
            <tr class="CelulaZebra2">
                <td colspan="5">
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

