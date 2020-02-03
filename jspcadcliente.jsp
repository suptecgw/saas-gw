<%@page import="br.com.gwsistemas.agendamentoTarefas.beans.TarefaAgendadaClienteLayoutEDI" %>
<%@page import="br.com.gwsistemas.bairro.BairroDAO" %>
<%@page import="br.com.gwsistemas.conhecimento.caixapostal.seguradora.CaixaPostalSeguradora" %>
<%@page import="br.com.gwsistemas.conhecimento.caixapostal.seguradora.CaixaPostalSeguradoraDAO" %>
<%@page import="br.com.gwsistemas.contratoComercial.ContratoComercial" %>
<%@page import="br.com.gwsistemas.contratodefrete.negociacao.ClienteNegociacaoAdiantamentoFrete" %>
<%@page import="br.com.gwsistemas.contratodefrete.negociacao.NegociacaoAdiantamentoFrete" %>
<%@page import="br.com.gwsistemas.contratodefrete.negociacao.NegociacaoAdiantamentoFreteBO" %>
<%@page import="br.com.gwsistemas.eutil.NivelAcessoUsuario" %>
<%@page import="br.com.gwsistemas.integracoes.ftp.ConfigTransf" %>
<%@page import="br.com.gwsistemas.integracoes.ftp.FtpBO" %>
<%@page import="br.com.gwsistemas.layoutedi.LayoutEDI" %>
<%@page import="br.com.gwsistemas.layoutedi.LayoutEDIBO" %>
<%@page import="br.com.gwsistemas.tabela.Coluna" %>
<%@page import="br.com.gwsistemas.tabela.Tabela" %>
<%@page import="br.com.gwsistemas.tabelaAdicionalTde.TabelaAdicionalTDE" %>
<%@page import="br.com.gwsistemas.tabelaAdicionalTde.TabelaAdicionalTdeBO" %>
<%@page import="cidade.BeanConsultaCidade" %>
<%@page import="cidade.Endereco" %>
<%@page import="cliente.*" %>
<%@page import="cliente.coletasautomaticas.ColetasAutomaticas" %>
<%@page import="cliente.tipoProduto.ConsultaTipoProduto" %>
<%@page import="cliente.tipoProduto.TipoProduto" %>
<%@page import="cliente.vencimentoFatura.DiasVencimentoFatura" %>
<%@page import="com.sagat.bean.produto.BeanGrupoProduto" %>
<%@page import="com.sagat.bean.produto.ProdutoBO" %>
<%@page import="filial.BeanFilial" %>
<%@page import="fornecedor.BeanConsultaFornecedor" %>
<%@page import="nucleo.*" %>
<%@page import="nucleo.exportacao.ExportacaoBO" %>
<%@page import="nucleo.exportacao.LayoutExcel" %>
<%@page import="nucleo.imagem.ClienteImagem" %>
<%@page import="nucleo.webservice.WebServiceCep" %>
<%@page import="tipo_veiculos.ConsultaTipo_veiculos" %>
<%@page import="usuario.BeanUsuario" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="java.sql.ResultSet" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="java.util.ArrayList" %>
<%@page import="java.util.Collection" %>
<%@ page import="java.util.Objects" %>
<%@ page import="br.com.gwsistemas.conhecimento.CteTagPersonalizadaCampo" %>
<%@ page import="org.apache.commons.lang3.StringUtils" %>
<%@ page contentType="text/html; charset=ISO-8859-1" language="java" errorPage="" %>
<script language="JavaScript" src="script/ie.js" type="text/javascript"></script><script language="JavaScript" src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/mascaras.js" type="text/javascript"></script><script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype_1_7_2.js" type="text/javascript"></script><script language="JavaScript"  src="script/jquery-1.11.2.min.js" type="text/javascript"></script>
<script language="JavaScript" type="text/javascript" src="script/situacaoPessoa.js"></script><script language="JavaScript" src="script/LogAcoesAuditoria.js" type="text/javascript"></script>
<script language="JavaScript" src="script/funcoesTelaCliente.js?v=${random.nextInt()}" type="text/javascript"></script><script language="javascript" src="script/funcoes.js" type="text/javascript"></script>

<!--<script type="text/javascript" src="script/fabtabulous.js"></script>-->
<% //Permissao do usuário nessa página
    BeanUsuario autenticado = Apoio.getUsuario(request);
    int nivelUser = autenticado.getAcesso("cadcliente"); 
    int nivelUserTabela = (autenticado != null ? autenticado.getAcesso("cadtabelacliente") : 0);
    int nivelComissao = autenticado.getAcesso("vercomissao");
    int nivelFinan = autenticado.getAcesso("altclifinan");
    int nivelAnaliseCredito = autenticado.getAcesso("altanalisecreditocliente");
    int nivelOperacional = autenticado.getAcesso("altclioperacional");
    int nivelClienteDireto = autenticado.getAcesso("clientedireto");
    int nivelBairro = autenticado.getAcesso("cadbairro");
    Tabela tabela = new Tabela("vcte");
    tabela.makeColunasDesejadas(null);
    Collection<Coluna> colunas = tabela.getColunas();
    Collection<BeanFilial> filiais = new ArrayList<BeanFilial>();
    BeanFilial beanFilial = new BeanFilial();
    Collection<ClienteTaxas> clienteTaxas = new ArrayList<ClienteTaxas>();
    ClienteTaxas clienteT = new ClienteTaxas();
    BeanCadCliente beanCCli = new BeanCadCliente();
    beanCCli.setConexao(Apoio.getUsuario(request).getConexao());
    clienteTaxas =  beanCCli.getClienteTaxas();
    ArrayList<BeanPermissaoContato> listaPermtest = new ArrayList<BeanPermissaoContato>();
    //Necessario popular o obj
    listaPermtest.addAll(beanCCli.getPermissaoContato(null));
    //Estava chamando direto o DAO, alterei para chamer primeiro o BO, Daniel Cassimiro
    ProdutoBO prBO = new ProdutoBO(); 
    Consulta filtros = new Consulta();
    filtros.setCampoConsulta("descricao");
    filtros.setLimiteResultados(1000);
    filtros.setPaginaAtual(1);
    Collection<BeanGrupoProduto> listaGp = prBO.listarGrupoProduto(filtros, autenticado);
    ResultSet rsFili = beanFilial.all(Apoio.getUsuario(request).getConexao());
    while(rsFili.next()){
        beanFilial = new BeanFilial();
        beanFilial.setIdfilial(rsFili.getInt("idfilial"));
        beanFilial.setAbreviatura(rsFili.getString("abreviatura"));
        filiais.add(beanFilial);
    }

    Collection<ConfigTransf> listarFtp = new ArrayList<ConfigTransf>();
    FtpBO ftp = new FtpBO();
    listarFtp = ftp.carregarCombo();
    Collection<CaixaPostalSeguradora> listaCaixaPostalSeguradora = new ArrayList<CaixaPostalSeguradora>();
    CaixaPostalSeguradoraDAO caixaPostalSeguradoraDAO = new CaixaPostalSeguradoraDAO();
    listaCaixaPostalSeguradora = caixaPostalSeguradoraDAO.mostrarTodos();
    //Consulta que trás todos os tipos de veiculos
    ConsultaTipo_veiculos tipoVeiculo = new ConsultaTipo_veiculos();
    tipoVeiculo.setConexao(Apoio.getUsuario(request).getConexao());
    //novo parametro para trazer os tipos de veiculo historia 3231
    tipoVeiculo.mostraTipos(false,0);
    ResultSet rsTipoVeiculo = tipoVeiculo.getResultado();
    //Consulta que trás todos os tipos de produtos
    Collection<TipoProduto> listaProduto = new ArrayList<TipoProduto>();
    ConsultaTipoProduto addTipoProduto = new ConsultaTipoProduto();
    addTipoProduto.setConexao(Apoio.getUsuario(request).getConexao());
    listaProduto = addTipoProduto.mostrarTodos(Apoio.getUsuario(request).getConexao());
    boolean executou = false;
    Collection<LayoutEDI> listaLayoutCONEMB = LayoutEDIBO.mostrarLayoutEDI("c", autenticado);
    Collection<LayoutEDI> listaLayoutDOCCOB = LayoutEDIBO.mostrarLayoutEDI("f", autenticado);
    Collection<LayoutEDI> listaLayoutOCOREN = LayoutEDIBO.mostrarLayoutEDI("o", autenticado);
    Collection<LayoutEDI> listaLayoutNOTFIS = LayoutEDIBO.mostrarLayoutEDI("n", autenticado);
    request.setAttribute("listaLayoutNOTFIS", listaLayoutNOTFIS);
    ExportacaoBO exportacaoBO = new ExportacaoBO();
    Collection<LayoutExcel> layoutsDocCobExcel = exportacaoBO.mostrarTodosLayoutsDocCobExcel(Apoio.getUsuario(request));
    Collection<SituacaoTributavel> listaStIcms = SituacaoTributavelICMS.mostrarTodos(Apoio.getUsuario(request).getConexao());
    Collection<NegociacaoAdiantamentoFrete> negociacaoCli = null;
    negociacaoCli = new ArrayList<NegociacaoAdiantamentoFrete>(); Consulta filtros2 = new Consulta(); filtros2.setCampoConsulta("descricao");filtros2.setLimiteResultados(10000000); filtros2.setOperador(Consulta.TODAS_AS_PARTES);
    NegociacaoAdiantamentoFreteBO negoDao = new NegociacaoAdiantamentoFreteBO();
    negociacaoCli = negoDao.carregarCombo();request.setAttribute("listaNegociacaoCliente", negociacaoCli);
    ClienteNegociacaoAdiantamentoFrete excecao = null;
    Collection<TabelaAdicionalTDE> listaTDE = TabelaAdicionalTdeBO.mostrarTodos();
//testando se a sessao é válida e se o usuário tem acesso
    if ((autenticado == null) || (nivelUser == 0)) { response.sendError(response.SC_FORBIDDEN); } //fim da MSA
    String acao = request.getParameter("acao");
    BeanCliente cli = new BeanCliente();
    BeanCadCliente cadCli = null;
    ClienteImagem imagem = new ClienteImagem();
    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
//Carregando as configuraões independente da ação
    BeanConfiguracao cfg = new BeanConfiguracao();
    cfg.setConexao(autenticado.getConexao());
//Carregando as configurações
    cfg.CarregaConfig();
    if (acao != null) {
        //instrucoes incomuns entre as acoes
        if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar") || acao.equals("verificar_cgc")) {    //instanciando o bean de cadastro
            cadCli = new BeanCadCliente();
            cadCli.setConexao(autenticado.getConexao());
            cadCli.setExecutor(autenticado);
        }
        //executando a acao desejada
        if ((acao.equals("editar")) && (request.getParameter("id") != null)) {
            int idcliente = Integer.parseInt(request.getParameter("id"));
            cli.setIdcliente(idcliente);
            //carregando os dados do cliente por completo(atributos, permissoes)
            cadCli.setCliente(cli);
            cadCli.LoadAllPropertys();
            request.setAttribute("cli", cli);
        } else if (acao.equals("atualizar") || acao.equals("incluir")) {
            //populando o JavaBean
            cli.setTipoEnvioEmailMDF(Apoio.parseInt(request.getParameter("emailMDF")));
            cli.setTipoEnvioEmailCte(request.getParameter("email"));
            cli.setRazaosocial(request.getParameter("rzs"));
            cli.setNomefantasia(request.getParameter("nomefantasia"));
            cli.setAtivo(request.getParameter("chkativo") != null);
            cli.setEndereco(request.getParameter("endereco"));
            cli.setComplemento(request.getParameter("compl"));
            cli.setBairro(request.getParameter("bairro"));
            cli.getBairroBean().setIdBairro(Apoio.parseInt(request.getParameter("idLocalizaBairro")));
            cli.setCep(request.getParameter("cep"));
            cli.getCidade().setIdcidade(Integer.parseInt(request.getParameter("idcidade")));
            cli.setFone(request.getParameter("fone"));
            cli.setFax(request.getParameter("fax"));
            cli.setTipoBaseComissao(request.getParameter("tipoBaseComissao"));
            cli.setTipocgc(request.getParameter("tipocgc"));
            cli.setTipoCfop(request.getParameter("tipoCfop"));
            cli.setCnpj(request.getParameter("cnpj"));
            cli.setInscest(request.getParameter("IE"));
            cli.setCondicaoPgt(Apoio.parseInt(request.getParameter("condicaopgt")));
            cli.getVendedor().setIdfornecedor(Integer.parseInt(request.getParameter("idven")));
            cli.setTipoComissao(Apoio.parseInt(request.getParameter("tipoComissao")));
            cli.setVlcomissaoVendedor(Apoio.parseFloat(request.getParameter("vlcomissao_vendedor")));
            cli.getVendedor2().setIdfornecedor(Apoio.parseInt(request.getParameter("idsupervisor")));
            cli.setTipoComissao2(Apoio.parseInt(request.getParameter("tipoComissao2")));
            cli.setVlcomissaoVendedor2(Apoio.parseFloat(request.getParameter("vlcomissao_vendedor2")));
            cli.setFichario(request.getParameter("fichario"));
            cli.getCnae().setId(Apoio.parseInt(request.getParameter("cnae_id")));
            cli.getGcf().setId(Apoio.parseInt(request.getParameter("grupo_id")));
            cli.setTipo_tabela(Apoio.parseInt(request.getParameter("tipotabela")));
            cli.getPlanoConta().setId(Apoio.parseInt(request.getParameter("plano_contas_id")));
            cli.getPlanoConta().setDescricao(request.getParameter("plano_conta_descricao"));
            cli.setEnderecoCob(request.getParameter("enderecoCob"));
            cli.setComplementoCob(request.getParameter("complCob"));
            cli.setBairroCob(request.getParameter("bairroCob"));
            cli.getBairroBeanCob().setIdBairro(Apoio.parseInt(request.getParameter("idBairroCob")));
            cli.setCepCob(request.getParameter("cepCob"));
            cli.getCidadeCob().setIdcidade(Apoio.parseInt(request.getParameter("cidadeCobId")));
            cli.setTipoPagtoFrete(request.getParameter("pagtoFrete"));
            cli.setTipoDiasVencimento(request.getParameter("tipoDiasVencimento"));
            cli.setSeguroCarga(request.getParameter("tipoSeguroCarga"));
            cli.setValidadeDdr(Apoio.paraDate(request.getParameter("dtddr")));
            cli.setNumeroApoliceDdr(request.getParameter("numero_apolice_ddr"));
            cli.getSeguradoraDdr().setIdfornecedor(Apoio.parseInt(request.getParameter("seguradora")));
            cli.setXmlEnvioFtp(Apoio.parseBoolean(request.getParameter("isEnviaFtp")));
            cli.getConfigFtp().setId(Apoio.parseInt(request.getParameter("enviaXmlFtp")));
            // History 374
            cli.setEspecieSerieModal(Apoio.parseBoolean(request.getParameter("ckEspecieSerieModal")));
            cli.setEspecie(request.getParameter("inpEspecie"));
            cli.setSerie(request.getParameter("inpSerie"));
            cli.setModalCliente(request.getParameter("modalCliente"));
            // History 374 - fim
            
            //Novos campos Autor : Mateus
            cli.setStUtilizacaoAverbacaoCTe(request.getParameter("statusAverbacaoCte").charAt(0));
            if(cli.getStUtilizacaoAverbacaoCTe() != "N".charAt(0)){
                cli.setFormaTransmissaoCTe(request.getParameter("radionCte").charAt(0));
                cli.getCaixaPostalSeguradoraRodoviario().setId(Apoio.parseInt(request.getParameter("seguradoraRodoviario")));
                cli.getCaixaPostalSeguradoraAereo().setId(Apoio.parseInt(request.getParameter("seguradoraAereo")));
                cli.getCaixaPostalSeguradoraAquaviario().setId(Apoio.parseInt(request.getParameter("seguradoraAquaviario")));
                cli.setAverbarCTeNormal(Apoio.parseBoolean(request.getParameter("averbarNormal")));
                cli.setAverbarCTeDistLocal(Apoio.parseBoolean(request.getParameter("averbarDistLocal")));
                cli.setAverbarCTeDiarias(Apoio.parseBoolean(request.getParameter("averbarDiarias")));
                cli.setAverbarCTePallets(Apoio.parseBoolean(request.getParameter("averbarPallets")));
                cli.setAverbarCTeComplementar(Apoio.parseBoolean(request.getParameter("averbarComplementar")));
                cli.setAverbarCTeReentrega(Apoio.parseBoolean(request.getParameter("averbarReentrega")));
                cli.setAverbarCTeDevolucao(Apoio.parseBoolean(request.getParameter("averbarDevolucao")));
                cli.setAverbarCTeCortesia(Apoio.parseBoolean(request.getParameter("averbarCortesia")));
                cli.setAverbarCTeSubstituicao(Apoio.parseBoolean(request.getParameter("averbarSubstituicao")));
            }
            cli.setStUtilizacaoAverbacaoNFSe(request.getParameter("statusAverbacaoNfs").charAt(0));
            if(cli.getStUtilizacaoAverbacaoNFSe() != "N".charAt(0)){
                cli.setFormaTransmissaoNFSe(request.getParameter("radionNfs").charAt(0));
                cli.getCaixaPostalSeguradoraNFSe().setId(Apoio.parseInt(request.getParameter("cxPostalNfs")));
            }
            cli.setDataInicialAverbacao(Apoio.paraDate(request.getParameter("dtApatir")));
            //----------------------------
            cli.setTabelaTipoProduto(request.getParameter("chkTipoProduto") != null);
            cli.setClienteDireto(Apoio.parseBoolean(request.getParameter("tipoCliente"))); //combobox com valor 'true' e 'false'
            cli.setIsEnviaEmailMDF(request.getParameter("chkEmailMDF") != null);
            cli.setEnviaEmailCtrc(request.getParameter("chkEmailCtrc") != null);
            cli.setEnviaEmailManifesto(request.getParameter("chkEmailManifesto") != null);
            cli.setEnviaEmailBaixaCtrc(request.getParameter("chkEmailBaixaCtrc") != null);
            cli.setUtilizaPautaFiscal(request.getParameter("chkPautaFiscal") != null);
            cli.setIncluiContainerFretePeso(request.getParameter("chkIncluiContainer") != null);
            cli.setObservacao(request.getParameter("obs_lin1") + "\r\n" + request.getParameter("obs_lin2") + "\r\n" + request.getParameter("obs_lin3") + "\r\n" + request.getParameter("obs_lin4") + "\r\n" + request.getParameter("obs_lin5"));
            cli.getUnidadeCusto().setId(Apoio.parseInt(request.getParameter("unidadeFreteId")));
            cli.setOcorrenciasClientes(request.getParameter("chkOcorrenciasCliente") != null);
            cli.setCodTransportadoraPrefat(request.getParameter("codTransportadoraPrefat"));
            cli.setEnviaEmailNfse(request.getParameter("chkEnviaEmailNfse") != null);
            cli.getOrigemCaptacao().setId(Apoio.parseInt(request.getParameter("origem_captacao_id")));
            cli.getOrigemCaptacao().setDescricao(request.getParameter("origem_captacao"));
            cli.setAnexarComprovante(request.getParameter("comprovante"));
            cli.setAnaliseCredito(request.getParameter("chkAnaliseCredito") != null);
            cli.setPermitirCreditoBloqNotas(request.getParameter("chkPermitirCredBloqNotas") != null);
            cli.setLimiteCredito(Apoio.parseDouble(request.getParameter("limiteCredito")));
            cli.setDiasAtraso(Apoio.parseInt(request.getParameter("diasAtraso")));
            cli.setEmailCancelarCTE(Apoio.parseBoolean(request.getParameter("chkEmailCancelarCTE")));
            cli.setEmailCartaCorrecaoCTE(Apoio.parseBoolean(request.getParameter("chkEmailcartacorrCTE")));
            cli.setUtilizaTabelaRemetente(request.getParameter("tipoTabelaRemetente"));
            cli.setConsumidorFinal(request.getParameter("consumidorFinal") != null);
            cli.setEtiquetaImprimirMaximo(Apoio.parseInt(request.getParameter("etiquetaImprimirMaximo")));
            cli.setEtiquetaLayoutImpressao(request.getParameter("etiquetaLayoutImpressao"));
            // -- endereco coleta
            cli.setHorarioColeta(request.getParameter("horarioColeta"));
            cli.setReferenciaCol(request.getParameter("referenciaCol"));
            cli.setEnderecoCol(request.getParameter("enderecoCol"));
            cli.setComplementoCol(request.getParameter("complCol"));
            cli.setBairroCol(request.getParameter("bairroCol"));
            cli.getBairroBeanCol().setIdBairro(Apoio.parseInt(request.getParameter("idBairroCol")));
            cli.setCepCol(request.getParameter("cepCol"));
            cli.getCidadeCol().setIdcidade(Apoio.parseInt(request.getParameter("cidadeColId")));
            cli.setNumeroLogradouro(request.getParameter("numeroLogradouro"));
            cli.getStIcms().setId(Apoio.parseInt(request.getParameter("stIcms")));
            cli.setIsFaturarMesmaCidadeComNfse(request.getParameter("chkFaturarMinuta") != null);
            cli.setTipoOrigemFrete(request.getParameter("tipoOrigemFrete"));
            cli.setNuncaProtestar(request.getParameter("isNuncaProtestar") != null);
            cli.setCobrarTde(request.getParameter("chkCobrarTde") != null);
            cli.setInscMunicipal(request.getParameter("inscMunicipal"));
            cli.setMotivoInativacao(request.getParameter("motivo"));
            cli.setMotivoTDE(request.getParameter("motivoTDE"));
            cli.setSubstituicaoTributariaMinasGerais(request.getParameter("chkSTMG") != null);
            cli.setSalvarDataEntregaMenorEmissao(request.getParameter("dataEntregaMenor") != null);
            cli.setCodIntegracaoFiscal(request.getParameter("cod_fiscal"));
            cli.setTipoCobranca(request.getParameter("tipoCobranca"));
            cli.setNumeroContainer(request.getParameter("chkNumeroInformado") != null);
            cli.setTipoComissaoVendedor(Apoio.parseInt(request.getParameter("tipoComissaoVendedor")));
            cli.setComissaoRodoviarioFracionadoVendedor(Apoio.parseDouble(request.getParameter("ComissaoRodoviarioFracionadoVendedor")));
            cli.setComissaoRodoviarioLotacaoVendedor(Apoio.parseDouble(request.getParameter("ComissaoRodoviarioLotacaoVendedor")));
            cli.setTipoComissaoSupervisor(Apoio.parseInt(request.getParameter("tipoComissaoSupervisor")));
            cli.setComissaoRodoviarioFracionadoSupervisor(Apoio.parseDouble(request.getParameter("ComissaoRodoviarioFracionadoSupervisor")));
            cli.setComissaoRodoviarioLotacaoSupervisor(Apoio.parseDouble(request.getParameter("ComissaoRodoviarioLotacaoSupervisor")));
            //Latitude e Longitude GwBuonny
            cli.setLatitude(Apoio.parseDouble(request.getParameter("latitude")));
            cli.setLongitude(Apoio.parseDouble(request.getParameter("longitude")));
            cli.getResponsavelAcompanhamentoEntrega().setIdusuario(Apoio.parseInt(request.getParameter("usuario_id")));
            cli.setTipoPgtoContaCorrente(request.getParameter("tipoPgtoContaCorrente"));
            cli.setSegunda(Apoio.parseBoolean(request.getParameter("chkSegunda")));
            cli.setTerca(Apoio.parseBoolean(request.getParameter("chkTerca")));
            cli.setQuarta(Apoio.parseBoolean(request.getParameter("chkQuarta")));
            cli.setQuinta(Apoio.parseBoolean(request.getParameter("chkQuinta")));
            cli.setSexta(Apoio.parseBoolean(request.getParameter("chkSexta")));
            cli.setSabado(Apoio.parseBoolean(request.getParameter("chkSabado")));
            cli.setDomingo(Apoio.parseBoolean(request.getParameter("chkDomingo")));
            cli.setConsiderarCubagemProduto(Apoio.parseBoolean(request.getParameter("considerarCubagemProduto")));
            cli.setComprimirDacteFatura(Apoio.parseBoolean(request.getParameter("chkComprimirDacteFatura")));
            cli.setValorDiariaParado(Apoio.parseDouble(request.getParameter("valorDiariaParado")));
            cli.setTipoDocumentoPadrao(request.getParameter("tipoDocumentoPadrao"));
            cli.setIsClienteArmazenagem(request.getParameter("chkClienteArmazenagem") != null);
            cli.setEnviaEmailChegada(Apoio.parseBoolean(request.getParameter("chkEnviaEmailChegada")));
            cli.setEnviaEmailOcorrencia(Apoio.parseBoolean(request.getParameter("chkEnviaEmailOcorrencia")));
            cli.setMostrarRotasDesseCliente(Apoio.parseBoolean(request.getParameter("carregarRotasContratoCliente")));
            cli.setUtilizarTipoFreteTabela(Apoio.parseBoolean(request.getParameter("utilizartipofretetabela")));
            cli.getUnidadeCustoReceita().setId(Apoio.parseInt(request.getParameter("unidadeId")));
            //Vendedor
            cli.setUtilizarCriterioPagamentoComissaoVendedor(Apoio.parseBoolean(request.getParameter("pagamentoComissaoVendedor")));
            cli.setCalcularComissaoVendedor(request.getParameter("calcularComissaoVendedor").charAt(0));
            cli.setImpostoFederalIcmsVendedor(Apoio.parseBoolean(request.getParameter("icmsVendedor")));
            cli.setImpostoFederalPisVendedor(Apoio.parseBoolean(request.getParameter("pisVendedor")));
            cli.setImpostoFederalCofinsVendedor(Apoio.parseBoolean(request.getParameter("cofinsVendedor")));
            cli.setImpostoFederalCsslVendedor(Apoio.parseBoolean(request.getParameter("csslVendedor")));
            cli.setImpostoFederalIrVendedor(Apoio.parseBoolean(request.getParameter("irVendedor")));
            cli.setImpostoFederalInssVendedor(Apoio.parseBoolean(request.getParameter("inssVendedor")));
            cli.setPagamentoComissaoJurosVendedor(request.getParameter("valorJurosVendedor"));
            cli.setPagamentoComissaoDescontoVendedor(request.getParameter("valorDescontoVendedor"));
            //Supervisor
            cli.setUtilizarCriterioPagamentoComissaoSupervisor(Apoio.parseBoolean(request.getParameter("pagamentoComissaoSupervisor")));
            cli.setCalcularComissaoSupervisor(request.getParameter("calcularComissaoSupervisor").charAt(0));
            cli.setImpostoFederalIcmsSupervisor(Apoio.parseBoolean(request.getParameter("icmsSupervisor")));
            cli.setImpostoFederalPisSupervisor(Apoio.parseBoolean(request.getParameter("pisSupervisor")));
            cli.setImpostoFederalCofinsSupervisor(Apoio.parseBoolean(request.getParameter("cofinsSupervisor")));
            cli.setImpostoFederalCsslSupervisor(Apoio.parseBoolean(request.getParameter("csslSupervisor")));
            cli.setImpostoFederalIrSupervisor(Apoio.parseBoolean(request.getParameter("irSupervisor")));
            cli.setImpostoFederalInssSupervisor(Apoio.parseBoolean(request.getParameter("inssSupervisor")));
            cli.setPagamentoComissaoJurosSupervisor(request.getParameter("valorJurosSupervisor"));
            cli.setPagamentoComissaoDescontoSupervisor(request.getParameter("valorDescontoSupervisor"));
            //Taxas de Tombamento e Roubo
            cli.setTaxaSeguroTombamentoRodoviario(Apoio.parseDouble(request.getParameter("taxaSeguroTombamentoRodoviario")));
            cli.setTaxaSeguroRouboRodoviario(Apoio.parseDouble(request.getParameter("taxaSeguroRouboRodoviario")));
            cli.setTaxaSeguroTombamentoAereo(Apoio.parseDouble(request.getParameter("taxaSeguroTombamentoAereo")));
            cli.setTaxaSeguroRouboAereo(Apoio.parseDouble(request.getParameter("taxaSeguroRouboAereo")));
            cli.setRetirarContratoFreteBaseCalculoVendedor(Apoio.parseBoolean(request.getParameter("retirarContratoFreteBaseCalculoVendedor")));
            cli.setRetirarContratoFreteBaseCalculoSupervisor(Apoio.parseBoolean(request.getParameter("retirarContratoFreteBaseCalculoSupervisor")));
            cli.setCodLoja(request.getParameter("codLoja"));
            cli.setConsignatario(Apoio.parseBoolean(request.getParameter("chkConsignatario")));
            cli.setRemetente(Apoio.parseBoolean(request.getParameter("chkRemetente")));
            cli.setDestinatario(Apoio.parseBoolean(request.getParameter("chkDestinatario")));
            cli.setRedespacho(Apoio.parseBoolean(request.getParameter("chkRedespacho")));
            cli.setRecebedor(Apoio.parseBoolean(request.getParameter("chkRecebedor")));
            cli.setExpedidor(Apoio.parseBoolean(request.getParameter("chkExpedidor")));
            cli.setPeriodicidadeFaturamento(request.getParameter("periodicidade"));
            //CTes Visíveis no módulo do cliente
            cli.setIsVisivelCteNormal(Apoio.parseBoolean(request.getParameter("chkCTnormal")));
            cli.setIsVisivelCteLocal(Apoio.parseBoolean(request.getParameter("chkCTlocal")));
            cli.setIsVisivelCteDiarias(Apoio.parseBoolean(request.getParameter("chkCTdiarias")));
            cli.setIsVisivelCtePallets(Apoio.parseBoolean(request.getParameter("chkCTpallets")));
            cli.setIsVisivelCteComplementar(Apoio.parseBoolean(request.getParameter("chkCTcomplementar")));
            cli.setIsVisivelCteReentrega(Apoio.parseBoolean(request.getParameter("chkCTreentrega")));
            cli.setIsVisivelCteDevolucao(Apoio.parseBoolean(request.getParameter("chkCTdevolucao")));
            cli.setIsVisivelCteCortesia(Apoio.parseBoolean(request.getParameter("chkCTcortesia")));
            cli.setIsVisivelCteSubstituicao(Apoio.parseBoolean(request.getParameter("chkCTsubstituicao")));
            cli.setIsVisivelCteAnulacao(Apoio.parseBoolean(request.getParameter("chkCTanulacao")));
            cli.setIsVisivelCteSubstituto(Apoio.parseBoolean(request.getParameter("chkCTsubstituto")));
            //adicionando check para Anexar comprovante de entrega ao enviar e-mail de boleto
            cli.setIsAnexarComprovanteEntregaBoleto(Apoio.parseBoolean(request.getParameter("isComprovanteEntrega")));
            cli.setCodigoIntegracaoCfe(request.getParameter("codigoIntegracaoCfe"));
            cli.setNegociacaoAdiantamento(Apoio.parseInt(request.getParameter("negociacaoAdiantamentoSlc")));
            cli.setMsgClienteCte(request.getParameter("msgCliCte").replaceAll("/\n/g", " "));
            cli.setMsgClienteColeta(request.getParameter("msgCliColeta").replaceAll("/\n/g", " "));
            cli.setTipoArredondamentoPeso(request.getParameter("tipoArredondamentoPeso"));
            cli.getUtilizarTabelaCliente().setIdcliente(Apoio.parseInt(request.getParameter("idtransportador")));
            //adicionando os tipos deprodutos
            int maxTipo = Integer.parseInt(request.getParameter("maxTipoProduto"));
            cli.setLogomarcaCliente(request.getParameter("logomarcaCliente"));
            cli.setXmlCteVcarga001(Apoio.parseBoolean(request.getParameter("xmlCteVcarga001")));
            cli.setTipoTributacao(request.getParameter("tipoTributacao"));
            cli.setFreteDirigido(Apoio.parseBoolean(request.getParameter("isfreteDirigido")));
            cli.setIsImprimirLogomarcaBoleto(Apoio.parseBoolean(request.getParameter("isImprimirLogomarcaBoleto")));
            cli.setGerarNumeroEtiquetaIncluirNota(request.getParameter("chkGerarNumeroEtiquetaIncluirNota") != null);
            cli.setBaixarXmlCliente(Apoio.parseBoolean(request.getParameter("baixarXmlCliente")));
            cli.getTipoProdutoDestinatario().setId(Apoio.parseInt(request.getParameter("tipoProdutoDestinatarioId")));
            cli.getTabelaTDE().setId(Apoio.parseInt(request.getParameter("tabelaTDE")));
            // 07/05/2018 - Ao consultar entregas deverá ocultar os campos:
            cli.setOcultoDataEmbarque(Apoio.parseBoolean(request.getParameter("chkRastreamentoOcultarDataEmbarque")));
            cli.setOcultoPrevisaoChegada(Apoio.parseBoolean(request.getParameter("chkRastreamentoOcultarPrevisaoChegada")));
            cli.setOcultoDataChegada(Apoio.parseBoolean(request.getParameter("chkRastreamentoOcultarDataChegada")));
            cli.setOcultoPrevisaoEntrega(Apoio.parseBoolean(request.getParameter("chkRastreamentoOcultarPrevisaoEntrega")));
            cli.setIsOcultarObservacao(Apoio.parseBoolean(request.getParameter("chkRastreamentoOcultarObservacao")));
            cli.setStatusAtualCargaUltimaOcorrenciaLancada(Apoio.parseBoolean(request.getParameter("chkStatusAtualCargaUltimaOcorrenciaLancada")));
            
            //13/08/2018
            cli.setTravaCamposImportacao(Apoio.parseBoolean(request.getParameter("travaCamposImportacao")));
            cli.setImportarNotfisPrevalecerEtiqueta(Apoio.parseBoolean(request.getParameter("chkImportarNotfisPrevalecerEtiqueta")));
            cli.setObservacaoFisco(
                    request.getParameter("obs_fisco_lin1")
                    + "\r\n" + request.getParameter("obs_fisco_lin2")
                    + "\r\n" + request.getParameter("obs_fisco_lin3")
                    + "\r\n" + request.getParameter("obs_fisco_lin4")
                    + "\r\n" + request.getParameter("obs_fisco_lin5")
            );

            cli.setEnviarEmailLembreteVencimentoFatura(Apoio.parseBoolean(request.getParameter("chkEnviarEmailLembreteVencimentoBoleto")));
            cli.setDiasVencimento(Apoio.parseInt(request.getParameter("inpDiasEnviarEmailLembreteVencimentoBoleto")));
            
            //26/11/2018
            cli.setAceitaLucratividadeNegativa(Apoio.parseBoolean(request.getParameter("aceitaLucratividadeNegativa")));
            cli.setPercentualAceito(Apoio.parseDouble(request.getParameter("percentualAceito")));
            
            cli.getFilialResponsavel().setIdfilial(Apoio.parseInt(request.getParameter("filialResponsavel")));
            cli.setEmitirCTeNFSeSomenteFilialResponsavel(Apoio.parseBoolean(request.getParameter("cteNfeEmissaoFilialResponsavel")));
            cli.setEmitirFaturaSomenteFilialResponsavel(Apoio.parseBoolean(request.getParameter("faturaEmissaoFilialResponsavel")));

            cli.setDesconsiderarMinuta(Apoio.parseBoolean(request.getParameter("isDesconsiderarMinuta")));
            
            cli.setGerarNfseCidadeOrigemDestinoCteLote(Apoio.parseBoolean(request.getParameter("isGerarNfseCidadeOrigemDestinoCteLote")));
            
            cli.setEnviarTipoOcorrencia(request.getParameter("enviarTipoOcorrencia"));
            cli.setTipoEnvioBoleto(request.getParameter("tipoEnvioBoleto"));
            
            cli.setConsultarEntregasRaizCNPJ(Apoio.parseBoolean(request.getParameter("chkConsultarEntregasTodasDaRaizCNPJ")));
            cli.setEnviarPushOcorrencias(Apoio.parseBoolean(request.getParameter("chkEnviarPushOcorrencias")));
            cli.setSerieMinuta(request.getParameter("serie-minuta"));
            cli.setTipoGeracaoNfseCidadeOrigemDestinoCteLote(request.getParameter("tipo-geracao-nfse-cidade-origem-destino-cte-lote"));

            ClienteCamposPersonalizadosXCarac xcarac = null;
            for(int i = 1; i<= Apoio.parseInt(request.getParameter("maxCampoXcarac"));i++){
                if(request.getParameter("idXcarac_"+i) != null){
                    xcarac = new ClienteCamposPersonalizadosXCarac();
                    xcarac.setId(Apoio.parseInt(request.getParameter("idXcarac_"+i)));
                    xcarac.setTipoConhecimento(request.getParameter("tipoXcaracCon_"+i));
                    xcarac.setTipoServico(request.getParameter("tipoXcaracServ_"+i));
                    xcarac.setTipoTag(request.getParameter("tipoXcaracTag_"+i));
                    xcarac.setValorTag(request.getParameter("valorXcaracTag_"+i));
                    xcarac.setModal(Apoio.parseInt(request.getParameter("modalXcarac_"+i)));
                    xcarac.setDeletar(Apoio.parseBoolean(request.getParameter("isDeletarXcarac_"+i)));
                    cli.getClienteXcarac().add(xcarac);
                }
            }
            ClienteOcorrenciaAutomatica ocorrenciaAuto = null;
            for(int i = 1; i<= Apoio.parseInt(request.getParameter("maxOcorrAuto"));i++){
                if(request.getParameter("idOcorrAuto_"+i) != null){
                    ocorrenciaAuto = new ClienteOcorrenciaAutomatica();
                    ocorrenciaAuto.setId(Apoio.parseInt(request.getParameter("idOcorrAuto_"+i)));
                    ocorrenciaAuto.getOcorrencia().setId(Apoio.parseInt(request.getParameter("idOcorr_"+i)));
                    ocorrenciaAuto.setObservacaoOcorrencia(request.getParameter("obsOcorr"+i).replaceAll("\\r\\n|\\r|\\n", " "));
                    ocorrenciaAuto.setTipoInclusao(request.getParameter("tipoInclusao_"+i));
                    ocorrenciaAuto.setDeletar(Apoio.parseBoolean(request.getParameter("deletarOcorrencia_"+i)));
                    ocorrenciaAuto.setTipoCte(request.getParameter("tipocte_" + i));
                    cli.getOcorrenciasAuto().add(ocorrenciaAuto);
                }
            }
            if(!cli.getLogomarcaCliente().equals("")){
            imagem.setUpload((String)request.getSession().getAttribute("dir_home")+"img/logoCliente/"+Apoio.getUsuario(request).getIp()+"/");
            imagem.setCaminho((String)request.getSession().getAttribute("dir_home")+"img/logoCliente/"+Apoio.getUsuario(request).getIp());
            imagem.setDescricao(request.getParameter("descricaoLogomarcaCliente"));
            imagem.setExtensao(request.getParameter("extensaoLogomarcaCliente"));
            imagem.setId(Apoio.parseInt(request.getParameter("idLogomarcaCliente")));
            cli.setImagemLogomarca(imagem);
            }
            if (maxTipo != 0) {
                TipoProduto tipoProduto[] = new TipoProduto[maxTipo];
                for (int i = 1; i <= maxTipo; ++i) {
                    TipoProduto tp = new TipoProduto();
                    if (request.getParameter("idTipoProduto_" + i) != null) {
                        tp.setId(Integer.parseInt(request.getParameter("idTipoProduto_" + i)));
                        tipoProduto[i - 1] = tp;
                    }
                }
                cli.setTipoProduto(tipoProduto);
            }
            int maxRemetente = Integer.parseInt(request.getParameter("maxTabelaRemetente"));
            if (maxRemetente != 0) {
                BeanCliente tipoRemetente[] = new BeanCliente[maxRemetente];
                for (int i = 1; i <= maxRemetente; ++i) {
                    BeanCliente cl = new BeanCliente();
                    if (request.getParameter("idRemetente_" + i) != null) {
                        cl.setIdcliente(Integer.parseInt(request.getParameter("idRemetente_" + i)));
                        cl.setTipo_tabela(Integer.parseInt(request.getParameter("tipoTabela_" + i)));
                        tipoRemetente[i - 1] = cl;
                    }
                }
                cli.setTabelaRemetente(tipoRemetente);
            }
            int maxCamposDiarias = Integer.parseInt(request.getParameter("maxCampoDiaria"));
            Collection<DiariasParadas> lista = new ArrayList<DiariasParadas>();
                DiariasParadas clienteCamposDiarias = null;
                if(maxCamposDiarias != 0){
                    for(int i=1; i <= maxCamposDiarias; i++){
                       clienteCamposDiarias = new DiariasParadas();
                        if (request.getParameter("descricaoTags_" + i) != null){
                            clienteCamposDiarias.setIdDiariasParadas(Apoio.parseInt(request.getParameter("idDiaria_"+i)));
                            clienteCamposDiarias.setValorDiarias(Apoio.parseDouble(request.getParameter("descricaoTags_" + i)));
                            clienteCamposDiarias.getTipoVeiculoDiariasParadas().setId(Apoio.parseInt(request.getParameter("camposVeiculo_" + i)));
                            clienteCamposDiarias.getTipoProdutoDiariasParadas().setId(Apoio.parseInt(request.getParameter("camposTipoProduto_" + i)));
                            clienteCamposDiarias.getBeanClienteDiariasParadas().setIdcliente(Apoio.parseInt(request.getParameter("id")));
                            clienteCamposDiarias.getCidadeDiarias().setIdcidade(Apoio.parseInt(request.getParameter("idCidadeDiaria_"+i)));
                            lista.add(clienteCamposDiarias);
                        }
                    }
                    cli.setDiariasParadasBeanCliente(lista);
                }
                int maxTaxas = Integer.parseInt(request.getParameter("maxTaxas"));
                Collection<ClienteTaxasXML> listaClienteTaxasXML = new ArrayList<ClienteTaxasXML>();
                ClienteTaxasXML clienteTaxasXML = null;
                if(maxTaxas != 0){
                    for(int i = 1; i <= maxTaxas; i++){
                        clienteTaxasXML = new ClienteTaxasXML();
                        if(request.getParameter("descricaoTaxas_" + i) != null){
                            clienteTaxasXML.setId(Apoio.parseInt(request.getParameter("idTaxas_"+i)));
                            clienteTaxasXML.getClienteTaxas().setId(Apoio.parseInt(request.getParameter("taxas_"+i)));
                            clienteTaxasXML.setNomeCampo(request.getParameter("descricaoTaxas_"+i));
                            clienteTaxasXML.setIgnorarXml(Apoio.parseBoolean(request.getParameter("isIgnorar_"+i)));
                            listaClienteTaxasXML.add(clienteTaxasXML);
                        }
                    }
                    cli.setClienteTaxasXML(listaClienteTaxasXML);
                }
            //Contatos
            boolean erroValidacao = false;
            String msgValidacao = "";
            int maxContato = Integer.parseInt(request.getParameter("maxContato"));
            if (maxContato != 0) {
                try{
                    //String[] strContato = request.getParameter("contatos").split("!!");
                        BeanContato contatoList[] = new BeanContato[maxContato];
                        BeanPermissaoContato perm = null;
                        BeanGrupoProduto grupo = null;
                        for (int c = 1; c <= maxContato; ++c) {
                            BeanContato cont = new BeanContato();
                            if (request.getParameter("idGeralCont_" + c) != null) {
                                cont.setId(Integer.parseInt(request.getParameter("idGeralCont_" + c)));
                                cont.setContato(request.getParameter("contato_" + c));
                                Apoio.validarEmail(request.getParameter("emailCont_" + c));
                                cont.setEmail(request.getParameter("emailCont_" + c));
                                cont.setRecebeEmailCobranca(request.getParameter("recebeCobranca_" + c) != null);
                                cont.setRecebeEmailEntrega(request.getParameter("recebeEntrega_" + c) != null);
                                cont.setSetor(request.getParameter("setorCont_" + c));
                                cont.setFone(request.getParameter("foneCont_" + c));
                                cont.setRamal(request.getParameter("ramalCont_" + c));
                                cont.setCelular(request.getParameter("celularCont_" + c));
                                cont.setLogin(request.getParameter("contLogin_" + c));
                                cont.setSenha(request.getParameter("contSenha_" + c));
                                cont.setReceberEmailEdi(request.getParameter("recebeEdi_" + c) != null);
                                int p = 1;
                                while (request.getParameter("permId_" + c + "_" + p) != null) {
                                    perm = new BeanPermissaoContato();
                                    if (Apoio.parseBoolean(request.getParameter("permChk_" + c + "_" + p))) {
                                        perm.setId(Apoio.parseInt(request.getParameter("permId_" + c + "_" + p)));
                                    }else{
                                        perm.setId(0);
                                    }
                                    perm.setIdPermissaoGwCli(Apoio.parseInt(request.getParameter("permGwCliId_" + c + "_" + p)));
                                    cont.getPermissoes().add(perm);
                                    p++;
                                }
                                int g = 1;
                                while (request.getParameter("grupId_" + c + "_" + g) != null) {
                                    grupo = new BeanGrupoProduto();
                                    if (Apoio.parseBoolean(request.getParameter("grupChk_" + c + "_" + g))) {
                                        grupo.setId(Apoio.parseInt(request.getParameter("grupId_" + c + "_" + g)));
                                    }else{
                                        grupo.setId(0);
                                    }
                                    grupo.setIdContatoGrupo(Apoio.parseInt(request.getParameter("grupIdContato_" + c + "_" + g)));
                                    cont.getGrupoProduto().add(grupo);
                                    g++;
                                }
                                contatoList[c - 1] = cont;
                            }
                        }
                        cli.setContatos(contatoList);
                }catch(Exception e){
                    erroValidacao = true;
                    msgValidacao = e.getMessage();
                }
            }
            int maxOcorrencia = Integer.parseInt(request.getParameter("maxOcorrencia"));
            if (maxOcorrencia != 0){
                OcorrenciaCliente ocorrenciaCli;
                for (int c = 1; c <= maxOcorrencia; ++c) {
                    ocorrenciaCli = new OcorrenciaCliente();
                   if (request.getParameter("idOcorrencia_" + c) != null){
                        ocorrenciaCli.setId(Integer.parseInt(request.getParameter("clienteOcorrenciaId_" + c)));
                        ocorrenciaCli.getOcorrencia().setId(Integer.parseInt(request.getParameter("idOcorrencia_" + c)));
                        ocorrenciaCli.setCodigoEspecificoEdi(request.getParameter("codigoEdi_" + c));
                        cli.getOcorrenciaClienteEdi().add(ocorrenciaCli);
                    }
                }
            }
            if (acao.equals("atualizar")) {
                cli.setIdcliente(Apoio.parseInt(request.getParameter("id")));
            }
            int maxLayEDI_c = Apoio.parseInt(request.getParameter("maxLayEDI_c"));
            int maxLayEDI_f = Apoio.parseInt(request.getParameter("maxLayEDI_f"));
            int maxLayEDI_o = Apoio.parseInt(request.getParameter("maxLayEDI_o"));            
            ClienteLayoutEDI layoutEdi;
            TarefaAgendadaClienteLayoutEDI tarefa = null;
            int qtdCron = 0;
            for (int c = 0; c <= maxLayEDI_c; c++) {
                if (request.getParameter("versao_c_" + c) != null) {
                    layoutEdi = new ClienteLayoutEDI("c", cli);
                    layoutEdi.setId(Apoio.parseInt(request.getParameter("idLayout_c_" + c)));
                    layoutEdi.setLayout(request.getParameter("versao_c_" + c));
                    layoutEdi.setTipoGeracaoEDI(Apoio.parseInt(request.getParameter("tipoGeracao_c_" + c)));
                    layoutEdi.getCliente().setCnpj(cli.getCnpj());
                    layoutEdi.setCreatedBy(autenticado);
                    layoutEdi.setUpdatedBy(autenticado);
                    qtdCron = Apoio.parseInt(request.getParameter("qtdCron_c_" + c));
                    for (int i = 0; i <= qtdCron; i++) {
                        if(request.getParameter("cron_c_"+c+"_"+ i) != null){
                            tarefa = new TarefaAgendadaClienteLayoutEDI(layoutEdi,"cron_c_"+c+"_"+ i+"_"+cli.getCnpj());
                            tarefa.setCronExpression(request.getParameter("cron_c_"+c+"_"+ i));
                            tarefa.setId(Apoio.parseInt(request.getParameter("idCron_c_"+c+"_"+ i)));
                            layoutEdi.getTarefas().add(tarefa);
                        }
                    }
                    cli.getLayoutsCONEMB().add(layoutEdi);
                }
            }
            for (int c = 0; c <= maxLayEDI_f; c++) {
                if (request.getParameter("versao_f_" + c) != null) {
                    layoutEdi = new ClienteLayoutEDI("f", cli);
                    layoutEdi.setId(Apoio.parseInt(request.getParameter("idLayout_f_" + c)));
                    layoutEdi.setLayout(request.getParameter("versao_f_" + c));
                    layoutEdi.setTipoGeracaoEDI(Apoio.parseInt(request.getParameter("tipoGeracao_f_" + c)));
                    layoutEdi.setCreatedBy(autenticado);
                    layoutEdi.setUpdatedBy(autenticado);
                    qtdCron = Apoio.parseInt(request.getParameter("qtdCron_f_" + c));
                    for (int i = 0; i <= qtdCron; i++) {
                        if (request.getParameter("cron_f_" + c + "_" + i) != null) {
                            tarefa = new TarefaAgendadaClienteLayoutEDI(layoutEdi,"cron_f_"+c+"_"+ i+"_"+cli.getCnpj());
                            tarefa.setCronExpression(request.getParameter("cron_f_" + c + "_" + i));
                            tarefa.setId(Apoio.parseInt(request.getParameter("idCron_f_" + c + "_" + i)));
                            layoutEdi.getTarefas().add(tarefa);
                        }
                    }
                    
                                    
                    cli.getLayoutsDOCCOB().add(layoutEdi);
                }
            }
            for (int c = 0; c <= maxLayEDI_o; c++) {
                if (request.getParameter("versao_o_" + c) != null) {
                    layoutEdi = new ClienteLayoutEDI("o", cli);
                    layoutEdi.setId(Apoio.parseInt(request.getParameter("idLayout_o_" + c)));
                    layoutEdi.setLayout(request.getParameter("versao_o_" + c), listaLayoutOCOREN);
                    layoutEdi.setTipoGeracaoEDI(Apoio.parseInt(request.getParameter("tipoGeracao_o_" + c)));
                    layoutEdi.setLogin(request.getParameter("loginEdi_o_" + c));
                    layoutEdi.setSenha(request.getParameter("senhaEdi_o_" + c));
                    layoutEdi.setChave(request.getParameter("chaveEdi_o_" + c));
                    layoutEdi.setExtensaoArquivo(request.getParameter("extensaoLayout_o_" + c));
                    layoutEdi.setCreatedBy(autenticado);
                    layoutEdi.setUpdatedBy(autenticado);
                    qtdCron = Apoio.parseInt(request.getParameter("qtdCron_o_" + c));
                    for (int i = 0; i <= qtdCron; i++) {
                        if (request.getParameter("cron_o_" + c + "_" + i) != null) {
                            tarefa = new TarefaAgendadaClienteLayoutEDI(layoutEdi,"cron_o_"+c+"_"+ i+"_"+cli.getCnpj());
                            tarefa.setCronExpression(request.getParameter("cron_o_" + c + "_" + i));
                            tarefa.setId(Apoio.parseInt(request.getParameter("idCron_o_" + c + "_" + i)));
                            layoutEdi.getTarefas().add(tarefa);
                        }
                    }
                    cli.getLayoutsOCOREN().add(layoutEdi);
                }
            }
            //adicionando endereços de entrega
            int qtdEndEntrega = Apoio.parseInt(request.getParameter("qtdEndEntrega"));
            Endereco end;
            for (int i = 1; i <= qtdEndEntrega; i++) {
                if (request.getParameter("idEndEntrga_" + i) != null) {
                    end = new Endereco();
                    end.setId(Apoio.parseInt(request.getParameter("idEndEntrga_" + i)));
                    end.setLograoduro(request.getParameter("logradouroEndEntrga_" + i));
                    end.setNumeroLogradouro(request.getParameter("numeroEndEntrga_" + i));
                    end.setCep(request.getParameter("cepEndEntrga_" + i));
                    end.setComplemento(request.getParameter("complementoEndEntrga_" + i));
                    end.setBairro(request.getParameter("bairroEndEntrga_" + i));
                    end.getBairroBean().setIdBairro(Apoio.parseInt(request.getParameter("idBairroEndEntrga_" + i)));
                    end.getCidade().setIdcidade(Apoio.parseInt(request.getParameter("idCidadeEndEntrga_" + i)));
                    cli.getEnderecosEntrega().add(end);
                }
            }
            //adicionando campos infq
            int maxCampoInfq = Apoio.parseInt(request.getParameter("maxCampoInfQ"));
            ClienteCamposPersonalizadosInfq camposInfq = null;
            for(int i = 1; i <= maxCampoInfq; i++){
                if(request.getParameter("idCampoInfQ_"+i) != null && !request.getParameter("idCampoInfQ_"+i).equals("null")){
                    camposInfq = new ClienteCamposPersonalizadosInfq();
//                    camposInfq.setId(Apoio.parseInt(request.getParameter("idCampoInfQ_"+i)));
                    camposInfq.setDescricaoTagInfq(request.getParameter("descricaoTagInfQ_"+i));
                    camposInfq.setCodUnidadeInfq(request.getParameter("codUndInfQ_"+i));
                    camposInfq.setCampoBancoInfq(request.getParameter("campoBanco_"+i));
                    cli.getClienteCamposInfq().add(camposInfq);
                }
            }
            //adicionando campos do xml
            int maxCampo = Apoio.parseInt(request.getParameter("maxCampo"));
            ClienteCamposPersonalizados camposXml = null;
            for(int i=1; i<=maxCampo; i++){
                if(request.getParameter("idCampo_"+i)!=null && !request.getParameter("idCampo_"+i).equals("null")){
                    camposXml = new ClienteCamposPersonalizados();
                    camposXml.setDescricaoTag(request.getParameter("descricaoTag_"+i));
                    camposXml.setColunaValorCte(request.getParameter("campos_"+i));
                    cli.getClienteCamposXML().add(camposXml);
                }
            }
            int maxColetasAuto = Apoio.parseInt(request.getParameter("qtdColetasAutomaticas"));
            ColetasAutomaticas coletasAutomaticas = null;
            for(int i=1; i<=maxColetasAuto; i++){
                if(request.getParameter("filial_"+i) != null || !request.getParameter("filial_"+i).equals("null")){
                    coletasAutomaticas = new ColetasAutomaticas();
                    coletasAutomaticas.setDiaSemana(Apoio.parseInt(request.getParameter("diaSemana_"+i)));
                    coletasAutomaticas.getFilial().setIdfilial(Apoio.parseInt(request.getParameter("filial_"+i)));
                    coletasAutomaticas.setHora(request.getParameter("hora_"+i));
                    coletasAutomaticas.setId(Apoio.parseInt(request.getParameter("id_"+i)));
                    cli.getColetasAutomaticas().add(coletasAutomaticas);
                }
            }
            int maxFaixaVencimento = Apoio.parseInt(request.getParameter("qtdFaixas"));
            DiasVencimentoFatura diasVencimentoFatura = null;
            if(cli.getTipoPagtoFrete().equals("c") && cli.getTipoPgtoContaCorrente().equals("v")){
                for(int i=1; i<=maxFaixaVencimento; i++){
                        diasVencimentoFatura = new DiasVencimentoFatura();
                        diasVencimentoFatura.setDiaInitial(Apoio.parseInt(request.getParameter("diaInicialFaixaVenc_"+i)));
                        diasVencimentoFatura.setDiaFinal(Apoio.parseInt(request.getParameter("diaFinalFaixaVenc_"+i)));
                        diasVencimentoFatura.setDiaVencimento(Apoio.parseInt(request.getParameter("diaVencimentoFaixaVenc_"+i)));
                        diasVencimentoFatura.setMes(request.getParameter("mesFaixaVenc_"+i));
                        diasVencimentoFatura.setId(Apoio.parseInt(request.getParameter("idFaixaVenc_"+i)));
                        if(request.getParameter("mesFaixaVenc_"+i)!= null){
                            cli.getDiasVencimentoFaturas().add(diasVencimentoFatura);
                        }
                }
            }
            // pegando valores de tipocliente e cliente respseg:
            int maximoExcecao = Apoio.parseInt(request.getParameter("contExcecaoCliente"));
            ClienteRespseg respseg = null;
            for(int x = 0; x < maximoExcecao; x++){
                if(request.getParameter("idClienteRespseg_"+x) != null){
                    respseg = new ClienteRespseg();
                    respseg.setResponsavelSeguro(ClienteRespsegEnum.values()[Apoio.parseInt(request.getParameter("responsavelSeguro_"+x))]);
                    respseg.setTipoCliente(ClienteTipo.values()[Apoio.parseInt(request.getParameter("tipoClienteExcecao_"+x))]);
                    respseg.setId(Apoio.parseInt(request.getParameter("idClienteRespseg_"+x)));
                    respseg.getClienteExcecao().setIdcliente(Apoio.parseInt(request.getParameter("idClienteExcecao_"+x)));
                    cli.getClienteRespseg().add(respseg);
                }
            }
            int maxClienteICMS = Apoio.parseInt(request.getParameter("maxClienteICMS"));
            ClienteICMSFilial clienteICMS = null;
            for(int i = 1; i <=maxClienteICMS; i++){
                if(request.getParameter("idStCliente_"+i) != null){
                    clienteICMS = new ClienteICMSFilial();
                    clienteICMS.setId(Apoio.parseInt(request.getParameter("idStCliente_"+i)));
                    clienteICMS.getFilial().setIdfilial(Apoio.parseInt(request.getParameter("filialICMS_"+i)));
                    clienteICMS.getSituacaoTributavel().setId(Apoio.parseInt(request.getParameter("stIcms_"+i)));
                    clienteICMS.setUsarNormativaGSF598(Apoio.parseBoolean(request.getParameter("isNormativa598_"+i)));
                    clienteICMS.setReducaoBaseIcms(Apoio.parseDouble(request.getParameter("reducaoIcms_"+i)));
                    clienteICMS.setPercentualCreditoPresumido(Apoio.parseDouble(request.getParameter("inputCreditoFiscal_"+i)));
                    clienteICMS.setUsarNormativaGSF129816(Apoio.parseBoolean(request.getParameter("isNormativa129816go_"+i)));
                    cli.getClienteICMSFilials().add(clienteICMS);
                }
            }
            int maxLayEdi_n = Apoio.parseInt(request.getParameter("maxLayEDI_n"));
            ClienteLayoutEDI layoutEdiN = null;
            boolean agruparNfRemDest = false;
            boolean agruparNfUfDestino = false;
            boolean agruparNfNumPed = false;
            boolean importarFilialSelec = false;
            boolean utilizarDadosVeiculo = false;
            boolean cadastrarMercadoria = false;
            boolean importarItemNf = false;
            boolean atualizarDestinatario = false;
            boolean atualizarRemetente = false;
            boolean AtualizarEndeDestinatario = false;
            boolean considerarGrupoClienteProduto = false;
            for(int qtdLayEdiN = 1; qtdLayEdiN <= maxLayEdi_n; qtdLayEdiN++){
                if(request.getParameter("slcLayout_"+qtdLayEdiN) != null){
                    layoutEdiN = new ClienteLayoutEDI("n", cli);
                    layoutEdiN.setId(Apoio.parseInt(request.getParameter("inpHidIdLayoutEdi_"+qtdLayEdiN)));
                    layoutEdiN.setLayoutFormatoAntigo(" ");
                    layoutEdiN.getLayoutEDI().setCodigoLayout(Apoio.parseInt(request.getParameter("slcLayout_"+qtdLayEdiN)));
                    layoutEdiN.getRedespacho().setIdcliente(Apoio.parseInt(request.getParameter("LocalizaIdRedespacho_"+qtdLayEdiN)));
                    layoutEdiN.setAtribuirRedespacho(Apoio.parseBoolean(request.getParameter("chkRedespacho_"+qtdLayEdiN)));
                    layoutEdiN.getDestinatario().setIdcliente(Apoio.parseInt(request.getParameter("LocalizaIdDestinatario_"+qtdLayEdiN)));
                    layoutEdiN.setAtribuirDestinatario(Apoio.parseBoolean(request.getParameter("chkDestinatario_"+qtdLayEdiN)));
                    layoutEdiN.getRemetente().setIdcliente(Apoio.parseInt(request.getParameter("LocalizaIdRemetente_"+qtdLayEdiN)));
                    layoutEdiN.setAtribuirRemetente(Apoio.parseBoolean(request.getParameter("chkRemetente_"+qtdLayEdiN)));
                    layoutEdiN.getConsignatario().setIdcliente(Apoio.parseInt(request.getParameter("LocalizaIdConsignatario_"+qtdLayEdiN)));
                    layoutEdiN.setAtribuirConsignatario(Apoio.parseBoolean(request.getParameter("chkConsignatario_"+qtdLayEdiN)));
                    layoutEdiN.getRepresentante().setIdfornecedor(Apoio.parseInt(request.getParameter("LocalizaIdRepresentante_"+qtdLayEdiN)));
                    layoutEdiN.setAtribuirRepresentante(Apoio.parseBoolean(request.getParameter("chkRepresentante_"+qtdLayEdiN)));
                    layoutEdiN.getRecebedor().setIdcliente(Apoio.parseInt(request.getParameter("LocalizaIdRecebedor_"+qtdLayEdiN)));
                    layoutEdiN.setAtribuirRecebedor(Apoio.parseBoolean(request.getParameter("chkRecebedor_"+qtdLayEdiN)));
                    layoutEdiN.getExpedidor().setIdcliente(Apoio.parseInt(request.getParameter("LocalizaIdExpedidor_"+qtdLayEdiN)));
                    layoutEdiN.setAtribuirExpedidor(Apoio.parseBoolean(request.getParameter("chkExpedidor_"+qtdLayEdiN)));
                    layoutEdiN.setConsiderarFrete(request.getParameter("inpRadTabelaArquivo_"+qtdLayEdiN) != null ? request.getParameter("inpRadTabelaArquivo_"+qtdLayEdiN) : "t");
                    agruparNfRemDest = (request.getParameter("inpRadNotaFiscal_" + qtdLayEdiN) != null && (request.getParameter("inpRadNotaFiscal_" + qtdLayEdiN).equals("s")));
                    layoutEdiN.setAgruparNfRemetenteDestinatario(agruparNfRemDest);
                    agruparNfUfDestino = (request.getParameter("inpRadUfDestino_" + qtdLayEdiN) != null && (request.getParameter("inpRadUfDestino_" + qtdLayEdiN).equals("s")));
                    layoutEdiN.setAgruparNfUfDestino(agruparNfUfDestino);
                    agruparNfNumPed = (request.getParameter("inpRadPedido_" + qtdLayEdiN) != null && (request.getParameter("inpRadPedido_" + qtdLayEdiN).equals("s")));
                    layoutEdiN.setAgruparNfNumeroPedido(agruparNfNumPed);
                    considerarGrupoClienteProduto = (request.getParameter("inpRadCliente_" + qtdLayEdiN) != null && (request.getParameter("inpRadCliente_" + qtdLayEdiN).equals("s")));
                    layoutEdiN.setConsiderarGrupoClienteProduto(considerarGrupoClienteProduto);
                    importarFilialSelec = (request.getParameter("inpRadFilial_" + qtdLayEdiN) != null && (request.getParameter("inpRadFilial_" + qtdLayEdiN).equals("s")));
                    layoutEdiN.setImportarFilialSelecionada(importarFilialSelec);
                    utilizarDadosVeiculo = (request.getParameter("inpRadVeiculo_" + qtdLayEdiN) != null && (request.getParameter("inpRadVeiculo_" + qtdLayEdiN).equals("s")));
                    layoutEdiN.setUtilizarDadosVeiculo(utilizarDadosVeiculo);
                    cadastrarMercadoria = (request.getParameter("inpRadMercadoria_" + qtdLayEdiN) != null && (request.getParameter("inpRadMercadoria_" + qtdLayEdiN).equals("s")));
                    layoutEdiN.setCadastrarMercadoria(cadastrarMercadoria);
                    importarItemNf = (request.getParameter("inpRadItemNota_" + qtdLayEdiN) != null && (request.getParameter("inpRadItemNota_" + qtdLayEdiN).equals("s") ? true : false));
                    layoutEdiN.setImportarItemNf(importarItemNf);
                    atualizarDestinatario = (request.getParameter("inpRadCadDestinatario_" + qtdLayEdiN) != null && (request.getParameter("inpRadCadDestinatario_" + qtdLayEdiN).equals("s") ? true : false));
                    layoutEdiN.setAtualizarDestinatario(atualizarDestinatario);
                    layoutEdiN.setTipoTabelaDestinatario(Apoio.parseInt(request.getParameter("slcTipoTabela_"+qtdLayEdiN)));
                    layoutEdiN.setUtilizarTabelaRemetente(request.getParameter("slcTipoTabelaRemetente_"+qtdLayEdiN) != null ? request.getParameter("slcTipoTabelaRemetente_"+qtdLayEdiN) : "");
                    layoutEdiN.setAgruparPorVeiculo(!request.getParameter("inpAgruparPorVeiculo_" + qtdLayEdiN).equals("n"));
                    layoutEdiN.setSubContratacao(!request.getParameter("inpSubContratacao_" + qtdLayEdiN).equals("n"));
                    layoutEdiN.getRemetenteNotaFiscal().setIdcliente(Apoio.parseInt(request.getParameter("layoutIdRemetente_"+qtdLayEdiN)));
                    layoutEdiN.setBasePadraoCubagem(Apoio.parseDouble(request.getParameter("inpBasePadraoCubagem_"+qtdLayEdiN)));
                    layoutEdiN.setBasePadraoCubagemAereo(Apoio.parseDouble(request.getParameter("inpBasePadraoCubagemAereo_"+qtdLayEdiN)));
                    atualizarRemetente = (request.getParameter("inpRadCadRemetente_" + qtdLayEdiN) != null && (request.getParameter("inpRadCadRemetente_" + qtdLayEdiN).equals("s") ? true : false));
                    layoutEdiN.setAtualizarRemetente(atualizarRemetente);
                    AtualizarEndeDestinatario = (request.getParameter("inpRadAtualizaEndDestinatario_" + qtdLayEdiN) == null || (request.getParameter("inpRadAtualizaEndDestinatario_" + qtdLayEdiN).equals("s") ? true : false));
                    layoutEdiN.setAtualizarEnderecoDestinatario(AtualizarEndeDestinatario);

                    layoutEdiN.setAtribuirResponsavelPagamento(Apoio.parseBoolean(request.getParameter("chkResponsavel_" + qtdLayEdiN)));
                    layoutEdiN.setTipoResponsavelPagamento(Apoio.parseInt(request.getParameter("inpRadResponsavel_" + qtdLayEdiN)));
                    layoutEdiN.setCalcularPrazoTabelaPreco(request.getParameter("inpCalcularPrazoTabelaPreco_" + qtdLayEdiN) != null && request.getParameter("inpCalcularPrazoTabelaPreco_" + qtdLayEdiN).trim().equals("s"));
                    layoutEdiN.setCreatedBy(autenticado);
                    layoutEdiN.setUpdatedBy(autenticado);
                    layoutEdiN.setConsiderarVolume(Apoio.parseInt(request.getParameter("inpTag_"+ qtdLayEdiN)));
                    layoutEdiN.setAgruparNFeEmissao(Apoio.parseBoolean(request.getParameter("agruparNFeDataEmissao_" + qtdLayEdiN)));

                    for (int i = 1; i <= Apoio.parseInt(request.getParameter("qtdDomTagsPersonalizadas_" + qtdLayEdiN)); i++) {
                        if (StringUtils.isNotBlank(request.getParameter("nomeTag_" + qtdLayEdiN + "_" + i))) {
                            ClienteLayoutEDITagPersonalizada clienteLayoutEDITagPersonalizada = new ClienteLayoutEDITagPersonalizada();

                            clienteLayoutEDITagPersonalizada.setId(Apoio.parseInt(request.getParameter("idTag_" + qtdLayEdiN + "_" + i)));
                            clienteLayoutEDITagPersonalizada.setTag(request.getParameter("nomeTag_" + qtdLayEdiN + "_" + i));

                            clienteLayoutEDITagPersonalizada.setCampo(CteTagPersonalizadaCampo.obterCampo(request.getParameter("campoTag_" + qtdLayEdiN + "_" + i)));
                            clienteLayoutEDITagPersonalizada.setClienteLayoutEdiId(layoutEdiN.getId());
                            
                            layoutEdiN.getTagsPersonalizadas().add(clienteLayoutEDITagPersonalizada);
                        }
                    }

                    cli.getLayoutsNOTIFIS().add(layoutEdiN);
                }
            }
                int contador = Apoio.parseInt(request.getParameter("maxExcecoes"));
                for(int i = 0; i < contador; i++){
                    excecao = new ClienteNegociacaoAdiantamentoFrete();
                    excecao.setId(Apoio.parseInt(request.getParameter("idExcecaoCli_"+i)));
                    excecao.getCliente().setIdcliente(Apoio.parseInt(request.getParameter("id")));
                    excecao.getMotorista().setIdmotorista(Apoio.parseInt(request.getParameter("idMotorista_"+i)));
                    excecao.getNegociacao().setId(Apoio.parseInt(request.getParameter("negociacaoMotorCliente_"+i)));
                    cli.getExecoesNegociacao().add(excecao);
                }
                ClienteCnpjCpfAutorizados clienteCnpjCpfAutorizados = null;
                int maxCnpj = Apoio.parseInt(request.getParameter("maxXmlAut")); //idXml_  xmlAut_
                for(int i = 1; i <= maxCnpj; i++){
                    clienteCnpjCpfAutorizados = new ClienteCnpjCpfAutorizados();
                    clienteCnpjCpfAutorizados.setId(Apoio.parseInt(request.getParameter("idXml_"+i)));
                    clienteCnpjCpfAutorizados.setCnpjcpf(request.getParameter("xmlAut_"+i).replaceAll("\\D+",""));
                    clienteCnpjCpfAutorizados.setTipo(request.getParameter("tpAut_"+i));
                    cli.getClienteCnpjCpfAutorizados().add(clienteCnpjCpfAutorizados);
                }
            if (!erroValidacao){
                if (acao.equals("atualizar")) {
                    cli.setIdcliente(Integer.parseInt(request.getParameter("id")));
                    cadCli.setCliente(cli);
                    executou = cadCli.Atualiza();
                } else if (acao.equals("incluir") && nivelUser >= 3) {
                    cadCli.setCliente(cli);
                    executou = cadCli.Inclui();
                }
            }
            String scr = "";
            String mensagemErro = "";
            if (!executou) {
                if(cadCli.getErros().contains("cliente_st_icms_filial_cliente_id_filial_id_key")){
                    mensagemErro = "Não poder ser incluída a mesma filial no cadastro de Situação Tributária ICMS!";
                    scr = "<script>";
                    scr += "alert('" + mensagemErro + "');";
                    scr += "window.close();"
                            + "window.opener.document.getElementById('gravar').disabled = false;"
                            + "window.opener.document.getElementById('gravar').value = 'Salvar';"
                            + "</script>";
                    acao = (acao.equals("atualizar") ? "editar" : "iniciar");
                }else if(cadCli.getErros().contains("cliente_taxas_xml_cliente_taxa_uk")){
                    mensagemErro = "Existem taxas duplicadas!";
                    scr = "<script>";
                    scr += "alert('" + mensagemErro + "');";
                    scr += "window.close();"
                            + "window.opener.document.getElementById('gravar').disabled = false;"
                            + "window.opener.document.getElementById('gravar').value = 'Salvar';"
                            + "</script>";
                }else if(cadCli.getErros().contains("cliente_id_tp_conhecimento_uk")){
                    mensagemErro = "Existem dois ou mais registros com o mesmo tipo de TAG e CT-e!";
                    scr = "<script>";
                    scr += "alert('" + mensagemErro + "');";
                    scr += "window.close();"
                            + "window.opener.document.getElementById('gravar').disabled = false;"
                            + "window.opener.document.getElementById('gravar').value = 'Salvar';"
                            + "</script>";
                }else if(cadCli.getErros().contains("cliente_id_tp_servico_uk")){
                    mensagemErro = "Existem dois ou mais registros com o mesmo tipo de TAG e Serviço!";
                    scr = "<script>";
                    scr += "alert('" + mensagemErro + "');";
                    scr += "window.close();"
                            + "window.opener.document.getElementById('gravar').disabled = false;"
                            + "window.opener.document.getElementById('gravar').value = 'Salvar';"
                            + "</script>";
                }else{
                        scr = "<script>";
                        scr += "alert('" + (erroValidacao ? msgValidacao : cadCli.getErros()) + "');";
                        scr += "window.close();"
                                + "window.opener.document.getElementById('gravar').disabled = false;"
                                + "window.opener.document.getElementById('gravar').value = 'Salvar';"
                                + "</script>";
                        acao = (acao.equals("atualizar") ? "editar" : "iniciar");
                }
            } else {
                scr = "<script>"
                        + "window.opener.document.location.replace('ConsultaControlador?codTela=10');"
                        + "window.close();"
                        + "</script>";
            }
            response.getWriter().append(scr);
            response.getWriter().close();
        } else if (acao.equals("cadastroExterior")) {
            String razaoSocial = request.getParameter("rzs");
            String endereco = request.getParameter("endereco");
            String bairro = (request.getParameter("bairro"));
            String uf = (request.getParameter("uf"));
            String cidade=(request.getParameter("cidade"));
            String cep = (request.getParameter("cep"));
            String complemento = (request.getParameter("compl"));
            cli.setRazaosocial(razaoSocial==null? "": razaoSocial);
            cli.setEndereco(endereco==null? "": endereco);
            cli.setBairro(bairro==null? "": bairro);
            cli.getCidade().setUf(uf==null? "": uf);
            cli.getCidade().setDescricaoCidade(cidade.equals("undefined")? "": cidade);
            cli.setCep(cep.equals("undefined")? "": cep);
            cli.setComplemento(complemento==null? "": complemento);
        }
        if (acao.equals("getEnderecoByCep")) {
            WebServiceCep webServiceCep = WebServiceCep.searchCep(request.getParameter("cep"));
            String resposta = "";
            if (webServiceCep.wasSuccessful()) {
                BeanConsultaCidade daoCidade = new BeanConsultaCidade();
                daoCidade.setConexao(autenticado.getConexao());
                int idCidade = daoCidade.localizarIdCidade(webServiceCep.getCidade(), webServiceCep.getUf());
                String bairro = webServiceCep.getBairro().length() < 25 ? webServiceCep.getBairro().toUpperCase() : webServiceCep.getBairro().toUpperCase().substring(0, 24);
                BairroDAO bairroDAO = new BairroDAO();
                int idBairro = bairroDAO.getIdBairro(Apoio.replaceCharSet(webServiceCep.getBairro().toUpperCase()), idCidade);
                if(idBairro == 0 && idCidade != 0){
                   new BairroDAO().cadastrarCep(idCidade, Apoio.replaceCharSet(webServiceCep.getBairro()), autenticado);
                   idBairro = new BairroDAO().getIdBairro(Apoio.replaceCharSet(webServiceCep.getBairro().toUpperCase()), idCidade);
                }
                resposta = "@@" + webServiceCep.getLogradouroFull().toUpperCase() + "@@"
                        + bairro + "@@"
                        + (idBairro != 0 ? idBairro : "0") + "@@"
                        + (idCidade != 0 ? webServiceCep.getCidade().toUpperCase() : "") + "@@"
                        + (idCidade != 0 ? idCidade : "0") + "@@"
                        + webServiceCep.getUf().toUpperCase() + "@@"
                        + webServiceCep.getCidade().toUpperCase() + "@@";
                //PrintWriter out = response.getWriter();
                out.println(resposta);
                //out.close();
            } else {
                resposta = "@@" + "@@" + "@@" + "@@" + "0@@";
                //PrintWriter out = response.getWriter();
                out.println(resposta);
                //out.close();
            }
        }
    }
    if (acao.equals("verificar_cgc")) {
        String resultado = cadCli.getVerificaCgc(request.getParameter("cnpj"));
        response.getWriter().append(resultado);
        response.getWriter().close();
    }
    if (acao.equals("removerEnderecoEntrega")) {
        int id = Apoio.parseInt(request.getParameter("idEndereco"));
            String mensagem =  BeanCadCliente.removerEnderecoEntrega(id, autenticado);
            response.getWriter().append(mensagem);
            response.getWriter().close();
    }
    if (acao.equals("removerCamposXML")) {
        int id = Apoio.parseInt(request.getParameter("id"));
        int idCliente = Apoio.parseInt(request.getParameter("idCliente"));
        BeanCadCliente beanCadCliente = new BeanCadCliente();
        beanCadCliente.setConexao(Apoio.getUsuario(request).getConexao());
        beanCadCliente.setExecutor(Apoio.getUsuario(request));
        beanCadCliente.DeletarCampos(id, idCliente, autenticado);
        response.getWriter().append("Removido com sucesso!");
        response.getWriter().close();
    }
    if (acao.equals("removerCamposInfq")){
        int id = Apoio.parseInt(request.getParameter("id"));
        int idCliente = Apoio.parseInt(request.getParameter("idCliente"));
        BeanCadCliente beanCadCliente = new BeanCadCliente();
        beanCadCliente.setConexao(Apoio.getUsuario(request).getConexao());
        beanCadCliente.setExecutor(Apoio.getUsuario(request));
        beanCadCliente.DeletarCamposInfq(id, idCliente, autenticado);
        response.getWriter().append("Removido com sucesso!");
        response.getWriter().close();
    }
    if (acao.equals("removerTaxaXML")) {
        int id = Apoio.parseInt(request.getParameter("id"));
        int idCliente = Apoio.parseInt(request.getParameter("idCliente"));
        BeanCadCliente beanCadCliente = new BeanCadCliente();
        beanCadCliente.setConexao(Apoio.getUsuario(request).getConexao());
        beanCadCliente.setExecutor(Apoio.getUsuario(request));
        beanCadCliente.deleteTaxasXML(id, idCliente, autenticado);
        response.getWriter().append("Removido com sucesso!");
        response.getWriter().close();
    }
    if (acao.equals("removerCamposDiaria")) {
        int idCampoDiaria = Apoio.parseInt(request.getParameter("idCampoDiaria"));
        BeanCadCliente beanCadClienteDiaria = new BeanCadCliente();
        beanCadClienteDiaria.setConexao(Apoio.getUsuario(request).getConexao());
        beanCadClienteDiaria.setExecutor(Apoio.getUsuario(request));
        beanCadClienteDiaria.deletarVeiculoDiariaParada(idCampoDiaria, autenticado);
        response.getWriter().append("Removido com sucesso!");
        response.getWriter().close();
    }
    if (acao.equals("removerClienteRespseg")) {
        int idClienteRespseg = Apoio.parseInt(request.getParameter("idClienteRespseg"));
        BeanCadCliente beanCadCliente = new BeanCadCliente();
        beanCadCliente.setConexao(Apoio.getUsuario(request).getConexao());
        beanCadCliente.setExecutor(Apoio.getUsuario(request));
        beanCadCliente.excluirClienteRespseg(idClienteRespseg, autenticado);
        response.getWriter().append("Removido com sucesso!");
        response.getWriter().close();
    }
    if (acao.equals("removerColetas")) {
        int id = Apoio.parseInt(request.getParameter("id"));
        int idCliente = Apoio.parseInt(request.getParameter("idCliente"));
        BeanCadCliente beanCadCliente = new BeanCadCliente();
        beanCadCliente.setConexao(Apoio.getUsuario(request).getConexao());
        beanCadCliente.setExecutor(Apoio.getUsuario(request));
        beanCadCliente.deletarColetasAutomaticas(id, idCliente, autenticado);
        response.getWriter().append("Removido com sucesso!");
        response.getWriter().close();
    }
    if (acao.equals("removerFaixaVencimento")) {
        int id = Apoio.parseInt(request.getParameter("idFaixa"));
        BeanCadCliente.removerFaixaVencimento(id, autenticado);
        response.getWriter().append("Removido com sucesso!");
        response.getWriter().close();
    }
    if (acao.equals("excluirOcorrenciaCliente")) {
        int id = Apoio.parseInt(request.getParameter("id"));
        BeanCadCliente.deletarOcorrenciaCliente(id, autenticado);
        response.getWriter().append("Removido com sucesso!");
        response.getWriter().close();
    }
     if (acao.equals("removerStICMS")) {
        int id = Apoio.parseInt(request.getParameter("id"));
        int idCliente = Apoio.parseInt(request.getParameter("idCliente"));
        BeanCadCliente beanCadCliente = new BeanCadCliente();
        beanCadCliente.setConexao(Apoio.getUsuario(request).getConexao());
        beanCadCliente.setExecutor(Apoio.getUsuario(request));
        beanCadCliente.DeletarSTICMS(id, idCliente, autenticado);
        response.getWriter().append("Removido com sucesso!");
        response.getWriter().close();
    }
     if (acao.equals("ajaxRemoverMomentoLayoutEDI")) {
        String id = request.getParameter("idMomentoLayoutEDI");
        BeanCadCliente bean = new BeanCadCliente();
        bean.setConexao(Apoio.getUsuario(request).getConexao());
        bean.setExecutor(Apoio.getUsuario(request));
        bean.deleteMomentoLayoutEDI(id, Apoio.getUsuario(request));
    }
     if (acao.equals("removerContatoCliente")) {
        String idContato = request.getParameter("idContato");
        cadCli = new BeanCadCliente();
        cadCli.setConexao(autenticado.getConexao());
        cadCli.setExecutor(autenticado);
        cadCli.removerContatoCliente(idContato);
    }
     if (acao.equals("removerTaxaXML")) {
        int id = Apoio.parseInt(request.getParameter("id"));
        int idCliente = Apoio.parseInt(request.getParameter("idCliente"));
        BeanCadCliente beanCadCliente = new BeanCadCliente();
        beanCadCliente.setConexao(Apoio.getUsuario(request).getConexao());
        beanCadCliente.setExecutor(Apoio.getUsuario(request));
        beanCadCliente.deleteTaxasXML(id, idCliente, autenticado);
        response.getWriter().append("Removido com sucesso!");
        response.getWriter().close();
    }
    if (acao.equals("removerXmlAutorizadores")) {
        String id = (request.getParameter("id"));
        String idCliente = (request.getParameter("idCliente"));
        BeanCadCliente beanCadCliente = new BeanCadCliente();
        beanCadCliente.setConexao(Apoio.getUsuario(request).getConexao());
        beanCadCliente.setExecutor(Apoio.getUsuario(request));
        beanCadCliente.removerXmlAutorizadores(id, idCliente);
        response.getWriter().append("Removido com sucesso!");
        response.getWriter().close();
    }
    
    if ("excluirTagPersonalizada".equals(acao)) {
        String id = (request.getParameter("id"));
        BeanCadCliente beanCadCliente = new BeanCadCliente();
        beanCadCliente.setConexao(Apoio.getUsuario(request).getConexao());
        beanCadCliente.setExecutor(Apoio.getUsuario(request));
        beanCadCliente.excluirTagPersonalizada(id);
        response.getWriter().append("Removido com sucesso!");
        response.getWriter().close();
    }
    boolean carregacli = (cadCli != null && (!acao.equals("incluir") || !acao.equals("atualizar")));
    request.setAttribute("carregacli", carregacli);
    request.setAttribute("cli", cli);
%>
<script language="javascript" type="text/javascript">
   jQuery.noConflict();
    arAbasGenerico = new Array();
    arAbasGenerico[0] = new stAba('tdContatos','tab1');
    arAbasGenerico[1] = new stAba('tdInfoFinan','tab2');
    arAbasGenerico[2] = new stAba('tdEndColEnt','tab3');
    arAbasGenerico[3] = new stAba('tdInfoOpe','tab5');
    arAbasGenerico[4] = new stAba('tdInfoCont','tab6');
    <%  if (Apoio.getUsuario(request).getAcesso("cadtabelacliente") >= NivelAcessoUsuario.LER.getNivel()) {%>
        arAbasGenerico[5] = new stAba('tdTabPreco','tab7');
    <%}%>
    arAbasGenerico[6] = new stAba('tdInfoCom','tab4');
    arAbasGenerico[7] = new stAba('tdAbaEdi','tab8');
    arAbasGenerico[8] = new stAba('tdAbaAuditoria','divAuditoria');
    arAbasGenerico[9] = new stAba('tdRastrCarga','tab9');
    //Não sei bem o porque mas tenho que abrir uma tag do javascript com o src e fechá-la,
    //para usar as funções do arquivo .js tenho que abrir uma nova tag
    var camposConsultaCliente = new CamposSituacaoPessoa();
    camposConsultaCliente.idC7NPJ = "cnpj";
    camposConsultaCliente.idRazaoSocial = "rzs" ;
    camposConsultaCliente.idNomeFantasia = "nomefantasia";
    camposConsultaCliente.idCep = "cep";
    camposConsultaCliente.idLogradouro = "endereco";
    camposConsultaCliente.idLogradouroNumero = "numeroLogradouro";
    camposConsultaCliente.idComplemento = "compl";
    camposConsultaCliente.idBairro = "bairro";
    var listaTipoCliente = new Array();
    var listaResponsavelSeguro = new Array();
    var listaNotfisAutomaticas = new Array();
    var countNotfis = 0;
    var countIndexLayout = 0;
    var listaNegociacoes = new Array();
    var countNegociacaos = 0;
    var listaExecoesdeNegocios = new Array();
    var countExecoesdeNegocios = 0;
    //Dados carregados da configuração para o DOM de Notfis
    var importacaoLote = new ImportacaoLote();
    <%if(cfg.getLayoutImportacaoXmlDanfe().equals("c")){%>
        importacaoLote.codigoLayoutEdi = "2";
    <%}%>
    importacaoLote.isAtualizarDestinatario = '<%=cfg.isAtualizarClienteImportacaoEdi()%>';
    importacaoLote.isCadastrarMercadoria = '<%=cfg.isImportarCtrcNotaMercadoria()%>';
    importacaoLote.isImportarItemNf = '<%=cfg.isImportarCtrcNotaItem()%>';
    importacaoLote.isAtualizarRemetente = '<%=cfg.isAtualizarClienteImportacaoEdi()%>';
    
     function verTabela(id){
        // foi reportado que o nivel para abrir o cadastro deve ser no minimo LER e não LER_ALTERAR.
        <%  if(Apoio.getUsuario(request).getAcesso("cadtabelacliente")  >= NivelAcessoUsuario.LER.getNivel()){ %>
        window.open("./cadtabela_preco.jsp?acao=editar&id="+id, "Cadastrar Tabela de Preco" , "top=0,resizable=yes,status=1,scrollbars=1");
        <%}%>
    }
    
    function verContrato(id){
        // foi reportado que o nivel para abrir o cadastro deve ser no minimo LER e não LER_ALTERAR.
        <%  if(Apoio.getUsuario(request).getAcesso("contratocomercial")  >= NivelAcessoUsuario.LER.getNivel()){ %>
        window.open("ContratoComercialControlador?acao=carregar&id=" + id + "&codTela=80");
        <%}%>
    }
    function aoCarregar(){
        exibiQtdMaximaElayoutImpressao();
        responsabilidadeAverbacao();
        if($('etiquetaLayoutImpressao').value == ""){
            $('etiquetaLayoutImpressao').value = 'Padrão';
        }
        if($("chkativo").checked == false){
            $("inativo").style.display = ($('chkativo').checked ? "none" : "");
        }
        if($('chkOcorrenciasCliente').checked == false  ){
            $("tabelaOcorrencia").style.display = ($('chkOcorrenciasCliente').checked ? "" : "none");
        }
        tipoClienteA();
        label();
        if(<%=nivelUser%> == 4){
            $("tableAuditoria").style.display = "";
        }else{
            $("tableAuditoria").style.display = "none";
        }
        if(("<%=cli.getTipoEnvioEmailCte()%>") =='x'){
            $("xml").checked=true;
            $("dacte").disabled= false;
            $("xdacte").disabled= false;
        }else if(("<%=cli.getTipoEnvioEmailCte()%>") =='d'){
            $("xml").disabled= false;
            $("dacte").checked=true;
            $("xdacte").disabled= false;
        }else{
            $("xml").disabled= false;
            $("dacte").disabled= false;
            $("xdacte").checked= true;
        }
        if(("<%=cli.getAnexarComprovante()%>") == 's'){
            $("anexar").checked= true;
            $("naoAnexar").checked= false;
        }else{
            $("anexar").checked= false;
            $("naoAnexar").checked= true;
        }
        checkEnvioEmailMDF(<%=cli.getTipoEnvioEmailMDF()%>);
    var listPermissaoCont = new Array();
        var listGrupoCont = new Array();
        <%int g = 0;for(BeanGrupoProduto gprodutos : listaGp){%>
        listGrupoCont['<%=g%>'] = new Grupo('<%=gprodutos.getId()%>','<%=gprodutos.getDescricao()%>');
        listGrupo['<%=g%>'] = new Grupo('<%=gprodutos.getId()%>','<%=gprodutos.getDescricao()%>');
        <%g++;}%>
        listPermissao[0] = new Permissao('0','Consultar estoque dos grupos','0',true);
        listPermissaoCont[0] = new Permissao('0','Consultar estoque dos grupos','0',true);
        <%for(int i = 0;i<listaPermtest.size();i++){
            BeanPermissaoContato perm = new BeanPermissaoContato();
            perm = listaPermtest.get(i);
        %>
            listPermissao['<%=i+1%>'] = new Permissao('<%=perm.getId()%>','<%=perm.getDescricao()%>');
            listPermissaoCont['<%=i+1%>'] = new Permissao('<%=perm.getId()%>','<%=perm.getDescricao()%>');
        <%}%>
        criterioCalculoComissao('<%=cli.getCalcularComissaoVendedor()%>','Vendedor');
        criterioCalculoComissao('<%=cli.getCalcularComissaoSupervisor()%>','Supervisor');
        //carrega todos os layout notfis para ser utilizado no DOM de importação em lote.
        <c:forEach var="notfis" varStatus="status" items="${listaLayoutNOTFIS}">
            listaNotfisAutomaticas[++countNotfis] = new Option('${notfis.codigoLayout}','${notfis.descricao}');
        </c:forEach>
    <%  if (carregacli) {
            //adicioonando os ajudantes
            for (int u = 0; u < cli.getTipoProduto().length; ++u) {
                TipoProduto tp = cli.getTipoProduto()[u];%>
                        addTipoProduto("<%=tp.getDescricao()%>","<%=tp.getId()%>");
    <%          }
        for (int ui = 0; ui < cli.getTabelaRemetente().length; ++ui) {
            BeanCliente clT = cli.getTabelaRemetente()[ui];%>
                    addRemetente('<%=clT.getIdcliente()%>', '<%=clT.getRazaosocial()%>', '<%=clT.getCnpj()%>', '<%=clT.getCidade().getDescricaoCidade()%>', '<%=clT.getCidade().getUf()%>', '<%=clT.getTipo_tabela()%>');
    <%          }%>
            $("tipoBaseComissao").value = "<%=cli.getTipoBaseComissao()%>";
            $("tipoCobranca").value = "<%=cli.getTipoCobranca()%>";
            $("periodicidade").value = "<%= cli.getPeriodicidadeFaturamento() %>";
            //adicioonando os contatos
    <%for (int c = 0; c < cli.getContatos().length; ++c) {
            BeanContato cont = cli.getContatos()[c];%>
            var contato = new Contato();
            contato.id = '<%=cont.getId()%>';
            contato.contato = '<%=cont.getContato()%>';
            contato.email = '<%=cont.getEmail()%>';
            contato.setor = '<%=cont.getSetor()%>';
            contato.fone = '<%=cont.getFone()%>';
            contato.ramal = '<%=cont.getRamal()%>';
            contato.celular = '<%=cont.getCelular()%>';
            contato.recebeEmailCobranca = '<%=cont.isRecebeEmailCobranca()%>';
            contato.recebeEmailEntrega = '<%=cont.isRecebeEmailEntrega()%>';
            contato.receberEmailEdi = '<%=cont.isReceberEmailEdi()%>';
            contato.isUsuario = 'true';
            contato.login = '<%=(cont.getLogin() == null ? "" : cont.getLogin())%>';
            contato.senha = '<%=(cont.getSenha() == null ? "" : cont.getSenha())%>';
            var selecionado = false;
            var t = 0;
            <%for(BeanGrupoProduto bgp : cont.getGrupoProduto()){%>
                listGrupoCont[t].isSelecionado = '<%=bgp.isSelecionado()%>';
                listGrupoCont[t].idContatoGrupo = '<%=bgp.getIdContatoGrupo()%>';
                if('<%=bgp.isSelecionado()%>' == "true"){
                    selecionado = true;
                }
                t++;
            <%}%>
            contato.listGrupoCont = listGrupoCont;
            var p = 1;
            if(t >= 1 && selecionado){
                listPermissaoCont[0].nivel =  "1";
            }
            <%for(BeanPermissaoContato bpc : cont.getPermissoes()){%>
                listPermissaoCont[p].nivel = '<%=bpc.getNivel()%>';
                listPermissaoCont[p].idPermGwCli = '<%=bpc.getIdPermissaoGwCli()%>';
                p++;
            <%}%>
            if(t >= 1 && selecionado){
                listPermissaoCont[0].nivel =  "1";
            }
            contato.listPermissaoCont = listPermissaoCont;
            addContato(contato);
            mostrarEstoqueGrupos('<%=c+1%>',1);
    <%}%>
            var endereco;
    <%for (Endereco endereco : cli.getEnderecosEntrega()) {%>
            endereco = new Endereco(<%=endereco.getId()%>, "<%=endereco.getLograoduro()%>",
            "<%=endereco.getCep()%>", "<%=endereco.getNumeroLogradouro()%>",
            "<%=endereco.getComplemento()%>", "<%=endereco.getCidade().getIdcidade()%>",
            "<%=endereco.getCidade().getDescricaoCidade()%>", "<%=endereco.getBairro()%>", "<%=endereco.getCidade().getUf()%>",
            <%=endereco.getBairroBean().getIdBairro() %>, "<%=endereco.getBairroBean().getDescricao()%>");
            addEndereco(endereco, $('tbodyEnderecosEntrega'));
    <%}%>
     var listaTarefa = null;
     var cron = null;
     var countCronAux = 0;
    <%for (ClienteLayoutEDI layout : cli.getLayoutsCONEMB()) {%>
            listaTarefas = new Array();
            countCronAux = 0;
            <%for (TarefaAgendadaClienteLayoutEDI tarefa : layout.getTarefas()) {%>
                cron = new Cron("<%=tarefa.getId()%>", "<%=tarefa.getCronExpression()%>");
                listaTarefas[countCronAux++] = cron;
            <%}%>
            addClienteLayoutEDI("c", "<%=layout.getLayout()%>","<%=layout.getId()%>" , "<%=layout.getTipoGeracaoEDI()%>", listaTarefas, null, null, null, "<%= layout.getExtensaoArquivo() %>");
    <%}%>
    <%for (ClienteLayoutEDI layout : cli.getLayoutsDOCCOB()) {%>
            listaTarefas = new Array();
            countCronAux = 0;
            <%for (TarefaAgendadaClienteLayoutEDI tarefa : layout.getTarefas()) {%>
                cron = new Cron("<%=tarefa.getId()%>", "<%=tarefa.getCronExpression()%>");
                listaTarefas[countCronAux++] = cron;
            <%}%>
            addClienteLayoutEDI("f", "<%=layout.getLayout()%>","<%=layout.getId()%>" , "<%=layout.getTipoGeracaoEDI()%>", listaTarefas, null, null, null, "<%= layout.getExtensaoArquivo() %>");
    <%}%>
    countCronAux = 0;
    <%for (ClienteLayoutEDI layout : cli.getLayoutsOCOREN()) {%>
            listaTarefas = new Array();
            countCronAux = 0;
            <%for (TarefaAgendadaClienteLayoutEDI tarefa : layout.getTarefas()) {%>
                cron = new Cron("<%=tarefa.getId()%>", "<%=tarefa.getCronExpression()%>");
                listaTarefas[countCronAux++] = cron;
            <%}%>
            addClienteLayoutEDI("o", "<%=layout.getLayout()%>","<%=layout.getId()%>", "<%=layout.getTipoGeracaoEDI()%>", listaTarefas, "<%=layout.getLogin()%>","<%=layout.getSenha()%>","<%=layout.getChave()%>", "<%= layout.getExtensaoArquivo() %>");
    <%}%>
        var campos;
    <% if(cli.getClienteCamposXML().size()>0){
         for (ClienteCamposPersonalizados clienteCampos : cli.getClienteCamposXML()) {%>
             campos = new Campos(<%=clienteCampos.getId()%>, '<%=clienteCampos.getDescricaoTag()%>', '<%=clienteCampos.getColunaValorCte()%>');
             addCampos(campos);
    <%}}%>
    var camposInfq;
    <% if(cli.getClienteCamposInfq().size()>0){
         for (ClienteCamposPersonalizadosInfq clienteInfq : cli.getClienteCamposInfq()) {%>
             camposInfq = new CamposInfq(<%=clienteInfq.getId()%>, '<%=clienteInfq.getDescricaoTagInfq()%>', '<%=clienteInfq.getCodUnidadeInfq()%>','<%=clienteInfq.getCampoBancoInfq()%>');
             addCampoInfQ(camposInfq);
    <%}}%>
        var coletas;
    <% if(cli.getColetasAutomaticas().size()>0){
         for (ColetasAutomaticas coletasAutomaticas : cli.getColetasAutomaticas()) {%>
             coletas = new ColetasAutomaticas('<%=coletasAutomaticas.getId()%>', '<%=coletasAutomaticas.getFilial().getIdfilial()%>', '<%=coletasAutomaticas.getFilial().getAbreviatura()%>', '<%=coletasAutomaticas.getDiaSemana()%>','<%=coletasAutomaticas.getHora()%>');
             addColetasAutomaticas(coletas, $('tbodyColetasAutomaticas'));
    <%}}%>
        var diasVencimento;
    <% if(cli.getTipoPagtoFrete() != null && cli.getTipoPgtoContaCorrente() != null && cli.getTipoPagtoFrete().equals("c") && cli.getTipoPgtoContaCorrente().equals("v") && cli.getDiasVencimentoFaturas().size()>0){
         for (DiasVencimentoFatura diasVencimentoFatura : cli.getDiasVencimentoFaturas()) {%>
             diasVencimento = new DiasVencimentoFatura('<%=diasVencimentoFatura.getId()%>', '<%=diasVencimentoFatura.getDiaInitial()%>', '<%=diasVencimentoFatura.getDiaFinal()%>', '<%=diasVencimentoFatura.getDiaVencimento()%>','<%=diasVencimentoFatura.getMes()%>');
             addFaixaVencimento(diasVencimento, $('tbodyFaixaVencimento'));
    <%}}else{%>
        $("FaixaVencimento").style.display = "none";
        <%}%>
       var ocorrencias;
    <% if(cli.getOcorrenciaClienteEdi().size()>0){
        for (OcorrenciaCliente ocorrenciaCliente : cli.getOcorrenciaClienteEdi()) {%>
                ocorrencias = new OcorrenciaEdi();
                ocorrencias.id = '<%=ocorrenciaCliente.getId()%>';
                ocorrencias.ocorrenciaid = '<%=ocorrenciaCliente.getOcorrencia().getId()%>';
                ocorrencias.descricaoOcorrencia = '<%=ocorrenciaCliente.getOcorrencia().getDescricao()%>';
                ocorrencias.codigoEspecificoEdi = '<%=ocorrenciaCliente.getCodigoEspecificoEdi()%>';
                addOcorrenciaEdi(ocorrencias, $('tb_ocorrencia'));
    <%}}%>
        var camposDiarias;
    <%
    if(cli.getDiariasParadasBeanCliente().size()>0){
    for (DiariasParadas diariasParadas : cli.getDiariasParadasBeanCliente()) {%>
         camposDiarias = new CamposDiarias(<%=diariasParadas.getIdDiariasParadas()%>,<%=diariasParadas.getBeanClienteDiariasParadas().getIdcliente()%>, <%=diariasParadas.getValorDiarias()%>,
              <%=diariasParadas.getTipoVeiculoDiariasParadas().getId()%>,'<%=diariasParadas.getTipoVeiculoDiariasParadas().getDescricao()%>',
              <%=diariasParadas.getTipoProdutoDiariasParadas().getId()%>,'<%=diariasParadas.getTipoProdutoDiariasParadas().getDescricao()%>',
              <%=diariasParadas.getCidadeDiarias().getIdcidade()%>,'<%=diariasParadas.getCidadeDiarias().getDescricaoCidade()%>','<%=diariasParadas.getCidadeDiarias().getUf()%>');
         addCampoDiarias(camposDiarias);
    <%}}%>
        alterarDefaultTipoFrete();
        var stICMS;
    <%
        if(cli.getClienteICMSFilials().size() > 0){
            for (ClienteICMSFilial clienteICMSFilial : cli.getClienteICMSFilials()) {%>
                 stICMS = new StICMS(<%=clienteICMSFilial.getId()%>,<%=clienteICMSFilial.getSituacaoTributavel().getId()%>, <%=clienteICMSFilial.getFilial().getIdfilial()%>, <%=clienteICMSFilial.isUsarNormativaGSF598() %>,<%=clienteICMSFilial.getReducaoBaseIcms() %>, <%= clienteICMSFilial.getPercentualCreditoPresumido() %>, <%= clienteICMSFilial.isUsarNormativaGSF129816() %>);
         addStICMS(stICMS);
    <%}}%>
         var taxas;
    <%
        if(cli.getClienteTaxasXML().size()>0){
         for (ClienteTaxasXML clientetaxas : cli.getClienteTaxasXML()) {%>
             taxas = new Taxas(<%=clientetaxas.getId()%>, '<%=clientetaxas.getNomeCampo()%>', <%=clientetaxas.getClienteTaxas().getId()%> ,
             '<%=clientetaxas.getClienteTaxas().getNomeTaxa()%>', '<%=clientetaxas.isIgnorarXml()%>');
             addCamposTaxas(taxas);
    <%}}%>
       <%for (ClienteLayoutEDI layout : cli.getLayoutsNOTIFIS()) {%>
                var importacaoLote = new ImportacaoLote('<%=layout.getId()%>','<%=layout.getLayoutEDI().getCodigoLayout()%>','<%=layout.isAtribuirRedespacho()%>',
                '<%=layout.getRedespacho().getIdcliente()%>','<%=layout.getRedespacho().getRazaosocial()%>','<%=layout.isAtribuirDestinatario()%>',
                '<%=layout.getDestinatario().getIdcliente()%>','<%=layout.getDestinatario().getRazaosocial()%>','<%=layout.isAtribuirRemetente()%>',
                '<%=layout.getRemetente().getIdcliente()%>','<%=layout.getRemetente().getRazaosocial()%>','<%=layout.isAtribuirConsignatario()%>',
                '<%=layout.getConsignatario().getIdcliente()%>','<%=layout.getConsignatario().getRazaosocial()%>','<%=layout.isAtribuirRepresentante()%>',
                '<%=layout.getRepresentante().getIdfornecedor()%>','<%=layout.getRepresentante().getRazaosocial()%>','<%=layout.isAtribuirRecebedor()%>',
                '<%=layout.getRecebedor().getIdcliente()%>','<%=layout.getRecebedor().getRazaosocial()%>','<%=layout.isAtribuirExpedidor()%>',
                '<%=layout.getExpedidor().getIdcliente()%>','<%=layout.getExpedidor().getRazaosocial()%>','<%=layout.getConsiderarFrete()%>',
                '<%=layout.isAgruparNfRemetenteDestinatario()%>','<%=layout.isAgruparNfUfDestino()%>','<%=layout.isAgruparNfNumeroPedido()%>','<%=layout.isConsiderarGrupoClienteProduto()%>',
                '<%=layout.isImportarFilialSelecionada()%>','<%=layout.isUtilizarDadosVeiculo()%>','<%=layout.isCadastrarMercadoria()%>',
                '<%=layout.isImportarItemNf()%>','<%=layout.isAtualizarDestinatario()%>','<%=layout.getTipoTabelaDestinatario()%>',
                '<%=layout.getUtilizarTabelaRemetente()%>','<%=layout.isAgruparPorVeiculo()%>',
                '<%=layout.getRemetenteNotaFiscal().getIdcliente()%>','<%=layout.getRemetenteNotaFiscal().getRazaosocial()%>','<%=layout.isSubContratacao()%>',
                '<%=layout.getBasePadraoCubagem()%>','<%=layout.isAtualizarRemetente()%>','<%=layout.isAtualizarEnderecoDestinatario()%>','<%=layout.getBasePadraoCubagemAereo()%>',
                '<%=layout.isAtribuirResponsavelPagamento()%>','<%=layout.getTipoResponsavelPagamento()%>','<%=layout.isCalcularPrazoTabelaPreco()%>','<%=layout.getConsiderarVolume()%>','<%=layout.isAgruparNFeEmissao()%>');
                addImportacaoLote(listaNotfisAutomaticas,importacaoLote);
                countIndexLayout++;
                mostrarLocalizaRedespacho(countIndexLayout);mostrarLocalizaDestinatario(countIndexLayout);mostrarLocalizaRemetente(countIndexLayout);mostrarLocalizaConsignatario(countIndexLayout);mostrarLocalizaRepresentante(countIndexLayout);mostrarLocalizaRecebedor(countIndexLayout);mostrarLocalizaExpedidor(countIndexLayout);
                <c:forEach var="tagPersonalizada" items="<%= layout.getTagsPersonalizadas() %>">
                    aoClicarAdicionarTags(countIndexLayout, undefined, {'nome_tag': '${tagPersonalizada.tag}','campo': '${tagPersonalizada.campo.campo}','id': '${tagPersonalizada.id}'});
                </c:forEach>
       <%}%>
        <%if(cli.isImpostoFederalIcmsVendedor() && cli.isImpostoFederalPisVendedor() && cli.isImpostoFederalCofinsVendedor() && cli.isImpostoFederalCsslVendedor() && cli.isImpostoFederalIrVendedor() && cli.isImpostoFederalInssVendedor()){%>
            $("impostoFederaisVendedor").checked = true;
        <%}%>
        <%if(cli.isImpostoFederalIcmsSupervisor() && cli.isImpostoFederalPisSupervisor() && cli.isImpostoFederalCofinsSupervisor() && cli.isImpostoFederalCsslSupervisor() && cli.isImpostoFederalIrSupervisor() && cli.isImpostoFederalInssSupervisor()){%>
            $("impostoFederaisSupervisor").checked = true;
        <%}%>
        <% if(cli.getClienteXcarac().size()>0){
         for (ClienteCamposPersonalizadosXCarac clienteXcarac : cli.getClienteXcarac()) {%>
             var xcarac = new CamposXcarac('<%=clienteXcarac.getId()%>', '<%=clienteXcarac.getTipoTag() %>', '<%=clienteXcarac.getValorTag()%>', '<%=clienteXcarac.getTipoConhecimento()%>', '<%=clienteXcarac.getTipoServico()%>', <%=clienteXcarac.getModal()%>);
             addXcarac(xcarac);
        <%}}%>
        <% if(cli.getOcorrenciasAuto().size()>0){
         for (ClienteOcorrenciaAutomatica ocorr : cli.getOcorrenciasAuto()) {%>
             var ocorrencia = new CamposOcorrAuto('<%=ocorr.getId()%>', '<%=ocorr.getOcorrencia().getId()%>', '<%=ocorr.getOcorrencia().getDescricao() %>', '<%=ocorr.getOcorrencia().getCodigo()%>', '<%=ocorr.getObservacaoOcorrencia()%>','<%= ocorr.getTipoInclusao() %>', '<%= ocorr.getTipoCte() %>');
             addOcorrenciaAutomatica(ocorrencia);
        <%}}%>
        var xmlAut;
        <%
        if(cli.getClienteCnpjCpfAutorizados().size() > 0){
            for (ClienteCnpjCpfAutorizados clienteCnpjs : cli.getClienteCnpjCpfAutorizados()) {%>
                 xmlAut = new XmlAutorizados(<%=clienteCnpjs.getId()%>,<%=clienteCnpjs.getCnpjcpf()%>, <%=clienteCnpjs.getTipo()%>);
                addXmlAutorizado(xmlAut);
        <%}}%>
    <%} else {%>
        $("chkSegunda").checked = true;$("chkTerca").checked = true;$("chkQuarta").checked = true;$("chkQuinta").checked = true;$("chkSexta").checked = true;$("chkSabado").checked = false;$("chkDomingo").checked = false;
        <% }%>
            //carregando a lista de tipo respseg
            <% for(int x = 0 ; x < ClienteRespsegEnum.values().length ; x++){ %>
                listaResponsavelSeguro[<%=x%>] = '<%= ClienteRespsegEnum.values()[x].getDescricao()%>';
            <%}%>
            //carregando a lista de tipo de cliente
            <% for(int x = 0 ; x < ClienteTipo.values().length ; x++){ %>
                listaTipoCliente[<%=x%>] = '<%= ClienteTipo.values()[x].getDescricao()%>';
            <%}%>
            <% for(ClienteRespseg cliente : cli.getClienteRespseg()){ %>
                addExcecaoCliente('<%= cliente.getTipoCliente().ordinal() %>','<%= cliente.getResponsavelSeguro().ordinal() %>','<%= cliente.getId() %>', '<%= cliente.getClienteExcecao().getIdcliente() %>', '<%= cliente.getClienteExcecao().getRazaosocial() %>');
            <%}%>
              <c:forEach var="negociacao" varStatus="status" items="${listaNegociacaoCliente}">
            listaNegociacoes[++countNegociacaos] = new Option('${negociacao.id}','${negociacao.descricao}');
            </c:forEach>
             <% for(ClienteNegociacaoAdiantamentoFrete negociacao : cli.getExecoesNegociacao()){ %>
                 var negociacaoCliente = new negociacaoAdiantamento('<%= negociacao.getMotorista().getIdmotorista() %>','<%= negociacao.getMotorista().getNome()%>','<%= negociacao.getNegociacao().getId() %>','<%= negociacao.getNegociacao().getDescricao()%>','<%= negociacao.getId()%>');
                 montarDomNegociacaoAdtMotorista(negociacaoCliente);<%}%>
                povoarSelect($("negociacaoAdiantamentoSlc"),listaNegociacoes);
                $("negociacaoAdiantamentoSlc").value ='<%= cli.getNegociacaoAdiantamento()%>';
            mostrarInfoRepresentante();
            $("msgCliCte").innerHTML = '<%= carregacli && cli.getMsgClienteCte() != null ? cli.getMsgClienteCte().trim().replaceAll("\r\n", " "): "" %>';
            $("msgCliColeta").innerHTML = '<%= carregacli && cli.getMsgClienteColeta() != null ? cli.getMsgClienteColeta().trim().replaceAll("\r\n", " "): "" %>';
            if ($("isEnviaFtp").checked) {
                $("enviaXmlFtp").show();
            }
            mostrarBloq();
            validarPermissaoUsuario('<%= nivelOperacional%>','operacional',true);
            isExibirSerieMinuta($("tipo-geracao-nfse-cidade-origem-destino-cte-lote"));
            let tbImportacaoLote = jQuery('#tbImportacaoLote');
            jQuery(tbImportacaoLote).on('click', '.btnAdicionarTags', (e) => aoClicarAdicionarTags(jQuery(e.target).attr('data-index'), jQuery(e.target).attr('data-classe'), undefined)).on('click', '.excluirTagAdicional', (e) => aoClicarExcluirTag(jQuery(e.target)));
            }

        function salva(){
            if ($('isGerarNfseCidadeOrigemDestinoCteLote').checked && $('tipo-geracao-nfse-cidade-origem-destino-cte-lote').value === '2' && $('serie-minuta').value.trim() === '') {
                return alert('Atenção: Ao marcar ao incluir conhecimentos em lote, gerar Minuta o campo Utilizar Série é obrigatório');
            }
            var maxLayEDI_n = $("maxLayEDI_n").value;
            for (var qtdLayout = 1; qtdLayout <= maxLayEDI_n; qtdLayout++) {
                if($("slcLayout_"+qtdLayout) != null){
                    if($("chkRedespacho_"+qtdLayout).checked && $("LocalizaIdRedespacho_"+qtdLayout).value == 0){
                        alert("Atenção: Ao marcar o redespacho, é obrigatório seleciona-lo!");
                        return false;
                    }
                    if($("chkDestinatario_"+qtdLayout).checked && $("LocalizaIdDestinatario_"+qtdLayout).value == 0){
                        alert("Atenção: Ao marcar o destinatário, é obrigatório seleciona-lo!");
                        return false;
                    }
                    if($("chkRemetente_"+qtdLayout).checked && $("LocalizaIdRemetente_"+qtdLayout).value == 0){
                        alert("Atenção: Ao marcar o remetente, é obrigatório seleciona-lo!");
                        return false;
                    }
                    if($("chkConsignatario_"+qtdLayout).checked && $("LocalizaIdConsignatario_"+qtdLayout).value == 0){
                        alert("Atenção: Ao marcar o consignatário, é obrigatório seleciona-lo!");
                        return false;
                    }
                    if($("chkRepresentante_"+qtdLayout).checked && $("LocalizaIdRepresentante_"+qtdLayout).value == 0){
                        alert("Atenção: Ao marcar o representante, é obrigatório seleciona-lo!");
                        return false;
                    }
                    if($("chkRecebedor_"+qtdLayout).checked && $("LocalizaIdRecebedor_"+qtdLayout).value == 0){
                        alert("Atenção: Ao marcar o recebedor, é obrigatório seleciona-lo!");
                        return false;
                    }
                    if($("chkExpedidor_"+qtdLayout).checked && $("LocalizaIdExpedidor_"+qtdLayout).value == 0){
                        alert("Atenção: Ao marcar o expedidor, é obrigatório seleciona-lo!");
                        return false;
                    }
                    if($("trImport_AgrupVeiculo_"+qtdLayout).style.display == "" && $("inpRadNotaFiscalSim_"+qtdLayout).checked && $("inpAgruparPorVeiculoSim_"+qtdLayout).checked){
                        alert("Atenção: Informe apenas uma forma de agrupamento (Remetente e Destinatário) ou (Veículo)!");
                        return false;
                    }
                }
            }
            if($("chkativo").checked == false && $("motivo").value == "" || $("motivo").value == "null"){
                alert("Informe o motivo do Cliente está desativado!");
                $("motivo").focus();
            }else{
                var cgc;
                //Validando campos em branco
                if($("chkativo").checked == true){
                    $("motivo").value = "";
                }
                if(getHoraValida()){
                    return false;
                }
                if(ckDataNull()==false){
                    return false;
                }
                if ($("rzs").value == null || $("rzs").value == "") {
                    alert ("Informe a razão social corretamente.");
                }
                else if (<%=cfg.isCliente_plano_de_contas()%> && $('tipoCliente').value == 'true' && ($('cod_conta').value == '' ) ){
                    alert ("Informe a conta contábil corretamente.");
                }
                else if (<%=cfg.isClienteValidaCnpj()%> && ! isCpf($("cnpj").value) && $("tipocgc").value == "F" && $("uf").value != "EX") {
                    alert ("CPF Inválido. Para consultar se o CPF está correto acesse http://www.sintegra.gov.br/");
                    $("cnpj").focus();
                }
                else if (<%=cfg.isClienteValidaCnpj()%> && ! isCnpj($("cnpj").value) && $("tipocgc").value == "J" && $("uf").value != "EX") {
                    alert ("CNPJ Inválido. Para consultar se o CNPJ está correto acesse http://www.sintegra.gov.br/");
                    $("cnpj").focus();
                }
                else if ( $("idcidade").value == "0" || $("idcidade").value == "") {
                    alert ("Informe a cidade corretamente.");
                }else if (<%=cfg.isClienteValidaIe()%> && !CheckIE($('IE').value , $('uf').value)) {
                    alert ("Inscrição Estadual inválida, caso o cliente nao tenha IE então digite a palavra ISENTO. Para consultar se a IE está correta acesse http://www.sintegra.gov.br/");
                }else if (<%=cfg.isClienteFantasiaObrigatorio()%> && $('nomefantasia').value == ''){
                    alert ("Informe o nome fantasia corretamente.");
                }else if (<%=cfg.isClienteCepObrigatorio()%> && $('cep').value == ''){
                    alert ("Informe o cep corretamente.");
                }else if (<%=cfg.isClienteEnderecoObrigatorio()%> && ($('endereco').value == '' || ($('bairro').value == '' && $("uf").value != "EX"))){
                    alert ("Informe o endereço completo corretamente.");
                }else if (<%=cfg.isClienteFoneObrigatorio()%> && $('fone').value == '' && $('fax').value == ''){
                    alert ("Informe o fone/fax corretamente.");
                }else if (<%=cfg.isClienteVendedorObrigatorio()%> && $('tipoCliente').value == 'true' && $('idven').value == '0'){
                    alert ("Informe o vendedor corretamente.");
                }else if (<%=cfg.isClienteVendedor2Obrigatorio()%> && $('tipoCliente').value == 'true' && $('idsupervisor').value == '0'){
                    alert ("Informe o supervisor de vendas corretamente.");
                }else if (<%=cfg.isClienteCepCobrancaObrigatorio()%> && $('tipoCliente').value == 'true' && $('cepCob').value == ''){
                    alert ("Informe o cep de cobrança corretamente.");
                }else if (<%=cfg.isClienteEnderecoCobrancaObrigatorio()%> && $('tipoCliente').value == 'true' && ($('enderecoCob').value == '' || $('bairroCob').value == '' || $('cidadeCobId').value == '0') ){
                    alert ("Informe o endereço de cobrança completo corretamente.");
                }else if (<%=cfg.isCliente_plano_de_contas()%> && $('tipoCliente').value == 'true' && ($('cod_conta').value == '' ) ){
                    alert ("Informe a conta contábil corretamente.");
                }else{
                    if ($("isEnviaFtp").checked) {
                        if ($("enviaXmlFtp").value == "") {
                            alert("Informe o FTP corretamente!");
                        }
                    }
                    var preenchido = false;
                    if($("tipoSeguroCarga").value=='c' && $("statusAverbacaoCte").value!='N'){
                        if($("seguradoraRodoviario").value!='0'){preenchido = true;}
                        if($("seguradoraAereo").value!='0'){preenchido = true;}
                        if($("seguradoraAquaviario").value!='0'){preenchido = true;}
                        if(!preenchido){
                            alert("Preencha ao menos uma Caixa Postal de Seguradora para CT-e!");
                            return false;
                        }
                    }
                    preenchido = false;
                    if($("tipoSeguroCarga").value=='c' && $("statusAverbacaoNfs").value!='N'){
                        if($("cxPostalNfs").value!='0'){preenchido = true;}
                         if(!preenchido){
                            alert("Preencha ao menos uma Caixa Postal de Seguradora para NFS-e!");
                            return false;
                        }
                    }
                    //verificando se é CPF ou CNPJ para formatar
                    if ($("tipocgc").value == "J"){
                        if ($("uf").value != "EX"){
                            $("cnpj").value = formatCpfCnpj($("cnpj").value,false,true);
                        }
                    }else{
                        $("cnpj").value = formatCpfCnpj($("cnpj").value,false,false);
                    }
                    // --- jonas
                  var maxContato = $("maxContato").value;
                  var existeContato = false;
                  var configEmail = <%=cfg.isEmailDeContato()%>;
                    if(configEmail == true && $("tipoCliente").value == "true"){
                        for(var qtdCont = 1; qtdCont <= maxContato; qtdCont++){
                            if($("emailCont_"+qtdCont) != null && $("emailCont_"+qtdCont).value.trim() != ""){
                                existeContato = true;
                                break;
                            }
                        }
                        if(!existeContato){
                            alert("Para clientes diretos é obrigatório ter ao menos um e-mail cadastrado!");
                            return false;
                        }
                    }
                    if($("chkEmailMDF").checked || $("chkEmailCtrc").checked || $("chkEmailManifesto").checked || $("chkEnviaEmailOcorrencia").checked || $("chkEnviaEmailChegada").checked || $("chkEmailBaixaCtrc").checked || $("chkEnviaEmailNfse").checked || $("chkEmailCancelarCTE").checked || $("chkEmailcartacorrCTE").checked){
                        for(var qtdCont = 1; qtdCont <= maxContato; qtdCont++){
                            if($("recebeEntrega_"+qtdCont).checked){
                                existeContato = true;
                                break;
                            }
                        }
                        if (!existeContato){
                            alert("Atenção: Ao marcar as infomações da entrega, é obrigatório cadastrar um e-mail de contato e marcar a opção de recebe e-mail de entrega!");
                            return false;
                        }
                    }
                        for(var qtdPrest = 1; qtdPrest <=  parseFloat($("maxTaxas").value);qtdPrest++){
                            if($("trCampoTaxas_"+qtdPrest) != null && $("descricaoTaxas_"+qtdPrest) != null && $("descricaoTaxas_"+qtdPrest).value == ''){
                                alert("Atenção: Ao adicionar campo personalizado para vPrest, é obrigatório informar o valor do campo!");
                                $("descricaoTaxas_"+qtdPrest).focus();
                                return false;
                            }}
                        for(var qtdXobs = 1; qtdXobs <=  parseFloat($("maxCampo").value);qtdXobs++){
                            if($("trCampo_"+qtdXobs) != null && $("descricaoTag_"+qtdXobs) != null && $("descricaoTag_"+qtdXobs).value == ''){
                                alert("Atenção: Ao adicionar campo personalizado para xOBS, é obrigatório informar o valor do campo!");
                                $("descricaoTag_"+qtdXobs).focus();
                                return false;
                            }}
                        for(var qtdXcarac = 1; qtdXcarac <=  parseFloat($("maxCampoXcarac").value);qtdXcarac++){
                            if($("trXcarac_"+qtdXcarac) != null && $("trXcarac_"+qtdXcarac).style.display == '' && $("valorXcaracTag_"+qtdPrest) != null && $("valorXcaracTag_"+qtdXcarac).value == ''){
                                alert("Atenção: Ao adicionar campo personalizado para xCaracAd ou xCaracSer, é obrigatório informar o valor do campo!");
                                $("valorXcaracTag_"+qtdXcarac).focus();
                                return false;
                            } }
                        for(var qtdInfq = 1; qtdInfq <=  parseFloat($("maxCampoInfQ").value); qtdInfq++){
                            if($("trCampoInfQ_"+qtdInfq) != null && $("descricaoTagInfQ_"+qtdInfq) != null && $("descricaoTagInfQ_"+qtdInfq).value == ''){
                                alert("Atenção: Ao adicionar campo personalizado para infQ, é obrigatório informar o valor do campo!");
                                $("descricaoTagInfQ_"+qtdInfq).focus();
                                return false;
                            }}
                        for(var i =1; i<=$("maxXmlAut").value; i++){
                            if (!isCpfCnpj(document.getElementById("xmlAut_"+i).value)){
                                alert ("CNPJ Autorizador de Impressão CT-e/NF-e" +document.getElementById("xmlAut_"+i).value+" Inválido.");
                                return false;
                            }}
                    $("gravar").value = "Enviando...";
                    $("acao").value = '<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>';
                    //Permissão Operacional
                    $('chkEmailMDF').disable = false;
                    $('tipotabela').disabled = false;$('tipoCliente').disabled = false;
                    $('pagtoFrete').disabled = false;$('tipoDiasVencimento').disabled = false;
                    $('chkEmailCtrc').disabled = false;$('chkEmailManifesto').disabled = false;
                    $('chkEmailBaixaCtrc').disabled = false;$('chkEnviaEmailNfse').disabled = false;
                    $('chkPautaFiscal').disabled = false;$('chkIncluiContainer').disabled = false;
                    $('tipoOrigemFrete').disabled = false;$('chkEmailCancelarCTE').disabled = false;
                    $('chkEmailcartacorrCTE').disabled = false;$('tipoTabelaRemetente').disabled = false;
                    $('chkPautaFiscal').disabled = false;$('chkSTMG').disabled = false;
                    $('tipoSeguroCarga').disabled = false;$('chkTipoProduto').disabled = false;
                    $('tipoCobranca').disabled = false;$('chkFaturarMinuta').disabled = false;
                    //permissão financeiro
                    $('condicaopgt').disabled = false;$('tipoComissao').disabled = false;
                    $('chkAnaliseCredito').disabled = false;$('isNuncaProtestar').disabled = false;
                    $('carregarRotasContratoCliente').disabled = false;$('isComprovanteEntrega').disable = false;
                    window.open('about:blank', 'pop', 'width=210, height=100');
                    validarPermissaoUsuario('<%= nivelOperacional%>','operacional',false);   
                    $("formulario").submit();
                    //submitPopupForm($("formulario"));
                }
            }
        }
        function excluircliente(){if (confirm("Deseja mesmo excluir este cliente?")){location.replace("./consultacliente?acao=excluir&id="+<%=request.getParameter("id")%>);}}
        function seAlterando(){
            //Botão excluir
<% //Apenas se tiver em modo de edição
    if (carregacli) {%>
            $("tipocgc").value = "<%=cli.getTipocgc()%>";
            $("tipotabela").value = "<%=cli.getTipo_tabela()%>";
            $("pagtoFrete").value = "<%=cli.getTipoPagtoFrete()%>";
            $("tipoDiasVencimento").value = "<%=cli.getTipoDiasVencimento()%>";
            $("tipoCliente").value = "<%=cli.isClienteDireto()%>";
            $("tipoCfop").value = "<%=cli.getTipoCfop()%>";
            $("tipoOrigemFrete").value = "<%=cli.getTipoOrigemFrete()%>";
            $("tipoComissao").value = "<%=cli.getTipoComissao()%>";
            $("tipoComissao2").value = "<%=cli.getTipoComissao2()%>";
            $("tipoTabelaRemetente").value = "<%=cli.getUtilizaTabelaRemetente()%>";
            $("tipoSeguroCarga").value = "<%=cli.getSeguroCarga()%>";
            $("tipoDocumentoPadrao").value = "<%= cli.getTipoDocumentoPadrao() %>";
            $("tipoPgtoContaCorrente").value = "<%=cli.getTipoPgtoContaCorrente()%>";
            $("chkClienteArmazenagem").value = "<%=cli.isIsClienteArmazenagem()%>";
            $("tipo-geracao-nfse-cidade-origem-destino-cte-lote").value = "<%=cli.getTipoGeracaoNfseCidadeOrigemDestinoCteLote()%>";
            $("serie-minuta").value = "<%=cli.getSerieMinuta()%>";
            alteraTabelaRemetente();
            tipoClienteA();
<%}%>
}
function aoClicarNoLocaliza(idjanela){
    //localizando cidade
    try {
        if(idjanela == "etiquetaLayoutImpressao"){
            $("telaEtiquetaLayoutImpressao").value = $("tela_etiqueta_layout_impressao").value;
        }else 
        
        if (idjanela=="Cidade"){
            $('idcidade').value = $('idcidadeorigem').value;
            $('cidade').value = $('cid_origem').value;
            $('uf').value = $('uf_origem').value;
        }else if(idjanela=="Cidade_Cobranca"){
            $('cidadeCobId').value = $('idcidadeorigem').value;
            $('cidadeCob').value = $('cid_origem').value;
            $('ufCob').value = $('uf_origem').value;
        }else if(idjanela=="Cidade_Entrega"){
            var index = $("indexAux").value;
            $('idCidadeEndEntrga_' + index).value = $('idcidadeorigem').value;
            $('cidadeEndEntrga_' + index).value = $('cid_origem').value;
            $('ufEndEntrga_' + index).value = $('uf_origem').value;
        }else if(idjanela=="Cidade_Coleta"){
            $('cidadeColId').value = $('idcidadeorigem').value;
            $('cidadeCol').value = $('cid_origem').value;
            $('ufCol').value = $('uf_origem').value;
        }else if (idjanela == "Tipo_de_produto"){
            addTipoProduto($("tipo_produto").value, $("tipo_produto_id").value);
        }else if (idjanela == "Tipo_Produto_Destinatario"){
            $("tipoProdutoDestinatarioId").value = $("tipo_produto_id").value;
            $("tipoProdutoDestinatario").value = $("tipo_produto").value;
        }else if (idjanela == "Vendedor"){
            $('idven').value = $('idvendedor').value;
            $('vendedor').value = $('ven_rzs').value;
        }else if (idjanela == "Supervisor"){
            $('idsupervisor').value = $('idvendedor').value;
            $('supervisor').value = $('ven_rzs').value;
        }else if (idjanela == "Remetente"){
            if (<%=(nivelOperacional < 2)%>){
                alert('Você não tem privilégios suficientes para executar essa ação!');
            }else{
                addRemetente($('idremetente').value, $('rem_rzs').value, $('rem_cnpj').value, $('rem_cidade').value, $('rem_uf').value);
            }
         }else if(idjanela == "Ocorrencia"){
            var index = $("indexAux").value;
            $('idOcorrencia_' + index).value = $('ocorrencia_id').value;
            $('descricaoOcorrencia_' + index).value = $('descricao_ocorrencia').value;
        }else if(idjanela == "Cidade_Diaria"){
            var index = $("indexAux").value;
            $('idCidadeDiaria_' + index).value = $('idcidadeorigem').value;
            $('cidadeDiaria_' + index).value = $('cid_origem').value;
            $('ufDiaria_' + index).value = $('uf_origem').value;
        }else if(idjanela == "ClienteExcecao"){
            var index = $("indexClienteExcecao").value;
            $("idClienteExcecao_"+index).value = $("idremetente").value;
            $("razaoClienteExcecao_"+index).value = $("rem_rzs").value;
        }else if(idjanela == "UnidadeCustoReceita"){
            $("siglaUnidadeCusto").value = $("sigla_und").value;
            $("unidadeId").value = $("id_und").value;
        }else if(idjanela == "UnidadeCustoFrete"){
            $("siglaUnidadeCustoFrete").value = $("sigla_und").value;
            $("unidadeFreteId").value = $("id_und").value;
        }else if(idjanela=="Bairro_Entrega"){
            var index = $("indexAux").value;
            $('idCidadeEndEntrga_' + index).value = $('idcidade').value;
            $('cidadeEndEntrga_' + index).value = $('cidade').value;
            $('ufEndEntrga_' + index).value = $('uf').value;
            $('bairroEndEntrga_' + index).value = $('descricao').value;
            $('idBairroEndEntrga_' + index).value = $('idbairro').value;
        }else if (idjanela == "Redespacho_Importacao") {
            var index = $("indexAux").value;
            $("LocalizaRedespacho_"+index).value = $("red_rzs").value;
            $("LocalizaIdRedespacho_"+index).value = $("idredespacho").value;
        }else if (idjanela == "Destinatario_Importacao") {
            var index = $("indexAux").value;
            $("LocalizaDestinatario_"+index).value = $("dest_rzs").value;
            $("LocalizaIdDestinatario_"+index).value = $("iddestinatario").value;
        }else if (idjanela == "Remetente_Importacao") {
            var index = $("indexAux").value;
            $("LocalizaRemetente_"+index).value = $("rem_rzs").value;
            $("LocalizaIdRemetente_"+index).value = $("idremetente").value;
        }else if (idjanela == "Consignatario_Importacao") {
            var index = $("indexAux").value;
            $("LocalizaConsignatario_"+index).value = $("con_rzs").value;
            $("LocalizaIdConsignatario_"+index).value = $("idconsignatario").value;
        }else if (idjanela == "Representante_Importacao") {
            var index = $("indexAux").value;
            $("LocalizaRepresentante_"+index).value = $("redspt_rzs").value;
            $("LocalizaIdRepresentante_"+index).value = $("idredespachante").value;
        }else if (idjanela == "Recebedor_Importacao") {
            var index = $("indexAux").value;
            $("LocalizaRecebedor_"+index).value = $("rec_rzs").value;
            $("LocalizaIdRecebedor_"+index).value = $("idrecebedor").value;
        }else if (idjanela == "Expedidor_Importacao") {
            var index = $("indexAux").value;
            $("LocalizaExpedidor_"+index).value = $("exp_rzs").value;
            $("LocalizaIdExpedidor_"+index).value = $("idexpedidor").value;
        }else if(idjanela == "Remetente_Layout"){
            var index = $("indexAux").value;
            $("layoutRemetente_"+index).value = $("rem_rzs").value;
            $("layoutIdRemetente_"+index).value = $("idremetente").value;
        }else if(idjanela == "Ocorrencia_Automatica"){
            var index = $("indexAux").value;
            var ocorrencia = new CamposOcorrAuto();
            ocorrencia.idOcorrencia = $('ocorrencia_id').value;
            ocorrencia.descOcorrencia = $('descricao_ocorrencia').value;
            ocorrencia.codigo = $('ocorrencia').value;
            addOcorrenciaAutomatica(ocorrencia);
        }else if(idjanela == "Motorista"){
            var apontador = $("apontadorMotor").value;$("idMotorista_"+apontador).value = $("idmotorista").value;$("nomeMotorista_"+apontador).value = $("motor_nome").value;
        } else if (idjanela == "Observacao") {//Se a tela de localizar chamada for de observação
            $("id").value = <%=(cli != null ? cli.getIdcliente() : 0)%>;
            var obs = $("obs_desc").value != undefined ? $("obs_desc").value : "";
            obs = replaceAll(obs, "<br>", "<BR>"); //Adcionando mais uma condição para quando o split("<BR>") vinher tanto em maiusculo quanto em minusculo ele poder tratar.
            $("obs_lin1").value = obs.split("<BR>")[0];
            $("obs_lin2").value = obs.split("<BR>")[1];
            $("obs_lin3").value = obs.split("<BR>")[2];
            $("obs_lin4").value = obs.split("<BR>")[3];
            $("obs_lin5").value = obs.split("<BR>")[4];
        } else if (idjanela == "Observacao_Fisco") {
            // Se a tela de localizar chamada for de observação de fisco
            $("id").value = <%=(cli != null ? cli.getIdcliente() : 0)%>;
            var obsFisco = $("obs_desc").value != undefined ? $("obs_desc").value : "";
            obsFisco = replaceAll(obsFisco, "<br>", "<BR>"); //Adcionando mais uma condição para quando o split("<BR>") vinher tanto em maiusculo quanto em minusculo ele poder tratar.
            $("obs_fisco_lin1").value = obsFisco.split("<BR>")[0];
            $("obs_fisco_lin2").value = obsFisco.split("<BR>")[1];
            $("obs_fisco_lin3").value = obsFisco.split("<BR>")[2];
            $("obs_fisco_lin4").value = obsFisco.split("<BR>")[3];
            $("obs_fisco_lin5").value = obsFisco.split("<BR>")[4];
        }
    } catch (e) {
        console.log(e);
    }
}
function repetirDadosPrincipais(){
    if (<%=nivelFinan == 4%>){$('enderecoCob').value = $('endereco').value + ($('numeroLogradouro').value == '' ? '' : ', ' + $('numeroLogradouro').value);$('complCob').value = $('compl').value;$('bairroCob').value = $('bairro').value;$('cepCob').value = $('cep').value;$('cidadeCobId').value = $('idcidade').value;$('cidadeCob').value = $('cidade').value;$('ufCob').value = $('uf').value;}else{alert('Você não tem privilégios suficientes para alterar o endereço de cobrança!');}}
        var countTipo = 0;
        var countEndereco = 0;
        var idxCont = 0;
        var countRemetente = 0;
        var callMascaraSoNumeros = "mascara(this,soNumeros);";
        //*************  ENDEREOS DE ENTREGA  *********************  INICIO
function validaEnderecoEntrega(index, idCidade){
    if(<%=nivelBairro == 4%> && idCidade != 0){
        $("bairroEndEntrga_"+index).readOnly = true;
    }else if(<%=nivelBairro == 4%> && idCidade == 0){
        $("bairroEndEntrga_"+index).readOnly = false;
    }else{
        $("bairroEndEntrga_"+index).readOnly = true;
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
    var rotina = "cliente";
    var dataDe = $("dataDeAuditoria").value;
    var dataAte = $("dataAteAuditoria").value;
    var id = "<%=(cli != null ? cli.getIdcliente(): 0)%>";
    consultarLog(rotina, id, dataDe, dataAte);
}

function addEndereco(endereco, table){
    var apelido = "EndEntrga";
    try {if (endereco == null || endereco == undefined) {endereco = new Endereco();}
        countEndereco++;
        var classe = "CelulaZebra2NoAlign";
        var callRemoverEndereco = "removerEndereco("+ countEndereco +");"
        var callLocCidade = "abrirLocalizarCidadeEntrega("+ countEndereco +");"
        var callLocBairroEntrega = "abrirLocalizarBairroEntrega("+ countEndereco + "," + endereco.cidadeId+ ");"
        var callLimparBairroEntrega = "limparBairroEntrega("+ countEndereco +");"
        var _tr = Builder.node("tr",{id:"trEndereco_"+ countEndereco, className:classe});
        var _tdRemove = Builder.node("td",{id:"tdRemove_"+ countEndereco, align: "center"});
        var _tdCep = Builder.node("td",{id:"tdCep_"+ countEndereco});
        var _tdEndereco = Builder.node("td",{id:"tdEndereco_"+ countEndereco});
        var _tdNumero = Builder.node("td",{id:"tdNumero_"+ countEndereco});
        var _tdComplemento = Builder.node("td",{id:"tdComplemento_"+ countEndereco});
        var _tdCidade = Builder.node("td",{id:"tdCidade_"+ countEndereco});
        var _tdBairro = Builder.node("td",{id:"tdBairro_"+ countEndereco});
        var _inpId = Builder.node("input", {id: "id"+apelido+"_"+ countEndereco,name: "id"+apelido+"_"+ countEndereco,type: "hidden",className: "inputTexto",value: endereco.id});
        var _inpCidadeId = Builder.node("input", {id: "idCidade"+apelido+"_"+ countEndereco, name: "idCidade"+apelido+"_"+ countEndereco ,type: "hidden",className: "inputTexto",value: endereco.cidadeId});
        var _inpBairroId = Builder.node("input", {id: "idBairro"+apelido+"_"+ countEndereco, name: "idBairro"+apelido+"_"+ countEndereco ,type: "hidden",value: endereco.idBairro});
        var _inpImg = Builder.node("img", {id: "imgRemove_"+ countEndereco, name: "imgRemove_"+ countEndereco ,src: "img/lixo.png",onclick: callRemoverEndereco});
        var _inpCep = Builder.node("input", {id: "cep"+apelido+"_"+ countEndereco, name: "cep"+apelido+"_"+ countEndereco ,type: "text",size: "10",maxLength: "10",className: "inputTexto",onblur:"getEnderecoByCepDom(this.value, false ," + countEndereco +")",onchange:"limparEnderecoEntrega("+countEndereco+");",value: endereco.cep});
        var _inpEndereco = Builder.node("input", {id: "logradouro"+apelido+"_"+ countEndereco, name: "logradouro"+apelido+"_"+ countEndereco ,type: "text",size: "30",maxLength: "60",className: "inputTexto",value: endereco.logradouro});
        var _inpComplemento = Builder.node("input", {id: "complemento"+apelido+"_"+ countEndereco, name: "complemento"+apelido+"_"+ countEndereco ,type: "text",size: "30",maxLength: "60",className: "inputTexto",value: endereco.complemento});
        var _inpBairro = Builder.node("input", {id: "bairro"+apelido+"_"+ countEndereco, name: "bairro"+apelido+"_"+ countEndereco ,type: "text",size: "15",maxLength: "60",className: (<%=nivelBairro == 4%> && endereco.cidadeId != 0 ? "inputReadOnly" : <%=nivelBairro == 4%> && endereco.cidadeId == 0 ? "inputtexto" : "inputReadOnly"),value: endereco.bairro});
        var _inpBotLocBairro = Builder.node("input", {id: "btBairro"+apelido+"_"+ countEndereco, type: "button",className: "botoes",onClick: callLocBairroEntrega,value: "..."});
        var _inpBotLimparBairro = Builder.node("IMG", {id: "btLimparBairro"+apelido+"_"+ countEndereco, onClick: callLimparBairroEntrega,className:"imagemLink",src:'img/borracha.gif'});
        var _inpCidade = Builder.node("input", {id: "cidade"+apelido+"_"+ countEndereco, name: "cidade_"+ countEndereco ,type: "text",size: "20",maxLength: "60",className: "inputTexto",value: endereco.cidadeDesc});
        var _inpUF = Builder.node("input", {id: "uf"+apelido+"_"+ countEndereco, name: "uf"+apelido+"_"+ countEndereco ,type: "text",size: "2",maxLength: "2",className: "inputTexto",value: endereco.uf});
        var _inpBotLocCli = Builder.node("input", {id: "bt"+apelido+"_"+ countEndereco, type: "button",className: "botoes",onClick: callLocCidade,value: "..."});
        readOnly(_inpUF, "inputReadOnly");
        readOnly(_inpCidade, "inputReadOnly");
        var _inpNumero = Builder.node("input", {id: "numero"+apelido+"_"+ countEndereco, name: "numero"+apelido+"_"+ countEndereco ,type: "text",size: "8",maxLength: "8",className: "inputTexto",onKeyPress: callMascaraSoNumeros,value: endereco.numeroLogradouro});
        _tdRemove.appendChild(_inpId);
        _tdRemove.appendChild(_inpImg);
        _tdCep.appendChild(_inpCep);
        _tdEndereco.appendChild(_inpEndereco);
        _tdEndereco.appendChild(_inpNumero);
        _tdComplemento.appendChild(_inpComplemento);
        _tdBairro.appendChild(_inpBairro);
        _tdBairro.appendChild(_inpBairroId);
        _tdBairro.appendChild(_inpBotLocBairro);
        if(<%=nivelBairro == 4%> ){
            _tdBairro.appendChild(_inpBotLimparBairro);
        }
        _tdCidade.appendChild(_inpCidadeId);
        _tdCidade.appendChild(_inpCidade);
        _tdCidade.appendChild(_inpUF);
        _tdCidade.appendChild(_inpBotLocCli);
        _tr.appendChild(_tdRemove);
        _tr.appendChild(_tdCep);
        _tr.appendChild(_tdEndereco);
        _tr.appendChild(_tdComplemento);
        _tr.appendChild(_tdBairro);
        _tr.appendChild(_tdCidade);
        table.appendChild(_tr);
        $("qtdEndEntrega").value = countEndereco;
        visivel(table);
        validaEnderecoEntrega(countEndereco, endereco.cidadeId);
    } catch (ex) {alert(ex);}}

        var countColAuto = 0;
        var listaColetasAutomaticas = new Array();
        var idCol=0;
        <%for (BeanFilial filial : filiais) { %>
            listaColetasAutomaticas[++idCol] = new Option("<%=filial.getIdfilial()%>", "<%=filial.getAbreviatura()%>");
        <% } %>
        function addRemetente(remetenteId, remetente, cnpjRemetente, cidadeRemetente, ufRemetente, tipoTabela){
            countRemetente++;
            var celulaZebra = ((countRemetente % 2) == 0 ? 'CelulaZebra2' : 'CelulaZebra1');
            var _trRem = Builder.node("tr",{name: "trRemetente_" + countRemetente, id: "trRemetente_" + countRemetente, className:celulaZebra});
            _trRem.appendChild(Builder.node("td", {name: "tdTitNome_" + countRemetente, id: "tdTitNome_" + countRemetente, width: '8%'}));
            _trRem.appendChild(Builder.node("td", {name: "tdNome_" + countRemetente, id: "tdNome_" + countRemetente, width: '28%'}));
            _trRem.appendChild(Builder.node("td", {name: "tdTitCnpj_" + countRemetente, id: "tdTitCnpj_" + countRemetente, width: '4%'}));
            _trRem.appendChild(Builder.node("td", {name: "tdCnpj_" + countRemetente, id: "tdCnpj_" + countRemetente, width: '17%'}));
            _trRem.appendChild(Builder.node("td", {name: "tdTitCidade_" + countRemetente, id: "tdTitCidade_" + countRemetente, width: '5%'}));
            _trRem.appendChild(Builder.node("td", {name: "tdCidade_" + countRemetente, id: "tdCidade_" + countRemetente, width: '19%'}));
            _trRem.appendChild(Builder.node("td", {name: "tdTipo_" + countRemetente, id: "tdTipo_" + countRemetente, width: '6%'}));
            _trRem.appendChild(Builder.node("td", {name: "tdTipoSlc_" + countRemetente, id: "tdTipoSlc_" + countRemetente, width: '11%'}));
            _trRem.appendChild(Builder.node("td", {name: "tdLixo_" + countRemetente, id: "tdLixo_" + countRemetente, width: '2%'}));
            $('tbTabelaRemetente').appendChild(_trRem);
            //id tabela
            var _lbTitNome = Builder.node("label", {},"Remetente:");
            $('tdTitNome_'+countRemetente).appendChild(_lbTitNome);
            var _lb1 = Builder.node("label", {
                name: "lbRemetente_" + countRemetente,
                id: "lbRemetente_" + countRemetente},remetente);
            var _ip1 = Builder.node("input", {
                name: "idRemetente_" + countRemetente,
                id: "idRemetente_" + countRemetente,
                type: "hidden",
                value: remetenteId});
            $('tdNome_'+countRemetente).appendChild(_lb1);
            $('tdNome_'+countRemetente).appendChild(_ip1);
            var _lbTitCnpj = Builder.node("label", {},"CNPJ:");
            $('tdTitCnpj_'+countRemetente).appendChild(_lbTitCnpj);
            var _lb2 = Builder.node("label", {
                name: "lbCnpjRem_" + countRemetente,
                id: "lbCnpjRem_" + countRemetente},cnpjRemetente);
            $('tdCnpj_'+countRemetente).appendChild(_lb2);
            var _lbTitCidade = Builder.node("label", {},"Cidade:");
            $('tdTitCidade_'+countRemetente).appendChild(_lbTitCidade);
            var _lb3 = Builder.node("label", {
                name: "lbCidadeRem_" + countRemetente,
                id: "lbCidadeRem_" + countRemetente},cidadeRemetente + '-' + ufRemetente);
            $('tdCidade_'+countRemetente).appendChild(_lb3);
            var _lb4 = Builder.node("label", {
                name: "lbTipoTab_" + countRemetente,
                id: "lbTipoTab_" + countRemetente},"Tabela:");
            $('tdTipo_'+countRemetente).appendChild(_lb4);
            var _slc = Builder.node("select", {style:"width:100px",
                name: "tipoTabela_" + countRemetente,id: "tipoTabela_" + countRemetente, className:"fieldMin"},
            [Builder.node("OPTION",{value:"-1"},"--Selecione--"),
                Builder.node("OPTION",{value:"0"},"Peso/Kg"),
                Builder.node("OPTION",{value:"1"},"Peso/Cubagem"),
                Builder.node("OPTION",{value:"2"},"% Nota Fiscal"),
                Builder.node("OPTION",{value:"3"},"Combinado"),
                Builder.node("OPTION",{value:"4"},"Por Volume"),
                Builder.node("OPTION",{value:"5"},"Por Km"),
                Builder.node("OPTION",{value:"6"},"Por Pallet")
            ]);
            _slc.value = tipoTabela;
            var _lb5 = Builder.node("label", {
                name: "lbTipoTabela_" + countRemetente,
                id: "lbTipoTabela_" + countRemetente},"");
            $('tdTipoSlc_'+countRemetente).appendChild(_slc);
            $('tdTipoSlc_'+countRemetente).appendChild(_lb5);
            if (<%=(nivelOperacional >= 2)%>){
                $('tipoTabela_' + countRemetente).style.display = '';
                $('lbTipoTabela_' + countRemetente).style.display = 'none';
            }else{
                $('tipoTabela_' + countRemetente).style.display = 'none';
                $('lbTipoTabela_' + countRemetente).style.display = '';
                if (tipoTabela == "-1"){
                    $('lbTipoTabela_' + countRemetente).innerHTML = '--Selecione--';
                }else if (tipoTabela == "0"){
                    $('lbTipoTabela_' + countRemetente).innerHTML = 'Peso/Kg';
                }else if (tipoTabela == "1"){
                    $('lbTipoTabela_' + countRemetente).innerHTML = 'Peso/Cubagem';
                }else if (tipoTabela == "2"){
                    $('lbTipoTabela_' + countRemetente).innerHTML = '% Nota Fiscal';
                }else if (tipoTabela == "3"){
                    $('lbTipoTabela_' + countRemetente).innerHTML = 'Combinado';
                }else if (tipoTabela == "4"){
                    $('lbTipoTabela_' + countRemetente).innerHTML = 'Por Volume';
                }else if (tipoTabela == "5"){
                    $('lbTipoTabela_' + countRemetente).innerHTML = 'Por Km';
                }else if (tipoTabela == "6"){
                    $('lbTipoTabela_' + countRemetente).innerHTML = 'Por Pallet';
                }
            }
            var _ipLixo = Builder.node("img", {
                src: "img/lixo.png" ,
                onclick:"mensagemExcluir('trRemetente_" + countRemetente + "','Realmente deseja excluir o remetente da lista de tabela de preço?');"});
            $('tdLixo_'+countRemetente).appendChild(_ipLixo);
            document.getElementById("maxTabelaRemetente").value = countRemetente;
        }
        function mensagemExcluir(campoExcluir, mensagem){
            var test = new Array();
            var tipoExclu = campoExcluir.split("_")[0];
            if (tipoExclu == 'tdTipo' || tipoExclu == 'trRemetente'){
                if (<%=(nivelOperacional < 2)%>){
                    alert('Você não tem privilégios suficientes para executar essa ação!');
                    return false;}}
            if(!confirm(mensagem)){
                return false;
            }else{Element.remove(campoExcluir);return true;}
        }
        //*************************  EDI ************************** INICIO        
        
    <%for (LayoutEDI layout : listaLayoutCONEMB) {%>
        listLayoutEDI_c[++idxC] = new Option("<%=layout.getId()%>", "<%=layout.getDescricao()%>");
    <%}%>
        
    <%for (LayoutEDI layout : listaLayoutDOCCOB) {%>
        listLayoutEDI_f[++idxF] = new Option("<%=layout.getId()%>", "<%=layout.getDescricao()%>");
    <%}%>
    <%for (LayoutExcel layoutExcel : layoutsDocCobExcel) {%>
        listLayoutEDI_f[++idxF] = new Option("<%=layoutExcel.getView()%>", "<%=layoutExcel.getDescricao()%>");
    <%}%>
        
   <%for (LayoutEDI layout : listaLayoutOCOREN) {%>
        listLayoutEDI_o[++idxO] = new Option("<%=layout.getId()%>", "<%=layout.getDescricao()%>");
        listLayoutEDI_obj[++idxObj] = new LayoutEdi(<%=layout.getId()%>, <%=layout.getCodigoLayout()%>, "<%=layout.getDescricao()%>", "<%=layout.getExtencaoArquivo()%>");
    <%}%>

        //*************************  EDI ************************** FIM
        var idCC = 0;
        var listaCampoXml = new Array();
        <%for (Coluna col : colunas) {%>
           listaCampoXml[++idCC] = new Option("<%=col.getNome()%>", "<%=col.getNomeFormatado()%>");
        <% } %>

        var idCampoTaxas = 0;
        var listaCampoTaxas = new Array();
        <%for (ClienteTaxas cliTaxas : clienteTaxas) {%>
           listaCampoTaxas[++idCampoTaxas] = new Option("<%=cliTaxas.getId()%>", "<%=cliTaxas.getNomeTaxa()%>");
        <% } %>
        
        var listaCampoVeiculo = new Array();
        var idCampoVeiculo = 0;
        var listaCampoTipoProduto = new Array();
        var idCampoListaProduto = 0;
        <%while(rsTipoVeiculo.next()){%>
           listaCampoVeiculo[++idCampoVeiculo] = new Option("<%=rsTipoVeiculo.getInt("id")%>", "<%=rsTipoVeiculo.getString("descricao")%>");
        <% } %>
          listaCampoTipoProduto[idCampoListaProduto] = new Option("", "----SELECIONE----");
         <%for(TipoProduto tipoProd : listaProduto){%>
             listaCampoTipoProduto[++idCampoListaProduto] = new Option("<%=tipoProd.getId()%>", "<%=tipoProd.getDescricao()%>");
         <%}%>
        
        var idClientesStICMS = 0;
        var listaStICMS = new Array();
        <%for (SituacaoTributavel situacaoTributavel : listaStIcms) {%>
           listaStICMS[++idClientesStICMS] = new Option("<%=situacaoTributavel.getId()%>", "<%=situacaoTributavel.getCodigo()%>-<%=situacaoTributavel.getDescricao()%>");
        <% } %>
        var listaFiliais = new Array();
        var idfiliais=0;
      //  listaFiliais[idfiliais] = new Option("", "TODAS");
         listaFiliais[idfiliais] = new Option("", "----TODAS----");
        <%for (BeanFilial filial : filiais) { %>
            listaFiliais[++idfiliais] = new Option("<%=filial.getIdfilial()%>", "<%=filial.getAbreviatura()%>");
        <% } %>
            
            var clienteAuditoriaId = "<%=(cli != null ? cli.getIdcliente(): 0)%>";

</script>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />
        <title>WebTrans - Cadastro de Clientes</title>
        <link href="estilo.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
        <link rel="stylesheet" href="stylesheets/tabs.css" type="text/css" media="all">

        <c:set var="config" value="<%=cfg%>"/>
    </head>
    <body onLoad="javascript:seAlterando();aoCarregar();label();AlternarAbasGenerico('tdContatos','tab1');alterarTipoComissaoVendedor();alterarTipoComissaoSupervisor();alterarTipoPgtoContaCorrente();alterarFaixaVencimento();mostrarCamposEmbarcador(null);alterarAverbacao(null);alterarAverbacaoNfs(null);mostrarDOMNegociacao();carregarIMG()">
        <div align="center">
            <form method="post" action="./cadcliente" id="formulario" target="pop">
                <img src="img/banner.gif" ><br>
                <input type="hidden" name="acao" id="acao" value="<%=acao%>">
                <input type="hidden" name="id" id="id" value="<%=(cli != null ? cli.getIdcliente() : 0)%>">
                <input type="hidden" id="indexAux" value="0">
                <input type="hidden" name="idcidadeorigem" id="idcidadeorigem" value="0">
                <input type="hidden" name="cid_origem" id="cid_origem" value="">
                <input type="hidden" name="uf_origem" id="uf_origem" value="">
                <input type="hidden" name="descricao" id="descricao" value="">
                <input type="hidden" name="idbairro" id="idbairro" value="0">
                <%-- Referente ao Vendedor --%>
                <input type="hidden" id="idven" name="idven" value="<%=cli != null ? cli.getVendedor().getIdfornecedor() : 0%>">
                <input type="hidden" id="idsupervisor" name="idsupervisor" value="<%=cli != null ? cli.getVendedor2().getIdfornecedor() : 0%>">
                <input type="hidden" id="idvendedor" name="idvendedor" value="0">
                <input type="hidden" id="cnae_id" name="cnae_id" value="<%=cli != null ? cli.getCnae().getId() : 0%>">
                <input type="hidden" id="grupo_id" name="grupo_id" value="<%=cli != null ? cli.getGcf().getId() : 0%>">
                <input type="hidden" id="plano_contas_id" name="plano_contas_id" value="<%=cli != null ? cli.getPlanoConta().getId() : 0%>">
                <input type="hidden" name="idcidade" id="idcidade" value="<%=(cli != null ? cli.getCidade().getIdcidade() : 0)%>">
                <input type="hidden" name="cidadeCobId" id="cidadeCobId" value="<%=(cli != null ? cli.getCidadeCob().getIdcidade() : 0)%>">
                <input type="hidden" name="cidadeColId" id="cidadeColId" value="<%=(cli != null ? cli.getCidadeCol().getIdcidade() : 0)%>">
                <input type="hidden" name="maxCampo" id="maxCampo" value="0">
                <input type="hidden" name="maxOcorrencia" id="maxOcorrencia" value="0">
                <input type="hidden" name="ocorrencia_id" id="ocorrencia_id" value="0">
                <input type="hidden" name="ocorrencia" id="ocorrencia" value="0">
                <input type="hidden" name="descricao_ocorrencia" id="descricao_ocorrencia" value="">
                <input type="hidden"  name="cliente_ocorrencia_id" id="cliente_ocorrencia_id" value="0">
                <%-- hidden para pegar a contagem máxima do DOM de campo diaria --%>
                <input type="hidden" name="maxCampoDiaria" id="maxCampoDiaria" value="0">
                <input type="hidden" name="indexClienteExcecao" id="indexClienteExcecao" value="0">
                <input type="hidden" name="maxClienteICMS" id="maxClienteICMS" value="0">
                <%--unidade de custo/22/06/2015--%>
                <input type="hidden" name="sigla_und" id="sigla_und" value="">
                <input type="hidden"  name="id_und" id="id_und" value="0">
                <%-- importação em lote --%>
                <input type="hidden" id="red_rzs" name="red_rzs" value=""/>
                <input type="hidden" id="idredespacho" name="idredespacho" value="0">
                <input type="hidden" id="dest_rzs" name="dest_rzs" value=""/>
                <input type="hidden" id="iddestinatario" name="iddestinatario" value="0">
                <input type="hidden" id="con_rzs" name="con_rzs" value=""/>
                <input type="hidden" id="idconsignatario" name="idconsignatario" value="0">
                <input type="hidden" id="redspt_rzs" name="redspt_rzs" value=""/>
                <input type="hidden" id="idredespachante" name="idredespachante" value="0">
                <input type="hidden" id="rec_rzs" name="rec_rzs" value=""/>
                <input type="hidden" id="idrecebedor" name="idrecebedor" value="0">
                <input type="hidden" id="exp_rzs" name="exp_rzs" value=""/>
                <input type="hidden" id="idexpedidor" name="idexpedidor" value="0">
                <input type="hidden" name="maxTaxas" id="maxTaxas" value="0">
                <input type="hidden" name="logomarcaCliente" id="logomarcaCliente" value="<%= (cli != null && cli.getLogomarcaCliente()!=null ? cli.getLogomarcaCliente() : "") %>">
                <input type="hidden" name="idLogomarcaCliente" id="idLogomarcaCliente" value="<%= cli != null && cli.getImagemLogomarca()!= null? cli.getImagemLogomarca().getId() : "0" %>">
                <input type="hidden" name="extensaoLogomarcaCliente" id="extensaoLogomarcaCliente" value="<%= cli != null && cli.getImagemLogomarca() != null? cli.getImagemLogomarca().getExtensao(): "" %>">
                <input type="hidden" name="descricaoLogomarcaCliente" id="descricaoLogomarcaCliente" value="<%= cli != null && cli.getImagemLogomarca() != null? cli.getImagemLogomarca().getDescricao(): "" %>">
                <input type="hidden" id="idmotorista" name="idmotorista" value="0"><input type="hidden" id="motor_nome" name="motor_nome" value="0"><input type="hidden" id="apontadorMotor" name="apontadorMotor" value="0">
                <input type="hidden" id="obs_desc" name="obs_desc" value="0">
                <input type="hidden" name="maxXmlAut" id="maxXmlAut" value="0">
                <table width="90%" align="center" class="bordaFina" >
                    <tr><td width="532" height="22"><div align="left"><b>Cadastro de Cliente</b></div></td>
                        <td width="81">
                            <% if ((acao.equals("editar")) && (nivelUser == 4) && (Boolean.parseBoolean(request.getParameter("ex")))) //se o paramentro vier com valor diferente de nulo ai pode excluir
                                {%>
                            <input  name="excluir" type="button" class="inputbotao" value="Excluir" alt="Exclui o cliente atual" onClick="javascript:excluircliente();"></td>
                            <%}%>
                        <td width="8">&nbsp;</td>
                        <td width="59"><input  name="Button" type="button" class="inputbotao" value=" Voltar para Consulta " alt="Volta para consulta" onClick="javascript:tryRequestToServer(function(){voltar()});"></td>
                    </tr>
                </table><br>
                <table width="90%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                    <tr class="tabela"><td align="center" colspan="8">Dados principais</td></tr>
                    <tr><td width="15%" class="TextoCampos">C&oacute;digo:</td>
                        <td width="25%" class="CelulaZebra2" colspan="">
                            <b><%=(cli != null ? cli.getIdcliente() : 0)%>
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                <input name="chkativo" type="checkbox" id="chkativo" value="checkbox" onclick="javascript:mostraObservacao();" <%=(cli != null ? (cli.getAtivo() ? "checked" : "") : "checked")%>>
                                Cliente Ativo</b></td>
                        <td class="CelulaZebra2" width="15%" colspan="2"></td>
                        <td width="10%" class="TextoCampos">*<select name="tipocgc" id="tipocgc" class="inputtexto" onchange="validarConsumidorFinal();">
                                <option value="F">CPF</option><option value="J" selected>CNPJ</option></select>:</td>
                        <td width="20%" class="CelulaZebra2" colspan="2">
                            <input name="cnpj" type="text" id="cnpj" value="<%=(cli != null ? cli.getCnpj() : "")%>" size="18" maxlength="18" onKeyPress="mascara(this, soNumeros);" class="inputtexto">
                            <%if (acao.equals("iniciar")) {%>
                            <img height="25" src="img/receita.png" border="0" title="Clique aqui para consultar o CNPJ na Receita Federal." align="absbottom" class="imagemLink" onClick="javascript:verificaCGC();">
                            <span class="linkEditar" onClick="verificaCGC();">Consultar Receita</span>
                            <%}%>
                        </td>
                        <td rowspan="5" class="CelulaZebra2" width="15%">
                            <label><b>Selecione uma logomarca:</b></label>
                            <div style="width: 100%">
                                <div style="width: 50%">
                                    <input type="file" onchange="carregarImagemCliente()" class="inputTexto" id="carregarImg" name="carregarImg" width="50">
                                </div>
                                <img id="borrachaLogomarca" class="imagemLink" alt="" src="img/borracha.gif" onclick="tryRequestToServer(function(){limparLogomarca();})">
                            </div>
                            <img id="LOGO_IMG" width="81px" height="50px" style="display: none;max-height: 50px;max-width: 81px;" name="LOGO_IMG" />
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">*Raz&atilde;o Social:</td>
                        <td class="CelulaZebra2"><input name="rzs" type="text" id="rzs" value="<%=(cli != null ? cli.getRazaosocial() : "")%>" size="40" maxlength="50" class="inputtexto"></td>
                        <td class="TextoCampos">Cód. Loja:</td>
                        <td class="CelulaZebra2"><input name="codLoja" type="text" id="codLoja" value="<%=(cli != null && cli.getCodLoja() != null ? cli.getCodLoja() : "")%>" size="7" class="inputtexto"></td>
                        <td class="TextoCampos"><%=cfg.isClienteFantasiaObrigatorio() ? "*" : ""%>N. Fantasia:</td>
                        <td class="CelulaZebra2" colspan="2"><input name="nomefantasia" type="text" id="nomefantasia" value="<%=(cli != null && cli.getNomefantasia() != null ? cli.getNomefantasia() : "")%>" size="40" maxlength="50" class="inputtexto"></td>
                    </tr>
                    <tr>
                        <td class="TextoCampos" ><%=cfg.isClienteCepObrigatorio() ? "*" : ""%>CEP:</td>
                        <td class="CelulaZebra2" colspan="6">
                            <input name="cep" type="text" id="cep" value="<%=(cli != null ? cli.getCep() : "")%>" size="8" maxlength="9" onchange="limparEndereco();" onBlur="getEnderecoByCep(this.value, false, 'enderecoPrincipal')" class="inputtexto">
                            <label><font color="red">Digite o CEP e tecle TAB que o sistema preencher&aacute; o endereço automaticamente.</font></label>
                        </td></tr>
                    <tr>
                        <td class="TextoCampos"><%=cfg.isClienteEnderecoObrigatorio() ? "*" : ""%>Endere&ccedil;o:</td>
                        <td class="CelulaZebra2">
                            <input name="endereco" type="text" id="endereco" value="<%=(cli != null ? cli.getEndereco() : "")%>" size="33" maxlength="50" class="inputtexto">
                            <input name="numeroLogradouro" type="text" id="numeroLogradouro" value="<%=(cli != null ? cli.getNumeroLogradouro() : "")%>" size="3" maxlength="10" class="inputtexto">
                        </td>
                        <td class="TextoCampos" colspan="3">Complemento:</td>
                        <td class="CelulaZebra2" colspan="2"><input name="compl" type="text" id="compl" value="<%=(cli != null ? cli.getComplemento() : "")%>" size="40" maxlength="40" class="inputtexto"></td>
                    </tr>
                    <tr>
                        <td class="TextoCampos"><%=cfg.isClienteEnderecoObrigatorio() ? "*" : ""%>Bairro:</td>
                        <td class="CelulaZebra2">
                            <c:if test="<%=nivelBairro != 4 %>">
                                <input name="bairro" id="bairro" maxlength="25" type="text" class="inputReadOnly"  size="16" readonly="" value="<%=(cli != null ? cli.getBairro() : "")%>">
                                <input id="localizaBairro" type="button" class="inputbotao" onclick="tryRequestToServer(function(){abrirLocalizaBairro();})"  value="..." name="localizaBairro"/>
                                <input id="idLocalizaBairro" type="hidden" name="idLocalizaBairro" value="<%=(cli != null ? cli.getBairroBean().getIdBairro() : "")%>"/>
                            </c:if>
                            <c:if test="<%=nivelBairro  == 4 && cli.getBairroBean().getIdBairro() != 0 %>">
                                <input name="bairro" id="bairro" maxlength="25" type="text" class="inputReadOnly"  size="16" readonly="" value="<%=(cli != null ? cli.getBairro() : "")%>"/>
                                <input id="localizaBairro" type="button" class="inputbotao" onclick="tryRequestToServer(function(){abrirLocalizaBairro();})"  value="..." name="localizaBairro"/>
                                <input id="idLocalizaBairro" type="hidden" name="idLocalizaBairro" value="<%=(cli != null ? cli.getBairroBean().getIdBairro() : "")%>"/>
                                <img id="borrachaBairro" class="imagemLink" onclick="limparBorrachaBairro()" src="img/borracha.gif" alt="">
                            </c:if>
                            <c:if test="<%=nivelBairro  == 4 && cli.getBairroBean().getIdBairro() == 0 %>">
                                <input name="bairro" id="bairro" maxlength="25" type="text" class="inputtexto"  size="16" value="<%=(cli != null ? cli.getBairro() : "")%>"/>
                                <input id="localizaBairro" type="button" class="inputbotao" onclick="tryRequestToServer(function(){abrirLocalizaBairro();})"  value="..." name="localizaBairro"/>
                                <input id="idLocalizaBairro" type="hidden" name="idLocalizaBairro" value="<%=(cli != null ? cli.getBairroBean().getIdBairro() : "")%>"/>
                                <img id="borrachaBairro" class="imagemLink" onclick="tryRequestToServer(function(){limparBorrachaBairro();})" src="img/borracha.gif" alt="">
                            </c:if>
                        </td>
                        <td class="TextoCampos" colspan="3">*Cidade/UF:</td>
                        <td class="CelulaZebra2" colspan="2">
                            <input name="cidade" type="text" id="cidade" value="<%=(cli != null ? cli.getCidade().getDescricaoCidade() : "")%>" size="30" maxlength="25" readonly="true" class="inputReadOnly8pt">
                            <input name="uf" type="text" id="uf" value="<%=(cli != null ? cli.getCidade().getUf() : "")%>" size="2" maxlength="25" readonly="true" class="inputReadOnly8pt">
                            <input name="localiza_cidade" type="button" class="inputbotao" id="localiza_cidade" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=11','Cidade','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos"><%=cfg.isClienteFoneObrigatorio() ? "*" : ""%>Fone / Fax:</td>
                        <td class="CelulaZebra2">
                            <input name="fone" type="text" id="fone" value="<%=(cli != null ? cli.getFone() : "")%>" size="15" maxlength="13" class="inputtexto">/
                            <input name="fax" type="text" id="fax" value="<%=(cli != null ? cli.getFax() : "")%>" size="15" maxlength="13" class="inputtexto">
                        </td>
                        <td class="TextoCampos" colspan="3"><%=cfg.isClienteValidaIe() ? "*" : ""%>Insc. Est.:</td>
                        <td class="CelulaZebra2">
                            <input name="IE" type="text" id="IE" onchange="validarConsumidorFinal();" value="<%=(cli != null ? cli.getInscest() : "")%>" size="20" maxlength="20" class="inputtexto">
                        </td>
                        <td class="TextoCampos" colspan="2">
                            <div align="center">
                                <label>
                                    <input name="consumidorFinal" type="checkbox" id="consumidorFinal" <%=(carregacli && cli.isConsumidorFinal() ? "checked" : "")%>>
                                    Consumidor final
                                </label>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">Insc. Municipal:</td>
                        <td class="CelulaZebra2" colspan="7">
                            <input name="inscMunicipal" type="text" id="inscMunicipal" value="<%=(cli != null ? cli.getInscMunicipal() : "")%>" size="20" maxlength="20" class="inputtexto">
                        </td></tr>
                    <tr>
                        <td colspan="8">
                            <table width="100%" border="0" align="center" cellpadding="2" cellspacing="1">
                                <tr>
                                    <td width="10%" class="TextoCampos">Tipo Cliente:</td>
                                    <td width="10%" class="CelulaZebra2">
                                        <select name="tipoCliente" id="tipoCliente" class="inputtexto" onChange="javascript:tipoClienteA();" <%=nivelClienteDireto != 0 ? "" : "disabled"%>>
                                            <option value="true">Cliente Direto</option>
                                            <option value="false" selected>Cliente Indireto</option>
                                        </select></td>
                                    <td width="5%" class="TextoCampos">Tipo CFOP:</td>
                                    <td width="8%" class="CelulaZebra2">
                                        <select name="tipoCfop" id="tipoCfop" class="inputtexto">
                                            <option value="c">Com&eacute;rcio</option>
                                            <option value="i">Ind&uacute;stria</option>
                                            <option value="t">Transportador</option>
                                            <option value="p">Prestador de serviço</option>
                                            <option value="r">Produtor Rural</option>
                                        </select></td>
                                        <td width="20%" class="CelulaZebra2">
                                            <div align="center"><input name="chkClienteArmazenagem" type="checkbox" id="chkClienteArmazenagem" value="false" <%=(carregacli && cli.isIsClienteArmazenagem() ? "checked" : "")%>>
                                                Cliente de armazenagem (gwLogis)
                                           </div></td>
                                    </tr>
                                    <tr>
                                        <td width="20%" class="TextoCampos" colspan="2">
                                            Ao utilizar esse cliente como destinatário:
                                        </td>
                                        <td width="20%" class="CelulaZebra2">
                                            <div align="center">
                                                <input name="chkCobrarTde" type="checkbox" id="chkCobrarTde" onclick="mostrarInfoRepresentante(this.value)" value="checkbox" <%=(carregacli && cli.isCobrarTde() ? "checked" : "")%>>
                                                Dificuldade de entrega, cobrar TDE ao Consignatário.
                                            </div>
                                        </td>
                                        <td width="20%" class="textoCampos">
                                                Utilizar o Tipo de Produto/Operação:
                                        </td>
                                        <td width="20%" class="CelulaZebra2">
                                            <input name="tipoProdutoDestinatario" id="tipoProdutoDestinatario" type="text" class="inputReadOnly"  size="16" readonly="" value="<%=(cli != null ? cli.getTipoProdutoDestinatario().getDescricao() : "")%>">
                                            <input type="button" class="inputbotao" onclick="tryRequestToServer(function(){abrirLocalizaTipoProduto();})"  value="..."/>
                                            <input id="tipoProdutoDestinatarioId" type="hidden" name="tipoProdutoDestinatarioId" value="<%=(cli != null ? cli.getTipoProdutoDestinatario().getId() : "")%>"/>
                                            <img class="imagemLink" onclick="limparLocalizaTipoProduto()" src="img/borracha.gif" alt="">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="5%" class="TextoCampos" colspan="2">Grupo de Clientes:</td>
                                    <td width="22%" class="CelulaZebra2">
                                        <input name="grupo" type="text" id="grupo" size="25" readonly class="inputReadOnly" value="<%=(cli != null && cli.getGcf().getDescricao() != null ? cli.getGcf().getDescricao() : "")%>">
                                        <input name="localiza_grupo" type="button" class="inputbotao" id="localiza_grupo" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.GRUPO_CLI_FOR%>', 'Grupo')">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('grupo').value='';getObj('grupo_id').value=0;">
                                    </td>
                                    <td class="CelulaZebra2" colspan="3">
                                    </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr name="trAltera" id="trAltera" style="display:none">
                            <td colspan="8" width="100%">
                                <table width="100%" border="0"  cellpadding="2" cellspacing="1">
                                <td class="TextoCampos" width="20%">Motivo TDE:
                                </td>
                                <td class="CelulaZebra2" width="80%">
                                    <textarea name="motivoTDE" cols="60" id="motivoTDE"><%=(cli.getMotivoTDE() == null ? "" : cli.getMotivoTDE())%></textarea>
                                </td></table></td></tr></tr>
                    <tr name="inativo" id="inativo" style="display:none;">
                        <td colspan="7" width="100%">
                            <table border="0" width="100%" >
                                <tr>
                                    <td width="20%" class="textoCampos">Motivo Desativa&ccedil;&atilde;o cliente:</td>
                                    <td width="80%" class="CelulaZebra2">
                                        <textarea name="motivo" cols="60" id="motivo"><%=(cli.getMotivoInativacao() == null ? "" : cli.getMotivoInativacao())%></textarea>
                                    </td></tr></table></td></tr></table><br><table align="center"  width="90%">
                                        <tr>
                        <td>
                            <table width="80%">
                                <tr>
                                    <td id="tdContatos" class="menu-sel" onclick="AlternarAbasGenerico('tdContatos','tab1')"> Contatos/Fichário </td>
                                    <td id="tdInfoFinan" class="menu" onclick="AlternarAbasGenerico('tdInfoFinan','tab2')"> Inf. Financeiras</td>
                                    <td id="tdInfoCom" class="menu" onclick="AlternarAbasGenerico('tdInfoCom','tab4')"> Inf. Comerciais</td>
                                    <td id="tdEndColEnt" class="menu" onclick="AlternarAbasGenerico('tdEndColEnt','tab3')"> Endere&ccedil;o de Coleta/Entrega</td>
                                    <td id="tdInfoOpe" class="menu" onclick="AlternarAbasGenerico('tdInfoOpe','tab5')"> Inf. Operacionais</td>
                                    <td id="tdAbaEdi" class="menu" onclick="AlternarAbasGenerico('tdAbaEdi','tab8')"> EDI</td>
                                    <td id="tdRastrCarga" class="menu" onclick="AlternarAbasGenerico('tdRastrCarga','tab9');"> Rastreamento da Carga</td>
                                    <%if(Apoio.getUsuario(request).getAcesso("cadtabelacliente")  >= NivelAcessoUsuario.LER.getNivel()){%>
                                    <td id="tdTabPreco" class="menu" onclick="AlternarAbasGenerico('tdTabPreco','tab7')"> Tabela de Preço</td>
                                    <%}%>
                                    <td id="tdInfoCont" class="menu" onclick="AlternarAbasGenerico('tdInfoCont','tab6')"> Integra&ccedil;&atilde;o cont&aacute;bil/Fiscal</td>
                                    <td style='display: <%= carregacli && nivelUser == 4 ? "" : "none" %>' id="tdAbaAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>
                                </tr></table></td></tr></table>
                <div id="container" style="width: 90%" align="left">
                    <div  id="tab1">
                        <fieldset>
                        <table width="100%" border="0">
                                <tr width="100%">
                                        <td class="TextoCampos">Fich&aacute;rio:</td>
                                        <td class="CelulaZebra2" colspan="4">
                                            <textarea name="fichario" class="inputtexto" style="width: 650px" cols="200" maxlength="400" rows="5" id="fichario"><%=(cli != null && cli.getFichario() != null ? cli.getFichario() : "")%></textarea>
                                        </td>
                                </tr>
                            </table>
                            <table width="100%" border="0" class="bordaFina">
                                <tbody id="TbContato" name="TbContato">
                                    
                                    <tr class="celula" >
                                        <td width="2%">
                                            <!--<img src="img/add.gif" border="0" title="Adicionar contato" class="imagemLink" style="vertical-align:middle;" onClick="javascript:addContato('0','','','','','','','false','false');">-->
                                            <a href="javascript: tryRequestToServer(function(){var contato = new Contato();contato.isUsuario = 'true';addContato(contato);})">
                                                <img src="img/add.gif" alt="contato" class="imagemLink" title="Novo contato"/>
                                            </a>
                                        </td>
                                        <td width="2%"></td>
                                        <td width="10%">Contato</td>
                                        <td width="10%">Setor</td>
                                        <td width="8%">Fone</td>
                                        <td width="5%">Ramal</td>
                                        <td width="10%">Celular</td>
                                        <td width="20%">E-mail</td>
                                        <td width="12%">Recebe E-mail de Entrega</td>
                                        <td width="12%">Recebe E-mail de Cobran&ccedil;a</td>
                                        <td width="12%">Recebe E-mail de EDI</td>
                                    </tr></tbody></table>
                        </fieldset>
                    </div>
                    <div id="tab2">
                        <fieldset id="tbCobranca">
                            <table width="100%" border="0" class="bordaFina">
                                <tr class="tabela"><td align="center" colspan="5"><div align="center">Endere&ccedil;o de Cobran&ccedil;a</div></td></tr>
                                <tr>
                                    <td colspan="5" class="TextoCampos">
                                        <div align="center">
                                            <input  name="Button" type="button" class="inputbotao" value="Repetir endereço principal" alt="Repetir dados do endereço principal" onClick="javascript:repetirDadosPrincipais();">
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos"><%=cfg.isClienteCepCobrancaObrigatorio() ? "*" : ""%>CEP:</td>
                                    <td class="CelulaZebra2">
                                        <input name="cepCob" type="text" id="cepCob" value="<%=(cli != null ? cli.getCepCob() : "")%>" onchange="limparEnderecoCob();" onblur="getEnderecoByCep(this.value, false, 'enderecoCobranca')" size="8" maxlength="9" class="<%=(nivelFinan == 4 ? "inputtexto" : "inputReadOnly")%>" <%=(nivelFinan == 4 ? "" : "readonly")%>>
                                    </td>
                                    <td class="TextoCampos"></td>
                                    <td class="CelulaZebra2"></td>
                                </tr>
                                <tr>
                                    <td width="15%" class="TextoCampos"><%=cfg.isClienteEnderecoCobrancaObrigatorio() ? "*" : ""%>Endere&ccedil;o:</td>
                                    <td width="35%" class="CelulaZebra2">
                                        <input name="enderecoCob" type="text" id="enderecoCob" value="<%=(cli != null ? cli.getEnderecoCob() : "")%>" size="40" maxlength="50" class="<%=(nivelFinan == 4 ? "inputtexto" : "inputReadOnly")%>" <%=(nivelFinan == 4 ? "" : "readonly")%>>
                                    </td>
                                    <td width="15%" class="TextoCampos">Complemento:</td>
                                    <td width="35%" class="CelulaZebra2" colspan="2">
                                        <input name="complCob" type="text" id="complCob" value="<%=(cli != null ? cli.getComplementoCob() : "")%>" size="40" maxlength="40" class="<%=(nivelFinan == 4 ? "inputtexto" : "inputReadOnly")%>" <%=(nivelFinan == 4 ? "" : "readonly")%>>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos"><%=cfg.isClienteEnderecoCobrancaObrigatorio() ? "*" : ""%>Bairro:</td>
                                    <td class="CelulaZebra2">
                                    <c:if test="<%=nivelBairro != 4 && nivelFinan != 4%>">
                                        <input name="bairroCob" id="bairroCob" maxlength="25" type="text" class="inputReadOnly" readonly=""  size="16" readonly="" value="<%=(cli != null ? cli.getBairroCob() : "")%>">
                                        <input id="localizaBairroCob" type="button" class="inputbotao" onclick="tryRequestToServer(function(){abrirLocalizaBairroCobranca();})"  value="..." name="localizaBairroCob"/>
                                        <input id="idBairroCob" type="hidden" name="idBairroCob" value="<%=(cli != null ? cli.getBairroBeanCob().getIdBairro() : "")%>"/>
                                    </c:if>
                                    <c:if test="<%=nivelBairro != 4 && nivelFinan == 4%>">
                                        <input name="bairroCob" id="bairroCob" maxlength="25" type="text" class="inputReadOnly" readonly=""  size="16" readonly="" value="<%=(cli != null ? cli.getBairroCob() : "")%>">
                                        <input id="localizaBairroCob" type="button" class="inputbotao" onclick="tryRequestToServer(function(){abrirLocalizaBairroCobranca();})"  value="..." name="localizaBairroCob"/>
                                        <input id="idBairroCob" type="hidden" name="idBairroCob" value="<%=(cli != null ? cli.getBairroBeanCob().getIdBairro() : "")%>"/>
                                    </c:if>
                                    <c:if test="<%=nivelBairro  == 4 && cli.getCidadeCob().getIdcidade() != 0 %>">
                                        <input name="bairroCob" id="bairroCob" maxlength="25" type="text" class="inputReadOnly" size="16" readonly="" value="<%=(cli != null ? cli.getBairroCob() : "")%>"/>
                                        <input id="localizaBairroCob" type="button" class="inputbotao" onclick="tryRequestToServer(function(){abrirLocalizaBairroCobranca();})"  value="..." name="localizaBairroCob"/>
                                        <input id="idBairroCob" type="hidden" name="idBairroCob" value="<%=(cli != null ? cli.getBairroBeanCob().getIdBairro() : "")%>"/>
                                        <img id="borrachaBairro" class="imagemLink" onclick="limparBorrachaBairroCob()" src="img/borracha.gif" alt="">
                                    </c:if>
                                    <c:if test="<%=nivelBairro  == 4 && cli.getCidadeCob().getIdcidade() == 0  %>">
                                        <input name="bairroCob" id="bairroCob" maxlength="25" type="text" class="inputtexto" size="16" value="<%=(cli != null ? cli.getBairroCob() : "")%>"/>
                                        <input id="localizaBairroCob" type="button" class="inputbotao" onclick="tryRequestToServer(function(){abrirLocalizaBairroCobranca();})"  value="..." name="localizaBairroCob"/>
                                        <input id="idBairroCob" type="hidden" name="idBairroCob" value="<%=(cli != null ? cli.getBairroBeanCob().getIdBairro() : "")%>"/>
                                        <img id="borrachaBairro" class="imagemLink" onclick="tryRequestToServer(function(){limparBorrachaBairroCob();})" src="img/borracha.gif" alt="">
                                    </c:if>
                                    </td>
                                    <td class="TextoCampos"><%=cfg.isClienteEnderecoCobrancaObrigatorio() ? "*" : ""%>Cidade/UF:</td>
                                    <td class="CelulaZebra2" colspan="2">
                                        <input name="cidadeCob" type="text" id="cidadeCob" value="<%=(cli != null ? cli.getCidadeCob().getDescricaoCidade() : "")%>" size="30" maxlength="25" readonly="true" class="inputReadOnly">
                                        <input name="ufCob" type="text" id="ufCob" value="<%=(cli != null ? cli.getCidadeCob().getUf() : "")%>" class="inputReadOnly" size="2" maxlength="25" readonly="true">
                                        <input name="localiza_cidade" type="button" class="inputbotao" id="localiza_cidade" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=11','Cidade_Cobranca','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');" <%=(nivelFinan == 4 ? "" : "disabled")%>>
                                    </td>
                                </tr>
                                <tr class="tabela"><td align="center" colspan="5"><div align="center">Informa&ccedil;&otilde;es financeiras</div></td></tr>
                                <tr>
                                    <td class="TextoCampos">Condi&ccedil;&atilde;o:</td>
                                    <td class="CelulaZebra2" colspan="1">
                                        <select name="pagtoFrete" id="pagtoFrete" style="font-size:8pt;" class="inputtexto" onChange="javascript:$('condicaopgt').value = (this.value == 'v'?'0':'30'); alterarTipoPgtoContaCorrente()" <%=(nivelFinan == 4 ? "" : "disabled")%>>
                                            <option value="v">&Agrave; vista</option>
                                            <option value="p">&Agrave; prazo</option>
                                            <option value="c">Conta Corrente</option>
                                        </select>
                                        <select name="tipoPgtoContaCorrente" id="tipoPgtoContaCorrente" style="display: none;font-size:8pt;width: 80px;" class="inputtexto" onChange="javascript:alterarFaixaVencimento()">
                                            <option value="q">Qtd Dias</option>
                                            <option value="v">Por Faixa de Dias</option>
                                        </select>
                                        <label id="lbCom" style="display: ">
                                        Com
                                        </label>
                                        <input name="condicaopgt" type="text" id="condicaopgt" size="2" maxlength="9" value="<%=(cli != null ? cli.getCondicaoPgt() : "0")%>" <%=(nivelFinan == 4 ? "" : "disabled")%> class="inputtexto">
                                        <select name="tipoDiasVencimento" id="tipoDiasVencimento" style="font-size:8pt;width: 220px;" class="inputtexto" <%=(nivelFinan == 4 ? "" : "disabled")%> >
                                            <option value="c">dias após a emissão do CT-e/NFS-e</option>
                                            <option value="f" selected>dias após a emissão da Fatura</option>
                                        </select>
                                    </td>
                                    <td  class="CelulaZebra2" colspan="2">
                                        <span id="tdDiasSemana">
                                            Dias permitidos para vencimento da fatura:
                                            <label><input name="chkSegunda" type="checkbox" id="chkSegunda" value="checkbox" <%=(carregacli && cli.isSegunda() ? "checked" : "")%> >SEG</label>
                                            <label><input name="chkTerca" type="checkbox" id="chkTerca" value="checkbox" <%=(carregacli && cli.isTerca() ? "checked" : "")%> >TER</label>
                                            <label><input name="chkQuarta" type="checkbox" id="chkQuarta" value="checkbox" <%=(carregacli && cli.isQuarta() ? "checked" : "")%> >QUA</label>
                                            <label><input name="chkQuinta" type="checkbox" id="chkQuinta" value="checkbox" <%=(carregacli && cli.isQuinta() ? "checked" : "")%> >QUI</label>
                                            <label><input name="chkSexta" type="checkbox" id="chkSexta" value="checkbox" <%=(carregacli && cli.isSexta() ? "checked" : "")%> >SEX</label>
                                            <label><input name="chkSabado" type="checkbox" id="chkSabado" value="checkbox" <%=(carregacli && cli.isSabado() ? "checked" : "")%> >SAB</label>
                                            <label><input name="chkDomingo" type="checkbox" id="chkDomingo" value="checkbox" <%=(carregacli && cli.isDomingo() ? "checked" : "")%> >DOM</label>
                                        </span>
                                    </td>
                                </tr>
                                <tr id="FaixaVencimento" style="display: none">
                                    <td align="center" colspan="2" width="100%">
                                        <table class="bordaFina" width="100%">
                                            <tr class="CelulaZebra1NoAlign">
                                                <td align="center" width="1%">
                                                    <img src="img/add.gif" class="imagemLink" onclick="addFaixaVencimento(null, $('tbodyFaixaVencimento'))" alt="add.gif">
                                                    <input type="hidden" name="qtdFaixas" id="qtdFaixas" value="0" />
                                                </td>
                                                <td width="10%" align="center">Dia Inicial - Emissão da Fatura</td>
                                                <td width="5%" align="center">Dia Final</td>
                                                <td width="5%" align="center">Dia Vencimento</td>
                                                <td width="5%" align="center" >Mês</td>
                                            </tr>
                                            <tbody style="display: none" id="tbodyFaixaVencimento"></tbody>
                                        </table>
                                    </td>
                                    <td align="center" colspan="2"  class="CelulaZebra2">
                                    </td>
                                </tr>
                                <tr id="tipoCobrancaTemp" >
                                    <td class="TextoCampos">Tipo Cobrança:</td>
                                    <td class="CelulaZebra2">
                                        <select name="tipoCobranca" id="tipoCobranca" style="font-size:8pt;" class="inputtexto" <%=(nivelFinan == 4 ? "" : "disabled")%>>
                                            <option value="c">Carteira (Depósito Bancário)</option>
                                            <option value="b">Banco (Boleto Bancário)</option>
                                        </select>
                                    </td>                                    
                                    <td class="TextoCampos">Periodicidade do Faturamento</td>
                                    <td class="CelulaZebra2">
                                        <select id="periodicidade" name="periodicidade" class="inputtexto">
                                            <option value="">N&atilde;o Informado</option>
                                            <option value="d">Di&aacute;rio</option>
                                            <option value="s">Semanal</option>
                                            <option value="c">Dic&ecirc;ndio</option>
                                            <option value="q">Quizenal</option>
                                            <option value="m">Mensal</option>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos" colspan="2" id="divAnalise">
                                        <div align="center">
                                            <input name="chkAnaliseCredito" type="checkbox" id="chkAnaliseCredito" onclick="mostrarBloq();" value="checkbox" <%=(carregacli && cli.isAnaliseCredito() ? "checked " : "")%> <%=(nivelFinan == 4 && nivelAnaliseCredito == 4? "" : " disabled")%>>
                                            Ativar an&aacute;lise de cr&eacute;dito.
                                        </div>
                                    </td>
                                    <td class="TextoCampos" id="permitirBloqNotas" style="display:none">
                                        <div align="center"  >
                                            <input name="chkPermitirCredBloqNotas" type="checkbox" id="chkPermitirCredBloqNotas" value="checkbox" <%=(carregacli && cli.isPermitirCreditoBloqNotas() ? " checked " : "")%>  <%=(nivelFinan == 4 && nivelAnaliseCredito == 4? "" : " disabled")%> >
                                            Permitir o lançamento de Notas/Coletas mesmo com o crédito bloqueado
                                        </div>
                                    </td>
                                    <td class="TextoCampos" colspan="3">
                                        <div align="center">
                                            <input type="checkbox" name="isNuncaProtestar" id="isNuncaProtestar" <%=(carregacli && cli.isNuncaProtestar() ? "checked" : "")%> <%=(nivelFinan == 4 ? "" : "disabled")%>>
                                            N&atilde;o protestar t&iacute;tulos/boletos desse cliente
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">Limite Cr&eacute;dito:</td>
                                    <td class="CelulaZebra2" colspan="2">
                                        <input name="limiteCredito" type="text" id="limiteCredito" class="<%=(nivelFinan == 4 && nivelAnaliseCredito == 4 ? "inputtexto" : "inputReadOnly")%>" value="<%=(cli != null ? Apoio.to_curr(cli.getLimiteCredito()) : "")%>" size="8" maxlength="9" onChange="seNaoFloatReset(this, '0.00')" <%=(nivelFinan == 4 ? "" : "readonly")%>>
                                        Bloquear cr&eacute;dito caso haja parcelas com
                                        <input name="diasAtraso" type="text" id="diasAtraso" class="<%=(nivelFinan == 4 && nivelAnaliseCredito == 4 ? "inputtexto" : "inputReadOnly")%>" value="<%=(cli != null ? cli.getDiasAtraso() : "")%>" size="4" maxlength="3" onChange="seNaoIntReset(this, '0')" <%=(nivelFinan == 4 ? "" : "readonly")%>>
                                        dias de atraso

                                    </td>
                                    <td class="CelulaZebra2">
                                        <input type="checkbox" style="display: <%=(Apoio.getUsuario(request).getAcesso("altclifinan") > NivelAcessoUsuario.LER_ALTERAR_INCLUIR.getNivel()) ? "" : "none"%>" name="isComprovanteEntrega" id="isComprovanteEntrega" value="checkbox" <%=(carregacli && cli.isIsAnexarComprovanteEntregaBoleto()? "checked" : "")%>>
                                        Ao enviar e-mail do boleto, anexar o comprovante de entrega.
                                    </td>
                                </tr>
                                <tr>
                                    <td class="CelulaZebra2" colspan="2"/>
                                    <td class="CelulaZebra2" colspan="2" style="text-align: center">
                                        <input type="checkbox" name="isDesconsiderarMinuta" id="isDesconsiderarMinuta" <%=(carregacli && cli.isDesconsiderarMinuta() ? "checked" : "")%> /> Ao incluir faturas/boletos para esse cliente, desconsiderar minutas
                                    <td>
                                </tr>
                                
                                <tr class="tabela"><td align="center" colspan="5"><div align="center">Boletos/Faturas</div></td></tr>
                                <tr>
                                    <td class="TextoCamposNoAlign" align="center" colspan="2">
                                        <input type="checkbox" id="chkComprimirDacteFatura" name="chkComprimirDacteFatura" <%=(carregacli && cli.isComprimirDacteFatura() ? "checked" : "")%> />
                                        Compactar XML(s) / DACTE(s) ao enviar por e-mail na Fatura
                                    </td>
                                    <td class="TextoCamposNoAlign" align="center" colspan="3">
                                        <input type="checkbox" style="display: <%=(Apoio.getUsuario(request).getAcesso("altclifinan") > NivelAcessoUsuario.LER_ALTERAR_INCLUIR.getNivel()) ? "" : "none"%>" name="isComprovanteEntrega" id="isComprovanteEntrega" value="checkbox" <%=(carregacli && cli.isIsAnexarComprovanteEntregaBoleto()? "checked" : "")%>>
                                        Ao enviar e-mail do boleto, anexar o comprovante de entrega.
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCamposNoAlign" align="center" colspan="2">
                                        <div align="center">
                                            <label>
                                                <input type="checkbox" name="isImprimirLogomarcaBoleto" id="isImprimirLogomarcaBoleto" <%=(carregacli && cli.isIsImprimirLogomarcaBoleto() ? "checked" : "")%>>
                                                Imprimir a logomarca no boleto
                                            </label>
                                        </div>
                                    </td>
                                    <td class="CelulaZebra2" colspan="3">
                                        <input type="checkbox" id="chkEnviarEmailLembreteVencimentoBoleto"
                                               name="chkEnviarEmailLembreteVencimentoBoleto"
                                               ${param.acao eq "iniciar" ? (config.enviarEmailLembreteVencimentoFatura ? "checked" : "") : cli.enviarEmailLembreteVencimentoFatura ? "checked" : ""}>
                                        <label for="chkEnviarEmailLembreteVencimentoBoleto">
                                            Enviar e-mail de lembrete de vencimento da fatura/boleto com
                                        </label>
                                        <input type="text" class="inputtexto" size="4" maxlength="3"
                                               id="inpDiasEnviarEmailLembreteVencimentoBoleto"
                                               name="inpDiasEnviarEmailLembreteVencimentoBoleto"
                                               onblur="seNaoIntReset(this, 3)"
                                               value="${param.acao eq "iniciar" ? config.qtdDiasVencimentoLembreteFatura : cli.diasVencimento}">
                                        <label for="inpDiasEnviarEmailLembreteVencimentoBoleto">
                                            dias antes do vencimento
                                        </label>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos" width="15%">
                                        Ao enviar e-mail do boleto:
                                    </td>
                                    <td class="TextoCamposNoAlign" colspan="4">
                                        <label>
                                            <input type="radio" name="tipoEnvioBoleto" value="a" <%=(carregacli && cli.getTipoEnvioBoleto() != null ? (cli.getTipoEnvioBoleto().equals("a") ? "checked" : "") : "checked")%>/>
                                            Anexar o boleto
                                        </label>
                                        <label>
                                            <input type="radio" name="tipoEnvioBoleto" value="l" <%=(carregacli && cli.getTipoEnvioBoleto() != null ? (cli.getTipoEnvioBoleto().equals("l") ? "checked" : "") : "")%>/>
                                            Enviar o link do boleto ( Apenas essa opção tem o rastreamento do e-mail ) 
                                        </label>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </div>
                    <div id="tab3">
                        <fieldset>
                            <table width="100%" border="0" class="bordaFina">
                                <tr class="tabela"><td align="center" colspan="4"><div align="center">Endere&ccedil;o Principal para Coleta</div></td></tr>
                                <tr>
                                    <td colspan="4" class="TextoCampos">
                                        <div align="center">
                                            <input  name="Button" type="button" class="inputbotao" value="Repetir dados principais" alt="Repetir endereço principal" onClick="javascript:repetirDadosPrincipaisCol();">
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">CEP:</td>
                                    <td class="CelulaZebra2">
                                        <input name="cepCol" type="text" id="cepCol" onchange="limparEnderecoCol();" onBlur="getEnderecoByCep(this.value, false, 'enderecoColeta')" value="<%=(cli != null ? cli.getCepCol() : "")%>" size="8" maxlength="9" class="inputtexto">
                                    </td>
                                    <td class="TextoCampos"></td>
                                    <td class="CelulaZebra2"></td>
                                </tr>
                                <tr>
                                    <td width="15%" class="TextoCampos">Endere&ccedil;o:</td>
                                    <td width="35%" class="CelulaZebra2">
                                        <input name="enderecoCol" type="text" id="enderecoCol" value="<%=(cli != null ? cli.getEnderecoCol() : "")%>" size="40" maxlength="50" class="inputtexto">
                                    </td>
                                    <td width="15%" class="TextoCampos">Complemento:</td>
                                    <td width="35%" class="CelulaZebra2">
                                        <input name="complCol" type="text" id="complCol" value="<%=(cli != null ? cli.getComplementoCol() : "")%>" size="40" maxlength="40" class="inputtexto">
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">Bairro:</td>
                                    <td class="CelulaZebra2">
                                        <c:if test="<%=nivelBairro != 4 && nivelFinan != 4%>">
                                            <input name="bairroCol" id="bairroCol" maxlength="25" type="text" class="inputReadOnly" readonly=""  size="16" readonly="" value="<%=(cli != null ? cli.getBairroCol() : "")%>">
                                            <input id="localizaBairroCol" type="button" class="inputbotao" onclick="tryRequestToServer(function(){abrirLocalizaBairroColeta();})"  value="..." name="localizaBairroCol"/>
                                            <input id="idBairroCol" type="hidden" name="idBairroCol" value="<%=(cli != null ? cli.getBairroBeanCol().getIdBairro() : "")%>"/>
                                        </c:if>
                                        <c:if test="<%=nivelBairro != 4 && nivelFinan == 4%>">
                                            <input name="bairroCol" id="bairroCol" maxlength="25" type="text" class="inputReadOnly" readonly=""  size="16" readonly="" value="<%=(cli != null ? cli.getBairroCol() : "")%>">
                                            <input id="localizaBairroCol" type="button" class="inputbotao" onclick="tryRequestToServer(function(){abrirLocalizaBairroColeta();})"  value="..." name="localizaBairroCol"/>
                                            <input id="idBairroCol" type="hidden" name="idBairroCol" value="<%=(cli != null ? cli.getBairroBeanCol().getIdBairro() : "")%>"/>
                                        </c:if>
                                        <c:if test="<%=nivelBairro  == 4 && cli.getCidadeCol().getIdcidade() != 0 %>">
                                            <input name="bairroCol" id="bairroCol" maxlength="25" type="text" class="inputReadOnly"  readonly="" size="16" value="<%=(cli != null ? cli.getBairroCol() : "")%>"/>
                                            <input id="localizaBairroCol" type="button" class="inputbotao" onclick="tryRequestToServer(function(){abrirLocalizaBairroColeta();})"  value="..." name="localizaBairroCol"/>
                                            <input id="idBairroCol" type="hidden" name="idBairroCol" value="<%=(cli != null ? cli.getBairroBeanCol().getIdBairro() : "")%>"/>
                                            <img id="borrachaBairroCol" class="imagemLink" onclick="limparBorrachaBairroCol()" src="img/borracha.gif" alt="">
                                        </c:if>
                                        <c:if test="<%=nivelBairro  == 4 && cli.getCidadeCol().getIdcidade() == 0 %>">
                                            <input name="bairroCol" id="bairroCol" maxlength="25" type="text" class="inputtexto" size="16" value="<%=(cli != null ? cli.getBairroCol() : "")%>"/>
                                            <input id="localizaBairroCol" type="button" class="inputbotao" onclick="tryRequestToServer(function(){abrirLocalizaBairroColeta();})"  value="..." name="localizaBairroCol"/>
                                            <input id="idBairroCol" type="hidden" name="idBairroCol" value="<%=(cli != null ? cli.getBairroBeanCol().getIdBairro() : "")%>"/>
                                            <img id="borrachaBairroCol" class="imagemLink" onclick="tryRequestToServer(function(){limparBorrachaBairroCol();})" src="img/borracha.gif" alt="">
                                        </c:if>
                                    </td>
                                    <td class="TextoCampos">Cidade/UF:</td>
                                    <td class="CelulaZebra2">
                                        <input name="cidadeCol" type="text" id="cidadeCol" value="<%=(cli != null ? cli.getCidadeCol().getDescricaoCidade() : "")%>" size="30" maxlength="25" readonly="true" class="inputReadOnly">
                                        <input name="ufCol" type="text" id="ufCol" value="<%=(cli != null ? cli.getCidadeCol().getUf() : "")%>" class="inputReadOnly" size="2" maxlength="25" readonly="true">
                                        <strong>
                                            <input name="localiza_cidade" type="button" class="inputbotao" id="localiza_cidade" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=11','Cidade_Coleta','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                        </strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">Hor&aacute;rio Coleta:</td>
                                    <td class="CelulaZebra2">
                                        <input name="horarioColeta" type="text" id="horarioColeta" value="<%=(cli != null ? cli.getHorarioColeta() : "")%>" size="40" maxlength="75" class="inputtexto">
                                    </td>
                                    <td class="TextoCampos">Refer&ecirc;ncia:</td>
                                    <td class="CelulaZebra2">
                                        <input name="referenciaCol" type="text" id="referenciaCol" value="<%=(cli != null ? cli.getReferenciaCol() : "")%>" size="40" maxlength="50" class="inputtexto">
                                    </td>
                                </tr>
                                <tr class="tabela"><td align="center" colspan="4"><div align="center">Outros Endere&ccedil;o(s) para Coleta e/ou Entrega</div></td></tr>
                                <tr>
                                    <td align="center" colspan="4" width="100%">
                                        <table class="bordaFina" width="100%">
                                            <tr class="CelulaZebra1NoAlign">
                                                <td align="center" >
                                                    <img src="img/add.gif" onclick="addEndereco(null, $('tbodyEnderecosEntrega'))" alt="add.gif">
                                                    <input type="hidden" name="qtdEndEntrega" id="qtdEndEntrega" value="0" />
                                                </td>
                                                <td width="10%" >CEP</td>
                                                <td width="32%" >Logradouro</td>
                                                <td width="20%" >Complemento</td>
                                                <td width="15%" >Bairro</td>
                                                <td width="20%" >Cidade</td>
                                            </tr>
                                            <tbody style="display: none" id="tbodyEnderecosEntrega"></tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr class="tabela"><td align="center" colspan="4"><div align="center">Parametrização para integração com GPS/Roteirizador</div></td></tr>
                                <tr>
                                    <td class="TextoCampos">Latitude do End. Principal:</td>
                                    <td class="CelulaZebra2">
                                        <input name="latitude" type="text" id="latitude" value="<%=(cli != null ? cli.getLatitude() : 0.00)%>" size="30" maxlength="31" class="inputtexto" onchange="javascript:seNaoFloatReset(this,'0.00');">
                                    </td>
                                    <td class="TextoCampos">Longitude do End. Principal:</td>
                                    <td class="CelulaZebra2">
                                        <input name="longitude" type="text" id="longitude" value="<%=(cli != null ? cli.getLongitude() : 0.00)%>" size="30" maxlength="31" class="inputtexto" onchange="javascript:seNaoFloatReset(this,'0.00');">
                                    </td>
                                </tr>
                                <tr class="tabela"><td align="center" colspan="4"><div align="center">Parametrização para coletas automáticas</div></td></tr>
                                <tr>
                                    <td align="center" colspan="4" width="100%">
                                        <table class="bordaFina" width="100%">
                                            <tr class="CelulaZebra1NoAlign">
                                                <td align="center" colspan="1" width="2%">
                                                    <img src="img/add.gif" onclick="addColetasAutomaticas(null, $('tbodyColetasAutomaticas'))" alt="add.gif">
                                                    <input type="hidden" name="qtdColetasAutomaticas" id="qtdColetasAutomaticas" value="0" />
                                                </td>
                                                <td width="15%" colspan="2" >Filial Responsável</td>
                                                <td width="15%" colspan="1" >Dia Semana</td>
                                                <td width="15%" >Horário Coleta</td>
                                                <td width="15%" ></td>
                                                <td width="15%" ></td>
                                            </tr>
                                            <tbody style="display: none" id="tbodyColetasAutomaticas"></tbody>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </div>
                    <div id="tab4">
                        <fieldset id="tbComercial">
                            <table width="100%" border="0" class="bordaFina">
                                <tr>
                                    <td width="5%" class="TextoCampos">Origem:</td>
                                    <td width="22%" class="CelulaZebra2">
                                        <input name="origem_captacao" type="text" id="origem_captacao" size="25" readonly class="inputReadOnly" value="<%=(cli != null && cli.getOrigemCaptacao().getDescricao() != null ? cli.getOrigemCaptacao().getDescricao(): "")%>">
                                        <input name="localiza_origem" type="button" class="inputbotao" id="localiza_origem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.ORIGEM_CAPTACAO%>', 'Origem')">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaOrigem()" style="display:<%=(nivelComissao == 0 ? "none" : "")%>;">
                                        <input name="origem_captacao_id" type="hidden" id="origem_captacao_id" value="<%= (cli != null && cli.getOrigemCaptacao().getId() != 0 ? cli.getOrigemCaptacao().getId() : "") %>">
                                    </td>
                                    <td width="22%" class="TextoCampos">Responsável pelo acompanhamento das entregas (Focal Point):</td>
                                    <td width="24%" class="CelulaZebra2">
                                        <input name="usuario_nome" type="text" id="usuario_nome" size="25" readonly class="inputReadOnly" value="<%=(cli != null && cli.getResponsavelAcompanhamentoEntrega().getNome() != null ? cli.getResponsavelAcompanhamentoEntrega().getNome(): "")%>">
                                        <input name="localiza_usuario" type="button" class="inputbotao" id="localiza_usuario" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.USUARIO%>', 'Usuario')">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="$('usuario_nome').value='';$('usuario_id').value = '0';">
                                        <input name="usuario_id" type="hidden" id="usuario_id" value="<%= (cli != null && cli.getResponsavelAcompanhamentoEntrega().getIdusuario() != 0 ? cli.getResponsavelAcompanhamentoEntrega().getIdusuario() : "0") %>">
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">Filial Responsável:</td>
                                    <td class="CelulaZebra2">
                                        <select class="inputtexto" id="filialResponsavel" name="filialResponsavel">
                                            <option value="0" ${not carregacli or cli.filialResponsavel.idfilial eq 0 ? 'selected' : ''}>Não Informado</option>
                                            <c:forEach items="<%= filiais %>" var="filial">
                                                <option value="${filial.idfilial}" ${carregacli and cli.filialResponsavel.idfilial eq filial.idfilial ? 'selected' : ''}>${filial.abreviatura}</option>
                                            </c:forEach>
                                        </select>
                                        <span style="margin-left: 10px">
                                            <input type="checkbox" id="cteNfeEmissaoFilialResponsavel"
                                                   name="cteNfeEmissaoFilialResponsavel"
                                                   ${carregacli and cli.emitirCTeNFSeSomenteFilialResponsavel ? 'checked' : ''}>
                                            <label for="cteNfeEmissaoFilialResponsavel">Ct-e(s)/NFS-e(s) só poderão ser emitidos pela filial selecionada</label>
                                        </span>
                                    </td>
                                    <td class="CelulaZebra2" colspan="4">
                                        <input type="checkbox" id="faturaEmissaoFilialResponsavel"
                                               name="faturaEmissaoFilialResponsavel"
                                               ${carregacli and cli.emitirFaturaSomenteFilialResponsavel ? 'checked' : ''}>
                                        <label for="faturaEmissaoFilialResponsavel">Faturas só poderão ser emitidas com contas bancárias da filial selecionada</label>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <table width="100%" border="0" class="bordaFina">
                                            <tr>
                                                <td width="50%">
                                                    <table width="100%" border="0" class="bordaFina">
                                                        <tr class="celula"><td colspan="3">Dados do Vendedor</td></tr>
                                                        <tr>
                                                            <td width="15%" class="TextoCampos"><%=cfg.isClienteVendedorObrigatorio() ? "*" : ""%>Vendedor:</td>
                                                            <td width="85%" class="CelulaZebra2" colspan="2">
                                                                <input name="vendedor" type="text" id="vendedor" size="40" readonly class="inputReadOnly" value="<%=(cli != null && cli.getVendedor().getRazaosocial() != null ? cli.getVendedor().getRazaosocial() : "")%>">
                                                                <input name="localiza_vendedor" type="button" class="inputbotao" id="localiza_vendedor" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.VENDEDOR%>', 'Vendedor')" style="display:<%=(nivelComissao == 0 ? "none" : "")%>;">
                                                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaVendedor()" style="display:<%=(nivelComissao == 0 ? "none" : "")%>;">
                                                                <input name="ven_rzs" type="hidden" id="ven_rzs" value="">
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="TextoCampos" width="15%">Tipo Comissão:</td>
                                                            <td class="CelulaZebra2" colspan="2" width="85%">
                                                                <select name="tipoComissao" id="tipoComissao" class="inputtexto" onchange="label()" style="display:<%=(nivelComissao == 0 ? "none" : "")%>;">
                                                                    <option value="0">Percentual</option>
                                                                    <option value="1">Valor Fixo</option>
                                                                </select>&nbsp;
                                                                 <select name="tipoComissaoVendedor" id="tipoComissaoVendedor" class="inputtexto" onChange="alterarTipoComissaoVendedor();">
                                                                    <option <%= cli != null ?  (cli.getTipoComissaoVendedor() == 1 ? "selected" : "") : "selected" %> value="1">Unificada</option>
                                                                    <option <%= cli != null ?  (cli.getTipoComissaoVendedor() == 2 ? "selected" : "") : "" %> value="2">Por Modal</option>
                                                                </select>&nbsp;
                                                                <select name="tipoBaseComissao" id="tipoBaseComissao" class="inputtexto" style="width:140px;display:<%=(nivelComissao == 0 ? "none" : "")%>;">
                                                                    <option value="t" selected>Sobre Total da Prestação</option>
                                                                    <option value="f">Sobre Frete Peso</option>
                                                                </select>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="TextoCampos" width="20%">
                                                                <label id="sobre2" name="sobre2" >Comissão R$:</label>
                                                                <label id="sobre3" name="sobre3">Comissão %:</label>
                                                            </td>
                                                            <td class="CelulaZebra2" colspan="3" width="80%">
                                                                <label id="lbAereoVendedor">Aéreo:</label>
                                                                <input name="vlcomissao_vendedor" class="inputtexto" style="display:<%=(nivelComissao == 0 ? "none" : "")%>;" type="text" id="vlcomissao_vendedor" value="<%=(cli != null ? Apoio.to_curr(cli.getVlcomissaoVendedor()) : "0.00")%>" size="5" maxlength="8" onChange="seNaoFloatReset(this, '0.00')">
                                                                <br/>
                                                                <label id="lbRodoFracVendedor">Rodoviário Fracionado:</label>
                                                                <input name="ComissaoRodoviarioFracionadoVendedor" class="inputtexto" type="text" id="ComissaoRodoviarioFracionadoVendedor" value="<%=(cli != null ? Apoio.to_curr(cli.getComissaoRodoviarioFracionadoVendedor()) : "0.00")%>" size="5" maxlength="8" onChange="seNaoFloatReset(this, '0.00')">
                                                                <label id="lbRodLotVendedor">Lotação:</label>
                                                                <input name="ComissaoRodoviarioLotacaoVendedor" class="inputtexto" type="text" id="ComissaoRodoviarioLotacaoVendedor" value="<%=(cli != null ? Apoio.to_curr(cli.getComissaoRodoviarioLotacaoVendedor()) : "0.00")%>" size="5" maxlength="8" onChange="seNaoFloatReset(this, '0.00')">
                                                            </td>
                                                        </tr>
                                                        <tr class="celula">
                                                            <td colspan="3">Critérios de Pagamento Comissão Vendedor</td>
                                                        </tr>
                                                        <tr class="CelulaZebra2NoAlign">
                                                            <td align="center" colspan="3" class="TextoCamposNoAlign">
                                                                <label>
                                                                    <input type="checkbox" id="pagamentoComissaoVendedor" name="pagamentoComissaoVendedor" value="checkbox" <%=(carregacli && cli.isUtilizarCriterioPagamentoComissaoVendedor() ? "checked" : "")%>/>
                                                                    Utilizar os critérios abaixo para pagamento de comissão do vendedor
                                                                </label>
                                                            </td>
                                                        </tr>
                                                        <tr class="CelulaZebra2">
                                                            <td class="TextoCampos" ><label>Calc. Comissão:</label></td>
                                                            <td class="CelulaZebra2">
                                                                <select name="calcularComissaoVendedor" id="calcularComissaoVendedor" class="inputtexto" onchange="criterioCalculoComissao(this.value,'Vendedor');">
                                                                    <option value="l" <%=(carregacli ? (cli.getCalcularComissaoVendedor() == 'l' ? "selected" : "") :  "selected")%> >Valor L&iacute;quido</option>
                                                                    <option value="b" <%=(carregacli ? (cli.getCalcularComissaoVendedor() == 'b' ? "selected" : "") :  "")%> >Valor Bruto</option>
                                                                </select>
                                                            </td>
                                                            <td>
                                                                <div id="divRetirarContratoFreteBaseCalculo" style="display: " align="center">
                                                                    <label>
                                                                        <input type="checkbox" id="retirarContratoFreteBaseCalculoVendedor" name="retirarContratoFreteBaseCalculoVendedor" value="checkbox" <%=(carregacli && cli.isRetirarContratoFreteBaseCalculoVendedor() ? "checked" : "")%>/>
                                                                        Retirar contrato frete da base de cálculo
                                                                    </label>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr class="CelulaZebra2">
                                                            <td class="TextoCamposNoAlign">
                                                                <div id="divIcmsVendedor" style="display: " align="center"><label><input type="checkbox" id="icmsVendedor" name="icmsVendedor" value="checkbox" <%=(carregacli ? (cli.isImpostoFederalIcmsVendedor() ? "checked" : "") : "checked")%>/>ICMS</label></div>
                                                            </td>
                                                            <td class="TextoCamposNoAlign" colspan="2">
                                                                <div id="divImpostosVendedor" style="display: ">
                                                                    <label><input type="checkbox" id="impostoFederaisVendedor" name="impostoFederaisVendedor" value="false" onclick="marcarTodosImpostos('Vendedor')"/>Impostos federais</label>
                                                                    <label><input type="checkbox" id="pisVendedor" name="pisVendedor" value="checkbox" <%=(carregacli && cli.isImpostoFederalPisVendedor() ? "checked" : "")%>/>PIS</label>
                                                                    <label><input type="checkbox" id="cofinsVendedor" name="cofinsVendedor" value="checkbox" <%=(carregacli && cli.isImpostoFederalCofinsVendedor() ? "checked" : "")%>/>COFINS</label>
                                                                    <label><input type="checkbox" id="csslVendedor" name="csslVendedor" value="checkbox" <%=(carregacli && cli.isImpostoFederalCsslVendedor() ? "checked" : "")%>/>CSSL</label>
                                                                    <label><input type="checkbox" id="irVendedor" name="irVendedor" value="checkbox" <%=(carregacli && cli.isImpostoFederalIrVendedor() ? "checked" : "")%>/>IR</label>
                                                                    <label><input type="checkbox" id="inssVendedor" name="inssVendedor" value="checkbox" <%=(carregacli && cli.isImpostoFederalInssVendedor() ? "checked" : "")%>/>INSS</label>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr class="CelulaZebra2">
                                                            <td class="TextoCampos" colspan="2"><label>Em caso de recebimentos com juros, pagar comissão sobre:</label></td>
                                                            <td class="TextoCamposNoAlign">
                                                                <label>
                                                                    <input type="radio" name="valorJurosVendedor" id="valorRecebidoJurosVendedor" value="rj" <%=(carregacli ? (cli.getPagamentoComissaoJurosVendedor().equals("rj") ? "checked" : "") : "checked")%>/>
                                                                    Valor Recebido
                                                                </label>
                                                                <label>
                                                                    <input type="radio" name="valorJurosVendedor" id="valorOriginalJurosVendedor" value="oj" <%=(carregacli ? (cli.getPagamentoComissaoJurosVendedor().equals("oj") ? "checked" : "") : "")%>/>
                                                                    Valor Original
                                                                </label>
                                                            </td>
                                                        </tr>
                                                        <tr class="CelulaZebra2">
                                                            <td class="TextoCampos" colspan="2"><label>Em caso de recebimentos com desconto, pagar comissão sobre:</label></td>
                                                            <td class="TextoCamposNoAlign">
                                                                <label>
                                                                    <input type="radio" name="valorDescontoVendedor" id="valorRecebidoDescontoVendedor" value="rd" <%=(carregacli ? (cli.getPagamentoComissaoDescontoVendedor().equals("rd") ? "checked" : "") : "checked")%>/>
                                                                    Valor Recebido
                                                                </label>
                                                                <label>
                                                                    <input type="radio" name="valorDescontoVendedor" id="valorOriginalDescontoVendedor" value="od" <%=(carregacli ? (cli.getPagamentoComissaoDescontoVendedor().equals("od") ? "checked" : "") : "")%>/>
                                                                    Valor Original
                                                                </label>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                                <td width="50%">
                                                    <table width="100%" border="0" class="bordaFina">
                                                        <tr class="celula">
                                                            <td colspan="3">Dados do Supervisor</td>
                                                        </tr>
                                                        <tr>
                                                            <td width="20%" class="TextoCampos"><%=cfg.isClienteVendedor2Obrigatorio() ? "*" : ""%>Supervisor:</td>
                                                            <td width="80%" class="CelulaZebra2" colspan="2">
                                                                <input name="supervisor" type="text" id="supervisor" size="40" readonly class="inputReadOnly" value="<%=(cli != null && cli.getVendedor2().getRazaosocial() != null ? cli.getVendedor2().getRazaosocial() : "")%>">
                                                                <strong>
                                                                    <input name="localiza_vendedor2" type="button" class="inputbotao" id="localiza_vendedor2" value="..."
                                                                           onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.VENDEDOR%>', 'Supervisor')" style="display:<%=(nivelComissao == 0 ? "none" : "")%>;">
                                                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaSupervisor()" style="display:<%=(nivelComissao == 0 ? "none" : "")%>;">
                                                                </strong>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="TextoCampos">Tipo comiss&atilde;o:</td>
                                                            <td class="CelulaZebra2" colspan="2">
                                                                <select name="tipoComissao2" class="inputtexto" id="tipoComissao2" onchange="label()" style="display:<%=(nivelComissao == 0 ? "none" : "")%>;">
                                                                    <option value="0">Percentual</option>
                                                                    <option value="1">Valor Fixo</option>
                                                                </select>&nbsp;
                                                                <select name="tipoComissaoSupervisor" id="tipoComissaoSupervisor" class="inputtexto" onchange="alterarTipoComissaoSupervisor();">
                                                                    <option <%= cli != null ?  (cli.getTipoComissaoSupervisor() == 1 ? "selected" : "") : "selected" %> value="1">Unificada</option>
                                                                    <option <%= cli != null ?  (cli.getTipoComissaoSupervisor() == 2 ? "selected" : "") : "" %> value="2">Por Modal</option>
                                                                </select>

                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="TextoCampos">
                                                                <label id="sobre2_sup" name="sobre2_sup">Comissão R$:</label>
                                                                <label id="sobre3_sup" name="sobre3_sup">Comissão %:</label>
                                                            </td>
                                                            <td class="CelulaZebra2" colspan="3">
                                                                <label id="tdAereo2" style="display:<%=(nivelComissao == 0 ? "none" : "")%>;">Aéreo:</label>
                                                                <input name="vlcomissao_vendedor2" style="display:<%=(nivelComissao == 0 ? "none" : "")%>;" type="text" id="vlcomissao_vendedor2" value="<%=(cli != null ? Apoio.to_curr(cli.getVlcomissaoVendedor2()) : "0.00")%>"
                                                                       size="10" maxlength="8" class="inputtexto" onChange="seNaoFloatReset(this, '0.00')">
                                                                <label id="lbRodoFracSupervisor">Rodoviário Fracionado:</label>
                                                                <input name="ComissaoRodoviarioFracionadoSupervisor" class="inputtexto" type="text" id="ComissaoRodoviarioFracionadoSupervisor" value="<%=(cli != null ? Apoio.to_curr(cli.getComissaoRodoviarioFracionadoSupervisor()) : "0.00")%>" size="5" maxlength="8" onChange="seNaoFloatReset(this, '0.00')">
                                                                <label id="lbRodoLotSupervisor">Lotação:</label>
                                                                <input name="ComissaoRodoviarioLotacaoSupervisor" class="inputtexto" type="text" id="ComissaoRodoviarioLotacaoSupervisor" value="<%=(cli != null ? Apoio.to_curr(cli.getComissaoRodoviarioLotacaoSupervisor()) : "0.00")%>" size="5" maxlength="8" onChange="seNaoFloatReset(this, '0.00')">
                                                            </td>
                                                        </tr>
                                                        <tr class="celula"><td colspan="3">Critérios de Pagamento Comissão Supervisor</td></tr>
                                                        <tr class="CelulaZebra2NoAlign">
                                                            <td align="center" colspan="3" class="TextoCamposNoAlign">
                                                                <label>
                                                                    <input type="checkbox" id="pagamentoComissaoSupervisor" name="pagamentoComissaoSupervisor" value="checkbox" <%=(carregacli && cli.isUtilizarCriterioPagamentoComissaoSupervisor() ? "checked" : "")%>/>
                                                                    Utilizar os critérios abaixo para pagamento de comissão do supervisor
                                                                </label>
                                                            </td>
                                                        </tr>
                                                        <tr class="CelulaZebra2">
                                                            <td class="TextoCampos"><label>Calc. Comissão:</label></td>
                                                            <td>
                                                                <select name="calcularComissaoSupervisor" id="calcularComissaoSupervisor" class="inputtexto" onchange="criterioCalculoComissao(this.value,'Supervisor');">
                                                                    <option value="l" <%=(carregacli ? (cli.getCalcularComissaoSupervisor() == 'l' ? "selected" : "") :  "selected")%> >Valor L&iacute;quido</option>
                                                                    <option value="b" <%=(carregacli ? (cli.getCalcularComissaoSupervisor() == 'b' ? "selected" : "") :  "")%> >Valor Bruto</option>
                                                                </select>
                                                            </td>
                                                            <td>
                                                                <div id="divRetirarContratoFreteBaseCalculo" style="display: " align="center">
                                                                    <label>
                                                                        <input type="checkbox" id="retirarContratoFreteBaseCalculoSupervisor" name="retirarContratoFreteBaseCalculoSupervisor" value="checkbox" <%=(carregacli && cli.isRetirarContratoFreteBaseCalculoSupervisor() ? "checked" : "")%>/>
                                                                        Retirar contrato frete da base de cálculo
                                                                    </label>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr class="CelulaZebra2">
                                                            <td class="TextoCamposNoAlign">
                                                                <div id="divIcmsSupervisor" style="display: " align="center"><label><input type="checkbox" id="icmsSupervisor" name="icmsSupervisor" value="checkbox" <%=(carregacli ? (cli.isImpostoFederalIcmsSupervisor() ? "checked" : "") : "checked")%> />ICMS</label></div>
                                                            </td>
                                                            <td class="TextoCamposNoAlign" colspan="2">
                                                                <div id="divImpostosSupervisor" style="display: ">
                                                                    <label><input type="checkbox" id="impostoFederaisSupervisor" name="impostoFederaisSupervisor" value="false" onclick="marcarTodosImpostos('Supervisor')"/>Impostos federais</label>
                                                                    <label><input type="checkbox" id="pisSupervisor" name="pisSupervisor" value="checkbox" <%=(carregacli ? (cli.isImpostoFederalPisSupervisor() ? "checked" : "") : "")%> />PIS</label>
                                                                    <label><input type="checkbox" id="cofinsSupervisor" name="cofinsSupervisor" value="checkbox" <%=(carregacli ? (cli.isImpostoFederalCofinsSupervisor() ? "checked" : "") : "")%> />COFINS</label>
                                                                    <label><input type="checkbox" id="csslSupervisor" name="csslSupervisor" value="checkbox" <%=(carregacli ? (cli.isImpostoFederalCsslSupervisor() ? "checked" : "") : "")%> />CSSL</label>
                                                                    <label><input type="checkbox" id="irSupervisor" name="irSupervisor" value="checkbox" <%=(carregacli ? (cli.isImpostoFederalIrSupervisor() ? "checked" : "") : "")%> />IR</label>
                                                                    <label><input type="checkbox" id="inssSupervisor" name="inssSupervisor" value="checkbox" <%=(carregacli ? (cli.isImpostoFederalInssSupervisor() ? "checked" : "") : "")%> />INSS</label>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr class="CelulaZebra2">
                                                            <td class="TextoCampos" colspan="2"><label>Em caso de recebimentos com juros, pagar comissão sobre:</label></td>
                                                            <td class="TextoCamposNoAlign">
                                                                <label>
                                                                    <input type="radio" name="valorJurosSupervisor" id="valorRecebidoJurosSupervisor" value="rj" <%=(carregacli ? (cli.getPagamentoComissaoJurosSupervisor().equals("rj") ? "checked" : "") : "checked")%>/>
                                                                    Valor Recebido
                                                                </label>
                                                                <label>
                                                                    <input type="radio" name="valorJurosSupervisor" id="valorOriginalJurosSupervisor" value="oj" <%=(carregacli ? (cli.getPagamentoComissaoJurosSupervisor().equals("oj") ? "checked" : "") : "")%> />
                                                                    Valor Original
                                                                </label>
                                                            </td>
                                                        </tr>
                                                        <tr class="CelulaZebra2">
                                                            <td class="TextoCampos" colspan="2"><label>Em caso de recebimentos com desconto, pagar comissão sobre:</label></td>
                                                            <td class="TextoCamposNoAlign" >
                                                                <label>
                                                                    <input type="radio" name="valorDescontoSupervisor" id="valorRecebidoDescontoSupervisor" value="rd" <%=(carregacli ? (cli.getPagamentoComissaoDescontoSupervisor().equals("rd") ? "checked" : "") : "checked")%>/>
                                                                    Valor Recebido
                                                                </label>
                                                                <label>
                                                                    <input type="radio" name="valorDescontoSupervisor" id="valorOriginalDescontoSupervisor" value="od" <%=(carregacli ? (cli.getPagamentoComissaoDescontoSupervisor().equals("od") ? "checked" : "") : "")%> />
                                                                    Valor Original
                                                                </label>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </div>
                    <div id="tab5">
                        <fieldset id="tbOpe">
                            <table width="100%" border="0" class="bordaFina">
                                <tr class="tabela"><td align="center"><div align="center">Tributa&ccedil;&atilde;o ICMS</div></td></tr>
                                <tr>
                                    <td>
                                        <table width="100%">
                                            <tr>
                                                <td align="center" width="20%" class="CelulaZebra2">
                                                    <div align="center">
                                                        <input name="chkPautaFiscal" type="checkbox" id="chkPautaFiscal" value="checkbox" <%=(carregacli && cli.isUtilizaPautaFiscal() ? "checked" : "")%>>
                                                        Utilizar Pauta Fiscal de ICMS.
                                                    </div>
                                                </td>
                                                <td align="center" width="50%" class="CelulaZebra2">
                                                    <div align="center">
                                                        <input name="chkSTMG" type="checkbox" id="chkSTMG" value="checkbox" <%=(carregacli && cli.isSubstituicaoTributariaMinasGerais() ? "checked" : "")%>>
                                                        Ao embutir ICMS considerar redu&ccedil;&atilde;o de 20% conforme decreto nº 44.147/2005 (Substitui&ccedil;&atilde;o tribut&aacute;ria-MG).
                                                    </div>
                                                </td>
                                                <td align="center" width="30%" class="CelulaZebra2">
                                                    <div align="center">
                                                        Regime de Tributação:
                                                        <select id="tipoTributacao" name="tipoTributacao" class="fieldMin">
                                                            <option value="NI" <%= (carregacli ? (cli.getTipoTributacao().equals("NI") ? "selected" : "" ): "selected") %> >Não informado</option>
                                                            <option value="SN" <%= (carregacli ? (cli.getTipoTributacao().equals("SN") ? "selected" : "" ): "") %> >Simples Nacional</option>
                                                            <option value="LR" <%= (carregacli ? (cli.getTipoTributacao().equals("LR") ? "selected" : "" ): "") %> >Lucro Real</option>
                                                            <option value="LP" <%= (carregacli ? (cli.getTipoTributacao().equals("LP") ? "selected" : "" ): "") %> >Lucro Presumido</option>
                                                            <option value="ME" <%= (carregacli ? (cli.getTipoTributacao().equals("ME") ? "selected" : "" ): "") %> >MEI - Micro Empreendedor Individual</option>
                                                        </select>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr><tr style="display: ">
                                <td colspan="2">
                                    <table border="0" cellpadding="0" cellspacing="1" width="100%" align="center">
                                        <tbody id="tbStICMS">
                                            <tr class="celula">
                                                <td width="2%" >
                                                    <img src="img/add.gif" border="0" class="imagemLink " title="Situação Tributável" onClick="javascript:addStICMS();">
                                                </td>
                                                <td width="30%" align="center">Situação Tributária ICMS</td>
                                                <td width="20%" align="center">Filial</td>
                                                <td width="10%" align="center" >Redução Base de Cálculo</td>
                                                <td width="20%" align="center" ></td>
                                                <td width="20%" align="center" >Base de Cálculo para crédito fiscal presumido</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                                <tr class="tabela"><td align="center"><div align="center">Informa&ccedil;&otilde;es de Entrega</div></td></tr>
                                <tr>
                                    <td>
                                        <table width="100%" border="0" >
                                            <tr>
                                                <td width="10%" rowspan="9" class="TextoCampos">Ativar envio de e-mails autom&aacute;ticos nas seguintes situa&ccedil;&otilde;es: </td>
                                                <td width="20%" class="TextoCampos" colspan="1">
                                                    <div align="left">
                                                        <label>
                                                            <input name="chkEmailMDF" type="checkbox" id="chkEmailMDF" value="checkbox" <%=(carregacli && cli.IsEnviaEmailMDF() ? "checked" : "")%>>
                                                            Ao confirmar o MDF-e na SEFAZ
                                                        </label>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos" >
                                                    <div align="left">
                                                        <label>
                                                            <input name="chkEmailCtrc" type="checkbox" id="chkEmailCtrc" value="checkbox" <%=(carregacli && cli.isEnviaEmailCtrc() ? "checked" : "")%>>
                                                            Ao confirmar o CT-e na SEFAZ.
                                                        </label>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos" >
                                                    <div align="left">
                                                        <label>
                                                            <input name="chkEmailManifesto" type="checkbox" id="chkEmailManifesto" value="checkbox" <%=(carregacli && cli.isEnviaEmailManifesto() ? "checked" : "")%>>
                                                            Ao imprimir o manifesto.
                                                        </label>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos" >
                                                    <div align="left">
                                                        <label>
                                                            <input name="chkEnviaEmailOcorrencia" type="checkbox" id="chkEnviaEmailOcorrencia" value="checkbox" <%=(carregacli && cli.isEnviaEmailOcorrencia() ? "checked" : "")%>/>
                                                            Ao adicionar ocorrências no CT-e.
                                                        </label>
                                                            <input style="margin-left: 30px;" type="radio" name="enviarTipoOcorrencia" id="enviarAdicionada" value="a" <%= (carregacli ? (cli.getEnviarTipoOcorrencia().equals("a") ? "checked" : "") : "checked") %> >Enviar apenas a ocorrência adicionada
                                                            <input type="radio" name="enviarTipoOcorrencia" id="enviarTodas" value="t" <%= (carregacli ? (cli.getEnviarTipoOcorrencia().equals("t") ? "checked" : "") : "") %> >Enviar todas as ocorrências
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos" >
                                                    <div align="left">
                                                        <label>
                                                            <input name="chkEnviaEmailChegada" type="checkbox" id="chkEnviaEmailChegada" value="checkbox" <%=(carregacli && cli.isEnviaEmailChegada() ? "checked" : "")%> />
                                                             Ao registrar a chegada no destino.
                                                        </label>
                                                    </div>
                                                </td>
                                            <tr>
                                                <td class="TextoCampos" >
                                                    <div align="left">
                                                        <label>
                                                            <input name="chkEmailBaixaCtrc" type="checkbox" id="chkEmailBaixaCtrc"  value="checkbox" <%=(carregacli && cli.isEnviaEmailBaixaCtrc() ? "checked" : "")%>>
                                                            Ao baixar a entrega do CT-e.
                                                        </label>
                                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Anexar Comprovante:
                                                        <input type="radio" name="comprovante" id="anexar" value="s" <%=(cli.getAnexarComprovante() == "s" ? "checked " : "")%>>Sim
                                                        <input type="radio" name="comprovante" id="naoAnexar" value="n" <%=(cli.getAnexarComprovante() == "n" ? "checked " : "")%>>Não
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos" >
                                                    <div align="left">
                                                        <label>
                                                            <input name="chkEmailCancelarCTE" type="checkbox" id="chkEmailCancelarCTE"  value="checkbox" <%=(carregacli && cli.isEmailCancelarCTE() ? "checked" : "")%>>
                                                            Cancelamento do CT-e na SEFAZ
                                                        </label>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos" >
                                                    <div align="left">
                                                        <label>
                                                            <input name="chkEmailcartacorrCTE" type="checkbox" id="chkEmailcartacorrCTE"  value="checkbox" <%=(carregacli && cli.isEmailCartaCorrecaoCTE()? "checked" : "")%>>
                                                            Carta de correção do CT-e na SEFAZ
                                                        </label>
                                                    </div>
                                                </td>
                                            </tr>
                                <tr>
                                    <td class="TextoCampos">
                                        <div align="left">
                                            <label>
                                                <input name="chkEnviaEmailNfse" type="checkbox" id="chkEnviaEmailNfse" value="checkbox" <%=(carregacli && cli.isEnviaEmailNfse() ? "checked" : "")%>>
                                                Ao confirmar NFS-e na prefeitura.
                                            </label>
                                        </div>
                                    </td>
                                </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="CelulaZebra2">
                                        <div align="center">
                                            <label>
                                                <input name="dataEntregaMenor" type="checkbox" id="dataEntregaMenor" value="checkbox" <%=(carregacli && cli.isSalvarDataEntregaMenorEmissao() ? "checked" : "")%>>
                                                Ao baixar, permitir que a data de entrega de CT seja menor que data da emissão.
                                            </label>
                                        </div>
                                    </td>
                                </tr>
                                <tr class="tabela"><td align="center"><div align="center">Averba&ccedil;&atilde;o da Carga</div></td></tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">
                                        <div align="center">
                                            Responsabilidade da Averba&ccedil;&atilde;o da carga:
                                            <select name="tipoSeguroCarga" id="tipoSeguroCarga" class="fieldMin" onchange="javascript:responsabilidadeAverbacao();mostrarCamposEmbarcador(this.value)" >
                                                <option value="c">Cliente (Tomador do Serviço)</option>
                                                <option value="t" selected>Transportadora</option>
                                                <option value="tr">Transportadora (Apenas Roubo)</option>
                                                <option value="tt">Transportadora (Apenas Tombamento)</option>
                                            </select>
                                            <span id="spvalidadeDDR" name="spvalidadeDDR" class="TextoCampos">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<br>Validade DDR:
                                                <input name="dtddr" type="text" value="<%=(cli != null && cli.getValidadeDdr() != null ? fmt.format(cli.getValidadeDdr()) : "")%>" size="10" maxlength="10"  onblur="alertInvalidDate(this,true)" class="fieldDate" onkeypress="fmtDate(this,event)" onkeyup="fmtDate(this,event)" <%=(nivelOperacional >= 2 ? "" : "readonly")%>>
                                                &nbsp;&nbsp;&nbsp;&nbsp;
                                                Apólice:
                                                <input name="numero_apolice_ddr" type="text" value="<%=(cli != null ? cli.getNumeroApoliceDdr() : "")%>" size="20" maxlength="50"  class="inputtexto" <%=(nivelOperacional >= 2 ? "" : "readonly")%>>
                                                &nbsp;&nbsp;&nbsp;&nbsp;Seguradora:
                                                <select name="seguradora" id="seguradora" class="inputtexto">
                                                    <option value="0" selected>Não selecionada</option>
                                                    <%BeanConsultaFornecedor conFor = new BeanConsultaFornecedor();
                                                                conFor.setConexao(Apoio.getUsuario(request).getConexao());
                                                                conFor.mostraSeguradoras();
                                                                ResultSet rsFor = conFor.getResultado();
                                                                while (rsFor.next()) {%>
                                                                <option value="<%=rsFor.getString("idfornecedor")%>" <%=(cli != null && rsFor.getInt("idfornecedor") == cli.getSeguradoraDdr().getIdfornecedor() ? "selected" : "")%> ><%=rsFor.getString("razaosocial")%></option>
                                                    <%}
                                                                rsFor.close();%>
                                                </select>
                                            </span>
                                        </div>
                                    </td>
                                </tr>
                                <tr id="trXmlCteVcarga" style="display:none">
                                    <td align="center" width="100%" class="CelulaZebra2" ><div align="center"><input name="xmlCteVcarga001" type="checkbox" id="xmlCteVcarga001" value="checkbox" <%=(carregacli && cli.isXmlCteVcarga001()? "checked" : "")%> >
                                                        Cliente não possui DDR, ao gerar o XML do CT-e a tag vcarga deverá ser preenchida com 0,01</div></td>
                                </tr>
                                <tr id="trEmbarcador1" style="display: none">
                                    <td>
                                        <table width="100%" border="0" align="center" cellpadding="0">
                                            <tr>
                                                <td class="TextoCampos" width="20%">
                                                    Status Averbação AT&M (CT-e):
                                                </td>
                                                <td class="celulaZebra2" width="20%" colspan="2">
                                                    <select name="statusAverbacaoCte" id="statusAverbacaoCte" class="fieldMin" style="width: 50%" onchange="alterarAverbacao(this.value);alert('Para as alterações serem efetivadas, faça Logout!')">
                                                        <option value="N" <%=(carregacli && cli.getStUtilizacaoAverbacaoCTe()== "N".charAt(0)? "selected" : "")%>>Não Utiliza</option>
                                                        <option value="H" <%=(carregacli && cli.getStUtilizacaoAverbacaoCTe()== "H".charAt(0)? "selected" : "")%>>Homologação</option>
                                                        <option value="P" <%=(carregacli && cli.getStUtilizacaoAverbacaoCTe()== "P".charAt(0)? "selected" : "")%>>Produção</option>
                                                    </select>
                                                </td>
                                                <td width="15%" class="TextoCampos"><div id="txFormaTransmissaoCte">Forma de Transmissão:</div></td>
                                                <td width="20%" class="CelulaZebra2" colspan="4">
                                                    <div id="divFormaTransmissaoCte">
                                                    <input type="radio" name="radionCte" id="radionCte" value="m" checked <%= carregacli && cli.getFormaTransmissaoCTe() == "m".charAt(0) ? "checked" : ""%> >Manual
                                                    <input type="radio" name="radionCte" id="radionCte" value="a" <%= carregacli && cli.getFormaTransmissaoCTe() == "a".charAt(0) ? "checked" : ""%> >Automaticamente após confirmado na sefaz
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr id="trCaixaPostal">
                                                <td class="TextoCampos">
                                                    Caixa Postal Rodoviário:
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <select  name="seguradoraRodoviario" id="seguradoraRodoviario" class="fieldMin"  style="width: 120px;">
                                                          <option value="0">Selecione</option>
                                                        <% for(CaixaPostalSeguradora postalSeguradora : listaCaixaPostalSeguradora){%>
                                                             <option value="<%=postalSeguradora.getId()%>" <%=(carregacli && cli.getCaixaPostalSeguradoraRodoviario().getId() == postalSeguradora.getId() ? "selected" : "")%>><%=postalSeguradora.getDescricao()%></option>
                                                        <%}%>
                                                    </select>
                                                </td>
                                                <td class="textoCampos">
                                                    Caixa Postal Aéreo:
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <select name="seguradoraAereo" id="seguradoraAereo" class="fieldMin"  style="width: 120px;">
                                                          <option value="0">Selecione</option>
                                                                 <% for(CaixaPostalSeguradora postalSeguradora : listaCaixaPostalSeguradora){%>
                                                             <option value="<%=postalSeguradora.getId()%>" <%=(carregacli && cli.getCaixaPostalSeguradoraAereo().getId() == postalSeguradora.getId() ? "selected" : "")%> ><%=postalSeguradora.getDescricao()%></option>
                                                        <%}%>
                                                    </select>
                                                </td>
                                                <td class="textoCampos">
                                                    Caixa Postal Aquaviário:
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <select name="seguradoraAquaviario" id="seguradoraAquaviario" class="fieldMin"  style="width: 120px;">
                                                          <option value="0">Selecione</option>
                                                                 <% for(CaixaPostalSeguradora postalSeguradora : listaCaixaPostalSeguradora){%>
                                                             <option value="<%=postalSeguradora.getId()%>" <%=(carregacli && cli.getCaixaPostalSeguradoraAquaviario().getId() == postalSeguradora.getId() ? "selected" : "")%> ><%=postalSeguradora.getDescricao()%></option>
                                                        <%}%>
                                                    </select>
                                                </td>
                                                <td class="CelulaZebra2" colspan="2">
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr id="trEmbarcador2" style="display: none">
                                    <td class="TextoCampos" ><div align="center">Tipos de CT-e que poderão ser Averbados:</div></td>
                                </tr>
                                <tr id="trEmbarcador3" name="trEmbarcador3" style="display: none">
                                    <td>
                                    <table width="100%" border="0" align="center" cellpadding="0">
                                        <tr>
                                            <td class="CelulaZebra2" width="35%">
                                                <input type="checkbox" class="inputtexto" name="averbarNormal" id="averbarNormal" <%=(carregacli && cli.isAverbarCTeNormal() ? "checked" : "")%>>Normal
                                            </td>
                                            <td class="CelulaZebra2" width="35%">
                                                <input type="checkbox" class="inputtexto" name="averbarDistLocal" id="averbarDistLocal" <%=(carregacli && cli.isAverbarCTeDistLocal()? "checked" : "")%>>Distribuição Local
                                            </td>
                                            <td class="CelulaZebra2" width="30%">
                                                <input type="checkbox" class="inputtexto" name="averbarDiarias" id="averbarDiarias" <%=(carregacli && cli.isAverbarCTeDiarias()? "checked" : "")%>>Diárias
                                            </td>
                                        </tr>
                                        <tr id="tdInfoAverbacao3" >
                                            <td class="CelulaZebra2">
                                                <input type="checkbox" class="inputtexto" name="averbarPallets" id="averbarPallets" <%=(carregacli && cli.isAverbarCTePallets() ? "checked" : "")%>>Pallets
                                            </td>
                                            <td class="CelulaZebra2">
                                                <input type="checkbox" class="inputtexto" name="averbarComplementar" id="averbarComplementar" <%=(carregacli && cli.isAverbarCTeComplementar()? "checked" : "")%>>Complementar
                                            </td>
                                            <td class="CelulaZebra2">
                                               <input type="checkbox" class="inputtexto" name="averbarReentrega" id="averbarReentrega" <%=(carregacli && cli.isAverbarCTeReentrega() ? "checked" : "")%>>Reentrega
                                            </td>
                                        </tr>
                                         <tr id="tdInfoAverbacao5" >
                                            <td class="CelulaZebra2">
                                                <input type="checkbox" class="inputtexto" name="averbarDevolucao" id="averbarDevolucao" <%=(carregacli && cli.isAverbarCTeDevolucao()? "checked" : "")%>>Devolução
                                            </td>
                                            <td class="CelulaZebra2">
                                                <input type="checkbox" class="inputtexto" name="averbarCortesia" id="averbarCortesia" <%=(carregacli && cli.isAverbarCTeCortesia()? "checked" : "")%>>Cortesia
                                            </td>
                                            <td class="CelulaZebra2">
                                                <input type="checkbox" class="inputtexto" name="averbarSubstituicao" id="averbarSubstituicao" <%=(carregacli && cli.isAverbarCTeSubstituicao()? "checked" : "")%>>Substituição
                                            </td>
                                        </tr>
                                    </table>
                                    </td>
                                </tr>
                                <tr id="trEmbarcador4" style="display: none">
                                    <td>
                                        <table width="100%" border="0" align="center" cellpadding="0">
                                            <tr>
                                                <td class="textoCampos" width="25%">
                                                    Status Averbação AT&M (NFS-e):
                                                </td>
                                                <td class="celulaZebra2" width="25%" colspan="2">

                                                    <div id="SelectStatusNfs">
                                                    <select name="statusAverbacaoNfs" id="statusAverbacaoNfs" class="fieldMin" style="width: 50%" onchange="alterarAverbacaoNfs(this.value);">
                                                        <option value="N" <%=(carregacli && cli.getStUtilizacaoAverbacaoNFSe() == "N".charAt(0)? "selected" : "")%>>Não Utiliza</option>
                                                        <option value="H" <%=(carregacli && cli.getStUtilizacaoAverbacaoNFSe() == "H".charAt(0)? "selected" : "")%>>Homologação</option>
                                                        <option value="P" <%=(carregacli && cli.getStUtilizacaoAverbacaoNFSe() == "P".charAt(0)? "selected" : "")%>>Produção</option>
                                                    </select>
                                                    </div>
                                                </td>
                                                <td width="15%" class="TextoCampos" id="txtFormaTransmissao"><div id="formaNfs">Forma de Transmissão:</div></td>
                                                <td width="35%" class="CelulaZebra2" colspan="2" id="radioFormaTransmissao">
                                                    <div id="divRadioNfs">
                                                        <input type="radio" name="radionNfs" id="radionNfs" value="m" checked <%= carregacli && cli.getFormaTransmissaoNFSe()== "m".charAt(0) ? "checked" : ""%> >Manual
                                                        <input type="radio" name="radionNfs" id="radionNfs" value="a" <%= carregacli && cli.getFormaTransmissaoNFSe()== "a".charAt(0) ? "checked" : ""%> >Automaticamente após confirmado na prefeitura
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr id="trEmbarcador5" style="display: none">
                                    <td>
                                       <table width="100%" border="0" align="center" cellpadding="0">
                                            <td class="textoCampos" width="20%">
                                                Caixa Postal NFS-e:
                                            </td>
                                            <td class="CelulaZebra2" width="80%" >
                                                <select name="cxPostalNfs" id="cxPostalNfs" class="fieldMin"  style="width: 120px;">
                                                      <option value="0">Selecione</option>
                                                             <% for(CaixaPostalSeguradora postalSeguradora : listaCaixaPostalSeguradora){%>
                                                         <option value="<%=postalSeguradora.getId()%>" <%=(carregacli && cli.getCaixaPostalSeguradoraNFSe().getId() == postalSeguradora.getId() ? "selected" : "")%> ><%=postalSeguradora.getDescricao()%></option>
                                                    <%}%>
                                                </select>
                                            </td>
                                        </table>
                                    </td>
                                </tr>
                                <tr id="trEmbarcador6" style="display: none">
                                    <td>
                                        <table width="100%" border="0" align="center" cellpadding="0">
                                            <td class="textoCampos" width="20%">
                                                A partir da data:
                                            </td>
                                            <td class="celulaZebra2"width="80%">
                                                <input type="text" onblur="alertInvalidDate(this)" class="fieldDate" value="<%=(carregacli  ? fmt.format(cli.getDataInicialAverbacao()): "")%>" maxlength="10" size="10" id="dtApatir" name="dtApatir" onkeypress="fmtDate(this, event)" onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)">
                                            </td>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <table width="100%" align="center" >
                                           <tr>
                                    <td width="100%" class="celulaZebra2">
                                        <table width="100%">
                                            <tr>
                                            <td width="80%" style="vertical-align:top;">
                                            <input type="hidden" id="contExcecaoCliente" name="contExcecaoCliente" value="<%= cli != null ? cli.getClienteRespseg().size() : 0 %>">
                                            <table class="bordaFina tabelaZerada"  width="100%"  id="excecaoClientes">
                                                <tr class="tabela"><td colspan="3" align="center">Exceções</td></tr>
                                                <tr class="celulaZebra2">
                                                    <td width="5%"><img src="img/add.gif" border="0" title="Adicionar uma nova Exceção" class="imagemLink" onclick="addExcecaoCliente()"></td>
                                                    <td width="90%">Exceção</td>
                                                </tr>
                                            </table>
                                            </td>
                                        <td width="20%" style="vertical-align:top;">
                                            <table class="bordaFina" width="20%" id="taxaTombamentoRoubo">
                                                <tbody>
                                                    <tr class="tabela">
                                                      <td colspan="8" align="center">Taxas de Seguros</td>
                                                    </tr>

                                                <tr class="tabela" >
                                                    <td width="33%" align="center"></td>
                                                    <td width="33%" align="center">Aéreo</td>
                                                    <td width="33%" align="center">Rodoviário</td>
                                                </tr>
                                                </tbody>
                                                <tbody>
                                                <tr class="CelulaZebra2NoAlign">
                                                    <td colspan="1" class="TextoCampos">Roubo:</td>
                                                    <td colspan="1" align="left"><input class="inputtexto" type="text" id="taxaSeguroRouboAereo" name="taxaSeguroRouboAereo" value="<%=(cli != null ? cli.getTaxaSeguroRouboAereo() : 0)%>" onchange="javascript: seNaoFloatReset(this,0.00)"></td>
                                                    <td colspan="1" align="left"><input class="inputtexto" type="text" id="taxaSeguroRouboRodoviario" name="taxaSeguroRouboRodoviario" value="<%= (cli != null ? cli.getTaxaSeguroRouboRodoviario() : 0) %>" onchange="javascript: seNaoFloatReset(this,0.00)"></td>
                                                </tr>
                                                <tr class="CelulaZebra2NoAlign">
                                                    <td colspan="1" class="TextoCampos">Tombamento:</td>
                                                    <td colspan="1" align="left"><input class="inputtexto" type="text" id="taxaSeguroTombamentoAereo" name="taxaSeguroTombamentoAereo" value="<%=(cli != null ? cli.getTaxaSeguroTombamentoAereo() : 0)%>" onchange="javascript: seNaoFloatReset(this,0.00)"></td>
                                                    <td colspan="1" align="left"><input class="inputtexto" type="text" id="taxaSeguroTombamentoRodoviario" name="taxaSeguroTombamentoRodoviario" value="<%= (cli != null ? cli.getTaxaSeguroTombamentoRodoviario() : 0) %>" onchange="javascript: seNaoFloatReset(this,0.00)"></td>
                                                </tr>
                                                </tbody></table></td></tr></table></td></tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr class="tabela"><td align="center"><div align="center">Configurações CT-e</div></td></tr>
                                <tr>
                                    <td colspan="2">
                                        <table width="100%" border="0" align="center" cellpadding="0" >
                                            <tr>
                                            <td width="50%" class="TextoCampos">Ao enviar MDF-e por email anexar:</td>
                                            <td width="50%" class="CelulaZebra2">
                                                <input class="optionEnvioMDF" type="radio" name="emailMDF" id="envioMDFDAM" value="1">Apenas o DAMDFE
                                                <input class="optionEnvioMDF" type="radio" name="emailMDF" id="envioMDFDAC" value="2">Apenas o DACTE
                                                <input class="optionEnvioMDF" type="radio" name="emailMDF" id="envioMDFCTE" value="3">Apenas o xml do Ct-e
                                                <input class="optionEnvioMDF" type="radio" name="emailMDF" id="envioMDFALL" value="4">Apenas o DAMDFE, DACTE e o XML do Ct-e
                                            </td>
                                            </tr>
                                            <tr>
                                            <td width="50%" class="TextoCampos">Ao enviar o CT-e por e-mail anexar:</td>
                                            <td width="50%" class="CelulaZebra2">
                                                <input type="radio" name="email" id="xml" value="x" <%=(cli.getTipoEnvioEmailCte() == "x" ? "checked " : "")%>>Apenas o XML
                                                <input type="radio" name="email" id="dacte" value="d" <%=(cli.getTipoEnvioEmailCte() == "d" ? "checked " : "")%>>Apenas o DACTE
                                                <input type="radio" name="email" id="xdacte" value="xd" <%=(cli.getTipoEnvioEmailCte() == "xd" ? "checked " : "")%> >XML e DACTE
                                            </td>
                                            </tr>
                                            <tr>
                                                <td class="CelulaZebra2" style="text-align: right" >
                                                    <input type="checkbox" name="isEnviaFtp" onclick="mostrarFTP();" id="isEnviaFtp" <%=(cli.isXmlEnvioFtp() ? "checked " : "")%>>&nbsp;&nbsp;Ao confirmar o CT-e na SEFAZ enviar XML para o FTP:
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <select name="enviaXmlFtp" id="enviaXmlFtp" class="fieldMin" style="display: none; width: 20%">
                                                        <% for(ConfigTransf ftplist : listarFtp){%>
                                                         <option value="<%=ftplist.getId()%>" <%=(carregacli && cli.getConfigFtp().getId() == ftplist.getId() ? "selected" : "")%> ><%=ftplist.getDescricao()%></option>
                                                        <%}%>
                                                    </select>
                                                </td>
                                            </tr>
                                            <!--History 374 -->
                                            <tr>
                                                 <td class="CelulaZebra2" style="text-align: right" >
                                                     <input type="checkbox" id="ckEspecieSerieModal" name="ckEspecieSerieModal" ${carregacli && cli.especieSerieModal ? "checked" : ""}>
                                                     <label for="ckEspecieSerieModal">Utilizar espécie/série/modal específicos para esse cliente:</label>
                                                </td>
                                                 <td class="CelulaZebra2" colspan="1" style="text-align: left" >
                                                     <input size="3" class="inputtexto" type="text" id="inpEspecie" name="inpEspecie" value="${carregacli and not empty cli.especie ? cli.especie : "CTE"}" maxlength="3">/
                                                     <input size="3" class="inputtexto" type="text" id="inpSerie" name="inpSerie" value="${carregacli and not empty cli.serie ? cli.serie : 1}" maxlength="3">
                                                     <select name="modalCliente"  class="fieldMin" id="modalCliente" style="font-size:8pt;">
                                                         <option value="r" ${carregacli and cli.modalCliente eq 'r' ? "selected" : ""}>Rodoviário</option>
                                                         <option value="a" ${carregacli and cli.modalCliente eq 'a' ? "selected" : ""}>Aéreo</option>
                                                         <option value="q" ${carregacli and cli.modalCliente eq 'q' ? "selected" : ""}>Aquaviário</option>
                                                    </select>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                <td width="100%" colspan="2" class="celulaZebra2">
                                    <table width="100%" >

                                        <tr>
                                            <td width="30%" style="vertical-align:top;">
                                                <table width="100%" class="bordaFina tabelaZerada">
                                                    <tr class="tabela"><td align="center" colspan="3"  height="40"><div align="center">Campos Personalizados na TAG xOBS (Observação)</div></td></tr>
                                                    <tr class="celula">
                                                        <td class="celula"  width="10%" >
                                                            <input id="maxCampoP" name="maxCampoP" value="0" type="hidden" />
                                                            <img src="img/add.gif" border="0" title="Campos personalizados para transmissão de CT-e" class="imagemLink" style="vertical-align:middle;" onClick="javascript:addCampos();">
                                                        </td>
                                                        <td width="50%" align="center">Nome do Campo</td>
                                                        <td width="40%" align="center" height="50">Nome do Campo no Banco de Dados</td>
                                                    </tr>
                                                    <tbody id="tbCampo"></tbody>
                                                </table>
                                            </td>
                                            <td width="30%" style="vertical-align:top;">
                                                <table width="100%" class="bordaFina tabelaZerada">
                                                    <tr class="tabela"><td align="center" colspan="4" height="40"><div align="center">Campos Personalizados na TAG vPrest (Total Prestação)</div></td></tr>
                                                    <tr class="celula">
                                                        <td class="celula" width="5%">
                                                            <input id="maxCampoT" name="maxCampoT" value="0" type="hidden" />
                                                            <img src="img/add.gif" border="0" title="Adicionar Campo Taxas" class="imagemLink" style="vertical-align:middle;" onClick="javascript:addCamposTaxas()">
                                                        </td>
                                                        <td width="20%" align="center">Não enviar no XML</td>
                                                        <td width="40%" align="center">Nome do Campo no XML</td>
                                                        <td width="35%" align="center" height="50">Taxas</td>
                                                    </tr>
                                                    <tbody id="tbTaxas"></tbody>
                                                </table>
                                            </td>
                                            <td width="40%" style="vertical-align:top;">
                                                <table width="30%" class="bordaFina tabelaZerada">
                                                    <tr class="tabela"><td align="center" colspan="4" height="40"><div align="center">Campos Personalizados na TAG infQ (Informações da Carga)</div></td></tr>
                                                    <tr class="celula">
                                                        <td class="celula"  width="10%" >
                                                            <input id="maxCampoInfQ" name="maxCampoInfQ" value="0" type="hidden" />
                                                            <img src="img/add.gif" border="0" title="Campos Personalizados na TAG infQ (Informações da Carga)" class="imagemLink" style="vertical-align:middle;" onClick="javascript:addCampoInfQ();">
                                                        </td>
                                                        <td width="20%" align="center">Nome do campo</td>
                                                        <td width="20%" align="center">Cód. UND</td>
                                                        <td width="40%" align="center" height="50">Campo do Banco de dados</td>
                                                    </tr>
                                                    <tbody id="tbCampoInfQ"></tbody>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td width="100%" colspan="2" class="celulaZebra2">
                                    <table width="100%" >
                                    <tr>
                                            <td width="30%" style="vertical-align:top;">
                                                <table width="100%" class="bordaFina tabelaZerada">
                                                    <tr class="tabela">
                                                        <td align="center" colspan="5"  height="40"><div align="center">Campos Personalizados nas TAGs xCaracAd e xCaracSer</div></td></tr>
                                                    <tr class="celula">
                                                        <td class="celula"  width="5%" >
                                                            <input id="maxCampoXcarac" name="maxCampoXcarac" value="0" type="hidden" />
                                                            <img src="img/add.gif" border="0" title="Campos personalizados para transmissão de CT-e" class="imagemLink" style="vertical-align:middle;" onClick="javascript:addXcarac(null);">
                                                        </td>
                                                        <td width="17%" align="center">TAG CT-e</td>
                                                        <td width="30%" align="center" height="50">Valor da TAG</td>
                                                        <td width="28%" align="center" height="50"> Tipo de Ct-e/Serviço</td>
                                                        <td width="20%" align="center" height="50">Modal</td>
                                                    </tr>
                                                    <tbody id="tbCampoXcarac"></tbody>
                                                </table>
                                            </td>

                                            <td width="30%" style="vertical-align:top;">
                                                <table width="100%" class="bordaFina">
                                                    <tr class="tabela"><td align="center" colspan="4" height="40"><div align="center">CNPJ(s) autorizados a baixar o XML do CT-e/NF-e da SEFAZ</div></td></tr>
                                                    <tr class="celula">
                                                        <td class="celula" width="5%">
                                                            <input id="maxCampoT" name="maxCampoT" value="0" type="hidden" />
                                                            <img src="img/add.gif" border="0" title="Adicionar CNPJ/CPF Autorizado" class="imagemLink" style="vertical-align:middle;" onClick="javascript:addXmlAutorizado()">
                                                        </td>
                                                            <td width="20%" align="center">CNPJ</td>
                                                            <td width="20%" align="center"></td>
                                                                </tr>
                                                                <tbody id="tbXmlAut"></tbody>
                                                </table>
                                            </td>
                                            <td width="40%" style="vertical-align:top;">
                                            </td>
                                  </tr>
                                </table>
                               </td>

                            </tr>
                            <tr class="tabela"><td align="center"><div align="center">Outras Informa&ccedil;&otilde;es operacionais</div></td></tr>
                                <tr>
                                    <td width="100%">
                                        <table class="bordaFina" width="100%" >
                                            <tr>
                                                <td class="CelulaZebra2">
                                                    <div align="center">
                                                        <label for="msgCliCte" class="textoCampos">Mensagem ao incluir um CT-e:</label>
                                                    </div>
                                                    <div align="center">
                                                        <textarea rows="2" cols="50" id="msgCliCte"
                                                                  name="msgCliCte"></textarea>
                                                    </div>
                                                    <div align="center" style="padding-top: 10px">
                                                        <label for="msgCliColeta" class="textoCampos">Mensagem ao incluir uma coleta:</label>
                                                    </div>
                                                    <div align="center">
                                                        <textarea rows="2" cols="50" id="msgCliColeta"
                                                                  name="msgCliColeta"></textarea>
                                                    </div>
                                                </td>
                                                <td class="CelulaZebra2" width="33%">
                                                    <div align="center">
                                                        <label for="obs_lin1" class="textoCampos">Observação Padrão ao Emitir CT-e:</label>
                                                    </div>
                                                    <div style="padding-left: 5px; padding-top: 5px">
                                                        <input name="obs_lin1" type="text" class="inputtexto" id="obs_lin1" value="<%=(cli != null ? cli.getObservacao().split("\n")[0] : "")%>" size="59" maxlength="99" >
                                                    </div>
                                                    <div style="padding-left: 5px; padding-top: 5px">
                                                        <input name="obs_lin2" type="text" class="inputtexto" id="obs_lin2" value="<%=(cli != null && cli.getObservacao().split("\n").length >= 2 ? cli.getObservacao().split("\n")[1] : "")%>" size="59" maxlength="99">
                                                    </div>
                                                    <div style="padding-left: 5px; padding-top: 5px">
                                                        <input name="obs_lin3" type="text" class="inputtexto" id="obs_lin3" value="<%=(cli != null && cli.getObservacao().split("\n").length >= 3 ? cli.getObservacao().split("\n")[2] : "")%>" size="59" maxlength="99">
                                                    </div>
                                                    <div style="padding-left: 5px; padding-top: 5px">
                                                        <input name="obs_lin4" type="text" class="inputtexto" id="obs_lin4" value="<%=(cli != null && cli.getObservacao().split("\n").length >= 4 ? cli.getObservacao().split("\n")[3] : "")%>" size="59" maxlength="99">
                                                    </div>
                                                    <div style="padding-left: 5px; padding-top: 5px; padding-bottom: 5px">
                                                        <input name="obs_lin5" type="text" class="inputtexto" id="obs_lin5" value="<%=(cli != null && cli.getObservacao().split("\n").length >= 5 ? cli.getObservacao().split("\n")[4] : "")%>" size="59" maxlength="99">
                                                        <input type="button" class="botoes" value="..." onclick="launchPopupLocate('./localiza?acao=consultar&amp;idlista=28', 'Observacao');">
                                                    </div>
                                                </td>
                                                <td class="CelulaZebra2" width="33%" colspan="2">
                                                    <div align="center">
                                                        <label for="obs_fisco_lin1" class="textoCampos">Observação padrão reservada ao fisco ao emitir um CT-e:</label>
                                                    </div>
                                                    <div style="padding-left: 5px; padding-top: 5px">
                                                        <input name="obs_fisco_lin1" type="text" class="inputtexto" id="obs_fisco_lin1" value="<%=(cli != null ? cli.getObservacaoFisco().split("\n")[0] : "")%>" size="59" maxlength="99" >
                                                    </div>
                                                    <div style="padding-left: 5px; padding-top: 5px">
                                                        <input name="obs_fisco_lin2" type="text" class="inputtexto" id="obs_fisco_lin2" value="<%=(cli != null && cli.getObservacaoFisco().split("\n").length >= 2 ? cli.getObservacaoFisco().split("\n")[1] : "")%>" size="59" maxlength="99">
                                                    </div>
                                                    <div style="padding-left: 5px; padding-top: 5px">
                                                        <input name="obs_fisco_lin3" type="text" class="inputtexto" id="obs_fisco_lin3" value="<%=(cli != null && cli.getObservacaoFisco().split("\n").length >= 3 ? cli.getObservacaoFisco().split("\n")[2] : "")%>" size="59" maxlength="99">
                                                    </div>
                                                    <div style="padding-left: 5px; padding-top: 5px">
                                                        <input name="obs_fisco_lin4" type="text" class="inputtexto" id="obs_fisco_lin4" value="<%=(cli != null && cli.getObservacaoFisco().split("\n").length >= 4 ? cli.getObservacaoFisco().split("\n")[3] : "")%>" size="59" maxlength="99">
                                                    </div>
                                                    <div style="padding-left: 5px; padding-top: 5px; padding-bottom: 5px">
                                                        <input name="obs_fisco_lin5" type="text" class="inputtexto" id="obs_fisco_lin5" value="<%=(cli != null && cli.getObservacaoFisco().split("\n").length >= 5 ? cli.getObservacaoFisco().split("\n")[4] : "")%>" size="59" maxlength="99">
                                                        <input type="button" class="botoes" value="..." onclick="launchPopupLocate('./localiza?acao=consultar&amp;idlista=28', 'Observacao_Fisco');">
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos">Unidade de custo padrão para lançamentos de receitas:</td>
                                                <td class="CelulaZebra2">
                                                    <input name="siglaUnidadeCusto" type="text" id="siglaUnidadeCusto" size="10" readonly class="inputReadOnly" value="<%=(cli != null && cli.getUnidadeCustoReceita().getSigla() != null ? cli.getUnidadeCustoReceita().getSigla() : "")%> " >
                                                    <input name="localizaUnidadeCusto" type="button" class="inputbotao" id="localizaUnidadeCusto" value="..." onclick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.UNIDADE_CUSTO%>', 'UnidadeCustoReceita')">
                                                    <img src="img/borracha.gif" align="absbottom" class="imagemLink" onclick="javascript:getObj('siglaUnidadeCusto').value='';getObj('unidadeId').value=0;">
                                                    <input type="hidden" name="unidadeId" id="unidadeId" value="<%=cli != null ? cli.getUnidadeCustoReceita().getId() : 0%>">
                                                </td>
                                                <td class="CelulaZebra2" width="50%" colspan="2">
                                                    <label>
                                                        <div>
                                                            <input type="checkbox" id="chkNumeroInformado" name="chkNumeroInformado" <%=(cli != null ? (cli.isNumeroContainer() ? "checked" : "") : "")%>>
                                                            Obrigar a inclusão do número do container ao lançar um CT-e.
                                                        </div>
                                                    </label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos" width="35%" >Unidade de Custo padrão para lançamentos de contratos de fretes:</td>
                                                <td class="CelulaZebra2" width="15%">
                                                    <input name="siglaUnidadeCustoFrete" type="text" id="siglaUnidadeCustoFrete" size="10" readonly class="inputReadOnly" value="<%=(cli != null && cli.getUnidadeCusto().getSigla() != null ? cli.getUnidadeCusto().getSigla() : "")%> " >
                                                    <input name="localizaUnidadeCustoFrete" type="button" class="inputbotao" id="localizaUnidadeCustoFrete" value="..." onclick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.UNIDADE_CUSTO%>', 'UnidadeCustoFrete')">
                                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onclick="getObj('siglaUnidadeCustoFrete').value='';getObj('unidadeFreteId').value=0;">
                                                    <input type="hidden" name="unidadeFreteId" id="unidadeFreteId" value="<%=cli != null ? cli.getUnidadeCusto().getId() : 0%>">
                                                </td>

                                                <td class="CelulaZebra2" width="50%" colspan="2">
                                                    <label>
                                                        <div>
                                                            <input name="chkFaturarMinuta" type="checkbox" id="chkFaturarMinuta" value="checkbox" <%=(carregacli && cli.isIsFaturarMesmaCidadeComNfse() ? "checked" : "")%>>
                                                            Ao Faturar Minuta gerar NFS-e para entregas dentro da cidade do embarcador.
                                                        </div>
                                                    </label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos">Tipo de Nota Fiscal Padrão nos lançamentos de Coletas/CT-e: </td>
                                                <td class="CelulaZebra2">
                                                    <select id="tipoDocumentoPadrao" name="tipoDocumentoPadrao" class="fieldMin">
                                                        <option value="NF">NF</option> ;
                                                        <option value="NE" selected >NF-e</option>
                                                        <option value="00">Declaração</option>
                                                        <option value="10">Dutoviário</option>
                                                        <option value="99">Outros</option>
                                                    </select>
                                                </td>
                                                <td class="CelulaZebra2" colspan="2">
                                                    <label>
                                                        <div>
                                                            <input name="carregarRotasContratoCliente" type="checkbox" id="carregarRotasContratoCliente" value="true" <%=(carregacli && cli.isMostrarRotasDesseCliente() ? "checked" : "")%> />
                                                            Ao carregar as rotas no contrato de frete deverá considerar apenas as rotas para esse cliente.
                                                        </div>
                                                    </label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos">Valor da diária parado para lançamentos de contratos de fretes:</td>
                                                <td class="CelulaZebra2">
                                                    <input name="valorDiariaParado" type="text" id="valorDiariaParado" class="<%=(nivelOperacional == 4 ? "inputtexto" : "inputReadOnly")%>" value="<%=(cli != null ? Apoio.to_curr(cli.getValorDiariaParado()) : "")%>" size="8" maxlength="9" onChange="seNaoFloatReset(this, '0.00')" <%=(nivelOperacional == 4 ? "" : "readonly")%>>
                                                    <img class="imagemLink" title="Valor da diária parado para lançamentos de contratos de fretes" src="img/add.gif" onclick="addCampoDiarias();"/>
                                                </td>
                                                <td class="CelulaZebra2" colspan="2">
                                                    <label>
                                                        <div>
                                                            <input name="considerarCubagemProduto" type="checkbox" id="considerarCubagemProduto" value="true" <%=(carregacli && cli.isConsiderarCubagemProduto()? "checked" : "")%> />
                                                            Ao importar CT-e (XML ou Chave de Acesso), carregar a cubagem do cadastro do produto.
                                                        </div>
                                                    </label>
                                                </td>
                                                <tr>
                                                    <td class="CelulaZebra2"></td>
                                                    <td class="CelulaZebra2">
                                                        <input type="checkbox" name="isGerarNfseCidadeOrigemDestinoCteLote" id="isGerarNfseCidadeOrigemDestinoCteLote" <%=(carregacli && cli.isGerarNfseCidadeOrigemDestinoCteLote() ? "checked" : "")%> />
                                                        Ao incluir conhecimentos em lote, gerar  
                                                        <select id="tipo-geracao-nfse-cidade-origem-destino-cte-lote" name="tipo-geracao-nfse-cidade-origem-destino-cte-lote" class="inputtexto" onchange="isExibirSerieMinuta(this)">
                                                            <option value="1">NFS-e</option>
                                                            <option value="2">Minuta</option>
                                                        </select>
                                                        para lançamentos com a mesma cidade de origem e destino.<br/>
                                                        <div id="div-serie-minuta">
                                                            <label>Utilizar a série:</label>
                                                            <input type="text" class="inputtexto" size="4" maxlength="3" id="serie-minuta" name="serie-minuta">
                                                        </div>
                                                    </td>
                                                    <td class="CelulaZebra2" colspan="1">
                                                        <label>
                                                            <div>
                                                                <input name="travaCamposImportacao" type="checkbox" id="travaCamposImportacao" <%=(carregacli && cli.isTravaCamposImportacao()? "checked" : "")%> />
                                                                Ao importar NF-e (XML, Chave de acesso ou EDI),os campos destinatário, número da NF-e, peso, valor da NF-e e QTD   de volumes não poderão ser alterados.
                                                            </div>
                                                        </label>
                                                    </td>
                                                 </tr> 
                                             </tr>
                                            <tr>
                                                <td class="CelulaZebra2" colspan="2"></td>
                                                <td class="CelulaZebra2">
                                                    <label>
                                                        <input name="baixarXmlCliente" type="checkbox" id="baixarXmlCliente" value="true" <%=(carregacli && cli.isBaixarXmlCliente()? "checked" : "")%> />Baixar XML's deste cliente diretamente da SEFAZ.
                                                    </label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos">Código integração CF-e:</td>
                                                <td class="CelulaZebra2">
                                                    <input name="codigoIntegracaoCfe" class="inputtexto" type="text" id="codigoIntegracaoCfe" value="<%=(cli != null ? (cli.getCodigoIntegracaoCfe()) : "")%>" size="20" maxlength="20">
                                                </td>
                                                <td class="CelulaZebra2" colspan="2">
                                                 <label>
                                                        <div>
                                                            <input onclick="exibiQtdMaximaElayoutImpressao()" name="chkGerarNumeroEtiquetaIncluirNota" type="checkbox" id="chkGerarNumeroEtiquetaIncluirNota" value="checkbox" <%=(carregacli && cli.isGerarNumeroEtiquetaIncluirNota()? "checked" : "")%> <%=(nivelOperacional >= 2 ? "" : "disabled")%>>
                                                            Gerar número de etiqueta ao incluir uma nota desse cliente.
                                                        </div>        
                                                    </label>
                                                </td>
                                             </tr>
                                             <tr>
                                                <td colspan="3">
                                                    <div id="qtdMaximaElayoutImpressao">
                                                        <table width="100%" id="tabelaEtiquetaCliente" style="margin: 0px;">
                                                            <tr>
                                                                <td class="textoCampos">
                                                                    <div align="left">
                                                                        <input type="checkbox" id="chkImportarNotfisPrevalecerEtiqueta" name="chkImportarNotfisPrevalecerEtiqueta" ${carregacli ? (cli.importarNotfisPrevalecerEtiqueta ? "checked" : "") : ""}>
                                                                        <label for="chkImportarNotfisPrevalecerEtiqueta">Ao importar NOTFIS deverá prevalecer a etiqueta do arquivo importado.</label>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="textoCampos">
                                                                    Qtd Máxima de impressões:
                                                                    <input class="inputtexto" type="text" onChange="seNaoIntReset(this, '0')"  value="<%=(cli.getEtiquetaImprimirMaximo() != 0 ? (cli.getEtiquetaImprimirMaximo()) : "")%>" id="etiquetaImprimirMaximo" name="etiquetaImprimirMaximo">
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="textoCampos">
                                                                    Layout de Impressão do cód barras da etiqueta:
                                                                    <input class="inputtexto" type="text" value="<%=(!Objects.equals(cli.getEtiquetaLayoutImpressao(), "") ? (cli.getEtiquetaLayoutImpressao()) : "Padrão")%>" id="etiquetaLayoutImpressao" name="etiquetaLayoutImpressao" size="15" readonly>
                                                                    <input type="button" class="inputbotao" id="localizaLayoutEtiqueta" value="..." onClick="exibirEtiquetaLayoutImpressao($('etiquetaLayoutImpressao'));">
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </td>
                                            </tr>
                                             <tr>
                                                <td class="TextoCampos">Negociação do Adiantamento do Contrato de Frete: </td><td class="TextoCampos"><div align="left">
                                                        <select id="negociacaoAdiantamentoSlc" name="negociacaoAdiantamentoSlc" class="inputtexto" onchange="mostrarDOMNegociacao()">
                                                            <option value="0" selected="">Não Informado</option>
                                                        </select></div></td>
                                                <td class="textoCampos">
                                                    <div align="left">
                                                        <input type="checkbox" id="aceitaLucratividadeNegativa" name="aceitaLucratividadeNegativa" ${carregacli ? (cli.aceitaLucratividadeNegativa ? "checked" : "") : ""}>
                                                        <label for="aceitaLucratividadeNegativa">Aceitar lucratividade negativa de</label>
                                                        <input type="text" class="inputtexto"  size="3" id="percentualAceito" name="percentualAceito" onChange="seNaoFloatReset(this, '0.00')" value="<%=(cli != null ? Apoio.to_curr(cli.getPercentualAceito()) : "")%>">
                                                        <label for="percentualAceito">% ao incluir um CT-e/Contrato de frete.</label>
                                                    </div>
                                                </td>
                                             </tr>
                                             <tr><td colspan="6"> <table class="bordaFina" width="100%" id="tabelaNegociacao" name="tabelaNegociacao"><tr><td colspan="6" class="tabela" align="center">Exceções da Negociação</td></tr><tr><td colspan="6" class="CelulaZebra2">
                                                                 <img src="img/add.gif" class="imagemLink" title="Adicionar Exceção de Negociaçao" onclick="tryRequestToServer(function(){montarDomNegociacaoAdtMotorista();});"><input type="hidden" id="maxExcecoes" name="maxExcecoes" value="0"></td></tr></table></td></tr></table>
                                        <table class="bordaFina" width="100%" >
                                            <tbody id="tbCampoDiarias">
                                                <tr class="celula">
                                                    <td width="2%"></td>
                                                    <td  width="16%"><div align="center">Tipo de Veiculo</div></td>
                                                    <td  width="17%"><div align="center">Tipos de produtos</div></td>
                                                    <td width="11%"><div align="center">Valor diária</div></td>
                                                    <td width="54%"><div align="left">Cidade</div></td>
                                        </tr></tbody></table></td></tr></table>
                        </fieldset>
                    </div>
                    <div  id="tab6">
                        <fieldset id="tbIntegra">
                            <table width="100%" border="0" class="bordaFina">
                                <tr class="tabela">
                                    <td colspan="2" align="center">Integra&ccedil;&atilde;o Fiscal</td>
                                    <td colspan="2" align="center">Integra&ccedil;&atilde;o Cont&aacute;bil</td>
                                </tr>
                                <tr>
                                    <td width="15%" class="TextoCampos">C&oacute;digo CNAE:</td>
                                    <td width="35%" class="CelulaZebra2">
                                        <input name="cod_cnae" type="text" id="cod_cnae" size="10" readonly class="inputReadOnly" value="<%=(cli != null && cli.getCnae().getCod_cnae() != null ? cli.getCnae().getCod_cnae() : "")%> " >
                                        <input name="localiza_cnae" type="button" class="inputbotao" id="localiza_cnae" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CNAE%>', 'Cnae')" >
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="getObj('cod_cnae').value='';getObj('cnae_id').value=0;" > </strong>
                                    </td>
                                    <td width="15%" class="TextoCampos">Conta Cont&aacute;bil:</td>
                                    <td width="35%" class="CelulaZebra2">
                                        <input name="cod_conta" type="text" id="cod_conta" size="10" class="inputTexto" value="<%=(cli != null ? cli.getPlanoConta().getCodigo() : "")%>" onkeypress="if (event.keyCode==13) localizarContaContabil(this.value);">
                                        <input type="text" class="inputReadOnly" id="plano_conta_descricao" name="plano_conta_descricao" size="25" value="<%=(cli != null ? cli.getPlanoConta().getDescricao():"")  %>" />
                                        <input name="localiza_conta" type="button" class="inputbotao" id="localiza_conta" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.PLANO_CONTAS%>', 'Plano_de_contas')" >
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="$('cod_conta').value='';$('plano_contas_id').value=0;$('plano_conta_descricao').value=''" ></strong>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">Código no Sistema Fiscal:</td>
                                    <td class="CelulaZebra2">
                                        <input name="cod_fiscal" type="text" id="cod_fiscal" size="25" maxlength="18" class="inputtexto" value="<%=(cli != null ? cli.getCodIntegracaoFiscal() : "")%>" >
                                    </td>
                                    <td class="TextoCampos"></td>
                                    <td class="CelulaZebra2"></td>
                                </tr>

                            </table>
                        </fieldset>
                    </div>
                    <div id="tab7" style="display: <%= (Apoio.getUsuario(request).getAcesso("cadtabelacliente")>= NivelAcessoUsuario.LER.getNivel() ? "" : "none") %> ">
                    <table width="100%" border="0" class="bordaFina">
                        <tr>
                            <td>
                                <table width="100%" border="0">
                                    <tr>
                                        <td class="TextoCampos" colspan="2">
                                            <div align="center">
                                                <input name="utilizartipofretetabela" type="checkbox" onclick="alterarDefaultTipoFrete()" id="utilizartipofretetabela" value="checkbox" <%=(carregacli && cli.isUtilizarTipoFreteTabela()? "checked" : "")%>>
                                                Utilizar Tipo de Frete da Tabela de Preço
                                            </div>
                                        </td>
                                        <td width="15%" class="TextoCampos">Tipo tabela:</td>
                                        <td width="15%" class="CelulaZebra2">
                                            <select name="tipotabela" id="tipotabela" class="fieldMin" <%=(nivelUserTabela >= 2 ? "" : "disabled")%>>
                                                <option value="-1">-- Selecione --</option><option value="0">Peso/Kg</option><option value="1">Peso/Cubagem</option><option value="2">% Nota Fiscal</option>
                                                <option value="3">Combinado</option><option value="4">Por volume</option><option value="5">Por Km</option><option value="6">Por Pallet</option>
                                            </select></td>
                                    </tr><tr>
                                        <td width="20%" class="TextoCampos">Considerar como origem do frete no CT-e:</td>
                                        <td width="10%" class="CelulaZebra2">
                                            <select name="tipoOrigemFrete" id="tipoOrigemFrete" class="fieldMin" <%=(nivelOperacional >= 2 ? "" : "disabled")%>>
                                                <option value="r" <%=(cli != null && cfg.getOrigemFrete().equals("r") ? "selected" : "")%> >A cidade do remetente</option>
                                                <option value="f" <%=(cli != null && cfg.getOrigemFrete().equals("f") ? "selected" : "")%>>A cidade da filial</option>
                                            </select>
                                        </td>
                                        <td width="40%" class="TextoCampos" colspan="2">
                                            <div align="center">
                                                <input name="chkIncluiContainer" type="checkbox" id="chkIncluiContainer" value="checkbox" <%=(carregacli && cli.isIncluiContainerFretePeso() ? "checked" : "")%>>
                                                Incluir peso do container no c&aacute;lculo do frete.
                                            </div></td></tr><tr>
                                        <td colspan="5">
                                            <table width="100%" id="tbAdiantMestre" name="tbAdiantMestre" border="0">
                                                <input type="hidden" name="maxTipoProduto" id="maxTipoProduto" value="0">
                                                <input type="hidden" name="maxContato" id="maxContato" value="0">
                                                <input type="hidden" name="tipo_produto_id" id="tipo_produto_id" value="0">
                                                <input type="hidden" name="tipo_produto" id="tipo_produto" value="">
                                                <tbody id="tbTipoProduto" name="tbTipoProduto">
                                                    <tr id="trTitulo" name="trTitulo" class="CelulaZebra2">
                                                        <td width="47%" class="CelulaZebra2">
                                                            <input name="chkTipoProduto" type="checkbox" id="chkTipoProduto" value="checkbox" <%=(carregacli && cli.isTabelaTipoProduto() ? "checked" : "")%>>
                                                            Sempre utilizar tabela de pre&ccedil;o por tipo de produto.
                                                        </td>
                                                        <td width="3%" class="CelulaZebra2" >
                                                            <img src="img/add.gif" border="0" title="Adicionar um novo tipo de produto" class="imagemLink"
                                                                 onClick="window.open('./localiza?acao=consultar&idlista=37','Tipo_de_produto','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');"
                                                                 style="display:<%=(nivelOperacional >= 2 ? "" : "none")%>;">
                                                        </td>
                                                        <td width="27%" class="CelulaZebra2" >Adicionar tipos de produto.</td>
                                                        <td width="23%" class="CelulaZebra2" >
                                                            <div align="center"></div>
                                                        </td></tr></tbody></table></td></tr><tr>
                                        <td class="CelulaZebra2" colspan="2">
                                            Utilizar a tabela do remetente:                                         
                                            <select name="tipoTabelaRemetente" id="tipoTabelaRemetente" class="fieldMin" onChange="javascript:alteraTabelaRemetente();" <%=(nivelOperacional >= 2 ? "" : "disabled")%>>
                                                <option value="n" selected>Nunca</option>
                                                <option value="s">Sempre</option>
                                                <option value="q">Apenas para o(s) remetente(s) abaixo</option>
                                            </select>
                                            <img src="img/add.gif" border="0" id="imgTabelaRemetente" name="imgTabelaRemetente" title="Adicionar um novo remetente" class="imagemLink" onClick="window.open('./localiza?acao=consultar&idlista=3','Remetente','top=80,left=100,height=400,width=700,resizable=yes,status=1,scrollbars=1');" style='display:none;'>
                                        </td>
                                        <td class="CelulaZebra2" colspan="2">
                                            <input type="checkbox" id="isfreteDirigido" name="isfreteDirigido" onclick="(this.checked ? this.value = true : this.value = false)" <%= (carregacli && cli.isFreteDirigido() ? "checked" : "" ) %>> Utilizar a tabela desse cliente quando o mesmo for o remetente do CT-e e o frete for FOB (Frete Dirigido)
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="CelulaZebra2" colspan="4">
                                            <div align="left">
                                                <label><b>Forma de arredondamento do peso no cálculo da tabela de preço : </b></label>
                                                <span><input type="radio" class="radio" id="tipoArredondamentoPeso" name="tipoArredondamentoPeso" value="n" <%=(carregacli ? (!cli.getTipoArredondamentoPeso().equalsIgnoreCase("a") && !cli.getTipoArredondamentoPeso().equalsIgnoreCase("c")? "checked" : "" ): ( !cfg.getTipoArredondamentoPeso().equalsIgnoreCase("a") || !cfg.getTipoArredondamentoPeso().equalsIgnoreCase("c") ? "checked" : ""))%>></span><label>  Não Arredondar </label>
                                                <span><input type="radio" class="radio" id="tipoArredondamentoPeso" name="tipoArredondamentoPeso" value="a" <%=(carregacli ?(cli.getTipoArredondamentoPeso().equalsIgnoreCase("a") ? "checked" : "" ): ( cfg.getTipoArredondamentoPeso().equalsIgnoreCase("a") ? "checked" : ""))%>></span><label>  Arredondamento padrão </label>
                                                <span><input type="radio" class="radio" id="tipoArredondamentoPeso" name="tipoArredondamentoPeso" value="c" <%=(carregacli ? (cli.getTipoArredondamentoPeso().equalsIgnoreCase("c") ? "checked" : "" ): ( cfg.getTipoArredondamentoPeso().equalsIgnoreCase("c") ? "checked" : ""))%>></span><label>  Sempre arredondar para cima </label>
                                            </div></td></tr>
                                    <tr>
                                        <td class="textoCampos" colspan="">
                                                <label>Se não existir tabela de preço para o trecho do CT-e, utilizar a tabela do cliente : </label>
                                        </td>
                                        <td class="CelulaZebra2" colspan="">
                                            <input type="hidden" id="idtransportador" name="idtransportador" value="<%=(cli != null ? cli.getUtilizarTabelaCliente().getIdcliente():"")  %>" />
                                            <input type="text" class="inputReadOnly" id="transp_rzs" name="transp_rzs" size="25" value="<%=(cli != null ? cli.getUtilizarTabelaCliente().getRazaosocial():"")  %>" readonly="true" />
                                            <input name="localiza_cliente" type="button" class="inputbotao" id="localiza_cliente" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%= BeanLocaliza.TRANSPORTADORA %>', 'utilizar_tabelas_cliente')" >
                                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="$('transp_rzs').value='';$('idtransportador').value=0;" ></strong>
                                        </td>
                                        <td class="textoCampos" colspan="">
                                                <label>Utilizar Tabela Adicional de TDE : </label>
                                        </td>
                                        <td class="CelulaZebra2" colspan="">
                                            <select id="tabelaTDE" name="tabelaTDE" class="fieldMin">
                                                <option value="0" <%= (cli != null ? (cli.getTabelaTDE().getId() == 0 ? "selected" : "") : "") %>>Nenhum</option>
                                                <% for(TabelaAdicionalTDE tde: listaTDE){ %>
                                                    <option value="<%= tde.getId() %>" <%= (cli != null ? (cli.getTabelaTDE().getId() == tde.getId() ? "selected" : "") : "") %> ><%= tde.getDescricao() %></option>
                                                <% } %>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr id="trTabelaRemetente" name="trTabelaRemetente" style="display:none;">
                                        <td colspan="3">
                                            <table width="100%" border="0" cellspacing="1" cellpadding="2">
                                                <input type="hidden" name="maxTabelaRemetente" id="maxTabelaRemetente" value="0">
                                                <input type="hidden" name="idremetente" id="idremetente" value="0">
                                                <input type="hidden" name="rem_rzs" id="rem_rzs" value="">
                                                <input type="hidden" name="rem_cnpj" id="rem_cnpj" value="">
                                                <input type="hidden" name="rem_cidade" id="rem_cidade" value="">
                                                <input type="hidden" name="rem_uf" id="rem_uf" value="">
                                                <tbody id="tbTabelaRemetente" name="tbTabelaRemetente">
                                                </tbody>
                                            </table></td></tr></table></td></tr>
                    </table>
                    <input name="cadcliente" type="button" class="inputbotao" id="cadcliente"  onClick="tryRequestToServer(function(){cadtabcliente()});" value="Incluir uma nova tabela de preço">
                        <table width="100%" border="0" class="bordaFina">
                            <tr class="tabela">
                            <td>Cod.</td><td>Data vigência</td><td>Origem</td><td>Destino</td><td>Tipo produto</td><td>Frete/Kg</td><td>Frete Valor</td><td>Outros</td><td>Taxa fixa</td><td>% NF</td><td>Mínimo. </td><td>Contrato Comercial </td>
                            <td> </td>
                         </tr>
                         <%int contador = 0;%>
                         <%for (BeanTabelaCliente tc : cli.getTabelasPreco()) {%>
                         <%boolean isAtivo = tc.isDesativada();%>
                         <tr>
                          <td class="CelulaZebra2">
                              <div class="linkEditar" onClick="tryRequestToServer(function(){verTabela(<%=tc.getId()%>)})"><%=tc.getId()%></div>
                          </td>
                         <td class="CelulaZebra2">
                             <font color="<%= tc.isDesativada() ? "red" : ""%>"><%= (tc.getDataVigencia() == null ? "" : fmt.format(tc.getDataVigencia())) %></font>
                         </td>
                         <td class="CelulaZebra2" >
                             <font color="<%= tc.isDesativada() ? "red" : ""%>">
                                <%=((tc.getTipoRota().equals("a") ? tc.getAreaOrigem().getDescricao() : (tc.getTipoRota().equals("c") ? tc.getCidadeOrigem().getCidade() :"")))%>
                             </font>
                         </td>
                         <td class="CelulaZebra2" >
                             <font color="<%= tc.isDesativada() ? "red" : ""%>">
                                <%=((tc.getTipoRota().equals("a") ? tc.getAreaDestino().getDescricao() : (tc.getTipoRota().equals("c") ? tc.getCidadeDestino().getCidade() : "" )))%>
                            </font>
                         </td>
                         <td class="CelulaZebra2"> <font color="<%= tc.isDesativada() ? "red" : ""%>"><%=tc.getTipoProduto().getDescricao()%></font></td>
                         <td class="CelulaZebra2"> <font color="<%= tc.isDesativada() ? "red" : ""%>"><%= tc.getValorPeso() %></font></td>
                         <td class="CelulaZebra2"> <font color="<%= tc.isDesativada() ? "red" : ""%>"><%= tc.getPercentualAdValorEm()%></font></td>
                         <td class="CelulaZebra2"> <font color="<%= tc.isDesativada() ? "red" : ""%>"><%= tc.getValorOutros() %></font></td>
                         <td class="CelulaZebra2"> <font color="<%= tc.isDesativada() ? "red" : ""%>"><%= tc.getValorTaxaFixa() %></font></td>
                         <td class="CelulaZebra2"> <font color="<%= tc.isDesativada() ? "red" : ""%>"> <%= tc.getPercentualNf() %></font></td>
                         <td class="CelulaZebra2"> <font color="<%= tc.isDesativada() ? "red" : ""%>"><%= tc.getValorFreteMinimo() %></font></td>
                         <td class="CelulaZebra2">
                            <font color="<%= tc.isDesativada() ? "red" : ""%>">
                                <%for (ContratoComercial contrato : tc.getContratos()) {
                                    if(contrato.getNumero().length() == 6) {%>
                                    <input type="hidden" value="<%= contrato.getId()%>" class="idContrato_<%=tc.getId()%>">
                                    <div class="linkEditar" onclick="tryRequestToServer(function(){verContrato(<%= contrato.getId()%>)})">
                                        <%= contrato.getNumero() %>;
                                    </div>
                                <%}}%>
                            </font>
                         </td>
                         <td class="CelulaZebra2" style="text-align: center;">
                             <img src="img/pdf.jpg" width="19" height="19" border="0" id="img_imprimir" class="imagemLink" title="Imprimir contratos dessa tabela" align="center"
                             onClick="tryRequestToServer(function() {imprimiContratos(<%=tc.getId()%>)});">
                         </td>
                         </tr>
                         <%contador++;%>
                         <%}%>
                       </table>
                     </div>
                     <div  id="tab8">
                        <fieldset id="tbIntegra">
                            <table width="100%" border="0" class="bordaFina">
                                <tr class="tabela"><td colspan="2" align="center">Informa&ccedil;&otilde;es EDI/Entrega</td></tr>
                                <tr class ="celulaZebra2">
                                    <td align="center">
                                        <input type="checkbox" name="chkOcorrenciasCliente" id="chkOcorrenciasCliente" value="checkbox" onclick="ativaOcorrencia();"<%=(carregacli && cli.isOcorrenciasClientes() ? "checked" : "")%>>
                                        Utilizar ocorr&ecirc;ncias especificas para esse cliente
                                    </td>
                                    <td align="center">Código da Transportadora no EDI: <input type="text" id="codTransportadoraPrefat" name="codTransportadoraPrefat" class="fieldMin" style="width: 130px;" maxlength="20" value='<%=(carregacli ? cli.getCodTransportadoraPrefat(): "")%>' ></td></tr><tr>
                                    <td colspan="2" class="celulaZebra2">
                                        <table width="100%">
                                            <td width="33%" style="vertical-align:top;">
                                                <table width="100%" name="tabelaOcorrencia" id="tabelaOcorrencia" class="bordaFina tabelaZerada">
                                                    <tr>
                                                        <td class="celula"  width="4%" >
                                                            <input id="maxLayEDI_c" name="maxLayEDI_c" value="0" type="hidden" />
                                                            <img src="img/add.gif" border="0" title="Adicionar Ocorrencias" class="imagemLink" style="vertical-align:middle;" onClick="addOcorrenciaEdi();">
                                                        </td>
                                                        <td class="CelulaZebra1NoAlign" width="30%"><b>Ocorr&ecirc;ncias</b></td>
                                                        <td class="CelulaZebra1NoAlign" width="66%"><b>C&oacute;digo Espec&iacute;fico EDI</b></td>
                                                    </tr>
                                                    <tbody id="tb_ocorrencia" name="tb_ocorrencia"></tbody>
                                                </table></td></table></td></tr><tr>
                                <td width="100%" colspan="2" class="celulaZebra2">
                                    <table width="76%" >
                                        <tr><td width="33%" style="vertical-align:top;">
                                                <table width="100%" class="bordaFina tabelaZerada">
                                                    <tr><td class="celula"  width="5%" align="center">
                                                            <input id="maxOcorrAuto" name="maxOcorrAuto" value="0" type="hidden" />
                                                            <img src="img/add.gif" border="0" title="Adicionar Ocorrência automática" class="imagemLink" style="vertical-align:middle;" onClick="abrirLocalizarOcorrenciaAutomatica();">
                                                        </td>
                                                        <td class="celula" colspan="4" width="95%">Ocorrências automáticas</td>
                                                    </tr>
                                                    <tr class="tabela">
                                                        <td align="center"></td>
                                                        <td align="center" width="70%">Ocorrência</td>
                                                        <td align="center">Texto Padrão</td>
                                                        <td align="center">Regra</td>
                                                        <td align="center">Tipo de CT-e</td>
                                                    </tr>
                                                    <tbody id="tbOcorrAuto"></tbody>
                                                </table></td></tr></table></td></tr><tr>
                                <td width="100%" colspan="2" class="celulaZebra2">
                                    <table width="100%" >
                                        <tr><td width="33%" style="vertical-align:top;">
                                                <table width="100%" class="bordaFina tabelaZerada">
                                                    <tr><td class="celula"  width="10%" >
                                                            <input id="maxLayEDI_c" name="maxLayEDI_c" value="0" type="hidden" />
                                                            <img src="img/add.gif" border="0" title="Adicionar Layout EDI CONEMB" class="imagemLink" style="vertical-align:middle;" onClick="addClienteLayoutEDI('c');">
                                                        </td>
                                                        <td class="celula" colspan="3" width="90%">Layouts EDI CONEMB</td>
                                                    </tr>
                                                    <tbody id="tb_c"></tbody>
                                                </table>
                                            </td>
                                            <td width="33%" style="vertical-align:top;">
                                                <table width="100%" class="bordaFina tabelaZerada">
                                                    <tr>
                                                        <td class="celula" width="10%">
                                                            <input id="maxLayEDI_f" name="maxLayEDI_f" value="0" type="hidden" />
                                                            <img src="img/add.gif" border="0" title="Adicionar Layout EDI DOCCOB" class="imagemLink" style="vertical-align:middle;" onClick="addClienteLayoutEDI('f')">
                                                        </td>
                                                        <td class="celula"  colspan="3"width="90%">Layouts EDI DOCCOB</td>
                                                    </tr>
                                                    <tbody id="tb_f"></tbody>
                                                </table></td>
                                            <td width="33%" style="vertical-align:top;">
                                                <table width="100%" class="bordaFina tabelaZerada">
                                                    <tr><td class="celula" width="10%">
                                                            <input id="maxLayEDI_o" name="maxLayEDI_o" value="0" type="hidden" />
                                                            <img src="img/add.gif" border="0" title="Adicionar Layout EDI OCOREN" class="imagemLink" style="vertical-align:middle;" onClick="addClienteLayoutEDI('o')">
                                                        </td><td class="celula" colspan="3" width="90%">Layouts EDI OCOREN</td>
                                                    </tr><tbody id="tb_o"></tbody></table></td></tr></table></td></tr></table></fieldset>
                        <table width="100%" border="0" class="bordaFina" style='display: <%= carregacli && nivelUser == 4 ? "" : "none" %>'>
                            <tr class="CelulaZebra1">
                                <td width="2%" align="center">
                                    <img src="img/add.gif" border="0" title="Adicionar Importação lote" class="imagemLink" style="vertical-align:middle;" onclick="addImportacaoLote(listaNotfisAutomaticas, importacaoLote);" />
                                </td>
                                <td width="98%" align="center" ><b>Importação em Lote (NOTFIS)</b></td>
                            </tr>
                        </table>
                        <table width="100%" border="0" class="bordaFina">
                            <input type="hidden" id="maxLayEDI_n" name="maxLayEDI_n" value="0"/>
                            <tbody id="tbImportacaoLote"></tbody>
                        </table>
                     </div>
                </div>
                <div id="divAuditoria" >
                    <table width="90%" align="center" cellpadding="2" cellspacing="1" class="bordaFina" id="tableAuditoria">
                        <tbody id="tbAuditoriaCabecalho">
                            <tr><td colspan="6"  class="tabela"><div align="center">Auditoria</div></td></tr>
                            <tr class="celulaNoAlign">
                                <td colspan="3"  align="left">
                                    <label>Data da Ação:</label>&ApplyFunction;
                                    <input type="text" class="fieldDate" id="dataDeAuditoria" maxlength="10" size="10" value="<%=Apoio.getDataAtual()%>" />
                                    <label> Até  </label>
                                    <input type="text" class="fieldDate" id="dataAteAuditoria" maxlength="10" size="10" value="<%=Apoio.getDataAtual()%>" />
                                </td>
                                <td colspan=""  >
                                    <input type="button" class="inputbotao" id="btPesquisarAuditoria" value=" Pesquisar " onclick="pesquisarAuditoria();" >
                                </td>
                                <td colspan="2"  ></td>
                            </tr>
                            <tr class="celula">
                                <td width="3%"></td><td width="17%">Usuário</td><td width="15%">Data</td><td width="15%">Ação</td><td width="10%">IP</td><td width="50%"></td>
                            </tr>
                        </tbody>
                        <tbody id="tbAuditoriaConteudo"></tbody>                        
                    </table>
                    <table width="90%" align="center" cellpadding="2" cellspacing="1" class="bordaFina" id="tableAuditoria">
                        <tr class="CelulaZebra2">
                            <td width="17%" class="TextoCampos">Incluso:</td>
                            <td width="33%" >Em: <%=cli != null && cli.getDtlancamento() != null ? fmt.format(cli.getDtlancamento()) : ""%> <br>
                                Por: <%=cli != null && cli.getDtlancamento() != null ? cli.getIdusuariolancamento().getNome() : ""%>
                            <td width="13%" class="TextoCampos">Alterado:
                            <td width="37%" >Em: <%=(cli != null && cli.getDtalteracao() != null) ? fmt.format(cli.getDtalteracao()) : ""%><br>
                                Por: <%=(cli != null && cli.getIdusuarioalteracao().getNome() != null) ? cli.getIdusuarioalteracao().getNome() : ""%>
                        </tr></table></div>
                <div id="tab9">
                    <table width="90%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                        <tr>
                            <td class="TextoCampos">Ao consultar entregas no módulo do cliente considerar os campos:</td>
                            <td class="CelulaZebra2" colspan="2">
                                <label><input type="checkbox" id="chkConsignatario" name="chkConsignatario" value="checkbox" <%=(carregacli ? (cli.isConsignatario() ? "checked" : "") : "checked")%>/>Consignatário (Tomador de serviço)</label>
                                <label><input type="checkbox" id="chkRemetente" name="chkRemetente" value="checkbox" <%=(carregacli && cli.isRemetente() ? "checked" : "")%> />Remetente</label>
                                <label><input type="checkbox" id="chkDestinatario" name="chkDestinatario" value="checkbox" <%=(carregacli && cli.isDestinatario() ? "checked" : "")%> />Destinatário</label>
                                <label><input type="checkbox" id="chkRedespacho" name="chkRedespacho" value="checkbox" <%=(carregacli && cli.isRedespacho() ? "checked" : "")%> />Redespacho</label>
                                <label><input type="checkbox" id="chkRecebedor" name="chkRecebedor" value="checkbox" <%=(carregacli && cli.isRecebedor() ? "checked" : "")%> />Recebedor</label>
                                <label><input type="checkbox" id="chkExpedidor" name="chkExpedidor" value="checkbox" <%=(carregacli && cli.isExpedidor() ? "checked" : "")%> />Expedidor</label>
                            </td></tr>
                        <tr>
                            <td class="TextoCampos">Ao consultar entregas deverá mostrar apenas CT-e(s):</td>
                            <td class="CelulaZebra2" colspan="2">
                                <label><input type="checkbox" id="chkCTnormal" name="chkCTnormal" value="checkbox" ${carregacli ? cli.isVisivelCteNormal ? "checked" : "" : "checked"}/>Normal</label>
                                <label><input type="checkbox" id="chkCTlocal" name="chkCTlocal" value="checkbox" ${carregacli ? cli.isVisivelCteLocal ? "checked" : "" : "checked"}/>Entrega Local(Cobrança)</label>
                                <label><input type="checkbox" id="chkCTdiarias" name="chkCTdiarias" value="checkbox" ${carregacli ? cli.isVisivelCteDiarias ? "checked" : "" : "checked"}/>Diárias</label>
                                <label><input type="checkbox" id="chkCTpallets" name="chkCTpallets" value="checkbox" ${carregacli ? cli.isVisivelCtePallets ? "checked" : "" : "checked"}/>Pallets</label>
                                <label><input type="checkbox" id="chkCTcomplementar" name="chkCTcomplementar" value="checkbox" ${carregacli ? cli.isVisivelCteComplementar ? "checked" : "" : "checked"}/>Complementar</label>
                                <label><input type="checkbox" id="chkCTreentrega" name="chkCTreentrega" value="checkbox" ${carregacli ? cli.isVisivelCteReentrega ? "checked" : "" : "checked"}/>Reentrega</label>
                                <label><input type="checkbox" id="chkCTdevolucao" name="chkCTdevolucao" value="checkbox" ${carregacli ? cli.isVisivelCteDevolucao ? "checked" : "" : "checked"}/>Devolução</label>
                                <label><input type="checkbox" id="chkCTcortesia" name="chkCTcortesia" value="checkbox" ${carregacli ? cli.isVisivelCteCortesia ? "checked" : "" : "checked"}/>Cortesia</label>
                                <label><input type="checkbox" id="chkCTsubstituicao" name="chkCTsubstituicao" value="checkbox" ${carregacli ? cli.isVisivelCteSubstituicao ? "checked" : "" : "checked"}/>Substituição</label>
                                <label><input type="checkbox" id="chkCTanulacao" name="chkCTanulacao" value="checkbox" ${carregacli ? cli.isVisivelCteAnulacao ? "checked" : "" : "checked"}/>Anulação</label>
                                <label><input type="checkbox" id="chkCTsubstituto" name="chkCTsubstituto" value="checkbox" ${carregacli ? cli.isVisivelCteSubstituto ? "checked" : "" : "checked"}/>Substituto</label>
                            </td></tr>
                        <tr>
                            <td class="TextoCampos">Ao consultar entregas deverá ocultar os campos:</td>
                            <td class="CelulaZebra2" colspan="2">
                                <label>
                                    <input type="checkbox" id="chkRastreamentoOcultarDataEmbarque" name="chkRastreamentoOcultarDataEmbarque" ${carregacli ? (cli.ocultoDataEmbarque ? "checked" : "") : "checked"}/>Data de Embarque
                                </label>
                                <label>
                                    <input type="checkbox" id="chkRastreamentoOcultarPrevisaoChegada" name="chkRastreamentoOcultarPrevisaoChegada" ${carregacli ? (cli.ocultoPrevisaoChegada ? "checked" : "") : "checked"}/>Previsão de Chegada
                                </label>
                                <label>
                                    <input type="checkbox" id="chkRastreamentoOcultarDataChegada" name="chkRastreamentoOcultarDataChegada" ${carregacli ? (cli.ocultoDataChegada ? "checked" : "") : "checked"}/>Data de Chegada
                                </label>
                                <label>
                                    <input type="checkbox" id="chkRastreamentoOcultarPrevisaoEntrega" name="chkRastreamentoOcultarPrevisaoEntrega" ${carregacli ? (cli.ocultoPrevisaoEntrega ? "checked" : "") : "checked"}/>Previsão de Entrega
                                </label>
                                <label>
                                    <input type="checkbox" id="chkRastreamentoOcultarObservacao" name="chkRastreamentoOcultarObservacao" ${carregacli ? (cli.isOcultarObservacao ? "checked" : "") : ""}/>Observação da Ocorrência
                                </label>
                            </td></tr>
                        <tr>
                            <td class="CelulaZebra2" colspan="3">
                                <div align="center">
                                    <input type="checkbox" id="chkStatusAtualCargaUltimaOcorrenciaLancada" name="chkStatusAtualCargaUltimaOcorrenciaLancada" ${carregacli ? (cli.statusAtualCargaUltimaOcorrenciaLancada ? "checked" : "") : ""}>
                                    O Status atual da carga deverá ser a descrição da última ocorrência lançada
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td class="CelulaZebra2" colspan="3">
                                <div align="center">
                                    <input type="checkbox" id="chkConsultarEntregasTodasDaRaizCNPJ" name="chkConsultarEntregasTodasDaRaizCNPJ" ${carregacli ? (cli.consultarEntregasRaizCNPJ ? "checked" : "") : ""}>
                                    Ao consultar entregas deverá mostrar todas as entregas da raiz do CNPJ
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td class="CelulaZebra2" colspan="3">
                                <div align="center">
                                    <input type="checkbox" id="chkEnviarPushOcorrencias" name="chkEnviarPushOcorrencias" ${carregacli ? (cli.enviarPushOcorrencias ? "checked" : "") : ""}>
                                    <label for="chkEnviarPushOcorrencias">Enviar notificações PUSH para ocorrências desse cliente</label>
                                </div>
                            </td>
                        </tr>
                    </table></div></form><br>
                 <table width="90%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                    <tr class="CelulaZebra2">
                        <td colspan="4">
                    <center>
                        <% if (nivelUser >= 2) {%>
                        <input name="gravar" type="button" class="inputbotao" id="gravar" value="   Salvar   " onClick="tryRequestToServer(function(){salva();});">
                        <%}%>
                    </center></td></tr>
                </table>
            <!--NÃO REMOVA MAIS O FORM ABAIXO POIS ELE É UTILIZADO NA REGRA DE IMAGEM!!-->
            <form id="formularioImg2" name="formularioImg2" method="post" target="pop"></form></div></body></html>
