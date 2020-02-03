function visualizar() {
    var filtros = concatFieldValue("idmotorista,motor_nome,idproprietario,nome,dtinicial,dtfinal,ctrc,idveiculo,vei_placa,idconsignatario,con_rzs,idConsultarFiliais,idcfe,apenasSaldosAutorizados,notaFiscalCliente");

    //Apenas se os filtros estiverem corretos
    if (filtros.trim() != '') {
        location.replace("./consulta_saldo_carta.jsp?acao=consultar&" + filtros + "&chk_saldo=" + $('chk_saldo').checked);
    }
}

function autorizarSaldo(idx) {
    var stUtilizacaoCFe = $('stUtilizacaoCfe_' + idx).value;

    if ($('vencPagto_' + idx).value == "") {
        alert("Informe a Data de vencimento!");
        return null;
    }

    var enviarPagBem = false;

    if (stUtilizacaoCFe === 'G') {
        if (confirm("Transmitir o valor do acréscimo para PagBem?")) {
            enviarPagBem = true;
        }
    }

    var agente = $('agentePgto_' + idx) != null ? "&agente_pagador=" + $('agentePgto_' + idx).value : "&agente_pagador=''";
    var agenteId = ($('idAgentePgto_' + idx) != null ? "&agente_pagador_id=" + $('idAgentePgto_' + idx).value : "&agente_pagador_id=0");

    window.open("./consulta_saldo_carta.jsp?acao=autoriza_saldo&id=" + idx +
        "&id_carta=" + $('idcarta_' + idx).value +
        "&avaria_carta=" + $('avariaPagto_' + idx).value +
        "&valor_saldo=" + $('valorLiqPagto_' + idx).value +
        "&saldo_autorizado=" + $('libPagto_' + idx).value +
        "&vencimento_saldo=" + $('vencPagto_' + idx).value +
        "&saldo_autorizado_justifica=" + $('saldoAutorizadoJustifica_' + idx).value +
        "&valorAcrescimo=" + $('acrescimoPagto_' + idx).value +
        "&enviarPagBem=" + enviarPagBem +
        agente +
        agenteId +
        "&id_despesa=" + $('iddespesa_' + idx).value
        , "", "top=0,left=0,height=30,width=30");

}

function calculaLiquido(idx) {
    var valorLiquido = parseFloat($('valorPagto_' + idx).value) - parseFloat($('avariaPagto_' + idx).value) + parseFloat($('acrescimoPagto_' + idx).value);

    if (parseFloat(valorLiquido) < 0) {
        alert('O valor líquido do saldo não poderá ser menor que zero.');
        $('avariaPagto_' + idx).value = '0.00';
    } else {
        $('valorLiqPagto_' + idx).value = formatoMoeda(valorLiquido);
    }
}

function verCtrc(id) {
    window.open("./frameset_conhecimento?acao=editar&id=" + id + "&ex=false", "Conhecimento", "top=0,resizable=yes,status=1,scrollbars=1");
}

function verDespesa(id) {
    window.open("./caddespesa.jsp?acao=editar&id=" + id + "&ex=false", "Despesa", "top=0,resizable=yes,status=1,scrollbars=1");
}

function viewCtrc(idcarta) {
    function e(transport) {
        var textoresposta = transport.responseText;
        //se deu algum erro na requisicao...
        if (textoresposta == "load=0") {
            return false;
        } else {
            Element.show("cf_" + idcarta);
            $("cf_" + idcarta).childNodes[(isIE() ? 1 : 3)].innerHTML = textoresposta;
        }
    }//funcao e()

    if (Element.visible("cf_" + idcarta)) {
        Element.toggle("cf_" + idcarta);
    } else {
        new Ajax.Request("./consulta_saldo_carta.jsp?acao=carregar_ctrcs&idcarta=" + idcarta, {
            method: 'post',
            onSuccess: e,
            onError: e
        });
    }
}

function liberaSaldo(idcarta) {
    function e(transport) {
        var textoresposta = transport.responseText;
        //se deu algum erro na requisicao...
        if (textoresposta == "load=0") {
            return false;
        } else {
            Element.show("cf2_" + idcarta);
            $("cf2_" + idcarta).childNodes[(isIE() ? 1 : 3)].innerHTML = textoresposta;
        }
    }//funcao e()

    if (Element.visible("cf2_" + idcarta)) {
        Element.toggle("cf2_" + idcarta);
    } else {
        new Ajax.Request("./consulta_saldo_carta.jsp?acao=carregar_pagamentos&idcarta=" + idcarta, {
            method: 'post',
            onSuccess: e,
            onError: e
        });
    }
}

function localizacliente() {
    post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=5', 'Consignatario_Fatura',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
}

function limparclifor() {
    $("idconsignatario").value = "0";
    $("con_rzs").value = "";
}

var windowOcorrencia = null;

function localizaOcorrencia(indexOcorrencia) {
    $("indexAux").value = indexOcorrencia;
    launchPopupLocate('./localiza?acao=consultar&idlista=62', 'Ocorrencia',
        'top=80,left=150,height=400,width=600,resizable=yes,status=1,scrollbars=1');
}

function salvar(idcartafrete, idx) {
    var ocorrencia = document.getElementById('ocorrencia_id_' + idx).value;
    var motorista = document.getElementById('is_motorista_ocorrencia_' + idx).value;
    var fornecedor = document.getElementById('is_fornecedor_ocorrencia_' + idx).value;

    var motoristaId = document.getElementById('motorista_id_' + idx).value;
    var fornecedorId = document.getElementById('proprietario_id_' + idx).value;

    window.open("./consulta_saldo_carta.jsp?acao=salvar" +
        "&idcartafrete=" + idcartafrete + 
        "&ocorrencia=" + ocorrencia +
        "&is_motorista=" + motorista +
        "&is_fornecedor=" + fornecedor +
        "&motorista_id=" + motoristaId +
        "&fornecedor_id=" + fornecedorId,
        "", "top=50,left=350,height=400,width=600,resizable=yes,status=1,scrollbars=1");
}

function aoClicarNoLocaliza(idJanela) {
    if (idJanela == 'Ocorrencia') {
        var index = $("indexAux").value;
        $('ocorrencia_id_' + index).value = $('ocorrencia_id').value;
        $('codigo_ocorrencia_' + index).value = $('ocorrencia').value;

        setTimeout(function() {
            if ($('is_fornecedor_ocorrencia').value === 't' || $('is_fornecedor_ocorrencia').value === 'true') {
                if (confirm('Deseja adicionar a ocorrência ao histórico do proprietário?')) {
                    $('is_fornecedor_ocorrencia_' + index).value = 'true';
                } else {
                    $('is_fornecedor_ocorrencia_' + index).value = 'false';
                }
            } else {
                $('is_fornecedor_ocorrencia_' + index).value = 'false';
            }

            if ($('is_motorista_ocorrencia').value === 't' || $('is_motorista_ocorrencia').value === 'true') {
                if (confirm('Deseja adicionar a ocorrência ao histórico do motorista?')) {
                    $('is_motorista_ocorrencia_' + index).value = 'true';
                } else {
                    $('is_motorista_ocorrencia_' + index).value = 'false';
                }
            } else {
                $('is_motorista_ocorrencia_' + index).value = 'false';
            }
        }, 250);
    } else if (idJanela == 'Agente_Pagador') {
        try {
            var idx = $('indexAux').value;
            //lembrar de colocar o percentual do abastecimento
            $('agentePgto_' + idx).value = $('agente').value;
            $('idAgentePgto_' + idx).value = $('idagente').value;
        } catch (e) {
            alert(e)
        }
    }
}

function apagaOcorrencia(idx) {
    $('ocorrencia_id_' + idx).value = '0';
    $('codigo_ocorrencia_' + idx).value = '';
}

function abrirLocalizaAgente(index) {
    try {
        $("indexAux").value = index;
        launchPopupLocate('./localiza?acao=consultar&idlista=16&fecharJanela=true', 'Agente_Pagador')
    } catch (e) {
        alert(e)
    }
}

function verCarta(idC, stCfe) {
    if (stCfe == 'N') {
        window.open('./cadcartafrete?acao=editar&id=' + idC + '&ex=false', 'Carta_frete', 'top=0,resizable=yes,status=1,scrollbars=1');
    } else {
        window.open("./ContratoFreteControlador?acao=iniciarEditar&id=" + idC, "LocCarta", 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
    }
}

function exibirJustificativa(valorLinhaSelecionada, codigoLinhaSelecionada) {
    var valor = valorLinhaSelecionada;
    var linhaParaOcultar = "saldoAutorizadoJustifica_" + codigoLinhaSelecionada;
    if (valor.value == "true") {
        document.getElementById(linhaParaOcultar.toString()).style.display = 'none';
    } else {
        document.getElementById(linhaParaOcultar.toString()).style.display = '';
    }
}

function verContratoFrete(id) {
    window.open("./bxctrc?acao=baixaCteManifesto&contratoFrete=" + id, "", "top=0,resizable=yes");
}