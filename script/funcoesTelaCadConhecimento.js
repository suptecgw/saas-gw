  //TODO: Onde atribuir o freteminimo? em valor_outros?
function verificaFreteMinimo(){//se nao for combinado ou nao for peso por faixa obrigue o frete minimo
    if (parseFloat($('tipotaxa').value) == "3"){return false;}
	var aliqTabelaMin = $('aliquota').value;
	if ($('fi_uf').value == 'MG' && $('con_uf').value == 'MG' && $('idconsignatario').value == $('idremetente').value
		&& ($('rem_st_mg').value == 'true' || $('rem_st_mg').value == 't')){aliqTabelaMin = 14.4;}
    var totalX = parseFloat($("total").value);
    var zeraTaxa = true;
    if (tarifas.is_desconsidera_taxa_minimo == true || tarifas.is_desconsidera_taxa_minimo == 't' || tarifas.is_desconsidera_taxa_minimo == 'true'){
      totalX = parseFloat(totalX) - parseFloat($("valor_taxa_fixa").value);
      zeraTaxa = false;
    }
    var zeraDespacho = true;
    if (tarifas.is_desconsidera_despacho_minimo == true || tarifas.is_desconsidera_despacho_minimo == 't' || tarifas.is_desconsidera_despacho_minimo == 'true'){
      totalX = parseFloat(totalX) - parseFloat($("valor_despacho").value);
      zeraDespacho = false;
    }
    var zeraSec = true;
    if (tarifas.is_desconsidera_seccat_minimo == true || tarifas.is_desconsidera_seccat_minimo == 't' || tarifas.is_desconsidera_seccat_minimo == 'true'){
      totalX = parseFloat(totalX) - parseFloat($("valor_sec_cat").value);
      zeraSec = false;
    }
    var zeraOutros = true;
    if (tarifas.is_desconsidera_outros_minimo == true || tarifas.is_desconsidera_outros_minimo == 't' || tarifas.is_desconsidera_outros_minimo == 'true'){
      totalX = parseFloat(totalX) - parseFloat($("valor_outros").value);
      zeraOutros = false;
    }
    var zeraGris = true;
    if (tarifas.is_desconsidera_gris_minimo == true || tarifas.is_desconsidera_gris_minimo == 't' || tarifas.is_desconsidera_gris_minimo == 'true'){
      totalX = parseFloat(totalX) - parseFloat($("valor_gris").value);
      zeraGris = false;
    }
    var zeraPedagio = true;
    if (tarifas.is_desconsidera_pedagio_minimo == true || tarifas.is_desconsidera_pedagio_minimo == 't' || tarifas.is_desconsidera_pedagio_minimo == 'true'){
      totalX = parseFloat(totalX) - parseFloat($("valor_pedagio").value);
      zeraPedagio = false;
    }
    var zeraSeguro = true;
    var seguroX = 0;
    if (tarifas.is_desconsidera_seguro_minimo == true || tarifas.is_desconsidera_seguro_minimo == 't' || tarifas.is_desconsidera_seguro_minimo == 'true'){
        var raizConsignatario = $("con_cnpj").value.replace(/[^\d]+/g,'');raizConsignatario = raizConsignatario.substring(0,8);
        var raizRedespacho = $("red_cnpj").value.replace(/[^\d]+/g,'');raizRedespacho = raizRedespacho.substring(0,8);
      seguroX = getFreteValor($("vlmercadoria").value,tarifas.percentual_advalorem,tarifas.percentual_nf,tarifas.base_nf_percentual,tarifas.valor_percentual_nf,
                                                    $("tipotaxa").value,'p',tarifas.formula_seguro,tarifas.formula_percentual,$('peso').value,$('volume').value, $('qtdPallets').value,
                                                    $('distancia_km').value, $('tipoveiculo').value,tarifas.is_considerar_maior_peso,$("cub_base").value,$("cub_metro").value,(raizConsignatario == raizRedespacho),$("redespacho_valor").value,
                                                    $('qtde_entregas').value,$("tipoTransporte").value, tarifas.tipo_inclusao_icms, aliqTabelaMin, true,$("tipo_arredondamento_peso_con").value);
      totalX = parseFloat(totalX) - parseFloat(seguroX);
      zeraSeguro = false;
    }  //se o total estiver menor que o frete minimo, entao o minimo prevalecerá
    if (isFreteMinimo(totalX,tarifas.valor_frete_minimo, tarifas.formula_minimo, $('tipotaxa').value, $('peso').value, $('vlmercadoria').value, $('volume').value, $("qtdPallets").value, $('distancia_km').value, $('tipoveiculo').value,tarifas.is_considerar_maior_peso,$("cub_base").value,$("cub_metro").value,$('qtde_entregas').value,$('tipoTransporte').value, tarifas.tipo_inclusao_icms, $("aliquota").value, tarifas.is_desconsidera_icms_minimo,$("tipo_arredondamento_peso_con").value)){
        alert("O total do frete é menor que o mínimo, prevalecerá o mínimo");
        var vlMinimo = getFreteMinimo(tarifas.valor_frete_minimo, tarifas.formula_minimo, $('tipotaxa').value, $('peso').value, $('vlmercadoria').value, $('volume').value, $("qtdPallets").value, $('distancia_km').value, $('tipoveiculo').value,tarifas.is_considerar_maior_peso,$("cub_base").value,$("cub_metro").value,$('qtde_entregas').value, $('tipoTransporte').value, tarifas.is_desconsidera_icms_minimo, tarifas.tipo_inclusao_icms, aliqTabelaMin,$("tipo_arredondamento_peso_con").value);
        $("valor_peso").value = "0.00";
        if (zeraSeguro){
            if ($('tipoTransporte').value == 'a'){
                $("valor_peso").value = formatoMoeda(parseFloat(vlMinimo));
            }else{
				if (tarifas.tipo_impressao_frete_minimo == 'p'){
					$("valor_frete").value = '0.00';
					$("valor_peso").value = formatoMoeda(parseFloat(vlMinimo));
				}else{
					$("valor_frete").value = formatoMoeda(parseFloat(vlMinimo));
					$("valor_peso").value = '0.00';}}
        }else{
            if ($('tipoTransporte').value == 'a'){
                $("valor_peso").value = formatoMoeda(parseFloat(vlMinimo));
                $("valor_frete").value = formatoMoeda(parseFloat(seguroX));
            }else{if (tarifas.tipo_impressao_frete_minimo == 'p'){$("valor_peso").value = formatoMoeda(parseFloat(vlMinimo));$("valor_frete").value = formatoMoeda(parseFloat(seguroX));
            }else{$("valor_frete").value = formatoMoeda(parseFloat(vlMinimo)+parseFloat(seguroX));}}}
        if (zeraTaxa){$("valor_taxa_fixa").value = "0.00";}
        if (zeraDespacho){$("valor_despacho").value = "0.00";}
        if (zeraSec){$("valor_sec_cat").value = "0.00";}
        if (zeraOutros){$("valor_outros").value = "0.00";}
        if (zeraGris){$("valor_gris").value = "0.00";}
        if (zeraPedagio){$("valor_pedagio").value = "0.00";}
        $("valor_desconto").value = "0.00";
        if (tarifas.is_desconsidera_icms_minimo == true || tarifas.is_desconsidera_icms_minimo == 't' || tarifas.is_desconsidera_icms_minimo == 'true'){
            $("incluirIcms").checked = false;$('addicms').value = false;$("incluirFederais").checked = false;
        }  //flag para a atualizacao do calculo
	    if (arguments[0] == false){return false;}recalcular(false);
        return true;
    }
    return false;
}

function tipoComissaoR() {
    $("localiza_redspt").style.display = "none";
    $("botao_redspt").style.display = "none";
    $("tipotaxaredesp").className = "inputReadOnly";
    $("tipotaxaredesp").disabled = true;
    $("vlredespachante").className = "inputReadOnly";
    $("vlredespachante").readOnly = true;
}

function tipoComissaoV() {
    $("localiza_vendedor").style.display = "none";
    $("botao_vendedor").style.display = "none";
    $("comissao_vendedor").className = "inputReadOnly";
    $("comissao_vendedor").readOnly = true;
}

function alteraFpagSaldo(){
    $('cartaFPagSaldoFavorecido').style.display = 'none';
    $('lblfavorecido').style.display = 'none';
    if ($('cartaFPagSaldo').value == '3' || $('cartaFPagSaldo').value == '4'
            || $('cartaFPagSaldo').value == '11' || $('cartaFPagSaldo').value == '13'
            || $('cartaFPagSaldo').value == '14' || $('cartaFPagSaldo').value == '16' 
            || $('cartaFPagSaldo').value == '17' || $('cartaFPagSaldo').value == '18' 
            || $('cartaFPagSaldo').value == '20'){
        $('cartaFPagSaldoFavorecido').style.display = '';
        $('lblfavorecido').style.display = '';
    }
}

function AlternarAbas(menu, conteudo) {
    for (i = 0; i < arAbas.length; i++) {
        m = document.getElementById(arAbas[i].menu);
        m.className = 'menu';
        c = document.getElementById(arAbas[i].conteudo)
        invisivel(c);
        //invisivel($(c.id.replace("div", "tr")));
    }
    m = document.getElementById(menu)
    m.className = 'menu-sel';
    c = document.getElementById(conteudo);
    visivel(c);
    //visivel($(conteudo.replace("div", "tr")));
}

function stAba(menu, conteudo) {
    this.menu = menu;
    this.conteudo = conteudo;
}

//function montarSelectUF(select){
//    
//    console.log("select: " + select);
//
//    var _select_uf = Builder.node("select", {
//        id: "teste",
//        name: "teste",
//        className: "inputtexto"
//    });
//
//    var _opt_uf_AC = Builder.node("option", {value: "AC"});
//    _opt_uf_AC.innerHTML = "AC";
//    var _opt_uf_AL = Builder.node("option", {value: "AL"});
//    _opt_uf_AL.innerHTML = "AL";
//    var _opt_uf_AM = Builder.node("option", {value: "AM"});
//    _opt_uf_AM.innerHTML = "AM";
//    var _opt_uf_AP = Builder.node("option", {value: "AP"});
//    _opt_uf_AP.innerHTML = "AP";
//    var _opt_uf_BA = Builder.node("option", {value: "BA"});
//    _opt_uf_BA.innerHTML = "BA";
//    var _opt_uf_CE = Builder.node("option", {value: "CE"});
//    _opt_uf_CE.innerHTML = "CE";
//    var _opt_uf_DF = Builder.node("option", {value: "DF"});
//    _opt_uf_DF.innerHTML = "DF";
//    var _opt_uf_ES = Builder.node("option", {value: "ES"});
//    _opt_uf_ES.innerHTML = "ES";
//    var _opt_uf_GO = Builder.node("option", {value: "GO"});
//    _opt_uf_GO.innerHTML = "GO";
//    var _opt_uf_MA = Builder.node("option", {value: "MA"});
//    _opt_uf_MA.innerHTML = "MA";
//    var _opt_uf_MG = Builder.node("option", {value: "MG"});
//    _opt_uf_MG.innerHTML = "MG";
//    var _opt_uf_MS = Builder.node("option", {value: "MS"});
//    _opt_uf_MS.innerHTML = "MS";
//    var _opt_uf_MT = Builder.node("option", {value: "MT"});
//    _opt_uf_MT.innerHTML = "MT";
//    var _opt_uf_PA = Builder.node("option", {value: "PA"});
//    _opt_uf_PA.innerHTML = "PA";
//    var _opt_uf_PB = Builder.node("option", {value: "PB"});
//    _opt_uf_PB.innerHTML = "PB";
//    var _opt_uf_PE = Builder.node("option", {value: "PE"});
//    _opt_uf_PE.innerHTML = "PE";
//    var _opt_uf_PI = Builder.node("option", {value: "PI"});
//    _opt_uf_PI.innerHTML = "PI";
//    var _opt_uf_PR = Builder.node("option", {value: "PR"});
//    _opt_uf_PR.innerHTML = "PR";
//    var _opt_uf_RJ = Builder.node("option", {value: "RJ"});
//    _opt_uf_RJ.innerHTML = "RJ";
//    var _opt_uf_RN = Builder.node("option", {value: "RN"});
//    _opt_uf_RN.innerHTML = "RN";
//    var _opt_uf_RO = Builder.node("option", {value: "RO"});
//    _opt_uf_RO.innerHTML = "RO";
//    var _opt_uf_RR = Builder.node("option", {value: "RR"});
//    _opt_uf_RR.innerHTML = "RR";
//    var _opt_uf_RS = Builder.node("option", {value: "RS"});
//    _opt_uf_RS.innerHTML = "RS";
//    var _opt_uf_SC = Builder.node("option", {value: "SC"});
//    _opt_uf_SC.innerHTML = "SC";
//    var _opt_uf_SE = Builder.node("option", {value: "SE"});
//    _opt_uf_SE.innerHTML = "SE";
//    var _opt_uf_SP = Builder.node("option", {value: "SP"});
//    _opt_uf_SP.innerHTML = "SP";
//    var _opt_uf_TO = Builder.node("option", {value: "TO"});
//    _opt_uf_TO.innerHTML = "TO";
//    var _opt_uf_EX = Builder.node("option", {value: "EX"});
//    _opt_uf_EX.innerHTML = "EX";
//    
//    _select_uf.appendChild(_opt_uf_AC);
//    _select_uf.appendChild(_opt_uf_AL);
//    _select_uf.appendChild(_opt_uf_AM);
//    _select_uf.appendChild(_opt_uf_AP);
//    _select_uf.appendChild(_opt_uf_BA);
//    _select_uf.appendChild(_opt_uf_CE);
//    _select_uf.appendChild(_opt_uf_DF);
//    _select_uf.appendChild(_opt_uf_ES);
//    _select_uf.appendChild(_opt_uf_GO);
//    _select_uf.appendChild(_opt_uf_MA);
//    _select_uf.appendChild(_opt_uf_MG);
//    _select_uf.appendChild(_opt_uf_MS);
//    _select_uf.appendChild(_opt_uf_MT);
//    _select_uf.appendChild(_opt_uf_PA);
//    _select_uf.appendChild(_opt_uf_PB);
//    _select_uf.appendChild(_opt_uf_PE);
//    _select_uf.appendChild(_opt_uf_PI);
//    _select_uf.appendChild(_opt_uf_PR);
//    _select_uf.appendChild(_opt_uf_RJ);
//    _select_uf.appendChild(_opt_uf_RN);
//    _select_uf.appendChild(_opt_uf_RO);
//    _select_uf.appendChild(_opt_uf_RR);
//    _select_uf.appendChild(_opt_uf_RS);
//    _select_uf.appendChild(_opt_uf_SC);
//    _select_uf.appendChild(_opt_uf_SE);
//    _select_uf.appendChild(_opt_uf_SP);
//    _select_uf.appendChild(_opt_uf_TO);
//    _select_uf.appendChild(_opt_uf_EX);
//    
//    
//    $("#ufInicio").append(_select_uf);
//    
//    
//    $("informacaouf").appendChild(document.createElement("div").appendChild(_select_uf));
//      
//}

function ControlarTalonario(isControlarTalonario) {
    if (isControlarTalonario == true || isControlarTalonario == 't' || isControlarTalonario == 'true') {
        if (parseFloat($('cartaValorAdiantamento').value) != 0 && $('cartaFPagAdiantamento').value == '3' && $('cartaDocAdiantamento_cb').value == '') {
            return alertMsg("Informe o número do cheque corretamente para o adiantamento.");
        }
        if (parseFloat($('cartaValorAdiantamentoExtra1').value) != 0 && $('cartaFPagAdiantamentoExtra1').value == '3' && $('cartaDocAdiantamento_cbExtra1').value == '') {
            return alertMsg("Informe o número do cheque corretamente para o adiantamento.");
        }
        if (parseFloat($('cartaValorAdiantamentoExtra2').value) != 0 && $('cartaFPagAdiantamentoExtra2').value == '3' && $('cartaDocAdiantamento_cbExtra2').value == '') {
            return alertMsg("Informe o número do cheque corretamente para o adiantamento.");
        }
    } else {
        if (parseFloat($('cartaValorAdiantamento').value) != 0 && $('cartaFPagAdiantamento').value == '3' && $('cartaDocAdiantamento').value == '') {
            return alertMsg("Informe o número do cheque corretamente para o adiantamento.");
        }
        if (parseFloat($('cartaValorAdiantamentoExtra1').value) != 0 && $('cartaFPagAdiantamentoExtra1').value == '3' && $('cartaDocAdiantamentoExtra1').value == '') {
            return alertMsg("Informe o número do cheque corretamente para o adiantamento.");
        }
        if (parseFloat($('cartaValorAdiantamentoExtra2').value) != 0 && $('cartaFPagAdiantamentoExtra2').value == '3' && $('cartaDocAdiantamentoExtra2').value == '') {
            return alertMsg("Informe o número do cheque corretamente para o adiantamento.");
        }
    }
}

function atribuiVlrsDaTaxa(zerarCampos, idTipoTaxa) {
    var raizConsignatario = $("con_cnpj").value.replace(/[^\d]+/g, '');
    raizConsignatario = raizConsignatario.substring(0, 8);
    var raizRedespacho = $("red_cnpj").value.replace(/[^\d]+/g, '');
    raizRedespacho = raizRedespacho.substring(0, 8);
    var isRedespachoTabela = (raizConsignatario == raizRedespacho ? true : false);
    var valorRedespachoLiquido = parseFloat($("redespacho_valor").value) - parseFloat($("redespacho_valor_icms").value);
    //se n selecionou um tipo de taxa, saia
    if ((idTipoTaxa == "-1") || (idTipoTaxa == "3" && $('tipoveiculo').value == "-1")) {
        return null;
    }
    //Validando se houve alteração no peso, volume, cubagem ou valor da mercadoria do orçamento.
    if ($('numero_orcamento').value != '') {
        //Verificando se houve alteração no peso
        if (parseFloat($('peso_orcamento').value) != parseFloat($('peso').value)) {
            if (!confirm('O peso do CT (' + parseFloat($('peso').value) + ') está diferente do peso do orçamento (' + parseFloat($('peso_orcamento').value) + '), deseja recalcular o valor do frete?')) {
                return null;
            }
        } //Verificando se houve alteração no peso
        if (parseFloat($('volume_orcamento').value) != parseFloat($('volume').value)) {
            if (!confirm('O volume do CT (' + parseFloat($('volume').value) + ') está diferente do volume do orçamento (' + parseFloat($('volume_orcamento').value) + '), deseja recalcular o valor do frete?')) {
                return null;
            }
        } //Verificando se houve alteração no valor da mercadoria
        if (parseFloat($('mercadoria_orcamento').value) != parseFloat($('vlmercadoria').value)) {
            if (!confirm('O valor das mercadorias do CT (' + parseFloat($('vlmercadoria').value) + ') está diferente do valor das mercadorias do orçamento (' + parseFloat($('mercadoria_orcamento').value) + '), deseja recalcular o valor do frete?')) {
                return null;
            }
        } //Verificando se houve alteração no valor da mercadoria
        if (parseFloat($('cubagem_orcamento').value) != parseFloat($('cub_metro').value)) {
            if (!confirm('A cubagem do CT (' + parseFloat($('cub_metro').value) + ') está diferente da cubagem do orçamento (' + parseFloat($('cubagem_orcamento').value) + '), deseja recalcular o valor do frete?')) {
                return null;
            }
        }
    }//se nao fez uma requisicao de busca de taxa anteriormente e o tipo do frete nao é "combinado"...
    if (buscouTaxas == "-1") {
        alteraTipoTaxa($("tipotaxa").value);
        return null;
    }
    $('addicms').value = 'false';
    var pesoCubado = 0;
    if ($('tipoTransporte').value == 'a') {
        $("cub_base").value = (tarifas.base_cubagem_aereo == undefined ? "0" : tarifas.base_cubagem_aereo);
    } else {
        $("cub_base").value = (tarifas.base_cubagem == undefined ? "0" : tarifas.base_cubagem);
    }
    var peso_para_calculo_frete = parseFloat($("peso").value);
    if ($('con_inclui_peso_container').value == true || $('con_inclui_peso_container').value == 't' || $('con_inclui_peso_container').value == 'true') {
        var peso_para_calculo_frete = parseFloat($("peso").value) + parseFloat($('peso_container').value);
    }
    //Aliquota do ICMS em caso de inclusão de CTRC pelo item
    var aliqTabela = $('aliquota').value;
    if ($('fi_uf').value == 'MG' && $('con_uf').value == 'MG' && $('idconsignatario').value == $('idremetente').value
            && ($('rem_st_mg').value == 'true' || $('rem_st_mg').value == 't')) {
        aliqTabela = 14.4;
    }
    //para a story 4092(PROB) os campos de ITR, ADEME e DESCONTO devem ser zerados
    $("valor_itr").value = "0,00";
    $("valor_ademe").value = "0,00";
    $("valor_desconto").value = "0,00";
    //chaveador de tipo de taxa
    switch (idTipoTaxa) {
        //Peso/Kg
        case "0" :
            //Verificando se o peso kg é menor que o peso cubado
            var base = parseFloat($("cub_base").value);
            var metro = parseFloat($("cub_metro").value);
            var pesoCubado = 0;
            if ($('tipoTransporte').value == 'a') {
                pesoCubado = (parseFloat(metro) * parseFloat(1000000)) / parseFloat(base);
            } else {
                pesoCubado = base * metro;
            }
            pesoCubado = parseFloat(pesoCubado);
            if (tarifas.is_considerar_maior_peso && parseFloat($("peso").value) < pesoCubado) {
                $('tipotaxa').value = '1';
                alteraTipoTaxa('1');
                showFields('1');
                return null;
            }
            $("valor_peso").value = getFretePeso(peso_para_calculo_frete, $("volume").value, $("tipotaxa").value, tarifas.valor_peso, tarifas.valor_volume, $("cub_base").value,
                    $("cub_metro").value, tarifas.valor_veiculo, tarifas.valor_por_faixa, $("tipoTransporte").value, tarifas.valor_excedente_aereo, tarifas.valor_excedente,
                    tarifas.maximo_peso_final, tarifas.ispreco_tonelada, tarifas.tipo_frete_peso, tarifas.valor_maximo_peso_final, tarifas.valor_km, tarifas.is_considerar_maior_peso,
                    tarifas.tipo_impressao_percentual, $("vlmercadoria").value, tarifas.base_nf_percentual, tarifas.valor_percentual_nf, tarifas.percentual_nf, $("qtdPallets").value,
                    $("distancia_km").value, tarifas.formula_volumes, $('tipoveiculo').value, tarifas.formula_percentual, tarifas.valor_pallet, tarifas.formula_pallet,
                    isRedespachoTabela, valorRedespachoLiquido, $('qtde_entregas').value, tarifas.formula_frete_peso, tarifas.tipo_inclusao_icms, aliqTabela, false, $("tipo_arredondamento_peso_con").value);
            break;
            //Peso/Cubagem
        case "1" :
            var base = parseFloat($("cub_base").value);
            var metro = parseFloat($("cub_metro").value);
            //Verificando se o peso kg é menor que o peso cubado
            var pesoCubado = 0;
            if ($('tipoTransporte').value == 'a') {
                pesoCubado = (parseFloat(metro) * parseFloat(1000000)) / parseFloat(base);
                $("cub_base").value = tarifas.base_cubagem_aereo;
            } else {
                pesoCubado = base * metro;
                $("cub_base").value = tarifas.base_cubagem;
            }
            pesoCubado = parseFloat(pesoCubado);
            $('cub_peso').value = formatoMoeda(pesoCubado);
            calculaPesoTaxadoCtrc();
            if (tarifas.is_considerar_maior_peso && parseFloat($("peso").value) > pesoCubado) {
                $('tipotaxa').value = '0';
                alteraTipoTaxa('0');
                showFields('0');
                return null;
            }
            if (tarifas.is_considerar_maior_peso && tarifas.tipo_frete_peso == "f" && parseFloat(formatoMoeda(tarifas.peso_calculo, 3)) < parseFloat(formatoMoeda(pesoCubado, 3))) {
                $('tipotaxa').value = '1';
                alteraTipoTaxa('1');
                showFields('1');
                return null;
            }
            $("valor_peso").value = getFretePeso($("peso").value, $("volume").value, $("tipotaxa").value, tarifas.valor_peso, tarifas.valor_volume, $("cub_base").value, $("cub_metro").value, tarifas.valor_veiculo, tarifas.valor_por_faixa,
                    $("tipoTransporte").value, tarifas.valor_excedente_aereo, tarifas.valor_excedente, tarifas.maximo_peso_final, tarifas.ispreco_tonelada, tarifas.tipo_frete_peso,
                    tarifas.valor_maximo_peso_final, tarifas.valor_km, tarifas.is_considerar_maior_peso, tarifas.tipo_impressao_percentual, $("vlmercadoria").value, tarifas.base_nf_percentual,
                    tarifas.valor_percentual_nf, tarifas.percentual_nf, $("qtdPallets").value, $("distancia_km").value, tarifas.formula_volumes, $('tipoveiculo').value,
                    tarifas.formula_percentual, tarifas.valor_pallet, tarifas.formula_pallet, isRedespachoTabela, valorRedespachoLiquido, $('qtde_entregas').value,
                    tarifas.formula_frete_peso, tarifas.tipo_inclusao_icms, aliqTabela, false, $("tipo_arredondamento_peso_con").value);
            break;  //Percentual sobre nota fiscal
        case "2":
            $("valor_peso").value = getFretePeso($("peso").value, $("volume").value, $("tipotaxa").value, tarifas.valor_peso, tarifas.valor_volume, $("cub_base").value,
                    $("cub_metro").value, tarifas.valor_veiculo, tarifas.valor_por_faixa, $("tipoTransporte").value, tarifas.valor_excedente_aereo, tarifas.valor_excedente,
                    tarifas.maximo_peso_final, tarifas.ispreco_tonelada, tarifas.tipo_frete_peso, tarifas.valor_maximo_peso_final, tarifas.valor_km, tarifas.is_considerar_maior_peso,
                    tarifas.tipo_impressao_percentual, $("vlmercadoria").value, tarifas.base_nf_percentual, tarifas.valor_percentual_nf, tarifas.percentual_nf, $("qtdPallets").value,
                    $("distancia_km").value, tarifas.formula_volumes, $('tipoveiculo').value, tarifas.formula_percentual, tarifas.valor_pallet, tarifas.formula_pallet,
                    isRedespachoTabela, valorRedespachoLiquido, $('qtde_entregas').value, tarifas.formula_frete_peso, tarifas.tipo_inclusao_icms, aliqTabela, false, $("tipo_arredondamento_peso_con").value);
            break;
            //frete combinado
        case "3":
            if (tarifas.tipo_taxa_combinado == 1) {
                $("valor_peso").value = (tarifas.valor_veiculo == undefined ? "0.00" : tarifas.valor_veiculo);
            } else if (tarifas.tipo_taxa_combinado == 2) {
                $("valor_peso").value = formatoMoeda((tarifas.valor_veiculo == undefined ? "0.00" : parseFloat(tarifas.valor_veiculo) * parseFloat($("peso").value)));
            } else if (tarifas.tipo_taxa_combinado == 3) {
                $("valor_peso").value = formatoMoeda((tarifas.valor_veiculo == undefined ? "0.00" : parseFloat(tarifas.valor_veiculo) * parseFloat($("peso").value) / 1000));
            } else {
                $("valor_peso").value = '0.00';
            }
            break;
            //frete por volume
        case "4":
            $("valor_peso").value = getFretePeso($("peso").value, $("volume").value, $("tipotaxa").value, tarifas.valor_peso, tarifas.valor_volume, $("cub_base").value,
                    $("cub_metro").value, tarifas.valor_veiculo, tarifas.valor_por_faixa, $("tipoTransporte").value, tarifas.valor_excedente_aereo, tarifas.valor_excedente,
                    tarifas.maximo_peso_final, tarifas.ispreco_tonelada, tarifas.tipo_frete_peso, tarifas.valor_maximo_peso_final, tarifas.valor_km, tarifas.is_considerar_maior_peso,
                    tarifas.tipo_impressao_percentual, $("vlmercadoria").value, tarifas.base_nf_percentual, tarifas.valor_percentual_nf, tarifas.percentual_nf, $("qtdPallets").value,
                    $("distancia_km").value, tarifas.formula_volumes, $('tipoveiculo').value, tarifas.formula_percentual, tarifas.valor_pallet, tarifas.formula_pallet, false, 0, $('qtde_entregas').value,
                    tarifas.formula_frete_peso, tarifas.tipo_inclusao_icms, aliqTabela, false, $("tipo_arredondamento_peso_con").value);
            break;
            //frete por km
        case "5":
            if (zerarCampos) {
                $("valor_peso").value = "0.00";
            }
            $("valor_peso").value = formatoMoeda(tarifas.valor_km);
            break;
            //frete por pallet
        case "6":
            $("valor_peso").value = getFretePeso($("peso").value, $("volume").value, $("tipotaxa").value, tarifas.valor_peso, tarifas.valor_volume, $("cub_base").value,
                    $("cub_metro").value, tarifas.valor_veiculo, tarifas.valor_por_faixa, $("tipoTransporte").value, tarifas.valor_excedente_aereo, tarifas.valor_excedente,
                    tarifas.maximo_peso_final, tarifas.ispreco_tonelada, tarifas.tipo_frete_peso, tarifas.valor_maximo_peso_final, tarifas.valor_km, tarifas.is_considerar_maior_peso,
                    tarifas.tipo_impressao_percentual, $("vlmercadoria").value, tarifas.base_nf_percentual, tarifas.valor_percentual_nf, tarifas.percentual_nf, $("qtdPallets").value,
                    $("distancia_km").value, tarifas.formula_volumes, $('tipoveiculo').value, tarifas.formula_percentual, tarifas.valor_pallet, tarifas.formula_pallet, false, 0, $('qtde_entregas').value,
                    tarifas.formula_frete_peso, tarifas.tipo_inclusao_icms, aliqTabela, false, $("tipo_arredondamento_peso_con").value);
            break;
    }
    if (tarifas.previsao_entrega_calculada == undefined || tarifas.previsao_entrega_calculada == '') {
        if ($('id_rota_viagem').value == 0) {
            $('dtprevisao').value = '';
        } else {
            getPrevisaoEntrega();
        }
    } else {
        $('dtprevisao').value = tarifas.previsao_entrega_calculada;
    }
    var raizConsignatario = $("con_cnpj").value.replace(/[^\d]+/g, '');
    raizConsignatario = raizConsignatario.substring(0, 8);
    var raizRedespacho = $("red_cnpj").value.replace(/[^\d]+/g, '');
    raizRedespacho = raizRedespacho.substring(0, 8);
    $("valor_frete").value = getFreteValor($("vlmercadoria").value, tarifas.percentual_advalorem, tarifas.percentual_nf, tarifas.base_nf_percentual, tarifas.valor_percentual_nf,
            $("tipotaxa").value, tarifas.tipo_impressao_percentual, tarifas.formula_seguro, tarifas.formula_percentual, $('peso').value, $('volume').value, $('qtdPallets').value,
            $('distancia_km').value, $('tipoveiculo').value, tarifas.is_considerar_maior_peso, $("cub_base").value, $("cub_metro").value, (raizConsignatario == raizRedespacho), //Só calcular se o redespacho for igual a o consignatário
            valorRedespachoLiquido, $('qtde_entregas').value, $("tipoTransporte").value, tarifas.tipo_inclusao_icms, aliqTabela, true, $("tipo_arredondamento_peso_con").value);
    $("valor_pedagio").value = getPedagio($('peso').value, tarifas.vl_pedagio, tarifas.qtd_kg_pedagio, idTipoTaxa, pesoCubado, tarifas.formula_pedagio, $('vlmercadoria').value, $('volume').value, $('qtdPallets').value, $('distancia_km').value, $('tipoveiculo').value, tarifas.is_considerar_maior_peso, tarifas.base_cubagem, $('cub_metro').value, $('qtde_entregas').value, $('tipoTransporte').value, tarifas.tipo_inclusao_icms, aliqTabela, $("tipo_arredondamento_peso_con").value);
    $("valor_outros").value = getOutros(tarifas.valor_outros, tarifas.formula_outros, $('tipotaxa').value, $('peso').value, $('vlmercadoria').value, $('volume').value, $('qtdPallets').value, $('distancia_km').value, $('tipoveiculo').value, tarifas.is_considerar_maior_peso, $("cub_base").value, $("cub_metro").value, $('qtde_entregas').value, $('tipoTransporte').value, tarifas.tipo_inclusao_icms, aliqTabela, $("tipo_arredondamento_peso_con").value);
    $("valor_gris").value = getGris(tarifas.percentual_gris, $("vlmercadoria").value, tarifas.valor_minimo_gris, tarifas.formula_gris, $('tipotaxa').value, $('peso').value, $('volume').value, $('qtdPallets').value, $('distancia_km').value, $('tipoveiculo').value, tarifas.is_considerar_maior_peso, $("cub_base").value, $("cub_metro").value, $('qtde_entregas').value, $('tipoTransporte').value, tarifas.tipo_inclusao_icms, aliqTabela, $("tipo_arredondamento_peso_con").value); //calcula o percentual do gris
    $("valor_despacho").value = getValorDespacho(tarifas.valor_despacho, tarifas.formula_despacho, $('tipotaxa').value, $('peso').value, $('vlmercadoria').value, $('volume').value, $('qtdPallets').value, $('distancia_km').value, $('tipoveiculo').value, tarifas.is_considerar_maior_peso, $("cub_base").value, $("cub_metro").value, $('qtde_entregas').value, $('tipoTransporte').value, tarifas.tipo_inclusao_icms, aliqTabela, $("tipo_arredondamento_peso_con").value);
    $("valor_sec_cat").value = getValorSecCat(tarifas.valor_sec_cat, tarifas.formula_sec_cat, $('tipotaxa').value, $('peso').value, $('vlmercadoria').value, $('volume').value, $('qtdPallets').value, $('distancia_km').value, $('tipoveiculo').value, tarifas.is_considerar_maior_peso, $("cub_base").value, $("cub_metro").value, $('qtde_entregas').value, $('tipoTransporte').value, tarifas.peso_limite_sec_cat, tarifas.valor_excedente_sec_cat, tarifas.tipo_inclusao_icms, aliqTabela, $("tipo_arredondamento_peso_con").value);
    $("valor_taxa_fixa").value = getTaxaFixa(tarifas.valor_taxa_fixa, tarifas.formula_taxa_fixa, $('tipotaxa').value, $('peso').value, $('vlmercadoria').value, $('volume').value, $('qtdPallets').value, $('distancia_km').value, $('tipoveiculo').value, tarifas.is_considerar_maior_peso, $("cub_base").value, $("cub_metro").value, $('qtde_entregas').value, $('tipoTransporte').value, tarifas.peso_limite_taxa_fixa, tarifas.valor_excedente_taxa_fixa, tarifas.tipo_inclusao_icms, aliqTabela, $("tipo_arredondamento_peso_con").value);
    $("client_tariff_id").value = (tarifas.id == undefined ? 0 : tarifas.id);
    if (tarifas.is_inclui_impostos_federais) {
        $('incluirFederais').checked = true;
    }
    if (tarifas.isinclui_icms && tarifas.tipo_inclusao_icms == 't') {
        $('incluirIcms').checked = true;
        $('incluirIcms').onclick();
    }
    if (tarifas.is_considerar_valor_maior_peso_nota && ($('tipotaxa').value == "0" || $('tipotaxa').value == "1" || $('tipotaxa').value == "2")) {
        var mTpFrete = getTipoPreferencialPesoPercentualNotaFiscal($("peso").value, $("volume").value, $("tipotaxa").value, tarifas.valor_peso, tarifas.valor_volume, $("cub_base").value,
                $("cub_metro").value, tarifas.valor_veiculo, tarifas.valor_por_faixa, $("tipoTransporte").value, tarifas.valor_excedente_aereo, tarifas.valor_excedente,
                tarifas.maximo_peso_final, tarifas.ispreco_tonelada, tarifas.tipo_frete_peso, tarifas.valor_maximo_peso_final, tarifas.valor_km, tarifas.is_considerar_maior_peso,
                tarifas.tipo_impressao_percentual, $("vlmercadoria").value, tarifas.base_nf_percentual, tarifas.valor_percentual_nf, tarifas.percentual_nf, $("qtdPallets").value,
                $("distancia_km").value, tarifas.formula_volumes, $('tipoveiculo').value, tarifas.formula_percentual, tarifas.valor_pallet, tarifas.formula_pallet,
                isRedespachoTabela, valorRedespachoLiquido, $('qtde_entregas').value, tarifas.formula_frete_peso, tarifas.tipo_inclusao_icms, aliqTabela, false, $("tipo_arredondamento_peso_con").value);
        if (mTpFrete != $('tipotaxa').value) {
            $('tipotaxa').value = mTpFrete;
            alteraTipoTaxa($('tipotaxa').value);
            return null;
        }
    }
    recalcular(false);
}
