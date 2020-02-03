var buscouTaxas = "-1";
var tarifas = new Array();
var tbPrecoredespDestinoVarios = new Array();
var tbPrecoredespOrigemVarios = new Array();

var callFmtData = "fmtDate(this, event)";
var callMascaraSoNumeros = "mascara(this, soNumeros);";
var callMascaraReais = "mascara(this, reais);";
var estiloTextRight = "text-align:right;";
var estiloMin = "fieldMin";
var estiloMin2 = "fieldMin2";
var alteraTipoFrete = true;

var countComp = 0;
function ComposicaoFrete(id, dtPrevisaoEntrega, tipProd, tipFrete, tipVeiculo, qtdEntrega, distanciaKm, qtdPallet, codTabela
        , isIncluirIcms, isIncluirPisCofins, isCobrarTde, vlTaxaFixa, vlTaxaFixaTotal, vlDespacho
        , vlAdeme, vlFretePeso, vlFreteValor, vlItr, vlSecCat, vlOutros, vlGris, vlPedagio, vlTde, vlDesconto
        , baseIcms, percIcms, percDesconto, isDescontoFreteNacional, isDescontoAdValorem, vlIcmsImbutido, baseCubagem, pesoCubagem
        , isSelecionado, vlPeso, vlDespesaColeta, vlDespesaEntrega) {

    countComp = parseInt($("qtdCompFrete").value);
    this.indice = (++countComp);
    this.id = (id == null || id == undefined ? 0 : id);
    this.dtPrevisaoEntrega = (dtPrevisaoEntrega == null || dtPrevisaoEntrega == undefined ? "" : dtPrevisaoEntrega);
    this.tipProd = (tipProd == null || tipProd == undefined ? 0 : tipProd);
    this.tipFrete = (tipFrete == null || tipFrete == undefined ? -1 : tipFrete);
    this.tipVeiculo = (tipVeiculo == null || tipVeiculo == undefined ? -1 : tipVeiculo);
    this.qtdEntrega = (qtdEntrega == null || qtdEntrega == undefined ? 1 : qtdEntrega);
    this.qtdPallet = (qtdPallet == null || qtdPallet == undefined ? "" : qtdPallet);
    this.distanciaKm = (distanciaKm == null || distanciaKm == undefined ? "" : distanciaKm);
    this.codTabela = (codTabela == null || codTabela == undefined ? "" : codTabela);

    this.isIncluirIcms = (isIncluirIcms == null || isIncluirIcms == undefined ? false : isIncluirIcms);
    this.isIncluirPisCofins = (isIncluirPisCofins == null || isIncluirPisCofins == undefined ? false : isIncluirPisCofins);
    this.isCobrarTde = (isCobrarTde == null || isCobrarTde == undefined ? false : isCobrarTde);
    this.isDescontoFreteNacional = (isDescontoFreteNacional == null || isDescontoFreteNacional == undefined ? false : isDescontoFreteNacional);
    this.isDescontoAdValorem = (isDescontoAdValorem == null || isDescontoAdValorem == undefined ? false : isDescontoAdValorem);
    this.isSelecionado = (isSelecionado == null || isSelecionado == undefined ? false : isSelecionado);

    this.vlTaxaFixa = (vlTaxaFixa == null || vlTaxaFixa == undefined ? 0 : vlTaxaFixa);
    this.vlTaxaFixaTotal = (vlTaxaFixaTotal == null || vlTaxaFixaTotal == undefined ? 0 : vlTaxaFixaTotal);
    this.vlDespacho = (vlDespacho == null || vlDespacho == undefined ? 0 : vlDespacho);
    this.vlAdeme = (vlAdeme == null || vlAdeme == undefined ? 0 : vlAdeme);
    this.vlFretePeso = (vlFretePeso == null || vlFretePeso == undefined ? 0 : vlFretePeso);
    this.vlFreteValor = (vlFreteValor == null || vlFreteValor == undefined ? 0 : vlFreteValor);
    this.vlItr = (vlItr == null || vlItr == undefined ? 0 : vlItr);
    this.vlPeso = (vlPeso == null || vlPeso == undefined ? 0 : vlPeso);
    this.vlDespesaColeta = (vlDespesaColeta == null || vlDespesaColeta == undefined ? 0 : vlDespesaColeta);
    this.vlDespesaEntrega = (vlDespesaEntrega == null || vlDespesaEntrega == undefined ? 0 : vlDespesaEntrega);
    this.resumoFinanceiro = (0);
    this.vlSecCat = (vlSecCat == null || vlSecCat == undefined ? 0 : vlSecCat);
    this.vlOutros = (vlOutros == null || vlOutros == undefined ? 0 : vlOutros);
    this.vlGris = (vlGris == null || vlGris == undefined ? 0 : vlGris);
    this.vlPedagio = (vlPedagio == null || vlPedagio == undefined ? 0 : vlPedagio);
    this.vlIcmsImbutido = (vlIcmsImbutido == null || vlIcmsImbutido == undefined ? 0 : vlIcmsImbutido);
    this.vlTde = (vlTde == null || vlTde == undefined ? 0 : vlTde);
    this.vlDesconto = (vlDesconto == null || vlDesconto == undefined ? 0 : vlDesconto);
    this.baseIcms = (baseIcms == null || baseIcms == undefined ? 0 : baseIcms);
    this.baseCubagem = (baseCubagem == null || baseCubagem == undefined ? 0 : baseCubagem);
    this.pesoCubagem = (pesoCubagem == null || pesoCubagem == undefined ? 0 : pesoCubagem);
    this.percIcms = (percIcms == null || percIcms == undefined ? $("aliquota").value : (percIcms == 0 ? $("aliquota").value : percIcms));
    this.percDesconto = (percDesconto == null || percDesconto == undefined ? 0 : percDesconto);
}

function addComposicaoFrete(comp, _tabela) {
    try {
        if (comp == null || comp == undefined) {
            comp = new ComposicaoFrete();
            comp.tipFrete = $("con_tipotaxa").value;
        }
        var rowSpanGenerico = ($("tipoTransporte_tipo").value == "a" ? 7 : 6);
        var callDefinirVisibilidade = "definirVisibilidadeCampos(" + comp.indice + ");";
        var callAlterarTipoFrete = "alterarTipoFrete(this.value, " + comp.indice + ");";
        var callCalculaFreteVarios = "calculaFreteVarios(" + comp.indice + ");";
        var callAlteraTipoTaxa = "alteraTipoTaxaVarios('S'," + comp.indice + ");";
        var callSelecionarEleiro = "selecionarEleito(" + comp.indice + ");";
        var callCalculaTaxaFixaTotalVarios = "calculaTaxaFixaTotalVarios(this.value," + comp.indice + ");";
        var classe = ((comp.indice % 2) == 0 ? 'CelulaZebra1' : 'CelulaZebra2');

        var _labelTipoProduto = Builder.node("label", {}, 'Tipo Produto:');
        var _labelTipoFrete = Builder.node("label", {}, 'Tipo Frete:');
        var _labelTipoVeiculo = Builder.node("label", {}, 'Tipo Veículo:');
        var _labelTabelaUtilizada = Builder.node("label", {}, 'Cód Tabela:');
        var _labelPallets = Builder.node("label", {id: "lbPallet_" + comp.indice}, 'Pallets:');
        var _labelDistancia = Builder.node("label", {id: "lbDistancia_" + comp.indice}, 'Distancia:');
        var _labelQtdEntrega = Builder.node("label", {}, 'Entregas:');
        var _labelIncluirIcms = Builder.node("label", {}, 'Incluir ICMS');
        var _labelIncluirPisCofins = Builder.node("label", {}, 'Incluir PIS/COFINS');
        var _labelTaxaFixaIgual = Builder.node("label", {}, '=');
        var _labelTaxaFixa = Builder.node("label", {id: "labTaxaFixa_" + comp.indice}, 'Taxa Fixa:');
        var _labelDespacho = Builder.node("label", {}, 'Despacho:');
        var _labelAdeme = Builder.node("label", {}, 'ADEME:');
        var _labelFretePeso = Builder.node("label", {id: "labFretePeso_" + comp.indice}, 'Frete Peso:');
        var _labelFreteValor = Builder.node("label", {id: "labFreteValor_" + comp.indice}, 'Frete Valor:');
        var _labelITR = Builder.node("label", {}, 'ITR:');
        var _labelSecCat = Builder.node("label", {id: "labSecCat_" + comp.indice}, 'SEC/CAT:');
        var _labelOutros = Builder.node("label", {}, 'Outros:');
        var _labelGris = Builder.node("label", {}, 'GRIS:');
        var _labelPedagio = Builder.node("label", {}, 'Pedágio:');
        var _labelCobrarTde = Builder.node("label", {}, ' Cobrar TDE');
        var _labelTde = Builder.node("label", {}, 'TDE:');
        var _labelDesconto = Builder.node("label", {}, 'Desconto:');
        var _labelDescontoR$ = Builder.node("label", {}, 'R$');
        var _labelTotalPrestacao = Builder.node("label", {}, 'Total Prest.:');
        var _labelBaseCalculo = Builder.node("label", {}, 'Base:');
        var _labelAliquota = Builder.node("label", {}, 'Aliq.(%):');
        var _labelIcms = Builder.node("label", {}, 'ICMS:');
        var _labelPisCofins = Builder.node("label", {}, 'PIS/COFINS:');
        var _labelPercDesconto = Builder.node("label", {}, '%');
        var _labelDescFreteNacional = Builder.node("label", {}, ' Desconto no Frete Nacional');
        var _labelDescAdValorem = Builder.node("label", {}, ' Desconto no ADVALOREM');
        var _labelValorPeso = Builder.node("label", {}, ' Taxa peso/kg da companhia Aérea:');
        var _labelValorDespesaColeta = Builder.node("label", {}, ' Despesa Coleta:');
        var _labelValorDespesaEntrega = Builder.node("label", {}, ' Despesa Entr.:');
        var _labelResumoFinanceiro = Builder.node("label", {}, ' Resumo Finan.:');


        var _trTipo = Builder.node("tr", {
            id: "trTipos_" + comp.indice,
            className: classe
        });
        var _tr1 = Builder.node("tr", {
            id: "trComp1_" + comp.indice,
            className: classe
        });
        var _tr2 = Builder.node("tr", {
            id: "trComp2_" + comp.indice,
            className: classe
        });
        var _tr3 = Builder.node("tr", {
            id: "trComp3_" + comp.indice,
            className: classe
        });
        var _tr4 = Builder.node("tr", {
            id: "trComp4_" + comp.indice,
            className: classe
        });
        var _tr5 = Builder.node("tr", {
            id: "trComp5_" + comp.indice,
            className: classe
        });
        var _tr6 = Builder.node("tr", {
            id: "trComp6_" + comp.indice,
            className: classe
        });

        var _tdLixo = new Element("td", {
            id: "tdLixo_" + comp.indice,
            align: "center",
            rowspan: rowSpanGenerico
        });
        var _tdSelecionado = new Element("td", {
            id: "tdSelecionado_" + comp.indice,
            align: "center",
            rowspan: rowSpanGenerico
        });
        var _tdImpressao = new Element("td", {
            id: "tdImpressao_" + comp.indice,
            align: "center",
            rowspan: rowSpanGenerico
        });

        //------------------- LINHA TIPOS  -------------------------------
        var _tdTipoProdDesc = new Element("td", {
            align: "right",
            colSpan: 1
        });
        var _tdTipoProdValor = new Element("td", {
            align: "left",
            colSpan: 1
        });
        var _tdTipoFreteDesc = new Element("td", {
            align: "right",
            colSpan: 1
        });
        var _tdTipoFreteValor = new Element("td", {
            align: "left",
            colSpan: 2
        });
        var _tdTipoVeiculoDesc = new Element("td", {
            align: "right",
            colSpan: 2
        });
        var _tdTipoVeiculoValor = new Element("td", {
            align: "left",
            colSpan: 3
        });

        //------------------- PRIMEIRA LINHA -----------------------------
        var _td11 = new Element("td", {
            align: "right",
            width: "12%",
            colSpan: 1
        });
        var _td12 = new Element("td", {
            align: "left",
            width: "16%",
            colSpan: 1
        });
        var _td13 = new Element("td", {
            align: "right",
            width: "10%",
            colSpan: 1
        });
        var _td14 = new Element("td", {
            align: "center",
            width: "8    %",
            colSpan: 1
        });
        var _td15 = new Element("td", {
            align: "right",
            width: "10%",
            colSpan: 1
        });
        var _td16 = new Element("td", {
            align: "right",
            width: "18%",
            colSpan: 2
        });
        var _td17 = new Element("td", {
            align: "center",
            width: "8%",
            colSpan: 1
        });
        var _td18 = new Element("td", {
            align: "left",
            width: "16%",
            colSpan: 2
        });
        //------------------- SEGUNDA LINHA -----------------------------
        var _td21 = new Element("td", {
            align: "right",
            colSpan: 1
        });
        var _td22 = new Element("td", {
            align: "left",
            colSpan: 1
        });
        var _td23 = new Element("td", {
            align: "right",
            colSpan: 1
        });
        var _td24 = new Element("td", {
            align: "center",
            colSpan: 1
        });
        var _td25 = new Element("td", {
            align: "right",
            colSpan: 1
        });
        var _td26 = new Element("td", {
            align: "left",
            width: "8%",
            colSpan: 1
        });
        var _td27 = new Element("td", {
            align: "right",
            width: "10%",
            colSpan: 1
        });
        var _td28 = new Element("td", {
            align: "center",
            colSpan: 1
        });
        var _td29 = new Element("td", {
            align: "right",
            width: "8%",
            colSpan: 1
        });
        var _td210 = new Element("td", {
            align: "center",
            width: "8%",
            colSpan: 1
        });

        //------------------- TERCEIRA LINHA -----------------------------
        var _td3_1 = new Element("td", {
            align: "right",
            colSpan: 1
        });
        var _td3_2 = new Element("td", {
            align: "left",
            colSpan: 1
        });
        var _td3_3 = new Element("td", {
            align: "right",
            colSpan: 1
        });
        var _td3_4 = new Element("td", {
            align: "center",
            colSpan: 1
        });
        var _td3_5 = new Element("td", {
            align: "right",
            colSpan: 1
        });
        var _td3_6 = new Element("td", {
            align: "left",
            colSpan: 1
        });
        var _td3_7 = new Element("td", {
            align: "right",
            colSpan: 1
        });
        var _td3_8 = new Element("td", {
            align: "center",
            colSpan: 1
        });
        var _td3_9 = new Element("td", {
            align: "right",
            colSpan: 1
        });
        var _td3_10 = new Element("td", {
            align: "center",
            colSpan: 1
        });

        //------------------- QUARTA LINHA -----------------------------
        var _td4_1 = new Element("td", {
            align: "right",
            colSpan: 1
        });
        var _td4_2 = new Element("td", {
            align: "center",
            colSpan: 1
        });
        var _td4_3 = new Element("td", {
            align: "right",
            colSpan: 1
        });
        var _td4_4 = new Element("td", {
            align: "center",
            colSpan: 1
        });
        var _td4_5 = new Element("td", {
            align: "right",
            colSpan: 1
        });
        var _td4_6 = new Element("td", {
            align: "left",
            colSpan: 2
        });
        var _td4_7 = new Element("td", {
            align: "left",
            colSpan: 3
        });

        //------------------- QUINTA LINHA -----------------------------
        var _td5_1 = new Element("td", {
            align: "right",
            colSpan: 1
        });
        var _td5_2 = new Element("td", {
            align: "left",
            colSpan: 1
        });
        var _td5_3 = new Element("td", {
            align: "right",
            colSpan: 1
        });
        var _td5_4 = new Element("td", {
            align: "center",
            colSpan: 1
        });
        var _td5_5 = new Element("td", {
            align: "right",
            colSpan: 1
        });
        var _td5_6 = new Element("td", {
            align: "left",
            colSpan: 1
        });
        var _td5_7 = new Element("td", {
            align: "right",
            colSpan: 1
        });
        var _td5_8 = new Element("td", {
            align: "center",
            colSpan: 1
        });
        var _td5_9 = new Element("td", {
            align: "right",
            colSpan: 1
        });
        var _td5_10 = new Element("td", {
            align: "right",
            colSpan: 1
        });

        //------------------- SEXTA LINHA -----------------------------
        var _td6_1 = new Element("td", {
            align: "right",
            colSpan: 3
        });
        var _td6_2 = new Element("td", {
            align: "center",
            colSpan: 1
        });
        var _td6_3 = new Element("td", {
            align: "right",
            colSpan: 1
        });
        var _td6_4 = new Element("td", {
            align: "left",
            colSpan: 1
        });
        var _td6_5 = new Element("td", {
            align: "right",
            colSpan: 1
        });
        var _td6_6 = new Element("td", {
            align: "center",
            colSpan: 1
        });
        var _td6_7 = new Element("td", {
            align: "right",
            colSpan: 1
        });
        var _td6_8 = new Element("td", {
            align: "right",
            colSpan: 1
        });

        var _inpTipoProduto = Builder.node("select", {
            id: "tipoProduto_" + comp.indice,
            name: "tipoProduto_" + comp.indice,
            type: "text",
            className: estiloMin,
            onChange: callAlteraTipoTaxa
        });
        if (listOptTipoProd.size() == 0) {
            listOptTipoProd[0] = new Option(0, "NENHUM");
        }
        povoarSelect(_inpTipoProduto, listOptTipoProd);

        var _slcTpFrete = Builder.node('select', {
            name: 'tipoFrete_' + comp.indice,
            id: 'tipoFrete_' + comp.indice,
            className: 'fieldMin',
            onChange: callAlterarTipoFrete + callAlteraTipoTaxa
        });
        var _tipoTaxaTabela = Builder.node('input', {
            name: 'tipoTaxaTabela_' + comp.indice,
            id: 'tipoTaxaTabela_' + comp.indice,
            type: "hidden",
            value: ""
        });
        povoarSelect(_slcTpFrete, listaTipoFreteAll);
        if (!alteraTipoFrete) {
            desabilitar(_slcTpFrete);
        }
        var _slcTpVeiculo = Builder.node('select', {
            name: 'tipoVeiculo_' + comp.indice,
            id: 'tipoVeiculo_' + comp.indice,
            className: 'fieldMin',
            onChange: callAlteraTipoTaxa
        });
        if (listOptTipoVeiculo != null && listOptTipoVeiculo != undefined) {
            povoarSelect(_slcTpVeiculo, listOptTipoVeiculo);
        }

        if (comp.tipFrete != (-1)) {
            _slcTpFrete.value = comp.tipFrete;
        } else {
            _slcTpFrete.selectedIndex = 0;
        }
        if (comp.tipProd != 0) {
            _inpTipoProduto.value = comp.tipProd;
        } else {
            _inpTipoProduto.selectedIndex = 0;
        }
        if (comp.tipVeiculo != (0)) {
            _slcTpVeiculo.value = comp.tipVeiculo;
        } else {
            _slcTpVeiculo.selectedIndex = 0;
        }

        var _inpId = Builder.node("input", {
            type: "hidden",
            name: "idComp_" + comp.indice,
            id: "idComp_" + comp.indice,
            value: comp.id
        });
        var _inpDtPrevEntrega = Builder.node("label", {
            id: "dtPrevEntrega_" + comp.indice
        }, comp.dtPrevisaoEntrega);

        var _img1 = Builder.node('IMG', {
            src: 'img/lixo.png',
            title: 'Excluir',
            className: 'imagemLink',
            onClick: "removerComposicaoOrcamento(" + comp.indice + ")"
        });
        var _img2 = Builder.node('IMG', {
            src: 'img/pdf.jpg',
            title: 'Imprimir',
            className: 'imagemLink',
            onClick: "imprimirSimulacao(" + comp.indice + ")"
        });

        var _inpQtdEntrega = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            onkeypress: callMascaraSoNumeros,
            onBlur: "seLimpoReset(this, '1');" + callCalculaTaxaFixaTotalVarios,
            size: 9,
            name: "qtdEntrega_" + comp.indice,
            id: "qtdEntrega_" + comp.indice,
            value: comp.qtdEntrega
        });
        var _inpQtdPallet = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            onkeypress: "seLimpoReset(this, '0');" + callMascaraSoNumeros,
            size: 9,
            name: "qtdPallet_" + comp.indice,
            id: "qtdPallet_" + comp.indice,
            value: comp.qtdPallet
        });
        var _inpDistanciaKm = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            onkeypress: "seLimpoReset(this, '0');" + callMascaraSoNumeros,
            size: 9,
            name: "distanciaKm_" + comp.indice,
            id: "distanciaKm_" + comp.indice,
            value: comp.distanciaKm
        });
        var _inpCodTabela = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            onkeypress: callMascaraSoNumeros,
            size: 9,
            name: "codTab_" + comp.indice,
            id: "codTab_" + comp.indice,
            value: comp.codTabela
        });
        readOnly(_inpCodTabela, "inputReadOnly8pt");

        var _inpAddICMS = Builder.node("input", {
            id: "isAddIcms_" + comp.indice,
            name: "isAddIcms_" + comp.indice,
            type: "checkbox",
            onClick: callCalculaFreteVarios
        });
        var _inpAddPisCofins = Builder.node("input", {
            id: "isAddPisCofins_" + comp.indice,
            name: "isAddPisCofins_" + comp.indice,
            type: "checkbox",
            onClick: callCalculaFreteVarios
        });
        var _inpSelecionado = Builder.node("input", {
            id: "isSelecionado_" + comp.indice,
            name: "isSelecionado",
            type: "radio",
            value: comp.id,
            onClick: callSelecionarEleiro
        });
        _inpSelecionado.checked = comp.isSelecionado;
        var _inpDescFreteNacional = Builder.node("input", {
            id: "isDescFreteNacional_" + comp.indice,
            name: "isDescFreteNacional_" + comp.indice,
            type: "checkbox",
            onClick: callCalculaFreteVarios
        });
        var _inpDescAdValorem = Builder.node("input", {
            id: "isDescAdValorem_" + comp.indice,
            name: "isDescAdValorem_" + comp.indice,
            type: "checkbox",
            onClick: callCalculaFreteVarios
        });
        var _inpCobrarTde = Builder.node("input", {
            id: "isCobrarTde_" + comp.indice,
            name: "isCobrarTde_" + comp.indice,
            type: "checkbox",
            onClick: callCalculaFreteVarios
        });

        _inpAddICMS.checked = comp.isIncluirIcms;
        _inpAddPisCofins.checked = comp.isIncluirPisCofins;
        _inpCobrarTde.checked = comp.isCobrarTde;
        _inpDescAdValorem.checked = comp.isDescontoAdValorem;
        _inpDescFreteNacional.checked = comp.isDescontoFreteNacional;

        var _inpVlTaxaFixa = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            style: estiloTextRight,
            onKeyPress: callMascaraReais,
            onBlur: "seLimpoReset(this, '0,00');" + callCalculaTaxaFixaTotalVarios,
            size: 9,
            name: "vlTaxaFixa_" + comp.indice,
            id: "vlTaxaFixa_" + comp.indice,
            value: colocarVirgula(comp.vlTaxaFixa)
        });
        var _inpVlTaxaFixaTot = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            style: estiloTextRight,
            onKeyPress: callMascaraReais,
            onBlur: "seLimpoReset(this, '0,00');" + callCalculaTaxaFixaTotalVarios,
            size: 9,
            name: "vlTaxaFixaTot_" + comp.indice,
            id: "vlTaxaFixaTot_" + comp.indice,
            value: colocarVirgula(comp.vlTaxaFixaTotal)
        });
        var _inpVlDespacho = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            style: estiloTextRight,
            onKeyPress: callMascaraReais,
            onBlur: "seLimpoReset(this, '0,00');" + callCalculaFreteVarios,
            size: 9,
            name: "vlDespacho_" + comp.indice,
            id: "vlDespacho_" + comp.indice,
            value: colocarVirgula(comp.vlDespacho)
        });
        var _inpVlAdeme = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            onKeyPress: callMascaraReais,
            onBlur: "seLimpoReset(this, '0,00');" + callCalculaFreteVarios,
            style: estiloTextRight,
            size: 9,
            name: "vlAdeme_" + comp.indice,
            id: "vlAdeme_" + comp.indice,
            value: colocarVirgula(comp.vlAdeme)
        });
        var _inpVlFretePeso = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            onKeyPress: callMascaraReais,
            onBlur: "seLimpoReset(this, '0,00');" + callCalculaFreteVarios,
            style: estiloTextRight,
            size: 9,
            name: "vlFretePeso_" + comp.indice,
            id: "vlFretePeso_" + comp.indice,
            value: colocarVirgula(comp.vlFretePeso)
        });
        var _inpVlFreteValor = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            onKeyPress: callMascaraReais,
            onBlur: "seLimpoReset(this, '0,00');" + callCalculaFreteVarios,
            style: estiloTextRight,
            size: 9,
            name: "vlFreteValor_" + comp.indice,
            id: "vlFreteValor_" + comp.indice,
            value: colocarVirgula(comp.vlFreteValor)
        });
        var _inpVlItr = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            onKeyPress: callMascaraReais,
            onBlur: "seLimpoReset(this, '0,00');" + callCalculaFreteVarios,
            style: estiloTextRight,
            size: 9,
            name: "vlItr_" + comp.indice,
            id: "vlItr_" + comp.indice,
            value: colocarVirgula(comp.vlItr)
        });
        var _inpVlSecCat = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            onKeyPress: callMascaraReais,
            onBlur: "seLimpoReset(this, '0,00');" + callCalculaFreteVarios,
            style: estiloTextRight,
            size: 9,
            name: "vlSecCat_" + comp.indice,
            id: "vlSecCat_" + comp.indice,
            value: colocarVirgula(comp.vlSecCat)
        });
        var _inpVlOutros = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            onKeyPress: callMascaraReais,
            onBlur: "seLimpoReset(this, '0,00');" + callCalculaFreteVarios,
            style: estiloTextRight,
            size: 9,
            name: "vlOutros_" + comp.indice,
            id: "vlOutros_" + comp.indice,
            value: colocarVirgula(comp.vlOutros)
        });
        var _inpBaseCubagem = Builder.node("input", {
            type: "hidden",
            className: "fieldMin",
            maxlength: 10,
            size: 9,
            name: "baseCubagem_" + comp.indice,
            id: "baseCubagem_" + comp.indice,
            value: comp.baseCubagem
        });
        var _inpPesoCubagem = Builder.node("input", {
            type: "hidden",
            className: "fieldMin",
            maxlength: 10,
            size: 9,
            name: "pesoCubagem_" + comp.indice,
            id: "pesoCubagem_" + comp.indice,
            value: comp.pesoCubagem
        });
        var _inpVlGris = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            onKeyPress: callMascaraReais,
            onBlur: "seLimpoReset(this, '0,00');" + callCalculaFreteVarios,
            style: estiloTextRight,
            size: 9,
            name: "vlGris_" + comp.indice,
            id: "vlGris_" + comp.indice,
            value: colocarVirgula(comp.vlGris)
        });
        var _inpVlPedagio = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            onKeyPress: callMascaraReais,
            onBlur: "seLimpoReset(this, '0,00');" + callCalculaFreteVarios,
            style: estiloTextRight,
            size: 9,
            name: "vlPedagio_" + comp.indice,
            id: "vlPedagio_" + comp.indice,
            value: colocarVirgula(comp.vlPedagio)
        });
        var _inpVlTde = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            style: estiloTextRight,
            onKeyPress: callMascaraReais,
            onBlur: "seLimpoReset(this, '0,00');" + callCalculaFreteVarios,
            size: 9,
            name: "vlTde_" + comp.indice,
            id: "vlTde_" + comp.indice,
            value: colocarVirgula(comp.vlTde)
        });
        var _inpVlDesconto = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            style: estiloTextRight,
            onKeyPress: callMascaraReais,
            onBlur: "seLimpoReset(this, '0,00');" + callCalculaFreteVarios,
            size: 9,
            name: "vlDesconto_" + comp.indice,
            id: "vlDesconto_" + comp.indice,
            value: colocarVirgula(comp.vlDesconto)
        });
        var _inpVlTotalPrestacao = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            style: estiloTextRight,
            onKeyPress: callMascaraReais,
            onBlur: "seLimpoReset(this, '0,00');" + callCalculaFreteVarios,
            size: 9,
            name: "vlTotalPrestacao_" + comp.indice,
            id: "vlTotalPrestacao_" + comp.indice,
            value: "0,00"
        });
        readOnly(_inpVlTotalPrestacao, "inputReadOnly8pt");
        var _inpVlBaseCalc = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            style: estiloTextRight,
            onKeyPress: callMascaraReais,
            onBlur: "seLimpoReset(this, '0,00');" + callCalculaFreteVarios,
            size: 9,
            name: "baseCalcIcms_" + comp.indice,
            id: "baseCalcIcms_" + comp.indice,
            value: colocarVirgula(comp.baseIcms)
        });
        var _inpPercIcms = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            style: estiloTextRight,
            onKeyPress: callMascaraReais,
            onBlur: "seLimpoReset(this, '0,00');" + callCalculaFreteVarios,
            size: 9,
            name: "percIcms_" + comp.indice,
            id: "percIcms_" + comp.indice,
            value: colocarVirgula(comp.percIcms)
        });
        var _inppercDesconto = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            style: estiloTextRight,
            onKeyPress: callMascaraReais,
            onBlur: "seLimpoReset(this, '0,00');" + callCalculaFreteVarios,
            size: 9,
            name: "percDesconto_" + comp.indice,
            id: "percDesconto_" + comp.indice,
            value: colocarVirgula(comp.percDesconto)
        });
        var _inpVlIcms = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            style: estiloTextRight,
            onkeypress: callMascaraReais,
            size: 9,
            name: "vlIcms_" + comp.indice,
            id: "vlIcms_" + comp.indice,
            value: ""
        });
        var _inpVlPisCofins = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            style: estiloTextRight,
            onkeypress: callMascaraReais,
            size: 9,
            name: "vlPisCofins_" + comp.indice,
            id: "vlPisCofins_" + comp.indice,
            value: "0,00"
        });
        var _inpVlIcmsImbutido = Builder.node("input", {
            type: "hidden",
            className: "fieldMin",
            maxlength: 10,
            style: estiloTextRight,
            onkeypress: callMascaraReais,
            size: 9,
            name: "vlIcmsImbutido_" + comp.indice,
            id: "vlIcmsImbutido_" + comp.indice,
            value: colocarVirgula(comp.vlIcmsImbutido)
        });

        var _inpVlPeso = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            style: estiloTextRight,
            onKeyPress: callMascaraReais,
            onBlur: "seLimpoReset(this, '0,00');" + callCalculaFreteVarios,
            size: 9,
            name: "vlPeso_" + comp.indice,
            id: "vlPeso_" + comp.indice,
            value: colocarVirgula(comp.vlPeso)
        });
        var _inpVlDespesaColeta = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            style: estiloTextRight,
            onKeyPress: callMascaraReais,
            onBlur: "seLimpoReset(this, '0,00');" + callCalculaFreteVarios,
            size: 9,
            name: "vlDespesaColeta_" + comp.indice,
            id: "vlDespesaColeta_" + comp.indice,
            value: colocarVirgula(comp.vlDespesaColeta)
        });
        var _inpVlDespesaEntrega = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            style: estiloTextRight,
            onKeyPress: callMascaraReais,
            onBlur: "seLimpoReset(this, '0,00');" + callCalculaFreteVarios,
            size: 9,
            name: "vlDespesaEntrega_" + comp.indice,
            id: "vlDespesaEntrega_" + comp.indice,
            value: colocarVirgula(comp.vlDespesaEntrega)
        });
        var _inpResumoFinanceiro = Builder.node("input", {
            type: "text",
            className: "fieldMin",
            maxlength: 10,
            style: estiloTextRight,
            onKeyPress: callMascaraReais,
            onBlur: "seLimpoReset(this, '0,00');" + callCalculaFreteVarios,
            size: 9,
            name: "vlResumoFinanceiro_" + comp.indice,
            id: "vlResumoFinanceiro_" + comp.indice,
            value: colocarVirgula(comp.resumoFinanceiro)
        });


        _tdSelecionado.appendChild(_inpId);
        if (comp.id != 0) {
            _tdSelecionado.appendChild(_inpSelecionado);
            _tdImpressao.appendChild(_img2);
        }
        _tdLixo.appendChild(_img1);

        _tdTipoProdDesc.appendChild(_labelTipoProduto);
        _tdTipoProdValor.appendChild(_inpTipoProduto);
        _tdTipoFreteDesc.appendChild(_labelTipoFrete);
        _tdTipoFreteValor.appendChild(_slcTpFrete);
        _tdTipoFreteValor.appendChild(_tipoTaxaTabela);
        _tdTipoVeiculoDesc.appendChild(_labelTipoVeiculo);
        _tdTipoVeiculoValor.appendChild(_slcTpVeiculo);

        _td11.appendChild(_labelDistancia);
        _td11.appendChild(_labelPallets);
        _td12.appendChild(_inpDistanciaKm);
        _td12.appendChild(_inpQtdPallet);
        _td13.appendChild(_labelQtdEntrega);
        _td14.appendChild(_inpQtdEntrega);
        _td16.appendChild(_labelTabelaUtilizada);
        _td17.appendChild(_inpCodTabela);
        _td18.appendChild(_inpAddICMS);
        _td18.appendChild(_labelIncluirIcms);
        _td18.appendChild(Builder.node("br"));
        _td18.appendChild(_inpAddPisCofins);
        _td18.appendChild(_labelIncluirPisCofins);

        _td21.appendChild(_labelTaxaFixa);
        _td22.appendChild(_inpVlTaxaFixa);
        _td22.appendChild(_labelTaxaFixaIgual);
        _td22.appendChild(_inpVlTaxaFixaTot);
        _td23.appendChild(_labelDespacho);
        _td24.appendChild(_inpVlDespacho);
        _td25.appendChild(_labelAdeme);
        _td26.appendChild(_inpVlAdeme);
        _td27.appendChild(_labelFretePeso);
        _td28.appendChild(_inpVlFretePeso);
        _td29.appendChild(_labelFreteValor);
        _td210.appendChild(_inpVlFreteValor);

        _td3_1.appendChild(_labelITR);
        _td3_2.appendChild(_inpVlItr);
        _td3_3.appendChild(_labelSecCat);
        _td3_4.appendChild(_inpVlSecCat);
        _td3_5.appendChild(_labelOutros);
        _td3_6.appendChild(_inpVlOutros);
        _td3_7.appendChild(_labelGris);
        _td3_8.appendChild(_inpVlGris);
        _td3_9.appendChild(_labelPedagio);
        _td3_10.appendChild(_inpVlPedagio);

        _td4_2.appendChild(_inpCobrarTde);
        _td4_2.appendChild(_labelCobrarTde);
        _td4_3.appendChild(_labelTde);
        _td4_4.appendChild(_inpVlTde);
        _td4_5.appendChild(_labelDesconto);
        _td4_6.appendChild(_labelDescontoR$);
        _td4_6.appendChild(_inpVlDesconto);
        _td4_6.appendChild(_labelPercDesconto);
        _td4_6.appendChild(_inppercDesconto);
        _td4_7.appendChild(_inpDescFreteNacional);
        _td4_7.appendChild(_labelDescFreteNacional);
        _td4_7.appendChild(Builder.node("br"));
        _td4_7.appendChild(_inpDescAdValorem);
        _td4_7.appendChild(_labelDescAdValorem);

        _td5_1.appendChild(_labelTotalPrestacao);
        _td5_2.appendChild(_inpVlTotalPrestacao);
        _td5_3.appendChild(_labelBaseCalculo);
        _td5_4.appendChild(_inpVlBaseCalc);
        _td5_4.appendChild(_inpBaseCubagem);
        _td5_4.appendChild(_inpPesoCubagem);
        _td5_5.appendChild(_labelAliquota);
        _td5_6.appendChild(_inpPercIcms);
        _td5_7.appendChild(_labelIcms);
        _td5_8.appendChild(_inpVlIcms);
        _td5_9.appendChild(_labelPisCofins);
        _td5_10.appendChild(_inpVlPisCofins);
        _td5_10.appendChild(_inpVlIcmsImbutido);

        _td6_1.appendChild(_labelValorPeso);
        _td6_2.appendChild(_inpVlPeso);
        _td6_3.appendChild(_labelValorDespesaColeta);
        _td6_4.appendChild(_inpVlDespesaColeta);
        _td6_5.appendChild(_labelValorDespesaEntrega);
        _td6_6.appendChild(_inpVlDespesaEntrega);
        _td6_7.appendChild(_labelResumoFinanceiro);
        _td6_8.appendChild(_inpResumoFinanceiro);


        _trTipo.appendChild(_tdSelecionado);
        _trTipo.appendChild(_tdImpressao);
        _trTipo.appendChild(_tdTipoProdDesc);
        _trTipo.appendChild(_tdTipoProdValor);
        _trTipo.appendChild(_tdTipoFreteDesc);
        _trTipo.appendChild(_tdTipoFreteValor);
        _trTipo.appendChild(_tdTipoVeiculoDesc);
        _trTipo.appendChild(_tdTipoVeiculoValor);
        _trTipo.appendChild(_tdLixo);


        _tr1.appendChild(_td11);
        _tr1.appendChild(_td12);
        _tr1.appendChild(_td13);
        _tr1.appendChild(_td14);
        _tr1.appendChild(_td15);
        _tr1.appendChild(_td16);
        _tr1.appendChild(_td17);
        _tr1.appendChild(_td18);

        _tr2.appendChild(_td21);
        _tr2.appendChild(_td22);
        _tr2.appendChild(_td23);
        _tr2.appendChild(_td24);
        _tr2.appendChild(_td25);
        _tr2.appendChild(_td26);
        _tr2.appendChild(_td27);
        _tr2.appendChild(_td28);
        _tr2.appendChild(_td29);
        _tr2.appendChild(_td210);

        _tr3.appendChild(_td3_1);
        _tr3.appendChild(_td3_2);
        _tr3.appendChild(_td3_3);
        _tr3.appendChild(_td3_4);
        _tr3.appendChild(_td3_5);
        _tr3.appendChild(_td3_6);
        _tr3.appendChild(_td3_7);
        _tr3.appendChild(_td3_8);
        _tr3.appendChild(_td3_9);
        _tr3.appendChild(_td3_10);

        _tr4.appendChild(_td4_1);
        _tr4.appendChild(_td4_2);
        _tr4.appendChild(_td4_3);
        _tr4.appendChild(_td4_4);
        _tr4.appendChild(_td4_5);
        _tr4.appendChild(_td4_6);
        _tr4.appendChild(_td4_7);

        _tr5.appendChild(_td5_1);
        _tr5.appendChild(_td5_2);
        _tr5.appendChild(_td5_3);
        _tr5.appendChild(_td5_4);
        _tr5.appendChild(_td5_5);
        _tr5.appendChild(_td5_6);
        _tr5.appendChild(_td5_7);
        _tr5.appendChild(_td5_8);
        _tr5.appendChild(_td5_9);
        _tr5.appendChild(_td5_10);

        _tr6.appendChild(_td6_1);
        _tr6.appendChild(_td6_2);
        _tr6.appendChild(_td6_3);
        _tr6.appendChild(_td6_4);
        _tr6.appendChild(_td6_5);
        _tr6.appendChild(_td6_6);
        _tr6.appendChild(_td6_7);
        _tr6.appendChild(_td6_8);

        _tabela.appendChild(_trTipo);
        _tabela.appendChild(_tr1);
        _tabela.appendChild(_tr2);
        _tabela.appendChild(_tr3);
        _tabela.appendChild(_tr4);
        _tabela.appendChild(_tr5);
        _tabela.appendChild(_tr6);


        if ($("tipoTransporte_tipo").value == "a") {
            visivel(_labelPercDesconto);
            visivel(_inppercDesconto);
            visivel(_inpDescFreteNacional);
            visivel(_labelDescFreteNacional);
            visivel(_inpDescAdValorem);
            visivel(_labelDescAdValorem);
        } else {
            invisivel(_labelPercDesconto);
            invisivel(_inppercDesconto);
            invisivel(_inpDescFreteNacional);
            invisivel(_labelDescFreteNacional);
            invisivel(_inpDescAdValorem);
            invisivel(_labelDescAdValorem);

        }

        readOnly(_inpVlIcms, "inputReadOnly8pt");
        readOnly(_inpPercIcms, "inputReadOnly8pt");
        readOnly(_inpVlDespesaColeta, "inputReadOnly8pt");
        readOnly(_inpVlDespesaEntrega, "inputReadOnly8pt");
        readOnly(_inpResumoFinanceiro, "inputReadOnly8pt");


        calculaFreteVarios(comp.indice);
        if (comp.id == 0) {
            redespTxOrigemVarios(comp.indice);
            redespTxDestinoVarios(comp.indice);
            alteraTipoTaxaVarios('N', comp.indice);
        } else {
            travarTipoFrete(comp.indice);
        }
        alterarTipoFrete(_slcTpFrete.value, comp.indice);
        validarTipoTransporteVarios(comp.indice);

        $("qtdCompFrete").value = comp.indice;

    } catch (e) {
        alert(e);
        console.log(e);
    }
}

function alterarTipoFrete(valor, idx) {
    $("lbDistancia_" + idx).style.display = "none";
    $("distanciaKm_" + idx).style.display = "none";
    $("lbPallet_" + idx).style.display = "none";
    $("qtdPallet_" + idx).style.display = "none";
    if (valor == "1") {
    } else if (valor == "5") {
        $("lbDistancia_" + idx).style.display = "";
        $("distanciaKm_" + idx).style.display = "";
    } else if (valor == "6") {
        $("lbPallet_" + idx).style.display = "";
        $("qtdPallet_" + idx).style.display = "";
    }
}
/**
 * esta tem a função de fazer a soma de todos os impostos
 * @param {type} idx
 * @returns {void}
 */
function calculaFreteVarios(idx) {
    try {

        var resultado = 0;
        var vlTaxaFixa = colocarPonto($("vlTaxaFixaTot_" + idx).value);
        var vlItr = colocarPonto($("vlItr_" + idx).value);
        var vlAdeme = colocarPonto($("vlAdeme_" + idx).value);
        var vlFretePeso = colocarPonto($("vlFretePeso_" + idx).value);
        var vlFreteValor = colocarPonto($("vlFreteValor_" + idx).value);
        var vlSecCat = colocarPonto($("vlSecCat_" + idx).value);
        var vlOutros = colocarPonto($("vlOutros_" + idx).value);
        var vlDespacho = colocarPonto($("vlDespacho_" + idx).value);
        var vlDesconto = colocarPonto($("vlDesconto_" + idx).value);
        var vlPedagio = colocarPonto($("vlPedagio_" + idx).value);
        var percDesconto = colocarPonto($("percDesconto_" + idx).value);
        var vlGris = colocarPonto($("vlGris_" + idx).value);
        resultado = parseFloat(vlTaxaFixa) + parseFloat(vlItr)
                + parseFloat(vlAdeme) + parseFloat(vlFretePeso) +
                parseFloat(vlFreteValor) + parseFloat(vlSecCat) +
                parseFloat(vlOutros) + parseFloat(vlGris) +
                parseFloat(vlDespacho) + parseFloat(vlPedagio) -
                (parseFloat(percDesconto) > 0 && $("tipoTransporte_tipo").value == "a" ? (parseFloat(percDesconto) * (parseFloat($("isDescAdValorem_" + idx).checked ? parseFloat(vlFreteValor) : 0) + parseFloat($("isDescFreteNacional_" + idx).checked ? parseFloat(vlFretePeso) : 0))) / 100 : parseFloat(vlDesconto));

        if (percDesconto > 0) {
            var valorDescontoPercentual = (parseFloat(percDesconto) * (parseFloat($("isDescAdValorem_" + idx).checked ? parseFloat(vlFreteValor) : 0) + parseFloat($("isDescFreteNacional_" + idx).checked ? parseFloat(vlFretePeso) : 0))) / 100;
            $("vlDesconto_" + idx).value = colocarVirgula(valorDescontoPercentual);
        }

        if ($('isCobrarTde_' + idx).checked) {
            if (tarifas != undefined && tarifas != null && tarifasVarias[idx] != undefined && tarifasVarias[idx] != undefined) {
                if (tarifasVarias[idx].formula_tde != undefined && tarifasVarias[idx].formula_tde != '') {
                    $('vlTde_' + idx).value = colocarVirgula(getTDE(tarifasVarias[idx].formula_tde, $("tipoFrete_" + idx).value, $('peso').value, $('valorMercadoria').value,
                            $('volumes').value, parseFloat(colocarPonto($("qtdPallet_" + idx).value)),
                            parseInt(colocarPonto($("distanciaKm_" + idx).value), 10), $("tipoVeiculo_" + idx).value,
                            tarifasVarias[idx].is_considerar_maior_peso, $("baseCubagem_" + idx).value, $("metro").value,
                            parseFloat(colocarPonto($("qtdEntrega_" + idx).value)), $("tipoTransporte_tipo").value),
                            resultado, vlFretePeso, vlFreteValor);
                } else if (tarifasVarias[idx].tipo_tde == 'v') {
                    $('vlTde_' + idx).value = colocarVirgula(tarifasVarias[idx].valor_dificuldade_entrega);
                } else if (tarifasVarias[idx].tipo_tde == 'p') {
                    $('vlTde_' + idx).value = colocarVirgula((parseFloat(resultado) * tarifasVarias[idx].valor_dificuldade_entrega / 100));
                }
            }
            resultado = parseFloat(resultado) + parseFloat(colocarPonto($('vlTde_' + idx).value));
        } else {
            $('vlTde_' + idx).value = "0,00";
        }

        $("vlTotalPrestacao_" + idx).value = colocarVirgula(resultado);

//        if (parseInt($("idComp_" + idx).value, 10) != 0) {
        /*
         funçao não utilizada no carregar do banco.
         desver ser separada das demais.
         */
        $("baseCalcIcms_" + idx).value = colocarVirgula(resultado);
//        }
        // calculo do ICMS
        $("vlIcms_" + idx).value = colocarVirgula(parseFloat(colocarPonto($("percIcms_" + idx).value)) * parseFloat(colocarPonto($("baseCalcIcms_" + idx).value)) / 100);

        //Caso esteja marcada a opção de incluir icms
        calculoIncluiIcmsVarios(idx);
//        validaTipoTransporte();

        $("vlDespesaColeta_" + idx).value = ($("idredespachanteColeta").value != 0 ? colocarVirgula(vlTaxaFixa, 2) : "0,00");
        $("vlDespesaEntrega_" + idx).value = ($("idredespachanteEntrega").value != 0 ? colocarVirgula(vlSecCat) : "0,00");


        calcResumoFinanceiro(idx);


    } catch (e) {
        alert("Erro ao calcular frete" + e);
        console.log("Erro ao calcular frete" + e);
        throw e;
    }
}

function calculaTaxaFixaTotalVarios(valor, idx) {
    try {
        valor = parseFloat(colocarPonto(valor));
        /*
         Esta função calcula o valor da taxa fixa total, inversamente proporcional
         ou seja, caso o mesmo precione tab na quantidade ele vai fazer a multiplicação,
         como faria tabem na taxa fixa, porem caso o mesmo prescione tab no total será feito a divisão.
         depois calcula o frete.
         */
        if (parseFloat(colocarPonto($("qtdEntrega_" + idx).value)) == valor || parseFloat(colocarPonto($("vlTaxaFixa_" + idx).value)) == valor) {
            $("vlTaxaFixaTot_" + idx).value = colocarVirgula(parseFloat(colocarPonto($("vlTaxaFixa_" + idx).value))
                    * parseFloat(colocarPonto($("qtdEntrega_" + idx).value)));
        } else {
            if ($("qtdEntrega_" + idx).value == 0) {
                $("qtdEntrega_" + idx).value = "1";
                $("vlTaxaFixa_" + idx).value = ($("vlTaxaFixaTot_" + idx).value);
            } else {
                $("vlTaxaFixa_" + idx).value = colocarVirgula(parseFloat(colocarPonto($("vlTaxaFixaTot_" + idx).value)) /
                        parseFloat(colocarPonto($("qtdEntrega_" + idx).value)));
            }
        }
        calculaFreteVarios(idx);
    } catch (e) {
        alert("Erro ao calcular taxa fixa.");
        console.log("Erro ao calcular taxa fixa.");
        throw e;
    }
}

function calculoIncluiIcmsVarios(idx) {
    try {
        var totalPrestacao = parseFloat(colocarPonto($("vlTotalPrestacao_" + idx).value));
        var aliquota = parseFloat(colocarPonto($("percIcms_" + idx).value));
        var icms = parseFloat(colocarPonto($("vlTotalPrestacao_" + idx).value));
        if ($("isAddIcms_" + idx).checked && $("isAddPisCofins_" + idx).checked) {
            aliquota += parseFloat(federais);
            totalPrestacao = totalPrestacao / ((100 - aliquota) / 100);
            $("vlTotalPrestacao_" + idx).value = colocarVirgula(totalPrestacao);
            $("baseCalcIcms_" + idx).value = colocarVirgula(totalPrestacao);
            $("vlIcms_" + idx).value = colocarVirgula(parseFloat(colocarPonto($("vlTotalPrestacao_" + idx).value)) *
                    parseFloat(colocarPonto($("percIcms_" + idx).value)) / 100);
            $("vlIcmsImbutido_" + idx).value = $("vlIcms_" + idx).value;
            $("vlPisCofins_" + idx).value = colocarVirgula(parseFloat(colocarPonto($("vlTotalPrestacao_" + idx).value)) * parseFloat(federais) / 100);
        } else if ($("isAddIcms_" + idx).checked) {
            totalPrestacao = totalPrestacao / ((100 - aliquota) / 100);
            icms = totalPrestacao - icms;
            $("vlTotalPrestacao_" + idx).value = colocarVirgula(totalPrestacao);
            $("baseCalcIcms_" + idx).value = colocarVirgula(totalPrestacao);
            $("vlIcms_" + idx).value = colocarVirgula(icms);
            $("vlIcmsImbutido_" + idx).value = colocarVirgula(icms);
            $("vlPisCofins_" + idx).value = '0,00';
        } else if ($("isAddPisCofins_" + idx).checked) {
            totalPrestacao = totalPrestacao / ((100 - federais) / 100);
            $("vlTotalPrestacao_" + idx).value = colocarVirgula(totalPrestacao);
            $("baseCalcIcms_" + idx).value = colocarVirgula(totalPrestacao);
            $("vlPisCofins_" + idx).value = colocarVirgula(parseFloat(colocarPonto($("vlTotalPrestacao_" + idx).value)) * parseFloat(federais) / 100);
            $("vlIcms_" + idx).value = colocarVirgula(parseFloat(colocarPonto($("vlTotalPrestacao_" + idx).value)) * parseFloat(colocarPonto($("percIcms_" + idx).value)) / 100);
            $("vlIcmsImbutido_" + idx).value = "0";
        } else {
            $("vlIcmsImbutido_" + idx).value = "0";
            $("vlPisCofins_" + idx).value = '0,00';
        }
        calcResumoFinanceiro(idx);
    } catch (e) {
        alert("ERRO AO CALCULAR ICMS!" + e);
        console.log(e);
    }
}

function limparComposicaoFreteVarios(idx){
    $("vlTaxaFixa_" + idx).value = "0,00";
    $("vlTaxaFixaTot_" + idx).value = "0,00";
    $("vlItr_" + idx).value = "0,00";
    $("vlDespacho_" + idx).value = "0,00";
    $("vlAdeme_" + idx).value = "0,00";
    $("vlFretePeso_" + idx).value = "0,00";
    $("vlFreteValor_" + idx).value = "0,00";
    //segunda linha
    $("vlSecCat_" + idx).value = "0,00";
    $("vlOutros_" + idx).value = "0,00";
    $("vlGris_" + idx).value = "0,00";
    $("vlPedagio_" + idx).value = "0,00";
    $("vlDesconto_" + idx).value = "0,00";
    //terceira linha
    $("vlTotalPrestacao_" + idx).value = "0,00";
    $("baseCalcIcms_" + idx).value = "0,00";
    $("vlIcms_" + idx).value = "0,00";
    //novos
    $("baseCubagem_" + idx).value = "0";
    $("codTab_" + idx).value = "";
    redespTxOrigemVarios(idx);
    redespTxDestinoVarios(idx);
}

function alteraTipoTaxaVarios(valida, idx) {
    try {
        pesoRealVarios[idx] = 0;
        var idtaxa = $("tipoFrete_" + idx).value;
        //objeto funcao usado na requisicao Ajax(uma espécie de evento)
        function e(transport) {
            var textoresposta = transport.responseText;
            espereEnviar("", false);

            //se deu algum erro na requisicao...
            if (textoresposta == "load=0") {

                buscouTaxas = "0";
                //fechaClientesWindow();
                if (valida == "S") {

                    alert("Não foi encontrada nenhuma tabela de preço para essa origem e esse destino.");

                    //Zerar valores calculo frete
                    //primeira linha
                    limparComposicaoFreteVarios(idx);

                }
                return false;
            } else {

                var _tab = '(' + textoresposta + ')';

                tarifasVarias[idx] = eval(_tab); // retono JSON
                if (tarifasVarias[idx].cliente_id == undefined) {
                    if (!confirm("Não foi encontrada nenhuma tabela de preço para essa origem e destino, \n deseja utilizar a tabela principal?")) {
                        return false;
                    }
                } else if (false) {// não é necessario entrar aqui
                    if (tarifasVarias[idx].valida_ate != undefined) {
                        var dataEmissao = new Date($('dtemissao').value.substring(6, 10), $('dtemissao').value.substring(3, 5), $('dtemissao').value.substring(0, 2));
                        var dataValidade = new Date(tarifasVarias[idx].valida_ate.substring(0, 4), tarifasVarias[idx].valida_ate.substring(5, 7), tarifasVarias[idx].valida_ate.substring(8, 10));
                        if (dataValidade.getTime() < dataEmissao.getTime()) {
                            alert('Atenção: A tabela de preço número ' + tarifasVarias[idx].id + ' esta vencida! Favor comunicar ao setor comercial.');
                        }
                    }
                    if ($('con_tabela_remetente').value == 'q' && ($("utilizaTipoFreteTabelaConsig").value == 'f' || $("utilizaTipoFreteTabelaConsig").value == 'false')) {
                        if (tarifasVarias[idx].tipo_frete_remetente != '-1') {
                            if (idtaxa != tarifas.tipo_frete_remetente) {
                                $("tipoFrete_" + idx).value = tarifasVarias[idx].tipo_frete_remetente;
                                alteraTipoTaxaVarios(valida, idx);
                            }
                        }
                    }
                }
                $("tipoTaxaTabela_" + idx).value = tarifasVarias[idx].tipo_taxa;
                //   Regras de negócio     //     --     encontram-se em tabelaFrete.js

                var pesoCubado = 0;
                if ($("tipoTransporte_tipo").value == 'a') {

                    $("baseCubagem_" + idx).value = getBaseCubagem(tarifasVarias[idx].base_cubagem_aereo);
                    pesoCubado = parseFloat($("metro").value) * parseFloat(1000000) / parseFloat($("baseCubagem_" + idx).value);
                } else {
                    $("baseCubagem_" + idx).value = getBaseCubagem(tarifasVarias[idx].base_cubagem);
                    pesoCubado = parseFloat($("baseCubagem_" + idx).value) * parseFloat($("metro").value);
                }

                $("pesoCubagem_" + idx).value = formatoMoeda(pesoCubado);

                var tp = $("tipoTaxaTabela_" + idx).value;
                var utiliza = false;
                var utilizaTabelaRemetente = (($("con_tabela_remetente").value == "s" && ($("utilizaTipoFreteTabelaRem").value == 't' || $("utilizaTipoFreteTabelaRem").value == 'true'))
                || ($("con_tabela_remetente").value == "q" && ($("utilizaTipoFreteTabelaRem").value == 't' || $("utilizaTipoFreteTabelaRem").value == 'true') 
                && tarifasVarias[idx].tipo_frete_remetente != '-1'));

                if (($("utilizaTipoFreteTabelaConsig").value == 't' || $("utilizaTipoFreteTabelaConsig").value == 'true') || utilizaTabelaRemetente) {
                    utiliza = true;
                }
                
                if ($("tipoTaxaTabela_" + idx).value != 'null' && $("tipoTaxaTabela_" + idx).value != undefined && (tp != '-1') && utiliza) {
//                    if (($("tipoFrete_" + idx).value =="0" || $("tipoFrete_" + idx).value == "1")) {
//                        
//                    }
                    if ($("utilizaTipoFreteTabelaConsig").value == 't') {
                        $("tipoFrete_" + idx).value = $("tipoTaxaTabela_" + idx).value;
                        $("tipoFrete_" + idx).disabled = true;
                    }
                    $("tipoFrete_" + idx).disabled = true;
                }else if (tarifasVarias[idx].cliente_id == undefined && (tp!='-1') && utiliza){
                    $("tipoFrete_" + idx).value = $("tipoTaxaTabela_" + idx).value;
                } else {
                    if (alteraTipoFrete) {
                        $("tipoFrete_" + idx).disabled = false;
                    } else {
                        $("tipoFrete_" + idx).disabled = true;
                    }
                }
                
                
                if ($("tipoFrete_" + idx).value == '0') {
                    if (tarifasVarias[idx].is_considerar_maior_peso && parseFloat($("peso").value) < pesoCubado) {
                        $("tipoFrete_" + idx).value = '1';
                        pesoRealVarios[idx] = pesoCubado;
                        alterarTipoFrete('1', idx);
                        alteraTipoTaxaVarios(valida, idx);
                        return null;
                    }
                }
                if ($("tipoFrete_" + idx).value == '1') {
                    if (tarifasVarias[idx].is_considerar_maior_peso && parseFloat($("peso").value) > pesoCubado) {
                        $("tipoFrete_" + idx).value = '0';
                        pesoRealVarios[idx] = $('peso').value;
                        alterarTipoFrete('0', idx);
                        alteraTipoTaxaVarios(valida, idx);
                        return null;
                    }
                }
                if ($("tipoFrete_" + idx).value == '1') {
                    if (tarifasVarias[idx].is_considerar_maior_peso && parseFloat($("peso").value) > pesoCubado) {
                        $("tipoFrete_" + idx).value = '1';
                        pesoRealVarios[idx] = pesoCubado;
                        alterarTipoFrete('1', idx);
                        alteraTipoTaxaVarios(valida, idx);
                        return null;
                    }
                }

                $("vlSecCat_" + idx).value = colocarVirgula(getValorSecCat(tarifasVarias[idx].valor_sec_cat, tarifasVarias[idx].formula_sec_cat,
                        $("tipoFrete_" + idx).value, $('peso').value, $('valorMercadoria').value,
                        $('volumes').value, '0', parseInt(colocarPonto($("distanciaKm_" + idx).value), 10),
                        $("tipoVeiculo_" + idx).value, tarifasVarias[idx].is_considerar_maior_peso,
                        $("baseCubagem_" + idx).value, $("metro").value, parseFloat(colocarPonto($("qtdEntrega_" + idx).value)),
                        $("tipoTransporte_tipo").value, tarifasVarias[idx].peso_limite_sec_cat,
                        tarifasVarias[idx].valor_excedente_sec_cat, tarifasVarias[idx].tipo_inclusao_icms,
                        parseFloat(colocarPonto($("percIcms_" + idx).value)))); //relaciona (sem calculos)

                $("codTab_" + idx).value = getIdTarifas(tarifasVarias[idx].id); // atribui o id da tabelaPreco no label

                $("vlGris_" + idx).value = colocarVirgula(getGris(tarifasVarias[idx].percentual_gris, $("valorMercadoria").value,
                        tarifasVarias[idx].valor_minimo_gris, tarifasVarias[idx].formula_gris, $("tipoFrete_" + idx).value,
                        $('peso').value, $('volumes').value, parseFloat(colocarPonto($("qtdPallet_" + idx).value)),
                        parseInt(colocarPonto($("distanciaKm_" + idx).value), 10), $("tipoVeiculo_" + idx).value, tarifasVarias[idx].is_considerar_maior_peso,
                        $("baseCubagem_" + idx).value, $("metro").value, parseFloat(colocarPonto($("qtdEntrega_" + idx).value)),
                        $("tipoTransporte_tipo").value, tarifasVarias[idx].tipo_inclusao_icms, parseFloat(colocarPonto($("percIcms_" + idx).value)))); //calcula o percentual do gris

                $("vlFreteValor_" + idx).value = colocarVirgula(getFreteValor($("valorMercadoria").value,
                        tarifasVarias[idx].percentual_advalorem,
                        tarifasVarias[idx].percentual_nf,
                        tarifasVarias[idx].base_nf_percentual,
                        tarifasVarias[idx].valor_percentual_nf,
                        $("tipoFrete_" + idx).value,
                        tarifasVarias[idx].tipo_impressao_percentual,
                        tarifasVarias[idx].formula_seguro, tarifasVarias[idx].formula_percentual,
                        $('peso').value,
                        $('volumes').value, parseFloat(colocarPonto($("qtdPallet_" + idx).value)), parseInt(colocarPonto($("distanciaKm_" + idx).value), 10),
                        $("tipoVeiculo_" + idx).value, tarifasVarias[idx].is_considerar_maior_peso, $("baseCubagem_" + idx).value,
                        $("metro").value, false, 0, parseFloat(colocarPonto($("qtdEntrega_" + idx).value)), $("tipoTransporte_tipo").value,
                        tarifasVarias[idx].tipo_inclusao_icms, parseFloat(colocarPonto($("percIcms_" + idx).value)), true)); //calcula o percentual do gris

                $("vlPedagio_" + idx).value = colocarVirgula(getPedagio($("peso").value, tarifasVarias[idx].valor_pedagio,
                        tarifasVarias[idx].qtd_quilo_pedagio, $("tipoFrete_" + idx).value, pesoCubado, tarifasVarias[idx].formula_pedagio,
                        $('valorMercadoria').value, $('volumes').value, $('qtdPallet').value,
                        parseInt(colocarPonto($("distanciaKm_" + idx).value), 10), $("tipoVeiculo_" + idx).value, tarifasVarias[idx].is_considerar_maior_peso,
                        $("baseCubagem_" + idx).value, $('metro').value, parseFloat(colocarPonto($("qtdEntrega_" + idx).value)),
                        $('tipoTransporte_tipo').value, tarifasVarias[idx].tipo_inclusao_icms, parseFloat(colocarPonto($("percIcms_" + idx).value))));

                $("vlOutros_" + idx).value = colocarVirgula(getOutros(tarifasVarias[idx].valor_outros, tarifasVarias[idx].formula_outros,
                        $("tipoFrete_" + idx).value, $('peso').value, $('valorMercadoria').value, $('volumes').value,
                        parseFloat(colocarPonto($("qtdPallet_" + idx).value)), parseInt(colocarPonto($("distanciaKm_" + idx).value), 10),
                        $("tipoVeiculo_" + idx).value, tarifasVarias[idx].is_considerar_maior_peso, $("baseCubagem_" + idx).value, $("metro").value,
                        parseFloat(colocarPonto($("qtdEntrega_" + idx).value)), $("tipoTransporte_tipo").value, tarifasVarias[idx].tipo_inclusao_icms,
                        parseFloat(colocarPonto($("percIcms_" + idx).value))));

                $("vlTaxaFixa_" + idx).value = colocarVirgula(getTaxaFixa(tarifasVarias[idx].valor_taxa_fixa, tarifasVarias[idx].formula_taxa_fixa, $("tipoFrete_" + idx).value,
                        $('peso').value, $('valorMercadoria').value, $('volumes').value, parseFloat(colocarPonto($("qtdPallet_" + idx).value)),
                        parseInt(colocarPonto($("distanciaKm_" + idx).value), 10), $("tipoVeiculo_" + idx).value, tarifasVarias[idx].is_considerar_maior_peso,
                        $("baseCubagem_" + idx).value, $("metro").value, parseFloat(colocarPonto($("qtdEntrega_" + idx).value)),
                        $("tipoTransporte_tipo").value, tarifasVarias[idx].peso_limite_taxa_fixa, tarifasVarias[idx].valor_excedente_taxa_fixa,
                        tarifasVarias[idx].tipo_inclusao_icms, parseFloat(colocarPonto($("percIcms_" + idx).value))));

                calculaTaxaFixaTotalVarios($("vlTaxaFixa_" + idx).value, idx);

                $("vlDespacho_" + idx).value = colocarVirgula(getValorDespacho(tarifasVarias[idx].valor_despacho, tarifasVarias[idx].formula_despacho, $("tipoFrete_" + idx).value,
                        $('peso').value, $('valorMercadoria').value, $('volumes').value, parseFloat(colocarPonto($("qtdPallet_" + idx).value)),
                        parseInt(colocarPonto($("distanciaKm_" + idx).value), 10), $("tipoVeiculo_" + idx).value, tarifasVarias[idx].is_considerar_maior_peso,
                        $("baseCubagem_" + idx).value, $("metro").value, parseFloat(colocarPonto($("qtdEntrega_" + idx).value)),
                        $("tipoTransporte_tipo").value, tarifasVarias[idx].tipo_inclusao_icms, parseFloat(colocarPonto($("percIcms_" + idx).value))));

                var tipoFrete = $("tipoFrete_" + idx).value;
                $("vlFretePeso_" + idx).value = colocarVirgula(getFretePeso($("peso").value,
                        $("volumes").value,
                        $("tipoFrete_" + idx).value,
                        tarifasVarias[idx].valor_peso,
                        tarifasVarias[idx].valor_volume,
                        $("baseCubagem_" + idx).value,
                        $("metro").value,
                        tarifasVarias[idx].valor_veiculo,
                        tarifasVarias[idx].valor_por_faixa,
                        $("tipoTransporte_tipo").value,
                        tarifasVarias[idx].valor_excedente_aereo,
                        tarifasVarias[idx].valor_excedente,
                        tarifasVarias[idx].maximo_peso_final,
                        tarifasVarias[idx].ispreco_tonelada,
                        tarifasVarias[idx].tipo_frete_peso,
                        tarifasVarias[idx].valor_maximo_peso_final,
                        tarifasVarias[idx].valor_km,
                        tarifasVarias[idx].is_considerar_maior_peso,
                        tarifasVarias[idx].tipo_impressao_percentual,
                        $("valorMercadoria").value,
                        tarifasVarias[idx].base_nf_percentual,
                        tarifasVarias[idx].valor_percentual_nf,
                        tarifasVarias[idx].percentual_nf,
                        parseFloat(colocarPonto($("qtdPallet_" + idx).value)),
                        parseInt(colocarPonto($("distanciaKm_" + idx).value), 10),
                        tarifasVarias[idx].formula_volumes, $("tipoVeiculo_" + idx).value,
                        tarifasVarias[idx].formula_percentual,
                        tarifasVarias[idx].valor_pallet,
                        tarifasVarias[idx].formula_pallet, false, 0, parseFloat(colocarPonto($("qtdEntrega_" + idx).value)),
                        tarifasVarias[idx].formula_frete_peso,
                        tarifasVarias[idx].tipo_inclusao_icms,
                        parseFloat(colocarPonto($("percIcms_" + idx).value)), false
                        ));

                if (tipoFrete != $("tipoFrete_" + idx).value) {
                    alteraTipoTaxaVarios(valida, idx);
                    return null;
                }

                if (tarifasVarias[idx].isinclui_icms && tarifasVarias[idx].tipo_inclusao_icms == 't') {
                    $("isAddIcms_" + idx).checked = true;
                } else {
                    $("isAddIcms_" + idx).checked = false;
                }
                $("isAddPisCofins_" + idx).checked = tarifasVarias[idx].is_inclui_impostos_federais;

                //é necessário o total da prestação parcial para comparar com o valor minimo.
                var seguroX = parseFloat(getFreteValor($("valorMercadoria").value,
                        tarifasVarias[idx].percentual_advalorem,
                        tarifasVarias[idx].percentual_nf,
                        tarifasVarias[idx].base_nf_percentual,
                        tarifasVarias[idx].valor_percentual_nf,
                        $("tipoFrete_" + idx).value,
                        'p',
                        tarifasVarias[idx].formula_seguro, tarifasVarias[idx].formula_percentual,
                        $('peso').value,
                        $('volumes').value, '0', parseInt(colocarPonto($("distanciaKm_" + idx).value), 10), $("tipoVeiculo_" + idx).value,
                        tarifasVarias[idx].is_considerar_maior_peso, $("baseCubagem_" + idx).value, $("metro").value,
                        false, 0, parseFloat(colocarPonto($("qtdEntrega_" + idx).value)), $("tipoTransporte_tipo").value,
                        tarifasVarias[idx].tipo_inclusao_icms, parseFloat(colocarPonto($("percIcms_" + idx).value)), true));

                calculaFreteVarios(idx);

                var totalPrestacao = parseFloat(colocarPonto($("vlTotalPrestacao_" + idx).value));

                if (tarifasVarias[idx].is_considerar_valor_maior_peso_nota && ($("tipoFrete_" + idx).value == "0" || $("tipoFrete_" + idx).value == "1" || $("tipoFrete_" + idx).value == "2")) {
                    var mTpFrete = getTipoPreferencialPesoPercentualNotaFiscal($("peso").value,
                        $("volumes").value,
                        $("tipoFrete_" + idx).value,
                        tarifasVarias[idx].valor_peso,
                        tarifasVarias[idx].valor_volume,
                        $("baseCubagem_" + idx).value,
                        $("metro").value,
                        tarifasVarias[idx].valor_veiculo,
                        tarifasVarias[idx].valor_por_faixa,
                        $("tipoTransporte_tipo").value,
                        tarifasVarias[idx].valor_excedente_aereo,
                        tarifasVarias[idx].valor_excedente,
                        tarifasVarias[idx].maximo_peso_final,
                        tarifasVarias[idx].ispreco_tonelada,
                        tarifasVarias[idx].tipo_frete_peso,
                        tarifasVarias[idx].valor_maximo_peso_final,
                        tarifasVarias[idx].valor_km,
                        tarifasVarias[idx].is_considerar_maior_peso,
                        tarifasVarias[idx].tipo_impressao_percentual,
                        $("valorMercadoria").value,
                        tarifasVarias[idx].base_nf_percentual,
                        tarifasVarias[idx].valor_percentual_nf,
                        tarifasVarias[idx].percentual_nf,
                        parseFloat(colocarPonto($("qtdPallet_" + idx).value)),
                        parseInt(colocarPonto($("distanciaKm_" + idx).value), 10),
                        tarifasVarias[idx].formula_volumes, $("tipoVeiculo_" + idx).value,
                        tarifasVarias[idx].formula_percentual,
                        tarifasVarias[idx].valor_pallet,
                        tarifasVarias[idx].formula_pallet, false, 0, parseFloat(colocarPonto($("qtdEntrega_" + idx).value)),
                        tarifasVarias[idx].formula_frete_peso,
                        tarifasVarias[idx].tipo_inclusao_icms,
                        parseFloat(colocarPonto($("percIcms_" + idx).value)), false);

                    if (mTpFrete != $("tipoFrete_" + idx).value) {
                        $("tipoFrete_" + idx).value = mTpFrete;
                        alteraTipoTaxaVarios(valida, idx);
                        return null;
                    }
                }

                totalPrestacao = (tarifasVarias[idx].is_desconsidera_taxa_minimo ? totalPrestacao - parseFloat(colocarPonto($("vlTaxaFixaTot_" + idx).value)) : totalPrestacao);
                totalPrestacao = (tarifasVarias[idx].is_desconsidera_despacho_minimo ? totalPrestacao - parseFloat(colocarPonto($("vlDespacho_" + idx).value)) : totalPrestacao);
                totalPrestacao = (tarifasVarias[idx].is_desconsidera_seccat_minimo ? totalPrestacao - parseFloat(colocarPonto($("vlSecCat_" + idx).value)) : totalPrestacao);
                totalPrestacao = (tarifasVarias[idx].is_desconsidera_outros_minimo ? totalPrestacao - parseFloat(colocarPonto($("vlOutros_" + idx).value)) : totalPrestacao);
                totalPrestacao = (tarifasVarias[idx].is_desconsidera_gris_minimo ? totalPrestacao - parseFloat(colocarVirgula($("vlGris_" + idx).value)) : totalPrestacao);
                totalPrestacao = (tarifasVarias[idx].is_desconsidera_pedagio_minimo ? totalPrestacao - parseFloat(colocarPonto($("vlPedagio_" + idx).value)) : totalPrestacao);
                totalPrestacao = (tarifasVarias[idx].is_desconsidera_seguro_minimo ? totalPrestacao - seguroX : totalPrestacao);
                if (isFreteMinimo(totalPrestacao, tarifasVarias[idx].valor_frete_minimo, tarifasVarias[idx].formula_minimo, $("tipoFrete_" + idx).value,
                        $('peso').value, $('valorMercadoria').value, $('volumes').value, '0', parseInt(colocarPonto($("distanciaKm_" + idx).value), 10),
                        $("tipoVeiculo_" + idx).value, tarifasVarias[idx].is_considerar_maior_peso, $("baseCubagem_" + idx).value,
                        $("metro").value, parseFloat(colocarPonto($("qtdEntrega_" + idx).value)), $("tipoTransporte_tipo").value,
                        tarifasVarias[idx].tipo_inclusao_icms, parseFloat(colocarPonto($("percIcms_" + idx).value)), tarifasVarias[idx].is_desconsidera_icms_minimo))
                {
                    alert("O total do frete é menor que o mínimo, prevalecerá o mínimo.");

                    //ASSUMINDO O VALOR MINIMO
                    //primeira linha
                    if (!tarifasVarias[idx].is_desconsidera_taxa_minimo) {
                        $("vlTaxaFixa_" + idx).value = "0,00";
                        $("vlTaxaFixaTot_" + idx).value = "0,00";
                    }


                    $("vlItr_" + idx).value = "0,00";
                    if (!tarifasVarias[idx].is_desconsidera_despacho_minimo) {
                        $("vlDespacho_" + idx).value = "0,00";
                    }

                    $("vlAdeme_" + idx).value = "0,00";
                    $("vlFretePeso_" + idx).value = "0,00";
                    var vlMinimoOrcamento = getFreteMinimo(tarifasVarias[idx].valor_frete_minimo, tarifasVarias[idx].formula_minimo,
                            $("tipoFrete_" + idx).value, $('peso').value, $('valorMercadoria').value, $('volumes').value, '0',
                            parseInt(colocarPonto($("distanciaKm_" + idx).value), 10), $("tipoVeiculo_" + idx).value, tarifasVarias[idx].is_considerar_maior_peso,
                            $("baseCubagem_" + idx).value, $("metro").value, parseFloat(colocarPonto($("qtdEntrega_" + idx).value)),
                            $("tipoTransporte_tipo").value, tarifasVarias[idx].is_desconsidera_icms_minimo, tarifasVarias[idx].tipo_inclusao_icms,
                            parseFloat(colocarPonto($("percIcms_" + idx).value)));

                    if (!tarifasVarias[idx].is_desconsidera_seguro_minimo) {
                        if (tarifasVarias[idx].tipo_impressao_frete_minimo == 'p') {
                            $("vlFretePeso_" + idx).value = colocarVirgula(parseFloat(vlMinimoOrcamento));
                            $("vlFreteValor_" + idx).value = colocarVirgula((!tarifasVarias[idx].is_desconsidera_seguro_minimo ? 0 : parseFloat(seguroX)));
                        } else {
                            $("vlFreteValor_" + idx).value = colocarVirgula(parseFloat(vlMinimoOrcamento) + (!tarifasVarias[idx].is_desconsidera_seguro_minimo ? 0 : parseFloat(seguroX)));
                        }
                    } else {
                        if (tarifasVarias[idx].tipo_impressao_frete_minimo == 'p') {
                            $("vlFretePeso_" + idx).value = colocarVirgula(parseFloat(vlMinimoOrcamento));
                            $("vlFreteValor_" + idx).value = colocarVirgula(parseFloat((!tarifasVarias[idx].is_desconsidera_seguro_minimo ? 0 : parseFloat(seguroX))));
                        } else {
                            $("vlFreteValor_" + idx).value = colocarVirgula(parseFloat(vlMinimoOrcamento) + (!tarifasVarias[idx].is_desconsidera_seguro_minimo ? 0 : parseFloat(seguroX)));
                        }
                    }

                    //segunda linha
                    if (!tarifasVarias[idx].is_desconsidera_seccat_minimo) {
                        $("vlSecCat_" + idx).value = "0,00";
                    }
                    if (!tarifasVarias[idx].is_desconsidera_outros_minimo) {
                        $("vlOutros_" + idx).value = "0,00";
                    }
                    if (!tarifasVarias[idx].is_desconsidera_gris_minimo) {
                        $("vlGris_" + idx).value = "0,00";
                    }
                    if (!tarifasVarias[idx].is_desconsidera_pedagio_minimo) {
                        $("vlPedagio_" + idx).value = "0,00";
                    }
                    $("vlDesconto_" + idx).value = "0,00";
                    //novos
                    $("baseCubagem_" + idx).value = "0";

                    if (tarifasVarias[idx].is_desconsidera_icms_minimo) { //check no cadastro da tabela 'Desconsiderar inclusão de ICMS em caso de frete'
                        $("isAddIcms_" + idx).checked = false;
                        $("isAddPisCofins_" + idx).checked = false;
                    }
                } //isFreteMinimo
            }


            calculaFreteVarios(idx);
            redespTxOrigemVarios(idx);
            redespTxDestinoVarios(idx);

            pesoRealVarios[idx] = 0;
            return false;
        }//funcao e()

        /*** Bloco de instrucoes ***/
        if (pesoRealVarios[idx] == 0) {
            if ($("tipoFrete_" + idx).value == "1") {
                pesoRealVarios[idx] = parseFloat(colocarPonto($("pesoCubagem_" + idx).value));
            } else {
                pesoRealVarios[idx] = parseFloat(($("peso").value));
            }
        }

        if (alteraTipoFrete){
            $("tipoFrete_" + idx).disabled = false;
        } else{
            $("tipoFrete_" + idx).disabled = true;
        }
        $("tabelaId").value = "";
        var utiliza = false;
        if (($("utilizaTipoFreteTabelaConsig").value == 't' || $("utilizaTipoFreteTabelaConsig").value == 'true')){
            utiliza = true;
        }

        if ($("tipoFrete_" + idx).value != "5" &&
                ($("cid_id_origem").value == "0" || $("idcidadedestino").value == "0") ||
                ($("tipoFrete_" + idx).value == "-1" && !utiliza) || $("rem_rzs").value == "") {
            limparComposicaoFreteVarios(idx);
            return false;
        }
        if ($("tipoFrete_" + idx).value == "5" && $("tipoVeiculo_" + idx).value == "-1") {
            limparComposicaoFreteVarios(idx);
            return false;
        }
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  gleidson parei aqui
//é preciso alterar o tipoVeiculo
        espereEnviar("", true);
        var clienteTabelaId = 0;
        //($('clientepagador').value == 'd' ? $('iddestinatario').value : $('idremetente').value)
        switch ($('clientepagador').value) {
            case "r":
                clienteTabelaId = $('idremetente').value;
                break;
            case "d":
                clienteTabelaId = $('iddestinatario').value;
                break;
            case "c":
                clienteTabelaId = $('idconsignatario').value;
                break;
        }

        if (pesoReal == undefined || pesoRealVarios[idx] == null || pesoRealVarios[idx] == undefined) {
            pesoRealVarios[idx] == 0;
        }
        tryRequestToServer(function () {
            new Ajax.Request("./ConhecimentoControlador?acao=carregar_taxascli"+
                    "&idconsignatario="+clienteTabelaId+
                    "&idcidadeorigem="+$("cid_id_origem").value+
                    "&idcidadedestino="+$("idcidadedestino").value+
                    "&tipoveiculo="+$("tipoVeiculo_" + idx).value+
                    "&tipoproduto="+$("tipoProduto_" + idx).value+
                    "&distancia_km="+parseInt(colocarPonto($("distanciaKm_" + idx).value), 10)+
                    "&dtemissao="+$("dtemissao").value+
                    "&idremetente="+$("idremetente").value+
                    "&con_tabela_remetente="+$("con_tabela_remetente").value+
                    "&peso="+pesoRealVarios[idx]+
                    "&idTaxa="+$("tipoFrete_" + idx).value+
                    "&tipoTransporte="+$("tipoTransporte_tipo").value,//na chamada antiga era informado r como padrao.
                {method: 'post',
                    onSuccess: e});
        });

    } catch (e) {
        alert("Erro ao calcular alteraTipoTaxaVarios" + e);
    }

}

function redespTxDestinoVarios(idx) {
    try {

        distanciaEntrada = $("distanciaKm_" + idx).value;

        if ($("tipoTransporte_tipo").value == "a") {
            function e(transport) {
                var textoresposta = transport.responseText;
                if (textoresposta == "load=0") {
                    return false;
                }
                tbPrecoredespDestinoVarios[idx] = jQuery.parseJSON(textoresposta, function (key, value) {

                    var type;

                    if (value && typeof value === 'object') {
                        type = value.type;
                        if (typeof type === 'string' && typeof window[type] === 'function') {
                            return new (window[type])(value);
                        }
                    }

                    return value;
                });

                $("distanciaKm_" + idx).value = tbPrecoredespDestinoVarios[idx].distanciaEntrega;

                var taxaFixaDestino = 0.00;
                var valorPercentual = 0.00;
                if (tbPrecoredespDestinoVarios[idx].tipotaxa == "2") {
                    var freteNacional = parseFloat(colocarPonto($("vlFretePeso_" + idx).value));
                    valorPercentual = (freteNacional * tbPrecoredespDestinoVarios[idx].vlsobfrete) / 100;
                    taxaFixaDestino = (valorPercentual > tbPrecoredespDestinoVarios[idx].vlfreteminimo) ? valorPercentual : tbPrecoredespDestinoVarios[idx].vlfreteminimo;

                } else if (tbPrecoredespDestinoVarios[idx].tipotaxa == "5") {
                    var distancia = parseFloat(colocarPonto($("distanciaKm_" + idx).value));
                    var valorCobrar = (tbPrecoredespDestinoVarios[idx].vlsobkm * distancia);
                    taxaFixaDestino = (valorCobrar > tbPrecoredespDestinoVarios[idx].vlfreteminimo) ? valorCobrar : tbPrecoredespDestinoVarios[idx].vlfreteminimo;
                } else {
                    var peso = $("peso").value;
                    //valor por km do tipo peso
                    var distancia = parseFloat(colocarPonto($("distanciaKm_" + idx).value));
                    var valorKM = (tbPrecoredespDestinoVarios[idx].vlsobkm * distancia);
                    //calculo
                    var valorCobrar = (((peso - tbPrecoredespDestinoVarios[idx].vlkgate) > 0) ?
                            ((peso - tbPrecoredespDestinoVarios[idx].vlkgate) * tbPrecoredespDestinoVarios[idx].vlsobpeso) + tbPrecoredespDestinoVarios[idx].vlprecofaixa :
                            tbPrecoredespDestinoVarios[idx].vlprecofaixa) + valorKM;

                    taxaFixaDestino = (valorCobrar > tbPrecoredespDestinoVarios[idx].vlfreteminimo) ? valorCobrar : tbPrecoredespDestinoVarios[idx].vlfreteminimo;
                    calculaTaxaFixaTotalVarios($("qtdEntrega_" + idx).value, idx);
                }
                $("vlSecCat_" + idx).value = colocarVirgula(taxaFixaDestino);
//                atribuirDistancia(distanciaEntrada, 'entrega');

                calculaFreteVarios(idx);
            }


            if (parseFloat($("idredespachanteEntrega").value) > 0) {
                tryRequestToServer(function () {
                    new Ajax.Request("./cadorcamento.jsp?acao=carregar_taxasRedespDestino&" +
                            concatFieldValue("idredespachanteEntrega,idcidadedestino,aeroportoEntregaId"), {method: 'post', onSuccess: e});
                });
            }

        } else {
            return false;
        }
    } catch (e) {
        alert("Erro ao calcular redespTxDestinoVarios:" + e);
    }
}

function redespTxOrigemVarios(idx) {

    distanciaColeta = $("distancia_coleta").value;

    if ($("tipoTransporte_tipo").value == "a") {
        function e(transport) {
            var textoresposta = transport.responseText;
            if (textoresposta == "load=0") {
                return false;
            }
            tbPrecoredespOrigemVarios[idx] = jQuery.parseJSON(textoresposta, function (key, value) {

                var type;

                if (value && typeof value === 'object') {
                    type = value.type;
                    if (typeof type === 'string' && typeof window[type] === 'function') {
                        return new (window[type])(value);
                    }
                }

                return value;
            });
            /*tbPrecoredespOrigem.vlfreteminimo
             *tbPrecoredespOrigem.vlkgate -> vl ate ___ kg
             *tbPrecoredespOrigem.vlsobpeso ->excedente sob peso
             *tbPrecoredespOrigem.vlprecofaixa ->cobrar
             **/
            var taxaFixa = 0.00;
            var valorPercentual = 0.00;
            $("distancia_coleta").value = tbPrecoredespOrigemVarios[idx].distanciaColeta;
            if (tbPrecoredespOrigemVarios[idx].tipotaxa == "2") {
                //se a tabela for % Frete...
                var freteNacional = $("valor_peso").value;
                //valor do calculo= (frete nacional x valor do frete na tabela de preco)/100 + valor Fixo da tabela
                valorPercentual = ((freteNacional * tbPrecoredespOrigemVarios[idx].vlsobfrete) / 100 + tbPrecoredespOrigemVarios[idx].vlTaxaFixa);
                taxaFixa = (valorPercentual > tbPrecoredespOrigemVarios[idx].vlfreteminimo) ? valorPercentual : tbPrecoredespOrigemVarios[idx].vlfreteminimo;

            } else if (tbPrecoredespOrigemVarios[idx].tipotaxa == "5") {
                //se a tabela for por KM...
                var distancia = $("distancia_coleta").value;
                //valor do calculo= (valor de KM da tabela x distancia vinda da coleta) + valor fixo da tabela
                var valorCobrar = ((tbPrecoredespOrigemVarios[idx].vlsobkm * distancia) + tbPrecoredespOrigemVarios[idx].vlTaxaFixa);
                taxaFixa = (valorCobrar > tbPrecoredespOrigemVarios[idx].vlfreteminimo) ? valorCobrar : tbPrecoredespOrigemVarios[idx].vlfreteminimo;
            } else {
                //se a tabela for por peso...
                var peso = $("peso").value;

                //km do tipo peso
                var distancia = $("distancia_coleta").value;
                var valorKM = (tbPrecoredespOrigemVarios[idx].vlsobkm * distancia);
                //calculo
                var valorCobrar = (((peso - tbPrecoredespOrigemVarios[idx].vlkgate) > 0) ?
                        ((peso - tbPrecoredespOrigemVarios[idx].vlkgate) * tbPrecoredespOrigemVarios[idx].vlsobpeso) + tbPrecoredespOrigemVarios[idx].vlprecofaixa :
                        tbPrecoredespOrigemVarios[idx].vlprecofaixa) + valorKM + tbPrecoredespOrigemVarios[idx].vlTaxaFixa;

                taxaFixa = (valorCobrar > tbPrecoredespOrigemVarios[idx].vlfreteminimo) ? valorCobrar : tbPrecoredespOrigemVarios[idx].vlfreteminimo;
            }

            $("vlTaxaFixa_" + idx).value = colocarVirgula(taxaFixa);
            $("vlTaxaFixaTot_" + idx).value = colocarVirgula(taxaFixa);
            calculaTaxaFixaTotalVarios($("qtdEntrega_" + idx).value, idx);
        }

        tryRequestToServer(function () {
            new Ajax.Request("./cadorcamento.jsp?acao=carregar_taxasRedespOrigem&" +
                    concatFieldValue("idredespachanteColeta,cid_id_origem,idfilial,aeroportoColetaId"), {method: 'post', onSuccess: e});//
        });


    } else {
        return false;
    }

}

function redespTxDestinoAll() {
    for (var i = 1, max = parseInt($("qtdCompFrete").value, 10); i <= max; i++) {
        if ($("tipoFrete_" + i) != null && $("tipoFrete_" + i) != undefined) {
            redespTxDestinoVarios(i);
        }
    }
}

function redespTxOrigemAll() {
    for (var i = 1, max = parseInt($("qtdCompFrete").value, 10); i <= max; i++) {
        if ($("tipoFrete_" + i) != null && $("tipoFrete_" + i) != undefined) {
            redespTxOrigemVarios(i);
        }
    }
}

function selecionarEleito(idx) {
    try {
        var tipoProduto = "";
        var tipoFrete = "";
        var tipoVeiculo = "";
        if ($("isSelecionado_" + idx) != null && $("isSelecionado_" + idx).checked) {

            tipoFrete = $("tipoFrete_" + idx).value;
            tipoVeiculo = $("tipoVeiculo_" + idx).value;
            tipoProduto = $("tipoProduto_" + idx).value;

            $("tipoproduto").value = tipoProduto;
            $("tipofrete").value = tipoFrete;
            $("tip").value = tipoVeiculo;


            var vlTaxaFixa = colocarPonto($("vlTaxaFixa_" + idx).value);
            var vlTaxaFixaTot = colocarPonto($("vlTaxaFixaTot_" + idx).value);
            var vlItr = colocarPonto($("vlItr_" + idx).value);
            var vlAdeme = colocarPonto($("vlAdeme_" + idx).value);
            var vlFretePeso = colocarPonto($("vlFretePeso_" + idx).value);
            var vlFreteValor = colocarPonto($("vlFreteValor_" + idx).value);
            var vlSecCat = colocarPonto($("vlSecCat_" + idx).value);
            var vlOutros = colocarPonto($("vlOutros_" + idx).value);
            var vlDespacho = colocarPonto($("vlDespacho_" + idx).value);
            var vlDesconto = colocarPonto($("vlDesconto_" + idx).value);
            var vlPedagio = colocarPonto($("vlPedagio_" + idx).value);
            var percDesconto = colocarPonto($("percDesconto_" + idx).value);
            var vlGris = colocarPonto($("vlGris_" + idx).value);
            var qtdEntrega = colocarPonto($("qtdEntrega_" + idx).value);
            var qtdPallet = colocarPonto($("qtdPallet_" + idx).value);
            var distanciaKm = colocarPonto($("distanciaKm_" + idx).value);
            var vlTde = colocarPonto($("vlTde_" + idx).value);
            var isDescontoAdValorem = ($("isDescAdValorem_" + idx).checked);
            var isDescontoNacional = ($("isDescFreteNacional_" + idx).checked);
            var isCobrarTde = ($("isCobrarTde_" + idx).checked);
            var isIncluirIcms = ($("isAddIcms_" + idx).checked);
            var isIncluirFederais = ($("isAddPisCofins_" + idx).checked);

            if ($("codTab_" + idx).value == "" || $("codTab_" + idx).value == "0") {
                $("incluirIcms").checked = isIncluirIcms;
                $("incluirFederais").checked = isIncluirFederais;
                $("isDescAdvalorem").checked = isDescontoNacional;
                $("isDescFreteNacional").checked = isDescontoAdValorem;
                $("incluirTDE").checked = isCobrarTde;

                $("taxaFixa").value = formatoMoeda(vlTaxaFixa);
                $("taxaFixaTotal").value = formatoMoeda(vlTaxaFixaTot);
                $("valor_itr").value = formatoMoeda(vlItr);
                $("valor_ademe").value = formatoMoeda(vlAdeme);
                $("valor_peso").value = formatoMoeda(vlFretePeso);
                $("valor_frete").value = formatoMoeda(vlFreteValor);
                $("valor_sec_cat").value = formatoMoeda(vlSecCat);
                $("valor_outros").value = formatoMoeda(vlOutros);
                $("valor_gris").value = formatoMoeda(vlGris);
                $("valor_despacho").value = formatoMoeda(vlDespacho);
                $("valor_pedagio").value = formatoMoeda(vlPedagio);
                $("valor_tde").value = formatoMoeda(vlTde);
                $("valor_desconto").value = formatoMoeda(vlDesconto);
                $("percentual_desconto").value = formatoMoeda(percDesconto);
                $("qtdEntregas").value = (qtdEntrega);
                $("qtdPallet").value = (qtdPallet);
                $("distancia_km").value = (distanciaKm);


                calculataxaFixaTotal(vlTaxaFixa);
                calculaFrete();
            } else {
                setTipofrete(tipoFrete);
                alteraTipoTaxa('S');
            }
        }
    } catch (e) {
        console.log(e);
        alert(e);
    }
}
function removerComposicaoOrcamento(idx) {
    try {
        var _id = $("idComp_" + idx).value;
        if (confirm("Deseja excluir esta pré composição de frete?")) {
            if (confirm("Tem certeza?")) {
                Element.remove(("trTipos_" + idx));
                Element.remove(("trComp1_" + idx));
                Element.remove(("trComp2_" + idx));
                Element.remove(("trComp3_" + idx));
                Element.remove(("trComp4_" + idx));
                Element.remove(("trComp5_" + idx));
                Element.remove(("trComp6_" + idx));


                new Ajax.Request("cadorcamento.jsp?acao=excluirComposicaoFrete&id=" + _id + "&idOrcamento=" + $("idorcamento").value, {
                    method: 'get',
                    onSuccess: function () {
                        alert('Pré composição de frete removida com sucesso!');
                    },
                    onFailure: function () {
                        alert('Erro ao excluir a pré composição de frete...');
                        return false;
                    }
                });
            }
        }
    } catch (e) {
        alert("Erro ao remover composicao:" + e);
    }
}

function validarPreComposicaoFrete() {
    try {
        for (var i = 1; i <= parseInt($("qtdCompFrete").value, 10); i++) {
            if ($("tipoFrete_" + i) != null && $("tipoFrete_" + i) != undefined) {
                $("tipoFrete_" + i).disabled = false;
                if ($("tipoFrete_" + i).value == "-1") {
                    alert("Informe o tipo do frete do pré-orçamento!");
                    return false;
                }
            }
        }
        return true;
    } catch (e) {
        alert(e);
    }
}

function recarregarTabelas() {
    try {
        for (var i = 1, max = parseInt($("qtdCompFrete").value, 10); i <= max; i++) {
            if ($("tipoFrete_" + i) != null && $("tipoFrete_" + i) != undefined && $("tipoFrete_" + i).value != "-1") {
                alterarTipoFrete($("tipoFrete_" + i).value, i);
                alteraTipoTaxaVarios("S", i);
            }
        }
    } catch (e) {
        console.log(e);
    }
}

function validatTipoTransporteTodos() {
    for (var i = 1, max = parseInt($("qtdCompFrete").value, 10); i <= max; i++) {
        if ($("tipoFrete_" + i) != null && $("tipoFrete_" + i) != undefined) {
            validarTipoTransporteVarios(i);
        }
    }
}

function validarTipoTransporteVarios(index) {
    var rowSpanGenerico = 7;
    if ($("trComp6_" + index) != null) {
        if ($("tipoTransporte_tipo").value == "a") {
            rowSpanGenerico = 7;
            visivel($("trComp6_" + index));
            $("labFreteValor_" + index).innerHTML = "AdValorEm:";
            $("labFretePeso_" + index).innerHTML = "Frete Naciona:";
            $("labTaxaFixa_" + index).innerHTML = "Taxa Origem:";
            $("labSecCat_" + index).innerHTML = "Taxa Destino:";
        } else {
            rowSpanGenerico = 6;
            invisivel($("trComp6_" + index));
            $("labFreteValor_" + index).innerHTML = "Frete Valor:";
            $("labFretePeso_" + index).innerHTML = "Frete Peso:";
            $("labSecCat_" + index).innerHTML = "SEC/CAT:";
            $("labTaxaFixa_" + index).innerHTML = "Taxa Fixa:";
        }
        $("tdLixo_" + index).rowSpan = rowSpanGenerico;
        $("tdSelecionado_" + index).rowSpan = rowSpanGenerico;
        $("tdImpressao_" + index).rowSpan = rowSpanGenerico;
    }
}

function atribuirDespesaSimulacao(coletaEntrega, valor) {
    for (var i = 1, max = parseInt($("qtdCompFrete").value, 10); i <= max; i++) {
        if ($("tipoFrete_" + i) != null && $("tipoFrete_" + i) != undefined) {
            if (coletaEntrega == "coleta") {
                $("vlDespesaColeta_" + i).value = valor;
            } else {
                $("vlDespesaEntrega_" + i).value = valor;
            }
        }
    }
}

function calcResumoFinanceiro(idx) {
    $("vlResumoFinanceiro_" + idx).value = colocarVirgula(
            parseFloat(colocarPonto($("vlTotalPrestacao_" + idx).value))
            - parseFloat(colocarPonto($("vlDespesaColeta_" + idx).value))
            - parseFloat(colocarPonto($("vlDespesaEntrega_" + idx).value))
            - ($("peso").value * parseFloat(colocarPonto($("vlPeso_" + idx).value)))
            - parseFloat(colocarPonto($("vlIcms_" + idx).value))
            , 2);
}

function imprimirSimulacao(idx) {
    try {
        var id = $("idComp_" + idx).value;

        launchPDF('./consulta_orcamento.jsp?acao=exportarSimulacao&modelo=' + "1" + '&simulacaoId=' + id, 'OrcamentoSimulacao' + $("idorcamento").value);
    } catch (e) {

    }

}

function travarTipoFrete(idx){
    var tp = $("tipoTaxaTabela_" + idx).value;
    var utiliza = false;
    var utilizaTabelaRemetente = (($("con_tabela_remetente").value == "s" && $("utilizaTipoFreteTabelaRem").value == 't')
            || ($("con_tabela_remetente").value == "q" && $("utilizaTipoFreteTabelaRem").value == 't'));

    if (($("utilizaTipoFreteTabelaConsig").value == 't' || $("utilizaTipoFreteTabelaConsig").value == 'true') || utilizaTabelaRemetente) {
        utiliza = true;
    }

    if ($("tipoTaxaTabela_" + idx).value != 'null' && $("tipoTaxaTabela_" + idx).value != undefined && (tp != '-1') && utiliza) {
        if (($("tipoFrete_" + idx).value == '0' || $("tipoFrete_" + idx).value == '1') && ($("tipoTaxaTabela_" + idx).value == '1' || $("tipoTaxaTabela_" + idx).value == '0')) {
            
        } else {
            if ($("clientepagador").value == 'r') {
                if ($("utilizaTipoFreteTabelaRem").value == 't') {
                    $("tipoFrete_" + idx).value = $("tipoTaxaTabela_" + idx).value;
                    $("tipoFrete_" + idx).disabled = true;
                }
            } else if ($("clientepagador").value == 'd') {
                if ($("utilizaTipoFreteTabelaDest").value == 't') {
                    $("tipoFrete_" + idx).value = $("tipoTaxaTabela_" + idx).value;
                    $("tipoFrete_" + idx).disabled = true;
                }
            } else if ($("clientepagador").value == 'c') {
                if ($("utilizaTipoFreteTabelaConsig").value == 't') {
                    $("tipoFrete_" + idx).value = $("tipoTaxaTabela_" + idx).value;
                    $("tipoFrete_" + idx).disabled = true;
                }
            }
        }
        $("tipoFrete_" + idx).disabled = true;
    } else {
        if (alteraTipoFrete) {
            $("tipoFrete_" + idx).disabled = false;
        } else {
            $("tipoFrete_" + idx).disabled = true;
        }
    }
}