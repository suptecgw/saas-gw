<%-- 
    Document   : nova_importacao_nova
    Created on : 09/10/2015, 16:01:57
    Author     : paulo
--%> 

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@page import="nucleo.Apoio"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<link href="estilo.css" rel="stylesheet" type="text/css"></link>
<script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript" src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
<script language="JavaScript" src="script/beans/nota_fiscal-util.js" type="text/javascript"></script>
<script language="javascript" src="script/notaFiscal-util.js"></script>
<script language="JavaScript" src="script/beans/CTRC.js" type="text/javascript"></script>
<script language="JavaScript" src="script/collection.js" type="text/javascript"></script>
<script type="text/javascript" src="script/jquery-1.11.2.min.js"></script>
<script language="JavaScript" src="script/shortcut.js"></script>
<link rel="chrome-webstore-item" href="https://chrome.google.com/webstore/detail/eegmcpafdbgpjdjocjfffnkjihijhagb">
<script type="text/javascript" language="JavaScript">
    jQuery.noConflict();
    
    var listaLayoutClienteEdiNotfis = new Array();
    var listaLayoutClienteEdiNotfisPadrao = new Array();
    var countLayoutEdi = 0;
    var countLayoutEdiPadrao = 0;
    var listLayoutEdi;    
    var listLayoutEdiNOTFIS;
    
    let qtdDomTagsPersonalizadas = 0;
    
    shortcut.add("Ctrl+Shift+A",function() {anexar();});
    
    function fechar(){
        window.close();
    }
    function receberEmail(){
        abrirJanela("ArquivoImportacaoXMLControlador?acao=receberEmailImportacao&", "bxXmlEmail", 20, 20);
    }
    function abrirLocalizarCliente(){
        popLocate(05,"Cliente","","");
    }
    function abrirLocalizarRedespacho(){
        popLocate(06,"Redespacho","","");
    }
    function abrirLocalizarDestinatario(){
        popLocate(04,"Destinatario","","");
    }
    function abrirLocalizarRemetente(){
        popLocate(03,"Remetente","","");
    }
    function abrirLocalizarConsignatario(){
        popLocate(05,"Consignatario","","");
    }
    function abrirLocalizarRepresentante(){
        popLocate(23,"Representante","","");
    }
    function abrirLocalizarRecebedor(){
        popLocate(79,"Recebedor","","");
    }
    function abrirLocalizarExpedidor(){
        popLocate(78,"Expedidor","","");
    }
    
    function abrirLocalizarGSM(){
        abrirLocaliza("ConhecimentoControlador?acao=localizarGSM&modulo=gwLogis&tipo=entrada", "locCfopEntradaLogis");
    }
    
    function abrirLocalizarCarga(){
        abrirJanela("ConhecimentoControlador?acao=localizarCarga", "locGwConferencia", 80, 80);
    }
    function abrirLocalizarDestinatarioNotaFiscal(){
        popLocate(04,"Destinatario_NotaFiscal","","");
    }
    function abrirLocalizarRemetenteNotaFiscal(){
        popLocate(03,"Remetente_NotaFiscal","","");
    }
    
    function limparCliente(){
        $("razaoSocialCliente").value = "";
        $("idCliente").value = "0";
        removerSelect();
        povoarSelect($("layoutArquivo"), listaLayoutClienteEdiNotfisPadrao);
        alterarLayout($("layoutArquivo").value);
        filtrosLayoutPadraoImportacao();
        var liberarLayout = ($("idCliente").value == 0 ? "false" : "true");
        readOnlyCamposFiltroLayoutImportacao(liberarLayout);
    }    
    function limparRedespacho(){
        $("razaoSocialRedespacho").value = "";
        $("idRedespacho").value = "0";
    }
    function limparDestinatario(){
        $("razaoSocialDestinatario").value = "";
        $("idDestinatario").value = "0";
    }
    function limparRemetente(){
        $("razaoSocialRemetente").value = "";
        $("idRemetente").value = "0";
    }    
    function limparConsignatario(){
        $("razaoSocialConsignatario").value = "";
        $("idConsignatario").value = "0";
    }
    function limparRepresentante(){
        $("razaoSocialRepresentante").value = "";
        $("idRepresentante").value = "0";
    }
    function limparRecebedor(){
        $("razaoSocialRecebedor").value = "";
        $("idRecebedor").value = "0";
    }
    function limparExpedidor(){
        $("razaoSocialExpedidor").value = "";
        $("idExpedidor").value = "0";
    }
    function limparRemetenteNotaFiscal(){
        $("razaoSocialRemetenteNotaFiscal").value = "";
        $("idRemetenteNotaFiscal").value = "0";
    }
    function limparDestinatarioNotaFiscal(){
        $("razaoSocialDestinatarioNotaFiscal").value = "";
        $("idDestinatarioNotaFiscal").value = "0";
    }
    
    function aoClicarNoLocaliza(idjanela){

        if (idjanela == "Cliente") {
            $("idCliente").value = $("idconsignatario").value;
            $("razaoSocialCliente").value = $("con_rzs").value;
            $("cnpjCliente").value = $("con_cnpj").value;            
            carregarFiltrosImportacaoNotfis($("idCliente").value);             
        }else if (idjanela == "Consignatario") {
            $("idConsignatario").value = $("idconsignatario").value;
            $("razaoSocialConsignatario").value = $("con_rzs").value;
        }else if (idjanela == "Redespacho") {
            $("idRedespacho").value = $("idredespacho").value;
            $("razaoSocialRedespacho").value = $("red_rzs").value;    
        }else if (idjanela == "Destinatario") {
            $("idDestinatario").value = $("iddestinatario").value;
            $("razaoSocialDestinatario").value = $("dest_rzs").value;                        
        }else if (idjanela == "Remetente") {
            $("idRemetente").value = $("idremetente").value;
            $("razaoSocialRemetente").value = $("rem_rzs").value;                        
        }else if (idjanela == "Representante") {
            $("idRepresentante").value = $("idredespachante").value;
            $("razaoSocialRepresentante").value = $("redspt_rzs").value;                        
        }else if (idjanela == "Recebedor") {
            $("idRecebedor").value = $("idrecebedor").value;
            $("razaoSocialRecebedor").value = $("rec_rzs").value;                        
        }else if (idjanela == "Expedidor") {
            $("idExpedidor").value = $("idexpedidor").value;
            $("razaoSocialExpedidor").value = $("exp_rzs").value;                
        }else if (idjanela == 'Remetente_NotaFiscal') {
            $("razaoSocialRemetenteNotaFiscal").value = $("rem_rzs").value;
            $("idRemetenteNotaFiscal").value = $("idremetente").value;
            $("cnpjRemetente").value = $("rem_cnpj").value;
            
        }else if (idjanela == 'Destinatario_NotaFiscal') {
            $("razaoSocialDestinatarioNotaFiscal").value = $("dest_rzs").value;
            $("idDestinatarioNotaFiscal").value = $("iddestinatario").value;    
        }
    }
    
    //Função para carregar os filtros que foram cadastrado no cliente.
    function carregarFiltrosImportacaoNotfis(idCliente) {
        var razaoSocialCliente = $("razaoSocialCliente").value;
        var cnpjCliente = $("cnpjCliente").value;
        removerSelect();
        listaLayoutClienteEdiNotfis = new Array();
        jQuery.ajax({
            url: '${homePath}/ClienteControlador',
            dataType: "json",
            method: "post",
            data: {
                idCliente: idCliente,
                acao: "carregarFiltrosImportacaoNotfis"
            },
            success: function (clienteLayoutEdi) {
                if (clienteLayoutEdi.length == 0) {
                    alert("Atenção: O Cliente: '" + razaoSocialCliente + "'\n CPF/CNPJ: '" + cnpjCliente + "', não possui layout edi notfis cadastrado, por isso não pode ser utilizado!");
                    limparCliente();
                } else {
                    listLayoutEdi = clienteLayoutEdi;

                    for (var i = 0; i < clienteLayoutEdi.length; i++) {
                        let ediLayout = clienteLayoutEdi[i];

                        <c:choose>
                            <c:when test="${param.tipoImportacao == 'unico'}">
                                // Quando for novo conhecimento vai validar apenas três layouts NF-e, Chave Acesso e CT-e, estão os layouts que estiverem cadastrado no cliente e for diferentes,
                                // não vai aparecer. por exemplo: Cliente XXXXX tem o layout Ipiranga, na tela de novo conhecimento não vai aparecer Ipiranga.
                                // Caso seja a tela de importação em lote, vai pegar todos os layouts que estiverem cadastrado no cliente.
                                if (ediLayout.layoutEDI.codigoLayout == "1" || ediLayout.layoutEDI.codigoLayout == "2" || ediLayout.layoutEDI.codigoLayout == "3" || ediLayout.layoutEDI.codigoLayout == "55") {
                                    listaLayoutClienteEdiNotfis[++countLayoutEdi] = new Option(ediLayout.layoutEDI.codigoLayout, ediLayout.layoutEDI.descricao);
                                }
                            </c:when>
                            <c:otherwise>
                                listaLayoutClienteEdiNotfis[++countLayoutEdi] = new Option(ediLayout.layoutEDI.codigoLayout, ediLayout.layoutEDI.descricao);
                            </c:otherwise>
                        </c:choose>
                    }

                    if (listaLayoutClienteEdiNotfis.length === 0) {
                        alert("Atenção: O Cliente: '" + razaoSocialCliente + "'\n CPF/CNPJ: '" + cnpjCliente + "', não possui layout edi notfis cadastrado, por isso não pode ser utilizado!");
                        limparCliente();
                    } else {
                        povoarSelect($("layoutArquivo"), listaLayoutClienteEdiNotfis);
                        alterarLayout($("layoutArquivo").value);
                    }
                }
            }
        });
    }
    
    //Função para remover todos os option do select de layout.
    function removerSelect(){                
        jQuery('#layoutArquivo option').remove();
        
        listaLayoutClienteEdiNotfis = "";
        countLayoutEdi = 0; 
    }
    
    function carregar(){
        try{

            window.onbeforeunload = null;
            var ctrc;
            var nf;
            var nf;
            var index= 0;
            var indexCubagem = 0;
            var pai = window.opener;
            var paiDoc = pai.document;
            var cubagem;
            var apoioNotas = 0;
            var merc;
            var qtdCubagem = 0;
            var listaCubagens;
            var indexMerc = 0;
            var listaMercadoria;
            var isAgrupar = ${param.isAgrupar};
            var isDadosVeiculo = ${param.isDadosVeiculo};
            var perguntarAddVariasNotasCtrc = (isAgrupar == true ? false : true);
            var isRedespacho = ${param.isRedespacho};
            var isRecebedor = ${param.isRecebedor};
            var isExpedidor = ${param.isExpedidor};
            var isRepresentante = ${param.isRepresentante};
            var isConsiderarPedidoAgrupamento = ${param.isAgruparPedido};
            var layoutArquivo = '${param.layoutArquivo}';           
            var isAtualizarCadastroCliente = ${param.isAtualizarCadastroCliente};
            var isAtualizarMercadoria = ${param.isAtualizarMercadoria};
            var isImportarNfItem = ${param.isImportarNfItem};
            var isAgruparPorVeiculo = ${param.isAgruparPorVeiculo};
            var agruparNfUfDestino = (${param.agruparNfUfDestino == '' ? false : param.agruparNfUfDestino});
            var isGerarCTePorNumeroFRS = (${ param.isGerarCTePorNumeroFRS == null || param.isGerarCTePorNumeroFRS == ''? false : param.isGerarCTePorNumeroFRS});
            var isSubContrato = ${param.isSubContrato};
            var agruparNFeEmissao = "${param['agruparNFeEmissao']}" === "true";

            var isConsiderarCtrcRedespacho = false;
            
            $("emissaoDe").value = '<c:out value="${param.emissaoDe}"/>';
            $("emissaoAte").value = '<c:out value="${param.emissaoAte}"/>';
            
            //Ao carregar a tela faço a condição, caso seja novo conhecimento pega apenas três layout padrão, se for importação em lote vai aparecer todos os layout do banco.
            <c:choose>
              <c:when test="${param.tipoImportacao != 'unico'}">
                <c:forEach var="notfis" varStatus="status" items="${listaLayoutNOTFIS}">
                    listaLayoutClienteEdiNotfisPadrao[++countLayoutEdiPadrao] = new Option('${notfis.codigoLayout}','${notfis.descricao}');
                </c:forEach>
              </c:when>
              <c:otherwise>    
                    listaLayoutClienteEdiNotfisPadrao[++countLayoutEdiPadrao] = new Option('1','NF-e (XML)');
                    listaLayoutClienteEdiNotfisPadrao[++countLayoutEdiPadrao] = new Option('2','NF-e (Chave de Acesso)');
                    listaLayoutClienteEdiNotfisPadrao[++countLayoutEdiPadrao] = new Option('3','CT-e Redespacho (XML)');
                    listaLayoutClienteEdiNotfisPadrao[++countLayoutEdiPadrao] = new Option('49','Cimento Nacional'); // esse código é o que está cadastrado na tabela layout_edi
                    listaLayoutClienteEdiNotfisPadrao[++countLayoutEdiPadrao] = new Option('55','NF-e (XML Sincronizados por E-mail/SEFAZ)'); // esse código é o que está cadastrado na tabela layout_edi
              </c:otherwise>
            </c:choose>
            
            //Preenche os option do select layoutArquivo dos layouts.
            povoarSelect($("layoutArquivo"), listaLayoutClienteEdiNotfisPadrao);
            
            if(layoutArquivo != ""){
                $("layoutArquivo").value = layoutArquivo;
            }
           
            alterarLayout($("layoutArquivo").value);
            


            filtrosLayoutPadraoImportacao();
            
            //pega as informações de configurações.
            if (isAtualizarCadastroCliente) {    
                $("atualizarCadDestinatarioSim").checked = true;
            }else{
                $("atualizarCadDestinatarioNao").checked = true;                
            }
            
            if (isAtualizarCadastroCliente) {                
                $("atualizarCadRemetenteSim").checked = true;
            }else{
                $("atualizarCadRemetenteNao").checked = true;                
            }
            
            if (isAtualizarCadastroCliente) {                
                $("atualizarEndDestinatarioSim").checked = true;
            }else{
                $("atualizarEndDestinatarioNao").checked = true;        
            }
            
            if (isAtualizarMercadoria) {
                $("cadastrarMercadoriaSim").checked = true;
            }else{
                $("cadastrarMercadoriaNao").checked = true;                
            }
            
            if (isImportarNfItem) {
                $("importarItemNfSim").checked = true;
            }else{
                $("importarItemNfNao").checked = true;                
            }
            
            if (isSubContrato) {
                $("inpSubContratacaoSim").checked = true;
                pai.$("tipoServico").value = "s";
            }else{
                $("inpSubContratacaoNao").checked = true;                
            }
            
            let tbodyAdicionarTags = jQuery('#tbodyTagsPersonalizadas');

            jQuery('#btnAdicionarTags').on('click', () => aoClicarAdicionarTags(undefined));
            
            tbodyAdicionarTags.on('click', '.excluirTagAdicional', (e) => aoClicarExcluirTag(jQuery(e.target)));
            
            <c:forEach var="ctrc" varStatus="status" items="${ctrcs}">                    
                ctrc = new CTRC();
                ctrc.cfopId = "${ctrc.cfop.idcfop}";
                ctrc.cfop = "${ctrc.cfop.cfop}"; 
                ctrc.taxaRoubo = "${ctrc.taxaSeguroRoubo}";
                ctrc.taxaRouboUrbano = "${ctrc.taxaSeguroRouboUrbano}";
                ctrc.taxaTombamento = "${ctrc.taxaSeguroTombamento}";
                ctrc.taxaTombamentoUrbano = "${ctrc.taxaSeguroTombamentoUrbano}";
                ctrc.taxaTombamentoUrbano = "${ctrc.taxaSeguroTombamentoUrbano}";
                ctrc.cubagemMetro = "${ctrc.cubagemMetro}";
                ctrc.numeroContainer = "${ctrc.numeroContainer}";
                ctrc.numero = "${ctrc.numero}";
                ctrc.serie = "${ctrc.serie}";
                ctrc.chaveCte = "${ctrc.chaveCte}";
                ctrc.emissaoEm = "${ctrc.emissaoEmS}";
                ctrc.emissaoAs = "${ctrc.emissaoAs}";
               
                ctrc.numeroCarga = "${ctrc.numeroCarga}";
                ctrc.pedido = "${ctrc.pedidoCliente}";
                ctrc.previsaoEntrega = "${ctrc.previsaoEntrega}";
                ctrc.idRota = "${ctrc.rota.id}";
                ctrc.rota = "${ctrc.rota.descricao}";
                ctrc.distancisKm = "${ctrc.distanciaOrigemDestino}";
                ctrc.tipoFrete = "${ctrc.tipoTaxa}";
                ctrc.valorFreteValor  = "${ctrc.valorFrete}";
                ctrc.isPodeAlterar = "${ctrc.podeAlterar}";
                ctrc.layoutArquivo = layoutArquivo;
                ctrc.tipoCteImpLote = "${ctrc.tipo}";
                ctrc.observacaoComplementar = "${ctrc.observacaoComplementar}";
                ctrc.cubagemBase = "${ctrc.cubagemBase}";
                ctrc.cubagemMetro = "${ctrc.cubagemMetro}";
                ctrc.subContrato = isSubContrato;

                
                <c:forEach var="obs" varStatus="status" items="${ctrc.observacao}">
                            ctrc.observacao += "${obs}";
                </c:forEach>
                    
                ctrc.consignatario.listaTipoProduto = new Array();
                var countOptTpProd = 0;
                <c:forEach var="tipo" varStatus="status" items="${ctrc.cliente.tipoProduto}">
                    ctrc.consignatario.listaTipoProduto[countOptTpProd++] = new Option('${tipo.id}', '${tipo.descricao}');            
                </c:forEach>
            
                ctrc.remetente.listaTipoProduto = new Array();
                countOptTpProd = 0;
                <c:forEach var="tipo" varStatus="status" items="${ctrc.remetente.tipoProduto}">
                    ctrc.remetente.listaTipoProduto[countOptTpProd++] = new Option('${tipo.id}', '${tipo.descricao}');            
                </c:forEach>
            
                ctrc.destinatario.listaTipoProduto = new Array();
                countOptTpProd = 0;
                <c:forEach var="tipo" varStatus="status" items="${ctrc.destinatario.tipoProduto}">
                    ctrc.destinatario.listaTipoProduto[countOptTpProd++] = new Option('${tipo.id}', '${tipo.descricao}');            
                </c:forEach>
            
                ctrc.redespacho.listaTipoProduto = new Array();
                countOptTpProd = 0;
                <c:forEach var="tipo" varStatus="status" items="${ctrc.redespacho.tipoProduto}">
                    ctrc.redespacho.listaTipoProduto[countOptTpProd++] = new Option('${tipo.id}', '${tipo.descricao}');            
                </c:forEach>
                    
                if ("${param.fontePreco}" == "a" ) {
                    if (pai.$("fontePreco") != null && pai.$("fontePreco") != undefined) {
                        pai.$("fontePreco").value = "${param.fontePreco}";
                    }
                    ctrc.tipoFrete = 3;
                    ctrc.valorFretePeso = "${ctrc.valorPeso}";
                    ctrc.valorTaxaFixa = "${ctrc.valorTaxaFixa}";
                    ctrc.valorFreteValor  = "${ctrc.valorFrete}";
                    ctrc.valorPedagio  = "${ctrc.valorPedagio}";
                    //isAgrupar = false;
                }

                //*************************CONSIGNATARIO********************************
                    ctrc.consignatario.razaoSocial = "${ctrc.cliente.razaosocial}";
                    ctrc.consignatario.id = "${ctrc.cliente.idcliente}";
                    ctrc.consignatario.cnpj = "${ctrc.cliente.cnpj}";
                    ctrc.consignatario.cidadeId = "${ctrc.cliente.cidade.idcidade}";
                    ctrc.consignatario.cidade = "${ctrc.cliente.cidade.descricaoCidade}";
                    ctrc.consignatario.uf = "${ctrc.cliente.cidade.uf}";
                    ctrc.consignatario.endereco = "${ctrc.cliente.endereco}";
                    ctrc.consignatario.isCreditoBloqueado = "${ctrc.cliente.creditoBloqueado}";
                    ctrc.consignatario.creditoDisponivel = "${ctrc.cliente.creditoDisponivel}";
                    ctrc.consignatario.tipoCGC = "${ctrc.cliente.cidade.descricaoCidade}";
                    ctrc.consignatario.tipoCfop = "${ctrc.cliente.tipoCfop}";
                    ctrc.consignatario.inscEst = "${ctrc.cliente.inscest}";
                    ctrc.consignatario.isStMG = "${ctrc.cliente.substituicaoTributariaMinasGerais}";
                    ctrc.consignatario.obrigaTabelaTipoProduto = "${ctrc.cliente.tabelaTipoProduto}";
                    ctrc.consignatario.utilizaTipoFreteTabela = "${ctrc.cliente.utilizarTipoFreteTabela}";
                    ctrc.consignatario.utilizaPautaFiscal = "${ctrc.cliente.utilizaPautaFiscal}";
                    ctrc.consignatario.tipoOrigemFrete = "${ctrc.cliente.tipoOrigemFrete}";
                    ctrc.consignatario.tipoTabela = "${ctrc.cliente.tipo_tabela}";
                    ctrc.consignatario.stIcms = "${ctrc.cliente.stIcms.id}";
                    ctrc.consignatario.reducaoIcms = "${ctrc.cliente.reducaoIcms}";
                    ctrc.consignatario.isUtilizarNormativaGSF598GO = "${ctrc.cliente.utilizarNormativaGSF598GO}";
                    ctrc.consignatario.creditoPresumido = "${ctrc.cliente.percentualCreditoPresumido}";
                    ctrc.consignatario.utilizarNormativaGSF129816GO = "${ctrc.cliente.utilizarNormativaGSF129816GO}";
                    ctrc.consignatario.obs = adicionarEnterObs("${fn:replace(ctrc.cliente.observacao, '"', '')}");
                    ctrc.consignatario.tipoPgto = "${ctrc.cliente.tipoPagtoFrete}";
                    ctrc.consignatario.qtdDiasPgto = "${ctrc.cliente.condicaoPgt}";
                    ctrc.consignatario.percComissaoVendedor = "${ctrc.cliente.vlcomissaoVendedor}";
                    ctrc.consignatario.unificadaModalVendedor = "${ctrc.cliente.tipoComissaoVendedor}";
                    ctrc.consignatario.percComissaoRodoviarioFracionadoVendedor = "${ctrc.cliente.comissaoRodoviarioFracionadoVendedor}";
                    ctrc.consignatario.percComissaoRodoviarioLotacaoVendedor = "${ctrc.cliente.comissaoRodoviarioLotacaoVendedor}";                    
                    ctrc.consignatario.vendedor.razaoSocial = "${ctrc.cliente.vendedor.razaosocial}";
                    ctrc.consignatario.vendedor.id = "${ctrc.cliente.vendedor.id}";
                    ctrc.consignatario.percComissaoVendedor = "${ctrc.cliente.vlcomissaoVendedor}";
                    ctrc.consignatario.mensagemUsuarioCte = "${fn:replace(ctrc.cliente.msgClienteCte, '"', '')}";
                    ctrc.consignatario.tipoArredondamentoPeso = "${ctrc.cliente.tipoArredondamentoPeso}";
                    ctrc.consignatario.tipoTributacao = "${ctrc.consignatario.tipoTributacao}";
                    ctrc.consignatario.travaCamposImportacao = "${ctrc.modalidadeFrete == 0 ? (ctrc.cliente.travaCamposImportacao || ctrc.remetente.travaCamposImportacao) : (ctrc.cliente.travaCamposImportacao || ctrc.destinatario.travaCamposImportacao)}";
                    ctrc.consignatario.utilizarTabelaCliente = "${ctrc.consignatario.utilizarTabelaCliente.id}";
                    ctrc.consignatario.especieSerieModal = "${ctrc.cliente.especieSerieModal}";
                    ctrc.consignatario.especie = "${ctrc.cliente.especie}";
                    ctrc.consignatario.serie = "${ctrc.cliente.serie}";
                    ctrc.consignatario.modalCliente = "${ctrc.cliente.modalCliente}";
                    ctrc.consignatario.gerarNfseCidadeOrigemDestinoCteLote = "${ctrc.cliente.gerarNfseCidadeOrigemDestinoCteLote}";
                    ctrc.consignatario.tipoGeracaoNfseCidadeOrigemDestinoCteLote = "${ctrc.cliente.tipoGeracaoNfseCidadeOrigemDestinoCteLote}";
                    ctrc.consignatario.serieMinuta = "${ctrc.cliente.serieMinuta}";
                    //*************************CONSIGNATARIO********************************
                    
                    //***************************REMETENTE**********************************
                    ctrc.remetente.razaoSocial = "${ctrc.remetente.razaosocial}";
                    ctrc.remetente.id = "${ctrc.remetente.idcliente}";
                    ctrc.remetente.cnpj = "${ctrc.remetente.cnpj}";
                    ctrc.remetente.cidadeId = "${ctrc.remetente.cidade.idcidade}";
                    ctrc.remetente.cidade = "${ctrc.remetente.cidade.descricaoCidade}";
                    ctrc.remetente.endereco = "${ctrc.remetente.endereco}";
                    ctrc.remetente.utilizaTipoFreteTabela = "${ctrc.remetente.utilizarTipoFreteTabela}";
                    ctrc.remetente.bairro = "${ctrc.remetente.bairro}";
                    ctrc.remetente.complemento = "${ctrc.remetente.complemento}";
                    ctrc.remetente.logradouro = "${ctrc.remetente.numeroLogradouro}";
                    
                    ctrc.remetente.uf = "${ctrc.remetente.cidade.uf}";
                    ctrc.cidadeOrigem = "${ctrc.remetente.cidade.descricaoCidade}";
                    ctrc.idCidadeOrigem = "${ctrc.remetente.cidade.idcidade}";
                    ctrc.ufOrigem = "${ctrc.remetente.cidade.uf}";
                    ctrc.remetente.tipoCfop = "${ctrc.remetente.tipoCfop}";
                    ctrc.remetente.inscEst = "${ctrc.remetente.inscest}";
                    ctrc.remetente.isStMG = "${ctrc.remetente.substituicaoTributariaMinasGerais}";
                    ctrc.remetente.isCreditoBloqueado = "${ctrc.remetente.creditoBloqueado}";
                    ctrc.remetente.isAnaliseCredito = "${ctrc.remetente.analiseCredito}";
                    ctrc.remetente.creditoDisponivel = "${ctrc.remetente.creditoDisponivel}";
                    ctrc.remetente.obrigaTabelaTipoProduto = "${ctrc.remetente.tabelaTipoProduto}";
                    ctrc.remetente.incluiPesoContainer = "${ctrc.remetente.incluiContainerFretePeso}";
                    ctrc.remetente.percComissaoVendedor = "${ctrc.remetente.vlcomissaoVendedor}";
                    ctrc.remetente.unificadaModalVendedor = "${ctrc.remetente.tipoComissaoVendedor}";
                    ctrc.remetente.percComissaoRodoviarioFracionadoVendedor = "${ctrc.remetente.comissaoRodoviarioFracionadoVendedor}";
                    ctrc.remetente.percComissaoRodoviarioLotacaoVendedor = "${ctrc.remetente.comissaoRodoviarioLotacaoVendedor}";
                
                    ctrc.remetente.utilizaPautaFiscal = "${ctrc.remetente.utilizaPautaFiscal}";
                    ctrc.remetente.tipoOrigemFrete = "${ctrc.remetente.tipoOrigemFrete}";
                    ctrc.remetente.tipoTabela = "${ctrc.remetente.tipo_tabela}";
                    ctrc.remetente.stIcms = "${ctrc.remetente.stIcms.id}";
                    ctrc.remetente.reducaoIcms = "${ctrc.remetente.reducaoIcms}";
                    ctrc.remetente.isUtilizarNormativaGSF598GO = "${ctrc.remetente.utilizarNormativaGSF598GO}";
                    ctrc.remetente.creditoPresumido = "${ctrc.remetente.percentualCreditoPresumido}";
                    ctrc.remetente.utilizarNormativaGSF129816GO = "${ctrc.remetente.utilizarNormativaGSF129816GO}";
                    ctrc.remetente.obs = "${fn:replace(ctrc.remetente.observacao, '"', '')}";
                    ctrc.remetente.tipoPgto = "${ctrc.remetente.tipoPagtoFrete}";
                    ctrc.remetente.qtdDiasPgto = "${ctrc.remetente.condicaoPgt}";
                    ctrc.tipoProduto = "${ctrc.tipoProduto.id}";

                    ctrc.remetente.utilizarTabelaRemetente = "${ctrc.remetente.utilizaTabelaRemetente}";
                    ctrc.remetente.vendedor.razaoSocial = "${ctrc.remetente.vendedor.razaosocial}";
                    ctrc.remetente.vendedor.id = "${ctrc.remetente.vendedor.id}";
                    ctrc.remetente.percComissaoVendedor = "${ctrc.remetente.vlcomissaoVendedor}";
                    ctrc.remetente.tipoDocumentoPadrao = "${ctrc.remetente.tipoDocumentoPadrao}";                
                    ctrc.remetente.mensagemUsuarioCte = "${fn:replace(ctrc.remetente.msgClienteCte, '\"', '')}";
                    ctrc.remetente.tipoArredondamentoPeso = "${ctrc.remetente.tipoArredondamentoPeso}";
                    ctrc.remetente.isFreteDirigido = "${ctrc.remetente.freteDirigido}";
                    ctrc.remetente.tipoTributacao = "${ctrc.remetente.tipoTributacao}";
                    ctrc.remetente.travaCamposImportacao = "${ctrc.remetente.travaCamposImportacao}";
                    ctrc.remetente.utilizarTabelaCliente = "${ctrc.remetente.utilizarTabelaCliente.id}";
                    ctrc.remetente.especieSerieModal = "${ctrc.remetente.especieSerieModal}";
                    ctrc.remetente.especie = "${ctrc.remetente.especie}";
                    ctrc.remetente.serie = "${ctrc.remetente.serie}";
                    ctrc.remetente.modalCliente = "${ctrc.remetente.modalCliente}";
                    ctrc.remetente.gerarNfseCidadeOrigemDestinoCteLote = "${ctrc.remetente.gerarNfseCidadeOrigemDestinoCteLote}";
                    ctrc.remetente.tipoGeracaoNfseCidadeOrigemDestinoCteLote = "${ctrc.remetente.tipoGeracaoNfseCidadeOrigemDestinoCteLote}";
                    ctrc.remetente.serieMinuta = "${ctrc.remetente.serieMinuta}";
                    //***************************REMETENTE**********************************
                    
                    //***************************DESTINATARIO*******************************
                    ctrc.destinatario.razaoSocial = "${ctrc.destinatario.razaosocial}";
                    ctrc.destinatario.id = "${ctrc.destinatario.idcliente}";
                    ctrc.destinatario.cnpj = "${ctrc.destinatario.cnpj}";
                    ctrc.destinatario.reducaoIcms = "${ctrc.destinatario.reducaoIcms}";
                    ctrc.destinatario.isIncluirTde = "${ctrc.destinatario.cobrarTde}";
                    ctrc.isCobrarTde = ("${ctrc.destinatario.cobrarTde}" == "true" || "${ctrc.destinatario.cobrarTde}" == "t");
                    ctrc.destinatario.utilizaTipoFreteTabela = "${ctrc.destinatario.utilizarTipoFreteTabela}";
                    ctrc.destinatario.inscEst = "${ctrc.destinatario.inscest}";
                    ctrc.destinatario.isStMG = "${ctrc.destinatario.substituicaoTributariaMinasGerais}";
                    ctrc.destinatario.isCreditoBloqueado = "${ctrc.destinatario.creditoBloqueado}";
                    ctrc.destinatario.isAnaliseCredito = "${ctrc.destinatario.analiseCredito}";
                    ctrc.destinatario.creditoDisponivel = "${ctrc.destinatario.creditoDisponivel}";
                    ctrc.destinatario.obs = "${fn:replace(ctrc.destinatario.observacao, '"', '')}";
                    ctrc.destinatario.tipoOrigemFrete = "${ctrc.destinatario.tipoOrigemFrete}";
                    ctrc.destinatario.cidadeId = "${ctrc.destinatario.cidade.idcidade}";
                    ctrc.destinatario.cidade = "${ctrc.destinatario.cidade.descricaoCidade}";
                    ctrc.destinatario.uf = "${ctrc.destinatario.cidade.uf}";
                    ctrc.destinatario.endereco = "${ctrc.destinatario.endereco}";                    
                    ctrc.destinatario.bairro = "${ctrc.destinatario.bairro}";
                    ctrc.destinatario.complemento = "${ctrc.destinatario.complemento}";
                    ctrc.destinatario.logradouro = "${ctrc.destinatario.numeroLogradouro}";
                    ctrc.destinatario.stIcms = "${ctrc.destinatario.stIcms.id}";
                    ctrc.destinatario.reducaoIcms = "${ctrc.destinatario.reducaoIcms}";
                    ctrc.destinatario.isUtilizarNormativaGSF598GO = "${ctrc.destinatario.utilizarNormativaGSF598GO}";
                    ctrc.destinatario.creditoPresumido = "${ctrc.destinatario.percentualCreditoPresumido}";
                    ctrc.destinatario.utilizarNormativaGSF129816GO = "${ctrc.destinatario.utilizarNormativaGSF129816GO}";
                    ctrc.destinatario.tipoPgto = "${ctrc.destinatario.tipoPagtoFrete}";
                    ctrc.destinatario.qtdDiasPgto = "${ctrc.destinatario.condicaoPgt}";
                    ctrc.destinatario.incluiPesoContainer = "${ctrc.destinatario.incluiContainerFretePeso}";
                    ctrc.idCidadeDestino = "${ctrc.destinatario.cidade.idcidade}";
                    ctrc.cidadeDestino = "${ctrc.destinatario.cidade.descricaoCidade}";
                    ctrc.ufDestino = "${ctrc.destinatario.cidade.uf}";
                    ctrc.destinatario.tipoTabela = "${ctrc.destinatario.tipo_tabela}";            
                    ctrc.destinatario.utilizaPautaFiscal = "${ctrc.destinatario.utilizaPautaFiscal}";
                    ctrc.destinatario.obrigaTabelaTipoProduto = "${ctrc.destinatario.tabelaTipoProduto}";
                    ctrc.destinatario.tipoCfop = "${ctrc.destinatario.tipoCfop}";
                    ctrc.destinatario.utilizarTabelaRemetente = "${ctrc.destinatario.utilizaTabelaRemetente}";
                    ctrc.destinatario.percComissaoVendedor = "${ctrc.destinatario.vlcomissaoVendedor}";
                    ctrc.destinatario.unificadaModalVendedor = "${ctrc.destinatario.tipoComissaoVendedor}";
                    ctrc.destinatario.percComissaoRodoviarioFracionadoVendedor = "${ctrc.destinatario.comissaoRodoviarioFracionadoVendedor}";
                    ctrc.destinatario.percComissaoRodoviarioLotacaoVendedor = "${ctrc.destinatario.comissaoRodoviarioLotacaoVendedor}";
                    ctrc.destinatario.vendedor.razaoSocial = "${ctrc.destinatario.vendedor.razaosocial}";
                    ctrc.destinatario.vendedor.id = "${ctrc.destinatario.vendedor.id}";
                    ctrc.destinatario.percComissaoVendedor = "${ctrc.destinatario.vlcomissaoVendedor}";
                    ctrc.destinatario.mensagemUsuarioCte = "${fn:replace(ctrc.destinatario.msgClienteCte, '"', '')}";
                    ctrc.destinatario.tipoArredondamentoPeso = "${ctrc.destinatario.tipoArredondamentoPeso}";
                    ctrc.destinatario.tipoTributacao = "${ctrc.destinatario.tipoTributacao}";
                    ctrc.destinatario.tipoProdutoDestinatario = "${ctrc.destinatario.tipoProdutoDestinatario.id}";
                    ctrc.destinatario.utilizarTabelaCliente = "${ctrc.destinatario.utilizarTabelaCliente.id}";
                    ctrc.destinatario.travaCamposImportacao = "${ctrc.destinatario.travaCamposImportacao}";
                    ctrc.destinatario.especieSerieModal = "${ctrc.destinatario.especieSerieModal}";
                    ctrc.destinatario.especie = "${ctrc.destinatario.especie}";
                    ctrc.destinatario.serie = "${ctrc.destinatario.serie}";
                    ctrc.destinatario.modalCliente = "${ctrc.destinatario.modalCliente}";
                    ctrc.destinatario.gerarNfseCidadeOrigemDestinoCteLote = "${ctrc.destinatario.gerarNfseCidadeOrigemDestinoCteLote}";
                    ctrc.destinatario.tipoGeracaoNfseCidadeOrigemDestinoCteLote = "${ctrc.destinatario.tipoGeracaoNfseCidadeOrigemDestinoCteLote}";
                    ctrc.destinatario.serieMinuta = "${ctrc.destinatario.serieMinuta}";

                    //cidade de origem e destino
                    ctrc.cidadeOrigem = "${ctrc.cidadeOrigem.descricaoCidade}";
                    ctrc.ufOrigem = "${ctrc.cidadeOrigem.uf}";
                    ctrc.idCidadeOrigem = "${ctrc.cidadeOrigem.idcidade}";
                    ctrc.cidadeDestino = "${ctrc.cidadeDestino.descricaoCidade}";
                    ctrc.idCidadeDestino = "${ctrc.cidadeDestino.idcidade}";            
                    ctrc.ufDestino = "${ctrc.cidadeDestino.uf}";
                    ctrc.modFrete= "${ctrc.modalidadeFrete}";
                    ctrc.enderecoEntregaId = "${ctrc.enderecoEntrega.id}";
                    ctrc.enderecoColetaId = "${ctrc.enderecoColeta.id}";
                    //o parametro de comparação($("layoutArquivo").value) esta chegando vazio alterei ctrc.layoutArquivo: 
                    if (ctrc.layoutArquivo == "4") {
                        ctrc.stICMS = "${ctrc.stIcms.id}";
                        ctrc.aliquotaIcms = "${ctrc.aliquota}";
                    }
                    //***************************DESTINATARIO*******************************
                    
                    //****************************REDESPACHO********************************
                    ctrc.redespacho.razaoSocial = "${ctrc.redespacho.razaosocial}";            
                    ctrc.redespacho.id = "${ctrc.redespacho.idcliente}";
                    ctrc.redespacho.cnpj = "${ctrc.redespacho.cnpj}";
                    ctrc.redespacho.cidadeId = "${ctrc.redespacho.cidade.idcidade}";
                    ctrc.redespacho.cidade = "${ctrc.redespacho.cidade.descricaoCidade}";
                    ctrc.redespacho.uf = "${ctrc.redespacho.cidade.uf}";
                    ctrc.redespacho.tipoPgto = "${ctrc.redespacho.tipoPagtoFrete}";
                    ctrc.redespacho.qtdDiasPgto = "${ctrc.redespacho.condicaoPgt}";
                    ctrc.redespacho.tipoCfop = "${ctrc.redespacho.tipoCfop}";
                    ctrc.redespacho.inscEst = "${ctrc.redespacho.inscest}";
                    ctrc.redespacho.isStMG = "${ctrc.redespacho.substituicaoTributariaMinasGerais}";
                    ctrc.redespacho.isCreditoBloqueado = "${ctrc.redespacho.creditoBloqueado}";
                    ctrc.redespacho.isAnaliseCredito = "${ctrc.redespacho.analiseCredito}";
                    ctrc.redespacho.creditoDisponivel = "${ctrc.redespacho.creditoDisponivel}";
                    ctrc.redespacho.obrigaTabelaTipoProduto = "${ctrc.redespacho.tabelaTipoProduto}";
                    ctrc.redespacho.utilizaPautaFiscal = "${ctrc.redespacho.utilizaPautaFiscal}";
                    ctrc.redespacho.tipoOrigemFrete = "${ctrc.redespacho.tipoOrigemFrete}";            
                    ctrc.redespacho.tipoTabela = "${ctrc.redespacho.tipo_tabela}"; 
                    ctrc.redespacho.utilizarTabelaRemetente = "${ctrc.redespacho.utilizaTabelaRemetente}";
                    ctrc.redespacho.unificadaModalVendedor = "${ctrc.redespacho.tipoComissaoVendedor}";
                    ctrc.redespacho.utilizaTipoFreteTabela = "${ctrc.redespacho.utilizarTipoFreteTabela}";
                    ctrc.redespacho.percComissaoRodoviarioFracionadoVendedor = "${ctrc.redespacho.comissaoRodoviarioFracionadoVendedor}";
                    ctrc.redespacho.percComissaoRodoviarioLotacaoVendedor = "${ctrc.redespacho.comissaoRodoviarioLotacaoVendedor}";                    
                    ctrc.redespacho.vendedor.razaoSocial = "${ctrc.redespacho.vendedor.razaosocial}";
                    ctrc.redespacho.vendedor.id = "${ctrc.redespacho.vendedor.id}";
                    ctrc.redespacho.percComissaoVendedor = "${ctrc.redespacho.vlcomissaoVendedor}";                    
                    ctrc.redespachoCtrc = "${ctrc.redespachoCtrc}";
                    ctrc.redespachoValor = "${ctrc.redespachoValor}";
                    ctrc.redespachoValorIcms = "${ctrc.redespachoValorIcms}";
                    ctrc.redespachoChaveAcesso = "${ctrc.redespachoChaveAcesso}";
                    ctrc.redespacho.mensagemUsuarioCte = "${fn:replace(ctrc.redespacho.msgClienteCte, '"', '')}";
                    ctrc.redespacho.tipoArredodamentoPeso = "${ctrc.redespacho.tipoArredondamentoPeso}";
                    ctrc.redespacho.creditoPresumido = "${ctrc.redespacho.percentualCreditoPresumido}";
                    ctrc.redespacho.utilizarNormativaGSF129816GO = "${ctrc.redespacho.utilizarNormativaGSF129816GO}";
                    ctrc.redespacho.utilizarTabelaCliente = "${ctrc.redespacho.utilizarTabelaCliente.id}";
                    ctrc.redespacho.especieSerieModal = "${ctrc.redespacho.especieSerieModal}";
                    ctrc.redespacho.especie = "${ctrc.redespacho.especie}";
                    ctrc.redespacho.serie = "${ctrc.redespacho.serie}";
                    ctrc.redespacho.modalCliente = "${ctrc.redespacho.modalCliente}";
                    ctrc.redespacho.tipoTributacao = "${ctrc.redespacho.tipoTributacao}";
                    if("${ctrc.layoutEdi}"=="38" && ctrc.redespachoChaveAcesso != ""){
                        isRedespacho = true;
                    }
                
                    
                        if(isDadosVeiculo){
                            if ("${ctrc.motorista.bloqueado}" == 'true' || ("${ctrc.motorista.motivobloqueio}"  != '' )){//no cadmanifesto tem essa validação e a análise disse para copiar de lá.
                                alert('Esse motorista está bloqueado. Motivo: ' + "${ctrc.motorista.motivobloqueio}");
                                ctrc.motorista = "";
                                ctrc.idMotorista = "0";
                            }else{
                                ctrc.motorista = "${ctrc.motorista.nome}";
                                ctrc.idMotorista = "${ctrc.motorista.idmotorista}";
                            }
                            ctrc.veiculo = "${ctrc.veiculo.placa}";
                            ctrc.idVeiculo = "${ctrc.veiculo.idveiculo}";
                            ctrc.carreta = "${ctrc.carreta.placa}";
                            ctrc.idCarreta = "${ctrc.carreta.idveiculo}";
                            ctrc.bitrem = "${ctrc.biTrem.placa}";
                            ctrc.idBitrem = "${ctrc.biTrem.idveiculo}";
                        } else {
                            ctrc.veiculo = "";
                            ctrc.idVeiculo = "0";
                            ctrc.motorista = "";
                            ctrc.idMotorista = "0";
                            ctrc.carreta = "";
                            ctrc.idCarreta = "0";
                            ctrc.bitrem = "";
                            ctrc.idBitrem = "0";
                            
                        }
                        if (isRedespacho || (ctrc.redespacho != null && ctrc.redespacho.id != '0' && ctrc.redespacho.id != 0)) {                        
                            ctrc.isRedespacho = true;
                        }                  
                    //****************************REDESPACHO********************************
                    
                    //****************************REPRESENTANTE*****************************                    
                    ctrc.representante.razaoSocial = "${ctrc.redespachante.razaosocial}";            
                    ctrc.representante.id = "${ctrc.redespachante.idfornecedor}";
                    ctrc.representante.cnpj = "${ctrc.redespachante.cpfCnpj}";
                    //****************************REPRESENTANTE*****************************
                    
                    //****************************RECEBEDOR*********************************                    
                    ctrc.recebedor.razaoSocial = "${ctrc.recebedor.razaosocial}";
                    ctrc.recebedor.id = "${ctrc.recebedor.idcliente}";
                    ctrc.recebedor.cnpj = "${ctrc.recebedor.cnpj}";
                    ctrc.recebedor.cidadeId = "${ctrc.recebedor.cidade.idcidade}";
                    ctrc.recebedor.cidade = "${ctrc.recebedor.cidade.descricaoCidade}";
                    ctrc.recebedor.uf = "${ctrc.recebedor.cidade.uf}";
                    
                    if (isRecebedor || (ctrc.recebedor != null && ctrc.recebedor.id != '0' && ctrc.recebedor.id != 0)) {                        
                        ctrc.isRecebedor = true;
                    }                    
                    //****************************RECEBEDOR*********************************
                    
                    //****************************EXPEDIDOR*********************************                    
                    ctrc.expedidor.razaoSocial = "${ctrc.expedidor.razaosocial}";
                    ctrc.expedidor.id = "${ctrc.expedidor.idcliente}";
                    ctrc.expedidor.cnpj = "${ctrc.expedidor.cnpj}";
                    ctrc.expedidor.cidadeId = "${ctrc.expedidor.cidade.idcidade}";
                    ctrc.expedidor.cidade = "${ctrc.expedidor.cidade.descricaoCidade}";
                    ctrc.expedidor.uf = "${ctrc.expedidor.cidade.uf}";
                    
                    if (isExpedidor || (ctrc.expedidor != null && ctrc.expedidor.id != '0' && ctrc.expedidor.id != 0)) {                        
                        ctrc.isExpedidor = true;
                    }                    
                    //****************************EXPEDIDOR*********************************
                    ctrc.calcularPrazoEntregaTabelaPreco = '${param.calcularPrazoEntregaTabelaPreco}';
                    var isPrevaleceNotfis = "${ctrc.modalidadeFrete == 0 ? (ctrc.cliente.importarNotfisPrevalecerEtiqueta || ctrc.remetente.importarNotfisPrevalecerEtiqueta) : (ctrc.cliente.importarNotfisPrevalecerEtiqueta || ctrc.destinatario.importarNotfisPrevalecerEtiqueta)}";
                    var isGerarEtiqueta = "${ctrc.modalidadeFrete == 0 ? (ctrc.cliente.gerarNumeroEtiquetaIncluirNota || ctrc.remetente.gerarNumeroEtiquetaIncluirNota) : (ctrc.cliente.gerarNumeroEtiquetaIncluirNota || ctrc.destinatario.gerarNumeroEtiquetaIncluirNota)}";
                    <c:forEach var="nota" varStatus="status" items="${ctrc.notas}">
                        <c:if test="${status.first}">
                            if ('${param.layoutArquivo}' == '9' || '${param.layoutArquivo}' == '33' || '${param.layoutArquivo}' == '59' || '${param.layoutArquivo}' == '71') {
                                pai.$("pedido").value = '${ctrc.pedidoCliente}';
                                if ("${param.fontePreco}" == "a") {
                                    pai.$("valorFrete").value = colocarVirgula('${ctrc.valorFrete}');
                                    pai.$("isRatearValorFrete").checked = true;
                                    pai.$("trTipoRateio").style.display = "";
                                    habilitar(pai.$("btRateioValorFrete"));
                                    notReadOnly(pai.$("valorFrete"), "fieldMin");
                                    notReadOnly(pai.$("valorTotalTaxaFixa"),"fieldMin");
                                    notReadOnly(pai.$("valorAdvalorem"),"fieldMin");
                                    notReadOnly(pai.$("valorOutros"),"fieldMin");
                                }
                            }
                        </c:if>
                        apoioNotas++;
                        nf = new NotaFiscal();
                        nf.id = "${nota.idnotafiscal}";
                        //faz a condição de se não tiver numero vai trazer o numero, serie e data do redespacho - Historia 2943
                        nf.numero = "${nota.numero != null ? nota.numero : ctrc.redespachoCtrc}";
                        nf.serie = "${nota.serie != null ? nota.serie : ctrc.serie}";
                        nf.dataEmissao = "${nota.numero != null ? nota.emissaoStr : ctrc.emissaoEmS}";
                        nf.peso = "${nota.peso}";
                        nf.valor = "${nota.valor}";
                        nf.volume = parseFloat("${nota.volume}");
                        
                        nf.cfop = "${nota.cfop.cfop}";
                        nf.cfopId = "${nota.cfop.idcfop}";                       
                        nf.chaveNFe = "${nota.chaveNFe}";
                        nf.destinatario = "${ctrc.destinatario.razaosocial}";
                        nf.destinatarioId = "${ctrc.destinatario.idcliente}";
                        nf.baseCalculoIcm = "${nota.vl_base_icms}";
                        nf.icmsValor  = "${nota.vl_icms}";
                        nf.pedido= "${nota.pedido}";
                        nf.isExiste = ("${nota.existe}" == "true");
                        nf.conteudo = "${nota.conteudo}";
                        nf.embalagem = "${nota.embalagem}";
                        nf.observacao = "${nota.observacaoAgenda}";
                        nf.dataAgenda = "${nota.dataAgendaStr}";
                        nf.horaAgenda = "${nota.horaAgenda}";
                        nf.dataPrevisao = "${nota.previsaoEmStr}";
                        nf.horaPrevisao = "${nota.previsaoAs}";
                        nf.metroCubico = "${nota.metroCubico}";
                        //se não tiver numero da nota vai trazer o tipo como outros se não continua do jeito que era - Historia 2943
                        if ("${nota.numero}" == "")  {
                             ctrc.remetente.tipoDocumentoPadrao = "99";
                        }else{
                            nf.tipoDocumento = (nf.chaveNFe == "" ? "NF": "NE");
                        }
                        nf.cargaId = "${nota.carga.id}";
                        nf.tipoConhecimento = "${nota.tipoConhecimento}";
                        pai.console.log(isGerarEtiqueta == 'true');
                        pai.console.log(isPrevaleceNotfis == 'true');
                        if((isGerarEtiqueta == 'true' && isPrevaleceNotfis == 'true')){
                            nf.codigoBarras = "${nota.codigoBarras}";
                        }else if(isGerarEtiqueta == 'true' && isPrevaleceNotfis == 'false'){
                            nf.codigoBarras = "";
                        }else{
                            nf.codigoBarras = "${nota.codigoBarras}";
                        }
                        /**
                         * EDI
                         */
                        nf.adValorem = "${nota.adValorem}";
                        nf.valorSeguro = "${nota.valorSeguro}";
                        nf.valorFretePeso = "${nota.valorFretePeso}";
                        nf.valorTotalTaxas = "${nota.valorTotalTaxas}";
                        nf.valorGris = "${nota.valorGris}";
                        nf.valorPedagio = "${nota.valorPedagio}";
                        nf.numeroCarga = "${nota.numeroCarga}";
                        if (layoutArquivo == "75"){
                            ctrc.numeroCarga = "${nota.numeroCarga}";
                        }
                        //alteração para lojas americanas, liberar campos da nota
                        /*if (layoutArquivo == "33" || layoutArquivo == "45") {
                            nf.isDesbloqueoValores = true;
                        }*/

                        nf.isImportacaoEDI = true;
                
                        listaCubagens = new Array();
                        indexCubagem = 0;
                        
                        <c:forEach var="cubagem" varStatus="status" items="${nota.cubagens}">
                            cubagem = new Cubabem();
                            cubagem.id = "${cubagem.id}";
                            cubagem.volume = "${cubagem.volume}";
                            cubagem.altura = "${cubagem.altura}";
                            cubagem.comprimento = "${cubagem.comprimento}";
                            cubagem.largura = "${cubagem.largura}";
                            cubagem.metroCubico = "${cubagem.metroCubico}";
                            cubagem.existe = '<c:out value="${cubagem.existe}"/>';
                             if((isGerarEtiqueta == 'true' && isPrevaleceNotfis == 'true')){
                                cubagem.etiqueta = "${cubagem.etiqueta}";
                            }else if(isGerarEtiqueta == 'true' && isPrevaleceNotfis == 'false'){
                                cubagem.etiqueta = "";
                            }else{
                                cubagem.etiqueta = "${cubagem.etiqueta}";
                            }
                            listaCubagens[indexCubagem++] = cubagem;
                        </c:forEach>
                            
                        nf.listaCuabagem = listaCubagens;
                    
                        listaMercadoria = new Array();
                        indexMerc = 0;
                        
                        <c:forEach var="merc" varStatus="status" items="${nota.mercadorias}">
                            merc = new Mercadoria();

                            merc.quantidade = ${merc.quantidade};
                            merc.valorUnitario = ${merc.valor};
                            merc.produto = "${merc.produto.descricao}";
                            merc.produtoId = ${merc.produto.id};

                            listaMercadoria[indexMerc++] = merc;
                        </c:forEach>
                            
                        nf.listaMercadoria = listaMercadoria;
                        
                        
                        pai.$("layout").value = "${ctrc.layoutEdi}";
                        
                        if("${ctrc.layoutEdi}"=="61" && isAgrupar){
                            isConsiderarCtrcRedespacho = true;
                        }    
    
                        //layoutArquivo = 49 Cimento Nacional
                        if("${ctrc.layoutEdi}"=="49"){
                            if(pai.$("cartaValorFrete")!= null && pai.$("cartaValorFrete")!= undefined){
                                pai.$("cartaValorFrete").value =  colocarVirgula("${ctrc.valorFrete}");
                                pai.$("perc_adiant").value =  colocarVirgula("${ctrc.motorista.percentualComissaoFrete}");
                                if(pai.$("idveiculoPrincipal") != null && pai.$("idveiculoPrincipal").value == 0){                                    
                                    pai.$("idproprietarioveiculo").value = '${ctrc.motorista.veiculo.proprietario.idfornecedor}';
                                    pai.$("vei_prop").value = '${ctrc.motorista.veiculo.proprietario.razaosocial}';
                                    pai.$("vei_prop_cgc").value = '${ctrc.motorista.veiculo.proprietario.cpfCnpj}';
                                }
                                if (pai.calcularFreteCarreteiro != undefined) {
                                    pai.calcularFreteCarreteiro();
                                }
                            }
                        }
                        if (pai.isExisteNFe != null && pai.isExisteNFe != undefined && pai.isExisteNFe(nf.chaveNFe)) {
                            alert("A 'NF-e' do arquivo selecionado já foi informada na tela de 'CT-e' em lote!");
                        }else {
                            if ($("layoutArquivo").value == "4") {
                                if (pai.prepararAddCtrc != null && pai.prepararAddCtrc != undefined) {
                                    pai.prepararAddCtrc(ctrc, nf, perguntarAddVariasNotasCtrc, isAgrupar, isConsiderarPedidoAgrupamento, isConsiderarCtrcRedespacho, isAgruparPorVeiculo);
                                }
                        }else if (pai.prepararAddCtrc != null && pai.prepararAddCtrc != undefined) {
                                pai.prepararAddCtrc(ctrc, nf, perguntarAddVariasNotasCtrc, isAgrupar, isConsiderarPedidoAgrupamento, isConsiderarCtrcRedespacho, isAgruparPorVeiculo, agruparNfUfDestino, isGerarCTePorNumeroFRS, agruparNFeEmissao);
                            }else if(pai.$("id_janela").value == "jspcadconhecimento"){
                                
                                if (((pai.$('rem_rzs').value != '' && pai.$('rem_rzs').value != ctrc.remetente.razaoSocial && pai.$("idremetente").value != ctrc.remetente.id) || 
                                        (pai.$('dest_rzs').value != '' && pai.$('dest_rzs').value != ctrc.destinatario.razaoSocial && pai.$("iddestinatario").value != ctrc.destinatario.id))){
                                    if ("${configuracao.validacaoCteXmlOutrosDestinatarios}"== "b") {
                                        alert('ATENÇÃO: O cliente informado na nova Nota é diferente do(s) selecionado(s) anteriormente. Por conta disso a nota não será adicionada.');
                                        return false;
                                    } else if ("${configuracao.validacaoCteXmlOutrosDestinatarios}"== "a"){
                                        alert('ATENÇÃO: O cliente informado na nova Nota é diferente do(s) selecionado(s) anteriormente.');
                                    }
                                }
                                
                                
                                //dados do remetente
                                
                                /**
                                 * Como esses campos não evidenciam o remetente e sempre são alterados quando escolhido, remetente, destinatario, consig.... preferi não manipula-los
                                 * 
                                    pai.$('id_rota_viagem').value = ctrc.remetente.id_rota_viagem;
                                    pai.$('rota_viagem').value = ctrc.remetente.rota_viagem;
                                    pai.$('distancia_km').value = ctrc.remetente.distanciakm;
                                    pai.$('prazo_rota').value = ctrc.remetente.prazo_rota;
                                    pai.$('tipo_prazo_rota').value = ctrc.remetente.tipo_prazo_rota;
                                    
                                 **/ 
                                 
                               
                                pai.$("rem_codigo").value = ctrc.remetente.id;
                                pai.$("idremetente").value = ctrc.remetente.id; 
                                pai.$("rem_rzs").value = ctrc.remetente.razaoSocial;
                                
                                //Adicionar remetente quando for importar mais de um xml, vai servir para comparação na página pai
                                if(pai.$("rem_rzs_anterior").value == ""){
                                    pai.$("rem_rzs_anterior").value = ctrc.remetente.razaoSocial;
                                }
                                if(pai.$("dest_rzs_anterior").value == ""){
                                    pai.$("dest_rzs_anterior").value = ctrc.destinatario.razaoSocial;
                                }
                                
                               // alert("ctrc.stIcms : " + ctrc.stICMS);
                                pai.$("st_icms").value = ctrc.stICMS;
                               // pai.$("stIcms").value = ctrc.stIcms.id;                                
                                
                                pai.$("rem_cidade").value = ctrc.remetente.cidade;
                                pai.$("rem_uf").value = ctrc.remetente.uf;
                                pai.$("rem_cnpj").value = ctrc.remetente.cnpj;
                                pai.$("rem_pgt").value = ctrc.remetente.qtdDiasPgto;
                                pai.$("rem_tipotaxa").value = ctrc.remetente.tipoTabela;
                                pai.$("venremetente").value = ctrc.remetente.vendedor.razaoSocial;
                                pai.$("idvenremetente").value = ctrc.remetente.vendedor.id;
                                pai.$('vlvenremetente').value = ctrc.remetente.percComissaoVendedor;
                                pai.$("idcidadeorigem").value = ctrc.remetente.cidadeId;
                                pai.$("remidcidade").value = ctrc.remetente.cidadeId;
                                pai.$("remtipofpag").value = ctrc.remetente.tipoPgto;
                                pai.$("remtipoorigem").value = ctrc.remetente.tipoOrigemFrete;
                                pai.$("rem_endereco").value = ctrc.remetente.endereco +", "+ ctrc.remetente.logradouro + " - " + ctrc.remetente.bairro + " " + ctrc.remetente.complemento;  
                                pai.$("remtabelaproduto").value = ctrc.remetente.obrigaTabelaTipoProduto;
                                pai.$("rem_inclui_peso_container").value = ctrc.remetente.incluiPesoContainer;
                                pai.$("rem_tabela_remetente").value = ctrc.remetente.utilizarTabelaRemetente;
                                pai.$("rem_obs").value = ctrc.remetente.obs;
                                pai.$("pauta_remetente").value = ctrc.remetente.utilizaPautaFiscal;
                                pai.$("rem_tipo_cfop").value = ctrc.remetente.tipoCfop;
                                pai.$("rem_st_mg").value = ctrc.remetente.isStMg;
                                pai.$("rem_st_icms").value = ctrc.remetente.stIcms;
                                pai.$("rem_reducao_icms").value = ctrc.remetente.reducaoIcms;
                                pai.$("rem_is_in_gsf_598_03_go").value = ctrc.remetente.isUtilizarNormativaGSF598GO;
                                pai.$("st_icms").value = ctrc.remetente.stIcms;
                                pai.$('rem_unificada_modal_vendedor').value = ctrc.remetente.unificadaModalVendedor;
                                pai.$('rem_comissao_rodoviario_fracionado_vendedor').value = ctrc.remetente.percComissaoRodoviarioFracionadoVendedor;
                                pai.$('rem_comissao_rodoviario_lotacao_vendedor').value = ctrc.remetente.percComissaoRodoviarioLotacaoVendedor;
                                pai.$('rem_is_bloqueado').value = ctrc.remetente.isCreditoBloqueado;
                                pai.$("rem_analise_credito").value = ctrc.remetente.isAnaliseCredito;
                                pai.$("rem_valor_credito").value = ctrc.remetente.creditoDisponivel;
                                pai.$("utilizatipofretetabelarem").value = ctrc.remetente.utilizaTipoFreteTabela;
                                pai.$("is_utilizar_tipo_frete_tabela").value = ctrc.remetente.utilizaTipoFreteTabela;
                                pai.$("mensagem_usuario_cte_rem").value = ctrc.remetente.mensagemUsuarioCte;
                                pai.$("tipo_arredondamento_peso_rem").value = ctrc.remetente.tipoArredondamentoPeso;
                                pai.$("rem_insc_est").value = ctrc.remetente.inscEst;
                    pai.$("rem_tipo_tributacao").value = ctrc.remetente.tipoTributacao;
                                //alterei o nome para o que existe no campo do novo cadastro de conhecimento
                                pai.$("is_frete_dirigido").value = ctrc.remetente.isFreteDirigido;
                                pai.aoClicarNoLocaliza('Remetente');


                    pai.$("con_tipo_tributacao").value = ctrc.consignatario.tipoTributacao;

                                //destinatario
                                pai.$("des_codigo").value = ctrc.destinatario.id;
                                pai.$("iddestinatario").value = ctrc.destinatario.id;
                                pai.$("dest_rzs").value = ctrc.destinatario.razaoSocial;
                                pai.$("dest_cidade").value = ctrc.destinatario.cidade;
                                pai.$("dest_uf").value = ctrc.destinatario.uf;
                                pai.$("dest_insc_est").value = ctrc.destinatario.inscEst;
                                //comentei a linha abaixo pois ela estava formantado sempre no formato cnpj e o arquivo quando importado ele ja vem formatado para o padrão
//                                pai.$("dest_cnpj").value = formatCpfCnpj(ctrc.destinatario.cnpj,true,true);
                                pai.$("dest_cnpj").value = ctrc.destinatario.cnpj;
                                pai.$("dest_tipotaxa").value = ctrc.destinatario.tipoTabela;
                                pai.$("desttipofpag").value = ctrc.destinatario.tipoPgto;
                                pai.$("aliquota").value = 0;
                                pai.$("desttipoorigem").value = ctrc.destinatario.tipoOrigemFrete;
                                pai.$("desttabelaproduto").value = ctrc.destinatario.obrigaTabelaTipoProduto;                                
                                pai.$("dest_endereco").value = ctrc.destinatario.endereco +", "+ ctrc.destinatario.logradouro + " - " + ctrc.destinatario.bairro + " " + ctrc.destinatario.complemento;  
                                pai.$("dest_obs").value = ctrc.destinatario.obs;
                                pai.$("des_inclui_tde").value = ctrc.destinatario.isIncluirTde;
                                pai.$("des_inclui_peso_container").value = ctrc.destinatario.incluiPesoContainer;
                                pai.$("vendestinatario").value = ctrc.destinatario.vendedor.razaoSocial;
                                pai.$("idvendestinatario").value = ctrc.destinatario.vendedor.id;
                                pai.$('vlvendestinatario').value = ctrc.destinatario.percComissaoVendedor;
                                pai.$("dest_pgt").value = ctrc.destinatario.qtdDiasPgto;
                                pai.$('des_unificada_modal_vendedor').value = ctrc.destinatario.unificadaModalVendedor;
                                pai.$('des_comissao_rodoviario_fracionado_vendedor').value = ctrc.destinatario.percComissaoRodoviarioFracionadoVendedor;
                                pai.$('des_comissao_rodoviario_lotacao_vendedor').value = ctrc.destinatario.percComissaoRodoviarioLotacaoVendedor;
                                pai.$("des_analise_credito").value = ctrc.destinatario.isAnaliseCredito;
                                pai.$("des_valor_credito").value = ctrc.destinatario.creditoDisponivel;
                                pai.$("des_is_bloqueado").value = ctrc.destinatario.isCreditoBloqueado;
                                pai.$("des_st_icms").value = ctrc.destinatario.stIcms;
                                pai.$("des_reducao_icms").value = ctrc.destinatario.reducaoIcms;
                                pai.$("des_is_in_gsf_598_03_go").value = ctrc.destinatario.isUtilizarNormativaGSF598GO;
                                pai.$("st_icms").value = ctrc.destinatario.stIcms;
                                pai.$("des_tabela_remetente").value = ctrc.destinatario.utilizarTabelaRemetente;
                                pai.$("pauta_destinatario").value = ctrc.destinatario.utilizaPautaFiscal;
                                pai.$("utilizatipofretetabeladest").value = ctrc.destinatario.utilizaTipoFreteTabela;
                                pai.$("is_utilizar_tipo_frete_tabela").value = ctrc.destinatario.utilizaTipoFreteTabela;
                                pai.$("tipo_produto_destinatario_id").value = ctrc.destinatario.tipoProdutoDestinatario;
                                //pai.$("des_inclui_peso_container").value = $("des_inclui_peso_container_"+id).value;
                                pai.$("st_rem_credito_presumido").value = ctrc.remetente.creditoPresumido;
                                pai.$("st_des_credito_presumido").value = ctrc.destinatario.creditoPresumido;
                                pai.$("st_cli_credito_presumido").value = ctrc.cliente.creditoPresumido;
                                pai.$("st_red_credito_presumido").value = ctrc.redespacho.creditoPresumido;
                                pai.$("st_credito_presumido").value = ctrc.consignatario.creditoPresumido;
                                pai.$("st_rec_credito_presumido").value = ctrc.recebedor.creditoPresumido;
                                pai.$("des_tipo_cfop").value = ctrc.destinatario.tipoCfop;
                    pai.$("dest_tipo_tributacao").value = ctrc.destinatario.tipoTributacao;
                                //cidade de destino
//                                pai.$("idcidadedestino").value = ctrc.destinatario.cidadeId;
//                                pai.$("cid_destino").value = ctrc.destinatario.cidade;
//                                pai.$("uf_destino").value = ctrc.destinatario.uf;
//                                pai.$("cidade_destino_id").value = ctrc.destinatario.cidadeId;
//                                
                                pai.$("idcidadedestino").value = ctrc.idCidadeDestino;
                                pai.$("cid_destino").value = ctrc.cidadeDestino;
                                pai.$("uf_destino").value = ctrc.ufDestino;
                                pai.$("cidade_destino_id").value = ctrc.idCidadeDestino;
                                //não estava carregando a rota - cassimiro
                                pai.$("rota_viagem").value = ctrc.rota;
                                //correção, porque não estava passando o idRota
                                pai.$("id_rota_viagem").value = ctrc.idRota;
                                pai.$("distancia_km").value = ctrc.distancisKm;
//                                pai.$("dest_cidade").value = ctrc.cidadeDestino;
//                                pai.$("dest_uf").value = ctrc.ufDestino;
                                //ctrcs
                                pai.$('taxa_roubo').value = formatoMoeda(ctrc.taxaRoubo);
                                pai.$('taxa_roubo_urbano').value = formatoMoeda(ctrc.taxaRouboUrbano);
                                pai.$('taxa_tombamento').value = formatoMoeda(ctrc.taxaTombamento);
                                pai.$('taxa_tombamento_urbano').value = formatoMoeda(ctrc.taxaTombamentoUrbano);
                                pai.$("mensagem_usuario_cte_des").value = ctrc.destinatario.mensagemUsuarioCte;
                                pai.$("tipo_arredondamento_peso_dest").value = ctrc.destinatario.tipoArredondamentoPeso;
                                pai.aoClicarNoLocaliza('Destinatario');
//                                pai.localizaRemetenteCodigo("idcliente", ctrc.remetente.id);
//                                pai.localizaDestinatarioCodigo("idcliente", ctrc.destinatario.id);

                                pai.$("rem_is_especie_serie_modal").value = "${ctrc.remetente.especieSerieModal}";
                                pai.$("rem_especie_cliente").value = "${ctrc.remetente.especie}";
                                pai.$("rem_serie_cliente").value = "${ctrc.remetente.serie}";
                                pai.$("rem_modal_cliente").value = "${ctrc.remetente.modalCliente}";
                                
                                pai.$("dest_is_especie_serie_modal").value = "${ctrc.destinatario.especieSerieModal}";
                                pai.$("dest_especie_cliente").value = "${ctrc.destinatario.especie}";
                                pai.$("dest_serie_cliente").value = "${ctrc.destinatario.serie}";
                                pai.$("dest_modal_cliente").value = "${ctrc.destinatario.modalCliente}";
                                
                                pai.$("con_is_especie_serie_modal").value = "${ctrc.cliente.especieSerieModal}";
                                pai.$("con_especie_cliente").value = "${ctrc.cliente.especie}";
                                pai.$("con_serie_cliente").value = "${ctrc.cliente.serie}";
                                pai.$("con_modal_cliente").value = "${ctrc.cliente.modalCliente}";
                                pai.$("numeroCarga").value = "${ctrc.numeroCarga}";
                                pai.$("pedido_cliente").value = "${ctrc.pedidoCliente}";

                                <c:forEach var="obs" varStatus="status" items="${ctrc.observacao}">
                                    pai.$("obs_lin${status.count}").value = "${obs}";
                                </c:forEach>

                                if (ctrc.isRedespacho) {
                                    pai.$("ck_redespacho").checked = ctrc.isRedespacho;
//                                    alert("ctrc.isRedespacho");
                                    pai.redespacho(true,true);
                                    pai.$("ctoredespacho").value = ctrc.redespachoCtrc;
                                    pai.$("redespacho_valor").value = ctrc.redespachoValor;
                                    pai.$("redespacho_valor_icms").value = ctrc.redespachoValorIcms;
                                    pai.$("red_codigo").value = ctrc.redespacho.id;
                                    pai.$("idredespacho").value = ctrc.redespacho.id; 
                                    pai.$("red_rzs").value = ctrc.redespacho.razaoSocial;
                                    pai.$("red_cidade").value = ctrc.redespacho.cidade;
                                    pai.$("red_cidade_id").value = ctrc.redespacho.cidadeId;
                                    pai.$("red_uf").value = ctrc.redespacho.uf;
                                    pai.$("red_cnpj").value = ctrc.redespacho.cnpj;
                                    pai.$("red_chave_acesso").value = ctrc.redespachoChaveAcesso.replace("[","").replace("]","");
                                    pai.$("red_is_bloqueado").value = ctrc.redespacho.isCreditoBloqueado;
                                    pai.$("red_analise_credito").value = ctrc.redespacho.isAnaliseCredito;
                                    pai.$("red_valor_credito").value = ctrc.redespacho.creditoDisponivel;
                                    pai.$("red_tipotaxa").value = ctrc.redespacho.tipoTabela;
                                    pai.$("idvenredespacho").value = ctrc.redespacho.vendedor.id;
                                    pai.$('vlvenredespacho').value = ctrc.redespacho.percComissaoVendedor;
                                    pai.$("red_pgt").value = ctrc.redespacho.qtdDiasPgto;
                                    pai.$('red_unificada_modal_vendedor').value = ctrc.redespacho.unificadaModalVendedor;
                                    pai.$('red_comissao_rodoviario_fracionado_vendedor').value = ctrc.redespacho.percComissaoRodoviarioFracionadoVendedor;
                                    pai.$('red_comissao_rodoviario_lotacao_vendedor').value = ctrc.redespacho.percComissaoRodoviarioLotacaoVendedor;
                                    pai.$("redtipofpag").value = ctrc.redespacho.tipoPgto;
                                    pai.$("red_st_icms").value = ctrc.redespacho.stIcms;
                                    pai.$("red_reducao_icms").value = ctrc.redespacho.reducaoIcms;
                                    pai.$("red_is_in_gsf_598_03_go").value = ctrc.redespacho.isUtilizarNormativaGSF598GO;
                                    pai.$("st_icms").value = ctrc.redespacho.stIcms;
                                    pai.$("red_tabela_remetente").value = ctrc.redespacho.utilizarTabelaRemetente;
                                    pai.$("utilizatipofretetabelared").value = ctrc.redespacho.utilizaTipoFreteTabela;
                                    pai.$("is_utilizar_tipo_frete_tabela").value = ctrc.redespacho.utilizaTipoFreteTabela;
                                    pai.$("pauta_redespacho").value = ctrc.redespacho.utilizaPautaFiscal;
                                    pai.$("tipo_arredondamento_peso_red").value = ctrc.redespacho.tipoArredondamentoPeso;
                                    pai.$("red_insc_est").value = ctrc.redespacho.inscEst;
                                    pai.aoClicarNoLocaliza('Redespacho');
                                    pai.$("red_is_especie_serie_modal").value = "${ctrc.redespacho.especieSerieModal}";
                                    pai.$("red_especie_cliente").value = "${ctrc.redespacho.especie}";
                                    pai.$("red_serie_cliente").value = "${ctrc.redespacho.serie}";
                                    pai.$("red_modal_cliente").value = "${ctrc.redespacho.modalCliente}";
                                }
                                
                                if (ctrc.isRecebedor) {
                                    pai.$("rec_codigo").value = ctrc.recebedor.id;
                                    pai.$("rec_rzs").value = ctrc.recebedor.razaoSocial;
                                    pai.$("rec_cidade").value = ctrc.recebedor.cidade;                                    
                                    pai.$("rec_uf").value = ctrc.recebedor.uf;
                                    pai.$("rec_cnpj").value = ctrc.recebedor.cnpj;
                                }
                                
                                if (ctrc.isExpedidor) {
                                    pai.$("exp_codigo").value = ctrc.expedidor.id;
                                    pai.$("exp_rzs").value = ctrc.expedidor.razaoSocial;
                                    pai.$("exp_cidade").value = ctrc.expedidor.cidade;                                    
                                    pai.$("exp_uf").value = ctrc.expedidor.uf;
                                    pai.$("exp_cnpj").value = ctrc.expedidor.cnpj;
                                }
                                if (isDadosVeiculo) {
                                    if ("${ctrc.veiculo.idveiculo}" != "0") {
                                        pai.$("vei_placa").value = "${ctrc.veiculo.placa}";
                                        pai.$("idveiculo").value = "${ctrc.veiculo.idveiculo}";
                                        pai.$("motor_nome").value = "${ctrc.motorista.nome}";
                                        pai.$("idmotorista").value = "${ctrc.motorista.idmotorista}";
                                        pai.$("car_placa").value = "${ctrc.carreta.placa}";
                                        pai.$("idcarreta").value = "${ctrc.carreta.idveiculo}";
                                        pai.$("bi_placa").value = "${ctrc.biTrem.placa}";
                                        pai.$("idbitrem").value = "${ctrc.biTrem.idveiculo}";
                                    }else{
                                        alert("O veiculo com placa '${ctrc.veiculo.placa}' não foi encontrado!");
                                    }
                                }
                                //limpando os dados do motorista e veiculos mesmo quando estes estão preenchidos no conhecimento ou importados da coleta
                                //e na configuração de importação não esta marcado para trazer os dados do veiculo e motorista. Historia 1173 prob - Daniel Cassimiro
//                                else{
//                                    pai.$("vei_placa").value = "";
//                                    pai.$("idveiculo").value = "0";
//                                    pai.$("motor_nome").value = "";
//                                    pai.$("idmotorista").value = "0";
//                                    pai.$("car_placa").value = "";
//                                    pai.$("idcarreta").value = "0";
//                                    pai.$("bi_placa").value = "";
//                                    pai.$("idbitrem").value = "0";
                                    
//                                }
                                //pai.$('contabelaproduto').value = ctrc.destinatario.isTabelaTipoProduto;
                                if (ctrc.modFrete == 0 || ctrc.modFrete == 2) { //CIF
                                    pai.setFretePago(true);
                                } else if (ctrc.modFrete == 1) { //FOB
                                    pai.setFretePago(false);
                                } else { //não informado
                                    alert('O Tomador do serviço (Consignatário) não foi informado na NF-e, favor informá-lo antes de importar.');
                                }
                               
                                // Readonly no localizar destinatário
                                if (ctrc.consignatario.travaCamposImportacao === 'true') {
                                    pai.$('is_travar_campos').value = ctrc.consignatario.travaCamposImportacao;
                                    pai.colocarReadOnly('true');
                                }
                                
                                if ("${param.fontePreco}" == "a" ) {
                                    pai.$("tipotaxa").value = "3";
                                    pai.$("valor_frete").value = "${ctrc.valorFrete}";
                                   
                                    
                                    if("${ctrc.layoutEdi}"=="49"){
                                        pai.$("valor_peso").value = formatoMoeda(ctrc.valorFretePeso);
                                        pai.$("valor_frete").value = "0,00";
                                        
                                        if(pai.$("cartaValorFrete")!= null && pai.$("cartaValorFrete")!= undefined){
                                                pai.$("idproprietarioveiculo").value = '${ctrc.motorista.veiculo.proprietario.idfornecedor}';
                                                pai.$("vei_prop").value = '${ctrc.motorista.veiculo.proprietario.razaosocial}';
                                                pai.$("vei_prop_cgc").value = '${ctrc.motorista.veiculo.proprietario.cpfCnpj}';
                                                pai.$("cartaValorFrete").value =  colocarVirgula("${ctrc.valorFrete}");
                                                pai.$("chk_carta_automatica").checked = true; 
                                        }
                                    }
                                    pai.recalcular(false);
                                    
                                }
                                if (pai.addNote != null && pai.addNote != undefined) {
                                    var elemento = null;
                                    var indiceNote = 0;
                                    var idColeta = 0;
                                    if (pai.getNextIndexFromTableRoot != null && pai.getNextIndexFromTableRoot != undefined) {
                                        indiceNote = pai.getNextIndexFromTableRoot(idColeta, "tableNotes0");
                                    }
                                    var sufixID = indiceNote +"_id" + idColeta;
                                    elemento = pai.addNote(
                                        idColeta, //idColeta,
                                        "tableNotes0",//idTableRoot, 
                                        0,//idnota
                                        nf.numero,//numero, 
                                        nf.serie,//serie, 
                                        (nf.dataEmissao == "" ? pai.dataAtual : nf.dataEmissao),//emissao,
                                        nf.valor,//valor, 
                                        nf.baseCalculoIcm, //vl_base_icms,
                                        nf.icmsValor, //vl_icms,
                                        nf.icmsST, //vl_icms_st,
                                        nf.icmsFrete, //vl_icms_frete,
                                        nf.peso, //peso,
                                        nf.volume, //volume, 
                                        nf.embalagem,//embalagem, 
                                        nf.conteudo,//descricao_produto,
                                        0, //idCTRC, 
                                        nf.pedido,//pedido, 
                                        false, //readOnly,
                                        0, //largura, 
                                        0, //altura, 
                                        0, //comprimento,
                                        nf.metroCubico, //metroCubico, 
                                        nf.marcaId, //idMarcaVeiculo, 
                                        nf.marca,//marcaVeiculo,
                                        nf.modelo,//modeloVeiculo, 
                                        nf.ano,//anoVeiculo, 
                                        nf.cor,//corVeiculo,
                                        nf.chassi,//chassiVeiculo,
                                        0, //maxItens,
                                        false, //isPossuiItens,
                                        nf.cfopId, //cfopId,
                                        nf.cfop,//cfop
                                        nf.chaveNFe,//chaveNFe,
                                        nf.isAgendado, //isAgendado, 
                                        nf.dataAgenda,//dataAgenda, 
                                        nf.horaAgenda,//horaAgenda,
                                        nf.observacao,//obsAgenda, 
                                        false, //isBaixaNota, 
                                        nf.dataPrevisao,//previsaoEntrega, 
                                        nf.horaPrevisao,//previsaoAs,
                                        ctrc.destinatario.id, //idDestinatario, 
                                        ctrc.destinatario.razaoSocial,//destinatario, 
                                        nf.isImportacaoEDI, //isEdi,
                                        (nf.listaCuabagem == null || nf.listaCuabagem == undefined ? 0 : nf.listaCuabagem.length), //maxItensMetro, 
                                        0, //minutaId, 
                                        nf.tipoDocumento,//tpDoc
                                        undefined, undefined, undefined, undefined,
                                        ctrc.consignatario.travaCamposImportacao);
                                        //variavel responsavel por contar as notas
                                    pai.countIdxNotes++;
                                    var alturaTot = 0;
                                    var larguraTot = 0;
                                    var comprimentoTot = 0;
                                    var volumeTot = 0;
                                    var itemCub = null;
                                    if (nf.listaCuabagem != null && nf.listaCuabagem != undefined && elemento != null && elemento != undefined) {
                                        try {
                                            for (var c = 0; c < nf.listaCuabagem.length; c++) {
                                                var metroCub = roundABNT(parseFloat(nf.listaCuabagem[c].altura) * parseFloat(nf.listaCuabagem[c].largura) * parseFloat(nf.listaCuabagem[c].comprimento) * parseFloat(nf.listaCuabagem[c].volume), 4);
                                                pai.addUpdateNotaFiscal3('trNote'+elemento,
                                                0,
                                                0,
                                                sufixID,
                                                metroCub,
                                                nf.listaCuabagem[c].altura,
                                                nf.listaCuabagem[c].largura,
                                                nf.listaCuabagem[c].comprimento,
                                                nf.listaCuabagem[c].volume,
                                                nf.listaCuabagem[c].etiqueta,
                                                c);
                                                
                                                alturaTot += parseFloat(nf.listaCuabagem[c].altura);
                                                larguraTot += parseFloat(nf.listaCuabagem[c].largura);
                                                comprimentoTot += parseFloat(nf.listaCuabagem[c].comprimento);
                                                volumeTot += parseFloat(nf.listaCuabagem[c].volume);
                                            }
                                            
                                            if (pai.updateSum != null && pai.updateSum != undefined) {
                                                pai.updateSum(true);
                                            }
                                        } catch (e) {
                                            console.log(e);
                                            alert("Erro ao adicionar cubagem.");
                                        }                                        
                                        pai.$("volume").value = roundABNT(volumeTot, 4);                                        
//                                        pai.alterouCampoDependente("cub_comprimento");
                                        pai.sumMetroNotes("0");
                                    }
                                    if (pai.applyEventInNote != null && pai.applyEventInNote != undefined && elemento != null && elemento != undefined) {
                                        pai.applyEventInNote();
                                    }
                                }
                                
                                pai.$("vlmercadoria").value = pai.sumValorNotes('0');
                                
                                //                                pai.alterouCampoDependente("vlmercadoria");
                                if ("${configuracao.cartaFreteAutomatica}"== "true") {
                                    pai.calcularFreteCarreteiro();
                                }
                                pai.$("peso").value = pai.sumPesoNotes('0');
                                //                                pai.alterouCampoDependente("peso");
                                pai.$("volume").value = pai.sumVolumeNotes('0');
                                
                                //                                pai.alterouCampoDependente("volume");
                                //                                pai.alterouCampoDependente("cub_base");
                                //                                pai.alterouCampoDependente("cub_altura");
                                //                                pai.alterouCampoDependente("cub_largura");
                                //                                pai.alterouCampoDependente("cub_comprimento");
                                //                                pai.alterouCampoDependegtjnte("cub_metro");
                                //                                pai.getStIcmsConsig();
                                pai.getCidadeOrigem();
                                pai.getDadosIcms();
                                pai.getTipoProdutos();
                                pai.calculaPesoTaxado();
                                pai.alteraTipoTaxa(pai.$("tipotaxa").value);
                                
                                pai.calculaPesoTaxadoCtrc();
                                pai.calculaVlRedespachante();                                
                                
                                if(ctrc.destinatario.id==0){
                                     if (confirm("Destinatário é do exterior e não é possível realizar o cadastro do mesmo. Deseja realizar o cadastro agora?")){
                                       
                                            window.open('./cadcliente?acao=cadastroExterior&rzs='+ctrc.destinatario.razaoSocial+
                                                    '&endereco='+ctrc.destinatario.endereco+
                                                    '&uf='+ctrc.destinatario.uf+
                                                    '&cidade='+ctrc.destinatario.cidade.descricaoCidade+
                                                    '&idcidade='+ctrc.destinatario.cidade.idcidade+
                                                    '&cep='+ctrc.destinatario.cep+
                                                    '&compl='+ctrc.destinatario.complemento+  '',                                                  
                                                    'Cliente','top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                                        }
                                }                               
                                
                                if(ctrc.remetente.id==0){
                                     if (confirm("Rementente é do exterior e não é possível realizar o cadastro do mesmo. Deseja realizar o cadastro agora?")){
                                            window.open('./cadcliente?acao=cadastroExterior&rzs='+ctrc.remetente.razaoSocial+
                                                    '&endereco='+ctrc.remetente.endereco+
                                                    '&uf='+ctrc.remetente.uf+
                                                    '&cidade='+ctrc.remetente.cidade.descricaoCidade+
                                                    '&idcidade='+ctrc.remetente.cidade.idcidade+
                                                    '&cep='+ctrc.remetente.cep+
                                                    '&compl='+ctrc.remetente.complemento+  '',                                                  
                                                    'Cliente','top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                                     }
                                } 
                            }
                        }
                    </c:forEach>
                    if(ctrc.listaNotas.length == 0 && nf == undefined){
                        // quando não tem notas e enviar o objeto como undefined dará erros.
                        if (nf === undefined) {
                            nf = new NotaFiscal();
                        }
                        pai.prepararAddCtrc(ctrc, nf, perguntarAddVariasNotasCtrc, isAgrupar, isConsiderarPedidoAgrupamento, isConsiderarCtrcRedespacho, isAgruparPorVeiculo);
                    }
            </c:forEach>
            <c:if test="${ctrcs != null}">
                if ('${param.layoutArquivo}' == '71' && "${param.fontePreco}" == "a") {
                    pai.ratearFretePeso(true);
                }
                window.close();
            </c:if>
               
        }catch(ex){            
            if (!isIE()) {
                console.log(ex);
                console.log("ERRO AO CARREGAR AS INFORMAÇOES:"+ex);
            }
            console.log(ex);
            alert(ex);
        }
    }
    
    function alterarLayout(layout){
        invisivel($("trImportacao_Redespacho"));
        invisivel($("trImportacao_Destinatario"));
        invisivel($("trImportacao_Remetente"));
        invisivel($("trImportacao_Consignatario"));
        invisivel($("trImportacao_Representante"));
        invisivel($("trImportacao_Recebedor"));
        invisivel($("trImportacao_Expedidor"));
        invisivel($("trImportacao_ConsiderarFrete"));
        invisivel($("trImportacao_NfRemetenteDestinatario"));
        invisivel($("trImportacao_NfUfDestino"));
        invisivel($("trImportacao_NfNumeroPedido"));
        invisivel($("trImportacao_ImportarFilialSelecionada"));
        invisivel($("trImportacao_ClienteProduto"));
        invisivel($("trImportacao_UtilizarDadosVeiculo"));
        invisivel($("trImportacao_CadastrarMercadoria"));
        invisivel($("trImportacao_ImportarItemNf"));
        invisivel($("trImportacao_AtualizarCadDestinatario"));
        invisivel($("trImportacao_BasePadraoCubagem"));
        invisivel($("trImportacao_BasePadraoCubagemAereo"));
        invisivel($("trImportacao_AgruparPorVeiculo"));
        $("btVisualizar").value = "Importar";
        invisivel($("tdLabelArquivo"));
        invisivel($("tdInput"));
        invisivel($("tdDtEmissao1"));
        invisivel($("tdChaveAcessoNFe1"));
        invisivel($("tdChaveAcessoNFe2"));
        invisivel($("trCaptcha"));
        invisivel($("tdDtEmissao2"));
        invisivel($("tdCarga1"));
        invisivel($("tdCarga2"));
        invisivel($("tdGSM1"));
        invisivel($("tdGSM2"));
        invisivel($("irWebStore"));
        invisivel($("irFirefox"));
        invisivel($("tdNotaFiscal1"));
        invisivel($("tdNotaFiscal2"));
        invisivel($("trNotaFiscalRemetente"));
        invisivel($("trNotaFiscalDestinatario"));
        invisivel($("trBaixarXMLEmail"));
        invisivel($("trQuantidadeNotas"));
        invisivel($("trNotasEscolhidas"));
        invisivel($("trEscolherNotas"));
        invisivel($("divProcedaMagazineLuiza"));
        invisivel($("trImportacao_subServico"));
        invisivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
        invisivel($("trImportacao_AtualizarCadRemetente"));
        invisivel($("trImportacao_AtualizarEndDesitinatario"));
        invisivel($("trImportacao_gerarCTePorNumeroFRS"));
        invisivel($("trImportacao_Responsavel"));
        invisivel($("trImportacao_CalcularPrazoEntregaTabelaPreco"));
        invisivel($("trImportacao_ConsiderarVolume"));
        invisivel($('spanAgruparNFeDataEmissao'));
        invisivel($("trNumeroRomaneioNF"));
        invisivel($("trImportacao_TagsPersonalizadas"));
        
                
        switch(layout){
            case "1"://NF-e (XML)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Remetente"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                visivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                visivel($("trImportacao_NfNumeroPedido"));
                visivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                visivel($("trImportacao_UtilizarDadosVeiculo"));
                visivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                visivel($("trImportacao_AgruparPorVeiculo"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("trCaptcha"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                visivel($("trImportacao_Responsavel"));
                visivel($("trImportacao_ConsiderarVolume"));
                visivel($('spanAgruparNFeDataEmissao'));
                visivel($('trImportacao_TagsPersonalizadas'));
                dadosImportacaoFiltrosLayout(1);
                break;
            case "2"://NF-e (Chave de Acesso)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Remetente"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                visivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                visivel($("trImportacao_UtilizarDadosVeiculo"));
                visivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                visivel($("trImportacao_AgruparPorVeiculo"));
                $("btVisualizar").value = "Importar";
                invisivel($("tdLabelArquivo"));
                invisivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                visivel($("tdChaveAcessoNFe1"));
//                visivel($("tdChaveAcessoNFe2"));
                visivel($("chaveAcessoNFe"));
                invisivel($("tdChaveAcessoCTe1"));
//                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("chaveAcessoCTe"));
                jQuery("input[id*='chaveAcessoCTe_']").hide();
//                visivel($("trCaptcha"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                //ajaxCarregarCaptcha();
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                visivel($("trImportacao_Responsavel"));
                visivel($("trImportacao_ConsiderarVolume"));
                visivel($('spanAgruparNFeDataEmissao'));
                visivel($('trImportacao_TagsPersonalizadas'));
                dadosImportacaoFiltrosLayout(2);
                jQuery("input[id*='chaveAcessoNFe_']").show();
                jQuery("input[id*='chaveAcessoCTe_']").hide();
                if (!window.gwsistemas) {
                    if (navigator.userAgent.indexOf('Chrome') != -1) {
                        alert('Atenção, é necessário ter a extensão da GW Sistemas instalada para utilizar essa rotina, você pode encontrar nossa extensão na Chrome Web Store ou no botão "Ir para webstore".');
                        jQuery('#chaveAcessoNFe_0').attr('disabled','true');
                        jQuery('#irWebStore').show();
                        
                        jQuery('#irWebStore').removeAttr('disabled');
                        jQuery('#irFirefox').removeAttr('disabled');
                        jQuery('#consultarChaveAcesso_0').attr('disabled','true');
                        return;
                    } else {
                        alert('Atenção, é necessário ter a extensão da GW Sistemas instalada para utilizar essa rotina, você pode encontrar nossa extensão na Firefox Add-ons ou no botão "Ir para firefox add-ons".');
                        jQuery('#chaveAcessoNFe_0').attr('disabled','true');
                        
                        jQuery('#irWebStore').removeAttr('disabled');
                        jQuery('#irFirefox').removeAttr('disabled');
                        
                        jQuery('#irFirefox').show();
                        jQuery('#consultarChaveAcesso_0').attr('disabled','true');
                        return;
                    }
                } else {
                    jQuery('#irWebStore').removeAttr('disabled');
                    jQuery('#irFirefox').removeAttr('disabled');
                    jQuery('#chaveAcessoNFe_0').removeAttr('disabled');
                    jQuery('#consultarChaveAcesso_0').removeAttr('disabled');
                    jQuery('#irWebStore').hide();
                }
                    break;
            case "3"://CT-e Redespacho (XML)
                invisivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                invisivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                visivel($("trImportacao_AgruparPorVeiculo"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("trCaptcha"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(3);
                break;
            case "4"://CT-e confirmado por outra aplicação (XML)
                invisivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                invisivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                visivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                invisivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("trCaptcha"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(4);
                break;
            case "5"://GSM (gwLogis)
                invisivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                invisivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                invisivel($("arq01"));
                invisivel($("tdLabelArquivo"));
                invisivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                visivel($("tdGSM1"));
                visivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(5);
                break;
            case "6"://Gw Conferencia
                invisivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                invisivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                invisivel($("arq01"));
                invisivel($("tdLabelArquivo"));
                invisivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                visivel($("tdCarga1"));
                visivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(6);
                break;
            case "7"://SETCESP-COTIN (eFacil)
                invisivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("trCaptcha"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(7);
                break;
            case "8"://SETCESP-COTIN (Mobly)
                invisivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Remetente"));
                visivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("trCaptcha"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                visivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(8);
                break;
            case "9"://SETCESP-COTIN (Ricardo Eletro)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Remetente"));
                visivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("trCaptcha"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(9);
                break;
            case "10"://Ipiranga
                invisivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("trCaptcha"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(10);
                break;
            case "11"://Itatiaia
                invisivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                visivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("trCaptcha"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(11);
                break;
            case "12"://JetClass(Maxxi)
                invisivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("trCaptcha"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(12);
                break;
            case "13"://JAMEF
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("trCaptcha"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(13);
                break;
            case "14"://Terphane
                invisivel($("trImportacao_Redespacho"))
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("trCaptcha"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(14);
                break;
            case "15"://NeoGrid
                invisivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("trCaptcha"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(15);
                break;
            case "16"://Alpargatas
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                visivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(16);
                break;
            case "17"://Proceda (3.0A)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(17);
                break;
            case "18"://Proceda (3.0B)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Remetente"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                visivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(18);
                break;
            case "19"://Proceda (3.0A - Displan)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(19);
                break;
            case "20"://Proceda (3.0A - Hermes)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(20);
                break;
            case "21"://Proceda (3.1)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                visivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(21);
                break;
            case "22"://Proceda (3.1 - Chave de Acesso)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(22);
                break;
            case "23"://Proceda (3.1 - Aliança)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                visivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(23);
                break;
            case "24"://Proceda (3.1 - Cia de Tecidos Santo Antônio)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                visivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(24);
                break;
            case "25"://Proceda (3.1 - Café 3 Corações)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(25);
                break;
            case "26"://Proceda (3.1 - DIST.MED.SANTA CRUZ)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(26);
                break;
            case "27"://Proceda (3.1 - Danone)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                visivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(27);
                break;
            case "28"://Proceda (3.1 - Fujioka)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(28);
                break;
            case "29"://Proceda (3.1 - Del Vale)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                visivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(29);
                break;
            case "30"://Proceda (3.1 - Masterfoods)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                visivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(30);
                break;
            case "31"://Proceda (3.1 - M. Dias)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                visivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(31);
                break;
            case "32"://Proceda (3.1 - Melhoramento CPNC)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                visivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(32);
                break;
            case "33"://Proceda (3.1 - Lojas Americanas)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(33);
                break;
            case "34"://Proceda (QUERO)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(34);
                break;
            case "35"://Redespacho (Rapidão Cometa)
                invisivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(35);
                break;
            case "36"://Padrão Hermes (Excel)
                invisivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                invisivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(36);
                break;
            case "37"://Tavex
                invisivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(37);
                break;
            case "38"://Tivit (5.0)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Remetente"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                visivel($("trImportacao_subServico"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                visivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(38);
                break;
            case "39"://Whirlpool
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(39);
                break;
            case "40"://Avon (Web Service)
                invisivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Pesquisar Notas Disponiveis";
                invisivel($("arq01"));
                invisivel($("tdLabelArquivo"));
                invisivel($("tdInput"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("trCaptcha"));
                visivel($("tdDtEmissao1"));
                visivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(40);
                break;
            case "41"://Proceda (3.1 - Philips)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(41);
                break;
            case "42"://Proceda (5.0 CONEMB - RAMTHUN)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(42);
                break;
            case "43"://Proceda (3.1 Jequiti)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(43);
                break;
            case "44"://Quatro Estações
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(44);
                break;
            case "45"://Privalia
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(45);
                break;
            case "46"://Samsung
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                visivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(46);
                break;
            case "47"://Proceda (3.1 - Coteminas)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(47);
                break;
            case "48"://Proceda (3.0A - DHL)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                visivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(48);
                break;
            case "49"://(Cimento Nacional)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Remetente"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                visivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                visivel($("trImportacao_UtilizarDadosVeiculo"));
                visivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                invisivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("trCaptcha"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(49);
//                ajaxCarregarCaptcha();
                break;
            case "50"://(Odorata Cosmeticos)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Remetente"));
                visivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                invisivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                invisivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("trCaptcha"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(50);
                break;
                
            case "51"://Tivit (5.0 Bellas Cosmeticos)
                invisivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(51);
                break;   
            case "52"://Proceda (3.1 - SIMPRESS COMERCIO E LOCAÇÃO)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(52);
                break;
            case "53": //Nota Fiscal
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Remetente"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                invisivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                $("btVisualizar").value = "Importar";
                invisivel($("arq01"));
                invisivel($("tdLabelArquivo"));
                invisivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                visivel($("tdNotaFiscal1"));
                visivel($("tdNotaFiscal2"));
                visivel($("trNotaFiscalRemetente"));
                visivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                visivel($("trNumeroRomaneioNF"));
                dadosImportacaoFiltrosLayout(53);
                break;
            case "54":  //  CT-e Chave Acesso
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Remetente"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                visivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                visivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                invisivel($("tdLabelArquivo"));
                invisivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoNFe2"));
                visivel($("tdChaveAcessoNFe1"));
//                visivel($("tdChaveAcessoCTe1"));
//                visivel($("tdChaveAcessoCTe2"));
//                visivel($("trCaptcha"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(54);
                jQuery("input[id*='chaveAcessoCTe_']").show();
                jQuery("input[id*='chaveAcessoNFe_']").hide();
                if (!window.gwsistemas) {
                    if (navigator.userAgent.indexOf('Chrome') != -1) {
                        alert('Atenção, é necessário ter a extensão da GW Sistemas instalada para utilizar essa rotina, você pode encontrar nossa extensão na Chrome Web Store ou no botão "Ir para webstore".');
                        jQuery('#chaveAcessoNFe_0').attr('disabled','true');
                        jQuery('#irWebStore').show();
                        jQuery('#consultarChaveAcesso_0').attr('disabled','true');
                        return;
                    } else {
                        alert('Atenção, é necessário ter a extensão da GW Sistemas instalada para utilizar essa rotina, você pode encontrar nossa extensão na Firefox Add-ons ou no botão "Ir para firefox add-ons".');
                        jQuery('#chaveAcessoNFe_0').attr('disabled','true');
                        jQuery('#irFirefox').show();
                        jQuery('#consultarChaveAcesso_0').attr('disabled','true');
                        return;
                    }
                } else {
                    jQuery('#chaveAcessoNFe_0').removeAttr('disabled');
                    jQuery('#consultarChaveAcesso_0').removeAttr('disabled');
                    jQuery('#irWebStore').hide();
                }
                //ajaxCarregarCaptchaCTE();
                break;
            case "55": //Arquivos Importados XML
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Remetente"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                visivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                invisivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                visivel($("trImportacao_AgruparPorVeiculo"));
                $("btVisualizar").value = "Importar";
                invisivel($("arq01"));
                invisivel($("tdLabelArquivo"));
                invisivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                visivel($("tdNotaFiscal1"));
                visivel($("tdNotaFiscal2"));
                visivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                visivel($("trBaixarXMLEmail"));
                visivel($("trQuantidadeNotas"));
                visivel($("trNotasEscolhidas"));
                visivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(55);
                break;        
            case "56":  //  Proceda (3.1 - SAN REMO, PINCEIS ATLAS, BETTANIN)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                visivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(56);
                break;            
            case "57":  // Proceda (3.1 - Regina Industria e Comercio S/A)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                visivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(57);
                break;            
            case "58":  // Proceda (Magazine Luiza)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Remetente"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                invisivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                visivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(58);
                break;
            case "59"://SETCESP-COTIN (CNova Comércio Eletrônicos S/A)
                invisivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                visivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("trCaptcha"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                visivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(59);
                break;
            case "60"://Proceda (3.1 Univar Brasil)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Remetente"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(60);
                break;
            case "61"://Proceda (3.0A GW Padrão)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Remetente"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                visivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                visivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                escondeMostraAtualizarDestinatario();
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(61);
                break;
            case "62"://Proceda (3.1 - Redespacho Celistics Barueri Transportadora LTDA)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Remetente"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                visivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                visivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(62);
                break;

            case "63"://Tambasa (XML)
                invisivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Remetente"));
                visivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                visivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                $("btVisualizar").value = "Importar";
                
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(63);
                break;
            case "64"://Proceda (3.1 - Proceda (3.1 ? Nativas Varejo e Distribuição LTDA))
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                visivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                visivel($("tdLabelArquivo"));
                invisivel($("trImportacao_ClienteProduto"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(64);
                break;
            case "65":// Unilever (Excel)
                invisivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                visivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                visivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                visivel($("tdLabelArquivo"));
                invisivel($("trImportacao_ClienteProduto"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                visivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(65);
                break;
            case "66"://Proceda (3.1 - Proceda (3.0A) BUAIZ
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                visivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                visivel($("tdLabelArquivo"));
                invisivel($("trImportacao_ClienteProduto"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(66);
                break;
            case "67"://Proceda (3.1 - Liotécnica)
                invisivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                visivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(67);
                break;
            case "68"://Proceda (3.1 - Proceda Flor Arte)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                visivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                visivel($("tdLabelArquivo"));
                invisivel($("trImportacao_ClienteProduto"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(68);
                break;
            case "69"://Proceda (3.1 - Redespacho Sist Global)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_NfRemetenteDestinatario"));
                visivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(69);
                break;  
            case "70"://Proceda (3.1 - Faber Castel)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                invisivel($("trImportacao_Remetente"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                visivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(70);
                break; 
            case "71"://Proceda (5.0 - Editora Abril)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                visivel($("trImportacao_ConsiderarFrete"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_NfRemetenteDestinatario"));
                visivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdLabelArquivo"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(71);
            break;
            case "72"://Proceda (3.1 - Madeira Madeira)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                visivel($("tdLabelArquivo"));
                invisivel($("trImportacao_ClienteProduto"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(72);
                break;
            case "73"://Proceda (3.1 - Supporte Armaz Vendas Logist Int LTDA)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                visivel($("tdLabelArquivo"));
                invisivel($("trImportacao_ClienteProduto"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(73);
                break;
            case "74"://Start Química (Excel)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                visivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                visivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                visivel($("tdLabelArquivo"));
                invisivel($("trImportacao_ClienteProduto"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(74);
                break;
                case "75"://TIVIT (5.0 - Itatiaia)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                visivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                visivel($("tdLabelArquivo"));
                invisivel($("trImportacao_ClienteProduto"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                visivel($("trImportacao_gerarCTePorNumeroFRS"));
                visivel($("trImportacao_CalcularPrazoEntregaTabelaPreco"));
                dadosImportacaoFiltrosLayout(75);
                break;
                case "76":// Grupo Farrapos (Transportadora)
                    // campos que não estão no XLS
                    visivel($("trImportacao_Redespacho"));
                    visivel($("trImportacao_Destinatario"));
                    visivel($("trImportacao_Consignatario"));
                    visivel($("trImportacao_Representante"));
                    visivel($("trImportacao_Recebedor"));
                    visivel($("trImportacao_Expedidor"));
                    invisivel($("trImportacao_ConsiderarFrete"));
                    visivel($("trImportacao_NfRemetenteDestinatario"));
                    invisivel($("trImportacao_NfNumeroPedido"));
                    invisivel($("trImportacao_ClienteProduto"));
                    invisivel($("trImportacao_ImportarFilialSelecionada"));
                    invisivel($("trImportacao_UtilizarDadosVeiculo"));
                    invisivel($("trImportacao_Remetente"));
                    invisivel($("trImportacao_CadastrarMercadoria"));
                    invisivel($("trImportacao_ImportarItemNf"));
                    invisivel($("trImportacao_AtualizarCadRemetente"));
                    visivel($("trImportacao_AtualizarCadDestinatario"));
                    visivel($("trImportacao_AtualizarEndDesitinatario"));
                    visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                    invisivel($("trImportacao_AgruparPorVeiculo"));
                    invisivel($("trImportacao_subServico"));
                    invisivel($("trImportacao_BasePadraoCubagem"));
                    invisivel($("trImportacao_NfUfDestino"));
                    invisivel($("trImportacao_gerarCTePorNumeroFRS"));

                    // campos que não estão no XLS
                    visivel($("tdLabelArquivo"));
                    $("btVisualizar").value = "Importar";
                    visivel($("arq01"));
                    visivel($("tdInput"));
                    invisivel($("tdDtEmissao1"));
                    invisivel($("tdChaveAcessoNFe1"));
                    invisivel($("trCaptcha"));
                    invisivel($("tdChaveAcessoNFe2"));
                    invisivel($("tdChaveAcessoCTe1"));
                    invisivel($("tdChaveAcessoCTe2"));
                    invisivel($("tdDtEmissao2"));
                    invisivel($("tdCarga1"));
                    invisivel($("tdCarga2"));
                    invisivel($("tdGSM1"));
                    invisivel($("tdGSM2"));
                    invisivel($("tdNotaFiscal1"));
                    invisivel($("tdNotaFiscal2"));
                    invisivel($("trNotaFiscalRemetente"));
                    invisivel($("trNotaFiscalDestinatario"));
                    invisivel($("trQuantidadeNotas"));
                    invisivel($("trNotasEscolhidas"));
                    invisivel($("trEscolherNotas"));
                    invisivel($("divProcedaMagazineLuiza"));
                    visivel($("trImportacao_CalcularPrazoEntregaTabelaPreco"));
                    dadosImportacaoFiltrosLayout(76);
                break;
            case "77": // Proceda (3.1 - Cia de Tecidos Santo Antonio)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                visivel($("tdLabelArquivo"));
                invisivel($("trImportacao_ClienteProduto"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                dadosImportacaoFiltrosLayout(77);
                break;
            case "78": // SETCESP-COTIN (Redespacho)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                visivel($("tdLabelArquivo"));
                invisivel($("trImportacao_ClienteProduto"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                invisivel($("trImportacao_CalcularPrazoEntregaTabelaPreco"));
                dadosImportacaoFiltrosLayout(78);
                break;
            case "79"://Proceda (3.0A - MEXICHEM BRASIL)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                visivel($("tdLabelArquivo"));
                invisivel($("trImportacao_ClienteProduto"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                invisivel($("trImportacao_CalcularPrazoEntregaTabelaPreco"));
                dadosImportacaoFiltrosLayout(79);
                break;
         case "80": // SETCESP-COTIN (Rico Transportes)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                visivel($("tdLabelArquivo"));
                invisivel($("trImportacao_ClienteProduto"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                invisivel($("trImportacao_CalcularPrazoEntregaTabelaPreco"));
                dadosImportacaoFiltrosLayout(80);
                break;        
         case "81": // Proceda (3.0A ? GROUPE SEB)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                visivel($("tdLabelArquivo"));
                invisivel($("trImportacao_ClienteProduto"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                invisivel($("trImportacao_CalcularPrazoEntregaTabelaPreco"));
                dadosImportacaoFiltrosLayout(81);
                break;        
         case "82": // Proceda (3.1 - Santher)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                visivel($("tdLabelArquivo"));
                invisivel($("trImportacao_ClienteProduto"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                invisivel($("trImportacao_CalcularPrazoEntregaTabelaPreco"));
                dadosImportacaoFiltrosLayout(82);
                break;
            case "83": // Proceda (3.1 - Kimberly Clark)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                visivel($("tdLabelArquivo"));
                invisivel($("trImportacao_ClienteProduto"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                invisivel($("trImportacao_CalcularPrazoEntregaTabelaPreco"));
                dadosImportacaoFiltrosLayout(83);
                break; 
            case "85": // Proceda (3.0A - O. V. D. IMPORTADORA E DISTRIBUIDORA LTDA)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                visivel($("tdLabelArquivo"));
                invisivel($("trImportacao_ClienteProduto"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                invisivel($("trImportacao_CalcularPrazoEntregaTabelaPreco"));
                invisivel($("spanAgruparNFeDataEmissao"));
                invisivel($("trImportacao_Responsavel"));
                dadosImportacaoFiltrosLayout(85);
                break;
            case "86"://Proceda (3.0A - LEROY MERLIN)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                visivel($("tdLabelArquivo"));
                invisivel($("trImportacao_ClienteProduto"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                invisivel($("trImportacao_CalcularPrazoEntregaTabelaPreco"));
                dadosImportacaoFiltrosLayout(86);
        case "87": // Proceda (3.1 - Tambasa)
                invisivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                visivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                visivel($("tdLabelArquivo"));
                invisivel($("trImportacao_ClienteProduto"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                $("nfRemetenteDestintarioSim").checked = true;
                 mostrarFiltroPedido();
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                invisivel($("trImportacao_CalcularPrazoEntregaTabelaPreco"));
                invisivel($("spanAgruparNFeDataEmissao"));
                dadosImportacaoFiltrosLayout(87);        
                break;
        case "88": // Proceda (3.1 - MARILAN ALIMENTOS S/A)
                visivel($("trImportacao_Redespacho"));
                visivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                visivel($("trImportacao_Representante"));
                visivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                visivel($("trImportacao_AtualizarCadRemetente"));
                visivel($("trImportacao_AtualizarCadDestinatario"));
                visivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                visivel($("tdLabelArquivo"));
                invisivel($("trImportacao_ClienteProduto"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                $("nfRemetenteDestintarioSim").checked = true;
                 mostrarFiltroPedido();
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                invisivel($("trImportacao_CalcularPrazoEntregaTabelaPreco"));
                invisivel($("spanAgruparNFeDataEmissao"));
                dadosImportacaoFiltrosLayout(88);        
                break;
        case "89": // Proceda (3.1 - DHL)
                visivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                visivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                visivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                visivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                visivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                invisivel($("trImportacao_subServico"));
                invisivel($("trImportacao_BasePadraoCubagem"));
                visivel($("tdLabelArquivo"));
                invisivel($("trImportacao_ClienteProduto"));
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("tdChaveAcessoCTe2"));
                $("nfRemetenteDestintarioSim").checked = true;
                mostrarFiltroPedido();
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("tdNotaFiscal1"));
                invisivel($("tdNotaFiscal2"));
                invisivel($("trNotaFiscalRemetente"));
                invisivel($("trNotaFiscalDestinatario"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                invisivel($("trImportacao_CalcularPrazoEntregaTabelaPreco"));
                invisivel($("spanAgruparNFeDataEmissao"));
                dadosImportacaoFiltrosLayout(89);
                break;
                
        default://caso o campo não fique em nenhum case.
                invisivel($("trImportacao_Redespacho"));
                invisivel($("trImportacao_Destinatario"));
                invisivel($("trImportacao_Remetente"));
                invisivel($("trImportacao_Consignatario"));
                invisivel($("trImportacao_Representante"));
                invisivel($("trImportacao_Recebedor"));
                invisivel($("trImportacao_Expedidor"));
                invisivel($("trImportacao_ConsiderarFrete"));
                invisivel($("trImportacao_NfRemetenteDestinatario"));
                invisivel($("trImportacao_NfUfDestino"));
                invisivel($("trImportacao_NfNumeroPedido"));
                invisivel($("trImportacao_gerarCTePorNumeroFRS"));
                invisivel($("trImportacao_ImportarFilialSelecionada"));
                invisivel($("trImportacao_ClienteProduto"));
                invisivel($("trImportacao_UtilizarDadosVeiculo"));
                invisivel($("trImportacao_CadastrarMercadoria"));
                invisivel($("trImportacao_ImportarItemNf"));
                invisivel($("trImportacao_AtualizarCadDestinatario"));
                invisivel($("trImportacao_UtilizarTabelaDestintarioRemetente"));
                invisivel($("trImportacao_AgruparPorVeiculo"));
                $("btVisualizar").value = "Importar";
                invisivel($("arq01"));
                invisivel($("tdLabelArquivo"));
                invisivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoCTe1"));
                invisivel($("trCaptcha"));
                //invisivel($("tdChaveAcessoNFe2"));
                invisivel($("chaveAcessoNFe"));
                invisivel($("tdChaveAcessoCTe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                invisivel($("tdGSM1"));
                invisivel($("tdGSM2"));
                invisivel($("trQuantidadeNotas"));
                invisivel($("trNotasEscolhidas"));
                invisivel($("trEscolherNotas"));
                invisivel($("divProcedaMagazineLuiza"));          
                invisivel($("trImportacao_BasePadraoCubagem"));
                invisivel($("trImportacao_AtualizarCadRemetente"));
                invisivel($("trImportacao_AtualizarEndDesitinatario"));
                invisivel($("trImportacao_BasePadraoCubagemAereo"));
                invisivel($("trImportacao_CalcularPrazoEntregaTabelaPreco"));
            return false;
            break;
        }
        
    }
    
    function escolherCaptcha(){
        if ($("layoutArquivo").value == 54) {
            ajaxCarregarCaptchaCTE();
        }else{
            ajaxCarregarCaptcha();
        }
    }
    
    
    function ajaxCarregarCaptcha(index,anexarDireto){
        var nfe = jQuery('#chaveAcessoNFe_'+index).val();
        var popChave = window.open('http://www.nfe.fazenda.gov.br/portal/consultaRecaptcha.aspx?tipoConsulta=completa&tipoConteudo=XbSeqxE8pl8=&nfe='+nfe,'', 'width=1000, height=700,scrollbars=1');
        jQuery('.block-tela').show();
        var interval = setInterval(function(){
            if (localStorage.getItem(nfe)) {
                clearInterval(interval);
                jQuery.ajax({
                    'url':'ConhecimentoControlador?acao=iniciarConsultarNFe',
                    data:{
                        'html':localStorage.getItem(nfe),
                        'chave':nfe,
                        'importarItemNf':jQuery('#importarItemNfSim').is(":checked"),
                        'cadastrarMercadoria':jQuery('#cadastrarMercadoriaSim').is(":checked")
                    },
                    'method':'post',
                    complete: function (data, textStatus, jqXHR) {
                        if(data.responseText.indexOf('ATENÇÃO') > -1){
                            alert(data.responseText);
                            return false;
                        }
                        jQuery("#trCaptcha").show();
                        try{
                            //validar se ocorreu um erro na trigger 'insert_arquivo_importacao_xml';
                            if (data.responseText.includes("insert_arquivo_importacao_xml")) {
                                throw 'ERROR:'+data.responseText;
                            }
                            jQuery("#layoutArquivo").attr("disabled", true);
                            jQuery("#imgChaveAcesso_"+(index)).show();
                            jQuery("#trCaptcha").hide();
                            jQuery("#chaveAcessoNFe_"+(index)).attr("readOnly",true);
                            jQuery("#consultarChaveAcesso_"+(index)).hide();
                            jQuery("#removerChaveAcesso_"+(index)).show();
                            sessionStorage.setItem(nfe,true);
                            addChaveAcesso();
                            if (anexarDireto) {
                                anexar();
                            }
                        }catch(err){
                            jQuery("#trCaptcha").hide();
                            alert(err);
                            console.error(err);
                        }finally{
                            localStorage.clear(); 
                        }
                   }
                });
                popChave.close();
                jQuery('.block-tela').hide();
            }
        }, 500);
    }
    
    function ajaxValidarExisteChaveBanco(tipo, index, anexarDireto){
        if (anexarDireto == null || anexarDireto == undefined) {
            anexarDireto = false;
        }
        
        if (tipo === "") {
            var layout = jQuery("#layoutArquivo").val();
            tipo = (layout === "2" ? "NFe" : "CTe");
        }
        var chave = jQuery("#chaveAcesso"+tipo+"_"+index).val();
        
        if (sessionStorage.getItem(chave) != undefined) {
            alert("chave já importada.");
            return false;
        }
        
        
        
        if (jQuery("#layoutArquivo").val() === '2') {
            tryRequestToServer(
                function(){
                    espereEnviar("Aguarde...", true);
                    new Ajax.Request("ConhecimentoControlador?acao=ajaxValidarExisteChaveBanco&chaveAcesso="+chave,{
                        method:'post',
                        data: {},
                        onSuccess: function(data){
                            console.log(data);
                            espereEnviar("Aguarde...", false);
                            if (data.responseText == "false") {
                                
                                ajaxCarregarCaptcha(index,anexarDireto);
                            }else{
                                jQuery("#layoutArquivo").attr("disabled", true);
                                jQuery("#imgChaveAcesso_"+index).show();
                                jQuery("#trCaptcha").hide();
                                jQuery("#chaveAcessoNFe_"+index).prop("readOnly",true);
                                jQuery("#consultarChaveAcesso_"+index).hide();
                                jQuery("#removerChaveAcesso_"+index).show();
                                sessionStorage.setItem(chave,true);
                                addChaveAcesso();
                                if (anexarDireto) {
                                    anexar();
                                }
                            }
                        }
                    });
                }
            );
        }else{
            tryRequestToServer(
                function(){
                    espereEnviar("Aguarde...", true);
                    new Ajax.Request("ConhecimentoControlador?acao=ajaxValidarExisteChaveBanco&chaveAcesso="+chave,{
                        method:'post',
                        data: {},
                        onSuccess: function(data){
                            console.log(data);
                            espereEnviar("Aguarde...", false);
                            if (data.responseText == "false") {
                                ajaxCarregarCaptchaCTE(index,anexarDireto);
                            }else{
                                jQuery("#layoutArquivo").attr("disabled", true);
                                jQuery("#imgChaveAcesso_"+index).show();
                                jQuery("#trCaptcha").hide();
                                jQuery("#chaveAcessoCTe_"+index).prop("readOnly",true);
                                jQuery("#consultarChaveAcesso_"+index).hide();
                                jQuery("#removerChaveAcesso_"+index).show();
                                sessionStorage.setItem(chave,true);
                                addChaveAcesso();
                                if (anexarDireto) {
                                    anexar();
                                }
                            }
                        }
                    });
                }
            );
        }
    }
    
    function ajaxCarregarCaptchaCTE(index, anexarDireto){
        var cte = jQuery('#chaveAcessoCTe_'+index).val();
        var popChave = window.open('http://www.cte.fazenda.gov.br/portal/consultaRecaptcha.aspx?tipoConsulta=completa&tipoConteudo=mCK/KoCqru0=&cte='+cte,'', 'width=1000, height=700,scrollbars=1');
        jQuery('.block-tela').show();
        var interval = setInterval(function(){
            if (localStorage.getItem(cte)) {
                clearInterval(interval);
                jQuery.ajax({
                    'url':'ConhecimentoControlador?acao=iniciarConsultarCTe',
                    data:{
                        'html':localStorage.getItem(cte),
                        'chave':cte
                    },
                    'method':'post',
                    complete: function (data, textStatus, jqXHR) {
                        console.log(data);
                        if (data.responseText == "true") {
                            try{
                                var chaveAcessoNFe = $("chaveAcessoCTe_"+(index)).value;
                                jQuery("#layoutArquivo").attr("disabled", true);
                                jQuery("#imgChaveAcesso_"+(index)).show();
                                jQuery("#chaveAcessoCTe_"+(index)).attr("readOnly",true);
                                jQuery("#consultarChaveAcesso_"+(index)).hide();
                                jQuery("#removerChaveAcesso_"+(index)).show();
                                sessionStorage.setItem(chaveAcessoNFe,true);
                                addChaveAcesso();
                                jQuery("#trCaptcha").hide();
                                if (anexarDireto) {
                                    anexar();
                                }
                            }catch(ex){
                                console.error(ex);
                            }finally {
                                localStorage.clear();
                            }
                        }else if (data.responseText.indexOf("ERRO:") > (-1)) {
                            alert(data.responseText);
                            localStorage.clear();
                        }
                   }
                });
                popChave.close();
                jQuery('.block-tela').hide();
            }
        }, 500);
    }
    
    //Função para carregar os dados do layout que foi definido no cliente.
    function dadosImportacaoFiltrosLayout(codigoLayout) {
        filtrosLayoutPadraoImportacao();

        if (listLayoutEdi == null || listLayoutEdi == undefined) {
            return;
        }

        let layoutEdiEscolhida = listLayoutEdi.find(e => e.layoutEDI.codigoLayout === codigoLayout);
        
        if (layoutEdiEscolhida=== undefined) {
            return;
        }

        if (layoutEdiEscolhida.atribuirRedespacho == true) {
            $("chkAtribuirRedespacho").checked = true;
        }

        $("razaoSocialRedespacho").value = (layoutEdiEscolhida.redespacho.razaosocial == undefined ? "" : layoutEdiEscolhida.redespacho.razaosocial);
        $("idRedespacho").value = layoutEdiEscolhida.redespacho.idcliente;

        if (layoutEdiEscolhida.atribuirDestinatario == true) {
            $("chkAtribuirDestinatario").checked = true;
        }

        $("razaoSocialDestinatario").value = (layoutEdiEscolhida.destinatario.razaosocial == undefined ? "" : layoutEdiEscolhida.destinatario.razaosocial);
        $("idDestinatario").value = layoutEdiEscolhida.destinatario.idcliente;

        if (layoutEdiEscolhida.atribuirRedespacho == true) {
            $("chkAtribuirRedespacho").checked = true;
        }

        $("razaoSocialRedespacho").value = (layoutEdiEscolhida.redespacho.razaosocial == undefined ? "" : layoutEdiEscolhida.redespacho.razaosocial);
        $("idRedespacho").value = layoutEdiEscolhida.redespacho.idcliente;

        if (layoutEdiEscolhida.atribuirDestinatario == true) {
            $("chkAtribuirDestinatario").checked = true;
        }

        if (layoutEdiEscolhida.atribuirRemetente == true) {
            $("chkAtribuirRemetente").checked = true;
        }

        $("razaoSocialRemetente").value = (layoutEdiEscolhida.remetente.razaosocial == undefined ? "" : layoutEdiEscolhida.remetente.razaosocial);
        $("idRemetente").value = layoutEdiEscolhida.remetente.idcliente;

        if (layoutEdiEscolhida.atribuirConsignatario == true) {
            $("chkAtribuirConsignatario").checked = true;
        }

        $("razaoSocialConsignatario").value = (layoutEdiEscolhida.consignatario.razaosocial == undefined ? "" : layoutEdiEscolhida.consignatario.razaosocial);
        $("idConsignatario").value = layoutEdiEscolhida.consignatario.idcliente;

        if (layoutEdiEscolhida.atribuirRepresentante == true) {
            $("chkAtribuirRepresentante").checked = true;
        }

        $("razaoSocialRepresentante").value = (layoutEdiEscolhida.representante.razaosocial == undefined ? "" : layoutEdiEscolhida.representante.razaosocial);
        $("idRepresentante").value = layoutEdiEscolhida.representante.idcliente;

        if (layoutEdiEscolhida.atribuirRecebedor == true) {
            $("chkAtribuirRecebedor").checked = true;
        }

        $("razaoSocialRecebedor").value = (layoutEdiEscolhida.recebedor.razaosocial == undefined ? "" : layoutEdiEscolhida.recebedor.razaosocial);
        $("idRecebedor").value = layoutEdiEscolhida.recebedor.idcliente;

        if (layoutEdiEscolhida.atribuirExpedidor == true) {
            $("chkAtribuirExpedidor").checked = true;
        }

        $("razaoSocialExpedidor").value = (layoutEdiEscolhida.expedidor.razaosocial == undefined ? "" : layoutEdiEscolhida.expedidor.razaosocial);
        $("idExpedidor").value = layoutEdiEscolhida.expedidor.idcliente;

        if (layoutEdiEscolhida.considerarFrete == "t") {
            $("tabelaPreco").checked = true;
        } else if (layoutEdiEscolhida.considerarFrete == "a") {
            $("valorArquivo").checked = true;
        }

        if (layoutEdiEscolhida.agruparNfRemetenteDestinatario == true) {
            $("nfRemetenteDestintarioSim").checked = true;
        } else if (layoutEdiEscolhida.agruparNfRemetenteDestinatario == false) {
            $("nfRemetenteDestintarioNao").checked = true;
        }

        if (layoutEdiEscolhida.agruparNfUfDestino == true) {
            $("nfUfDestinoSim").checked = true;
        } else if (layoutEdiEscolhida.agruparNfUfDestino == false) {
            $("nfUfDestinoNao").checked = true;
        }

        if (layoutEdiEscolhida.agruparNfNumeroPedido == true) {
            $("numeroPedidoSim").checked = true;
        } else if (layoutEdiEscolhida.agruparNfNumeroPedido == false) {
            $("numeroPedidoNao").checked = true;
        }

        if (layoutEdiEscolhida.considerarGrupoClienteProduto == true) {
            $("clienteProdutoSim").checked = true;
        } else if (layoutEdiEscolhida.considerarGrupoClienteProduto == false) {
            $("clienteProdutoNao").checked = true;
        }

        if (layoutEdiEscolhida.importarFilialSelecionada == true) {
            $("filialSelecionadaSim").checked = true;
        } else if (layoutEdiEscolhida.importarFilialSelecionada == false) {
            $("filialSelecionadaNao").checked = true;
        }

        if (layoutEdiEscolhida.utilizarDadosVeiculo == true) {
            $("utilizarDadosVeiculoSim").checked = true;
        } else if (layoutEdiEscolhida.utilizarDadosVeiculo == false) {
            $("utilizarDadosVeiculoNao").checked = true;
        }

        if (layoutEdiEscolhida.cadastrarMercadoria == true) {
            $("cadastrarMercadoriaSim").checked = true;
        } else if (layoutEdiEscolhida.cadastrarMercadoria == false) {
            $("cadastrarMercadoriaNao").checked = true;
        }

        if (layoutEdiEscolhida.importarItemNf == true) {
            $("importarItemNfSim").checked = true;
        } else if (layoutEdiEscolhida.importarItemNf == false) {
            $("importarItemNfNao").checked = true;
        }

        if (codigoLayout != "51") {
            if (layoutEdiEscolhida.agruparPorVeiculo == true) {
                $("agruparPorVeiculoSim").checked = true;
            } else if (layoutEdiEscolhida.agruparPorVeiculo == false) {
                $("agruparPorVeiculoNao").checked = true;
            }
        } else {
            $("agruparPorVeiculoNao").checked = true;
        }

        if (layoutEdiEscolhida.atualizarDestinatario == true) {
            $("atualizarCadRemetenteSim").checked = true;
        } else {
            if (layoutEdiEscolhida.atribuirRemetente == true) {
                $("atualizarCadRemetenteSim").checked = true;
            } else {
                $("atualizarCadRemetenteNao").checked = true;
            }
        }

        if (layoutEdiEscolhida.atualizarDestinatario == true) {
            $("atualizarEndDestinatarioSim").checked = true;
        } else {
            if (layoutEdiEscolhida.atualizarEnderecoDestinatario == true) {
                $("atualizarEndDestinatarioSim").checked = true;
            } else {
                $("atualizarEndDestinatarioNao").checked = true;
            }
        }

        if (layoutEdiEscolhida.atualizarDestinatario == true) {
            $("atualizarCadDestinatarioSim").checked = true;
        } else if (layoutEdiEscolhida.atualizarDestinatario == false) {
            $("atualizarCadDestinatarioNao").checked = true;
        }

        if (layoutEdiEscolhida.subContratacao == true) {
            $("inpSubContratacaoSim").checked = true;
        } else if (layoutEdiEscolhida.subContratacao == false) {
            $("inpSubContratacaoNao").checked = true;
        }

        if (layoutEdiEscolhida.atribuirResponsavelPagamento == true) {
            $("chkAtribuirResponsavel").checked = true;
            mostrarRadioResponsavel();
        } else {
            $("chkAtribuirResponsavel").checked = false;
            mostrarRadioResponsavel();
        }

        if (layoutEdiEscolhida.tipoResponsavelPagamento == '0') {
            $("responsavelCIF").checked = true;
        } else if (layoutEdiEscolhida.tipoResponsavelPagamento == '1') {
            $("responsavelFOB").checked = true;
        } else if (layoutEdiEscolhida.tipoResponsavelPagamento == '2') {
            $("responsavelTerceiro").checked = true;
        }

        jQuery("#tipoTabela option[value='" + layoutEdiEscolhida.tipoTabelaDestinatario + "']").prop("selected", true);
        jQuery("#tabelaRemetente option[value='" + layoutEdiEscolhida.utilizarTabelaRemetente + "']").prop("selected", true);

        $("razaoSocialRemetenteNotaFiscal").value = (layoutEdiEscolhida.remetenteNotaFiscal.razaosocial == undefined ? "" : layoutEdiEscolhida.remetenteNotaFiscal.razaosocial);
        $("idRemetenteNotaFiscal").value = layoutEdiEscolhida.remetenteNotaFiscal.idcliente;
        $("inpBasePadraoCubagem").value = layoutEdiEscolhida.basePadraoCubagem;
        $("inpBasePadraoCubagemAereo").value = layoutEdiEscolhida.basePadraoCubagemAereo;

        if (layoutEdiEscolhida.calcularPrazoTabelaPreco == true) {
            $("calcularPrazoEntregaTabelaPrecoSim").checked = true;
        } else if (layoutEdiEscolhida.calcularPrazoTabelaPreco == false) {
            $("calcularPrazoEntregaTabelaPrecoNao").checked = true;
        }

        if (layoutEdiEscolhida.considerarVolume == "1") {
            $("inpTagTransportadora").checked = true;
        } else if (layoutEdiEscolhida.considerarVolume == "2") {
            $("inpTagZeroTransportadora").checked = true;
        }

        if (layoutEdiEscolhida.agruparNFeEmissao) {
            $('agruparNFeDataEmissao').checked = true;
        }

        if (layoutEdiEscolhida.tagsPersonalizadas !== undefined && layoutEdiEscolhida.tagsPersonalizadas.length > 0) {
            for (let i = 0; i < layoutEdiEscolhida.tagsPersonalizadas.length; i++) {
                let tag = layoutEdiEscolhida.tagsPersonalizadas[i];

                aoClicarAdicionarTags({
                    'campo': tag.campo.toLowerCase(),
                    'nome_tag': tag.tag
                });
            }
        }
        var liberarLayout = ($("idCliente").value == 0 ? "false" : "true");
        readOnlyCamposFiltroLayoutImportacao(liberarLayout);
    }

    //Função para pegar o valor padrão do layout
    function filtrosLayoutPadraoImportacao(){    
            $("chkAtribuirRedespacho").checked = false;
            $("idRedespacho").value = "0";
            $("razaoSocialRedespacho").value = "";
            $("chkAtribuirDestinatario").checked = false;
            $("idDestinatario").value = "0";
            $("razaoSocialDestinatario").value = "";
            $("chkAtribuirRemetente").checked = false;
            $("idRemetente").value = "0";
            $("razaoSocialRemetente").value = "";
            $("chkAtribuirConsignatario").checked = false;
            $("idConsignatario").value = "0";
            $("razaoSocialConsignatario").value = "";
            $("chkAtribuirRepresentante").checked = false;
            $("idRepresentante").value = "0";
            $("razaoSocialRepresentante").value = "";
            $("chkAtribuirRecebedor").checked = false;
            $("idRecebedor").value = "0";
            $("razaoSocialRecebedor").value = "";
            $("chkAtribuirExpedidor").checked = false;
            $("idExpedidor").value = "0";
            $("razaoSocialExpedidor").value = "";        
            $("tabelaPreco").checked = true;
            $("nfRemetenteDestintarioSim").checked = true;
        $("nfUfDestinoNao").checked = true;
            $("numeroPedidoNao").checked = true;
            $("clienteProdutoSim").checked = true;
            $("filialSelecionadaNao").checked = true;
            $("utilizarDadosVeiculoNao").checked = true;
            if ("${configuracao.importarCtrcNotaMercadoria}"== "true" || "${configuracao.importarCtrcNotaMercadoria}"== "t") {
                $("cadastrarMercadoriaSim").checked = true;
            }else{
                $("cadastrarMercadoriaNao").checked = true;
            }
            if ("${configuracao.importarCtrcNotaItem}"== "true" || "${configuracao.importarCtrcNotaItem}"== "t") {
                $("importarItemNfSim").checked = true;
            }else{
                $("importarItemNfNao").checked = true;
            }
            $("agruparPorVeiculoNao").checked = true;
//            $("atualizarCadDestinatarioNao").checked = true;
            $("inpSubContratacaoNao").checked = true;
            $("tipoTabela").value = "-1";
            $("tabelaRemetente").value = "n";
            jQuery('#tbodyTagsPersonalizadas').empty();
            $('qtdDomTagsPersonalizadas').value = '0';
            qtdDomTagsPersonalizadas = 0;
    }
    
    //função para colocar os campos readonly e desabilitado
    function readOnlyCamposFiltroLayoutImportacao(isBloquear){
        mostrarLocalizaRedespacho();
        mostrarLocalizaDestinatario();
        mostrarLocalizaRemetente();
        mostrarLocalizaConsignatario();
        mostrarLocalizaRepresentante();
        mostrarLocalizaRecebedor();
        mostrarLocalizaExpedidor();
        if (isBloquear == "true") {
            jQuery("input").attr("readOnly",true).attr("disabled",true);
            jQuery("#inpBasePadraoCubagem").attr("readOnly",true).attr("disabled",false);
            jQuery("#inpBasePadraoCubagemAereo").attr("readOnly",true).attr("disabled",false);
            jQuery("select").attr("readOnly",true).attr("disabled",true);
            jQuery("img").hide();
            jQuery("#btnlLocalizarRedespacho").hide();
            jQuery("#btnlLocalizarDestinatario").hide();
            jQuery("#btnlLocalizarRemetente").hide();

            jQuery("#btnlLocalizarConsignatario").hide();
            jQuery("#btnlLocalizarRepresentante").hide();
            jQuery("#btnlLocalizarRecebedor").hide();
            jQuery("#btnlLocalizarExpedidor").hide();
            jQuery("#layoutArquivo").attr("readOnly",false).attr("disabled",false);
            jQuery("#arq01").attr("readOnly",false).attr("disabled",false);
            jQuery("#btnFechar").attr("readOnly",false).attr("disabled",false);
            jQuery("#btVisualizar").attr("readOnly",false).attr("disabled",false);
            jQuery("#btnlLocalizarCliente").attr("readOnly",false).attr("disabled",false);
            jQuery("#razaoSocialCliente").attr("disabled",false);
            jQuery("#btLocGSM").attr("readOnly",false).attr("disabled",false);                        
            jQuery("#btLocCarga").attr("readOnly",false).attr("disabled",false);                        
            jQuery("#chaveAcessoNFe").attr("readOnly",false).attr("disabled",false);                        
            jQuery("#chaveAcessoCTe").attr("readOnly",false).attr("disabled",false);
            jQuery("input[id*='chaveAcessoNFe_']").attr("readOnly",false).attr("disabled",false);                        
            jQuery("input[id*='chaveAcessoCTe_']").attr("readOnly",false).attr("disabled",false);
            jQuery("input[id*='consultarChaveAcesso_']").attr("readOnly",false).attr("disabled",false);
            jQuery("#captcha").attr("readOnly",false).attr("disabled",false);                        
            jQuery("#Consultar").attr("readOnly",false).attr("disabled",false);                        
            jQuery("#imgCaptcha").show();                        
            jQuery("#dtEmissao").attr("readOnly",false).attr("disabled",false);
            jQuery("#btnBorrachaCliente").show();
            jQuery("#logoMarca").show();
            jQuery("#emissaoDe").removeAttr("readOnly").removeAttr("disabled");
            jQuery("#emissaoAte").removeAttr("readOnly").removeAttr("disabled");
            jQuery("#btnEscolherNotasManualmente").removeAttr("readOnly").removeAttr("disabled");
        }else if (isBloquear == "false") {
            jQuery("input").removeAttr("readOnly").removeAttr("disabled");
            jQuery("select").removeAttr("readOnly").removeAttr("disabled");
            jQuery("img").show();
            jQuery("input").show();
            jQuery("#inpBasePadraoCubagem").attr("readOnly",true).attr("disabled",false).val("");
            jQuery("#inpBasePadraoCubagemAereo").attr("readOnly",true).attr("disabled",false).val("");
        }
        
    }
    
    function anexar(){
        window.onbeforeunload = null;
        var pai = window.opener.document;
        var arq01 = $("arq01").value;
       
        var filial = "";
//        var filialCadConhecimento = "";
        var formulario = $("formularioFilho");
        formulario.enctype = "multipart/form-data";
        
        try {
            if (pai.getElementById("filial") != null && "${param.tipoImportacao}" != "unico") {
                //                filialId = pai.getElementById("filial").value.split("@@")[0];
                filial = pai.getElementById("filial").value;
            }else if(pai.getElementById("idfilial") != null){
                filial = pai.getElementById("idfilial").value;
            }
            
            // analisando a rotina de anexar itens a nota, foi visto que na tela de novo cadastro de CTE não tem essa opção no DOM de NF.
            // assim, Deivid disse que deveria travar o usuário de ter a opção de anexar os itens na nota pela rotina de novo cadastro.
            if ("${param.tipoImportacao}" == "unico" && $("importarItemNfSim").checked) {
                alert("Atenção, para inserir os itens na nota fiscal, deverá ser utilizada a rotina de importação em lote.");
                return false;
            } 
             
            var isDadosVeiculo = ($("utilizarDadosVeiculoSim").checked ? true : false);
            var fontePreco = ($("tabelaPreco").checked ? "t" : "a");
            if (arq01 == "" && $("layoutArquivo").value != "40" 
                    && $("layoutArquivo").value != "2" 
                    && $("layoutArquivo").value != "4" 
                    && $("layoutArquivo").value != "5" 
                    && $("layoutArquivo").value != "53"
                    && $("layoutArquivo").value != "54"
                    && $("layoutArquivo").value != "55"
                ){
                alert("Selecione o arquivo.");
                return false;
                
                var ultimoPonto = arq01.lastIndexOf(".");
                
                var extensao = arq01.substr(ultimoPonto+1).toUpperCase();
                
                var possuiExtencao = false;
                for(var i=0;i<arrayExtencoes.length;i++){
                    
                    if( arrayExtencoes[i].indexOf( extensao ) != -1 ){
                        possuiExtencao = true;
                    }
                }
                
                if(!possuiExtencao){
                    return  alert( "Extensão de arquivo inválida." );
                }
                formulario.enctype = "multipart/form-data";
            }else if($("layoutArquivo").value == "40" && $("dtEmissao").value == ""){
                return showErro("Informe a data de emissão!", $("dtEmissao"));
//            }else if($("layoutArquivo").value == "54" && $("chaveAcessoCTe").value == ""){
//                return showErro("Informe a chave de acesso do CT-e!", $("chaveAcessoCTe"));
//            }else if($("layoutArquivo").value == "54" && jQuery("#chaveAcessoCTe").val().length < 44 ){
//                return showErro("A chave de acesso do CT-e deve ter 44 digitos!", $("chaveAcessoCTe"));
            }else if($("layoutArquivo").value == "2" || $("layoutArquivo").value == "54"){
                if (($("layoutArquivo").value == "2") && 
                        ((!(jQuery("input[name^='chaveAcessoNFe_']").length > 1)) || 
                        jQuery("input[name^='chaveAcessoNFe_']").last().val() != '')) {
                    
                    if (!(jQuery("#trCaptcha").is(":visible"))) {
                        if (confirm('Atenção, a ultima chave de acesso não foi verificada, deseja validar?')) {
                            ajaxValidarExisteChaveBanco('NFe', jQuery("input[name^='chaveAcessoNFe_']").last().attr("indx"), true);
                            return false;
                        }
                    }else{
                            chamarImportacao(true);
                            return false;
                    }
                    alert("deve ser confirmado todas as notas antes de importar");
                    return false;
                }
                if (($("layoutArquivo").value == "54") && 
                        ((!(jQuery("input[name^='chaveAcessoCTe_']").length > 1)) || 
                        jQuery("input[name^='chaveAcessoCTe_']").last().val() != '')) {
                    
                     if (!(jQuery("#trCaptcha").is(":visible"))) {
                        if (confirm('Atenção, a ultima chave de acesso não foi verificada, deseja validar?')) {
                            ajaxValidarExisteChaveBanco('CTe', jQuery("input[name^='chaveAcessoCTe_']").last().attr("indx"), true);
                            return false;
                        }
                    }else{
                            chamarImportacao(true);
                            return false;
                    }
                    alert("deve ser confirmado todos os CTes antes de importar");
                    return false;
                }
                formulario.enctype = "";
//            }else if($("layoutArquivo").value == "2" && $("chaveAcessoNFe").value == ""){
//                return showErro("Informe a chave de acesso da NF-e!", $("chaveAcessoNFe"));
            }else if($("layoutArquivo").value == "5" && ($("idGSM").value == "" || $("idGSM").value == "0")){
                return showErro("Informe a GSM!", $("numeroGSM"));
            }else if($("layoutArquivo").value == "6" && ($("idCarga").value == "" || $("idCarga").value == "0")){
                return showErro("Informe a Carga!", $("numeroCarga"));
                        
            }else if($("layoutArquivo").value == "49"){
               isDadosVeiculo = true;
               fontePreco = "a";
            }else if ($("layoutArquivo").value == "50") {
//                if ($("idRemetente").value == 0) {
//                    alert("Atenção: Remetente é obrigatório");
//                    return false;
//                }if ($("idConsignatario").value == 0) {
//                    alert("Atenção: Consignatário é obrigatório");
//                    return false;
//                }
            }else if ($("layoutArquivo").value == "53") {
                if($("emissaoDe").value == "" && $("emissaoAte").value == "" && $("idRemetenteNotaFiscal").value == "0" && $("idDestinatarioNotaFiscal").value == "0"){
                    alert("Informe pelo menos um filtro!");
                    return false;
                }else if($("emissaoDe").value == "" || $("emissaoAte").value == ""){
                    alert("Informe a data de emissão corretamente!");
                    return false;
                }
            }else if ($("layoutArquivo").value == "55") {
                formulario.enctype = "";
                habilitar($("apenasNotas"));
                if($("emissaoDe").value == "" || $("emissaoAte").value == "" || $("idRemetenteNotaFiscal").value == "0"){
                    showErro("Informe os filtros", $("emissaoDe"), $("emissaoAte"), $("razaoSocialRemetenteNotaFiscal"));
                    return false;
                }else if($("emissaoDe").value == "" || $("emissaoAte").value == ""){
                    alert("Informe a data de emissão corretamente!");
                    return false;
                }
            } else if($("trImportacao_AgruparPorVeiculo").style.display == "" && $("agruparPorVeiculoSim").checked && $("nfRemetenteDestintarioSim").checked){
                alert("Informe apenas uma forma de agrupamento (Remetente e Destinatário) ou (Veículo)");
                return false;
            } else if ($("trImportacao_AgruparPorVeiculo").style.display == "" && $("agruparPorVeiculoSim").checked && $("nfUfDestinoSim").checked) {
                alert("Informe apenas uma forma de agrupamento (Remetente e Destinatário) ou (Veículo) ou (UF de Destino)");
                return false;
            } else if ($("trImportacao_AgruparPorVeiculo").style.display == "" && $("nfUfDestinoSim").checked && $("nfRemetenteDestintarioSim").checked) {
                alert("Informe apenas uma forma de agrupamento (Remetente e Destinatário) ou (Veículo) ou (UF de Destino)");
                return false;
            } else if ($("trImportacao_Redespacho").style.display == "" && $("chkAtribuirRedespacho").checked && $("idRedespacho").value == 0) {
                alert("Atenção: Redespacho é obrigatório!");
                return true;
            }else if($("trImportacao_Destinatario").style.display == "" && $("chkAtribuirDestinatario").checked && $("idDestinatario").value == 0){
                alert("Atenção: Destinatario é obrigatório!");
                return true;                
            }else if($("trImportacao_Remetente").style.display == "" & $("chkAtribuirRemetente").checked && $("idRemetente").value == 0){
                alert("Atenção: Remetente é obrigatório!");
                return true;                
            }else if($("trImportacao_Consignatario").style.display == "" && $("chkAtribuirConsignatario").checked && $("idConsignatario").value == 0) {
                    alert("Atenção: Consignatario é obrigatório!");
                    return true;
                } else if ($("trImportacao_Representante").style.display == "" && $("chkAtribuirRepresentante").checked && $("idRepresentante").value == 0) {
                    alert("Atenção: Representante é obrigatório!");
                    return true;
                } else if ($("chkAtribuirRecebedor").checked && $("idRecebedor").value == 0 && ($("layoutArquivo").value == "1" || $("layoutArquivo").value == "2")) {
                    alert("Atenção: Recebedor é obrigatório!");
                    return true;
                } else if ($("chkAtribuirExpedidor").checked && $("idExpedidor").value == 0 && ($("layoutArquivo").value == "1" || $("layoutArquivo").value == "2")) {
                    alert("Atenção: Expedidor é obrigatório!");
                    return true;
                }
                
                if($("layoutArquivo").value == "49"){
                    var nfe = '';
                    if ($('arq01').files.length < 1 || !$('arq01').files[0]) {
                        alert('Atenção: Não foi possível encontrar a chave de acesso do arquivo.');
                        return false;
                    } else {
                        var reader = new FileReader();
                        reader.addEventListener('load', function (e) {
                            var parser = new DOMParser();
                            var xmlF = parser.parseFromString(e.target.result,"text/xml");
                            nfe = xmlF.getElementsByTagName("CHAVE_ACESSO")[0].childNodes[0].nodeValue;
                            
                            var popChave = window.open('http://www.nfe.fazenda.gov.br/portal/consultaRecaptcha.aspx?tipoConsulta=completa&tipoConteudo=XbSeqxE8pl8=&nfe=' + nfe, '', 'width=1000, height=700,scrollbars=1');
                            jQuery('.block-tela').show();
                            var interval = setInterval(function () {
                                if (localStorage.getItem(nfe)) {
                                    jQuery.ajax({
                                        'url': 'ConhecimentoControlador?acao=armazenarHtmlNfe',
                                        'method': 'post',
                                        data: {
                                            'html': localStorage.getItem(nfe)
                                        },
                                        complete: function (jqXHR, textStatus) {
                                            try {
                                                clearInterval(interval);
                                                formulario.action = "ConhecimentoControlador?acao=importarFile&layoutArquivo=" + $("layoutArquivo").value +
                                                        "&filial=" + filial + "&isRedespacho=" + $("chkAtribuirRedespacho").checked + "&redespachoId=" + $("idRedespacho").value +
                                                        "&isRepresentante=" + $("chkAtribuirRepresentante").checked + "&representanteId=" + $("idRepresentante").value +
                                                        "&tipoTabela=" + $("tipoTabela").value + "&caracter=" + $("captcha").value + "&saidaId=" + $("idGSM").value +
                                                        "&cargaId=" + $("idCarga").value + "&tipoTransporte=" + pai.getElementById("tipoTransporte").value +
                                                        "&tipoImportacao=${param.tipoImportacao}" +
                                                        "&utilizarTabelaRemetente=" + $("tabelaRemetente").value + "&isRemetente=" + $("chkAtribuirRemetente").checked +
                                                        "&idremetente=" + $("idRemetente").value +
                                                        "&isConsignatario=" + $("chkAtribuirConsignatario").checked + "&consignatarioId=" + $("idConsignatario").value +
                                                        "&dtEmissao=" + $("dtEmissao").value + "&fontePreco=" + fontePreco + "&isDestinatario=" + $("chkAtribuirDestinatario").checked +
                                                        "&idDestinatario=" + $("idDestinatario").value + "&isRecebedor=" + $("chkAtribuirRecebedor").checked + "&idRecebedor=" + $("idRecebedor").value +
                                                        "&isExpedidor=" + $("chkAtribuirExpedidor").checked + "&idExpedidor=" + $("idExpedidor").value +
                                                        "&atualizarCadDestinatario=" + ($("atualizarCadDestinatarioSim").checked ? true : false) +
                                                        "&agruparNfRemetenteDestintario=" + ($("nfRemetenteDestintarioSim").checked ? true : false) + "&isDadosVeiculo=" + isDadosVeiculo +
                                                        "&agruparPedido=" + ($("numeroPedidoSim").checked ? true : false) + "&isApenasTransp=" + ($("filialSelecionadaSim").checked ? true : false) +
                                                        "&isGrupoCliProd=" + ($("clienteProdutoSim").checked ? true : false) + "&isCadastrarMercadoria=" + ($("cadastrarMercadoriaSim").checked ? true : false) +
                                                        "&isImportarItensNota=" + ($("importarItemNfSim").checked ? true : false) +
                                                        "&isAgruparPorVeiculo=" + ($("agruparPorVeiculoSim").checked ? true : false) +
                                                        "&idRemetenteNotaFiscal=" + $("idRemetenteNotaFiscal").value + "&idDestinatarioNotaFiscal=" + $("idDestinatarioNotaFiscal").value +
                                                        "&razaoSocialRemetenteNotaFiscal=" + $("razaoSocialRemetenteNotaFiscal").value + "&razaoSocialDestinatarioNotaFiscal=" + $("razaoSocialDestinatarioNotaFiscal").value +
                                                        "&dataEmissaoNotaFiscalDe=" + $("emissaoDe").value + "&dataEmissaoNotaFiscalAte=" + $("emissaoAte").value
                                                        + "&cnpjRemetente=" + $("cnpjRemetente").value
                                                        + "&rem_fantasia&isEntregaMagazineLuiza=" + ($("entrega").checked ? true : false)
                                                        + "&isSubContratacao=" + ($("inpSubContratacaoNao").checked ? false : true)
                                                        + "&inpBasePadraoCubagem=" + $("inpBasePadraoCubagem").value
                                                        + "&atualizarCadRemetente=" + ($("atualizarCadRemetenteSim").checked ? true : false)
                                                        + "&atualizarEndDestinatario=" + ($("atualizarEndDestinatarioNao").checked ? true : false)
                                                        + "&maximoChaves=" + jQuery("input[id*='chaveAcessoNFe_']").length
                                                        + "&inpBasePadraoCubagemAereo=" + $("inpBasePadraoCubagemAereo").value
                                                        + "&tipoConhecimento=" + pai.getElementById("tipoConhecimento").value
                                                        + "&nomeImgCaptcha=" + ($("nomeImgCaptcha").value)
                                                        + "&chkAtribuirResponsavel=" + $("chkAtribuirResponsavel").checked
                                                        + "&responsavel=" + jQuery('input[name="responsavel"]:checked').val()
                                                        + "&calcularPrazoEntregaTabelaPreco=" + jQuery('input[name="calcularPrazoEntregaTabelaPreco"]:checked').val()
                                                        + "&considerarVolume=" + ($("inpTagTransportadora").checked ? '1' : '2')
                                                        + "&agruparNFeDataEmissao=" + $('agruparNFeDataEmissao').checked;
                                                //                            +"html="+btoa(localStorage.getItem(nfe));
                                                //                    +"&html="+localStorage.getItem(nfe)
                                                formulario.method = "post";
                                                jQuery('.block-tela').hide();
                                                localStorage.clear();
                                                popChave.close();
                                                formulario.submit();
                                            } catch (err) {
                                                jQuery('.block-tela').hide();
                                                localStorage.clear();
                                                popChave.close();
                                            }
                                        }
                                    });
                                }
                            }, 500);
                            
                            
                        });
                        reader.readAsBinaryString($('arq01').files[0]);
                    }
                }else{
                    formulario.action ="ConhecimentoControlador?acao=importarFile&layoutArquivo="+$("layoutArquivo").value+
                    "&filial="+filial+"&isRedespacho="+$("chkAtribuirRedespacho").checked+"&redespachoId="+$("idRedespacho").value+
                    "&isRepresentante="+$("chkAtribuirRepresentante").checked+"&representanteId="+$("idRepresentante").value+
                    "&tipoTabela="+$("tipoTabela").value+"&caracter="+$("captcha").value+"&saidaId="+$("idGSM").value+
                    "&cargaId="+$("idCarga").value+"&tipoTransporte="+pai.getElementById("tipoTransporte").value+
                    "&tipoImportacao=${param.tipoImportacao}"+
                    "&utilizarTabelaRemetente="+$("tabelaRemetente").value+"&isRemetente="+$("chkAtribuirRemetente").checked+
                    "&idremetente="+$("idRemetente").value+
                    "&isConsignatario="+$("chkAtribuirConsignatario").checked+"&consignatarioId="+$("idConsignatario").value+
                    "&dtEmissao="+$("dtEmissao").value+"&fontePreco=" + fontePreco+"&isDestinatario=" + $("chkAtribuirDestinatario").checked+
                    "&idDestinatario="+ $("idDestinatario").value+"&isRecebedor="+$("chkAtribuirRecebedor").checked+"&idRecebedor="+$("idRecebedor").value+
                    "&isExpedidor="+$("chkAtribuirExpedidor").checked+"&idExpedidor="+$("idExpedidor").value+
                    "&atualizarCadDestinatario="+($("atualizarCadDestinatarioSim").checked ? true : false)+
                    "&agruparNfRemetenteDestintario="+($("nfRemetenteDestintarioSim").checked ? true : false)+"&isDadosVeiculo="+isDadosVeiculo+
                    "&agruparPedido="+($("numeroPedidoSim").checked ? true : false)+"&isApenasTransp="+($("filialSelecionadaSim").checked ? true : false)+
                    "&isGrupoCliProd="+($("clienteProdutoSim").checked ? true : false)+"&isCadastrarMercadoria="+($("cadastrarMercadoriaSim").checked ? true : false)+
                    "&isImportarItensNota="+($("importarItemNfSim").checked ? true : false)+
                    "&isAgruparPorVeiculo="+($("agruparPorVeiculoSim").checked ? true : false)+
                    "&idRemetenteNotaFiscal="+$("idRemetenteNotaFiscal").value+"&idDestinatarioNotaFiscal="+$("idDestinatarioNotaFiscal").value+
                    "&razaoSocialRemetenteNotaFiscal="+$("razaoSocialRemetenteNotaFiscal").value+"&razaoSocialDestinatarioNotaFiscal="+$("razaoSocialDestinatarioNotaFiscal").value+
                    "&dataEmissaoNotaFiscalDe="+$("emissaoDe").value+"&dataEmissaoNotaFiscalAte="+$("emissaoAte").value
                    +"&cnpjRemetente="+$("cnpjRemetente").value
                    +"&rem_fantasia&isEntregaMagazineLuiza="+($("entrega").checked ? true : false)
                    +"&isSubContratacao="+($("inpSubContratacaoNao").checked ? false : true)
                    +"&inpBasePadraoCubagem="+$("inpBasePadraoCubagem").value
                    +"&atualizarCadRemetente="+($("atualizarCadRemetenteSim").checked ? true : false)
                    +"&atualizarEndDestinatario="+($("atualizarEndDestinatarioNao").checked ? true : false)
                    +"&maximoChaves="+jQuery("input[id*='chaveAcessoNFe_']").length
                    +"&inpBasePadraoCubagemAereo="+$("inpBasePadraoCubagemAereo").value                
                    +"&tipoConhecimento="+pai.getElementById("tipoConhecimento").value                
                    +"&nomeImgCaptcha="+($("nomeImgCaptcha").value)
                    +"&chkAtribuirResponsavel="+$("chkAtribuirResponsavel").checked
                    +"&gerarCTePorNumeroFRS="+($("gerarCTePorNumeroFRSSim").checked ? true : false)
                    +"&responsavel="+jQuery('input[name="responsavel"]:checked').val()
                    +"&calcularPrazoEntregaTabelaPreco=" + jQuery('input[name="calcularPrazoEntregaTabelaPreco"]:checked').val()
                    + "&considerarVolume=" + ($("inpTagTransportadora").checked ? '1' : '2')
                    + "&agruparNFeDataEmissao=" + $('agruparNFeDataEmissao').checked
                    +"&numeroRomaneioNF=" + $('numeroRomaneioNF').value
                    +"&qtdDomTagsPersonalizadas=" + $('qtdDomTagsPersonalizadas').value
                    +"&" + jQuery('#tbodyTagsPersonalizadas :input').removeAttr('disabled').serialize();

                    formulario.method = "post";
                    //window.open('about:blank', 'pop', 'width=210, height=100');
                    espereEnviar("Aguarde...", true);
                    formulario.submit();
                }
            } catch (e) {
                console.log(e);
                alert(e);
                espereEnviar("", false);
            }

            return true;
        }
    
    function adicionarEnterObs(obs){
        var obsNfe = replaceAll(obs,"<br/>","\n\n\r");
        return obsNfe;
    }
    
    function mostrarLocalizaRedespacho(){
        if ($("chkAtribuirRedespacho").checked) {
            $("divRedespachoLocaliza").style.display = "";
        }else{
            $("divRedespachoLocaliza").style.display = "none";
            limparRedespacho();
        }
    }
    function mostrarLocalizaDestinatario(){
        if ($("chkAtribuirDestinatario").checked) {
            $("divDestinatarioLocaliza").style.display = "";
        }else{
            $("divDestinatarioLocaliza").style.display = "none";
            limparDestinatario();
        }
    }
    function mostrarLocalizaRemetente(){
        if ($("chkAtribuirRemetente").checked) {
            $("divRemetenteLocaliza").style.display = "";
        }else{
            $("divRemetenteLocaliza").style.display = "none";
            limparRemetente();
        }
    }
    function mostrarLocalizaConsignatario(){
        if ($("chkAtribuirConsignatario").checked) {
            $("divConsignatarioLocaliza").style.display = "";
        }else{
            $("divConsignatarioLocaliza").style.display = "none";
            limparConsignatario();
        }
    }
    function mostrarLocalizaRepresentante(){
        if ($("chkAtribuirRepresentante").checked) {
            $("divRepresentanteLocaliza").style.display = "";
        }else{
            $("divRepresentanteLocaliza").style.display = "none";
            limparRepresentante();
        }
    }
    function mostrarLocalizaRecebedor(){
        if ($("chkAtribuirRecebedor").checked) {
            $("divRecebedorLocaliza").style.display = "";
        }else{
            $("divRecebedorLocaliza").style.display = "none";
            limparRecebedor();
        }
    }
    function mostrarLocalizaExpedidor(){
        if ($("chkAtribuirExpedidor").checked) {
            $("divExpedidorLocaliza").style.display = "";
        }else{
            $("divExpedidorLocaliza").style.display = "none";
            limparExpedidor();
        }
    }
    
    function mostrarFiltroPedido(){
        if($("layoutArquivo").value != "58" && $("layoutArquivo").value != "62" && $("layoutArquivo").value != "87" && $("layoutArquivo").value != "88"){
            if($("nfRemetenteDestintarioSim").checked){
                $("trImportacao_NfNumeroPedido").style.display = "";
                visivel($('spanAgruparNFeDataEmissao'));
            }else{
                $("trImportacao_NfNumeroPedido").style.display = "none";
                invisivel($('spanAgruparNFeDataEmissao'));
            }            
        }
    }
    
    function alterarData(dataBR){
        var data = dataBR.split('/');
        var novaData = data[1] + "-" + data[0] + "-" + data[2];
        return novaData;
    }
    
    function escolherNotas(){
        
        var razaoCliente = $("razaoSocialRemetenteNotaFiscal").value;
        var idCliente = $("idRemetenteNotaFiscal").value;
        var dataDe = alterarData($("emissaoDe").value);
        var dataAte = alterarData($("emissaoAte").value);
        var notasSelecionadas = $("labelNotaEscolhidasFiltro").innerHTML;
        launchPopupLocate("pops/seleciona_nota_cte_lote.jsp"
                            +"?acao=pesquisarNotas"
                            +"&idCliente="+idCliente
                            +"&dataDe="+dataDe
                            +"&dataAte="+dataAte
                            +"&notasSelecionadas="+notasSelecionadas
                            +"&razaoRemetente="+razaoCliente
                        , "pop");
    }
    function chamarImportacao(anexarDireto){
        if (anexarDireto == null || anexarDireto == undefined) {
            anexarDireto = false;
        }
        
        var layoutArquivo = $("layoutArquivo").value;
        if(layoutArquivo == 2){
            chamarImportacaoNFE(anexarDireto);
        } else if(layoutArquivo == 54){
            chamarImportacaoCTE(anexarDireto);
        }
    }
    
    function chamarImportacaoNFE(anexarDireto){
        if (anexarDireto == null || anexarDireto == undefined) {
            anexarDireto = false;
        }
        espereEnviar("Aguarde...", true);
        var index = parseInt(jQuery("#indiceChaveAcesso").val());
        var chaveAcessoNFe = $("chaveAcessoNFe_"+(index-1)).value;
        var captcha = $("captcha").value;
        if(chaveAcessoNFe != null && chaveAcessoNFe.trim() != ""){
            if(captcha != null && captcha.trim() != ""){
//                anexar();
                new Ajax.Request("ConhecimentoControlador?acao=checkCaptchaNfe&chaveAcesso="+chaveAcessoNFe+"&caracter="+captcha+"&layout=nfeChaveAcesso&isImportarItensNota="+($("importarItemNfSim").checked ? true : false),{
                    method:'post',
                    data: {},
                    onSuccess: function(data){
                        if (data.responseText == "true") {
                            espereEnviar("Aguarde...", false);
                            jQuery("#layoutArquivo").attr("disabled", true);
                            jQuery("#imgChaveAcesso_"+(index-1)).show();
                            jQuery("#trCaptcha").hide();
                            jQuery("#chaveAcessoNFe_"+(index-1)).attr("readOnly",true);
                            jQuery("#consultarChaveAcesso_"+(index-1)).hide();
                            jQuery("#removerChaveAcesso_"+(index-1)).show();
                            sessionStorage.setItem(chaveAcessoNFe,true);
                            addChaveAcesso();
                            if (anexarDireto) {
                                anexar();
                            }
                        } else {
                            espereEnviar("Aguarde...", false);
                            var imgCaptcha = replaceAll(data.responseText, "\\", "");
                            $("imgCaptcha").src = imgCaptcha + '?' + new Date().getTime();
                            $("nomeImgCaptcha").value = imgCaptcha.substring(imgCaptcha.indexOf("img/captcha/"), imgCaptcha.length);
                        }
                    }
                });
            }else{
               alert("Favor digitar o código captcha corretamente!"); 
            }
        }else{
            alert("Favor digitar a chave de acesso da NFe corretamente!");
        }
    }
    
    function chamarImportacaoCTE(anexarDireto){
        if (anexarDireto == null || anexarDireto == undefined) {
            anexarDireto = false;
        }
        var index = parseInt(jQuery("#indiceChaveAcesso").val());
        var chaveAcessoNFe = $("chaveAcessoCTe_"+(index-1)).value;
        var captcha = $("captcha").value;
        if(chaveAcessoNFe != null && chaveAcessoNFe.trim() != ""){
            if(captcha != null && captcha.trim() != ""){
//                anexar();
                new Ajax.Request("ConhecimentoControlador?acao=ajaxPesquisarXML&chaveAcesso="+chaveAcessoNFe+"&caracter="+captcha+"&layout=cteChaveAcesso",{
                    method:'post',
                    data: {},
                    onSuccess: function(data){
                        if (data.responseText == "true") {
                            espereEnviar("Aguarde...", false);
                            jQuery("#layoutArquivo").attr("disabled", true);
                            jQuery("#imgChaveAcesso_"+(index-1)).show();
                            jQuery("#chaveAcessoCTe_"+(index-1)).attr("readOnly",true);
                            jQuery("#consultarChaveAcesso_"+(index-1)).hide();
                            jQuery("#removerChaveAcesso_"+(index-1)).show();
                            sessionStorage.setItem(chaveAcessoNFe,true);
                            addChaveAcesso();
                            jQuery("#trCaptcha").hide();
                            if (anexarDireto) {
                                anexar();
                            }
                        }else if (data.responseText.indexOf("ERRO:") > (-1)) {
                            jQuery("#trCaptcha").hide();
                            alert(data.responseText);
                        }
                    }
                });
            }else{
               alert("Favor digitar o código captcha corretamente!") 
            }
            
        }else{
            alert("Favor digitar a chave de acesso do CTe corretamente!")
        }
    }
    
    function escondeMostraAtualizarDestinatario(){
        if ($("atualizarCadDestinatarioSim").checked && $("layoutArquivo").value == 61) {
            visivel($("trImportacao_AtualizarEndDesitinatario"));    
        }else{
            invisivel($("trImportacao_AtualizarEndDesitinatario"));    
        }
    }
    
    function addChaveAcesso(){
        // variaveis de uso
        var table = jQuery("#tableChaves");
        var index = parseInt(jQuery("#indiceChaveAcesso").val());
        var layout = jQuery("#layoutArquivo").val();
        
        // variaveis de tela
        var tr = jQuery("<tr class='CelulaZebra2NoAlign' id='trChaves_"+index+"' name='trChaves_"+index+"'>");
        var tdLabels = jQuery("<td width='50%'  class='textoCampos'>").
            append("<label>").text("Digite a Chave de Acesso: ");
        var tdCampos = jQuery("<td width='50%'>").
            append('<input name="chaveAcessoNFe_'+index+'" indx='+index+' id="chaveAcessoNFe_'+index+'" type="text" class="inputTexto" size="60" onkeypress="javascript:if (event.keyCode==13) tryRequestToServer( function(){ajaxValidarExisteChaveBanco(\'NFe\',\''+index+'\');});mascara(this, soNumeros);" maxLength="44" onchange="recarregarCaptchaMudouChave()"/>').
            append('<input name="chaveAcessoCTe_'+index+'" indx='+index+' id="chaveAcessoCTe_'+index+'" type="text" class="inputTexto" size="60" onkeypress="javascript:if (event.keyCode==13) tryRequestToServer( function(){ajaxValidarExisteChaveBanco(\'CTe\',\''+index+'\');});mascara(this, soNumeros);" maxLength="44" onchange="recarregarCaptchaMudouChave()"/>').
            append('<input type="button" value="validar" id="consultarChaveAcesso_'+index+'" class="inputBotao" onclick="ajaxValidarExisteChaveBanco(\'\',\''+index+'\');">').
            append('<input type="button" value="Remover" id="removerChaveAcesso_'+index+'" class="inputBotao" onclick="removerChaveBanco(\''+index+'\');" style="display: none;">').
            append('<img style="display: none" src="img/ok.png" width="20px" height="20px" id="imgChaveAcesso_'+index+'">');
        
        // setar variaveis
        tr.append(tdLabels);
        tr.append(tdCampos);
        table.append(tr);
        
        //incrementar indice
        index = index + 1;
        jQuery("#indiceChaveAcesso").val(index);
        
        // validar quem ficará visivel
        if (layout === '2') {
            jQuery("input[id*='chaveAcessoNFe_']").show();
            jQuery("input[id*='chaveAcessoCTe_']").hide();
        }else if(layout === '54'){
            jQuery("input[id*='chaveAcessoCTe_']").show();
            jQuery("input[id*='chaveAcessoNFe_']").hide();
        }
        
    }
    function removerChaveBanco(index){
        var layout = jQuery("#layoutArquivo").val();
        
        var chave = jQuery("#chaveAcesso"+(layout === '2' ? "NFe" : "CTe")+"_"+index);
        if (confirm("Deseja remover a chave \""+chave.val()+"\" da importação?")) {
            sessionStorage.removeItem(chave.val());
            jQuery("#trChaves_"+index).remove();
            if (jQuery("tr[id*='trChaves_']").length === 1) {
                jQuery("#layoutArquivo").attr("disabled", false);
            }
        }
    }
    
    window.onbeforeunload = function(){
        sessionStorage.clear();
    };
    
    function recarregarCaptchaMudouChave(){
        jQuery("#trCaptcha").hide();
        jQuery("#captcha").val('');
        jQuery("#imgCaptcha").attr('src','');
    }

    function validaRadioNF() {
        var radioImportNF = jQuery('input:radio[name=nfRemetenteDestintario]:checked').val();
        if (radioImportNF == 's') {
            alert("O agrupamento por UF de destino só pode ser utilizado caso o agrupamento por remetente e destinatário esteja desabilitado");
            $("nfUfDestinoNao").checked = true;
        }
    }

    function validaRadioUF() {
        var radioUfDestino = jQuery('input:radio[name=nfUfDestino]:checked').val();
        if (radioUfDestino == 's') {
            alert("O agrupamento por remetente e destinatário de destino só pode ser utilizado caso o agrupamento por UF esteja desabilitado");
            $("nfRemetenteDestintarioNao").checked = true;
        }
    }

    function mostrarRadioResponsavel() {
        if (jQuery('#chkAtribuirResponsavel').is(":checked")) {
            visivel($('tdRadioResponsavel'));
        } else {
            invisivel($('tdRadioResponsavel'));
        }
    }

    function aoClicarAdicionarTags(tagAdicional) {
        if (tagAdicional === undefined) {
            tagAdicional = {
                'nome_tag': '',
                'campo': 'pedido_nfe'
            }
        }

        let tbodyAdicionarTags = jQuery('#tbodyTagsPersonalizadas');

        let qtdTag = qtdDomTagsPersonalizadas++;

        $('qtdDomTagsPersonalizadas').value = qtdDomTagsPersonalizadas;

        let tr = jQuery('<tr>', {'class': 'CelulaZebra2'});
        
        let select = jQuery('<select>', {'class': 'inputtexto', 'id': 'campoTag_' + qtdTag, 'name': 'campoTag_' + qtdTag});

        select.append(jQuery('<option>', {'value': 'pedido_nfe'}).text('Pedido da NF'));
        select.append(jQuery('<option>', {'value': 'pedido_cte'}).text('Pedido do CT-e'));
        select.append(jQuery('<option>', {'value': 'carga_cte'}).text('Nº da carga do CT-e'));
        select.append(jQuery('<option>', {'value': 'obs_cte'}).text('Observação do CT-e'));

        console.log('tagAdicional[\'campo\']=' + tagAdicional['campo']);
        select.val(tagAdicional['campo']);

        tr.append(jQuery('<td>').append(jQuery('<div>', {'align': 'center'}).append(jQuery('<img>', {'src': '${homePath}/img/lixo.png', 'class': 'excluirTagAdicional imagemLink'}))));
        tr.append(jQuery('<td>').append(jQuery('<input>', {'type': 'text', 'class': 'inputtexto', 'id': 'nomeTag_' + qtdTag, 'name': 'nomeTag_' + qtdTag, 'value': tagAdicional['nome_tag']})));
        tr.append(jQuery('<td>').append(select));

        tbodyAdicionarTags.append(tr);
    }
    
    function aoClicarExcluirTag(btnExcluir) {
        let tr = btnExcluir.parent().parent().parent();
        
        if (confirm('Tem certeza que deseja excluir essa TAG?')) {
            if (confirm('Tem certeza?')) {
                tr.remove();
            }
        }
    }
</script>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>Webtrans - Importação de Conhecimento (EDI,XML,DANFE)</title>
    </head>
    <body onload="javascript:carregar();
            addChaveAcesso();
            sessionStorage.clear();">
        <img id="logoMarca" name="logoMarca" src="img/banner.gif" />
        <table class="bordaFina" width="90%" align="center">
            <tr>
                <td width="82%" align="left"><b>Importação de Conhecimento (EDI,XML,DANFE)</b></td>
                <td>
                    <input id="btnFechar" name="btnFechar" type="button" value=" Fechar " class="inputbotao" onclick="window.onbeforeunload = null;fechar();"/>
                </td>
            </tr>            
        </table>
        <br/>
        <form method="post" id="formularioFilho" enctype="">
            <input type="hidden" id="idconsignatario" name="idconsignatario" value="0" />
            <input type="hidden" id="con_rzs" name="con_rzs" value="" />
            <input type="hidden" id="con_cnpj" name="con_cnpj" value="" />
            <input type="hidden" id="idredespacho" name="idredespacho" value="0" />
            <input type="hidden" id="red_rzs" name="red_rzs" value="" />
            <input type="hidden" id="iddestinatario" name="iddestinatario" value="0" />
            <input type="hidden" id="dest_rzs" name="dest_rzs" value="" />
            <input type="hidden" id="iddestinatario" name="iddestinatario" value="0" />
            <input type="hidden" id="dest_rzs" name="dest_rzs" value="" />
            <input type="hidden" id="idremetente" name="idremetente" value="0" />
            <input type="hidden" id="rem_cnpj" name="rem_cnpj" value="0" />
            <input type="hidden" id="rem_rzs" name="rem_rzs" value="" />
            <input type="hidden" id="idredespachante" name="idredespachante" value="0" />
            <input type="hidden" id="redspt_rzs" name="redspt_rzs" value="" />
            <input type="hidden" id="idrecebedor" name="idrecebedor" value="0" />
            <input type="hidden" id="rec_rzs" name="rec_rzs" value="" />
            <input type="hidden" id="idexpedidor" name="idexpedidor" value="0" />
            <input type="hidden" id="exp_rzs" name="exp_rzs" value="" />
            <input type="hidden" name="indiceChaveAcesso" id="indiceChaveAcesso" value="0" />
            <input type="hidden" name="html" id="html" value="">
            <table width="90%" align="center" class="bordaFina">
                <tr class="tabela">
                    <td colspan="10">Seleção do Layout</td>                                    
                </tr>
                <tr class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>Cliente:</label>                                
                    </td>
                    <td width="50%" align="left" colspan="2">
                        <input type="text" id="razaoSocialCliente" name="razaoSocialCliente" class="inputReadOnly" value="" size="35" readonly/>
                        <input type="hidden" id="idCliente" name="idCliente" value=""/>
                        <input type="hidden" id="cnpjCliente" name="cnpjCliente" value=""/>
                        <input type="button" id="btnlLocalizarCliente" name="btnlLocalizarCliente" class="inputBotao" value="..." onclick="tryRequestToServer(function () {
                                    abrirLocalizarCliente();});"/>
                        <img id="btnBorrachaCliente" name="btnBorrachaCliente" src="img/borracha.gif" class="imagemLink" onclick="tryRequestToServer(function () {
                                    limparCliente();
                                });"/>
                    </td>
                </tr>    
                <tr class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>Escolha o Layout:</label>                                
                    </td>
                    <td width="50%" align="left" colspan="3">
                        <select name="layoutArquivo" id="layoutArquivo" class="inputTexto" style="width: 200px;" onchange="alterarLayout(this.value);"></select>
                        <di id="divProcedaMagazineLuiza" style="display: none">
                            <label>
                                <input type="radio" id="entrega" name="tipoMagazineLuiza" value="e" checked />
                                Entrega                                
                            </label>
                            <label>
                                <input type="radio" id="reversa" name="tipoMagazineLuiza" value="r" />
                                Reversa
                            </label>
                        </di>
                        <input type="button" value="Ir para webstore" id="irWebStore" style="display:none;" onclick="window.open('https://chrome.google.com/webstore/detail/gw-sistemas/eegmcpafdbgpjdjocjfffnkjihijhagb','','height=650, width=800, scrollbars=yes,resizable=yes');location.reload();" class="inputBotao">
                        <input type="button" value="Ir para firefox add-ons" id="irFirefox" style="display:none;" onclick="window.open('https://addons.mozilla.org/pt-BR/firefox/addon/gw-sistemas/','','height=650, width=800, scrollbars=yes,resizable=yes');location.reload();" class="inputBotao">
                    </td>                    
                </tr>
                <tr id="trBaixarXMLEmail" style="display: none">                    
                    <td class="TextoCampos"></td>
                    <td class="CelulaZebra2NoAlign" align="left">
                        <input name="btReceberEmail" id="btReceberEmail" type="button" class="inputbotao" 
                               value="  Baixar XML(s) do E-mail  " onclick="tryRequestToServer(function(){receberEmail();});" />
                    </td>
                </tr>
                <tr class="CelulaZebra2NoAlign">
                    <td id="tdLabelArquivo" align="right" colspan="1">
                        Escolha o Arquivo:
                    </td>       
                    <td id="tdInput" align="left" colspan="2">
                        <input name="arq01[]" id="arq01" type="file" multiple="multiple"  class="inputTexto" size="50" />
                    </td>       
                    <td id="tdDtEmissao1" align="right" style="display: none">
                        Data de Emissão das Notas:
                    </td>
                    <td id="tdDtEmissao2" align="left" style="display: none" >
                        <input type="text" id="dtEmissao"  name="dtEmissao" class="fieldDateMin" maxlength="10" size="12" onBlur="alertInvalidDate(this)"  />
                    </td>
                    <td id="tdChaveAcessoNFe1" align="right" style="display: none" colspan="3">
                        <table width="100%" id="tableChaves">
<!--                            <tr class="CelulaZebra2NoAlign" id="trChaves_">
                                <td width="50%" class="textoCampos">
                                    Digite a Chave de Acesso: 
                                </td>
                                <td width="50%">
                                    <input name="chaveAcessoNFe" id="chaveAcessoNFe" type="text" class="inputTexto" size="60" onkeypress="javascript:if (event.keyCode==13) tryRequestToServer( function(){ajaxValidarExisteChaveBanco();}); " />
                                    <input name="chaveAcessoCTe" id="chaveAcessoCTe" type="text" class="inputTexto" size="60" onkeypress="javascript:if (event.keyCode==13) tryRequestToServer( function(){chamarImportacaoCTE();});"  />
                                    <img style="display: " src="img/ok.png" width="20px" height="20px">
                                </td>
                            </tr>-->
                        </table>
                    </td>
<!--                    <td id="tdChaveAcessoNFe1" align="right" style="display: none" colspan="2">
                        Digite a Chave de Acesso:
                    </td>
-->
                    <td id="tdChaveAcessoCTe1" align="right" style="display: none" colspan="2">
                        Digite a Chave de Acesso:
                    </td>
                    <td id="tdChaveAcessoNFe2" align="left" style="display: none">
                        
                        
                    </td>
                    <td id="tdChaveAcessoCTe2" align="left" style="display: none">
                        
                        
                    </td>
                    <td id="tdGSM1" align="right" style="display: none">
                        Informe a GSM:
                    </td>
                    <td id="tdGSM2" align="left" style="display: none">
                        <input name="numeroGSM" id="numeroGSM" type="text" class="inputReadOnly8pt" size="15" readonly />
                        <input name="idGSM" id="idGSM" type="hidden" class="inputTexto" size="60"  />
                        <input name="btLocGSM" id="btLocGSM" type="button" class="inputBotaoMin" onclick="abrirLocalizarGSM();" value="..." />
                    </td>
                    <td id="tdCarga1" align="right" style="display: none">
                        Informe a Carga:
                    </td>
                    <td id="tdCarga2" align="left" style="display: none">
                        <input name="numeroCarga" id="numeroCarga" type="text" class="inputReadOnly8pt" size="15"  />
                        <input name="idCarga" id="idCarga" type="hidden" class="inputTexto" size="60"  />
                        <input name="btLocCarga" id="btLocCarga" type="button" class="inputBotaoMin" onclick="abrirLocalizarCarga();" value="..." />
                    </td>
                    <td id="tdNotaFiscal1" align="right" style="display: none"><label>Data de Emissão</label></td>
                    <td id="tdNotaFiscal2" style="display: none">
                        <div align="left">
                            De:
                            <input name="emissaoDe" id="emissaoDe" type="text" size="10" maxlength="10" onkeydown="fmtDate(this, event)"  onblur="alertInvalidDate(this)" class="fieldDate"  />
                            Até:
                            <input name="emissaoAte" id="emissaoAte" type="text" size="10" maxlength="10" onkeydown="fmtDate(this, event)"  onblur="alertInvalidDate(this)" class="fieldDate"  />
                        </div>
                    </td>
                </tr>
                <tr id="trCaptcha" style="display: none">
                    <td class="TextoCampos">Digite os caracteres ao lado:</td>
                    <td class="celulaZebra2" width="20%">
                        <input id="captcha" name="captcha" value="" class="inputTexto" onkeypress="javascript:if (event.keyCode==13) tryRequestToServer( function(){chamarImportacao();});" />
                        <input type="button" id="Consultar" value="Consultar" onclick="tryRequestToServer( function(){chamarImportacao();});" class="botoes">
                    </td>
                    <td class="CelulaZebra2NoAlign" align="center" colspan="2">
                        <img alt="" src="" id="imgCaptcha">                
                        <input type="hidden" id="nomeImgCaptcha" name="nomeImgCaptcha" value="">
                        <br>Se os caracteres da imagem estiverem ilegíveis,
                        <span class="linkEditar" onClick="escolherCaptcha();">gerar outra imagem</span>.
                    </td>
                </tr>
                <tr id="trNotaFiscalRemetente" style="display: none">
                    <td class="TextoCampos">
                        <label>Remetente:</label>
                    </td>
                    <td class="CelulaZebra2">
                        <input type="text" id="razaoSocialRemetenteNotaFiscal" name="razaoSocialRemetenteNotaFiscal" class="inputReadOnly" value="<c:out value="${param.razaoSocialRemetenteNotaFiscal}"/>" size="40" readonly/>
                        <input type="hidden" name="cnpjRemetente" id="cnpjRemetente" value="">
                        <input type="hidden" id="idRemetenteNotaFiscal" name="idRemetenteNotaFiscal" value="<c:out value="${param.idRemetenteNotaFiscal}"/>"/>
                        <input type="button" id="btnLocalizarRemetenteNotaFiscal" name="btnLocalizarRemetenteNotaFiscal" class="inputBotao" value="..." onclick="tryRequestToServer(function(){abrirLocalizarRemetenteNotaFiscal();});"/>
                        <img id="btnBorrachaRemetenteNotaFiscal" name="btnBorrachaRemetenteNotaFiscal" src="img/borracha.gif" class="imagemLink" onclick="limparRemetenteNotaFiscal();"/>
                    </td>                    
                </tr>
                <tr class="CelulaZebra2NoAlign" style="display: none" id="trEscolherNotas">
                    <td align="right">
                    </td>
                    <td align="left">
                        <input type="button" id="btnEscolherNotasManualmente" value="Escolher notas manualmente" onclick="javascript:escolherNotas();" class="botoes">
                        <input type="hidden" name="apenasNotas" id="apenasNotas" value="">
                    </td>
                </tr>
                <tr class="CelulaZebra2NoAlign" style="display: none" id="trNotasEscolhidas">
                    <td align="right">Notas Selecionadas:
                    </td>
                    <td align="left">
                        <label id="labelNotaEscolhidas"></label>
                        <label id="labelNotaEscolhidasFiltro" style="display: none"></label>
                    </td>
                </tr>
                <tr class="CelulaZebra2NoAlign" style="display: none" id="trQuantidadeNotas">
                    <td align="right">Quantidade de Notas:
                    </td>
                    <td align="left">
                        <label id="labelQuantidade"></label>
                    </td>
                </tr>
                <tr id="trNotaFiscalDestinatario" style="display: none">                    
                    <td class="TextoCampos">
                        <label>Destinatário:</label>
                    </td>
                    <td class="CelulaZebra2">
                        <input type="text" id="razaoSocialDestinatarioNotaFiscal" name="razaoSocialDestinatarioNotaFiscal" class="inputReadOnly" value="" size="40" readonly/>
                        <input type="hidden" id="idDestinatarioNotaFiscal" name="idDestinatarioNotaFiscal" value="0"/>
                        <input type="button" id="btnlLocalizarDestinatarioNotaFiscal" name="btnlLocalizarDestinatarioNotaFiscal" class="inputBotao" value="..." onclick="tryRequestToServer(function(){abrirLocalizarDestinatarioNotaFiscal();});"/>
                        <img id="btnBorrachaDestinatarioNotaFiscal" name="btnBorrachaDestinatarioNotaFiscal" src="img/borracha.gif" class="imagemLink" onclick="limparDestinatarioNotaFiscal();"/>
                    </td>
                </tr>
                <tr class="CelulaZebra2NoAlign" id="trNumeroRomaneioNF" style="display: none;">
                    <td align="right">
                        Número de Romaneio:
                    </td>
                    <td  align="left">
                        <input type="text" id="numeroRomaneioNF" name="numeroRomaneioNF" class="inputTexto" maxlength="30" size="12">
                    </td>
                </tr>
            </table>
            <table width="90%" align="center" class="bordaFina">
                <tr class="tabela" >
                    <td colspan="4">Informações da Importa&ccedil;&atilde;o</td>
                </tr>
                <tr id="trImportacao_Redespacho" name="trImportacao_Redespacho" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>
                            <input type="checkbox" id="chkAtribuirRedespacho" name="chkAtribuirRedespacho" value="true" onclick="javascript:mostrarLocalizaRedespacho();"/> 
                            Atribuir o redespacho para todos os CT-e(s)
                        </label>                                                    
                    </td>
                        <td width="50%" align="left">
                            <div id="divRedespachoLocaliza" style="display: none">
                                <input type="text" id="razaoSocialRedespacho" name="razaoSocialRedespacho" class="inputReadOnly" value="" size="40" readonly/>
                                <input type="hidden" id="idRedespacho" name="idRedespacho" value=""/>
                                <input type="button" id="btnlLocalizarRedespacho" name="btnlLocalizarRedespacho" class="inputBotao" value="..." onclick="tryRequestToServer(function(){abrirLocalizarRedespacho();});"/>
                                <img id="btnBorrachaRedespacho" name="btnBorrachaRedespacho" src="img/borracha.gif" class="imagemLink" onclick="limparRedespacho();"/>
                            </div>
                        </td>                    
                </tr>
                <tr id="trImportacao_Destinatario" name="trImportacao_Destinatario" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>
                            <input type="checkbox" id="chkAtribuirDestinatario" name="chkAtribuirDestinatario" value="true" onclick="javascript:mostrarLocalizaDestinatario();"/> 
                            Atribuir o destinatário para todos os CT-e(s)
                        </label>                                                    
                    </td>
                    <td width="50%" align="left">
                        <div id="divDestinatarioLocaliza" style="display: none">
                            <input type="text" id="razaoSocialDestinatario" name="razaoSocialDestinatario" class="inputReadOnly" value="" size="40" readonly/>
                            <input type="hidden" id="idDestinatario" name="idDestinatario" value=""/>
                            <input type="button" id="btnlLocalizarDestinatario" name="btnlLocalizarDestintario" class="inputBotao" value="..." onclick="tryRequestToServer(function(){abrirLocalizarDestinatario();});"/>
                            <img id="btnBorrachaDestinatario" name="btnBorrachaDestinatario" src="img/borracha.gif" class="imagemLink" onclick="limparDestinatario();"/>
                        </div>
                    </td>
                </tr>
                <tr id="trImportacao_Remetente" name="trImportacao_Remetente" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>
                            <input type="checkbox" id="chkAtribuirRemetente" name="chkAtribuirRemetente" value="true" onclick="javascript:mostrarLocalizaRemetente();"/> 
                            Atribuir o remetente para todos os CT-e(s)
                        </label>                                                    
                    </td>
                    <td width="50%" align="left">
                        <div id="divRemetenteLocaliza" style="display: none">
                            <input type="text" id="razaoSocialRemetente" name="razaoSocialRemetente" class="inputReadOnly" value="" size="40" readonly/>
                            <input type="hidden" id="idRemetente" name="idRemetente" value=""/>
                            <input type="button" id="btnlLocalizarRemetente" name="btnlLocalizarRemetente" class="inputBotao" value="..." onclick="tryRequestToServer(function(){abrirLocalizarRemetente();});"/>
                            <img id="btnBorrachaRemetente" name="btnBorrachaRemetente" src="img/borracha.gif" class="imagemLink" onclick="limparRemetente();"/>
                        </div>
                    </td>
                </tr>
                <tr id="trImportacao_Consignatario" name="trImportacao_Consignatario" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>
                            <input type="checkbox" id="chkAtribuirConsignatario" name="chkAtribuirConsignatario" value="true" onclick="javascript:mostrarLocalizaConsignatario();"/> 
                            Atribuir o consignatário para todos os CT-e(s)
                        </label>                                                    
                    </td>
                    <td width="50%" align="left">
                        <div id="divConsignatarioLocaliza" style="display: none">
                            <input type="text" id="razaoSocialConsignatario" name="razaoSocialConsignatario" class="inputReadOnly" value="" size="40" readonly/>
                            <input type="hidden" id="idConsignatario" name="idConsignatario" value=""/>
                            <input type="button" id="btnlLocalizarConsignatario" name="btnlLocalizarConsignatario" class="inputBotao" value="..." onclick="tryRequestToServer(function(){abrirLocalizarConsignatario();});"/>
                            <img id="btnBorrachaConsignatario" name="btnBorrachaConsignatario" src="img/borracha.gif" class="imagemLink" onclick="limparConsignatario();"/>                            
                        </div>
                    </td>
                </tr>
                <tr id="trImportacao_Representante" name="trImportacao_Representante" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>
                            <input type="checkbox" id="chkAtribuirRepresentante" name="chkAtribuirRepresentante" value="true" onclick="javascript:mostrarLocalizaRepresentante();"/> 
                            Atribuir o representante para todos os CT-e(s)
                        </label>                                                    
                    </td>
                    <td width="50%" align="left">
                        <div id="divRepresentanteLocaliza" style="display: none">
                            <input type="text" id="razaoSocialRepresentante" name="razaoSocialRepresentante" class="inputReadOnly" value="" size="40" readonly/>
                            <input type="hidden" id="idRepresentante" name="idRepresentante" value=""/>
                            <input type="button" id="btnlLocalizarRepresentante" name="btnlLocalizarRepresentante" class="inputBotao" value="..." onclick="tryRequestToServer(function(){abrirLocalizarRepresentante();});"/>
                            <img id="btnBorrachaRepresentante" name="btnBorrachaRepresentante" src="img/borracha.gif" class="imagemLink" onclick="limparRepresentante();"/>                            
                        </div>
                    </td>
                </tr>
                <tr id="trImportacao_Recebedor" name="trImportacao_Recebedor" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>
                            <input type="checkbox" id="chkAtribuirRecebedor" name="chkAtribuirRecebedor" value="true" onclick="javascript:mostrarLocalizaRecebedor();"/> 
                            Atribuir o recebedor para todos os CT-e(s)
                        </label>                                                    
                    </td>
                    <td width="50%" align="left">
                        <div id="divRecebedorLocaliza" style="display: none">
                            <input type="text" id="razaoSocialRecebedor" name="razaoSocialRecebedor" class="inputReadOnly" value="" size="40" readonly/>
                            <input type="hidden" id="idRecebedor" name="idRecebedor" value=""/>
                            <input type="button" id="btnlLocalizarRecebedor" name="btnlLocalizarRecebedor" class="inputBotao" value="..." onclick="tryRequestToServer(function(){abrirLocalizarRecebedor();});"/>
                            <img id="btnBorrachaRecebedor" name="btnBorrachaRecebedor" src="img/borracha.gif" class="imagemLink" onclick="limparRecebedor();"/>                            
                        </div>
                    </td>
                </tr>
                <tr id="trImportacao_Expedidor" name="trImportacao_Expedidor" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>
                            <input type="checkbox" id="chkAtribuirExpedidor" name="chkAtribuirExpedidor" value="true" onclick="javascript:mostrarLocalizaExpedidor();"/> 
                            Atribuir o Expedidor para todos os CT-e(s)
                        </label>                                                    
                    </td>
                    <td width="50%" align="left">
                        <div id="divExpedidorLocaliza" style="display: none">
                            <input type="text" id="razaoSocialExpedidor" name="razaoSocialExpedidor" class="inputReadOnly" value="" size="40" readonly/>
                            <input type="hidden" id="idExpedidor" name="idExpedidor" value=""/>
                            <input type="button" id="btnlLocalizarExpedidor" name="btnlLocalizarExpedidor" class="inputBotao" value="..." onclick="tryRequestToServer(function(){abrirLocalizarExpedidor();});"/>
                            <img id="btnBorrachaExpedidor" name="btnBorrachaExpedidor" src="img/borracha.gif" class="imagemLink" onclick="limparExpedidor();"/>                            
                        </div>
                    </td>
                </tr>
                <tr id="trImportacao_Responsavel" name="trImportacao_Responsavel" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>
                            <input type="checkbox" id="chkAtribuirResponsavel" name="chkAtribuirResponsavel" onclick="mostrarRadioResponsavel();">
                            Atribuir o responsável pelo pagamento
                        </label>
                    </td>
                    <td width="50%" align="left">
                        <div id="tdRadioResponsavel" style="display: none;">
                            <label>
                                <input type="radio" id="responsavelCIF" name="responsavel" value="0" checked>
                                CIF
                            </label>
                            <label>
                                <input type="radio" id="responsavelFOB" name="responsavel" value="1">
                                FOB
                            </label>
                            <label>
                                <input type="radio" id="responsavelTerceiro" name="responsavel" value="2">
                                Terceiro
                            </label>
                        </div>
                    </td>
                </tr>
                <tr id="trImportacao_ConsiderarFrete" name="trImportacao_ConsiderarFrete" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>                            
                            Ao importar considerar o valor do frete
                        </label>                                                    
                    </td>
                    <td width="50%" align="left">
                        <label>
                            <input type="radio" id="tabelaPreco" name="considerarFrete" value="t"/>
                            Cálculo da tabela de preço
                        </label>
                        <label>
                            <input type="radio" id="valorArquivo" name="considerarFrete" value="a"/>
                            Valor informado no arquivo
                        </label>
                    </td>
                </tr>
                <tr id="trImportacao_CalcularPrazoEntregaTabelaPreco" name="trImportacao_CalcularPrazoEntregaTabelaPreco" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>
                            Calcular o prazo de entrega pela tabela de preço?
                        </label>
                    </td>
                    <td width="50%" align="left">
                        <label>
                            <input type="radio" id="calcularPrazoEntregaTabelaPrecoSim" name="calcularPrazoEntregaTabelaPreco" value="s" checked>
                            Sim
                        </label>
                        <label>
                            <input type="radio" id="calcularPrazoEntregaTabelaPrecoNao" name="calcularPrazoEntregaTabelaPreco" value="n">
                            Não
                        </label>
                    </td>
                </tr>
                <tr id="trImportacao_NfRemetenteDestinatario" name="trImportacao_NfRemetenteDestinatario" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>                            
                            Caso existam notas fiscais para o mesmo remetente e destinatário, deseja agrupa-las no mesmo CT-e?
                        </label>                                                    
                    </td>
                    <td width="50%" align="left">
                        <label>
                            <input type="radio" id="nfRemetenteDestintarioSim" name="nfRemetenteDestintario" value="s" onclick="mostrarFiltroPedido()"/>
                            Sim
                        </label>
                        <label>
                            <input type="radio" id="nfRemetenteDestintarioNao" name="nfRemetenteDestintario" value="n" onclick="mostrarFiltroPedido()"/>
                            Não
                        </label>
                        <span id="spanAgruparNFeDataEmissao">
                            <input type="checkbox" id="agruparNFeDataEmissao" name="agruparNFeDataEmissao">
                            <label for="agruparNFeDataEmissao">Ao agrupar considerar as notas com a mesma data de emissão</label>
                        </span>
                    </td>
                </tr>
                <tr id="trImportacao_NfUfDestino" name="trImportacao_NfUfDestino" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>                            
                            Caso existam notas fiscais para a mesma UF de destino, deseja agrupa-las no mesmo CT-e?
                        </label>                                                    
                    </td>
                    <td width="50%" align="left">
                        <label>
                            <input type="radio" id="nfUfDestinoSim" name="nfUfDestino" value="s" onclick="validaRadioNF()"/>
                            Sim
                        </label>
                        <label>
                            <input type="radio" id="nfUfDestinoNao" name="nfUfDestino" value="n" onclick="validaRadioNF()"/>
                            Não
                        </label>
                    </td>
                </tr>
                <tr id="trImportacao_NfNumeroPedido" name="trImportacao_NfNumeroPedido" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>                            
                            Gerar um CT-e para cada número do pedido?
                        </label>                                                    
                    </td>
                    <td width="50%" align="left">
                        <label>
                            <input type="radio" id="numeroPedidoSim" name="numeroPedido" value="s"/>
                            Sim
                        </label>
                        <label>
                            <input type="radio" id="numeroPedidoNao" name="numeroPedido" value="n"/>
                            Não
                        </label>
                    </td>
                </tr>
                <tr id="trImportacao_gerarCTePorNumeroFRS" name="trImportacao_gerarCTePorNumeroFRS" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>                            
                            Gerar um CT-e para cada número da carga?
                        </label>                                                    
                    </td>
                    <td width="50%" align="left">
                        <label>
                            <input type="radio" id="gerarCTePorNumeroFRSSim" name="gerarCTePorNumeroFRS" value="s"/>
                            Sim
                        </label>
                        <label>
                            <input checked="true" type="radio" id="gerarCTePorNumeroFRSNao" name="gerarCTePorNumeroFRS" value="n"/>
                            Não
                        </label>
                    </td>
                </tr>
                <tr id="trImportacao_ClienteProduto" name="trImportacao_ClienteProduto" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>                            
                            Considerar o grupo de cliente no localizar produto?
                        </label>                                                    
                    </td>
                    <td width="50%" align="left">
                        <label>
                            <input type="radio" id="clienteProdutoSim" name="clienteProduto" value="s"/>
                            Sim
                        </label>
                        <label>
                            <input type="radio" id="clienteProdutoNao" name="clienteProduto" value="n"/>
                            Não
                        </label>
                    </td>
                </tr>
                <tr id="trImportacao_ImportarFilialSelecionada" name="trImportacao_ImportarFilialSelecionada" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>                            
                            Importar arquivo apenas da filial selecionada?
                        </label>                                                    
                    </td>
                    <td width="50%" align="left">
                        <label>
                            <input type="radio" id="filialSelecionadaSim" name="filialSelecionada" value="s"/>
                            Sim
                        </label>
                        <label>
                            <input type="radio" id="filialSelecionadaNao" name="filialSelecionada" value="n"/>
                            Não
                        </label>
                    </td>
                </tr>
                <tr id="trImportacao_UtilizarDadosVeiculo" name="trImportacao_UtilizarDadosVeiculo" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>                            
                            Utilizar os dados do veículo do XML?
                        </label>                                                    
                    </td>
                    <td width="50%" align="left">
                        <label>
                            <input type="radio" id="utilizarDadosVeiculoSim" name="utilizarDadosVeiculo" value="s"/>
                            Sim
                        </label>
                        <label>
                            <input type="radio" id="utilizarDadosVeiculoNao" name="utilizarDadosVeiculo" value="n"/>
                            Não
                        </label>
                    </td>
                </tr>
                <tr id="trImportacao_CadastrarMercadoria" name="trImportacao_CadastrarMercadoria" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>                            
                            Cadastrar mercadoria?
                        </label>                                                    
                    </td>
                    <td width="50%" align="left">
                        <label>
                            <input type="radio" id="cadastrarMercadoriaSim" name="cadastrarMercadoria" value="s"/>
                            Sim
                        </label>
                        <label>
                            <input type="radio" id="cadastrarMercadoriaNao" name="cadastrarMercadoria" value="n"/>
                            Não
                        </label>
                    </td>
                </tr>
                <tr id="trImportacao_ImportarItemNf" name="trImportacao_ImportarItemNf" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>                            
                            Importar os Itens da Nota?
                        </label>                                                    
                    </td>
                    <td width="50%" align="left">
                        <label>
                            <input type="radio" id="importarItemNfSim" name="importarItemNf" value="s"/>
                            Sim
                        </label>
                        <label>
                            <input type="radio" id="importarItemNfNao" name="importarItemNf" value="n"/>
                            Não
                        </label>
                    </td>
                </tr>
                <tr id="trImportacao_AgruparPorVeiculo" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>                            
                            Caso Exista Notas Fiscais para o mesmo veículo, deseja agrupa-las no mesmo CT-e? O destinatário do CT-e será o da primeira nota.
                        </label>                                                    
                    </td>
                    <td width="50%" align="left">
                        <label>
                            <input type="radio" id="agruparPorVeiculoSim" name="agruparPorVeiculo" value="s"/>
                            Sim
                        </label>
                        <label>
                            <input type="radio" id="agruparPorVeiculoNao" name="agruparPorVeiculo" value="n" checked/>
                            Não
                        </label>
                    </td>
                </tr>
                <tr id="trImportacao_AtualizarCadDestinatario" name="trImportacao_AtualizarCadDestinatario" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>                            
                            Atualizar o cadastro do destinatário ao importar o arquivo?
                        </label>                                                    
                    </td>
                    <td width="50%" align="left">
                        <label>
                            <input type="radio" id="atualizarCadDestinatarioSim" name="atualizarCadDestinatario" value="s" onclick="tryRequestToServer(function(){escondeMostraAtualizarDestinatario();});"/>
                            Sim
                        </label>
                        <label>
                            <input type="radio" id="atualizarCadDestinatarioNao" name="atualizarCadDestinatario" value="n" onclick="tryRequestToServer(function(){escondeMostraAtualizarDestinatario();});"/>
                            Não
                        </label>
                    </td>
                </tr>
                <tr id="trImportacao_AtualizarEndDesitinatario" name="trImportacao_AtualizarEndDesitinatario" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>                            
                            Atualizar o endereço do destinatário ao importar o arquivo?
                        </label>                                                    
                    </td>
                    <td width="50%" align="left">
                        <label>
                            <input type="radio" id="atualizarEndDestinatarioSim" name="atualizarEndDestinatario" value="s"/>
                            Atualizar
                        </label>
                        <label>
                            <input type="radio" id="atualizarEndDestinatarioNao" name="atualizarEndDestinatario" value="n"/>
                            Adicionar como um novo endereço de entrega
                        </label>
                    </td>
                </tr>
                <tr id="trImportacao_AtualizarCadRemetente" name="trImportacao_AtualizarCadRemetente" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>                            
                            Atualizar o cadastro do remetente ao importar o arquivo?
                        </label>                                                    
                    </td>
                    <td width="50%" align="left">
                        <label>
                            <input type="radio" id="atualizarCadRemetenteSim" name="atualizarCadRemetente" value="s"/>
                            Sim
                        </label>
                        <label>
                            <input type="radio" id="atualizarCadRemetenteNao" name="atualizarCadRemetente" value="n"/>
                            Não
                        </label>
                    </td>
                </tr>
                <tr id="trImportacao_subServico" name="trImportacao_subServico" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <label>                            
                           Serviço de Subcontratação ?
                        </label>                                                    
                    </td>
                    <td width="50%" align="left">
                        <label>
                            <input type="radio" id="inpSubContratacaoSim" name="inpSubContratacao" value="s"/>
                            Sim
                        </label>
                        <label>
                            <input type="radio" id="inpSubContratacaoNao" name="inpSubContratacao" value="n"/>
                            Não
                        </label>
                    </td>
                </tr>
                <tr id="trImportacao_UtilizarTabelaDestintarioRemetente" name="trImportacao_UtilizarTabelaDestintarioRemetente" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <div>
                            <label>                            
                                Ao cadastrar o destinatário:
                            </label>
                        </div>
                        <div>
                            <label>                            
                                Utilizar:
                            </label>
                        </div>
                    </td>
                    <td width="50%" align="left">
                        <div>
                            <label>
                                Tipo Tabela: 
                            </label>
                            <select name="tipoTabela" id="tipoTabela" class="inputTexto" style="width: 100px;" onchange="">
                                <option value="-1">-- Selecione --</option>
                                <option value="0">Peso/Kg</option>
                                <option value="1">Peso/Cubagem</option>
                                <option value="2">% Nota Fiscal</option>
                                <option value="3">Combinado</option>
                                <option value="4">Por volume</option>
                                <option value="5">Por Km</option>
                                <option value="6">Por Pallet</option>
                            </select>                            
                        </div>
                        <div>
                            <label>
                                Utilizar tabela do remetente
                            </label>
                            <select name="tabelaRemetente" id="tabelaRemetente" class="inputTexto" style="width: 100px;" onchange="">
                                <option value="n" selected>Nunca</option>
                                <option value="s">Sempre</option>
                            </select>                            
                            
                        </div>
                    </td>
                </tr>
                <tr id="trImportacao_BasePadraoCubagem" name="trImportacao_BasePadraoCubagem" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <div>
                            <label>
                                Base Padrão para Cubagem Rodoviário:
                            </label>
                        </div>
                    </td>
                    <td width="50%" align="left">
                        <div>
                            <input type="texte" id="inpBasePadraoCubagem" name="inpBasePadraoCubagem" class="inputReadOnly" maxlength="15" size="15" readonly=""/>
                        </div>
                    </td>
                </tr>
                <tr id="trImportacao_BasePadraoCubagemAereo" name="trImportacao_BasePadraoCubagemAereo" style="display: none" class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <div>
                            <label>
                                Base Padrão para Cubagem Aéreo:
                            </label>
                        </div>
                    </td>
                    <td width="50%" align="left">
                        <div>
                            <input type="texte" id="inpBasePadraoCubagemAereo" name="inpBasePadraoCubagemAereo" class="inputReadOnly" maxlength="15" size="15" readonly=""/>
                        </div>
                    </td>
                </tr>
                
                
                <tr id="trImportacao_ConsiderarVolume" name="trImportacao_ConsiderarVolume"  class="CelulaZebra2NoAlign" >
                     <td width="50%" align="right">
                        <div>
                            <label for="inpTag" >
                                Considerar o volume:
                            </label>
                        </div>
                    </td>
                    
                    <td width="50%" align="left">    
                        <table>
                            <tbody>
                                <tr>
                                    <td>
                                        <label>
                                            <input type="radio" id="inpTagTransportadora" name="inpTag" value="1"/>
                                            Da tag de transportadora
                                        </label>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <label>
                                            <input type="radio" id="inpTagZeroTransportadora" name="inpTag" value="2" checked />
                                             Se a tag transportadora vier zero então carregar a quantidade total dos produtos
                                        </label>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </td>
                    
                </tr>
                <tr id="trImportacao_TagsPersonalizadas" name="trImportacao_TagsPersonalizadas"
                    class="CelulaZebra2NoAlign">
                    <td width="50%" align="right">
                        <div>
                            <label>
                                Utilizar tags personalizadas na importação do XML:
                            </label>
                        </div>
                    </td>
                    <td width="50%" align="left">
                        <table>
                            <thead>
                            <tr class="tabela">
                                <td width="1%">
                                    <div align="center">
                                        <img src="${homePath}/img/add.gif" id="btnAdicionarTags" class="imagemLink">
                                        <input type="hidden" id="qtdDomTagsPersonalizadas" name="qtdDomTagsPersonalizadas" value="0">
                                    </div>
                                </td>
                                <td width="5%">Nome da TAG</td>
                                <td width="5%">Campo</td>
                            </tr>
                            </thead>
                            <tbody id="tbodyTagsPersonalizadas">
                            
                            </tbody>
                        </table>
                    </td>
                </tr>
                
            </table>
            <table width="90%" align="center" class="bordaFina">                
                <tr class="CelulaZebra2NoAlign" align="center">                                
                    <td width="100%"  >
                        <input name="btVisualizar" id="btVisualizar" type="button" class="botoes" onclick="tryRequestToServer(function(){anexar();});" value="Importar" />
                    </td>                                
                </tr>
            </table>
        </form>
    </body>
    <style>
        .block-tela{
            position: absolute;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            top: 0;
            left: 0;
            z-index: 99999;
            display: none;
        }
    </style>
    <div class="block-tela">
        
    </div>
</html>
