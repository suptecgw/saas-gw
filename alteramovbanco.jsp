<%@ page contentType="text/html" language="java"
         import="java.sql.ResultSet,
         mov_banco.conta.*,
         mov_banco.*,
         mov_banco.banco.*,
         mov_banco.talaocheque.ConsultaTalaoCheque,
         mov_banco.talaocheque.TalaoCheque,
         conhecimento.duplicata.*,
         nucleo.BeanConfiguracao,
         nucleo.BeanLocaliza,
         java.text.*,
         java.util.Date,
         java.util.Hashtable,
         java.util.Enumeration,
         nucleo.Apoio" errorPage="" %>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/jquery.js" type="text/javascript"></script>
<script language="JavaScript" src="script/LogAcoesAuditoria.js" type="text/javascript"></script>

<%

            BeanConfiguracao cfg = null;
            cfg = new BeanConfiguracao();
            cfg.setConexao(Apoio.getUsuario(request).getConexao());
            //Carregando as configurações
            cfg.CarregaConfig();
            int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("conbancaria") : 0);
            int nivelUserConta = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadconta") : 0);
            int nivelUserDespesaFilial = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("landespfl") : 0);
            
            boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
            int idUsuario = Apoio.getUsuario(request).getIdusuario();
            
            //testando se a sessao é válida e se o usuário tem acesso
            if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
                response.sendError(response.SC_FORBIDDEN);
            }
            //fim da MSA

            String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));

            SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
            BeanCadMovBanco cadBanco = null;
            BeanMovBanco mBanco = null;
            boolean carregaMov = false;
            if (acao.equals("editar")) {
                cadBanco = new BeanCadMovBanco();
                cadBanco.setConexao(Apoio.getUsuario(request).getConexao());
                cadBanco.setExecutor(Apoio.getUsuario(request));
                mBanco = new BeanMovBanco();
                mBanco.setIdLancamento(Integer.parseInt(request.getParameter("id") == null ? "0" : request.getParameter("id")));
                cadBanco.setBMovBanco(mBanco);
                cadBanco.LoadAllPropertys();
                carregaMov = true;
            }

            if (acao.equals("salvar")) {

                //Preechendo os dados do débito
                BeanMovBanco mb = new BeanMovBanco();
                mb.setIdLancamento(Integer.parseInt(request.getParameter("idlancamento")));
                mb.getConta().setIdConta(Integer.parseInt(request.getParameter("conta")));
                mb.setDtEntrada(formatador.parse(request.getParameter("data_entrada")));
                mb.setDtEmissao(formatador.parse(request.getParameter("data_emissao")));
                mb.setHistorico(request.getParameter("descricao_historico"));
                mb.setDocum(request.getParameter("docum"));
                mb.setConciliado(Boolean.parseBoolean(request.getParameter("isConciliado")));
                cadBanco = new BeanCadMovBanco();
                cadBanco.setConexao(Apoio.getUsuario(request).getConexao());
                cadBanco.setExecutor(Apoio.getUsuario(request));
                cadBanco.setBMovBanco(mb);

                boolean erroSalvar = cadBanco.AtualizaMovBanco();
                //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
                if (!erroSalvar) {
                    response.getWriter().append("err<=>" + cadBanco.getErros());
                } else {
                    response.getWriter().append("err<=>");
                }

                response.getWriter().close();
            }

%>


<script language="javascript" type="text/javascript">
    
    jQuery.noConflict();
    
    var arAbasDS = new Array();
    arAbasDS[0] = new setAba('tdPrincipal','divDados');
    arAbasDS[1] = new setAba('tdAbaAuditoria','divAuditoria');

    function setAba(menu, conteudo)
        {
            this.menu = menu;
            this.conteudo = conteudo;
        }

       function AlterneAba(menu, conteudo) {
        try {
            if (arAbasDS != null) {
                for (i = 0; i < arAbasDS.length; i++) {
                    if (arAbasDS[i] != null && arAbasDS[i] != undefined) {
                        m = document.getElementById(arAbasDS[i].menu);
                        m.className = 'menu';
                        for (var j = 0, max = arAbasDS[i].conteudo.split(",").length; j < max; j++) {
                            c = document.getElementById(arAbasDS[i].conteudo.split(",")[j]);
                            if (c != null) {
                                invisivel(c, false);
                            } else if ($(arAbasDS[i].conteudo.split(",")[j].replace("div", "tr")) != null) {
                                invisivel($(arAbasDS[i].conteudo.split(",")[j].replace("div", "tr")), false);
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
        } catch (e) {
            alert(e);
        }
    }
    
    function habilitaSalvar(opcao){
        getObj("salvar").disabled = !opcao;
        getObj("salvar").value = (opcao ? "Salvar" : "Enviando...");
    }

    function salvar(linhas){

        function ev(resp, codstatus) {
            if (codstatus==200 && resp=="err<=>"){
                alert('Cadastro realizado com sucesso.');
                window.opener.visualizar();
                window.close();
            }
            else{
                alert(resp.split("<=>")[1]);
                $('conta').disabled = true;
            }
        }
        if (! validaData(getObj("data_emissao").value)){
            alert('Informe a data de emissão corretamente.');
        }else if (! validaData(getObj("data_entrada").value)){
            alert('Informe a data de entrada corretamente.');
        }else{
            $('conta').disabled = false;
            requisitaAjax("./alteramovbanco.jsp?acao=salvar&"+concatFieldValue("idlancamento,conta,data_emissao,data_entrada,docum,descricao_historico")+"&isConciliado="+$('chk_conciliado').checked,ev);
        }
    }
    
    function setAuditoria() {
        try {
            if ($("dataDeAuditoria") != null && $("dataDeAuditoria") != undefined) {
                $("dataDeAuditoria").value = "<%=carregaMov ? Apoio.getDataAtual() : ""%>";
            }

            if ($("dataAteAuditoria") != null && $("dataAteAuditoria") != undefined) {
                $("dataAteAuditoria").value = "<%=carregaMov ? Apoio.getDataAtual() : ""%>";
            }
    
        } catch (e) {
            console.log(e);
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
        var rotina = "conciliacao_bancaria";
        var dataDe = $("dataDeAuditoria").value;
        var dataAte = $("dataAteAuditoria").value;
        var id = <%=carregaMov ? mBanco.getIdLancamento() : 0 %>;
        consultarLog(rotina, id, dataDe, dataAte);
    }

</script>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />
        

        <title>Webtrans - Alterar Lan&ccedil;amento banc&aacute;rio/caixa</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>
    <body onLoad="applyFormatter();AlterneAba('tdPrincipal', 'divDados');setAuditoria();">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
        </div>
        <table width="70%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Alterar Lan&ccedil;amento banc&aacute;rio/caixa</b></td>
            </tr>
        </table>

        <br>
        <table width="70%" align="center" cellpadding="2" cellspacing="1">
            <tr>
                <td width="100%">
                  <table align="left">
                       <tr>
                          <td id="tdPrincipal" class="menu-sel" onclick="AlterneAba('tdPrincipal', 'divDados')"> Dados da Movimentação Bancária/Caixa </td>
                          <td style='display: <%=carregaMov && nivelUser ==4 ? "" : "none" %>' id="tdAbaAuditoria" class="menu" onclick="AlterneAba('tdAbaAuditoria','divAuditoria')"> Auditoria</td>

                       </tr>
                    </table>
                </td> 
            </tr>
        </table>
        <div id="divDados" name="divDados">                    
        <table width="70%" border="0" class="bordaFina" align="center">
<!--            <tr class="tabela">
                <td colspan="6"><div align="center">Dados da Movimentação Bancária/Caixa</div>
                    <div align="center"></div></td>
            </tr>-->
            <tr>
                <td class="TextoCampos" width="10%" >Conta:</td>
                <td class="CelulaZebra2" width="20%" ><strong>
                        <select name="conta" id="conta" class="inputtexto" onchange="alterandoConta()" <%=carregaMov && cadBanco.getBMovBanco().isCheque() ? "disabled" : ""%>>
                            <% //variaveis da paginacao
                                        //Carregando todas as contas cadastradas
                                        BeanConsultaConta conta = new BeanConsultaConta();
                                        conta.setConexao(Apoio.getUsuario(request).getConexao());
                                        conta.mostraContas((nivelUserDespesaFilial > 1 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), false, limitarUsuarioVisualizarConta, idUsuario);
                                        ResultSet rsconta = conta.getResultado();
                    while (rsconta.next()) {%>
                            <option value="<%=rsconta.getString("idconta")%>" <%=(carregaMov && cadBanco.getBMovBanco().getConta().getIdConta() == rsconta.getInt("idconta") ? "selected" : "")%>><%=rsconta.getString("numero")%></option>
                            <%}%>
                        </select>
                    </strong></td>
                <td class="TextoCampos" width="15%" >Data de Emissão:</td>
                <td class="CelulaZebra2" width="15%">
                    <input name="data_emissao" type="text" id="data_emissao" style="font-size:8pt;" value="<%=(carregaMov ? formatador.format(cadBanco.getBMovBanco().getDtEmissao()) : "")%>" size="9" maxlength="10" onblur="alertInvalidDate(this)" class="fieldDate" >
                </td>
                <td class="TextoCampos" width="15%" >Data de Entrada:</td>
                <td class="CelulaZebra2" width="15%" >
                    <input name="data_entrada" type="text" id="data_entrada" style="font-size:8pt;" value="<%=(carregaMov ? formatador.format(cadBanco.getBMovBanco().getDtEntrada()) : "")%>" size="9" maxlength="10" onblur="alertInvalidDate(this)" class="fieldDate" >
                </td>
            </tr>
            <tr>
                <td class="TextoCampos" colspan="2" >
                    <div align="center">
                        <input name="chk_conciliado" id="chk_conciliado" type="checkbox" <%=(carregaMov && cadBanco.getBMovBanco().getConciliado() ? "checked" : "")%>>
                        Movimento Conciliado
                    </div>
                </td>
                <td class="TextoCampos">Valor:</td>
                <td class="CelulaZebra2">
                    <label>
                        <%=(carregaMov ? new DecimalFormat("#,##0.00").format(cadBanco.getBMovBanco().getValor()) : "0,00")%>
                        (<%=(carregaMov ? (cadBanco.getBMovBanco().getValor() >= 0 ? "Crédito" : "Débito") : "")%>)
                    </label>
                </td>
                <td class="TextoCampos">Usuário inclusão:</td>
                <td class="CelulaZebra2">
                    <label>
                        <%=(carregaMov ? cadBanco.getBMovBanco().getUsuario().getNome() : "")%>
                    </label>
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Documento:</td>
                <td class="CelulaZebra2">
                    <input name="docum" type="text" id="docum" value="<%=(carregaMov ? cadBanco.getBMovBanco().getDocum() : "")%>" style="font-size:8pt;" size="10" maxlength="15" class="<%=carregaMov && cadBanco.getBMovBanco().isCheque() ? "inputReadOnly" : "inputtexto"%>" <%=carregaMov && cadBanco.getBMovBanco().isCheque() ? "readOnly" : ""%>>
                    <input name="idlancamento" type="hidden" id="idlancamento" value="<%=(carregaMov ? cadBanco.getBMovBanco().getIdLancamento() : "0")%>">
                </td>
                <td colspan="4" class="TextoCampos">
                    <div align="center"><font color="red">
                            <%if (carregaMov && cadBanco.getBMovBanco().isCheque()) {%>
                            ATENÇÃO: O nº do documento e a conta bancária não poderão ser alterados, pois esse movimento trata-se de um pagamento em cheque.
                            <%}%>
                        </font></div>
                </td>

            </tr>
            <tr>
                <td class="TextoCampos">Hist&oacute;rico:</td>
                <td colspan="5" class="CelulaZebra2"><strong> </strong><strong>
                        <input name="descricao_historico" type="text" id="descricao_historico" value="<%=(carregaMov ? cadBanco.getBMovBanco().getHistorico() : "")%>" style="font-size:8pt;" size="80" class="inputtexto" >
                    </strong></td>
            </tr>
        </table>
        </div>  
         <div id="divAuditoria" name="divAuditoria">           
            <table width="70%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">           
            <tr> 
                <td><%@include file="/gwTrans/template_auditoria.jsp" %></td>
            </tr>
          </table>
        </div> 
        <table width="70%" border="0" class="bordaFina" align="center">
            <tr>
                <td width="100%" class="TextoCampos"> <div align="center">
                        <% if (nivelUser >= 2) {%>
                        <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salvar();});">
                        <%}%>
                    </div></td>
            </tr>
        </table>
    </body>
</html>