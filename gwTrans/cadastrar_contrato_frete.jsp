
<%@page import="nucleo.Apoio"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<link href="estilo.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" href="stylesheets/tabs.css" type="text/css" media="all">
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("builder.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("prototype_1_6.js")%>" type="text/javascript"></script>
<script type="text/javascript" src="script/<%=Apoio.noCacheScript("fabtabulous.js")%>"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("funcoes_gweb.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("mascaras.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("jquery.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("TalaoCheque.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("Despesa.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("impostos.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("contrato_frete_documento.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("funcoesTelaContratoFrete.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("LogAcoesAuditoria.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("funcoesTelaContratoFrete.js")%>" type="text/javascript"></script>

<%--@elvariable id="cadContratoFrete" type="br.com.gwsistemas.contratodefrete.ContratoFrete"--%>

<script language="JavaScript" type="text/javascript">
    var homePath = '${homePath}';

    jQuery.noConflict();    

    var countDocum = 0;
    var countPgto = 0;
    var countDespesa = 0;
    var countDespesaPlanoCusto = 0;
    var listaFormaPagamento;
    var listaBanco;
    var listaConta;
    var listaDocum;
    var listaEspecie;
    var dataAtual = '${param.dataAtual}';
    var callMascaraReais = "mascara(this,reais);";
    var listaNegociacoes;
    var contadorNegociacoes = 0;
    var contadorRegras = 0;
    var isConfiguracaoReterImposto = ${configuracao.diariaRetemImposto};
    var manualAutomaticoCiotNivel = '${param.nivelManualAutomaticoCiot}';
    var status = '<c:out  value="${usuario.filial.stUtilizacaoCfeS}" default="N"/>';
    var manualAutomaticoCiotNivel = '${param.nivelManualAutomaticoCiot}';
    var contratoRetencaoImpostoOperadoraCFe = <c:out  value="${cadContratoFrete.retencaoImpostoOperadoraCFe}" default="false"/>;
    var validarValorMaximoTabelaRotaPermissao = '${param.nivelAlteraFreteTabela != 4 or param.nivelAutorizaContratoMaior != 4}' === 'true';

    function gerenciaCFe(isValida) {
        var status = '<c:out  value="${usuario.filial.stUtilizacaoCfeS}" default="N"/>';
        var operadoraCiot = $('filialCfe_' + $('filial').value).value;
        /*  ATENÇÃO: A REGRA DO IF ABAIXO ESTÁ ERRADA, PORÉM  TRATA-SE DE QUE É UM ERRO ANTIGO QUE FAZIA 
         * A TELA DE CONTRATO-FRETE ABRIR COMO contrato E NÃO pré-contrato ISSO SE TORNOU O PADRÃO DE LANÇAMENTO DE MUITOS CLIENTES.
         * CORRIGIR E FAZER ABRIR COMO pré-contrato, POSSIVELMENTE CAUSARÁ PROBLEMAS A ALGUNS CLIENTES.
         * A REGRA DE COMO A TELA DEVERÁ ABRIR SERÁ DEFINIDA POR DEIVID.  */
        if (status == 'N' || status == 'P' || 'D') { 
            $("statusContrato").checked = true;
            showHide(true, isValida);
            if (status == 'P') {
                $("divLbTipo").style.display = 'none';
                $("divTipo").style.display = 'none';
            }
        } else {
            showHide($("statusContrato").checked, isValida);
        }

        if (operadoraCiot != 'R') {
            $("divLbTipo").style.display = 'none';
            $("divTipo").style.display = 'none';
        }
    }

    function calculaIR(inss, doCalc) {
        var percentualBase = <c:out value="${configuracao.irAliqBaseCalculo}" default="0"/>;

        var faixas = new Array();

        faixas[0] = new Faixa(0,
    <c:out value="${configuracao.irDe1}" default="0"/>,
    <c:out value="0" default="0"/>,
    <c:out value="0" default="0"/>);

        faixas[1] = new Faixa('<c:out value="${configuracao.irDe1}" default="0"/>',
    <c:out value="${configuracao.irAte1}" default="0"/>,
    <c:out value="${configuracao.irAliq1}" default="0"/>,
    <c:out value="${configuracao.irdeduzir1}" default="0"/>);

        faixas[2] = new Faixa(<c:out value="${configuracao.irDe2}" default="0"/>,
    <c:out value="${configuracao.irAte2}" default="0"/>,
    <c:out value="${configuracao.irAliq2}" default="0"/>,
    <c:out value="${configuracao.irDeduzir2}" default="0"/>);

        faixas[3] = new Faixa(<c:out value="${configuracao.irDe3}" default="0"/>,
    <c:out value="${configuracao.irAte3}" default="0"/>,
    <c:out value="${configuracao.irAliq3}" default="0"/>,
    <c:out value="${configuracao.irDeduzir3}" default="0"/>);

        faixas[4] = new Faixa(<c:out value="${configuracao.irAte3}" default="0"/>,
    <c:out value="999999999999" default="0"/>,
    <c:out value="${configuracao.irAliqAcima}" default="0"/>,
    <c:out value="${configuracao.irdeduzirAcima}" default="0"/>);

        var baseIRJaRetida = $('base_ir_prop_retido').value;
        var valorIRJaRetido = $('ir_prop_retido').value;
        var isCalculaDependentes = <c:out value="${configuracao.consideraDependentesIr}" default="false"/>;
        var valorPorDependente = '<c:out value="${configuracao.irVlDependente}" default="0"/>';
        var deduzirInssIr = '<c:out value="${configuracao.deduzirINSSIR}" default="0"/>';
        var ir = new IR(inss.valorFrete, percentualBase, faixas, inss.valorFinal, baseIRJaRetida, valorIRJaRetido, $("qtddependentes").value, valorPorDependente, isCalculaDependentes, deduzirInssIr);
        
        if (doCalc) {
            $("vlIr").value = colocarVirgula(ir.valorFinal);
            $("vlBaseIr").value = colocarVirgula(ir.baseCalculo);
            $("aliqIr").value = colocarVirgula(ir.aliquota);
            $("vlDependentes").value = colocarVirgula(valorPorDependente);
        } else {
            $("vlIrIntFinan").value = colocarVirgula(ir.valorFinal);
            $("vlBaseIrIntFinan").value = colocarVirgula(ir.baseCalculo);
            $("aliqIrIntFinan").value = colocarVirgula(ir.aliquota);
            $("vlDependentesIntFinan").value = colocarVirgula(valorPorDependente);
        }
    }

    function calculaSest(baseCalculo, doCalc) {
        var aliquota = <c:out value="${configuracao.sestSenatAliq}" default="0"/>;
        var sest = new Sest(baseCalculo, aliquota);
        
        
        if (doCalc) {
            $("vlBaseSesc").value = colocarVirgula(sest.baseCalculo);
            $("aliqSescSenat").value = colocarVirgula(sest.aliquota);
            $("vlSescSenat").value = colocarVirgula(sest.valorFinal);
        } else {
            $("vlBaseSescIntFinan").value = colocarVirgula(sest.baseCalculo);
            $("aliqSescSenatIntFinan").value = colocarVirgula(sest.aliquota);
            $("vlSescSenatIntFinan").value = colocarVirgula(sest.valorFinal);
            
        }

        return sest;
    }

    function getBaseRetencao() {
        var valorFreteLb = pontoParseFloat($("vlFreteMotorista").value);
        if (${configuracao.diariaRetemImposto}) {
            valorFreteLb += pontoParseFloat($("vlDiaria").value);
        }
        if (${configuracao.outrosRetemImposto}) {
            valorFreteLb += pontoParseFloat($("vlOutros").value);
        }
        if (${configuracao.descargaRetemImposto}) {
            valorFreteLb += pontoParseFloat($("vlDescarga").value);
        }
        if (${configuracao.deduzirImpostosOutrasRetencoesCfe}) {
            var valor = pontoParseFloat($('vlOutrasDeducoes').value);
            
            if (isNaN(valor)) {
                valor = 0;

                $('vlOutrasDeducoes').value = colocarVirgula("0");
            }

            valorFreteLb -= valor;
        }
        $('lbBaseImpostos').innerHTML = colocarVirgula(valorFreteLb.toString());
    }

    function calculaInss(doCalc) {
        var valorFrete = pontoParseFloat($("vlFreteMotorista").value);
        if (${configuracao.diariaRetemImposto}) {
            valorFrete += pontoParseFloat($("vlDiaria").value);
        }
        if (${configuracao.outrosRetemImposto}) {
            valorFrete += pontoParseFloat($("vlOutros").value);
        }
        if (${configuracao.descargaRetemImposto}) {
            valorFrete += pontoParseFloat($("vlDescarga").value);
        }
        if (${configuracao.deduzirImpostosOutrasRetencoesCfe}) {
            var valor = pontoParseFloat($('vlOutrasDeducoes').value);

            if (isNaN(valor)) {
                valor = 0;
            }

            valorFrete -= valor;
        }

        var percentualBase = <c:out value="${configuracao.inssAliqBaseCalculo}" default="0"/>;
        var valorJaRetido = parseFloat($("inss_prop_retido").value) + pontoParseFloat($("vlRetidoEmpresa").value);
        var teto = <c:out value="${configuracao.tetoInss}" default="0"/>;
        var faixas = new Array();

        faixas[0] = new Faixa(0,
    <c:out value="${configuracao.inssAte}" default="0"/>,
    <c:out value="${configuracao.inssAliqAte}" default="0"/>);

        faixas[1] = new Faixa(<c:out value="${configuracao.inssDe1}" default="0"/>,
    <c:out value="${configuracao.inssAte1}" default="0"/>,
    <c:out value="${configuracao.inssAliq1}" default="0"/>);

        faixas [2] = new Faixa(<c:out value="${configuracao.inssDe2}" default="0"/>,
    <c:out value="${configuracao.inssAte2}" default="0"/>,
    <c:out value="${configuracao.inssAliq2}" default="0"/>);

        faixas [3] = new Faixa(<c:out value="${configuracao.inssDe3}" default="0"/>,
    <c:out value="${configuracao.inssAte3}" default="0"/>,
    <c:out value="${configuracao.inssAliq3}" default="0"/>);

        var baseINSSJaRetida = $('base_inss_prop_retido').value;
        var inss = new Inss(valorFrete, percentualBase, faixas, teto, valorJaRetido, baseINSSJaRetida);

        if (doCalc) {
            $("aliqInss").value = colocarVirgula(inss.aliquota);
            $("vlBaseInss").value = colocarVirgula(inss.baseCalculo);
            $("vlINSS").value = colocarVirgula(inss.valorFinal);
        } else {
            $("aliqInssIntFinan").value = colocarVirgula(inss.aliquota);
            $("vlBaseInssIntFinan").value = colocarVirgula(inss.baseCalculo);
            $("vlINSSIntFinan").value = colocarVirgula(inss.valorFinal);
        }
        return inss;
    }

    function aoClicarNoLocaliza(idJanela) {
        
        try {
            var index = $("indexAux").value;
            var plano;
            if (idJanela == 'Fornecedor') {
                $('fornecedor_' + index).value = $('fornecedor').value;
                $('idFornecedor_' + index).value = $('idfornecedor').value;
                $('historico_' + index).value = $('descricao_historico').value;
                if ($('idplcustopadrao').value != "0") {
                    plano = new ApropriacaoDespesa();
                    plano.idApropriacao = $('idplcustopadrao').value;
                    plano.conta = $('contaplcusto').value;
                    plano.apropriacao = $('descricaoplcusto').value;
                    plano.und = $('sigla_und_forn').value;
                    plano.idUnd = $('id_und_forn').value;
                    plano.veiculo = $("vei_placa").value;
                    plano.idVeiculo = $("idveiculo").value;
                    addPropriacao(index, plano);
                }
            } else if (idJanela == 'Historico') {
                $('historico_' + index).value = $('descricao_historico').value;
                $('idHistorico_' + index).value = $('idhist').value;
            } else if (idJanela == 'Consignatario') {
                if (isConfiguracaoReterImposto) {
                    $('vlUnitarioDiaria').value = colocarVirgula($('con_valor_diaria_parado').value);
                    $('con_rzs').value = $('con_rzs').value;
                    $('idconsignatario').value = $('idconsignatario').value;
                } else {
                    $('vlUnitarioDiaria2').value = colocarVirgula($('con_valor_diaria_parado').value);
                    $('con_rzs2').value = $('con_rzs').value;
                    $('idconsignatario2').value = $('idconsignatario').value;
                }
                calculaDiaria();
                calculaImpostos();
                calcula();
            } else if (idJanela == 'Veiculo_Despesa') {
                $('veiculoAprop_' + index).value = $('vei_placa').value;
                $('idVeiculoAprop_' + index).value = $('idveiculo').value;
            } else if (idJanela == 'Unidade_de_Custo') {
                $('undAprop_' + index).value = $('sigla_und').value;
                $('idUndAprop_' + index).value = $('id_und').value;
            } else if (idJanela == 'Agente_Pagador') {
                var idx = $('indexAux').value;
                //lembrar de colocar o percentual do abastecimento
                $('agentePgto_' + idx).value = $('agente').value;
                $('idAgentePgto_' + idx).value = $('idagente').value;
            } else if (idJanela == 'Plano') {
                if (index.split("_")[1] == "undefined") {
                    plano = new ApropriacaoDespesa();
                    plano.idApropriacao = $("idplanocusto_despesa").value;
                    plano.conta = $("plcusto_conta_despesa").value;
                    plano.apropriacao = $("plcusto_descricao_despesa").value;
                    plano.veiculo = $("vei_placa").value;
                    plano.idVeiculo = $("idveiculo").value;
                    addPropriacao(index.split("_")[0], plano);
                } else {
                    $("conta_" + index).value = $("plcusto_conta_despesa").value;
                    $("idApropriacao_" + index).value = $("idplanocusto_despesa").value;
                    $("apropriacao_" + index).value = $("plcusto_descricao_despesa").value;
                }

            } else if (idJanela == 'Motorista' || idJanela == 'Veiculo') {
                carregarAbastecimentos();
                if (idJanela == 'Motorista' && ($("idveiculo").value != "" || $("idveiculo").value != "0")) {
                    abrirLoginSupervisor('<c:out value="${configuracao.permitirLancamantoOSAbertoVeiculo}"/>', 2);
                } else if (idJanela == 'Veiculo') {
                    abrirLoginSupervisor('<c:out value="${configuracao.permitirLancamantoOSAbertoVeiculo}"/>', 2);
                }

                verificaSituacaoMotorista();
                var isTac = $("is_tac").value;
                $("observacao").value = ($("obscartafrete").value).replace("<br>", "\n");
                $("observacao").value = ($("observacao").value).replace("<br>", "\n");
                $("observacao").value = ($("observacao").value).replace("<br>", "\n");
                $("observacao").value = ($("observacao").value).replace("<br>", "\n");
                $("observacao").value = ($("observacao").value).replace("<br>", "\n");
                var bloqueado = validarBloqueioVeiculo("veiculo");
                if (idJanela == 'Veiculo' && !bloqueado) {
                    /* var campo = document.getElementById("categoriaNdd").value;
                     var campo2 = document.getElementById("categoriaPamcard").value;*/
                    $("categoriaNdd").value = getObj("categoria_ndd_id").value;
                    $("categoriaPamcard").value = getObj("categoria_pamcard_id").value;
                    if ($("stUtilizacaoCfeS").value == 'P' || $("stUtilizacaoCfeS").value == 'A' || $("stUtilizacaoCfeS").value == 'D') {
                        $("solucoesPedagio").value = $("solucao_pedagio").value;
                        alterarFavorecidoPedagio();
                    }
                    

                }
                if (idJanela == 'Motorista') {
                    /* var campo = document.getElementById("categoriaNdd").value;
                     var campo2 = document.getElementById("categoriaPamcard").value;*/
                    $("percentualDescontoContrato").value = $("mot_outros_descontos_carta").value;
                    let percentualRetencao = parseFloat($("mot_outros_descontos_carta").value);
                    if (percentualRetencao > 0) {
                        $("percentualRetencao").value = $("mot_outros_descontos_carta").value;
                    }
                    var bloqueado = validarBloqueioVeiculoMotorista("veiculo_motorista,carreta_motorista,bitrem_motorista");
                    if (!bloqueado) {
                        $("categoriaNdd").value = getObj("categoria_ndd_id").value;
                        $("categoriaPamcard").value = getObj("categoria_pamcard_id").value;
                        if ($("stUtilizacaoCfeS").value == 'P' || $("stUtilizacaoCfeS").value == 'A' || $("stUtilizacaoCfeS").value == 'D') {
                            $("solucoesPedagio").value = $("solucao_pedagio").value;
                            alterarFavorecidoPedagio();
                        }
                        validarNegociacao();
                    }
                }

                if (isTac == 'f') {
                    $("statusContrato").checked = true;
                    $("chkReterImpostos").checked = false;
                } else {
                    $("statusPre").checked = true;
                    if (!isRetencaoImpostoOperadoraCFe()) {
                        $("chkReterImpostos").checked = true;
                    }
                    visualizarImpostos();
                }
                gerenciaCFe();
                $('vlJaRetido').value = colocarVirgula($('inss_prop_retido').value);
            } else if (idJanela == 'ManifRom') {
                calculaImpostos();
            } else if (idJanela == 'Carreta') {
                validarBloqueioVeiculo("carreta");
            } else if (idJanela == 'Bitrem') {
                validarBloqueioVeiculo("bitrem");
            } else if (idJanela == 'Cidade_Origem') {
                $("id-cidade-origem").value = $("idcidadeorigem").value;
                $("cidade-origem").value = $("cid_origem").value;
                $("uf-origem").value = $("uf_origem").value;
            } else if (idJanela == 'Cidade_Destino') {
                $("id-cidade-destino").value = $("idcidadeorigem").value;
                $("cidade-destino").value = $("cid_origem").value;
                $("uf-destino").value = $("uf_origem").value;
            }
        } catch (ex) {
            console.log(ex);
            alert(ex);
        }
        carregarNumeroTacAgregBase();
        if ($("basetac").value != '') {

            $("baseTacAgregado").value = $("basetac").value;
            $("agregado").checked = true;
            $("normal").checked = false;
        }

    }

    function salvar() {
        try {
            var formulario = $("formulario");
            var cancelar = $("cancelada").checked;
            var idFilial = $("filial").value;
            //Iniciando validações
            var maxPgtop = $("maxPagamento").value;
            var despDelete = "";

            //Verificando se o total dos pagamentos está igual ao valor liquido do frete.
            var totalPagamentosVal = parseFloat(0);
            var totalAdt = 0;
            var count = 0;
            var totSaldo = 0;
            $("stFilialCfe").value = $('filialCfe_' + $('filial').value).value;
            for (var i = 1; i <= maxPgtop; i++) {
                if ($('valorPgto_' + i) != null) {
                    $('formaPagto_' + i).disabled = false;
                    $('contaPgto_' + i).disabled = false;
                    //cometei por conta de que o valor esta sendo desabilitado e não esta salvand o banco na linha de saldo
//                        $ 'banco_'+i).disabled = "true";
                    $('banco_' + i).disabled = true;
                    $('tipoContaPgto_' + i).disabled = false;
                    $('tipoPagamentoCfe_' + i).disabled = false;
                  
                    var vlpgto = parseFloat(colocarPonto($('valorPgto_' + i).value));
                    if (vlpgto < 0) {
                        alert("Valor de pagamento não pode ser menor que 0 (zero)!");
                        $('valorPgto_' + i).value = 0;
                        return false;
                    }
                    if ($("isSalvar" + i).value == 'true') {
                        totalPagamentosVal += vlpgto;
                    }
                    if ($('tipoPagto_' + i).value == 'a') { //Somando apenas os adiantamentos
                        totalAdt += parseFloat(vlpgto);
                        if ($('contaPgto_' + i).value == '0') {
                        }
                    }else{
                        totSaldo += parseFloat(vlpgto);
                    }
                    if (($('formaPagto_' + i).value == '8') && $('idAgentePgto_' + i).value == '0') {
                        alert('Informe o agente pagador do(s) pagamento(s)!');
                        return null;
                    }
                    if ($('formaPagto_' + i).value == '1' && $("despesaPagId_" + i).value != "0") {
                        despDelete += (despDelete == "" ? "" : ",") + $("despesaPagId_" + i).value;
                    }

                    if ($("tipoFavorecido_" + i).value == 'p') {
                        count++;
                    }
                    var pagamentosDebitar = "7,5,1,6,15,2,8"; //includes
                    if(($("idPgto_"+i).value == 0)  && ($("contaPgto_"+i).value=='' || $("contaPgto_"+i).value=='0')){
                        if(!pagamentosDebitar.includes($('formaPagto_' + i).value) && $('tipoPagto_' + i).value != 's'){
                            alert("Informe conta a ser debitada!");
                            return null;
                        }
                    }
                   
                    if ($("tipoFavorecido_" + i).value =="" || $("tipoFavorecido_" + i).value =="0") {
                        alert('Informe o favorecido do(s) pagamento(s)!');
                        return null;
                    }
                    
                    
                }
            }
            <c:if test="${param.acao == 1}">
                        
            var ir = pontoParseFloat($("vlIrIntFinan").value);
            var inss = pontoParseFloat($("vlINSSIntFinan").value);
            var sest = pontoParseFloat($("vlSescSenatIntFinan").value);
            if (isRetencaoImpostoOperadoraCFe()) {
                if (totSaldo < (ir + inss + sest)) {
                    alert("ATENÇÃO: Não é possivel salvar o contrato pois a provisão dos impostos ("
                            +colocarVirgula((ir + inss + sest))+") é maior que o saldo ("+colocarVirgula(totSaldo)+").");
                    return null;
                }
            }

            </c:if>
            
            if ($("vlLiquido").value == "0,00") {
                alert("ATENÇÃO: O total dos pagamentos não pode ser 0.");
                return false;
            }

            //Validando pagamento para o proprietário, quando não for PAMCARD
            /*for (var max = 1; max <= maxPgtop; max++) {
             if($("formaPagto_"+max)!=null){
             if ($("formaPagto_" + max).value != 11 && count < 1 && cancelar == false) {
             alert("Um dos pagamentos tem que ser direcionado ao proprietário do veículo!");
             return false;
             }
             }
             }*/
            for (var i = 1; i <= parseFloat($("maxDespesa").value); i++) {
                if($("idFornecedor_"+i)){
                    if(($("idFornecedor_"+i).value == '0' || $("idFornecedor_"+i).value == '')  && !($("deletado_"+i).value == true || $("deletado_"+i).value == 'true')){
                        alert("Favor informar corretamente o fornecedor da Despesa Agregada!");
                        $("fornecedor_"+i).focus();
                        return false;
                    }
                }
            }

            if (despDelete != "") {
                if (!confirm("A(s) seguinte(s) despesa(s): '" + despDelete + "' será(ão) deleteda(s).\n Tem certeza que é isso que deseja?")) {
                    return false;
                }
            }

            var valor_total = (parseFloat(totalPagamentosVal.toFixed(2)) + parseFloat(colocarPonto($('cartaValorCC').value))).toFixed(2);

            // alert("total pagamento: "+parseFloat(totalPagamentosVal.toFixed(2)));
            // alert("cartaValorCC: "+parseFloat(colocarPonto($('cartaValorCC').value)));
            // alert("valor_total: "+valor_total);

            if (pontoParseFloat($('vlLiquido').value) != parseFloat(valor_total)) {
                alert('A soma dos pagamentos ('+colocarVirgula(parseFloat(valor_total))+') deverá ser igual ao valor líquido do frete('+colocarVirgula(pontoParseFloat($('vlLiquido').value))+')!');
                return null;
            } else if (maxPgtop <= 0) {
                if (!($('filialCfe_' + $('filial').value).value == 'R' && $("statusPre").checked)) {
                    alert('Informe os pagamentos do contrato de frete corretamente!');
                    return null;
                }
            }

            if(pontoParseFloat($('vlLiquido').value) == parseFloat(valor_total) && ${param.nivelLiberacaoSaldoCarta == 4}){
                for (var i = 1; i <= maxPgtop; i++) {
                    if($("valorPgto_"+i)){
                        var percentual = (parseFloat(colocarPonto($("valorPgto_"+i).value)) * 100 / pontoParseFloat($('vlLiquido').value)); 
                        $("percPgto_" + i).value = roundABNT(percentual,2);
                    }
                } 
            }
            //Validando o percentual do adiantamento
            /**
             * @autor   Gleidson
             * @date    19/10/2016
             * @motivo  Com a rotina de negociação se faz desnecessario existir a permissão 'alterapercadiant'
             * pois caso o contrato tenha negociação ele não poderá alterar a negociação
             * 
            if ({param.nivelUserAdiantamento != 4}) {
                var percAdtPermitido = $("perc_adiant").value;
                var xTotalLiquido = colocarPonto($('vlLiquido').value);
                var percAdtmo = parseFloat(totalAdt) * 100 / parseFloat(xTotalLiquido);
                if (parseFloat(percAdtmo).toFixed(2) > parseFloat(percAdtPermitido)) {
                    alert('Para esse motorista só é permitido ' + percAdtPermitido + '% de adiantamento!');
                    return false;
                }
            }
             */

            if (parseFloat(colocarPonto($('vlFreteMotorista').value)) > parseFloat(colocarPonto($('inTotalValorFrete').value))) {
                if (!${configuracao.permiteContratoMaiorCtrc}) {
                    alert('O contrato de frete não poderá ser salvo. O valor do contrato de frete é maior que o valor dos documentos transportados!');
                    return null;
                }
            }

            if ($('filialCfe_' + $('filial').value).value == 'P' && ($("categoriaPamcard").value == 0)) {
                alert("Informe a categoria Pamcard !");
                $("categoriaPamcard").focus();
                return false;
            }
            if (($('filialCfe_' + $('filial').value).value == 'P' || $('filialCfe_' + $('filial').value).value == 'A' || $('filialCfe_' + $('filial').value).value == 'D')
                && ($("dataPartida").value == "" || $("dataTermino").value == "")) {
                if ($("dataPartida").value == "") {
                    alert("Informe a data de partida!");
                    $("dataPartida").focus();
                    return false;
                } else {
                    alert("Informe a data de término!");
                    $("dataTermino").focus();
                    return false;
                }
            }
            if ($('filialCfe_' + $('filial').value).value == 'P' || $('filialCfe_' + $('filial').value).value == 'A') {
                if ($("natureza_cod").value == 0) {
                    alert("Informe a natureza da carga!")
                    return false;
                }
            }
            if ($('solicitarAutorizacao').checked && $('motivoSolicitacao').value == '') {
                alert("Informe o motivo da solicitação de autorização do frete!")
                return false;
            }
            if (($('is_calcular_pedagio_cfe_' + $('filial').value).value == 't' || $('is_calcular_pedagio_cfe_' + $('filial').value).value == 'true') 
                        && ($("stUtilizacaoCfeS").value == 'P') && ($("solucoesPedagio").value == 0)) {
                alert("Informe uma Solução de Pedágio!");
                return false;
            }

            habilitar($("filial"));
            habilitar($("negociacaoAdiantamento"));
            var maxPgtop = $("maxPagamento").value;
            for (var i = 1; i <= maxPgtop; i++) {
                if ($("formaPagto_" + i) != null) {
                    habilitar($("tipoPagto_" + i));
                    habilitar($("formaPagto_" + i));
                    habilitar($("documPgto2_" + i));
                    habilitar($("contaPgto_" + i));
                    habilitar($("valorPgto_" + i));
                    habilitar($("dataPgto_" + i));
                    habilitar($("documPgto_" + i));
                    habilitar($("tipoContaPgto_" + i));
                    habilitar($("tipoFavorecido_" + i));
                    habilitar($("banco_" + i));
                }
            }
            $("chkReterImpostos").disabled = false;

            var maxAdiantamento = $("maxPagamento").value;
            var campoChq = "documPgto_";
            if (${configuracao.controlarTalonario}) {
                campoChq = "documPgto2_";
            }


            for (var qtdMaxAdian = 1; qtdMaxAdian <= maxAdiantamento; qtdMaxAdian++) {

                var cont = 0;

                for (var qtdAdianMax = 1; qtdAdianMax <= maxAdiantamento; qtdAdianMax++) {
                    //alert('1º FOR INDEX:' + qtdMaxAdian + ' VALOR: '+$("documPgto2_"+qtdMaxAdian).value);
                    //alert('2º FOR INDEX:' + qtdAdianMax + ' VALOR: '+$("documPgto2_"+qtdAdianMax).value);

                    if ($("formaPagto_" + qtdAdianMax) != null) {
                        if ($("formaPagto_" + qtdAdianMax).value == "3") {
                            if (($("formaPagto_" + qtdAdianMax) != null) && ($("formaPagto_" + qtdMaxAdian) != null)) {
                                if ($(campoChq + qtdMaxAdian).value == $(campoChq + qtdAdianMax).value) {
                                    if ($("formaPagto_" + qtdMaxAdian).value == $("formaPagto_" + qtdAdianMax).value) {
                                        cont++;
                                    }
                                }
                            }
                        }
                    }
                }
                if ($(campoChq + qtdMaxAdian) != null) {
                    if ($(campoChq + qtdMaxAdian).value != "") {
                        if (cont >= 2) {
                            alert("ATENÇÃO: Não pode salvar dois cheques com o mesmo número.");
                            return false;
                        }
                    }
                }
            }
            
            if ($('filialCfe_' + $('filial').value).value == 'A') {
                if ($("categoriaNdd").value == 0) {
                    alert("Informe a categoria do veículo Target!");
                    $("categoriaNdd").focus();
                    return false;
                } else if ($("categoriaNdd").value == 1) {
                    alert("A Categoria Target não pode ser Isento!");
                    $("categoriaNdd").focus();
                    return false;
                }

            }

            setEnv();
            window.open('about:blank', 'pop', 'width=210, height=100');
            formulario.action += "&isRetencaoImpostoOperadoraCFe=" + isRetencaoImpostoOperadoraCFe();
            formulario.submit();
            $("negociacaoAdiantamento").disabled = true;
        } catch (exception) {
            console.log(exception);
            alert(exception);
        }

    }

    function carregar() {
    
        listaFormaPagamento = new Array();
        listaBanco = new Array();
        listaConta = new Array();
        listaEspecie = new Array();
        listaDocum = new Array();
        listaNegociacoes = new Array();
        listaNegociacoesRegras = new Array();
        var isRomaneio = false;
        $("dataDeAuditoria").value = '${param.dataAtual}';
        $("dataAteAuditoria").value = '${param.dataAtual}';
        $("natureza_cod").value = '<c:out value="${param.idNaturezaCarga}"/>';
        $("natureza_cod_desc").value = '<c:out value="${param.codigoNaturezaCarga}"/>';
        $("natureza_desc").value = '<c:out value="${param.descricaoNaturezaCarga}"/>';
    <c:if test="${usuario.filial.stUtilizacaoCfeS == 'P'}">
        $("tdLabelCategoriaPamcard").style.display = '';
        $("tdCategoriaPamcard").style.display = '';
    </c:if>

    <c:if test="${usuario.filial.stUtilizacaoCfeS == 'D' || usuario.filial.stUtilizacaoCfeS == 'A'}">
        $("tdLabelCategoriaNdd").style.display = '';
        $("tdCategoriaNdd").style.display = '';
    </c:if>
    <c:if test="${usuario.filial.stUtilizacaoCfeS != 'N'}">    
        $("contaID").value = ('${usuario.filial.contaCfe.idConta}');
    </c:if>
   
    <c:forEach var="fpgto" varStatus="status" items="${listaFpgto}">
        listaFormaPagamento[${status.count - 1}] = new Option('${fpgto.idFPag}', '${fpgto.descFPag}');
    </c:forEach>
    <c:forEach var="banco" varStatus="status" items="${listaBanco}">
        listaBanco[${status.count - 1}] = new Option('${banco.idBanco}', '${banco.descricao}');
    </c:forEach>
    <c:forEach var="conta" varStatus="status" items="${listaConta}">
        listaConta[${status.count - 1}] = new Option('${conta.idConta}', '${conta.numero}-${conta.digito_conta}/${conta.banco.descricao}');
    </c:forEach>
    <c:forEach var="especie" varStatus="status" items="${listaEspecie}">
                listaEspecie[${status.count - 1}] = new Option('${especie.id}', '${especie.especie}');
    </c:forEach>
    <c:forEach var="docum" varStatus="status" items="${cadContratoFrete.pagamentos}">
                listaDocum[${status.count - 1}] = new Option('${docum.documento}', '${docum.documento}');
    </c:forEach>
    <c:forEach var="negociacao" varStatus="status" items="${listaNegociacaoFrete}">    
        listaNegociacoes[${status.count - 1}] = new Negociacao('${negociacao.id}', '${negociacao.descricao}', '${negociacao.tipoCalculo}');
        listaNegociacoes[${status.count - 1}].regras = new Array();
        <c:forEach var="regras" varStatus="contador" items="${negociacao.regrasFrete}">
                listaNegociacoes[${status.count - 1}].regras[${contador.count - 1}] = new regrasNegociacao('${regras.id}', '${regras.tipo}', '${regras.percentual}', '${regras.tipoFav}', '${regras.pagamentoCfe}', '${regras.diasPag}', '${regras.formaPagamento.idFPag}', '${regras.negociacaoAdiantamento.id}', '${regras.flagValorEditavel}');
                contadorRegras++;
    </c:forEach>
    </c:forEach>
                //Atribuindo a negociação ao select
                povoarSelect($("negociacaoAdiantamento"), listaNegociacoes);

                if ('${param.negociacaoAdiantamentoId}' != 0) {
                    $("negociacaoAdiantamento").value = '${param.negociacaoAdiantamentoId}';
                    $("negociacaoHidden").value = '${param.negociacaoAdiantamentoId}';
                }
                //read
                if (${param.acao == 2}) {
                    carregarNumeroTacAgregBase();
                    $("idcontratofrete").value = '${cadContratoFrete.id}';
                    readOnly($("idcontratofrete"));
                    $("data").value = '${cadContratoFrete.data}';
                    $("filial").value = '${cadContratoFrete.filial.idfilial}';
                    $("filial").disabled = true;
                    $("idmotorista").value = '${cadContratoFrete.motorista.idmotorista}';
                    $("motor_nome").value = '${cadContratoFrete.motorista.nome}';
                    $("motor_cpf").value = '${cadContratoFrete.motorista.cpf}';
                    $("motor_cnh").value = '${cadContratoFrete.motorista.cnh}';
                    $("motor_tipo_conta1").value = '${cadContratoFrete.motorista.tipoContaAdiantamentoExpers}';
                    $("motor_conta1").value = '${cadContratoFrete.motorista.conta1}';
                    $("motor_agencia1").value = '${cadContratoFrete.motorista.agencia1}';
                    $("motor_favorecido1").value = '${cadContratoFrete.motorista.favorecido1}';
                    $("motor_banco1").value = '${cadContratoFrete.motorista.banco1.idBanco}';
                    $("motor_tipo_conta2").value = '${cadContratoFrete.motorista.tipoContaSaldoExpers}';
                    $("motor_conta2").value = '${cadContratoFrete.motorista.conta2}';
                    $("motor_agencia2").value = '${cadContratoFrete.motorista.agencia2}';
                    $("motor_favorecido2").value = '${cadContratoFrete.motorista.favorecido2}';
                    $("motor_banco2").value = '${cadContratoFrete.motorista.banco2.idBanco}';
                    $("idveiculo").value = '${cadContratoFrete.veiculo.idveiculo}';
                    $("vei_placa").value = '${cadContratoFrete.veiculo.placa}';
                    $("vei_prop").value = '${cadContratoFrete.contratado.razaosocial}';
                    $("idproprietarioveiculo").value = '${cadContratoFrete.contratado.idfornecedor}';
                    $("vei_prop_cgc").value = '${cadContratoFrete.contratado.cpfCnpj}';
                    $("prop_conta1").value = '${cadContratoFrete.contratado.contaBancaria}';
                    $("prop_tipo_conta1").value = '${cadContratoFrete.contratado.tipoContaAdiantamentoExpers}';
                    $("prop_agencia1").value = '${cadContratoFrete.contratado.agenciaBancaria}';
                    $("prop_favorecido1").value = '${cadContratoFrete.contratado.favorecido}';
                    $("prop_banco1").value = '${cadContratoFrete.contratado.banco.idBanco}';
                    $("prop_conta2").value = '${cadContratoFrete.contratado.contaBancaria2}';
                    $("prop_tipo_conta2").value = '${cadContratoFrete.contratado.tipoContaSaldoExpers}';
                    $("prop_agencia2").value = '${cadContratoFrete.contratado.agenciaBancaria2}';
                    $("prop_favorecido2").value = '${cadContratoFrete.contratado.favorecido2}';
                    $("prop_banco2").value = '${cadContratoFrete.contratado.banco2.idBanco}';
                    $("debito_prop").value = '${cadContratoFrete.contratado.debitoProp}';
                    $("percentual_desconto_prop").value = '${cadContratoFrete.contratado.percentualDescontoProp}';
                    $("tipo_desconto_prop").value = '${cadContratoFrete.contratado.tipoDescontoContaCorrente}';
                    $("idcarreta").value = '${cadContratoFrete.carreta.idveiculo}';
                    $("car_placa").value = '${cadContratoFrete.carreta.placa}';
                    $("car_prop").value = '${cadContratoFrete.carreta.proprietario.razaosocial}';
                    $("car_prop_cgc").value = '${cadContratoFrete.carreta.proprietario.cpfCnpj}';
                    $("idbitrem").value = '${cadContratoFrete.biTrem.idveiculo}';
                    $("bi_placa").value = '${cadContratoFrete.biTrem.placa}';
                    $("bi_prop").value = '${cadContratoFrete.biTrem.proprietario.razaosocial}';
                    $("bi_prop_cgc").value = '${cadContratoFrete.biTrem.proprietario.cpfCnpj}';
                    $("vlFreteMotorista").value = colocarVirgula('${cadContratoFrete.vlFreteMotorista}');
                    $("vlTonelada").value = colocarVirgula('${cadContratoFrete.valorTonelada}');
                    $("vlOutrasDeducoes").value = colocarVirgula('${cadContratoFrete.vlOutrasDeducoes}');
                    $("vlOutros").value = colocarVirgula('${cadContratoFrete.outrosDescontos}');
                    $("vlIr").value = colocarVirgula('${cadContratoFrete.vlIr}');
                    $("qtddependentes").value = '${cadContratoFrete.qtdDependentes}';
                    $("vlDependentes").value = colocarVirgula('${cadContratoFrete.vlDependentes}');
                    $("vlBaseIr").value = colocarVirgula('${cadContratoFrete.vlBaseIr}');
                    $("aliqIr").value = colocarVirgula('${cadContratoFrete.aliqIr}');
                    $("vlINSS").value = colocarVirgula('${cadContratoFrete.vlinss}');
                    $("vlJaRetido").value = colocarVirgula('${cadContratoFrete.vlJaRetido}');
                    $("vlRetidoEmpresa").value = colocarVirgula('${cadContratoFrete.vlOutrasEmpresas}');
                    $("vlBaseInss").value = colocarVirgula('${cadContratoFrete.vlBaseInss}');
                    $("aliqInss").value = colocarVirgula('${cadContratoFrete.aliqInss}');
                    $("vlPedagio").value = colocarVirgula('${cadContratoFrete.valorPedagio}');
                    $("vlDescarga").value = colocarVirgula('${cadContratoFrete.valorDescarga}');
                    $("vlTarifas").value = colocarVirgula('${cadContratoFrete.totalTarifas}');
                    $("vlAvaria").value = colocarVirgula('${cadContratoFrete.vlAvaria}');
                    $("vlSescSenat").value = colocarVirgula('${cadContratoFrete.vlSestSenat}');
                    $("vlBaseSesc").value = colocarVirgula('${cadContratoFrete.baseSestSenat}');
                    $("vlImpostos").value = colocarVirgula('${cadContratoFrete.vlImpostos}');
                    $("vlLiquido").value = colocarVirgula('${cadContratoFrete.vlLiquido}');
                    $("vlLiquido2").value = colocarVirgula('${cadContratoFrete.vlLiquido}');
                    $("aliqSescSenat").value = colocarVirgula('${cadContratoFrete.aliqSestSenat}');
                    $("obsOutros").value = '${cadContratoFrete.obsOutrosDescontos}';
                    $("chkReterImpostos").checked = ('${cadContratoFrete.reterImpostos}' == "true" ? true : false);
                    if (<c:out  value="${cadContratoFrete.reterImpostos}" default="false"/> && <c:out  value="${cadContratoFrete.retencaoImpostoOperadoraCFe}" default="false"/>) {
                        $("chkReterImpostos").style.display = "none";
                    }
                    $("cancelada").checked = ('${cadContratoFrete.isCancelada}' == "true" ? true : false);
                    ('${cadContratoFrete.statusCFe.ordinal()}' == "3" ? $("statusContrato").checked = true : $("statusPre").checked = true);
                    if ('${cadContratoFrete.rota.id}' != '0') {
                        $("rota").appendChild(Builder.node('OPTION', {value: "${cadContratoFrete.rota.id}"}, "${cadContratoFrete.rota.descricao}"));
                    }
                    $("rota").value = '${cadContratoFrete.rota.id}';
                    $("idRota").value = '${cadContratoFrete.rota.id}';
                    $("ibgeCidadeOrigem").value = '${cadContratoFrete.rota.origem.cod_ibge}';
                    $("ibgeCidadeDestino").value = '${cadContratoFrete.rota.destino.cod_ibge}';
                    
                    $("eixosSuspensos").value = <c:out value="${cadContratoFrete.eixosSuspensos}" default="0"/>;
                    $("categoriaPamcard").value = <c:out value="${cadContratoFrete.categoriaVeiculo.id }" default="0"/>;
                    $("categoriaNdd").value = <c:out value="${cadContratoFrete.categoriaVeiculoNdd.id }" default="0"/>;
                    $("dataPartida").value = '${cadContratoFrete.dataPartida}';
                    $("dataTermino").value = '${cadContratoFrete.dataTermino}';
                    $("is_tac").value = '${cadContratoFrete.contratado.tac ? "t" : "f"}';
                    $("natureza_cod").value = '${cadContratoFrete.natureza.cod}';
                    $("natureza_cod_desc").value = '${cadContratoFrete.natureza.codigo}';
                    $("natureza_desc").value = '${cadContratoFrete.natureza.descricao}';
                    $("pedagioIdaVolta").checked = ('${cadContratoFrete.pedagioIdaVolta}' == "true" ? true : false);
                    $("base_ir_prop_retido").value = '${cadContratoFrete.baseIRJaRetida}';
                    $("ir_prop_retido").value = '${cadContratoFrete.vlIRJaRetido}';
                    $("base_inss_prop_retido").value = '${cadContratoFrete.baseINSSJaRetida}';
                    $("inss_prop_retido").value = '${cadContratoFrete.vlJaRetido}';
                    $("ciot").value = '${cadContratoFrete.ciot}';
                    $("ciotCodVerificador").value = '${cadContratoFrete.ciotCodVerificador}';
                    if (isConfiguracaoReterImposto) {
                        $("qtdDiaria").value = '${cadContratoFrete.qtdDiarias}';
                        $("idconsignatario").value = '${cadContratoFrete.clienteDiariaParada.idcliente}';
                        $("con_rzs").value = '${cadContratoFrete.clienteDiariaParada.razaosocial}';
                        $("vlUnitarioDiaria").value = colocarVirgula('${cadContratoFrete.valorUnitarioDiaria}');
                        $("vlDiaria").value = colocarVirgula('${cadContratoFrete.valorDiaria}');
                        $("diariaParada").checked = ('${cadContratoFrete.diariaParada}' == "true" ? true : false);
                    }else{
                        $("qtdDiaria2").value = '${cadContratoFrete.qtdDiarias}';
                        $("idconsignatario2").value = '${cadContratoFrete.clienteDiariaParada.idcliente}';
                        $("con_rzs2").value = '${cadContratoFrete.clienteDiariaParada.razaosocial}';
                        $("vlUnitarioDiaria2").value = colocarVirgula('${cadContratoFrete.valorUnitarioDiaria}');
                        $("vlDiaria2").value = colocarVirgula('${cadContratoFrete.valorDiaria}');
                        $("diariaParada2").checked = ('${cadContratoFrete.diariaParada}' == "true" ? true : false);
                    }
                    $("solicitarAutorizacao").checked = ('${cadContratoFrete.precisaAutorizacao}' == "true" ? true : false);
                    $("autorizarSolicitacao").checked = ('${cadContratoFrete.autorizado}' == "true" ? true : false);
                    $("tipoProduto").value = '${cadContratoFrete.tipoProduto.id}';
                    $("os_aberto_veiculo").value = '${cadContratoFrete.veiculo.osAbertoVeiculo}';
                    $("negociacaoAdiantamento").value = '${cadContratoFrete.negociacao.id}';
                    $("negociacaoHidden").value = '${cadContratoFrete.negociacao.id}';
                    $("operadoraCiot").value = '${cadContratoFrete.operacaoCiot}';
                    $("tipoEmbalagem").value = '${cadContratoFrete.tipoEmbalagem.id}';
                    $("cep-origem").value = '${cadContratoFrete.cepOrigem}';
                    $("cep-destino").value = '${cadContratoFrete.cepDestino}';
                    $("id-cidade-origem").value = '${cadContratoFrete.cidadeOrigem.id}';
                    $("id-cidade-destino").value = '${cadContratoFrete.cidadeDestino.id}';
                    $("cidade-origem").value = '${cadContratoFrete.cidadeOrigem.cidade}';
                    $("cidade-destino").value = '${cadContratoFrete.cidadeDestino.cidade}';
                    $("uf-origem").value = '${cadContratoFrete.cidadeOrigem.uf}';
                    $("uf-destino").value = '${cadContratoFrete.cidadeDestino.uf}';
                    $("distancia-contrato-frete").value = '${cadContratoFrete.distancia}';
                    $("tipo-carga").value = '${cadContratoFrete.tipoCarga}';
            
    <c:if test="${configuracao.diariaRetemImposto}">
                    $("idcidadedestino").value = '${cadContratoFrete.cidadeDiaria.idcidade}';
                    $("cid_destino").value = '${cadContratoFrete.cidadeDiaria.descricaoCidade}';
                    $("uf_destino").value = '${cadContratoFrete.cidadeDiaria.uf}';
    </c:if>
                    $("valorPorKM").value = colocarVirgula('${cadContratoFrete.valorPorKm}');
                    $("quantidadeKm").value = ('${cadContratoFrete.quantidadeKm}');
                    //campo abaixo é o campo de codContratoRepom e a função abaixo para verificar
                    //se for zero ele e a TR na qual se encontra não serão exibidos.
                    $("contrRepom").value = '${cadContratoFrete.codContratoRepom}';
                    aparecerContratoRepom($("contrRepom").value); // está comentado mas é só pra saber qual é o metodo.

    <c:if test="${usuario.filial.stUtilizacaoCfeS == 'P' || usuario.filial.stUtilizacaoCfeS == 'A' || usuario.filial.stUtilizacaoCfeS == 'D'}">

                    $("solucoesPedagio").value = '${cadContratoFrete.solucoesPedagio.id}';
                    $("favorecidoPedagio").value = '${cadContratoFrete.favorecidoPedagio}';
    </c:if>

                    $("abastecimentos").value = colocarVirgula('${cadContratoFrete.valorAbastecimento}');
                    var numerosAbastecimentos = '';

                    <c:forEach items="${cadContratoFrete.numerosAbastecimentos}" var="numero" varStatus="status">
                        numerosAbastecimentos += '${numero}';

                        <c:if test="${!status.last}">
                            numerosAbastecimentos += ', '
                        </c:if>
                    </c:forEach>

                    $("lbAbastecimento").innerHTML = numerosAbastecimentos;
                    validacaoValorTonelada();
                    //  validacaoValorKM();


                    var statusCfe = "<c:out value="${cadContratoFrete.statusCFe}" default="0"/>";
                    if (statusCfe == "PENDENTE" && $("is_tac").value == 't') {
                        $("statusPre").checked = true;
                    } else {
                        $("statusContrato").checked = true;
                    }


                    var isTac = '${cadContratoFrete.baseTacAgregado}';
                    if ('${cadContratoFrete.tacAgregado}' == 'true') {
                        $("agregado").checked = true;
                        $("normal").checked = false;
                        $("baseTacAgregado").value = '${cadContratoFrete.baseTacAgregado}';
                        $("basetac").value = '${cadContratoFrete.baseTacAgregado}';
                    } else {
                        //alert("entrou else");
                        $("normal").checked = true;
                        $("agregado").checked = false;
                    }

                    $("controlarTarifasBancariasContratado").value = '${cadContratoFrete.filial.controlarTarifasBancariasContratado}';
                    if('${cadContratoFrete.filial.controlarTarifasBancariasContratado}' == "true"){
                        $("qtdSaques").value = ('${cadContratoFrete.quantidadeSaques}');
                        $("valorPorSaques").value = colocarVirgula('${cadContratoFrete.valorPorSaques}');
                        $("qtdTransf").value = ('${cadContratoFrete.quantidadeTransferencias}');
                        $("valorTransf").value = colocarVirgula('${cadContratoFrete.valorPorTransferencia}');
                    }else{
                        jQuery("#trTarifas").hide();
                    }


                <%--<c:if test="${cadContratoFrete.filial.controlarTarifasBancariasContratado == 'true' && (cadContratoFrete.filial.stUtilizacaoCfeS == 'D' || cadContratoFrete.filial.stUtilizacaoCfeS == 'P')}">--%>
//                    $("trTarifas").style.display = "";
//                    $("controlarTarifasBancariasContratado").value = 'true';
//                    $("qtdSaques").value = ('$ {(cadContratoFrete.quantidadeSaques > 0 ? cadContratoFrete.quantidadeSaques : cadContratoFrete.filial.quantidadeSaquesContratoFrete)}');
//                    $("valorPorSaques").value = colocarVirgula('$ {(cadContratoFrete.valorPorSaques > 0 ? cadContratoFrete.valorPorSaques : cadContratoFrete.filial.valorSaquesContratoFrete)}');
//                    $("qtdTransf").value = ('$ {(cadContratoFrete.quantidadeTransferencias > 0 ? cadContratoFrete.quantidadeTransferencias : cadContratoFrete.filial.quantidadeTransferenciasContratoFrete)}');
//                    $("valorTransf").value = colocarVirgula('$ {(cadContratoFrete.valorPorTransferencia > 0 ? cadContratoFrete.valorPorTransferencia : cadContratoFrete.filial.valorTransferenciasContratoFrete)}');

//                    calculaTotalTarifas();
                    <%--<c:if test="${cadContratoFrete.filial.stUtilizacaoCfeS == 'D'}">--%>
                                //  $("qtdSaques").readonly = 'true';
                                //  $("valorPorSaques").readonly = 'true';
                                // $("qtdTransf").readonly = 'true';
                                //  $("valorTransf").readonly = 'true';
//                                $("vlTarifas").readOnly = true;
//                                $("qtdSaques").readOnly = true;
//                                $("valorPorSaques").readOnly = true;
//                                $("qtdTransf").readOnly = true;
//                                $("valorTransf").readOnly = true;
//                                $("totalSaques").readOnly = true;
//                                $("totalTransf").readOnly = true;
//                                $("vlTarifas").className = 'inputReadOnly8pt';
//                                $("qtdSaques").className = 'inputReadOnly8pt';
//                                $("valorPorSaques").className = 'inputReadOnly8pt';
//                                $("qtdTransf").className = 'inputReadOnly8pt';
//                                $("valorTransf").className = 'inputReadOnly8pt';//className:'inputReadOnly8pt'
//                                $("totalSaques").className = 'inputReadOnly8pt';
//                                $("totalTransf").className = 'inputReadOnly8pt';
                    <%--</c:if>--%>
                <%--</c:if>--%>
                <%--<c:if test="${cadContratoFrete.filial.controlarTarifasBancariasContratado == 'false'}">--%>
//                                $("trTarifas").style.display = "none";
//                                $("controlarTarifasBancariasContratado").value = 'false';
//                                $("qtdSaques").value = ('$ {cadContratoFrete.filial.quantidadeSaquesContratoFrete}');
//                                $("valorPorSaques").value = colocarVirgula('$ {cadContratoFrete.filial.valorSaquesContratoFrete}');
//                                $("qtdTransf").value = ('$ {cadContratoFrete.filial.quantidadeTransferenciasContratoFrete}');
//                                $("valorTransf").value = colocarVirgula('$ {cadContratoFrete.filial.valorTransferenciasContratoFrete}');

                <%--</c:if>--%>

                    getRotaPercurso(false);
                    var documento;
    <c:forEach var="documento" varStatus="status" items="${cadContratoFrete.documentos}">
                    documento = new ContratoFreteDocumento();
                    documento.id = '${documento.id}';
                    documento.tipo = '${documento.tipo}';
                    documento.numero = '${documento.numero}';
                    documento.data = '${documento.data}';
                    documento.origemId = '${documento.origem.idcidade}';
                    documento.origem = '${documento.origem.descricaoCidade}';
                    documento.destinoId = '${documento.destino.idcidade}';
                    documento.destino = '${documento.destino.descricaoCidade}';
                    documento.peso = '${documento.peso}';
                    documento.valorFrete = '${documento.valor}';
                    documento.valorNota = '${documento.valorNota}';
                    documento.volumes = '${documento.volume}';
                    documento.clienteId = '${documento.cliente.idcliente}';
                    documento.qtdEntregas = '${documento.qtdEntregas}';
                    documento.isMostraRotaCliente = '${documento.cliente.mostrarRotasDesseCliente}';
                    documento.filialDestino = '${documento.filialDestino.abreviatura}';
                    documento.idFilialDestino = '${usuario.filial.idfilial}';
                    documento.filialOrigem = '${usuario.filial.abreviatura}';
                    documento.totalCteCIF = '${documento.valorTotalCif}';
                    documento.totalCteFOB = '${documento.valorTotalFob}';
                    documento.totalCteTerceiro = '${documento.valorTotalTerceiro}';
                    documento.valorPedagio = '${documento.valorPedagio}';

                    addDocumentoContratoFrete(documento);

                    if (documento.tipo == "ROMANEIO") {
                        isRomaneio = true;
                    }

    </c:forEach>

                    var pg;
                    invisivel($("trCartaCC"));
    <c:forEach var="pg" varStatus="status" items="${cadContratoFrete.pagamentos}">
                    pg = new ContratoFretePagamento();
                    

                    if (parseFloat("${pg.valor}") > 0 && "${pg.conta.idConta}" == $('contaCC').value && parseFloat($('contaCC').value) > 0 && "${pg.conta.idConta}" != '0' && "${pg.contaCorrente}" == 'true') {
                        $('idPgtoCC').value = "${pg.id}";
                        $('idDespesaCC').value = "${pg.despesa.idmovimento}";
                        $('cartaValorCC').value = colocarVirgula("${pg.valor}");
                        $('cartaDataCC').value = "${pg.dataStr}";
                        $('cartaFPagCC').value = "${pg.fpag.idFPag}";
                        visivel($("trCartaCC"));
                        $('lbDespCC').innerHTML = "${pg.despesa.idmovimento}";
                        $('lbStatusCC').innerHTML = ('${pg.baixado}' === 'true') ? 'Baixado' : 'Em aberto';

                    } else {
                        pg.id = ${pg.id};
                        pg.tipo = '${pg.tipoPagamento}';
                        pg.valor = "${pg.valor}";
                        pg.data = "${pg.dataStr}";
                        pg.fpag = "${pg.fpag.idFPag}";
                        pg.doc = '${pg.documento}';
                        pg.agente_id = ${pg.agente.idfornecedor};
                        pg.agente = "${pg.agente.razaosocial}";
                        pg.despesa_id = ${pg.despesa.idmovimento};
                        pg.fixo = true;
                        pg.percAbastec = "${pg.percAbastecimento}";
                        pg.baixado = ${pg.baixado};
                        pg.contaId = ${pg.conta.idConta};
                        pg.saldoAutorizado = ${pg.saldoAutorizado};
                        pg.planoAgente = "${pg.agente.planoCustoPadrao.idconta}";
                        pg.undAgente = "${pg.agente.unidadeCusto.id}";
                        pg.contaAd = "${pg.contaBancaria}";
                        pg.agenciaAd = "${pg.agenciaBancaria}";
                        pg.favorecidoAd = "${pg.favorecido}";
                        pg.bancoAd = "${pg.banco.idBanco}";
                        pg.tipoFavorecido = "${pg.tipoFavorecido}";
                        pg.nfiscal = "${pg.despesa.nfiscal}";
                        pg.tipoConta = "${pg.tipoConta}";
                        pg.tipoPagamentoCfe = "${pg.tipoPagamentoCfe}";
                        pg.isContaCorrente = ${pg.contaCorrente};
                        pg.isControlarTarifasBancariasContratado = ${pg.parcelaTarifa};
                        pg.valorDesconto = ${pg.valorDesconto};
                        pg.utilizaNegociacao = ($("negociacaoAdiantamento").value != "0");
                        pg.isCarregando = true;
                        pg.idfilial = '${pg.filial.idfilial}';
                        pg.filial = '${pg.filial.abreviatura}';
                        pg.percPgto = ${pg.percentualPag};
                        pg.isValorEditavel = ${pg.isEditarValor};
                        pg.observacao = '${pg.observacao}';
                        pg.fechamentoAgregadoId = '${pg.fechamentoAgregado.id}';
                        pg.dataFechamentoAgregado = '${pg.fechamentoAgregado.dataFechamento}';
                        pg.despesafechamentoAgregadoId = '${pg.fechamentoAgregado.despesa.idmovimento}';
                        addPagto(pg);
                    }

                    /*
                     *Permissão alteração tipo de pagamaneto CF-e
                     **/

    </c:forEach>
                    var despesa;
    <c:forEach var="despesa" varStatus="statusDespesa" items="${cadContratoFrete.despesas}">
                    despesa = new Despesa();

                    despesa.id = '${despesa.idmovimento}';
                    despesa.tipo = ${despesa.avista} ? "a" : "p";
                    despesa.data = '${despesa.dtEmissaoStr}';
                    despesa.serie = "${despesa.serie}";
                    despesa.especie = "${despesa.esp.especie}";
                    despesa.especieId = "${despesa.esp.id}";
                    despesa.nf = "${despesa.nfiscal}";
                    despesa.fornecedor = "${despesa.fornecedor.razaosocial}";
                    despesa.idFornecedor = "${despesa.fornecedor.idfornecedor}";
                    despesa.historico = "${despesa.descHistorico}";
                    despesa.valor = "${despesa.valor}";
                    despesa.venc = "${despesa.duplicatas[0].dtVenc}";
                    despesa.doc = "${despesa.duplicatas[0].movBanco.docum}";
                    despesa.idConta = "${despesa.duplicatas[0].movBanco.conta.idConta}";
                    despesa.isCheque = "${despesa.duplicatas[0].movBanco.cheque}";

                    addDespesa(despesa);

                    var ap;
        <c:forEach var="aprop" varStatus="status" items="${despesa.apropriacoes}">
                    ap = new ApropriacaoDespesa();
                    ap.apropriacao = "${aprop.planocusto.descricao}";
                    ap.idApropriacao = "${aprop.planocusto.idconta}";
                    ap.conta = "${aprop.planocusto.conta}";
                    ap.idUnd = "${aprop.undCusto.id}";
                    ap.und = "${aprop.undCusto.sigla}";
                    ap.idVeiculo = "${aprop.veiculo.idveiculo}";
                    ap.veiculo = "${aprop.veiculo.placa}";
                    ap.incluindo = false;
                    ap.valor = "${aprop.valor}";


                    addPropriacao(despesa.index, ap);

            <c:forEach var="duplicata" items="${despesa.duplicatas}">
                <c:if test="${duplicata.baixado}">
                    $("pcLixo_" +${statusDespesa.count} + "_" +${status.count}).style.display = "none";
                    $("localizaAprop_" +${statusDespesa.count} + "_" +${status.count}).style.display = "none";
                    $("valorAprop_" +${statusDespesa.count} + "_" +${status.count}).readOnly = true;
                    $("valorAprop_" +${statusDespesa.count} + "_" +${status.count}).className = "inputReadOnly8pt";
                    $("localizaUnd_" +${statusDespesa.count} + "_" +${status.count}).style.display = "none";
                </c:if>
            </c:forEach>

        </c:forEach>


        <c:forEach var="duplicata" items="${despesa.duplicatas}">
            <c:if test="${duplicata.baixado}">
                    $("pcLixoDespesa_" +${statusDespesa.count}).style.display = "none";
                    $("inpBaixado_" +${statusDespesa.count}).value = true;
                    $("lblBaixado_" +${statusDespesa.count}).innerHTML = "Baixado";
                    $("localizaForn_" +${statusDespesa.count}).style.display = "none";
                    $("fornecedor_" +${statusDespesa.count}).readOnly = true;
                    $("localizaHist_" +${statusDespesa.count}).style.display = "none";
                    $("historico_" +${statusDespesa.count}).readOnly = true;
                    $("historico_" +${statusDespesa.count}).className = "inputReadOnly8pt";
                    $("serie_" +${statusDespesa.count}).readOnly = true;
                    $("serie_" +${statusDespesa.count}).className = "inputReadOnly8pt";
                    $("notaFiscal_" +${statusDespesa.count}).readOnly = true;
                    $("notaFiscal_" +${statusDespesa.count}).className = "inputReadOnly8pt";
                    $("dtDespesa_" +${statusDespesa.count}).readOnly = true;
                    $("dtDespesa_" +${statusDespesa.count}).className = "inputReadOnly8pt";
                    $("especieDesp_" +${statusDespesa.count}).disabled = true;
                    $("tipoDesp_" +${statusDespesa.count}).disabled = true;
                    $("dtVencimento_" +${statusDespesa.count}).readOnly = true;
                    $("dtVencimento_" +${statusDespesa.count}).className = "inputReadOnly8pt";
                    $("addApropriacao_" +${statusDespesa.count}).style.display = "none";
            </c:if>

        </c:forEach>

    </c:forEach>

                    //Permissao de alteração de valores ao editar
    <c:if test="${param.acao == 2 && param.nivelAlteraValor != 4}">
                    desabilitarCampo('vlFreteMotorista');
                    desabilitarCampo('vlTonelada');
                    desabilitarCampo('vlOutrasDeducoes');
                    desabilitarCampo('vlAvaria');
                    desabilitarCampo('vlOutros');
                    desabilitarCampo('vlPedagio');
                    desabilitarCampo('vlDescarga');
                    desabilitarCampo('vlDiaria');
                    desabilitarCampo('vlUnitarioDiaria');
                    desabilitarCampo('qtdDiaria');
                    //para quando na configuração nao estiver marcado para reter imposto
                    desabilitarCampo('vlDiaria2');
                    desabilitarCampo('vlUnitarioDiaria2');
                    desabilitarCampo('qtdDiaria2');
    </c:if>

                    if ($('solicitarAutorizacao').checked) {
                        $('divSolicitarAutorizacao').style.display = '';
                    }

    <c:if test="${param.nivelAutorizaContratoMaior == 4}">
                    $('divSolicitarAutorizacao').style.display = 'none';
                    $('divAutorizar').style.display = '';
    </c:if>

                    //Mostrando o usuário que autorizou o frete maior
                    if ('${cadContratoFrete.precisaAutorizacao}' == 'true' && '${cadContratoFrete.autorizado}' == 'true') {
                        $('divAutorizar').style.display = 'none';
                        $('divSolicitarAutorizacao').style.display = 'none';
                        $('divAutorizado').style.display = '';
                        $('lbAutorizadoPor').innerHTML = '${cadContratoFrete.usuarioAutorizacao.nome}';
                        $('lbAutorizadoEm').innerHTML = '${cadContratoFrete.autorizadoEm}';
                        $('lbAutorizadoAs').innerHTML = '${cadContratoFrete.autorizadoAs}';
                        $('motivoSolicitacao').readOnly = true;
                        $("motivoSolicitacao").className = "inputReadOnly";
                    }

                    readOnly($("percentualRetencao"));
                } else {
    <c:if test="${param.nivelAlteraFreteTabela != 4}">
                    $('divSolicitarAutorizacao').style.display = '';
    </c:if>
                    aparecerContratoRepom($("contrRepom").value);

                    setDefault();

                    if ($("stUtilizacaoCfeS").value == 'P' || $("stUtilizacaoCfeS").value == 'A' || $("stUtilizacaoCfeS").value == 'D') {
                        $("solucoesPedagio").value = $("solucao_pedagio").value;

                    }
                    
                //se estiver fazendo um novo cadastro...
                if (${param.acao == 1}) { 
                    $("controlarTarifasBancariasContratado").value = '${autenticado.filial.controlarTarifasBancariasContratado}';
                    if('${autenticado.filial.controlarTarifasBancariasContratado}' == "true"){
                        $("qtdSaques").value = ('${autenticado.filial.quantidadeSaquesContratoFrete}');
                        $("valorPorSaques").value = colocarVirgula('${(autenticado.filial.valorSaquesContratoFrete)}');
                        $("qtdTransf").value = ('${(autenticado.filial.quantidadeTransferenciasContratoFrete)}');
                        $("valorTransf").value = colocarVirgula('${(autenticado.filial.valorTransferenciasContratoFrete)}');
                    }else{
                        jQuery("#trTarifas").hide();
                    }
                    
                }
                
                }
//                calculaTotalTarifas();
                alterarFavorecidoPedagio();

    <c:if test="${param.nivelCancelar != 4}">
                $("cancelada").style.display = 'none';
                $("lbCancelado").innerHTML = 'Sem permissão para cancelar!';
    </c:if>

                getDiariaParada();

                //Validar campos exclusivos das operadoras de CIOT
                $('divCiotAgregado').style.display = 'none';
                if ($('filialCfe_' + $('filial').value).value == 'D') {
                    $('divCiotAgregado').style.display = '';
                }

                getBaseRetencao();

    <c:if test="${param.nivelAlteraImpostos != 4}">
                $("vlSescSenat").readOnly = true;
                $("vlSescSenat").className = "inputReadOnly";
                $("vlINSS").readOnly = true;
                $("vlINSS").className = "inputReadOnly";
                $("vlJaRetido").readOnly = true;
                $("vlJaRetido").className = "inputReadOnly";
                $("vlIr").readOnly = true;
                $("vlIr").className = "inputReadOnly";
                $("vlDependentes").readOnly = true;
                $("vlDependentes").className = "inputReadOnly";
                $("chkReterImpostos").style.display = "none";
                $("lbReter").style.display = "none";
    </c:if>

    <c:if test="${param.nivelCiot != 4}">
                $("ciot").readOnly = true;
                $("ciot").className = "inputReadOnly";
                $("ciotCodVerificador").readOnly = true;
                $("ciotCodVerificador").className = "inputReadOnly";
    </c:if>

    <c:if test="${param.nivelNumeroData != 4}">
                $("idcontratofrete").readOnly = true;
                $("idcontratofrete").className = "inputReadOnly";
                $("data").readOnly = true;
                $("data").className = "inputReadOnly";
    </c:if>

                //Permissao para informar valores no contrato diferente da tabela de preco
    <c:if test="${param.nivelAlteraFreteTabela != 4}">
                desabilitarCampo('vlFreteMotorista');
                desabilitarCampo('vlTonelada');
                desabilitarCampo('vlDiaria');
                desabilitarCampo('vlUnitarioDiaria');
                desabilitarCampo('vlDiaria2');
                desabilitarCampo('vlUnitarioDiaria2');
                desabilitarCampo('vlOutros');
                desabilitarCampo('vlPedagio');
                desabilitarCampo('vlDescarga');
    </c:if>

                solicitaAutorizacao(true);

                gerenciaCFe(false);
                //reterImposto();   Comentei essa linha porque a mesma estava sendo chamada mesmo quando não precisava
                //Verificando se está pago ou a pagar - Spring 2 - Tarefa: 88.
                if (countDespesa > 0) {
                    for (var i = 1; i <= countDespesa; i++) {
                        if ($("tipoDesp_" + i) != null) {
                            verContaDespesa(i);
                        }
                    }
                }


                //Funcão para remover todos os ícones de lixeiras das despesas na hora de editar
                if ($("idmotorista").value != 0) {
                    var index = 1;

                    if ($("maxPlano_" + index) != null) {

                        var maxPlano = $("maxPlano_" + index).value;

                        var sair = true;

                        while (sair) {
                            for (var i = 1; i <= maxPlano; i++) {
                                if ($("pcLixo_" + index + "_" + i) != null && $("lblBaixado_" + index).value != 'false') {
                                    $("pcLixo_" + index + "_" + i).style.visibility = "hidden";
                                    $("pcLixoDespesa_" + index).style.visibility = "hidden";
                                } else if ($("pcLixo_" + index + "_" + i) == null) {
                                    sair = false;
                                }
                            }
                            index++;
                        }
                    }
                }


    <c:if test="${usuario.filial.opcaoGerarCIOTTacAgregado == 'true'}">
                $("divCiotAgregado").style.display = '';
    </c:if>
    <c:if test="${usuario.filial.opcaoGerarCIOTTacAgregado == 'false'}">
                $("divCiotAgregado").style.display = 'none';
    </c:if>


    <c:if test="${configuracao.consideraDependentesIr}">
                $('qtddependentes').style.display = '';
                $('vlDependentes').style.display = '';
                $('lbQtdDependentes').style.display = '';
                $('lbVlDependentes').style.display = '';
    </c:if>


                if (isRomaneio) {
    <c:if test="${configuracao.romaneioAutorizacaoPagamento}">
                    $("rota").style.display = "none";
                    $("carregaRota").style.display = "none";
                    $("lblPercuso").style.display = "none";
                    $("percurso").style.display = "none";
                    $("tdRota").innerHTML = "determinada através do Romaneio";
    </c:if>
                }
                validarNegociacao();
                visualizarImpostos();
            }

            function setDefault() {
                $("filial").value = '${usuario.filial.idfilial}';
                $("filial").disabled = (${param.nivelOutrasFiliais < 3});
                $("idcontratofrete").value = '${param.proximoNumero}';
                $("data").value = '${param.dataAtual}';
                $("dataPartida").value = '${param.dataPartida}';

                getRotaPercurso(false);

            }

            function calculaFreteTabela() {
                var tb_vlFrete = 0;
                var tb_tipoValor = $('tab_tipo_valor').value;
                var tb_valor = $('tab_valor').value;
                var tb_peso = $('pesoTonelada').value;
                var tb_valor_frete = colocarPonto($('inTotalValorFrete').value);
                var tb_valor_nota = colocarPonto($('inTotalValorNota').value);
                var tb_qtd_entregas = colocarPonto($('inTotalEntregas').value);
                var considerarCampoCte = $("considerarCampoCte").value;
                var tbValorFreteCte = colocarPonto($("totalValorFreteCte").value);
                var tbValorPesoCte = colocarPonto($("totalValorPesoCte").value);
                
                $('vlTonelada').value = '0,00';
                // Só irá calcular o valor do frete se o motorista não tiver tabela de preço.
                if (parseFloat($('percentual_valor_cte_calculo_cfe').value) <= 0) {                    
                    if (tb_tipoValor == 'p') {
                        tb_vlFrete = parseFloat(tb_valor) * parseFloat(tb_peso);
                        $('vlTonelada').value = colocarVirgula(tb_valor);
                    } else if (tb_tipoValor == 'f') {
                        tb_vlFrete = parseFloat(tb_valor);
                    } else if (tb_tipoValor == 'c') {
                        if (considerarCampoCte == 'tp') {//tp = pelo total da prestação
                            tb_vlFrete = parseFloat(tb_valor_frete) * parseFloat(tb_valor) / 100;
                            $('tabTipoCalculo').innerHTML += ", Total da Prestação";
                        } else if (considerarCampoCte == 'fp') { //fp = pelo frete peso
                            tb_vlFrete = parseFloat(tbValorPesoCte) * parseFloat(tb_valor) / 100;
                            $('tabTipoCalculo').innerHTML += ", Frete Peso";
                        } else if (considerarCampoCte == 'fv') {// fv = pelo frete valor
                            tb_vlFrete = parseFloat(tbValorFreteCte) * parseFloat(tb_valor) / 100;
                            $('tabTipoCalculo').innerHTML += ", Frete Valor";
                        }
                    } else if (tb_tipoValor == 'n') {                        
                        if ($('rota_is_nfe_por_entrega').value === 'false') {
                            tb_vlFrete = parseFloat(tb_valor_nota) * parseFloat(tb_valor) / 100;
                        } else {
                            var valorDaNota = getValorNotas(parseFloat(tb_valor), parseFloat($('rota_valor_minimo').value));
                            tb_vlFrete = valorDaNota;
                            $('tabValorCalculo').innerHTML = 'Valor tabela: ' + parseFloat(tb_valor) + '% NF-e por Entrega.';
                        } 
                    } else if (tb_tipoValor == 'k') {
                        tb_vlFrete = calculaValorKM();
                        if (tb_vlFrete == undefined) {
                            tb_vlFrete = 0;
                        }
                    }

                    if (tb_vlFrete < parseFloat($('rota_valor_minimo').value)) {
                        tb_vlFrete = parseFloat($('rota_valor_minimo').value);
                        $('tabTipoCalculo').innerHTML += ", Valor Mínimo"
                    }
                } else {
                    // Pega o valor do frete calculado pela tabela do motorista
                    tb_vlFrete = $('vlFreteMotorista').value;
                }

                //Verificando o peso excedente
                var pesoSuportado = parseInt($('vei_cap_carga').value) + parseInt($('car_cap_carga').value) + parseInt($('bi_cap_carga').value);
                var pesoFrete = parseInt(colocarPonto($("labTotalPeso").innerHTML));
                var pesoTolerancia = ${configuracao.percentualToleranciaPeso};
                pesoSuportado = parseInt(pesoSuportado) + parseInt((parseInt(pesoSuportado) * parseFloat(pesoTolerancia) / 100));
                var pesoExcedente = parseInt(pesoFrete) - parseInt(pesoSuportado);
                if (parseInt(pesoExcedente) > 0) {
                    tb_vlFrete = parseFloat(tb_vlFrete) + parseFloat((parseFloat($('tab_valor_excedente').value) * parseInt(pesoExcedente)));
                }

                //Verificando a quantidade de entregas
                var qtdEntregasValidas = parseFloat(tb_qtd_entregas) - parseFloat($('tab_qtd_entrega').value) + parseFloat((parseFloat($('tab_qtd_entrega').value) == 0 ? 0 : 1));
                var vlEntrega = parseFloat(parseFloat(qtdEntregasValidas)) * parseFloat($('tab_valor_entrega').value);
                if (parseFloat(vlEntrega) > 0) {
                    tb_vlFrete = parseFloat(tb_vlFrete) + parseFloat(vlEntrega);
                }
                if ($('tabela_is_deduzir_pedagio').value === 'true') {                    
                    tb_vlFrete -= parseFloat(colocarPonto($('vlPedagio').value));
                }
                $('vlFreteMotorista').value = colocarVirgula(parseFloat(tb_vlFrete) + parseFloat($('tab_taxa_fixa').value));
                calculaDiaria();
                calculaImpostos();
            }

            function getTabelaPreco() {
                function e(transport) {
                    var textoresposta = transport.responseText;
                    var acao = '${param.acao}';
                    $('detalhesTabRota').style.display = "none";
                    $('tabTipoCalculo').innerHTML = '';
                    $('tabTipoVeiculo').innerHTML = '';
                    $('tabTipoProduto').innerHTML = '';
                    $('tabTipoCliente').innerHTML = '';
                    $('tabValorCalculo').innerHTML = '';

                    //se deu algum erro na requisicao...
                    if (textoresposta == "-1") {
                        alert('Houve algum problema ao requistar a tabela de preço, favor tente novamente. ');
                        return false;
                    } else {
                        var tabRotaX = jQuery.parseJSON(textoresposta).tabRota;
                        if (tabRotaX.id == '0') {
                            alert('Tabela de preço não encontrada para a rota escolhida!');
                            $('vlUnitarioDiaria').value = '0,00';
                            $('vlPedagio').value = '0,00';
                            calcularTabelaMotoristaCfe();
                            calculaDiaria();
                            calculaImpostos();
                            $('tab_taxa_fixa').value = '0,00';
                            return false;
                        }
                        
                        var tipoCalculoX = 'Não encontrado';
                        var tipoValorX = '';
                        if (tabRotaX.tipoValor == 'p') {
                            tipoCalculoX = 'Peso/TON';
                            tipoValorX = colocarVirgula(tabRotaX.valor) + '/TON';
                        } else if (tabRotaX.tipoValor == 'f') {
                            tipoCalculoX = 'Valor Fixo';
                            tipoValorX = colocarVirgula(tabRotaX.valor);
                        } else if (tabRotaX.tipoValor == 'c') {
                            tipoCalculoX = '% CT-e';
                            tipoValorX = colocarVirgula(tabRotaX.valor) + '%';
                        } else if (tabRotaX.tipoValor == 'n') {
                            tipoCalculoX = '% NF-e';
                            tipoValorX = colocarVirgula(tabRotaX.valor) + '%';
                        } else if (tabRotaX.tipoValor == 'k') {
                            tipoCalculoX = 'RS/KM';
                            tipoValorX = colocarVirgula(tabRotaX.valor);
                        }

                        //Mostrando o labelpar ao usuário
                        if (tabRotaX.distancia > 0) {
                            $("quantidadeKm").value = tabRotaX.distancia;
                        }
                        $('detalhesTabRota').style.display = "";
                        $('tabTipoCalculo').innerHTML = 'Tipo cálculo:' + tipoCalculoX;
                        $('tabTipoVeiculo').innerHTML = 'Veículo:' + tabRotaX.tipoVeiculo.descricao;
                        if (tabRotaX.tipoProduto.descricao != '') {
                            $('tabTipoProduto').innerHTML = 'Operação:' + tabRotaX.tipoProduto.descricao;
                        }
                        if (tabRotaX.cliente.razaosocial != '') {
                            $('tabTipoCliente').innerHTML = 'Cliente:' + tabRotaX.cliente.razaosocial;
                        }
                        $('tabValorCalculo').innerHTML = 'Valor tabela:' + tipoValorX;
                        //campos para calcular a tabela
                        $('vlUnitarioDiaria').value = colocarVirgula(tabRotaX.valorDiaria);
                        var valorPedagio = 0;

                        if (tabRotaX.carregarPedagio) {
                            // O valor do pedágio não será calculado de acordo com a tabela e sim será a soma do valor de pedágio de todos os CT-e(s) que estão vinculados aos manifestos do contrato de frete.
                            for (var i = 1; i <= countDocum; i++) {
                                valorPedagio += parseFloat(colocarPonto($('inpPedagio_' + i).innerHTML));
                            }
                        } else {
                            valorPedagio = tabRotaX.valorPedagio;
                        }

                        $('vlPedagio').value = colocarVirgula(valorPedagio);
                        $('tab_tipo_valor').value = tabRotaX.tipoValor;
                        $('tab_valor').value = tabRotaX.valor;
                        $('tab_valor_maximo').value = tabRotaX.valorMaximo;
                        $('tab_valor_entrega').value = tabRotaX.valorEntrega;
                        $('tab_qtd_entrega').value = tabRotaX.quantidadeEntregas;
                        $('tab_valor_excedente').value = tabRotaX.valorPesoExcedente;
                        $('tab_taxa_fixa').value = tabRotaX.valorTaxaFixa;
                        if(tabRotaX.valorTaxaFixa > 0){
                            $('acrescentardo_taxa').style.display = "inline";
                        }else{
                            $('acrescentardo_taxa').style.display = 'none';
                        }
                        $('tab_id').value = tabRotaX.id;
                        $('considerarCampoCte').value = tabRotaX.considerarCampoCte;
                        if (tabRotaX.tipoValor == 'k') {
                            $("valorDoKM").value = tipoValorX;
                            $("valorPorKM").value = tipoValorX;

                        } else {
                            $("valorDoKM").value = "0.00";
                            $("valorPorKM").value = "0.00";
                        }
                        $('tabela_is_deduzir_pedagio').value = tabRotaX.deduzirPedagio;
                        $('tabela_is_carregar_pedagio_ctes').value = tabRotaX.carregarPedagio;
                        $('rota_valor_minimo').value = tabRotaX.valorMinimo;
                        $('rota_is_nfe_por_entrega').value = tabRotaX.calcularPercentualNFePorEntrega;
                        calcularTabelaMotoristaCfe();
                        calculaFreteTabela();
                        validacaoValorTonelada();
                        atualizarCampos(tabRotaX.tipoValor);
                    }
                }//funcao e()

                //Buscar o cliente dos documentos
                var mxDc = $('maxDocumento').value;
                var idClienteTabela = '0';
                for (i = 1; i <= mxDc; i++) {
                    if ($("idDocumento_" + i) != null) {
                        idClienteTabela = $("idCliente_" + i).value;
                    }
                }

                if ($('rota').value == '0') {
                    alert('Para calcular o frete a rota deverá ser informada!');
                    return false;
                }
                //Buscando o tipo de veiculo
                var idVeiculoTabela = 0;
                if ($('idveiculo').value != '0' && $('idveiculo').value != '') {
                    idVeiculoTabela = $('idveiculo').value;
                }
                if ($('idcarreta').value != '0' && $('idcarreta').value != '') {
                    idVeiculoTabela = $('idcarreta').value;
                }
                if ($('idbitrem').value != '0' && $('idbitrem').value != '') {
                    idVeiculoTabela = $('idbitrem').value;
                }
                if (idVeiculoTabela == '0') {
                    alert('Para calcular o frete o veículo deverá ser informado!');
                    return false;
                }

    <c:if test="${param.acao == 2 && param.nivelAlteraValor != 4}">
                alert('ATENÇÃO: Você não tem privilégios suficientes para alterar o valor do frete!');
                return false;
    </c:if>

                tryRequestToServer(function () {
                    new Ajax.Request("ContratoFreteControlador?acao=carregarTabelaRotaAjax&rotaId=" + $('rota').value + "&veiculoId=" + idVeiculoTabela + "&clienteId=" + idClienteTabela + "&tipoProdutoId=" + $('tipoProduto').value, {method: 'post', onSuccess: e, onError: e});
                });

            }

            function alterarNegociacao(novaNegociacao, origem) {
                var acao = '${param.acao}';
                var max = countPgto;
                var ori = origem;
                novaNegociacao = novaNegociacao + "";
                var NegociacaoAtual = $("negociacaoHidden").value;
                if (acao == '1') {
                    if (NegociacaoAtual != novaNegociacao) {
                        for (var i = 1; i <= max; i++) {
                            removerPagamento(i);
                        }
                        $("negociacaoAdiantamento").value = novaNegociacao;
                        $("negociacaoHidden").value = novaNegociacao;
                        $("labelAdiantamento").style.display = "none";
                        $("camposAdiantamento").style.display = "none";
                        
                        countPgto = 0;
                        validarAddPagto(false);
                        $("origemNegociacao").value = origem;
                    }
                    if (origem != "ma") {
                        $("negociacaoAdiantamento").disabled = true;
                    } else {
                        $("negociacaoAdiantamento").disabled = false;
                    }
                } else {
                    $("negociacaoAdiantamento").disabled = true;
                }

                if ($("negociacaoAdiantamento").value == "0") {
                    visivel($("imgAddPagamento"));
                } else {
                    invisivel($("imgAddPagamento"));
                }
                
                if(${param.nivelLiberacaoSaldoCarta == 4} || $("negociacaoAdiantamento").value == "0"){
                    visivel($("inputAddSaldo"));
                }else{
                    invisivel($("inputAddSaldo"));
            }
            }

            function atualizarCampos(tipo) {
                if (tipo == "p") {
                    desabilitarCampo('vlFreteMotorista');
                    desabilitarCampo('valorPorKM');
                    desabilitarCampo('quantidadeKm');
                    habilitarCampo('vlTonelada');
                } else if (tipo == "f") {
                    habilitarCampo('vlFreteMotorista');
                    desabilitarCampo('vlTonelada');
                    desabilitarCampo('valorPorKM');
                    desabilitarCampo('quantidadeKm');
                } else if (tipo == "c") {
                    if (${param.nivelAlteraFreteTabela != 4} || ${param.nivelAutorizaContratoMaior != 4}) {
                        desabilitarCampo('vlFreteMotorista');
                    } else {
                        habilitarCampo('vlFreteMotorista');
                    }
                    desabilitarCampo('vlTonelada');
                    desabilitarCampo('valorPorKM');
                    desabilitarCampo('quantidadeKm');
                } else if (tipo == "n") {
                    if (${param.nivelAlteraFreteTabela != 4} || ${param.nivelAutorizaContratoMaior != 4}) {
                        desabilitarCampo('vlFreteMotorista');
                    } else {
                        habilitarCampo('vlFreteMotorista');
                    }
                    desabilitarCampo('vlTonelada');
                    desabilitarCampo('valorPorKM');
                    desabilitarCampo('quantidadeKm');
                } else if (tipo == "k") {
                    desabilitarCampo('vlFreteMotorista');
                    desabilitarCampo('vlTonelada');
                    habilitarCampo('valorPorKM');
                    habilitarCampo('quantidadeKm');
                }
            }

            function getRotaPercurso(isAtualizaData) {
                limparPedagio();

                function e(transport) { 
                    var textoresposta = transport.responseText;

                    var acao = '${param.acao}';
                    var rota_ant = '${cadContratoFrete.rota.id}';

                    //se deu algum erro na requisicao...
                    if (textoresposta == "-1") {
                        alert('Houve algum problema ao requistar os percursos, favor tente novamente. ');
                        return false;
                    } else {

                        var rota = jQuery.parseJSON(textoresposta).rota;
                        //caso entre para atualizar o cadastro não irá colocar uma nova data de previsão - historia 3191
                        if (rota.dataPrevista != undefined && isAtualizaData) {
                            $("dataTermino").value = rota.dataPrevista;
                        }

                        var listPercurso = rota.percursos[0].percurso;

                        var percurso;
                        var slct = $("percurso");
                        
//                    var valor = $("percurso").value;
                        var valor = "0";
                        var desc = "----------";

                        removeOptionSelected("percurso");
//                    if(listPercurso== null || listPercurso== undefined){
                        slct.appendChild(Builder.node('OPTION', {value: valor}, desc));
//                    }
                        var length = (listPercurso != undefined && listPercurso.length != undefined ? listPercurso.length : 1);

                        for (var i = 0; i < length; i++) {

                            if (length > 1) {
                                percurso = listPercurso[i];
                                if (i == 0) {
                                    valor = listPercurso[i].id;
                                }
                            } else {
                                percurso = listPercurso;
                            }
                            if (percurso != null && percurso != undefined) {
                                slct.appendChild(Builder.node('OPTION', {value: percurso.id}, percurso.descricao));
                            }
                        }

                        if (acao == '2') {
                            slct.value = '<c:out value="${cadContratoFrete.percurso.id}"/>';
                        } else {
                            slct.value = valor;
                        }
                    }
                }//funcao e()
                tryRequestToServer(function () {
                    new Ajax.Request("ContratoFreteControlador?acao=carregarRotaPercursoAjax&rota=" + ($('rota') != null ? $('rota').value : "") + "&dataPartida=" + $("dataPartida").value, {method: 'post', onSuccess: e, onError: e});
                });
            }

            function getRota() {

                function e(transport) {
                    var textoresposta = transport.responseText;
                    
                    var acao = '${param.acao}';
                    var rota_ant = '${cadContratoFrete.rota.id}';
                    
                    //se deu algum erro na requisicao...
                    if (textoresposta == "-1") {
                        alert('Houve algum problema ao requistar as rotas, favor tente novamente. ');
                        return false;
                    } else {

                        var rotaX = jQuery.parseJSON(textoresposta).list[0].rota;
                    
                        var listRota = rotaX;
                        var rotaY;
                        var slct = $("rota");
                        var rotaIdAnt = slct.value;
                        
                        removeOptionSelected("rota");
                        slct.appendChild(Builder.node('OPTION', {value: "0"}, "Rota não informada"));
                        var length = (listRota != undefined && listRota.length != undefined ? listRota.length : 1);

                        for (var i = 0; i < length; i++) {
                            
                            if (length > 1) {
                                rotaY = listRota[i];
                                if (i == 0) {
                                    valor = listRota[i].id;
                                }
                            } else {
                                rotaY = listRota;
                            }
                            if (rotaY.distancia > 0) {
                                $("quantidadeKm").value = rotaY.distancia;
                            }
                            if (rotaY != null && rotaY != undefined) {
                                //Adicionando os códigos ibge das cidades origem e destino.
                                $("ibgeCidadeOrigem").value += rotaY.origem.cod_ibge + "!!";
                                $("ibgeCidadeDestino").value += rotaY.destino.cod_ibge + "!!";
                                $("nomeRota").value += rotaY.descricao + "!!";
                                $("idRota").value += rotaY.id + "!!";
//                                $("vlFreteMotorista").value = getTabelaRota(rotaY.id);
                                slct.appendChild(Builder.node('OPTION', {value: rotaY.id}, rotaY.descricao));
                                if (length > 1) {
                                    slct.value = rotaIdAnt;
                                } else {
                                    slct.value = rotaY.id;

                                    getRotaPercurso(true);

                                }
                                if (slct.value != 0) {
                                    getTabelaPreco();
                                }

                            }
                        }

                    }

                }//funcao e()
                var mxDc = $('maxDocumento').value;
                var cidadesOrigem = '';
                var cidadesDestino = '';
                var isRotaColeta = false;
                var isRotaTransferencia = false;
                var isRotaEntrega = false;
                var clienteRota = 0;

                for (i = 1; i <= mxDc; i++) {
                    if ($("idDocumento_" + i) != null) {
                        cidadesOrigem += (cidadesOrigem == '' ? '' : ',') + $("idOrigem_" + i).value;
                        cidadesDestino += (cidadesDestino == '' ? '' : ',') + $("idDestino_" + i).value;
                        if ($("idTipoDoc_" + i).value == 'COLETA') {
                            isRotaColeta = true;
                        }
                        if ($("idTipoDoc_" + i).value == 'ROMANEIO') {
                            isRotaEntrega = true;
                        }
                        if ($("idTipoDoc_" + i).value == 'MANIFESTO') {
                            isRotaTransferencia = true;
                        }
                        if (clienteRota == 0 && ($("isMostraRota_" + i).value == 'true' || $("isMostraRota_" + i).value == true)) {
                            clienteRota = $("idCliente_" + i).value;
                        }
                    }
                }

                tryRequestToServer(function () {
                    new Ajax.Request("ContratoFreteControlador?acao=carregarRotaAjax&cidadesOrigem=" + cidadesOrigem + "&cidadesDestino=" + cidadesDestino + "&isRotaColeta=" + isRotaColeta + "&isRotaEntrega=" + isRotaEntrega + "&isRotaTransferencia=" + isRotaTransferencia + "&clienteRota=" + clienteRota, {method: 'post', onSuccess: e, onError: e});
                });
            }


            //@@@@@@@@@@@@@@@@@@ CALCULOS @@@@@@@@@@@@@@@@@@@

//            function calculaAdiantamento(index) {
//                var adiantamento = 0;
//                var adiantamentoMOT = 0;
//                var adiantamentoPROP = 0;
//                var vlLiquido = parseFloat(colocarPonto($("vlLiquido").value)) - parseFloat($("vlTarifas").value);
//                var negociacao = $("negociacaoAdiantamento").value;
//                for(var i = 0; i < listaNegociacoesRegras.length; i++){
//                    if(listaNegociacoesRegras[i].negociacaoAdiantamento == negociacao){
//                        
//                    if((listaNegociacoesRegras[i].tipo == 'a') && (listaNegociacoesRegras[i].tipoFav =='m')){
//                        adiantamentoMOT += listaNegociacoesRegras[i].percentual;
//                    }else if((listaNegociacoesRegras[i].tipo == 'a') && (listaNegociacoesRegras[i].tipoFav =='p')){
//                        adiantamentoMOT += listaNegociacoesRegras[i].percentual;
//                    }
//                }
//                }
//                adiantamento = ($("tipoFavorecido_"+index).value == 'p' ? adiantamentoPROP : adiantamentoMOT);
//                var vlAdiantamento = parseFloat(adiantamento) / 100 * vlLiquido;
//                $("valorPgto_" + index).value = colocarVirgula(vlAdiantamento, 2);
//            }
            function calcula() {
                /*impostos*/
                if ($("vlOutros").value == "") {
                    $("vlOutros").value = "0,00";
                }
                if ($("vlPedagio").value == "") {
                    $("vlPedagio").value = "0,00";
                }
                if ($("vlAvaria").value == "") {
                    $("vlAvaria").value = "0,00";
                }
                if ($("vlOutrasDeducoes").value == "") {
                    $("vlOutrasDeducoes").value = "0,00";
                }
                var ir = pontoParseFloat($("vlIr").value);
                var inss = pontoParseFloat($("vlINSS").value);
                var sest = pontoParseFloat($("vlSescSenat").value);
                var outrasDed = pontoParseFloat($("vlOutrasDeducoes").value);

                var impostos = ir + inss + sest + outrasDed;
                /*valores*/
                var abastecimento = parseFloat($("abastecimentos").value);
                var frete = pontoParseFloat($("vlFreteMotorista").value);
                var outrosVal = pontoParseFloat($("vlOutros").value);
                var pedagio = pontoParseFloat($("vlPedagio").value);
                var diaria = (isConfiguracaoReterImposto ? pontoParseFloat($("vlDiaria").value) : pontoParseFloat($("vlDiaria2").value));
                var descarga = pontoParseFloat($("vlDescarga").value);
                var valores = (frete + outrosVal + pedagio + diaria + descarga);
                var avaria = pontoParseFloat($("vlAvaria").value);
                var liquido = (valores - impostos - avaria - abastecimento);
                var valorTarifas = pontoParseFloat($("vlTarifas").value);
                if ($("controlarTarifasBancariasContratado").value && ($("stUtilizacaoCfeS").value == 'P' || $("stUtilizacaoCfeS").value == 'D' || $("stUtilizacaoCfeS").value == 'A')) {
                    liquido = liquido + valorTarifas;
                }

                /*Imprimindo na tela*/
                $("vlImpostos").value = colocarVirgula(impostos);
                $("vlLiquido").value = colocarVirgula(liquido);
                $("vlLiquido2").value = colocarVirgula(liquido);

                if (countPgto == 0) {
                    validarAddPagto(false);
                } else if (${param.acao != 2}) {
                    recalcularPgtos();
                }
            }


             /** 
            * @param {String} tipo tipo = A => adiantamento    /    S => saldo
            * */
            function getDadosRegra(tipo){
                var regra;
                for (var i = 0; i < getNegociacao().regras.length; i++) {
                    regra = getNegociacao().regras[i];
                    if (regra.tipo == tipo) {
                        return regra;
                    }
                }
            }

            function calcularAdiantamentoFilial(listaFiliais, arrayFilialOrigem, vlContratoLiquido, totalCte, negociacao, fob, cif){
                if(listaFiliais == null || listaFiliais == undefined){
                    listaFiliais = new filiais();
                }
                var pagamento = null;
                var arrayPagamentos = null;
                var countArrayPagamentos = 0;
                var percVlFilial = 0;
                var valorContratoFilial = 0;
                var contadorRegras = 0;
                var contadorFiliais = 0;
                var contadorRegrasGeral = (listaFiliais.length * negociacao.regras.length);
                var totalRegrasGeral = 0;
                var totalAdiantamentoGeral = 0;
                var totalSaldoGeral = 0;
                countArrayPagamentos = 0;
                //Array para adicionar os pagamentos prontos antes de adicionar no dom e na tela.
                arrayPagamentos = new Array();
                var valorAdiantamento = $("valorAdiantamento").value;
                    valorAdiantamento = roundABNT(parseFloat(colocarPonto(valorAdiantamento)),2);
                var quantidadeDivisaoAdiantamento = 1;
                var pagamentoFrete = "";
                var saldoOrigem = 0;
                var valorOrigemAdiantamento = 0;
                for (var ori = 0; ori < 1; ori++) {
                    
                    if (arrayFilialOrigem[ori] != undefined) {
                        
                        // atenção! o campo de percVlFilial estava com RoundABNT, dessa forma os valores ficavam acima do total de frete.
                    percVlFilial = (arrayFilialOrigem[ori].valorTotal * 100) / totalCte;
                    
                    //Guardar percentual filial
                    valorContratoFilial = roundABNT((vlContratoLiquido * percVlFilial / 100),2);
                    valorOrigemAdiantamento = valorContratoFilial;
                    if (valorContratoFilial < valorAdiantamento) {
                        for (var i = 0; i < arrayFilialOrigem.length; i++) {
                                var atual = arrayFilialOrigem[i];
                                if (atual.totalCteCIF !== null && atual.totalCteCIF !== undefined && parseFloat(atual.totalCteCIF) > 0) {
                                    var percAtual1 = roundABNT((atual.totalCteCIF*100)/cif,2);
                                    var valorAtual1 = roundABNT((valorContratoFilial/100)*percAtual1,2);
                                    pagamento = new ContratoFretePagamento();
                                    pagamento.totalFilialPagamento = percVlFilial;
                                    pagamento.tipo = 'a';
                                    pagamento.fixo = true;
                                    pagamento.utilizaNegociacao = true;
                                    pagamento.filialDestino = arrayFilialOrigem[0].nomeFilial;
                                    pagamento.idfilial = arrayFilialOrigem[0].filialId;
                                    pagamento.data = dataAtual;
                                    pagamento.valor = valorAtual1;
                                    pagamento.isValorEditavel = getDadosRegra(pagamento.tipo).isValorEditavel;
                                    pagamento.tipoFavorecido = getDadosRegra(pagamento.tipo).tipoFav;
                                    pagamento.observacao = "Frete CIF referente a filial de destino " + atual.filialDestino;
                                    arrayPagamentos[countArrayPagamentos++] = pagamento;
                                    contadorFiliais++;
                                }
                        }
//                        for(var divisao = 0; divisao < quantidadeDivisaoAdiantamento; divisao++){
//                            pagamento = new ContratoFretePagamento();
//                            pagamento.totalFilialPagamento = percVlFilial;
//                            pagamento.tipo = 'a';
//                            pagamento.fixo = true;
//                            pagamento.utilizaNegociacao = true;
//                            pagamento.filialDestino = arrayFilialOrigem[0].nomeFilial;
//                            pagamento.idfilial = arrayFilialOrigem[0].filialId;
//                            pagamento.data = dataAtual;
//                            pagamento.valor = valorContratoFilial/quantidadeDivisaoAdiantamento;
//                            pagamento.isValorEditavel = getDadosRegra(pagamento.tipo).isValorEditavel;
//                            pagamento.tipoFavorecido = getDadosRegra(pagamento.tipo).tipoFav;
//                            arrayPagamentos[countArrayPagamentos++] = pagamento;
//                            contadorFiliais++;
//                        }
                        
                        
                        
                        for(var fl = 0; fl < listaFiliais.length; fl++) {   
                            percVlFilial = roundABNT((listaFiliais[fl].valorTotal * 100) / fob,2);
                            
                            //Guardar percentual filial
                            valorContratoFilial = roundABNT(((valorAdiantamento - valorOrigemAdiantamento) * (percVlFilial/100)),2);
                            pagamento = new ContratoFretePagamento();
                            pagamento.totalFilialPagamento = percVlFilial;
                            pagamento.tipo = 'a';
                            pagamento.fixo = true;
                            pagamento.utilizaNegociacao = true;
                            pagamento.filialDestino = listaFiliais[fl].nomeFilial;
                            pagamento.idfilial = listaFiliais[fl].filialId;
                            pagamento.data = dataAtual;
                            pagamento.valor = valorContratoFilial;
                            pagamento.isValorEditavel = getDadosRegra(pagamento.tipo).isValorEditavel;
                            pagamento.tipoFavorecido = getDadosRegra(pagamento.tipo).tipoFav;
                            pagamento.observacao = "Frete FOB referente a filial de destino " + listaFiliais[fl].nomeFilial;
                            arrayPagamentos[countArrayPagamentos++] = pagamento;
                            contadorFiliais++;
                        }
                    }else{
                        for (var i = 0; i < arrayFilialOrigem.length; i++) {
                                var atual = arrayFilialOrigem[i];
                                if (atual.totalCteCIF !== null && atual.totalCteCIF !== undefined && parseFloat(atual.totalCteCIF) > 0) {
                                    var percAtual2 = roundABNT((atual.totalCteCIF*100)/cif,2);
                                    var valorAtual2 = roundABNT((valorAdiantamento/100)*percAtual2,2);
                                    pagamento = new ContratoFretePagamento();
                                    pagamento.totalFilialPagamento = percVlFilial;
                                    pagamento.tipo = 'a';
                                    pagamento.fixo = true;
                                    pagamento.utilizaNegociacao = true;
                                    pagamento.filialDestino = arrayFilialOrigem[0].nomeFilial;
                                    pagamento.idfilial = arrayFilialOrigem[0].filialId;
                                    pagamento.data = dataAtual;
                                    pagamento.valor = valorAtual2;
                                    pagamento.isValorEditavel = getDadosRegra(pagamento.tipo).isValorEditavel;
                                    pagamento.tipoFavorecido = getDadosRegra(pagamento.tipo).tipoFav;
                                    pagamento.observacao = "Frete CIF referente a filial de destino " + atual.filialDestino;
                                    arrayPagamentos[countArrayPagamentos++] = pagamento;
                                    contadorFiliais++;
                                }
                        }
                        for(var i = 0; i < arrayFilialOrigem.length; i++){
                            var atual = arrayFilialOrigem[i];
                                if (atual.totalCteCIF !== null && atual.totalCteCIF !== undefined && parseFloat(atual.totalCteCIF) > 0) {
                                    var percAtual3 = roundABNT((atual.totalCteCIF*100)/cif,2);
                                    var valorAtual3 = roundABNT(((valorContratoFilial - valorAdiantamento)/100)*percAtual3,2);
                                    pagamento = new ContratoFretePagamento();
                                    pagamento.totalFilialPagamento = percVlFilial;
                                    pagamento.tipo = 's';
                                    pagamento.fixo = true;
                                    pagamento.utilizaNegociacao = true;
                                    pagamento.filialDestino = arrayFilialOrigem[0].nomeFilial;
                                    pagamento.idfilial = arrayFilialOrigem[0].filialId;
                                    pagamento.data = dataAtual;
                                    pagamento.valor = valorAtual3;
                                    pagamento.isValorEditavel = getDadosRegra(pagamento.tipo).isValorEditavel;
                                    pagamento.tipoFavorecido = getDadosRegra(pagamento.tipo).tipoFav;
                                    pagamento.observacao = "Frete CIF referente a filial de destino " + atual.filialDestino;
                                    arrayPagamentos[countArrayPagamentos++] = pagamento;
                                    contadorFiliais++;

                                    saldoOrigem = valorContratoFilial - valorAdiantamento;
                                }
                        
                        }
//                        for(var divisao = 0; divisao < quantidadeDivisaoAdiantamento; divisao++){
//                            pagamento = new ContratoFretePagamento();
//                            pagamento.totalFilialPagamento = percVlFilial;
//                            pagamento.tipo = 'a';
//                            pagamento.fixo = true;
//                            pagamento.utilizaNegociacao = true;
//                            pagamento.filialDestino = arrayFilialOrigem[0].nomeFilial;
//                            pagamento.idfilial = arrayFilialOrigem[0].filialId;
//                            pagamento.data = dataAtual;
//                            pagamento.valor = valorAdiantamento/quantidadeDivisaoAdiantamento;
//                            pagamento.isValorEditavel = getDadosRegra(pagamento.tipo).isValorEditavel;
//                            pagamento.tipoFavorecido = getDadosRegra(pagamento.tipo).tipoFav;
//                            arrayPagamentos[countArrayPagamentos++] = pagamento;
//                            contadorFiliais++;
//                        }
//                        pagamento = new ContratoFretePagamento();
//                        pagamento.totalFilialPagamento = percVlFilial;
//                        pagamento.tipo = 's';
//                        pagamento.fixo = true;
//                        pagamento.utilizaNegociacao = true;
//                        pagamento.filialDestino = arrayFilialOrigem[0].nomeFilial;
//                        pagamento.idfilial = arrayFilialOrigem[0].filialId;
//                        pagamento.data = dataAtual;
//                        pagamento.valor = valorContratoFilial - valorAdiantamento;
//                        pagamento.isValorEditavel = getDadosRegra(pagamento.tipo).isValorEditavel;
//                        pagamento.tipoFavorecido = getDadosRegra(pagamento.tipo).tipoFav;
//                        arrayPagamentos[countArrayPagamentos++] = pagamento;
//                        contadorFiliais++;
//                        
//                        saldoOrigem = valorContratoFilial - valorAdiantamento;
                    }
                }
            }
            
            for (var fil = 0; fil < listaFiliais.length; fil++) {
                    
//                    percVlFilial = roundABNT((listaFiliais[fil].valorTotal * 100) / totalCte,3);
                    percVlFilial = roundABNT((listaFiliais[fil].valorTotal * 100) / fob,2);
                    // criando os adiantamentos com base na quantidade de cheque
                    if (arrayFilialOrigem == undefined || arrayFilialOrigem.length == 0) {
                        for(var divisao = 0; divisao < quantidadeDivisaoAdiantamento; divisao++){
                            pagamento = new ContratoFretePagamento();
                            pagamento.totalFilialPagamento = percVlFilial;
                            pagamento.tipo = 'a';
                            pagamento.fixo = true;
                            pagamento.utilizaNegociacao = true;
                            pagamento.filialDestino = listaFiliais[fil].nomeFilial;
                            pagamento.idfilial = listaFiliais[fil].filialId;
                            pagamento.data = dataAtual;
                            pagamento.valor = valorAdiantamento/quantidadeDivisaoAdiantamento;
                            pagamento.isValorEditavel = getDadosRegra(pagamento.tipo).isValorEditavel;
                            pagamento.tipoFavorecido = getDadosRegra(pagamento.tipo).tipoFav;
                            pagamento.observacao = "Frete FOB referente a filial de destino " + listaFiliais[fil].nomeFilial;
                            arrayPagamentos[countArrayPagamentos++] = pagamento;
                            contadorFiliais++;
                        }
                    }
                    
                    //Guardar percentual filial
                    valorContratoFilial = roundABNT(((vlContratoLiquido - valorAdiantamento - saldoOrigem) * percVlFilial / 100),2);

                    pagamento = new ContratoFretePagamento();
                    pagamento.totalFilialPagamento = percVlFilial;
                    pagamento.tipo = 's';
                    pagamento.fixo = true;
                    pagamento.utilizaNegociacao = true;
                    pagamento.filialDestino = listaFiliais[fil].nomeFilial;
                    pagamento.idfilial = listaFiliais[fil].filialId;
                    pagamento.data = dataAtual;
                    pagamento.valor = valorContratoFilial;
                    pagamento.isValorEditavel = getDadosRegra(pagamento.tipo).isValorEditavel;
                    pagamento.tipoFavorecido = getDadosRegra(pagamento.tipo).tipoFav;
                    pagamento.observacao = "Frete FOB referente a filial de destino " + listaFiliais[fil].nomeFilial;
                    arrayPagamentos[countArrayPagamentos++] = pagamento;
                    contadorFiliais++;
                }
                
                return arrayPagamentos;
            }

            //@@@@@@@@@@@@@@@@@@ CALCULOS @@@@@@@@@@@@@@@@@@@
            
            function validarAddPagto(isValidarCampos) {
                
                try{
                    isValidarCampos = (isValidarCampos == null || isValidarCampos == undefined ? true : isValidarCampos);
                    //Validando antes de incluir o Pagamento
                    var aviso = "";
                    var vlLiquido = parseFloat(colocarPonto($('vlLiquido').value));
                    var vlContrato = parseFloat(colocarPonto($("vlFreteMotorista").value));
                    var valorTarifas = pontoParseFloat($("vlTarifas").value);
//                    if ($("controlarTarifasBancariasContratado").value && ($("stUtilizacaoCfeS").value == 'P' || $("stUtilizacaoCfeS").value == 'D')) {
//                        vlLiquido = vlLiquido - valorTarifas;
//                    }
                    if ($('tipo_desconto_prop').value == '2') {
                        // ^--- Sobre o valor do frete
                        var vlCC = (vlContrato * parseFloat(colocarVirgula($('percentual_desconto_prop').value))) / 100;

                        if (vlCC > parseFloat($('debito_prop').value)) {
                            vlCC = $('debito_prop').value;
                        }

                        vlLiquido = vlLiquido - vlCC;
                    }

                    var pagamento = null;
                    var arrayPagamentos = null;
                    var countArrayPagamentos = 0;
                    var listaFilial = new Array();
                    var arrayFilialOrigem = new Array();

                    if ($('idmotorista').value == 0) {
                        aviso = ('Informe o motorista corretamente!');
                    } else if ($('idveiculo').value == 0) {
                        aviso = ('Informe o veículo corretamente!');
                    } else if (vlLiquido <= 0) {
                        aviso = ('Informe o valor do contrato corretamente!');
                    } else {
                        
                        if ($("negociacaoAdiantamento").value == '0') {

                            if (countPgto == 0) {
                                var adiantamento = new ContratoFretePagamento();
                                adiantamento.fixo = true;
                                adiantamento.percPgto = 0;
                                adiantamento.tipoFavorecido = "p";
                                //carregava automaticamente 'não selecionado' quando não tinha forma de pagamentos - historia 3289
    //                            adiantamento.fpag = '1';

                                addPagto(adiantamento);
                                var saldo = new ContratoFretePagamento();
                                saldo.tipo = "s";
                                saldo.fixo = true;
                                saldo.percPgto = 100;
                                saldo.tipoFavorecido = "p";
                                saldo.valor = vlLiquido;
                                addPagto(saldo);
                            } else {
                                addPagto();
                            }
                        } else {
                            if (${param.acao != 2}) {
                                var totalCte = 0;
                                    for (var i = 0, max = listaNegociacoes.length; i < max; i++) {
                                        if ($("negociacaoAdiantamento").value == listaNegociacoes[i].valor) {
                                            //countArrayPagamentos
                                            arrayPagamentos = new Array();
                                            countArrayPagamentos = 0;
                                            //Quardando o tipo de calculo
                                            $("tipoCalculoNegociacao").value = listaNegociacoes[i].tipoCalculo;
                                            //Calculo dos pagamentos de como estava antes.
                                            
                                            // se houver apenas um adiantamento na regra, deverá ser criado um saldo zerado.
                                            if (listaNegociacoes[i].regras.length === 1 && listaNegociacoes[i].regras[0].tipo == "a" ) {
                                                listaNegociacoes[i].regras.push(new regrasNegociacao(0, 's', 0));
                                                listaNegociacoes[i].regras[1].isValorEditavel = true;
                                            }
                                            if (listaNegociacoes[i].tipoCalculo == "pc") {
                                                for (var k = 0; k < listaNegociacoes[i].regras.length; k++) {
                                                    pagamento = new ContratoFretePagamento();
                                                    pagamento.totalFilialPagamento = 0;
                                                    pagamento.tipo = listaNegociacoes[i].regras[k].tipo;
                                                    pagamento.tipoPagamentoCfe = listaNegociacoes[i].regras[k].pagamentoCfe;
                                                    pagamento.tipoFavorecido = listaNegociacoes[i].regras[k].tipoFav;
                                                    pagamento.fixo = true;
                                                    pagamento.utilizaNegociacao = true;
                                                    pagamento.percPgto = listaNegociacoes[i].regras[k].percentual;
                                                    pagamento.isValorEditavel = listaNegociacoes[i].regras[k].isValorEditavel;
                                                    pagamento.fpag = listaNegociacoes[i].regras[k].idFpag;
                                                    if (parseFloat(listaNegociacoes[i].regras[k].percentual) != 0) {
                                                        pagamento.valor = (vlLiquido * listaNegociacoes[i].regras[k].percentual / 100);
                                                    }
                                                    
                                                    arrayPagamentos[countArrayPagamentos++]= pagamento;
                                                }
                                                $("labelAdiantamento").style.display = "none";
                                                $("camposAdiantamento").style.display = "none";
                                            }else if (listaNegociacoes[i].tipoCalculo == "rf") {
                                                $("labelAdiantamento").style.display = "";
                                                $("camposAdiantamento").style.display = "";
                                                var percentADT = parseFloat(0);
                                                for (var k = 0; k < listaNegociacoes[i].regras.length; k++) {
                                                    if (listaNegociacoes[i].regras[k].tipo == "a") {
                                                        percentADT = percentADT + parseFloat(listaNegociacoes[i].regras[k].percentual);
                                                    }
                                                }
                                                $("valorAdiantamento").value = (roundABNT((parseFloat(colocarPonto($("vlLiquido").value)) / 100) * percentADT,2));
                                            }
                                        }
                                    }
                                
                                //Regra de adicionar os pagamentos 
                                if (arrayPagamentos != null && arrayPagamentos.length > 0) {
                                    for (var i = 0, max = arrayPagamentos.length; i < max; i++) {
                                        addPagto(arrayPagamentos[i]);
                                    }
                                }
                            }
                        }
//                        addTarifaBancaria();
                        verificarSobraPgto();
                    }

                    if (isValidarCampos && aviso != "") {
                        alert(aviso);
                        return null;
                    }

                    //A cada adição de pagamento será recuperado a conta do motorista ou proprietario.
                    var maxCampos = parseInt($("maxPagamento").value, 10);
                    for (i = 1; i <= maxCampos; i++) {
                        alteraTipoFavorecido(i);
                    }
                }catch(e){
                    console.log(e);
                }
            }

            function criarSaldoSecundario(){
                                    for (var i = 1; i <= parseFloat($("maxPagamento").value); i++) {
                                        if($("valorPgto_"+i)){
                                            if($("tipoPagto_"+i).value == 's'){
                                                jQuery('#valorPgto_'+i).attr('disabled',false);
                                                jQuery('#valorPgto_'+i).attr('readonly',false);
                                                jQuery('#valorPgto_'+i).removeClass('inputReadOnly8pt');
                                                jQuery('#valorPgto_'+i).addClass('fieldMin');
                                            }
                                        }
                                    }
                                    var pagamento = new ContratoFretePagamento();
                                    pagamento.tipo = "s";
                                    pagamento.tipoFavorecido = 'p';
                                    pagamento.fixo = true;
                                    pagamento.utilizaNegociacao = true;
                                    pagamento.totalFilialPagamento = 0;
                                    pagamento.percPgto = 0;
                                    pagamento.valor = 0;
                                    pagamento.isValorEditavel = true;
                                    pagamento.idfilial = jQuery('#filial').val();
                                    pagamento.data = converterDataBR(addDays(converterDataUSA(dataAtual), 0));
                                    addPagto(pagamento);

                    var maxCampos = parseInt($("maxPagamento").value, 10);
                    for (i = 1; i <= maxCampos; i++) {
                        alteraTipoFavorecido(i);
                    }
                }

            function getNegociacao(){
                for(var qq = 0; qq < listaNegociacoes.length; qq++){
                    if(listaNegociacoes[qq].valor == jQuery("select[id='negociacaoAdiantamento']").val()){
                        return listaNegociacoes[qq];
                    }
                }
                return null;
            }
    
            function calcularRateioFilial() {
                var listaFilial = new Array();
                var arrayFilialOrigem = new Array();
                var totalCte = 0;
                var totalFob = 0;
                var totalCif = 0;
                var vlLiquido = parseFloat(colocarPonto($('vlLiquido').value));
                var valorAdiantamento = $("valorAdiantamento").value;
                if (valorAdiantamento == "") {
                    alert("Valor do adiantamento está em branco.");
                    return false;
                }
                if (roundABNT(parseFloat(vlLiquido),3) < roundABNT(parseFloat(colocarPonto(valorAdiantamento)),3)) {
                    alert("Valor do adiantamento maior que o valor do contrato.");
                    return false;
                }
                var max = countPgto;
                for (var linha = 1; linha <= max; linha++) {
                    if ($("trPgto_" + linha) != null) {
                        Element.remove($("trPgto_" + linha));
                        Element.remove($("trObs_" + linha));
                    }
                }
                countPgto = 0;
                if (countDocum == 0) {
                    alert("Não existe documentos selecionados. Favor selecionar os documentos antes de continuar.");
                }
                //Nova forma de calculo com filiais de destinos e origem.
                //Percorrendo a lista de documentos para gerar a lista das filiais com os seus respectivos valores
                //Lista com os documentos adicionado no contrato de frete EX: MANIFESTO/COLETA ETC..
                for (var j = 1; j <= countDocum; j++) {
                    totalFob = parseFloat(totalFob) + parseFloat(listadocumento[j].totalCteFOB);
                    totalCif = parseFloat(totalCif) + parseFloat(listadocumento[j].totalCteCIF);
                }
                for (var j = 1; j <= countDocum; j++) {
                    if (listadocumento[j].tipo == "MANIFESTO") {

                        if (listadocumento[j].totalCteFOB > 0) {
                            addFilial(listaFilial,null, new Filial(listadocumento[j].idFilialDestino, listadocumento[j].totalCteFOB, false, listadocumento[j].filialDestino));
                        }
                        if (listadocumento[j].totalCteTerceiro > 0) {
                            addFilial(listaFilial, null, new Filial(listadocumento[j].idFilialDestino, listadocumento[j].totalCteTerceiro, false, listadocumento[j].filialDestino));
                        }
                        if (listadocumento[j].totalCteCIF > 0) {
                            var e = document.getElementById("filial");
                            var itemSelecionado = e.options[e.selectedIndex].text;
                            addFilial(listaFilial, arrayFilialOrigem, new Filial($("filial").value, listadocumento[j].totalCteCIF, true, itemSelecionado, listadocumento[j].totalCteCIF, listadocumento[j].filialDestino));
                        }

                        //Total geral dos ct-es que estão nos manifestos
                        totalCte += (parseFloat(listadocumento[j].totalCteCIF) + parseFloat(listadocumento[j].totalCteFOB) + parseFloat(listadocumento[j].totalCteTerceiro));
                        //Calcula os adiantamentos e saldos para cada um da lista de Negociações.
                    }
                }
                arrayPagamentos = calcularAdiantamentoFilial(listaFilial, arrayFilialOrigem, vlLiquido, totalCte, getNegociacao(), totalFob, totalCif);
                if (arrayPagamentos != null && arrayPagamentos.length > 0) {
                    for (var i = 0, max = arrayPagamentos.length; i < max; i++) {
                        addPagto(arrayPagamentos[i], undefined, false, true);// pagamento, controlaTarifa, isClone, isRateio
                    }
                    $("isCriarSaldoSecundario").value = true;
                }
            }
            
            function addFilial(arrayFilial,arrayFilialOrigem, filial){
                var posicao = -1;
                
                if (arrayFilial != null && filial != null) {
                    for (var i = 0; i < arrayFilial.length; i++) {
                        
                        if (arrayFilial[i].filialId == filial.filialId && !filial.isFlagOrigem) {
                            posicao = i;
                            break;
                        }
                    }
                    if (arrayFilialOrigem != null) {
                        for (var i = 0; i < arrayFilialOrigem.length; i++) {
                            if (filial.isFlagOrigem) {
                                arrayFilialOrigem[i].valorTotal= parseFloat(arrayFilialOrigem[i].valorTotal) + parseFloat(filial.valorTotal);
                            }
                            if (arrayFilialOrigem[i].filialId === filial.filialId && arrayFilialOrigem[i].filialDestino === filial.filialDestino && !arrayFilialOrigem.isFlagOrigem) {
                                posicao = i;
                                break;
                            }
                        }
                    }
                    if (posicao == -1) {
                        if (arrayFilialOrigem != null && filial.isFlagOrigem) {
                            //Novo array para guardar só os CIFs
                            arrayFilialOrigem[arrayFilialOrigem.length]=filial;
                        }else{
                            arrayFilial[arrayFilial.length]=filial;
                        }
                    }else{
                        if (arrayFilialOrigem != null && filial.isFlagOrigem) {
                            //Novo array para guardar só os CIFs
                            arrayFilialOrigem[posicao].valorTotal= parseFloat(arrayFilialOrigem[posicao].valorTotal) + parseFloat(filial.valorTotal);
                            arrayFilialOrigem[posicao].nomeFilial = filial.nomeFilial;
                            arrayFilialOrigem[posicao].idFilial = filial.filialId;
                        }else{
                            arrayFilial[posicao].valorTotal= parseFloat(arrayFilial[posicao].valorTotal) + parseFloat(filial.valorTotal);
                            arrayFilial[posicao].nomeFilial = filial.nomeFilial;
                            arrayFilial[posicao].idFilial = filial.filialId;
                        }
                    }
                }
            }
            
            function addPagto(pagamento, isControlarTarifasBancariasContratado, isClone, isRateio) {
                if (pagamento == null || pagamento == undefined) {
                    pagamento = new ContratoFretePagamento();
                }
                
                if (isRetencaoImpostoOperadoraCFe()) {
                    if (pagamento.tipo === "s" && getPrimeiroSaldo() !== -1) {
                        alert("ATENÇÂO: Só é possivel adicionar um saldo, pois a opção 'A retenção de impostos será realizada pela REPOM' esta ativa!");
                        return false;
                    }
                }
                
                countPgto++;
                var validarData = "alertInvalidDate(this)";
                var formatarData = "fmtDate(this, event)";
                var celulaZebrada = ((countPgto % 2) == 0 ? 'celulaZebra1' : 'celulaZebra2');
                var optPagConfig = '<c:out value="${configuracao.fpag.idFPag}" default="1"/>'; //Default 1 pois equivale a opção 'Não Específicado' em Configurações - Marcos - PROB - 3685

                var controlarTarifasBancariasContratado = (isControlarTarifasBancariasContratado == undefined ? pagamento.isControlarTarifasBancariasContratado : (isControlarTarifasBancariasContratado));

                var vlTarifas = parseFloat(colocarPonto($("valorTarifas").value));
                var _tr1 = Builder.node("TR", {id: "trPgto_" + countPgto, className: celulaZebrada});
                var _td0 = new Element("TD", {align: "center"});
                var _td1 = new Element("TD", {align: "center"});
                var _td2 = Builder.node("TD", {align: "center"});
                var _td3 = Builder.node("TD", {align: "center"});
                var _td4 = Builder.node("TD", {align: "center"});
                var _td5 = Builder.node("TD", {align: "center"});
                var _td6 = Builder.node("TD", {align: "left"});
                var _td7 = Builder.node("TD", {align: "center"});
                var _td8 = Builder.node("TD", {align: "center"});
                var _td9 = Builder.node("TD", {align: "center"});
                var _td10 = Builder.node("TD", {align: "center"});
                var _trObservacao = Builder.node("tr",{
                    id:"trObs_"+countPgto,
                    className: celulaZebrada
                });
                var _tdObservacaoBranco = Builder.node("td",{
                    
                });
                var _tdObservacao = Builder.node("td",{
                    colspan:"3"
                });
                
                var _tdDividir = Builder.node("td",{
                    colspan:"6"
                });
                
                var _inputObservacao = Builder.node("input",{
                    type:"text",
                    id: "observacaoPgto_"+countPgto,
                    name: "observacaoPgto_"+countPgto,
                    className: 'fieldMin',
                    size:"40",
                    value:pagamento.observacao
                });
                
                var _botaoDividir = Builder.node('input',{
                    type:"button",
                    className:"inputBotao",
                    value:" Replicar pagamento ",
                    onClick:"dividirPagamento("+countPgto+")"
                });
                
                var _labelObservacao = Builder.node('LABEL', {
                    id: "labelObservacao_" + countPgto
                });
                Element.update(_labelObservacao, " Observação: ");
                
                
                _tdObservacao.append(_labelObservacao);
                _tdObservacao.append(_inputObservacao);
                _trObservacao.append(_tdObservacaoBranco);
                _trObservacao.append(_tdObservacao);

                if (pagamento.fechamentoAgregadoId != 0) {
                    let _tdObservacaoDespesa = Builder.node("td",{
                        colspan:"6"
                    });

                    let _labelObservacaoDespesa = Builder.node('LABEL', {
                        id: "observacao_despesa_" + countPgto//,
//                    style:"display:none"
                    });

                    _labelObservacaoDespesa.innerHTML = "Fechamento Agregado em " + pagamento.dataFechamentoAgregado + " com a despesa ";
                    
                    if ('${pode_visualizar_despesa}' === 'true') {
                        _labelObservacaoDespesa.innerHTML += '<label class="linkEditar" onClick="abrirDespesaFechamentoAgregado(' + pagamento.despesafechamentoAgregadoId + ')">' + pagamento.despesafechamentoAgregadoId + '</label>';
                    } else {
                        _labelObservacaoDespesa.innerHTML += pagamento.despesafechamentoAgregadoId;
                    }

                    _tdObservacaoDespesa.append(_labelObservacaoDespesa);
                    _trObservacao.append(_tdObservacaoDespesa);
                } else {
                    if (isRateio) {
                        _tdDividir.append(_botaoDividir);
                    }
                    _trObservacao.append(_tdDividir);
                }
                
                var imagemPlusMinus = Builder.node("img",{
                    type:"img",
                    id: "imgPluMinus_"+countPgto,
                    src: "img/plus.jpg",
                    title:"abrir as observações.",
                    className: 'imagemLink',
                    onClick:"abrirObservacao("+countPgto+")"
                });
                imagemPlusMinus.value="plus";
                
                _td0.append(imagemPlusMinus);
                
                //variaveis com as funcoes
                var callVerDocumPgto = "verDocumPgto(" + countPgto + ");";
                var callLocalizarAgente = "abrirLocalizaAgente(" + countPgto + ");";
                var callAlterarTipoPagamento = "alterarTipoPagamento(" + countPgto + ");";
                var callVerDesp = "verDesp(" + pagamento.despesa_id + ");";
                var callExcluirPagto = "excluirPagto(" + countPgto + ");";
                var callBaixar = "baixar(" + pagamento.nfiscal + ");";
                var callAlteraFavorecidoPagto = "alteraTipoFavorecido(" + countPgto + ");";
                var calcularTalaoCheque = "calcularTalaoCheque(" + countPgto + ");";
                var callAlterarAdiantamento = "alterarAdiantamento();";

                var _lab1 = Builder.node('LABEL', {id: "lab1_" + countPgto});
                Element.update(_lab1, " Favorecido: ");
                var _lab2 = Builder.node('LABEL', {id: "lab2_" + countPgto});
                Element.update(_lab2, " Conta: ");
                var _lab3 = Builder.node('LABEL', {id: "lab3_" + countPgto});
                Element.update(_lab3, " Banco: ");
                var _lab4 = Builder.node('LABEL', {id: "lab4_" + countPgto});
                Element.update(_lab4, " Ag: ");
                var _lab5 = Builder.node('LABEL', {className: 'linkEditar', onClick: callVerDesp});
                Element.update(_lab5, pagamento.despesa_id);
                var _lab6 = Builder.node('LABEL', {id: 'status_' + countPgto});
                var _lab7 = Builder.node('LABEL', {id: "lab7_" + countPgto});
                Element.update(_lab7, " Debitar: ");
                var _lab8 = Builder.node('LABEL', {id: "lab8_" + countPgto});
                Element.update(_lab8, " Ag. Pagador: ");
                var _lab9 = Builder.node('LABEL', {id: "lab9_" + countPgto});
                Element.update(_lab9, " Efetivação: ");

                if (controlarTarifasBancariasContratado) {
                    pagamento.valor = calculaTotalTarifas();//pegar valor calculado. Pois estava vindo zerado.
                }
                
                var _inp1 = Builder.node("INPUT", {type: "text", size: 9, name: "valorPgto_" + countPgto, id: "valorPgto_" + countPgto, className: 'fieldMin', value: colocarVirgula(pagamento.valor), onKeyPress: callMascaraReais});
                var _inp2 = Builder.node("INPUT", {type: "text", size: 11, name: "dataPgto_" + countPgto, id: "dataPgto_" + countPgto, onkeypress: formatarData, onblur: validarData, value: pagamento.data, className: 'fieldDateMin'}); //className:'inputReadOnly8pt' fieldDateMin
                var _inp3 = Builder.node("INPUT", {type: "text", size: 10, name: "documPgto_" + countPgto, id: "documPgto_" + countPgto, value: pagamento.doc, className: 'fieldMin'});
                var _inp4 = Builder.node("INPUT", {type: "text", size: 20, name: "favorecidoAd_" + countPgto, id: "favorecidoAd_" + countPgto, className: 'fieldMin', value: pagamento.favorecidoAd});
                var _inp5 = Builder.node("INPUT", {type: "text", size: 10, name: "contaAd_" + countPgto, id: "contaAd_" + countPgto, className: 'fieldMin', value: pagamento.contaAd});
                var _inp6 = Builder.node("INPUT", {type: "text", size: 5, name: "agenciaAd_" + countPgto, id: "agenciaAd_" + countPgto, className: 'fieldMin', value: pagamento.agenciaAd});
                var _inp7 = Builder.node("INPUT", {type: "hidden", name: "idPgto_" + countPgto, id: "idPgto_" + countPgto, value: pagamento.id});
                var _inp8 = Builder.node("INPUT", {type: "text", size: 30, name: "agentePgto_" + countPgto, id: "agentePgto_" + countPgto, className: 'inputReadOnly8pt', value: pagamento.agente});
                var _inp9 = Builder.node("INPUT", {type: "hidden", name: "idAgentePgto_" + countPgto, id: "idAgentePgto_" + countPgto, value: pagamento.agente_id});
                var _inp10 = Builder.node("INPUT", {type: "hidden", name: "percAbast_" + countPgto, id: "percAbast_" + countPgto, value: pagamento.percAbastec});
                var _inp11 = Builder.node("INPUT", {type: "hidden", name: "despesaPagId_" + countPgto, id: "despesaPagId_" + countPgto, value: pagamento.despesa_id});
                
                var _inp11_idFilial = Builder.node("INPUT", {type: "hidden", name: "idFilialPagamento_" + countPgto, id: "idFilialPagamento_" + countPgto, value: pagamento.idfilial});

                var _inp11_filial = Builder.node("LABEL", {name: "filialDespesa_" + countPgto, id: "filialDespesa_" + countPgto});
                _inp11_filial.innerHTML = "<br>" + (pagamento.filial ? pagamento.filial : (pagamento.filialDestino ? pagamento.filialDestino : ""));
                
                var _inp12 = Builder.node("INPUT", {type: "hidden", name: "baixado_" + countPgto, id: "baixado_" + countPgto, value: pagamento.baixado});
                var _inp13 = Builder.node("INPUT", {type: "hidden", name: "saldoAltorizacao_" + countPgto, id: "saldoAltorizacao_" + countPgto, value: pagamento.saldoAutorizado});
                var _inp14 = Builder.node("INPUT", {type: "hidden", name: "planoAgente_" + countPgto, id: "planoAgente_" + countPgto, value: pagamento.planoAgente});
                var _inp15 = Builder.node("INPUT", {type: "hidden", name: "undAgente_" + countPgto, id: "undAgente_" + countPgto, value: pagamento.undAgente});
                var _inp16 = Builder.node("INPUT", {type: "hidden", name: "isPamcard_" + countPgto, id: "isPamcard_" + countPgto});
                var _inp17 = Builder.node("INPUT", {type: "hidden", name: "isRepom_" + countPgto, id: "isRepom_" + countPgto});
                var _inp18 = Builder.node("INPUT", {type: "hidden", name: "isNdd_" + countPgto, id: "isNdd_" + countPgto});
                var _inp19 = Builder.node("INPUT", {type: "hidden", name: "isTicket_" + countPgto, id: "isTicket_" + countPgto});
                var _inp20 = Builder.node("INPUT", {type: "hidden", name: "isControlarTarifasBancariasContratado_" + countPgto, id: "isControlarTarifasBancariasContratado_" + countPgto, value: (controlarTarifasBancariasContratado)});
                var _inp21 = Builder.node("INPUT", {type: "hidden", name: "isSalvar" + countPgto, id: "isSalvar" + countPgto, value: "true"});
                var _inp22 = Builder.node("INPUT", {type: "text", size: 9, name: "valorDesconto_" + countPgto, id: "valorDesconto_" + countPgto, className: 'fieldMin', value: pagamento.valorDesconto, onKeyPress: callMascaraReais});
                var _inp23 = Builder.node("INPUT", {type: "hidden", name: "percPgto_" + countPgto, id: "percPgto_" + countPgto, value: pagamento.percPgto});
                var _inp24 = Builder.node("INPUT", {type: "hidden", name: "isValorEditavel_" + countPgto, id: "isValorEditavel_" + countPgto, value: pagamento.isValorEditavel});
                var _inp25 = Builder.node("INPUT", {type: "hidden", name: "tipoCalculoAd_" + countPgto, id: "tipoCalculoAd_" + countPgto, value: pagamento.tipoCalculo});
                var _inp25_1 = Builder.node("INPUT", {type: "hidden", name: "valoTotalFilial_" + countPgto, id: "valoTotalFilial_" + countPgto, value: pagamento.totalFilialPagamento});
                var _inp26 = Builder.node("INPUT", {type: "hidden", name: "isTarget_" + countPgto, id: "isTarget_" + countPgto});

                var _but1 = Builder.node('INPUT', {type: 'button', name: 'localizaAgente_' + countPgto, id: 'localizaAgente_' + countPgto, value: '...', className: 'inputBotaoMin', onClick: callLocalizarAgente});

                var _img1 = Builder.node('IMG', {src: 'img/lixo.png', title: 'Excluir Pagamento', className: 'imagemLink', onClick: callExcluirPagto});
                var _img2 = Builder.node('IMG', {src: 'img/baixar.gif', title: 'Baixar este ' + (pagamento.tipo == "a" ? "Adiantamento" : "Saldo"), className: 'imagemLink', onClick: callBaixar});

                var _slc1 = Builder.node('SELECT', {name: 'tipoPagto_' + countPgto, id: 'tipoPagto_' + countPgto, className: 'fieldMin', onChange: callAlterarTipoPagamento});
                var _optA = Builder.node('OPTION', {value: "a"});
                var _optS = Builder.node('OPTION', {value: "s"});

                _slc1.appendChild(Element.update(_optA, "Adiantamento"));
                _slc1.appendChild(Element.update(_optS, "Saldo"));

                var _slc2 = Builder.node('SELECT', {name: 'formaPagto_' + countPgto, id: 'formaPagto_' + countPgto, className: 'fieldMin', onChange: callVerDocumPgto});
                var _slc3 = Builder.node('SELECT', {name: 'contaPgto_' + countPgto, id: 'contaPgto_' + countPgto, className: 'fieldMin', onChange: callVerDocumPgto});
                var _slc4 = Builder.node('SELECT', {name: 'banco_' + countPgto, id: 'banco_' + countPgto, className: 'fieldMin'});

                var _slc5 = Builder.node('SELECT', {name: 'tipoFavorecido_' + countPgto, id: 'tipoFavorecido_' + countPgto, className: 'fieldMin', onChange: callAlteraFavorecidoPagto});
                var _optT = Builder.node('OPTION', {value: "t"});
                var _optM = Builder.node('OPTION', {value: "m"});
                var _optP = Builder.node('OPTION', {value: "p"});
                if (!pagamento.isPamcard && !pagamento.isNdd && !pagamento.isEFrete && !pagamento.isExpers && !pagamento.isPagBem) {
                    _slc5.appendChild(Element.update(_optT, "Terceiro"));
                }
                _slc5.appendChild(Element.update(_optM, "Motorista"));
                _slc5.appendChild(Element.update(_optP, "Proprietário"));

                var _slc6 = Builder.node('SELECT', {name: 'documPgto2_' + countPgto, id: 'documPgto2_' + countPgto, className: 'fieldMin', onchange: calcularTalaoCheque});

                var _slc7 = Builder.node('SELECT', {name: 'tipoContaPgto_' + countPgto, id: 'tipoContaPgto_' + countPgto, className: 'fieldMin'});
                var _optCorrente = Builder.node('OPTION', {value: "c"});
                var _optPoupanca = Builder.node('OPTION', {value: "p"});
                _slc7.appendChild(Element.update(_optCorrente, "C. Corrente:"));
                _slc7.appendChild(Element.update(_optPoupanca, "C. Poupança:"));

                if (manualAutomaticoCiotNivel == 4) {
                    var _slc8 = Builder.node('SELECT', {name: 'tipoPagamentoCfe_' + countPgto, id: 'tipoPagamentoCfe_' + countPgto, className: 'fieldMin'});
                    var _opt5M = Builder.node('OPTION', {value: "M"});
                    var _opt5A = Builder.node('OPTION', {value: "A"});

                    _slc8.appendChild(Element.update(_opt5M, "Manual"));//Manual
                    _slc8.appendChild(Element.update(_opt5A, "Automática"));//Automática
                } else {
                    var _slc8 = Builder.node('SELECT', {name: 'tipoPagamentoCfe_' + countPgto, id: 'tipoPagamentoCfe_' + countPgto, className: 'fieldMin', disabled: ""});
                    var _opt5M = Builder.node('OPTION', {value: "M"});
                    var _opt5A = Builder.node('OPTION', {value: "A"});

                    _slc8.appendChild(Element.update(_opt5M, "Manual"));//Manual
                    _slc8.appendChild(Element.update(_opt5A, "Automática"));//Automática
                }
                

                if (controlarTarifasBancariasContratado) {
                    
                    readOnly(_inp1, "inputReadOnly8pt");
                    readOnly(_inp2, "inputReadOnly8pt");
                    readOnly(_inp3, "inputReadOnly8pt");
                    readOnly(_inp4, "inputReadOnly8pt");
                    readOnly(_inp5, "inputReadOnly8pt");
                    readOnly(_inp6, "inputReadOnly8pt");
                    readOnly(_inp22, "inputReadOnly8pt");

                    //_slc2.disabled = "true";
                    _slc3.disabled = "true";
                    _slc4.disabled = "true";
                    _slc5.disabled = "true";
                    _slc7.disabled = "true";
                    _slc8.disabled = "true";

                }

                if (pagamento.utilizaNegociacao) {
                    readOnly(_inp1, "inputReadOnly8pt");
                }
                //Deivid pediu pra tirar por conta da Efficax
//                if (pagamento.utilizaNegociacao) {
//                    desabilitar(_slc5);
//                }

               var opt = new Element("option", {
                    value: "0"
                });

                Element.update(opt, " Selecione ");
                _slc2.appendChild(opt);
                
                var optPgto = null;
                for (var i = 0; i < listaFormaPagamento.length; i++) {
                    
                    if (_slc2.value == "") {
                        _slc2.selectedIndex = 0;
                    }
                    optPgto = Builder.node("option", {value: listaFormaPagamento[i].valor});
                    Element.update(optPgto, listaFormaPagamento[i].descricao);
                    var isMostra = false;
  
                    if (pagamento.isPamcard) {
                        if (listaFormaPagamento[i].valor == 4 || listaFormaPagamento[i].valor == 11 || listaFormaPagamento[i].valor == pagamento.fpag) {
                            isMostra = true;
                        }
                    } else if (pagamento.isNdd) {
                        if (listaFormaPagamento[i].valor == 4 || listaFormaPagamento[i].valor == 14 || listaFormaPagamento[i].valor == pagamento.fpag) {
                            isMostra = true;
                        }
                    } else if (pagamento.isTicket) {
                        if (listaFormaPagamento[i].valor == 4 || listaFormaPagamento[i].valor == 13 || listaFormaPagamento[i].valor == pagamento.fpag) {
                            isMostra = true;
                        }
                    } else if (pagamento.isRepom) {
                        if (listaFormaPagamento[i].valor == 12 || listaFormaPagamento[i].valor == pagamento.fpag || listaFormaPagamento[i].valor == 4 ) {
                            isMostra = true;
                        }
                    } else if (pagamento.isEFrete) {
                        if (listaFormaPagamento[i].valor == 4 || listaFormaPagamento[i].valor == 16 || listaFormaPagamento[i].valor == pagamento.fpag) {
                            isMostra = true;
                        }
                    } else if (pagamento.isExpers) {
                        if (listaFormaPagamento[i].valor == 4 || listaFormaPagamento[i].valor == 17 || listaFormaPagamento[i].valor == pagamento.fpag) {
                            isMostra = true;
                        }
                    } else if (pagamento.isPagBem) {
                        if (listaFormaPagamento[i].valor == 4 || listaFormaPagamento[i].valor == 18 || listaFormaPagamento[i].valor == pagamento.fpag) {
                            isMostra = true;
                        }
                    } else if (pagamento.isTarget) {
                        if (listaFormaPagamento[i].valor == 4 || listaFormaPagamento[i].valor == 20 || listaFormaPagamento[i].valor == pagamento.fpag) {
                            isMostra = true;
                        }
                    } else {
                        
                        isMostra = true;
                    }
                    //Sempre irá aparecer essa opção 
                    if (listaFormaPagamento[i].valor == 19) {
                        isMostra = true;
                    }else if(listaFormaPagamento[i].valor == 1){
                        isMostra = true;
                    }
                    
                    if (isMostra) {
                        _slc2.appendChild(optPgto);
                    }
                }

                var optBanco = null;
                //Primeira opção do select
                var opt = new Element("option", {
                    value: ""
                });

                Element.update(opt, " Selecione ");
                _slc4.appendChild(opt);

                for (var i = 0; i < listaBanco.length; i++) {
                    if (_slc4.value == "") {
                        _slc4.selectedIndex = 0;
                    }
                    optBanco = Builder.node("option", {
                        value: listaBanco[i].valor
                    });

                    Element.update(optBanco, listaBanco[i].descricao);
                    _slc4.appendChild(optBanco);
                }

                _slc4.value = pagamento.bancoAd;

                var optConta = null;
                
                optConta = Builder.node("option", {value: 0});
                Element.update(optConta, "Selecione");
                _slc3.appendChild(optConta);
                        
                optConta = Builder.node("option", {value: 0});
                Element.update(optConta, "Selecione");
                _slc3.appendChild(optConta);
                        
                for (var i = 0; i < listaConta.length; i++) {
                    if (listaConta[i].valor == $("contaCC").value) {
                        listaConta.splice(i, 1);
                    } else {
                        optConta = Builder.node("option", {
                            value: listaConta[i].valor
                        });
                        Element.update(optConta, listaConta[i].descricao);
                        _slc3.appendChild(optConta);
                    }
                }

                // INSERINDO VALORES DOS SELECT'S
                _slc1.value = pagamento.tipo;
                _slc5.value = (pagamento.tipoFavorecido == undefined || pagamento.tipoFavorecido =="" ? "p" : pagamento.tipoFavorecido);
                if (pagamento.contaId == '0') {
                    if (pagamento.isContaCorrente) {
                        _slc3.value = $('contaCC').value;
                    } else {
                        //fazer aqui

                        if (_slc1.value == "a") {
                            _slc3.value = ($("contaID").value == "" ? 0: $("contaID").value);
                        } else {
                            _slc3.selectedIndex = 0;
                        }

                    }
                } else {
                    _slc3.value = pagamento.contaId;
                }
                    
                var optDocum = null;
                for (var i = 0; i < listaDocum.length; i++) {
                    optDocum = Builder.node("option", {
                        value: listaDocum[i].valor
                    });
                    Element.update(optDocum, listaDocum[i].descricao);
                    _slc6.appendChild(optDocum);
                }

                _td1.appendChild(_inp7);
                _td1.appendChild(_slc1);
                _td2.appendChild(_inp1);
                _td10.appendChild(_inp22);
                _td3.appendChild(_inp2);
                _td4.appendChild(_slc2);
                _td4.appendChild(_slc8);
                _td5.appendChild(_inp3);
                _td5.appendChild(_slc6);

                var _br1 = Builder.node("br", {id: "br1_" + countPgto});
                var _br2 = Builder.node("br", {id: "br2_" + countPgto});
                var _br3 = Builder.node("br", {id: "br3_" + countPgto});

                _td6.appendChild(_lab7);
                _td6.appendChild(_slc3);
                _td6.appendChild(_br1);
                _td6.appendChild(_lab1);
                _td6.appendChild(_slc5);
                _td6.appendChild(_inp4);
                _td6.appendChild(_br2);
                _td6.appendChild(_slc7);
                //_td6.appendChild(_lab2);
                _td6.appendChild(_inp5);
                _td6.appendChild(_lab4);
                _td6.appendChild(_inp6);
                _td6.appendChild(_br3);
                _td6.appendChild(_lab3);
                _td6.appendChild(_slc4);
                _td6.appendChild(_lab8);
                _td6.appendChild(_inp8);
                _td6.appendChild(_inp9);
                _td6.appendChild(_inp10);
                _td6.appendChild(_inp12);
                _td6.appendChild(_inp13);
                _td6.appendChild(_inp14);
                _td6.appendChild(_inp15);
                _td6.appendChild(_inp16);
                _td6.appendChild(_inp17);
                _td6.appendChild(_inp18);
                _td6.appendChild(_inp19);
                _td6.appendChild(_inp20);
                _td6.appendChild(_inp21);
                _td6.appendChild(_inp23);
                _td6.appendChild(_inp24);
                _td6.appendChild(_inp25);
                _td6.appendChild(_inp25_1);
                _td6.appendChild(_inp26);
                _td6.appendChild(_but1);
                
                //_td6.appendChild(_lab9);
                //_td6.appendChild(_slc8);

                if (pagamento.despesa_id != 0 && pagamento.despesa_id != "0") {
                    _td7.appendChild(_lab5);
                }
                _td7.appendChild(_inp11);
                _td7.appendChild(_inp11_idFilial);
                _td7.appendChild(_inp11_filial);
                
                _td8.appendChild(_lab6);

                if (!pagamento.fixo) {
                    _td9.appendChild(_img1);
                } else if (!pagamento.baixado && pagamento.fpag != 8 && pagamento.despesa_id != 0 && true) {
                    _td9.appendChild(_img2);
                }
                
                _tr1.appendChild(_td0);
                _tr1.appendChild(_td1);
                _tr1.appendChild(_td2);
                if (${param.utilizacaoCfe == 'X'}) {
                    _tr1.appendChild(_td10);
                }
                _tr1.appendChild(_td3);
                _tr1.appendChild(_td4);
                _tr1.appendChild(_td5);
                _tr1.appendChild(_td6);
                _tr1.appendChild(_td7);
                _tr1.appendChild(_td8);
                _tr1.appendChild(_td9);

                if (pagamento.fixo) {
                    desabilitar(_slc1);
                }
                
                //Mudando de default 2-(Dinheiro) e passando a ser o primeiro item da lista quando não tiver valores para colocar na forma de pagamento.
                _slc2.value = "0";
                //Coloca como default o que está em configuração marcado na aba contrato de frete.
                //Após essa regra o que vinher abaixo é prioridade
                if (pagamento.fpag == undefined) {
                    _slc2.value = '${configuracao.fpag.idFPag}';
                }
                
                if (pagamento.tipo == "a") {
                    var nivelPgCfe = parseFloat('${param.nivelTipoPagamentoCfe}');
                    if (nivelPgCfe != 4) {
                        desabilitar(_slc8);
                    }

                    _inp1.onblur = new Function(callAlterarAdiantamento);
                    visivel(_slc3);
                    visivel(_lab9);
                    visivel(_slc8);

                    invisivel(_br1);
                    invisivel(_br2);
                    invisivel(_br3);
                    invisivel(_lab1);
                    invisivel(_slc5);
                    invisivel(_slc4);
                    invisivel(_inp4);
                    invisivel(_lab2);
                    invisivel(_lab3);
                    invisivel(_lab4);
                    invisivel(_inp5);
                    invisivel(_inp6);

                } else {
                    invisivel(_lab9);
                    invisivel(_slc8);
                    invisivel(_slc3);
                }
                //invisivel(_inp8);
                //invisivel(_inp9);
                //invisivel(_but1);
                if (pagamento.fpag != "3" || pagamento.tipo != "a" || ${configuracao.controlarTalonario}) {
                    invisivel(_slc6);
                }
                //Validar antes do baixado
                if(pagamento.isValorEditavel == "true"||pagamento.isValorEditavel == true){ 
                    _inp1.disabled = false;
                    _inp1.className="fieldMin";
                    _inp1.readOnly = false;
                }else{ 
                    //quando não tiver Negociação do Adiantamento de Frete o campo fica habilitado - historia 3225
                    if ($("negociacaoAdiantamento").value != "0"){
                        desabilitar(_inp1);
                    }
                }
                
                if (pagamento.baixado || pagamento.saldoAutorizado) {
                    desabilitar(_slc1);
                    desabilitar(_slc3);
                    desabilitar(_slc4);
                    //desabilitar(_slc5);
                    desabilitar(_slc6);
                    desabilitar(_slc7);
                    readOnly(_inp1, "inputReadOnly8pt");
                    readOnly(_inp2, "inputReadOnly8pt");
                    readOnly(_inp3, "inputReadOnly8pt");
                    readOnly(_inp4, "inputReadOnly8pt");
                    readOnly(_inp5, "inputReadOnly8pt");
                    readOnly(_inp6, "inputReadOnly8pt");
                    desabilitar(_slc2);
                    desabilitar(_slc5);

                    if (pagamento.baixado) {
                        Element.update(_lab6, "Baixado");
                    } else {
                        Element.update(_lab6, "Autorizado");
                    }
                } else {
                    if (pagamento.despesa_id != 0) {
                        Element.update(_lab6, "Em aberto");
                    }
                }

                //Criando todos os elementos
                $("bodyPagamento").appendChild(_tr1);
                $("bodyPagamento").appendChild(_trObservacao);
                $("trObs_"+countPgto).style.display = "none";

                if (pagamento.id != 0) {//Se estiver editando
                    invisivel($('documPgto2_' + countPgto));
                    //$('contaPgto_'+countPgto).value = pagamento.contaId;  Comentei essa linha porque já estava sendo setado lá em cima no objeto _slc3
                    $('formaPagto_' + countPgto).value = pagamento.fpag;
                    $("tipoFavorecido_" + countPgto).value = pagamento.tipoFavorecido;
                }

                $("tipoPagamentoCfe_" + countPgto).value = pagamento.tipoPagamentoCfe;
                $('tipoContaPgto_' + countPgto).value = pagamento.tipoConta;
                $('isPamcard_' + countPgto).value = pagamento.isPamcard;
                $('isRepom_' + countPgto).value = pagamento.isRepom;
                $('isNdd_' + countPgto).value = pagamento.isNdd;
                $('isTicket_' + countPgto).value = pagamento.isTicket;
                $('isTarget_' + countPgto).value = pagamento.isTarget;

                var deixarEmBranco = false;

                if (pagamento.id == 0) {
                    if (pagamento.isPamcard) {
                        jQuery("#formaPagto_" + countPgto).val('11');
                        deixarEmBranco = (pagamento.fpag == null ? false : !(pagamento.fpag == "11"));
                    } else if (pagamento.isRepom) {
                        jQuery("#formaPagto_" + countPgto).val('12');
                        deixarEmBranco = (pagamento.fpag == null ? false : !(pagamento.fpag == "12"));
                    } else if (pagamento.isNdd) {
                        jQuery("#formaPagto_" + countPgto).val('14');
                        deixarEmBranco = (pagamento.fpag == null ? false : !(pagamento.fpag == "14"));
                    } else if (pagamento.isEFrete && (!pagamento.emissaoGratuita)) {
                        jQuery("#formaPagto_" + countPgto).val('16');
                        deixarEmBranco = (pagamento.fpag == null ? false : !(pagamento.fpag == "16"));
                    } else if (pagamento.isEFrete && (pagamento.emissaoGratuita)) {
                        jQuery("#formaPagto_" + countPgto).val('4');
                        deixarEmBranco = (pagamento.fpag == null ? false : !(pagamento.fpag == "4"));
                    } else if (pagamento.isExpers) {
                        jQuery("#formaPagto_" + countPgto).val('17');
                        deixarEmBranco = (pagamento.fpag == null ? false : !(pagamento.fpag == "17"));
                    } else if (pagamento.isPagBem) {
                        jQuery("#formaPagto_" + countPgto).val('18');
                        deixarEmBranco = (pagamento.fpag == null ? false : !(pagamento.fpag == "18"));
                    } else if (pagamento.isTarget) {
                        jQuery("#formaPagto_" + countPgto).val('20');
                        deixarEmBranco = (pagamento.fpag == null ? false : !(pagamento.fpag == "20"));
                    }
                }
                
                $("tipoPagto_" + countPgto).style.width = '50px';
                $("formaPagto_" + countPgto).style.width = '85px';
                $("contaPgto_" + countPgto).style.width = '140px';
                //$("tipoFavorecido_"+countPgto).style.width = '60px';
                $("banco_" + countPgto).style.width = '140px';

                $("maxPagamento").value = countPgto;
                if (!pagamento.isCarregando){
                    calculaSaldo(countPgto);
                }
                
                if (isClone) {
                    deixarEmBranco = false;
                }
                
                if (pagamento.fpag != undefined && pagamento.fpag != "" && pagamento.fpag != $("formaPagto_" + countPgto).value) {
                    //Se na negociação tiver marcado uma forma de pagamento diferente da filial, vai assumir a forma de pagamento descrita no arquivo funcoesTelaContratoFrete.js
                    if (!deixarEmBranco) {
                        jQuery("#formaPagto_" + countPgto).val(pagamento.fpag);
                    }else{
                        jQuery('#formaPagto_' + countPgto).find('option').each(function(a,b){
                            if (b.value == pagamento.fpag) {
                                b.style.display = "none";
                                b.disabled = true;
                            }
                        });
                        jQuery("#formaPagto_" + countPgto).val("0");
                    }
                }
                if(pagamento.fpag != undefined && pagamento.fpag != "" && pagamento.fpag == 0){
                    jQuery.map(jQuery('select[id="formaPagto_'+countPgto+'"] option') ,function(option) {
                         if(option.value == optPagConfig){
                             option.selected = true;
                         };
                    });
                }
                verDocumPgto(countPgto, pagamento.doc);
            }

            function dividirPagamento(index){
                var pagCopia = new ContratoFretePagamento();
                pagCopia.tipo = $("tipoPagto_"+index).value;
                pagCopia.valor = 0;
                pagCopia.data = $("dataPgto_"+index).value;
                pagCopia.fpag = $("formaPagto_"+index).value;
                pagCopia.tipoPagamentoCfe = $("tipoPagamentoCfe_"+index).value;
                pagCopia.doc = $("documPgto_"+index).value;
                pagCopia.contaId = $("contaPgto_"+index).value;
                pagCopia.tipoFavorecido = $("tipoFavorecido_"+index).value;
                pagCopia.favorecidoAd = $("favorecidoAd_"+index).value;
                pagCopia.tipoConta = $("tipoContaPgto_"+index).value;
                pagCopia.contaAd = $("contaAd_"+index).value;
                pagCopia.agenciaAd = $("agenciaAd_"+index).value;
                pagCopia.bancoAd = $("banco_"+index).value;
                pagCopia.agente = $("agentePgto_"+index).value;
                pagCopia.agente_id = $("idAgentePgto_"+index).value;
                pagCopia.idfilial = $("idFilialPagamento_"+index).value;
                pagCopia.filial = jQuery("#filialDespesa_"+index).text();
                pagCopia.isValorEditavel = true;
                
                addPagto(pagCopia, undefined, true, true);
            }

            function alterarTipoPagamento(index) {
                var formaPag = $('formaPagto_' + index).value;
                var idxSaldo = getPrimeiroSaldo();
                if (isRetencaoImpostoOperadoraCFe()) {
                    if ($("tipoPagto_" + index).value === "s" && getPrimeiroSaldo() !== -1 && idxSaldo !== index) {
                        $("tipoPagto_" + index).value = "a";
                        alert("ATENÇÂO: Só é possivel adicionar um saldo, pois a opção 'A retenção de impostos será realizada pela REPOM' esta ativa!");
                    }
                }

                if ($("tipoPagto_" + index).value == "a") {
                    visivel($("contaPgto_" + index));
                    visivel($("_lab9_" + index));
                    visivel($("tipoPagamentoCfe_" + index));
                    if (${configuracao.gerar_despesa_cartafrete}) {
                        invisivel($("br1_" + index));
                        invisivel($("br2_" + index));
                        invisivel($("br3_" + index));
                        invisivel($("lab1_" + index));
                        invisivel($("tipoContaPgto_" + index));
                        invisivel($("lab3_" + index));
                        invisivel($("lab4_" + index));
                        invisivel($("banco_" + index));
                        if (formaPag == '3' || formaPag == '8' || formaPag == '11' || formaPag == '13' || formaPag == '14' || formaPag == '17' || formaPag == '18' || formaPag == '20') {
                            visivel($("tipoFavorecido_" + index));
                            visivel($("favorecidoAd_" + index));
                        } else {
                            invisivel($("tipoFavorecido_" + index));
                            invisivel($("favorecidoAd_" + index));
                        }
                        invisivel($("contaAd_" + index));
                        invisivel($("agenciaAd_" + index));
                        if (formaPag == '8') {
                            invisivel($("lab7_" + index));
                            invisivel($("contaPgto_" + index));
                            visivel($("lab8_" + index));
                            visivel($("agentePgto_" + index));
                            visivel($("localizaAgente_" + index));

                        }
                        else if (formaPag == '12') {
                            invisivel($("br2_" + index));
                            invisivel($("br3_" + index));
                            visivel($("lab1_" + index));
                            visivel($("tipoContaPgto_" + index));
                            visivel($("lab3_" + index));
                            visivel($("lab4_" + index));
                            visivel($("tipoFavorecido_" + index));
                            visivel($("banco_" + index));
                            visivel($("favorecidoAd_" + index));
                            visivel($("contaAd_" + index));
                            visivel($("agenciaAd_" + index));
                            visivel($("lab8_" + index));
                            visivel($("agentePgto_" + index));
                            visivel($("localizaAgente_" + index));


                        } else if (formaPag == '3') {
                            visivel($("tipoFavorecido_" + index));
                            visivel($("favorecidoAd_" + index));
                            if (${configuracao.controlarTalonario}) {
                                invisivel($("documPgto_" + index));
                                visivel($("documPgto2_" + index));
                            } else {
                                visivel($("documPgto_" + index));
                                invisivel($("documPgto2_" + index));
                            }
                            visivel($("contaAd_" + index));
                            visivel($("agenciaAd_" + index));
                            visivel($("tipoContaPgto_" + index));
                        } else if (formaPag == '9' || formaPag == '4') {

                            visivel($("tipoFavorecido_" + index));
                            visivel($("favorecidoAd_" + index));
                            visivel($("contaAd_" + index));
                            visivel($("agenciaAd_" + index));
                            visivel($("tipoContaPgto_" + index));
                            invisivel($("agentePgto_" + index));
                            invisivel($("lab8_" + index));
                            invisivel($("localizaAgente_" + index));
                        } else if (formaPag == '16') {
                            visivel($("tipoFavorecido_" + index));
                            visivel($("favorecidoAd_" + index));
                            invisivel($("documPgto_" + index));
                            invisivel($("documPgto2_" + index));
                            visivel($("contaAd_" + index));
                            visivel($("agenciaAd_" + index));
                            visivel($("tipoContaPgto_" + index));
                        } else if (formaPag == '17' || formaPag == '18') {
                            visivel($("tipoFavorecido_" + index));
                            visivel($("favorecidoAd_" + index));
                            invisivel($("documPgto_" + index));
                            invisivel($("documPgto2_" + index));
                            visivel($("contaAd_" + index));
                            visivel($("agenciaAd_" + index));
                            visivel($("tipoContaPgto_" + index));
                        } else if (formaPag == '10' || formaPag == '15') {
                            invisivel($("lab8_" + index));
                            invisivel($("agentePgto_" + index));
                            invisivel($("localizaAgente_" + index));
                            visivel($("tipoFavorecido_" + index));
                            visivel($("favorecidoAd_" + index));
                            visivel($("lab7_" + index));
                            visivel($("contaPgto_" + index));
                        } else {
                            invisivel($("lab8_" + index));
                            invisivel($("agentePgto_" + index));
                            invisivel($("localizaAgente_" + index));
                            visivel($("lab7_" + index));
                            visivel($("contaPgto_" + index));
                        }
                    } else {
                        invisivel($("br1_" + index));
                        invisivel($("lab7_" + index));
                        invisivel($("contaPgto_" + index));
                        invisivel($("_lab9_" + index));
                        invisivel($("tipoPagamentoCfe_" + index));
                        if (formaPag == '8') {
                            invisivel($("br2_" + index));
                            invisivel($("br3_" + index));
                            invisivel($("lab1_" + index));
                            invisivel($("tipoContaPgto_" + index));
                            invisivel($("lab3_" + index));
                            invisivel($("lab4_" + index));
                            invisivel($("banco_" + index));
                            invisivel($("tipoFavorecido_" + index));
                            invisivel($("favorecidoAd_" + index));
                            invisivel($("contaAd_" + index));
                            invisivel($("agenciaAd_" + index));
                            visivel($("lab8_" + index));
                            visivel($("agentePgto_" + index));
                            visivel($("localizaAgente_" + index));

                        }
                        else if (formaPag == '12') {
                            invisivel($("br2_" + index));
                            invisivel($("br3_" + index));
                            visivel($("lab1_" + index));
                            visivel($("tipoContaPgto_" + index));
                            visivel($("lab3_" + index));
                            visivel($("lab4_" + index));
                            visivel($("tipoFavorecido_" + index));
                            visivel($("banco_" + index));
                            visivel($("favorecidoAd_" + index));
                            visivel($("contaAd_" + index));
                            visivel($("agenciaAd_" + index));
                            visivel($("lab8_" + index));
                            visivel($("agentePgto_" + index));
                            visivel($("localizaAgente_" + index));

                        } else if (formaPag == '3') {
                            visivel($("tipoFavorecido_" + index));
                            visivel($("favorecidoAd_" + index));
                            visivel($("contaAd_" + index));
                            visivel($("agenciaAd_" + index));
                            visivel($("tipoContaPgto_" + index));
                        } else {

                            visivel($("br2_" + index));
                            visivel($("br3_" + index));
                            visivel($("lab1_" + index));
                            visivel($("tipoContaPgto_" + index));
                            visivel($("lab3_" + index));
                            visivel($("lab4_" + index));
                            visivel($("banco_" + index));
                            visivel($("tipoFavorecido_" + index));
                            visivel($("favorecidoAd_" + index));
                            visivel($("contaAd_" + index));
                            visivel($("agenciaAd_" + index));
                            invisivel($("lab8_" + index));
                            invisivel($("agentePgto_" + index));
                            invisivel($("localizaAgente_" + index));
                        }
                    }
                } else {
                    invisivel($("br1_" + index));
                    invisivel($("lab7_" + index));
                    invisivel($("contaPgto_" + index));
                    if (formaPag == '8') {
                        invisivel($("br2_" + index));
                        invisivel($("br3_" + index));
                        invisivel($("lab1_" + index));
                        invisivel($("tipoContaPgto_" + index));
                        invisivel($("lab3_" + index));
                        invisivel($("lab4_" + index));
                        invisivel($("tipoFavorecido_" + index));
                        invisivel($("banco_" + index));
                        invisivel($("favorecidoAd_" + index));
                        invisivel($("contaAd_" + index));
                        invisivel($("agenciaAd_" + index));
                        visivel($("lab8_" + index));
                        visivel($("agentePgto_" + index));
                        visivel($("localizaAgente_" + index));
                    }
                    else if (formaPag == '12') {
                        invisivel($("br2_" + index));
                        invisivel($("br3_" + index));
                        visivel($("lab1_" + index));
                        visivel($("tipoContaPgto_" + index));
                        visivel($("lab3_" + index));
                        visivel($("lab4_" + index));
                        visivel($("tipoFavorecido_" + index));
                        visivel($("banco_" + index));
                        visivel($("favorecidoAd_" + index));
                        visivel($("contaAd_" + index));
                        visivel($("agenciaAd_" + index));
                        visivel($("lab8_" + index));
                        visivel($("agentePgto_" + index));
                        visivel($("localizaAgente_" + index));

                    } else if (formaPag == '16') {
                        visivel($("tipoFavorecido_" + index));
                        visivel($("favorecidoAd_" + index));
                        invisivel($("documPgto_" + index));
                        invisivel($("documPgto2_" + index));
                        visivel($("contaAd_" + index));
                        visivel($("agenciaAd_" + index));
                        visivel($("tipoContaPgto_" + index));
                    } else if (formaPag == '17' || formaPag == '18') {
                        visivel($("tipoFavorecido_" + index));
                        visivel($("favorecidoAd_" + index));
                        invisivel($("documPgto_" + index));
                        invisivel($("documPgto2_" + index));
                        visivel($("contaAd_" + index));
                        visivel($("agenciaAd_" + index));
                        visivel($("tipoContaPgto_" + index));
                    } else {
                        if ($("tipoPagto_" + index).value == "s") {
                            visivel($("documPgto_" + index));
                            invisivel($("documPgto2_" + index));
                        } else {
                            invisivel($("documPgto_" + index));
                            visivel($("documPgto2_" + index));
                        }
                        visivel($("br3_" + index));
                        visivel($("lab1_" + index));
                        visivel($("tipoContaPgto_" + index));
                        visivel($("lab3_" + index));
                        visivel($("lab4_" + index));
                        visivel($("tipoFavorecido_" + index));
                        visivel($("banco_" + index));
                        visivel($("favorecidoAd_" + index));
                        visivel($("contaAd_" + index));
                        visivel($("agenciaAd_" + index));
                        invisivel($("lab7_" + index));
                        invisivel($("lab8_" + index));
                        invisivel($("agentePgto_" + index));
                        invisivel($("localizaAgente_" + index));
                    }
                }
                //Se for Pamcard
                if ($('isPamcard_' + index).value == true || $('isPamcard_' + index).value == 't' || $('isPamcard_' + index).value == 'true') {
                    visivel($("tipoFavorecido_" + index));
                    if ($("formaPagto_" + index).value == "11") {
                        if ($("tipoPagto_" + index).value == "a") {
                            visivel($("br1_" + index));
                        }
                        invisivel($("br2_" + index));
                        invisivel($("br3_" + index));
                        visivel($("lab1_" + index));
                        invisivel($("tipoContaPgto_" + index));
                        invisivel($("lab3_" + index));
                        invisivel($("lab4_" + index));
                        invisivel($("banco_" + index));
                        invisivel($("favorecidoAd_" + index));
                        invisivel($("contaAd_" + index));
                        invisivel($("agenciaAd_" + index));
                    } else if ($("formaPagto_" + index).value == "4") {
                        if ($("tipoPagto_" + index).value == "a") {
                            visivel($("br1_" + index));
                        }
                        visivel($("br2_" + index));
                        visivel($("br3_" + index));
                        visivel($("lab1_" + index));
                        visivel($("tipoContaPgto_" + index));
                        visivel($("lab3_" + index));
                        visivel($("lab4_" + index));
                        visivel($("banco_" + index));
                        invisivel($("favorecidoAd_" + index));
                        visivel($("contaAd_" + index));
                        visivel($("agenciaAd_" + index));
                    }
                }

                // SE FOR NDD
                if ($('isNdd_' + index).value == true || $('isNdd_' + index).value == 't' || $('isNdd_' + index).value == 'true') {
                    visivel($("tipoFavorecido_" + index));
                    if ($("formaPagto_" + index).value == "14") {
                        if ($("tipoPagto_" + index).value == "a") {
                            visivel($("br1_" + index));
                        }
                        invisivel($("br2_" + index));
                        invisivel($("br3_" + index));
                        visivel($("lab1_" + index));
                        invisivel($("tipoContaPgto_" + index));
                        invisivel($("lab3_" + index));
                        invisivel($("lab4_" + index));
                        invisivel($("banco_" + index));
                        invisivel($("favorecidoAd_" + index));
                        invisivel($("contaAd_" + index));
                        invisivel($("agenciaAd_" + index));
                    } else if ($("formaPagto_" + index).value == "4") {
                        if ($("tipoPagto_" + index).value == "a") {
                            visivel($("br1_" + index));
                        }
                        visivel($("br2_" + index));
                        visivel($("br3_" + index));
                        visivel($("lab1_" + index));
                        visivel($("tipoContaPgto_" + index));
                        visivel($("lab3_" + index));
                        visivel($("lab4_" + index));
                        visivel($("banco_" + index));
                        invisivel($("favorecidoAd_" + index));
                        visivel($("contaAd_" + index));
                        visivel($("agenciaAd_" + index));
                    }
                }
                // SE FOR Ticket
                if ($('isTicket_' + index).value == true || $('isTicket_' + index).value == 't' || $('isTicket_' + index).value == 'true') {
                    visivel($("tipoFavorecido_" + index));
                    if ($("formaPagto_" + index).value == "13") {
                        if ($("tipoPagto_" + index).value == "a") {
                            visivel($("br1_" + index));
                        }
                        invisivel($("br2_" + index));
                        invisivel($("br3_" + index));
                        visivel($("lab1_" + index));
                        invisivel($("tipoContaPgto_" + index));
                        invisivel($("lab3_" + index));
                        invisivel($("lab4_" + index));
                        invisivel($("banco_" + index));
                        invisivel($("favorecidoAd_" + index));
                        invisivel($("contaAd_" + index));
                        invisivel($("agenciaAd_" + index));
                    } else if ($("formaPagto_" + index).value == "4") {
                        if ($("tipoPagto_" + index).value == "a") {
                            visivel($("br1_" + index));
                        }
                        visivel($("br2_" + index));
                        visivel($("br3_" + index));
                        visivel($("lab1_" + index));
                        visivel($("tipoContaPgto_" + index));
                        visivel($("lab3_" + index));
                        visivel($("lab4_" + index));
                        visivel($("banco_" + index));
                        invisivel($("favorecidoAd_" + index));
                        visivel($("contaAd_" + index));
                        visivel($("agenciaAd_" + index));
                    }
                }
                //Se for Repom
                if ($('isRepom_' + index).value == true || $('isRepom_' + index).value == 't' || $('isRepom_' + index).value == 'true') {
                    if ($('idAgentePgto_' + index).value == 0) {
                        $('idAgentePgto_' + index).value = $('agente_repom_id_' + $('filial').value).value;
                        $('agentePgto_' + index).value = $('agente_repom_' + $('filial').value).value;
                    }
                }
                // Se for Target
                if ($('isTarget_' + index).value == true || $('isTarget_' + index).value == 't' || $('isTarget_' + index).value == 'true') {
                    visivel($("tipoFavorecido_" + index));
                    if ($("formaPagto_" + index).value == "20") {
                        invisivel($("br1_" + index));
                        invisivel($("br2_" + index));
                        invisivel($("br3_" + index));
                        visivel($("lab1_" + index));
                        invisivel($("tipoContaPgto_" + index));
                        invisivel($("lab3_" + index));
                        invisivel($("lab4_" + index));
                        invisivel($("banco_" + index));
                        invisivel($("favorecidoAd_" + index));
                        invisivel($("contaAd_" + index));
                        invisivel($("agenciaAd_" + index));
                    } else if ($("formaPagto_" + index).value == "4") {
                        visivel($("br1_" + index));
                        visivel($("br2_" + index));
                        visivel($("br3_" + index));
                        visivel($("lab1_" + index));
                        visivel($("tipoContaPgto_" + index));
                        visivel($("lab3_" + index));
                        visivel($("lab4_" + index));
                        visivel($("banco_" + index));
                        invisivel($("favorecidoAd_" + index));
                        visivel($("contaAd_" + index));
                        visivel($("agenciaAd_" + index));
                    }
                }
            }

            function abrirObservacao(index){
                if($("imgPluMinus_"+index).value === "plus"){
                    $("imgPluMinus_"+index).src = "img/minus.jpg";
                    $("imgPluMinus_"+index).value = "minus";
                    $("trObs_"+index).style.display = "";
                }else{
                    $("imgPluMinus_"+index).src = "img/plus.jpg";
                    $("imgPluMinus_"+index).value = "plus";
                    $("trObs_"+index).style.display = "none";
                }
            }

            function verDocumPgto(linha, valueSelect) {
                if ($("formaPagto_" + linha).value == "3" && $("tipoPagto_" + linha).value == "a" && ${configuracao.gerar_despesa_cartafrete} && ${configuracao.controlarTalonario}) {
                    controlarCheque(${configuracao.controlarTalonario}, $("documPgto2_" + linha), $("documPgto_" + linha), $('contaPgto_' + linha).value, valueSelect);

                }else if ($("formaPagto_" + linha).value == "2"){
                       $("tipoFavorecido_"+linha).value ='m'; 

                }else {
                    invisivel($("documPgto2_" + linha));
                    visivel($("documPgto_" + linha));
                }
                alterarTipoPagamento(linha);
            }
            //@@@@@@@@@@@@@@@@@@@  PAGAMENTO @@@@@@@@@@@@@@@@ FIM

            //@@@@@@@@@@@@@@@@@@@  DESPESAS @@@@@@@@@@@@@@@@ INICIO
            
            function editarDespesa(index){
                if($("idDepesa_"+index)){
                    var id = $("idDepesa_"+index).value;
                    var podeExcluir = ($("inpBaixado_"+index).value == true || $("inpBaixado_"+index).value == 'true');
                        tryRequestToServer(function () {
                            window.open("./caddespesa?acao=editar&id="+id+"&podeExcluir="+podeExcluir,'Despesa_Agregada','top=80,left=0,height=400,width=1000,resizable=yes,status=1,scrollbars=1,fullscreen=yes');
                         });
                }   
            }
            
            function addDespesa(despesa) {
                if (despesa == null || despesa == undefined) {
                    despesa = new Despesa();
                    despesa.data = dataAtual;
                    despesa.venc = dataAtual;
                }
                countDespesa++;

                despesa.index = countDespesa;
                //chamada de funcoes
                var callVerDocumDesp = "verDocumDesp(" + countDespesa + ");";
                var callLocalizarFornecedor = "abrirLocalizarFornecedor(" + countDespesa + ");";
                var callLocalizarHistorico = "abrirLocalizarHistorico(" + countDespesa + ");";
                var callLocalizarPlano = "abrirLocalizaPlanoCusto(" + countDespesa + ");";
                var callVerContaDesp = "verContaDespesa(" + countDespesa + ");";

                var _table = Builder.node("TABLE", {width: "100%", className: "bordaFina"});
                var _tBody = Builder.node("TBODY", {id: "tBodyPlano_" + countDespesa});
                var _td0 = Builder.node("TD", {colSpan: 11});

                var _tr1 = Builder.node("TR", {id: "tr_" + countDespesa});//tr
                var _tr2 = Builder.node("TR", {id: "trContaDespesa_" + countDespesa});//tr
                var _tr3_1 = Builder.node("TR", {id: "tr_" + countDespesa, className: "celula"});//tr
                var _tr3 = Builder.node("TR", {id: "trPlanoCusto_" + countDespesa});//trPlanoCusto_
                //td's
                var _td1 = Builder.node("TD", {className: "textoCamposNoAlign", align: "center"});
                var _td1desp = Builder.node("TD", {className: "textoCamposNoAlign", align: "center"});
                var _td2 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left"});
                var _td3 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left"});
                var _td4 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left"});
                var _td5 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left"});
                var _td6 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left"});
                var _td7 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left"});
                var _td8 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left"});
                var _td9 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left"});
                var _td10 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left", colSpan: 2});

                var _td2_0 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left"});
                var _td2_1 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left", colSpan: 4});
                var _td2_2 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left", colSpan: 6});


                var _td3_1 = Builder.node("TD", {align: "center", width: "3%"});
                var _td3_2 = Builder.node("TD", {align: "left", width: "40%"});
                var _td3_3 = Builder.node("TD", {align: "left", width: "12%"});
                var _td3_4 = Builder.node("TD", {align: "left", width: "8%"});
                var _td3_5 = Builder.node("TD", {align: "left", width: "10%"});
                var _td3_6 = Builder.node("TD", {align: "left", width: "3%"});
                var _td3_7 = Builder.node("TD", {align: "left", width: "10%"});
                var _td3_8 = Builder.node("TD", {align: "left", width: "14%", colspan: 2});

                //label
                var _lab1 = Builder.node("LABEL");
                var _lab2 = Builder.node("LABEL");
                var _lab3 = Builder.node("LABEL");
                var _lab4 = Builder.node("LABEL");
                var _lab5 = Builder.node("LABEL");
                var _lab6 = Builder.node("LABEL");
                var _labBaixado = Builder.node("LABEL", {id: "lblBaixado_" + countDespesa, name: "lblBaixado_" + countDespesa});
                _labBaixado.value = "false";
                _labBaixado.innerHTML = "Em Aberto";


                //input's
                var _inp1 = Builder.node("INPUT", {type: "text", size: 8, maxlength: 3 , name: "serie_" + countDespesa, id: "serie_" + countDespesa, className: 'fieldMin', value: despesa.serie});
                var _inp2 = Builder.node("INPUT", {type: "text", size: 8, name: "notaFiscal_" + countDespesa, id: "notaFiscal_" + countDespesa, className: 'fieldMin', value: despesa.nf});
                var _inp3 = Builder.node("INPUT", {type: "text", size: 10, name: "dtDespesa_" + countDespesa, id: "dtDespesa_" + countDespesa, className: 'fieldDateMin', value: despesa.data});
                var _inp9 = Builder.node("INPUT", {type: "text", size: 10, name: "dtVencimento_" + countDespesa, id: "dtVencimento_" + countDespesa, className: 'fieldDateMin', value: despesa.venc});
                var _inp4 = Builder.node("INPUT", {type: "text", size: 30, name: "fornecedor_" + countDespesa, id: "fornecedor_" + countDespesa, className: 'inputReadOnly8pt', value: despesa.fornecedor});
                var _inp5 = Builder.node("INPUT", {type: "hidden", name: "idFornecedor_" + countDespesa, id: "idFornecedor_" + countDespesa, value: despesa.idFornecedor});
                var _inp13 = Builder.node("INPUT", {type: "hidden", name: "idDepesa_" + countDespesa, id: "idDepesa_" + countDespesa, value: despesa.id});
                var _lbl13 = Builder.node("LABEL", {name: "lblidDepesa_" + countDespesa, id: "lblidDepesa_" + countDespesa, className: "linkEditar", onClick: "editarDespesa(" +countDespesa+ ");" });
                _lbl13.innerHTML = despesa.id;
                var _inp6 = Builder.node("INPUT", {type: "text", size: 30, name: "historico_" + countDespesa, id: "historico_" + countDespesa, className: 'fieldMin', value: despesa.historico});
                var _inp7 = Builder.node("INPUT", {type: "hidden", name: "idHistorico_" + countDespesa, id: "idHistorico_" + countDespesa, value: despesa.idHistorico});
                var _inp8 = Builder.node("INPUT", {type: "text", size: 8, name: "valorDespesa_" + countDespesa, id: "valorDespesa_" + countDespesa, className: 'fieldMin', value: colocarVirgula(despesa.valor)});
                var _inp10 = Builder.node("INPUT", {type: "hidden", name: "maxPlano_" + countDespesa, id: "maxPlano_" + countDespesa, value: 0});
                var imgLixo = Builder.node("IMG", {src: "img/lixo.png", name: "pcLixoDespesa_" + countDespesa, id: "pcLixoDespesa_" + countDespesa, onClick: "removerDespesas(" + countDespesa + ");"});//lixeira para excluir a despesa
                var _inp11 = Builder.node("INPUT", {type: "text", size: 8, name: "documDesp_" + countDespesa, id: "documDesp_" + countDespesa, className: 'fieldMin', value: despesa.doc});
                var _inp12 = Builder.node("INPUT", {type: "checkbox", name: "isCheque_" + countDespesa, id: "isCheque_" + countDespesa, className: 'fieldMin', onClick: callVerDocumDesp});
                var _inpBaixado = Builder.node("INPUT", {type: "hidden", name: "inpBaixado_" + countDespesa, id: "inpBaixado_" + countDespesa, value: "false"});

                var _but1 = Builder.node('INPUT', {type: 'button', name: 'localizaForn_' + countDespesa, id: 'localizaForn_' + countDespesa, value: '...', className: 'inputBotaoMin', onClick: callLocalizarFornecedor});
                var _but2 = Builder.node('INPUT', {type: 'button', name: 'localizaHist_' + countDespesa, id: 'localizaHist_' + countDespesa, value: '...', className: 'inputBotaoMin', onClick: callLocalizarHistorico});

                var _img1 = Builder.node('IMG', {id: "addApropriacao_" + countDespesa, name: "addApropriacao_" + countDespesa, src: 'img/add.gif', title: 'Adicionar Apropriação', className: 'imagemLink', onClick: callLocalizarPlano});

                var _slc1 = Builder.node('SELECT', {name: 'tipoDesp_' + countDespesa, id: 'tipoDesp_' + countDespesa, className: 'fieldMin', onchange: callVerContaDesp});
                var _slc2 = Builder.node('SELECT', {name: 'especieDesp_' + countDespesa, id: 'especieDesp_' + countDespesa, className: 'fieldMin'});
                var _slc3 = Builder.node('SELECT', {name: 'contaDesp_' + countDespesa, id: 'contaDesp_' + countDespesa, className: 'fieldMin', onchange: callVerDocumDesp});
                var _slc4 = Builder.node('SELECT', {name: 'documDesp2_' + countDespesa, id: 'documDesp2_' + countDespesa, className: 'fieldMin'});


                var _optA = Builder.node('OPTION', {value: "a"});
                var _optP = Builder.node('OPTION', {value: "p"});

                _slc1.appendChild(Element.update(_optP, "A Pagar"));//prazo
                _slc1.appendChild(Element.update(_optA, "Pago"));//avista
                if(despesa.tipo != undefined && despesa.tipo !=''){
                    _slc1.value = despesa.tipo;
                }else{
                    _slc1.value = 'a';
                }
                
                var optEspecie = null;
                for (var i = 0; i < listaEspecie.length; i++) {
                    optEspecie = Builder.node("option", {
                        value: listaEspecie[i].valor
                    });
                    Element.update(optEspecie, listaEspecie[i].descricao);
                    _slc2.appendChild(optEspecie);
                }

                var optConta = null;
                for (var i = 0; i < listaConta.length; i++) {
                    optConta = Builder.node("option", {
                        value: listaConta[i].valor
                    });
                    Element.update(optConta, listaConta[i].descricao);
                    _slc3.appendChild(optConta);
                }

                if (despesa.idConta == 0) {
                    _slc3.selectedIndex = 0;
                } else {
                    _slc3.value = despesa.idConta;
                }

                 var _inp14 = Builder.node("INPUT", {type: "hidden", name: "deletado_" + countDespesa, id: "deletado_" + countDespesa, value: false});



                //referente a tr 1
                _td1.appendChild(imgLixo);
                _td1.appendChild(_inp10);
                _td1.appendChild(_inp13);
                _td1.appendChild(_inp14);
                _td2.appendChild(_slc1);
                if(_inp13.value != '0'){
                    _td1desp.appendChild(_lbl13);
                }
                _td3.appendChild(_slc2);
                _td4.appendChild(_inp1);
                _td5.appendChild(_inp2);
                _td6.appendChild(_inp3);
                _td7.appendChild(_inp4);
                _td7.appendChild(_inp5);
                _td7.appendChild(_but1);
                _td8.appendChild(_inp6);
                _td8.appendChild(_inp7);
                _td8.appendChild(_but2);
                _td9.appendChild(_inp8);
                _td10.appendChild(_labBaixado);
                _td10.appendChild(_inpBaixado);
                _tr1.appendChild(_td1);
                _tr1.appendChild(_td1desp);
                _tr1.appendChild(_td2);
                _tr1.appendChild(_td3);
                _tr1.appendChild(_td4);
                _tr1.appendChild(_td5);
                _tr1.appendChild(_td6);
                _tr1.appendChild(_td7);
                _tr1.appendChild(_td8);
                _tr1.appendChild(_td9);
                _tr1.appendChild(_td10);


                //referente a tr2
                Element.update(_lab6, " Cheque ");

                _td2_1.appendChild(_slc3);
                _td2_2.appendChild(_inp12);
                _td2_2.appendChild(_lab6);
                _td2_2.appendChild(_inp11);
                _td2_2.appendChild(_slc4);
                //_td2_1.appendChild(_slc3);

                _tr2.appendChild(_td2_0);
                _tr2.appendChild(_td2_1);
                _tr2.appendChild(_td2_2);

                //referente a tr3
                //preparando a linha com plano de custo

                Element.update(_lab1, "Plano de Custo");
                Element.update(_lab2, "Veículo");
                Element.update(_lab3, "Valor");
                Element.update(_lab4, "Und. Custo");
                Element.update(_lab5, "Vencimento:");

                _td3_1.appendChild(_img1);
                _td3_2.appendChild(_lab1);
                _td3_3.appendChild(_lab2);
                _td3_4.appendChild(_lab3);
                _td3_5.appendChild(_lab4);
                _td3_7.appendChild(_lab5);
                _td3_8.appendChild(_inp9);

                _tr3_1.appendChild(_td3_1);
                _tr3_1.appendChild(_td3_2);
                _tr3_1.appendChild(_td3_3);
                _tr3_1.appendChild(_td3_4);
                _tr3_1.appendChild(_td3_5);
                _tr3_1.appendChild(_td3_6);
                _tr3_1.appendChild(_td3_7);
                _tr3_1.appendChild(_td3_8);


                _tBody.appendChild(_tr3_1);
                _table.appendChild(_tBody);
                _td0.appendChild(_table);
                _tr3.appendChild(_td0);


                invisivel(_tr2);
                invisivel(_slc4);
                if (despesa.especieId == 0) {
                    _slc2.selectedIndex = 0;
                } else {
                    _slc2.value = despesa.especieId;
                }

                readOnly(_inp8, "inputReadOnly8pt");

                $("bodyDespesa").appendChild(_tr1);
                $("bodyDespesa").appendChild(_tr2);
                $("bodyDespesa").appendChild(_tr3);
                $("maxDespesa").value = countDespesa;

            }
            function addPropriacao(indexDespesa, plano) {
                if (plano == null || plano == undefined) {
                    plano = new ApropriacaoDespesa();
                }
                countDespesaPlanoCusto = parseInt($("maxPlano_" + indexDespesa).value);
                ++countDespesaPlanoCusto;

                var callCalcularDespesaValor = "calcularDespesaValor(" + indexDespesa + "," + countDespesaPlanoCusto + ");";
                var callLocalizarUnidadeCusto = "abrirLocalizarUndCusto('" + indexDespesa + "_" + countDespesaPlanoCusto + "');";
                var callLocalizarVeiculo = "abrirLocalizarVeiculo('" + indexDespesa + "_" + countDespesaPlanoCusto + "');";
                var callLocalizarPlano = "abrirLocalizaPlanoCusto(" + indexDespesa + "," + countDespesaPlanoCusto + ");";
                var _tr1 = Builder.node("TR", {id: "tr_" + indexDespesa + "_" + countDespesaPlanoCusto, className: "celula"});

                var imgLixo = Builder.node("IMG", {src: "img/lixo.png", name: "pcLixo_" + indexDespesa + "_" + countDespesaPlanoCusto, id: "pcLixo_" + indexDespesa + "_" + countDespesaPlanoCusto, onClick: "removerPlanoCusto(" + indexDespesa + "," + countDespesaPlanoCusto + ")"});//lixeira para excluir a despesa
                var _inp1 = Builder.node("INPUT", {type: "text", size: 12, name: "conta_" + indexDespesa + "_" + countDespesaPlanoCusto, id: "conta_" + indexDespesa + "_" + countDespesaPlanoCusto, className: 'inputReadOnly8pt', readOnly: true, value: plano.conta});
                var _inp2 = Builder.node("INPUT", {type: "text", size: 30, name: "apropriacao_" + indexDespesa + "_" + countDespesaPlanoCusto, id: "apropriacao_" + indexDespesa + "_" + countDespesaPlanoCusto, className: 'inputReadOnly8pt', readOnly: true, value: plano.apropriacao});
                var _inp3 = Builder.node("INPUT", {type: "hidden", name: "idApropriacao_" + indexDespesa + "_" + countDespesaPlanoCusto, id: "idApropriacao_" + indexDespesa + "_" + countDespesaPlanoCusto, className: 'fieldMin', value: plano.idApropriacao});
                var _inp4 = Builder.node("INPUT", {type: "text", size: 10, name: "veiculoAprop_" + indexDespesa + "_" + countDespesaPlanoCusto, id: "veiculoAprop_" + indexDespesa + "_" + countDespesaPlanoCusto, className: 'inputReadOnly8pt', readOnly: true, value: plano.veiculo});
                var _inp5 = Builder.node("INPUT", {type: "hidden", name: "idVeiculoAprop_" + indexDespesa + "_" + countDespesaPlanoCusto, id: "idVeiculoAprop_" + indexDespesa + "_" + countDespesaPlanoCusto, className: 'fieldMin', value: plano.idVeiculo});
                var _inp6 = Builder.node("INPUT", {type: "text", size: 8, name: "valorAprop_" + indexDespesa + "_" + countDespesaPlanoCusto, id: "valorAprop_" + indexDespesa + "_" + countDespesaPlanoCusto, className: 'fieldMin', value: colocarVirgula(plano.valor), onBlur: callCalcularDespesaValor, onKeyPress: callMascaraReais});
                var _inp7 = Builder.node("INPUT", {type: "hidden", name: "idUndAprop_" + indexDespesa + "_" + countDespesaPlanoCusto, id: "idUndAprop_" + indexDespesa + "_" + countDespesaPlanoCusto, className: 'fieldMin', value: plano.idUnd});
                var _inp8 = Builder.node("INPUT", {type: "text", size: 6, name: "undAprop_" + indexDespesa + "_" + countDespesaPlanoCusto, id: "undAprop_" + indexDespesa + "_" + countDespesaPlanoCusto, className: 'inputReadOnly8pt', readOnly: true, value: plano.und});

                var _but1 = Builder.node('INPUT', {type: 'button', name: 'localizaAprop_' + indexDespesa + "_" + countDespesaPlanoCusto, id: 'localizaAprop_' + indexDespesa + "_" + countDespesaPlanoCusto, value: '...', className: 'inputBotaoMin', onClick: callLocalizarPlano});
                var _but2 = Builder.node('INPUT', {type: 'button', name: 'localizaVeic_' + indexDespesa + "_" + countDespesaPlanoCusto, id: 'localizaVeic_' + indexDespesa + "_" + countDespesaPlanoCusto, value: '...', className: 'inputBotaoMin', onClick: callLocalizarVeiculo});
                var _but3 = Builder.node('INPUT', {type: 'button', name: 'localizaUnd_' + indexDespesa + "_" + countDespesaPlanoCusto, id: 'localizaUnd_' + indexDespesa + "_" + countDespesaPlanoCusto, value: '...', className: 'inputBotaoMin', onClick: callLocalizarUnidadeCusto});

                var _td1 = Builder.node("TD", {align: "center"});
                var _td2 = Builder.node("TD", {align: "left"});
                var _td3 = Builder.node("TD", {align: "left"});
                var _td4 = Builder.node("TD", {align: "left"});
                var _td5 = Builder.node("TD", {align: "left"});
                var _td6 = Builder.node("TD", {align: "left"});
                var _td7 = Builder.node("TD", {align: "left"});
                var _td8 = Builder.node("TD", {align: "left"});

                _td1.appendChild(imgLixo);
                _td2.appendChild(_inp1);
                _td2.appendChild(_inp2);
                _td2.appendChild(_but1);
                _td2.appendChild(_inp3);
                _td3.appendChild(_inp4);
                _td3.appendChild(_inp5);
                //_td3.appendChild(_but2);
                _td4.appendChild(_inp6);
                _td5.appendChild(_inp7);
                _td5.appendChild(_inp8);
                _td5.appendChild(_but3);

                _tr1.appendChild(_td1);
                _tr1.appendChild(_td2);
                _tr1.appendChild(_td3);
                _tr1.appendChild(_td4);
                _tr1.appendChild(_td5);
                _tr1.appendChild(_td6);
                _tr1.appendChild(_td7);
                _tr1.appendChild(_td8);

                $("tBodyPlano_" + indexDespesa).appendChild(_tr1);
                $("maxPlano_" + indexDespesa).value = countDespesaPlanoCusto;

            }
            function verDocumDesp(linha) {
                if ($("isCheque_" + linha) != null && $("isCheque_" + linha).checked) {
                    controlarCheque(${configuracao.controlarTalonario}, $("documDesp2_" + linha), $("documDesp_" + linha), $('contaDesp_' + linha).value);
                }
            }
            function escEspDivCont(idDivAtual, imgAtual){
                var divAtual = document.getElementById(idDivAtual);
                    if (divAtual.style.display == '') {
                        divAtual.style.display = 'none';
                        if (imgAtual != null) {
                            imgAtual.src = "img/plus.jpg";
                        }
                    } else {
                        divAtual.style.display = '';
                        if (imgAtual != null) {
                            imgAtual.src = "img/minus.jpg";
                        }
                    }
            }
          
            //@@@@@@@@@@@@@@@@@@@  DOCUMENTO @@@@@@@@@@@@@@@@ INICIO
            var listadocumento = null;
            function addDocumentoContratoFrete(documento) {

                if (listadocumento == null) {
                    listadocumento = new Array();
                }
                if (documento == null || documento == undefined) {
                    documento = new ContratoFreteDocumento();
                }
                countDocum++;

                var _tr = Builder.node("TR", {id: "trDocum_" + countDocum});
                //---------------------- Documento Manifesto ------------------------------------//
                var _trDManifMaster = Builder.node("TR", {id: "trDocumManifMaster_" + countDocum, style:"display:"});
                
                var _tbMaster = Builder.node("TABLE", {id: "tbMaster_" + countDocum, style:"display:", width:"100%"});
                
                var _tdDepois = Builder.node("TD", {className: "inputtext", style:"display:none", align: "center", id:"tddepois"+countDocum, name:"", colspan:"11"});
                
                var _tdDManif = Builder.node("TD", {className: "celulaZebra1", align: "center", id:"tdVazia123_"+countDocum, name:"", cospan:11 });
                
                var _trDManif = Builder.node("TR", {id: "trDocumManif_" + countDocum, style:"display:"});
                
                var _tdLb_0 = Builder.node("TD", {className: "textoCamposNoAlign", align: "center", id:"tdVazia_"+countDocum, name:""});
                
                var _tdLbFilOrig = Builder.node("TD", {className: "textoCamposNoAlign", align: "right"});
                var _labFilOrig = Builder.node("LABEL", {id: "labelFilOrig_" + countDocum, className:"textoLabel"});
                _labFilOrig.innerHTML = "Filial de Origem:";
                
                var _tdInpFilOrig = Builder.node("TD", {className: "textoCamposNoAlign", align: "center"});
                var _inpFilOrig = Builder.node("LABEL", {id: "inpFilOrig_" + countDocum, className:"textoLabel"});
                _inpFilOrig.innerHTML = documento.filialOrigem;
                
                var _tdLbFilDest = Builder.node("TD", {className: "textoCamposNoAlign", align: "center"});
                var _labFilDest = Builder.node("LABEL", {id: "labelFilDest_" + countDocum, className:"textoLabel"});
                _labFilDest.innerHTML = "Filial de Destino";
                
                var _tdInpFilDest = Builder.node("TD", {className: "textoCamposNoAlign", align: "center"});
                var _inpFilDest = Builder.node("LABEL", {id: "inpFilDest_" + countDocum, className:"textoLabel"});
                _inpFilDest.innerHTML = documento.filialDestino;
                
                var _tdLbTotalLbCIF = Builder.node("TD", {className: "textoCamposNoAlign", align: "center"});
                var _labFilTotalCIF = Builder.node("LABEL", {id: "labelTotalCIF_" + countDocum, className:"textoLabel"});
                _labFilTotalCIF.innerHTML = "Tot. Frete CIF:";
                
                var _tdInpTotalDestCIF = Builder.node("TD", {className: "textoCamposNoAlign", align: "right"});
                var _inpFilTotalCIF = Builder.node("LABEL", {id: "inpTotalCIF_" + countDocum, className:"textoLabel"});
                _inpFilTotalCIF.innerHTML = documento.totalCteCIF;
                
                var _tdLbTotalLbFOB = Builder.node("TD", {className: "textoCamposNoAlign", align: "center"});
                var _labFilTotalFOB = Builder.node("LABEL", {id: "labelTotalFOB_" + countDocum, className:"textoLabel"});
                _labFilTotalFOB.innerHTML = "Tot. Frete FOB:";
                
                var _tdInpTotalDestFOB = Builder.node("TD", {className: "textoCamposNoAlign", align: "right"});
                var _inpFilTotalFOB = Builder.node("LABEL", {id: "inpTotalFOB_" + countDocum, className:"textoLabel"});
                _inpFilTotalFOB.innerHTML = documento.totalCteFOB;
                
                var _tdLbTotalLbTerceiro = Builder.node("TD", {className: "textoCamposNoAlign", align: "center"});
                var _labFilTotalTerceiro = Builder.node("LABEL", {id: "labelTerceiros_" + countDocum, className:"textoLabel"});
                _labFilTotalTerceiro.innerHTML = "Tot. Frete Terceiros:";
                
                var _tdInpTotalDestTerceiro = Builder.node("TD", {className: "textoCamposNoAlign", align: "right"});
                var _inpFilTotalTerceiro = Builder.node("LABEL", {id: "inpTotalTerceiros_" + countDocum, className:"textoLabel"});
                _inpFilTotalTerceiro.innerHTML = documento.totalCteTerceiro;
                
                var _inpIdFilialDestino = Builder.node("INPUT", {type: "hidden", size: "5", name: "idFilialDestino_" + countDocum, id: "idFilialDestino_" + countDocum, value: documento.idFilialDestino});
                
                //Tive que tirar o name, verificar se pode dá algum problema.
                var _inp1 = Builder.node("INPUT", {type: "hidden", size: "5", name: "tipoDocumento_" + countDocum, id: "tipoDocumento_" + countDocum, value: documento.tipo});

                var _inp2 = Builder.node("INPUT", {type: "hidden", size: "5", name: "idDocumento_" + countDocum, id: "idDocumento_" + countDocum, value: documento.id});
                var _inpOrigemId = Builder.node("INPUT", {type: "hidden", size: "5", name: "idOrigem_" + countDocum, id: "idOrigem_" + countDocum, value: documento.origemId});
                var _inpDestinoId = Builder.node("INPUT", {type: "hidden", size: "5", name: "idDestino_" + countDocum, id: "idDestino_" + countDocum, value: documento.destinoId});
                var _inpClienteId = Builder.node("INPUT", {type: "hidden", size: "5", name: "idCliente_" + countDocum, id: "idCliente_" + countDocum, value: documento.clienteId});
                var _inpClienteIsRota = Builder.node("INPUT", {type: "hidden", size: "5", name: "isMostraRota_" + countDocum, id: "isMostraRota_" + countDocum, value: documento.isMostraRotaCliente});
                var _inpTipoDoc = Builder.node("INPUT", {type: "hidden", size: "5", name: "idTipoDoc_" + countDocum, id: "idTipoDoc_" + countDocum, value: documento.tipo});
                var _inpClienteNegociacaoId = Builder.node("INPUT", {type: "hidden", size: "5", name: "ClienteNegociacaoId_" + countDocum, id: "ClienteNegociacaoId_" + countDocum, value: documento.clienteNegociacao});

                var _td0 = Builder.node("TD", {className: "textoCamposNoAlign", align: "center"});
                var _td1 = Builder.node("TD", {className: "textoCamposNoAlign", align: "center"});
                var _td2 = Builder.node("TD", {className: "textoCamposNoAlign", align: "center"});
                var _td3 = Builder.node("TD", {className: "textoCamposNoAlign", align: "center"});
                var _td4 = Builder.node("TD", {className: "textoCamposNoAlign", align: "center"});
                var _td5 = Builder.node("TD", {className: "textoCamposNoAlign", align: "right"});
                var _tdEntregas = Builder.node("TD", {className: "textoCamposNoAlign", align: "right"});
                var _td6 = Builder.node("TD", {className: "textoCamposNoAlign", align: "right"});
                var _td7 = Builder.node("TD", {className: "textoCamposNoAlign", align: "right"});
                var _td8 = Builder.node("TD", {className: "textoCamposNoAlign", align: "right"});
                var _td9 = Builder.node("TD", {className: "textoCamposNoAlign", align: "right"});
                    
                var _ip1aPlus = Builder.node("img", {
                        src: "img/plus.jpg",
                        onclick: "escEspDivCont('tddepois" + countDocum + "',this);"
                    });
                    
                var _lab0 = Builder.node("LABEL", {id: "labelTipo_" + countDocum});
                var _lab1 = Builder.node("LABEL", {id: "labelNumero_" + countDocum, onClick: "tryRequestToServer(function(){verDocumento('" + documento.tipo + "', '" + documento.id + "');});", className: "linkEditar"});
                var _lab2 = Builder.node("LABEL", {id: "labelOrigem_" + countDocum});
                var _lab3 = Builder.node("LABEL", {id: "labelDestino_" + countDocum});
                var _lab4 = Builder.node("LABEL", {id: "labelData_" + countDocum});
                var _labQtdEntregas = Builder.node("LABEL", {id: "labelEntregas_" + countDocum});
                var _lab5 = Builder.node("LABEL", {id: "labelPeso_" + countDocum});
                var _lab6 = Builder.node("LABEL", {id: "labelValorFrete_" + countDocum});
                var _lab7 = Builder.node("LABEL", {id: "labelVol_" + countDocum});
                var _lab8 = Builder.node("LABEL", {id: "labelValorNota_" + countDocum});

                var _valorFreteCte = Builder.node("input", {
                    id: "valorFreteCte_" + countDocum,
                    name: "valorFreteCte_" + countDocum,
                    type: "hidden",
                    value: colocarVirgula(documento.valorFreteCte)
                });

                var _valorPesoCte = Builder.node("input", {
                    id: "valorPesoCte_" + countDocum,
                    name: "valorPesoCte_" + countDocum,
                    type: "hidden",
                    value: colocarVirgula(documento.valorPesoCte)
                });

                var _tdLbPedagio = Builder.node("TD", {className: "textoCamposNoAlign", align: "center"});
                var _labPedagio = Builder.node("LABEL", {id: "labelPedagio_" + countDocum, className: "textoLabel"});
                _labPedagio.innerHTML = "Pedágio:";

                var _tdInpPedagio = Builder.node("TD", {className: "textoCamposNoAlign", align: "right"});
                var _inpPedagio = Builder.node("LABEL", {id: "inpPedagio_" + countDocum, className: "textoLabel"});
                _inpPedagio.innerHTML = documento.valorPedagio;

                Element.update(_lab0, documento.tipo);
                Element.update(_lab1, documento.numero);
                Element.update(_lab2, documento.origem);
                Element.update(_lab3, documento.destino);
                Element.update(_lab4, documento.data);
                Element.update(_labQtdEntregas, documento.qtdEntregas);
                Element.update(_lab5, colocarVirgula(documento.peso));
                Element.update(_lab6, colocarVirgula(documento.valorFrete));
                Element.update(_lab7, colocarVirgula(documento.volumes));
                Element.update(_lab8, colocarVirgula(documento.valorNota));
                              
                if (documento.tipo == "MANIFESTO") {
                    _td0.appendChild(_ip1aPlus);
                }
                _td1.appendChild(_lab0);
                _td1.appendChild(_inp1);
                _td1.appendChild(_inp2);
                _td1.appendChild(_inpTipoDoc);
                _td2.appendChild(_lab1);
                _td3.appendChild(_lab2);
                _td3.appendChild(_inpOrigemId);
                _td4.appendChild(_lab3);
                _td4.appendChild(_inpDestinoId);
                _td4.appendChild(_inpClienteId);
                _td4.appendChild(_inpClienteNegociacaoId);
                _td4.appendChild(_inpClienteIsRota);
                _td5.appendChild(_lab4);
                _tdEntregas.appendChild(_labQtdEntregas);
                _td6.appendChild(_lab5);
                _td7.appendChild(_lab7);
                _td8.appendChild(_lab8);
                _td9.appendChild(_lab6);
                _td9.appendChild(_valorFreteCte);
                _td9.appendChild(_valorPesoCte);
                
                _tr.appendChild(_td0);                                
                _tr.appendChild(_td1);
                _tr.appendChild(_td2);
                _tr.appendChild(_td3);
                _tr.appendChild(_td4);
                _tr.appendChild(_td5);
                _tr.appendChild(_tdEntregas);
                _tr.appendChild(_td6);
                _tr.appendChild(_td7);
                _tr.appendChild(_td8);
                _tr.appendChild(_td9);
                
                
                Element.update(_inpFilTotalCIF, colocarVirgula(documento.totalCteCIF));
                Element.update(_inpFilTotalFOB, colocarVirgula(documento.totalCteFOB));
                Element.update(_inpFilTotalTerceiro, colocarVirgula(documento.totalCteTerceiro));
                Element.update(_inpPedagio, colocarVirgula(documento.valorPedagio));
                
                
                _tdLb_0.appendChild(_inpIdFilialDestino);
                
                _tdLbFilOrig.appendChild(_labFilOrig);
                _tdInpFilOrig.appendChild(_inpFilOrig);
                _tdLbFilDest.appendChild(_labFilDest);
                _tdInpFilDest.appendChild(_inpFilDest);
                
                _tdLbTotalLbCIF.appendChild(_labFilTotalCIF);
                _tdInpTotalDestCIF.appendChild(_inpFilTotalCIF);
                
                _tdLbTotalLbFOB.appendChild(_labFilTotalFOB);
                _tdInpTotalDestFOB.appendChild(_inpFilTotalFOB);
                
                _tdLbTotalLbTerceiro.appendChild(_labFilTotalTerceiro);
                _tdInpTotalDestTerceiro.appendChild(_inpFilTotalTerceiro);

                _tdLbPedagio.appendChild(_labPedagio);
                _tdInpPedagio.appendChild(_inpPedagio);

                _trDManif.appendChild(_tdLb_0);
                _trDManif.appendChild(_tdLbFilOrig);
                _trDManif.appendChild(_tdInpFilOrig);
                _trDManif.appendChild(_tdLbFilDest);
                _trDManif.appendChild(_tdInpFilDest);
                
                _trDManif.appendChild(_tdLbTotalLbCIF);
                _trDManif.appendChild(_tdInpTotalDestCIF);
                
                _trDManif.appendChild(_tdLbTotalLbFOB);
                _trDManif.appendChild(_tdInpTotalDestFOB);
                
                _trDManif.appendChild(_tdLbTotalLbTerceiro);
                _trDManif.appendChild(_tdInpTotalDestTerceiro);

                _trDManif.appendChild(_tdLbPedagio);
                _trDManif.appendChild(_tdInpPedagio);
                
                _trDManif.appendChild(_tdDManif);
                
                _tbMaster.appendChild(_trDManif);
                
                _tdDepois.appendChild(_tbMaster);
                
                _trDManifMaster.appendChild(_tdDepois);
                
                
                $("bodyDocum").appendChild(_tr);
                if (documento.tipo == "MANIFESTO") {
                    $("bodyDocum").appendChild(_trDManifMaster);           
                }
                $("maxDocumento").value = countDocum;
                calcularEntregas(countDocum);
                calcularPeso(countDocum);
                calcularVolume(countDocum);
                calcularValorNota(countDocum);
                calcularValorFrete(countDocum);
                calcularValorFreteCte(countDocum);
                calcularValorPesoCte(countDocum);
                
                listadocumento[countDocum] = documento;
                
            }

            function verDocumento(tipoDoc, idDoc) {
                if (tipoDoc == 'ROMANEIO') {
    <c:if test="${param.nivelRomaneio == 0}">
                    alert('Atenção: Você não tem privilégios suficientes para acessar a tela de Romaneio!');
                    return false;
    </c:if>
                    window.open('./cadromaneio.jsp?acao=editar&id=' + idDoc + '&ex=false', 'Romaneio', 'top=0,resizable=yes,status=1,scrollbars=1');
                } else if (tipoDoc == 'COLETA') {
    <c:if test="${param.nivelColeta == 0}">
                    alert('Atenção: Você não tem privilégios suficientes para acessar a tela de Coleta!');
                    return false;
    </c:if>
                    window.open('./cadcoleta.jsp?acao=editar&id=' + idDoc + '&ex=false', 'Coleta', 'top=0,resizable=yes,status=1,scrollbars=1');
                } else {
    <c:if test="${param.nivelManifesto == 0}">
                    alert('Atenção: Você não tem privilégios suficientes para acessar a tela de Manifesto!');
                    return false;
    </c:if>
                    window.open('./cadmanifesto?acao=editar&id=' + idDoc + '&ex=false', 'Manifesto', 'top=0,resizable=yes,status=1,scrollbars=1');
                }

            }

            function selecionar_manifesto(qtdLinhas, acao) {
                var nivelProprio = parseFloat('${param.nivelVeiculoProprio}');
                if ($("mostrarTudo").checked && nivelProprio < 4) {
                    alert('ATENÇÃO! Você não tem privilégios suficiente para selecionar documentos de veículos próprios.\r\n\r\n\r\nCódigo da permissão: 293');
                    return null;
                }
                if ($("motor_nome").value == "" || $("vei_placa").value == "") {
                    alert("ATENÇÃO: Escolha primeiro um motorista e uma placa!");
                    return false;
                }

                tryRequestToServer(function () {
                    window.open('./selecionamanifesto?acao=iniciar&marcados2=' + $("idcontratofrete").value + '&marcados=' + verificaManifs() + '&acaoDoPai=' + acao + "&filial=" +
                            $("filial").value + "&mostratudo=" + $("mostrarTudo").checked + "&idmotorista=" + $("idmotorista").value + "&motor_nome=" + $("motor_nome").value + "&travarMotorista=true"
                            , 'ManifRom', 'top=80,left=0,height=400,width=1000,resizable=yes,status=1,scrollbars=1,fullscreen=yes')
                });
            }

            function getDiariaParada() {
                if ($('diariaParada').checked) {
    <c:if test="${configuracao.diariaRetemImposto}">
                    $('con_rzs').style.display = "";
                    $('borrachaCliente').style.display = "";
                    $('botaoCliente').style.display = "";
                    $('lbCliente').style.display = "";
                    $('lbCidadeDest').style.display = "";
                    $('cid_destino').style.display = "";
                    $('uf_destino').style.display = "";
                    $('borrachaCidade').style.display = "";
                    $('botaoCidade').style.display = "";
    </c:if>
    <c:if test="${param.acao == 2 && param.nivelAlteraValor != 4}">
                    $('borrachaCliente').style.display = "none";
                    $('botaoCliente').style.display = "none";
                    $('borrachaCliente2').style.display = "none";
                    $('botaoCliente2').style.display = "none";
    </c:if>
                } else {
    <c:if test="${configuracao.diariaRetemImposto}">
                    $('con_rzs').style.display = "none";
                    $('borrachaCliente').style.display = "none";
                    $('botaoCliente').style.display = "none";
                    $('lbCliente').style.display = "none";
                    $('lbCidadeDest').style.display = "none";
                    $('cid_destino').style.display = "none";
                    $('uf_destino').style.display = "none";
                    $('borrachaCidade').style.display = "none";
                    $('botaoCidade').style.display = "none";
    </c:if>
                }
            }

            //@@@@@@@@@@@@@@@@@@@  DOCUMENTO @@@@@@@@@@@@@@@@ FIM

            function validacaoValorTonelada() {

                //Permissao de alteração de valores
    <c:if test="${param.nivelAlteraFreteTabela != 4}">
                if (!$('solicitarAutorizacao').checked) {
                    desabilitarCampo('vlUnitarioDiaria');
                    desabilitarCampo('vlFreteMotorista');
                    desabilitarCampo('vlTonelada');
                    desabilitarCampo('valorPorKM');
                }
                return false;
    </c:if>
                if (colocarPonto($('vlFreteMotorista').value) > 0 && colocarPonto($('vlTonelada').value) == 0 && (colocarPonto($('valorPorKM').value) == 0 || colocarPonto($('quantidadeKm').value) == 0)) {
                    desabilitarCampo('vlTonelada');
                    desabilitarCampo('quantidadeKm');
                    desabilitarCampo('valorPorKM');
                } else if (colocarPonto($('vlTonelada').value) > 0) {
                    desabilitarCampo('vlFreteMotorista');
                    desabilitarCampo('valorPorKM');
                    desabilitarCampo('quantidadeKm');
                    habilitarCampo('vlTonelada');
                } else if (colocarPonto($('valorPorKM').value) > 0 && colocarPonto($('quantidadeKm').value) > 0) {
                    desabilitarCampo('vlFreteMotorista');
                    desabilitarCampo('vlTonelada');
                    habilitarCampo('valorPorKM');
                    habilitarCampo('quantidadeKm');
                } else if (colocarPonto($('valorPorKM').value) == 0 || colocarPonto($('quantidadeKm').value) == 0) {
                    habilitarCampo('vlFreteMotorista');
                    habilitarCampo('vlTonelada');
                    habilitarCampo('valorPorKM');
                    habilitarCampo('quantidadeKm');
                }

            }

            function liberarCamposQuantidade() {

                if (colocarPonto($('quantidadeKm').value) == 0) {
                    habilitarCampo('vlTonelada');
                    habilitarCampo('valorPorKM');
                    habilitarCampo('vlFreteMotorista');
                } else if (colocarPonto($('quantidadeKm').value) > 0 && colocarPonto($('valorPorKM').value) > 0) {
                    desabilitarCampo('vlTonelada');
                    desabilitarCampo('vlFreteMotorista');
                    habilitarCampo('valorPorKM');
                    habilitarCampo('quantidadeKm');
                }

    <c:if test="${param.nivelAlteraFreteTabela != 4}">
                if (!$('solicitarAutorizacao').checked) {
                    desabilitarCampo('vlFreteMotorista');
                    desabilitarCampo('vlTonelada');
                    desabilitarCampo('vlUnitarioDiaria');
                    desabilitarCampo('valorPorKM');
                }
    </c:if>

            }
            
                 
        function getEnderecoByCep(cep, localiza){
            if (cep.trim() != '') {
                espereEnviar("",true);	  		
                new Ajax.Request("./jspcadcliente.jsp?acao=getEnderecoByCep&cep="+ cep,
                {
                    method:"get",
                    onSuccess: function(transport){
                        let response = transport.responseText;                    
                        carregaCepAjax(response, localiza);
                    },
                    onFailure: function(){ }
                });
            }
        }
        
        function carregaCepAjax(resposta, localiza){
            
            let rua = resposta.split("@@")[1];
            let bairro = resposta.split("@@")[2];
            let cidade = resposta.split("@@")[4];
            let idCidade = resposta.split("@@")[5];
            let uf = resposta.split("@@")[6];

                if (localiza == 'cidadeOrigem' && cidade != 0) {
                    $("id-cidade-origem").value = idCidade;
                    $("cidade-origem").value = cidade;
                    $("uf-origem").value = uf;
                } else if (localiza == 'cidadeDestino' && cidade != 0) {
                    $("id-cidade-destino").value = idCidade;
                    $("cidade-destino").value = cidade;
                    $("uf-destino").value = uf;
                } else {
                    alert('Não foi localizado endereço para este CEP!');
                    if (localiza == 'cidadeOrigem') {
                        limparCidadeOrigem();
                    } else if (localiza == 'cidadeDestino') {
                        limparCidadeDestino();
                    }
                }
            
            espereEnviar("",false);	  		
        }
        
        function getAjudaCidadeOrigem() {
            let mensagem = "OBS: Se não preencher o CEP será enviado para ANTT o CEP da Filial do contrato de frete.";
            if (${param.utilizacaoCfe != 'R'}) {
                mensagem += " Se não preencher a cidade de origem, será enviado para ANTT a cidade de origem definida na rota informada no contrato de frete.";
            }
        
            alert(mensagem);
        }

        function getAjudaCidadeDestino() {
            let mensagem = "OBS: Se não preencher o CEP será enviado para ANTT o CEP do destinatário da carga.";
            if (${param.utilizacaoCfe != 'R'}) {
                mensagem += " Se não preencher a cidade de destino, será enviado para ANTT a cidade de destino definida na rota informada no contrato de frete.";
            }
            
            alert(mensagem);
        }
        
</script>
<style type="text/css">
    <!--
    .style1 {
        color: #990000
    }

    .style3 {
        color: #EADEC8
    }
    -->
    
    .textoLabel{
        font-weight: bold;
    }
</style>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>WebTrans - Lançamento do Contrato de Frete</title>
    </head>
    <body onload="carregar();
            applyFormatter();
            applyChangeHandler();alterarOperadoraCiot();calculaTotalTarifas();">
        <div align="center">
            <img alt="" src="img/banner.gif" width="30%" height="64"> <br>
            <table class="bordaFina" width="80%">
                <tr>
                    <td width="80%" align="left"><b>Lançamento de Contrato de Frete</b></td>
                    <td width="10%">
                        <div style="margin-right: 10px;">
                            <c:if test="${param.utilizacaoCfe == 'E'}">
                                <input type="button"  value=" Consultar Situação dos veículos na ANTT (e-Frete) " class="inputBotao" onclick="consultarSituacaoVeiculoEfrete()" /> 
                            </c:if>
                        </div>
                        <div style="margin-right: 10px;">
                            <c:if test="${param.utilizacaoCfe == 'G'}">
                                <input type="button"  value=" Consultar Situação dos veículos na ANTT (PagBem) " class="inputBotao" onclick="consultarSituacaoVeiculoEfrete()" /> 
                            </c:if>
                        </div>
                    </td>
                    <td width="10%" style="${usuario.filial.stUtilizacaoCfeS=='X'? "": "display: none" }"  id="tdConsultaExpers">
                        <input type="button"  value=" Consultar Situação do Contratado na ANTT (Expers) " class="inputBotao" onclick="enviarProprietarioExpers();" />
                    </td>
                    <td width="10%">
                        
                        <input type="button"  value=" Voltar para Consulta " class="inputBotao" onclick="voltar()" /> <!--Hidden's para os botoes de localziar -->
                        <input type="hidden" name="fornecedor" id="fornecedor" value="0" size="10" class="inputtexto" /> 
                        <input type="hidden" name="idfornecedor" id="idfornecedor" value="0" size="10" class="inputtexto" /> 
                        <input type="hidden" name="descricao_historico" id="descricao_historico" value="0" size="10" class="inputtexto" /> 
                        <input type="hidden" name="idhist" id="idhist" value="0" size="10" class="inputtexto" /> 
                        <input type="hidden" name="idplcustopadrao" id="idplcustopadrao" value="0" size="10" class="inputtexto" /> 
                       
                        <input type="hidden" name="contaplcusto" id="contaplcusto" value="0" size="10" class="inputtexto" /> 
                        <input type="hidden" name="descricaoplcusto" id="descricaoplcusto" value="0" size="10" class="inputtexto" /> 
                        <input type="hidden" name="veiculo_id" id="veiculo_id" value="0" size="10" class="inputtexto" /> 
                        <input type="hidden" name="veiculo" id="veiculo" value="0" size="10" class="inputtexto" /> 
                        <input type="hidden" name="id_und_forn" id="id_und_forn" value="0" size="10" class="inputtexto" /> 
                        <input type="hidden" name="id_und" id="id_und" value="0" size="10" class="inputtexto" /> 
                        <input type="hidden" name="sigla_und_forn" id="sigla_und_forn" value="0" size="10" class="inputtexto" /> 
                        <input type="hidden" name="sigla_und" id="sigla_und" value="0" size="10" class="inputtexto" /> 
                        <input type="hidden" name="idplanocusto_despesa" id="idplanocusto_despesa" value="0" size="10" class="inputtexto" /> 
                        <input type="hidden" name="plcusto_conta_despesa" id="plcusto_conta_despesa" value="0" size="10" class="inputtexto" /> 
                        <input type="hidden" name="plcusto_descricao_despesa" id="plcusto_descricao_despesa" value="0" size="10" class="inputtexto" /> 
                        <!--<input type="hidden" name="vei_placa" id="vei_placa" value="0" size="10" class="inputtexto" /> 
                        <input type="hidden" name="idveiculo" id="idveiculo" value="0" size="10" class="inputtexto" /> -->
                        <input type="hidden" name="agente" id="agente" value="" size="10" class="inputtexto" /> 
                        <input type="hidden" name="idagente" id="idagente" value="0" size="10" class="inputtexto" /> 
                        <input type="hidden" name="plano_agente" id="plano_agente" value="0" size="10" class="inputtexto" /> 
                        <input type="hidden" name="und_agente" id="und_agente" value="0" size="10" class="inputtexto" /> 
                        <input type="hidden" name="indexAux" id="indexAux" value="0" size="10" class="inputtexto" /> 
                        <input type="hidden" name="is_tac" id="is_tac" value="f">
                        <input type="hidden" name="categoria_ndd_id" id="categoria_ndd_id" value="0">
                        <input type="hidden" name="categoria_pamcard_id" id="categoria_pamcard_id" value="0">
                        <input type="hidden" id="bloqueado" value="f"  />
                        <!--Inicio - hidden para serem utilizados no calcular pedágio da NDD-->
                        <input type="hidden" name="cnpjFilial" id="cnpjFilial" value="<c:out value="${usuario.filial.cnpj}"/>"/>
                        <input type="hidden" name="cnpjContratantePamcard" id="cnpjContratantePamcard" value="<c:out value="${usuario.filial.cnpjContratantePamcard}"/>"/>                        
                        <input type="hidden" name="ibgeCidadeOrigem" id="ibgeCidadeOrigem" value=""/>                                             
                        <input type="hidden" name="ibgeCidadeDestino" id="ibgeCidadeDestino" value=""/>                                             
                        <input type="hidden" name="nomeRota" id="nomeRota" value=""/>                                             
                        <input type="hidden" name="idRota" id="idRota" value=""/>                                             
                        <input type="hidden" name="valorDoKM" id="valorDoKM" value="0"/>
                        <input type="hidden" name="stUtilizacaoCfeS" id="stUtilizacaoCfeS" value="${usuario.filial.stUtilizacaoCfeS}"/>
                        <input type="hidden" name="solucao_pedagio" id="solucao_pedagio" value="0" />
                        <input type="hidden" name="controlarTarifasBancariasContratado" id="controlarTarifasBancariasContratado" value="false" />
                        <input type="hidden" name="valorTarifas" id="valorTarifas" value="" />
                        <input type="hidden" name="vlLiquido2" id="vlLiquido2" value="false" />
                        <input type="hidden" name="consultaMotorConf" id="consultaMotorConf" value="${configuracao.vlConMotor}" />
                        <input type="hidden" name="percentualDescontoContrato" id="percentualDescontoContrato" 
                               value="${cadContratoFrete.motorista.percentualDescontoContrato == null ? 0 : cadContratoFrete.motorista.percentualDescontoContrato}" />
                        <input type="hidden" name="mot_outros_descontos_carta" id="mot_outros_descontos_carta" value="0"/>
                        <input type="hidden" name="tipoVlConMotorista" id="tipoVlConMotorista" value="${configuracao.tipoVlConMotor}" />
                        <input type="hidden" name="motivo_bloqueio" id="motivo_bloqueio">    
                        <input type="hidden" name="is_bloqueado" id="is_bloqueado">    
                        <input type="hidden" name="moto_veiculo_bloq_motivo" id="moto_veiculo_bloq_motivo">    
                        <input type="hidden" name="is_moto_veiculo_bloq" id="is_moto_veiculo_bloq">    
                        <input type="hidden" name="moto_carreta_bloq_motivo" id="moto_carreta_bloq_motivo">    
                        <input type="hidden" name="is_moto_carreta_bloq" id="is_moto_carreta_bloq"> 
                        <input type="hidden" name="moto_bitrem_bloq_motivo" id="moto_bitrem_bloq_motivo">    
                        <input type="hidden" name="is_moto_bitrem_bloq" id="is_moto_bitrem_bloq"> 
                        <input type="hidden" name="negociacao_motorista" id="negociacao_motorista"> 
                        <input type="hidden" name="origemNegociacao" id="origemNegociacao" value=""> 
                        <input type="hidden" name="operadoraCiot" id="operadoraCiot" value=""/>
                        <input type="hidden" name="tipoCalculoNegociacao" id="tipoCalculoNegociacao" value=""/>
                        <input type="hidden" name="deduzirImpostosOutrasRetencoesCfe" id="deduzirImpostosOutrasRetencoesCfe" value="${configuracao.deduzirImpostosOutrasRetencoesCfe}">
                        <input type="hidden" name="tipo_veiculo_id" id="tipo_veiculo_id">

                        <input type="hidden" name="idcidadeorigem" id="idcidadeorigem">
                        <input type="hidden" name="cid_origem" id="cid_origem">
                        <input type="hidden" name="uf_origem" id="uf_origem">
                        <!--Fim-->
                    </td>
                    <td style="display: none"><textarea class="inputTexto" cols="80" rows="3" id="obscartafrete" name="obscartafrete"></textarea></td>
                </tr>
            </table>
            <br>
            <form  action="ContratoFreteControlador?acao=${param.acao == 1 ? "cadastrar" : "editar"}"  id="formulario" name="formulario"
                   method="post" target="pop" accept-charset="ISO-8859-1">
                <input type="hidden" name="miliSegundos" id="miliSegundos" value=""/>
                <input type="hidden" name="os_aberto_veiculo" id="os_aberto_veiculo" value="">
                <input type="hidden" name="codigo_ibge_origem" id="codigo_ibge_origem" value="">
                <input type="hidden" name="codigo_ibge_destino" id="codigo_ibge_destino" value="">
                <input type="hidden" name="permitir_lancamento_os_em_aberto" id="permitir_lancamento_os_em_aberto" value="">
                <input type="hidden" name="contaID" id="contaID" value="">
                <input type="hidden" name="plano_proprietario" id="plano_proprietario" value="0" size="10" class="inputtexto" /> 
                <input type="hidden" name="und_proprietario" id="und_proprietario" value="0" size="10" class="inputtexto" /> 
                 <input type="hidden" name="und_proprietario" id="und_proprietario" value="0" size="10" class="inputtexto" /> 


                <table width="80%" border="0" class="bordaFina" align="center">
                    <tr class="tabela">
                        <td align='center'>Dados Principais</td>
                    </tr>
                    <tr>
                        <td>
                            <table width="100%" border="0" class="bordaFina" align="center">
                                <tr>
                                    <td colspan="9">
                                        <table width="100%" border="0" align="center">
                                            <tr>
                                                <td width="15%" class="TextoCampos">
                                                    <b><font size="3">
                                                            Nº Contrato:
                                                        </font></b>
                                                </td>
                                                <td width="15%" class="CelulaZebra2">
                                                    <input type="text" name="idcontratofrete" id="idcontratofrete" value="${cadContratoFrete.id}" size="7" class="inputtexto" style="font-size:14pt;"/>
                                                </td>
                                                <td width="10%" class="TextoCampos">
                                                    <b><font size="3">
                                                            Nº CIOT:
                                                        </font></b>
                                                </td>
                                                <td width="30%" class="CelulaZebra2">
                                                    <input type="text"  size="12" maxlength="15" name="ciot" id="ciot"  onkeypress="mascara(this, soNumeros)"  class="${param.nivel >= 4 ? "inputTexto" : "inputReadOnly"}" style="font-size:14pt;"/>
                                                    <b><font size="3">
                                                            /
                                                        </font></b>
                                                    <input type="text"  size="3" maxlength="6" name="ciotCodVerificador" id="ciotCodVerificador" onkeypress="mascara(this, soNumeros)" class="${param.nivel >= 4 ? "inputTexto" : "inputReadOnly"}" style="font-size:14pt;"/>
                                                </td>
                                                <td class="celulaZebra2"><img src="img/ndd.png" alt="" name="imgOperadoraCiot" id="imgOperadoraCiot"  width="80px" /></td>
                                                <td width="30%" class="CelulaZebra2">
                                                    <input type="radio" onchange="carregarNumeroTacAgregBase()" name="tac_agregado" id="normal" value="false" checked>CIOT Normal
                                                    <div id="divCiotAgregado"><input type="radio" onchange="carregarNumeroTacAgregBase()" name="tac_agregado" id="agregado" value="true">CIOT Agregado (Contrato Base:
                                                        <input type="text" name ="baseTacAgregado" id="baseTacAgregado"  class="inputReadOnly8pt" readonly size="3" value="">
                                                        <input type="hidden" name="basetac" id="basetac" value="">) 
                                                    </div>
                                                </td>
                                            </tr>    
                                            <tr id="contratoRepom"  name="contratoRepom">

                                                <td class="CelulaZebra2" colspan="4"></td>
                                                <td class="CelulaZebra2">Contrato Repom</td>
                                                <td class="CelulaZebra2"> <input type="text" name="contrRepom" id="contrRepom" class="inputReadOnly8pt" size="10" readonly></td>
                                            </tr>    
                                        </table>
                                    </td>
                                </tr>    

                                <tr>
                                    <td width="12%" class="TextoCampos">
                                        <div id="divLbTipo">
                                            Tipo:
                                        </div>
                                    </td>
                                    <td width="16%" class="celulaZebra2">
                                        <div id="divTipo">
                                            <input name="statusCfe"
                                                   onchange="showHide(!this.checked)" id="statusPre"
                                                   type="radio" checked value="0"/>

                                            <label for="statusPre" id="lbstatuspre">PRÉ-CONTRATO</label> 											
                                            <br>
                                            <input name="statusCfe"
                                                   onchange="showHide(this.checked)" id="statusContrato"
                                                   type="radio" value="3"/>

                                            <label for="statusContrato">CONTRATO</label>
                                        </div>

                                    </td>
                                    <td width="12%" class="TextoCampos">
                                        <div align="center">
                                            <input type="checkbox" name="cancelada" id="cancelada"
                                                   class="inputtexto" /><label id="lbCancelado" name="lbCancelado">Cancelado</label>
                                        </div>    
                                    </td>
                                    <td width="12%" class="celulaZebra2"></td>
                                    <td width="12%" class="TextoCampos">Filial:</td>
                                    <td width="12%" class="celulaZebra2">
                                        <select name="filial" id="filial" class="inputtexto" style="width: 90px;" onchange="javascript: alterarOperadoraCiot();validarNegociacao();
                                                getTarifasFilial();reterImposto();"> 
                                            <c:forEach var="filial" varStatus="status" items="${listaFilial}">
                                                <option value="${filial.idfilial}" lang="${filial.stUtilizacaoCfeS}">${filial.abreviatura}</option>
                                            </c:forEach>
                                        </select> <c:forEach var="filial" varStatus="status"
                                                   items="${listaFilial}">
                                            <input type="hidden" id="stFilialCfe" name="stFilialCfe">
                                            <input type="hidden" id="filialCfe_${filial.idfilial}"
                                                   name="filialCfe_${filial.idfilial}"
                                                   value="${filial.stUtilizacaoCfeS}">
                                            <input type="hidden" id="agente_repom_id_${filial.idfilial}"
                                                   name="agente_repom_id_${filial.idfilial}"
                                                   value="${filial.agentePagadorRepom.idfornecedor}">
                                            <input type="hidden" id="agente_repom_${filial.idfilial}"
                                                   name="agente_repom_${filial.idfilial}"
                                                   value="${filial.agentePagadorRepom.razaosocial}">
                                            <input type="hidden" id="emissao_gratuita_${filial.idfilial}"
                                                   name="emissao_gratuita_${filial.idfilial}"
                                                   value="${filial.emissaoGratuita}">
                                            <input type="hidden" id="negociacao_contrato_frete_${filial.idfilial}"
                                                   name="negociacao_contrato_frete_${filial.idfilial}"
                                                   value="${filial.negociadaoAdiantamentoId}">
                                            <input type="hidden" id="is_retencao_imposto_operadora_cfe_${filial.idfilial}"
                                                   name="is_retencao_imposto_operadora_cfe_${filial.idfilial}"
                                                   value="${filial.retencaoImpostoOperadoraCFe}">
                                            <input type="hidden" id="is_calcular_pedagio_cfe_${filial.idfilial}"
                                                   name="is_calcular_pedagio_cfe_${filial.idfilial}"
                                                   value="${filial.calcularPedagioCfe}">
                                        </c:forEach></td>
                                    <td width="12%" class="TextoCampos">Data:</td>
                                    <td width="12%" class="celulaZebra2"><input type="text"
                                                                                onBlur="alertInvalidDate(this)" size="10" maxlength="10"
                                                                                name="data" id="data" class="fieldDate" class="inputtexto" />
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">Rota:</td>
                                    <td id="tdRota" class="celulaZebra2">
                                        <select name="rota" id="rota" class="fieldMin" onchange="getRotaPercurso(true);
                                                if (this.value != '0') {
                                                    getTabelaPreco();
                                                }" onkeypress="verSeTemRota();" onclick="verSeTemRota();">
                                            <option value="0">Rota não informada</option>
                                            <c:forEach var="rota" varStatus="status" items="${listaRota}">
                                                <option value=${rota.id}>${rota.descricao}</option>
                                            </c:forEach>                                            
                                        </select>                                                                                       
                                        <img src="img/atualiza.png" alt="" name="carregaRota" title="Clique aqui para atualizar as rotas de acordo com as cidades de destino dos documentos informados." class="imagemLink" id="carregaRota" onclick="getRota()" />
                                    </td>
                                    <td class="TextoCampos"><label id="lblPercuso">Percurso:</label></td>
                                    <td class="celulaZebra2"><select name="percurso" id="percurso" class="fieldMin" >
                                            <option value="0">----------</option>
                                        </select>
                                    </td>

                                    <td class="TextoCampos"><div align="right">Data Partida:</div></td>
                                    <td class="CelulaZebra2"><input type="text"
                                                                    onBlur="alertInvalidDate(this, true)" size="10" maxlength="10"
                                                                    name="dataPartida" id="dataPartida" onchange="getRotaPercurso(true)" class="fieldDate"
                                                                    class="inputtexto" /></td>
                                    <td class="TextoCampos"><div align="right">Data T&eacute;rmino:</div></td>
                                    <td class="CelulaZebra2"><input type="text"
                                                                    onBlur="alertInvalidDate(this, true)" size="10" maxlength="10"
                                                                    name="dataTermino" id="dataTermino" class="fieldDate"
                                                                    class="inputtexto" /></td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">Origem:</td>
                                    <td class="TextoCampos" colspan="3" style="text-align: left !important">
                                        <label>CEP: </label>
                                        <input name="cep-origem" type="text" id="cep-origem" size="10" maxlength="9" onBlur="getEnderecoByCep(this.value, 'cidadeOrigem')" class="fieldMin">
                                        <label style='display: ${param.utilizacaoCfe != 'R' ? "text" : "none"}'>Cidade: </label>
                                        <input type="hidden" name="id-cidade-origem" id="id-cidade-origem">
                                        <input type='${param.utilizacaoCfe != 'R' ? "text" : "hidden"}' name="cidade-origem" id="cidade-origem" class="inputReadOnly8pt" readonly>
                                        <input type='${param.utilizacaoCfe != 'R' ? "text" : "hidden"}' name="uf-origem" id="uf-origem" class="inputReadOnly8pt" size="3" readonly>
                                        <input type='${param.utilizacaoCfe != 'R' ? "button" : "hidden"}' class="inputBotaoMin" value="..." onclick="launchPopupLocate('./localiza?acao=consultar&idlista=11','Cidade_Origem')">
                                        <img src="img/borracha.gif" alt="" name="borrachaCidadeOrigem" class="imagemLink" id="borrachaCidadeOrigem" onclick="limparCidadeOrigem()" style="width: 17px;">
                                        <img src="${homePath}/img/ajuda.png" class="imagemLink" style="width: 15px;" title="OBS: Se não preencher o CEP será enviado para ANTT o CEP da Filial do contrato de frete; Se não preencher a cidade de origem, será enviado para ANTT a cidade de origem definida na rota informada no contrato de frete." onclick="javascript:getAjudaCidadeOrigem();"/>
                                    </td>
                                    <td class="TextoCampos">Destino:</td>
                                    <td class="TextoCampos" colspan="3" style="text-align: left !important">
                                        <label>CEP: </label>
                                        <input name="cep-destino" type="text" id="cep-destino" size="10" maxlength="9" onBlur="getEnderecoByCep(this.value, 'cidadeDestino')" class="fieldMin">
                                        <label style='display: ${param.utilizacaoCfe != 'R' ? "text" : "none"}'>Cidade: </label>
                                        <input type="hidden" name="id-cidade-destino" id="id-cidade-destino">
                                        <input type='${param.utilizacaoCfe != 'R' ? "text" : "hidden"}' name="cidade-destino" id="cidade-destino" class="inputReadOnly8pt" readonly>
                                        <input type='${param.utilizacaoCfe != 'R' ? "text" : "hidden"}' name="uf-destino" id="uf-destino" class="inputReadOnly8pt" size="3" readonly>
                                        <input type='${param.utilizacaoCfe != 'R' ? "button" : "hidden"}' class="inputBotaoMin" value="..." onclick="launchPopupLocate('./localiza?acao=consultar&idlista=11','Cidade_Destino')">
                                        <img src="img/borracha.gif" alt="" name="borrachaCidadeDestino" class="imagemLink" id="borrachaCidadeDestino" onclick="limparCidadeDestino()" style="width: 17px;">
                                        <img src="${homePath}/img/ajuda.png" class="imagemLink" style="width: 15px;" title="OBS: Se não preencher o CEP será enviado para ANTT o CEP do destinatário da carga; Se não preencher a cidade de destino, será enviado para ANTT a cidade de destino definida na rota informada no contrato de frete." onclick="javascript:getAjudaCidadeDestino();"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">
                                        <label>Distância: </label>
                                    </td>
                                    <td class="celulaZebra2" colspan="7">
                                        <input name="distancia-contrato-frete" id="distancia-contrato-frete" type="int" size="8" maxlength="8" class="inputTexto">
                                        <label>KM</label>
                                        <img src="${homePath}/img/ajuda.png" class="imagemLink" style="width: 15px;" title="OBS: Se não preencher a distância, será enviado para ANTT a distância cadastrada na rota informada no contrato de frete." onclick="javascript:getAjudaDistancia();"/>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
                <br>
                <div id="container" style="width: 80%" align="center">
                    <div align="center">
                        <ul id="tabs">
                            <li><a href="#tab1"><strong>Dados do Contratado</strong></a>
                            </li>
                            <li><a href="#tab2"><strong>Documentos</strong></a></li>
                            <li><a href="#tab3" id="abaPagamento"><strong>Valores/Pagamentos</strong></a>
                            </li>
                            <li><a href="#tab4"><strong>Despesas Agregadas</strong></a></li>
                            <li style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none" }'><a href="#tab5"><strong>Auditoria</strong></a></li>
                        </ul>
                    </div>
                    <div class="panel" id="tab1">
                        <fieldset>
                            <table width="100%" border="0" class="bordaFina" align="center">
                                <tr>
                                    <td width="10%" class="celula">MOTORISTA</td>
                                    <td width="5%" class="TextoCampos">*Nome:</td>
                                    <td width="20%" class="celulaZebra2"><input
                                            name="motor_nome" id="motor_nome" type="text"
                                            class="inputReadOnly8pt" size="28" readonly /> <input
                                            type="button" class="inputBotaoMin" name="botaoMotorista"
                                            id="botaoMotorista" onclick="abrirLocalizaMotorista()"
                                            value="..." /> <input type="hidden" name="idmotorista"
                                            id="idmotorista" value="0" /> <input type="hidden"
                                            name="motor_conta1" id="motor_conta1" value=""> <input 
                                            type="hidden"name="motor_tipo_conta1" id="motor_tipo_conta1" value=""> <input
                                            type="hidden" name="motor_agencia1" id="motor_agencia1"
                                            value=""> <input type="hidden" name="motor_favorecido1"
                                            id="motor_favorecido1" value=""> <input type="hidden"
                                            name="motor_banco1" id="motor_banco1" value=""> <input
                                            type="hidden" name="motor_conta2" id="motor_conta2" value="">
                                        <input type="hidden" name="motor_tipo_conta2" id="motor_tipo_conta2" value="">
                                        <input type="hidden" name="motor_agencia2" id="motor_agencia2"
                                               value=""> <input type="hidden" name="motor_banco2"
                                               id="motor_banco2" value=""> <input type="hidden"
                                               name="motor_favorecido2" id="motor_favorecido2" value="">
                                        <input type="hidden" name="base_ir_prop_retido"
                                               id="base_ir_prop_retido" class="inputReadOnly8pt" size="20"
                                               readonly="true" value="0"> <input type="hidden"
                                               name="ir_prop_retido" id="ir_prop_retido"
                                               class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                        <input type="hidden" name="base_inss_prop_retido"
                                               id="base_inss_prop_retido" class="inputReadOnly8pt" size="20"
                                               readonly="true" value="0"> <input type="hidden"
                                               name="inss_prop_retido" id="inss_prop_retido" value="0"
                                               size="10" class="inputtexto" />
                                        <input type="hidden" id="motivobloqueio" name="motivobloqueio" value=""  /> 
                                        <input type="hidden" id="percentual_valor_cte_calculo_cfe" name="percentual_valor_cte_calculo_cfe">
                                        <input type="hidden" id="tipo_calculo_percentual_valor_cfe" name="tipo_calculo_percentual_valor_cfe">
                                        <input type="hidden" id="calculo_valor_contrato_frete" name="calculo_valor_contrato_frete">
                                    </td>
                                    <td width="8%" class="TextoCampos">CPF:</td>
                                    <td width="18%" class="celulaZebra2"><input
                                            name="motor_cpf" id="motor_cpf" type="text"
                                            class="inputReadOnly8pt" size="15" readonly /></td>
                                    <td width="9%" class="TextoCampos">Habilitação:</td>
                                    <td width="13%" class="celulaZebra2"><input
                                            name="motor_cnh" id="motor_cnh" type="text"
                                            class="inputReadOnly8pt" size="15" readonly /></td>
                                    <td width="7%" class="TextoCampos"></td>
                                    <td width="9%" class="celulaZebra2"></td>
                                </tr>
                                <tr>
                                    <td class="celula">VEÍCULO</td>
                                    <td class="TextoCampos">*Placa:</td>
                                    <td class="celulaZebra2"><input type="text"
                                                                    class="inputReadOnly8pt" name="vei_placa" id="vei_placa"
                                                                    size="9" maxlength="9" readonly > <input type="hidden"
                                                                    name="idveiculo" id="idveiculo" value="0" /> <input
                                                                    type="button" class="inputBotaoMin" name="botaoVeiculo"
                                                                    id="botaoVeiculo" onclick="abrirLocalizaVeiculo()" value="..." />
                                        <input type="hidden" id="rntrc_veiculo" name="rntrc_veiculo" value="">
                                    </td>
                                    <td class="TextoCampos">Contratado:</td>
                                    <td class="celulaZebra2"><input type="text"
                                                                    class="inputReadOnly8pt" name="vei_prop" id="vei_prop"
                                                                    size="30" maxlength="40"  > <input type="hidden"
                                                                    name="idproprietarioveiculo" id="idproprietarioveiculo"
                                                                    maxlength="40" readonly > <input type="hidden"
                                                                    name="prop_conta1" id="prop_conta1" value=""> <input
                                                                    type="hidden" name="prop_agencia1" id="prop_agencia1" value="">
                                                                    <input type="hidden" name="prop_tipo_conta1" id="prop_tipo_conta1" value="">
                                        <input name="debito_prop" type="hidden" id="debito_prop" size="10" value="0">
                                        <input name="percentual_desconto_prop" type="hidden" id="percentual_desconto_prop" size="10" value="0">
                                        <input name="tipo_desconto_prop" type="hidden" id="tipo_desconto_prop" value="1">
                                        <input type="hidden" name="prop_favorecido1"
                                               id="prop_favorecido1" value=""> <input type="hidden"
                                               name="prop_banco1" id="prop_banco1" value=""> <input
                                               type="hidden" name="prop_conta2" id="prop_conta2" value="">
                                        <input type="hidden" name="prop_tipo_conta2" id="prop_tipo_conta2" value="">
                                        <input type="hidden" name="prop_agencia2" id="prop_agencia2"
                                               value=""> <input type="hidden" name="prop_favorecido2"
                                               id="prop_favorecido2" value=""> <input type="hidden"
                                               name="prop_banco2" id="prop_banco2" value=""></td>
                                    <td class="TextoCampos">CNPJ/CPF:</td>
                                    <td class="celulaZebra2"><input type="text"
                                                                    class="inputReadOnly8pt" name="vei_prop_cgc" id="vei_prop_cgc"
                                                                    size="20" maxlength="15" readonly></td>
                                    <td class="TextoCampos">Cap. Carga:</td>
                                    <td class="celulaZebra2"><input type="text"
                                                                    class="inputReadOnly8pt" name="vei_cap_carga" id="vei_cap_carga"
                                                                    size="8" maxlength="15" readonly>Kg(s)</td>
                                </tr>
                                <tr>
                                    <td class="celula">CARRETA</td>
                                    <td class="TextoCampos">Placa:</td>
                                    <td class="celulaZebra2"><input type="text"
                                                                    class="inputReadOnly8pt" name="car_placa" id="car_placa"
                                                                    size="9" maxlength="8" readonly> <input type="hidden"
                                                                    name="idcarreta" id="idcarreta" value="0" /> <input
                                                                    type="button" class="inputBotaoMin" id="botaoCarreta"
                                                                    onclick="abrirLocalizaCarreta()" value="..." /> <img
                                                                    src="img/borracha.gif" alt="" name="borrachaCarreta"
                                                                    class="imagemLink" id="borrachaCarreta"
                                                                    onclick="limparCarreta()" />
                                        <input type="hidden" id="rntrc_carreta" name="rntrc_carreta" value="">
                                    </td>
                                    <td class="TextoCampos">Proprietário:</td>
                                    <td class="celulaZebra2"><input type="text"
                                                                    class="inputReadOnly8pt" name="car_prop" id="car_prop"
                                                                    size="30" maxlength="40" readonly></td>
                                    <td class="TextoCampos">CNPJ/CPF:</td>
                                    <td class="celulaZebra2"><input type="text"
                                                                    class="inputReadOnly8pt" name="car_prop_cgc" id="car_prop_cgc"
                                                                    size="20" maxlength="15" readonly></td>
                                    <td class="TextoCampos">Cap. Carga:</td>
                                    <td class="celulaZebra2"><input type="text"
                                                                    class="inputReadOnly8pt" name="car_cap_carga" id="car_cap_carga"
                                                                    size="8" maxlength="15" readonly>Kg(s)</td>
                                </tr>
                                <tr>
                                    <td class="celula">BI-TREM</td>
                                    <td class="TextoCampos">Placa:</td>
                                    <td class="celulaZebra2"><input type="text"
                                                                    class="inputReadOnly8pt" name="bi_placa" id="bi_placa" size="9"
                                                                    maxlength="8" readonly> <input type="hidden"
                                                                    name="idbitrem" id="idbitrem" value="0" /> <input
                                                                    type="button" class="inputBotaoMin" id="botaoCarreta"
                                                                    onclick="abrirLocalizaBiTrem()" value="..." /> <img
                                                                    src="img/borracha.gif" alt="" name="borrachaCarreta"
                                                                    class="imagemLink" id="borrachaCarreta"
                                                                    onclick="limparBiTrem()" />
                                        <input type="hidden" id="rntrc_bitrem" name="rntrc_bitrem" value="">
                                    </td>
                                    <td class="TextoCampos">Proprietário:</td>
                                    <td class="celulaZebra2"><input type="text"
                                                                    class="inputReadOnly8pt" name="bi_prop" id="bi_prop" size="30"
                                                                    maxlength="40" readonly></td>
                                    <td class="TextoCampos">CNPJ/CPF:</td>
                                    <td class="celulaZebra2"><input type="text"
                                                                    class="inputReadOnly8pt" name="bi_prop_cgc" id="bi_prop_cgc"
                                                                    size="20" maxlength="15" readonly></td>
                                    <td class="TextoCampos">Cap. Carga:</td>
                                    <td class="celulaZebra2"><input type="text"
                                                                    class="inputReadOnly8pt" name="bi_cap_carga" id="bi_cap_carga"
                                                                    size="8" maxlength="15" readonly>Kg(s)</td>
                                </tr>
                                <tr>
                                    <td colspan='9'>
                                        <table width="100%" border="0" align="center">
                                            <tr>
                                                <td  class='TextoCampos'>Qtd de eixos suspensos: </td>
                                                <td  class='CelulaZebra2'><input type="text"
                                                                                 class="inputTexto" name="eixosSuspensos" id="eixosSuspensos"
                                                                                 size="3" onkeypress="mascara(this, soNumeros)" maxlength="1"
                                                                                 value="0"></td>
                                                <td style="display: none" id="tdLabelCategoriaPamcard"  class='TextoCampos'><div align="right">Categoria
                                                        Pamcard:</div></td>
                                                <td style="display: none" id="tdCategoriaPamcard" class='CelulaZebra2'>
                                                    <select class="inputtexto" id="categoriaPamcard" name="categoriaPamcard" style="width: 150px;">
                                                        <option value="0">Não informado</option>
                                                        <c:forEach var="categoria" varStatus="status"
                                                                   items="${listaCategoriaPamcard}">
                                                            <option value="${categoria.id}">${categoria.descricao}</option>
                                                        </c:forEach>
                                                    </select>
                                                </td>
                                                <td style="display: none" id="tdLabelCategoriaNdd"  class='TextoCampos'>
                                                    <div align="right">
                                                        <c:if test="${usuario.filial.stUtilizacaoCfeS == 'D'}">
                                                            Categoria NDD:
                                                        </c:if>
                                                        <c:if test="${usuario.filial.stUtilizacaoCfeS == 'A'}">
                                                            Categoria Target:
                                                        </c:if>
                                                    </div>
                                                </td>
                                                <td style="display: none" id="tdCategoriaNdd" class='CelulaZebra2'>
                                                    <select class="inputtexto" id="categoriaNdd"
                                                            name="categoriaNdd" style="width: 150px;">
                                                        <option value="0">Não informado</option>
                                                        <c:forEach var="categoria" varStatus="status"
                                                                   items="${listaCategoriaNdd}">
                                                            <option value="${categoria.id}">${categoria.descricao}</option>
                                                        </c:forEach>
                                                    </select>
                                                    <c:forEach var="categoria" varStatus="status" items="${listaCategoriaNdd}">
                                                        <input type="hidden" id="codigoCategoriaNdd_${categoria.id}" name="codigoCategoriaNdd_${categoria.id}" value="${categoria.cod}">
                                                    </c:forEach>
                                                </td>
                                                <td width="25%" class="TextoCampos">
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </div>
                    <div class="panel" id="tab2">
                        <fieldset>
                            <table width="100%" border="0" class="tabelaZerada" align="center">
                                <tr>
                                    <td colspan='11' class='CelulaZebra2'><input type="button"
                                                                                 value="Selecionar Documentos" class="botoes"
                                                                                 id="botSelectDocum"
                                                                                 onclick="selecionar_manifesto(0, 'cadastrar')" /> <input
                                                                                 name="mostrarTudo" id="mostrarTudo" onclick="" type="checkbox" />
                                        <label>Mostrar documentos vinculados a veículos da frota própria</label></td>
                                </tr>					

                                <tr class="celula">
                                    <td width="2%"></td>
                                    <td width="5%">
                                    
                                        <div align="center">
                                            Tipo Doc <input type="hidden" id="maxDocumento"
                                                            name="maxDocumento" value="0" />
                                        </div>
                                    </td>
                                    <td width="7%">
                                        <div align="center">
                                            Número <input type="hidden" id="maxDocumento"
                                                          name="maxDocumento" value="0" />
                                        </div>
                                    </td>
                                    <td width="23%">
                                        <div align="center">Cidade/UF Origem</div>
                                    </td>
                                    <td width="23%">
                                        <div align="center">Cidade/UF Destino</div>
                                    </td>
                                    <td width="5%">
                                        <div align="center">Data</div>
                                    </td>
                                    <td width="7%">
                                        <div align="center">Entregas</div>
                                    </td>
                                    <td width="7%">
                                        <div align="center">Peso(Kg)</div>
                                    </td>
                                    <td width="7%">
                                        <div align="center">Vol(s)</div>
                                    </td>
                                    <td width="7%">
                                        <div align="center">R$ Merc.</div>
                                    </td>
                                    <td width="7%">
                                        <div align="center">R$ Frete</div>
                                    </td>
                                </tr>
                                <tbody id="bodyDocum">
                                </tbody>
                                <tr class="celula">
                                    <td align="right" colspan="6">Totais:</td>
                                    <td align="right"><b><label id="labTotalEntregas">0</label></b>
                                        <input type="hidden" id="inTotalEntregas" value="0,00">
                                        <input type="hidden" id="totalValorFreteCte" value="0,00">
                                        <input type="hidden" id="totalValorPesoCte" value="0,00">
                                    </td>
                                    <td align="right"><b><label id="labTotalPeso">0,00</label></b>
                                    </td>
                                    <td align="right"><b><label id="labTotalVol">0,00</label></b>
                                    </td>
                                    <td align="right">
                                        <b>
                                            <label id="labTotalMerc">0,00</label>
                                            <input type="hidden" id="inTotalValorNota" value="0,00">
                                        </b>
                                    </td>
                                    <td align="right">
                                        <b>
                                            <label id="labTotalValorFrete">0,00</label>
                                            <input type="hidden" id="inTotalValorFrete" value="0,00">
                                            <input type="hidden" id="totalValorFreteCte" value="0,00">
                                            <input type="hidden" id="totalValorPesoCte" value="0,00">
                                        </b>
                                </tr>
                                <tr>
                                    <td class="TextoCampos" colspan="3">Natureza da Carga: </td>
                                    <td class="CelulaZebra2">
                                        <input type="text"class="inputReadOnly8pt" name="natureza_cod_desc" id="natureza_cod_desc" size="4" readonly> 
                                        <input type="text"class="inputReadOnly8pt" name="natureza_desc" id="natureza_desc" size="23" readonly> 
                                        <input type="hidden" name="natureza_cod" id="natureza_cod" value="0" /> 
                                        <input type="button" class="inputBotaoMin" id="botaoCarreta" onclick="abrirLocalizaNatureza()" value="..." /> 
                                        <!--<img src="img/borracha.gif" alt="" name="borrachaNatureza" class="imagemLink" id="borrachanatureza" onclick="limparBiTrem()" /></td>-->
                                    </td>                                                             
                                    <td class="TextoCampos">Tipo de Produto/Operação:</td>
                                    <td class="CelulaZebra2" colspan="3">
                                        <select name="tipoProduto" id="tipoProduto" class="inputtexto" style="width: 200px;" onchange="getTabelaPreco();">
                                            <option value="0" selected>Não informado</option>
                                            <c:forEach var="tpProd" varStatus="status" items="${listaTipoProduto}">
                                                <option value="${tpProd.id}" >${tpProd.descricao}</option>
                                            </c:forEach>
                                        </select>
                                    </td>
                                    <td class="TextoCampos" colspan="2">Tipo Embalagem:</td>
                                    <td class="CelulaZebra2" colspan="1">
                                        <select name="tipoEmbalagem" id="tipoEmbalagem" class="inputtexto" style="width: 200px;">
                                            <option value="0" selected>Não informado</option>
                                            <c:forEach var="tpEmbalagem" varStatus="status" items="${listaTipoEmbalagem}">
                                                <option value="${tpEmbalagem.id}" >${tpEmbalagem.descricao}</option>
                                            </c:forEach>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos"  class="CelulaZebra2" colspan="3">
                                        <label>Tipo de Carga: </label>
                                    </td>
                                    <td class="celulaZebra2" colspan="8">
                                        <select class="fieldMin" id="tipo-carga" name="tipo-carga">
                                            <option value="">Não informado</option>
                                            <option value="01">Carga Geral</option>
                                            <option value="02">Carga Granel</option>
                                            <option value="03">Carga Frigorìfica</option>
                                            <option value="04">Carga Perigosa</option>
                                            <option value="05">Carga Neogranel</option>
                                        </select>
                                    </td>
                                </tr>
                                
                            </table>
                        </fieldset>
                    </div>
                    <div class="panel" id="tab3">
                        <fieldset>
                            <table width="100%" border="0" class="bordaFina" align="center">
                                <tr>
                                    <td class='TextoCampos'><b>R$/Tonelada:</b></td>
                                    <td class='CelulaZebra2'><input
                                            name="vlTonelada" onclick="this.select();" onblur="calculaValorTonelada();
                                                    bloquearCamposValorTonelada();"
                                            onkeypress="mascara(this, reais)" id="vlTonelada"
                                            type="text" class="inputtexto changeHandler" size="5" maxlength="12"
                                            value="0,00" />&nbsp;&nbsp;<label><b>*</b></label>
                                        <label id="labTotalPesoTon" name="labTotalPesoTon">0,00&nbsp;TON</label>
                                        <input name="pesoTonelada" id="pesoTonelada" type="hidden" class="inputtexto"  value="0"/>
                                    </td>
                                    <td class='CelulaZebra2' colspan="3">
                                        <div id="divSolicitarAutorizacao" name="divSolicitarAutorizacao" style="display:none;">
                                            <input type="checkbox" class="inputTexto" name="solicitarAutorizacao" id="solicitarAutorizacao" onclick="javascript:solicitaAutorizacao(false);
                                                    if (!this.checked) {
                                                        getTabelaPreco()
                                                    }"/>
                                            <label for="solicitarAutorizacao">Solicitar Autorização para Frete maior que a tabela</label>
                                        </div>
                                        <div id="divAutorizar" name="divAutorizar" style="display:none;">
                                            <input type="checkbox" class="inputTexto" name="autorizarSolicitacao" id="autorizarSolicitacao" onclick=""/>
                                            Autorizar Valor do frete maior que a tabela de preço
                                        </div>
                                        <div id="divAutorizado" name="divAutorizado" style="display:none;">
                                            Autorizado por:<label id="lbAutorizadoPor"></label><br>
                                            Data Autorização:<label id="lbAutorizadoEm"></label>&nbsp;às&nbsp;<label id="lbAutorizadoAs"></label>
                                        </div>
                                    </td>
                                    <td class='TextoCampos'>
                                        <label id="lbMotivoAutorizacao" name="lbMotivoAutorizacao" style="display:none;">Motivo:</label>
                                    </td>
                                    <td class='CelulaZebra2' colspan="4">
                                        <textarea class="inputTexto" cols="37" rows="3" id="motivoSolicitacao" name="motivoSolicitacao" style="display:none;"><c:out value="${cadContratoFrete.motivoAutorizacao}"/></textarea>
                                    </td>
                                </tr>
                                <tr>
                                    <td class='TextoCampos'><b>R$/KM:</b></td>
                                    <td class='CelulaZebra2'>
                                        <input name="valorPorKM" onclick="this.select();" onblur="calculaValorKM();
                                                calculaImpostos();
                                                liberarCamposValorPorKM();"                                               
                                               onkeypress="mascara(this, reais);" id="valorPorKM" type="text" class="inputReadOnly changeHandler" size="5" maxlength="12" value="0,00" />&nbsp;&nbsp;
                                        <label><b>*</b></label>
                                        <input name="quantidadeKm" id="quantidadeKm" type="text" class="inputtexto changeHandler" 
                                               onblur="calculaValorKM();
                                                       calculaImpostos();
                                                       liberarCamposQuantidade();" 
                                               onkeypress="mascara(this, soNumeros)" size="8" value="0" maxlength="12"/>
                                        <label id="labTotalKM" name="labTotalKM">&nbsp;KM</label>
                                    </td>
                                    <td class='CelulaZebra2' colspan="10"></td>
                                </tr>                                   
                                <tr>
                                    <td class='TextoCampos'><b>Valor Contrato:</b></td>
                                    <td class='CelulaZebra2'><input
                                            name="vlFreteMotorista" onblur="calculaImpostos();
                                                    bloquearCamposValorContrato();"
                                            onkeypress="mascara(this, reais);" id="vlFreteMotorista"
                                            type="text" class="inputtexto changeHandler" size="9" maxlength="12"
                                            value="0,00" />&nbsp;&nbsp;<label><b>(+)</b></label>&nbsp;&nbsp;
                                        <img src="img/calculadora.png" alt="" name="carregaTabela" title="Clique aqui para calcular o frete pela tabela de preço da rota escolhida." class="imagemLink" id="carregaTabela" onclick="getTabelaPreco()" />
                                    </td>
                                    <td class='CelulaZebra2' colspan="8">
                                        <div id="detalhesTabRota" name="detalhesTabRota" style="display:none;">
                                            <label id="tabTipoVeiculo"></label>&nbsp;&nbsp;
                                            <label id="tabTipoProduto"></label>&nbsp;&nbsp;
                                            <label id="tabTipoCliente"></label>&nbsp;&nbsp;
                                            <label id="tabTipoCalculo"></label>&nbsp;&nbsp;
                                            <label id="tabValorCalculo"></label>
                                            <label name="acrescentardo_taxa" id="acrescentardo_taxa" style="display:none;"> Acrescentado taxa fixa</label>
                                        </div>
                                        <input name="tab_tipo_valor" id="tab_tipo_valor" type="hidden" value="" />
                                        <input name="tab_valor" id="tab_valor" type="hidden" value="0" />
                                        <input name="tab_valor_maximo" id="tab_valor_maximo" type="hidden" value="0" />
                                        <input name="tab_taxa_fixa" id="tab_taxa_fixa" type="hidden" value="0" />

                                        <input name="tab_valor_entrega" id="tab_valor_entrega" type="hidden" value="0" />
                                        <input name="tab_qtd_entrega" id="tab_qtd_entrega" type="hidden" value="0" />
                                        <input name="tab_valor_excedente" id="tab_valor_excedente" type="hidden" value="0" />
                                        <input name="tab_id" id="tab_id" type="hidden" value="0" />
                                        <input name="considerarCampoCte" id="considerarCampoCte" type="hidden" value="" />
                                        <input name="tabela_is_deduzir_pedagio" id="tabela_is_deduzir_pedagio" type="hidden" value="false">
                                        <input name="tabela_is_carregar_pedagio_ctes" id="tabela_is_carregar_pedagio_ctes" type="hidden" value="false">
                                        <input name="motorista_valor_minimo" type="hidden" id="motorista_valor_minimo" value="0.00">
                                        <input name="rota_valor_minimo" type="hidden" id="rota_valor_minimo" value="0.00">
                                        <input name="rota_is_nfe_por_entrega" type="hidden" id="rota_is_nfe_por_entrega" value="0.00">
                                    </td>
                                </tr>
                                <tr style="display: ${configuracao.diariaRetemImposto ? "" :"none"}">
                                    <td class="textoCampos">Diária:</td>
                                    <td class="celulaZebra2">
                                        <input name="qtdDiaria" onchange="seNaoIntReset(this, '0');
                                                calculaDiaria();
                                                calculaImpostos();
                                                calcula();" id="qtdDiaria" type="text" class="inputtexto" size="1" maxlength="10" value="0" />(*)
                                        <input name="vlUnitarioDiaria" onblur="calculaDiaria();
                                                calculaImpostos();
                                                calcula();" onkeypress="mascara(this, reais)" id="vlUnitarioDiaria" type="text" class="inputtexto" size="6" maxlength="10" value="0,00" />(=)
                                        <input name="vlDiaria" onblur="calculaImpostos();
                                                calcula();" onkeypress="mascara(this, reais)" id="vlDiaria" type="text" class="inputReadOnly" size="6" maxlength="10" value="0,00" readonly/>(+)
                                    </td>
                                    <td class="celulaZebra2" colspan="3">
                                        <input type="checkbox" class="inputTexto" name="diariaParada" id="diariaParada" onclick="getDiariaParada()" /> Diária Parado (Sem carregamento)
                                    </td>
                                    <td class="TextoCampos">
                                        <label id="lbCliente" name="lbCliente">Cidade:</label><br>
                                        <label id="lbCidadeDest" name="lbCidadeDest">Cliente:</label>
                                    </td>
                                    <td class="celulaZebra2" colspan="4">
                                        <input type="text" class="inputReadOnly8pt" name="cid_destino" id="cid_destino" size="28" readonly> 
                                        <input type="text" class="inputReadOnly8pt" name="uf_destino" id="uf_destino" size="3" readonly> 
                                        <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="0"/> 
                                        <input type="button" class="inputBotaoMin" id="botaoCidade" onclick="abrirLocalizaCidade()" value="..." /> 
                                        <img src="img/borracha.gif" alt="" name="borrachaCidade" class="imagemLink" id="borrachaCidade" onclick="$('idcidadedestino').value = '0';
                                                $('cid_destino').value = '';
                                                $('uf_destino').value = '';" />
                                        <input type="text"class="inputReadOnly8pt" name="con_rzs" id="con_rzs" size="35" readonly> 
                                        <input type="hidden" name="idconsignatario" id="idconsignatario" value="0" /> 
                                        <input type="hidden" name="con_valor_diaria_parado" id="con_valor_diaria_parado" value="0" /> 
                                        <input type="button" class="inputBotaoMin" id="botaoCliente" onclick="abrirLocalizaCliente()" value="..." /> 
                                        <img src="img/borracha.gif" alt="" name="borrachaCliente" class="imagemLink" id="borrachaCliente" onclick="$('idconsignatario').value = '0';
                                                $('con_rzs').value = '';" />
                                    </td>
                                </tr>
                                <c:if test="${configuracao.outrosRetemImposto}">
                                    <tr>
                                        <td class="textoCampos">Outros:</td>
                                        <td class="celulaZebra2"><input name="vlOutros" onblur="calculaImpostos();
                                                calcula();"
                                                                        onkeypress="mascara(this, reais)" id="vlOutros" type="text"
                                                                        class="inputtexto" size="9" maxlength="10" value="0,00" />&nbsp;&nbsp;(+)
                                        </td>
                                        <td class="celulaZebra2" colspan="8">Descrição Outros: <input
                                                name="obsOutros" id="obsOutros" type="text" class="fieldMin"
                                                maxlength="60" size="60" value="" />
                                        </td>
                                    </tr>
                                </c:if>
                                <c:if test="${configuracao.descargaRetemImposto}">
                                    <tr>
                                        <td class="textoCampos">Descarga:</td>
                                        <td class="celulaZebra2"><input name="vlDescarga" onblur="calculaImpostos();
                                                calcula();"
                                                                        onkeypress="mascara(this, reais)" id="vlDescarga" type="text"
                                                                        class="inputtexto" size="9" maxlength="10" value="0,00" />&nbsp;&nbsp;(+)</td>
                                        <td class="celulaZebra2" colspan="8"></td>
                                    </tr>
                                </c:if>
                                <tr id="trBaseImpostos">
                                    <td class='TextoCampos'><b>Base Retenção:</b></td>
                                    <td class='CelulaZebra2'><b><label id="lbBaseImpostos"></label></b></td>
                                    <td class='CelulaZebra2' colspan="8">
                                        <input name="chkReterImpostos" id="chkReterImpostos" onclick="reterImposto()" type="checkbox" /> 
                                        <label id="lbReter">Reter Impostos (IRRF,INSS e SEST/SENAT)</label>
                                    </td>
                                </tr>
                                <tr id="trIR">
                                    <td class="textoCampos style1">Valor IRRF:</td>
                                    <td class="celulaZebra2 style1"><input name="vlIr"
                                                                           onkeypress="mascara(this, reais)" id="vlIr"
                                                                           onblur="calcula(true, true);" type="text" class="inputtexto"
                                                                           size="9" maxlength="12" value="0,00" />&nbsp;&nbsp;<label>(-)</label>
                                    </td>
                                    <td class="textoCampos style1"><label style="display:none;" id="lbQtdDependentes" name="lbQtdDependentes">Dependentes:</label></td>
                                    <td class="celulaZebra2 style1"><input
                                            name="qtddependentes" onkeypress="mascara(this, soNumeros)"
                                            id="qtddependentes" type="text" class="inputReadOnly" size="2" style="display:none;"
                                            maxlength="10" value="0" readonly/></td>
                                    <td class="textoCampos style1"><label style="display:none;" id="lbVlDependentes" name="lbVlDependentes">Valor por
                                            Dependente:</label></td>
                                    <td class="celulaZebra2 style1"><input
                                            name="vlDependentes" onkeypress="mascara(this, reais)"
                                            id="vlDependentes" type="text" class="inputReadOnly" size="7" style="display:none;"
                                            maxlength="10" value="0,00" readonly/></td>
                                    <td class="textoCampos style1">Base Cálculo:</td>
                                    <td class="celulaZebra2 style1"><input
                                            name="vlBaseIr" onkeypress="mascara(this, reais)"
                                            id="vlBaseIr" type="text" class="inputReadOnly" readonly
                                            size="7" maxlength="12" value="0,00" /></td>
                                    <td class="textoCampos style1">Alíquota(%):</td>
                                    <td class="celulaZebra2 style1"><input
                                            name="aliqIr" onkeypress="mascara(this, reais)" id="aliqIr"
                                            type="text" class="inputReadOnly" readonly size="4"
                                            maxlength="6" value="0,00" /></td>
                                </tr>
                                <tr id="trINSS">
                                    <td class="textoCampos style1">INSS:</td>
                                    <td class="celulaZebra2 style1"><input name="vlINSS"
                                                                           onkeypress="mascara(this, reais)" id="vlINSS" type="text"
                                                                           class="inputtexto" onblur="calcula(true, true);" size="9" maxlength="12" value="0,00" />&nbsp;&nbsp;(-)
                                    </td>
                                    <td class="textoCampos style1">Retido mês:</td>
                                    <td class="celulaZebra2 style1"><input
                                            name="vlJaRetido" onkeypress="mascara(this, reais)"
                                            onblur="calculaImpostos()" id="vlJaRetido" type="text"
                                            class="inputtexto" size="7" maxlength="10" value="0,00" />
                                    </td>
                                    <td class="textoCampos style1">Retido outras 
                                        empresas:</td>
                                    <td class="celulaZebra2 style1"><input
                                            name="vlRetidoEmpresa" onkeypress="mascara(this, reais)"
                                            id="vlRetidoEmpresa" type="text" class="inputtexto" size="7"
                                            maxlength="10" value="0,00" /></td>
                                    <td class="textoCampos style1">Base Cálculo:</td>
                                    <td class="celulaZebra2 style1"><input
                                            name="vlBaseInss" onkeypress="mascara(this, reais)"
                                            id="vlBaseInss" type="text" class="inputReadOnly" readonly
                                            size="7" maxlength="10" value="0,00" /></td>
                                    <td class="textoCampos style1">Alíquota(%):</td>
                                    <td class="celulaZebra2 style1"><input
                                            name="aliqInss" onkeypress="mascara(this, reais)"
                                            id="aliqInss" type="text" class="inputReadOnly" readonly
                                            size="4" maxlength="10" value="0,00" />
                                        <input id="aliqInssIntFinan" type="hidden" value="" >
                                        <input id="vlBaseInssIntFinan" type="hidden" value="" >
                                        <input id="vlINSSIntFinan" type="hidden" value="" >
                                        <input id="vlBaseSescIntFinan" type="hidden" value="" >
                                        <input id="aliqSescSenatIntFinan" type="hidden" value="" >
                                        <input id="vlSescSenatIntFinan" type="hidden" value="" >
                                        <input id="vlIrIntFinan" type="hidden" value="" >
                                        <input id="vlBaseIrIntFinan" type="hidden" value="" >
                                        <input id="aliqIrIntFinan" type="hidden" value="" >
                                        <input id="vlDependentesIntFinan" type="hidden" value="" >
                                    </td>
                                </tr>
                                <tr id="trSestSenat">
                                    <td class="textoCampos style1">Sest/Senat:</td>
                                    <td class="celulaZebra2 style1"><input name="vlSescSenat"
                                                                           onkeypress="mascara(this, reais)" onblur="calcula(true, true);" id="vlSescSenat" type="text"
                                                                           class="inputtexto" size="9" maxlength="10" value="0,00" />&nbsp;&nbsp;(-)
                                    </td>
                                    <td class="textoCampos style1" colspan="4"></td>
                                    <td class="textoCampos style1">Base Cálculo:</td>
                                    <td class="celulaZebra2 style1"><input
                                            name="vlBaseSesc" onkeypress="mascara(this, reais)"
                                            id="vlBaseSesc" type="text" class="inputReadOnly" readonly
                                            size="7" maxlength="10" value="0,00" /></td>
                                    <td class="textoCampos style1">Alíquota(%):</td>
                                    <td class="celulaZebra2 style1"><input
                                            name="aliqSescSenat" onkeypress="mascara(this, reais)"
                                            id="aliqSescSenat" type="text" class="inputReadOnly"
                                            readonly size="4" maxlength="10" value="0,00" /></td>
                                </tr>
                                <tr>
                                    <td class="textoCampos style1">Outras retenções:</td>
                                    <td class="celulaZebra2 style1">
                                        <input id="percentualRetencao" name="percentualRetencao" type="text"
                                               class="inputtexto changeHandler" size="5" maxlength="9" value="0" onkeypress="mascara(this, reais)"
                                               onchange="calculaImpostos();">&nbsp;&nbsp;%
                                        
                                        <input onblur="calculaImpostos();"
                                               name="vlOutrasDeducoes" onkeypress="mascara(this, reais)"
                                               id="vlOutrasDeducoes" type="text" class="inputtexto" size="9"
                                               maxlength="10" value="0,00">&nbsp;&nbsp;(-)
                                        
                                        <c:choose>
                                            <c:when test="${param.acao == 1 && configuracao.tipoVlConMotor == 'f' && configuracao.vlConMotor != 0}">
                                                <script>
                                                    $('vlOutrasDeducoes').value = colocarVirgula(parseFloat('${configuracao.vlConMotor}'));
                                                    readOnly($('percentualRetencao'));
                                                </script>
                                            </c:when>
                                            <c:when test="${param.acao == 1 && configuracao.tipoVlConMotor == 'p' && configuracao.vlConMotor != 0}">
                                                <script>
                                                    $('percentualRetencao').value = parseFloat('${configuracao.vlConMotor}').toString().replace('.', ',');
                                                    readOnly($('vlOutrasDeducoes'));
                                                </script>
                                            </c:when>
                                        </c:choose>
                                    </td>
                                    <td class="textoCampos style1" colspan="8">
                                        <input name="vlImpostos" id="vlImpostos" type="hidden" value="0" />
                                    </td>
                                </tr>
                                <tr ${(not configuracao.descontoAutomaticoAbastecimento) ? "style='display: none;'" : ""}>
                                    <td class="textoCampos style1"><label for="abastecimentos">Abastecimentos:</label></td>
                                    <td class="celulaZebra2 style1">    
                                        <input id="abastecimentos" name="abastecimentos" type="text"
                                               class="inputtexto inputReadOnly" size="9" maxlength="9" value="0,00"
                                               onchange="seNaoFloatReset(this, '0,00')" readonly >&nbsp;&nbsp;(-)
                                    </td>
                                    <td class="celulaZebra2 style1" colspan="8">
                                        <label>Referente aos abastecimentos: <span id="lbAbastecimento"></span></label>
                                        <input type="hidden" name="ids_abastecimentos" id="ids_abastecimentos">
                                    </td>
                                </tr>
                                <tr>
                                    <td class="textoCampos style1">Avaria:</td>
                                    <td class="celulaZebra2 style1"><input name="vlAvaria"
                                                                           onkeypress="mascara(this, reais)" onblur="calcula()"
                                                                           id="vlAvaria" type="text" class="inputtexto" size="9"
                                                                           maxlength="10" value="0,00" />&nbsp;&nbsp;(-)</td>
                                    <td class="textoCampos style1" colspan="8"></td>
                                </tr>
                                <c:if test="${!configuracao.outrosRetemImposto}">
                                    <tr>
                                        <td class="textoCampos">Outros:</td>
                                        <td class="celulaZebra2"><input name="vlOutros" onblur="calcula()"
                                                                        onkeypress="mascara(this, reais)" id="vlOutros" type="text"
                                                                        class="inputtexto" size="9" maxlength="10" value="0,00" />&nbsp;&nbsp;(+)
                                        </td>
                                        <td class="celulaZebra2" colspan="8">Descrição Outros:<input
                                                name="obsOutros" id="obsOutros" type="text" class="fieldMin"
                                                maxlength="60" size="60" value="" />
                                        </td>
                                    </tr>
                                </c:if>
                                <tr>
                                    <td class="textoCampos">Pedágio:</td>
                                    <td class="celulaZebra2"><input name="vlPedagio" onblur="calcula()"
                                                                    onkeypress="mascara(this, reais)" id="vlPedagio" type="text"
                                                                    class="inputtexto" size="9" maxlength="10" value="0,00" />&nbsp;&nbsp;(+)&nbsp;&nbsp;
                                        <c:if test="${usuario.filial.stUtilizacaoCfeS ==  'D' || usuario.filial.stUtilizacaoCfeS ==  'A'}">
                                            <img src="img/pedagio1.png" width="40px" height="30px" alt="" name="calcularPegadio" title="Clique aqui para calcular o pedágio." class="imagemLink" id="calcularPegadio"
                                                 onclick="${usuario.filial.stUtilizacaoCfeS ==  'D' ? "getCalcularPedagioNdd()" : "getCalcularPedagioTarget()"}" />&nbsp;&nbsp;
                                            <label id="lbPedagioNddCalculado" name="lbPedagioNddCalculado"></label>                                            
                                        </c:if>
                                    </td>
                                    <td class="celulaZebra2" colspan="3">
                                        <input type="checkbox" class="inputTexto" name="pedagioIdaVolta" id="pedagioIdaVolta" /> Valor do ped&aacute;gio referente a Ida e Volta
                                    </td>
                                    <td class="TextoCampos" colspan="2">
                                        <div><c:if test="${usuario.filial.stUtilizacaoCfeS == 'P' || (usuario.filial.stUtilizacaoCfeS == 'G' && usuario.filial.calcularPedagioCfe ) || usuario.filial.stUtilizacaoCfeS == 'A' || usuario.filial.stUtilizacaoCfeS == 'D'}">Soluç&atilde;o Ped&aacute;gio:
                                                <select onChange="javascript:alterarFavorecidoPedagio();" class="inputtexto" name="solucoesPedagio" id="solucoesPedagio" style="width: 100px;">
                                                    <option value="0">Selecione</option>
                                                    <c:forEach var="solucoesPedagio" varStatus="status" items="${listaSolucaoPedagio}">
                                                        <option value="${solucoesPedagio.id}">${solucoesPedagio.codigo}-${solucoesPedagio.descricao}</option>
                                                    </c:forEach>
                                                </select>
                                            </c:if>
                                        </div>
                                    </td>
                                    <td class="TextoCampos" colspan="3">
                                        <div id="divfavorecidoPedagio" name="divfavorecidoPedagio">
                                            <c:if test="${usuario.filial.stUtilizacaoCfeS == 'P' || usuario.filial.stUtilizacaoCfeS == 'A' || usuario.filial.stUtilizacaoCfeS == 'D'}">
                                                Favorecido do Ped&aacute;gio:
                                                <select class="inputtexto" id="favorecidoPedagio" name="favorecidoPedagio">
                                                    <option value="m">Motorista</option>
                                                    <option value="p">Propriet&aacute;rio</option>
                                                </select>
                                            </c:if>
                                        </div >
                                    </td>    
                                </tr>
                                <c:if test="${!configuracao.diariaRetemImposto}">
                                    <tr>
                                        <td class="textoCampos">Diária:</td>
                                        <td class="celulaZebra2">
                                            <input name="qtdDiaria2" onchange="seNaoIntReset(this, '0');
                                                    calculaDiaria();" id="qtdDiaria2" type="text" class="inputtexto" size="1" maxlength="10" value="0" />(*)
                                            <input name="vlUnitarioDiaria2" onblur="calculaDiaria();" onkeypress="mascara(this, reais)" id="vlUnitarioDiaria2" type="text" class="inputtexto" size="6" maxlength="10" value="0,00" />(=)
                                            <input name="vlDiaria2" onblur="calcula()" onkeypress="mascara(this, reais)" id="vlDiaria2" type="text" class="inputReadOnly" size="6" maxlength="10" value="0,00" readonly/>(+)
                                        </td>
                                        <td class="celulaZebra2" colspan="3">
                                            <input type="checkbox" class="inputTexto" name="diariaParada2" id="diariaParada2" onclick="getDiariaParada()" /> Diária Parado (Sem carregamento)
                                        </td>
                                        <td class="TextoCampos"><label id="lbCliente2" name="lbCliente2">Cliente:</label></td>
                                        <td class="celulaZebra2" colspan="4">
                                            <input type="text"class="inputReadOnly8pt" name="con_rzs2" id="con_rzs2" size="40" readonly> 
                                            <input type="hidden" name="idconsignatario2" id="idconsignatario2" value="0" /> 
                                            <input type="hidden" name="con_valor_diaria_parado2" id="con_valor_diaria_parado2" value="0" /> 
                                            <input type="button" class="inputBotaoMin" id="botaoCliente2" onclick="abrirLocalizaCliente()" value="..." /> 
                                            <img src="img/borracha.gif" alt="" name="borrachaCliente2" class="imagemLink" id="borrachaCliente2" onclick="$('idconsignatario2').value = '0';
                                                    $('con_rzs2').value = '';" />
                                        </td>
                                    </tr>
                                </c:if>
                                <c:if test="${!configuracao.descargaRetemImposto}">
                                    <tr>
                                        <td class="textoCampos">Descarga:</td>
                                        <td class="celulaZebra2"><input name="vlDescarga" onblur="calcula()"
                                                                        onkeypress="mascara(this, reais)" id="vlDescarga" type="text"
                                                                        class="inputtexto" size="9" maxlength="10" value="0,00" />&nbsp;&nbsp;(+)</td>
                                        <td class="celulaZebra2" colspan="8"></td>
                                    </tr>
                                </c:if>
                                <tr id="trTarifas">
                                    <td class="textoCampos">Total Tarifas:</td>
                                    <td class="celulaZebra2">
                                        <input name="vlTarifas" id="vlTarifas"  onkeypress="mascara(this, reais)"  readonly="true"
                                               type="text" class="inputReadOnly" size="9" maxlength="10" value="0,00" onblur="bloquearCamposValorContrato();alterarAdiantamento();"/>&nbsp;&nbsp;(+)</td>
                                    <td colspan="3" class="TextoCampos" >
                                        <div align="left" id="valorTarifasSaque" style="display: ">Saques:
                                            <input name="qtdSaques" type="text" id="qtdSaques" value="" class="inputTexto" size="3" maxlength="5" onkeypress="soNumeros(this.value)" onblur="javascript:calculaTotalTarifas();">

                                            (*)
                                            <input name="valorPorSaques" type="text" id="valorPorSaques" value="" class="inputTexto" size="8" onkeypress="soNumeros(this.value);mascara(this, reais)" onblur="javascript:calculaTotalTarifas();" maxlength="10">
                                            =
                                            <input name="totalSaques" type="text" id="totalSaques" value="" class="inputReadOnly" size="10" onkeypress="soNumeros(this.value)"  readonly="true">
                                        </div>
                                    </td>
                                    <td colspan="5" class="TextoCampos" >
                                        <div align="left" id="valorTarifasTransf" style="display: ">Transferência:
                                            <input name="qtdTransf" type="text" id="qtdTransf" value="" class="inputTexto" size="3" maxlength="5" onkeypress="soNumeros(this.value)" onblur="javascript:calculaTotalTarifas();">

                                            (*)
                                            <input name="valorTransf" type="text" id="valorTransf" value="" class="inputTexto" size="8"  onkeypress="soNumeros(this.value);mascara(this, reais)" onblur="javascript:calculaTotalTarifas();" >
                                            = 
                                            <input name="totalTransf" type="text" id="totalTransf" value="" class="inputReadOnly" size="10"  onkeypress="soNumeros(this.value)" readonly="true" >
                                            </dvi>
                                            </td>
                                            </tr>
                                            <tr>
                                                <td width='10%' class="textoCampos"><b>Valor L&iacute;quido:</b></td>
                                                <td width='22%' class="celulaZebra2"><input name="vlLiquido"
                                                                                            onkeypress="mascara(this, reais)" id="vlLiquido" type="text"
                                                                                            readonly class="inputReadOnly" size="9" maxlength="10"
                                                                                            value="0,00" />&nbsp;&nbsp;(=)</td>
                                                <td width='10%' class="textoCampos"></td>
                                                <td width='7%' class="celulaZebra2"></td>
                                                <td width='16%' class="textoCampos"></td>
                                                <td width='7%' class="celulaZebra2"></td>
                                                <td width='8%' class="textoCampos"></td>
                                                <td width='7%' class="celulaZebra2"></td>
                                                <td width='7%' class="textoCampos"></td>
                                                <td width='5%' class="celulaZebra2"></td>
                                            </tr>                      
                            </table>
                            <table width="100%" border="0" class="bordaFina" align="center">
                                <tr class="tabela">
                                    <td align='center'>Dados do Pagamento</td>
                                </tr>
                            </table>
                            <table width="100%" id="trDadosPagamento">
                                <tbody id="bodyPagamento">
                                    <tr>
                                        <td width="100%" colspan="12">
                                            <table width="100%">
                                                <tr>
                                                    <td width="15%" class="TextoCampos" align="center">
                                                        <input align="center" type="button" class="inputBotao" id="inputAddSaldo" value="Adicionar um novo Saldo" onClick="criarSaldoSecundario();" style="display: none">
                                                    </td>
                                                    <td width="30%" class="TextoCampos">
                                                        Negociação do Adiantamento de Frete :
                                                    </td>
                                                    <td width="10%" class="CelulaZebra2">
                                                        <input id="negociacaoHidden" type="hidden" value="" />
                                                        <select class="inputtexto" id="negociacaoAdiantamento" name="negociacaoAdiantamento" onchange="validarNegociacao(false, this.value)">
                                                            <option value="0"> Não Informado </option>
                                                        </select>
                                                    </td>
                                                    <td width="20%" class="TextoCampos">
                                                        <c:if test="${param.acao == 1}">
                                                            <label id="labelAdiantamento" style="display: none">
                                                                Valor do adiantamento :
                                                            </label>
                                                        </c:if>
                                                    </td>
                                                    <td width="15%" class="CelulaZebra2">
                                                        <c:if test="${param.acao == 1}">
                                                            <div id="camposAdiantamento" style="display: none">
                                                                <input type="text" name="valorAdiantamento" id="valorAdiantamento" value="" class="inputtexto" onkeypress="mascara(this, reais);" maxlength="12" size="10">
                                                                <input type="button" onclick="calcularRateioFilial();" value=" Calcular " class="botoes">
                                                            </div>
                                                        </c:if>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr class="celula">
                                        <td width="3%">
                                            <div align="center">
                                                <img src="img/add.gif" border="0" class="imagemLink" id="imgAddPagamento"
                                                     title="Adicionar um novo Pagamento"
                                                     onClick="validarAddPagto(false);"><input type="hidden"
                                                     id="maxPagamento" name="maxPagamento" value="0" />
                                            </div>
                                        </td>
                                        <td width="4%"><div align="center">Tipo</div></td>
                                        <td width="8%"><div align="center">Valor</div></td>
                                        <td width="8%" style="${param.utilizacaoCfe == 'X'? "display :" : "display: none"}"><div align="center">Valor Desconto</div></td>
                                        <td width="9%"><div align="center">Data</div></td>
                                        <td width="11%"><div align="center">Forma Pgto</div></td>
                                        <td width="8%"><div align="center">Docum</div></td>
                                        <td width="38%"><div align="center">Conta</div></td>
                                        <td width="8%"><div align="center">Despesa</div></td>
                                        <td width="8%"><div align="center">Status</div></td>
                                        <td width="3%"><div align="center"></div></td>
                                    </tr>
                                    
                                </tbody>
                                <tbody id="bodyContaCorrente"></tbody>
                                <tr name="trCartaCC" id="trCartaCC" style="display: none">
                                    <td class="TextoCampos" colspan="2">C/C.:</td>
                                    <td class="TextoCampos"><div align="center">
                                            <input name="cartaValorCC" type="text" id="cartaValorCC" value="0,00" size="9" maxlength="12" class="fieldMin" readonly align="center"></div>
                                        <input name="idPgtoCC" type="hidden" id="idPgtoCC" value="0" >
                                        <input name="idDespesaCC" type="hidden" id="idDespesaCC" value="0" >
                                    </td>
                                    <td class="TextoCampos">
                                        <div align="center">
                                            <input name="cartaDataCC" type="text" id="cartaDataCC" value="" class="fieldMin" onChange="" size="11" maxlength="10" readonly>
                                        </div>
                                    </td>
                                    <td class="TextoCampos"><input name="cartaFPagCC" type="hidden" id="cartaFPagCC" value="2"></td>
                                    <td class="TextoCampos"><input name="contaCC" type="hidden" id="contaCC" value="${configuracao.contaAdiantamentoFornecedor.idConta}"></td>
                                    <td class="CelulaZebra2"></td>
                                    <td class="CelulaZebra2">
                                        <div align="center">
                                            <label id="lbDespCC" name="lbDespCC" class="linkEditar" onClick="verDesp(0);"></label>
                                        </div>
                                    </td>
                                    <td class="CelulaZebra2">
                                        <div align="center">
                                            <label id="lbStatusCC" name="lbStatusCC">
                                            </label>
                                        </div>
                                    </td>
                                    <td class="CelulaZebra2"></td>
                                </tr>
                            </table>
                        </fieldset>
                    </div>
                    <div class="panel" id="tab4">
                        <fieldset>
                            <table class="tabelaZerada" width="100%" id="trDespesas">
                                <tbody id="bodyDespesa">
                                    <tr class="celula">
                                        <td width="3%">
                                            <div align="center">
                                                <img src="img/add.gif" border="0" class="imagemLink"
                                                     title="Adicionar uma nova despesa" onClick="addDespesa();"></span>
                                                <input type="hidden" id="maxDespesa" name="maxDespesa"
                                                       value="0" />
                                            </div>
                                        </td>
                                        <td width="8%" colspan="2"><div align="center">Despesa</div></td>
                                        <td width="6%"><div align="center">Espécie</div></td>
                                        <td width="7%"><div align="center">Série</div></td>
                                        <td width="7%"><div align="center">NF</div></td>
                                        <td width="8%"><div align="center">Emissão</div></td>
                                        <td width="24%"><div align="center">Fornecedor</div></td>
                                        <td width="24%"><div align="center">Histórico</div></td>
                                        <td width="8%"><div align="center">Valor</div></td>
                                        <td width="5%"><div align="center"></div></td>
                                    </tr>
                                </tbody>
                            </table>
                        </fieldset>
                        </div>
                    </div>
                    <div class="panel" id="tab5">
                        <table width="80%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina" style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none" }'>

                            <%@include file="/gwTrans/template_auditoria.jsp" %>

                        <tr class="celulaZebra2">
                            <td class="textoCampos" width="15%">Incluso:</td>
                            <td colspan="2" width="35%">em: ${cadContratoFrete.dtLancamento} <br>
                                por: ${cadContratoFrete.usuarioLancamento.nome}
                            </td>
                            <td class="textoCampos" width="15%">Alterado:</td>
                            <td colspan="2" width="35%">em: ${cadContratoFrete.dtAlteracao} <br>
                                por: ${cadContratoFrete.usuarioAlteracao.nome}
                            </td>
                        </tr>
                    </table>
                </div>                  
                <br>

                <table width="80%" border="0" class="bordaFina" align="center">
                    <tr class="tabela">
                        <td align='center' colspan='2'>Outras Informações</td>
                    </tr>
                    <tr id="trObservacao">
                        <td width="10%" class="textoCampos">Observação:</td>
                        <td width="90%" class="celulaZebra2"><textarea class="inputTexto" cols="80" rows="3" id="observacao" name="observacao"><c:out value="${cadContratoFrete.observacao}" /></textarea></td>
                    </tr>
                </table>



                <table width="80%" border="0" class="bordaFina" align="center">
                    <tr>                                    
                        <c:if test="${param.nivel >= param.bloq && (param.nivelSalvarImpresso == null || param.nivelSalvarImpresso == 4)}">
                            <td colspan="6" class="celulaZebra2">
                                <div align="center">
                                    <input type="button" value="  SALVAR  " class="inputBotao"
                                           id="botSalvar"
                                           onclick="tryRequestToServer(function () {
                                                       salvar()
                                                   })" />
                                </div>
                            </td>
                        </c:if>
                    </tr>
                </table>

            </form>
        </table>
    </div>
</body>
</html>

