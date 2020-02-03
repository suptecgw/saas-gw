function CTeManifesto(idCTe, emissao, numeroCTe, remetente, destinatario, cidadeOrigem, cidadeDestino, volume, volumeReal, peso, pesoReal, notaFiscal, frete, isGeraPinSuframa, idCTeManifesto, serie, novoRegistro,idCidadeDestino){
            this.idCTe = (idCTe == undefined || idCTe == null ? 0 : idCTe);
            this.emissao = (emissao == undefined || emissao == null ? '<%=Apoio.getDataAtual()%>' : emissao);
            this.numeroCTe = (numeroCTe == undefined || numeroCTe == null ? 0 : numeroCTe);
            this.remetente = (remetente == undefined || remetente == null ? '' : remetente);
            this.destinatario = (destinatario == undefined || destinatario == null ? '' : destinatario);
            this.cidadeOrigem = (cidadeOrigem == undefined || cidadeOrigem == null ? '' : cidadeOrigem);
            this.cidadeDestino = (cidadeDestino == undefined || cidadeDestino == null ? '' : cidadeDestino);
            this.volume = (volume == undefined || volume == null ? 0 : volume);
            this.volumeReal = (volumeReal == undefined || volumeReal == null ? 0 : volumeReal);
            this.peso = (peso == undefined || peso == null ? 0 : peso);
            this.pesoReal = (pesoReal == undefined || pesoReal == null ? 0 : pesoReal);
            this.notaFiscal = (notaFiscal == undefined || notaFiscal == null ? 0 : notaFiscal);
            this.frete = (frete == undefined || frete == null ? 0 : frete);
            this.isGeraPinSuframa = (isGeraPinSuframa == undefined || isGeraPinSuframa == null ? false : isGeraPinSuframa);
            this.idCTeManifesto = (idCTeManifesto == undefined || idCTeManifesto == null ? 0 : idCTeManifesto);
            this.serie = (serie == undefined || serie == null ? 1 : serie);
            this.novoRegistro = (novoRegistro == undefined || serie == null ? false : novoRegistro);
            this.idCidadeDestino = (idCidadeDestino == undefined || idCidadeDestino == null ? 0 : idCidadeDestino);
            
        }
       
        
        
        var  listaIdsCidadeDestino=[];
        function listaCidadesDestinoCte(numeroCte,nomeCidadeDestino,idCidadeDestino){
            console.log("A: "+numeroCte);
            console.log("AB: "+nomeCidadeDestino);
            console.log("ABC: "+idCidadeDestino);
            listaIdsCidadeDestino.push({
                'numero_cte':numeroCte,
                'nome_cidade':nomeCidadeDestino, 
                'id_cidade': idCidadeDestino
            });
        }
        
        function listaCidadesAtendidasAeroporto(){
            var cidadesAtendidasAero = [];
            cidadesAtendidasAero = $("cidades_atendidas_id").value.split(",").map(item => parseInt(item));
            return cidadesAtendidasAero;
        }
        

        function comparaCidCtesCidAeroAtendida(){
            if($("tipo_movimento").value == "a"){
               var aeroportoDestino = $("aeroportoEntrega").value;
               var aeroporto= listaCidadesAtendidasAeroporto();
               var cidadeNaoAtendidas = listaIdsCidadeDestino.filter(item => !aeroporto.includes(item['id_cidade']))
                       .map(item => item['numero_cte'])
                       .join(', ');
                //Mostrando msg para usuário.
                if(aeroportoDestino !="" && cidadeNaoAtendidas.length > 0){
                    confirm("Os Ct-e(s): "+cidadeNaoAtendidas+ " estão destinados a uma cidade não atendida pelo aeroporto "+ aeroportoDestino);
                }
            }
        }
        
        
        var countCTeManifesto = 0;
        function addCTeManifesto(cteManifesto, tabela){
            

            try{
                if (cteManifesto == null || cteManifesto == undefined) {
                    cteManifesto = new CTeManifesto();
                }
                var celulaZebra = ((countCTeManifesto % 2) == 0 ? 'CelulaZebra2' : 'CelulaZebra1');
                
                var _trCTeManifesto = Builder.node("tr",{id:"trCTeManifesto_"+ countCTeManifesto, className:celulaZebra});
                var _tdEmissao = Builder.node("td",{id:"tdEmissao_"+ countCTeManifesto, align: "center"});
                var _tdNumeroCTe = Builder.node("td",{id:"tdNumeroCTe_"+ countCTeManifesto, align: "center"});
                var _tdRemetente = Builder.node("td",{id:"tdRemetente_"+ countCTeManifesto, align: "center"});
                var _tdCidadeOrigem = Builder.node("td",{id:"tdCidadeOrigem_"+ countCTeManifesto, align: "center"});
                var _tdDestinatario = Builder.node("td",{id:"tdDestinatario_"+ countCTeManifesto, align: "center"});
                var _tdCidadeDestino = Builder.node("td",{id:"tdCidadeDestino_"+ countCTeManifesto, align: "center"});
                var _tdVolume = Builder.node("td",{id:"tdVolume_"+ countCTeManifesto, align: "center"});
                var _tdVolumeReal = Builder.node("td",{id:"tdVolumeReal_"+ countCTeManifesto, align: "center"});
                var _tdPeso = Builder.node("td",{id:"tdPeso_"+ countCTeManifesto, align: "center"});
                var _tdPesoReal = Builder.node("td",{id:"tdPesoReal_"+ countCTeManifesto, align: "center"});
                var _tdNotaFiscal = Builder.node("td",{id:"tdNotaFiscal_"+ countCTeManifesto, align: "center"});
                var _tdFrete = Builder.node("td",{id:"tdFrete_"+ countCTeManifesto, align: "center"});
                var _tdPin = Builder.node("td",{id:"tdPin_"+ countCTeManifesto, align: "center"});
                
                
                var _lblEmissao = Builder.node("label", {
                    id: "emissao_"+ countCTeManifesto, 
                    name: "emissao_"+countCTeManifesto
                });                
                _lblEmissao.innerHTML = cteManifesto.emissao;
                
                var _inpHidIdCTe = Builder.node("input", {
                    id: "idCTe_"+ countCTeManifesto, 
                    name: "idCTe_"+countCTeManifesto,
                    type: 'hidden',
                    value: cteManifesto.idCTe
                });
                
                var _inpHidIdCTeManif = Builder.node("input", {
                    id: "idCTeManif_"+ countCTeManifesto, 
                    name: "idCTeManif_"+countCTeManifesto,
                    type: 'hidden',
                    value: cteManifesto.idCTeManifesto
                });
                
                var _inpHidNumeroCTe = Builder.node("input", {
                    id: "numeroCTe_"+ countCTeManifesto, 
                    name: "numeroCTe_"+countCTeManifesto,
                    type: 'hidden',
                    value: cteManifesto.numeroCTe
                });              
                
                var _inpHidSerieCTe = Builder.node("input", {
                    id: "serieCTe_"+ countCTeManifesto, 
                    name: "serieCTe_"+countCTeManifesto,
                    type: 'hidden',
                    value: cteManifesto.serie
                });
                var _inpHidNovoRegis = Builder.node("input", {
                    id: "novoRegistro_"+ countCTeManifesto, 
                    name: "novoRegistro_"+countCTeManifesto,
                    type: 'hidden',
                    value: cteManifesto.novoRegistro
                });
                
                var _bCTe = Builder.node("b",{
                    
                });
                
                var _linkCTe = Builder.node("a",{
                    href: 'javascript:tryRequestToServer(function(){verCtrc('+cteManifesto.idCTe+');});'
                });
                _linkCTe.innerHTML = cteManifesto.numeroCTe;
                
                var _lblRemetente = Builder.node("label", {
                    id: "remetente_"+ countCTeManifesto, 
                    name: "remetente_"+countCTeManifesto 
                });                
                _lblRemetente.innerHTML = cteManifesto.remetente;
                
                var _lblDestinatario = Builder.node("label", {
                    id: "destinatario_"+ countCTeManifesto, 
                    name: "destinatario_"+countCTeManifesto 
                });
                _lblDestinatario.innerHTML = cteManifesto.destinatario;
                
                var _lblCidadeOrigem = Builder.node("label", {
                    id: "cidadeOrigem_"+ countCTeManifesto, 
                    name: "cidadeOrigem_"+countCTeManifesto 
                });
                _lblCidadeOrigem.innerHTML = cteManifesto.cidadeOrigem;
                
                var _lblCidadeDestino = Builder.node("label", {
                    id: "cidadeDestino_"+ countCTeManifesto, 
                    name: "cidadeDestino_"+countCTeManifesto 
                });
                _lblCidadeDestino.innerHTML = cteManifesto.cidadeDestino;
                
                var _inpHidIdCidadeDestino= Builder.node("input", {
                    id: "idCidadeDestino_"+ countCTeManifesto, 
                    name: "idCidadeDestino_"+countCTeManifesto,
                    type: 'hidden',
                    value: cteManifesto.idCidadeDestino
                });
                var _divVolume = Builder.node("div",{
                    align:"right"
                });
                
                var _lblVolume = Builder.node("label", {
                    id: "volume_"+ countCTeManifesto, 
                    name: "volume_"+countCTeManifesto
                });
                _lblVolume.innerHTML = cteManifesto.volume;
                
                var _divVolumeReal = Builder.node("div",{
                   align:"right" 
                });
                
                var _inpVolumeReal = Builder.node("input", {
                    id: "volumeReal_"+ countCTeManifesto, 
                    name: "volumeReal_"+countCTeManifesto,
                    type: "text",
                    className: "inputTexto",
                    onblur:"seNaoFloatReset(this, '0.00'), calcularVolumeReal()",
                    size:"6",
                    style:"text-align: right",
                    value: cteManifesto.volumeReal
                });
                
                var _inpHidPeso = Builder.node("input", {
                    id: "peso_"+ countCTeManifesto, 
                    name: "peso_"+countCTeManifesto ,
                    type:"hidden",
                    value: cteManifesto.peso
                });
                
                var _divPeso = Builder.node("div",{
                   align:"right" 
                });
                
                var _lblPeso = Builder.node("label", {
                    id: "pesoLbl_"+ countCTeManifesto, 
                    name: "pesoLbl_"+countCTeManifesto
                });                
                _lblPeso.innerHTML = cteManifesto.peso;
                
                var _divPesoReal = Builder.node("div",{
                   align:"right" 
                });
                
                var _inpPesoReal = Builder.node("input", {
                    id: "pesoReal_"+ countCTeManifesto, 
                    name: "pesoReal_"+countCTeManifesto ,
                    type: "text",
                    className: "inputTexto",
                    onblur:"seNaoFloatReset(this, '0.00'), calcularPesoReal()",
                    size:"6",
                    style:"text-align: right",
                    value: cteManifesto.pesoReal
                });
                
                var _inpHidNotaFiscal = Builder.node("input", {
                    id: "notaFiscal_"+ countCTeManifesto, 
                    name: "notaFiscal_"+countCTeManifesto,
                    type: "hidden",
                    value: cteManifesto.notaFiscal
                });
                
                var _divNotaFiscal = Builder.node("div",{
                   align:"right" 
                });
                
                var _lblNotaFiscal = Builder.node("label", {
                    id: "notaFiscalLbl_"+ countCTeManifesto, 
                    name: "notaFiscalLbl_"+countCTeManifesto
                });
                _lblNotaFiscal.innerHTML = cteManifesto.notaFiscal;
                
                var _divFrete = Builder.node("div",{
                   align:"right" 
                });
                
                var _lblFrete = Builder.node("label", {
                    id: "frete_"+ countCTeManifesto, 
                    name: "frete_"+countCTeManifesto                                        
                });
                _lblFrete.innerHTML = cteManifesto.frete;
                
                var _divPin = Builder.node("div",{
                    align: "center"
                });
                
                var _inpPin = Builder.node("input",{
                   id:"isPin_"+countCTeManifesto, 
                   name:"isPin_"+countCTeManifesto, 
                   type:"checkbox",
                   value:"checkbox",
                   alt:"Gerar PIN para o SUFRAMA ",
                   style:"display: none"
                });
                if (cteManifesto.isGeraPinSuframa == true) {
                    _inpPin.style.display = "";
                    validacaoPIN();
                    _inpPin.checked = true;
                }
                
               
                
                _tdEmissao.appendChild(_lblEmissao);
                _tdNumeroCTe.appendChild(_inpHidIdCTe);
                _tdNumeroCTe.appendChild(_inpHidIdCTeManif);
                _tdNumeroCTe.appendChild(_inpHidNumeroCTe);
                _tdNumeroCTe.appendChild(_inpHidSerieCTe);
                _tdNumeroCTe.appendChild(_inpHidNovoRegis);
                _bCTe.appendChild(_linkCTe)
                _tdNumeroCTe.appendChild(_bCTe);
                _tdRemetente.appendChild(_lblRemetente);
                _tdCidadeOrigem.appendChild(_lblCidadeOrigem);
                _tdDestinatario.appendChild(_lblDestinatario);
                _tdCidadeDestino.appendChild(_lblCidadeDestino);
                _tdCidadeDestino.appendChild(_inpHidIdCidadeDestino);
                _divVolume.appendChild(_lblVolume);
                _tdVolume.appendChild(_divVolume);
                _divVolumeReal.appendChild(_inpVolumeReal);
                _tdVolumeReal.appendChild(_divVolumeReal);
                _divPeso.appendChild(_lblPeso);
                _tdPeso.appendChild(_divPeso);
                _tdPeso.appendChild(_inpHidPeso);
                _divPesoReal.appendChild(_inpPesoReal);
                _tdPesoReal.appendChild(_divPesoReal);
                _divNotaFiscal.appendChild(_lblNotaFiscal);
                _tdNotaFiscal.appendChild(_divNotaFiscal);
                _tdNotaFiscal.appendChild(_inpHidNotaFiscal);
                _divFrete.appendChild(_lblFrete)
                _tdFrete.appendChild(_divFrete);
                _divPin.appendChild(_inpPin);
                _tdPin.appendChild(_divPin);
                
                _trCTeManifesto.appendChild(_tdEmissao);
                _trCTeManifesto.appendChild(_tdNumeroCTe);
                _trCTeManifesto.appendChild(_tdRemetente);
                _trCTeManifesto.appendChild(_tdCidadeOrigem);
                _trCTeManifesto.appendChild(_tdDestinatario);
                _trCTeManifesto.appendChild(_tdCidadeDestino);
                _trCTeManifesto.appendChild(_tdVolume);
                _trCTeManifesto.appendChild(_tdVolumeReal);
                _trCTeManifesto.appendChild(_tdPeso);
                _trCTeManifesto.appendChild(_tdPesoReal);
                _trCTeManifesto.appendChild(_tdNotaFiscal);
                _trCTeManifesto.appendChild(_tdFrete);
                _trCTeManifesto.appendChild(_tdPin);
                
                tabela.appendChild(_trCTeManifesto);
                visivel(tabela);
                countCTeManifesto++;
                $("qtdLinhasCTe").value = countCTeManifesto;
                listaCidadesDestinoCte(cteManifesto.numeroCTe,cteManifesto.cidadeDestino,cteManifesto.idCidadeDestino);
                
//                < %//Calcular os totais quando não for um carregar
//                  if(!carregamanif){% >//
//                    calcularQtdTotais();
//                    calcularVolume();
//                    calcularVolumeReal();
//                    calcularPeso();
//                    calcularPesoReal();
//                    calcularNotaFiscal();
//                    calcularFrete();
//                < %//}%>

            }catch(e){
                console.log(e);
            }
        }


function ativarAverbacaoManual() {
    if ($("chkProtocoloAverbacao").checked === true) {
        notReadOnly($("protocoloAverbacao"));
    } else {
        readOnly($("protocoloAverbacao"));
    }
}

//----------------------- condutores------------------------------------- inicio
function condutorAdicional(id, idCondutor, nomeMotorista, incluido, protocolo, averbado, protocoloAverbacao, motivo) {
    this.id = (id !== undefined && id != null ? id : 0);
    this.idCondutor = (idCondutor !== undefined && idCondutor != null ? idCondutor : 0);
    this.nomeMotorista = (nomeMotorista !== undefined && nomeMotorista != null ? nomeMotorista : "");
    this.incluido = (incluido !== undefined && incluido != null ? incluido : "");
    this.protocolo = (protocolo !== undefined && protocolo != null ? protocolo : "");
    this.averbado = (averbado !== undefined && averbado != null ? averbado : false);
    this.protocoloAverbacao = (protocoloAverbacao !== undefined && protocoloAverbacao != null ? protocoloAverbacao : "");
    this.motivo = (motivo !== undefined && motivo != null ? motivo : "");
}

function addCondutoresAdicionais(condutoresAdicionais) {
    $("trCondutores").style.display = "";
    if (condutoresAdicionais == null || condutoresAdicionais === undefined) {
        condutoresAdicionais = new condutorAdicional();
    }

    countCondutoresAdicionais++;

    var tr_ = Builder.node("tr", {
        id: "trMotorista_" + countCondutoresAdicionais,
        name: "trMotorista_" + countCondutoresAdicionais,
        className: "CelulaZebra2",
        align: "center"
    });

    var tdImagemExcluir = Builder.node("td", {
        align: "center"
    });

    var tdMotorista = Builder.node("td", {
        align: "left"
    });
    var tdSefaz = Builder.node("td", {
        align: "center",
        colspan: "1"
    });
    var tdAverbacao = Builder.node("td", {
        align: "center"
    });

    var imagemExcluir = Builder.node("img", {
        src: "img/lixo.png",
        title: "Excluir motorista",
        className: "imagemLink",
        onclick: "excluirCondutoresAdicionais(" + countCondutoresAdicionais + "," + condutoresAdicionais.id + ");"
    });

    var inputHiddenIdMotorista = Builder.node("input", {
        id: "idMotorista_" + countCondutoresAdicionais,
        name: "idMotorista_" + countCondutoresAdicionais,
        type: "hidden",
        value: condutoresAdicionais.idCondutor

    });

    var inputHiddenId = Builder.node("input", {
        id: "id_" + countCondutoresAdicionais,
        name: "id_" + countCondutoresAdicionais,
        type: "hidden",
        value: condutoresAdicionais.id

    });

    var inputMotorista = Builder.node("input", {
        type: "text",
        className: "inputReadOnly",
        id: "nomeMotorista_" + countCondutoresAdicionais,
        name: "nomeMotorista_" + countCondutoresAdicionais,
        size: "30",
        maxlength: "40",
        readOnly: "true",
        value: condutoresAdicionais.nomeMotorista

    });

    var pesquisarMotorista = Builder.node("input", {
        type: "button",
        className: "inputBotaoMin",
        id: "botaoMotorista_" + countCondutoresAdicionais,
        name: "botaoMotorista_" + countCondutoresAdicionais,
        onclick: "abrirLocalizarMotorista(" + countCondutoresAdicionais + ");",
        value: "..."

    });

    var xml = Builder.node("img", {
        name: "botaoEnviar",
        id: "botaoEnviar",
        type: "button",
        className: "imagemLink",
        title: "Imprimir XML Cliente",
        onclick: "imprimirXML(" + countCondutoresAdicionais + ", " + condutoresAdicionais.protocolo + ")",
        value: "Imprimir xml",
        src: "img/xml.png"
    });

    var imagemEnviar = Builder.node("input", {
        name: "botaoEnviar",
        id: "botaoEnviar",
        type: "button",
        className: "inputbotao",
        onclick: "enviarCondutor(" + countCondutoresAdicionais + ");",
        value: "Enviar para Sefaz"
    });

    //POVOANDO AS TD'S
    if (condutoresAdicionais.incluido !== "true") {
        tdImagemExcluir.appendChild(imagemExcluir);
    }
    tdMotorista.appendChild(inputHiddenIdMotorista);
    tdMotorista.appendChild(inputHiddenId);
    tdMotorista.appendChild(inputMotorista);
    tdMotorista.appendChild(pesquisarMotorista);

    if (condutoresAdicionais.incluido === "true") {
        tdSefaz.appendChild(xml);

        // Averbação aqui
        if (mostrarAverbacao) {
            var tdAverbacaoJQuery = jQuery(tdAverbacao);

            var conteudoDiv = jQuery('<label>')
                .append('Alteração Averbada: ')
                .append(jQuery('<strong>')
                    .text(condutoresAdicionais.averbado === 'true' ? 'Sim' : 'Não')
                );

            if (condutoresAdicionais.averbado === 'true') {
                conteudoDiv.append('&nbsp;'.repeat(4)).append('Protocolo: ').append(jQuery('<span>').text(condutoresAdicionais.protocoloAverbacao))
            } else {
                conteudoDiv.append('&nbsp;'.repeat(4)).append('Motivo: ').append(jQuery('<span>').text(condutoresAdicionais.motivo));
                conteudoDiv.append('&nbsp;'.repeat(4)).append(jQuery('<strong>', {
                    'class': 'averbarMDFe linkEditar',
                    'data-manifesto-id': manifestoId,
                    'data-manifesto-numero': manifestoNumero,
                    'data-filial-id': manifestoFilial
                }).text('Averbar manualmente'))
            }
            var divAverbacao = jQuery('<div>', {
                'class': 'trAverbacao',
                'align': 'left'
            }).append(conteudoDiv);

            tdAverbacaoJQuery.append(divAverbacao);
        }
    } else if (condutoresAdicionais.id !== 0) {
        tdSefaz.appendChild(imagemEnviar);
    }

    //POVOANDO AS TR'S
    tr_.appendChild(tdImagemExcluir);
    tr_.appendChild(tdMotorista);
    tr_.appendChild(tdSefaz);
    tr_.appendChild(tdAverbacao);

    $("tbCondutores").appendChild(tr_);
    $("maxCondutores").value = countCondutoresAdicionais;
}

function excluirCondutoresAdicionais(excluirIndex, id) {
    if (confirm("Deseja excluir este condutor?")) {
        Element.remove('trMotorista_' + excluirIndex);
        if (confirm("Tem certeza?")) {
            new Ajax.Request("./cadmanifesto?acao=excluirCondutor&id_=" + id,
                {
                    method: 'post',
                    onSuccess: function () {
                        alert('Condutor removido com sucesso!')
                    },
                    onFailure: function () {
                        alert('Something went wrong...')
                    }
                });
        }
    }

}

function enviarCondutor(index) {
    var manifestoID = $("id").value;
    var idmotorista = $("idMotorista_" + index).value;
    var chaveAcesso = $("chaveAcesso").value;

    $("formulario").action = "./MDFeControlador?acao=enviarInclusaoCondutores&manifestoID=" + manifestoID + "&idmotorista=" + idmotorista + "&chaveAcesso=" + chaveAcesso;

    window.open('about:blank', 'pop', 'width=210, height=100');
    $("formulario").submit();

}

function imprimirXML(index, protocolo) {
    var idMotorista = $("idMotorista_" + index).value;
    var idManifesto = $("id").value;
    var chaveAcesso = $("chaveAcesso").value;

    window.open("./" + chaveAcesso + "-mdfe.xml?acao=gerarXmlCondutoresMdfe&idmanifesto=" + idManifesto + "&idmotorista=" + idMotorista + "&protocolo=" + protocolo, "xmlMDFe" + idManifesto, 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
}
// ---------------------------- condutores ----------------------------------fim

jQuery(document).ready(function () {
    var trAverbacao = jQuery('#trCondutores');

    trAverbacao.on('click', '.averbarMDFe', function () {
        var elemento = jQuery(this);

        var manifestoNumero = elemento.attr('data-manifesto-numero');
        var manifestoId = elemento.attr('data-manifesto-id');
        var filialId = elemento.attr('data-filial-id');

        chamarConfirm('Tem certeza de que deseja averbar manualmente o manifesto: ' + manifestoNumero + '?', 'averbarMDFeSim("' + manifestoId + '", "' + filialId + '")');
    });

    trAverbacao.on('click', '.consultarProtocoloAverbacao', function() {
        var elemento = jQuery(this);

        var protocolo = elemento.attr('data-protocolo');

        chamarAlert('Protocolo de averbação: ' + protocolo);
    })
});

function averbarMDFeSim(manifestoId, filialId) {
    jQuery('.bloqueio-tela').show();
    jQuery('.bloqueio-enviando-averbacao').show();

    jQuery.post(homePath + '/MDFeControlador', {
        'acao': 'averbarMDFe',
        'manifestoId': manifestoId,
        'filialId': filialId
    }, function (data) {
        jQuery('.bloqueio-tela').hide();
        jQuery('.bloqueio-enviando-averbacao').hide();

        chamarAlert(data, function() {
            window.location.reload(true);
        });
    });
}

function ItemIsca(idmovimentacao, data_saida, data_chegada, numero_isca){
    this.idmovimentacao = (idmovimentacao != undefined && idmovimentacao != null ? idmovimentacao : 0);
    this.data_saida = (data_saida != undefined ? data_saida : $("dtsaida").value);
    this.data_chegada = (data_chegada != undefined && data_chegada != 'null'  ? data_chegada : "");
    this.numero_isca = (numero_isca != undefined  ? numero_isca : "");
}

function addIscas(itensIscas){
    $("trIscas").style.display = "";
    try{
        if (itensIscas == null || itensIscas == undefined){
            itensIscas = new ItemIsca();
        }

        countItensIscas++;
        //var homePath = $("homePath").value;
        var tabelaBase = $("tbIscas");

        var tr =  Builder.node("tr" , {
            className:"CelulaZebra2",
            id:"idLinhaIscas_" + countItensIscas
        });

        var td0 = Builder.node("td" , {
            align: "center"
        });
        var img0 = Builder.node("img",{
            className:"imagemLink",
            src: "img/lixo.png",
            onClick:"excluirIscas("+ itensIscas.idmovimentacao + "," + countItensIscas +");"

        });

        td0.appendChild(img0);

        var td1 = Builder.node("td" , {
            align :"center"

        });

        var td2 = Builder.node("td" , {
            align :"center"

        });

        var td3 = Builder.node("td" , {
            align :"center"

        });



        var inpId = Builder.node("input" , {
            type  : "hidden" ,
            name  : "idIsca_" + countItensIscas ,
            id    : "idIsca_" + countItensIscas ,
            value : "0"
        });

        var inpMovId = Builder.node("input" , {
            type  : "hidden" ,
            name  : "idMovimentacaoIsca_" + countItensIscas ,
            id    : "idMovimentacaoIsca_" + countItensIscas ,
            value : itensIscas.idmovimentacao
        });

        var inp1 = Builder.node("input" , {
            id : "idIscaInput_" + countItensIscas ,
            name : "idIscaInput_" + countItensIscas ,
            className:"inputtexto",
            type  : "text" ,
            size  : "20",
            maxLength : "10",
            value : itensIscas.numero_isca
        });

        readOnly(inp1);

        var inp2 = Builder.node("input" , {
            id : "data_isca_saida_" + countItensIscas ,
            name : "data_isca_saida_" + countItensIscas ,
            className:"fieldDateMin",
            type  : "text" ,
            size  : "12",
            onBlur: "alertInvalidDate(this,true)",
            maxLength : "10" ,
            value : itensIscas.data_saida
        });

        readOnly(inp2)

        var text6 = Builder.node ("input", {
            id : "data_isca_chegada_" + countItensIscas ,
            name : "data_isca_chegada_" + countItensIscas ,
            className:"fieldDateMin",
            type  : "text" ,
            size  : "12",
            onBlur: "alertInvalidDate(this,true);validarDataChegada("+countItensIscas+")",
            maxLength : "10",
            value : itensIscas.data_chegada
        });


        td1.appendChild(inpId);
        td1.appendChild(inpMovId);
        td1.appendChild(inp1);

        td2.appendChild(inp2);

        td3.appendChild(text6);

        tr.appendChild(td0);
        tr.appendChild(td1);
        tr.appendChild(td2);
        tr.appendChild(td3);


        tabelaBase.appendChild(tr);
        $("maxIsca").value = countItensIscas;
        applyFormatter();
    }catch(ex){
        alert(ex);
    }
}

function limparIsca (id){
    $("idIsca_"+ id).value = 0;
    $("idIscaInput_"+ id).value = "";
}

function addNewIsca(){
    var newIndex = $("maxIsca").value;
    localizaIsca(++newIndex,$("numIsca").value);
}

function localizaIsca(index, valor) {
    //objeto funcao usado na requisicao Ajax(uma espécie de evento)
    function e(isca) {
        var resp = JSON.parse(isca.responseText);
        espereEnviar("", false);
        //se deu algum erro na requisicao...
        if(resp["message"] != null){
            alert(resp["message"]);
            $("numIsca").value = "";
            return false;
        }else if (resp['numero_isca'] === null) {
            alert('Isca não Localizada.');
            $("numIsca").value = "";
            return false;
        } else if (!resp["is_ativo"]) {
            alert('Isca inativa.');
            $("numIsca").value = "";
            return false;
        } else {
            if(validarIscas(resp["isca_id"], index)){
                $("numIsca").value = "";
                alert("Isca Encontrada!");
                var item = new ItemIsca(null, null, null, resp["numero_isca"]);
                addIscas(item);
                $('idIsca_' + index).value = resp["isca_id"];
            }
        }
    }//funcao e()

    if (valor != '') {
        espereEnviar("", true);
        tryRequestToServer(function () {
            new Ajax.Request("./MovimentacaoIscasControlador?acao=localizar&valor=" + encodeURIComponent(valor), {
                method: 'get',
                onSuccess: e,
                onError: e
            });
        });
    }
}

function excluirIscas(id, index){
    var idmanif = $("id").value;
    if(confirm("Deseja excluir esta isca?")){
        if(confirm("Tem certeza?")){
            new Ajax.Request("MovimentacaoIscasControlador?acao=excluir&id="+id,
                {
                    method:'get',
                    onSuccess: function(){ alert('Isca removida com sucesso!');
                        $("idLinhaIscas_" + index).style.display = "none";
                        limparIsca(index)},
                    onFailure: function(){ alert('Something went wrong...') }
                });
        }
    }
}

function validarIscas(id, index){
    var max = $("maxIsca").value;
    for (var i = 1; i <= max; i++) {
        if($('idIsca_' + i).value == id && index != i){
            $("numIsca").value = "";
            alert("Esta isca não pode ser selecionada pois já está associada a um manifesto ou romaneio.");
            limparIsca(index);
            return false;
        }
    }
    return true;
}

function validarDataChegada(index) {
    var data_saida = $("data_isca_saida_"+index).value;
    var data_chegada = $("data_isca_chegada_"+index).value;
    if(data_chegada != undefined && data_chegada != null && data_chegada != "") {
        if (data_chegada < data_saida) {
            alert("A data de chegada não pode ser menor que a data de saída");
            $("data_isca_chegada_" + index).value = "";
            return false;
        }
    }
}