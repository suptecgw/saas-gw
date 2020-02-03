<%@ page contentType="text/html" language="java"
         import="nucleo.*,
         java.text.DecimalFormat,
         java.text.SimpleDateFormat,
         java.sql.ResultSet" errorPage="" %>
<%@page import="mov_banco.conta.BeanConsultaConta"%>
<%@page import="conhecimento.duplicata.factoring.BeanFactoring"%>
<%@page import="conhecimento.duplicata.factoring.BeanCadFactoring"%>
<%@page import="despesa.apropriacao.BeanApropDespesa"%>
<%@page import="conhecimento.duplicata.fatura.*"%>
<%@page import="java.util.Date"%>
<%@page import="filial.BeanFilial"%>
<%@page import="org.json.simple.JSONObject"%>


<script language="javascript" src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype_1_7_2.js" type="text/javascript"></script>
<script language="JavaScript" src="script/jquery.js" type="text/javascript"></script>
<script language="JavaScript" src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
<script language="JavaScript" src="script/LogAcoesAuditoria.js" type="text/javascript"></script>

<%
//Permissao do usuário nessa página
    int nivelUser = Apoio.getUsuario(request).getAcesso("lancamentofactoring");
    int nivelFatura = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("lanfatura") : 0);

//testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    //fim da MSA

    boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
    int idUsuario = Apoio.getUsuario(request).getIdusuario();

    String acao = request.getParameter("acao");
    BeanFactoring fac = new BeanFactoring();
    BeanCadFactoring cadFac = null;
    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");

    if (acao != null) {

        //instrucoes incomuns entre as acoes
        if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar") || acao.equals("visualizar") || acao.equals("excluir")) {//instanciando o bean de cadastro
            cadFac = new BeanCadFactoring();
            cadFac.setConexao(Apoio.getUsuario(request).getConexao());
            cadFac.setExecutor(Apoio.getUsuario(request));
        }

        if (acao.equals("excluir")) {
            cadFac.getFac().setId(Integer.parseInt(request.getParameter("id")));
            cadFac.Deleta();

            response.getWriter().append("err<=>" + cadFac.getErros());
            response.getWriter().close();
        }

        if (acao.equals("iniciar")) {
            cadFac = new BeanCadFactoring();
            cadFac.setConexao(Apoio.getUsuario(request).getConexao());
            cadFac.setExecutor(Apoio.getUsuario(request));
            cadFac = null;
        }

        //executando a acao desejada
        if ((acao.equals("editar")) && (request.getParameter("id") != null)) {
            int id = Integer.parseInt(request.getParameter("id"));
            fac.setId(id);
            //carregando os dados do cliente por completo(atributos, permissoes)
            cadFac.setFac(fac);
            cadFac.LoadAllPropertys();
        } else if (acao.equals("atualizar") || acao.equals("incluir")) {
            //populando o JavaBean

            fac.setDescontadaEm(Apoio.paraDate(request.getParameter("dtdesconto")));
            fac.getFactoring().setIdfornecedor(Integer.parseInt(request.getParameter("factoring_id")));
            fac.setObservacao(request.getParameter("observacao"));
            fac.getConta().setIdConta(Integer.parseInt(request.getParameter("conta")));
            fac.setValorDesconto(Double.parseDouble(request.getParameter("valorDesconto")));
            fac.setValorJuros(Double.parseDouble(request.getParameter("valorAcrescimo")));
            fac.setPercentualJuros(Apoio.parseDouble(request.getParameter("percentual"))); // 01-12-2013 - Paulo
            fac.getDespesa().setIdmovimento(Integer.parseInt(request.getParameter("iddespesa")));
            fac.getMovBanco().setIdLancamento(Integer.parseInt(request.getParameter("movBancoId")));
            fac.setNumeroBordero(request.getParameter("numeroBordero"));
            BeanApropDespesa[] aprop = new BeanApropDespesa[1];
            BeanApropDespesa ap = new BeanApropDespesa();
            ap.getPlanocusto().setIdconta(Integer.parseInt(request.getParameter("idplanocusto_despesa")));

            ap.getUndCusto().setId(Integer.parseInt(request.getParameter("id_und")));
            aprop[0] = ap;
            fac.getDespesa().setApropriacoes(aprop);
            //adicionando os ajudantes
            if (!request.getParameter("countFatura").equals("") && !request.getParameter("countFatura").equals("0")) {
                int countFatura = Integer.parseInt(request.getParameter("countFatura"));
                BeanFatura faturas[] = new BeanFatura[countFatura];
                int z = 0;
                for (int i = 0; i <= countFatura; ++i) {
                    if (request.getParameter("idFat" + i) != null) {
                        BeanFatura ft = new BeanFatura();
                        ft.setId(Integer.parseInt(request.getParameter("idFat" + i)));
                        faturas[z] = ft;
                        z++;
                    }
                }
                fac.setFatura(faturas);
            }

            boolean erro = false;
            if (acao.equals("atualizar")) {
                fac.setId(Integer.parseInt(request.getParameter("id")));
                cadFac.setFac(fac);
                erro = !cadFac.Atualiza();
            } else if (acao.equals("incluir") && nivelUser >= 3) {
                cadFac.setFac(fac);
                erro = !cadFac.Inclui();
            }

            // EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
            if (!acao.equals("excluir")) {
                String scr = "";
                if (erro) {
                    scr = "<script>"
                            + "window.opener.document.getElementById('gravar').disabled = false;"
                            + "window.opener.document.getElementById('gravar').value = 'Salvar';";
                    scr += "alert('" + cadFac.getErros() + "');";
                    scr += "window.close();"
                            + "</script>";
                    acao = (acao.equals("atualizar") ? "editar" : "iniciar");
                } else {// <-- Se nao teve erro redirecione para a consulta
                    scr = "<script>"
                            + "window.opener.document.location.replace('./jspconsulta_factoring.jsp?acao=iniciar');"
                            + "window.close();"
                            + "</script>";
                }
                response.getWriter().append(scr);
                response.getWriter().close();
            }
        }
        if (acao.equals("localizaFatura")) {
            BeanConsultaFatura consultaFatura = new BeanConsultaFatura();
            consultaFatura.setConexao(Apoio.getUsuario(request).getConexao());
            ResultSet rs = consultaFatura.LocalizaAjaxFactoring(request.getParameter("numeroFatura"), request.getParameter("anoFatura"));
            JSONObject jo = new JSONObject();

            if (rs != null && rs.next()) {
                for (int i = 1; i <= rs.getMetaData().getColumnCount(); ++i) {
                    if (rs.getString(i) != null) {
                        //se eh um tipo boolean(valor f ou t e inicia com "is")
                        if ((rs.getString(i).equals("f") || rs.getString(i).equals("t")) && rs.getMetaData().getColumnName(i).startsWith("is")) {
                            jo.put(rs.getMetaData().getColumnName(i), rs.getBoolean(i) + "");
                        } else {
                            jo.put(rs.getMetaData().getColumnName(i), rs.getString(i));
                        }
                    }
                }
                rs.close();
                response.getWriter().append(jo.toString().replace("\"false\"", "false").replace("\"true\"", "true"));
            } else {
                response.getWriter().append("load=0");
            }
            response.getWriter().close();
        }
    }
    boolean carregaFac = (cadFac != null && (!acao.equals("incluir") || !acao.equals("atualizar") || acao.equals("visualizar")));
%>
<script language="JavaScript" type="text/javascript">
    //Não sei bem o porque mas tenho que abrir uma tag do javascript com o src e fechá-la,
    //para usar as funções do arquivo .js tenho que abrir uma nova tag <script>

    //Quando o usuário clica em voltar
    jQuery.noConflict();

    function setAbaMF(menu, conteudo)
    {
        this.menu = menu;
        this.conteudo = conteudo;
    }

    arAbasMF = new Array();
    arAbasMF[0] = new setAbaMF('tdAbaFatura','divFatura');
    arAbasMF[1] = new setAbaMF('tdAbaAuditoria','divAuditoria');


    function AlterneAbaMF(menu, conteudo) {
        if (arAbasMF != null) {
            for (i = 0; i < arAbasMF.length; i++) {
                if (arAbasMF[i] != null && arAbasMF[i] != undefined) {
                    m = document.getElementById(arAbasMF[i].menu);
                    m.className = 'menu';
                    for (var j = 0, max = arAbasMF[i].conteudo.split(",").length; j < max; j++) {
                        c = document.getElementById(arAbasMF[i].conteudo.split(",")[j]);
                        if (c != null) {
                            invisivel(c, false);
                        } else if ($(arAbasMF[i].conteudo.split(",")[j].replace("div", "tr")) != null) {
                            invisivel($(arAbasMF[i].conteudo.split(",")[j].replace("div", "tr")), false);
                        }
                    }
                }
            }
            m = document.getElementById(menu);
            m.className = 'menu-sel';
            for (var i = 0, max = conteudo.split(",").length; i < max; i++) {
                c = document.getElementById(conteudo.split(",")[i]);
                if (c != null) {
                    visivel(c, false);
                } else if ($(conteudo.split(",")[i].replace("div", "tr")) != null) {
                    visivel($(conteudo.split(",")[i].replace("div", "tr")), false);
                }
            }
        } else {
            alert("Inicialize a variavel arAbasGenerico!");
        }
    }

    function voltar() {
        parent.document.location.replace("./jspconsulta_factoring.jsp?acao=iniciar");
    }

    //Salva as informações digitadas
    function salva(acao) {
        console.log("AAAAAAAAAAAA acao: " + acao);
        //Validando campos em branco

//        alert($('factoringId').value);
        if ($('factoring_id').value == '' || $('factoring_id').value == '0') {
            alert("Informe o agente de factoring corretamente.");
        } else if (parseFloat($('valorAcrescimo').value) != 0 && $('idplanocusto_despesa').value == '0') {
            alert("Informe a conta de plano de custo para geração da despesa do juros.");
        } else {
            $("gravar").disabled = true;
            $("gravar").value = "Enviando...";
            if (acao == "atualizar")
                acao += "&id=<%=(fac != null ? fac.getId() : 0)%>";

            $('formFat').action = "./cadmovimentacao_factoring.jsp?acao=" + acao + "&" + "countFatura=" + countFatura + "&" +
                    concatFieldValue('dtdesconto,factoring_id,valorDesconto,valorAcrescimo,conta,observacao,movBancoId,id_und,percentual,numeroBordero');
//            submitPopupForm($('formFat'));
            $('formFat').target = "pop";
            window.open('about:blank', 'pop', 'width=210, height=100');
            $('formFat').submit();
        }
    }

    function excluir(id) {
        if (confirm("Deseja mesmo excluir este contrato de factoring, fazendo isso o lançamento de crédito do banco também será apagado?")) {
            location.replace("./fatura_cliente?acao=excluir&id=" + id);
        }
    }

    var indexFatura = new Array();
    var countFatura = 0;
    var idContaUnica = '0';

    function localizaund() {
        post_cad = window.open('./localiza?acao=consultar&idlista=39', 'Unidade_de_custo',
                'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function limparund() {
        $("id_und").value = 0;
        $("sigla_und").value = "";
    }

    function addFatura(idFat, numeroFat, clienteFat, vencimentoFat, valorFat, nossoNumeroFat, valorDouble, idConta) {
        idContaUnica = (idContaUnica == undefined ? 0 : idContaUnica);
        if (idContaUnica == '0') {
            $('conta').value = (<%=!carregaFac%> && (idConta == 0 || idConta == undefined) ? $('conta').value : idConta);
            idContaUnica = idConta;
        } else {
            if (idContaUnica != idConta) {
                alert('Não será possível escolher essa fatura, a conta é diferente que a conta da fatura informada anteriormente');
                return null
            }
        }

        var indice = 1;
        countFatura++;
        indice = countFatura;

        for (var x = 1; x <= countFatura; x++) {
            if ($("idFat" + x) != null) {
                var id = $("idFat" + x).value;
                if (parseInt(id) == parseInt(idFat)) {
                    return false;
                }
            }
        }

        var vencimento = (vencimentoFat == undefined ? 'C/ Apres.' : vencimentoFat);

        var trLine = Builder.node("tr", {className: "CelulaZebra" + ((indice % 2) == 0 ? "1" : "2"), id: "trFatura" + indice, name: "trFatura" + indice});

        var tdLixo = Builder.node("td", {id: "tdFat0" + indice});
        var _img1 = Builder.node("img", {src: "img/lixo.png", onclick: "delFatura('" + indice + "');"});

        tdLixo.appendChild(_img1);
        trLine.appendChild(tdLixo);

        var tdNumero = Builder.node("td", {id: "tdFat1" + indice}, numeroFat);
        var inIdFatura = Builder.node("input", {type: "hidden", id: "idFat" + indice, name: "idFat" + indice, value: idFat});
        var inFaturaAno = Builder.node("input", {type: "hidden", id: numeroFat, name: numeroFat});
        var inValorFatura = Builder.node("input", {type: "hidden", id: "valorFatHid" + indice, name: "valorFatHid" + indice, value: valorDouble});

        tdNumero.appendChild(inIdFatura);
        tdNumero.appendChild(inValorFatura);
        tdNumero.appendChild(inFaturaAno);
        trLine.appendChild(tdNumero);

        var tdCliente = Builder.node("td", {id: "tdFat2" + indice}, clienteFat);
        trLine.appendChild(tdCliente);

        var tdVencimento = Builder.node("td", {id: "tdFat3" + indice}, vencimento);
        trLine.appendChild(tdVencimento);

        var tdValor = Builder.node("td", {id: "tdFat4" + indice}, valorFat);
        trLine.appendChild(tdValor);

        var tdNossoNumero = Builder.node("td", {id: "tdFat5" + indice}, nossoNumeroFat);
        trLine.appendChild(tdNossoNumero);

        getObj("corpoFatura").appendChild(trLine);

        CalculosAddFatura();
        calculaLiquido();

        if (nossoNumeroFat != '0' || nossoNumeroFat != '') {
            $('conta').disabled = true;
        }

    }

    var faturas;
    function incluirFaturaAjax() {
        var numeroAno = $("numeroFatura").value + "/" + $("anoFatura").value;

        if (countFatura != 0 && $(numeroAno) != null) {
            return alert("A Fatura/Boleto " + numeroAno + " já foi inclusa.");
        }

        function e(transport) {
            var resp = transport.responseText;

            espereEnviar("", false);

            //se deu algum erro na requisicao...
            if (resp == 'load=0') {
                alert('Fatura/Boleto não encontrado.');
                return false;
            } else {
                faturas = eval('(' + resp + ')');
                if (faturas.baixado == 't') {
                    alert('Essa fatura/boleto já encontra-se baixado.');
                    return null;
                } else if (faturas.situacao == 'DT') {
                    alert('Essa fatura/boleto já foi descontado anteriormente.');
                    return null;
                } else {
                    addFatura(faturas.fatura_id, faturas.numero_fatura + '/' + faturas.ano_fatura, faturas.consignatario, faturas.vencimento_fatura_br, faturas.valor_br, faturas.boleto_nosso_numero, faturas.valor_liquido_fatura, faturas.idconta);
                    $('numeroFatura').value = '';
                    $('numeroFatura').focus();
                }
            }
        }



        espereEnviar("", true);
        tryRequestToServer(function () {
            new Ajax.Request("./cadmovimentacao_factoring.jsp?acao=localizaFatura&numeroFatura=" + $('numeroFatura').value +
                    "&anoFatura=" + $('anoFatura').value, {method: 'post', onSuccess: e, onError: e});
        });
    }

    function CalculosAddFatura() {
        var totalFaturas = 0, valorTotal = 0;
        for (i = 0; i <= countFatura; ++i) {
            if ($('idFat' + i) != null) {
                totalFaturas++;
                valorTotal += parseFloat($("valorFatHid" + i).value);
            }
        }
        $("lbValorTotal").innerHTML = formatoMoeda(valorTotal);
        $("valorDesconto").value = formatoMoeda(valorTotal);
        $("lbQtdFaturas").innerHTML = totalFaturas;
    }

    function calculaLiquido() {
        $('lbliq').innerHTML = formatoMoeda(parseFloat($('valorDesconto').value) - parseFloat($('valorAcrescimo').value));
    }

    function aoCarregar() {
    <%if (carregaFac) {
            for (int u = 0; u < fac.getFatura().length; ++u) {
                BeanFatura ft = fac.getFatura()[u];%>
        addFatura(<%=ft.getId()%>, '<%=ft.getNumero() + "/" + ft.getAnoFatura()%>', '<%=ft.getCliente().getRazaosocial()%>', '<%=ft.getBoletoInstrucao1()%>', '<%=ft.getBoletoInstrucao2()%>', '<%=ft.getBoletoNossoNumero()%>', <%=ft.getValorAcrescimo()%>, <%=ft.getConta().getIdConta()%>);
    <%}
        }%>
    }

    function delFatura(idx) {
        if (confirm("Deseja mesmo remover a Fatura/Boleto desse desconto?")) {
            Element.remove('trFatura' + idx);
            CalculosAddFatura();
            calculaLiquido();
        }
    }
    // 01-12-2013 Paulo nova função para pegar o percentual

    function calcPercentual() {
        $('percentual').value = formatoMoeda(parseFloat(($('valorAcrescimo').value / $('valorDesconto').value) * 100));
    }

    // 27-11-2013 Paulo nova função para calcular porcentagem
    function calcValorPercentual(percentualJuros) {
        var totalJuros = (($("valorDesconto").value) * colocarPonto(percentualJuros)) / 100;
        $("valorAcrescimo").value = formatoMoeda(parseFloat(totalJuros));
    }

    //Selecionar faturas
    function selecionarFaturas() {
        launchPopupLocate("./seleciona_faturas_duplicatas.jsp?acao=");
    }

    function pesquisarAuditoria() {
        if (countLog != null || countLog != undefined) {
            for (var i = 1; i <= countLog; i++) {
                if ($("tr1Log") != null) {
                    Element.remove(("tr1Log" + i));
                }
                if ($("tr2Log") != null) {
                    Element.remove(("tr2Log" + i));
                }
            }
        }
        countLog = 0;
        var rotina = "movimentacao_factoring";
        var dataDe = $("dataDeAuditoria").value;
        var dataAte = $("dataAteAuditoria").value;
        var id = '<%= carregaFac ? cadFac.getFac().getId() : 0%>';
        consultarLog(rotina, id, dataDe, dataAte);
    }
    function setDataAuditoria() {
        $("dataDeAuditoria").value = "<%= Apoio.getDataAtual()%>";
        $("dataAteAuditoria").value = "<%= Apoio.getDataAtual()%>";
    }
</script>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">

        <title>WebTrans - Desconto de duplicatas em factoring</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="javascript:aoCarregar();
            setDataAuditoria();
            AlterneAbaMF('tdAbaFatura', 'divFatura')">

        <img src="img/banner.gif">
        <br>
        <input type="hidden" name="factoring_id" id="factoring_id" value="<%=(carregaFac ? fac.getFactoring().getIdfornecedor() : "0")%>">
        <input type="hidden" name="movBancoId" id="movBancoId" value="<%=(carregaFac ? fac.getMovBanco().getIdLancamento() : "0")%>">
        <input type="hidden" name="id_und" id="id_und" value="<%=(carregaFac ? fac.getDespesa().getApropriacoes()[0].getUndCusto().getId() : "0")%>">

        <table width="75%" align="center" class="bordaFina" >
            <tr>
                <td width="532" height="22">
                    <div align="left"><b>Desconto de duplicatas em factoring</b></div></td>
                <td width="81">
                    <%if ((acao.equals("editar")) && (nivelUser == 4) && (Boolean.parseBoolean(request.getParameter("ex")))) //se o paramentro vier com valor diferente de nulo ai pode excluir
                        {%>
                    <input  name="excluir" type="button" class="botoes" value="Excluir" alt="Exclui a fatura atual" onClick="javascript:excluir(<%=(carregaFac ? fac.getId() : 0)%>);"></td>
                    <%}%>
                <td width="8">&nbsp;</td>
                <td width="59"><input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:voltar();"></td>
            </tr>
        </table>
        <br>
        <form method="post" id="formFat">
            <table width="75%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr class="tabela">
                    <td height="15%" colspan="7" align="center">Dados principais </td>
                </tr>
                <tr>
                    <td width="10%" class="TextoCampos">Data cr&eacute;dito: </td>
                    <td width="20%" class="CelulaZebra2"><strong>
                            <input name="dtdesconto" type="text" id="dtdesconto" value="<%=(carregaFac ? fmt.format(fac.getDescontadaEm()) : Apoio.getDataAtual())%>" size="9" maxlength="10" class="fieldDate"
                                   onBlur="alertInvalidDate(this)" onKeyPress="fmtDate(this, event)" onKeyDown="fmtDate(this, event)" onKeyUp="fmtDate(this, event)" />
                        </strong></td>
                    <td class="TextoCampos" width="10%" ><strong>
                        </strong>Factoring:</td>
                    <td  width="30%" class="CelulaZebra2"><input name="factoring" type="text" id="factoring" value="<%=(carregaFac ? fac.getFactoring().getRazaosocial() : "")%>" size="40" maxlength="50" readonly="true" class="inputReadOnly">
                        <strong>
                            <input name="button" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=43', 'Factoring')" value="...">
                        </strong>
                    </td>
                    <td class="textoCampos" width="10%">Número do borderô: </td>
                    <td class="CelulaZebra2" width="30%">
                        <input type="text" class="inputtexto" id="numeroBordero" name="numeroBordero" size="30" maxlength="30" value="<%= carregaFac && fac.getNumeroBordero()  != null ? fac.getNumeroBordero() : "" %>">
                    </td>
                </tr>
            </table>
            <table width="75%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr>
                    <td width="100%" colspan="8">
                        <table align="left">
                            <tr>
                                <td width="20%" id="tdAbaFatura" name="tdAbaFatura" class="menu-sel" onclick="AlterneAbaMF('tdAbaFatura', 'divFatura')">Fatura</td>
                                <td width="20%" style='display: <%= carregaFac && nivelUser == 4 ? "" : "none"%>' id="tdAbaAuditoria" name="tdAbaAuditoria" class="menu" onclick="AlterneAbaMF('tdAbaAuditoria', 'divAuditoria')">Auditoria</td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td width="100%" >
                        <div id="divFatura">                
                            <table width="100%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">            
                                <tr>
                                    <td colspan="7" class="tabela"><div align="center">Faturas deste contrato</div></td>
                                </tr>
                                <tr style="display:'<%=(carregaFac && fac.getMovBanco().getConciliado() ? "none" : "")%>'">
                                    <td colspan="2" class="TextoCampos">Informe o número da fatura:</td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="numeroFatura" type="text" id="numeroFatura" value="" onKeyPress="javascript:if (event.keyCode == 13)
                                                    incluirFaturaAjax();" size="6" maxlength="6" class="inputtexto">
                                        <input name="anoFatura" type="text" id="anoFatura" value="" onKeyPress="javascript:if (event.keyCode == 13)
                                                    incluirFaturaAjax();" size="3" maxlength="4" class="inputtexto">
                                        e tecle enter 
                                    </td>
                                    <td colspan="3" class="CelulaZebra2">
                                        <input type="button" value="Selecionar Faturas" class="inputbotao" onclick="javascript:selecionarFaturas();" >
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="7">
                                        <table width="100%">
                                            <tbody id="corpoFatura">
                                                <tr class="celula">
                                                    <td width="3%"></td>
                                                    <td width="12%">Número</td>
                                                    <td width="48%">Cliente</td>
                                                    <td width="10%">Vencimento</td>
                                                    <td width="10%">Valor</td>
                                                    <td width="17%">Nosso número</td>
                                                </tr>
                                            </tbody>	
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="7">
                                        <table width="100%">
                                            <tr class="celula">
                                                <td width="23%"><div align="right">Total de Faturas:</div></td>
                                                <td width="28%"><b><label id="lbQtdFaturas">0,00</label></b></td>
                                                <td width="22%"><div align="right">Valor total:</div></td>
                                                <td width="10%"><b><label id="lbValorTotal">0,00</label></b></td>
                                                <td width="17%">&nbsp;</td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr class="tabela">
                                    <td colspan="7" align="center">Dados do pagamento </td>
                                </tr>
                                <tr>
                                    <td colspan="7">
                                        <table width="100%">
                                            <tr>
                                                <td width="8%" class="TextoCampos">Total:</td>    
                                                <td width="10%" class="CelulaZebra2"><input name="valorDesconto" type="text" class="inputReadOnly" id="valorDesconto"  onBlur="javascript:seNaoFloatReset(this, '0.00');
                                                        calculaLiquido();" value="<%=(carregaFac ? Apoio.to_curr(fac.getValorDesconto()) : "0.00")%>" size="6" maxlength="12" readonly></td>    
                                                <td class="TextoCampos" width="8%" >% Juros:</td>
                                                <td class="CelulaZebra2" width="10%">
                                                    <%if (fac.getDespesa().getIdmovimento() != 0) {%>
                                                    <input name="percentual" type="text" class="inputReadOnly" readonly="" id="percentual" value="<%=(carregaFac ? Apoio.to_curr(fac.getPercentualJuros()) : "0.00")%>" size="7" maxlength="6" onchange="calcValorPercentual(this.value);" onkeypress="mascara(this, reais)" /></td>
                                                    <%} else {%>
                                        <input name="percentual" type="text" class="inputtexto" id="percentual" value="<%=(carregaFac ? Apoio.to_curr(fac.getPercentualJuros()) : "0.00")%>" size="7" maxlength="6" onchange="calcValorPercentual(this.value);" onkeypress="mascara(this, reais)" /></td>
                                        <%}%>
                                    <td width="8%" class="TextoCampos">Juros:</td>    
                                    <td width="10%" class="CelulaZebra2">
                                        <%if (fac.getDespesa().getIdmovimento() != 0) {%>
                                        <input class="inputReadOnly" readonly="" name="valorAcrescimo" type="text" id="valorAcrescimo"  onchange="javascript:seNaoFloatReset(this, '0.00');
                                                calculaLiquido();
                                                calcPercentual();" value="<%=(carregaFac ? Apoio.to_curr(fac.getValorJuros()) : "0.00")%>" size="6" maxlength="12"></td>    
                                        <%} else {%>
                                <input class="inputtexto" name="valorAcrescimo" type="text" id="valorAcrescimo"  onchange="javascript:seNaoFloatReset(this, '0.00');
                                        calculaLiquido();
                                        calcPercentual();" value="<%=(carregaFac ? Apoio.to_curr(fac.getValorJuros()) : "0.00")%>" size="6" maxlength="12"></td> 
                                <%}%>
                                <td width="8%" class="TextoCampos">Líquido:</td>    
                                <td width="10%" class="CelulaZebra2"><div align="center"><b>
                                            <label name="lbliq" id="lbliq">0,00</label>
                                        </b></div></td>    
                                <td width="12%" class="TextoCampos">Conta crédito:</td>    
                                <td width="34%" class="CelulaZebra2">
                                    <select name="conta" id="conta" class="inputtexto" style="width: 120px;">
                                        <%//Carregando todas as contas cadastradas
                                            BeanConsultaConta conta = new BeanConsultaConta();
                                            conta.setConexao(Apoio.getUsuario(request).getConexao());
                                            conta.mostraContas(0, false, limitarUsuarioVisualizarConta, idUsuario);
                                            ResultSet rsconta = conta.getResultado();%>
                                        <%while (rsconta.next()) {%>
                                        <option value="<%=rsconta.getString("idconta")%>" <%=(carregaFac && fac.getConta().getIdConta() == rsconta.getInt("idconta") ? "selected" : "")%>>
                                            <%=rsconta.getString("numero") + "-" + rsconta.getString("digito_conta") + " / " + rsconta.getString("banco")%>                                                                            
                                        </option><%}%>
                                    </select>                                
                                </td>    
                                </tr>
                            </table>
                    </td>
                </tr>
                <tr>
                    <td align="center" class="TextoCampos">Observação:</td>
                    <td colspan="6" class="CelulaZebra2"><textarea name="observacao" cols="70" rows="4" id="observacao" class="inputtexto"><%=(carregaFac ? fac.getObservacao() : "")%></textarea></td>
                </tr>
                <tr class="tabela">
                    <td colspan="7" align="center">Dados da despesa dos juros</td>
                </tr>
                <tr>
                    <td width="15%" class="TextoCampos"><label><%=(carregaFac ? "Despesa: " + fac.getDespesa().getIdmovimento() : "")%></label>
                        <input type="hidden" name="iddespesa" id="iddespesa" value="<%=(carregaFac ? fac.getDespesa().getIdmovimento() : 0)%>"></td>
                    <td width="25%" class="TextoCampos"><div align="right">Plano de custo do juros:</div></td>
                    <td width="25%" colspan="2" class="CelulaZebra2"><div align="left"><strong>
                                <input name="plcusto_descricao_despesa" type="text" id="plcusto_descricao_despesa" class="inputReadOnly8pt" size="30" maxlength="80" readonly="true" value="<%=(carregaFac ? fac.getDespesa().getApropriacoes()[0].getPlanocusto().getDescricao() : "")%>">
                                <input name="localiza_plano" type="button" class="botoes" id="localiza_plano" value="..." onClick="javascript:post_cad = window.open('./localiza?acao=consultar&idlista=20', 'Plano', 'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                <input type="hidden" name="idplanocusto_despesa" id="idplanocusto_despesa" value="<%=(carregaFac ? fac.getDespesa().getApropriacoes()[0].getPlanocusto().getIdconta() : 0)%>">
                            </strong></div>
                    </td>
                    <td width="15%" class="TextoCampos"><div align="right">Und. de custo:</div></td>
                    <td width="20%" colspan="2" class="CelulaZebra2"><div align="left"><strong>
                                <input name="sigla_und" type="text" id="sigla_und" class="inputReadOnly8pt" size="10" maxlength="80" readonly="true" value="<%=(carregaFac ? fac.getDespesa().getApropriacoes()[0].getUndCusto().getSigla() : "")%>">
                                <input name="localiza_plano" type="button" class="botoes" id="localiza_plano" value="..." onClick="javascript:post_cad = window.open('./localiza?acao=consultar&idlista=39', 'Unidade_Custo', 'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                            </strong></div>
                    </td>

                </tr>
            </table>
        </div>
    </td>
</tr>
<tr>
    <td width="100%">
        <div id="divAuditoria">                    
            <table width="100%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina" style='display: <%= carregaFac && nivelUser == 4 ? "" : "none"%>'>
                <tr>      
                    <td><%@include file="/gwTrans/template_auditoria.jsp" %></td>
                </tr>
                <tr>
                    <td colspan="7">
                        <table width="100%" border="0">
                            <tr>
                                <td width="13%" class="TextoCampos">Incluso:</td>
                                <td width="37%" class="CelulaZebra2">Em: <%=carregaFac && fac.getCreatedAt() != null ? fmt.format(fac.getCreatedAt()) : ""%>
                                    <br>
                                    Por: <%=carregaFac && fac.getCreatedAt() != null ? fac.getCreated_by().getNome() : ""%></td>
                                <td width="13%" class="TextoCampos">Alterado:</td>
                                <td width="37%" class="CelulaZebra2">Em: <%=(carregaFac && fac.getUpdatedAt() != null ? fmt.format(fac.getUpdatedAt()) : "")%><br>
                                    Por: <%=(carregaFac ? fac.getUpdated_by().getNome() : "")%></td>
                            </tr>
                        </table>                    
                    </td>
                </tr>

            </table>
        </div>  
    </td>
</tr>
</table>
<br/>
<table width="75%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
    <tr class="CelulaZebra2">
        <td colspan="7">
    <center>
        <%if (nivelUser >= 2) {
                if (acao.equals("iniciar") || (carregaFac && !fac.getMovBanco().getConciliado())) {%>
        <input name="gravar" type="button" class="botoes" id="gravar" value="Salvar" onClick="javascript:tryRequestToServer(function () {
                    salva('<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>');
                });">
        <%  } else {%>
        <label>Esse lançamento já foi conciliado, não pode mais ser alterado.</label>
        <%}
            }%>
    </center>
    </td>
    </tr>
</table>
</form>
</html>
