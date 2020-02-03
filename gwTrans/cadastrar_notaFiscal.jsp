<%--
    Document   : cadastrar_notaFiscal
    Created on : 15/07/2013, 10:36:23
    Author     : Rogerio Brito
--%>

<%@page import="nucleo.Apoio"%>
<%@page import="nucleo.BeanLocaliza"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<link rel="stylesheet" href="estilo.css" type="text/css">

<script language="JavaScript" src="script/<%=Apoio.noCacheScript("builder.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("prototype_1_6.js")%>" type="text/javascript"></script>
<script language="JavaScript"  src="script/<%=Apoio.noCacheScript("funcoes_gweb.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/beans/<%=Apoio.noCacheScript("beans/nota_fiscal-util.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("mascaras.js")%>" type="text/javascript"></script>
<script language="javasscript" src="script/<%= Apoio.noCacheScript("LogAcoesAuditoria.js")%>" type="text/javascript"></script>
<script src="${homePath}/assets/js/jquery-1.9.1.min.js?v=${random.nextInt()}"></script>
<script type="text/javascript" laPnguage="JavaScript">
    //-------------------------------------------------------------------------- Início das Declarações de Variáveis Globais

    arAbasGenerico = new Array();
    arAbasGenerico[0] = new stAba('tdCubagem', 'divCubagem');
    arAbasGenerico[1] = new stAba('tdItens', 'divItens');
    arAbasGenerico[2] = new stAba('tdInfFiscais', 'divInfFiscais');
    arAbasGenerico[3] = new stAba('tdAgenEnt', 'divAgenEnt');
    arAbasGenerico[4] = new stAba('tdInfVeiculo', 'divInfVeiculo');
    arAbasGenerico[5] = new stAba('tdAuditoria', 'divAuditoria');
    var contCubagens = 0;
    var contItens = 0;
    jQuery.noConflict();
    //-------------------------------------------------------------------------- Fim das Declarações de Variáveis Globais

    //-------------------------------------------------------------------------- Função que carrega com a página
    function carregar() {
        try {
            var action = "${param.acao}";
            $("notaSerie").value = '${param.serie}';
            $("notaEmissao").value = '${param.dataAtual}';
            $("dataDeAuditoria").value = '${param.dataAtual}';
            $("dataAteAuditoria").value = '${param.dataAtual}';
            $("botaoPontoControle").style.display="none";

            if (action == 2) {//Se for Editar
                // 
                $("botaoPontoControle").style.display="";
                //Dados Principais
                $("idNota").value = "${notaFiscal.idnotafiscal}";
                $("notaNumero").value = "${notaFiscal.numero}";
                $("notaSerie").value = "${notaFiscal.serie}";
                $("notaEmissao").value = "${notaFiscal.emissaoStr}";
                $("notaValor").value = "${notaFiscal.valor}";
                $("notaPeso").value = "${notaFiscal.peso}";
                //dados do destinatario, e desabilitando os campos que possam alterar o destinatario.
                $("iddestinatario").value = "${notaFiscal.destinatario.idcliente}";
                $("dest_rzs").value = "${notaFiscal.destinatario.razaosocial}";
                $("des_codigo").value = "${notaFiscal.destinatario.idcliente}";
                $("des_codigo").readOnly = true
                $("dest_cnpj").value = "${notaFiscal.destinatario.cnpj}"
                $("dest_cnpj").readOnly = true

                //dados do remetente, e desabilitando os campos que possam alterar o remetente.
                $("idremetente").value = "${notaFiscal.remetente.idcliente}";
                $("rem_rzs").value = "${notaFiscal.remetente.razaosocial}";
                $("rem_codigo").value = "${notaFiscal.remetente.idcliente}";
                $("rem_codigo").readOnly = true
                $("rem_cnpj").value = "${notaFiscal.remetente.cnpj}"
                $("rem_cnpj").readOnly = true

                $("qtdPallet").value = "${notaFiscal.quantidadePallet}";

                var conhe = "${notaFiscal.conhecimento.id}";

                var coleta = "${notaFiscal.coleta.id}";

                $("notaEmbalagem").value = "${notaFiscal.embalagem}";
                $("notaConteudo").value = "${notaFiscal.conteudo}";
                $("numeroRomaneio").value = "${notaFiscal.numeroRomaneio}";
                $("notaColetaId").innerHTML = "${notaFiscal.coleta.id}";
                $("notaColetaNumero").innerHTML = "${notaFiscal.coleta.numero}";

                if (conhe != null || conhe != "" || coleta != null || coleta != "") {
                    $("localiza_rem").style.display = "none";
                    $("localiza_rem1").style.display = "none";
                    $("borracharem").style.display = "none";
                    $("borrachadest").style.display = "none";

                } else {

                    $("iddestinatario").style.display = "";
                    $("dest_rzs").style.display = "";
                    $("idremetente").style.display = "";
                    $("rem_rzs").style.display = "";
                    $("localiza_rem").style.display = "";
                    $("localiza_rem1").style.display = "";
                    $("borracharem").style.display = "";
                    $("borrachadest").style.display = "";

                }

                $("notaConhecimentoId").innerHTML = "${notaFiscal.conhecimento.id}";
                $("notaConhecimentoNumero").innerHTML = "${notaFiscal.conhecimento.numero}";
                $("nPedidoCliente").value = "${notaFiscal.pedido}";

                //Informações Fiscais
                $("notaBaseIcms").value = "${notaFiscal.vl_base_icms}";
                $("notaValorIcms").value = "${notaFiscal.vl_icms}";
                $("notaIcmsSt").value = "${notaFiscal.vl_icms_st}";
                $("notaIcmsFrete").value = "${notaFiscal.vl_icms_frete}";
                $("idcfop").value = "${notaFiscal.cfop.idcfop}";
                $("cfop").value = "${notaFiscal.cfop.cfop}";
                $("notaChaveAcessoNfe").value = "${notaFiscal.chaveNFe}";
                $("nfTipoDocumento").value = "${notaFiscal.tipoDocumento}";
                //Agendamento/Entrega
                $("ediSim").checked = ${notaFiscal.importadaEdi ? true : false};
                $("ediNao").checked = ${!notaFiscal.importadaEdi ? true : false};
                $("agendadaSim").checked = ${notaFiscal.agendado ? true : false};
                $("agendadaNao").checked = ${!notaFiscal.agendado ? true : false};
                $("notaDataAgendamento").value = "${notaFiscal.dataAgendaStr}";
                $("notaHoraAgendamento").value = "${notaFiscal.horaAgenda}";
                $("notaContato").value = "${notaFiscal.contato}";
                $("notaContatoFone").value = "${notaFiscal.contatoFone}";
                $("notaContatoFone").onblur();// Para inicializar já formatado o campo.
                $("notaObservacao").value = "${notaFiscal.observacaoAgenda}";
                $("notaAgendadoPor").value = "${notaFiscal.agendadoPor.nome}";
                $("notaAgendadoPorId").value = "${notaFiscal.agendadoPor.idusuario}";
                $("notaDataEntrega").value = "${notaFiscal.entregaEmStr}";
                var entregaAs = "${notaFiscal.entregaAs == null || notaFiscal.entregaAs == "null" ? "" : notaFiscal.entregaAs}";
                $("notaHoraEntrega").value = entregaAs.replace(":00", "");
                //Informações do Veículos
                $("descricao").value = "${notaFiscal.marcaVeiculo.descricao}";
                $("idmarca").value = "${notaFiscal.marcaVeiculo.idmarca}";
                $("notaVeiculoModelo").value = "${notaFiscal.modeloVeiculo}";
                $("notaVeiculoAno").value = "${notaFiscal.anoVeiculo}";
                $("notaVeiculoCor").value = "${notaFiscal.corVeiculo}";
                $("notaVeiculoChassi").value = "${notaFiscal.chassiVeiculo}";
                $("notaVolume").value = "${notaFiscal.volume}";

                //Cubagens
    <c:forEach var="cub" varStatus="status" items="${notaFiscal.cubagensNotaFiscal}">
                var cub = new Cubabem();
                cub.id = "${cub.id}";
                cub.volume = "${cub.volume}";
                cub.comprimento = "${cub.comprimento}";
                cub.altura = "${cub.altura}";
                cub.largura = "${cub.largura}";
                cub.etiqueta = "${cub.etiqueta}";
                addCubagemNota(cub);
//                    calcularCubagemNota();
                calcularTotalVolumeCubagem();
                calcularTotalMetroCubagem("${status.count}");
                calcularTotalGeralMetroCubagem();
    </c:forEach>
                //Itens da nota
    <c:forEach var="item" varStatus="status" items="${notaFiscal.itensNotaFiscal}">
                var item = new ItemNotaFiscal();
                item.idItem = "${item.id}";
                item.descricaoItem = "${item.descricao}";
                item.quantidadeItem = "${item.quantidade}";
                item.valorItem = "${item.valor}";
                item.idProduto = "${item.produto.id}";
                item.codigoProduto = "${item.produto.codigo}";
                item.descricaoProduto = "${item.produto.descricao}";
                item.idUnidade = "${item.produto.unidadeMedidaEstoque.id}";
                item.siglaUnidade = "${item.produto.unidadeMedidaEstoque.sigla}";
                item.descricaoUnidade = "${item.produto.unidadeMedidaEstoque.descricao}";
                addItemNotaFiscal(item);
//                    calcularTotalItensNota();
                calcularTotalQuantidadeItens();
                calcularTotalItens("${status.count}");
                calcularTotalGeralItens();
    </c:forEach>

            }
            
            if ('${notaFiscal.conhecimento.cliente.travaCamposImportacao}' === 'true' && '${notaFiscal.importadaEdi}' === 'true') {
                readOnly($("notaNumero"), 'inputReadOnly8pt');
                readOnly($("notaSerie"), 'inputReadOnly8pt');
                readOnly($("notaValor"), 'inputReadOnly8pt');
                readOnly($("notaPeso"), 'inputReadOnly8pt');
                readOnly($("notaVolume"), 'inputReadOnly8pt');
                readOnly($("des_codigo"), 'inputReadOnly8pt');
                readOnly($("dest_rzs"), 'inputReadOnly8pt');
                readOnly($("notaChaveAcessoNfe"), 'inputReadOnly8pt');
            }
        } catch (e) {
            alert(e);
        }

    }
    
    //-------------------------------------------------------------------------- Início do DOM de Cubagem 

    function aplicarReadOnly(classe) {
        function apply(ele) {
            ele.readOnly = true;
        }
        var elems = elementsByClassName(classe, 'input', arguments[1] || document);
        for (i = 0; i < elems.length; ++i) {
            apply(elems[i]);
        }
    }

    // Ajax para ser re-aproveitado.
    function removerItemNota(index) {
        var id = $("idItem_" + index).value;
        var descricao = $("descricaoItem_" + index).value;
        var qtdItem = $("quantidadeItem_" + index).value;
        var totalItem = $("totalItem_" + index).value;
        if (confirm("Deseja excluir " + descricao + "?")) {
            if (confirm("Tem certeza?")) {
                if (id != 0) {
                    new Ajax.Request("./NotaFiscalControlador?acao=excluirItemNota&idItemNota=" + id, {
                        method: 'get',
                        onSuccess: function () {
                            Element.remove($("trItens_" + index));
                            calcularTotalQuantidadeItens();
                            calcularTotalGeralItens();
                            alert('Item removido com sucesso!');
                        },
                        onFailure: function () {
                            alert('Erro ao excluir o Item...');
                            return false
                        }
                    });
                } else {
                    Element.remove($("trItens_" + index));
                    calcularTotalQuantidadeItens();
                    calcularTotalGeralItens();

                }
            }
        }
    }
    function removerCubagem(index) {
        var id = $("cubId_" + index).value;
        var descricao = $("cubVolume_" + index).value;
        var cudMetro = $("cubMetro_" + index).value;
        if (confirm("Deseja excluir " + descricao + "?")) {
            if (confirm("Tem certeza?")) {
                if (id != 0) {
                    new Ajax.Request("./NotaFiscalControlador?acao=excluirCubagem&idCubagem=" + id, {
                        method: 'get',
                        onSuccess: function () {
                            Element.remove($("trCubagem_" + index));
                            calcularTotalVolumeCubagem();
                            calcularTotalGeralMetroCubagem();
                            alert('Cubagem removido com sucesso!');
                        },
                        onFailure: function () {
                            alert('Erro ao excluir o Cubagem...');
                            return false
                        }
                    });
                } else {
                    Element.remove($("trCubagem_" + index));
                    calcularTotalVolumeCubagem();
                    calcularTotalGeralMetroCubagem();
                }
            }
        }
    }


    function addCubagemNota(cubagem, classeInput) {
//        var calCalcularCubagemNota = "calcularCubagemNota();";
        contCubagens++;
        var calCalcularTotalVolumeCubagem = "calcularTotalVolumeCubagem();";
        var calCalcularTotalMetroCubagem = "calcularTotalMetroCubagem('" + contCubagens + "');";
        var calCalcularTotalGeralMetroCubagem = "calcularTotalGeralMetroCubagem();";
        var callMascaraReais = "mascara(this, reais);";
        var seNaoFloatReset = "seNaoFloatResetNota(this,'0.00');";
        var maxLengtDefault = 15;
        var sizeInput = 15;
        if (classeInput == null || classeInput == undefined) {
            classeInput = "fieldMin numero";
        }
        if (cubagem == null || cubagem == undefined) {
            cubagem = new Cubabem();
        }
        var classe = (contCubagens % 2 != 0 ? 'CelulaZebra2NoAlign' : 'CelulaZebra1NoAlign');

        var _trCubagem = Builder.node("tr", {
            className: classe,
            align: "center",
            id: "trCubagem_" + contCubagens

        });
        var _td0 = Builder.node("td", {
            width: "2%",
            align: "center",
            id: "td0_" + contCubagens
        });

        var _tdVolume = Builder.node("td", {
            width: "10%",
            align: "center",
            id: "tdVolumeValor_" + contCubagens
        });

        <c:if test="${imprimirEtiquetas}">
            var _tdCheckboxImprimir = Builder.node("td", {
                width: "1%",
                align: "center",
                id: "tdCheckboxImprimir_" + contCubagens
            });
        </c:if>

        var _tdComprimento = Builder.node("td", {
            width: "10%",
            align: "center",
            id: "tdComprimentoValor_" + contCubagens
        });

        var _tdLargura = Builder.node("td", {
            width: "10%",
            align: "center",
            id: "tdLarguraValor_" + contCubagens
        });

        var _tdAltura = Builder.node("td", {
            width: "10%",
            align: "center",
            id: "tdAlturaValor_" + contCubagens
        });

        var _tdMetro = Builder.node("td", {
            width: "10%",
            align: "center",
            id: "tdMetroValor_" + contCubagens
        });
        
        var _tdEtiqueta = Builder.node("td", {
            width: "10%",
            align: "center",
            id: "tdEtiquetaValor_" + contCubagens
        });

        var _imgRemoverCubagem = Builder.node("img", {
            src: "img/lixo.png",
            id: "imgRemoverCubagem_" + contCubagens,
            className: "imagemLinkSpc",
            border: "0",
            width: "14px",
            onClick: "removerCubagem(" + contCubagens + ");"
        });

        var _inpVolume = Builder.node("input", {
            id: "cubVolume_" + contCubagens,
            name: "cubVolume_" + contCubagens,
            type: "text",
            className: classeInput,
            onKeyPress: callMascaraReais,
            size: sizeInput,
            maxlength: maxLengtDefault,
            onblur: seNaoFloatReset,
            onchange: seNaoFloatReset + "" + calCalcularTotalVolumeCubagem + "" + calCalcularTotalMetroCubagem,
            value: colocarVirgula(cubagem.volume)
        });

        var _cubId = Builder.node("input", {
            id: "cubId_" + contCubagens,
            name: "cubId_" + contCubagens,
            type: "hidden",
            value: cubagem.id
        });

        var _inpComprimento = Builder.node("input", {
            id: "cubComprimento_" + contCubagens,
            name: "cubComprimento_" + contCubagens,
            type: "text",
            className: classeInput,
            onKeyPress: callMascaraReais,
            size: sizeInput,
            onblur: seNaoFloatReset,
            onchange: seNaoFloatReset + "" + calCalcularTotalMetroCubagem,
            maxlength: maxLengtDefault,
            value: colocarVirgula(cubagem.comprimento)
        });

        var _inpAltura = Builder.node("input", {
            id: "cubAltura_" + contCubagens,
            name: "cubAltura_" + contCubagens,
            type: "text",
            className: classeInput,
            onblur: seNaoFloatReset,
            onchange: seNaoFloatReset + "" + calCalcularTotalMetroCubagem,
            onKeyPress: callMascaraReais,
            size: sizeInput,
            maxlength: maxLengtDefault,
            value: colocarVirgula(cubagem.altura)
        });

        var _inpLargura = Builder.node("input", {
            id: "cubLargura_" + contCubagens,
            name: "cubLargura_" + contCubagens,
            type: "text",
            className: classeInput,
            onKeyPress: callMascaraReais,
            size: sizeInput,
            onblur: seNaoFloatReset,
            onchange: seNaoFloatReset + "" + calCalcularTotalMetroCubagem,
            maxlength: maxLengtDefault,
            value: colocarVirgula(cubagem.largura)
        });

        var _inpMetro = Builder.node("input", {
            id: "cubMetro_" + contCubagens,
            name: "cubMetro_" + contCubagens,
            type: "text",
            className: "inputReadOnly8pt numero",
//            onKeyPress: calCalcularTotalGeralMetroCubagem+""+"mascara(this, reais, 4);",
            onKeyPress: "mascara(this, reais, 4);",
            size: sizeInput,
            onblur: seNaoFloatReset,
            onchange: seNaoFloatReset,
            maxlength: maxLengtDefault,
            readOnly: 'true',
            value: colocarVirgula(cubagem.metroCubico, 4)
        });
        
        
        var _inpEtiqueta = Builder.node("input", {
            id: "cubEtiqueta_" + contCubagens,
            name: "cubEtiqueta_" + contCubagens,
            type: "text",
            className: classeInput,
            size: "22",           
            value: cubagem.etiqueta
        });

        <c:if test="${imprimirEtiquetas}">
            var _inpCheckboxImprimir = Builder.node("input", {
                id: "ckImprimir_" + contCubagens,
                name: "ckImprimir_" + contCubagens,
                type: "checkbox",
                'data-id': cubagem.id
            });
        </c:if>
        
        
        if (classeInput == "fieldMin numero") {
            _td0.appendChild(_imgRemoverCubagem);
        }

        <c:if test="${imprimirEtiquetas}">
            _tdCheckboxImprimir.appendChild(_inpCheckboxImprimir);
        </c:if>
        _tdVolume.appendChild(_inpVolume);
        _tdVolume.appendChild(_cubId);
        _tdComprimento.appendChild(_inpComprimento);
        _tdLargura.appendChild(_inpLargura);
        _tdAltura.appendChild(_inpAltura);
        _tdMetro.appendChild(_inpMetro);
        _tdEtiqueta.appendChild(_inpEtiqueta);

        _trCubagem.appendChild(_td0);
        <c:if test="${imprimirEtiquetas}">
            _trCubagem.appendChild(_tdCheckboxImprimir);
        </c:if>
        _trCubagem.appendChild(_tdVolume);
        _trCubagem.appendChild(_tdComprimento);
        _trCubagem.appendChild(_tdAltura);
        _trCubagem.appendChild(_tdLargura);
        _trCubagem.appendChild(_tdMetro);
        _trCubagem.appendChild(_tdEtiqueta);

        $("tbodyCubagens").appendChild(_trCubagem);
        $("qtdCubagens").value = contCubagens;
        //calcularCubagemNota(_inpVolume);
    }

    //-------------------------------------------------------------------------- Fim do DOM de Cubagem 
    //-------------------------------------------------------------------------- Início do DOM de Itens
    //Classe para ser utilizada no dom de itens da nota fiscal.

    function ItemNotaFiscal(
            idItem, descricaoItem, quantidadeItem, valorItem,
            idProduto, codigoProduto, descricaoProduto,
            idUnidade, siglaUnidade, descricaoUnidade
            ) {
        this.idItem = (idItem != null && idItem != undefined) ? idItem : 0;
        this.descricaoItem = (descricaoItem != null && descricaoItem != undefined) ? descricaoItem : "";
        this.quantidadeItem = (quantidadeItem != null && quantidadeItem != undefined ? quantidadeItem : 0);
        this.valorItem = (valorItem != null && valorItem != undefined) ? valorItem : 0.00;
        this.idProduto = (idProduto != null && idProduto != undefined) ? idProduto : 0;
        this.codigoProduto = (codigoProduto != null && codigoProduto != undefined) ? codigoProduto : "";
        this.descricaoProduto = (descricaoProduto != null && descricaoProduto != undefined) ? descricaoProduto : "";
        this.idUnidade = (idUnidade != null && idUnidade != undefined) ? idUnidade : 0;
        this.siglaUnidade = (siglaUnidade != null && siglaUnidade != undefined) ? siglaUnidade : "";
        this.descricaoUnidade = (descricaoUnidade != null && descricaoUnidade != undefined) ? descricaoUnidade : "";

    }

    function aoClicarNoLocaliza(idJanela) {
        if (idJanela == 'undefined') {
            idJanela = $("janela").value;
        }
        var i = $("idx").value;
        try {
            if (idJanela == 'produto_item') {
                $("notaCodigoItem_" + i).value = $("codigo_produto").value;
                $("descricaoItem_" + i).value = $("descricao_produto").value;
                $("produtoId_" + i).value = $("produto_id").value;
                $("sigla_und_" + i).value = $("und_estoque").value;
                if ($("vl_unitario_item_nota").value != "") {
                    $("valorItem_" + i).value = colocarVirgula($("vl_unitario_item_nota").value);
                } else {
                    $("valorItem_" + i).value = '0.00';
                }
            }
        } catch (e) {
            alert(e);
        }
    }

    function addItemNotaFiscal(item, classeInput) {
        contItens++;
//        var calcularTotalIntensNota = "calcularTotalItensNota();";
        var callCalcularTotalQuantidadeItens = "calcularTotalQuantidadeItens();";
        var callCalcularTotalItens = "calcularTotalItens('" + contItens + "');";
        var callCalcularTotalGeralItens = "calcularTotalGeralItens();";
        var seNaoFloatReset = "seNaoFloatResetNota(this,'0.00');";
        var callMascaraReais = "mascara(this, reais);";
        var maxLengtDefault = 15;
        var sizeInput = 15;
        if (classeInput == null || classeInput == undefined) {
            classeInput = "fieldMin numero";
        }

        if (item == null || item == undefined) {
            item = new ItemNotaFiscal();
        }

        var classe = (contItens % 2 != 0 ? 'CelulaZebra2NoAlign' : 'CelulaZebra1NoAlign');

        var _trItem = Builder.node("tr", {
            className: classe,
            align: "center",
            id: "trItens_" + contItens

        });

        var _td0 = Builder.node("td", {
            width: "2%",
            align: "center",
            id: "tdItens0_" + contItens
        });

        var _tdCodigoItem = Builder.node("td", {
            width: "10%",
            align: "center",
            id: "tdCodigoItem_" + contItens
        });

        var _tdDescricaoItem = Builder.node("td", {
            width: "10%",
            align: "left",
            id: "tdDescricaoItem_" + contItens
        });

        var _tdUnidadeItem = Builder.node("td", {
            width: "10%",
            align: "center",
            id: "tdUnidadeItem_" + contItens
        });

        var _tdQuantidadeItem = Builder.node("td", {
            width: "10%",
            align: "center",
            id: "tdQuantidadeItem_" + contItens
        });

        var _tdValorItem = Builder.node("td", {
            width: "10%",
            align: "center",
            id: "tdValorItem_" + contItens
        });

        var _tdTotalItem = Builder.node("td", {
            width: "10%",
            align: "center",
            id: "tdTotalItem_" + contItens
        });

        var _imgRemoverItem = Builder.node("img", {
            src: "img/lixo.png",
            id: "imgRemoverItem_" + contItens,
            className: "imagemLinkSpc",
            border: "0",
            width: "14px",
            onClick: "removerItemNota(" + contItens + ");"
        });

        var _inpIdItem = Builder.node("input", {
            id: "idItem_" + contItens,
            name: "idItem_" + contItens,
            type: "hidden",
            value: item.idItem
        });

        var _inpIdProdutoItem = Builder.node("input", {
            id: "produtoId_" + contItens,
            name: "produtoId_" + contItens,
            type: "hidden",
            value: item.idProduto
        });

        var _inpIdUnidadeItem = Builder.node("input", {
            id: "idIUnidadetem_" + contItens,
            name: "idUnidadeItem_" + contItens,
            type: "hidden",
            value: item.idUnidade
        });

        var _inpCodigoProdutoItem = Builder.node("input", {
            id: "notaCodigoItem_" + contItens,
            name: "notaCodigoItem_" + contItens,
            type: "text",
            className: "inputReadOnly8pt",
            readonly: true,
            size: 10,
            maxlength: maxLengtDefault,
            value: item.codigoProduto
        });
        var _inpBotaoProduto = Builder.node("input", {
            id: "btnProduto_" + contItens,
            name: "btnProduto_" + contItens,
            type: 'button',
            value: '...',
            onclick: "localizaProduto(" + contItens + ")",
            className: 'botoes'
        });
        var _inpLimpar = Builder.node('IMG',
                {src: 'img/borracha.gif',
                    align: 'absbottom',
                    title: 'Apagar Item',
                    className: 'imagemLink',
                    onClick: "$('notaCodigoItem_" + contItens + "').value ='';\n\
                     $('descricaoItem_" + contItens + "').value ='';\n\
                     $('sigla_und_" + contItens + "').value ='';\n\
                     $('quantidadeItem_" + contItens + "').value ='0,00'; \n\
                     $('valorItem_" + contItens + "').value = '0,00';\n\
                     $('totalItem_" + contItens + "').value ='0,00';\n\
                     $('idIUnidadetem_" + contItens + "').value ='0';\n\
                     $('idItem_" + contItens + "').value ='0';\n\
                     $('produtoId_" + contItens + "').value ='0';"
                });
        var _inpDescricaoItem = Builder.node("input", {
            id: "descricaoItem_" + contItens,
            name: "descricaoItem_" + contItens,
            type: "text",
            className: classeInput.split(" ")[0],
            size: 50,
            maxlength: 80,
//            value: item.idProduto != 0 ? item.descricaoProduto : item.descricaoItem // estava exibindo a mesma descrição, independente se usuario alterasse. 
//            value: item.idProduto != 0 ? item.descricaoItem : item.descricaoProduto
            value: item.descricaoItem != "" ? item.descricaoItem : item.descricaoProduto
        });

        var _inpSiglaUnidadeItem = Builder.node("input", {
            id: "sigla_und_" + contItens,
            name: "sigla_und_" + contItens,
            type: "text",
            className: "inputReadOnly8pt",
            readonly: true,
            size: 10,
            maxlength: maxLengtDefault,
            value: item.siglaUnidade
        });

        var _inpQuantidadeItem = Builder.node("input", {
            id: "quantidadeItem_" + contItens,
            name: "quantidadeItem_" + contItens,
            type: "text",
            className: classeInput,
            onchange: seNaoFloatReset + "" + callCalcularTotalQuantidadeItens + "" + callCalcularTotalItens,
            onblur: seNaoFloatReset+";"+callMascaraReais,
            onKeyPress: callMascaraReais,
            size: 12,
            maxlength: maxLengtDefault,
            value: colocarVirgula(item.quantidadeItem)
        });

        var _inpValorItem = Builder.node("input", {
            id: "valorItem_" + contItens,
            name: "valorItem_" + contItens,
            type: "text",
            className: classeInput,
            onchange: seNaoFloatReset + "" + callCalcularTotalItens,
            onblur: seNaoFloatReset+";"+callMascaraReais,
            onKeyPress: callMascaraReais,
            size: sizeInput,
            maxlength: maxLengtDefault,
            value: colocarVirgula(item.valorItem)
        });

        var _inpTotalItem = Builder.node("input", {
            id: "totalItem_" + contItens,
            name: "totalItem_" + contItens,
            type: "text",
            className: classeInput,
            onchange: seNaoFloatReset+";"+callMascaraReais,
            onblur: seNaoFloatReset+";"+callMascaraReais,
//            onKeyPress: callCalcularTotalGeralItens+""+callMascaraReais,
            onKeyPress: callMascaraReais,
            size: sizeInput,
            maxlength: maxLengtDefault,
            readOnly: "true",
            value: "0.00"
        });

        if (classeInput == "fieldMin numero") {
            _td0.appendChild(_imgRemoverItem);
        }

        _tdCodigoItem.appendChild(_inpIdItem);
        _tdCodigoItem.appendChild(_inpIdProdutoItem);
        _tdCodigoItem.appendChild(_inpIdUnidadeItem);
        _tdCodigoItem.appendChild(_inpCodigoProdutoItem);
        _tdCodigoItem.appendChild(_inpBotaoProduto);
        _tdCodigoItem.appendChild(_inpLimpar);

        _tdDescricaoItem.appendChild(_inpDescricaoItem);
        _tdUnidadeItem.appendChild(_inpSiglaUnidadeItem);
        _tdQuantidadeItem.appendChild(_inpQuantidadeItem);
        _tdValorItem.appendChild(_inpValorItem);
        _tdTotalItem.appendChild(_inpTotalItem)

        _trItem.appendChild(_td0);
        _trItem.appendChild(_tdCodigoItem);
        _trItem.appendChild(_tdDescricaoItem);
        _trItem.appendChild(_tdUnidadeItem);
        _trItem.appendChild(_tdQuantidadeItem);
        _trItem.appendChild(_tdValorItem);
        _trItem.appendChild(_tdTotalItem);

        $("tbodyItens").appendChild(_trItem);
        $("qtdItens").value = contItens;

    }
    //-------------------------------------------------------------------------- Fim do DOM de Itens 
    //-------------------------------------------------------------------------- Início das Funções de Limpar
    function limparProduto(index) {
        $("idProduto" + index).value = 0;
        $("descricaoProduto" + index).value = "";
    }

    function limparDestinatario(index) {
        $("idDestinatario" + index).value = 0;
        $("descricaoDestinatario" + index).value = "";
    }
    //-------------------------------------------------------------------------- Fim das funções de Limpar

    function limparCliente() {
        document.formulario.cliente.value = "";
        document.formulario.idCliente.value = "0";
    }
    //-------------------------------------------------------------------------- Início das Funções de Localizar

    function localizaProduto(i, rotulo) {
        $("idx").value = i;
        $("janela").value = 'produto_item';
        rotulo = 'produto_item';
        launchPopupLocate('./localiza?acao=consultar&idlista=50&paramaux=cliente_id&paramaux2=pd.destinatario_id', rotulo);
        //aoClicarNoLocaliza('produto_item');
    }

    function localizaremetente() {
        window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=<%=BeanLocaliza.REMETENTE_DE_CONHECIMENTO%>', 'Remetente',
                'top=80,left=150,height=700,width=1400,resizable=yes,status=1,scrollbars=1');
    }

    function localizamarca(rotulo) {
        post_cad = window.open('./localiza?acao=consultar&idlista=0', rotulo,
                'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }

    //Parecido com a função da tela listar_cte.jsp
    function consultarNfeSefaz() {
        abrirMax('about:blank', 'popConsultaCompleta')
        $("ContentPlaceHolder1_txtChaveAcessoCompleta").value = $("notaChaveAcessoNfe").value;
        $("formConsulta").submit();
    }
    //-------------------------------------------------------------------------- Fim das Funções de Localizar

//    function calcularCubagemNota(){
//        var volume, comprimento,altura, largura,cubico,totalVolume = 0.00 ,totalCubico = 0.0000;
//
//        for(var i = 1; i <= contCubagens;i++){
//            if($("trCubagem_" + i) != null){
//                volume = parseFloat(colocarPonto($("cubVolume_" + i).value));
//                comprimento = parseFloat(colocarPonto($("cubComprimento_" + i).value));
//                altura =  parseFloat(colocarPonto($("cubAltura_" + i).value));
//                largura = parseFloat(colocarPonto($("cubLargura_" + i).value));
//                cubico = roundABNT((((volume*comprimento)*altura)*largura), 4);
//                totalVolume = roundABNT(totalVolume + volume, 2);
//                totalCubico = roundABNT( totalCubico + cubico, 4)
//                $("cubMetro_" +i).value =  colocarVirgula(cubico,4);
//            }
//            
//        }
//        $("totalVolumeCubagem").value =  colocarVirgula(totalVolume,2);
//        $("totalMetroCubagem").value =  colocarVirgula(totalCubico,4);
//    }
//    
//    function calcularTotalItensNota(){
//        var quantidade = 0.00, valor = 0.00, total= 0.00, totalQtd = 0.00 ,totalValor = 0.00;
//        
//        for(var i = 1; i <= contItens;i++){
//            if($("trItens_" + i) != null){
//                quantidade = parseFloat(colocarPonto($("quantidadeItem_" + i).value));
//                valor = parseFloat(colocarPonto($("valorItem_" + i).value));
//                total = roundABNT((valor*quantidade), 2);
//                totalQtd = roundABNT(totalQtd + quantidade, 2);
//                totalValor = roundABNT( totalValor + total, 2)
//                $("totalItem_" +i).value =  colocarVirgula(total,2);
//            }
//        }
//        $("totalQtdItem").value =  colocarVirgula(totalQtd,2);
//        $("totalGeralItem").value =  colocarVirgula(totalValor,2);
//    }

    var volume = 0, totalVolume = 0;
    function calcularTotalVolumeCubagem() {
        totalVolume = 0;
        for (var qtdCubagem = 1; qtdCubagem <= contCubagens; qtdCubagem++) {
            if ($("cubVolume_" + qtdCubagem) != null) {
                volume = parseFloat(virgulaToPonto($("cubVolume_" + qtdCubagem).value));
                totalVolume = roundABNT(totalVolume + volume, 2);
            }
        }
        $("totalVolumeCubagem").value = colocarVirgula(totalVolume, 2);
        calcularTotalGeralMetroCubagem();
    }

    //Esse método não precisa do for, vou calcular apenas a linha.
    var comprimento = 0, altura = 0, largura = 0, totalMetro = 0;
    function calcularTotalMetroCubagem(index) {
        totalMetro = 0;
        if ($("cubVolume_" + index) != null) {

            volume = parseFloat(virgulaToPonto($("cubVolume_" + index).value));
            comprimento = parseFloat(virgulaToPonto($("cubComprimento_" + index).value));
            altura = parseFloat(virgulaToPonto($("cubAltura_" + index).value));
            largura = parseFloat(virgulaToPonto($("cubLargura_" + index).value));

            if (volume != "0" && comprimento != "0" && altura != "0" && largura != "0") {
                totalMetro = roundABNT((((volume * comprimento) * altura) * largura), 4);
                $("cubMetro_" + index).value = colocarVirgula(totalMetro, 4);
            }
        }
        calcularTotalGeralMetroCubagem();
    }

    var cubico, totalGeralMetro = 0;
    function calcularTotalGeralMetroCubagem() {
        totalGeralMetro = 0;
        for (var qtdMetro = 1; qtdMetro <= contCubagens; qtdMetro++) {
            if ($("cubMetro_" + qtdMetro) != null) {
                cubico = parseFloat(colocarPonto($("cubMetro_" + qtdMetro).value));
                totalGeralMetro = roundABNT(totalGeralMetro + cubico, 4);
            }
        }
        $("totalMetroCubagem").value = colocarVirgula(totalGeralMetro, 4);
    }

    var quantidade = 0, totalQuantidade = 0;
    function calcularTotalQuantidadeItens() {
        totalQuantidade = 0;
        for (var qtdItens = 1; qtdItens <= contItens; qtdItens++) {
            if ($("quantidadeItem_" + qtdItens) != null) {
                quantidade = parseFloat(colocarPonto($("quantidadeItem_" + qtdItens).value));
                totalQuantidade = roundABNT(totalQuantidade + quantidade, 2);
            }
        }
        $("totalQtdItem").value = colocarVirgula(totalQuantidade, 2);
        calcularTotalGeralItens();
    }
    var totalItens;
    var valorUnitario = 0;
    function calcularTotalItens(index) {
        totalItens = 0;
        if ($("quantidadeItem_" + index) != null && $("valorItem_" + index) != null) {
            console.log($("valorItem_" + index).value);
            valorUnitario = parseFloat(colocarPonto($("valorItem_" + index).value));
            console.log(valorUnitario);
            quantidade = parseFloat(colocarPonto($("quantidadeItem_" + index).value));
            console.log($("quantidadeItem_" + index).value);
            console.log(quantidade);
//            totalItens = roundABNT((valor*quantidade), 2); 
            totalItens = quantidade * valorUnitario;
            console.log(totalItens);
            console.log(colocarVirgula(totalItens));
            $("totalItem_" + index).value = colocarVirgula(totalItens);
        }
        calcularTotalGeralItens();
    }

    var totalItens = 0, totalGeralItens = 0;
    function calcularTotalGeralItens() {
        totalGeralItens = 0;
        for (var qtdItens = 1; qtdItens <= contItens; qtdItens++) {
            if ($("totalItem_" + qtdItens) != null) {
                totalItens = parseFloat(colocarPonto($("totalItem_" + qtdItens).value));
                totalGeralItens = roundABNT(totalGeralItens + totalItens, 2);
            }
        }
        $("totalGeralItem").value = colocarVirgula(totalGeralItens, 2);
    }

    function voltar() {
        tryRequestToServer(function () {
            (window.location = "./NotaFiscalControlador?acao=listar")
        });
    }

    function fecharTela() {
        window.close();
    }

    function salvar() {
        var numero = $("notaNumero").value;
        var serie = $("notaSerie").value;
        var emissao = $("notaEmissao").value;
        var remetente = $("rem_rzs").value;
        var destinatario = $("dest_rzs").value;

        if (numero == "") {
            alert("O campo número não pode ficar em branco ");
            numero.focus();
            return false;
        }
        if (serie == "") {
            alert("O campo serie não pode ficar em branco ");
            serie.focus();
            return false;
        }
        if (emissao == "") {
            alert("O campo Data de Emissão não pode ficar em branco ");
            emissao.focus();
            return false;
        }

        if (remetente == "") {
            alert("O Remetente não pode ficar em branco ");
            remetente.focus();
            return false;
        }
        if (destinatario == "" && $("idacao").value == "1") {
            alert("O Destinatario não pode ficar em branco ");
            destinatario.focus();
            return false;
        }

//        if (destinatario == "" && $("idacao").value == "2" && $("iddestinatario").value == "0") {
//            alert("Não pode alterar uma nota sem o Destinatario ");
//            destinatario.focus();
//            return false;
//        }


        setEnv("botSalvar");
        window.open('about:blank', 'pop', 'width=210, height=100');
        $("formulario").submit();
        return true;

    }


    function localizaDestinatarioCodigo(campo, valor) {

        //objeto funcao usado na requisicao Ajax(uma espécie de evento)
        function e(transport) {
            var resp = transport.responseText;
            espereEnviar("", false);
            //se deu algum erro na requisicao...
            if (resp == 'null') {
                alert('Erro ao localizar cliente.');
                return false;
            } else if (resp == 'INA') {
                alert('Cliente inativo.');
                return false;
            } else if (resp == '') {
                if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")) {
                    window.open('./cadcliente?acao=iniciar', 'Cliente', 'top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                }
                return false;
            } else {
                var cliControl = eval('(' + resp + ')');

                $('iddestinatario').value = cliControl.idcliente;
                $('des_codigo').value = cliControl.idcliente;
                $('dest_rzs').value = cliControl.razao;
                $('dest_cnpj').value = cliControl.cnpj;

            }
        }//funcao e()

        if (valor != '') {
            espereEnviar("", true);
            tryRequestToServer(function () {
                new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor=" + valor + "&idfilial=0&campo=" + campo, {method: 'post', onSuccess: e, onError: e});
            });
        }
    }


    function localizaRemetenteCodigo(campo, valor) {

        //objeto funcao usado na requisicao Ajax(uma espécie de evento)
        function e(transport) {
            var resp = transport.responseText;
            espereEnviar("", false);
            //se deu algum erro na requisicao...
            if (resp == 'null') {
                alert('Erro ao localizar cliente.');
                return false;
            } else if (resp == 'INA') {
                alert('Cliente inativo.');
                return false;
            } else if (resp == '') {
                if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")) {
                    window.open('./cadcliente?acao=iniciar', 'Cliente', 'top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                }
                return false;
            } else {
                var cliControl = eval('(' + resp + ')');
                $('idremetente').value = cliControl.idcliente;
                $('rem_codigo').value = cliControl.idcliente;
                $('rem_rzs').value = cliControl.razao;
                $('rem_cnpj').value = cliControl.cnpj;
                if (campo == 'c.razaosocial') {
                    getObj('dest_rzs_cl').focus();
                }
            }
        }//funcao e()

        if (valor != '') {
            espereEnviar("", true);
            tryRequestToServer(function () {
                new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor=" + valor + "&idfilial=0&campo=" + campo, {method: 'post', onSuccess: e, onError: e});
            });
        }
    }

    function pesquisarAuditoria() {
        if (countLog != null && countLog != undefined) {
            for (var i = 1; i <= countLog; i++) {
                if ($("tr1Log" + i) != null) {
                    Element.remove($("tr1Log" + i));
                }
                if ($("tr2Log" + i) != null) {
                    Element.remove($("tr2Log" + i));
                }
            }
        }
        countLog = 0;
        var rotina = "nota_fiscal";
        var dataDe = $("dataDeAuditoria").value;
        var dataAte = $("dataAteAuditoria").value;
        var id = $("idNota").value;
        consultarLog(rotina, id, dataDe, dataAte);
    }


    
    function verPontosControle(){
        numeroNFe = $("notaNumero").value;
        var data = "<%=Apoio.getDataAtual()%>";
        window.open('./PontoControleControlador?acao=visualizarPontoControle&numeroNFe='+numeroNFe+'&tipoPesquisa=nfe&dataDe='+data+'&dataAte='+data, 'pontoControle' , 'top=0,resizable=yes,status=1,scrollbars=1');
    }
    
    function seNaoFloatResetNota(obj_input, valor_reset) {
        var zerosEsquerda = (arguments[2] != null ? arguments[2] : true);
        var fixed = (arguments[3] != null ? arguments[3] : 2);
        obj_input.value = colocarPonto(obj_input.value.trim());
        var vlr = ((obj_input.value.trim() == "" ? "0" : obj_input.value.trim()));
        obj_input.value = colocarVirgula(isNaN(vlr) || parseFloat(vlr) == 0 ?
                valor_reset : (vlr.indexOf('.') < 0 ? vlr + (zerosEsquerda ? ',00' : '') : vlr), fixed);
    }

    <c:if test="${imprimirEtiquetas}">
        jQuery(document).ready(function () {
            jQuery('#marcarTodasCubagensImprimir').on('click', function () {
                var marcado = jQuery(this).is(":checked");

                jQuery('input[id^=ckImprimir_]').prop('checked', marcado);
            });

            jQuery('#imprimirEtiquetaCubagem').on('click', function () {
                var cubagens = jQuery('[id^=ckImprimir_]:checked').map(function () {
                    return jQuery(this).attr('data-id')
                }).get().join();

                if (cubagens !== undefined && cubagens !== '') {
                    document.location.href = '${homePath}/matricidectrc.ctrc?is_cubagem_nf=true&idmovs=' + cubagens + '&driverImpressora=' + encodeURI(jQuery('#driverImpressora').val()) + '&caminho_impressora=' + encodeURI(jQuery('#caminhoImpressora').val());
                }
            });
        });
    </c:if>
</script>

<style type="text/css">

    .style3 {color: #333333}
    .style4 {
        font-size: 14px;
        font-weight: bold;
    }
    .numero {
        text-align: right;
    }

</style>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>Webtrans - Lançamento de Nota Fiscal</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>
    <body onload="carregar();
            AlternarAbasGenerico('tdCubagem', 'divCubagem');">
        <img src="img/banner.gif" align="middle">
        <table class="bordaFina" width="90%" align="center">
            <tr>
                <td width="90%" align="left"> 
                    <span class="style4">Cadastro de Nota Fiscal</span>
                </td>

                <td id="botaoPontoControle">
                    <input type="button" class="botoes" value="Pontos de Controle" onclick="javascript: verPontosControle()" >
                </td>
                
                <td>
                    <input id="botVoltar" type="button" value="Voltar" class="inputBotao" onclick="voltar()"/>

                </td>
            </tr>
        </table>
        <br>
        <form action="NotaFiscalControlador?acao=${param.nivelNotaFiscal > 2 && param.acao != 2 ? "cadastrar" : param.nivelNotaFiscal > 2 || param.nivelConhecimento > 2 && param.acao == 2 ? "editar" : ""}" id="formulario" name="formulario" method="post" target="pop" >
            <input type="hidden" id="idNota" name="idNota" value="${param.notaFiscal.idNota}">
            <input type="hidden" id="idacao" name="idacao" value="${param.acao}">
            <input type="hidden" id="descricao_produto" name="descricao_produto" >
            <input type="hidden" id="codigo_produto" name="codigo_produto" >
            <input type="hidden" id="produto_id" name="produto_id" >
            <input type="hidden" id="und_estoque"  name="und_estoque" >
            <input type="hidden" id="vl_unitario_item_nota" name="vl_unitario_item_nota" >
            <input type="hidden" id="idx" name="idx" value="0">
            <input type="hidden" id="janela" name="janela" value="0">
            <input type="hidden" id="coleta" name="coleta" value="${notaFiscal.coleta.id}">
            <input type="hidden" id="conhecimento" name="conhecimento" value="${notaFiscal.conhecimento.id}">






            <table width="90%" class="bordaFina" align="center"><!-------------- Início dos Dados Principais da Nota Fiscal -->
                <tr><!---------------------------------------------------------- Linha Título -->
                    <td colspan="20" class="tabela" align="center">Dados Principais</td>

                </tr>
                <tr width="90%">
                    <td class="textoCampos" width="8%" >Número:</td>
                    <td class="CelulaZebra2" width="10%" >
                        <input id="notaNumero" name="notaNumero" class="fieldMin"  type="text"  size="10" value="" >
                    </td>

                    <td class="textoCampos" width="8%">Série:</td>
                    <td class="CelulaZebra2" width="8%">
                        <input id="notaSerie" name="nota_serie" class="fieldMin"  type="text" value="" size="3" maxlength="3" >
                    </td>

                    <td class="textoCampos" width="8%">Emissão:</td>
                    <td class="CelulaZebra2" width="10%">
                        <input id="notaEmissao" name="notaEmissao" class="fieldMin" type="text" maxlength="10" size="10" onchange="javascript:alertInvalidDate(this);"  value=""  onkeypress="fmtDate(this, event)" onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)">
                    </td>

                    <td class="textoCampos" width="8%">Valor:</td>
                    <td class="CelulaZebra2" width="8%">
                        <input id="notaValor" name="notaValor" class="fieldMin" type="text" onchange="seNaoFloatResetNota(this, '0.00')" value="0.00" size="10" maxlength="11" >
                    </td>

                    <td class="textoCampos" width="8%">Peso:</td>
                    <td class="CelulaZebra2" width="8%">
                        <input id="notaPeso" name="notaPeso" class="fieldMin" type="text" onchange="seNaoFloatResetNota(this, '0.00')" value="0.00" size="10" maxlength="10">
                    </td>

                    <td class="textoCampos" width="8%">Volume:</td>
                    <td class="CelulaZebra2" width="8%">
                        <input id="notaVolume" name="notaVolume" class="fieldMin" type="text" onchange="seNaoFloatResetNota(this, '0.00')" value="0.00" size="10" maxlength="10">
                    </td>
                </tr>

                <tr>
                    <td class="textoCampos">Embalagem:</td>
                    <td class="CelulaZebra2" colspan="3">
                        <input id="notaEmbalagem" name="notaEmbalagem" class="fieldMin" type="text"  size="13" value="" maxlength="20">
                    </td>

                    <td class="textoCampos">Conteúdo:</td>
                    <td class="CelulaZebra2" colspan="1">
                        <input id="notaConteudo" name="notaConteudo" class="fieldMin" type="text"  size="30" value="" maxlength="30">
                    </td>
                    <td class="textoCampos">Nº Romaneio:</td>
                    <td class="CelulaZebra2" colspan="1">
                        <input id="numeroRomaneio" name="numeroRomaneio" class="fieldMin" type="text"  size="15" value="" maxlength="30">
                    </td>
                    <td class="textoCampos">Nº Pedido:</td>
                    <td class="CelulaZebra2">
                        <input type="text" id="nPedidoCliente" class="fieldMin" name="nPedidoCliente" size="12" value="" maxlength="15" onkeypress="mascara(this, soNumeros)">
                    </td>
                    <td class="textoCampos">Qtd. Pallet:</td>
                    <td class="CelulaZebra2">
                        <input type="text" id="qtdPallet" class="fieldMin" name="qtdPallet" size="10" value="" maxlength="8" onkeydown="mascara(this, soNumeros)">
                    </td>
                </tr>
                <tr>
                    <td class="textoCampos" >
                        Nº Coleta:</td>
                    <td class="CelulaZebra2">
                        <input id="notaColetaId" name="notaColetaId" name="notaRemetenteId" class="inputReadOnly8pt" type="hidden"   value="0" >
                        <label id="notaColetaNumero" name="notaColetaNumero" > </label>
                    </td>

                    <td class="textoCampos">Nº CT:</td>
                    <td class="CelulaZebra2" colspan="2">
                        <input id="notaConhecimentoId" name="notaConhecimentoId"  class="inputReadOnly8pt" type="hidden"   value="0" >
                        <label id="notaConhecimentoNumero" name="notaConhecimentoNumero" > </label>
                    </td>
                    <td class="CelulaZebra2" colspan="7">
                    </td>

                </tr>

                <tr>
                    <!-- esses 3 campos abaixo sao para a pesquisa por CNPJ  e COD -->
                    <td class="textoCampos">Remetente:</td>
                    <td class="celulaZebra2" colspan="5">
                        <input name="rem_codigo" type="text" id="rem_codigo" size="3" value="" onKeyUp="javascript:if (event.keyCode == 13)
                                    localizaRemetenteCodigo('idcliente', this.value)" class="fieldMin">
                        <input name="rem_cnpj" type="text" class="inputReadOnly8pt" id="rem_cnpj" maxlength="18" size="18" value="" onKeyUp="javascript:if (event.keyCode == 13)
                                    localizaRemetenteCodigo('cnpj', this.value)">

                        <input id="idremetente" name="idremetente"  type="hidden"   value="0" >
                        <input name="rem_rzs" type="text" id="rem_rzs" size="39" value="" onKeyUp="javascript:if (event.keyCode == 13)
                                    localizaRemetenteCodigo('c.razaosocial', this.value)" class="inputReadOnly8pt">
                        <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:localizaremetente();">
                        <img src="img/borracha.gif" border="0" id="borracharem" name="borracharem" align="absbottom" class="imagemLink" onClick="javascript:getObj('idremetente').value = '0';
                                getObj('rem_rzs').value = '';
                                getObj('rem_cnpj').value = '';
                                getObj('rem_codigo').value = '';">
                    </td>

                    <td class="textoCampos">Destinatário: </td>
                    <td class="celulaZebra2" colspan="5">        
                        <input name="des_codigo" type="text" id="des_codigo" size="3" value="" onKeyUp="javascript:if (event.keyCode == 13)
                                    localizaDestinatarioCodigo('idcliente', this.value)" class="fieldMin">
                        <input name="dest_cnpj" type="text" class="inputReadOnly8pt" id="dest_cnpj" maxlength="18" size="18" value="" onKeyUp="javascript:if (event.keyCode == 13)
                                    localizaDestinatarioCodigo('cnpj', this.value)">

                        <input name="iddestinatario" type="hidden" id="iddestinatario" value="">
                        <input name="dest_rzs" type="text" id="dest_rzs" value="" size="33"  onKeyUp="javascript:if (event.keyCode == 13)
                                    localizaDestinatarioCodigo('c.razaosocial', this.value)" class="inputReadOnly8pt">
                        <input name="localiza_rem1" type="button" class="botoes" id="localiza_rem1" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.DESTINATARIO_DE_CONHECIMENTO%>', 'Destinatario');">
                        <img src="img/borracha.gif" border="0" id="borrachadest" name="borrachadest" align="absbottom" class="imagemLink" onClick="javascript:getObj('iddestinatario').value = '0';
                                getObj('dest_rzs').value = '';
                                getObj('dest_cnpj').value = '';
                                getObj('des_codigo').value = '';">
                    </td>

                </tr>
            </table>
            <table align="center" width="90%" class="bordaFina"><!------------------------------- Início das Abas -->
                <tr>
                    <td width="100%" class="celulaZebra2">
                        <table align="left">
                            <tr>
                                <td id="tdCubagem" class="menu-sel" onclick="AlternarAbasGenerico('tdCubagem', 'divCubagem');"> Cubagens </td>
                                <td id="tdItens" class="menu" onclick="AlternarAbasGenerico('tdItens', 'divItens');"> Itens</td>
                                <td id="tdInfFiscais" class="menu" onclick="AlternarAbasGenerico('tdInfFiscais', 'divInfFiscais');"> Inf. Fiscais</td>
                                <td id="tdAgenEnt" class="menu" onclick="AlternarAbasGenerico('tdAgenEnt', 'divAgenEnt');">Agendamento/Entrega</td>
                                <td id="tdInfVeiculo" class="menu" onclick="AlternarAbasGenerico('tdInfVeiculo', 'divInfVeiculo');"> Inf. Veiculo Transportado</td>
                                <td id="tdAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAuditoria', 'divAuditoria');"> Auditoria </td>

                            </tr>
                        </table>
                    </td> 
                </tr>
                <tr>
                    <td width="100%">
                        <div id="divCubagem" > <!-------------------------------------------- Início da Div das Cubagens -->
                            <table align="center" width="100%" class="bordaFina">
                                <input id="qtdCubagens" name="qtdCubagens" type="hidden" value="0" />
                                <tr class="tabela" style="font-size: 10">
                                    <td align="left" width="1%">
                                        <img width="14px" src="img/add.gif" title="Adicionar Cubagem." id="imgAddCubagem" onclick="addCubagemNota()" class="imagemLinkSpc" />
                                    </td>
                                    <c:if test="${imprimirEtiquetas}">
                                        <td align="left" width="1%">
                                            <input type="checkbox" id="marcarTodasCubagensImprimir" name="marcarTodasCubagensImprimir">
                                        </td>
                                    </c:if>
                                    <td align="center" width="15%">Volume</td>
                                    <td align="center" width="15%">Comprimento</td>
                                    <td align="center" width="15%">Altura</td>
                                    <td align="center" width="15%">Largura</td>
                                    <td align="center" width="15%">M³</td>
                                    <td align="center" width="15%">Etiqueta</td>
                                </tr>
                                <tbody id="tbodyCubagens" ></tbody>
                                <tr></tr>
                                <tr class="tabela" style="font-size: 10"  >
                                    <td align="left" width="1%"></td>
                                    <c:if test="${imprimirEtiquetas}">
                                        <td align="left" width="1%"></td>
                                    </c:if>
                                    <td align="center" width="20%">
                                        <input id="totalVolumeCubagem" name="totalVolumeCubagem" class="inputReadOnly8pt numero" readonly type="text" value="0,00" maxlength="15" size="15"  >
                                    </td>
                                    <td align="right" width="20%" colspan="3"><b>Total M³:</b></td>

                                    <td align="center" width="19%">
                                        <input id="totalMetroCubagem" name="totalMetroCubagem"  class="inputReadOnly8pt numero" readonly  type="text" value="0,0000" maxlength="15" size="15"  >
                                    </td>
                                    <td align="center" width="19%">
                                        
                                    </td>
                                </tr>
                            </table>
                        </div><!------------------------------------------------------------ Fim da Div das Cubagens -->
                        <div id="divItens"> <!---------------------------------------------- Início da Div dos Itens -->
                            <table align="center" width="100%" class="bordaFina">
                                <input id="qtdItens" name="qtdItens" type="hidden" value="0" />
                                <tr class="tabela" style="font-size: 10">
                                    <td align="left" width="1%">
                                        <img width="14px" src="img/add.gif" title="Adicionar Item." id="imgAddItem" onclick="javascript:addItemNotaFiscal()" class="imagemLinkSpc" />
                                    </td>
                                    <td align="center" width="15%">Código</td>
                                    <td align="center" width="40%">Descrição</td>
                                    <td align="center" width="9%">Unidade</td>
                                    <td align="center" width="5%">Quanitdade</td>
                                    <td align="center" width="15%">Unitário</td>
                                    <td align="center" width="15%">Total</td>
                                </tr>
                                <tbody id="tbodyItens" ></tbody>
                                <tr></tr>

                                <tr class="tabela"  >
                                    <td colspan="4" align="right"><b>Total dos Itens:</b></td>
                                    <td align="center" width="20%">
                                        <input id="totalQtdItem" name="totalQtdItem" class="inputReadOnly8pt numero" readonly type="text" value="0,00" maxlength="15" size="12"  >
                                    </td>

                                    <td width="15%"></td>

                                    <td align="center" width="19%">
                                        <input id="totalGeralItem" name="totalGeralItem"  class="inputReadOnly8pt numero" readonly type="text" value="0,00" maxlength="15" size="15"  >
                                    </td>
                                </tr>
                            </table>
                        </div><!------------------------------------------------------------ Fim da Div dos Itens -->
                        <div id="divInfFiscais"> <!----------------------------------------- Início da Div das Informações Fiscais -->
                            <table width="100%" class="bordaFina" align="center">

                                <tr>
                                    <td class="textoCampos" width="9%" >Base ICMS:</td>
                                    <td class="CelulaZebra2" width="9%" >
                                        <input id="notaBaseIcms" name="notaBaseIcms" class="fieldMin"  type="text"  size="10" onchange="seNaoFloatResetNota(this, '0.00')" value="00.00" maxlength="11" >
                                    </td>

                                    <td class="textoCampos" width="9%">Valor ICMS:</td>
                                    <td class="CelulaZebra2" width="9%">
                                        <input id="notaValorIcms" name="notaValorIcms" class="fieldMin"  type="text" onchange="seNaoFloatResetNota(this, '0.00')" value="00.00" size="10" maxlength="11" >
                                    </td>

                                    <td class="textoCampos" width="9%">ICMS ST:</td>
                                    <td class="CelulaZebra2" width="9%">
                                        <input id="notaIcmsSt" name="notaIcmsSt" class="fieldMin"  type="text" onchange="seNaoFloatResetNota(this, '0.00')" value="00.00" size="10" maxlength="11" >
                                    </td>

                                    <td class="textoCampos" width="9%">ICMS Frete:</td>
                                    <td class="CelulaZebra2" width="9%">
                                        <input id="notaIcmsFrete" name="notaIcmsFrete" class="fieldMin" type="text" onchange="seNaoFloatResetNota(this, '0.00')" value="00.00" size="10" maxlength="11" >
                                    </td>

                                    <td class="textoCampos" width="7%">CFOP:</td>
                                    <td width="15%" class="CelulaZebra2">
                                        <input class="inputReadOnly" type="text" size="7" id="cfop" readonly  value=""/>
                                        <input type="button" id="botCfop" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CFOP%>', 'Cfop')" value="..." />
                                        <input type="hidden" id="idcfop" name="idcfop"  value=""/>
                                    </td>

                                </tr>

                                <tr>
                                    <td class="textoCampos">Chave NF-E: </td>
                                    <td class="celulaZebra2" colspan="4">
                                        <input id="notaChaveAcessoNfe" name="notaChaveAcessoNfe" class="fieldMin" type="text" value="" size="55" maxlength="44" >
                                        <img id="imgConsultaSefaz" class="imagemLink" height="20px" align="middle" src="img/pesquisar_cte.png" onclick="consultarNfeSefaz();" title="Consultar chave de acesso na SEFAZ" alt="">
                                    </td>
                                    <td class="textoCampos">Tipo Documento:</td>
                                    <td class="celulaZebra2" colspan="4">
                                        <select id="nfTipoDocumento" name="nfTipoDocumento" class="fieldMin">
                                            <option value="NF" selected>NF</option>
                                            <option value="NE" >NF-e</option>
                                            <option value="00" >Declaração</option>
                                            <option value="10" >Dutoviário</option>
                                            <option value="99" >Outros</option>
                                        </select>
                                    </td>
                                </tr>

                            </table>
                        </div><!------------------------------------------------------------ Fim da Div das Informações Fiscais --->

                        <div id="divAgenEnt"> <!-------------------------------------------- Início da Div do Agendamente e Entrega -->
                            <table width="100%" class="bordaFina" align="center">
                                <tr>
                                    <td class="textoCampos" colspan="2" width="25%" >Nota fiscal importada via EDI?:</td>
                                    <td class="CelulaZebra2" colspan="6" width="75%" >
                                        Sim <input id="ediSim"  name="isEdi" value="true"   type="radio">
                                        Não <input id="ediNao" name="isEdi" value="false" checked type="radio">
                                    </td>
                                </tr>

                                <tr>
                                    <td class="textoCampos" colspan="2" width="25%" >Carga com entrega Agendada? :</td>
                                    <td class="CelulaZebra2" colspan="2" width="15%" >
                                        Sim <input id="agendadaSim" name="isAgendado" value="true"   type="radio"  >
                                        Não <input id="agendadaNao" name="isAgendado" value="false" checked type="radio" >
                                    </td>

                                    <td class="textoCampos" width="15%">Data do Agendamento:</td>
                                    <td class="CelulaZebra2" width="45" colspan="3" >
                                        <input id="notaDataAgendamento" name="notaDataAgendamento" class="fieldMin" type="text" maxlength="10" size="9" onchange="javascript:alertInvalidDate(this);"  value=""  onkeypress="fmtDate(this, event)" onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)">
                                        Ás
                                        <input id="notaHoraAgendamento" name="notaHoraAgendamento" class="fieldMin" type="text" maxlength="5" size="5"   onkeyup="mascaraHora(this)" value="">
                                    </td>

                                </tr>

                                <tr>
                                    <td class="textoCampos" colspan="2" width="25%">Contato:</td>
                                    <td class="CelulaZebra2" colspan="2" width="15%">
                                        <input id="notaContato" name="notaContato" class="fieldMin" type="text" value="" size="45"  >
                                    </td>
                                    <td class="textoCampos" width="15%">Telefone:</td>
                                    <td class="CelulaZebra2" colspan="3" width="45%">
                                        <input id="notaContatoFone" name="notaContatoFone" class="fieldMin" type="text" type="text" onkeypress="mascara(this, telefone);" onchange="mascara(this, telefone);" onfocus="mascara(this, telefone);" onblur="mascara(this, telefone);" value="" size="13" maxlength="14" >
                                    </td>
                                </tr>

                                <tr>
                                    <td class="textoCampos" colspan="2" width="25%" >Observação:</td>
                                    <td class="CelulaZebra2" colspan="6" width="75%" >
                                        <textarea id="notaObservacao" name="notaObservacao" class="fieldMin" onblur="this.value = this.value.substring(0, 200);" rows="5" cols="80"></textarea>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="textoCampos" colspan="2" width="25%" >Agendado por:</td>
                                    <td class="CelulaZebra2" colspan="2" width="30%" >
                                        <input id="notaAgendadoPor" name="notaAgendadoPor" class="inputReadOnly" type="text"   value="" maxlength="50" size="45">
                                        <input type="hidden" name="notaAgendadoPorId" id="notaAgendadoPorId" value="">
                                    </td>

                                    <td class="textoCampos" width="15%">Data da Entrega</td>
                                    <td class="CelulaZebra2" width="45" colspan="3" >
                                        <input id="notaDataEntrega" name="notaDataEntrega" class="fieldMin" type="text" maxlength="10" size="10" onchange="javascript:alertInvalidDate(this);"  value=""  onkeypress="fmtDate(this, event)" onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)">
                                        Ás
                                        <input id="notaHoraEntrega" name="notaHoraEntrega" class="fieldMin" type="text" maxlength="5" size="5"   onkeyup="mascaraHora(this)" value="">
                                    </td>
                                </tr>
                            </table>
                        </div><!------------------------------------------------------------ Fim da Div do Agendamente e Entrega -->
                        <div id="divInfVeiculo"> <!---------------------------------------- Início da Div das Informações do Veiculo Trasportado-->
                            <table width="100%" class="bordaFina" align="center">
                                <tr>
                                    <td class="textoCampos" width="10%" >Marca:</td>
                                    <td colspan="3" class="CelulaZebra2">
                                        <input name="idmarca" id="idmarca" type="hidden" value="">
                                        <input name="descricao" type="text" id="descricao" size="25" maxlength="25" readonly class="inputReadOnly8pt" value="">
                                        <input  name="localiza_marca2" type="button" class="botoes" id="localiza_marca" onClick="javascript:localizamarca('marca_rastreador');" value="...">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar marca do rastreador" onClick="javascript:$('idmarca').value = '0';
                                                javascript:$('descricao').value = '';">
                                    </td>

                                    <td class="textoCampos" width="10%" >Modelo:</td>
                                    <td class="CelulaZebra2" width="30%" >
                                        <input id="notaVeiculoModelo" name="notaVeiculoModelo" class="fieldMin"  type="text"  size="30"  maxlength="30" >
                                    </td>

                                    <td class="textoCampos" width="10%" >Ano:</td>
                                    <td class="CelulaZebra2" width="10%" >
                                        <input id="notaVeiculoAno" name="notaVeiculoAno" class="fieldMin"  type="text"  size="4"  maxlength="4" onkeypress="mascara(this, soNumeros)"> 
                                    </td>
                                </tr>
                                <tr>
                                    <td class="textoCampos" width="10%" >Cor:</td>
                                    <td class="CelulaZebra2" width="30%" >
                                        <select id="notaVeiculoCor" class="fieldMin" name="notaVeiculoCor">
                                            <option selected="" value="0">Nao Informado</option>
                                            <option value="1">BRANCA</option>
                                            <option value="2">AMARELA</option>
                                            <option value="3">AZUL</option>
                                            <option value="4">VERDE</option>
                                            <option value="5">VERMELHA</option>
                                            <option value="6">LARANJA</option>
                                            <option value="7">PRETA</option>
                                            <option value="8">PRATA</option>
                                            <option value="9">CINZA</option>
                                            <option value="10">BEGE</option>
                                            <option value="11">ROXO</option>
                                            <option value="12">VINHO</option>
                                            <option value="13">GRENÁ</option>
                                            <option value="14">MARROM</option>
                                            <option value="15">ROSA</option>
                                            <option value="16">FANTASIA</option>
                                        </select>
                                    </td>
                                    <td class="textoCampos" width="10%" >Chassi:</td>
                                    <td class="CelulaZebra2" width="30%" colspan="3">
                                        <input id="notaVeiculoChassi" name="notaVeiculoChassi" class="fieldMin"  type="text"  size="30"  maxlength="30" >
                                    </td>
                                    <td class="CelulaZebra2" width="30%" colspan="3"></td>
                                </tr>
                            </table>
                        </div><!------------------------------------------------------------ Fim da Div das Informações do Veiculo Transportado -->
                    </td>
                </tr>
                <tr>
                    <td>
                        <div id="divAuditoria">
                             <table width="100%" class="bordaFina" align="center"><!------------------ Início da Auditoria --> 
                                <tr>
                                    <td><%@include file="/gwTrans/template_auditoria.jsp" %></td>
                                </tr>
                                <tr>
                                    <td colspan="8"> 
                                        <table width="100%" align="center" class="bordaFina">
                                            <tr class="CelulaZebra2">
                                                <td class="TextoCampos" width="15%"> Incluso:</td>

                                                <td width="35%" class="CelulaZebra2"> em: ${notaFiscal.criadoEm} <br>
                                                    por: ${notaFiscal.criadoPor.nome} 
                                                </td>

                                                <td width="15%" class="TextoCampos"> Alterado:</td>
                                                <td width="35%" class="CelulaZebra2"> em: ${notaFiscal.alteradoEm} <br>
                                                    por: ${notaFiscal.alteradoPor.nome}
                                                </td>
                                            </tr>   
                                        </table>                  
                                    </td>
                                </tr>

                            </table>
                        </div>                     
                    </td>
                </tr>
            </table><!---------------------------------------------------------- Fim das Abas -->



        </form><!--------------------------------------------------------------- fim do formulário Principal -->
        <!-- Copiado da tela listar_cte.jsp -->
        <div style="display:none">
            <form  action="http://www.nfe.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa" id="formConsulta" method="post" target="popConsultaCompleta">
                <input type="hidden" id="ContentPlaceHolder1_txtChaveAcessoCompleta" name="ctl00$ContentPlaceHolder1$txtChaveAcessoCompleta" value=""/>                        
                <input type="hidden" name="__EVENTARGUMENT">
                <input type="hidden" name="__EVENTVALIDATION" value="/wEWDwLqi5+UCwLnzPHfDgKC+5r9AgKv1eaJDQKv1crCCgLKvoxzArbj59AHAuq3254LArXmppIHArS400ICtK7PoAgC+73rpgECjJXFhAcCi5GdvQsCt4XRhw1DnvM3roGNgaNuGPVWJbokBotieg==">
                <input type="hidden" name="__VIEWSTATE" value="/wEPDwUJMzM3NTgyNjMxD2QWAmYPZBYCAgMPZBYQAgkPDxYCHgRUZXh0BQ8xMCw3NzQgYmlsaMO1ZXNkZAINDw8WAh8ABQ0xLDE2IG1pbGjDtWVzZGQCDw8PFgIeC05hdmlnYXRlVXJsBRVpbmZvRXN0YXRpc3RpY2FzLmFzcHhkZAITDw8WAh8BBeABaHR0cHM6Ly93d3cxLnNwZWQuZmF6ZW5kYS5nb3YuYnIvc2NyaXB0cy9zY2FlZi9sb2dpbi9sb2dpbi5hc3A/VVJMPS9zcGVkbmZlYWNlc3NvL2FybmZlL2luaWNpYWwvZGVmYXVsdC5hc3B4JlNpc3RlbWE9U1BFRE5GZSUyMFBvcnRhbCZVUkxDZXJ0PS9zY3JpcHRzL3NjYWVmL2xvZ2luL0FicmVDZXJ0aWZpY2Fkby9kZWZhdWx0LmFzcCZVUkxTY2FlZj0vc2NyaXB0cy9zY2FlZi9zY2FlZi5kbGxkZAIXDw8WAh8BBTJwZXJndW50YXNGcmVxdWVudGVzLmFzcHg/dGlwb0NvbnRldWRvPTQ3RklvNzJ6OTlzPWRkAicPPCsAEQIADxYEHgtfIURhdGFCb3VuZGceC18hSXRlbUNvdW50AgRkARAWABYAFgAWAmYPZBYMZg8PFgIeB1Zpc2libGVoZGQCAQ9kFgJmD2QWAgIBDw8WBh4NQWx0ZXJuYXRlVGV4dAUrTWFuaWZlc3RvIEVsZXRyw7RuaWNvIGRlIERvY3VtZW50b3MgRmlzY2Fpcx4PQ29tbWFuZEFyZ3VtZW50BSRodHRwczovL21kZmUtcG9ydGFsLnNlZmF6LnJzLmdvdi5ici8eCEltYWdlVXJsBR1+L2ltYWdlbnMvYmFubmVyX21kZmVfT2ZmLnBuZxYCHgV0aXRsZQUrTWFuaWZlc3RvIEVsZXRyw7RuaWNvIGRlIERvY3VtZW50b3MgRmlzY2Fpc2QCAg9kFgJmD2QWAgIBDw8WBh8FBSZDb25oZWNpbWVudG8gZGUgVHJhbnNwb3J0ZSBFbGV0csO0bmljbx8GBR1odHRwOi8vd3d3LmN0ZS5mYXplbmRhLmdvdi5ich8HBSR+L2ltYWdlbnMvYmFubmVyc19WaXNpdGVfQ1RlX09mZi5wbmcWAh8IBSZDb25oZWNpbWVudG8gZGUgVHJhbnNwb3J0ZSBFbGV0csO0bmljb2QCAw9kFgJmD2QWAgIBDw8WBh8FBSlTaXN0ZW1hIFDDumJsaWNvIGRlIEVzY3JpdHVyYcOnw6NvIEZpc2NhbB8GBSNodHRwOi8vd3d3MS5yZWNlaXRhLmZhemVuZGEuZ292LmJyLx8HBSV+L2ltYWdlbnMvYmFubmVyc19WaXNpdGVfU3BlZF9PZmYucG5nFgIfCAUpU2lzdGVtYSBQw7pibGljbyBkZSBFc2NyaXR1cmHDp8OjbyBGaXNjYWxkAgQPZBYCZg9kFgICAQ8PFgYfBQUqU3VwZXJpbnRlbmTDqm5jaWEgZGEgWm9uYSBGcmFuY2EgZGUgTWFuYXVzHwYFGmh0dHA6Ly93d3cuc3VmcmFtYS5nb3YuYnIvHwcFIH4vaW1hZ2Vucy9iYW5uZXJzX21hbmF1c19PZmYucG5nFgIfCAUqU3VwZXJpbnRlbmTDqm5jaWEgZGEgWm9uYSBGcmFuY2EgZGUgTWFuYXVzZAIFDw8WAh8EaGRkAjMPZBYEAgEPDxYCHwAFCUNvbnN1bHRhc2RkAgMPZBYEAgEPZBYEAgEPZBYCAgEPZBYIZg9kFgICAw8PZBYIHgpPbktleVByZXNzBRltYXNjYXJhKHRoaXMsc29OdW1lcm9zNDQpHgdvbkZvY3VzBRltYXNjYXJhKHRoaXMsc29OdW1lcm9zNDQpHgZvbkJsdXIFGW1hc2NhcmEodGhpcyxzb051bWVyb3M0NCkeCG9uQ2hhbmdlBRltYXNjYXJhKHRoaXMsc29OdW1lcm9zNDQpZAIBD2QWAgIDDw9kFggfCQUZbWFzY2FyYSh0aGlzLHNvTnVtZXJvczQ0KR8KBRltYXNjYXJhKHRoaXMsc29OdW1lcm9zNDQpHwsFGW1hc2NhcmEodGhpcyxzb051bWVyb3M0NCkfDAUZbWFzY2FyYSh0aGlzLHNvTnVtZXJvczQ0KWQCAg9kFgICCw8QZGQWAGQCAw9kFgICCw8QZGQWAGQCAw9kFggCBw8PFgIeD1ZhbGlkYXRpb25Hcm91cAUIY29tcGxldGFkZAIJDw8WAh8NBQhjb21wbGV0YWRkAgsPDxYCHw0FCGNvbXBsZXRhZGQCDw8PFgIfDQUIY29tcGxldGFkZAIDD2QWBAIBDw8WBB8HBY4+ZGF0YTppbWFnZS9wbmc7YmFzZTY0LGlWQk9SdzBLR2dvQUFBQU5TVWhFVWdBQUFMUUFBQUF5Q0FZQUFBRDFKUEgzQUFBQUFYTlNSMElBcnM0YzZRQUFBQVJuUVUxQkFBQ3hqd3Y4WVFVQUFBQUpjRWhaY3dBQURzTUFBQTdEQWNkdnFHUUFBQmJPU1VSQlZIaGUxWjFYckZ4RkVvWk56c25rSUVEa2JMSklJZ2hFem1DUlRCWkppQnhGemtFSXNNQ0lOU3hnZ2dBaE1FaWtCU3l4Z0FTTEh4WjRXY09UOFJPODhiWm9uODdPMTl6L2JOMjYxWDM2ekowTDdDK1ZadWFjN3VydTZrcmRmV1ptMnZUcDAvODViZHEwcGtUTEw3LzhmN2JhYXF2Rm9oa3paaXc2NG9nai9uSFlZWWN0bkRsejV0OHZ2UERDdjgyZE8zZWVhUDc4K1g5cG11YXVMbHF5Wk1sRGxPZlZYdi9sbDEvdTg5ZjYwc3N2di94WDlXZldyRmtMZHQ5OTkzL3R0OTkrMzBMME9TS1YvL0xMTDJkSFBQOUlZanpSOWFrbTVNRjhSUGYrakRSdHBaVlcrbmVreEtPa3pUZmZ2RG40NElOYnV2bm1tNXM3Nzd5enVlU1NTNXFCWVRSUFBmVlU4K21ubnliNjZhZWZtcmZmZmp2ZC8vWFhYOXZyb2l1dnZMSVpHRkM2ZittbGw3WTg5OWxubjdEdHlkREFlSnNqanp5eWVmenh4NXRGaXhZMWc0bHQzbnZ2dllIY2hvTWREN3lnSDMvOHNTVStSNkE4L1huaGhSZkdyZ3dQMzRjU2FJOTJIM3p3d2JFcmYzNU13eE9lZDk1NTdTU3V1ZWFhemI3Nzd0dHNzODAyemE2NzdvcDNidS85UDlLS0s2N1liTGZkZHMzcXE2OGUzdTlEeXk2N2JIcmRmdnZ0azBGQktQdTc3NzZiWGovLy9QTXhzY2JBS0ZUdm0yKytTUXB6Mm1tbkpjTisvZlhYMDdVSXI3MzJXbXFYTmp5bzg5VlhYNDE5bWdpVTFpcXY3ME1Kak92V1cyOXRGaTllUEhibGo0VWZpOFVubjN6eW0rRVAzdU9xazNCUlprM2VNY2NjazZ3WldLdCsrdW1uMHlCMzJtbW5adjMxMTI4R0lYeEt2T05rQ1dPVTk4WmdOWW5RTTg4ODA1eDc3cm1KTHJ2c3NuVHQ2cXV2YnN1dnQ5NTZJYzgraENHSkgvSzU2S0tMMnZhSlFNZ1NSYVZkcnBXQS9QR1NmaUkvL1BERHRyMmM5MFpwNFY5U2VnLzZob3pnTzJydjNDZENlT1RHQWkvNmVzSUpKL3hQb1FIaC9xQ0REbXFGaEdlak1nMzNiUnlyVnNkTGRQdnR0NmUyTHIvODh2WWFLUWdUemZXenp6NjdWUVRvOU5OUGJ4VUZVbDlIUlphM2JRdkR4WWdIS2RxNDhpdXNzRUlpZTIxWXNxa1piV3ZNS0pXVm1lWUM1Y0JyUjhvK0xKUm1xTzFSZTJjaUJBNFJaL0xzczgrT3BOODJnbzFUYUN4QXdsMXV1ZVhTSzU2R3ZMVXJQTlhnL2ZmZlQ2SFZ3bm9mM211QXZQWVZxRFVpdkpjbUJTSVhsckpncUJybnFJalViTER3YkRiWVlJUDBlWXN0dGhnWDhhYUtyQkV3Ump0bXlRSWxxa1d0M0NsbmpjdWlLd1Y2OGNVWG01dHV1aW0xRStuVmQ5OTlsOHBFdkNOWUhScW4wSVJDQ1lyR2JDckIrejZDOGNEcml0Y1ZWMXd4ZG5VOHRCZ1VQdnJvbzBRU0hJUHZFem85NE1QZ1BiaU9nUEVhNm9Qb3hCTlBuRkpEK0wwSkkyTXNwR0ZXbG5JbTFxbVUwQlgrYlFvRVQ2NURyRE9pZW9KMXF2ZmZmLy9ZMVhxTVUyaEFSOGlUTmZGWFhYVlYyd0RlbXRRZ1Vvb0lDR2JCZ2dXcDgyKzg4VWJMNTdISEhoc3I4UnNveDJCUmVnWUxGUG9PUGZUUWRNMGFSQzVmdE1ERFdBTVV2MXhPU0xyVk53cFJYb2JBUWxIOVczWFZWZE0xbTdJY2NNQUJyZmYrc3hES0xSbkprTDFUNll0b0FVc2I4SVNRR2ZPZE14cnJWSEVtZlpFVUd1Wk1xSWUxbG8wMzNyaDl6dzVJVk43ajJtdXZiZXVnVU41WUJOcGhzR3lKU2FsKy92bm5wQlFJaVA1UnB6WmZ0UDFHUUlBNnRQSDk5OTkzMXU4RDYzMHdPcHRtUkxzU2dEcU00ODAzMzJ6THNuWmhWNEc4RWo0cEh4eGMzM3Z2dmRNOUtZUUlEeXRqS1JHTDR3TVBQREM4SjFrRDVnYStlaDBXR2x0SnhuanAwbzdRN05telUwYncwa3N2OVo2cnBORFJJR0IwMjIyM3RRSi80b2tuMm9VYXhNUlJyd1NVaHpvMVN1amhyYm9QckpWalFCYVQ5VUFldnA4WXVrM1YyQ3YzQml4NEk3VzdGdFRqOWRSVFQwMkczVmQrZ1BtQkIvd0ZIN2tFK3YzMTExODNQL3p3UTI5NTl3WDhVZWljVTV6TTNDZUZacEErcHlHVUlnd09NVWdSeUdVUkt1VnNMc2xDaEVNQmVhbGhCRDhWWURLamFEQlpEeVF3VHFJSEtaaFNDdzZNVUVxaWl4UVNRc0dqeVlPSHZXNFZIQjY4dnZQT08ybWZPc281cVYrU09kY1pxeFo0S0lmNjlNb3JyNlJyRmlWanorVzh3Mkt5ODhDWUdEdHpnSzRpTi9haUorVFFFdExERHorY0JzNkVFUWFwcEVFaGVEdGhxNjIyV3RvREhNYWlSb0Urd2thQit2WVJqNEU4R0I4R1hKTUxFK3JaNnRObmRpT2tXRUkwcVYxS0tuRGZ6MHNYYk9SaTY4d2pwMlRzT0ZEbnVPT09hMU1kOGJHRTRkcVVCckxSd1VKT2xMRkdFWXo3aWlUY1IzRnhITWd4YXJ1bFFmbHhDczFrSXlRR1R3N00rMGhSOFVSTU1vY3JZc1prNThLSVIyNGdmUUVmMm1ZeWhrVkppUmpucUU1TE45MTAwM1pOQURTcEZzZ1plWmVVRkxtaHpLUWllS1VTS012WU5EN2tGRVV1d0FLZWFFejdLSTlOblNaRDhJblNuTHZ2dmp2ZDUvRUgyaFE5OU5CRGJWMzBFT2VnejUwMDREdE9vVUZOT0xCV2FnOGJlSThSbEFCL3l1YXN0d1FteFJvTkNnS3YzQUtzQmprbGduZU5NbSsyMldacEJ5aTY1NG0xeC96NTg4ZGFHQTQyeDJSdjN5c0x5aXFqc1dXOVU2S2NQRjl0LzRjbDVNaHBLWHBqRjg0UjZRd0V1dkhHRzhmZHl4RksvOEFERDhRS0hYa09ENnZRT2NJalVRNWhvc1FLTWVTSFhQTWh1QVl5TmlZSGZrd0toaEY1Vnc5NUtrKzVzYTYxMWxyaHVBaDdoRjc2WXNmQWV4M29iTDMxMWhQcUxiUE1NbTM5WWNidWdRekVHMDhtbEhKaEN5S3E2dGVRanZNWit5bW5uSkt1ZWUvYW1SSlVFQ2tkUis5RUV1YVY5cUp5RUlwc0RUcFU2QnJVS0hTTzFsMTMzZlpVQ3c4aHo0Rnk2a0VmaFQ1UDdJc2pSUEZDcVFBRFJ6bXRZcU9vOUxOV3lPd1ZXN0J0cE8xS251K2dYMUpFWHFNd0N1Z0hkVlplZWVWeC9DRkZzMXFscGcwWkh1MUxEdXpSY2hRdnZqeDdvM3VraXJ5V2dKeTZQQ1hFUEhtNWdwd2ptVGR2WHNpbmh0aHNvTjlXcnZBbmdrVGxveDJrYW9WbVVMYXlWMmlzQ29HejB0OWxsMTFhYjlTSGhnbDc3T1dDS0czb2xYc05hT2VkZDU0Z29BaldNODZkTzNlQ1lpc05tamx6Wmx0T1JPaGRZNDAxMG51VW1oMGk5cDFKMDVBcE5Jb0RHTm81L1BERFV4ak9qY2thQ3hTMWk5TFVnbmJZRGR0MjIyMG44SUgyM0hQUDhMUlZUc2tET1VmbDBSTmtIQ0ZVYUt6Q1dpVU53c2ptdkY2aG1Sd0w2a1loTFRmWVlZakZodmNRQXRmdnVlZWVaTjBsVHdRUHhzVjRhMkYzQzBRMjVET3g4TVJyK25Jb0RSTWw0eDNWZ3JORUtFVXVyYktJSWhrUGgrVms3SUdCc00ycngyd3RJV2Y2SUYyeXhIbUhCZVZJTnlJSHgxaThBN0VJRmRwN093YkVaeHNpZlJqd0NnMVFFbHNHMG9xWFZUckg0WVJPZTEvYmY5NWdQTkYreVp2cUVJajJmRjBJWVZrREJZeTdadUpwRjY5cXR5N3RBUTd5c3Zjc0VjR0FQVVRwUzZSRzh1WmRjckxFb3F3a3M3WFhYanVzeDI1RUZ4Z3pEeFhsb291MmdWRjRmdytTbHlibGpPNUQ1TktsL29PaGMyanZwVkFjajBpaElhMWkyUXRGcWV3OUZGR2dqU2praUJDZVZTUUI0ZklNU0ZRSGlyWVhyWUxsUXFDZ1JSZUdlY1laWnlSUHpGaTRob0htSWdLTFpPdGQ2THZ1a2U3WXNpTGxzSUJ4NFFqOHNUSDlwVzFPK2M0NjY2eVFqK2pZWTQ5TmRhSW5INlB5aklkMlM4QVJJSU5vM0Z4RFhrckRrSmN2dzJrb3FSZGppd3dDNTlNMUo4SzBRV2Z2UTJCUVY4Y3RzQlJ5WmlhSkE0UW9wNGtVZXNzdHQyemZzK0N5bnlHczBJTmpkdzV2YkRsTEtMMUNQZ3FUVXc2RWxjdTlOQjRNckVzT1BHdkFBMGhSR3psaXJORjJwbjJjSUNJckR4UUh3eUU2MlBraWN0cklRZ2pmWkpOTlFuN1F4UmRmUE82OWVOa3lvcHdpNFFDSVFqbVBESkZlTGx5NE1KVkh2aGlkZDJBUWJUQ3VLRlZCUHpBK0Qvb2J6ZE8wanovK2VBNE5RUWlzTCtRZElpQmszMEdlN3lEczZyTWZoQ2JRaDM0RXdoRnd0SE1nWWhFWTVWMFFmSzBBY2dLcEFhRTdhaU5IUE15RkV1YmtwTFJocWFXV21sQ1hCNU1zTUZqTkY1NDZHb01VUExjN01HUEdqUGI5ZGRkZGwzaXhOMjdMaUpncm5BQmw4TlkxS1E1ZW1mSWNyL01xb0N2cFd5V3VmTWtvUktTbkZ1aHFwSzlEcHh5Qzl3NFczUE1kVThnbDNFMmZQbjNDZlN4WWVSUktZQ0dQeityZDFpbFJia0dVRTBnTnFGZGFhRVowempubnBJZC9JcEQrbENhVjNaSUlYV1BnWHNRUG85YytyM0xTYUs3NkVsRUxCWmFSZVdkSEcvYUJ0ejVFZnE4b1hNS2tGYnFFU0Vnb3BZQXc4Wnk2dDhvcXF5U3IxdEVuNFpqeWxJUFhvNDgrbXE1clA3akxXeERtKzNoaEZDQm5uQkVveTc0NHo3dVE2OUtmWElTQS9DR0FoWExNSE9WQ3Y0Q01rSlhTQnlHM2RlbkhtVlArTG1MdFpCZjJ0cC8rdVJuYTVMNnQzNWVRTVhPZnd6aUZSaEJlSUpOQmwwSUw1R1BXUXhIUzc3MzMzdVNoK2N4WHdIUlAyMGdJUnZ1NUpjS1RSZ3RIano2TFFzRXFnYndIazRnaDVoU2I2MzVCS2tUcDFJWWJicGlPZisyY3lNZ3RiQ3BpbFlqUG5pZms1NEhQVVRrUmZXTW5Dd2RFdmtzVVZSOTQ3VnAvaUg5dWx3T0NON3d3YnRLbG5BeFp0N0dJdEpCQmoxTm9CSUVBK25pcEVtb1ZHakRKZHQrYVZJRUZCZjFKWi9SajEvbWMyNG9yRWZ4UTJoeHFKZ1Z3NzYyMzNrckg5OWJiZUtOaFBINUxNbGRXSUtMNHN2U2JNUXRxRXlYUGVYc0x1MTZ4NU9jNHA5QmFSRnR2cTEyZVBsQUVpblk1Y0RwcXh3Slo1eUtNMzFXVFFVOXB5a0dIZkVlaWpsdWdVTEpNWG1mTm10WFczV09QUGJKV2kzVXI5MTVublhVbTNCZnhEUkFtaGdtVWg3R2d6OXl6SGdod25VbVZoMkdyQ1FHaVlEWVh0YUI4ZEhCQzJJd1FHU3JYUHZ2c3M5USs0SlhGc2U3N3ZGTDlWL21JSjMzQ0lDMnNjVm9TSHd2SzlsVm81TVBjS3VwYUt2R2lYblJBQjlrdFhtRktGUnI0VGlBTUlSY0p1STVuOG5VaklpU3o5d3JrQlI1NTVKRWt2SzZGMnkyMzNKTHFXYURzV29uem14M3N5dWhieWhDSEJ5ajFGMTk4VVJYSmNnY3NrUUZFYXdLdWVZL0laOTMzM3Q1R1dieVc1U1ZDdHZLMlFrNmhLZWZIYWIyMVIrUW9NQW9aUnRTT0haczNTQUEvdTlheTVMK2ZXcVhRVVNNZXBCZVVzUVI4QjZUUTNMZWZnWVRIUFR6STBVY2ZQYUcrSmNJcENpZUJ5d3VvbndpK3RNL0w3Mm5BdzA4TzlYblcySmJsUUlLSGxYSmdDdzN2WTJVRTM4aW84RGdSY2dxTmpMd1g0eHJLdkdUSmtwUXFFVkg4L09UU2pTamxRVzVSV1JFN1MvVEZPeHF1Q1ZKV2VGa2dCOGxZWlN6WnNWRk9CbW5CM0VicEI5R0djVklIcWxKb0dtR0NDWDBSYUt6V281SlhJbEQ5d0F5VEFleWlETEpQMUhsaU1WajZrcVdBeDBhaFdVUkVmRHl4Nk1FSWdIM0lISXFVUUxCOTEzTUpHSGd1UXZnMFFZZ1VtcFNoNUJIaHhWNDFVVU5sVU95Y1I3TmpCTHhIeWFLMmE0Z1VVTHNPdEl0UzZiTUZPb0tqSXNwNUhsYWhTeURpNUZMT2xnYmxRb1ZXQnlEbFBUWkUwM2tybUdFRnN1T09PeWFCNHBIWnE5MS8vLzE3L1JSWExpZlBlYWNTb1lEUFAvLzh1QnljeHozNXJUODI5cjNYQU1pQko4d3V1T0NDZE54T21zS3pGcmt4NEdWeWlCYVJHMjIwVVdyWHl6c0h2Mk5raWJiaEExQ09ZZWRNaEhGNFE0ZS8yckQ0OXR0dlU1VGpCM2dpWHBaWTUyaXNmdHlSaHg5SGd6THBad3hRWE5zUnJSb2h2Q0Y1Slh1dUFveXRaY25TMlc2cDlkWWlRbi91dUxxTFVGd0x2QU45Wnp6UmhESFpYQmZ4YTBmOFlDTEVFYXN2UDByaTYycHNSM3BaQzhjZmYzeFlEOElEZTArR1I4YWd1YzVZU29jekdKdSs2QXlpeFdLSlpPVDhJaXZ0NVNJRzEvMjlyblFtb2h0dXVDSHRjdUZNL1NNRHVlaVRGdUNEKzNmUkFUb1plU0FCUmJIMy9lY2NLTU1FNnZ0ajBBNDc3SkFzbFpQQzNYYmJMUzJjY3AwVTRRMllOSjYxdGpzSDlna3l4cUhydWJCdVFiOG9LMlZCMlZSL2xJVG5oejllaWxldkVDalo5ZGRmM3l5OTlOSVQ2dkpvQUxMaVdXS01yMnVoNndrbEo2M2psTkxPTWU5dE9jbVg2RUlLZzNOQ1BqYWRZR2ZuekRQUHJKcDNnWHFkYVlJait6MVZVamkvZG9HbjVLaCtzbkJQWXhyY245SmREc0VxQ3lkckNBM3lUM3pWZ0doZ1BUclBTaUQ0MHVvL2d2SjRVcW56eno4L3ZULzU1Sk9iYTY2NXBqbnFxS1BTNUlyZnNFUU9uMHNWbUFpZVVyUGZvUnNWb1JSMzNISEhPSzhNYkNwcHJ3c2xSMFZkWHdmRFZIbnVSV09OMGovR2pId3hKUFFBWmNUd2lLNzBXK1ZJUS90Z2drTG5PZ1hJYzNNcjZnZ1NnUEllTEJ4RmswY1ZFSzYvNW1FRkI2enlRbmd1d2k4aGltZHZ1L2lwVHl3K1NhbTBvOEtCQmFBOUNENk1sM0hERzhIYmgzUUkzWGpQazA0NktkM2pTd1Y0MHVlZWV5N3hFZURET0ZXL2xCNzBKUmE5cEFLa2hNZ0FPU0VmOXF1SlBsWnVOcFcwVVFJd1Y2VjVoU2YxQkgrNkN0bjdIc2dBT1dvbnFtUTRITUFnSisyWFkyaDQ0YTU1bmFEUXZsT2FDSWpuTFB5S3VnUUpnTTd6cXZCbEljWHlXejBXWG5BQzcvR21kZ0YyeUNHSHBLTlpid0Fldms5UkgzbFBYczExaUxBdFdXamlvNzdScm5KYnR1aEthd3FlZkl1VVd5bUFDRSt2ZmtEcVJ3NzBSVnVQVm1ZbHlJZ0ZqVk5qaFE5dEMxNUJrWmVYZVc0ZTRGM2JOM2hJTGp6NlVFS3IwRkpjSm9MZmVxQ0RlR3J5UGdRRDFXeVZXWGdCUktBZHlrVEtMbmpCZVh6d3dRZk5YbnZ0MVE3YTVwbTFreW5BSHprd1Z2SEFNSUgxYnFSS0tEUEd3L1BnNUxrMXV6TjRkSlFUT1VkajhhQk1Wem4xMlpaajdyVDFpT3hBeWNBOWtCdDE5ZnZjQUo1VzRidVFjMFNBOGR1K2xXQ2o4WDMzOFhjdmViUUs3VU9SbExFVW9yclFWd0REUW4yMXEya1dVOUgzNFhJS2d0RnduZjdDUzE4Wmdzamp1SWFuck4zQklZZGxtNHhGRktkWktOd3dvRDlkTWxTZnZjSXlKam1CUGg0UlVBZWVuTHFTdW5BR0FROXZPQ1dVSEpIdFd3M29kNVN1ZW1RWGhYaE1Qd2lvejRENlFrclZGemJVa2NOYXhjSWJXaUhrRkFRdlFCUkN5T3k0NUI2S3NVUWtRTWtweitUREEva0E2d2lpVkVXUVhLY2FmVHlpeGF1dnZ0cU90OC9QdlRFbnlLQUdqTit2MjVCVmwvSmFpRWRXb1lIM3pqbFBZTkVuckFtYVZPWGNrd0ZDZ0lmOVRpRVBOZm1VaHZZSWlhekFVVXFWallqblJjaUY0WXVuNkN2c1VwU1RYRXVJSnJ3djZHOGZqeWhRVDE2MjYyZkhCTVlqMlNsZEswRVJWdUF6ZGFObmJYSVFqNkpDOXdVVFRVZGdEbW9uUXBQcUI5YUZMdU5oRWlSWXZPbWNPWFBTNUpTOEwvZnd1TlNOUE9vZmdlaHdZUmd3bG1ISDQrZldBOFVYYjV2ejFteWYyZ2dMNE9NUDhyb2dIaU5WYUIvVytpcG9iYzVOeDdzRUxEejU1Sk1UL3VqSEV0NFpMNDIzcnBsc08zSERndnA5aklXZEZudTQwTGUrSU1kUlFpNVY2RXBaZkhSbFhuek9TMzlMRHM2MjdaVzhGcUZDRDhNSStMQm1POVdISi9Wemt5VkYxbU9aa1lDcGl6QnpDemhTQ0hZcGNtMlVNSXEwQ0tXQ0IxOU1yYzB6TFZSLzJIbktBYjZTa1U4Vi9OeDYxRGl2VWhuZmRzNnd1akJCb1dzOW53V2RLUW0zTDAvNFFSSGtLVmo4SVJ3cllBU0FvdnZqWWRJSXluSkNxV3Q4ZjFIUFVRUDRsTHdIOXhtSERsY3N1dXBHS0NsUEg5UXFOWDJYdDh4RkdmcWhQdFdrQ2hZMTBiWGtkVzNiYklYcWZWL1p0QXJOQURtVjBYRXdYM3VxUVdtdlVaQVNzZ1dFWUtGSW9EVmdNbEFvZnRsZUFtVFFmbUdIVXFQY0NOR0NQbHFGWnhkRTEzUGVBOUFXOSszL3dBaGRkU05NUm5tRVdrZmgvMFNUdG5QOWhaZFBGWDR2Y0dESG93RDJENmE4Yk9oWFNZZGFoV2FTR0NqV3dRNkJEbEc2UEFBTkVQWjVWc04rY2RGNkFkNGpUSDFIRU9xeVp1cEdYby9yL05DTGVIaEY1dUNDU2NsTkNNZXAvbUVaZVBCTmxMNGhuUGFwSTgrano3V2duL2J2UHZxaWxOZkNUNU91RTE0WmQ4NEF2YkpBZlNQUFpHQTllTTZ3aU1JbEhTb3VDaGtZQW9PNUZWQUViL1VsTHhEQjg0K0V6dUJZN2ZQZ0VFZmNWaW41VERxZytwU04ra3Jhd2I5QzJib1F4ODk5bE5GSHBsS2tZcUp5K1NDVHdqaHIyMlpNVWpMR21NdHJMVjh2eTF4NjRKVWxtb00vTzRvS2JUMUFsK0Q5NENOaElQaWNVWWcvcTNuYVFBbjh3UTRDNTBFZysxTzlQRTZxOTJ6MXFIK1JRZEVueXZISUtjOUtxSjRJejEwYi9sRW01Q0tGOHA4RnhpWCs5R215Nkt0a3RCK2xTVFd3SG5NeXlEbVhxVUJSb2EwSFFDQ2x3WG1yajd3QW41bU1IQi92NWVReDJJK1VNdEFmN3JPRHdUV3ZTS0tjUVhHTmlkTFlvbWQxdTM3WnRBL29vL2hHeHRKSFllaTMvc2pVSTFLYW12WE5WSU0rK1o4RUd3YndLV1VJUWxHaGhkOUxNRkpPQnM4dmFRS01RRzNyc2RDU0Y2VThsQXVySHBTTHZ2ckV6Z2dLTkFvZ3N5Z2ZaSUpvcTBhbVZnNlJwK2VhVnhySjAwYU5Xc1VZRmVnM1grNndmYU50NU40SDhJRkhaTXp3KzIwOFRmTmZ1L2gvN1NST2lqNEFBQUFBU1VWT1JLNUNZSUk9HwRnZGQCBQ8WAh8EZ2QCNw8PFgIfAAUtUG9ydGFsIGRhIE5GLWUgMjAxNSAtIE5vdGEgRmlzY2FsIEVsZXRyw7RuaWNhZGQYAwUeX19Db250cm9sc1JlcXVpcmVQb3N0QmFja0tleV9fFgYFD2N0bDAwJGlidEJ1c2NhcgUpY3RsMDAkZ2R2TGlua3NEZXN0YXF1ZSRjdGwwMiRJbWFnZUJ1dHRvbjEFKWN0bDAwJGdkdkxpbmtzRGVzdGFxdWUkY3RsMDMkSW1hZ2VCdXR0b24xBSljdGwwMCRnZHZMaW5rc0Rlc3RhcXVlJGN0bDA0JEltYWdlQnV0dG9uMQUpY3RsMDAkZ2R2TGlua3NEZXN0YXF1ZSRjdGwwNSRJbWFnZUJ1dHRvbjEFJGN0bDAwJENvbnRlbnRQbGFjZUhvbGRlcjEkc29tQ2FwdGNoYQUmY3RsMDAkQ29udGVudFBsYWNlSG9sZGVyMSRtdndDb25zdWx0YXMPD2QCAWQFFmN0bDAwJGdkdkxpbmtzRGVzdGFxdWUPPCsADAEIAgFkO2XyIlKuP2mUKSxDDV37kPwNCG8=">
                <input type="hidden" name="ctl00$ContentPlaceHolder1$btnConsultar" value="Continuar">
                <input type="hidden" name="ctl00$ContentPlaceHolder1$txtCaptcha" value="">
                <input type="hidden" name="ctl00$txtPalavraChave">
                <input type="hidden" name="hiddenInputToUpdateATBuffer_CommonToolkitScripts" value="1">

            </form>
        </div>

        <br/>
        <c:if test="${param.nivelNotaFiscal > 2}">               
            <table width="90%" class="bordaFina" align="center">
                <tr>

                    <td colspan="6" class="CelulaZebra2" style="display: flex; height: 25px;align-items: center;justify-content: space-between;margin: 0 auto;">
                        <div style="flex: 1;">
                            <c:if test="${imprimirEtiquetas}">
                                <label for="caminhoImpressora">Impressora Matricial:</label>
                                <select name="caminhoImpressora" id="caminhoImpressora" class="inputtexto">
                                    <c:forEach var="impr" items="${impressoras}">
                                        <option value="${impr.descricao}" ${param.impressora==impr.descricao?"selected":""} >${impr.descricao}</option>
                                    </c:forEach>
                                </select>
                                <label for="driverImpressora" style="padding-left: 10px;">Driver:</label>
                                <select name="driverImpressora" id="driverImpressora" class="inputtexto">
                                    <c:forEach var="driver" varStatus="status" items="${drivers}">
                                        <option value="${driver}">${driver}</option>
                                    </c:forEach>
                                </select>
                                <img src="${homePath}/img/ctrc.gif" class="imagemLink" title="Imprimir cubagens selecionadas" alt="Imprimir cubagens selecionadas" id="imprimirEtiquetaCubagem">
                            </c:if>
                        </div>
                        <div>
                            <input type="button" value="SALVAR" id="botSalvar" name="botSalvar" class="inputbotao" onclick="tryRequestToServer(function () {
                                        salvar()
                                    })"/>
                        </div>
                        <div style="flex: 1;"></div>
                    </td>
                </c:if>
            </tr>


        </table><!-------------------------------------------------------------- Fim da Auditoria -->
    </body>
</html>
