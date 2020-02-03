<%@ page contentType="text/html" language="java"
         import="planocusto.planocontas.*,
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
            ? Apoio.getUsuario(request).getAcesso("cadplanocontas") : 0);
    boolean souadm = Apoio.getUsuario(request).getSouAdm();
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(response.SC_FORBIDDEN);
    }
   //fim da MSA
%>

<%
    String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    boolean carregapc = false;
    CadPlanoContas cadPc = null;
    PlanoContas pc = null;

    if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar")) {     //instanciando o bean de cadastro
        pc = new PlanoContas();
        cadPc = new CadPlanoContas();
        cadPc.setConexao(Apoio.getUsuario(request).getConexao());
        cadPc.setExecutor(Apoio.getUsuario(request));
    }

    //executando a acao desejada
    if ((acao.equals("editar")) && (request.getParameter("id") != null)) {
        int id = Integer.parseInt(request.getParameter("id"));
        pc.setId(id);
        cadPc.setPlanoContas(pc);
        //carregando completo
        cadPc.LoadAllPropertys();
    } else if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir"))) {
        //populando o JavaBean
        pc.setCodigo(request.getParameter("codigo"));
        pc.setConta(request.getParameter("conta"));
        pc.setDescricao(request.getParameter("descricao"));
        pc.setNivel(Apoio.parseInt(request.getParameter("nivel")));     
        pc.setTipoConta(request.getParameter("tipoConta"));
        pc.setCodigoNatureza(request.getParameter("codNatureza"));
        pc.setContaReferenciada(request.getParameter("codContaReferenciada"));
        pc.setCnpjEstabelecimento(request.getParameter("cnpjEstabelecimento"));    
        if (acao.equals("atualizar")) {
            pc.setId(Integer.parseInt(request.getParameter("id")));
        }
      //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
        //3º teste de erro naquela acao executada.
        cadPc.setPlanoContas(pc);
        boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                ? cadPc.Inclui() : cadPc.Atualiza());

//EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
%><script language="javascript" type=""><%          if (erro) {
              acao = (acao.equals("atualizar") ? "editar" : "iniciar");
    %>alert('<%=(cadPc.getErros())%>');
    <%} else {%>
    location.replace('ConsultaControlador?codTela=22');
    <%}%>
</script>

<%}
    //variavel usada para saber se o usuario esta editando
    carregapc = (cadPc != null && (!acao.equals("incluir") || !acao.equals("atualizar")));
%>
<script language="javascript" type="text/javascript">
    jQuery.noConflict();
    arAbasGenerico = new Array();
    arAbasGenerico[0] = stAba('tdAbaAuditoria', 'divAuditoria');

    function voltar() {
        location.replace('ConsultaControlador?codTela=22');
    }

    function salva(acao) {
        if (!wasNull('codigo,conta,descricao'))
        {
            document.getElementById("salvar").disabled = true;
            document.getElementById("salvar").value = "Enviando...";  
            if (acao == "atualizar")
                acao += "&id=<%=(carregapc ? cadPc.getPc().getId() : 0)%>";
            document.location.replace("./cadplano_contas.jsp?acao=" + acao + "&" + concatFieldValue("codigo,conta,descricao, nivel,tipoConta, codNatureza,cnpjEstabelecimento,codContaReferenciada"));
        } else
            alert("Preencha os campos corretamente!");
    }

    function excluir(id) {
        if (confirm("Deseja mesmo excluir esta conta do plano de contas?"))
        {
            location.replace("./consulta_plano_contas.jsp?acao=excluir&id=" + id);
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
        var rotina = "plain_accounts";
        var dataDe = $("dataDeAuditoria").value;
        var dataAte = $("dataAteAuditoria").value;
        var id = <%=(carregapc ? cadPc.getPc().getId() : 0)%>;
        console.log(id);
        consultarLog(rotina, id, dataDe, dataAte);

    }

    function setDataAuditoria() {

        $("dataDeAuditoria").value = "<%=carregapc ? Apoio.getDataAtual() : ""%>";
        $("dataAteAuditoria").value = "<%=carregapc ? Apoio.getDataAtual() : ""%>";

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

        <title>WebTrans - Cadastro de Plano de Contas</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">

    </head>

    <body onload="AlternarAbasGenerico('tdAbaAuditoria', 'divAuditoria');setDataAuditoria()">
        <img src="img/banner.gif" >
        <br>
        <table width="40%" align="center" class="bordaFina" >
            <tr >
                <td width="268"><div align="left"><strong>Plano de contas </strong></div></td>
                <%  //se o paramentro vier com valor entao nao pode excluir
        if ((acao.equals("editar")) && (nivelUser >= 4) && (Boolean.parseBoolean(request.getParameter("ex")))) {%>
                <td width="63"><input name="excluir" type="button" class="botoes" id="excluir" value="Excluir"
                                      onClick="javascript:excluir(<%=(carregapc ? cadPc.getPc().getId() : 0)%>)"></td>
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
                <td class="TextoCampos">*C&oacute;digo:</td>
                <td colspan="2" class="CelulaZebra2"><input name="codigo" type="text" id="codigo" value="<%=(carregapc ? cadPc.getPc().getCodigo() : "")%>" size="15" maxlength="15" class="inputtexto"></td>
            </tr>
            <tr>
                <td class="TextoCampos">*Conta cont&aacute;bil:</td>
                <td colspan="2" class="CelulaZebra2"><input name="conta" type="text" id="conta" value="<%=(carregapc ? cadPc.getPc().getConta() : "")%>" size="20" maxlength="20" class="inputtexto"></td>
            </tr>
            <tr>
                <td class="TextoCampos">*Descri&ccedil;&atilde;o:</td>
                <td colspan="2" class="CelulaZebra2"><input name="descricao" type="text" id="descricao" value="<%=(carregapc ? cadPc.getPc().getDescricao() : "")%>" size="55" maxlength="60" class="inputtexto"></td>
            </tr>
            <tr>
                <td class="TextoCampos">*Tipo:</td>
                <td colspan="2" class="CelulaZebra2">
                    <select name="tipoConta" id="tipoConta"  class="inputtexto" >   
                        <option value="">--- Selecione</option>
                        <option value="A" <%=(carregapc && cadPc.getPc().getTipoConta().equals("A") ? "selected" : "")%>>Analítica</option>
                        <option value="S" <%=(carregapc && cadPc.getPc().getTipoConta().equals("S")? "selected" : "")%>>Sintética</option>
                    </select></td>
            </tr>
            <tr>
                <td class="TextoCampos">Nível:</td>
                <td colspan="2" class="CelulaZebra2"><input name="nivel" type="text" id="nivel" value="<%=(carregapc ? cadPc.getPc().getNivel(): "")%>" size="10" maxlength="10" class="inputtexto"></td>
            </tr>
             <tr>
                <td class="TextoCampos">*Código de Natureza da conta:</td>
                <td colspan="2" class="CelulaZebra2">
                    <select name="codNatureza" id="codNatureza"  class="inputtexto" >
                        <option value="">--- Selecione</option>
                        <option value="01" <%=(carregapc && cadPc.getPc().getCodigoNatureza().equals("01") ? "selected" : "")%>>Contas de ativo</option>
                        <option value="02" <%=(carregapc && cadPc.getPc().getCodigoNatureza().equals("02")? "selected" : "")%>>Contas de passivo</option>
                        <option value="03" <%=(carregapc && cadPc.getPc().getCodigoNatureza().equals("03")? "selected" : "")%>>Patrimônio líquido</option>
                        <option value="04" <%=(carregapc && cadPc.getPc().getCodigoNatureza().equals("04")? "selected" : "")%>>Contas de resultado</option>
                        <option value="05" <%=(carregapc && cadPc.getPc().getCodigoNatureza().equals("05")? "selected" : "")%>>Contas de compensação</option>
                        <option value="09" <%=(carregapc && cadPc.getPc().getCodigoNatureza().equals("09")? "selected" : "")%>>Outras</option>
                    </select></td>
            </tr>
            <tr>
                <td class="TextoCampos">Código da Conta Referenciada</td>
                <td colspan="2" class="CelulaZebra2"><input name="codContaReferenciada" type="text" id="codContaReferenciada" value="<%=(carregapc ? cadPc.getPc().getContaReferenciada(): "")%>" size="10" maxlength="10" class="inputtexto"></td>
            </tr>
            <tr>
                <td class="TextoCampos">CNPJ do Estabelecimento</td> 
                <td colspan="2" class="CelulaZebra2"><input name="cnpjEstabelecimento" type="text" id="cnpjEstabelecimento" value="<%=(carregapc ? cadPc.getPc().getCnpjEstabelecimento(): "")%>" size="10" maxlength="10" class="inputtexto"></td>
            </tr>
        </table> 
        <table align="center" width="40%" >
            <tr>
                <td width="100%">
                    <table align="left">
                        <tr>
                            <td style='display:<%= carregapc && nivelUser == 4 ? "" : "none"%>' id="tdAbaAuditoria" name="tdAbaAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAbaAuditoria', 'divAuditoria')"> Auditoria</td>
                        </tr>
                    </table>
                </td> 
            </tr>
        </table>
        <div id="divAuditoria" >

            <table width="40%" align="center" cellpadding="2" cellspacing="1" class="bordaFina" id="tableAuditoria" style='display: <%=carregapc && nivelUser == 4 ? "" : "none"%>'>
                <%@include file="/gwTrans/template_auditoria.jsp" %>

            </table>
        </div>

        <br>
        <% if (nivelUser >= 2) {%>
        <table width="40%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">       
            <tr class="CelulaZebra2">
                <td colspan="5">

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
