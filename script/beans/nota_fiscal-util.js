/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


function NotaFiscal(id
    , valor
    , numero
    , dataEmissao
    , serie
    , peso
    , volume
    , cubagem
    , listaCuabagem
    , listaMercadoria
    , embalagem
    , conteudo
    , baseCalculoIcm
    , icmsValor
    , icmsST
    , icmsFrete
    , cfop
    , cfopId
    , chaveNFe
    , marca
    , marcaId
    , modelo
    , ano
    , cor
    , chassi
    , isImportacaoEDI
    , pedido
    , isAgendado
    , dataAgenda
    , horaAgenda
    , dataPrevisao
    , horaPrevisao
    , destinatario
    , destinatarioId
    , observacao
    , isExiste
    , adValorem
    , valorSeguro
    , valorFretePeso
    , valorTotalTaxas
    , metroCubico
    , valorGris
    , valorPedagio
    , tipoDocumento
    , cargaId
    , isDesbloqueoValores
    , tipoConhecimento
    , isAddCubagem
    , codigoBarras
    ){
    this.id = (id == null || id== undefined ? 0 : id);
    this.cargaId = (cargaId == null || cargaId== undefined ? 0 : cargaId);
    this.valor = (valor == null || valor == undefined ? 0 : valor);
    this.numero = (numero == null || numero == undefined ? "" : numero);
    this.dataEmissao = (dataEmissao == null || dataEmissao == undefined ? "" : dataEmissao);
    this.serie = (serie == null || serie == undefined ? "" : serie);
    this.peso = (peso == null || peso == undefined ? 0 : peso);
    this.volume = (volume == null || volume == undefined ? 0 : volume);
    this.cubagem = (cubagem == null || cubagem == undefined ? (new Cubabem()): cubagem);
    this.listaCuabagem = (listaCuabagem == null || listaCuabagem == undefined ? null : listaCuabagem);
    this.listaMercadoria = (listaMercadoria == null || listaMercadoria == undefined ? null : listaMercadoria);
    this.embalagem = (embalagem == null || embalagem == undefined ? "" : embalagem);
    this.baseCalculoIcm = (baseCalculoIcm == null || baseCalculoIcm == undefined ? 0 : baseCalculoIcm);
    this.conteudo = (conteudo == null || conteudo == undefined ? "" : conteudo);
    this.icmsValor = (icmsValor == null || icmsValor == undefined ? 0 : icmsValor);
    this.icmsST = (icmsST == null || icmsST == undefined ? 0 : icmsST);
    this.icmsFrete = (icmsFrete == null || icmsFrete == undefined ? 0 : icmsFrete);
    this.cfop = (cfop == null || cfop == undefined ? "" : cfop);
    this.cfopId = (cfopId == null || cfopId == undefined ? 0 : cfopId);
    this.chaveNFe = (chaveNFe == null || chaveNFe == undefined ? "" : chaveNFe);
    this.marca = (marca == null || marca == undefined ? "" : marca);        
    this.marcaId = (marcaId == null || marcaId == undefined ? 0 : marcaId);
    this.modelo = (modelo == null || modelo == undefined ? "" : modelo);
    this.ano= (ano == null || ano == undefined ? 0 : ano);
    this.cor = (cor == null || cor == undefined ? "" : cor);
    this.chassi = (chassi == null || chassi == undefined ? "" : chassi);
    this.isImportacaoEDI = (isImportacaoEDI == null || isImportacaoEDI == undefined ? false : isImportacaoEDI);
    this.isAgendado = (isAgendado == null || isAgendado == undefined ? false : isAgendado);
    this.isExiste = (isExiste == null || isExiste == undefined ? false : isExiste);
    this.pedido = (pedido == null || pedido == undefined ? "" : pedido);
    this.dataAgenda = (dataAgenda == null || dataAgenda == undefined ? "" : dataAgenda);
    this.horaAgenda = (horaAgenda == null || horaAgenda == undefined ? "" : horaAgenda);
    this.dataPrevisao = (dataPrevisao== null || dataPrevisao == undefined ? "" : dataPrevisao);
    this.horaPrevisao = (horaPrevisao == null || horaPrevisao == undefined ? "" : horaPrevisao);
    this.destinatario = (destinatario == null || destinatario == undefined ? "" : destinatario);
    this.tipoDocumento = (tipoDocumento == null || tipoDocumento == undefined ? "" : tipoDocumento);
    this.destinatarioId = (destinatarioId == null || destinatarioId == undefined ? 0 : destinatarioId);
    this.observacao = (observacao == null || observacao == undefined ? "" : observacao);
    this.metroCubico = (metroCubico == null || metroCubico == undefined ? 0 : metroCubico);
    /**
     * Campos adicionados por Vladson. EDI Proceda 3.1 Pode ser substituido por
     * uma classe unica futuramente.
     */
    this.adValorem = (adValorem == null || adValorem == undefined ? 0 : adValorem);
    this.valorSeguro = (valorSeguro == null || valorSeguro == undefined ? 0 : valorSeguro);
    this.valorFretePeso = (valorFretePeso == null || valorFretePeso == undefined ? 0 : valorFretePeso);
    this.valorTotalTaxas = (valorTotalTaxas == null || valorTotalTaxas == undefined ? 0 : valorTotalTaxas);
    this.valorGris = (valorGris == null || valorGris == undefined ? 0 : valorGris);
    this.valorPedagio = (valorPedagio== null || valorPedagio == undefined ? 0 : valorPedagio);
    this.isDesbloqueoValores = (isDesbloqueoValores== null || isDesbloqueoValores == undefined ? false : isDesbloqueoValores);
    this.tipoConhecimento = (tipoConhecimento == null || tipoConhecimento == undefined ? "" : tipoConhecimento);
    this.isAddCubagem = (isAddCubagem == null || isAddCubagem == undefined ? true : isAddCubagem);
    
    this.codigoBarras = (codigoBarras == null || codigoBarras == undefined ? "" : codigoBarras);
}

function Cubabem(id
    ,volume
    ,comprimento
    ,largura
    ,altura
    ,metroCubico
    ,orcamentoId
    ,notaFiscalId
    ,existe
    ,etiqueta
    ){
        
    this.id = (id == null || id== undefined ? 0 : id);
    this.volume = (volume == null || volume== undefined ? 0 : volume);
    this.comprimento = (comprimento == null || comprimento == undefined ? 0 : comprimento);
    this.largura = (largura == null || largura == undefined ? 0 : largura);
    this.altura = (altura == null || altura == undefined ? 0 : altura);
    this.metroCubico = (metroCubico == null || metroCubico == undefined ? 0 : metroCubico);
    this.orcamentoId = (orcamentoId == null || orcamentoId == undefined ? 0 : orcamentoId);
    this.notaFiscalId = (notaFiscalId == null || notaFiscalId == undefined ? 0 : notaFiscalId);
    this.existe = (existe == null || existe == undefined ? true : existe);
    this.etiqueta = (etiqueta == null || etiqueta == undefined ? "" : etiqueta);
}

function Mercadoria(id
    ,quantidade
    ,valorUnitario
    ,notaFiscalId
    ,produtoId
    ,produto
    ){
        
    this.id = (id == null || id== undefined ? 0 : id);
    this.quantidade = (quantidade == null || quantidade== undefined ? 0 : quantidade);
    this.produtoId = (produtoId == null || produtoId == undefined ? 0 : produtoId);
    this.produto = (produto == null || produto == undefined ? "" : produto);
    this.valorUnitario = (valorUnitario == null || valorUnitario == undefined ? 0 : valorUnitario);
    this.notaFiscalId = (notaFiscalId == null || notaFiscalId == undefined ? 0 : notaFiscalId);
}
