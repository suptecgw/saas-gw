jQuery.noConflict();

let countImagemCte = 0;

let chavesAdicionadas = [];

let mensagemErros = '';

class ImagemCte {
    constructor(idImagem, imagem, numeroCte, idFilial, filial, emissao, chaveAcessoCte, numeroNFs,
                idRemetente, remetente, cidadeOrigem, ufOrigem, idCidadeOrigem, idDestinatario,
                cidadeDestino, ufDestino, idCidadeDestino, destinatario, idConsignatario, consignatario,
                descricaoImagem, isBaixaEntrega, dataEntrega, horaEntrega, dataComprovante, horaComprovante, idOcorrencia, codigoOcorrencia, descricaoOcorrencia,
                obsEntrega, nomeArquivo, idCte, msgErro, baixaEm, chegadaEm, chegadaAs, entregaAs, valorAvaria,
                inicioDescarregoEm, inicioDescarregoAs, cobrouDescarrego, fimDescarregoEm, fimDescarregoAs) {
        this.idImagem = (idImagem != undefined || idImagem != null ? idImagem : 0);
        this.imagem = (imagem != undefined || imagem != null ? imagem : 0);
        this.numeroCte = (numeroCte != undefined || numeroCte != null ? numeroCte : 0);
        this.idFilial = (idFilial != undefined || idFilial != null ? numeroCte : 0);
        this.filial = (filial != undefined || filial != null ? filial : "");
        this.emissao = (emissao != undefined || emissao != null ? emissao : dataAtual);
        this.chaveAcessoCte = (chaveAcessoCte != undefined || chaveAcessoCte != null ? chaveAcessoCte : 0);
        this.numeroNFs = (numeroNFs != undefined || numeroNFs != null ? numeroNFs : 0);
        this.idRemetente = (idRemetente != undefined || idRemetente != null ? idRemetente : 0);
        this.remetente = (remetente != undefined || remetente != null ? remetente : "");
        this.cidadeOrigem = (cidadeOrigem != undefined || cidadeOrigem != null ? cidadeOrigem : "");
        this.ufOrigem = (ufOrigem != undefined || ufOrigem != null ? ufOrigem : "");
        this.idCidadeOrigem = (idCidadeOrigem != undefined || idCidadeOrigem != null ? idCidadeOrigem : 0);
        this.idDestinatario = (idDestinatario != undefined || idDestinatario != null ? idDestinatario : 0);
        this.cidadeDestino = (cidadeDestino != undefined || cidadeDestino != null ? cidadeDestino : "");
        this.ufDestino = (ufDestino != undefined || ufDestino != null ? ufDestino : "");
        this.idCidadeDestino = (idCidadeDestino != undefined || idCidadeDestino != null ? idCidadeDestino : 0);
        this.destinatario = (destinatario != undefined || destinatario != null ? destinatario : "");
        this.idConsignatario = (idConsignatario != undefined || idConsignatario != null ? idConsignatario : 0);
        this.consignatario = (consignatario != undefined || consignatario != null ? consignatario : "");
        this.dataEntrega = (dataEntrega != undefined || dataEntrega != null ? dataEntrega : dataAtual);
        this.horaEntrega = (horaEntrega != undefined || horaEntrega != null ? horaEntrega : horaAtual);
        this.dataComprovante = (dataComprovante != undefined || dataComprovante != null ? dataComprovante : dataAtual);
        this.horaComprovante = (horaComprovante != undefined || horaComprovante != null ? horaComprovante : horaAtual);
        this.idOcorrencia = (idOcorrencia != undefined || idOcorrencia != null ? idOcorrencia : 0);
        this.codigoOcorrencia = (codigoOcorrencia != undefined || codigoOcorrencia != null ? codigoOcorrencia : "");
        this.descricaoOcorrencia = (descricaoOcorrencia != undefined || descricaoOcorrencia != null ? descricaoOcorrencia : "");
        this.nomeArquivo = (nomeArquivo != undefined || nomeArquivo != null ? nomeArquivo : "");
        this.idCte = (idCte != undefined || idCte != null ? idCte : 0);
        this.msgErro = (msgErro != undefined || msgErro != null ? msgErro : "");
        this.baixaEm = (baixaEm != undefined || baixaEm != null ? baixaEm : "");
        this.chegadaEm = (chegadaEm != undefined || chegadaEm != null ? chegadaEm : "");
        this.chegadaAs = (chegadaAs != undefined || chegadaAs != null ? chegadaAs : "");
        this.entregaAs = (entregaAs != undefined || entregaAs != null ? entregaAs : "");
        this.valorAvaria = (valorAvaria != undefined || valorAvaria != null ? valorAvaria : "");
        this.inicioDescarregoEm = (inicioDescarregoEm != undefined || inicioDescarregoEm != null ? inicioDescarregoEm : "");
        this.inicioDescarregoAs = (inicioDescarregoAs != undefined || inicioDescarregoAs != null ? inicioDescarregoAs : "");
        this.cobrouDescarrego = (cobrouDescarrego != undefined || cobrouDescarrego != null ? cobrouDescarrego : "");
        this.fimDescarregoEm = (fimDescarregoEm != undefined || fimDescarregoEm != null ? fimDescarregoEm : "");
        this.fimDescarregoAs = (fimDescarregoAs != undefined || fimDescarregoAs != null ? fimDescarregoAs : "");
    }
}

function addImagemCte(imagemCte, modelo) {
    if (modelo === 'chaveAcessoCTe' && imagemCte.chaveAcessoCte) {
        if (chavesAdicionadas.includes(imagemCte.chaveAcessoCte)) {
            return;
        }

        chavesAdicionadas.push(imagemCte.chaveAcessoCte);
    }

    let table = $("tbImagemCte");

    if (imagemCte === undefined || imagemCte === null) {
        imagemCte = new ImagemCte();
    }

    countImagemCte++;
    let classe = ((countImagemCte % 2) === 0 ? 'CelulaZebra1NoAlign' : 'CelulaZebra2NoAlign');

    //###############TR#####################        
    let _trNumeroCte = Builder.node("tr", {
        id: "trNumeroCte_" + countImagemCte,
        name: "trNumeroCte_" + countImagemCte,
        className: classe
    });
    let _trChaveAcessoCte = Builder.node("tr", {
        id: "trChaveAcessoCte_" + countImagemCte,
        name: "trChaveAcessoCte_" + countImagemCte,
        className: classe
    });
    let _trNumeroNfs = Builder.node("tr", {
        id: "trNumeroNfs_" + countImagemCte,
        name: "trNumeroNfs_" + countImagemCte,
        className: classe
    });
    let _trRemetente = Builder.node("tr", {
        id: "trRemetente_" + countImagemCte,
        name: "trRemetente_" + countImagemCte,
        className: classe
    });
    let _trDestinatario = Builder.node("tr", {
        id: "trDestinatario_" + countImagemCte,
        name: "trDestinatario_" + countImagemCte,
        className: classe
    });
    let _trConsignatario = Builder.node("tr", {
        id: "trConsignatario_" + countImagemCte,
        name: "trConsignatario_" + countImagemCte,
        className: classe
    });
    let _trDescricaoImagem = Builder.node("tr", {
        id: "trDescricaoImagem_" + countImagemCte,
        name: "trDescricaoImagem_" + countImagemCte,
        className: classe
    });
    let _trEntrega = Builder.node("tr", {
        id: "trEntrega_" + countImagemCte,
        name: "trEntrega_" + countImagemCte,
        className: classe
    });
    let _trComprovante = Builder.node("tr", {
        id: "trComprovante_" + countImagemCte,
        name: "trComprovante_" + countImagemCte,
        className: classe
    });
    let _trObsEntrega = Builder.node("tr", {
        id: "trObsEntrega_" + countImagemCte,
        name: "trObsEntrega_" + countImagemCte,
        className: classe
    });
    let _trMsgErro = Builder.node("tr", {
        id: "trMsgErro_" + countImagemCte,
        name: "trMsgErro_" + countImagemCte,
        className: classe
    });

    //###############TR#####################

    //###############LABEL#####################
    let _lblCte = Builder.node("label", {id: "lblCte_" + countImagemCte, name: "lblCte_" + countImagemCte});
    _lblCte.innerHTML = "CT-e:"

    let _lblFilial = Builder.node("label", {id: "lblFilial_" + countImagemCte, name: "lblFilial_" + countImagemCte});
    _lblFilial.innerHTML = "Filial:"

    let _lblEmissao = Builder.node("label", {id: "lblEmissao_" + countImagemCte, name: "lblEmissao_" + countImagemCte});
    _lblEmissao.innerHTML = "Emissão:"

    let _lblChaveAcessoCte = Builder.node("label", {
        id: "lblChaveAcessoCte_" + countImagemCte,
        name: "lblChaveAcessoCte_" + countImagemCte
    });
    _lblChaveAcessoCte.innerHTML = "Chave CT-e:";

    let _lblNumeroNfs = Builder.node("label", {
        id: "lblNumeroNfs_" + countImagemCte,
        name: "lblNumeroNfs_" + countImagemCte
    });
    _lblNumeroNfs.innerHTML = "NF(s):";

    let _lblRemetente = Builder.node("label", {
        id: "lblRemetente_" + countImagemCte,
        name: "lblRemetente_" + countImagemCte
    });
    _lblRemetente.innerHTML = "Remetente:";

    let _lblOrigem = Builder.node("label", {id: "lblOrigem_" + countImagemCte, name: "lblOrigem_" + countImagemCte});
    _lblOrigem.innerHTML = "Origem:"

    let _lblOrigemEspaco = Builder.node("label", {
        id: "lblOrigemEspaco_" + countImagemCte,
        name: "lblOrigemEspaco_" + countImagemCte
    });
    _lblOrigemEspaco.innerHTML = "&nbsp;&nbsp;";

    let _lblDestinatario = Builder.node("label", {
        id: "lblDestinatario_" + countImagemCte,
        name: "lblDestinatario_" + countImagemCte
    });
    _lblDestinatario.innerHTML = "Destinatário:";

    let _lblDestino = Builder.node("label", {id: "lblDestino_" + countImagemCte, name: "lblDestino_" + countImagemCte});
    _lblDestino.innerHTML = "Destino:";

    let _lblDestinoEspaco = Builder.node("label", {
        id: "lblDestinoEspaco_" + countImagemCte,
        name: "lblDestinoEspaco_" + countImagemCte
    });
    _lblDestinoEspaco.innerHTML = "&nbsp;&nbsp;";

    let _lblConsignatario = Builder.node("label", {
        id: "lblConsignatario_" + countImagemCte,
        name: "lblConsignatario_" + countImagemCte
    });
    _lblConsignatario.innerHTML = "Consignatário:";

    let _lblDescricaoImagem = Builder.node("label", {
        id: "lblDescricaoImagem_" + countImagemCte,
        name: "lblDescricaoImagem_" + countImagemCte
    });
    _lblDescricaoImagem.innerHTML = "Descrição Imagem:";

    let _lblImagemDescricao = Builder.node("label", {
        id: "lblImagemDescricao_" + countImagemCte,
        name: "lblImagemDescricao_" + countImagemCte
    });
    _lblImagemDescricao.innerHTML = "Descrição Imagem";

    let _lblBaixarEntrega = Builder.node("label", {
        id: "lblBaixarEntrega_" + countImagemCte,
        name: "lblBaixarEntrega_" + countImagemCte
    });
    _lblBaixarEntrega.innerHTML = "Baixar Entrega";

    let _lblComprovanteEntrega = Builder.node("label", {
        id: "lblComprovanteEntrega_" + countImagemCte,
        name: "lblComprovanteEntrega_" + countImagemCte
    });
    _lblComprovanteEntrega.innerHTML = "Baixar Comprovante";

    let _lblDataEntrega = Builder.node("label", {
        id: "lblDataEntrega_" + countImagemCte,
        name: "lblDataEntrega_" + countImagemCte
    });
    _lblDataEntrega.innerHTML = "Data Entrega:";

    let _lblHoraEntrega = Builder.node("label", {
        id: "lblHoraEntrega_" + countImagemCte,
        name: "lblHoraEntrega_" + countImagemCte
    });
    _lblHoraEntrega.innerHTML = " às ";

    let _lblDataComprovante = Builder.node("label", {
        id: "lblDataComprovante_" + countImagemCte,
        name: "lblDataComprovante_" + countImagemCte
    });
    _lblDataComprovante.innerHTML = "Data Comprovante: ";

    let _lblHoraComprovante = Builder.node("label", {
        id: "lblHoraComprovante_" + countImagemCte,
        name: "lblHoraComprovante_" + countImagemCte
    });
    _lblHoraComprovante.innerHTML = " às ";

    let _lblOcorrencia = Builder.node("label", {
        id: "lblOcorrencia_" + countImagemCte,
        name: "lblOcorrencia_" + countImagemCte
    });
    _lblOcorrencia.innerHTML = "Ocorrência:";

    let _lblOcorrenciaEspacoCodigo = Builder.node("label", {
        id: "lblOcorrenciaEspacoCodigo_" + countImagemCte,
        name: "lblOcorrenciaEspacoCodigo_" + countImagemCte
    });
    _lblOcorrenciaEspacoCodigo.innerHTML = "&nbsp;&nbsp;";

    let _lblOcorrenciaEspaco = Builder.node("label", {
        id: "lblOcorrenciaEspaco_" + countImagemCte,
        name: "lblOcorrenciaEspaco_" + countImagemCte
    });
    _lblOcorrenciaEspaco.innerHTML = "&nbsp;&nbsp;";

    let _lblObsEntrega = Builder.node("label", {
        id: "lblObsEntrega_" + countImagemCte,
        name: "lblObsEntrega_" + countImagemCte
    });
    _lblObsEntrega.innerHTML = "Observação:";

    let _lblVisualizarImagem = Builder.node("label", {
        id: "imgVisualizarImagem_" + countImagemCte,
        name: "imgVisualizarImagem_" + countImagemCte
    });
    _lblVisualizarImagem.innerHTML = "&nbsp;&nbsp;<br/>";

    //###############LABEL#####################

    //###############TD#####################
    let _tdImagem = Builder.node("td", {
        id: "tdImagem_" + countImagemCte,
        name: "tdImagem_" + countImagemCte,
        rowspan: "9",
        width: "20%"
    });
    let _tdLblCte = Builder.node("td", {
        id: "tdLblCte_" + countImagemCte,
        name: "tdLblCte_" + countImagemCte,
        width: "12%"
    });
    let _tdInpCte = Builder.node("td", {
        id: "tdInpCte_" + countImagemCte,
        name: "tdInpCte_" + countImagemCte,
        width: "20%"
    });
    let _tdLblFilial = Builder.node("td", {
        id: "tdLblFilial_" + countImagemCte,
        name: "tdLblFilial_" + countImagemCte,
        width: "10%"
    });
    let _tdInpFilial = Builder.node("td", {
        id: "tdInpFilial_" + countImagemCte,
        name: "tdInpFilial_" + countImagemCte,
        width: "10%"
    });
    let _tdLblEmissao = Builder.node("td", {
        id: "tdLblEmissao_" + countImagemCte,
        name: "tdLblEmissao_" + countImagemCte,
        width: "15%"
    });
    let _tdInpEmissao = Builder.node("td", {
        id: "tdInpEmissao_" + countImagemCte,
        name: "tdInpEmissao_" + countImagemCte,
        width: "15%"
    });
    let _tdLblChaveAcessoCte = Builder.node("td", {
        id: "tdLblChaveAcessoCte_" + countImagemCte,
        name: "tdLblChaveAcessoCte_" + countImagemCte
    });
    let _tdInpChaveAcessoCte = Builder.node("td", {
        id: "tdInpChaveAcessoCte_" + countImagemCte,
        name: "tdInpChaveAcessoCte_" + countImagemCte,
        colspan: "5"
    });
    let _tdLblNumeroNfs = Builder.node("td", {
        id: "tdLblNumeroNfs_" + countImagemCte,
        name: "tdLblNumeroNfs_" + countImagemCte
    });
    let _tdInpNumeroNfs = Builder.node("td", {
        id: "tdInpNumeroNfs_" + countImagemCte,
        name: "tdInpNumeroNfs_" + countImagemCte,
        colspan: "5"
    });
    let _tdLblRemetente = Builder.node("td", {
        id: "tdLblRemetente_" + countImagemCte,
        name: "tdLblRemetente_" + countImagemCte
    });
    let _tdInpRemetente = Builder.node("td", {
        id: "tdInpRemetente_" + countImagemCte,
        name: "tdInpRemetente_" + countImagemCte
    });
    let _tdLblOrigem = Builder.node("td", {id: "tdLblOrigem_" + countImagemCte, name: "tdLblOrigem_" + countImagemCte});
    let _tdInpOrigem = Builder.node("td", {
        id: "tdInpOrigem_" + countImagemCte,
        name: "tdInpOrigem_" + countImagemCte,
        colspan: "3"
    });
    let _tdLblDestinatario = Builder.node("td", {
        id: "tdLblDestinatario_" + countImagemCte,
        name: "tdLblDestinatario_" + countImagemCte
    });
    let _tdInpDestinatario = Builder.node("td", {
        id: "tdInpDestinatario_" + countImagemCte,
        name: "tdInpDestinatario_" + countImagemCte
    });
    let _tdLblDestino = Builder.node("td", {
        id: "tdLblDestino_" + countImagemCte,
        name: "tdLblDestino_" + countImagemCte
    });
    let _tdInpDestino = Builder.node("td", {
        id: "tdInpDestino_" + countImagemCte,
        name: "tdInpDestino_" + countImagemCte,
        colspan: "3"
    });
    let _tdLblConsignatario = Builder.node("td", {
        id: "tdLblConsignatario_" + countImagemCte,
        name: "tdLblConsignatario_" + countImagemCte
    });
    let _tdInpConsignatario = Builder.node("td", {
        id: "tdInpConsignatario_" + countImagemCte,
        name: "tdInpConsignatario_" + countImagemCte,
        colspan: "5"
    });
    let _tdLblDescricaoImagem = Builder.node("td", {
        id: "tdLblDescricaoImagem_" + countImagemCte,
        name: "tdLblDescricaoImagem_" + countImagemCte
    });
    let _tdInpDescricaoImagem = Builder.node("td", {
        id: "tdInpDescricaoImagem_" + countImagemCte,
        name: "tdInpDescricaoImagem_" + countImagemCte,
        colspan: "5"
    });
    let _tdChkBaixarEntrega = Builder.node("td", {
        id: "tdChkBaixarEntrega_" + countImagemCte,
        name: "tdChkBaixarEntrega_" + countImagemCte
    });
    let _tdLblDataEntrega = Builder.node("td", {
        id: "tdLblDataEntrega_" + countImagemCte,
        name: "tdLblDataEntrega_" + countImagemCte
    });
    let _tdInpDataEntrega = Builder.node("td", {
        id: "tdInpDataEntrega_" + countImagemCte,
        name: "tdInpDataEntrega_" + countImagemCte
    });
    let _tdChkComprovanteEntrega = Builder.node("td", {
        id: "tdComprovanteEntrega_" + countImagemCte,
        name: "tdChkComprovanteEntrega_" + countImagemCte
    });
    let _tdLblDataComprovante = Builder.node("td", {
        id: "tdLblDataComprovante_" + countImagemCte,
        name: "tdLblDataComprovante_" + countImagemCte
    });
    let _tdInpDataComprovante = Builder.node("td", {
        id: "tdInpDataComprovante_" + countImagemCte,
        name: "tdInpDataComprovante_" + countImagemCte
    });
    let _tdLblOcorrencia = Builder.node("td", {
        id: "tdLblOcorrencia_" + countImagemCte,
        name: "tdLblOcorrencia_" + countImagemCte
    });
    let _tdInpOcorrencia = Builder.node("td", {
        id: "tdOcorrencia_" + countImagemCte,
        name: "tdInpOcorrencia_" + countImagemCte,
        colspan: "2"
    });
    let _tdLblObsEntrega = Builder.node("td", {
        id: "tdLblObsEntrega_" + countImagemCte,
        name: "tdLblObsEntrega_" + countImagemCte
    });
    let _tdInpObsEntrega = Builder.node("td", {
        id: "tdInpObsEntrega_" + countImagemCte,
        name: "tdInpObsEntrega_" + countImagemCte,
        colspan: "5"
    });
    let _tdLblMsgErro = Builder.node("td", {
        id: "tdLblMsgErro_" + countImagemCte,
        name: "tdLblMsgErro_" + countImagemCte,
        colspan: "7"
    });
    let _tdEmpty = Builder.node("td", {
        class: classe
    });
    let _tdEmpty1 = Builder.node("td", {
        class: classe
    });
    let _tdEmpty2 = Builder.node("td", {
        class: classe
    });
    let _tdEmpty3 = Builder.node("td", {
        class: classe
    });


    //###############TD#####################

    //##############DIV#####################
    let _divLblCte = Builder.node("div", {align: "right"});
    let _divInpCte = Builder.node("div", {align: "left"});
    let _divLblFilial = Builder.node("div", {align: "right"});
    let _divInpFilial = Builder.node("div", {align: "left"});
    let _divLblEmissao = Builder.node("div", {align: "right"});
    let _divInpEmissao = Builder.node("div", {align: "left"});
    let _divLblChaveAcessoCte = Builder.node("div", {align: "right"});
    let _divInpChaveAcessoCte = Builder.node("div", {align: "left"});
    let _divLblNumeroNfs = Builder.node("div", {align: "right"});
    let _divInpNumeroNfs = Builder.node("div", {align: "left"});
    let _divLblRemetente = Builder.node("div", {align: "right"});
    let _divInpRemetente = Builder.node("div", {align: "left"});
    let _divLblOrigem = Builder.node("div", {align: "right"});
    let _divInpOrigem = Builder.node("div", {align: "left"});
    let _divLblDestinatario = Builder.node("div", {align: "right"});
    let _divInpDestinatario = Builder.node("div", {align: "left"});
    let _divLblDestino = Builder.node("div", {align: "right"});
    let _divInpDestino = Builder.node("div", {align: "left"});
    let _divLblConsignatario = Builder.node("div", {align: "right"});
    let _divInpConsignatario = Builder.node("div", {align: "left"});
    let _divLblDescricaoImagem = Builder.node("div", {align: "right"});
    let _divInpDescricaoImagem = Builder.node("div", {align: "left"});
    let _divLblDataEntrega = Builder.node("div", {align: "right"});
    let _divInpDataEntrega = Builder.node("div", {align: "left"});
    let _divLblDataComprovante = Builder.node("div", {align: "right"});
    let _divInpDataComprovante = Builder.node("div", {align: "left"});
    let _divLblOcorrencia = Builder.node("div", {align: "right"});
    let _divInpOcorrencia = Builder.node("div", {align: "left"});
    let _divLblObsEntrega = Builder.node("div", {align: "right"});
    let _divInpObsEntrega = Builder.node("div", {align: "left"});

    //##############DIV#####################

    //##############INPUT###################
    let _inpNumeroCte = Builder.node("input", {
        id: "inpNumeroCte_" + countImagemCte,
        name: "inpNumeroCte_" + countImagemCte,
        type: "text",
        className: "inputReadOnly",
        size: "10",
        readonly: "true",
        value: imagemCte.numeroCte
    });

    let _inpLocalizaCte = Builder.node("input", {
        id: "imgLocalizaCte_" + countImagemCte,
        name: "imgLocalizaCte_" + countImagemCte,
        type: "button",
        className: "inputbotao",
        onclick: "tryRequestToServer(function(){abrirLocalizaCteDom(" + countImagemCte + ");});",
        value: "..."

    });

    let _inpFilial = Builder.node("input", {
        id: "inpFilial_" + countImagemCte,
        name: "inpFilial_" + countImagemCte,
        type: "text",
        size: "10",
        className: "inputReadOnly",
        readonly: "true",
        value: imagemCte.filial

    });

    let _inpEmissao = Builder.node("input", {
        id: "inpEmissao_" + countImagemCte,
        name: "inpEmissao_" + countImagemCte,
        type: "text",
        className: "inputReadOnly",
        readonly: "true",
        size: "10",
        value: imagemCte.emissao
    });

    let _inpChaveAcessoCte = Builder.node("input", {
        id: "inpChaveAcessoCte_" + countImagemCte,
        name: "inpChaveAcessoCte_" + countImagemCte,
        type: "text",
        className: "inputReadOnly",
        size: "52",
        maxlength: "44",
        readonly: "true",
        value: imagemCte.chaveAcessoCte
    });

    let _inpNumeroNfs = Builder.node("input", {
        id: "inpNumeroNfs_" + countImagemCte,
        name: "inpNumeroNfs_" + countImagemCte,
        type: "text",
        className: "inputReadOnly",
        size: "52",
        readonly: "true",
        value: imagemCte.numeroNFs
    });

    let _inpRemetente = Builder.node("input", {
        id: "inpRemetente_" + countImagemCte,
        name: "inpRemetente_" + countImagemCte,
        type: "text",
        className: "inputReadOnly",
        size: "52",
        readonly: "true",
        value: imagemCte.remetente
    });

    let _inpHidIdRemetente = Builder.node("input", {
        id: "inpHidIdRemetente_" + countImagemCte,
        name: "inpIdRemetente_" + countImagemCte,
        type: "hidden",
        value: imagemCte.idRemetente
    });

    let _inpDestinatario = Builder.node("input", {
        id: "inpDestinatario_" + countImagemCte,
        name: "inpDestinatario_" + countImagemCte,
        type: "text",
        className: "inputReadOnly",
        size: "52",
        readonly: "true",
        value: imagemCte.destinatario
    });

    let _inpHidIdDestinatario = Builder.node("input", {
        id: "inpHidIdDestinatario_" + countImagemCte,
        name: "inpHidIdDestinatario_" + countImagemCte,
        type: "hidden",
        value: imagemCte.idDestinatario
    });

    let _inpConsignatario = Builder.node("input", {
        id: "inpConsignatario_" + countImagemCte,
        name: "inpConsignatario_" + countImagemCte,
        type: "text",
        className: "inputReadOnly",
        size: "52",
        readonly: "true",
        value: imagemCte.consignatario
    });

    let _inpHidIdConsignatario = Builder.node("input", {
        id: "inpHidIdConsignatario_" + countImagemCte,
        name: "inpHidIdConsignatario_" + countImagemCte,
        type: "hidden",
        value: imagemCte.idConsignatario
    });

    let _inpOrigem = Builder.node("input", {
        id: "inpOrigem_" + countImagemCte,
        name: "inpOrigem_" + countImagemCte,
        type: "text",
        className: "inputReadOnly",
        size: "10",
        value: imagemCte.cidadeOrigem
    });

    let _inpHidIdOrigem = Builder.node("input", {
        id: "inpHidIdOrigem_" + countImagemCte,
        name: "inpHidIdOrigem_" + countImagemCte,
        type: "hidden",
        value: imagemCte.idCidadeOrigem
    });

    let _inpHidIdBaixaem = Builder.node("input", {
        id: "inpBaixaem_" + countImagemCte,
        name: "inpBaixaem_" + countImagemCte,
        type: "hidden",
        value: imagemCte.baixaEm ? imagemCte.baixaEm : ""
    });

    let _inpHiddenChegadaEm = Builder.node("input", {
        id: "inpHiddenChegadaEm_" + countImagemCte,
        name: "inpHiddenChegadaEm_" + countImagemCte,
        type: "hidden",
        value: imagemCte.chegadaEm ? imagemCte.chegadaEm : ""
    });

    let _inpHiddenChegadaAs = Builder.node("input", {
        id: "inpHiddenChegadaAs_" + countImagemCte,
        name: "inpHiddenChegadaAs_" + countImagemCte,
        type: "hidden",
        value: imagemCte.chegadaAs ? imagemCte.chegadaAs : ""
    });

    let _inpHiddenEntregaAs = Builder.node("input", {
        id: "inpHiddenEntregaAs_" + countImagemCte,
        name: "inpHiddenEntregaAs_" + countImagemCte,
        type: "hidden",
        value: imagemCte.entregaAs ? imagemCte.entregaAs : ""
    });

    let _inpHiddenValorAvaria = Builder.node("input", {
        id: "inpHiddenValorAvaria_" + countImagemCte,
        name: "inpHiddenValorAvaria_" + countImagemCte,
        type: "hidden",
        value: imagemCte.valorAvaria ? imagemCte.valorAvaria : ""
    });

    let _inpHiddenInicioDescarregoEm = Builder.node("input", {
        id: "inpHiddenInicioDescarregoEm_" + countImagemCte,
        name: "inpHiddenInicioDescarregoEm_" + countImagemCte,
        type: "hidden",
        value: imagemCte.inicioDescarregoEm ? imagemCte.inicioDescarregoEm : ""
    });

    let _inpHiddenInicioDescarregoAs = Builder.node("input", {
        id: "inpHiddenInicioDescarregoAs_" + countImagemCte,
        name: "inpHiddenInicioDescarregoAs_" + countImagemCte,
        type: "hidden",
        value: imagemCte.inicioDescarregoAs ? imagemCte.inicioDescarregoAs : ""
    });

    let _inpHiddenCobrouDescarrego = Builder.node("input", {
        id: "inpHiddenCobrouDescarrego_" + countImagemCte,
        name: "inpHiddenCobrouDescarrego_" + countImagemCte,
        type: "hidden",
        value: imagemCte.cobrouDescarrego ? imagemCte.cobrouDescarrego : ""
    });

    let _inpHiddenFimDescarregoEm = Builder.node("input", {
        id: "inpHiddenFimDescarregoEm_" + countImagemCte,
        name: "inpHiddenFimDescarregoEm_" + countImagemCte,
        type: "hidden",
        value: imagemCte.fimDescarregoEm ? imagemCte.fimDescarregoEm : ""
    });

    let _inpHiddenFimDescarregoAs = Builder.node("input", {
        id: "inpHiddenFimDescarregoAs_" + countImagemCte,
        name: "inpHiddenFimDescarregoAs_" + countImagemCte,
        type: "hidden",
        value: imagemCte.fimDescarregoAs ? imagemCte.fimDescarregoAs : ""
    });

    let _inpUfOrigem = Builder.node("input", {
        id: "inpUfOrigem_" + countImagemCte,
        name: "inpUfOrigem_" + countImagemCte,
        type: "text",
        className: "inputReadOnly",
        size: "3",
        value: imagemCte.ufOrigem
    });

    let _inpDestino = Builder.node("input", {
        id: "inpDestino_" + countImagemCte,
        name: "inpDestino_" + countImagemCte,
        type: "text",
        className: "inputReadOnly",
        size: "10",
        value: imagemCte.cidadeDestino
    });

    let _inpHidIdDestino = Builder.node("input", {
        id: "inpHidIdDestino_" + countImagemCte,
        name: "inpHidIdDestino_" + countImagemCte,
        type: "hidden",
        value: imagemCte.idCidadeDestino
    });

    let _inpUfDestino = Builder.node("input", {
        id: "inpUfDestino_" + countImagemCte,
        name: "inpUfDestino_" + countImagemCte,
        type: "text",
        className: "inputReadOnly",
        size: "3",
        value: imagemCte.ufDestino
    });

    let _textAreaDescricaoImagem = Builder.node("textarea", {
        id: "txtADescricaoImagem_" + countImagemCte,
        name: "txtADescricaoImagem_" + countImagemCte,
        className: "inputtexto",
        rows: "4",
        cols: "90",
        value: ""
    });

    let _chkBaixarEntrega = Builder.node("input", {
        id: "chkBaixarEntrega_" + countImagemCte,
        name: "chkBaixarEntrega_" + countImagemCte,
        type: "checkbox"
    });

    let _inpDataEntrega = Builder.node("input", {
        id: "inpDataEntrega_" + countImagemCte,
        name: "inpDataEntrega_" + countImagemCte,
        className: "inputtexto",
        size: "10",
        maxlength: "10",
        value: imagemCte.dataEntrega,
        onblur: "alertInvalidDate(this, true);validaDatas('" + imagemCte.emissao + "', '" + countImagemCte + "')",
        onkeydown: "fmtDate(this, event)",
        onkeyup: "fmtDate(this, event)",
        onkeypress: "fmtDate(this, event)"
    });

    let _inpHoraEntrega = Builder.node("input", {
        id: "inpHoraEntrega_" + countImagemCte,
        name: "inpHoraEntrega_" + countImagemCte,
        className: "inputtexto",
        size: "5",
        value: imagemCte.horaEntrega,
        onkeyup: "mascaraHora(this)"
    });

    let _chkComprovanteEntrega = Builder.node("input", {
        id: "chkComprovanteEntrega_" + countImagemCte,
        name: "chkComprovanteEntrega_" + countImagemCte,
        onclick:"enableDescricaoImagem("+countImagemCte+")",
        type: "checkbox"
    });

    let _inpDataComprovante = Builder.node("input", {
        id: "inpDataComprovante_" + countImagemCte,
        name: "inpDataComprovante_" + countImagemCte,
        className: "inputtexto",
        size: "10",
        maxlength: "10",
        value: imagemCte.dataEntrega,
        onblur: "alertInvalidDate(this, true);validaDatas('" + imagemCte.emissao + "', '" + countImagemCte + "')",
        onkeydown: "fmtDate(this, event)",
        onkeyup: "fmtDate(this, event)",
        onkeypress: "fmtDate(this, event)"
    });

    let _inpHoraComprovante = Builder.node("input", {
        id: "inpHoraComprovante_" + countImagemCte,
        name: "inpHoraComprovante_" + countImagemCte,
        className: "inputtexto",
        size: "5",
        value: imagemCte.horaEntrega,
        onkeyup: "mascaraHora(this)"
    });

    let _inpCodigoOcorrencia = Builder.node("input", {
        id: "inpCodigoOcorrencia_" + countImagemCte,
        name: "inpCodigoOcorrencia_" + countImagemCte,
        type: "text",
        className: "inputReadOnly",
        readOnly: "true",
        size: "5",
        value: imagemCte.codigoOcorrencia
    });

    let _inpOcorrencia = Builder.node("input", {
        id: "inpOcorrencia_" + countImagemCte,
        name: "inpOcorrencia_" + countImagemCte,
        className: "inputReadOnly",
        type: "text",
        readOnly: "true",
        size: "25",
        value: imagemCte.descricaoOcorrencia
    });

    let _inpHidIdOcorrencia = Builder.node("input", {
        id: "inpHidIdOcorrencia_" + countImagemCte,
        name: "inpHidIdOcorrencia_" + countImagemCte,
        type: "hidden",
        value: imagemCte.idOcorrencia
    });

    let _inpLocalizaOcorrencia = Builder.node("input", {
        id: "imgLocalizaOcorrencia_" + countImagemCte,
        name: "imgLocalizaOcorrencia_" + countImagemCte,
        type: "button",
        className: "inputbotao",
        onclick: "tryRequestToServer(function(){abrirLocalizaOcorrenciaDom(" + countImagemCte + ");});",
        value: "..."

    });

    let _textAreaObsEntrega = Builder.node("textarea", {
        id: "txtAObsEntrega_" + countImagemCte,
        name: "txtAObsEntrega_" + countImagemCte,
        className: "inputtexto",
        rows: "4",
        cols: "90",
        value: ""
    });

    //##############INPUT###################


    let _mensagemErro = Builder.node("label", {
        id: "txtMsgErro_" + countImagemCte,
        name: "txtMsgErro_" + countImagemCte,
        style: "color: red; font-size: 18px"
    });
    _mensagemErro.innerHTML = imagemCte.msgErro;

    //#############IMG######################
    let _imgVisualizarImagem = Builder.node("img", {
        'data-imagem-name': imagemCte.nomeArquivo,
        src: "",
        class: "imagemLink",
        onclick: "visualizarImagem(this)"
    });

    let _inpHidNomeArquivo = Builder.node("input", {
        id: "inpHidNomeArquivo_" + countImagemCte,
        name: "inpHidNomeArquivo_" + countImagemCte,
        type: "hidden",
        value: imagemCte.nomeArquivo
    });

    let _inpHidConteudoArquivo = Builder.node("input", {
        id: "inpHidConteudoArquivo_" + countImagemCte,
        name: "inpHidConteudoArquivo_" + countImagemCte,
        type: "hidden",
        value: '',
        'data-imagem-name': imagemCte.nomeArquivo,
    });

    let _inpHidIdCte = Builder.node("input", {
        id: "inpIdCte_" + countImagemCte,
        name: "inpIdCte_" + countImagemCte,
        type: "hidden",
        value: imagemCte.idCte
    });


    //#############IMG######################

    _divLblCte.appendChild(_lblCte);
    _divInpCte.appendChild(_inpNumeroCte);
    _divInpCte.appendChild(_inpLocalizaCte);
    _divInpCte.appendChild(_inpHidNomeArquivo);
    _divInpCte.appendChild(_inpHidConteudoArquivo);
    _divInpCte.appendChild(_inpHidIdCte);
    _divInpCte.appendChild(_inpHidIdBaixaem);
    _divInpCte.appendChild(_inpHiddenChegadaEm);
    _divInpCte.appendChild(_inpHiddenChegadaAs);
    _divInpCte.appendChild(_inpHiddenEntregaAs);
    _divInpCte.appendChild(_inpHiddenValorAvaria);
    _divInpCte.appendChild(_inpHiddenInicioDescarregoEm);
    _divInpCte.appendChild(_inpHiddenInicioDescarregoAs);
    _divInpCte.appendChild(_inpHiddenCobrouDescarrego);
    _divInpCte.appendChild(_inpHiddenFimDescarregoEm);
    _divInpCte.appendChild(_inpHiddenFimDescarregoAs);
    _divLblFilial.appendChild(_lblFilial);
    _divInpFilial.appendChild(_inpFilial);
    _divLblEmissao.appendChild(_lblEmissao);
    _divInpEmissao.appendChild(_inpEmissao);
    _divLblChaveAcessoCte.appendChild(_lblChaveAcessoCte);
    _divInpChaveAcessoCte.appendChild(_inpChaveAcessoCte);
    _divLblNumeroNfs.appendChild(_lblNumeroNfs);
    _divInpNumeroNfs.appendChild(_inpNumeroNfs);
    _divLblRemetente.appendChild(_lblRemetente);
    _divInpRemetente.appendChild(_inpRemetente);
    _divInpRemetente.appendChild(_inpHidIdRemetente);
    _divLblOrigem.appendChild(_lblOrigem);
    _divInpOrigem.appendChild(_inpOrigem);
    _divInpOrigem.appendChild(_inpHidIdOrigem);
    _divInpOrigem.appendChild(_lblOrigemEspaco);
    _divInpOrigem.appendChild(_inpUfOrigem);
    _divLblDestinatario.appendChild(_lblDestinatario);
    _divInpDestinatario.appendChild(_inpDestinatario);
    _divInpDestinatario.appendChild(_inpHidIdDestinatario);
    _divLblDestino.appendChild(_lblDestino);
    _divInpDestino.appendChild(_inpDestino);
    _divInpDestino.appendChild(_inpHidIdDestino);
    _divInpDestino.appendChild(_lblDestinoEspaco);
    _divInpDestino.appendChild(_inpUfDestino);
    _divLblConsignatario.appendChild(_lblConsignatario);
    _divInpConsignatario.appendChild(_inpConsignatario);
    _divInpConsignatario.appendChild(_inpHidIdConsignatario);
    _divLblDescricaoImagem.appendChild(_lblDescricaoImagem);
    _divInpDescricaoImagem.appendChild(_textAreaDescricaoImagem);
    _divLblDataEntrega.appendChild(_lblDataEntrega);
    _divInpDataEntrega.appendChild(_inpDataEntrega);
    _divInpDataEntrega.appendChild(_lblHoraEntrega);
    _divInpDataEntrega.appendChild(_inpHoraEntrega);
    _divLblDataComprovante.appendChild(_lblDataComprovante);
    _divInpDataComprovante.appendChild(_inpDataComprovante);
    _divInpDataComprovante.appendChild(_lblHoraComprovante);
    _divInpDataComprovante.appendChild(_inpHoraComprovante);
    _divLblOcorrencia.appendChild(_lblOcorrencia);
    _divInpOcorrencia.appendChild(_inpCodigoOcorrencia);
    _divInpOcorrencia.appendChild(_lblOcorrenciaEspacoCodigo);
    _divInpOcorrencia.appendChild(_inpOcorrencia);
    _divInpOcorrencia.appendChild(_inpHidIdOcorrencia);
    _divInpOcorrencia.appendChild(_lblOcorrenciaEspaco);
    _divInpOcorrencia.appendChild(_inpLocalizaOcorrencia);
    _divLblObsEntrega.appendChild(_lblObsEntrega);
    _divInpObsEntrega.appendChild(_textAreaObsEntrega);


    _tdImagem.appendChild(_imgVisualizarImagem);
    _tdImagem.appendChild(_lblVisualizarImagem);

    _tdLblCte.appendChild(_divLblCte);
    _tdInpCte.appendChild(_divInpCte);
    _tdLblFilial.appendChild(_divLblFilial);
    _tdInpFilial.appendChild(_divInpFilial);
    _tdLblEmissao.appendChild(_divLblEmissao);
    _tdInpEmissao.appendChild(_divInpEmissao);
    _tdLblChaveAcessoCte.appendChild(_divLblChaveAcessoCte);
    _tdInpChaveAcessoCte.appendChild(_divInpChaveAcessoCte);
    _tdLblNumeroNfs.appendChild(_divLblNumeroNfs);
    _tdInpNumeroNfs.appendChild(_divInpNumeroNfs);
    _tdLblRemetente.appendChild(_divLblRemetente);
    _tdInpRemetente.appendChild(_divInpRemetente);
    _tdLblOrigem.appendChild(_divLblOrigem);
    _tdInpOrigem.appendChild(_divInpOrigem);
    _tdLblDestinatario.appendChild(_divLblDestinatario);
    _tdInpDestinatario.appendChild(_divInpDestinatario);
    _tdLblDestino.appendChild(_divLblDestino);
    _tdInpDestino.appendChild(_divInpDestino);
    _tdLblConsignatario.appendChild(_divLblConsignatario);
    _tdInpConsignatario.appendChild(_divInpConsignatario);
    _tdLblDescricaoImagem.appendChild(_divLblDescricaoImagem);
    _tdInpDescricaoImagem.appendChild(_divInpDescricaoImagem);
    _tdChkBaixarEntrega.appendChild(_chkBaixarEntrega);
    _tdChkBaixarEntrega.appendChild(_lblBaixarEntrega);
    _tdChkComprovanteEntrega.appendChild(_chkComprovanteEntrega);
    _tdChkComprovanteEntrega.appendChild(_lblComprovanteEntrega);
    _tdLblDataEntrega.appendChild(_divLblDataEntrega);
    _tdInpDataEntrega.appendChild(_divInpDataEntrega);
    _tdLblDataComprovante.appendChild(_divLblDataComprovante);
    _tdInpDataComprovante.appendChild(_divInpDataComprovante);

    //Caso usuario não tenha nenhuma permissão referente a ocorrencia, não pode adicionar
    if (podeProcurarOcorrencia) {
        _tdLblOcorrencia.appendChild(_divLblOcorrencia);
        _tdInpOcorrencia.appendChild(_divInpOcorrencia);
    }

    _tdLblObsEntrega.appendChild(_divLblObsEntrega);
    _tdInpObsEntrega.appendChild(_divInpObsEntrega);

    _tdLblMsgErro.appendChild(_mensagemErro);

    _trNumeroCte.appendChild(_tdImagem);
    _trNumeroCte.appendChild(_tdLblCte);
    _trNumeroCte.appendChild(_tdInpCte);
    _trNumeroCte.appendChild(_tdLblFilial);
    _trNumeroCte.appendChild(_tdInpFilial);
    _trNumeroCte.appendChild(_tdLblEmissao);
    _trNumeroCte.appendChild(_tdInpEmissao);

    _trChaveAcessoCte.appendChild(_tdLblChaveAcessoCte);
    _trChaveAcessoCte.appendChild(_tdInpChaveAcessoCte);

    _trNumeroNfs.appendChild(_tdLblNumeroNfs);
    _trNumeroNfs.appendChild(_tdInpNumeroNfs);

    _trRemetente.appendChild(_tdLblRemetente);
    _trRemetente.appendChild(_tdInpRemetente);
    _trRemetente.appendChild(_tdLblOrigem);
    _trRemetente.appendChild(_tdInpOrigem);

    _trDestinatario.appendChild(_tdLblDestinatario);
    _trDestinatario.appendChild(_tdInpDestinatario);
    _trDestinatario.appendChild(_tdLblDestino);
    _trDestinatario.appendChild(_tdInpDestino);

    _trConsignatario.appendChild(_tdLblConsignatario);
    _trConsignatario.appendChild(_tdInpConsignatario);

    _trDescricaoImagem.appendChild(_tdLblDescricaoImagem);
    _trDescricaoImagem.appendChild(_tdInpDescricaoImagem);

    _trEntrega.appendChild(_tdChkBaixarEntrega);
    _trEntrega.appendChild(_tdLblDataEntrega);
    _trEntrega.appendChild(_tdInpDataEntrega);

    _trEntrega.appendChild(_tdLblOcorrencia);
    _trEntrega.appendChild(_tdInpOcorrencia);

    _trComprovante.appendChild(_tdChkComprovanteEntrega);
    _trComprovante.appendChild(_tdLblDataComprovante);
    _trComprovante.appendChild(_tdInpDataComprovante);
    _trComprovante.appendChild(_tdEmpty1);
    _trComprovante.appendChild(_tdEmpty2);
    _trComprovante.appendChild(_tdEmpty3);

    _trObsEntrega.appendChild(_tdLblObsEntrega);
    _trObsEntrega.appendChild(_tdInpObsEntrega);
    _trObsEntrega.appendChild(_tdEmpty);

    _trMsgErro.appendChild(_tdLblMsgErro);

    table.appendChild(_trNumeroCte);
    table.appendChild(_trChaveAcessoCte);
    table.appendChild(_trNumeroNfs);
    table.appendChild(_trRemetente);
    table.appendChild(_trDestinatario);
    table.appendChild(_trConsignatario);
    table.appendChild(_trDescricaoImagem);
    table.appendChild(_trEntrega);
    table.appendChild(_trComprovante);
    table.appendChild(_trObsEntrega);
    table.appendChild(_trMsgErro);

    if (imagemCte.msgErro === "") {
        invisivel(_trMsgErro);
    } else {
        visivel(_trMsgErro);
    }

    if (!podeBaixar) {
        invisivel(_trEntrega);
        invisivel(_trObsEntrega);
    }

    if (imagemCte.baixaEm && imagemCte.baixaEm !== "") {
        _chkBaixarEntrega.disabled = true;

        invisivel(_inpLocalizaOcorrencia);
        invisivel(_inpLocalizaCte);
        readOnly(_inpDataEntrega);
        readOnly(_inpHoraEntrega);
        readOnly(_textAreaDescricaoImagem);
        readOnly(_textAreaObsEntrega);

        _inpDataEntrega.value = '';
        _inpHoraEntrega.value = '';
    }

    $("maxCte").value = countImagemCte;

}

function carregar() {
    $("dataEntrega").value = dataAtual;
    $("horaEntrega").value = horaAtual;
    $("dataComprovante").value = dataAtual;
    $("horaComprovante").value = horaAtual;

    jQuery('input[name="tipoDocumento"]').on('change', function () {
        if (this.value === 'numeroCanhotoNFe') {
            visivel($('localizarRemetenteTR'));
        } else {
            invisivel($('localizarRemetenteTR'));
        }
    });
}

function abrirLocalizaOcorrencia() {
    launchPopupLocate('./localiza?acao=consultar&idlista=40', 'Ocorrencia_CTe');
}

function abrirLocalizaOcorrenciaDom(index) {
    launchPopupLocate('./localiza?acao=consultar&idlista=40', 'Ocorrencia_CTe_' + index);
}

function abrirLocalizaCteDom(index) {
    launchPopupLocate('./localiza?acao=consultar&idlista=91', 'listar_Cte_' + index);
}

function aoClicarNoLocaliza(idjanela) {
    let index = idjanela.split("_")[2];

    if (idjanela == "Ocorrencia_CTe") {
        $("codigoOcorrencia").value = $("ocorrencia").value;
        $("descricaoOcorrencia").value = $("descricao_ocorrencia").value;
        $("idOcorrencia").value = $("ocorrencia_id").value;
    } else if (idjanela == "Ocorrencia_CTe_" + index) {
        $("inpCodigoOcorrencia_" + index).value = $("ocorrencia").value;
        $("inpOcorrencia_" + index).value = $("descricao_ocorrencia").value;
        $("inpHidIdOcorrencia_" + index).value = $("ocorrencia_id").value;

    } else if (idjanela == "listar_Cte_" + index) {
        $("inpIdCte_" + index).value = $("id").value;
        $("inpNumeroCte_" + index).value = $("numero").value;
        $("inpChaveAcessoCte_" + index).value = $("chave_acesso_cte").value;
        $("inpRemetente_" + index).value = $("remetente").value;
        $("inpDestinatario_" + index).value = $("destinatario").value;
        $("inpConsignatario_" + index).value = $("consignatario").value;
        $("inpFilial_" + index).value = $("filial").value;
        $("inpDestino_" + index).value = $("cidade_destino").value;
        $("inpOrigem_" + index).value = $("cidade_origem").value;
        $("inpBaixaem_" + index).value = $("baixa_em").value;
        $("inpNumeroNfs_" + index).value = $("numero_nf").value;
        $("inpUfOrigem_" + index).value = $("uf_origem").value;
        $("inpUfDestino_" + index).value = $("uf_destino").value;

        if ($("inpBaixaem_" + index).value != "") {
            $("chkBaixarEntrega_" + index).disabled = true;
            $("txtMsgErro_" + index).innerHTML = "CT-e já baixado!";
            visivel($('trMsgErro_' + index));
        } else {
            $("chkBaixarEntrega_" + index).disabled = false;
            $("txtMsgErro_" + index).value = "";
            invisivel($('trMsgErro_' + index));
        }
    }
}

function salvar() {
    let passouValidacao = true;

    if (jQuery('[id^="trNumeroCte_"]').length === 0) {
        alert('Não existem anexos importados');

        return false;
    }

    // Validações
    jQuery('input[type="checkbox"][name^="chkBaixarEntrega_"]:checked').each(function () {
        let index = this.id.split('_')[1];
        let emissao = $('inpEmissao_' + index).value;

        if (!validaDatas(emissao, index)) {
            passouValidacao = false;

            return false;
        }

        // Obrigar a ocorrência, se a configuração estiver marcada.
        if (obrigarOcorrenciaConfiguracao === 'true' && ($('inpHidIdOcorrencia_' + index).value === '0' || $('inpHidIdOcorrencia_' + index).value === '')) {
            alert('Não é possível baixar o CT-e sem ocorrência!');

            passouValidacao = false;

            return false;
        }
    });

    if (!passouValidacao) {
        return false;
    }

    mostrarAguarde(true);

    // Salvar por AJAX
    // Irá salvar em 5 a 5 imagens.
    mensagemErros = '';
    let maximo = 5;
    let repeticoes = Math.round(countImagemCte / maximo);
    // Se sobrar resto da divisão, acrescentar + 1 repetição
    if ((countImagemCte % maximo) > 0) {
        repeticoes += 1;
    }
    let formulario = jQuery("#formSalvar");
    let arrayDados = [];
    let indexJaVistos = [];

    for (let i = 0; i < repeticoes; i++) {
        let data = {'acao': 'cadastrar'};
        let maxCte = 0;

        let indexCtesNaoSalvarOcorrencia = jQuery('input[name^="chkBaixarEntrega_"]:disabled').map((index, e) => e.id.substring(e.name.lastIndexOf('_') + 1)).toArray().filter(e => !indexJaVistos.includes(e));
        if (indexCtesNaoSalvarOcorrencia.length > 0) {
            for (let a = 0; a < indexCtesNaoSalvarOcorrencia.length; a++) {
                let index = indexCtesNaoSalvarOcorrencia[a];
                indexJaVistos.push(index);

                if ((formulario.find('input[name="inpIdCte_' + index + '"]').val() !== '0'
                    && formulario.find('input[name="inpBaixaem_' + index + '"]').val() === '') || ($('chkComprovanteEntrega_'+index) != null && $('chkComprovanteEntrega_'+index).checked)) {
                    maxCte++;
                    let inputs = formulario.find('[name$="_' + index + '"]').serializeArray();

                    if (inputs.length > 0) {
                        inputs.map(x => data[x.name.replace('_' + index, '_' + maxCte)] = x.value);
                    }
                }

                if (maxCte >= 5) {
                    break;
                }
            }
        }

        if (maxCte < maximo) {
            for (let index = 1; index <= countImagemCte; index++) {
                if (!indexJaVistos.includes(String(index))) {
                    indexJaVistos.push(String(index));

                    if ((formulario.find('input[name="inpIdCte_' + index + '"]').val() !== '0'
                        && formulario.find('input[name="inpBaixaem_' + index + '"]').val() === '')|| ($('chkComprovanteEntrega_'+index) != null && $('chkComprovanteEntrega_'+index).checked)) {
                        maxCte++;

                        let inputs = formulario.find('[name$="_' + index + '"]').serializeArray();

                        if (inputs.length > 0) {
                            inputs.map(x => data[x.name.replace('_' + index, '_' + maxCte)] = x.value);
                        }

                        if (maxCte >= 5) {
                            break;
                        }
                    }
                }
            }
        }

        data['maxCte'] = maxCte;
        data['status'] = 'pendente';

        if (maxCte > 0) {
            arrayDados.push(data);
        }
    }

    if (arrayDados.length > 0) {
        salvarImagemAjax(arrayDados);
    }
}

function salvarImagemAjax(arrayDados) {
    let data = arrayDados.filter(e => e.status === 'pendente' || e.status === 'erro').toArray().first();

    if (data !== undefined) {
        jQuery.when(jQuery.ajax({
            url: homePath + '/AnexarImagemControlador',
            type: 'POST',
            data: data,
            success: data1 => {
                data.status = 'enviado';

                if (data1) {
                    let json = JSON.parse(data1);

                    if (json) {
                        if (!json['success']) {
                            mensagemErros += json['erro'];
                        }
                    }
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                console.error('Um erro aconteceu ao salvar a imagem!', errorThrown);
            }
        })).done(() => {
            setTimeout(() => salvarImagemAjax(arrayDados), 500)
        }).fail(error => {
            console.error('Um erro aconteceu ao reconhecer a imagem! Tentando novamente...', error);

            setTimeout(() => salvarImagemAjax(arrayDados), 500)
        });
    } else {
        if (mensagemErros !== '') {
            alert(mensagemErros);
        } else {
            alert('Anexos salvos com sucesso');
        }

        $("inputAnexarArquivos").value = '';
        $('maxCte').value = '0';
        jQuery('#tbImagemCte').empty();
        chavesAdicionadas = [];

        mostrarAguarde(false);
    }
}

function anexarCte() {
    countImagemCte = 0;
    let arquivos = $("inputAnexarArquivos").files;

    if (arquivos.length == 0) {
        alert("Atenção: Selecione um arquivo!");

        return false;
    }

    let modelo = jQuery('input[name="tipoDocumento"]:checked').val();
    if (modelo === 'numeroCanhotoNFe' && $('idremetente').value <= 0) {
        alert("Atenção: O Remetente é de preenchimento obrigatório!");

        return false;
    }

    mostrarAguarde(true);

    let listaArquivos = [];

    for (let i = 0; i < arquivos.length; i++) {
        listaArquivos.push({'arquivo': arquivos[i], 'status': 'pendente'});
    }

    enviarImagem(listaArquivos, modelo);
}

function enviarImagem(listaImagens, modelo) {
    let imagens = listaImagens.filter(e => e.status === 'pendente' || e.status === 'erro').toArray().slice(0, 5);

    if (imagens.length > 0) {
        let ajaxes = [];

        for (let i = 0; i < imagens.length; i++) {
            let imagem = imagens[i];
            let formData = new FormData();

            formData.append('inputAnexarArquivos[]', imagem.arquivo);
            formData.append('tipoDocumento', modelo);

            ajaxes.push(jQuery.ajax({
                url: linkGwOCR + '/api/v1/reconhecimento/imagem/reconhecer',
                type: 'POST',
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: data => {
                    imagem.status = 'enviado';

                    sucessoImportarArquivo(data, imagem.arquivo, modelo)
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    console.error('Um erro aconteceu ao reconhecer a imagem!', errorThrown);
                }
            }));
        }

        jQuery.when(...ajaxes).done(() => {
            setTimeout(() => enviarImagem(listaImagens, modelo), 500)
        }).fail(error => {
            console.error('Um erro aconteceu ao reconhecer a imagem! Tentando novamente...', error);

            setTimeout(() => enviarImagem(listaImagens, modelo), 500)
        });
    } else {
        mostrarAguarde(false);
    }
}

function repetir() {
    let isBaixaEntrega = $("chkBaixarEntrega").checked;
    let dataBaixaEntrega = $("dataEntrega").value;
    let horaBaixaEntrega = $("horaEntrega").value;
    let idOcorrencia = $("idOcorrencia").value;
    let codigoOcorrencia = $("codigoOcorrencia").value;
    let descricaoOcorrencia = $("descricaoOcorrencia").value;
    let obsEntrega = $("obsEntrega").value;
    let descricaoImagem = $("descricaoImagem").value;
    let isComprovanteEntrega = $("chkComprovanteEntrega").checked;
    let dataComprovante = $("dataComprovante").value;
    let horaComprovante = $("horaComprovante").value;

    let maxCte = $("maxCte").value;
    let cteJaVistos = [];

    for (let qtdCte = 1; qtdCte <= maxCte; qtdCte++) {
        let cteId = $('inpIdCte_' + qtdCte).value;

        if (!cteJaVistos.includes(cteId)) {
            cteJaVistos.push(cteId);

            if ($("inpNumeroCte_" + qtdCte) != null) {
                if (!$("chkBaixarEntrega_" + qtdCte).disabled) {
                    $("chkBaixarEntrega_" + qtdCte).checked = isBaixaEntrega;
                    $("inpDataEntrega_" + qtdCte).value = dataBaixaEntrega;
                    $("inpHoraEntrega_" + qtdCte).value = horaBaixaEntrega;
                    $("inpHidIdOcorrencia_" + qtdCte).value = idOcorrencia;
                    $("inpCodigoOcorrencia_" + qtdCte).value = codigoOcorrencia;
                    $("inpOcorrencia_" + qtdCte).value = descricaoOcorrencia;
                    $("txtAObsEntrega_" + qtdCte).value = obsEntrega;
                    $("txtADescricaoImagem_" + qtdCte).value = descricaoImagem;
                }
                $("chkComprovanteEntrega_" + qtdCte).checked = isComprovanteEntrega;
                $("inpDataComprovante_" + qtdCte).value = dataComprovante;
                $("inpHoraComprovante_" + qtdCte).value = horaComprovante;
            }
        } else {
            invisivel($('imgLocalizaOcorrencia_' + qtdCte));
            $('chkBaixarEntrega_' + qtdCte).disabled = true;
            readOnly($('inpDataEntrega_' + qtdCte));
            readOnly($('inpHoraEntrega_' + qtdCte));
            readOnly($('txtAObsEntrega_' + qtdCte));


            $("txtADescricaoImagem_" + qtdCte).value = descricaoImagem;
        }
        if(isComprovanteEntrega){
            enableDescricaoImagem(qtdCte);
            $("txtADescricaoImagem_" + qtdCte).value = descricaoImagem;
        }
    }
}

function visualizarImagem(imagem) {
    let image = new Image();
    image.src = imagem.src;

    let w = window.open("", "visualizaImagem", 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
    w.document.write(image.outerHTML);
}

function abrirLocalizarRemetente() {
    launchPopupLocate('./localiza?acao=consultar&idlista=03', 'Remetente');
}

function localizarOcorrenciaCodigo(param) {
    mostrarAguarde(true);

    jQuery.post(homePath + '/ConhecimentoControlador', {
        'acao': 'ajaxCarregarOcorrenciaCodigo',
        'ocorrencia': param.value,
        'idSales': '',
        'carregarTudo': true
    }, function (data) {
        if (data) {
            $("idOcorrencia").value = data['idOcorrencia'];
            $("codigoOcorrencia").value = data['codigoOcorrencia'];
            $("descricaoOcorrencia").value = data['descricaoOcorrencia'];
        }

        mostrarAguarde(false);
    }, 'json')
}

function validaDatas(dtEmissao, id) {
    let dataAtualDate = new Date(dataAtual.substring(6, 10), dataAtual.substring(3, 5) - 1, dataAtual.substring(0, 2));
    var dataEmissao = new Date(dtEmissao.substring(6, 10), dtEmissao.substring(3, 5) - 1, dtEmissao.substring(0, 2));
    var dataEntrega = new Date($('inpDataEntrega_' + id).value.substring(6, 10), $('inpDataEntrega_' + id).value.substring(3, 5) - 1, $('inpDataEntrega_' + id).value.substring(0, 2));

    if ($('chkBaixarEntrega_' + id).checked) {
        if ($('inpDataEntrega_' + id).value === '') {
            alert('A "Data Entrega" é de preenchimento obrigatório!');

            return false;
        } else {
            if (dataEntrega.getTime() < dataEmissao.getTime()) {
                alert('A data de entrega não pode ser inferior a data de emissão.');
                $('inpDataEntrega_' + id).value = '';

                return false;
            } else if (dataEntrega.getTime() > dataAtualDate.getTime()) {
                alert('A data de entrega não pode ser superior a data atual.');
                $('inpDataEntrega_' + id).value = '';

                return false;
            }
        }
    }

    return true;
}

function mostrarAguarde(mostrar) {
    if (mostrar) {
        jQuery(document).scrollTop(0);
        jQuery('html, body').css({
            overflow: 'hidden',
            height: '100%'
        });
        jQuery('.bloqueio-tela,.bloqueio-aguarde').show();
    } else {
        jQuery('html, body').css({
            overflow: 'auto',
            height: 'auto'
        });

        jQuery('.bloqueio-tela,.bloqueio-aguarde').hide();
    }
}

function sucessoImportarArquivo(data, arquivo, modelo) {
    if (data) {
        jQuery.each(data, function (key, value) {
            let chaveAcesso = value[0];

            if (modelo === 'numeroCanhotoNFe') {
                chaveAcesso += '/' + $('idremetente').value;
            }

            jQuery.post(homePath + '/AnexarImagemControlador', {
                'acao': 'anexarImagemCte',
                'chaveAcesso': chaveAcesso,
                'modelo': modelo
            }, function (data1) {
                if (data1) {
                    let imagemCte = new ImagemCte();

                    if (data1.erro) {
                        imagemCte.msgErro = data1.erro;
                    }

                    imagemCte.dataEntrega = dataAtual;
                    imagemCte.horaEntrega = horaAtual;

                    if (data1.conhecimento) {
                        imagemCte.emissao = data1.conhecimento.emissao_em;
                        imagemCte.idRemetente = data1.conhecimento.remetente.idcliente;
                        imagemCte.remetente = data1.conhecimento.remetente.razaosocial;
                        imagemCte.idCidadeOrigem = data1.conhecimento.remetente.cidade.idcidade;
                        imagemCte.cidadeOrigem = data1.conhecimento.remetente.cidade.descricaoCidade;
                        imagemCte.ufOrigem = data1.conhecimento.remetente.cidade.uf;
                        imagemCte.idDestinatario = data1.conhecimento.destinatario.idcliente;
                        imagemCte.destinatario = data1.conhecimento.destinatario.razaosocial;
                        imagemCte.idCidadeDestino = data1.conhecimento.destinatario.cidade.idcidade;
                        imagemCte.cidadeDestino = data1.conhecimento.destinatario.cidade.descricaoCidade;
                        imagemCte.ufDestino = data1.conhecimento.destinatario.cidade.uf;
                        imagemCte.idConsignatario = data1.conhecimento.cliente.idcliente;
                        imagemCte.consignatario = data1.conhecimento.cliente.razaosocial;
                        imagemCte.numeroCte = data1.conhecimento.numero;
                        imagemCte.chaveAcessoCte = data1.conhecimento.chaveAcessoCte;

                        imagemCte.baixaEm = data1.conhecimento.baixa_em;
                        imagemCte.chegadaEm = data1.conhecimento.chegada_em;
                        imagemCte.chegadaAs = data1.conhecimento.chegadaAs;
                        imagemCte.entregaAs = data1.conhecimento.entregaAs;
                        imagemCte.valorAvaria = data1.conhecimento.valorAvaria;
                        imagemCte.inicioDescarregoEm = data1.conhecimento.inicioDescarregoEm;
                        imagemCte.inicioDescarregoAs = data1.conhecimento.inicioDescarregoAs;
                        imagemCte.cobrouDescarrego = data1.conhecimento.cobrouDescarrego;
                        imagemCte.fimDescarregoEm = data1.conhecimento.FimDescarregoEm;
                        imagemCte.fimDescarregoAs = data1.conhecimento.FimDescarregoAs;

                        imagemCte.idCte = data1.conhecimento.id;
                        imagemCte.numeroNFs = data1.conhecimento.notas.map(e => e.numero).join(', ');
                        imagemCte.filial = data1.conhecimento.filial.abreviatura;
                    }

                    imagemCte.nomeArquivo = key;

                    let reader = new FileReader();

                    // Closure to capture the file information.
                    reader.onload = (e => {
                        // Render thumbnail.
                        let img = jQuery('img[data-imagem-name="' + key + '"]');
                        let inputHidden = jQuery('input[data-imagem-name="' + key + '"]');

                        img.attr('src', e.target.result);
                        inputHidden.val(e.target.result);
                    });

                    // Read in the image file as a data URL.
                    reader.readAsDataURL(arquivo);

                    addImagemCte(imagemCte, modelo);
                }
            }, 'json');
        });
    }
}

function enableDescricaoImagem(index) {
    let descricao = $("txtADescricaoImagem_"+index);
    if($("chkBaixarEntrega_" + index).disabled) {
        if ($("chkComprovanteEntrega_" + index).checked) {
            notReadOnly(descricao);
        } else {
            descricao.value = '';
            readOnly(descricao);
        }
    }
}

