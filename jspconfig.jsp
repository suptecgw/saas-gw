<%@page import="br.com.gwsistemas.configuracao.email.EmailImportacaoXml"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="filial.BeanFilial"%>
<%@page import="filial.BeanConsultaFilial"%>
<%@page import="nucleo.Consulta"%>
<%@page import="java.util.ArrayList"%>
<%@page import="br.com.gwsistemas.configuracao.email.Email"%>
<%@page import="br.com.gwsistemas.configuracao.email.EmailBO"%>
<%@page import="nucleo.SituacaoTributavel"%>
<%@page import="nucleo.ContribuicaoSocial"%>
<%@page import="nucleo.SituacaoTributavelPisCofins"%>
<%@page import="java.util.Collection"%>
<%@ taglib uri="/WEB-INF/tld/custonTagLibrary.tld" prefix="cg" %>
<%@ page contentType="text/html" language="java"
         import="nucleo.BeanConfiguracao,
         java.text.*,
         java.util.Date,
         nucleo.Apoio,fpag.*,
         java.net.URLEncoder" errorPage="" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>

<%
    //response.setContentType("text/html;charset=UTF-8");
    //Permissao do usuário nessa página
    int nivelUser = Apoio.getUsuario(request).getAcesso("altconfig");
    int permissaoModeloNegocio = Apoio.getUsuario(request).getAcesso("altmodelonegocio");
    boolean temacesso = (Apoio.getUsuario(request) != null && Apoio.getUsuario(request).getAcesso("altconfig") > 0);
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    //fim da MSA

    //instanciando um formatador de simbolos
    DecimalFormatSymbols dfs = new DecimalFormatSymbols();
    dfs.setDecimalSeparator('.');
    DecimalFormat vlrformat = new DecimalFormat("0.00", dfs);
    vlrformat.setDecimalSeparatorAlwaysShown(true);
    Collection<SituacaoTributavel> sitTribPisCofins = SituacaoTributavelPisCofins.mostrarTodos(Apoio.getUsuario(request).getConexao());
    Collection<ContribuicaoSocial> contribuicoesSociais = ContribuicaoSocial.mostrarTodos(Apoio.getUsuario(request).getConexao());

    SimpleDateFormat formatoHora = new SimpleDateFormat("HH:mm");
    String hora = formatoHora.format(new Date());    

    Consulta filtroImportacao = new Consulta();
    StringBuilder sqlIportacao = new StringBuilder();
    sqlIportacao.append(" and not ce.is_fatura");
    filtroImportacao.setFiltrosAdicionais(sqlIportacao);
    filtroImportacao.setCampoConsulta(" ce.mail_usuario ");
    EmailBO emailbo2 = new EmailBO();
    Collection<Email> emailImportacao = new ArrayList<Email>();
    emailImportacao = emailbo2.listar(filtroImportacao);
    request.setAttribute("emailImportacao", emailImportacao);    

%>
<% String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    boolean carregaconfig = (temacesso && acao.equals("editar"));
    BeanConfiguracao jbean = null;

    if (acao.equals("editar") || acao.equals("salvar") || acao.equals("salvarImg")) {
        jbean = new BeanConfiguracao();
        jbean.setConexao(Apoio.getUsuario(request).getConexao());
        jbean.setExecutor(Apoio.getUsuario(request));
    }
    //carrega as configuracoes
    if (carregaconfig) {
        //carregando todas as configuracoes
        carregaconfig = jbean.CarregaConfig();
        //Carrega os Email importação xml.
        request.setAttribute("emailXmlImportacao", jbean.getEmailImportacaoXml());        
    }
    
    if (acao.equals("excluirEmailImportacaoXml")) {
        jbean = new BeanConfiguracao();
        jbean.setConexao(Apoio.getUsuario(request).getConexao());
        jbean.setExecutor(Apoio.getUsuario(request));
        
        int idEmailImportacaoXml = Apoio.parseInt(request.getParameter("idEmailImportacaoXml"));
        
        jbean.excluirEmailImportacaoXml(idEmailImportacaoXml);
        
    }
    
    //salva as configuracoes
    if (acao.equals("salvar")) {
        jbean.setEstruturaplano(request.getParameter("estplano"));
        jbean.getPlanoCustoComissaoMotorista().setIdconta(Apoio.parseInt(request.getParameter("contaComissaoMotoristaId")));
        jbean.getPlanoDefault().setIdconta(Apoio.parseInt(request.getParameter("idplanocustolancamento")));
        jbean.getCfopDefault().setIdcfop(Apoio.parseInt(request.getParameter("idcfop")));
        jbean.getCfopDefault2().setIdcfop(Apoio.parseInt(request.getParameter("idcfop2_2")));
        jbean.getCfopIndustriaDentro().setIdcfop(Apoio.parseInt(request.getParameter("idcfop_industria_dentro")));
        jbean.getCfopIndustriaFora().setIdcfop(Apoio.parseInt(request.getParameter("idcfop_industria_fora")));
        jbean.getCfopPessoaFisicaDentro().setIdcfop(Apoio.parseInt(request.getParameter("idcfop_pessoa_fisica_dentro")));
        jbean.getCfopPessoaFisicaFora().setIdcfop(Apoio.parseInt(request.getParameter("idcfop_pessoa_fisica_fora")));
        jbean.getCfopOutroEstado().setIdcfop(Apoio.parseInt(request.getParameter("idcfop_outro_estado")));
        jbean.getCfopOutroEstadoFora().setIdcfop(Apoio.parseInt(request.getParameter("idcfop_outro_estado_fora")));
        jbean.getCfopNotaServico().setIdcfop(Apoio.parseInt(request.getParameter("idcfop_nota_servico")));
        jbean.getCfopTransporteDentro().setIdcfop(Apoio.parseInt(request.getParameter("idcfop_transporte_dentro")));
        jbean.getCfopTransporteFora().setIdcfop(Apoio.parseInt(request.getParameter("idcfop_transporte_fora")));
        jbean.getCfopPrestadorServicoDentro().setIdcfop(Apoio.parseInt(request.getParameter("idcfop_prestador_servico_dentro")));
        jbean.getCfopPrestadorServicoFora().setIdcfop(Apoio.parseInt(request.getParameter("idcfop_prestador_servico_fora")));
        jbean.getCfopProdutorRuralDentro().setIdcfop(Apoio.parseInt(request.getParameter("idcfop_produtor_rural_dentro")));
        jbean.getCfopProdutorRuralFora().setIdcfop(Apoio.parseInt(request.getParameter("idcfop_produtor_rural_fora")));
        jbean.getCfopExteriorDentro().setIdcfop(Apoio.parseInt(request.getParameter("idcfop_exterior_dentro")));
        jbean.getCfopExteriorFora().setIdcfop(Apoio.parseInt(request.getParameter("idcfop_exterior_fora")));
        jbean.getCfopSubContratacaoDentro().setIdcfop(Apoio.parseInt(request.getParameter("idcfop_subcontratacao_dentro")));
        jbean.getCfopSubContratacaoFora().setIdcfop(Apoio.parseInt(request.getParameter("idcfop_subcontratacao_fora")));
        jbean.setIrDe1(Apoio.parseFloat(request.getParameter("irde1")));
        jbean.setIrAte1(Apoio.parseFloat(request.getParameter("irate1")));
        jbean.setIrAliq1(Apoio.parseFloat(request.getParameter("iraliq1")));
        jbean.setIrDeduzir1(Apoio.parseFloat(request.getParameter("irdeduzir1")));
        jbean.setIrDe2(Apoio.parseFloat(request.getParameter("irde2")));
        jbean.setIrAte2(Apoio.parseFloat(request.getParameter("irate2")));
        jbean.setIrAliq2(Apoio.parseFloat(request.getParameter("iraliq2")));
        jbean.setIrDeduzir2(Apoio.parseFloat(request.getParameter("irdeduzir2")));
        jbean.setIrDe3(Apoio.parseFloat(request.getParameter("irde3")));
        jbean.setIrAte3(Apoio.parseFloat(request.getParameter("irate3")));
        jbean.setIrAliq3(Apoio.parseFloat(request.getParameter("iraliq3")));
        jbean.setIrDeduzir3(Apoio.parseFloat(request.getParameter("irdeduzir3")));
        jbean.setIrAcima(Apoio.parseFloat(request.getParameter("iracima")));
        jbean.setIrAliqAcima(Apoio.parseFloat(request.getParameter("iraliqacima")));
        jbean.setIrDeduzirAcima(Apoio.parseFloat(request.getParameter("irdeduziracima")));
        jbean.setIrAliqBaseCalculo(Apoio.parseFloat(request.getParameter("iraliqbasecalculo")));
        jbean.setIrVlDependente(Apoio.parseFloat(request.getParameter("irvldependente")));
        jbean.setInssAliqBaseCalculo(Apoio.parseFloat(request.getParameter("inssaliqbasecalculo")));
        jbean.setInssAte(Apoio.parseFloat(request.getParameter("inssate")));
        jbean.setInssAliqAte(Apoio.parseFloat(request.getParameter("inssaliqate")));
        jbean.setInssDe1(Apoio.parseFloat(request.getParameter("inssde1")));
        jbean.setInssAte1(Apoio.parseFloat(request.getParameter("inssate1")));
        jbean.setInssAliq1(Apoio.parseFloat(request.getParameter("inssaliq1")));
        jbean.setInssDe2(Apoio.parseFloat(request.getParameter("inssde2")));
        jbean.setInssAte2(Apoio.parseFloat(request.getParameter("inssate2")));
        jbean.setInssAliq2(Apoio.parseFloat(request.getParameter("inssaliq2")));
        jbean.setInssDe3(Apoio.parseFloat(request.getParameter("inssde3")));
        jbean.setInssAte3(Apoio.parseFloat(request.getParameter("inssate3")));
        jbean.setInssAliq3(Apoio.parseFloat(request.getParameter("inssaliq3")));
        jbean.setTetoInss(Apoio.parseFloat(request.getParameter("tetoinss")));
        jbean.setSestSenatAliq(Apoio.parseFloat(request.getParameter("sestsenataliq")));
        jbean.setVlConMotor(Apoio.parseFloat(request.getParameter("vlconmotor")));
        jbean.setTipoVlConMotor(request.getParameter("tipo_vlconmotor"));
        jbean.setImpostorenda(Apoio.parseFloat(request.getParameter("impostorenda")));
        jbean.setCssl(Apoio.parseFloat(request.getParameter("cssl_config")));
        jbean.setPis(Apoio.parseFloat(request.getParameter("pis_config")));
        jbean.setCofins(Apoio.parseFloat(request.getParameter("cofins_config")));
        jbean.setTetoLiberacao(Apoio.parseFloat(request.getParameter("tetoliberacao")));
        jbean.setGerar_despesa_cartafrete(Apoio.parseBoolean(request.getParameter("gerar_despesa")));
        jbean.getFornecedor_cartafrete().setIdfornecedor(Apoio.parseInt(request.getParameter("idfornecedor")));
        jbean.getPlanocusto_cartafrete().setIdconta(Apoio.parseInt(request.getParameter("plcusto_adiantamento_id")));
        jbean.getPlanoCustoSaldoId().setIdconta(Apoio.parseInt(request.getParameter("idplanocusto_saldo")));
        jbean.setIsContabil(Apoio.parseBoolean(request.getParameter("iscontabil")));
        jbean.setIsFiscal(Apoio.parseBoolean(request.getParameter("isfiscal")));
        jbean.getContaJurosPago().setId(Apoio.parseInt(request.getParameter("jurospagos_id")));
        jbean.getContaJurosPago().setDescricao(request.getParameter("jurospagosDescricao"));
        jbean.getContaJurosRecebidos().setId(Apoio.parseInt(request.getParameter("jurosrecebidos_id")));
        jbean.getContaJurosRecebidos().setDescricao(request.getParameter("jurosrecebidosDescricao"));
        jbean.getContaDescontoConcedidos().setId(Apoio.parseInt(request.getParameter("descontosconcedidos_id")));
        jbean.getContaDescontoConcedidos().setDescricao(request.getParameter("descontosconcedidosDescricao"));
        jbean.getContaDescontoObtido().setId(Apoio.parseInt(request.getParameter("descontosobtidos_id")));
        jbean.getContaDescontoObtido().setDescricao(request.getParameter("descontosobtidosDescricao"));
        jbean.getContaCliente().setId(Apoio.parseInt(request.getParameter("contaClienteId")));
        jbean.getContaCliente().setDescricao(request.getParameter("contaClienteDescricao"));
        jbean.getContaFornecedor().setId(Apoio.parseInt(request.getParameter("contaFornecedorId")));
        jbean.getContaFornecedor().setDescricao(request.getParameter("contaFornecedorDescricao"));
        jbean.getContaProprietario().setId(Apoio.parseInt(request.getParameter("contaProprietarioId")));
        jbean.getContaProprietario().setDescricao(request.getParameter("contaProprietarioDescricao"));
        jbean.setHistoricoProvisao(request.getParameter("historico_provisao"));
        jbean.setHistoricoPagamento(request.getParameter("historico_pagamento"));
        jbean.setHistoricoRecebimento(request.getParameter("historico_recebimento"));
        jbean.getContaIrrfRetido().setId(Apoio.parseInt(request.getParameter("irrf_retido_id")));
        jbean.getContaIrrfRetido().setDescricao(request.getParameter("irrfRetidoDescricao"));
        jbean.getContaInssRetido().setId(Apoio.parseInt(request.getParameter("inss_retido_id")));
        jbean.getContaInssRetido().setDescricao(request.getParameter("inssRetidoDescricao"));
        jbean.getContaIssRetido().setId(Apoio.parseInt(request.getParameter("iss_retido_id")));
        jbean.getContaIssRetido().setDescricao(request.getParameter("issRetidoDescricao"));
        jbean.getFpag().setIdFPag(Apoio.parseInt(request.getParameter("fpag")));
        jbean.setIdentidicadorCartafrete(Apoio.parseInt(request.getParameter("identificador_cartafrete")));
        jbean.setSalvaCartaSemManifesto(Apoio.parseBoolean(request.getParameter("semmanifesto")));
        jbean.getConta_padrao_id().setIdConta(Apoio.parseInt(request.getParameter("conta_padrao_id")));
        jbean.getConta_adiantamento_viagem_id().setIdConta(Apoio.parseInt(request.getParameter("conta_adiantamento_viagem_id")));
        jbean.getContaAdiantamentoFornecedor().setIdConta(Apoio.parseInt(request.getParameter("contaAdiantamentoFornecedor")));
        jbean.setValidarContainer(Apoio.parseBoolean(request.getParameter("validarContainer")));
        jbean.setValidarGenset(Apoio.parseBoolean(request.getParameter("validarGenset")));
        jbean.setIscartaFreteAutomatica(Apoio.parseBoolean(request.getParameter("cartaFreteAutomatica")));
        jbean.setCartaFreteAutomaticaColeta(Apoio.parseBoolean(request.getParameter("cartaFreteAutomaticaColeta")));
        jbean.setIsGeraGEMColeta(Apoio.parseBoolean(request.getParameter("gerarGem")));
        jbean.setIsGeraGSMManifesto(Apoio.parseBoolean(request.getParameter("gerarGsm")));
        jbean.setIsUnidadeCustoObrigatoria(Apoio.parseBoolean(request.getParameter("chk_und_custo")));
        jbean.setPlanoCustoObrigatorio(Apoio.parseBoolean(request.getParameter("chk_plano_custo_obrigatorio")));
        jbean.setBaixaAdiantamentoCartaFrete(Apoio.parseBoolean(request.getParameter("baixaAdiantamentoCarta")));
        jbean.setBaixarDespesaAposConfirmacaoCIOT(Apoio.parseBoolean(request.getParameter("baixarDespesaAposConfirmacaoCIOT")));
        jbean.getServicoMontagemCarga().setId(Apoio.parseInt(request.getParameter("type_service_id")));
        jbean.setIsProvisaoDespesa(Apoio.parseBoolean(request.getParameter("provisaoDespesa")));
        jbean.setMensagemCartaFrete(request.getParameter("mensagemCartaFrete"));
        jbean.setMensagemCobranca(request.getParameter("mensagemCobranca"));
        jbean.setSeriePadraoCtrc(request.getParameter("serieCtrcPadrao"));
        jbean.setSeriePadraoNotaServico(request.getParameter("serieNotaServicoPadrao"));
        jbean.setManifestarCtrcVariasVezes(Apoio.parseBoolean(request.getParameter("manifestarCtrcVariasVezes")));
        jbean.setImpedeViagemMotorista(Apoio.parseBoolean(request.getParameter("impedeViagemMotorista")));
        jbean.setObrigarOcorrenciaBaixCtrc(Apoio.parseBoolean(request.getParameter("obrigarOcorrenciaBaixCtrc")));
        jbean.setObrigaNotaFiscalCtrc(Apoio.parseBoolean(request.getParameter("obrigaNotaFiscalCtrc")));
        jbean.setObrigaColetaCTRC(Apoio.parseBoolean(request.getParameter("obrigaColetaCtrc")));
        jbean.setObrigaRotaCTRC(Apoio.parseBoolean(request.getParameter("obrigaRotaCtrc")));
        jbean.setObrigaVeiculoCTRC(Apoio.parseBoolean(request.getParameter("obrigaVeiculoCtrc")));
        jbean.setObrigaMotoristaCTRC(Apoio.parseBoolean(request.getParameter("obrigaMotoristaCtrc")));
        jbean.setObrigaAgenteCargaCTRC(Apoio.parseBoolean(request.getParameter("obrigaAgenteCargaCtrc")));
        //jbean.setLancaColetaNaCartaFrete(Boolean.parseBoolean(request.getParameter("coletaCartaFrete")));
        jbean.setSubCodigoManifesto(Apoio.parseBoolean(request.getParameter("subCodigoManifesto")));        //campos novos desde 02/09
        jbean.setMensagemCtrc(request.getParameter("mensagemCtrc"));
        jbean.setMensagemManifesto(request.getParameter("mensagemManifesto"));
        jbean.setMensagemEntrega(request.getParameter("mensagemEntrega"));
        jbean.setPermiteEntregaCtrcNaoResolvido(Apoio.parseBoolean(request.getParameter("permiteEntregaCtrcNaoResolvido")));
        jbean.setPermiteSalvarCTEValorMenorImpostos(Apoio.parseBoolean(request.getParameter("permiteSalvarCte")));
        jbean.getContaPisRetido().setId(Apoio.parseInt(request.getParameter("pis_retido_id")));
        jbean.getContaCofinsRetido().setId(Apoio.parseInt(request.getParameter("cofins_retido_id")));
        jbean.getContaCsslRetido().setId(Apoio.parseInt(request.getParameter("cssl_retido_id")));
        //novo campo desde 09/03 - jonas
        jbean.setFechamentoDiaConcBanc(Apoio.parseBoolean(request.getParameter("fechamentoDiaConcBanc")));
        jbean.setControlarTalonario(Apoio.parseBoolean(request.getParameter("controlarTalonario")));
        jbean.setMostraEnderecoClienteCtrc(Apoio.parseBoolean(request.getParameter("mostraEnderecoClienteCtrc")));
        jbean.setBaixaEntregaNota(Apoio.parseBoolean(request.getParameter("baixaEntregaNota")));
        jbean.getUnidadeCustoAdiantamento().setId(Apoio.parseInt(request.getParameter("und_custo_adiantamento_id")));
        jbean.getUnidadeCustoSaldo().setId(Apoio.parseInt(request.getParameter("und_custo_saldo_id")));

        jbean.setGerarCartaFreteColeta(Apoio.parseBoolean(request.getParameter("gerarCartaFreteColeta")));
        jbean.setGerarCartaFreteManifesto(Apoio.parseBoolean(request.getParameter("gerarCartaFreteManifesto")));
        jbean.setGerarCartaFreteRomaneio(Apoio.parseBoolean(request.getParameter("gerarCartaFreteRomaneio")));
        jbean.setClienteFantasiaObrigatorio(request.getParameter("clienteFantasiaObrigatorio") != null);
        jbean.setClienteCepObrigatorio(request.getParameter("clienteCepObrigatorio") != null);
        jbean.setClienteEnderecoObrigatorio(request.getParameter("clienteEnderecoObrigatorio") != null);
        jbean.setClienteFoneObrigatorio(request.getParameter("clienteFoneObrigatorio") != null);
        jbean.setClienteCepCobrancaObrigatorio(request.getParameter("clienteCepCobrancaObrigatorio") != null);
        jbean.setClienteEnderecoCobrancaObrigatorio(request.getParameter("clienteEnderecoCobrancaObrigatorio") != null);
        jbean.setClienteVendedorObrigatorio(request.getParameter("clienteVendedorObrigatorio") != null);
        jbean.setClienteVendedor2Obrigatorio(request.getParameter("clienteVendedor2Obrigatorio") != null);
        jbean.setClienteValidaCnpj(request.getParameter("clienteValidaCnpj") != null);
        jbean.setClienteDuplicaCnpj(request.getParameter("clienteDuplicaCnpj") != null);
        jbean.setClienteValidaIe(request.getParameter("clienteValidaIe") != null);
        jbean.setTipoSequenciaManifesto(request.getParameter("tipo_sequencia_manifesto"));
        jbean.setCliente_plano_de_contas(request.getParameter("clientePlanoDeContas") != null);
        jbean.setMotoristaEnderecoObrigatorio(Apoio.parseBoolean(request.getParameter("motoristaEnderecoObrigatorio")));
        jbean.setMotoristaRGOrgaoObrigatorio(Apoio.parseBoolean(request.getParameter("motoristaRGOrgaoObrigatorio")));
        jbean.setMotoristaDataEmissaoRGObrigatorio(Apoio.parseBoolean(request.getParameter("motoristaDataEmissaoRGObrigatorio")));
        jbean.setMotoristaCNHObrigatorio(Apoio.parseBoolean(request.getParameter("motoristaCNHObrigatorio")));
        jbean.setMotoristaDataEmissaoCNHObrigatorio(Apoio.parseBoolean(request.getParameter("motoristaDataEmissaoCNHObrigatorio")));
        jbean.setMotoristaDataVencimentoCNHObrigatorio(Apoio.parseBoolean(request.getParameter("motoristaDataVencimentoCNHObrigatorio")));
        jbean.setMotoristaVeiculoObrigatorio(Apoio.parseBoolean(request.getParameter("motoristaVeiculoObrigatorio")));
        jbean.setProprietarioDataNascimentoObrigatorio(Apoio.parseBoolean(request.getParameter("proprietarioDataNascimentoObrigatorio")));
        jbean.setProprietarioEnderecoObrigatorio(Apoio.parseBoolean(request.getParameter("proprietarioEnderecoObrigatorio")));
        jbean.setProprietarioRgOrgaoObrigatorio(Apoio.parseBoolean(request.getParameter("proprietarioRgOrgaoObrigatorio")));
        jbean.setProprietarioTelefoneObrigatorio(Apoio.parseBoolean(request.getParameter("proprietarioTelefoneObrigatorio")));
        jbean.setProprietarioPisPasepObrigatorio(Apoio.parseBoolean(request.getParameter("proprietarioPisPasepObrigatorio")));
        jbean.setNome_fantasia_fornecedor_obrigatorio(Apoio.parseBoolean(request.getParameter("fornecedorNomeFantasia")));
        jbean.setCep_fornecedor_obrigatorio(Apoio.parseBoolean(request.getParameter("fornecedorCEP")));
        jbean.setIe_fornecedor_obrigatorio(Apoio.parseBoolean(request.getParameter("fornecedorIE")));
        jbean.setEndereco_fornecedor_obrigatorio(Apoio.parseBoolean(request.getParameter("fornecedorEndereco")));
        jbean.setConta_contabil_fornecedor_obrigatorio(Apoio.parseBoolean(request.getParameter("fornecedorContaContabil")));
        jbean.setRomanearCtrcSemChegada(Apoio.parseBoolean(request.getParameter("romanearCTRC")));
        jbean.setValidadeProposta(Apoio.parseInt(request.getParameter("validadeProposta")));
        jbean.setMotoristaPisPasepObrigatorio(Apoio.parseBoolean(request.getParameter("motoristaPisPasepObrigatorio")));
        jbean.setMotoristaTelefoneObrigatorio(Apoio.parseBoolean(request.getParameter("motoristaTelefoneObrigatorio")));
        jbean.setMotoristaTelefoneObrigatorio2(Apoio.parseBoolean(request.getParameter("motoristaTelefoneObrigatorio2")));
        //campos default para relatorios
        jbean.setRelDefaultFatura(request.getParameter("cbFatura"));
        jbean.setRelDefaultColeta(request.getParameter("cbColeta"));
        jbean.setRelDefaultManifesto(request.getParameter("cbManifesto"));
        jbean.setRelDefaultCartaFrete(request.getParameter("cbCartaFrete"));
        jbean.setRelDefaultMotorista(request.getParameter("cbMotorista"));
        jbean.setRelDefaultBoleto(request.getParameter("cbBoleto"));
        jbean.setRelDefaultOrdemServico(request.getParameter("modeloOS"));
        jbean.getSituacaoTribPisCofins().setId(Apoio.parseInt(request.getParameter("situacaoTribPisCofins")));
        jbean.getContribuicaoSocial().setId(Apoio.parseInt(request.getParameter("contribuicaoSocial")));
        jbean.setCriterioEscrituracao(request.getParameter("criterioEscrituracao"));
        jbean.setImportarCtrcNotaMercadoria(Apoio.parseBoolean(request.getParameter("importarCtrcNotaMercadoria")));
        jbean.setImportarCtrcNotaItem(Apoio.parseBoolean(request.getParameter("importarCtrcNotaItem")));
        jbean.setPermiteContratoMaiorCtrc(Apoio.parseBoolean(request.getParameter("permiteContratoMaior")));
        jbean.setPercentualAdiantamentoContratoFrete(Apoio.parseDouble(request.getParameter("percentualAdiantamento")));
        jbean.setSSL(Apoio.parseBoolean(request.getParameter("isSSL")));
        jbean.setStartTLS(Apoio.parseBoolean(request.getParameter("isStartTLS")));
        jbean.setSSLFatura(Apoio.parseBoolean(request.getParameter("isSSLFatura")));
        jbean.setStartTLSFatura(Apoio.parseBoolean(request.getParameter("isStartTLSFatura")));
        jbean.getOcorrenciaRomaneio().setId(Apoio.parseInt(request.getParameter("idOcorrenciaRomaneioCTe")));
        jbean.setGeraIntegracaoContaReduzida(request.getParameter("chk_gera_conta_reduzida") != null);
        jbean.setGerarCnpjIntegracaoContabil(request.getParameter("chk_gera_cnpj") != null);
        jbean.setMensagemBoleto(request.getParameter("mensagemBoleto"));
        jbean.setMensagemCte(request.getParameter("mensagemCte"));
        jbean.setPreferenciaEnvioEmail(request.getParameter("preferenciaEmail"));
        jbean.getEmailEntrega().setId(Apoio.parseInt(request.getParameter("emailEntrega")));
        jbean.getEmailOrcamento().setId(Apoio.parseInt(request.getParameter("emailOrcamento")));
        jbean.getEmailEDI().setId(Apoio.parseInt(request.getParameter("emailEDI")));
        
        jbean.getEmailFatura().setId(Apoio.parseInt(request.getParameter("emailFatura")));
        jbean.setValidaApoliceVeiculo(Apoio.parseBoolean(request.getParameter("validaApoliceVeiculo")));
        //11/07/13
        jbean.setProprietarioValidaPis(Apoio.parseBoolean(request.getParameter("proprietarioValidaPis")));
        //01/08/13
        jbean.setMotoristaLocalEmissaoCNH(Apoio.parseBoolean(request.getParameter("motoristaLocalEmissaoCNH")));
        jbean.setCtrcsConfirmadosParaRomaneio(Apoio.parseBoolean(request.getParameter("ctrcsConfirmadosParaRomaneio")));
        jbean.setCtrcsConfirmadosParaManifesto(Apoio.parseBoolean(request.getParameter("ctrcsConfirmadosParaManifesto")));
        jbean.setAtualizarClienteImportacaoEdi(Apoio.parseBoolean(request.getParameter("atualizarClienteImportacaoEdi")));
        //10-03-2013
        jbean.setMensagemManifestoRepresentante(request.getParameter("mensagemManifestoRepresentante"));
        // novos campos, referente ao lançamento de viagem - 18-03-2014
        jbean.getPlanoCustoDiariaMotorista().setIdconta(Apoio.parseInt(request.getParameter("idContaPadraoMotoristaDiaria")));
        jbean.getPlanoCustoPernoiteMotorista().setIdconta(Apoio.parseInt(request.getParameter("idContaPadraoMotoristaPernoite")));
        jbean.getPlanoCustoAlimentacaoMotorista().setIdconta(Apoio.parseInt(request.getParameter("idContaPadraoMotoristaAlimentacao")));
        jbean.getPlanoCustoDiariaAjudante().setIdconta(Apoio.parseInt(request.getParameter("idContaPadraoAjudanteDiaria")));
        jbean.getPlanoCustoPernoiteAjudante().setIdconta(Apoio.parseInt(request.getParameter("idContaPadraoAjudantePernoite")));
        jbean.getPlanoCustoAlimentacaoAjudante().setIdconta(Apoio.parseInt(request.getParameter("idContaPadraoAjudanteAlimentacao")));
        jbean.setValorPernoiteViagem(Apoio.parseDouble(request.getParameter("valorPernoiteViagem")));
        jbean.setValorAlimentacaoViagem(Apoio.parseDouble(request.getParameter("valorAlimentacaoViagem")));
        jbean.setCartaFreteAutomaticaRomaneio(Apoio.parseBoolean(request.getParameter("cartaFreteAutomaticaRomaneio")));
        jbean.setQtdDiasArmazenarAnexos(Apoio.parseInt(request.getParameter("qtdDiasArmazenarAnexos")));
        jbean.setQtdEmailLote(Apoio.parseInt(request.getParameter("qtdEmailLote")));
//        jbean.setTempoEmailLote(Apoio.paraDate(request.getParameter("qtdTempoEmailLote")));
//        jbean.setHoraFinalEmailLote(Apoio.paraHora(request.getParameter("horaInicialEmailLote")));
        jbean.setTempoEmailLote(Apoio.getFormatTime(request.getParameter("qtdTempoEmailLote")));
        jbean.setHoraInicialEmailLote(Apoio.paraHora(request.getParameter("horaInicialEmailLote")));
        jbean.setHoraFinalEmailLote(Apoio.paraHora(request.getParameter("horaFinalEmailLote")));
        jbean.setIsEnviarEntreHorario(Apoio.parseBoolean(request.getParameter("chkEnviarEmailApenasEntre")));
        jbean.setConsignatarioClienteDireto(Apoio.parseBoolean(request.getParameter("consigClienteDireto")));        
        jbean.setDiariaRetemImposto(Apoio.parseBoolean(request.getParameter("chkIsDiariaRetemImposto")));
        jbean.setDescargaRetemImposto(Apoio.parseBoolean(request.getParameter("chkIsDescargaRetemImposto")));
        jbean.setOutrosRetemImposto(Apoio.parseBoolean(request.getParameter("chkIsOutrosRetemImposto")));        
        jbean.getPlanoCustoPedagio().setIdconta(Apoio.parseInt(request.getParameter("idPlanoCustoPedagio")));
        jbean.setConsideraOutrasRetencoesDespesaAnaliseFrete(Apoio.parseBoolean(request.getParameter("consideraOutrasRetencoesDespesaAnaliseFrete")));
        jbean.setAceitarServicoCtNfs(Apoio.parseBoolean(request.getParameter("aceitarServicoCtNfs")));
        jbean.setPercentualToleranciaPeso(Apoio.parseDouble(request.getParameter("percentualToleranciaPeso")));
        jbean.setMensagemChegada(request.getParameter("mensagemChegada"));
        jbean.setMensagemOcorrencia(request.getParameter("mensagemOcorrencia"));
        jbean.setConsiderarDataBaixa(request.getParameter("considerarDataBaixa"));
        jbean.setValidacaoCteXmlOutrosDestinatarios(request.getParameter("validacaoCteXmlOutrosDestinatarios"));
        jbean.setLayoutImportacaoXmlDanfe(request.getParameter("layoutImportacaoXmlDanfe"));
        jbean.setRelDefaultConhecimento(request.getParameter("cdConhecimento"));
        jbean.getFilialOrcamentoGwCli().setIdfilial(Apoio.parseInt(request.getParameter("filialOrcamentoGwCli")));
        //06/02/2015
        jbean.setRelDefaultConsultaVenda(request.getParameter("cdConsultaVenda"));
        jbean.setRelDefaultConsultaRomaneio(request.getParameter("cdConsultaRomaneio"));
        //16/03/2015
        jbean.setEmbutirIR(Apoio.parseBoolean(request.getParameter("embutir_renda")));
        jbean.setEmbutirCssl(Apoio.parseBoolean(request.getParameter("embutir_cssl")));
        jbean.setEmbutirPis(Apoio.parseBoolean(request.getParameter("embutir_pis")));
        jbean.setEmbutirCofins(Apoio.parseBoolean(request.getParameter("embutir_cofins")));
        jbean.getOcorrenciaRomaneioColeta().setId(Apoio.parseInt(request.getParameter("idOcorrenciaRomaneioColeta")));
        jbean.setPermitirLancamantoOSAbertoVeiculo(request.getParameter("permitirLancamentoOSAbertoVeiculo"));
        jbean.setUtilizarNumeroCteFatura(Apoio.parseBoolean(request.getParameter("utilizarNumeroCteFatura")));        
        jbean.setIsObrigaKmChegadaAdv(Apoio.parseBoolean(request.getParameter("obrigaKmChegadaAdv")));
        jbean.setConsideraDependentesIr(Apoio.parseBoolean(request.getParameter("consideraDependentesIr")));
        jbean.setPercentualExtraCustoSeguro(Apoio.parseDouble(request.getParameter("percentualExtraCustoSeguro")));
        jbean.setIsIncluirRetirarCteManifestoFreteLancado(Apoio.parseBoolean(request.getParameter("incluirRetirarCteManifestoContratoFreteLancado")));
        //04/06/2015
        jbean.setMensagemNfse(request.getParameter("mensagemNfse"));
        
        jbean.setMensagemOrcamento(request.getParameter("mensagemOrcamento"));
        jbean.setMensagemColetaRepresentante(request.getParameter("mensagemColetaRepresentante"));
        
        jbean.setNomeImagemLogo(request.getParameter("nomeImagem"));       
        jbean.setQuantidadeDiasAvisoBackup(Apoio.parseInt(request.getParameter("quantidadeDiasAvisoBackup")));
        jbean.setQuantidadeDiasEmailBackup(Apoio.parseInt(request.getParameter("quantidadeDiasEmailBackup")));
        jbean.setRntrc(Apoio.parseBoolean(request.getParameter("chkRntrc")));
        jbean.setBaixarAdvSaldoZerado(Apoio.parseBoolean(request.getParameter("baixarAdvSaldoZerado")));
        jbean.setRomaneioAutorizacaoPagamento(Apoio.parseBoolean(request.getParameter("romaneioAutorizacaoPagamento")));
        jbean.setRomaneioAutorizacaoPadrao(Apoio.parseBoolean(request.getParameter("romaneioAutorizacaoPadrao")));
        jbean.setSerieExclusaoAverbacao(request.getParameter("serieExclusaoAverbacao"));
        jbean.setTipoOrdenacaoCteManifesto(request.getParameter("ordenacaoCteManifesto"));
        jbean.setClienteInscricaoIsentoImportacao(Apoio.parseBoolean(request.getParameter("isClienteInscricaoIsentoImportacao")));
     
//        jbean.getEmailImportacaoArquivoXmlId().setId(Apoio.parseInt(request.getParameter("emailImportacao")));

        EmailImportacaoXml emailImportacaoXml = null;
        int qtdEmailImportacao = Apoio.parseInt(request.getParameter("maxEmailImportacaoXml"));
        for(int qtdEmail = 1; qtdEmail <= qtdEmailImportacao; qtdEmail++){
            
            if (request.getParameter("inpIdEmailImportacaoXml_"+qtdEmail) != null) {
                
                emailImportacaoXml = new EmailImportacaoXml();
                emailImportacaoXml.setId(Apoio.parseInt(request.getParameter("inpIdEmailImportacaoXml_"+qtdEmail)));
                emailImportacaoXml.getEmail().setId(Apoio.parseInt(request.getParameter("slcEmail_"+qtdEmail)));
                emailImportacaoXml.setIdConfiguracao(Apoio.parseInt(request.getParameter("inpIdConfig_"+qtdEmail)));
                jbean.getEmailImportacaoXml().add(emailImportacaoXml);
                    
            }
        }
        
        jbean.setEmbutirInss(Apoio.parseBoolean(request.getParameter("embutirInss")));
        jbean.setInss(Apoio.parseFloat(request.getParameter("inss_config")));
        jbean.setEmailDeContato(Apoio.parseBoolean(request.getParameter("isEmailDeContato")));
        jbean.setModeloPadraoVeiculo("'"+request.getParameter("campo_consulta")+"'");
        jbean.setIsAtivarRecebimento(Apoio.parseBoolean(request.getParameter("isAtivarRecebimento")));
        jbean.setMinutosBaixarEmails(Apoio.parseInt(request.getParameter("minutosBaixarEmails")));
        jbean.setIsBaixarApenasEntre(Apoio.parseBoolean(request.getParameter("isBaixarApenasEntre")));
        jbean.setHoraBaixaEmailInicio(Apoio.getFormatSqlTime(request.getParameter("horaBaixarEmailInicio")));
        jbean.setHoraBaixaEmailFim(Apoio.getFormatSqlTime(request.getParameter("horaBaixarEmailFim")));
        jbean.setEnviarEmailAutomaticoFatura(Apoio.parseBoolean(request.getParameter("enviarEmailAutomaticoFatura")));
        jbean.setIncluirFaturasCTeConfirmados(Apoio.parseBoolean(request.getParameter("incluirFaturasCTeConfirmados")));
        jbean.setBaixarFaturaParcialDiferenca(Apoio.parseBoolean(request.getParameter("baixarFaturaParcialDiferenca")));
        
        //27/04/2016
        jbean.setIsRetirarLetrasLogradouro(request.getParameter("validarNumeroLogradouro").equals("remover") ? true : false);
        jbean.setPreencheZeroLogradouro(request.getParameter("validarNumeroLogradouro").equals("zerar") ? true : false);
        
        jbean.setIsManifestoPontoControle(request.getParameter("manifestoPontoControle").equals("ativado"));
        jbean.setIsRomaneioPontoControle(request.getParameter("romaneioPontoControle").equals("ativado"));
        jbean.setIsBaixarComprovanteGwMobile(Apoio.parseBoolean(request.getParameter("baixarComprovanteGwMobile")));
        jbean.setIsIgnorarDadosMobileBaixados(Apoio.parseBoolean(request.getParameter("ignorarDadosBaixadosMobile")));
        
        //21/07/2016
        jbean.setOrigemFrete(request.getParameter("origemFrete"));
        
        //29/07/2016
        jbean.setCodSegurancaCNH(Apoio.parseBoolean(request.getParameter("motoristaCodSegCNHObrigatorio")));
        
        //28/09/2016
        jbean.getContaAdiantamentoCliente().setIdConta(Apoio.parseInt(request.getParameter("contaAdiantamentoCliente")));
        
        jbean.setAcaoCteRomaneioExistente(request.getParameter("transferirCteRomaneioAtual"));
        
        jbean.setTipoArredondamentoPeso(request.getParameter("tipoArredondamentoPeso"));
        
        jbean.setTipoCalculaIss(request.getParameter("tipoCalculoIss"));
        
        jbean.setMatrizFilialFranquia(request.getParameter("tipoFilial"));
        
        //28/12/2017
        jbean.setObservacoesContrato(request.getParameter("observacoesContrato"));
        jbean.setCondicoesPagamento(request.getParameter("condicoesPagamento"));
        jbean.setObservacoesGerais(request.getParameter("observacoesGerais"));

        // 08/07/2018
        jbean.setPercentualPadraoDescontoContaCorrente(Apoio.parseDouble(request.getParameter("percentualPadraoContaCorrente")));
        jbean.setTipoDescontoContaCorrente(Apoio.parseInt(request.getParameter("tipoDescontoContaCorrente")));
        
        // 07/08/2018
        jbean.setDeduzirImpostosOutrasRetencoesCfe(Apoio.parseBoolean(request.getParameter("chkIsDeduzirImpostosOutrasRetencoesCfe")));
        
        // 11/10/2018
        jbean.setDescontoAutomaticoAbastecimento(Apoio.parseBoolean(request.getParameter("descontoAutomaticoAbastecimento")));
        jbean.setConsiderarAbastecimentoApartir(Apoio.getFormatData(request.getParameter("considerarAbastecimentoApartir")));
        
        // 15/10/2018 
        //jbean.setTema(Apoio.parseInt(request.getParameter("valorTema")));
        jbean.setTipoTema(jbean.getTipoTema().descobreTipoTema(Apoio.parseInt(request.getParameter("valorTema"))));
        
        jbean.setAtivarEnvioVencimentoFatura(Apoio.parseBoolean(request.getParameter("chkEnvioEmailAutomaticoVencimentoFatura")));
        jbean.getContaEmailVencimentoFatura().setId(Apoio.parseInt(request.getParameter("selectEmailVencimentoFatura")));
        jbean.setHoraEnvioEmailVencimentoFatura(Apoio.getFormatSqlTime(request.getParameter("inpHoraExecucaoEmailVencimentoFatura")));
        jbean.setMensagemEmailVencimentoFatura(request.getParameter("inpMensagemEmailVencimentoFatura"));

        jbean.setEnviarEmailLembreteVencimentoFatura(Apoio.parseBoolean(request.getParameter("chkEnviarEmailLembreteVencimentoBoleto")));
        jbean.setQtdDiasVencimentoLembreteFatura(Apoio.parseInt(request.getParameter("inpDiasEnviarEmailLembreteVencimentoBoleto")));
        jbean.setLinkWebtransRastreioFatura(request.getParameter("linkWebtransRastreioFatura"));
        jbean.setPagamentoRecebimentoTransitoriaFilial(Apoio.parseBoolean(request.getParameter("chkPagamentoRecebimentoTransitoriaFilial")));
        jbean.setPermitirManifestoVeiculoNaoEncerrado(Apoio.parseBoolean(request.getParameter("is-permitir-manifesto-veiculo-nao-encerrado")));
        jbean.setDeduzirINSSIR(Apoio.parseBoolean(request.getParameter("deduzirINSSIR")));
        
        jbean.getFornecedorPadraoAdvMobile().setIdfornecedor(Apoio.parseInt(request.getParameter("idfornecedor_adv")));
        jbean.getFornecedorPadraoAdvMobile().setRazaosocial(request.getParameter("fornecedor_adv"));

        boolean erro = !jbean.Salvar();
        String msgErro = jbean.getErros();

%><script language="javascript" type=""><%    if (erro) {
        if (!msgErro.equals("")) {%>
    alert("<%=msgErro%>");
    <%} else {%>  
    alert("Erro ao tentar alterar a configuração do sistema!");
    <%}
        }
        Apoio.setConfig(request.getSession().getServletContext(), Apoio.getUsuario(request).getConexao());
    %>
    window.close();
</script>
<%}else if (acao.equals("salvarImg")) {
    try{
        jbean.salvarImagem(request,response);
    }catch(Exception e){
        PrintWriter out2 = null;
        out2 = response.getWriter();
        out2.println("<script> alert('"+e.getMessage()+"');</script>");
        out2.println("<script> window.opener.document.getElementById('carregarImg').value = ''; </script>");
        out2.println("<script> window.opener.document.getElementById('LOGO_IMG').style.display = 'none'; </script>");
        out2.println("<script> window.opener.document.getElementById('nomeImagem').value = ''; </script>");
        out2.println("<script> window.close();</script>");
    }
    }
%>

<script type="text/javascript" src="script/jquery-1.11.2.min.js"></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script language="javascript" type="text/javascript">
jQuery.noConflict();

function carrega() {
    corTema();
    $('identificador_cartafrete').value = '<%=jbean.getIdentidicadorCartafrete()%>';

    if (("<%=jbean.getPreferenciaEnvioEmail()%>") == 'a') {
        $("mesmo_tempo").checked = true;
        $("caixa_saida").checked = false;
    } else {
        $("mesmo_tempo").checked = false;
        $("caixa_saida").checked = true;
        alterarPreferenciaEmail('b');
    }
    
    liberarAutorizacaoPadraoRomaneio();
    alterarBaixarEmailsEntre();
    alterarAtivarRecebimentoEmails();
    
    <c:forEach var="email" varStatus="status" items="${emailImportacao}">
            listaEmailImportacaoXml[++countEmail] = new Option('${email.id}','${email.descricao}');
    </c:forEach>
    
    <c:forEach var="emailXml" varStatus="status" items="${emailXmlImportacao}">    
        var emailImportacao = new EmailImportacaoXml('${emailXml.id}','${emailXml.idConfiguracao}','${emailXml.email.id}');
        addEmailImportacaoXml(listaEmailImportacaoXml, emailImportacao);
    </c:forEach>
        
    if (${param.aba != "" && param.aba == "preferencias"}) {
        $("abaPreferencia").click();
    }
    $("dataDeAuditoria").value = '<%= Apoio.getDataAtual() %>';
    $("dataAteAuditoria").value = '<%= Apoio.getDataAtual() %>';
    
    if (<%=jbean.getTipoCalculaIss() != null && jbean.getTipoCalculaIss().equals("1")%>) {
        $("calculoIndividualIss").checked = true;
        $("calculoTotalIss").checked = false;
    }else{
        $("calculoIndividualIss").checked = false;
        $("calculoTotalIss").checked = true;
    }

}
</script>

<script type="text/javascript" src="script/tiny_mce/tiny_mce.js"></script>
<script type="text/javascript">
tinyMCE.init({
    // General options
    mode: "exact",
    elements: "mensagemEntrega,mensagemManifesto,mensagemCtrc, mensagemCte, mensagemBoleto, mensagemCobranca, mensagemManifestoRepresentante, mensagemChegada, mensagemOcorrencia, mensagemNfse, mensagemOrcamento, mensagemColetaRepresentante, inpMensagemEmailVencimentoFatura ",
    theme: "advanced",
    plugins: "safari,pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template,inlinepopups",
    // Theme options
    theme_advanced_buttons1: "save,newdocument,|,bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,styleselect,formatselect,fontselect,fontsizeselect",
    theme_advanced_buttons2: "cut,copy,paste,pastetext,pasteword,|,search,replace,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,cleanup,help,code,|,insertdate,inserttime,preview,|,forecolor,backcolor",
    theme_advanced_buttons3: "tablecontrols,|,hr,removeformat,visualaid,|,sub,sup,|,charmap,emotions,iespell,media,advhr,|,print,|,ltr,rtl,|,fullscreen",
    theme_advanced_buttons4: "insertlayer,moveforward,movebackward,absolute,|,styleprops,|,cite,abbr,acronym,del,ins,attribs,|,visualchars,nonbreaking,template,pagebreak",
    theme_advanced_toolbar_location: "top",
    theme_advanced_toolbar_align: "left",
    theme_advanced_statusbar_location: "bottom",
    theme_advanced_resizing: false,
    // Example word content CSS (should be your site CSS) this one removes paragraph margins
    content_css: "css/word.css",
    document_base_url: "",
    // Replace values for the template plugin
    template_replace_values: {
        username: "Some User",
        staffid: "991234"
    }
});
</script>

<%@page import="java.sql.ResultSet"%>
<%@page import="mov_banco.conta.BeanConsultaConta"%>
<html>
    <head>
        <script src="script/prototype.js" type="text/javascript"></script>
        <script type="text/javascript" src="script/fabtabulous.js"></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>Webtrans - Alterar Configuração</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <link rel="stylesheet" href="stylesheets/tabs.css" type="text/css" media="all">
        
        <script src="script/funcoesTelaConfiguracao.js?v=${random.nextInt()}" type="text/javascript"></script>
        <style type="text/css">
            <!--
            .style2 {font-size: 14px}
            .style3 {font-size: 14px; font-weight: bold; }
            -->
        </style>

        <c:set var="config" value="<%= jbean %>"/>
    </head>

    <body onLoad="javascript:carrega();">
        <form method="post" action="./config?acao=salvar" id="formulario">
            <img src="img/banner.gif"> <br>
            <input type="hidden" id="plano_conta_descricao" name="plano_conta_descricao" value="" />
            <input type="hidden" name="plano_contas_id" id="plano_contas_id" value="">
            <input type="hidden" name="cod_conta" id="cod_conta" value="">
            <input type="hidden" name="idplanocustolancamento" id="idplanocustolancamento"value="<%=(carregaconfig ? jbean.getPlanoDefault().getIdconta() : 0)%>">
            <input type="hidden" name="idplanocusto" id="idplanocusto" value="">
            <input type="hidden" name="plcusto_descricao" id="plcusto_descricao" value="">
            <input type="hidden" name="plcusto_conta" id="plcusto_conta" value="">
            <input type="hidden" name="plcusto_adiantamento_id" id="plcusto_adiantamento_id" value="<%=(carregaconfig ? jbean.getPlanocusto_cartafrete().getIdconta() : 0)%>">
            <input type="hidden" name="idplanocusto_despesa" id="idplanocusto_despesa" value="">
            <input type="hidden" name="plcusto_descricao_despesa" id="plcusto_descricao_despesa" value="">
            <input type="hidden" name="idplanocusto_saldo" id="idplanocusto_saldo" value="<%=(carregaconfig ? jbean.getPlanoCustoSaldoId().getIdconta() : 0)%>">
            <input type="hidden" name="plcusto_conta_despesa" id="plcusto_conta_despesa" value="">
            <input type="hidden" name="idcfop" id="idcfop" value="<%=(carregaconfig ? jbean.getCfopDefault().getIdcfop() : 0)%>">
            <input type="hidden" name="idcfop2" id="idcfop2" value="0">
            <input type="hidden" name="desccfop2" id="desccfop2" value="">
            <input type="hidden" name="cfop2" id="cfop2" value="">
            <input type="hidden" name="idcfop2_2" id="idcfop2_2" value="<%=(carregaconfig ? jbean.getCfopDefault2().getIdcfop() : 0)%>">

            <input type="hidden" name="idcfop_industria_dentro" id="idcfop_industria_dentro" value="<%=(carregaconfig ? jbean.getCfopIndustriaDentro().getIdcfop() : 0)%>">
            <input type="hidden" name="idcfop_industria_fora" id="idcfop_industria_fora" value="<%=(carregaconfig ? jbean.getCfopIndustriaFora().getIdcfop() : 0)%>">
            <input type="hidden" name="idcfop_pessoa_fisica_dentro" id="idcfop_pessoa_fisica_dentro" value="<%=(carregaconfig ? jbean.getCfopPessoaFisicaDentro().getIdcfop() : 0)%>">
            <input type="hidden" name="idcfop_pessoa_fisica_fora" id="idcfop_pessoa_fisica_fora" value="<%=(carregaconfig ? jbean.getCfopPessoaFisicaFora().getIdcfop() : 0)%>">
            <input type="hidden" name="idcfop_outro_estado" id="idcfop_outro_estado" value="<%=(carregaconfig ? jbean.getCfopOutroEstado().getIdcfop() : 0)%>">
            <input type="hidden" name="idcfop_outro_estado_fora" id="idcfop_outro_estado_fora" value="<%=(carregaconfig ? jbean.getCfopOutroEstadoFora().getIdcfop() : 0)%>">
            <input type="hidden" name="idcfop_nota_servico" id="idcfop_nota_servico" value="<%=(carregaconfig ? jbean.getCfopNotaServico().getIdcfop() : 0)%>">

            <input type="hidden" name="jurospagos_id" id="jurospagos_id" value="<%=(carregaconfig ? jbean.getContaJurosPago().getId() : 0)%>">
            <input type="hidden" name="jurosrecebidos_id" id="jurosrecebidos_id" value="<%=(carregaconfig ? jbean.getContaJurosRecebidos().getId() : 0)%>">
            <input type="hidden" name="descontosconcedidos_id" id="descontosconcedidos_id" value="<%=(carregaconfig ? jbean.getContaDescontoConcedidos().getId() : 0)%>">
            <input type="hidden" name="descontosobtidos_id" id="descontosobtidos_id" value="<%=(carregaconfig ? jbean.getContaDescontoObtido().getId() : 0)%>">
            <input type="hidden" name="irrf_retido_id" id="irrf_retido_id" value="<%=(carregaconfig ? jbean.getContaIrrfRetido().getId() : 0)%>">
            <input type="hidden" name="inss_retido_id" id="inss_retido_id" value="<%=(carregaconfig ? jbean.getContaInssRetido().getId() : 0)%>">
            <input type="hidden" name="iss_retido_id" id="iss_retido_id" value="<%=(carregaconfig ? jbean.getContaIssRetido().getId() : 0)%>">
            <input type="hidden" name="pis_retido_id" id="pis_retido_id" value="<%=(carregaconfig ? jbean.getContaPisRetido().getId() : 0)%>">
            <input type="hidden" name="cofins_retido_id" id="cofins_retido_id" value="<%=(carregaconfig ? jbean.getContaCofinsRetido().getId() : 0)%>">
            <input type="hidden" name="cssl_retido_id" id="cssl_retido_id" value="<%=(carregaconfig ? jbean.getContaCsslRetido().getId() : 0)%>">
            <input type="hidden" name="contaClienteId" id="contaClienteId" value="<%=(carregaconfig ? jbean.getContaCliente().getId() : 0)%>">
            <input type="hidden" name="contaFornecedorId" id="contaFornecedorId" value="<%=(carregaconfig ? jbean.getContaFornecedor().getId() : 0)%>">
            <input type="hidden" name="contaProprietarioId" id="contaProprietarioId" value="<%=(carregaconfig ? jbean.getContaProprietario().getId() : 0)%>">
            <input type="hidden" name="contaComissaoMotoristaId" id="contaComissaoMotoristaId" value="<%=(carregaconfig ? jbean.getPlanoCustoComissaoMotorista().getIdconta() : 0)%>">
            <!-- Plano Custo Viagem -->
            <input type="hidden" name="idplano_custo_viagem" id="idplano_custo_viagem" value="">
            <input type="hidden" name="plano_custo_viagem" id="plano_custo_viagem" value="">
            <input type="hidden" name="plano_custo_viagem_descricao" id="plano_custo_viagem_descricao" value="">
            <!-- Plano de custo pedagio -->
             <input type="hidden" name="idPlanoCustoPedagio" id="idPlanoCustoPedagio" value="<%=(carregaconfig ? jbean.getPlanoCustoPedagio().getIdconta() : 0)%>">
            <!-- Ocorrencias -->
            <input type="hidden" name="ocorrencia" id="ocorrencia" value="">
            <input type="hidden" name="ocorrencia_id" id="ocorrencia_id" value="">
            <input type="hidden" name="nomeImagem" id="nomeImagem" value="<%= (carregaconfig ?jbean.getNomeImagemLogo() : "" ) %>">
            <input type="hidden" name="quantidadeDiasAvisoBackup" id="quantidadeDiasAvisoBackup" value="<%= (carregaconfig ?jbean.getQuantidadeDiasAvisoBackup() : 5 ) %>">
            <input type="hidden" name="quantidadeDiasEmailBackup" id="quantidadeDiasEmailBackup" value="<%= (carregaconfig ?jbean.getQuantidadeDiasEmailBackup() : 15 ) %>">
            <input type="hidden" name="idConfig" id="idConfig" value="<%= (carregaconfig ? jbean.getId() : "0" ) %>"/>
            <input type="hidden" name="valorTema" id="valorTema" value="<%=(carregaconfig ? jbean.getTipoTema().getValor() : "1" )%>" />
            <div align="center">
                <table width="85%" align="center" class="bordaFina">
                    <tr>
                        <td><b>Alterar configuração</b></td>
                    </tr>
                </table>

                <br/>
                <div id="container" style="width:85%" >
                    <div>
                        <ul id="tabs">
                            <li>
                                <a href="#tab1" ><strong>Configurações Gerais</strong></a>
                            </li>
                            <li>
                                <a href="#tab5" ><strong>Cadastros/Consultas</strong></a>
                            </li>
                            <li>
                                <a href="#tab2" ><strong>Contrato de Frete</strong></a>
                            </li>
                            <li>
                                <a href="#tab3" ><strong>Integração Contábil e Fiscal</strong></a>
                            </li>
                            <li>
                                <a href="#tab4" ><strong>E-mail</strong></a>
                            </li>
                            <li>
                                <a href="#tab8" ><strong>Tabela de Preço</strong></a>
                            </li>
                            <li>
                                <a href="#tab6" id="abaPreferencia"><strong>Preferências</strong></a>
                            </li>
                            <li>
                                <a href="#tab7" id="abaAuditoria"><strong>Auditoria</strong></a>
                            </li>
                        </ul>
                    </div>
                    <div class="panel" id="tab1">
                        <fieldset>
                            <table width="100%" border="0" class="bordaFina" align="center">
                                <tr class="tabela">
                                    <td colspan="4">
                                        <div align="center">
                                            Configura&ccedil;&otilde;es Gerais
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="2" class="TextoCampos">
                                        Modelo de Negócio da Transportadora: 
                                    </td>
                                    <td class="TextoCamposNoAlign" colspan="2" align="left">
                                        <label>
                                            <input type="radio" name="tipoFilial" id="tipoFilial" <%=permissaoModeloNegocio > 0 ? "" : "disabled"%> value="p" <%= carregaconfig ? (jbean.getMatrizFilialFranquia().equals("p") ? " checked " : "" ) : " checked " %>> Matriz/Filial
                                        </label>
                                        <label>
                                            <input type="radio" name="tipoFilial" id="tipoFilial" <%=permissaoModeloNegocio > 0 ? "" : "disabled"%> value="f" <%= carregaconfig ? (jbean.getMatrizFilialFranquia().equals("f") ? " checked " : "") : "" %>> Franquia
                                        </label>
                                    </td>
                                </tr>
                                <tr class="tabela">
                                <td colspan="4">
                                        <div align="center">
                                            Configura&ccedil;&otilde;es Cadastrais
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="2" class="TextoCampos">
                                        Estrutura Plano de Custo: 
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="estplano" id="estplano" type="text" size="20" maxlength="20" value="<%=(carregaconfig ? jbean.getEstruturaplano() : "")%>" onKeyPress="javascript:digitaestrutura();" class="inputtexto">
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20" colspan="4" class="tabela">
                                        <div align="center">
                                            Configura&ccedil;&otilde;es para Lan&ccedil;amentos de Despesas/Bancos
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="2" class="TextoCampos">
                                        Conta Padr&atilde;o para Controle de Adiantamento de Viagens:
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <select name="conta_adiantamento_viagem_id" id="conta_adiantamento_viagem_id" style="font-size:8pt;" class="inputtexto">
                                            <%      //Carregando todas as contas cadastradas
                                                BeanConsultaConta conta = new BeanConsultaConta();
                                                conta.setConexao(Apoio.getUsuario(request).getConexao());
                                                conta.mostraContas((nivelUser > 1 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), false, false, 0);
                                                ResultSet rsconta = conta.getResultado();%>
                                            <option value="0" selected>Selecione</option>
                                            <%while (rsconta.next()) {
                                                    if (rsconta.getString("tipo_conta").equals("ca")) {%>
                                            <option value="<%=rsconta.getString("idconta")%>" <%=(carregaconfig && jbean.getConta_adiantamento_viagem_id().getIdConta() == rsconta.getInt("idconta") ? "selected" : "")%>> <%=rsconta.getString("numero") + "-" + rsconta.getString("digito_conta") + " / " + rsconta.getString("banco")%></option>
                                            <%      }
                                                }
                                                rsconta.close();%>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="2" class="TextoCampos">
                                        Conta Padr&atilde;o para Controle de Adiantamento de Fornecedores:
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <select name="contaAdiantamentoFornecedor" id="contaAdiantamentoFornecedor" style="font-size:8pt;" class="inputtexto">
                                            <%      //Carregando todas as contas cadastradas
                                                conta.setConexao(Apoio.getUsuario(request).getConexao());
                                                conta.mostraContas((nivelUser > 1 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), false, false, 0);
                                                ResultSet rsconta3 = conta.getResultado();%>
                                            <option value="0" selected>Selecione</option>
                                            <%while (rsconta3.next()) {
                                                    if (rsconta3.getString("tipo_conta").equals("ca")) {%>
                                            <option value="<%=rsconta3.getString("idconta")%>" <%=(carregaconfig && jbean.getContaAdiantamentoFornecedor().getIdConta() == rsconta3.getInt("idconta") ? "selected" : "")%>> <%=rsconta3.getString("numero") + "-" + rsconta3.getString("digito_conta") + " / " + rsconta3.getString("banco")%></option>
                                            <% }
                                                }
                                                rsconta.close();%>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="2" class="TextoCampos">
                                        Conta Padr&atilde;o para Controle de Adiantamento de Clientes:
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <select name="contaAdiantamentoCliente" id="contaAdiantamentoCliente" style="font-size:8pt;" class="inputtexto">
                                            <%      //Carregando todas as contas cadastradas
                                                conta.setConexao(Apoio.getUsuario(request).getConexao());
                                                conta.mostraContas((nivelUser > 1 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), false, false, 0);
                                                ResultSet rsconta4 = conta.getResultado();%>
                                            <option value="0" selected>Selecione</option>
                                            <%while (rsconta4.next()) {
                                                    if (rsconta4.getString("tipo_conta").equals("ca")) {%>
                                            <option value="<%=rsconta4.getString("idconta")%>" <%=(carregaconfig && jbean.getContaAdiantamentoCliente().getIdConta() == rsconta4.getInt("idconta") ? "selected" : "")%>> <%=rsconta4.getString("numero") + "-" + rsconta4.getString("digito_conta") + " / " + rsconta4.getString("banco")%></option>
                                            <% }
                                                }
                                                rsconta.close();%>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="2" class="TextoCampos">
                                        Conta Padr&atilde;o para Baixa de Contas &agrave; pagar, &agrave; receber e Concilia&ccedil;&atilde;o: 
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <select name="conta_padrao_id" class="inputtexto" id="conta_padrao_id" style="font-size:8pt;">
                                            <%      //Carregando todas as contas cadastradas
                                                conta.mostraContas((nivelUser > 1 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), false, false, 0);
                                                ResultSet rsconta2 = conta.getResultado();
                                            %>
                                            <option value="0" selected>Selecione</option>
                                            <%while (rsconta2.next()) {%>
                                            <option value="<%=rsconta2.getString("idconta")%>" <%=(carregaconfig && jbean.getConta_padrao_id().getIdConta() == rsconta2.getInt("idconta") ? "selected" : "")%>> <%=rsconta2.getString("numero") + "-" + rsconta2.getString("digito_conta") + " / " + rsconta2.getString("banco")%></option>
                                            <%}
                                                rsconta2.close();%>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="2" class="TextoCampos">
                                        Valor M&aacute;ximo para Baixas sem Libera&ccedil;&atilde;o:
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="tetoliberacao" class="inputtexto" type="text" id="tetoliberacao" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getTetoLiberacao())) : "0.00")%>" size="5" align="right" >
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="4" class="Celulazebra2">
                                        <div align="center">
                                            <input type="checkbox" name="chk_und_custo" id="chk_und_custo" value="true" <%=(carregaconfig && jbean.isUnidadeCustoObrigatoria() ? "checked" : "")%>>
                                            Obrigar a Unidade de Custo nos Lançamentos de Despesas
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="4" class="Celulazebra2">
                                        <div align="center">
                                            <input type="checkbox" name="chk_plano_custo_obrigatorio" id="chk_plano_custo_obrigatorio" value="true" <%=(carregaconfig && jbean.isPlanoCustoObrigatorio() ? "checked" : "")%>>
                                            Obrigar o Plano de Custo nos Lançamentos de Despesas
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="4" class="Celulazebra2">
                                        <div align="center">
                                            <input type="checkbox" name="provisaoDespesa" id="provisaoDespesa" value="true" <%=(carregaconfig && jbean.isProvisaoDespesa() ? "checked" : "")%>>
                                            Habilitar Opção de Gerar Provisão nos Lançamentos de Despesas
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="4" class="Celulazebra2">
                                        <div align="center">
                                            <input type="checkbox" name="fechamentoDiaConcBanc" id="fechamentoDiaConcBanc" value="true" <%=(carregaconfig && jbean.isFechamentoDiaConcBanc() ? "checked" : "")%>>
                                            Habilitar Controle de Fechamento do dia na Conciliação Bancária.
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="4" class="Celulazebra2">
                                        <div align="center">
                                            <input type="checkbox" name="controlarTalonario" id="controlarTalonario" value="true" <%=(carregaconfig && jbean.isControlarTalonario() ? "checked" : "")%>>
                                            Habilitar Controle de Talonário para Cheques Emitidos.
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="2" class="TextoCampos">Plano de custo padrão para lançamentos automáticos da diária do motorista:</td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="contaPadraoMotoristaDiaria" type="text" id="contaPadraoMotoristaDiaria" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getPlanoCustoDiariaMotorista().getConta() : "")%>" size="10" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localizaMotoristaDiaria" type="button" class="botoes" id="localizaMotoristaDiaria" value="..." onClick="javascript:localizaPlanoViagem('plano_custo_diaria_motorista');">
                                            <input name="descricaoPadraoMotoristaDiaria" type="text" id="descricaoPadraoMotoristaDiaria" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getPlanoCustoDiariaMotorista().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                            <input type="hidden" name="idContaPadraoMotoristaDiaria" id="idContaPadraoMotoristaDiaria" value="<%=(carregaconfig ? jbean.getPlanoCustoDiariaMotorista().getIdconta() : "0")%>"/>
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="2" class="TextoCampos">Plano de custo padrão para lançamentos automáticos da pernoite do motorista:</td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="contaPadraoMotoristaPernoite" type="text" id="contaPadraoMotoristaPernoite" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getPlanoCustoPernoiteMotorista().getConta() : "")%>" size="10" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localizaMotoristaPernoite" type="button" class="botoes" id="localizaMotoristaPernoite" value="..." onClick="javascript:localizaPlanoViagem('plano_custo_pernoite_motorista');">
                                            <input name="descricaoPadraoMotoristaPernoite" type="text" id="descricaoPadraoMotoristaPernoite" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getPlanoCustoPernoiteMotorista().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                            <input type="hidden" name="idContaPadraoMotoristaPernoite" id="idContaPadraoMotoristaPernoite" value="<%=(carregaconfig ? jbean.getPlanoCustoPernoiteMotorista().getIdconta() : "0")%>"/>
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="2" class="TextoCampos">Plano de custo padrão para lançamentos automáticos da alimentação do motorista:</td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="contaPadraoMotoristaAlimentacao" type="text" id="contaPadraoMotoristaAlimentacao" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getPlanoCustoAlimentacaoMotorista().getConta() : "")%>" size="10" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localizaMotoristaAlimentacao" type="button" class="botoes" id="localizaMotoristaAlimentacao" value="..." onClick="javascript:localizaPlanoViagem('plano_custo_alimentacao_motorista');">
                                            <input name="descricaoPadraoMotoristaAlimentacao" type="text" id="descricaoPadraoMotoristaAlimentacao" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getPlanoCustoAlimentacaoMotorista().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                            <input type="hidden" name="idContaPadraoMotoristaAlimentacao" id="idContaPadraoMotoristaAlimentacao" value="<%=(carregaconfig ? jbean.getPlanoCustoAlimentacaoMotorista().getIdconta() : "0")%>"/>
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="2" class="TextoCampos">Plano de custo padrão para lançamentos automáticos da diária do ajudante:</td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="contaPadraoAjudanteDiaria" type="text" id="contaPadraoAjudanteDiaria" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getPlanoCustoDiariaAjudante().getConta() : "")%>" size="10" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localizaAjudanteDiaria" type="button" class="botoes" id="localizaAjudanteDiaria" value="..." onClick="javascript:localizaPlanoViagem('plano_custo_diaria_ajudante');">
                                            <input name="descricaoPadraoAjudanteDiaria" type="text" id="descricaoPadraoAjudanteDiaria" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getPlanoCustoDiariaAjudante().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                            <input type="hidden" name="idContaPadraoAjudanteDiaria" id="idContaPadraoAjudanteDiaria" value="<%=(carregaconfig ? jbean.getPlanoCustoDiariaAjudante().getIdconta() : "0")%>"/>
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="2" class="TextoCampos">Plano de custo padrão para lançamentos automáticos da pernoite do ajudante:</td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="contaPadraoAjudantePernoite" type="text" id="contaPadraoAjudantePernoite" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getPlanoCustoPernoiteAjudante().getConta() : "")%>" size="10" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localizaAjudantePernoite" type="button" class="botoes" id="localizaAjudantePernoite" value="..." onClick="javascript:localizaPlanoViagem('plano_custo_pernoite_ajudante');">
                                            <input name="descricaoPadraoAjudantePernoite" type="text" id="descricaoPadraoAjudantePernoite" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getPlanoCustoPernoiteAjudante().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                            <input type="hidden" name="idContaPadraoAjudantePernoite" id="idContaPadraoAjudantePernoite" value="<%=(carregaconfig ? jbean.getPlanoCustoPernoiteAjudante().getIdconta() : "0")%>"/>
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="2" class="TextoCampos">Plano de custo padrão para lançamentos automáticos da alimentação do ajudante:</td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="contaPadraoAjudanteAlimentacao" type="text" id="contaPadraoAjudanteAlimentacao" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getPlanoCustoAlimentacaoAjudante().getConta() : "")%>" size="10" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localizaAjudanteAlimentacao" type="button" class="botoes" id="localizaAjudanteAlimentacao" value="..." onClick="javascript:localizaPlanoViagem('plano_custo_alimentacao_ajudante');">
                                            <input name="descricaoPadraoAjudanteAlimentacao" type="text" id="descricaoPadraoAjudanteAlimentacao" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getPlanoCustoAlimentacaoAjudante().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                            <input type="hidden" name="idContaPadraoAjudanteAlimentacao" id="idContaPadraoAjudanteAlimentacao" value="<%=(carregaconfig ? jbean.getPlanoCustoAlimentacaoAjudante().getIdconta() : "0")%>"/>
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="2" class="TextoCampos">Valor padrão da pernoite em lançamentos de viagens:</td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input id="valorPernoiteViagem" name="valorPernoiteViagem" type="text" class="inputtexto" size="7" maxlength="12" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Double.valueOf(jbean.getValorPernoiteViagem())) : "0.00")%>" >
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="2" class="TextoCampos">Valor padrão da alimentação em lançamentos de viagens:</td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input id="valorAlimentacaoViagem" name="valorAlimentacaoViagem" type="text" class="inputtexto" size="7" maxlength="12" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Double.valueOf(jbean.getValorAlimentacaoViagem())) : "0.00")%>">
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20" colspan="4" class="tabela"> 
                                        <div align="center">
                                            Configura&ccedil;&otilde;es para Lan&ccedil;amentos de Coletas
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="4" class="Celulazebra2">
                                        <div align="center">
                                            <input type="checkbox" name="gerarGem" id="gerarGem" value="true" <%=(carregaconfig && jbean.isGeraGEMColeta() ? "checked" : "")%>>
                                            Gerar GEM no gwLogis Automaticamente ao Incluir uma Coleta
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">
                                        Serviço padrão p/ Lançamentos de Coleta/OS na Montagem de Carga:
                                    </td>
                                    <td colspan="2" class="Celulazebra2">
                                        <input name="type_service_id" type="hidden" id="type_service_id" style="background-color:#FFFFF1" value="<%=(carregaconfig ? jbean.getServicoMontagemCarga().getId() : "0")%>" size="30" maxlength="50" readonly="true">
                                        <input name="type_service_descricao" type="text" class="inputReadOnly" id="type_service_descricao" value="<%=(carregaconfig ? jbean.getServicoMontagemCarga().getDescricao() : "")%>" size="35" maxlength="50" readonly="true">
                                        <input name="localiza_servico" type="button" class="botoes" id="localiza_servico" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=36', 'Servico');">
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20" colspan="4" class="tabela"> 
                                        <div align="center">
                                            Configura&ccedil;&otilde;es para Lan&ccedil;amentos de CT-e(s)
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="2" class="TextoCampos">
                                        Conta Default para os Lan&ccedil;amentos:
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="plcusto_conta_lancamento" type="text" id="plcusto_conta_lancamento" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getPlanoDefault().getConta() : "")%>" size="10" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_plano" type="button" class="botoes" id="localiza_plano" value="..." onClick="javascript:localizaplano();">
                                            <input name="plcusto_descricao_lancamento" type="text" id="plcusto_descricao_lancamento" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getPlanoDefault().getDescricao() : "")%>" size="25" maxlength="25" readonly="true">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="2" class="TextoCampos">
                                        CFOP Padrão para Lançamentos Dentro do Estado (Comércio):
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="cfop" type="text" id="cfop" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopDefault().getCfop() : "")%>" size="5" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_cfop" type="button" class="botoes" id="localiza_cfop" value="..." onClick="javascript:localizacfop();">
                                            <input name="desccfop" type="text" id="desccfop" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopDefault().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">
                                        CFOP Padrão para Lançamentos Fora do Estado (Comércio):
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="cfop2_2" type="text" id="cfop2_2" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopDefault2().getCfop() : "")%>" size="5" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_cfop2" type="button" class="botoes" id="localiza_cfop2" value="..." onClick="javascript:localizacfop2('CFOP_fora_do_estado');">
                                            <input name="desccfop2_2" type="text" id="desccfop2_2" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopDefault2().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="2" class="TextoCampos">
                                        CFOP Padrão para Lançamentos Dentro do Estado (Indústria):
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="cfop_industria_dentro" type="text" id="cfop_industria_dentro" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopIndustriaDentro().getCfop() : "")%>" size="5" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_cfop" type="button" class="botoes" id="localiza_cfop" value="..." onClick="javascript:localizacfop2('cfop_industria_dentro_do_estado');">
                                            <input name="desccfop_industria_dentro" type="text" id="desccfop_industria_dentro" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopIndustriaDentro().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">
                                        CFOP Padrão para Lançamentos Fora do Estado (Indústria):
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="cfop_industria_fora" type="text" id="cfop_industria_fora" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopIndustriaFora().getCfop() : "")%>" size="5" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_cfop2" type="button" class="botoes" id="localiza_cfop2" value="..." onClick="javascript:localizacfop2('cfop_industria_fora_do_estado');">
                                            <input name="desccfop_industria_fora" type="text" id="desccfop_industria_fora" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopIndustriaFora().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">
                                        CFOP Padrão para Lançamentos Dentro do Estado (Transporte):
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="cfop_transporte_dentro" type="text" id="cfop_transporte_dentro" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopTransporteDentro().getCfop() : "")%>" size="5" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_cfop2" type="button" class="botoes" id="localiza_cfop2" value="..." onClick="javascript:localizacfop2('cfop_transporte_dentro');">
                                            <input name="desccfop_transporte_dentro" type="text" id="desccfop_transporte_dentro" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopTransporteDentro().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                            <input type="hidden" name="idcfop_transporte_dentro" id="idcfop_transporte_dentro" value="<%=(carregaconfig ? jbean.getCfopTransporteDentro().getIdcfop() : 0)%>">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">
                                        CFOP Padrão para Lançamentos Fora do Estado (Transporte):
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="cfop_transporte_fora" type="text" id="cfop_transporte_fora" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopTransporteFora().getCfop() : "")%>" size="5" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_cfop2" type="button" class="botoes" id="localiza_cfop2" value="..." onClick="javascript:localizacfop2('cfop_transporte_fora');">
                                            <input name="desccfop_transporte_fora" type="text" id="desccfop_transporte_fora" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopTransporteFora().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                            <input type="hidden" name="idcfop_transporte_fora" id="idcfop_transporte_fora" value="<%=(carregaconfig ? jbean.getCfopTransporteFora().getIdcfop() : 0)%>">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">
                                        CFOP Padrão para Lançamentos Dentro do Estado (Prestador de Serviço):
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="cfop_prestador_servico_dentro" type="text" id="cfop_prestador_servico_dentro" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopPrestadorServicoDentro().getCfop() : "")%>" size="5" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_cfop2" type="button" class="botoes" id="localiza_cfop2" value="..." onClick="javascript:localizacfop2('cfop_prestador_servico_dentro');">
                                            <input name="desccfop_prestador_servico_dentro" type="text" id="desccfop_prestador_servico_dentro" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopPrestadorServicoDentro().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                            <input type="hidden" name="idcfop_prestador_servico_dentro" id="idcfop_prestador_servico_dentro" value="<%=(carregaconfig ? jbean.getCfopPrestadorServicoDentro().getIdcfop() : 0)%>">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">
                                        CFOP Padrão para Lançamentos Fora do Estado (Prestador de Serviço):
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="cfop_prestador_servico_fora" type="text" id="cfop_prestador_servico_fora" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopPrestadorServicoFora().getCfop() : "")%>" size="5" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_cfop2" type="button" class="botoes" id="localiza_cfop2" value="..." onClick="javascript:localizacfop2('cfop_prestador_servico_fora');">
                                            <input name="desccfop_prestador_servico_fora" type="text" id="desccfop_prestador_servico_fora" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopPrestadorServicoFora().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                            <input type="hidden" name="idcfop_prestador_servico_fora" id="idcfop_prestador_servico_fora" value="<%=(carregaconfig ? jbean.getCfopPrestadorServicoFora().getIdcfop() : 0)%>">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">
                                        CFOP Padrão para Lançamentos Dentro do Estado (Produtor Rural):
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="cfop_produtor_rural_dentro" type="text" id="cfop_produtor_rural_dentro" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopProdutorRuralDentro().getCfop() : "")%>" size="5" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_cfop2" type="button" class="botoes" id="localiza_cfop2" value="..." onClick="javascript:localizacfop2('cfop_produtor_rural_dentro');">
                                            <input name="desccfop_produtor_rural_dentro" type="text" id="desccfop_produtor_rural_dentro" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopProdutorRuralDentro().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                            <input type="hidden" name="idcfop_produtor_rural_dentro" id="idcfop_produtor_rural_dentro" value="<%=(carregaconfig ? jbean.getCfopProdutorRuralDentro().getIdcfop() : 0)%>">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">
                                        CFOP Padrão para Lançamentos Fora do Estado (Produtor Rural):
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="cfop_produtor_rural_fora" type="text" id="cfop_produtor_rural_fora" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopProdutorRuralFora().getCfop() : "")%>" size="5" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_cfop2" type="button" class="botoes" id="localiza_cfop2" value="..." onClick="javascript:localizacfop2('cfop_produtor_rural_fora');">
                                            <input name="desccfop_produtor_rural_fora" type="text" id="desccfop_produtor_rural_fora" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopProdutorRuralFora().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                            <input type="hidden" name="idcfop_produtor_rural_fora" id="idcfop_produtor_rural_fora" value="<%=(carregaconfig ? jbean.getCfopProdutorRuralFora().getIdcfop() : 0)%>">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="2" class="TextoCampos">
                                        CFOP Padrão para Lançamentos dentro do Estado (Pessoa Física):
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="cfop_pessoa_fisica_dentro" type="text" id="cfop_pessoa_fisica_dentro" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopPessoaFisicaDentro().getCfop() : "")%>" size="5" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_cfop" type="button" class="botoes" id="localiza_cfop" value="..." onClick="javascript:localizacfop2('cfop_pessoa_fisica_dentro_do_estado');">
                                            <input name="desccfop_pessoa_fisica_dentro" type="text" id="desccfop_pessoa_fisica_dentro" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopPessoaFisicaDentro().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">
                                        CFOP Padrão para Lançamentos Fora do Estado (Pessoa Física):
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="cfop_pessoa_fisica_fora" type="text" id="cfop_pessoa_fisica_fora" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopPessoaFisicaFora().getCfop() : "")%>" size="5" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_cfop2" type="button" class="botoes" id="localiza_cfop2" value="..." onClick="javascript:localizacfop2('cfop_pessoa_fisica_fora_do_estado');">
                                            <input name="desccfop_pessoa_fisica_fora" type="text" id="desccfop_pessoa_fisica_fora" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopPessoaFisicaFora().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">
                                        CFOP Padrão para Lançamentos com Origem Diferente da UF da Filial e Destino dentro da UF de Origem:
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="cfop_outro_estado" type="text" id="cfop_outro_estado" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopOutroEstado().getCfop() : "")%>" size="5" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_cfop2" type="button" class="botoes" id="localiza_cfop2" value="..." onClick="javascript:localizacfop2('cfop_de_outra_UF');">
                                            <input name="desccfop_outro_estado" type="text" id="desccfop_outro_estado" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopOutroEstado().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">
                                        CFOP Padrão para Lançamentos com Origem diferente da UF da Filial e Destino Fora da UF de Origem:
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="cfop_outro_estado_fora" type="text" id="cfop_outro_estado_fora" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopOutroEstadoFora().getCfop() : "")%>" size="5" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_cfop2" type="button" class="botoes" id="localiza_cfop2" value="..." onClick="javascript:localizacfop2('cfop_de_outra_UF_fora');">
                                            <input name="desccfop_outro_estado_fora" type="text" id="desccfop_outro_estado_fora" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopOutroEstadoFora().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">
                                        CFOP Padrão para Destinatário do Exterior com Origem do Frete dentro do Estado:
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="cfop_exterior_dentro" type="text" id="cfop_exterior_dentro" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopExteriorDentro().getCfop() : "")%>" size="5" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_cfop2" type="button" class="botoes" id="localiza_cfop2" value="..." onClick="javascript:localizacfop2('cfop_exterior_dentro');">
                                            <input name="desccfop_exterior_dentro" type="text" id="desccfop_exterior_dentro" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopExteriorDentro().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                            <input type="hidden" name="idcfop_exterior_dentro" id="idcfop_exterior_dentro" value="<%=(carregaconfig ? jbean.getCfopExteriorDentro().getIdcfop() : 0)%>">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">
                                        CFOP Padrão para Destinatário do Exterior com Origem do Frete Fora do Estado:
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="cfop_exterior_fora" type="text" id="cfop_exterior_fora" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopExteriorFora().getCfop() : "")%>" size="5" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_cfop2" type="button" class="botoes" id="localiza_cfop2" value="..." onClick="javascript:localizacfop2('cfop_exterior_fora');">
                                            <input name="desccfop_exterior_fora" type="text" id="desccfop_exterior_fora" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopExteriorFora().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                            <input type="hidden" name="idcfop_exterior_fora" id="idcfop_exterior_fora" value="<%=(carregaconfig ? jbean.getCfopExteriorFora().getIdcfop() : 0)%>">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">
                                        CFOP Padrão para Lançamentos de Notas de Serviços:
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="cfop_nota_servico" type="text" id="cfop_nota_servico" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopNotaServico().getCfop() : "")%>" size="5" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_cfop2" type="button" class="botoes" id="localiza_cfop2" value="..." onClick="javascript:localizacfop2('cfop_nota_servico');">
                                            <input name="desccfop_nota_servico" type="text" id="desccfop_nota_servico" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopNotaServico().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">
                                        CFOP Subcontratação para dentro da UF:
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="cfop_subcontratacao_dentro" type="text" id="cfop_subcontratacao_dentro" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopSubContratacaoDentro().getCfop() : "")%>" size="5" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_cfop2" type="button" class="botoes" id="localiza_cfop2" value="..." onClick="javascript:localizacfop2('cfop_subcontratacao_dentro_do_estado');">
                                            <input name="desccfop_subcontratacao_dentro" type="text" id="desccfop_subcontratacao_dentro" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopSubContratacaoDentro().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                            <input type="hidden" name="idcfop_subcontratacao_dentro" id="idcfop_subcontratacao_dentro" value="<%=(carregaconfig ? jbean.getCfopSubContratacaoDentro().getIdcfop() : 0)%>">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">
                                        CFOP Subcontratação para fora da UF:
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="cfop_subcontratacao_fora" type="text" id="cfop_subcontratacao_fora" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopSubContratacaoFora().getCfop() : "")%>" size="5" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_cfop2" type="button" class="botoes" id="localiza_cfop2" value="..." onClick="javascript:localizacfop2('cfop_subcontratacao_fora_do_estado');">
                                            <input name="desccfop_subcontratacao_fora" type="text" id="desccfop_subcontratacao_fora" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getCfopSubContratacaoFora().getDescricao() : "")%>" size="30" maxlength="25" readonly="true">
                                            <input type="hidden" name="idcfop_subcontratacao_fora" id="idcfop_subcontratacao_fora" value="<%=(carregaconfig ? jbean.getCfopSubContratacaoFora().getIdcfop() : 0)%>">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table width="100%">
                                            <tr>
                                                <td class="TextoCampos">
                                                    Série Padrão para CT-e:
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <input name="serieCtrcPadrao" type="text" id="serieCtrcPadrao" class="inputtexto" size="4" value="<%=(carregaconfig ? jbean.getSeriePadraoCtrc() : "")%>">
                                                </td>
                                                <td class="TextoCampos">
                                                    Série Padrão para Nota de Serviço:
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <input name="serieNotaServicoPadrao" type="text" id="serieNotaServicoPadrao" class="inputtexto" size="4" value="<%=(carregaconfig ? jbean.getSeriePadraoNotaServico() : "")%>">
                                                </td>
                                                <td class="TextoCampos">
                                                    Percentual adicional no valor do seguro (IOF, tarifas diversas e etc...):
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <input name="percentualExtraCustoSeguro" class="inputtexto" type="text" id="percentualExtraCustoSeguro" size="4" onblur="javascript:seNaoFloatReset(this,'0.00')" value="<%=(carregaconfig ? vlrformat.format(Double.valueOf(jbean.getPercentualExtraCustoSeguro())) :"0.00")%>" size="5" align="right" >
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>                            
                                <tr>
                                    <td colspan="4" class="Celulazebra2">
                                        <div align="center">
                                            <input type="checkbox" name="permiteEntregaCtrcNaoResolvido" id="permiteEntregaCtrcNaoResolvido" value="true" <%=(carregaconfig && jbean.isPermiteEntregaCtrcNaoResolvido() ? "checked" : "")%>>
                                            Permitir a Entrega dos CT-e(s) com Ocorrências não Resolvidas.
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="Celulazebra2">
                                        <div align="center">
                                            <input type="checkbox" name="mostraEnderecoClienteCtrc" id="mostraEnderecoClienteCtrc" value="true" <%=(carregaconfig && jbean.isMostraEnderecoClienteCtrc() ? "checked" : "")%>>
                                            Mostrar Endereço do Remetente e Destinatário no Lançamento do CT-e.
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="Celulazebra2">
                                        <div align="center">
                                            <input type="checkbox" name="baixaEntregaNota" id="baixaEntregaNota" value="true" <%=(carregaconfig && jbean.isBaixaEntregaNota() ? "checked" : "")%>>
                                            Ativar Baixa de Entrega por Nota Fiscal.
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="Celulazebra2">
                                        <div align="center">
                                            <input type="checkbox" name="obrigarOcorrenciaBaixCtrc" id="obrigarOcorrenciaBaixCtrc" value="true" <%=(carregaconfig && jbean.isObrigarOcorrenciaBaixCtrc() ? "checked" : "")%>>
                                            Ao baixar Entrega de um CT-e, Obrigar a Inclusão de no Mínimo uma Ocorrência
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="Celulazebra2">
                                        <div align="center">
                                            <input type="checkbox" name="romanearCTRC" id="romanearCTRC" value="true" <%=(carregaconfig && jbean.isRomanearCtrcSemChegada() ? "checked" : "")%>>
                                            Permitir Adicionar um CT-e sem data de Chegada ao Incluir um Romaneio
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos" colspan="2">
                                        Permitir Lançamento de OS em aberto para veículo (Adv,Coleta,Contrato de Frete,CT-e,Manifesto,Romaneio):
                                    </td>
                                    <td class="Celulazebra2" colspan="2">                                        
                                        <select id="permitirLancamentoOSAbertoVeciulo" name="permitirLancamentoOSAbertoVeiculo" class="inputtexto" style="width: 200px">
                                            <option value="SP" <%=(carregaconfig && jbean.getPermitirLancamantoOSAbertoVeiculo().equals("SP") ? "selected" : "")%>>Sempre Permitir</option>
                                            <option value="NP" <%=(carregaconfig && jbean.getPermitirLancamantoOSAbertoVeiculo().equals("NP") ? "selected" : "")%>>Não Permitir</option>
                                            <option value="PS" <%=(carregaconfig && jbean.getPermitirLancamantoOSAbertoVeiculo().equals("PS") ? "selected" : "")%>>Permitir Supervisor</option>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="textoCampos" colspan="2">
                                        Ao incluir um CT-e, não considerar alíquotas de seguro se a(s) série(s) for(em):
                                    </td>
                                    <td class="textoCampos" colspan="2" style="text-align: left">
                                        <input id="serieExclusaoAverbacao" name="serieExclusaoAverbacao" class="inputTexto" type="text" maxlength="20" size="20" value="<%=(carregaconfig ? jbean.getSerieExclusaoAverbacao() : "")%>" /> Exemplo: "M,R,2"
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="Celulazebra2"><div align="center" >
                                            <input type="checkbox" name="permiteSalvarCte" id="permiteSalvarCte" value="true" <%=(carregaconfig && jbean.isPermiteSalvarCTEValorMenorImpostos() ? "checked" : "")%> >
                                            Permite salvar um CT-e caso o valor da prestação de serviço seja menor que os impostos (ICMS e Impostos Federais).</div>
                                   </td>    
                                </tr>
                                <tr>
                                    <td height="20" colspan="4" class="tabela"> 
                                        <div align="center">
                                            Configura&ccedil;&otilde;es para Lan&ccedil;amentos de Manifestos
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="4" class="Celulazebra2">
                                        <div align="center">
                                            <input type="checkbox" name="gerarGsm" id="gerarGsm" value="true" <%=(carregaconfig && jbean.isGeraGSMManifesto() ? "checked" : "")%>>
                                            Gerar GSM no gwLogis Automaticamente ao Incluir um Manifesto
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="4" class="Celulazebra2">
                                        <div align="center">
                                            <input type="checkbox" name="manifestarCtrcVariasVezes" id="manifestarCtrcVariasVezes" value="true" <%=(carregaconfig && jbean.isManifestarCtrcVariasVezes() ? "checked" : "")%>>
                                            Manifestar CT-e mais de uma vez
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="Celulazebra2">
                                        <div align="center">
                                            <input type="checkbox" name="subCodigoManifesto" id="subCodigoManifesto" value="true" <%=(carregaconfig && jbean.isSubCodigoManifesto() ? "checked" : "")%>>
                                            Utilizar Sub Código nos Manifestos
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">
                                        Utilizar como Sequência do Manifesto:
                                    </td>
                                    <td colspan="2" class="Celulazebra2">
                                        <select name="tipo_sequencia_manifesto" id="tipo_sequencia_manifesto" class="inputtexto">
                                            <option value="0" <%=(carregaconfig && jbean.getTipoSequenciaManifesto().equals("0") ? "selected" : "")%>>A filial de origem e a filial de destino.</option>
                                            <option value="1" <%=(carregaconfig && jbean.getTipoSequenciaManifesto().equals("1") ? "selected" : "")%>>Apenas a filial de origem.</option>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="Celulazebra2">
                                        <div align="center">
                                            <input type="checkbox" name="ctrcsConfirmadosParaManifesto" id="ctrcsConfirmadosParaManifesto" value="true" <%=(carregaconfig && jbean.isCtrcsConfirmadosParaManifesto() ? "checked" : "")%>>
                                            Ao incluir um manifesto só poderá ser informado CT-e(s) Confirmados
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="Celulazebra2">
                                        <div align="center">
                                            <input type="checkbox" name="incluirRetirarCteManifestoContratoFreteLancado" id="incluirRetirarCteManifestoContratoFreteLancado" value="true" <%=(carregaconfig && jbean.isIncluirRetirarCteManifestoFreteLancado() ? "checked" : "")%>>
                                            Permitir Incluir/Retirar um CT-e do manifesto caso já tenha contrato frete lan&ccedil;ado
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="celulaZebra2" style="text-align: center"> Ao incluir um manifesto utilizar como cidade de destino:
                                        
                                        <select id="ordenacaoCteManifesto" name="ordenacaoCteManifesto" class="inputtexto">
                                            <option value="c" <%= (carregaconfig && jbean.getTipoOrdenacaoCteManifesto().equals("c") ? "selected" : "") %> >A cidade de destino do CT-e</option>
                                            <option value="d" <%= (carregaconfig && jbean.getTipoOrdenacaoCteManifesto().equals("d") ? "selected" : "") %> >A Cidade mais distante (Precisa de rota cadastrada)</option>
                                            <option value="f" <%= (carregaconfig && jbean.getTipoOrdenacaoCteManifesto().equals("f") ? "selected" : "") %> >Pela cidade da filial</option>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="Celulazebra2" style="text-align: center">
                                        <input type="checkbox" name="is-permitir-manifesto-veiculo-nao-encerrado" id="is-permitir-manifesto-veiculo-nao-encerrado" value="true" <%=(carregaconfig && jbean.isPermitirManifestoVeiculoNaoEncerrado() ? "checked" : "")%>>
                                        N&atilde;o permitir incluir um novo manifesto para o mesmo ve&iacute;culo ou motorista caso j&aacute; tenha um outro manifesto n&atilde;o encerrado para os mesmos.
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20" colspan="4" class="tabela"> 
                                        <div align="center">
                                            Configurações para Lançamentos de Adiantamento de Viagens
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="4" class="Celulazebra2">
                                        <div align="center">
                                            <input type="checkbox" name="impedeViagemMotorista" id="impedeViagemMotorista" value="true" <%=(carregaconfig && jbean.isImpedeViagemMotorista() ? "checked" : "")%>>
                                            Travar Inclusão de Adiantamento de Viagem para Motorista, caso a Viagem Anterior Esteja em Aberto.
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="4" class="Celulazebra2">
                                        <div align="center">
                                            <input type="checkbox" name="obrigaKmChegadaAdv" id="obrigaKmChegadaAdv" value="true" <%=(carregaconfig && jbean.isObrigaKmChegadaAdv()? "checked" : "")%>>
                                            Ao baixar o ADV o km de chegada não poderá ser menor que o km de saída.
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="2" class="TextoCampos">
                                        Plano de Custo Padrão para Lançamentos Automáticos da Comissão do Motorista:
                                    </td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="plcusto_comissao" type="text" id="plcusto_comissao" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getPlanoCustoComissaoMotorista().getConta() : "")%>" size="10" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_plano_comissao" type="button" class="botoes" id="localiza_plano_comissao" value="..." onClick="javascript:localizaplanocomissao();">
                                            <input name="plcusto_descricao_comissao" type="text" id="plcusto_descricao_comissao" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getPlanoCustoComissaoMotorista().getDescricao() : "")%>" size="25" maxlength="25" readonly="true">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" colspan="4" class="Celulazebra2">
                                        <div align="center">
                                            <input type="checkbox" name="baixarAdvSaldoZerado" id="baixarAdvSaldoZerado" value="true" <%=(carregaconfig && jbean.isBaixarAdvSaldoZerado()? "checked" : "")%>>
                                            Ao baixar o ADV, permitir que fique saldos de acerto/reembolso para o motorista.
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20" colspan="4" class="tabela">
                                        <div align="center">
                                            Configurações para Lançamentos de Romaneios
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">Ocorrência padrão para baixa de CT-e na tela de romaneio:</td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="ocorrenciaRomaneioCTe" type="text" id="ocorrenciaRomaneioCTe" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getOcorrenciaRomaneio().getCodigo() : "")%>" size="10" maxlength="25" readonly="true">
                                        <input type="hidden" name="idOcorrenciaRomaneioCTe" id="idOcorrenciaRomaneioCTe" value="<%=(carregaconfig ? jbean.getOcorrenciaRomaneio().getId() : 0)%>">
                                        <input name="" type="button" class="botoes" id="" value="..." onClick="javascript:localizaOcorrenciaRomaneioCTe();">
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">Ocorrência padrão para baixa de Coleta na tela de romaneio:</td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="ocorrenciaRomaneioColeta" type="text" id="ocorrenciaRomaneioColeta" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getOcorrenciaRomaneioColeta().getCodigo() : "")%>" size="10" maxlength="25" readonly="true">
                                        <input type="hidden" name="idOcorrenciaRomaneioColeta" id="idOcorrenciaRomaneioColeta" value="<%=(carregaconfig ? jbean.getOcorrenciaRomaneioColeta().getId() : 0)%>">
                                        <input name="" type="button" class="botoes" id="" value="..." onClick="javascript:localizaOcorrenciaRomaneioColeta();">
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="Celulazebra2">
                                        <div align="center">
                                            <label>
                                                <input type="checkbox" name="ctrcsConfirmadosParaRomaneio" id="ctrcsConfirmadosParaRomaneio" value="true" <%=(carregaconfig && jbean.isCtrcsConfirmadosParaRomaneio() ? "checked" : "")%>>
                                                Ao incluir um romaneio só poderá ser informado CT-e(s) confirmados                                                
                                            </label>
                                        </div>
                                    </td>
                                </tr>
                                <tr>   
                                    <td colspan="2" class="Celulazebra2">
                                        <div align="center">
                                            <label>
                                                <input type="checkbox" name="romaneioAutorizacaoPagamento" id="romaneioAutorizacaoPagamento" value="true" <%=(carregaconfig && jbean.isRomaneioAutorizacaoPagamento() ? "checked" : "")%> onclick="liberarAutorizacaoPadraoRomaneio();">
                                                Ativar autorização de pagamento nas entregas do romaneio                                                
                                            </label>
                                        </div>
                                    </td>
                                    <td colspan="2" class="Celulazebra2">
                                        <div align="center" id="divRomaneioAutorizacaoPadrao" style="display: none">
                                            <label>
                                                <input type="radio" name="romaneioAutorizacaoPadrao" id="romaneioAutorizacaoPadrao" value="true" <%=(carregaconfig && jbean.isRomaneioAutorizacaoPadrao() ? "checked" : "")%>>
                                                Autorizado                                                
                                            </label>
                                            <label>
                                                <input type="radio" name="romaneioAutorizacaoPadrao" id="romaneioAutorizacaoPadrao" value="false" <%=(carregaconfig && !jbean.isRomaneioAutorizacaoPadrao() ? "checked" : "")%>>
                                                Não Autorizado
                                            </label>                                                    
                                        </div>
                                    </td>
                                </tr>
                                <tr>   
                                    <td colspan="2" class="Celulazebra2">
                                        <div align="center">
                                            <label>                                         
                                               Ao adicionar um CTe/Coleta que já está em outro romaneio em aberto o sistema deverá:                                                  
                                            </label>
                                        </div>
                                    </td>
                                    <td colspan="2" class="Celulazebra2">
                                        <div align="center" id="divRomaneioAutorizacaoPadrao" style="display: ">
                                            <label>
                                                <input type="radio" name="transferirCteRomaneioAtual" id="naoAvisarQueCteJaFoiSelecionado" value="t" <%=(carregaconfig && jbean.getAcaoCteRomaneioExistente().equals("t")? "checked" : "")%>>
                                                Tranferir para o romaneio atual                                               
                                            </label>
                                            <label>
                                                <input type="radio" name="transferirCteRomaneioAtual" id="avisarQueCteJaFoiSelecionado" value="a" <%=(carregaconfig && jbean.getAcaoCteRomaneioExistente().equals("a") ? "checked" : "")%>>
                                                Não transferir para o romaneio atual e Informar ao usuário que já foi selecionado em outro romaneio.
                                            </label>                                                    
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20" colspan="4" class="tabela">
                                        <div align="center">
                                            Configurações para Lançamentos de Or&ccedil;amentos
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20" colspan="4" class="CelulaZebra2"> 
                                        <div align="center">
                                            Quantidade de dias para a Validade da Proposta:
                                            <input name="validadeProposta" type="text" id="validadeProposta" class="inputtexto" size="4" value="<%=(carregaconfig ? jbean.getValidadeProposta() : jbean.getValidadeProposta())%>">
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20" colspan="4" class="CelulaZebra2"> 
                                        <div align="center">
                                            Filial Padrão para Lançamento de Orçamento no Módulo GwCli:                      
                                 
                                        <select name="filialOrcamentoGwCli" class="inputtexto" id="filialOrcamentoGwCli" style="font-size:8pt;">
                                            <%      //Carregando todas as filiais cadastradas                                               
                                                BeanConsultaFilial filial = new BeanConsultaFilial();
                                                filial.setConexao(Apoio.getUsuario(request).getConexao());
                                                Collection<BeanFilial> filiais = filial.mostrarTodosOrcamentosGwCli();
                                            %>
                                            <%for(BeanFilial fi : filiais) {%>
                                                <option value="<%=fi.getIdfilial() %>" <%= (carregaconfig ? (fi.getIdfilial() == jbean.getFilialOrcamentoGwCli().getIdfilial()? "selected": "" ): ""  )%> > <%= fi.getAbreviatura()%></option>
                                            <%}%>
                                        </select>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20" colspan="4" class="tabela">
                                        <div align="center">
                                            Configurações para apólice de veículos
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20" colspan="4" class="CelulaZebra2"> 
                                        <div align="center">
                                            <input type="checkbox" name="validaApoliceVeiculo" id="validaApoliceVeiculo" value="true" <%=(carregaconfig && jbean.isValidaApoliceVeiculo() ? "checked" : "")%>>
                                            Vincular veículo a contrato com apólice
                                        </div>
                                    </td>
                                </tr>  
                                <tr >
                                    <td height="20" colspan="4" class="tabela">
                                        <div align="center">
                                            Configurações para Importação de EDI
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20" colspan="2" class="CelulaZebra2"> 
                                        <div align="center">
                                            <label>
                                                <input type="checkbox" name="atualizarClienteImportacaoEdi" id="atualizarClienteImportacaoEdi" value="true" <%=(carregaconfig && jbean.isAtualizarClienteImportacaoEdi() ? "checked" : "")%>>
                                                Atualizar o cadastro do cliente ao importar EDI/XML/DANFE, caso o cliente já esteja cadastrado.                                                
                                            </label>
                                        </div>                                           
                                    </td>
                                    <td class="TextoCampos">                                         
                                        <label>                                                
                                            Ao Importar XML/DANFE trazer por default o layout:
                                        </label>                                        
                                    </td>
                                    <td class="CelulaZebra2"> 
                                        <select id="layoutImportacaoXmlDanfe" name="layoutImportacaoXmlDanfe" class="inputtexto">
                                            <option value="x" <%=(carregaconfig && jbean.getLayoutImportacaoXmlDanfe().equals("x") ? "selected" : "")%>>XML</option>
                                            <option value="c" <%=(carregaconfig && jbean.getLayoutImportacaoXmlDanfe().equals("c") ? "selected" : "")%>>Chave de Acesso</option>
                                        </select>
                                    </td>
                                </tr>
                                <tr >
                                    <td height="20" colspan="4" class="tabela">
                                        <div align="center">
                                            Configuração gwMobile
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20" colspan="2" class="CelulaZebra2"> 
                                        <div align="right">
                                            <label>
                                                Ao incluir um manifesto o campo ponto de controle deverá vir:
                                            </label>
                                        </div>
                                    </td>
                                    <td class="TextoCamposNoAlign" colspan="2" align="left">
                                        <label>
                                            <input type="radio" name="manifestoPontoControle" id="manifestoPontoControle" value="ativado" <%= carregaconfig ? (jbean.isIsManifestoPontoControle()? " checked " : "" ) : "" %>> Ativado
                                        </label>
                                        <label>
                                            <input type="radio" name="manifestoPontoControle" id="manifestoPontoControle" value="desativado" <%= carregaconfig ? (jbean.isIsManifestoPontoControle() ? "" : " checked ") : " checked " %>> Desativado
                                        </label>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20" colspan="2" class="CelulaZebra2"> 
                                        <div align="right">
                                            <label>
                                                Ao incluir um romaneio o campo ponto de controle deverá vir:
                                            </label>
                                        </div>
                                    </td>
                                    <td class="TextoCamposNoAlign" colspan="2" align="left">
                                        <label>
                                            <input type="radio" name="romaneioPontoControle" id="romaneioPontoControle" value="ativado" <%= carregaconfig ? (jbean.isIsRomaneioPontoControle() ? " checked " : "" ) : "" %>> Ativado
                                        </label>
                                        <label>
                                            <input type="radio" name="romaneioPontoControle" id="romaneioPontoControle" value="desativado" <%= carregaconfig ? (jbean.isIsRomaneioPontoControle() ? "" : " checked ") : " checked " %>> Desativado
                                        </label>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20" colspan="4" class="CelulaZebra2"> 
                                        <div align="center">
                                            <label>
                                                <input type="checkbox" name="baixarComprovanteGwMobile" id="baixarComprovanteGwMobile" <%= (carregaconfig ? (jbean.isIsBaixarComprovanteGwMobile() ? "checked='true'" : "") : "") %>> Ao baixar uma entrega com anexo o sistema deverá baixar o comprovante de entrega automaticamente.
                                            </label>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20" colspan="4" class="CelulaZebra2"> 
                                        <div align="center">
                                            <label>
                                                <input type="checkbox" name="ignorarDadosBaixadosMobile" id="ignorarDadosBaixadosMobile" <%= (carregaconfig ? (jbean.isIsIgnorarDadosMobileBaixados()? "checked='true'" : "") : "") %>> Ignorar dados do GW Mobile se o romaneio já estiver baixado
                                            </label>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="20" colspan="2" class="CelulaZebra2">
                                        <div align="right">
                                            <label>
                                                Fornecedor Padrão para lançamentos de despesas no ADV:
                                            </label>
                                        </div>
                                    </td>
                                    <td class="TextoCamposNoAlign" colspan="2" align="left">
                                        <input type="hidden" name="idfornecedor_adv" id="idfornecedor_adv" value="<%=(carregaconfig ? jbean.getFornecedorPadraoAdvMobile().getIdfornecedor() : 0)%>">
                                        <input name="fornecedor_adv" type="text" id="fornecedor_adv" class="inputReadOnly" value="<%=(carregaconfig && jbean.getFornecedorPadraoAdvMobile().getRazaosocial() != null ? jbean.getFornecedorPadraoAdvMobile().getRazaosocial() : "")%>" size="50" maxlength="25" readonly="readonly">
                                        <input type="button" class="botoes" value="..." onClick="localizaFornecedorPadraoAdvMobile();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Fornecedor" onClick="limparFornecedorPadraoAdvMobile()">
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </div>
                    <div class="panel" id="tab5">
                        <fieldset>
                            <table width="100%" border="0" class="bordaFina" align="center">
                                <tr class="tabela">
                                    <td colspan="4">
                                        <div align="center">Cadastro de Clientes</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table class="bordaFina" width="100%">
                                            <tr>
                                                <td colspan="4">
                                                    <table width="100%" border="0" >
                                                        <tr>
                                                            <td width="25%" class="TextoCampos">Campos Obrigat&oacute;rios:</td>
                                                            <td width="17%" class="CelulaZebra2"><input type="checkbox" name="clienteFantasiaObrigatorio" id="clienteFantasiaObrigatorio" value="true" <%=(carregaconfig && jbean.isClienteFantasiaObrigatorio() ? "checked" : "")%>> Nome Fantasia</td>
                                                            <td width="20%" class="CelulaZebra2"><input type="checkbox" name="clienteCepObrigatorio" id="clienteCepObrigatorio" value="true" <%=(carregaconfig && jbean.isClienteCepObrigatorio() ? "checked" : "")%>> CEP</td>
                                                            <td width="13%" class="CelulaZebra2"><input type="checkbox" name="clienteEnderecoObrigatorio" id="clienteEnderecoObrigatorio" value="true" <%=(carregaconfig && jbean.isClienteEnderecoObrigatorio() ? "checked" : "")%>> Endereço</td>
                                                            <td width="13%" class="CelulaZebra2"><input type="checkbox" name="clienteFoneObrigatorio" id="clienteFoneObrigatorio" value="true" <%=(carregaconfig && jbean.isClienteFoneObrigatorio() ? "checked" : "")%>> Fone</td>
                                                            <td width="13%" class="CelulaZebra2"></td>
                                                        </tr>
                                                        <tr>
                                                            <td width="25%" class="TextoCampos">Campos Obrigat&oacute;rios Para Clientes Diretos:</td>
                                                            <td width="13%" class="CelulaZebra2"><input type="checkbox" name="clienteCepCobrancaObrigatorio" id="clienteCepCobrancaObrigatorio" value="true" <%=(carregaconfig && jbean.isClienteCepCobrancaObrigatorio() ? "checked" : "")%>> CEP Cobrança</td>
                                                            <td width="13%" class="CelulaZebra2"><input type="checkbox" name="clienteEnderecoCobrancaObrigatorio" id="clienteEnderecoCobrancaObrigatorio" value="true" <%=(carregaconfig && jbean.isClienteEnderecoCobrancaObrigatorio() ? "checked" : "")%>> Endereço Cobrança</td>
                                                            <td width="13%" class="CelulaZebra2"><input type="checkbox" name="clienteVendedorObrigatorio" id="clienteVendedorObrigatorio" value="true" <%=(carregaconfig && jbean.isClienteVendedorObrigatorio() ? "checked" : "")%>> Vendedor</td>
                                                            <td width="12%" class="CelulaZebra2"><input type="checkbox" name="clienteVendedor2Obrigatorio" id="clienteVendedor2Obrigatorio" value="true" <%=(carregaconfig && jbean.isClienteVendedor2Obrigatorio() ? "checked" : "")%>> Supervisor</td>
                                                            <td width="13%" class="CelulaZebra2"><input type="checkbox" name="clientePlanoDeContas" id="clientePlanoDeContas" value="true" <%=(carregaconfig && jbean.isCliente_plano_de_contas() ? "checked" : "")%>> Plano de Contas</td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="4">
                                                    <table width="100%" border="0">
                                                        <tr>
                                                            <td width="15%" class="CelulaZebra2"><div align="center"><input type="checkbox" name="clienteValidaCnpj" id="clienteValidaCnpj" value="true" <%=(carregaconfig && jbean.isClienteValidaCnpj() ? "checked" : "")%>> Validar CPF/CNPJ</div></td>
                                                            <td width="25%" class="CelulaZebra2"><div align="center" style="display:none;"><input type="checkbox" name="clienteDuplicaCnpj" id="clienteDuplicaCnpj" value="true" <%=(carregaconfig && jbean.isClienteDuplicaCnpj() ? "checked" : "")%>> Aceitar duplicação CNPJ (Em caso de construtoras)</div></td>
                                                            <td width="15%" class="CelulaZebra2"><div align="center"><input type="checkbox" name="clienteValidaIe" id="clienteValidaIe" value="true" <%=(carregaconfig && jbean.isClienteValidaIe() ? "checked" : "")%>>Validar Inscrição Estadual</div></td>
                                                            <td width="45%" class="CelulaZebra2"><div align="center"><input type="checkbox" name="isClienteInscricaoIsentoImportacao" id="isClienteInscricaoIsentoImportacao" value="true" <%=(carregaconfig && jbean.isClienteInscricaoIsentoImportacao()? "checked" : "")%>>Ao importar EDI/XML, se a inscrição estadual não vier preenchida no arquivo, o cliente deverá ser salvo com a palavra ISENTO</div></td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td width="15%" class="CelulaZebra2">
                                                    <div align="center">
                                                        <input type="checkbox" name="isEmailDeContato" id="isEmailDeContato" value="true" <%=(carregaconfig && jbean.isEmailDeContato()? "checked" : "")%>>
                                                            E-mail de Contato
                                                    </div>
                                                </td>
                                                <td width="50%" class="TextoCampos">Ao incluir o campo "Considerar como origem do frete no CT-e" deverá ser:</td>
                                                <td width="35%" class="CelulaZebra2">
                                                    <div>
                                                        <select name="origemFrete" id="origemFrete" class="inputtexto">
                                                            <option value="r" <%=(carregaconfig && jbean.getOrigemFrete().equals("r") ? "selected" : "")%>>A cidade do remetente</option>
                                                            <option value="f" <%=(carregaconfig && jbean.getOrigemFrete().equals("f") ? "selected" : "")%>>A cidade da filial</option>
                                                        </select>
                                                    </div>
                                                </td>
                                            </tr>
                                            
<!--                                            <tr>
                                                <td class="CelulaZebra2" colspan="4">
                                                    <div align="center">
                                                        <label>
                                                            <input type="checkbox" name="retirarLetrasLogradouro" id="retirarLetrasLogradouro" value="true" <%=(carregaconfig && jbean.isIsRetirarLetrasLogradouro()? "checked" : "")%>>
                                                            Ao importar XML/EDI retirar letras do campo número do logradouro.
                                                        </label>
                                                    </div>  
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" colspan="4">
                                                    <div align="center">
                                                        <label>
                                                            <input type="checkbox" name="preencheZeroLogradouro" id="preencheZeroLogradouro"  value="true" <%=(carregaconfig && jbean.isPreencheZeroLogradouro()? "checked" : "")%>>
                                                            Ao importar XML/EDI preencher com zero se no campo número do logradouro tiver caracteres não numéricos.
                                                        </label>
                                                    </div>
                                                </td>
                                            </tr>-->
                                            <tr>
                                                <td class="CelulaZebra2" colspan="4">
                                                    <div align="left">
                                                        <label><b>Caso o numero do logradouro contenha letras : </b></label>
                                                            <span>
                                                            <input type="radio" class="radio" id="validarNumeroLogradouro" name="validarNumeroLogradouro" value="remover" <%=(carregaconfig && jbean.isIsRetirarLetrasLogradouro()? "checked" : "")%>>
                                                            </span>
                                                            <label> Remover as letras </label>
                                                            <span>
                                                            <input type="radio" class="radio" name="validarNumeroLogradouro" id="validarNumeroLogradouro" value="zerar"  <%=(carregaconfig && jbean.isPreencheZeroLogradouro()?  "checked" : "")%>>
                                                            </span>
                                                            <label> Preencher com '0' </label>
                                                            <span>
                                                            <input type="radio" class="radio" id="validarNumeroLogradouro" name="validarNumeroLogradouro" value="manter" <%=(carregaconfig && jbean.isIsRetirarLetrasLogradouro() == false && jbean.isPreencheZeroLogradouro() == false ? "checked" : "")%>>
                                                            </span>
                                                            <label> Manter o numero do logradouro</label>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" colspan="4">
                                                    <div align="left">
                                                        <label><b>Forma de arredondamento do peso no cálculo da tabela de preço : </b></label>
                                                            <span>
                                                                <input type="radio" class="radio" name="tipoArredondamentoPeso" id="tipoArredondamentoPeso" value="n"  <%=(carregaconfig && (!jbean.getTipoArredondamentoPeso().equalsIgnoreCase("a") && !jbean.getTipoArredondamentoPeso().equalsIgnoreCase("c")) ? "checked" : "")%>>
                                                            </span>
                                                            <label> Não arredondar </label>
                                                            <span>
                                                            <span>
                                                                <input type="radio" class="radio" id="tipoArredondamentoPeso" name="tipoArredondamentoPeso" value="a" <%=(carregaconfig && jbean.getTipoArredondamentoPeso().equalsIgnoreCase("a")? "checked" : "")%>>
                                                            </span>
                                                            <label> Arredondamento padrão </label>
                                                            <input type="radio" class="radio" id="tipoArredondamentoPeso" name="tipoArredondamentoPeso" value="c" <%=(carregaconfig && jbean.getTipoArredondamentoPeso().equalsIgnoreCase("c") ? "checked" : "")%>>
                                                            </span>
                                                            <label>Sempre arredondar para cima</label>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" colspan="4">
                                                    <input type="checkbox" id="chkEnviarEmailLembreteVencimentoBoleto"
                                                           name="chkEnviarEmailLembreteVencimentoBoleto"
                                                           ${config.enviarEmailLembreteVencimentoFatura ? "checked" : ""}>
                                                    <label for="chkEnviarEmailLembreteVencimentoBoleto">
                                                        Enviar e-mail de lembrete de vencimento da fatura/boleto com
                                                    </label>
                                                    <input type="text" class="inputtexto" size="4" maxlength="3"
                                                           id="inpDiasEnviarEmailLembreteVencimentoBoleto"
                                                           name="inpDiasEnviarEmailLembreteVencimentoBoleto"
                                                           onblur="seNaoIntReset(this, 3)"
                                                           value="${config.qtdDiasVencimentoLembreteFatura}">
                                                    <label for="inpDiasEnviarEmailLembreteVencimentoBoleto">
                                                        dias antes do vencimento
                                                    </label>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr class="tabela">
                                    <td colspan="4"><div align="center">Cadastro de Motorista</div></td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table class="bordaFina" width="100%">
                                            <tr>
                                                <td width="15%" rowspan="2" class="TextoCampos">Campos Obrigat&oacute;rios:</td>
                                                <td class="CelulaZebra2"><input type="checkbox" name="motoristaDataEmissaoCNHObrigatorio" id="motoristaDataEmissaoCNHObrigatorio" value="true" <%=(carregaconfig && jbean.isMotoristaDataEmissaoCNHObrigatorio() ? "checked" : "")%>> Data de Emissão da CNH</td>
                                                <td class="CelulaZebra2"><input type="checkbox" name="motoristaEnderecoObrigatorio" id="motoristaEnderecoObrigatorio" value="true" <%=(carregaconfig && jbean.isMotoristaEnderecoObrigatorio() ? "checked" : "")%>> Endereço</td>
                                                <td class="CelulaZebra2"><input type="checkbox" name="motoristaRGOrgaoObrigatorio" id="motoristaRGOrgaoObrigatorio" value="true" <%=(carregaconfig && jbean.isMotoristaRGOrgaoObrigatorio() ? "checked" : "")%>> RG/Orgão</td>
                                                <td class="CelulaZebra2"><input type="checkbox" name="motoristaDataEmissaoRGObrigatorio" id="motoristaDataEmissaoRGObrigatorio" value="true" <%=(carregaconfig && jbean.isMotoristaDataEmissaoRGObrigatorio() ? "checked" : "")%>> Data de Emissão do RG</td>
                                                <td class="CelulaZebra2"><input type="checkbox" name="motoristaCNHObrigatorio" id="motoristaCNHObrigatorio" value="true" <%=(carregaconfig && jbean.isMotoristaCNHObrigatorio() ? "checked" : "")%>> CNH</td>
                                                <td colspan="2" class="CelulaZebra2"><input type="checkbox" name="motoristaLocalEmissaoCNH" id="motoristaLocalEmissaoCNH" value="true" <%=(carregaconfig && jbean.isMotoristaLocalEmissaoCNH() ? "checked" : "")%>> Local de Emissão da CNH</td>

                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2"><input type="checkbox" name="motoristaCodSegCNHObrigatorio" id="motoristaCodSegCNHObrigatorio" value="true" <%=(carregaconfig && jbean.isCodSegurancaCNH()? "checked" : "")%>> Código de segurança da CNH</td>
                                                <td class="CelulaZebra2"><input type="checkbox" name="motoristaDataVencimentoCNHObrigatorio" id="motoristaDataVencimentoCNHObrigatorio" value="true" <%=(carregaconfig && jbean.isMotoristaDataVencimentoCNHObrigatorio() ? "checked" : "")%>> Data de Vencimento da CNH</td>
                                                <td class="CelulaZebra2"><input type="checkbox" name="motoristaVeiculoObrigatorio" id="motoristaVeiculoObrigatorio" value="true" <%=(carregaconfig && jbean.isMotoristaVeiculoObrigatorio() ? "checked" : "")%>> Veículo</td>

                                                <td class="CelulaZebra2"><input type="checkbox" name="motoristaPisPasepObrigatorio" id="motoristaPisPasepObrigatorio" value="true" <%=(carregaconfig && jbean.isMotoristaPisPasepObrigatorio() ? "checked" : "")%>> PIS/PASEP(Apenas os Funcionários)</td>
                                                <td class="CelulaZebra2"><input type="checkbox" name="motoristaTelefoneObrigatorio" id="motoristaTelefoneObrigatorio" value="true" <%=(carregaconfig && jbean.isMotoristaTelefoneObrigatorio() ? "checked" : "")%>>Telefone 1</td>
                                                <td class="CelulaZebra2"><input type="checkbox" name="motoristaTelefoneObrigatorio2" id="motoristaTelefoneObrigatorio2" value="true" <%=(carregaconfig && jbean.isMotoristaTelefoneObrigatorio2() ? "checked" : "")%>>Telefone 2</td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos" colspan="2">Percentual Padr&atilde;o para Adiantamento no Contrato de Frete.</td>
                                                <td class="CelulaZebra2" colspan="5">
                                                    <input name="percentualAdiantamento" class="inputtexto" type="text" id="percentualAdiantamento"
                                                           onBlur="javascript:seNaoFloatReset(this, '0.00');"
                                                           value="<%=(carregaconfig ? vlrformat.format(jbean.getPercentualAdiantamentoContratoFrete()) : "0.00")%>" size="5" align="right" >
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr class="tabela">
                                    <td colspan="4"><div align="center">Cadastro de Propriet&aacute;rio</div></td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table class="bordaFina" width="100%">
                                            <tr>
                                                <td width="12%" class="TextoCampos">Campos Obrigat&oacute;rios:</td>
                                                <td width="15%" class="CelulaZebra2"><input type="checkbox" name="proprietarioDataNascimentoObrigatorio" id="proprietarioDataNascimentoObrigatorio" value="true" <%=(carregaconfig && jbean.isProprietarioDataNascimentoObrigatorio() ? "checked" : "")%>> Data de Nascimento</td>
                                                <td width="15%" class="CelulaZebra2"><input type="checkbox" name="proprietarioEnderecoObrigatorio" id="proprietarioEnderecoObrigatorio" value="true" <%=(carregaconfig && jbean.isProprietarioEnderecoObrigatorio() ? "checked" : "")%>> Endereço</td>
                                                <td width="12%" class="CelulaZebra2"><input type="checkbox" name="proprietarioRgOrgaoObrigatorio" id="proprietarioRgOrgaoObrigatorio" value="true" <%=(carregaconfig && jbean.isProprietarioRgOrgaoObrigatorio() ? "checked" : "")%>> RG/Orgão</td>
                                                <td width="11%" class="CelulaZebra2"><input type="checkbox" name="proprietarioTelefoneObrigatorio" id="proprietarioTelefoneObrigatorio" value="true" <%=(carregaconfig && jbean.isProprietarioTelefoneObrigatorio() ? "checked" : "")%>> Telefone</td>
                                                <td width="11%" class="CelulaZebra2"><input type="checkbox" name="chkRntrc" id="chkRntrc" value="true" <%=(carregaconfig && jbean.isRntrc() ? "checked" : "")%>> Nº RNTRC</td>
                                                <td width="10%" class="CelulaZebra2"><input type="checkbox" name="proprietarioPisPasepObrigatorio" id="proprietarioPisPasepObrigatorio" value="true" <%=(carregaconfig && jbean.isProprietarioPisPasepObrigatorio() ? "checked" : "")%>> PIS/PASEP</td>
                                                <td width="14%" class="CelulaZebra2"><input type="checkbox" name="proprietarioValidaPis" id="proprietarioValidaPis" value="true" <%=(carregaconfig && jbean.isProprietarioValidaPis() ? "checked" : "")%>> Validar PIS/PASEP</td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos" colspan="2">% Padrão de desconto de conta corrente:</td>
                                                <td class="CelulaZebra2" colspan="1">
                                                    <input name="percentualPadraoContaCorrente" type="text"
                                                           id="percentualPadraoContaCorrente" class="inputtexto"
                                                           onBlur="seNaoFloatReset(this, '0.00');" size="7" align="right"
                                                           value="<%=(carregaconfig ? vlrformat.format(jbean.getPercentualPadraoDescontoContaCorrente()) : "0.00")%>">
                                                </td>
                                                <td colspan="5" class="CelulaZebra2">
                                                    <select class="inputtexto" id="tipoDescontoContaCorrente"
                                                            name="tipoDescontoContaCorrente">
                                                        <option value="1" <%=(jbean.getTipoDescontoContaCorrente() == 1 ? "selected" : "")%>>
                                                            Sobre o saldo do frete
                                                        </option>
                                                        <option value="2" <%=(jbean.getTipoDescontoContaCorrente() == 2 ? "selected" : "")%>>
                                                            Sobre o valor do frete
                                                        </option>
                                                    </select>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>

                                <tr class="tabela">
                                    <td colspan="4"><div align="center">Cadastro de Fornecedor</div></td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table class="bordaFina" width="100%">
                                            <tr>
                                                <td width="15%" rowspan="2" class="TextoCampos">Campos Obrigat&oacute;rios:</td>
                                                <td width="20%" class="CelulaZebra2"><input type="checkbox" name="fornecedorNomeFantasia" id="fornecedorNomeFantasia" value="true" <%=(carregaconfig && jbean.isNome_fantasia_fornecedor_obrigatorio() ? "checked" : "")%>> Nome Fantasia</td>
                                                <td width="20%" class="CelulaZebra2"><input type="checkbox" name="fornecedorCEP" id="fornecedorCEP" value="true" <%=(carregaconfig && jbean.isCep_fornecedor_obrigatorio() ? "checked" : "")%>> CEP</td>
                                                <td width="20%" class="CelulaZebra2"><input type="checkbox" name="fornecedorEndereco" id="fornecedorEndereco" value="true" <%=(carregaconfig && jbean.isEndereco_fornecedor_obrigatorio() ? "checked" : "")%>> Endereço</td>
                                                <td width="10%" class="CelulaZebra2"><input type="checkbox" name="fornecedorIE" id="fornecedorIE" value="true" <%=(carregaconfig && jbean.isIe_fornecedor_obrigatorio() ? "checked" : "")%>> I.E.</td>
                                                <td width="15%" class="CelulaZebra2"><input type="checkbox" name="fornecedorContaContabil" id="fornecedorContaContabil" value="true" <%=(carregaconfig && jbean.isConta_contabil_fornecedor_obrigatorio() ? "checked" : "")%>> Conta Contábil</td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>

                                <tr class="tabela">
                                    <td colspan="4">
                                        <div align="center">Lan&ccedil;amento de Conhecimentos de Transportes (CT-e)</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table width="100%" border="0" class="bordaFina">
                                            <tr class="CelulaZebra2">
                                                <td style="vertical-align: top" width="30%" class="CelulaZebra2">
                                                    <table id="tbCtrcInclusoes" width="100%"  class="tabelaZerada">
                                                        <tr>
                                                            <td class="Celulazebra2">
                                                                <input type="checkbox" name="importarCtrcNotaMercadoria" id="importarCtrcNotaMercadoria" value="true" <%=(carregaconfig && jbean.isImportarCtrcNotaMercadoria() ? "checked" : "")%>>
                                                            </td>
                                                            <td class="Celulazebra2">
                                                                Cadastrar Mercadoria ao Importar um CT-e
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="Celulazebra2">
                                                                <input type="checkbox" name="importarCtrcNotaItem" id="importarCtrcNotaItem" value="true" <%=(carregaconfig && jbean.isImportarCtrcNotaItem() ? "checked" : "")%>>
                                                            </td>
                                                            <td class="Celulazebra2">
                                                                Importar os Itens da Nota ao Importar um CT-e em Lote
                                                            </td>
                                                        </tr>
                                                        
                                                    </table>
                                                </td>
                                                <td style="vertical-align: top" width="40%" class="CelulaZebra2">
                                                    <table id="tbCtrcObrigacoes"  width="100%" class="tabelaZerada">
                                                        <tr>
                                                            <td class="Celulazebra2" >
                                                                <input type="checkbox" name="obrigaNotaFiscalCtrc" id="obrigaNotaFiscalCtrc" value="true" <%=(carregaconfig && jbean.isObrigaNotaFiscalCtrc() ? "checked" : "")%>>
                                                            </td>
                                                            <td class="Celulazebra2" >
                                                                Obrigar a Inclus&atilde;o de, no M&iacute;nimo, uma Nota Fiscal ao Incluir o CT-e
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="Celulazebra2">
                                                                <input type="checkbox" name="obrigaAgenteCargaCtrc" id="obrigaAgenteCargaCtrc" value="true" <%=(carregaconfig && jbean.isObrigaAgenteCargaCTRC() ? "checked" : "")%>>
                                                            </td>
                                                            <td class="Celulazebra2">
                                                                Obrigar a Inclus&atilde;o do Agente de Carga ao Incluir o CT-e com Contrato de Frete
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="Celulazebra2" >
                                                                <input type="checkbox" name="obrigaMotoristaCtrc" id="obrigaMotoristaCtrc" value="true" <%=(carregaconfig && jbean.isObrigaMotoristaCTRC() ? "checked" : "")%>>
                                                            </td>
                                                            <td class="Celulazebra2" >
                                                                Obrigar a Inclus&atilde;o do Motorista ao Incluir o CT-e
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="Celulazebra2" >
                                                                <input type="checkbox" name="obrigaVeiculoCtrc" id="obrigaVeiculoCtrc" value="true" <%=(carregaconfig && jbean.isObrigaVeiculoCTRC() ? "checked" : "")%>>
                                                            </td>
                                                            <td class="Celulazebra2" >
                                                                Obrigar a Inclus&atilde;o do Ve&iacute;culo ao Incluir o CT-e
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="Celulazebra2" >
                                                                <input type="checkbox" name="obrigaRotaCtrc" id="obrigaRotaCtrc" value="true" <%=(carregaconfig && jbean.isObrigaRotaCTRC() ? "checked" : "")%>>
                                                            </td>
                                                            <td class="Celulazebra2" >
                                                                Obrigar a Inclus&atilde;o da Rota ao Incluir o CT-e
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="Celulazebra2" >
                                                                <input type="checkbox" name="obrigaColetaCtrc" id="obrigaColetaCtrc" value="true" <%=(carregaconfig && jbean.isObrigaColetaCTRC() ? "checked" : "")%> />
                                                            </td>
                                                            <td class="Celulazebra2" >
                                                                Obrigar a Inclusão de uma Coleta ao Incluir o CT-e
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="CelulaZebra2" >
                                                                <input type="checkbox" name="aceitarServicoCtNfs" id="aceitarServicoCtNfs" value="true" <%=(carregaconfig && jbean.isAceitarServicoCtNfs() ? "checked" : "")%> />
                                                            </td>
                                                            <td class="CelulaZebra2" >
                                                                Aceitar o CNPJ do Tomador do Serviço Igual ao da Filial Emissora do CT-e/NFS-e
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                                <td style="vertical-align: top" width="30%" class="CelulaZebra2">
                                                    <table id="tbCtrcValidacoes"  width="100%" class="tabelaZerada">
                                                        <tr>
                                                            <td class="Celulazebra2">
                                                                <input type="checkbox" name="validarContainer" id="validarContainer" value="true" <%=(carregaconfig && jbean.isValidarContainer() ? "checked" : "")%>>
                                                            </td>
                                                            <td class="Celulazebra2">
                                                                Validar Container
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="Celulazebra2">
                                                                <input type="checkbox" name="validarGenset" id="validarGenset" value="true" <%=(carregaconfig && jbean.isValidarGenset() ? "checked" : "")%>>
                                                            </td>
                                                            <td class="Celulazebra2">
                                                                Validar GENSET
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="Celulazebra2">
                                                                <input type="checkbox" name="consigClienteDireto" id="consigClienteDireto" value="true" <%=(carregaconfig && jbean.isConsignatarioClienteDireto() ? "checked" : "")%>>
                                                            </td>
                                                            <td class="Celulazebra2">
                                                                Permitir Apenas Cliente Direto como Consignatario
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="Celulazebra2" colspan="2">
                                                                <label>(</label>
                                                                <span>
                                                                    <input type="radio" name="validacaoCteXmlOutrosDestinatarios" id="validacaoCteXmlOutrosDestinatariosA" value="a" <%=(carregaconfig && jbean.getValidacaoCteXmlOutrosDestinatarios().equals("a") ? "checked" : "")%> >
                                                                    <label>Avisar</label>
                                                                </span>
                                                                <span>
                                                                    <input type="radio" name="validacaoCteXmlOutrosDestinatarios" id="validacaoCteXmlOutrosDestinatariosB" value="b" <%=(carregaconfig && jbean.getValidacaoCteXmlOutrosDestinatarios().equals("b") ? "checked" : "")%> >
                                                                    <label>Bloquear</label>
                                                                </span>
                                                                <label>)</label>
                                                                Quando adicionar notas de clientes diferentes no Lançamento de CT-e
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr class="tabela">
                                    <td colspan="4">
                                        <div align="center">Lan&ccedil;amento de Faturas e Boletos</div>
                                    </td>
                                </tr>
                                <td colspan="3">
                                <table id="tbCteFaturas" width="100%"  class="tabelaZerada">
                                    <tr>
                                        <td class="Celulazebra2">
                                            <div align ="center">
                                                <label>
                                                    <input type="checkbox" name="utilizarNumeroCteFatura" id="utilizarNumeroCteFatura" value="true" <%=(carregaconfig && jbean.isUtilizarNumeroCteFatura()? "checked" : "")%>>                                   
                                                    Utilizar Número de CT-e no Número da Fatura
                                                </label>
                                            </div>
                                        </td>
                                        <td class="Celulazebra2">
                                            <div align ="center">
                                                <label>
                                                    <input type="checkbox" name="enviarEmailAutomaticoFatura" id="enviarEmailAutomaticoFatura" value="true" <%=(carregaconfig && jbean.isEnviarEmailAutomaticoFatura() ? "checked" : "")%> />                                   
                                                    Enviar e-mail automaticamente ao incluir a fatura
                                                </label>
                                            </div>
                                        </td>
                                        <td class="Celulazebra2">
                                            <div align ="center">
                                                <label>
                                                    <input type="checkbox" name="incluirFaturasCTeConfirmados" id="incluirFaturasCTeConfirmados" value="true" <%=(carregaconfig && jbean.isIncluirFaturasCTeConfirmados() ? "checked" : "")%> />
                                                    Incluir faturas apenas de CT-e(s) confirmados
                                                </label>
                                            </div>
                                        </td>
                                        <td class="Celulazebra2">
                                            <div align ="center">
                                                <label>
                                                    <input type="checkbox" name="baixarFaturaParcialDiferenca" id="baixarFaturaParcialDiferenca" value="true" <%=(carregaconfig && jbean.isBaixarFaturaParcialDiferenca() ? "checked" : "")%> />
                                                    Ao baixar uma fatura parcialmente a diferença deverá fazer parte da fatura original
                                                </label>
                                            </div>
                                        </td>
                                    </tr>                                
                                </table>
                                </td>
                                <tr class="tabela">
                                    <td colspan="4">
                                        <div align="center">Relat&oacute;rios Padr&atilde;o</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table width="100%" border="0" class="bordaFina">
                                            <tr>
                                                <td width="20%" class="CelulaZebra2">
                                                    <div align="right">
                                                        Consultar Coleta:
                                                    </div>
                                                </td>
                                                <td  width="30%" class="CelulaZebra2">
                                                    <select name="cbColeta" id="cbColeta" class="inputtexto">
                                                        <option value="1" <%=(jbean.getRelDefaultColeta().equals("1") ? "selected" : "")%>>Modelo 1 (Coleta)</option>
                                                        <option value="2" <%=(jbean.getRelDefaultColeta().equals("2") ? "selected" : "")%>>Modelo 2 (Coleta)</option>
                                                        <option value="3" <%=(jbean.getRelDefaultColeta().equals("3") ? "selected" : "")%>>Modelo 3 (Coleta)</option>
                                                        <option value="4" <%=(jbean.getRelDefaultColeta().equals("4") ? "selected" : "")%>>Modelo 4 (Coleta)</option>
                                                        <option value="5" <%=(jbean.getRelDefaultColeta().equals("5") ? "selected" : "")%>>Modelo 5 (Coleta)</option>
                                                        <option value="6" <%=(jbean.getRelDefaultColeta().equals("6") ? "selected" : "")%>>Modelo 6 (OS)</option>
                                                        <option value="7" <%=(jbean.getRelDefaultColeta().equals("7") ? "selected" : "")%>>Modelo 7 (Coleta)</option>
                                                        <option value="8" <%=(jbean.getRelDefaultColeta().equals("8") ? "selected" : "")%>>Modelo 8 (Relatório de embarque)</option>
                                                        <option value="9" <%=(jbean.getRelDefaultColeta().equals("9") ? "selected" : "")%>>Modelo 9 (Coleta Container)</option>
                                                        <option value="10" <%=(jbean.getRelDefaultColeta().equals("10") ? "selected" : "")%>>Modelo 10 (Coleta Container)</option>
                                                        <option value="11" <%=(jbean.getRelDefaultColeta().equals("11") ? "selected" : "")%>>Modelo 11 (Coleta Container)</option>
                                                        <option value="12" <%=(jbean.getRelDefaultColeta().equals("12") ? "selected" : "")%>>Modelo 12 (Coleta Container)</option>
                                                        <option value="13" <%=(jbean.getRelDefaultColeta().equals("13") ? "selected" : "")%>>Modelo 13 (Coleta)</option>
                                                        <option value="14" <%=(jbean.getRelDefaultColeta().equals("14") ? "selected" : "")%>>Modelo 14 (Coleta BUNGE)</option>
                                                        <option value="15" <%=(jbean.getRelDefaultColeta().equals("15") ? "selected" : "")%>>Modelo 15 (Coleta)</option>
                                                        <option value="16" <%=(jbean.getRelDefaultColeta().equals("16") ? "selected" : "")%>>Modelo 16 (Paletização)</option>
                                                        <option value="17" <%=(jbean.getRelDefaultColeta().equals("17") ? "selected" : "")%>>Modelo 17 (Declaração das Condições da Carga)</option>
                                                        <option value="18" <%=(jbean.getRelDefaultColeta().equals("18") ? "selected" : "")%>>Modelo 18 (Coleta)</option>
                                                        <option value="19" <%=(jbean.getRelDefaultColeta().equals("19") ? "selected" : "")%>>Modelo 19 (Coleta Aérea)</option>
                                                        <%
                                                            if (jbean.isGeraGEMColeta()) {
                                                        %>
                                                        <option value="md" <%=(jbean.getRelDefaultColeta().equals("md") ? "selected" : "")%>>Mapa de descarga(gwLogis)</option> 
                                                        <option value="cr" <%=(jbean.getRelDefaultColeta().equals("cr") ? "selected" : "")%>>Comprovante de Recebimento(gwLogis)</option>
                                                        <option value="co" <%=(jbean.getRelDefaultColeta().equals("co") ? "selected" : "")%>>Controle de ocorrências(gwLogis)</option>
                                                        <%// carregando os modelos personalizados
                                                            }
                                                            for (String rel : Apoio.listDocColeta(request)) {%>
                                                        <option value="doc_coleta_personalizado_<%=rel%>" <%=(jbean.getRelDefaultColeta().startsWith("doc_coleta_personalizado_" + rel) ? "selected" : "")%> >Modelo <%=rel.toUpperCase()%> (Personalizado)</option>
                                                        <%}%>

                                                    </select>
                                                </td>
                                                <td width="20%" class="CelulaZebra2">
                                                    <div align="right">
                                                        Consultar Manifesto:
                                                    </div>
                                                </td>
                                                <td width="30%" class="CelulaZebra2">
                                                    <select name="cbManifesto" id="cbManifesto" class="inputtexto">
                                                        <option value="1" <%=(jbean.getRelDefaultManifesto().equals("1") ? "selected" : "")%>>Modelo 1 (Rodoviário)</option>
                                                        <option value="2" <%=(jbean.getRelDefaultManifesto().equals("2") ? "selected" : "")%>>Modelo 2 (Rodoviário)</option>
                                                        <option value="3" <%=(jbean.getRelDefaultManifesto().equals("3") ? "selected" : "")%>>Modelo 3 (Rodoviário)</option>
                                                        <option value="4" <%=(jbean.getRelDefaultManifesto().equals("4") ? "selected" : "")%>>Modelo 4 (Rodoviário)</option>
                                                        <option value="5" <%=(jbean.getRelDefaultManifesto().equals("5") ? "selected" : "")%>>Modelo 5 (Rodoviário)</option>
                                                        <option value="6" <%=(jbean.getRelDefaultManifesto().equals("6") ? "selected" : "")%>>Modelo 6 (Rodoviário)</option>
                                                        <option value="7" <%=(jbean.getRelDefaultManifesto().equals("7") ? "selected" : "")%>>Modelo 7 (Marítimo)</option>
                                                        <option value="8" <%=(jbean.getRelDefaultManifesto().equals("8") ? "selected" : "")%>>Modelo 8 (Rodoviário)</option>
                                                        <option value="9" <%=(jbean.getRelDefaultManifesto().equals("9") ? "selected" : "")%>>Modelo 9 (Rodoviário)</option>
                                                        <option value="10" <%=(jbean.getRelDefaultManifesto().equals("10") ? "selected" : "")%>>Modelo 10 (Rodoviário)</option>
                                                        <option value="11" <%=(jbean.getRelDefaultManifesto().equals("11") ? "selected" : "")%>>Modelo 11 (Rodoviário)</option>
                                                        <option value="12" <%=(jbean.getRelDefaultManifesto().equals("12") ? "selected" : "")%>>Modelo 12 (Rodoviário)</option>
                                                        <option value="13" <%=(jbean.getRelDefaultManifesto().equals("13") ? "selected" : "")%>>Modelo 13 (Rodoviário)</option>
                                                        <option value="14" <%=(jbean.getRelDefaultManifesto().equals("14") ? "selected" : "")%>>Modelo 14 (Aéreo)</option>
                                                        <option value="15" <%=(jbean.getRelDefaultManifesto().equals("15") ? "selected" : "")%>>Modelo 15 (Rodoviário/Aéreo)</option>
                                                        <option value="16" <%=(jbean.getRelDefaultManifesto().equals("16") ? "selected" : "")%>>Modelo 16 (Aéreo - Minuta de Despacho)</option>
                                                        <%// Carregando modelo de Manifesto personalizado
                                                            for (String rel : Apoio.listManifesto(request)) {%>
                                                        <option value="doc_manifesto_personalizado_<%=rel%>" <%=(jbean.getRelDefaultManifesto().equals("doc_manifesto_personalizado_" + rel) ? "selected" : "")%> >Modelo <%=rel.toUpperCase()%> (Personalizado)</option>
                                                        <%}%>

                                                    </select>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2">
                                                    <div align="right">
                                                        Consultar Contrato de Frete:
                                                    </div>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <select name="cbCartaFrete" id="cbCartaFrete" class="inputtexto">
                                                        <option value="1" <%=(jbean.getRelDefaultCartaFrete().equals("1") ? "selected" : "")%>>Modelo 1</option>
                                                        <option value="2" <%=(jbean.getRelDefaultCartaFrete().equals("2") ? "selected" : "")%>>Modelo 2</option>
                                                        <option value="3" <%=(jbean.getRelDefaultCartaFrete().equals("3") ? "selected" : "")%>>Modelo 3</option>
                                                        <option value="4" <%=(jbean.getRelDefaultCartaFrete().equals("4") ? "selected" : "")%>>Modelo 4</option>
                                                        <option value="5" <%=(jbean.getRelDefaultCartaFrete().equals("5") ? "selected" : "")%>>Modelo 5 (Saldo)</option>
                                                        <option value="6" <%=(jbean.getRelDefaultCartaFrete().equals("6") ? "selected" : "")%>>Modelo 6</option>
                                                        <option value="7" <%=(jbean.getRelDefaultCartaFrete().equals("7") ? "selected" : "")%>>Modelo 7</option>
                                                        <option value="8" <%=(jbean.getRelDefaultCartaFrete().equals("8") ? "selected" : "")%>>Modelo 8</option>
                                                        <option value="9" <%=(jbean.getRelDefaultCartaFrete().equals("9") ? "selected" : "")%>>Modelo 9 (Coleta)</option>
                                                        <option value="10" <%=(jbean.getRelDefaultCartaFrete().equals("10") ? "selected" : "")%>>Modelo 10 (Pamcard)</option>
                                                        <option value="11" <%=(jbean.getRelDefaultCartaFrete().equals("11") ? "selected" : "")%>>Modelo 11 (NDD Cargo)</option>
                                                        <option value="12" <%=(jbean.getRelDefaultCartaFrete().equals("12") ? "selected" : "")%>>Modelo 12</option>
                                                        <option value="13" <%=(jbean.getRelDefaultCartaFrete().equals("13") ? "selected" : "")%>>Modelo 13</option>
                                                        <option value="14" ${configuracao.relDefaultCartaFrete == ("14")?"selected":""}>Modelo 14 (EFrete)</option>
                                                        <option value="15" ${configuracao.relDefaultCartaFrete == ("15")?"selected":""}>Modelo 15 (TARGET - Web Service)</option>
                                                        <option value="16" ${configuracao.relDefaultCartaFrete == ("16")?"selected":""}>Modelo 16 - Com extrato C/C</option>
                                                        <% for (String rel : Apoio.listCartaFrete(request)) {%>

                                                        <option value="doc_cartafrete_personalizado_<%=rel%>" <%=(jbean.getRelDefaultCartaFrete().startsWith("doc_cartafrete_personalizado_"+rel) ? "selected" : "")%>> Modelo <%= rel.toUpperCase()%> (Personalizado)</option>
                                                        <%}
                                                        %>



                                                    </select>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <div align="right">
                                                        Consultar Fatura:
                                                    </div>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <select name="cbFatura" id="cbFatura" class="inputtexto" >
                                                        <option value="1" <%=(jbean.getRelDefaultFatura().equals("1") ? "selected" : "")%>>Modelo 1</option>
                                                        <option value="2" <%=(jbean.getRelDefaultFatura().equals("2") ? "selected" : "")%>>Modelo 2</option>
                                                        <option value="3" <%=(jbean.getRelDefaultFatura().equals("3") ? "selected" : "")%>>Modelo 3</option>
                                                        <option value="4" <%=(jbean.getRelDefaultFatura().equals("4") ? "selected" : "")%>>Modelo 4</option>
                                                        <option value="5" <%=(jbean.getRelDefaultFatura().equals("5") ? "selected" : "")%>>Modelo 5</option>
                                                        <option value="6" <%=(jbean.getRelDefaultFatura().equals("6") ? "selected" : "")%>>Modelo 6</option>
                                                        <option value="7" <%=(jbean.getRelDefaultFatura().equals("7") ? "selected" : "")%>>Modelo 7</option>
                                                        <option value="8" <%=(jbean.getRelDefaultFatura().equals("8") ? "selected" : "")%>>Modelo 8</option>
                                                        <option value="9" <%=(jbean.getRelDefaultFatura().equals("9") ? "selected" : "")%>>Modelo 9</option>
                                                        <option value="10" <%=(jbean.getRelDefaultFatura().equals("10") ? "selected" : "")%>>Modelo 10</option>
                                                        <option value="11" <%=(jbean.getRelDefaultFatura().equals("11") ? "selected" : "")%>>Modelo 11 (Container)</option>
                                                        <option value="12" <%=(jbean.getRelDefaultFatura().equals("12") ? "selected" : "")%>>Modelo 12</option>
                                                        <option value="13" <%=(jbean.getRelDefaultFatura().equals("13") ? "selected" : "")%>>Modelo 13 (Apenas NFS)</option>
                                                        <% for (String rel : Apoio.listFaturas(request)) {%>

                                                        <option value="doc_fatura_personalizado_<%=rel%>" <%=(jbean.getRelDefaultFatura().startsWith("doc_fatura_personalizado_"+rel) ? "selected" : "")%>> Modelo <%= rel.toUpperCase()%> (Personalizado)</option>
                                                        <%}
                                                        %>
                                                    </select>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2">
                                                    <div align="right">Consultar Motorista:</div>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <select name="cbMotorista" id="cbMotorista" class="inputtexto">
                                                        <option value="2" <%=(jbean.getRelDefaultMotorista().equals("2") ? "selected" : "")%>>Modelo 2</option>
                                                        <option value="3" <%=(jbean.getRelDefaultMotorista().equals("3") ? "selected" : "")%>>Modelo 3</option>
                                                        <option value="4" <%=(jbean.getRelDefaultMotorista().equals("4") ? "selected" : "")%>>Modelo 4</option>
                                                        <option value="5" <%=(jbean.getRelDefaultMotorista().equals("5") ? "selected" : "")%>>Modelo 5</option>
                                                        <%// Carregando modelo de Motorista personalizado
                                                            for (String rel : Apoio.listDocMotorista(request)) {%>
                                                        <option value="doc_motorista_personalizado_<%=rel%>" <%=(jbean.getRelDefaultMotorista().startsWith("doc_motorista_personalizado_"+rel) ? "selected" : "")%> >Modelo <%=rel.toUpperCase()%> (Personalizado)</option>
                                                        <%}%>
                                                    </select>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <div align="right">Boleto:</div>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <select name="cbBoleto" id="cbBoleto" class="inputtexto">
                                                        <option value="1" <%=(jbean.getRelDefaultBoleto().equals("1") ? "selected" : "")%>>Modelo 1</option>
                                                        <option value="2" <%=(jbean.getRelDefaultBoleto().equals("2") ? "selected" : "")%>>Modelo 2</option>
                                                        <option value="3" <%=(jbean.getRelDefaultBoleto().equals("3") ? "selected" : "")%>>Modelo 3</option>
                                                        <option value="4" <%=(jbean.getRelDefaultBoleto().equals("4") ? "selected" : "")%>>Modelo 4</option>
                                                        <option value="5" <%=(jbean.getRelDefaultBoleto().equals("5") ? "selected" : "")%>>Modelo 5</option>
                                                        <option value="6" <%=(jbean.getRelDefaultBoleto().equals("6") ? "selected" : "")%>>Modelo 6</option>
                                                        <option value="7" <%=(jbean.getRelDefaultBoleto().equals("7") ? "selected" : "")%>>Modelo 7</option>
                                                        <option value="8" <%=(jbean.getRelDefaultBoleto().equals("8") ? "selected" : "")%>>Modelo 8</option>
                                                        <option value="9" <%=jbean.getRelDefaultBoleto().equals("9") ? "selected" : ""%>>Modelo 9</option>
                                                        <option value="10" <%=jbean.getRelDefaultBoleto().equals("10") ? "selected" : ""%>>Modelo 10</option>
                                                        <option value="11" <%=jbean.getRelDefaultBoleto().equals("11") ? "selected" : ""%>>Modelo 11</option>
                                                        // Carregando o modelo de Boleto personalizado
                                                        <% for (String rel : Apoio.listBoleto(request)) {%>
                                                        <option value="boleto_personalizado_" <%=(jbean.getRelDefaultBoleto().startsWith("boleto_personalizado_") ? "selected" : "")%>> Modelo <%= rel.toUpperCase()%> (Personalizado)</option>

                                                        <%}%>

                                                    </select>
                                                </td>
                                                <tr class="Celulazebra2">
                                                <td >
                                                    <div align="right">Consultar Conhecimento:</div>
                                                </td> 
                                                <td>
                                                    <select name="cdConhecimento" id="cdConhecimento" class="inputtexto">
                                                        <option value="1" <%=jbean.getRelDefaultConhecimento().equals("1") ? "selected" : ""%>>Modelo 1 (Minuta)</option>
                                                        <option value="2" <%=jbean.getRelDefaultConhecimento().equals("2") ? "selected" : ""%>>Modelo 2 (Etiqueta)</option>
                                                        <option value="3" <%=jbean.getRelDefaultConhecimento().equals("3") ? "selected" : ""%>>Modelo 3 (Minuta)</option>
                                                        <option value="4" <%=jbean.getRelDefaultConhecimento().equals("4") ? "selected" : ""%>>Modelo 4 (Minuta)</option>

                                                        <%for (String rel : Apoio.listDocCtrc(request)) {%>
                                                        <option value="personalizado_<%=rel%>" <%=(jbean.getRelDefaultConhecimento().startsWith("personalizado_"+rel) ? "selected" : "")%>>Modelo <%=rel.toUpperCase()%> (Personalizado)</option>
                                                        <%}%>
                                                    </select>
                                                </td>
                                                <td>
                                                    <div align="right">Consultar Venda:</div>
                                                </td>
                                                <td>
                                                    <select name="cdConsultaVenda" id="cdConsultaVenda" class="inputtexto">
                                                        <option value="1" <%=jbean.getRelDefaultConsultaVenda().equals("1") ? "selected" : "" %>>Modelo 1</option>
                                                        <option value="2" <%=jbean.getRelDefaultConsultaVenda().equals("2") ? "selected" : "" %>>Modelo 2</option>
                                                        
                                                        <% for (String consultaVenda : Apoio.listNotasServico(request)) {%>
                                                        <option value="nota_servico_personalizado_<%=consultaVenda%>" <%=(jbean.getRelDefaultConsultaVenda().startsWith("nota_servico_personalizado_" + consultaVenda) ? "selected" : "")%>>Modelo <%=consultaVenda.toUpperCase() %></option>
                                                        <%}%>
                                                    </select>
                                                </td>
                                                
                                                </tr>
                                                <tr class="Celulazebra2">
                                                    <td>
                                                        <div align="right">Consultar Romaneio:</div>
                                                    </td>
                                                    <td>
                                                        <select name="cdConsultaRomaneio" id="cdConsultaRomaneio" class="inputtexto">
                                                            <option value="1" <%=jbean.getRelDefaultConsultaRomaneio().equals("1") ? "selected" : "" %>>Modelo 1</option>
                                                            <option value="2" <%=jbean.getRelDefaultConsultaRomaneio().equals("2") ? "selected" : "" %>>Modelo 2</option>
                                                            <option value="3" <%=jbean.getRelDefaultConsultaRomaneio().equals("3") ? "selected" : "" %>>Modelo 3</option>
                                                            <option value="4" <%=jbean.getRelDefaultConsultaRomaneio().equals("4") ? "selected" : "" %>>Modelo 4</option>
                                                            <option value="5" <%=jbean.getRelDefaultConsultaRomaneio().equals("5") ? "selected" : "" %>>Modelo 5</option>
                                                            <option value="6" <%=jbean.getRelDefaultConsultaRomaneio().equals("6") ? "selected" : "" %>>Modelo 6</option>
                                                            <option value="7" <%=jbean.getRelDefaultConsultaRomaneio().equals("7") ? "selected" : "" %>>Modelo 7</option>
                                                            <%for (String relRomaneio : Apoio.listRomaneios(request)) {%>
                                                                   <option value="personalizado_<%=relRomaneio%>" <%=(jbean.getRelDefaultConsultaRomaneio().startsWith("personalizado_" + relRomaneio) ? "selected" : "")%>>Modelo <%=relRomaneio.toUpperCase()%></option>
                                                            <%}%>
                                                        </select>
                                                    </td>
                                                    <td class="CelulaZebra2">
                                                        <div align="right">Modelo padrão O.S:</div>
                                                    </td>
                                                    <td width="30%" class="CelulaZebra2">
                                                        <select name="modeloOS" id="modeloOS" class="inputtexto">
                                                            <option value="1"  <%=jbean.getRelDefaultOrdemServico().equals("1") ? "selected" : "" %>>Modelo 1 </option>
                                                            <option value="2"  <%=jbean.getRelDefaultOrdemServico().equals("2") ? "selected" : "" %>>Modelo 2 </option>
                                                            <option value="3"  <%=jbean.getRelDefaultOrdemServico().equals("3") ? "selected" : "" %>>Modelo 3 </option>
                                                            <option value="4"  <%=jbean.getRelDefaultOrdemServico().equals("4") ? "selected" : "" %>>Modelo 4 </option>
                                                            <option value="5"  <%=jbean.getRelDefaultOrdemServico().equals("5") ? "selected" : "" %>>Modelo 5 (Custo da OS)</option>
                                                            <option value="6"  <%=jbean.getRelDefaultOrdemServico().equals("6") ? "selected" : "" %>>Modelo 6 </option>
                                                        </select>
                                                    </td>
                                                </tr>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr class="tabela">
                                    <td colspan="4">
                                        <div align="center">Lan&ccedil;amento de Nota de Servi&ccedil;o</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table width="100%" border="0" class="bordaFina">
                                            <tr>
                                                <td  width="50%" class="CelulaZebra2">
                                                    <div align="center">
                                                        <label>Forma de Calcular o ISS: </label>
                                                        <input type="radio" name="tipoCalculoIss" id="calculoIndividualIss" value="1">
                                                        Individualmente para cada servi&ccedil;o da nota
                                                        <input type="radio" name="tipoCalculoIss" id="calculoTotalIss" value="2">
                                                        Sobre o total do servi&ccedil;o
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </div>
                    <div class="panel" id="tab2">
                        <fieldset>
                            <table width="100%" border="0" class="bordaFina" align="center">
                                <tr class="tabela">
                                    <td colspan="4"> 
                                        <div align="center">
                                            Percentuais para C&aacute;lculo dos Impostos no Contrato de Frete
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="421" colspan="4">
                                        <table width="100%" border="0">
                                            <tr class="Celula">
                                                <td colspan="9">
                                                    <div align="center">Imposto de Renda (IR)</div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2" class="TextoCampos">
                                                    Base de C&aacute;lculo:
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <input name="iraliqbasecalculo" class="inputtexto" type="text" id="iraliqbasecalculo" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getIrAliqBaseCalculo())) : "0.00")%>" size="5" align="right" >
                                                    %
                                                </td>

                                                <td colspan="2" class="TextoCampos">
                                                    <input id="consideraDependentesIr" name="consideraDependentesIr" type="checkbox" value="true" <%=(carregaconfig && jbean.isConsideraDependentesIr()? "checked" : "")%>/>
                                                    Deduzir o valor dos dependentes ao calcular IR
                                                </td>
                                                <td colspan="2" class="TextoCampos">Valor Dependente:</td>
                                                <td colspan="2" class="CelulaZebra2">
                                                    <input name="irvldependente" class="inputtexto" type="text" id="irvldependente" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getIrVlDependente())) : "0.00")%>" size="7" align="right" >
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="3" class="CelulaZebra2">
                                                </td>
                                                <td colspan="4" class="CelulaZebra2">
                                                    <input id="deduzirINSSIR" name="deduzirINSSIR" type="checkbox" <%=(carregaconfig && jbean.isDeduzirINSSIR()? "checked" : "")%>/>
                                                    Deduzir o valor do INSS da base de cálculo do IR
                                                </td>
                                                <td colspan="3" class="CelulaZebra2">
                                                </td>
                                            </tr>
                                            <tr>
                                                <td width="15%" class="TextoCampos">De:</td>
                                                <td width="10%" class="CelulaZebra2"><input name="irde1" class="inputtexto" type="text" id="irde1" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getIrDe1())) : "0.00")%>" size="7" align="right" ></td>
                                                <td width="10%" class="TextoCampos">At&eacute;:</td>
                                                <td width="10%" class="CelulaZebra2"><input name="irate1" class="inputtexto" type="text" id="irate1" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getIrAte1())) : "0.00")%>" size="7" align="right" >          </td>
                                                <td colspan="2" class="TextoCampos">Aplicar:</td>
                                                <td width="15%" class="CelulaZebra2"><input name="iraliq1" class="inputtexto" type="text" id="iraliq1" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getIrAliq1())) : "0.00")%>" size="5" align="right" >%</td>
                                                <td width="10%" class="TextoCampos">Deduzir:</td>
                                                <td width="15%" class="CelulaZebra2"><input name="irdeduzir1" class="inputtexto" type="text" id="irdeduzir1" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getIrdeduzir1())) : "0.00")%>" size="7" align="right" >          </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos">De:</td>
                                                <td class="CelulaZebra2"><input name="irde2" class="inputtexto" type="text" id="irde2" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getIrDe2())) : "0.00")%>" size="7" align="right" ></td>
                                                <td class="TextoCampos">At&eacute;:</td>
                                                <td class="CelulaZebra2"><input name="irate2" class="inputtexto" type="text" id="irate2" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getIrAte2())) : "0.00")%>" size="7" align="right" >          </td>
                                                <td colspan="2" class="TextoCampos">Aplicar:</td>
                                                <td class="CelulaZebra2"><input name="iraliq2" class="inputtexto" type="text" id="iraliq2" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getIrAliq2())) : "0.00")%>" size="5" align="right" >%</td>
                                                <td class="TextoCampos">Deduzir:</td>
                                                <td class="CelulaZebra2"><input name="irdeduzir2" class="inputtexto" type="text" id="irdeduzir2" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getIrDeduzir2())) : "0.00")%>" size="7" align="right" >          </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos">De:</td>
                                                <td class="CelulaZebra2"><input name="irde3" class="inputtexto" type="text" id="irde3" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getIrDe3())) : "0.00")%>" size="7" align="right" ></td>
                                                <td class="TextoCampos">At&eacute;:</td>
                                                <td class="CelulaZebra2"><input name="irate3" class="inputtexto" type="text" id="irate3" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getIrAte3())) : "0.00")%>" size="7" align="right" >          </td>
                                                <td colspan="2" class="TextoCampos">Aplicar:</td>
                                                <td class="CelulaZebra2"><input name="iraliq3" class="inputtexto" type="text" id="iraliq3" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getIrAliq3())) : "0.00")%>" size="5" align="right" >%</td>
                                                <td class="TextoCampos">Deduzir:</td>
                                                <td class="CelulaZebra2"><input name="irdeduzir3" class="inputtexto" type="text" id="irdeduzir3" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getIrDeduzir3())) : "0.00")%>" size="7" align="right" >          </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos">
                                                    Acima de:
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <input name="iracima" type="text" class="inputtexto" id="iracima" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getIrAcima())) : "0.00")%>" size="7" align="right" >
                                                </td>
                                                <td class="TextoCampos">
                                                    Aplicar:
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <input name="iraliqacima" type="text" class="inputtexto" id="iraliqacima" onBlur="javascript:seNaoFloatReset(this, '0.00');"  value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getIrAliqAcima())) : "0.00")%>" size="5" align="right" >
                                                    %
                                                </td>
                                                <td colspan="2" class="TextoCampos">
                                                    Deduzir:
                                                </td>
                                                <td colspan="3" class="CelulaZebra2">
                                                    <input name="irdeduziracima" class="inputtexto" type="text" id="irdeduziracima" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getIrdeduzirAcima())) : "0.00")%>" size="7" align="right" >
                                                </td>
                                            </tr>
                                            <tr class="Celula">
                                                <td colspan="9">
                                                    <div align="center">
                                                        INSS
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="4" class="TextoCampos">
                                                    Base de C&aacute;lculo:
                                                </td>
                                                <td colspan="2" class="CelulaZebra2">
                                                    <input name="inssaliqbasecalculo" class="inputtexto" type="text" id="inssaliqbasecalculo" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getInssAliqBaseCalculo())) : "0.00")%>" size="5" align="right" >
                                                    %
                                                </td>
                                                <td class="TextoCampos">
                                                    Teto Reten&ccedil;&atilde;o:
                                                </td>
                                                <td colspan="2" class="CelulaZebra2">
                                                    <input name="tetoinss" type="text" class="inputtexto" id="tetoinss" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getTetoInss())) : "0.00")%>" size="5" align="right" >
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="4" class="TextoCampos">
                                                    At&eacute;:
                                                </td>
                                                <td colspan="2" class="CelulaZebra2">
                                                    <input name="inssate" type="text" class="inputtexto" id="inssate" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getInssAte())) : "0.00")%>" size="7" align="right" >
                                                </td>
                                                <td class="TextoCampos">
                                                    Aplicar:
                                                </td>
                                                <td colspan="2" class="CelulaZebra2">
                                                    <input name="inssaliqate" type="text" class="inputtexto" id="inssaliqate" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getInssAliqAte())) : "0.00")%>" size="5" align="right" >
                                                    %
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2" class="TextoCampos">
                                                    De:
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <input name="inssde1" type="text" id="inssde1" class="inputtexto" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getInssDe1())) : "0.00")%>" size="7" align="right" >
                                                </td>
                                                <td class="TextoCampos">
                                                    At&eacute;:
                                                </td>
                                                <td colspan="2" class="CelulaZebra2">
                                                    <input name="inssate1" type="text"  class="inputtexto" id="inssate1" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getInssAte1())) : "0.00")%>" size="7" align="right" >
                                                </td>
                                                <td class="TextoCampos">
                                                    Aplicar:
                                                </td>
                                                <td colspan="2" class="CelulaZebra2">
                                                    <input name="inssaliq1" type="text" class="inputtexto"  id="inssaliq1" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getInssAliq1())) : "0.00")%>" size="5" align="right" >
                                                    % 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2" class="TextoCampos">
                                                    De:
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <input name="inssde2" type="text" id="inssde2" class="inputtexto" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getInssDe2())) : "0.00")%>" size="7" align="right" >
                                                </td>
                                                <td class="TextoCampos">
                                                    At&eacute;:
                                                </td>
                                                <td colspan="2" class="CelulaZebra2">
                                                    <input name="inssate2" type="text" class="inputtexto" id="inssate2" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getInssAte2())) : "0.00")%>" size="7" align="right" >
                                                </td>
                                                <td class="TextoCampos">
                                                    Aplicar:
                                                </td>
                                                <td colspan="2" class="CelulaZebra2">
                                                    <input name="inssaliq2" type="text" class="inputtexto" id="inssaliq2" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getInssAliq2())) : "0.00")%>" size="5" align="right" >
                                                    % 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2" class="TextoCampos">
                                                    De:
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <input name="inssde3" type="text" id="inssde3" class="inputtexto" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getInssDe3())) : "0.00")%>" size="7" align="right" >
                                                </td>
                                                <td class="TextoCampos">
                                                    At&eacute;: 
                                                </td>
                                                <td colspan="2" class="CelulaZebra2">
                                                    <input name="inssate3" type="text" class="inputtexto" id="inssate3" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getInssAte3())) : "0.00")%>" size="7" align="right" >
                                                </td>
                                                <td class="TextoCampos">
                                                    Aplicar:
                                                </td>
                                                <td colspan="2" class="CelulaZebra2">
                                                    <input name="inssaliq3" type="text" class="inputtexto" id="inssaliq3" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getInssAliq3())) : "0.00")%>" size="5" align="right" >
                                                    %
                                                </td>
                                            </tr>
                                            <tr class="Celula">
                                                <td colspan="9">
                                                    <div align="center">
                                                        SEST/SENAT
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td height="24" colspan="4" class="TextoCampos">Al&iacute;quota:</td>
                                                <td colspan="5" class="CelulaZebra2">
                                                    <input name="sestsenataliq" type="text" class="inputtexto" id="sestsenataliq" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getSestSenatAliq())) : "0.00")%>" size="5" align="right" >
                                                    %
                                                </td>
                                            </tr>
                                            <tr class="tabela">
                                                <td colspan="9">
                                                    <div align="center">
                                                        Outras (Contrato de Frete)
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos" colspan="4"> 
                                                    <div>
                                                        Ao reter impostos acrescentar ao valor do frete:
                                                    </div>
                                                </td>
                                                <td class="CelulaZebra2" colspan="8">
                                                    <label class="TextoCampos">
                                                        <input id="chkIsDiariaRetemImposto" type="checkbox" value="true" <%=(carregaconfig && jbean.isDiariaRetemImposto() ? "checked" : "")%> name="chkIsDiariaRetemImposto"/>
                                                        Valor da Diária
                                                    </label> &nbsp; &nbsp; &nbsp; &nbsp;
                                                    <label class="TextoCampos">
                                                        <input id="chkIsDescargaRetemImposto" type="checkbox" value="true" <%=(carregaconfig && jbean.isDescargaRetemImposto() ? "checked" : "")%> name="chkIsDescargaRetemImposto"/>
                                                        Valor da Descarga
                                                    </label>&nbsp; &nbsp; &nbsp; &nbsp;
                                                    <label class="TextoCampos">                                                        
                                                        <input id="chkIsOutrosRetemImposto" type="checkbox" value="true"  <%=(carregaconfig && jbean.isOutrosRetemImposto() ? "checked" : "")%> name="chkIsOutrosRetemImposto"/>
                                                        Valor Outros
                                                    </label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos" colspan="4">
                                                    <div>
                                                        Ao reter impostos deduzir do valor do frete:
                                                    </div>
                                                </td>
                                                <td class="CelulaZebra2" colspan="8">
                                                    <label class="TextoCampos">
                                                        <input id="chkIsDeduzirImpostosOutrasRetencoesCfe" type="checkbox" <%=(carregaconfig && jbean.isDeduzirImpostosOutrasRetencoesCfe() ? "checked" : "")%> name="chkIsDeduzirImpostosOutrasRetencoesCfe">
                                                        Outras Retenções
                                                    </label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos" colspan="3">
                                                    <div align="right">
                                                        Valor Consulta Motorista:
                                                    </div>
                                                </td>
                                                <td class="CelulaZebra2" colspan="2">
                                                    <input name="vlconmotor" type="text" id="vlconmotor" class="inputtexto" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? jbean.getVlConMotor() : "0.00")%>" size="7" align="right" >
                                                    <select name="tipo_vlconmotor" id="tipo_vlconmotor" class="inputtexto">
                                                        <option value="f" <%=(carregaconfig && jbean.getTipoVlConMotor().equals("f") ? "selected" : "")%>>R$</option>
                                                        <option value="p" <%=(carregaconfig && jbean.getTipoVlConMotor().equals("p") ? "selected" : "")%>>%</option>
                                                    </select>
                                                </td>
                                                <td class="CelulaZebra2" colspan="4">
                                                    Esse valor Ser&aacute; Descontado do Motorista no Contrato de Frete.
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="4" rowspan="8" class="TextoCampos"> 
                                                    <div align="right">
                                                        <input type="checkbox" name="gerar_despesa" id="gerar_despesa" value="true" <%=(carregaconfig && jbean.getGerar_despesa_cartafrete() ? "checked" : "")%>>
                                                        Gerar Despesa ao Lan&ccedil;ar/Baixar Contrato de Frete.
                                                    </div>
                                                </td>
                                                <td colspan="2" class="TextoCampos">
                                                    Fornecedor:
                                                </td>
                                                <td colspan="3" class="CelulaZebra2">
                                                    <input type="hidden" name="idfornecedor" id="idfornecedor" value="<%=(carregaconfig ? jbean.getFornecedor_cartafrete().getIdfornecedor() : 0)%>">
                                                    <input name="fornecedor" type="text" id="fornecedor" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getFornecedor_cartafrete().getRazaosocial() : "")%>" size="22" maxlength="50" readonly="true">
                                                    <strong>
                                                        <input name="localiza_forn" type="button" class="botoes" id="localiza_forn" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=21', 'Fornecedor')">
                                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Fornecedor" onClick="javascript:getObj('idfornecedor').value = 0;
                                                                javascript:getObj('fornecedor').value = 'O Proprietário do veículo';">
                                                    </strong>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="5" class="celula">
                                                    <div align="center">Plano e Unidade de Custo Padr&atilde;o </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2" class="TextoCampos">
                                                    Adiantamento:
                                                </td>
                                                <td colspan="3" class="CelulaZebra2">
                                                    <input name="plcusto_adiantamento" type="text" id="plcusto_adiantamento" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getPlanocusto_cartafrete().getConta() : "")%>" size="10" maxlength="25" readonly="true">
                                                    <strong>
                                                        <input name="localiza_plano_cartafrete" type="button" class="botoes" id="localiza_plano_cartafrete" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=20', 'Plano_custo_despesa_adiantamento')">&nbsp;&nbsp;
                                                    </strong>
                                                    <input name="und_custo_adiantamento" type="text" id="und_custo_adiantamento" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getUnidadeCustoAdiantamento().getSigla() : "")%>" size="4" maxlength="25" readonly="true">
                                                    <strong>
                                                        <input name="localiza_unidade_cartafrete" type="button" class="botoes" id="localiza_unidade_cartafrete" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=39', 'und_custo_adiantamento')">
                                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Fornecedor" onClick="javascript:getObj('und_custo_adiantamento_id').value = 0;
                                                                javascript:getObj('und_custo_adiantamento').value = '';">
                                                        <input name="id_und" type="hidden" id="id_und" value="0">
                                                        <input name="sigla_und" type="hidden" id="sigla_und" value="">
                                                        <input name="und_custo_adiantamento_id" type="hidden" id="und_custo_adiantamento_id" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getUnidadeCustoAdiantamento().getId() : "0")%>">
                                                    </strong>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2" class="TextoCampos">
                                                    Saldo:
                                                </td>
                                                <td colspan="3" class="CelulaZebra2">
                                                    <input name="plcusto_saldo" type="text" id="plcusto_saldo" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getPlanoCustoSaldoId().getConta() : "")%>" size="10" maxlength="25" readonly="true">
                                                    <strong>
                                                        <input name="localiza_plano_cartafrete" type="button" class="botoes" id="localiza_plano_cartafrete" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=20', 'Plano_custo_despesa_saldo')">&nbsp;&nbsp;
                                                    </strong>
                                                    <input name="und_custo_saldo" type="text" id="und_custo_saldo" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getUnidadeCustoSaldo().getSigla() : "")%>" size="4" maxlength="25" readonly="true">
                                                    <strong>
                                                        <input name="localiza_unidade_saldo_cartafrete" type="button" class="botoes" id="localiza_unidade_saldo_cartafrete" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=39', 'und_custo_saldo')">
                                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Fornecedor" onClick="javascript:getObj('und_custo_saldo_id').value = 0;
                                                                javascript:getObj('und_custo_saldo').value = '';">
                                                        <input name="und_custo_saldo_id" type="hidden" id="und_custo_saldo_id" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getUnidadeCustoSaldo().getId() : "0")%>">
                                                    </strong>                                            
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2" class="TextoCampos">
                                                    Pedágio:
                                                </td>
                                                <td colspan="3" class="CelulaZebra2">
                                                    <input name="plcusto_pedagio" type="text" id="plcusto_pedagio" class="inputReadOnly" value="<%=(carregaconfig ? jbean.getPlanoCustoPedagio().getConta() : "")%>" size="10" maxlength="25" readonly="true">
                                                    <strong>
                                                        <input name="localiza_plano_cartafrete" type="button" class="botoes" id="localiza_plano_cartafrete" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=20', 'Plano_custo_despesa_pedagio')">&nbsp;&nbsp;
                                                    </strong>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="5" class="TextoCampos">
                                                    <div align="left">
                                                        Considerar como N&ordm; do Documento na Despesa:
                                                        <select name="identificador_cartafrete" id="identificador_cartafrete" class="inputtexto">
                                                            <option value="0">N&ordm; do Contrato de Frete</option>
                                                            <option value="1">N&ordm; do CT-e</option>
                                                        </select>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" colspan="5">
                                                    <div align="center">
                                                        <input name="baixaAdiantamentoCarta" type="checkbox" id="baixaAdiantamentoCarta" value="true" <%=(carregaconfig && jbean.isBaixaAdiantamentoCartaFrete() ? "checked" : "")%> onclick="validacaoBaixarDespesaAposConfirmarCIOT('baixarAdiantamento')" >
                                                        Baixar Despesa Automaticamente ao Incluir Adiantamento nas Formas de Pagamento Dinheiro, Cheque, Dep&oacute;sito Banc&aacute;rio ou Transferência Banc&aacute;ria.
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" colspan="5">
                                                    <div align="center">
                                                        <input name="baixarDespesaAposConfirmacaoCIOT" type="checkbox" id="baixarDespesaAposConfirmacaoCIOT" value="true" <%=(carregaconfig && jbean.isBaixarDespesaAposConfirmacaoCIOT() ? "checked" : "")%>  onclick="validacaoBaixarDespesaAposConfirmarCIOT('baixarDespesa')">
                                                        Só baixar o adiantamento após a confirmação do CIOT
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos" colspan="3">
                                                    Forma de Pagamento Padr&atilde;o: 
                                                </td>
                                                <td colspan="2" class="CelulaZebra2">
                                                    <select name="fpag" id="fpag" class="inputtexto">
                                                        <%  BeanConsultaFPag fpag = new BeanConsultaFPag();
                                                            fpag.setConexao(Apoio.getUsuario(request).getConexao());
                                                            fpag.MostrarTudo();
                                                            ResultSet rs = fpag.getResultado();
                                                            while (rs.next()) {%>
                                                        <option value="<%=rs.getString("idfpag")%>" <%=(carregaconfig && rs.getInt("idfpag") == jbean.getFpag().getIdFPag() ? "selected" : "")%> style="background-color:#FFFFFF"><%=rs.getString("descfpag")%></option>
                                                        <%  }
                                                            rs.close();%>
                                                    </select>            
                                                    <div align="center">
                                                    </div>
                                                </td>
                                                <td colspan="4" class="CelulaZebra2">
                                                    <div align="center">
                                                        <input name="semmanifesto" type="checkbox" id="semmanifesto" value="true" <%=(carregaconfig && jbean.isSalvaCartaSemManifesto() ? "checked" : "")%>>
                                                        Salvar Contrato de Frete sem documentos (manifesto, coleta, romaneio). 
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos" colspan="9">
                                                    <div align="center">
                                                        <input name="permiteContratoMaior" type="checkbox" id="permiteContratoMaior" value="true" <%=(carregaconfig && jbean.isPermiteContratoMaiorCtrc() ? "checked" : "")%>>
                                                        Permite Salvar um Contrato de Frete com o Valor do Carreteiro Maior que o Valor Líquido (Valor do Frete - ICMS - Impostos Federais) dos documentos transportados.
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="9">
                                                    <table width="100%" border="0" align="center">
                                                        <tr>
                                                            <td class="CelulaZebra2" width="45%">
                                                                <div align="center">
                                                                    <input name="cartaFreteAutomatica" type="checkbox" id="cartaFreteAutomatica" value="true" <%=(carregaconfig && jbean.isCartaFreteAutomatica() ? "checked" : "")%>>
                                                                    Gerar Contrato de Frete Automaticamente ao Incluir um CT-e.
                                                                </div>
                                                            </td>
                                                            <td class="TextoCampos" width="20%">
                                                                Gerar Contrato de Frete de:
                                                            </td>
                                                            <td class="CelulaZebra2" width="11%">
                                                                <div align="center">
                                                                    <!--<input name="coletaCartaFrete" type="checkbox" id="coletaCartaFrete" value="true" (carregaconfig && jbean.isLancaColetaNaCartaFrete() ? "checked" : "")>-->
                                                                    <input name="gerarCartaFreteColeta" type="checkbox" id="gerarCartaFreteColeta" value="true" <%=(carregaconfig && jbean.isGerarCartaFreteColeta() ? "checked" : "")%>>
                                                                    Coletas.
                                                                </div>
                                                            </td>
                                                            <td class="CelulaZebra2" width="12%">
                                                                <div align="center">
                                                                    <input name="gerarCartaFreteRomaneio" type="checkbox" id="gerarCartaFreteRomaneio" value="true" <%=(carregaconfig && jbean.isGerarCartaFreteRomaneio() ? "checked" : "")%>>
                                                                    Romaneios.
                                                                </div>
                                                            </td>
                                                            <td class="CelulaZebra2" width="12%">
                                                                <div align="center">
                                                                    <input name="gerarCartaFreteManifesto" type="checkbox" id="gerarCartaFreteManifesto" value="true" <%=(carregaconfig && jbean.isGerarCartaFreteManifesto() ? "checked" : "")%>>
                                                                    Manifestos.
                                                                </div></td></tr></table>
                                                </td>
                                            </tr>
                                            <tr class="CelulaZebra2">
                                                <td align="center"   colspan="3" >
                                                    <input name="cartaFreteAutomaticaColeta" type="checkbox" id="cartaFreteAutomaticaColeta" <%=(carregaconfig && jbean.isCartaFreteAutomaticaColeta() ? "checked" : "")%> value="true">
                                                    Gerar Contrato de Frete Automaticamente ao Incluir uma Coleta.
                                                </td>
                                                <td align="center" colspan="3" >
                                                    <input name="cartaFreteAutomaticaRomaneio" type="checkbox" id="cartaFreteAutomaticaRomaneio" <%=(carregaconfig && jbean.isCartaFreteAutomaticaRomaneio() ? "checked" : "")%> value="true" >
                                                    Gerar Contrato de Frete Automaticamente ao Incluir um Romaneio.
                                                </td><td colspan="3" align="center"><label>
                                                        <input name="consideraOutrasRetencoesDespesaAnaliseFrete" type="checkbox" id="consideraOutrasRetencoesDespesaAnaliseFrete" <%=(carregaconfig && jbean.isConsideraOutrasRetencoesDespesaAnaliseFrete() ? "checked" : "" )%> value="true" />
                                                        O campo "outras retenções" não será considerado uma despesa nos relatórios de lucratividade.
                                                    </label></td> <tr>
                                                 <td class="TextoCampos" colspan="6" >
                                                    <div align="right">
                                                        Percentual de Tolerância de Peso ao Calcular Excedente Pela Tabela de Frete:
                                                    </div></td>
                                                <td class="CelulaZebra2" colspan="4">
                                                    <input name="percentualToleranciaPeso" type="text" id="percentualToleranciaPeso" class="inputtexto" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? jbean.getPercentualToleranciaPeso() : "0.00")%>" size="4" align="right" maxlength="5" >
                                            </tr></td></tr>
                                            <tr><td class="TextoCampos" colspan="6"><label style="margin-right: 10px;">
                                                        <input id="descontoAutomaticoAbastecimento" name="descontoAutomaticoAbastecimento" type="checkbox" <%=(carregaconfig && jbean.isDescontoAutomaticoAbastecimento() ? "checked" : "")%>/>Descontar automaticamente abastecimentos do GW Frota ao incluir um contrato de frete.
                                                    </label></td>
                                                <td class="CelulaZebra2" colspan="4">
                                                    Considerar abastecimentos a partir de:                                                     
                                                    <input name="considerarAbastecimentoApartir" type="text" id="considerarAbastecimentoApartir" size="10" maxlength="10" placeholder="dd/mm/yyyy" value="<%=(carregaconfig ? jbean.getConsiderarAbastecimentoApartir() : "")%>" class="fieldDate" onkeypress="mascaraData(this, event)">
                                                </td></tr>
                                            <tr>
                                                <td class="TextoCampos" colspan="3" >
                                                    Mensagem ao Gerar Contrato de Frete:
                                                </td>
                                                <td class="CelulaZebra2" colspan="6" >
                                                    <textarea cols="50" rows="6" class="inputtexto" id="mensagemCartaFrete" name="mensagemCartaFrete" ><%=(carregaconfig ? jbean.getMensagemCartaFrete() : "")%></textarea>
                                                </td>
                                            </tr>                                          
                                        </table>
                                    </td></tr></table>
                        </fieldset>
                    </div>
                    <div class="panel" id="tab3">
                        <fieldset>
                            <table width="100%" border="0" class="bordaFina" align="center">
                                <tr>
                                    <td colspan="4" class="tabela">
                                        <div align="center">
                                            Integra&ccedil;&atilde;o Cont&aacute;bil e Fiscal 
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="50%" colspan="2" class="TextoCampos">
                                        <div align="center">
                                            <input type="checkbox" name="iscontabil" id="iscontabil" value="true" <%=(carregaconfig && jbean.getIsContabil() ? "checked" : "")%>>
                                            Gerar Integra&ccedil;&atilde;o Cont&aacute;bil 
                                        </div>
                                    </td>
                                    <td width="50%" colspan="2" class="TextoCampos">
                                        <div align="center">
                                            <input type="checkbox" name="isfiscal" id="isfiscal" value="true" <%=(carregaconfig && jbean.getIsFiscal() ? "checked" : "")%>>
                                            Gerar Integra&ccedil;&atilde;o Fiscal 
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="celula">
                                        <div align="center">
                                            Contas das Despesas/Receitas,Impostos Retidos e Contrato de Fretes 
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table width="100%" class="bordaFina">
                                            <tr>
                                                <td width="17%" class="TextoCampos">
                                                    Juros Pagos: 
                                                </td>
                                                <td width="33%" class="CelulaZebra2">
                                                    <input name="jurospagos" class="inputTexto" type="text" id="jurospagos" value="<%=(carregaconfig ? jbean.getContaJurosPago().getCodigo() : "")%>" size="10" maxlength="25" onkeypress="if (event.keyCode==13) localizarContaContabil(this,$('jurospagos_id'), $('jurospagosDescricao'));">
                                                    <input name="jurospagosDescricao" class="inputReadOnly" type="text" id="jurospagosDescricao" value="<%=(carregaconfig ? jbean.getContaJurosPago().getDescricao() : "")%>" size="20" readonly="true">
                                                    <strong>
                                                        <input name="localiza_jurospagos" type="button" class="botoes" id="localiza_jurospagos" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=38', 'Conta_juros_pagos')">
                                                        <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Carreta" onClick="javascript:getObj('jurospagos_id').value = 0;getObj('jurospagosDescricao').value = '';
                                                                javascript:getObj('jurospagos').value = '';"></strong>
                                                    </strong>
                                                </td>
                                                <td width="17%" class="TextoCampos">
                                                    Juros Recebidos: 
                                                </td>
                                                <td width="33%" class="CelulaZebra2">
                                                    <input name="jurosrecebidos" class="inputTexto" type="text" id="jurosrecebidos"  value="<%=(carregaconfig ? jbean.getContaJurosRecebidos().getCodigo() : "")%>" size="10" maxlength="25" onkeypress="if (event.keyCode==13) localizarContaContabil(this,$('jurosrecebidos_id'), $('jurosrecebidosDescricao'));">
                                                    <input name="jurosrecebidosDescricao" class="inputReadOnly" type="text" id="jurosrecebidosDescricao" value="<%=(carregaconfig ? jbean.getContaJurosRecebidos().getDescricao() : "")%>" size="20" readonly="true">
                                                    <strong>
                                                        <input name="localiza_jurosrecebidos" type="button" class="botoes" id="localiza_jurosrecebidos" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=38', 'Conta_juros_recebidos')">
                                                        <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Carreta" onClick="javascript:getObj('jurosrecebidos_id').value = 0;getObj('jurosrecebidosDescricao').value = '';
                                                                javascript:getObj('jurosrecebidos').value = '';"></strong> 
                                                    </strong>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos">
                                                    Descontos Concedidos: 
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <input name="descontosconcedidos" type="text" class="inputTexto" id="descontosconcedidos"  value="<%=(carregaconfig ? jbean.getContaDescontoConcedidos().getCodigo() : "")%>" size="10" maxlength="25" onkeypress="if (event.keyCode==13) localizarContaContabil(this,$('descontosconcedidos_id'), $('descontosconcedidosDescricao'));">
                                                    <input name="descontosconcedidosDescricao" class="inputReadOnly" type="text" id="descontosconcedidosDescricao" value="<%=(carregaconfig ? jbean.getContaDescontoConcedidos().getDescricao() : "")%>" size="20" readonly="true">
                                                    <strong>
                                                        <input name="localiza_descontosconcedidos" type="button" class="botoes" id="localiza_descontosconcedidos" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=38', 'Conta_descontos_concedidos')">
                                                        <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Carreta" onClick="javascript:getObj('descontosconcedidos_id').value = 0;getObj('descontosconcedidosDescricao').value = '';
                                                                javascript:getObj('descontosconcedidos').value = '';"></strong> 
                                                    </strong>
                                                </td>
                                                <td class="TextoCampos">
                                                    Descontos Obtidos: 
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <input name="descontosobtidos" class="inputTexto" type="text" id="descontosobtidos"  value="<%=(carregaconfig ? jbean.getContaDescontoObtido().getCodigo() : "")%>" size="10" maxlength="25" onkeypress="if (event.keyCode==13) localizarContaContabil(this,$('descontosobtidos_id'), $('descontosobtidosDescricao'));">
                                                    <input name="descontosobtidosDescricao" class="inputReadOnly" type="text" id="descontosobtidosDescricao" value="<%=(carregaconfig ? jbean.getContaDescontoObtido().getDescricao() : "")%>" size="20" readonly="true">
                                                    <strong>
                                                        <input name="localiza_descontosobtidos" type="button" class="botoes" id="localiza_descontosobtidos" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=38', 'Conta_descontos_obtidos')">
                                                        <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Carreta" onClick="javascript:getObj('descontosobtidos_id').value = 0;getObj('descontosobtidosDescricao').value = '';
                                                                javascript:getObj('descontosobtidos').value = '';"></strong> 
                                                    </strong>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td rowspan="6" class="TextoCampos">
                                                    Impostos nas Compras:
                                                </td>
                                                <td class="TextoCampos">
                                                    IRRF Retido: 
                                                </td>
                                                <td colspan="2" class="CelulaZebra2">
                                                    <strong>
                                                        <span class="CelulaZebra2">
                                                            <input name="irrfRetido" type="text" id="irrfRetido" class="inputTexto" value="<%=(carregaconfig ? jbean.getContaIrrfRetido().getCodigo() : "")%>" size="10" maxlength="25" onkeypress="if (event.keyCode==13) localizarContaContabil(this,$('irrf_retido_id'), $('irrfRetidoDescricao'));">
                                                            <input name="irrfRetidoDescricao" class="inputReadOnly" type="text" id="irrfRetidoDescricao" value="<%=(carregaconfig ? jbean.getContaIrrfRetido().getDescricao() : "")%>" size="20" readonly="true">
                                                            <strong>
                                                                <input name="localiza_jurospagos" type="button" class="botoes" id="localiza_jurospagos" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=38', 'IRRF_retido')">
                                                                <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Carreta" onClick="javascript:getObj('irrf_retido_id').value = 0;getObj('irrfRetidoDescricao').value = '';
                                                                        javascript:getObj('irrfRetido').value = '';"></strong>
                                                            </strong>
                                                        </span> 
                                                    </strong>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos">
                                                    INSS Retido: 
                                                </td>
                                                <td colspan="2" class="CelulaZebra2">
                                                    <strong>
                                                        <span class="CelulaZebra2">
                                                            <input name="inssRetido" type="text" id="inssRetido" class="inputTexto" value="<%=(carregaconfig ? jbean.getContaInssRetido().getCodigo() : "")%>" size="10" maxlength="25" onkeypress="if (event.keyCode==13) localizarContaContabil(this,$('inss_retido_id'), $('inssRetidoDescricao'));">
                                                            <input name="inssRetidoDescricao" class="inputReadOnly" type="text" id="inssRetidoDescricao" value="<%=(carregaconfig ? jbean.getContaInssRetido().getDescricao() : "")%>" size="20" readonly="true">
                                                            <strong>
                                                                <input name="localiza_jurospagos" type="button" class="botoes" id="localiza_jurospagos" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=38', 'INSS_retido')">
                                                                <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Carreta" onClick="javascript:getObj('inss_retido_id').value = 0; getObj('inssRetidoDescricao').value = '';
                                                                        javascript:getObj('inssRetido').value = '';"></strong>
                                                            </strong>
                                                        </span>
                                                    </strong>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos">
                                                    ISS Retido: 
                                                </td>
                                                <td colspan="2" class="CelulaZebra2">
                                                    <strong>
                                                        <span class="CelulaZebra2">
                                                            <input name="issRetido" type="text" id="issRetido" class="inputTexto" value="<%=(carregaconfig ? jbean.getContaIssRetido().getCodigo() : "")%>" size="10" maxlength="25" onkeypress="if (event.keyCode==13) localizarContaContabil(this,$('iss_retido_id'), $('issRetidoDescricao'));">
                                                            <input name="issRetidoDescricao" class="inputReadOnly" type="text" id="issRetidoDescricao" value="<%=(carregaconfig ? jbean.getContaIssRetido().getDescricao() : "")%>" size="20" readonly="true">
                                                            <strong>
                                                                <input name="localiza_jurospagos" type="button" class="botoes" id="localiza_jurospagos" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=38', 'ISS_retido')">
                                                                <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Carreta" onClick="javascript:getObj('iss_retido_id').value = 0; getObj('issRetidoDescricao').value = '';
                                                                        javascript:getObj('issRetido').value = '';"></strong>
                                                            </strong>
                                                        </span>
                                                    </strong>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos">
                                                    PIS Retido: 
                                                </td>
                                                <td colspan="2" class="CelulaZebra2">
                                                    <strong>
                                                        <span class="CelulaZebra2">
                                                            <input name="pisRetido" type="text" id="pisRetido" class="inputTexto" value="<%=(carregaconfig ? jbean.getContaPisRetido().getCodigo() : "")%>" size="10" maxlength="25" onkeypress="if (event.keyCode==13) localizarContaContabil(this,$('pis_retido_id'), $('pisRetidoDescricao'));">
                                                            <input name="pisRetidoDescricao" class="inputReadOnly" type="text" id="pisRetidoDescricao" value="<%=(carregaconfig ? jbean.getContaPisRetido().getDescricao() : "")%>" size="20" readonly="true">
                                                            <strong>
                                                                <input name="localiza_jurospagos" type="button" class="botoes" id="localiza_jurospagos" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=38', 'PIS_retido')">
                                                                <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Carreta" onClick="javascript:getObj('pis_retido_id').value = 0; getObj('pisRetidoDescricao').value = '';
                                                                        javascript:getObj('pisRetido').value = '';"></strong>
                                                            </strong>
                                                        </span>
                                                    </strong>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos">
                                                    COFINS Retido: 
                                                </td>
                                                <td colspan="2" class="CelulaZebra2">
                                                    <strong>
                                                        <span class="CelulaZebra2">
                                                            <input name="cofinsRetido" type="text" id="cofinsRetido" class="inputTexto" value="<%=(carregaconfig ? jbean.getContaCofinsRetido().getCodigo() : "")%>" size="10" maxlength="25" onkeypress="if (event.keyCode==13) localizarContaContabil(this,$('cofins_retido_id'), $('cofinsRetidoDescricao'));">
                                                            <input name="cofinsRetidoDescricao" class="inputReadOnly" type="text" id="cofinsRetidoDescricao" value="<%=(carregaconfig ? jbean.getContaCofinsRetido().getDescricao() : "")%>" size="20" readonly="true">
                                                            <strong>
                                                                <input name="localiza_jurospagos" type="button" class="botoes" id="localiza_jurospagos" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=38', 'COFINS_retido')">
                                                                <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Carreta" onClick="javascript:getObj('cofins_retido_id').value = 0; getObj('cofinsRetidoDescricao').value = '';
                                                                        javascript:getObj('cofinsRetido').value = '';"></strong>
                                                            </strong>
                                                        </span>
                                                    </strong>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos">
                                                    CSSL Retido: 
                                                </td>
                                                <td colspan="2" class="CelulaZebra2">
                                                    <strong>
                                                        <span class="CelulaZebra2">
                                                            <input name="csslRetido" type="text" id="csslRetido" class="inputTexto" value="<%=(carregaconfig ? jbean.getContaCsslRetido().getCodigo() : "")%>" size="10" maxlength="25" onkeypress="if (event.keyCode==13) localizarContaContabil(this,$('cssl_retido_id'), $('csslRetidoDescricao'));">
                                                            <input name="csslRetidoDescricao" class="inputReadOnly" type="text" id="csslRetidoDescricao" value="<%=(carregaconfig ? jbean.getContaCsslRetido().getDescricao() : "")%>" size="20" readonly="true">
                                                            <strong>
                                                                <input name="localiza_jurospagos" type="button" class="botoes" id="localiza_jurospagos" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=38', 'CSSL_retido')">
                                                                <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Carreta" onClick="javascript:getObj('cssl_retido_id').value = 0; getObj('csslRetidoDescricao').value = '';
                                                                        javascript:getObj('csslRetido').value = '';"></strong>
                                                            </strong>
                                                        </span>
                                                    </strong>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="4">
                                                    <table width="100%">
                                                        <tr>
                                                            <td width="10%" class="TextoCampos">
                                                                Padr&atilde;o do Cliente: 
                                                            </td>
                                                            <td width="30%" class="celulaZebra2">
                                                                <input name="contaCliente" type="text" id="contaCliente" class="inputTexto" value="<%=(carregaconfig ? jbean.getContaCliente().getCodigo() : "")%>" size="10" maxlength="25" onkeypress="if (event.keyCode==13) localizarContaContabil(this,$('contaClienteId'), $('contaClienteDescricao'));">
                                                                <input name="contaClienteDescricao" class="inputReadOnly" type="text" id="contaClienteDescricao" value="<%=(carregaconfig ? jbean.getContaCliente().getDescricao() : "")%>" size="20" readonly="true">
                                                                <input name="localiza_contaCliente" type="button" class="botoes" id="localiza_contaCliente" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=38', 'Conta_Padrao_Cliente')">
                                                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Conta" onClick="javascript:getObj('contaClienteId').value = 0; getObj('contaClienteDescricao').value = '';
                                                                        javascript:getObj('contaCliente').value = '';">
                                                            </td>
                                                            <td width="15%" class="TextoCampos">
                                                                Padr&atilde;o do Fornecedor: 
                                                            </td>
                                                            <td width="30%" class="celulaZebra2">
                                                                <input name="contaFornecedor" type="text" id="contaFornecedor" class="inputTexto" value="<%=(carregaconfig ? jbean.getContaFornecedor().getCodigo() : "")%>" size="10" maxlength="25" onkeypress="if (event.keyCode==13) localizarContaContabil(this,$('contaFornecedorId'), $('contaFornecedorDescricao'));">
                                                                <input name="contaFornecedorDescricao" class="inputReadOnly" type="text" id="contaFornecedorDescricao" value="<%=(carregaconfig ? jbean.getContaFornecedor().getDescricao() : "")%>" size="20" readonly="true">
                                                                <input name="localiza_contaCliente" type="button" class="botoes" id="localiza_contaCliente" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=38', 'Conta_Padrao_Fornecedor')">
                                                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Conta" onClick="javascript:getObj('contaFornecedorId').value = 0; getObj('contaFornecedorDescricao').value = '';
                                                                        javascript:getObj('contaFornecedor').value = '';">
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td width="20%" class="TextoCampos">
                                                                Padr&atilde;o do Propriet&aacute;rio: 
                                                            </td>
                                                            <td width="30%" class="celulaZebra2" colspan="3">
                                                                <input name="contaProprietario" type="text" id="contaProprietario" class="inputTexto" value="<%=(carregaconfig ? jbean.getContaProprietario().getCodigo() : "")%>" size="10" maxlength="25" onkeypress="if (event.keyCode==13) localizarContaContabil(this,$('contaProprietarioId'), $('contaProprietarioDescricao'));">
                                                                <input name="contaProprietarioDescricao" class="inputReadOnly" type="text" id="contaProprietarioDescricao" value="<%=(carregaconfig ? jbean.getContaProprietario().getDescricao() : "")%>" size="20" readonly="true">
                                                                <input name="localiza_contaProprietario" type="button" class="botoes" id="localiza_contaProprietario" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=38', 'Conta_Padrao_Proprietario')">
                                                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Conta" onClick="javascript:getObj('contaProprietarioId').value = 0; getObj('contaProprietarioDescricao').value = '';
                                                                        javascript:getObj('contaProprietario').value = '';">
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="celula">
                                        <div align="center">
                                            Complementos dos Hist&oacute;ricos para Contabilidade 
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table width="100%" class="bordaFina">
                                            <tr>
                                                <td width="20%" class="TextoCampos">Para Provis&otilde;es: </td>
                                                <td width="30%" class="CelulaZebra2">
                                                    <input name="historico_provisao" id="historico_provisao" class="inputtexto" type="text" size="20" maxlength="20" value="<%=(carregaconfig ? jbean.getHistoricoProvisao() : "")%>">
                                                </td>
                                                <td width="20%" class="TextoCampos">Para Recebimentos: </td>
                                                <td width="30%" class="CelulaZebra2">
                                                    <input name="historico_recebimento" id="historico_recebimento" class="inputtexto" type="text" size="20" maxlength="20" value="<%=(carregaconfig ? jbean.getHistoricoRecebimento() : "")%>">
                                                </td>
                                            </tr>
                                            <tr>
                                                <td width="20%" class="TextoCampos">Para Pagamentos: </td>
                                                <td width="30%" class="CelulaZebra2">
                                                    <input name="historico_pagamento" id="historico_pagamento" class="inputtexto" type="text" size="20" maxlength="20" value="<%=(carregaconfig ? jbean.getHistoricoPagamento() : "")%>">
                                                </td>
                                                <td width="20%" class="TextoCampos">&nbsp;</td>
                                                <td width="30%" class="CelulaZebra2">&nbsp;</td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="celula">
                                        <div align="center">% dos Impostos Federais</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table width="100%" class="bordaFina">
                                            <tr>
                                                <td width="5%" class="TextoCampos">IR:</td>
                                                <td width="10%" class="CelulaZebra2">
                                                    <input name="impostorenda" type="text" class="inputtexto" id="impostorenda" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getImpostorenda())) : "0.00")%>" size="5" align="right" >
                                                    <label>
                                                    <br><input name="embutir_renda" id="embutir_renda" type="checkbox" value="true" <%=(carregaconfig && jbean.isEmbutirIR() ? "checked" : "")%>>
                                                        Embutir IR no CT-e
                                                    </label>
                                                    
                                                </td>
                                                <td width="5%" class="TextoCampos">CSSL:</td>
                                                <td width="10%" class="CelulaZebra2">
                                                    <input name="cssl_config" type="text" id="cssl_config" class="inputtexto" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getCssl())) : "0.00")%>" size="5" align="right" >
                                                    <label>
                                                        <br><input name="embutir_cssl" id="embutir_cssl" type="checkbox" value="true" <%=(carregaconfig && jbean.isEmbutirCssl() ? "checked" : "")%>>
                                                        Embutir CSSL no CT-e
                                                    </label>
                                                </td>
                                                <td width="5%" class="TextoCampos">PIS:</td>
                                                <td width="10%" class="CelulaZebra2">
                                                    <input name="pis_config" type="text" id="pis_config" class="inputtexto" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getPis())) : "0.00")%>" size="5" align="right" >
                                                    <label>
                                                        <br><input name="embutir_pis" id="embutir_pis" type="checkbox" value="true" <%=(carregaconfig && jbean.isEmbutirPis() ? "checked" : "")%>>
                                                        Embutir PIS no CT-e
                                                    </label>
                                                </td>
                                                <td width="5%" class="TextoCampos">COFINS:</td>
                                                <td width="10%" class="CelulaZebra2">
                                                    <input name="cofins_config" type="text" id="cofins_config" class="inputtexto" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getCofins())) : "0.00")%>" size="5" align="right" >
                                                    <label>
                                                        <br><input name="embutir_cofins" id="embutir_cofins" type="checkbox" value="true" <%=(carregaconfig && jbean.isEmbutirCofins() ? "checked" : "")%>>
                                                        Embutir COFINS no CT-e
                                                    </label>
                                                </td>
                                                <td width="5%" class="TextoCampos">INSS:</td>
                                                <td width="10%" class="CelulaZebra2">
                                                    <input name="inss_config" type="text" id="inss_config" class="inputtexto" onBlur="javascript:seNaoFloatReset(this, '0.00');" value="<%=(carregaconfig ? vlrformat.format(Float.valueOf(jbean.getInss())) : "0.00")%>" size="5" align="right" >
                                                    <label>
                                                        <br><input name="embutirInss" id="embutirInss" type="checkbox" value="true" <%=(carregaconfig && jbean.isEmbutirInss() ? "checked" : "")%>>
                                                        Embutir INSS no CT-e
                                                    </label>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="celula">
                                        <div align="center">
                                            Outras Informações
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">
                                        <div align="center">
                                            <input type="checkbox" name="chk_gera_cnpj" id="chk_gera_cnpj" value="true" <%=(carregaconfig && jbean.isGerarCnpjIntegracaoContabil() ? "checked" : "")%>>
                                            Gerar Código CP2 na integração com o NG Contábil
                                        </div>
                                    </td>
                                    <td colspan="2" class="TextoCampos">
                                        <div align="center">
                                            <input type="checkbox" name="chk_gera_conta_reduzida" id="chk_gera_conta_reduzida" value="true" <%=(carregaconfig && jbean.isGeraIntegracaoContaReduzida() ? "checked" : "")%>>
                                            Gerar Arquivo de integração contábil com a conta reduzida
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">
                                        Considerar como Data da Baixa: 
                                    </td>
                                    <td class="CelulaZebra2">
                                        <select id="considerarDataBaixa" name="considerarDataBaixa" class="inputTexto" style="width: 180px">
                                            <option value="p" <%=carregaconfig && jbean.getConsiderarDataBaixa() != null && jbean.getConsiderarDataBaixa().trim().equals("p") ? "selected" : ""%>>Data do Pagamento</option>
                                            <option value="c" <%=carregaconfig && jbean.getConsiderarDataBaixa() != null && jbean.getConsiderarDataBaixa().trim().equals("c") ? "selected" : ""%>>Data da Conciliação</option>

                                        </select>                                                   
                                    </td>
                                    <td class="TextoCampos" colspan="2">
                                        <div style="text-align: left; padding-left: 10px; padding-top: 5px; padding-bottom: 5px;">
                                            <input type="checkbox" id="chkPagamentoRecebimentoTransitoriaFilial" name="chkPagamentoRecebimentoTransitoriaFilial"
                                                ${config.pagamentoRecebimentoTransitoriaFilial ? "checked" : ""}>

                                            <label for="chkPagamentoRecebimentoTransitoriaFilial">Ao realizar pagamentos ou
                                                recebimentos de uma filial com a conta bancária da outra filial, serão
                                                realizados 2 novos lançamentos em contas transitórias definidas no cadastro
                                                da filial. OBS: Habilitado apenas para integração com o sistema Fortes
                                                Contábil.</label>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="celula">
                                        <div align="center">
                                            Informa&ccedil;&otilde;es para Gera&ccedil;&atilde;o do EFD PIS/COFINS de Sa&iacute;da
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table width="100%" class="bordaFina">
                                            <tr>
                                                <td class="TextoCampos">
                                                    Contribui&ccedil;&atilde;o Social:
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <select id="contribuicaoSocial" name="contribuicaoSocial" class="inputTexto" style="width: 180px">
                                                        <option value="0">----Não Informado----</option>
                                                        <% for (ContribuicaoSocial contSocial : contribuicoesSociais) {%>
                                                        <option value="<%=contSocial.getId()%>" <%=carregaconfig && jbean.getContribuicaoSocial().getId() == contSocial.getId() ? "selected" : ""%> ><%=contSocial.getCodigo() + " - " + contSocial.getDescricao()%></option>
                                                        <% }%>
                                                    </select>
                                                </td>
                                                <td class="TextoCampos" >
                                                    Sit. Tribut&aacute;vel PIS/COFINS:
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <select id="situacaoTribPisCofins" name="situacaoTribPisCofins" class="inputTexto" style="width: 180px">
                                                        <% for (SituacaoTributavel sitTribPis : sitTribPisCofins) {%>
                                                        <option value="<%=sitTribPis.getId()%>" <%=carregaconfig && jbean.getSituacaoTribPisCofins().getId() == sitTribPis.getId() ? "selected" : ""%> ><%=sitTribPis.getCodigo() + " - " + sitTribPis.getDescricao()%></option>
                                                        <% }%>
                                                    </select>
                                                </td>
                                                <td class="TextoCampos" >
                                                    Critério de Escrit./Apuração
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <select id="criterioEscrituracao" name="criterioEscrituracao" class="inputTexto" style="width: 180px">
                                                        <option value="">----Não Informado----</option>
                                                        <option value="1" <%=carregaconfig && jbean.getCriterioEscrituracao() != null && jbean.getCriterioEscrituracao().trim().equals("1") ? "selected" : ""%>>Regime de Caixa &HorizontalLine; Escrituração consolidada</option>
                                                        <option value="2" <%=carregaconfig && jbean.getCriterioEscrituracao() != null && jbean.getCriterioEscrituracao().trim().equals("2") ? "selected" : ""%>>Regime de Competência &HorizontalLine; Escrituração consolidada</option>
                                                        <option value="9" <%=carregaconfig && jbean.getCriterioEscrituracao() != null && jbean.getCriterioEscrituracao().trim().equals("9") ? "selected" : ""%>>Regime de Competência &HorizontalLine; Escrituração detalhada</option>
                                                    </select>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </div>
                    <div class="panel" id="tab4">
                        <fieldset>  
                            <table width="100%" border="0" class="bordaFina" align="center">
                                
                                
                                <tr>
                                    <td colspan="4" class="tabela">
                                        <div align="center">
                                            Preferências para Recebimento de e-mail(s)
                                        </div>
                                    </td>
                                </tr>
<!--                                <tr>
                                    <td class="TextoCampos" colspan="1">
                                        E-mail para importação XML:
                                    </td>
                                    <td class="TextoCampos" colspan="3">
                                        <div align="left">

                                            <select name="emailImportacao" id="emailImportacao" class="inputtexto"  style="width: 110px;">

                                                 < %      //Carregando todas as contas cadastradas
                                                    
                                                    EmailBO emailbo = new EmailBO();
                                                    Consulta filtroImportacao = new Consulta();
                                                    StringBuilder sql2 = new StringBuilder();
                                                    StringBuilder sqlIportacao = new StringBuilder();
                                                    sqlIportacao.append(" and not ce.is_fatura");
                                                    filtroImportacao.setFiltrosAdicionais(sqlIportacao);
                                                    filtroImportacao.setCampoConsulta(" ce.mail_usuario ");
                                                    EmailBO emailbo2 = new EmailBO();
                                                    Collection<Email> emailImportacao = new ArrayList<Email>();
                                                    emailImportacao = emailbo.listar(filtroImportacao);
                                                %>
                                                <option value="0" selected>Selecione</option>
                                                < %
                                                    for (Email email : emailImportacao) {
                                                %>
                                                <option value="< %=email.getId()%>" < %=(jbean.getEmailImportacaoArquivoXmlId().getId() == email.getId() ? "selected" : "")%> >< %=email.getDescricao()%> </option>
                                                < %
                                                    }
                                                %>
                                            </select>
                                        </div>
                                    </td>
                                </tr>-->
                                <tr>
                                    <td class="CelulaZebra2" colspan="2">
                                        <input type="checkbox" name="isAtivarRecebimento" id="isAtivarRecebimento" onclick="alterarAtivarRecebimentoEmails();" <%= (carregaconfig && jbean.isIsAtivarRecebimento() ? "checked" : "" ) %>>
                                        <label for="isAtivarRecebimento">Ativar recebimento de e-mail automático</label>
                                    </td>
                                    <td class="TextoCampos">
                                        <div align="left">
                                            <label id="labelMinutosBaixarEmails">
                                                A cada  <input type="text" name="minutosBaixarEmails" id="minutosBaixarEmails" value="<%=(carregaconfig ? jbean.getMinutosBaixarEmails() : "60" )%>" class="inputtexto" size="4" maxlength="5" onchange="alterarQuantidadeMinutosBaixarEmails(this);"> minutos
                                            </label>
                                        </div>
                                    </td>
                                    <td class="CelulaZebra2">                                        
                                    </td>
                                </tr>
                                <tr>
                                    <td class="CelulaZebra2" colspan="4">
                                        <input type="checkbox" name="isBaixarApenasEntre" id="isBaixarApenasEntre" onclick="javaScript:alterarBaixarEmailsEntre();" <%= (carregaconfig && (jbean.isIsBaixarApenasEntre())? "checked" : "") %>>
                                        <label for="isBaixarApenasEntre">Baixar e-mail(s) apenas entre:</label>
                                    </td>
                                </tr>
                                <tr id="trHoraInicioFim">
                                    <td class="textoCampos">
                                        Hora inicial: 
                                    </td>
                                    <td class="CelulaZebra2">
                                        <input type="text" name="horaBaixarEmailInicio" id="horaBaixarEmailInicio" value="<%= (carregaconfig ? Apoio.getFormatTime(jbean.getHoraBaixaEmailInicio()) : "00:00") %>" size="5" class="inputtexto" onkeypress="mascaraHora(this)">
                                    </td>
                                    <td class="textoCampos">
                                        Hora final: 
                                    </td>
                                    <td class="CelulaZebra2">
                                        <input type="text" name="horaBaixarEmailFim" id="horaBaixarEmailFim" value="<%= (carregaconfig ? Apoio.getFormatTime(jbean.getHoraBaixaEmailFim()) : "00:00") %>" size="5" class="inputtexto" onkeypress="mascaraHora(this)">
                                    </td>
                                </tr>                                
                                <tr>
                                    <td colspan="4">
                                        <table width="100%" border="0" class="bordaFina">
                                            <tr>
                                                <td width="5%" class="CelulaZebra2NoAlign" align="center">
                                                    <img src="img/add.gif" border="0" title="Adicionar Email para Importação XML" class="imagemLink" style="vertical-align:middle;" onclick="addEmailImportacaoXml(listaEmailImportacaoXml, emailImportacaoXml);" />
                                                </td>
                                                <td width="95%" class="TextoCamposNoAlign" align="center">                                                    
                                                    <b>E-mail(s) para importação XML</b>
                                                </td>                                                
                                            </tr>
                                            <!--<tr>-->
                                            <input type="hidden" id="maxEmailImportacaoXml" name="maxEmailImportacaoXml" value="0"/>
                                            <tbody id="tbEmailImportacaoXml"></tbody>
                                            <!--</tr>-->
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="tabela">
                                        <div align="center">
                                            Preferências de envio de e-mails
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                <table width="100%" border="0" class="">
                                    <td class="TextoCampos" >
                                        E-mail para Entrega:
                                    </td>
                                    <td class="TextoCampos" >
                                        <div align="left">

                                            <select name="emailEntrega" class="inputtexto"  id="emailEntrega"  >

                                                <%      //Carregando todas as contas cadastradas
                                                    Consulta filtro = new Consulta();
                                                    EmailBO emailbo = new EmailBO();
                                                    StringBuilder sql = new StringBuilder();
                                                    sql.append(" and not ce.is_fatura");
                                                    filtro.setFiltrosAdicionais(sql);
                                                    filtro.setCampoConsulta(" ce.mail_usuario ");
                                                    filtro.setLimiteResultados(100);
                                                    Collection<Email> emailEntrega = new ArrayList<Email>();
                                                    emailEntrega = emailbo.listar(filtro);
                                                %>
                                                <option value="0" selected>Selecione</option>
                                                <%
                                                    for (Email email : emailEntrega) {
                                                %>
                                                <option value="<%=email.getId()%>" <%=(jbean.getEmailEntrega().getId() == email.getId() ? "selected" : "")%> ><%=email.getDescricao()%> </option>
                                                <%
                                                    }
                                                %>
                                            </select>
                                        </div>
                                    </td>
                                    <td class="TextoCampos" >
                                        E-mail para envio de Orçamentos e Coletas:
                                    </td>
                                    <td class="TextoCampos">
                                        <div align="left">
                                            <select name="emailOrcamento" class="inputtexto"  id="emailOrcamento"  >
                                                
                                                <%  //Carregando todas as contas cadastradas
                                                    Consulta filtroOrcamento = new Consulta();
                                                    EmailBO emailboOrca = new EmailBO();
                                                    StringBuilder sqlOrc = new StringBuilder();
                                                    sqlOrc.append(" and not ce.is_fatura");
                                                    filtroOrcamento.setFiltrosAdicionais(sqlOrc);
                                                    filtroOrcamento.setCampoConsulta(" ce.mail_usuario ");
                                                    filtroOrcamento.setLimiteResultados(100);
                                                    Collection<Email> emailOrcamento = new ArrayList<Email>();
                                                    emailOrcamento = emailboOrca.listar(filtro);
                                                %>
                                                
                                                <option value="0" selected>Selecione</option>
                                                <%
                                                    for (Email email : emailOrcamento) {
                                                %>
                                                <option value="<%=email.getId()%>" <%=(jbean.getEmailOrcamento().getId() == email.getId() ? "selected" : "")%> ><%=email.getDescricao()%> </option>
                                                <%
                                                    }
                                                %>
                                            </select>
                                        </div>
                                    </td>
                                    <td class="TextoCampos">
                                        E-mail para envio de EDI:
                                    </td>
                                    <td class="TextoCampos">
                                        <div align="left">                                            
                                            <select name="emailEDI" class="inputtexto"  id="emailEDI">
                                                
                                                <%  //Carregando todas as contas cadastradas
                                                    Consulta filtroEDI = new Consulta();
                                                    EmailBO emailboEDI = new EmailBO();
                                                    StringBuilder sqlEDI = new StringBuilder();
                                                    sqlEDI.append(" and not ce.is_fatura and ce.is_oculto is false ");
                                                    filtroEDI.setFiltrosAdicionais(sqlEDI);
                                                    filtroEDI.setCampoConsulta(" ce.mail_usuario ");
                                                    filtroEDI.setLimiteResultados(100);
                                                    Collection<Email> emailEDI = new ArrayList<Email>();
                                                    emailEDI = emailboEDI.listar(filtro);
                                                %>
                                                
                                                <option value="0" selected>Selecione</option>
                                                <%
                                                    for (Email email : emailEDI) {
                                                %>
                                                <option value="<%=email.getId()%>" <%=(jbean.getEmailEDI().getId() == email.getId() ? "selected" : "")%> ><%=email.getDescricao()%> </option>
                                                <%
                                                    }
                                                %>
                                            </select>
                                        </div>
                                    </td>
                                    <td class="TextoCampos" colspan="1">
                                        E-mail para Fatura:
                                    </td>
                                    <td class="TextoCampos" colspan="1">
                                        <div align="left">

                                            <select name="emailFatura" class="inputtexto"  id="emailFatura"  style="width: 110px;">

                                                <%      //Carregando todas as contas cadastradas

                                                    Consulta filtro1 = new Consulta();
                                                    StringBuilder sql1 = new StringBuilder();
                                                    sql1.append(" and ce.is_fatura");
                                                    filtro1.setFiltrosAdicionais(sql1);
                                                    filtro1.setCampoConsulta(" ce.mail_usuario ");
                                                    filtro1.setLimiteResultados(100);
                                                    Collection<Email> emailsFatura = new ArrayList<Email>();
                                                    emailsFatura = emailbo.listar(filtro1);
                                                %>

                                                <c:set var="emails_fatura" value="<%= emailsFatura %>"/>
                                                <option value="0" selected>Selecione</option>
                                                <%
                                                    for (Email email : emailsFatura) {
                                                        if (email.getMailNomeRemetente() != null || !email.getMailNomeRemetente().equals("")) {
                                                %>
                                                <option value="<%=email.getId()%>" <%=(jbean.getEmailFatura().getId() == email.getId() ? "selected" : "")%> ><%=email.getDescricao()%> </option>
                                                <%      }
                                                    }

                                                %>
                                            </select>
                                        </div>
                                    </td>
                                    </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos" colspan="2">
                                        <div align="center">
                                            <label>
                                                <input type="radio" name="preferenciaEmail" id="mesmo_tempo" value="a" <%=(jbean.getPreferenciaEnvioEmail() == "a" ? "checked " : "")%> onChange="alterarPreferenciaEmail(this.value);">Ao clicar em 'Enviar'
                                            </label>
                                        </div>
                                    </td>
                                    <td class="TextoCampos" colspan="2">
                                        <div align="center">
                                            <label>
                                                <input type="radio" name="preferenciaEmail" id="caixa_saida" value="b" <%=(jbean.getPreferenciaEnvioEmail() == "b" ? "checked " : "")%> onChange="alterarPreferenciaEmail(this.value);">Armazenar na caixa de saída e enviar lotes:
                                            </label>
                                            <label id="lblQtdEmailLotes" style="display: none">
                                                Qtd de Email em Lote:
                                                <input name="qtdEmailLote" type="text" id="qtdEmailLote" value="<%=(carregaconfig && jbean.getQtdEmailLote() != 0 ? jbean.getQtdEmailLote() : "0")%>" size="4" maxlength="8" class="inputtexto">                                            
                                                A cada:
                                                <input name="qtdTempoEmailLote" type="text" id="qtdTempoEmailLote" value="<%=(carregaconfig && jbean.getTempoEmailLote() != "" ? jbean.getTempoEmailLote() : "00:00")%>" onkeypress="mascaraHora(this)" size="4" maxlength="8" class="inputtexto">
                                            </label>
                                        </div>
                                    </td>
                                </tr>
                                <tr id="trPreferenciaEmail" style="display: none">
                                    <td class="TextoCampos" colspan="2"></td>
                                    <td class="TextoCampos" colspan="2">
                                        <div align="center">
                                            <label>                                            
                                                <input type="checkbox" name="chkEnviarEmailApenasEntre" id="chkEnviarEmailApenasEntre" value="true" <%=(carregaconfig && jbean.getIsEnviarEntreHorario() ? "checked" : "")%>>
                                                Enviar e-mails apenas entre: </label> 
                                            <label for="horaInicialEmailLote">Hora Inicial:</label>
                                            <input name="horaInicialEmailLote" type="text" onkeyup="mascaraHora(this)" id="horaInicialEmailLote" value="<%=(carregaconfig && jbean.getHoraInicialEmailLote() != "" ? jbean.getHoraInicialEmailLote() : hora)%>" size="4" maxlength="8" class="inputtexto">
                                            <label for="horaFinalEmailLote">Hora Final:</label>
                                            <input name="horaFinalEmailLote" type="text" onkeyup="mascaraHora(this)" id="horaFinalEmailLote" value="<%=(carregaconfig && jbean.getHoraFinalEmailLote() != "" ? jbean.getHoraFinalEmailLote() : hora)%>" size="4" maxlength="8" class="inputtexto">                                            
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos" colspan="1">
                                        <label for="qtdDiasArmazenarAnexos">Qtd de dias que o anexo ficará armazenado:</label>
                                    </td>
                                    <td class="CelulaZebra2" colspan="3">
                                        <input id="qtdDiasArmazenarAnexos" type="text" name="qtdDiasArmazenarAnexos" value="<%=(carregaconfig ? jbean.getQtdDiasArmazenarAnexos() : "30")%>" class="inputtexto" size="4" maxlength="8">                                        
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos" colspan="1" width="40%">
                                        <div align="center">
                                            <input type="checkbox" name="chkEnvioEmailAutomaticoVencimentoFatura"
                                                   id="chkEnvioEmailAutomaticoVencimentoFatura"
                                            ${config.ativarEnvioVencimentoFatura ? "checked": ""}>
                                            <label for="chkEnvioEmailAutomaticoVencimentoFatura">Ativar Envio de e-mail para clientes lembrando do vencimento de fatura/boleto.</label>
                                        </div>
                                    </td>
                                    <td class="TextoCampos" colspan="1" width="25%">
                                        <div align="center">
                                            <label for="selectEmailVencimentoFatura">E-mail para envio:</label>
                                            <select name="selectEmailVencimentoFatura" id="selectEmailVencimentoFatura" class="inputtexto">
                                                <option value="0" ${config.contaEmailVencimentoFatura.id eq 0 ? "selected" : ""}>Selecione</option>

                                                <c:forEach var="email" items="${emails_fatura}">
                                                    <option value="${email.id}" ${config.contaEmailVencimentoFatura.id eq email.id ? "selected" : ""}>${email.descricao}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                    </td>
                                    <td class="TextoCampos" colspan="2">
                                        <div align="center">
                                            <label for="inpHoraExecucaoEmailVencimentoFatura">Essa função será executada diariamente às:</label>
                                            <input type="text" class="inputtexto" id="inpHoraExecucaoEmailVencimentoFatura" name="inpHoraExecucaoEmailVencimentoFatura"
                                            size="5" maxlength="5" onkeyup="mascaraHora(this)" value="${config.horaEnvioEmailVencimentoFatura == null ? "" : config.horaEnvioEmailVencimentoFatura}">
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos" colspan="1">
                                        <label >Link Webtrans ( Rastreamento de fatura / boleto ): </label>
                                    </td>
                                    <td class="CelulaZebra2" colspan="3">
                                        <input id="linkWebtransRastreioFatura" type="text" maxlength="150" name="linkWebtransRastreioFatura" value="<%=(carregaconfig ? jbean.getLinkWebtransRastreioFatura(): "")%>" class="inputtexto" size="70">
                                    </td>
                                </tr>
                                <tr style="display: none">
                                    <td colspan="4" class="tabela">
                                        <div align="center">
                                            Mensagem CT-e
                                        </div>
                                    </td>
                                </tr>
                                 <tr style="display: none">
                                    <td colspan="4">
                                        <table width="100%">
                                            <tr>
                                                <td class="celula" colspan="6">
                                                    <div align="center">
                                                        Vari&aacute;veis
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" width="16%">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@nota_fiscal','mensagemCtrc')">@@nota_fiscal</a>
                                                </td>
                                                <td class="CelulaZebra2" width="20%">
                                                    Nota Fiscal
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@ctrc_','mensagemCtrc')">@@ctrc</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    CT-e
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@emissao_ctrc','mensagemCtrc')">@@emissao_ctrc</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Emiss&atilde;o CT-e
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@previsao_entrega','mensagemCtrc')">@@previsao_entrega</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Previs&atilde;o Entrega
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@nome_cliente','mensagemCtrc')">@@nome_cliente</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Nome Cliente
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cnpj_cliente','mensagemCtrc')">@@cnpj_cliente</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    CNPJ Cliente
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@nome_transportadora','mensagemCtrc')">@@nome_transportadora</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Nome Transportadora
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@remetente','mensagemCtrc')">@@remetente</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Remetente
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@destinatario','mensagemCtrc')">@@destinatario</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Destinat&aacute;rio
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@volume','mensagemCtrc')">@@volume</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Volume
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@peso','mensagemCtrc')">@@peso</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Peso
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@valor_mercadoria','mensagemCtrc')">@@valor_mercadoria</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Valor da Mercadoria
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@valor_frete','mensagemCtrc')">@@valor_frete</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Valor Frete
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cidade_destino','mensagemCtrc')">@@cidade_destino</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Cidade do Destinat&aacute;rio
                                                </td>
                                                <td class="CelulaZebra2" >

                                                </td>
                                                <td class="CelulaZebra2" >

                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                 <tr style="display: none">
                                    <td class="celula" colspan="4">
                                        <div align="center">
                                            Mensagem
                                        </div>
                                    </td>
                                </tr>
                                 <tr style="display: none">
                                    <td class="CelulaZebra2" colspan="4" align="center">
                                        <div align="center">
                                            <textarea cols="80" rows="15" id="mensagemCtrc" name="mensagemCtrc" style="width: 80%"><%=(carregaconfig ? jbean.getMensagemCtrc() : "")%></textarea>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="tabela">
                                        <div align="center">
                                            Mensagem Manifesto
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table width="100%">
                                            <tr>
                                                <td class="celula" colspan="6">
                                                    <div align="center">
                                                        Vari&aacute;veis
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" width="20%">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@nota_fiscal','mensagemManifesto')">@@nota_fiscal</a>
                                                </td>
                                                <td class="CelulaZebra2" width="18%">
                                                    Nota Fiscal
                                                </td>
                                                <td class="CelulaZebra2" width="18%">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@ctrc','mensagemManifesto')">@@ctrc</a>
                                                </td>
                                                <td class="CelulaZebra2" width="20%">
                                                    CT-e
                                                </td>
                                                <td class="CelulaZebra2" width="18%">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@emissao_ctrc','mensagemManifesto')">@@emissao_ctrc</a>
                                                </td>
                                                <td class="CelulaZebra2" width="20%">
                                                    Emiss&atilde;o CT-e
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@previsao_entrega','mensagemManifesto')">@@previsao_entrega</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Previs&atilde;o Entrega
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@nome_cliente','mensagemManifesto')">@@nome_cliente</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Nome Cliente
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cnpj_cliente','mensagemManifesto')">@@cnpj_cliente</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    CNPJ Cliente
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@nome_transportadora','mensagemManifesto')">@@nome_transportadora</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Nome Transportadora
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@remetente','mensagemManifesto')">@@remetente</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Remetente
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@detinatario','mensagemManifesto')">@@detinatario</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Detinat&aacute;rio
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@volume','mensagemManifesto')">@@volume</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Volume
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@peso','mensagemManifesto')">@@peso</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Peso
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@valor_mercadoria','mensagemManifesto')">@@valor_mercadoria</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Valor da Mercadoria
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@valor_frete','mensagemManifesto')">@@valor_frete</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Valor Frete
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cidade_destino','mensagemManifesto')">@@cidade_destino</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Cidade do Destinat&aacute;rio
                                                </td>
                                                <td class="CelulaZebra2" >

                                                </td>
                                                <td class="CelulaZebra2" >

                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="celula" colspan="4">
                                        <div align="center">
                                            Mensagem
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="CelulaZebra2" colspan="4" align="center">
                                        <div align="center">
                                            <textarea cols="80" rows="15" id="mensagemManifesto" name="mensagemManifesto" style="width: 80%"><%=(carregaconfig ? jbean.getMensagemManifesto() : "")%></textarea>
                                        </div>                                    
                                    </td>
                                </tr>                                
                                <tr>
                                    <td colspan="4" class="tabela">
                                        <div align="center">
                                            Mensagem Entrega
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table width="100%">
                                            <tr>
                                                <td class="celula" colspan="6">
                                                    <div align="center">
                                                        Vari&aacute;veis
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" width="18%">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@nota_fiscal','mensagemEntrega')">@@nota_fiscal</a>
                                                </td>
                                                <td class="CelulaZebra2" width="20%">
                                                    Nota Fiscal
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@ctrc','mensagemEntrega')">@@ctrc</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    CT-e
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@emissao_ctrc','mensagemEntrega')">@@emissao_ctrc</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Emiss&atilde;o CT-e
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@previsao_entrega','mensagemEntrega')">@@previsao_entrega</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Previs&atilde;o Entrega
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@data_entrega','mensagemEntrega')">@@data_entrega</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Data Entrega
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@data_chegada','mensagemEntrega')">@@data_chegada</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Data Chegada
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@nome_cliente','mensagemEntrega')">@@nome_cliente</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Nome Cliente
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cnpj_cliente','mensagemEntrega')">@@cnpj_cliente</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    CNPJ Cliente
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@nome_transportadora','mensagemEntrega')">@@nome_transportadora</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Nome Transportadora
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@observacao_entrega','mensagemEntrega')">@@observacao_entrega</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Observa&ccedil;&atilde;o Entrega
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@remetente','mensagemEntrega')">@@remetente</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Remetente
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@destinatario','mensagemEntrega')">@@destinatario</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Destinat&aacute;rio
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@volume','mensagemEntrega')">@@volume</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Volume
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@peso','mensagemEntrega')">@@peso</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Peso
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@valor_mercadoria','mensagemEntrega')">@@valor_mercadoria</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Valor da Mercadoria
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@valor_frete','mensagemEntrega')">@@valor_frete</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Valor Frete
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cidade_destino','mensagemEntrega')">@@cidade_destino</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Cidade do Destinat&aacute;rio
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@pedido_nf','mensagemEntrega')">@@pedido_nf</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Número do Pedido da NF
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="celulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@numero_carga','mensagemEntrega')">@@numero_carga</a>
                                                </td>
                                                <td class="CelulaZebra2"  colspan="8">
                                                    Número da Carga
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>

                                <tr>
                                    <td class="celula" colspan="4" align="center">
                                        <div align="center">Mensagem</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="CelulaZebra2" colspan="4">
                                        <div align="center">
                                            <textarea cols="80" rows="15" id="mensagemEntrega" name="mensagemEntrega" style="width: 80%"><%=(carregaconfig ? jbean.getMensagemEntrega() : "")%></textarea>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="tabela">
                                        <div align="center">
                                            Mensagem CT-e
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table width="100%">
                                            <tr>
                                                <td class="celula" colspan="6">
                                                    <div align="center">
                                                        Vari&aacute;veis
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" width="18%">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cte','mensagemCte')">@@cte</a>
                                                </td>
                                                <td class="CelulaZebra2" width="20%">
                                                    Número do CT-e
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@chave_de_acesso','mensagemCte')">@@chave_de_acesso</a>
                                                </td>
                                                <td class="CelulaZebra2" width="20%">
                                                    Chave de Acesso
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@emissao_cte','mensagemCte')">@@emissao_cte</a>
                                                </td>     
                                                <td class="CelulaZebra2" width="20%">
                                                    Data da emissão do Ct-e
                                                </td>
                                            </tr>
                                            <tr>
                                                <!--                       //                          29-10-2013 - Incluso @@nota_fiscal mensagemCte - Paulo-->
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@nota_fiscal','mensagemCte')">@@nota_fiscal</a>
                                                </td>     
                                                <td class="CelulaZebra2" width="20%">
                                                    Nota Fiscal
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@previsao_entrega','mensagemCte')">@@previsao_entrega</a>
                                                </td>     
                                                <td class="CelulaZebra2" width="20%">
                                                    Previsão entrega do CT-e
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@destinatario','mensagemCte')">@@destinatario</a>
                                                </td>     
                                                <td class="CelulaZebra2" width="20%">
                                                    Destinatário do CT-e
                                                </td>
                                            </tr>
                                            <tr>
                                                <!--                                                30-10-2013 - Paulo-->
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@volume','mensagemCte')">@@volume</a>
                                                </td>     
                                                <td class="CelulaZebra2" width="20%">
                                                    Total Volumes
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@peso','mensagemCte')">@@peso</a>
                                                </td>     
                                                <td class="CelulaZebra2" width="20%">
                                                    Total Peso
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cidade_destino','mensagemCte')">@@cidade_destino</a>
                                                </td>     
                                                <td class="CelulaZebra2" width="20%">
                                                    Cidade Destino
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="celula" colspan="4" align="center">
                                        <div align="center">Mensagem</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="CelulaZebra2" colspan="4">
                                        <div align="center">
                                            <textarea cols="80" rows="15" id="mensagemCte" name="mensagemCte" style="width: 80%"><%=(carregaconfig ? jbean.getMensagemCte() : "")%></textarea>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="tabela">
                                        <div align="center">
                                            Mensagem Boleto
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table width="100%">
                                            <tr>
                                                <td class="celula" colspan="6">
                                                    <div align="center">
                                                        Vari&aacute;veis
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" width="18%">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@vencimento_fatura','mensagemBoleto')">@@vencimento_fatura</a>
                                                </td>
                                                <td class="CelulaZebra2" width="20%">
                                                    Vencimento da Fatura
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@data_primeiro_cte','mensagemBoleto')">@@data_primeiro_cte</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Data do primeiro CT-e
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@data_ultimo_cte','mensagemBoleto')">@@data_ultimo_cte</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Data do último CT-e
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" width="18%">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@numero_fatura','mensagemBoleto')">@@numero_fatura</a>
                                                </td>
                                                <td class="CelulaZebra2" width="20%">
                                                    Número da Fatura
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cliente','mensagemBoleto')">@@cliente</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Nome do Cliente
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cnpj_cliente','mensagemBoleto')">@@cnpj_cliente</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    CNPJ do Cliente
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" width="18%">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@login_cliente','mensagemBoleto')">@@login_cliente</a>
                                                </td>
                                                <td class="CelulaZebra2" width="20%">
                                                    Login Módulo do Cliente
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@senha_cliente','mensagemBoleto')">@@senha_cliente</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Senha Módulo do Cliente
                                                </td>
                                                <td class="CelulaZebra2" >
                                                </td>
                                                <td class="CelulaZebra2" >
                                                </td>
                                            </tr>

                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="celula" colspan="4" align="center">
                                        <div align="center">Mensagem</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="CelulaZebra2" colspan="4">
                                        <div align="center">
                                            <textarea cols="80" rows="15" id="mensagemBoleto" name="mensagemBoleto" style="width: 80%"><%=(carregaconfig ? jbean.getMensagemBoleto() : "")%></textarea>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="tabela">
                                        <div align="center">
                                            Mensagem Cobrança
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table width="100%">
                                            <tr>
                                                <td class="celula" colspan="6">
                                                    <div align="center">
                                                        Vari&aacute;veis
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr style="display: none">
                                                <td class="CelulaZebra2" width="18%">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@vencimento_fatura','mensagemCobranca')">@@vencimento_fatura</a>
                                                </td>
                                                <td class="CelulaZebra2" width="20%">
                                                    Vencimento da Fatura
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@data_primeiro_cte','mensagemCobranca')">@@data_primeiro_cte</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Data do primeiro CT-e
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@data_ultimo_cte','mensagemCobranca')">@@data_ultimo_cte</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Data do último CT-e
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cliente','mensagemCobranca')">@@cliente</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Nome do Cliente
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cnpj_cliente','mensagemCobranca')">@@cnpj_cliente</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    CNPJ do Cliente
                                                </td>
<!--                                                <td class="CelulaZebra2" width="18%">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@numero_fatura','mensagemCobranca')">@@numero_fatura</a>
                                                </td>
                                                <td class="CelulaZebra2" width="20%">
                                                    Número da Fatura
                                                </td>-->
                                            </tr>

                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="celula" colspan="4" align="center">
                                        <div align="center">Mensagem</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="CelulaZebra2" colspan="4">
                                        <div align="center">
                                            <textarea cols="80" rows="15" id="mensagemCobranca" name="mensagemCobranca" style="width: 80%"><%=(carregaconfig ? jbean.getMensagemCobranca(): "")%></textarea>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="tabela">
                                        <div align="center">
                                            <label for="inpMensagemEmailVencimentoFatura">Mensagem do e-mail para
                                                lembrete de vencimento</label>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table width="100%">
                                            <tr>
                                                <td class="celula" colspan="6">
                                                    <div align="center">
                                                        Variáveis
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" width="18%">
                                                    <a style="text-decoration:none"
                                                       href="javascript:concatMensEmail('@@vencimento_fatura','inpMensagemEmailVencimentoFatura')">@@vencimento_fatura</a>
                                                </td>
                                                <td class="CelulaZebra2" width="20%">
                                                    Vencimento da Fatura
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none"
                                                       href="javascript:concatMensEmail('@@numero_fatura','inpMensagemEmailVencimentoFatura')">@@numero_fatura</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Número da Fatura
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none"
                                                       href="javascript:concatMensEmail('@@cliente','inpMensagemEmailVencimentoFatura')">@@cliente</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Nome do Cliente
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none"
                                                       href="javascript:concatMensEmail('@@cnpj_cliente','inpMensagemEmailVencimentoFatura')">@@cnpj_cliente</a>
                                                </td>
                                                <td class="CelulaZebra2" colspan="5">
                                                    CNPJ do Cliente
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="celula" colspan="4" align="center">
                                        <div align="center">Mensagem</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="CelulaZebra2" colspan="4">
                                        <div align="center">
                                            <textarea cols="80" rows="15" id="inpMensagemEmailVencimentoFatura"
                                                      name="inpMensagemEmailVencimentoFatura"
                                                      style="width: 80%">${config.mensagemEmailVencimentoFatura}</textarea>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="tabela">
                                        <div align="center">
                                            Mensagem Manifesto Para Representantes
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table width="100%">
                                            <tr>
                                                <td class="celula" colspan="6">
                                                    <div align="center">
                                                        Vari&aacute;veis
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration: none" href="javascript:concatMensEmail('@@transportadora','mensagemManifestoRepresentante')">@@transportadora</a>
                                                </td>                                    
                                                <td class="CelulaZebra2">
                                                    Razao Social da filial origem
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration: none" href="javascript:concatMensEmail('@@representante','mensagemManifestoRepresentante')">@@representante</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Razao Social do representante de destino
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration: none" href="javascript:concatMensEmail('@@origem','mensagemManifestoRepresentante')">@@origem</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Cidade de origem do manifesto
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration: none" href="javascript:concatMensEmail('@@destino','mensagemManifestoRepresentante')">@@destino</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Cidade de destino do manifesto
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration: none" href="javascript:concatMensEmail('@@peso','mensagemManifestoRepresentante')">@@peso</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Total do peso do manifesto
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration: none" href="javascript:concatMensEmail('@@volumes','mensagemManifestoRepresentante')">@@volumes</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Total de volumes do manifesto
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration: none" href="javascript:concatMensEmail('@@valor_mercadoria','mensagemManifestoRepresentante')">@@valor_mercadoria</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Valor Total das mercadorias do manifesto
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration: none" href="javascript:concatMensEmail('@@emissao','mensagemManifestoRepresentante')">@@emissao</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Data de emissão do manifesto
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration: none" href="javascript:concatMensEmail('@@chegada','mensagemManifestoRepresentante')">@@chegada</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Data de previsao de chegada do manifesto
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration: none" href="javascript:concatMensEmail('@@voo','mensagemManifestoRepresentante')">@@voo</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Numero do voo
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration: none" href="javascript:concatMensEmail('@@cia_aerea','mensagemManifestoRepresentante')">@@cia_aerea</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Companhia aérea
                                                </td>
                                                <td class="CelulaZebra2"></td>
                                                <td class="celulaZebra2"></td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="celula" colspan="4" align="center">
                                        <div align="center">Mensagem</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="CelulaZebra2" colspan="4">
                                        <div align="center">
                                            <textarea cols="80" rows="15" id="mensagemManifestoRepresentante" name="mensagemManifestoRepresentante" style="width: 80%"><%=(carregaconfig ? jbean.getMensagemManifestoRepresentante() : "")%></textarea>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="tabela">
                                        <div align="center">
                                            Mensagem Chegada
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table width="100%">
                                            <tr>
                                                <td class="celula" colspan="6">
                                                    <div align="center">
                                                        Vari&aacute;veis
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" width="18%">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@nota_fiscal','mensagemChegada')">@@nota_fiscal</a>
                                                </td>
                                                <td class="CelulaZebra2" width="20%">
                                                    Nota Fiscal
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@ctrc','mensagemChegada')">@@ctrc</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    CT-e
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@emissao_ctrc','mensagemChegada')">@@emissao_ctrc</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Emiss&atilde;o CT-e
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@previsao_entrega','mensagemChegada')">@@previsao_entrega</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Previs&atilde;o Entrega
                                                </td>
                                                 <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@pedido_nf','mensagemChegada')">@@pedido_nf</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Número do Pedido da NF
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@data_chegada','mensagemChegada')">@@data_chegada</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Data Chegada
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@nome_cliente','mensagemChegada')">@@nome_cliente</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Nome Cliente
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cnpj_cliente','mensagemChegada')">@@cnpj_cliente</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    CNPJ Cliente
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@nome_transportadora','mensagemChegada')">@@nome_transportadora</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Nome Transportadora
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@observacao_entrega','mensagemChegada')">@@observacao_entrega</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Observa&ccedil;&atilde;o Entrega
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@remetente','mensagemChegada')">@@remetente</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Remetente
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@destinatario','mensagemChegada')">@@destinatario</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Destinat&aacute;rio
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@volume','mensagemChegada')">@@volume</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Volume
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@peso','mensagemChegada')">@@peso</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Peso
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@valor_mercadoria','mensagemChegada')">@@valor_mercadoria</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Valor da Mercadoria
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@valor_frete','mensagemChegada')">@@valor_frete</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Valor Frete
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cidade_destino','mensagemChegada')">@@cidade_destino</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Cidade do Destinat&aacute;rio
                                                </td>
                                                <td class="CelulaZebra2" >
                                                </td>
                                                <td class="CelulaZebra2" >
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>

                                <tr>
                                    <td class="celula" colspan="4" align="center">
                                        <div align="center">Mensagem</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="CelulaZebra2" colspan="4">
                                        <div align="center">
                                            <textarea cols="80" rows="15" id="mensagemChegada" name="mensagemChegada" style="width: 80%"><%=(carregaconfig ? jbean.getMensagemChegada() : "")%></textarea>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="tabela">
                                        <div align="center">
                                            Mensagem Ocorrência
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table width="100%">
                                            <tr>
                                                <td class="celula" colspan="6">
                                                    <div align="center">
                                                        Vari&aacute;veis
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" width="18%">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@nota_fiscal','mensagemOcorrencia')">@@nota_fiscal</a>
                                                </td>
                                                <td class="CelulaZebra2" width="20%">
                                                    Nota Fiscal
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@ctrc','mensagemOcorrencia')">@@ctrc</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    CT-e
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@emissao_ctrc','mensagemOcorrencia')">@@emissao_ctrc</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Emiss&atilde;o CT-e
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@data_ocorrencia','mensagemOcorrencia')">@@data_ocorrencia</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Data da Ocorrência
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@data_chegada','mensagemOcorrencia')">@@data_chegada</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Data Chegada
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@nome_cliente','mensagemOcorrencia')">@@nome_cliente</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Nome Cliente
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cnpj_cliente','mensagemOcorrencia')">@@cnpj_cliente</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    CNPJ Cliente
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@codigo_ocorrencia','mensagemOcorrencia')">@@codigo_ocorrencia</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Código Ocorrência
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@observacao_ocorrencia','mensagemOcorrencia')">@@observacao_ocorrencia</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Observa&ccedil;&atilde;o Ocorrência
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@descricao_ocorrencia','mensagemOcorrencia')">@@descricao_ocorrencia</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Descrição Ocorrência
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@destinatario','mensagemOcorrencia')">@@destinatario</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Destinat&aacute;rio
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@volume','mensagemOcorrencia')">@@volume</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Volume
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@peso','mensagemOcorrencia')">@@peso</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Peso
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@valor_mercadoria','mensagemOcorrencia')">@@valor_mercadoria</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Valor da Mercadoria
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@valor_frete','mensagemOcorrencia')">@@valor_frete</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Valor Frete
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cidade_destino','mensagemOcorrencia')">@@cidade_destino</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Cidade do Destinat&aacute;rio
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@pedido_nf','mensagemOcorrencia')">@@pedido_nf</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Número do Pedido da NF
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@hora_ocorrencia','mensagemOcorrencia')">@@hora_ocorrencia</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Hora da Ocorrência
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@remetente','mensagemOcorrencia')">@@remetente</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Nome do Remetente
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@recebedor','mensagemOcorrencia')">@@recebedor</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Nome do Recebedor
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cidade_recebedor','mensagemOcorrencia')">@@cidade_recebedor</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Cidade do Recebedor
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>

                                <tr>
                                    <td class="celula" colspan="4" align="center">
                                        <div align="center">Mensagem</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="CelulaZebra2" colspan="4">
                                        <div align="center">
                                            <textarea cols="80" rows="15" id="mensagemOcorrencia" name="mensagemOcorrencia" style="width: 80%"><%=(carregaconfig ? jbean.getMensagemOcorrencia() : "")%></textarea>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="tabela">
                                        <div align="center">
                                            Mensagem NFS-e
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table width="100%">
                                            <tr>
                                                <td class="celula" colspan="8">
                                                    <div align="center">
                                                        Vari&aacute;veis
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@emissao_nfse','mensagemNfse')">@@emissao_nfse</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Emiss&atilde;o NFS-e
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@destinatario','mensagemNfse')">@@destinatario</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Destinat&aacute;rio
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cidade_destino','mensagemNfse')">@@cidade_destino</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Cidade do Destinat&aacute;rio
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@nfse','mensagemNfse')">@@nfse</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    NFS-e
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="celula" colspan="4">
                                        <div align="center">
                                            Mensagem
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="CelulaZebra2" colspan="4" align="center">
                                        <div align="center">
                                            <textarea cols="80" rows="15" id="mensagemNfse" name="mensagemNfse" style="width: 80%"><%=(carregaconfig ? jbean.getMensagemNfse() : "")%></textarea>
                                        </div>
                                    </td>
                                </tr>
                                
                                <tr>
                                    <td colspan="4" class="tabela">
                                        <div align="center">
                                            Mensagem Orçamento
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table width="100%">
                                            <tr>
                                                <td class="celula" colspan="8">
                                                    <div align="center">
                                                        Vari&aacute;veis
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@remetente','mensagemOrcamento')">@@remetente</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Remetente
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@destinatario','mensagemOrcamento')">@@destinatario</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Destinat&aacute;rio
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cidade_origem','mensagemOrcamento')">@@cidade_origem</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Cidade do Origem
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@uf_origem','mensagemOrcamento')">@@uf_origem</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    UF de Origem
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cidade_destino','mensagemOrcamento')">@@cidade_destino</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Cidade do Destino
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@uf_destino','mensagemOrcamento')">@@uf_destino</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    UF de Destino
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@valor_total_orcamento','mensagemOrcamento')">@@valor_total_orcamento</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Valor total do Orçamento
                                                </td>
                                                <td class="CelulaZebra2">
                                                </td>
                                                <td class="CelulaZebra2">
                                                </td>
                                                <td class="CelulaZebra2">
                                                </td>
                                                <td class="CelulaZebra2">
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="celula" colspan="4">
                                        <div align="center">
                                            Mensagem
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="CelulaZebra2" colspan="4" align="center">
                                        <div align="center">
                                            <textarea cols="80" rows="15" id="mensagemOrcamento" name="mensagemOrcamento" style="width: 80%"><%=(carregaconfig ? jbean.getMensagemOrcamento() : "")%></textarea>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" class="tabela">
                                        <div align="center">
                                            Mensagem Coleta para Representantes
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table width="100%">
                                            <tr>
                                                <td class="celula" colspan="8">
                                                    <div align="center">
                                                        Vari&aacute;veis
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" style="width: 12.5%;">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@numero','mensagemColetaRepresentante')">@@numero</a>
                                                </td>
                                                <td class="CelulaZebra2" style="width: 12.5%;">
                                                    Número da Coleta
                                                </td>
                                                <td class="CelulaZebra2" style="width: 12.5%;">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@remetente','mensagemColetaRepresentante')">@@remetente</a>
                                                </td>
                                                <td class="CelulaZebra2" style="width: 12.5%;">
                                                    Remetente
                                                </td>
                                                <td class="CelulaZebra2" style="width: 12.5%;">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@destinatario','mensagemColetaRepresentante')">@@destinatario</a>
                                                </td>
                                                <td class="CelulaZebra2" style="width: 12.5%;">
                                                    Destinat&aacute;rio
                                                </td>
                                                <td class="CelulaZebra2" style="width: 12.5%;">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cidade_origem','mensagemColetaRepresentante')">@@cidade_origem</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Cidade do Origem
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@uf_origem','mensagemColetaRepresentante')">@@uf_origem</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    UF de Origem
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@cidade_destino','mensagemColetaRepresentante')">@@cidade_destino</a>
                                                </td>
                                                <td class="CelulaZebra2" >
                                                    Cidade do Destino
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@uf_destino','mensagemColetaRepresentante')">@@uf_destino</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    UF de Destino
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@contato','mensagemColetaRepresentante')">@@contato</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Nome de Contato
                                                </td>
                                            </tr>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@pedido','mensagemColetaRepresentante')">@@pedido</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Numero do Pedido
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@solicitacao','mensagemColetaRepresentante')">@@solicitacao</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Data de Solicitacao
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@programada','mensagemColetaRepresentante')">@@programada</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Data de programação
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@hora_programada','mensagemColetaRepresentante')">@@hora_programada</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Hora de Programação
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@local_coleta','mensagemColetaRepresentante')">@@local_coleta</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Local da Coleta (Endereço, bairro, cidade, UF)
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@ponto_refererencia','mensagemColetaRepresentante')">@@ponto_refererencia</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Ponto de Referência
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@observacao','mensagemColetaRepresentante')">@@observacao</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Observação
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@peso','mensagemColetaRepresentante')">@@peso</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Peso Solicitado
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@volume','mensagemColetaRepresentante')">@@volume</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Volumes Solicitados
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@valor_nf','mensagemColetaRepresentante')">@@valor_nf</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Valor Notas
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@conteudo','mensagemColetaRepresentante')">@@conteudo</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Conteudo
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <a style="text-decoration:none" href="javascript:concatMensEmail('@@especie','mensagemColetaRepresentante')">@@especie</a>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    Embalagem/Espécie
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="celula" colspan="4">
                                        <div align="center">
                                            Mensagem
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="CelulaZebra2" colspan="4" align="center">
                                        <div align="center">
                                            <textarea cols="80" rows="15" id="mensagemColetaRepresentante" name="mensagemColetaRepresentante" style="width: 80%"><%=(carregaconfig ? jbean.getMensagemColetaRepresentante() : "")%></textarea>
                                        </div>
                                    </td>
                                </tr>
                                
                            </table>
                        </fieldset>
                    </div>
            </div>
            <div class="panel" id='tab8' style="width:85%" >
                <table width="100%" border="0" class="bordaFina" align="center">
                    <tr>
                        <td colspan="4" class="tabela">
                            <div align="center">
                                Observações padrões para lançamento de contrato comercial
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos" colspan="3" >
                            Observações do contrato:
                        </td>
                        <td class="CelulaZebra2" colspan="6" >
                            <textarea cols="50" rows="6" class="inputtexto" id="observacoesContrato" name="observacoesContrato" ><%=(carregaconfig ? jbean.getObservacoesContrato(): "")%></textarea>
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos" colspan="3" >
                            Condições de pagamento:
                        </td>
                        <td class="CelulaZebra2" colspan="6" >
                            <textarea cols="50" rows="6" class="inputtexto" id="condicoesPagamento" name="condicoesPagamento" ><%=(carregaconfig ? jbean.getCondicoesPagamento(): "")%></textarea>
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos" colspan="3" >
                            Observações gerais:
                        </td>
                        <td class="CelulaZebra2" colspan="6" >
                            <textarea cols="50" rows="6" class="inputtexto" id="observacoesGerais" name="observacoesGerais" ><%=(carregaconfig ? jbean.getObservacoesGerais(): "")%></textarea>
                        </td>
                    </tr>
                </table>
            </div>
        </form>
                        <div class="panel" id='tab6' style="width:85%" >
                        <form method="post" id="formImagem" target="pop" enctype="multipart/form-data">
                        <table width="100%" border="0" class="bordaFina" align="center">
                            <tr>
                                <td colspan="4" class="tabela">
                                    <div align="center">
                                        Preferências gerais
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos" colspan="2">
                                    Logomarca da tela Principal:
                                </td>
                                <td class="CelulaZebra2" colspan="2">
                                    <input type="file" onchange="carregarImagem()" class="inputTexto" id="carregarImg" name="carregarImg">
                                    <img id="LOGO_IMG" width="81px" height="50px" style="display: none" name="imagem"/>
                                </td>
                            </tr>
                             <tr>
                                 <td class="TextoCampos" colspan="2" style="padding:5px;">Tema:</td> 
                                 <td class="CelulaZebra2" colspan="2">  
                                     <select id="tema" name="tema" onchange="corTema();copiarParaFormPrincipal(this.value,'valorTema')">
                                         <option value="1" <%=(carregaconfig && jbean.getTipoTema().getValor() == 1 ? "selected" : "")%>>Azul</option> 
                                         <option value="2" <%=(carregaconfig && jbean.getTipoTema().getValor() == 2 ? "selected" : "")%>>Cinza</option>
                                         <option value="3" <%=(carregaconfig && jbean.getTipoTema().getValor() == 3 ? "selected" : "")%>>Verde</option>
                                         <option value="4" <%=(carregaconfig && jbean.getTipoTema().getValor() == 4 ? "selected" : "")%>>Marrom</option>
                                     </select>
                                     <span id="corTema" name="corTema" style="padding: 6px; width: 40px; display:inline-block;" ></span>
                                 </td>
                            </tr>
                            <tr>
                                <td colspan="4" class="tabela">
                                    <div align="center">
                                        Configuração de backup
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">
                                    Quantidade de dias até avisar:
                                </td>
                                <td class="celulaZebra2">
                                    <input type="text" name="qtdDiasAvisoBackup" id="qtdDiasAvisoBackup" value="<%= (carregaconfig ? jbean.getQuantidadeDiasAvisoBackup() : 5 )%>" class="inputTexto" size="3" maxlength="2" onblur="seNaoIntReset(this,1)" onchange="copiarParaFormPrincipal(this.value,'quantidadeDiasAvisoBackup')">
                                </td>
                                <td class="TextoCampos">
                                    Quantidade de dias até enviar e-mail:
                                </td>
                                <td class="celulaZebra2">
                                    <input type="text" name="qtdDiasEmailBackup" id="qtdDiasEmailBackup" value="<%= (carregaconfig ? jbean.getQuantidadeDiasEmailBackup() : 15 )%>" class="inputTexto" size="3" maxlength="2"  onblur="seNaoIntReset(this,1)" onchange="copiarParaFormPrincipal(this.value,'quantidadeDiasEmailBackup')">
                                </td>
                            </tr>
                        </table>
                        </form>
                        </div>
                        <div class="panel" id='tab7' style="width:85%" >
                            <table align="center"  width="100%" class="bordaFina" >
                                <tr>
                                    <td>
                                        <div id="divAuditoria" width="80%" >
                                            <table colspan="3" width="100%" align="center" cellpadding="1" cellspacing="1" class="bordaFina" id="tableAuditoria">
                                                <%@include file="./gwTrans/template_auditoria.jsp" %>
                                            </table>
                                        </div> 
                                    </td>    
                                </tr>
                            </table>        
                        </div>            
                                        <br/>
                <table width="85%" border="0" class="bordaFina" align="center">
                    <tr class="CelulaZebra2">
                        <td >
                            <% if (nivelUser >= 2) {%>
                            <div align="center">
                                <input name="salvar2" type="button" class="botoes" id="salvar2" value="   Salvar   " onClick="javascript:tryRequestToServer(function () {
                                            salvar();
                                        });">
                            </div>
                            <%}%>
                        </td>
                    </tr>
                </table>
    </body>
</html>
