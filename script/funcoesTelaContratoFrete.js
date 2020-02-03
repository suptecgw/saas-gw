/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/* global Ajax */

function limparVeiculo() {
    $("vei_placa").value = "";
    $("vei_prop").value = "";
    $("vei_prop_cgc").value = "";
    $("idveiculo").value = "0";
    $("vei_cap_carga").value = "";

}

function limparCarreta() {
    $("car_placa").value = "";
    $("car_prop").value = "";
    $("car_prop_cgc").value = "";
    $("idcarreta").value = "0";
    $("car_cap_carga").value = "";
}

function limparBiTrem() {
    $("bi_placa").value = "";
    $("bi_prop").value = "";
    $("bi_prop_cgc").value = "";
    $("idbitrem").value = "0";
    $("bi_cap_carga").value = "";
}

function showHide(isShow, isValida) {
    isValida = (isValida == undefined || isValida == true ? true : false);
    if (isShow) {
        visivel($("tab3"));
        visivel($("trDadosPagamento"));
        visivel($("trDespesas"));
        visivel($("abaPagamento"));
    } else {
        var idProp = $("idproprietarioveiculo").value;
        if (isValida && idProp != '' && $("is_tac").value == "f") {
            alert("Atenção, o proprietário do veículo não é um\r\nTAC (Transportador autônomo de cargas)\r\nportanto não poderá emitir CF-e.")
            $("statusContrato").checked = true;
            return false;
        }
        invisivel($("tab3"));
        invisivel($("trDadosPagamento"));
        invisivel($("trDespesas"));
        invisivel($("abaPagamento"));
    }
    return true;
}

function isRetencaoImpostoOperadoraCFe(){
    var idFilial = $("filial").value;
    var isRetencaoImpostoOperadoraCFe = ($("is_retencao_imposto_operadora_cfe_" + idFilial).value == "true" || $("is_retencao_imposto_operadora_cfe_" + idFilial).value == "t");
    return (contratoRetencaoImpostoOperadoraCFe || isRetencaoImpostoOperadoraCFe);
}

function calculaImpostos() {
    if ($("vlFreteMotorista").value == "") {
        $("vlFreteMotorista").value = "0,00";
    }

    // Verificar se o usuário NÃO tem permissão de:
    // * "(CONTRATO DE FRETE) Alterar o valor do contrato desconsiderando o valor que será calculado automaticamente pela tabela de preço."
    // * "(CONTRATO DE FRETE) Autorizar contrato de frete com valor maior que o definido na tabela de preço."
    // Se não tiver, caso tenha tabela de rota, deverá validar se o valor do contrato não extrapola o valor máximo da tabela.
    // A validação só será feita para o tipo de tabela rota "Valor fixo" e "R$/KM"
    if (valueBefore !== null && valueBefore !== '0,00' && valueBefore !== this.value
        && validarValorMaximoTabelaRotaPermissao
        && !$('solicitarAutorizacao').checked
        && ($('tab_tipo_valor').value === 'f' || $('tab_tipo_valor').value === 'k')) {
        let valorFrete = 0;

        if ($('tab_tipo_valor').value === 'f') {
            valorFrete = parseFloat(colocarPonto($("vlFreteMotorista").value));
        } else if ($('tab_tipo_valor').value === 'k') {
            valorFrete = parseFloat(colocarPonto($("valorPorKM").value));
        }

        let valorMaximoTabela = parseFloat($('tab_valor_maximo').value);
        
        if (valorFrete > valorMaximoTabela) {
            if ($('tab_tipo_valor').value === 'f') {
                alert('Valor do contrato maior que o máximo permitido para rota. Você deverá solicitar autorização para lançar esse valor.')
            } else if ($('tab_tipo_valor').value === 'k') {
                alert('Valor do KM maior que o máximo permitido para rota. Você deverá solicitar autorização para lançar esse valor.')
            }

            valueBefore = '0,00';

            getTabelaPreco();
        }
    }

    calcularRetencoes();
    var isReter = $("chkReterImpostos").checked;
    if (isReter && !isRetencaoImpostoOperadoraCFe()) {
        var inss = calculaInss(true);
        calculaSest(inss.baseCalculo, true);
        calculaIR(inss, true);
    } else {
        $('vlIr').value = '0,00';
        $('vlDependentes').value = '0,00';
        $('vlBaseIr').value = '0,00';
        $('aliqIr').value = '0,00';
        $('vlINSS').value = '0,00';
        $('vlRetidoEmpresa').value = '0,00';
        $('vlBaseInss').value = '0,00';
        $('aliqInss').value = '0,00';
        $('vlSescSenat').value = '0,00';
        $('vlBaseSesc').value = '0,00';
        $('aliqSescSenat').value = '0,00';
        if (isRetencaoImpostoOperadoraCFe()) {
            var inss = calculaInss(false);
            calculaSest(inss.baseCalculo, false);
            calculaIR(inss, false);
        }
    }
    calcula();
    getBaseRetencao();
}

function verificaSituacaoMotorista() {
    if ($("bloqueado").value == 't' || $("bloqueado").value == 'true') {
        alert('Esse motorista está bloqueado. Motivo: ' + $("motivobloqueio").value);
        $("motor_nome").value = '';
        $("idmotorista").value = '0';
        $("vei_placa").value = '';
        $("car_placa").value = '';
        $("bi_placa").value = '';
        $("motor_cpf").value = '';
        $("vei_prop").value = '';
        $("car_prop").value = '';
        $("bi_prop").value = '';
        $("motor_cnh").value = '';
        $("vei_prop_cgc").value = '';
        $("car_prop_cgc").value = '';
        $("bi_prop_cgc").value = '';
    }
}

function abrirLocalizaMotorista() {
    if (countPgto == 0) {
        if ($("stUtilizacaoCfeS").value == 'A') {
            // Caso o CF-e for Target, seta o parâmetro paramaux4 com o ID de 7 para abrir a solução de pedágio "Cartão Target Bradesco"
            launchPopupLocate('./localiza?acao=consultar&paramaux=carta&idlista=10&fecharJanela=true&paramaux4=7', 'Motorista');
        } else if ($("stUtilizacaoCfeS").value == 'D') {
            // Caso o CF-e for NDD, seta o parâmetro paramaux4 com o ID de 4 para abrir a solução de pedágio "Sem Parar / Via Fácil"
            launchPopupLocate('./localiza?acao=consultar&paramaux=carta&idlista=10&fecharJanela=true&paramaux4=4', 'Motorista');
        } else {
            launchPopupLocate('./localiza?acao=consultar&paramaux=carta&idlista=10&fecharJanela=true', 'Motorista');
        }
    } else {
        alert('Alteração não permitida. Já existem pagamentos lançados nesse contrato.');
    }
}

function abrirLocalizaNatureza() {
    launchPopupLocate('./localiza?acao=consultar&idlista=64&fecharJanela=true', 'Natureza')
}
function abrirLocalizaVeiculo() {
    try {
        if (countPgto == 0) {
            launchPopupLocate('./localiza?acao=consultar&idlista=7&fecharJanela=true', 'Veiculo');

        } else {
            alert('Alteração não permitida. Já existem pagamentos lançados nesse contrato.');
        }
    } catch (e) {
        console.log(e);
        alert(e);
    }

}

function voltar() {
    tryRequestToServer(function () {
        window.location = "ContratoFreteControlador?acao=listar";
    });
}

function aparecerContratoRepom(valor) {
    if (valor == 0) {
        $("contratoRepom").style.display = "none";
    } else {
        $("contratoRepom").style.display = "";
    }
}


function habilitarCampo(campo) {
    $(campo).removeClassName("inputReadOnly");
    $(campo).addClassName("inputTexto");
    $(campo).readOnly = false;
}
function desabilitarCampo(campo) {
    $(campo).removeClassName("inputTexto");
    $(campo).addClassName("inputReadOnly");
    $(campo).readOnly = true;
}

function visualizarImpostos(){
    if ($("chkReterImpostos").checked) {
        visivel($("trIR"));
        visivel($("trINSS"));
        visivel($("trSestSenat"));
    } else {
        invisivel($("trIR"));
        invisivel($("trINSS"));
        invisivel($("trSestSenat"));
    }
}
function reterImposto() {
    if ($("chkReterImpostos").checked) {
        if (isRetencaoImpostoOperadoraCFe()) {
            $("chkReterImpostos").checked = false;
            alert("ATENÇÃO: Os impostos serão calculados no momento da quitação do saldo!");
        }
    }
    visualizarImpostos();
    calculaImpostos();
}

//@@@@@@@@@@@@@@@@@@ CALCULOS @@@@@@@@@@@@@@@@@@@
function getTotAdiantamento() {
    var vlAdiantamento = 0;
    for (i = 1; i <= countPgto; i++) {
        if ($("valorPgto_" + i) != null && $("tipoPagto_" + i).value == "a" && $("isControlarTarifasBancariasContratado_" + i).value == 'false') {
            vlAdiantamento += parseFloat(colocarPonto($("valorPgto_" + i).value));
        }
    }
    return vlAdiantamento;
}

function calculaSaldo(index) {
    try {
//        var vlLiquido = parseFloat(colocarPonto($("vlLiquido").value)) - parseFloat(colocarPonto($("vlTarifas").value));
        var vlLiquido = parseFloat(colocarPonto($("vlLiquido").value));
        var vlContrato = parseFloat(colocarPonto($("vlFreteMotorista").value));
        var vlAdiantamento = getTotAdiantamento();
        var vlSaldo = vlLiquido - vlAdiantamento;
        var vls;
        var dtPagamento = "";
        var countSaldo = 0;
        var vlDeducaoSaldo = 0;
        var percDeducaoSaldo = 0;
        var vlPgto = 0;
        var vlCC = 0;

        if (parseFloat($('debito_prop').value) > 0 && parseFloat($('percentual_desconto_prop').value) > 0) {
            var percentual_desconto = parseFloat($('percentual_desconto_prop').value);

            if ($('tipo_desconto_prop').value == '2') {
                // ^--- Sobre o valor do frete
                vlCC = (vlSaldo == 0 ? 0 : vlContrato * parseFloat(colocarVirgula($('percentual_desconto_prop').value)) / 100);
            } else {
                vlCC = (vlSaldo == 0 ? 0 : parseFloat(parseFloat(percentual_desconto) * parseFloat(vlSaldo) / 100));
            }
            if (parseFloat(vlCC) > parseFloat($('debito_prop').value)) {
                vlCC = $('debito_prop').value;
            }
            vls = parseFloat(parseFloat(formatoMoeda(vlSaldo)) - parseFloat(formatoMoeda(vlCC)));
        }

        if ($("tipoPagto_" + index) != null && $("tipoPagto_" + index).value == "s") {
            vlPgto = parseFloat(colocarPonto($("valorPgto_" + index).value));
            if (vlCC != 0 && vlPgto != 0) {
                if ($('tipo_desconto_prop').value != '2') {
                    // ^--- Se não for sobre o valor do frete
                    percDeducaoSaldo = roundABNT((vlPgto * 100 / vlSaldo));
                    vlDeducaoSaldo = roundABNT(parseFloat(vlCC * percDeducaoSaldo / 100), 2);
                    $("valorPgto_" + index).value = colocarVirgula(vlPgto - vlDeducaoSaldo, 2);
                }
                dtPagamento = $("dataPgto_" + index).value;
            }
        }
        if (vlCC != null && parseFloat(vlCC) > 0) {
            visivel($("trCartaCC"));
            $('cartaValorCC').value = colocarVirgula(roundABNT(parseFloat(vlCC), 2), 2);
            if (dtPagamento != "") {
                $('cartaDataCC').value = dtPagamento;
            }
        } else {
            invisivel($("trCartaCC"));
        }
    } catch (e) {
        console.log(e);
    }

}

function verificarSobraPgto() {
    var maxPgto = parseInt($("maxPagamento").value, 0);
    var vlLiquido = parseFloat(colocarPonto($("vlLiquido").value));
    var vlCC = parseFloat(colocarPonto($('cartaValorCC').value == "" ? "0,00" : $('cartaValorCC').value));
    var vlTotPgto = 0;
    var vlDiferenca = 0;
    for (var i = 1; i <= maxPgto; i++) {
        if ($("tipoPagto_" + i) != null) {
            vlTotPgto += parseFloat(colocarPonto($("valorPgto_" + i).value));
        }
    }
    vlDiferenca = vlLiquido - vlTotPgto - vlCC;

    var continuar = true;
    var indiceReverso = maxPgto;
    if (vlDiferenca > 0) {
        do {
            if ($("tipoPagto_" + indiceReverso) != null) {
                if ($("tipoPagto_" + indiceReverso).value == "s") {
                    $("valorPgto_" + indiceReverso).value = colocarVirgula(parseFloat(colocarPonto($("valorPgto_" + indiceReverso).value)) + vlDiferenca);
                    continuar = false;
                }
            } else {
                continuar = false;
            }
            indiceReverso--;
        } while (continuar);
    }
}


function alterarAdiantamento() {
//    var vlLiquido = parseFloat(colocarPonto($("vlLiquido").value)) - parseFloat($("vlTarifas").value);
    var vlLiquido = parseFloat(colocarPonto($("vlLiquido").value));
    var vlAdiantamento = getTotAdiantamento();
    var vlCC = parseFloat(colocarPonto($('cartaValorCC').value == "" ? "0,00" : $('cartaValorCC').value));
    var vlSaldo = vlLiquido - vlAdiantamento - vlCC;
    var qtdSaldos = 0;

    for (i = 1; i <= countPgto; i++) {

        if ($("idPgto_" + i) != null && $("tipoPagto_" + i).value == "s") {
            qtdSaldos++;
        }
    }
    if (qtdSaldos == 1) {
        for (i = 1; i <= countPgto; i++) {
            if ($("idPgto_" + i) != null && $("tipoPagto_" + i).value == "s") {
                if ($("valorPgto_" + i).disabled == false) {
                    $("valorPgto_" + i).value = colocarVirgula(vlSaldo / qtdSaldos, 2);
                }
            }
        }
    }
}

function pagtoLivre(tipo) {
    for (var i = 1; i <= countPgto; i++) {
        if ($("idPgto_" + i) != null && $("tipoPagto_" + i).value == tipo && $("despesaPagId_" + i).value == '0') {
            return i;
        }
    }
    return null;
}

function calculaAdiantamento(index) {
    var vlLiquido = parseFloat(colocarPonto($("vlLiquido").value)) - parseFloat($("vlTarifas").value);
//                var vlAdiantamento = parseFloat($('perc_adiant').value) / 100 * vlLiquido;
//
//                $("valorPgto_" + index).value = colocarVirgula(vlAdiantamento, 2);
}

/*function calcularRetencoes() {
        var vlDeducoes = 0;
        if ($("consultaMotorConf").value == 0 && $("percentualDescontoContrato").value == 0) {
            vlDeducoes = $("consultaMotorConf").value;
        } else {
            if ($("tipoVlConMotorista").value == "f") {
                vlDeducoes = $("consultaMotorConf").value;

            } else {
                vlDeducoes = (parseFloat(colocarPonto($("vlFreteMotorista").value)) * parseFloat($("consultaMotorConf").value)) / 100;
            }
            vlDeducoes += ((parseFloat(colocarPonto($("vlFreteMotorista").value)) * parseFloat($("percentualDescontoContrato").value)) / 100);
        }
        $("vlOutrasDeducoes").value = colocarVirgula(vlDeducoes, null);
    }*/

function calcularRetencoes() {
    var vlDeducoes = 0;

    var elementoValorOutrasRetencoes = $('vlOutrasDeducoes');
    var elementoPercentualRetencao = $('percentualRetencao');
    var elementoValorLiquido = $('vlFreteMotorista');

    var valorRetencao = pontoParseFloat(elementoValorOutrasRetencoes.value);
    var valorPercentualRetencao = pontoParseFloat(elementoPercentualRetencao.value);// esse campo vem do aoclicarnolocaliza de motorista com PONTO, logo, colocar ponto quebra o campo.
    var valorLiquido = pontoParseFloat(elementoValorLiquido.value);

    if (valorPercentualRetencao < 0) {
        elementoPercentualRetencao.value = '0';
        vlDeducoes = 0;
        notReadOnly(elementoValorOutrasRetencoes);
        alert('O percentual não pode ser menor que 0%!');
    } else if (valorPercentualRetencao > 100) {
        elementoPercentualRetencao.value = '0';
        vlDeducoes = 0;
        notReadOnly(elementoValorOutrasRetencoes);
        alert('O percentual não pode ser maior que 100%!');
    } else {
        if (valorRetencao === 0 && valorPercentualRetencao === 0) {
            notReadOnly(elementoValorOutrasRetencoes);
            notReadOnly(elementoPercentualRetencao);
        } else if (valorPercentualRetencao !== 0 && valorRetencao === 0 && !elementoValorOutrasRetencoes.readOnly) {
            readOnly(elementoValorOutrasRetencoes);
        } else if (valorPercentualRetencao === 0 && valorRetencao !== 0 && elementoValorOutrasRetencoes.readOnly) {
            notReadOnly(elementoValorOutrasRetencoes);
        } else if (valorRetencao !== 0 && valorPercentualRetencao === 0 && !elementoPercentualRetencao.readOnly) {
            readOnly(elementoPercentualRetencao);
        } else if (valorRetencao === 0 && valorPercentualRetencao !== 0 && elementoPercentualRetencao.readOnly) {
            notReadOnly(elementoPercentualRetencao);
        }

        // Calcular
        if (valorPercentualRetencao !== 0 && elementoValorOutrasRetencoes.readOnly) {
            vlDeducoes = (valorLiquido * valorPercentualRetencao) / 100;
        } else if (elementoPercentualRetencao.readOnly) {
            vlDeducoes = valorRetencao;
        }
        
        elementoValorOutrasRetencoes.value = colocarVirgula(vlDeducoes, null);
    }
}

function calcularEntregas(linha) {
    var totalEntregas = 0;
    for (var i = 1; i <= linha; i++) {
        if ($("labelEntregas_" + i) != null && $("labelEntregas_" + i) != undefined) {
            totalEntregas += parseFloat($("labelEntregas_" + i).innerHTML);
        }
    }
    $("labTotalEntregas").innerHTML = totalEntregas;
    $("inTotalEntregas").value = colocarVirgula(totalEntregas);
}
function calcularPeso(linha) {
    var totalPeso = 0;
    for (var i = 1; i <= linha; i++) {
        if ($("labelPeso_" + i) != null && $("labelPeso_" + i) != undefined) {
            totalPeso += parseFloat(colocarPonto($("labelPeso_" + i).innerHTML));
        }
    }
    $("labTotalPeso").innerHTML = colocarVirgula(totalPeso);
    $("labTotalPesoTon").innerHTML = colocarVirgula(totalPeso / 1000) + " TON";
    $("pesoTonelada").value = (totalPeso / 1000);
}
function calcularVolume(linha) {
    var totalVolume = 0;
    for (var i = 1; i <= linha; i++) {
        if ($("labelVol_" + i) != null && $("labelVol_" + i) != undefined) {
            totalVolume += parseFloat(colocarPonto($("labelVol_" + i).innerHTML));
        }
    }
    $("labTotalVol").innerHTML = colocarVirgula(totalVolume);
}
function calcularValorFrete(linha) {
    var totalValorFrete = 0;
    for (var i = 1; i <= linha; i++) {
        if ($("labelValorFrete_" + i) != null && $("labelValorFrete_" + i) != undefined) {
            totalValorFrete += parseFloat(colocarPonto($("labelValorFrete_" + i).innerHTML));
        }
    }
    $("labTotalValorFrete").innerHTML = colocarVirgula(totalValorFrete);
    $("inTotalValorFrete").value = colocarVirgula(totalValorFrete);
}
function calcularValorNota(linha) {
    var totalValorNota = 0;
    for (var i = 1; i <= linha; i++) {
        if ($("labelValorNota_" + i) != null && $("labelValorNota_" + i) != undefined) {
            totalValorNota += parseFloat(colocarPonto($("labelValorNota_" + i).innerHTML));
        }
    }
    $("labTotalMerc").innerHTML = colocarVirgula(totalValorNota);
    $("inTotalValorNota").value = colocarVirgula(totalValorNota);
}
function calcularValorFreteCte(linha) {
    var totalValorFreteCte = 0;
    for (var i = 1; i <= linha; i++) {
        if ($("valorFreteCte_" + i) != null && $("valorFreteCte_" + i) != undefined) {
            totalValorFreteCte += parseFloat(colocarPonto($("valorFreteCte_" + i).value));
        }
    }
    $("totalValorFreteCte").value = colocarVirgula(totalValorFreteCte);
}
function calcularValorPesoCte(linha) {
    var totalValorPesoCte = 0;
    for (var i = 1; i <= linha; i++) {
        if ($("valorPesoCte_" + i) != null && $("valorPesoCte_" + i) != undefined) {
            totalValorPesoCte += parseFloat(colocarPonto($("valorPesoCte_" + i).value));
        }
    }
    $("totalValorPesoCte").value = colocarVirgula(totalValorPesoCte);
}




//@@@@@@@@@@@@@@@@@@@  PAGAMENTO @@@@@@@@@@@@@@@@  INICIO
function ContratoFretePagamento(id, tipo, valor, data, fpag, doc, agente_id,
        agente, despesa_id, fixo, percAbastec, baixado, contaId, saldoAutorizado, planoAgente,
        contaAd, agenciaAd, favorecidoAd, bancoAd, tipoFavorecido, undAgente, nfiscal, tipoConta, isPamcard,
        isRepom, isNdd, isTicket, tipoPagamentoCfe, isContaCorrente, isControlarTarifasBancariasContratado,
        isEFrete, isExpers, isPagBem, valorDesconto, utilizaNegociacao, percPgto, isCarregando, isValorEditavel,tipoContaPgto, tipoCalculo, idfilial,filial,totalFilialPagamento, isTarget,
        observacao, fechamentoAgregadoId, dataFechamentoAgregado ,despesafechamentoAgregadoId) {
    this.id = (id == null || id == undefined ? 0 : id);
    this.tipo = (tipo == null || tipo == undefined ? "a" : tipo);
    this.valor = (valor == null || valor == undefined ? 0 : valor);
    this.data = (data == null || data == undefined ? dataAtual : data);
    this.doc = (doc == null || doc == undefined ? "" : doc);
    this.agente_id = (agente_id == null || agente_id == undefined ? 0 : agente_id);
    this.agente = (agente == null || agente == undefined ? "" : agente);
    this.despesa_id = (despesa_id == null || despesa_id == undefined ? 0 : despesa_id);
    this.fixo = (fixo == null || fixo == undefined ? false : fixo);
    this.percAbastec = (percAbastec == null || percAbastec == undefined ? 0 : percAbastec);
    this.baixado = (baixado == null || baixado == undefined ? false : baixado);
    this.contaId = (contaId == null || contaId == undefined ? 0 : contaId);
    this.saldoAutorizado = (saldoAutorizado == null || saldoAutorizado == undefined ? false : saldoAutorizado);
    this.planoAgente = (planoAgente == null || planoAgente == undefined ? 0 : planoAgente);
    this.contaAd = (contaAd == null || contaAd == undefined ? "" : contaAd);
    this.agenciaAd = (agenciaAd == null || agenciaAd == undefined ? "" : agenciaAd);
    this.favorecidoAd = (favorecidoAd == null || favorecidoAd == undefined ? "" : favorecidoAd);
    this.bancoAd = (bancoAd == null || bancoAd == undefined ? "" : bancoAd);
    this.tipoFavorecido = (tipoFavorecido == null || tipoFavorecido == undefined ? "" : tipoFavorecido);
    this.undAgente = (undAgente == null || undAgente == undefined ? "" : undAgente);
    this.nfiscal = (nfiscal == null || nfiscal == undefined ? "" : nfiscal);
    this.tipoConta = (tipoConta == null || tipoConta == undefined ? "c" : tipoConta);
    this.isPamcard = (($('is_tac').value == 't') && ($('filialCfe_' + $('filial').value).value == 'P'));
    this.isRepom = (($('is_tac').value == 't') && ($('filialCfe_' + $('filial').value).value == 'R'));
    this.isNdd = (($('is_tac').value == 't') && ($('filialCfe_' + $('filial').value).value == 'D'));
    this.isTicket = (($('is_tac').value == 't') && ($('filialCfe_' + $('filial').value).value == 'T'));
    this.tipoPagamentoCfe = (tipoPagamentoCfe == null || tipoPagamentoCfe == undefined ? "M" : "A");
    this.isEFrete = (($('filialCfe_' + $('filial').value).value == 'E'));
    this.isExpers = (($('filialCfe_' + $('filial').value).value == 'X'));
    this.isPagBem = (($('filialCfe_' + $('filial').value).value == 'G'));
    this.emissaoGratuita = (($('emissao_gratuita_' + $('filial').value).value == 'true')); //emissao_gratuita_
    this.valorDesconto = (valorDesconto == null || valorDesconto == undefined ? 0 : valorDesconto);
    this.percPgto = (percPgto == null || percPgto == undefined ? 0 : percPgto);
    this.tipoContaPgto = (tipoContaPgto == null || tipoContaPgto == undefined ? 'c' : tipoContaPgto);
    this.isValorEditavel = (isValorEditavel == null || isValorEditavel == undefined ? false : isValorEditavel);
    this.idfilial = (idfilial == null || idfilial == undefined ? 0 : idfilial);
    this.filial = (filial == null || filial == undefined ? "" : filial);
    this.totalFilialPagamento = (totalFilialPagamento == null || totalFilialPagamento == undefined ? 0 : totalFilialPagamento);
    this.isTarget = (($('is_tac').value == 't') && ($('filialCfe_' + $('filial').value).value == 'A'));
    this.observacao = (observacao == null || observacao == undefined ? "" : observacao);


    if (fpag == null || fpag == undefined) {
        if (this.isPamcard) {
            this.fpag = 11;
        } else if (this.isRepom) {
            this.fpag = 12;
        } else if (this.isNdd) {
            this.fpag = 14;
        } else if (this.isTicket) {
            this.fpag = 13;
        } else if (this.isEFrete) {
            this.fpag = 16;
        } else if (this.isExpers) {
            this.fpag = 17;
        } else if (this.isPagBem) {
            this.fpag = 18;
        } else if (this.isTarget) {
            this.fpag = 20;
        } else {
            this.fpag = 4;
        }
    } else {
        this.fpag = fpag;
    }
    this.isContaCorrente = (isContaCorrente == null || isContaCorrente == undefined ? false : isContaCorrente);
    this.isControlarTarifasBancariasContratado = (isControlarTarifasBancariasContratado == undefined ? false : isControlarTarifasBancariasContratado);
    this.utilizaNegociacao = (utilizaNegociacao == undefined ? false : utilizaNegociacao);
    this.isCarregando = (isCarregando == null || isCarregando == undefined ? false : isCarregando);
    this.tipoCalculo = (tipoCalculo == null || tipoCalculo == undefined ? false : tipoCalculo);
    this.fechamentoAgregadoId = (fechamentoAgregadoId === null || fechamentoAgregadoId === undefined ? 0 : fechamentoAgregadoId);
    this.dataFechamentoAgregado = (dataFechamentoAgregado === null || dataFechamentoAgregado === undefined ? 0 : dataFechamentoAgregado);
    this.despesafechamentoAgregadoId = (despesafechamentoAgregadoId === null || despesafechamentoAgregadoId === undefined ? 0 : despesafechamentoAgregadoId);

}

function addTarifaBancaria() {
    var vlTarifa = parseFloat(colocarPonto($("valorTarifas").value));
    var quantidadeTarifasBancarias = jQuery("input[id *= 'isControlarTarifasBancariasContratado'][value='true']").length;
    // SO DEVE ADICIONAR TARIFA SE NÃO EXISTIR AINDA...
    if ($("controlarTarifasBancariasContratado").value == "true" && ($("stUtilizacaoCfeS").value == 'P' || $("stUtilizacaoCfeS").value == 'D') && vlTarifa > 0 && quantidadeTarifasBancarias < 1) {
        var tarifa = new ContratoFretePagamento();
        tarifa.tipo = "a";
        tarifa.isContaCorrente = true;
        tarifa.isControlarTarifasBancariasContratado = true;
        addPagto(tarifa, true);
    }
}

function recalcularPgtos() {
    var maxPgto = parseInt($("maxPagamento").value, 10);
    var valorAdiant = 0;
    var valorSaldo = 0;
    var valorAdiantSaldo = 0;
    var vlLiquido = parseFloat(colocarPonto($("vlLiquido").value));
    var vlContrato = parseFloat(colocarPonto($("vlFreteMotorista").value));

    for (var i = 1; i <= maxPgto; i++) {

        recalcularPgto(i);
        calculaSaldo(i);

        if ($('tipo_desconto_prop').value == '2') {
            // ^--- Sobre o valor do frete
            var vlCC = (vlContrato * parseFloat(colocarVirgula($('percentual_desconto_prop').value))) / 100;

            if (vlCC > parseFloat($('debito_prop').value)) {
                vlCC = $('debito_prop').value;
            }

            vlLiquido = vlLiquido - vlCC;
        }

        valorAdiantSaldo = roundABNT((vlLiquido * parseFloat($("percPgto_" + i).value)) / 100, 3);
        //Pegando o ultimo adiantamento
        if ((i === (maxPgto - 1))) {
            //listando todo os pagamentos para pegar os adiantamentos
            for (var ad = 1; ad <= maxPgto; ad++) {
                if ($("tipoPagto_" + ad).value == 'a') {
                    //Equanto não for o penultimo, então calcula.
                    if (!(ad === (maxPgto - 1))) {
                        //Somando os valores dos adiantamentos das filias de destinos.
                        valorAdiant += parseFloat($("valorPgto_" + ad).value);
                    }
                }
            }
            $("valorPgto_" + i).value = colocarVirgula(roundABNT(parseFloat(valorAdiantSaldo) - parseFloat(valorAdiant), 3));
        }
    }
    verificarSobraPgto();
}

function recalcularPgto(index) {
    var vlLiquido = parseFloat(colocarPonto($("vlLiquido").value));
    var vlContrato = parseFloat(colocarPonto($("vlFreteMotorista").value));
    var valorTarifas = pontoParseFloat($("vlTarifas").value);
    var vlCC = parseFloat(colocarPonto($('cartaValorCC').value == "" ? "0,00" : $('cartaValorCC').value));
    if ($("controlarTarifasBancariasContratado").value && ($("stUtilizacaoCfeS").value == 'P' || $("stUtilizacaoCfeS").value == 'D' || $("stUtilizacaoCfeS").value == 'A')) {
//        vlLiquido = vlLiquido - valorTarifas;
    }

    if ($('tipo_desconto_prop').value == '2') {
        // ^--- Sobre o valor do frete
        vlCC = (vlContrato * parseFloat(colocarVirgula($('percentual_desconto_prop').value))) / 100;

        if (vlCC > parseFloat($('debito_prop').value)) {
            vlCC = $('debito_prop').value;
        }
    }
    vlLiquido = vlLiquido - vlCC;

    var vlPgto = 0;
    var percPgto = 0;
    if ($("percPgto_" + index) != null) {
        if ($("isControlarTarifasBancariasContratado_" + index).value != "true") {
            //Se na negociação estiver o novo tipo de calculo, é tratado dentro de RF
            if ($("tipoCalculoNegociacao").value == "rf") {

                var percVlFilial = $("valoTotalFilial_" + index).value;
                var valorContratoFilial = roundABNT((vlLiquido * percVlFilial / 100), 3);
                vlPgto = roundABNT((valorContratoFilial * $("percPgto_" + index).value) / 100, 3);

            } else {
                //Regra antiga de Recalcular os pagamentos.
                percPgto = parseFloat(($("percPgto_" + index).value));
                vlPgto = (vlLiquido * percPgto / 100);
            }

            $("valorPgto_" + index).value = colocarVirgula(vlPgto, 2);
        }
    }
}

function getPrimeiroSaldo(){
    for (var i = 0; i <= countPgto; i++) {
        if ($("tipoPagto_" + i) != null && $("tipoPagto_" + i).value == "s") {
            return i;
        }
    }
    return -1;
}

function alteraTipoFavorecido(idx) {
    if ($('tipoFavorecido_' + idx) != null) {
        var tipo = $('tipoFavorecido_' + idx).value;
        if (tipo == 'm' && $('tipoPagto_' + idx).value == 'a') {
            $('contaAd_' + idx).value = ($('motor_conta1').value.trim() != '' ? $('motor_conta1').value : $('motor_conta2').value);
            $('agenciaAd_' + idx).value = ($('motor_conta1').value.trim() != '' ? $('motor_agencia1').value : $('motor_agencia2').value);
            $('favorecidoAd_' + idx).value = ($('motor_conta1').value.trim() != '' ? $('motor_favorecido1').value : $('motor_favorecido2').value);
            $('banco_' + idx).value = ($('motor_conta1').value.trim() != '' ? $('motor_banco1').value : $('motor_banco2').value);
            $('tipoContaPgto_' + idx).value = ($('motor_tipo_conta1').value.trim() != '' ? $('motor_tipo_conta1').value : $('motor_tipo_conta2').value);
            if ($('favorecidoAd_' + idx).value.trim() == '') {
                $('favorecidoAd_' + idx).value = $('motor_nome').value;
            }
        } else if (tipo == 'm' && $('tipoPagto_' + idx).value == 's') {
            $('contaAd_' + idx).value = ($('motor_conta2').value != '' ? $('motor_conta2').value : $('motor_conta1').value);
            $('agenciaAd_' + idx).value = ($('motor_conta2').value != '' ? $('motor_agencia2').value : $('motor_agencia1').value);
            $('favorecidoAd_' + idx).value = ($('motor_conta2').value != '' ? $('motor_favorecido2').value : $('motor_favorecido1').value);
            $('banco_' + idx).value = ($('motor_conta2').value != '' ? $('motor_banco2').value : $('motor_banco1').value);
            $('tipoContaPgto_' + idx).value = ($('motor_tipo_conta2').value.trim() != '' ? $('motor_tipo_conta2').value : $('motor_tipo_conta1').value);
            if ($('favorecidoAd_' + idx).value.trim() == '') {
                $('favorecidoAd_' + idx).value = $('motor_nome').value;
            }
        } else if (tipo == 'p' && $('tipoPagto_' + idx).value == 'a') {
            $('contaAd_' + idx).value = ($('prop_conta1').value != '' ? $('prop_conta1').value : $('prop_conta2').value);
            $('agenciaAd_' + idx).value = ($('prop_conta1').value != '' ? $('prop_agencia1').value : $('prop_agencia2').value);
            $('favorecidoAd_' + idx).value = ($('prop_conta1').value != '' ? $('prop_favorecido1').value : $('prop_favorecido2').value);
            $('banco_' + idx).value = ($('prop_conta1').value != '' ? $('prop_banco1').value : $('prop_banco2').value);
            $('tipoContaPgto_' + idx).value = ($('prop_tipo_conta1').value.trim() != '' ? $('prop_tipo_conta1').value : $('prop_tipo_conta2').value);
            if ($('favorecidoAd_' + idx).value.trim() == '') {
                $('favorecidoAd_' + idx).value = $('vei_prop').value;
            }
        } else if (tipo == 'p' && $('tipoPagto_' + idx).value == 's') {
            $('contaAd_' + idx).value = ($('prop_conta2').value != '' ? $('prop_conta2').value : $('prop_conta1').value);
            $('agenciaAd_' + idx).value = ($('prop_conta2').value != '' ? $('prop_agencia2').value : $('prop_agencia1').value);
            $('favorecidoAd_' + idx).value = ($('prop_conta2').value != '' ? $('prop_favorecido2').value : $('prop_favorecido1').value);
            $('banco_' + idx).value = ($('prop_conta2').value != '' ? $('prop_banco2').value : $('prop_banco1').value);
            $('tipoContaPgto_' + idx).value = ($('prop_tipo_conta2').value.trim() != '' ? $('prop_tipo_conta2').value : $('prop_tipo_conta1').value);
            if ($('favorecidoAd_' + idx).value.trim() == '') {
                $('favorecidoAd_' + idx).value = $('vei_prop').value;
            }
        } else {
            $('contaAd_' + idx).value = '';
            $('agenciaAd_' + idx).value = '';
            $('favorecidoAd_' + idx).value = '';
            $('banco_' + idx).value = '1';
        }
    }
}

function baixar(nf) {
    tryRequestToServer(function () {
        window.open("./bxcontaspagar?acao=consultar&" +
                "idfornecedor=" + $('idproprietarioveiculo').value + "&fornecedor=" + $('vei_prop').value + "&" +
                "dtinicial=" + dataAtual + "&dtfinal=" + dataAtual + "&baixado=false" + "&idfilial=" + $('filial').value + "&" +
                "fi_abreviatura=" + getTextSelect($('filial')) + "&mostrarSaldo=true" + "&nf=" + nf + "&valor1=0.00&valor2=0.00&tipoData=dtvenc", "Despesa", "top=8,resizable=yes,status=1,scrollbars=1")
    });
}

function verDesp(id) {
    var idDesp = id;
    if (id == 0) {
        idDesp = $('idDespesaCC').value;
    }
    if (true) {
        window.open("./caddespesa?acao=editar&id=" + idDesp + "&ex=false", "Despesa", "top=0,resizable=yes,status=1,scrollbars=1");
    } else {
        alert('Você não tem acesso a tela de despesa, favor entrar em contato com o seu supervisor.');
    }
}

function ApropriacaoDespesa(idApropriacao, conta, apropriacao, idVeiculo, veiculo, valor, incluindo, idUnd, und) {
    this.idApropriacao = (idApropriacao == null || idApropriacao == undefined ? 0 : idApropriacao);
    this.conta = (conta == null || conta == undefined ? 0 : conta);
    this.apropriacao = (apropriacao == null || apropriacao == undefined ? "" : apropriacao);
    this.idVeiculo = (idVeiculo == null || idVeiculo == undefined ? 0 : idVeiculo);
    this.veiculo = (veiculo == null || veiculo == undefined ? "" : veiculo);
    this.valor = (valor == null || valor == undefined ? 0 : valor);
    this.incluindo = (incluindo == null || incluindo == undefined ? true : incluindo);
    this.idUnd = (idUnd == null || idUnd == undefined ? "" : idUnd);
    this.und = (und == null || und == undefined ? "" : und);
}

function verContaDespesa(index) {
    if ($("tipoDesp_" + index).value == "a") {
        visivel($("trContaDespesa_" + index));
    } else {
        invisivel($("trContaDespesa_" + index));
    }
}

function calcularDespesaValor(indexDesp, indexPlano) {
    var vlDesp = $("valorDespesa_" + indexDesp);
    var maxPlano = parseInt($("maxPlano_" + indexDesp).value);
    var valor = 0;

    for (var i = 1; i <= maxPlano; i++) {
        if ($("valorAprop_" + indexDesp + "_" + indexPlano) != null) {
            valor += parseFloat(colocarPonto($("valorAprop_" + indexDesp + "_" + i).value));
        }
    }
    vlDesp.value = colocarVirgula(valor);
}

function removerDespesaAgregada(index) {
    if (confirm("Deseja remover a despesa da \'Nota Fiscal\':" + $("notaFiscal_" + index).value + "?")) {
        if (confirm("Tem certeza?")) {

        }
    }
}

//Remover DOM de Plano de Custo
function removerPlanoCusto(despesa, linha) {
    if (confirm("Deseja mesmo excluir este Plano de Custo ?")) {
        Element.remove('tr_' + despesa + "_" + linha);
    }
}

//remover DOM Despesa
function removerDespesas(index) {
    var idDespesa = 0;
    if (confirm("Deseja mesmo excluir este Despesa ?")) {
        if (confirm("Tem Certeza?")) {
            $("tr_" + index).style.display = "none";
            $("trPlanoCusto_" + index).style.display = "none";
            idDespesa = $("idDepesa_" + index).value;  
            $("deletado_"+index).value = true;
            alert('Despesa Agregada removido com sucesso!');
               
        }
    }
}
/**
 * Limpando as listas antes de adicionar uma lista nova.
 * @returns {undefined}
 */
function removeAllDocum() {
    for (var i = 1; i <= countDocum; i++) {
        if ($("trDocum_" + i) != null) {
            Element.remove($("trDocum_" + i));
            Element.remove($("trDocumManifMaster_" + i));
        }
    }
    listadocumento = null;
    countDocum = 0;
}

function verificaManifs() {
    var retorno = "";
    for (i = 1; i <= countDocum; ++i) {
        retorno += (retorno == "" ? "" : ",") + $("idDocumento_" + i).value + '!!!' + $("tipoDocumento_" + i).value + '!!!' + $("idDocumento_" + i).value;
    }
    return (retorno);
}

function verSeTemRota() {
    if ($('rota').value == '0' && $('rota').length == 1) {
        alert('ATENÇÃO: Para carregar as rotas, primeiro deverá selecionar os documentos do contato de frete e em seguida clicar no botão (atualizar) ao lado.\r\n\r\nOBS: Caso o documento já tenha sido informado verifique se existe uma rota cadastrada para a origem e destino do documento.');
    }
}

function calculaValorTonelada() {
    if ($('vlTonelada').value == "") {
        $('vlTonelada').value = "0,00";
    }
    if ($('vlTonelada').readOnly == false) {

        $('vlFreteMotorista').value = colocarVirgula(colocarPonto($('vlTonelada').value) * $('pesoTonelada').value);
        calculaImpostos();
        validacaoValorTonelada();
    }
}

function calculaValorKM() {
    try {
        var retorno = 0;

        if ($('valorPorKM').value == "") {
            $('valorPorKM').value = "0,00";
        }
        if ($('quantidadeKm').value == "") {
            $('quantidadeKm').value = "0";
        }

        var valorPorKm = pontoParseFloat($('valorPorKM').value);
        var qtdPorKm = parseFloat($('quantidadeKm').value);

        //            if(valorPorKm > 0 && parseFloat($('vlTonelada').value) == 0){
        retorno = (valorPorKm * qtdPorKm);
        $('vlFreteMotorista').value = colocarVirgula(retorno);
        //        validacaoValorKM();

        return retorno;
    } catch (e) {
        console.log(e);
        alert(e);
    }

}

function validacaoValorKM() {
    if ($("valorDoKM").value == 0 && $("vlTonelada").value == 0 && $("quantidadeKm").value == 0) {
        $("valorPorKM").className = "inputtexto";
        $("valorPorKM").readOnly = false;
    } else {
        $("valorPorKM").readOnly = true;
        $("valorPorKM").className = "inputReadOnly";
        $("vlTonelada").readOnly = true;
        $("vlTonelada").removeClassName("inputTexto");
        $("vlTonelada").addClassName("inputReadOnly");
    }
    liberarCamposQuantidade();
}

function bloquearCamposValorContrato() {
    if (colocarPonto($('vlFreteMotorista').value) == 0) {
        habilitarCampo('vlFreteMotorista');
        habilitarCampo('vlTonelada');
        habilitarCampo('valorPorKM');
        habilitarCampo('quantidadeKm');
        if (colocarPonto($("valorPorKM").value) > 0 && $("quantidadeKm").value > 0) {
            habilitarCampo('valorPorKM');
            habilitarCampo('quantidadeKm');
        }
    } else if (colocarPonto($('vlFreteMotorista').value) > 0) {
        desabilitarCampo('vlTonelada');
        desabilitarCampo('valorPorKM');
        desabilitarCampo('quantidadeKm');
        if (colocarPonto($("valorPorKM").value) > 0 && $("quantidadeKm").value > 0) {
            habilitarCampo('valorPorKM');
            habilitarCampo('quantidadeKm');
        }
    } else {
        desabilitarCampo('vlTonelada');
        desabilitarCampo('valorPorKM');
        desabilitarCampo('quantidadeKm');
    }

}

function liberarCamposValorPorKM() {

    if (colocarPonto($('valorPorKM').value) == 0) {
        habilitarCampo('vlTonelada');
        habilitarCampo('valorPorKM');
        habilitarCampo('vlFreteMotorista');
        habilitarCampo('quantidadeKm');
        if (colocarPonto($('vlTonelada').value) > 0) {
            desabilitarCampo('valorPorKM');
            desabilitarCampo('vlFreteMotorista');
            desabilitarCampo('quantidadeKm');
        }
    } else if (colocarPonto($('valorPorKM').value) > 0 && colocarPonto($('quantidadeKm').value) > 0) {
        desabilitarCampo('vlTonelada');
        habilitarCampo('valorPorKM');
        desabilitarCampo('vlFreteMotorista');
        habilitarCampo('quantidadeKm');
    }

}

function bloquearCamposValorTonelada() {
    if ($('vlTonelada').value != "") {
        if (colocarPonto($('vlTonelada').value) > 0) {
            $("vlFreteMotorista").removeClassName("inputTexto");
            $("vlFreteMotorista").addClassName("inputReadOnly");
            $('vlFreteMotorista').readOnly = true;
            $("valorPorKM").readOnly = true;
            $("valorPorKM").className = "inputReadOnly";
            $("quantidadeKm").readOnly = true;
            $("quantidadeKm").className = 'inputReadOnly';
        } else {
            $("vlFreteMotorista").removeClassName("inputReadOnly");
            $("vlFreteMotorista").addClassName("inputTexto");
            $('vlFreteMotorista').readOnly = false;
            $("valorPorKM").readOnly = false;
            $("valorPorKM").className = "inputTexto";
            $("quantidadeKm").readOnly = false;
            $("quantidadeKm").className = 'inputTexto';
        }
    } else {
        $("vlFreteMotorista").removeClassName("inputReadOnly");
        $("vlFreteMotorista").addClassName("inputTexto");
        $('vlFreteMotorista').readOnly = false;
        $("valorPorKM").readOnly = false;
        $("valorPorKM").className = "inputTexto";
        $("quantidadeKm").readOnly = false;
        $("quantidadeKm").className = 'inputTexto';
    }
}

function solicitaAutorizacao(isEditar) {
    if ($('solicitarAutorizacao').checked) {
        $('lbMotivoAutorizacao').style.display = '';
        $('motivoSolicitacao').style.display = '';
        habilitarCampo('vlFreteMotorista');
        habilitarCampo('vlTonelada');
        habilitarCampo('vlUnitarioDiaria');
        habilitarCampo('valorPorKM');
    } else {
        //Só pode recalcular os valores dos campos abaixo quando não for o carregar.
        //Quando não for o carregar e o solicitar autorização for false.
        if (countPgto != 0 && !isEditar) {
            $('vlFreteMotorista').value = "0,00";
            $('valorPorKM').value = "0,00";
            $('vlTonelada').value = "0,00";
            $('quantidadeKm').value = "0,00";

            if ($("rota").value != "0") {
                getRota();
            }
            calculaImpostos();
        }

        $('lbMotivoAutorizacao').style.display = 'none';
        $('motivoSolicitacao').style.display = 'none';
        habilitarCampo('quantidadeKm');
    }
    validacaoValorTonelada();
}

var pedagioCalculado = false;
function getCalcularPedagioNdd() {
    var idPercurso = $("percurso").value;
    espereEnviar("Aguarde...", true);

    if ($('rota').value == '0') {
        alert("Para calcular o 'Pedágio' a rota deverá ser informada!");
        espereEnviar("Aguarde...", false);
        return false;
    }
//            if ($('percurso').value == '0'){
//                alert("Para calcular o 'Pedágio' o percurso deverá ser informado!");
//                espereEnviar("Aguarde...",false);
//                return false;
//            }

    if (pedagioCalculado == true) {
        alert("Esse 'Pedágio' já foi calculado!");
        espereEnviar("Aguarde...", false);
        return false;
    }

    var qtdRotas = $("idRota").value.split("!!").length;
    var ibgeCidadeOrigem;
    var ibgeCidadeDestino;
    var nomeRota;
    var idRota;
    for (var rotaPercursos = 0; rotaPercursos <= qtdRotas - 1; rotaPercursos++) {
        if ($("idRota").value.split("!!")[rotaPercursos] == $("rota").value) {
            ibgeCidadeOrigem = $("ibgeCidadeOrigem").value.split("!!")[rotaPercursos];
            ibgeCidadeDestino = $("ibgeCidadeDestino").value.split("!!")[rotaPercursos];
            nomeRota = $("nomeRota").value.split("!!")[rotaPercursos];
            idRota = $("idRota").value.split("!!")[rotaPercursos];
        }
    }

    if (categoriaNdd == '0') {
        alert("Categoria NDD inválida!");
        espereEnviar("Aguarde...", false);
        return false;
    }
    var categoriaNdd = $("categoriaNdd").value;
    if (categoriaNdd == '0') {
        alert("Categoria NDD inválida!");
        espereEnviar("Aguarde...", false);
        return false;
    }
    var codigoCategoriaNdd = $("codigoCategoriaNdd_" + categoriaNdd).value;
    var cnpjFilial = $("cnpjFilial").value;
    var cnpjContratantePamcard = $("cnpjContratantePamcard").value;

    var maxDocum = $("maxDocumento").value;
    var idmanifesto = "";
    for (var i = 1; i <= maxDocum; i++) {
        if ($("tipoDocumento_" + i).value = ("MANIFESTO")) {
            if ($("idDocumento_" + i) != null) {
                idmanifesto += "," + $("idDocumento_" + i).value;
            }
        }
    }
    idmanifesto = idmanifesto.substr(1);

    function e(transport) {
        var textoresposta = transport.responseText;
        if (textoresposta == "-1") {
            alert('Houve algum problema ao requistar o calculo do pedágio, favor tente novamente. ');
            return false;
        } else {
            var nddPedagio = jQuery.parseJSON(textoresposta).nddPedagio;
            $("lbPedagioNddCalculado").innerHTML = "R$: ";
            $("lbPedagioNddCalculado").innerHTML += colocarVirgula(nddPedagio.valor);
            if (nddPedagio.codigo != 164) {
                $("vlPedagio").value = $("lbPedagioNddCalculado").innerHTML.replace("R$: ", "");
                calcula();
                alert(nddPedagio.mensagem);
                espereEnviar("Aguarde...", false);
                return false;
            }
            espereEnviar("Aguarde...", false);
            if (confirm("Deseja abater o valor do 'Pedágio' no Total do Contrato?")) {
//                        if ($("valorPedagioCalculado").value == 0) {
//                            $("valorPedagioCalculado").value = colocarVirgula($("lbPedagioNddCalculado").innerHTML.replace("R$: ",""));
//                        }
                var valorPedagio = $("lbPedagioNddCalculado").innerHTML.replace("R$: ", "");
                $("vlFreteMotorista").value = colocarVirgula(colocarPonto($("vlFreteMotorista").value) - colocarPonto(valorPedagio));
                calculaImpostos();
                validacaoValorTonelada();
                // validacaoValorKM();
                pedagioCalculado = true;
            }
        }

    }
    new Ajax.Request("NddControlador?acao=calcularPedagioNddAjax&categoriaNdd=" + categoriaNdd + "&cnpjFilial=" + cnpjFilial + "&cnpjContratantePamcard=" + cnpjContratantePamcard + "&nomeRota=" + nomeRota + "&ibgeCidadeOrigem=" + ibgeCidadeOrigem + "&ibgeCidadeDestino=" + ibgeCidadeDestino + "&idRota=" + idRota + "&idPercurso=" + idPercurso + "&codigoCategoriaNdd=" + codigoCategoriaNdd + "&idmanifesto=" + idmanifesto, {method: 'post', onSuccess: e, onError: e});
}

function calculaDiaria() {
    if (isConfiguracaoReterImposto) {
        $('vlDiaria').value = colocarVirgula(parseFloat(colocarPonto($('qtdDiaria').value)) * parseFloat(colocarPonto($('vlUnitarioDiaria').value)));
    } else {
        $('vlDiaria2').value = colocarVirgula(parseFloat(colocarPonto($('qtdDiaria2').value)) * parseFloat(colocarPonto($('vlUnitarioDiaria2').value)));
    }
    calcula();
}


function limparPedagio() {
    pedagioCalculado = false;
    $("lbPedagioNddCalculado") != null ? $("lbPedagioNddCalculado").innerHTML = "" : "";
}

function alterarFavorecidoPedagio() {
    if ($("solucoesPedagio") != null) {
        if ($("solucoesPedagio").value == 6 || $("solucoesPedagio").value == 0) {
            $("divfavorecidoPedagio").style.display = 'none';
        } else {
            $("divfavorecidoPedagio").style.display = '';
        }
    }
}

function calculaTotalTarifas() {

    $("totalSaques").value = colocarVirgula(colocarPonto($("qtdSaques").value) * colocarPonto($("valorPorSaques").value));

    $("totalTransf").value = colocarVirgula(colocarPonto($("qtdTransf").value) * colocarPonto($("valorTransf").value));

    var valorTarifas = parseFloat(colocarPonto($("totalSaques").value)) + parseFloat(colocarPonto($("totalTransf").value));
    $("valorTarifas").value = colocarVirgula(valorTarifas);

    if ($("stUtilizacaoCfeS").value == 'P') {
        $("vlTarifas").value = $("valorTarifas").value;
        $("vlTarifas").readonly = 'true';
    }
    calcula();
    return $("vlTarifas").value;
}

function atualizarVlLiquido() {
    $("vlLiquido").value = parseFloat($("vlLiquido2").value) + parseFloat($("vlTarifas").value);
}

function removerPagamento(index) {
    var idPagto = 0;
    idPagto = $("idPgto_" + index).value;
    Element.remove($("trPgto_" + index));
    Element.remove($("trObs_" + index));
    new Ajax.Request("./ContratoFreteControlador?acao=excluirPagamentos&idPagamento=" + idPagto, {
        method: 'post',
        onSuccess: function () { },
        onFailure: function () { }
    });
}

function consultarSituacaoVeiculoEfrete() {
    var placa1 = $("vei_placa").value;
    var placa2 = $("car_placa").value;
    var placa3 = $("bi_placa").value;

    var rntrcVeiculo = ($("rntrc_veiculo").value);
    var rntrcCarr = ($("rntrc_carreta").value);
    var rntrcBitrem = ($("rntrc_bitrem").value);

    var cnpjVeiculo = $("vei_prop_cgc").value.replace(/[^0-9]/g, '');
    var cnpjCarr = $("car_prop_cgc").value.replace(/[^0-9]/g, '');
    var cnpjBi = $("bi_prop_cgc").value.replace(/[^0-9]/g, '');

    if (placa1 == "") {
        alert('Informe o veículo corretamente');
        return false;
    }

    espereEnviar("Aguarde...", true);
    function e(transport) {
        espereEnviar("Aguarde...", false);
        var textoresposta = transport.responseText;
        alert(textoresposta);
    }

    var utilizacao = $("stUtilizacaoCfeS").value;
    var idveiculo = $("idveiculo").value;

    if (utilizacao == 'E') {

        tryRequestToServer(function () {
            new Ajax.Request("EFreteControlador?acao=consultarVeiculosFrete&placa1=" + placa1 + "&placa2=" + placa2 + "&placa3=" + placa3 +
                    "&rntrcVei=" + rntrcVeiculo + "&rntrcCarr=" + rntrcCarr + "&rntrcBi=" + rntrcBitrem + "&cnpjVei=" + cnpjVeiculo + "&cnpjCarr=" + cnpjCarr +
                    "&cnpjBi=" + cnpjBi, {method: 'post', onSuccess: e, onError: e});
        });
    }
    if (utilizacao == 'G') {
        tryRequestToServer(function () {
            new Ajax.Request("PagBemControlador?acao=consultaSituacaoRntrc&idVeiculo=" + idveiculo, {method: 'post', onSuccess: e, onError: e});
        });
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
    var rotina = "carta_frete";
    var dataDe = $("dataDeAuditoria").value;
    var dataAte = $("dataAteAuditoria").value;
    var id = $("idcontratofrete").value;

    consultarLog(rotina, id, dataDe, dataAte);

}

function enviarProprietarioExpers() {

    var idProprietario = $("idproprietarioveiculo").value;

    if (idProprietario == 0) {
        alert("Escolha um Contratado!");
        return false;
    }

    espereEnviar("Aguarde...", true);
    function e(transport) {
        espereEnviar("Aguarde...", false);
        var textoresposta = transport.responseText;
        alert(textoresposta);

    }
    tryRequestToServer(function () {
        new Ajax.Request('ExpersControlador?acao=consultarProprietarioExpers&idProprietario=' + idProprietario, {method: 'post', onSuccess: e, onError: e});
    });
}

function validarBloqueioVeiculo(tipo) {
    var bloqueado = false;
    if ($("is_bloqueado").value == "t" && tipo == "veiculo") {
        setTimeout(function () {
            alert("O veículo " + $("vei_placa").value + " está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
            limparVeiculo();
            bloqueado = true;
        }, 100);
    }
    if ($("is_bloqueado").value == "t" && tipo == "carreta") {
        setTimeout(function () {
            alert("A carreta " + $("car_placa").value + " está bloqueada e não poderá ser utilizada no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
            limparCarreta();
            bloqueado = true;
        }, 100);
    }
    if ($("is_bloqueado").value == "t" && tipo == "bitrem") {
        setTimeout(function () {
            alert("O Bi-trem " + $("bi_placa").value + " está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
            limparBiTrem();
            bloqueado = true;
        }, 100);
    }
    return bloqueado;
}

function validarBloqueioVeiculoMotorista(filtrosM) {
    var bloqueado = false;
    var filtros = filtrosM;
    for (var i = 0; i <= filtros.split(",").length; i++) {
        if ($("is_moto_veiculo_bloq").value == "t" && filtros.split(",")[i] == "veiculo_motorista") {
            setTimeout(function () {
                alert("O veiculo " + $("vei_placa").value + ", vinculado ao motorista " + $("motor_nome").value + ", está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("moto_veiculo_bloq_motivo").value);
                limparVeiculo();
                bloqueado = true;
            }, 100);
        } else if ($("is_moto_carreta_bloq").value == "t" && filtros.split(",")[i] == "carreta_motorista") {
            setTimeout(function () {
                alert("A carreta " + $("car_placa").value + ", vinculada ao motorista " + $("motor_nome").value + ", está bloqueada e não poderá ser utilizada no lançamento. \r\n Motivo: " + $("moto_carreta_bloq_motivo").value);
                limparCarreta();
                bloqueado = true;

            }, 100);
        } else if ($("is_moto_bitrem_bloq").value == "t" && filtros.split(",")[i] == "bitrem_motorista") {
            setTimeout(function () {
                alert("O bi-trem " + $("bi_placa").value + ", vinculada ao motorista " + $("motor_nome").value + ", está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("moto_bitrem_bloq_motivo").value);
                limparBiTrem();
                bloqueado = true;

            }, 100);
        }
    }
    return bloqueado;
}

function carregarDadosNegociacao() {
    var maxDocs = $('maxDocumento').value;
    var idCliente = ($("idCliente_" + maxDocs) == null ? 0 : $("idCliente_" + maxDocs).value);
    var idMotorista = $("idmotorista").value;
    var origem = $("origemNegociacao").value;
    var idNegociacao = '0';
    if ((idCliente != '0' && idMotorista != '0') && origem.indexOf("cm") - 1) {
        jQuery.ajax({url: 'ContratoFreteControlador?', dataType: "text", method: "post",
            data: {
                acao: "validarCliMot",
                idMotorista: idMotorista,
                idCliente: idCliente
            },
            success: function (data) {
                var regras = jQuery.parseJSON(data);
                if (regras != null) {
                    idNegociacao = regras.negociacaoCliMot.Negociacao.id;
                    if (idNegociacao != "") {
                        alterarNegociacao(idNegociacao, "cm");
                    }
                }
            },
            error: function (data) {
                console.log("falha na requisição");
            }
        });
    }
}



/**
 *
 * @returns {Array[NegociacaoId,Origem]}
 */
function getNegociacaoAutomatica() {
    var idFilial = $("filial").value;
    var maxDocs = $('maxDocumento').value;
    var negociacaoCliente = ($("ClienteNegociacaoId_" + maxDocs) == null ? '0' : $("ClienteNegociacaoId_" + maxDocs).value);
    var negociacaoFilial = ($("negociacao_contrato_frete_" + idFilial).value == "" ? "0" : $("negociacao_contrato_frete_" + idFilial).value);
    var negociacaoMotorista = ($("negociacao_motorista").value == "" ? "0" : $("negociacao_motorista").value);
    var retorno = new Array();

    if (negociacaoFilial != "0") {
        retorno[0] = negociacaoFilial;
        retorno[1] = "fi";
    }
    if (negociacaoMotorista != "0") {
        retorno[0] = negociacaoMotorista;
        retorno[1] = "mo";
    }
    if (negociacaoCliente != "0") {
        retorno[0] = negociacaoCliente;
        retorno[1] = "cl";
    }
    if (negociacaoFilial == "0" && negociacaoMotorista == "0" && negociacaoCliente == "0") {
        retorno[0] = "0";
        retorno[1] = "ma";
    }
    return retorno;

}

function validarNegociacao(isAutomatico, valor) {
    isAutomatico = (isAutomatico == null || isAutomatico == undefined ? true : isAutomatico);//variavel que indica se vai utilizar a negociação automatica
    valor = (valor == null || valor == undefined ? "" : valor);//variavel que indica se vai utilizar a negociação automatica
    var negociacao = null;
    if (isAutomatico) {
        negociacao = getNegociacaoAutomatica();
    } else {
        negociacao = new Array();
        negociacao[0] = valor;
        negociacao[1] = "ma";
    }

    if (negociacao[1] == "cl") {
        carregarDadosNegociacao();
    }
    alterarNegociacao(negociacao[0], negociacao[1]);
}

function regrasNegociacao(id, tipo, percentual, tipoFav, pagamentoCfe, diaspag, idFpag, negociacaoAdiantamento, isValorEditavel) {
    this.id = id;
    this.tipo = tipo;
    this.percentual = percentual;
    this.tipoFav = tipoFav;
    this.pagamentoCfe = pagamentoCfe;
    this.diaspag = diaspag;
    this.idFpag = idFpag;
    this.negociacaoAdiantamento = negociacaoAdiantamento;
    this.isValorEditavel = isValorEditavel;
}

function excluirPagto(linha) {
    var tipo = $("tipoPagto_" + linha).value == "a" ? "Adiantamento" : "Saldo";
    if (confirm("Deseja mesmo excluir este " + tipo + " ?")) {
        if (confirm("Tem certeza? ")) {
            if ($("trPgto_" + linha) != null) {
                Element.remove($("trPgto_" + linha));
                Element.remove($("trObs_" + linha));
            }
        }
    }
}

function getTarifasFilial() {
    var idFilial = $("filial").value;


    function e(transport) {
        var textoresposta = transport.responseText;
        var filial = jQuery.parseJSON(textoresposta).filial;

        var adiantamento = new ContratoFretePagamento();
        adiantamento.fixo = true;

        $("controlarTarifasBancariasContratado").value = (filial.controlarTarifasBancariasContratado);
        if (filial.controlarTarifasBancariasContratado) {
            $("trTarifas").style.display = "";

        } else {
            $("trTarifas").style.display = "none";
        }
        $("qtdSaques").value = (filial.quantidadeSaquesContratoFrete);
        $("valorPorSaques").value = (filial.valorSaquesContratoFrete);
        $("qtdTransf").value = (filial.quantidadeTransferenciasContratoFrete);
        $("valorTransf").value = (filial.valorTransferenciasContratoFrete);
        $("contaID").value = (filial.contaCfe.idConta);
        var valor = calculaTotalTarifas();

        var maxPagamento = $("maxPagamento").value;
        var count = 0;
        for (var i = 1; i <= maxPagamento; i++) {
            if (filial.controlarTarifasBancariasContratado) {
                if ($("isControlarTarifasBancariasContratado_" + i) != null && $("isControlarTarifasBancariasContratado_" + i).value == 'true') {
                    removerPagamento(i);
                    addPagto(adiantamento, true);
                    count++;
                }
            } else {
                if ($("isControlarTarifasBancariasContratado_" + i) != null && $("isControlarTarifasBancariasContratado_" + i).value == 'true') {
                    removerPagamento(i);
                }
            }
        }
//                if(count==0){
//                     addPagto(adiantamento, true);
//                }
        calculaImpostos();
        bloquearCamposValorContrato();
        alterarAdiantamento();
    }
    new Ajax.Request("./ContratoFreteControlador?acao=tarifasFilial&idFilial=" + idFilial, {method: 'post', onSuccess: e, onError: e});
}

function alterarOperadoraCiot() {
    var utiCFE = ($("operadoraCiot").value == "" ? $("stUtilizacaoCfeS").value : $("operadoraCiot").value);

    if (utiCFE == 'N') {
        $("imgOperadoraCiot").style.display = "none";
    } else if (utiCFE == 'R') {
        $("imgOperadoraCiot").style.display = "";
        $("imgOperadoraCiot").src = "img/repom.png";
    } else if (utiCFE == 'D') {
        $("imgOperadoraCiot").style.display = "";
        $("imgOperadoraCiot").src = "img/ndd.png";
    } else if (utiCFE == 'P') {
        $("imgOperadoraCiot").style.display = "";
        $("imgOperadoraCiot").src = "img/pamcard.png";
    } else if (utiCFE == 'E') {
        $("imgOperadoraCiot").style.display = "";
        $("imgOperadoraCiot").src = "img/efrete.png";
    } else if (utiCFE == 'X') {
        $("imgOperadoraCiot").style.display = "";
        $("imgOperadoraCiot").src = "img/expers.png";
    } else if (utiCFE == 'G') {
        $("imgOperadoraCiot").style.display = "";
        $("imgOperadoraCiot").src = "img/pagbem.png";
    } else if (utiCFE == 'A') {
        $("imgOperadoraCiot").style.display = "";
        $("imgOperadoraCiot").src = "img/targetmp.png";
    }
}

function abrirLocalizaCliente() {
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
        alert('O veículo deverá ser informado antes de escolher o cliente!');
        return false;
    }
    launchPopupLocate('./localiza?acao=consultar&idlista=86&fecharJanela=true&paramaux=' + idVeiculoTabela + ($('idcidadedestino').value == '0' ? "" : ' &paramaux2=' + $('idcidadedestino').value) + '&paramaux3=' + $('tipoProduto').value, 'Consignatario');
}

function abrirLocalizaCidade() {
    if ($('idconsignatario').value != '0') {
        alert('Para escolher a cidade o cliente NÃO pode estar preenchido, limpe o campo do cliente e tente novamente!');
        return false;
    }
    launchPopupLocate('./localiza?acao=consultar&idlista=12&fecharJanela=true', 'Cidade_Destino');
}
function abrirLocalizaCarreta() {
    launchPopupLocate('./localiza?acao=consultar&idlista=9&fecharJanela=true', 'Carreta')
}
function abrirLocalizaBiTrem() {
    launchPopupLocate('./localiza?acao=consultar&idlista=51&fecharJanela=true', 'Bitrem')
}

function abrirLocalizaPlanoCusto(indexDespesa, indexPlano) {
    $("indexAux").value = indexDespesa + "_" + indexPlano;
    launchPopupLocate('./localiza?acao=consultar&idlista=20&fecharJanela=true', 'Plano')
}

function abrirLocalizarFornecedor(index) {
    $("indexAux").value = index;
    launchPopupLocate('./localiza?acao=consultar&idlista=21&fecharJanela=true', 'Fornecedor')
}
function abrirLocalizaAgente(index) {
    $("indexAux").value = index;
    launchPopupLocate('./localiza?acao=consultar&idlista=16&fecharJanela=true', 'Agente_Pagador')
}
function abrirLocalizarHistorico(index) {
    $("indexAux").value = index;
    launchPopupLocate('./localiza?acao=consultar&idlista=14&fecharJanela=true', 'Historico')
}
function abrirLocalizarVeiculo(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(24, "Veiculo", "");
}
function abrirLocalizarUndCusto(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(39, "Unidade_de_Custo", "");
}

//Caluclar duplicata de talão de cheque
function calcularTalaoCheque(index) {
    var maxAdiantamento = $("maxPagamento").value;
    var adiantamento = $("documPgto2_" + index).value;

    for (i = 1; i < maxAdiantamento; i++) {
        //Se o adiantamento for diferente de 0
        if (adiantamento != 0) {
            //Se o index for diferente do atual que no caso seria ele mesmo
            if (i != index) {
                //Se a forma de pagamento for igual a cheque
                if ($("formaPagto_" + i).value == "3") {
                    //Se o valor do adiantamento for igual
                    if (adiantamento == $("documPgto2_" + i).value) {
                        $("documPgto2_" + index).value = "";
                        alert("Você não pode lançar 2 adiantamentos com o mesmo número de documento! ");
                        return false;
                    }

                }
            }
        }
    }
}

function carregarNumeroTacAgregBase() {

    $("normal").disabled = false;//disabilitado = false... ele esta habilitado..
    $("baseTacAgregado").value = '0';//limpa antes de obter o valor, para caso ele não tenha o
    // tac base, ele não ficar com o anterior.

    var idproprietarioveiculo = $("idproprietarioveiculo").value;
    var idFrete = parseInt($("idcontratofrete").value, 10);

    new Ajax.Request('ContratoFreteControlador?acao=carregarContratoExistente' +
            '&idProp=' + idproprietarioveiculo,
            {
                method: 'get',
                onSuccess: function (transport) {
                    var response = transport.responseText;
                    var resposta = parseInt(response, 10);

                    if (resposta != 0 && resposta != null && resposta != idFrete) {
                        //alert("Contrato já existente para esse Proprietário!")
                        alert("Atenção! Já existe CIOT gerado para o contrato de frete " + resposta + ". ");
                        $("baseTacAgregado").value = resposta;
                        $("normal").disabled = true;
                        $("agregado").checked = true;
                    }
                },
                onFailure: function () {

                    return true;
                }
            });
}

function Negociacao(valor, descricao, tipoCalculo, regras) {
    this.valor = valor;
    this.descricao = descricao;
    this.tipoCalculo = tipoCalculo;
    this.regras = regras;
}

function Filial(id, valorTotal, isFlagOrigem, nomeFilial, totalCteCIF, filialDestino) {
    this.filialId = id;
    this.valorTotal = valorTotal;
    this.isFlagOrigem = isFlagOrigem;
    this.nomeFilial = nomeFilial;
    this.totalCteCIF = totalCteCIF;
    this.filialDestino = filialDestino;
}

function FilialDestino(id, valorTotal, isFlagOrigem, nomeFilial) {
    this.filialIdDest = id;
    this.valorTotalDest = valorTotal;
    this.isFlagOrigemDest = isFlagOrigem;
    this.nomeFilialDest = nomeFilial;
}

function pagtoLivre(tipo) {
    for (var i = 1; i <= countPgto; i++) {
        if ($("idPgto_" + i) != null && $("tipoPagto_" + i).value == tipo && $("despesaPagId_" + i).value == '0') {
            return i;
        }
    }
    return null;
}

function getCalcularPedagioTarget() {
    var idPercurso = $("percurso").value;
    espereEnviar("Aguarde...", true);

    if ($('rota').value == '0') {
        alert("Para calcular o 'Pedágio' a rota deverá ser informada!");
        espereEnviar("Aguarde...", false);
        return false;
    }

    if (pedagioCalculado == true) {
        alert("Esse 'Pedágio' já foi calculado!");
        espereEnviar("Aguarde...", false);
        return false;
    }

    var qtdRotas = $("idRota").value.split("!!").length;
    var idRota;

    for (var rotaPercursos = 0; rotaPercursos <= qtdRotas - 1; rotaPercursos++) {
        if ($("idRota").value.split("!!")[rotaPercursos] == $("rota").value) {
            idRota = $("idRota").value.split("!!")[rotaPercursos];
        }
    }

    var categoriaNdd = $("categoriaNdd").value;

    if (categoriaNdd == '0') {
        alert("Categoria Target inválida!");
        espereEnviar("Aguarde...", false);
        return false;
    }

    var codigoCategoriaNdd = $("codigoCategoriaNdd_" + categoriaNdd).value;
    var modoPagamentoPedagio = jQuery('#solucoesPedagio option:selected').text().split('-')[0];

    if (modoPagamentoPedagio == '7') {
        modoPagamentoPedagio = '1'; // Cartão Transportes Bradesco Target
    } else {
        modoPagamentoPedagio = '4'; // Sem Parar / Via Fácil
    }

    function e(transport) {
        var textoresposta = transport.responseText;

        var targetPedagio = jQuery.parseJSON(textoresposta).targetPedagio;

        if (targetPedagio.erro != null) {
            alert(targetPedagio.erro.mensagemErro);

            espereEnviar("Aguarde...", false);

            return false;
        } else {
            $("lbPedagioNddCalculado").innerHTML = "R$: ";
            $("lbPedagioNddCalculado").innerHTML += colocarVirgula(targetPedagio.valorPedagioTotal);

            espereEnviar("Aguarde...", false);

            if (confirm("Deseja abater o valor do 'Pedágio' no Total do Contrato?")) {
                var valorPedagio = $("lbPedagioNddCalculado").innerHTML.replace("R$: ", "");
                $("vlFreteMotorista").value = colocarVirgula(colocarPonto($("vlFreteMotorista").value) - colocarPonto(valorPedagio));
                calculaImpostos();
                validacaoValorTonelada();
                pedagioCalculado = true;
            }
        }

    }

    new Ajax.Request("TargetControlador?acao=calcularPedagioTargetAjax&codigoCategoriaTarget=" + codigoCategoriaNdd + "&idRota=" + idRota + "&modoPagamentoPedagio=" + modoPagamentoPedagio, {method: 'post', onSuccess: e, onError: e});
}

function calcularTabelaMotoristaCfe() {
    var percentualValor = parseFloat($('percentual_valor_cte_calculo_cfe').value);
    var vlFrete = 0;
    
    if (percentualValor !== 0) {
        $('detalhesTabRota').style.display = "";
        $('tabTipoCalculo').innerHTML = 'Tipo cálculo: tabela de motorista';
        
        var tbValorMeradoria = parseFloat(colocarPonto($('inTotalValorNota').value)); // Pelo total da prestação
        var tbValorFrete = parseFloat(colocarPonto($('inTotalValorFrete').value)); // Pelo total da prestação
        var tbValorPesoCte = parseFloat(colocarPonto($("totalValorPesoCte").value)); // Pelo frete peso
        var tbValorFreteCte = parseFloat(colocarPonto($("totalValorFreteCte").value)); // Pelo frete valor
        var campoCalculoMotorista = $('calculo_valor_contrato_frete').value;
        var tipoCalculoPercentualValorCFe = $('tipo_calculo_percentual_valor_cfe').value;
        
        if(campoCalculoMotorista === 'nf'){
            if ($('rota_is_nfe_por_entrega').value === 'false') {
                vlFrete = tbValorMeradoria * (percentualValor / 100);
                $('tabValorCalculo').innerHTML = 'Valor tabela: ' + percentualValor + '% sobre o total da Mercadoria. ';
            } else {
                var valorDaNota = getValorNotas(percentualValor, parseFloat($('motorista_valor_minimo').value));
                vlFrete = valorDaNota;
                $('tabValorCalculo').innerHTML = 'Valor tabela: ' + percentualValor + '% NF-e por Entrega.';
            }
        }else if (campoCalculoMotorista === 'ct') {
                if(tipoCalculoPercentualValorCFe === 'tp') {
                    // tp = pelo total da prestação
                    vlFrete = tbValorFrete * (percentualValor / 100);

                    $('tabValorCalculo').innerHTML = 'Valor tabela: ' + percentualValor + '% sobre o total da prestação.';
                } else if (tipoCalculoPercentualValorCFe === 'fp') {
                    // fp = pelo frete peso
                    vlFrete = tbValorPesoCte * (percentualValor / 100);

                    $('tabValorCalculo').innerHTML = 'Valor tabela: ' + percentualValor + '% sobre o frete peso.';
                } else if (tipoCalculoPercentualValorCFe === 'fv') {
                    // fv = pelo frete valor
                    vlFrete = tbValorFreteCte * (percentualValor / 100);

                    $('tabValorCalculo').innerHTML = 'Valor tabela: ' + percentualValor + '% sobre o frete valor.';
                }
            }
        }

        if (vlFrete < parseFloat($('motorista_valor_minimo').value)) {
            vlFrete = parseFloat($('motorista_valor_minimo').value);
            $('tabValorCalculo').innerHTML = 'Valor mínimo: R$ ' + parseFloat($('motorista_valor_minimo').value).toFixed(2) + '.';
        }

        $('vlFreteMotorista').value = roundABNT(vlFrete);
}

function carregarAbastecimentos() {
    jQuery.post(homePath + '/ContratoFreteControlador', {
            'acao': 'carregarAbastecimentos',
            'idveiculo': jQuery("#idveiculo").val()
        }, function (data) {
            var obj = JSON.parse(data);
            jQuery('#abastecimentos').val(parseFloat(obj['total_abastecimento']).toFixed(2));
            jQuery('#lbAbastecimento').text(obj['abastecimentos'].join(', '));
            jQuery('#ids_abastecimentos').val(obj['abastecimentos_ids'].join(','));
        }
    );
}


function getValorNotas(percentualValor, valorMinimo) {

    var idsColeta = "";
    var idsRomaneio = "";
    var idsManifesto = "";

    for (i = 1; i <= countDocum; ++i) {
        if ($("tipoDocumento_" + i).value === 'MANIFESTO') {
            if (idsManifesto === "") {
                idsManifesto = $("idDocumento_" + i).value;
            } else {
                idsManifesto += "," + $("idDocumento_" + i).value;
            }
        } else if ($("tipoDocumento_" + i).value === 'COLETA') {
            if (idsColeta === "") {
                idsColeta = $("idDocumento_" + i).value;
            } else {
                idsColeta += "," + $("idDocumento_" + i).value;
            }
        } else if ($("tipoDocumento_" + i).value === 'ROMANEIO') {
            if (idsRomaneio === "") {
                idsRomaneio = $("idDocumento_" + i).value;
            } else {
                idsRomaneio += "," + $("idDocumento_" + i).value;
            }
        }
    }

    var valorDaNota = 0;

    jQuery.ajax({
        url: 'ContratoFreteControlador',
        type: 'POST',
        async: false,
        data: {
            'acao': 'carregarValorNotas',
            'idsManifesto': idsManifesto,
            'idsColeta': idsColeta,
            'idsRomaneio': idsRomaneio,
            'idsCTRC': ''
        },
        success: function (data, textStatus, jqXHR) {
            if (data) {
                data = JSON.parse(data);

                var valorNota = 0;
                jQuery.each(data, function (index, nota) {
                    valorNota = nota.valor * (percentualValor / 100);

                    if (valorNota < parseFloat(valorMinimo)) {
                        valorNota = parseFloat(valorMinimo);
                    }

                    valorDaNota += parseFloat(valorNota);
                });
            }
        }
    });
    return valorDaNota;
}

function abrirDespesaFechamentoAgregado(despesaId) {
    tryRequestToServer(function () {
        window.open("./caddespesa?acao=editar&id=" + despesaId + "&podeExcluir=false", 'Despesa_Fechamento_Agregado', 'top=80,left=0,height=400,width=1000,resizable=yes,status=1,scrollbars=1,fullscreen=yes');
    });
}

function abrirDespesaFechamentoAgregado(despesaId) {
    tryRequestToServer(function () {
        window.open("./caddespesa?acao=editar&id=" + despesaId + "&podeExcluir=false", 'Despesa_Fechamento_Agregado', 'top=80,left=0,height=400,width=1000,resizable=yes,status=1,scrollbars=1,fullscreen=yes');
    });
}

function limparCidadeOrigem() {
    $('id-cidade-origem').value = "";
    $('cidade-origem').value = "";
    $('uf-origem').value = "";
    $('cep-origem').value = "";
}

function limparCidadeDestino() {
    $('id-cidade-destino').value = "";
    $('cidade-destino').value = "";
    $('uf-destino').value = "";
    $('cep-destino').value = "";
}

function getAjudaDistancia() {
    alert("OBS: Se não preencher a distância, será enviado para ANTT a distância cadastrada na rota informada no contrato de frete.");
}