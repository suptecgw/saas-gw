function addTabelaPrecoCiaAerea(idsTP, descsTP, idsTE, codsTE, descsTE) {
    var countDOM = jQuery('.countTrDOM').size() + 1;

    var corpo = jQuery('#tableDOMtp');
//    var trTitulos = jQuery('<tr id="trTitulo_' + countDOM + '">');

    var trTituloDOMFP = jQuery('<tr class="tabela">');
    var tdTituloDOMFP = jQuery('<td colspan="15" align="center">');
    var divTituloDOMFP = jQuery('<div align="center">Faixas de peso</div>');
    tdTituloDOMFP.append(divTituloDOMFP);
    trTituloDOMFP.append(tdTituloDOMFP);

    var tdVerMais = jQuery('<td class="TextoCampos" style="text-align:center;"></td>');
    var imgVerMais = jQuery('<img src="img/plus.jpg" id="img_' + countDOM + '" onclick="exibirDOMFaixaPeso(' + countDOM + ')">');
    tdVerMais.append(imgVerMais);

    var tdLixo = jQuery('<td class="TextoCampos" style="text-align:center;"></td>');
    var imgLixo = jQuery('<img class="imagemLink countTrDOM" onclick="removeItemDom(' + countDOM + ')" src="img/lixo.png">');
    tdLixo.append(imgLixo);

//    var tdTituloLixo = jQuery('<td class="TextoCampos" width="3%" style="background-color:#7FB2CC;" id="tdtopolixo" name="tdtopolixo"></td>');
//    var tdTituloVerMais = jQuery('<td class="TextoCampos" width="2%" style="background-color:#7FB2CC;" id="tdtopovermais" name="tdtopovermais"></td>');
//    var tdOrigem = jQuery('<td class="TextoCampos" width="7%" style="background-color:#7FB2CC;" id="tdlblorigem" name="tdlblorigem"><div align="left">Aeroporto Origem</div></td>');
//    var tdDestino = jQuery('<td class="TextoCampos" width="7%" style="background-color:#7FB2CC;" id="tdlbldestino" name="tdlbldestino"><div align="left">Aeroporto Destino</div></td>');
//    var tdExcedente = jQuery('<td class="TextoCampos" width="5%" style="background-color:#7FB2CC;" id="tdlblexcedente" name="tdlblexcedente"><div align="left">Valor excedente</div></td>');
//    var tdFixo = jQuery('<td class="TextoCampos" width="5%" style="background-color:#7FB2CC;" id="tdlblfixo" name="tdlblfixo"><div align="left">Valor Fixo</div></td>');
//    var tdTipoProduto = jQuery('<td class="TextoCampos" width="5%" style="background-color:#7FB2CC;" id="tdlbltipoproduto" name="tdlbltipoproduto"><div align="left">Tipo de Produtos</div></td>');
//    var tdTarifaEspecifica = jQuery('<td class="TextoCampos" width="5%" style="background-color:#7FB2CC;" id="tdlbltarifaespecifica" name="tdlbltarifaespecifica"><div align="left">Tarifa específica</div></td>');
//    var tdTaxaColeta = jQuery('<td class="TextoCampos" width="5%" style="background-color:#7FB2CC;" id="tdlbltaxacoleta" name="tdlbltaxacoleta"><div align="left">Taxa de coleta</div></td>');
//    var tdTaxaEntrega = jQuery('<td class="TextoCampos" width="5%" style="background-color:#7FB2CC;" id="tdlbltaxaentrega" name="tdlbltaxaentrega"><div align="left">Taxa de Entrega</div></td>');
//    var tdTaxaCapatazia = jQuery('<td class="TextoCampos" width="5%" style="background-color:#7FB2CC;" id="tdlbltaxacapatazia" name="tdlbltaxacapatazia"><div align="left">Taxa de Capatazia</div></td>');
//    var tdTaxaFixa = jQuery('<td class="TextoCampos" width="5%" style="background-color:#7FB2CC;" id="tdlbltaxafixa" name="tdlbltaxafixa"><div align="left">Taxa Fixa</div></td>');
//    var tdTaxaDesembaraco = jQuery('<td class="TextoCampos" width="5%" style="background-color:#7FB2CC;" id="tdlbltaxadesembaraco" name="tdlbltaxadesembaraco"><div align="left">Taxa de desembaraço</div></td>');
//    var tdSeguro = jQuery('<td class="TextoCampos" width="5%" style="background-color:#7FB2CC;" id="tdlblseguro" name="tdlblseguro"><div align="left">% seguro</div></td>');
//    var tdFreteMinimo = jQuery('<td class="TextoCampos" width="5%" style="background-color:#7FB2CC;" id="tdlblfreteminimo" name="tdlblfreteminimo"><div align="left">Frete Mínimo</div></td>');

//    trTitulos.append(tdTituloLixo);
//    trTitulos.append(tdTituloVerMais);
//    trTitulos.append(tdOrigem);
//    trTitulos.append(tdDestino);
//    trTitulos.append(tdExcedente);
//    trTitulos.append(tdFixo);
//    trTitulos.append(tdTipoProduto);
//    trTitulos.append(tdTarifaEspecifica);
//    trTitulos.append(tdTaxaColeta);
//    trTitulos.append(tdTaxaEntrega);
//    trTitulos.append(tdTaxaCapatazia);
//    trTitulos.append(tdTaxaFixa);
//    trTitulos.append(tdTaxaDesembaraco);
//    trTitulos.append(tdSeguro);
//    trTitulos.append(tdFreteMinimo);

    var trDom = jQuery('<tr id=trDom_' + countDOM + '>');

    var tdOrigemVal = jQuery('<td class="CelulaZebra2">');
    var inputOrigem = jQuery('<input name="aeroportoColeta_' + countDOM + '" id="aeroportoColeta_' + countDOM + '" class="inputReadOnly" value="" size="17" readonly="true"/>');
    var btnOrigem = jQuery('<input name="btAero" type="button" id="btAero" class="inputBotaoMin" value="..." onClick="javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=73\', \'Aeroporto_Coleta_' + countDOM + '\')" style="text-align: center"/>');
    var btnLimpaOrigem = jQuery('<img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaAeroportoColeta();">');
    var hiddenOrigem = jQuery('<input name="aeroportoColetaId_' + countDOM + '" id="aeroportoColetaId_' + countDOM + '" type="hidden" value=""/>');
    var hiddenID = jQuery('<input name="tabelaId_' + countDOM + '" id="tabelaId_' + countDOM + '" type="hidden" value="0"/>');
    var hiddenExcluido = jQuery('<input name="isExcluido_' + countDOM + '" id="isExcluido_' + countDOM + '" type="hidden" value="false"/>');

    tdOrigemVal.append(inputOrigem);
    tdOrigemVal.append(btnOrigem);
    tdOrigemVal.append(btnLimpaOrigem);
    tdOrigemVal.append(hiddenOrigem);
    tdOrigemVal.append(hiddenID);
    tdOrigemVal.append(hiddenExcluido);

    var tdDestinoVal = jQuery('<td class="CelulaZebra2">');
    var inputDestino = jQuery('<input name="aeroportoEntrega_' + countDOM + '" id="aeroportoEntrega_' + countDOM + '" class="inputReadOnly" value="" size="17" readonly="true"/>');
    var btnDestino = jQuery('<input name="btAero" type="button" id="btAero" class="inputBotaoMin" value="..." onClick="javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=73\', \'Aeroporto_Entrega_' + countDOM + '\')" style="text-align: center"/>');
    var btnLimpaDestino = jQuery('<img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaAeroportoEntrega();">');
    var hiddenDestino = jQuery('<input name="aeroportoEntregaId_' + countDOM + '" id="aeroportoEntregaId_' + countDOM + '" type="hidden" value=""/>');

    tdDestinoVal.append(inputDestino);
    tdDestinoVal.append(btnDestino);
    tdDestinoVal.append(btnLimpaDestino);
    tdDestinoVal.append(hiddenDestino);

    var tdExcedenteVal = jQuery('<td class="CelulaZebra2">');
    var inputExcedente = jQuery('<input name="excedente_' + countDOM + '" type="text" id="excedente_' + countDOM + '" onchange="seNaoFloatReset(this,\'0.00\')" size="7" maxlength="7" class="inputtexto fieldMin">');

    tdExcedenteVal.append(inputExcedente);

    var tdFixoVal = jQuery('<td class="CelulaZebra2">');
    var inputFixo = jQuery('<input name="fixo_' + countDOM + '" type="text" id="fixo_' + countDOM + '" onchange="seNaoFloatReset(this,\'0.00\')" size="7" maxlength="7" class="inputtexto fieldMin">');

    tdFixoVal.append(inputFixo);

    var optionSelectTP = jQuery('<option value="0">Selecione</option>');
    var tdTipoProdutoVal = jQuery('<td class="CelulaZebra2">');
    var selectTipoProduto = jQuery('<select name="tipoProduto_' + countDOM + '" id="tipoProduto_' + countDOM + '" class="inputtexto" style="width: 95px;">');
    selectTipoProduto.append(optionSelectTP);

    tdTipoProdutoVal.append(selectTipoProduto);

    var optionSelectTE = jQuery('<option value="0">TARIFA NORMAL</option>');
    var tdTarifaEspecificaVal = jQuery('<td class="CelulaZebra2">');
    var selectTarifaEspecifica = jQuery('<select name="tarifaEspecifica_' + countDOM + '" id="tarifaEspecifica_' + countDOM + '" class="inputtexto" style="width: 90px;">');
    selectTarifaEspecifica.append(optionSelectTE);

    tdTarifaEspecificaVal.append(selectTarifaEspecifica);

    var tdTaxaColetaVal = jQuery('<td class="CelulaZebra2">');
    var inputTaxaColeta = jQuery('<input name="taxaColeta_' + countDOM + '" type="text" id="taxaColeta_' + countDOM + '" onchange="seNaoFloatReset(this,\'0.00\')" size="7" maxlength="7" class="inputtexto fieldMin">');

    tdTaxaColetaVal.append(inputTaxaColeta);

    var tdTaxaEntregaVal = jQuery('<td class="CelulaZebra2">');
    var inputTaxaEntrega = jQuery('<input name="taxaEntrega_' + countDOM + '" type="text" id="taxaEntrega_' + countDOM + '" onchange="seNaoFloatReset(this,\'0.00\')" size="7" maxlength="7" class="inputtexto fieldMin">');

    tdTaxaEntregaVal.append(inputTaxaEntrega);

    var tdTaxaCapataziaVal = jQuery('<td class="CelulaZebra2">');
    var inputTaxaCapatazia = jQuery('<input name="taxaCapatazia_' + countDOM + '" type="text" id="taxaCapatazia_' + countDOM + '" onchange="seNaoFloatReset(this,\'0.00\')" size="7" maxlength="7" class="inputtexto fieldMin">');

    tdTaxaCapataziaVal.append(inputTaxaCapatazia);

    var tdTaxaFixaVal = jQuery('<td class="CelulaZebra2">');
    var inputTaxaFixa = jQuery('<input name="taxaFixa_' + countDOM + '" type="text" id="taxaFixa_' + countDOM + '" onchange="seNaoFloatReset(this,\'0.00\')" size="7" maxlength="7" class="inputtexto fieldMin">');

    tdTaxaFixaVal.append(inputTaxaFixa);

    var tdTaxaDesembaracoVal = jQuery('<td class="CelulaZebra2">');
    var inputTaxaDesembaraco = jQuery('<input name="taxaDesembaraco_' + countDOM + '" type="text" id="taxaDesembaraco_' + countDOM + '" onchange="seNaoFloatReset(this,\'0.00\')" size="7" maxlength="7" class="inputtexto fieldMin">');

    tdTaxaDesembaracoVal.append(inputTaxaDesembaraco);

    var tdSeguroVal = jQuery('<td class="CelulaZebra2">');
    var inputSeguro = jQuery('<input name="seguro_' + countDOM + '" type="text" id="seguro_' + countDOM + '" onchange="seNaoFloatReset(this,\'0.00\')" size="7" maxlength="7" class="inputtexto fieldMin">');

    tdSeguroVal.append(inputSeguro);

    var tdFreteMinimoVal = jQuery('<td class="CelulaZebra2">');
    var inputFreteMinimo = jQuery('<input name="freteMinimo_' + countDOM + '" type="text" id="freteMinimo_' + countDOM + '" onchange="seNaoFloatReset(this,\'0.00\')" size="7" maxlength="7" class="inputtexto fieldMin">');

    tdFreteMinimoVal.append(inputFreteMinimo);

    trDom.append(tdLixo);
    trDom.append(tdVerMais);
    trDom.append(tdOrigemVal);
    trDom.append(tdDestinoVal);
    trDom.append(tdExcedenteVal);
    trDom.append(tdFixoVal);
    trDom.append(tdTipoProdutoVal);
    trDom.append(tdTarifaEspecificaVal);
    trDom.append(tdTaxaColetaVal);
    trDom.append(tdTaxaEntregaVal);
    trDom.append(tdTaxaCapataziaVal);
    trDom.append(tdTaxaFixaVal);
    trDom.append(tdTaxaDesembaracoVal);
    trDom.append(tdSeguroVal);
    trDom.append(tdFreteMinimoVal);

    var trDomFaixaPeso = jQuery('<tr id="trDOMFaixaPeso_' + countDOM + '" style="display: none;">');
    var tdBrancaEsquerdaFaixaPeso = jQuery('<td colspan="1" class="TextoCampos">');
    var tdBrancaDireitaFaixaPeso = jQuery('<td colspan="11" class="TextoCampos">');
    var tdPrincipalFaixaPeso = jQuery('<td colspan="3">');
    var tableDOMFaixaPeso = jQuery('<table width="100%" align="left">');
    var tBodyFaixaPeso = jQuery('<tbody id="tBodyFaixaPeso_' + countDOM + '" name="tBodyFaixaPeso_' + countDOM + '">');

    var trTituloFaixaPeso = jQuery('<tr>');
    var tdTituloFaixaPeso = jQuery('<td class="TextoCampos celula" width="1%" style="background-color:#7FB2CC;" id="tdtitulofaixapeso" name="tdtitulofaixapeso">');
    var imagemAddFaixaPeso = jQuery('<img src="img/add.gif" id="imgAddFaixaPeso_' + countDOM + '" onclick="adicionarDOMFaixaPeso(' + countDOM + ')">');
    var qtdFaixaPeso = jQuery('<input type="hidden" id="qtdTabFaixaPeso_' + countDOM + '" name="qtdTabFaixaPeso_' + countDOM + '" value="0" />');
    var tdTituloPesoInicial = jQuery('<td class="TextoCampos" width="1%" style="background-color:#7FB2CC;" id="tdlblpesoinicial" name="tdlblpesoinicial"><div align="left">Peso Inicial</div></td>');
    var tdTituloPesoFinal = jQuery('<td class="TextoCampos" width="1%" style="background-color:#7FB2CC;" id="tdlblpesofinal" name="tdlblpesofinal"><div align="left">Peso Final</div></td>');
    var tdTituloValorQuilo = jQuery('<td class="TextoCampos" width="1%" style="background-color:#7FB2CC;" id="tdlblvalorporquilo" name="tdlblvalorporquilo"><div align="left">Valor</div></td>');
    var tdTituloTipoValor = jQuery('<td class="TextoCampos" width="1%" style="background-color:#7FB2CC;" id="tdlbltipovalor" name="tdlbltipovalor"><div align="left"></div></td>');
    tdTituloFaixaPeso.append(imagemAddFaixaPeso);
    tdTituloFaixaPeso.append(qtdFaixaPeso);
    
    trTituloFaixaPeso.append(tdTituloFaixaPeso);
    trTituloFaixaPeso.append(tdTituloPesoInicial);
    trTituloFaixaPeso.append(tdTituloPesoFinal);
    trTituloFaixaPeso.append(tdTituloValorQuilo);
    trTituloFaixaPeso.append(tdTituloTipoValor);

    tBodyFaixaPeso.append(trTituloDOMFP);
    tBodyFaixaPeso.append(trTituloFaixaPeso);

    tableDOMFaixaPeso.append(tBodyFaixaPeso);

    tdPrincipalFaixaPeso.append(tableDOMFaixaPeso);
    trDomFaixaPeso.append(tdBrancaEsquerdaFaixaPeso);
    trDomFaixaPeso.append(tdPrincipalFaixaPeso);
    trDomFaixaPeso.append(tdBrancaDireitaFaixaPeso);

//    corpo.append(trTitulos);
    corpo.append(trDom);
    corpo.append(trDomFaixaPeso);

    jQuery('#qtdTabPreceCiaAerea').val(parseInt(jQuery('#qtdTabPreceCiaAerea').val()) + 1);
    addOptionsTipoProduto(idsTP, descsTP, countDOM);
    addOptionsTarifaEspecifica(idsTE, codsTE, descsTE, countDOM);
}

function addOptionsTipoProduto(ids, descs, index) {
    var arrayIds = ids.split(';');
    var arrayDescs = descs.split(';');
    for (var i = 0; i < arrayIds.length; i++) {
        if(arrayIds[i] != "") {
            var option = jQuery('<option value="' + arrayIds[i] + '">' + arrayDescs[i] + '</option>');
            jQuery('#tipoProduto_' + index).append(option);
        }
    }
}

function addOptionsTarifaEspecifica(ids, cods, descs, index) {
    var arrayIds = ids.split(';');
    var arrayCods = cods.split(';');
    var arrayDescs = descs.split(';');
    for (var i = 0; i < arrayIds.length; i++) {
        if(arrayIds[i] != "") {
            var option = jQuery('<option value="' + arrayIds[i] + '">'+ arrayCods[i] +' - ' + arrayDescs[i] + '</option>');
            jQuery('#tarifaEspecifica_' + index).append(option);
        }
    }
}

function adicionarDOMFaixaPeso(index) {
    var countDOM = jQuery('.countTrFPDOM_' + index + '').size() + 1;

    var tBodyFaixaPeso = jQuery('#tBodyFaixaPeso_' + index);

    var tdLixoFaixaPeso = jQuery('<td class="TextoCampos" style="text-align:center;"></td>');
    var imgLixoFaixaPeso = jQuery('<img class="imagemLink countTrFPDOM_' + index + '" onclick="removeItemDomFp(' + index + ', ' + countDOM + ')" src="img/lixo.png">');
    tdLixoFaixaPeso.append(imgLixoFaixaPeso);

//    var trTitulosDOMFP = jQuery('<tr id="trTituloFp_' + index + '_' + countDOM + '">');
//    var tdTituloLixoFaixaPeso = jQuery('<td class="TextoCampos" width="3%" style="background-color:#7FB2CC;" id="tdtopolixofaixapeso" name="tdtopolixofaixapeso"></td>');
//    var tdPesoInicial = jQuery('<td class="TextoCampos" width="7%" style="background-color:#7FB2CC;" id="tdlblpesoinicial" name="tdlblpesoinicial"><div align="left">Peso Inicial</div></td>');
//    var tdPesoFinal = jQuery('<td class="TextoCampos" width="7%" style="background-color:#7FB2CC;" id="tdlblpesofinal" name="tdlblpesofinal"><div align="left">Peso Final</div></td>');
//    var tdValorPorQuilo = jQuery('<td class="TextoCampos" width="5%" style="background-color:#7FB2CC;" id="tdlblvalorporquilo" name="tdlblvalorporquilo"><div align="left">Valor Por Quilo</div></td>');
//
//    trTitulosDOMFP.append(tdTituloLixoFaixaPeso);
//    trTitulosDOMFP.append(tdPesoInicial);
//    trTitulosDOMFP.append(tdPesoFinal);
//    trTitulosDOMFP.append(tdValorPorQuilo);

    var trValoresDOMFP = jQuery('<tr id="trDomFp_' + index + '_' + countDOM + '" data-index="' + index + '">');

    var tdValorPesoInicial = jQuery('<td class="CelulaZebra2">');
    var inputPesoInicial = jQuery('<input data-faixa-peso="inicial"  data-count-dom="' + countDOM + '" name="pesoinicial_' + index + '_' + countDOM + '" type="text" id="pesoinicial_' + index + '_' + countDOM + '" onchange="seNaoFloatReset(this,\'0.00\')" size="7" maxlength="7" class="inputtexto">');
    var hiddenIDFaixaPeso = jQuery('<input name="tpFaixaPesoId_' + index + '_' + countDOM + '" id="tpFaixaPesoId_' + index + '_' + countDOM + '" type="hidden" value="0"/>');
    var hiddenExcluidoFP = jQuery('<input name="isExcluidoFP_' + index + '_' + countDOM + '" id="isExcluidoFP_' + index + '_' + countDOM + '" type="hidden" value="false"/>');

    tdValorPesoInicial.append(inputPesoInicial);
    tdValorPesoInicial.append(hiddenIDFaixaPeso);
    tdValorPesoInicial.append(hiddenExcluidoFP);

    var tdValorPesoFinal = jQuery('<td class="CelulaZebra2">');
    var inputPesoFinal = jQuery('<input data-faixa-peso="final" data-count-dom="' + countDOM + '" name="pesofinal_' + index + '_' + countDOM + '" type="text" id="pesofinal_' + index + '_' + countDOM + '" onchange="seNaoFloatReset(this,\'0.00\')" size="7" maxlength="7" class="inputtexto">');

    tdValorPesoFinal.append(inputPesoFinal);

    var tdValorVPorQuilo = jQuery('<td class="CelulaZebra2">');
    var inputValorPorQuilo = jQuery('<input name="valorporquilo_' + index + '_' + countDOM + '" type="text" id="valorporquilo_' + index + '_' + countDOM + '" onchange="seNaoFloatReset(this,\'0.00\')" size="7" maxlength="7" class="inputtexto">');

    var optionSelectTpValor1 = jQuery('<option value="k">Valor/Kg</option>');
    var optionSelectTpValor2 = jQuery('<option value="f">Valor Fixo</option>');
    var tdTipoValorPeso = jQuery('<td class="CelulaZebra2">');
    var selectTipoValor = jQuery('<select name="tpValor_' + index + '_' + countDOM + '" id="tpValor_' + index + '_' + countDOM + '" class="inputtexto" style="width: 95px;">');
    
    selectTipoValor.append(optionSelectTpValor1);
    selectTipoValor.append(optionSelectTpValor2);
    tdTipoValorPeso.append(selectTipoValor);

    tdValorVPorQuilo.append(inputValorPorQuilo);

    trValoresDOMFP.append(tdLixoFaixaPeso);
    trValoresDOMFP.append(tdValorPesoInicial);
    trValoresDOMFP.append(tdValorPesoFinal);
    trValoresDOMFP.append(tdValorVPorQuilo);
    trValoresDOMFP.append(tdTipoValorPeso);

//    tBodyFaixaPeso.append(trTitulosDOMFP);;
    tBodyFaixaPeso.append(trValoresDOMFP);

    jQuery('#qtdTabFaixaPeso_' + index).val(parseInt(jQuery('#qtdTabFaixaPeso_' + index).val()) + 1);
    
    var isInputModificado = false;
    var valorAntigo = false;
    jQuery(inputPesoInicial).focusin(function () {
        isInputModificado = false;
        valorAntigo = this.value;
    });
    
    jQuery(inputPesoFinal).focusin(function () {
        isInputModificado = false;
        valorAntigo = this.value;
    });
    
    jQuery(inputPesoInicial).change(function () {
        var vl = this.value;
        var campo = jQuery(this);
            jQuery.each(jQuery('[data-index='+index+']'),function(i){
                var pos = parseInt(i) + 1;
                if (jQuery("#isExcluidoFP_"+index+"_"+pos).val() != 'true'){
                    var isMesmaLinha = false;
                    var vlInicial = parseFloat(jQuery(this).find('[data-faixa-peso=inicial]').val());
                    var vlFinal = parseFloat((jQuery(this).find('[data-faixa-peso=final]').val() == '' ? '0.00' : jQuery(this).find('[data-faixa-peso=final]').val()));
                    if(jQuery(inputPesoInicial).attr('id') === "pesoinicial_"+index+"_"+pos) {
                        isMesmaLinha = true;
                    }

                    if (isMesmaLinha) {
                        if (parseFloat(vl) == vlFinal && vlFinal > 0) {
                                jQuery(inputPesoInicial).css('border','1px solid red');
                                alert('O valor ('+vl+') de inicio não pode ser igual ao valor fim ('+vlFinal+')');
                                campo.val(valorAntigo);
                                setTimeout(function(){
                                    jQuery(inputPesoInicial).focus();
                                },100);
                            return false;
                        }else if (parseFloat(vl) > vlFinal && vlFinal > 0) {
                                jQuery(inputPesoInicial).css('border','1px solid red');
                                alert('O valor ('+vl+') de inicio não pode ser maior que o valor fim ('+vlFinal+')');
                                campo.val(valorAntigo);
                                setTimeout(function(){
                                    jQuery(inputPesoInicial).focus();
                                },100);
                            return false;
                        }else if (vl == "") {
                                jQuery(inputPesoInicial).css('border','1px solid red');
                                alert('O valor ('+vl+') não pode ficar em branco');
                                campo.val(valorAntigo);
                                setTimeout(function(){
                                    jQuery(inputPesoInicial).focus();
                                },100);
                            return false;
                        }
                    }

                    if (vlInicial >= 0 && vlFinal > 0 && !isMesmaLinha) {
                        if (vl >= vlInicial && vl <= vlFinal) {
                            jQuery(inputPesoInicial).css('border','1px solid red');
                            alert('O valor ('+vl+') já pertence a faixa de peso ('+vlInicial+' até '+vlFinal+').');
                            campo.val(valorAntigo);
                            setTimeout(function(){
                                jQuery(inputPesoInicial).focus();
                            },100);
                            return false;
                        }else{
                            jQuery(inputPesoInicial).css('border','');
                        }
                    }
                }
            });
            valorAntigo = "";
    });

    jQuery(inputPesoFinal).change(function () {
        var vl = this.value;
        var campo = jQuery(this);
        jQuery.each(jQuery('[data-index='+index+']'),function(i){
            var pos = parseInt(i) + 1;
            if (jQuery("#isExcluidoFP_"+index+"_"+pos).val() != 'true'){
                var isMesmaLinha = false;
                var vlInicial = parseFloat(jQuery(this).find('[data-faixa-peso=inicial]').val());
                var vlFinal = parseFloat(jQuery(this).find('[data-faixa-peso=final]').val());
                if(jQuery(inputPesoFinal).attr('id') === "pesofinal_"+index+"_"+pos) {
                    isMesmaLinha = true;
                }

                if (isMesmaLinha) {
                    if (parseFloat(vl) == vlInicial && vlInicial > 0) {
                            jQuery(inputPesoFinal).css('border','1px solid red');
                            alert('O valor ('+vl+') de fim não pode ser igual ao valor inicio ('+vlInicial+')');
                            campo.val(valorAntigo);
                            setTimeout(function(){
                                jQuery(inputPesoFinal).focus();
                            },100);
                            return false;
                    }else if (parseFloat(vl) < vlInicial) {
                            jQuery(inputPesoFinal).css('border','1px solid red');
                            alert('O valor ('+vl+') de fim não pode ser menor que o valor inicio ('+vlInicial+')');
                            campo.val(valorAntigo);
                            setTimeout(function(){
                                jQuery(inputPesoFinal).focus();
                            },100);
                            return false;
                    }else if (vl == "") {
                            jQuery(inputPesoFinal).css('border','1px solid red');
                            alert('O valor ('+vl+') não pode ficar em branco');
                            campo.val(valorAntigo);
                            setTimeout(function(){
                                jQuery(inputPesoFinal).focus();
                            },100);
                            return false;
                    }
                }

                if (vlInicial >= 0 && vlFinal > 0 && !isMesmaLinha) {
                    if (vl >= vlInicial && vl <= vlFinal) {
                        jQuery(inputPesoFinal).css('border','1px solid red');
                        alert('O valor ('+vl+') já pertence a faixa de peso ('+vlInicial+' até '+vlFinal+').');
                            campo.val(valorAntigo);
                        setTimeout(function(){
                            jQuery(inputPesoFinal).focus();
                        },100);
                            return false;
                    }else{
                        jQuery(inputPesoFinal).css('border','');
                    }
                }
            }
        });
        valorAntigo = "";
    });

    jQuery(inputPesoInicial).focusout(function () {
    });
    jQuery(inputPesoFinal).focusout(function () {
    });
}

function exibirDOMFaixaPeso(index) {
    if (jQuery('#trDOMFaixaPeso_' + index).is(':visible')) {
        jQuery('#img_' + index).attr('src', 'img/plus.jpg');
        jQuery('#trDOMFaixaPeso_' + index).css('display', 'none');
    } else {
        jQuery('#img_' + index).attr('src', 'img/minus.jpg');
        jQuery('#trDOMFaixaPeso_' + index).css('display', '');
    }
}

function removeItemDom(index) {
    var conf = confirm("Tem certeza que deseja excluir essa tabela?");
    if (conf) {
        jQuery('#trTitulo_' + index).hide();
        jQuery('#trDom_' + index).hide();
        jQuery('#trDOMFaixaPeso_' + index).hide();
        jQuery('#isExcluido_' + index).val('true');
        jQuery('input[id^="isExcluidoFP_' + index + '"]').each(function (i) {
            var indice = i + 1;
            jQuery('#isExcluidoFP_' + index + '_' + indice).val('true');
        });
    }
}

function removeItemDomFp(tabela, index) {
    var conf = confirm("Tem certeza que deseja excluir essa faixa de peso?");
    if (conf) {
        jQuery('#trTituloFp_' + tabela + '_' + index).hide();
        jQuery('#trDomFp_' + tabela + '_' + index).hide();
        jQuery('#isExcluidoFP_' + tabela + '_' + index).val('true');
    }
}

function validaFaixasPeso() {
    var existePrimeiraFaixa = false;
    var existePesoNegativo = false;
    var qtdTabelas = jQuery('#qtdTabPreceCiaAerea').val();
    var validar;
    // Mateus ajudou a criar o comando abaixo, ele busca as TR que tem id com qualquer parte igual a trDom e valida se ele está display none.
    jQuery.each(jQuery('#dvInfoTabPrecoCiaAerea table tbody tr[id*="trDom"]'),function(i,e){if(e.style.display != 'none'){validar = true; return false;}});
    // não validar significa que não temos tabelas aereas a validar as faixas de peso.
    if (!validar) {
        return true;
    }
    for (var i = 1; i <= qtdTabelas; i++) {
        existePrimeiraFaixa = false;
        existePesoNegativo = false;
        var qtdFaixas = jQuery('#qtdTabFaixaPeso_' + i).val();
        for (var j = 1; j <= qtdFaixas; j++) {
            var pesoInicial = parseFloat(jQuery('#pesoinicial_' + i + '_' + j).val());
            var pesoFinal = jQuery('#pesofinal_' + i + '_' + j).val();
            var valorQuilo = jQuery('#valorporquilo_' + i + '_' + j).val();
            if (pesoInicial == 0) {
                existePrimeiraFaixa = true;
            }
            if (pesoInicial < 0 || pesoFinal < 0 || valorQuilo < 0) {
                existePesoNegativo = true;
            }
        }
            if (!existePrimeiraFaixa) {
                alert("Existem tabelas sem faixa de peso iniciando em 0");
                return false;
            } else if (existePesoNegativo) {
                alert("Não são aceitos valores nagativos nas faixas de peso.");
                return false;
            }
        }
        
        return true;
    }
