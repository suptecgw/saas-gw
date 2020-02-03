/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */



jQuery(document).ready(function () {
    jQuery("#pegarTabelaPreco").click(function () {
        var aeropOrigem = jQuery("#aeroportoColetaId").val();
        var aeropDestino = jQuery("#aeroportoEntregaId").val();
        var compAerea = jQuery("#idcompanhia").val();
        var tipoProduto = jQuery("#tipo_produto_operacao").val();

        if (aeropOrigem == null || aeropOrigem == "" || aeropOrigem == "0") {
            alert("ATENÇÃO! Aeroporto de Origem não selecionado.");
            return false;
        } else if (aeropDestino == null || aeropDestino == "" || aeropDestino == "0") {
            alert("ATENÇÃO! Aeroporto de Destino não selecionado.");
            return false;
        } else if (compAerea == null || compAerea == "" || compAerea == "0") {
            alert("ATENÇÃO! Companhia aérea não selecionada.");
            return false;
        } else if (tipoProduto == null || tipoProduto == "" || tipoProduto == "0") {
            alert("ATENÇÃO! Tipo de produto não selecionado.");
            return false;
        }

        jQuery.ajax({
            url: "ManifestoControlador",
            dataType: "text",
            method: "post",
            async: false,
            data: {
                aeroportoOrigem : aeropOrigem,
                aeroportoDestino : aeropDestino,
                companhia : compAerea,
                tipoProduto : tipoProduto,
                acao: "consultaTabelaPrecoAerea"
            },
            success: function (data) {
                // variaveis
                if (data.trim()+'' == 'erro') {
                    alert("Não foi identificada a tabela de preço. Os valores do AWB serão zerados. ");
                    jQuery("#freteNacional").val("0,00");
                    jQuery("#valorFixo").val("0,00");
                    jQuery("#advalorem").val("0,00");
                    jQuery("#taxaEntrega").val("0,00");
                    jQuery("#taxaColeta").val("0,00");
                    jQuery("#taxaCapatazia").val("0,00");
                    jQuery("#taxaFixa").val("0,00");
                    jQuery("#taxaDesembaraco").val("0,00");
                    jQuery("#tarifaEspecifica").val("0");
                    jQuery("#valorFrete").val("0,00");
                    jQuery("#valorTotalIcms").val("0,00");
                    jQuery("#vlAWBCalculado").val("0,00");
                    return false;
                }else{
                    var json = JSON.parse(data);
                    var faixaPesoList = json.faixasPeso;
                    var faixaPeso;
                    var pesoAWB = parseFloat((jQuery("#pesoAWB").val() == '' ? 0 : jQuery("#pesoAWB").val()));
                    var valorMercadorias = parseFloat((jQuery("#frete").text() === '' ? 0 : jQuery("#frete").text()));
                    var valorFixo;
                    var freteNacional;
                    var advalorem;
                    var taxaColeta;
                    var taxaEntrega;
                    var taxaCapatazia;
                    var taxaFixa;
                    var taxaDesembaraco;
                    var tarifaEspecifica;
                    var valorFreteFaixa;


                    // logica do frete nacional
                    // Frete Nacional: multiplicação do campo 'Peso Taxado' com o valor da faixa de peso encontrada, 
                    //  caso seja a ultima faixa de peso então deverá adicionar o excedente por cada quilo que ultrapassou a ultima faixa; 
                    for (var i = 0; i < faixaPesoList.length; i++) {
                        faixaPeso = faixaPesoList[i];
                        valorFreteFaixa = getValorFrete(pesoAWB, parseFloat(faixaPeso.valorQuilo), faixaPeso.tipoValor);
                        if (pesoAWB >= parseFloat(faixaPeso.pesoInicial) && pesoAWB <= parseFloat(faixaPeso.pesoFinal)) {
                            freteNacional = valorFreteFaixa;
                            break;
//                            }else if (pesoAWB > parseFloat(faixaPeso.pesoFinal)) {
                        }else if (i === (faixaPesoList.length - 1)) {
                            // pega o valor maximo da faixa * o valor do peso dela + o excedente(peso-pesoMaximo) * o valor excedente da tabela.
                            freteNacional = valorFreteFaixa +
                                    ((pesoAWB - parseFloat(faixaPeso.pesoFinal)) * parseFloat(json.valorExcedente));
                        }
                    }

                    // logica advalorem
                    // ADVALOREM: multiplicação do valor total da mercadoria no manifesto pelo percentual definido na tabela no campo '% seguro' 
                    advalorem = parseFloat(parseFloat(valorMercadorias) * parseFloat((json.percentualSeguro/100)));

                    // logica taxa entregas
                    // Taxa de Entrega: deverá carregar a taxa de entrega definido na tabela se o campo '( ) Entrega Domiciliar' no AWB estiver marcado
                    taxaEntrega = parseFloat(jQuery("#tipoRetirada").val() == '2' ? json.taxaEntrega : "0,00");


                    //Os demais campos deverão ser carregados da tabela de preço. 
                    valorFixo = parseFloat(json.valorFixo);
                    taxaColeta = parseFloat(json.taxaColeta);
                    taxaCapatazia = parseFloat(json.taxaCapatazia);
                    taxaFixa = parseFloat(json.taxaFixa);
                    taxaDesembaraco = parseFloat(json.taxaDesembaraco);
                    tarifaEspecifica = json.tarifaEspecifica.id;

                    //Se a soma de tudo for menor que Frete Minimo então deverá prevalecer o campo Frete Mínimo no Frete Nacional e os demais campos deverão ficar zerados.
                    var somados = (valorFixo + freteNacional + advalorem + taxaEntrega + taxaColeta + taxaCapatazia + taxaFixa + taxaDesembaraco );
                    var valorFrete;
                    if (somados < parseFloat(json.freteMinimo)) {
                        alert("ATENÇÃO! O valor do AWB é menor que o minimo. Prevalecerá o minimo.");
                        jQuery("#freteNacional").val(colocarVirgula(parseFloat(json.freteMinimo)));
                        jQuery("#valorFixo").val("0,00");
                        jQuery("#advalorem").val("0,00");
                        jQuery("#taxaEntrega").val("0,00");
                        jQuery("#taxaColeta").val("0,00");
                        jQuery("#taxaCapatazia").val("0,00");
                        jQuery("#taxaFixa").val("0,00");
                        jQuery("#taxaDesembaraco").val("0,00");
                        jQuery("#tarifaEspecifica").val("0");
                        jQuery("#valorFrete").val(parseFloat(json.freteMinimo));
                        valorFrete = parseFloat(json.freteMinimo);
                    }else{
                        jQuery("#valorFixo").val(colocarVirgula(valorFixo));
                        jQuery("#freteNacional").val(colocarVirgula(freteNacional));
                        jQuery("#vlAWBCalculado").val(colocarVirgula(somados));
                        jQuery("#advalorem").val(colocarVirgula(advalorem));
                        jQuery("#taxaEntrega").val(colocarVirgula(taxaEntrega));
                        jQuery("#taxaColeta").val(colocarVirgula(taxaColeta));
                        jQuery("#taxaCapatazia").val(colocarVirgula(taxaCapatazia));
                        jQuery("#taxaFixa").val(colocarVirgula(taxaFixa));
                        jQuery("#taxaDesembaraco").val(colocarVirgula(taxaDesembaraco));
                        jQuery("#tarifaEspecifica").val(tarifaEspecifica);

                        // jQuery("#valorFrete").val(somados);
                        valorFrete = somados;
                    }

                    var aliq = parseFloat(jQuery("#valorIcms").val());
                    jQuery("#valorTotalIcms").val(roundABNT(((valorFrete/100)*aliq),2));
                }
//                Abaixo é um exemplo de como deve vir:
//                {"id":12,"valorExcedente":12.0,"valorFixo":12.0,"tarifaEspecifica":12.0,
//                "taxaColeta":14.0,"taxaEntrega":14.0,"taxaCapatazia":14.0,"taxaFixa":14.0,
//                "taxaDesembaraco":45.0,"percentualSeguro":45.0,"freteMinimo":5000.0,"isExcluido":false}
            }, error: function () {
                alert("Erro inesperado, favor refazer a operação.");
            }
        });

    });

});

/***
 * 
 * @param {type} peso
 * @param {type} valorPeso
 * @param {type} tipoValor
 * @returns se o tipoValor for k fará a multiplicação de peso*valor, se for f será o valor fixo.
 */
function getValorFrete(peso, valorPeso, tipoValor){
    if (tipoValor === 'k') {
        return peso * valorPeso;
    }else{
        return valorPeso;
    }
}


function carregarOcorrencias(zebra) {
    //objeto funcao usado na requisicao Ajax(uma espécie de evento)
    function e(transport) {
        var textoresposta = transport.responseText;
        espereEnviar("", false);
        //se deu algum erro na requisicao...
        if (textoresposta == "-1") {
            alert('Houve algum problema ao requistar as ocorrências, favor informar manualmente.');
            return false;
        } else {

            for (i = 0; i <= textoresposta.split('!!000!!').length - 1; ++i) {

                ocor = textoresposta.split('!!000!!')[i];
                addOcorrencia(ocor.split('!!999!!')[12], ocor.split('!!999!!')[0], ocor.split('!!999!!')[1],
                        ocor.split('!!999!!')[2], ocor.split('!!999!!')[3], ocor.split('!!999!!')[4],
                        ocor.split('!!999!!')[5], ocor.split('!!999!!')[6],
                        (ocor.split('!!999!!')[7] == 'f' ? false : true), ocor.split('!!999!!')[8],
                        ocor.split('!!999!!')[9], ocor.split('!!999!!')[10], ocor.split('!!999!!')[11]);
            }
        }
    }//funcao e()
    espereEnviar("", true);
    $('mostrar').style.display = "none";
    zebraAux = zebra;
    var id = $('id').value;
    tryRequestToServer(function () {
        new Ajax.Request("./cadmanifesto?acao=carregarOcorrencia&manifestoId=" + id,
                {method: 'post', onSuccess: e, onError: e});
    });
}

//--------------------------- Ocorrência -------------------------------- fim

function slcTpDestino() {
    var tipo = $("tipoDestino").value;
    if (tipo == "fl") {
        $("inp_fl").style.display = "";
        $("inp_rd").style.display = "none";
    } else {
        $("inp_fl").style.display = "none";
        $("inp_rd").style.display = "";
    }
}

function limpaRedespachante() {
    $("idredespachante").value = "0";
    $("redspt_rzs").value = "";
}


function recalcula() {
    if ($("segurroubo").value == "" || $("segurtomb").value == "")
        alert("Informe a taxa de seguro corretamente.");
    else {
        $("vlsegurroubo").value = formatoMoeda(parseFloat($("total_notas").innerHTML) * parseFloat($("segurroubo").value) / 100);
        $("vlsegurtomb").value = formatoMoeda(parseFloat($("total_notas").innerHTML) * parseFloat($("segurtomb").value) / 100);
        $("totalsegur").value = formatoMoeda(parseFloat($("vlsegurtomb").value) + parseFloat($("vlsegurroubo").value));
    }
}

function voltar() {
    tryRequestToServer(function () {
        document.location.replace("ConsultaControlador?codTela=28")
    });
}

function calculaAwb(isAlteraBase) {
    $('total_prestacao').value = formatoMoeda(parseFloat($('frete_peso').value) + parseFloat($('frete_valor').value) +
            parseFloat($('taxa_emergencia').value) + parseFloat($('taxa_transportador').value) +
            parseFloat($('taxa_entrega').value));
    if (isAlteraBase) {
        $('base_calculo').value = $('total_prestacao').value;
    }

    $('perc_icms').value = formatoMoeda(parseFloat($('base_calculo').value) * parseFloat($('aliquota_icms').value) / 100);
}

var newOptions = {
    'Selecione' : -1,
    'Conferente' : 0,
    'Arrumador' : 1,
    'Ajudante' : 2
};

function Fornecedor(id, fornecedorId, fornecedorNome, fornecedorTipo){
    if (id === null || id === undefined ? this.id = 0 : this.id = id);
    if (fornecedorId === null || fornecedorId === undefined ? this.fornecedorId = 0 : this.fornecedorId = fornecedorId);
    if (fornecedorNome === null || fornecedorNome === undefined ? this.fornecedorNome = "" : this.fornecedorNome = fornecedorNome);
    if (fornecedorTipo === null || fornecedorTipo === undefined ? this.fornecedorTipo = -1 : this.fornecedorTipo = fornecedorTipo);
}

function povoarSelectFornecedor(select){
    if(select.prop) {
        var options = select.prop('options');
    }
    else {
        var options = select.attr('options');
    }
    jQuery.each(newOptions, function(valOp, textOp) {
        select.append(jQuery('<option>', {value:textOp, text:valOp}));
    });
}


var countFuncionario = 0;
function addFuncionario(funcionario) {
    try {
        if (funcionario == null || funcionario == undefined) {
            funcionario = new Fornecedor();
        }

        var index = "";

        if (index == "") {

            var classe = "CelulaZebra2NoAlign";
            var callRemoverFuncionario = "removerFuncionario(" + countFuncionario + ");"
            var _tr = Builder.node("tr", {id: "trFuncionario_" + countFuncionario, className: classe});
            var _tdRemove = Builder.node("td", {id: "tdFuncionarioRemove_" + countFuncionario, align: "center"});
            var _tdFuncionarioNome = Builder.node("td", {id: "tdFuncionarioNome_" + countFuncionario});
            var _tdFuncionarioTipo = Builder.node("td", {id: "tdFuncionarioTipo_" + countFuncionario});
            var _td4 = Builder.node("td");

            var _inpId = Builder.node("input", {
                id: "idFuncionarioManifesto_" + countFuncionario,
                name: "idFuncionarioManifesto_" + countFuncionario,
                type: "hidden",
                className: "inputTexto",
                value: funcionario.id
            });
            var _inpIdFornecedor = Builder.node("input", {
                id: "idFuncionario_" + countFuncionario,
                name: "idFuncionario_" + countFuncionario,
                type: "hidden",
                className: "inputTexto",
                value: funcionario.fornecedorId
            });
            var _inpImg = Builder.node("img", {
                id: "imgFuncionarioRemove_" + countFuncionario,
                name: "imgFuncionarioRemove_" + countFuncionario,
                src: "img/lixo.png",
                onclick: callRemoverFuncionario
            });
            var _inpNome = Builder.node("input", {
                id: "nomeFuncionario_" + countFuncionario,
                name: "nomeFuncionario_" + countFuncionario,
                type: "text",
                size: "50",
                maxLength: "100",
                className: "inputReadOnly",
                readOnly: "true",
                value: funcionario.fornecedorNome
            });
            var _inpRemovido = Builder.node("input", {
                id: "isRemovido_" + countFuncionario,
                name: "isRemovido_" + countFuncionario,
                type:"hidden",
                value: 'false'
            });

            var _inpLocalizaFuncionario = Builder.node("input", {
                id: "localizaFuncionario_" + countFuncionario,
                name: "localizaFuncionario_" + countFuncionario,
                type: "button",
                class: "inputBotaoMin",
                value: "...",
                onClick: "abrirLocalizarFuncionario(" + countFuncionario + ");"
            });
            
            _tdRemove.appendChild(_inpId);
            _tdRemove.appendChild(_inpIdFornecedor);
            _tdRemove.appendChild(_inpRemovido);
            _tdRemove.appendChild(_inpImg);
            _tdFuncionarioNome.appendChild(_inpNome);
            _tdFuncionarioNome.appendChild(_inpLocalizaFuncionario);
            _tr.appendChild(_tdRemove);
            _tr.appendChild(_tdFuncionarioNome);
            _tr.appendChild(_tdFuncionarioTipo);
            $("fornecedores").appendChild(_tr);
            
            
            var select = jQuery("<select class='inputtexto'>")
                .attr("id","tipoFuncionario_"+countFuncionario)
                .attr("name","tipoFuncionario_"+countFuncionario);
            povoarSelectFornecedor(select);
            select.val(funcionario.fornecedorTipo);
            jQuery("#tdFuncionarioTipo_" + countFuncionario).append(select);

            $("qtdFuncionario").value = countFuncionario;
        } else {
            $("idFuncionario_" + index).value = funcionario.idfornecedor;
            $("nomeFuncionario_" + index).value = funcionario.nome;
        }
            countFuncionario++;

    } catch (ex) {
        alert(ex);
    }
}

function abrirLocalizarFuncionario(index) {
    if ($("index_funcionario") != null) {
        $("index_funcionario").value = index;
    }

    if ($("tipoFuncionario_" + index).value == 2) {
        launchPopupLocate('./localiza?acao=consultar&idlista=25', 'Ajudante');
    } else if ($("tipoFuncionario_" + index).value == 1  || $("tipoFuncionario_" + index).value == 0) {
        launchPopupLocate('./localiza?acao=consultar&idlista=93', 'Funcionario');
    }  else{
        alert("Selecione um Tipo de Funcionário!");
    }
}

function removerFuncionario(index){
    if(confirm("Deseja remover o funcionário " + jQuery("#nomeFuncionario_"+index).val())){
        jQuery("#isRemovido_"+index).val('true');
        jQuery("#trFuncionario_"+index).hide();
    }
}

function validarSelects(){
   var retorno = true;
   jQuery("select[id^='tipoFuncionario_'] option:selected").each(function(e,v){
        if(this.value === '-1' && (jQuery("#isRemovido_"+e).val() === 'false')){
            alert('Selecione o tipo do Funcionário '+ jQuery("#nomeFuncionario_"+e).val());
            retorno = false;
        }
    });
    return retorno;
}

function validarPrevisaoChegada(){
    var retorno = true;
    var dtprevista = $("dtprevista").value;
    var dtsaida = $("dtsaida").value;
    var hrprevista = $("hrprevista").value;
    var hrsaida = $("hrsaida").value;

    var arrDataPrevista = dtprevista.split('/');
    var arrDataSaida = dtsaida.split('/');

    var stringFormatada1 = arrDataPrevista[1] + '-' + arrDataPrevista[0] + '-' + arrDataPrevista[2];
    var stringFormatada2 = arrDataSaida[1] + '-' + arrDataSaida[0] + '-' + arrDataSaida[2];
    var dataFormatada1 = new Date(stringFormatada1);
    var dataFormatada2 = new Date(stringFormatada2);

    hrprevista = hrprevista.split(":");
    hrsaida = hrsaida.split(":");

    var d = new Date();
    var hr1 = new Date(d.getFullYear(), d.getMonth(), d.getDate(), hrprevista[0], hrprevista[1]);
    var hr2 = new Date(d.getFullYear(), d.getMonth(), d.getDate(), hrsaida[0], hrsaida[1]);

    if(dtprevista !== undefined && dtprevista !== ''){
        if(dataFormatada1 < dataFormatada2) {
            alert('A data de Previsão de Chegada não pode ser anterior à Data de Saída!');
            retorno = false;
        }else if(dataFormatada1 >= dataFormatada2){
            if(hr1 < hr2) {
                alert('A hora da Previsão de Chegada não pode ser anterior à Hora de Saída!');
                retorno = false;
            }
        }
    }
    return retorno;
}