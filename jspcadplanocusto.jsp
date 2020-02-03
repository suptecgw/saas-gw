<%@ page contentType="text/html" language="java"
         import="java.sql.ResultSet,
         planocusto.BeanCadPlanoCusto,
         nucleo.BeanConfiguracao,
         nucleo.BeanLocaliza,
         nucleo.Apoio" errorPage="" %>
<script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
    // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
    int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadplanocusto") : 0);
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(response.SC_FORBIDDEN);
    }
   //fim da MSA
%>
<%
    //Carregando configuracao
    BeanConfiguracao cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    cfg.CarregaConfig();

    String acao = (request.getParameter("acao") == null && nivelUser > 0 ? "" : request.getParameter("acao"));
    boolean carregaconta = false;
    BeanCadPlanoCusto beanplano = null;
    String estruturaplano = "";

    if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar") || acao.equals("iniciar")) {     //instanciando o bean de cadastro
        beanplano = new BeanCadPlanoCusto();
        beanplano.setConexao(Apoio.getUsuario(request).getConexao());
        beanplano.setExecutor(Apoio.getUsuario(request));

        if ((acao.equals("editar")) && (request.getParameter("id") != null)) {
            int idconta = Integer.parseInt(request.getParameter("id"));
            beanplano.setIdconta(idconta);
            beanplano.LoadAllPropertys();
        } else if (nivelUser >= 2 && acao.equals("atualizar") || acao.equals("incluir")) {
            beanplano.setConta(request.getParameter("codconta"));
            beanplano.setDescricao(request.getParameter("desc"));
            beanplano.setIsProvisao(Boolean.parseBoolean(request.getParameter("isprovisao")));
            beanplano.setIsTransitoria(Boolean.parseBoolean(request.getParameter("istransitoria")));
            beanplano.getPlanoConta().setId(Integer.parseInt(request.getParameter("plano_contas_id")));
            beanplano.getPlanoConta().setDescricao(request.getParameter("plano_conta_descricao"));
            beanplano.getHistorico().setIdHistorico(Integer.parseInt(request.getParameter("historico_id")));
            beanplano.setIsVisualizarOrcamentacao(Apoio.parseBoolean(request.getParameter("isvisualizarorcamentacao")));
            beanplano.setIsObrigaVeiculoDespesa(Apoio.parseBoolean(request.getParameter("obrigaVeiculoDespesa")));
            beanplano.setIsMostrarAnaliseVeiculo(Apoio.parseBoolean(request.getParameter("isMostrarAnaliseVeiculo")));
            beanplano.setTipoDataAnalise(request.getParameter("tipoDataAnalise").charAt(0));
            beanplano.setObservacao(request.getParameter("observacao"));
            beanplano.setAtivo(Apoio.parseBoolean(request.getParameter("is_ativo")));
            beanplano.setIsBloquearLancamento(Apoio.parseBoolean(request.getParameter("is_bloquear_lancamento")));
            // se for uma estrutura absoluta entaum vai ser setado senao vai ser obtido na sql
            if (beanplano.getConta().indexOf(".") < 0) {
                beanplano.setTipo(request.getParameter("tip").charAt(0));
            }

            if (acao.equals("atualizar")) {
                beanplano.setIdconta(Integer.parseInt(request.getParameter("id")));
            } else if (acao.equals("incluir")) {
                //quando o plano cadastrado em uma nova estrutura está mais alto que a configuração.
                    if ( Apoio.parseInt(cfg.getEstruturaplano().substring(0,cfg.getEstruturaplano().indexOf(".")))
                            < Apoio.parseInt(beanplano.getConta())) {
                        beanplano.setErros("Estrutura da conta diferente da informada em configurações.");
                    }
            }
            
            boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                    ? (beanplano.getErros().equals("") ? beanplano.Inclui() : false) : beanplano.Atualiza());

            //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
%><script language="javascript" type=""><%                if (erro) {
                    acao = (acao.equals("atualizar") ? "editar" : "iniciar");
    %>alert('<%=(beanplano.getErros())%>');
    <%} else {%>
    location.replace("ConsultaControlador?codTela=21");
    <%}%>
</script><%
                     } else if (acao.equals("iniciar")) {
                         estruturaplano = cfg.getEstruturaplano();
                     }

                 }

                 //variavel usada para saber se o usuario esta editando
                 carregaconta = (beanplano != null) && (beanplano.getDescricao() != null)
                         && (!acao.equals("incluir") || !acao.equals("atualizar"));
%>
<script language="javascript" type="text/javascript">

    jQuery.noConflict();

    arAbasGenerico = new Array();
    arAbasGenerico[0] = new stAba('tdPrincipal', 'divIntegracaoContabil');
    arAbasGenerico[1] = new stAba('tdInformacoesRelatorios', 'divInformacoesRelatorios');
    arAbasGenerico[2] = new stAba('tdAbaAuditoria', 'divAuditoria');
    
    function voltar() {
        document.location.replace("ConsultaControlador?codTela=21");
    }

    function salva(acao) {
        if (!wasNull('contapai,desc,codconta' + ($("tr_tipo").style.display == "" ? ',tip' : ''))) {
            $("salvar").disabled = true;
            $("salvar").value = "Enviando...";

            if (acao == "atualizar")
                acao += "&id=<%=(carregaconta ? beanplano.getIdconta() : 0)%>";
            document.location.replace("./cadplanocusto?acao=" + acao +
                    "&codconta=" + $("codconta").value +
                    "&desc=" + $("desc").value +
                    "&isprovisao=" + $("isprovisao").checked +
                    "&istransitoria=" + $("chkTransitoria").checked +
                    "&plano_contas_id=" + $("plano_contas_id").value +
                    "&historico_id=" + $("idhist").value +
                    "&tip=" + $("tip").value +
                    "&isvisualizarorcamentacao=" + $("isvisualizarorcamentacao").checked +
                    "&obrigaVeiculoDespesa=" + $("obrigaVeiculoDespesa").checked +
                    "&isMostrarAnaliseVeiculo=" + $("isMostrarAnaliseVeiculo").checked +
                    "&tipoDataAnalise="+ $("tipoDataAnalise").value +
                    "&observacao="+ $("observacao").value +
                    "&is_ativo=" + $("is_ativo").checked +
                    "&is_bloquear_lancamento=" + $("is_bloquear_lancamento").checked);
        } else
            alert("Preencha os campos corretamente!");
    }

    function excluir(idconta)
    {
        if (confirm("Deseja mesmo excluir?"))
        {
            location.replace("./consultaplano?acao=excluir&id=" + idconta);
        }
    }

    function inczero(expr, qtzeros) {
        if (qtzeros <= 0)
            return expr;
        for (i = 1; i <= qtzeros; ++i)
            expr = '0' + expr;
        return expr;
    }

    function deczero(expr) {
        while (expr.substring(0, 1) == "0")
            expr = expr.substring(1, expr.length);
        return expr;
    }

    function iniciacad() {
        var sel = $("contapai");
        var est = "<%=estruturaplano%>";

        if (sel.value == "") {
            $("tr_tipo").style.display = "none";
            $("codconta").value = "";
            return null;
        }
        if (sel.value == "nova")
        {
            var aux = sel.options[sel.options.length - 2].value;
    <%//se é a primeira estrutura absoluta%>
            if (aux == "")
            {
                for (i = 0; i < est.substring(0, est.indexOf(".")).length; ++i)
                    aux += "0";
                incnumerador(aux);
            } else
                aux = aux.substring(0, (aux.indexOf('.') < 0 ? aux.length : aux.indexOf('.')));
    <%//mostrando a opcao de tipo%>
            $("tr_tipo").style.display = "";
            $("codconta").value = incnumerador(aux);
            return null;
        }
    <%//ocultando a opcao de tipo%>
        $("tr_tipo").style.display = "none";
        var i = 0;
    <%//se a conta for um nivel acima da analitica, vai poder usar a ultima conta analitica%>
        if (sel.value.length <= est.substring(0, est.lastIndexOf('.')).length) {
            while (sel.options[i] != null)
            {
                if (sel.options[i].value == sel.value)
                {
                    i++;
    <%//se so tiver uma estrutura...%>
                    if (sel.options[i].value.substring(0, sel.value.length) != sel.value)
                    {
                        var est = "<%=estruturaplano%>";
                        var digitos = est.substring(sel.value.length + 1, est.length);
                        digitos = digitos.substring(0, (digitos.indexOf('.') < 0 ? digitos.length : digitos.indexOf('.'))).length;
                        $("codconta").value = sel.value + "." + inczero('1', digitos - 1);
                        return;
                    }
    <% // enquanto a conta começar com a numeracao selecionada(p/ pegar a ultima)  %>
                    while (sel.options[i].value.substring(0, sel.value.length) == sel.value)
                        ++i;

                    var aux = sel.options[i - 1].value.substring(sel.value.length + 1, sel.options[i - 1].value.length);
    <%//se a conta nao tiver '.' entao vai seer o tamanho dela%>
                    aux = aux.substring(0, (aux.indexOf(".") < 0 ? aux.length : aux.indexOf(".")));
                    $("codconta").value = incnumerador(sel.value + "." + aux);
                    return;
                } else
                    i++;
            }//while
        } else
    <%//só chega aqui se a conta selecionada já trazer a ultima analitica%>
        $("codconta").value = incnumerador(sel.value);
    }

    function incnumerador(valoranterior) {
        var est = "<%=estruturaplano%>";
        //pegando a posicao do ultimo ponto
        var posUltimoPonto = (valoranterior.lastIndexOf('.') < 0 ? 0 : valoranterior.lastIndexOf('.') + 1);
        var ini = valoranterior.substring(0, valoranterior.lastIndexOf('.') + 1);

        //pegando o ultimo numero(o valor q vai ser incrementado)
        var num = deczero(valoranterior.substring(posUltimoPonto, valoranterior.length));
        num = parseInt((num == "" ? "0" : num)) + 1;
        //calculando a quantidade de zero
        tam = valoranterior.substring(posUltimoPonto, valoranterior.length).length;
        //convertendo para str
        num = "" + num;
        return ini + inczero(num, tam - num.length);
    }

    /*
     function incnumerador(valoranterior){
     var est = estruturaplano>";
     //pegando a posicao do ultimo ponto
     var posUltimoPonto = (valoranterior.lastIndexOf('.') < 0 ? 0 : valoranterior.lastIndexOf('.')+1);
     var ini = valoranterior.substring(0,valoranterior.lastIndexOf('.')+1);
     //pegando o ultimo numero(o valor q vai ser incrementado)
     var num = deczero(valoranterior.substring(posUltimoPonto, valoranterior.length));
     num = parseInt( (num == "" ? "0" : num) ) + 1;
     //calculando a quantidade de zero
     posUltimoPonto = valoranterior.substring(posUltimoPonto, valoranterior.length).length;
     //convertendo para string
     var tamNumero = ""+num;
     return ini + inczero(num, posUltimoPonto - tamNumero.length);
     }
     */
    function obrigaVeiculoDespesa() {

        var valorSelecionadoTipoConta = $("tip");

        var obrigaVeiculoDespesa = $("obrigaVeiculoDespesa");

        var tipoHidden;
        if ($("contapai") != null) {
            if ($($("contapai").options[$("contapai").selectedIndex].text) != null) {
                tipoHidden = ($($("contapai").options[$("contapai").selectedIndex].text).value);
                switch (tipoHidden) {
                    case "d":
                        $("tr_obrigaVeiculoDespesa").style.display = "";
                        valorSelecionadoTipoConta.value = "";
                        break;
                    case "r":
                        $("tr_obrigaVeiculoDespesa").style.display = "none";
                        valorSelecionadoTipoConta.value = "";
                        obrigaVeiculoDespesa.checked = false;
                        break;
                }
            } else {
                tipoHidden = null;
            }
            if ($("contapai").value == "") {
                $("tr_obrigaVeiculoDespesa").style.display = "none";
                obrigaVeiculoDespesa.checked = false;
            } else if ($("contapai").value == "nova") {
                if (valorSelecionadoTipoConta.value != "d") {
                    console.log("CONTA FILHO != D");
                    $("tr_obrigaVeiculoDespesa").style.display = "none";
                    obrigaVeiculoDespesa.checked = false;
                } else {
                    $("tr_obrigaVeiculoDespesa").style.display = "";
                }
            }
        }

        if ($("contapai") == null) {
            if (valorSelecionadoTipoConta.value != "d") {
                $("tr_obrigaVeiculoDespesa").style.display = "none";
                obrigaVeiculoDespesa.checked = false;
            } else {
                $("tr_obrigaVeiculoDespesa").style.display = "";
            }
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
        var rotina = "planocusto";
        var dataDe = $("dataDeAuditoria").value;
        var dataAte = $("dataAteAuditoria").value;
        var id = <%=(carregaconta ? beanplano.getIdconta() : 0)%>;
        console.log(rotina, id);
        consultarLog(rotina, id, dataDe, dataAte);

    }
    function setDataAuditoria() {
        $("dataDeAuditoria").value = "<%=carregaconta ? Apoio.getDataAtual() : ""%>";
        $("dataAteAuditoria").value = "<%=carregaconta ? Apoio.getDataAtual() : ""%>";

    }
    
    function localizarContaContabil(conta){
        
        jQuery.ajax({
            url: "./PlanoContaControlador?",
            dataType: "text",
            method : "post",
            async : false,
            data: {
                conta: conta,
                acao : "localizarContaContabil"
            },
            success: function(data) {
                var conta = jQuery.parseJSON(data);
                espereEnviar("",false);
                if (conta == null){
                    alert("Plano de contas não encontrado!");
                    return false;
                }else if(conta == ''){
                    alert("Plano de contas não encontrado!");
                    return false;
                }else if(conta.erro == 'true'){
                    alert("Plano de contas não encontrado!");
                    return false;
                }else{
                    $('plano_contas_id').value = conta.id;
                    $('cod_conta').value = conta.codigo;
                    $('plano_conta_descricao').value = conta.descricao;
                }
            },error: function(){
                alert("Plano de contas não encontrado!");
            }
        });
    }
    
    function limparConta(){
        $("cod_conta").value = "";
        $("plano_conta_descricao").value = "";
        $("plano_contas_id").value = "0";
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

        <title>WebTrans - Cadastro</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onload="obrigaVeiculoDespesa();
            setDataAuditoria();
            AlternarAbasGenerico('tdPrincipal', 'divIntegracaoContabil');">
        <img src="img/banner.gif" alt="Sistema de Transportadora online">
        <br>
        <input type="hidden" id="plano_contas_id" value="<%=(carregaconta ? beanplano.getPlanoConta().getId() : 0)%>">
        <input type="hidden" id="idhist"         value="<%=(carregaconta ? beanplano.getHistorico().getIdhistorico() : 0)%>">
        <table width="45%" align="center" class="bordaFina" >
            <tr >
                <td width="613"><div align="left"><b>Cadastro de Plano Centro de Custo </b></div></td>
                <%  //se o paramentro vier com valor entao nao pode excluir
                    if ((acao.equals("editar")) && (nivelUser >= 4) && (Boolean.parseBoolean(request.getParameter("ex")))) {%>
                <td width="15"><input name="excluir" type="button" class="botoes" id="excluir" value="Excluir"
                                      onClick="javascript:excluir(<%=(carregaconta ? beanplano.getIdconta() : 0)%>)"></td>
                    <%}%>
                <td width="56" ><input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:voltar();"></td>
            </tr>
        </table>
        <br>
        <table width="45%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
            <tr class="tabela">
                <td height="21" colspan="4" align="center"><strong>Dados principais</strong>                </td>
            </tr>
            <%if (acao.equals("iniciar")) {%>
            <tr>
                <td width="106" class="TextoCampos">*Conta Pai:</td>
                <td width="292" class="CelulaZebra2">
                    <select name="contapai" id="contapai" onChange="javascript:iniciacad(this.value);
                            obrigaVeiculoDespesa();" class="inputtexto">
                        <option value="">--- Selecione</option><%
                            ResultSet lista = beanplano.getContasPai();
                            if (!lista.wasNull())
                                while (lista.next()) {
                                    String est = estruturaplano;//se a conta for um nivel acima da analitica, vai poder usar a ultima conta analitica
                                    if (est == null) {
                                        break;
                                    }
                                    int contaAcima = (est.lastIndexOf('.') == -1 ? est.length() : est.substring(0, est.lastIndexOf('.')).length());

                                %><option value="<%=((lista.getString("conta").length() == contaAcima)
                                        && (lista.getString("contaanalitica") != null) ? lista.getString("contaanalitica") : (lista.getString("conta")))%>">
                            <%=(lista.getString("conta") + " - " + lista.getString("descricao"))%>
                        </option><%
                            }%>
                        <option value="nova" style="background-color:#CCCCCC">Iniciar Estrutura</option>
                    </select>
                    <%
                        lista = beanplano.getContasPai();
                        if (!lista.wasNull()) {
                            while (lista.next()) {
                    %><input type="hidden" id="<%= lista.getString("conta") + " - " + lista.getString("descricao")%>" value="<%= lista.getString("tipo")%>"><%
                            }
                        }
                    %>
                </td>
                <td class="TextoCampos" width="10%">
                    <label>
                        <input name="is_ativo" type="checkbox" id="is_ativo" value="checkbox" <%=(!carregaconta || (carregaconta && beanplano.isAtivo()) ? "checked" : "")%>>
                        Ativo                        
                    </label>
                </td>
            </tr>
            <%}%>
            <tr>
                <td class="TextoCampos">C&oacute;digo da Conta:</td>
                <td class="CelulaZebra2" <%= (acao.equals("iniciar")) ? "colspan=\"2\"" : "" %>><input name="codconta" type="text" id="codconta" style="text-align:right" size="20" class="inputReadOnly"
                                                maxlength="20" readonly value="<%=(carregaconta ? beanplano.getConta() : "")%>"></td>
                
                <%if (!acao.equals("iniciar")) {%>
                    <td class="TextoCampos" width="10%">
                        <label>
                            <input name="is_ativo" type="checkbox" id="is_ativo" value="checkbox" <%=(!carregaconta || (carregaconta && beanplano.isAtivo()) ? "checked" : "")%>>
                            Ativo                        
                        </label>
                    </td>
                <%}%>
            </tr>
            <tr>
                <td class="TextoCampos">*Descri&ccedil;&atilde;o:</td>
                <td class="CelulaZebra2" colspan="2"><input name="desc" type="text" id="desc" size="35" maxlength="60" value="<%=(carregaconta ? beanplano.getDescricao() : "")%>" class="inputtexto"></td>
            </tr>
            <tr class="CelulaZebra2" style="<%=(carregaconta ? "" : "display:none")%>" id="tr_tipo">
                <td class="TextoCampos">*Tipo:</td>
                <td colspan="2"><select name="tip" id="tip" <%=(carregaconta ? "disabled" : "")%> class="inputtexto" onChange="javascript:obrigaVeiculoDespesa()">
                        <option value="">--- Selecione</option>
                        <option value="d" <%=(carregaconta && beanplano.getTipo() == 'd' ? "selected" : "")%>>Despesas</option>
                        <option value="r" <%=(carregaconta && beanplano.getTipo() == 'r' ? "selected" : "")%>>Receitas</option>
                    </select></td>
            </tr>
            <tr>
                <td class="TextoCampos">Observação do plano de custo:</td>
                <td class="CelulaZebra2" colspan="2"><input name="observacao" type="text" id="observacao" size="35" value="<%=(carregaconta ? beanplano.getObservacao(): "")%>" class="inputtexto"></td>
            </tr>
        </table>
        <table width="45%" align="center" cellpadding="2" cellspacing="1">
            <tr>
                <td width="100%">
                    <table align="left">
                        <tr>
                            <td id="tdPrincipal" class="menu-sel" onclick="AlternarAbasGenerico('tdPrincipal', 'divIntegracaoContabil')"> Integração com o Contábil </td>
                            <td id="tdInformacoesRelatorios" class="menu-sel" onclick="AlternarAbasGenerico('tdInformacoesRelatorios', 'divInformacoesRelatorios')"> Informações Gerenciais </td>
                            <td style='display: <%=carregaconta && nivelUser == 4 ? "" : "none"%>' id="tdAbaAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAbaAuditoria', 'divAuditoria')"> Auditoria</td>
                        </tr>
                    </table>
                </td> 
            </tr>
        </table>    
        <div id="divIntegracaoContabil">                           
            <table width="45%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">                
                <tr class="tabela" style=<%=(cfg.getIsContabil() ? "display:" : "display:none")%>>
                    <td height="20" colspan="2"><div align="center">Integração com o Contábil</div></td>
                </tr>
                <tr style=<%=(cfg.getIsContabil() ? "display:" : "display:none")%>>
                    <td height="17" colspan="2" class="TextoCampos"><p align="center">
                            <input name="isprovisao" type="checkbox" id="isprovisao" value="checkbox" <%=(carregaconta && beanplano.getIsProvisao() ? "checked" : "")%>>
                            Contabilizar provis&atilde;o desse P. centro de Custo </p>
                    </td>
                </tr>
                
                <tr style="display: none;" id="tr_obrigaVeiculoDespesa">
                    <td height="17" colspan="2" class="TextoCampos"><p align="center">
                            <input name="obrigaVeiculoDespesa" type="checkbox" id="obrigaVeiculoDespesa" value="checkbox" <%=(carregaconta && beanplano.isObrigaVeiculoDespesa() ? "checked" : "")%>>
                            Obrigar vinculo de ve&iacute;culo na apropria&ccedil&atilde;o das despesas.
                        </p>
                    </td>
                </tr>

                <tr style=<%=(cfg.getIsContabil() ? "display:" : "display:none")%>>
                    <td height="17" class="TextoCampos">Conta cont&aacute;bil:</td>
                    <td height="17" class="CelulaZebra2">
                        <input name="cod_conta" type="text" id="cod_conta" size="10"  class="inputTexto" value="<%=(carregaconta ? beanplano.getPlanoConta().getCodigo() : "")%>" onkeypress="if (event.keyCode==13) localizarContaContabil(this.value);">
                        <input type="text" class="inputReadOnly" id="plano_conta_descricao" name="plano_conta_descricao" size="25" value="<%=(carregaconta && beanplano != null ? beanplano.getPlanoConta().getDescricao():"")  %>" />
                        <strong>
                            <input name="localiza_conta" type="button" class="botoes" id="localiza_conta" value="..." 
                                   onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.PLANO_CONTAS%>', 'Plano_de_contas')">
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:limparConta();"></strong></td>
                </tr>
                <tr style=<%=(cfg.getIsContabil() ? "display:" : "display:none")%>>
                    <td height="17" class="TextoCampos">Hist&oacute;rico:</td>
                    <td height="17" class="CelulaZebra2"><input name="codigo_historico" type="text" class="inputReadOnly" id="codigo_historico" onBlur="javascript:seNaoIntReset(this, '0');" value="<%=(carregaconta ? beanplano.getHistorico().getCodigo_historico() : "")%>" size="2" maxlength="3">
                        <input type="button" class="botoes"  value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.HISTORICO_DE_LANCAMENTO%>', 'Historico')">
                        <img src="img/borracha.gif" width="27" height="20" border="0" align="absbottom" class="imagemLink" title="Limpar Hist&ograve;rico" onClick="getObj('descricao_historico').value = '';
                            getObj('idhist').value = '0';
                            getObj('codigo_historico').value = '';">
                        <input type="text" class="inputReadOnly" id="descricao_historico" value="<%=(carregaconta ? beanplano.getHistorico().getDescHistorico() : "")%>" size="20" readonly="readonly"></td>
                </tr>
                <tr style=<%=(cfg.getIsContabil() ? "display:" : "display:none")%>>
                    <td height="17" colspan="2" class="TextoCampos"><div align="center">O hist&oacute;rico ser&aacute; considerado apenas para lan&ccedil;amentos de 2&ordf;,3&ordf; e 4&ordf; f&oacute;rmulas.</div></td>
                </tr>
            </table> 
        </div>
        <div id="divInformacoesRelatorios">
            <table width="45%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr id="tr_tipo">
                    <td class="TextoCampos" width="10%"></td>
                    <td class="TextoCampos" colspan="2">
                        <div align="left">
                            <input name="chkTransitoria" type="checkbox" id="chkTransitoria" value="checkbox" <%=(carregaconta && beanplano.isTransitoria() ? "checked" : "")%>>
                            Conta transit&oacute;ria, n&atilde;o far&aacute; parte dos relat&oacute;rios gerenciais. 
                        </div>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos" width="10%"></td>
                    <td height="17" class="TextoCampos" colspan="2">
                        <div align="left">
                            <input name="isMostrarAnaliseVeiculo" type="checkbox" id="isMostrarAnaliseVeiculo" value="checkbox" <%=(carregaconta && beanplano.isMostrarAnaliseVeiculo()? "checked" : "")%>>
                            Visualizar esse plano de custo nos relatórios de custos dos veículos.
                        </div>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos" width="10%"></td>
                    <td height="17" class="TextoCampos" colspan="2">
                        <p align="left">
                            <input name="isvisualizarorcamentacao" type="checkbox" id="isvisualizarorcamentacao" value="checkbox" <%=(!carregaconta ?  "checked": (carregaconta && beanplano.isVisualizarOrcamentacao() ? "checked" : ""))%>>
                            Visualizar essa conta na or&ccedil;amenta&ccedil;&atilde;o
                        </p>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos" width="10%"></td>
                    <td height="17" class="TextoCampos" colspan="2">
                        <p align="left">
                            <input name="is_bloquear_lancamento" type="checkbox" teste="<%=beanplano.isBloquearLancamento()%>" id="is_bloquear_lancamento" value="checkbox" <%=(carregaconta && beanplano.isBloquearLancamento() ? "checked" : "") %> >
                            Bloquear o lançamento da despesa se o valor ultrapassar o que foi definido na orçamentação
                        </p>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos" colspan="2">Nos relatórios de custos dos veículos considerar como filtro:</td>
                    <td class="CelulaZebra2" width="292" >
                        <select name="tipoDataAnalise" id="tipoDataAnalise" class="inputtexto" height="17">
                            <option value="e"<%=(carregaconta && beanplano.getTipoDataAnalise() == 'e' ? "selected" : "")%>>A data de Emissão</option>
                            <option value="v" <%=(carregaconta && beanplano.getTipoDataAnalise() == 'v' ? "selected" : "")%>>A data de Vencimento</option>
                            <option value="p" <%=(carregaconta && beanplano.getTipoDataAnalise() == 'p' ? "selected" : "")%>>A data de Pagamento</option>
                        </select>
                    </td>
                </tr>
                
            </table>
        </div>
            <div id="divAuditoria" >

                <table width="45%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina" id="tableAuditoria" style='display: <%=carregaconta && nivelUser == 4 ? "" : "none"%>'>
                    <%@include file="/gwTrans/template_auditoria.jsp" %>

                </table>
            </div>
            <br/>        
            <table width="45%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">  
                <tr class="CelulaZebra2">
                    <td colspan="4">
                        <% if (nivelUser >= 2) {%>
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
