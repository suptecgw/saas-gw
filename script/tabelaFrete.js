/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

//      JS utilizado em cadorcamento.jsp

function getGris(percGris, valorMercadoria, valorMinimoGris, formula, tipoFrete, peso, volumes, pallets, km,
        tipoVeiculo, considerarMaiorPeso, baseCubagem, metro, entregas, tipoTransporte,
        tipoIncluiIcms, aliquotaIcms, formaArredondamento, pagador, freteRedespacho, icmsRedespacho) {
    //Calculo do gris.
    var vlGris = 0;
    if (formula != null && formula != undefined && formula.trim() != '') {
        vlGris = compilaFormula(formula, tipoFrete, peso, valorMercadoria, volumes, pallets, km, tipoVeiculo, 
                        considerarMaiorPeso, baseCubagem, metro, entregas, tipoTransporte, 0, 0, 0, 
                        formaArredondamento, pagador, freteRedespacho, icmsRedespacho);
    } else {
        vlGris = parseFloat(percGris) / 100 * parseFloat(valorMercadoria); // perc do gris (tabelaPreco) * valor mercadoria (informado pelo cliente)
        if (vlGris < valorMinimoGris) {
            vlGris = valorMinimoGris;
        }
    }

    if (tipoIncluiIcms == 'i' && parseFloat(aliquotaIcms) != 0) {
        vlGris = parseFloat(vlGris) / (1 - (parseFloat(aliquotaIcms) / 100));
    }

    return formatoMoeda(vlGris);
}

function getIncluirIcms(incluiIcms) {

    return incluiIcms;
}

function getFreteValor(valorMercadoria, adValorEm, percentualNf, baseNfPercentual,
        valorPercentualNf, tipoFrete, tipoImpressaoPercentual,
        formulaSeguro, formulaPercentual, peso, volumes, pallets, km, tipoVeiculo, considerarMaiorPeso,
        baseCubagem, metro, isRedespacho, valorRedespacho, entregas, tipoTransporte, tipoIncluiIcms, aliquotaIcms, conciderarValorSeguro, formaArredondamento,
        pagador, freteRedespacho, icmsRedespacho) {
    conciderarValorSeguro = (conciderarValorSeguro == null || conciderarValorSeguro == undefined ? true : conciderarValorSeguro);
    //Calculo do frete valor.

    //valorMercadoria = informado pelo cliente
    //adValorEm = informado pelo banco
    //percentualNf = informado pelo banco
    //baseNfPercentual = informado pelo banco
    //valorPercentualNf = informado pelo banco
    //tipoFrete = informado pelo cliente

    var freteValor = 0;
    //tipoFrete == % nota fiscal ---------------------------------------------

    if (tipoFrete == 2) {
        var vlMercadoria = (isRedespacho ? valorRedespacho : valorMercadoria);
        if (tipoImpressaoPercentual == "v") {
            if (formulaPercentual != undefined && formulaPercentual.trim() != '') {
                freteValor = compilaFormula(formulaPercentual, tipoFrete, peso, vlMercadoria, volumes, pallets,
                        km, tipoVeiculo, considerarMaiorPeso, baseCubagem, metro, entregas,
                        tipoTransporte, 0, 0, 0, formaArredondamento,
                        pagador, freteRedespacho, icmsRedespacho);
            } else {
                // valorMercadoria menor que o valor minimo
                if (parseFloat(vlMercadoria) <= parseFloat(baseNfPercentual)) {
                    freteValor = parseFloat(valorPercentualNf);
                } else {
                    // valorMercadoria * percentual da nota fiscal
                    freteValor = parseFloat(vlMercadoria) * parseFloat(percentualNf) / 100;
                }
            }
        }
    }
    //valorMervadoria * percentual de adValorEm
    var vlSeguro = 0;
    if (formulaSeguro != null && formulaSeguro != undefined && formulaSeguro.trim() != '') {
        vlSeguro = compilaFormula(formulaSeguro, tipoFrete, peso, valorMercadoria, volumes, pallets, km,
                tipoVeiculo, considerarMaiorPeso, baseCubagem, metro, entregas, tipoTransporte, 0, 0, 0,
                formaArredondamento, pagador, freteRedespacho, icmsRedespacho);
    } else {
        vlSeguro = parseFloat(valorMercadoria) * parseFloat(adValorEm) / 100;
    }

    if (conciderarValorSeguro) {
        freteValor += parseFloat(vlSeguro);
    }

    if (tipoIncluiIcms == 'i' && parseFloat(aliquotaIcms) != 0) {
        freteValor = parseFloat(freteValor) / (1 - (parseFloat(aliquotaIcms) / 100));
    }

    return formatoMoeda(freteValor);
}

function getPedagio(peso, valorPedagio, qtdQuiloPedagio, tipoFrete, pesoCubado, formula, valorMercadoria, volumes, pallets, km, tipoVeiculo,
        considerarMaiorPeso, baseCubagem, metro, entregas, tipoTransporte, tipoIncluiIcms, aliquotaIcms,
        formaArredondamento, pagador, freteRedespacho, icmsRedespacho) {
    //Calculo do valor do pedágio.

    //peso = informado pelo cliente
    //valorPedagio = informado pelo banco
    //qtdQuiloPedagio = informado pelo banco
    //tipoFrete = informado pelo cliente
    //pesoCubado = informado pelo cliente

    var vlPedagio = 0;
    if (formula != null && formula != undefined && formula.trim() != '') {

        vlPedagio = compilaFormula(formula, tipoFrete, peso, valorMercadoria, volumes, pallets, km, tipoVeiculo,
                considerarMaiorPeso, baseCubagem, metro, entregas, tipoTransporte, 0, 0, 0, formaArredondamento,
                pagador, freteRedespacho, icmsRedespacho);
    } else {

        if (formaArredondamento == 'a') {
            peso = Math.round(peso);
        } else if (formaArredondamento == 'c') {
            peso = Math.ceil(peso);
        }

        var pesoPedagio = peso;
        if (tipoFrete == '1') {
            pesoPedagio = pesoCubado;
        }
        var qtdQuiloPorPeso = (pesoPedagio == 0 ? 0 : Math.ceil(pesoPedagio / qtdQuiloPedagio)); //caso a divisão não retorne inteiro ele arredonda
        vlPedagio = qtdQuiloPorPeso * valorPedagio;
    }

    if (tipoIncluiIcms == 'i' && parseFloat(aliquotaIcms) != 0) {
        vlPedagio = parseFloat(vlPedagio) / (1 - (parseFloat(aliquotaIcms) / 100));
    }

    return formatoMoeda(vlPedagio);
}

function getOutros(valorOutros, formula, tipoFrete, peso, valorMercadoria, volumes, pallets, km,
        tipoVeiculo, considerarMaiorPeso, baseCubagem, metro, entregas, tipoTransporte,
        tipoIncluiIcms, aliquotaIcms, formaArredondamento, pagador, freteRedespacho, icmsRedespacho) {
    //valor de outros. - não preceisa de calculo
    //valorOutros = informado pelo banco
    var vlOutros = 0;
    if (formula != null && formula != undefined && formula.trim() != '') {
        vlOutros = compilaFormula(formula, tipoFrete, peso, valorMercadoria, volumes, pallets, km, tipoVeiculo, considerarMaiorPeso,
                baseCubagem, metro, entregas, tipoTransporte, 0, 0, 0,
                formaArredondamento, pagador, freteRedespacho, icmsRedespacho);
    } else {
        vlOutros = (valorOutros == undefined ? 0 : valorOutros);
    }

    if (tipoIncluiIcms == 'i' && parseFloat(aliquotaIcms) != 0) {
        vlOutros = parseFloat(vlOutros) / (1 - (parseFloat(aliquotaIcms) / 100));
    }

    return formatoMoeda(vlOutros);
}

function getTDE(formula, tipoFrete, peso, valorMercadoria, volumes, pallets, km, tipoVeiculo, considerarMaiorPeso, baseCubagem,
        metro, entregas, tipoTransporte, valorTotalFreteSemTDE, valorFretePeso, valorFreteValor,
        formaArredondamento, tipoIncluiIcms, aliquotaIcms, pagador, freteRedespacho, icmsRedespacho) {
    //valor de outros. - não preceisa de calculo
    //valorOutros = informado pelo banco
    var vlTDE = 0;
    if (formula != null && formula != undefined && formula.trim() != '') {
        vlTDE = compilaFormula(formula, tipoFrete, peso, valorMercadoria, volumes, pallets, km, tipoVeiculo,
                considerarMaiorPeso, baseCubagem, metro, entregas, tipoTransporte, valorTotalFreteSemTDE, valorFretePeso,
                valorFreteValor, formaArredondamento, pagador, freteRedespacho, icmsRedespacho);
    }
    if (tipoIncluiIcms == 'i' && parseFloat(aliquotaIcms) != 0) {
        vlTDE = parseFloat(vlTDE) / (1 - (parseFloat(aliquotaIcms) / 100));
    }
    return formatoMoeda(vlTDE);
}

function getTaxaFixa(valorTaxaFixa, formula, tipoFrete, peso, valorMercadoria, volumes, pallets, km, tipoVeiculo,
        considerarMaiorPeso, baseCubagem, metro, entregas, tipoTransporte, limitePeso, excedenteTaxa, tipoIncluiIcms,
        aliquotaIcms, formaArredondamento, pagador, freteRedespacho, icmsRedespacho) {
    //valor da taxa fixa. - não preceisa de calculo
    //valorTaxaFixa = informado pelo banco

    var pesoTaxado = getPesoTaxado(tipoTransporte, baseCubagem, metro, considerarMaiorPeso, peso, formaArredondamento);

    var vlTaxa = 0;
    if (formula != null && formula != undefined && formula.trim() != '') {
        vlTaxa = compilaFormula(formula, tipoFrete, peso, valorMercadoria, volumes, pallets, km, tipoVeiculo, considerarMaiorPeso,
                baseCubagem, metro, entregas, tipoTransporte, 0, 0, 0,
                formaArredondamento, pagador, freteRedespacho, icmsRedespacho);
    } else {
        vlTaxa = (valorTaxaFixa == undefined ? 0 : valorTaxaFixa);
        if (parseFloat(pesoTaxado) > parseFloat(limitePeso)) {
            vlTaxa = parseFloat(vlTaxa) + ((parseFloat(pesoTaxado) - parseFloat(limitePeso)) * parseFloat(excedenteTaxa));
        }
    }

    if (tipoIncluiIcms == 'i' && parseFloat(aliquotaIcms) != 0) {
        vlTaxa = parseFloat(vlTaxa) / (1 - (parseFloat(aliquotaIcms) / 100));
    }

    return formatoMoeda(vlTaxa);
}

function getValorDespacho(valorDespacho, formula, tipoFrete, peso, valorMercadoria, volumes, pallets, km,
        tipoVeiculo, considerarMaiorPeso, baseCubagem, metro, entregas, tipoTransporte,
        tipoIncluiIcms, aliquotaIcms, formaArredondamento, pagador, freteRedespacho, icmsRedespacho) {
    //valor do despacho. - não preceisa de calculo
    //valorDespacho = informado pelo banco
    var vlDespacho = 0;
    if (formula != null && formula != undefined && formula.trim() != '') {
        vlDespacho = compilaFormula(formula, tipoFrete, peso, valorMercadoria, volumes, pallets, km,
                tipoVeiculo, considerarMaiorPeso, baseCubagem, metro, entregas, tipoTransporte, 0, 0, 0,
                formaArredondamento, pagador, freteRedespacho, icmsRedespacho);
    } else {
        vlDespacho = (valorDespacho == undefined ? 0 : valorDespacho);
    }

    if (tipoIncluiIcms == 'i' && parseFloat(aliquotaIcms) != 0) {
        vlDespacho = parseFloat(vlDespacho) / (1 - (parseFloat(aliquotaIcms) / 100));
    }

    return formatoMoeda(vlDespacho);
}

function getBaseCubagem(base) {
    //base. - não preceisa de calculo

    //base = informado pelo banco

    return base;
}

function getFretePeso(peso, volume, tipoFrete, valorPeso, valorVolume, baseCubagem, metro,
        valorVeiculo, valorPorFaixa, transporteTipo, valorExcedenteAereo, valorExcedente,
        maximoPesoFinal, isPrecoTonelada, tipoFretePeso, valorMaximoPeso, valorKm,
        considerarMaiorPeso, tipoImpressaoPercentual, valorMercadoria, baseNfPercentual,
        valorPercentualNf, percentualNf, pallets, km, formulaVolume, tipoVeiculo, formulaPercentual, valorPallet,
        formulaPallet, isRedespacho, valorRedespacho, entregas, formulaPeso, tipoIncluiIcms, aliquotaIcms, isRecalculando, formaArredondamento
        ,pagador, freteRedespacho, icmsRedespacho) {
    //Calculo do frete-peso.

    //peso = informado pelo cliente
    //volume = informado pelo banco
    //tipoFrete = informado pelo cliente
    //valorPeso = informado pelo banco
    //valorVolume = informado pelo banco
    //baseCubagem = informado pelo banco
    //metro = informado pelo cliente
    //valorVeiculo = informado pelo banco
    //valorPorFaixa = informado pelo banco
    //transporteTipo = informado pelo cliente

    if (formaArredondamento == 'a') {
        peso = Math.round(peso);
    } else if (formaArredondamento == 'c') {
        peso = Math.ceil(peso);
    }

    var fretePeso = 0
    // tipoFrete == Peso/kg -------------------------------------------------
    if (tipoFrete == 0) {
        if (tipoFretePeso == 'f') {
            //Se o peso informado não for excedente
            if (valorPorFaixa != 0) {
                fretePeso = valorPorFaixa;
            } else {
                var excedente = 0;
                var fretePeso_pt1 = 0;
                //existem dois tipos de excedentes no momento
                if (transporteTipo == 'a') {
                    excedente = parseFloat(valorExcedenteAereo);
                } else {
                    excedente = parseFloat(valorExcedente)
                }
                fretePeso_pt1 = excedente * (parseFloat(peso) - parseFloat(maximoPesoFinal));
                fretePeso = fretePeso_pt1 + parseFloat(valorMaximoPeso);
            }
        } else {
            if (formulaPeso != null && formulaPeso != undefined && formulaPeso.trim() != '') {
                fretePeso = compilaFormula(formulaPeso, tipoFrete, peso, valorMercadoria, volume, pallets, km,
                        tipoVeiculo, considerarMaiorPeso, baseCubagem, metro, entregas, transporteTipo,
                        0, 0, 0, formaArredondamento, pagador, freteRedespacho, icmsRedespacho);
            } else {
                fretePeso = valorPeso * parseFloat(peso) * (isPrecoTonelada ? 1 / 1000 : 1);
            }
        }
        // tipoFrete == Peso/cubagem -------------------------------------------------
    } else if (tipoFrete == 1) {
        var metroBase = 0;
        if (transporteTipo == 'a') {
            metroBase = parseFloat(metro) * parseFloat(1000000) / parseFloat(baseCubagem);
        } else {
            metroBase = parseFloat(metro) * parseFloat(baseCubagem);
        }

        if (formaArredondamento == 'a') {
            metroBase = Math.round(metroBase);
        } else if (formaArredondamento == 'c') {
            metroBase = Math.ceil(metroBase);
        }

        if (tipoFretePeso == 'f') {
            //Se o peso informado não for excedente
            if (valorPorFaixa != 0) {
                fretePeso = valorPorFaixa;
            } else {
                var excedente1 = 0
                var fp_pt1 = 0
                //existem dois tipos de excedentes no momento
                if (transporteTipo == 'a') {
                    excedente1 = parseFloat(valorExcedenteAereo);
                } else {
                    excedente1 = parseFloat(valorExcedente)
                }
                fp_pt1 = excedente1 * (parseFloat(metroBase) - parseFloat(maximoPesoFinal));
                fretePeso = fp_pt1 + parseFloat(valorMaximoPeso);
            }
        } else {
            if (formulaPeso != null && formulaPeso != undefined && formulaPeso.trim() != '') {
                fretePeso = compilaFormula(formulaPeso, tipoFrete, peso, valorMercadoria, volume, pallets, km,
                        tipoVeiculo, considerarMaiorPeso, baseCubagem, metro, entregas,
                        transporteTipo, 0, 0, 0, formaArredondamento, pagador, freteRedespacho, icmsRedespacho);
            } else {
                fretePeso = valorPeso * metroBase * (isPrecoTonelada ? 1 / 1000 : 1);
            }
        }
        //tipoFrete == % nota fiscal ---------------------------------------------
    } else if (tipoFrete == 2) {
        var vlMercadoria = (isRedespacho ? valorRedespacho : valorMercadoria);
        if (tipoImpressaoPercentual == "p") {
            if (formulaPercentual != null && formulaPercentual != undefined && formulaPercentual.trim() != '') {
                fretePeso = compilaFormula(formulaPercentual, tipoFrete, peso, vlMercadoria, volume, pallets, km,
                        tipoVeiculo, considerarMaiorPeso, baseCubagem, metro, entregas,
                        transporteTipo, 0, 0, 0, formaArredondamento, pagador, freteRedespacho, icmsRedespacho);
            } else {
                // valorMercadoria menor que o valor minimo
                if (parseFloat(vlMercadoria) <= parseFloat(baseNfPercentual)) {
                    fretePeso = parseFloat(valorPercentualNf);
                } else {
                    // valorMercadoria * percentual da nota fiscal
                    fretePeso = parseFloat(vlMercadoria) * parseFloat(percentualNf) / 100;
                }
            }
        }
        // tipoFrete == combinado -------------------------------------------------
    } else if (tipoFrete == 3) {
        //// a sql já trata o tipo do veiculo
        fretePeso = valorVeiculo;
//        fretePeso = valorVeiculo;
        // tipoFrete == por volume -------------------------------------------------
    } else if (tipoFrete == 4) {
        if (formulaVolume != null && formulaVolume != undefined && formulaVolume.trim() != '') {
            fretePeso = compilaFormula(formulaVolume, tipoFrete, peso, valorMercadoria, volume, pallets, km, tipoVeiculo,
                    considerarMaiorPeso, baseCubagem, metro, entregas, transporteTipo, 0, 0, 0, formaArredondamento,
                    pagador, freteRedespacho, icmsRedespacho);
        } else {
            fretePeso = valorVolume * volume;
        }
        // tipoFrete == por km -----------------------------------------------------
    } else if (tipoFrete == 5) {
        fretePeso = valorKm;
        // tipoFrete == por pallet -----------------------------------------------------
    } else if (tipoFrete == 6) {
        if (formulaPallet != null && formulaPallet != undefined && formulaPallet.trim() != '') {
            fretePeso = compilaFormula(formulaPallet, tipoFrete, peso, valorMercadoria, volume, pallets, km, tipoVeiculo,
                    considerarMaiorPeso, baseCubagem, metro, entregas, transporteTipo, 0, 0, 0, formaArredondamento,
                    pagador, freteRedespacho, icmsRedespacho);
        } else {
            fretePeso = valorPallet * pallets;
        }
    }

    // ----------------------- Importante --------------------------------------
    var fretePesoCubagem = 0;
    var fretePesoKg = 0;
    if (formulaPeso == null || formulaPeso == undefined || formulaPeso.trim() == '') {
        if (considerarMaiorPeso == true && tipoFrete == 0) {
            fretePesoKg = fretePeso;
            fretePesoCubagem = getFretePeso(peso, volume, 1, valorPeso, valorVolume, baseCubagem,
                    metro, valorVeiculo, valorPorFaixa, transporteTipo,
                    valorExcedenteAereo, valorExcedente, maximoPesoFinal,
                    isPrecoTonelada, tipoFretePeso, valorMaximoPeso,
                    valorKm, false, tipoImpressaoPercentual, valorMercadoria, baseNfPercentual,
                    valorPercentualNf, percentualNf, pallets, km, formulaVolume, tipoVeiculo, formulaPercentual, valorPallet,
                    formulaPallet, isRedespacho, valorRedespacho, entregas, formulaPeso, tipoIncluiIcms, aliquotaIcms, true, formaArredondamento);
            if (fretePesoCubagem > fretePesoKg) {
                fretePeso = fretePesoCubagem;
                //$("tipofrete").value = "1";
                //setTipofrete("1");
            } else {
                fretePeso = fretePesoKg;
            }
        } else if (considerarMaiorPeso == true && tipoFrete == 1) {
            fretePesoCubagem = fretePeso;
            fretePesoKg = getFretePeso(peso, volume, 0, valorPeso, valorVolume, baseCubagem,
                    metro, valorVeiculo, valorPorFaixa, transporteTipo,
                    valorExcedenteAereo, valorExcedente, maximoPesoFinal,
                    isPrecoTonelada, tipoFretePeso, valorMaximoPeso,
                    valorKm, false, tipoImpressaoPercentual, valorMercadoria, baseNfPercentual,
                    valorPercentualNf, percentualNf, pallets, km, formulaVolume, tipoVeiculo, formulaPercentual, valorPallet,
                    formulaPallet, isRedespacho, valorRedespacho, entregas, formulaPeso, tipoIncluiIcms, aliquotaIcms, true, formaArredondamento);
            if (fretePesoCubagem < fretePesoKg) {
                fretePeso = fretePesoKg;
                // $("tipofrete").value = "0";
                //setTipofrete("0");
            } else {
                fretePeso = fretePesoCubagem;
            }
        }
    }

    if (tipoIncluiIcms == 'i' && parseFloat(aliquotaIcms) != 0 && !isRecalculando) {
        fretePeso = parseFloat(fretePeso) / (1 - (parseFloat(aliquotaIcms) / 100));
    }

    return formatoMoeda(fretePeso);
}

function isFreteMinimo(totalPrestacao, valorFreteMinimo, formula, tipoFrete, peso, valorMercadoria, volumes, pallets, km, tipoVeiculo,
        considerarMaiorPeso, baseCubagem, metro, entregas, tipoTransporte, tipoIncluiIcms, aliquotaIcm,
        desconsideraIcmsMinimo, formaArredondamento, pagador, freteRedespacho, icmsRedespacho) {
    var retorno = false;

    if (tipoIncluiIcms == 'i' && parseFloat(aliquotaIcm) > 0) {
        if (desconsideraIcmsMinimo == false || desconsideraIcmsMinimo == 'false' || desconsideraIcmsMinimo == 'f') {
            var idxIcm = ((100 - parseFloat(aliquotaIcm)) / 100);
            var vlSemIcms = parseFloat(totalPrestacao) * parseFloat(idxIcm);
            totalPrestacao = vlSemIcms.toFixed(2);
        }
    }

    var vlMinimo = 0;
    if (formula != null && formula != undefined && formula.trim() != '') {
        vlMinimo = compilaFormula(formula, tipoFrete, peso, valorMercadoria, volumes, pallets, km, tipoVeiculo, considerarMaiorPeso,
                baseCubagem, metro, entregas, tipoTransporte, 0, 0, 0, formaArredondamento,
                pagador, freteRedespacho, icmsRedespacho);
    } else {
        vlMinimo = valorFreteMinimo;
    }
    var totalFrete = parseFloat(totalPrestacao).toFixed(2);
    var totalMinimo = parseFloat(vlMinimo).toFixed(2);


    if (!isNaN(totalFrete) && !isNaN(totalMinimo)) {
        if (parseFloat(totalFrete) < parseFloat(totalMinimo)) {
            retorno = true;
        }
    }
    return retorno;
}

function getFreteMinimo(valorFreteMinimo, formula, tipoFrete, peso, valorMercadoria, volumes, pallets, km, tipoVeiculo, considerarMaiorPeso,
        baseCubagem, metro, entregas, tipoTransporte, desconsideraIcmsMinimo, tipoIncluiIcms, aliquotaIcms,
        formaArredondamento, pagador, freteRedespacho, icmsRedespacho) {
    var vlMinimo = 0;
    if (formula != null && formula != undefined && formula.trim() != '') {
        vlMinimo = compilaFormula(formula, tipoFrete, peso, valorMercadoria, volumes, pallets, km, tipoVeiculo, considerarMaiorPeso,
                baseCubagem, metro, entregas, tipoTransporte, 0, 0, 0, formaArredondamento,
                pagador, freteRedespacho, icmsRedespacho);
    } else {
        vlMinimo = valorFreteMinimo;
    }

    if (desconsideraIcmsMinimo == false && tipoIncluiIcms == 'i' && parseFloat(aliquotaIcms) != 0) {
        vlMinimo = parseFloat(vlMinimo) / (1 - (parseFloat(aliquotaIcms) / 100));
    }

    return formatoMoeda(vlMinimo);
}

function getValorSecCat(vlSecCat, formula, tipoFrete, peso, valorMercadoria, volumes, pallets, km, tipoVeiculo, considerarMaiorPeso,
        baseCubagem, metro, entregas, tipoTransporte, limitePeso, excedenteSecCat, tipoIncluiIcms, aliquotaIcms,
        formaArredondamento, pagador, freteRedespacho, icmsRedespacho) {
    //valor de secCat. - não preceisa de calculo
    //vlSecCat = informado pelo banco
    var vlSec = 0;
    if (formula != null && formula != undefined && formula.trim() != '') {
        vlSec = compilaFormula(formula, tipoFrete, peso, valorMercadoria, volumes, pallets, km, tipoVeiculo, considerarMaiorPeso,
                baseCubagem, metro, entregas, tipoTransporte, 0, 0, 0,
                formaArredondamento, pagador, freteRedespacho, icmsRedespacho);
    } else {

        var pesoTaxado = getPesoTaxado(tipoTransporte, baseCubagem, metro, considerarMaiorPeso, peso, formaArredondamento);

        vlSec = (vlSecCat == undefined ? 0 : vlSecCat);
        if (parseFloat(pesoTaxado) > parseFloat(limitePeso)) {
            vlSec = parseFloat(vlSec) + ((parseFloat(pesoTaxado) - parseFloat(limitePeso)) * parseFloat(excedenteSecCat));
        }
    }

    if (tipoIncluiIcms == 'i' && parseFloat(aliquotaIcms) != 0) {
        vlSec = parseFloat(vlSec) / (1 - (parseFloat(aliquotaIcms) / 100));
    }

    return formatoMoeda(vlSec);
}

function getIdTarifas(tarifasId) { //campo retornado pelo banco
    return tarifasId;
}

/**
 * função para receber uma formula, suas variaveis e executalos.
 * @param {type} formula
 * @param {type} tipoFrete
 * @param {type} peso
 * @param {type} valorMercadoriaFormula
 * @param {type} volumes
 * @param {type} pallets
 * @param {type} km
 * @param {type} tipoVeiculo
 * @param {type} considerarMaiorPeso
 * @param {type} baseCubagem
 * @param {type} metro
 * @param {type} entregas
 * @param {type} tipoTransporte
 * @param {type} valorTotalFreteSemTDE
 * @param {type} valorFretePeso
 * @param {type} valorFreteValor
 * @param {type} formaArredondamento
 * @param {type} pagador
 * @param {type} freteRedespacho
 * @param {type} icmsRedespacho
 * @returns formula executada com os parametros passados
 */
function compilaFormula(formula, tipoFrete, peso, valorMercadoriaFormula, volumes, pallets, km, tipoVeiculo,
        considerarMaiorPeso, baseCubagem, metro, entregas, tipoTransporte, valorTotalFreteSemTDE, valorFretePeso,
        valorFreteValor, formaArredondamento, pagador, freteRedespacho, icmsRedespacho) {

    var resultado = 0;
    var pesoCubado = 0;
    if (tipoTransporte == 'a') {
        pesoCubado = parseFloat(metro) * parseFloat(1000000) / parseFloat(baseCubagem);
    } else {
        pesoCubado = parseFloat(baseCubagem) * parseFloat(metro);
    }
    var pesoTaxado = peso;
    if (considerarMaiorPeso == true || considerarMaiorPeso == 't' || considerarMaiorPeso == 'true') {
        if (parseFloat(peso) < parseFloat(pesoCubado)) {
            pesoTaxado = pesoCubado;
        }
    } else {
        if (tipoFrete == '1') {
            pesoTaxado = pesoCubado;
        }
    }
    if (formaArredondamento == 'a') {
        pesoTaxado = Math.round(pesoTaxado);
    } else if (formaArredondamento == 'c') {
        pesoTaxado = Math.ceil(pesoTaxado);
    }

    if (freteRedespacho == undefined) {
        freteRedespacho = '0,00';
    }
    if (icmsRedespacho == undefined) {
        icmsRedespacho = '0,00';
    }

    var fml = formula.replace(/@@tipoFrete/gi, tipoFrete)
            .replace(/@@peso/gi, pesoTaxado)
            .replace(/@@mercadoria/gi, valorMercadoriaFormula)
            .replace(/@@volume/gi, volumes)
            .replace(/@@pallets/gi, pallets)
            .replace(/@@km/gi, km)
            .replace(/@@tipoVeiculo/gi, tipoVeiculo)
            .replace(/@@entregas/gi, entregas)
            .replace(/@@cubado/gi, pesoCubado)
            .replace(/@@totalFrete/gi, valorTotalFreteSemTDE)
            .replace(/@@fretePeso/gi, valorFretePeso)
            .replace(/@@freteValor/gi, valorFreteValor)
            .replace(/@@pagador_frete/gi, pagador)
            .replace(/@@frete_redespacho/gi, freteRedespacho)
            .replace(/@@icms_redespacho/gi, icmsRedespacho);

    try {
        resultado = eval(fml);
    } catch (err) {
        //alert(fml);
        alert('Erro na fórmula! Favor revisar a fórmula cadastrada, alguns cálculos não foram executados.\r\nFórmula:\r\n' + fml);
    }

    if (resultado == undefined) {
        //alert(fml);
        alert('Erro na fórmula! Favor revisar a fórmula cadastrada, alguns cálculos não foram executados.\r\nFórmula:\r\n' + fml);
    }

    return resultado;
}

function getPesoTaxado(tipoTransporte, baseCubagem, metro, considerarMaiorPeso, peso, formaArredondamento) {
    var pesoCubado = 0;
    if (tipoTransporte == 'a') {
        if (parseFloat(baseCubagem) == 0 || parseFloat(metro) == 0) {
            pesoCubado = 0;
        } else {
            pesoCubado = parseFloat(metro) * parseFloat(1000000) / parseFloat(baseCubagem);
        }
    } else {
        pesoCubado = parseFloat(baseCubagem) * parseFloat(metro);
    }

    var pesoCobrar = peso;
    if (considerarMaiorPeso == true || considerarMaiorPeso == 't' || considerarMaiorPeso == 'true') {
        if (parseFloat(peso) < parseFloat(pesoCubado)) {
            pesoCobrar = pesoCubado;
        }
    }

    if (formaArredondamento == 'a') {
        pesoCobrar = Math.round(pesoCobrar);
    } else if (formaArredondamento == 'c') {
        pesoCobrar = Math.ceil(pesoCobrar);
    }
    return parseFloat(pesoCobrar);

}



function calculaNota(valorMercadoria, percentualNf, baseNfPercentual, valorPercentualNf, tipoImpressaoPercentual, formulaPercentual, peso, volumes,
        pallets, km, tipoVeiculo, considerarMaiorPeso, baseCubagem, metro, isRedespacho, valorRedespacho, entregas,
        tipoTransporte, pagador, freteRedespacho, icmsRedespacho) {


    var freteValor = 0;
    //tipoFrete == % nota fiscal ---------------------------------------------


    var vlMercadoria = (isRedespacho ? valorRedespacho : valorMercadoria);
    if (tipoImpressaoPercentual == "v") {
        if (formulaPercentual != undefined && formulaPercentual.trim() != '') {
            freteValor = compilaFormula(formulaPercentual, tipoFrete, peso, vlMercadoria, volumes, pallets, km, tipoVeiculo,
                    considerarMaiorPeso, baseCubagem, metro, entregas, tipoTransporte, 0, 0, 0,
                    undefined, pagador, freteRedespacho, icmsRedespacho);
        } else {
            // valorMercadoria menor que o valor minimo
            if (parseFloat(vlMercadoria) <= parseFloat(baseNfPercentual)) {
                freteValor = parseFloat(valorPercentualNf);
            } else {
                // valorMercadoria * percentual da nota fiscal
                freteValor = parseFloat(vlMercadoria) * parseFloat(percentualNf) / 100;
            }
        }
    }

    return formatoMoeda(freteValor);
}



function calculaPeso(peso, volume, valorPeso, baseCubagem, metro, valorPorFaixa, transporteTipo, valorExcedenteAereo, valorExcedente, maximoPesoFinal,
        isPrecoTonelada, tipoFretePeso, valorMaximoPeso, considerarMaiorPeso, valorMercadoria, pallets, km, tipoVeiculo, entregas, formulaPeso,
        pagador, freteRedespacho, icmsRedespacho) {

    var fretePeso = 0

    if (tipoFretePeso == 'f') {
        //Se o peso informado não for excedente
        if (valorPorFaixa != 0) {
            fretePeso = valorPorFaixa;
        } else {
            var excedente = 0;
            var fretePeso_pt1 = 0;
            //existem dois tipos de excedentes no momento
            if (transporteTipo == 'a') {
                excedente = parseFloat(valorExcedenteAereo);
            } else {
                excedente = parseFloat(valorExcedente)
            }
            fretePeso_pt1 = excedente * (parseFloat(peso) - parseFloat(maximoPesoFinal));
            fretePeso = fretePeso_pt1 + parseFloat(valorMaximoPeso);
        }
    } else {
        if (formulaPeso != null && formulaPeso != undefined && formulaPeso.trim() != '') {
            fretePeso = compilaFormula(formulaPeso, tipoFrete, peso, valorMercadoria, volume, pallets, km, tipoVeiculo,
                    considerarMaiorPeso, baseCubagem, metro, entregas, transporteTipo, 0, 0, 0, undefined,
                    pagador, freteRedespacho, icmsRedespacho);
        } else {
            fretePeso = valorPeso * parseFloat(peso) * (isPrecoTonelada ? 1 / 1000 : 1);
        }
    }

    return formatoMoeda(fretePeso);
}

function getTipoPreferencialPesoPercentualNotaFiscal(
        peso, volume, tipoFrete, valorPeso, valorVolume, baseCubagem, metro,
        valorVeiculo, valorPorFaixa, transporteTipo, valorExcedenteAereo, valorExcedente,
        maximoPesoFinal, isPrecoTonelada, tipoFretePeso, valorMaximoPeso, valorKm,
        considerarMaiorPeso, tipoImpressaoPercentual, valorMercadoria, baseNfPercentual,
        valorPercentualNf, percentualNf, pallets, km, formulaVolume, tipoVeiculo, formulaPercentual, valorPallet,
        formulaPallet, isRedespacho, valorRedespacho, entregas, formulaPeso, tipoIncluiIcms, aliquotaIcms, isRecalculando, formaArredondamento
        , pagador, freteRedespacho, icmsRedespacho) {

    var tipFreteRet = tipoFrete;
    var _vlPeso = getFretePeso(peso, volume, ((tipoFrete == "0" || tipoFrete == "1") ? tipoFrete : "0"), valorPeso, valorVolume, baseCubagem, metro,
            valorVeiculo, valorPorFaixa, transporteTipo, valorExcedenteAereo, valorExcedente,
            maximoPesoFinal, isPrecoTonelada, tipoFretePeso, valorMaximoPeso, valorKm,
            considerarMaiorPeso, "v", valorMercadoria, baseNfPercentual,
            valorPercentualNf, percentualNf, pallets, km, formulaVolume, tipoVeiculo, formulaPercentual, valorPallet,
            formulaPallet, isRedespacho, valorRedespacho, entregas, formulaPeso, tipoIncluiIcms, aliquotaIcms, isRecalculando, formaArredondamento,
            pagador, freteRedespacho, icmsRedespacho);

    var _vlPercentualNf = getFreteValor(valorMercadoria, 0, percentualNf, baseNfPercentual,
            valorPercentualNf, "2", "v",
            "", formulaPercentual, peso, valorVolume, pallets, km, tipoVeiculo, considerarMaiorPeso,
            baseCubagem, metro, isRedespacho, valorRedespacho, entregas, transporteTipo, tipoIncluiIcms, aliquotaIcms, false, formaArredondamento,
            pagador, freteRedespacho, icmsRedespacho);


    if (parseFloat(_vlPeso) == parseFloat(_vlPercentualNf)) {
        return tipoFrete;
    }

    if (parseFloat(_vlPeso) > parseFloat(_vlPercentualNf)) {
        if (tipoFrete == "2") {
            tipFreteRet = "0";
        }
    } else if (parseFloat(_vlPeso) < parseFloat(_vlPercentualNf)) {
        if ((tipoFrete == "0" || tipoFrete == "1")) {
            tipFreteRet = "2";
        }
    }

    return tipFreteRet;
}

function getAdValorEm(formulaSeguro, adValorEm, tipoFrete, peso, volumes, pallets, km, tipoVeiculo, considerarMaiorPeso, baseCubagem,
        metro, tipoTransporte, entregas, valorMercadoria,
        formaArredondamento, pagador, freteRedespacho, icmsRedespacho) {
    var vlSeguro = 0;
    if (formulaSeguro != null && formulaSeguro != undefined && formulaSeguro.trim() != '') {
        vlSeguro = compilaFormula(formulaSeguro, tipoFrete, peso, valorMercadoria, volumes, pallets, km, tipoVeiculo, considerarMaiorPeso,
                baseCubagem, metro, entregas, tipoTransporte, 0, 0, 0,
                formaArredondamento, pagador, freteRedespacho, icmsRedespacho);
    } else {
        vlSeguro = parseFloat(valorMercadoria) * parseFloat(adValorEm) / 100;
    }
    return vlSeguro;
}
