function SelectProdutos(id, descricao, isSelected) {
    this.id = (id != undefined ? id : 0);
    this.descricao = (descricao != undefined ? descricao : "");
    this.isSelected = (isSelected != undefined ? isSelected : false);
}

function addTipoVeiculo(tpVeiKm) {
    countTpVeiKm++;
    if (tpVeiKm == null || tpVeiKm == undefined) {
        tpVeiKm = new TipoVeiculoRota();
    }
    var _imgLixo = Builder.node("IMG", {
        src: "img/lixo.png",
        onClick: "removerTable(" + countTpVeiKm + "," + countRota + ");",
        style: "text-align:left;cursor:pointer;margin-right:10px;"
    });
    var hid1_ = Builder.node("INPUT", {
        type: "hidden",
        id: "idRotaTpVei_" + countRota + "_" + countTpVeiKm,
        name: "idRotaTpVei_" + countRota + "_" + countTpVeiKm,
        value: tpVeiKm.id
    });
    var hid2_ = Builder.node("INPUT", {
        type: "hidden",
        id: "tipoVeiculoId_" + countRota + "_" + countTpVeiKm,
        name: "tipoVeiculoId_" + countRota + "_" + countTpVeiKm,
        value: tpVeiKm.tipoVeiculoId
    });
    var lab1_ = Builder.node("LABEL", {style: "vertical-align:super;"}, tpVeiKm.tipoVeiculo);

    var inpCliente_ = Builder.node("INPUT", {
        type: "text",
        id: "clienteTabela_" + countRota + "_" + countTpVeiKm,
        name: "clienteTabela_" + countRota + "_" + countTpVeiKm,
        size: "26",
        maxLength: "30",
        value: tpVeiKm.clienteTabela,
        className: "inputReadOnly8pt",
        readOnly: true,
        style: "border-top-width:1px;margin-top: 5;"
    });
    var hidClienteId_ = Builder.node("INPUT", {
        type: "hidden",
        id: "clienteTabelaId_" + countRota + "_" + countTpVeiKm,
        name: "clienteTabelaId_" + countRota + "_" + countTpVeiKm,
        value: tpVeiKm.clienteTabelaId
    });
    var botCliente_ = Builder.node("INPUT", {
        className: "inputBotaoMin",
        id: "localizaCliente_" + countRota + "_" + countTpVeiKm,
        name: "localizaCliente_" + countRota + "_" + countTpVeiKm,
        type: "button",
        value: "...",
        onClick: "localizarCliente(this);"
    });
    var _imgCliente_ = Builder.node("IMG", {
        src: "img/borracha.gif",
        id: "imgCliente_" + countRota + "_" + countTpVeiKm,
        onClick: "limparCliente('" + countRota + "_" + countTpVeiKm + "');",
        title: "Limpar o cliente.",
        style: "padding-left:4px;position:;"
    });

    var slcProd_ = Builder.node("SELECT", {
        id: "tipoProduto_" + countRota + "_" + countTpVeiKm,
        name: "tipoProduto_" + countRota + "_" + countTpVeiKm,
        className: "fieldMin",
        style: "width:110px;"
    });
    for (var i = 0; i < tpVeiKm.tiposProdutos.length; i++) {
        var optProd = Builder.node("option", {value: tpVeiKm.tiposProdutos[i].id}, tpVeiKm.tiposProdutos[i].descricao);
        slcProd_.appendChild(optProd);
    }
    var lab2_ = Builder.node("LABEL", {id: "labelmaximo_" + countRota + "_" + countTpVeiKm}, " máximo: ");
    var lab3_ = Builder.node("LABEL", {id: "label3_" + countRota + "_" + countTpVeiKm}, "");
    var lab4_ = Builder.node("LABEL", {id: "label4_" + countRota + "_" + countTpVeiKm}, " % ");
    var labEx_ = Builder.node("LABEL", {id: "labelEx_" + countRota + "_" + countTpVeiKm}, "Exced./Kg:");
    var labValorMinimo_ = Builder.node("LABEL", {id: "labValorMinimo_" + countRota + "_" + countTpVeiKm}, "Valor Mínimo:");
    var labNFePorEntrega_ = Builder.node("LABEL", {id: "labNFePorEntrega_" + countRota + "_" + countTpVeiKm, for: 'chkNFePorEntrega_' + countRota + '_' + countTpVeiKm}, "% NF-e por Entrega");
    var inp1_ = Builder.node("INPUT", {
        type: "text",
        id: "valor1_" + countRota + "_" + countTpVeiKm,
        name: "valor1_" + countRota + "_" + countTpVeiKm,
        size: "6",
        maxLength: "20",
        value: tpVeiKm.valor,
        className: "fieldMin",
        onchange: "seNaoFloatReset($('valor1_" + countRota + "_" + countTpVeiKm + "'), 0.00);"
    });
    var inp2_ = Builder.node("INPUT", {
        type: "text",
        id: "valor2_" + countRota + "_" + countTpVeiKm,
        name: "valor2_" + countRota + "_" + countTpVeiKm,
        size: "6",
        maxLength: "20",
        value: tpVeiKm.valor,
        className: "fieldMin",
        onchange: "seNaoFloatReset($('valor2_" + countRota + "_" + countTpVeiKm + "'), 0.00);calcMaximo(" + countRota + "," + countTpVeiKm + ");"
    });
    var inp3_ = Builder.node("INPUT", {
        type: "text",
        id: "valorMaximo_" + countRota + "_" + countTpVeiKm,
        name: "valorMaximo_" + countRota + "_" + countTpVeiKm,
        size: "6",
        maxLength: "20",
        value: tpVeiKm.valorMaximo,
        className: "fieldMin",
        onchange: "seNaoFloatReset($('valorMaximo_" + countRota + "_" + countTpVeiKm + "'), 0.00);"
    });
    var inpEx_ = Builder.node("INPUT", {
        type: "text",
        id: "valorExcedente_" + countRota + "_" + countTpVeiKm,
        name: "valorExcedente_" + countRota + "_" + countTpVeiKm,
        size: "6",
        maxLength: "20",
        value: tpVeiKm.valorPesoExcedente,
        className: "fieldMin",
        onchange: "seNaoFloatReset($('valorExcedente_" + countRota + "_" + countTpVeiKm + "'), 0.00);"
    });
    var inpValorMinimo_ = Builder.node("INPUT", {
        type: "text",
        id: "valorMinimo_" + countRota + "_" + countTpVeiKm,
        name: "valorMinimo_" + countRota + "_" + countTpVeiKm,
        size: "6",
        maxLength: "20",
        value: tpVeiKm.valorMinimo,
        className: "fieldMin",
        onchange: "seNaoFloatReset($('valorMinimo_" + countRota + "_" + countTpVeiKm + "'), 0.00);"
    });
    var slc1_ = Builder.node("SELECT", {
        id: "tipoValor_" + countRota + "_" + countTpVeiKm,
        name: "tipoValor_" + countRota + "_" + countTpVeiKm,
        className: "fieldMin",
        onchange: "slcTipoValor(" + countRota + "," + countTpVeiKm + ")"
    }, [
        Builder.node('OPTION', {value: 'p'}, 'Peso/TON'),
        Builder.node('OPTION', {value: 'f'}, 'Valor Fixo'),
        Builder.node('OPTION', {value: 'c'}, '% CT-e'),
        Builder.node('OPTION', {value: 'n'}, '% NF-e'),
        Builder.node('OPTION', {value: 'k'}, 'R$/KM')
    ]);

    var _considerarCampoCte = Builder.node("select", {
        id: "considerarCampoCte_" + countRota + "_" + countTpVeiKm,
        name: "considerarCampoCte_" + countRota + "_" + countTpVeiKm,
        className: "fieldMin",
        style: "display: none; width:100px"
    });

    povoarSelect(_considerarCampoCte, listaConsiderarValor);

    var div1_ = Builder.node("DIV", {id: "div1_" + countRota + "_" + countTpVeiKm});
    var div2_ = Builder.node("DIV", {id: "div2_" + countRota + "_" + countTpVeiKm});
    var inp4_ = Builder.node("INPUT", {
        type: "text",
        id: "valorViagem2_" + countRota + "_" + countTpVeiKm,
        name: "valorViagem2_" + countRota + "_" + countTpVeiKm,
        size: "8",
        maxLength: "20",
        value: tpVeiKm.valor_viagem_2,
        className: "fieldMin",
        onchange: "seNaoFloatReset($('valorViagem2_" + countRota + "_" + countTpVeiKm + "'), 0.00);"
    });
    var inp5_ = Builder.node("INPUT", {
        type: "text",
        id: "valorPedagio_" + countRota + "_" + countTpVeiKm,
        name: "valorPedagio_" + countRota + "_" + countTpVeiKm,
        size: "3",
        maxLength: "20",
        value: tpVeiKm.valor_pedagio,
        className: "fieldMin",
        onchange: "seNaoFloatReset($('valorPedagio_" + countRota + "_" + countTpVeiKm + "'), 0.00);",
        style: "vertical-align:super;"
    });
    var inp6_ = Builder.node("INPUT", {
        type: "text",
        id: "valorEntrega_" + countRota + "_" + countTpVeiKm,
        name: "valorEntrega_" + countRota + "_" + countTpVeiKm,
        size: "3",
        maxLength: "20",
        value: tpVeiKm.valor_entrega,
        className: "fieldMin",
        onchange: "seNaoFloatReset($('valorEntrega_" + countRota + "_" + countTpVeiKm + "'), 0.00);"
    });
    var inp8_ = Builder.node("INPUT", {
        type: "text",
        id: "taxaFixa_" + countRota + "_" + countTpVeiKm,
        name: "taxaFixa_" + countRota + "_" + countTpVeiKm,
        size: "6",
        maxLength: "20",
        value: tpVeiKm.taxaFixa,
        className: "fieldMin",
        onchange: "seNaoFloatReset($('taxaFixa_" + countRota + "_" + countTpVeiKm + "'), 0.00);"
    });
    var lb6_ = Builder.node("LABEL", "A partir da ");
    var inp6_2 = Builder.node("INPUT", {
        type: "text",
        id: "qtdEntrega_" + countRota + "_" + countTpVeiKm,
        name: "qtdEntrega_" + countRota + "_" + countTpVeiKm,
        size: "1",
        maxLength: "20",
        value: tpVeiKm.qtd_entrega,
        className: "fieldMin",
        onchange: "seNaoIntReset($('qtdEntregas_" + countRota + "_" + countTpVeiKm + "'), 0.00);"
    });
    var inp7_diaria_ = Builder.node("INPUT", {
        type: "text",
        id: "valorDiaria_" + countRota + "_" + countTpVeiKm,
        name: "valorDiaria_" + countRota + "_" + countTpVeiKm,
        size: "5",
        maxLength: "20",
        value: tpVeiKm.valorDiaria,
        className: "fieldMin",
        onchange: "seNaoFloatReset($('valorDiaria_" + countRota + "_" + countTpVeiKm + "'), 0.00);"
    });
    var labValorPedagio_ = Builder.node("LABEL", {
        id: "labValorPedagio_" + countRota + "_" + countTpVeiKm,
        style: "vertical-align:20%;"
    }, " Pedágio: ");
    var labDeduzirPedagio_ = Builder.node("LABEL", {
        id: "labDeduzir_" + countRota + "_" + countTpVeiKm,
        style: "vertical-align:20%;"
    }, " Deduzir pedágio do valor do frete. ");
    var chkDeduzirPedagio_ = Builder.node("INPUT", {
        type: "checkbox",
        id: "chkDeduzir_" + countRota + "_" + countTpVeiKm,
        name: "chkDeduzir_" + countRota + "_" + countTpVeiKm
    });
    var labCarregarPedagioV_ = Builder.node("LABEL", {
        id: "labCarregarV_" + countRota + "_" + countTpVeiKm,
        style: "vertical-align:20%;"
    }, " Carregar valor do pedágio dos CT-es vinculados aos manifestos.");
    var chkCarregarPedagioV_ = Builder.node("INPUT", {
        type: "checkbox",
        id: "chkCarregarV_" + countRota + "_" + countTpVeiKm,
        name: "chkCarregarV_" + countRota + "_" + countTpVeiKm,
        onClick: "readOnlyValorPedagio('" + countRota + '_' + countTpVeiKm + "')"
    });
    var chkNFePorEntrega_ = Builder.node("INPUT", {
        type: "checkbox",
        id: "chkNFePorEntrega_" + countRota + "_" + countTpVeiKm,
        name: "chkNFePorEntrega_" + countRota + "_" + countTpVeiKm
    });
    div1_.appendChild(inp1_);
    div1_.appendChild(lab3_);
    div1_.appendChild(lab4_);
    div2_.appendChild(inp2_);
    div2_.appendChild(lab2_);
    div2_.appendChild(inp3_);

    var td1_ = Builder.node("TD", {rowspan: "2"});
    var tdCliente_ = Builder.node("TD", {style: "display:block;"});
    var tdTipoProduto_ = Builder.node("TD");
    var td2_ = Builder.node("TD");
    var tdTipoTabela_ = Builder.node("TD");
    var td4_ = Builder.node("TD");
    var td8_ = Builder.node("TD");
    var td6_ = Builder.node("TD");
    var td7_diaria_ = Builder.node("TD");
    //07/08/2018
    var tdCampos = Builder.node("TD", {colspan: "8"});
    //07/08/2018
    tdCampos.appendChild(labValorPedagio_);
    tdCampos.appendChild(inp5_);
    tdCampos.appendChild(chkDeduzirPedagio_);
    tdCampos.appendChild(labDeduzirPedagio_);
    tdCampos.appendChild(chkCarregarPedagioV_);
    tdCampos.appendChild(labCarregarPedagioV_);


    td1_.appendChild(hid1_);
    td1_.appendChild(hid2_);
    td1_.appendChild(_imgLixo);
    td1_.appendChild(lab1_);
    tdCliente_.appendChild(hidClienteId_);
    tdCliente_.appendChild(inpCliente_);
    tdCliente_.appendChild(botCliente_);
    tdCliente_.appendChild(_imgCliente_);
    tdTipoProduto_.appendChild(slcProd_);
    td2_.appendChild(div1_);
    td2_.appendChild(div2_);
    td2_.appendChild(inp1_);
    td2_.appendChild(labEx_);
    td2_.appendChild(inpEx_);
    jQuery(td2_).append(jQuery('<div>').append(jQuery(labValorMinimo_)).append(jQuery(inpValorMinimo_)))
        .append(jQuery('<div id="divChkNFeEntrega_' + countRota + '_' + countTpVeiKm + '" style="display: none;">').append(jQuery(chkNFePorEntrega_)).append(jQuery(labNFePorEntrega_)));
    tdTipoTabela_.appendChild(slc1_);
    tdTipoTabela_.appendChild(_considerarCampoCte);
    td4_.appendChild(inp4_);
    td8_.appendChild(inp8_);
    td6_.appendChild(inp6_);
    td6_.appendChild(lb6_);
    td6_.appendChild(inp6_2);
    td7_diaria_.appendChild(inp7_diaria_);

    var classe = ((countRota % 2) != 0 ? 'CelulaZebra2' : 'CelulaZebra1');
    var tr1_ = Builder.node("TR", {className: classe, id: "trTpVeiKm_" + countRota + "_" + countTpVeiKm});
    var trDeduzirPedagio_ = Builder.node("TR", {
        className: classe,
        id: "trTpVeiKmDeduzirPedagio_" + countRota + "_" + countTpVeiKm
    });

    tr1_.appendChild(td1_);
    tr1_.appendChild(tdCliente_);
    tr1_.appendChild(tdTipoProduto_);
    tr1_.appendChild(tdTipoTabela_);
    tr1_.appendChild(td2_);
    tr1_.appendChild(td4_);
    tr1_.appendChild(td8_);
    tr1_.appendChild(td6_);
    tr1_.appendChild(td7_diaria_);
    trDeduzirPedagio_.appendChild(tdCampos);

    $("tbTipoVeiculo_" + countRota).appendChild(tr1_);
    //07/08/2018
    $("tbTipoVeiculo_" + countRota).appendChild(trDeduzirPedagio_);

    div2_.style.display = "none";
    lab4_.style.display = "none";

    slc1_.value = tpVeiKm.tipoValor;
    _considerarCampoCte.value = tpVeiKm.considerarCampoCte;

    slcProd_.value = tpVeiKm.tipoProdutoId;

    $("maxTpVei_" + countRota).value = countTpVeiKm;

    //08/08/2018
    $("chkDeduzir_" + countRota + "_" + countTpVeiKm).checked = tpVeiKm.is_deduzir_pedagio;
    $("chkCarregarV_" + countRota + "_" + countTpVeiKm).checked = tpVeiKm.is_carregar_pedagio_ctes;
    $("chkNFePorEntrega_" + countRota + "_" + countTpVeiKm).checked = tpVeiKm.calcularPercentualNFePorEntrega;

    if (tpVeiKm.is_carregar_pedagio_ctes) {
        readOnly($('valorPedagio_' + countRota + "_" + countTpVeiKm), 'inputReadOnly8pt');
    }
}

function slcTipoValor(linhaRota, linhaTipoVeiculo) {
    try {
        var xTipoTab = $("tipoValor_" + linhaRota + "_" + linhaTipoVeiculo).value;
        if (xTipoTab == "f" || xTipoTab == "k") {
            $("valor1_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "none";
            $("valor2_" + linhaRota + "_" + linhaTipoVeiculo).value = $("valor1_" + linhaRota + "_" + linhaTipoVeiculo).value;
            $("div1_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "none";
            $("div2_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "";
            $("label3_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "none";
            $("label4_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "none";
            $("valorExcedente_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "";
            $("labelEx_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "";
            $("labelmaximo_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "";
            $("valorMaximo_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "";
            $("considerarCampoCte_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "none";
            $("considerarCampoCte_" + linhaRota + "_" + linhaTipoVeiculo).value = "tp";
            $("divChkNFeEntrega_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "none";
        } else if (xTipoTab == "p") {
            $("valor1_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "";
            $("valor1_" + linhaRota + "_" + linhaTipoVeiculo).value = $("valor2_" + linhaRota + "_" + linhaTipoVeiculo).value;
            $("div1_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "";
            $("div2_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "none";
            $("label3_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "";
            $("label4_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "none";
            $("valorExcedente_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "";
            $("labelEx_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "";
            $("valorMaximo_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "";
            $("considerarCampoCte_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "none";
            $("considerarCampoCte_" + linhaRota + "_" + linhaTipoVeiculo).value = "tp";
            $("divChkNFeEntrega_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "none";
        } else if (xTipoTab == "c" || xTipoTab == "n") {
            $("valor1_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "";
            $("valor1_" + linhaRota + "_" + linhaTipoVeiculo).value = $("valor2_" + linhaRota + "_" + linhaTipoVeiculo).value;
            $("div1_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "";
            $("div2_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "none";
            $("label3_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "none";
            $("label4_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "";
            $("valorExcedente_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "";
            $("labelEx_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "";
            if (xTipoTab == "c") {
                $("considerarCampoCte_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "";
                $("divChkNFeEntrega_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "none";
            } else if (xTipoTab == "n") {
                $("considerarCampoCte_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "none";
                $("considerarCampoCte_" + linhaRota + "_" + linhaTipoVeiculo).value = "tp";
                $("divChkNFeEntrega_" + linhaRota + "_" + linhaTipoVeiculo).style.display = "";
            }
        }
        calcMaximo(linhaRota, linhaTipoVeiculo);
    } catch (e) {
        console.error(e);
    }
}

function calcMaximo(linhaRota, linhaTipoVeiculo) {
    var valor = parseFloat($("valor2_" + linhaRota + "_" + linhaTipoVeiculo).value);
    var valorMax = parseFloat($("valorMaximo_" + linhaRota + "_" + linhaTipoVeiculo).value);
    if (valor > valorMax) {
        $("valorMaximo_" + linhaRota + "_" + linhaTipoVeiculo).value = formatoMoeda(valor);
    }

}

function addNewTipoVeiculo(obj) {
    $("linhaRota").value = obj.name.split("_")[1];
    launchPopupLocate('./localiza?acao=consultar&idlista=61', 'Tipo_Veiculo');
}

function getAjudaViagem2() {
    var mensagem = "Esse campo serve exclusivamente para a rotina de montagem de carga, caso o motorista faça 2 viagens no mesmo dia a segunda viagem poderá ter um preço diferenciado.";
    alert(mensagem);
}

function validarValorNegativo(distancia, index) {
    if (distancia.value < 0) {
        alert("Atenção: Valor está negativo para a Distância!");
        $("distancia_" + index).value = 0;
    }
}

function selecionaTipoRota(idxx) {
    if ($('tipoRota_' + idxx).value == 'c') {
        $('areaDestino_' + idxx).style.display = 'none';
        $('localizaAreaDestino_' + idxx).style.display = 'none';
        $('brMdfe_' + idxx).style.display = 'none';
        $('lbMdfe_' + idxx).style.display = 'none';
    } else {
        $('areaDestino_' + idxx).style.display = '';
        $('localizaAreaDestino_' + idxx).style.display = '';
        $('brMdfe_' + idxx).style.display = '';
        $('lbMdfe_' + idxx).style.display = '';
    }
}

function removerRota(idx) {
    if (confirm("Deseja mesmo apagar a rota?")) {
        Element.remove('trRota_' + idx);
        Element.remove('trSecundaria_' + idx);
        Element.remove('trTipoVeiculos_' + idx);
        Element.remove('trPercurso_' + idx);
        Element.remove('trValoresMotorista' + idx);
    }
}

function removerTable(idx, rota) {
    if (confirm("Deseja mesmo apagar a tabela da preço?")) {

        if (jQuery("#idRotaTpVei_" + rota + "_" + idx) !== "") {
            if (jQuery("#idsTabelaPrecoExcluir").val() !== "") {
                jQuery("#idsTabelaPrecoExcluir").val(jQuery("#idsTabelaPrecoExcluir").val() + "," + jQuery("#idRotaTpVei_" + rota + "_" + idx).val());
            } else {
                jQuery("#idsTabelaPrecoExcluir").val(jQuery("#idRotaTpVei_" + rota + "_" + idx).val());
            }
        }
        Element.remove('trTpVeiKm_' + rota + '_' + idx);
        Element.remove('trTpVeiKmDeduzirPedagio_' + rota + '_' + idx);
    }
}

function localizarCidadeOrigem(obj) {
    $("linhaRota").value = obj.name.split("_")[1];
    launchPopupLocate('./localiza?acao=consultar&idlista=11', 'Cidade_Origem');
}

function localizarCidadeDestino(obj) {
    $("linhaRota").value = obj.name.split("_")[1];
    launchPopupLocate('./localiza?acao=consultar&idlista=12', 'Cidade_Destino');
}

function localizarAreaDestino(obj) {
    $("linhaRota").value = obj.name.split("_")[1];
    launchPopupLocate('./localiza?acao=consultar&idlista=34', 'Area_Destino');
}

function localizarCliente(obj) {
    $("linhaRota").value = obj.name.split("_")[1] + "_" + obj.name.split("_")[2];
    launchPopupLocate('./localiza?acao=consultar&idlista=5', 'Cliente_Tabela');
}

function limparCliente(idX) {
    $("clienteTabelaId_" + idX).value = '0';
    $("clienteTabela_" + idX).value = '';
}

function chkTipoVeiculo(elemento) {
    var linha = elemento.id.split("_")[1];

    if ($("trSecundaria_" + linha).style.display == "none") {
        $("trSecundaria_" + linha).style.display = "";
        elemento.src = "img/minus.jpg";
    } else {
        $("trSecundaria_" + linha).style.display = "none";
        elemento.src = "img/plus.jpg";
    }
}


//-------------------    PERCURSO  --------------------- INICIO
var countPercurso = 0;

function Percurso(id, descricao, codigoSolicitacaoMonitoramento) {
    this.id = (id == null || id == undefined ? "0" : id);
    this.descricao = (descricao == null || descricao == undefined ? "" : descricao);
    this.codigoSolicitacaoMonitoramento = (codigoSolicitacaoMonitoramento == null || codigoSolicitacaoMonitoramento == undefined ? 0 : codigoSolicitacaoMonitoramento);
}

function addPercurso(percurso, linhaRota) {
    linhaRota = (linhaRota == null || linhaRota == undefined ? 1 : linhaRota);

    countPercurso = parseInt($("maxPercurso_" + linhaRota).value);
    ++countPercurso;

    if (percurso == null || percurso == undefined) {
        percurso = new Percurso();
    }
    var classe = (linhaRota % 2 == 0 ? "CelulaZebra1NoAlign" : "CelulaZebra2NoAlign");
    var classeInvert = (linhaRota % 2 != 0 ? "CelulaZebra1NoAlign" : "CelulaZebra2NoAlign");

    var _hid1 = Builder.node("INPUT", {
        type: "hidden",
        id: "idPercursoRota_" + linhaRota + "_" + countPercurso,
        name: "idPercursoRota_" + linhaRota + "_" + countPercurso,
        value: percurso.id
    });
    var _hid2 = Builder.node("INPUT", {
        type: "hidden",
        id: "maxPercursoCidade_" + linhaRota + "_" + countPercurso,
        name: "maxPercursoCidade_" + linhaRota + "_" + countPercurso,
        value: 0
    });
    var _inp1 = Builder.node("INPUT", {
        type: "text",
        id: "descricaoPercurso_" + linhaRota + "_" + countPercurso,
        className: "fieldMin",
        name: "descricaoPercurso_" + linhaRota + "_" + countPercurso,
        maxLength: 50,
        size: "35",
        value: percurso.descricao
    });
    var _lab1 = Builder.node("LABEL", "Nome: ");
    var _img1 = Builder.node("IMG", {
        src: "img/add.gif",
        id: "imgAddPerc_" + linhaRota,
        onClick: "localizarCidadePercurso(" + linhaRota + "," + countPercurso + ");",
        title: "Adicionar uma cidade."
    });
    var _img3 = Builder.node("IMG", {
        src: "img/lixo.png",
        onClick: "removerPercurso(" + linhaRota + "," + countPercurso + ");",
        title: "Excluir Percurso"
    });
    // td's da primeira tr
    var _td1 = Builder.node("TD", {align: "center", width: "3%", className: classe});
    var _td2 = Builder.node("TD", {align: "left", colSpan: 3, width: "94%", className: classe});
    var _tdLixPer = Builder.node("TD", {align: "center", width: "3%", className: classe});
    // td's da segunda tr
    var _td1_3 = Builder.node("TD", {colSpan: 5});

    // td's da terceira tr
    var _td1_2 = Builder.node("TD", {width: "5%", align: "center", className: classeInvert});
    var _td2_2 = Builder.node("TD", {width: "10%", align: "left", className: classeInvert}, ['Ordem']);
    var _td3_2 = Builder.node("TD", {width: "85%", align: "left", className: classeInvert}, ['Cidade']);
    var _tr = Builder.node("TR", {id: "trPercursoCidade1_" + linhaRota + "_" + countPercurso});
    var _tr2_1 = Builder.node("TR", {id: "trPercursoCidade2_" + linhaRota + "_" + countPercurso});

    var _table = Builder.node("TABLE", {width: "100%", className: "bordaFina"}, [
        Builder.node("TBODY", {
            id: "tbPercursoCidade_" + linhaRota + "_" + countPercurso,
            name: "tbPercursoCidade_" + linhaRota + "_" + countPercurso
        }, [
            Builder.node("TR", {}, [
                _td1_2,
                _td2_2,
                _td3_2
            ])
        ])
    ]);

    _tdLixPer.appendChild(_hid1);
    _tdLixPer.appendChild(_hid2);
    _tdLixPer.appendChild(_img3);
    _td2.appendChild(_lab1);
    _td2.appendChild(_inp1);

    _td1_3.appendChild(_table);

    _tr.appendChild(_tdLixPer);
    _tr.appendChild(_td2);

    _td1_2.appendChild(_img1);

    _tr2_1.appendChild(_td1_3);

    $("tbPercurso_" + linhaRota).appendChild(_tr);
    $("tbPercurso_" + linhaRota).appendChild(_tr2_1);

    $("maxPercurso_" + linhaRota).value = parseInt($("maxPercurso_" + linhaRota).value) + 1;
}

function removerPercurso(linhaRota, linhaPercurso) {
    var descricao = $("descricaoPercurso_" + linhaRota + "_" + linhaPercurso).value;
    if (confirm("Deseja mesmo apagar o percurso " + descricao + " ?")) {

        function e(transport) {
            var textoResposta = transport.responseText;
            if (textoResposta == "-1") {
                alert('');
                return false;
            } else {
                if (textoResposta != "") {
                    //Caso o retorno contenha a substring abaixo
                    if (textoResposta.indexOf("carta_frete_rota_percurso_id_fkey") > -1 || textoResposta.indexOf("manifesto_percurso_id_fkey") > -1) {
                        alert("ATENÇÃO: Não é possível excluir o percurso, pois o mesmo já foi utilizado em um lançamento.");
                        return false;
                    }

                }

                //Removendo as Trs
                Element.remove('trPercursoCidade1_' + linhaRota + "_" + linhaPercurso);
                Element.remove('trPercursoCidade2_' + linhaRota + "_" + linhaPercurso);
                return true;
            }
        }

        var id = $("idPercursoRota_" + linhaRota + "_" + linhaPercurso).value;

        if (parseInt(id) != 0) {
            tryRequestToServer(function () {
                new Ajax.Request("./cadrota.jsp?acao=AjaxRemoverPercurso&percursoId=" + id, {
                    method: 'post',
                    onSuccess: e
                    ,
                    onError: e
                });
            });
        } else {
            Element.remove('trPercursoCidade1_' + linhaRota + "_" + linhaPercurso);
            Element.remove('trPercursoCidade2_' + linhaRota + "_" + linhaPercurso);
            countPercurso--;
        }
    }
}

//-------------------    PERCURSO  --------------------- FIM

//-------------------  PERCURSO CIDADE  ---------------  INICIO
var countPercursoCidade = 0;

function localizarCidadePercurso(linhaRota, linhaPercurso, linhaPercursoCidade) {
    $("linhaRota").value = linhaRota;
    $("linhaPercurso").value = linhaPercurso;
    $("linhaPercursoCidade").value = linhaPercursoCidade;
    launchPopupLocate('./localiza?acao=consultar&idlista=12&fecharJanela=false', 'Cidade_Percurso');
}

function removerPercursoCidade(linhaRota, linhaPercurso, linhaPercursoCidade) {
    var descricao = $("descricaoPercurso_" + linhaRota + "_" + linhaPercurso).value;
    var cidade = $("cidadePercurso_" + linhaRota + "_" + linhaPercurso + "_" + linhaPercursoCidade).value;
    if (confirm("Deseja mesmo apagar a cidade: " + cidade + " do percurso " + descricao + " ?")) {
        var id = $("idPercursoCidadeRota_" + linhaRota + "_" + linhaPercurso + "_" + linhaPercursoCidade).value;
        Element.remove('trPercursoCidadeRota_' + linhaRota + "_" + linhaPercurso + "_" + linhaPercursoCidade);
        Element.remove('trPercursoCidadeRotaCodigoSolicitacaoMonitoramento_' + linhaRota + "_" + linhaPercurso + "_" + linhaPercursoCidade);
        if (parseInt(id) != 0) {
            tryRequestToServer(function () {
                new Ajax.Request("./cadrota.jsp?acao=AjaxRemoverPercursoCidade&percursoCidadeId=" + id, {
                    method: 'post',
                    onSuccess: "alert('Percurso removido com sucesso!')"
                    ,
                    onError: "alert('Não foi possivel remover o Percurso!')"
                });
            });
        }
    }
}

function PercursoCidade(id, ordem, idCidade, cidade, uf, codigoSolicitacaoMonitoramento) {
    this.id = (id == null || id == undefined ? "0" : id);
    this.ordem = (ordem == null || ordem == undefined ? 0 : ordem);
    this.idCidade = (idCidade == null || idCidade == undefined ? 0 : idCidade);
    this.cidade = (cidade == null || cidade == undefined ? "" : cidade);
    this.uf = (uf == null || uf == undefined ? "" : uf);
    this.codigoSolicitacaoMonitoramento = (codigoSolicitacaoMonitoramento == null || codigoSolicitacaoMonitoramento == undefined ? 0 : codigoSolicitacaoMonitoramento);
}

function addPercursoCidade(percursoCidade, linhaRota, linhaPercurso) {
    linhaRota = (linhaRota == null || linhaRota == undefined ? 1 : linhaRota);

    countPercursoCidade = parseInt($("maxPercursoCidade_" + linhaRota + "_" + linhaPercurso).value);
    ++countPercursoCidade;

    var _tr0 = $("trPercursoCidade2_" + linhaRota + "_" + linhaPercurso);
    visivel(_tr0);

    if (percursoCidade == null || percursoCidade == undefined) {
        percursoCidade = new PercursoCidade();
    }
    var ordem = 1;
    var linhaAnt = countPercursoCidade - 1;

    if ($("ordemPercurso_" + linhaRota + "_" + linhaPercurso + "_" + linhaAnt) != null) {
        ordem = parseInt($("ordemPercurso_" + linhaRota + "_" + linhaPercurso + "_" + linhaAnt).value) + 1;
    } else if (percursoCidade.id != 0) {
        ordem = percursoCidade.ordem;
    }

    var classe = (linhaRota % 2 == 0 ? "CelulaZebra1NoAlign" : "CelulaZebra2NoAlign");
    var _hid1 = Builder.node("INPUT", {
        type: "hidden",
        id: "idPercursoCidadeRota_" + linhaRota + "_" + linhaPercurso + "_" + countPercursoCidade,
        name: "idPercursoCidadeRota_" + linhaRota + "_" + linhaPercurso + "_" + countPercursoCidade,
        value: percursoCidade.id
    });
    var _inp1 = Builder.node("INPUT", {
        type: "text",
        id: "ordemPercurso_" + linhaRota + "_" + linhaPercurso + "_" + countPercursoCidade,
        name: "ordemPercurso_" + linhaRota + "_" + linhaPercurso + "_" + countPercursoCidade,
        value: (ordem),
        size: 2,
        maxLength: 5,
        className: "fieldMin",
        onchange: "seNaoIntReset($('ordemPercurso_" + linhaRota + "_" + linhaPercurso + "_" + countPercursoCidade + "'), 0);"
    });
    var _inp2 = Builder.node("INPUT", {
        type: "hidden",
        id: "idCidadePercurso_" + linhaRota + "_" + linhaPercurso + "_" + countPercursoCidade,
        name: "idCidadePercurso_" + linhaRota + "_" + linhaPercurso + "_" + countPercursoCidade,
        maxLength: 10,
        size: 8,
        value: percursoCidade.idCidade
    });
    var _inp3 = Builder.node("INPUT", {
        type: "text",
        id: "cidadePercurso_" + linhaRota + "_" + linhaPercurso + "_" + countPercursoCidade,
        name: "cidadePercurso_" + linhaRota + "_" + linhaPercurso + "_" + countPercursoCidade,
        value: percursoCidade.cidade,
        size: 25,
        maxLength: 30,
        className: "inputReadOnly8pt"
    });
    var _inp4 = Builder.node("INPUT", {
        type: "text",
        id: "ufPercurso_" + linhaRota + "_" + linhaPercurso + "_" + countPercursoCidade,
        name: "ufPercurso_" + linhaRota + "_" + linhaPercurso + "_" + countPercursoCidade,
        value: percursoCidade.uf,
        size: 2,
        maxLength: 2,
        className: "inputReadOnly8pt"
    });
    var _img3 = Builder.node("IMG", {
        src: "img/lixo.png",
        onClick: "removerPercursoCidade(" + linhaRota + "," + linhaPercurso + "," + countPercursoCidade + ");",
        title: "Excluir Cidade do Percurso"
    });
    var _bot1 = Builder.node("INPUT", {
        className: "inputBotaoMin",
        id: "localizaPercurso_" + linhaRota + "_" + linhaPercurso + "_" + countPercursoCidade,
        name: "localizaPercurso_" + linhaRota + "_" + linhaPercurso + "_" + countPercursoCidade,
        type: "button",
        value: "...",
        onClick: "localizarCidadePercurso('" + linhaRota + "','" + linhaPercurso + "','" + countPercursoCidade + "');"
    });

    var _td0 = Builder.node("TD", {align: "center", className: classe});
    var _td1 = Builder.node("TD", {align: "left", className: classe});
    var _td2 = Builder.node("TD", {align: "left", className: classe});
    var _tr1 = Builder.node("TR", {id: "trPercursoCidadeRota_" + linhaRota + "_" + linhaPercurso + "_" + countPercursoCidade});

    _td0.appendChild(_hid1);
    _td0.appendChild(_img3);
    _td1.appendChild(_inp1);
    _td2.appendChild(_inp2);
    _td2.appendChild(_inp3);
    _td2.appendChild(_inp4);
    _td2.appendChild(_bot1);

    _tr1.appendChild(_td0);
    _tr1.appendChild(_td1);
    _tr1.appendChild(_td2);

    // Campos para o Monitora
    var _labelCodigoSolicitacaoMonitoramento = Builder.node("LABEL", "Código SM:");
    var _inputCodigoSolicitacaoMonitoramento = Builder.node("INPUT", {
        type: "text",
        id: "codigoSolicitacaoMonitoramento_" + linhaRota + "_" + linhaPercurso + "_" + countPercursoCidade,
        name: "codigoSolicitacaoMonitoramento_" + linhaRota + "_" + linhaPercurso + "_" + countPercursoCidade,
        value: percursoCidade.codigoSolicitacaoMonitoramento,
        size: 17,
        maxLength: 50,
        className: "fieldMin"
    });
    var _tdCodigoSolicitacaoMonitoramento1 = Builder.node("TD", {
        align: "left",
        className: classe
    });
    var _tdCodigoSolicitacaoMonitoramento2 = Builder.node("TD", {
        align: "left",
        className: classe
    });
    var _tdCodigoSolicitacaoMonitoramento3 = Builder.node("TD", {
        align: "left",
        className: classe
    });

    var _tr2 = Builder.node("TR", {
        id: "trPercursoCidadeRotaCodigoSolicitacaoMonitoramento_" + linhaRota + "_" + linhaPercurso + "_" + countPercursoCidade
    });

    _tdCodigoSolicitacaoMonitoramento3.appendChild(_labelCodigoSolicitacaoMonitoramento);
    _tdCodigoSolicitacaoMonitoramento3.appendChild(_inputCodigoSolicitacaoMonitoramento);

    _tr2.appendChild(_tdCodigoSolicitacaoMonitoramento1);
    _tr2.appendChild(_tdCodigoSolicitacaoMonitoramento2);
    _tr2.appendChild(_tdCodigoSolicitacaoMonitoramento3);

    $("tbPercursoCidade_" + linhaRota + "_" + linhaPercurso).appendChild(_tr1);
    $("tbPercursoCidade_" + linhaRota + "_" + linhaPercurso).appendChild(_tr2);

    $("maxPercursoCidade_" + linhaRota + "_" + linhaPercurso).value = countPercursoCidade;
    if (percursoCidade.idCidade == 0) {
        localizarCidadePercurso(linhaRota + "_" + linhaPercurso + "_" + countPercursoCidade);
    }
}

//-------------------  PERCURSO CIDADE  ---------------  FIM

// @@@@@@@@@ ROTA  @@@@@@@@@@@ FIM

function aoClicarNoLocaliza(idjanela) {
    var i = $("linhaRota").value;
    var j = $("linhaPercurso").value;
    var p = $("linhaPercursoCidade").value;
    var percursoCidade;
    if (idjanela == "Cidade_Origem") {
        $("cidadeOrigemId_" + i).value = $("idcidadeorigem").value;
        $("cidadeOrigem_" + i).value = $("cid_origem").value;
        $("ufOrigem_" + i).value = $("uf_origem").value;
    } else if (idjanela == "Cidade_Destino") {
        $("cidadeDestinoId_" + i).value = $("idcidadedestino").value;
        $("cidadeDestino_" + i).value = $("cid_destino").value;
        $("ufDestino_" + i).value = $("uf_destino").value;
    } else if (idjanela == "Area_Destino") {
        $("areaDestinoId_" + i).value = $("area_id").value;
        $("areaDestino_" + i).value = $("sigla_area").value;
    } else if (idjanela == "Cliente_Tabela") {
        $("clienteTabelaId_" + i).value = $("idconsignatario").value;
        $("clienteTabela_" + i).value = $("con_rzs").value + " (" + $("con_cnpj").value + ")";
    } else if (idjanela == "Cidade_Percurso") {
        if ($("idCidadePercurso_" + i + "_" + j + "_" + p) != null) {
            $("idCidadePercurso_" + i + "_" + j + "_" + p).value = $("idcidadedestino").value;
            $("cidadePercurso_" + i + "_" + j + "_" + p).value = $("cid_destino").value;
            $("ufPercurso_" + i + "_" + j + "_" + p).value = $("uf_destino").value;
        } else {
            percursoCidade = new PercursoCidade(0, null, $("idcidadedestino").value, $("cid_destino").value, $("uf_destino").value)
            addPercursoCidade(percursoCidade, i, j);
        }
    } else if (idjanela == "Tipo_Veiculo") {
        var tpNewVei = new TipoVeiculoRota(0, $('tipo_veiculo_id').value, $('tipo_veiculo_descricao').value, "0.00");
        addTipoVeiculo(tpNewVei);
    }
}

function voltar() {
    location.replace("ConsultaControlador?codTela=47");
}

function salva(acao) {
    for (var i = 1; i <= countRota; i++) {
        if ($("descricao_" + i) != null && $("descricao_" + i).value == "") {
            return showErro("Informe o nome da rota!", $("descricao_" + i));
        }
        if ($("cidadeOrigemId_" + i) != null && $("cidadeOrigemId_" + i).value == "0") {
            alert("Informe uma cidade!");
            $("cidadeOrigem_" + i).style.background = "#FFE8E8";
            $("ufOrigem_" + i).style.background = "#FFE8E8";
            return false;
        }
        if ($("cidadeDestinoId_" + i) != null && $("cidadeDestinoId_" + i).value == "0") {
            alert("Informe uma cidade!");
            $("cidadeDestino_" + i).style.background = "#FFE8E8";
            $("ufDestino_" + i).style.background = "#FFE8E8";
            return false;
        }
        if ($("tipoRota_" + i) != null && $("tipoRota_" + i).value == "a" && $("areaDestinoId_" + i) != null && $("areaDestinoId_" + i).value == "0") {
            alert("Informe a área de destino corretamente!");
            $("areaDestino_" + i).style.background = "#FFE8E8";
            return false;
        }
        var maxPerc = $("maxPercurso_" + i).value;
        for (var j = 1; j <= maxPerc; j++) {
            if ($("descricaoPercurso_" + i + "_" + j) != null && $("descricaoPercurso_" + i + "_" + j).value.trim() == "") {
                return showErro("Informe uma descrição do percurso!", $("descricaoPercurso_" + i + "_" + j));
            }
        }
    }

    $("formulario").action = "./cadrota.jsp?acao=" + acao;
    window.open('about:blank', 'pop', 'width=210, height=100');
    $("formulario").submit();
}

function excluir(id) {
    if (confirm("Deseja mesmo excluir esta rota?")) {
        location.replace("consulta_rota.jsp?acao=excluir&id=" + id);
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
    var rotina = "rota";
    var dataDe = $("dataDeAuditoria").value;
    var dataAte = $("dataAteAuditoria").value;
    var id = $("idRota").value;
    consultarLog(rotina, id, dataDe, dataAte);
}

function readOnlyValorPedagio(id) {
    if ($('chkCarregarV_' + id).checked) {
        readOnly($('valorPedagio_' + id), 'inputReadOnly8pt');
    } else {
        notReadOnly($('valorPedagio_' + id), 'fieldMin');
    }
}

function setDataAuditoria() {
    $("dataDeAuditoria").value = carregarota === 'true' ? data : '';
    $("dataAteAuditoria").value = carregarota === 'true' ? data : '';
}