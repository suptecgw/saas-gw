function mascaraData(campo, e) {
    var kC = (document.all) ? event.keyCode : e.keyCode;
    var data = campo.value;

    if (kC != 8 && kC != 46) {
        if (data.length == 2) {
            campo.value = data += '/';
        } else if (data.length == 5) {
            campo.value = data += '/';
        } else
            campo.value = data;
    }
}

function digitaestrutura() {

    if (document.all) // Internet Explorer
        var tecla = event.keyCode;
    else if (document.layers) // Nestcape
        var tecla = e.which;
    if (tecla == 57 || tecla == 46) // apenas os dígitos "9" e "."
        return true;
    else
        event.keyCode = 0;
}

function alterarBaixarEmailsEntre(){
        //validar se está ou não marcado para aparecer a TR : trHoraInicioFim
        var elemento = jQuery("#isBaixarApenasEntre");
        if(elemento.prop('checked')){
            jQuery("#trHoraInicioFim").show();
        }else{
            jQuery("#trHoraInicioFim").hide();
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
    var rotina = "configuracao";
    var dataDe = $("dataDeAuditoria").value;
    var dataAte = $("dataAteAuditoria").value;
    var id = "1";
    consultarLog(rotina, id, dataDe, dataAte);

}

function corTema(){
    var tema = document.getElementById('tema');
    var cor = document.getElementById('corTema');
    if(tema.value === '1'){ // azul
        cor.style.backgroundColor = "#0c253e";
    }else if(tema.value === '2'){ // cinza
        cor.style.backgroundColor = "#757575";
    }else if(tema.value === '3'){ // verde
        cor.style.backgroundColor = "#1b5e20";
    }else if(tema.value === '4'){ //marrom
        cor.style.backgroundColor = "#6D4C41";
    }
}




var listaEmailImportacaoXml = new Array();
var countEmail = 0;
var emailImportacaoXml = null;

function localizaplanocomissao() {
    post_cad = window.open('./localiza?acao=consultar&idlista=20', 'planocustocomissao',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
}

function localizaplano() {
    post_cad = window.open('./localiza?acao=consultar&idlista=13', 'planocusto',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
}

function localizacfop() {
    post_cad = window.open('./localiza?acao=consultar&idlista=2', 'CFOP',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
}

function localizacfop2(janela) {
    post_cad = window.open('./localiza?acao=consultar&idlista=15', janela,
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
}

function localizaOcorrenciaRomaneioCTe() {
    post_cad = window.open('./localiza?acao=consultar&idlista=40', 'Ocorrencia_CTe', 'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
}

function localizaOcorrenciaRomaneioColeta() {
    post_cad = window.open('./localiza?acao=consultar&idlista=48', 'Ocorrencia_Coleta', 'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
}

function localizaPlanoViagem(janela) {
    post_cad = window.open('./localiza?acao=consultar&idlista=80', janela, 'top=80,left=150,height=600,width=600,resizable=yes,status=1,scrollbars=1');
}

function salvar() {
    if ($("descontoAutomaticoAbastecimento").checked && $("considerarAbastecimentoApartir").value.trim() == "") {
        return alert("ATENÇÃO: Para descontar automaticamente abastecimentos do GW Frota ao incluir um contrato de frete, o campo(Considerar abastecimentos a partir de) deverá estar preenchido");
    }

    if ($("ctrcsConfirmadosParaManifesto").checked == true && $("cartaFreteAutomatica").checked == true) {
        return alert("ATENÇÃO: Para incluir carta frete automatica ao salvar conhecimento, é necessário que o campo (Ao incluir um manifesto só poderá ser informado CT-e(s) Confirmados) " +
            " ou (Gerar Contrato de Frete Automaticamente ao Incluir um CT-e) esteja desmarcado.");
    }

    if ($("conta_adiantamento_viagem_id").value != "0" && $("contaAdiantamentoFornecedor").value != "0" &&
        $("conta_adiantamento_viagem_id").value == $("contaAdiantamentoFornecedor").value) {
        return alert("A conta padrão de adiantamento de viagens não pode ser igual a de adiantamento de fornecedores.");
    }
    if (jQuery("#quantidadeDiasAvisoBackup").val() > 10) {
        if (!(confirm("ATENÇÃO: o campo de quantidade de dias para avisar que o backup está atrasado está acima dos 10 dias, deseja continuar assim mesmo?"))) {
            return false;
        }
    }

    if ($('chkEnvioEmailAutomaticoVencimentoFatura').checked) {
        if ($('selectEmailVencimentoFatura').value === '0' || $('inpHoraExecucaoEmailVencimentoFatura').value === '') {
            alert('Para ativar a opção "Envio de e-mail para clientes lembrando do vencimento de fatura/boleto", é necessário preencher os campos!');

            return false;
        }
    }

    if (parseInt($("idcfop").value) == 0 || parseInt($("idcfop2_2").value) == 0 || parseInt($("idcfop_industria_dentro").value) == 0 || parseInt($("idcfop_industria_fora").value) == 0 || parseInt($("idcfop_pessoa_fisica_dentro").value) == 0 || parseInt($("idcfop_pessoa_fisica_fora").value) == 0 || parseInt($("idcfop_outro_estado").value) == 0
        || parseInt($("idcfop_outro_estado_fora").value) == 0
        || parseInt($('idcfop_transporte_dentro').value) == 0
        || parseInt($('idcfop_transporte_fora').value) == 0
        || parseInt($('idcfop_prestador_servico_dentro').value) == 0
        || parseInt($('idcfop_prestador_servico_fora').value) == 0
        || parseInt($('idcfop_produtor_rural_dentro').value) == 0
        || parseInt($('idcfop_produtor_rural_fora').value) == 0
        || parseInt($('idcfop_exterior_dentro').value) == 0
        || parseInt($('idcfop_exterior_fora').value) == 0
        || parseInt($('idcfop_subcontratacao_dentro').value) == 0
        || parseInt($('idcfop_subcontratacao_fora').value) == 0
    ) {
        alert("Informe todos os CFOP's!");
    } else if ($("gerar_despesa").checked && ($("plcusto_adiantamento_id").value == 0 || $("idplanocusto_saldo").value == 0)) {
        alert("Fornecedor e/ou plano custo default inválidos.");
    } else if ($("estplano") != null) {
        $("formulario").submit();
    } else {
        alert("Preencha os campos corretamente!");
    }
}

function concatMensEmail(campo, textArea) {
    var x = tinyMCE.get(textArea);
    var texto = x.getContent();
    var textoFinal = "";

    if (texto.length == 0) {
        textoFinal = "<p>" + campo + "</p>";
    } else {

        var arrayTexto = texto.split("</p>");
        for (var i = 0; i <= arrayTexto.length - 2; i++) {

            if (i != (arrayTexto.length - 2)) {
                textoFinal += arrayTexto[i] + "</p>";
                //alert("textoFinal1 "+textoFinal);
            } else {
                textoFinal += arrayTexto[i] + campo + "</p>";
                // alert("textoFinal2 "+textoFinal);
            }
        }
    }
    tinyMCE.get(textArea).setContent(textoFinal);
}

function digitaestrutura() {

    if (document.all) // Internet Explorer
        var tecla = event.keyCode;
    else if (document.layers) // Nestcape
        var tecla = e.which;
    if (tecla == 57 || tecla == 46) // apenas os dígitos "9" e "."
        return true;
    else
        event.keyCode = 0;
}

function aoClicarNoLocaliza(idjanela) {
    try {
        if (idjanela == "Conta_juros_pagos") {
            $("jurospagos_id").value = $("plano_contas_id").value;
            $("jurospagos").value = $("cod_conta").value;
            $("jurospagosDescricao").value = $("plano_conta_descricao").value;
        } else if (idjanela == "Conta_juros_recebidos") {
            $("jurosrecebidos_id").value = $("plano_contas_id").value;
            $("jurosrecebidos").value = $("cod_conta").value;
            $("jurosrecebidosDescricao").value = $("plano_conta_descricao").value;
        } else if (idjanela == "Conta_descontos_concedidos") {
            $("descontosconcedidos_id").value = $("plano_contas_id").value;
            $("descontosconcedidos").value = $("cod_conta").value;
            $("descontosconcedidosDescricao").value = $("plano_conta_descricao").value;
        } else if (idjanela == "Conta_descontos_obtidos") {
            $("descontosobtidos_id").value = $("plano_contas_id").value;
            $("descontosobtidos").value = $("cod_conta").value;
            $("descontosobtidosDescricao").value = $("plano_conta_descricao").value;
        } else if (idjanela == "IRRF_retido") {
            $("irrf_retido_id").value = $("plano_contas_id").value;
            $("irrfRetido").value = $("cod_conta").value;
            $("irrfRetidoDescricao").value = $("plano_conta_descricao").value;
        } else if (idjanela == "INSS_retido") {
            $("inss_retido_id").value = $("plano_contas_id").value;
            $("inssRetido").value = $("cod_conta").value;
            $("inssRetidoDescricao").value = $("plano_conta_descricao").value;
        } else if (idjanela == "ISS_retido") {
            $("iss_retido_id").value = $("plano_contas_id").value;
            $("issRetido").value = $("cod_conta").value;
            $("issRetidoDescricao").value = $("plano_conta_descricao").value;
        } else if (idjanela == "PIS_retido") {
            $("pis_retido_id").value = $("plano_contas_id").value;
            $("pisRetido").value = $("cod_conta").value;
            $("pisRetidoDescricao").value = $("plano_conta_descricao").value;
        } else if (idjanela == "COFINS_retido") {
            $("cofins_retido_id").value = $("plano_contas_id").value;
            $("cofinsRetido").value = $("cod_conta").value;
            $("cofinsRetidoDescricao").value = $("plano_conta_descricao").value;
        } else if (idjanela == "CSSL_retido") {
            $("cssl_retido_id").value = $("plano_contas_id").value;
            $("csslRetido").value = $("cod_conta").value;
            $("csslRetidoDescricao").value = $("plano_conta_descricao").value;
        } else if (idjanela == "Plano_custo_despesa_adiantamento") {
            $("plcusto_adiantamento_id").value = $("idplanocusto_despesa").value;
            $("plcusto_adiantamento").value = $("plcusto_conta_despesa").value
            $('plcusto_adiantamentoDescricao').value = $("plano_conta_descricao").value;
            ;
        } else if (idjanela == "Plano_custo_despesa_saldo") {
            $("idplanocusto_saldo").value = $("idplanocusto_despesa").value;
            $("plcusto_saldo").value = $("plcusto_conta_despesa").value;
            $('plcusto_saldoDescricao').value = $("plano_conta_descricao").value;
        } else if (idjanela == "und_custo_adiantamento") {
            $("und_custo_adiantamento_id").value = $("id_und").value;
            $("und_custo_adiantamento").value = $("sigla_und").value;
        } else if (idjanela == "und_custo_saldo") {
            $("und_custo_saldo_id").value = $("id_und").value;
            $("und_custo_saldo").value = $("sigla_und").value;
        } else if (idjanela == "cfop_industria_dentro_do_estado") {
            $('idcfop_industria_dentro').value = $('idcfop2').value;
            $('desccfop_industria_dentro').value = $('desccfop2').value;
            $('cfop_industria_dentro').value = $('cfop2').value;
        } else if (idjanela == "cfop_industria_fora_do_estado") {
            $('idcfop_industria_fora').value = $('idcfop2').value;
            $('desccfop_industria_fora').value = $('desccfop2').value;
            $('cfop_industria_fora').value = $('cfop2').value;
        } else if (idjanela == "cfop_de_outra_UF") {
            $('idcfop_outro_estado').value = $('idcfop2').value;
            $('desccfop_outro_estado').value = $('desccfop2').value;
            $('cfop_outro_estado').value = $('cfop2').value;
        } else if (idjanela == "cfop_de_outra_UF_fora") {
            $('idcfop_outro_estado_fora').value = $('idcfop2').value;
            $('desccfop_outro_estado_fora').value = $('desccfop2').value;
            $('cfop_outro_estado_fora').value = $('cfop2').value;
        } else if (idjanela == "cfop_nota_servico") {
            $('idcfop_nota_servico').value = $('idcfop2').value;
            $('desccfop_nota_servico').value = $('desccfop2').value;
            $('cfop_nota_servico').value = $('cfop2').value;
        } else if (idjanela == "cfop_pessoa_fisica_dentro_do_estado") {
            $('idcfop_pessoa_fisica_dentro').value = $('idcfop2').value;
            $('desccfop_pessoa_fisica_dentro').value = $('desccfop2').value;
            $('cfop_pessoa_fisica_dentro').value = $('cfop2').value;
        } else if (idjanela == "cfop_pessoa_fisica_fora_do_estado") {
            $('idcfop_pessoa_fisica_fora').value = $('idcfop2').value;
            $('desccfop_pessoa_fisica_fora').value = $('desccfop2').value;
            $('cfop_pessoa_fisica_fora').value = $('cfop2').value;
        } else if (idjanela == "CFOP_fora_do_estado") {
            $('idcfop2_2').value = $('idcfop2').value;
            $('desccfop2_2').value = $('desccfop2').value;
            $('cfop2_2').value = $('cfop2').value;
        } else if (idjanela == "cfop_transporte_dentro") {
            $('idcfop_transporte_dentro').value = $('idcfop2').value;
            $('desccfop_transporte_dentro').value = $('desccfop2').value;
            $('cfop_transporte_dentro').value = $('cfop2').value;
        } else if (idjanela == "cfop_transporte_fora") {
            $('idcfop_transporte_fora').value = $('idcfop2').value;
            $('desccfop_transporte_fora').value = $('desccfop2').value;
            $('cfop_transporte_fora').value = $('cfop2').value;
        } else if (idjanela == "cfop_prestador_servico_dentro") {
            $('idcfop_prestador_servico_dentro').value = $('idcfop2').value;
            $('desccfop_prestador_servico_dentro').value = $('desccfop2').value;
            $('cfop_prestador_servico_dentro').value = $('cfop2').value;
        } else if (idjanela == "cfop_prestador_servico_fora") {
            $('idcfop_prestador_servico_fora').value = $('idcfop2').value;
            $('desccfop_prestador_servico_fora').value = $('desccfop2').value;
            $('cfop_prestador_servico_fora').value = $('cfop2').value;
        } else if (idjanela == "cfop_produtor_rural_dentro") {
            $('idcfop_produtor_rural_dentro').value = $('idcfop2').value;
            $('desccfop_produtor_rural_dentro').value = $('desccfop2').value;
            $('cfop_produtor_rural_dentro').value = $('cfop2').value;
        } else if (idjanela == "cfop_produtor_rural_fora") {
            $('idcfop_produtor_rural_fora').value = $('idcfop2').value;
            $('desccfop_produtor_rural_fora').value = $('desccfop2').value;
            $('cfop_produtor_rural_fora').value = $('cfop2').value;
        } else if (idjanela == "cfop_exterior_dentro") {
            $('idcfop_exterior_dentro').value = $('idcfop2').value;
            $('desccfop_exterior_dentro').value = $('desccfop2').value;
            $('cfop_exterior_dentro').value = $('cfop2').value;
        } else if (idjanela == "cfop_exterior_fora") {
            $('idcfop_exterior_fora').value = $('idcfop2').value;
            $('desccfop_exterior_fora').value = $('desccfop2').value;
            $('cfop_exterior_fora').value = $('cfop2').value;
        } else if (idjanela == "Conta_Padrao_Cliente") {
            $('contaClienteId').value = $('plano_contas_id').value;
            $('contaCliente').value = $('cod_conta').value;
            $('contaClienteDescricao').value = $("plano_conta_descricao").value;
        } else if (idjanela == "Conta_Padrao_Fornecedor") {
            $('contaFornecedorId').value = $('plano_contas_id').value;
            $('contaFornecedor').value = $('cod_conta').value;
            $('contaFornecedorDescricao').value = $("plano_conta_descricao").value;
        } else if (idjanela == "Conta_Padrao_Proprietario") {
            $('contaProprietarioId').value = $('plano_contas_id').value;
            $('contaProprietario').value = $('cod_conta').value;
            $('contaProprietarioDescricao').value = $("plano_conta_descricao").value;
        } else if (idjanela == "planocustocomissao") {
            $('contaComissaoMotoristaId').value = $('idplanocusto_despesa').value;
            $('plcusto_comissao').value = $('plcusto_conta_despesa').value;
            $('plcusto_descricao_comissao').value = $('plcusto_descricao_despesa').value;
        } else if (idjanela == "planocusto") {
            $('idplanocustolancamento').value = $('idplanocusto').value;
            $('plcusto_conta_lancamento').value = $('plcusto_conta').value;
            $('plcusto_descricao_lancamento').value = $('plcusto_descricao').value;
        } else if (idjanela == "cfop_subcontratacao_dentro_do_estado") {
            $('idcfop_subcontratacao_dentro').value = $('idcfop2').value;
            $('desccfop_subcontratacao_dentro').value = $('desccfop2').value;
            $('cfop_subcontratacao_dentro').value = $('cfop2').value;
        } else if (idjanela == "cfop_subcontratacao_fora_do_estado") {
            $('idcfop_subcontratacao_fora').value = $('idcfop2').value;
            $('desccfop_subcontratacao_fora').value = $('desccfop2').value;
            $('cfop_subcontratacao_fora').value = $('cfop2').value;
        } else if (idjanela == "plano_custo_diaria_motorista") {
            $('idContaPadraoMotoristaDiaria').value = $('idplano_custo_viagem').value;
            $('contaPadraoMotoristaDiaria').value = $('plano_custo_viagem').value;
            $('descricaoPadraoMotoristaDiaria').value = $('plano_custo_viagem_descricao').value;
        } else if (idjanela == "plano_custo_diaria_ajudante") {
            $('idContaPadraoAjudanteDiaria').value = $('idplano_custo_viagem').value;
            $('contaPadraoAjudanteDiaria').value = $('plano_custo_viagem').value;
            $('descricaoPadraoAjudanteDiaria').value = $('plano_custo_viagem_descricao').value;
        } else if (idjanela == "plano_custo_pernoite_motorista") {
            $('idContaPadraoMotoristaPernoite').value = $('idplano_custo_viagem').value;
            $('contaPadraoMotoristaPernoite').value = $('plano_custo_viagem').value;
            $('descricaoPadraoMotoristaPernoite').value = $('plano_custo_viagem_descricao').value;
        } else if (idjanela == "plano_custo_pernoite_ajudante") {
            $('idContaPadraoAjudantePernoite').value = $('idplano_custo_viagem').value;
            $('contaPadraoAjudantePernoite').value = $('plano_custo_viagem').value;
            $('descricaoPadraoAjudantePernoite').value = $('plano_custo_viagem_descricao').value;
        } else if (idjanela == "plano_custo_alimentacao_motorista") {
            $('idContaPadraoMotoristaAlimentacao').value = $('idplano_custo_viagem').value;
            $('contaPadraoMotoristaAlimentacao').value = $('plano_custo_viagem').value;
            $('descricaoPadraoMotoristaAlimentacao').value = $('plano_custo_viagem_descricao').value;
        } else if (idjanela == "plano_custo_alimentacao_ajudante") {
            $('idContaPadraoAjudanteAlimentacao').value = $('idplano_custo_viagem').value;
            $('contaPadraoAjudanteAlimentacao').value = $('plano_custo_viagem').value;
            $('descricaoPadraoAjudanteAlimentacao').value = $('plano_custo_viagem_descricao').value;
        } else if (idjanela == "Plano_custo_despesa_pedagio") {
            $('plcusto_pedagio').value = $('plcusto_conta_despesa').value;
            $('idPlanoCustoPedagio').value = $('idplanocusto_despesa').value;
        } else if (idjanela == "Ocorrencia_CTe") {
            $("ocorrenciaRomaneioCTe").value = $("ocorrencia").value;
            $("idOcorrenciaRomaneioCTe").value = $("ocorrencia_id").value;
        } else if (idjanela == "Ocorrencia_Coleta") {
            $("ocorrenciaRomaneioColeta").value = $("ocorrencia").value;
            $("idOcorrenciaRomaneioColeta").value = $("ocorrencia_id").value;
        } else if (idjanela === 'Fornecedor_ADV_Mobile') {
            
        }
    } catch (e) {
        alert(e)
    }
}

function alterarPreferenciaEmail(valor) {

    if (valor == 'b') {
        $('trPreferenciaEmail').style.display = "";
        $('lblQtdEmailLotes').style.display = "";
    } else if (valor == 'a') {
        $('trPreferenciaEmail').style.display = "none";
        $('lblQtdEmailLotes').style.display = "none";
        $('chkEnviarEmailApenasEntre').checked = false;
        $('chkEnviarEmailApenasEntre').value = false;
    }

}

function validacaoBaixarDespesaAposConfirmarCIOT(campoClicado) {
    //função para validação dos campos de baixar despesa so com confirmação do CIOT e baixar adiantamento;
    if (campoClicado == 'baixarDespesa') { // se o campo clicado for o de baixar despesa;
        if (!$("baixaAdiantamentoCarta").checked) { // se o campo de baixaradiantamento estiver desmarcado, ou seja, estava marcado e cliquei para desmarcar;
            alert("Só será possivel habilitar a função 'Só baixar após a confirmação do CIOT ', " +
                "se a função 'Baixar Despesa Automaticamente ao Incluir Adiantamento nas Formas de Pagamento Dinheiro, Cheque, Depósito Bancário ou Transferência Bancária. ' também estiver habilitada");
            $("baixarDespesaAposConfirmacaoCIOT").checked = false; // se o campo de baixaradiantamento for desmarcado, também desmarcar o de baixar automaticamente;
        }
    } else if (campoClicado == 'baixarAdiantamento') { // se o campo clicado for o de baixar adiantamento;
        if (!$("baixaAdiantamentoCarta").checked) { // se o campo baixar adiantamento estiver desmarcado, ou seja, estava marcado e clicou para desmarcar;
            $("baixarDespesaAposConfirmacaoCIOT").checked = false; // se desmarcar o campo de baixar adiantamento tambem desmarcara o campo de baixar despesa;
        }
    }

}

function carregarImagem() {
    jQuery('input[type=file]').each(function (index) {
        if (jQuery('input[type=file]').eq(index).val() != "") {
            readURL(this);
            jQuery('#LOGO_IMG').show();
        }
    });
    salvarImg();
    jQuery("#nomeImagem").val(jQuery("#carregarImg").val().split("\\").pop());
}

function readURL(input) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function (e) {
            jQuery(input).next()
                .attr('src', e.target.result)
        };
        reader.readAsDataURL(input.files[0]);
    }
    else {
        var img = input.value;
    }
}

function salvarImg() {
    var carregarImg = $("carregarImg").value;

    if (carregarImg == "") {
        alert("Selecione a Imagem!");
        return false;
    }

    var extensoesOk = ",.gif,.jpg,.pdf,.xml,.png,";

    var extensao = "," + carregarImg.substr(carregarImg.length - 4).toLowerCase() + ",";
    if (extensoesOk.indexOf(extensao) == -1) {
        document.getElementById('carregarImg').value = '';
        document.getElementById('nomeImagem').value = '';
        document.getElementById('LOGO_IMG').style.display = 'none';
        return alert("Extensão de Arquivo de imagem Inválida!.");
    }

    $("formImagem").action = "./config?acao=salvarImg"
    console.log("chega em salvarImg");
    $("formImagem").target = "pop";
    $("formImagem").method = "post";

    window.open('about:blank', 'pop', 'width=400, height=300');
    document.getElementById("formImagem").submit();
}

function copiarParaFormPrincipal(valor, idCampo) {
    jQuery("#" + idCampo).val(valor);
}

function liberarAutorizacaoPadraoRomaneio() {
    if ($("romaneioAutorizacaoPagamento").checked) {
        $("divRomaneioAutorizacaoPadrao").style.display = "";
    } else {
        $("divRomaneioAutorizacaoPadrao").style.display = "none";
    }
}


// parte de funções de baixa de email (INICIO)
function alterarQuantidadeMinutosBaixarEmails(elemento) {
    //validar se é menor que 15;
    if (isNaN(elemento.value)) {
        alert("Valor digitado deve ser numerico.");
        elemento.value = 0;
    }
    var valorInteiro = parseInt(elemento.value);
    if (valorInteiro < 15) {
        alert("Valor digitado deve ser maior que 15.");
        elemento.value = 0;
    }
}

function alterarBaixarEmailsEntre() {
    //validar se está ou não marcado para aparecer a TR : trHoraInicioFim
    var elemento = jQuery("#isBaixarApenasEntre");
    if (elemento.prop('checked')) {
        jQuery("#trHoraInicioFim").show();
    } else {
        jQuery("#trHoraInicioFim").hide();
    }
}

function alterarAtivarRecebimentoEmails() {
    // validar se está ou não marcado para aparecer os campos labelMinutosBaixarEmails e MinutosBaixarEmails
    var elemento = jQuery("#isAtivarRecebimento");
    if (elemento.prop('checked')) {
        jQuery("#minutosBaixarEmails").show();
        jQuery("#labelMinutosBaixarEmails").show();
    } else {
        jQuery("#minutosBaixarEmails").hide();
        jQuery("#labelMinutosBaixarEmails").hide();
    }
}

// parte de funções de baixa de email (FIM)

function EmailImportacaoXml(id, idConfig, idEmail) {
    this.id = (id != null && id != undefined ? id : 0);
    this.idConfig = (idConfig != null && idConfig != undefined ? idConfig : $("idConfig").value);
    this.idEmail = (idEmail != null && idEmail != undefined ? idEmail : idEmail);
}

var countEmailImportacaoXml = 0;

function addEmailImportacaoXml(listaEmailImportacaoXml, emailImportacaoXml) {

    if (emailImportacaoXml == null || emailImportacaoXml == undefined) {
        emailImportacaoXml = new EmailImportacaoXml();
    }

    var qtdEmail = listaEmailImportacaoXml.length - 1;

    if (qtdEmail == countEmailImportacaoXml) {
        alert("Atenção: Não exite mais email(s) para adicionar!");
        return false;
    }

    countEmailImportacaoXml++;

    var classe = (countEmailImportacaoXml % 2 == 1 ? "CelulaZebra1NoAlign" : "CelulaZebra2NoAlign");
    var tabela = $("tbEmailImportacaoXml");

    var _trPrincipal = Builder.node("tr", {id: "trPrincipal_" + countEmailImportacaoXml, className: "tabela"});
    var _tdExcluir = Builder.node("td", {
        id: "tdExcluir_" + countEmailImportacaoXml,
        className: classe,
        align: "center"
    });
    var _tdEmail = Builder.node("td", {id: "tdEmail_" + countEmailImportacaoXml, className: classe});

    var _slcEmail = Builder.node("select", {
        id: "slcEmail_" + countEmailImportacaoXml,
        name: "slcEmail_" + countEmailImportacaoXml,
        className: "inputtexto",
        style: "width:200px"
    });

    var _inpExcluirEmail = Builder.node("img", {
        id: "inpExcluirEmail_" + countEmailImportacaoXml,
        name: "inpExcluirEmail_" + countEmailImportacaoXml,
        type: "button",
        className: "imagemLink",
        src: "img/lixo.png",
        onclick: "javascript:tryRequestToServer(function(){excluirEmailImportacaoXml(" + countEmailImportacaoXml + ")});"
    });

    var _inpHidIdEmailImportacaoXml = Builder.node("input", {
        id: "inpIdEmailImportacaoXml_" + countEmailImportacaoXml,
        name: "inpIdEmailImportacaoXml_" + countEmailImportacaoXml,
        type: "hidden",
        value: emailImportacaoXml.id
    });

    var _inpHidIdConfig = Builder.node("input", {
        id: "inpIdConfig_" + countEmailImportacaoXml,
        name: "inpIdConfig_" + countEmailImportacaoXml,
        type: "hidden",
        value: emailImportacaoXml.idConfig
    });

    povoarSelect(_slcEmail, listaEmailImportacaoXml);

    _tdExcluir.appendChild(_inpExcluirEmail);
    _tdExcluir.appendChild(_inpHidIdEmailImportacaoXml);
    _tdExcluir.appendChild(_inpHidIdConfig);
    _tdEmail.appendChild(_slcEmail);

    _trPrincipal.appendChild(_tdExcluir);
    _trPrincipal.appendChild(_tdEmail);
    tabela.appendChild(_trPrincipal);

    if (emailImportacaoXml.id > 0) {
        $("slcEmail_" + countEmailImportacaoXml).value = emailImportacaoXml.idEmail;
    }

    $("maxEmailImportacaoXml").value = countEmailImportacaoXml;
}

function excluirEmailImportacaoXml(index) {
    var idEmailImportacaoXml = $("inpIdEmailImportacaoXml_" + index).value;
    jQuery.ajax({
        url: "./config?",
        dataType: "text",
        method: "post",
        async: false,
        data: {
            idEmailImportacaoXml: idEmailImportacaoXml,
            acao: "excluirEmailImportacaoXml"
        },
        success: function (data) {
            Element.remove("trPrincipal_" + index);
            alert("Email importação xml excluído com sucesso.");
        }, error: function () {
            alert("Erro ao excluir o email importação xml.");
        }
    });
}


function localizarContaContabil(elementoCodigo, elementoId, elementoDescricao) {
    var campo = elementoCodigo.name;
    var conta = elementoCodigo.value;
    jQuery.ajax({
        url: "./PlanoContaControlador?",
        dataType: "text",
        method: "post",
        async: false,
        data: {
            conta: conta,
            acao: "localizarContaContabil"
        },
        success: function (data) {
            var conta = jQuery.parseJSON(data);
            espereEnviar("", false);
            if (conta == null) {
                alert("Plano de contas não encontrado!");
                return false;
            } else if (conta == '') {
                alert("Plano de contas não encontrado!");
                return false;
            } else if (conta.erro == 'true') {
                alert("Plano de contas não encontrado!");
                return false;
            } else {
                elementoId.value = conta.id;
                elementoCodigo.value = conta.codigo;
                elementoDescricao.value = conta.descricao;
            }
        }, error: function () {
            alert("Erro inesperado, favor refazer a operação.");
        }
    });
}

function localizaFornecedorPadraoAdvMobile() {
    post_cad = window.open('./localiza?acao=consultar&idlista=21&suffix=_adv', 'Fornecedor_ADV_Mobile', 'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
}

function limparFornecedorPadraoAdvMobile() {
    getObj('idfornecedor_adv').value = 0;
    getObj('fornecedor_adv').value = '';
}