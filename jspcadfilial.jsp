<%@page import="usuario.BeanUsuario"%>
<%@page import="com.google.gson.JsonElement"%>
<%@page import="com.google.gson.JsonObject"%>
<%@page import="com.google.gson.JsonParser"%>
<%@page import="filial.FilialInscricaoEstadualSubstituta"%>
<%@page import="br.com.gwsistemas.gerenciadorrisco.GerenciadorRisco"%>
<%@page import="br.com.gwsistemas.gerenciadorrisco.GerenciadorRiscoBO"%>
<%@page import="filial.IntegracaoServico"%>
<%@page import="br.com.gwsistemas.agendamentoTarefas.beans.TarefaAgendadaBaixarXml"%>
<%@page import="br.com.gwsistemas.configuracao.email.EmailBO"%>
<%@page import="br.com.gwsistemas.configuracao.email.Email"%>
<%@page import="br.com.gwsistemas.contratodefrete.negociacao.NegociacaoAdiantamentoFreteBO"%>
<%@page import="filial.FilialImpostoFederal"%>
<%@page import="br.com.gwsistemas.tabela.Tabela"%>
<%@page import="br.com.gwsistemas.tabela.Coluna"%>
<%@page import="br.com.gwsistemas.cfe.repom.CodigoMovimentosRepom"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="nucleo.Consulta"%>
<%@page import="br.com.gwsistemas.contratodefrete.negociacao.NegociacaoAdiantamentoFrete"%>
<%@page import="filial.CidadesAtendidas"%>
<%@page import="cidade.BeanCidade"%>
<%@page import="br.com.gwsistemas.conhecimento.caixapostal.seguradora.CaixaPostalSeguradoraDAO"%>
<%@page import="java.util.ArrayList"%>
<%@page import="br.com.gwsistemas.conhecimento.caixapostal.seguradora.CaixaPostalSeguradora"%>
<%@page import="cliente.BeanTabelaCliente"%>
<%@page import="filial.FilialEnderecoSaidaBuonny"%>
<%@page import="filial.RateioCustoAdministrativo"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="java.util.List"%>
<%@page import="fornecedor.BeanConsultaFornecedor"%>
<%@page import="com.thoughtworks.xstream.XStream"%>
<%@page import="com.thoughtworks.xstream.io.json.JettisonMappedXmlDriver"%>
<%@page import="java.util.Collection"%>
<%@page import="filial.RecolhimentoIcms"%>
<%@page import="filial.indicadorEscrituracaoContabilSef"%>
<%@page import="filial.IndicadorExibilidadeEscrituracaoSef"%>
<%@ page contentType="text/html; charset=ISO-8859-1" language="java"
         import="java.sql.ResultSet,
         permissao.BeanPermissao,
         nucleo.Apoio,
         nucleo.impressora.*,
         filial.BeanCadFilial,
         filial.IndicadorDocumentoSef,
         filial.BeanFilial" errorPage="" %>
<%@ page import="br.com.gwsistemas.filial.FilialCnpjAutorizado" %>
<%@ page import="org.apache.commons.lang3.StringUtils" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<link REL="stylesheet" HREF="estilo.css" TYPE="text/css">
<%
    // privilégio de permissaVersão CT-e:o. Ex.: if (nivelUser == 4) <usuario pode excluir
    int nivelUser = Apoio.getUsuario(request).getAcesso("cadfilial");
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
    }
    //fim da MSA
%>
<%//ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de

    String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    boolean carregaFi = false;
    BeanPermissao perm = null;
    BeanCadFilial cadfi = null;
    BeanFilial fi = null;
    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
    RateioCustoAdministrativo rateioValorData = null;
    FilialEnderecoSaidaBuonny filialEndereco = null;
    Collection<CaixaPostalSeguradora> listaCaixaPostalSeguradora = new ArrayList<CaixaPostalSeguradora>();
    CaixaPostalSeguradoraDAO caixaPostalSeguradoraDAO = new CaixaPostalSeguradoraDAO();
    listaCaixaPostalSeguradora = caixaPostalSeguradoraDAO.mostrarTodos();
    BeanTabelaCliente tab = null;
    Collection<NegociacaoAdiantamentoFrete> negociacaoFilial = null;
    DecimalFormat df = new DecimalFormat("0.00"); 
    
    Tabela tabela = new Tabela("vcodigo_movimento_repom");
    tabela.makeColunasDesejadas(null);
    Collection<Coluna> colunas = tabela.getColunas();
    
    // start GerenciadorRisco
    List<GerenciadorRisco> gerenciadorRiscos;
    GerenciadorRiscoBO gerenciadorRiscoBO = null;
    try {
        gerenciadorRiscoBO = new GerenciadorRiscoBO();
        
        gerenciadorRiscos = gerenciadorRiscoBO.listar();
    } finally {
        gerenciadorRiscoBO = null;
    }
    // end GerenciadorRisco

    
    /* trecho retirado de configurações, para carregar os emails da base que são de FATURA! */
    Consulta filtro1 = new Consulta();
    StringBuilder sql1 = new StringBuilder();
    sql1.append(" and ce.is_fatura");
    filtro1.setFiltrosAdicionais(sql1);
    filtro1.setCampoConsulta(" ce.mail_usuario ");
    filtro1.setLimiteResultados(100);
    Collection<Email> emails = new ArrayList<Email>();
    Collection<Email> emailsFatura = new ArrayList<Email>();
    EmailBO emailbo = new EmailBO();
    emails = emailbo.listar(filtro1);
    for (Email email : emails) {
        if (email.getMailNomeRemetente() != null || !email.getMailNomeRemetente().equals("")) {
            emailsFatura.add(email);
        }
    }
    request.setAttribute("emailsFatura", emailsFatura);
    
    //instrucoes incomuns entre as acoes
    if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar") || acao.equals("removeImposto")) {    //instanciando o bean de cadastro
        cadfi = new BeanCadFilial();
        cadfi.setExecutor(Apoio.getUsuario(request));
        cadfi.setConexao(Apoio.getUsuario(request).getConexao());
    }
    //executando a acao desejada
    if ((acao.equals("editar")) && (request.getParameter("id") != null)) {// ESSE ID VEM DO CONTROLADOR
        int idfilial = Apoio.parseInt(request.getParameter("id"));// ESSE ID VEM DO CONTROLADOR
        cadfi.getFilial().setIdfilial(idfilial);
        //carregando a filial por completo(atributos, permissoes)
        cadfi.LoadAllPropertys();
        fi = cadfi.getFilial();
        request.setAttribute("integracoes", fi.getIntegracao());
        request.setAttribute("substitutas", fi.getIesSubstitutas());
        request.setAttribute("filial", fi);
        request.setAttribute("diasTrava", (fi.getTravaDiasManifesto() > 0 ?fi.getTravaDiasManifesto() : "" ));
    } else if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir"))) {
        //populando o JavaBean
        cadfi.getFilial().setRazaosocial(URLDecoder.decode(request.getParameter("rzs")));
//        cadfi.getFilial().setAbreviatura(URLDecoder.decode(request.getParameter("abrev")));
        cadfi.getFilial().setAbreviatura(request.getParameter("abrev"));
        cadfi.getFilial().setBairro(request.getParameter("bairro"));
        cadfi.getFilial().getCidade().setIdcidade(Apoio.parseInt(request.getParameter("idcidadeorigemFilial")));
        cadfi.getFilial().getCidade().setDescricaoCidade(request.getParameter("cid_origemFilial"));
        cadfi.getFilial().setEndereco(request.getParameter("en"));
        cadfi.getFilial().setNumero(request.getParameter("numero"));
        cadfi.getFilial().setResponsavel(request.getParameter("responsavel"));
        cadfi.getFilial().setCep(request.getParameter("cep"));
        cadfi.getFilial().getCidade().setUf(request.getParameter("uf_origemFilial"));
        cadfi.getFilial().setFone(request.getParameter("fone"));
        cadfi.getFilial().setCnpj(request.getParameter("cnpj"));
        cadfi.getFilial().setCaminhoImpressora(request.getParameter("caminho_impressora"));
        cadfi.getFilial().setDriverPadraoImpressora(request.getParameter("driverPadraoImpressora"));
        cadfi.getFilial().setCodigoFilial(request.getParameter("codigofilial"));
        cadfi.getFilial().setRetencaoImpostoOperadoraCFe(Apoio.parseBoolean(request.getParameter("isRetencaoImpostoOperadoraCFe")));
        cadfi.getFilial().setInscest(request.getParameter("inscest"));
        cadfi.getFilial().setInscmun(request.getParameter("inscmun"));
        cadfi.getFilial().setNomeContador(request.getParameter("nome_contador"));
        cadfi.getFilial().setCpfContador(request.getParameter("cpf_contador"));
        cadfi.getFilial().setCrcContador(request.getParameter("crc_contador"));
        cadfi.getFilial().setFone1Contador(request.getParameter("fone1_contador"));
        cadfi.getFilial().setFone2Contador(request.getParameter("fone2_contador"));
        cadfi.getFilial().setFaxContador(request.getParameter("fax_contador"));
        cadfi.getFilial().setCxPostalContador(request.getParameter("cxpostal_contador"));
        cadfi.getFilial().setEmailContador(request.getParameter("email_contador"));
        cadfi.getFilial().setCepContador(request.getParameter("cep_contador"));
        cadfi.getFilial().setLogradouroContador(request.getParameter("logradouro_contador"));
        cadfi.getFilial().setNumLogradouroContador(request.getParameter("num_logradouro_contador"));
        cadfi.getFilial().setComplementoLogradouroContador(request.getParameter("complemento_logradouro_contador"));
        cadfi.getFilial().setBairroContador(request.getParameter("bairro_contador"));
        cadfi.getFilial().getCidadeContador().setIdcidade(Apoio.parseInt(request.getParameter("idcidadecontador")));
        cadfi.getFilial().getCidadeContador().setDescricaoCidade(request.getParameter("cidadeContador"));
        cadfi.getFilial().getCidadeContador().setUf(request.getParameter("ufContador"));
        cadfi.getFilial().setFoneResponsavel(request.getParameter("fone_responsavel"));
        cadfi.getFilial().setEmailResponsavel(request.getParameter("email_responsavel"));
        cadfi.getFilial().setCpfResponsavel(request.getParameter("cpf_responsavel"));
        cadfi.getFilial().setDeduzirPedagioIcms(Apoio.parseBoolean(request.getParameter("deduzirPedagio")));
        
        cadfi.getFilial().setAtivaDivisaoIcms(Apoio.parseBoolean(request.getParameter("enviarIcms")));
        cadfi.getFilial().setAtivaCombatePobreza(Apoio.parseBoolean(request.getParameter("envioPercentual")));
        
        cadfi.getFilial().getEmailFaturaFilial().setId(Apoio.parseInt(request.getParameter("emailFaturaFilial")));
        
        cadfi.getFilial().setGeraSequenciaCtrcManifesto(Apoio.parseBoolean(request.getParameter("geraSequenciaCtrc")));
        cadfi.getFilial().setSequenciaCtMultiModal(Apoio.parseBoolean(request.getParameter("sequenciaMultiModal")));
        cadfi.getFilial().setControlaSequenciaSelo(Apoio.parseBoolean(request.getParameter("sequenciaSeloCT")));
        cadfi.getFilial().setImprimirMaisEtiquetas(Apoio.parseBoolean(request.getParameter("imprMais1")));//Imprimir mais 1 etiqueta alem da quantidade normal, sejá por CTRC ou NF    
        cadfi.getFilial().setStUtilizacaoCte(request.getParameter("stUtilizacaoCte").charAt(0));
        cadfi.getFilial().setStUtilizacaoCfe(request.getParameter("stUtilizacaoCfe").charAt(0));
        cadfi.getFilial().setStUtilizacaoCle(request.getParameter("stUtilizacaoCle").charAt(0));
        cadfi.getFilial().setModalCTE(request.getParameter("modalConhecimento"));
        cadfi.getFilial().setNaturezaOperacao(Apoio.parseInt(request.getParameter("naturezaOperacao")));
        cadfi.getFilial().setRegimeEspecialTributacao(Apoio.parseInt(request.getParameter("regimeEspecialTributacao")));
        //********************************* SEF *************************
        cadfi.getFilial().getIndArq().setId(Apoio.parseInt(request.getParameter("indArq")));
        cadfi.getFilial().getPrfIss().setId(Apoio.parseInt(request.getParameter("prfIss")));
        cadfi.getFilial().getPrfICMS().setId(Apoio.parseInt(request.getParameter("prfIcms")));
        cadfi.getFilial().getIndEc().setId(Apoio.parseInt(request.getParameter("indEc")));        
        cadfi.getFilial().setPrfRidf(Apoio.parseBoolean(request.getParameter("prfRidf")));
        cadfi.getFilial().setPrfRudf(Apoio.parseBoolean(request.getParameter("prfRudf")));
        cadfi.getFilial().setPrfLmf(Apoio.parseBoolean(request.getParameter("prfLmf")));
        cadfi.getFilial().setPrfRv(Apoio.parseBoolean(request.getParameter("prfRv")));
        cadfi.getFilial().setPrfRi(Apoio.parseBoolean(request.getParameter("prfRi")));
        cadfi.getFilial().setIndIss(Apoio.parseBoolean(request.getParameter("indIss")));
        cadfi.getFilial().setIndRt(Apoio.parseBoolean(request.getParameter("indRt")));
        cadfi.getFilial().setIndIcms(Apoio.parseBoolean(request.getParameter("indIcms")));
        cadfi.getFilial().setIndSt(Apoio.parseBoolean(request.getParameter("indSt")));
        cadfi.getFilial().setIndAt(Apoio.parseBoolean(request.getParameter("indAt")));
        cadfi.getFilial().setIndIpi(Apoio.parseBoolean(request.getParameter("indIpi")));
        cadfi.getFilial().setIndRi(Apoio.parseBoolean(request.getParameter("indRi")));
        cadfi.getFilial().setIsAtivarHoraVerao(Apoio.parseBoolean(request.getParameter("isAtivarHoraVerao")));
        
        cadfi.getFilial().setModeloDacte(request.getParameter("modeloDacte"));
        
        cadfi.getFilial().getCodRecolhimentoIcms().setId(Apoio.parseInt(request.getParameter("cod_recolhimento")));
        cadfi.getFilial().setPerfilEFD(request.getParameter("perfilEFD"));
        cadfi.getFilial().setCodAgregacaoEntrada(request.getParameter("codAgregacaoEntrada"));
        cadfi.getFilial().setCodAgregacaoSaida(request.getParameter("codAgregacaoSaida"));
        cadfi.getFilial().setTipoCarga(request.getParameter("tipo-carga"));
        
        IntegracaoServico servicos = null;
        
        servicos = new IntegracaoServico();
        servicos.setId(Apoio.parseInt(request.getParameter("idFreteFacil")));
        servicos.setToken(request.getParameter("tokenEnvioFreteFacil"));
        servicos.setIsEnvioAutomatico(Apoio.parseBoolean(request.getParameter("isEnvioAutomaticoFreteFacil")));
        servicos.setTipoServico(1);
        servicos.setAmbiente(Apoio.parseInt(request.getParameter("tipoAmbienteFreteFacil")));
        cadfi.getFilial().getIntegracao().add(servicos);
        
        String status = request.getParameter("stUtilizacaoNfse");
        if (status.equalsIgnoreCase("H")) {
            cadfi.getFilial().setStUtilizacaoNfse('M');
            cadfi.getFilial().setHomologacaoNFSe(true);
        } else if (status.equalsIgnoreCase("P")) {
            cadfi.getFilial().setStUtilizacaoNfse('M');
            cadfi.getFilial().setHomologacaoNFSe(false);
        } else {
            cadfi.getFilial().setStUtilizacaoNfse('S');
            cadfi.getFilial().setHomologacaoNFSe(true);
        }

        cadfi.getFilial().setItauSegurosNumeroApolice(request.getParameter("itauSegurosNumeroApolice"));
        cadfi.getFilial().setItauSegurosSubGrupo(request.getParameter("itauSegurosSubGrupo"));
        cadfi.getFilial().setItauSegurosAverbarRCF(Apoio.parseBoolean(request.getParameter("itauSegurosAverbarRCF")));
        cadfi.getFilial().setItauSegurosAverbarTRN(Apoio.parseBoolean(request.getParameter("itauSegurosAverbarTRN")));
        cadfi.getFilial().setSite(request.getParameter("site"));
        cadfi.getFilial().setNumeroRntrc(Apoio.parseLong(request.getParameter("numero_rntrc")));       
        cadfi.getFilial().setIdPermissoes(request.getParameter("permissaoCK").split(","));
        cadfi.getFilial().getAgentePagadorRepom().setIdfornecedor(Apoio.parseInt(request.getParameter("idagente")));
        cadfi.getFilial().setCnpjContratantePamcard(request.getParameter("cnpjContratante"));
        cadfi.getFilial().setCnpjContratanteGwMobile(request.getParameter("cnpjContratanteGwMobile"));
        cadfi.getFilial().setHomologacaoCfe(Apoio.parseBoolean(request.getParameter("isHomologacaoCfe")));
       
        cadfi.getFilial().setCalcularPedagioCfe(Apoio.parseBoolean(request.getParameter("isCalcularPedagioCfe")));
       // cadfi.getFilial().getContaPamcard().setIdConta(Apoio.parseInt(request.getParameter("contaPamcardId")));
       // cadfi.getFilial().getContaNdd().setIdConta(Apoio.parseInt(request.getParameter("contaNddId")));
      //  cadfi.getFilial().getContaTicketFrete().setIdConta(Apoio.parseInt(request.getParameter("contaTicketFreteId")));
      //  cadfi.getFilial().getContaRepom().setIdConta(Apoio.parseInt(request.getParameter("contaRepomId")));
        cadfi.getFilial().setUtilizarCertificadoA1Pamcard(Apoio.parseBoolean(request.getParameter("utilizarCertificadoA1")));

        cadfi.getFilial().getCnae().setId(Apoio.parseInt(request.getParameter("cnae_id")));
        cadfi.getFilial().getCnae().setCod_cnae(request.getParameter("cod_cnae"));
        cadfi.getFilial().getCnae().setDescricao(request.getParameter("descricao_cnae"));
        String cpfCnpjConfirmadorNdd = request.getParameter("cnpj_confirmador_ndd");
        cpfCnpjConfirmadorNdd = cpfCnpjConfirmadorNdd.replace("/", "");
        cpfCnpjConfirmadorNdd = cpfCnpjConfirmadorNdd.replace("--", "");
        cpfCnpjConfirmadorNdd = cpfCnpjConfirmadorNdd.replace("-", "");
        cpfCnpjConfirmadorNdd = cpfCnpjConfirmadorNdd.replace(".", "");
        cadfi.getFilial().setSpedInformarValoresAgregados(Apoio.parseBoolean(request.getParameter("agregarValoresSPED")));
//        cadfi.getFilial().setLoginAverbacao(request.getParameter("login_averbacao"));
//        cadfi.getFilial().setSenhaAverbacao(request.getParameter("senha_averbacao"));
//        cadfi.getFilial().setCodigoAtemApisul(request.getParameter("codigo_atm"));
       
        cadfi.getFilial().setTransmitirCteServidorSeguradora(Apoio.parseBoolean(request.getParameter("transmitirSeguradora")));
        cadfi.getFilial().setTipoUtilizacaoApisul(request.getParameter("tipo_utilizacao_apisul"));
 //       cadfi.getFilial().setSeguradora(request.getParameter("seguradoraAverbacao"));
        cadfi.getFilial().setTransmitirAutomaticamenteConfirmarCte(Apoio.parseBoolean(request.getParameter("transmitirAuto")));
        cadfi.getFilial().setStUtilizacaoMDFe(request.getParameter("stUtilizacaoMDFe").charAt(0));
        
        cadfi.getFilial().getSeguradoraDdr().setIdfornecedor(Apoio.parseInt(request.getParameter("seguradora")));
        
        cadfi.getFilial().setAverbarNormal(Apoio.parseBoolean(request.getParameter("averbarNormal")));
        cadfi.getFilial().setAverbarDistLocal(Apoio.parseBoolean(request.getParameter("averbarDistLocal")));
        cadfi.getFilial().setAverbarDiarias(Apoio.parseBoolean(request.getParameter("averbarDiarias")));
        cadfi.getFilial().setAverbarPallets(Apoio.parseBoolean(request.getParameter("averbarPallets")));
        cadfi.getFilial().setAverbarComplementar(Apoio.parseBoolean(request.getParameter("averbarComplementar")));
        cadfi.getFilial().setAverbarReentrega(Apoio.parseBoolean(request.getParameter("averbarReentrega")));
        cadfi.getFilial().setAverbarDevolucao(Apoio.parseBoolean(request.getParameter("averbarDevolucao")));
        cadfi.getFilial().setAverbarCortesia(Apoio.parseBoolean(request.getParameter("averbarCortesia")));
        cadfi.getFilial().setAverbarSubstituicao(Apoio.parseBoolean(request.getParameter("averbarSubstituicao")));
        cadfi.getFilial().setImprimirEtiquetaPaginacao(request.getParameter("imprimirEtiquetaPaginacao"));
        cadfi.getFilial().setVersaoUtilizacaoCte(request.getParameter("versaoCTE"));
        cadfi.getFilial().setRateioComercial(Apoio.parseDouble(request.getParameter("rateioComercial")));
        cadfi.getFilial().setRateioAdministrativo(Apoio.parseDouble(request.getParameter("rateioAdministrativo")));
        cadfi.getFilial().setValorKiloIdeal(Apoio.parseDouble(request.getParameter("valorKiloIdeal")));
        
        cadfi.getFilial().setAddEFDContribuicaoPrevidenciaria(Apoio.parseBoolean(request.getParameter("isAddEFDContribuicaoPrevidenciaria")));
        cadfi.getFilial().setEFDCodAtividadeContribuicaoPrevidenciaria(request.getParameter("efdCodAtividadeContribuicaoPrevidenciaria"));
        
        if(Apoio.parseBoolean(request.getParameter("isContingenciaFSDA"))){
            cadfi.getFilial().setContingenciaFsda(Apoio.parseBoolean(request.getParameter("isContingenciaFSDA")));
            cadfi.getFilial().setJustificativaFsda(request.getParameter("justificativaFSDA"));
            cadfi.getFilial().setDataFsda(Apoio.paraDate(request.getParameter("dataFSDA")));
            cadfi.getFilial().setHoraFsda((request.getParameter("horaFSDA")));
        }else{
            cadfi.getFilial().setJustificativaFsda("");
            cadfi.getFilial().setContingenciaFsda(false);
            cadfi.getFilial().setDataFsda(Apoio.getFormatData(Apoio.getDataAtual()));
            cadfi.getFilial().setHoraFsda(Apoio.getHoraAtual());
           
        }
        
        cadfi.getFilial().setCriarParcelaValorDescarga(Apoio.parseBoolean(request.getParameter("criarParcelaValorDescarga")));
      
        cadfi.getFilial().setCpfCnpjConfirmadorNdd(cpfCnpjConfirmadorNdd);
        cadfi.getFilial().setTipoEfetivacao(Apoio.parseInt(request.getParameter("Selectconfirmador")));
        // novo campo - 02-04-2014
        cadfi.getFilial().setEmailRecebimentoPreAlerta(request.getParameter("emailRecebimentoPreAlerta"));
       
        cadfi.getFilial().setStUtilizacaoBuonnyRoteirizador(request.getParameter("idStUtilizacaoBuonnyRoteirizador").charAt(0));
        
        cadfi.getFilial().setUtilizacaoNFSeG2ka(Apoio.parseBoolean(request.getParameter("utilizacaoNFSeG2ka")));
        cadfi.getFilial().setHoraCancelamentoCte(Apoio.parseBoolean(request.getParameter("horaCancelamentoCte")));
        
        cadfi.getFilial().setValidaIpNFSeG2ka(Apoio.parseBoolean(request.getParameter("chkValidaIpNFSeG2ka")));
        
        cadfi.getFilial().setSeriePadraoCTeAereo(request.getParameter("seriePadraoCTeAereo"));
        cadfi.getFilial().setSeriePadraoCTeAquaviario(request.getParameter("seriePadraoCTeAquaviario"));
        cadfi.getFilial().setSeriePadraoCTeRodoviario(request.getParameter("seriePadraoCTeRodoviario"));        
        
        cadfi.getFilial().getUtilizaFilialFreteAvistaCTe().setIdfilial(Apoio.parseInt(request.getParameter("idfilialFreteAvista")));     
        
        cadfi.getFilial().setOpcaoGerarCIOTTacAgregado(Apoio.parseBoolean(request.getParameter("gerarOpcaoCIOTTacAgregado")));
        
        cadfi.getFilial().setConfirmarPagamentoNDD(Apoio.parseBoolean(request.getParameter("confirmarPagamentoNDD")));        
       
        //25/02/2015
        cadfi.getFilial().setSalarioValorRateio(request.getParameter("idDefinicaoSalarioMotoristaVeiculo").charAt(0));
       
        cadfi.getFilial().setIncentivadorCultural(Apoio.parseBoolean(request.getParameter("incentivadorCultural")));
        
        cadfi.getFilial().setDataInicialAverbacao(Apoio.paraDate(request.getParameter("dataAverb")));        
        
        cadfi.getFilial().getCaixaPostalSeguradoraRodoviario().setId(Apoio.parseInt(request.getParameter("seguradoraRodoviario")));
        cadfi.getFilial().getCaixaPostalSeguradoraAereo().setId(Apoio.parseInt(request.getParameter("seguradoraAereo")));
        cadfi.getFilial().getCaixaPostalSeguradoraAquaviario().setId(Apoio.parseInt(request.getParameter("seguradoraAquaviario")));
        
        cadfi.getFilial().getCaixaPostalSeguradoraNFSe().setId(Apoio.parseInt(request.getParameter("seguradoraNFSe"))); 
        cadfi.getFilial().setTipoUtilizacaoAverbacaoNFSe(request.getParameter("tipoUtilizacaoAverbacaoNFSe"));
        cadfi.getFilial().setTransmitirAutomaticamenteConfirmarNfse(Apoio.parseBoolean(request.getParameter("transmitirAutoNfse")));  
        
        cadfi.getFilial().setEmissaoGratuita(Apoio.parseBoolean(request.getParameter("emissaoGratuita")));
        cadfi.getFilial().setPermitirCiotContratadosSemTacEquiparados(Apoio.parseBoolean(request.getParameter("permitirCiotContratadosSemTacEquiparados")));
        cadfi.getFilial().setChaveAcessoIntegracao(request.getParameter("chaveAcessoInteg"));
        cadfi.getFilial().setQtdDiasQuitSaldo(Apoio.parseInt(request.getParameter("qtdDiasQuitSaldo")));
        cadfi.getFilial().setSolicitarConferenciaDocumentoCiot(Apoio.parseBoolean(request.getParameter("solicitarConferenciaDocumentoCiot")));
        cadfi.getFilial().setObrigaSequenciaCte(Apoio.parseBoolean(request.getParameter("obrigaSequenciaCte")));
        cadfi.getFilial().setOrcamentoOutrasFilias(Apoio.parseBoolean(request.getParameter("isOrcamentoOutrasFilias")));
               
        cadfi.getFilial().setCodigoIntegracaoCfe(request.getParameter("codigoIntegracaoCfe"));
        int maxAliquotas = Apoio.parseInt(request.getParameter("maxAliquotaImpostoFederal"));
        FilialImpostoFederal impostos = null;
        for(int i = 0; i < maxAliquotas; i++){
            if (request.getParameter("competencia_"+i) != null && (!request.getParameter("competencia_"+i).trim().equals("")) ) {
                impostos = new FilialImpostoFederal();
                impostos.setId(Apoio.parseInt(request.getParameter("id_"+i)));
                impostos.setCompetencia(request.getParameter("competencia_"+i));
                impostos.setPercCOFINS(Apoio.parseDouble(request.getParameter("cofins_"+i)));
                impostos.setPercINSS(Apoio.parseDouble(request.getParameter("inss_"+i)));
                impostos.setPercIR(Apoio.parseDouble(request.getParameter("ir_"+i)));
                impostos.setPercPIS(Apoio.parseDouble(request.getParameter("pis_"+i)));
                impostos.setPercCSSL(Apoio.parseDouble(request.getParameter("cssl_"+i)));
                cadfi.getFilial().getImpostosFederais().add(impostos);   
            }
        }
        cadfi.getFilial().setTipoTributacao(request.getParameter("tipoTributacao"));
        
        String cnpjMatriz = (request.getParameter("cnpjMatriz")!=null?  request.getParameter("cnpjMatriz"): "");
        if(!cnpjMatriz.equals("")){
            cnpjMatriz = cnpjMatriz.replace(".", "");
            cnpjMatriz = cnpjMatriz.replace("/", "");
            cnpjMatriz = cnpjMatriz.replace("-", "");
        }      
        cadfi.getFilial().setCnpjMatriz(cnpjMatriz);
        cadfi.getFilial().getContaCfe().setIdConta(Apoio.parseInt(request.getParameter("contaCfeId")));
        
        cadfi.getFilial().setLoginPagBem(request.getParameter("loginPagBem"));
        cadfi.getFilial().setSenhaPagBem(request.getParameter("senhaPagBem"));
        
        cadfi.getFilial().setViagemLiberadaCFe(Apoio.parseBoolean(request.getParameter("viagemLiberada")));
        
        //Add no Campo do DOM valor de custo e data de partida 20/02/2015
        int maxValorDivido = Apoio.parseInt(request.getParameter("maxValorDivido"));       
            for (int i = 0; i <= maxValorDivido; i++){
                if(request.getParameter("valorDividido_" + i) != null) {
                    rateioValorData = new RateioCustoAdministrativo();
                    rateioValorData.setIdValorData(Apoio.parseInt(request.getParameter("idRateio_" + i)));
                    rateioValorData.setValorCustoRateio(Apoio.parseDouble(request.getParameter("valorDividido_" + i)));
                    rateioValorData.setDataPartidaRateio(Apoio.paraDate(request.getParameter("dataValorDivido_" + i)));                 
                    
                    cadfi.getFilial().getRateioCustoAdminitrativo().add(rateioValorData);                   
                    
             }
         }       

        if (acao.equals("atualizar")) {
            cadfi.getFilial().setIdfilial(Apoio.parseInt(request.getParameter("idfilialAtual")));
        }        
        
        int maxEnderecos = Apoio.parseInt(request.getParameter("maxEnderecos"));
            for(int i = 0; i <= maxEnderecos; i++){
            if(request.getParameter("descricaoLogradouroCidadeBuonny_"+i) != null){
                
                filialEndereco = new FilialEnderecoSaidaBuonny();
                filialEndereco.setId(Apoio.parseInt(request.getParameter("idEnderecoFilialSaidaBuonny_"+i)));
                filialEndereco.getFilial().setIdfilial(Apoio.parseInt(request.getParameter("idfilialAtual"))); 
                filialEndereco.getEndereco().setId(Apoio.parseInt(request.getParameter("idEndereco_"+i)));
                filialEndereco.getEndereco().setLograoduro(request.getParameter("descricaoLogradouroCidadeBuonny_" +i)); 
                filialEndereco.getEndereco().setCep(request.getParameter("numeroCepCidadeBuonny_" +i));
                filialEndereco.getEndereco().setBairro(request.getParameter("descricaoBairroCidadeBuonny_" +i));
                filialEndereco.getEndereco().setNumeroLogradouro(request.getParameter("numeroLogradouroCidadeBuonny_" +i));
                filialEndereco.getEndereco().getCidade().setIdcidade(Apoio.parseInt(request.getParameter("idCidadeBuonny_"+i)));                
                
                cadfi.getFilial().getFilialEnderecoSaidaBuonny().add(filialEndereco);
            }
        }
            
        cadfi.getFilial().setTipoVeiculoKm(request.getParameter("veiculoKm").charAt(0));
        cadfi.getFilial().setTokenGwMobile(request.getParameter("tokenGwMobile"));
        cadfi.getFilial().setTipoUtilizacaoGWMobile(request.getParameter("tipoUtilizacaoGWMobile"));
        cadfi.getFilial().setSerieMdfe(request.getParameter("serieMdfe"));
        // recebendo Valor para Natureza
        cadfi.getFilial().getNaturezaCargaContratoFrete().setCodigo(request.getParameter("natureza_cod"));
        //controlarTarifasBancarias qtdSaques valorPorSaques  qtdTransf valorTransf
        
        cadfi.getFilial().setControlarTarifasBancariasContratado(Apoio.parseBoolean(request.getParameter("controlarTarifasBancarias")));
        cadfi.getFilial().setQuantidadeSaquesContratoFrete(Apoio.parseInt(request.getParameter("qtdSaques")));
        cadfi.getFilial().setValorSaquesContratoFrete(Apoio.parseDouble(request.getParameter("valorPorSaques")));
        cadfi.getFilial().setQuantidadeTransferenciasContratoFrete(Apoio.parseInt(request.getParameter("qtdTransf")));
        cadfi.getFilial().setValorTransferenciasContratoFrete(Apoio.parseDouble(request.getParameter("valorTransf")));
       
        cadfi.getFilial().setIsAtivaControleValorManifesto(Apoio.parseBoolean(request.getParameter("controleValor")));
        cadfi.getFilial().setValorMaximo(Apoio.parseDouble(request.getParameter("valorMaximo")));
        cadfi.getFilial().setNegociadaoAdiantamentoId(Apoio.parseInt(request.getParameter("negociacaoAdiantamento")));
        cadfi.getFilial().setAtivarICMSGoias(Apoio.parseBoolean(request.getParameter("isICMSufGO")));
        cadfi.getFilial().setValorCotacaoDolar(Apoio.parseDouble(request.getParameter("cotacaoDolar")));
        cadfi.getFilial().setCotacaoDolarEm(Apoio.paraDate(request.getParameter("cotacaoDolarEm")));
        cadfi.getFilial().setVersaoUtilizacaoMdfe(request.getParameter("versaoMDFe"));
        cadfi.getFilial().setMostrarFreteCifEmitidoPropriaFilialFobs(Apoio.parseBoolean(request.getParameter("isMostrarFreteCifEmitidoPropriaFilialFobs")));
        
        cadfi.getFilial().setMostrarFreteCifEmitidoPropriaFilialFobs(Apoio.parseBoolean(request.getParameter("isMostrarFreteCifEmitidoPropriaFilialFobs")));
        cadfi.getFilial().setUltimoNSUCTE(Apoio.parseInt(request.getParameter("ultimoNsuCte")));
        cadfi.getFilial().setUltimoNSUNFE(Apoio.parseInt(request.getParameter("ultimoNsuNfe")));
        cadfi.getFilial().setUf(request.getParameter("uf_origemFilial"));
        if(Apoio.parseInt(request.getParameter("maxCronCte")) >0){
            TarefaAgendadaBaixarXml tarefaBaixaXml = null;
            for(int c = 1; c <= Apoio.parseInt(request.getParameter("maxCronCte")); c++ ){
                if(request.getParameter("cron_cte_"+c) != null){
                    tarefaBaixaXml = new TarefaAgendadaBaixarXml();
                    tarefaBaixaXml.setTipoXml("C");
                    tarefaBaixaXml.setCronExpression(request.getParameter("cron_cte_"+c));
                    tarefaBaixaXml.setId(Apoio.parseInt(request.getParameter("idCron_cte_"+c)));
                    tarefaBaixaXml.setDeletarTarefa(Apoio.parseBoolean(request.getParameter("removerCron_cte_"+c)));
                    tarefaBaixaXml.setIdFilial(Apoio.parseInt(request.getParameter("idfilialAtual")));
                    tarefaBaixaXml.setFilial(cadfi.getFilial());
                    tarefaBaixaXml.getFilial().setCaminhoCertificado(request.getParameter("caminho_certificado"));
                    tarefaBaixaXml.getFilial().setSenhaCertificado(request.getParameter("senha_certificado"));
                    cadfi.getFilial().getTarefabaixarXml().add(tarefaBaixaXml);
                } else if(request.getParameter("cron_nfe_"+c) != null){
                    tarefaBaixaXml = new TarefaAgendadaBaixarXml();
                    tarefaBaixaXml.setTipoXml("N");
                    tarefaBaixaXml.setCronExpression(request.getParameter("cron_nfe_"+c));
                    tarefaBaixaXml.setId(Apoio.parseInt(request.getParameter("idCron_nfe_"+c)));
                    tarefaBaixaXml.setDeletarTarefa(Apoio.parseBoolean(request.getParameter("removerCron_nfe_"+c)));
                    tarefaBaixaXml.setIdFilial(Apoio.parseInt(request.getParameter("idfilialAtual")));
                    tarefaBaixaXml.setFilial(cadfi.getFilial());
                    tarefaBaixaXml.getFilial().setCaminhoCertificado(request.getParameter("caminho_certificado"));
                    tarefaBaixaXml.getFilial().setSenhaCertificado(request.getParameter("senha_certificado"));
                    cadfi.getFilial().getTarefabaixarXml().add(tarefaBaixaXml);
                }
            }
        }
       
       
        //for adiciona a quantidade de cidades ao cadastrar id do DOM e cidade.
        CidadesAtendidas cidade = null;
        int maxCidades = Apoio.parseInt(request.getParameter("maxCidades"));
            for(int qtdCidade = 1; qtdCidade <= maxCidades; qtdCidade++){
                if(request.getParameter("idFilialCidadeAtendida_"+ qtdCidade) != null){
                    cidade = new CidadesAtendidas();
                    cidade.setId(Apoio.parseInt(request.getParameter("idFilialCidadeAtendida_"+qtdCidade)));
                    cidade.getCidade().setIdcidade(Apoio.parseInt(request.getParameter("idCidade_"+qtdCidade)));
                    cadfi.getFilial().getCidadesAtendidas().add(cidade);                
                }
            }
        
        cadfi.getFilial().setCidadeAtendidas(Apoio.parseBoolean(request.getParameter("chkCidade")));
        
        CodigoMovimentosRepom codigoMovimentosRepom = null;
        int maxCodigo = Apoio.parseInt(request.getParameter("maxCodigo"));
            for(int i = 0; i <= maxCodigo; i++){
            if(request.getParameter("codigo_"+i) != null){
                
                codigoMovimentosRepom = new CodigoMovimentosRepom();
                codigoMovimentosRepom.setId(Apoio.parseInt(request.getParameter("idCodigo_"+i)));
                codigoMovimentosRepom.setCodigoRepom(request.getParameter("codigo_"+i));
                codigoMovimentosRepom.setDescricao(request.getParameter("descricao_"+i));               
                codigoMovimentosRepom.setCampoView(request.getParameter("campoView_"+i));               
                
                cadfi.getFilial().getCodigoMovimentosRepoms().add(codigoMovimentosRepom);
            }
        }
            
        // IEs Substitutas
        FilialInscricaoEstadualSubstituta IESubs;
        
        JsonParser jsonParser = new JsonParser();
        JsonObject jsonObject = jsonParser.parse(request.getParameter("substitutas")).getAsJsonObject();
        for (JsonElement jsonElement : jsonObject.getAsJsonArray("listaUf")) {
            JsonObject object = jsonElement.getAsJsonObject();
            IESubs = new FilialInscricaoEstadualSubstituta();
            IESubs.setUF(object.getAsJsonPrimitive("uf").getAsString());
            IESubs.setInscEstSubstituta(object.getAsJsonPrimitive("insc").getAsString());
            IESubs.setId(object.getAsJsonPrimitive("id").getAsInt());
            
            IESubs.setIsExcluido(Apoio.parseBoolean(object.getAsJsonPrimitive("isExcluido").getAsString()));
            cadfi.getFilial().getIesSubstitutas().add(IESubs);
        }
         
        // start GerenciadorRisco
        cadfi.getFilial().getFilialGerenciadorRisco().setId(Apoio.parseInt(request.getParameter("filialGerenciamentoRiscoId")));
        cadfi.getFilial().getFilialGerenciadorRisco().setCodigo(request.getParameter("codigoGerenciadoraRisco"));
        cadfi.getFilial().getFilialGerenciadorRisco().setSenha(request.getParameter("senhaGerenciadoraRisco"));
        cadfi.getFilial().getFilialGerenciadorRisco().setStUtilizacao(Apoio.parseInt(request.getParameter("stUtilizacaoGerenciadoraRisco")));
        cadfi.getFilial().getFilialGerenciadorRisco().setDataInicioUso(Apoio.paraDate(request.getParameter("dataUsoGerenciadoraRiscoService")));
        cadfi.getFilial().getFilialGerenciadorRisco().setTipoBloqueioRastreamento(Apoio.parseInt(request.getParameter("tipoBloqueioRastreamento")));
        cadfi.getFilial().getFilialGerenciadorRisco().setPgrId(Apoio.parseInt(request.getParameter("idGerenciadoraRisco")));
        cadfi.getFilial().getFilialGerenciadorRisco().getGerenciadorRisco().setId(Apoio.parseInt(request.getParameter("gerenciamentoRiscoId")));
        // end GerenciadorRisco
        
        cadfi.getFilial().setLoginCFe(request.getParameter("loginCFe"));
        cadfi.getFilial().setSenhaCFe(request.getParameter("senhaCFe"));
        
        cadfi.getFilial().setLoginEfrete(request.getParameter("loginEfrete"));
        cadfi.getFilial().setSenhaEfrete(request.getParameter("senhaEfrete"));
        cadfi.getFilial().setUtilizaLoginEfrete(Apoio.parseBoolean(request.getParameter("isUtilizaLoginEfrete")));

        // start Fusion Trak
        cadfi.getFilial().setStUtilizacaoFusionTrakRoteirizador(request.getParameter("idStUtilizacaoFusionTrakRoteirizador").charAt(0));
        cadfi.getFilial().setLoginRoteirizador(request.getParameter("loginRoteirizador"));
        cadfi.getFilial().setSenhaRoteirizador(request.getParameter("senhaRoteirizador"));
        // end Fusion Trak
        cadfi.getFilial().setImportarNFeDestinatario(Apoio.parseBoolean(request.getParameter("importarXMLNFeFilial")));
        cadfi.getFilial().setModeloMdfe(request.getParameter("modelo-mdfe"));
        //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,align: "center"
        //3º teste de erro naquela acao executada.

        //09/08/2018  history-113
            cadfi.getFilial().setTravaDiasManifesto(Apoio.parseInt(request.getParameter("diasTravaManifesto")));
            cadfi.getFilial().setAtivarDiasMdfeEncerrados(Apoio.parseBoolean(request.getParameter("checTravaManifesto")));

        // 15/10/2018
        cadfi.getFilial().setTransmitirMDFeSeguradora(Apoio.parseBoolean(request.getParameter("transmitirSeguradoraMDFe")));
        cadfi.getFilial().setTransmitirAutomaticamenteMDFeSeguradora(Apoio.parseBoolean(request.getParameter("transmitirAutoMDFe")));
        cadfi.getFilial().setDataInicialAverbacaoMDFe(Apoio.paraDate(request.getParameter("dataAverbMDFe")));
        
        // 12/02/2019
        cadfi.getFilial().setDescontarTaxaCartaoContratado(Apoio.parseBoolean(request.getParameter("isDescontarTaxaCartaoContratado")));

        cadfi.getFilial().getPlanoCustoTransitoria().setId(Apoio.parseInt(request.getParameter("plano_contas_id")));
        cadfi.getFilial().getPlanoCustoTransitoria().setConta(request.getParameter("cod_conta"));
        cadfi.getFilial().getPlanoCustoTransitoria().setDescricao(request.getParameter("plano_conta_descricao"));

        cadfi.getFilial().setAbaterBaseCalculoImpostosPedagio(Apoio.parseBoolean(request.getParameter("isAbaterBaseCalculoImpostosPedagio")));
        cadfi.getFilial().setModeloMdfe(request.getParameter("modelo-mdfe"));
        
        // CNPJs autorizados
        for (int i = 1; i <= Apoio.parseInt(request.getParameter("qtdDomCnpjAutorizadoCTe")); i++) {
            if (request.getParameter("idCnpjAutorizadoCTe_" + i) != null) {
                FilialCnpjAutorizado filialCnpjAutorizado = new FilialCnpjAutorizado();
                
                filialCnpjAutorizado.setId(Apoio.parseInt(request.getParameter("idCnpjAutorizadoCTe_" + i)));
                filialCnpjAutorizado.setCnpj(StringUtils.replace(StringUtils.replace(StringUtils.replace(request.getParameter("cnpjAutorizadoCTe_" + i), "/", ""), ".", ""), "-", ""));
                filialCnpjAutorizado.setFilial(cadfi.getFilial());
                filialCnpjAutorizado.setTipo("c");
                
                cadfi.getFilial().getFilialCnpjAutorizadosCTe().add(filialCnpjAutorizado);
            }
        }

        for (int i = 1; i <= Apoio.parseInt(request.getParameter("qtdDomCnpjAutorizadoMDFe")); i++) {
            if (request.getParameter("idCnpjAutorizadoMDFe_" + i) != null) {
                FilialCnpjAutorizado filialCnpjAutorizado = new FilialCnpjAutorizado();

                filialCnpjAutorizado.setId(Apoio.parseInt(request.getParameter("idCnpjAutorizadoMDFe_" + i)));
                filialCnpjAutorizado.setCnpj(StringUtils.replace(StringUtils.replace(StringUtils.replace(request.getParameter("cnpjAutorizadoMDFe_" + i), "/", ""), ".", ""), "-", ""));
                filialCnpjAutorizado.setFilial(cadfi.getFilial());
                filialCnpjAutorizado.setTipo("m");

                cadfi.getFilial().getFilialCnpjAutorizadosMDFe().add(filialCnpjAutorizado);
            }
        }
        

        boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                ? cadfi.Inclui() : cadfi.Atualiza());
        
        

        //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
%><script language="javascript" type="text/javascript"><%
    if (erro) {
        acao = (acao.equals("atualizar") ? "editar" : "iniciar");
        if(cadfi.getErros().indexOf("filial_endereco_saida_buonny") > -1){
            %>alert('Atenção: Endereço da Buonny já foi utilizado, não pode ser excluido!');
                window.close();
            <%
        }if(cadfi.getErros().indexOf("cidade_filial") > -1){
            %>alert('Atenção: Cidades atendidas para essa filial não pode se repetir!');
                window.close();
            <%
        }if(cadfi.getErros().indexOf("uniq_comp_filial") > -1){
            %>alert('Atenção: Já exite uma competência para essa filial cadastrada!');
                window.close();
            <%
        }if (cadfi.getErros().indexOf("filial_inscricao_estadual_substituta_uf") > -1){
            %>alert('Atenção: Não pode existir mais de uma Inscrição Estadual substituta para uma UF!');
                window.close();
            <%
        }else{
            %>alert('<%=(cadfi.getErros())%>');
                window.opener.$("salvar").disabled = false;
                window.opener.$("salvar").value = "Salvar";
                window.close();
            <%
                fi = cadfi.getFilial();
        }
            
    } else {
        BeanUsuario user = Apoio.getUsuario(request);
        user.setFilial(cadfi.getFilial());
        request.getSession().removeAttribute("usuario");
        request.getSession().setAttribute("usuario", user);
            %>
        window.close();
    window.opener.location.replace("ConsultaControlador?codTela=1");
    <%}%>
</script>

<%}
    //instanciando o bean de permissoes...
    if (acao.equals("iniciar") || acao.equals("editar")) {
        perm = new BeanPermissao();
        perm.setConexao(Apoio.getUsuario(request).getConexao());
    }
    if (acao.equals("removeImposto")) {
        int id = Apoio.parseInt(request.getParameter("idfilialAtual"));
        cadfi.removeImposto(id);
    }

    if(acao.equals("carregarRecolhimentoIcmsAjax")){
        String uf = request.getParameter("uf");
        
        Collection<RecolhimentoIcms> listaRec = RecolhimentoIcms.mostrarTodos(Apoio.getUsuario(request).getConexao(), uf);
        
        XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
        xstream.setMode(XStream.NO_REFERENCES);
        xstream.alias("recolhimentoIcms", RecolhimentoIcms.class);
        String json = xstream.toXML(listaRec);

        response.getWriter().append(json);

        response.getWriter().close();
    }
    
    //variavel usada para saber se o usuario esta editando
    carregaFi = ((fi != null) && (fi.getCnpj() != null) && (!acao.equals("incluir") || !acao.equals("atualizar")));
    
    String dataAtual = fmt.format(new Date());
    
    if (acao.equals("excluirRateioCustoAdministrativo")){
        cadfi = new BeanCadFilial();
        cadfi.setExecutor(Apoio.getUsuario(request));
        cadfi.setConexao(Apoio.getUsuario(request).getConexao());
    
        int idRateio = Apoio.parseInt(request.getParameter("idRatear"));       
         cadfi.excluirRateioCustoAdministrativo(idRateio);
         
    }
    
    if(acao.equalsIgnoreCase("excluirEnderecoFilialSaidaBuonny")){
        boolean retorno = false;
        cadfi = new BeanCadFilial();
        cadfi.setExecutor(Apoio.getUsuario(request));
        cadfi.setConexao(Apoio.getUsuario(request).getConexao());
        
        int idEnderecoSaidaByonny = Apoio.parseInt(request.getParameter("idEnderecoFilialSaidaBuonny"));
        retorno = cadfi.excluirEnderecoFilialSaidaBuonny(idEnderecoSaidaByonny);
        
        XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
        xstream.setMode(XStream.NO_REFERENCES);
        xstream.alias("retorno", Boolean.class);
        String json = xstream.toXML(retorno);

        response.getWriter().append(json);

        response.getWriter().close();
    }  
   //excluir a cidade selecionada
    if(acao.equalsIgnoreCase("excluirCidadeSaida")){
        boolean retorno = false;
        cadfi = new BeanCadFilial();
        cadfi.setExecutor(Apoio.getUsuario(request));
        cadfi.setConexao(Apoio.getUsuario(request).getConexao());
        
        int idCidade = Apoio.parseInt(request.getParameter("idCidade"));
        retorno = cadfi.excluirCidadeSaida(idCidade);
        
        XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
        xstream.setMode(XStream.NO_REFERENCES);
        xstream.alias("retorno", Boolean.class);
        String json = xstream.toXML(retorno);

        response.getWriter().append(json);

        response.getWriter().close();
    }  
    
    //Localizar por UF.
    if(acao.equalsIgnoreCase("localizarCidadesPorUF")){
        Collection<BeanCidade> retorno = null;
        cadfi = new BeanCadFilial();
        cadfi.setExecutor(Apoio.getUsuario(request));
        cadfi.setConexao(Apoio.getUsuario(request).getConexao());
        
        String UF = request.getParameter("uf");
        retorno = cadfi.localizarCidadesPorUF(UF);
        
        XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
        xstream.setMode(XStream.NO_REFERENCES);
        xstream.alias("retorno", CidadesAtendidas.class);
        String json = xstream.toXML(retorno);
        
        
        response.getWriter().append(json);

        response.getWriter().close();
    }  
    
    if (acao.equals("removerCodigosRepom")) {
        int idCodigo = Apoio.parseInt(request.getParameter("idCodigo"));
       // int idFilial = Apoio.parseInt(request.getParameter("idFilial"));
        BeanCadFilial beanCadFilial = new BeanCadFilial();
        beanCadFilial.setConexao(Apoio.getUsuario(request).getConexao());
        beanCadFilial.setExecutor(Apoio.getUsuario(request));
        beanCadFilial.deletarCodigosRepom(idCodigo,  Apoio.getUsuario(request));
        response.getWriter().append("Removido com sucesso!");
        response.getWriter().close();
    }
    
    request.setAttribute("autenticado", Apoio.getUsuario(request));
    
%>
<script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<!--<script language="JavaScript" src="script/jquery.js" type="text/javascript"></script>-->
<script language="javascript" src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="javascript" src="script/mascaras.js" type="text/javascript"></script>
<script type="text/javascript" src="script/fabtabulous.js"></script>
<script type="text/javascript" src="script/jquery-1.11.2.min.js"></script>
<script src="${homePath}/assets/js/jquery.mask.min.js?v=${random.nextInt()}"></script>
<script language="JavaScript" src="script/LogAcoesAuditoria.js" type="text/javascript"></script>
<script src="${homePath}/script/funcoesTelaFilial.js?v=${random.nextInt()}"></script>
<script language="javascript" type="text/javascript">
    
    var homePath = '${homePath}';

    arAbasGenerico = new Array();
    arAbasGenerico[0] = new stAba('tdIntFiscal','tab1');
    arAbasGenerico[1] = new stAba('tdOperacional','tab2');
    arAbasGenerico[2] = new stAba('tdFinanceiro','tab7');
    arAbasGenerico[3] = new stAba('tdIntegracoes','tab3');
    arAbasGenerico[4] = new stAba('tdGerencial','tab4');
    arAbasGenerico[5] = new stAba('tdPermissoes','tab5');
    arAbasGenerico[6] = new stAba('tdAuditoria','tab6');
    arAbasGenerico[7] = new stAba('tdConfigGerais','tab8');
    
    
    
    
    jQuery.noConflict();
    function check() {
        var i = 1;
        if (!wasNull('rzs,abrev,cnpj')){
            while (document.getElementById("ck"+i) != null){
                if (document.getElementById("ck"+i).checked == true)
                    return true;
                i++;
            }
            return false;
        }else
            return false;
    }
    
    var listaSeg =null;
    var y=0;

    function atribuicombos(){
    <%   if (carregaFi) {
    %>
            //****************** SEF ********************
            var valorMaximo = '<%=df.format(fi.getValorMaximo())%>';
                $("valorMaximo").value = valorMaximo;
            
//            if(valorMaximo.split(".")[1].length < 2){
//               valorMaximo = valorMaximo + "0"; 
//            }
//            
//            if(valorMaximo != "0.0"){
//                $("valorMaximo").value = fmtReais(valorMaximo,2);
//            }
          
            $("controleValor").checked = <%=fi.isIsAtivaControleValorManifesto()%>
            $("indArq").value = "<%=fi.getIndArq().getId()%>";
            $("prfIss").value = "<%=fi.getPrfIss().getId()%>";
            $("prfIcms").value = "<%=fi.getPrfICMS().getId()%>";
            $("indEc").value = "<%=fi.getIndEc().getId()%>";
          
            $("uf_origemFilial").value = "<%=fi.getCidade().getUf()%>";
            $("driverPadraoImpressora").value = "<%=fi.getDriverPadraoImpressora()%>";
            $("cnpj").value = formatCpfCnpj("<%=fi.getCnpj()%>", true, true);
            $("cpf_responsavel").value = formatCpfCnpj("<%=fi.getCpfResponsavel()%>", true,false);
            $("cpf_contador").value = formatCpfCnpj("<%=fi.getCpfContador()%>", true,false);
            $("cnpjContratante").value = "<%=fi.getCnpjContratantePamcard()%>";
            $("modalConhecimento").value = "<%=fi.getModalCTE()%>";
            $("modeloDacte").value = "<%=fi.getModeloDacte()%>";
            $("cod_recolhimento").value= "<%=fi.getCodRecolhimentoIcms().getId()%>"
            $("perfilEFD").value= "<%=fi.getPerfilEFD()%>";
            $("codAgregacaoEntrada").value= "<%=fi.getCodAgregacaoEntrada()%>";
            $("codAgregacaoSaida").value= "<%=fi.getCodAgregacaoSaida()%>";
            $("tipo_utilizacao_apisul").value = "<%=fi.getTipoUtilizacaoApisul()%>";
            $("tipoUtilizacaoAverbacaoNFSe").value = "<%=fi.getTipoUtilizacaoAverbacaoNFSe()%>";
            $("tipoUtilizacaoGWMobile").value = "<%=fi.getTipoUtilizacaoGWMobile()%>";
            $("cnpjMatriz").value = formatCpfCnpj("<%=fi.getCnpjMatriz()%>", true, true);

            $("emailFaturaFilial").value = '${filial.emailFaturaFilial.id == null? 0 : filial.emailFaturaFilial.id}';
            $("modelo-mdfe").value = "<%=fi.getModeloMdfe() == "" ? "1" : fi.getModeloMdfe()%>" ;
            
            alteraAverbacao();
            alteraAverbacaoNfse();
            if("<%=fi.isTransmitirCteServidorSeguradora()%>"=="true"){                
                $("transmitirSeguradora").checked = true;
                alteraSeguradora(true);
            }else{
                $("transmitirSeguradora").checked = false;
                alteraSeguradora(false);
            }
            if("<%=fi.isTransmitirAutomaticamenteConfirmarCte()%>"=="true"){
                $("transmitirAuto").checked = true;
            }
      
         alteraCfe();
   
            if("<%=fi.isSolicitarConferenciaDocumentoCiot()%>"=="true"){
                if($("solicitarConferenciaDocumentoCiot")!=null){
                   $("solicitarConferenciaDocumentoCiot").checked = true;                
                }
            }
            //solicitarConferenciaDocumentoCiot
          
          
          

        habilitarValorTarifas();




        
        
        var camposRepom=null;
          <%         
        if(fi.getCodigoMovimentosRepoms().size()>0){
         for (CodigoMovimentosRepom codigo : fi.getCodigoMovimentosRepoms()) {%>             
             camposRepom = new CamposRepom(<%=codigo.getId()%>, '<%=codigo.getCodigoRepom()%>', '<%=codigo.getDescricao()%>' , 
             '<%=codigo.getCampoView()%>');         
             addCodigoMovimentoRepom(camposRepom);
    <%}}%>     
        <% for(TarefaAgendadaBaixarXml xml : fi.getTarefabaixarXml()){ %>    
            var cron = new Cron('<%= xml.getId()%>','<%= xml.getCronExpression()%>');
            addCron('<%=(xml.getTipoXml().equals("C") ? "cte" : "nfe")%>',cron);
        <%}%>

        if ("<%=fi.isTransmitirMDFeSeguradora()%>" == "true") {
            $("transmitirSeguradoraMDFe").checked = true;
            alteraSeguradoraMDFe(true);
        } else {
            $("transmitirSeguradoraMDFe").checked = false;
            alteraSeguradoraMDFe(false);
        }
        
        $("isUtilizaLoginEfrete").checked = "<%= fi.isUtilizaLoginEfrete() %>" == "true";
        utilizaLoginSenhaEfrete();
        
        
        if ("<%=fi.isTransmitirAutomaticamenteMDFeSeguradora()%>" == "true") {
            $("transmitirAutoMDFe").checked = true;
        }
    <%   }%>
            
            alteraCfe();
             <%
                negociacaoFilial = new ArrayList<NegociacaoAdiantamentoFrete>();
                Consulta filtros2 = new Consulta();
                filtros2.setCampoConsulta("descricao");
                filtros2.setLimiteResultados(10000000);
                filtros2.setOperador(Consulta.TODAS_AS_PARTES);
                NegociacaoAdiantamentoFreteBO negoDao = new NegociacaoAdiantamentoFreteBO();
                negociacaoFilial = negoDao.carregarCombo();
                %>
                $("negociacaoAdiantamento").value = "<%= carregaFi? cadfi.getFilial().getNegociadaoAdiantamentoId() : 0 %>";
                
                
            
                <c:forEach var="filialCnpjAutorizado" items="${filial.filialCnpjAutorizadosCTe}">
                    aoClicarAdicionarCnpjAutorizadoCTe(undefined, '${filialCnpjAutorizado.id}', '${filialCnpjAutorizado.cnpj}');
                </c:forEach>
                <c:forEach var="filialCnpjAutorizado" items="${filial.filialCnpjAutorizadosMDFe}">
                    aoClicarAdicionarCnpjAutorizadoMDFe(undefined, '${filialCnpjAutorizado.id}', '${filialCnpjAutorizado.cnpj}');
                </c:forEach>
        }

    function voltar(){
        document.location.replace("ConsultaControlador?codTela=1");
    }

   
    
    function salva(acao, qtde_permissoes){
        
        var qtdCidadeRemovidas = $("maxCidades").value;
        var qtdRateiosRemovidos = $("maxValorDivido").value;
        var msgRemoverValorDOM = $("idDefinicaoSalarioMotoristaVeiculo").value;
        try{
    
        if (!isCnpj(document.getElementById("cnpjContratante").value) && $('stUtilizacaoCfe').value == 'P' ){
            alert ("CNPJ do Contratante Inválido.");
            $("cnpjContratante").focus();
            return false;
        }
//         if ($('filialCfe_' + $('filial').value).value == 'P') {
//                if ($("natureza_cod").value == 0) {
//                    alert("Informe a natureza da carga!")
//                    return false;
//                }
//            }
        if (!isCnpj(document.getElementById("cnpj").value)){
            alert ("CNPJ Inválido.");
       
        }else if (check()) {     
            if($("stUtilizacaoCfe").value=='E'){
                if (!isCnpj(document.getElementById("cnpjMatriz").value)){
                    return showErro("CNPJ da Matriz (E-Frete) Inválido.");
                }
                
            }
            
            if(document.getElementById("isContingenciaFSDA").checked ==  true){   
           
                if(document.getElementById("justificativaFSDA").value=="" || document.getElementById("justificativaFSDA").value == 'undefined'){
                    return showErro("Justificativa de Contigência com FS-DA deve ser preenchida!", document.getElementById("justificativaFSDA"));
                }
                if(document.getElementById("dataFSDA").value=="" || document.getElementById("dataFSDA").value == 'undefined'){
                     return showErro("Data da Contigência com FS-DA deve ser preenchida corretamente!", document.getElementById("dataFSDA"));              
                }
                if(document.getElementById("horaFSDA").value=="" || document.getElementById("horaFSDA").value == 'undefined'){
                    return showErro("Hora da Contigência com FS-DA deve ser preenchida corretamente!", document.getElementById("horaFSDA"));
                }       
            }  
            var url = "";
            for (i = 1; i <= qtde_permissoes; ++i)
            {
                if ( (document.getElementById("ck"+i) != null) && (document.getElementById("ck"+i).checked) )
                {
                    url += (url != ""?",":"")+document.getElementById("ck"+i).value;                  
                }
            }
            if (acao == "atualizar")
                acao += "&id=<%=(carregaFi ? fi.getIdfilial() : 0)%>";
            //alert("aaaaa  "+$("indRiT").checked);
            
//            alert($("isHomologacaoCfe").checked)
                
//            document.location.replace("./cadfilial?acao="+acao+"&rzs="+encodeURIComponent($("rzs").value)+
//                "&cnpj_confirmador_ndd=" + $("cnpj_confirmador_ndd").value+
//                "&Selectconfirmador=" + $("Selectconfirmador").value +
//                "&abrev="+encodeURIComponent($("abrev").value)+
//                "&cnpj="+formatCpfCnpj($("cnpj").value,false,true)+
//                "&fone="+$("fone").value+
//                "&bairro="+$("bairro").value+
//                "&cidade="+$("cid_origemFilial").value+
//                "&cidade_id="+$("idcidadeorigemFilial").value+
//                "&en="+$("en").value+
//                "&uf="+$("uf_origemFilial").value+
//                "&idagente="+$("idagente").value+
//                "&cep="+$("cep").value+
//                "&cpf_contador="+formatCpfCnpj($("cpf_contador").value,false,false)+
//                
//                "&cep_contador="+$("cep_contador").value+
//                "&logradouro_contador="+$("logradouro_contador").value+
//                "&num_logradouro_contador="+$("num_logradouro_contador").value+
//                "&complemento_logradouro_contador="+$("complemento_logradouro_contador").value+
//                "&bairro_contador="+$("bairro_contador").value+
//                "&cidade_contador="+$("cidadeContador").value+
//                "&cidade_contador_id="+$("idcidadecontador").value+
//                "&uf_contador="+$("ufContador").value+
//                                
//                "&cpf_responsavel="+formatCpfCnpj($("cpf_responsavel").value,false,false)+
//                "&deduzirPedagio="+$("deduzirPedagio").checked+
//                "&geraSequenciaCtrc="+$("geraSequenciaCtrc").checked+
//                "&isCalcularPedagioCfe="+$("isCalcularPedagioCfe").checked+
//                "&isHomologacaoCfe="+$("isHomologacaoCfe").checked+
//                "&sequenciaMultiModal="+$("sequenciaMultiModal").checked+
//                "&optanteSimplesNacional="+$("optanteSimplesNacional").checked+
//                "&stUtilizacaoCte="+$("stUtilizacaoCte").value+
//                "&stUtilizacaoCle="+$("stUtilizacaoCle").value+
//                "&stUtilizacaoCfe="+$("stUtilizacaoCfe").value+
//                "&perfilEFD="+$("perfilEFD").value+
//                "&stUtilizacaoNfse="+$("stUtilizacaoNfse").value+
//                "&rateioComercial="+$("rateioComercial").value+
//                "&rateioAdministrativo="+$("rateioAdministrativo").value+
//                "&modalConhecimento="+$("modalConhecimento").value+
//                "&sequenciaSeloCT="+$("sequenciaSeloCT").checked+
//                "&horaCancelamentoCte="+$("horaCancelamentoCte").checked+
//                "&itauSegurosAverbarRCF="+$("itauSegurosAverbarRCF").checked+
//                "&itauSegurosAverbarTRN="+$("itauSegurosAverbarTRN").checked+
//                "&site="+$("site").value+
//                "&contaPamcardId="+$("contaPamcardId").value+
//                "&contaNddId="+$("contaNddId").value+
//                "&contaTicketFreteId="+$("contaTicketFreteId").value+
//                "&contaRepomId=" + $("contaRepomId").value +
//                "&cnpjContratante="+formatCpfCnpj($("cnpjContratante").value,false,true)+
//                "&cnpjContratanteGwMobile="+$("cnpjContratanteGwMobile").value+
//                "&indArq="+ $("indArq").value+
//                "&prfIss="+ $("prfIss").value+
//                "&prfIcms="+ $("prfIcms").value+
//                "&prfRidf="+ $("prfRidfT").checked+
//                "&prfRudf="+ $("prfRudfT").checked+
//                "&prfLmf="+ $("prfLmfT").checked+
//                "&prfRv="+ $("prfRvT").checked+
//                "&prfRi="+ $("prfRiT").checked+
//                "&indEc="+ $("indEc").value+
//                "&indIss="+ $("indIssT").checked+
//                "&indRt="+ $("indRtT").checked+
//                "&indIcms="+ $("indIcmsT").checked+
//                "&indSt="+ $("indStT").checked+
//                "&indAt="+ $("indAtT").checked+
//                "&indIpi="+ $("indIpiT").checked+
//                "&indRi="+ $("indRiT").checked+
//                "&modeloDacte="+ $("modeloDacte").value+
//                "&cod_recolhimento="+$("cod_recolhimento").value+
//                "&login_averbacao="+$("login_averbacao").value+
//                "&agregarValoresSPED="+$("agregarValoresSPEDT").checked+
//                "&senha_averbacao="+$("senha_averbacao").value+
//                "&codigo_atm="+$("codigo_atm").value+
//                "&seguradoraAverbacao="+$("seguradoraAverbacao").value+
//                "&tipo_utilizacao_apisul="+$("tipo_utilizacao_apisul").value+
//                "&transmitirSeguradora="+$("transmitirSeguradora").checked+
//                "&transmitirAuto="+$("transmitirAuto").checked+
//                "&stUtilizacaoMDFe="+$("stUtilizacaoMDFe").value+
//                "&seguradora="+$("seguradora").value+
//                "&utilizarCertificadoA1="+$("utilizarCertificadoA1").checked+
//                
//                "&averbarNormal="+$("averbarNormal").checked+
//                "&averbarDistLocal="+$("averbarDistLocal").checked+
//                "&averbarDiarias="+$("averbarDiarias").checked+
//                "&averbarPallets="+$("averbarPallets").checked+
//                "&averbarComplementar="+$("averbarComplementar").checked+
//                "&averbarReentrega="+$("averbarReentrega").checked+
//                "&averbarDevolucao="+$("averbarDevolucao").checked+
//                "&averbarCortesia="+$("averbarCortesia").checked+
//                "&averbarSubstituicao="+$("averbarSubstituicao").checked+
//                "&versaoCTE="+$("versaoCTE").value+
//                "&imprimirEtiquetaPaginacao="+$("imprimirEtiquetaPaginacao").value+
//                "&imprimirMais="+$("imprMais1").checked+
//                
//                "&formImg="+$("formImg").submit+
//                "&formImg1="+document.getElementById("formImg")+
//                "&formImgenc="+document.getElementById("formImg").enctype+
//                
//                "&isContingenciaFSDA="+document.getElementById("isContingenciaFSDA").checked+
//                "&justificativaFSDA="+document.getElementById("justificativaFSDA").value+
//                "&dataFSDA="+document.getElementById("dataFSDA").value+
//                "&horaFSDA="+document.getElementById("horaFSDA").value+
//                "&criarParcelaValorDescarga="+document.getElementById("criarParcelaValorDescarga").checked+                
//                "&stUtilizacaoBuonnyRoteirizador="+$("stUtilizacaoBuonnyRoteirizador").value+"&utilizacaoNFSeG2ka="+$("utilizacaoNFSeG2ka").checked+"&idfilial="+$("idfilial").value+
//                "&seriePadraoCTeAereo="+$("seriePadraoCTeAereo").value+"&seriePadraoCTeAquaviario="+$("seriePadraoCTeAquaviario").value+"&seriePadraoCTeRodoviario="+$("seriePadraoCTeRodoviario").value+
//                "&gerarOpcaoCIOTTacAgregado="+document.getElementById("gerarOpcaoCIOTTacAgregado").checked+"&confirmarPagamentoNDD="+$("confirmarPagamentoNDD").checked+                
//                "&"+concatFieldValue("caminho_impressora,driverPadraoImpressora,codigofilial,inscest,inscmun," + 
//                "numero,responsavel,nome_contador,crc_contador,fone1_contador,fone2_contador," +
//                "fax_contador,cxpostal_contador,email_contador,fone_responsavel,email_responsavel,numero_rntrc"+ 
//                ",itauSegurosNumeroApolice,itauSegurosSubGrupo,cnae_id,cod_cnae,descricao_cnae,naturezaOperacao,regimeEspecialTributacao,emailRecebimentoPreAlerta")+
//                "&ps="+url);
            if(msgRemoverValorDOM == 'm'){
                if(qtdRateiosRemovidos != 0){
                    if(!confirm("Atenção, valores do rateio serão Excluídos!")){
                        return false;
                    }
                    if(!confirm("Tem certeza?!")){
                        return false;
                }
            }
        }
        if($("chkCidade").checked == false){
        if(qtdCidadeRemovidas != 0){
            if(!confirm("Atenção, as cidades serão Excluídas!")){
                        return false;
                    }
                    if(!confirm("Tem certeza?!")){
                        return false;
                }
            }
        }
        if($("stUtilizacaoCte").value != 'N'){
            if ($("seriePadraoCTeAereo").value == "" || $("seriePadraoCTeAquaviario").value == "" || $("seriePadraoCTeRodoviario").value == "") {
                alert("Atenção! Os campos de série padrão para emissão do CT-e não podem ficar em branco.");
                return false;
            }
        }
        if(document.getElementById("gerenciamentoRiscoId").value != '1'){
            if(document.getElementById("dataUsoGerenciadoraRiscoService").value == ""){
                showErro("Atenção! Ao ativar o uso da integração com um gerenciador de risco, o campo Data Início é de preenchimento obrigatório.", $("dataUsoGerenciadoraRiscoService"));
                return false;
            }
        }
       
        //seguradoraRodoviario  seguradoraAereo  seguradoraAquaviario
        var preenchido = false;
        if($("tipo_utilizacao_apisul").value != "N"){
            if($("seguradoraRodoviario").value!='0'){
                preenchido = true;
            }
            if($("seguradoraAereo").value!='0'){
                preenchido = true;
            }
            if($("seguradoraAquaviario").value!='0'){
                preenchido = true;
            }
            
            if(!preenchido){
                alert("Preencha ao menos uma Caixa Postal de Seguradora!");
                return false;
            }
            
        }
        if($("controleValor").checked == true && ($("valorMaximo").value == "0,00" || $("valorMaximo").value == "")){
            alert("O valor maximo deve ser diferente de zero ou vazio quando o controle de valor estiver ativo.");
            return false;
        }
        
        // Validar CNPJs 
        let isOk = true;
        jQuery('input[type="text"][name^="cnpjAutorizadoCTe"]').each(function loopValidarCnpjAutorizadosCTe() {
            if (!isCnpj(this.value)) {
                alert('O CNPJ ' + this.value + ' da seção CNPJ(s) autorizados a baixar o XML do CT-e da SEFAZ está inválido!');

                isOk = false;

                return false;
            }
            
            // Verificar se existe o mesmo CNPJ em outro lugar
            let cnpj = this.value;

            if (jQuery('input[type="text"][name^="cnpjAutorizadoCTe"]').filter(function filtrarCnpj() { return this.value === cnpj }).length > 1) {
                alert('O CNPJ ' + cnpj + ' da seção CNPJ(s) autorizados a baixar o XML do CT-e da SEFAZ está duplicado!');

                isOk = false;

                return false;
            }
        });
        
        if (!isOk) {
            return false;
        }

        jQuery('input[type="text"][name^="cnpjAutorizadoMDFe"]').each(function loopValidarCnpjAutorizadosMDFe() {
            if (!isCnpj(this.value)) {
                alert('O CNPJ ' + this.value + ' da seção CNPJ(s) autorizados a baixar o XML do MDF-e da SEFAZ está inválido!');

                isOk = false;

                return false;
            }

            // Verificar se existe o mesmo CNPJ em outro lugar
            let cnpj = this.value;

            if (jQuery('input[type="text"][name^="cnpjAutorizadoMDFe"]').filter(function filtrarCnpj() { return this.value === cnpj }).length > 1) {
                alert('O CNPJ ' + cnpj + ' da seção CNPJ(s) autorizados a baixar o XML do MDF-e da SEFAZ está duplicado!');

                isOk = false;

                return false;
            }
        });

            document.getElementById("salvar").disabled = true;
            document.getElementById("salvar").value = "Enviando...";
            var formulario = $("formImg");    
            formulario.action = "./cadfilial?acao="+acao+"&rzs="+encodeURIComponent($("rzs").value)
                                +"&permissaoCK="+url+"&abrev="+encodeURIComponent($("abrev").value)
                                +"&cnpj="+formatCpfCnpj($("cnpj").value,false,true)
                                +"&cpf_contador="+formatCpfCnpj($("cpf_contador").value,false,false)
                                +"&cpf_responsavel="+formatCpfCnpj($("cpf_responsavel").value,false,false)
                                +"&cnpjContratante="+formatCpfCnpj($("cnpjContratante").value,false,true);
            window.open('about:blank', 'pop', 'width=210, height=100');
            formulario.submit();  

        return true;        
                  
    
        }else{
            alert("Preencha os campos corretamente!");
        }
    }catch(e){
        alert(e);
    }    
          
    }
    function pesquisarAuditoria() {    
        for (var i = 1; i <= countLog; i++) {
            if ($("tr1Log_" + i) != null) {
                Element.remove(("tr1Log_" + i));
            }
            if ($("tr2Log_" + i) != null) {
                Element.remove(("tr2Log_" + i));
            }
        }
        countLog = 0;
        var rotina = "filial";
        var dataDe = $("dataDeAuditoria").value;
        var dataAte = $("dataAteAuditoria").value;
        var id = "<%=(fi != null ? fi.getId(): 0)%>";
        consultarLog(rotina, id, dataDe, dataAte);
    }
    function carregarCodRecolhimento(elemento){
        try {
            //carrega bombas dependendo de tanque
            new Ajax.Request('./cadfilial?acao=carregarRecolhimentoIcmsAjax' + '&uf=' + elemento.value,{
                method:'get',
                onSuccess: function(transport){
                    var resposta = jQuery.parseJSON(transport.responseText);
                    var lista = resposta.list[0];
                    var listaOption = new Array();
                    listaOption[0] = new Option("0", "Selecione");
                    if (lista != null && lista != undefined && lista != "") {
                        var recolhimentoIcms = lista.recolhimentoIcms;
                        
                        var length = (recolhimentoIcms != undefined && recolhimentoIcms.length != undefined ? recolhimentoIcms.length : 1);
                        
                        for(var i = 0; i < length; i++){
                            if(length > 1){
                                listaOption[i + 1] = new Option(recolhimentoIcms[i].id, recolhimentoIcms[i].codigo + "-" + recolhimentoIcms[i].descricao);
                            }else{
                                listaOption[i + 1] = new Option(recolhimentoIcms.id,  recolhimentoIcms.codigo + "-" + recolhimentoIcms.descricao);
                            }
                        }
                    }
                    removeOptionSelected($("cod_recolhimento").id);
                    povoarSelect($("cod_recolhimento"), listaOption);
                },
                onFailure: function() { alert('Something went wrong...')}
            });
        } catch (e) { 
            alert(e);
        }
    }

    function aoClicarNoLocaliza(janelaId){   
   
        if (janelaId.trim() == "Cidade") {
            $('cid_origemFilial').value = $('cid_origem').value;
            $('uf_origemFilial').value = $('uf_origem').value;
            $('idcidadeorigemFilial').value = $('idcidadeorigem').value;
            carregarCodRecolhimento($("uf_origemFilial"));
            ativarICMSGO();
        }
//        if (janelaId == "Conta_Pancard") {
//            $("contaPamcardId").value = $("idconta").value;
//            $("contaPamcard").value = $("descricao").value;
//        }
//        if (janelaId == "Conta_Ndd") {
//            $("contaNddId").value = $("idconta").value;
//            $("contaNdd").value = $("descricao").value;
//        }
//
//        if(janelaId == "Conta_TicketFrete"){
//            $("contaTicketFreteId").value = $("idconta").value;
//            $("contaTicketFrete").value = $("descricao").value;
//
//        }
//        
//        if (janelaId == "Conta_Repom") {
//            $("contaRepomId").value = $("idconta").value;
//            $("contaRepom").value = $("descricao").value;
//
//        }        
       
        if (janelaId == "Conta_CFe") {
            $("contaCfeId").value = $("idconta").value;
            $("contaCfe").value = $("descricao").value;
        }        
       
       
        if (janelaId == "Cidade_Contador"){       
            $('cidadeContador').value = $('cid_origem').value;
            $('ufContador').value = $('uf_origem').value;
            $('idcidadecontador').value = $('idcidadeorigem').value;
            
        }
        
        //Objeto null, recebe informaçoes do Localizar Cidade_Atendidas 
        if (janelaId == "Cidade_Atendidas") {
            var idCidade = $('idcidadeorigem').value;
            var cidade = $('cid_origem').value;            
            var existe = true; 
            existe = consultarCidades(idCidade, cidade);
            
           if(existe == true){
               var cidadeAtendida = null;
                cidadeAtendida = new CidadeAtendida()
                cidadeAtendida.idCidade = idCidade;
                cidadeAtendida.cidade = cidade;
                cidadeAtendida.uf = $('uf_origem').value;

            addCidadeAtendida(cidadeAtendida);
           } 
            
            
        }
            
        if(janelaId == 'Filial'){
            $("idfilialFreteAvista").value = $("idfilial").value;
        }
            
        var maxBairro = $("maxEnderecos").value;        
        for(var i = 1; i <= maxBairro; i++){
            if (janelaId == "FilialCidadeSaida_"+i){
                $('descricaoCidadeBuonny_'+i).value = $('cid_origem').value;
                $('descricaoUFCidadeBuonny_'+i).value = $('uf_origem').value;
                $('idCidadeBuonny_'+i).value=$('idcidadeorigem').value;                
            }
        }
    }

    function excluirfilial(idfilial){
        if (confirm("Deseja mesmo excluir esta filial?")){
            location.replace("./consultafilial?acao=excluir&id="+idfilial);
        }
    }
    
    
    function alteraAverbacaoNfse(){
        if($("tipoUtilizacaoAverbacaoNFSe").value=='N'){
            $("trAverbacaoNfse").style.display = "none";
        }else {
            $("trAverbacaoNfse").style.display = "";
        }
    }
    
    
    function alteraAverbacao(){
        if($("tipo_utilizacao_apisul").value!='N'){
            $("tdInfoAverbacao").style.display="";
            $("tdInfoAverbacao1").style.display="";
            $("tdInfoAverbacaoMDFe").style.display="";
              //$("tdInfoAverbacao2").style.display="";
              //$("tdInfoAverbacao3").style.display="";
              //$("tdInfoAverbacao4").style.display="";
              //$("tdInfoAverbacao5").style.display="";
        }else{
            $("tdInfoAverbacao").style.display="none";
            $("tdInfoAverbacao1").style.display="none";
            $("tdInfoAverbacaoMDFe").style.display="none";
            //$("tdInfoAverbacao2").style.display="none";
            //$("tdInfoAverbacao3").style.display="none";
            //$("tdInfoAverbacao4").style.display="none";
            //$("tdInfoAverbacao5").style.display="none";
        }
    }
    
    function alteraSeguradora(){
        
         var valor = $("transmitirSeguradora").checked;
                    
         if(valor==true || valor=="on"){
          //  $("seguradoraAverbacao").style.display="";
            $("transmitirAuto2").style.display= "";
            $("transmitirAuto").style.display= "";
         }else{
          //  $("seguradoraAverbacao").style.display="none";
            $("transmitirAuto2").style.display= "none";
            $("transmitirAuto").style.display= "none";
         }   
    }

    function alteraCfe(){
        $('lbAgente').innerHTML = '';
        $('agente').style.display='none';
        $('localiza_agente').style.display = 'none';
        //$('contaTicketFrete').style.display = 'none';
        //$('localiza_conta_ticketfrete').style.display = 'none';
        //$('lbContaTicketFrete').style.display = 'none'
        $('lbCNPJ').innerHTML = '';
        $('cnpjContratante').style.display = 'none';
        //$('cnpj_confirmador_ndd').style.display = 'none';
        //$('lbcnpj_confirmador_ndd').style.display = 'none';
        $('Selectconfirmador').style.display = 'none';
        $('tdSelectconfirmador').style.display = 'none';
        $('maisLinha').style.display = 'none';
        $('trIntFinan').style.display = 'none';
        
        if ($('stUtilizacaoCfe').value == 'R' ){
            $('agente').style.display = '';
            $('lbAgente').innerHTML = 'Agente Pagador:';
            $('localiza_agente').style.display = '';
            $('linhaNova').style.display = '';
         //   $('lbContaPancard').style.display = 'none';
         //   $('contaPamcard').style.display = 'none';
         //   $('localiza_conta_pancard').style.display ='none';
         //   $('lbContaTicketFrete').style.display = 'none';
           // $('lbContaNdd').style.display = 'none';
           // $('localiza_conta_ndd').style.display = 'none';
          //  $('contaNdd').style.display = 'none';
         //   $('contaTicketFrete').style.display = 'none';
         //   $('localiza_conta_ticketfrete').style.display = 'none';
            $('cnpjContratante').value="";
            $('cnpj_confirmador_ndd').style.display = 'none';
            $('lbcnpj_confirmador_ndd').style.display = 'none';
            $('Selectconfirmador').style.display = 'none';
            $('tdSelectconfirmador').style.display = 'none';
            $('maisLinha').style.display = 'none';    
            $('trNatureza').style.display = '';   
            $('trIntFinan').style.display = '';   
            //$('linhaNova01').style.display = '';
            $('despesaDescarga').style.display = 'none';
            $('tarifasBancarias').style.display = 'none';
            $('trInfoEFrete').style.display = 'none';
            $('trInfoEFrete2').style.display = 'none';
            $('trExpers').style.display = 'none';
            $('trExpers2').style.display = 'none'; 
            $("trPamcardServidor").style.display = 'none'; 
                     
            $('tdcontacfe1').style.display = ''; 
            $('tdcontacfe2').style.display = ''; 
            
            $('trInfoPagBem').style.display = 'none';
            $('trCodigoRepom').style.display = '';

            $('trTarget').style.display = 'none';

                     
            jQuery(".repom").show();
            jQuery(".pamcard").hide();
        }   
      
        if($('stUtilizacaoCfe').value == 'P'){
            $('linhaNova').style.display = '';
        //    $('lbContaPancard').style.display = '';
        //    $('contaPamcard').style.display = '';
         //   $('localiza_conta_pancard').style.display ='';
         //   $('lbContaNdd').style.display = 'none';
         //   $('localiza_conta_ndd').style.display = 'none';
        //    $('contaNdd').style.display = 'none';
         //   $('lbContaTicketFrete').style.display = 'none';
          //  $('contaTicketFrete').style.display = 'none';
          //  $('localiza_conta_ticketfrete').style.display = 'none';
            $('agente').style.display = '';
            $('lbAgente').innerHTML = 'Agente Pagador:';
            $('localiza_agente').style.display = '';
            $('linhaNova0').style.display = '';
            $("divlinhaNova0").style.display = '';
            $("divlinhaNova1").style.display = '';
            $("divlinhaNova2").style.display = '';
           // $('linhaNova01').style.display = 'none';
            $('lbCNPJ').innerHTML = 'CNPJ do Contratante:';
            $('cnpjContratante').style.display = '';
            $('cnpj_confirmador_ndd').style.display = 'none';
            $('lbcnpj_confirmador_ndd').style.display = 'none';
            $('Selectconfirmador').style.display = 'none';
            $('tdSelectconfirmador').style.display = 'none';
            $('maisLinha').style.display = 'none';
            $('despesaDescarga').style.display = 'none';
            $('trNatureza').style.display = '';   
            $('tarifasBancarias').style.display = '';
            $('trInfoEFrete').style.display = 'none';
            $('trInfoEFrete2').style.display = 'none';
            $('trExpers').style.display = 'none'; 
            $('trExpers2').style.display = 'none'; 
             $("trPamcardServidor").style.display = ''; 
            
            $('tdcontacfe1').style.display = ''; 
            $('tdcontacfe2').style.display = ''; 
            
            $('trInfoPagBem').style.display = 'none';
                        $('trCodigoRepom').style.display = 'none';
            $('trTarget').style.display = 'none';

            
            jQuery(".repom").hide();
            jQuery(".pamcard").show();
        }
        if ($('stUtilizacaoCfe').value == 'N' ){
           $('linhaNova').style.display = 'none';
            //$('lbContaPancard').style.display = 'none';
            //$('contaPamcard').style.display = 'none';
            //$('localiza_conta_pancard').style.display ='none';
            $('linhaNova0').style.display = 'none';
            //$('linhaNova01').style.display = 'none';
            $("divlinhaNova0").style.display = 'none';
            $("divlinhaNova1").style.display = 'none';
            $("divlinhaNova2").style.display = 'none';
//            $('lbContaNdd').style.display = 'none';
//            $('contaNdd').style.display = 'none';
//            $('localiza_conta_ndd').style.display = 'none';
//            $('contaTicketFrete').style.display = 'none';
//            $('localiza_conta_ticketfrete').style.display = 'none';
//            $('lbContaTicketFrete').style.display = 'none';
           // $('cnpjContratante').value="";
            $('cnpj_confirmador_ndd').style.display = 'none';
            $('lbcnpj_confirmador_ndd').style.display = 'none';
            $('Selectconfirmador').style.display = 'none';
            $('tdSelectconfirmador').style.display = 'none';
            $('maisLinha').style.display = 'none';
            $('despesaDescarga').style.display = 'none';
            $('trNatureza').style.display = 'none';   
            $('tarifasBancarias').style.display = 'none';
            $('trInfoEFrete').style.display = 'none';
            $('trInfoEFrete2').style.display = 'none';
            $('trExpers').style.display = 'none'; 
            $('trExpers2').style.display = 'none'; 
            $("trPamcardServidor").style.display = 'none'; 
            
            $('trInfoPagBem').style.display = 'none';
                        $('trCodigoRepom').style.display = 'none';
            $('trTarget').style.display = 'none';

            


            jQuery(".repom").hide();
            jQuery(".pamcard").hide();
        }
        if($('stUtilizacaoCfe').value == 'D'){
            $('linhaNova').style.display = '';
        //    $('lbContaPancard').style.display = 'none';
        //    $('contaPamcard').style.display = 'none';
        //    $('localiza_conta_pancard').style.display ='none';
         //   $('lbContaNdd').style.display = '';
          //  $('contaNdd').style.display = '';
         //   $('localiza_conta_ndd').style.display = '';
            $('linhaNova0').style.display = '';
            $("divlinhaNova0").style.display = '';
            $("divlinhaNova1").style.display = '';
            $("divlinhaNova2").style.display = '';
            $('agente').style.display = 'none';
            //$('linhaNova01').style.display = 'none';
            $('lbCNPJ').innerHTML = 'CNPJ do Contratante:';
            $('cnpjContratante').style.display = '';
          //  $('contaTicketFrete').style.display = 'none';
          //  $('localiza_conta_ticketfrete').style.display = 'none';
           // $('lbContaTicketFrete').style.display = 'none';
            $('cnpj_confirmador_ndd').style.display = '';
            $('lbcnpj_confirmador_ndd').style.display = '';
            $('Selectconfirmador').style.display = '';
            $('tdSelectconfirmador').style.display = '';
            $('maisLinha').style.display = '';
                $('tipoEfetivacao').style.display = '';
             $('despesaDescarga').style.display = ''; //divCriarParcelaValorDescarga  divHabilitarGerarCIOTTAC
            $('divCriarParcelaValorDescarga').style.display = '';
            $('divHabilitarGerarCIOTTAC').style.display = '';
            $('trNatureza').style.display = '';
            $('tarifasBancarias').style.display = '';
            $('trInfoEFrete').style.display = 'none';
            $('trInfoEFrete2').style.display = 'none';
               $("trPamcardServidor").style.display = 'none'; 
            
            $('trExpers').style.display = 'none'; 
            $('trExpers2').style.display = 'none'; 
                    
            $('tdcontacfe1').style.display = ''; 
            $('tdcontacfe2').style.display = ''; 
            
            $('trInfoPagBem').style.display = 'none';
                        $('trCodigoRepom').style.display = 'none';
            $('trTarget').style.display = 'none';

            
            jQuery(".repom").hide();
            jQuery(".pamcard").hide();
        }
        if($('stUtilizacaoCfe').value == 'T'){
          //  $('contaTicketFrete').style.display = '';
           // $('localiza_conta_ticketfrete').style.display = '';
            $('cnpjContratante').style.display = '';
            $('linhaNova').style.display = '';
          //  $('lbContaTicketFrete').style.display = '';
        //    $('lbContaPancard').style.display = 'none';
        //    $('contaPamcard').style.display = 'none';
         //   $('localiza_conta_pancard').style.display ='none';
           // $('lbContaNdd').style.display = 'none';
           // $('contaNdd').style.display = 'none';
          //  $('localiza_conta_ndd').style.display = 'none';
            $('linhaNova0').style.display = '';
            $("divlinhaNova0").style.display = '';
            $("divlinhaNova1").style.display = '';
            $("divlinhaNova2").style.display = '';
            //$('linhaNova01').style.display = 'none';
            $('lbCNPJ').innerHTML = 'CNPJ do Contratante:';
            $('cnpj_confirmador_ndd').style.display = 'none';
            $('lbcnpj_confirmador_ndd').style.display = 'none';
            $('Selectconfirmador').style.display = 'none';
            $('tdSelectconfirmador').style.display = 'none';
            $('maisLinha').style.display = 'none';
            $('despesaDescarga').style.display = 'none';
            $('trNatureza').style.display = '';
            $('tarifasBancarias').style.display = 'none';
            $('trInfoEFrete').style.display = 'none';
            $('trInfoEFrete2').style.display = 'none';
            $("trPamcardServidor").style.display = 'none'; 
            $('trExpers').style.display = 'none'; 
            $('trExpers2').style.display = 'none'; 
            $('trInfoPagBem').style.display = 'none';
                        $('trCodigoRepom').style.display = 'none';
            $('trTarget').style.display = '';
            

            

            jQuery(".repom").hide();
            jQuery(".pamcard").hide();

        }
        if($('stUtilizacaoCfe').value == 'E'){
           // $('contaTicketFrete').style.display = 'none';
           // $('localiza_conta_ticketfrete').style.display = 'none';
            $('cnpjContratante').style.display = 'none';
            $('linhaNova').style.display = '';
         //   $('lbContaTicketFrete').style.display = 'none';
        //    $('lbContaPancard').style.display = 'none';
        //    $('contaPamcard').style.display = 'none';
         //   $('localiza_conta_pancard').style.display ='none';
           // $('lbContaNdd').style.display = 'none';
            //$('contaNdd').style.display = 'none';
            //$('localiza_conta_ndd').style.display = 'none';
            $('linhaNova0').style.display = 'none';
            //$('linhaNova01').style.display = 'none';
            $('lbCNPJ').innerHTML = 'CNPJ do Contratante:';
            $('cnpj_confirmador_ndd').style.display = 'none';
            $('lbcnpj_confirmador_ndd').style.display = 'none';
          
            $('tdSelectconfirmador').style.display = '';
            $('maisLinha').style.display = '';
            $('tipoEfetivacao').style.display = 'none';
            $('Selectconfirmador').style.display = 'none';
            
            
            $('despesaDescarga').style.display = 'none';
            $('tarifasBancarias').style.display = 'none';
            $('trNatureza').style.display = '';
            $('trInfoEFrete').style.display = '';
            $('trInfoEFrete2').style.display = '';
            $('agente').style.display = 'none';
             
            $('lbcnpj_confirmador_ndd').style.display = 'none';            
           // $('contaPamcard').style.display = 'none';
           // $('contaPamcardId').style.display = 'none';
         //   $('localiza_conta_pancard').style.display = 'none';
            $('cnpj_confirmador_ndd').style.display = 'none'; 
            
            $('trExpers').style.display = 'none'; 
            $('trExpers2').style.display = 'none'; 
            $('tdCnpjMatriz').style.display = ''; 
            $('tdEmissaoGratuita').style.display = ''; 
            $('divPagBemCodigo').style.display = 'none'; 
            $('tdPermitirSemTAC').style.display = ''; 
               $("trPamcardServidor").style.display = 'none'; 
            $('tdcontacfe1').style.display = ''; 
            $('tdcontacfe2').style.display = ''; 
            $('trInfoPagBem').style.display = 'none';
                        $('trCodigoRepom').style.display = 'none';
           
            $('trTarget').style.display = 'none';
            

            
            jQuery(".repom").hide();
            jQuery(".pamcard").hide();

        }
        
        if($('stUtilizacaoCfe').value == 'X'){
           // $('contaTicketFrete').style.display = 'none';
           // $('localiza_conta_ticketfrete').style.display = 'none';
            $('cnpjContratante').style.display = 'none';
            $('linhaNova').style.display = '';
         //   $('lbContaTicketFrete').style.display = 'none';
        //    $('lbContaPancard').style.display = 'none';
         //   $('contaPamcard').style.display = 'none';
         //   $('localiza_conta_pancard').style.display ='none';
          //  $('lbContaNdd').style.display = 'none';
         //   $('contaNdd').style.display = 'none';
         //   $('localiza_conta_ndd').style.display = 'none';
            $('linhaNova0').style.display = 'none';
            //$('linhaNova01').style.display = 'none';
            $('lbCNPJ').innerHTML = 'CNPJ do Contratante:';
            $('cnpj_confirmador_ndd').style.display = 'none';
            $('lbcnpj_confirmador_ndd').style.display = 'none';
          
            $('tdSelectconfirmador').style.display = '';
            $('maisLinha').style.display = '';
            $('tipoEfetivacao').style.display = 'none';
            $('Selectconfirmador').style.display = 'none';
            
            $('despesaDescarga').style.display = ''; //divCriarParcelaValorDescarga  divHabilitarGerarCIOTTAC
            $('divCriarParcelaValorDescarga').style.display = 'none';
            $('divHabilitarGerarCIOTTAC').style.display = '';
            
            $('tarifasBancarias').style.display = '';
            $('trNatureza').style.display = '';
            $('trInfoEFrete').style.display = '';
            $('trInfoEFrete2').style.display = 'none';
            $('agente').style.display = 'none';
             
            $('lbcnpj_confirmador_ndd').style.display = 'none';            
        //    $('contaPamcard').style.display = 'none';
         //   $('contaPamcardId').style.display = 'none';
        //    $('localiza_conta_pancard').style.display = 'none';
            $('cnpj_confirmador_ndd').style.display = 'none'; 
            
            $('tdCnpjMatriz').style.display = ''; 
            $('tdEmissaoGratuita').style.display = 'none'; 
            $('divPagBemCodigo').style.display = 'none'; 
            $('tdPermitirSemTAC').style.display = ''; 
            $('trExpers').style.display = ''; 
            $('trExpers2').style.display = ''; 
            
             $('tdcontacfe1').style.display = ''; 
            $('tdcontacfe2').style.display = ''; 
            //tdPermitirSemTAC  trExpers
            $("trPamcardServidor").style.display = 'none'; 
            $('trInfoPagBem').style.display = 'none'; 
                        $('trCodigoRepom').style.display = 'none';
            $('trTarget').style.display = 'none';

            jQuery(".repom").hide();
            jQuery(".pamcard").hide();

        }
         if($('stUtilizacaoCfe').value == 'G'){
            //$('contaTicketFrete').style.display = 'none';
            //$('localiza_conta_ticketfrete').style.display = 'none';
            $('cnpjContratante').style.display = 'none';
            $('linhaNova').style.display = '';
           // $('lbContaTicketFrete').style.display = 'none';
          //  $('lbContaPancard').style.display = 'none';
          //  $('contaPamcard').style.display = 'none';
         //   $('localiza_conta_pancard').style.display ='none';
           // $('lbContaNdd').style.display = 'none';
           // $('contaNdd').style.display = 'none';
           // $('localiza_conta_ndd').style.display = 'none';
            $('linhaNova0').style.display = '';
            $("divlinhaNova0").style.display = '';
            $("divlinhaNova1").style.display = 'none';
            $("divlinhaNova2").style.display = 'none';
            //$('linhaNova01').style.display = 'none';
            $('lbCNPJ').innerHTML = 'CNPJ do Contratante:';
            $('cnpj_confirmador_ndd').style.display = 'none';
            $('lbcnpj_confirmador_ndd').style.display = 'none';
          
            $('tdSelectconfirmador').style.display = '';
            $('maisLinha').style.display = '';
            $('tipoEfetivacao').style.display = 'none';
            $('Selectconfirmador').style.display = 'none';
            
            $('despesaDescarga').style.display = ''; //divCriarParcelaValorDescarga  divHabilitarGerarCIOTTAC
            $('divCriarParcelaValorDescarga').style.display = 'none';
            $('divHabilitarGerarCIOTTAC').style.display = '';
            
            $('tarifasBancarias').style.display = '';
            $('trNatureza').style.display = '';
            $('trInfoEFrete').style.display = '';
            $('trInfoEFrete2').style.display = 'none';
            $('agente').style.display = 'none';
             
            $('lbcnpj_confirmador_ndd').style.display = 'none';            
         //   $('contaPamcard').style.display = 'none';
          //  $('contaPamcardId').style.display = 'none';
          //  $('localiza_conta_pancard').style.display = 'none';
            $('cnpj_confirmador_ndd').style.display = 'none'; 
            
            $('tdCnpjMatriz').style.display = ''; 
            $('divPagBemCodigo').style.display = ''; 
            $('tdEmissaoGratuita').style.display = 'none'; 
            $('tdPermitirSemTAC').style.display = 'none'; 
            $('trExpers').style.display = 'none'; 
            
            $('tdcontacfe1').style.display = ''; 
            $('tdcontacfe2').style.display = ''; 
            
            $('trInfoPagBem').style.display = ''; 
            $('trExpers2').style.display = 'none'; 
                        $('trCodigoRepom').style.display = 'none';
            $('trTarget').style.display = 'none';
            

            
            //tdPermitirSemTAC  trExpers

            jQuery(".repom").hide();
            jQuery(".pamcard").hide();

        }
        
        // Target
        if($('stUtilizacaoCfe').value == 'A'){
            $('cnpjContratante').style.display = '';
            $('linhaNova').style.display = '';
            $('linhaNova0').style.display = '';
            $("divlinhaNova0").style.display = 'none';
            $("divlinhaNova1").style.display = '';
            $("divlinhaNova2").style.display = '';
            $('agente').style.display = 'none';
            $('divHabilitarGerarCIOTTAC').style.display = '';
            $('lbCNPJ').innerHTML = 'CNPJ do Contratante:';
            $('cnpj_confirmador_ndd').style.display = 'none';
            $('lbcnpj_confirmador_ndd').style.display = 'none';
            $('Selectconfirmador').style.display = 'none';
            $('tdSelectconfirmador').style.display = '';
            $('maisLinha').style.display = '';
            $('tipoEfetivacao').style.display = 'none';
            $('despesaDescarga').style.display = '';
            $('divCriarParcelaValorDescarga').style.display = 'none';
            $('trNatureza').style.display = '';
            $('tarifasBancarias').style.display = '';
            $('trInfoEFrete').style.display = 'none';
            $('trInfoEFrete2').style.display = 'none';
            $("trPamcardServidor").style.display = 'none'; 
            $('trExpers').style.display = 'none'; 
            $('trExpers2').style.display = 'none'; 
            $('trInfoPagBem').style.display = 'none';
            $('trCodigoRepom').style.display = 'none';
            $('trTarget').style.display = '';

            jQuery(".repom").hide();
            jQuery(".pamcard").hide();

        }
    }
 
    function infoFsda(){   
        var check = $("isContingenciaFSDA").checked;
        if(check == true){
            $("infoFsda").style.display='';
        }else {
            $("infoFsda").style.display='none';
        }
    }
    
    function localizarFilial(){
        post_cad = window.open('./localiza?acao=consultar&idlista=8','Filial','top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }
    
    function limparFilial(){
        $("idfilialFreteAvista").value = "0";
        $("fi_abreviatura").value = "";        
    }
    function limparNatureza(){
        $("natureza_cod_desc").value = "";
        $("natureza_desc").value = "";        
        $("natureza_cod").value = "0";            
    }
    
    function habilitarDesabilitaRateio(){        
        var inputRateio = $("idDesabilitaRateioInputs");
        var habilitaDesabilitaRateio = $("idDefinicaoSalarioMotoristaVeiculo").value; 
        var informaRateioExcluidos = $("maxValorDivido").value;
        
        
        if(habilitaDesabilitaRateio == "r"){
            inputRateio.style.display = "";
        
        }else if(habilitaDesabilitaRateio == "m"){
            inputRateio.style.display = "none";
            if(informaRateioExcluidos != 0){
                alert("Atenção! Ao escolher essa opção todos os valores do rateio serão excluídos ao Salvar!");
            }
       
        }
       
    }     
    
    var dataAtualizada = '<%=dataAtual%>';
    function rateioCustoAdministrativo(dataApartir, valorRateio, idRateio){
        this.dataApartir = (dataApartir != undefined) ? dataApartir : dataAtualizada;
        this.valorRateio = (valorRateio != undefined) ? valorRateio : '0.00';
        this.idRateio = (idRateio != undefined) ? idRateio : 0;
    }
    
    var countAddvalor = 0;
    function addRateioCustoAdministrativo(valorRateado) {
        
        if(valorRateado == null || valorRateado == undefined) {
            valorRateado = new rateioCustoAdministrativo();
        }
        
        countAddvalor++;
        
        var _tr0 = Builder.node("tr", {
            id: "trValor_" + countAddvalor,
            name: "trValor_" + countAddvalor,
            className:"celulaZebra2",
            align: "center"
            
        });
        var _td0 = Builder.node("td", {
           width: "2%",
           align: "center"
        });
        
        var _td1 = Builder.node("td", {            
           width:"45%",
           align: "center"
        });
        
        var _td2 = Builder.node("td", {
           width: "45%",
           align: "center"
        }); 
        
        var inputDividir = Builder.node("input",{
            id: "valorDividido_" + countAddvalor,
            name: "valorDividido_" + countAddvalor,
            type: "text",
            value: colocarVirgula(valorRateado.valorRateio,2),
            size: "5",
            className: "fieldMin",
            onchange: "seNaoFloatReset(this,'0.00')", 
            onBlur:"setZero(this);"           
        });
            
        _td1.appendChild(inputDividir);
        
        
        var inputData = Builder.node("input", {
            id: "dataValorDivido_" + countAddvalor,
            name: "dataValorDivido_" + countAddvalor,
            type: "text",
            value: valorRateado.dataApartir,
            size: "11",
            className: "fieldDateMin",
            onblur: "alertInvalidDate(this);",
            onkeypress: "fmtDate(this, event)",
            maxlength: "10"
        }); 
        
        var inputExcluir = Builder.node("input", {
            id: "idRateio_" + countAddvalor,
            name: "idRateio_" + countAddvalor,
            type: "hidden",
            value: valorRateado.idRateio
        });
        
         var _imgExcluir = Builder.node("img", {
            src: "img/lixo.png",
            title: "Excluir Rateio",
            className: "imagemLink",            
            onClick: "excluirRateioCustoAdministrativo("+valorRateado.idRateio+","+countAddvalor+");"
        });
        
        _td0.appendChild(_imgExcluir);
        
        _td2.appendChild(inputExcluir);
        _td2.appendChild(inputData); //atualizando
        
        _tr0.appendChild(_td0);
        _tr0.appendChild(_td1);
        _tr0.appendChild(_td2);
       
        //implementa na tela
        $("idAddRateio").appendChild(_tr0);
        
        $("maxValorDivido").value = countAddvalor;   
        
    }
    
     function enderecoFilialBuonny(id ,idEndereco, logradouro, bairro, cep, cidade, idCidade, numeroLogradouro, uf){
        
        this.id = (id != undefined ? id : 0);
        this.idEndereco = (idEndereco != undefined ? idEndereco : 0);
        this.logradouro = (logradouro != undefined ? logradouro : "");
        this.bairro = (bairro != undefined ? bairro : "");
        this.cep = (cep != undefined ? cep : "");
        this.cidade = (cidade != undefined ? cidade : "");
        this.idCidade = (idCidade != undefined ? idCidade : 0);
        this.numeroLogradouro = (numeroLogradouro != undefined ? numeroLogradouro : 0);
        this.uf = (uf != undefined ? uf : "");
    }
     
    var contEnderecoFilial = 0;    
    function addFilialEndereco(enderecoBuonny){
       
        if (enderecoBuonny ==  null || enderecoBuonny == undefined){
                    enderecoBuonny = new enderecoFilialBuonny();
            }         
                     contEnderecoFilial++;
    
    var tr_0  = Builder.node("tr", {
           id: "trEnderecoBuonny_" + contEnderecoFilial,
            name: "trEnderecoBuonny_" + contEnderecoFilial,
            className:"celulaZebra2",
            align: "center"
           
          });
       
        //TODAS AS TD's
       var tdImagemLixo = Builder.node("td", {
           align: "center" 
       });
       var tdLogradouro = Builder.node("td", {
            align: "center"
       });
       var tdBairro = Builder.node("td", {
            align: "center"
       });
       var tdCep = Builder.node("td", {
            align: "center"
       });
       var tdCidade = Builder.node("td", {
            align: "center"
       });
       var tdNumeroLogra = Builder.node("td", {
           align: "center"
       });       
       
       //TODOS OS INPUT's
       var inputHidIdEnderecoBuonny = Builder.node("input",{
            id: "idEnderecoFilialSaidaBuonny_" + contEnderecoFilial,
            name: "idEnderecoFilialSaidaBuonny_" + contEnderecoFilial,
            type: "hidden",
            value: enderecoBuonny.id
       });
       
       var inputHidIdEndereco = Builder.node("input",{
            id: "idEndereco_" + contEnderecoFilial,
            name: "idEndereco_" + contEnderecoFilial,
            type: "hidden",
            value: enderecoBuonny.idEndereco
       });
        
       var inputLogradouro = Builder.node("input",{
            id: "descricaoLogradouroCidadeBuonny_" + contEnderecoFilial,
            name: "descricaoLogradouroCidadeBuonny_" + contEnderecoFilial,
            type: "text",
            size: "25",
            className: "inputtexto",
            value: enderecoBuonny.logradouro
        });
        
        var inputBairro = Builder.node("input",{
            id: "descricaoBairroCidadeBuonny_" + contEnderecoFilial,
            name: "descricaoBairroCidadeBuonny_" + contEnderecoFilial,
            type: "text",
            size: "20",
            className: "inputtexto",
            value: enderecoBuonny.bairro
        });
        
        var inputCep = Builder.node("input",{
            id: "numeroCepCidadeBuonny_" + contEnderecoFilial,
            name: "numeroCepCidadeBuonny_" + contEnderecoFilial,
            type: "text",
            size: "7",
            maxlength: "9",
            className: "inputtexto",
            OnKeyPress: "formatar(this, '#####-###')",
            value: enderecoBuonny.cep
        });
        
        var inputCidade = Builder.node("input",{
            id: "descricaoCidadeBuonny_" + contEnderecoFilial,
            name: "descricaoCidadeBuonny_" + contEnderecoFilial,
            type: "text",
            size: "15",
            className: "inputReadOnly",
            readonly: "true",
            value: enderecoBuonny.cidade
        });
        var inputHidIdCidade = Builder.node("input",{
            id: "idCidadeBuonny_" + contEnderecoFilial,
            name: "idCidadeBuonny_" + contEnderecoFilial,
            type: "hidden",
            value: enderecoBuonny.idCidade
        });
        var inputNumeroLogra = Builder.node("input", {
            id: "numeroLogradouroCidadeBuonny_" + contEnderecoFilial,
            name: "numeroLogradouroCidadeBuonny_" + contEnderecoFilial,
            type: "text",
            size: "6",
            maxlength: "6",
            className: "inputtexto",
            value: enderecoBuonny.numeroLogradouro
        });
        var inputUF = Builder.node("input", {
            id: "descricaoUFCidadeBuonny_" + contEnderecoFilial,
            name: "descricaoUFCidadeBuonny_" + contEnderecoFilial,
            type: "text",
            size: "2",
            className: "inputReadOnly",
            readonly: "true",
            value: enderecoBuonny.uf
        });
        
        var imagemExcluir = Builder.node("img", {
            src: "img/lixo.png",
            title: "Excluir endereço",
            className: "imagemLink",            
            onClick: "excluirEnderecoBuonny("+enderecoBuonny.id+","+contEnderecoFilial+");"
        });
        
        //INICIO DO BOTÃO DE LOCALIZAR CIDADE
        var pesquisarCidade = Builder.node("input", {
            type: "button",
            className:"botoes",
            id: "botaoCidade_"+contEnderecoFilial,
            name: "botaoCidade_"+contEnderecoFilial,
            onClick:"localizaCidadeBuonny("+contEnderecoFilial+");",
            value: "..."
        });
        
    var borrachaCidade = Builder.node("img" , {
            id: "borrachaCidade" ,
            className:"imagemLink",
            src: "img/borracha.gif",
            onclick:"limparCidadeBuonny("+contEnderecoFilial+");"
        });
        
    // POVOANDO AS TD's
    tdImagemLixo.appendChild(imagemExcluir);
    tdImagemLixo.appendChild(inputHidIdEnderecoBuonny);
    tdLogradouro.appendChild(inputHidIdEndereco);
    tdLogradouro.appendChild(inputLogradouro);
    tdBairro.appendChild(inputBairro);
    tdCep.appendChild(inputCep);    
    tdCidade.appendChild(inputCidade);
    
//    tdNumeroLogra.appendChild(inputExcluir);
    tdNumeroLogra.appendChild(inputNumeroLogra);//atualizando   
    
    tdCidade.appendChild(inputUF);
    tdCidade.appendChild(inputHidIdCidade);
    tdCidade.appendChild(pesquisarCidade);
    tdCidade.appendChild(borrachaCidade);
    
    //POVOANDO AS TR's
    tr_0.appendChild(tdImagemLixo);
    tr_0.appendChild(tdLogradouro);
    tr_0.appendChild(tdCidade);
    tr_0.appendChild(tdBairro);
    tr_0.appendChild(tdCep);
    tr_0.appendChild(tdNumeroLogra);   
    
    //POVOANDO A TABELA
   $("tbEnderecoBuonny").appendChild(tr_0);
    
   //IMPLEMENTA NA TELA
//   $("idAddEndereco").appendChild(tabela);    
   
   $("maxEnderecos").value = contEnderecoFilial;  
    
    // Logradouro, Bairro, cep, cidade.
    
    }
    
    function excluirRateioCustoAdministrativo(idRateio ,excluirIndex){
             
        var excluindo =  "trValor_" + excluirIndex;
       
        if (confirm("Deseja excluir o Rateio?")){
            if (confirm("Tem certeza?")){ 
               Element.remove(excluindo);
               $("maxEnderecos").value = $("maxEnderecos").value-1;
                if(idRateio != 0) {
                    new Ajax.Request("./cadfilial?acao=excluirRateioCustoAdministrativo&idRatear=" + idRateio);
                    alert("Rateio removido com sucesso!");
                    
                    
                }
            }
        }
    }
    
    function carregarTela(){
        var valorDataRateio;
        var enderecoBuonny;
        var cidadesAtendidas;
        
        <%
            if(carregaFi){
                if(cadfi.getFilial().getRateioCustoAdminitrativo().size()>0){
                for (RateioCustoAdministrativo rateio : cadfi.getFilial().getRateioCustoAdminitrativo())
            {
            %>
//                    rateioCustoAdministrativo = new rateioCustoAdministrativo('<%=fmt.format(rateio.getDataPartidaRateio())%>', '<%=rateio.getValorCustoRateio()%>', '<%=rateio.getIdValorData()%>');
                    addRateioCustoAdministrativo(new rateioCustoAdministrativo('<%=fmt.format(rateio.getDataPartidaRateio())%>', '<%=rateio.getValorCustoRateio()%>', '<%=rateio.getIdValorData()%>'));
    
        <%}}}%> 
            
        <%
            if(carregaFi){
                if(cadfi.getFilial().getFilialEnderecoSaidaBuonny().size()>0){
                   for(FilialEnderecoSaidaBuonny buonny : cadfi.getFilial().getFilialEnderecoSaidaBuonny()) 
                //function enderecoFilialBuonny(id ,logradouro, bairro, cep, cidade, idCidade, numeroLogradouro, uf){
                    {%>
                            enderecoBuonny = new enderecoFilialBuonny(<%=buonny.getId()%>,<%=buonny.getEndereco().getId()%>,'<%=buonny.getEndereco().getLograoduro()%>', '<%=buonny.getEndereco().getBairro()%>', 
                            '<%=buonny.getEndereco().getCep()%>','<%= buonny.getEndereco().getCidade().getDescricaoCidade()%>',<%= buonny.getEndereco().getCidade().getIdcidade()%>, 
                            '<%=buonny.getEndereco().getNumeroLogradouro()%>','<%=buonny.getEndereco().getCidade().getUf()%>');
                            addFilialEndereco(enderecoBuonny);
                    
                 
           <%}}}%>
            //Carregar o DOM
                 //Tem que ter a mesma posição de CidadeAtendida(id,idCidade,cidade,uf)
            <%
            if(carregaFi){
                if(cadfi.getFilial().getCidadesAtendidas().size()>0){
                 for(CidadesAtendidas cidade : cadfi.getFilial().getCidadesAtendidas()){%>
                    cidadesAtendidas = new CidadeAtendida();
                    cidadesAtendidas.id = '<%=cidade.getId()%>';
                    cidadesAtendidas.idCidade = '<%=cidade.getCidade().getIdcidade()%>';
                    cidadesAtendidas.cidade = '<%=cidade.getCidade().getDescricaoCidade()%>';
                    cidadesAtendidas.uf = '<%=cidade.getCidade().getUf()%>';
                    
                    addCidadeAtendida(cidadesAtendidas);
                <%}%> 
           <%}}%>  
               
            var idStUtilizacaoBuonnyRoteirizador = $("idStUtilizacaoBuonnyRoteirizador").value;
            if (idStUtilizacaoBuonnyRoteirizador == 'P' || idStUtilizacaoBuonnyRoteirizador == 'H'){
                $("trEnderecoBuonny").style.display = '';
            }else{
                $("trEnderecoBuonny").style.display = 'none';    
            }
            
            <% if (carregaFi) { %>
                   <% for(FilialImpostoFederal imp : cadfi.getFilial().getImpostosFederais()){ %>
                       var imposto = new impostoFederal();
                       imposto.id = '<%= imp.getId() %>';
                       imposto.competencia = "<%= imp.getCompetencia() %>";
                       imposto.ir = '<%= imp.getPercIR() %>';
                       imposto.cssl = '<%= imp.getPercCSSL() %>';
                       imposto.pis = '<%= imp.getPercPIS() %>';
                       imposto.cofins = '<%= imp.getPercCOFINS() %>';
                       imposto.inss = '<%= imp.getPercINSS() %>';
                       
                       addAliquotasImpostosFederais(imposto);
                    <% } %>
            <% } %>
            
            <c:forEach items="${integracoes}" var="integ">
                if ('${integ.tipoServico}' === '1') {
                    $("tipoAmbienteFreteFacil").value = '${integ.ambiente}';
                    if (${integ.isEnvioAutomatico}) {$("isEnvioAutomaticoFreteFacil").checked = '${integ.isEnvioAutomatico}';}
                    $("tokenEnvioFreteFacil").value = '${integ.token}';
                    $("idFreteFacil").value = '${integ.id}';
                }
            </c:forEach>
                var jsonCompleto = {};
                var lista = new Array();
            <c:forEach items="${substitutas}" var="sub" varStatus="stat">
                    var ie = {};
                    ie["id"] = "${sub.id}";
                    ie["insc"] = "${sub.inscEstSubstituta}";
                    ie["uf"] = "${sub.UF}";
                    ie["isExcluido"] = "${sub.isExcluido}";
                    lista.push(ie);
            </c:forEach>
                Object.assign(jsonCompleto, {'listaUf': lista});
                jQuery('#substitutas').val(jQuery.stringify(jsonCompleto));
                
                jQuery("#valorPorSaques").val(colocarVirgula(jQuery("#valorPorSaques").val(),2));
                jQuery("#valorTransf").val(colocarVirgula(jQuery("#valorTransf").val(),2));
            }
            
    
    
    function mostrarEnderecoBuonny(){ //mostra o DOM apenas para algumas opções do SELECT
        var idStUtilizacaoBuonnyRoteirizador = $("idStUtilizacaoBuonnyRoteirizador").value;
            if (idStUtilizacaoBuonnyRoteirizador == 'P' || idStUtilizacaoBuonnyRoteirizador == 'H'){
                $("trEnderecoBuonny").style.display = '';
            }else{
                $("trEnderecoBuonny").style.display = 'none';    
                if($("maxEnderecos").value!=0){
                    alert('Atenção! Ao escolher essa opção todas as informações que não foram salvas serão perdidas!');
                }
        }
    }

    function localizaCidadeBuonny(contEnderecoFilial){ //localiza a cidade
       window.open('./localiza?acao=consultar&idlista=11','FilialCidadeSaida_'+contEnderecoFilial, 'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
        
    
    }
    
    function excluirEnderecoBuonny(idEnderecoFilialSaidaBuonny ,excluirIndex){
             
        var excluindo =  "trEnderecoBuonny_" + excluirIndex;       

        if (confirm("Deseja 'excluir' o endereço de saída da Buonny?")){
            if (confirm("Tem certeza?")){
                if(idEnderecoFilialSaidaBuonny != 0){
                    jQuery.ajax({
                            url: '<c:url value="./cadfilial" />',
                            dataType: "text",
                            method: "post",
                            data: {
                                idEnderecoFilialSaidaBuonny : idEnderecoFilialSaidaBuonny,                        
                                acao : "excluirEnderecoFilialSaidaBuonny"
                            },
                            success: function(data) {
                               if(JSON.parse(data).boolean == false){
                                   alert("Atenção: Endereço da Buonny já foi utilizado, não pode ser excluido!");
                               }else{
                                   Element.remove(excluindo);
                                   alert("Endereço Buonny excluido com sucesso!");                                   
                               }
                            }
                        });
                }else{
                   Element.remove(excluindo);
                   alert("Endereço da Buonny excluido com sucesso!");
                }
            }
        }        
    }
        
        function habilitarCheck(enviarICMS){
            if(enviarICMS.checked){
             $("isAtivarEnvioPercentualICMS").style.display = "";
            }else{
             $("isAtivarEnvioPercentualICMS").style.display = "none";
             $("envioPercentual").checked = false;
            }
        }

        function abrirLocalizaNatureza() {
            launchPopupLocate('./localiza?acao=consultar&idlista=64&fecharJanela=true', 'Natureza')
        }
        function habilitarValorTarifas(){
            if($("controlarTarifasBancarias").checked == true){
                $("valorTarifasSaque").style.display = "";
                $("valorTarifasTransf").style.display = "";
            }else{
                $("valorTarifasSaque").style.display = "none";
                $("valorTarifasTransf").style.display = "none";
            }
        }
        
        function habilitarCodigoAtividadeEconomicaContPrevidenciaria(){
            $("isAddEFDContribuicaoPrevidenciariaT").checked ? visivel($('trCodigoAtividadeContribuicaoPrevidenciaria')) : invisivel($('trCodigoAtividadeContribuicaoPrevidenciaria'));
            
        }
                
        function habilitarGerenciamentoRisco(tipoChamada) {
            display = "none";
            
            if ($("gerenciamentoRiscoId").value != 1) {
                display = "";
            }
            
            $("stUtilizacaoGerenciadoraRisco").style.display = display;
            $("divStUtilizacaoGerenciadoraRisco").style.display = display;
            $("trGerenciadoraRisco").style.display = display;
            $("trGerenciadoraRisco2").style.display = display;
            $("trGerenciadoraRisco3").style.display = display;
            
            if (tipoChamada != 1) {
                // Limpar campos
                $("codigoGerenciadoraRisco").value = "";
                $("senhaGerenciadoraRisco").value = "";
                $("idGerenciadoraRisco").value = "";
                // Precisei usar jQuery ao invés de $ pois o $ não estava dando certo
                // para substituir o campo selecionado para não utiliza.
                jQuery("#stUtilizacaoGerenciadoraRisco").val("0");
            }
        }
        
        function ativarValorMaximo(){
            if($("controleValor").checked == true){
                $("valorMaximo").style.display = "";
                $("labelValorMax").style.display = "";
            }else{
                $("valorMaximo").style.display = "none";
                $("labelValorMax").style.display = "none";
            }
        }
        
        function ativarICMSGO(){
            if($("uf_origemFilial").value == 'GO'){
                $("trIcmsGO").style.display = "";
            }else{
                $("trIcmsGO").style.display = "none";
            }
        }
        
        //Visualizar o DOM com o click do check
        function ativarCidade(){
            
            var informaCidadeExcluidas = $("maxCidades").value;
            
            if($("chkCidade").checked){
                 $("tabelaCidade").style.display = "";
            }else{
                 $("tabelaCidade").style.display = "none";
                 $("tabelaCidade").checked = false;
             if(informaCidadeExcluidas != 0)
                 alert("Atenção! Ao escolher essa opção todos as cidades serão excluídas ao Salvar!");
            }
            
//            $("tabelaCidade").style.display = ($('chkCidade').checked ? "" : "none")
            
        }
        
        //Função que define se a tela de consulta permanece aberto ao escolher uma cidade.
        function localizarCidadeAtendidas(){
            var max = parseFloat($("maxCidades").value);
            var cidadesCadastradas = "";
            for (var i = 1; i <= max; i++) {
                if($("idCidade_"+i) != null){
                    if(cidadesCadastradas == ""){
                        cidadesCadastradas = $("idCidade_"+i).value;
                    }else{
                        cidadesCadastradas = cidadesCadastradas+","+$("idCidade_"+i).value;
                    }
                }
            }
            launchPopupLocate('./localiza?acao=consultar&idlista=11&fecharJanela=false&paramaux3='+cidadesCadastradas,'Cidade_Atendidas');
        }
        
        //Cria um objeto com valores (id,idCidade,cidade,uf)
        function CidadeAtendida(id,idCidade,cidade,uf){
            
            this.id = (id != undefined  || id != null ? id : 0);
            this.idCidade = (idCidade != undefined  || idCidade != null ? idCidade : "");            
            this.cidade = (cidade != undefined || cidade != null ? cidade : 0);
            this.uf = (uf != undefined  || uf != null ? uf : "");            
        
        }
        
        //Add em cada linha as informações no DOM
        var countCidade = 0;
        function addCidadeAtendida(cidadeAtendida){
            if(cidadeAtendida == undefined || cidadeAtendida == null){
                cidadeAtendida = new CidadeAtendida();
            }  
            countCidade++;
            
            var table = $("tbodyCidade");
            
            //Linha em zebra
            var classe = ((countCidade % 2) == 0 ? 'CelulaZebra2' : 'CelulaZebra1');
            
            //Estrutura do DOM _tr e _td
            var _trCidade = Builder.node("tr",{
               id:"cidade_"+countCidade, 
               name:"cidade_"+countCidade,
               className:classe
            });
            
           
            var _imagemExcluir = Builder.node("img", {
                src: "img/lixo.png",
                title: "Excluir endereço",
                className: "imagemLink",            
                onClick: "excluirCidade("+cidadeAtendida.id+","+countCidade+");"
            });
            
            var _tdDescricao = Builder.node("td",{
               id:"descricao_"+countCidade, 
               name:"descricao_"+countCidade
            });
            
            var _tdUf = Builder.node("td",{
               id:"uf_"+countCidade, 
               name:"uf_"+countCidade
               
            });
            
            var _tdExcluir = Builder.node("td",{
               id:"excluir_"+countCidade, 
               name:"excluir_"+countCidade,
               align: "center"
            });
            //Recebendo valores e adicionando em _td
            var _lblCidade = Builder.node("label",{
                id: "descricaoCidade_" + countCidade,
                name: "descricaoCidade_" + countCidade
            });
            _lblCidade.innerHTML = cidadeAtendida.cidade;
            
            var _lblUF = Builder.node("label",{
                id: "descricaoUf_" + countCidade,
                name: "descricaoUf_" + countCidade,
            });
            _lblUF.innerHTML = cidadeAtendida.uf;
            
            var _inpIdCidade = Builder.node("input",{
                id:"idCidade_"+countCidade,
                name:"idCidade_"+countCidade,
                type:"hidden",
                value:cidadeAtendida.idCidade
            });
            
            var _inpIdFilialCidade = Builder.node("input",{
                id:"idFilialCidadeAtendida_"+countCidade,
                name:"idFilialCidadeAtendida_"+countCidade,
                type:"hidden",
                value:cidadeAtendida.id
            });
            
             var _tdAdd = Builder.node("td",{
               id:"add_"+countCidade, 
               name:"add_"+countCidade
            });
            
             var _tdAddd = Builder.node("td",{
               id:"add_"+countCidade, 
               name:"add_"+countCidade
            });
            
             var _tdAdddd = Builder.node("td",{
               id:"add_"+countCidade, 
               name:"add_"+countCidade
            });
             
            
            _tdExcluir.appendChild(_imagemExcluir);
            _tdDescricao.appendChild(_lblCidade);
            _tdUf.appendChild(_lblUF);
            _tdDescricao.appendChild(_inpIdCidade);
            _tdDescricao.appendChild(_inpIdFilialCidade);
            
            //
            _trCidade.appendChild(_tdExcluir);
            _trCidade.appendChild(_tdDescricao);
            _trCidade.appendChild(_tdUf);
            _trCidade.appendChild(_tdAdd);
            _trCidade.appendChild(_tdAddd);
            _trCidade.appendChild(_tdAdddd);
           
            table.appendChild(_trCidade);
            
            $("maxCidades").value = countCidade;  


        }
         
        function excluirCidade(idCidade ,excluirIndex){
             
            var excluindo =  "cidade_" + excluirIndex;       

            if (confirm("Deseja 'excluir' a Cidade?")){
                if (confirm("Tem certeza?")){
                    if(idCidade != 0){
                        jQuery.ajax({
                                url: '<c:url value="./cadfilial" />',
                                dataType: "text",
                                method: "post",
                                data: {
                                    idCidade : idCidade,                        
                                    acao : "excluirCidadeSaida"
                                },
                                success: function(data) {
                                   if(JSON.parse(data).boolean == false){
                                       alert("Atenção: Cidade já foi utilizado, não pode ser excluido!");
                                   }else{
                                       Element.remove(excluindo);
                                       alert("Cidade excluido com sucesso!");                                   
                                   }
                                }
                            });
                    }else{
                       Element.remove(excluindo);
                       alert("Cidade excluido com sucesso!");
                    }
                }
            }        
        }
        
        function consultaCidadePorUF(uf){
        
                 var consultar =  "uf_";   
                        if(uf != ""){
                            jQuery.ajax({
                                    url: '<c:url value="./cadfilial" />',
                                    dataType: "text",
                                    method: "post",
                                    data: {
                                        uf : uf,                        
                                        acao : "localizarCidadesPorUF"
                                    },
                                    success: function(data) {
                                        
                                        var lista = jQuery.parseJSON(data);
                                        var listaUF = lista.list[0];
                                        // se o campo de cidade.BeanCidade for nulo, pegar diretamente de cidade.
                                        var UF = (listaUF["cidade.BeanCidade"] === null  || listaUF["cidade.BeanCidade"] === undefined ?  listaUF.cidade : listaUF["cidade.BeanCidade"]);
                                        var mUf;
                                        
                                        var length = (UF != undefined && UF.length != undefined ? UF.length : 1);
                                        var cidade;
                                        if (length > 1) {
                                            for (var i = 0; i < length; i++) {
                                                    
                                                        mUf = UF[i];
                                                        var idCidade = mUf.idcidade;
                                                        var cidadeDesc = mUf.descricaoCidade;
                                                        var existe = true;
                                                        existe = consultarCidades(idCidade, cidadeDesc);
                                                        
                                                        if(existe == true){
                                                            
                                                                cidade = new CidadeAtendida();
                                                                cidade.idCidade = idCidade;
                                                                cidade.cidade = cidadeDesc;
                                                                cidade.uf = mUf.uf;
                                                                addCidadeAtendida(cidade);
                                                        }
                                                    
                                                }
                                        }                                        
                                       
                                       
                                       
                                    }
                                });
                        }else{
                        alert("Informe uma UF valida")
                        }  
          }

        function consultarCidades(idCidade, cidade){
            var maxCidades = $("maxCidades").value;
            for (var qtdCid = 1; qtdCid <= maxCidades; qtdCid++) {
                if(idCidade == $("idCidade_"+qtdCid).value){
                    alert("Atenção: A Cidade " + cidade + " já foi adicionada");
                    return false;                    
                }
                    break;
            }
            return true;
        
        }
       
    function CamposRepom(idCodigo, codigoRepom, descricao, campoView){                            
        this.idCodigo = (idCodigo != undefined ? idCodigo : 0);
        this.codigoRepom = (codigoRepom != undefined ? codigoRepom : "");
        this.descricao = (descricao != undefined ? descricao : "");       
        this.campoView = (campoView != undefined ? campoView : "");       
    }
    
    var idCC = 0;      
    var listaCampoXml = new Array();    
    <%for (Coluna col : colunas) {%>
        listaCampoXml[++idCC] = new Option("<%=col.getNome()%>", "<%=col.getNomeFormatado()%>");          
    <% } %>
        
    var countCodigo = 0;
    function addCodigoMovimentoRepom(campo){
        countCodigo++;
       var lista = listaCampoXml;
        if(campo == null || campo == undefined){
            campo = new CamposRepom();
        }
        var td0_ = Builder.node("TD",{ align: "center"});
        var td1_ = Builder.node("TD",{ align: "center"});
        var td2_ = Builder.node("TD",{ align: "center"});
        var td3_ = Builder.node("TD",{ align: "center"});
       
        //campos
        var hid1_ = Builder.node("INPUT",{type:"hidden",id:"idCodigo_"+countCodigo,name:"idCodigo_"+countCodigo,value: campo.idCodigo});
        // Descricao 
        var inp1_ = Builder.node("INPUT",{type:"text",id:"codigo_"+countCodigo,name:"codigo_"+countCodigo,value: campo.codigoRepom,size: "15" ,maxlength: "20" ,className:"inputtexto"});             
        var inp2_ = Builder.node("INPUT",{type:"text",id:"descricao_"+countCodigo,name:"descricao_"+countCodigo,value: campo.descricao,size: "15" ,maxlength: "20" ,className:"inputtexto"}); 
        
        var inp3_= null;
        var _slc = Builder.node("select",{id:"campoView_"+countCodigo, name:"campoView_"+countCodigo, className: "fieldMin"});
        _slc.style.width="95%";
        
       
        var _img0 = Builder.node("IMG",{src:"img/lixo.png",onClick:"removerItem("+countCodigo+");"});               
        td0_.appendChild(_img0);
        td1_.appendChild(hid1_);
        td1_.appendChild(inp1_);  
        td2_.appendChild(inp2_);               
        td3_.appendChild(_slc);               
        var tr1_ = Builder.node("TR",{className:"CelulaZebra2",id:"trCodigo_"+countCodigo, name:"trCodigo_"+countCodigo});tr1_.appendChild(td0_);
        tr1_.appendChild(td1_);
        tr1_.appendChild(td2_);       
        tr1_.appendChild(td3_);       
        $("tbCodigo").appendChild(tr1_);
        $("maxCodigo").value = countCodigo;
        povoarSelect(_slc, lista);
        
        if(campo.campoView!=null && campo.campoView!=""){               
                _slc.value = campo.campoView;
        }
    }
    
    
    function removerItem(index){  
            try {
                var idCodigo = $("idCodigo_"+index).value; 
                var descricao = ($("descricao_"+index).value);
                if(idCodigo==0){
                     Element.remove("trCodigo_"+index);
                }else{
                        if(confirm("Deseja excluir o campo '"+descricao+"'?")){
                            if(confirm("Tem certeza?")){              
                                new Ajax.Request("./jspcadfilial.jsp?acao=removerCodigosRepom&idCodigo="+idCodigo,{method:'get',
                                    onSuccess: function(){ Element.remove("trCodigo_"+index); alert('Código removido com sucesso!')},
                                    onFailure: function(){alert('Something went wrong...') }});     
                            }
                        }
                }
            } catch (e) { 
                alert(e);
            }
    }
        
        function getTR(classe){
            return jQuery("<tr class='CelulaZebra2NoAlign' style='align: center'>");
        }
        
        function getTD(width, classe){
            return jQuery("<td width='"+width+"'>");
        }
        
    function addAliquotasImpostosFederais(imposto) {
        if (imposto == null || imposto == undefined) {
            imposto = new impostoFederal();   
        }
    
        var max = jQuery("#maxAliquotaImpostoFederal");
        var indiceAliquotaImpostoFederal = max.val();
        var table = jQuery("#tableAliquotasImpostosFederais").find('tbody');
        
        var tr = getTR()
            .append(jQuery("<td width='5%'>").append("<img src='img/lixo.png' onclick='removerAliquotaImpostoFederal(\""+indiceAliquotaImpostoFederal+"\")'>")
                                .append("<input type='hidden' value='"+imposto.id+"' id='id_"+indiceAliquotaImpostoFederal+"' name='id_"+indiceAliquotaImpostoFederal+"'>"))
            .append(getTD("15%").append("<input type='text' onKeyPress='mascaraCompetencia(this);' value='"+imposto.competencia+"' id='competencia_"+indiceAliquotaImpostoFederal+"' name='competencia_"+indiceAliquotaImpostoFederal+"' size='12' maxlength='7' class='fieldMin'>"))
            .append(getTD("15%").append("<input type='text' onChange='seNaoFloatReset(this,\"0.00\")' value='"+imposto.ir+"' id='ir_"+indiceAliquotaImpostoFederal+"'  name='ir_"+indiceAliquotaImpostoFederal+"' size='12' maxlength='8' class='fieldMin'>"))
            .append(getTD("15%").append("<input type='text' onChange='seNaoFloatReset(this,\"0.00\")' value='"+imposto.cssl+"' id='cssl_"+indiceAliquotaImpostoFederal+"' name='cssl_"+indiceAliquotaImpostoFederal+"' size='12' maxlength='8' class='fieldMin'>"))
            .append(getTD("15%").append("<input type='text' onChange='seNaoFloatReset(this,\"0.00\")' value='"+imposto.pis+"' id='pis_"+indiceAliquotaImpostoFederal+"' name='pis_"+indiceAliquotaImpostoFederal+"' size='12' maxlength='8' class='fieldMin'>"))
            .append(getTD("15%").append("<input type='text' onChange='seNaoFloatReset(this,\"0.00\")' value='"+imposto.cofins+"' id='cofins_"+indiceAliquotaImpostoFederal+"' name='cofins_"+indiceAliquotaImpostoFederal+"' size='12' maxlength='8' class='fieldMin'>"))
            .append(getTD("15%").append("<input type='text' onChange='seNaoFloatReset(this,\"0.00\")' value='"+imposto.inss+"' id='inss_"+indiceAliquotaImpostoFederal+"' name='inss_"+indiceAliquotaImpostoFederal+"' size='12' maxlength='8' class='fieldMin'>"));
        
        table.append(tr);
        max.val(parseInt(max.val()) + 1);
    }
    
    function impostoFederal(id, competencia, ir, cssl, pis, cofins, inss){
        this.id = (id != undefined ? id : 0);
        this.competencia = (competencia != undefined ? competencia : "");
        this.ir = (ir != undefined ? ir : "0,00");
        this.cssl = (cssl != undefined ? cssl : "0,00");
        this.pis = (pis != undefined ? pis : "0,00");
        this.cofins = (cofins != undefined ? cofins : "0,00");
        this.inss = (inss != undefined ? inss : "0,00");
    }
    
    function removerAliquotaImpostoFederal(indice){
        var id = jQuery("#id_"+indice);
        if (confirm("Deseja excluir o imposto ?")) {
            jQuery.ajax({
                url: '<c:url value="./cadfilial" />',
                dataType: "text",
                method: "post",
                data: {
                    acao : "removeImposto",
                    idfilialAtual : id.val()
                },
                success: function(data) {
                    alert("Imposto removido com sucesso.");
                    jQuery(id.parents("tr")[0]).remove();
                }
            });
        }
    }
    
    function deixarAbaGerencialVisivel(){
        var tipoTributacao = jQuery("#tipoTributacao").val();
        if (tipoTributacao == 'lr') {
            jQuery("#domImpostosFederais").show();
            jQuery("#tituloImpostosFederais").show();
        }else{
            jQuery("#domImpostosFederais").hide();
            jQuery("#tituloImpostosFederais").hide();
        }
    }
    
    function Cron(id, cronExpressao) {
        this.id = (id == null || id == undefined ? 0 : id);
        this.cronExpressao = (cronExpressao == null || cronExpressao == undefined ? "" : cronExpressao);
    }

    function addCron(tipo, cron) {
        try {
            cron = (cron == null || cron == undefined ? new Cron() : cron);
            var countCron = parseFloat($("maxCronCte").value) + 1;
            var classe = (countCron % 2 == 0 ? 'CelulaZebra2' : 'CelulaZebra1');
            var sufixo = "_" +tipo+ "_" + countCron;
            var _labelCron = Builder.node("label", "Momento:");
            var _labelExplicacao = Builder.node("label", "O momento esta apresentado em forma de expressão cron, para visualizar e/ou informar clique no botão ao lado");
            var _br = Builder.node("br");
            var _tr = Builder.node("tr", {id: "trCron" + sufixo, name:"trCron", className: classe});
            var _tdDesc = Builder.node("td", {id: "tdCronDesc" + sufixo, className: classe, width: "20%", align: "rigth"});
            var _tdValor = Builder.node("td", {id: "tdCronValor" + sufixo, className: classe, width: "70%"});
            var _tdLixo = Builder.node("td", {id: "tdCronValor" + sufixo, className: classe, width: "10%", align: "center"});
            var _imgLixo = Builder.node('IMG', {src: 'img/lixo.png', title: 'Apagar Momento', className: 'imagemLink', onClick: "removerCron('" + tipo + "','" + countCron + "');"});
            var _idLayout = Builder.node('input', {type: "hidden", id: "idCron" + sufixo, name: "idCron" + sufixo, value: cron.id});
            var _isRemoverCron = Builder.node('input', {type: "hidden", id: "removerCron" + sufixo, name: "removerCron" + sufixo, value: 'false'});
            var _inpCron = Builder.node('input', {type: "text", size: "10", id: "cron" + sufixo, className: "fieldMin", name: "cron" + sufixo, value: cron.cronExpressao});
            readOnly(_inpCron, "inputReadOnly8pt");
            var _btLocalizarCron = Builder.node('input', {type: "button", id: "btCron" + sufixo, onClick: "abrirLocalizarCron('" + _inpCron.id + "')", className: "inputBotaoMin", value: "..."});
            _tdDesc.appendChild(_labelCron);
            _tdValor.appendChild(_inpCron);
            _tdValor.appendChild(_idLayout);
            _tdValor.appendChild(_isRemoverCron);
            _tdValor.appendChild(_btLocalizarCron);
            _tdValor.appendChild(_br);
            _tdValor.appendChild(_labelExplicacao);
            _tdLixo.appendChild(_imgLixo);
            _tr.appendChild(_tdLixo);
            _tr.appendChild(_tdDesc);
            _tr.appendChild(_tdValor);
            if(tipo == "cte"){
                $("bodyCron").appendChild(_tr);
            }else{
                $("bodyCronNfe").appendChild(_tr);
            }
            $("maxCronCte").value = countCron;
        } catch (e) {
            console.log(e);
        }
    }
    
    function removerCron(tipo, countCron){
        try {
            var sufixo = "_"+tipo+"_"+countCron;
            if(confirm("Deseja excluir o momento do layout ?")){
                if(confirm("Tem certeza?")){
                    $("trCron"+sufixo).style.display="none";
                    $("removerCron"+sufixo).value = 'true';
                }
            }
        } catch (e) {console.log(e);}
    }
    
    function abrirLocalizarCron(elementoId) {
    try {
        tryRequestToServer(function () {
            abrirJanela("AgendamentoTarefasCrontrolador?acao=localizarCron"
                    + "&elemento=" + elementoId, "locCron", 50, 30);
        });
    } catch (e) {
        alert(e);
    }
}
jQuery(document).ready(function(){
    // IFRAME IE SUBSTITUTA
    setTimeout(function () {
        jQuery(jQuery('.frameIeSubstituta')[0]).html('<iframe id="ieSubstituta" name="ieSubstituta" src="./iframe_inscri_estadual_subistituta.jsp?nomeusuario=${autenticado.nome}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
    }, 1);
    jQuery('.btn-frame-substituta').click(function(){
        if(jQuery('.frameIeSubstituta').is(':visible') == false) {
            jQuery('.bloqueio-tela').show();
            window.top.frames['ieSubstituta'].montaFrame();
            jQuery('.frameIeSubstituta').show(250);
        }
    });
    
    // CARREGAR HORARIO VERAO
    jQuery("#isAtivarHoraVerao").prop("checked", <%= (carregaFi ? fi.isIsAtivarHoraVerao() : false) %>);
});

function esconderBloqTela(){
    jQuery('.bloqueio-tela').hide();
}

function pegarAsCoisas(){
    return jQuery('#substitutas').val();
}

function fechaFrameSubstituta() {
    jQuery('.frameIeSubstituta').hide(250);
    jQuery(jQuery('.frameIeSubstituta')[0]).html('');
    criaIframe();
}
function recebeSubstitutas(lista) {
    jQuery('#substitutas').val(lista);
}

function getSubstitutasFilial() {
    return (jQuery('#substitutas').val() ? jQuery('#substitutas').val() : null);
}

function criaIframe() {
    setTimeout(function () {
        jQuery(jQuery('.frameIeSubstituta')[0]).html('<iframe id="ieSubstituta" name="ieSubstituta" src="./iframe_inscri_estadual_subistituta.jsp?nomeusuario=${autenticado.nome}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
    }, 1);
}

    function habilitarFusionTrak(tipoChamada) {
        var display = "none";

        if ($("idStUtilizacaoFusionTrakRoteirizador").value != 'N') {
            display = "";
        }

        $("trLoginRoteirizador").style.display = display;

        if (tipoChamada != 1) {
            // Limpar campos se status for não utiliza
            if ($("idStUtilizacaoFusionTrakRoteirizador").value == 'N') {
                $("loginRoteirizador").value = "";
                $("senhaRoteirizador").value = "";
            }
        }
    }
    
     function desabilitarInclusaoManifesto(){
        
            if($("checTravaManifesto").checked){
                $("diasTravaManifesto").readOnly = false;
            }else {
                $("diasTravaManifesto").readOnly = true; 
                $("diasTravaManifesto").value="";
            }  
        }
    

            
    function somenteNumeros(num) {
        var er = /[^0-9.]/;
        er.lastIndex = 0;
        var campo = num;
        if (er.test(campo.value)) {
          campo.value = "";
        }
    }

    function alteraSeguradoraMDFe() {
        var valor = $("transmitirSeguradoraMDFe").checked;
        
        if (valor == true || valor == "on") {
            $("transmitirAutoMDFe2").style.display = "";
            $("transmitirAutoMDFe").style.display = "";
        } else {
            $("transmitirAutoMDFe2").style.display = "none";
            $("transmitirAutoMDFe").style.display = "none";
        }
       
    }
    
    function utilizaLoginSenhaEfrete() {
        var valor = $("isUtilizaLoginEfrete").checked;
         if (valor == true || valor == "on") {
            $("tdLoginEfrete").style.display = "";
            $("tdSenhaEfrete").style.display = "";
        } else {
            $("tdLoginEfrete").style.display = "none";
            $("tdSenhaEfrete").style.display = "none";
        }
        
    }
</script>
<html>
    <head>
        <script language="javascript" src="script/funcoes.js" type="text/javascript"></script>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">
        <META HTTP-EQUIV="Page-Enter" CONTENT = "RevealTrans (Duration=1, Transition=12)">

        <title>WebTrans - Cadastro de Filiais</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style1 {font-size: 10px}
            -->
        </style>
    </head>
    <body onLoad="javascript:atribuicombos();document.getElementById('rzs').focus();AlternarAbasGenerico('tdIntFiscal','tab1');infoFsda();
        habilitarDesabilitaRateio(); carregarTela();habilitarGerenciamentoRisco(1);habilitarCodigoAtividadeEconomicaContPrevidenciaria();ativarCidade();ativarValorMaximo();ativarICMSGO();
        deixarAbaGerencialVisivel();habilitarFusionTrak(1);">
        <form action="Request" method="post" id="formImg" target="pop"  name="formImg" >
        
        <input type="hidden" id="idcidadeorigem" name="idcidadeorigem" value="">
        <input name="cid_origem" type="hidden" id="cid_origem" class="inputReadOnly" readonly value="" size="27" maxlength="35">
        <input name="uf_origem" type="hidden" class="inputReadOnly" id="uf_origem" size="2" readonly value="">
        
        <input type="hidden" id="idconta" name="idconta" >
        <input type="hidden" id="descricao" name="descricao" >
        <input type="hidden" id="maxCronCte" name="maxCronCte" value="0" >
        <input type="hidden" id="idfilialAtual" name="idfilialAtual" value="<%=(carregaFi ? fi.getIdfilial() : 0)%>"/>
        <input type="hidden" id="idfilial" name="idfilial" value="0"/>
        
        <input id="maxCodigo" name="maxCodigo" value="0" type="hidden" />
        
        <!--<input type="hidden" id="maxValorDivido" name="maxValorDivido" value="0"/>-->
        
        
        <img src="img/banner.gif">
        <br>
        <table width="75%" align="center" class="bordaFina" >
            <tr>
                <td width="613">
                    <div align="left">
                        <b>Cadastro de Filial</b>
                    </div>
                </td>
                <% if ((acao.equals("editar")) && (nivelUser >= 4) && (request.getParameter("ex") == null)) //se o paramentro vier com valor entao nao pode excluir
                    {%>
                <td width="15">
                    <input name="excluir" type="button" class="botoes" id="excluir" value="Excluir" onClick="javascript:excluirfilial(<%=(carregaFi ? fi.getIdfilial() : 0)%>)">
                </td>
                <%}%>
                <td width="56">
                    <input name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:voltar();">
                </td>
            </tr>
        </table>
        <br>
        <table width="75%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
            <tr class="tabela">
                <td colspan="4" align="center">Dados Principais</td>
            </tr>
            <div class="frameIeSubstituta">
            </div>
            <tr>
                <td width="15%" class="TextoCampos">*Raz&atilde;o Social/C&oacute;digo:</td>
                <td colspan="3" class="CelulaZebra2"> 
                    <input name="rzs" type="text" id="rzs" value="<%=(carregaFi ? fi.getRazaosocial() : "")%>" size="50" maxlength="50" class="inputtexto"> 
                    
                    <input onload="concatFieldValue();" name="codigofilial" type="text" id="codigofilial" value="<%=(carregaFi ? fi.getCodigoFilial() : "")%>" size="3" maxlength="2" class="inputtexto">
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">*Abreviatura:</td>
                <td colspan="3" class="CelulaZebra2">
                    <input name="abrev" type="text" id="abrev" value="<%=(carregaFi ? fi.getAbreviatura() : "")%>" size="22" maxlength="12" class="inputtexto">
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Endere&ccedil;o</td>
                <td colspan="3" class="CelulaZebra2"> 
                    <input name="en" type="text" id="en" value="<%=(carregaFi ? fi.getEndereco() : "")%>" size="70" maxlength="70" class="inputtexto">
                    <input onload="concatFieldValue();" name="numero" type="text" id="numero" value="<%=(carregaFi ? fi.getNumero() : "")%>" size="5" maxlength="5" class="inputtexto">
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Bairro:</td>
                <td width="40%" class="CelulaZebra2">
                    <input name="bairro" type="text" id="bairro" value="<%=(carregaFi ? fi.getBairro() : "")%>" size="25" maxlength="25" class="inputtexto">
                </td>
                <td width="10%" class="TextoCampos">CEP:</td>
                <td width="30%" class="CelulaZebra2">
                    <input name="cep" type="text" id="cep" value="<%=(carregaFi ? fi.getCep() : "")%>" size="9" maxlength="9" class="inputtexto" onkeypress="formatar(this, '#####-###');">
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Cidade/UF:</td>
                <td class="CelulaZebra2">
                    <input name="cid_origemFilial" type="text" id="cid_origemFilial" class="inputReadOnly" readonly value="<%=(carregaFi ? fi.getCidade().getDescricaoCidade() : "")%>" size="28" maxlength="35">
                    <input type="hidden" id="idcidadeorigemFilial" name="idcidadeorigemFilial" value="<%=(carregaFi ? fi.getCidade().getIdcidade() : 0)%>">
                    <input name="uf_origemFilial" type="text" class="inputReadOnly" id="uf_origemFilial" size="2" readonly value="<%=(carregaFi ? fi.getCidade().getUf() : "")%>">
                    <input name="button" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=11','Cidade')" value="...">
                    <img src="img/borracha.gif" align="absbottom" class="imagemLink" title="Limpar Cidade" onClick="getObj('cid_origemFilial').value='';getObj('uf_origemFilial').value='';getObj('idcidadeorigemFilial').value='0';">
                </td>
                <td class="TextoCampos">Telefone:</td>
                <td class="CelulaZebra2">
                    <input name="fone" type="text" id="fone" size="13" value="<%=(carregaFi ? fi.getFone() : "")%>" maxlength="13" class="inputtexto">
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Web Site:</td>
                <td class="CelulaZebra2" colspan="2">
                    <input name="site" type="text" id="site" value="<%=(carregaFi ? fi.getSite() : "")%>" size="50" maxlength="50" class="inputtexto">
                </td>
                <!--<td class="TextoCampos">&nbsp;</td>-->
                <td class="CelulaZebra2">&nbsp;</td>
            </tr>
            <tr>
                <td class="TextoCampos">*CNPJ:</td>
                <td class="CelulaZebra2">
                    <input name="cnpj" type="text" id="cnpj" onKeyPress="javascript:digitaCnpj();" maxlength="18" size="22" class="inputtexto">
                </td>
                <td class="TextoCampos">Inscr. Est.:</td>
                <td class="CelulaZebra2">
                    <input onload="concatFieldValue();" name="inscest" type="text" id="inscest" value="<%=(carregaFi ? fi.getInscest() : "")%>"  size="22" maxlength="20" class="inputtexto">
                    <input type="button" class="btn-frame-substituta botoes" value="IE Substituta" />
                    <input name="substitutas" type="hidden" id="substitutas" size="22" maxlength="20" class="inputtexto">
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Inscr. Municipal:</td>
                <td class="CelulaZebra2">
                    <input onload="concatFieldValue();" name="inscmun" type="text" id="inscmun" value="<%=(carregaFi ? fi.getInscmun() : "")%>" size="22" maxlength="20" class="inputtexto" />
                </td>
                <td class="TextoCampos"></td>
                <td class="CelulaZebra2"></td>
            </tr>
        </table>
                <div id="ieSubst" name="ieSubst">
                  <!-- <tbody id="tbIeSubst"></tbody> 
                  <iframe id="iframeieSubst" name="iframeieSubst" src="" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" >
                  </iframe>-->
                </div>        
                <table width="75%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
            
                <td>
            <table width="90%">
                
            <tr>
                <td id="tdIntFiscal" class="menu-sel" onclick="AlternarAbasGenerico('tdIntFiscal', 'tab1')"> Informações Fiscais</td>
                <td id="tdOperacional" class="menu" onclick="AlternarAbasGenerico('tdOperacional', 'tab2')"> Operacional</td>
                <td id="tdFinanceiro" class="menu" onclick="AlternarAbasGenerico('tdFinanceiro', 'tab7')"> Financeiro</td>
                <td id="tdIntegracoes" class="menu" onclick="AlternarAbasGenerico('tdIntegracoes', 'tab3')"> Integrações</td>
                <td id="tdGerencial" class="menu" onclick="AlternarAbasGenerico('tdGerencial', 'tab4')"> Gerencial</td>
                <td id="tdConfigGerais" class="menu" onclick="AlternarAbasGenerico('tdConfigGerais', 'tab8')"> Configurações Gerais</td>
                <td id="tdPermissoes" class="menu" onclick="AlternarAbasGenerico('tdPermissoes', 'tab5')"> Permissões</td>
                <td id="tdAuditoria" class="menu" <%=nivelUser != 4 ? "style='display: none'" : ""%> onclick="AlternarAbasGenerico('tdAuditoria', 'tab6')"> Auditoria</td>
            </tr>
            </table>
                </td>
             
    </table>
            <div id="tab2" style="">
                <table width="75%" align="center" class="bordaFina">
                    <tr class="tabela"/>            
            <tr>
                <td colspan="4" class="tabela">
                    <div align="center">Dados para Impress&atilde;o </div>
                </td>
            </tr>
            <tr>
                <td class="TextoCampos" >Impressora: </td>
                <td class="CelulaZebra2">      
                    <select name="caminho_impressora" id="caminho_impressora" class="inputtexto" onload="concatFieldValue();">
                        <option value="">&nbsp;&nbsp;</option>
                        <%BeanConsultaImpressora impressoras = new BeanConsultaImpressora();
                            impressoras.setConexao(Apoio.getUsuario(request).getConexao());
                            if (impressoras.Consultar()) {
                                ResultSet rs = impressoras.getResultado();
                                while (rs.next()) {%>
                        <option value="<%=rs.getString("descricao")%>" <%=(carregaFi && rs.getString("descricao").equals(fi.getCaminhoImpressora()) ? "selected" : "")%>><%=rs.getString("descricao")%></option>
                        <%}%>
                        <%}%>
                    </select>
                </td>


                <td class="TextoCampos" colspan="0">Driver CTRC : </td>
                <td class="CelulaZebra2" colspan="0">
                    <select name="driverPadraoImpressora" id="driverPadraoImpressora" class="inputtexto" onload="concatFieldValue();">
                        <option value="">&nbsp;&nbsp;</option>
                        <% java.util.Vector drivers = Apoio.listFiles(Apoio.getDirDrivers(request), "ctrc.txt");
                            for (int i = 0; i < drivers.size(); ++i) {
                                String driv = (String) drivers.get(i);
                                driv = driv.substring(0, driv.lastIndexOf("."));
                        %>
                        <option value="<%=driv%>"><%=driv%>&nbsp;</option>
                        <%}%>
                    </select>
                </td>
            <tr>
                <td class="TextoCampos" >Modelo DACTE: </td>
                <td class="CelulaZebra2">      
                    <select name="modeloDacte" id="modeloDacte" class="inputtexto">
                        <option value="1">Modelo 1 (Rodoviário)</option>
                        <option value="2">Modelo 2 (Rodoviário)</option>
                        <option value="3">Modelo 3 (Aéreo)</option>
                        <option value="4">Modelo 4 (Aquaviário)</option>
                        <option value="5">Modelo 5 (Rodoviário)</option>
                        <option value="6">Modelo 6 (Rodoviário)</option>
                        <option value="7">Modelo 7 (Rodoviário Meia Folha)</option>
                        <option value="8" >Modelo 8 (Redespacho)</option>
                        <option value="9" >Modelo 9 (Rodoviário 3.00)</option>
                        <option value="10" >Modelo 10 (Aéreo 3.00)</option>
                        <option value="11" >Modelo 11 (Aquaviário 3.00)</option>
                        <option value="12" >Modelo 12 (Multimodal 3.00)</option>
                        <option value="13" >Modelo 13 (Rodoviário QR Code)</option>
                        <option value="14" >Modelo 14 (Aéreo QR Code)</option>
                        <option value="15" >Modelo 15 (Aquaviário QR Code)</option>

                        <% int contador = 3;
                             for (String rel : Apoio.listDacte(request)) {%>
                        <option value="personalizado_<%=rel%>" >Modelo <%=rel.toUpperCase()%> (Personalizado)</option>
                        <%}%>
                    </select>
                </td>
                <td class="TextoCampos" >Modelo DAMDF-e:</td>
                <td class="CelulaZebra2"> 
                    <select name="modelo-mdfe" id="modelo-mdfe" class="inputtexto">
                        <option value="1">DAMDF-e</option>
                        <option value="2" selected>DAMDF-e (Rodoviário)</option>
                        <option value="3">DAMDF-e (Aéreo)</option>
                        <option value="4">DAMDF-e (Aquaviário)</option>
                    </select>
                </td>
            </tr>
            <td colspan="4" class="tabela">
                    <div align="center">Informa&ccedil;&otilde;es Operacionais </div>
                </td>        
        </tr>
        <tr>
            <td colspan="4">
                <table class="bordaFina" width="100%">
                    <tr>
                        <td width="50%" align="center" class="TextoCampos">
                            <div align="left">
                                <input type="checkbox" name="deduzirPedagio" id="deduzirPedagio" <%=(carregaFi && fi.isDeduzirPedagioIcms() ? "checked" : "")%>>
                                Deduzir Valor do Ped&aacute;gio na Base de C&aacute;lculo do ICMS ao Lan&ccedil;ar um CTRC.
                            </div>
                        </td>
                        <td width="50%" align="center" class="TextoCampos" colspan="2">
                            <div align="left">
                                <input type="checkbox" name="geraSequenciaCtrc" id="geraSequenciaCtrc" <%=(carregaFi ? (fi.isGeraSequenciaCtrcManifesto() ? "checked" : "") : "checked")%>>
                                Gerar Sequ&ecirc;ncia de Numera&ccedil;&atilde;o ao Incluir um CT/Manifesto.
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td width="50%" align="center" class="TextoCampos">
                            <div align="left">
                                <input type="checkbox" name="sequenciaMultiModal" id="sequenciaMultiModal" <%=(carregaFi && fi.isSequenciaCtMultiModal() ? "checked" : "")%>>
                                Gerar Sequ&ecirc;ncia &Uacute;nica para CTs Multi Modais.
                            </div>
                        </td>
                        <td width="50%" align="center" class="TextoCampos" colspan="2">
                            <div align="left">
                                <input type="checkbox" name="sequenciaSeloCT" id="sequenciaSeloCT" <%=(carregaFi && fi.isControlaSequenciaSelo() ? "checked" : "")%>>
                                Controlar Sequ&ecirc;ncia de Selo para Lan&ccedil;amentos de CTs.
                            </div>
                        </td>
                    </tr>
                    
                    <tr>
                        <td width="50%" align="center" class="TextoCampos">
                            <div align="left">
                                Ao imprimir etiquetas considerar o total de volumes:
                                <select id="imprimirEtiquetaPaginacao" name="imprimirEtiquetaPaginacao" class="inputtexto">
                                    <option value="c" <%=(carregaFi && fi.getImprimirEtiquetaPaginacao().equals("c") ? "selected" : "")%>>do CT-e</option>
                                    <option value="n" <%=(carregaFi && fi.getImprimirEtiquetaPaginacao().equals("n") ? "selected" : "")%>>da NF</option>
                                    <option value="p" <%=(carregaFi && fi.getImprimirEtiquetaPaginacao().equals("p") ? "selected" : "")%>>do Item da NF</option>
                                    <option value="b" <%=(carregaFi && fi.getImprimirEtiquetaPaginacao().equals("b") ? "selected" : "")%>>da cubagem da NF</option>
                                </select>
                            </div>
                        </td>
                        <td width="50%" align="left" class="TextoCampos" colspan="2">
                            <div align="left">
                            <input type="checkbox" id="imprMais1" name="imprMais1" <%=(carregaFi && fi.isImprimirMaisEtiquetas() ? "checked" : "")%>>
                                Ao imprimir etiquetas, imprimir 1 a mais para colocar no verso da NF.
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">                        
                            <!--<input type="checkbox" id="chkUtilizaFilialFreteAvista" name="chkUtilizaFilialFreteAvista" value=""/>-->
                            Utilizar a filial para recebimentos de fretes à vista:                        
                        </td>
                        <td class="CelulaZebra2" colspan="2">
                            <input type="hidden" id="idfilialFreteAvista" name="idfilialFreteAvista" value="<%=(carregaFi ? fi.getUtilizaFilialFreteAvistaCTe().getIdfilial() : 0)%>"/>
                            <input type="text" id="fi_abreviatura" class="inputReadOnly" readonly name="fi_abreviatura" value="<%=(carregaFi ? (fi.getUtilizaFilialFreteAvistaCTe().getAbreviatura() != null ? fi.getUtilizaFilialFreteAvistaCTe().getAbreviatura() : "") : "")%>"/>
                            <input type="button" class="botoes" id="botaoFilial" name="botaoFilial" value="..." onclick="javascript:localizarFilial();"/>
                            <img src="img/borracha.gif" border="0" class="imagemLink" onclick="limparFilial();"/>
                        </td>
                    </tr>
                    <tr>                  
                        <td class="textoCampos">CNAE:</td>
                        <td class="CelulaZebra2" colspan="2" >
                            <input onload="concatFieldValue();" type="text" name="cod_cnae" id="cod_cnae" size="15" readonly class="inputReadOnly" value="<%=(fi != null && fi.getCnae().getCod_cnae() != null ? fi.getCnae().getCod_cnae() : "")%> " >
                            <input onload="concatFieldValue();" type="text" name="descricao_cnae" id="descricao_cnae" size="30" readonly class="inputReadOnly" value="<%=(fi != null && fi.getCnae().getDescricao() !=null ? fi.getCnae().getDescricao() : "")%>">
                            <input type="button" class="inputBotaoMin" name="botaoCnae"  value="..." onclick="launchPopupLocate('./localiza?acao=consultar&idlista=30','CNAE');">
                            <input onload="concatFieldValue();" type="hidden" name="cnae_id" id="cnae_id" value="<%=fi != null ? fi.getCnae().getId() : 0%>">
                        </td>
                    </tr>
                     <tr>
                        <td class="TextoCampos">Negociação do Adiantamento do Contrato de Frete: </td><td class="TextoCampos"><div align="left">
                                <select id="negociacaoAdiantamento" name="negociacaoAdiantamento" class="inputtexto">
                                    <option value="0" selected="">Não Informado</option>
                                    <% for (NegociacaoAdiantamentoFrete negociacao : negociacaoFilial){ %><option value="<%= negociacao.getId() %>"><%= negociacao.getDescricao() %></option><%}%>
                                </select></div></td>                                              
                        <td class="TextoCampos" colspan="2"></td>
                     </tr>
                      <tr>
                        <td class="TextoCampos"><div align="left">
                                <input type="checkbox" id="isOrcamentoOutrasFilias" name="isOrcamentoOutrasFilias" <%= carregaFi && fi.isOrcamentoOutrasFilias() ? "checked" : "" %>>
                                Permitir o vínculo de orçamentos aprovados de outras filiais ao incluir um CT-e
                            </div>
                        </td>
                        <td width="50%" align="center" class="TextoCampos" colspan="2">
                            
                        </td>
                    </tr>
                     <tr><td colspan="3"> <table class="bordaFina" width="100%" id="tableDomNegociacao" name="tableDomNegociacao"></table></td></tr>
                    <tr>
                        <td width="50%" align="center" class="TextoCampos">
                            <div align="left">
                                <input type="checkbox" name="controleValor" id="controleValor" onclick="ativarValorMaximo();">
                                Ativar controle de valor de mercadoria na emissão de manifesto.
                            </div>
                        </td>
                        <td width="25%" align="center" class="TextoCampos" >
                            <label id="labelValorMax">Valor máximo permitido:</label>
                        </td>
                        <td width="25%" class="CelulaZebra2">
                            <input type="text" class="inputtexto" name="valorMaximo" id="valorMaximo" maxlength="16" size="14" value="0,00" onkeydown="fmtDecimalNumber(this, event,2);" onkeypress="fmtDecimalNumber(this, event,2);" onkeyup="fmtDecimalNumber(this, event,2);">
                        </td>
                    </tr>
                    <tr id="trIcmsGO" name="trTcmsGO">
                        <td class="CelulaZebra2" colspan="4"><input type="checkbox" name="isICMSufGO" id="isICMSufGO" <%= carregaFi && fi.isAtivarICMSGoias()? "checked" : "" %>>
                        Essa filial possui o termo de credenciamento da superintendência da Receita, dispensando-a da condição de substituído tributário conforme a instrução normativa Nº 1298/16-GSF, de 18 de outubro de 2016, Art 2º item II</td>
                    </tr>
                    <tr>
                        <td colspan="4" align="center" class="TextoCampos">
                            <div align="left">
                                <input type="checkbox" name="importarXMLNFeFilial"
                                       id="importarXMLNFeFilial" <%= (carregaFi && fi.isImportarNFeDestinatario()) ? "checked" : "" %>>
                                Importar XMLs de NF-e quando a filial for o destinatário da NF-e.
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td class="CelulaZebra2"> Ultimo NSU CT-e : 
                            <input class="inputtexto" type="text" name="ultimoNsuCte" id="ultimoNsuCte" value="<%= carregaFi ? fi.getUltimoNSUCTE() : "0" %>">
                        </td>
                        <td class="CelulaZebra2" colspan="3"> Ultimo NSU NF-e : 
                            <input class="inputtexto" type="text" name="ultimoNsuNfe" id="ultimoNsuNfe" value="<%= carregaFi ? fi.getUltimoNSUNFE() : "0" %>">
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="CelulaZebra2" colspan="4">
                <table width="100%" border="0" class="bordaFina" align="left" id="tbTarefas">
                    <tr>
                        <td class="Tabela" align="center" colspan="4"> Tarefas Agendadas</td>
                    </tr>
                    <tr>
                        <td class="CelulaZebra2" colspan="8">
                            <table width="100%" border="0" class="bordaBranca" align="left" id="tbTarefas1">
                                <tr>
                                    <td  style="vertical-align:top;" width="50%">
                                        <table width="100%" border="0" class="bordaFina" align="left" id="tbCron">
                                            <thead>
                                                <Tr>
                                                    <td class="CelulaZebra2" align="center" colspan="1">
                                                        <img src="img/add.gif" title="Adicionar Sincronização" class="imagemLink" onclick="javascript:addCron('cte');"></td>
                                                    <td class="CelulaZebra2" align="center" colspan="3"><b>Sincronizar XML CTE</b></td>
                                                </Tr>
                                            </thead>
                                            <tbody id="bodyCron">

                                            </tbody>
                                        </table>
                                    </td>
                                    <td  style="vertical-align:top;"  width="50%">
                                        <table width="100%" border="0" class="bordaFina" align="left" id="tbCronNfe">
                                            <thead>
                                                <Tr>
                                                    <td class="CelulaZebra2" align="center" colspan="1">
                                                        <img src="img/add.gif" title="Adicionar Sincronização" class="imagemLink" onclick="javascript:addCron('nfe');"></td>
                                                    <td class="CelulaZebra2" align="center" colspan="3"><b>Sincronizar XML NFE</b></td>
                                                </Tr>
                                            </thead>
                                            <tbody id="bodyCronNfe">

                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </table> 
                        </td>
                    </tr>        
                </table>
            </td>
        </tr>
                        
                    <div>                            
                        <table width="75%" border="0" class="bordaFina" align="center">
                            <tr class ="celulaZebra2">
                                <td colspan="2">
                                    <input type="checkbox" name="chkCidade" id="chkCidade"  value="checked"
                                           onclick="javascript:tryRequestToServer(function () {ativarCidade();});"
                                           <%=(carregaFi && fi.isCidadeAtendidas() ? "checked" : "")%>>
                                        Ativar controle de cidades atendidas para essa filial
                                </td>
                            </tr>
                        </table>  
                        <table table width="75%" border="0" class="bordaFina" align="center">
                            <tr>
                                <td width="75%" class="celulaZebra2">
                                    <table width="100%">
                                        <td width="33%" style="vertical-align:top;">
                                            <table width="100%" id="tabelaCidade" class="bordaFina tabelaZerada">
                                                <tbody>
                                                    <tr>
                                                    <td class="celula"  width="1%" align="right">                                                
                                                        <img src="img/add.gif" border="0" title="Adicionar Cidade" class="imagemLink" style="vertical-align:middle;" 
                                                             onClick="javascript:tryRequestToServer(function () {localizarCidadeAtendidas();
                                                                });">
                                                    </td>
                                                    <td class="celula" width="15%">Cidade</td>
                                                    <td class="celula" width="1%">UF</td>
                                                    <td class="celula" width="20%">
                                                        Acrescentar todas as cidades da UF:
                                                    </td>
                                                    <td class="celula" width="1%">
                                                        <input name="filtroCidadePorUf" type="text" id="filtroCidadePorUf" value="" maxlength="2" size="3" class="inputtexto">
                                                    </td>
                                                    <td class="celula" width="1%">
                                                        <input name="Pesquisar" type="button" class="botoes" id="Pesquisar" value="Pesquisar" onClick="javascript:tryRequestToServer(function () {consultaCidadePorUF(getObj('filtroCidadePorUf').value)});">
                                                    </td>
                                                </tr>
                                                </tbody>
                                                <tbody id="tbodyCidade">
                                                </tbody>
                                            </table>
                                        </td>
                                    </table>
                                </td>
                            </tr>
                        </table>

                        <input type="hidden" id="maxCidades" name="maxCidades" onload="applyFormatter();"/>      
                    </div>      
                        
                </table></div>
       <div id="tab1" style="">
        <table class="bordaFina" align="center" width="75%">
                <tr>
                    <td class="TextoCampos">
                        Tipo de Tributação: 
                    </td>
                    <td class="CelulaZebra2" >
                        <select id="tipoTributacao" name="tipoTributacao" class="inputTexto" onchange="deixarAbaGerencialVisivel();">
                            <option value="ni" <%= (carregaFi ? (fi.getTipoTributacao().equals("ni") ? "selected" : "") : "") %>>Não informado</option>
                            <option value="lr" <%= (carregaFi ? (fi.getTipoTributacao().equals("lr") ? "selected" : "") : "") %>>Lucro Real</option>
                            <option value="lp" <%= (carregaFi ? (fi.getTipoTributacao().equals("lp") ? "selected" : "") : "") %>>Lucro Presumido</option>
                            <option value="sn" <%= (carregaFi ? (fi.getTipoTributacao().equals("sn") ? "selected" : "") : "") %>>Simples Nacional</option>
                            <option value="me" <%= (carregaFi ? (fi.getTipoTributacao().equals("me") ? "selected" : "") : "") %>>Micro Empreendedor Individual(MEI)</option>
                        </select>
                    </td>
                </tr>
                <tr class="tabela">
            <td colspan="4" align="center">Dados para Exporta&ccedil;&atilde;o de Dados (SEF/SINTEGRA/SPED) </td>
        </tr>
        <tr>
            <td colspan="4" class="celula">
                <div align="center">Dados do Respons&aacute;vel pela Filial</div>
            </td>
        </tr>
        <tr class="TextoCampos">
            <td colspan="4" >
                <table width="100%" border="1" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="10%" class="TextoCampos">Nome : </td>
                        <td width="40%" class="CelulaZebra2">
                            <input onload="concatFieldValue();" name="responsavel" type="text" id="responsavel" value="<%=(carregaFi ? fi.getResponsavel() : "")%>" size="30" maxlength="28" class="inputtexto">
                        </td>
                        <td width="10%" class="TextoCampos">E-mail : </td>
                        <td width="40%" class="CelulaZebra2">
                            <input onload="concatFieldValue();" name="email_responsavel" type="text" id="email_responsavel" value="<%=(carregaFi ? fi.getEmailResponsavel() : "")%>" size="40" maxlength="50" class="inputtexto">
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">CPF : </td>
                        <td class="CelulaZebra2">
                            <input name="cpf_responsavel" type="text" id="cpf_responsavel" onKeyPress="javascript:digitaCnpj();" size="20" maxlength="14" class="inputtexto">
                        </td>
                        <td class="TextoCampos">Fone : </td>
                        <td class="CelulaZebra2">
                            <input onload="concatFieldValue();" name="fone_responsavel" type="text" id="fone_responsavel" value="<%=(carregaFi ? fi.getFoneResponsavel() : "")%>" size="10" maxlength="12" class="inputtexto">
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos" colspan="2">Email para recebimento pré alerta:</td>
                        <td class="CelulaZebra2" colspan="2">
                            <input onload="concatFieldValue();" type="text" id="emailRecebimentoPreAlerta" name="emailRecebimentoPreAlerta" value="<%=(carregaFi ? fi.getEmailRecebimentoPreAlerta() : "")%>" size="20" class="inputtexto">
                        </td>
                    </tr>                    
                </table>
            </td>
        </tr>
        
        <tr>
            <td colspan="4" class="celula"><div align="center">Dados do Contador</div></td>
        </tr>
        <tr>
            <td colspan="4" class="TextoCampos">
                <table width="100%" border="1" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="10%" class="TextoCampos">Nome : </td>
                        <td width="40%" class="CelulaZebra2">
                            <span class="CelulaZebra2">
                                <input onload="concatFieldValue();" name="nome_contador" type="text" id="nome_contador" value="<%=(carregaFi ? fi.getNomeContador() : "")%>" size="33" maxlength="50" class="inputtexto">
                            </span>
                        </td>
                        <td width="10%" class="TextoCampos">E-mail : </td>
                        <td width="40%">
                            <span class="CelulaZebra2">
                                <input onload="concatFieldValue();" name="email_contador" type="text" id="email_contador" value="<%=(carregaFi ? fi.getEmailContador() : "")%>" size="50" maxlength="50" class="inputtexto">
                            </span>
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">CPF :</td>
                        <td>
                            <span class="CelulaZebra2">
                                <input name="cpf_contador" type="text" id="cpf_contador" onKeyPress="javascript:digitaCnpj();" size="20" maxlength="14" class="inputtexto">
                            </span>
                        </td>
                        <td class="TextoCampos">CRC : </td>
                        <td>
                            <span class="CelulaZebra2">
                                <input onload="concatFieldValue();" name="crc_contador" type="text" id="crc_contador" value="<%=(carregaFi ? fi.getCrcContador() : "")%>" size="15" maxlength="10" class="inputtexto">
                            </span>
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">Lograd/N° :</td>
                        <td>
                            <span class="CelulaZebra2">
                                <input name="logradouro_contador" type="text" id="logradouro_contador" value="<%=(carregaFi ? fi.getLogradouroContador(): "")%>"  size="40" maxlength="200" class="inputtexto">
                            </span>/
                            <span class="CelulaZebra2">
                                <input name="num_logradouro_contador" type="text" id="num_logradouro_contador" value="<%=(carregaFi ? fi.getNumLogradouroContador() : "")%>" size="5" maxlength="10" class="inputtexto">
                            </span>
                        </td>
                        <td class="TextoCampos">CEP/Cx Postal: </td>
                        <td>
                            <span class="CelulaZebra2">
                                <input name="cep_contador" type="text" id="cep_contador" value="<%=(carregaFi ? fi.getCepContador() : "")%>" size="15" maxlength="10" class="inputtexto">
                            </span>/
                            <span class="CelulaZebra2">
                                <input onload="concatFieldValue();" name="cxpostal_contador" type="text" id="cxpostal_contador" value="<%=(carregaFi ? fi.getCxPostalContador() : "")%>" size="12" maxlength="6" class="inputtexto">
                            </span>
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">Bairro :</td>
                        <td>
                            <span class="CelulaZebra2">
                                <input name="bairro_contador" type="text" id="bairro_contador"  value="<%=(carregaFi ? fi.getBairroContador(): "")%>" size="25" maxlength="25" class="inputtexto">
                            </span>
                        </td>
                        <td class="TextoCampos">Cidade/UF : </td>
                        <td>
                            <span class="CelulaZebra2">
                                <input name="cidadeContador" type="text" id="cidadeContador" class="inputReadOnly" readonly value="<%=(carregaFi && fi.getCidadeContador().getDescricaoCidade() != null ? fi.getCidadeContador().getDescricaoCidade() : "")%>" size="35" maxlength="35">
                                <input name="ufContador" type="text" class="inputReadOnly" id="ufContador" size="2" readonly value="<%=(carregaFi && fi.getCidadeContador().getDescricaoCidade() != null ? fi.getCidadeContador().getUf() : "")%>">
                                <input name="button" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=11','Cidade_Contador')" value="...">
                                <input type="hidden" id="idcidadecontador" name="idcidadecontador" class="inputReadOnly" readonly value="<%=(carregaFi && fi.getCidadeContador().getDescricaoCidade() != null ? fi.getCidadeContador().getIdcidade() : 0)%>">
                                <img src="img/borracha.gif" align="absbottom" class="imagemLink" title="Limpar Cidade" onClick="getObj('cidadeContador').value='';getObj('ufContador').value='';getObj('idcidadecontador').value='0';">
                            </span>
                        </td>
                                                                        
                    </tr>
                    <tr>
                        <td class="TextoCampos">Fones :</td>
                        <td>
                            <span class="CelulaZebra2">
                                <input onload="concatFieldValue();" name="fone1_contador" type="text" id="fone1_contador" value="<%=(carregaFi ? fi.getFone1Contador() : "")%>" size="10" maxlength="12" class="inputtexto">
                                /
                                <input onload="concatFieldValue();" name="fone2_contador" type="text" id="fone2_contador" value="<%=(carregaFi ? fi.getFone2Contador() : "")%>" size="10" maxlength="12" class="inputtexto">
                            </span>
                            / 
                            <span class="CelulaZebra2">
                                <input onload="concatFieldValue();" name="fax_contador" type="text" id="fax_contador" value="<%=(carregaFi ? fi.getFaxContador() : "")%>" size="10" maxlength="12" class="inputtexto">
                            </span>
                        </td>
                        <td class="TextoCampos">Compl.: </td>
                        <td>
                            <span class="CelulaZebra2">
                                <input name="complemento_logradouro_contador" type="text" id="complemento_logradouro_contador" value="<%=(carregaFi ? fi.getComplementoLogradouroContador() : "")%>" size="50" maxlength="50" class="inputtexto">
                            </span>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td colspan="4" class="celula">
                <div align="center">Informações do SEF II</div>
            </td>
        </tr>
        <tr class="TextoCampos">
            <td colspan="4" width="100%">
                <table width="100%" border="1px">
                    <tr>
                        <td width="60%" class="TextoCampos">Indicador do documento contido no arquivo:</td>
                        <td width="40%" class="celulaZebra2">
                            <select id="indArq" name="indArq" class="inputTexto" style="width: 140px">
                                <option value="0">Selecione</option>
                                <% for (IndicadorDocumentoSef indDoc : IndicadorDocumentoSef.mostrarTodos(Apoio.getUsuario(request).getConexao())) {%>
                                <option value="<%=indDoc.getId()%>"><%=indDoc.getCodigo() + "-" + indDoc.getDescricao()%></option>
                                <% }%>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td  class="TextoCampos">Indicador de exigibilidade da escrituração do ISS:</td>
                        <td  class="celulaZebra2">
                            <select id="prfIss" name="prfIss" class="inputTexto" style="width: 140px">
                                <option value="0">Selecione</option>
                                <% for (IndicadorExibilidadeEscrituracaoSef prfIss : IndicadorExibilidadeEscrituracaoSef.mostrarTodos(Apoio.getUsuario(request).getConexao(), true)) {%>
                                <option value="<%=prfIss.getId()%>"><%=prfIss.getCodigo() + "-" + prfIss.getDescricao()%></option>
                                <% }%>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td  class="TextoCampos">Indicador de exigibilidade da escrituração do ICMS:</td>
                        <td  class="celulaZebra2">
                            <select id="prfIcms" name="prfIcms" class="inputTexto" style="width: 140px">
                                <option value="0">Selecione</option>
                                <% for (IndicadorExibilidadeEscrituracaoSef prfIcms : IndicadorExibilidadeEscrituracaoSef.mostrarTodos(Apoio.getUsuario(request).getConexao(), false)) {%>
                                <option value="<%=prfIcms.getId()%>"><%=prfIcms.getCodigo() + "-" + prfIcms.getDescricao()%></option>
                                <% }%>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td  class="TextoCampos">Indicador de exigibilidade do Registro de Impressão de Documentos Fiscais:</td>
                        <td  class="celulaZebra2">
                            Sim<input type="radio" id="prfRidfT" name="prfRidf" <%= carregaFi && fi.isPrfRidf() ? "checked" : ""%> value="true" />
                            Não<input type="radio" id="prfRidfF" name="prfRidf" <%=(carregaFi && fi.isPrfRidf()) ? "" : "checked"%> value="false"/>   
                        </td>
                    </tr>
                    <tr>
                        <td  class="TextoCampos">Indicador de exigibilidade do Registro de Utilização de Documentos Fiscais:</td>
                        <td  class="celulaZebra2">
                            Sim<input type="radio" id="prfRudfT" name="prfRudf" <%= carregaFi && fi.isPrfRudf() ? "checked" : ""%> value="true" />
                            Não<input type="radio" id="prfRudfF" name="prfRudf" <%= (carregaFi && fi.isPrfRudf()) ? "" : "checked"%> value="false"/>   
                        </td>
                    </tr>
                    <tr>
                        <td  class="TextoCampos">Indicador de exigibilidade do Livro de Movimentação de Combustíveis:</td>
                        <td  class="celulaZebra2">
                            Sim<input type="radio" id="prfLmfT" name="prfLmf" <%=  carregaFi && fi.isPrfLmf() ? "checked" : ""%> value="true" />
                            Não<input type="radio" id="prfLmfF" name="prfLmf" <%=  (carregaFi && fi.isPrfLmf()) ? "" : "checked"%> value="false"/>   
                        </td>
                    </tr>
                    <tr>
                        <td  class="TextoCampos">Indicador de exigibilidade do Registro de Veículos:</td>
                        <td  class="celulaZebra2">
                            Sim<input type="radio" id="prfRvT" name="prfRv" <%= carregaFi && fi.isPrfRv() ? "checked" : ""%> value="true" />
                            Não<input type="radio" id="prfRvF" name="prfRv" <%= (carregaFi && fi.isPrfRv()) ? "" : "checked"%> value="false"/>   
                        </td>
                    </tr>
                    <tr>
                        <td  class="TextoCampos">Indicador de exigibilidade anual do Registro de Inventário:</td>
                        <td  class="celulaZebra2">
                            Sim<input type="radio" id="prfRiT" name="prfRi" <%=  carregaFi && fi.isPrfRi() ? "checked" : ""%> value="true" />
                            Não<input type="radio" id="prfRiF" name="prfRi"  <%= (carregaFi && fi.isPrfRi()) ? "" : "checked"%> value="true"/>   
                        </td>
                    </tr>
                    <tr>
                        <td  class="TextoCampos">Indicador de apresentação da escrituração contábil:</td>
                        <td  class="celulaZebra2">
                            <select id="indEc" name="indEc" class="inputTexto" style="width: 140px">
                                <option value="0">Selecione</option>
                                <% for (indicadorEscrituracaoContabilSef indEc : indicadorEscrituracaoContabilSef.mostrarTodos(Apoio.getUsuario(request).getConexao())) {%>
                                <option value="<%=indEc.getId()%>"><%=indEc.getCodigo() + "-" + indEc.getDescricao()%></option>
                                <% }%>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td  class="TextoCampos">Indicador de operações sujeitas ao ISS:</td>
                        <td  class="celulaZebra2">
                            Sim<input type="radio" id="indIssT" name="indIss" <%=  carregaFi && fi.isIndIss() ? "checked" : ""%> value="true" />
                            Não<input type="radio" id="indIssF" name="indIss"  <%=  (carregaFi && fi.isIndIss()) ? "" : "checked"%> value="false"/>   
                        </td>
                    </tr>
                    <tr>
                        <td  class="TextoCampos">Indicador de operações sujeitas à retenção tributária do ISS, na condição de contribuinte-substituído:</td>
                        <td  class="celulaZebra2">
                            Sim<input type="radio" id="indRtT" name="indRt" <%=  carregaFi && fi.isIndRt() ? "checked" : ""%> value="true" />
                            Não<input type="radio" id="indRtF" name="indRt"  <%= (carregaFi && fi.isIndRt()) ? "" : "checked"%> value="false"/>   
                        </td>
                    </tr>
                    <tr>
                        <td  class="TextoCampos">Indicador de operações sujeitas ao ICMS:</td>
                        <td  class="celulaZebra2">
                            Sim<input type="radio" id="indIcmsT" name="indIcms" <%= carregaFi && fi.isIndIcms() ? "checked" : ""%> value="true" />
                            Não<input type="radio" id="indIcmsF" name="indIcms"  <%= (carregaFi && fi.isIndIcms()) ? "" : "checked"%> value="false"/>   
                        </td>
                    </tr>
                    <tr>
                        <td  class="TextoCampos">Indicador de operações sujeitas à substituição tributária do ICMS, na condição de contribuinte-substituto:</td>
                        <td  class="celulaZebra2">
                            Sim<input type="radio" id="indStT" name="indSt" <%= carregaFi && fi.isIndSt() ? "checked" : ""%> value="true" />
                            Não<input type="radio" id="indStF" name="indSt"  <%= (carregaFi && fi.isIndSt()) ? "" : "checked"%> value="false"/>   
                        </td>
                    </tr>
                    <tr>
                        <td  class="TextoCampos">Indicador de operações sujeitas à antecipação tributária do ICMS, nas entradas:</td>
                        <td  class="celulaZebra2">
                            Sim<input type="radio" id="indAtT" name="indAt" <%= carregaFi && fi.isIndAt() ? "checked" : ""%> value="true" />
                            Não<input type="radio" id="indAtF" name="indAt"  <%= (carregaFi && fi.isIndAt()) ? "" : "checked"%> value="false"/>   
                        </td>
                    </tr>
                    <tr>
                        <td  class="TextoCampos">Indicador de operações sujeitas ao IPI:</td>
                        <td  class="celulaZebra2">
                            Sim<input type="radio" id="indIpiT" name="indIpi" <%= carregaFi && fi.isIndIpi() ? "checked" : ""%> value="true" />
                            Não<input type="radio" id="indIpiF" name="indIpi" <%= (carregaFi && fi.isIndIpi()) ? "" : "checked"%> value="false"/>   
                        </td>
                    </tr>
                    <tr>
                        <td  class="TextoCampos">Indicador de apresentação avulsa do Registro de Inventário:</td>
                        <td  class="celulaZebra2">
                            Sim<input type="radio" id="indRiT" name="indRi" <%= carregaFi && fi.isIndRi() ? "checked" : ""%> value="true" />
                            Não<input type="radio" id="indRiF" name="indRi"  <%= (carregaFi && fi.isIndRi()) ? "" : "checked"%> value="false"/>   
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos" >Código do recolhimento do ICMS </td>
                        <td class="CelulaZebra2" >      
                            <select name="cod_recolhimento" id="cod_recolhimento" class="inputtexto" style="width: 110px">
                                <option value="0">Selecione</option>
                                <% for (RecolhimentoIcms recIcms : RecolhimentoIcms.mostrarTodos(Apoio.getUsuario(request).getConexao(), carregaFi ? fi.getCidade().getUf() : "")) {%>
                                <option value="<%=recIcms.getId()%>"><%=recIcms.getCodigo() + "-" + recIcms.getDescricao()%></option>
                                <% }%>
                            </select>
                        </td>
                    </tr>
                </table>
            </td> 
        </tr>
        <tr>
            <td colspan="4" class="celula"><div align="center">Informações do SPED Fiscal</div></td>
        </tr>
        <tr>
            <td colspan="4" width="100%">
                <table width="100%" border="1px">
                    <tr>
                        <td class="TextoCampos" width="60%" >Perfil EFD</td>
                        <td class="CelulaZebra2" width="40%" >      
                            <select name="perfilEFD" id="perfilEFD" class="inputtexto" style="width: 110px">
                                <option value="A">A</option>
                                <option value="B">B</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos" align="center" width="50%" >
                            <span>
                                <label>Agregar valores por município:</label>
                            </span>
                        </td>
                        <td  class="celulaZebra2">
                            Sim<input type="radio" id="agregarValoresSPEDT" name="agregarValoresSPED" <%= carregaFi && fi.isSpedInformarValoresAgregados() ? "checked" : ""%> value="true" />
                            Não<input type="radio" id="agregarValoresSPEDF" name="agregarValoresSPED"  <%= (carregaFi && fi.isSpedInformarValoresAgregados()) ? "" : "checked"%> value="false"/>   
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos" align="center" width="50%" >
                            <span>
                                <label>Codigo da Tabela de Itens da Unidade da Federação para Agregação de Entrada:</label>
                            </span>
                        </td>
                        <td  class="celulaZebra2">
                            <input type="text" size="10" maxlength="10" id="codAgregacaoEntrada" name="codAgregacaoEntrada" class="inputtexto">
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos" align="center" width="50%" >
                            <span>
                                <label>Codigo da Tabela de Itens da Unidade da Federação para Agregação de Saída:</label>
                            </span>
                        </td>
                        <td  class="celulaZebra2">
                            <input type="text" size="10" maxlength="10" id="codAgregacaoSaida" name="codAgregacaoSaida" class="inputtexto">
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td colspan="4" class="celula"><div align="center">Informações do SPED Pis Cofins</div></td>
        </tr>
        <tr>
            <td colspan="4" width="100%">
                <table width="100%" border="1px">
                    <tr>
                        <td class="TextoCampos" width="60%" >Gerar o Registro 0145 (Regime de Apuração da Contribuição Previdenciária sobre a Receita Bruta) e o Bloco P</td>
                        <td class="CelulaZebra2" width="40%" >
                            Sim<input type="radio"  id="isAddEFDContribuicaoPrevidenciariaT" name="isAddEFDContribuicaoPrevidenciaria" <%= carregaFi && fi.isAddEFDContribuicaoPrevidenciaria()? "checked" : ""%> 
                                      onclick="(this.checked ? visivel($('trCodigoAtividadeContribuicaoPrevidenciaria')) : invisivel($('trCodigoAtividadeContribuicaoPrevidenciaria')))" value="true" />
                            Não<input type="radio" id="isAddEFDContribuicaoPrevidenciariaF" name="isAddEFDContribuicaoPrevidenciaria"  <%= (carregaFi && fi.isAddEFDContribuicaoPrevidenciaria()) ? "" : "checked"%> 
                                      onclick="(this.checked ? invisivel($('trCodigoAtividadeContribuicaoPrevidenciaria')) : visivel($('trCodigoAtividadeContribuicaoPrevidenciaria')))" value="false"/>   
                        </td>
                    </tr>
                    <tr id="trCodigoAtividadeContribuicaoPrevidenciaria">
                        <td class="TextoCampos" width="60%" >Código de Atividade Econômica Sujeita a Contribuição Previdênciaria:</td>
                        <td class="CelulaZebra2" width="40%" >
                            <input name="efdCodAtividadeContribuicaoPrevidenciaria" type="text" id="efdCodAtividadeContribuicaoPrevidenciaria" value="<%=(carregaFi ? fi.getEFDCodAtividadeContribuicaoPrevidenciaria(): "")%>" size="8" maxlength="20" class="inputtexto">
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
            </table>
       </div>
       <div id="tab7" style="">
           <table width="75%" align="center" class="bordaFina">
               <tr class="tabela"/>            
               <tr>
            <td colspan="4" width="100%">
                <table width="100%" class="bordaFina">
                    <tr>
                        <td colspan="2" class="textoCamposNoAlign" align="center">
                            <input name="isMostrarFreteCifEmitidoPropriaFilialFobs" type="checkbox" id="isMostrarFreteCifEmitidoPropriaFilialFobs" <%=(carregaFi ? (fi.isMostrarFreteCifEmitidoPropriaFilialFobs()? "checked" : "") : "")%> >
                            <label>No lançamento de fatura deverá mostrar apenas fretes CIF emitidos pela minha filial e fretes FOB destinados a minha filial</label>
                        </td>
                    </tr>
                    <tr>
                        <td class="textoCampos">
                            <label>E-mail padrão para envio de faturas:</label>
                        </td>
                        <td class="CelulaZebra2">
                            <select name="emailFaturaFilial" class="inputtexto"  id="emailFaturaFilial"  style="width: 300px;">
                                <option value="0">Utilizar e-mail definido em configurações</option>
                                <c:forEach items="${emailsFatura}" var="email">
                                    <option value="${email.id}">${email.descricao}</option>
                                </c:forEach>
                            </select>
                        </td>
                    </tr>
                </table>
            </td>            
           </table>
       </div>
        <div id='tab8'>
            <table width='75%' align='center' class="bordaFina">
                <thead class='tabela'>
                    <tr>
                        <th>
                            Ativar Horário de Verão
                        </th>
                    </tr>
                </thead>
                
                <tbody>
                    <tr>
                        <td class='textoCamposNoAlign' align='center'>
                            <input type="checkbox" id="isAtivarHoraVerao" name="isAtivarHoraVerao" > Ativar Horário de Verão
                        </td>
                    </tr>
                </tbody>
                
            </table>
        </div>
       <div id="tab3">
            <table width="75%" align="center" class="bordaFina">
                <c:if test="${filial.descricaoCertificado != null}">
                    <tr class="celulaZebra2">
                        <td colspan="4" align="center">
                            <label><strong>Certificado digital:</strong> <span id="descricaoCertificadoDigital"><%=(carregaFi ? fi.getDescricaoCertificado() : "")%></span></label>
                            <label style="padding-left: 15px;"><strong>Validade do certificado:</strong> <span id="validadeCertificadoDigital"><%=(carregaFi ? fi.getValidadeCertificado() : "")%></span></label>
                            <label style="padding-left: 15px;"><strong>CNPJ:</strong> <span id="cnpjCertificadoDigital"><%=(carregaFi ? fi.getCnpjCertificado() : "")%></span></label>
                            <label style="padding-left: 15px;"><strong>Cadeia de certificado:</strong> <span id="cadeiaCertificadoDigital"><%=(carregaFi ? fi.getCadeiaCertificado() : "")%></span></label>
                            
                            <input type="hidden" id="caminho_certificado" name="caminho_certificado" value="<%=(carregaFi ? fi.getCaminhoCertificado() : "")%>">
                            <input type="hidden" id="senha_certificado" name="senha_certificado" value="<%=(carregaFi ? fi.getSenhaCertificado() : "")%>">
                        </td>
                    </tr>
                </c:if>
                
             <tr class="tabela">
            <td colspan="4" align="center">Dados para Averba&ccedil;&atilde;o </td>
        </tr>  
        <tr>
            <td colspan="4" width="100%">
                <table width="100%" class="bordaFina">
                    <tr>
                        <td class="TextoCampos">N&uacute;mero da Apolice:</td>
                        <td class="celulaZebra2">
                            <input onload="concatFieldValue();" name="itauSegurosNumeroApolice" type="text" id="itauSegurosNumeroApolice" value="<%=(carregaFi ? fi.getItauSegurosNumeroApolice() : "")%>" size="15" maxlength="50" class="inputtexto">
                        </td>
                        <td class="TextoCampos">Sub Grupo:</td>
                        <td class="celulaZebra2">
                            <input onload="concatFieldValue();" name="itauSegurosSubGrupo" type="text" id="itauSegurosSubGrupo" value="<%=(carregaFi ? fi.getItauSegurosSubGrupo() : "")%>" size="6" maxlength="3" class="inputtexto">
                        </td>
                        <td class="textoCamposNoAlign" align="center">
                            <input name="itauSegurosAverbarRCF" type="checkbox" id="itauSegurosAverbarRCF" <%=(carregaFi ? (fi.isItauSegurosAverbarRCF() ? "checked" : "") : "")%> >
                            <label>Averbar RCF-DC</label>
                        </td>
                        <td class="textoCamposNoAlign" align="center">
                            <input name="itauSegurosAverbarTRN" type="checkbox" id="itauSegurosAverbarTRN" <%=(carregaFi ? (fi.isItauSegurosAverbarTRN() ? "checked" : "") : "")%> >
                            <label>Averbar TRN</label>
                        </td>
                        </tr>
                        <tr>
                        <td class="textoCamposNoAlign" align="center" colspan="6">
                            Seguradora:
                                                <select name="seguradora" id="seguradora" class="inputtexto" style="width: 120px;">
                                                    <option value="0" selected>Não selecionada</option>
                                                    <%BeanConsultaFornecedor conFor = new BeanConsultaFornecedor();
                                                                conFor.setConexao(Apoio.getUsuario(request).getConexao());
                                                                conFor.mostraSeguradoras();
                                                                ResultSet rsFor = conFor.getResultado();
                                                                while (rsFor.next()) {%>
                                                            <option value="<%=rsFor.getString("idfornecedor")%>" <%=(carregaFi ? (rsFor.getInt("idfornecedor") == fi.getSeguradoraDdr().getIdfornecedor() ? "selected" : "") : "")%> ><%=rsFor.getString("razaosocial")%></option>                                                    <%}
                                                                rsFor.close();%>
                                                </select>                             
                            </td>
                    </tr>
                </table>
            </td>      
        </tr>
        <tr>
            <td colspan="4" align="center" colspan="8" width="100%">
                <table width="100%" border="0" cellspacing="1" cellpadding="2" class="bordaFina">
                    <tr>                                           
                        <td width="15%" colspan="2" class="TextoCampos">Status de Averbação:</td>
                        <td width="15%" colspan="4" class="CelulaZebra2">
                            <select name="tipo_utilizacao_apisul" id="tipo_utilizacao_apisul" class="inputtexto" onchange="alteraAverbacao();alert('Para as alterações serem efetivadas, faça Logout!')"> 
                                        <option value="N" <%=(carregaFi && fi.getTipoUtilizacaoApisul() == "N" ? "selected" : "")%>>Não Utiliza</option>   
                                        <option value="H" <%=(carregaFi && fi.getTipoUtilizacaoApisul() == "H" ? "selected" : "")%>>Homologação</option>
                                        <option value="P" <%=(carregaFi && fi.getTipoUtilizacaoApisul() == "P" ? "selected" : "")%>>Produção</option>                                      
                            </select>
                        </td> 
                    </tr>
                     <tr id="tdInfoAverbacao"  style="display: none">  
                        <div align="right">
                        <td width="15%" class="CelulaZebra2"><div align="right">Rodoviário:</div></td>
                        <td width="15%" class="CelulaZebra2">
                            <select  name="seguradoraRodoviario" id="seguradoraRodoviario" class="inputtexto"  style="width: 120px;">
                                <option value="0">Selecione</option>
                                <% for(CaixaPostalSeguradora postalSeguradora : listaCaixaPostalSeguradora){%>                                
                                     <option value="<%=postalSeguradora.getId()%>"  <%=(carregaFi && fi.getCaixaPostalSeguradoraRodoviario().getId() == postalSeguradora.getId() ? "selected" : "")%>><%=postalSeguradora.getDescricao()%></option>  
                                <%}%>                                                                
                            </select>
                        </td>     
                        
                        <td width="15%" class="CelulaZebra2"><div align="right">Aéreo:</div></td> 
                        <td width="15%" class="CelulaZebra2">
                            <select name="seguradoraAereo" id="seguradoraAereo" class="inputtexto"  style="width: 120px;"> 
                                <option value="0">Selecione</option>
                                         <% for(CaixaPostalSeguradora postalSeguradora : listaCaixaPostalSeguradora){%>
                                     <option value="<%=postalSeguradora.getId()%>"  <%=(carregaFi && fi.getCaixaPostalSeguradoraAereo().getId() == postalSeguradora.getId() ? "selected" : "")%>><%=postalSeguradora.getDescricao()%></option>  
                                <%}%>                                    
                            </select>
                        </td>     
                         
                        <td width="15%" class="CelulaZebra2"><div align="right">Aquaviário: </div></td>
                        <td width="15%" colspan="2" class="CelulaZebra2">
                            <select name="seguradoraAquaviario" id="seguradoraAquaviario" class="inputtexto"  style="width: 120px;"> 
                                <option value="0">Selecione</option>
                                         <% for(CaixaPostalSeguradora postalSeguradora : listaCaixaPostalSeguradora){%>
                                     <option value="<%=postalSeguradora.getId()%>"  <%=(carregaFi && fi.getCaixaPostalSeguradoraAquaviario().getId() == postalSeguradora.getId() ? "selected" : "")%>><%=postalSeguradora.getDescricao()%></option>  
                                <%}%>                          
                            </select>
                        </td>
                        </div>
                    </tr>
                    <tr id="tdInfoAverbacao1" style="display: none">
                        <td width="15%" colspan="2" class="CelulaZebra2">
                            <input type="checkbox" onclick="alteraSeguradora(this.value)" class="inputtexto"
                                   name="transmitirSeguradora"
                                   id="transmitirSeguradora" <%=(carregaFi && fi.isTransmitirCteServidorSeguradora() ? "checked " : "")%>>
                            <label for="transmitirSeguradora">Transmitir CT-e para o servidor da Seguradora</label>
                        </td>
                        <td width="15%" colspan="2" class="CelulaZebra2">
                            <input type="checkbox" class="inputtexto" name="transmitirAuto"
                                   id="transmitirAuto"   <%=(carregaFi && fi.isTransmitirAutomaticamenteConfirmarCte() ? "checked " : "")%>>
                            <label id="transmitirAuto2" for="transmitirAuto">Transmitir automaticamente ao confirmar o CT-e na SEFAZ</label>
                        </td>
                        <td width="15%" colspan="1" class="TextoCampos" id="dtAverb1">
                            <label for="dataAverb">A partir da data:</label>
                        </td>
                        <td width="10%" colspan="2" class="CelulaZebra2" id="dtAverb2">
                            <input name="dataAverb" type="text" id="dataAverb" size="10" maxlength="10"
                                   value="<%=(carregaFi && fi.getDataInicialAverbacao() != null ? fmt.format(fi.getDataInicialAverbacao()): "")%>"
                                   onkeypress="fmtDate(this,event)" onblur="alertInvalidDate(this,true)"
                                   class="fieldDate">
                        </td>
                    </tr>
                    <tr id="tdInfoAverbacaoMDFe" style="display: none">
                        <td width="15%" colspan="2" class="CelulaZebra2">
                            <input type="checkbox" onclick="alteraSeguradoraMDFe(this.value)" class="inputtexto"
                                   name="transmitirSeguradoraMDFe"
                                   id="transmitirSeguradoraMDFe" <%=(carregaFi && fi.isTransmitirMDFeSeguradora() ? "checked " : "")%>>
                            <label for="transmitirSeguradoraMDFe">Transmitir MDF-e para o servidor da Seguradora</label>
                        </td>
                        <td width="15%" colspan="2" class="CelulaZebra2">
                            <input type="checkbox" class="inputtexto" name="transmitirAutoMDFe"
                                   id="transmitirAutoMDFe" <%=(carregaFi && fi.isTransmitirAutomaticamenteMDFeSeguradora() ? "checked " : "")%>>
                            <label id="transmitirAutoMDFe2" for="transmitirAutoMDFe">Transmitir automaticamente ao confirmar o MDF-e na SEFAZ</label>
                        </td>
                        <td width="15%" colspan="1" class="TextoCampos" id="dtAverbMDFe1">
                            <label for="dataAverbMDFe">A partir da data:</label>
                        </td>
                        <td width="10%" colspan="2" class="CelulaZebra2" id="dtAverbMDFe2">
                            <input name="dataAverbMDFe" type="text" id="dataAverbMDFe" size="10" maxlength="10"
                                   value="<%=(carregaFi && fi.getDataInicialAverbacaoMDFe() != null ? fmt.format(fi.getDataInicialAverbacaoMDFe()): "")%>"
                                   onkeypress="fmtDate(this,event)" onblur="alertInvalidDate(this,true)"
                                   class="fieldDate">
                        </td>
                    </tr>
                    <tr id="tdInfoAverbacao2" >
                        <td width="15%" colspan="8" class="TextoCampos">
                        <div align="center">
                          Tipos de CT-e que poderão ser Averbados:
                          </div></td>
                    <tr id="tdInfoAverbacao4" >
                            <td width="10%" colspan="2" class="CelulaZebra2">                                   
                                <input type="checkbox" class="inputtexto" name="averbarNormal" id="averbarNormal" <%=(carregaFi &&fi.isAverbarNormal() ? "checked " : "")%>>Normal
                            </td>
                            <td width="10%" colspan="3" class="CelulaZebra2">                                   
                                <input type="checkbox" class="inputtexto" name="averbarDistLocal" id="averbarDistLocal" <%=(carregaFi &&fi.isAverbarDistLocal() ? "checked " : "")%>>Distribuição Local
                            </td>
                            <td width="10%" colspan="3" class="CelulaZebra2">                                   
                                <input type="checkbox" class="inputtexto" name="averbarDiarias" id="averbarDiarias" <%=(carregaFi &&fi.isAverbarDiarias() ? "checked " : "")%>>Diárias
                            </td>
                    </tr>   
                    <tr id="tdInfoAverbacao3" >
                        <td width="10%" colspan="2" class="CelulaZebra2">                                   
                                <input type="checkbox" class="inputtexto" name="averbarPallets" id="averbarPallets" <%=(carregaFi &&fi.isAverbarPallets() ? "checked " : "")%>>Pallets
                            </td>
                            <td width="10%" colspan="3" class="CelulaZebra2">                                   
                                <input type="checkbox" class="inputtexto" name="averbarComplementar" id="averbarComplementar" <%=(carregaFi &&fi.isAverbarComplementar() ? "checked " : "")%>>Complementar
                            </td>
                               <td width="10%" colspan="3" class="CelulaZebra2">                                   
                                <input type="checkbox" class="inputtexto" name="averbarReentrega" id="averbarReentrega" <%=(carregaFi &&fi.isAverbarReentrega() ? "checked " : "")%>>Reentrega
                            </td>                               
                    </tr>  
                     <tr id="tdInfoAverbacao5" >
                       
                             <td width="10%" colspan="2" class="CelulaZebra2">                                   
                                <input type="checkbox" class="inputtexto" name="averbarDevolucao" id="averbarDevolucao" <%=(carregaFi &&fi.isAverbarDevolucao() ? "checked " : "")%>>Devolução
                            </td>
                             <td width="10%" colspan="3" class="CelulaZebra2">                                   
                                <input type="checkbox" class="inputtexto" name="averbarCortesia" id="averbarCortesia" <%=(carregaFi &&fi.isAverbarCortesia() ? "checked " : "")%>>Cortesia
                            </td>
                             <td width="10%" colspan="3" class="CelulaZebra2">                                   
                                <input type="checkbox" class="inputtexto" name="averbarSubstituicao" id="averbarSubstituicao" <%=(carregaFi &&fi.isAverbarSubstituicao() ? "checked " : "")%>>Substituição
                            </td>
                               
                    </tr>  
                </table>
            </td>
        </tr>
        <tr class="tabela">
            <td colspan="4" align="center">Informa&ccedil;&otilde;es Conhecimento de Transporte Eletrônico (CT-e)</td>
        </tr>
        <tr>
            <td colspan="4" align="center">
                <table width="100%" border="0" cellspacing="1" cellpadding="2" class="bordaFina">
                    <tr>
                        <td width="15%" class="TextoCampos">Status CT-e:</td>
                        <td width="1%" class="CelulaZebra2">
                            <label>
                                <div>                                    
                                    <select name="stUtilizacaoCte" id="stUtilizacaoCte" class="inputtexto">
                                        <option value="N" <%=(carregaFi && fi.getStUtilizacaoCte() == 'N' ? "selected" : "")%>>Não Utiliza</option>
                                        <option value="H" <%=(carregaFi && fi.getStUtilizacaoCte() == 'H' ? "selected" : "")%>>Homologação</option>
                                        <option value="P" <%=(carregaFi && fi.getStUtilizacaoCte() == 'P' ? "selected" : "")%>>Produção</option>
                                        <option value="S" <%=(carregaFi && fi.getStUtilizacaoCte() == 'S' ? "selected" : "")%>>Cont.Serv São Paulo</option>
                                        <option value="R" <%=(carregaFi && fi.getStUtilizacaoCte() == 'R' ? "selected" : "")%>>Cont.Serv Rio Grande do Sul</option>
                                    </select>
                                </div>
                            </label>
                        </td>
                        <td width="15%" class="TextoCampos">Modal CT-e:</td>
                        <td width="10%" class="CelulaZebra2">
                            <select name="modalConhecimento" class="fieldMin" id="modalConhecimento" style="font-size:8pt;" >
                                <option value="f" <%=(carregaFi && fi.getModalCTE() == "f" ? "selected" : "")%>>Fracionado</option>
                                <option value="l" <%=(carregaFi && fi.getModalCTE() == "l" ? "selected" : "")%>>Lotação</option>
                            </select>
                        </td>
                        <td width="20%" class="TextoCampos" colspan="2">N&uacute;mero RNTRC:</td>
                        <td width="5%" class="CelulaZebra2" colspan="2">
                            <input onload="concatFieldValue();" name="numero_rntrc" type="text" id="numero_rntrc" onBlur="javascript:seNaoIntReset(this,'0');" size="20" maxlength="14" value="<%=(carregaFi ? fi.getNumeroRntrc() : "0")%>" class="inputtexto">
                        </td>
                        
                    </tr>
                    <tr>
                        <td width="40%" class="TextoCampos" colspan="1">
                            <label>                                
                                <input type="checkbox" name="isContingenciaFSDA" id="isContingenciaFSDA" <%=(carregaFi ? (fi.isContingenciaFsda()? "checked" : "") : "")%> value="true" onclick="javascript:infoFsda();">
                                Contingência em FS-DA 
                            </label>
                        </td>                         
                        <td width="40%" class="TextoCampos" colspan="1">Versão CT-e:</td>
                        <td width="40%" class="CelulaZebra2" colspan="6">
                            <label>
                                <div>
                                    <select name="versaoCTE" id="versaoCTE" class="inputtexto">
                                        <option value="200" <%=(carregaFi && fi.getVersaoUtilizacaoCte().equals("200") ? "selected" : "")%>>2.00</option>
                                        <option value="300" <%=(carregaFi && fi.getVersaoUtilizacaoCte().equals("300") ? "selected" : "")%>>3.00</option>
                                        
                                    </select>
                                </div>
                            </label>
                        </td>
                    </tr>
                        <tr id="infoFsda" style="display: none">
                         <td width="40%" class="TextoCampos" colspan="1">
                             Justificativa:                      </td> 
                         <td width="40%" class="TextoCampos" colspan="1">
                             <input name="justificativaFSDA" id ="justificativaFSDA" type="text" size="20" class="inputtexto" value="<%=(carregaFi ? fi.getJustificativaFsda(): "")%>">
                         </td>
                         <td width="40%" class="TextoCampos" colspan="1">Data:
                             </td>
                         <td width="40%" class="TextoCampos" colspan="1">
                             
                             <input name="dataFSDA" id ="dataFSDA" type="text" size="10" class="inputtexto" onBlur="alertInvalidDate(this)" class="fieldDate" value="<%=(carregaFi ? fmt.format((fi.getDataFsda() != null ? (fi.getDataFsda()) : new Date())) : Apoio.getDataAtual())%>" onkeypress="mascaraData(this)">
                         </td>
                         <td width="40%" class="TextoCampos" colspan="1">
                             Hora:</td>
                         <td width="40%" class="TextoCampos" colspan="1">
                             <input name="horaFSDA" id ="horaFSDA" type="text" size="8" class="inputtexto" value="<%=(carregaFi && fi.getHoraFsda()!= null ? (fi.getHoraFsda()) : new SimpleDateFormat("HH:mm").format(new Date()))%>" onkeypress="mascaraHora(this)">
                         </td>                    
                         <td width="40%" class="TextoCampos" colspan="1"></td>                             
                         <td width="40%" class="TextoCampos" colspan="1"></td>                    
                     </tr>
                        <tr>
                            <td colspan="2" align="center" class="CelulaZebra2">
                                <label class="textoCampos">
                                <input type="checkbox" id="horaCancelamentoCte" name="horaCancelamentoCte" <%=(carregaFi && fi.isHoraCancelamentoCte() ? "checked" : "")%>>
                                Acrescentar 1 hora a requisição de cancelamento do CTe.</label>
                            </td>
                            <td colspan="4" align="center" class="CelulaZebra2">
                                 <label class="textoCampos">
                                <input type="checkbox" id="obrigaSequenciaCte" name="obrigaSequenciaCte" <%=(carregaFi && fi.isObrigaSequenciaCte() ? "checked" : "")%>>
                                Obriga o CTe a seguir uma sequência numérica.</label>
                            </td>
                            <td align="center" class="CelulaZebra2">
                            </td>
                            <td align="center" class="CelulaZebra2">
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos" colspan="2">
                                <label>Série padrão para emissão do CT-e:</label>
                            </td>
                            <td class="CelulaZebra2" colspan="6">
                                <label class="TextoCampos">Aéreo:</label>
                                <input type="text" id="seriePadraoCTeAereo" name="seriePadraoCTeAereo" class="inputtexto" value="<%=(carregaFi ? fi.getSeriePadraoCTeAereo(): "")%>" size="5" maxlength="8"/>
                                <label class="TextoCampos">Aquaviário:</label>
                                <input type="text" id="seriePadraoCTeAquaviario" name="seriePadraoCTeAquaviario" class="inputtexto" value="<%=(carregaFi ? fi.getSeriePadraoCTeAquaviario(): "")%>" size="5" maxlength="8"/>
                                <label class="TextoCampos">Rodoviário:</label>
                                <input type="text" id="seriePadraoCTeRodoviario" name="seriePadraoCTeRodoviario" class="inputtexto" value="<%=(carregaFi ? fi.getSeriePadraoCTeRodoviario(): "")%>" size="5" maxlength="8"/>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="8" class="CelulaZebra2NoAlign">
                                <div align="center">
                                    <label>
                                        <input type="checkbox" id="enviarIcms" name="enviarIcms" onclick="habilitarCheck(this)" <%=(carregaFi && fi.isAtivaDivisaoIcms() ? "checked" : "")%>> 
                                        Ativar a divisão de ICMS para UF de destino ao emitir CT-e FOB para fora da UF quando o destinatário for consumidor final (EC 87/2015)
                                    </label>                                    
                                </div>
                            </td>
                        </tr>
                        <tr id="isAtivarEnvioPercentualICMS" style="<%= (carregaFi && fi.isAtivaDivisaoIcms() ? "" : "display: none") %>">
                            <td colspan="8" class="CelulaZebra2NoAlign">
                                <div align="center">
                                    <label>
                                        <input type="checkbox" id="envioPercentual" name="envioPercentual" onclick="" <%=(carregaFi && fi.isAtivaDivisaoIcms() && fi.isAtivaCombatePobreza() ? "checked" : "")%>>
                                        Ativar envio do percentual de ICMS correspondente ao fundo de combate à pobreza na UF de término da prestação
                                    </label>                                    
                                </div>
                            </td>
                        </tr>
                    <tr class="CelulaZebra2">
                        <td colspan="1" align="center">
                            <table width="100%" border="0" cellspacing="1" cellpadding="2" class="bordaFina">
                                <thead>
                                    <tr class="tabela">
                                        <th colspan="4" align="center">CNPJ(s) autorizados a baixar o XML do CT-e da SEFAZ</th>
                                    </tr>
                                    <tr class="celula">
                                        <th width="5%">
                                            <img src="${homePath}/img/add.gif" class="imagemLink" id="btnAdicionarCnpjAutorizadoCTe">
                                        </th>
                                        <th width="35%">
                                            <label>CNPJ</label>
                                        </th>
                                        <th width="60%"></th>
                                    </tr>
                                </thead>
                                <tbody id="bodyCnpjAutorizadoCTe">
                                </tbody>
                                <input type="hidden" id="qtdDomCnpjAutorizadoCTe" name="qtdDomCnpjAutorizadoCTe" value="0">
                            </table>
                        </td>
                        <td colspan="7"></td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr class="tabela">
            <td colspan="4" align="center">Informa&ccedil;&otilde;es Manifesto Eletrônico (MDF-e)</td>
        </tr>
        <tr>
            <td colspan="4" align="center">
                <table width="100%" border="0" cellspacing="1" cellpadding="2" class="bordaFina">
                    <tr>
                        <td width="15%" class="TextoCampos" align="left">Status MDF-e:</td>
                        <td width="15%" class="CelulaZebra2">
                            <label>
                                <div>
                                    <select name="stUtilizacaoMDFe" id="stUtilizacaoMDFe" class="inputtexto">
                                        <option value="N" <%=(carregaFi && fi.getStUtilizacaoMDFe() == 'N' ? "selected" : "")%>>Não Utiliza</option>
                                        <option value="H" <%=(carregaFi && fi.getStUtilizacaoMDFe() == 'H' ? "selected" : "")%>>Homologação</option>
                                        <option value="P" <%=(carregaFi && fi.getStUtilizacaoMDFe() == 'P' ? "selected" : "")%>>Produção</option>
                                        <option value="C" <%=(carregaFi && fi.getStUtilizacaoMDFe() == 'C' ? "selected" : "")%>>Conting&ecirc;ncia</option>
                                    </select>
                                </div>
                            </label>
                        </td>
                         <td width="15%" class="TextoCampos" align="left">Versão Layout MDF-e:</td>
                        <td width="15%" class="CelulaZebra2">
                            <label>
                                <div>
                                    <select name="versaoMDFe" id="versaoMDFe" class="inputtexto">
                                        <option value="100" <%=(carregaFi && fi.getVersaoUtilizacaoMdfe().equals("100") ? "selected" : "")%>>1.00</option>
                                        <option value="300" <%=(carregaFi && fi.getVersaoUtilizacaoMdfe().equals("300") ? "selected" : "")%>>3.00</option>                                       
                                    </select>
                                </div>
                            </label>
                        </td>
                        <td width="15%" class="TextoCampos" align="left">Série MDF-e:</td>
                        <td width="15%" class="CelulaZebra2">
                            <input type="text" class="inputtexto" id="serieMdfe" name="serieMdfe" value="<%=(carregaFi ? fi.getSerieMdfe() : "")%>" size="5" maxlength="8"/>
                        </td>
                    </tr>
                    <!-- 09/08/2018 history-113 -->
                    <tr>
                        <td width="15%" class="TextoCampos" colspan="6">
                            <div align="center">
                                <input type="checkbox" id="checTravaManifesto" name="checTravaManifesto" onclick="javascript:desabilitarInclusaoManifesto();" <%=(carregaFi && fi.isAtivarDiasMdfeEncerrados() ? "checked" : "")%>>
                                Não permitir inclusão de novos manifestos caso exista outro manifesto com mais de <input type="text" id="diasTravaManifesto" name="diasTravaManifesto" class="inputtexto" oninput="somenteNumeros(this)" size="3" maxlength="3" value="${diasTrava}"> dia(s) que ainda não tenha sido encerrado
                            </div>
                        </td>
                    </tr>
                    <!-- 09/08/2018 history-113 -->
                    <tr class="CelulaZebra2">
                        <td colspan="2" align="center">
                            <table width="100%" border="0" cellspacing="1" cellpadding="2" class="bordaFina">
                                <thead>
                                <tr class="tabela">
                                    <th colspan="4" align="center">CNPJ(s) autorizados a baixar o XML do MDF-e da SEFAZ</th>
                                </tr>
                                <tr class="celula">
                                    <th width="5%">
                                        <img src="${homePath}/img/add.gif" class="imagemLink" id="btnAdicionarCnpjAutorizadoMDFe">
                                    </th>
                                    <th width="35%">
                                        <label>CNPJ</label>
                                    </th>
                                    <th width="60%"></th>
                                </tr>
                                </thead>
                                <tbody id="bodyCnpjAutorizadoMDFe">
                                </tbody>
                                <input type="hidden" id="qtdDomCnpjAutorizadoMDFe" name="qtdDomCnpjAutorizadoMDFe" value="0">
                            </table>
                        </td>
                        <td colspan="4"></td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr class="tabela">
            <td colspan="4" align="center">Gerenciador de Risco</td>
        </tr>
        <tr>
            <td colspan="4" align="center">
                <table width="100%" border="0" cellspacing="1" cellpadding="3" class="bordaFina">
                    <tr>
                        <td width="15%" class="TextoCampos" colspan="2">Gerenciadora de Risco:</td>
                        <td width="15%" class="CelulaZebra2" colspan="1">
                            <input type="hidden" id="filialGerenciamentoRiscoId" name="filialGerenciamentoRiscoId" value="<%= (carregaFi ? fi.getFilialGerenciadorRisco().getId() : 0)%>"/>
                            
                            <select name="gerenciamentoRiscoId" id="gerenciamentoRiscoId" class="inputtexto" onchange="javascript:habilitarGerenciamentoRisco();">
                                <%
                                    for (GerenciadorRisco gerenciadorRisco : gerenciadorRiscos) {
                                %>
                                <option value="<%= gerenciadorRisco.getId()%>" <%= carregaFi && fi.getFilialGerenciadorRisco().getGerenciadorRisco().getId() == gerenciadorRisco.getId() ? "selected" : ""%>><%= gerenciadorRisco.getDescricao()%></option>
                                <%
                                    }
                                %>
                            </select>
                        </td>
                        <td width="15%" class="CelulaZebra2" colspan="1">
                            <div id="divStUtilizacaoGerenciadoraRisco" name="divStUtilizacaoGerenciadoraRisco" class="TextoCampos">Status:</div>
                        </td>
                        <td width="15%" class="CelulaZebra2" colspan="1">
                            <select name="stUtilizacaoGerenciadoraRisco" id="stUtilizacaoGerenciadoraRisco" class="inputtexto">
                                <option value="0" <%= carregaFi && fi.getFilialGerenciadorRisco().getStUtilizacao() == 0 ? "selected" : ""%>>Não Utiliza</option>
                                <option value="1" <%= carregaFi && fi.getFilialGerenciadorRisco().getStUtilizacao() == 1 ? "selected" : ""%>>Homologação</option>
                                <option value="2" <%= carregaFi && fi.getFilialGerenciadorRisco().getStUtilizacao() == 2 ? "selected" : ""%>>Produção</option>
                            </select>
                        </td>
                    </tr>
                    <tr id="trGerenciadoraRisco" name="trGerenciadoraRisco">
                        <td width="15%" class="TextoCampos" colspan="2">Código:</td>
                        <td width="15%" class="CelulaZebra2" colspan="1">
                            <label>
                                <div>
                                    <input type="text" class="inputTexto" id="codigoGerenciadoraRisco" name="codigoGerenciadoraRisco" value="<%= carregaFi && fi.getFilialGerenciadorRisco().getCodigo() != null ? fi.getFilialGerenciadorRisco().getCodigo() : ""%>">
                                </div>
                            </label> 
                        </td>
                        <td width="15%" class="TextoCampos" colspan="1">
                            Senha:
                        </td>
                        <td width="15%" class="TextoCampos" colspan="1"> 
                            <label>
                                <div align="left">
                                    <input type="password" class="inputTexto" id="senhaGerenciadoraRisco" name="senhaGerenciadoraRisco" value="<%= carregaFi && fi.getFilialGerenciadorRisco().getSenha() != null ? fi.getFilialGerenciadorRisco().getSenha() : ""%>">
                                </div>
                            </label>
                        </td>
                    </tr>
                    <tr id="trGerenciadoraRisco2" name="trGerenciadoraRisco2">
                        <td width="15%" class="TextoCampos" colspan="2">ID:</td>
                        <td width="15%" class="CelulaZebra2" colspan="1">
                            <label>
                                <div>
                                    <input type="text" class="inputTexto" id="idGerenciadoraRisco" name="idGerenciadoraRisco" value="<%= carregaFi ? fi.getFilialGerenciadorRisco().getPgrId() : ""%>">
                                </div>
                            </label> 
                        </td>
                        <td width="15%" colspan="1" class="TextoCampos">A partir da data:</td>
                        <td width="15%" colspan="1" class="CelulaZebra2">
                            <input name="dataUsoGerenciadoraRiscoService" type="text" id="dataUsoGerenciadoraRiscoService" size="10" maxlength="10" value="<%= carregaFi && fi.getFilialGerenciadorRisco().getDataInicioUso() != null ? fmt.format(fi.getFilialGerenciadorRisco().getDataInicioUso()) : dataAtual%>" onkeypress="fmtDate(this, event)" onblur="alertInvalidDate(this, true)" class="fieldDate">
                        </td>    
                    </tr>
                    <tr id="trGerenciadoraRisco3" name="trGerenciadoraRisco3">
                        <td width="15%" class="TextoCampos" colspan="2">Tipo Bloqueio Rastreamento:</td>
                        <td width="15%" class="CelulaZebra2" colspan="1">
                            <label>
                                <div >
                                    <select name="tipoBloqueioRastreamento" id="tipoBloqueioRastreamento" class="inputtexto">
                                        <option value="1" <%= carregaFi && fi.getFilialGerenciadorRisco().getTipoBloqueioRastreamento() == 1 ? "selected" : ""%>>Aviso</option>
                                        <option value="2" <%= carregaFi && fi.getFilialGerenciadorRisco().getTipoBloqueioRastreamento() == 2 ? "selected" : ""%>>Bloqueio</option>
                                    </select>
                                </div>
                            </label>
                        </td>
                        <td width="15%" class="CelulaZebra2" colspan="1"></td>
                        <td width="15%" class="CelulaZebra2" colspan="1"></td>
                    </tr>
                   
                </table>
            </td>
        </tr>
         
        <tr class="tabela">
            <td colspan="4" align="center">Informa&ccedil;&otilde;es Contrato de Frete Eletrônica (CF-e)</td>
        </tr>
        <tr>
            <td colspan="4" align="center">
                <table width="100%" border="0" cellspacing="1" cellpadding="2" class="bordaFina">  
                    <tr>
                        <td width="15%" class="TextoCampos">Status CF-e:</td>
                        <td width="20%" class="CelulaZebra2">
                            <label>
                                <div>
                                    <select name="stUtilizacaoCfe" id="stUtilizacaoCfe" class="inputtexto" onchange="alteraCfe()">  
                                        <option value="N" <%=(carregaFi && fi.getStUtilizacaoCfe() == 'N' ? "selected" : "")%>>Não Utiliza</option>
                                        <option value="D" <%=(carregaFi && fi.getStUtilizacaoCfe() == 'D' ? "selected" : "")%>>NDD Cargo</option>
                                        <option value="P" <%=(carregaFi && fi.getStUtilizacaoCfe() == 'P' ? "selected" : "")%>>Pamcard</option>
                                        <option value="R" <%=(carregaFi && fi.getStUtilizacaoCfe() == 'R' ? "selected" : "")%>>Repom</option>
                                        <option value="E" <%=(carregaFi && fi.getStUtilizacaoCfe() == 'E' ? "selected" : "")%>>eFrete</option>
                                        <option value="X" <%=(carregaFi && fi.getStUtilizacaoCfe() == 'X' ? "selected" : "")%>>ExpeRS</option>
                                        <option value="G" <%=(carregaFi && fi.getStUtilizacaoCfe() == 'G' ? "selected" : "")%>>PagBem</option>
                                        <option value="A" <%=(carregaFi && fi.getStUtilizacaoCfe() == 'A' ? "selected" : "")%>>Target</option>
                                    </select>
                                </div>
                            </label>
                        </td>
                        <td width="23%" class="TextoCampos">
                            <!--lbAgente-->
                            <label id="lbAgente" name="lbAgente">Agente Pagador:</label>
                            <!--lbContaNdd
                            <label id="lbContaNdd" name="lbContaNdd">Conta Ndd</label>-->
                            <!-- lbContaTicketFrete
                            <label id="lbContaTicketFrete" name="lbContaTicketFrete">Conta TicketFrete:</label>-->
                        </td>
                        <td width="42%" class="CelulaZebra2" >
                            <!-- Agente pagador -->
                            <input name="agente" type="text" id="agente" class="inputReadOnly" readonly value="<%=(carregaFi ? fi.getAgentePagadorRepom().getRazaosocial() : "")%>" size="35" maxlength="35">
                            <input name="idagente" type="hidden" id="idagente" class="inputReadOnly" readonly value="<%=(carregaFi ? fi.getAgentePagadorRepom().getIdfornecedor() : "0")%>" size="27" maxlength="35">
                            <input name="localiza_agente" id="localiza_agente" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=16','Agente')" value="...">
                           
                            </td>
                    </tr>  
                   
                    
                    <tr id="linhaNova0" name="linhaNova0"> 
                        <td colspan="2" class="celulaZebra2"  style="text-align:center">
                            <div align="left" id="divlinhaNova0">
                                <label class="TextoCampos">
                                    <input type="checkbox" name="isCalcularPedagioCfe" id="isCalcularPedagioCfe" <%=(carregaFi ? (fi.isCalcularPedagioCfe() ? "checked" : "") : "checked")%> value="true">
                                    Calcular Ped&aacute;gio
                                </label>                                
                            </div>
                        </td>
                        <td class="TextoCampos">
                            <div align="right" id="divlinhaNova1">
                                <label id="lbCNPJ" name="lbCNPJ"></label>
                                <!--<label id="lbContaRepom" class="repom">Conta repom:</label>-->
                            </div>
                        </td>
                        <td class="CelulaZebra2">
                            <div align="left" id="divlinhaNova2">
                                <input name="cnpjContratante" type="text" id="cnpjContratante" value="<%=(carregaFi ? fi.getCnpjContratantePamcard() : "")%>" class="inputTexto" size="25" maxlength="18">
                               
                               </div>
                        </td>
                    </tr>
                    <!--<tr id="linhaNova01" name="linhaNova01" style="display: none">
                         <td colspan="2" class="celulaZebra2"  style="text-align:center">
                            <label>
                                <input type="checkbox" name="isHomologacaoCfe" id="isHomologacaoCfe" <%=(carregaFi ? (fi.isHomologacaoCfe() ? "checked" : "") : "checked")%> value="true">
                                Uso em Homologa&ccedil;&atilde;o
                            </label>
                        </td>
                         <td class="TextoCampos"></td>
                          <td class="TextoCampos"></td>
                    </tr>-->
                    
                    <tr class="celulaZebra2" id="linhaNova" name="linhaNova" style="display: none;text-align: center">
                       
                            <td colspan="2" >
                                <label class="textoCampos">
                                    <div align="left">                                    
                                        <input type="checkbox" name="isHomologacaoCfe" id="isHomologacaoCfe" <%=(carregaFi ? (fi.isHomologacaoCfe() ? "checked" : "") : "checked")%> value="true">
                                        Uso em Homologa&ccedil;&atilde;o
                                    </div>
                                </label>
                            </td>
                            <td class="TextoCampos">
                                <!--<label id="lbContaPancard" name="lbContaPancard">Conta Pamcard</label>-->
                                <label id="lbcnpj_confirmador_ndd" name="lbcnpj_confirmador_ndd">CPF/CNPJ confirmador ndd</label> 
                            </td>
                            <td class="CelulaZebra2">
                               <input type="text" name="cnpj_confirmador_ndd" id="cnpj_confirmador_ndd" size="20" maxlength="20" class="inputTexto" value="<%=(carregaFi ? fi.getCpfCnpjConfirmadorNdd() : "")%>" onchange="this.onblur" onblur="" onkeypress="mascara(this, soNumeros);">
                            </td>
                       
                            <tr class="celulaZebra2" id="maisLinha" name="maisLinha">
                                <td class="TextoCampos" colspan="2">
                                    <div align="left">
                                        <label>
                                            <input type="checkbox" id="confirmarPagamentoNDD" name="confirmarPagamentoNDD" <%=(carregaFi ? (fi.isConfirmarPagamentoNDD() ? "checked" : "") : "checked")%> value="true"/>
                                            Transmitir pagamento do saldo para operadora.
                                        </label>                                        
                                    </div>
                                </td>
                                <!--<td></td>-->
                                <td class="textoCampos"><label id="tipoEfetivacao" name="tipoEfetivacao" align="right">Tipo efetivação</label>
                                <td class="celulaZebra2" id="tdSelectconfirmador" name="tdSelectconfirmador">
                                      <select name="Selectconfirmador" id="Selectconfirmador" class="inputtexto">  
                                          <option value="1" <%=(carregaFi && fi.getTipoEfetivacao() == 1 ? "selected" : "")%>>POSTO CREDENCIADO</option>
                                          <option value="4" <%=(carregaFi && fi.getTipoEfetivacao() == 4 ? "selected" : "")%>>CONFIRMAÇÃO ELETRÔNICA</option>
                                      </select>
                                </td> 
                                
                           </tr>
                         </tr>
                         <tr class="celulaZebra2 pamcard" id="trPamcardServidor">
                             <td style="text-align: center" colspan="2" class="celulaZebra2" >                                 
                                 <label>                                     
                                     <input type="checkbox" name="utilizarCertificadoA1" id="utilizarCertificadoA1" <%=(carregaFi ? (fi.isUtilizarCertificadoA1Pamcard() ? "checked" : "") : "checked")%> value="true" >
                                     Utilizar certificado A1
                                 </label>
                             </td>
                             
                             <td class="textoCampos"></td>
                             <td class="celulaZebra2"></td>
                         </tr>   
                          <tr id="despesaDescarga" style="display: none">
                            <td colspan="3" class="celulaZebra2">
                                <div align="left" id="divCriarParcelaValorDescarga">
                                    <label class="textoCampos">
                                        <input type="checkbox" name="criarParcelaValorDescarga" id="criarParcelaValorDescarga" <%=(carregaFi ? (fi.isCriarParcelaValorDescarga()? "checked" : "") : "")%> value="true">
                                        Ao gerar CIOT, criar uma despesa separada para o valor da descarga na NDD.
                                    </label>                                    
                                </div>
                            </td>
                            <td colspan="3" class="TextoCampos">
                                <div align="left" id="divHabilitarGerarCIOTTAC">
                                    <label>
                                        <input type="checkbox" name="gerarOpcaoCIOTTacAgregado" id="gerarOpcaoCIOTTacAgregado" <%=(carregaFi ? (fi.isOpcaoGerarCIOTTacAgregado()? "checked" : "") : "")%> value="true">
                                        Habilitar opção de gerar CIOT TAC Agregado
                                    </label>                                    
                                </div>
                            </td>
                        </tr>
                        
                        <tr id="tarifasBancarias">
                            <td width="25%" class="celulaZebra2">
                                <div align="left">
                                    <label class="textoCampos">
                                        <input type="checkbox" name="controlarTarifasBancarias" id="controlarTarifasBancarias" <%=(carregaFi ? (fi.isControlarTarifasBancariasContratado()? "checked" : "") : "")%> value="true" onclick="javascript:habilitarValorTarifas();">
                                        Controlar Tarifas Bancárias do Contratado.
                                    </label>                                    
                                </div>
                            </td>
                            <td width="30%" class="TextoCampos" >
                                <div align="center" id="valorTarifasSaque" style="display: none">Quantidade de Saques:
                                <input name="qtdSaques" type="text" id="qtdSaques" value="<%=(carregaFi ? fi.getQuantidadeSaquesContratoFrete(): "")%>" class="inputTexto" size="3" maxlength="5" onkeypress="soNumeros(this.value)">
                           
                                Valor por Saques:
                                <input name="valorPorSaques" type="text" id="valorPorSaques" value="<%=(carregaFi ? fi.getValorSaquesContratoFrete(): "0.00")%>" class="inputTexto" size="5" onkeypress="soNumeros(this.value);mascara(this, reais)" maxlength="10" >
                                </div>
                            </td>
                            <td colspan="2" class="TextoCampos" >
                                <div align="center" id="valorTarifasTransf" style="display: none">Quantidade de Transferências
                                <input name="qtdTransf" type="text" id="qtdTransf" value="<%=(carregaFi ? fi.getQuantidadeTransferenciasContratoFrete(): "")%>" class="inputTexto" size="3" maxlength="5" onkeypress="soNumeros(this.value)">
                           
                                Valor por Transferência:
                                <input name="valorTransf" type="text" id="valorTransf" value="<%=(carregaFi ? fi.getValorTransferenciasContratoFrete(): "0.00")%>" class="inputTexto" size="5"  onkeypress="soNumeros(this.value);mascara(this, reais)"  maxlength="10">
                                </dvi>
                            </td>
                        </tr>
                        
<!--                        <tr id="gerarTacAgregado" >
                            <td colspan="6" class="TextoCampos"  style="text-align:center">
                                <label>
                                    <input type="checkbox" name="gerarOpcaoCIOTTacAgregado" id="gerarOpcaoCIOTTacAgregado" <%--(carregaFi ? (fi.isOpcaoGerarCIOTTacAgregado()? "checked" : "") : "")--%> value="true">
                                    Habilitar opção de gerar CIOT TAC Agregado
                                </label>
                            </td>
                        </tr>-->
                        <tr class="celulaZebra2" id="trNatureza">
                             <td style="text-align: right" class="TextoCampos">Natureza da Carga: </td>
                                    <td class="CelulaZebra2" colspan="1">
                                        <input type="hidden" name="natureza_cod" id="natureza_cod" value='<%= carregaFi ? (fi.getNaturezaCargaContratoFrete().getCod()) : 0 %>' /> 
                                        <input type="text"class="inputReadOnly8pt" name="natureza_cod_desc" id="natureza_cod_desc" size="4" readonly value='<%= carregaFi ? (fi.getNaturezaCargaContratoFrete().getCodigo()==null? "" : fi.getNaturezaCargaContratoFrete().getCodigo()) : 0 %>'> 
                                        <input type="text"class="inputReadOnly8pt" name="natureza_desc" id="natureza_desc" size="23" readonly value='<%= carregaFi ? (fi.getNaturezaCargaContratoFrete().getDescricao()==null? "" : fi.getNaturezaCargaContratoFrete().getDescricao()) : "" %>'> 
                                        <input type="button" class="inputBotaoMin" id="botaoCarreta" onclick=" javascript:tryRequestToServer(function (){abrirLocalizaNatureza()});" value="..." /> 
                                        <img src="img/borracha.gif" alt="" name="borrachaNatureza" class="imagemLink" id="borrachanatureza" onclick="limparNatureza()" />
                                    </td>
                                               
                                    <td class="TextoCampos" id="tdcontacfe1">
                                            Conta CF-e:
                                    </td>                                    
                                    <td class="CelulaZebra2" id="tdcontacfe2">
                                        <input name="contaCfe" type="" id="contaCfe" value="<%=(carregaFi ? fi.getContaCfe().getDescricao(): "")%>" class="inputReadOnly" readonly size="25" maxlength="18">
                                        <input name="contaCfeId" type="hidden" id="contaCfeId" value="<%=(carregaFi ? fi.getContaCfe().getIdConta() : "")%>" class="inputReadOnly" readonly size="25" maxlength="18">
                                        <input name="localiza_conta_cfe" id="localiza_conta_cfe" type="button" class="botoes cfe" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=31&paramaux=and is_utiliza_carta_frete ', 'Conta_CFe')" value="...">
                                    </td>
                                    
                        </tr>                    
                        <tr class="celulaZebra2" id="trIntFinan" style="display: none">
                            <td colspan="2">
                                <div >
                                    <input type="checkbox" name="isRetencaoImpostoOperadoraCFe" id="isRetencaoImpostoOperadoraCFe" <%=(carregaFi ? (fi.isRetencaoImpostoOperadoraCFe()? "checked" : "") : "")%> value="true">
                                    A retenção de impostos será realizada pela REPOM
                                </div>
                            </td>
                             <td>
                                 <div>
                                    <input type="checkbox" name="isDescontarTaxaCartaoContratado" id="isDescontarTaxaCartaoContratado" <%=(carregaFi ? (fi.isDescontarTaxaCartaoContratado()? "checked" : "") : "")%> >
                                    Descontar taxa de ativação do cartão do contratado
                                </div>
                            </td>
                            <td>
                            </td>
                        </tr>
                        <tr class="celulaZebra2" id="trInfoEFrete" style="display: none">
                             <td class="TextoCampos" style="text-align: center" colspan="2" > <div id="tdCnpjMatriz">CNPJ da Matriz: <input type="text" id="cnpjMatriz" name="cnpjMatriz" class="inputTexto" onKeyPress="javascript:digitaCnpj();" size="20" maxlength="14" value="<%=(carregaFi ? (fi.getCnpjMatriz()==null? "" : fi.getCnpjMatriz()) : "")%>" ></div></td>
                            <td class="TextoCampos" style="text-align: center"  ><div id="tdEmissaoGratuita" ><label><input type="checkbox" id="emissaoGratuita" name="emissaoGratuita" value="checkbox" <%=(carregaFi ? (fi.isEmissaoGratuita()? "checked" : "") : "")%> >Emissao Gratuita </label></div>
                           
                                <div id="divPagBemCodigo" style="display: none">
                                    Código integração CF-e:
                                    <input name="codigoIntegracaoCfe" class="inputtexto" type="text" id="codigoIntegracaoCfe" value="<%= (carregaFi ? (fi.getCodigoIntegracaoCfe().equals("") ? "" : fi.getCodigoIntegracaoCfe()) : "")%>" size="20" maxlength="20">                                                    
                                </div>
                            </td> 
                            
                            
                            <td class="TextoCampos"style="text-align: center" colspan="2" ><div id="tdPermitirSemTAC"><label><input  type="checkbox" id="permitirCiotContratadosSemTacEquiparados" name="permitirCiotContratadosSemTacEquiparados" value="checkbox" <%=(carregaFi ? (fi.isPermitirCiotContratadosSemTacEquiparados()? "checked" : "") : "")%> >Permitir geração de CIOT para Contratados que não sejam TAC ou Equiparados </label></div></td>
                                    
                        </tr>
                        <tr class="celulaZebra2" id="trInfoEFrete2" style="display: none">
                             <td class="TextoCampos" style="text-align: center" colspan="1">
                                 <div id="tdCheckBoxEfrete">
                                     <label><input type="checkbox" id="isUtilizaLoginEfrete" name="isUtilizaLoginEfrete" class="inputbotao" onchange="utilizaLoginSenhaEfrete()" <%=(carregaFi ? (fi.isUtilizaLoginEfrete() ? " checked " : "") : "")%>> Utiliza Pré-cadastro </label>
                                 </div>
                             </td>
                             <td class="TextoCampos" style="text-align: center" colspan="2">
                                 <div id="tdLoginEfrete">Usuário E-Frete: 
                                     <input type="text" id="loginEfrete" name="loginEfrete" class="inputTexto" size="40" maxlength="40" value="<%=(carregaFi ? (fi.getLoginEfrete()==null? "" : fi.getLoginEfrete()) : "")%>">
                                 </div>
                             </td>
                             <td class="TextoCampos" style="text-align: center" colspan="1">
                                 <div id="tdSenhaEfrete">Senha E-Frete: 
                                     <input type="text" id="senhaEfrete" name="senhaEfrete" class="inputTexto" size="20" maxlength="20" value="<%=(carregaFi ? (fi.getSenhaEfrete()==null? "" : fi.getSenhaEfrete()) : "")%>">
                                 </div>
                             </td>
                                    
                        </tr>
                      
                        <tr class="CelulaZebra2" id="trExpers" style="display: none">  
                            <td class="TextoCampos" style="text-align: center" colspan="2">Chave de Acesso da Integração: 
                                <input type="text" id="chaveAcessoInteg" name="chaveAcessoInteg" class="inputTexto" size="50" maxlength="100" value="<%=(carregaFi ? (fi.getChaveAcessoIntegracao()==null? "" : fi.getChaveAcessoIntegracao()) : "")%>" ></td>
                            <td class="TextoCampos" style="text-align: center" colspan="2">QTD de dias para liberação da parcela de quitação após a quitação do saldo:
                                <input type="text" class="inputTexto" id="qtdDiasQuitSaldo" name="qtdDiasQuitSaldo" maxlength="3" size="5" value="<%= (carregaFi ? (fi.getQtdDiasQuitSaldo() == 0 ? "" : String.valueOf(fi.getQtdDiasQuitSaldo())) : "")%>" />
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" id="trExpers2" style="display: none">  
                            <td class="TextoCampos" style="text-align: center" colspan="2">
                                <label>
                                <input type="checkbox" name="solicitarConferenciaDocumentoCiot" id="solicitarConferenciaDocumentoCiot" <%=(carregaFi ? (fi.isSolicitarConferenciaDocumentoCiot()? "checked" : "") : "")%> value="true">
                                
                                Ao quitar o saldo, solicitar a conferência dos documentos.
                                </label>
                            </td> 
                            <td class="TextoCampos" style="text-align: center" colspan="3">
                                </td>
                                                      
                        </tr>
                        <tr class="celulaZebra2" id="trInfoPagBem" style="display: none">
                            <td class="TextoCampos" style="text-align: center" colspan="1" > Login PagBem: <input type="text" id="loginPagBem" name="loginPagBem" class="inputTexto" onKeyPress="javascript:digitaCnpj();" size="20" maxlength="14" value="<%=(carregaFi ? (fi.getLoginPagBem() == null ? "" : fi.getLoginPagBem()) : "")%>" ></td>
                            <td class="TextoCampos" style="text-align: center"  colspan="1"> Senha PagBem:
                                <input class="inputtexto" type="text" id="senhaPagBem" name="senhaPagBem" value="<%= (carregaFi ? (fi.getSenhaPagBem().equals("") ? "" : fi.getSenhaPagBem()) : "")%>" size="20" maxlength="20">                                                    
                            </td> 
                            <td class="TextoCampos" colspan="2" style="text-align: center"> 
                                <label>
                                    <input type="checkbox" name="viagemLiberada" id="viagemLiberada" <%=(carregaFi ? (fi.isViagemLiberadaCFe() ? "checked" : "") : "checked")%> value="true">
                                    Ao gerar CIOT, a viagem deverá ir liberada

                                </label>
                            </td>  
                        </tr>
                        <tr id="trCodigoRepom" name="trCodigoRepom" class="celulaZebra2"  style="display:none">                            
                            <td colspan="8">
                                <table class="bordaFina" border ="0" width="50%">
                                    <tr class="tabela" width="100%">
                                        <td align="center" colspan="4"><div align="center" style="width: 100%">Campos de Movimentação da Repom</div></td></tr>
                                           <tr class="celula">
                                            <td width="5%"><input id="maxCodigoR" name="maxCodigoR" value="0" type="hidden" />
                                                <img src="img/add.gif" title="Movimentação Repom" class="imagemLink" onClick="javascript:addCodigoMovimentoRepom();"> </td>
                                            <td >Código Repom </td>
                                            <td >Movimentação </td>
                                            <td >Campos </td>
                                           
                                        </tr>
                                        <tbody id="tbCodigo"></tbody>
                                </table>
                            </td>
                        </tr>
                        <tr class="celulaZebra2" id="trTarget" style="display: none">
                            <td class="TextoCampos" style="text-align: right" colspan="1">
                                Login Target:
                            </td>
                            <td class="CelulaZebra2" colspan="1">
                                <input type="text" id="loginCFe" name="loginCFe" class="inputTexto" size="20" maxlength="20" value="<%=(carregaFi ? (fi.getLoginCFe() == null ? "" : fi.getLoginCFe()) : "")%>">
                            </td>
                            <td class="TextoCampos" style="text-align: right" colspan="1">
                                Token Target:
                            </td>
                            <td class="CelulaZebra2" colspan="1">
                                <input class="inputtexto" type="password" id="senhaCFe" name="senhaCFe" value="<%= (carregaFi ? (fi.getSenhaCFe() == null ? "" : fi.getSenhaCFe()) : "")%>" size="20" maxlength="20">                                                    
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">
                                <label>Tipo de Carga: </label>
                            </td>
                            <td  class="CelulaZebra2" colspan="3">
                                <select class="fieldMin" id="tipo-carga" name="tipo-carga">
                                    <option value="" <%=(carregaFi && fi.getTipoCarga().equals("") ? "selected" : "")%>>Não informado</option>
                                    <option value="01" <%=(carregaFi && fi.getTipoCarga().equals("01") ? "selected" : "")%>>Carga Geral</option>
                                    <option value="02" <%=(carregaFi && fi.getTipoCarga().equals("02") ? "selected" : "")%>>Carga Granel</option>
                                    <option value="03" <%=(carregaFi && fi.getTipoCarga().equals("03") ? "selected" : "")%>>Carga Frigorìfica</option>
                                    <option value="04" <%=(carregaFi && fi.getTipoCarga().equals("04") ? "selected" : "")%>>Carga Perigosa</option>
                                    <option value="05" <%=(carregaFi && fi.getTipoCarga().equals("05") ? "selected" : "")%>>Carga Neogranel</option>
                                </select>
                            </td>
                        </tr>
                            <!--<td width="5%" style="width: 5% !important" >-->
                                <!--<input id="maxCampoP" name="maxCampoP" value="0" type="hidden" />-->
                                <!--<img src="img/add.gif" title="Movimentação Repom" class="imagemLink" onClick="javascript:addCodigoMovimentoRepom();">-->
                            <!--</td>-->
                            <!--<td width="5%" align="center">Código da Movimentação</td>-->
                            <!--<td width="5%" align="center">Movimentação</td>-->                      
<!--                              <div style="width: 10%; height: 20px;float: left;"> <input id="maxCampoP" name="maxCampoP" value="0" type="hidden" /> <img src="img/add.gif" title="Movimentação Repom" class="imagemLink" onClick="javascript:addCodigoMovimentoRepom();"></div>
                                <div style="width: 45%; height: 20px;float: left">Código da Movimentação</div>
                                <div style="width: 45%; height: 20px;float: left">Movimentação</div>-->
                      

            </table>
                            
            </td>
        </tr>
        <tr class="tabela">
            <td colspan="4" align="center" >Informações sistemas de captação de motoristas</td>
        </tr>
        <tr>
            <td class="textoCampos" >
                Integração com Frete Fácil:
            </td>
            <td class="CelulaZebra2" colspan="3">
                <input type="hidden" name="idFreteFacil" id="idFreteFacil" value="0">
                <select id="tipoAmbienteFreteFacil" name="tipoAmbienteFreteFacil" class="inputtexto">
                    <option value="0">Não Utiliza</option>
                    <option value="1">Homologação</option>
                    <option value="2">Produção</option>
                </select>
            </td>
        </tr>
        <tr>
            <td class="textoCampos">
                Token de envio:
            </td>
            <td class="CelulaZebra2">
                <input type="text" name="tokenEnvioFreteFacil" id="tokenEnvioFreteFacil" value="" class="inputtexto" size="40">
            </td>
            <td class="CelulaZebra2" colspan="2">
                <label><input type="checkbox" id="isEnvioAutomaticoFreteFacil" name="isEnvioAutomaticoFreteFacil"> Enviar Automaticamente ao gerar CIOT</label>
            </td>
        </tr>
        <tr class="tabela">
            <td colspan="4" align="center">Informa&ccedil;&otilde;es Nota Fiscal de Serviço Eletrônica (NFS-e)</td>
        </tr>
        <tr>
            <td colspan="4" align="center">
                
                    <tr>
                        <td width="25%" class="TextoCampos">Status NFS-e:</td>
                        <td width="25%" class="CelulaZebra2">
                            <label>
                                <div>
                                    <select name="stUtilizacaoNfse" id="stUtilizacaoNfse" class="inputtexto" onchange="alteraCfe()">  
                                        <option value="H" <%=(carregaFi && fi.getStUtilizacaoNfse() == 'H' ? "selected" : "")%>>Homologação</option>
                                        <option value="P" <%=(carregaFi && fi.getStUtilizacaoNfse() == 'P' ? "selected" : "")%>>Produção</option>
                                        <option value="S" <%=(carregaFi && fi.getStUtilizacaoNfse() == 'S' ? "selected" : "")%>>Não Utiliza</option>
                                    </select>
                                </div>
                            </label>
                        </td>
                        <td colspan="2"  class="CelulaZebra2" >
                            <label>
                                <div align='center'>                                    
                                    <label class="textoCampos">
                                        <input type="checkbox" id="utilizacaoNFSeG2ka" name="utilizacaoNFSeG2ka" <%=(carregaFi && fi.isUtilizacaoNFSeG2ka() ? "checked" : "")%>/>
                                        Utilizar G2ka para envio NFS-e
                                    </label>
                                </div>
                            </label>
                        </td>
                    </tr>
                    <tr>
                        <td  class="CelulaZebra2" colspan="4">
                            <label>
                                <div align='center'>
                                    <label class="textoCampos">                                        
                                        <input type="checkbox" id="chkValidaIpNFSeG2ka" name="chkValidaIpNFSeG2ka" <%=(!carregaFi ? "checked" : carregaFi && fi.isValidaIpNFSeG2ka() ? "checked" : "")%>/>
                                        Validar ip para NFSe G2ka
                                    </label>
                                </div>
                            </label>
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos" colspan="2">
                            C&oacute;digo de Natureza da Opera&ccedil;&atilde;o:
                        </td>
                        <td class="CelulaZebra2" colspan="2"  >
                            <select onload="concatFieldValue();" name="naturezaOperacao" class="inputtexto" id="naturezaOperacao">
                                <option <%=(carregaFi && fi.getNaturezaOperacao() == 0 ? "selected" : "")%> value="0" selected >Não informado</option>
                                <option <%=(carregaFi && fi.getNaturezaOperacao() == 1 ? "selected" : "")%> value="1">Tributação no município</option>
                                <option <%=(carregaFi && fi.getNaturezaOperacao() == 2 ? "selected" : "")%> value="2">Tributação fora do município</option>
                                <option <%=(carregaFi && fi.getNaturezaOperacao() == 3 ? "selected" : "")%> value="3">Isenção</option>
                                <option <%=(carregaFi && fi.getNaturezaOperacao() == 4 ? "selected" : "")%> value="4">Imune</option>
                                <option <%=(carregaFi && fi.getNaturezaOperacao() == 5 ? "selected" : "")%> value="5">Exigibilidade suspensa por decisão judicial</option>
                                <option <%=(carregaFi && fi.getNaturezaOperacao() == 6 ? "selected" : "")%> value="6">Exigibilidade suspensa por procedimento administrativo</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos" colspan="2">
                            C&oacute;digo de Identifica&ccedil;&atilde;o do Regime Especial de Tributa&ccedil;&atilde;o:
                        </td>
                        <td class="CelulaZebra2" colspan="2" >
                            <select onload="concatFieldValue();" name="regimeEspecialTributacao" class="inputtexto" id="regimeEspecialTributacao">
                                <option <%=(carregaFi && fi.getRegimeEspecialTributacao() == 0 ? "selected" : "")%> value="0" selected >Não informado</option>
                                <option <%=(carregaFi && fi.getRegimeEspecialTributacao() == 1 ? "selected" : "")%> value="1">Microempresa municipal</option>
                                <option <%=(carregaFi && fi.getRegimeEspecialTributacao() == 2 ? "selected" : "")%> value="2">Estimativa</option>
                                <option <%=(carregaFi && fi.getRegimeEspecialTributacao() == 3 ? "selected" : "")%> value="3">Sociedade de profissionais</option>
                                <option <%=(carregaFi && fi.getRegimeEspecialTributacao() == 4 ? "selected" : "")%> value="4">Cooperativa</option>
                                <option <%=(carregaFi && fi.getRegimeEspecialTributacao() == 5 ? "selected" : "")%> value="5">Microempresário Individual (MEI)</option>
                                <option <%=(carregaFi && fi.getRegimeEspecialTributacao() == 6 ? "selected" : "")%> value="6">Microempresário e Empresa de Pequeno Porte (ME EPP)</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td class="CelulaZebra2" colspan="2" >
                            <div align="center">
                                <label class="textoCampos">                                    
                                    <!--<input id="incentivadorCultural" type="checkbox" name="incentivadorCultural" align="center" < c:out value="$ {(filialCadFilial.incentivadorCultural == null || !filialCadFilial.incentivadorCultural ? '' : param.acao == 2 ?'checked':'checked')}"/>>-->
                                    <input id="incentivadorCultural" type="checkbox" name="incentivadorCultural" align="center" <%=(carregaFi && fi.isIncentivadorCultural() ? "checked" : "")%>/>
                                    Incentivador Cultural
                                </label>
                            </div>
                        </td>
                        <td class="CelulaZebra2" colspan="2" >
<!--                            <div align="center">
                                <label class="textoCampos">                                    
                                    <input id="optanteSimplesNacional" type="checkbox" name="optanteSimplesNacional" align="center"/>
                                    Optante Simples Nacional
                                </label>
                            </div>-->
                        </td>
                    </tr>
                    
                    <tr>
                        <td class="CelulaZebra2" colspan="1">
                            <div align="right">
                                <label class="textoCampos"> Status de Averbação NFS-e</label>
                            </div>
                        </td>  
                        <td width="15%" colspan="3" class="CelulaZebra2">
                            <select name="tipoUtilizacaoAverbacaoNFSe" id="tipoUtilizacaoAverbacaoNFSe" class="inputtexto" onchange="alteraAverbacaoNfse();alert('Para as alterações serem efetivadas, faça Logout!')"> 
                                <option value="N" <%=(carregaFi && fi.getTipoUtilizacaoAverbacaoNFSe()== "N" ? "selected" : "")%>>Não Utiliza</option>   
                                <option value="H" <%=(carregaFi && fi.getTipoUtilizacaoAverbacaoNFSe() == "H" ? "selected" : "")%>>Homologação</option>
                                <option value="P" <%=(carregaFi && fi.getTipoUtilizacaoAverbacaoNFSe() == "P" ? "selected" : "")%>>Produção</option>                                      
                            </select>
                        </td>   
                    </tr>
                    <tr id="trAverbacaoNfse" style="display: none">
                            <td width="15%" colspan="1" class="CelulaZebra2">
                                 <div align="right">
                                 <input type="checkbox" class="inputtexto" name="transmitirAutoNfse" id="transmitirAutoNfse"   <%=(carregaFi &&fi.isTransmitirAutomaticamenteConfirmarNfse()? "checked " : "")%>>
                                    Transmitir ao confirmar a NFS-e
                                </div>
                            </td>
                           
                            <td width="15%" class="CelulaZebra2" colspan="3">
                            <select  name="seguradoraNFSe" id="seguradoraNFSe" class="inputtexto"  style="width: 120px;">
                                <% for(CaixaPostalSeguradora postalSeguradora : listaCaixaPostalSeguradora){%>                                
                                     <option value="<%=postalSeguradora.getId()%>"  <%=(carregaFi && fi.getCaixaPostalSeguradoraNFSe().getId() == postalSeguradora.getId() ? "selected" : "")%>><%=postalSeguradora.getDescricao()%></option>  
                                <%}%>                                                                
                            </select>
                        </td> 
                                                         
                    </tr>   
                    
                    <tr>
                        <td colspan="4" align="center" class="tabela">
                            Informações Capa de Lote Eletrônica (CL-e) 
                        </td>
                    </tr>

                    <tr>
                        <td class="TextoCampos"  width="25%">
                            Status CL-e:
                        </td>
                        <td class="CelulaZebra2" width="25%">
                            <select name="stUtilizacaoCle" class="inputtexto" id="stUtilizacaoCle">
                                <option value="H" <%=(carregaFi && fi.getStUtilizacaoCle() == 'H' ? "selected" : "")%>>Homologação</option>
                                <option value="P" <%=(carregaFi && fi.getStUtilizacaoCle() == 'P' ? "selected" : "")%>>Produção</option>
                                <option value="N" <%=(carregaFi && fi.getStUtilizacaoCle() == 'N' ? "selected" : "")%>>Não Utiliza</option>

                            </select>
                        </td>
                        <td class="TextoCampos"  colspan="2" >

                        </td>
                    </tr>
                    <tr>
                        <td colspan="4" align="center" class="tabela">Parametrização para integração com GPS/Roteirizador </td>
                    </tr>
                    <tr>
                        <td colspan="4" align="center">
                            <table width="100%" border="0" cellspacing="1" cellpadding="2">
                                <tr>
                                    <td class="TextoCampos" width="25%">Status Integração com a Buonny:</td>
                                    <td class="CelulaZebra2" width="10%">

                                        <select name="idStUtilizacaoBuonnyRoteirizador" class="inputtexto"
                                                id="idStUtilizacaoBuonnyRoteirizador" onchange="mostrarEnderecoBuonny();">
                                            <option value="H" <%=(carregaFi && fi.getStUtilizacaoBuonnyRoteirizador() == 'H' ? "selected" : "")%>>
                                                Homologação
                                            </option>
                                            <option value="P" <%=(carregaFi && fi.getStUtilizacaoBuonnyRoteirizador() == 'P' ? "selected" : "")%>>
                                                Produção
                                            </option>
                                            <option value="N" <%=(carregaFi && fi.getStUtilizacaoBuonnyRoteirizador() == 'N' ? "selected" : "")%>>
                                                Não Utiliza
                                            </option>
                                        </select>
                                    </td>
                                    <td class="TextoCampos" colspan="3"></td>
                                </tr>
                                <!-- // Logradouro, Bairro, cep, cidade. -->
                                <tr id="trEnderecoBuonny" style="display:none;">
                                    <td align="center" colspan="5" width="100%">
                                        <table width="100%" class="bordaFina">
                                            <tbody name="tbEnderecoBuonny" id="tbEnderecoBuonny">
                                            <tr class="celula">
                                                <td width="2%">
                                                    <img style="vertical-align:middle;" border="0"
                                                         class="imagemLink" onclick="addFilialEndereco()" src="img/add.gif"
                                                         title="Adicionar Endereço"/>
                                                </td>
                                                <td width="25%">Logradouro</td>
                                                <td width="35%">Cidade</td>
                                                <td width="25%">Bairro</td>
                                                <td width="15%">CEP</td>
                                                <td width="10%">Número</td>
                                            </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos" width="25%">Status Integração com a Fusion Trak:</td>
                                    <td class="CelulaZebra2" width="10%">

                                        <select name="idStUtilizacaoFusionTrakRoteirizador" class="inputtexto"
                                                id="idStUtilizacaoFusionTrakRoteirizador" onchange="habilitarFusionTrak();">
                                            <option value="N" <%=(carregaFi && fi.getStUtilizacaoFusionTrakRoteirizador() == 'N' ? "selected" : "")%>>
                                                Não Utiliza
                                            </option>
                                            <option value="H" <%=(carregaFi && fi.getStUtilizacaoFusionTrakRoteirizador() == 'H' ? "selected" : "")%>>
                                                Homologação
                                            </option>Status Integração com a Buonny:
                                            <option value="P" <%=(carregaFi && fi.getStUtilizacaoFusionTrakRoteirizador() == 'P' ? "selected" : "")%>>
                                                Produção
                                            </option>
                                        </select>
                                    </td>
                                    <td class="TextoCampos" colspan="3"></td>
                                </tr>
                                <tr id="trLoginRoteirizador" style="display: none">
                                    <td class="TextoCampos" width="10%">Login:</td>
                                    <td class="CelulaZebra2" width="10%">
                                        <label>
                                            <div>
                                                <input type="text" class="inputTexto" id="loginRoteirizador"
                                                       name="loginRoteirizador"
                                                       value="<%= carregaFi && fi.getLoginRoteirizador() != null ? fi.getLoginRoteirizador() : ""%>">
                                            </div>
                                        </label>
                                    </td>
                                    <td class="TextoCampos" width="5%">Senha:</td>
                                    <td class="TextoCampos" width="5%">
                                        <label>
                                            <div align="left">
                                                <input type="password" class="inputTexto" id="senhaRoteirizador"
                                                       name="senhaRoteirizador" size="10"
                                                       value="<%= carregaFi && fi.getSenhaRoteirizador() != null ? fi.getSenhaRoteirizador() : ""%>">
                                            </div>
                                        </label>
                                    </td>
                                    <td class="TextoCampos"></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                    <input type="hidden" id="maxEnderecos" name="maxEnderecos" onload="applyFormatter();"/>
                        <td colspan="4" align="center" class="tabela">
                            Informações Gw Mobile
                        </td>
                    </tr>
                    <tr>
                        
                        <td class="CelulaZebra2" colspan="4" >
                            <div align="center">
                                <select class="inputtexto" value="<%=(carregaFi ? fi.getTipoUtilizacaoGWMobile(): "")%>" id="tipoUtilizacaoGWMobile" name="tipoUtilizacaoGWMobile">
                                  <option value="N">Não utiliza</option>  
                                  <option value="H">Homologação</option>  
                                  <option value="P">Produção</option>  
                                </select>    
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos" colspan="1">
                            CNPJ Contratante:
                        </td>
                        <td class="CelulaZebra2" colspan="1">
                            <input name="cnpjContratanteGwMobile" type="text" id="cnpjContratanteGwMobile" value="<%=(carregaFi ? fi.getCnpjContratanteGwMobile() : "")%>" class="inputTexto" size="25" maxlength="18">
                        </td>
                        <td class="TextoCampos" >
                            Token:
                        </td>
                         <td class="CelulaZebra2" >
                            <input name="tokenGwMobile" type="text" id="tokenGwMobile" value="<%=(carregaFi && fi.getTokenGwMobile()!=null? fi.getTokenGwMobile(): "")%>" class="inputTexto" size="40" maxlength="50">
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4" align="center" class="tabela">
                            Informações GW-i
                        </td>
                    </tr>
                    <tr>
                        <td colspan="1" class="TextoCampos">
                            Token:
                        </td>
                         <td colspan="3" class="CelulaZebra2">
                            <input name="tokenGwi" type="text" id="tokenGwi" value="<%=(carregaFi && fi.getTokenGWi()!=null? fi.getTokenGWi(): "")%>" class="inputReadOnly" size="40" maxlength="50" readonly>
                        </td>
                    </tr>   
                    <tr>
                        <td colspan="4" align="center" class="tabela">
                            Integração Contábil
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" class="TextoCampos">
                            Conta Contábil Transitória para pagamentos/recebimentos de outra filial:
                        </td>
                        <td colspan="2" class="CelulaZebra2">
                            <input type="hidden" id="plano_contas_id" name="plano_contas_id" value="<%=(carregaFi ? fi.getPlanoCustoTransitoria().getId() : 0)%>">

                            <input name="cod_conta" type="text" id="cod_conta" size="10" class="inputTexto"
                                   onkeypress="if (event.keyCode===13) localizarContaContabil(this.value);"
                                   value="<%= carregaFi && fi.getPlanoCustoTransitoria().getId() != 0 ? fi.getPlanoCustoTransitoria().getConta() : "" %>">
                            <input type="text" class="inputReadOnly" id="plano_conta_descricao" name="plano_conta_descricao" size="25"
                                   value="<%= carregaFi && fi.getPlanoCustoTransitoria().getId() != 0 ? fi.getPlanoCustoTransitoria().getDescricao() : "" %>">
                            <input name="localiza_conta" type="button" class="botoes" id="localiza_conta" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=38', 'Plano_de_contas')">
                            <img alt="" src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limparContaContabil();">
                        </td>
                    </tr>
            </table>
        </div> 
                        <div id="tab4">
                          <table width="75%" align="center" class="bordaFina">
                            <tr class="tabela">
                                <td colspan="4" align="center"> Moeda </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">
                                    Cotação do Dolar:
                                </td>
                                <td class="celulaZebra2">
                                    <input type="text" name="cotacaoDolar" id="cotacaoDolar" value="<%= (carregaFi ? Apoio.to_curr(fi.getValorCotacaoDolar()) : "0,00") %>" 
                                           class="inputTexto" onChange="seNaoFloatReset(this,'0.00')" size="15" maxlength="10">
                                </td>
                                <td class="TextoCampos">
                                    Cotação em:
                                </td>
                                <td class="celulaZebra2">
                                    <input type="text" name="cotacaoDolarEm" id="cotacaoDolarEm" value="<%= (carregaFi ? Apoio.getFormatData(fi.getCotacaoDolarEm()) : "") %>" 
                                           onkeypress="fmtDate(this,event)" onblur="alertInvalidDate(this,true)" class="fieldDate" size="10" maxlength="10">
                                </td>
                            </tr>
                            <tr class="tabela"> 
                                <td colspan="4" align="center">&Iacute;ndices de An&aacute;lise de Lucratividade</td>
                            </tr>
                              <tr>
            <td colspan="4" width="100%" >
                <table width="100%" class="bordaFina">
                    <tr>
                        <td class="TextoCampos">Comercial:</td>
                        <td class="celulaZebra2">
                            <input name="rateioComercial" type="text" id="rateioComercial" class="fieldMin" onChange="seNaoFloatReset(this,'0.00')"
                                   size="15" value="<%=(carregaFi ? Apoio.to_curr(fi.getRateioComercial()) : "0.00")%>">
                                    
                        </td>                                   
                            
                        
                        
                        <td class="TextoCampos">Administrativo:</td>
                        <td class="celulaZebra2">
                            <input name="rateioAdministrativo" type="text" id="rateioAdministrativo" class="fieldMin" onChange="seNaoFloatReset(this,'0.00')"
                                   size="15" value="<%=(carregaFi ? Apoio.to_curr(fi.getRateioAdministrativo()) : "0.00")%>">
                                   
                        </td>
                        
                        <td class="TextoCampos">R$/Kg ideal para CT-e(s) emitidos por essa filial:</td>
                        <td class="celulaZebra2">
                            <input name="valorKiloIdeal" type="text" id="valorKiloIdeal" class="fieldMin" onChange="seNaoFloatReset(this,'0.00')"
                                   size="15" value="<%=(carregaFi ? Apoio.to_curr(fi.getValorKiloIdeal()) : "0.00")%>">
                                   
                        </td>
                            </tr>
                    <tr>
                        <td colspan="6" class="celulaZebra2">
                            <div style="padding-left: 10px;">
                                <input type="checkbox" name="isAbaterBaseCalculoImpostosPedagio" id="isAbaterBaseCalculoImpostosPedagio" <%=(carregaFi ? (fi.isAbaterBaseCalculoImpostosPedagio() ? "checked" : "") : "")%> >
                                <label for="isAbaterBaseCalculoImpostosPedagio">Abater da base de cálculo dos impostos federais o valor do pedágio informado no CT-e</label>
                            </div>
                        </td>
                    </tr>
                          </table>
                </td>
                              </tr>
                
                
                    <tr class="tabela">
                        <td align="center" colspan="4">Índice para análises de lucratividades por veículos</td>                
                    </tr>
                    <tr>
                    <td width="100%" colspan="4">
                        <table width="100%" class="bordaFina">
                            <tr>
                                <td width="50%" class="TextoCampos">Definição do salário do motorista no custo do veículo:</td>
                                <td width="50%" class="celulaZebra2" colspan="3">
                                    <select id="idDefinicaoSalarioMotoristaVeiculo" name="idDefinicaoSalarioMotoristaVeiculo" class="inputtexto" onchange="habilitarDesabilitaRateio();">
                                        <option id="idDesabilitaRateio" value="m" <%=(carregaFi && fi.getSalarioValorRateio() == 'm' ? "selected" : "")%> >Salário definido no cadastro do motorista</option>                                        
                                        <option id="idHabilitaRateio" value="r" <%=(carregaFi && fi.getSalarioValorRateio()== 'r' ? "selected" : "")%> >Valor para rateio entre todos os veiculos</option>                                        
                                   
                                   
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td width="100%" colspan="4">
                                    <table  width="100%" class="bordaFina" id="idDesabilitaRateioInputs" style="display: none;" >
                                        <tbody name="idAddRateio" id="idAddRateio">
                                            <tr class="celula" >                               
                                                <td width="2%">                                   
                                                    <img style="vertical-align:middle;" id="idRatear" name="idRatear" border="0" class="imagemLink" onclick="addRateioCustoAdministrativo()" src="img/add.gif" title="Adcionar Rateio"/>
                                                </td>

                                                <td width="45%">Valor de custo</td>

                                                <td width="45%">Apartir de</td>                            
                                            </tr>
                                        </tbody>                            
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td width="50%" class="TextoCampos">
                                    <label>Nos relatórios de análise de veículo, carregar o km rodado: </label>
                                </td>
                                <td width="50%" class="celulaZebra2" colspan="3">
                                    <select id="veiculoKm" class="inputtexto" name="veiculoKm">
                                        <option value="v" <%=(carregaFi && fi.getTipoVeiculoKm() == 'v' ? "selected" : "")%> >Da Viagem</option>
                                        <option value="a" <%=(carregaFi && fi.getTipoVeiculoKm() == 'a' ? "selected" : "")%> >Do abastecimento</option>
                                    </select>
                                </td>
                            </tr>
                        </table>
                    </tr>
                                <tr class="celula">
                                                                     
                                        <input type="hidden" id="maxValorDivido" name="maxValorDivido" onload="applyFormatter();"/>
                                  
                                </tr>
                                <tr class="tabela" id="tituloImpostosFederais">
                                    <td align="center" colspan="4">Impostos Federais</td>
                                </tr>
                                <tr id="domImpostosFederais">
                                    <td colspan="4">
                                        <input type="hidden" name="maxAliquotaImpostoFederal" id="maxAliquotaImpostoFederal" value="0">
                                        <table class="bordaFina" style="width: 100%;" id="tableAliquotasImpostosFederais">
                                            <tbody>
                                                <tr  class="celula">
                                                    <td><img style="vertical-align:middle;" id="aliquotasImpostosFederais" name="aliquotasImpostosFederais" border="0" class="imagemLink" onclick="addAliquotasImpostosFederais()" src="img/add.gif" title="Adcionar aliquotas dos impostos federais"/></td>
                                                    <td>Mes/Ano</td>
                                                    <td>IR</td>
                                                    <td>CSSL</td>
                                                    <td>PIS</td>
                                                    <td>COFINS</td>
                                                    <td>INSS</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                        </table>                                         
                    </div>
                  
        <div id="tab5" style="">
            <table width="75%" align="center" class="bordaFina"> 
        <tr class="tabela">
            <td colspan="4" align="center">Acessos da Filial</td>
        </tr>
        <td height="23" colspan="4"> 
            <table width="100%" border="1" align="center" cellpadding="2" cellspacing="1">
                <!-- INICIO -->
                <%
                    //contador de permissoes
                    int i = 0;
                    String categ = "";
                    boolean fimRs = false;
                    if ((acao.equals("iniciar") || acao.equals("editar")) && (perm.Consultar(BeanPermissao.TODAS_AS_PERMISSOES, 0))) {     //declarando essa variavel  por conveniencia de codigo
                        ResultSet rs = perm.getResultSet();
                        //agora ele vai listar as permissoes e testar se o usuario tem aquela permissao
                        fimRs = !rs.next();
                        while (!fimRs) {
                            i++;
                            if (!categ.equals(rs.getString("categoria"))) {
                                categ = rs.getString("categoria");
                                if (categ.equals("0ca")) {%>
                <tr class="celula"><td colspan="2"><b>Cadastros</b></td></tr>
                <%} else if (categ.equals("1la")) {%>
                <tr class="celula"><td colspan="2"><b>Lançamentos</b></td></tr>
                <%} else if (categ.equals("2pr")) {%>
                <tr class="celula"><td colspan="2"><b>Processos</b></td></tr>
                <%} else if (categ.equals("2pa")) {%>
                <tr class="celula"><td colspan="2"><b>Painéis</b></td></tr>
                <%} else if (categ.equals("3re")) {%>
                <tr class="celula"><td colspan="2"><b>Relatórios</b></td></tr>
                <%} else if (categ.equals("4co")) {%>
                <tr class="celula"><td colspan="2"><b>Configurações</b></td></tr>
                <%} else if (categ.equals("5ou")) {%>
                <tr class="celula"><td colspan="2"><b>Outras permissões</b></td></tr>
                <%}
                        }%>
                <tr>
                    <td width="48%" height="20" class="CelulaZebra2">
                        <label>
                            <input type="checkbox" id="ck<%=i%>" name="ck<%=i%>" value="<%=rs.getString("idpermissao")%>"
                                   <%=(carregaFi && Apoio.pesquisaArray(fi.getIdPermissoes(), rs.getString("idpermissao")) >= 0 ? "checked" : "")%>>
                            <%=rs.getString("descricao")%>
                        </label>					
                    </td>
                    <% //chamando outro next() para a segunda coluna de permissoes
                        if (rs.next()) {
                            if (!categ.equals(rs.getString("categoria"))) {%>
                    <td width="50%" class="CelulaZebra2">&nbsp;</td>
                    <%} else {
                            i++;%>
                    <td width="50%" class="CelulaZebra2">
                        <label>
                            <input type="checkbox" id="ck<%=i%>" name="ck<%=i%>" value="<%=rs.getInt("idpermissao")%>"
                                   <%=(carregaFi && Apoio.pesquisaArray(fi.getIdPermissoes(), rs.getString("idpermissao")) >= 0 ? "checked" : "")%>>
                            <%=rs.getString("descricao")%> 
                        </label>    	      				
                    </td>
                    <%fimRs = !rs.next();
                            }
                        } else {//if-else
                            fimRs = true;%>
                    <td width="50%" class="CelulaZebra2">&nbsp;</td>
                    <%}%> 
                </tr>
                <%}//while
                            rs.close();
                        }//if%>
                <!-- FIM -->
            </table>
        </td>
</table>
        </div>
            <div id="tab6" <%=nivelUser != 4 ? "style='display: none'" : ""%> >
            <table width="75%" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tbody id="tbAuditoriaCabecalho">
                    <tr>
                        <td colspan="6"  class="tabela"><div align="center">Auditoria</div></td>
                    </tr>
                    <tr class="celulaNoAlign">
                        <td colspan="3"  align="left">
                            <label>Data da Ação:</label>&ApplyFunction;
                            <input type="text" class="fieldDate" id="dataDeAuditoria" maxlength="10" size="10" value="<%=Apoio.getDataAtual()%>" />
                            <label> Até </label>
                            <input type="text" class="fieldDate" id="dataAteAuditoria" maxlength="10" size="10" value="<%=Apoio.getDataAtual()%>" />
                        </td>
                        <td colspan="1"  >
                            <input type="button" class="botoes" id="btPesquisarAuditoria" value=" Pesquisar " onclick="javascript:tryRequestToServer(function () {
                                pesquisarAuditoria();
                            });" >
                        </td>
                        <td colspan="2"  ></td>
                    </tr>
                    <tr class="celula">
                        <td width="3%"></td>
                        <td width="25%">Usuário</td>
                        <td width="20%">Data</td>
                        <td width="20%">Ação</td>
                        <td width="22%">IP</td>
                        <td width="10%"></td>
                    </tr>
                </tbody>
                <tbody id="tbAuditoriaConteudo" class="limite" style="height: 40px">
                </tbody>
            </table>
        </div> 
            
            </br>
                <table width="75%" align="center" class="bordaFina"> 
        <tr class="tabela">      
        <% if (nivelUser >= 2) {%>
        <tr class="CelulaZebra2">
            <td colspan="6"> 
        <center>
            <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>',<%=i%>);});desabilitarInclusaoManifesto();">
        </center>
    </td>
</tr>
<%}%>
</tr>
</table>
<br/>
 </form>
</body>
</html>
<style>body{height: 100%}.bloqueio-tela{display: none;position: absolute;width: 100%;height: 100%;background: #000;opacity: 0.5;z-index: 999999998;top: 0;left:0}</style>
<div class="bloqueio-tela"></div>