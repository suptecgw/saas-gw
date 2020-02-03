/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


function refreshClassTabs(element) { //Funcão criada apenas para funcionar a rotina de habilitar a guia pelo atalho
    for (var i = 1; i <= 10; i++) {
        var elm = $('aTab' + i);
        if (elm != null) {
            $(elm).removeClassName('active-tab');
            $(elm.href.match(/#(\w.+)/)[1]).removeClassName('active-tab-body');
        }
    }
    if (element != null) {
        $(element).addClassName('active-tab');
        $(element.href.match(/#(\w.+)/)[1]).addClassName('active-tab-body');
    }
}
function executarAtalhos(event) {
    if (event == 113) {
        incluiNF();
    } else if (event == 115) {
        var elm = $('aTab1');
        refreshClassTabs(elm);
    } else if (event == 119) {
        var elm = $('aTab2');
        refreshClassTabs(elm);
    } else if (event == 120) {
        var elm = $('aTab3');
        refreshClassTabs(elm);
    } else if (event == 121) {
        var elm = $('aTab4');
        refreshClassTabs(elm);
    }
}
function voltar() {
    jQuery('#bt_consultar').attr('disabled', true);
    parent.document.location.replace("ConsultaControlador?codTela=24");
}

function excluirColeta(id) {
    if (confirm("Deseja mesmo excluir esta Coleta?"))
        window.open("./cadcoleta?acao=excluir&idcoleta=" + id, 'excluirColeta', 'top=80,left=70,height=200,width=800,resizable=yes,status=1,scrollbars=1');
}

function totalHorimetro() {
    if (parseFloat($('horimFinal').value) > 0) {
        $("lbHorim").innerHTML = "=" + (parseFloat($('horimFinal').value) - parseFloat($("horimInicial").value));
    } else {
        $("lbHorim").innerHTML = "";
    }
}

function carregarAjaxTalaoCheque(textoresposta, elemento) {

    if (textoresposta == "-1") {
        alert('Houve algum problema ao requistar o novo cheque, favor informar manualmente.');
        return false;
    } else {

        var lista = jQuery.parseJSON(textoresposta);
        var listCheque = lista.list[0].documento;
        var talaoCheque;
        var slct = elemento;
        var isPrimeiro = true;

        var valor = "";
        removeOptionSelected(elemento.id);
        slct.appendChild(Builder.node('OPTION', {value: valor}, valor));
        var length = (listCheque != undefined && listCheque.length != undefined ? listCheque.length : 1);

        for (var i = 0; i < length; i++) {
            if (length > 1) {
                talaoCheque = listCheque[i];
                valor += (isPrimeiro ? talaoCheque : "");

            } else {
                talaoCheque = listCheque;
            }
            if (talaoCheque != null && talaoCheque != undefined) {
                slct.appendChild(Builder.node('OPTION', {value: talaoCheque}, talaoCheque));
            }
            isPrimeiro = false;
        }
        slct.value = valor;
    }
}

function validarBloqueioVeiculo(tipo) {

    if ($("is_bloqueado").value == "t" && tipo == "veiculo") {
        setTimeout(function () {
            alert("O veículo " + $("vei_placa").value + " está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
            $("idveiculo").value = "0";
            $("vei_placa").value = "";
        }, 100);
    }
    if ($("is_bloqueado").value == "t" && tipo == "carreta") {
        setTimeout(function () {
            alert("A carreta " + $("car_placa").value + " está bloqueada e não poderá ser utilizada no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
            $("idcarreta").value = "0";
            $("car_placa").value = "";
        }, 100);
    }
    if ($("is_bloqueado").value == "t" && tipo == "bitrem") {
        setTimeout(function () {
            alert("O Bi-trem " + $("bi_placa").value + " está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
            $("idbitrem").value = "0";
            $("bi_placa").value = "";
        }, 100);
    }
}

function validarBloqueioVeiculoMotorista(filtro) {
    setTimeout(function () {
        if ($("is_moto_veiculo_bloq").value == "t" && filtro == "veiculo_motorista") {
            alert("O veiculo " + $("vei_placa").value + ", vinculado ao motorista " + $("motor_nome").value + ", está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("moto_veiculo_bloq_motivo").value);
            $("idveiculo").value = "0";
            $("vei_placa").value = "";
        } else if ($("is_moto_carreta_bloq").value == "t" && filtro == "carreta_motorista") {
            alert("A carreta " + $("car_placa").value + ", vinculada ao motorista " + $("motor_nome").value + ", está bloqueada e não poderá ser utilizada no lançamento. \r\n Motivo: " + $("moto_carreta_bloq_motivo").value);
            $("idcarreta").value = "0";
            $("car_placa").value = "";
        } else if ($("is_moto_bitrem_bloq").value == "t" && filtro == "bitrem_motorista") {
            alert("O bi-trem " + $("bi_placa").value + ", vinculada ao motorista " + $("motor_nome").value + ", está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("moto_bitrem_bloq_motivo").value);
            $("idbitrem").value = "0";
            $("bi_placa").value = "";
        } else if ($("is_moto_tritrem_bloq").value == "t" && filtro == "tritrem_motorista") {
            alert("A 3ª Carreta " + $("tri_placa").value + ", vinculada ao motorista " + $("motor_nome").value + ", está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("moto_tritrem_bloq_motivo").value);
            $("idtritrem").value = "0";
            $("tri_placa").value = "";
        }
    }, 100);
}
function calcularRetencoes() {
    var vlDeducoes = 0;

    var elementoValorOutrasRetencoes = $('cartaRetencoes');
    var elementoPercentualRetencao = $('percentualRetencao');
    var elementoValorLiquido = $('cartaValorFrete');

    var valorRetencao = parseFloat(elementoValorOutrasRetencoes.value);
    var valorPercentualRetencao = parseFloat(elementoPercentualRetencao.value);
    var valorLiquido = 0;

    if (elementoValorLiquido.value.indexOf(',') !== -1) {
        // Tela de importação CTRC em Lote, o campo é formatado como reais (pontos e vírgulas).
        valorLiquido = parseFloat(colocarPonto(elementoValorLiquido.value));
    } else {
        // Tela de CTRC normal, o campo só é formatado com pontos para decimais.
        valorLiquido = parseFloat(elementoValorLiquido.value);
    }

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
            notReadOnly(elementoValorOutrasRetencoes, 'fieldMin style1');
            notReadOnly(elementoPercentualRetencao, 'fieldMin');
        } else if (valorPercentualRetencao !== 0 && valorRetencao === 0 && !elementoValorOutrasRetencoes.readOnly) {
            readOnly(elementoValorOutrasRetencoes, 'inputReadOnly8pt style1');
        } else if (valorPercentualRetencao === 0 && valorRetencao !== 0 && elementoValorOutrasRetencoes.readOnly) {
            notReadOnly(elementoValorOutrasRetencoes, 'fieldMin style1');
        } else if (valorRetencao !== 0 && valorPercentualRetencao === 0 && !elementoPercentualRetencao.readOnly) {
            readOnly(elementoPercentualRetencao, 'inputReadOnly8pt');
        } else if (valorRetencao === 0 && valorPercentualRetencao !== 0 && elementoPercentualRetencao.readOnly) {
            notReadOnly(elementoPercentualRetencao, 'fieldMin');
        }

        // Calcular
        if (valorPercentualRetencao !== 0 && elementoValorOutrasRetencoes.readOnly) {
            vlDeducoes = (valorLiquido * valorPercentualRetencao) / 100;
            vlDeducoes += (valorLiquido * parseFloat($("mot_outros_descontos_carta").value)) / 100;
        } else if (elementoPercentualRetencao.readOnly) {
            vlDeducoes = valorRetencao;
        }

        elementoValorOutrasRetencoes.value = colocarVirgula(vlDeducoes, null);
    }
}

function abrirLocalizarRemetente() {
    launchPopupLocate('./localiza?categoria=loc_cliente&acao=consultar&paramaux2=' + $('uf_dest').value + '&idlista=3' + '&paramaux3=' + $('cidade_destino_id').value, 'Remetente');
}

function abrirLocalizarDestinatario() {
    launchPopupLocate('./localiza?categoria=loc_cliente&paramaux2=' + $('rem_uf').value + '&acao=consultar&idlista=4' + '&paramaux3=' + $("idcidadeorigem").value, 'Destinatario');
}

function jsonTaxasColeta() {
    var tabela = JSON.parse($("json_taxas").value);
    var taxa_rota = 0;
    if (tabela) {
        for (let i in tabela) {
            if (tabela[i].tipo_veiculo == $('tipoveiculo').value) {
                taxa_rota = parseFloat(tabela[i].valor);
            }
        }
    }
    return taxa_rota;
}

function calcularTabelaMotorista() {
    var percentualValor = parseFloat($('percentual_valor_cte_calculo_cfe').value);
    var vlFrete = 0;
    var tbValorFrete = 0; // Pelo total da prestação
    var tbValorPesoCte = 0; // Pelo frete peso
    var tbValorFreteCte = 0; // Pelo frete valor
    var tbvalorNotaFiscal = 0; //pela Nota Fiscal
    if (percentualValor !== 0) {
//        tbValorFrete = parseFloat($('').value); // Pelo total da prestação
        tbValorPesoCte = parseFloat($("totalPeso").value); // Pelo frete peso
        tbValorFreteCte = parseFloat($("vlcombinado").value); // Pelo frete valor
        tbvalorNotaFiscal = parseFloat($('totalNF').value); // pela Nota Fiscal
        var tipoCalculoPercentualValorCFe = $('tipo_calculo_percentual_valor_cfe').value;
        if ($('calculo_valor_contrato_frete').value === 'ct') {
            if (tipoCalculoPercentualValorCFe === 'tp') {
                vlFrete = tbValorFreteCte * (percentualValor / 100);
            } else if (tipoCalculoPercentualValorCFe === 'fp') {
                vlFrete = tbValorPesoCte * (percentualValor / 100);
            } else if (tipoCalculoPercentualValorCFe === 'fv') {
                vlFrete = tbValorFreteCte * (percentualValor / 100);
            }
        } else if ($('calculo_valor_contrato_frete').value === 'nf') {
            vlFrete = tbvalorNotaFiscal * (percentualValor / 100);
        }

        if (vlFrete < parseFloat($('motorista_valor_minimo').value)) {
            vlFrete = parseFloat($('motorista_valor_minimo').value);
        }
    }
    return vlFrete;
}

function validarTipoVeiculo(tipo) {
    var tipoVeiculoMotorista = $("tipo_veiculo_motorista");
    var tipoVeiculoVeiculo = $("tipo_veiculo_veiculo");
    var tipoVeiculoCarreta = $("tipo_veiculo_carreta");

    if (tipo == 'c') {
        if ((tipoVeiculoMotorista.value == '0' || tipoVeiculoMotorista.value == tipoVeiculoCarreta.value) || (tipoVeiculoMotorista.value != '0' && tipoVeiculoMotorista.value != tipoVeiculoCarreta.value)) {
            tipoVeiculoMotorista.value = tipoVeiculoVeiculo.value;
        }
        tipoVeiculoCarreta.value = '0';
    } else {
        if ((tipoVeiculoMotorista.value == '0' || tipoVeiculoMotorista.value == tipoVeiculoVeiculo.value) && tipoVeiculoCarreta.value != '0') {
            tipoVeiculoMotorista.value = tipoVeiculoCarreta.value;
        } else if ((tipoVeiculoMotorista.value == '0' || tipoVeiculoMotorista.value == tipoVeiculoVeiculo.value) && tipoVeiculoCarreta.value == '0') {
            tipoVeiculoMotorista.value = '0';
        }
        tipoVeiculoVeiculo.value = '0';
    }
    $("tipoveiculo").value = (tipoVeiculoMotorista.value == '0' ? '-1' : tipoVeiculoMotorista.value);
}

function isRetencaoImpostoOpeCFe() {
    var isRetencaoImpostoOpeCFe = ($("is_retencao_impostos_operadora_cfe").value === "true" || $("is_retencao_impostos_operadora_cfe").value === "t" ? true : false);
    return isRetencaoImpostoOpeCFe;
}