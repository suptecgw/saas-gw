/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
//@@@@@@@@@@@@@@@@@@@  VARIAVEIS GLOBAIS  
var countConhecimento = 0;
var countConhecimentoNota = 0;
var countConhecimentoNotaCubagem = 0;
var countTotNota = 0;
var arrayAbas = new Array();
var aba;
var callVerCliente = "verCliente(this);";
var callMascaraReais = "mascara(this, reais);";
var callsetZero = "setZero(this,false);";
var callMascaraSoNumeros = "mascara(this, soNumeros);";
var callVerificarNota = "verificarNota(this);";
var callAlertInvalidDate = "alertInvalidDate(this);";
var callFmtData = "fmtDate(this, event)";
var callRecalcular = "recalcular(index);";
var callFormatarHora = "mascaraHora(this)";
var callFormatarData = "formatar(this, '##/##/####')";
var estiloMin = "fieldMin";
var estiloMin2 = "fieldMin2";
var estiloData = "fieldDateMin";
var estiloTabela = "tabela";
var estiloMinReadOnly = "inputReadOnly8pt";
var estiloTextRight = "text-align:right;";
var estiloTextCenter = "text-align:center;";
var callCalcularIcmsAll = "calcularIcms(@@index);";
var sizeDecimal = "7";
var sizeDefault = "6";
var maxLengtPerc = "6";
var maxLengtDefault = "10";
var styleAux = " style1 ";
var styleErro = " style3 ";
var styleMsgCli = " style4 ";
var styleFontSizeDefault = "xx";
var pesoReal = new Array();
var buscouTaxas = "-1";
var tarifas = new Array();
var alteraTipoFrete = false;
/*   MANUAL DE INSTRUÇÕES BASICAS PARA MECHER NESTE JS
 *   
 *  1 - Se você não souber o que é um DOM, NÃO MECHA NESSE AQUIVO!
 *  2 - Repare que cada função monta partes especificas de um conhecimento.
 *  3 - As variaveis globais estão acima. Como o nome já diz, são usadas em varias partes do codigo, 
 *      então muito  cuidado ao modificar alguma delas. Os style's por exemplo foram criado no jsp 
 *      que utiliza este js e apenas referenciado aqui.
 *  4 - Os metodos de localizar utilizam um elemento hidden que está criado no jsp que utiliza este js.
 *  5 - Algumas variaveis utilizadas neste arquivo não foram criadas nele e sim no jsp que o utiliza.
 *  6 - Por conta de algumas "sutilezas" do IE cuidado quando for mecher em qualquer coisa neste arquivo, 
 *      principalmente nas abas.
 *  7 - Tenha acima de tudo atenção!!!!!!
 */


//@@@@@@@@@@@@@@@@@@@  CONTROLANDO AS ABAS  
/**
 * 
 * @param {type} elementoId
 * @returns {undefined}
 */
function AlternarAbas(elementoId) {
    var elemento = $(elementoId);
    var descricao = elemento.id.split("_")[0];
    var index = elemento.id.split("_")[1];
    var arAbas = arrayAbas[index - 1];


    for (i = 0; i < arAbas.length; i++) {
        m = $(arAbas[i].menu);
        m.className = 'menu';
        c = $(arAbas[i].conteudo)
        //invisivel(c);
        invisivel($(c.id.replace("div", "tr")));
    }

    var conteudo = descricao.replace("tdAba", "div") + "_" + index;
    elemento.className = 'menu-sel';
    c = $(conteudo);
    visivel(c);
    visivel($(conteudo.replace("div", "tr")));

}
function stAba(menu, conteudo) {
    this.menu = menu;
    this.conteudo = conteudo;
}
//@@@@@@@@@@@@@@@@@@@  FUNÇÕES DE LOCALIZAR  
function abrirLocalizarRemetente(index) {
    var camposAdicionais = "";
    var filial = $("filial").value.split("@@")[0];
    if ($("indexAux") != null) {
        $("indexAux").value = index;
        camposAdicionais = "&paramaux=" + $("filial").value.split("@@")[0] + "&paramaux2=" + $("ufDestinoLocais_" + index).value + "&paramaux3=" + $("cidadeDestinoIdLocais_" + index).value + '&paramaux4=' + filial;
    }
    popLocate(3, "Remetente", "", camposAdicionais);
}
var listOptTipoProd = Array();
function localizarTipoProduto(id, index) {
    localizarTipoProdutoGenerico(id, $("tipoProdutoTabela_" + index));
}

function localizarTipoProdutoGenerico(id, elemento) {
    function e(transport) {
        try {
            var textoResposta = transport.responseText;

            if (textoResposta == "-1") {
                alert('ERRO: Houve algum problema.');
                return false;
            } else {
                var list = null;
                var listaTipoProd = null;
                listOptTipoProd = Array();
                var tipoProd = null;

                list = jQuery.parseJSON(textoResposta);

                if (list != null && list != undefined && list.list[0] != null && list.list[0] != undefined) {

                    listaTipoProd = list.list[0].tipoProduto;

                    if (listaTipoProd != undefined) {
                        // pega o tamanho do array retornado.

                        var length = (listaTipoProd != undefined && listaTipoProd.length != undefined ? listaTipoProd.length : 1);

                        //o primeiro item da lista sera NENHUM.
                        listOptTipoProd[0] = new Option(0, "NENHUM");

                        //varre a lista a partir do 0(zero)(primeiro item).
                        for (var i = 0; i < length; i++) {
                            if (length == 1) {
                                tipoProd = listaTipoProd;
                            } else {
                                tipoProd = listaTipoProd[i];
                            }
                            //vai setar na proxima posicao, pois, se setar o atual ele desconsiderara o 0(ZERO) da lista.
                            listOptTipoProd[i + 1] = new Option(tipoProd.id, tipoProd.descricao);
                            if (elemento != null && elemento != undefined) {
                                removeOptionSelected(elemento.id);
                                povoarSelect(elemento, listOptTipoProd);
                            }
                        }
                    }
                }
            }
        } catch (e) {
            alert(e);
            if (!isIE()) {
                console.log(e);
                console.trace();
            }
        }
    }
    tryRequestToServer(function () {
        new Ajax.Request("ConhecimentoControlador?acao=localizarTipoProdutoAJAX&id=" + id + "&isGrupoCliProd=true", {
            method: 'post',
            onSuccess: e
            ,
            onError: e
        });
    });
}


function abrirLocalizarDestinatario(index) {
    var camposAdicionais = "";
    var filial = $("filial").value.split("@@")[0];
    if ($("indexAux") != null) {
        $("indexAux").value = index;
        camposAdicionais = "&paramaux=" + $("filial").value.split("@@")[0] + "&paramaux2=" + $("ufOrigemLocais_" + index).value + "&paramaux3=" + $("cidadeOrigemIdLocais_" + index).value + '&paramaux4=' + filial;
    }
    popLocate(4, "Destinatario", "", camposAdicionais);
}

function abrirLocalizarDestinatarioNota(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(4, "Destinatario_Nota", "");
}

function abrirLocalizarRepresentante(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(23, "Representante", "");
}
function abrirLocalizarMotorista(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(10, "MotoristaOutros", "");
}
function abrirLocalizarVeiculo(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(7, "VeiculoOutros", "");
}
function abrirLocalizarCarreta(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(9, "CarretaOutros", "");
}
function abrirLocalizarBitrem(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(51, "BitremOutros", "");
}
function abrirLocalizarConsignatario(index) {
    var filial = $("filial").value.split("@@")[0];

    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(5, "Consignatario", "", "&paramaux4=" + filial);
}
function abrirLocalizarRedespacho(index) {
    var filial = $("filial").value.split("@@")[0];
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(6, "Redespacho", "", "&paramaux4=" + filial + '&paramaux5=' + $("cidadeOrigemIdLocais_" + index).value);
}
function abrirLocalizarCidadeOrigem(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    var campoadc = "&paramaux=" + $("cidadeDestinoIdLocais_" + index).value;
    popLocate(11, "Cidade_Origem", "", campoadc);
}
function abrirLocalizarCidadeDestino(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    var campoadc = "&paramaux=" + $("cidadeOrigemIdLocais_" + index).value;
    popLocate(12, "Cidade_Destino", "", campoadc);
}
function abrirLocalizarVendedor(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(27, "Vendedor", "");
}
function abrirLocalizarObservacao(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(28, "Observacao", "");
}
function abrirLocalizarCFOP(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(2, "CFOP", "");
}
function abrirLocalizarCFOPNota(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(2, "CFOP_Nota", "");
}
function abrirLocalizarRecebedor(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(79, "Recebedor", "", "");
}
function abrirLocalizarExpedidor(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(78, "Expedidor", "", "");
}

function limparCampoRecebedor(index) {
    $("idRecebedor_" + index).value = "0";
    $("recebedor_" + index).value = "";
    $("recebedorCidade_" + index).value = "";
    $("recebedorCidadeId_" + index).value = "0";
    $("recebedorUF_" + index).value = "";
    $("recebedorCNPJ_" + index).value = "";
}

function limparCampoExpedidor(index) {
    $("idExpedidor_" + index).value = "0";
    $("expedidor_" + index).value = "";
    $("expedidorCidade_" + index).value = "";
    $("expedidorCidadeId_" + index).value = "0";
    $("expedidorUF_" + index).value = "";
    $("expedidorCNPJ_" + index).value = "";
}

function limparCampo(objDesc, objId) {
    objDesc.value = "";
    objId.value = "0";
}

//@@@@@@@@@@@@@@@@@@@  FUNÇÕES DO DOM  
/**
 * 
 * @param {Object JS} ctrc
 * @param {HTML Object} tabelaContainer
 * @param {HTML Object} obMaxCtrc
 * @param {HTML Object} objSerie
 * @param {boolean} temPermissao_alteraprecocte
 * @param {boolean} temPermissao_alterainffiscal
 * @param {boolean} temPermissao_alteratipofretecte
 * @param {boolean} embutirICMS
 * @param {boolean} embutirPISCOFINS
 * @returns {void}
 */
function addConhecimentoLote(ctrc, tabelaContainer, obMaxCtrc, objSerie, temPermissao_alteraprecocte, temPermissao_alterainffiscal, temPermissao_alteratipofretecte, embutirICMS, embutirPISCOFINS, tipoProdutoPadrao, tipoVeiculoPadrao, observacaoPadrao) {
    desabilitar($("filial"));
    desabilitar($("tipoTransporte"));

    if (ctrc == null || ctrc == undefined) {
        ctrc = new CTRC();
    }

    //validando pois se no ctrc já houver um tipoProduto, ele não será sobrescrito
    if (ctrc.tipoProduto == "0") {
        ctrc.tipoProduto = tipoProdutoPadrao;
    }

    //validando pois se no ctrc já houver um tipoVeiculo, ele não será sobrescrito
    if (ctrc.tipoVeiculo == "0") {
        ctrc.tipoVeiculo = tipoVeiculoPadrao;
    }

    //validando pois se no ctrc já houver uma observação, ela não será sobrescrita
    if (ctrc.observacao == "") {
        ctrc.observacao = observacaoPadrao;
    }
    ctrc.isIcms = embutirICMS;
    ctrc.isPisCofins = embutirPISCOFINS;
    var colSpanAba = 15;
    var index = parseInt(obMaxCtrc.value, 10) + 1;
    countConhecimentoNota = index;

    var classe = ((index % 2) != 0 ? 'CelulaZebra2NoAlign' : 'CelulaZebra1NoAlign');
    //chamadas de função
    var callAlternarAbas = "AlternarAbas(this.id);";
    ctrc.index = index;
    ctrc.className = classe;
    var callRemoverCtrc = "removerCtrc(" + index + ");";

    var tbodyContainer = Builder.node("tbody", {
        id: "tbodyContainer_" + index,
        name: "tbodyContainer_" + index
    });
    tabelaContainer.appendChild(tbodyContainer)


    var _trAba = Builder.node("tr", {
        id: "trAba_" + index
    });
    var _tdAbaCliente = Builder.node("td", {
        id: "tdAbaCliente_" + index,
        className: "menu",
        onClick: callAlternarAbas
    });
    var _tdAbaNotaFiscal = Builder.node("td", {
        id: "tdAbaNotaFiscal_" + index,
        className: "menu",
        onClick: callAlternarAbas
    });
    var _tdAbaComposicaoFrete = Builder.node("td", {
        id: "tdAbaComposicaoFrete_" + index,
        className: "menu",
        onClick: callAlternarAbas
    });
    var _tdAbaOutros = Builder.node("td", {
        id: "tdAbaOutros_" + index,
        className: "menu",
        onClick: callAlternarAbas
    });
    var _labelClientes = Builder.node("label", {
        onClick: "AlternarAbas('" + _tdAbaCliente.id + "')"
    }, 'Clientes');
    var _labelNotasFiscais = Builder.node("label", {
        onClick: "AlternarAbas('" + _tdAbaNotaFiscal.id + "')"
    }, 'Notas Fiscais');
    var _labelConmposicaoFrete = Builder.node("label", {
        onClick: "AlternarAbas('" + _tdAbaComposicaoFrete.id + "')"
    }, 'Composição Frete');
    var _labelOutros = Builder.node("label", {
        onClick: "AlternarAbas('" + _tdAbaOutros.id + "')"
    }, 'Outros');

    _tdAbaCliente.appendChild(_labelClientes);
    _tdAbaNotaFiscal.appendChild(_labelNotasFiscais);
    _tdAbaComposicaoFrete.appendChild(_labelConmposicaoFrete);
    _tdAbaOutros.appendChild(_labelOutros);

    _trAba.appendChild(_tdAbaCliente);

    _trAba.appendChild(_tdAbaNotaFiscal);
    _trAba.appendChild(_tdAbaComposicaoFrete);
    _trAba.appendChild(_tdAbaOutros);

    var _trAba1 = Builder.node("tr", {
        id: "trAba1_" + index,
        className: classe
    });
    var _tdCheck = Builder.node("td", {
        id: "tdCheck_" + index,
        align: "center",
        className: classe,
        width: "3%",
        colSpan: 1
    });
    var _tdAba1 = Builder.node("td", {
        id: "tdAba1_" + index,
        align: "left",
        className: classe,
        width: "48%",
        colSpan: 9
    });

    var _labelSequencia = Builder.node("label", {
        id: "sequenciaCtrc_" + index
    }, fillZero(index, 3));

    var _indexHidden = Builder.node("input", {
        id: "indexCtrc_" + index,
        type: "hidden",
        name: "indexCtrc_" + index,
        value: fillZero(index, 3)
    });
    var _tipoCteImpLoteHidden = Builder.node("input", {
        id: "tpConhecimentoLote_" + index,
        type: "hidden",
        name: "tpConhecimentoLote__" + index,
        value: ctrc.tipoCteImpLote
    });
    var _chkSave = Builder.node("input", {
        id: "chkSave_" + index,
        type: "checkbox",
        name: "chkSave_" + index
    });
    _chkSave.checked = true;
    _tdCheck.appendChild(_chkSave);

    var _labelMensagemErro = Builder.node("label", {
        id: "mensagemErro_" + index
    });
    var _labelErroAtual = Builder.node("label", {
        id: "erroAtual_" + index,
        onClick: "exibirErroCtrc(" + index + ")"
    });
    var _labelAlertaErro = Builder.node("label", {
        id: "alertaErro_" + index,
        className: "linkEditar",
        onClick: "exibirErroCtrc(" + index + ")"
    });
    _labelAlertaErro.innerHTML = "<br/><b>Clique aqui para ver detalhado.<b/>";
    invisivel(_labelAlertaErro);
    invisivel(_labelMensagemErro);

    var _br = Builder.node("br", {});
    var _labelMensagemCli = Builder.node("label", {
        id: "mensagemCliente_" + index
    });
    var _labelAvisoMsg = Builder.node("label", {
        id: "avisoMsg_" + index,
        onClick: "alert(getMsgCliente(" + index + "));"
    });
    var _labelAlertaMsgCli = Builder.node("label", {
        id: "alertaMsgCli_" + index,
        className: "linkEditar",
        onClick: "alert(getMsgCliente(" + index + "));"
    });
    _labelAlertaMsgCli.innerHTML = "<br/><b>Clique aqui para ver detalhado.<b/>";
    invisivel(_labelAlertaErro);
    invisivel(_labelMensagemCli);
    var _imgRemoverCtrc = Builder.node("img", {
        src: "img/lixo.png",
        className: "imagemLinkSpc",
        border: "0",
        onClick: callRemoverCtrc
    });

    var _tdAba2 = Builder.node("td", {
        id: "tdAba2_" + index,
        width: "40%",
        colSpan: "3",
        className: classe
    });
    _tdAba2.appendChild(_labelAvisoMsg);
    _tdAba2.appendChild(_labelAlertaMsgCli);
    _tdAba2.appendChild(_br);
    _tdAba2.appendChild(_labelMensagemCli);
    _tdAba2.appendChild(_labelErroAtual);
    _tdAba2.appendChild(_labelAlertaErro);
    _tdAba2.appendChild(_labelMensagemErro);
    var _tdAba3 = Builder.node("td", {
        id: "tdAba3_" + index,
        width: "5%",
        className: classe
    });
    _tdAba3.appendChild(_indexHidden);
    _tdAba3.appendChild(_tipoCteImpLoteHidden);
    _tdAba3.appendChild(_labelSequencia);
    var _tdAba4 = Builder.node("td", {
        id: "tdAba4_" + index,
        width: "2%",
        className: classe
    });

    _tdAba4.appendChild(_imgRemoverCtrc);
    var _table = Builder.node("table", {
        id: "table1_" + index,
        width: "100%",
        border: 0
    });
    var _tbody = Builder.node("tbody", {
        id: "tBodyAba_" + index,
        width: "100%"
    });
    // elementos da aba cliente
    var _trCliente = Builder.node("tr", {
        id: "trCliente_" + index
    });
    var _tdCliente = Builder.node("td", {
        id: "tdCliente_" + index,
        width: "100%",
        colSpan: colSpanAba
    });
    var _tableCliente = Builder.node("table", {
        id: "tableCliente_" + index,
        width: "100%",
        className: "bordaFina"
    });
    var _tBodyCliente = Builder.node("tbody", {
        id: "tBodyCliente_" + index,
        width: "100%"
    });
    var _divCliente = Builder.node("div", {
        id: "divCliente_" + index
    });

    _tableCliente.appendChild(_tBodyCliente);
    _divCliente.appendChild(_tableCliente);
    _tdCliente.appendChild(_divCliente);
    _trCliente.appendChild(_tdCliente);

    //elementos da aba nota fiscal
    var _trNotaFiscal = Builder.node("tr", {
        id: "trNotaFiscal_" + index
    });
    var _tdNotaFiscal = Builder.node("td", {
        id: "tdNotaFiscal_" + index,
        width: "100%",
        colSpan: colSpanAba
    });
    var _divNotaFiscal = Builder.node("div", {
        id: "divNotaFiscal_" + index
    });
    var _tableNotaFiscal = Builder.node("table", {
        id: "tableNotaFiscal_" + index,
        width: "100%",
        className: "bordaFina"
    });
    var _tBodyNotaFiscal = Builder.node("tbody", {
        id: "tBodyNotaFiscal_" + index,
        width: "100%"
    });
    var _tableNotaFiscalTotais = Builder.node("table", {
        id: "tableNotaFiscalTotais_" + index,
        width: "100%",
        className: "bordaFina"
    });
    var _tBodyNotaFiscalTotais = Builder.node("tbody", {
        id: "tBodyNotaFiscalTotais_" + index,
        width: "100%"
    });

    _tableNotaFiscal.appendChild(_tBodyNotaFiscal);
    _tableNotaFiscalTotais.appendChild(_tBodyNotaFiscalTotais);
    _divNotaFiscal.appendChild(_tableNotaFiscal);
    _divNotaFiscal.appendChild(_tableNotaFiscalTotais);
    _tdNotaFiscal.appendChild(_divNotaFiscal);
    _trNotaFiscal.appendChild(_tdNotaFiscal);


    //elementos da aba composição do frete
    var _trComposicaoFrete = Builder.node("tr", {
        id: "trComposicaoFrete_" + index
    });
    var _tdComposicaoFrete = Builder.node("td", {
        id: "tdComposicaoFrete_" + index,
        width: "100%",
        colSpan: colSpanAba
    });
    var _divComposicaoFrete = Builder.node("div", {
        id: "divComposicaoFrete_" + index
    });
    var _tableComposicaoFrete = Builder.node("table", {
        id: "tableComposicaoFrete_" + index,
        width: "100%",
        className: "bordaFina"
    });
    var _tBodyComposicaoFrete = Builder.node("tbody", {
        id: "tBodyComposicaoFrete_" + index,
        width: "100%"
    });
    var _tableComposicaoFreteTotaisNF = Builder.node("table", {
        id: "tableComposicaoFreteTotaisNF_" + index,
        width: "100%",
        className: "bordaFina"
    });
    var _tBodyComposicaoFreteTotaisNF = Builder.node("tbody", {
        id: "tBodyComposicaoFreteTotaisNF_" + index,
        width: "100%"
    });
    var _tableComposicaoFreteTabelaPrecoLocais = Builder.node("table", {
        id: "tableComposicaoFretePrecoLocais_" + index,
        width: "100%",
        className: "bordaFina"
    });
    var _tBodyComposicaoFreteTabelaPrecoLocais = Builder.node("tbody", {
        id: "tBodyComposicaoFretePrecoLocais_" + index,
        width: "100%"
    });
    var _tableComposicaoFreteTabelaPreco = Builder.node("table", {
        id: "tableComposicaoFreteTabelaPreco_" + index,
        width: "100%",
        className: "bordaFina"
    });
    var _tBodyComposicaoFreteTabelaPreco = Builder.node("tbody", {
        id: "tBodyComposicaoFreteTabelaPreco_" + index,
        width: "100%"
    });

    _tableComposicaoFreteTabelaPrecoLocais.appendChild(_tBodyComposicaoFreteTabelaPrecoLocais);
    _tableComposicaoFreteTabelaPreco.appendChild(_tBodyComposicaoFreteTabelaPreco);

    _tableComposicaoFreteTotaisNF.appendChild(_tBodyComposicaoFreteTotaisNF);
    _tableComposicaoFrete.appendChild(_tBodyComposicaoFrete);
    _divComposicaoFrete.appendChild(_tableComposicaoFreteTotaisNF);
    _divComposicaoFrete.appendChild(_tableComposicaoFreteTabelaPrecoLocais);
    _divComposicaoFrete.appendChild(_tableComposicaoFreteTabelaPreco);
    _divComposicaoFrete.appendChild(_tableComposicaoFrete);
    _tdComposicaoFrete.appendChild(_divComposicaoFrete);
    _trComposicaoFrete.appendChild(_tdComposicaoFrete);


    //elementos da aba outros
    var _trOutros = Builder.node("tr", {
        id: "trOutros_" + index
    });
    var _tdOutros = Builder.node("td", {
        id: "tdOutros_" + index,
        width: "100%",
        colSpan: colSpanAba
    });
    var _divOutros = Builder.node("div", {
        id: "divOutros_" + index
    });
    var _tableOutros = Builder.node("table", {
        id: "tableOutros_" + index,
        width: "100%",
        className: "bordaFina"
    });
    var _tBodyOutros = Builder.node("tbody", {
        id: "tBodyOutros_" + index,
        width: "100%"
    });

    _tableOutros.appendChild(_tBodyOutros);
    _divOutros.appendChild(_tableOutros);
    _tdOutros.appendChild(_divOutros);
    _trOutros.appendChild(_tdOutros);

    tbodyContainer.appendChild(_trAba1);
    tbodyContainer.appendChild(_trCliente);
    tbodyContainer.appendChild(_trNotaFiscal);
    tbodyContainer.appendChild(_trComposicaoFrete);
    tbodyContainer.appendChild(_trOutros);

    //@@@@@@@@@@@@@@   abas   @@@@@@@@@@@@@@@@@@@@@@@@  INICIO
    aba = new Array();
    aba[0] = new stAba(_tdAbaCliente.id, _divCliente.id);
    aba[1] = new stAba(_tdAbaNotaFiscal.id, _divNotaFiscal.id);
    aba[2] = new stAba(_tdAbaComposicaoFrete.id, _divComposicaoFrete.id);
    aba[3] = new stAba(_tdAbaOutros.id, _divOutros.id);

    arrayAbas[index - 1] = aba;



    _tbody.appendChild(_trAba);
    _table.appendChild(_tbody);
    _tdAba1.appendChild(_table);
    _trAba1.appendChild(_tdCheck);
    _trAba1.appendChild(_tdAba1);
    _trAba1.appendChild(_tdAba2);
    _trAba1.appendChild(_tdAba3);
    _trAba1.appendChild(_tdAba4);


    AlternarAbas(_tdAbaCliente.id);
    //@@@@@@@@@@@@@@   abas   @@@@@@@@@@@@@@@@@@@@@@@@  FIM

    obMaxCtrc.value = index;
    addConhecimentoLoteCliente(ctrc, index, _tBodyCliente, classe);
    addConhecimentoLoteNotasFiscais(ctrc, index, _tBodyNotaFiscal, classe, objSerie);
    addConhecimentoLoteNotasFiscaisTrTotais(index, _tBodyNotaFiscalTotais, classe, 0, ctrc);
    addConhecimentoLoteNotasFiscaisTrTotais(index, _tBodyComposicaoFreteTotaisNF, classe, 1, ctrc);
    addConhecimentoLoteTrLocais(ctrc, index, _tBodyComposicaoFreteTabelaPrecoLocais, classe);
//    temPermissao_alterainffiscal - azul - 3 campos.
//    temPermissao_alteraprecocte  - vermelho - muitos campos.
//    temPermissao_alteratipofretecte - verde - 3 selects = tipoProduto, tipoFrete e tipo Veiculo.
    alteraTipoFrete = temPermissao_alteratipofretecte;
    addConhecimentoLoteTrTabela(ctrc, index, _tBodyComposicaoFreteTabelaPreco, classe, temPermissao_alteratipofretecte);//funcao OK

    addConhecimentoComposicaoFrete(ctrc, index, _tBodyComposicaoFrete, classe, temPermissao_alteraprecocte);//funcao OK
    addConhecimentoLoteTotais(ctrc, index, tbodyContainer, classe, temPermissao_alterainffiscal);
    addConhecimentoLoteTrOutros(ctrc, index, _tBodyOutros, classe);

}
//cliente
function addConhecimentoLoteCliente(ctrc, index, tabela, classe) {
    addConhecimentoLoteClienteTR(ctrc.remetente, index, tabela, classe, true);
    addConhecimentoLoteClienteTR(ctrc.destinatario, index, tabela, classe, false);
    addConhecimentoLoteClienteTRResponsePagamento(ctrc, index, tabela, classe, false);
    addConhecimentoLoteClienteTR(ctrc.redespacho, index, tabela, classe, false);
    addConhecimentoLoteClienteTR(ctrc.consignatario, index, tabela, classe, false);
    addConhecimentoLoteClienteTR(ctrc.recebedor, index, tabela, classe, false);
    addConhecimentoLoteClienteTR(ctrc.expedidor, index, tabela, classe, false);

    // Readonly no localizar destinatário
    if (ctrc.consignatario.travaCamposImportacao === 'true') {
        $('botLocDestinatario_' + index).disabled = true;
    }
}
function addConhecimentoLoteClienteTR(cliente, index, tabela, classe, isRemetente) {
    if (cliente == null || cliente == undefined) {
        cliente = new Cliente();
    }
    var verTr = cliente.descricao != "Redespacho" ? true : false;
    var escolherCli = cliente.descricao != "Consignatario" ? true : false;
    //chamadas de função
    var callLocalizar = "abrirLocalizar" + cliente.descricao + "(" + index + ");";
    var callBorrachaLocalizar = "limparCampo" + cliente.descricao + "(" + index + ");";

    var _borrachaLocaliza = Builder.node("img", {
        id: "borrachaLocaliza" + cliente.descricao + "_" + index,
        name: "borrachaLocaliza" + cliente.descricao + "_" + index,
        className: "imagemLink",
        src: "img/borracha.gif",
        onclick: callBorrachaLocalizar
    });

    var tamanhoPadrao = 40;
    var classMin = "fieldMin";

    //remetente
    var _trCliente = Builder.node("tr", {
        id: "tr" + cliente.descricao + "_" + index,
        className: classe
    });
    var _tdDescricao1 = Builder.node("td", {
        id: "td" + cliente.descricao + "Desc_" + index
        ,
        align: "right"
    });
    var _tdDescricao2 = Builder.node("td", {
        id: "td" + cliente.descricao + "Valor_" + index
        ,
        align: "left"
    });
    var _tdDescricaoCidade1 = Builder.node("td", {
        id: "td" + cliente.descricao + "DescCidade_" + index
        ,
        align: "right"
    });
    var _tdDescricaoCidade2 = Builder.node("td", {
        id: "td" + cliente.descricao + "ValorCidade_" + index
        ,
        align: "left"
    });
    var _tdCnpj1 = Builder.node("td", {
        id: "td" + cliente.descricao + "Cnpj_" + index
        ,
        align: "right"
    });
    var _tdCnpj2 = Builder.node("td", {
        id: "td" + cliente.descricao + "ValorCnpj_" + index
        ,
        align: "left"
    });

    var _labelCidade = Builder.node("label", {
        id: "label" + cliente.descricao + "_" + index
    }, cliente.descricao + ":");
    var _labelRemetenteCidade = Builder.node("label", {
        id: "label" + cliente.descricao + "Cidade_" + index
    }, "Cidade:");
    var _labelCNPJ = Builder.node("label", {
        id: "label" + cliente.descricao + "Cidade_" + index
    }, "CNPJ:");

    var _inpClienteIdH = Builder.node("input", {
        id: "id" + cliente.descricao + "_" + index,
        name: "id" + cliente.descricao + "_" + index,
        type: "hidden",
        value: cliente.id
    });

    var _inpClienteCreditoPresumido = Builder.node("input", {
        id: "valorCreditoPresumido" + cliente.descricao + "_" + index,
        name: "valorCreditoPresumido" + cliente.descricao + "_" + index,
        type: "hidden",
        value: (cliente.creditoPresumido == null || cliente.creditoPresumido == undefined ? "0,00" : cliente.creditoPresumido)
    });

    var _inpUtilizarNormativaGSF129816GO = Builder.node("input", {
        id: "utilizarNormativaGSF129816GO" + cliente.descricao + "_" + index,
        name: "utilizarNormativaGSF129816GO" + cliente.descricao + "_" + index,
        type: "hidden",
        value: (cliente.utilizarNormativaGSF129816GO == null || cliente.utilizarNormativaGSF129816GO == undefined ? "false" : cliente.utilizarNormativaGSF129816GO)
    });

    var _inpTipoTributacao = Builder.node("input", {
        id: "tipoTributacao_" + cliente.descricao + "_" + index,
        name: "tipoTributacao_" + cliente.descricao + "_" + index,
        type: "hidden",
        value: (cliente.tipoTributacao == null || cliente.tipoTributacao == undefined ? "NI" : cliente.tipoTributacao)
    });

    var _inpClienteUTilizaTpFreteTabela = Builder.node("input", {
        id: "utilizaTipoFreteTabela" + cliente.descricao + "_" + index,
        name: "utilizaTipoFreteTabela" + cliente.descricao + "_" + index,
        type: "hidden",
        value: cliente.utilizaTipoFreteTabela
    });

    var _inpTabelaRemetenteIdsH = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "TabelaRemetenteIds_" + index,
        name: cliente.descricao.toLowerCase() + "TabelaRemetenteIds_" + index,
        type: "hidden",
        value: cliente.tabelaRemetenteIds
    });
    var _inpQtdDiasPgtoH = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "QtdDiasPgto_" + index,
        name: cliente.descricao.toLowerCase() + "QtdDiasPgto_" + index,
        type: "hidden",
        value: cliente.qtdDiasPgto
    });
    var _inpTipoPgtoH = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "TipoPgto_" + index,
        name: cliente.descricao.toLowerCase() + "TipoPgto_" + index,
        type: "hidden",
        value: cliente.tipoPgto
    });
    var _inpVendedorH = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "Vendedor_" + index,
        name: cliente.descricao.toLowerCase() + "Vendedor_" + index,
        type: "hidden",
        value: cliente.vendedor.razaoSocial
    });
    var _inpVendedorIdH = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "VendedorId_" + index,
        name: cliente.descricao.toLowerCase() + "VendedorId_" + index,
        type: "hidden",
        value: cliente.vendedor.id
    });
    var _inpVendedorComissaoH = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "VendedorComissao_" + index,
        name: cliente.descricao.toLowerCase() + "VendedorComissao_" + index,
        type: "hidden",
        value: colocarVirgula(cliente.percComissaoVendedor, 2)
    });
    var _inpUnificadaModalVendedorH = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "UnificadaModalVendedor_" + index,
        name: cliente.descricao.toLowerCase() + "UnificadaModalVendedor_" + index,
        type: "hidden",
        value: cliente.unificadaModalVendedor
    });
    var _inpTipoProdutoH = Builder.node("select", {
        id: cliente.descricao.toLowerCase() + "TipoProduto_" + index,
        name: cliente.descricao.toLowerCase() + "TipoProduto_" + index,
        value: ""
    });
    var tpProdNenhum = Builder.node("option", {value: '0'}, 'NENHUM');
    if (cliente.listaTipoProduto != null && cliente.listaTipoProduto != undefined) {
        povoarSelect(_inpTipoProdutoH, cliente.listaTipoProduto);
        if (cliente.listaTipoProduto != null && cliente.listaTipoProduto.length > 0) {
            _inpTipoProdutoH.appendChild(tpProdNenhum);
            _inpTipoProdutoH.value = cliente.listaTipoProduto[0].valor;
        }
    }
    invisivel(_inpTipoProdutoH);

    var _inpPercComissaoRodoviarioFracionadoVendedorH = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "PercComissaoRodoviarioFracionadoVendedor_" + index,
        name: cliente.descricao.toLowerCase() + "PercComissaoRodoviarioFracionadoVendedor_" + index,
        type: "hidden",
        value: colocarVirgula(cliente.percComissaoRodoviarioFracionadoVendedor, 2)
    });
    var _inpPercComissaoRodoviarioLotacaoVendedorH = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "PercComissaoRodoviarioLotacaoVendedor_" + index,
        name: cliente.descricao.toLowerCase() + "PercComissaoRodoviarioLotacaoVendedor_" + index,
        type: "hidden",
        value: colocarVirgula(cliente.percComissaoRodoviarioLotacaoVendedor, 2)
    });
    var _inpStMgH = Builder.node("input", {
        id: "isStMg" + cliente.descricao + "_" + index,
        name: "isStMg" + cliente.descricao + "_" + index,
        type: "hidden",
        value: cliente.isStMG
    });
    var _inpUtilizaPautaFiscalH = Builder.node("input", {
        id: "utilizaPautaFiscal" + cliente.descricao + "_" + index,
        name: "utilizaPautaFiscal" + cliente.descricao + "_" + index,
        type: "hidden",
        value: cliente.utilizaPautaFiscal
    });
    var _inpTipoTabelaH = Builder.node("input", {
        id: "tipoTabela" + cliente.descricao + "_" + index,
        name: "tipoTabela" + cliente.descricao + "_" + index,
        type: "hidden",
        value: cliente.tipoTabela
    });
    var _inpReducaoBaseIcmsCliente = Builder.node("input", {
        id: "reducaoBaseIcms" + cliente.descricao + "_" + index,
        name: "reducaoBaseIcms" + cliente.descricao + "_" + index,
        type: "hidden",
        value: colocarVirgula(cliente.reducaoIcms)
    });
    var _inpUtilizarNormativaGSF598GOCliente = Builder.node("input", {
        id: "utilizarNormativaGSF598GO" + cliente.descricao + "_" + index,
        name: "utilizarNormativaGSF598GO" + cliente.descricao + "_" + index,
        type: "hidden",
        value: cliente.isUtilizarNormativaGSF598GO
    });

    var _inpReducaoBaseIcmsH = Builder.node("input", {
        id: "reducaoBaseIcms_" + index,
        name: "reducaoBaseIcms_" + index,
        type: "hidden",
        value: colocarVirgula(cliente.reducaoIcms)
    });

    var _inpObriaTabelaTipoProdutoH = Builder.node("input", {
        id: "obrigaTabelaTipoProduto_" + index,
        name: "obrigaTabelaTipoProduto_" + index,
        type: "hidden",
        value: cliente.obrigaTabelaTipoProduto
    });
    var _inpIncluirTdeH = Builder.node("input", {
        id: "incluirTde" + cliente.descricao + "_" + index,
        name: "incluirTde" + cliente.descricao + "_" + index,
        type: "hidden",
        value: cliente.isIncluirTde
    });
    var _inpInscricaEstadualH = Builder.node("input", {
        id: "inscricaoEstadual" + cliente.descricao + "_" + index,
        name: "inscricaoEstadual" + cliente.descricao + "_" + index,
        type: "hidden",
        value: cliente.inscEst
    });
    var _inpClienteTipoCfopH = Builder.node("input", {
        id: "tipoCfop" + cliente.descricao + "_" + index,
        name: "tipoCfop" + cliente.descricao + "_" + index,
        type: "hidden",
        value: cliente.tipoCfop
    });
    var _inpRazaoSocial = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "_" + index,
        name: cliente.descricao.toLowerCase() + "_" + index,
        type: "text",
        size: tamanhoPadrao,
        value: cliente.razaoSocial
    });
    var _inpClienteCidade = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "Cidade_" + index,
        name: cliente.descricao.toLowerCase() + "Cidade_" + index,
        type: "text",
        value: cliente.cidade
    });
    var _inpClienteUF = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "UF_" + index,
        name: cliente.descricao.toLowerCase() + "UF_" + index,
        type: "text",
        size: "3",
        style: "margin-left : 5px;" + estiloTextCenter,
        value: cliente.uf
    });
    var _inpClienteGerarNfseCidadeOrigemDestinoCteLote = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "GerarNfseCidadeOrigemDestinoCteLote_" + index,
        name: cliente.descricao.toLowerCase() + "GerarNfseCidadeOrigemDestinoCteLote_" + index,
        type: "hidden",
        value: cliente.gerarNfseCidadeOrigemDestinoCteLote
    });
    
    var _inpTipoGerarNfseCidadeOrigemDestinoCteLote = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "TipoNfseCidadeOrigemDestinoCteLote_" + index,
        name: cliente.descricao.toLowerCase() + "TipoNfseCidadeOrigemDestinoCteLote_" + index,
        type: "hidden",
        value: cliente.tipoGeracaoNfseCidadeOrigemDestinoCteLote
    });
    
    var _inpSerieMinuta = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "-serie-minuta-" + index,
        name: cliente.descricao.toLowerCase() + "-serie-minuta-" + index,
        type: "hidden",
        value: cliente.serieMinuta
    });
    
    var _inpCidadeIdH = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "CidadeId_" + index,
        name: cliente.descricao.toLowerCase() + "CidadeId_" + index,
        type: "hidden",
        value: cliente.cidadeId
    });
    var _inpUtilizaTabelaRemetenteH = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "UtilizaTabelaRemetente_" + index,
        name: cliente.descricao.toLowerCase() + "UtilizaTabelaRemetente_" + index,
        type: "hidden",
        value: cliente.utilizarTabelaRemetente
    });
    var _inpClienteCNPJ = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "CNPJ_" + index,
        name: cliente.descricao.toLowerCase() + "CNPJ_" + index,
        type: "text",
        value: cliente.cnpj,
        size: "25",
        className: classMin
    });
    var _inpClienteTipoCGC = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "TipoCGC_" + index,
        name: cliente.descricao.toLowerCase() + "TipoCGC_" + index,
        type: "hidden",
        value: cliente.inscEst,
        className: classMin
    });
    var _inpClienteStICMS = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "StIcms_" + index,
        name: cliente.descricao.toLowerCase() + "StIcms_" + index,
        type: "hidden",
        value: (cliente.stIcms == "0" || cliente.stIcms == 0 ? 0 : cliente.stIcms),
        className: classMin
    });
    _inpClienteStICMS.value = (cliente.stIcms == "0" || cliente.stIcms == 0 ? 0 : cliente.stIcms);

    var _inpTipoProdutoDestinatario = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "tipoProdutoDestinatario_" + index,
        name: cliente.descricao.toLowerCase() + "tipoProdutoDestinatario_" + index,
        type: "hidden",
        value: (cliente.tipoProdutoDestinatario == "0" || cliente.tipoProdutoDestinatario == 0 ? 0 : cliente.tipoProdutoDestinatario)
    });

    var _inpClienteObservacaoH = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "Obs_" + index,
        name: cliente.descricao.toLowerCase() + "Obs_" + index,
        type: "hidden",
        value: replaceAll(cliente.obs, "<br/>", "\n")
    });
    var _inpClienteObservacaoFiscoH = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "ObsFisco_" + index,
        name: cliente.descricao.toLowerCase() + "ObsFisco_" + index,
        type: "hidden",
        value: replaceAll(cliente.obsFisco, "<br/>", "\n")
    });
    var _inpClienteTipoOrigemFreteH = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "TipoOrigemFrete_" + index,
        name: cliente.descricao.toLowerCase() + "TipoOrigemFrete_" + index,
        type: "hidden",
        value: cliente.tipoOrigemFrete,
        className: classMin
    });

    var _botLocCliente = Builder.node("input", {
        id: "botLoc" + cliente.descricao + "_" + index,
        type: "button",
        value: "...",
        className: "inputBotaoMin",
        onClick: callLocalizar
    });

    var _inpTravaCamposH = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "TravaCampos_" + index,
        name: cliente.descricao.toLowerCase() + "TravaCampos_" + index,
        type: "hidden",
        value: cliente.travaCamposImportacao
    });

    var _botLocClienteCidade = Builder.node("input", {
        id: "botLoc" + cliente.descricao + "Cidade_" + index,
        type: "button",
        value: "...",
        className: "inputBotaoMin"
    });

    var _imgAbrirCliente = Builder.node("img", {
        src: "img/page_edit.png",
        id: "abrir" + cliente.descricao + "_" + index,
        className: "imagemLinkSpc",
        border: "0",
        onClick: callVerCliente,
        title: "Ver Cadastro "
    });

    var _inpTipoDocumentoPadrao = Builder.node("input", {
        type: "hidden"
        , id: "tipoDocumentoPadrao" + cliente.descricao + "_" + index
        , value: cliente.tipoDocumentoPadrao
    });

    var _inpExped = Builder.node("input", {
        id: "exp_" + index,
        name: "tiporedesp_" + index,
        type: "radio",
        value: "exp",
        checked: "true",
        onClick: "javascript:cidadeOrigemExpedidor(" + index + ");alteraRecebedorLote(" + index + ");alteraTipoTaxa('S'," + index + ")"
    });

    var _labelExpedidor = Builder.node("label", {}, "Exped.");

    var _inpRec = Builder.node("input", {
        id: "rec_" + index,
        name: "tiporedesp_" + index,
        type: "radio",
        value: "rec",
        onClick: "javascript:cidadeDestinoRecebedor(" + index + ");alteraExpedidorLote(" + index + ");alteraTipoTaxa('S'," + index + ")"
    });
    var _labelRecebedor = Builder.node("label", {}, "Receb.");

    var _msgClienteH = Builder.node("input", {
        id: "_msg" + cliente.descricao + "_cte_" + index,
        name: "_msg" + cliente.descricao + "_cte_" + index,
        type: "hidden",
        value: cliente.mensagemUsuarioCte
    });
    var _ArredondamentoCliente = Builder.node("input", {
        id: "_tipoArredondamentoPeso" + cliente.descricao + "_" + index,
        name: "_tipoArredondamentoPeso" + cliente.descricao + "_" + index,
        type: "hidden",
        value: cliente.tipoArredondamentoPeso
    });

    var _isfreteDirigido = Builder.node("input", {
        id: "_isfreteDirigido" + cliente.descricao + "_" + index,
        name: "_isfreteDirigido" + cliente.descricao + "_" + index,
        type: "hidden",
        value: cliente.isFreteDirigido
    });

    var _utilizarTabelaCliente = Builder.node("input", {
        id: "_utilizarTabelaCliente_id_" + cliente.descricao + "_" + index,
        name: "_utilizarTabelaCliente_id_" + cliente.descricao + "_" + index,
        type: "hidden",
        value: (cliente.utilizarTabelaCliente == undefined || cliente.utilizarTabelaCliente == null ? "0" : cliente.utilizarTabelaCliente)
    });

    var _inpClienteEspecieSerieModalClienteH = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "EspecieSerieModalCliente_" + index,
        name: cliente.descricao.toLowerCase() + "EspecieSerieModalCliente_" + index,
        type: "hidden",
        value: cliente.especieSerieModal
    });
    var _inpClienteEspecieClienteH = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "EspecieCliente_" + index,
        name: cliente.descricao.toLowerCase() + "EspecieCliente_" + index,
        type: "hidden",
        value: cliente.especie
    });
    var _inpClienteSerieClienteH = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "SerieCliente_" + index,
        name: cliente.descricao.toLowerCase() + "SerieCliente_" + index,
        type: "hidden",
        value: cliente.serie
    });
    var _inpClienteModalClienteH = Builder.node("input", {
        id: cliente.descricao.toLowerCase() + "ModalCliente_" + index,
        name: cliente.descricao.toLowerCase() + "ModalCliente_" + index,
        type: "hidden",
        value: cliente.modalCliente
    });
    
    readOnly(_inpRazaoSocial, estiloMinReadOnly);
    readOnly(_inpClienteCidade, estiloMinReadOnly);
    readOnly(_inpClienteUF, estiloMinReadOnly);
    readOnly(_inpClienteCNPJ, estiloMinReadOnly);

    //povoando elementos
    _tdDescricao1.appendChild(_labelCidade);
    _tdDescricao2.appendChild(_inpRazaoSocial);
    _tdDescricao2.appendChild(_inpClienteIdH);
    _tdDescricao2.appendChild(_inpClienteCreditoPresumido);
    _tdDescricao2.appendChild(_inpUtilizarNormativaGSF129816GO);
    _tdDescricao2.appendChild(_inpTipoTributacao);
    _tdDescricao2.appendChild(_inpClienteUTilizaTpFreteTabela);
    _tdDescricao2.appendChild(_inpQtdDiasPgtoH);
    _tdDescricao2.appendChild(_inpTipoPgtoH);
    _tdDescricao2.appendChild(_inpVendedorH);
    _tdDescricao2.appendChild(_inpVendedorIdH);
    _tdDescricao2.appendChild(_inpVendedorComissaoH);
    _tdDescricao2.appendChild(_inpUnificadaModalVendedorH);
    _tdDescricao2.appendChild(_inpPercComissaoRodoviarioFracionadoVendedorH);
    _tdDescricao2.appendChild(_inpPercComissaoRodoviarioLotacaoVendedorH);
    _tdDescricao2.appendChild(_inpTabelaRemetenteIdsH);
    _tdDescricao2.appendChild(_inpUtilizaTabelaRemetenteH);
    _tdDescricao2.appendChild(_inpClienteObservacaoH);
    _tdDescricao2.appendChild(_inpClienteObservacaoFiscoH);
    _tdDescricao2.appendChild(_inpStMgH);
    _tdDescricao2.appendChild(_inpInscricaEstadualH);
    _tdDescricao2.appendChild(_inpClienteTipoCGC);
    _tdDescricao2.appendChild(_inpClienteStICMS);
    _tdDescricao2.appendChild(_inpIncluirTdeH);
    _tdDescricao2.appendChild(_inpUtilizaPautaFiscalH);
    _tdDescricao2.appendChild(_inpClienteTipoOrigemFreteH);
    _tdDescricao2.appendChild(_inpTipoTabelaH);
    _tdDescricao2.appendChild(_inpTipoProdutoH);
    _tdDescricao2.appendChild(_msgClienteH);
    _tdDescricao2.appendChild(_ArredondamentoCliente);
    _tdDescricao2.appendChild(_utilizarTabelaCliente);
    _tdDescricao2.appendChild(_inpTravaCamposH);
    _tdDescricao2.appendChild(_inpClienteEspecieSerieModalClienteH);
    _tdDescricao2.appendChild(_inpClienteEspecieClienteH);
    _tdDescricao2.appendChild(_inpClienteSerieClienteH);
    _tdDescricao2.appendChild(_inpClienteModalClienteH);

    if (cliente.descricao == "Destinatario") {
        _tdDescricao2.appendChild(_inpReducaoBaseIcmsH);
    }
    _tdDescricao2.appendChild(_inpReducaoBaseIcmsCliente);
    _tdDescricao2.appendChild(_inpUtilizarNormativaGSF598GOCliente);
    _tdDescricao2.appendChild(_inpTipoProdutoDestinatario);
    if (cliente.descricao == "Remetente") {
        _tdDescricao2.appendChild(_inpObriaTabelaTipoProdutoH);
        _tdDescricao2.appendChild(_isfreteDirigido);
    }

    _tdDescricao2.appendChild(_inpClienteTipoCfopH);
    _tdDescricao2.appendChild(_botLocCliente);
    _tdDescricao2.appendChild(_imgAbrirCliente);
    if (cliente.descricao == "Recebedor" || cliente.descricao == "Expedidor") {
        _tdDescricao2.appendChild(_borrachaLocaliza);
    }
    _tdDescricao2.appendChild(_inpTipoDocumentoPadrao);

    if (cliente.descricao == 'Redespacho') {
        _tdDescricao2.appendChild(_inpExped);
        _tdDescricao2.appendChild(_labelExpedidor);
        _tdDescricao2.appendChild(_inpRec);
        _tdDescricao2.appendChild(_labelRecebedor);
    }

    _tdDescricaoCidade1.appendChild(_labelRemetenteCidade);
    _tdDescricaoCidade2.appendChild(_inpClienteCidade);
    _tdDescricaoCidade2.appendChild(_inpClienteUF);
    _tdDescricaoCidade2.appendChild(_inpClienteGerarNfseCidadeOrigemDestinoCteLote);
    _tdDescricaoCidade2.appendChild(_inpTipoGerarNfseCidadeOrigemDestinoCteLote);
    _tdDescricaoCidade2.appendChild(_inpSerieMinuta);
    _tdDescricaoCidade2.appendChild(_inpCidadeIdH);
    //_tdDescricaoCidade2.appendChild(_botLocClienteCidade);   
    _tdCnpj1.appendChild(_labelCNPJ);
    _tdCnpj2.appendChild(_inpClienteCNPJ);


    _trCliente.appendChild(_tdDescricao1);
    _trCliente.appendChild(_tdDescricao2);
    _trCliente.appendChild(_tdDescricaoCidade1);
    _trCliente.appendChild(_tdDescricaoCidade2);
    _trCliente.appendChild(_tdCnpj1);
    _trCliente.appendChild(_tdCnpj2);


    //ocultar campos
    if (!verTr) {
        invisivel(_trCliente);
    }
    if (!escolherCli) {
        invisivel(_botLocCliente);
        invisivel(_imgAbrirCliente);
    }
    invisivel(_inpTipoProdutoH);

    tabela.appendChild(_trCliente);

    if (cliente.descricao === 'Consignatario') {
        if (cliente.mensagemUsuarioCte !== "" && cliente.mensagemUsuarioCte !== null) {
            setMsgCliente(index, cliente.mensagemUsuarioCte);
        } else {
            limparMsgCliente(index);
        }
    }

}




function addConhecimentoLoteClienteTRResponsePagamento(ctrc, index, tabela, classe) {
    var callAlterarTipoPagamento = "alterarTipoPagamento(" + index + ", true);";
    var callVerRedespacho = "verRedespacho(this);";
    var callAtribuirCfopPdrao = "atribuirCfopPadrao(" + index + ");";
    var callAbrirLocalizarCFOP = "abrirLocalizarCFOP(" + index + ");";
    var callDefinirAliquotaIcmsCtrc = "definirAliquotaIcmsCtrc(" + index + ");";

    var apelido = "Resp";

    var _tr = Builder.node("tr");
    var _td = Builder.node("td", {
        colSpan: 6,
        width: "100%",
        border: 0,
        cellpadding: 0,
        cellspacing: 0
    });
    var _table = Builder.node("table", {
        width: "100%"
    });
    var _tbody = Builder.node("tbody");
    var _trResp = Builder.node("tr", {
        id: "tr" + apelido + "_" + index,
        className: classe
    });


    //td's
    var _tdRespDesc = Builder.node("td", {
        id: "td" + apelido + "Desc_" + index,
        className: classe,
        rowSpan: 2,
        align: "right",
        width: "8%"
    });
    var _tdRespValor = Builder.node("td", {
        id: "td" + apelido + "Valor_" + index,
        className: classe,
        rowSpan: 2,
        align: "center",
        width: "12%"
    });
    var _tdRecebedorRetira = Builder.node("td", {
        id: "tdIsRedespacho_" + index,
        className: classe,
        align: "center",
        rowSpan: 2,
        width: "18%"
    });
    var _tdRedespacho = Builder.node("td", {
        id: "tdIsRedespacho_" + index,
        className: classe,
        align: "center",
        rowSpan: 2,
        width: "10%"
    });
    var _tdCtrcDesc = Builder.node("td", {
        id: "tdCtrcDesc_" + index,
        className: classe,
        align: "right",
        width: "5%"
    });
    var _tdCtrcValor = Builder.node("td", {
        id: "tdCtrcValor_" + index,
        className: classe,
        width: "10%",
        align: "left"
    });
    var _tdValorDesc = Builder.node("td", {
        id: "tdRedespachoDesc_" + index,
        className: classe,
        width: "5%",
        align: "right"
    });
    //var _tdValorDesc = Builder.node("td", {id:"tdRedespachoDesc_" + index, className: classe+"NoAlign", align:"right", width: "8%"});
    var _tdValorValor = Builder.node("td", {
        id: "tdRedespachoValor_" + index,
        className: classe,
        width: "8%",
        align: "left"
    });
    var _tdValorIcmsDesc = Builder.node("td", {
        id: "tdRedespachoIcmsDesc_" + index,
        className: classe,
        width: "5%",
        align: "right"
    });
    //var _tdValorDesc = Builder.node("td", {id:"tdRedespachoDesc_" + index, className: classe+"NoAlign", align:"right", width: "8%"});
    var _tdValorIcmsValor = Builder.node("td", {
        id: "tdRedespachoIcmsValor_" + index,
        className: classe,
        width: "8%",
        align: "left"
    });
    var _tdCfopDesc = Builder.node("td", {
        id: "tdCfopDesc_" + index,
        className: classe,
        width: "6%",
        rowSpan: 2,
        align: "right"
    });
    var _tdCfopValor = Builder.node("td", {
        id: "tdCfopDesc_" + index,
        className: classe,
        width: "9%",
        rowSpan: 2,
        align: "left"
    });


    var _trRedespChaveAcesso = Builder.node("tr", {
        id: "tr" + apelido + "RedespachoChaveAcesso_" + index,
        className: classe
    });

    var _tdRedChaveAcessoDesc = Builder.node("td", {
        id: "tdRedChaveAcessoDesc_" + index,
        className: classe,
        colSpan: 2,
        align: "right"
    });
    var _tdRedChaveAcessoValor = Builder.node("td", {
        id: "tdRedChaveAcessoDesc_" + index,
        className: classe,
        colSpan: 2,
        align: "left"
    });
    var _tdRedChaveDadosHidden = Builder.node("td", {
        id: "tdRedChaveDadosHidden_" + index,
        className: classe
    });
    var _tdRedChaveDadosQtd = Builder.node("td", {
        id: "tdRedChaveDadosQtd_" + index,
        className: classe
    });

    //label's'
    var _labelRespDesc = Builder.node("label", {
        id: "label" + apelido + "Desc_" + index
    }, "Resp. Pgto.:");
    var _labelCIF = Builder.node("label", {
        id: "label" + apelido + "CIF_" + index
    }, "CIF");
    var _labelFOB = Builder.node("label", {
        id: "label" + apelido + "FOB_" + index
    }, "FOB");
    var _labelTerceiros = Builder.node("label", {
        id: "label" + apelido + "Trerceiros_" + index
    }, "Terceiros");
    var _labelRedespacho = Builder.node("label", {}, "Redespacho");
    var _labelCtrc = Builder.node("label", {}, "Ctrc:");
    var _labelValor = Builder.node("label", {}, "Valor:");
    var _labelValorIcms = Builder.node("label", {}, "ICMS:");
    var _labelCfop = Builder.node("label", {}, "CFOP:");
    var _labelbranco = Builder.node("label", {}, "  ");
    var _labelRedChaveAcesso = Builder.node("label", {}, "CTe Expedidor:");
    var _labelRedChaveAcessoQTD = Builder.node("label", {
        id: "lblRedChaveAcessoQtd_" + index,
        name: "lblRedChaveAcessoQtd_" + index,
        style: "text-align:center "
    });
    var _labelRecebedorRetira = Builder.node("label", {}, "Recebedor retira a carga no destino");

    //input's
    var _inpTpPag_HIDDEN_GAMB = Builder.node("input", {
        id: "tipoPagamentoGamb_" + index,
        name: "tipoPagamentoGamb_" + index,
        type: "hidden",
        value: ""
    });
    var _inpCIF = Builder.node("input", {
        id: "tipoPagamentoC_" + index,
        name: "tipoPagamento_" + index,
        type: "radio",
        value: "cif",
        onClick: callAlterarTipoPagamento
    });
    var _inpFOB = Builder.node("input", {
        id: "tipoPagamentoF_" + index,
        name: "tipoPagamento_" + index,
        type: "radio",
        onClick: callAlterarTipoPagamento,
        value: "fob"
    });
    var _inpTerceiros = Builder.node("input", {
        id: "tipoPagamentoT_" + index,
        name: "tipoPagamento_" + index,
        type: "radio",
        value: "terceiros",
        onClick: callAlterarTipoPagamento
    });
    var _inpRecebedorRetira = Builder.node("input", {
        id: "isRecebedorRetira_" + index,
        name: "isRecebedorRetira_" + index,
        type: "checkbox"
    });
    _inpRecebedorRetira.checked = ctrc.recebedorRetiraCargaDestino;

    var _inpRedespacho = Builder.node("input", {
        id: "isRedespacho_" + index,
        name: "isRedespacho_" + index,
        type: "checkbox",
        onClick: callVerRedespacho + callAtribuirCfopPdrao + callDefinirAliquotaIcmsCtrc + callAlterarTipoPagamento
    });
    _inpRedespacho.checked = ctrc.isRedespacho;

    var _inpCtrc = Builder.node("input", {
        id: "redespachoCtrc_" + index,
        name: "redespachoCtrc_" + index,
        type: "text",
        className: estiloMin,
        maxLengt: 10,
        size: 8,
        value: ctrc.redespachoCtrc

    });
    var _inpRedChaveAcesso = Builder.node("input", {
        id: "redespachoChaveAcesso_" + index,
        name: "redespachoChaveAcesso_" + index,
        type: "text",
        className: estiloMin,
        maxLengt: 44,
        size: 40

    });
    var _inpValor = Builder.node("input", {
        id: "redespachoValor_" + index,
        name: "redespachoValor_" + index,
        type: "text",
        size: 8,
        style: estiloTextRight,
        className: estiloMin,
        onKeyPress: callMascaraReais,
        maxLengt: 12,
        value: colocarVirgula(ctrc.redespachoValor)

    });
    var _inpValorIcms = Builder.node("input", {
        id: "redespachoValorIcms_" + index,
        name: "redespachoValorIcms_" + index,
        type: "text",
        size: 8,
        style: estiloTextRight,
        className: estiloMin,
        onKeyPress: callMascaraReais,
        maxLengt: 12,
        value: colocarVirgula(ctrc.redespachoValorIcms)

    });
    var _inpCfop = Builder.node("input", {
        id: "cfopCtrc_" + index,
        name: "cfopCtrc_" + index,
        type: "text",
        size: 5,
        style: estiloTextCenter,
        className: estiloMin,
        value: ctrc.cfop
    });
    readOnly(_inpCfop, estiloMinReadOnly);
    var _inpCfopIdH = Builder.node("input", {
        id: "cfopCtrcId_" + index,
        name: "cfopCtrcId_" + index,
        type: "hidden",
        size: 4,
        className: estiloMin,
        value: ctrc.cfopId
    });
    var _botLocCFOP = Builder.node("input", {
        id: "botCFOP_" + index,
        type: "button",
        value: "...",
        className: "inputBotaoMin",
        onClick: callAbrirLocalizarCFOP
    });

    var _inpRedChaveAcessoExtras = Builder.node("input", {
        id: "redespachoChaveAcessoAll_" + index,
        name: "redespachoChaveAcessoAll_" + index,
        type: "hidden",
        className: estiloMin,
        maxLengt: 44,
        size: 40

    });
    var _imgChaveAcessoExtras = Builder.node("img", {
        src: "img/add.gif",
        onclick: "montarDivChaves(" + index + ")",
        className: "imagemLink"

    });

    var _json_taxas = Builder.node("input", {
        id: "json_taxas_conhecimento_" + index,
        name: "json_taxas_conhecimento_" + index,
        type: "hidden",
        className: estiloMin
    });

    var _is_nfe_por_entrega = Builder.node("input", {
        id: "is_nfe_por_entrega_" + index,
        name: "is_nfe_por_entrega_" + index,
        type: "hidden",
        className: estiloMin
    });

    //povoando
    _tdRespDesc.appendChild(_labelRespDesc);
    _tdRespValor.appendChild(_inpTpPag_HIDDEN_GAMB);
    _tdRespValor.appendChild(_inpCIF);
    _tdRespValor.appendChild(_labelCIF);
    _tdRespValor.appendChild(_inpFOB);
    _tdRespValor.appendChild(_labelFOB);
    _tdRespValor.appendChild(_inpTerceiros);
    _tdRespValor.appendChild(_labelTerceiros);
    _tdRespValor.appendChild(_json_taxas);
    _tdRespValor.appendChild(_is_nfe_por_entrega);

    _tdRecebedorRetira.appendChild(_inpRecebedorRetira);
    _tdRecebedorRetira.appendChild(_labelRecebedorRetira);
    _tdRedespacho.appendChild(_inpRedespacho);
    _tdRedespacho.appendChild(_labelRedespacho);

    _tdCtrcDesc.appendChild(_labelCtrc);
    _tdCtrcValor.appendChild(_inpCtrc);

    _tdValorDesc.appendChild(_labelValor);
    _tdValorValor.appendChild(_inpValor);

    _tdValorIcmsDesc.appendChild(_labelValorIcms);
    _tdValorIcmsValor.appendChild(_inpValorIcms);

    _tdCfopDesc.appendChild(_labelCfop);
    _tdCfopValor.appendChild(_inpCfop);
    //_tdCfopValor.appendChild(_botLocCFOP);
    _tdCfopValor.appendChild(_inpCfopIdH);

    _trResp.appendChild(_tdCfopDesc);
    _trResp.appendChild(_tdCfopValor);
    _trResp.appendChild(_tdRespDesc);
    _trResp.appendChild(_tdRespValor);
    _trResp.appendChild(_tdRecebedorRetira);
    _trResp.appendChild(_tdRedespacho);
    _trResp.appendChild(_tdCtrcDesc);
    _trResp.appendChild(_tdCtrcValor);
    _trResp.appendChild(_tdValorDesc);
    _trResp.appendChild(_tdValorValor);
    _trResp.appendChild(_tdValorIcmsDesc);
    _trResp.appendChild(_tdValorIcmsValor);

    var chavesAcesso = ctrc.redespachoChaveAcesso;
    var agrupador = "";
    var contador = (chavesAcesso.split(",")[0] == "" ? 0 : 1);
    chavesAcesso = chavesAcesso.replace("[", "").replace("]", "");
    _inpRedChaveAcesso.value = chavesAcesso.split(",")[0];
    for (var i = 1; i <= chavesAcesso.split(",").length; i++) {
        if (chavesAcesso.split(",")[i] != undefined && chavesAcesso.split(",")[i] != "" && chavesAcesso.split(",")[0].trim() != chavesAcesso.split(",")[i].trim()) {
            agrupador = agrupador + chavesAcesso.split(",")[i].trim() + ",";
            contador++;
        }
    }
    _inpRedChaveAcessoExtras.value = agrupador;
    _labelRedChaveAcessoQTD.innerHTML = "QTD chaves : " + contador;
    _tdRedChaveAcessoDesc.appendChild(_labelRedChaveAcesso);
    _tdRedChaveAcessoValor.appendChild(_inpRedChaveAcesso);
    _tdRedChaveDadosHidden.appendChild(_imgChaveAcessoExtras);
    _tdRedChaveDadosHidden.appendChild(_inpRedChaveAcessoExtras);
    _tdRedChaveDadosQtd.appendChild(_labelRedChaveAcessoQTD);

    _trRedespChaveAcesso.appendChild(_tdRedChaveAcessoDesc);
    _trRedespChaveAcesso.appendChild(_tdRedChaveAcessoValor);
    _trRedespChaveAcesso.appendChild(_tdRedChaveDadosHidden);
    _trRedespChaveAcesso.appendChild(_tdRedChaveDadosQtd);

    _tbody.appendChild(_trResp);
    _tbody.appendChild(_trRedespChaveAcesso);
    _table.appendChild(_tbody);
    _td.appendChild(_table);
    _tr.appendChild(_td);
    tabela.appendChild(_tr);

    if (ctrc.modFrete == "0") {
        _inpCIF.checked = true;
    } else if (ctrc.modFrete == "1") {
        _inpFOB.checked = true;
    } else if (ctrc.modFrete == "2") {
        _inpTerceiros.checked = true;
    } else if (ctrc.modFrete == "3" || ctrc.modFrete == "4" || ctrc.modFrete == "9") {
        setErroCtrc(index, 'O Tomador do serviço (Consignatário) não foi informado na NF-e, favor informá-lo antes de importar.');
    }
    verRedespacho($("isRedespacho_" + index));
}
//notas fiscais
function addConhecimentoLoteNotasFiscais(ctrc, index, tabela, classe, objSerie) {
    addConhecimentoLoteNotasFiscaisCabecalho(index, tabela, classe, objSerie);

}
function addConhecimentoLoteNotasFiscaisCabecalho(index, tabela, classe, objSerie) {

    //td's'
    var _tdAdd = Builder.node("td", {
        width: "2%"
    });
    var _tdShow = Builder.node("td", {
        width: "2%"
    });
    var _tdNumero = Builder.node("td", {
        width: "7%"
    }, 'Número');
    var _tdSerie = Builder.node("td", {
        width: "4%"
    }, 'Série');
    var _tdEmissao = Builder.node("td", {
        width: "8%"
    }, 'Emissão');
    var _tdValor = Builder.node("td", {
        width: "7%"
    }, 'Valor');
    var _tdPeso = Builder.node("td", {
        width: "8%"
    }, 'Peso(Kg)');
    var _tdVolume = Builder.node("td", {
        width: "7%"
    }, 'Volume');
    var _tdEmpalagem = Builder.node("td", {
        width: "9%"
    }, 'Embalagem');
    var _tdConteudo = Builder.node("td", {
        width: "12%"
    }, 'Conteúdo');
    var _tdBcIcm = Builder.node("td", {
        width: "7%"
    }, 'Bc Icms');
    var _tdVlIcm = Builder.node("td", {
        width: "7%"
    }, 'Vl Icms');
    var _tdImcSt = Builder.node("td", {
        width: "6%"
    }, 'Icms ST');
    var _tdPedido = Builder.node("td", {
        width: "7%"
    }, 'Pedido');
    var _tdTpDoc = Builder.node("td", {
        width: "6%"
    }, 'Tp.Doc');

    var _imgAdd = Builder.node("img", {
        src: "img/add.gif",
        id: "addNota_" + index,
        className: "imagemLinkSpc",
        border: "0",
        onClick: "addNotaDom(" + null + ",'" + index + "','" + classe + "','" + objSerie.value + "',true);",
        title: "Adicionar Nota  "
    });
    var _inpQtdNotas = Builder.node("input", {
        id: "qtdNotas_" + index,
        name: "qtdNotas_" + index,
        value: 0,
        style: estiloTextRight,
        type: "hidden"
    });

    var _trCabecalhoNota = Builder.node("tr", {
        className: classe
    });

    _tdAdd.appendChild(_imgAdd);
    _tdAdd.appendChild(_inpQtdNotas);


    _trCabecalhoNota.appendChild(_tdAdd);
    _trCabecalhoNota.appendChild(_tdShow);
    _trCabecalhoNota.appendChild(_tdNumero);
    _trCabecalhoNota.appendChild(_tdSerie);
    _trCabecalhoNota.appendChild(_tdEmissao);
    _trCabecalhoNota.appendChild(_tdValor);
    _trCabecalhoNota.appendChild(_tdPeso);
    _trCabecalhoNota.appendChild(_tdVolume);
    _trCabecalhoNota.appendChild(_tdEmpalagem);
    _trCabecalhoNota.appendChild(_tdConteudo);
    _trCabecalhoNota.appendChild(_tdBcIcm);
    _trCabecalhoNota.appendChild(_tdVlIcm);
    _trCabecalhoNota.appendChild(_tdImcSt);
    _trCabecalhoNota.appendChild(_tdPedido);
    _trCabecalhoNota.appendChild(_tdTpDoc);

    tabela.appendChild(_trCabecalhoNota);

}

function contaAddNfs(indice) {
    if (indice !== null && indice !== undefined) {

        var qtd = jQuery("#qtdNotas_" + indice).val();
        jQuery("#conNf" + "_" + indice).text(qtd);

    }

}

function contaRemovNfs(indice) {
    if (indice !== null && indice !== undefined) {

        var qtd = jQuery("#qtdNotas_" + indice).val();
        qtd--;
        jQuery("#qtdNotas_" + indice).val(qtd);
        console.log("QTD: " + qtd);
        jQuery("#conNf" + "_" + indice).text(qtd);
    }

}

function addConhecimentoLoteNotasFiscaisConteudo(nota, indexCtrc, classe, serieDefault, isFocus, travaCamposImportacao) {
    isFocus = (isFocus == null || isFocus == undefined ? false : isFocus);

    if (nota == null) {
        nota = new NotaFiscal();
    }
    classe = (classe == null || classe == undefined || classe == "" ? ((indexCtrc % 2) != 0 ? 'CelulaZebra2NoAlign' : 'CelulaZebra1NoAlign') : classe);
    var prex = "nota";
    var tabela = $("tBodyNotaFiscal_" + indexCtrc);
    var index = parseInt($("qtdNotas_" + indexCtrc).value, 10) + 1;

    var callCalcularTotais = "calcularTotaisNF(" + indexCtrc + ");";
    var callRemoverNota = "removerNota(this);";
    var callShowAdicionais = "showAddConhecimentoNotaAdicionais(this);";

    var _trNotaConteudo = Builder.node("tr", {
        className: classe,
        id: "notaConteudo_" + indexCtrc + "_" + index
    });
    var _imgRemove = Builder.node("img", {
        src: "img/lixo.png",
        id: "removerNota_" + indexCtrc + "_" + index,
        className: "imagemLinkSpc",
        border: "0",
        onClick: callRemoverNota+"alteraTipoTaxa('S','"+indexCtrc+"')",
        title: "Excluir do conhecimento Nota  "
    });
    var _imgShow = Builder.node("img", {
        src: "img/plus.jpg",
        id: "addShow_" + indexCtrc + "_" + index,
        className: "imagemLinkSpc",
        border: "0",
        onClick: callShowAdicionais,
        title: "Abrir Informações Adicionais da Nota Fiscal "
    });

    var _tdRemover = Builder.node("td");
    var _tdShow = Builder.node("td", {
        align: "center"
    });
    var _tdNumero = Builder.node("td");
    var _tdSerie = Builder.node("td");
    var _tdEmissao = Builder.node("td");
    var _tdValor = Builder.node("td");
    var _tdPeso = Builder.node("td");
    var _tdVolume = Builder.node("td");
    var _tdEmpalagem = Builder.node("td");
    var _tdConteudo = Builder.node("td");
    var _tdBcIcm = Builder.node("td");
    var _tdVlIcm = Builder.node("td");
    var _tdImcSt = Builder.node("td");
    var _tdPedido = Builder.node("td");
    var _tdTipoDoc = Builder.node("td");



    var _inpId = Builder.node("input", {
        id: prex + "Id_" + indexCtrc + "_" + index,
        name: prex + "Id_" + indexCtrc + "_" + index,
        type: "hidden",
        className: estiloMin,
        size: 6,
        maxlength: maxLengtDefault,
        value: nota.id
    });
    var _inpAdValorem = Builder.node("input", {
        id: prex + "AdValorem_" + indexCtrc + "_" + index,
        name: prex + "AdValorem_" + indexCtrc + "_" + index,
        type: "hidden",
        className: estiloMin,
        size: 6,
        maxlength: maxLengtDefault,
        value: nota.adValorem
    });
    var _inpValorSeguro = Builder.node("input", {
        id: prex + "ValorSeguro_" + indexCtrc + "_" + index,
        name: prex + "ValorSeguro_" + indexCtrc + "_" + index,
        type: "hidden",
        className: estiloMin,
        size: 6,
        maxlength: maxLengtDefault,
        value: nota.valorSeguro
    });
    var _inpValorFretePeso = Builder.node("input", {
        id: prex + "ValorFretePeso_" + indexCtrc + "_" + index,
        name: prex + "ValorFretePeso_" + indexCtrc + "_" + index,
        type: "hidden",
        className: estiloMin,
        size: 6,
        maxlength: maxLengtDefault,
        value: nota.valorFretePeso
    });
    var _inpValorTotalTaxas = Builder.node("input", {
        id: prex + "ValorTotalTaxas_" + indexCtrc + "_" + index,
        name: prex + "ValorTotalTaxas_" + indexCtrc + "_" + index,
        type: "hidden",
        className: estiloMin,
        size: 6,
        maxlength: maxLengtDefault,
        value: nota.valorTotalTaxas
    });
    var _inpValorGris = Builder.node("input", {
        id: prex + "ValorGris_" + indexCtrc + "_" + index,
        name: prex + "ValorGris_" + indexCtrc + "_" + index,
        type: "hidden",
        className: estiloMin,
        size: 6,
        maxlength: maxLengtDefault,
        value: nota.valorGris
    });
    var _inpValorPedagio = Builder.node("input", {
        id: prex + "ValorPedagio_" + indexCtrc + "_" + index,
        name: prex + "ValorPedagio_" + indexCtrc + "_" + index,
        type: "hidden",
        className: estiloMin,
        size: 6,
        maxlength: maxLengtDefault,
        value: nota.valorPedagio
    });
    var _inpExiste = Builder.node("input", {
        id: prex + "Existe_" + indexCtrc + "_" + index,
        name: prex + "Existe_" + indexCtrc + "_" + index,
        type: "hidden",
        value: nota.isExiste
    });
    var _inpQtdCubagens = Builder.node("input", {
        id: "qtdCubagens_" + indexCtrc + "_" + index,
        name: "qtdCubagens_" + indexCtrc + "_" + index,
        type: "hidden",
        value: "0"
    });
    var _inpQtdMercadorias = Builder.node("input", {
        id: "qtdMercadorias_" + indexCtrc + "_" + index,
        name: "qtdMercadorias_" + indexCtrc + "_" + index,
        type: "hidden",
        value: "0"
    });
    var _inpNumero = Builder.node("input", {
        id: prex + "Numero_" + indexCtrc + "_" + index,
        name: prex + "Numero_" + indexCtrc + "_" + index,
        type: "text",
        key: indexCtrc,
        onblur: callVerificarNota,
        className: estiloMin,
        size: 8,
        maxlength: maxLengtDefault,
        value: nota.numero,
        onKeyPress: callMascaraSoNumeros
    });
    var _inpNfId = Builder.node("input", {
        id: prex + "Id_" + indexCtrc + "_" + index,
        name: prex + "Id_" + indexCtrc + "_" + index,
        type: "hidden",
        className: estiloMin,
        size: 8,
        maxlength: maxLengtDefault,
        value: nota.id,
        onKeyPress: callMascaraSoNumeros
    });
    var _inpCargaId = Builder.node("input", {
        id: prex + "CargaId_" + indexCtrc + "_" + index,
        name: prex + "CargaId_" + indexCtrc + "_" + index,
        type: "hidden",
        value: nota.cargaId
    });



    var _inpTipoCte = Builder.node("input", {
        id: prex + "TipoCte_" + indexCtrc + "_" + index,
        name: prex + "TipoCte_" + indexCtrc + "_" + index,
        type: "hidden",
        value: nota.tipoConhecimento
    });

    var _inpSerie = Builder.node("input", {
        id: prex + "Serie_" + indexCtrc + "_" + index,
        name: prex + "Serie_" + indexCtrc + "_" + index,
        type: "text",
        className: estiloMin,
        size: 3,
        maxlength: maxLengtDefault,
        value: (nota.serie == "" ? serieDefault : nota.serie)
    });
    var _inpDataEmissao = Builder.node("input", {
        id: prex + "DataEmissao_" + indexCtrc + "_" + index,
        name: prex + "DataEmissao_" + indexCtrc + "_" + index,
        type: "text",
        className: "fieldDateMin",
        maxlength: 10,
        onkeypress: callFmtData,
        size: 9,
        value: nota.dataEmissao == "" ? dataAtual : nota.dataEmissao
    });
    var _inpValor = Builder.node("input", {
        id: prex + "Valor_" + indexCtrc + "_" + index,
        name: prex + "Valor_" + indexCtrc + "_" + index,
        type: "text",
        className: estiloMin,
        size: 8,
        style: estiloTextRight,
        maxLengt: 15,
        onKeyPress: callMascaraReais,
        onblur: callCalcularTotais,
        value: colocarVirgula(nota.valor)
    });
    var _inpPeso = Builder.node("input", {
        id: prex + "Peso_" + indexCtrc + "_" + index,
        name: prex + "Peso_" + indexCtrc + "_" + index,
        type: "text",
        className: estiloMin,
        size: 7,
        style: estiloTextRight,
        onKeyPress: "mascara(this, reais, 3);",
        onblur: callCalcularTotais,
        maxlength: 12,
        value: colocarVirgula(nota.peso, 3)
    });
    var _inpVolume = Builder.node("input", {
        id: prex + "Volume_" + indexCtrc + "_" + index,
        name: prex + "Volume_" + indexCtrc + "_" + index,
        type: "text",
        style: estiloTextRight,
        className: estiloMin,
        size: 6,
        onKeyPress: "mascara(this, reais, 4);",
        onblur: callCalcularTotais,
        maxlength: 15,
        value: colocarVirgula(nota.volume, 4)
    });

    var _inpEmbalagem = Builder.node("input", {
        id: prex + "Embalagem_" + indexCtrc + "_" + index,
        name: prex + "Embalagem_" + indexCtrc + "_" + index,
        type: "text",
        className: estiloMin,
        size: 12,
        maxlength: 16,
        value: nota.embalagem
    });
    var _inpConteudo = Builder.node("input", {
        id: prex + "Conteudo_" + indexCtrc + "_" + index,
        name: prex + "Conteudo_" + indexCtrc + "_" + index,
        type: "text",
        className: estiloMin,
        size: 16,
        maxlength: 20,
        value: nota.conteudo
    });
    var _inpBCIcms = Builder.node("input", {
        id: prex + "BaseCalcIcms_" + indexCtrc + "_" + index,
        name: prex + "BaseCalcIcms_" + indexCtrc + "_" + index,
        type: "text",
        className: estiloMin,
        onKeyPress: callMascaraReais,
        size: 8,
        style: estiloTextRight,
        maxlength: 15,
        value: colocarVirgula(nota.baseCalculoIcm)
    });
    var _inpValorIcms = Builder.node("input", {
        id: prex + "ValorIcms_" + indexCtrc + "_" + index,
        name: prex + "ValorIcms_" + indexCtrc + "_" + index,
        type: "text",
        className: estiloMin,
        onKeyPress: callMascaraReais,
        size: 6,
        style: estiloTextRight,
        maxlength: maxLengtDefault,
        value: colocarVirgula(nota.icmsValor)
    });
    var _inpIcmsT = Builder.node("input", {
        id: prex + "ValorIcmsST_" + indexCtrc + "_" + index,
        name: prex + "ValorIcmsST_" + indexCtrc + "_" + index,
        type: "text",
        style: estiloTextRight,
        className: estiloMin,
        size: 6,
        maxlength: maxLengtDefault,
        value: colocarVirgula(nota.icmsST)
    });
    var _inpPedido = Builder.node("input", {
        id: prex + "Pedido_" + indexCtrc + "_" + index,
        name: prex + "Pedido_" + indexCtrc + "_" + index,
        type: "text",
        className: estiloMin,
        size: 7,
        maxlength: 15,
        value: nota.pedido
    });
    var _inpTipoDocum = Builder.node("select", {
        id: prex + "TipoDocum_" + indexCtrc + "_" + index,
        name: prex + "TipoDocum_" + indexCtrc + "_" + index,
        type: "text",
        className: estiloMin
    });

    povoarSelect(_inpTipoDocum, listaTipoDocNf);
    if (nota.tipoDocumento != "") {
        _inpTipoDocum.value = nota.tipoDocumento;
    }

    if ($("tipoDocumentoPadraoRemetente_" + indexCtrc) != undefined) {
        _inpTipoDocum.value = $("tipoDocumentoPadraoRemetente_" + indexCtrc).value;
    }

    var _inpTipoDocumGamb = Builder.node("input", {
        id: prex + "TipoDocumGamb_" + indexCtrc + "_" + index,
        name: prex + "TipoDocumGamb_" + indexCtrc + "_" + index,
        type: "hidden",
        className: estiloMin
    });

    /**
     * var _inpAdValorem = Builder.node("input", {
     id :prex+"AdValorem_"+indexCtrc+"_"+index, 
     name :prex+"AdValorem_"+indexCtrc+"_"+index, 
     type : "hidden" ,
     className: estiloMin,
     size: 6 ,
     maxlength: maxLengtDefault,
     value : nota.adValorem
     });    
     var _inpValorSeguro = Builder.node("input", {
     id :prex+"ValorSeguro_"+indexCtrc+"_"+index, 
     name :prex+"ValorSeguro_"+indexCtrc+"_"+index, 
     type : "hidden" ,
     className: estiloMin,
     size: 6 ,
     maxlength: maxLengtDefault,
     value : nota.valorSeguro
     });    
     var _inpValorFretePeso = Builder.node("input", {
     id :prex+"ValorFretePeso_"+indexCtrc+"_"+index, 
     name :prex+"ValorFretePeso_"+indexCtrc+"_"+index, 
     type : "hidden" ,
     className: estiloMin,
     size: 6 ,
     maxlength: maxLengtDefault,
     value : nota.valorFretePeso
     });    
     var _inpValorTotalTaxas = Builder.node("input", {
     id :prex+"ValorTotalTaxas"+indexCtrc+"_"+index, 
     name :prex+"ValorTotalTaxas_"+indexCtrc+"_"+index, 
     type : "hidden" ,
     className: estiloMin,
     size: 6 ,
     maxlength: maxLengtDefault,
     value : nota.valorTotalTaxas
     }); 
     *
     **/

    _tdRemover.appendChild(_imgRemove);
    _tdShow.appendChild(_imgShow);
    _tdNumero.appendChild(_inpId);
    _tdNumero.appendChild(_inpAdValorem);
    _tdNumero.appendChild(_inpValorSeguro);
    _tdNumero.appendChild(_inpValorFretePeso);
    _tdNumero.appendChild(_inpValorTotalTaxas);
    _tdNumero.appendChild(_inpValorGris);
    _tdNumero.appendChild(_inpValorPedagio);
    _tdNumero.appendChild(_inpExiste);
    _tdNumero.appendChild(_inpQtdCubagens);
    _tdNumero.appendChild(_inpQtdMercadorias);
    _tdNumero.appendChild(_inpNumero);
    _tdNumero.appendChild(_inpNfId);
    _tdNumero.appendChild(_inpCargaId);
    _tdNumero.appendChild(_inpTipoCte);
    _tdSerie.appendChild(_inpSerie);
    _tdEmissao.appendChild(_inpDataEmissao);
    _tdValor.appendChild(_inpValor);
    _tdPeso.appendChild(_inpPeso);
    _tdVolume.appendChild(_inpVolume);
    _tdEmpalagem.appendChild(_inpEmbalagem);
    _tdConteudo.appendChild(_inpConteudo);
    _tdBcIcm.appendChild(_inpBCIcms);
    _tdVlIcm.appendChild(_inpValorIcms);
    _tdImcSt.appendChild(_inpIcmsT);
    _tdPedido.appendChild(_inpPedido);
    _tdTipoDoc.appendChild(_inpTipoDocum);
    _tdTipoDoc.appendChild(_inpTipoDocumGamb);

    _trNotaConteudo.appendChild(_tdRemover);
    _trNotaConteudo.appendChild(_tdShow);
    _trNotaConteudo.appendChild(_tdNumero);
    _trNotaConteudo.appendChild(_tdSerie);
    _trNotaConteudo.appendChild(_tdEmissao);
    _trNotaConteudo.appendChild(_tdValor);
    _trNotaConteudo.appendChild(_tdPeso);
    _trNotaConteudo.appendChild(_tdVolume);
    _trNotaConteudo.appendChild(_tdEmpalagem);
    _trNotaConteudo.appendChild(_tdConteudo);
    _trNotaConteudo.appendChild(_tdBcIcm);
    _trNotaConteudo.appendChild(_tdVlIcm);
    _trNotaConteudo.appendChild(_tdImcSt);
    _trNotaConteudo.appendChild(_tdPedido);
    _trNotaConteudo.appendChild(_tdTipoDoc);

    $("qtdNotas_" + indexCtrc).value = index;
    tabela.appendChild(_trNotaConteudo);

    var _trNotaAdicionais = Builder.node("tr", {
        id: "trNotaAdicionais_" + indexCtrc + "_" + index
    });
    var _tdNotaAdicionais = Builder.node("td", {
        width: "100%",
        colSpan: "15",
        id: "tdNotaAdicionais_" + indexCtrc + "_" + index
    });
    var _tableNotaAdicionais = Builder.node("table", {
        width: "100%",
        className: "bordaFina",
        id: "tableNotaAdicionais_" + indexCtrc + "_" + index
    });
    var _tBodyNotaAdicionais = Builder.node("tbody", {
        id: "tbodyNotaAdicionais_" + indexCtrc + "_" + index
    });
    if (isFocus) {
        _inpNumero.focus();
    }
    invisivel(_trNotaAdicionais);
    //deixando campos readOnly    
    if (travaCamposImportacao === 'true') {
        readOnly(_inpNumero, estiloMinReadOnly);
        readOnly(_inpDataEmissao, estiloMinReadOnly);
        readOnly(_inpSerie, estiloMinReadOnly);
        //@Tag LojasAmericanas
        //Validação só para o layout das lojas americanas por enquanto.        
        //if (!nota.isDesbloqueoValores) {
        readOnly(_inpPeso, estiloMinReadOnly);
        //comentei a linha porque na rotina da Ricardo eletro a importações que os valores vem zerado historia 2162 
//            readOnly(_inpValor, estiloMinReadOnly);
        readOnly(_inpVolume, estiloMinReadOnly);
        readOnly(_inpVolume, estiloMinReadOnly);
        //}

        readOnly(_inpValor, estiloMinReadOnly);
    }

    _tableNotaAdicionais.appendChild(_tBodyNotaAdicionais)
    _tdNotaAdicionais.appendChild(_tableNotaAdicionais)
    _trNotaAdicionais.appendChild(_tdNotaAdicionais)
    tabela.appendChild(_trNotaAdicionais);
    var isPrimeiraCubagem = true;
    addConhecimentoLoteNotasFiscaisConteudoAdicional(nota, indexCtrc, index, classe, _tBodyNotaAdicionais, travaCamposImportacao);
    if (nota.listaCuabagem != null && nota.listaCuabagem.size() != 0) {
        for (i = 0; i < nota.listaCuabagem.size(); i++) {
            if (nota.listaCuabagem[i] != null) {
                if (!nota.listaCuabagem[i].existe) {
                    setErroCtrc(indexCtrc, "Possui mercadoria que não consta na base de dados ou a cubagem esta zerada!\n");
                    //                    $("mensagemErro_"+ indexCtrc).innerHTML += "Possui mercadoria que não consta na base de dados ou a cubagem esta zerada!\n";
                    //                    $("mensagemErro_"+ indexCtrc).className = styleErro;
                    //                    $("alertaErro_"+ indexCtrc).className = styleErro;
                    //                    $("alertaErro_"+ indexCtrc).title = $("mensagemErro_"+ indexCtrc).innerHTML;
                    //                    visivel($("alertaErro_"+ indexCtrc));
                    //                    $("mensagemErro_"+ indexCtrc).value = "Possui mercadoria que não consta na base de dados ou encontra-se sem cubagem!";
                }
                addConhecimentoLoteNotasCubagens(nota.listaCuabagem[i], classe, indexCtrc, index, isPrimeiraCubagem);
                isPrimeiraCubagem = false;
            }
        }
    } else {
        var cub = new Cubabem();
        cub.volume = nota.volume;
        cub.metroCubico = nota.metroCubico;
        cub.etiqueta = nota.codigoBarras;
        addConhecimentoLoteNotasCubagens(cub, classe, indexCtrc, index, true);
    }
    //Adicionando as mercadorias
    var merc = null;
    if (nota.listaMercadoria != null && nota.listaMercadoria.size() != 0) {
        for (i = 0; i < nota.listaMercadoria.size(); i++) {
            merc = nota.listaMercadoria[i];
            if (merc != null) {
                if (merc.produtoId == 0 && merc.quantidade > 0) {
                    setErroCtrc(indexCtrc, "Produto '" + merc.produto + "' não esta cadastrado!\n");
                    //                    $("mensagemErro_"+ indexCtrc).innerHTML += "Produto '"+merc.produto+"' não esta cadastrado!\n";
                    //                    $("mensagemErro_"+ indexCtrc).className = styleErro;
                    //                    $("alertaErro_"+ indexCtrc).className = styleErro;
                    //                    $("alertaErro_"+ indexCtrc).title = $("mensagemErro_"+ indexCtrc).innerHTML;
                    //                    visivel($("alertaErro_"+ indexCtrc));
                }
                addConhecimentoLoteNotasMercadorias(nota.listaMercadoria[i], classe, indexCtrc, index);
            }
        }
    }
    calcularTotaisNF(indexCtrc);
    if (nota.isExiste) {

        setErroCtrc(indexCtrc, " A NF '" + nota.numero + "' já foi importada! \n");
        //        $("mensagemErro_"+ indexCtrc).innerHTML += " A NF '"+nota.numero+"' já foi importada!\n";
        //        $("mensagemErro_"+ indexCtrc).className = styleErro;
        //        $("alertaErro_"+ indexCtrc).className = styleErro;
        //        $("alertaErro_"+ indexCtrc).title = $("mensagemErro_"+ indexCtrc).innerHTML;
        //        visivel($("alertaErro_"+ indexCtrc));
    }
    // conta as notas adiciondas.
    atualizarContatorNFe(indexCtrc);
}
function addConhecimentoLoteNotasFiscaisConteudoAdicional(nota, indexCtrc, index, classe, tabela, travaCamposImportacao) {
    if (nota == null) {
        nota = new NotaFiscal();
    }
    var callAbrirLocalizarCFOP = "abrirLocalizarCFOPNota('" + indexCtrc + "_" + index + "');";
    var callAbrirLocalizarDestinatarioNota = "abrirLocalizarDestinatarioNota('" + indexCtrc + "_" + index + "');";

    var _trNotaAdicionaisCubagem = Builder.node("tr");
    var _tdNotaAdicionaisCubagem = Builder.node("td", {
        width: "100%",
        colSpan: "10",
        className: "tabela"
    }, "Cubagens");
    _trNotaAdicionaisCubagem.appendChild(_tdNotaAdicionaisCubagem);

    var _trNotaAdicionaisCubagemPai = Builder.node("tr", {
        id: "trNotaAdicionaisCubagemPai_" + indexCtrc + "_" + index
    });
    var _tdNotaAdicionaisCubagemPai = Builder.node("td", {
        width: "100%",
        colSpan: "10"
    });
    var _tableNotaAdicionaisCubagem = Builder.node("table", {
        width: "100%",
        className: "bordaFina"
    });
    var _tbodyNotaAdicionaisCubagem = Builder.node("tbody", {
        id: "tbodyNotaAdicionaisCubagens_" + indexCtrc + "_" + index
    });

    var _trNotaAdicionaisMercadoria = Builder.node("tr");
    var _tdNotaAdicionaisMercadoria = Builder.node("td", {
        width: "100%",
        colSpan: "10",
        className: "tabela"
    }, "Mercadorias");
    _trNotaAdicionaisMercadoria.appendChild(_tdNotaAdicionaisMercadoria);

    var _trNotaAdicionaisMercadoriaPai = Builder.node("tr", {
        id: "trNotaAdicionaisMercadoriaPai_" + indexCtrc + "_" + index
    });
    var _tdNotaAdicionaisMercadoriaPai = Builder.node("td", {
        width: "100%",
        colSpan: "10"
    });
    var _tableNotaAdicionaisMercadoria = Builder.node("table", {
        width: "100%",
        className: "bordaFina"
    });
    var _tbodyNotaAdicionaisMercadoria = Builder.node("tbody", {
        id: "tbodyNotaAdicionaisMercadoria_" + indexCtrc + "_" + index
    });

    var _trNotaAdicionaisLinha1 = Builder.node("tr", {
        className: classe,
        id: "trNotaAdicionaisLinha1_" + indexCtrc + "_" + index
    });
    var _trNotaAdicionaisLinhaAgendamento1 = Builder.node("tr", {
        className: classe,
        id: "trNotaAdicionaisLinhaAgendamento1_" + indexCtrc + "_" + index
    });
    var _trNotaAdicionaisLinhaAgendamento2 = Builder.node("tr", {
        className: classe,
        id: "trNotaAdicionaisLinhaAgendamento2_" + indexCtrc + "_" + index
    });
    var _trNotaAdicionaisLinhaDestinatario = Builder.node("tr", {
        className: classe,
        id: "trNotaAdicionaisLinhaPrevisao_" + indexCtrc + "_" + index
    });
    var _trNotaAdicionaisLinhaVeiculo = Builder.node("tr", {
        className: classe,
        id: "trNotaAdicionaisLinhaVeiculo_" + indexCtrc + "_" + index
    });
    var _trNotaAdicionaisLinhaVeiculoNovo = Builder.node("tr", {
        className: classe,
        id: "trNotaAdicionaisLinhaVeiculoNovo_" + indexCtrc + "_" + index
    });
    var _tdNotaCfopDesc = Builder.node("td", {
        //        width: "10%",
        align: "right",
        id: "tdNotaCfopDesc_" + indexCtrc + "_" + index
    });
    var _tdNotaCfopValor = Builder.node("td", {
        //        width: "10%",
        align: "left",
        id: "tdNotaCfopValor_" + indexCtrc + "_" + index
    });
    var _tdNotaChaveAcessoDesc = Builder.node("td", {
        align: "right",
        //        width: "10%",
        id: "tdNotaChaveAcessoDesc_" + indexCtrc + "_" + index
    });
    var _tdNotaChaveAcessoValor = Builder.node("td", {
        //        width: "30%",
        align: "left",
        colSpan: "3",
        id: "tdNotaChaveAcessoValor_" + indexCtrc + "_" + index
    });
    var _tdNotaImportacaoEDIDesc = Builder.node("td", {
        //        width: "30%",
        align: "right",
        colSpan: "3",
        id: "tdNotaImportacaoEDIDesc_" + indexCtrc + "_" + index
    });
    var _tdNotaImportacaoEDIValor = Builder.node("td", {
        //        width: "10%",
        align: "left",
        id: "tdNotaImportacaoEDIValor_" + indexCtrc + "_" + index
    });
    var _tdNotaAgendadoValor = Builder.node("td", {
        //        width: "20%",
        colSpan: "2",
        id: "tdNotaAgendadoValor_" + indexCtrc + "_" + index
    });
    var _tdNotaDataAgendaDesc = Builder.node("td", {
        //        width: "10%",
        align: "right",
        id: "tdNotaDataAgendaDesc_" + indexCtrc + "_" + index
    });
    var _tdNotaDataAgendaValor = Builder.node("td", {
        //        width: "10%",
        align: "left",
        id: "tdNotaDataAgendaValor_" + indexCtrc + "_" + index
    });
    var _tdNotaHoraAgendaDesc = Builder.node("td", {
        //        width: "10%",
        align: "right",
        id: "tdNotaHoraAgendaDesc_" + indexCtrc + "_" + index
    });
    var _tdNotaHoraAgendaValor = Builder.node("td", {
        //        width: "10%",
        align: "left",
        id: "tdNotaHoraAgendaValor_" + indexCtrc + "_" + index
    });
    var _tdNotaObsAgendaDesc = Builder.node("td", {
        align: "right",
        id: "tdNotaObsAgendaValor_" + indexCtrc + "_" + index
    });
    var _tdNotaObsAgendaValor = Builder.node("td", {
        align: "left",
        colSpan: "9",
        id: "tdNotaObsAgendaValor_" + indexCtrc + "_" + index
    });
    var _tdNotaPrevisaoDesc = Builder.node("td", {
        //        align: "right",
        width: "10%",
        id: "tdNotaPrevisaoDesc_" + indexCtrc + "_" + index
    });
    var _tdNotaPrevisaoValor = Builder.node("td", {
        align: "left",
        //        width: "30%",
        colSpan: "3",
        id: "tdNotaPrevisaoValor_" + indexCtrc + "_" + index
    });
    var _tdNotaDestinatarioDesc = Builder.node("td", {
        align: "right",
        //        width: "10%",
        id: "tdNotaDestinatarioDesc_" + indexCtrc + "_" + index
    });
    var _tdNotaDestinatarioValor = Builder.node("td", {
        align: "left",
        colSpan: "3",
        //        width: "30%",
        id: "tdNotaDestinatarioValor_" + indexCtrc + "_" + index
    });
    var _tdNotaMarcaDesc = Builder.node("td", {
        align: "right",
        width: "10%",
        id: "tdNotaMarcaDesc_" + indexCtrc + "_" + index
    });
    var _tdNotaMarcaValor = Builder.node("td", {
        align: "left",
        width: "10%",
        id: "tdNotaMarcaValor_" + indexCtrc + "_" + index
    });
    var _tdNotaModeloDesc = Builder.node("td", {
        align: "right",
        width: "10%",
        id: "tdNotaModeloDesc_" + indexCtrc + "_" + index
    });
    var _tdNotaModeloValor = Builder.node("td", {
        align: "left",
        width: "16%",
        id: "tdNotaModeloValor_" + indexCtrc + "_" + index
    });
    var _tdNotaAnoDesc = Builder.node("td", {
        align: "right",
        width: "6%",
        id: "tdNotaAnoDesc_" + indexCtrc + "_" + index
    });
    var _tdNotaAnoValor = Builder.node("td", {
        align: "left",
        width: "8%",
        id: "tdNotaAnoValor_" + indexCtrc + "_" + index
    });
    var _tdNotaCorDesc = Builder.node("td", {
        align: "right",
        width: "10%",
        id: "tdNotaCorDesc_" + indexCtrc + "_" + index
    });
    var _tdNotaCorValor = Builder.node("td", {
        align: "left",
        width: "10%",
        id: "tdNotaCorValor_" + indexCtrc + "_" + index
    });
    var _tdNotaChassiDesc = Builder.node("td", {
        align: "right",
        id: "tdNotaChassiDesc_" + indexCtrc + "_" + index,
        width: "10%"
    });
    var _tdNotaChassiValor = Builder.node("td", {
        align: "left",
        width: "10%",
        id: "tdNotaChassiValor_" + indexCtrc + "_" + index
    });

    //veiculo novo    
    var _tdNotaVeiculoPlacaDesc = Builder.node("td", {
        align: "right",
        width: "10%",
        id: "tdNotaVeiculoPlaca_" + indexCtrc + "_" + index
    });

    var _tdNotaVeiculoPlacaValor = Builder.node("td", {
        align: "right",
        width: "10%",
        id: "tdNotaVeiculoPlacaValor_" + indexCtrc + "_" + index
    });

    var _tdNotaVeiculoNovoDesc = Builder.node("td", {
        align: "right",
        width: "10%",
        id: "tdNotaVeiculoNovoDesc_" + indexCtrc + "_" + index
    });
    var _tdNotaVeiculoNovoValor = Builder.node("td", {
        align: "right",
        width: "10%",
        id: "tdNotaVeiculoNovoValor_" + indexCtrc + "_" + index
    });
    var _tdNotaVeiculoCorFabDesc = Builder.node("td", {
        align: "right",
        width: "10%",
        id: "tdNotaVeiculoCorFabDesc_" + indexCtrc + "_" + index
    });
    var _tdNotaVeiculoCorFabValor = Builder.node("td", {
        align: "right",
        width: "10%",
        id: "tdNotaVeiculoCorFabValor_" + indexCtrc + "_" + index
    });
    var _tdNotaVeiculoMarcaModeloDesc = Builder.node("td", {
        align: "right",
        width: "10%",
        id: "tdNotaVeiculoMarcaModeloDesc_" + indexCtrc + "_" + index
    });
    var _tdNotaVeiculoMarcaModeloValor = Builder.node("td", {
        align: "right",
        width: "10%",
        id: "tdNotaVeiculoMarcaModeloValor_" + indexCtrc + "_" + index
    });
    var _tdNotaVeiculoBlanc = Builder.node("td", {
        align: "right",
        colspan: "2",
        id: "_tdNotaVeiculoBlanc" + indexCtrc + "_" + index
    });


    //label's
    var _labelCfop = Builder.node("label", {}, 'CFOP:');
    var _labelChaveNFe = Builder.node("label", {}, 'Chave NF-e:');
    var _labelPedidoCarga = Builder.node("label", {}, 'Pedido/Carga:');
    var _labelAgendado = Builder.node("label", {}, 'Agendado');
    var _labelImportacaoEDI = Builder.node("label", {}, 'Nota Fiscal importada via EDI:');
    var _labelSIM = Builder.node("label", {}, 'SIM');
    var _labelNAO = Builder.node("label", {}, 'Não');
    var _labelDataAgenda = Builder.node("label", {}, 'Data:');
    var _labelHoraAgenda = Builder.node("label", {}, 'Hora:');
    var _labelObsAgenda = Builder.node("label", {}, 'Observação:');
    var _labelPrevisao = Builder.node("label", {}, 'Previsão:');
    var _labelAs = Builder.node("label", {}, ' às ');
    var _labelDestinatario = Builder.node("label", {}, 'Destinatário:');
    var _labelMarca = Builder.node("label", {}, 'Marca:');
    var _labelModelo = Builder.node("label", {}, 'Modelo:');
    var _labelAno = Builder.node("label", {}, 'Ano:');
    var _labelCor = Builder.node("label", {}, 'Cor:');
    var _labelChassi = Builder.node("label", {}, 'Chassi:');
    var _negritoImport = Builder.node("b");


    //veiculo Novo

    var _labelVeiculoPlaca = Builder.node("label", {}, 'Placa:');
    var _labelVeiculoNovo = Builder.node("label", {}, 'Veículo Novo:');
    var _labelVeiculoCorFab = Builder.node("label", {}, 'Cor Fabricante:');
    var _labelVeiculoMarcaModelo = Builder.node("label", {}, 'Marca/Modelo:');

    //input's
    var _inpNotaCfop = Builder.node("input", {
        id: "notaCfop_" + indexCtrc + "_" + index,
        name: "notaCfop_" + indexCtrc + "_" + index,
        type: "text",
        className: estiloMin,
        size: "4",
        maxlength: "5",
        value: nota.cfop
    });
    readOnly(_inpNotaCfop, estiloMinReadOnly);
    var _inpNotaCfopId = Builder.node("input", {
        id: "notaCfopId_" + indexCtrc + "_" + index,
        name: "notaCfopId_" + indexCtrc + "_" + index,
        type: "hidden",
        className: estiloMin,
        value: nota.cfopId
    });
    var _botLocCFOP = Builder.node("input", {
        id: "botCFOP_" + indexCtrc + "_" + index,
        type: "button",
        value: "...",
        className: "inputBotaoMin",
        onClick: callAbrirLocalizarCFOP
    });
    var _inpNotaChaveAcesso = Builder.node("input", {
        id: "notaChaveNFe_" + indexCtrc + "_" + index,
        name: "notaChaveNFe_" + indexCtrc + "_" + index,
        type: "text",
        className: estiloMin,
        size: "55",
        value: nota.chaveNFe
    });
    var _inpNotaPedidoCarga = Builder.node("input", {
        id: "notaPedidoCarga_" + indexCtrc + "_" + index,
        name: "ntoaPedidoCarga_" + indexCtrc + "_" + index,
        type: "text",
        className: estiloMin,
        maxlength: maxLengtDefault,
        size: sizeDefault,
        value: nota.pedido
    });
    var _inpNotaAtendido = Builder.node("input", {
        id: "isNotaAtendido_" + indexCtrc + "_" + index,
        name: "isNotaAtendido_" + indexCtrc + "_" + index,
        type: "checkbox"
    });
    _inpNotaAtendido.checked = nota.isAgendado;

    var _inpNotaIsImportacaoEDI = Builder.node("input", {
        id: "isNotaImportacaoEDI_" + indexCtrc + "_" + index,
        name: "isNotaImportacaoEDI_" + indexCtrc + "_" + index,
        type: "hidden",
        value: nota.isImportacaoEDI
    });

    var _inpNotaDataAgendamento = Builder.node("input", {
        id: "notaDataAgendamento_" + indexCtrc + "_" + index,
        name: "notaDataAgendamento_" + indexCtrc + "_" + index,
        type: "text",
        className: estiloData,
        size: "8",
        value: nota.dataAgenda,
        maxlength: "10",
        onkeypress: callFmtData
    });
    var _inpNotaHoraAgendamento = Builder.node("input", {
        id: "notaHoraAgendamento_" + indexCtrc + "_" + index,
        name: "notaHoraAgendamento_" + indexCtrc + "_" + index,
        type: "text",
        className: estiloMin,
        size: "10",
        value: nota.horaAgenda,
        onkeypress: callFormatarHora
    });
    var _inpNotaDataPrevisao = Builder.node("input", {
        id: "notaDataPrevisao_" + indexCtrc + "_" + index,
        name: "notaDataPrevisao_" + indexCtrc + "_" + index,
        type: "text",
        className: estiloData,
        size: "10",
        value: nota.dataPrevisao,
        maxlength: "10",
        onkeypress: callFmtData
    });
    var _inpNotaHoraPrevisao = Builder.node("input", {
        id: "notaHoraPrevisao_" + indexCtrc + "_" + index,
        name: "notaHoraPrevisao_" + indexCtrc + "_" + index,
        type: "text",
        className: estiloMin,
        size: "10",
        value: nota.horaPrevisao,
        onkeypress: callFormatarHora
    });
    var _inpNotaObsAgendamento = Builder.node("input", {
        id: "notaObsAgendamento_" + indexCtrc + "_" + index,
        name: "notaObsAgendamento_" + indexCtrc + "_" + index,
        type: "text",
        className: estiloMin,
        size: "100",
        value: nota.observacao
    });
    var _inpNotaDestinatario = Builder.node("input", {
        id: "notaDestinatario_" + indexCtrc + "_" + index,
        name: "notaDestinatario_" + indexCtrc + "_" + index,
        type: "text",
        className: estiloMin,
        size: "50",
        value: nota.destinatario
    });
    var _botLocDestinatario = Builder.node("input", {
        id: "botDestinatario_" + indexCtrc + "_" + index,
        type: "button",
        value: "...",
        className: "inputBotaoMin",
        onClick: callAbrirLocalizarDestinatarioNota
    });
    readOnly(_inpNotaDestinatario, estiloMinReadOnly);
    var _inpNotaDestinatarioId = Builder.node("input", {
        id: "notaDestinatarioId_" + indexCtrc + "_" + index,
        name: "notaDestinatarioId_" + indexCtrc + "_" + index,
        type: "hidden",
        value: nota.destinatarioId
    });

    _tdNotaCfopDesc.appendChild(_labelCfop);
    _tdNotaCfopValor.appendChild(_inpNotaCfop);
    _tdNotaCfopValor.appendChild(_botLocCFOP);
    _tdNotaCfopValor.appendChild(_inpNotaCfopId);
    _tdNotaChaveAcessoDesc.appendChild(_labelChaveNFe);
    _tdNotaChaveAcessoValor.appendChild(_inpNotaChaveAcesso);
    _tdNotaImportacaoEDIDesc.appendChild(_labelImportacaoEDI);
    if (nota.isImportacaoEDI) {
        _negritoImport.appendChild(_labelSIM);
    } else {
        _negritoImport.appendChild(_labelNAO);
    }
    _tdNotaImportacaoEDIValor.appendChild(_negritoImport);

    _trNotaAdicionaisLinha1.appendChild(_tdNotaCfopDesc);
    _trNotaAdicionaisLinha1.appendChild(_tdNotaCfopValor);
    _trNotaAdicionaisLinha1.appendChild(_tdNotaChaveAcessoDesc);
    _trNotaAdicionaisLinha1.appendChild(_tdNotaChaveAcessoValor);
    _trNotaAdicionaisLinha1.appendChild(_tdNotaPrevisaoDesc);
    _trNotaAdicionaisLinha1.appendChild(_tdNotaPrevisaoValor);

    _tdNotaAgendadoValor.appendChild(_inpNotaAtendido);
    _tdNotaAgendadoValor.appendChild(_inpNotaIsImportacaoEDI);
    _tdNotaAgendadoValor.appendChild(_labelAgendado);
    _tdNotaDataAgendaDesc.appendChild(_labelDataAgenda);
    _tdNotaDataAgendaValor.appendChild(_inpNotaDataAgendamento);
    _tdNotaHoraAgendaDesc.appendChild(_labelHoraAgenda);
    _tdNotaHoraAgendaValor.appendChild(_inpNotaHoraAgendamento);

    _trNotaAdicionaisLinhaAgendamento1.appendChild(_tdNotaDestinatarioDesc);
    _trNotaAdicionaisLinhaAgendamento1.appendChild(_tdNotaDestinatarioValor);
    _trNotaAdicionaisLinhaAgendamento1.appendChild(_tdNotaAgendadoValor);
    _trNotaAdicionaisLinhaAgendamento1.appendChild(_tdNotaDataAgendaDesc);
    _trNotaAdicionaisLinhaAgendamento1.appendChild(_tdNotaDataAgendaValor);
    _trNotaAdicionaisLinhaAgendamento1.appendChild(_tdNotaHoraAgendaDesc);
    _trNotaAdicionaisLinhaAgendamento1.appendChild(_tdNotaHoraAgendaValor);

    _tdNotaObsAgendaDesc.appendChild(_labelObsAgenda);
    _tdNotaObsAgendaValor.appendChild(_inpNotaObsAgendamento);

    _trNotaAdicionaisLinhaAgendamento2.appendChild(_tdNotaObsAgendaDesc);
    _trNotaAdicionaisLinhaAgendamento2.appendChild(_tdNotaObsAgendaValor);

    _tdNotaPrevisaoDesc.appendChild(_labelPrevisao);
    _tdNotaPrevisaoValor.appendChild(_inpNotaDataPrevisao);
    _tdNotaPrevisaoValor.appendChild(_labelAs);
    _tdNotaPrevisaoValor.appendChild(_inpNotaHoraPrevisao);
    _tdNotaDestinatarioDesc.appendChild(_labelDestinatario);
    _tdNotaDestinatarioValor.appendChild(_inpNotaDestinatario);
    _tdNotaDestinatarioValor.appendChild(_botLocDestinatario);
    _tdNotaDestinatarioValor.appendChild(_inpNotaDestinatarioId);



    _trNotaAdicionaisLinhaVeiculo.appendChild(_tdNotaMarcaDesc);
    _trNotaAdicionaisLinhaVeiculo.appendChild(_tdNotaMarcaValor);
    _trNotaAdicionaisLinhaVeiculo.appendChild(_tdNotaModeloDesc);
    _trNotaAdicionaisLinhaVeiculo.appendChild(_tdNotaModeloValor);
    _trNotaAdicionaisLinhaVeiculo.appendChild(_tdNotaAnoDesc);
    _trNotaAdicionaisLinhaVeiculo.appendChild(_tdNotaAnoValor);
    _trNotaAdicionaisLinhaVeiculo.appendChild(_tdNotaCorDesc);
    _trNotaAdicionaisLinhaVeiculo.appendChild(_tdNotaCorValor);
    _trNotaAdicionaisLinhaVeiculo.appendChild(_tdNotaChassiDesc);
    _trNotaAdicionaisLinhaVeiculo.appendChild(_tdNotaChassiValor);

    _tdNotaVeiculoPlacaDesc.appendChild(_labelVeiculoPlaca);
    _tdNotaVeiculoNovoDesc.appendChild(_labelVeiculoNovo);
    _tdNotaVeiculoCorFabDesc.appendChild(_labelVeiculoCorFab);
    _tdNotaVeiculoMarcaModeloDesc.appendChild(_labelVeiculoMarcaModelo);

    _trNotaAdicionaisLinhaVeiculoNovo.appendChild(_tdNotaVeiculoPlacaDesc);
    _trNotaAdicionaisLinhaVeiculoNovo.appendChild(_tdNotaVeiculoPlacaValor);
    _trNotaAdicionaisLinhaVeiculoNovo.appendChild(_tdNotaVeiculoNovoDesc);
    _trNotaAdicionaisLinhaVeiculoNovo.appendChild(_tdNotaVeiculoNovoValor);
    _trNotaAdicionaisLinhaVeiculoNovo.appendChild(_tdNotaVeiculoCorFabDesc);
    _trNotaAdicionaisLinhaVeiculoNovo.appendChild(_tdNotaVeiculoCorFabValor);
    _trNotaAdicionaisLinhaVeiculoNovo.appendChild(_tdNotaVeiculoMarcaModeloDesc);
    _trNotaAdicionaisLinhaVeiculoNovo.appendChild(_tdNotaVeiculoMarcaModeloValor);
    _trNotaAdicionaisLinhaVeiculoNovo.appendChild(_tdNotaVeiculoBlanc);

    _tableNotaAdicionaisCubagem.appendChild(_tbodyNotaAdicionaisCubagem);
    _tdNotaAdicionaisCubagemPai.appendChild(_tableNotaAdicionaisCubagem);
    _trNotaAdicionaisCubagemPai.appendChild(_tdNotaAdicionaisCubagemPai);

    _tableNotaAdicionaisMercadoria.appendChild(_tbodyNotaAdicionaisMercadoria);
    _tdNotaAdicionaisMercadoriaPai.appendChild(_tableNotaAdicionaisMercadoria);
    _trNotaAdicionaisMercadoriaPai.appendChild(_tdNotaAdicionaisMercadoriaPai);

    //temporariamente escondidos
    invisivel(_trNotaAdicionaisMercadoria);
    invisivel(_trNotaAdicionaisMercadoriaPai);


    tabela.appendChild(_trNotaAdicionaisCubagem);
    tabela.appendChild(_trNotaAdicionaisCubagemPai);
    tabela.appendChild(_trNotaAdicionaisMercadoria);
    tabela.appendChild(_trNotaAdicionaisMercadoriaPai);
    tabela.appendChild(_trNotaAdicionaisLinha1);
    tabela.appendChild(_trNotaAdicionaisLinhaAgendamento1);
    tabela.appendChild(_trNotaAdicionaisLinhaAgendamento2);
    tabela.appendChild(_trNotaAdicionaisLinhaVeiculo);
    // tabela.appendChild(_trNotaAdicionaisLinhaVeiculoNovo);  //Comentado pois os campos de veiculo nao estavam sendo usados

    if (nota.isImportacaoEDI && travaCamposImportacao === 'true') {
        readOnly(_inpNotaChaveAcesso, 'inputReadOnly8pt');
        _botLocDestinatario.disabled = true;
    }
}
function addConhecimentoLoteNotasFiscaisTrTotais(index, tabela, classe, tipo, ctrc) {
    var tipos = new Array();
    tipos[0] = "TotalNF";
    tipos[1] = "TotalCF";

    var callAlteraTipoTaxa = "alteraTipoTaxa('N'," + index + " );"
    var callCalculaPesoTaxado = "calculaPesoTaxado(" + index + " );"
    var callEspelharTotalCubagem = "espelharTotalCubagem(this);"
    var calCalcularCubagemNota = "calcularCubagemNota(this);";
    var calCalcularCubagemComposicaoFrete = "calcularCubagemComposicaoFrete(this);";
    var preencheCubagemTotal = "preencheCubagemTotal(this);";
    var apelido = tipos[tipo];
    var _trTotaisNF = Builder.node("tr", {
        id: "tr" + apelido + "_" + index,
        className: classe
    });
    var _tdTotaisNF = Builder.node("td", {
        id: "td" + apelido + "_" + index,
        align: "right",

    });
    var _tdQtdNF = Builder.node("td", {
        id: "td" + apelido + "_" + index,
        align: "right"

    });

    var _tdTotaisMercadoriaDesc = Builder.node("td", {
        id: "td" + apelido + "ValorDes_" + index,
        align: "right"
    });
    var _tdTotaisMercadoriaValor = Builder.node("td", {
        id: "td" + apelido + "ValorValor_" + index,
        align: "left"
    });
    var _tdTotaisPesoDesc = Builder.node("td", {
        id: "td" + apelido + "PesoDesc_" + index,
        align: "right"
    });
    var _tdTotaisPesoValor = Builder.node("td", {
        id: "td" + apelido + "PesoValor_" + index,
        align: "left"
    });
    var _tdTotaisVolumeDesc = Builder.node("td", {
        id: "td" + apelido + "VolumeDesc_" + index,
        align: "right"
    });
    var _tdTotaisVolumeValor = Builder.node("td", {
        id: "td" + apelido + "VolumeValor_" + index,
        align: "left"
    });
    var _tdCubagem = Builder.node("td", {
        id: "td" + apelido + "Cubagem_" + index,
        align: "right"
    });
    var _tdCubagemValor = Builder.node("td", {
        id: "td" + apelido + "CubagemValor_" + index,
        align: "left"
    });
    var _tdCubagemBaseDesc = Builder.node("td", {
        id: "td" + apelido + "CubagemBaseDesc_" + index,
        align: "right"
    });
    var _tdCubagemBaseValor = Builder.node("td", {
        id: "td" + apelido + "CubagemBaseValor_" + index,
        align: "left"
    });

    var _negritoTotais = Builder.node("b");
    var _negritoCubagem = Builder.node("b");

    var _labelTotais = Builder.node("label", {}, 'TOTAL NF(S)');
    var _labelQTDNOTAS = Builder.node("label", {}, '');
    var _labelQTDNOTAS2 = Builder.node("label", {id: "TotalQtdNotas_" + index}, '');
    var _labelContadorNf = Builder.node("label", {id: "conNf" + "_" + index, name: "conNf" + "_" + index}, '0');
    var _labelTotalValor = Builder.node("label", {}, 'Valor:');
    var _labelTotalPeso = Builder.node("label", {}, 'Peso:');
    var _labelTotalVolume = Builder.node("label", {}, 'Vol(s):');
    var _labelCubagem = Builder.node("label", {}, 'CUBAGEM');
    var _labelCubagemC = Builder.node("label", {}, 'C:');
    var _labelCubagemL = Builder.node("label", {}, 'L:');
    var _labelCubagemA = Builder.node("label", {}, 'A:');
    var _labelCubagemMetro = Builder.node("label", {}, 'M³');
    var _labelCubagemBase = Builder.node("label", {}, 'Base');
    var _labelCubagemIgual = Builder.node("label", {}, '=');
    var _labelCubagemIgual2 = Builder.node("label", {}, '=');
    var _labelCubagemKg = Builder.node("label", {}, 'Kg');

    var _inpTotalNFMercadoria = Builder.node("input", {
        id: "valorMercadoria" + apelido + "_" + index,
        name: "valorMercadoria" + apelido + "_" + index,
        type: "text",
        onKeyPress: callMascaraReais,
        style: estiloTextRight,
        className: estiloMin,
        size: sizeDecimal,
        maxLength: maxLengtPerc,
        value: "0,00"
    });
    var _inpTotalNFPeso = Builder.node("input", {
        id: "valorPeso" + apelido + "_" + index,
        name: "valorPeso" + apelido + "_" + index,
        type: "text",
        style: estiloTextRight,
        onKeyPress: callMascaraReais,
        className: estiloMin,
        size: sizeDecimal,
        maxLength: maxLengtPerc,
        value: "0,00"
    });
    var _inpTotalNFVolume = Builder.node("input", {
        id: "valorVolume" + apelido + "_" + index,
        name: "valorVolume" + apelido + "_" + index,
        type: "text",
        style: estiloTextRight,
        onKeyPress: callMascaraReais,
        className: estiloMin,
        size: sizeDecimal,
        maxLength: maxLengtPerc,
        value: "0,00"
    });
    var _inpcubagemComprimento = Builder.node("input", {
        id: "cubagemComprimento" + apelido + "_" + index,
        name: "cubagemComprimento" + apelido + "_" + index,
        type: "text",
        onKeyPress: "mascara(this, reaisManual, 4);",
        style: estiloTextRight,
        className: estiloMin2,
        size: "4",
        //maxLength: maxLengtPerc,
        value: "0,00",
        onBlur: "isNumeroBR(this, true);" + callEspelharTotalCubagem + calCalcularCubagemComposicaoFrete + callAlteraTipoTaxa
    });
    var _inpCubagemAltura = Builder.node("input", {
        id: "cubagemAltura" + apelido + "_" + index,
        name: "cubagemAltura" + apelido + "_" + index,
        type: "text",
        onKeyPress: "mascara(this, reaisManual, 4);",
        className: estiloMin2,
        size: "4",
        style: estiloTextRight,
        //maxLength: maxLengtPerc,
        value: "0,00",
        onBlur: "isNumeroBR(this, true);" + callEspelharTotalCubagem + calCalcularCubagemComposicaoFrete + callAlteraTipoTaxa
    });
    var _inpCubagemLargura = Builder.node("input", {
        id: "cubagemLargura" + apelido + "_" + index,
        name: "cubagemLargura" + apelido + "_" + index,
        type: "text",
        onKeyPress: "mascara(this, reaisManual, 4);",
        className: estiloMin2,
        size: "4",
        style: estiloTextRight,
        //maxLength: maxLengtPerc,
        value: "0,00",
        onBlur: "isNumeroBR(this, true);" + callEspelharTotalCubagem + calCalcularCubagemComposicaoFrete + callAlteraTipoTaxa
    });
    var _inpCubagemMetro = Builder.node("input", {
        id: "cubagemMetro" + apelido + "_" + index,
        name: "cubagemMetro" + apelido + "_" + index,
        type: "text",
        onKeyPress: "mascara(this, reaisManual, 4);", /*Não mexer nesse codigo, falar com Vladson*/
        className: estiloMin2,
        size: "4",
        style: estiloTextRight,
        /*maxLength: maxLengtPerc,*/
        value: "0,00",
        onBlur: "isNumeroBR(this, true);" + callCalculaPesoTaxado + preencheCubagemTotal
    });
    var _inpCubagemMetroHid = Builder.node("input", {
        id: "cubagemMetroHid_" + index,
        name: "cubagemMetroHid_" + index,
        type: "hidden",
        value: colocarVirgula(ctrc.cubagemMetro, 4)
    });

    var _inpCubagemBase = Builder.node("input", {
        id: "cubagemBase" + apelido + "_" + index,
        name: "cubagemBase" + apelido + "_" + index,
        type: "text",
        onKeyPress: callMascaraReais,
        className: estiloMin,
        size: sizeDecimal,
        style: estiloTextRight,
        maxLength: maxLengtPerc,
        value: colocarVirgula(ctrc.cubagemBase, 2),
        onBlur: callCalculaPesoTaxado + callEspelharTotalCubagem + callAlteraTipoTaxa
    });
    var _inpCubagemPeso = Builder.node("input", {
        id: "cubagemPeso" + apelido + "_" + index,
        name: "cubagemPeso" + apelido + "_" + index,
        type: "text",
        style: estiloTextRight,
        onKeyPress: callMascaraReais,
        className: estiloMin,
        size: sizeDecimal,
        maxLength: maxLengtPerc,
        value: "0,000",
        onBlur: callEspelharTotalCubagem + callAlteraTipoTaxa
    });




    readOnly(_inpTotalNFMercadoria, estiloMinReadOnly);
    readOnly(_inpTotalNFPeso, estiloMinReadOnly);
    readOnly(_inpTotalNFVolume, estiloMinReadOnly);
    readOnly(_inpCubagemPeso, estiloMinReadOnly);

    _negritoTotais.appendChild(_labelTotais);
    _tdTotaisNF.appendChild(_negritoTotais);
    _tdQtdNF.appendChild(_labelQTDNOTAS);
    _tdQtdNF.appendChild(_labelQTDNOTAS2);
    _tdTotaisMercadoriaDesc.appendChild(_labelTotalValor);
    _tdTotaisMercadoriaValor.appendChild(_inpTotalNFMercadoria);
    _tdTotaisPesoDesc.appendChild(_labelTotalPeso);
    _tdTotaisPesoValor.appendChild(_inpTotalNFPeso);
    _tdTotaisVolumeDesc.appendChild(_labelTotalVolume);
    _tdTotaisVolumeValor.appendChild(_inpTotalNFVolume);

    _negritoCubagem.appendChild(_labelCubagem);
    _tdCubagem.appendChild(_negritoCubagem);
    _tdCubagemValor.appendChild(_labelCubagemC);
    _tdCubagemValor.appendChild(_inpcubagemComprimento);
    _tdCubagemValor.appendChild(_labelCubagemA);
    _tdCubagemValor.appendChild(_inpCubagemAltura);
    _tdCubagemValor.appendChild(_labelCubagemL);
    _tdCubagemValor.appendChild(_inpCubagemLargura);
    _tdCubagemValor.appendChild(_labelCubagemIgual);
    _tdCubagemValor.appendChild(_inpCubagemMetro);
    _tdCubagemValor.appendChild(_inpCubagemMetroHid);
    _tdCubagemValor.appendChild(_labelCubagemMetro);
    _tdCubagemBaseDesc.appendChild(_labelCubagemBase);
    _tdCubagemBaseValor.appendChild(_inpCubagemBase);
    _tdCubagemBaseValor.appendChild(_labelCubagemIgual2);
    _tdCubagemBaseValor.appendChild(_inpCubagemPeso);
    _tdCubagemBaseValor.appendChild(_labelCubagemKg);

    _trTotaisNF.appendChild(_tdTotaisNF);
    _trTotaisNF.appendChild(_tdQtdNF);
    _trTotaisNF.appendChild(_tdTotaisMercadoriaDesc);
    _trTotaisNF.appendChild(_tdTotaisMercadoriaValor);
    _trTotaisNF.appendChild(_tdTotaisPesoDesc);
    _trTotaisNF.appendChild(_tdTotaisPesoValor);
    _trTotaisNF.appendChild(_tdTotaisVolumeDesc);
    _trTotaisNF.appendChild(_tdTotaisVolumeValor);
    _trTotaisNF.appendChild(_tdCubagem);
    _trTotaisNF.appendChild(_tdCubagemValor);
    _trTotaisNF.appendChild(_tdCubagemBaseDesc);
    _trTotaisNF.appendChild(_tdCubagemBaseValor);

    tabela.appendChild(_trTotaisNF);



}
function calcularTotaisNF(index) {

    var max = $("qtdNotas_" + index).value;
    var objValor = null;
    var objPeso = null;
    var objVolume = null;
    var valorTotal = 0;
    var pesoTotal = 0;
    var volumeTotal = 0;
    var layout = $("layout").value;

    /**
     *Proceda 3.1
     *
     **/
    var fontePreco = $("fontePreco").value;

    var objAdValorem = null;
    var objValorSeguro = null;
    var objValorFretePeso = null;
    var objValorGris = null;
    var objValorTotalTaxas = null;
    var objValorPedagio = null;

    var valorFreteTotal = 0;
    var valorPesoTotal = 0;
    var valorTaxaFixaTotal = 0;
    var valorGris = 0;
    var valorPedagio = 0;
    /**
     *Fim Proceda 3.1
     **/
    for (var i = 1; i <= max; i++) {
        objValor = $("notaValor_" + index + "_" + i);
        objPeso = $("notaPeso_" + index + "_" + i);
        objVolume = $("notaVolume_" + index + "_" + i);

        if (objValor.value == "" || objValor.value == null) {
            objValor.value = '0,00';
        }
        if (objPeso.value == "" || objPeso.value == null) {
            objPeso.value = '0,00';
        }
        if (objVolume.value == "" || objVolume.value == null) {
            objVolume.value = '0,00';
        }


        if (objValor != null && objValor != undefined) {
            valorTotal += parseFloat(colocarPonto(objValor.value));
            pesoTotal += parseFloat(colocarPonto(objPeso.value));
            volumeTotal += parseFloat(colocarPonto(objVolume.value));
        }
        /**
         *INICIO
         *Utilizar valores do arquivo
         **/
        if (fontePreco == "a") {


            objAdValorem = $("notaAdValorem_" + index + "_" + i);
            objValorSeguro = $("notaValorSeguro_" + index + "_" + i);
            objValorFretePeso = $("notaValorFretePeso_" + index + "_" + i);
            objValorTotalTaxas = $("notaValorTotalTaxas_" + index + "_" + i);
            objValorGris = $("notaValorGris_" + index + "_" + i);
            objValorPedagio = $("notaValorPedagio_" + index + "_" + i);
            /**
             *Utilizar valores do arquivo
             *Fim
             **/
            if (objAdValorem != null && objAdValorem != undefined) {
                valorFreteTotal += (parseFloat(objAdValorem.value) + parseFloat(objValorSeguro.value));
                if (layout != '75') {
                    valorPesoTotal += (parseFloat(objValorFretePeso.value));
                    valorGris += (parseFloat(objValorGris.value));
                    valorPedagio += (parseFloat(objValorPedagio.value));
                } else { // se for layout 75, ele não soma os valores que estão agrupados 
                    if (valorPesoTotal == 0) {
                        valorPesoTotal += (parseFloat(objValorFretePeso.value));
                    }
                    valorGris = (parseFloat(objValorGris.value));
                    valorPedagio = (parseFloat(objValorPedagio.value));
                }
                valorTaxaFixaTotal += (parseFloat(objValorTotalTaxas.value));

            }



        }


    }


    //tr do total da aba nota
    $("valorMercadoriaTotalNF_" + index).value = colocarVirgula(valorTotal);
    $("valorPesoTotalNF_" + index).value = colocarVirgula(pesoTotal, 3);
    $("valorVolumeTotalNF_" + index).value = colocarVirgula(volumeTotal, 4);
    //tr do total da aba composição frete
    $("valorMercadoriaTotalCF_" + index).value = colocarVirgula(valorTotal);
    $("valorPesoTotalCF_" + index).value = colocarVirgula(pesoTotal, 3);
    $("valorVolumeTotalCF_" + index).value = colocarVirgula(volumeTotal, 4);
    calculaPesoTaxado(index);

    /*     
     *Utilizar valores do arquivo
     */



    if (fontePreco == "a") {

        if (layout != "49") {
            $("valorFretePeso_" + index).value = colocarVirgula(valorPesoTotal);
        } else {
            if ($("cartaValorFrete") != null && $("cartaValorFrete") != undefined) {
                $("cartaValorFrete").value = $("valorFreteValor_" + index).value;
            }

        }
        $("valorFreteValor_" + index).value = colocarVirgula(valorFreteTotal);
        $("valorTaxaFixa_" + index).value = colocarVirgula(valorTaxaFixaTotal);
        $("valorPedagio_" + index).value = colocarVirgula(valorPedagio);
        $("valorGris_" + index).value = colocarVirgula(valorGris);
        recalcular(index);

    }

    /**
     *Fim Utilizar valores do arquivo
     **/

    alteraTipoTaxa("N", index);

}
function removerNota(elemento) {
    try {
        var indexCtrc = elemento.id.split("_")[1];
        var indexNota = elemento.id.split("_")[2];
        var nome = $("notaNumero_" + indexCtrc + "_" + indexNota).value;
        if (confirm("Deseja excluir a nota '" + nome + "'?")) {
            subValorTotalMercadorias(indexCtrc, indexNota);
            Element.remove($("notaConteudo_" + indexCtrc + "_" + indexNota));
            Element.remove($("trNotaAdicionais_" + indexCtrc + "_" + indexNota));
            atualizarContatorNFe(indexCtrc);
        }
    } catch (ex) {
        alert(ex);
        console.log(ex);
    }

}

function atualizarContatorNFe(indexCtrc) {
    var qtdNotas = jQuery('tr[id*=notaConteudo_' + indexCtrc + ']').size();
    jQuery("#TotalQtdNotas_" + indexCtrc).text(qtdNotas);
}

function subValorTotalMercadorias(indexCtrc, indexNota) {
    var valorNF = parseFloat(colocarPonto($("valorMercadoriaTotalNF_" + indexCtrc).value));
    var pesoNF = parseFloat(colocarPonto($("valorPesoTotalNF_" + indexCtrc).value));
    var volumeNF = parseFloat(colocarPonto($("valorVolumeTotalNF_" + indexCtrc).value));


    var vlr = valorNF - parseFloat(colocarPonto($("notaValor_" + indexCtrc + "_" + indexNota).value));
    var peso = pesoNF - parseFloat(colocarPonto($("notaPeso_" + indexCtrc + "_" + indexNota).value));
    var vlm = volumeNF - parseFloat(colocarPonto($("notaVolume_" + indexCtrc + "_" + indexNota).value));


    $("valorMercadoriaTotalNF_" + indexCtrc).value = colocarVirgula(roundABNT(vlr));
    $("valorPesoTotalNF_" + indexCtrc).value = colocarVirgula(roundABNT(peso));
    $("valorVolumeTotalNF_" + indexCtrc).value = colocarVirgula(roundABNT(vlm));
}


function addConhecimentoLoteNotasCubagens(cubagem, classe, indexCtrc, indexNota, isPrimeiro) {
    var calAddConhecimentoLoteNotasCubagens = "addConhecimentoLoteNotasCubagens(" + null + ", '" + classe + "', " + indexCtrc + ", " + indexNota + "," + false + ");";
    var calCalcularCubagemNota = "calcularCubagemNota(this, true);";
    var preencheCubagem = "preencheCubagem(this);";
    if (cubagem == null) {
        cubagem = new Cubabem();
    }

    var index = parseInt($("qtdCubagens_" + indexCtrc + "_" + indexNota).value, 10) + 1;
    classe = (classe == null || classe == undefined || classe == "" ? ((indexCtrc % 2) != 0 ? 'CelulaZebra2NoAlign' : 'CelulaZebra1NoAlign') : classe);
    var _trCubagem = Builder.node("tr", {
        className: classe,
        id: "trCubagem_" + indexCtrc + "_" + indexNota + "_" + index
    });
    var _td0 = Builder.node("td", {
        width: "2%",
        id: "td0_" + indexCtrc + "_" + indexNota + "_" + index
    });
    var _tdVolumeDesc = Builder.node("td", {
        width: "10%",
        align: "right",
        id: "tdVolumeDesc_" + indexCtrc + "_" + indexNota + "_" + index
    });
    var _tdVolumeValor = Builder.node("td", {
        width: "10%",
        align: "left",
        id: "tdVolumeValor_" + indexCtrc + "_" + indexNota + "_" + index
    });
    var _tdComprimentoDesc = Builder.node("td", {
        width: "10%",
        align: "right",
        id: "tdComprimentoDesc_" + indexCtrc + "_" + indexNota + "_" + index
    });
    var _tdComprimentoValor = Builder.node("td", {
        width: "10%",
        align: "left",
        id: "tdComprimentoValor_" + indexCtrc + "_" + indexNota + "_" + index
    });
    var _tdLarguraDesc = Builder.node("td", {
        width: "7%",
        align: "right",
        id: "tdLarguraDesc_" + indexCtrc + "_" + indexNota + "_" + index
    });
    var _tdLarguraValor = Builder.node("td", {
        width: "7%",
        align: "left",
        id: "tdLarguraValor_" + indexCtrc + "_" + indexNota + "_" + index
    });
    var _tdAlturaDesc = Builder.node("td", {
        width: "6%",
        align: "right",
        id: "tdAlturaDesc_" + indexCtrc + "_" + indexNota + "_" + index
    });
    var _tdAlturaValor = Builder.node("td", {
        width: "8%",
        align: "left",
        id: "tdAlturaValor_" + indexCtrc + "_" + indexNota + "_" + index
    });
    var _tdMetroDesc = Builder.node("td", {
        width: "6%",
        align: "right",
        id: "tdMetroDesc_" + indexCtrc + "_" + indexNota + "_" + index
    });
    var _tdMetroValor = Builder.node("td", {
        width: "5%",
        align: "left",
        id: "tdMetroValor_" + indexCtrc + "_" + indexNota + "_" + index
    });

    var _tdEtiquetaDesc = Builder.node("td", {
        width: "5%",
        align: "right",
        id: "tdEtiquetaDesc_" + indexCtrc + "_" + indexNota + "_" + index
    });
    var _tdEtiquetaValor = Builder.node("td", {
        width: "20%",
        align: "left",
        id: "tdEtiquetaValor_" + indexCtrc + "_" + indexNota + "_" + index
    });

    var _labelVolume = Builder.node("label", {}, 'Volume:');
    var _labelComprimento = Builder.node("label", {}, 'Comp.:');
    var _labelLargura = Builder.node("label", {}, 'Largura.:');
    var _labelALtura = Builder.node("label", {}, 'Alt..:');
    var _labelMetro = Builder.node("label", {}, 'M³:');
    var _labelEtiqueta = Builder.node("label", {}, 'Etiqueta:');


    var _imgAdd = Builder.node("img", {
        src: "img/add.gif",
        id: "addCubagem_" + indexCtrc + "_" + indexNota,
        className: "imagemLinkSpc",
        border: "0",
        onClick: calAddConhecimentoLoteNotasCubagens,
        title: "Adicionar Cubagem"
    });
    var _imgRemoverCubagem = Builder.node("img", {
        src: "img/lixo.png",
        id: "imgRemoveCubagem_" + indexCtrc + "_" + indexNota + "_" + index,
        className: "imagemLinkSpc",
        border: "0",
        onClick: "removerCubagem(this);"
    });
    var _inpVolume = Builder.node("input", {
        id: "cubVolume_" + indexCtrc + "_" + indexNota + "_" + index,
        name: "cubVolume_" + indexCtrc + "_" + indexNota + "_" + index,
        type: "text",
        style: estiloTextRight,
        className: estiloMin,
        onKeyPress: "mascara(this, reais, 4);",
        size: 6,
        maxlength: maxLengtDefault,
        onBlur: calCalcularCubagemNota,
        value: colocarVirgula(cubagem.volume, 4)
    });
    var _inpComprimento = Builder.node("input", {
        id: "cubComprimento_" + indexCtrc + "_" + indexNota + "_" + index,
        name: "cubComprimento_" + indexCtrc + "_" + indexNota + "_" + index,
        type: "text",
        style: estiloTextRight,
        className: estiloMin,
        onKeyPress: "mascara(this, reais, 4);",
        size: 6,
        onBlur: calCalcularCubagemNota,
        maxlength: maxLengtDefault,
        value: colocarVirgula(cubagem.comprimento, 4)
    });
    var _inpAltura = Builder.node("input", {
        id: "cubAltura_" + indexCtrc + "_" + indexNota + "_" + index,
        name: "cubAltura_" + indexCtrc + "_" + indexNota + "_" + index,
        type: "text",
        style: estiloTextRight,
        className: estiloMin,
        onBlur: calCalcularCubagemNota,
        onKeyPress: "mascara(this, reais, 4);",
        size: 6,
        maxlength: maxLengtDefault,
        value: colocarVirgula(cubagem.altura, 4)
    });
    var _inpLargura = Builder.node("input", {
        id: "cubLargura_" + indexCtrc + "_" + indexNota + "_" + index,
        name: "cubLargura_" + indexCtrc + "_" + indexNota + "_" + index,
        type: "text",
        className: estiloMin,
        onKeyPress: "mascara(this, reais, 4);",
        size: 6,
        style: estiloTextRight,
        onBlur: calCalcularCubagemNota,
        maxlength: maxLengtDefault,
        value: colocarVirgula(cubagem.largura, 4)
    });
    var _inpMetro = Builder.node("input", {
        id: "cubMetro_" + indexCtrc + "_" + indexNota + "_" + index,
        name: "cubMetro_" + indexCtrc + "_" + indexNota + "_" + index,
        type: "text",
        className: estiloMin,
        onKeyPress: "mascara(this, reais, 4);",
        size: 6,
        style: estiloTextRight,
        onBlur: preencheCubagem,
        maxlength: maxLengtDefault,
        value: colocarVirgula(cubagem.metroCubico, 8)
    });

    var _inpMetroHid = Builder.node("input", {
        id: "cubMetroHid_" + indexCtrc + "_" + indexNota + "_" + index,
        name: "cubMetroHid_" + indexCtrc + "_" + indexNota + "_" + index,
        type: "hidden",
        value: "0,00"
    });

    var _inpEtiqueta = Builder.node("input", {
        id: "cubEtiqueta_" + indexCtrc + "_" + indexNota + "_" + index,
        name: "cubEtiqueta_" + indexCtrc + "_" + indexNota + "_" + index,
        type: "text",
        className: estiloMin,
        size: "22",
        style: estiloTextRight,
        value: cubagem.etiqueta
    });

    var _inpIdHid = Builder.node("input", {
        id: "cubId_" + indexCtrc + "_" + indexNota + "_" + index,
        name: "cubId_" + indexCtrc + "_" + indexNota + "_" + index,
        type: "hidden",
        value: cubagem.id
    });

    if (isPrimeiro) {
        _td0.appendChild(_imgAdd);
    } else {
        _td0.appendChild(_imgRemoverCubagem);
    }
    _td0.appendChild(_inpIdHid);
    //readOnly(_inpMetro, estiloMinReadOnly);
    _tdVolumeDesc.appendChild(_labelVolume);
    _tdVolumeValor.appendChild(_inpVolume);
    _tdComprimentoDesc.appendChild(_labelComprimento);
    _tdComprimentoValor.appendChild(_inpComprimento);
    _tdLarguraDesc.appendChild(_labelLargura);
    _tdLarguraValor.appendChild(_inpLargura);
    _tdAlturaDesc.appendChild(_labelALtura);
    _tdAlturaValor.appendChild(_inpAltura);
    _tdMetroDesc.appendChild(_labelMetro);
    _tdMetroValor.appendChild(_inpMetro);
    _tdMetroValor.appendChild(_inpMetroHid);
    _tdEtiquetaDesc.appendChild(_labelEtiqueta);
    _tdEtiquetaValor.appendChild(_inpEtiqueta);

    _trCubagem.appendChild(_td0);
    _trCubagem.appendChild(_tdVolumeDesc);
    _trCubagem.appendChild(_tdVolumeValor);
    _trCubagem.appendChild(_tdComprimentoDesc);
    _trCubagem.appendChild(_tdComprimentoValor);
    _trCubagem.appendChild(_tdAlturaDesc);
    _trCubagem.appendChild(_tdAlturaValor);
    _trCubagem.appendChild(_tdLarguraDesc);
    _trCubagem.appendChild(_tdLarguraValor);
    _trCubagem.appendChild(_tdMetroDesc);
    _trCubagem.appendChild(_tdMetroValor);
    _trCubagem.appendChild(_tdEtiquetaDesc);
    _trCubagem.appendChild(_tdEtiquetaValor);

    $("tbodyNotaAdicionaisCubagens_" + indexCtrc + "_" + indexNota).appendChild(_trCubagem);
    $("qtdCubagens_" + indexCtrc + "_" + indexNota).value = index;
    calcularCubagemNota(_inpVolume);
}
function addConhecimentoLoteNotasMercadorias(mercadoria, classe, indexCtrc, indexNota) {
    try {
        if (mercadoria == null || mercadoria == undefined) {
            mercadoria = new Mercadoria();
        }
        var index = parseInt($("qtdMercadorias_" + indexCtrc + "_" + indexNota).value, 10) + 1;
        classe = (classe == null || classe == undefined || classe == "" ? ((indexCtrc % 2) != 0 ? 'CelulaZebra2NoAlign' : 'CelulaZebra1NoAlign') : classe);
        var _trMercadorias = Builder.node("tr", {
            className: classe,
            id: "trMercadorias_" + indexCtrc + "_" + indexNota + "_" + index
        });
        var _td0 = Builder.node("td", {
            width: "2%",
            id: "td0_" + indexCtrc + "_" + indexNota + "_" + index
        });
        var _inpItemId = Builder.node("input", {
            id: "itemId_" + indexCtrc + "_" + indexNota + "_" + index,
            name: "itemId_" + indexCtrc + "_" + indexNota + "_" + index,
            type: "hidden",
            value: mercadoria.id
        });
        var _inpProdutoId = Builder.node("input", {
            id: "produtoId_" + indexCtrc + "_" + indexNota + "_" + index,
            name: "produtoId_" + indexCtrc + "_" + indexNota + "_" + index,
            type: "hidden",
            value: mercadoria.produtoId
        });
        var _inpProduto = Builder.node("input", {
            id: "produto_" + indexCtrc + "_" + indexNota + "_" + index,
            name: "produto_" + indexCtrc + "_" + indexNota + "_" + index,
            type: "hidden",
            value: mercadoria.produto
        });
        var _inpQuantidade = Builder.node("input", {
            id: "itemQuantidade_" + indexCtrc + "_" + indexNota + "_" + index,
            name: "itemQuantidade_" + indexCtrc + "_" + indexNota + "_" + index,
            type: "hidden",
            value: colocarVirgula(mercadoria.quantidade, 2)
        });
        var _inpValorUnitario = Builder.node("input", {
            id: "itemValorUnitario_" + indexCtrc + "_" + indexNota + "_" + index,
            name: "itemValorUnitario_" + indexCtrc + "_" + indexNota + "_" + index,
            type: "hidden",
            value: colocarVirgula(mercadoria.valorUnitario)
        });

        _td0.appendChild(_inpItemId);
        _td0.appendChild(_inpProduto);
        _td0.appendChild(_inpProdutoId);
        _td0.appendChild(_inpQuantidade);
        _td0.appendChild(_inpValorUnitario);

        _trMercadorias.appendChild(_td0);

        $("tbodyNotaAdicionaisMercadoria_" + indexCtrc + "_" + indexNota).appendChild(_trMercadorias);
        $("qtdMercadorias_" + indexCtrc + "_" + indexNota).value = index;
    } catch (e) {
        alert(e);
        console.log(e);
    }
}
function removerCubagem(elemento) {
    var tr = "trCubagem" + elemento.id.replace("imgRemoveCubagem", "");

    if (confirm("Tem certeza que deseja remover esta cubagem? ")) {
        Element.remove($(tr));
    }
}

function habilitarCampos_alteraprecocte(index) {
    notReadOnly($("valorTaxaFixa_" + index));
    notReadOnly($("valorItr_" + index));
    notReadOnly($("valorDespacho_" + index));
    notReadOnly($("valorAdeme_" + index));
    notReadOnly($("valorFretePeso_" + index));
    notReadOnly($("valorFreteValor_" + index));
    notReadOnly($("valorSecCat_" + index));
    notReadOnly($("valorOutros_" + index));
    notReadOnly($("valorGris_" + index));
    notReadOnly($("valorPedagio_" + index));
    notReadOnly($("valorTde_" + index));
    notReadOnly($("valorDesconto_" + index));
    $("isTde_" + index).disabled = false;
    $("isAddIcms_" + index).disabled = false;
    $("isAddPisCofins_" + index).disabled = false;
}
function desabilitarCampos_alteraprecocte(index) {
    $("isAddIcms_" + index).disabled = true;
    $("isAddPisCofins_" + index).disabled = true;
    readOnly($("valorTaxaFixa_" + index), estiloMinReadOnly);
    readOnly($("valorItr_" + index), estiloMinReadOnly);
    readOnly($("valorDespacho_" + index), estiloMinReadOnly);
    readOnly($("valorAdeme_" + index), estiloMinReadOnly);
    readOnly($("valorFretePeso_" + index), estiloMinReadOnly);
    readOnly($("valorFreteValor_" + index), estiloMinReadOnly);
    readOnly($("valorSecCat_" + index), estiloMinReadOnly);
    readOnly($("valorOutros_" + index), estiloMinReadOnly);
    readOnly($("valorGris_" + index), estiloMinReadOnly);
    readOnly($("valorPedagio_" + index), estiloMinReadOnly);
    $("isTde_" + index).disabled = true;
    readOnly($("valorTde_" + index), estiloMinReadOnly);
    readOnly($("valorDesconto_" + index), estiloMinReadOnly);
}

//composilçao frete
function addConhecimentoComposicaoFrete(ctrc, index, tabela, classe, temPermissao_alteraprecocte) {
    var myCallRecalcular = callRecalcular.replace("index", index);
    var callCalcularTotalPrestacao = "calcularTotalPrestacao(" + index + " );";
    var callAlteraTipoTaxa = "alteraTipoTaxa('N'," + index + " );";
    var callMarcarTDE = "marcarTde(this);";
    var callMarcarSecCat = "marcarSecCat(this);";
    var _trComposicao1 = Builder.node("tr", {
        id: "trComposicao1_" + index,
        className: classe
    });
    var _trComposicao2 = Builder.node("tr", {
        id: "trComposicao2_" + index,
        className: classe
    });
    var _trComposicao3 = Builder.node("tr", {
        id: "trComposicao3_" + index,
        className: classe
    });

    var _negritoEmbutir = Builder.node("b");
    var _negritoIcms = Builder.node("b");
    var _negritoPisCofins = Builder.node("b");
    var _negritoFretePeso = Builder.node("b");
    var _negritoFreteValor = Builder.node("b");

    //td's da linha 1
    var _tdPesoTaxadoDesc = Builder.node("td", {
        id: "tdPesoTaxadoDesc_" + index,
        align: "right"
    });
    var _tdPesoTaxadoValor = Builder.node("td", {
        id: "tdPesoTaxadoVarlor_" + index,
        colSpan: 2,
        align: "left"
    });
    var _tdEmbutirTotalPrestacaoDesc = Builder.node("td", {
        id: "tdEmbutirTotalPrestacaoDesc_" + index,
        colSpan: 9,
        align: "center"
    });
    var _tdEmbutirTotalPrestacaoValor = Builder.node("td", {
        id: "tdEmbutirTotalPrestacaoValor_" + index
    });

    //td's da linha 2
    var _tdTaxaFixaDesc = Builder.node("td", {
        id: "tdTaxaFixaDesc_" + index,
        align: "right"
    });
    var _tdTaxaFixaValor = Builder.node("td", {
        id: "tdTaxaFixaValor_" + index,
        align: "left"
    });
    var _tdItrDesc = Builder.node("td", {
        id: "tdItrDesc_" + index,
        align: "right"
    });
    var _tdItrValor = Builder.node("td", {
        id: "tdItrValor_" + index,
        align: "left"
    });
    var _tdDespachoDesc = Builder.node("td", {
        id: "tdDespachoDesc_" + index,
        align: "right"
    });
    var _tdDespachoValor = Builder.node("td", {
        id: "tdDespachoValor_" + index,
        align: "left"
    });
    var _tdAdemeDesc = Builder.node("td", {
        id: "tdAdemeDesc_" + index,
        align: "right"
    });
    var _tdAdemeValor = Builder.node("td", {
        id: "tdAdemeValor_" + index,
        align: "left"
    });
    var _tdFretePesoDesc = Builder.node("td", {
        id: "tdFretePesoDesc_" + index,
        align: "right"
    });
    var _tdFretePesoValor = Builder.node("td", {
        id: "tdFretePesoValor_" + index,
        align: "left"
    });
    var _tdFreteValorDesc = Builder.node("td", {
        id: "tdFreteValorDesc_" + index,
        align: "right"
    });
    var _tdFreteValorValor = Builder.node("td", {
        id: "tdFreteValorValor_" + index,
        align: "left"
    });


    //td's da linha 3'
    var _tdSecCatDesc = Builder.node("td", {
        id: "tdSecCatDesc_" + index,
        align: "right"
    });
    var _tdSecCatValor = Builder.node("td", {
        id: "tdSecCatValor_" + index,
        align: "left"
    });
    var _tdOutrosDesc = Builder.node("td", {
        id: "tdOutrosDesc_" + index,
        align: "right"
    });
    var _tdOutrosValor = Builder.node("td", {
        id: "tdOutrosValor_" + index,
        align: "left"
    });
    var _tdGrisDesc = Builder.node("td", {
        id: "tdGrisDesc_" + index,
        align: "right"
    });
    var _tdGrisValor = Builder.node("td", {
        id: "tdGrisValor_" + index,
        align: "left"
    });
    var _tdPedagioDesc = Builder.node("td", {
        id: "tdPedagioDesc_" + index,
        align: "right"
    });
    var _tdPedagioValor = Builder.node("td", {
        id: "tdPedagioValor_" + index,
        align: "left"
    });
    var _tdTdeDesc = Builder.node("td", {
        id: "tdTdeDesc_" + index,
        align: "right"
    });
    var _tdTdeValor = Builder.node("td", {
        id: "tdTdeValor_" + index,
        align: "left"
    });
    var _tdDescontoDesc = Builder.node("td", {
        id: "tdDescontoDesc_" + index,
        align: "right"
    });
    var _tdDescontoValor = Builder.node("td", {
        id: "tdDescontoValor_" + index,
        align: "left"
    });

    var labelFederaisGeral = "";
    var labelFederais = "";

    if (embutirIr) {
        labelFederaisGeral += "/IR";
    }
    if (embutirCssl) {
        labelFederaisGeral += "/CSSL";
    }
    if (embutirPis) {
        labelFederaisGeral += "/PIS";
    }
    if (embutirCofins) {
        labelFederaisGeral += "/COFINS";
    }
    if (embutirInss) {
        labelFederaisGeral += "/INSS";
    }

    var label = labelFederaisGeral.lastIndexOf("/");
    if (label > -1) {
        labelFederais = labelFederaisGeral.replace("/", "").replace(" ", "/").replace(" ", "/").replace(" ", "/");
    }



    //label's da linha 1
    var _labelPesoTaxado = Builder.node("label", {}, 'Peso Taxado:');
    var _labelPesoTaxadoSufixo = Builder.node("label", {}, ' Kg');
    var _labelEmbutirTotalPrestacao = Builder.node("label", {}, 'Embutir no total da prestação:');
    var _labelEmbutirTotalPrestacaoIcms = Builder.node("label", {}, ' ICMS/ISS ');
    var _labelEmbutirTotalPrestacaoPisCofins = Builder.node("label", {}, labelFederais);

    //label's da linha 2
    var _labelTaxaFixa = Builder.node("label", {}, ($("tipoTransporte").value == 'a' ? 'Taxa Origem:' : 'Taxa Fixa:'));
    var _labelITR = Builder.node("label", {}, 'ITR:');
    var _labelDespacho = Builder.node("label", {}, 'Despacho:');
    var _labelAdeme = Builder.node("label", {}, 'ADEME:');
    var _labelFretePeso = Builder.node("label", {}, ($("tipoTransporte").value == 'a' ? 'Frete Nacional:' : 'Frete Peso:'));
    var _labelFreteValor = Builder.node("label", {}, ($("tipoTransporte").value == 'a' ? 'AD Valorem:' : 'Frete Valor:'));


    //label's da linha 3
    var _labelCobrarSecCat = Builder.node("label", {id: "lbCobrarSecCat_" + index, name: "lbCobrarSecCat_" + index}, 'Cobrar ');
    var _labelSecCat = Builder.node("label", {}, ($("tipoTransporte").value == 'a' ? 'Taxa Destino:' : 'SEC/CAT:'));
    var _labelOutros = Builder.node("label", {}, 'Outros:');
    var _labelGris = Builder.node("label", {}, 'GRIS:');
    var _labelPedagio = Builder.node("label", {}, 'Pedágio:');
    var _labelTde = Builder.node("label", {}, ' Cobrar TDE:');
    var _labelDesconto = Builder.node("label", {
        className: styleAux
    }, 'Desconto:');


    //input's da linha 1
    var _inpPesoTaxado = Builder.node("input", {
        id: "valorPesoTaxado_" + index,
        name: "valorPesoTaxado_" + index,
        type: "text",
        style: estiloTextRight,
        className: estiloMin,
        onKeyPress: callMascaraReais,
        maxlength: maxLengtDefault,
        onkeyup: callsetZero,
        size: sizeDecimal,
        value: colocarVirgula(ctrc.pesoTaxado)
    });
    var _inpICMS = Builder.node("input", {
        id: "isAddIcms_" + index,
        name: "isAddIcms_" + index,
        type: "checkbox",
        onKeyPress: callMascaraReais,
        maxlength: maxLengtDefault,
        size: sizeDecimal,
        onClick: 'aoClicarIcmsIss(' + index + ')'
    });

    _inpICMS.checked = ctrc.isIcms;
    var _inpPisCofins = Builder.node("input", {
        id: "isAddPisCofins_" + index,
        name: "isAddPisCofins_" + index,
        type: "checkbox",
        onKeyPress: callMascaraReais,
        maxlength: maxLengtDefault,
        size: sizeDecimal,
        checked: ctrc.isPisCofins,
        onClick: myCallRecalcular//
    });

    _inpPisCofins.checked = ctrc.isPisCofins;
    //input's da linha 2
    var _inpTaxaFixa = Builder.node("input", {
        id: "valorTaxaFixa_" + index,
        name: "valorTaxaFixa_" + index,
        type: "text",
        style: estiloTextRight,
        onblur: myCallRecalcular,
        className: estiloMin,
        onKeyPress: callMascaraReais,
        maxlength: maxLengtDefault,
        onkeyup: callsetZero,
        size: sizeDecimal,
        value: colocarVirgula(ctrc.valorTaxaFixa)
    });


    var _inpITR = Builder.node("input", {
        id: "valorItr_" + index,
        name: "valorItr_" + index,
        type: "text",
        style: estiloTextRight,
        onblur: myCallRecalcular,
        className: estiloMin,
        onKeyPress: callMascaraReais,
        size: sizeDecimal,
        onkeyup: callsetZero,
        maxlength: maxLengtDefault,
        value: colocarVirgula(ctrc.valorItr)
    });

    var _inpDespacho = Builder.node("input", {
        id: "valorDespacho_" + index,
        name: "valorDespacho_" + index,
        type: "text",
        style: estiloTextRight,
        onblur: myCallRecalcular,
        className: estiloMin,
        onKeyPress: callMascaraReais,
        maxlength: maxLengtDefault,
        size: sizeDecimal,
        onkeyup: callsetZero,
        value: colocarVirgula(ctrc.valorDespacho)
    });

    var _inpAdeme = Builder.node("input", {
        id: "valorAdeme_" + index,
        name: "valorAdeme_" + index,
        type: "text",
        style: estiloTextRight,
        onblur: myCallRecalcular,
        className: estiloMin,
        maxlength: maxLengtDefault,
        onKeyPress: callMascaraReais,
        size: sizeDecimal,
        onkeyup: callsetZero,
        value: colocarVirgula(ctrc.valorAdeme)
    });

    var _inpFretePeso = Builder.node("input", {
        id: "valorFretePeso_" + index,
        name: "valorFretePeso_" + index,
        type: "text",
        style: estiloTextRight,
        onblur: myCallRecalcular,
        className: estiloMin,
        maxlength: maxLengtDefault,
        onKeyPress: callMascaraReais,
        size: sizeDecimal,
        onkeyup: callsetZero,
        value: colocarVirgula(ctrc.valorFretePeso)
    });

    var _inpFreteValor = Builder.node("input", {
        id: "valorFreteValor_" + index,
        name: "valorFreteValor_" + index,
        type: "text",
        style: estiloTextRight,
        className: estiloMin,
        maxlength: maxLengtDefault,
        onKeyPress: callMascaraReais,
        size: sizeDecimal,
        onkeyup: callsetZero,
        onblur: myCallRecalcular,
        value: colocarVirgula(ctrc.valorFreteValor)
    });

    //input's da linha 2
    var _inpCalculaSecCat = Builder.node("input", {
        id: "calculaSecCat_" + index,
        name: "calculaSecCat_" + index,
        type: "hidden",
        value: ctrc.calculaSecCat
    });

    var _inpCobrarSecCat = Builder.node("input", {
        id: "isSecCat_" + index,
        name: "isSecCat_" + index,
        type: "checkbox",
        onClick: myCallRecalcular + callMarcarSecCat
    });
    _inpCobrarSecCat.checked = true;

    var _inpSecCat = Builder.node("input", {
        id: "valorSecCat_" + index,
        name: "valorSecCat_" + index,
        type: "text",
        style: estiloTextRight,
        className: estiloMin,
        maxlength: maxLengtDefault,
        onKeyPress: callMascaraReais,
        onblur: myCallRecalcular,
        size: sizeDecimal,
        onkeyup: callsetZero,
        style: estiloTextRight,
        value: colocarVirgula(ctrc.valorSecCat)
    });

    var _inpOutros = Builder.node("input", {
        id: "valorOutros_" + index,
        name: "valorOutros_" + index,
        type: "text",
        style: estiloTextRight,
        className: estiloMin,
        maxlength: maxLengtDefault,
        onKeyPress: callMascaraReais,
        size: sizeDecimal,
        onkeyup: callsetZero,
        onblur: myCallRecalcular,
        value: colocarVirgula(ctrc.valorOutros)
    });

    var _inpGris = Builder.node("input", {
        id: "valorGris_" + index,
        name: "valorGris_" + index,
        type: "text",
        style: estiloTextRight,
        maxlength: maxLengtDefault,
        className: estiloMin,
        onKeyPress: callMascaraReais,
        size: sizeDecimal,
        onkeyup: callsetZero,
        onblur: myCallRecalcular,
        value: colocarVirgula(ctrc.valorDespacho)
    });

    var _inpPedagio = Builder.node("input", {
        id: "valorPedagio_" + index,
        name: "valorPedagio_" + index,
        type: "text",
        className: estiloMin,
        onKeyPress: callMascaraReais,
        size: sizeDecimal,
        onkeyup: callsetZero,
        style: estiloTextRight,
        onblur: myCallRecalcular,
        maxlength: maxLengtDefault,
        value: colocarVirgula(ctrc.valorPedagio)
    });

    var _inpCobrarTde = Builder.node("input", {
        id: "isTde_" + index,
        name: "isTde_" + index,
        type: "checkbox",
        onClick: myCallRecalcular
    });

    _inpCobrarTde.checked = ctrc.isCobrarTde;
    var _inpTde = Builder.node("input", {
        id: "valorTde_" + index,
        name: "valorTde_" + index,
        type: "text",
        onkeyup: callsetZero,
        style: estiloTextRight,
        className: estiloMin,
        maxlength: maxLengtDefault,
        onKeyPress: callMascaraReais,
        onblur: myCallRecalcular,
        size: sizeDecimal,
        value: colocarVirgula(ctrc.valorTde)
    });

    var _inpDesconto = Builder.node("input", {
        id: "valorDesconto_" + index,
        name: "valorDesconto_" + index,
        type: "text",
        style: estiloTextRight,
        maxlength: maxLengtDefault,
        className: estiloMin + styleAux,
        onKeyPress: callMascaraReais,
        size: sizeDecimal,
        onkeyup: callsetZero,
        onblur: myCallRecalcular,
        value: colocarVirgula(ctrc.valorDesconto)
    });

    readOnly(_inpPesoTaxado, estiloMinReadOnly);

    //povoando linha 1
    _tdPesoTaxadoDesc.appendChild(_labelPesoTaxado);
    _tdPesoTaxadoValor.appendChild(_inpPesoTaxado);
    _tdPesoTaxadoValor.appendChild(_labelPesoTaxadoSufixo);
    _negritoEmbutir.appendChild(_labelEmbutirTotalPrestacao);
    _negritoEmbutir.appendChild(_labelEmbutirTotalPrestacao);
    _tdEmbutirTotalPrestacaoDesc.appendChild(_negritoEmbutir);
    _tdEmbutirTotalPrestacaoDesc.appendChild(_inpICMS);
    _negritoIcms.appendChild(_labelEmbutirTotalPrestacaoIcms);
    _tdEmbutirTotalPrestacaoDesc.appendChild(_negritoIcms);
    _tdEmbutirTotalPrestacaoDesc.appendChild(_inpPisCofins);
    _negritoPisCofins.appendChild(_labelEmbutirTotalPrestacaoPisCofins);
    _tdEmbutirTotalPrestacaoDesc.appendChild(_negritoPisCofins);


    _trComposicao1.appendChild(_tdPesoTaxadoDesc);
    _trComposicao1.appendChild(_tdPesoTaxadoValor);
    _trComposicao1.appendChild(_tdEmbutirTotalPrestacaoDesc);

    //povoando linha 2
    _tdTaxaFixaDesc.appendChild(_labelTaxaFixa);
    _tdTaxaFixaValor.appendChild(_inpTaxaFixa);
    _tdItrDesc.appendChild(_labelITR);
    _tdItrValor.appendChild(_inpITR);
    _tdDespachoDesc.appendChild(_labelDespacho);
    _tdDespachoValor.appendChild(_inpDespacho);
    _tdAdemeDesc.appendChild(_labelAdeme);
    _tdAdemeValor.appendChild(_inpAdeme);
    _negritoFretePeso.appendChild(_labelFretePeso);
    _tdFretePesoDesc.appendChild(_negritoFretePeso);
    _tdFretePesoValor.appendChild(_inpFretePeso);
    _negritoFreteValor.appendChild(_labelFreteValor);
    _tdFreteValorDesc.appendChild(_negritoFreteValor);
    _tdFreteValorValor.appendChild(_inpFreteValor);

    _trComposicao2.appendChild(_tdTaxaFixaDesc);
    _trComposicao2.appendChild(_tdTaxaFixaValor);
    _trComposicao2.appendChild(_tdItrDesc);
    _trComposicao2.appendChild(_tdItrValor);
    _trComposicao2.appendChild(_tdDespachoDesc);
    _trComposicao2.appendChild(_tdDespachoValor);
    _trComposicao2.appendChild(_tdAdemeDesc);
    _trComposicao2.appendChild(_tdAdemeValor);
    _trComposicao2.appendChild(_tdFretePesoDesc);
    _trComposicao2.appendChild(_tdFretePesoValor);
    _trComposicao2.appendChild(_tdFreteValorDesc);
    _trComposicao2.appendChild(_tdFreteValorValor);


    //povoando linha 3
    _tdSecCatDesc.appendChild(_inpCalculaSecCat);
    _tdSecCatDesc.appendChild(_inpCobrarSecCat);
    _tdSecCatDesc.appendChild(_labelCobrarSecCat);
    _tdSecCatDesc.appendChild(_labelSecCat);
    _tdSecCatValor.appendChild(_inpSecCat);
    _tdOutrosDesc.appendChild(_labelOutros);
    _tdOutrosValor.appendChild(_inpOutros);
    _tdGrisDesc.appendChild(_labelGris);
    _tdGrisValor.appendChild(_inpGris);
    _tdPedagioDesc.appendChild(_labelPedagio);
    _tdPedagioValor.appendChild(_inpPedagio);
    _tdTdeDesc.appendChild(_inpCobrarTde);
    _tdTdeDesc.appendChild(_labelTde);
    _tdTdeValor.appendChild(_inpTde);
    _tdDescontoDesc.appendChild(_labelDesconto);
    _tdDescontoValor.appendChild(_inpDesconto);

    _trComposicao3.appendChild(_tdSecCatDesc);
    _trComposicao3.appendChild(_tdSecCatValor);
    _trComposicao3.appendChild(_tdOutrosDesc);
    _trComposicao3.appendChild(_tdOutrosValor);
    _trComposicao3.appendChild(_tdGrisDesc);
    _trComposicao3.appendChild(_tdGrisValor);
    _trComposicao3.appendChild(_tdPedagioDesc);
    _trComposicao3.appendChild(_tdPedagioValor);
    _trComposicao3.appendChild(_tdTdeDesc);
    _trComposicao3.appendChild(_tdTdeValor);
    _trComposicao3.appendChild(_tdDescontoDesc);
    _trComposicao3.appendChild(_tdDescontoValor);


    tabela.appendChild(_trComposicao1);
    tabela.appendChild(_trComposicao2);
    tabela.appendChild(_trComposicao3);
    if (temPermissao_alteraprecocte == "false") {
        desabilitarCampos_alteraprecocte(index);
    }
    invisivel($("isSecCat_" + index));
    invisivel($("lbCobrarSecCat_" + index));
}

function habilitarCampos_alterainffiscal(index) {
    readOnly($("baseCalculoIcms_" + index), estiloMinReadOnly);
    notReadOnly($("aliquotaIcms_" + index));
    notReadOnly($("valorIcmsBarreira_" + index));
    $("stIcms_" + index).disabled = false;
}

function desabilitarCampos_alterainffiscal(index) {
    readOnly($("baseCalculoIcms_" + index), estiloMinReadOnly);
    readOnly($("aliquotaIcms_" + index), estiloMinReadOnly);
    readOnly($("valorIcmsBarreira_" + index), estiloMinReadOnly);
    $("stIcms_" + index).disabled = true;
}

function addConhecimentoLoteTotais(ctrc, index, tabela, classe, temPermissao_alterainffiscal) {
    var myCallRecalcular = callRecalcular.replace("index", index);
    var callCalcularIcms = callCalcularIcmsAll.replace("@@index", index);
    var _trValoresTotais = Builder.node("tr", {
        id: "trValoresTotais_" + index,
        className: classe
    });

    var _tdTotalPrestacaoDesc = Builder.node("td", {
        id: "tdTotalPrestacaoDesc_" + index,
        width: "14%",
        align: "right",
        colspan: 2
    });
    var _tdTotalPrestacaoValor = Builder.node("td", {
        id: "tdTotalPrestacaoValor_" + index,
        width: "6%",
        align: "left"
    });
    var _tdBaseCalcDesc = Builder.node("td", {
        id: "tdTotalPrestacaoDesc_" + index,
        width: "10%",
        align: "right"
    });
    var _tdBaseCalcValor = Builder.node("td", {
        id: "tdTotalPrestacaoValor_" + index,
        width: "6%",
        align: "left"
    });
    var _tdAliquotaDesc = Builder.node("td", {
        id: "tdIcmsDesc_" + index,
        width: "8%",
        align: "right"
    });
    var _tdAliquotaValor = Builder.node("td", {
        id: "tdIcmsValor_" + index,
        width: "6%",
        align: "left"
    });
    var _tdIcmsDesc = Builder.node("td", {
        id: "tdIcmsDesc_" + index,
        width: "6%",
        align: "right"
    });
    var _tdIcmsValor = Builder.node("td", {
        id: "tdIcmsValor_" + index,
        width: "6%",
        align: "left"
    });
    var _tdPisCofinsDesc = Builder.node("td", {
        id: "tdPisCofinsDesc_" + index,
        width: "10%",
        align: "right"
    });
    var _tdPisCofinsValor = Builder.node("td", {
        id: "tdPisCofinsValor_" + index,
        width: "6%",
        align: "left"
    });
    var _tdStICMSDesc = Builder.node("td", {
        id: "tdStICMSDesc_" + index,
        width: "6%",
        align: "right"
    });
    var _tdStICMSValor = Builder.node("td", {
        id: "tdStICMSValor_" + index,
        width: "6%",
        align: "left"
    });
    var _tdIcmsBarreiraDesc = Builder.node("td", {
        id: "tdIcmsBarreiraDesc_" + index,
        width: "6%",
        align: "right"
    });
    var _tdIcmsBarreiraValor = Builder.node("td", {
        id: "tdIcmsBarreiraValor_" + index,
        width: "6%",
        align: "left"
    });


    var labelFederais = "";

    if (embutirIr) {
        labelFederais += "/IR";
    }
    if (embutirCssl) {
        labelFederais += "/CSSL";
    }
    if (embutirPis) {
        labelFederais += "/PIS";
    }
    if (embutirCofins) {
        labelFederais += "/COFINS";
    }
    if (embutirInss) {
        labelFederais += "/INSS";
    }

    var label = labelFederais.lastIndexOf("/");
    if (label > -1) {
        var labelFede = labelFederais.replace("/", "").replace(" ", "/").replace(" ", "/").replace(" ", "/");
    }

    var _negrito1 = Builder.node("b");
    var _labelTotalPrestacao = Builder.node("label", {}, 'Total Prestação:');
    var _labelBaseCalculo = Builder.node("label", {}, 'Base Cálc:');
    var _labelAliquota = Builder.node("label", {}, 'Aliq.(%):');
    var _labelIcms = Builder.node("label", {}, 'ICMS/ISS:');
    var _labelPisCofins = Builder.node("label", {}, labelFede + ':');
    var _labelStIcms = Builder.node("label", {}, 'ST. ICMS:');
    var _labelIcmsBarreira = Builder.node("label", {}, 'ICMS Barreira:');


    var _inpTotalPrestacao = Builder.node("input", {
        id: "totalPrestacao_" + index,
        name: "totalPrestacao_" + index,
        type: "text",
        style: estiloTextRight,
        onKeyPress: callMascaraReais,
        size: sizeDecimal,
        value: colocarVirgula(ctrc.totalPrestacao)
    });
    var _inpTotalParcelas = Builder.node("input", {
        id: "totalParcelas_" + index,
        name: "totalParcelas_" + index,
        type: "hidden",
        style: estiloTextRight,
        onKeyPress: callMascaraReais,
        size: sizeDecimal,
        value: colocarVirgula(0)
    });
    var _inpBaseCalculoIcms = Builder.node("input", {
        id: "baseCalculoIcms_" + index,
        name: "baseCalculoIcms_" + index,
        type: "text",
        onKeyPress: callMascaraReais,
        className: estiloMin,
        size: sizeDecimal,
        style: estiloTextRight,
        maxLength: maxLengtPerc,
        onChange: callCalcularIcms + myCallRecalcular,
        value: colocarVirgula(ctrc.baseCalculoIcms)
    });

    var _inpAliquotaIcms = Builder.node("input", {
        id: "aliquotaIcms_" + index,
        name: "aliquotaIcms_" + index,
        type: "text",
        style: estiloTextRight,
        maxLength: maxLengtPerc,
        size: sizeDecimal,
        className: estiloMin,
        onChange: callCalcularIcms + myCallRecalcular,
        onKeyPress: callMascaraReais,
        value: colocarVirgula(ctrc.aliquotaIcms)
    });
    var _inpUtilizarNormativaGSF598GO = Builder.node("input", {
        id: "utilizarNormativaGSF598GO_" + index,
        name: "utilizarNormativaGSF598GO_" + index,
        type: "hidden",
        value: ""
    });
    var _inpReducaoBaseIcmsHConfig = Builder.node("input", {
        id: "percReducaoIcmsConfig_" + index,
        name: "percReducaoIcmsConfig_" + index,
        type: "hidden",
        value: ""
    });
    var _inpPercReducaoIcms = Builder.node("input", {
        id: "percReducaoIcms_" + index,
        name: "percReducaoIcms_" + index,
        type: "hidden",
        style: estiloTextRight,
        maxLength: maxLengtPerc,
        size: sizeDecimal,
        className: estiloMin,
        value: 0
    });
    var _inpAliquotaIcmsH = Builder.node("input", {
        id: "aliquotaIcmsH_" + index,
        name: "aliquotaIcmsH_" + index,
        type: "hidden",
        style: estiloTextRight,
        maxLength: maxLengtPerc,
        size: sizeDecimal,
        className: estiloMin,
        value: ctrc.aliquotaIcms
    });
    var _inpValorIcms = Builder.node("input", {
        id: "valorIcms_" + index,
        name: "valorIcms_" + index,
        type: "text",
        style: estiloTextRight,
        size: sizeDecimal,
        onKeyPress: callMascaraReais,
        value: colocarVirgula(ctrc.valorIcms)
    });
    var _inpValorPisCofins = Builder.node("input", {
        id: "valorPisCofins_" + index,
        name: "valorPisCofins_" + index,
        size: sizeDecimal,
        style: estiloTextRight,
        type: "text",
        onKeyPress: callMascaraReais,
        onChange: callCalcularIcms + myCallRecalcular,
        value: colocarVirgula(ctrc.valorPisCofins)
    });
    var _inpValorIcmsBarreira = Builder.node("input", {
        id: "valorIcmsBarreira_" + index,
        name: "valorIcmsBarreira_" + index,
        type: "text",
        className: estiloMin,
        onKeyPress: callMascaraReais,
        size: sizeDecimal,
        style: estiloTextRight,
        maxLength: maxLengtPerc,
        value: colocarVirgula(ctrc.valorIcmsBarreira)
    });
    var _inpStIcms_HIDDEN_REM = Builder.node("input", {
        id: "stIcmsRem_" + index,
        type: "hidden",
        className: estiloMin,
        name: "stIcmsRem_" + index,
        value: ctrc.remetente.stIcms
    });
    var _inpStIcms_HIDDEN_DES = Builder.node("input", {
        id: "stIcmsDest_" + index,
        type: "hidden",
        className: estiloMin,
        name: "stIcmsDest_" + index,
        value: ctrc.destinatario.stIcms
    });
    var _inpStIcms_HIDDEN_CON = Builder.node("input", {
        id: "stIcmsConsig_" + index,
        type: "hidden",
        className: estiloMin,
        name: "stIcmsConsig_" + index,
        value: ctrc.consignatario.stIcms
    });
    var _inpStIcms_HIDDEN_RED = Builder.node("input", {
        id: "stIcmsRed_" + index,
        type: "hidden",
        className: estiloMin,
        name: "stIcmsRed_" + index,
        value: ctrc.redespacho.stIcms
    });
    var _inpStIcms_HIDDEN_CONFIG = Builder.node("input", {
        id: "stIcmsConfig_" + index,
        type: "hidden",
        className: estiloMin,
        name: "stIcmsConfig_" + index,
        value: ""
    });

    var _inpStIcms_HIDDEN_GAMB = Builder.node("input", {
        id: "stIcmsGamb_" + index,
        type: "hidden",
        className: estiloMin,
        name: "stIcmsGamb_" + index,
        value: ""
    });
    var _inpStIcms = Builder.node("select", {
        id: "stIcms_" + index,
        className: estiloMin,
        name: "stIcms_" + index,
        value: ctrc.stICMS
    });

    var _inpValorPautaFiscal = Builder.node("input", {
        id: "valorPautaFiscal_" + index,
        style: estiloTextRight,
        name: "valorPautaFiscal_" + index,
        type: "hidden",
        value: colocarVirgula(ctrc.valorPautaFiscal)
    });

    var _inpValorCreditoPresumido = Builder.node("input", {
        id: "ValorCreditoPresumido_" + index,
        name: "ValorCreditoPresumido_" + index,
        type: "hidden"
    });

    var _inpUtilizarNormativaGSF129816GO = Builder.node("input", {
        id: "utilizarNormativaGSF129816GO_" + index,
        name: "utilizarNormativaGSF129816GO_" + index,
        type: "hidden"
    });

    povoarSelect(_inpStIcms, listaStICMS);
    _inpStIcms.style.width = "50px";

    readOnly(_inpTotalPrestacao, estiloMinReadOnly);
    readOnly(_inpBaseCalculoIcms, estiloMinReadOnly);
    readOnly(_inpValorIcms, estiloMinReadOnly);
    readOnly(_inpValorPisCofins, estiloMinReadOnly);

    _negrito1.appendChild(_labelTotalPrestacao);
    _tdTotalPrestacaoDesc.appendChild(_negrito1);
    _tdTotalPrestacaoValor.appendChild(_inpTotalPrestacao);
    _tdTotalPrestacaoValor.appendChild(_inpTotalParcelas);
    _tdBaseCalcDesc.appendChild(_labelBaseCalculo);
    _tdBaseCalcValor.appendChild(_inpBaseCalculoIcms);
    _tdAliquotaDesc.appendChild(_labelAliquota);
    _tdAliquotaValor.appendChild(_inpAliquotaIcms);
    _tdAliquotaValor.appendChild(_inpValorPautaFiscal);
    _tdAliquotaValor.appendChild(_inpAliquotaIcmsH);
    _tdAliquotaValor.appendChild(_inpPercReducaoIcms);
    _tdAliquotaValor.appendChild(_inpReducaoBaseIcmsHConfig);
    _tdAliquotaValor.appendChild(_inpUtilizarNormativaGSF598GO);
    _tdIcmsDesc.appendChild(_labelIcms);
    _tdIcmsValor.appendChild(_inpValorIcms);
    _tdIcmsValor.appendChild(_inpValorCreditoPresumido);
    _tdIcmsValor.appendChild(_inpUtilizarNormativaGSF129816GO);
    _tdPisCofinsDesc.appendChild(_labelPisCofins);
    _tdPisCofinsValor.appendChild(_inpValorPisCofins);
    _tdStICMSDesc.appendChild(_labelStIcms);
    _tdStICMSValor.appendChild(_inpStIcms);
    _tdStICMSValor.appendChild(_inpStIcms_HIDDEN_REM);
    _tdStICMSValor.appendChild(_inpStIcms_HIDDEN_DES);
    _tdStICMSValor.appendChild(_inpStIcms_HIDDEN_CON);
    _tdStICMSValor.appendChild(_inpStIcms_HIDDEN_CONFIG);
    _tdStICMSValor.appendChild(_inpStIcms_HIDDEN_RED);
    _tdStICMSValor.appendChild(_inpStIcms_HIDDEN_GAMB);
    _tdIcmsBarreiraDesc.appendChild(_labelIcmsBarreira);
    _tdIcmsBarreiraValor.appendChild(_inpValorIcmsBarreira);


    _trValoresTotais.appendChild(_tdTotalPrestacaoDesc);
    _trValoresTotais.appendChild(_tdTotalPrestacaoValor);
    _trValoresTotais.appendChild(_tdBaseCalcDesc);
    _trValoresTotais.appendChild(_tdBaseCalcValor);
    _trValoresTotais.appendChild(_tdAliquotaDesc);
    _trValoresTotais.appendChild(_tdAliquotaValor);
    _trValoresTotais.appendChild(_tdIcmsDesc);
    _trValoresTotais.appendChild(_tdIcmsValor);
    _trValoresTotais.appendChild(_tdPisCofinsDesc);
    _trValoresTotais.appendChild(_tdPisCofinsValor);
    _trValoresTotais.appendChild(_tdStICMSDesc);
    _trValoresTotais.appendChild(_tdStICMSValor);
    _trValoresTotais.appendChild(_tdIcmsBarreiraDesc);
    _trValoresTotais.appendChild(_tdIcmsBarreiraValor);

    tabela.appendChild(_trValoresTotais);

    if (temPermissao_alterainffiscal == "false") {
        desabilitarCampos_alterainffiscal(index);
    }
    //alterei o valor de comparação antes comparava com: "cteConfirmadoXML"
    if ($("layout").value == "4") {
        _inpStIcms.value = ctrc.stICMS;
    }
}
function addConhecimentoLoteTrLocais(ctrc, index, tabela, classe) {
    var apelido = "Locais"
    var callMyCallRecalcular = callRecalcular.replace("index", index);
    var callAlteraTipoTaxa = "alteraTipoTaxa('N'," + index + " );"
    var callGetPautaFiscal = "getPautaFiscal(" + index + ");"
    var callLocalizarCidadeOrigem = "abrirLocalizarCidadeOrigem(" + index + ");";
    var callLocalizarCidadeDestino = "abrirLocalizarCidadeDestino(" + index + ");";
    var _trLocais = Builder.node("tr", {
        id: "tr" + apelido + "_" + index,
        className: classe
    });

    var _tdCalculadoEntre = Builder.node("td", {
        id: "tdCalculadoEntre" + apelido + "_" + index
    });
    var _tdOrigemDesc = Builder.node("td", {
        id: "tdOrigemDesc" + apelido + "_" + index
    });
    var _tdOrigemValor = Builder.node("td", {
        id: "tdOrigemValor" + apelido + "_" + index
    });
    var _tdDestinoDesc = Builder.node("td", {
        id: "tdDestinoDesc" + apelido + "_" + index
    });
    var _tdDestinoValor = Builder.node("td", {
        id: "tdDestinoValor" + apelido + "_" + index
    });
    var _tdRotaDesc = Builder.node("td", {
        id: "tdRotaDesc" + apelido + "_" + index
    });
    var _tdRotaValor = Builder.node("td", {
        id: "tdRotaValor" + apelido + "_" + index
    });
    var _tdDistanciaKm = Builder.node("td", {
        id: "tdDistanciaKm" + apelido + "_" + index
    });
    var _tdUrbano = Builder.node("td", {
        id: "tdUrbano" + apelido + "_" + index
    });

    var _negrito = Builder.node("b");

    var _labelCalculadoEntre = Builder.node("label", {}, 'Calculado Entre');
    var _labelOrigem = Builder.node("label", {}, 'Origem:');
    var _labelDestino = Builder.node("label", {}, 'Destino:');
    var _labelRota = Builder.node("label", {}, 'Rota:');
    var _labelKm = Builder.node("label", {}, 'Km');
    var _labelUrbano = Builder.node("label", {}, 'Entrega Urbana');


    var _inpOrigem = Builder.node("input", {
        id: "cidadeOrigem" + apelido + "_" + index,
        name: "cidadeOrigem" + apelido + "_" + index,
        type: "text",
        className: estiloMin,
        value: ctrc.cidadeOrigem
    });
    var _inpOrigemUF = Builder.node("input", {
        id: "ufOrigem" + apelido + "_" + index,
        name: "ufOrigem" + apelido + "_" + index,
        type: "text",
        size: "3",
        className: estiloMin,
        style: "margin-left : 5px",
        value: ctrc.ufOrigem
    });
    var _inpOrigemIdH = Builder.node("input", {
        id: "cidadeOrigemId" + apelido + "_" + index,
        name: "cidadeOrigemId" + apelido + "_" + index,
        type: "hidden",
        className: estiloMin,
        value: ctrc.idCidadeOrigem
    });
    var _inpEnderecoEntregaId = Builder.node("input", {
        id: "enderecoEntregaId_" + index,
        name: "enderecoEntregaId" + apelido + "_" + index,
        type: "hidden",
        className: estiloMin,
        value: ctrc.enderecoEntregaId
    });
    var _inpEnderecoColetaId = Builder.node("input", {
        id: "enderecoColetaId_" + index,
        name: "enderecoColetaId" + apelido + "_" + index,
        type: "hidden",
        className: estiloMin,
        value: ctrc.enderecoColetaId
    });
    var _botLocOrigem = Builder.node("input", {
        id: "botLocOrigem_" + index,
        type: "button",
        value: "...",
        className: "inputBotaoMin",
        onClick: callLocalizarCidadeOrigem
    });
    var _inpDestino = Builder.node("input", {
        id: "cidadeDestino" + apelido + "_" + index,
        name: "cidadeDestino" + apelido + "_" + index,
        type: "text",
        className: estiloMin,
        value: ctrc.destinatario.cidade
    });
    var _inpDestinoUF = Builder.node("input", {
        id: "ufDestino" + apelido + "_" + index,
        name: "ufDestino" + apelido + "_" + index,
        type: "text",
        size: "3",
        className: estiloMin,
        style: "margin-left : 5px",
        value: ctrc.destinatario.uf
    });
    var _inpDestinoIdH = Builder.node("input", {
        id: "cidadeDestinoId" + apelido + "_" + index,
        name: "cidadeDestinoId" + apelido + "_" + index,
        className: estiloMin,
        type: "hidden",
        value: ctrc.destinatario.cidadeId
    });
    var _botLocDestino = Builder.node("input", {
        id: "botLocDestino_" + index,
        type: "button",
        value: "...",
        className: "inputBotaoMin",
        onClick: callLocalizarCidadeDestino
    });
    var _inpRota = Builder.node("input", {
        id: "rota" + apelido + "_" + index,
        name: "rota" + apelido + "_" + index,
        type: "text",
        size: "8",
        className: estiloMin,
        value: ctrc.rota
    });
    var _inpRotaIdh = Builder.node("input", {
        id: "rotaId" + apelido + "_" + index,
        name: "rotaId" + apelido + "_" + index,
        type: "hidden",
        size: "8",
        className: estiloMin,
        value: ctrc.idRota
    });
    var _inpTaxaRoubo = Builder.node("input", {
        id: "taxaRoubo" + apelido + "_" + index,
        name: "taxaRoubo" + apelido + "_" + index,
        type: "hidden",
        size: "8",
        className: estiloMin,
        value: ctrc.taxaRoubo
    });
    var _inpTaxaRouboUrbano = Builder.node("input", {
        id: "taxaRouboUrbano" + apelido + "_" + index,
        name: "taxaRouboUrbano" + apelido + "_" + index,
        type: "hidden",
        size: "8",
        className: estiloMin,
        value: ctrc.taxaRouboUrbano
    });
    var _inpTaxaTombamentoUrbano = Builder.node("input", {
        id: "taxaTombamentoUrbano" + apelido + "_" + index,
        name: "taxaTombamentoUrbano" + apelido + "_" + index,
        type: "hidden",
        size: "8",
        className: estiloMin,
        value: ctrc.taxaTombamentoUrbano
    });
    var _inpTaxaTombamento = Builder.node("input", {
        id: "taxaTombamento" + apelido + "_" + index,
        name: "taxaTombamento" + apelido + "_" + index,
        type: "hidden",
        size: "8",
        className: estiloMin,
        value: ctrc.taxaTombamento
    });
    var _inpIsUrbano = Builder.node("input", {
        id: "isUrbano" + apelido + "_" + index,
        name: "isUrbano" + apelido + "_" + index,
        type: "checkbox",
        className: estiloMin,
        value: ctrc.isUrbano
    });
    var _inpDistanciaKm = Builder.node("input", {
        id: "distanciaKm" + apelido + "_" + index,
        name: "distanciaKm" + apelido + "_" + index,
        type: "text",
        style: estiloTextRight,
        className: estiloMin,
        size: "8",
        onkeypress: callMascaraSoNumeros,
        maxLength: "8",
        value: ctrc.distancisKm,
        onChange: callGetPautaFiscal + callAlteraTipoTaxa
    });

    readOnly(_inpOrigem, estiloMinReadOnly);
    readOnly(_inpOrigemUF, estiloMinReadOnly);
    readOnly(_inpDestino, estiloMinReadOnly);
    readOnly(_inpDestinoUF, estiloMinReadOnly);
    readOnly(_inpRota, estiloMinReadOnly);

    _negrito.appendChild(_labelCalculadoEntre);
    _tdCalculadoEntre.appendChild(_negrito);
    _tdOrigemDesc.appendChild(_labelOrigem);
    _tdOrigemValor.appendChild(_inpOrigem);
    _tdOrigemValor.appendChild(_inpOrigemIdH);
    _tdOrigemValor.appendChild(_inpEnderecoEntregaId);
    _tdOrigemValor.appendChild(_inpEnderecoColetaId);
    _tdOrigemValor.appendChild(_inpOrigemUF);
    _tdOrigemValor.appendChild(_botLocOrigem);
    _tdDestinoDesc.appendChild(_labelDestino);
    _tdDestinoValor.appendChild(_inpDestino);
    _tdDestinoValor.appendChild(_inpDestinoIdH);
    _tdDestinoValor.appendChild(_inpDestinoUF);
    _tdDestinoValor.appendChild(_botLocDestino);
    _tdRotaDesc.appendChild(_labelRota);
    _tdRotaValor.appendChild(_inpRota);
    _tdRotaValor.appendChild(_inpRotaIdh);
    _tdDistanciaKm.appendChild(_inpDistanciaKm)
    _tdDistanciaKm.appendChild(_labelKm)
    _tdUrbano.appendChild(_inpTaxaRoubo);
    _tdUrbano.appendChild(_inpTaxaRouboUrbano);
    _tdUrbano.appendChild(_inpTaxaTombamento);
    _tdUrbano.appendChild(_inpTaxaTombamentoUrbano);
    _tdUrbano.appendChild(_inpIsUrbano);
    _tdUrbano.appendChild(_labelUrbano);

    _trLocais.appendChild(_tdCalculadoEntre);
    _trLocais.appendChild(_tdOrigemDesc);
    _trLocais.appendChild(_tdOrigemValor);
    _trLocais.appendChild(_tdDestinoDesc);
    _trLocais.appendChild(_tdDestinoValor);
    _trLocais.appendChild(_tdUrbano);
    _trLocais.appendChild(_tdRotaDesc);
    _trLocais.appendChild(_tdRotaValor);
    _trLocais.appendChild(_tdDistanciaKm);

    tabela.appendChild(_trLocais);

}

function desabilitarCampos_alteratipofretecte(index) {
    var apelido = "Tabela";
    $("tipoFrete" + apelido + "_" + index).disabled = true;
}

function habilitarCampos_alteratipofretecte(index) {
    var apelido = "Tabela";
    $("tipoFrete" + apelido + "_" + index).disabled = false;
}

function addConhecimentoLoteTrTabela(ctrc, index, tabela, classe, temPermissao_alteratipofretecte) {
    var callAlteraTipoTaxa = "alteraTipoTaxa('S'," + index + " );"
    var mostrarComposicaoFrete = "mostrarCamposComposicaoFreteLote(" + index + ")";
    var apelido = "Tabela";
    var arrayTipoProd = null;
    var _trTabela = Builder.node("tr", {
        id: "tr" + apelido + "_" + index,
        className: classe
    });

    var _tdQtdEntregasDesc = Builder.node("td", {
        id: "tdQtdEntregasDesc" + apelido + "_" + index,
        align: "right"
    });
    var _tdQtdEntregasValor = Builder.node("td", {
        id: "tdQtdEntregasValor" + apelido + "_" + index,
        align: "left"
    });
    var _tdQtdPalettsDesc = Builder.node("td", {
        id: "tdQtdEntregasDesc" + apelido + "_" + index,
        align: "right"
    });
    var _tdQtdPalettsValor = Builder.node("td", {
        id: "tdQtdEntregasValor" + apelido + "_" + index,
        align: "left"
    });
    var _tdTipoProdutoDesc = Builder.node("td", {
        id: "tdTipoProdutoDesc" + apelido + "_" + index,
        align: "right"
    });
    var _tdTipoProdutoValor = Builder.node("td", {
        id: "tdTipoProdutoValor" + apelido + "_" + index,
        align: "left"
    });
    var _tdTipoFreteDesc = Builder.node("td", {
        id: "tdTipoFreteDesc" + apelido + "_" + index,
        align: "right"
    });
    var _tdTipoFreteValor = Builder.node("td", {
        id: "tdTipoFreteValor" + apelido + "_" + index,
        align: "left"
    });
    var _tdTipoVeiculoDesc = Builder.node("td", {
        id: "tdTipoVeiculoDesc" + apelido + "_" + index,
        align: "right"
    });
    var _tdTipoVeiculoValor = Builder.node("td", {
        id: "tdTipoVeiculoValor" + apelido + "_" + index,
        align: "left"
    });
    var _tdTabelaUtilizadaDesc = Builder.node("td", {
        id: "TabelaUtilizadaDesc" + apelido + "_" + index,
        align: "right"
    });
    var _tdTabelaUtilizadaValor = Builder.node("td", {
        id: "TabelaUtilizadaValor" + apelido + "_" + index,
        align: "left"
    });

    var _labelQtdEntrega = Builder.node("label", {}, 'Entregas:');
    var _labelPallets = Builder.node("label", {}, 'Pallets:');
    var _labelTipoProduto = Builder.node("label", {}, 'Tipo Produto:');
    var _labelTipoFrete = Builder.node("label", {}, 'Tipo Frete:');
    var _labelTipoVeiculo = Builder.node("label", {}, 'Tipo Veículo:');
    var _labelTabelaUtilizada = Builder.node("label", {}, 'Tabela Utilizada:');
    var _brMinimo = Builder.node("br", {
        id: "brMinimo_" + index
    });
    var _labelUtilizaMinimo = Builder.node("label", {
        id: "labelMinimo_" + index,
        className: styleErro
    }, 'Utilizou Frete Minimo');

    var _inpQtdEntregas = Builder.node("input", {
        id: "qtdEntregas" + apelido + "_" + index,
        name: "qtdEntregas" + apelido + "_" + index,
        type: "text",
        className: estiloMin,
        onKeyPress: callMascaraSoNumeros,
        maxlength: maxLengtDefault,
        style: estiloTextRight,
        size: "5",
        value: ctrc.qtdEntregas
    });
    var _inpQtdPallets = Builder.node("input", {
        id: "qtdPallets" + apelido + "_" + index,
        name: "qtdPallets" + apelido + "_" + index,
        type: "text",
        style: estiloTextRight,
        className: estiloMin,
        onKeyPress: callMascaraSoNumeros,
        maxlength: maxLengtDefault,
        size: "5",
        value: ctrc.qtdPallets
    });
    var _inpTipoProduto_Hidden_Gamb = Builder.node("input", {
        id: "tipoProduto" + apelido + "Gamb" + "_" + index,
        name: "tipoProduto" + apelido + "Gamb" + "_" + index,
        value: "",
        type: "hidden"
    });
    var _inpTipoProduto = Builder.node("select", {
        id: "tipoProduto" + apelido + "_" + index,
        name: "tipoProduto" + apelido + "_" + index,
        type: "text",
        className: estiloMin,
        onChange: callAlteraTipoTaxa
    });


    var optProduto = Builder.node("option", {
        value: "0"
    });
    Element.update(optProduto, "NENHUM");

    arrayTipoProd = (ctrc.consignatario != null && ctrc.consignatario.listaTipoProduto != null && ctrc.consignatario.listaTipoProduto.size() > 0 ? ctrc.consignatario.listaTipoProduto : listaTipoProdutoAll);
    if (arrayTipoProd.length > 1 || arrayTipoProd.length == 0) {
        _inpTipoProduto.appendChild(optProduto);
    }
    povoarSelect(_inpTipoProduto, arrayTipoProd);
    jQuery("#" + _inpTipoProduto.id + " option").each(function () {
        if (jQuery(this).val() == ctrc.tipoProduto) {
            jQuery(this).attr('selected', 'selected');
        }
    });

    var _inpTipoFrete = Builder.node("select", {
        id: "tipoFrete" + apelido + "_" + index,
        name: "tipoFrete" + apelido + "_" + index,
        type: "text",
        className: estiloMin,
        onChange: callAlteraTipoTaxa + mostrarComposicaoFrete
    });

    var _inpTipoFrete_Hidden_Gamb = Builder.node("input", {
        id: "tipoFrete" + apelido + "Gamb" + "_" + index,
        name: "tipoFrete" + apelido + "Gamb" + "_" + index,
        value: "",
        type: "hidden"
    });

    var _inpTipoTaxa = Builder.node("input", {
        id: "tipoTaxa_" + index,
        name: "tipoTaxa_" + index,
        value: "",
        type: "hidden"
    });

    var optFrete = null;
    povoarSelect(_inpTipoFrete, listaTipoFreteAll);
    _inpTipoFrete.value = ctrc.tipoFrete;
//    jQuery("#"+_inpTipoFrete.id+" option").each(function(){
//        if(jQuery(this).val() == ctrc.tipoFrete){
//            jQuery(this).attr('selected','selected');
//        }
//        });
    var _inpTipoVeiculo_Hidden_Gamb = Builder.node("input", {
        id: "tipoVeiculo" + apelido + "Gamb" + "_" + index,
        name: "tipoVeiculo" + apelido + "Gamb" + "_" + index,
        value: "",
        type: "hidden"
    });
    var _inpTipoVeiculo = Builder.node("select", {
        id: "tipoVeiculo" + apelido + "_" + index,
        name: "tipoVeiculo" + apelido + "_" + index,
        type: "text",
        className: estiloMin,
        onChange: callAlteraTipoTaxa + "calcularFreteCarreteiro();"
    });


    var optVeiculo = Builder.node("option", {
        value: "0"
    });
    Element.update(optVeiculo, "Nenhum");
    _inpTipoVeiculo.appendChild(optVeiculo);
//    for (var i = 0; i < listaTipoVeiculoAll.length; i++) {
//        optVeiculo = Builder.node("option", {
//            value: listaTipoVeiculoAll[i].valor
//        });
//        Element.update(optVeiculo, listaTipoVeiculoAll[i].descricao);
//        _inpTipoVeiculo.appendChild(optVeiculo);
//    }
//    //task 904 da Sprint, dia 09/06/2015 - poder replicar o select de tipo veiculo.
//    if (isExisteOption(_inpTipoVeiculo, ctrc.tipoVeiculo)) {
//        _inpTipoVeiculo.value = ctrc.tipoVeiculo;
//    } else {
//        _inpTipoVeiculo.selectedIndex = 0;
//    }
    povoarSelect(_inpTipoVeiculo, listaTipoVeiculoAll);
    jQuery("#" + _inpTipoVeiculo.id + " option").each(function () {
        if (jQuery(this).val() == ctrc.tipoVeiculo) {
            jQuery(this).attr('selected', 'selected');
        }
    });
    var _inpTabelaUtilizada = Builder.node("input", {
        id: "tabelaUtilizada" + apelido + "_" + index,
        name: "tabelaUtilizada" + apelido + "_" + index,
        type: "text",
        className: estiloMin,
        onKeyPress: callMascaraSoNumeros,
        maxlength: maxLengtDefault,
        size: "5",
        value: ctrc.tabelaUtilizada
    });
    var _inpPodeAlterarH = Builder.node("input", {
        id: "podeAlterar_" + index,
        name: "podeAlterar_" + index,
        type: "hidden",
        value: ctrc.isPodeAlterar
    });
    var _inpNumeroH = Builder.node("input", {
        id: "numero_" + index,
        name: "numero_" + index,
        type: "hidden",
        value: ctrc.numero
    });
    var _inpSerieH = Builder.node("input", {
        id: "serie_" + index,
        name: "serie_" + index,
        type: "hidden",
        value: ctrc.serie
    });
    var _inpChaveCteH = Builder.node("input", {
        id: "chaveCte_" + index,
        name: "chaveCte_" + index,
        type: "hidden",
        value: ctrc.chaveCte
    });
    var _inpEmissaoCteH = Builder.node("input", {
        id: "emissaoEm_" + index,
        name: "emissaoEm_" + index,
        type: "hidden",
        value: (ctrc.emissaoEm != undefined && ctrc.emissaoEm != '' ? ctrc.emissaoEm : jQuery("#dataEmissaoCTe").val())
    });
    var _inpEmissaoAsH = Builder.node("input", {
        id: "emissaoAs_" + index,
        name: "emissaoAs_" + index,
        type: "hidden",
        value: ctrc.emissaoAs
    });
    var _inpSubContratacaoH = Builder.node("input", {
        id: "isSubContrato_" + index,
        name: "isSubContrato_" + index,
        type: "hidden",
        value: ctrc.subContrato
    });

    readOnly(_inpTabelaUtilizada, estiloMinReadOnly);

    _tdQtdEntregasDesc.appendChild(_labelQtdEntrega);
    _tdQtdEntregasValor.appendChild(_inpQtdEntregas);
    _tdQtdPalettsDesc.appendChild(_labelPallets);
    _tdQtdPalettsValor.appendChild(_inpQtdPallets);
    _tdTipoProdutoDesc.appendChild(_labelTipoProduto);
    _tdTipoProdutoValor.appendChild(_inpTipoProduto);
    _tdTipoProdutoValor.appendChild(_inpTipoProduto_Hidden_Gamb);
    _tdTipoFreteDesc.appendChild(_labelTipoFrete);
    _tdTipoFreteValor.appendChild(_inpTipoFrete);
    _tdTipoFreteValor.appendChild(_inpTipoFrete_Hidden_Gamb);
    _tdTipoFreteValor.appendChild(_inpTipoTaxa);
    _tdTipoVeiculoDesc.appendChild(_labelTipoVeiculo);
    _tdTipoVeiculoValor.appendChild(_inpTipoVeiculo);
    _tdTipoVeiculoValor.appendChild(_inpTipoVeiculo_Hidden_Gamb);
    _tdTabelaUtilizadaDesc.appendChild(_labelTabelaUtilizada);
    _tdTabelaUtilizadaDesc.appendChild(_brMinimo);
    _tdTabelaUtilizadaDesc.appendChild(_labelUtilizaMinimo);
    _tdTabelaUtilizadaValor.appendChild(_inpTabelaUtilizada);
    _tdTabelaUtilizadaValor.appendChild(_inpPodeAlterarH);
    _tdTabelaUtilizadaValor.appendChild(_inpNumeroH);
    _tdTabelaUtilizadaValor.appendChild(_inpSerieH);
    _tdTabelaUtilizadaValor.appendChild(_inpChaveCteH);
    _tdTabelaUtilizadaValor.appendChild(_inpEmissaoCteH);
    _tdTabelaUtilizadaValor.appendChild(_inpEmissaoAsH);
    _tdTabelaUtilizadaValor.appendChild(_inpSubContratacaoH);

    _trTabela.appendChild(_tdQtdEntregasDesc);
    _trTabela.appendChild(_tdQtdEntregasValor);
    _trTabela.appendChild(_tdQtdPalettsDesc);
    _trTabela.appendChild(_tdQtdPalettsValor);
    _trTabela.appendChild(_tdTipoProdutoDesc);
    _trTabela.appendChild(_tdTipoProdutoValor);
    _trTabela.appendChild(_tdTipoFreteDesc);
    _trTabela.appendChild(_tdTipoFreteValor);
    _trTabela.appendChild(_tdTipoVeiculoDesc);
    _trTabela.appendChild(_tdTipoVeiculoValor);
    _trTabela.appendChild(_tdTabelaUtilizadaDesc);
    _trTabela.appendChild(_tdTabelaUtilizadaValor);

    tabela.appendChild(_trTabela);

    invisivel(_brMinimo);
    invisivel(_labelUtilizaMinimo);

    //se nao tem permissao alteratipofretecte, ficara indisponivel.
    if (temPermissao_alteratipofretecte == "false") {
        desabilitarCampos_alteratipofretecte(index);
    }
}
//outros
function addConhecimentoLoteTrOutros(ctrc, index, tabela, classe) {
    try {
        var apelido = "Outros";
        var callAbrirLocalizarObservacao = "abrirLocalizarObservacao(" + index + ");";
        var callAbrirLocalizarVendedor = "abrirLocalizarVendedor(" + index + ");";
        var callAbrirLocalizarRepresentante = "abrirLocalizarRepresentante(" + index + ");";
        var callAbrirLocalizarMotorista = "abrirLocalizarMotorista(" + index + ");";
        var callAbrirLocalizarVeiculo = "abrirLocalizarVeiculo(" + index + ");";
        var callAbrirLocalizarCarreta = "abrirLocalizarCarreta(" + index + ");";
        var callAbrirLocalizarBitrem = "abrirLocalizarBitrem(" + index + ");";
        var callAbrirLocalizarObservacaoFisco = "abrirLocalizarObservacaoFisco(" + index + ");";

        var _trOutros = Builder.node("tr", {
            id: "tr" + apelido + "_" + index,
            className: classe
        });
        var _trOutros2 = Builder.node("tr", {
            id: "tr" + apelido + "2_" + index,
            className: classe
        });
        var _trOutros3 = Builder.node("tr", {
            id: "tr" + apelido + "3_" + index,
            className: classe
        });
        var _trOutros4 = Builder.node("tr", {
            id: "tr" + apelido + "4_" + index,
            className: classe
        });
        var _trOutros5 = Builder.node("tr", {
            id: "tr" + apelido + "5_" + index,
            className: classe
        });

        var _trOutros6 = Builder.node("tr", {
            id: "tr" + apelido + "6_" + index,
            className: classe
        });

        var _tdObservacaoDesc = Builder.node("td", {
            id: "tdObservacaoDesc" + apelido + "_" + index,
            align: "right",
            rowSpan: "6",
            width: '4%'
        });
        var _tdObservacaoFiscoDesc = Builder.node("td", {
            id: "tdObservacaoFiscoDesc" + apelido + "_" + index,
            align: "right",
            rowSpan: "6",
            width: '4%'
        });
        var _divObservacaoValor = Builder.node("div", {
            id: "divObservacaoDesc" + apelido + "_" + index,
            align: "left"
        });
        var _divObservacaoFiscoValor = Builder.node("div", {
            id: "divObservacaoFiscoDesc" + apelido + "_" + index,
            align: "left"
        });
        var _tdObservacaoValor = Builder.node("td", {
            id: "tdObservacaoValor" + apelido + "_" + index,
            align: "left",
            rowSpan: "6",
            width: "23%"
        });
        var _tdObservacaoFiscoValor = Builder.node("td", {
            id: "tdObservacaoFiscoValor" + apelido + "_" + index,
            align: "left",
            rowSpan: "6",
            width: "23%"
        });
        var _tdVendedorDesc = Builder.node("td", {
            id: "tdVendedorDesc" + apelido + "_" + index,
            align: "right"
        });
        var _tdVendedorComissaoDesc = Builder.node("td", {
            id: "tdVendedorComissaoDesc" + apelido + "_" + index,
            align: "right"
        });
        var _tdNumContainerDesc = Builder.node("td", {
            id: "tdNumContainerDesc" + apelido + "_" + index,
            align: "right"
        });
        var _tdVendedorValor = Builder.node("td", {
            id: "tdVendedorValor" + apelido + "_" + index,
            align: "left"
        });
        var _tdVendedorComissaoValor = Builder.node("td", {
            id: "tdVendedorComissaoValor" + apelido + "_" + index,
            align: "left"
        });
        var _tdPrevisaoEntregaDesc = Builder.node("td", {
            id: "tdPrevisaoEntregaDesc" + apelido + "_" + index,
            align: "right"
        });
        var _tdPrevisaoEntregaValor = Builder.node("td", {
            id: "tdPrevisaoEntregaValor" + apelido + "_" + index,
            align: "left"
        });
        var _tdRepresentanteDesc = Builder.node("td", {
            id: "tdRepresentanteDesc" + apelido + "_" + index,
            align: "right"
        });
        var _tdRepresentanteValor = Builder.node("td", {
            id: "tdRepresentanteValor" + apelido + "_" + index,
            colSpan: "3",
            align: "left"
        });
        var _tdNumContainerValor = Builder.node("td", {
            id: "tdNumContainerValor" + apelido + "_" + index,
            align: "left"
        });
        var _tdNumCargaDesc = Builder.node("td", {
            id: "tdNumCargaDesc" + apelido + "_" + index,
            align: "right"
        });
        var _tdNumPedidoDesc = Builder.node("td", {
            id: "tdNumPedidoDesc" + apelido + "_" + index,
            align: "right"
        });
        var _tdNumCargaValor = Builder.node("td", {
            id: "tdNumCargaValor" + apelido + "_" + index,
            colSpan: "1",
            align: "left"
        });
        var _tdNumPedidoValor = Builder.node("td", {
            id: "tdNumPedidoValor" + apelido + "_" + index,
            colSpan: "3",
            align: "left"
        });
        var _tdMotoristaDesc = Builder.node("td", {
            id: "tdMotoristaDesc" + apelido + "_" + index,
            align: "right"
        });
        var _tdMotoristaValor = Builder.node("td", {
            id: "tdMotoristaValor" + apelido + "_" + index,
            align: "left"
        });

        var _tdVeiculoDesc = Builder.node("td", {
            id: "tdVeiculoDesc" + apelido + "_" + index,
            align: "right"
        });

        var _tdVeiculoValor = Builder.node("td", {
            id: "tdVeiculoValor" + apelido + "_" + index,
            align: "left"
        });

        var _tdCarretaDesc = Builder.node("td", {
            id: "tdCarretaDesc" + apelido + "_" + index,
            align: "right"
        });

        var _tdCarretaValor = Builder.node("td", {
            id: "tdCarretaValor" + apelido + "_" + index,
            align: "left"
        });

        var _tdBitremDesc = Builder.node("td", {
            id: "tdBitremDesc" + apelido + "_" + index,
            align: "right"
        });

        var _tdBitremValor = Builder.node("td", {
            id: "tdBitremValor" + apelido + "_" + index,
            align: "left"
        });

        var _labelObservacao = Builder.node("label", {}, 'Observação:');
        var _labelObservacaoFisco = Builder.node("label", {}, 'OBS Reservado ao Fisco:');
        var _labelVendedor = Builder.node("label", {}, 'Vendedor:');
        var _labelVendedorComissao = Builder.node("label", {}, '%:');
        var _labelPrevisaoEntrega = Builder.node("label", {}, 'Prev. Entrega:');
        var _labelRepresentante = Builder.node("label", {}, 'Representante:');
        var _labelNumContainer = Builder.node("label", {}, 'Nº Container:');
        var _labelNumCarga = Builder.node("label", {}, 'Nº Carga:');
        var _labelNumPedido = Builder.node("label", {}, 'Nº Pedido:');
        var _labelMotorista = Builder.node("label", {}, 'Motorista:');
        var _labelVeiculo = Builder.node("label", {}, 'Veiculo:');
        var _labelCarreta = Builder.node("label", {}, 'Carreta:');
        var _labelBitrem = Builder.node("label", {}, 'Bitrem:');
        //        var _labelRepresentante = Builder.node("label",{},'Representante:');


        var _inpObservacao_Hidden_Gamb = Builder.node("input", {
            id: "observacao" + apelido + "Gamb_" + index,
            name: "observacao" + apelido + "Gamb_" + index,
            type: "hidden",
            value: ""
        });
        var _inpObservacao = Builder.node("textarea", {
            id: "observacao" + apelido + "_" + index,
            name: "observacao" + apelido + "_" + index,
            type: "text",
            className: estiloMin,
            rows: "5",
            cols: "50"
        });
        _inpObservacao.innerHTML = ctrc.observacao;

        var _inpObservacaoFisco = Builder.node("textarea", {
            id: "observacaoFisco" + apelido + "_" + index,
            name: "observacaoFisco" + apelido + "_" + index,
            type: "text",
            className: estiloMin,
            rows: "5",
            cols: "50"
        });

        var _inpObservacaoComplementar = Builder.node("input", {
            id: "observacaoComplementar" + apelido + "_" + index,
            name: "observacaoComplementar" + apelido + "_" + index,
            type: "hidden",
            value: ctrc.observacaoComplementar
        });
//        _inpObservacaoComplementar.innerHTML = ctrc.observacaoComplementar;

        var _botLocObservacao = Builder.node("input", {
            id: "botLocObservacao_" + index,
            type: "button",
            value: "...",
            className: "inputBotaoMin",
            onClick: callAbrirLocalizarObservacao
        });

        var _botLocObservacaoFisco = Builder.node("input", {
            id: "botLocObservacaoFisco_" + index,
            type: "button",
            value: "...",
            className: "inputBotaoMin",
            onClick: callAbrirLocalizarObservacaoFisco
        });

        var _inpVendedor = Builder.node("input", {
            id: "vendedor" + apelido + "_" + index,
            name: "vendedor" + apelido + "_" + index,
            type: "text",
            size: "20",
            className: estiloMin,
            value: ""
        });
        var _inpVendedorComissao = Builder.node("input", {
            id: "vendedorComissao" + apelido + "_" + index,
            name: "vendedorComissao" + apelido + "_" + index,
            type: "text",
            size: "5",
            style: estiloTextRight,
            className: estiloMin,
            onKeyPress: callMascaraReais,
            value: "0,00"
        });
        readOnly(_inpVendedor, estiloMinReadOnly);
        var _inpVendedorIdH = Builder.node("input", {
            id: "vendedorId" + apelido + "_" + index,
            name: "vendedorId" + apelido + "_" + index,
            type: "hidden",
            className: estiloMin,
            value: "0"
        });
        var _botLocVendedor = Builder.node("input", {
            id: "botLocVendedor_" + index,
            type: "button",
            value: "...",
            className: "inputBotaoMin",
            onClick: callAbrirLocalizarVendedor
        });
        var _imgLimparVendedor = Builder.node("img", {
            src: "img/borracha.gif",
            className: "imagemLinkSpc",
            border: "0",
            onClick: "limparCampo(" + _inpVendedor.id + ", " + _inpVendedorIdH.id + ");"
        });
        var _inpRepresentante = Builder.node("input", {
            id: "representante" + apelido + "_" + index,
            name: "representante" + apelido + "_" + index,
            type: "text",
            size: "30",
            className: estiloMin,
            value: ctrc.representante.razaoSocial
        });
        var _inpNumContainer = Builder.node("input", {
            id: "numContainer" + apelido + "_" + index,
            name: "numContainer" + apelido + "_" + index,
            type: "text",
            size: "12",
            className: estiloMin,
            value: ctrc.numeroContainer
        });
        var _inpNumCarga = Builder.node("input", {
            id: "numCarga" + apelido + "_" + index,
            name: "numCarga" + apelido + "_" + index,
            type: "text",
            size: "20",
            maxlength: "20",
            className: estiloMin,
            value: ctrc.numeroCarga
        });
        var _inpPedidoCarga = Builder.node("input", {
            id: "numPedido" + apelido + "_" + index,
            name: "numPedido" + apelido + "_" + index,
            type: "text",
            size: "12",
            className: estiloMin,
            value: ctrc.pedido
        });
        readOnly(_inpRepresentante, estiloMinReadOnly);
        var _inpRepresentanteIdH = Builder.node("input", {
            id: "representanteId" + apelido + "_" + index,
            name: "representanteId" + apelido + "_" + index,
            type: "hidden",
            className: estiloMin,
            value: ctrc.representante.id
        });
        var _botLocRepresentante = Builder.node("input", {
            id: "botLocRepresentante_" + index,
            type: "button",
            value: "...",
            className: "inputBotaoMin",
            onClick: callAbrirLocalizarRepresentante
        });
        var _imgLimparRepresentante = Builder.node("img", {
            src: "img/borracha.gif",
            className: "imagemLinkSpc",
            border: "0",
            onClick: "limparCampo(" + _inpRepresentante.id + ", " + _inpRepresentanteIdH.id + ");"
        });
        var _inpPrevisaoEntrega = Builder.node("input", {
            id: "previsaoEntrega_" + index,
            name: "previsaoEntrega_" + index,
            type: "text",
            className: "fieldDateMin",
            maxlength: 10,
            onkeypress: callFmtData,
            size: 10,
            value: (ctrc.previsaoEntrega.trim() == "" ? dataAtual : ctrc.previsaoEntrega)
        });

        var _inpMotorista = Builder.node("input", {
            id: "motorista_" + apelido + "_" + index,
            name: "motorista_" + apelido + "_" + index,
            type: "text",
            className: estiloMin,
            value: ctrc.motorista
        });
        readOnly(_inpMotorista, estiloMinReadOnly);

        var _inpMotoristaId = Builder.node("input", {
            id: "motoristaId_" + apelido + "_" + index,
            name: "motoristaId_" + apelido + "_" + index,
            type: "hidden",
            className: estiloMin,
            value: ctrc.idMotorista
        });

        var _botLocMotorista = Builder.node("input", {
            id: "botLocMotorista_" + index,
            type: "button",
            value: "...",
            className: "inputBotaoMin",
            onClick: callAbrirLocalizarMotorista
        });
        var _imgLimparMotorista = Builder.node("img", {
            src: "img/borracha.gif",
            className: "imagemLinkSpc",
            border: "0",
            onClick: "limparCampo(" + _inpMotorista.id + ", " + _inpMotoristaId.id + ");"
        });

        var _inpVeiculo = Builder.node("input", {
            id: "veiculo_" + apelido + "_" + index,
            name: "veiculo_" + apelido + "_" + index,
            type: "text",
            className: estiloMin,
            value: ctrc.veiculo
        });
        readOnly(_inpVeiculo, estiloMinReadOnly);

        var _inpVeiculoId = Builder.node("input", {
            id: "veiculoId_" + apelido + "_" + index,
            name: "veiculoId_" + apelido + "_" + index,
            type: "hidden",
            className: estiloMin,
            value: ctrc.idVeiculo
        });

        var _botLocVeiculo = Builder.node("input", {
            id: "botLocVeiculo_" + index,
            type: "button",
            value: "...",
            className: "inputBotaoMin",
            onClick: callAbrirLocalizarVeiculo
        });
        var _imgLimparVeiculo = Builder.node("img", {
            src: "img/borracha.gif",
            className: "imagemLinkSpc",
            border: "0",
            onClick: "limparCampo(" + _inpVeiculo.id + ", " + _inpVeiculoId.id + ");"
        });

        if (ctrc.veiculo != "" && ctrc.idVeiculo == "0") {
            _inpVeiculo.style.color = "red";
            setErroCtrc(index, " O veiculo com placa '" + ctrc.veiculo + "' não foi encontrado!.\n");
        }

        var _inpCarreta = Builder.node("input", {
            id: "carreta_" + apelido + "_" + index,
            name: "carreta_" + apelido + "_" + index,
            type: "text",
            className: estiloMin,
            value: ctrc.carreta
        });

        readOnly(_inpCarreta, estiloMinReadOnly);
        var _inpCarretaId = Builder.node("input", {
            id: "carretaId_" + apelido + "_" + index,
            name: "carretaId_" + apelido + "_" + index,
            type: "hidden",
            className: estiloMin,
            value: ctrc.idCarreta
        });
        var _botLocCarreta = Builder.node("input", {
            id: "botLocCarreta_" + index,
            type: "button",
            value: "...",
            className: "inputBotaoMin",
            onClick: callAbrirLocalizarCarreta
        });
        var _imgLimparCarreta = Builder.node("img", {
            src: "img/borracha.gif",
            className: "imagemLinkSpc",
            border: "0",
            onClick: "limparCampo(" + _inpCarreta.id + ", " + _inpCarretaId.id + ");"
        });

        if (ctrc.carreta != "" && ctrc.idCarreta == "0") {
            _inpCarreta.style.color = "red";
            setErroCtrc(index, " A carreta com placa '" + ctrc.carreta + "' não foi encontrado!.\n");
        }

        var _inpBitrem = Builder.node("input", {
            id: "bitrem_" + apelido + "_" + index,
            name: "bitrem_" + apelido + "_" + index,
            type: "text",
            className: estiloMin,
            value: ctrc.bitrem
        });

        readOnly(_inpBitrem, estiloMinReadOnly);

        var _inpBitremId = Builder.node("input", {
            id: "bitremId_" + apelido + "_" + index,
            name: "bitremId_" + apelido + "_" + index,
            type: "hidden",
            className: estiloMin,
            value: ctrc.idBitrem
        });
        var _botLocBitrem = Builder.node("input", {
            id: "botLocBitrem_" + index,
            type: "button",
            value: "...",
            className: "inputBotaoMin",
            onClick: callAbrirLocalizarBitrem
        });
        var _imgLimparBitrem = Builder.node("img", {
            src: "img/borracha.gif",
            className: "imagemLinkSpc",
            border: "0",
            onClick: "limparCampo(" + _inpBitrem.id + ", " + _inpBitremId.id + ");"
        });

        if (ctrc.bitrem != "" && ctrc.idBitrem == "0") {
            _inpBitrem.style.color = "red";
            setErroCtrc(index, " O bitrem com placa '" + ctrc.bitrem + "' não foi encontrado!.\n");
        }

        _tdObservacaoDesc.appendChild(_labelObservacao);
        _divObservacaoValor.appendChild(_inpObservacao);
        _divObservacaoValor.appendChild(_inpObservacao_Hidden_Gamb);
        _divObservacaoValor.appendChild(_inpObservacaoComplementar);
        _divObservacaoValor.appendChild(_botLocObservacao);
        _tdObservacaoValor.appendChild(_divObservacaoValor);

        _tdObservacaoFiscoDesc.appendChild(_labelObservacaoFisco);
        _divObservacaoFiscoValor.appendChild(_inpObservacaoFisco);
        _divObservacaoFiscoValor.appendChild(_botLocObservacaoFisco);
        _tdObservacaoFiscoValor.appendChild(_divObservacaoFiscoValor);

        _tdVendedorDesc.appendChild(_labelVendedor);
        _tdVendedorValor.appendChild(_inpVendedor);
        _tdVendedorValor.appendChild(_inpVendedorIdH);
        _tdVendedorValor.appendChild(_botLocVendedor);
        _tdVendedorValor.appendChild(_imgLimparVendedor);
        _tdVendedorComissaoDesc.appendChild(_labelVendedorComissao);
        _tdVendedorComissaoValor.appendChild(_inpVendedorComissao);

        _tdRepresentanteDesc.appendChild(_labelRepresentante);
        _tdRepresentanteValor.appendChild(_inpRepresentante);
        _tdRepresentanteValor.appendChild(_inpRepresentanteIdH);
        _tdRepresentanteValor.appendChild(_botLocRepresentante);
        _tdRepresentanteValor.appendChild(_imgLimparRepresentante);

        _tdNumContainerDesc.appendChild(_labelNumContainer);
        _tdNumContainerValor.appendChild(_inpNumContainer);
        _tdPrevisaoEntregaDesc.appendChild(_labelPrevisaoEntrega);
        _tdPrevisaoEntregaValor.appendChild(_inpPrevisaoEntrega);

        _tdNumCargaDesc.appendChild(_labelNumCarga);
        _tdNumCargaValor.appendChild(_inpNumCarga);

        _tdNumPedidoDesc.appendChild(_labelNumPedido);
        _tdNumPedidoValor.appendChild(_inpPedidoCarga);

        _tdMotoristaDesc.appendChild(_labelMotorista);
        _tdMotoristaValor.appendChild(_inpMotorista);
        _tdMotoristaValor.appendChild(_inpMotoristaId);
        _tdMotoristaValor.appendChild(_botLocMotorista);
        _tdMotoristaValor.appendChild(_imgLimparMotorista);

        _tdVeiculoDesc.appendChild(_labelVeiculo);
        _tdVeiculoValor.appendChild(_inpVeiculo);
        _tdVeiculoValor.appendChild(_inpVeiculoId);
        _tdVeiculoValor.appendChild(_botLocVeiculo);
        _tdVeiculoValor.appendChild(_imgLimparVeiculo);

        _tdCarretaDesc.appendChild(_labelCarreta);
        _tdCarretaValor.appendChild(_inpCarreta);
        _tdCarretaValor.appendChild(_inpCarretaId);
        _tdCarretaValor.appendChild(_botLocCarreta);
        _tdCarretaValor.appendChild(_imgLimparCarreta);

        _tdBitremDesc.appendChild(_labelBitrem);
        _tdBitremValor.appendChild(_inpBitrem);
        _tdBitremValor.appendChild(_inpBitremId);
        _tdBitremValor.appendChild(_botLocBitrem);
        _tdBitremValor.appendChild(_imgLimparBitrem);

        _trOutros.appendChild(_tdObservacaoDesc);
        _trOutros.appendChild(_tdObservacaoValor);
        _trOutros.appendChild(_tdObservacaoFiscoDesc);
        _trOutros.appendChild(_tdObservacaoFiscoValor);
        _trOutros.appendChild(_tdVendedorDesc);
        _trOutros.appendChild(_tdVendedorValor);
        _trOutros.appendChild(_tdVendedorComissaoDesc);
        _trOutros.appendChild(_tdVendedorComissaoValor);

        _trOutros2.appendChild(_tdRepresentanteDesc);
        _trOutros2.appendChild(_tdRepresentanteValor);

        _trOutros3.appendChild(_tdPrevisaoEntregaDesc);
        _trOutros3.appendChild(_tdPrevisaoEntregaValor);
        _trOutros3.appendChild(_tdNumContainerDesc);
        _trOutros3.appendChild(_tdNumContainerValor);

        _trOutros4.appendChild(_tdNumCargaDesc);
        _trOutros4.appendChild(_tdNumCargaValor);

        _trOutros4.appendChild(_tdNumPedidoDesc);
        _trOutros4.appendChild(_tdNumPedidoValor);


        _trOutros5.appendChild(_tdMotoristaDesc);
        _trOutros5.appendChild(_tdMotoristaValor);

        _trOutros5.appendChild(_tdVeiculoDesc);
        _trOutros5.appendChild(_tdVeiculoValor);

        _trOutros6.appendChild(_tdCarretaDesc);
        _trOutros6.appendChild(_tdCarretaValor);
        _trOutros6.appendChild(_tdBitremDesc);
        _trOutros6.appendChild(_tdBitremValor);

        tabela.appendChild(_trOutros);
        tabela.appendChild(_trOutros2);
        tabela.appendChild(_trOutros3);
        tabela.appendChild(_trOutros4);
        tabela.appendChild(_trOutros5);
        tabela.appendChild(_trOutros6);

    } catch (e) {
        alert(e);
        console.log(e);
    }

}
function removerCtrc(index) {
    try {
        var max = parseInt($("maxConhecimento").value, 10);
        var countExiste = 0;
        if (confirm("Tem certeza que deseja remover este o \'CTRC\' " + $("sequenciaCtrc_" + index).innerHTML + " ?")) {
            Element.remove($("trAba1_" + index));
            Element.remove($("trCliente_" + index));
            Element.remove($("trNotaFiscal_" + index));
            Element.remove($("trComposicaoFrete_" + index));
            Element.remove($("trOutros_" + index));
            Element.remove($("trValoresTotais_" + index));
            for (i = 1; i < max; i++) {
                if ($("trAba1_" + i) != null && $("trAba1_" + i) != undefined) {
                    countExiste++;
                }
            }
            if (countExiste == 0) {
                habilitar($("filial"));
                habilitar($("tipoTransporte"));
            }
            ratearFretePeso(false);
        }
    } catch (e) {
        console.error(e);
    }
}
//@@@@@@@@@@@@@@@@@@@  CONSTRUTORES  
function CTRC(id, numero, serie, emissaoEm, remetente, destinatario,
        qtd, peso, valorNFs, valorFrete, pesoRealCtrc
        , consignatario, tipoFrete, tipoPagamento, isRedespacho
        , redespacho, pesoTaxado, taxaFixa, isIcms, isPisCofins
        , valorItr, valorDespacho, valorAdeme, valorFretePeso, valorFreteValor
        , valorSecCat, valorOutros, valorGris, valorPedagio
        , isCobrarTde, valorTde, valorDesconto, totalPrestacao
        , baseCalculoIcms, aliquotaIcms, valorIcms, valorPisCofins
        , icmsBarreira, listaNotas, redespachoCtrc, redespachoValor
        , cidadeOrigem, ufOrigem, idCidadeOrigem
        , cidadeDestino, ufDestino, idCidadeDestino
        , rota, idRota, distancisKm, isUrbano
        , qtdEntregas, qtdPallets, tipoProduto, tipoVeiculo, tabelaUtilizada
        , vendedor, vendedorId, observacao, previsaoEntrega
        , cfop, cfopId, modFrete, valorPautaFiscal, enderecoEntregaId
        , taxaRouboUrbano, taxaTombamentoUrbano, taxaRoubo, taxaTombamento
        , representante, stICMS, cubagemMetro, numeroContainer, numeroCarga
        , redespachoValorIcms, cliente, redespachoChaveAcesso
        , veiculo, idVeiculo, motorista, idMotorista, carreta, idCarreta, bitrem, idBitrem, listaNotas
        , podeAlterar, chaveCte, emissaoAs, recebedor, expedidor, isRecebedor, isExpedidor, tipoCteImpLote
        , observacaoComplementar, enderecoColetaId, subContrato, cubagemBase, cubagemMetro, pedido, tipoProdutoDestinatario, calculaSecCat
        , observacaoComplementar, enderecoColetaId, subContrato, cubagemBase, cubagemMetro
        , calcularPrazoEntregaTabelaPreco, gerarNfseCidadeOrigemDestinoCteLote, tipoGeracaoNfseCidadeOrigemDestinoCteLote, serieMinuta
        ) {

    //validação
    //valores boolean
    this.isRedespacho = (isRedespacho == null || isRedespacho == undefined ? false : isRedespacho);
    this.isRecebedor = (isRecebedor == null || isRecebedor == undefined ? false : isRecebedor);
    this.isExpedidor = (isExpedidor == null || isExpedidor == undefined ? false : isExpedidor);
    this.isIcms = (isIcms == null || isIcms == undefined ? false : isIcms);
    this.isPisCofins = (isPisCofins == null || isPisCofins == undefined ? false : isPisCofins);
    this.isCobrarTde = (isCobrarTde == null || isCobrarTde == undefined ? false : isCobrarTde);
    this.isUrbano = (isUrbano == null || isUrbano == undefined ? false : isUrbano);
    this.isPodeAlterar = (podeAlterar == null || podeAlterar == undefined ? true : podeAlterar);
    this.subContrato = (subContrato == null || subContrato == undefined ? false : subContrato);

    //numericos
    this.id = (id == null || id == undefined ? "" : id);
    this.qtd = (qtd == null || qtd == undefined ? "" : qtd);
    this.peso = (peso == null || peso == undefined ? "" : peso);
    this.pesoReal = (pesoRealCtrc == null || pesoRealCtrc == undefined ? peso : pesoRealCtrc);
    this.valorNFs = (valorNFs == null || valorNFs == undefined ? "" : valorNFs);
    this.valorFrete = (valorFrete == null || valorFrete == undefined ? "" : valorFrete);
    this.pesoTaxado = (pesoTaxado == null || pesoTaxado == undefined ? 0 : pesoTaxado);
    this.valorTaxaFixa = (taxaFixa == null || taxaFixa == undefined ? 0 : taxaFixa);
    this.valorItr = (valorItr == null || valorItr == undefined ? 0 : valorItr);
    this.valorDespacho = (valorDespacho == null || valorDespacho == undefined ? 0 : valorDespacho);
    this.valorDesconto = (valorDesconto == null || valorDesconto == undefined ? 0 : valorDesconto);
    this.valorAdeme = (valorAdeme == null || valorAdeme == undefined ? 0 : valorAdeme);
    this.valorFretePeso = (valorFretePeso == null || valorFretePeso == undefined ? 0 : valorFretePeso);
    this.valorFreteValor = (valorFreteValor == null || valorFreteValor == undefined ? 0 : valorFreteValor);
    this.calculaSecCat = (calculaSecCat == null || calculaSecCat == undefined ? "" : calculaSecCat);
    this.valorSecCat = (valorSecCat == null || valorSecCat == undefined ? 0 : valorSecCat);
    this.valorOutros = (valorOutros == null || valorOutros == undefined ? 0 : valorOutros);
    this.valorGris = (valorGris == null || valorGris == undefined ? 0 : valorGris);
    this.valorPedagio = (valorPedagio == null || valorPedagio == undefined ? 0 : valorPedagio);
    this.valorTde = (valorTde == null || valorTde == undefined ? 0 : valorTde);
    this.totalPrestacao = (totalPrestacao == null || totalPrestacao == undefined ? 0 : totalPrestacao);
    this.baseCalculoIcms = (baseCalculoIcms == null || baseCalculoIcms == undefined ? 0 : baseCalculoIcms);
    this.aliquotaIcms = (aliquotaIcms == null || aliquotaIcms == undefined ? 0 : aliquotaIcms);
    this.valorIcms = (valorIcms == null || valorIcms == undefined ? 0 : valorIcms);
    this.valorPisCofins = (valorPisCofins == null || valorPisCofins == undefined ? 0 : valorPisCofins);
    this.valorIcmsBarreira = (icmsBarreira == null || icmsBarreira == undefined ? 0 : icmsBarreira);
    this.redespachoValor = (redespachoValor == null || redespachoValor == undefined ? 0 : redespachoValor);
    this.redespachoValorIcms = (redespachoValorIcms == null || redespachoValorIcms == undefined ? 0 : redespachoValorIcms);
    this.valorPautaFiscal = (valorPautaFiscal == null || valorPautaFiscal == undefined ? 0 : valorPautaFiscal);
    this.idCidadeOrigem = (idCidadeOrigem == null || idCidadeOrigem == undefined ? 0 : idCidadeOrigem);
    this.idCidadeDestino = (idCidadeDestino == null || idCidadeDestino == undefined ? 0 : idCidadeDestino);
    this.idRota = (idRota == null || idRota == undefined ? 0 : idRota);
    this.distancisKm = (distancisKm == null || distancisKm == undefined ? 0 : distancisKm);
    this.qtdEntregas = (qtdEntregas == null || qtdEntregas == undefined ? 1 : qtdEntregas);
    this.qtdPallets = (qtdPallets == null || qtdPallets == undefined ? 0 : qtdPallets);
    this.vendedorId = (vendedorId == null || vendedorId == undefined ? 0 : vendedorId);
    this.enderecoEntregaId = (enderecoEntregaId == null || enderecoEntregaId == undefined ? 0 : enderecoEntregaId);
    this.cfopId = (cfopId == null || cfopId == undefined ? 0 : cfopId);
    this.tipoProduto = (tipoProduto == null || tipoProduto == undefined ? "0" : tipoProduto);
    this.tipoVeiculo = (tipoVeiculo == null || tipoVeiculo == undefined ? "0" : tipoVeiculo);
    this.taxaRoubo = (taxaRoubo == null || taxaRoubo == undefined ? "0" : taxaRoubo);
    this.taxaRouboUrbano = (taxaRouboUrbano == null || taxaRouboUrbano == undefined ? "0" : taxaRouboUrbano);
    this.taxaTombamento = (taxaTombamento == null || taxaTombamento == undefined ? "0" : taxaTombamento);
    this.taxaTombamentoUrbano = (taxaTombamentoUrbano == null || taxaTombamentoUrbano == undefined ? 0 : taxaTombamentoUrbano);
    this.tabelaUtilizada = (tabelaUtilizada == null || tabelaUtilizada == undefined ? "" : tabelaUtilizada);
    this.redespachoChaveAcesso = (redespachoChaveAcesso == null || redespachoChaveAcesso == undefined ? "" : redespachoChaveAcesso);
    this.chaveCte = (chaveCte == null || chaveCte == undefined ? "" : chaveCte);
    this.tipoFrete = (tipoFrete == null || tipoFrete == undefined ? "-1" : tipoFrete);
    this.listaNotas = (listaNotas == null || listaNotas == undefined ? null : listaNotas);
    this.stICMS = (stICMS == null || stICMS == undefined ? 1 : stICMS);
    this.cubagemMetro = (cubagemMetro == null || cubagemMetro == undefined ? 0 : cubagemMetro);
    this.cliente = (cliente == null || cliente == undefined ? 0 : cliente);
    this.idVeiculo = (idVeiculo == null || idVeiculo == undefined ? "0" : idVeiculo);
    this.idMotorista = (idMotorista == null || idMotorista == undefined ? "" : idMotorista);
    this.idCarreta = (idCarreta == null || idCarreta == undefined ? "" : idCarreta);
    this.idBitrem = (idBitrem == null || idBitrem == undefined ? "" : idBitrem);
    this.index = 0;
    this.className = "";
    this.listaNotas = (listaNotas == null || listaNotas == undefined ? null : listaNotas);
    this.tipoCteImpLote = (tipoCteImpLote == null || tipoCteImpLote == undefined ? "null" : tipoCteImpLote);
    this.enderecoColetaId = (enderecoColetaId == null || enderecoColetaId == undefined ? 0 : enderecoColetaId);
    this.cubagemBase = (cubagemBase == null || cubagemBase == undefined ? 0 : cubagemBase);
    this.cubagemMetro = (cubagemMetro == null || cubagemMetro == undefined ? 0 : cubagemMetro);



    //strings
    this.numero = (numero == null || numero == undefined ? "" : numero);
    this.serie = (serie == null || serie == undefined ? "" : serie);
    this.emissaoEm = (emissaoEm == null || emissaoEm == undefined ? "" : emissaoEm);
    this.emissaoAs = (emissaoAs == null || emissaoAs == undefined ? "" : emissaoAs);
    this.previsaoEntrega = (previsaoEntrega == null || previsaoEntrega == undefined ? "" : previsaoEntrega);
    this.tipoPagamento = (tipoPagamento == null || tipoPagamento == undefined ? "" : tipoPagamento);
    this.redespachoCtrc = (redespachoCtrc == null || redespachoCtrc == undefined ? "" : redespachoCtrc);
    this.cidadeOrigem = (cidadeOrigem == null || cidadeOrigem == undefined ? "" : cidadeOrigem);
    this.ufOrigem = (ufOrigem == null || cidadeOrigem == undefined ? "" : ufOrigem);
    this.cidadeDestino = (cidadeDestino == null || cidadeDestino == undefined ? "" : cidadeDestino);
    this.ufDestino = (ufDestino == null || ufDestino == undefined ? "" : ufDestino);
    this.rota = (rota == null || rota == undefined ? "" : rota);
    this.vendedor = (vendedor == null || vendedor == undefined ? "" : vendedor);
    this.observacao = (observacao == null || observacao == undefined ? "" : observacao);
    this.cfop = (cfop == null || cfop == undefined ? "" : cfop);
    this.modFrete = (modFrete == null || modFrete == undefined ? "" : modFrete);
    this.numeroContainer = (numeroContainer == null || numeroContainer == undefined ? "" : numeroContainer);
    this.numeroCarga = (numeroCarga == null || numeroCarga == undefined ? "" : numeroCarga);
    this.veiculo = (veiculo == null || veiculo == undefined ? "" : veiculo);
    this.motorista = (motorista == null || motorista == undefined ? "" : motorista);
    this.carreta = (carreta == null || carreta == undefined ? "" : carreta);
    this.bitrem = (bitrem == null || bitrem == undefined ? "" : bitrem);
    this.pedido = (pedido == null || pedido == undefined ? "" : pedido);

    //objetos
    this.remetente = (remetente == null || remetente == undefined ? new Cliente("Remetente") : remetente);
    this.destinatario = (destinatario == null || destinatario == undefined ? new Cliente("Destinatario") : destinatario);
    this.consignatario = (consignatario == null || consignatario == undefined ? new Cliente("Consignatario") : consignatario);
    this.redespacho = (redespacho == null || redespacho == undefined ? new Cliente("Redespacho") : redespacho);
    this.representante = (representante == null || representante == undefined ? new Fornecedor() : representante);
    this.recebedor = (recebedor == null || recebedor == undefined ? new Cliente("Recebedor") : recebedor);
    this.expedidor = (expedidor == null || expedidor == undefined ? new Cliente("Expedidor") : expedidor);

    //colections
    this.listaNotas = (listaNotas == null || listaNotas == undefined ? new Array() : listaNotas);
    this.observacaoComplementar = (observacaoComplementar == null || observacaoComplementar == undefined ? "" : observacaoComplementar);
    this.calcularPrazoEntregaTabelaPreco = (calcularPrazoEntregaTabelaPreco == null || calcularPrazoEntregaTabelaPreco == undefined ? "s" : calcularPrazoEntregaTabelaPreco);

}
function Cliente(descricao, razaoSocial, id, cnpj, cidade, cidadeId,
        uf, tipoCfop, obrigaTabelaTipoProduto, tipoCgc,
        inscEst, isIncluirTde, reducaoIcms, utilizaPautaFiscal,
        tipoOrigemFrete, isStMG, tipoTabela, utilizarTabelaRemetente,
        tabelaCliente, tabelaRemetenteIds, stIcms, obs, qtdDiasPgto, tipoPgto,
        endereco, incluiPesoContainer, vendedor, percComissaoVendedor, listaTipoProduto,
        unificadaModalVendedor, percComissaoRodoviarioFracionadoVendedor, percComissaoRodoviarioLotacaoVendedor
        , isCreditoBloqueado, isAnaliseCredito, creditoDisponivel, bairro, complemento, logradouro, tipoDocumentoPadrao,
        utilizaTipoFreteTabela, mensagemUsuarioCte, isUtilizarNormativaGSF598GO, tipoArredondamentoPeso, isFreteDirigido,
        tipoProdutoDestinatario, obsFisco, travaCamposImportacao, utilizarTabelaCliente,
        especieSerieModal, especie, serie, modalCliente, gerarNfseCidadeOrigemDestinoCteLote, tipoGeracaoNfseCidadeOrigemDestinoCteLote, serieMinuta) {

    this.id = (id == null || id == undefined ? 0 : id);
    this.descricao = (descricao == null || descricao == undefined ? "" : descricao);
    this.razaoSocial = (razaoSocial == null || razaoSocial == undefined ? "" : razaoSocial);
    this.cnpj = (cnpj == null || cnpj == undefined ? "" : cnpj);
    this.cidade = (cidade == null || cidade == undefined ? "" : cidade);
    this.uf = (uf == null || uf == undefined ? "" : uf);
    this.obs = (obs == null || obs == undefined ? "" : obs);
    this.cidadeId = (cidadeId == null || cidadeId == undefined ? "" : cidadeId);
    this.tipoCfop = (tipoCfop == null || tipoCfop == undefined ? "" : tipoCfop);
    this.tipoCGC = (tipoCgc == null || tipoCgc == undefined ? "" : tipoCgc);
    this.inscEst = (inscEst == null || inscEst == undefined ? "" : inscEst);
    this.obrigaTabelaTipoProduto = (obrigaTabelaTipoProduto == null || obrigaTabelaTipoProduto == undefined || obrigaTabelaTipoProduto == "" || obrigaTabelaTipoProduto == "f" || obrigaTabelaTipoProduto == "false" ? false : obrigaTabelaTipoProduto);
    this.isIncluirTde = (isIncluirTde == null || isIncluirTde == undefined || isIncluirTde == "" || isIncluirTde == "f" || isIncluirTde == "false" ? false : isIncluirTde);
    this.utilizaPautaFiscal = (utilizaPautaFiscal == null || utilizaPautaFiscal == undefined || utilizaPautaFiscal == "" || utilizaPautaFiscal == "f" || utilizaPautaFiscal == "false" ? false : utilizaPautaFiscal);
    this.reducaoIcms = (reducaoIcms == null || reducaoIcms == undefined ? 0 : reducaoIcms);
    this.tipoOrigemFrete = (tipoOrigemFrete == null || tipoOrigemFrete == undefined ? "" : tipoOrigemFrete);
    this.endereco = (endereco == null || endereco == undefined ? "" : endereco);
    this.isStMG = (isStMG == null || isStMG == undefined || isStMG == "" || isStMG == "f" || isStMG == "false" ? false : isStMG);
    this.isCreditoBloqueado = (isCreditoBloqueado == null || isCreditoBloqueado == undefined || isCreditoBloqueado == "" || isCreditoBloqueado == "f" || isCreditoBloqueado == "false" ? false : isCreditoBloqueado);
    this.isAnaliseCredito = (isAnaliseCredito == null || isAnaliseCredito == undefined || isAnaliseCredito == "" || isAnaliseCredito == "f" || isAnaliseCredito == "false" ? false : isAnaliseCredito);
    this.isUtilizarNormativaGSF598GO = (isUtilizarNormativaGSF598GO == null || isUtilizarNormativaGSF598GO == undefined || isUtilizarNormativaGSF598GO == "" || isAnaliseCredito == "f" || isAnaliseCredito == "false" ? false : isUtilizarNormativaGSF598GO);
    this.tipoTabela = (tipoTabela == null || tipoTabela == undefined ? "" : tipoTabela);
    this.utilizarTabelaRemetente = (utilizarTabelaRemetente == null || utilizarTabelaRemetente == undefined ? "n " : utilizarTabelaRemetente);
    this.incluiPesoContainer = (incluiPesoContainer == null || incluiPesoContainer == undefined || incluiPesoContainer == "f" || incluiPesoContainer == "false" ? false : incluiPesoContainer);
    this.tabelaCliente = (tabelaCliente == undefined || tabelaCliente == null ? new Array() : tabelaCliente);
    this.tabelaRemetenteIds = (tabelaRemetenteIds == undefined || tabelaRemetenteIds == null ? 0 : tabelaRemetenteIds);
    this.creditoDisponivel = (creditoDisponivel == undefined || creditoDisponivel == null ? 0 : creditoDisponivel);
    this.stIcms = (stIcms == undefined || stIcms == null ? 0 : stIcms);
    this.tipoPgto = (tipoPgto == undefined || tipoPgto == null ? "v" : tipoPgto);
    this.qtdDiasPgto = (qtdDiasPgto == undefined || qtdDiasPgto == null ? 30 : qtdDiasPgto);
    this.percComissaoVendedor = (percComissaoVendedor == undefined || percComissaoVendedor == null ? 0 : percComissaoVendedor);
    this.unificadaModalVendedor = (unificadaModalVendedor == null || unificadaModalVendedor == undefined ? 0 : unificadaModalVendedor);
    this.percComissaoRodoviarioFracionadoVendedor = (percComissaoRodoviarioFracionadoVendedor == null || percComissaoRodoviarioFracionadoVendedor == undefined ? 0 : percComissaoRodoviarioFracionadoVendedor);
    this.percComissaoRodoviarioLotacaoVendedor = (percComissaoRodoviarioLotacaoVendedor == null || percComissaoRodoviarioLotacaoVendedor == undefined ? 0 : percComissaoRodoviarioLotacaoVendedor);
    this.vendedor = (vendedor == null || vendedor == undefined ? new Fornecedor() : vendedor);
    this.listaTipoProduto = (listaTipoProduto == null || listaTipoProduto == undefined ? new Array() : listaTipoProduto);
    this.bairro = (bairro == null || bairro == undefined ? "" : bairro);
    this.complemento = (complemento == null || complemento == undefined ? "" : complemento);
    this.logradouro = (logradouro == null || logradouro == undefined ? "" : logradouro);
    this.tipoDocumentoPadrao = (tipoDocumentoPadrao == null || tipoDocumentoPadrao == undefined ? "NE" : tipoDocumentoPadrao);
    this.utilizaTipoFreteTabela = (utilizaTipoFreteTabela == null || utilizaTipoFreteTabela == undefined ? "" : utilizaTipoFreteTabela);
    this.mensagemUsuarioCte = (mensagemUsuarioCte == null || mensagemUsuarioCte == undefined ? "" : mensagemUsuarioCte);
    this.tipoArredondamentoPeso = (tipoArredondamentoPeso == null || tipoArredondamentoPeso == undefined ? "n" : tipoArredondamentoPeso);
    this.isFreteDirigido = (isFreteDirigido == null || isFreteDirigido == undefined ? false : isFreteDirigido);
    this.tipoProdutoDestinatario = (tipoProdutoDestinatario == null || tipoProdutoDestinatario == undefined ? "" : tipoProdutoDestinatario);
    this.utilizarTabelaCliente = (utilizarTabelaCliente == null || utilizarTabelaCliente == undefined ? "0" : utilizarTabelaCliente);
    this.obsFisco = (obsFisco == null || obsFisco == undefined ? "" : obsFisco);
    this.travaCamposImportacao = (travaCamposImportacao == null || travaCamposImportacao == undefined ? false : travaCamposImportacao);
    this.especieSerieModal = (especieSerieModal == null || especieSerieModal == undefined ? false : especieSerieModal);
    this.especie = (especie == null || especie == undefined ? "CTR" : especie);
    this.serie = (serie == null || serie == undefined ? "1" : serie);
    this.modalCliente = (modalCliente == null || modalCliente == undefined ? "r" : modalCliente);
    this.gerarNfseCidadeOrigemDestinoCteLote = (gerarNfseCidadeOrigemDestinoCteLote == null || gerarNfseCidadeOrigemDestinoCteLote == undefined ? false : gerarNfseCidadeOrigemDestinoCteLote);
    this.tipoGeracaoNfseCidadeOrigemDestinoCteLote = (tipoGeracaoNfseCidadeOrigemDestinoCteLote == null || tipoGeracaoNfseCidadeOrigemDestinoCteLote == undefined ? "" : tipoGeracaoNfseCidadeOrigemDestinoCteLote);
    this.serieMinuta = (serieMinuta == null || serieMinuta == undefined ? "" : serieMinuta);
}
function Fornecedor(descricao, razaoSocial, id, cnpj,
        vlFreteMinimo, vlSobFrete, vlSobPeso, vlKgAte, vlPrecoFaixa
        ) {
    this.id = (id == null || id == undefined ? 0 : id);
    this.descricao = (descricao == null || descricao == undefined ? "" : descricao);
    this.razaoSocial = (razaoSocial == null || razaoSocial == undefined ? "" : razaoSocial);
    this.cnpj = (cnpj == null || cnpj == undefined ? "" : cnpj);

    this.vlFreteMinimo = (vlFreteMinimo == null || vlFreteMinimo == undefined ? 0 : vlFreteMinimo);
    this.vlPrecoFaixa = (vlPrecoFaixa == null || vlPrecoFaixa == undefined ? 0 : vlPrecoFaixa);
    this.vlKgAte = (vlKgAte == null || vlKgAte == undefined ? 0 : vlKgAte);
    this.vlSobPeso = (vlSobPeso == null || vlSobPeso == undefined ? 0 : vlSobPeso);
    this.vlSobFrete = (vlSobFrete == null || vlSobFrete == undefined ? 0 : vlSobFrete);
}
// funlçoes de ajuda
function verCliente(elemento) {

    var descricaoCampo = elemento.id.replace("abrir", "id");

    var idCliente = $(descricaoCampo).value;


    if (idCliente != "0") {
        window.open('./cadcliente?acao=editar&id=' + idCliente, 'Cliente', 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
    }
}
function getObsCliente(index, valor) {
    try {
        var obs = valor != undefined ? valor : "";
        obs = replaceAll(valor, "<br>", "");
        obs = replaceAll(valor, "<br/>", "");
        obs = replaceAll(valor, "<BR>", "");
        obs = replaceAll(valor, "<BR/>", "");
        if (obs != null && obs != "") {
            $("observacaoOutros_" + index).value = valor;
            definirAliquotaIcmsCtrc(index, true);
        } else {
            $("observacaoOutros_" + index).value = $('obsPadrao').value;
            definirAliquotaIcmsCtrc(index, false);
        }
    } catch (e) {
        alert(e);
        console.log(e);
    }
}
function alterarTipoPagamento(index, isDefinirTipoFrete) {
    try {
        isDefinirTipoFrete = (isDefinirTipoFrete == null || isDefinirTipoFrete == undefined ? true : isDefinirTipoFrete);
        var rzs = $("consignatario_" + index);
        var id = $("idConsignatario_" + index);
        var cidade = $("consignatarioCidade_" + index);
        var uf = $("consignatarioUF_" + index);
        var cidadeId = $("consignatarioCidadeId_" + index);
        var cnpj = $("consignatarioCNPJ_" + index);
        var botao = $("botLocConsignatario_" + index);
        var img = $("abrirConsignatario_" + index);
        var utilizaPauta = $("utilizaPautaFiscalConsignatario_" + index);
        var tipoOrigemFrete = $("consignatarioTipoOrigemFrete_" + index);
        var tipoTabela = $("tipoTabelaConsignatario_" + index);
        var tabelaRemetente = $("consignatarioUtilizaTabelaRemetente_" + index);
        var consignatarioStIcms = $("consignatarioStIcms_" + index);
        var consignatarioReducaoIcms = $("reducaoBaseIcmsConsignatario_" + index);
        var consignatarioUtilizarNormativaGSF598GO = $("utilizarNormativaGSF598GOConsignatario_" + index);
        var consignatarioValorCreditoPresumido = $("valorCreditoPresumidoConsignatario_" + index);
        var consignatarioUtilizarNormativaGSF129816GO = $("utilizarNormativaGSF129816GOConsignatario_" + index);
        var stIcms = $("stIcms_" + index);
        var obs = $("observacaoOutros_" + index);
        var obsFisco = $("observacaoFiscoOutros_" + index);
        var tipoPgto = $("consignatarioTipoPgto_" + index);
        var qtdDiasPgto = $("consignatarioQtdDiasPgto_" + index);
        var vendedor = $("vendedorOutros_" + index);
        var vendedorId = $("vendedorIdOutros_" + index);
        var vendedorComissao = $("consignatarioVendedorComissao_" + index); //O valor exibido na tela é gerado pela função 'definirComissaoVendedorLote(index)'
        var tipoModalVendedor = $("consignatarioUnificadaModalVendedor_" + index);
        var percComissaoRodFracionado = $("consignatarioPercComissaoRodoviarioFracionadoVendedor_" + index);
        var percComissaoRodLotacao = $("consignatarioPercComissaoRodoviarioLotacaoVendedor_" + index);
        var tipoCfop = $('tipoCfopConsignatario_' + index);
        var tipoTributacaoConsignatario = $('tipoTributacao_Consignatario_' + index);
        var utilizarTabelaCliente_id = $('_utilizarTabelaCliente_id_Consignatario_' + index);
        var isEspecieCliente = $('consignatarioEspecieSerieModalCliente_' + index);
        var especieCliente = $('consignatarioEspecieCliente_' + index);
        var serieCliente = $('consignatarioSerieCliente_' + index);
        var modalCliente = $('consignatarioModalCliente_' + index);

        var podeAlterar = ($('podeAlterar_' + index).value == "true" ? true : false);

        var observacao = "";
        var mensagemCte = $("_msgConsignatario_cte_" + index);
        var tipoArredondamento = $("_tipoArredondamentoPesoConsignatario_" + index);
        var gerarNFSeCidadesIguais = $("consignatarioGerarNfseCidadeOrigemDestinoCteLote_" + index);
        var tipoNFSeCidadesIguais = $("consignatarioTipoNfseCidadeOrigemDestinoCteLote_" + index);
        var serieMinuta = $("consignatario-serie-minuta-" + index);
        //27/11/2015 - Referente a Story: 1803, Sprint 20 do Prob - Número Mantis: 0002336
        //Caso o consignatário seja diferente do remetente e destinatário, então vai ser terceiros.
        //Foi definido que ao escolher o consignatário e for diferentes do remetente e destinatario então vai ser tercerios para todos os layouts
        // if(id.value != $("idRemetente_" + index).value && id.value != $("idDestinatario_" + index).value){            
        //    $("tipoPagamentoT_" + index).checked = true;
        //}
        
        if ($("tipoPagamentoC_" + index).checked) {
            rzs.value = $("remetente_" + index).value;
            id.value = $("idRemetente_" + index).value;
            cidade.value = $("remetenteCidade_" + index).value;
            uf.value = $("remetenteUF_" + index).value;
            cidadeId.value = $("remetenteCidadeId_" + index).value;
            cnpj.value = $("remetenteCNPJ_" + index).value;
            utilizaPauta.value = $("utilizaPautaFiscalRemetente_" + index).value;
            tipoOrigemFrete.value = $("remetenteTipoOrigemFrete_" + index).value;
            tipoTabela.value = $("tipoTabelaRemetente_" + index).value;
            tabelaRemetente.value = $("remetenteUtilizaTabelaRemetente_" + index).value;
            consignatarioStIcms.value = $("remetenteStIcms_" + index).value;
            consignatarioReducaoIcms.value = $("reducaoBaseIcmsRemetente_" + index).value;
            consignatarioUtilizarNormativaGSF598GO.value = $("utilizarNormativaGSF598GORemetente_" + index).value;
            consignatarioValorCreditoPresumido.value = $("valorCreditoPresumidoRemetente_" + index).value;
            consignatarioUtilizarNormativaGSF129816GO.value = $("utilizarNormativaGSF129816GORemetente_" + index).value;
            tipoTributacaoConsignatario.value = $("tipoTributacao_Remetente_" + index).value;
            utilizarTabelaCliente_id.value = $("_utilizarTabelaCliente_id_Remetente_" + index).value;
//            if (podeAlterar) {
//                if (parseInt($("remetenteStIcms_" + index).value, 10) == 0) {
//                    stIcms.value = $("stIcmsConfig_" + index).value;
//                } else {
//                    stIcms.value = $("remetenteStIcms_" + index).value;
//                }
//            }
            obs.value = getObs($("remetenteObs_" + index).value);
            obsFisco.value = getObs($("remetenteObsFisco_" + index).value);
            tipoPgto.value = $("remetenteTipoPgto_" + index).value;
            qtdDiasPgto.value = $("remetenteQtdDiasPgto_" + index).value;
            vendedor.value = $("remetenteVendedor_" + index).value;
            vendedorId.value = $("remetenteVendedorId_" + index).value;
            vendedorComissao.value = $("remetenteVendedorComissao_" + index).value;
            tipoModalVendedor.value = $("remetenteUnificadaModalVendedor_" + index).value;
            percComissaoRodFracionado.value = $("remetentePercComissaoRodoviarioFracionadoVendedor_" + index).value;
            tipoCfop.value = $('tipoCfopRemetente_' + index).value;
            percComissaoRodLotacao.value = $("remetentePercComissaoRodoviarioLotacaoVendedor_" + index).value;
            mensagemCte.value = $("_msgRemetente_cte_" + index).value;
            tipoArredondamento.value = $("_tipoArredondamentoPesoRemetente_" + index).value;
            $("utilizaTipoFreteTabelaConsignatario_" + index).value = $("utilizaTipoFreteTabelaRemetente_" + index).value;
            gerarNFSeCidadesIguais.value = $("remetenteGerarNfseCidadeOrigemDestinoCteLote_" + index).value;
            tipoNFSeCidadesIguais.value = $("remetenteTipoNfseCidadeOrigemDestinoCteLote_" + index).value;
            serieMinuta.value = $("remetente-serie-minuta-" + index).value;


            invisivel(botao);
            invisivel(img);

            observacao = obs.value;
            if ($("remetenteTipoProduto_" + index).innerHTML != '' && $("remetenteTipoProduto_" + index).innerHTML != null) {
                copyOption($("remetenteTipoProduto_" + index), $("tipoProdutoTabela_" + index), $("remetenteTipoProduto_" + index).value);
            } else {
                removeOptionSelected($("tipoProdutoTabela_" + index).id);
                povoarSelect($("tipoProdutoTabela_" + index), listaTipoProdutoAll);
            }

//                localizarTipoProduto(id.value, index);
            getObsCliente(index, obs.value);
            getObsClienteFisco(index, obsFisco.value);

            isEspecieCliente.value = $('remetenteEspecieSerieModalCliente_' + index).value;
            especieCliente.value = $('remetenteEspecieCliente_' + index).value;
            serieCliente.value = $('remetenteSerieCliente_' + index).value;
            modalCliente.value = $('remetenteModalCliente_' + index).value;
        } else if ($("tipoPagamentoF_" + index).checked) {
            rzs.value = $("destinatario_" + index).value;
            id.value = $("idDestinatario_" + index).value;
            cidade.value = $("destinatarioCidade_" + index).value;
            uf.value = $("destinatarioUF_" + index).value;
            cidadeId.value = $("destinatarioCidadeId_" + index).value;
            cnpj.value = $("destinatarioCNPJ_" + index).value;
            consignatarioStIcms.value = $("destinatarioStIcms_" + index).value;
            consignatarioReducaoIcms.value = $("reducaoBaseIcmsDestinatario_" + index).value;
            consignatarioUtilizarNormativaGSF598GO.value = $("utilizarNormativaGSF598GODestinatario_" + index).value;
            consignatarioValorCreditoPresumido.value = $("valorCreditoPresumidoDestinatario_" + index).value;
            consignatarioUtilizarNormativaGSF129816GO.value = $("utilizarNormativaGSF129816GODestinatario_" + index).value;
            tipoTributacaoConsignatario.value = $("tipoTributacao_Destinatario_" + index).value;
//            if (podeAlterar) {
//                if (parseInt($("destinatarioStIcms_" + index).value, 10) == 0) {
//                    stIcms.value = $("stIcmsConfig_" + index).value;
//                } else {
//                    stIcms.value = $("destinatarioStIcms_" + index).value;
//                }
//            }
            obs.value = getObs($("destinatarioObs_" + index).value);
            obsFisco.value = getObs($("destinatarioObsFisco_" + index).value);
            utilizaPauta.value = $("utilizaPautaFiscalDestinatario_" + index).value;
            tipoOrigemFrete.value = $("destinatarioTipoOrigemFrete_" + index).value;
            tipoTabela.value = $("tipoTabelaDestinatario_" + index).value;
            tabelaRemetente.value = $("destinatarioUtilizaTabelaRemetente_" + index).value;
            tipoPgto.value = $("destinatarioTipoPgto_" + index).value;
            tipoCfop.value = $('tipoCfopDestinatario_' + index).value;
            qtdDiasPgto.value = $("destinatarioQtdDiasPgto_" + index).value;
            vendedor.value = $("destinatarioVendedor_" + index).value;
            vendedorId.value = $("destinatarioVendedorId_" + index).value;
            vendedorComissao.value = $("destinatarioVendedorComissao_" + index).value;
            tipoModalVendedor.value = $("destinatarioUnificadaModalVendedor_" + index).value;
            percComissaoRodFracionado.value = $("destinatarioPercComissaoRodoviarioFracionadoVendedor_" + index).value;
            percComissaoRodLotacao.value = $("destinatarioPercComissaoRodoviarioLotacaoVendedor_" + index).value;
            mensagemCte.value = $("_msgDestinatario_cte_" + index).value;
            tipoArredondamento.value = $("_tipoArredondamentoPesoDestinatario_" + index).value;
            if ($("consignatarioUtilizaTabelaRemetente_" + index).value == "n") {
                $("utilizaTipoFreteTabelaConsignatario_" + index).value = $("utilizaTipoFreteTabelaDestinatario_" + index).value;
            } else {
                $("utilizaTipoFreteTabelaConsignatario_" + index).value = $("utilizaTipoFreteTabelaRemetente_" + index).value;
            }
            gerarNFSeCidadesIguais.value = $("destinatarioGerarNfseCidadeOrigemDestinoCteLote_" + index).value;
            tipoNFSeCidadesIguais.value = $("destinatarioTipoNfseCidadeOrigemDestinoCteLote_" + index).value;
            serieMinuta.value = $("destinatario-serie-minuta-" + index).value;
            utilizarTabelaCliente_id.value = $("_utilizarTabelaCliente_id_Destinatario_" + index).value;
            invisivel(botao);
            invisivel(img);
            observacao = obs.value;
            getObsCliente(index, obs.value);
            getObsClienteFisco(index, obsFisco.value);
            if ($("_isfreteDirigidoRemetente_" + index).value == "true" || $("_isfreteDirigidoRemetente_" + index).value == "t") {
                copyOption($("remetenteTipoProduto_" + index), $("tipoProdutoTabela_" + index), $("remetenteTipoProduto_" + index).value);
            } else if ($("destinatarioTipoProduto_" + index).innerHTML != '' && $("destinatarioTipoProduto_" + index).innerHTML != null) {
                copyOption($("destinatarioTipoProduto_" + index), $("tipoProdutoTabela_" + index), $("destinatarioTipoProduto_" + index).value);
            } else {
                removeOptionSelected($("tipoProdutoTabela_" + index).id);
                povoarSelect($("tipoProdutoTabela_" + index), listaTipoProdutoAll);
            }

            isEspecieCliente.value = $('destinatarioEspecieSerieModalCliente_' + index).value;
            especieCliente.value = $('destinatarioEspecieCliente_' + index).value;
            serieCliente.value = $('destinatarioSerieCliente_' + index).value;
            modalCliente.value = $('destinatarioModalCliente_' + index).value;
        } else {
            if ($("isRedespacho_" + index).checked && ($("idConsignatario_" + index).value == 0 || $("idConsignatario_" + index).value == "")) {
                rzs.value = $("redespacho_" + index).value;
                id.value = $("idRedespacho_" + index).value;
                cidade.value = $("redespachoCidade_" + index).value;
                uf.value = $("redespachoUF_" + index).value;
                tipoPgto.value = $("redespachoTipoPgto_" + index).value;
                qtdDiasPgto.value = $("redespachoQtdDiasPgto_" + index).value;
                cidadeId.value = $("redespachoCidadeId_" + index).value;
                cnpj.value = $("redespachoCNPJ_" + index).value;
                utilizaPauta.value = $("utilizaPautaFiscalRedespacho_" + index).value;
                tipoOrigemFrete.value = $("redespachoTipoOrigemFrete_" + index).value;
                tipoTabela.value = $("tipoTabelaRedespacho_" + index).value;
                tabelaRemetente.value = $("redespachoUtilizaTabelaRemetente_" + index).value;
                vendedor.value = $("redespachoVendedor_" + index).value;
                tipoCfop.value = $('tipoCfopRedespacho_' + index).value;
                vendedorId.value = $("redespachoVendedorId_" + index).value;
                vendedorComissao.value = $("redespachoVendedorComissao_" + index).value;
                tipoModalVendedor.value = $("redespachoUnificadaModalVendedor_" + index).value;
                percComissaoRodFracionado.value = $("redespachoPercComissaoRodoviarioFracionadoVendedor_" + index).value;
                percComissaoRodLotacao.value = $("redespachoPercComissaoRodoviarioLotacaoVendedor_" + index).value;
                mensagemCte.value = $("_msgRedespacho_cte_" + index).value;
                tipoArredondamento.value = $("_tipoArredondamentoPesoRedespacho_" + index).value;
                tipoTributacaoConsignatario.value = $("tipoTributacao_Redespacho_" + index).value;
                utilizarTabelaCliente_id.value = $("_utilizarTabelaCliente_id_Redespacho_" + index).value;
                if ($("consignatarioUtilizaTabelaRemetente_" + index).value == "n") {
                    $("utilizaTipoFreteTabelaConsignatario_" + index).value = $("utilizaTipoFreteTabelaDestinatario_" + index).value;
                } else {
                    $("utilizaTipoFreteTabelaConsignatario_" + index).value = $("utilizaTipoFreteTabelaRemetente_" + index).value;
                }
                verRedespacho($("isRedespacho_" + index));
                definirAliquotaIcmsCtrc(index);
                if ($("consignatarioTipoProduto_" + index).innerHTML != '' && $("consignatarioTipoProduto_" + index).innerHTML != null) {
                    copyOption($("consignatarioTipoProduto_" + index), $("tipoProdutoTabela_" + index), $("consignatarioTipoProduto_" + index).value);
                } else {
                    removeOptionSelected($("tipoProdutoTabela_" + index).id);
                    povoarSelect($("tipoProdutoTabela_" + index), listaTipoProdutoAll);
                }
                consignatarioStIcms.value = $("redespachoStIcms_" + index).value;
                consignatarioReducaoIcms.value = $("reducaoBaseIcmsRedespacho_" + index).value;
                consignatarioUtilizarNormativaGSF598GO.value = $("utilizarNormativaGSF598GORedespacho_" + index).value;

                obsFisco.value = getObs($("redespachoObsFisco_" + index).value);
                getObsClienteFisco(index, obsFisco.value);

                isEspecieCliente.value = $('redespachoEspecieSerieModalCliente_' + index).value;
                especieCliente.value = $('redespachoEspecieCliente_' + index).value;
                serieCliente.value = $('redespachoSerieCliente_' + index).value;
                modalCliente.value = $('redespachoModalCliente_' + index).value;
            } else if ($("idRemetente_" + index).value == id.value || $("idDestinatario_" + index).value == id.value) {
                rzs.value = "";
                id.value = 0;
                cidade.value = "";
                uf.value = "";
                cidadeId.value = 0;
                cnpj.value = "";
                tipoTabela.value = "";
                utilizaPauta.value = "";
                tipoOrigemFrete.value = "";
                tabelaRemetente.value = "";
                tipoPgto.value = "";
                qtdDiasPgto.value = "";
                vendedor.value = "";
                vendedorId.value = 0;
                vendedorComissao.value = 0;
                removeOptionSelected($("tipoProdutoTabela_" + index).id);
                localizarTipoProduto(id.value, index);
                observacao = "";
                mensagemCte.value = "";
                tipoArredondamento.value = "n";
                utilizarTabelaCliente_id.value = 0;
                $("stIcms_" + index).value = $("stIcmsConfig_" + index).value;
            }



            visivel(botao);
            visivel(img);
        }
        $("ValorCreditoPresumido_" + index).value = consignatarioValorCreditoPresumido.value;
        $("utilizarNormativaGSF129816GO_" + index).value = consignatarioUtilizarNormativaGSF129816GO.value;

//            if ($("tipoProdutoTabela_" + indeidRemetente_x).options.length == 0) {
//                povoarSelect($("tipoProdutoTabela_" + index), listaTipoProdutoAll);
//            }

        if (($("utilizaTipoFreteTabelaConsignatario_" + index).value == 'f' || $("utilizaTipoFreteTabelaConsignatario_" + index).value == 'false')
                && ($("permissao_alteratipofretecte").value == "true" || $("permissao_alteratipofretecte").value == "t")) {
            $("tipoFreteTabela_" + index).disabled = false;
        }

        if ($("isRedespacho_" + index).checked) {
            verRedespacho($("isRedespacho_" + index));
        }

        definirComissaoVendedorLote(index);
        if (podeAlterar) {
            atribuirCfopPadrao(index);

            if (isDefinirTipoFrete) {
                definirTipoFrete(index);
            }
            definiCidadeOrigem(index);
            // definirAliquotaIcmsCtrc(index);
            getPautaFiscal(index);
            alteraTipoTaxa("S", index);
            getObsCliente(index, observacao);
            definirICMSCTe(index);

            if (gerarNFSeCidadesIguais.value === 'true' || gerarNFSeCidadesIguais.value === 't') {
                obterIssNfseCtrc(index);
            }
        }
        recalcular(index);
        if (mensagemCte.value !== "" && mensagemCte.value !== null) {
            setMsgCliente(index, mensagemCte.value);
        } else {
            limparMsgCliente(index);
        }

    } catch (ex) {
        alert(ex);
    }
}
function verRedespacho(elemento) {
    try {
        var index = elemento.id.split("_")[1];
        var tr = $("trRedespacho_" + index);
        var tr2 = $("trRespRedespachoChaveAcesso_" + index);
        if (elemento.checked) {
            visivel(tr);
            visivel(tr2);
            notReadOnly($("redespachoCtrc_" + index), estiloMin);
            notReadOnly($("redespachoValor_" + index), estiloMin);
            notReadOnly($("redespachoValorIcms_" + index), estiloMin);
            notReadOnly($("redespachoChaveAcesso_" + index), estiloMin);
        } else {
            readOnly($("redespachoCtrc_" + index), estiloMinReadOnly);
            readOnly($("redespachoValor_" + index), estiloMinReadOnly);
            readOnly($("redespachoValorIcms_" + index), estiloMinReadOnly);
            readOnly($("redespachoChaveAcesso_" + index), estiloMinReadOnly);
            invisivel(tr);
            invisivel(tr2);
        }
    } catch (e) {
        if (!isIE()) {
            console.log(e);
            console.trace();
        }
    }
}

function atribuirCfopPadraoNota(indexCTe) {
    var maxNota = parseInt($("qtdNotas_" + indexCTe).value, 10);
    for (var qtdNota = 1; qtdNota <= maxNota; qtdNota++) {
        if ($("notaCfopId_" + indexCTe + "_" + qtdNota) != null && $("notaCfopId_" + indexCTe + "_" + qtdNota).value == 0) {
            $("notaCfopId_" + indexCTe + "_" + qtdNota).value = $("cfopCtrcId_" + indexCTe).value;
            $("notaCfop_" + indexCTe + "_" + qtdNota).value = $("cfopCtrc_" + indexCTe).value;
        }
    }

}

/**
 * ATENÇÃO:
 * SE FOR MEXER NESSE MÉTODO VERIFICAR NO ARQUIVO CONHECIMENTOBO.JAVA POIS EXISTE UMA VÁLIDAÇÃO IGUAL.
 * E PROVAVELMENTE PRECISARÁ ALTERAR LÁ TAMBÉM.
 * @param {type} index
 * @returns {undefined}
 */
function atribuirCfopPadrao(index) {
    var idCfopComDentro = (idCfopComercioDentro != 0 ? idCfopComercioDentro : 0);
    var cfopComDentro = (idCfopComercioDentro != 0 ? cfopComercioDentro : "");
    var idCfopComFora = (idCfopComercioFora != 0 ? idCfopComercioFora : 0);
    var cfopComFora = (idCfopComercioFora != 0 ? cfopComercioFora : "");
    var idCfopInduDentro = (idCfopIndDentro != 0 ? idCfopIndDentro : 0);
    var cfopInduDentro = (idCfopIndDentro != 0 ? cfopIndDentro : "");
    var idCfopInduFora = (idCfopIndFora != 0 ? idCfopIndFora : 0);
    var cfopInduFora = (idCfopIndFora != 0 ? cfopIndFora : "");
    var idCfopCPFDentro = (idCfopPFDentro != 0 ? idCfopPFDentro : 0);
    var cfopCPFDentro = (idCfopPFDentro != 0 ? cfopPFDentro : "");
    var idCfopCPFFora = (idCfopPFFora != 0 ? idCfopPFFora : 0);
    var cfopCPFFora = (idCfopPFFora != 0 ? cfopPFFora : "");
    var idCfopUF = (idCfopOutroEstado != 0 ? idCfopOutroEstado : 0);
    var cfopUF = (idCfopOutroEstado != 0 ? cfopOutroEstado : "");
    var idCfopUFFora = (idCfopOutroEstadoFora != 0 ? idCfopOutroEstadoFora : 0);
    var cfopUFFora = (idCfopOutroEstadoFora != 0 ? cfopOutroEstadoFora : "");
    var idCfopTraFora = (idCfopTransporteFora != 0 ? idCfopTransporteFora : 0);
    var cfopTraFora = (idCfopTransporteFora != 0 ? cfopTransporteFora : "");
    var idCfopTraDentro = (idCfopTransporteDentro != 0 ? idCfopTransporteDentro : 0);
    var cfopTraDentro = (idCfopTransporteDentro != 0 ? cfopTransporteDentro : "");
    var idCfopServFora = (idCfopPrestacaoServicoFora != 0 ? idCfopPrestacaoServicoFora : 0);
    var cfopServFora = (idCfopPrestacaoServicoFora != 0 ? cfopPrestacaoServicoFora : "");
    var idCfopServDentro = (idCfopPrestacaoServicoDentro != 0 ? idCfopPrestacaoServicoDentro : 0);
    var cfopServDentro = (idCfopPrestacaoServicoDentro != 0 ? cfopPrestacaoServicoDentro : "");
    var idCfopRuralFora = (idCfopProdutorRuralFora != 0 ? idCfopProdutorRuralFora : 0);
    var cfopRuralFora = (idCfopProdutorRuralFora != 0 ? cfopProdutorRuralFora : "");
    var idCfopRuralDentro = (idCfopProdutorRuralDentro != 0 ? idCfopProdutorRuralDentro : 0);
    var cfopRuralDentro = (idCfopProdutorRuralDentro != 0 ? cfopProdutorRuralDentro : "");
    var idCfopExtFora = (idCfopExteriorFora != 0 ? idCfopExteriorFora : 0);
    var cfopExtFora = (idCfopExteriorFora != 0 ? cfopExteriorFora : "");
    var idCfopExtDentro = (idCfopExteriorDentro != 0 ? idCfopExteriorDentro : 0);
    var cfopExtDentro = (idCfopExteriorDentro != 0 ? cfopExteriorDentro : "");
    var idCfopSubFora = (idCfopSubContratacaoFora != 0 ? idCfopSubContratacaoFora : 0);
    var cfopSubFora = (idCfopSubContratacaoFora != 0 ? cfopSubContratacaoFora : "");
    var idCfopSubDentro = (idCfopSubContratacaoDentro != 0 ? idCfopSubContratacaoDentro : 0);
    var cfopSubDentro = (idCfopSubContratacaoDentro != 0 ? cfopSubContratacaoDentro : 0);

    var filial_uf = $("filial").value.split("@@")[1];
    var remetente_uf = $("ufOrigemLocais_" + index).value;
    var destinatario_uf = $("ufDestinoLocais_" + index).value;
    var tipoServico = $("tipoServico").value;
    var cnpjConsig = $('consignatarioCNPJ_' + index).value;
    var tipoCfopConsig = $('tipoCfopConsignatario_' + index).value;
    var consigIe = "";
    if ($("tipoPagamentoC_" + index) != null && $("tipoPagamentoC_" + index).checked) {
        consigIe = $("inscricaoEstadualRemetente_" + index).value;
    } else if ($("tipoPagamentoF_" + index) != null && $("tipoPagamentoF_" + index).checked) {
        consigIe = $("inscricaoEstadualDestinatario_" + index).value;
    } else if ($("tipoPagamentoT_" + index) != null && $("tipoPagamentoT_" + index).checked) {
        if ($("isRedespacho_" + index).checked) {
            consigIe = $("inscricaoEstadualRedespacho_" + index).value;
        } else {
            consigIe = $("inscricaoEstadualConsignatario_" + index).value;
        }
    }
    var podeAlterar = ($('podeAlterar_' + index).value == "true" ? true : false);
    if (podeAlterar) {
        if (tipoServico == 's') {
            $("cfopCtrcId_" + index).value = (filial_uf == destinatario_uf ? idCfopSubDentro : idCfopSubFora);
            $("cfopCtrc_" + index).value = (filial_uf == destinatario_uf ? cfopSubDentro : cfopSubFora);
        } else if (destinatario_uf == 'EX') { //Fretes com destinatario para fora do pais
            $("cfopCtrcId_" + index).value = (filial_uf == remetente_uf ? idCfopExtDentro : idCfopExtFora);
            $("cfopCtrc_" + index).value = (filial_uf == remetente_uf ? cfopExtDentro : cfopExtFora);
        } else if (filial_uf != remetente_uf /*&& !$('isRedespacho_' + index).checked  COMENTADO NA STORY  PROB 3641 - POIS A REGRA DE CFOP NA SEFAZ NÃO LEVA EM CONSIDERAÇÃO CASOS DE REDESPACHO - MARCOS  */) { //Fretes originados em outra UF
            $("cfopCtrcId_" + index).value = (remetente_uf == destinatario_uf ? idCfopUF : idCfopUFFora);
            $("cfopCtrc_" + index).value = (remetente_uf == destinatario_uf ? cfopUF : cfopUFFora);
        } else if (cnpjConsig.length == 14 && consigIe == "ISENTO") {//Apenas pessoa fisica
            $("cfopCtrcId_" + index).value = (filial_uf == destinatario_uf ? idCfopCPFDentro : idCfopCPFFora);
            $("cfopCtrc_" + index).value = (filial_uf == destinatario_uf ? cfopCPFDentro : cfopCPFFora);
        } else if ($('tipoCfopConsignatario_' + index).value == 'c') {//APENAS PARA COMÉRCIO
            $("cfopCtrcId_" + index).value = (filial_uf == destinatario_uf ? idCfopComDentro : idCfopComFora);
            $("cfopCtrc_" + index).value = (filial_uf == destinatario_uf ? cfopComDentro : cfopComFora);
        } else if ($('tipoCfopConsignatario_' + index).value == 'i') {//APENAS PARA industria
            $("cfopCtrcId_" + index).value = (filial_uf == destinatario_uf ? idCfopInduDentro : idCfopInduFora);
            $("cfopCtrc_" + index).value = (filial_uf == destinatario_uf ? cfopInduDentro : cfopInduFora);
        } else if ($('tipoCfopConsignatario_' + index).value == 't') {//APENAS PARA transporte
            $("cfopCtrcId_" + index).value = (filial_uf == destinatario_uf ? idCfopTraDentro : idCfopTraFora);
            $("cfopCtrc_" + index).value = (filial_uf == destinatario_uf ? cfopTraDentro : cfopTraFora);
        } else if ($('tipoCfopConsignatario_' + index).value == 'p') {//APENAS PARA Prestador de serviço
            $("cfopCtrcId_" + index).value = (filial_uf == destinatario_uf ? idCfopServDentro : idCfopServFora);
            $("cfopCtrc_" + index).value = (filial_uf == destinatario_uf ? cfopServDentro : cfopServFora);
        } else if ($('tipoCfopConsignatario_' + index).value == 'r') {//APENAS PARA Produtor Rural
            $("cfopCtrcId_" + index).value = (filial_uf == destinatario_uf ? idCfopRuralDentro : idCfopRuralFora);
            $("cfopCtrc_" + index).value = (filial_uf == destinatario_uf ? cfopRuralDentro : cfopRuralFora);
        }
    }
    atribuirCfopPadraoNota(index);
}

function calculaPesoCubado(index) {
    var cubMetro = parseFloat(colocarPonto($('cubagemMetroTotalNF_' + index).value));
    var cubBase = parseFloat(colocarPonto($('cubagemBaseTotalNF_' + index).value));
    var cubPeso = 0;

    if ($('tipoTransporte').value == 'a') {
        cubPeso = arredondar(((cubMetro * parseFloat(1000000)) / cubBase), 3);
    } else {
        cubPeso = arredondar((cubBase * cubMetro), 3);
    }

    return cubPeso;
}

function calculaPesoTaxado(index) {
    var cubPeso = 0;
    var valorPesoTot = 0;

    if (index == undefined) {
        return false;
    }

    valorPesoTot = parseFloat(colocarPonto($('valorPesoTotalNF_' + index).value));

    cubPeso = calculaPesoCubado(index);

    $('cubagemPesoTotalNF_' + index).value = colocarVirgula(cubPeso, 3);
    $('cubagemPesoTotalCF_' + index).value = colocarVirgula(cubPeso, 3);

    if (valorPesoTot > cubPeso) {
        $('valorPesoTaxado_' + index).value = colocarVirgula(valorPesoTot, 3);
    } else {
        $('valorPesoTaxado_' + index).value = colocarVirgula(cubPeso, 3);
    }

    if ($("_tipoArredondamentoPesoConsignatario_" + index).value == 'a') {
        $('valorPesoTaxado_' + index).value = Math.round(colocarPonto($('valorPesoTaxado_' + index).value));
    } else if ($("_tipoArredondamentoPesoConsignatario_" + index).value == 'c') {
        $('valorPesoTaxado_' + index).value = Math.ceil(colocarPonto($('valorPesoTaxado_' + index).value));
    }
}
function calcularTotalPrestacao(index) {
    var valorTaxaFixa = parseFloat(colocarPonto($("valorTaxaFixa_" + index).value));
    var valorItr = parseFloat(colocarPonto($("valorItr_" + index).value));
    var valorDespacho = parseFloat(colocarPonto($("valorDespacho_" + index).value));
    var valorDesconto = parseFloat(colocarPonto($("valorDesconto_" + index).value));
    var valorAdeme = parseFloat(colocarPonto($("valorAdeme_" + index).value));
    var valorFretePeso = parseFloat(colocarPonto($("valorFretePeso_" + index).value));
    var valorFreteValor = parseFloat(colocarPonto($("valorFreteValor_" + index).value));
    var valorSecCat = parseFloat(colocarPonto($("valorSecCat_" + index).value));
    var valorOutros = parseFloat(colocarPonto($("valorOutros_" + index).value));
    var valorGris = parseFloat(colocarPonto($("valorGris_" + index).value));
    var valorPedagio = parseFloat(colocarPonto($("valorPedagio_" + index).value));
    var valorTde = parseFloat(colocarPonto($("valorTde_" + index).value));
    var isIncluirTde = $("isTde_" + index).checked;
    var isIncluirSecCat = $("isSecCat_" + index).checked;
    var totalPrestacao = 0;
    totalPrestacao = valorAdeme + valorDespacho + valorFretePeso + valorFreteValor + valorGris + valorItr + valorOutros + valorPedagio + valorTaxaFixa;
    if (isIncluirTde) {
        totalPrestacao += valorTde;
    }
    if (isIncluirSecCat) {
        totalPrestacao += valorSecCat;
    }
    $("totalPrestacao_" + index).value = colocarVirgula((totalPrestacao - valorDesconto));
//calcularIcms(index);
}
function calcularIcms(index) {
    var vlBC = parseFloat(colocarPonto($("baseCalculoIcms_" + index).value));
    var aliqIcms = parseFloat(colocarPonto($("aliquotaIcms_" + index).value));
    var vlIcms = vlBC * (aliqIcms / 100);

    $("valorIcms_" + index).value = colocarVirgula(vlIcms);
}
function carregarTabela(transport, index, valida) {
    try {
        var textoresposta = transport.responseText;

        //se deu algum erro na requisicao...
        if (textoresposta == "load=0") {

            buscouTaxas = "0";
            //fechaClientesWindow();
            if (valida == "S") {
                if ($("layout").value != "webserviceNDDAvon") {
                    alert("Não foi encontrada nenhuma tabela de preço para essa origem e esse destino.Ctrc:" + index);
                }


                //Zerar valores calculo frete
                //primeira linha


                if ($("fontePreco").value != "a") {
                    $("valorTaxaFixa_" + index).value = "0,00";
                    //                $("taxaFixaTotal_" + index).value = "0,00";
                    $("valorItr_" + index).value = "0,00";
                    $("valorDespacho_" + index).value = "0,00";
                    $("valorAdeme_" + index).value = "0,00";
                    $("valorFretePeso_" + index).value = "0,00";
                    $("valorFreteValor_" + index).value = "0,00";
                    //segunda linha
                    $("valorSecCat_" + index).value = "0,00";
                    $("valorOutros_" + index).value = "0,00";
                    $("valorGris_" + index).value = "0,00";
                    $("valorPedagio_" + index).value = "0,00";
                    $("valorDesconto_" + index).value = "0,00";
                    //terceira linha
                    $("totalPrestacao_" + index).value = "00,00";
                    $("baseCalculoIcms_" + index).value = "0,00";
                    $("valorIcms_" + index).value = "0,00";
                    //este campo foi comentado por conta da historia 
//                    $("cubagemBaseTotalNF_" + index).value = "0";
//                    $("cubagemBaseTotalCF_" + index).value = "0";
                    $("tabelaUtilizadaTabela_" + index).value = "";
                }
            }
            return false;
        }
        tarifas[index] = eval('(' + textoresposta + ')'); // retono JSON

        if (tarifas[index].cliente_id == undefined) {
            if ($("layout").value != "webserviceNDDAvon") {
                setTimeout(function () {
                    if (!confirm("Não foi encontrada nenhuma tabela de preço para essa origem e destino. Ctrc:" + index + ". \n Deseja utilizar a tabela principal?")) {
                        $("tabelaUtilizadaTabela_" + index).value = "";
                        if (alteraTipoFrete == "true" || alteraTipoFrete == "t") {
                            $("tipoFreteTabela_" + index).disabled = false;
                        } else {
                            $("tipoFreteTabela_" + index).disabled = true;
                        }
                        return false;
                    }
                }, 3000);
            }
        } else {

            $("tipoTaxa_" + index).value = tarifas[index].tipo_taxa;
            var tp = $("tipoTaxa_" + index).value;
            var utiliza = false;
            var utilizaTabelaRemetente = (($("consignatarioUtilizaTabelaRemetente_" + index).value == "s" && $("utilizaTipoFreteTabelaRemetente_" + index).value == 't') ||
                    ($("consignatarioUtilizaTabelaRemetente_" + index).value == "q" && $("utilizaTipoFreteTabelaRemetente_" + index).value == 't' && tarifas[index].tipo_frete_remetente != '-1'));

            if (($("utilizaTipoFreteTabelaConsignatario_" + index).value == 't' || $("utilizaTipoFreteTabelaConsignatario_" + index).value == 'true') || utilizaTabelaRemetente) {
                utiliza = true;
            }
            if ($("tipoTaxa_" + index) != null && $("tipoTaxa_" + index) != undefined && (tp != '-1') && utiliza) {
                if (($("tipoFreteTabela_" + index).value == '0' || $("tipoFreteTabela_" + index).value == '1')
                        && ($("tipoTaxa_" + index).value == '1' || $("tipoTaxa_" + index).value == '0') && tarifas[index].is_considerar_maior_peso) {
                } else if (($("tipoFreteTabela_" + index).value == '0' || $("tipoFreteTabela_" + index).value == '1' || $("tipoFreteTabela_" + index).value == '2')
                        && ($("tipoTaxa_" + index).value == '1' || $("tipoTaxa_" + index).value == '0' || $("tipoTaxa_" + index).value == '2') && tarifas[index].is_considerar_maior_peso) {
                } else {
                    $("tipoFreteTabela_" + index).value = $("tipoTaxa_" + index).value;
                    $("tipoFreteTabela_" + index).value.disabled = true;
                    idtaxa = $("tipoFreteTabela_" + index).value;
                }
                $("tipoFreteTabela_" + index).disabled = true;
            } else if (tarifas[index].cliente_id == undefined && (tp != '-1') && utiliza) {
                $("tipoFreteTabela_" + index).value = $("tipoTaxa_" + index).value;
            } else {
                if (alteraTipoFrete == "true" || alteraTipoFrete == "t") {
                    $("tipoFreteTabela_" + index).disabled = false;
                } else {
                    $("tipoFreteTabela_" + index).disabled = true;
                }
            }

            if (tarifas[index].valida_ate != undefined) {
                var dataEmissao = new Date(dataAtual.substring(6, 10), dataAtual.substring(3, 5), dataAtual.substring(0, 2));
                var dataValidade = new Date(tarifas[index].valida_ate.substring(0, 4), tarifas[index].valida_ate.substring(5, 7), tarifas[index].valida_ate.substring(8, 10));
                if (dataValidade.getTime() < dataEmissao.getTime()) {
                    alert('Atenção: A tabela de preço número ' + tarifas[index].id + ' esta vencida! Favor comunicar ao setor comercial.');
                }
            }
            if ($('consignatarioUtilizaTabelaRemetente_' + index).value == 'q'
                    && ($("utilizaTipoFreteTabelaConsignatario_" + index).value == 'f' || $("utilizaTipoFreteTabelaConsignatario_" + index).value == 'false')) {
                if (tarifas[index].tipo_frete_remetente != '-1') {
                    if (idtaxa != tarifas[index].tipo_frete_remetente) {
                        $("tipoFreteTabela_" + index).value = tarifas[index].tipo_frete_remetente;
                        alteraTipoTaxa(valida, index);
                    }
                }
            }
        }

        var valorRateioLiquido = 0;
        if ($("isRedespacho_" + index).checked) {
            valorRateioLiquido = parseFloat(colocarPonto($("redespachoValor_" + index).value)) - parseFloat(colocarPonto($("redespachoValorIcms_" + index).value));
        }

        //   Regras de negócio     //     --     encontram-se em tabelaFrete.js
        var aliqTabelaMin = colocarPonto($('aliquotaIcms_' + index).value);
        if ($("filial").value.split('@@')[1] == 'MG' && $('consignatarioUF_' + index).value == 'MG' && $('idConsignatario_' + index).value == $('idRemetente_' + index).value
                && ($('isStMgRemetente_' + index).value == 'true' || $('isStMgRemetente_' + index).value == 't')) {
            aliqTabelaMin = 14.4;
        }
        var pesoCubado = 0;
        if ($("tipoTransporte").value == 'a') {
            $("cubagemBaseTotalNF_" + index).value = colocarVirgula(getBaseCubagem(tarifas[index].base_cubagem_aereo));
            $("cubagemBaseTotalCF_" + index).value = colocarVirgula(getBaseCubagem(tarifas[index].base_cubagem_aereo));
            pesoCubado = parseFloat(colocarPonto($("cubagemMetroTotalNF_" + index).value)) * parseFloat(1000000) / parseFloat(colocarPonto($("cubagemBaseTotalNF_" + index).value));
        } else {
            // Se o çayout for diferente de 8(mobly)
            if($("layout").value != "8"){
                $("cubagemBaseTotalNF_" + index).value = colocarVirgula(getBaseCubagem(tarifas[index].base_cubagem));
                $("cubagemBaseTotalCF_" + index).value = colocarVirgula(getBaseCubagem(tarifas[index].base_cubagem));
            }
            pesoCubado = parseFloat(colocarPonto($("cubagemBaseTotalNF_" + index).value)) * parseFloat(colocarPonto($("cubagemMetroTotalNF_" + index).value));
        }

        $('cubagemPesoTotalNF_' + index).value = colocarVirgula(pesoCubado, 3);
        $('cubagemPesoTotalCF_' + index).value = colocarVirgula(pesoCubado, 3);

        if ($('tipoFreteTabela_' + index).value == '0') {
            if (tarifas[index].is_considerar_maior_peso && parseFloat(colocarPonto($("valorPesoTotalNF_" + index).value)) < pesoCubado) {
                $('tipoFreteTabela_' + index).value = '1';
                pesoReal[index] = pesoCubado;
                //  setTipofrete('1');
                alteraTipoTaxa(valida, index);
                return null;
            }
        }

        if ($('tipoFreteTabela_' + index).value == '1') {
            calculaPesoTaxado(index);
            if (tarifas[index].is_considerar_maior_peso && parseFloat(colocarPonto($("valorPesoTotalNF_" + index).value)) > pesoCubado) {
                $('tipoFreteTabela_' + index).value = '0';
                pesoReal[index] = parseFloat(colocarPonto($('valorPesoTotalNF_' + index).value));
                alteraTipoTaxa(valida, index);
                return null;
            }
            if (tarifas[index].is_considerar_maior_peso && parseFloat(formatoMoeda(tarifas[index].peso_calculo)) < parseFloat(formatoMoeda(pesoCubado)) && tarifas[index].tipo_frete_peso == "f") {
                $('tipoFreteTabela_' + index).value = '1';
                pesoReal[index] = pesoCubado;
                alteraTipoTaxa(valida, index);
                return null;
            }
        }

        if (($('consignatarioUtilizaTabelaRemetente_' + index).value == 'n') && (!(tarifas[index].cliente_id == 0 || tarifas[index].cliente_id == undefined) && tarifas[index].cliente_id != $("idConsignatario_" + index).value && $("_utilizarTabelaCliente_id_Consignatario_" + index).value != tarifas[index].cliente_id) && !($("_isfreteDirigidoRemetente_" + index).value == "t" || $("_isfreteDirigidoRemetente_" + index).value == "true")) {
            alteraTipoTaxa("S", index);
        }

        $("valorSecCat_" + index).value = colocarVirgula(getValorSecCat(tarifas[index].valor_sec_cat, tarifas[index].formula_sec_cat, $('tipoFreteTabela_' + index).value,
                colocarPonto($('valorPesoTotalNF_' + index).value), colocarPonto($('valorMercadoriaTotalNF_' + index).value), colocarPonto($('valorVolumeTotalNF_' + index).value), '0',
                $('distanciaKmLocais_' + index).value, $('tipoVeiculoTabela_' + index).value, tarifas[index].is_considerar_maior_peso,
                colocarPonto($("cubagemBaseTotalNF_" + index).value), colocarPonto($("cubagemMetroTotalNF_" + index).value),
                $('qtdEntregasTabela_' + index).value, $("tipoTransporte").value, tarifas[index].peso_limite_sec_cat,
                tarifas[index].valor_excedente_sec_cat, tarifas[index].tipo_inclusao_icms, aliqTabelaMin, $('_tipoArredondamentoPesoConsignatario_' + index).value,
                ($("idConsignatario_" + index).value == $("idRemetente_" + index).value ? "0" : ($("idConsignatario_" + index).value == $("idDestinatario_" + index).value ? "1" : "2")), $("redespachoValor_" + index).value, $("redespachoValorIcms_" + index).value)); //relaciona (sem calculos)

        $("tabelaUtilizadaTabela_" + index).value = tarifas[index].id; // atribui o id da tabelaPreco no label

        if ($("fontePreco").value != "a") {
            $("valorGris_" + index).value = colocarVirgula(getGris(tarifas[index].percentual_gris, colocarPonto($("valorMercadoriaTotalNF_" + index).value),
                    tarifas[index].valor_minimo_gris, tarifas[index].formula_gris, $('tipoFreteTabela_' + index).value, colocarPonto($('valorPesoTotalNF_' + index).value),
                    colocarPonto($('valorVolumeTotalNF_' + index).value), $("qtdPalletsTabela_" + index).value, $('distanciaKmLocais_' + index).value,
                    $('tipoVeiculoTabela_' + index).value, tarifas[index].is_considerar_maior_peso,
                    colocarPonto($("cubagemBaseTotalNF_" + index).value), colocarPonto($("cubagemMetroTotalNF_" + index).value), $('qtdEntregasTabela_' + index).value,
                    $("tipoTransporte").value, tarifas[index].tipo_inclusao_icms, aliqTabelaMin, $('_tipoArredondamentoPesoConsignatario_' + index).value,
                    ($("idConsignatario_" + index).value == $("idRemetente_" + index).value ? "0" : ($("idConsignatario_" + index).value == $("idDestinatario_" + index).value ? "1" : "2")), $("redespachoValor_" + index).value, $("redespachoValorIcms_" + index).value)); //calcula o percentual do gris

            var raizConsignatario = $("consignatarioCNPJ_" + index).value.replace(/[^\d]+/g, '');
            raizConsignatario = raizConsignatario.substring(0, 8);
            var raizRedespacho = $("redespachoCNPJ_" + index).value.replace(/[^\d]+/g, '');
            raizRedespacho = raizRedespacho.substring(0, 8);
            $("valorFreteValor_" + index).value = colocarVirgula(getFreteValor(colocarPonto($("valorMercadoriaTotalNF_" + index).value),
                    tarifas[index].percentual_advalorem,
                    tarifas[index].percentual_nf,
                    tarifas[index].base_nf_percentual,
                    tarifas[index].valor_percentual_nf,
                    $("tipoFreteTabela_" + index).value,
                    tarifas[index].tipo_impressao_percentual,
                    tarifas[index].formula_seguro, tarifas[index].formula_percentual,
                    colocarPonto($('valorPesoTotalNF_' + index).value),
                    colocarPonto($('valorVolumeTotalNF_' + index).value), $("qtdPalletsTabela_" + index).value, $('distanciaKmLocais_' + index).value,
                    $('tipoVeiculoTabela_' + index).value, tarifas[index].is_considerar_maior_peso, colocarPonto($("cubagemBaseTotalNF_" + index).value),
                    colocarPonto($("cubagemMetroTotalNF_" + index).value), (raizConsignatario == raizRedespacho), valorRateioLiquido, $('qtdEntregasTabela_' + index).value, $("tipoTransporte").value,
                    tarifas[index].tipo_inclusao_icms, aliqTabelaMin, true, $('_tipoArredondamentoPesoConsignatario_' + index).value,
                    ($("idConsignatario_" + index).value == $("idRemetente_" + index).value ? "0" : ($("idConsignatario_" + index).value == $("idDestinatario_" + index).value ? "1" : "2")), $("redespachoValor_" + index).value, $("redespachoValorIcms_" + index).value)); //calcula o percentual do gris



            $("valorPedagio_" + index).value = colocarVirgula(getPedagio(colocarPonto($("valorPesoTotalNF_" + index).value), tarifas[index].vl_pedagio,
                    tarifas[index].qtd_kg_pedagio, $("tipoFreteTabela_" + index).value, pesoCubado, tarifas[index].formula_pedagio,
                    colocarPonto($('valorMercadoriaTotalNF_' + index).value), colocarPonto($('valorVolumeTotalNF_' + index).value), $('qtdPalletsTabela_' + index).value,
                    $('distanciaKmLocais_' + index).value, $('tipoVeiculoTabela_' + index).value, tarifas[index].is_considerar_maior_peso, colocarPonto($("cubagemBaseTotalNF_" + index).value),
                    colocarPonto($('cubagemMetroTotalNF_' + index).value), $('qtdEntregasTabela_' + index).value, $('tipoTransporte').value,
                    tarifas[index].tipo_inclusao_icms, aliqTabelaMin, $('_tipoArredondamentoPesoConsignatario_' + index).value,
                    ($("idConsignatario_" + index).value == $("idRemetente_" + index).value ? "0" : ($("idConsignatario_" + index).value == $("idDestinatario_" + index).value ? "1" : "2")), $("redespachoValor_" + index).value, $("redespachoValorIcms_" + index).value));
        }


        $("valorOutros_" + index).value = colocarVirgula(getOutros(tarifas[index].valor_outros, tarifas[index].formula_outros,
                $('tipoFreteTabela_' + index).value, colocarPonto($('valorPesoTotalNF_' + index).value), colocarPonto($('valorMercadoriaTotalNF_' + index).value),
                colocarPonto($('valorVolumeTotalNF_' + index).value), $("qtdPalletsTabela_" + index).value, $('distanciaKmLocais_' + index).value,
                $('tipoVeiculoTabela_' + index).value, tarifas[index].is_considerar_maior_peso, colocarPonto($("cubagemBaseTotalNF_" + index).value),
                colocarPonto($("cubagemMetroTotalNF_" + index).value), $('qtdEntregasTabela_' + index).value,
                $("tipoTransporte").value, tarifas[index].tipo_inclusao_icms,
                aliqTabelaMin, $('_tipoArredondamentoPesoConsignatario_' + index).value,
                ($("idConsignatario_" + index).value == $("idRemetente_" + index).value ? "0" : ($("idConsignatario_" + index).value == $("idDestinatario_" + index).value ? "1" : "2")), $("redespachoValor_" + index).value, $("redespachoValorIcms_" + index).value));

        $("valorTaxaFixa_" + index).value = colocarVirgula(getTaxaFixa(tarifas[index].valor_taxa_fixa, tarifas[index].formula_taxa_fixa,
                $('tipoFreteTabela_' + index).value, colocarPonto($('valorPesoTotalNF_' + index).value), colocarPonto($('valorMercadoriaTotalNF_' + index).value),
                colocarPonto($('valorVolumeTotalNF_' + index).value), $("qtdPalletsTabela_" + index).value,
                $('distanciaKmLocais_' + index).value, $('tipoVeiculoTabela_' + index).value, tarifas[index].is_considerar_maior_peso,
                colocarPonto($("cubagemBaseTotalNF_" + index).value), colocarPonto($("cubagemMetroTotalNF_" + index).value),
                $('qtdEntregasTabela_' + index).value, $("tipoTransporte").value,
                tarifas[index].peso_limite_taxa_fixa, tarifas[index].valor_excedente_taxa_fixa,
                tarifas[index].tipo_inclusao_icms, aliqTabelaMin, $('_tipoArredondamentoPesoConsignatario_' + index).value,
                ($("idConsignatario_" + index).value == $("idRemetente_" + index).value ? "0" : ($("idConsignatario_" + index).value == $("idDestinatario_" + index).value ? "1" : "2")), $("redespachoValor_" + index).value, $("redespachoValorIcms_" + index).value));
        //calculataxaFixaTotal($("taxaFixa").value);

        $("valorDespacho_" + index).value = colocarVirgula(getValorDespacho(tarifas[index].valor_despacho, tarifas[index].formula_despacho,
                $('tipoFreteTabela_' + index).value, colocarPonto($('valorPesoTotalNF_' + index).value), colocarPonto($('valorMercadoriaTotalNF_' + index).value),
                colocarPonto($('valorVolumeTotalNF_' + index).value), $("qtdPalletsTabela_" + index).value, $('distanciaKmLocais_' + index).value,
                $('tipoVeiculoTabela_' + index).value, tarifas[index].is_considerar_maior_peso,
                colocarPonto($("cubagemBaseTotalNF_" + index).value), colocarPonto($("cubagemMetroTotalNF_" + index).value),
                $('qtdEntregasTabela_' + index).value, $("tipoTransporte").value, tarifas[index].tipo_inclusao_icms,
                aliqTabelaMin, $('_tipoArredondamentoPesoConsignatario_' + index).value,
                ($("idConsignatario_" + index).value == $("idRemetente_" + index).value ? "0" : ($("idConsignatario_" + index).value == $("idDestinatario_" + index).value ? "1" : "2")), $("redespachoValor_" + index).value, $("redespachoValorIcms_" + index).value));

        var pesoParaCalculo = 0;
        if ($('tipoFreteTabela_' + index).value == "1") {
            pesoParaCalculo = parseFloat(colocarPonto($("cubagemPesoTotalCF_" + index).value));
        } else {
            pesoParaCalculo = parseFloat(colocarPonto($("valorPesoTotalNF_" + index).value));
        }

        var tipoFrete = $("tipoFreteTabela_" + index).value;
        if ($("fontePreco").value != "a") {
            $("valorFretePeso_" + index).value = colocarVirgula(getFretePeso(pesoParaCalculo,
                    colocarPonto($("valorVolumeTotalNF_" + index).value),
                    tipoFrete,
                    tarifas[index].valor_peso,
                    tarifas[index].valor_volume,
                    colocarPonto($("cubagemBaseTotalNF_" + index).value),
                    colocarPonto($("cubagemMetroTotalNF_" + index).value),
                    tarifas[index].valor_veiculo,
                    tarifas[index].valor_por_faixa,
                    $("tipoTransporte").value,
                    tarifas[index].valor_excedente_aereo,
                    tarifas[index].valor_excedente,
                    tarifas[index].maximo_peso_final,
                    tarifas[index].ispreco_tonelada,
                    tarifas[index].tipo_frete_peso,
                    tarifas[index].valor_maximo_peso_final,
                    tarifas[index].valor_km,
                    tarifas[index].is_considerar_maior_peso,
                    tarifas[index].tipo_impressao_percentual,
                    colocarPonto($("valorMercadoriaTotalNF_" + index).value),
                    tarifas[index].base_nf_percentual,
                    tarifas[index].valor_percentual_nf,
                    tarifas[index].percentual_nf,
                    $("qtdPalletsTabela_" + index).value,
                    $("distanciaKmLocais_" + index).value,
                    tarifas[index].formula_volumes, $('tipoVeiculoTabela_' + index).value,
                    tarifas[index].formula_percentual,
                    tarifas[index].valor_pallet,
                    tarifas[index].formula_pallet,
                    $("isRedespacho_" + index).checked,
                    valorRateioLiquido,
                    $('qtdEntregasTabela_' + index).value,
                    tarifas[index].formula_frete_peso,
                    tarifas[index].tipo_inclusao_icms,
                    aliqTabelaMin, false,
                    $('_tipoArredondamentoPesoConsignatario_' + index).value
                    ));

            if ($('tipoFreteTabela_' + index).value == "3") {//Caso o tipo da tabela seja combinado
                if (tarifas[index].tipo_taxa_combinado == 1) {
                    $("valorFretePeso_" + index).value = colocarVirgula((tarifas[index].valor_veiculo == undefined ? "0.00" : tarifas[index].valor_veiculo));
                } else if (tarifas[index].tipo_taxa_combinado == 2) {
                    $("valorFretePeso_" + index).value = colocarVirgula((tarifas[index].valor_veiculo == undefined ? "0.00" : parseFloat(tarifas[index].valor_veiculo) * pesoParaCalculo));
                } else if (tarifas[index].tipo_taxa_combinado == 3) {
                    $("valorFretePeso_" + index).value = colocarVirgula((tarifas[index].valor_veiculo == undefined ? "0.00" : parseFloat(tarifas[index].valor_veiculo) * pesoParaCalculo / 1000));
                } else {
                    $("valorFretePeso_" + index).value = '0,00';
                }
            }
        }
        if (tipoFrete != $("tipoFreteTabela_" + index).value) {
            alteraTipoTaxa(valida, index);
            return null;
        }
        if (tarifas[index].isinclui_icms && tarifas[index].tipo_inclusao_icms == 't') {
            $("isAddIcms_" + index).checked = true;
        } else {
            $("isAddIcms_" + index).checked = false;
        }
        $("isAddPisCofins_" + index).checked = tarifas[index].is_inclui_impostos_federais;

        //é necessário o total da prestação parcial para comparar com o valor minimo.
        var seguroX = parseFloat(getFreteValor(colocarPonto($("valorMercadoriaTotalNF_" + index).value),
                tarifas[index].percentual_advalorem,
                tarifas[index].percentual_nf,
                tarifas[index].base_nf_percentual,
                tarifas[index].valor_percentual_nf,
                $("tipoFreteTabela_" + index).value,
                'p',
                tarifas[index].formula_seguro, tarifas[index].formula_percentual,
                colocarPonto($('valorPesoTotalNF_' + index).value),
                colocarPonto($('valorVolumeTotalNF_' + index).value), '0', $('distanciaKmLocais_' + index).value, $('tipoVeiculoTabela_' + index).value,
                tarifas[index].is_considerar_maior_peso, colocarPonto($("cubagemBaseTotalNF_" + index).value), colocarPonto($("cubagemMetroTotalNF_" + index).value),
                (raizConsignatario == raizRedespacho), valorRateioLiquido, $('qtdEntregasTabela_' + index).value, $("tipoTransporte").value,
                tarifas[index].tipo_inclusao_icms, aliqTabelaMin, true, $('_tipoArredondamentoPesoConsignatario_' + index).value,
                ($("idConsignatario_" + index).value == $("idRemetente_" + index).value ? "0" : ($("idConsignatario_" + index).value == $("idDestinatario_" + index).value ? "1" : "2")), $("redespachoValor_" + index).value, $("redespachoValorIcms_" + index).value));

        var totalPrestacao = parseFloat(colocarPonto($("valorTaxaFixa_" + index).value)) +
                parseFloat(colocarPonto($("valorItr_" + index).value)) +
                parseFloat(colocarPonto($("valorAdeme_" + index).value)) +
                parseFloat(colocarPonto($("valorFretePeso_" + index).value)) +
                parseFloat(colocarPonto($("valorFreteValor_" + index).value)) +
                parseFloat(colocarPonto($("valorSecCat_" + index).value)) +
                parseFloat(colocarPonto($("valorOutros_" + index).value)) +
                parseFloat(colocarPonto($("valorGris_" + index).value)) +
                parseFloat(colocarPonto($("valorDespacho_" + index).value)) +
                parseFloat(colocarPonto($("valorPedagio_" + index).value)) -
                parseFloat(colocarPonto($("valorDesconto_" + index).value));

        totalPrestacao = (tarifas[index].is_desconsidera_taxa_minimo ? totalPrestacao - parseFloat(colocarPonto($("valorTaxaFixa_" + index).value)) : totalPrestacao);
        totalPrestacao = (tarifas[index].is_desconsidera_despacho_minimo ? totalPrestacao - parseFloat(colocarPonto($("valorDespacho_" + index).value)) : totalPrestacao);
        totalPrestacao = (tarifas[index].is_desconsidera_seccat_minimo ? totalPrestacao - parseFloat(colocarPonto($("valorSecCat_" + index).value)) : totalPrestacao);
        totalPrestacao = (tarifas[index].is_desconsidera_outros_minimo ? totalPrestacao - parseFloat(colocarPonto($("valorOutros_" + index).value)) : totalPrestacao);
        totalPrestacao = (tarifas[index].is_desconsidera_gris_minimo ? totalPrestacao - parseFloat(colocarPonto($("valorGris_" + index).value)) : totalPrestacao);
        totalPrestacao = (tarifas[index].is_desconsidera_pedagio_minimo ? totalPrestacao - parseFloat(colocarPonto($("valorPedagio_" + index).value)) : totalPrestacao);
        totalPrestacao = (tarifas[index].is_desconsidera_seguro_minimo ? totalPrestacao - seguroX : totalPrestacao);



        if (tarifas[index].is_considerar_valor_maior_peso_nota && (tipoFrete == "0" || tipoFrete == "1" || tipoFrete == "2")) {
            var mTpFrete = getTipoPreferencialPesoPercentualNotaFiscal(colocarPonto($("valorPesoTotalNF_" + index).value),
                    colocarPonto($("valorVolumeTotalNF_" + index).value), tipoFrete,
                    tarifas[index].valor_peso,
                    tarifas[index].valor_volume,
                    colocarPonto($("cubagemBaseTotalNF_" + index).value),
                    colocarPonto($("cubagemMetroTotalNF_" + index).value),
                    tarifas[index].valor_veiculo,
                    tarifas[index].valor_por_faixa,
                    $("tipoTransporte").value,
                    tarifas[index].valor_excedente_aereo,
                    tarifas[index].valor_excedente,
                    tarifas[index].maximo_peso_final,
                    tarifas[index].ispreco_tonelada,
                    tarifas[index].tipo_frete_peso,
                    tarifas[index].valor_maximo_peso_final,
                    tarifas[index].valor_km,
                    tarifas[index].is_considerar_maior_peso,
                    tarifas[index].tipo_impressao_percentual,
                    colocarPonto($("valorMercadoriaTotalNF_" + index).value),
                    tarifas[index].base_nf_percentual,
                    tarifas[index].valor_percentual_nf,
                    tarifas[index].percentual_nf,
                    $("qtdPalletsTabela_" + index).value,
                    $("distanciaKmLocais_" + index).value,
                    tarifas[index].formula_volumes, $('tipoVeiculoTabela_' + index).value,
                    tarifas[index].formula_percentual,
                    tarifas[index].valor_pallet,
                    tarifas[index].formula_pallet,
                    $("isRedespacho_" + index).checked,
                    valorRateioLiquido,
                    $('qtdEntregasTabela_' + index).value,
                    tarifas[index].formula_frete_peso,
                    tarifas[index].tipo_inclusao_icms,
                    aliqTabelaMin, false, $('_tipoArredondamentoPesoConsignatario_' + index).value);

            if (mTpFrete != tipoFrete) {
                $("tipoFreteTabela_" + index).value = mTpFrete;
                alteraTipoTaxa(valida, index);
                return null;
            }
        }

        //validaTipoTransporte();
        calcularIcms(index);
        recalcular(index);

        //Calculando a previsao de entrega
        if(tarifas[index].previsao_entrega_calculada != ""){
            $("previsaoEntrega_" + index).value = tarifas[index].previsao_entrega_calculada;
        }


        mostrarCamposComposicaoFreteLote(index);

        return true;
    } catch (exception) {
        //alert("Deu erro de script! \nÉ melhor fechar a tela e importar o arquivo novamente \n");
    } finally {
    }

    return false;
}//funcao e()
function alteraTipoTaxa(valida, index) {
    //objeto funcao usado na requisicao Ajax(uma espécie de evento)
    var tipoTaxa = parseInt($("tipoFreteTabela_" + index).value, 10);
//    var tipoVeiculo = parseInt($("tipoVeiculoTabela_" + index).value, 10);
    var podeAlterar = ($('podeAlterar_' + index).value == "true" ? true : false);
    var usaTaxaTabela = false;
    if ($("utilizaTipoFreteTabelaConsignatario_" + index).value == 't' || $("utilizaTipoFreteTabelaConsignatario_" + index).value == 'true') {
        usaTaxaTabela = true;
    }

    function e(transport) {
        carregarTabela(transport, index, valida);
        espereEnviar("", false);
    }

    if ((tipoTaxa == -1 && !usaTaxaTabela)) {
        limparComposicaoFreteLote(index);
        return false;
    }

    if (!podeAlterar) {
        return false;
    }
    /*** Bloco de instrucoes ***/
//    if (tipoTaxa == 3 && tipoVeiculo == 0) {
//        return false;
//    } COMENTEI POIS A REGRA NÃO EXISTE NA TELA DE NOVO CADASTRO. IMPORTANDO VIA NOVO CADASTRO A TABELA DE PREÇO CARREGA NORMALMENTE. - PROB 4565
    //if (pesoReal == 0){
    if (tipoTaxa == 1) {
        pesoReal[index] = parseFloat(colocarPonto($("cubagemPesoTotalNF_" + index).value));
    } else {
        pesoReal[index] = parseFloat(colocarPonto($("valorPesoTotalNF_" + index).value));
    }

    calculaPesoTaxado(index);
    //Comentei a linha abaixo em 22/07/2013 junto com GLEIDSON por causa de um erro que estava ocorrendo na AK Transportes conforme e-mail de ANdré em 20/07/2013 às 19:47
    //    pesoReal[index] = parseFloat(colocarPonto($("valorPesoTaxado_"+ index).value));
    //}
    if (tipoTaxa != 5 &&
            ($("cidadeOrigemIdLocais_" + index).value == "0" || $("cidadeDestinoIdLocais_" + index).value == "0") ||
            (tipoTaxa == "-1" && !usaTaxaTabela) || $("destinatario_" + index).value == "") {
        return false;
    }
    if (tipoTaxa == 5 && $("tipoVeiculoTabela_" + index).value == "0") {
        return false;
    }
    //se a opcao eh "Peso/kg" e o usuario nao preencheu o peso e o valor da mercadoria...
    if ((tipoTaxa == 0) && (parseFloat(colocarPonto($("valorPesoTotalNF_" + index).value)) == parseFloat("0") || parseFloat(colocarPonto($("valorMercadoriaTotalNF_" + index).value)) == parseFloat("0"))) {
        //alert("É preciso prencher os campos \"Peso(Kg)\" e \"Vl.Mercadoria\".");
        return false;
    }
    if (pesoReal[index] == null || pesoReal[index] == undefined || pesoReal[index] == "") {
        pesoReal[index] = 0;
    }
    if ((tipoTaxa == 0) && pesoReal[index] == parseFloat(0)) {
        return false
    }
    var clienteTabelaId = $('idConsignatario_' + index).value;
    if (clienteTabelaId == "" || clienteTabelaId == "0") {
        return false;
    }

    espereEnviar("", true);



    tryRequestToServer(function () {
        new Ajax.Request("ConhecimentoControlador?acao=carregar_taxascli" +
                "&dtemissao=" + $("dataEmissaoCTe").value + "&idconsignatario=" + clienteTabelaId + "&con_tabela_remetente=" + ($("tipoPagamentoF_" + index).checked && ($("_isfreteDirigidoRemetente_" + index).value == "t" || $("_isfreteDirigidoRemetente_" + index).value == "true") ? "s" : $("consignatarioUtilizaTabelaRemetente_" + index).value) +
                "&tipoTransporte=" + $("tipoTransporte").value +
                "&tipoveiculo=" + $("tipoVeiculoTabela_" + index).value + "&tipoproduto=" + $("tipoProdutoTabela_" + index).value +
                "&idcidadeorigem=" + $("cidadeOrigemIdLocais_" + index).value + "&idcidadedestino=" + $("cidadeDestinoIdLocais_" + index).value +
                "&peso=" + pesoReal[index] + "&idremetente=" + $('idRemetente_' + index).value + "&idTaxa=" + tipoTaxa +
                "&idDestinatario=" + $("idDestinatario_" + index).value,
                {
                    method: 'post',
                    onSuccess: e
                    ,
                    onError: e
                });
    });


    return true;
}// alteraTipoTaxa()
function recalcular(index) {
    try {

        //    var total_anterior = $("total").value;
        var valor_taxa_fixa = parseFloat(colocarPonto($("valorTaxaFixa_" + index).value));
        var valor_itr = parseFloat(colocarPonto($("valorItr_" + index).value));
        var fretepeso = parseFloat(colocarPonto($("valorFretePeso_" + index).value));
        var fretevalor = parseFloat(colocarPonto($("valorFreteValor_" + index).value));
        var adicionais = parseFloat(colocarPonto($("valorDespacho_" + index).value));
        var aceme = parseFloat(colocarPonto($("valorAdeme_" + index).value));
        var outros = parseFloat(colocarPonto($("valorOutros_" + index).value));
        var aliqfrete = parseFloat(colocarPonto($("aliquotaIcms_" + index).value));
        var valor_sec_cat = parseFloat(colocarPonto($("valorSecCat_" + index).value));
        var valor_gris = parseFloat(colocarPonto($("valorGris_" + index).value));
        var valor_pedagio = parseFloat(colocarPonto($("valorPedagio_" + index).value));
        var valor_desconto = parseFloat(colocarPonto($("valorDesconto_" + index).value));
        var valor_tde = parseFloat(colocarPonto($('valorTde_' + index).value));
        var total = (valor_taxa_fixa + valor_itr + fretepeso + fretevalor + adicionais + aceme + outros
                + valor_gris + valor_pedagio + valor_sec_cat) - valor_desconto;

        var basecalculo = parseFloat(colocarPonto($("baseCalculoIcms_" + index).value));
        var uf = $("filial").value.split("@@")[1];


        //calculando a diferença do valor de icms pelo total
        if ($("isAddIcms_" + index).checked && false) {
            if (uf == 'MG' && $('con_uf').value == 'MG' && $('idConsignatario_' + index).value == $('idDestinatario_' + index).value) {
                total += parseFloat((basecalculo * aliqfrete / 100) * 80 / 100);
            } else {
                total += parseFloat(basecalculo * aliqfrete / 100);
            }
        }

        //o metodo isNaN() retorna se o valor NAO eh um numero. (Not a Number)
        if (!isNaN(total)) {
            total = total.toFixed(3);

            $("totalPrestacao_" + index).value = colocarVirgula(arredondar(total, 2));
            prepararIniciarContratoFrete();

            var calcMinimo = false;
            invisivel($("brMinimo_" + index));
            invisivel($("labelMinimo_" + index));
            calcMinimo = verificaFreteMinimo(index);
            fretepeso = parseFloat(colocarPonto($("valorFretePeso_" + index).value));
            fretevalor = parseFloat(colocarPonto($("valorFreteValor_" + index).value));
            //Se possui frete minimo então refazer estes calculos
            if (calcMinimo) {
                valor_taxa_fixa = parseFloat(colocarPonto($("valorTaxaFixa_" + index).value));
                valor_itr = parseFloat(colocarPonto($("valorItr_" + index).value));
                adicionais = parseFloat(colocarPonto($("valorDespacho_" + index).value));
                aceme = parseFloat(colocarPonto($("valorAdeme_" + index).value));
                outros = parseFloat(colocarPonto($("valorOutros_" + index).value));
                valor_sec_cat = ($("isSecCat_" + index).checked ? parseFloat(colocarPonto($("valorSecCat_" + index).value)) : 0);
                valor_gris = parseFloat(colocarPonto($("valorGris_" + index).value));
                valor_pedagio = parseFloat(colocarPonto($("valorPedagio_" + index).value));
                valor_desconto = parseFloat(colocarPonto($("valorDesconto_" + index).value));
                valor_tde = ($('isTde_' + index).checked ? parseFloat(colocarPonto($('valorTde_' + index).value)) : 0);
                total = (valor_taxa_fixa + valor_itr + fretepeso + fretevalor + adicionais + aceme + outros
                        + valor_gris + valor_pedagio + valor_tde + valor_sec_cat) - valor_desconto;

                basecalculo = parseFloat(colocarPonto($("baseCalculoIcms_" + index).value));


                //calculando a diferença do valor de icms pelo total
                if ($("isAddIcms_" + index).checked && false) {
                    if (uf == 'MG' && $('con_uf').value == 'MG' && $('idConsignatario_' + index).value == $('idDestinatario_' + index).value) {
                        total += parseFloat((basecalculo * aliqfrete / 100) * 80 / 100);
                    } else {
                        total += parseFloat(basecalculo * aliqfrete / 100);
                    }
                }

                total = total.toFixed(3);

                $("totalPrestacao_" + index).value = colocarVirgula(arredondar(total, 2));
                prepararIniciarContratoFrete();

                visivel($("brMinimo_" + index));
                visivel($("labelMinimo_" + index));

                if (total > 0) {
                    calcularBaseIcms(index);
                    calcularIcms(index);
                } else {
                    $("baseCalculoIcms_" + index).value = "0,00";
                }
                //marcarTde($("isTde_"+index));
                return null;

            } else {
                //                invisivel($("brMinimo_"+index));
                //                invisivel($("labelMinimo_"+index));
            }
            //passando a flag que nao recalcula
            //            return null;
            //        }

            var resultado = parseFloat(colocarPonto($("totalPrestacao_" + index).value));
            if ($('isTde_' + index).checked) {
                if (tarifas != undefined && tarifas[index] != null) {
                    if (tarifas[index].formula_tde != undefined && tarifas[index].formula_tde != '') {
                        $('valorTde_' + index).value = colocarVirgula(getTDE(tarifas[index].formula_tde, $("tipoFreteTabela_" + index).value,
                                colocarPonto($('valorPesoTotalNF_' + index).value), colocarPonto($('valorMercadoriaTotalNF_' + index).value),
                                colocarPonto($('valorVolumeTotalNF_' + index).value), $('qtdPalletsTabela_' + index).value,
                                $('distanciaKmLocais_' + index).value, $('tipoVeiculoTabela_' + index).value, tarifas[index].is_considerar_maior_peso,
                                colocarPonto($("cubagemBaseTotalNF_" + index).value), colocarPonto($("cubagemMetroTotalNF_" + index).value),
                                $('qtdEntregasTabela_' + index).value, $('tipoTransporte').value, resultado, fretepeso, fretevalor, $('_tipoArredondamentoPesoConsignatario_' + index).value, tarifas[index].tipo_inclusao_icms, $('aliquotaIcms_' + index).value,
                                ($("idConsignatario_" + index).value == $("idRemetente_" + index).value ? "0" : ($("idConsignatario_" + index).value == $("idDestinatario_" + index).value ? "1" : "2")), $("redespachoValor_" + index).value, $("redespachoValorIcms_" + index).value));
                    } else if (tarifas[index].tipo_tde == 'v') {
                        $('valorTde_' + index).value = colocarVirgula(tarifas[index].valor_dificuldade_entrega);
                        if (tarifas[index].tipo_inclusao_icms == 'i' && $('aliquotaIcms_' + index).value != 0) {
                            $('valorTde_' + index).value = colocarVirgula(parseFloat(colocarPonto($('valorTde_' + index).value)) / (1 - parseFloat(colocarPonto($('aliquotaIcms_' + index).value)) / 100));
                        }
                    } else if (tarifas[index].tipo_tde == 'p') {
                        $('valorTde_' + index).value = colocarVirgula((parseFloat(resultado) * tarifas[index].valor_dificuldade_entrega / 100));
                        if (tarifas[index].tipo_inclusao_icms == 'i' && $('aliquotaIcms_' + index).value != 0) {
                            $('valorTde_' + index).value = colocarVirgula(parseFloat(colocarPonto($('valorTde_' + index).value)) / (1 - parseFloat(colocarPonto($('aliquotaIcms_' + index).value)) / 100));
                        }
                    }
                    valor_tde = parseFloat(colocarPonto($('valorTde_' + index).value));
                }
                //$('valorTde_' + index).value = colocarVirgula($('valorTde_' + index).value);
                resultado = parseFloat(resultado) + parseFloat(valor_tde);

            } else {
                $('valorTde_' + index).value = "0,00";
            }
            var aliqTabelaMin = parseFloat(colocarPonto($('aliquotaIcms_' + index).value));
            if ($("isSecCat_" + index).checked) {
                if (tarifas != undefined && tarifas[index] != null) {
                    $("calculaSecCat_" + index).value = tarifas[index].calcula_sec_cat;
                    if (tarifas[index].calcula_sec_cat == 'c') {
                        invisivel($('lbCobrarSecCat_' + index));
                        invisivel($('isSecCat_' + index));
                    } else {
                        visivel($('lbCobrarSecCat_' + index));
                        visivel($('isSecCat_' + index));
                    }
                    if (tarifas[index].calcula_sec_cat != null && tarifas[index].calcula_sec_cat != undefined) {
                        if ($("filial").value.split('@@')[1] == 'MG' && $('consignatarioUF_' + index).value == 'MG' && $('idConsignatario_' + index).value == $('idRemetente_' + index).value
                                && ($('isStMgRemetente_' + index).value == 'true' || $('isStMgRemetente_' + index).value == 't')) {
                            aliqTabelaMin = 14.4;
                        }
                        $("valorSecCat_" + index).value = colocarVirgula(getValorSecCat(tarifas[index].valor_sec_cat, tarifas[index].formula_sec_cat, $('tipoFreteTabela_' + index).value,
                                colocarPonto($('valorPesoTotalNF_' + index).value), colocarPonto($('valorMercadoriaTotalNF_' + index).value), colocarPonto($('valorVolumeTotalNF_' + index).value), '0',
                                $('distanciaKmLocais_' + index).value, $('tipoVeiculoTabela_' + index).value, tarifas[index].is_considerar_maior_peso,
                                colocarPonto($("cubagemBaseTotalNF_" + index).value), colocarPonto($("cubagemMetroTotalNF_" + index).value),
                                $('qtdEntregasTabela_' + index).value, $("tipoTransporte").value, tarifas[index].peso_limite_sec_cat,
                                tarifas[index].valor_excedente_sec_cat, tarifas[index].tipo_inclusao_icms, aliqTabelaMin, $('_tipoArredondamentoPesoConsignatario_' + index).value));
                    }
                }
                resultado = parseFloat(resultado);
            } else {
                $("valorSecCat_" + index).value = "0.00";
            }
            $("totalPrestacao_" + index).value = colocarVirgula(resultado);
            if (resultado > 0) {
                calcularBaseIcms(index);
            } else {
                $("baseCalculoIcms_" + index).value = "0,00";
            }

            basecalculo = colocarPonto($("baseCalculoIcms_" + index).value);

            //calculando o valor do icms
            var txICMS = parseFloat((basecalculo * aliqfrete) / 100);
            txICMS = txICMS.toFixed(3);
            //calcularTotalPrestacao(index);
            $("valorIcms_" + index).value = colocarVirgula(arredondar(txICMS, 2));

            //atualizando a parcelas(somente se existir uma)

            //recalculado os valores do redespachante    
            //        calculaVlRedespachante();
            //        if (<%=acao.equals("iniciar")%> && <%=cfg.isCartaFreteAutomatica()%>){
            //			calcularFreteCarreteiro();
            //	}

        }

    } catch (e) {
        console.error(e);
    }

}//recalcular
function definirAliquotaIcmsCtrc(index, enviarObs) {
    var obs = "";
    var aliquotaIcmsJs = null;
    var podeAlterar = ($('podeAlterar_' + index).value == "true" ? true : false);
    var isSubContrato = ($('isSubContrato_' + index).value == "true" ? true : false);
    var filial = $("filial").value;
    var ativarICMSGoias = (filial.split("@@")[12] == "true" || filial.split("@@")[12] == "t");
    var remetenteUf = $("remetenteUF_" + index).value;
    var filialUf = filial.split("@@")[1];
    var isCif = ($("idConsignatario_" + index).value == $("idRemetente_" + index).value);
    var obsFisco = "";

    if (!enviarObs) {
        obs = $("observacaoOutros_" + index);
        obsFisco = $("observacaoFiscoOutros_" + index);
    }
    try {
        if (podeAlterar && !isSubContrato) {
            var ufOrigem = $("ufOrigemLocais_" + index).value;
            var ufDestino = $("ufDestinoLocais_" + index).value;
            var cidadeDestino = $("cidadeDestinoIdLocais_" + index).value;
            if (ufOrigem != "" && ufDestino != "") {
                definirValorAliquota(ufOrigem, ufDestino, cidadeDestino, $("aliquotaIcmsH_" + index), obs, $("percReducaoIcmsConfig_" + index),
                        $("tipoTransporte").value, $("inscricaoEstadualDestinatario_" + index).value.toUpperCase() == "ISENTO", $("stIcmsConfig_" + index), $("tipoTributacao_Consignatario_" + index).value, obsFisco);
                $("aliquotaIcms_" + index).value = colocarVirgula(parseFloat($("aliquotaIcmsH_" + index).value));

            }
            //is_IN_GSF_1298_16_GO
        }
        if (filialUf.toUpperCase() == "GO" && !ativarICMSGoias && remetenteUf.toUpperCase() == "GO" && isCif) {
            $("aliquotaIcms_" + index).value = '0,00';
            $("aliquotaIcmsH_" + index).value = '0,00';
        }
    } catch (ex) {
        alert(ex);
    }
}

function definirICMSCTe(index) {
    var podeAlterar = ($('podeAlterar_' + index).value == "true" ? true : false);
    var stIcms = $("stIcms_" + index);
    var percReducao = $("percReducaoIcms_" + index);

    var utilizarNormativaGSF598GO = $("utilizarNormativaGSF598GO_" + index);
    if (podeAlterar) {
        if (parseInt($("consignatarioStIcms_" + index).value, 10) == 0) {
            habilitar(stIcms);
            stIcms.value = $("stIcmsConfig_" + index).value;
            percReducao.value = colocarVirgula($("percReducaoIcmsConfig_" + index).value);
            utilizarNormativaGSF598GO.value = "false";
        } else {
            stIcms.value = $("consignatarioStIcms_" + index).value;
            percReducao.value = colocarVirgula($("reducaoBaseIcmsConsignatario_" + index).value);
            utilizarNormativaGSF598GO.value = $("utilizarNormativaGSF598GOConsignatario_" + index).value;
            desabilitar(stIcms);
        }
    }
}




function showAddConhecimentoNotaAdicionais(elemento) {
    var sufix = elemento.id.replace("addShow", "");
    var tr = $("trNotaAdicionais" + sufix);
    if (isVisivel(tr)) {
        invisivel(tr);
        elemento.src = "img/plus.jpg";
    } else {
        elemento.src = "img/minus.jpg";
        visivel(tr);
    }
}

function calcularCubagemNota(elemento, isAlterando) {
    try {
        isAlterando = (isAlterando == null || isAlterando == undefined ? false : isAlterando);
        var metro, volume, altura, largura, comprimento;
        metro = volume = altura = largura = comprimento = 0;
        var indexCtrc = elemento.id.split("_")[1];
        var qtdCubagens = 0;
        var qtdNotas = parseInt($("qtdNotas_" + indexCtrc).value, 10);
        for (var j = 1; j <= qtdNotas; j++) {
            if ($("notaVolume_" + indexCtrc + "_" + j) != null) {

                qtdCubagens = parseInt($("qtdCubagens_" + indexCtrc + "_" + j).value, 10);
                volume = 0;
                altura = 0;
                comprimento = 0;
                largura = 0;
                for (var i = 1; i <= qtdCubagens; i++) {

                    if ($("cubVolume_" + indexCtrc + "_" + j + "_" + i) != null) {

                        volume += parseFloat(colocarPonto($("cubVolume_" + indexCtrc + "_" + j + "_" + i).value));
                        altura += parseFloat(colocarPonto($("cubAltura_" + indexCtrc + "_" + j + "_" + i).value));
                        comprimento += parseFloat(colocarPonto($("cubComprimento_" + indexCtrc + "_" + j + "_" + i).value));
                        largura += parseFloat(colocarPonto($("cubLargura_" + indexCtrc + "_" + j + "_" + i).value));
                        // alert("cubMetroHid_: "+$("cubMetroHid_"+indexCtrc+"_"+j+"_"+i).value);


                        if (parseFloat(colocarPonto($("cubMetroHid_" + indexCtrc + "_" + j + "_" + i).value)) == 0 || $("cubMetroHid_" + indexCtrc + "_" + j + "_" + i).value == "0,0000" || isAlterando) {

                            //IF criado para carregar no conhecimento o metro cubico definido no arquivo NOTFIS. Criado por Deivid com supervisão de GLeidson em 30-01-2015
                            if (parseFloat(colocarPonto($("cubAltura_" + indexCtrc + "_" + j + "_" + i).value)) != 0 &&
                                    parseFloat(colocarPonto($("cubComprimento_" + indexCtrc + "_" + j + "_" + i).value)) != 0 &&
                                    parseFloat(colocarPonto($("cubLargura_" + indexCtrc + "_" + j + "_" + i).value)) != 0
                                    && parseFloat(colocarPonto($("cubVolume_" + indexCtrc + "_" + j + "_" + i).value)) != 0) {

                                $("cubMetro_" + indexCtrc + "_" + j + "_" + i).value = colocarVirgula(parseFloat(colocarPonto($("cubVolume_" + indexCtrc + "_" + j + "_" + i).value))
                                        * parseFloat(colocarPonto($("cubAltura_" + indexCtrc + "_" + j + "_" + i).value))
                                        * parseFloat(colocarPonto($("cubComprimento_" + indexCtrc + "_" + j + "_" + i).value))
                                        * parseFloat(colocarPonto($("cubLargura_" + indexCtrc + "_" + j + "_" + i).value)), 4);
                            }
                            metro += parseFloat(colocarPonto($("cubMetro_" + indexCtrc + "_" + j + "_" + i).value));
                        } else {
                            metro = $("cubMetroHid_" + indexCtrc + "_" + j + "_" + i).value;
                        }
                    }
                    if (volume != parseFloat(0)) {
                        $("notaVolume_" + indexCtrc + "_" + j).value = colocarVirgula(volume, 4);
                    }
                }
            }
        }

        $("cubagemLarguraTotalNF_" + indexCtrc).value = colocarVirgula(largura, 4);
        $("cubagemLarguraTotalCF_" + indexCtrc).value = colocarVirgula(largura, 4);
        $("cubagemComprimentoTotalNF_" + indexCtrc).value = colocarVirgula(comprimento, 4);
        $("cubagemComprimentoTotalCF_" + indexCtrc).value = colocarVirgula(comprimento, 4);
        $("cubagemAlturaTotalNF_" + indexCtrc).value = colocarVirgula(altura, 4);
        $("cubagemAlturaTotalCF_" + indexCtrc).value = colocarVirgula(altura, 4);
        if ($("cubagemMetroHid_" + indexCtrc != "0,00")) {
            $("cubagemMetroTotalNF_" + indexCtrc).value = colocarVirgula(metro, 8);
        } else {
            $("cubagemMetroTotalNF_" + indexCtrc).value = colocarVirgula($("cubagemMetroHid_" + indexCtrc).value, 4);
        }
        $("cubagemMetroTotalCF_" + indexCtrc).value = $("cubagemMetroTotalNF_" + indexCtrc).value;

        alteraTipoTaxa("S", indexCtrc);
    } catch (e) {
        alert("Erro ao calcular cubagens.\n" + e);
    }

}


function calcularCubagemComposicaoFrete(elemento) {

    var indexCtrc = elemento.id.split("_")[1];
    var total = 0;

    if ($("cubagemComprimentoTotalCF_" + indexCtrc) != null) {

        if (parseFloat(colocarPonto($("cubagemComprimentoTotalCF_" + indexCtrc).value)) != 0 || $("cubagemComprimentoTotalCF_" + indexCtrc).value != "0,0000") {

            if (parseFloat(colocarPonto($("cubagemComprimentoTotalCF_" + indexCtrc).value)) != 0 &&
                    parseFloat(colocarPonto($("cubagemAlturaTotalCF_" + indexCtrc).value)) != 0 &&
                    parseFloat(colocarPonto($("cubagemLarguraTotalCF_" + indexCtrc).value)) != 0) {

                total = colocarVirgula(parseFloat(colocarPonto($("cubagemComprimentoTotalCF_" + indexCtrc).value))
                        * parseFloat(colocarPonto($("cubagemAlturaTotalCF_" + indexCtrc).value))
                        * parseFloat(colocarPonto($("cubagemLarguraTotalCF_" + indexCtrc).value)), 4);
            }

            $("cubagemMetroTotalCF_" + indexCtrc).value = total;
            $("cubagemMetroTotalNF_" + indexCtrc).value = total;
        }
    }
}


function preencheCubagem(elemento) {

    var metro, volume, altura, largura, comprimento;
    metro = volume = altura = largura = comprimento = 0;
    var indexCtrc = elemento.id.split("_")[1];
    var i2 = elemento.id.split("_")[2];
    var i3 = elemento.id.split("_")[3];
    var qtdCubagens = 0;

    var valor = elemento.value;
    var qtdNotas = parseInt($("qtdNotas_" + indexCtrc).value, 10);
    for (var j = 1; j <= qtdNotas; j++) {
        if ($("notaVolume_" + indexCtrc + "_" + j) != null) {
            qtdCubagens = parseInt($("qtdCubagens_" + indexCtrc + "_" + j).value, 10);
            for (var i = 1; i <= qtdCubagens; i++) {
                metro += parseFloat(colocarPonto($("cubMetro_" + indexCtrc + "_" + j + "_" + i).value));
            }
        }
    }
    $("cubMetroHid_" + indexCtrc + "_" + i2 + "_" + i3).value = valor;
    $("cubagemMetroTotalNF_" + indexCtrc).value = colocarVirgula(metro, 4);
    $("cubagemMetroHid_" + indexCtrc).value = colocarVirgula(metro, 4);
    $("cubagemMetroTotalCF_" + indexCtrc).value = colocarVirgula(metro, 4);
}


function preencheCubagemTotal(elemento) {

    var indexCtrc = elemento.id.split("_")[1];
    var cubagem = 0;

    $("cubagemMetroHid_" + indexCtrc).value = elemento.value;
    $("cubagemMetroTotalNF_" + indexCtrc).value = elemento.value;


}


function verificaFreteMinimo(index)
{
    try {
        var valorRateioLiquido = 0;
        if ($("isRedespacho_" + index).checked) {
            valorRateioLiquido = parseFloat(colocarPonto($("redespachoValor_" + index).value)) - parseFloat(colocarPonto($("redespachoValorIcms_" + index).value));
        }
        if (tarifas[index] != null && tarifas[index] != undefined) {
            //se nao for combinado ou nao for peso por faixa obrigue o frete minimo
            if (parseFloat($('tipoFreteTabela_' + index).value) == "3") {
                return false;
            }
            var aliqTabelaMin = parseFloat(colocarPonto($('aliquotaIcms_' + index).value));
            if ($("filial").value.split('@@')[1] == 'MG' && $('consignatarioUF_' + index).value == 'MG' && $('idConsignatario_' + index).value == $('idRemetente_' + index).value
                    && ($('isStMgRemetente_' + index).value == 'true' || $('isStMgRemetente_' + index).value == 't')) {
                aliqTabelaMin = 14.4;
            }


            var totalX = parseFloat(colocarPonto($("totalPrestacao_" + index).value));
            var zeraTaxa = true;
            if (tarifas[index].is_desconsidera_taxa_minimo == true || tarifas[index].is_desconsidera_taxa_minimo == 't' || tarifas[index].is_desconsidera_taxa_minimo == 'true') {
                totalX = parseFloat(totalX) - parseFloat(colocarPonto($("valorTaxaFixa_" + index).value));
                zeraTaxa = false;
            }
            var zeraDespacho = true;
            if (tarifas[index].is_desconsidera_despacho_minimo == true || tarifas[index].is_desconsidera_despacho_minimo == 't' || tarifas[index].is_desconsidera_despacho_minimo == 'true') {
                totalX = parseFloat(totalX) - parseFloat(colocarPonto($("valorDespacho_" + index).value));
                zeraDespacho = false;
            }
            var zeraSec = true;
            if (tarifas[index].is_desconsidera_seccat_minimo == true || tarifas[index].is_desconsidera_seccat_minimo == 't' || tarifas[index].is_desconsidera_seccat_minimo == 'true') {
                totalX = parseFloat(totalX) - parseFloat(colocarPonto($("valorSecCat_" + index).value));
                zeraSec = false;
            }
            var zeraOutros = true;
            if (tarifas[index].is_desconsidera_outros_minimo == true || tarifas[index].is_desconsidera_outros_minimo == 't' || tarifas[index].is_desconsidera_outros_minimo == 'true') {
                totalX = parseFloat(totalX) - parseFloat(colocarPonto($("valorOutros_" + index).value));
                zeraOutros = false;
            }
            var zeraGris = true;
            if (tarifas[index].is_desconsidera_gris_minimo == true || tarifas[index].is_desconsidera_gris_minimo == 't' || tarifas[index].is_desconsidera_gris_minimo == 'true') {
                totalX = parseFloat(totalX) - parseFloat(colocarPonto($("valorGris_" + index).value));
                zeraGris = false;
            }
            var zeraPedagio = true;
            if (tarifas[index].is_desconsidera_pedagio_minimo == true || tarifas[index].is_desconsidera_pedagio_minimo == 't' || tarifas[index].is_desconsidera_pedagio_minimo == 'true') {
                totalX = parseFloat(totalX) - parseFloat(colocarPonto($("valorPedagio_" + index).value));
                zeraPedagio = false;
            }
            var zeraSeguro = true;
            var seguroX = 0;
            var raizConsignatario = $("consignatarioCNPJ_" + index).value.replace(/[^\d]+/g, '');
            raizConsignatario = raizConsignatario.substring(0, 8);
            var raizRedespacho = $("redespachoCNPJ_" + index).value.replace(/[^\d]+/g, '');
            raizRedespacho = raizRedespacho.substring(0, 8);
            if (tarifas[index].is_desconsidera_seguro_minimo == true || tarifas[index].is_desconsidera_seguro_minimo == 't' || tarifas[index].is_desconsidera_seguro_minimo == 'true') {
                seguroX = getFreteValor(parseFloat(colocarPonto($('valorMercadoriaTotalNF_' + index).value)), tarifas[index].percentual_advalorem,
                        tarifas[index].percentual_nf, tarifas[index].base_nf_percentual, tarifas[index].valor_percentual_nf,
                        $('tipoFreteTabela_' + index).value, 'p', tarifas[index].formula_seguro,
                        tarifas[index].formula_percentual, parseFloat(colocarPonto($('valorPesoTotalNF_' + index).value)),
                        parseFloat(colocarPonto($('valorVolumeTotalNF_' + index).value)), '0',
                        $('distanciaKmLocais_' + index).value, $('tipoVeiculoTabela_' + index).value, tarifas[index].is_considerar_maior_peso,
                        parseFloat(colocarPonto($("cubagemBaseTotalNF_" + index).value)), parseFloat(colocarPonto($("cubagemMetroTotalNF_" + index).value)),
                        (raizConsignatario == raizRedespacho), valorRateioLiquido,
                        $('qtdEntregasTabela_' + index).value, $("tipoTransporte").value, tarifas[index].tipo_inclusao_icms, aliqTabelaMin, true,
                        ($("idConsignatario_" + index).value == $("idRemetente_" + index).value ? "0" : ($("idConsignatario_" + index).value == $("idDestinatario_" + index).value ? "1" : "2")), $("redespachoValor_" + index).value, $("redespachoValorIcms_" + index).value);
                totalX = parseFloat(totalX) - parseFloat(seguroX);
                zeraSeguro = false;
            }
            //se o total estiver menor que o frete minimo, entao o minimo prevalecerá
            if (isFreteMinimo(totalX, tarifas[index].valor_frete_minimo, tarifas[index].formula_minimo, $('tipoFreteTabela_' + index).value,
                    parseFloat(colocarPonto($('valorPesoTotalNF_' + index).value)), parseFloat(colocarPonto($('valorMercadoriaTotalNF_' + index).value)),
                    parseFloat(colocarPonto($('valorVolumeTotalNF_' + index).value)), '0', $('distanciaKmLocais_' + index).value, $('tipoVeiculoTabela_' + index).value,
                    tarifas[index].is_considerar_maior_peso, parseFloat(colocarPonto($("cubagemBaseTotalNF_" + index).value)), colocarPonto($("cubagemMetroTotalNF_" + index).value),
                    $('qtdEntregasTabela_' + index).value, $("tipoTransporte").value, tarifas[index].tipo_inclusao_icms,
                    colocarPonto($("aliquotaIcms_" + index).value), tarifas[index].is_desconsidera_icms_minimo,
                    ($("idConsignatario_" + index).value == $("idRemetente_" + index).value ? "0" : ($("idConsignatario_" + index).value == $("idDestinatario_" + index).value ? "1" : "2")), $("redespachoValor_" + index).value, $("redespachoValorIcms_" + index).value)) {

                //                alert("O total do frete é menor que o mínimo, prevalecerá o mínimo");
                //                visivel($("brMinimo_"+index));
                //                visivel($("labelMinimo_"+index));

                var vlMinimo = (getFreteMinimo(tarifas[index].valor_frete_minimo,
                        tarifas[index].formula_minimo, $('tipoFreteTabela_' + index).value, colocarPonto($('valorPesoTotalNF_' + index).value),
                        colocarPonto($('valorMercadoriaTotalNF_' + index).value), $('valorVolumeTotalNF_' + index).value, '0',
                        colocarPonto($('distanciaKmLocais_' + index).value), $('tipoVeiculoTabela_' + index).value, tarifas[index].is_considerar_maior_peso,
                        colocarPonto($("cubagemBaseTotalNF_" + index).value), colocarPonto($("cubagemMetroTotalNF_" + index).value), $('qtdEntregasTabela_' + index).value,
                        $("tipoTransporte").value, tarifas[index].is_desconsidera_icms_minimo, tarifas[index].tipo_inclusao_icms,
                        colocarPonto($('aliquotaIcms_' + index).value),
                        ($("idConsignatario_" + index).value == $("idRemetente_" + index).value ? "0" : ($("idConsignatario_" + index).value == $("idDestinatario_" + index).value ? "1" : "2")), $("redespachoValor_" + index).value, $("redespachoValorIcms_" + index).value));

                //$("valorFretePeso_" + index).value
                //$("valorFreteValor_" + index).value1
                $("valorFretePeso_" + index).value = "0,00";
                if (zeraSeguro) {
                    if ($('tipoTransporte').value == 'a') {
                        $("valorFreteValor_" + index).value = colocarVirgula(parseFloat(vlMinimo));
                    } else {
                        if (tarifas[index].tipo_impressao_frete_minimo == 'p') {
                            $("valorFreteValor_" + index).value = '0,00';
                            $("valorFretePeso_" + index).value = colocarVirgula(parseFloat(vlMinimo));
                        } else {
                            $("valorFreteValor_" + index).value = colocarVirgula(parseFloat(vlMinimo));
                            $("valorFretePeso_" + index).value = '0,00';
                        }
                    }
                } else {
                    if ($('tipoTransporte').value == 'a') {
                        $("valorFretePeso_" + index).value = colocarVirgula(parseFloat(vlMinimo));
                        $("valorFreteValor_" + index).value = colocarVirgula(parseFloat(seguroX));
                    } else {
                        if (tarifas[index].tipo_impressao_frete_minimo == 'p') {
                            $("valorFretePeso_" + index).value = colocarVirgula(parseFloat(vlMinimo));
                            $("valorFreteValor_" + index).value = colocarVirgula(parseFloat(seguroX));
                        } else {
                            $("valorFreteValor_" + index).value = colocarVirgula(parseFloat(vlMinimo) + parseFloat(seguroX));
                        }
                    }
                }
                if (zeraTaxa) {
                    $("valorTaxaFixa_" + index).value = "0,00";
                }
                if (zeraDespacho) {
                    $("valorDespacho_" + index).value = "0,00";
                }
                if (zeraSec) {
                    $("valorSecCat_" + index).value = "0,00";
                }
                if (zeraOutros) {
                    $("valorOutros_" + index).value = "0,00";
                }
                if (zeraGris) {
                    $("valorGris_" + index).value = "0,00";
                }
                if (zeraPedagio) {
                    $("valorPedagio_" + index).value = "0,00";
                }
                $("valorDesconto_" + index).value = "0,00";
                if (tarifas[index].is_desconsidera_icms_minimo == true || tarifas[index].is_desconsidera_icms_minimo == 't' || tarifas[index].is_desconsidera_icms_minimo == 'true') {
                    $("isAddIcms_" + index).checked = false;
                    $("isAddPisCofins_" + index).checked = false;
                }
                //flag para a atualizacao do calculo
                //        if (arguments[0] == false){
                //            return false;
                //        }
                //                recalcular(index);
                return true;
            }
        }
        return false;
    } catch (e) {
        alert("Erro verificar frete minimo!\n" + e);
    }

}
function espelharTotalCubagem(elemento) {
    var sufix = elemento.id.split("_")[0].substring(elemento.id.split("_")[0].length - 2, elemento.id.split("_")[0].length);
    var index = elemento.id.split("_")[1];
    //TotalCF
    try {
        switch (sufix) {
            case "NF":
                $("cubagemComprimentoTotalCF_" + index).value = $("cubagemComprimentoTotalNF_" + index).value;
                $("cubagemLarguraTotalCF_" + index).value = $("cubagemLarguraTotalNF_" + index).value;
                $("cubagemAlturaTotalCF_" + index).value = $("cubagemAlturaTotalNF_" + index).value;
                $("cubagemMetroTotalCF_" + index).value = $("cubagemMetroTotalNF_" + index).value;
                $("cubagemBaseTotalCF_" + index).value = $("cubagemBaseTotalNF_" + index).value;
                break;
            case "CF":
                $("cubagemComprimentoTotalNF_" + index).value = $("cubagemComprimentoTotalCF_" + index).value;
                $("cubagemLarguraTotalNF_" + index).value = $("cubagemLarguraTotalCF_" + index).value;
                $("cubagemAlturaTotalNF_" + index).value = $("cubagemAlturaTotalCF_" + index).value;
                $("cubagemMetroTotalNF_" + index).value = $("cubagemMetroTotalCF_" + index).value;
                $("cubagemBaseTotalNF_" + index).value = $("cubagemBaseTotalCF_" + index).value;
                break;
        }
    } catch (ex) {
        alert(ex);
    }
}
function marcarTde(elemento) {
    var index = elemento.id.split("_")[1];
    if (elemento.checked) {
        if (tarifas[index] != null) {
            $('valorTde_' + index).value = colocarVirgula(tarifas[index].valor_dificuldade_entrega);
            if (tarifas[index].tipo_inclusao_icms == 'i' && $('aliquotaIcms_' + index).value != 0) {
                $('valorTde_' + index).value = formatoMoeda(parseFloat($('valorTde_' + index).value) / (1 - parseFloat($('aliquotaIcms_' + index).value) / 100));
            }
        }
    }
}
function marcarSecCat(elemento) {
    var index = elemento.id.split("_")[1];
    if (elemento.checked) {
        if (tarifas[index] != null) {
            $('valorSecCat_' + index).value = colocarVirgula(tarifas[index].valor_sec_cat);
        }
    }
}
function definiCidadeOrigem(index) {
    var tipoOrigemFrete = $("consignatarioTipoOrigemFrete_" + index).value;
    var cidadeOrigemDesc = $("cidadeOrigemLocais_" + index);
    var ufOrigem = $("ufOrigemLocais_" + index);
    var cidadeOrigemId = $("cidadeOrigemIdLocais_" + index);


    if ($("isRedespacho_" + index).checked && $("exp_" + index).checked) {
        switch (tipoOrigemFrete) {
            case "f":
                cidadeOrigemId.value = $("filial").value.split("@@")[3];
                cidadeOrigemDesc.value = $("filial").value.split("@@")[4];
                ufOrigem.value = $("filial").value.split("@@")[1];
                break;
            case "r":
                cidadeOrigemExpedidor(index);
                break;
            default:
                cidadeOrigemDesc.value = "";
                cidadeOrigemId.value = "";
                ufOrigem.value = "";
                break;
        }
        //não faz nada, tava dando erro quando escolhia redespacho e marcava como expedidor 
    } else {
        switch (tipoOrigemFrete) {
            case "f":
                cidadeOrigemId.value = $("filial").value.split("@@")[3];
                cidadeOrigemDesc.value = $("filial").value.split("@@")[4];
                ufOrigem.value = $("filial").value.split("@@")[1];
                break;
            case "r":
                cidadeOrigemDesc.value = $("remetenteCidade_" + index).value;
                cidadeOrigemId.value = $("remetenteCidadeId_" + index).value;
                ufOrigem.value = $("remetenteUF_" + index).value;
                break;
            default:
                cidadeOrigemDesc.value = "";
                cidadeOrigemId.value = "";
                ufOrigem.value = "";
                break;
        }
    }

    //Quando o tipo origem frete (CIF/FOB/TERCEIROS) Não estiverem marcados(Ao localizar manualmente o remetente e o destinatario) usar a cidade abaixo para calcular a rota.
    if (tipoOrigemFrete == "") {
        cidadeOrigemDesc.value = $("remetenteCidade_" + index).value;
        cidadeOrigemId.value = $("remetenteCidadeId_" + index).value;
        ufOrigem.value = $("remetenteUF_" + index).value;
    }
}
function indexCtrcRemetenteDestinatario(cnpjRem, cnpjDest, obMax) {

    for (var i = 1; i <= parseInt(obMax.value, 10); i++) {

        if ($("destinatarioCNPJ_" + i) != null) {
            if ($("destinatarioCNPJ_" + i).value == cnpjDest && $("remetenteCNPJ_" + i).value == cnpjRem && cnpjRem != "" && cnpjDest != "") {
                return i;
            }
        }
    }
    return 0;
}

function indexCtrcUfDestino(ufDestino, obMax) {
    for (var i = 1; i <= parseInt(obMax.value, 10); i++) {
        if ($("destinatarioUF_" + i) != null) {
            if ($("destinatarioUF_" + i).value == ufDestino && ufDestino != "") {
                return i;
            }
        }
    }
    return 0;
}

/**
 * função que vai procurar o index do cte que tenha o mesmo numero de carga para incluir no mesmo CTe
 */
function indexCTeNumeroCarga(NumeroCarga, obMax) {
    for (var i = 1; i <= parseInt(obMax.value, 10); i++) {
        if ($("numCargaOutros_" + i) != null) {
            if (($("numCargaOutros_" + i).value == NumeroCarga) && (NumeroCarga != "")) {
                return i;
            }
        }
    }
    return 0;
}

function indexCtrcRemetenteDestinatarioNumeroCarga(cnpjRem, cnpjDest, obMax, numeroCarga) {

    for (var i = 1; i <= parseInt(obMax.value, 10); i++) {

        if ($("destinatarioCNPJ_" + i) != null && $("numCargaOutros_" + i) != null) {
            if ($("destinatarioCNPJ_" + i).value == cnpjDest && $("remetenteCNPJ_" + i).value == cnpjRem && cnpjRem != "" && cnpjDest != "" && ($("numCargaOutros_" + i).value == numeroCarga && numeroCarga != "")) {
                return i;
            }
        }
    }
    return 0;
}

function indexCtrcVeiculo(veiculoId, placa, obMax) {
    for (var i = 1; i <= parseInt(obMax.value, 10); i++) {
        if ($("veiculoId_Outros_" + i) != null) {
            if ($("veiculoId_Outros_" + i).value == veiculoId && veiculoId != 0 && veiculoId != "0") {
                return i;
            }
        }
    }
    return 0;
}

//Função usada para o layout cteConfirmadoXML de ctrcs confirmados;
function indexLayoutCtrcConfirmado(numeroCtrc, obMax) {

    for (var i = 1; i <= parseInt(obMax.value, 10); i++) {
        if ($("numero_" + i) != null) {
            if ($("numero_" + i).value == numeroCtrc) {
                return i;
            }
        }
    }
    return 0;
}

function indexCtrcRemetenteDestinatarioPedido(cnpjRem, cnpjDest, obMax, numPedido) {
    for (var i = 1; i <= parseInt(obMax.value, 10); i++) {
        if ($("destinatarioCNPJ_" + i) != null) {
            if ($("destinatarioCNPJ_" + i).value == cnpjDest &&
                    $("remetenteCNPJ_" + i).value == cnpjRem &&
                    $("remetenteCNPJ_" + i).value == cnpjRem &&
                    $("notaPedido_" + i + "_1").value == numPedido &&
                    cnpjRem != "" && cnpjDest != "" && numPedido != "") {
                return i;
            }
        }
    }
    return 0;
}
function indexCtrcRemetenteDestinatarioCtrcRedespacho(cnpjRem, cnpjDest, obMax, ctrcRedespacho) {
    for (var i = 1; i <= parseInt(obMax.value, 10); i++) {
        if ($("destinatarioCNPJ_" + i) != null) {
            if ($("destinatarioCNPJ_" + i).value == cnpjDest &&
                    $("remetenteCNPJ_" + i).value == cnpjRem &&
                    $("remetenteCNPJ_" + i).value == cnpjRem &&
                    $("redespachoCtrc_" + i).value == ctrcRedespacho &&
                    cnpjRem != "" && cnpjDest != "" && ctrcRedespacho != "") {
                return i;
            }
        }
    }
    return 0;
}
function novaImportacao(evento) {
    var url = "CTeControlador?acao=importarCTeLote&evento=" + evento;
    window.open(url, 'anexoCRM', 'width=500, height=200');
}
//TODO: Onde atribuir o freteminimo? em valor_outros?  
function calcularBaseIcms(index) {
    var aliquota = parseFloat(colocarPonto($('aliquotaIcms_' + index).value));
    var baseCalculo = parseFloat(colocarPonto($("totalPrestacao_" + index).value));
    var totalAntesICMS = parseFloat(colocarPonto($("totalPrestacao_" + index).value));
    var isAddIcms = $("isAddIcms_" + index).checked;
    var isAddPisCofins = $("isAddPisCofins_" + index).checked;
    var reducaoBase = 0;
    var indice = 0;
    var diferencaIcms = 0;
    var diferencaFed = 0;
    var isUtilizaPautaFiscal = false;
    var xTON = 0;
    var xVLTON = 0;
    var xVLTONPAUTA = 0;
    var xICMS = 0;
    var stIcms = parseInt($("stIcms_" + index).value, 10);
    var utilizarNormativaGSF598GO = ($("utilizarNormativaGSF598GO_" + index).value == "true" || $("utilizarNormativaGSF598GO_" + index).value == "t" ? true : false);

    if ($('filial').value.split("_")[2] == 'true') {
        baseCalculo = parseFloat(parseFloat(colocarPonto($("totalPrestacao_" + index).value))) - parseFloat(colocarPonto($("valorPegadio_" + index).value));
    }

    reducaoBase = parseFloat(colocarPonto($("percReducaoIcms_" + index).value));
    $('totalParcelas_' + index).value = "";
    if (reducaoBase > 0 && stIcms == 3) {//caso tenha valor de redução e o st seja 20 (3 é o id)
        if (isAddIcms && (aliquota != 0)) {
            if (utilizarNormativaGSF598GO) {
                var indiceIcms = ((100 - aliquota) / 100);
                var aliquotaReduzida = aliquota * reducaoBase / 100;
                var indiceReduzido = ((100 - aliquotaReduzida) / 100);
                var totalFrete = parseFloat(colocarPonto($('totalPrestacao_' + index).value));
                var totalPrestacao = (totalFrete / indiceIcms * indiceReduzido);
                var totalPrestacao2 = (totalFrete / indiceIcms);

                $('totalPrestacao_' + index).value = colocarVirgula(totalPrestacao2);
                $('totalParcelas_' + index).value = colocarVirgula(totalPrestacao);
                baseCalculo = (totalPrestacao2 * reducaoBase / 100);
            } else {
                indice = parseFloat((100 - (aliquota - (aliquota * parseFloat(reducaoBase) / 100))) / 100);
                diferencaIcms = (baseCalculo / indice) - baseCalculo;
                diferencaIcms = arredondar(diferencaIcms, 3);
                $('totalPrestacao_' + index).value = colocarVirgula(parseFloat(colocarPonto($('totalPrestacao_' + index).value)) + arredondar(diferencaIcms, 2));
                baseCalculo = parseFloat(baseCalculo) + parseFloat(arredondar(diferencaIcms, 2));
            }
        }
    } else {
        if (isAddIcms && isAddPisCofins && aliquota != 0) {

            var aliquotaICMS = aliquota;
            var aliquotaPISCOFINS = aliquota;
            aliquotaPISCOFINS += parseFloat(formatoMoeda(federais));
            indice = parseFloat((100 - aliquotaPISCOFINS) / 100);
            diferencaIcms = parseFloat((baseCalculo / indice) - baseCalculo);
            diferencaIcms = arredondar(diferencaIcms, 2);
            $('totalPrestacao_' + index).value = colocarVirgula(parseFloat(colocarPonto($('totalPrestacao_' + index).value)) + arredondar(diferencaIcms, 2));

            baseCalculo += diferencaIcms;
            var valorIcms = ((baseCalculo * aliquotaICMS) / 100);
            valorIcms = valorIcms.toFixed(3);
            valorIcms = arredondar(valorIcms, 2);
            $("valorPisCofins_" + index).value = colocarVirgula(parseFloat(diferencaIcms) - parseFloat(valorIcms));
        } else if (isAddIcms && (aliquota != 0)) {

            indice = parseFloat((100 - aliquota) / 100);
            if ($('ufDestinoLocais_' + index).value != 'MG' && $("filial").value.split('@@')[1] == 'MG' && $('consignatarioUF_' + index).value == 'MG' && $('idConsignatario_' + index).value == $('idRemetente_' + index).value
                    && ($('isStMgRemetente_' + index).value == 'true' || $('isStMgRemetente_' + index).value == 't')) {
                indice = 0.856;
            }
            diferencaIcms = parseFloat((baseCalculo - (baseCalculo / indice)) * -1);
            diferencaIcms = diferencaIcms.toFixed(2);
            if ($("filial").value.split('@@')[1] == 'AM' && $('consignatarioUF_' + index).value == 'AM' && $('idConsignatario_' + index).value == $('idRemetente_' + index).value && $('tipoCfopConsignatario_' + index).value == 'i') {
                var credFiscal = (diferencaIcms * 20 / 100)
                $('totalPrestacao_' + index).value = colocarVirgula(parseFloat(colocarPonto($('totalPrestacao_' + index).value)) + arredondar(credFiscal, 2));
            } else {
                $('totalPrestacao_' + index).value = colocarVirgula(parseFloat(colocarPonto($('totalPrestacao_' + index).value)) + arredondar(diferencaIcms, 2));
            }
            baseCalculo = parseFloat(baseCalculo) + parseFloat(arredondar(diferencaIcms, 2));
            $("valorPisCofins_" + index).value = "0,00";
        } else if (isAddPisCofins) {
            //foi alterado aqui pois ANALISE informou que o valor correto é a soma de PIS e COFINS.
            //a analise fez o calculo e aprovou.
            indice = parseFloat((100 - federais) / 100);
            diferencaFed = parseFloat((baseCalculo - (baseCalculo / indice)) * -1);
            $('totalPrestacao_' + index).value = colocarVirgula(parseFloat(colocarPonto($('totalPrestacao_' + index).value)) + arredondar(diferencaFed, 2));
            baseCalculo = parseFloat(baseCalculo) + parseFloat(diferencaFed);
            $("valorPisCofins_" + index).value = colocarVirgula(parseFloat(colocarPonto($('totalPrestacao_' + index).value)) * parseFloat(federais) / 100);
        } else {
            $("valorPisCofins_" + index).value = "0,00";
        }
        if ($("utilizaPautaFiscalConsignatario_" + index).value == "t" || $("utilizaPautaFiscalConsignatario_" + index).value == "true" || $("utilizaPautaFiscalConsignatario_" + index).value == true) {
            var xPeso = parseFloat(colocarPonto($('valorPesoTotalNF_' + index).value));
            var xPesoCubado = parseFloat(colocarPonto($('cubagemMetroTotalNF_' + index).value)) * parseFloat(300); //Segundo a Lei a base sempre deverá ser 300

            if (parseFloat(xPeso) >= parseFloat(xPesoCubado)) {
                xTON = parseFloat(xPeso) / 1000;
            } else {
                xTON = parseFloat(xPesoCubado) / 1000;
            }

            xVLTON = parseFloat(baseCalculo) / parseFloat(xTON);
            xVLTONPAUTA = parseFloat($('valorPautaFiscal_' + index).value);

            if (xVLTON < xVLTONPAUTA) {
                isUtilizaPautaFiscal = true;
            }

            if (isUtilizaPautaFiscal) {
                var xVLTONsemICMS = formatoMoeda(parseFloat(totalAntesICMS) / parseFloat(xTON));
                var xVLTONcomICMS = formatoMoeda(parseFloat(xVLTONsemICMS) + (parseFloat(xVLTONPAUTA) * parseFloat(aliquota) / 100));
                baseCalculo = parseFloat(xVLTONPAUTA) * parseFloat(xTON);
                if (isAddIcms && isAddPisCofins && (aliquota != 0)) {
                    xICMS = ((parseFloat(baseCalculo.toFixed(2)) * parseFloat(aliquota)) / 100);
                    xICMS = xICMS.toFixed(3);
                    xICMS = arredondar(xICMS, 2);
                    var totalComICMS = parseFloat(totalAntesICMS) + parseFloat(xICMS);
                    var aliquotaPIS = parseFloat(formatoMoeda(federais));
                    var indicePIS = parseFloat((100 - aliquotaPIS) / 100);
                    var xVLTONcomPIS = formatoMoeda(parseFloat(xVLTONcomICMS) / parseFloat(indicePIS));
                    $('totalPrestacao_' + index).value = colocarVirgula(parseFloat(xVLTONcomPIS) * parseFloat(xTON));
                    var diferencaPIS = formatoMoeda(parseFloat($('total').value) - parseFloat(totalAntesICMS) - parseFloat(xICMS));
                    $("valorPisCofins_" + index).value = colocarVirgula(parseFloat(diferencaPIS));
                } else if (isAddIcms && (aliquota != 0)) {
                    xICMS = (parseFloat(baseCalculo) * parseFloat(aliquota) / 100);
                    $('totalPrestacao_' + index).value = colocarVirgula(parseFloat(totalAntesICMS) + parseFloat(xICMS));
                }
            }
        }
    }

    $("baseCalculoIcms_" + index).value = colocarVirgula(baseCalculo);
}//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function getPautaFiscal(index) {
    var podeAlterar = ($('podeAlterar_' + index).value == "true" ? true : false);

    if (podeAlterar) {
        if ($("utilizaPautaFiscalConsignatario_" + index).value == "t" || $("utilizaPautaFiscalConsignatario_" + index).value == "true" || $("utilizaPautaFiscalConsignatario_" + index).value == true) {
            //objeto funcao usado na requisicao Ajax(uma espécie de evento)
            function e(transport) {
                var resp = transport.responseText;
                espereEnviar("", false);
                //se deu algum erro na requisicao...
                $('valorPautaFiscal_' + index).value = colocarVirgula(resp);
                if (resp == -1.0) {
                    alert('Não existe pauta fiscal cadastrada, o valor do ICMS não será calculado.');
                    return false;
                } else if (resp == 0.0) {
                    alert('O valor da pauta fiscal é 0,00, favor verificar se está correto com o setor fiscal da empresa.');
                }
                return true;
            }//funcao e()

            espereEnviar("", true);
            new Ajax.Request("ConhecimentoControlador?acao=carregaPautaFiscal&km=" + $("distanciaKmLocais_" + index).value +
                    "&idfilial=" + $("filial").value.split("@@")[0], {
                method: 'post',
                onSuccess: e,
                onError: e
            });
        } else {
            $('valorPautaFiscal_' + index).value = '0,00';
        }
    }
}
function definirTipoFrete(index) {
    var tipoTabela = $("tipoTabelaConsignatario_" + index).value;

    if (tipoTabela != "") {
        $("tipoFreteTabela_" + index).value = tipoTabela;
    }
}
function containsRemetente(ids, idRemetente) {
    if (ids != null && ids != "" && ids.split(",").length > 0) {
        for (i = 0; i < ids.split(",").length; i++) {
            if (ids.split(",")[i] == idRemetente) {
                return true;
            }
        }
    }
    return false;
}
function getValorTotalMercadorias() {
    var qtdCtrc = $("maxConhecimento").value;
    var valorNF = 0;
    for (var i = 1; i <= qtdCtrc; i++) {
        if ($("valorMercadoriaTotalNF_" + i) != null) {
            if ((isRatearCTRCSelecionados && $("chkSave_" + i).checked) || (!isRatearCTRCSelecionados)) {
                valorNF += parseFloat(colocarPonto($("valorMercadoriaTotalNF_" + i).value));
            }
        }
    }
    return valorNF;
}
function getTotalSeguro() {
    try {
        var qtdCtrc = $("maxConhecimento").value;
        var totalSeguroProp = 0;
        for (i = 1; i <= qtdCtrc; i++) {
            if ($('isUrbanoLocais_' + i) != null) {
                if ($('isUrbanoLocais_' + i).checked) {
                    totalSeguroProp += parseFloat(parseFloat(colocarPonto($('valorMercadoriaTotalNF_' + i).value)) *
                            (parseFloat(colocarPonto($('taxaRouboUrbanoLocais_' + i).value)) + parseFloat(colocarPonto($('taxaTombamentoUrbanoLocais_' + i).value))) / 100);
                } else {
                    totalSeguroProp += parseFloat(parseFloat(colocarPonto($('valorMercadoriaTotalNF_' + i).value)) *
                            (parseFloat(colocarPonto($('taxaRouboLocais_' + i).value)) + parseFloat(colocarPonto($('taxaTombamentoLocais_' + i).value))) / 100);
                }
            }
        }
        return totalSeguroProp;
    } catch (e) {
        alert(e);
    }

}
function getPesoTotalCtrcs() {
    var max = parseInt($("maxConhecimento").value, 10);
    var pesoTot = 0;
    for (var i = 1; i <= max; i++) {
        if ($("valorPesoTotalCF_" + i) != null && $("valorPesoTotalCF_" + i) != undefined) {
            if ((isRatearCTRCSelecionados && $("chkSave_" + i).checked) || (!isRatearCTRCSelecionados)) {
                pesoTot += parseFloat(colocarPonto($("valorPesoTotalCF_" + i).value));
            }
        }
    }
    return pesoTot;
}
function getMetroCubicoTotalCtrcs() {
    var max = parseInt($("maxConhecimento").value, 10);
    var metroCubicoTot = 0;
    for (var i = 1; i <= max; i++) {
        if ($("cubagemMetroTotalCF_" + i) != null && $("cubagemMetroTotalCF_" + i) != undefined) {
            if ((isRatearCTRCSelecionados && $("chkSave_" + i).checked) || (!isRatearCTRCSelecionados)) {
                metroCubicoTot += parseFloat(colocarPonto($("cubagemMetroTotalCF_" + i).value));
            }
        }
    }
    return metroCubicoTot;
}
function getTotalGeralPrestacao() {
    var max = parseInt($("maxConhecimento").value, 10);
    var totalPrestacao = 0;
    for (var i = 1; i <= max; i++) {
        if ($("totalPrestacao_" + i) != null && $("totalPrestacao_" + i) != undefined) {
            totalPrestacao += parseFloat(colocarPonto($("totalPrestacao_" + i).value));
        }
    }
    return totalPrestacao;
}
function getTotalGeralFretePeso() {
    var max = parseInt($("maxConhecimento").value, 10);
    var totalfretePeso = 0;
    for (var i = 1; i <= max; i++) {
        if ($("valorFretePeso_" + i) != null && $("valorFretePeso_" + i) != undefined) {
            totalfretePeso += parseFloat(colocarPonto($("valorFretePeso_" + i).value));
        }
    }
    return totalfretePeso;
}
function getTotalGeralKM() {
    var max = parseInt($("maxConhecimento").value, 10);
    var totalKM = 0;
    for (var i = 1; i <= max; i++) {
        if ($("distanciaKmLocais_" + i) != null && $("distanciaKmLocais_" + i) != undefined) {
            totalKM += parseFloat(colocarPonto($("distanciaKmLocais_" + i).value));
        }
    }
    return totalKM;
}
function getTotalGeralFreteValor() {
    var max = parseInt($("maxConhecimento").value, 10);
    var totalFreteValor = 0;
    for (var i = 1; i <= max; i++) {
        if ($("valorFreteValor_" + i) != null && $("valorFreteValor_" + i) != undefined) {
            totalFreteValor += parseFloat(colocarPonto($("valorFreteValor_" + i).value));
        }
    }
    return totalFreteValor;
}
function getTotalICMS() {
    var max = parseInt($("maxConhecimento").value, 10);
    var totalICMS = 0;
    for (var i = 1; i <= max; i++) {
        if ($("valorIcms_" + i) != null && $("valorIcms_" + i) != undefined) {
            totalICMS += parseFloat(colocarPonto($("valorIcms_" + i).value));
        }
    }
    return totalICMS;
}
function getTotalQtdEntregas() {
    var max = parseInt($("maxConhecimento").value, 10);
    var qtdEntregas = 0;
    for (var i = 1; i <= max; i++) {
        if ($("qtdEntregasTabela_" + i) != null && $("qtdEntregasTabela_" + i) != undefined) {
            qtdEntregas += parseFloat(colocarPonto($("qtdEntregasTabela_" + i).value));
        }
    }
    return qtdEntregas;
}
function getObs(obs) {

    var aux = (obs != undefined && obs != null ? obs : "");

    aux = replaceAll(aux, "\r", "");
    aux = replaceAll(aux, "\n", "<br>");
    return replaceAll(aux, "<br>", "\r");
}
function validarCtrc(index) {
    try {
        if ($("idRemetente_" + index) != null && $("chkSave_" + index).checked) {
            var qtdNotas = parseInt($("qtdNotas_" + index).value, 10);
            if ($("idRemetente_" + index) != null && $("idRemetente_" + index).value == "0") {
                return showErro("Informe o \'Remetente\', na Aba \'Clientes\'. No " + index + "º Conhecimento", $("remetente_" + index));
            }
            if ($("idDestinatario_" + index) != null && $("idDestinatario_" + index).value == "0") {
                return showErro("Informe o \'Destinatario\', na Aba \'Clientes\'. No " + index + "º Conhecimento", $("destinatario_" + index));
            }
            if ($("idConsignatario_" + index) != null && $("idConsignatario_" + index).value == "0") {
                return showErro("Informe o \'Consignatario\', na Aba \'Clientes\'. No " + index + "º Conhecimento", $("consignatario_" + index));
            }
            if ($("cfopCtrcId_" + index) != null && $("cfopCtrcId_" + index).value == "0") {
                return showErro("Informe o \'CFOP', na Aba \'Clientes\'. No " + index + "º Conhecimento", $("cfopCtrc_" + index));
            }
            if ($("isRedespacho_" + index).checked) {
                //            if ($("redespachoCtrc_"+index) != null && $("redespachoCtrc_"+index).value == "") {
                //                return showErro("Informe o \'CTRC do Redespacho\', na Aba \'Clientes\'. No "+index+"º Conhecimento", $("redespachoCtrc_"+index));
                //            }
                //            if ($("redespachoValor_"+index) != null && ($("redespachoValor_"+index).value == "0,00" || $("redespachoValor_"+index).value == "")) {
                //                return showErro("Informe o \'Valor do Redespacho\', na Aba \'Clientes\'. No "+index+"º Conhecimento", $("redespachoValor_"+index));
                //            }    
            }
            //        alert(qtdNotas)
            //        for (i = 1; i <= qtdNotas; i++) {
            //            return validarNota(i, index);
            //        }
            if ($("tipoPagamentoC_" + index) != null && !$("tipoPagamentoC_" + index).checked
                    && $("tipoPagamentoF_" + index) != null && !$("tipoPagamentoF_" + index).checked
                    && $("tipoPagamentoT_" + index) != null && !$("tipoPagamentoT_" + index).checked) {
                return showErro("Informe o \'Responsavel pelo pagamento', na Aba \'Clientes'. No " + index + "º Conhecimento");
            }
            if ($("tipoFreteTabela_" + index) != null && $("tipoFreteTabela_" + index).value == "-1") {
                return showErro("Informe o \'Tipo do Frete', na Aba \'Composição Frete\'. No " + index + "º Conhecimento");
            }
            if ($("tipoFreteTabela_" + index).value == "1" && $("layout").value == "9" && $("layout").value == "59" && parseFloat(colocarPonto($("cubagemMetroTotalNF_" + index).value)) == parseFloat("0")) {
                return showErro("Informe o \'Metro Cubico\'!. No " + index + "º Conhecimento", $("cubagemMetroTotalNF_" + index), $("cubagemMetroTotalCF_" + index));
            }
            if ($("especie").value == "CTE" && $("previsaoEntrega_" + index).value.trim() == "") {
                return showErro("Informe a \'Previsão de Entrega\'!. No " + index + "º Conhecimento", $("previsaoEntrega_" + index));
            }
            if ($("totalPrestacao_" + index) != null && parseFloat(colocarPonto($("totalPrestacao_" + index).value)) == parseFloat("0")) {
                return showErro("Informe o \'Total da Prestação\'. No " + index + "º Conhecimento", $("totalPrestacao_" + index));
            }

            if (!$('isAddIcms_' + index).checked && sessionStorage.getItem('pode_desmarcar_embutir_iss_' + index) === 'false') {
                return showErro('Atenção: Você não pode desmarcar "ICMS/ISS", pois no cadastro do serviço está marcado para embutir o ISS. No ' + index + 'º Conhecimento', $('isAddIcms_' + index));
            }
        }
    } catch (e) {
        alert("Erro ao validar o CTRC!" + e);
    }


    return  true;
}
function validarNota(index, indexCtrc) {
//    if ($("notaExiste_"+indexCtrc+ "_"+index) != null && $("notaExiste_"+indexCtrc+ "_"+index).value == "true") {
//        return showErro("A nota de número \'"+$("notaNumero_"+indexCtrc+ "_"+index).value+"\'. No "+indexCtrc+"º Conhecimento, já existe no sistema!",$("notaExiste_"+indexCtrc+ "_"+index));
//    }
//    return true;
}
function validarCubagem(indexCtrc, indexNota, indexCub) {
    try {
        var numNota = $("notaNumero_" + indexCtrc + "_" + indexNota).value;
        if ($("tipoFreteTabela_" + indexCtrc).value == "1" && $("layout").value == "ricardoEletro" && parseFloat(colocarPonto($("cubMetro_" + indexCtrc + "_" + indexNota + "_" + indexCub).value)) == parseFloat("0")) {
            AlternarAbas('tdAbaNotaFiscal_' + indexCtrc);
            $('tdAbaNotaFiscal_' + indexCtrc).focus();
            return showErro("Informe o \'Metro Cubico\'!. No " + indexCtrc + "º Conhecimento, Nota:" + numNota, $("cubMetro_" + indexCtrc + "_" + indexNota + "_" + indexCub));
        }
    } catch (e) {
        alert("Erro ao validar as cubagens!" + e);
    }
    return true;
}
function localizarNota(numero) {
    for (var c = 1; c <= parseInt($("maxConhecimento").value, 10); c++) {
        if ($("tdAbaNotaFiscal_" + c) != null && $("tdAbaNotaFiscal_" + c) != undefined) {
            for (var n = 1; n <= parseInt($("qtdNotas_" + c).value, 10); n++) {
                if ($("notaNumero_" + c + "_" + n) != null && $("notaNumero_" + c + "_" + n) != undefined) {
                    if ($("notaNumero_" + c + "_" + n).value == numero) {
                        AlternarAbas("tdAbaNotaFiscal_" + c);
                        $("tdAbaNotaFiscal_" + c).focus();
                        $("notaNumero_" + c + "_" + n).focus();
                        showAddConhecimentoNotaAdicionais($("addShow_" + c + "_" + n));
                    }
                }
            }
        }
    }
}
function marcarCheck(valor, qtdMax) {
    //chkSave_
    for (var i = 1; i <= qtdMax; i++) {
        if ($("chkSave_" + i) != null && $("chkSave_" + i) != undefined) {
            $("chkSave_" + i).checked = valor;
        }
    }
}
/**
 * Retorna a quantidade de conhecimentos que foram liberados para serem salvos
 */
function getQtdCtrcAutorizados(qtdMax) {
    var qtd = 0;
    //chkSave_
    for (var i = 1; i <= qtdMax; i++) {
        if ($("chkSave_" + i) != null && $("chkSave_" + i) != undefined && $("chkSave_" + i).checked) {
            qtd++;
        }
    }
    return qtd;
}
function exibirErroCtrc(index) {
    alert(getErroCtrc(index));
}
function exibirErroAll(qtdMax) {
    //chkSave_
    var erros = "";
    for (var i = 1; i <= qtdMax; i++) {
        if ($("mensagemErro_" + i) != null && $("chkSave_" + i) != undefined) {
            erros += $("mensagemErro_" + index).innerHTML;
        }
    }
    if (erros != "") {
        //alert(erros);
    }
}
function getErroCtrc(index) {
    var erro = "";
    if ($("mensagemErro_" + index) != null) {
        erro = $("mensagemErro_" + index).innerHTML;
    }
    return erro;
}
function setErroCtrc(indexCtrc, msg) {
    $("erroAtual_" + indexCtrc).innerHTML = msg;
    $("mensagemErro_" + indexCtrc).innerHTML += msg;
    $("mensagemErro_" + indexCtrc).className = styleErro;
    $("erroAtual_" + indexCtrc).className = styleErro;
    $("alertaErro_" + indexCtrc).className = styleErro;
    $("alertaErro_" + indexCtrc).title = $("mensagemErro_" + indexCtrc).innerHTML;
    visivel($("alertaErro_" + indexCtrc));
}

function setMsgCliente(indexCtrc, msg) {
    $("avisoMsg_" + indexCtrc).innerHTML = "Aviso sobre o Consignatário do CT-e";
    $("mensagemCliente_" + indexCtrc).innerHTML = "Mensagem importante para emissão de CT-e do cliente :" + $("consignatario_" + indexCtrc) == null ? '' : $("consignatario_" + indexCtrc).value + " : " + msg;
    $("mensagemCliente_" + indexCtrc).className = styleMsgCli;
    $("avisoMsg_" + indexCtrc).className = styleMsgCli;
    $("alertaMsgCli_" + indexCtrc).className = styleMsgCli;
    $("alertaMsgCli_" + indexCtrc).title = $("mensagemCliente_" + indexCtrc).innerHTML;
    if (msg != "") {
        visivel($("alertaMsgCli_" + indexCtrc));
    }
}

function limparMsgCliente(indexCtrc) {
    invisivel($("alertaMsgCli_" + indexCtrc));
    $("avisoMsg_" + indexCtrc).innerHTML = "";
    $("mensagemCliente_" + indexCtrc).innerHTML = "";
}
function getMsgCliente(index) {
    var msg = "";
    if ($("mensagemCliente_" + index) != null) {
        msg = $("mensagemCliente_" + index).innerHTML;
    }
    return msg;
}
function getValorComissaoVendedor(tipo, modal, isFracionado, vlUnificado, vlAereo, vlRodFracionado, vlRodLotacao) {
    var retorno = 0;

    if (tipo == "1") {
        retorno = vlUnificado != null && vlUnificado != undefined ? vlUnificado : 0;
    } else {
        switch (modal) {
            case "r":
                retorno = (isFracionado ? vlRodFracionado : vlRodLotacao);
                break;
            case "a":
                retorno = vlAereo != null && vlAereo != undefined ? vlAereo : 0;
                break;
            case "q":
                retorno = vlUnificado != null && vlUnificado != undefined ? vlUnificado : 0;
                break;
        }
    }

    return retorno;
}
function definirComissaoVendedorLote(index) {
    $("vendedorComissaoOutros_" + index).value = getValorComissaoVendedor($("consignatarioUnificadaModalVendedor_" + index).value,
            $("tipoTransporte").value, $("modalCTe").value == "f", $("consignatarioVendedorComissao_" + index).value,
            $("consignatarioVendedorComissao_" + index).value, $("consignatarioPercComissaoRodoviarioFracionadoVendedor_" + index).value,
            $("consignatarioPercComissaoRodoviarioLotacaoVendedor_" + index).value);
}

function mostrarCamposComposicaoFreteLote(index) {
    var permissaoAlterarPreco = $("alteraprecocte").value;

    if ($("tipoFreteTabela_" + index).value == '3' && $("tabelaUtilizadaTabela_" + index).value == "") {
        habilitarCampos_alteraprecocte(index);
    } else if (permissaoAlterarPreco == "false") {
        desabilitarCampos_alteraprecocte(index);
    }
}

function limparComposicaoFreteLote(index) {
    $("tabelaUtilizadaTabela_" + index).value = "";
    $("valorTaxaFixa_" + index).value = "0.00";
    $("valorItr_" + index).value = "0.00";
    $("valorDespacho_" + index).value = "0.00";
    $("valorAdeme_" + index).value = "0.00";
    $("valorFretePeso_" + index).value = "0.00";
    $("valorFreteValor_" + index).value = "0.00";
    $("valorSecCat_" + index).value = "0.00";
    $("valorOutros_" + index).value = "0.00";
    $("valorGris_" + index).value = "0.00";
    $("valorPedagio_" + index).value = "0.00";
    $("valorTde_" + index).value = "0.00";
    $("valorDesconto_" + index).value = "0.00";
    $("totalPrestacao_" + index).value = "0.00";
    $("baseCalculoIcms_" + index).value = "0.00";
    $("valorIcms_" + index).value = "0.00";
    $("valorPisCofins_" + index).value = "0.00";
}

function addNotaDom(nota, indexCtrc, classe, serieDefault, isFocus, travaCamposImportacao) {
    var adicionarNotaColeta = $("chkAdicionarNotaColeta").checked;
    if (adicionarNotaColeta) {
        if ($("idcoleta").value == 0) {
            addConhecimentoLoteNotasFiscaisConteudo(nota, indexCtrc, classe, serieDefault, isFocus, travaCamposImportacao);
        } else {
            launchPopupLocate('./localiza?acao=consultar&fecharJanela=false&idlista=46&paramaux=' + $("idcoleta").value + '&paramaux2=' + notasAdicionadas(), 'Nota_Fiscal_' + indexCtrc);
        }
    } else {
        addConhecimentoLoteNotasFiscaisConteudo(nota, indexCtrc, classe, serieDefault, isFocus, travaCamposImportacao);
    }
}

//Pegar os ids das notas que já foram adicionado pela coleta, para não adicionar novamente.
function notasAdicionadas() {
    var ids = "0";
    var maxCte = $("maxConhecimento").value;
    var maxNota = 0;
    for (var qtdCte = 0; qtdCte <= maxCte; qtdCte++) {
        if ($("qtdNotas_" + qtdCte) != null) {
            maxNota = $("qtdNotas_" + qtdCte).value;
            for (var qtdNota = 0; qtdNota <= maxNota; qtdNota++) {
                if ($('notaId_' + qtdCte + "_" + qtdNota) != null) {
                    ids += "," + $('notaId_' + qtdCte + "_" + qtdNota).value;

                }
            }
        }
    }
    return ids;
}

function montagemDomChavesLote(index) {
    var allChaves = $("redespachoChaveAcessoAll_" + index).value;
    var quantidade = 0;
    for (var i = 0; i <= allChaves.split(",").length; i++) {
        if (allChaves.split(",")[i] != "") {
            addDomChavesAcessoLote(allChaves.split(",")[i], index);

        }
    }
    return quantidade;
}

var countChaves = 0;
function salvarChavesLote(index) {
    var max = $("redespachoChaveAcessoAll_" + index).value;
    max = max.split(",").length;
    var chavesAgrupadas = "";
    var contador = ($("redespachoChaveAcesso_" + index).value == "" ? 0 : 1);
    for (var i = 0; i < max; i++) {
        if ($("chaveAcessoExtra_" + index + "_" + i) != null && $("chaveAcessoExtra_" + index + "_" + i).value != "") {
            if (i == 0 && $('redespachoChaveAcesso_' + index).value.trim() == '') {
                $("redespachoChaveAcesso_" + index).value = $("chaveAcessoExtra_" + index + "_" + i).value;
            } else {

                chavesAgrupadas = chavesAgrupadas + $("chaveAcessoExtra_" + index + "_" + i).value + ",";
                contador++;
            }
        }
    }
    $("redespachoChaveAcessoAll_" + index).value = chavesAgrupadas;

    if (contador >= 2) {
        $("lblRedChaveAcessoQtd_" + index).innerHTML = " QTD Chaves : " + contador;
    }
}
function montarDivChaveAcessoLote(index) {
    countChaves = 0;
    //inserindo na layer os objetos da nota fiscal        
    var cmdHtml = "";
    //Criando a tabela
    cmdHtml =
    "<table width='100%' class='bordaFina'>"+
            "<tr> "
        +"<td class='tabela' align='center'> Chaves de Acesso de Redespacho"+" </td>"+
            "</tr>" +
            "<tr>"+
            "<td class='TextoCampos' id='chavesExtrasRed'>" +
            "<div id='divChaves' class='conteudo'> " +
            "<table class='bordaFina' width='100%'>" +
                            "<tr>"+
                                "<td class= 'CelulaZebra2'>"+
                                    "<img src='img/add.gif' class='imagemLink' title='Adicionar uma nova Chave de Acesso' onclick='addDomChavesAcessoLote(\"\","+index+")';>\n\
                                </td>"+
                                "<td class='CelulaZebra2'><label><b> Adicionar Chave de Acesso</b></label>"+
                                "</td>"+ 
                            "</tr>"+
                            "<tr> "+
                                "<td> "+
                                "</td>"+
                                "<td> "+
                                   "<div class= 'conteudo'  style='max-height: 250px; overflow: auto; height: 500px;'>"+
                                    "<fieldset>"+
                                    "<table id='tbChavesAcessoRed' name='tbChavesAcessoRed' width='100%' class='bordaFina'>"+
                                    "</table>"+
                                    "</fieldset>"+
                                        "</div>"+
                                "</td>"+
                            "</tr>"+
                        "</table>"+
                    "</div>"+
                "</td>"+
            "</tr>"
        +"</td>"
    +"</tr>"+
            "<tr class='CelulaZebra2' align='center'>" +
    "<td align='center'><input name='salvar_nf' type='button' class='botoes' id='salvar_chaves' value='SALVAR' style='text-align: left'>"+
    "<label>                             </label>"+
            "<input name='fechar_chave' type='button' class='botoes' id='fechar_chave' value='FECHAR' style='text-align: right'></td>" +
            "</tr>"
    +"</table> "         
            ;
    blockInterfaceLote(true);
    document.getElementById("promptRedChave").innerHTML = cmdHtml;
    document.getElementById("promptRedChave").style.display = "";
    countChaves = montagemDomChavesLote(index);
    $("lblRedChaveAcessoQtd_" + index).innerHTML = " QTD Chaves : " + countChaves;
    document.getElementById("salvar_chaves").onclick = function () {
        salvarChavesLote(index);
        document.getElementById("promptRedChave").style.display = 'none';
        blockInterfaceLote(false);
    }
    document.getElementById("fechar_chave").onclick = function () {
        document.getElementById("promptRedChave").style.display = 'none';
        blockInterfaceLote(false);
    }
}

function addDomChavesAcessoLote(chaveAcesso, indexCtrc) {
    var trVariasChaves = Builder.node("tr", {
        name: "trChaveExtra_" + indexCtrc + "_" + countChaves,
        id: "trChaveExtra_" + indexCtrc + "_" + countChaves
    });
    var tdVariasChaves = Builder.node("td", {
        name: "tdChaveExtra_" + indexCtrc + "_" + countChaves,
        id: "tdChaveExtra_" + indexCtrc + "_" + countChaves,
        class: "CelulaZebra2",
        colspan: "4",
    });
    var lblvariasChaves = Builder.node("label", {});
    var inpVariasChaves = Builder.node("input", {
        name: "chaveAcessoExtra_" + indexCtrc + "_" + countChaves,
        id: "chaveAcessoExtra_" + indexCtrc + "_" + countChaves,
        class: "inputtexto",
        type: "text",
        size: "44",
        maxlength: "44",
        value: (chaveAcesso != undefined ? chaveAcesso : "")
    });
    lblvariasChaves.innerHTML = " Chave : ";
    countChaves++;
    tdVariasChaves.appendChild(lblvariasChaves);
    tdVariasChaves.appendChild(inpVariasChaves);
    trVariasChaves.appendChild(tdVariasChaves);
    $("tbChavesAcessoRed").appendChild(trVariasChaves);

}
function blockInterfaceLote(fechaCortina)
{
    var $a = jQuery.noConflict();
    if (document.getElementById("cortina") == null)
    {
        var layer = document.createElement("DIV");
        layer.id = "cortina";
        document.body.appendChild(layer);
        var ob = document.getElementById("cortina");
        ob.style.position = "absolute";
        ob.style.width = "100%";
        ob.style.height = $a(document).height() + "px";
        ob.style.zIndex = 8;
        ob.style.backgroundColor = "#000000";
        ob.style.left = "0";
        ob.style.top = "0";
        ob.style.filter = "alpha(opacity=15)";
        ob.style.opacity = "0.2";
    }

    document.getElementById("cortina").style.display = (fechaCortina ? "" : "none");
}

function cidadeDestinoRecebedor(index) {
    if ($("cidadeDestinoLocais_" + index) != null && $("redespachoCidade_" + index) != null) {
        //altera a cidade de destino para a cidade do redespacho expedidor
        $("cidadeDestinoLocais_" + index).value = $("redespachoCidade_" + index).value;
        $("ufDestinoLocais_" + index).value = $("redespachoUF_" + index).value;
        $("cidadeDestinoIdLocais_" + index).value = $("redespachoCidadeId_" + index).value;

        //altera a cidade de origem para a cidade do redespacho Remetente
        $("cidadeOrigemLocais_" + index).value = $("remetenteCidade_" + index).value;
        $("ufOrigemLocais_" + index).value = $("remetenteUF_" + index).value;
        $("cidadeOrigemIdLocais_" + index).value = $("remetenteCidadeId_" + index).value;
    }
}

function cidadeOrigemExpedidor(index) {
    if ($("cidadeOrigemLocais_" + index) != null && $("redespachoCidade_" + index) != null) {
        //altera a cidade de origem para a cidade do redespacho expedidor
        $("cidadeOrigemLocais_" + index).value = $("redespachoCidade_" + index).value;
        $("ufOrigemLocais_" + index).value = $("redespachoUF_" + index).value;
        $("cidadeOrigemIdLocais_" + index).value = $("redespachoCidadeId_" + index).value;
        $("idcidadeorigem").value = $("cidadeOrigemIdLocais_" + index).value;
        //altera a cidade de destino para a cidade do redespacho destinatario
        $("cidadeDestinoLocais_" + index).value = $("destinatarioCidade_" + index).value;
        $("ufDestinoLocais_" + index).value = $("destinatarioUF_" + index).value;
        $("cidadeDestinoIdLocais_" + index).value = $("destinatarioCidadeId_" + index).value;

    }
}

//ao clicar no tipo de redespacho vai limpar o campo do expedidor e incluir o recebedor
function alteraExpedidorLote(index) {
    $("expedidor_" + index).value = "";
    $("idExpedidor_" + index).value = 0;

    $("recebedor_" + index).value = $("redespacho_" + index).value;
    $("idRecebedor_" + index).value = $("idRedespacho_" + index).value;
}

//ao clicar no tipo de redespacho vai limpar o campo do recebedor e incluir o expedidor
function alteraRecebedorLote(index) {
    $("recebedor_" + index).value = "";
    $("idRecebedor_" + index).value = 0;

    $("expedidor_" + index).value = $("redespacho_" + index).value;
    $("idExpedidor_" + index).value = $("idRedespacho_" + index).value;
}

function verificarNota(e) {
    jQuery('[key]').each(function () {
        if (e !== this && this.value === e.value && jQuery(this).parent().next().find("input").val() === jQuery(e).parent().next().find("input").val() && jQuery(e).attr("key") === jQuery(this).attr("key") && this.value !== '' && e.value !== '') {
            alert('A nota com o número : ' + e.value + ' já existe');
            return false;
        }
    });
}

function carregarPrevisaoEntrega(calcularPrazoEntregaTabelaPreco, index) {
    if ($("fontePreco").value == "a" && calcularPrazoEntregaTabelaPreco == "s") {
        jQuery.post('ConhecimentoControlador', {
            'acao': 'carregar_taxascli',
            'dtemissao': $("dataEmissaoCTe").value,
            'idconsignatario': $('idConsignatario_' + index).value,
            'con_tabela_remetente': ($("tipoPagamentoF_" + index).checked && ($("_isfreteDirigidoRemetente_" + index).value == "t" || $("_isfreteDirigidoRemetente_" + index).value == "true") ? "s" : $("consignatarioUtilizaTabelaRemetente_" + index).value),
            'tipoTransporte': $("tipoTransporte").value,
            'tipoveiculo': $("tipoVeiculoTabela_" + index).value,
            'tipoproduto': $("tipoProdutoTabela_" + index).value,
            'idcidadeorigem': $("cidadeOrigemIdLocais_" + index).value,
            'idcidadedestino': $("cidadeDestinoIdLocais_" + index).value,
            'peso': '0',
            'idremetente': $('idRemetente_' + index).value,
            'idTaxa': $("tipoFreteTabela_" + index).value,
            'idDestinatario': $("idDestinatario_" + index).value
        }, function (data) {
            if (data) {
                $('previsaoEntrega_' + index).value = data["previsao_entrega_calculada"];
            }
        }, 'json');
    }
}

function calcularTabelaMotorista() {
    var percentualValor = parseFloat($('percentual_valor_cte_calculo_cfe').value);
    if (percentualValor !== 0) {
        var vlFrete = 0;

        var tbValorFrete = 0; // Pelo total da prestação
        var tbValorPesoCte = 0; // Pelo frete peso
        var tbValorFreteCte = 0; // Pelo frete valor
        var tbvalorNotaFiscal = 0; //pela Nota Fiscal

        // Se a variável $("maxConhecimento") existir, significa que está na tela de importação CTRC em lote.
        // Se não, significa que está na tela de lançamento de CTRC normal.
        if ($("maxConhecimento") !== undefined && $("maxConhecimento") !== null) {
            for (var i = 1; i <= parseInt($("maxConhecimento").value); i++) {
                if ($('totalPrestacao_' + i)) {
                    tbValorFrete += parseFloat(colocarPonto($('totalPrestacao_' + i).value));
                    tbValorPesoCte += parseFloat(colocarPonto($('valorFretePeso_' + i).value));
                    tbValorFreteCte += parseFloat(colocarPonto($('valorFreteValor_' + i).value));
                    tbvalorNotaFiscal += parseFloat(colocarPonto($('valorMercadoriaTotalNF_' + i).value));
                }
            }
        } else {
            tbValorFrete = parseFloat($('total').value); // Pelo total da prestação
            tbValorPesoCte = parseFloat($("valor_peso").value); // Pelo frete peso
            tbValorFreteCte = parseFloat($("valor_frete").value); // Pelo frete valor
            tbvalorNotaFiscal = parseFloat($('vlmercadoria').value); // pela Nota Fiscal
        }

        var tipoCalculoPercentualValorCFe = $('tipo_calculo_percentual_valor_cfe').value;

        if ($('calculo_valor_contrato_frete').value === 'ct') {
            if (tipoCalculoPercentualValorCFe === 'tp') {
                // tp = pelo total da prestação
                vlFrete = tbValorFrete * (percentualValor / 100);
            } else if (tipoCalculoPercentualValorCFe === 'fp') {
                // fp = pelo frete peso
                vlFrete = tbValorPesoCte * (percentualValor / 100);
            } else if (tipoCalculoPercentualValorCFe === 'fv') {
                // fv = pelo frete valor
                vlFrete = tbValorFreteCte * (percentualValor / 100);
            }
        } else if ($('calculo_valor_contrato_frete').value === 'nf') {
            var valorDaNota = getValorNotas(percentualValor, parseFloat($('motorista_valor_minimo').value));
            vlFrete = valorDaNota;
        }

        if (vlFrete < parseFloat($('motorista_valor_minimo').value)) {
            vlFrete = parseFloat($('motorista_valor_minimo').value);
        }

        return vlFrete;
    }
}

function abrirLocalizarObservacaoFisco(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(28, "Observacao_Fisco", "");
}

function getObsClienteFisco(index, valor) {
    var obsFisco = valor != undefined ? valor : "";
    obsFisco = replaceAll(valor, "<br>", "");
    obsFisco = replaceAll(valor, "<br/>", "");
    obsFisco = replaceAll(valor, "<BR>", "");
    obsFisco = replaceAll(valor, "<BR/>", "");
    if (obsFisco != null && obsFisco != "") {
        $("observacaoFiscoOutros_" + index).value = valor;
    }
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

function carregarAbastecimentos() {
    jQuery.post(homePath + '/ContratoFreteControlador', {
        'acao': 'carregarAbastecimentos',
        'idveiculo': jQuery("#idveiculo").val()
    }, function (data) {
        var obj = JSON.parse(data);
        jQuery('#abastecimentos').val(parseFloat(obj['total_abastecimento']).toFixed(2));
        jQuery('#ids_abastecimentos').val(obj['abastecimentos_ids'].join(','));
    }
    );
}

function jsonTaxasConhecimentoLote() {

    var taxaFixa = 0;

    if ($("maxConhecimento") !== undefined && $("maxConhecimento") !== null) {
        for (var i = 1; i <= parseInt($("maxConhecimento").value); i++) {
            if ($("json_taxas_conhecimento_" + i).value != '') {

                var tabela = JSON.parse($("json_taxas_conhecimento_" + i).value);
                if (tabela) {
                    for (let j in tabela) {
                        if (tabela[j].tipo_veiculo == $('tipo_veiculo_motorista').value) {
                            taxaFixa += parseFloat(tabela[j].valor);
                        }
                    }
                }
            }
        }
    }

    return taxaFixa;
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
}

function isRetencaoImpostoOperadoraCFeLote() {
    let filial = ($('filial').value).split("@@")[0];
    let isRetencaoImpostoOperadoraCFe = ($("is_retencao_imposto_operadora_cfe_" + filial).value === "true" || $("is_retencao_imposto_operadora_cfe_" + filial).value === "t");
    return isRetencaoImpostoOperadoraCFe;
}

function limparImpostosLote() {
    $('cartaImpostos').value = '0,00';
    $("valorINSS").value = '0,00';
    $("valorSEST").value = '0,00';
    $("valorIR").value = '0,00';
}
function getTotAdiantamento() {
    try {
        var vlAdiantamento = 0;
        for (let i = 1; i <= countPgto; i++) {
            if ($("valorPgto_" + i) !== null && $("tipoPagto_" + i).value === "a") {
                vlAdiantamento += parseFloat(colocarPonto($("valorPgto_" + i).value));
            }
        }
        return vlAdiantamento;

    } catch (e) {
        console.error(e);
        console.log(e);
    }
}
function getTotSaldo() {
    try {
        var vlSaldo = 0;
        for (let i = 1; i <= countPgto; i++) {
            if ($("valorPgto_" + i) !== null && $("tipoPagto_" + i).value === "s") {
                vlSaldo += parseFloat(colocarPonto($("valorPgto_" + i).value));
            }
        }
        return vlSaldo;

    } catch (e) {
        console.error(e);
        console.log(e);
    }
}


function indexCtrcRemetenteDestinatarioEmissao(cnpjRem, cnpjDest, obMax, emissaoEm) {
    if (cnpjRem !== '' && cnpjDest !== '' && emissaoEm !== '') {
        for (var i = 1; i <= parseInt(obMax.value); i++) {
            var objRem = $("remetenteCNPJ_" + i);
            var objDest = $("destinatarioCNPJ_" + i);

            if (objRem !== undefined && objRem.value === cnpjRem && objDest !== undefined && objDest.value === cnpjDest
                    && jQuery('#tBodyNotaFiscal_' + i).find('input[name^="notaDataEmissao_"]').first().val() === emissaoEm) {
                return i;
            }
        }
    }

    return 0;
}


function obterIssNfseCtrc(index) {
    // Só irá obter o ISS do NFS-e caso a cidade de origem e destino forem iguais.
    var cidadeOrigemId = $('cidadeOrigemIdLocais_' + index).value;
    var cidadeDestinoId = $('cidadeDestinoIdLocais_' + index).value;

    if (cidadeOrigemId === cidadeDestinoId) {
        // Ajax para carregar o ISS do serviço do NFS-e da cidade.

        jQuery.get(homePath + '/NotaServicoControlador', {
            'acao': 'carregarAliquotaIssCtrcLote',
            'cidadeId': cidadeOrigemId
        }, function (data) {
            if (data && data['aliquota_iss']) {
                $('aliquotaIcms_' + index).value = colocarVirgula(data['aliquota_iss']);

                if (data['embutir_iss'] && !$('isAddIcms_' + index).checked) {
                    $('isAddIcms_' + index).click();

                    sessionStorage.setItem('pode_desmarcar_embutir_iss_' + index, 'false');
                }
            }
        }, 'json');
    }
}

function aoClicarIcmsIss(index) {
    var addIcmsCheck = $('isAddIcms_' + index);

    if (!addIcmsCheck.checked && sessionStorage.getItem('pode_desmarcar_embutir_iss_' + index) === 'false') {
        alert('Atenção: Você não pode desmarcar esta opção, pois no cadastro do serviço está marcado para embutir o ISS.');

        addIcmsCheck.checked = true;

        return false;
    }

    recalcular(index);
}

function getValorNotas(percentualValor, valorMinimo) {

    try {
        console.log(percentualValor);
        console.log(valorMinimo);

        let valorNota = 0;
        let valorRetorno = 0;
        let valor = 0;
        let tbvalorNotaFiscal = 0;
        let valorDaNotaPorCTE = 0;
        let rotaId = ($('rotaIdLocais_1') === null ? 0 : $('rotaIdLocais_1').value);
        let tipoProdutoTabela = ($("tipoProdutoTabela_1").value === "" || $("tipoProdutoTabela_1").value === "0" ? 0 : parseInt($("tipoProdutoTabela_1").value, 10));
        let consignatarioId = ($("idConsignatario_1").value === "" || $("idConsignatario_1").value === "0" ? 0 : parseInt($("idConsignatario_1").value, 10));
        let veiculoId = ($("idcarretaPrincipal").value === "" || $("idcarretaPrincipal").value === "0" ? 0 : parseInt($("idcarretaPrincipal").value, 10));

        if (veiculoId === 0) {
            veiculoId = ($("idveiculoPrincipal").value === "" || $("idveiculoPrincipal").value === "0" ? 0 : parseInt($("idveiculoPrincipal").value, 10));
        }

        if ($("maxConhecimento") !== undefined && $("maxConhecimento") !== null) {
            for (var i = 1; i <= parseInt($("maxConhecimento").value); i++) {
                if ($('totalPrestacao_' + i)) {
                    tbvalorNotaFiscal += parseFloat(colocarPonto($('valorMercadoriaTotalNF_' + i).value));
                }
            }
        }

        jQuery.ajax({
            url: 'ContratoFreteControlador',
            type: 'POST',
            async: false,
            data: {
                'acao': 'carregarTabelaRotaAjax',
                'rotaId': rotaId,
                'veiculoId': veiculoId,
                'tipoProdutoId': tipoProdutoTabela,
                'clienteId': consignatarioId,
            },
            success: function (data, textStatus, jqXHR) {
                if (data) {
                    data = JSON.parse(data);
                }
                if (data) {
                    valorRetorno = calcularValorEntrega(data,parseFloat(percentualValor), parseFloat(valorMinimo));
                }
            }
        });
        return valorRetorno;
    } catch (e) {
        console.log(e);
    }
}

function calcularValorEntrega(data, percentualMotorista, vlMinimoMotorista) {
    let vlContratoTotal = 0; // Valor total calculado para o contrato
    let tabela = data.tabRota; // Tabela da rota
    let maxCtrc = $("maxConhecimento").value; // Quantidade maxima de ct-es na tela
    let vlMercadoriaCTe = 0; //Valor da mercadoria do ct-e

    try {
        let calculo = (perc, min, vlMerc) => {
            let vlContrato = vlMerc * (perc / 100);
            if (vlContrato < min) { // Caso o valor calculado para o CT-e seja menor que o minimo, prevalesse o minimo
                vlContrato = min;
            }
            return vlContrato;
        }

        if (tabela) {
            //Se o percentual do motorista estiver preenchido, todo o calculo será baseado no motorista.
            let percentual = (percentualMotorista === 0 ? tabela.valor : percentualMotorista); // Percentual que será aplicado
            let vlMinimo = (percentualMotorista === 0 ? tabela.valorMinimo : vlMinimoMotorista); // Valor minimo que será aplicado.
            if (tabela.calcularPercentualNFePorEntrega) {
                for (var i = 1; i <= maxCtrc; i++) {
                    if ($('chkSave_' + i) !== null && $('chkSave_' + i).checked) {
                        vlMercadoriaCTe = pontoParseFloat($("valorMercadoriaTotalNF_" + i).value);
                        vlContratoTotal += calculo(percentual, vlMinimo, vlMercadoriaCTe);
                    }
                }
            } else {
                vlMercadoriaCTe = getValorTotalMercadorias();
                vlContratoTotal = calculo(percentual, vlMinimo, vlMercadoriaCTe);
            }
        }
    } catch (e) {
        console.log(e);
    }
    return vlContratoTotal;

}