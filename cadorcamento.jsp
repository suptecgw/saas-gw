<%@page import="cidade.BeanCadCidade"%>
<%@page import="cidade.BeanCidade"%>
<%@page import="br.com.gwsistemas.feriados.Feriado"%>
<%@page import="java.util.Date"%>
<%@page import="com.sagat.bean.produto.Produto"%>
<%@page import="br.com.gwsistemas.conhecimento.ComposicaoFrete"%>
<%@page import="planocusto.BeanPlanoCusto"%>
<%@page import="venda.Tributacao"%>
<%@page import="conhecimento.orcamento.OrcamentoServicos"%>
<%@page import="conhecimento.orcamento.OrcamentoEmbalagem"%>
<%@page import="org.apache.jasper.tagplugins.jstl.core.ForEach"%>
<%@page import="br.com.gwsistemas.embalagem.Embalagem"%>
<%@page import="conhecimento.orcamento.OrcamentoProdutos"%>
<%@page import="fornecedor.TabelaPrecoRedespacho"%>

<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html"
         language="java"
         import="nucleo.*,
         java.sql.ResultSet, 
         mov_banco.conta.BeanConsultaConta,
         conhecimento.orcamento.BeanOrcamento,
         conhecimento.orcamento.Cubagem,
         conhecimento.orcamento.BeanCadOrcamento,
         tipo_veiculos.*,
         java.text.DecimalFormat,
         java.text.SimpleDateFormat,
         java.net.*,
         cliente.BeanCadTabelaCliente,
         filial.BeanFilial,
         org.json.simple.JSONObject,
         cliente.tipoProduto.TipoProduto,
         java.util.ArrayList,
         java.util.Collection,
         java.util.Vector" %>

<script language="javascript" type="text/javascript" src="script/<%=Apoio.noCacheScript("builder.js")%>"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("jquery.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("servicos-util.js")%>" type="text/javascript"></script>
<script language="javascript" src="script/<%=Apoio.noCacheScript("prototype_1_6.js")%>" type=""></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("funcoes_gweb.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/beans/<%=Apoio.noCacheScript("CTRC.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("aliquotaIcmsCtrc.js")%>" type="text/javascript"></script>
<script language="javascript" src="script/<%=Apoio.noCacheScript("tabelaFrete.js")%>" type=""></script>
<script language="javascript" type="text/javascript" src="script/<%= Apoio.noCacheScript("mascaras.js")%>" ></script>
<script language="javascript" type="text/javascript" src="script/beans/<%= Apoio.noCacheScript("ComposicaoFrete.js")%>" ></script>
<script type="text/javascript" src="script/<%=Apoio.noCacheScript("ImpostoServico.js")%>"></script>        
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("shortcut.js")%>"></script>
<script language="javasscript" src="script/<%= Apoio.noCacheScript("LogAcoesAuditoria.js")%>" type="text/javascript"></script>
<link href="estilo.css"  media="screen" rel="Stylesheet" type="text/css" />

<% int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("lanorcamento") : 0);

    if (Apoio.getUsuario(request) == null || nivelUser == 0) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
    }
    
//dados padroes de conhecimento de transporte(preenchidos na configuracao)
int idCfopComercioDentro = 0;
String cfopComercioDentro = "";
int idPlanoCfopComercioDentro = 0;
int idCfopComercioFora = 0;
String cfopComercioFora = "";
int idPlanoCfopComercioFora = 0;
int idCfopIndDentro = 0;
String cfopIndDentro = "";
int idPlanoCfopIndDentro = 0;
int idCfopIndFora = 0;
String cfopIndFora = "";
int idPlanoCfopIndFora = 0;
int idCfopPFDentro = 0;
String cfopPFDentro = "";
int idPlanoCfopPFDentro = 0;
int idCfopPFFora = 0;
String cfopPFFora = "";
int idPlanoCfopPFFora = 0;
int idCfopOutroEstado = 0;
String cfopOutroEstado = "";
int idPlanoCfopOutroEstado = 0;
int idCfopOutroEstadoFora = 0;
String cfopOutroEstadoFora = "";
int idPlanoCfopOutroEstadoFora = 0;
int idCfopTransporteDentro = 0;
String cfopTransporteDentro = "";
int idPlanoCfopTransporteDentro = 0;
int idCfopTransporteFora = 0;
String cfopTransporteFora = "";
int idPlanoCfopTransporteFora = 0;
int idCfopPrestacaoServicoDentro = 0;
String cfopPrestacaoServicoDentro = "";
int idPlanoCfopPrestacaoServicoDentro = 0;
int idCfopPrestacaoServicoFora = 0;
String cfopPrestacaoServicoFora = "";
int idPlanoCfopPrestacaoServicoFora = 0;
int idCfopProdutorRuralDentro = 0;
String cfopProdutorRuralDentro = "";
int idPlanoCfopProdutorRuralDentro = 0;
int idCfopProdutorRuralFora = 0;
String cfopProdutorRuralFora = "";
int idPlanoCfopProdutorRuralFora = 0;
int idCfopExteriorDentro = 0;
String cfopExteriorDentro = "";
int idPlanoCfopExteriorDentro = 0;
int idCfopExteriorFora = 0;
String cfopExteriorFora = "";
int idPlanoCfopExteriorFora = 0;
int idCfopSubContratacaoDentro = 0;
String cfopSubContratacaoDentro = "";
int idPlanoCfopSubContratacaoDentro = 0;
int idCfopSubContratacaoFora = 0;
String cfopSubContratacaoFora = "";
int idPlanoCfopSubContratacaoFora = 0;
    
    

    //Carregando as configuraões independente da ação
    BeanConfiguracao cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    //Carregando as configurações
    cfg.CarregaConfig();
    boolean emiteRodoviario = Apoio.getUsuario(request).isEmiteRodoviario();
    boolean emiteAereo = Apoio.getUsuario(request).isEmiteAereo();
    boolean emiteAquaviario = Apoio.getUsuario(request).isEmiteAquaviario();
    BeanPlanoCusto plcustopadrao = null;
    //Valor padrao para validade da proposta
    int validadeProposta = cfg.getValidadeProposta();
    BeanOrcamento orcamento = new BeanOrcamento();
    BeanCadOrcamento cadorc = null;
    OrcamentoServicos orcserv = new OrcamentoServicos(); 
    ComposicaoFrete comFrete = null;
    
    boolean alteraTipoFrete = (Apoio.getUsuario(request).getAcesso("alteratipofretecte") == 4);
    //Fazer a condição para Aprovar ou não o select Status do orçamento
    int aprovarOrcamento = (Apoio.getUsuario(request).getAcesso("aprovarounaoorcamento"));
    
    //obtendo o cfop padrao alterado na configuracao
  idCfopComercioDentro = cfg.getCfopDefault().getIdcfop();
  cfopComercioDentro = cfg.getCfopDefault().getCfop();
  idPlanoCfopComercioDentro = cfg.getCfopDefault().getPlanoCusto().getIdconta();
  idCfopComercioFora = cfg.getCfopDefault2().getIdcfop();
  cfopComercioFora = cfg.getCfopDefault2().getCfop();
  idPlanoCfopComercioFora = cfg.getCfopDefault2().getPlanoCusto().getIdconta();
  idCfopIndDentro = cfg.getCfopIndustriaDentro().getIdcfop();
  cfopIndDentro = cfg.getCfopIndustriaDentro().getCfop();
  idPlanoCfopIndDentro = cfg.getCfopIndustriaDentro().getPlanoCusto().getIdconta();
  idCfopIndFora = cfg.getCfopIndustriaFora().getIdcfop();
  cfopIndFora = cfg.getCfopIndustriaFora().getCfop();
  idPlanoCfopIndFora = cfg.getCfopIndustriaFora().getPlanoCusto().getIdconta();
  idCfopPFDentro = cfg.getCfopPessoaFisicaDentro().getIdcfop();
  cfopPFDentro = cfg.getCfopPessoaFisicaDentro().getCfop();
  idPlanoCfopPFDentro = cfg.getCfopPessoaFisicaDentro().getPlanoCusto().getIdconta();
  idCfopPFFora = cfg.getCfopPessoaFisicaFora().getIdcfop();
  cfopPFFora = cfg.getCfopPessoaFisicaFora().getCfop();
  idPlanoCfopPFFora = cfg.getCfopPessoaFisicaFora().getPlanoCusto().getIdconta();
  idCfopOutroEstado = cfg.getCfopOutroEstado().getIdcfop();
  cfopOutroEstado = cfg.getCfopOutroEstado().getCfop();
  idPlanoCfopOutroEstado = cfg.getCfopOutroEstado().getPlanoCusto().getIdconta();
  idCfopOutroEstadoFora = cfg.getCfopOutroEstadoFora().getIdcfop();
  cfopOutroEstadoFora = cfg.getCfopOutroEstadoFora().getCfop();
  idPlanoCfopOutroEstadoFora = cfg.getCfopOutroEstadoFora().getPlanoCusto().getIdconta();
  idCfopTransporteDentro = cfg.getCfopTransporteDentro().getIdcfop();
  cfopTransporteDentro = cfg.getCfopTransporteDentro().getCfop();
  idPlanoCfopTransporteDentro = cfg.getCfopTransporteDentro().getPlanoCusto().getIdconta();
  idCfopTransporteFora = cfg.getCfopTransporteFora().getIdcfop();
  cfopTransporteFora = cfg.getCfopTransporteFora().getCfop();
  idPlanoCfopTransporteFora = cfg.getCfopTransporteFora().getPlanoCusto().getIdconta();
  idCfopPrestacaoServicoDentro = cfg.getCfopPrestadorServicoDentro().getIdcfop();
  cfopPrestacaoServicoDentro = cfg.getCfopPrestadorServicoDentro().getCfop();
  idPlanoCfopPrestacaoServicoDentro = cfg.getCfopPrestadorServicoDentro().getPlanoCusto().getIdconta();
  idCfopPrestacaoServicoFora = cfg.getCfopPrestadorServicoFora().getIdcfop();
  cfopPrestacaoServicoFora = cfg.getCfopPrestadorServicoFora().getCfop();
  idPlanoCfopPrestacaoServicoFora = cfg.getCfopPrestadorServicoFora().getPlanoCusto().getIdconta();
  idCfopProdutorRuralDentro = cfg.getCfopProdutorRuralDentro().getIdcfop();
  cfopProdutorRuralDentro = cfg.getCfopProdutorRuralDentro().getCfop();
  idPlanoCfopProdutorRuralDentro = cfg.getCfopProdutorRuralDentro().getPlanoCusto().getIdconta();
  idCfopProdutorRuralFora = cfg.getCfopProdutorRuralFora().getIdcfop();
  cfopProdutorRuralFora = cfg.getCfopProdutorRuralFora().getCfop();
  idPlanoCfopProdutorRuralFora = cfg.getCfopProdutorRuralFora().getPlanoCusto().getIdconta();  
  idCfopExteriorDentro = cfg.getCfopExteriorDentro().getIdcfop();
  cfopExteriorDentro = cfg.getCfopExteriorDentro().getCfop();
  idPlanoCfopExteriorDentro = cfg.getCfopExteriorDentro().getPlanoCusto().getIdconta();
  idCfopExteriorFora = cfg.getCfopExteriorFora().getIdcfop();
  cfopExteriorFora = cfg.getCfopExteriorFora().getCfop();
  idPlanoCfopExteriorFora = cfg.getCfopExteriorFora().getPlanoCusto().getIdconta();  
  idCfopSubContratacaoDentro = cfg.getCfopSubContratacaoDentro().getIdcfop();
  cfopSubContratacaoDentro = cfg.getCfopSubContratacaoDentro().getCfop();
  idPlanoCfopSubContratacaoDentro = cfg.getCfopSubContratacaoDentro().getPlanoCusto().getIdconta();
  idCfopSubContratacaoFora = cfg.getCfopSubContratacaoFora().getIdcfop();
  cfopSubContratacaoFora = cfg.getCfopSubContratacaoFora().getCfop();
  idPlanoCfopSubContratacaoFora = cfg.getCfopSubContratacaoFora().getPlanoCusto().getIdconta();
  plcustopadrao = cfg.getPlanoDefault();
        
    String acao = (request.getParameter("acao") == null || nivelUser == 0 ? "" : request.getParameter("acao"));
    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
    boolean carregaorc = !(acao.equals("incluir") || acao.equals("atualizar") || acao.equals("iniciar") || acao.equals("excluir"));
    cadorc = new BeanCadOrcamento();
    cadorc.setConexao(Apoio.getUsuario(request).getConexao());
    cadorc.setExecutor(Apoio.getUsuario(request));
    
    if(acao.equals("excluirProduto")){
        cadorc.excluirProdutoOrcamento(Apoio.parseInt(request.getParameter("idOrcamento")), Apoio.parseInt(request.getParameter("idProduto")));
        response.getWriter().close();
    }
    if(acao.equals("removerServico")){
        cadorc.excluirServicoOrcamento(Apoio.parseInt(request.getParameter("idOrcamento")), Apoio.parseInt(request.getParameter("idServico")));
        //chamar a função de excluir o serviço, essa função estará em seu bean de cadastros...
    }
    
    if(acao.equals("excluirComposicaoFrete")){
        cadorc.excluirComposicaoFrete(Apoio.parseInt(request.getParameter("idOrcamento")), Apoio.parseInt(request.getParameter("id")));
    }
    if(acao.equals("iniciar")){
        orcamento = cadorc.LoadAllPropertysOrcamentoEmbalagem();
    }
    

    ResultSet rs2 = Tributacao.all("id,descricao,codigo", Apoio.getUsuario(request).getConexao());
    String taxes = "";
    String taxesGenerico = "";
    while (rs2.next()) {
        taxes += (taxes.equals("") ? "" : "!!-") + rs2.getInt("id") + ":.:" + rs2.getString("codigo");
    }
    rs2.close();
    ResultSet rs3 = Tributacao.allGenericos("id,descricao,codigo", Apoio.getUsuario(request).getConexao());
    while (rs3.next()) {
        taxesGenerico += (taxesGenerico.equals("") ? "" : "!!-") + rs3.getInt("id") + ":.:" + rs3.getString("codigo");
    }
    rs3.close();

    if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar") || acao.equals("excluir")) {
        if (acao.equals("editar")) {
            int idorcamento = Apoio.parseInt(request.getParameter("id"));
            orcamento.setId(idorcamento);
            cadorc.setOrcamento(orcamento);
            carregaorc = cadorc.LoadAllPropertys();
            orcamento = (carregaorc ? cadorc.getOrcamento() : null);
        } else if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir") || acao.equals("excluir"))) {
            boolean executou = false;
            cadorc.setExecutor(Apoio.getUsuario(request));
//ATENÇÃO PERGUNTAR A DEIVID SOBRE O CAMPO VALORPESO E O CAMPO VALOR FRETE PESO
            //setando os atributos que nao podem ser setados dinamicamente(acoes: atualizar/incluir)
            if (acao.equals("atualizar") || acao.equals("incluir")) {


                orcamento.setId(Apoio.parseInt(request.getParameter("idorcamento")));
                orcamento.getFilial().setIdfilial(Apoio.parseInt(request.getParameter("idfilial")));
                orcamento.setNumero(request.getParameter("numero"));
                orcamento.setDtLancamento(Apoio.paraDate(request.getParameter("dtemissao")));
                orcamento.getCliente().setIdcliente(Apoio.parseInt(request.getParameter("idremetente")));
                orcamento.getCliente().setRazaosocial(request.getParameter("rem_rzs"));
                orcamento.getCliente().setCnpj(request.getParameter("rem_cnpj"));
                orcamento.setFone(request.getParameter("fone"));
                orcamento.setContato(request.getParameter("contato_orcamento"));
                orcamento.setTipo(request.getParameter("tipoTransporte_tipo"));
                orcamento.setEmail(request.getParameter("rem_email"));
                orcamento.setEmailDestinatario(request.getParameter("des_email"));
                orcamento.setValidadeProposta(Apoio.parseInt(request.getParameter("validade_proposta")));
                orcamento.getCidadeOrigem().setIdcidade(Apoio.parseInt(request.getParameter("cid_id_origem")));
                orcamento.getCidadeDestino().setIdcidade(Apoio.parseInt(request.getParameter("idcidadedestino")));
                orcamento.setDistanciaOrigemDestino(Apoio.parseInt(request.getParameter("distancia_km")));
                orcamento.setDistanciaColeta(Apoio.parseInt(request.getParameter("distancia_coleta")));
                orcamento.setDistanciaEntrega(Apoio.parseInt(request.getParameter("distancia_entrega")));
                orcamento.setPeso(Apoio.parseDouble(request.getParameter("peso")));
                orcamento.setVolume(Apoio.parseDouble(request.getParameter("volumes")));
                orcamento.setVlMercadorias(Apoio.parseDouble(request.getParameter("valorMercadoria")));
                orcamento.setCubagemMetro(Apoio.parseDouble(request.getParameter("metro")));
                orcamento.setQtdEntregas(Apoio.parseInt(request.getParameter("qtdEntregas")));
                orcamento.getTipoVeiculo().setId(Apoio.parseInt(request.getParameter("tip")));
                orcamento.getTipoProduto().setId(Apoio.parseInt(request.getParameter("tipoproduto")));
                orcamento.setTipoTaxa(Apoio.parseInt(request.getParameter("tipofrete")));
                orcamento.setTaxaFixa(Apoio.parseDouble(request.getParameter("taxaFixa")));
                orcamento.setValorItr(Apoio.parseDouble(request.getParameter("valor_itr")));
                orcamento.setValorTde(Apoio.parseDouble(request.getParameter("valor_tde")));
                orcamento.setValorDespacho(Apoio.parseDouble(request.getParameter("valor_despacho")));
                orcamento.setValorAdeme(Apoio.parseDouble(request.getParameter("valor_ademe")));
                orcamento.setValorFretePeso(Apoio.parseDouble(request.getParameter("valor_peso")));
                orcamento.setValorPesoAnaliseAereo(Apoio.parseDouble(request.getParameter("valorPeso")));
                orcamento.setValorFreteValor(Apoio.parseDouble(request.getParameter("valor_frete")));
                orcamento.setValorSecCat(Apoio.parseDouble(request.getParameter("valor_sec_cat")));
                orcamento.setValorOutros(Apoio.parseDouble(request.getParameter("valor_outros")));
                orcamento.setValorGris(Apoio.parseDouble(request.getParameter("valor_gris")));
                orcamento.setValorPedagio(Apoio.parseDouble(request.getParameter("valor_pedagio")));
                orcamento.setValorDesconto(Apoio.parseDouble(request.getParameter("valor_desconto")));
                orcamento.setPercentualDesconto(Apoio.parseDouble(request.getParameter("percentual_desconto")));
                orcamento.setValorBaseIcms(Apoio.parseDouble(request.getParameter("base_calculo")));
                orcamento.setValorAliquota(Apoio.parseDouble(request.getParameter("aliquota")));
                orcamento.setPrevisaoEmbarque(Apoio.paraDate(request.getParameter("dtembarque")));
                orcamento.setPrevisaoEntrega(Apoio.paraDate(request.getParameter("dtentrega")));
                orcamento.setObservacao(request.getParameter("observacao"));
                orcamento.getTabelaCliente().setId(Apoio.parseInt(request.getParameter("tabelaId")));
                orcamento.getVendedor().setIdfornecedor(Apoio.parseInt(request.getParameter("idvendedor")));
                orcamento.setMotivo(request.getParameter("motivo"));
                orcamento.setStatus(Apoio.parseInt(request.getParameter("status")));
                orcamento.getAeroportoEntrega().setId(Apoio.parseInt(request.getParameter("aeroportoEntregaId")));
                orcamento.getAeroportoEntrega().setNome(request.getParameter("aeroportoEntrega"));
                orcamento.getAeroportoColeta().setId(Apoio.parseInt(request.getParameter("aeroportoColetaId")));
                orcamento.getAeroportoColeta().setNome(request.getParameter("aeroportoColeta"));
                orcamento.setDescontoFreteNacional(request.getParameter("isDescFreteNacional") != null ? true : false);
                orcamento.setDescontoAdvalorem(request.getParameter("isDescAdvalorem") != null ? true : false);
                //novos campos a partir de 22/12/2009 - de jonas
                orcamento.setBase(Apoio.parseDouble(request.getParameter("base")));
//                orcamento.setQtdKm(Apoio.parseInt(request.getParameter("distanciaKm")));
                //novos campos a partir de 30/12/2009 - de jonas
                orcamento.setIcmsImbutido(Apoio.parseDouble(request.getParameter("icmsImbutido")));
                orcamento.setIncluirIcms(request.getParameter("incluirIcms") != null ? true : false);
                //novos campos a partir de 07/01/2010 - de jonas
                orcamento.setClientePagador(request.getParameter("clientepagador"));
                //novos campos a partir de 13/01/2010 - de jonas ANIVERSÁRIO DE DEIVID
                orcamento.setFoneDestinatario(request.getParameter("dest_fone"));
                orcamento.setContatoDestinatario(request.getParameter("contatoDestinatario"));
                orcamento.setEnderecoColeta(request.getParameter("endereco_col"));
                orcamento.setBairroColeta(request.getParameter("bairro_col"));
                orcamento.setColetarMercadoria(request.getParameter("coletarMercadoria") != null ? true : false);
                //novos campos a partir de 09/02/2010 - de jonas
                orcamento.setCondicaoPgt(Apoio.parseInt(request.getParameter("condicaopgt")));
                orcamento.setTipoPagtoFrete(request.getParameter("pagtoFrete"));
                //destinatario
                orcamento.getDestinatario().setIdcliente(Apoio.parseInt(request.getParameter("iddestinatario")));
                orcamento.getDestinatario().setRazaosocial(request.getParameter("dest_rzs"));
                //cidade coleta
                orcamento.getCidadeColeta().setIdcidade(Apoio.parseInt(request.getParameter("cid_id_coleta")));
                orcamento.getCidadeColeta().setDescricaoCidade(request.getParameter("cid_nome_coleta"));
                orcamento.getCidadeColeta().setUf(request.getParameter("cid_uf_coleta"));
                orcamento.setQuantidadePallets(Apoio.parseInt(request.getParameter("qtdPallet")));
                orcamento.setTde(request.getParameter("incluirTDE") != null);
                orcamento.setCalculaSecCat(request.getParameter("calculaSecCat"));
                orcamento.setIsCobraSecCat(Apoio.parseBoolean("isCobraSecCat"));


                orcamento.setPlaca(request.getParameter("placa"));
                orcamento.setAno(request.getParameter("ano"));
                orcamento.setModelo(request.getParameter("modelo"));
                orcamento.getMarca().setDescricao(request.getParameter("descricao"));
                orcamento.getMarca().setIdmarca(Apoio.parseInt(request.getParameter("idmarca")));
                orcamento.setCor(Apoio.parseInt(request.getParameter("cor")));
                orcamento.setChassi(request.getParameter("chassi"));
                orcamento.setTipoCarga(request.getParameter("tipoCarga"));
                
                orcamento.setValorMercado(Apoio.parseDouble(request.getParameter("valorMercado")));

                orcamento.setConteudo(request.getParameter("conteudo"));

                orcamento.setValorFederaisImbutidos(Apoio.parseDouble(request.getParameter("federaisImbutidos")));
                orcamento.setIncluiFederais(request.getParameter("incluirFederais") != null);
                orcamento.getRepresentanteColeta().setIdfornecedor(Apoio.parseInt(request.getParameter("idredespachanteColeta")));
                orcamento.getRepresentanteEntrega().setIdfornecedor(Apoio.parseInt(request.getParameter("idredespachanteEntrega")));
                orcamento.setValorTotalPrestacao(Apoio.parseDouble(request.getParameter("totalPrestacao")));
                
                //resumo de mudanca
                orcamento.setDescontoPercent(Apoio.parseDouble(request.getParameter("percDesconto")));
                orcamento.setTipoTaxaMudanca(request.getParameter("tipoTaxaMudanca"));
                orcamento.setTipoDescontoPercent(request.getParameter("formaDesconto"));
                orcamento.setIsFinalizaOrcamento(request.getParameter("isFinalizaOrcamento") != null ? true : false);
                orcamento.setValorMudanca(Apoio.parseDouble(request.getParameter("TotalGeral")));
                orcamento.getCfop().setIdcfop(Apoio.parseInt(request.getParameter("idcfop_ctrc")));
                orcamento.setCustosAdm(Apoio.parseDouble(request.getParameter("custoAdministrativo")));
                orcamento.setCustosComercial(Apoio.parseDouble(request.getParameter("custoComercial")));
                //Carreganto as Cubagens
                int qtdCub = Apoio.parseInt(request.getParameter("maxCubagem"));
                Cubagem cubs[] = new Cubagem[qtdCub + 1];
                Cubagem cb = null;
                for (int j = 1; j <= qtdCub; j++) {
                    if (request.getParameter("volume_" + j) != null) {
                        cb = new Cubagem();
                        cb.setVolume(Apoio.parseFloat(request.getParameter("volume_" + j)));
                        cb.setComprimento(Apoio.parseFloat(request.getParameter("comprimento_" + j)));
                        cb.setLargura(Apoio.parseFloat(request.getParameter("largura_" + j)));
                        cb.setAltura(Apoio.parseFloat(request.getParameter("altura_" + j)));
                        cb.setMetroCubico(Apoio.parseFloat(request.getParameter("metro_" + j)));
                        cubs[j] = cb;
                    }
                }
                orcamento.setCubagens(cubs);

                if (orcamento.getClientePagador().equals("c")) {
                    orcamento.getConsignatario().setIdcliente(Apoio.parseInt(request.getParameter("idconsignatario")));
                    orcamento.setContatoConsignatario(request.getParameter("contato_consignatario"));
                    orcamento.setFoneConsignatario(request.getParameter("fone_consignatario"));
                    orcamento.setEmailConsignatario(request.getParameter("con_email"));
                } else if (orcamento.getClientePagador().equals("r")) {
                    orcamento.getConsignatario().setIdcliente(orcamento.getCliente().getIdcliente());
                } else if (orcamento.getClientePagador().equals("d")) {
                    orcamento.getConsignatario().setIdcliente(orcamento.getDestinatario().getIdcliente());
                }

                cadorc.setOrcamento(orcamento);

                OrcamentoProdutos orcpr = null;
                int max = Apoio.parseInt(request.getParameter("max"));
                if(max != 0){
                    for(int i = 1; i <= max; i++){
                        if(request.getParameter("idProduto_" + i) != null) {
                            orcpr = new OrcamentoProdutos();
                            orcpr.setIdOrcamento(Apoio.parseInt(request.getParameter("idOrcamento")));
                            orcpr.setId(Apoio.parseInt(request.getParameter("idOrcProduto_" + i)));
                            orcpr.getProduto().setId(Apoio.parseInt(request.getParameter("idProduto_" + i)));
                            orcpr.getProduto().setCodigo(request.getParameter("codProduto_" + i));
                            orcpr.getProduto().setDescricao(request.getParameter("descProduto_" + i));
                            orcpr.setMetroCubico(Apoio.parseDouble(request.getParameter("metroProduto_" + i)));
                            orcpr.setQuantidade(Apoio.parseInt(request.getParameter("quantProduto_"+i)));
                            orcpr.setValor(Apoio.parseDouble(request.getParameter("valorProduto_"+i)));
                            orcpr.setPesoBruto(Apoio.parseDouble(request.getParameter("pesoBruto_" + i)));
                            orcamento.getProdutos().add(orcpr);
                        }
                    }
                }
                
                int quantidadeEmbalagens = Apoio.parseInt(request.getParameter("contEmbalagem"));
                
                OrcamentoEmbalagem oe = null;
                for(int i = 1; i <= quantidadeEmbalagens ; i++){
                   // if(request.getParameter("idEmbalagem_" + i) != null){
                        oe = new OrcamentoEmbalagem();
                        oe.setOrcamentoId(orcamento.getId());
                        oe.setId(Apoio.parseInt(request.getParameter("idOrcEmbalagem_"+i)));
                        oe.getEmbalagem().setId(Apoio.parseInt(request.getParameter("idEmbalagem_"+i)));
                        oe.setQuantidade(Apoio.parseInt(request.getParameter("quantidade_"+i)));
                        oe.setValor(Apoio.parseDouble(request.getParameter("valorEmbalagem_"+i)));
                        
                        orcamento.getEmbalagem().add(oe);
               // }
                }
                
                //dom de servicos...
                int fim = Apoio.parseInt(request.getParameter("totalServicos"));
                for(int e = 1; e < fim; e++){
                
                    if (request.getParameter("id" + e) != null) {
                OrcamentoServicos os = new OrcamentoServicos();
                os.setId(Apoio.parseInt(request.getParameter("id" + e)));
                os.setDescricaoComplmentar(request.getParameter("servicoCompl" + e));
                os.getTipo_servico().setId(Apoio.parseInt(request.getParameter("id_servico" + e)));
                os.getTributacao().setId(Apoio.parseInt(request.getParameter("issTrib" + e)));
                os.setValor(Apoio.parseDouble(request.getParameter("vl_unitario" + e)));
                os.setIss(Apoio.parseDouble(request.getParameter("perc_iss" + e)));
                os.setQuantidade(Apoio.parseFloat(request.getParameter("qtd" + e)));
                os.setQtdDias(Apoio.parseInt(request.getParameter("qtdDias_" + e)));
                os.getInssTributacao().setId(Apoio.parseInt(request.getParameter("inssTrib" + e)));
                os.setInss(Apoio.parseDouble(request.getParameter("perc_inss" + e)));
                os.getPisTributacao().setId(Apoio.parseInt(request.getParameter("pisTrib" + e)));
                os.setPis(Apoio.parseDouble(request.getParameter("perc_pis" + e)));
                os.getCofinsTributacao().setId(Apoio.parseInt(request.getParameter("cofinsTrib" + e)));
                os.setCofins(Apoio.parseDouble(request.getParameter("perc_cofins" + e)));
                os.getIrTributacao().setId(Apoio.parseInt(request.getParameter("irTrib" + e)));
                os.setIr(Apoio.parseDouble(request.getParameter("perc_ir" + e)));
                os.getCsslTributacao().setId(Apoio.parseInt(request.getParameter("csslTrib" + e)));
                os.setCssl(Apoio.parseDouble(request.getParameter("perc_cssl" + e)));
                os.setEmbutirISS(request.getParameter("embutirISS_" + e) == null ? false : true);

                orcamento.getServicos().add(os);
            }
                //aqui ainda é atualizar ou incluir....
        }
                
           int qtdCompFrete = Apoio.parseInt(request.getParameter("qtdCompFrete"));
           ComposicaoFrete comp = null;
           int idSelecionado = Apoio.parseInt(request.getParameter("isSelecionado"));
           for (int i = 1; i <= qtdCompFrete; i++) {
               if (request.getParameter("idComp_" + i) != null) {
                   comp = new ComposicaoFrete();
                   
                   
                   comp.setId(Apoio.parseInt(request.getParameter("idComp_" + i)));
                   
                   if (idSelecionado != 0 && idSelecionado == comp.getId()) {
                           comp.setSelecionado(true);
                   }
                   
                   comp.setQtdEntrega(Apoio.parseInt(request.getParameter("qtdEntrega_" + i)));
                   comp.setQtdPallets(Apoio.parseInt(request.getParameter("qtdPallet_" + i)));
                   comp.setCodTabela(Apoio.parseInt(request.getParameter("codTab_" + i)));
                   comp.setTipoFrete(request.getParameter("tipoFrete_" + i));
                   comp.getTipoProduto().setId(Apoio.parseInt(request.getParameter("tipoProduto_" + i)));
                   comp.getTipoVeiculo().setId(Apoio.parseInt(request.getParameter("tipoVeiculo_" + i)));

                   comp.setIncluirIcms(Apoio.parseBoolean(request.getParameter("isAddIcms_" + i)));
                   comp.setIncluirPisCofins(Apoio.parseBoolean(request.getParameter("isAddPisCofins_" + i)));
                   comp.setDescontoFreteNacional(Apoio.parseBoolean(request.getParameter("isDescFreteNacional_" + i)));
                   comp.setDescontoAdValorem(Apoio.parseBoolean(request.getParameter("isDescAdValorem_" + i)));
                   comp.setCobrarTde(Apoio.parseBoolean(request.getParameter("isCobrarTde_" + i)));

                   comp.setVlTaxaFixa(Apoio.parseDouble(request.getParameter("vlTaxaFixa_" + i)));
                   comp.setVlTaxaFixaTotal(Apoio.parseDouble(request.getParameter("vlTaxaFixaTot_" + i)));
                   comp.setVlDespacho(Apoio.parseDouble(request.getParameter("vlDespacho_" + i)));
                   comp.setVlAdeme(Apoio.parseDouble(request.getParameter("vlAdeme_" + i)));
                   comp.setVlFretePeso(Apoio.parseDouble(request.getParameter("vlFretePeso_" + i)));
                   comp.setVlFreteValor(Apoio.parseDouble(request.getParameter("vlFreteValor_" + i)));
                   comp.setVlItr(Apoio.parseDouble(request.getParameter("vlItr_" + i)));
                   comp.setVlSecCat(Apoio.parseDouble(request.getParameter("vlSecCat_" + i)));
                   comp.setVlDespesaColeta(Apoio.parseDouble(request.getParameter("vlDespesaColeta_" + i)));
                   comp.setVlDespesaEntrega(Apoio.parseDouble(request.getParameter("vlDespesaEntrega_" + i)));
                   comp.setVlPeso(Apoio.parseDouble(request.getParameter("vlPeso_" + i)));
                   comp.setVlOutros(Apoio.parseDouble(request.getParameter("vlOutros_" + i)));
                   comp.setBaseCubagem(Apoio.parseDouble(request.getParameter("baseCubagem_" + i)));
                   comp.setPesoCubagem(Apoio.parseDouble(request.getParameter("pesoCubagem_" + i)));
                   comp.setVlGris(Apoio.parseDouble(request.getParameter("vlGris_" + i)));
                   comp.setVlPedagio(Apoio.parseDouble(request.getParameter("vlPedagio_" + i)));
                   if (comp.isCobrarTde()) {
                       comp.setVlTde(Apoio.parseDouble(request.getParameter("vlTde_" + i)));
                   }
                   comp.setVlDesconto(Apoio.parseDouble(request.getParameter("vlDesconto_" + i)));
                   comp.setBaseIcms(Apoio.parseDouble(request.getParameter("baseCalcIcms_" + i)));
                   comp.setPercIcms(Apoio.parseDouble(request.getParameter("percIcms_" + i)));
                   comp.setPercDesconto(Apoio.parseDouble(request.getParameter("percDesconto_" + i)));
                   comp.setVlIcmsImbutido(Apoio.parseDouble(request.getParameter("vlIcmsImbutido_" + i)));
                   orcamento.getComposicoesFrete().add(comp);
               }
           }
                
                if (acao.equals("atualizar")) {
                    executou = cadorc.Atualiza(Apoio.getConfiguracao(request));
                } else if (acao.equals("incluir") && nivelUser >= 3) {
                    executou = cadorc.Inclui(Apoio.getConfiguracao(request));
                }
                
                if (!executou) {
                    
%>
<script type="text/javascript">
    
    if(<%=cadorc.getErros().indexOf("unk_orcamento_produto") > -1%>) {
        if (<%=orcpr != null%>) {
              alert("Atenção, o produto " + '<%=orcpr != null ? orcpr.getProduto().getDescricao() : "" %>' + " não pode ser adicionado mais de uma vez!");
        }
    }else {
        alert('<%=cadorc.getErros()%>');
    }
    window.opener.habilitaSalvar(true);
    window.close();
</script>
<%} else {%>
<script>
    window.opener.document.location.replace('./consulta_orcamento.jsp?acao=iniciar');
    window.close();
</script>
<%
        String scr = "";
        scr = "<script>";
        scr += "voltar();"
                + //      "window.close();"+
                "</script>";
        //response.getWriter().append(scr);
    }
    //response.getWriter().close();

} else if (acao.equals("excluir") && nivelUser >= 4) {
    cadorc.setOrcamento(orcamento);
    executou = cadorc.Deleta();
}
        }
    }

    if (acao.equals("carregar_taxasRedespOrigem")) {
        int idRedesp = Apoio.parseInt(request.getParameter("idredespachanteColeta"));
        int idCidade = Apoio.parseInt(request.getParameter("cid_id_origem"));
        int idFilial = Apoio.parseInt(request.getParameter("idfilial"));
        int idAeroporto = Apoio.parseInt(request.getParameter("aeroportoColetaId"));
        int distanciaColeta = 0;

        TabelaPrecoRedespacho tbredespOrigem = null;
        tbredespOrigem = cadorc.getTabelaPrecoFornecedorArea(idRedesp, idCidade);

        if (tbredespOrigem != null) {
            distanciaColeta = cadorc.getDistanciaColeta(idCidade, idFilial, idAeroporto);
        }

        if (tbredespOrigem != null) {
            JSONObject jo = new JSONObject();
            jo.put("vlfreteminimo", tbredespOrigem.getVlfreteminimo());
            jo.put("vlsobfrete", tbredespOrigem.getVlsobfrete());
            jo.put("vlsobpeso", tbredespOrigem.getVlsobpeso());
            jo.put("vlsobkm", tbredespOrigem.getVlsobkm());
            jo.put("vlprecofaixa", tbredespOrigem.getVlPrecoFaixa());
            jo.put("vlkgate", tbredespOrigem.getVlKgAte());
            jo.put("tipotaxa", tbredespOrigem.getTipoTaxa());
            jo.put("distanciaColeta", distanciaColeta);
            jo.put("vlTaxaFixa", tbredespOrigem.getTaxaFixa());
            response.getWriter().append(jo.toString().replace("\"false\"", "false").replace("\"true\"", "true"));
        } else {
            response.getWriter().append("load=0");
        }
        response.getWriter().close();
    }

    if (acao.equals("carregar_taxasRedespDestino")) {
        int idRedesp = Apoio.parseInt(request.getParameter("idredespachanteEntrega"));
        int idCidade = Apoio.parseInt(request.getParameter("idcidadedestino"));
        int idAeroporto = Apoio.parseInt(request.getParameter("aeroportoEntregaId"));
        int distanciaEntrega = 0;
        TabelaPrecoRedespacho tbredespDestino = null;
        tbredespDestino = cadorc.getTabelaPrecoFornecedorArea(idRedesp, idCidade);


        if (tbredespDestino != null) {
            distanciaEntrega = cadorc.getDistanciaEntrega(idAeroporto, idCidade);
        }

        if (tbredespDestino != null) {
            JSONObject jo = new JSONObject();
            jo.put("vlfreteminimo", tbredespDestino.getVlfreteminimo());
            jo.put("vlsobfrete", tbredespDestino.getVlsobfrete());
            jo.put("vlsobpeso", tbredespDestino.getVlsobpeso());
            jo.put("vlsobkm", tbredespDestino.getVlsobkm());
            jo.put("vlprecofaixa", tbredespDestino.getVlPrecoFaixa());
            jo.put("vlkgate", tbredespDestino.getVlKgAte());
            jo.put("tipotaxa", tbredespDestino.getTipoTaxa());
            jo.put("distanciaEntrega", distanciaEntrega);
            jo.put("vlTaxaFixa", tbredespDestino.getTaxaFixa());
            response.getWriter().append(jo.toString().replace("\"false\"", "false").replace("\"true\"", "true"));
        } else {
            response.getWriter().append("load=0");
        }
        response.getWriter().close();
    }
%>


<script language="JavaScript" type="text/javascript">
    // ----------------------------------- C A L C U L O S // ini
    var federais = ${configuracao.totalImpostosFederais};
    var pesoRealVarios = new Array();
    alteraTipoFrete = <%=alteraTipoFrete%>;
    
    function calculataxaFixaTotal(valor){
        /*
         Esta função calcula o valor da taxa fixa total, inversamente proporcional
            ou seja, caso o mesmo precione tab na quantidade ele vai fazer a multiplicação,
            como faria tabem na taxa fixa, porem caso o mesmo prescione tab no total será feito a divisão.
            depois calcula o frete.
         */
        try{
        
            if ($("qtdEntregas").value == valor || $("taxaFixa").value == valor){            
                $("taxaFixaTotal").value = formatoMoeda($("taxaFixa").value * $("qtdEntregas").value);
            }else {
                if ($("qtdEntregas").value == 0){
                    $("qtdEntregas").value = "1";
                    $("taxaFixa").value = formatoMoeda($("taxaFixaTotal").value);
                }else{
                    $("taxaFixa").value = formatoMoeda($("taxaFixaTotal").value / $("qtdEntregas").value);
                }
            }
            calculaFrete();
            validaTipoTransporte();
        }catch(e){
            console.error(e);
        }
    }

    function calculaFrete(){
        /*
         esta tem a função de fazer a soma de todos os impostos
         */
        var resultado = 0;
         
            resultado = parseFloat($("taxaFixaTotal").value) +parseFloat($("valor_itr").value)                
                + parseFloat($("valor_ademe").value) + parseFloat($("valor_peso").value) +
                parseFloat($("valor_frete").value) +// parseFloat($("valor_sec_cat").value) +
                parseFloat($("valor_outros").value) + parseFloat($("valor_gris").value) +
                parseFloat($("valor_despacho").value) + parseFloat($("valor_pedagio").value) -
                (parseFloat($("percentual_desconto").value ) > 0 && $("tipoTransporte_tipo").value == "a"? (parseFloat($("percentual_desconto").value) * (parseFloat($("isDescAdvalorem").checked?$("valor_frete").value:0)+parseFloat($("isDescFreteNacional").checked?$("valor_peso").value:0)))/100  :              parseFloat($("valor_desconto").value));
        
        if ($("isCobraSecCat").checked) {
           if (tarifas != undefined){
                if (tarifas.calcula_sec_cat != undefined){
                    $("calculaSecCat").value = tarifas.calcula_sec_cat;
                    mostraCobraSecCat(tarifas.calcula_sec_cat);
                    if ($('fi_uf').value == 'MG' && $('con_uf').value == 'MG' && $('idconsignatario').value == $('idremetente').value && ($('rem_st_mg').value == 'true' || $('rem_st_mg').value == 't')){ aliqTabela = 14.4;}
                    
                }} resultado = parseFloat(resultado) + parseFloat($('valor_sec_cat').value);
        }else{
            $("valor_sec_cat").value = "0.00";
        }     
        
        if($("percentual_desconto").value >0 ){
            var valorDescontoPercentual = (parseFloat($("percentual_desconto").value) * (parseFloat($("isDescAdvalorem").checked?$("valor_frete").value:0)+parseFloat($("isDescFreteNacional").checked?$("valor_peso").value:0)))/100;
            $("valor_desconto").value = formatoMoeda(valorDescontoPercentual);
        }
        
        if ($('incluirTDE').checked){
            if (tarifas != undefined){
                if (tarifas.formula_tde != undefined && tarifas.formula_tde != ''){
                    $('valor_tde').value = getTDE(tarifas.formula_tde, $('tipofrete').value, $('peso').value, $('valorMercadoria').value, $('volumes').value, $("qtdPallet").value, $('distancia_km').value, $('tip').value, tarifas.is_considerar_maior_peso,$("base").value,$("metro").value, $('qtdEntregas').value,$("tipoTransporte_tipo").value, resultado, parseFloat($("valor_peso").value), parseFloat($("valor_frete").value), $("tipo_arredondamento_peso").value,tarifas.tipo_inclusao_icms, $('aliquota').value, (jQuery("#clientepagador").val() == 'r' ? "0" : (jQuery("#clientepagador").val() == 'd' ? "1" : "2")), undefined, undefined);
                }else if (tarifas.tipo_tde == 'v'){
                    $('valor_tde').value = formatoMoeda(tarifas.valor_dificuldade_entrega);
                }else if (tarifas.tipo_tde == 'p'){
                    $('valor_tde').value = formatoMoeda((parseFloat(resultado) * tarifas.valor_dificuldade_entrega / 100));
                }
            }
            resultado = parseFloat(resultado) + parseFloat($('valor_tde').value);
        }else{
            $('valor_tde').value = "0.00";
        }
        
        
        
        $("totalPrestacao").value = formatoMoeda(resultado) ;

        if(<%=(orcamento != null ? true : false)%>){
            /*
                funçao não utilizada no carregar do banco.
                desver ser separada das demais.
             */
            $("base_calculo").value = formatoMoeda(resultado);
        }
        // calculo do ICMS
        $("icms").value = formatoMoeda($("aliquota").value * $("base_calculo").value/100);

        //Caso esteja marcada a opção de incluir icms
        calculoIncluiIcms();
        validaTipoTransporte();
       
        //        ATENÇÃO PERGUNTAR A DEIVID SOBRE A TAXA ORIGEM SE È TAXAFIXA OU TAXAFIXATOTAL
        // FALTA SALVAR VALOR PESO NO BANCO DE DADOS
        $("despColeta").value =  ($("idredespachanteColeta").value !=0 ? $("taxaFixaTotal").value:0.00);
        $("despEntrega").value = ($("idredespachanteEntrega").value != 0 ? $("valor_sec_cat").value : 0.00);
        
        totalFinanceiro();
        // ESTE È O RESUMO FINANCEIRO
    }
    
    function mostraCobraSecCat(cobraSecCat){
        if (cobraSecCat == 'p') {
            visivel($("isCobraSecCat"));
            visivel($("lbCobraSecCat"));
        }else{
            invisivel($("isCobraSecCat"));
            invisivel($("lbCobraSecCat"));
        }
    }
    
    function calcularSeguro(){
        var valor = $("valor_frete").value;
        $("seguro").value = valor;
        calculaGeralResumo();
    }

    function calcularPeso(){
        var valor = $("valor_peso").value;
        $("valorFrete").value = valor;
        CalcularPercent();
        calcularSubTotal();
    }
    
    //atribui valor_reset para o input text se o mesmo contiver um valor nao inteiro tive que colocar essa função dentro desse jsp por que no .js ele não estava encontrando.
    function seNaoIntReset(obj_input, valor_reset){
        if (obj_input.value.trim() == ""){
            obj_input.value = valor_reset;
            return true;
        }

        obj_input.value = ((isNaN(obj_input.value)) || (obj_input.value.indexOf('.') > -1) ? //ATENCAO!! Kenneth removeu "|| parseInt(vlr) == 0" daqui pq nao aceitava "0"
                valor_reset : obj_input.value);
        obj_input.value = obj_input.value.trim();
    }
    
    function CalcularPercent(){
        var percent = $("percDesconto").value;
        var tipoDesc = $("formaDesconto").value;
        
        if(tipoDesc == "R"){
            $("totalDesconto").value =  percent;
        }else
        if(tipoDesc == "P"){
            $("totalDesconto").value = (($("valorFrete").value * percent)/100);
        }
    
        redespTxOrigem();
    }
    
    function CalcularPercentCTENFSE(){
        var tipoDesc = $("tipoTaxaMudanca").value;
        
        if(tipoDesc == "CTE"){
        $("NFSE_CTEPercent").value =  $("aliquota").value;
        }else
        if(tipoDesc == "NFSE"){
        $("NFSE_CTEPercent").value = issPadrao;
    }
    calculaGeralResumo();
    }
    
    function calculaValorTotalResumo(){
    var subFrete  = parseFloat($("subTotal").value);//recupera o valor de sub frete
    var seguro    = parseFloat($("seguro").value);//recupera o valor de seguro
    var embalagem = parseFloat($("embalagemTotal").value);//recupera o valor de embalagens
    var servicos  = parseFloat($("servicosTotal").value);//recupera o valor de servicos
    var geral = parseFloat(subFrete) + parseFloat(seguro) + parseFloat(embalagem) + parseFloat(servicos);//faz o somatorio
    return geral;//retorna o valor
    }
    
    function calculaTotalImpostosResumo(){
    var geralResumo = calculaValorTotalResumo();//chama a funcao
    var impostoPercent = $("NFSE_CTEPercent").value;//recupera o percentual de imposto CTE ou NFSE
    $("TotalImposto").value = roundABNT(((geralResumo/100)*impostoPercent), 2); //seta no campo Valor Imposto
    return ((geralResumo/100)*impostoPercent);
    }
    
    function calculaGeralResumo(){
        var geralResumo = roundABNT(calculaValorTotalResumo(), 2);//chama a funcao
        var valorImposto = roundABNT(calculaTotalImpostosResumo(), 2); //recupera o valor do imposto
        $("TotalGeral").value = roundABNT(geralResumo + valorImposto, 2);//seta o valor no campo Total Getal
    }
    
    function carregarTotalGeralServicosParaResumo(){
    $("servicosTotal").value = getTotalGeralServico();
    calculaGeralResumo();
    }
    
    function calcularSubTotal(){
         var subTotal = $("valorFrete").value - $("totalDesconto").value;
         $("subTotal").value = subTotal;
         calculaGeralResumo();
    }
    
    function calcularTotalEmbalagem(){
        var max = ($("contEmbalagem") == null ? 0 : $("contEmbalagem").value);
        var cont = 1;
        var total = 0;
        for(cont = 1; cont <= max; cont++){
            total = parseFloat(total) + parseFloat($("totalEmbalagem_"+cont).value);
         }
        $("totalEmbalagens").value = total;
        $("embalagemTotal").value = total;
        calculaGeralResumo();
    }
    
    var issPadrao = '<%= Apoio.getConfiguracao(request).getServicoMontagemCarga().getIss() %>';

    function valorIssPadrao(){

        $("NFSE_CTEPercent").value =  issPadrao;
    
    }
    
    
    function calculoIncluiIcms(){
        var totalPrestacao = parseFloat($("totalPrestacao").value);
        var aliquota = parseFloat($("aliquota").value);
        var icms = parseFloat($("totalPrestacao").value);
        var federais = parseFloat(<%=cfg.getCalcularEmbutirImpostosFederais()%>);
        
        var mostrarLabelFiscal = "";
        var labelFederais = "";
            if (<%=cfg.isEmbutirPis()%>) {
                mostrarLabelFiscal += "/PIS";
            }
            if (<%=cfg.isEmbutirCofins()%>) {
                mostrarLabelFiscal += "/COFINS";
            }
            if (<%=cfg.isEmbutirIR()%>) {
                mostrarLabelFiscal += "/IR";
            }
            if (<%=cfg.isEmbutirCssl()%>) {
                mostrarLabelFiscal += "/CSSL";
            }
            var label = mostrarLabelFiscal.lastIndexOf("/");
            if (label > -1) {
                labelFederais = mostrarLabelFiscal.replace("/","").replace(" ","/").replace(" ","/").replace(" ","/");
            }
        $("lbpis").innerHTML = labelFederais;
        $("federaisImbutidos").style.display = "";
        if ($("incluirIcms").checked && $("incluirFederais").checked){
            aliquota += parseFloat(federais);
            totalPrestacao = totalPrestacao /((100-aliquota)/100);
            $("totalPrestacao").value = formatoMoeda(totalPrestacao);
            $("base_calculo").value = formatoMoeda(totalPrestacao);
            $("icms").value = formatoMoeda(parseFloat($("totalPrestacao").value) * parseFloat($("aliquota").value) / 100);
            $("icmsImbutido").value = $("icms").value;
            $("federaisImbutidos").value = formatoMoeda(parseFloat($("totalPrestacao").value) * parseFloat(federais) / 100);
        }else if ($("incluirIcms").checked){
            totalPrestacao = totalPrestacao /((100-aliquota)/100);
            icms = totalPrestacao - icms;
            $("totalPrestacao").value = formatoMoeda(totalPrestacao);
            $("base_calculo").value = formatoMoeda(totalPrestacao);
            $("icms").value = formatoMoeda(icms);
            $("icmsImbutido").value = formatoMoeda(icms);
            $("federaisImbutidos").value = '0.00';
            $("lbpis").innerHTML = "";
            $("federaisImbutidos").style.display = "none";
        }else if ($("incluirFederais").checked){
            totalPrestacao = totalPrestacao /((100-federais)/100);
            $("totalPrestacao").value = formatoMoeda(totalPrestacao);
            $("base_calculo").value = formatoMoeda(totalPrestacao);
            $("federaisImbutidos").value = formatoMoeda(parseFloat($("totalPrestacao").value) * parseFloat(federais) / 100);
            $("icms").value = formatoMoeda(parseFloat($("totalPrestacao").value) * parseFloat($("aliquota").value) / 100);
            $("icmsImbutido").value = '0';
        }else {
            $("icmsImbutido").value = '0';
            $("federaisImbutidos").value = '0.00';
            $("lbpis").innerHTML = "";
            $("federaisImbutidos").style.display = "none";
        }
        validaTipoTransporte();
    }

    function calculaMetroCubico(){
        /*
         sem necessidade de calcular quando é carregado.
         */
        //        $("metro").value =  formatoMoeda(parseFloat($("altura").value)*parseFloat($("largura").value)*parseFloat($("comprimento").value)*parseFloat($("volumes").value));
        
        alteraTipoTaxa('N');
        validaTipoTransporte();
    }
    
    function totalizarEmbalagem(index){ 
    
    if($("quantidade_"+index) != null){
    
        var quantidade = $("quantidade_"+index).value;
        var valorUnitario = $("valorEmbalagem_"+index).value;
        $("totalEmbalagem_"+index).value = (quantidade * valorUnitario) ;
        }
     }
    

    function validaTipoTransporte(){
        var tipoTransporte  = $("tipoTransporte_tipo").value;
        if(tipoTransporte == "a"){
            $("lbTaxaFixa").innerHTML="Taxa Origem:";
            $("lbFreteValor").innerHTML = "AdValorEm:";
            $("lbFretePeso").innerHTML="Frete Nacional:";
            $("lbSecCat").innerHTML="Taxa Destino:";
            $("trFornecedor").style.display="";
            $("trDistancia").style.display = "";
            $("lblPercentualDesc").style.display= "";
            $("lblIsDescFreteNacional").style.display= "";
            $("lblIsDescAdvalorem").style.display= "";
            $("detalheAerio").style.display="";
        }else{
            $("detalheAerio").style.display="none";
            $("lbTaxaFixa").innerHTML="Taxa Fixa:";
            $("lbFreteValor").innerHTML = "Frete Valor:";
            $("lbFretePeso").innerHTML="Frete Peso:";
            $("lbSecCat").innerHTML="SEC/CAT:";
            $("trFornecedor").style.display="none";
            $("trDistancia").style.display = "none";
            $("lblPercentualDesc").style.display= "none";
            $("lblIsDescFreteNacional").style.display= "none";
            $("lblIsDescAdvalorem").style.display= "none";
        }
        
        validatTipoTransporteTodos();
    }
    // ----------------------------------------------- C A L C U L O S // fim

    function verCliente(tipo) {
        var mostrar = false;
        var idCliente = 0;
        if (tipo == 'R' && $('rem_codigo').value != '') {
            idCliente = $('rem_codigo').value;
            mostrar = true;
        } else if (tipo == 'D' && $('des_codigo').value != '') {
            idCliente = $('des_codigo').value;
            mostrar = true;
        } else if (tipo == 'C' && $('con_codigo').value != '') {
            idCliente = $('con_codigo').value;
            mostrar = true;
        }
        if (mostrar)
            window.open('./cadcliente?acao=editar&id=' + idCliente, 'Cliente', 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
    }

    function applyEventInServ() {
        var lastIndex = (getNextIndexFromServ('node_servs') - 1);
        //aplicando o evento ao ultimo servico adicionado
        var lastVlUnit = $("vl_unitario"+lastIndex);
        if (lastVlUnit != null){
            lastVlUnit.onchange = function(){
                seNaoFloatReset(lastVlUnit,"0.00");
                //atualizando totais
                setValorHidden(lastIndex);
                getCalculaTotalServ(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                validaTipoTributacao(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                refreshTotal(true, true);
            };
        }
        var lastQtd = $("qtd"+lastIndex);
        if (lastQtd != null){
            lastQtd.onchange = function(){
                seNaoFloatReset(lastQtd,"1");
                //atualizando totais
                validaTipoTributacao(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                getCalculaTotalServ(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                refreshTotal(true, true);
            };
        }
        var lastDias = $("qtdDias_"+lastIndex);
        if (lastDias != null){
            lastDias.onchange = function(){
                seNaoFloatReset(lastQtd,"1");
                //atualizando totais
                validaTipoTributacao(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                getCalculaTotalServ(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                refreshTotal(true, true);
            };
        }
        var lastIss = null;
        lastIss = $("perc_iss"+lastIndex);
        if (lastIss != null){
            lastIss.onchange = function(){
                seNaoFloatReset(lastIss,"0.00");
                //atualizando totais
                validaTipoTributacao(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                getCalculaTotalServ(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                refreshTotal(true, true);
            };
        }                    
        var lastInss = null;
        lastInss = $("perc_inss"+lastIndex);
        if (lastInss != null){
            lastInss.onchange = function(){
                seNaoFloatReset(lastInss,"0.00");
                //atualizando totais
                validaTipoTributacao(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                getCalculaTotalServ(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                refreshTotal(true, true);
            };
        }
        var lastPis = null;
        lastPis = $("perc_pis"+lastIndex);
        if (lastPis != null){
            lastPis.onchange = function(){
                seNaoFloatReset(lastPis,"0.00");
                //atualizando totais
                validaTipoTributacao(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                getCalculaTotalServ(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                refreshTotal(true, true);
            };
        }
        var lastCofins = null;
        lastCofins = $("perc_cofins"+lastIndex);
        if (lastCofins != null){
            lastCofins.onchange = function(){
                seNaoFloatReset(lastCofins,"0.00");
                //atualizando totais
                validaTipoTributacao(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                getCalculaTotalServ(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                refreshTotal(true, true);
            };
        }
        var lastIr = null;
        lastIr = $("perc_ir"+lastIndex);
        if (lastIr != null){
            lastIr.onchange = function(){
                seNaoFloatReset(lastIr,"0.00");
                //atualizando totais
                validaTipoTributacao(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                getCalculaTotalServ(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                refreshTotal(true, true);
            };
        }
        var lastCssl = null;
        lastCssl = $("perc_cssl"+lastIndex);
        if (lastCssl != null){
            lastCssl.onchange = function(){
                seNaoFloatReset(lastCssl,"0.00");
                //atualizando totais
                validaTipoTributacao(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                getCalculaTotalServ(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                refreshTotal(true, true);
            };
        }
        var lastTrib = null;
        
        for (i = 0; i < listaTributos.length; i++) {
            lastTrib = $(listaTributos[i].descricao+"Trib"+lastIndex);
            if (lastTrib != null){
                lastTrib.onchange = function(){
                    refreshTotal(true, true);
                    validaTipoTributacao(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                };
            }
        }
        var embISS = $("embutirISS_"+lastIndex);
        if (embISS != null){
            if(embISS.disabled==true){
                habilitar(embISS);
                embISS.onchange = function(){
                    refreshTotal(true, true);
                    //                                validaTipoTributacao(lastIndex);
                }
                desabilitar(embISS);
            }else{
                embISS.onchange = function(){
                    refreshTotal(true, true);
                }
            }
        }
    }
    
    function alteraTipoProduto(){
        alteraTipoTaxa($('tipofrete').value);
    }

    /*--- Variaveis globais ---*/
    //indexacao da apropriacao

    function baixar(venc, baixado){
        window.open("./bxcontaspagar?acao=consultar&"+
            "idfornecedor="+$('idfornecedor').value+"&fornecedor="+$('fornecedor').value+"&"+
            "dtinicial="+venc+"&dtfinal="+venc+"&baixado="+baixado+"&idfilial="+$('idfilial').value+"&"+
            "fi_abreviatura="+$('fi_abreviatura').value+"&nf=&valor1=0.00&valor2=0.00&tipoData=dtvenc", "Despesa" , "top=8,resizable=yes,status=1,scrollbars=1");
    }

    // javascript não possui replaceall
    function replaceAll(string, token, newtoken) {
        while (string.indexOf(token) != -1) {
            string = string.replace(token, newtoken);
        }
        return string;
    }

    function aoClicarNoLocaliza(idjanela){
    var valor = $("indexProduto").value;
        
        atribuiCfopPadrao();
        function indiceJanela(initPos, finalPos) { return idjanela.substring(initPos, finalPos); }
        if (idjanela == "Observacao"){
            var obs = "" + $("obs_desc").value;
            obs = replaceAll(obs, "<BR>","\n");
            obs = replaceAll(obs, "<br>","\n");
            obs = replaceAll(obs, "</br>","\n");;
            obs = replaceAll(obs, "</BR>","\n");
            $("observacao").value = obs;
            
        }else if(idjanela != "Produto" && idjanela != "Servico"){
            alteraTipoTaxa('S');
        }

        if (idjanela == "Cliente"){
            $("cid_nome_origem").value = $("rem_cidade").value;
            $("cid_uf_origem").value = $("rem_uf").value;
            $("cid_id_origem").value = $("idcidadeorigem").value;
            $("fone").value = $("rem_fone").value;
            $("idvendedor").value = $("idvenremetente").value;
            $("ven_rzs").value = $("venremetente").value;
            $("tipofrete").value = $("rem_tipotaxa").value;
            setTipofrete($("tipofrete").value);alteraTipoTaxa('S');
            //cidade coleta
            var filial  = $("idfilial").value;
            if ($("remtipoorigem").value == 'f' && $("cidadeFilial_"+filial) != null){
                var idCidadeFl = ($("cidadeFilial_"+filial).value).split("!!")[0];
                var cidadeFl = ($("cidadeFilial_"+filial).value).split("!!")[1];
                var ufFl = ($("cidadeFilial_"+filial).value).split("!!")[2];

                $("cid_id_origem").value = idCidadeFl;
                $("cid_nome_origem").value = cidadeFl;
                $("cid_uf_origem").value = ufFl;
            }
            $("cid_id_coleta").value = $("idcidade_col").value;
            $("cid_nome_coleta").value = $("cidade_col").value;
            $("cid_uf_coleta").value = $("uf_col").value;            
            getTipoProdutos();
            $('contato_orcamento').value = $('contato').value;
            $("utilizaTipoFreteTabelaRem").value = $("is_utilizar_tipo_frete_tabela").value;
            
            getCondicaoPagto();
            getDadosIcms();
            mudarCifFob();
        }

        if (idjanela == "Cidade_orcamento"){
            getDadosIcms();
        }
        if (idjanela == "Destinatario"){
            $("idcidadedestino").value = $("cidade_destino_id").value;
            $("cid_destino").value = $("dest_cidade").value;
            $("uf_destino").value = $("dest_uf").value;
            $("incluirTDE").checked = ($("des_inclui_tde").value == 't' || $("des_inclui_tde").value == 'true');
            getTipoProdutos();
            $('contatoDestinatario').value = $('contato_destinatario').value;
            $("utilizaTipoFreteTabelaDest").value = $("is_utilizar_tipo_frete_tabela").value;
            $("idvendedor").value = $("idvendestinatario").value;
            $("ven_rzs").value = $("vendestinatario").value;
            
            getCondicaoPagto();
            getDadosIcms();
            mudarCifFob();
        }
        if (idjanela == "Consignatario"){
            if ($("con_tabela_remetente").value == "n") {
                 $("utilizaTipoFreteTabelaConsig").value = $("is_utilizar_tipo_frete_tabela").value;
             }else{
                 $("utilizaTipoFreteTabelaConsig").value = ($("utilizaTipoFreteTabelaRem").value);  
                 $("con_tipotaxa").value = $("rem_tipotaxa").value;
             }
            $("fone_consignatario").value = $("con_fone").value; 
            getCondicaoPagto();
            getTipoProdutos();
            getDadosIcms();
        }
        if (idjanela == "Cidade"){ //cidade de origem
            $("cid_id_origem").value = $("idcidadeorigem").value;
            $("cid_nome_origem").value = $("cid_origem").value;
            $("cid_uf_origem").value = $("uf_origem").value;
            getDadosIcms();
        }
        if (idjanela == "Cidade_coleta"){ //cidade de coleta
            $("cid_id_coleta").value = $("idcidadeorigem").value;
            $("cid_nome_coleta").value = $("cid_origem").value;
            $("cid_uf_coleta").value = $("uf_origem").value;
            getDadosIcms();
        }
        if(idjanela == "Representante_Coleta"){
            $("redespachanteColeta").value = $("redspt_rzs").value;
            $("idredespachanteColeta").value = $("idredespachante").value;
            $("aeroportoColetaId").value = $("aeroporto_id").value;
            $("aeroportoColeta").value = $("aeroporto_desc").value;
            $("distancia_coleta").value = $("distancia_coleta").value;
            redespTxOrigem();
            redespTxOrigemAll();
        }
        if(idjanela == "Representante_Entrega"){
            $("redespachanteEntrega").value = $("redspt_rzs").value;
            $("idredespachanteEntrega").value = $("idredespachante").value;
            $("aeroportoEntregaId").value = $("aeroporto_id").value;
            $("aeroportoEntrega").value = $("aeroporto_desc").value;
            $("distancia_entrega").value = $("distancia_entrega").value;
            redespTxDestino();
            redespTxDestinoAll();
        }
        if(idjanela == "Aeroporto_Coleta"){
            $("aeroportoColeta").value = $("aeroporto").value
            $("aeroportoColetaId").value = $("aeroporto_id").value
            redespTxOrigem();
            redespTxOrigemAll();
        }
        if(idjanela == "Aeroporto_Entrega"){
            $("aeroportoEntrega").value = $("aeroporto").value
            $("aeroportoEntregaId").value = $("aeroporto_id").value
            redespTxDestino();
            redespTxDestinoAll();
        }
            
        //se a janela que abrir for a de produtos...
        if(idjanela == "Produto"){
            //limparProdutosMudanca(valor);
            $("codProduto_"+valor).value = $("codigo_produto").value;
            $("descProduto_"+valor).value = $("descricao_produto").value;
            $("idProduto_"+valor).value = $("produto_id").value;
            $("metroProduto_"+valor).value = $("metro_cubico").value;
            $("pesoBruto_"+valor ).value = $("peso_bruto").value;
            depoisDoLocalizar(valor);
        }
        
        if (idjanela.indexOf("Servico") > -1 && idjanela != "Nota_De_Servico"){
                            listaTributos = new Array();
                            listaTributos[0] = new ImpostoServico($('type_service_valor').value * 1, $('type_service_iss_percent').value, $('tax_id').value, 1, "iss");
                            listaTributos[1] = new ImpostoServico($('type_service_valor').value * 1, $('type_service_inss_percent').value, $('inss_tax_id').value, 1, "inss");
                            listaTributos[2] = new ImpostoServico($('type_service_valor').value * 1, $('type_service_pis_percent').value, $('pis_tax_id').value, 1, "pis");
                            listaTributos[3] = new ImpostoServico($('type_service_valor').value * 1, $('type_service_cofins_percent').value, $('cofins_tax_id').value, 1, "cofins");
                            listaTributos[4] = new ImpostoServico($('type_service_valor').value * 1, $('type_service_ir_percent').value, $('ir_tax_id').value, 1, "ir");
                            listaTributos[5] = new ImpostoServico($('type_service_valor').value * 1, $('type_service_cssl_percent').value, $('cssl_tax_id').value, 1, "cssl");

                            addServ(listaTributos,
                            'node_servs',
                            0,
                            $('type_service_id').value,
                            $('type_service_descricao').value,
                            '1',
                            $('type_service_valor').value,
                            '<%=taxes%>',
                            '<%=taxesGenerico%>',
                            $('idplanocusto').value,
                            $('plcusto_conta').value,
                            $('plcusto_descricao').value,
                            "0",
                            "",
                            $('is_usa_dias').value,
                            '1',
                            $("tax_id").value+":.:"+$("codigo_taxa").value+"!!-",
                            "", $("embutir_iss").value, true, 0, "",
                            $("quantidade_casas_decimais_quantidade").value,
                            $("quantidade_casas_decimais_valor").value,
                            "",
                            '<%=cfg.getTipoCalculaIss()%>'
                        );
                           refreshTotal(true, true);
                        

                        }
    }
                        
    //para o DOM de produto depois de localizar o produto ele fará certas acões...
    function depoisDoLocalizar(index){
        //valor total (quantidade x valor)
        if ($("valorTotalProduto_"+index) != null && index > 0) {
            
            $("valorTotalProduto_"+index).value = ($("quantProduto_"+index).value * $("valorProduto_"+index).value);
             
        }
        //valor total geral(soma todos os valores totais)
        var valorTotal = 0;
        var quantidadeItens = countProdutosMudanca;
        parseInt(valorTotal);
            for(var i = 1; i <= quantidadeItens ; i++){ 
                if ($("valorTotalProduto_"+i) != null) {
                    valorTotal = parseFloat(valorTotal) + parseFloat(($("valorTotalProduto_"+i).value));    
                }
            }
            
            
            if (index == 0) {
                valorTotal = 0;
            }
            
        $("valorT").value = 0;
        $("valorT").value = parseFloat(valorTotal);

        var metroTotal = 0;
        parseInt(metroTotal);
        for(var i2 = 1; i2 <= quantidadeItens; i2++){
            if ($("metroProduto_"+i2) != null) {
                metroTotal = parseFloat(metroTotal) + parseFloat($("metroProduto_"+i2).value);    
            }
        }
            if (index == 0) {
                metroTotal = 0;
            }

        $("m3total").value = "0";
        $("m3total").value = formatoMoeda(metroTotal);
        
        //passar esses valores(metrototal e valortotal) para a tela principal...
        $("valorMercadoria").value = parseFloat(valorTotal);
        $("metro").value = metroTotal;
        
        var pesoBrutoTotal = 0;
        parseInt(pesoBrutoTotal);
        for(var i = 1; i <=quantidadeItens; i++) {
            if($("pesoBruto_" + i) != null){
                pesoBrutoTotal = parseFloat(pesoBrutoTotal) + parseFloat($("pesoBruto_" + i).value);                            
            }
                
        }
        if(index == 0) {
            pesoBrutoTotal = 0;
        }
        $("pesoBrutoTotal").value = "0";
        $("pesoBrutoTotal").value = formatoMoeda(pesoBrutoTotal);
     
    }
    
    function popLocate(indice, idlista, nomeJanela){
        launchPopupLocate("./localiza?acao=consultar&idlista="+idlista, nomeJanela + indice);
    }

    //exibe uma msg e para a instrucao
    function alertMsg(msgText){ alert(msgText); return false; }

    function habilitaSalvar(opcao){

        $("botSalvar").disabled = !opcao;
        $("botSalvar").value = (opcao ? "Salvar" : "Enviando...");
    }
    
    var idxTpVeic = 0;
    var idxTpProd = 0;
    var listOptTipoProd = Array();
    var listOptTipoVeiculo = Array();
    listOptTipoProd[idxTpProd++] = new Option(0, "Nenhum");
    listOptTipoVeiculo[idxTpVeic++] = new Option(-1, "Nenhum");
    var listaTipoFreteAll = Array();
    listaTipoFreteAll[0] = new Option(-1, "--Selecione--");
    listaTipoFreteAll[1] = new Option(0, "Peso/Kg");
    listaTipoFreteAll[2] = new Option(1, "Peso/Cubagem");
    listaTipoFreteAll[3] = new Option(2, "% Nota Fiscal");
    listaTipoFreteAll[4] = new Option(3, "Combinado");
    listaTipoFreteAll[5] = new Option(4, "Por Volume");
    listaTipoFreteAll[6] = new Option(5, "Por Km");
    listaTipoFreteAll[7] = new Option(6, "Por Pallet");
    function salvar(){
        var podeSalvar = true;
        var qtd = getNextIndexFromServ('node_servs');

        $('totalServicos').value = qtd;
          
        for(var i=1;i<qtd;i++){
        for(var j=1;j<qtd;j++){
            if($("perc_iss" + i).value != $("perc_iss" + j).value){
                alert("O Percentual de ISS dos Serviços Não pode ser Diferente!");
                podeSalvar = false;;
                }
            }
        }
        if(podeSalvar){
            if($('clientepagador').value == 'c'){
                if($('idconsignatario').value == 0 || $('idconsignatario').value == ""){
                    alert("Selecione um Consignatário!");
                    podeSalvar = false;;
                }
            }else if($('clientepagador').value == 'r'){
                if(($('idremetente').value == 0 || $('idremetente').value == "") && ($("rem_rzs").value.trim() == "")){
                    alert("Selecione um Remetente!");
                    podeSalvar = false;;
                }
            }else if($('clientepagador').value == 'd'){
                if(($('iddestinatario').value == 0 || $('iddestinatario').value == "") && ($("dest_rzs").value.trim() == "")){
                    alert("Selecione um Destinatário!");
                    podeSalvar = false;;
                }
            }
        }
        if(podeSalvar){
            if($('cid_id_origem').value == '0'){
                    alert("Selecione um Cidade de Origem!");
                    podeSalvar = false;;
            } else if($('idcidadedestino').value == '0'){
                    alert("Selecione um Cidade de Destino!");
                    podeSalvar = false;;
            }
        }
		
        if ($('aliquota').value < 0){
            alert(getMensagemAliquota($('cid_uf_origem').value, $('uf_destino').value));
            podeSalvar = false;;
        }
        
        var dataEmissao = new Date($('dtemissao').value.substring(6,10),
        parseFloat($('dtemissao').value.substring(3,5)) -1,
        $('dtemissao').value.substring(0,2));
        var dataEmbarque = new Date($('dtembarque').value.substring(6,10),
        parseFloat($('dtembarque').value.substring(3,5)) - 1,
        $('dtembarque').value.substring(0,2));

        if ($('dtembarque').value != ''){
            if (dataEmbarque.getTime() < dataEmissao.getTime()){
                alert('A data de embarque não pode ser inferior a data de emissão.');
                podeSalvar = false;;
            }
        }
        if ($('dtentrega').value != ''){          
            var dataEntrega =
                new Date($('dtentrega').value.substring(6,10),
            parseFloat($('dtentrega').value.substring(3,5)) - 1,
            $('dtentrega').value.substring(0,2));           
           
            if (dataEntrega.getTime() < dataEmissao.getTime()){
                alert('A data de entrega não pode ser inferior a data de emissão.');
                podeSalvar = false;;
            }else if (dataEntrega.getTime() < dataEmbarque.getTime()){
                alert('A data de entrega não pode ser inferior a data de embarque.');
                podeSalvar = false;;
            }
        }
        if($("percentual_desconto").value > 0 && !$("isDescFreteNacional").checked && !$("isDescAdvalorem").checked){
            alert("Selecione pelo menos um tipo de desconto.");
            podeSalvar = false;;
        }

        habilitaSalvar(false);

        if (<%=nivelUser%> != 4){
            $("condicaopgt").disabled = false;
        }
        //verificar se o produto esta vazio.
        for(var i = 1; i <= countProdutosMudanca; i++){
            if($("idProduto_"+i) != null){
            if($("idProduto_"+i).value == "0"){
                alert("Produto não pode estar vazio!.")
                podeSalvar = false;
            }
        }
        if($("quantProduto_"+i) != null){
            if ($("quantProduto_"+i).value == "") {
                alert("ATENÇÃO: O campo quantidade do produto " + $("descProduto_"+i).value + " não pode ficar em branco!");
                podeSalvar = false;
                break;
                return false;
            }
            else if($("quantProduto_"+i).value == "0"){
                alert("ATENÇÃO: O campo quantidade do produto " + $("descProduto_"+i).value + " precisa ser diferente de 0!");
                podeSalvar = false;
                break;
                return false;
            }
        }
        }
        //validação do total prestação não pode ser 0, quando o status for aprovado
        if(parseFloat($("totalPrestacao").value) <= 0 && $("status").value == 1){            
            alert("Total da prestação não pode ser " + $("totalPrestacao").value);
            habilitaSalvar(true);
            podeSalvar = false;
        }   
            
          //passei esta funcao para o for acima, pois o contador ao excluir dava erro. 11/06/2015  
//        var maxProduto = parseInt($("max").value);
//        for (var max = 1; max <= maxProduto; max++) {
//            if ($("quantProduto_"+max).value == "") {
//                alert("ATENÇÃO: O campo quantidade do produto " + $("descProduto_"+max).value + " não pode ficar em branco!");
//                podeSalvar = false;
//                break;
//                return false;
//            }
//            else if($("quantProduto_"+max).value == "0"){
//                alert("ATENÇÃO: O campo quantidade do produto " + $("descProduto_"+max).value + " precisa ser diferente de 0!");
//                podeSalvar = false;
//                break;
//                return false;
//            }
//        }
        

        if (!validarPreComposicaoFrete()) {
            podeSalvar = false;;
        }
        //habilitando campos para não irem nulos
        $("tipofrete").disabled = false;

        if (podeSalvar) {
            var pop = window.open('about:blank', 'pop', 'width=210, height=100');
            $("formulario").submit();            
        }else{
            habilitaSalvar(true);
        }
        
        return true;
    }

    function voltar(){
        document.location.replace('./consulta_orcamento.jsp?acao=iniciar');
    }
     
    function carregar(){
        var comJs = null;
            getAliquotasIcmsAjax($('idfilial').value);

            if(<%=!acao.equals("iniciar")%>){
            $("tipofrete").value =  '<%=orcamento.getTipoTaxa()%>';
            $("tipoTransporte_tipo").value = '<%=orcamento.getTipo()%>';
            //deve validar o display das divs
           
            
            //adicioonando as cubagens
                 <%for (int u = 0; u < orcamento.getCubagens().length; ++u) {
            Cubagem cb = orcamento.getCubagens()[u];
            if (cb != null) {%>
                        addCubagem("<%=cb.getVolume()%>","<%=cb.getComprimento()%>","<%=cb.getLargura()%>",
                        "<%=cb.getAltura()%>","<%=cb.getMetroCubicoStr()%>"); 
                    <% }
                    } %>
                    
//                    getTipoProdutos();
                    getAliquotasIcmsAjax(<%=orcamento.getFilial().getIdfilial()%>);
                    var op = new ProdutosMudanca();
                    var contador = 1;
                    <c:forEach var="itensProduto" varStatus="status" items="<%=orcamento.getProdutos()%>">
                    op = new ProdutosMudanca() ;
                    
                    op.idOrcProduto = "${itensProduto.id}";//esse é o ID do orcamentoProduto
                    op.idOrcamento = "${itensProduto.idOrcamento}";//esse é o id do orcamento
                    op.idProdutos = "${itensProduto.produto.id}";//esse é o id do PRODUTO EM SI
                    op.descProdutos = "${itensProduto.produto.descricao}";//descricao do produto
                    op.codProdutos = "${itensProduto.produto.codigo}";//codigo do produto
                    op.metroProdutos = "${itensProduto.metroCubico}";//metrocubico do produto
                    op.quantProdutos = "${itensProduto.quantidade}";//quantidade do produto
                    op.valorProdutos = "${itensProduto.valor}";//valor do produto
                    op.pesoBruto = "${itensProduto.pesoBruto}";// Valor do Peso Bruto
                    
                    addProdutosMudanca(op);
                        depoisDoLocalizar(contador);
                        contador++;
                    </c:forEach> 

                        
                    contador = 0;
                    <c:forEach var="emb" varStatus="status" items="<%=orcamento.getEmbalagem()%>"> 
                    contador++;
                    totalizarEmbalagem(contador);
                    </c:forEach> 
                        


                     <c:forEach var="orcserv" varStatus="status" items="<%=orcamento.getServicos()%>">
                         
                          
                    listaTributos = new Array();
                    listaTributos[0] = new ImpostoServico(${orcserv.valor} * ${orcserv.quantidade},${orcserv.iss}, ${orcserv.tributacao.id},${orcserv.qtdDias}, "iss");
                    listaTributos[1] = new ImpostoServico(${orcserv.valor} * ${orcserv.quantidade},${orcserv.inss},${orcserv.inssTributacao.id},${orcserv.qtdDias}, "inss");
                    listaTributos[2] = new ImpostoServico(${orcserv.valor} * ${orcserv.quantidade},${orcserv.pis}, ${orcserv.pisTributacao.id},${orcserv.qtdDias}, "pis");
                    listaTributos[3] = new ImpostoServico(${orcserv.valor} * ${orcserv.quantidade},${orcserv.cofins} ,${orcserv.cofinsTributacao.id},${orcserv.qtdDias}, "cofins");
                    listaTributos[4] = new ImpostoServico(${orcserv.valor} * ${orcserv.quantidade},${orcserv.ir},${orcserv.irTributacao.id},${orcserv.qtdDias}, "ir");
                    listaTributos[5] = new ImpostoServico(${orcserv.valor} * ${orcserv.quantidade},${orcserv.cssl},${orcserv.csslTributacao.id},${orcserv.qtdDias}, "cssl");
                       
                   
            
                     addServ(listaTributos,
                    'node_servs',
                    '${orcserv.id}',
                    '${orcserv.tipo_servico.id}',
                    '${orcserv.tipo_servico.descricao}',
                    '${orcserv.quantidade}',
                    '${orcserv.valor}',
                    '<%=taxes%>','<%=taxesGenerico%>',
                    '${orcserv.tipo_servico.planoCustoPadrao.idconta}',
                    '${orcserv.tipo_servico.planoCustoPadrao.conta}',
                    '${orcserv.tipo_servico.planoCustoPadrao.descricao}',
                    '${orcserv.coleta.id}',
                    '${orcserv.coleta.numero}',
                    '${orcserv.tipo_servico.usaDias}',
                    '${orcserv.qtdDias}',
                    '<%=taxes%>',
                    "",
                    ${orcserv.embutirISS},
                    false, 0, 
                    '${orcserv.descricaoComplmentar}',
                    '${orcserv.tipo_servico.qtdCasasDecimaisQuantidade}', 
                    '${orcserv.tipo_servico.qtdCasasDecimaisValor}',
                    "",
                    '<%=cfg.getTipoCalculaIss()%>'
                );
                    
                refreshTotal(false, false);
                
                         

                    </c:forEach>

                    <%for (ComposicaoFrete com : orcamento.getComposicoesFrete()) {%>
                        comJs = new ComposicaoFrete();
                        comJs.id = "<%=com.getId()%>";
                        comJs.tipProd = "<%=com.getTipoProduto().getId()%>";
                        comJs.tipFrete = "<%=com.getTipoFrete()%>";
                        comJs.tipVeiculo = "<%=com.getTipoVeiculo().getId()%>";
                        comJs.qtdEntrega = "<%=com.getQtdEntrega()%>";
                        comJs.qtdPallet = "<%=com.getQtdPallets()%>";
                        comJs.distanciaKm = "<%=com.getDistanciaKm()%>";
                        comJs.codTabela = "<%=com.getCodTabela()%>";

                        comJs.isIncluirIcms = <%=com.isIncluirIcms()%>;
                        comJs.isIncluirPisCofins = <%=com.isIncluirPisCofins()%>;
                        comJs.isCobrarTde = <%=com.isCobrarTde()%>;
                        comJs.isDescontoFreteNacional = <%=com.isDescontoFreteNacional()%>;
                        comJs.isDescontoAdValorem = <%=com.isDescontoAdValorem()%>;

                        comJs.vlTaxaFixa = "<%=com.getVlTaxaFixa()%>";
                        comJs.vlTaxaFixaTotal = "<%=com.getVlTaxaFixaTotal()%>";
                        comJs.vlDespacho = "<%=com.getVlDespacho()%>";
                        comJs.vlAdeme = "<%=com.getVlAdeme()%>";
                        comJs.vlFretePeso = "<%=com.getVlFretePeso()%>";
                        comJs.vlFreteValor = "<%=com.getVlFreteValor()%>";
                        comJs.vlDespesaColeta = "<%=com.getVlDespesaColeta()%>";
                        
                        comJs.vlDespesaEntrega = "<%=com.getVlDespesaEntrega()%>";
                        comJs.vlPeso = "<%=com.getVlPeso()%>";
                        comJs.vlItr = "<%=com.getVlItr()%>";
                        comJs.vlSecCat = "<%=com.getVlSecCat()%>";
                        comJs.vlOutros = "<%=com.getVlOutros()%>";
                        comJs.vlGris = "<%=com.getVlGris()%>";
                        comJs.vlPedagio = "<%=com.getVlPedagio()%>";
                        comJs.vlIcmsImbutido = "<%=com.getVlIcmsImbutido()%>";
                        comJs.vlTde = "<%=com.getVlTde()%>";
                        comJs.vlDesconto = "<%=com.getVlDesconto()%>";
                        comJs.baseIcms = "<%=com.getBaseIcms()%>";
                        comJs.baseCubagem = "<%=com.getBaseCubagem()%>";
                        comJs.pesoCubagem = "<%=com.getPesoCubagem()%>";
                        comJs.percIcms = "<%=com.getPercIcms()%>";
                        comJs.percDesconto = "<%=com.getPercDesconto()%>";
                        comJs.isSelecionado = <%=com.isSelecionado()%>;

                        comJs.percIcms = (comJs.percIcms == 0 ? $("aliquota").value : comJs.percIcms);
                         
                         addComposicaoFrete(comJs, $('tbPreCalcFrete'));
                    <%}%>
                    if ($("con_tabela_remetente").value != "n") {
                        $("utilizaTipoFreteTabelaConsig").value = $("utilizaTipoFreteTabelaRem").value;
                        $("con_tipotaxa").value = $("rem_tipotaxa").value;
                    }
    
                    var tp = $("tipoTaxaTabela").value;
                    var utiliza = false;
                    var utilizaTabelaRemetente = (($("con_tabela_remetente").value == "s" && ($("utilizaTipoFreteTabelaRem").value == 't' || $("utilizaTipoFreteTabelaRem").value == 'true')) 
                    || ($("con_tabela_remetente").value == "q" && ($("utilizaTipoFreteTabelaRem").value == 't'||$("utilizaTipoFreteTabelaRem").value == 'true')) && tarifas.tipo_frete_remetente != '-1');

                    if((($("utilizaTipoFreteTabelaConsig").value == 't' || $("utilizaTipoFreteTabelaConsig").value == 'true') || utilizaTabelaRemetente) 
                            && ($("tabelaId").value != "0" || $("tabelaId").value != "")){
                        utiliza = true;
                    }
                    
                    if($("tipoTaxaTabela").value!= 'null' && $("tipoTaxaTabela").value!=undefined && (tp!='-1')  && utiliza){
                        if($("utilizaTipoFreteTabelaConsig").value == 't'){
                            $("tipofrete").disabled = true;
                        }
                        $("tipofrete").disabled = 'true';
                    }else{      
                        if(<%=alteraTipoFrete%>){
                            $("tipofrete").disabled = false;
                        }else{
                            $("tipofrete").disabled = true;
                        }
                    }
                    
                }else{
                    getAliquotasIcmsAjax(<%=Apoio.getUsuario(request).getFilial().getIdfilial()%>);
                    if(<%=!alteraTipoFrete%>){
                        disableField("tipofrete", true);
                    }else{
                        disableField("tipofrete", false);
                        setTipofrete('<%=orcamento.getTipoTaxa()%>');
                    }
                }
                
                $("clientepagador").value = '<%=orcamento.getClientePagador()%>';
                $("pagtoFrete").value = '<%=orcamento.getTipoPagtoFrete()%>';
                
                validaTipoTransporte();
                //alteraTipoTaxa('S');
            
                if($("clientepagador").value == "c" ){
                    $("trConsignatario").style.display = "";
                }else{
                    $("trConsignatario").style.display = "none";
                }
                
                
                if($("tipoCarga").value == "v"){                    
                    $("propVeiculo").style.display = "";           
                }else{
                    $("propVeiculo").style.display = "none";            
                }
                $("cor").value = "<%=orcamento.getCor()%>";
                
                if(<%=!orcamento.isPodeExcluir()%>){
                    //desabledAllElement($("formulario"));
                    readOnlyAll($("formulario"),"inputReadOnly8pt");
                    visivel($("labCTRC"));
                }
                
            
            //Alterando a descrição para ficar de acordo com as configurações
            var mostrarLabelFiscal = "";
            
            if (<%=cfg.isEmbutirPis()%>) {
                mostrarLabelFiscal += "/PIS";
            }
            if (<%=cfg.isEmbutirCofins()%>) {
                mostrarLabelFiscal += "/COFINS";
            }
            if (<%=cfg.isEmbutirIR()%>) {
                mostrarLabelFiscal += "/IR";
            }
            if (<%=cfg.isEmbutirCssl()%>) {
                mostrarLabelFiscal += "/CSSL";
            }
            var label = mostrarLabelFiscal.lastIndexOf("/");
            if (label > -1) {
                var labelFederais = mostrarLabelFiscal.replace("/","").replace(" ","/").replace(" ","/").replace(" ","/");
            }
//        if (< %=aprovarOrcamento%> == 4){
//            $("status").disabled = "true";
//        } else{
//            $("status").disabled = "false";
//        }
            
            $("lbPisCofins").innerHTML = labelFederais;
            permissaoAprovarOrcamento();
            calcularCustosFilial($('idfilial').value);
            mostraCobraSecCat($("calculaSecCat").value);
       }
                
            function setTipofrete(valor){
                //$("lbBaseCubagem").style.display = "none";
               // $("divBaseCubagem").style.display = "none";
//                $("lbDistancia").style.display = "none";
//                $("divDistancia").style.display = "none";
                $("lbPallet").style.display = "none";
                $("qtdPallet").style.display = "none";
                if (valor == "1"){
                   // $("lbBaseCubagem").style.display = "";
                  //  $("divBaseCubagem").style.display = "";
                }else if (valor == "5"){
//                    $("lbDistancia").style.display = "";
//                    $("divDistancia").style.display = "";
                }else if (valor == "6"){
                    $("lbPallet").style.display = "";
                    $("qtdPallet").style.display = "";
                }
            }

            function mostrarEndColeta(){
                if ($("coletarMercadoria").checked){
                    $("trColetar").style.display = "";
                }else{
                    $("trColetar").style.display = "none";
                }
            }
            
            function disableField(campo, isDisable){
		$(campo).disabled = isDisable;
            }
            
</script>

<script language="JavaScript" type="text/javascript">
    var buscouTaxas = "-1";
    var tarifas = {};
    var tarifasVarias = new Array();
    var pesoReal = 0;
    var tbPrecoredespOrigem = {};
    var tbPrecoredespDestino = {};

    function limparComposicaoFrete(){
        $("taxaFixa").value = "0.00";
        $("taxaFixaTotal").value = "0.00";
        $("valor_itr").value = "0.00";
        $("valor_despacho").value = "0.00";
        $("valor_ademe").value = "0.00";
        $("valor_peso").value = "0.00";
        $("valor_frete").value = "0.00";
        //segunda linha
        $("valor_sec_cat").value = "0.00";
        $("valor_outros").value = "0.00";
        $("valor_gris").value = "0.00";
        $("valor_pedagio").value = "0.00";
        $("valor_desconto").value = "0.00";
        //terceira linha
        $("totalPrestacao").value = "0.00";
        $("base_calculo").value = "0.00";
        $("icms").value = "0.00";
        $("tabelaId").value = "";
        //novos
        var baseCubagem =  parseFloat($("base").value);
        $("base").value = (baseCubagem > 0 ? baseCubagem : "0");
        recalculaCubagens();
        redespTxOrigem();
        redespTxDestino();
    }
    
    function calcularPesoCubado(tipoTransporte){
        var pesoCubado;
        if (tipoTransporte == 'a'){
            $("base").value = getBaseCubagem(tarifas.base_cubagem_aereo);
            pesoCubado =  parseFloat($("metro").value) * parseFloat(1000000) / parseFloat($("base").value);
        }else{
            $("base").value = getBaseCubagem(tarifas.base_cubagem);
            pesoCubado = parseFloat($("base").value) * parseFloat($("metro").value);
        }
        return pesoCubado;
    }
    
    function alteraTipoTaxa(valida){
        try {
            var idtaxa = $("tipofrete").value;
        //objeto funcao usado na requisicao Ajax(uma espécie de evento)
        function e(transport){
            var textoresposta = transport.responseText;
            espereEnviar("",false);
            //se deu algum erro na requisicao...
            if (textoresposta == "load=0") {
                
                buscouTaxas = "0";
                //fechaClientesWindow();
                if ( valida == "S"){
                
                    alert("Não foi encontrada nenhuma tabela de preço para essa origem e esse destino.");
                }
                limparComposicaoFrete();
                
                return false;
            }
            tarifas = eval('('+textoresposta+')'); // retono JSON
//            if (tarifas.cliente_id == undefined){
//                if (!confirm("Não foi encontrada nenhuma tabela de preço para essa origem e destino, \n deseja utilizar a tabela principal?")){
//                    return false;
//                }
//            }else{
                if (tarifas.valida_ate != undefined){
                    var dataEmissao = new Date($('dtemissao').value.substring(6,10),$('dtemissao').value.substring(3,5),$('dtemissao').value.substring(0,2));
                    var dataValidade = new Date(tarifas.valida_ate.substring(0,4),tarifas.valida_ate.substring(5,7),tarifas.valida_ate.substring(8,10));
                    if (dataValidade.getTime() < dataEmissao.getTime()){
                        alert('Atenção: A tabela de preço número '+tarifas.id+' esta vencida! Favor comunicar ao setor comercial.');
                    }
                }
                if ($('con_tabela_remetente').value == 'q' && ($("utilizaTipoFreteTabelaConsig").value == 'f' || $("utilizaTipoFreteTabelaConsig").value == 'false')){
                    if (tarifas.tipo_frete_remetente != '-1' && tarifas.tipo_frete_remetente != undefined){if (idtaxa != tarifas.tipo_frete_remetente){$("tipofrete").value = tarifas.tipo_frete_remetente;alteraTipoTaxa(valida);}}
                }
//            }
            $("tipoTaxaTabela").value = tarifas.tipo_taxa;
           
            //   Regras de negócio     //     --     encontram-se em tabelaFrete.js
            var pesoCubado = calcularPesoCubado($("tipoTransporte_tipo").value);
            $('pesoKgCubado').value = formatoMoeda(pesoCubado); 
                       
            var tp = $("tipoTaxaTabela").value;
            var utiliza = false;
            var utilizaTabelaRemetente = (($("con_tabela_remetente").value == "s" && ($("utilizaTipoFreteTabelaRem").value == 't' || $("utilizaTipoFreteTabelaRem").value == 'true')) 
            || ($("con_tabela_remetente").value == "q" && ($("utilizaTipoFreteTabelaRem").value == 't'||$("utilizaTipoFreteTabelaRem").value == 'true')) && tarifas.tipo_frete_remetente != '-1');
    
            if(($("utilizaTipoFreteTabelaConsig").value == 't' || $("utilizaTipoFreteTabelaConsig").value == 'true') || utilizaTabelaRemetente){
                utiliza = true;
            }
           
            if($("tipoTaxaTabela").value!= 'null' && $("tipoTaxaTabela").value!=undefined && (tp!='-1') && ($("tipofrete").value != '-1') && utiliza){
                if(($("tipofrete").value=='0' || $("tipofrete").value=='1') && ($("tipoTaxaTabela").value== '1' || $("tipoTaxaTabela").value=='0') &&  tarifas.is_considerar_maior_peso){
                }else if(($("tipofrete").value=='0' || $("tipofrete").value=='1'|| $("tipofrete").value=='2')
                        && ($("tipoTaxaTabela").value== '1' || $("tipoTaxaTabela").value=='0'|| $("tipoTaxaTabela").value=='2') &&  tarifas.is_considerar_valor_maior_peso_nota){
                }else{          
                    
                    if($("utilizaTipoFreteTabelaConsig").value == 't' || $("utilizaTipoFreteTabelaConsig").value == 'true'){
                        $("tipofrete").value= $("tipoTaxaTabela").value;
                        $("tipofrete").disabled = true;
                    }
                }
                $("tipofrete").disabled = 'true';
            }else if (tarifas.cliente_id == undefined && (tp!='-1') && utiliza){
                $("tipofrete").value= $("tipoTaxaTabela").value;
            }else{
                if(<%=alteraTipoFrete%>){
                    $("tipofrete").disabled = false;
                }else{
                    $("tipofrete").disabled = true;
                }
            }
                
            // colocado no local onde os valores são recalculados.
            $("valor_ademe").value = "0.00";
            
            if ($('tipofrete').value == '0'){
                if (tarifas.is_considerar_maior_peso && parseFloat($("peso").value) < pesoCubado){

                    $('tipofrete').value = '1';
                    pesoReal = pesoCubado;
                    setTipofrete('1');
                    alteraTipoTaxa(valida);
                    return null;
                }
            }
            if ($('tipofrete').value == '1'){
                if (tarifas.is_considerar_maior_peso && parseFloat($("peso").value) > pesoCubado){
                    $('tipofrete').value = '0';
                    pesoReal = $('peso').value;
                    setTipofrete('0');
                    alteraTipoTaxa(valida);
                    return null;
                }
            }
            if ($('tipofrete').value == '1'){
                if (tarifas.is_considerar_maior_peso && tarifas.tipo_frete_peso == "f" && parseFloat(formatoMoeda(tarifas.peso_calculo)) < parseFloat(formatoMoeda(pesoCubado))){
                    $('tipofrete').value = '1';
                    pesoReal = pesoCubado;
                    setTipofrete('1');
                    alteraTipoTaxa(valida);
                    return null;
                }
            }
            
            $("valor_sec_cat").value = getValorSecCat(tarifas.valor_sec_cat, tarifas.formula_sec_cat, $('tipofrete').value, $('peso').value, $('valorMercadoria').value, $('volumes').value, '0', $('distancia_km').value, $('tip').value, tarifas.is_considerar_maior_peso,$("base").value,$("metro").value, $('qtdEntregas').value, $("tipoTransporte_tipo").value, tarifas.peso_limite_sec_cat, tarifas.valor_excedente_sec_cat, tarifas.tipo_inclusao_icms, $('aliquota').value, $("tipo_arredondamento_peso").value, (jQuery("#clientepagador").val() == 'r' ? "0" : (jQuery("#clientepagador").val() == 'd' ? "1" : "2")), undefined, undefined); //relaciona (sem calculos)
            
            $("tabelaId").value = getIdTarifas(tarifas.id); // atribui o id da tabelaPreco no label
            
            $("dtentrega").value = tarifas.previsao_entrega_calculada;
            
            $("valor_gris").value = getGris(tarifas.percentual_gris,$("valorMercadoria").value,
            tarifas.valor_minimo_gris, tarifas.formula_gris, $('tipofrete').value, $('peso').value, $('volumes').value, $("qtdPallet").value, $('distancia_km').value, $('tip').value, tarifas.is_considerar_maior_peso,$("base").value,$("metro").value, $('qtdEntregas').value, $("tipoTransporte_tipo").value, tarifas.tipo_inclusao_icms, $('aliquota').value,  $("tipo_arredondamento_peso").value,
            (jQuery("#clientepagador").val() == 'r' ? "0" : (jQuery("#clientepagador").val() == 'd' ? "1" : "2")), undefined, undefined); //calcula o percentual do gris
            
            $("valor_frete").value = getFreteValor($("valorMercadoria").value,
            tarifas.percentual_advalorem,
            tarifas.percentual_nf,
            tarifas.base_nf_percentual,
            tarifas.valor_percentual_nf,
            $("tipofrete").value,
            tarifas.tipo_impressao_percentual,
            tarifas.formula_seguro, tarifas.formula_percentual,
            $('peso').value,
            $('volumes').value, $("qtdPallet").value, $('distancia_km').value,
            $('tip').value, tarifas.is_considerar_maior_peso,$("base").value,
            $("metro").value,false,0,$('qtdEntregas').value,$("tipoTransporte_tipo").value,
            tarifas.tipo_inclusao_icms, $('aliquota').value, true,$("tipo_arredondamento_peso").value,
            (jQuery("#clientepagador").val() == 'r' ? "0" : (jQuery("#clientepagador").val() == 'd' ? "1" : "2")), 
            undefined, undefined); //calcula o percentual do gris
            
            $("valor_pedagio").value = getPedagio($("peso").value,tarifas.vl_pedagio,tarifas.qtd_kg_pedagio, $("tipofrete").value, pesoCubado, tarifas.formula_pedagio,$('valorMercadoria').value,$('volumes').value,$('qtdPallet').value,$('distancia_km').value,$('tip').value,tarifas.is_considerar_maior_peso,$("base").value,$('metro').value,$('qtdEntregas').value,$('tipoTransporte_tipo').value, tarifas.tipo_inclusao_icms, $('aliquota').value, $("tipo_arredondamento_peso").value, (jQuery("#clientepagador").val() == 'r' ? "0" : (jQuery("#clientepagador").val() == 'd' ? "1" : "2")), undefined, undefined);

            $("valor_outros").value = getOutros(tarifas.valor_outros, tarifas.formula_outros, $('tipofrete').value, $('peso').value, $('valorMercadoria').value, $('volumes').value, $("qtdPallet").value, $('distancia_km').value, $('tip').value, tarifas.is_considerar_maior_peso,$("base").value,$("metro").value, $('qtdEntregas').value,$("tipoTransporte_tipo").value, tarifas.tipo_inclusao_icms, $('aliquota').value,  $("tipo_arredondamento_peso").value, (jQuery("#clientepagador").val() == 'r' ? "0" : (jQuery("#clientepagador").val() == 'd' ? "1" : "2")), undefined, undefined);
            $("taxaFixa").value = getTaxaFixa(tarifas.valor_taxa_fixa, tarifas.formula_taxa_fixa, $('tipofrete').value, $('peso').value, $('valorMercadoria').value, $('volumes').value, $("qtdPallet").value, $('distancia_km').value, $('tip').value, tarifas.is_considerar_maior_peso,$("base").value,$("metro").value, $('qtdEntregas').value,$("tipoTransporte_tipo").value, tarifas.peso_limite_taxa_fixa, tarifas.valor_excedente_taxa_fixa, tarifas.tipo_inclusao_icms, $('aliquota').value, $("tipo_arredondamento_peso").value, (jQuery("#clientepagador").val() == 'r' ? "0" : (jQuery("#clientepagador").val() == 'd' ? "1" : "2")), undefined, undefined);
            calculataxaFixaTotal($("taxaFixa").value);

            $("valor_despacho").value = getValorDespacho(tarifas.valor_despacho, tarifas.formula_despacho, $('tipofrete').value, $('peso').value, $('valorMercadoria').value, $('volumes').value, $("qtdPallet").value, $('distancia_km').value, $('tip').value, tarifas.is_considerar_maior_peso,$("base").value,$("metro").value, $('qtdEntregas').value,$("tipoTransporte_tipo").value, tarifas.tipo_inclusao_icms, $('aliquota').value, $("tipo_arredondamento_peso").value, (jQuery("#clientepagador").val() == 'r' ? "0" : (jQuery("#clientepagador").val() == 'd' ? "1" : "2")), undefined, undefined);

            var tipoFrete = $("tipofrete").value; 
            
            // tipo frete = 3 => combinado -> se for combinado ele deve verificar se o tipo de cobrança no veiculo é
                // fixo, por KG ou por TON. e fazer o calculo de acordo com o tipo do veiculo.
            if (tipoFrete == "3") {
                if (tarifas.tipo_taxa_combinado == 1){
                    $("valor_peso").value = (tarifas.valor_veiculo == undefined ? "0.00" : tarifas.valor_veiculo);
                }else if(tarifas.tipo_taxa_combinado == 2){
                    $("valor_peso").value = formatoMoeda((tarifas.valor_veiculo == undefined ? "0.00" : parseFloat(tarifas.valor_veiculo) * parseFloat($("peso").value)));
                }else if(tarifas.tipo_taxa_combinado == 3){
                    $("valor_peso").value = formatoMoeda((tarifas.valor_veiculo == undefined ? "0.00" : parseFloat(tarifas.valor_veiculo) * parseFloat($("peso").value) / 1000));
                }else{
                    $("valor_peso").value = '0.00';
                }
            }else{
                
                $("valor_peso").value = formatoMoeda(getFretePeso($("peso").value,
                $("volumes").value,
                $("tipofrete").value,
                tarifas.valor_peso,
                tarifas.valor_volume,
                $("base").value,
                $("metro").value,
                tarifas.valor_veiculo,
                tarifas.valor_por_faixa,
                $("tipoTransporte_tipo").value,
                tarifas.valor_excedente_aereo ,
                tarifas.valor_excedente,
                tarifas.maximo_peso_final,
                tarifas.ispreco_tonelada,
                tarifas.tipo_frete_peso,
                tarifas.valor_maximo_peso_final,
                tarifas.valor_km,
                tarifas.is_considerar_maior_peso,
                tarifas.tipo_impressao_percentual,
                $("valorMercadoria").value,
                tarifas.base_nf_percentual,
                tarifas.valor_percentual_nf,
                tarifas.percentual_nf,
                $("qtdPallet").value,
                $("distancia_km").value,
                tarifas.formula_volumes, $('tip').value,
                tarifas.formula_percentual,
                tarifas.valor_pallet,
                tarifas.formula_pallet,false,0, $('qtdEntregas').value,
                tarifas.formula_frete_peso,
                tarifas.tipo_inclusao_icms,
                $('aliquota').value, false, 
                $("tipo_arredondamento_peso").value
                ));
            }

//            if ($("tipoFrete").value == 0 && (parseFloat($("peso").value) == 0 || parseFloat($("vlmercadoria").value) == 0)) {
//		  return false;
//            } 

            if (tipoFrete != $("tipofrete").value){
                alteraTipoTaxa(valida);
                return null;
            }
            if (tarifas.isinclui_icms && tarifas.tipo_inclusao_icms == 't'){
                $("incluirIcms").checked = true;
            }else{
                $("incluirIcms").checked = false;
            }
            $("incluirFederais").checked = tarifas.is_inclui_impostos_federais;

            //é necessário o total da prestação parcial para comparar com o valor minimo.
            var seguroX = parseFloat(getFreteValor($("valorMercadoria").value,
            tarifas.percentual_advalorem,
            tarifas.percentual_nf,
            tarifas.base_nf_percentual,
            tarifas.valor_percentual_nf,
            $("tipofrete").value,
            'p',
            tarifas.formula_seguro, tarifas.formula_percentual,
            $('peso').value,
            $('volumes').value, '0', $('distancia_km').value, $('tip').value, 
            tarifas.is_considerar_maior_peso,$("base").value,$("metro").value,
            false,0, $('qtdEntregas').value,$("tipoTransporte_tipo").value,
            tarifas.tipo_inclusao_icms, $('aliquota').value, true, $("tipo_arredondamento_peso").value,
            (jQuery("#clientepagador").val() == 'r' ? "0" : (jQuery("#clientepagador").val() == 'd' ? "1" : "2")), 
            undefined, undefined));
            var totalPrestacao = parseFloat($("taxaFixaTotal").value) +parseFloat($("valor_itr").value) +
                parseFloat($("valor_ademe").value) + parseFloat($("valor_peso").value) +
                parseFloat($("valor_frete").value) + parseFloat($("valor_sec_cat").value) + 
                parseFloat($("valor_outros").value) + parseFloat($("valor_gris").value) +
                parseFloat($("valor_despacho").value) + parseFloat($("valor_pedagio").value) -
                (parseFloat($("percentual_desconto").value ) > 0 && $("tipoTransporte_tipo").value == "a"? (parseFloat($("percentual_desconto").value) * (parseFloat($("isDescAdvalorem").checked?$("valor_frete").value:0)+parseFloat($("isDescFreteNacional").checked?$("valor_peso").value:0)))/100 :parseFloat($("valor_desconto").value));
                
            totalPrestacao = (tarifas.is_desconsidera_taxa_minimo ? totalPrestacao - parseFloat($("taxaFixaTotal").value) : totalPrestacao);
            totalPrestacao = (tarifas.is_desconsidera_despacho_minimo ? totalPrestacao - parseFloat($("valor_despacho").value) : totalPrestacao);
            totalPrestacao = (tarifas.is_desconsidera_seccat_minimo ? totalPrestacao - parseFloat($("valor_sec_cat").value) : totalPrestacao);
            totalPrestacao = (tarifas.is_desconsidera_outros_minimo ? totalPrestacao - parseFloat($("valor_outros").value) : totalPrestacao);
            totalPrestacao = (tarifas.is_desconsidera_gris_minimo ? totalPrestacao - parseFloat($("valor_gris").value) : totalPrestacao);
            totalPrestacao = (tarifas.is_desconsidera_pedagio_minimo ? totalPrestacao - parseFloat($("valor_pedagio").value) : totalPrestacao);
            totalPrestacao = (tarifas.is_desconsidera_seguro_minimo ? totalPrestacao - seguroX : totalPrestacao);
            
            
            if (tarifas.is_considerar_valor_maior_peso_nota && ($('tipofrete').value == "0" || $('tipofrete').value == "1" || $('tipofrete').value == "2")) {
                var mTpFrete = getTipoPreferencialPesoPercentualNotaFiscal($("peso").value,
                                    $("volumes").value,$("tipofrete").value,
                                    tarifas.valor_peso,tarifas.valor_volume,
                                    $("base").value,$("metro").value,
                                    tarifas.valor_veiculo, tarifas.valor_por_faixa,
                                    $("tipoTransporte_tipo").value, tarifas.valor_excedente_aereo ,
                                    tarifas.valor_excedente, tarifas.maximo_peso_final,
                                    tarifas.ispreco_tonelada, tarifas.tipo_frete_peso,
                                    tarifas.valor_maximo_peso_final, tarifas.valor_km,
                                    tarifas.is_considerar_maior_peso, tarifas.tipo_impressao_percentual,
                                    $("valorMercadoria").value, tarifas.base_nf_percentual,
                                    tarifas.valor_percentual_nf, tarifas.percentual_nf,
                                    $("qtdPallet").value, $("distancia_km").value,
                                    tarifas.formula_volumes, $('tip').value,
                                    tarifas.formula_percentual, tarifas.valor_pallet,
                                    tarifas.formula_pallet,false,0, $('qtdEntregas').value,
                                    tarifas.formula_frete_peso, tarifas.tipo_inclusao_icms,
                                    $('aliquota').value, false, $("tipo_arredondamento_peso").value,
                                    
                                    ($("idconsignatario").value == $("idremetente").value ? "CIF" : 
                                            ($("idconsignatario").value == $("iddestinatario").value ? "FOB" : "CON")), undefined, undefined);
                                    
                if (mTpFrete != $('tipofrete').value) {
                    $('tipofrete').value = mTpFrete;
                    alteraTipoTaxa(valida);
                    return null;
                }
            }
            
            if (isFreteMinimo(totalPrestacao,tarifas.valor_frete_minimo, tarifas.formula_minimo, $('tipofrete').value, $('peso').value, $('valorMercadoria').value, 
            $('volumes').value, '0', $('distancia_km').value, $('tip').value, tarifas.is_considerar_maior_peso,$("base").value,$("metro").value, $('qtdEntregas').value,
            $("tipoTransporte_tipo").value, tarifas.tipo_inclusao_icms, $("aliquota").value, tarifas.is_desconsidera_icms_minimo,
            (jQuery("#clientepagador").val() == 'r' ? "0" : (jQuery("#clientepagador").val() == 'd' ? "1" : "2")), undefined, undefined)){
                alert("O total do frete é menor que o mínimo, prevalecerá o mínimo.");

                //ASSUMINDO O VALOR MINIMO
                //primeira linha
                if (!tarifas.is_desconsidera_taxa_minimo){
                    $("taxaFixa").value = "0.00";
                    $("taxaFixaTotal").value = "0.00";
                }
                    
                
                $("valor_itr").value = "0.00";
                if (!tarifas.is_desconsidera_despacho_minimo){
                    $("valor_despacho").value = "0.00";
                }
                     
                $("valor_ademe").value = "0.00";
                $("valor_peso").value = "0.00";
                var vlMinimoOrcamento = getFreteMinimo(tarifas.valor_frete_minimo, tarifas.formula_minimo, $('tipofrete').value, $('peso').value, $('valorMercadoria').value, $('volumes').value, '0', $('distancia_km').value, $('tip').value, tarifas.is_considerar_maior_peso,$("base").value,$("metro").value, $('qtdEntregas').value,$("tipoTransporte_tipo").value, tarifas.is_desconsidera_icms_minimo, tarifas.tipo_inclusao_icms, $('aliquota').value, $("tipo_arredondamento_peso").value, (jQuery("#clientepagador").val() == 'r' ? "0" : (jQuery("#clientepagador").val() == 'd' ? "1" : "2")), undefined, undefined);
                if (!tarifas.is_desconsidera_seguro_minimo){
                    if (tarifas.tipo_impressao_frete_minimo == 'p'){
                        $("valor_peso").value = formatoMoeda(parseFloat(vlMinimoOrcamento));
                        $("valor_frete").value = formatoMoeda((!tarifas.is_desconsidera_seguro_minimo ?  0: parseFloat(seguroX)));
                    }else{
                        $("valor_frete").value = formatoMoeda(parseFloat(vlMinimoOrcamento) + (!tarifas.is_desconsidera_seguro_minimo ?  0: parseFloat(seguroX)));
                    }
                }else{
                    if (tarifas.tipo_impressao_frete_minimo == 'p'){
                        $("valor_peso").value = formatoMoeda(parseFloat(vlMinimoOrcamento));
                        $("valor_frete").value = formatoMoeda(parseFloat((!tarifas.is_desconsidera_seguro_minimo ?  0: parseFloat(seguroX))));
                    }else{
                        $("valor_frete").value = formatoMoeda(parseFloat(vlMinimoOrcamento) + (!tarifas.is_desconsidera_seguro_minimo ?  0: parseFloat(seguroX)));
                    }
                }  
                //segunda linha
                if (!tarifas.is_desconsidera_seccat_minimo){
                    $("valor_sec_cat").value = "0.00";
                }
                if (!tarifas.is_desconsidera_outros_minimo) {
                    $("valor_outros").value = "0.00";
                }
                if (!tarifas.is_desconsidera_gris_minimo){
                    $("valor_gris").value = "0.00";
                }
                if (!tarifas.is_desconsidera_pedagio_minimo){
                    $("valor_pedagio").value = "0.00";
                }
                $("valor_desconto").value = "0.00";
                //novos
                $("base").value ='0';

                if (tarifas.is_desconsidera_icms_minimo){ //check no cadastro da tabela 'Desconsiderar inclusão de ICMS em caso de frete'
                    $("incluirIcms").checked = false;
                    $("incluirFederais").checked = false;
                }
            } //isFreteMinimo
             
            
            recalculaCubagens();
            recalculaCubagens();
            calculaFrete();
            validaTipoTransporte();
            redespTxOrigem();
            redespTxDestino();
            pesoReal = 0;
            return false;
        }//funcao e()

        /*** Bloco de instrucoes ***/
        if (pesoReal == 0){
            if($("tipofrete").value == "1"){
                pesoReal = $("pesoKgCubado").value;
            }else{
                pesoReal = $("peso").value;
            }
        }

        if(<%=alteraTipoFrete%>){
                $("tipofrete").disabled = false;
        }else{
                $("tipofrete").disabled = true;
        }
        $("tabelaId").value = "";

        var utiliza = false;
    
            if(($("utilizaTipoFreteTabelaConsig").value == 't' || $("utilizaTipoFreteTabelaConsig").value == 'true')){
                utiliza = true;
            }

        if($("tipofrete").value != "5" &&
            ($("cid_id_origem").value == "0" || $("idcidadedestino").value == "0") ||
            ($("tipofrete").value == "-1" && !utiliza)){
            limparComposicaoFrete();
            return false;
        }
        
        var tipo = $("clientepagador").value;
        var rzsTipo = (tipo === "r" ? "rem_rzs" : (tipo === "d" ? "dest_rzs" : "con_rzs")); // remetente / destinatario / consignatario
        if ((tipo === "r" && $("idremetente").value === "0") ||
            (tipo === "d" && $("iddestinatario").value === "0") ||
            (tipo === "c" && $("idconsignatario").value === "0")) {
//                limparComposicaoFrete();
//                return false;            
        }
        
        if ($("tipofrete").value == "5" && $("tip").value == "0"){
            limparComposicaoFrete();
            return false;            
        }
        
        

        espereEnviar("",true);
        var clienteTabelaId = 0;
        //($('clientepagador').value == 'd' ? $('iddestinatario').value : $('idremetente').value)
        switch($('clientepagador').value){
            case "r":
                clienteTabelaId = $('idremetente').value;
                break;
            case "d":
                clienteTabelaId = $('iddestinatario').value;
                break;
            case "c":
                clienteTabelaId = $('idconsignatario').value;
                break;
        }

        tryRequestToServer(function(){
            new Ajax.Request("./ConhecimentoControlador?acao=carregar_taxascli"+
                    "&idconsignatario="+clienteTabelaId+
                    "&idcidadeorigem="+$("cid_id_origem").value+
                    "&idcidadedestino="+$("idcidadedestino").value+
                    "&tipoveiculo="+$("tip").value+
                    "&tipoproduto="+$("tipoproduto").value+
                    "&distancia_km="+$("distancia_km").value+
                    "&dtemissao="+$("dtemissao").value+
                    "&idremetente="+$("idremetente").value+
                    "&con_tabela_remetente="+$("con_tabela_remetente").value+
                    "&peso="+pesoReal+
                    "&idTaxa="+$('tipofrete').value+
                    "&idDestinatario="+$("iddestinatario").value+
                    "&tipoTransporte="+$("tipoTransporte_tipo").value,//na chamada antiga era informado r como padrao.
            {method:'post',
                onSuccess: e});
        });
        } catch (e) {
            console.log(e);
        }
    }// alteraTipoTaxa()


    //Todas as vezes que for atribuido um representante coleta ou entrega
    //o valor depois de processada é atribuida ao campo destinado abaixo
    function atribuirDistancia(distancia,coletaEntrega){
        var distancia = distancia;
        if(coletaEntrega == 'coleta'){
            $("distancia_coleta").value = distancia;
        }else 
            if(coletaEntrega == 'entrega'){
            $("distancia_entrega").value = distancia;
        }
    }
    
    /*se o representante tiver tabela de preco para a area especificada 
      a taxa de origem ou de destino vai receber o valor 
      da tabela de preço do representante  */
    var distanciaColeta;
    
    function redespTxOrigem(){
        
        distanciaColeta = $("distancia_coleta").value;
        
        if($("tipoTransporte_tipo").value == "a"){
            function e(transport){
                var textoresposta = transport.responseText;
                if (textoresposta == "load=0") {
                    return false;
                }
                tbPrecoredespOrigem = jQuery.parseJSON(textoresposta,function(key, value){
       
                    var type;
            
                    if (value && typeof value === 'object') {
                        type = value.type;
                        if (typeof type === 'string' && typeof window[type] === 'function') {
                            return new (window[type])(value);
                        }
                    }

                    return value;
                });
                /*tbPrecoredespOrigem.vlfreteminimo
                 *tbPrecoredespOrigem.vlkgate -> vl ate ___ kg
                 *tbPrecoredespOrigem.vlsobpeso ->excedente sob peso
                 *tbPrecoredespOrigem.vlprecofaixa ->cobrar
                 **/
                var taxaFixa = 0.00;
                var valorPercentual = 0.00;
                $("distancia_coleta").value = tbPrecoredespOrigem.distanciaColeta;            
                if(tbPrecoredespOrigem.tipotaxa == "2"){
                    //se a tabela for % Frete...
                    var freteNacional =$("valor_peso").value;
                    //valor do calculo= (frete nacional x valor do frete na tabela de preco)/100 + valor Fixo da tabela
                    valorPercentual = ((freteNacional * tbPrecoredespOrigem.vlsobfrete)/100+tbPrecoredespOrigem.vlTaxaFixa);                    
                    taxaFixa = (valorPercentual > tbPrecoredespOrigem.vlfreteminimo)?valorPercentual:tbPrecoredespOrigem.vlfreteminimo;
                 
                }else if(tbPrecoredespOrigem.tipotaxa == "5"){
                    //se a tabela for por KM...
                    var distancia = $("distancia_coleta").value;
                    //valor do calculo= (valor de KM da tabela x distancia vinda da coleta) + valor fixo da tabela
                    var valorCobrar = ((tbPrecoredespOrigem.vlsobkm * distancia)+tbPrecoredespOrigem.vlTaxaFixa);
                    taxaFixa = (valorCobrar > tbPrecoredespOrigem.vlfreteminimo)?valorCobrar:tbPrecoredespOrigem.vlfreteminimo;
                }else{
                    //se a tabela for por peso...
                    var peso = $("peso").value;
                    
                    //km do tipo peso
                    var distancia = $("distancia_coleta").value;
                    var valorKM = (tbPrecoredespOrigem.vlsobkm * distancia);
                    //calculo
                    var valorCobrar = (((peso  - tbPrecoredespOrigem.vlkgate)>0)?
                        ((peso  - tbPrecoredespOrigem.vlkgate)*tbPrecoredespOrigem.vlsobpeso)+tbPrecoredespOrigem.vlprecofaixa:
                        tbPrecoredespOrigem.vlprecofaixa)+valorKM+tbPrecoredespOrigem.vlTaxaFixa;
                  
                    taxaFixa = (valorCobrar > tbPrecoredespOrigem.vlfreteminimo)?valorCobrar:tbPrecoredespOrigem.vlfreteminimo;
                }
                 
                $("taxaFixa").value = formatoMoeda(taxaFixa); 
                calculataxaFixaTotal($("qtdEntregas").value);
                atribuirDistancia(distanciaColeta,'coleta');
            }
                
            tryRequestToServer(function(){
                new Ajax.Request("./cadorcamento.jsp?acao=carregar_taxasRedespOrigem&"+
                    concatFieldValue("idredespachanteColeta,cid_id_origem,idfilial,aeroportoColetaId"),{method:'post',onSuccess: e});//
            }); 
            
            
        }else{
            return false;
        }
        
    }
    
    var distanciaEntrada;
    
    function redespTxDestino(){
        
        distanciaEntrada = $("distancia_entrega").value;
        
        if($("tipoTransporte_tipo").value == "a"){
            function e(transport){
                var textoresposta = transport.responseText;
                if (textoresposta == "load=0") {
                    return false;
                }
                tbPrecoredespDestino = jQuery.parseJSON(textoresposta,function(key, value){

                    var type;

                    if (value && typeof value === 'object') {
                        type = value.type;
                        if (typeof type === 'string' && typeof window[type] === 'function') {
                            return new (window[type])(value);
                        }
                    }

                    return value;
                });
                
                $("distancia_entrega").value = tbPrecoredespDestino.distanciaEntrega;
                var taxaFixaDestino = 0.00;
                var valorPercentual = 0.00;
                if(tbPrecoredespDestino.tipotaxa == "2"){
                    //se a tabela for por % frete...
                    var freteNacional =$("valor_peso").value;
                    //valor do calculo= ((frete nacional x valor do frete na tabela de preco)/100) + valor Fixo da tabela
                    valorPercentual = ((freteNacional * tbPrecoredespDestino.vlsobfrete)/100)+tbPrecoredespDestino.vlTaxaFixa;
                    taxaFixaDestino = (valorPercentual > tbPrecoredespDestino.vlfreteminimo)?valorPercentual:tbPrecoredespDestino.vlfreteminimo;

                }else if(tbPrecoredespDestino.tipotaxa == "5"){
                    //se a tabela for por KM...
                    var distancia = $("distancia_entrega").value;
                    //valor do calculo= (valor de KM da tabela x distancia vinda da entrega) + valor fixo da tabela
                    var valorCobrar = ((tbPrecoredespDestino.vlsobkm * distancia)+tbPrecoredespDestino.vlTaxaFixa);
                    taxaFixaDestino = (valorCobrar > tbPrecoredespDestino.vlfreteminimo)?valorCobrar:tbPrecoredespDestino.vlfreteminimo;
                }else{
                    //se a tabela for por peso...
                    var peso = $("peso").value;
                    //valor por km do tipo peso
                    var distancia = $("distancia_entrega").value;
                    var valorKM = (tbPrecoredespDestino.vlsobkm * distancia);
                    //calculo
                    var valorCobrar = (((peso  - tbPrecoredespDestino.vlkgate)>0)?
                        ((peso  - tbPrecoredespDestino.vlkgate)*tbPrecoredespDestino.vlsobpeso)+tbPrecoredespDestino.vlprecofaixa:
                        tbPrecoredespDestino.vlprecofaixa)+valorKM+tbPrecoredespDestino.vlTaxaFixa;

                    taxaFixaDestino = (valorCobrar > tbPrecoredespDestino.vlfreteminimo)?valorCobrar:tbPrecoredespDestino.vlfreteminimo;
                    calculataxaFixaTotal($("qtdEntregas").value);
                }             
                $("valor_sec_cat").value = formatoMoeda(taxaFixaDestino);
                calculaFrete();
                atribuirDistancia(distanciaEntrada, 'entrega');
            }
    

            if (parseFloat($("idredespachanteEntrega").value) > 0){
                tryRequestToServer(function(){
                    new Ajax.Request("./cadorcamento.jsp?acao=carregar_taxasRedespDestino&"+
                        concatFieldValue("idredespachanteEntrega,idcidadedestino,aeroportoEntregaId"),{method:'post',onSuccess: e});
                });
            }
            
        }else{
            return false;
        }
    }
    
    
    /* function getDistanciaColeta(){
         tryRequestToServer(function(){
                new Ajax.Request("./cadorcamento.jsp?acao=getDistanciaColeta&"+
                    concatFieldValue("idredespachanteEntrega,idcidadedestino"),{method:'post',onSuccess: e});
         });
    }*/
    
    function limpaVendedor(){
        getObj("idvendedor").value = "0";
        getObj("ven_rzs").value = "";
    }
    
    function limpaConsignatario(){
        getObj("idconsignatario").value = "0";
        getObj("con_codigo").value = "0";
        getObj("con_cnpj").value = "";
        getObj("con_rzs").value = "";
    }

    function alteraStatus(valor){
        valor = parseInt(valor, 10);
        if (valor == 2){
            $("divMotivo").style.display = "";
            $("lbMotivo").style.display = "";
        }else{
            $("divMotivo").style.display = "none";
            $("lbMotivo").style.display = "none";
        }
        if (valor != 1) {
            invisivel($("trIsFinalizarOrcamento"));
            $("isFinalizaOrcamento").checked = false;
        }
        alteraTransporte($("tipoCarga").value);
        
    }
    
    function permissaoAprovarOrcamento(){
        if (<%=aprovarOrcamento%> == 0){
            $("status").disabled = "false";
        }
    }
    
    
    
    function removerServicoAjax(nameObj, index, nameObj2) {
    
        var descricao = $("servico"+index).value;
        var idServico = $("id"+index).value;
        var idOrcamento = $("idorcamento").value;
        
            if(confirm("Deseja excluir o Serviço "+descricao+" ?")){
                if(confirm("Tem certeza?")){
                    if (idOrcamento != 0) {
                   
                    new Ajax.Request("./cadorcamento.jsp?acao=removerServico&idServico=" + idServico + "&idOrcamento=" + idOrcamento ,
                        {
                            method:'get',
                            onSuccess: function(){ Element.remove(nameObj);Element.remove($(nameObj2)); alert('Item removido com sucesso!') },
                            onFailure: function(){ alert('Erro ao excluir...') }
                            });
        
                    }else{
                        Element.remove(nameObj);
                        Element.remove($(nameObj2));
                    }
                    }
                    }
                    }
    
    
    function alteraTransporte(valor){
        if (valor=="v"){
            $("propVeiculo").style.display = "";
           
        }else{
            $("propVeiculo").style.display = "none";
            
        }
        
          var permissao = <%=(Apoio.getUsuario(request).getAcesso("cadfinalizaorcamento") > 3) %>;
        
          $("valorMercadoria").readOnly = false;
          $("metro").readOnly = false;
          $("resumoMudancaTitulo").style.display = "none";
          $("resumoMudancaCorpo").style.display = "none";
          invisivel($("trIsFinalizarOrcamento"));
        
      if(valor=="m"){
          $("valorMercadoria").readOnly = true;
          $("metro").readOnly = true;
          $("resumoMudancaTitulo").style.display = "";
          $("resumoMudancaCorpo").style.display = "";
          if (permissao && parseInt($("status").value, 10) == 1) {
              visivel($("trIsFinalizarOrcamento"));
          }
          
      }else{
          
        }          
    }
    
    var arAbasGenerico = new Array();
    arAbasGenerico[0] = new stAba('tdAba_1','tab1');
    arAbasGenerico[1] = new stAba('tdAba_2','tab2');
    arAbasGenerico[2] = new stAba('tdAba_3','tab3');
    arAbasGenerico[3] = new stAba('tdAba_4','tab4');
    arAbasGenerico[4] = new stAba('tdAba_5','tab5');

    //  -- inicio localiza rematente pelo codigo
    function localizaRemetenteCodigo(campo, valor){

        //objeto funcao usado na requisicao Ajax(uma espécie de evento)
        function e(transport){
            var resp = transport.responseText;
            espereEnviar("",false);
            //se deu algum erro na requisicao...
            if (resp == 'null'){
                alert('Erro ao localizar cliente.');
                return false;
            }else if (resp == 'INA'){
                $('idremetente').value = '0';
                $('rem_codigo').value = '';
                $('rem_rzs').value = '';
                $('rem_cidade').value = '';
                $('rem_uf').value = '';
                $('rem_cnpj').value = '';
                $('rem_email').value = '';
                $('remtabelaproduto').value = 'f';
                alert('Cliente inativo.');
                $("rem_tipo_tributacao").value = "NI";
                return false;
            }else if(resp == ''){
                $('idremetente').value = '0';
                $('rem_codigo').value = '';
                $('rem_rzs').value = '';
                $('rem_cidade').value = '';
                $('rem_uf').value = '';
                $('rem_cnpj').value = '';
                $('rem_email').value = '';
                $('remtabelaproduto').value = 'f';
                $("rem_tipo_tributacao").value = "NI";

                if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")){
                    window.open('./cadcliente?acao=iniciar','Cliente','top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                }
                return false;
            }else{
                var cliControl = eval('('+resp+')');

                $('idremetente').value = cliControl.idcliente;
                $('rem_codigo').value = cliControl.idcliente;
                $('rem_rzs').value = cliControl.razao;
                $('rem_cnpj').value = cliControl.cnpj;
                
                var filial  = $("idfilial").value;

                if (cliControl.tipo_origem_frete == "f"  && $("cidadeFilial_"+filial) != null){
                    var idCidadeFl = ($("cidadeFilial_"+filial).value).split("!!")[0];
                    var cidadeFl = ($("cidadeFilial_"+filial).value).split("!!")[1];
                    var ufFl = ($("cidadeFilial_"+filial).value).split("!!")[2];

                    $("cid_id_origem").value = idCidadeFl;
                    $('cid_nome_origem').value = cidadeFl;
                    $('cid_uf_origem').value = ufFl;

                }else{

                    $("cid_id_origem").value = cliControl.idcidade;
                    $('cid_nome_origem').value = cliControl.cidade;
                    $('cid_uf_origem').value = cliControl.uf;
                }

                $("endereco_col").value = cliControl.endereco_col;
                $("bairro_col").value = cliControl.bairro_col;
                $('cid_nome_coleta').value = cliControl.cidade_col;
                $('cid_uf_coleta').value =cliControl.uf_col;
                $("cid_id_coleta").value = cliControl.idcidade_col;
                $("idvendedor").value = cliControl.idvendedor;
                $("ven_rzs").value = cliControl.vendedor;

                $("idcidadeorigem").value = cliControl.idcidade;

                $("rem_tipotaxa").value = cliControl.tipotaxa;
                $("rem_tabela_remetente").value = cliControl.tipo_tabela_remetente;
                $("tipofrete").value = cliControl.tipotaxa;
                $("rem_email").value = cliControl.email;
                $('remtabelaproduto').value = cliControl.is_tabela_apenas_produto;
                $('remtipofpag').value = cliControl.tipofpag;
                $('rem_pgt').value = cliControl.pgt;
                $('fone').value = cliControl.fone;
                $('contato_orcamento').value = cliControl.contato_orcamento;
                $("utilizaTipoFreteTabelaRem").value = cliControl.is_utilizar_tipo_frete_tabela;
                
                $('idconsignatario').value = cliControl.idcliente;
                $('con_codigo').value = cliControl.idcliente;
                $('con_rzs').value = cliControl.razao;
                $('con_cnpj').value = cliControl.cnpj;
                $('tipofpag').value = cliControl.tipofpag;
                $('con_pgt').value = cliControl.pgt;
                $('con_email').value = cliControl.email;
                $('contato_consignatario').value = cliControl.contato_orcamento;
                $('fone_consignatario').value = cliControl.fone;
                $("utilizaTipoFreteTabelaConsig").value = cliControl.is_utilizar_tipo_frete_tabela;
                $("con_tipotaxa").value = cliControl.tipotaxa;
                $("con_tabela_remetente").value = cliControl.tipo_tabela_remetente;
                
                $("idvenremetente").value = cliControl.idvendedor;
                $("venremetente").value = cliControl.vendedor;
                
                $("tipo_arredondamento_peso_rem").value = cliControl.tipo_arredondamento_peso;
                $("rem_tipo_tributacao").value = cliControl.tipo_tributacao;
                
                
                getTipoProdutos();
                getCondicaoPagto();
                localizarTipoProdutoGenerico($('idremetente').value);
                mudarCifFob();
            }
        }//funcao e()

        if (valor != ''){
            espereEnviar("",true);
            tryRequestToServer(function(){
                new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor="+valor+"&idfilial=0&campo="+campo,{method:'post', onSuccess: e, onError: e});
            });
        }
    }
  
    //  -- inicio localiza consignatário pelo codigo
    function localizaConsignatarioCodigo(campo, valor){
        try{
        //objeto funcao usado na requisicao Ajax(uma espécie de evento)
        function e(transport){
            var resp = transport.responseText;
            espereEnviar("",false);
            //se deu algum erro na requisicao...
            if (resp == 'null'){
                alert('Erro ao localizar consignatario.');
                return false;
            }else if (resp == 'INA'){
                $('idconsignatario').value = '0';
                $('con_codigo').value = '';
                $('con_rzs').value = '';
                $('con_cnpj').value = '';
                $('con_email').value = '';
                $("con_tipo_tributacao").value = "NI";
                alert('Consignatário inativo.');
                return false;
            }else if(resp == ''){
                $('idconsignatario').value = '0';
                $('con_codigo').value = '';
                $('con_rzs').value = '';
                $('con_cnpj').value = '';
                $('con_email').value = '';
                $("con_tipo_tributacao").value = "NI";
	
                if (confirm("Consignatário não encontrado, deseja cadastrá-lo agora?")){
                    window.open('./cadcliente?acao=iniciar','Consignatário','top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                }
                return false;
            }else{
                var cliControl = eval('('+resp+')');
                     
                $('idconsignatario').value = cliControl.idcliente;
                $('con_codigo').value = cliControl.idcliente;
                $('con_rzs').value = cliControl.razao;
                $('con_cnpj').value = cliControl.cnpj;
                $('tipofpag').value = cliControl.tipofpag;
                $('con_pgt').value = cliControl.pgt;
                $('con_email').value = cliControl.email;
                $('contato_consignatario').value = cliControl.contato_orcamento;
                $('fone_consignatario').value = cliControl.fone;
                $("utilizaTipoFreteTabelaConsig").value = cliControl.is_utilizar_tipo_frete_tabela;
                $("con_tipotaxa").value = cliControl.tipotaxa;
                $("con_tabela_remetente").value = cliControl.tipo_tabela_remetente;
                $('contabelaproduto').value = cliControl.is_tabela_apenas_produto;
                $("idconvendedor").value = cliControl.idvendedor;
                $("con_vendedor").value = cliControl.vendedor;
                $("tipo_arredondamento_peso_con").value = cliControl.tipo_arredondamento_peso;
                $("con_tipo_tributacao").value = cliControl.tipo_tributacao;
                
                getCondicaoPagto();
                mudarCifFob();
                getTipoProdutos();
            }
        }//funcao e()

        if (valor != ''){
            espereEnviar("",true);
            tryRequestToServer(function(){
                new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor="+valor+"&idfilial=0&campo="+campo,{method:'post', onSuccess: e, onError: e});
            });
        }
        }catch(e){
            console.log(e);
        }
    }
    
    //criação do obj para o DOM
    function embalagens(idEmbalagem, descEmbalagem, valorEmbalagem){
    this.idEmbalagem = (idEmbalagem != null || idEmbalagem != undefined ? idEmbalagem : 0);
    this.descEmbalagem = (descEmbalagem != null || descEmbalagem != undefined ? descEmbalagem : "");
    this.valorEmbalagem = (valorEmbalagem != null || valorEmbalagem != undefined ? valorEmbalagem : 0);
    }
    
    function ProdutosMudanca(idProdutos,codProdutos, descProdutos, metroProdutos, valorProdutos, quantProdutos, idOrcamento, idOrcProduto, pesoBruto){
    this.idProdutos = (idProdutos != undefined || idProdutos != null ? idProdutos : 0);
    this.idOrcamento = (idOrcamento != undefined || idOrcamento != null ? idOrcamento : 0);
    this.idOrcProduto = (idOrcProduto != undefined || idOrcProduto != null ? idOrcProduto : 0);
    this.codProdutos = (codProdutos != undefined  || codProdutos  != null ? codProdutos : "");
    this.descProdutos = (descProdutos != undefined || descProdutos  != null ? descProdutos : "");
    this.metroProdutos = (metroProdutos != undefined || metroProdutos  != null ? metroProdutos : 0);
    this.valorProdutos = (valorProdutos != undefined || valorProdutos  != null ? valorProdutos : 0);
    this.quantProdutos = (quantProdutos != undefined || quantProdutos  != null ? quantProdutos : 0);
    this.pesoBruto = (pesoBruto != undefined || pesoBruto != null ? pesoBruto : 0);
    }
    var countProdutosMudanca = 0;
    
    function limparProdutosMudanca(valor){
    $("codProduto_"+valor).value = 0;
    $("idOrcProduto_"+valor).value = 0;
    $("idProduto_"+valor).value = 0;
    $("idOrcamento_"+valor).value = 0;
    $("descProduto_"+valor).value = "";
    $("quantProduto_"+valor).value = 0;
    $("metroProduto_"+valor).value = 0;
    $("valorProduto_"+valor).value = 0;
    $("valorTotalProduto_"+valor).value = 0;
    $("pesoBruto_" + valor).value = 0;
    depoisDoLocalizar(valor);
    }
    
    //função para localizar o produto
    function localizaProduto(valor){
        post_cad = window.open('./localiza?acao=consultar&idlista=50&paramaux=cliente_id&paramaux2=pd.destinatario_id','Produto',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
        $("indexProduto").value = valor;
        //aoClicarNoLocaliza("Produto");
    }
    
    function excluir(index){
            
       
        var descricao = $("descProduto_"+index).value;
        var idProduto = $("idProduto_"+index).value;
        var idOrcamento = $("idOrcamento_"+index).value;
        
            if(confirm("Deseja excluir o Produto \'"+descricao+"\'?")){
                if(confirm("Tem certeza?")){
                    if (idProduto != 0 && idOrcamento != 0) {
                        new Ajax.Request("./cadorcamento.jsp?acao=excluirProduto&idProduto="+idProduto+"&modulo=gwFrota&idOrcamento=" + idOrcamento  ,
                        {
                            method:'get', 
                            onSuccess: function(){ 
                                alert('Item removido com sucesso!')
//                                $("max").value--;
                                Element.remove(("idLinha_"+index)); 
//                                countProdutosMudanca--;
                                depoisDoLocalizar(countProdutosMudanca);
                                
                            },
                            onFailure: function(){ alert('Erro ao excluir...') }
                        });    
                    }else{
                        Element.remove(("idLinha_"+index));
//                        countProdutosMudanca--;
                        depoisDoLocalizar(countProdutosMudanca);
//                        $("max").value--;
//                        countProdutosMudanca--;
                    }
                }
            }
            
    }
//funcão de criação das linhas e colunas do DOM de produtos
    function addProdutosMudanca(produtosMudanca){
       
        if(produtosMudanca == null || produtosMudanca == undefined){
            produtosMudanca = new ProdutosMudanca();
        }
     countProdutosMudanca++;
    
        var homePath = '${homePath}';
        var tabelaBase = $("itensMudanca");

        var tr =  Builder.node("tr" , {
        className:"CelulaZebra2",
        id:"idLinha_" + countProdutosMudanca,
        name:"idLinha_"+ countProdutosMudanca});
    
        
        var td0 = Builder.node ("td", {
        width : "14%",
        align:"center"});

        var td1 = Builder.node ("td", {
        width : "30%",
        align:"center"});

        var td2 = Builder.node ("td", {
        width : "11%",   
        align:"center"});

        var td3 = Builder.node ("td", {
        width : "11%",
        align:"center"});

        var td4 = Builder.node ("td", {
        width : "11%",
        align:"center"});

        var td5 = Builder.node ("td", {
        width : "11%",
        align:"center"});

        var td6 = Builder.node ("td", {
        width : "11%",
        align:"center"});
        
        var tdvazia = Builder.node("td", {
        width : "1%",
        align:"center"});
    
        
        //inicio de hiddens
        var idProdutos = Builder.node("input", {
        type : "hidden",
        name : "idProduto_"+ countProdutosMudanca,
        id   : "idProduto_"+ countProdutosMudanca,
        value: produtosMudanca.idProdutos});
        
        var idOrcamento = Builder.node("input", {
        type : "hidden",
        name : "idOrcamento_"+ countProdutosMudanca,
        id   : "idOrcamento_"+ countProdutosMudanca,
        value: produtosMudanca.idOrcamento});
    
        var idOrcProduto = Builder.node("input", {
        type : "hidden",
        name : "idOrcProduto_"+ countProdutosMudanca,
        id   : "idOrcProduto_"+ countProdutosMudanca,
        value: produtosMudanca.idOrcProduto});
        //fim hiddens

        //inicio informacoes do produto
        var codProdutos = Builder.node("input", {
        type : "text",
        className:"fieldMin",
        name : "codProduto_"+ countProdutosMudanca,
        id   : "codProduto_"+ countProdutosMudanca,
        maxlength : 10,
        size : 10,
        value: produtosMudanca.codProdutos});
        readOnly(codProdutos);

        var descProdutos = Builder.node("input", {
        type : "text",
        className:"fieldMin",
        name : "descProduto_"+ countProdutosMudanca,
        id   : "descProduto_"+ countProdutosMudanca,
        size : 30,
        maxlength : 20,
        value: produtosMudanca.descProdutos});
        readOnly(descProdutos);

        var metroProdutos = Builder.node("input", {
        type : "text",
        className:"fieldMin styleValor",
        name : "metroProduto_"+ countProdutosMudanca,
        id   : "metroProduto_"+ countProdutosMudanca,
        maxlength : 10,
        size : 10,
        onBlur : "depoisDoLocalizar("+countProdutosMudanca+")",
        onChange:"seNaoFloatReset(this,'0.00');",
        value: produtosMudanca.metroProdutos});

        var quantProdutos = Builder.node("input", {
        type : "text",
        className:"fieldMin styleValor",
        name : "quantProduto_"+ countProdutosMudanca,
        id   : "quantProduto_"+ countProdutosMudanca,
        maxlength : 10,
        size : 10,
        onBlur : "depoisDoLocalizar("+countProdutosMudanca+")",
        value: produtosMudanca.quantProdutos});

        var valorProdutos = Builder.node("input", {
        type : "text",
        className:"fieldMin styleValor",
        name : "valorProduto_"+ countProdutosMudanca,
        id   : "valorProduto_"+ countProdutosMudanca,
        maxlength : 10,
        size : 10,
        onBlur : "depoisDoLocalizar("+countProdutosMudanca+")",
        onChange:"seNaoFloatReset(this,'0.00');",
        value: produtosMudanca.valorProdutos});

        var valorTotalProdutos = Builder.node("input", {
        type : "text",
        className:"fieldMin styleValor",
        name : "valorTotalProduto_"+ countProdutosMudanca,
        id   : "valorTotalProduto_"+ countProdutosMudanca,
        maxLength : 10,
        size : 10,
        value : 0
        });
        readOnly(valorTotalProdutos, "inputReadOnly styleValor");
        //fim campos
        
        //inicio de botoes
        var pesquisarProdutos = Builder.node("input", {
        type : "button",
        className:"botoes",
        id   : "botaoProdutos_"+countProdutosMudanca,
        name : "botaoProdutos_"+countProdutosMudanca,
        onClick:"localizaProduto("+countProdutosMudanca+");",
        value : "..."});

        var borrachaProdutos = Builder.node("img" , {
            id: "borrachaProdutos" ,
            className:"imagemLink",
            src: "img/borracha.gif",
            onclick:"limparProdutosMudanca("+ countProdutosMudanca +");" });
        
        
        var lixeirinha = Builder.node("img",{
                    className:"imagemLink",
                    src: "img/lixo.png",
                    onclick:"excluir("+countProdutosMudanca+");"
                
                });
                
        //td Peso Bruto
        var pesoBruto = Builder.node("input", {
        type : "text",
        className:"fieldMin styleValor",
        name : "pesoBruto_"+ countProdutosMudanca,
        id   : "pesoBruto_"+ countProdutosMudanca,
        maxlength : 10,
        size : 10,
        onBlur : "depoisDoLocalizar("+countProdutosMudanca+")",
        onChange:"seNaoFloatReset(this,'0.00');",
        value: produtosMudanca.pesoBruto
        });
                
        //preenchendo as TD's com seus campos...
        tdvazia.appendChild(lixeirinha);    // icone lixo (primeira TD)
        td0.appendChild(codProdutos);       // codigo do produto (segunda TD)
        td0.appendChild(idProdutos);        // id do produto (segunda TD)
        td0.appendChild(idOrcamento);       // id do orcamento (segunda TD)
        td0.appendChild(idOrcProduto);      // id da tabela controle entre orcamento e produto (segunda TD)
        td1.appendChild(descProdutos);      // descricao (terceira TD)
        td1.appendChild(pesquisarProdutos); // icone de pesquisar (terceira TD)
        td1.appendChild(borrachaProdutos);  // icone de borracha (terceira TD)
        td2.appendChild(metroProdutos);     // campo metro do produto (quarta TD)
        td3.appendChild(valorProdutos);     // campo de valor do produto (setima TD)
        td4.appendChild(valorTotalProdutos);// campo de valor total (oitava TD)
        td5.appendChild(quantProdutos);     // campo de quantidade de produtos (sexta TD)
        td6.appendChild(pesoBruto);         //campo Peso Bruto (quinta TD)

        tr.appendChild(tdvazia);  //icone de excluir
        tr.appendChild(td0);      //codigo
        tr.appendChild(td1);      //desc + pesq + apagar
        tr.appendChild(td2);      //metro
        tr.appendChild(td6);      //Peso  
        tr.appendChild(td5);      //quantidade
        tr.appendChild(td3);      //valor
        tr.appendChild(td4);      //valorTotal
       
        
        tabelaBase.appendChild(tr);       
        $("max").value = countProdutosMudanca;
    }
    
    
    //  -- inicio localiza rematente pelo codigo
    function localizaDestinatarioCodigo(campo, valor){

        //objeto funcao usado na requisicao Ajax(uma espécie de evento)
        function e(transport){
            var resp = transport.responseText;
            espereEnviar("",false);
            //se deu algum erro na requisicao...
            if (resp == 'null'){
                alert('Erro ao localizar cliente.');
                return false;
            }else if (resp == 'INA'){
                $('iddestinatario').value = '0';
                $('des_codigo').value = '';
                $('dest_rzs').value = '';
                $('cid_destino').value = '';
                $('uf_destino').value = '';
                $('dest_cnpj').value = '';
                $('des_email').value = '';
                $('desttabelaproduto').value = 'f';
                $('dest_insc_est').value = '';
                $("dest_tipo_tributacao").value = "NI";
                alert('Cliente inativo.');
                return false;
            }else if(resp == ''){
                $('iddestinatario').value = '0';
                $('des_codigo').value = '';
                $('dest_rzs').value = '';
                $('cid_destino').value = '';
                $('uf_destino').value = '';
                $('dest_cnpj').value = '';
                $('des_email').value = '';
                //$('dest_tipotaxa').value = '-1';
                $("idcidadedestino").value = "0";
                $('des_inclui_tde').value = 'f';
                $('desttabelaproduto').value = 'f';
                $('dest_insc_est').value = '';
                $("dest_tipo_tributacao").value = "NI";
                        
                if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")){
                    window.open('./cadcliente?acao=iniciar','Cliente','top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                }
                return false;
            }else{
                var cliControl = eval('('+resp+')');
                $('iddestinatario').value = cliControl.idcliente;
                $('des_codigo').value = cliControl.idcliente;
                $('dest_rzs').value = cliControl.razao;
                $('dest_cidade').value = cliControl.cidade;
                $('dest_uf').value = cliControl.uf;
                $('dest_cnpj').value = cliControl.cnpj;
                $('dest_insc_est').value = cliControl.incricao_estadual;
                $("cidade_destino_id").value = cliControl.idcidade;
                $("des_email").value = cliControl.email;
                $("des_inclui_tde").value = cliControl.is_cobrar_tde;
                //$("aliquota").value = cliControl.aliquota;
                $('desttabelaproduto').value = cliControl.is_tabela_apenas_produto;
                $('desttipofpag').value = cliControl.tipofpag;
                $('dest_pgt').value = cliControl.pgt;
                $('dest_fone').value = cliControl.fone;
                $('contato_destinatario').value = cliControl.contato_orcamento;
                $("utilizaTipoFreteTabelaDest").value = cliControl.is_utilizar_tipo_frete_tabela;
                $("dest_tipotaxa").value = cliControl.tipotaxa;
                $("des_tabela_remetente").value = cliControl.tipo_tabela_remetente;
                $("distancia_km").value = cliControl.distanciakm;
                $("idvendestinatario").value = cliControl.idvendedor;
                $("vendestinatario").value = cliControl.vendedor;
                $("tipo_arredondamento_peso_dest").value = cliControl.tipo_arredondamento_peso;
                $("dest_tipo_tributacao").value = cliControl.tipo_tributacao;
                
                
                aoClicarNoLocaliza("Destinatario");
            }
        }//funcao e()
        if ($("cid_uf_origem").value == ''){
            alert('Informe o remetente ou a cidade de origem corretamente.');
            return null;
        }else if (valor != ''){
            espereEnviar("",true);
            tryRequestToServer(function(){
                new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor="+valor+"&idfilial="+$('idfilial').value+"&campo="+campo+"&remUF="+$('cid_uf_origem').value+"&idcidadeorigem="+$('idcidadeorigem').value,{method:'post', onSuccess: e, onError: e});
            });
        }
    }

    function getCondicaoPagto(){
        if ($('clientepagador').value == 'r'){
            $('pagtoFrete').value = $('remtipofpag').value;
            $('condicaopgt').value = $('rem_pgt').value;
            $("utilizaTipoFreteTabelaConsig").value = $("utilizaTipoFreteTabelaRem").value;
            $("con_tabela_remetente").value = ($("rem_tabela_remetente").value);
            $("tipofrete").value = $("rem_tipotaxa").value;
            $("tipo_arredondamento_peso").value = $("tipo_arredondamento_peso_rem").value;
        }else if ($('clientepagador').value == 'd'){
            
            $("con_tabela_remetente").value = ($("des_tabela_remetente").value);
            $('pagtoFrete').value = $('desttipofpag').value;
            $('condicaopgt').value = $('dest_pgt').value;
            $("utilizaTipoFreteTabelaConsig").value = $("utilizaTipoFreteTabelaDest").value;
            $("tipofrete").value = $("dest_tipotaxa").value;
            $("tipo_arredondamento_peso").value = $("tipo_arredondamento_peso_dest").value;
        }else if ($('clientepagador').value == 'c'){
            $('pagtoFrete').value = $('tipofpag').value;
            $('condicaopgt').value = $('con_pgt').value;
            $("tipofrete").value = $("con_tipotaxa").value;
            $("tipo_arredondamento_peso").value = $("tipo_arredondamento_peso_con").value;
        }
        if ($("con_tabela_remetente").value != "n") {
            $("utilizaTipoFreteTabelaConsig").value = $("utilizaTipoFreteTabelaRem").value;
            $("con_tipotaxa").value = $("rem_tipotaxa").value;
            $("tipofrete").value = $("con_tipotaxa").value;
        }
        alteraTipoTaxa('N');
    }

    var countCubagem = 0;
    function addCubagem(volume, comprimento, largura, altura, metro){

        countCubagem++;
        $('trCubagem').style.display = "";

        var _tr1 = Builder.node("tr", {
            name: "trCubagem_" + countCubagem,
            id: "trCubagem_" + countCubagem,
            className: "CelulaZebra2"
        });
        //Excluir
        var _td1 = Builder.node("td", {});
        var _div1 = Builder.node("div", {
            align:"center"
        });
        var _ip1 = Builder.node("img", {
            src: "./img/lixo.png",
            onclick:"delCubagem('"+countCubagem+"');"
        });
        _div1.appendChild(_ip1);
        _td1.appendChild(_div1);

        //Volumes
        var _tdVolume = Builder.node("td");//novo elemento campo
        var _divVolume = Builder.node("div", {
            align:"right"
        });
        var _ipVolume = Builder.node("input", {
            name: "volume_" +  countCubagem,
            id: "volume_" +  countCubagem,
            type: "text",
            value: volume,
            size: "7",
            maxLenght: "12",
            className:"fieldMin",
            onChange:"seNaoFloatReset(this,'0.00');calculaCubagem('"+countCubagem+"')"
        });
        _divVolume.appendChild(_ipVolume);
        _tdVolume.appendChild(_divVolume);

        //Comprimento
        var _tdComprimento = Builder.node("td");//novo elemento campo
        var _divComprimento = Builder.node("div", {
            align:"right"
        });
        var _ipComprimento = Builder.node("input", {
            name: "comprimento_" +  countCubagem,
            id: "comprimento_" +  countCubagem,
            type: "text",
            value: comprimento,
            size: "7",
            maxLenght: "12",
            className:"fieldMin",
            onChange:"seNaoFloatReset(this,'0.00');calculaCubagem('"+countCubagem+"')"
        });
        _divComprimento.appendChild(_ipComprimento);
        _tdComprimento.appendChild(_divComprimento);

        //Largura
        var _tdLargura = Builder.node("td");//novo elemento campo
        var _divLargura = Builder.node("div", {
            align:"right"
        });
        var _ipLargura = Builder.node("input", {
            name: "largura_" +  countCubagem,
            id: "largura_" +  countCubagem,
            type: "text",
            value: largura,
            size: "7",
            maxLenght: "12",
            className:"fieldMin",
            onChange:"seNaoFloatReset(this,'0.00');calculaCubagem('"+countCubagem+"')"
        });
        _divLargura.appendChild(_ipLargura);
        _tdLargura.appendChild(_divLargura);

        //Altura
        var _tdAltura = Builder.node("td");//novo elemento campo
        var _divAltura = Builder.node("div", {
            align:"right"
        });
        var _ipAltura = Builder.node("input", {
            name: "altura_" +  countCubagem,
            id: "altura_" +  countCubagem,
            type: "text",
            value: altura,
            size: "7",
            maxLenght: "12",
            className:"fieldMin",
            onChange:"seNaoFloatReset(this,'0.00');calculaCubagem('"+countCubagem+"')"
        });
        _divAltura.appendChild(_ipAltura);
        _tdAltura.appendChild(_divAltura);

        //Metro
        var _tdMetro = Builder.node("td");//novo elemento campo
        var _divMetro = Builder.node("div", {
            align:"right"
        });
        var _ipMetro = Builder.node("input", {
            name: "metro_" +  countCubagem,
            id: "metro_" +  countCubagem,
            type: "text",
            value: metro,
            size: "7",
            maxLenght: "12",
            className:"fieldMin",
            onChange:"seNaoFloatReset(this,'0.00');"
        });
        _divMetro.appendChild(_ipMetro);
        _tdMetro.appendChild(_divMetro);

        //PesoCubado
        var _tdPeso = Builder.node("td");//novo elemento campo
        var _divPeso = Builder.node("div", {
            align:"right"
        });
        var _ipPeso = Builder.node("input", {
            name: "pesoCubado_" +  countCubagem,
            id: "pesoCubado_" +  countCubagem,
            type: "text",
            value: '0.00',
            size: "7",
            maxLenght: "12",
            className:"inputReadOnly8pt",
            readOnly:true,
            onChange:"seNaoFloatReset(this,'0.00');"
        });
        _divPeso.appendChild(_ipPeso);
        _tdPeso.appendChild(_divPeso);

        var _tdVazio = Builder.node("td");//novo elemento campo

        _tr1.appendChild(_td1);
        _tr1.appendChild(_tdVolume);
        _tr1.appendChild(_tdComprimento);
        _tr1.appendChild(_tdLargura);
        _tr1.appendChild(_tdAltura);
        _tr1.appendChild(_tdMetro);
        _tr1.appendChild(_tdPeso);
        _tr1.appendChild(_tdVazio);

        //implementa
        $("cubagemBody").appendChild(_tr1);

        $("maxCubagem").value = countCubagem;
        calculaPesoCubado(countCubagem);
    }
    function recalculaCubagens(){
        if(jQuery("input[name*='volume_']").length > 0){
            for (var i = 0, max = $("maxCubagem").value; i <= max; i++) {
                if($("altura_"+i) != null){
                    calculaCubagem(i);
                }
            }
        }else{
            if(parseFloat($("base").value) > 0){
                $('pesoKgCubado').value = parseFloat($("base").value) * parseFloat($("metro").value);
            }else{
                $('pesoKgCubado').value = "0,00";
            }
        }
    }
    function calculaCubagem(idx){
        $('metro_'+idx).value = roundABNT(parseFloat($('volume_'+idx).value) * parseFloat($('comprimento_'+idx).value) * parseFloat($('altura_'+idx).value) * parseFloat($('largura_'+idx).value), 4);
        calculaPesoCubado(idx);
        getTotalCubagens();
    }

    function calculaPesoCubado(idx){
        var pesoCubadoLinha = 0;
        if ($("tipoTransporte_tipo").value == 'a'){
            //validando, se BASE = 0 na divisão fica o valor 'infinity'. se for 0 dividir por 1.
            var base = ($("base").value == 0 ? 1 : $("base").value);
            pesoCubadoLinha =  parseFloat($("metro_"+idx).value) * parseFloat(1000000) / parseFloat(base);
        }else{
            pesoCubadoLinha = roundABNT(parseFloat($("base").value) * parseFloat($("metro_"+idx).value), 4);
        }
        $('pesoCubado_'+idx).value = pesoCubadoLinha;
    }

    function delCubagem(idx) {
        if (confirm("Deseja mesmo excluir esta cubagem?")){
            Element.remove("trCubagem_" + idx);
            getTotalCubagens();
        }
    }

    function getTotalCubagens(){
        var totalVolumes = 0;
        var totalPesoCubado = 0;
        var totalMetros = 0;
        var metroAntesAlterar = $('metro').value;
        for (i = 1; i <= countCubagem; ++i){
            if ($('volume_'+i)!=null){
                totalVolumes += parseFloat($('volume_'+i).value);
                totalMetros += parseFloat($('metro_'+i).value);
                totalPesoCubado += parseFloat($('pesoCubado_'+i).value);
            }
        }
        $('volumes').value = totalVolumes;
        $('metro').value = totalMetros;
        $('pesoKgCubado').value = totalPesoCubado;
        if (parseFloat(metroAntesAlterar) != parseFloat(totalMetros)){
            alteraTipoTaxa('N');
        }
    }
    
    //funcao de atribuicao de CFOP padrao
function atribuiCfopPadrao(){    
       var idCfopComDentro = <%=(idCfopComercioDentro != 0 ? idCfopComercioDentro : 0)%>;
       var cfopComDentro = <%=(idCfopComercioDentro != 0 ? String.valueOf(cfopComercioDentro) : "''")%>;
	   var idPlanoCustoComDentro = <%=(idCfopComercioDentro != 0 ? String.valueOf(idPlanoCfopComercioDentro) : 0)%>;
       var idCfopComFora = <%=(idCfopComercioFora != 0 ? idCfopComercioFora : 0)%>;
       var cfopComFora = <%=(idCfopComercioFora != 0 ? String.valueOf(cfopComercioFora) : "''")%>;
	   var idPlanoCustoComFora = <%=(idCfopComercioFora != 0 ? String.valueOf(idPlanoCfopComercioDentro) : 0)%>;
       var idCfopInduDentro = <%=(idCfopIndDentro != 0 ? idCfopIndDentro : 0)%>;
       var cfopInduDentro = <%=(idCfopIndDentro != 0 ? String.valueOf(cfopIndDentro) : "''")%>;
	   var idPlanoCustoInduDentro = <%=(idCfopIndFora != 0 ? String.valueOf(idPlanoCfopIndDentro) : 0)%>;
       var idCfopInduFora = <%=(idCfopIndFora != 0 ? idCfopIndFora : 0)%>;
       var cfopInduFora = <%=(idCfopIndFora != 0 ? String.valueOf(cfopIndFora) : "''")%>;
	   var idPlanoCustoInduFora = <%=(idCfopIndFora != 0 ? String.valueOf(idPlanoCfopIndFora) : 0)%>;
       var idCfopCPFDentro = <%=(idCfopPFDentro != 0 ? idCfopPFDentro : 0)%>;
       var cfopCPFDentro = <%=(idCfopPFDentro != 0 ? String.valueOf(cfopPFDentro) : "''")%>;
	   var idPlanoCustoCPFDentro = <%=(idCfopPFDentro != 0 ? String.valueOf(idPlanoCfopPFDentro) : 0)%>;
       var idCfopCPFFora = <%=(idCfopPFFora != 0 ? idCfopPFFora : 0)%>;
       var cfopCPFFora = <%=(idCfopPFFora != 0 ? String.valueOf(cfopPFFora) : "''")%>;
	   var idPlanoCustoCPFFora = <%=(idCfopPFFora != 0 ? String.valueOf(idPlanoCfopPFFora) : 0)%>;
       var idCfopUF = <%=(idCfopOutroEstado != 0 ? idCfopOutroEstado : 0)%>;
       var cfopUF = <%=(idCfopOutroEstado != 0 ? String.valueOf(cfopOutroEstado) : "''")%>;
	   var idPlanoCustoUF = <%=(idCfopOutroEstado != 0 ? String.valueOf(idPlanoCfopOutroEstado) : 0)%>;
       var idCfopUFFora = <%=(idCfopOutroEstadoFora != 0 ? idCfopOutroEstadoFora : 0)%>;
       var cfopUFFora = <%=(idCfopOutroEstadoFora != 0 ? String.valueOf(cfopOutroEstadoFora) : "''")%>;
	   var idPlanoCustoUFFora = <%=(idCfopOutroEstadoFora != 0 ? String.valueOf(idPlanoCfopOutroEstadoFora) : 0)%>;
  var idCfopTraFora = <%=(idCfopTransporteFora != 0 ? idCfopTransporteFora : 0)%>;
  var cfopTraFora = <%=(idCfopTransporteFora != 0 ? String.valueOf(cfopTransporteFora) : "''")%>;
	   var idPlanoCustoTraFora = <%=(idCfopTransporteFora != 0 ? String.valueOf(idPlanoCfopTransporteFora) : 0)%>;
  var idCfopTraDentro = <%=(idCfopTransporteDentro != 0 ? idCfopTransporteDentro : 0)%>;
  var cfopTraDentro = <%=(idCfopTransporteDentro != 0 ? String.valueOf(cfopTransporteDentro) : "''")%>;
	   var idPlanoCustoTraDentro = <%=(idCfopTransporteDentro != 0 ? String.valueOf(idPlanoCfopTransporteDentro) : 0)%>;
  var idCfopServFora = <%=(idCfopPrestacaoServicoFora != 0 ? idCfopPrestacaoServicoFora : 0)%>;
  var cfopServFora = <%=(idCfopPrestacaoServicoFora != 0 ? cfopPrestacaoServicoFora : "''")%>;
	   var idPlanoCustoServFora = <%=(idCfopPrestacaoServicoFora != 0 ? String.valueOf(idPlanoCfopPrestacaoServicoFora) : 0)%>;
  var idCfopServDentro = <%=(idCfopPrestacaoServicoDentro != 0 ? idCfopPrestacaoServicoDentro : 0)%>;
  var cfopServDentro = <%=(idCfopPrestacaoServicoDentro != 0 ? cfopPrestacaoServicoDentro : "''")%>;
	   var idPlanoCustoServDentro = <%=(idCfopPrestacaoServicoDentro != 0 ? String.valueOf(idPlanoCfopPrestacaoServicoDentro) : 0)%>;
  var idCfopRuralFora = <%=(idCfopProdutorRuralFora != 0 ? idCfopProdutorRuralFora : 0)%>;
  var cfopRuralFora = <%=(idCfopProdutorRuralFora != 0 ? cfopProdutorRuralFora : "''")%>;
	   var idPlanoCustoRuralFora = <%=(idCfopProdutorRuralFora != 0 ? String.valueOf(idPlanoCfopProdutorRuralFora) : 0)%>;
  var idCfopRuralDentro = <%=(idCfopProdutorRuralDentro != 0 ? idCfopProdutorRuralDentro : 0)%>;
  var cfopRuralDentro = <%=(idCfopProdutorRuralDentro != 0 ? cfopProdutorRuralDentro : "''")%>;
	   var idPlanoCustoRuralDentro = <%=(idCfopProdutorRuralDentro != 0 ? String.valueOf(idPlanoCfopProdutorRuralDentro) : 0)%>;
  var idCfopExtFora = <%=(idCfopExteriorFora != 0 ? idCfopExteriorFora : 0)%>;
  var cfopExtFora = <%=(idCfopExteriorFora != 0 ? cfopExteriorFora : "''")%>;
	   var idPlanoCustoExtFora = <%=(idCfopExteriorFora != 0 ? String.valueOf(idPlanoCfopExteriorFora) : 0)%>;
  var idCfopExtDentro = <%=(idCfopExteriorDentro != 0 ? idCfopExteriorDentro : 0)%>;
  var cfopExtDentro = <%=(idCfopExteriorDentro != 0 ? cfopExteriorDentro : "''")%>;
	   var idPlanoCustoExtDentro = <%=(idCfopExteriorDentro != 0 ? String.valueOf(idPlanoCfopExteriorDentro) : 0)%>;
  var idCfopSubDentro = <%=(idCfopSubContratacaoDentro != 0 ? idCfopSubContratacaoDentro : 0)%>;
  var cfopSubDentro = <%=(idCfopSubContratacaoDentro != 0 ? cfopSubContratacaoDentro : "''")%>;
           var idPlanoCustoSubDentro = <%=(idCfopSubContratacaoDentro != 0 ? String.valueOf(idPlanoCfopSubContratacaoDentro) : 0)%>;
  var idCfopSubFora = <%=(idCfopSubContratacaoFora != 0 ? idCfopSubContratacaoFora : 0)%>;
  var cfopSubFora = <%=(idCfopSubContratacaoFora != 0 ? cfopSubContratacaoFora : "''")%>;
           var idPlanoCustoSubFora = <%=(idCfopSubContratacaoFora != 0 ? String.valueOf(idPlanoCfopSubContratacaoFora) : 0)%>; 

       var filial_uf = $("fi_uf").value;
       var remetente_uf = $("uf_origem").value;
       var destinatario_uf = $("uf_destino").value;
       if($("tipoServico").value == 's'){//Apenas para SubContratação           
           $("idcfop_ctrc").value = (filial_uf == destinatario_uf ? idCfopSubDentro : idCfopSubFora);
           $("cfop_ctrc").value = (filial_uf == destinatario_uf ? cfopSubDentro : cfopSubFora);
           $("cfop_plano_custo_id").value = (filial_uf == destinatario_uf ? idPlanoCustoSubDentro : idPlanoCustoSubFora);
       } else if (destinatario_uf == 'EX'){ //Fretes com destinatario para fora do pais           
           $("idcfop_ctrc").value = (filial_uf == remetente_uf ? idCfopExtDentro : idCfopExtFora);
           $("cfop_ctrc").value   = (filial_uf == remetente_uf ? cfopExtDentro : cfopExtFora);
           $("cfop_plano_custo_id").value   = (filial_uf == remetente_uf ? idPlanoCustoExtDentro : idPlanoCustoExtFora);
       }else if (filial_uf != remetente_uf && !$('ck_redespacho').checked){ //Fretes originados em outra UF           
           $("idcfop_ctrc").value = (filial_uf == destinatario_uf ? idCfopUF : idCfopUFFora);
           $("cfop_ctrc").value   = (filial_uf == destinatario_uf ? cfopUF : cfopUFFora);
           $("cfop_plano_custo_id").value   = (filial_uf == destinatario_uf ? idPlanoCustoUF : idPlanoCustoUFFora);
       }else if ($('con_cnpj').value.length == 14){//Apenas pessoa fisica           
           $("idcfop_ctrc").value = (filial_uf == destinatario_uf ? idCfopCPFDentro : idCfopCPFFora);
           $("cfop_ctrc").value   = (filial_uf == destinatario_uf ? cfopCPFDentro : cfopCPFFora);
           $("cfop_plano_custo_id").value   = (filial_uf == destinatario_uf ? idPlanoCustoCPFDentro : idPlanoCustoCPFFora);
       }else if ($('con_tipo_cfop').value == 'c'){//APENAS PARA COMÉRCIO           
           $("idcfop_ctrc").value = (filial_uf == destinatario_uf ? idCfopComDentro : idCfopComFora);
           $("cfop_ctrc").value   = (filial_uf == destinatario_uf ? cfopComDentro : cfopComFora);
           $("cfop_plano_custo_id").value   = (filial_uf == destinatario_uf ? idPlanoCustoComDentro : idPlanoCustoComFora);
       }else if ($('con_tipo_cfop').value == 'i'){//APENAS PARA industria           
           $("idcfop_ctrc").value = (filial_uf == destinatario_uf ? idCfopInduDentro : idCfopInduFora);
           $("cfop_ctrc").value   = (filial_uf == destinatario_uf ? cfopInduDentro : cfopInduFora);
           $("cfop_plano_custo_id").value   = (filial_uf == destinatario_uf ? idPlanoCustoInduDentro : idPlanoCustoInduFora);
       }else if ($('con_tipo_cfop').value == 't'){//APENAS PARA transporte           
           $("idcfop_ctrc").value = (filial_uf == destinatario_uf ? idCfopTraDentro : idCfopTraFora);
           $("cfop_ctrc").value   = (filial_uf == destinatario_uf ? cfopTraDentro : cfopTraFora);
           $("cfop_plano_custo_id").value   = (filial_uf == destinatario_uf ? idPlanoCustoTraDentro : idPlanoCustoTraFora);
       }else if ($('con_tipo_cfop').value == 'p'){//APENAS PARA Prestador de serviço           
           $("idcfop_ctrc").value = (filial_uf == destinatario_uf ? idCfopServDentro : idCfopServFora);
           $("cfop_ctrc").value   = (filial_uf == destinatario_uf ? cfopServDentro : cfopServFora);
           $("cfop_plano_custo_id").value   = (filial_uf == destinatario_uf ? idPlanoCustoServDentro : idPlanoCustoServFora);
       }else if ($('con_tipo_cfop').value == 'r'){//APENAS PARA Produtor Rural           
           $("idcfop_ctrc").value = (filial_uf == destinatario_uf ? idCfopRuralDentro : idCfopRuralFora);
           $("cfop_ctrc").value   = (filial_uf == destinatario_uf ? cfopRuralDentro : cfopRuralFora);
           $("cfop_plano_custo_id").value   = (filial_uf == destinatario_uf ? idPlanoCustoRuralDentro : idPlanoCustoRuralFora);           
       } 
}


    function mudarCifFob(){
        if ($("clientepagador").value == 'r') {
            $("ven_rzs").value = $("venremetente").value;
            $("idvendedor").value = $("idvenremetente").value;
            $("con_tipo_tributacao").value = $("rem_tipo_tributacao").value;
        }else if ($("clientepagador").value == 'd') {
            $("ven_rzs").value = $("vendestinatario").value;
            $("idvendedor").value = $("idvendestinatario").value;
            $("con_tipo_tributacao").value = $("dest_tipo_tributacao").value;
        }else{
            $("ven_rzs").value = $("con_vendedor").value;
            $("idvendedor").value = $("idconvendedor").value;
        }
    }

    //fim da funcao do CFOP
    function getTipoProdutos(){
        var clientePagadorId = 0;
        if ($('clientepagador').value == 'r' && ($('remtabelaproduto').value == 't' || $('remtabelaproduto').value == 'true' || $('remtabelaproduto').value == true)){
            clientePagadorId = $('idremetente').value;
        }
        if ($('clientepagador').value == 'd' && ($('desttabelaproduto').value == 't' || $('desttabelaproduto').value == 'true' || $('desttabelaproduto').value == true)){
            clientePagadorId = $('iddestinatario').value;
        } 
        if($('clientepagador').value == 'c' && ($('contabelaproduto').value == 't' || $('contabelaproduto').value == 'true' || $('contabelaproduto').value == true)){
            clientePagadorId = $('idconsignatario').value;
        }
        localizarTipoProdutoGenerico(clientePagadorId);
        
        var tipoAtual = $('tipoproduto').value;
        function e(transport){
            var resp = transport.responseText;
            espereEnviar("",false);
            //se deu algum erro na requisicao...
            if (resp == 'null'){
                alert('Erro ao carregar os tipos de produtos.');
                return false;
            }else{
                var tipoProd = document.getElementById("divTipoProduto");
                var selectTipo = "<select name='tipoproduto' id='tipoproduto' class='fieldMin' style='width:110px;' onChange='alteraTipoProduto();'>";
                tipoProd.innerHTML = selectTipo+resp+"</select>";
                
                $('tipoproduto').value = tipoAtual;
                if ($('tipoproduto').value == ''){
                    $('tipoproduto').value = '0';
                }
            }
        }//funcao e()

        espereEnviar("",true);
        tryRequestToServer(function(){
            new Ajax.Request("./cadtipoproduto.jsp?acao=carregaTipos&cliente="+clientePagadorId,{method:'post', onSuccess: e, onError: e});
        });
        
        if ($("clientepagador").value == "c" ){
            $("trConsignatario").style.display = "";
        }else{
            $("trConsignatario").style.display = "none";
        }
    }

    function getDadosIcms(){
        var ufOrigemIcms = $('cid_uf_origem').value;
        var ufDestinoIcms = $('uf_destino').value;
        var idCidadeDestinoCtrc = $('idcidadedestino').value;
        var isDestinatarioIsento = ($('dest_insc_est').value.trim() == '' || $('dest_insc_est').value.trim() == 'ISENTO' || $('dest_insc_est').value.trim() == 'ISENTA');
        var tpTransporteIcms = $('tipoTransporte_tipo').value;
        var aliquotaIcmsJs = null;
//        getAliquotasIcmsAjax($('idfilial').value);
       
        if (ufOrigemIcms != '' && ufDestinoIcms != ''){
            aliquotaIcmsJs = getUfAliquotaIcmsCtrc(ufOrigemIcms, ufDestinoIcms, idCidadeDestinoCtrc, undefined, $("con_tipo_tributacao").value);

            if (aliquotaIcmsJs != null) {
                //Verificando se o destinatário é ISENTO de IE
                if (tpTransporteIcms == 'a'){
                    if (isDestinatarioIsento){
                        $('aliquota').value = aliquotaIcmsJs.aliquotaAereoPessoaFisica != undefined ? aliquotaIcmsJs.aliquotaAereoPessoaFisica : "-1.00";
                    }else{
                        $('aliquota').value = aliquotaIcmsJs.aliquotaAereo != undefined ? aliquotaIcmsJs.aliquotaAereo : "-1.00";
                    }
                }else{
                    if (isDestinatarioIsento){
                        $('aliquota').value = aliquotaIcmsJs.aliquotaPessoaFisica != undefined ? aliquotaIcmsJs.aliquotaPessoaFisica : "-1.00";
                    }else{
                        $('aliquota').value = aliquotaIcmsJs.aliquota != undefined ? aliquotaIcmsJs.aliquota : "-1.00";
                    }
                }
            }else{
                $('aliquota').value = '-1.00';
            }	
        }
    }
    
        function refreshTotal(refreshDup, refreshAprop) {
                $("totalService").value = getTotalGeralServico();
                //$("totalISS").value = getTotalISS('< %=taxes%>',false);
                //$("totalISSRetido").value = getTotalISS('< %=taxes%>',true);

        getTotalISS();
                $("valorLiquido").value = formatoMoeda(parseFloat($("totalService").value) - parseFloat($("totalISSRetido").value));

                //Copiaram codigos de cadvenda sem necessidade ou não criaram as funções aqui abaixo de proposito
                //Recriar parcelas
//                if (refreshDup && !$('btCriarDupls').disabled)
//                    doParcels();
//
//                //Refaz apropriações
//                if (refreshAprop)
//                    atualizaPlanoDefault();
                
                        

            }
    
    function showTotalImpostos(){
                        var img = $("botShowImpostos");
                        if(img.alt == "Abrir"){
                            img.alt = "Fechar";
                            img.title = "Ocultar os Totais dos Impostos.";
                            img.src="img/minus.jpg";
                            visivel($("trTotalImpostos"));
                        }else{
                            img.alt = "Abrir";
                            img.title = "Mostrar os Totais dos Impostos.";
                            img.src="img/plus.jpg";                
                            invisivel($("trTotalImpostos"));
                        }
                    }
    
    function limpaAeroportoEntrega(){
        $("aeroportoEntrega").value = "";
        $("aeroportoEntregaId").value = "0";
        redespTxDestino();
    }
    function limpaAeroportoColeta(){
        $("aeroportoColeta").value = "";
        $("aeroportoColetaId").value = "0";
        redespTxOrigem();
    }
    function alteraDesconto(){
        var percDesconto = $("percentual_desconto").value;
        if(percDesconto != 0){
            
            document.getElementById("valor_desconto").className ="inputReadOnly8pt";
            document.getElementById("valor_desconto").setAttribute("readOnly",true);
        }else{
            document.getElementById("valor_desconto").className ="fieldMin";
            document.getElementById("valor_desconto").removeAttribute('readOnly'); 
            
        }        
    }
    
    function alternarAbaDinamicamente(acao){
        var indiceVisivel = 0;
        var i = 1;
        var soma = 0;
        var podeAbrirAba = true;
        while ($("tab" + i) != null) {
            if ($("tab"+ i) != null && ($("tab"+ i).style.display == "")) {
                indiceVisivel = i;
            }
            i++;
        }
        
        soma = indiceVisivel + acao;
        
        if (soma >= 1 && soma <= 4) {
            podeAbrirAba = abrirAba(soma);
        }
        
        if (!podeAbrirAba) {
            podeAbrirAba = abrirAba(soma + acao);
        }
    } 
   
    function abrirAba(indice){
        if ($('tdAba_'+ indice).style.display == "") {
            AlternarAbasGenerico('tdAba_'+ indice,'tab'+indice);
        }
        return ($('tdAba_'+ indice).style.display == "");
    }   
       
    shortcut.add("Ctrl+page_up",function() {alternarAbaDinamicamente(-1);});
    shortcut.add("Ctrl+page_down",function() {alternarAbaDinamicamente(+1);});
    shortcut.add("Ctrl+1",function() {abrirAba(1);});
    shortcut.add("Ctrl+2",function() {abrirAba(2);});
    shortcut.add("Ctrl+3",function() {abrirAba(3);});
    shortcut.add("Ctrl+4",function() {abrirAba(4);});
    
     function pesquisarAuditoria(){
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
    var rotina = "orcamento";
    var dataDe = $("dataDeAuditoria").value;
    var dataAte = $("dataAteAuditoria").value;
    var id = <%=(carregaorc ? cadorc.getOrcamento().getId() : 0)%>;
    consultarLog(rotina, id, dataDe, dataAte);
    }
    
    function setDataAuditoria(){
       $("dataDeAuditoria").value = '<%= Apoio.getDataAtual() %>' 
       $("dataAteAuditoria").value = '<%= Apoio.getDataAtual() %>' 
        
    }
    
    function calcularCustosFilial(idfilial){
        var percntAdm = 0;
        var percntComercial = 0;
            if($("tipoTransporte_tipo").value == "a"){
                var comercial = parseFloat($("rateioComercial_"+idfilial).value); 
                var admin = parseFloat($("rateioAdm_"+idfilial).value); 
                var receita = parseFloat($("totalPrestacao").value);
                if(receita != 0){
                    percntComercial = roundABNT(receita* (comercial/100));
                    percntAdm = roundABNT(receita*(admin/100));
                     $("custoComercial").value = roundABNT(percntComercial);
                     $("custoAdministrativo").value = roundABNT(percntAdm);
//                     $("resumoFinanceiro").value = roundABNT(receita - (percntComercial + percntAdm));
                }
            }else{
                $("custoComercial").value = roundABNT(percntComercial);
                $("custoAdministrativo").value = roundABNT(percntAdm); 
            } 
    }
    
    function totalFinanceiro(){
        calcularCustosFilial($("idfilial").value);
        var custoCA = roundABNT(parseFloat($("custoComercial").value) + parseFloat($("custoAdministrativo").value),2);
        var txFixaTotal = roundABNT(parseFloat($("taxaFixaTotal").value),2);
        var vlSecCat = roundABNT(parseFloat($("valor_sec_cat").value),2);
        var valorPeso = 0;
        var totalPrestacao = roundABNT(parseFloat($("totalPrestacao").value),2);
        var federais = parseFloat(<%=cfg.getCalcularEmbutirImpostosFederais()%>);
        var resumoFinanceiro = 0;
        var advalorem = parseFloat($("valor_frete").value);
        if($("tipofrete").value != '1'){
           valorPeso = roundABNT(parseFloat($("peso").value) * parseFloat($("valorPeso").value),2);
        }else{
           valorPeso = roundABNT(parseFloat($("pesoKgCubado").value) * parseFloat($("valorPeso").value),2);
        }
//        resumoFinanceiro = roundABNT(parseFloat($("totalPrestacao").value) - (txFixaTotal - vlSecCat),2) - (valorPeso - parseFloat($("icms").value) - custoCA);
        resumoFinanceiro = roundABNT(parseFloat($("totalPrestacao").value),2) - (valorPeso + parseFloat($("icms").value) + custoCA + (txFixaTotal + vlSecCat) + roundABNT(totalPrestacao * parseFloat(federais) / 100) + advalorem);
        $("resumoFinanceiro").value = formatoMoeda(resumoFinanceiro);
    }
</script> 

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">

        <title> Webtrans - Lan&ccedil;amento de Or&ccedil;amento </title>
        <link href="./estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .cellNotes {
                font-size: 10px;
                background-color:#E6E6E6;
            }
            .styleValor {
                text-align: right;
            }
            -->
        </style>
    </head>

    <body onLoad="applyFormatter(); /*calculaFrete();*/ carregar(); 
            alteraStatus('<%=(orcamento != null ? orcamento.getStatus() : "0")%>');
            alteraTransporte('<%= (orcamento != null ? orcamento.getTipoCarga() : "c")%>');
            mostrarEndColeta();validaTipoTransporte();alteraDesconto();calculaFrete();
            calcularTotalEmbalagem();calcularSubTotal();calcularSeguro();
            CalcularPercentCTENFSE();carregarTotalGeralServicosParaResumo();
            AlternarAbasGenerico('tdAba_1','tab1');atribuiCfopPadrao();setDataAuditoria();calcularPeso(); ">
        
        <form action="./cadorcamento.jsp?acao=<%=(acao.equals("iniciar") ? "incluir" : acao.equals("editar") ? "atualizar" : "")%>" id="formulario" target="pop" name="formulario" method="post">
            <img src="img/banner.gif" >
            <br>
            <input type="hidden" id="idveiculo" value="0">
            <input type="hidden" id="vei_placa" value="">
            <input type="hidden" id="type_service_id">
            <input type="hidden" id="type_service_descricao">
            <input type="hidden" id="type_service_valor">
            <input type="hidden" id="type_service_iss_percent">
            <input type="hidden" id="type_service_inss_percent">
            <input type="hidden" id="type_service_pis_percent">
            <input type="hidden" id="type_service_cofins_percent">
            <input type="hidden" id="type_service_ir_percent">
            <input type="hidden" id="type_service_cssl_percent">
            <input type="hidden" id="tax_id">
            <input type="hidden" id="inss_tax_id">
            <input type="hidden" id="pis_tax_id">
            <input type="hidden" id="cofins_tax_id">
            <input type="hidden" id="ir_tax_id">
            <input type="hidden" id="cssl_tax_id">
            <input type="hidden" id="codigo_taxa">
            <input type="hidden" id="embutir_iss">
            <input type="hidden" id="is_usa_dias" name="is_usa_dias" value="">
            <input type="hidden" id="quantidade_casas_decimais_quantidade" value="0">
            <input type="hidden" id="quantidade_casas_decimais_valor" value="0">
            <input type="hidden" id="idplanocusto">
            <input type="hidden" id="plcusto_conta">
            <input type="hidden" id="plcusto_descricao">
            <input type="hidden" id="totalServicos" name="totalServicos">
            
            <input type="hidden" id="aeroporto_desc" name="aeroporto_desc" value="">
            <input type="hidden" id="aeroporto_id" name="aeroporto_id" value="">
            <input type="hidden" id="distancia_col" name="distancia_col" value="">
            

            <input type="hidden" name="cid_id_origem" id="cid_id_origem" value="<%=(orcamento != null ? orcamento.getCidadeOrigem().getIdcidade() : "0")%>">
            <input type="hidden" name="cid_id_coleta" id="cid_id_coleta" value="<%=(orcamento != null ? orcamento.getCidadeColeta().getIdcidade() : "0")%>">
            <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="<%=(orcamento != null ? orcamento.getCidadeDestino().getIdcidade() : "0")%>">
            
            <!-- cidade origem -->
            <input type="hidden" name="idcidadeorigem" id="idcidadeorigem" value="0"><!-- aoclicarnolocaliza -->
            <input type="hidden" name="cid_origem" id="cid_origem" value=""><!-- aoclicarnolocaliza -->
            <input type="hidden" name="uf_origem" id="uf_origem" value=""><!-- aoclicarnolocaliza -->
            <!-- cidade coleta -->
            <input type="hidden" name="idcidade_col" id="idcidade_col" value="0"><!-- aoclicarnolocaliza -->
            <input type="hidden" name="cidade_col" id="cidade_col" value=""><!-- aoclicarnolocaliza -->
            <input type="hidden" name="uf_col" id="uf_col" value=""><!-- aoclicarnolocaliza -->
            <!-- destinatario -->
            <input type="hidden" name="cidade_destino_id" id="cidade_destino_id" value="0"><!-- aoclicarnolocaliza -->
            <input type="hidden" name="dest_cidade" id="dest_cidade" value=""><!-- aoclicarnolocaliza -->
            <input type="hidden" name="dest_uf" id="dest_uf" value=""><!-- aoclicarnolocaliza -->
            <input type="hidden" name="dest_insc_est" id="dest_insc_est" value="<%=(orcamento != null ? orcamento.getDestinatario().getInscest() : "0")%>">
            
            <!-- Vendedores -->
            <input type="hidden" name="rem_vendedor" id="rem_vendedor" value="0"><!-- aoclicarnolocaliza -->
            <input type="hidden" name="idremvendedor" id="idremvendedor" value="0"><!-- aoclicarnolocaliza -->
            <input type="hidden" name="dest_vendedor" id="dest_vendedor" value="0"><!-- aoclicarnolocaliza -->
            <input type="hidden" name="iddestvendedor" id="iddestvendedor" value="0"><!-- aoclicarnolocaliza -->
            
            <input type="hidden" name="con_vendedor" id="con_vendedor" value="0"><!-- aoclicarnolocaliza -->
            <input type="hidden" name="idconvendedor" id="idconvendedor" value="0"><!-- aoclicarnolocaliza -->
            
            <input type="hidden" name="vendestinatario" id="vendestinatario" value="0"><!-- aoclicarnolocaliza -->
            <input type="hidden" name="idvendestinatario" id="idvendestinatario" value="0"><!-- aoclicarnolocaliza -->
            
            
            <!-- produto -->
            <input type="hidden" name="produto_id" id="produto_id" value="0"><!-- aoclicarnolocaliza -->
            <input type="hidden" name="descricao_produto" id="descricao_produto" value=""><!-- aoclicarnolocaliza -->
            <input type="hidden" name="metro_cubico" id="metro_cubico" value="0"><!-- aoclicarnolocaliza -->
            <input type="hidden" name="codigo_produto" id="codigo_produto" value="0">
            <input type="hidden" name="indexProduto" id="indexProduto" value="">
            <input type="hidden" name="max" id="max" value="0">
            <input type="hidden" name="maxServico" id="maxServico" value="0">
            <input id="peso_bruto" type="hidden" value="0" name="peso_bruto"/><!-- aoclicarnolocaliza irá adcionar o valor do Peso Bruto-->
            
            <input type="hidden" name="numero" id="numero" value="<%=(orcamento != null ? orcamento.getNumero() : "0")%>">
            <input type="hidden" name="idorcamento" id="idorcamento" value="<%=(orcamento != null ? orcamento.getId() : "0")%>">
            <input type="hidden" name="obs_desc" id="obs_desc" value="">
            <input type="hidden" name="icmsImbutido" id="icmsImbutido" value="<%=(orcamento != null ? orcamento.getIcmsImbutido() : "0")%>">
            <!-- Cliente -->
            <input type="hidden" name="idvenremetente" id="idvenremetente" value="0"> <!-- aoclicarnolocaliza -->
            <input type="hidden" name="venremetente" id="venremetente" value=""><!-- aoclicarnolocaliza -->
            <input type="hidden" name="rem_cidade" id="rem_cidade" value="">
            <input type="hidden" name="rem_uf" id="rem_uf" value="">
            <input type="hidden" name="rem_fone" id="rem_fone" value="">
            <input type="hidden" name="con_fone" id="con_fone" value="">
            <input type="hidden" name="rem_tipotaxa" id="rem_tipotaxa" value="<%=(orcamento != null ? orcamento.getCliente().getTipo_tabela(): "-1")%>">
            <input type="hidden" name="dest_tipotaxa" id="dest_tipotaxa" value="<%=(orcamento != null ? orcamento.getDestinatario().getTipo_tabela(): "-1")%>">
            <input type="hidden" name="con_tipotaxa" id="con_tipotaxa" value="<%=(orcamento != null ? orcamento.getConsignatario().getTipo_tabela(): "-1")%>">
            <!--<input type="hidden" name="idcidadeorigem" id="idcidadeorigem" value="0">-->
            <input type="hidden" name="contato" id="contato" value="">
            <input type="hidden" name="contato_destinatario" id="contato_destinatario" value="">
            <input type="hidden" id="idvendedor" name="idvendedor" value="<%=orcamento != null ? orcamento.getVendedor().getIdfornecedor() : 0%>">
            <input type="hidden" name="maxCubagem" id="maxCubagem" value="0">
            <input type="hidden" name="redspt_rzs" id="redspt_rzs" value=""/> 
            <input type="hidden" name="idredespachante" id="idredespachante" value="0"/>
            
            <!-- cfop para o cte -->
            <input type="hidden" name="idcfop_ctrc" id="idcfop_ctrc" value="0"/>
            <input type="hidden" name="cfop_ctrc" id="cfop_ctrc" value="0"/>
            <input type="hidden" name="ck_redespacho" id="ck_redespacho" value="0"/>
            <input type="hidden" name="con_tipo_cfop" id="con_tipo_cfop" value="0"/>
            <input type="hidden" name="cfop_plano_custo_id" id="cfop_plano_custo_id" value="0"/>
            <input type="hidden" name="fi_uf" id="fi_uf" value="<%=(carregaorc ? orcamento.getFilial().getCidade().getUf() :
                                                                      (acao.equals("iniciar") ? Apoio.getUsuario(request).getFilial().getCidade().getUf() : ""))%>">
            
            <input type="hidden" name="utilizaTipoFreteTabelaRem" id="utilizaTipoFreteTabelaRem" value="<%=(carregaorc ? orcamento.getCliente().isUtilizarTipoFreteTabela() : false)%>">
            <input type="hidden" name="utilizaTipoFreteTabelaDest" id="utilizaTipoFreteTabelaDest" value="<%=(carregaorc ? orcamento.getDestinatario().isUtilizarTipoFreteTabela() : false)%>">
            <input type="hidden" name="utilizaTipoFreteTabelaConsig" id="utilizaTipoFreteTabelaConsig" value="<%=(carregaorc ? orcamento.getConsignatario().isUtilizarTipoFreteTabela() : false)%>">
            <input type="hidden" name="is_utilizar_tipo_frete_tabela" id="is_utilizar_tipo_frete_tabela" value="">
            <input type="hidden" name="rem_tabela_remetente" id="rem_tabela_remetente" value="<%=(orcamento != null ? orcamento.getCliente().getUtilizaTabelaRemetente() : "n")%>">
            <input type="hidden" name="des_tabela_remetente" id="des_tabela_remetente" value="<%=(orcamento != null ? orcamento.getDestinatario().getUtilizaTabelaRemetente() : "n")%>">
            <input type="hidden" name="con_tabela_remetente" id="con_tabela_remetente" value="<%=(orcamento != null ? orcamento.getConsignatario().getUtilizaTabelaRemetente() : "n")%>">
            <input type="hidden" name="tipo_arredondamento_peso_rem" id="tipo_arredondamento_peso_rem" value="<%=(orcamento != null ? orcamento.getCliente().getTipoArredondamentoPeso(): "n")%>">
            <input type="hidden" name="tipo_arredondamento_peso_dest" id="tipo_arredondamento_peso_dest" value="<%=(orcamento != null ? orcamento.getDestinatario().getTipoArredondamentoPeso() : "n")%>">
            <input type="hidden" name="tipo_arredondamento_peso_con" id="tipo_arredondamento_peso_con" value="<%=(orcamento != null ? orcamento.getConsignatario().getTipoArredondamentoPeso() : "n")%>">
            <input type="hidden" name="tipo_arredondamento_peso" id="tipo_arredondamento_peso" value="n">
            <input type="hidden" name="dest_tipo_tributacao" id="dest_tipo_tributacao" value="<%= (orcamento != null ? orcamento.getDestinatario().getTipoTributacao() : "NI") %>">
            <input type="hidden" name="rem_tipo_tributacao" id="rem_tipo_tributacao" value="<%= (orcamento != null ? orcamento.getCliente().getTipoTributacao() : "NI") %>">
            <input type="hidden" name="con_tipo_tributacao" id="con_tipo_tributacao" value="<%= (orcamento != null ? orcamento.getConsignatario().getTipoTributacao() : "NI") %>">
            
            <input type="hidden" name="tipoTaxaTabela" id="tipoTaxaTabela" value="">            
            <input type="hidden" name="rem_st_mg" id="rem_st_mg" value="<%=(orcamento != null ? orcamento.getCliente().isSubstituicaoTributariaMinasGerais(): false)%>"/>
            <input type="hidden" name="con_uf" id="con_uf" value="<%=(orcamento != null ? orcamento.getConsignatario().getCidade().getUf(): "")%>"/>
            
            <input name="tipoServico" type="hidden" id="tipoServico" size="3" class="inputReadOnly8pt" readonly="true" value="n">
            
            <table width="80%" align="center" class="bordaFina" >
                <tr>
                    <td width="613" align="left">
                        <b>Lan&ccedil;amento de Or&ccedil;amento</b>
                    </td>
                    <%   if ((acao.equals("editar")) && (nivelUser >= 4) && (Boolean.parseBoolean(request.getParameter("podeExcluir")))) {
                    %>	   
                    <td width="15">
                        <input name="excluir" type="button" class="inputBotaoMin" value="Excluir"
                               onClick="javascript:tryRequestToServer(function(){excluir('<%=(carregaorc ? orcamento.getId() : 0)%>');});">
                    </td>
                    <%}%>
                    <td width="56" >
                        <input  type="button" class="botoes" id="bt_consultar" onClick="voltar()" value="Voltar para Consulta">
                    </td>
                </tr>
            </table>
            <br>
            <table width="80%" border="0" cellspacing="0" cellpadding="0" class="" align="center">
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="left">
                            <tr class="tabela" id="">

                             <td id="tdAba_1" class="menu-sel" onclick="AlternarAbasGenerico('tdAba_1','tab1');"> <center> Dados Principais </center></td>
                             <td id="tdAba_2" class="menu" onclick="AlternarAbasGenerico('tdAba_2','tab3');"> Servicos</td>
                             <td id="tdAba_3" class="menu" onclick="AlternarAbasGenerico('tdAba_3','tab2');"> Itens </td>
                             <td id="tdAba_4" class="menu" onclick="AlternarAbasGenerico('tdAba_4','tab4');">Criar Várias Simulações de Fretes</td>
                             <td style='display: <%= carregaorc && nivelUser == 4 ? "" : "none" %>' id="tdAba_5" class="menu" onclick="AlternarAbasGenerico('tdAba_5','tab5');">Auditoria</td>
                            <!-- coloca-se em <div> com um ID do segundo parametro do metodo AlternarAbasGenerico -->

                            </tr>
                        </table>
                    </td>
                    <td width="10%"></td>
                </tr>
            </table>
            <div id="tab1">
            <table width="80%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
                
                
                
                <tr>
                    <td width="8%" class="TextoCampos">N&uacute;mero:</td>
                    <td width="15%" class="CelulaZebra2">
                        <span class="CelulaZebra2">
                            <b><%=(acao.equals("editar") ? String.valueOf(orcamento.getNumero()) : "")%></b>
                        </span>
                    </td>
                    <td width="6%" class="TextoCampos">Tipo:</td>
                    <td width="25%" class="CelulaZebra2">
                        <span class="CelulaZebra2">
                            <select name="tipoTransporte_tipo" id="tipoTransporte_tipo" class="fieldMin" onChange="validaTipoTransporte();getDadosIcms();calcularCustosFilial($('idfilial').value);alteraTipoTaxa('S');" style="width: 110px;">
                                <%= emiteRodoviario ? "<option value='r' >CTR-Rodoviário</option>" : ""%>
                                <%= emiteAereo ? "<option value='a' >CTA-A&eacute;reo</option>" : ""%>
                                <%= emiteAquaviario ? "<option value='q' >CTQ-Aquavi&aacute;rio</option>" : ""  %>
                            </select>
                            <select name="tipoCarga" id="tipoCarga" class="fieldMin" onChange="alteraTransporte(this.value)" style="width: 65px;">
                                <option value="c" <%=carregaorc ? (orcamento.getTipoCarga().equals("c") ? "selected" : "") : "selected"%>>Carga</option>
                                <option value="v" <%=carregaorc ? (orcamento.getTipoCarga().equals("v") ? "selected" : "") : ""%>>Veículo (Cegonha)</option>
                                <option value="m" <%=carregaorc ? (orcamento.getTipoCarga().equals("m") ? "selected" : "") : ""%>>Mudança</option>

                            </select>
                        </span>
                    </td>
                    <td width="5%" class="TextoCampos">Filial:</td>
                    <td width="18%" class="CelulaZebra2">
                        <select name="idfilial" id="idfilial" class="fieldMin" onchange="getAliquotasIcmsAjax(this.value);calcularCustosFilial(this.value)">
                            <%BeanFilial fl = new BeanFilial();
                                ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());

                                int filial = (carregaorc ? orcamento.getFilial().getIdfilial() : request.getParameter("idfilial") != null ? Apoio.parseInt(request.getParameter("idfilial")) : Apoio.getUsuario(request).getFilial().getIdfilial());

                                Collection<BeanFilial> listaFilial = new ArrayList<BeanFilial>();
                                BeanFilial filialB = null;
                                while (rsFl.next()) {
                                    filialB = new BeanFilial();
                                    filialB.setIdfilial(rsFl.getInt("idfilial"));
                                    filialB.getCidade().setIdcidade(rsFl.getInt("cidade_id"));
                                    filialB.getCidade().setDescricaoCidade(rsFl.getString("cidade_filial"));
                                    filialB.getCidade().setUf(rsFl.getString("uf_filial"));
                                    filialB.setRateioAdministrativo(rsFl.getDouble("rateio_administrativo"));
                                    filialB.setRateioComercial(rsFl.getDouble("rateio_comercial"));
                                    listaFilial.add(filialB);
                            %>
                            <option value="<%=rsFl.getString("idfilial")%>"
                                    <%=(filial == rsFl.getInt("idfilial") ? "selected" : "")%>><%=rsFl.getString("abreviatura")%></option>
                            <%}%>
                        </select>
                        <%
                            for (BeanFilial filialU : listaFilial) {
                        %>
                        <input type="hidden"  id="cidadeFilial_<%=filialU.getIdfilial()%>" name="cidadeFilial_<%=filialU.getIdfilial()%>"  value="<%=filialU.getCidade().getIdcidade() + "!!" + filialU.getCidade().getDescricaoCidade() + "!!" + filialU.getCidade().getUf()%>"/>
                        <input type="hidden"  id="rateioComercial_<%=filialU.getIdfilial()%>" name="rateioComercial_<%=filialU.getIdfilial()%>"  value="<%=filialU.getRateioComercial()%>"/>
                        <input type="hidden"  id="rateioAdm_<%=filialU.getIdfilial()%>" name="rateioAdm_<%=filialU.getIdfilial()%>"  value="<%=filialU.getRateioAdministrativo()%>"/>
                        <%
                            }
                        %>                    
                    </td>
                    <td width="7%" class="TextoCampos">Data:</td>
                    <td width="16%" class="CelulaZebra2">
                        <span class="CelulaZebra2">
                            <input name="dtemissao" type="text" id="dtemissao" size="9" maxlength="10"
                                   value="<%=carregaorc ? fmt.format(orcamento.getDtLancamento()) : Apoio.getDataAtual()%>"
                                   onblur="alertInvalidDate(this)" class="fieldDate" style="font-size:8pt;">
                        </span>
                    </td>
                </tr>
                <tr colspan="6" >
                    <td class="TextoCampos">Status:</td>
                    <td class="CelulaZebra2">
                        <span class="CelulaZebra2">
                            <select name="status" id="status" class="fieldMin" onChange="alteraStatus(this.value)">
                                <option value="0" <%=carregaorc ? (orcamento.getStatus() == 0 ? "selected" : "") : "selected"%>>Em aberto</option>
                                <option value="1" <%=carregaorc ? (orcamento.getStatus() == 1 ? "selected" : "") : ""%>>Aprovado</option>
                                <option value="2" <%=carregaorc ? (orcamento.getStatus() == 2 ? "selected" : "") : ""%>>N&atilde;o aprovado</option>
                            </select>
                        </span>
                    </td>
                    <td class="TextoCampos">
                        <div id="lbMotivo">Motivo:</div>
                    </td>
                    <td class="CelulaZebra2" colspan="5">
                        <div id="divMotivo">
                            <input name="motivo" type="text" id="motivo" size="75" value="<%=(carregaorc ? orcamento.getMotivo() : "")%>" class="fieldMin">
                        </div>
                        <label id="labCTRC" style="display: none">
                            <%=carregaorc && !orcamento.isPodeExcluir() 
                                    ? (orcamento.getTipoTaxaMudanca().equals("CTE") ? "Vinculado ao CT " + orcamento.getConhecimento().getNumero() + " em " + fmt.format(orcamento.getConhecimento().getEmissaoEm()) 
                                    : (orcamento.getTipoTaxaMudanca().equals("NFSE")? "Vinculado a NFS " + orcamento.getVenda().getNumero() + " em " + fmt.format(orcamento.getVenda().getEmissaoEm()) 
                                    :"")
                                    ) : ""%>
                        </label>
                    </td>    
                </tr>
                        
                <tr id="trIsFinalizarOrcamento" >
                    <td class="CelulaZebra2" colspan="8">
                        <label id="lbFinalizar"> 
                            Finalizar:<input type="checkbox" name="isFinalizaOrcamento" id="isFinalizaOrcamento" <%= (carregaorc? (orcamento.isIsFinalizaOrcamento() ? "checked" : "" ) : "") %> >
                        </label>
                    </td>        
                </tr>
                <tr>
                    <td colspan="8">
                        <table width="100%" border="0" cellspacing="1" cellpadding="2">
                            <tr>
                                <td width="13%" class="TextoCampos">Remetente:</td>
                                <td colspan="4" class="CelulaZebra2">
                                    <input type="hidden"  id="idremetente" name="idremetente"  value="<%=orcamento.getCliente().getIdcliente()%>"  />
                                    <input type="hidden"  id="remtipoorigem" name="remtipoorigem"  value="r" />
                                    <input type="hidden"  id="remtabelaproduto" name="remtabelaproduto"  value="<%=carregaorc ? orcamento.getCliente().isTabelaTipoProduto() : "f"%>" />
                                    <input name="rem_codigo" type="text" id="rem_codigo" size="4" value="<%=orcamento.getCliente().getIdcliente()%>" onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo('idcliente', this.value)" class="fieldMin">
                                    <input name="rem_cnpj" type="text" class="inputReadOnly8pt" id="rem_cnpj" maxlength="23" size="17" value="<%=orcamento.getCliente().getCnpj()%>" onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo('cnpj',this.value)" style="font-size:8pt;" >
                                    <input class="inputReadOnly8pt" type="text" size="30" name="rem_rzs" id="rem_rzs" value="<%=orcamento.getCliente().getRazaosocial()%>" onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo('c.razaosocial',this.value)" style="font-size:8pt;" />
                                    <input type="button" class="inputBotaoMin" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=3&paramaux2='+$('dest_uf').value+'&paramaux3='+$('idcidadedestino').value,'Cliente')" value="..." style="font-size:8pt;"/>
                                    <img src="img/page_edit.png" border="0" onClick="javascript:verCliente('R');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                    <input type="hidden"  id="remtipofpag" name="remtipofpag"  value="<%=carregaorc ? orcamento.getCliente().getTipoPagtoFrete() : "v"%>" />
                                    <input type="hidden"  id="rem_pgt" name="rem_pgt"  value="<%=carregaorc ? orcamento.getCliente().getCondicaoPgt() : "0"%>" />
                                </td>
                                <td width="31%" class="CelulaZebra2">
                                    <div align="center" >
                                        <input name="coletarMercadoria" type="checkbox" id="coletarMercadoria" value="checkbox" <%=carregaorc && orcamento.isColetarMercadoria() ? "checked" : ""%> onClick="mostrarEndColeta();">
                                        Coletar mercadoria
                                    </div>
                                </td>
                            </tr>
                            <tr name="trColetar" id="trColetar" style="display:none;">
                                <td class="TextoCampos">Endere&ccedil;o:</td>
                                <td colspan="5" class="CelulaZebra2">
                                    <input name="endereco_col" type="text" class="inputReadOnly8pt" style="font-size:8pt;"
                                           id="endereco_col" size="40" value="<%=(orcamento != null ? orcamento.getEnderecoColeta() : "")%>">
                                    <input name="bairro_col" type="text" class="inputReadOnly8pt" style="font-size:8pt;"
                                           id="bairro_col" size="15" value="<%=(orcamento != null ? orcamento.getBairroColeta() : "")%>" >                                            
                                    <input name="cid_nome_coleta" type="text" id="cid_nome_coleta" 
                                           value="<%=(orcamento != null ? orcamento.getCidadeColeta().getDescricaoCidade() : "")%>" style="font-size:8pt;" size="18" maxlength="25" readonly="true" class="inputReadOnly8pt">
                                    <input name="cid_uf_coleta" type="text" id="cid_uf_coleta" 
                                           value="<%=(orcamento != null ? orcamento.getCidadeColeta().getUf() : "")%>" style="font-size:8pt;" size="2" maxlength="25" readonly="true" class="inputReadOnly8pt">
                                    <strong>
                                        <input id="localiza_cidade_coleta" type="button" class="inputBotaoMin" value="..."
                                               onClick="javascript:window.open('./localiza?acao=consultar&idlista=11&paramaux='+$('idcidadedestino').value+'&paramaux2='+$('uf_destino').value,'Cidade_coleta','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                    </strong>
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Contato:</td>
                                <td width="14%" class="CelulaZebra2">
                                    <input name="contato_orcamento" type="text" id="contato_orcamento" size="15" maxlength="30"
                                           value="<%=carregaorc ? (orcamento.getContato()==null? "" : orcamento.getContato()) : "" %>" class="fieldMin">
                                </td>
                                <td width="10%" class="TextoCampos">Fone:</td>
                                <td width="14%" class="CelulaZebra2">
                                    <input name="fone" type="text" id="fone" size="15" maxlength="20"
                                           value="<%=carregaorc ? (orcamento.getFone()==null? "" : orcamento.getFone()) : ""%>" class="fieldMin">
                                </td>
                                <td width="18%" class="TextoCampos">E-mail:</td>
                                <td class="CelulaZebra2">
                                    <input name="rem_email" type="text" id="rem_email" size="35" maxlength="120"
                                           value="<%=carregaorc ? orcamento.getEmail() : ""%>" class="fieldMin">
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Destinat&aacute;rio:</td>
                                <td colspan="4" class="CelulaZebra2">
                                    <input name="des_codigo" type="text" id="des_codigo" size="4" value="<%=orcamento.getDestinatario().getIdcliente()%>" onKeyUp="javascript:if (event.keyCode==13) localizaDestinatarioCodigo('idcliente', this.value)" class="fieldMin">
                                    <input name="dest_cnpj" type="text" class="inputReadOnly8pt" id="dest_cnpj" maxlength="23" size="17" value="<%=orcamento.getDestinatario().getCnpj()%>" onKeyUp="javascript:if (event.keyCode==13) localizaDestinatarioCodigo('cnpj',this.value)" style="font-size:8pt;" >
                                    <input class="required inputReadOnly8pt" type="text" size="30" name="dest_rzs" id="dest_rzs" value="<%=orcamento.getDestinatario().getRazaosocial()%>" onKeyUp="javascript:if (event.keyCode==13) localizaDestinatarioCodigo('c.razaosocial',this.value)" style="font-size:8pt;" />
                                    <input type="button" class="inputBotaoMin" onClick="if ($('cid_uf_origem').value == ''){alert('Informe o remetente ou a cidade de origem corretamente.')}else{launchPopupLocate('./localiza?acao=consultar&idlista=4&paramaux='+$('idfilial').value+'&paramaux2='+$('cid_uf_origem').value+'&paramaux3='+$('idcidadeorigem').value,'Destinatario')}" value="..." />
                                    <input type="hidden"  id="desttabelaproduto" name="desttabelaproduto"  value="<%=carregaorc ? orcamento.getDestinatario().isTabelaTipoProduto() : "f"%>" />
                                    <input type="hidden"  id="iddestinatario" name="iddestinatario"  value="<%=orcamento.getDestinatario().getIdcliente()%>"  />          
                                    <input type="hidden"  id="des_inclui_tde" name="des_inclui_tde"  value="f"/>
                                    <input type="hidden"  id="desttipofpag" name="desttipofpag"  value="<%=carregaorc ? orcamento.getDestinatario().getTipoPagtoFrete() : "v"%>" />
                                    <input type="hidden"  id="dest_pgt" name="dest_pgt"  value="<%=carregaorc ? orcamento.getDestinatario().getCondicaoPgt() : "0"%>" />
                                    <img src="img/page_edit.png" border="0" onClick="javascript:verCliente('D');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                </td>
                                <td class="CelulaZebra2">&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Contato</td>
                                <td class="CelulaZebra2">
                                    <input name="contatoDestinatario" type="text" id="contatoDestinatario" size="15" maxlength="30"
                                           value="<%=carregaorc ? orcamento.getContatoDestinatario() : ""%>" class="fieldMin">
                                </td>
                                <td class="TextoCampos">Fone:</td>
                                <td class="CelulaZebra2">
                                    <input name="dest_fone" type="text" id="dest_fone" size="15" maxlength="20"
                                           value="<%=carregaorc ? orcamento.getFoneDestinatario() : ""%>" class="fieldMin">
                                </td>
                                <td class="TextoCampos">E-mail:</td>
                                <td class="CelulaZebra2">
                                    <input name="des_email" type="text" id="des_email" size="35" maxlength="120"
                                           value="<%=carregaorc ? orcamento.getEmailDestinatario() : ""%>" class="fieldMin">
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr class="tabela">
                    <td colspan="8">
                        <div align="center">Dados do Pagamento (Financeiro)</div>
                    </td>
                </tr>
                <tr>
                    <td colspan="8">
                        <table width="100%" border="0" cellspacing="1" cellpadding="2">
                            <tr>
                                <td width="17%" class="TextoCampos">Cliente Pagador:</td>
                                <td width="21%" class="CelulaZebra2">
                                    <select name="clientepagador" id="clientepagador" class="fieldMin" onChange="getCondicaoPagto();getTipoProdutos();mudarCifFob();getDadosIcms();">
                                        <option value="d">Destinat&aacute;rio (FOB)</option>
                                        <option value="r" selected>Remetente (CIF)</option>
                                        <option value="c">Terceiro (CON)</option>
                                    </select>
                                </td>
                                <td width="14%" class="TextoCampos">Condi&ccedil;&atilde;o:</td>
                                <td colspan="3" class="CelulaZebra2">
                                    <select name="pagtoFrete" id="pagtoFrete" class="fieldMin" onChange="javascript:$('condicaopgt').value = (this.value == 'v'?'0':'30')" <%=(nivelUser == 4 ? "" : "disabled")%>>
                                        <option value="v">&Agrave; vista</option>
                                        <option value="p">&Agrave; prazo</option>
                                        <option value="c">C. Corrente</option>
                                    </select>
                                    com 
                                    <input name="condicaopgt" type="text" id="condicaopgt" size="2" maxlength="9" class="fieldMin"
                                           onChange="seNaoIntReset(this,'0')" value="<%=(carregaorc ? orcamento.getCondicaoPgt() : 30)%>" <%=(nivelUser == 4 ? "" : "disabled")%>> 
                                    dias ap&oacute;s a emiss&atilde;o.
                                </td>
                            </tr>
                            <tr id="trConsignatario">
                                <td colspan="8">
                                    <table width="100%" border="0" cellspacing="1" cellpadding="2">
                                        <tr>
                                            <td width="13%" class="TextoCampos">Consignat&aacute;rio:</td>
                                            <td colspan="5" class="CelulaZebra2">
                                                <input type="hidden" id="idconsignatario" name="idconsignatario"  value="<%=orcamento.getConsignatario().getIdcliente()%>"  />
                                                <input name="con_codigo" type="text" id="con_codigo" size="3" value="<%=orcamento.getConsignatario().getIdcliente()%>" onKeyUp="javascript:if (event.keyCode==13) localizaConsignatarioCodigo('idcliente', this.value)" class="fieldMin">
                                                <input name="con_cnpj" type="text" class="inputReadOnly8pt" id="con_cnpj" maxlength="23" size="15" value="<%=orcamento.getConsignatario().getCnpj()%>" onKeyUp="javascript:if (event.keyCode==13) localizaConsignatarioCodigo('cnpj',this.value)" style="font-size:8pt;" >
                                                <input class="inputReadOnly8pt" type="text" size="25" name="con_rzs" id="con_rzs" value="<%=orcamento.getConsignatario().getRazaosocial()%>" style="font-size:8pt;" readonly="true"/>
                                                <input type="button" class="inputBotaoMin" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=5','Consignatario')" value="..." style="font-size:8pt;"/>
                                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaConsignatario()">
                                                <input type="hidden"  id="tipofpag" name="tipofpag"  value="<%=carregaorc ? orcamento.getConsignatario().getTipoPagtoFrete() : "v"%>" />
                                                <input type="hidden"  id="contabelaproduto" name="contabelaproduto"  value="<%=carregaorc ? orcamento.getConsignatario().isTabelaTipoProduto() : "f"%>" />
                                                <input type="hidden"  id="con_pgt" name="con_pgt"  value="<%=carregaorc ? orcamento.getConsignatario().getCondicaoPgt() : "0"%>" />
                                                <img src="img/page_edit.png" border="0" onClick="javascript:verCliente('C');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos">Contato:</td>
                                            <td width="14%" class="CelulaZebra2">
                                                <input name="contato_consignatario" type="text" id="contato_consignatario" size="15" maxlength="30"
                                                       value="<%=carregaorc ? orcamento.getContatoConsignatario() : ""%>" class="fieldMin">
                                            </td>
                                            <td width="10%" class="TextoCampos">Fone:</td>
                                            <td width="14%" class="CelulaZebra2">
                                                <input name="fone_consignatario" type="text" id="fone_consignatario" size="15" maxlength="20"
                                                       value="<%=carregaorc ? orcamento.getFoneConsignatario() : ""%>" class="fieldMin">
                                            </td>
                                            <td width="18%" class="TextoCampos">E-mail:</td>
                                            <td class="CelulaZebra2">
                                                <input name="con_email" type="text" id="con_email" size="35" maxlength="120"
                                                       value="<%=carregaorc ? orcamento.getEmailConsignatario() : ""%>" class="fieldMin">
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Vendedor:</td>
                                <td colspan="3" class="CelulaZebra2">
                                    <strong>
                                        <input name="ven_rzs" type="text" id="ven_rzs" size="40" readonly class="inputReadOnly8pt" value="<%=(carregaorc ? orcamento.getVendedor().getRazaosocial() : "")%> " style="font-size:8pt;">
                                        <input type="button" class="inputBotaoMin" id="localiza_vendedor" value="..."
                                               onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.VENDEDOR%>', 'Vendedor')">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaVendedor()">
                                    </strong>
                                </td>
                                <td width="20%" class="TextoCampos">Validade Proposta:</td>
                                <td width="10%" class="CelulaZebra2">
                                    <input name="validade_proposta" type="text" id="validade_proposta" size="2" maxlength="9"
                                           onChange="seNaoIntReset(this,'0')" class="fieldMin" value="<%=(carregaorc ? orcamento.getValidadeProposta() : validadeProposta)%>">
                                    Dias
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr class="tabela">
                    <td colspan="8">
                        <div align="center">Dados da Carga</div>
                    </td>
                </tr>
                <tr>
                    <td colspan="8">
                        <table width="100%" border="0" cellspacing="1" cellpadding="2">
                            <tr>
                                <td width="16%" class="TextoCampos">Cidade Origem:</td>
                                <td width="34%" class="CelulaZebra2">
                                    <input name="cid_nome_origem" type="text" id="cid_nome_origem" value="<%=(orcamento != null ? orcamento.getCidadeOrigem().getDescricaoCidade() : "")%>" class="inputReadOnly8pt" size="26" maxlength="25" readonly="true">
                                    <input name="cid_uf_origem" type="text" id="cid_uf_origem" value="<%=(orcamento != null ? orcamento.getCidadeOrigem().getUf() : "")%>" class="inputReadOnly8pt" size="1" maxlength="25" readonly="true">
                                    <strong>
                                        <strong>
                                            <input type="button" class="inputBotaoMin" id="localiza_cidade" value="..."
                                                   onClick="javascript:window.open('./localiza?acao=consultar&idlista=11&paramaux='+$('idcidadedestino').value+'&paramaux2='+$('uf_destino').value,'Cidade','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                        </strong>
                                    </strong>
                                </td>
                                <td width="16%" class="TextoCampos">Cidade Destino:</td>
                                <td width="34%" class="CelulaZebra2">
                                    <input name="cid_destino" type="text" id="cid_destino" value="<%=(orcamento != null ? orcamento.getCidadeDestino().getDescricaoCidade() : "")%>" class="inputReadOnly8pt" size="26" maxlength="25" readonly="true">
                                    <input name="uf_destino" type="text" id="uf_destino" value="<%=(orcamento != null ? orcamento.getCidadeDestino().getUf() : "")%>" class="inputReadOnly8pt" size="1" maxlength="25" readonly="true">
                                    <strong>
                                        <input type="button" class="inputBotaoMin" id="localiza_cidade2" value="..."
                                               onClick="javascript:window.open('./localiza?acao=consultar&idlista=12&paramaux='+$('idcidadeorigem').value+'&paramaux2='+$('uf_origem').value,'Cidade_orcamento','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                    </strong>
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Distância:</td>
                                <td class="CelulaZebra2">
                                    <input name="distancia_km" type="text" id="distancia_km" value="<%=(orcamento != null ? orcamento.getDistanciaOrigemDestino() : "0")%>" size="8" maxlength="12" class="fieldMin" onBlur="javascript:seNaoIntReset(this,'0.00');" onChange="alteraTipoTaxa('N');">
                                    <label id="lbKm" name="lbKm">Km</label>
                                </td>
                                <td class="CelulaZebra2"></td>
                                <td class="CelulaZebra2"></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="8">
                        <table width="100%" border="0" cellspacing="1" cellpadding="2">
                            <tr>
                                <td width="15%" class="TextoCampos">Tipo de Produto:</td>
                                <td width="20%" class="CelulaZebra2">
                                    <div id="divTipoProduto" name="divTipoProduto">
                                        <select name="tipoproduto" id="tipoproduto" style="font-size:8pt;" onChange="alteraTipoTaxa('S')" class="fieldMin" style="width:110px;">
                                            <option value="0">Nenhum</option>
                                            <%
                                                ResultSet product_types = TipoProduto.all(Apoio.getConnectionFromUser(request), (orcamento.getClientePagador().equals("r") ? orcamento.getCliente().getIdcliente() : orcamento.getConsignatario().getIdcliente()), true,orcamento.getTipoProduto().getId());
                                                while (product_types.next()) {
                                            %>
                                                <script>
                                                        listOptTipoProd[idxTpProd++] = new Option("<%=product_types.getInt("id")%>", "<%=product_types.getString("descricao")%>");
                                                </script>
                                            <option value="<%=product_types.getString("id")%>"
                                                    style="background-color:#FFFFFF" <%=(carregaorc && product_types.getInt("id") == orcamento.getTipoProduto().getId() ? "Selected" : "")%>> <%=product_types.getString("descricao")%> 
                                            </option>
                                                
                                            <%}%>
                                        </select>
                                    </div>
                                </td>
                                <td width="14%" class="TextoCampos">Tipo de Tabela:</td>
                                <td width="17%" class="CelulaZebra2">
                                    <select name="tipofrete" id="tipofrete" style="font-size:8pt; " onChange="setTipofrete(this.value);alteraTipoTaxa('S')" class="fieldMin">
                                        <option value="-1">--Selecione--</option>
                                        <option value="0">Peso/Kg</option>
                                        <option value="1">Peso/Cubagem</option>
                                        <option value="2">% Nota Fiscal</option>
                                        <option value="3">Combinado</option>
                                        <option value="4">Por Volume</option>
                                        <option value="5">Por Km</option>
                                        <option value="6">Por Pallet</option>
                                    </select>
                                </td>
                                <td width="17%" class="TextoCampos">Tipo de Ve&iacute;culo:</td>
                                <td width="17%" class="CelulaZebra2">
                                    <select name="tip" id="tip" style="font-size:8pt;" onChange="alteraTipoTaxa('S')" class="fieldMin">
                                        <option value="-1"  Selected>Nenhum</option>
                                        <%ConsultaTipo_veiculos tipo = new ConsultaTipo_veiculos();
                                            tipo.setConexao(Apoio.getUsuario(request).getConexao());
                                            //alteracao referente a historia 3231
                                            tipo.mostraTipos(true, orcamento.getTipoVeiculo().getId());
                                            ResultSet rs = tipo.getResultado();

                                            while (rs.next()) {%>
                                        <option value="<%=rs.getString("id")%>" style="background-color:#FFFFFF" <%=(carregaorc && rs.getInt("id") == orcamento.getTipoVeiculo().getId() ? "Selected" : "")%>><%=rs.getString("descricao")%></option>
                                        
                                        <script>
                                                listOptTipoVeiculo[idxTpVeic++] = new Option("<%=rs.getInt("id")%>", "<%=rs.getString("descricao")%>");
                                        </script>
                                        <%}%>
                                    </select>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="8">
                        <table width="100%" border="0" cellspacing="1" cellpadding="2">
                            <tr>
                                <td width="8%" class="TextoCampos">Conteúdo:</td>
                                <td width="9%" class="CelulaZebra2">
                                    <input name="conteudo" type="text" id="conteudo" value="<%=(carregaorc ? orcamento.getConteudo() : "")%>" class="fieldMin" size="10" maxlength="30">
                                </td>
                                <td width="11%" class="TextoCampos">Valor Mercadoria:</td>
                                <td width="8%" class="CelulaZebra2">
                                    <input name="valorMercadoria" type="text" id="valorMercadoria"
                                           onChange="seNaoFloatReset(this,'0.00');alteraTipoTaxa('N');"
                                           size="7" maxlength="10" value="<%=(carregaorc ? Apoio.to_curr(orcamento.getVlMercadorias()) : "0.00")%>" class="fieldMin">
                                </td>
                                <td width="7%" class="TextoCampos">Peso(Kg):</td>
                                <td width="8%" class="CelulaZebra2">
                                    <input name="peso" type="text" id="peso" onChange="alteraTipoTaxa('N');seNaoFloatReset(this,'0.00');redespTxDestino();redespTxOrigem();"
                                           size="7" maxlength="10" value="<%=(carregaorc ? Apoio.roundABNT(orcamento.getPeso(), 3) : "0.00")%>" class="fieldMin">
                                </td>
                                <td width="7%" class="TextoCampos">Vol(s):</td>
                                <td width="8%" class="CelulaZebra2">
                                    <input name="volumes" type="text" id="volumes" onChange="seNaoFloatReset(this,'0.00');calculaMetroCubico();"
                                           size="4" maxlength="10" class="fieldMin" value="<%=(carregaorc ? Apoio.to_curr(orcamento.getVolume()) : "0.00")%>" style="font-size:8pt;">
                                    <img src="img/add.gif" border="0" onClick="addCubagem('0.00','0.00','0.00','0.00','0.00');"
                                         title="Adicionar Cubagem" class="imagemLink" align="absbottom">
                                </td>
                                <td width="3%" class="TextoCampos">M&sup3;:</td>
                                <td width="6%" class="CelulaZebra2">                                    
                                    <input name="metro" type="text" id="metro" onChange="seNaoFloatReset(this,'0.00');alteraTipoTaxa('N');"
                                           size="5" maxlength="10" value="<%=(carregaorc ? orcamento.getCubagemMetro() : "0.00")%>" class="fieldMin">
                                </td>
                                <td width="12%" class="TextoCampos">
                                    <div id="lbBaseCubagem" style="display:">Base Cub.:
                                        <input name="base" type="text" id="base" class="fieldMin" size="6" value="<%=(carregaorc ? Apoio.to_curr(orcamento.getBase()) : "0")%>" onChange="seNaoFloatReset(this,'0.00')" onblur="recalculaCubagens()">                                    
                                    </div>
                                </td>
                                <td width="12%" class="CelulaZebra2">
                                    <div id="divBaseCubagem" style="display:">
                                        Peso Cub.:
                                        <input name="pesoKgCubado" type="text" id="pesoKgCubado" readonly class="inputReadOnly8pt" size="6" value="<%=(carregaorc ? Apoio.to_curr(orcamento.getPesoCubado()) : "0")%>">            
                                    </div>
                                </td>

                            </tr>

                            <tr id="trCubagem" name="trCubagem" style="display:none;">
                                <td colspan="12">
                                    <table width="100%" border="0" cellspacing="1" cellpadding="2">
                                        <tbody id="cubagemBody" name="cubagemBody">
                                            <tr class="tabela">
                                                <td width="5%">&nbsp;</td>
                                                <td width="15%">
                                                    <div align="right">Volumes</div>
                                                </td>
                                                <td width="15%">
                                                    <div align="right">Comprimento</div>
                                                </td>
                                                <td width="15%">
                                                    <div align="right">Largura</div>
                                                </td>
                                                <td width="15%">
                                                    <div align="right">Altura</div>
                                                </td>
                                                <td width="10%">
                                                    <div align="right">M&sup3;</div>
                                                </td>
                                                <td width="15%">
                                                    <div align="right">Peso Cubado</div>
                                                </td>
                                                <td width="10%">&nbsp;</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>


                            <tr id="propVeiculo" name="propVeiculo" style="display:none;">
                                <td colspan="12">
                                    <table width="100%" border="0" cellspacing="1" cellpadding="2">
                                        <tr class="tabela">
                                            <td colspan="8">
                                                <div align="center">Dados do Veículo Transportado (Cegonha)</div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos" width="10%">Placa:</td>
                                            <td class="CelulaZebra2" width="15%">
                                                <input name="placa" type="text" id="placa" size="15" maxlength="30" class="fieldMin" value="<%=(orcamento != null ? orcamento.getPlaca() : "")%>">
                                            </td>
                                            <td class="TextoCampos" width="10%">Marca:</td>
                                            <td class="CelulaZebra2" width="15%">
                                                <input name="descricao" type="text" id="descricao" value="<%=(orcamento.getMarca().getDescricao() != null ? orcamento.getMarca().getDescricao() : "")%>" class="inputReadOnly8pt" size="10" maxlength="15" readonly="true">
                                                <input type="hidden" name="idmarca" type="text" id="idmarca" value="<%=(orcamento != null ? orcamento.getMarca().getIdmarca() : "")%>" class="inputReadOnly8pt" size="10" maxlength="15" readonly="true">
                                                <strong>
                                                    <strong>
                                                        <input type="button" class="inputBotaoMin" id="localiza_cidade" value="..."
                                                               onClick="javascript:window.open('./localiza?acao=consultar&idlista=00&paramaux='+$('descricao').value,'Marca','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                                    </strong>
                                                </strong>
                                            </td>
                                            <td class="TextoCampos" width="10%">Modelo:</td>
                                            <td class="CelulaZebra2" width="15%">
                                                <input name="modelo" type="text" id="modelo" size="15" maxlength="30" class="fieldMin" value="<%=(orcamento != null ? orcamento.getModelo() : "")%>">
                                            </td>
                                            <td class="TextoCampos" width="10%">Fab/Mod:</td>
                                            <td class="CelulaZebra2" width="15%">
                                                <input name="ano" type="text" id="ano" size="10" maxlength="30" class="fieldMin" value="<%=(orcamento != null ? orcamento.getAno() : "")%>">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos">Cor:</td>
                                            <td class="CelulaZebra2">
                                                <select name="cor" id="cor" class="fieldMin" >
                                                    <option value="0" selected>N&atilde;o Informado</option>
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
                                                    <option value="13">GREN&Aacute;</option>
                                                    <option value="14">MARROM</option>
                                                    <option value="15">ROSA</option>
                                                    <option value="16">FANTASIA</option>
                                                </select>
                                            </td>
                                            <td class="TextoCampos">Chassi:</td>
                                            <td class="CelulaZebra2">
                                                <input name="chassi" type="text" id="chassi" size="15" maxlength="30" class="fieldMin" value="<%=(orcamento != null ? orcamento.getChassi() : "")%>">
                                            </td>
                                            <td class="TextoCampos">Vlr Mercado:</td>
                                            <td class="CelulaZebra2">
                                                <input name="valorMercado" type="text" id="valorMercado" value="<%=Apoio.to_curr(orcamento.getValorMercado())%>" size="9" maxlength="12" class="fieldMin" onChange="javascript:seNaoFloatReset(this,'0.00');calculaFrete();">
                                            </td>
                                            <td class="TextoCampos"></td>
                                            <td class="CelulaZebra2"></td>
                                        </tr>   
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr class="tabela">
                    <td colspan="8">
                        <div align="center">C&aacute;lculo do Frete</div>
                    </td>
                </tr>
                <tr id="trFornecedor">
                    <td colspan="8">
                        <table width="100%" border="0" cellspacing="1" cellpadding="2">
                            <tr>
                                <td colspan="2" class="Celula">Representante da Coleta</td>
                                <td colspan="2" class="Celula">Representante da Entrega</td>
                            </tr>
                            <tr>
                                <td width="15%" class="TextoCampos">Razão Social:</td>
                                <td width="35%" class="CelulaZebra2">
                                    <input  name="redespachanteColeta" id="redespachanteColeta" value="<%=(carregaorc ? orcamento.getRepresentanteColeta().getRazaosocial() : ' ')%>" class="inputReadOnly8pt" size="30" readonly/>
                                    <input type="hidden" name="idredespachanteColeta" id="idredespachanteColeta" value="<%=(carregaorc ? orcamento.getRepresentanteColeta().getId() : 0)%>"/>
                                    <input type="button" class="inputBotaoMin" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REDESPACHANTE%>', 'Representante_Coleta')"/>
                                    <img src="img/borracha.gif" border="0"  class="imagemLink" title="" onClick="javascript:getObj('redespachanteColeta').value = '';javascript:getObj('idredespachanteColeta').value = '0';">
                                </td>
                                <td width="15%" class="TextoCampos">Razão Social:</td>
                                <td width="35%" class="CelulaZebra2">
                                    <input name="redespachanteEntrega" id="redespachanteEntrega" value="<%=(carregaorc ? orcamento.getRepresentanteEntrega().getRazaosocial() : ' ')%>" class="inputReadOnly8pt" size="30" readonly/>
                                    <input type="hidden" name="idredespachanteEntrega" id="idredespachanteEntrega" value="<%=(carregaorc ? orcamento.getRepresentanteEntrega().getId() : 0)%>"/>
                                    <input type="button" class="inputBotaoMin" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REDESPACHANTE2%>', 'Representante_Entrega')"/>
                                    <img src="img/borracha.gif" border="0"  class="imagemLink" title="" onClick="javascript:getObj('redespachanteEntrega').value = '';javascript:getObj('idredespachanteEntrega').value = '0';">
                                </td>                                
                            </tr>
                            <tr id="trDistancia">
                                <td class="TextoCampos" colspan="2">
                                    Aeroporto:
                                    <input name="aeroportoColeta" id="aeroportoColeta" class="inputReadOnly8pt" value="<%=(orcamento != null ? orcamento.getAeroportoColeta().getNome() : "")%>" size="13" readonly/>
                                    <input type="button" name="btAero" id="btAero" class="inputBotaoMin" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=73&paramaux='+$('idredespachanteColeta').value, 'Aeroporto_Coleta')" style="text-align: center"/>
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaAeroportoColeta()">
                                    <input name="aeroportoColetaId" id="aeroportoColetaId" type="hidden" value="<%=(orcamento != null ? orcamento.getAeroportoColeta().getId() : "0")%>"/>
                                    Distância:
                                    <input name="distancia_coleta" type="text" id="distancia_coleta" value="<%=(orcamento != null ? orcamento.getDistanciaColeta() : "0")%>" size="8" maxlength="12" class="inputReadOnly8pt" onBlur="javascript:seNaoIntReset(this,'0');" onChange="alteraTipoTaxa($('tipotaxa').value);redespTxOrigem();" readonly>
                                    <label id="lbKm" name="lbKm">Km</label>
                                </td>
                                <input type="hidden" id="aeroporto_id" name="aeroporto_id" value="0"/>
                                <input type="hidden" id="aeroporto" name="aeroporto" value=""/>
                                <td class="CelulaZebra2" colspan="2">
                                    Aeroporto:
                                    <input name="aeroportoEntrega" id="aeroportoEntrega" class="inputReadOnly8pt" value="<%=(orcamento != null ? orcamento.getAeroportoEntrega().getNome() : "")%>" size="13" readonly/>
                                    <input type="button" name="btAero" id="btAero" class="inputBotaoMin" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.AEROPORTO2%>&paramaux='+$('idredespachanteEntrega').value, 'Aeroporto_Entrega')" style="text-align: center"/>
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaAeroportoEntrega()">
                                    <input name="aeroportoEntregaId" id="aeroportoEntregaId" type="hidden" value="<%=(orcamento != null ? orcamento.getAeroportoEntrega().getId() : "0")%>"/>
                                    <!--<input name="cidade_aeroporto_id" id="cidade_aeroporto_id" type="hidden" value="<%=(orcamento != null ? orcamento.getAeroportoEntrega().getCidade().getIdcidade() : "0")%>"/>-->
                                    Distância:
                                    <input name="distancia_entrega" type="text" id="distancia_entrega" value="<%=(orcamento != null ? orcamento.getDistanciaEntrega() : "0")%>" size="8" maxlength="12" class="inputReadOnly8pt" onBlur="javascript:seNaoIntReset(this,'0');" onChange="alteraTipoTaxa($('tipotaxa').value);redespTxDestino();" readonly>
                                    <label id="lbKm" name="lbKm">Km</label>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="8">
                        <table width="100%" border="0" cellspacing="1" cellpadding="2">
                            <tr>
                                <td class="TextoCampos">
                                    <!--<div id="lbDistancia" style="display:none"></div>-->
                                    <div id="lbPallet" style="display:none">Pallets:</div>
                                </td>
                                <td class="CelulaZebra2">
                                    <!--<div id="divDistancia" style="display:none">-->
<!--                                        <input name="distanciaKm" class="fieldMin"type="text" id="distanciaKm" onChange="seNaoIntReset(this,'0');alteraTipoTaxa('N')"
                                               size="4" value="< %=(carregaorc ? orcamento.getQtdKm() : "0")%>" style="font-size:8pt;"> 
                                        Km-->
                                    <!--</div>-->                        
                                    <input name="qtdPallet" type="text" class="fieldMin" id="qtdPallet" onChange="seNaoIntReset(this,'0');alteraTipoTaxa('N')"
                                           size="4" value="<%=(carregaorc ? orcamento.getQuantidadePallets() : "0")%>" style="font-size:8pt;display:none;">
                                </td>
                                <td class="TextoCampos">Entregas:</td>
                                <td class="CelulaZebra2">
                                    <input name="qtdEntregas" type="text" id="qtdEntregas" onChange="seNaoIntReset(this,'1');calculataxaFixaTotal(this.value);alteraTipoTaxa('S');"
                                           size="3" maxlength="10" value="<%=(carregaorc ? orcamento.getQtdEntregas() : "1")%>" class="fieldMin">
                                </td>
                                <td class="TextoCampos">&nbsp;</td>
                                <td colspan="2" class="CelulaZebra2">
                                    <div align="right">
                                        <b>C&oacute;d. Tabela:</b>
                                    </div>
                                </td>
                                <td class="CelulaZebra2">
                                    <input name="tabelaId" type="text" id="tabelaId" size="3" value="<%=(carregaorc ? orcamento.getTabelaCliente().getId() : "0")%>" style="font-size:8pt;" class="fieldMin" readonly>
                                </td>
                                <td colspan="2" class="TextoCampos">
                                    <div align="left" >
                                        <input name="incluirIcms" type="checkbox" id="incluirIcms" value="checkbox" <%=carregaorc && orcamento.isIncluirIcms() ? "checked" : ""%> onClick="calculaFrete();">
                                        Incluir ICMS
                                    </div>
                                    <div align="left" >
                                        <input name="incluirFederais" type="checkbox" id="incluirFederais" value="checkbox" <%=carregaorc && orcamento.isIncluiFederais() ? "checked" : ""%> onClick="calculaFrete();">
                                        Incluir <label id="lbPisCofins">PIS/COFINS/IR/CSSL</label>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td width="14%" class="TextoCampos">
                                    <label id="lbTaxaFixa">Taxa fixa:</label>
                                </td>
                                <td width="18%" class="CelulaZebra2">
                                    <input name="taxaFixa" type="text" id="taxaFixa" onChange="seNaoFloatReset(this,'0.00');calculataxaFixaTotal(this.value);"
                                           size="5" maxlength="10" value="<%=(carregaorc ? Apoio.to_curr(orcamento.getTaxaFixa()) : "0.00")%>" class="fieldMin">
                                    = 
                                    <input name="taxaFixaTotal" type="text" id="taxaFixaTotal" onChange="seNaoFloatReset(this,'0.00');calculataxaFixaTotal(this.value);"
                                           size="5" maxlength="10" value="<%=(carregaorc ? Apoio.to_curr(orcamento.getTaxaFixaTotal()) : "0.00")%>" class="fieldMin">
                                </td>
                                <td width="11%" class="TextoCampos">Despacho:</td>
                                <td width="5%" class="CelulaZebra2">
                                    <input name="valor_despacho" type="text" id="valor_despacho" value="<%=Apoio.to_curr(orcamento.getValorDespacho())%>" size="5"
                                           maxlength="12" class="fieldMin" onChange="javascript:seNaoFloatReset(this,'0.00');calculaFrete();">
                                </td>
                                <td width="9%" class="TextoCampos">ADEME:</td>
                                <td width="5%" class="CelulaZebra2">
                                    <input name="valor_ademe" type="text" id="valor_ademe" value="<%=Apoio.to_curr(orcamento.getValorAdeme())%>" size="5"
                                           maxlength="12" class="fieldMin" onChange="javascript:seNaoFloatReset(this,'0.00');calculaFrete();" >
                                </td>
                                <td width="12%" class="TextoCampos">
                                    <div id="lbFretePeso">
                                        <b>Frete Peso:</b>
                                    </div>  
                                </td>
                                <td width="4%" class="CelulaZebra2">
                                    <input name="valor_peso" type="text" id="valor_peso" value="<%=Apoio.to_curr(orcamento.getValorFretePeso())%>" size="5"
                                           maxlength="12" class="fieldMin" onChange="javascript:seNaoFloatReset(this,'0.00');calculaFrete();calcularPeso();redespTxDestino();redespTxOrigem();">
                                </td>
                                <td width="12%" class="TextoCampos">
                                    <label id="lbFreteValor">
                                        <b>Frete Valor:</b>
                                    </label>
                                </td>
                                <td width="10%" class="CelulaZebra2">
                                    <input name="valor_frete" type="text" id="valor_frete" class="fieldMin" value="<%=Apoio.to_curr(orcamento.getValorFreteValor())%>"
                                           size="5" maxlength="12" onChange="javascript:seNaoFloatReset(this,'0.00');calculaFrete();calcularSeguro();">
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">ITR:</td>
                                <td class="CelulaZebra2">
                                    <input name="valor_itr" type="text" id="valor_itr" class="fieldMin" value="<%=Apoio.to_curr(orcamento.getValorItr())%>" size="5"
                                           maxlength="12" onChange="javascript:seNaoFloatReset(this,'0.00');calculaFrete();" >
                                </td>
                                <td class="TextoCampos">
                                    <input type="hidden" name="calculaSecCat" id="calculaSecCat" value="<%=orcamento.getCalculaSecCat()%>"/>
                                    <input type="checkbox" name="isCobraSecCat" id="isCobraSecCat" <%=orcamento.getConhecimento().isIsCalculaSecCat() ? "checked" : ""%> onClick="calculaFrete();">
                                    <label id="lbCobraSecCat">Cobrar </label>
                                    <label id="lbSecCat">SEC/CAT:</label>
                                </td>
                                <td class="CelulaZebra2">
                                    <input name="valor_sec_cat" type="text" id="valor_sec_cat" value="<%=Apoio.to_curr(orcamento.getValorSecCat())%>"
                                           size="5" maxlength="12" class="fieldMin" onChange="javascript:seNaoFloatReset(this,'0.00');calculaFrete();">
                                </td>
                                <td class="TextoCampos">Outros:</td>
                                <td class="CelulaZebra2">
                                    <input name="valor_outros" type="text" id="valor_outros" value="<%=Apoio.to_curr(orcamento.getValorOutros())%>" size="5"
                                           maxlength="12" class="fieldMin" onChange="javascript:seNaoFloatReset(this,'0.00');calculaFrete();" >
                                </td>
                                <td class="TextoCampos">GRIS:</td>
                                <td class="CelulaZebra2">
                                    <input name="valor_gris" type="text" id="valor_gris" value="<%=Apoio.to_curr(orcamento.getValorGris())%>" size="5"
                                           maxlength="12" class="fieldMin" onChange="javascript:seNaoFloatReset(this,'0.00');calculaFrete();">
                                </td>
                                <td class="TextoCampos">Ped&aacute;gio:</td>
                                <td class="CelulaZebra2">
                                    <input name="valor_pedagio" type="text" id="valor_pedagio" value="<%=Apoio.to_curr(orcamento.getValorPedagio())%>" size="5"
                                           maxlength="12" class="fieldMin" onChange="javascript:seNaoFloatReset(this,'0.00');calculaFrete();" >
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">&nbsp;</td>
                                <td class="CelulaZebra2">
                                    <div align="center" >
                                        <input name="incluirTDE" type="checkbox" id="incluirTDE" value="checkbox" <%=carregaorc && orcamento.isTde() ? "checked" : ""%> onClick="calculaFrete();">
                                        Cobrar TDE.
                                    </div>
                                </td>
                                <td class="TextoCampos">TDE:</td>
                                <td class="CelulaZebra2">
                                    <input name="valor_tde" type="text" id="valor_tde" class="fieldMin" value="<%=Apoio.to_curr(orcamento.getValorTde())%>" size="5"
                                           maxlength="12" onChange="javascript:seNaoFloatReset(this,'0.00');calculaFrete();" >
                                </td>
                                <!--<td class="TextoCampos"><label  style="float:left">R$</label></td>-->
                                <td class="TextoCampos">
                                    <span class="TextoCampos style1 style3">Desconto:</span>
                                </td>
                                <td class="CelulaZebra2" colspan="2">
                                    R$ <input name="valor_desconto" type="text" id="valor_desconto" value="<%=Apoio.to_curr(orcamento.getValorDesconto())%>" size="5"
                                              maxlength="12" class="fieldMin" style="color:#FF0000" onChange="javascript:seNaoFloatReset(this,'0.00');calculaFrete();">
                                    <label id="lblPercentualDesc">% <input name="percentual_desconto" type="text" id="percentual_desconto" value="<%=Apoio.to_curr(orcamento.getPercentualDesconto())%>" size="5"
                                                                           maxlength="12" class="fieldMin" style="color:#FF0000" onChange="javascript:seNaoFloatReset(this,'0.00');calculaFrete();alteraDesconto();"></label>
                                </td>
                                <td class="CelulaZebra2" colspan="3">
                                    <label id="lblIsDescFreteNacional"><input type="checkbox" name="isDescFreteNacional" id="isDescFreteNacional" onclick="calculaFrete();" <%=carregaorc && orcamento.isDescontoFreteNacional() ? "checked" : ""%>>
                                        Desconto no Frete Nacional</label>
                                        <br/>
                                    <label id="lblIsDescAdvalorem"> 
                                        <input type="checkbox" name="isDescAdvalorem" id="isDescAdvalorem" onclick="calculaFrete();" <%=carregaorc && orcamento.isDescontoAdvalorem() ? "checked" : ""%> >
                                        Desconto no ADVALOREM</label>
                                </td>
                                <!--                                <td class="CelulaZebra2">&nbsp;</td>-->
                                <!--                                <td class="CelulaZebra2">&nbsp;</td>-->
                            </tr>
                            <tr>
                                <td class="TextoCampos">
                                    <b>TOTAL PREST.:</b>
                                </td>
                                <td class="CelulaZebra2">
                                    <input name="totalPrestacao" type="text" id="totalPrestacao" value="0.00" size="5" style="font-size:8pt;" class="inputReadOnly8pt" readonly>
                                </td>
                                <td class="TextoCampos">Base:</td>
                                <td class="CelulaZebra2">
                                    <input name="base_calculo" type="text" id="base_calculo" value="<%=Apoio.to_curr(orcamento.getValorBaseIcms())%>" size="5"
                                           maxlength="12" class="fieldMin" onChange="javascript:seNaoFloatReset(this,document.getElementById('totalPrestacao').value);calculaFrete()">
                                </td>
                                <td class="TextoCampos">Al&iacute;q.(%):</td>
                                <td class="CelulaZebra2">
                                    <input name="aliquota" type="text" id="aliquota" onChange="javascript:seNaoFloatReset(this,'0.00');calculaFrete();CalcularPercentCTENFSE();"
                                           class="fieldMin" size="5" maxlength="5" value="<%=Apoio.to_curr(orcamento.getValorAliquota())%>">
                                </td>
                                <td class="TextoCampos">ICMS:</td>
                                <td class="CelulaZebra2">
                                    <input name="icms" type="text" id="icms" value="0.00" size="5" maxlength="12" style="font-size:8pt;" class="inputReadOnly8pt" readonly>
                                </td>
                                <td class="TextoCampos">
                                    <label id="lbpis" name="lbpis">PIS/COFINS:</label>
                                </td>
                                <td class="CelulaZebra2">
                                    <input name="federaisImbutidos" type="text" id="federaisImbutidos" value="<%=Apoio.to_curr(orcamento.getValorFederaisImbutidos())%>" size="5"
                                           maxlength="12" style="font-size:8pt;" class="inputReadOnly8pt" onChange="javascript:seNaoFloatReset(this,'0.00');calculaFrete();" readOnly>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="100%">
                                    <table width="100%" id="detalheAerio" >
                                        <tr width="100%">
                                            <td class="TextoCampos" width="23%" style="font-size:8pt">
                                                Taxa peso/kg da companhia Aérea:
                                                <input id="valorPeso" class="fieldMin" type="text" 
                                                       onchange="javascript:seNaoFloatReset(this,'0.00');calculaFrete();totalFinanceiro();" 
                                                       maxlength="12" size="5" value="<%=Apoio.to_curr(orcamento.getValorPesoAnaliseAereo())%>" 
                                                       name="valorPeso" >
                                            </td>
                                            <td class="TextoCampos" style="font-size:8pt">
                                                Despesa coleta:
                                                <input type="text" id="despColeta" class="inputReadOnly8pt" onchange="javascript:seNaoFloatReset(this,'0.00');" size="5" readonly>

                                            </td>
                                            <td class="TextoCampos" style="font-size:8pt">
                                                Despesas entrega:
                                                <input type="text" id="despEntrega" class="inputReadOnly8pt" onchange="javascript:seNaoFloatReset(this,'0.00');" size="5" readonly>

                                            </td>
                                            <td class="TextoCampos" style="font-size:8pt">
                                                Custo Comercial:
                                                <input type="text" id="custoComercial" name="custoComercial" class="inputReadOnly8pt" value="0.00" onchange="javascript:seNaoFloatReset(this,'0.00');" size="5" readonly>

                                            </td>
                                            <td class="TextoCampos" style="font-size:8pt">
                                                Custo Administrativo
                                                <input type="text" id="custoAdministrativo" name="custoAdministrativo" class="inputReadOnly8pt" value="0.00" onchange="javascript:seNaoFloatReset(this,'0.00');" size="5" readonly>

                                            </td>
                                            <td class="TextoCampos" width="20%" style="font-size:8pt">
                                                <b>Resumo financeiro:</b>
                                                <input id="resumoFinanceiro" class="inputReadOnly8pt" type="text" 
                                                       readonly style="font-size:8pt;" size="5" value="" name="resumoFinanceiro">
                                            </td>
                                        </tr>
                                    </table>    
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                    <tr class="tabela" id="resumoMudancaTitulo">
                    <td colspan="8">
                        <div align="center">Resumo dos valores da mudança</div>
                    </td>
                </tr>
                <tr id="resumoMudancaCorpo">
                    <td colspan="8">
                <table width="100%">
                <tr>
                    <td class="TextoCampos" width="10%">Valor Frete:</td>
                    <td class="CelulaZebra2" width="10%">
                        <input name="valorFrete" type="text" id="valorFrete" size="10" maxlength="10" value="" 
                               onblur="seNaoFloatReset(this,'0.00');" onchange="CalcularPercent();calcularSubTotal();" class="inputReadOnly" readonly="true" style="font-size:8pt;">
                    </td>
                    <td class="TextoCampos" >Desconto:</td>
                    <td class="CelulaZebra2" colspan="2">
                        <select onblur="CalcularPercent();calcularSubTotal();"  class="fieldMin" name="formaDesconto" id="formaDesconto">
                            <option <%= carregaorc ? (orcamento.getTipoDescontoPercent().equals("P") ? "selected" : "") : ""%> value="P">%</option>
                            <option <%= carregaorc ? (orcamento.getTipoDescontoPercent().equals("R") ? "selected" : "") : ""%> value="R">R$</option>
                        </select>
                        <input name="percDesconto" id="percDesconto" size="3" onblur="CalcularPercent();calcularSubTotal();" onkeydown="mascara(this, soNumeros);" maxlength="3" class="fieldMin"  value="<%= Apoio.to_curr(orcamento.getDescontoPercent()) %>"> 
                        = <input name="totalDesconto" id="totalDesconto" maxlength="5" size="5" onchange="calcularSubTotal();" class="inputReadOnly" readonly="true">
                    </td>
                    <td class="TextoCampos" colspan="2">Sub total Frete:</td>
                    <td class="CelulaZebra2">
                        <input name="subTotal" id="subTotal" maxlength="8" size="8" class="inputReadOnly" readonly="true">
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos" >Seguro:</td>
                    <td class="CelulaZebra2">
                        <input name="seguro" id="seguro" maxlength="5" size="5" class="inputReadOnly" onchange="calculaGeralResumo();">
                    </td>
                    <td class="TextoCampos" >Embalagem:</td>
                    <td class="CelulaZebra2">
                        <input name="embalagemTotal" id="embalagemTotal" maxlength="5" size="5" class="inputReadOnly" readonly="true">
                    </td>
                    <td class="TextoCampos" >Serviços:</td>
                    <td class="CelulaZebra2">
                        <input name="servicosTotal" id="servicosTotal" maxlength="5" size="5" class="inputReadOnly" readonly="true" >
                    </td>
                    <td class="TextoCampos" >NFS-e ou CT-e:</td>
                    <td class="CelulaZebra2">
                        <select class="fieldMin" id="tipoTaxaMudanca" name="tipoTaxaMudanca" onblur="CalcularPercentCTENFSE();">
                            <option <%= carregaorc ? (orcamento.getTipoTaxaMudanca().equals("CTE" ) ? "selected" : "") : ""%> value="CTE" >CT-e</option>
                            <option <%= carregaorc ? (orcamento.getTipoTaxaMudanca().equals("NFSE")? "selected" : "") : ""%> value="NFSE">NFS-e</option>
                        </select>
                            <input name="NFSE_CTEPercent" id="NFSE_CTEPercent" maxlength="5" size="5" class="inputReadOnly" value="<%= (orcamento.getTipoTaxaMudanca().equals("CTE") ? "" : Apoio.getConfiguracao(request).getServicoMontagemCarga().getIss()) %>" readonly="true">%
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos" colspan="5"></td>
                    <td class="TextoCampos" colspan="2">Valor Imposto:</td>
                    <td class="CelulaZebra2"><input name="TotalImposto" id="TotalImposto" class="inputReadOnly" readonly="true" size="10" readonly="true"></td>
                </tr>
                <tr>
                    <td class="TextoCampos" colspan="5"></td>
                    <td class="TextoCampos" colspan="2">Total Geral:</td>
                    <td class="CelulaZebra2"><input name="TotalGeral" id="TotalGeral"  class="inputReadOnly" readonly="true" size="10" readonly="true"></td>
                </tr>
                    </table>
                    </td>
                </tr>
                <tr class="tabela">
                    <td colspan="8">
                        <div align="center">Dados da Entrega</div>
                    </td>
                </tr>
                <tr>
                    <td colspan="8">
                        <table width="100%" border="0" cellspacing="1" cellpadding="2">
                            <tr>
                                <td width="25%" class="TextoCampos">Previs&atilde;o de Embarque:</td>
                                <td width="25%" class="CelulaZebra2">
                                    <input name="dtembarque" type="text" id="dtembarque" size="10" maxlength="10" value="<%=carregaorc ? orcamento.getPrevisaoEmbarque() == null ? "" : fmt.format(orcamento.getPrevisaoEmbarque()) : ""%>"
                                           onblur="alertInvalidDate(this, true)" class="fieldDate" style="font-size:8pt;">
                                </td>
                                <td width="25%" class="TextoCampos">Previs&atilde;o de entrega:</td>
                                <td width="25%" class="CelulaZebra2">
                                    <input name="dtentrega" type="text" id="dtentrega" size="10" maxlength="10" value="<%=carregaorc ? orcamento.getPrevisaoEntrega() == null ? "" : fmt.format(orcamento.getPrevisaoEntrega()) : ""%>"
                                           onblur="alertInvalidDate(this, true)" class="fieldDate" style="font-size:8pt;">
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Observa&ccedil;&atilde;o:</td>
                                <td colspan="3" class="CelulaZebra2">
                                    <textarea name="observacao" cols="60" rows="4"  id="observacao" class="fieldMin"><%=(carregaorc ? orcamento.getObservacao() : "")%></textarea>
                                    <input type="button" class="inputBotaoMin" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=28','Observacao');" value="...">
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
            </div>
            <div id="tab2" name="tab2">
                <table width="80%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
                    
                        <tr class="tabela">
                            <td align="center" width="100%" colspan="8">
                                    Produtos
                                </td>
                        </tr>
                        <tr class="celula">
                                <td width="1%">
                                    <img onclick="addProdutosMudanca(null);" alt="addCampo" src="img/novo.gif" class="imagemLink"/>
                                </td>
                                <input type="hidden" name="max" id="max" value="0"/>
                                <td width="14%">Código</td>
                                <td width="30%">Descrição</td>                                
                                <td width="11%">Metro cúbico</td> 
                                <td width="11%">Peso Bruto</td>
                                <td width="11%">Quantidade</td>
                                <td width="11%">Valor</td>
                                <td width="11%">Total</td>

                                </tr>  
                        <tbody id="itensMudanca"></tbody>
                        <tr class="celula">
                            <td></td>
                            <td></td>
                            <td></td>
                            <td>
                                <input type="text" id="m3total" name="m3total" class="inputReadOnly styleValor" value="0" readonly="true" size="10">
                            </td>
                            <td>
                                <input id="pesoBrutoTotal" type="text" class="inputReadOnly styleValor" value="0" readonly="true" size="10" name="pesoBrutoTotal"/>
                            </td>
                            <td></td>                       
                            <td align="right">                                
                                Valor Total:                                 
                            </td>
                            <td colspan="1">
                                <input type="text" id="valorT" name="valorT" class="inputReadOnly styleValor" readonly="true" size="10">
                            </td>
                        </tr>
                </table><br>
                <table width="80%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
                    
                        <tr class="tabela">
                            <td align="center" width="100%" colspan="7">
                                    Embalagem
                                </td>
                                
                        <tr class="celula">
                                
                                <input type="hidden" name="max" id="max" value="0"/>
                                
                                <td width="50%" colspan="1" align="center">Descrição</td>
                                <td width="10%" colspan="1" align="right">Quantidade</td>
                                <td width="15%" colspan="1" align="right">Valor unitario</td>
                                <td width="15%" colspan="1" align="rightr">Total</td>

                                </tr>  
                        
                                
                                            <% int numero = 1; %>
                                <c:forEach var="embalagem" varStatus="status" items="<%=orcamento.getEmbalagem()%>">
                                                <tr>
                                                    <td class="CelulaZebra2"> 
                                                        ${embalagem.embalagem.descricao} 
                                                        <c:if test="${status.last}">
                                                            <input type="hidden" name="contEmbalagem" id="contEmbalagem" value="${status.count}">
                                                        </c:if>
                                                    </td>
                                                    <td class="CelulaZebra2NoAlign" align="right"> <input type="text" size="7" maxlength="7" class="inputTexto styleValor" id="quantidade_${status.count}" name="quantidade_${status.count}" value="${embalagem.quantidade}"
                                                                                     onkeydown="mascara(this, soNumeros);" onblur="totalizarEmbalagem(${status.count});calcularTotalEmbalagem();">
                                                    <input type="hidden" id="idEmbalagem_${status.count}" name="idEmbalagem_${status.count}" value="${embalagem.embalagem.id}">
                                                    <input type="hidden" id="idOrcEmbalagem_${status.count}" name="idOrcEmbalagem_${status.count}" value="${embalagem.id}"></td>
                                                    <td class="CelulaZebra2NoAlign" align="right"> <input type="text" size="10" maxlength="7" class="inputTexto styleValor" id="valorEmbalagem_${status.count}" name="valorEmbalagem_${status.count}" value="${embalagem.valor}" 
                                                                                     onblur="seNaoFloatReset(this,'0.00'), totalizarEmbalagem(${status.count});calcularTotalEmbalagem();"> </td>
                                                    <td class="CelulaZebra2NoAlign" align="right" ><input type="text" class="inputReadOnly8pt styleValor" id="totalEmbalagem_${status.count}" name="totalEmbalagem_${status.count}" readonly="" value="0"> </td>
                                                </tr>                                             
                                </c:forEach>
                                                    <tr>
                                                        <td class="CelulaZebra2NoAlign" align="right" colspan="3">
                                                        Total Geral das Embalagens:
                                                        </td>
                                                        <td class="CelulaZebra2NoAlign" align="right">
                                                            <input type="text" id="totalEmbalagens" name="totalEmbalagens" class="inputReadOnly styleValor" readonly="true">
                                                        </td>
                                                    </tr>
                                
                                
                                
                </table>
            </div>  
            <div class="panel" id="tab3">
                        <table width="80%" border="0" class="bordaFina" align="center">
                            <tr id="trTituloDistribuicao" name="trTituloDistribuicao" style="display: none;">
                                <td class="tabela">
                                    <div align="center">Rela&ccedil;&atilde;o dos CTRCs de entregas locais (Minutas)</div>
                                </td>
                            </tr>
                            <tr id="trAddTituloDistribuicao" name="trAddTituloDistribuicao" style="display: none;">
                                <td>
                                    <table border="0" cellpadding="1" cellspacing="1" width="100%">
                                        <tbody id="tbDistribuicao" name="tbDistribuicao">
                                            <tr>
                                                <td width="1%" class="celula">
                                                    <img src="img/add.gif" border="0" title="Adicionar um novo CTRC de distribuição" class="imagemLink" id="botAdd" onClick="javascript:tryRequestToServer(function(){selecionaCTRC();});">
                                                </td>
                                                <td width="10%" class="celula"><div align="left">CTRC</div></td>
                                                <td width="8%" class="celula"><div align="left">NF</div></td>
                                                <td width="10%" class="celula"><div align="left">Emiss&atilde;o</div></td>
                                                <td width="10%" class="celula"><div align="right">Valor</div></td>
                                                <td width="27%" class="celula"><div align="left">Destinat&aacute;rio</div></td>
                                                <td width="15%" class="celula"><div align="left">Bairro</div></td>
                                                <td width="20%" class="celula"><div align="left">Cidade</div></td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                            <tr id="trTotalTituloDistribuicao" name="trTotalTituloDistribuicao" style="display: none;">
                                <td colspan="10">
                                    <table border="0" cellpadding="1" cellspacing="1" width="100%">
                                        <tbody id="tbDistribuicao" name="tbDistribuicao">
                                            <tr>
                                                <td width="12%" class="celula">
                                                    <div align="right">
                                                         <label id="lbQtdDistribuicao" name="lbQtdDistribuicao">0 CTRC(s)</label>
                                                    </div>
                                                </td>
                                                <td width="10%" class="celula"><div align="right">TOTAL:</div></td>
                                                <td width="10%" class="celula">
                                                    <div align="right">
                                                        <label id="lbTotalDistribuicao" name="lbTotalDistribuicao">0.00</label>
                                                    </div>
                                                </td>
                                                <td width="68%" class="celula"></td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td class="tabela"><div align="center">Servi&ccedil;os</div></td>
                            </tr>
                            <tr id="trBotaoOS" name="trBotaoOS">
                                <!--<td class="CelulaZebra2"><input type="button" id="botAddOs" class="botoes" value="Adicionar servi&ccedil;os da OS" onClick="javascript:tryRequestToServer(function(){selecionaOS();});"></td>-->
                            </tr>
                            <tr>
                                <td colspan="10">
                                    <table border="0" cellpadding="0" cellspacing="0" style="width:100%; height:100%; border: 1 solid #000">
                                        <tbody id="node_servs">
                                            <tr class="cellNotes">
                                                <td width="4%"><img src="img/add.gif" border="0" title="Adicionar um novo serviço na OS" class="imagemLink" id="botAdd" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=36','Servico')"></td>
                                                <td width="25%">Servi&ccedil;o</td>
                                                <td width="15%">Complemento</td>
                                                <td width="10%"><div id="lbDias" name="lbDias" style="display:none">Dias</div></td>
                                                <td width="10%">Quant.</td>
                                                <td width="10%">Unit&aacute;rio</td>
                                                <td width="10%">Total</td>
                                                <td width="8%">Embutir ISS</td>
                                                <td width="8%">Coleta</td>
                                                <td></td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="10" >
                                    <table width="100%"  border="0">
                                        <tr>
                                            <td width="3%" align="center">
                                                <img src="img/plus.jpg" id="botShowImpostos" alt="Abrir" class="imagemLink" onclick="showTotalImpostos()" title="Mostrar os totais dos impostos."/>
                                            </td>
                                            <td width="17%" class="tabela">
                                                <div align="center">Totais dos Servi&ccedil;os</div>
                                            </td>
                                            <td width="11%" class="TextoCampos">Valor Bruto: </td>
                                            <td width="9%" class="CelulaZebra2">
                                                <span class="CelulaZebra2">
                                                    <input name="totalService" type="text" class="inputReadOnly" id="totalService"  onBlur="javascript:seNaoFloatReset(this,'0.00');" value="0.00" size="8" maxlength="12" readonly >
                                                </span>
                                            </td>
                                            <td width="9%" class="TextoCampos">Valor ISS:</td>
                                            <td width="9%" class="CelulaZebra2">
                                                <span class="CelulaZebra2">
                                                    <input name="totalISS" type="text" class="inputReadOnly" id="totalISS"  onBlur="javascript:seNaoFloatReset(this,'0.00');" value="0.00" size="8" maxlength="12" readonly >
                                                </span>
                                            </td>
                                            <td width="14%" class="TextoCampos">Valor ISS Retido: </td>
                                            <td width="9%" class="CelulaZebra2">
                                                <span class="CelulaZebra2">
                                                    <input name="totalISSRetido" type="text" class="inputReadOnly" id="totalISSRetido"  onBlur="javascript:seNaoFloatReset(this,'0.00');" value="0.00" size="8" maxlength="12" readonly>
                                                </span>
                                            </td>
                                            <td width="12%" class="TextoCampos">Valor L&iacute;quido: </td>
                                            <td width="10%" class="CelulaZebra2">
                                                <span class="CelulaZebra2">
                                                    <input name="valorLiquido" type="text" class="inputReadOnly" id="valorLiquido"  onBlur="javascript:seNaoFloatReset(this,'0.00');" value="0.00" size="8" maxlength="12" readonly onchange="carregarTotalGeralServicosParaResumo();" >
                                                </span>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr id="trTotalImpostos"style="display: none" >
                                <td width="3%" align="center" colspan="10">
                                    <table width="100%" class="bordaFina">
                                        <tr>
                                            <td class="TextoCampos" style="font-size: xx-small" width="2%" align="right">ISS:</td>
                                            <td class="TextoCampos" style="font-size: xx-small" width="4%" align="right"><label id="valorTotIss">0,00</label></td>                                            
                                            <td class="TextoCampos" style="font-size: xx-small" width="3%" align="right">INSS:</td>
                                            <td class="TextoCampos" style="font-size: xx-small" width="4%" align="right"><label id="valorTotInss">0,00</label></td>                                            
                                            <td class="TextoCampos" style="font-size: xx-small" width="3%" align="right">PIS:</td>
                                            <td class="TextoCampos" style="font-size: xx-small" width="4%" align="right"><label id="valorTotPis">0,00</label></td>                                            
                                            <td class="TextoCampos" style="font-size: xx-small" width="4%" align="right">COFINS:</td>
                                            <td class="TextoCampos" style="font-size: xx-small" width="4%" align="right"><label id="valorTotCofins">0,00</label></td>                                            
                                            <td class="TextoCampos" style="font-size: xx-small" width="2%" align="right">IR:</td>
                                            <td class="TextoCampos" style="font-size: xx-small" width="4%" align="right"><label id="valorTotIr">0,00</label></td>                                            
                                            <td class="TextoCampos" style="font-size: xx-small" width="3%" align="right">CSSL:</td>
                                            <td class="TextoCampos" style="font-size: xx-small" width="4%" align="right"><label id="valorTotCssl">0,00</label></td>                                            
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos" style="font-size: xx-small" width="4%" align="right">ISS Ret:</td>
                                            <td class="TextoCampos" style="font-size: xx-small" width="4%" align="right"><label id="valorTotIssRetido">0,00</label></td>
                                            <td class="TextoCampos" style="font-size: xx-small" width="5%" align="right">INSS Ret:</td>
                                            <td class="TextoCampos" style="font-size: xx-small" width="4%" align="right"><label id="valorTotInssRetido">0,00</label></td>
                                            <td class="TextoCampos" style="font-size: xx-small" width="4%" align="right">PIS Ret:</td>
                                            <td class="TextoCampos" style="font-size: xx-small" width="4%" align="right"><label id="valorTotPisRetido">0,00</label></td>
                                            <td class="TextoCampos" style="font-size: xx-small" width="6%" align="right">COFINS Ret:</td>
                                            <td class="TextoCampos" style="font-size: xx-small" width="4%" align="right"><label id="valorTotCofinsRetido">0,00</label></td>
                                            <td class="TextoCampos" style="font-size: xx-small" width="4%" align="right">IR Ret:</td>
                                            <td class="TextoCampos" style="font-size: xx-small" width="4%" align="right"><label id="valorTotIrRetido">0,00</label></td>
                                            <td class="TextoCampos" style="font-size: xx-small" width="3%" align="right">CSSL Ret:</td>
                                            <td class="TextoCampos" style="font-size: xx-small" width="4%" align="right"><label id="valorTotCsslRetido">0,00</label></td>
                                        </tr>
                                    </table>
                                </td>                                                    
                            </tr>
                        </table>
                </div>
                <div class="panel" id="tab4">
                    <table width="80%" border="0" class="bordaFina" align="center">
                        <tbody>
                            <tr class="CelulaZebra2NoAlign">
                                <td align='center' colspan="2" width="3%"><img src="img/add.gif" border="0" onClick="addComposicaoFrete(null, $('tbPreCalcFrete'))"
                                                                   title="Adicionar Simulação de Frete" class="imagemLink" align="absbottom"></td>
                                <td width="97%" colspan="11">
                                    <label>Adicionar Simulação de Frete</label>
                                    <input type="hidden" id="qtdCompFrete" name="qtdCompFrete" value="0" />
                                </td>
                            </tr>
                        </tbody>
                        <tbody id="tbPreCalcFrete"></tbody>
                    </table>
                </div>
              <div id="tab5">  
            <table width="80%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center" style='display: <%= carregaorc && nivelUser == 4 ? "" : "none" %>' >
                   <tr class="tabela">
                    <td colspan="8" align="center">Auditoria</td>
                </tr>
                <tr>
                    <td>
                        <%@include file="/gwTrans/template_auditoria.jsp" %>
                    </td>
                </tr>
                <tr>
                    <td colspan="8" >
                        <table width="100%" border="0">
                            <tr>
                                <td width="10%" class="TextoCampos">Incluso:</td>
                                <td width="40%" class="CelulaZebra2">
                                    Em:<%=fmt.format(orcamento.getCreatedAt())%>
                                    <br>
                                    Por: <%=(orcamento.getCreatedBy().getNome()== null ? (orcamento.getContatoUsuario().getContato()):orcamento.getCreatedBy().getNome() )%> 
                                </td>
                                <td width="10%" class="TextoCampos">Alterado:</td>
                                <td width="40%" class="CelulaZebra2">
                                    Em:<%=(orcamento.getUpdateAt() != null ? fmt.format(orcamento.getUpdateAt()) : "")%>
                                    <br>
                                    Por:<%=orcamento.getUpdatedBy().getNome()%> 
                                </td>
                            </tr>
                        </table>    
                    </td>
                </tr>
            </table>
              </div>                   
            <br/>
             <table width="80%" border="0" class="bordaFina" align="center">
                <tr class="CelulaZebra2">
                    <td colspan="8">
                        <div align="center">
                            <%if (!carregaorc || orcamento.isPodeExcluir()) {%>
                            <input name="botSalvar" type="button" class="botoes" id="botSalvar" value="Salvar"
                                   onClick="javascript:tryRequestToServer(function(){salvar();});">
                            <% } else if (!orcamento.isPodeExcluir()) {%>
                            <label class="style1 style3">
                               <%=carregaorc && !orcamento.isPodeExcluir() 
                                    ? (orcamento.getTipoTaxaMudanca().equals("CTE") ? "Vinculado ao CT " + orcamento.getConhecimento().getNumero() + " em " + fmt.format(orcamento.getConhecimento().getEmissaoEm()) 
                                    : (orcamento.getTipoTaxaMudanca().equals("NFSE")? "Vinculado a NFS " + orcamento.getVenda().getNumero() + " em " + fmt.format(orcamento.getVenda().getEmissaoEm()) 
                                    :"")
                                    ) : ""%>
                            </label>
                            <% }%>
                        </div>
                    </td>
                </tr>
            </table>
        </form>
    </body>
</html>
