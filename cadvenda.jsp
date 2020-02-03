<%@page import="br.com.gwsistemas.gwcte.averbacao.apisul.AverbacaoApisulBO100"%>
<%@page import="br.com.gwsistemas.gwcte.averbacao.ModeloDocumentoAverbacao"%>
<%@page import="br.com.gwsistemas.gwcte.averbacao.DocumentoAverbacao"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="nucleo.Auditoria.Auditoria"%>
<%@page import="com.sagat.bean.CadNotaFiscal"%>
<%@page import="conhecimento.orcamento.Cubagem"%>
<%@page import="com.sagat.bean.NotaFiscal"%>
<%@page import="com.sagat.bean.ItemNotaFiscal"%>
<%@page import="despesa.apropriacao.BeanApropDespesa"%>
<%@page import="despesa.duplicata.BeanDuplDespesa"%>
<%@page import="despesa.BeanDespesa"%>
<%@page import="mov_banco.conta.BeanConsultaConta"%>
<%@page import="despesa.especie.Especie"%>
<%@page import="cliente.tipoProduto.TipoProduto"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Collection"%>
<%@page import="conhecimento.BeanConhecimento"%>
<%@page import="java.util.Iterator"%>
<%@page import="venda.servico.BeanTipoServico"%>
<%@page import="com.thoughtworks.xstream.io.json.JettisonMappedXmlDriver"%>
<%@page import="com.thoughtworks.xstream.XStream"%>
<%@page import="net.sf.json.JSONObject"%>
<%@ page language="java" 
         contentType="text/html; charset=ISO-8859-1"
         import="nucleo.*, venda.*"
         pageEncoding="ISO-8859-1" %>

<%

    int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadvenda") : 0);
    int nivelUserFatura = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("lanfatura") : 0);
//   int nivelUserFl = (nivelUser == 0 ? 0 : Apoio.getUsuario(request).getAcesso("landespfl"));
    if (Apoio.getUsuario(request) == null || nivelUser == 0) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
    }
    int nivelComissao = Apoio.getUsuario(request).getAcesso("vercomissao");
    BeanConfiguracao cfg = null;
    BeanConsultaConta cta = null;
    cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    //Carregando as configurações
    cfg.CarregaConfig();
    String acao = (nivelUser == 0 ? "" : request.getParameter("acao"));

    boolean carrega_venda = acao.equals("editar");
    
    //validar se o cliente utiliza nfse g2ka
    boolean utilizacaoNFSeG2ka = Apoio.getUsuario(request).getFilial().isUtilizacaoNFSeG2ka();
   
    boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
    int idUsuario = Apoio.getUsuario(request).getIdusuario();
     
%>

<jsp:useBean id="venda" class="venda.BeanVenda" />
<jsp:useBean id="cadvenda" class="venda.BeanCadVenda" />
<jsp:setProperty property="*" name="venda"/>

<%	if (nivelUser >= 1) {
        cadvenda.setConexao(Apoio.getConnectionFromUser(request));
    } 

    SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
    //instanciando um formatador de simbolos

    boolean carregaorc = !(acao.equals("incluir") || acao.equals("atualizar") || acao.equals("iniciar") || acao.equals("excluir"));
    if (acao.equals("iniciar")) {
        carregaorc = true;
    }
    

    if (acao.equals("iniciar") || acao.equals("editar")) {
        cta = new BeanConsultaConta();
        cta.setConexao(Apoio.getUsuario(request).getConexao());
    }

    ResultSet rs2 = Tributacao.all("id,descricao,codigo", Apoio.getUsuario(request).getConexao());
    String taxes = "";
    String taxesGenerico = "";
    while (rs2.next()) {
        taxes += (taxes.equals("") ? "" : "!!-") + rs2.getInt("id") + ":.:" + rs2.getString("codigo") + " - " + rs2.getString("descricao");
    }
    rs2 = Tributacao.allGenericos("id,descricao,codigo", Apoio.getUsuario(request).getConexao());
    while (rs2.next()) {
        taxesGenerico += (taxesGenerico.equals("") ? "" : "!!-") + rs2.getInt("id") + ":.:" + rs2.getString("codigo") +  " - " +rs2.getString("descricao");
    }
    rs2.close();

    if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir"))) {
        //adicionando as duplicatas
        boolean isSuccess = false;
        if(acao.equals("atualizar") && Apoio.parseBoolean(request.getParameter("ckprotocoloAverbacao"))){
            AverbacaoBO averbacaoBO = new AverbacaoApisulBO100();
                DocumentoAverbacao documentoAverbacao = new DocumentoAverbacao();
                documentoAverbacao.setProtocolo(request.getParameter("protocoloAverbacao"));
                documentoAverbacao.setCodigoErro(null);
                documentoAverbacao.setDescricaoCompleta("Averbado com Sucesso!");
                documentoAverbacao.setCancelado(false);
                documentoAverbacao.getnFSe().getVenda().setId(nucleo.Apoio.parseInt(request.getParameter("id")));
                documentoAverbacao.getnFSe().setNumero(Apoio.parseInt(request.getParameter("nfiscal")));
                averbacaoBO.insertProtocoloAverbacao(documentoAverbacao, ModeloDocumentoAverbacao.NFSE);
                isSuccess = true;   
                
                
            venda.setTipo(request.getParameter("tipoNota"));
            venda.setNumeroCarga(request.getParameter("numCarga"));
            venda.setHouseAwb(request.getParameter("house_awb"));
            venda.setMasterAwb(request.getParameter("master_awb"));
            venda.setLocalColeta(request.getParameter("local_coleta"));
            venda.setEntrega(request.getParameter("entrega"));
            venda.getTipoProduto().setId(Apoio.parseInt(request.getParameter("tipoproduto")));
            venda.setIdMotorista(Apoio.parseInt(request.getParameter("idmotorista")));
            venda.getRemetente().setIdcliente(Apoio.parseInt(request.getParameter("idremetente")));
            venda.getRemetente().getCidade().setIdcidade(Apoio.parseInt(request.getParameter("idcidadeorigem")));
            venda.getDestinatario().setIdcliente(Apoio.parseInt(request.getParameter("iddestinatario")));
            venda.getDestinatario().getCidade().setIdcidade(Apoio.parseInt(request.getParameter("cidade_destino_id")));
            venda.setCtrcId(Apoio.parseInt(request.getParameter("numeroCtrcId")));
            
            
            // carregando as notas 
            int qNotas = Apoio.parseInt(request.getParameter("objCountIdxNotes"));
            NotaFiscal nf;
            Cubagem cubnf;
            ItemNotaFiscal itemnf;
            String sufix = "";
            int sale = venda.getId();

            for (int j = 1; j <= qNotas; ++j) {
                if (request.getParameter("nf_numero" + j + "_id0") != null) {

                    nf = new NotaFiscal();
                    nf.setIdnotafiscal(Apoio.parseInt(request.getParameter("nf_idnota_fiscal" + j + "_id0")));
                    nf.setNumero(request.getParameter("nf_numero" + j + "_id0"));
                    nf.setSerie(request.getParameter("nf_serie" + j + "_id0"));
                    nf.setEmissao(Apoio.paraDate(request.getParameter("nf_emissao" + j + "_id0")));
                    nf.setValor(Apoio.parseDouble(request.getParameter("nf_valor" + j + "_id0").replaceAll(",", ".")));
                    nf.setVl_base_icms(Apoio.parseFloat(request.getParameter("nf_base_icms" + j + "_id0").replaceAll(",", ".")));
                    nf.setVl_icms(request.getParameter("nf_icms" + j + "_id0").trim().equals("") ? 0 : Apoio.parseFloat(request.getParameter("nf_icms" + j + "_id0").replaceAll(",", ".")));
                    nf.setVl_icms_frete(request.getParameter("nf_icms_frete" + j + "_id0").trim().equals("") ? 0 : Apoio.parseFloat(request.getParameter("nf_icms_frete" + j + "_id0").replaceAll(",", ".")));
                    nf.setVl_icms_st(request.getParameter("nf_icms_st" + j + "_id0").trim().equals("") ? 0 : Apoio.parseFloat(request.getParameter("nf_icms_st" + j + "_id0").replaceAll(",", ".")));
                    nf.setPeso(Apoio.parseFloat(request.getParameter("nf_peso" + j + "_id0").replaceAll(",", ".")));
                    nf.setVolume(Apoio.parseFloat(request.getParameter("nf_volume" + j + "_id0").replaceAll(",", ".")));
                    nf.setEmbalagem(request.getParameter("nf_embalagem" + j + "_id0"));
                    nf.setConteudo(request.getParameter("nf_conteudo" + j + "_id0"));
                    nf.setPedido(request.getParameter("nf_pedido" + j + "_id0"));
                    nf.setLargura(Apoio.parseFloat(request.getParameter("nf_largura" + j + "_id0").replaceAll(",", ".")));
                    nf.setAltura(Apoio.parseFloat(request.getParameter("nf_altura" + j + "_id0").replaceAll(",", ".")));
                    nf.setComprimento(Apoio.parseFloat(request.getParameter("nf_comprimento" + j + "_id0").replaceAll(",", ".")));
                    nf.setMetroCubico(Apoio.parseFloat(request.getParameter("nf_metroCubico" + j + "_id0").replaceAll(",", ".")));
                    nf.getMarcaVeiculo().setIdmarca(Apoio.parseInt(request.getParameter("nf_id_marca_veiculo" + j + "_id0")));
                    nf.setModeloVeiculo(request.getParameter("nf_modelo_veiculo" + j + "_id0"));
                    nf.setAnoVeiculo(request.getParameter("nf_ano_veiculo" + j + "_id0"));
                    nf.setCorVeiculo(Apoio.parseInt(request.getParameter("nf_cor_veiculo" + j + "_id0")));
                    nf.setChassiVeiculo(request.getParameter("nf_chassi_veiculo" + j + "_id0"));
                    nf.setTipoDocumento(request.getParameter("nf_tipoDocumento" + j + "_id0"));
                    //novos campos
                    nf.setAgendado(new Boolean(request.getParameter("nf_is_agendado" + j + "_id0")));
                    nf.setDataAgenda(Apoio.paraDate(request.getParameter("nf_data_agenda" + j + "_id0")));
                    nf.setHoraAgenda(request.getParameter("nf_hora_agenda" + j + "_id0"));
                    nf.setObservacaoAgenda(request.getParameter("nf_obs_agenda" + j + "_id0"));

                    String ncfop = request.getParameter("nf_cfopId" + j + "_id0");
                    nf.getCfop().setIdcfop(ncfop != null && !ncfop.equals("null") ? Apoio.parseInt(ncfop) : 0);
                    //nf.getCfop().setCfop(request.getParameter("nf_cfop" + j + "_id" + sale));
                    nf.setChaveNFe(request.getParameter("nf_chave_nf" + j + "_id0"));
                    nf.setPrevisaoEm(Apoio.paraDate(request.getParameter("nf_previsao_entrega" + j + "_id0")));
                    nf.setPrevisaoAs(request.getParameter("nf_previsao_as" + j + "_id0"));
                    nf.getDestinatario().setIdcliente(Apoio.parseInt(request.getParameter("nf_id_destinatario" + j + "_id0")));

                    sufix = j + "_id" + sale;

                    int qtdItens = Apoio.parseInt(request.getParameter("maxItens" + sufix));

                    ItemNotaFiscal arINf[] = new ItemNotaFiscal[qtdItens + 1];
                    int it = 0;
                    for (int s = 0; s <= qtdItens; s++) {
                        if (request.getParameter("itemIdNota_" + sufix + s) != null) {
                            itemnf = new ItemNotaFiscal();
                            itemnf.setId(Apoio.parseInt(request.getParameter("itemId_" + sufix + s)));
                            itemnf.setDescricao(request.getParameter("itemDescricao_" + sufix + s));
                            itemnf.setQuantidade(Apoio.parseFloat(request.getParameter("itemQuantidade_" + sufix + s)));
                            itemnf.setValor(Apoio.parseFloat(request.getParameter("itemValor_" + sufix + s)));
                            itemnf.setIdNota(Apoio.parseInt(request.getParameter("itemIdNota_" + sufix + s)));
                            arINf[it] = itemnf;
                            it++;
                        }
                    }
                    nf.setItemNotaFiscal(arINf);

                    int qtdItensMetro = Apoio.parseInt(request.getParameter("maxItensMetro" + sufix));

                    Cubagem arCub[] = new Cubagem[qtdItensMetro + 1];
                    it = 0;

                    for (int s = 0; s <= qtdItensMetro; s++) {
                        if (request.getParameter("nf_metroId_" + sufix + s) != null) {
                            cubnf = new Cubagem();
                            cubnf.setId(Apoio.parseInt(request.getParameter("nf_metroId_" + sufix + s)));
                            cubnf.setAltura(Apoio.parseDouble(request.getParameter("nf_itemAltura_" + sufix + s)));
                            cubnf.setComprimento(Apoio.parseDouble(request.getParameter("nf_metroComprimento_" + sufix + s)));
                            cubnf.setLargura(Apoio.parseDouble(request.getParameter("nf_metroLargura_" + sufix + s)));
                            cubnf.setMetroCubico(Apoio.parseDouble(request.getParameter("nf_metroCubico_" + sufix + s)));
                            cubnf.setVolume(Apoio.parseDouble(request.getParameter("nf_metroVolume_" + sufix + s)));
                            arCub[it] = cubnf;
                            it++;
                        }
                    }
                    nf.setCubagens(arCub);

                    venda.getNotas().add(nf);
                }
            }
            cadvenda.setExecutor(Apoio.getUsuario(request));
            cadvenda.setConexao(Apoio.getConnectionFromUser(request));
            cadvenda.setVenda(venda);
            
            isSuccess = cadvenda.atualizaDadosNFSEConfirmada();
            
        }else{
        
        
        for (int i = 0; i <= Apoio.parseInt(request.getParameter("qtdParcelas")); ++i) {
            if (request.getParameter("parcel_id" + i) != null) {
                BeanDuplicata d = new BeanDuplicata();
                d.setId(Apoio.parseInt(request.getParameter("parcel_id" + i)));
                d.setDuplicata(Apoio.parseInt(request.getParameter("parcel_index" + i)));
                d.setDtvenc(Apoio.paraDate(request.getParameter("parcel_vence_em" + i)));
                d.setVlduplicata(Apoio.parseDouble(request.getParameter("parcel_valor" + i)));
                venda.getDuplicatas().add(d);
            }
        }

        //adicionando os servicos
        for (int e = 1; e <= Apoio.parseInt(request.getParameter("qtdServ")); ++e) {
            if (request.getParameter("id" + e) != null) {
                BeanVendaServico s = new BeanVendaServico();
                s.setId(Apoio.parseInt(request.getParameter("id" + e)));
                s.setDescricaoComplmentar(request.getParameter("servicoCompl" + e));
                s.getTipo_servico().setId(Apoio.parseInt(request.getParameter("id_servico" + e)));
                s.getTributacao().setId(Apoio.parseInt(request.getParameter("issTrib" + e)));
                s.setValor(Apoio.parseDouble(request.getParameter("vl_unitario" + e)));
                s.setIss(Apoio.parseDouble(request.getParameter("perc_iss" + e)));
                s.setQuantidade(Apoio.parseFloat(request.getParameter("qtd" + e)));
                s.setQtdDias(Apoio.parseInt(request.getParameter("qtdDias_" + e)));
                s.getInssTributacao().setId(Apoio.parseInt(request.getParameter("inssTrib" + e)));
                s.setInss(Apoio.parseDouble(request.getParameter("perc_inss" + e)));
                s.getPisTributacao().setId(Apoio.parseInt(request.getParameter("pisTrib" + e)));
                s.setPis(Apoio.parseDouble(request.getParameter("perc_pis" + e)));
                s.getCofinsTributacao().setId(Apoio.parseInt(request.getParameter("cofinsTrib" + e)));
                s.setCofins(Apoio.parseDouble(request.getParameter("perc_cofins" + e)));
                s.getIrTributacao().setId(Apoio.parseInt(request.getParameter("irTrib" + e)));
                s.setIr(Apoio.parseDouble(request.getParameter("perc_ir" + e)));
                s.getCsslTributacao().setId(Apoio.parseInt(request.getParameter("csslTrib" + e)));
                s.setCssl(Apoio.parseDouble(request.getParameter("perc_cssl" + e)));
                s.setEmbutirISS(request.getParameter("embutirISS_" + e) == null ? false : true);

                venda.getVenda_servicos().add(s);
            }
        }

        //adicionando as apropriacoes
        for (int e = 1; e <= Apoio.parseInt(request.getParameter("qtdAprop")); ++e) {
            if (request.getParameter("appropriation_id" + e) != null) {
                BeanApropriacao d = new BeanApropriacao();
                d.setIdmovimento(Apoio.parseInt(request.getParameter("appropriation_id" + e)));
                d.getPlanocusto().setIdconta(Apoio.parseInt(request.getParameter("idplanocusto" + e)));
                d.setValor(Apoio.parseFloat(request.getParameter("apropVl" + e)));
                d.getUnidadeCusto().setId(Apoio.parseInt(request.getParameter("idUndCusto" + e)));
                d.getVeiculo().setIdveiculo(Apoio.parseInt(request.getParameter("idPlVeiculo" + e)));
                venda.getApropriacoes().add(d);
            }
        }

        venda.setCreatedBy(Apoio.getUsuario(request));
        venda.setMotivoCancelamento(request.getParameter("motivoCancelamento"));
        venda.getFilial().setIdfilial(Apoio.parseInt(request.getParameter("idfilial")));
        venda.getAgencia().setId(Apoio.parseInt(request.getParameter("agency_id")));
        venda.getCfop().setIdcfop(Apoio.parseInt(request.getParameter("idcfop")));
        venda.getCliente().setIdcliente(Apoio.parseInt(request.getParameter("idconsignatario")));
        venda.getRemetente().setIdcliente(Apoio.parseInt(request.getParameter("idremetente")));
        venda.getRemetente().getCidade().setIdcidade(Apoio.parseInt(request.getParameter("idcidadeorigem")));
        venda.getDestinatario().setIdcliente(Apoio.parseInt(request.getParameter("iddestinatario")));
        venda.getDestinatario().getCidade().setIdcidade(Apoio.parseInt(request.getParameter("cidade_destino_id")));
        venda.getColeta().setId(Apoio.parseInt(request.getParameter("idcoleta")));
        venda.getVendedor().setIdfornecedor(Apoio.parseInt(request.getParameter("idvendedor")));
        venda.setComissaoVendedor(Apoio.parseDouble(request.getParameter("comissaovendedor")));
        venda.setEmissaoEm(request.getParameter("emissao_em"));
        venda.setCancelado(request.getParameter("is_cancelado") != null);
        venda.setHistorico(request.getParameter("descricao_historico"));
        venda.setPedidoCliente(request.getParameter("pedido_cliente"));
        String idnotaSubs = (request.getParameter("idnotasubs"));
        venda.getVendaSubs().setId(Apoio.parseInt(idnotaSubs != null ? idnotaSubs : "0"));
        venda.setTipo(request.getParameter("tipoNota"));
        venda.setCtrcId(Apoio.parseInt(request.getParameter("numeroCtrcId")));
        venda.setNumeroCarga(request.getParameter("numCarga"));
        venda.setNaturezaOperacao(Apoio.parseInt(request.getParameter("naturezaOperacao")));
        venda.setHouseAwb(request.getParameter("house_awb"));
        venda.setMasterAwb(request.getParameter("master_awb"));
        venda.setLocalColeta(request.getParameter("local_coleta"));
        venda.setEntrega(request.getParameter("entrega"));
        venda.getTipoProduto().setId(Apoio.parseInt(request.getParameter("tipoproduto")));
        //campo para o cliente detalhar melhor os servicos para envio NFS-e G2ka.        
        venda.setDescricaoServicoNFSeG2ka(request.getParameter("descricaoServico"));
        //Novo campo para a cidade, caso o cliente faça algum serviço fora do seu município, para NFS-e.
        venda.getCidadePrestacaoNFSeId().setIdcidade(Apoio.parseInt(request.getParameter("idcidade")));
        
        
        venda.setIdMotorista(Apoio.parseInt(request.getParameter("idmotorista")));
        
        //Adicionando os CTRCs de distribuição
        Collection listaCt = new ArrayList();
        BeanConhecimento ct = null;
        int qtdCt = Apoio.parseInt(request.getParameter("qtdDistribuicao"));
        int pp = 0;
        for (int i = 0; i <= qtdCt; i++) {
            ct = new BeanConhecimento();
            if (request.getParameter("ctrcId_" + i) != null) {
                ct.setId(Apoio.parseInt(request.getParameter("ctrcId_" + i)));
                listaCt.add(ct);
            }
        }
        venda.setCtrcsDistribuicao(listaCt);

        // carregando as notas 
        int qNotas = Apoio.parseInt(request.getParameter("objCountIdxNotes"));
        NotaFiscal nf;
        Cubagem cubnf;
        ItemNotaFiscal itemnf;
        String sufix = "";
        int sale = venda.getId();
        int h = 0;

        for (int j = 1; j <= qNotas; ++j) {
            if (request.getParameter("nf_numero" + j + "_id0") != null) {

                nf = new NotaFiscal();
                nf.setIdnotafiscal(Apoio.parseInt(request.getParameter("nf_idnota_fiscal" + j + "_id0")));
                nf.setNumero(request.getParameter("nf_numero" + j + "_id0"));
                nf.setSerie(request.getParameter("nf_serie" + j + "_id0"));
                nf.setEmissao(Apoio.paraDate(request.getParameter("nf_emissao" + j + "_id0")));
                nf.setValor(Apoio.parseDouble(request.getParameter("nf_valor" + j + "_id0").replaceAll(",", ".")));
                nf.setVl_base_icms(Apoio.parseFloat(request.getParameter("nf_base_icms" + j + "_id0").replaceAll(",", ".")));
                nf.setVl_icms(request.getParameter("nf_icms" + j + "_id0").trim().equals("") ? 0 : Apoio.parseFloat(request.getParameter("nf_icms" + j + "_id0").replaceAll(",", ".")));
                nf.setVl_icms_frete(request.getParameter("nf_icms_frete" + j + "_id0").trim().equals("") ? 0 : Apoio.parseFloat(request.getParameter("nf_icms_frete" + j + "_id0").replaceAll(",", ".")));
                nf.setVl_icms_st(request.getParameter("nf_icms_st" + j + "_id0").trim().equals("") ? 0 : Apoio.parseFloat(request.getParameter("nf_icms_st" + j + "_id0").replaceAll(",", ".")));
                nf.setPeso(Apoio.parseFloat(request.getParameter("nf_peso" + j + "_id0").replaceAll(",", ".")));
                nf.setVolume(Apoio.parseFloat(request.getParameter("nf_volume" + j + "_id0").replaceAll(",", ".")));
                nf.setEmbalagem(request.getParameter("nf_embalagem" + j + "_id0"));
                nf.setConteudo(request.getParameter("nf_conteudo" + j + "_id0"));
                nf.setPedido(request.getParameter("nf_pedido" + j + "_id0"));
                nf.setLargura(Apoio.parseFloat(request.getParameter("nf_largura" + j + "_id0").replaceAll(",", ".")));
                nf.setAltura(Apoio.parseFloat(request.getParameter("nf_altura" + j + "_id0").replaceAll(",", ".")));
                nf.setComprimento(Apoio.parseFloat(request.getParameter("nf_comprimento" + j + "_id0").replaceAll(",", ".")));
                nf.setMetroCubico(Apoio.parseFloat(request.getParameter("nf_metroCubico" + j + "_id0").replaceAll(",", ".")));
                nf.getMarcaVeiculo().setIdmarca(Apoio.parseInt(request.getParameter("nf_id_marca_veiculo" + j + "_id0")));
                nf.setModeloVeiculo(request.getParameter("nf_modelo_veiculo" + j + "_id0"));
                nf.setAnoVeiculo(request.getParameter("nf_ano_veiculo" + j + "_id0"));
                nf.setCorVeiculo(Apoio.parseInt(request.getParameter("nf_cor_veiculo" + j + "_id0")));
                nf.setChassiVeiculo(request.getParameter("nf_chassi_veiculo" + j + "_id0"));
                nf.setTipoDocumento(request.getParameter("nf_tipoDocumento" + j + "_id0"));
                //novos campos
                nf.setAgendado(new Boolean(request.getParameter("nf_is_agendado" + j + "_id0")));
                nf.setDataAgenda(Apoio.paraDate(request.getParameter("nf_data_agenda" + j + "_id0")));
                nf.setHoraAgenda(request.getParameter("nf_hora_agenda" + j + "_id0"));
                nf.setObservacaoAgenda(request.getParameter("nf_obs_agenda" + j + "_id0"));

                String ncfop = request.getParameter("nf_cfopId" + j + "_id0");
                nf.getCfop().setIdcfop(ncfop != null && !ncfop.equals("null") ? Apoio.parseInt(ncfop) : 0);
                //nf.getCfop().setCfop(request.getParameter("nf_cfop" + j + "_id" + sale));
                nf.setChaveNFe(request.getParameter("nf_chave_nf" + j + "_id0"));
                nf.setPrevisaoEm(Apoio.paraDate(request.getParameter("nf_previsao_entrega" + j + "_id0")));
                nf.setPrevisaoAs(request.getParameter("nf_previsao_as" + j + "_id0"));
                nf.getDestinatario().setIdcliente(Apoio.parseInt(request.getParameter("nf_id_destinatario" + j + "_id0")));

                sufix = j + "_id" + sale;

                int qtdItens = Apoio.parseInt(request.getParameter("maxItens" + sufix));

                ItemNotaFiscal arINf[] = new ItemNotaFiscal[qtdItens + 1];
                int it = 0;
                for (int s = 0; s <= qtdItens; s++) {
                    if (request.getParameter("itemIdNota_" + sufix + s) != null) {
                        itemnf = new ItemNotaFiscal();
                        itemnf.setId(Apoio.parseInt(request.getParameter("itemId_" + sufix + s)));
                        itemnf.setDescricao(request.getParameter("itemDescricao_" + sufix + s));
                        itemnf.setQuantidade(Apoio.parseFloat(request.getParameter("itemQuantidade_" + sufix + s)));
                        itemnf.setValor(Apoio.parseFloat(request.getParameter("itemValor_" + sufix + s)));
                        itemnf.setIdNota(Apoio.parseInt(request.getParameter("itemIdNota_" + sufix + s)));
                        arINf[it] = itemnf;
                        it++;
                    }
                }
                nf.setItemNotaFiscal(arINf);

                int qtdItensMetro = Apoio.parseInt(request.getParameter("maxItensMetro" + sufix));

                Cubagem arCub[] = new Cubagem[qtdItensMetro + 1];
                it = 0;

                for (int s = 0; s <= qtdItensMetro; s++) {
                    if (request.getParameter("nf_metroId_" + sufix + s) != null) {
                        cubnf = new Cubagem();
                        cubnf.setId(Apoio.parseInt(request.getParameter("nf_metroId_" + sufix + s)));
                        cubnf.setAltura(Apoio.parseDouble(request.getParameter("nf_itemAltura_" + sufix + s)));
                        cubnf.setComprimento(Apoio.parseDouble(request.getParameter("nf_metroComprimento_" + sufix + s)));
                        cubnf.setLargura(Apoio.parseDouble(request.getParameter("nf_metroLargura_" + sufix + s)));
                        cubnf.setMetroCubico(Apoio.parseDouble(request.getParameter("nf_metroCubico_" + sufix + s)));
                        cubnf.setVolume(Apoio.parseDouble(request.getParameter("nf_metroVolume_" + sufix + s)));
                        arCub[it] = cubnf;
                        it++;
                    }
                }
                nf.setCubagens(arCub);

                venda.getNotas().add(nf);
                h++;
            }
        }

        //Carregando as despesas agregadas
        int qtdNotas = Apoio.parseInt(request.getParameter("qtdNotas"));
        BeanDespesa[] dp = new BeanDespesa[qtdNotas];
        for (int x = 0; x < qtdNotas; ++x) {
            if (request.getParameter("tipoDesp" + x) != null && request.getParameter("idNota" + x).equals("0")) {
                dp[x] = new BeanDespesa();
                dp[x].getFilial().setIdfilial(Apoio.parseInt(request.getParameter("idfilial")));


                dp[x].setAVista(request.getParameter("tipoDesp" + x).equals("a") ? true : false);
                dp[x].getEsp().setId(Apoio.parseInt(request.getParameter("especie" + x)));


                dp[x].setSerie(request.getParameter("serie" + x));
                dp[x].setNfiscal(request.getParameter("nf" + x));
                dp[x].setDtEmissao(Apoio.paraDate(request.getParameter("dataNota" + x)));
                dp[x].setDtEntrada(Apoio.paraDate(request.getParameter("dataNota" + x)));
                dp[x].setCompetencia(request.getParameter("dataNota" + x).substring(3, 10));
                dp[x].getFornecedor().setIdfornecedor(Apoio.parseInt(request.getParameter("idfornecedor" + x)));
                dp[x].getHistorico().setIdHistorico(Apoio.parseInt(request.getParameter("idhistoricoNota" + x)));
                dp[x].setDescHistorico(request.getParameter("historicoNota" + x));
                dp[x].setValor(Apoio.parseFloat(request.getParameter("valorNota" + x)));
                //atribuindo as parcelas
                BeanDuplDespesa[] du = new BeanDuplDespesa[1];
                du[0] = new BeanDuplDespesa();
                du[0].setDtvenc(Apoio.paraDate(request.getParameter("dataNota" + x)));
                du[0].setVlduplicata(Apoio.parseFloat(request.getParameter("valorNota" + x)));
                //Caso o lançamento seja a vista
                if (dp[x].isAVista()) {
                    du[0].setBaixado(true);
                    du[0].setVlduplicata(Apoio.parseFloat(request.getParameter("valorNota" + x)));
                    du[0].setVlacrescimo(0);
                    du[0].setVldesconto(0);
                    du[0].getFpag().setIdFPag(request.getParameter("chqDespCarta_" + x) == null ? 1 : 3);
                    du[0].setVlpago(Apoio.parseFloat(request.getParameter("valorNota" + x)));
                    du[0].setDtpago(Apoio.paraDate(request.getParameter("dataNota" + x)));
                    //movimentacao bancaria
                    du[0].getMovBanco().setConciliado(false);
                    du[0].getMovBanco().getConta().setIdConta(Apoio.parseInt(request.getParameter("contaDespesa_" + x)));
                    du[0].getMovBanco().setValor(Apoio.parseFloat(request.getParameter("valorNota" + x)));
                    du[0].getMovBanco().setDtEntrada(Apoio.paraDate(request.getParameter("dataNota" + x)));
                    du[0].getMovBanco().setDtEmissao(Apoio.paraDate(request.getParameter("dataNota" + x)));
                    du[0].getMovBanco().getHistorico_id().setIdHistorico(Apoio.parseInt(request.getParameter("idhistoricoNota" + x)));
                    du[0].getMovBanco().setHistorico(request.getParameter("historicoNota" + x));
                    du[0].getMovBanco().setCheque(true);

                    if (cfg.isControlarTalonario() && (request.getParameter("isCheque_" + x) != null ? true : false)) {
                        du[0].getMovBanco().setDocum(request.getParameter("docDespCarta_cb_" + x));
                    } else {
                        du[0].getMovBanco().setDocum(request.getParameter("docDespCarta_" + x));
                    }
                    du[0].getMovBanco().setNominal("");
                }
                dp[x].setDuplicatas(du);

                //atribuindo as apropriacoes
                int qtdApp = Apoio.parseInt(request.getParameter("qtdApp"));
                BeanApropDespesa[] ap = new BeanApropDespesa[qtdApp];
                int j = 0; //Não posso utilizar o y pois o array do jsp não está na ordem correta da despesa.
                for (int y = 0; y < qtdApp; ++y) {
                    if (request.getParameter("idApropriacao_" + x + "_" + y) != null) {
                        ap[j] = new BeanApropDespesa();
                        ap[j].getPlanocusto().setIdconta(Apoio.parseInt(request.getParameter("idApropriacao_" + x + "_" + y)));
                        ap[j].getFilial().setIdfilial(Apoio.parseInt(request.getParameter("idfilial")));
                        ap[j].getVeiculo().setIdveiculo(Apoio.parseInt(request.getParameter("idVeiculo_" + x + "_" + y)));
                        ap[j].getUndCusto().setId(Apoio.parseInt(request.getParameter("idUnd_" + x + "_" + y)));
                        ap[j].setValor(Apoio.parseFloat(request.getParameter("valorApp_" + x + "_" + y)));
                        j++;
                    }
                }
                dp[x].setApropriacoes(ap);
            }
        }
        venda.setDespesa(dp);

        cadvenda.setVenda(venda);

        cadvenda.setExecutor(Apoio.getUsuario(request));

        

        if (acao.equals("incluir")) {
            isSuccess = cadvenda.Inclui();
        } else if (acao.equals("atualizar")) {
            isSuccess = cadvenda.Atualiza();
        }
    }
        if (!isSuccess) {
            if(cadvenda.getErros().indexOf("sales_numero_key")> -1){
                response.getWriter().append("<script>alert('Nota de Serviço já cadastrada com a mesma Série, Espécie e Filial!');window.close();</script>");
            }else{                
                response.getWriter().append("<script>alert('" + cadvenda.getErros() + "');window.close();</script>");
            }
        } else {
            response.getWriter().append("<script>window.opener.voltar(); window.close();</script>");
        }
        response.getWriter().close();

    
    } else if (acao.equals("excluir") && nivelUser > 3) {
        cadvenda.getVenda().setId(Apoio.parseInt(request.getParameter("id")));
        cadvenda.setExecutor(Apoio.getUsuario(request));
        cadvenda.Deleta();
        
        String mensagemErro = "";
        if(cadvenda.getErros().indexOf("fatura_contrato_receita_receita_id_fkey") > -1){
            mensagemErro = "Atenção: Você não pode excluir a nota fiscal de serviço "+ cadvenda.getVenda().getId() +", pois já existe contrato faturado.";
        }else{
            mensagemErro = cadvenda.getErros();            
        }
        
        response.getWriter().append("err<=>" + mensagemErro);
        response.getWriter().close();
    } else if (carrega_venda && nivelUser > 0) {
        cadvenda.getVenda().setId(Apoio.parseInt(request.getParameter("id")));
        cadvenda.setExecutor(Apoio.getUsuario(request));
        if (cadvenda.LoadAllPropertys()) {
            venda = cadvenda.getVenda();
        }
    } else if (acao.equals("get_next_sale")) {
        cadvenda.setExecutor(Apoio.getUsuario(request));
        response.getWriter().append(cadvenda.getNextSale(request.getParameter("serie"),
                request.getParameter("especie"),
                Apoio.parseInt(request.getParameter("idfilial")),
                Apoio.parseInt(request.getParameter("agency_id")), 'N', false)
                + "<=>" + cadvenda.getErros());
        response.getWriter().close();
    } else if (acao.equals("iniciar")) {
        String serieAtual = "";
        if (Apoio.getUsuario(request).getFilial().getStUtilizacaoNfse() == 'M' && !Apoio.getUsuario(request).getFilial().getCidade().getCod_ibge().equals("5201108")) {
            serieAtual = "RPS";
        } else {
            serieAtual = cfg.getSeriePadraoNotaServico();
        }
        cadvenda.setExecutor(Apoio.getUsuario(request));
        venda.setNumero(cadvenda.getNextSale(serieAtual, venda.getEspecie(),
                Apoio.getUsuario(request).getFilial().getIdfilial(),
                Apoio.getUsuario(request).getAgencia().getId(), 'N', false));
    } else if (acao.equals("removerNotaFiscalAjax")) {
        //quando for colocar no gweb, use o controlador da nota
     
        Auditoria auditoria = new Auditoria();
        auditoria.setIp(request.getRemoteHost());
        auditoria.setAcao("Remover Nota Fiscal");        
        auditoria.setRotina("Alterar Nota Fiscal");
        auditoria.setUsuario(Apoio.getUsuario(request));
        auditoria.setModulo("WebTrans NF");        
        
        CadNotaFiscal.removerNota(Apoio.parseInt(request.getParameter("idNota")), Apoio.getUsuario(request).getConexao(), auditoria);
    } else if (acao.equals("carregar_subs_json")) {
        cadvenda.getVenda().setId(Apoio.parseInt(request.getParameter("idnotasubs")));
        cadvenda.setExecutor(Apoio.getUsuario(request));
        if (cadvenda.LoadAllPropertys()) {
            venda = cadvenda.getVenda();
        }

        venda.setApropriacoes(null);
        venda.setCreatedBy(null);
        venda.setUpdatedBy(null);
        venda.setDuplicatas(null);

        XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
        xstream.setMode(XStream.NO_REFERENCES);
        xstream.alias("venda", BeanVenda.class);
        xstream.alias("vendaserv", BeanVendaServico.class);
        xstream.alias("tiposerv", venda.servico.BeanTipoServico.class);

        String json = xstream.toXML(venda).replace("\"false\"", "false").replace("\"true\"", "true");

        response.getWriter().append(json);
        response.getWriter().close();
    }
%>

<%@page import="conhecimento.duplicata.BeanDuplicata"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="venda.Tributacao"%>
<%@page import="conhecimento.apropriacao.BeanApropriacao"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DecimalFormatSymbols"%>
<%@page import="java.text.DecimalFormat"%>
<%@ page import="br.com.gwsistemas.gwcte.averbacao.AverbacaoBO" %>
<html>
<head>
    <!-- <script src="script/funcoes.js"   type="text/javascript"></script> comentando pois esta duplicado        -->
    <script language="JavaScript" src="script/<%=Apoio.noCacheScript("builder.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("prototype.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("notaFiscal-util.js")%>" type="text/javascript"></script>
        <script type="text/javascript" src="script/<%=Apoio.noCacheScript("fabtabulous.js")%>"></script>
        <script type="text/javascript" src="script/<%=Apoio.noCacheScript("ImpostoServico.js")%>"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("jquery.js")%>" type="text/javascript"></script>
        <!--<script language="JavaScript" src="script/servicos-util_backup..js" type="text/javascript"></script>-->
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("servicos-util.js")%>" type="text/javascript"></script>
        
        <script language="javascript" src="script/<%=Apoio.noCacheScript("funcoes.js")%>"></script>
        <!--<script language="javascript" type="text/javascript" src="script/< %=Apoio.noCacheScript("builder.js")%>"></script> comentando pois esta duplicado -->
        <!--<script language="javascript" src="script/< %=Apoio.noCacheScript("prototype.js")%>" type=""></script> comentando pois esta duplicado-->
        <!--<script language="javascript" src="script/funcoes.js" type=""></script> comentando pois esta duplicado-->
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("aliquotaIcmsCtrc.js")%>" type="text/javascript"></script>
        <script language="javascript" src="script/<%=Apoio.noCacheScript("tabelaFrete.js")%>" type=""></script>
        <script language="javascript" src="script/<%=Apoio.noCacheScript("funcoesTelaCtrc.js")%>" type=""></script>
        <script language="JavaScript" type="text/javascript" src="script/<%=Apoio.noCacheScript("LogAcoesAuditoria.js")%>"></script>

        <link href="estilo.css"  media="screen" rel="Stylesheet" type="text/css" />
        <link rel="stylesheet" href="stylesheets/tabs.css" type="text/css" media="all">

        <script type="text/javascript">
            jQuery.noConflict();

            var indexAprop = 0;
            var countIdxNotes = 0;
            var popupLocate = null
            var totalVendaAnaliseCredito = 0;
            var listaTributos = new Array();
            

            function popLocate(indice, idlista, nomeJanela){
                popupLocate = launchPopupLocate("./localiza?acao=consultar&suffix="+indice+"&idlista="+idlista, nomeJanela + indice);
            }

            function build(tagname, properties){
                return Builder.node(tagname, properties);
            }

            function removerNotaFiscalAjax(idNota){
                tryRequestToServer(function(){
                    new Ajax.Request("./cadvenda.jsp?acao=removerNotaFiscalAjax&idNota="+idNota,{
                        method:'post', 
                        onSuccess: ""
                        ,
                        onError: ""
                    });
                });
            }

            /**Appropriation(id, idPlcusto, contaPlcusto, descPlcusto, valorAprop)*/
            function addAppropriation(id, idPlcusto, contaPlcusto, descPlcusto, valorAprop, idUndCusto, undCusto, idVeiculo, veiculo) {
                var valor = (valorAprop == 0 ? 0 : valorAprop);
                if (valor == 0){
                    for (i = 0; i <= indexAprop; ++i){
                        if ($('apropVl'+i)!=null){
                            valor += parseFloat($('apropVl'+i).value);
                        }
                    }
                    valor = formatoMoeda( parseFloat($('totalService').value) - parseFloat(valor) );
                }

                indexAprop++;
                var index = indexAprop;

                var _tr = Builder.node('TR', {id:'trAprop'+index, className:'CelulaZebra2'},
                [Builder.node('td', [ Builder.node('IMG',{border:'0',src:'./img/cancelar.png',
                            style:'cursor:pointer;',onclick:'Element.remove($(\'trAprop'+index+'\'))' })
                    ]),
                    Builder.node('td', [ build('INPUT', {name:'appropriation_id'+index,id:'appropriation_id'+index,value:id, type:'hidden'}),
                        build('INPUT',{value:contaPlcusto, id:'plcusto_conta'+index, name:'plcusto_conta', size:'8', readonly:'1', className:'inputReadOnly'})
                    ]),
                    Builder.node('td', [ build('INPUT',{value:descPlcusto, id:'plcusto_descricao'+index, name:'plcusto_descricao', size:'38', readonly:'1', className:'inputReadOnly'}),
                        build('INPUT',{type:'hidden', name:'idplanocusto'+index, id:'idplanocusto'+index, value:idPlcusto}),
                        build('INPUT',{type:'button', value:'...', onclick:"popLocate('"+index+"',<%=BeanLocaliza.PLANO_CUSTO_RECEITA%>,'Plano_Custo')", className:'botoes'})
                    ]),
                    Builder.node('td', [ build('INPUT',{value:veiculo, id:'plVeiculo'+index, name:'plVeiculo'+index, size:'9', readonly:'1', className:'inputReadOnly'}),
                        build('INPUT',{type:'hidden', name:'idPlVeiculo'+index, id:'idPlVeiculo'+index, value:idVeiculo}),
                        build('INPUT',{type:'button', value:'...', onclick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=<%=BeanLocaliza.VEICULO%>\', \'Veiculo'+index+'\');', className:'botoes'}),
                        build('IMG',{src:'img/borracha.gif', align:'absbottom', title:'Apagar Veiculo',className:'imagemLink',onClick:"$('idPlVeiculo"+index+"').value ='0';$('plVeiculo"+index+"').value ='';"})
                    ]),
                    Builder.node('td',{align:'right'}, [build('input', {type:'text', name:'apropVl'+index, id:'apropVl'+index, value:formatoMoeda(valor), size:'9', onchange:'seNaoFloatReset(this,\'0.00\');', className:'inputtexto'})
                    ]),
                    Builder.node('td', [ build('INPUT',{value:undCusto, id:'undCusto'+index, className:'inputReadOnly', name:'undCusto'+index, size:'7', readonly:'1'}),
                        build('INPUT',{type:'hidden', name:'idUndCusto'+index, id:'idUndCusto'+index, value:idUndCusto}),
                        build('INPUT',{type:'button', value:'...', onclick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=<%=BeanLocaliza.UNIDADE_CUSTO%>\', \'Unidade_Custo'+index+'\');', className:'botoes'})
                    ])
                ]);
                $('table_aprop').appendChild(_tr);
            }
            /**addParcel(id, indice, vence_em, valor, fatura, dtPago, vlPago conta, docum, isReadOnly)*/
            function addParcel(id, idx, vence_em, valor, idFatura, fatura, dtPago, vlPago, conta, docum, isReadOnly) {
                idx = (idx == 0? ($('table_parcels').lastChild == 'undefined' ? parseFloat($('table_parcels').lastChild.id.replace("trDup","")) : 0) +1
                : idx);
                var _tr = Builder.node('TR', {id:'trDup' + idx, className:'CelulaZebra2'},
                [Builder.node('td', [Builder.node('INPUT', {name:'parcel_id'+idx,id:'parcel_id'+idx,value:id, type:'hidden'}),
                        Builder.node('INPUT',{type:'text', name:'parcel_index'+idx, id:'parcel_index'+idx, className:'inputtexto', size:'2',maxlength:'3', value: idx, readOnly:'true'})]),
                    Builder.node('td', [Builder.node('INPUT',{className:'fieldDate', type:'text', name:'parcel_vence_em'+idx, id:'parcel_vence_em'+idx, size:'10',maxlength:'10', value:vence_em, onblur:'alertInvalidDate(this)'})]),
                    Builder.node('td', [Builder.node('INPUT',{type:'text', name:'parcel_valor'+idx, id:'parcel_valor'+idx, size:'8',maxlength:'12', className:'inputtexto', value:formatoMoeda(valor), onchange:'seNaoFloatReset(this,\'0.00\');'})]),
                    Builder.node('td', [Builder.node('LABEL', {className:'linkEditar', onClick:'javascript:verFatura('+idFatura+');'}, (fatura == '/'?'':fatura))]),
                    Builder.node('td', dtPago),
                    Builder.node('td', vlPago),
                    Builder.node('td', conta),
                    Builder.node('td', docum),
                    Builder.node('td', (dtPago != '' ? 'Quitada' : (fatura != '/' && fatura != '' ? 'Faturada' : 'Em aberto'))),
                    Builder.node('td', '')
                ]);

                $('table_parcels').appendChild(_tr);
                applyFormatter();

                if (isReadOnly){
                    $('parcelCount').disabled = isReadOnly;
                    $('btCriarDupls').disabled = isReadOnly;
                    $('parcel_index'+idx).className = 'inputReadOnly';
                    $('parcel_vence_em'+idx).readOnly = isReadOnly;
                    $('parcel_vence_em'+idx).className = 'inputReadOnly';
                    $('parcel_valor'+idx).readOnly = isReadOnly;
                    $('parcel_valor'+idx).className = 'inputReadOnly';
                    $('is_cancelado').disabled = isReadOnly;
                }
            }
  
            function refreshTotal(refreshDup, refreshAprop) {
                $("totalService").value = getTotalGeralServico();
                //$("totalISS").value = getTotalISS('< %=taxes%>',false);
                //$("totalISSRetido").value = getTotalISS('< %=taxes%>',true);
                getTotalISS();
                $("valorLiquido").value = formatoMoeda(parseFloat($("totalService").value) - parseFloat($("totalImpostosRetido").value));

                //Recriar parcelas
                if (refreshDup && !$('btCriarDupls').disabled)
                    doParcels();

                //Refaz apropriações
                if (refreshAprop)
                    atualizaPlanoDefault();

            }
            
            function appropCount(){
                return $('table_aprop').childNodes.length
            }
  
            function doParcels() {
                if ($('emissao_em').value != ''){
                    var qtDup = parseFloat($("parcelCount").value);

                    removeElementsByPrefix("trDup", 1);

                    for (xx = 1; xx <= qtDup; xx++){
                        var vl = parseFloat($("valorLiquido").value);
                        var vlDup = formatoMoeda(parseFloat(vl / qtDup));
                        //Se a divisao n for exata, entao some na ultima duplicata para balancear o valor.
                        if (xx == qtDup) {
                            var diffVlDup = formatoMoeda((vlDup * qtDup) - vl);
                            vlDup = formatoMoeda(vlDup - parseFloat(diffVlDup));
                        }
                        addParcel(0, xx, incData($("emissao_em").value, xx * parseFloat($("con_pgt").value)), vlDup, 0, '', '', '0,00', '', '', false);
                    }
                }
            }
  
            function checkForm(){

                if ($('idconsignatario').value == 0){
                    alert("Informe o Cliente Corretamente!");
                    return false;
                }

                if (parseFloat($('totalService').value) <= 0){
                    alert("O Total do Serviço Deverá ser Maior que Zero.");
                    return false;
                }

                if ($('table_parcels').childNodes.length < 1){
                    alert("Crie pelo Menos uma Parcela.");
                    return false;
                }

                var totalAprop = 0;
                for (i = 1; i <= indexAprop; ++i){
                    if ($('appropriation_id'+i) != null)
                        totalAprop = totalAprop + parseFloat($('apropVl'+i).value);
                }
                var totalService = formatoMoeda($('totalService').value);
                totalAprop = formatoMoeda(totalAprop);
                if (totalAprop != totalService){
                    alert("O Valor Total das Apropriações (Aba Informações Financeiras) deve ser Igual ao Valor Total de Serviços.");
                    return false;
                }

                var totalParcel = 0;
                for (i = 0;  i <= $('table_parcels').childNodes.length; ++i){
                    if ($('parcel_valor'+i) != null)
                        totalParcel = totalParcel + parseFloat($('parcel_valor'+i).value);
                }

                if (formatoMoeda(totalParcel) != formatoMoeda($('valorLiquido').value)) {
                    alert("O Valor Total das Parcelas(Aba Informações Financeiras) deve ser Igual ao Valor Líquido dos Serviços.");
                    return false;
                }

                if (!$("is_cancelado").checked && ($('con_analise_credito').value == 't' || $('con_analise_credito').value == 'true')){
                    var alterouCliente = ($('idconsignatario').value != "<%=(carrega_venda ? venda.getCliente().getIdcliente() : "0")%>");
                    var msg = getAnaliseCredito('<%=carrega_venda%>',$('con_is_bloqueado').value,$('con_valor_credito').value,$('totalService').value,(('<%=carrega_venda%>' === "true")?totalVendaAnaliseCredito:0),alterouCliente);
                    if (msg != ''){
                        alert(msg);
                        return false;
                    }

                }else if ($("is_cancelado").checked){
                    if ($("motivoCancelamento").value.trim() == ''){
                        alert('Informe o Motivo do Cancelamento.');
                        return false;
                    }                    
                    if (countCTRC > 0 && confirm("Deseja retirar o vínculo desse CT-e com a NFS-e?")) {
                        for (var qtdCtrcs = 0; qtdCtrcs <= countCTRC; qtdCtrcs++) {
                            if ($('ctrcId_'+qtdCtrcs) != null) {                            
                                    removerCTRCDist(qtdCtrcs);                            
                            }    
                        }
                    }
                }

                for (i = 0; i < indexNotes; ++i){
                    if ($('idfornecedor'+i) != null){
                        if ($('idfornecedor'+i).value == 0){
                            alert('Informe o Fornecedor da Despesa Corretamente.');
                            return false;
                        }
                     //   if ($('nf'+i).value == ''){
                     //       alert('Informe o Número da Nota da Despesa Corretamente.');
                     //       return false;
                     //   }
                        if ($('valorNota'+i).value == 0){
                            alert('Informe o Valor da Nota da Despesa Corretamente.');
                            return false;
                        }
                    }
                }

                //Validação apenas em caso de entrega local
                if ($('tipoNota').value == 'l'){
                    if ($('idremetente').value != '0' && $('iddestinatario').value == '0'){
                        alert('Informe o Destinatário Corretamente.');
                        return false;
                    }else if ($('idremetente').value == '0' && $('iddestinatario').value != '0'){
                        alert('Informe o Remetente Corretamente.');
                        return false;
                    }
                }
                return true;
            }
  
            function _onload() {
            <%if (carrega_venda) {%>
                    $('tipoNota').value = '<%=venda.getTipo()%>';
                    $('naturezaOperacao').value = '<%=venda.getNaturezaOperacao()%>';
                    mostrarEsconderCidadesNFSe($('naturezaOperacao').value);
                    alteraTipo();
                    
                    $("especieOriginal").value = $("especie").value;
                    $("serieOriginal").value = $("serie").value;
                    $("idfilialOriginal").value = $("idfilial").value;
                    $("agency_idOriginal").value = $("agency_id").value;
                    $("numeroOriginal").value = $("numero").value;
                    
            <%
                Iterator iCt = venda.getCtrcsDistribuicao().iterator();
                BeanConhecimento ct = null;
                while (iCt.hasNext()) {
                    ct = (BeanConhecimento) iCt.next();
            %>
                    addCTRC(<%=ct.getId()%>,
                    '<%=ct.getNumero()%>',
                    '<%=formatador.format(ct.getEmissaoEm())%>',
            <%=Apoio.parseDouble(String.valueOf(ct.getTotalReceita()))%>,
                    '<%=ct.getDestinatario().getRazaosocial()%>',
                    '<%=ct.getDestinatario().getBairro()%>',
                    '<%=ct.getDestinatario().getCidade().getDescricaoCidade()%>',
                    '<%=(ct.getNotas().isEmpty() ? "" : ((NotaFiscal) ct.getNotas().toArray()[0]).getNumero())%>');
            <%}

                BeanDespesa d = new BeanDespesa();
                BeanApropDespesa ap = new BeanApropDespesa();
                for (int x = 0; x < venda.getDespesa().length; x++) {
                    d = venda.getDespesa()[x];%>
                            addNotes(<%=d.getIdmovimento()%>,'<%=(d.isAVista() ? 'a' : 'p')%>','<%=d.getEspecie_().getId()%>', '<%=d.getSerie()%>', '<%=d.getNfiscal()%>', '<%=formatador.format(d.getDtEmissao())%>','<%=formatador.format(d.getDuplicatas()[0].getDtvenc())%>',<%=d.getFornecedor().getIdfornecedor()%>,'<%=d.getCompetencia()%>',<%=d.getHistorico().getIdhistorico()%>,'<%=d.getDescHistorico()%>',<%=d.getValor()%>,'<%=d.getDuplicatas()[0].getMovBanco().getDocum()%>', <%=d.getDuplicatas()[0].getMovBanco().getConta().getIdConta()%>);
            <%for (int y = 0; y < venda.getDespesa()[x].getApropriacoes().length; y++) {
                    ap = venda.getDespesa()[x].getApropriacoes()[y];%>
                            addApropriacao(indexNotes - 1, <%=ap.getPlanocusto().getIdconta()%>, '<%=ap.getPlanocusto().getConta()%>', '<%=ap.getPlanocusto().getDescricao()%>', <%=ap.getVeiculo().getIdveiculo()%>, '<%=ap.getVeiculo().getPlaca()%>', <%=ap.getValor()%>, false, <%=ap.getUndCusto().getId()%>, '<%=ap.getUndCusto().getSigla()%>');
            <%}
                    }
                }%>

                        escondeMostraCancelamento(<%=venda.isCancelado()%>);

            <%//adicionando servicos da venda
                for (int h = 0; h < venda.getVenda_servicos().size(); ++h) {
                    BeanVendaServico vs = (BeanVendaServico) venda.getVenda_servicos().get(h);
            %>  
                    listaTributos = new Array();
                    listaTributos[0] = new ImpostoServico(<%=vs.getValor() * vs.getQuantidade()%>,<%=vs.getIss()%>,<%=vs.getTributacao().getId()%>,<%=vs.getQtdDias()%>, "iss");
                    listaTributos[1] = new ImpostoServico(<%=vs.getValor() * vs.getQuantidade()%>,<%=vs.getInss()%>,<%=vs.getInssTributacao().getId()%>,<%=vs.getQtdDias()%>, "inss");
                    listaTributos[2] = new ImpostoServico(<%=vs.getValor() * vs.getQuantidade()%>,<%=vs.getPis()%>,<%=vs.getPisTributacao().getId()%>,<%=vs.getQtdDias()%>, "pis");
                    listaTributos[3] = new ImpostoServico(<%=vs.getValor() * vs.getQuantidade()%>,<%=vs.getCofins()%>,<%=vs.getCofinsTributacao().getId()%>,<%=vs.getQtdDias()%>, "cofins");
                    listaTributos[4] = new ImpostoServico(<%=vs.getValor() * vs.getQuantidade()%>,<%=vs.getIr()%>,<%=vs.getIrTributacao().getId()%>,<%=vs.getQtdDias()%>, "ir");
                    listaTributos[5] = new ImpostoServico(<%=vs.getValor() * vs.getQuantidade()%>,<%=vs.getCssl()%>,<%=vs.getCsslTributacao().getId()%>,<%=vs.getQtdDias()%>, "cssl");

                    addServ(listaTributos,
                    'node_servs',
            <%=vs.getId()%>,
                    '<%=vs.getTipo_servico().getId()%>',
                    '<%=vs.getTipo_servico().getDescricao()%>',
                    '<%=vs.getQuantidade()%>',
            <%=vs.getValor()%>,                    
                    '<%=taxes%>',
                    '<%=taxesGenerico%>',
                    '<%=vs.getTipo_servico().getPlanoCustoPadrao().getIdconta()%>',
                    '<%=vs.getTipo_servico().getPlanoCustoPadrao().getConta()%>',
                    '<%=vs.getTipo_servico().getPlanoCustoPadrao().getDescricao()%>',
            <%=vs.getColeta().getId()%>,
                    '<%=vs.getColeta().getNumero()%>',
                    '<%=vs.getTipo_servico().isUsaDias()%>',
                    '<%=vs.getQtdDias()%>',
                    '<%=taxes%>',
                    "",
            <%=vs.isEmbutirISS()%>, 
                    false, 0, '<%=vs.getDescricaoComplmentar()%>',
                    <%=vs.getTipo_servico().getQtdCasasDecimaisQuantidade()%>, <%=vs.getTipo_servico().getQtdCasasDecimaisValor()%>,<%=vs.getTipo_servico().getExigibilidadeISS()%>,<%=cfg.getTipoCalculaIss()%>
                );
                    refreshTotal(false, false);
            <%}
                //adicionando duplicatas
                for (int q = 0; q < venda.getDuplicatas().size(); ++q) {
                    BeanDuplicata du = (BeanDuplicata) venda.getDuplicatas().get(q);
            %>addParcel("<%=du.getId()%>",
            <%=du.getDuplicata()%>,
                    "<%=Apoio.fmt(du.getDtvenc())%>",
                    "<%=du.getVlduplicata()%>",
            <%=du.getFatura().getId()%>,
                    "<%=du.getFatura().getNumero()%>",
                    "<%=(du.getDtpago() == null ? "" : formatador.format(du.getDtpago()))%>",
                    "<%=(new DecimalFormat("#,##0.00").format(du.getVlpago()))%>",
                    "<%=du.getMovBanco().getConta().getNumero()%>",
                    "<%=du.getMovBanco().getDocum()%>",
            <%=(du.isBaixado() || !du.getFatura().getNumero().equals("/"))%>);<%
                }

                //adicionanndo apropriacoes
                for (int b = 0; b < venda.getApropriacoes().size(); ++b) {
                    BeanApropriacao ap = (BeanApropriacao) venda.getApropriacoes().get(b);
            %>addAppropriation("<%=ap.getIdmovimento()%>",
            <%=ap.getPlanocusto().getIdconta()%>,
                    "<%=ap.getPlanocusto().getConta()%>",
                    "<%=ap.getPlanocusto().getDescricao()%>",
            <%=ap.getValor()%>,
                    "<%=ap.getUnidadeCusto().getId()%>",
                    "<%=ap.getUnidadeCusto().getSigla()%>",
                    '<%=ap.getVeiculo().getIdveiculo()%>',
                    '<%=ap.getVeiculo().getPlaca()%>');<%
                        }
            %>
                    totalVendaAnaliseCredito = getTotalGeralServico();

            <% 
                if (!acao.equals("iniciar") && (venda.getStatusNFSe().equals("C") || venda.getStatusNFSe().equals("E"))) {%>
                    bloqueiaNFSe();
            <%}%>
                    //adicionando as notas
            <%
                for (NotaFiscal n : venda.getNotas()) {%>

                        var prefixo = addNote('0',
                        'tableNotes0',
                        '<%=n.getIdnotafiscal()%>',//
                        '<%=n.getNumero()%>',//
                        '<%=n.getSerie()%>',//
                        '<%=(n.getEmissao() != null ? new SimpleDateFormat("dd/MM/yyyy").format(n.getEmissao()) : "")%>',//
                        '<%=n.getValor()%>',//
                        '<%=n.getVl_base_icms()%>',//
                        '<%=n.getVl_icms()%>',//
                        '<%=n.getVl_icms_st()%>',//
                        '<%=n.getVl_icms_frete()%>',//
                        '<%=n.getPeso()%>',//
                        '<%=n.getVolume()%>',//
                        '<%=n.getEmbalagem()%>',//
                        '<%=n.getConteudo()%>',//
            <%=n.getIdconhecimento()%>,//
                    '<%=n.getPedido()%>',//
                    false,//
                    '<%=n.getLargura()%>',//
                    '<%=n.getAltura()%>',//
                    '<%=n.getComprimento()%>',//
                    '<%=n.getMetroCubico()%>',//
                    '<%=n.getMarcaVeiculo().getIdmarca()%>',//
                    '<%=n.getMarcaVeiculo().getDescricao()%>',//
                    '<%=n.getModeloVeiculo()%>',//
                    '<%=n.getAnoVeiculo()%>',//
                    '<%=n.getCorVeiculo()%>',//
                    '<%=n.getChassiVeiculo()%>',//
                    '<%=n.getItemNotaFiscal().length%>',//
                    'true',//
                    '<%=n.getCfop().getIdcfop()%>',//
                    '<%=n.getCfop().getCfop()%>',//
                    '<%=n.getChaveNFe()%>',//
                    '<%=n.isAgendado()%>', //novos campos//
                    '<%=n.getDataAgenda() != null ? new SimpleDateFormat("dd/MM/yyyy").format(n.getDataAgenda()) : ""%>',//
                    '<%=n.getHoraAgenda()%>',//
                    '<%=n.getObservacaoAgenda()%>','<%=cfg.isBaixaEntregaNota()%>',//
                    '<%=n.getPrevisaoEm() != null ? new SimpleDateFormat("dd/MM/yyyy").format(n.getPrevisaoEm()) : ""%>',//
                    '<%=n.getPrevisaoAs()%>',//
                    '<%=n.getDestinatario().getIdcliente()%>',//
                    '<%=n.getDestinatario().getRazaosocial()%>',//
            <%=n.isImportadaEdi()%>,//
                    '<%=n.getCubagens().length%>',//
                    '',//
                    '<%=n.getTipoDocumento()%>',//
                    '',//
                    ''//143
                );

                    countIdxNotes++;

            <% for (int c = 0; c < n.getItemNotaFiscal().length; ++c) {
                    ItemNotaFiscal item = n.getItemNotaFiscal()[c];
            %>
                    addUpdateNotaFiscal2('trNote'+prefixo,
                    '<%=n.getIdnotafiscal()%>',
                    '<%=item.getId()%>',
                    prefixo,
                    '<%=item.getDescricao()%>',
                    '<%=item.getQuantidade()%>',
                    '<%=item.getValor()%>',
                    (<%=c%>+1),
                    'editar',
                    '<%=item.getBasePaletizacao()%>',
                    '<%=item.getAlturaPaletizacao()%>');
            <%
                }//for
                for (int c = 0; c < n.getCubagens().length; ++c) {
                    Cubagem cub = n.getCubagens()[c];

            %>
                    addUpdateNotaFiscal3('trNote'+prefixo,
                    '<%=n.getIdnotafiscal()%>',
                    '<%=cub.getId()%>',
                    prefixo,
                    '<%=cub.getMetroCubico()%>',
                    '<%=cub.getAltura()%>',
                    '<%=cub.getLargura()%>',
                    '<%=cub.getComprimento()%>',
                    '<%=cub.getVolume()%>',
                    '<%=cub.getEtiqueta()%>',
            <%=c%>);
            <%
                    }//for

                    //notas += (notas.equals("") ? "" : "!!-") + n.getIdnotafiscal() + ":.:" + n.getNumero();

                }%>
     //Aba Auditoria               
    if ($("dataDeAuditoria") != null) {
                $("dataDeAuditoria").value = '<%=Apoio.getDataAtual()%>';
                $("dataAteAuditoria").value = '<%=Apoio.getDataAtual()%>';
            }
   
    if ('<c:out value="<%=nivelUser%>"/>' == 4) {
            $("tableAuditoria").style.display = "";
        } else {
            $("tableAuditoria").style.display = "none";
        }        
                        totaisNotas();

                    }//_onload()
                
                    function excluir(id){
                        function ev(resp, st) {
                            if (st == 200) {
                                if (resp != "Nota(s) Excluida(s)") {
                                    alert(resp);
                                } else {
                                    voltar();
                                }
                            } else {
                                alert("Status " + st + "\n\nNão Conseguiu Realizar o Acesso ao Servidor!");
                            }
                        }

                        if (confirm("Deseja Mesmo Excluir Esta Venda?")) {
                            requisitaAjax("${homePath}/NotaServicoControlador?acao=excluir&ids=" + id, ev);
                        }
                    }

                    function voltar(){
                        document.location.replace('ConsultaControlador?codTela=75');
                    }
                    
                     //Função para apenas visualizar a nota fiscal.
                    function visualizarNota(idNotaFiscal){
                        if(idNotaFiscal != 0){
                            window.open("NotaFiscalControlador?acao=carregar&idNota="+idNotaFiscal+"&visualizar=true",
                                    "visualizarNota" , 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
                        }else{
                            alert("Nota fiscal ainda não foi salva!");
                        }
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

                    function aoClicarNoLocaliza(idjanela){
                        if (idjanela == "Observacao"){
                            while ($('obs_desc').value.indexOf("<BR>") > -1)
                                $('obs_desc').value = $('obs_desc').value.replace("<BR>","<br>");

                            var array_obs =  $('obs_desc').value.split("<br>");

                            $('observacao1').value = array_obs[0];
                            $('observacao2').value = (array_obs[1] != undefined? array_obs[1] : "");
                            $('observacao3').value = (array_obs[2] != undefined? array_obs[2] : "");
                            $('observacao4').value = (array_obs[3] != undefined? array_obs[3] : "");
                            $('observacao5').value = (array_obs[4] != undefined? array_obs[4] : "");
                        }
                        if (idjanela == "Nota_De_Servico"){
                            while ($('obs_desc').value.indexOf("<BR>") > -1)
                                $('obs_desc').value = $('obs_desc').value.replace("<BR>","<br>");

                            var array_obs =  $('obs_desc').value.split("<br>");

                            $('observacao1').value = array_obs[0];
                            $('observacao2').value = (array_obs[1] != undefined? array_obs[1] : "");
                            $('observacao3').value = (array_obs[2] != undefined? array_obs[2] : "");
                            $('observacao4').value = (array_obs[3] != undefined? array_obs[3] : "");
                            $('observacao5').value = (array_obs[4] != undefined? array_obs[4] : "");

                            carregaSubsJson();
                        }

                        if (idjanela.substring(0,13) == "Unidade_Custo"){
                            $('idUndCusto'+idjanela.substring(13,15)).value = $('id_und').value;
                            $('undCusto'+idjanela.substring(13,15)).value = $('sigla_und').value;
                        }

                        if (idjanela.substring(0,7) == "Veiculo"){
                            if (idjanela.split('_')[1] != null){
                                $('idVeiculo_'+idjanela.split('_')[1]+'_'+idjanela.split('_')[2]).value = $('idveiculo').value;
                                $('veiculo_'+idjanela.split('_')[1]+'_'+idjanela.split('_')[2]).value = $('vei_placa').value;
                            }else{
                                $('idPlVeiculo'+idjanela.substring(7,9)).value = $('idveiculo').value;
                                $('plVeiculo'+idjanela.substring(7,9)).value = $('vei_placa').value;
                            }
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
                            //                        $('type_service_valor').value,
                            //                       $('type_service_iss_percent').value,
                            //                      '0',
                            //                     $('tax_id').value,
                            '<%=taxes%>',
                            '<%=taxesGenerico%>',
                            $('idplanocusto').value,
                            $('plcusto_conta').value,
                            $('plcusto_descricao').value,
                            "0",
                            "",
                            $('is_logistico').value,//foi dito que o campo antigo(is_usa_dias) é o mesmo que o novo(is)logistico)
                            '1',
                            $("tax_id").value+":.:"+$("codigo_taxa").value+"!!-",
                            "", $("embutir_iss").value, true, 0, "",
                            $("quantidade_casas_decimais_quantidade").value,
                            $("quantidade_casas_decimais_valor").value,
                            $("exigibilidade_iss").value,
                            <%=cfg.getTipoCalculaIss()%>
                        );
                            refreshTotal(true, true);
                        }

                        if (idjanela.indexOf("Apropriacao") > -1){

                            addAppropriation('0',$('idplanocusto').value,$('plcusto_conta').value,$('plcusto_descricao').value,'0','0','','0','');
                        }

                        if (idjanela.indexOf("Tipo_Servico") > -1){

                            refreshTotalServices(true, true);

                            var totaliti = document.getElementById("totalService").innerHTML;

                            if (parseFloat(popupLocate.$("idconta"+popupLocate.registro_selecionado).innerHTML) > 0){
                                var plcusto_id = popupLocate.registro_selecionado;

                                addAppropriation(0, popupLocate.$("idconta"+plcusto_id).innerHTML,
                                popupLocate.$("plcusto_conta"+plcusto_id).innerHTML,
                                popupLocate.$("plcusto_descricao"+plcusto_id).innerHTML,
                                totaliti,'0','','0','');
                            }
                        }

                        if(idjanela.split('_')[0] == 'Fornecedor'){
                            $('fornecedor'+idjanela.split('_')[1]).value = $('fornecedor').value;
                            $('idfornecedor'+idjanela.split('_')[1]).value = $('idfornecedor').value;
                            var jaExiste = checkPlanoCustoRepetido(idjanela.split('_')[1]);
                            if ($('idplcustopadrao').value != '0' && !jaExiste){
                                addApropriacao(idjanela.split('_')[1], $('idplcustopadrao').value, $('contaplcusto').value, $('descricaoplcusto').value, 0, '', 0, true, $('id_und_forn').value, $('sigla_und_forn').value);
                            }
                        }

                        if(idjanela.split('_')[0] == 'Plano'){
                            if (idjanela.split('_')[2] == null){
                                addApropriacao(idjanela.split('_')[1], $('idplanocusto_despesa').value, $('plcusto_conta_despesa').value, $('plcusto_descricao_despesa').value, 0, '', 0, true, 0, '');
                            }else{
                                $('idApropriacao_'+idjanela.split('_')[1]+'_'+idjanela.split('_')[2]).value = $('idplanocusto_despesa').value;
                                $('conta_'+idjanela.split('_')[1]+'_'+idjanela.split('_')[2]).value = $('plcusto_conta_despesa').value;
                                $('apropriacao_'+idjanela.split('_')[1]+'_'+idjanela.split('_')[2]).value = $('plcusto_descricao_despesa').value;
                            }
                        }

                        if(idjanela.split('_')[0] == 'Und'){
                            $('idUnd_'+idjanela.split('_')[1]+'_'+idjanela.split('_')[2]).value = $('id_und').value;
                            $('und_'+idjanela.split('_')[1]+'_'+idjanela.split('_')[2]).value = $('sigla_und').value;
                        }
                        
                        // Pega o cfop do localizar e adiciona no DOM de notas_fiscais
                        if (idjanela.split("__")[0] == "Cfop_Nota_fiscal_nfe"){
                            var idxCfopNfe = idjanela.split("__")[1];
                            $('nf_cfop'+idxCfopNfe).value = $('cfop').value;
                            $('nf_cfopId'+idxCfopNfe).value = $('idcfop').value;
                        }
                        // Pega o conteudo do localizar e adciona no DOM de notas_fiscais
                        if(idjanela.split("__")[0] == "Produto_ctrcs_nf"){                           
                            var idxProdNF = idjanela.split("__")[1];                           
                            $('nf_conteudo'+idxProdNF).value = $('desc_prod').value;
                        }
                        
                        if (idjanela == "Consignatario") {
                            if ($("naturezaOperacao").value == "2") {
                                $("idcidade").value = $("con_idcidade").value;
                                $("cidade").value = $("con_cidade").value;
                                $("uf").value = $("con_uf").value;    
                            }
//                            usarClienteRemetente();
                        }
                        if (idjanela == "Filial") {                            
                            $("idcidade").value = $("fi_idcidade").value;
                            $("cidade").value = $("fi_cidade").value;
                            $("uf").value = $("fi_uf").value;
                            getNextSale();
                        }
                        
                    }

                    function excluirApp(indexNota, indexAprop){
                        if (confirm("Deseja Mesmo Excluir esta Apropriação?")){
                            Element.remove('trApropDesp'+indexNota+'_'+indexAprop);
                            totalNota(indexNota);
                        }
                    }

                    function excluirNota(indexNota){
                        if (confirm("Deseja Mesmo Excluir esta Despesa?")){
                            Element.remove('trApropDesp'+indexNota);
                            Element.remove('trdesp'+indexNota);
                        }
                    }

                    function getNextSale(){
                        var especie = $("especie").value;
                        var serie = $("serie").value;
                        var idfilial = $("idfilial").value;
                        var agency_id = $("agency_id").value;
                        var numero = $("numero").value;
                        
                        var especieOriginal = $("especieOriginal").value;
                        var serieOriginal = $("serieOriginal").value;
                        var idfilialOriginal = $("idfilialOriginal").value;
                        var agency_idOriginal = $("agency_idOriginal").value;
                        var numeroOriginal = $("numeroOriginal").value;
                        
                        if (especie == especieOriginal &&
                            serie == serieOriginal &&
                            idfilial == idfilialOriginal &&
                            agency_id == agency_idOriginal) {
                            $("numero").value = numeroOriginal;
                            return false;
                        }
                        
                        function e(resp, st){
                            if (st == 200)
                                if (resp.split("<=>")[1] != "")
                                    alert(resp.split("<=>")[1]);
                            else
                                $("numero").value = resp.split("<=>")[0];
                            else
                                alert("Status "+st+"\n\nNão Conseguiu Acessar o Servidor!");

                        }

                        requisitaAjax("./cadvenda.jsp?acao=get_next_sale&"+concatFieldValue("especie,serie,idfilial,agency_id"), e);
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
                
                    function salvar(){
                        
//                        $("btSalvar").disabled = true;
                        
                        var qtd = getNextIndexFromServ('node_servs');
                        for(var i=1;i<qtd;i++){
                            for(var j=1;j<qtd;j++){
                                if($("perc_iss" + i).value != $("perc_iss" + j).value){
                                    alert("O Percentual de ISS dos Serviços Não pode ser Diferente!");
//                                    $("btSalvar").disabled = false;
                                    return false;
                                }
                            }
                        }
                        if(($("idremetente").value == 0 || $("iddestinatario").value == 0) && $("idmotorista").value != 0 ){
                            alert("Atenção! Para salvar um motorista na NFS, devem ser informados: Remetente e Destinatário!");
                            return false;
                        }
                        
                        tryRequestToServer(function(){
                            if (checkForm()){
                                habilitaTrib();
                                $("objCountIdxNotes").value = countIdxNotes;
                                $('tipoNota').disabled = false;
                                $("qtdApp").value = indexApp;
                                $("qtdNotas").value = indexNotes;
                                window.open('about:blank', 'pop', 'width=210, height=100');
                                $('form1').action = './cadvenda.jsp?acao=<%=carrega_venda ? "atualizar&id=" + venda.getId() : "incluir"%>&qtdParcelas='+$('table_parcels').childNodes.length+
//                                    '&qtdAprop='+indexAprop+'&qtdDistribuicao='+countCTRC+'&qtdServ='+getNextIndexFromServ('node_servs');
                                    '&qtdAprop='+indexAprop+'&qtdDistribuicao='+countCTRC+'&qtdServ='+$("maxServico").value;
                                $('form1').submit();
//                                $("btSalvar").disabled = true;
                            }else {
//                                $("btSalvar").disabled = false;
                            }
                        });
                    }

                    function atualizaPlanoDefault(){
                        var achou = false;
                        for (x = 0; x <= indexAprop; ++x){ //percorra todas as apropriações para zerar o valor
                            if ($('idplanocusto'+x) != null){
                                $('apropVl'+x).value = formatoMoeda(0);
                            }
                        }

                        for (i = 0; i <= getNextIndexFromServ('node_servs'); ++i){ //Percorra todos os serviços

                            if ($('id_servico'+i) != null){ //Se a linha existir
                                if ($('id_plano'+i).value != '0'){ //Se o plano de custo default existir
                                    for (x = 0; x <= indexAprop; ++x){ //percorra todas as apropriações para saber se o plano já foi adicionado
                                        if ($('idplanocusto'+x) != null){
                                            if ($('id_plano'+i).value == $('idplanocusto'+x).value){
                                                $('apropVl'+x).value = formatoMoeda(parseFloat($('apropVl'+x).value) +  parseFloat($('vl_total'+i).value));
                                                achou = true;
                                                break;
                                            }
                                        }
                                    }
                                    if (!achou){
                                        addAppropriation('0', $('id_plano'+i).value, $('conta_plano'+i).value, $('descricao_plano'+i).value, formatoMoeda($('vl_total'+i).value), '0', '', '0', '');
                                    }
                                    achou = false;
                                }
                            }
                        }
                    }

                    function verFatura(id){
                        if (<%=nivelUserFatura > 1%>){
                            window.open('./jspfatura.jsp?acao=editar&id='+id+'&ex=false', 'Fatura' , 'top=0,resizable=yes');
                        }else{
                            alert('Você Não Tem Acesso a Essa Rotina. Procure o Administrador.');
                        }
                    }

                    function selecionaOS(){
                        if ($('idconsignatario').value == 0){
                            alert('Informe o Cliente Corretamente!');
                        }else{
                            window.open('./pops/seleciona_os_venda.jsp?acao=iniciar&idconsignatario='+$('idconsignatario').value+
                                '&con_rzs='+$('con_rzs').value+'&marcados='+selecionaServicos(), 'OS' , 'top=0,width=800,resizable=yes,status=1,scrollbars=1');
                        }
                    }

                    function selecionaCTRC(){
                        if ($('idconsignatario').value == 0){
                            alert('Informe o Cliente Corretamente!');
                        }else{
                            window.open('./pops/seleciona_ctrc_distribuicao.jsp?acao=iniciar&telaChamada=ns&idconsignatario='+$('idconsignatario').value+
                                '&con_rzs='+$('con_rzs').value+'&marcados='+getCTRCMarcados(), 'CTRC' , 'top=0,width=800,resizable=yes,status=1,scrollbars=1');
                        }
                    }

                    function selecionaServicos(){
                        var qtd = qtdServicos;
                        var marcados = "0";
                        for (i = 0; i <= qtd; ++i){ //Percorra todos os serviços
                            if ($('id'+i) != null){
                                marcados += ',' + $('id'+i).value;
                            }
                        }
                        return marcados;
                    }

                    function getCTRCMarcados(){
                        var qtd = countCTRC;
                        var marcados = "0";
                        for (i = 0; i <= qtd; ++i){ //Percorra todos os serviços
                            if ($('ctrcId_'+i) != null){
                                marcados += ',' + $('ctrcId_'+i).value;
                            }
                        }
                        return marcados;
                    }

                    function getTotaisCTRC(){
                        var qtd = countCTRC;
                        var marcados = "0";
                        var totalValor = 0;
                        var qtdCTRC = 0;
                        for (i = 0; i <= qtd; ++i){ //Percorra todos os serviços
                            if ($('ctrcId_'+i) != null){
                                totalValor += parseFloat($('ctrcValor_'+i).value);
                                qtdCTRC++;
                            }
                        }
                        $('lbTotalDistribuicao').innerHTML = formatoMoeda(totalValor);
                        $('lbQtdDistribuicao').innerHTML = qtdCTRC + ' CTRC(s)';
                    }

                    function carregaSubsJson(){
                        var venda = {};
                        function e(transport){
                            var textoresposta = transport.responseText;
                            espereEnviar("",false);


                            venda = jQuery.parseJSON(textoresposta);
                            var vendaServico;


                            var length;
                            if(venda.venda.venda__servicos[0].vendaserv.length == undefined){
                                length = 1;
                            }else{
                                length = venda.venda.venda__servicos[0].vendaserv.length;
                            }

                            removeAllServ();

                            for(var i=0; i< length; i++){
                                if(length > 1){
                                    vendaServico = venda.venda.venda__servicos[0].vendaserv[i];
                                }else{
                                    vendaServico = venda.venda.venda__servicos[0].vendaserv;
                                }

                                listaTributos = new Array();
                                listaTributos[0] = new ImpostoServico(vendaServico.valor * vendaServico.quantidade, vendaServico.iss, vendaServico.tributacao.id, vendaServico.qtdDias, "iss");
                                listaTributos[1] = new ImpostoServico(vendaServico.valor * vendaServico.quantidade, vendaServico.iss, vendaServico.tributacao.id, vendaServico.qtdDias, "inss");
                                listaTributos[2] = new ImpostoServico(vendaServico.valor * vendaServico.quantidade, vendaServico.iss, vendaServico.tributacao.id, vendaServico.qtdDias, "pis");
                                listaTributos[3] = new ImpostoServico(vendaServico.valor * vendaServico.quantidade, vendaServico.iss, vendaServico.tributacao.id, vendaServico.qtdDias, "cofins");
                                listaTributos[4] = new ImpostoServico(vendaServico.valor * vendaServico.quantidade, vendaServico.iss, vendaServico.tributacao.id, vendaServico.qtdDias, "ir");
                                listaTributos[5] = new ImpostoServico(vendaServico.valor * vendaServico.quantidade, vendaServico.iss, vendaServico.tributacao.id, vendaServico.qtdDias, "cssl");
                                addServ(
                                listaTributos,
                                'node_servs',
                                vendaServico.id,
                                vendaServico.tipo__servico.id,
                                vendaServico.tipo__servico.descricao,
                                vendaServico.quantidade,
                                vendaServico.valor,
                                //vendaServico.valorTotal,
                                '<%=taxes%>',
                                '<%=taxesGenerico%>',
                                vendaServico.tipo__servico.planoCustoPadrao.idconta,
                                vendaServico.tipo__servico.planoCustoPadrao.conta,
                                vendaServico.tipo__servico.planoCustoPadrao.descricao,
                                vendaServico.coleta.id,
                                vendaServico.coleta.numero,
                                vendaServico.tipo__servico.usaDias,
                                vendaServico.qtdDias,
                                '<%=taxes%>',
                                "",
                                vendaServico.embutirISS, 
                                false, 
                                0, 
                                "",
                                '<%=cfg.getTipoCalculaIss()%>');
                            }

                            refreshTotal(true, true);
                            atualizaPlanoDefault()
                        }


                        espereEnviar("",true);
                        tryRequestToServer(function(){
                            new Ajax.Request("./cadvenda.jsp?acao=carregar_subs_json&idnotasubs=" + $("idnotasubs").value,
                            {method:'post',
                                onSuccess: e});
                        });
                    }

                    function bloqueiaNFSe(){
                        bloqueiaInput($("especie"));
                        bloqueiaInput($("serie"));
                        bloqueiaInput($("numero"));
                        bloqueiaInput($("emissao_em"));
                        desabilitaInput($("botAddOs"));
                        desabilitaInput($("botFilial"));
                        desabilitaInput($("botCfop"));
                        //desapareceImg($("botAdd"));

                        bloqueiaServicos();
                    }

                    function escondeMostraCancelamento(check){
                        if(check){
                            $("motivoCancelamento").style.display = "";
                            $("lbMotivoCancelamento").innerHTML = "Motivo:";
                        }else{
                            $("motivoCancelamento").style.display = "none";
                            $("lbMotivoCancelamento").innerHTML = "";
                        }
                    }

                    function alteraTipo(){
                        var tipo = $('tipoNota').value;
                        $('trTituloDistribuicao').style.display = 'none';
                        $('trAddTituloDistribuicao').style.display = 'none';
                        $('trTotalTituloDistribuicao').style.display = 'none';
                        $('trBotaoOS').style.display = 'none';
                        $('trNF').style.display = 'none';
                        if (<%=!carrega_venda%>) {
                            limpaRemetenteCodigo();
                        }
                        if (tipo == 'n'){
                            $('trBotaoOS').style.display = '';
                        }else if (tipo == 'l'){
                            $('trTituloDistribuicao').style.display = '';
                            $('trAddTituloDistribuicao').style.display = '';
                            $('trTotalTituloDistribuicao').style.display = '';
                            $('trNF').style.display = '';
//                            usarClienteRemetente();
                        }else if (tipo == 'p') {
                            $('trNF').style.display = '';
                        }
                    }

                    function removerCTRCDist(idx){
                        if (confirm("Deseja mesmo apagar o CTRC da lista?")){
                            Element.remove('trDistribuicao_'+idx);
                            getTotaisCTRC();
                        }
                    }

                    var countCTRC = 0;
                    function addCTRC(idCTRC, numero_ctrc, emissao_ctrc, valor_ctrc, destinatario, bairro_destino, cidade_destino, numero_nota){
                        var tr_ = Builder.node("TR",{className:"CelulaZebra"+(countCTRC%2==0?2:1), id:"trDistribuicao_"+countCTRC, name:"trDistribuicao_"+countCTRC});
                        var td1_ = Builder.node("TD");
                        var img1_ =  Builder.node("IMG", {src:"img/lixo.png", title:"Apagar o CTRC de distribuição "+ numero_ctrc +" da lista.", className:"imagemLink", onClick:"removerCTRCDist("+countCTRC+");"});
                        var inp1_ = Builder.node("INPUT", {type:"hidden", name:"ctrcId_"+countCTRC, id:"ctrcId_"+countCTRC, value:idCTRC});
                        var inp2_ = Builder.node("INPUT", {type:"hidden", name:"ctrcValor_"+countCTRC, id:"ctrcValor_"+countCTRC, value:valor_ctrc});
                        td1_.appendChild(img1_);
                        td1_.appendChild(inp1_);
                        td1_.appendChild(inp2_);

                        var td2_ = Builder.node("TD",numero_ctrc);
                        var td3_ = Builder.node("TD",emissao_ctrc);
                        var td4_ = Builder.node("TD",{align:"right"},valor_ctrc);
                        var td5_ = Builder.node("TD",destinatario);
                        var td6_ = Builder.node("TD",bairro_destino);
                        var td7_ = Builder.node("TD",cidade_destino);
                        var td8_ = Builder.node("TD",numero_nota);

                        tr_.appendChild(td1_);
                        tr_.appendChild(td2_);
                        tr_.appendChild(td8_);
                        tr_.appendChild(td3_);
                        tr_.appendChild(td4_);
                        tr_.appendChild(td5_);
                        tr_.appendChild(td6_);
                        tr_.appendChild(td7_);

                        $('tbDistribuicao').appendChild(tr_);

                        countCTRC++;

                        getTotaisCTRC();
                        
                        
                        
    
                    }

                    var listaConta = new Array();
                    var countConta = 0;

                    function Lista(id,descricao){
                        this.id = id ;
                        this.descricao = descricao;
                    }

            <%cta.setConexao(Apoio.getUsuario(request).getConexao());
                        cta.mostraContas(0, false, limitarUsuarioVisualizarConta, idUsuario);
                        ResultSet rsconta = cta.getResultado();
                        while (rsconta.next()) {%>
                        listaConta[countConta]= new Lista('<%=rsconta.getString("idconta")%>', '<%=rsconta.getString("banco")%>  <%=rsconta.getString("numero")%> - <%=rsconta.getString("digito_conta")%>') ;
                        countConta++;
                        <%}%>

                function alteraTipoDespesa(index){
                    if($("tipoDesp"+index).value=="a"){
                        visivel($("trdesp2_"+index));
                    }else{
                        invisivel($("trdesp2_"+index));
                    }
                }

                function isUsarCheque(i){
                    if($("isCheque_"+i).checked){
                        verDocDesp(i);
                    }else{
                        visivel($('docDespCarta_'+i));
                        invisivel($('docDespCarta_cb_'+i));
                    }
                }

                function verDocDesp(vIndexPagto){
                    //objeto funcao usado na requisicao Ajax(uma espécie de evento)
                    $('docDespCarta_cb_'+vIndexPagto).style.display = "none";
                    $('docDespCarta_'+vIndexPagto).style.display = "";

                    if ($("tipoDesp"+vIndexPagto).value == "a" && $("isCheque_"+vIndexPagto).checked){

            <%if (cfg.isControlarTalonario()) {%>

                        function e(transport){
                            var textoresposta = transport.responseText;


                            //se deu algum erro na requisicao...
                            if (textoresposta == "-1"){
                                alert('Houve Algum Problema ao Requistar o Novo Cheque, Favor Informar Manualmente.');
                                return false;
                            }else{
            <%if (cfg.isControlarTalonario()) {%>
                                //var lista = JSON.parse(textoresposta);
                                var lista = jQuery.parseJSON(textoresposta);
                                var listCheque = lista.list[0].documento;
                                var documento;
                                var isPrimeiro = true;
                                var slct = $("docDespCarta_cb_"+vIndexPagto);


                                var valor = "";
                                removeOptionSelected("docDespCarta_cb_"+vIndexPagto);

                                slct.appendChild(Builder.node('OPTION', {value:""}, "-----"));
                                //                slct.appendChild(Builder.node('OPTION', {value:valor}, valor));
                                var length = (listCheque.length == undefined ? 1 : listCheque.length);

                                for(var i = 0; i < length; i++){
                                    if(length > 1){
                                        documento = listCheque[i];
                                    }else{
                                        documento = listCheque;
                                    }
                                    valor += (isPrimeiro ? documento :"");
                                    if(documento != null && documento != undefined){
                                        slct.appendChild(Builder.node('OPTION', {value: documento}, documento));
                                    }
                                    isPrimeiro = false;
                                }

                                slct.value = valor;
            <%}%>
                            }
                        }//funcao e()


                        $('docDespCarta_cb_'+vIndexPagto).style.display = "";
                        $('docDespCarta_'+vIndexPagto).style.display = "none";

                        tryRequestToServer(function(){
                            new Ajax.Request("TalaoChequeControlador?acao=proxCheque&setor=o&idConta="+$('contaDespesa_'+vIndexPagto).value,{method:'post', onSuccess: e, onError: e});
                        });

            <%}%>
                    }
                }

                var indexNotes = 0;
                function addNotes(id, tipo, especie, serie, nf, data, venc, idfornecedor, fornecedor, idhist, historico, valor, doc, contaId){
                    var acao = '<%=acao%>';
                    var incluindo = (id == 0 ? true : false);
                    var _tr = '';
                    var _td = '';
                    var _opt1 = Builder.node('OPTION', {value:'a'}, 'Pago');
                    var _opt2 = Builder.node('OPTION', {value:'p'}, 'A Pagar');
                    contaId = (contaId == 0 ? <%=cfg.getConta_padrao_id().getIdConta()%>: contaId);

                    _tr = Builder.node('TR', {id:'trdesp'+indexNotes,name:'trdesp'+indexNotes, className:'CelulaZebra2'},
                    [Builder.node('TD',indexNotes+1),
                        Builder.node('TD',
                        [Builder.node('SELECT', {name:'tipoDesp'+indexNotes, id:'tipoDesp'+indexNotes, className:'fieldMin', onchange:'javascript:alteraTipoDespesa('+indexNotes+');$(\'idTipoDesp'+indexNotes+'\').value = this.value;'},[]),
                            Builder.node('INPUT', {type:'hidden', name:'idTipoDesp'+indexNotes, id:'idTipoDesp'+indexNotes,
                                value:tipo}),
                            Builder.node('LABEL', {name:'despesa_'+indexNotes,
                                id:'despesa_'+indexNotes, value:id, className:'linkEditar',
                                onClick:'javascript: verDesp('+id+');'})
                        ]
                    ),
                        Builder.node('TD',
                        [Builder.node('SELECT', {name:'especie'+indexNotes, id:'especie'+indexNotes, className:'fieldMin'},
                            [
            <%      Especie es = new Especie();
                ResultSet rsEsp = es.all(Apoio.getUsuario(request).getConexao());
                while (rsEsp.next()) {%>
                                    Builder.node('OPTION', {value:'<%=rsEsp.getString("id")%>'}, '<%=rsEsp.getString("especie")%>'),
            <%      }
                rsEsp.close();
            %>       ])]),
                                Builder.node('TD',
                                [Builder.node('INPUT', {type:'text', name:'serie'+indexNotes, id:'serie'+indexNotes,
                                        size:'4', maxLength:'3', value:serie, className:'fieldMin'}),
                                    Builder.node('INPUT',{type:'hidden', name:'idNota'+indexNotes, id:'idNota'+indexNotes, value:id},'')
                                ]),
                                Builder.node('TD',
                                [Builder.node('INPUT', {type:'text', name:'nf'+indexNotes, id:'nf'+indexNotes,
                                        size:'7', maxLength:'10', value:nf, className:'fieldMin'})
                                ]),
                                Builder.node('TD',
                                [Builder.node('INPUT', {type:'text', name:'dataNota'+indexNotes, id:'dataNota'+indexNotes,
                                        size:'12', maxLength:'10', value:data, className:'fieldMin',
                                        onBlur:'alertInvalidDate($(\'dataNota'+indexNotes+'\'));',
                                        onKeyDown:'fmtDate($(\'dataNota'+indexNotes+'\') , event);',
                                        onKeyUp:'fmtDate($(\'dataNota'+indexNotes+'\') , event);',
                                        onKeyPress:'fmtDate($(\'dataNota'+indexNotes+'\') , event);'})
                                ]),
                                Builder.node('TD',
                                [Builder.node('INPUT', {type:'hidden', name:'idfornecedor'+indexNotes, id:'idfornecedor'+indexNotes,
                                        value:idfornecedor}),
                                    Builder.node('INPUT', {type:'text', name:'fornecedor'+indexNotes, id:'fornecedor'+indexNotes,
                                        size:'32', maxLength:'80', value:fornecedor, className:'inputReadOnly8pt'}),
                                    Builder.node('INPUT', {type:'button', name:'localizaForn_'+indexNotes, id:'localizaForn_'+indexNotes,
                                        value:'...', className:'botoes',
                                        onClick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=21\',\'Fornecedor_'+indexNotes+'\');'
                                    })
                                ]),
                                Builder.node('TD',
                                [Builder.node('INPUT', {type:'hidden', name:'idhistoricoNota'+indexNotes, id:'idhistoricoNota'+indexNotes,
                                        value:idhist}),
                                    Builder.node('INPUT', {type:'text', name:'historicoNota'+indexNotes, id:'historicoNota'+indexNotes,
                                        size:'30', maxLength:'200', value:historico, className:'fieldMin'})
                                    //                            Builder.node('INPUT', {type:'button', name:'localizaHist_'+indexNotes, id:'localizaHist_'+indexNotes,
                                    //                                value:'...', className:'botoes',
                                    //                                onClick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=14\',\'Historico_'+indexNotes+'\');'
                                    //                            })
                                ]),
                                Builder.node('TD',
                                [Builder.node('INPUT', {type:'text', name:'valorNota'+indexNotes, id:'valorNota'+indexNotes,
                                        size:'8', maxLength:'12', value:formatoMoeda(valor), className:'inputReadOnly8pt',
                                        onchange:'seNaoFloatReset($(\'valorNota'+indexNotes+'\'), \'0.00\');'})
                                ]),
                                Builder.node('TD', (!incluindo ? '' :
                                    [Builder.node('IMG', {src:'img/lixo.png', title:'Excluir Despesa', className:'imagemLink',
                                        onClick:'excluirNota('+indexNotes+');'})
                                ]))
                            ]);

                            $('desp_notes').appendChild(_tr);

                            $('tipoDesp'+indexNotes).appendChild(_opt1);
                            $('tipoDesp'+indexNotes).appendChild(_opt2);

                            tipo = (tipo==""?"p":tipo);

                            $('tipoDesp'+indexNotes).value = tipo;
                            $('idTipoDesp'+indexNotes).value = tipo;
                            $('fornecedor'+indexNotes).readOnly = true;
                            $('valorNota'+indexNotes).readOnly = true;

                            var slc2_ = Builder.node("SELECT",{id:"contaDespesa_"+indexNotes, name:"contaDespesa_"+indexNotes, className:"fieldMin", onChange:"isUsarCheque("+indexNotes+")"});

                            var _opt1 = null;

                            for(var i = 0; i < listaConta.length; i++){
                                slc2_.appendChild(Builder.node("OPTION", {value: listaConta[i].id},listaConta[i].descricao));
                            }

                            var _inp = Builder.node('INPUT', {type:'text', name:'docDespCarta_'+indexNotes, id:'docDespCarta_'+indexNotes, size:'8', maxLength:'10', value: "", className:'fieldMin'});
                            var _chk = Builder.node('INPUT', {type:'checkbox', name:'isCheque_'+indexNotes, id:'isCheque_'+indexNotes ,className:'fieldMin', onClick:"isUsarCheque("+indexNotes+")"});
                            var _lab = Builder.node('LABEL', "Cheque ");

                            var slc1_ = Builder.node("SELECT",{id:"docDespCarta_cb_"+indexNotes, name:"docDespCarta_cb_"+indexNotes, className:"fieldMin"});
                            var _opt = Builder.node('OPTION', {value:''}, '-----');

                            slc1_.appendChild(_opt);

                            var _td0 = Builder.node("TD");
                            var _td1 = Builder.node("TD",{colSpan:"4"});
                            var _td2 = Builder.node("TD",{colSpan:"5"});

                            _td1.appendChild(slc2_);
                            _td2.appendChild(_chk);
                            _td2.appendChild(_lab);
                            _td2.appendChild(_inp);
                            _td2.appendChild(slc1_);

                            var _tr2 = Builder.node('TR', {id:'trdesp2_'+indexNotes,name:'trdesp2_'+indexNotes, className:'CelulaZebra2'});
                            _tr2.appendChild(_td0);
                            _tr2.appendChild(_td1);
                            _tr2.appendChild(_td2);

                            $('desp_notes').appendChild(_tr2);

                            invisivel(slc1_);
                            invisivel(_tr2);

                            //Criando a tabela de Apropriações
                            _tr = Builder.node('TR', {id:'trApropDesp'+indexNotes},
                            [Builder.node('TD',{colSpan:'10'},
                                [Builder.node('TABLE', {id:'TB'+indexNotes, width:'100%', border:'0'},
                                    [Builder.node('TBODY', {id:'TBODYNOTES'+indexNotes},
                                        [Builder.node('TR', {className:'CelulaZebra1'},
                                            [Builder.node('TD', {width:'2%'}, (!incluindo ? '' :
                                                    [Builder.node('IMG', {src:'img/add.gif', title:'Adicionar Apropriação', className:'imagemLink',
                                                        onClick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=20\',\'Plano_'+indexNotes+'\');'})
                                                ])),
                                                Builder.node('TD', {width:'42%'}, 'Plano de custo'),
                                                Builder.node('TD', {width:'14%'}, 'Veículo'),
                                                Builder.node('TD', {width:'9%'}, 'Valor'),
                                                Builder.node('TD', {width:'10%'}, 'Und. custo'),
                                                Builder.node('TD', {width:'3%'}, ''),
                                                Builder.node('TD', {width:'10%'}, 'Vencimento :'),
                                                Builder.node('TD', {width:'10%'},
                                                [Builder.node('INPUT', {type:'text', name:'dataVenc'+indexNotes, id:'dataVenc'+indexNotes,
                                                        size:'12', maxLength:'10', value:venc, className:'fieldMin',
                                                        onBlur:'alertInvalidDate($(\'dataVenc'+indexNotes+'\'));',
                                                        onKeyDown:'fmtDate($(\'dataVenc'+indexNotes+'\') , event);',
                                                        onKeyUp:'fmtDate($(\'dataVenc'+indexNotes+'\') , event);',
                                                        onKeyPress:'fmtDate($(\'dataVenc'+indexNotes+'\') , event);'})
                                                ])
                                            ])
                                        ])
                                    ])
                                ])
                            ]);
                            $('desp_notes').appendChild(_tr);

                            if (!incluindo){
                                $('contaDespesa_'+indexNotes).value = contaId;
                                $('especie'+indexNotes).disabled = true;
                                $('tipoDesp'+indexNotes).disabled = true;
                                $('contaDespesa_'+indexNotes).disabled = true;
                                $('serie'+indexNotes).readOnly = true;
                                $('nf'+indexNotes).readOnly = true;
                                $('dataNota'+indexNotes).readOnly = true;
                                $('dataVenc'+indexNotes).readOnly = true;
                                $('historicoNota'+indexNotes).readOnly = true;
                                $('docDespCarta_'+indexNotes).readOnly = true;
                                $('isCheque_'+indexNotes).disabled = true;
                                $('localizaForn_'+indexNotes).style.display = "none";
                                //$('localizaHist_'+indexNotes).style.display = "none";
                                $('especie'+indexNotes).style.backgroundColor = '#FFFFF1';
                                invisivel($('tipoDesp'+indexNotes));
                                $('tipoDesp'+indexNotes).style.backgroundColor = '#FFFFF1';
                                $('isCheque_'+indexNotes).style.backgroundColor = '#FFFFF1';
                                $('serie'+indexNotes).style.backgroundColor = '#FFFFF1';
                                $('nf'+indexNotes).style.backgroundColor = '#FFFFF1';
                                $('docDespCarta_'+indexNotes).style.backgroundColor = '#FFFFF1';
                                $('dataNota'+indexNotes).style.backgroundColor = '#FFFFF1';
                                $('dataVenc'+indexNotes).style.backgroundColor = '#FFFFF1';
                                $('historicoNota'+indexNotes).style.backgroundColor = '#FFFFF1';
                                $('contaDespesa_'+indexNotes).style.backgroundColor = '#FFFFF1';
                                $('tipoDesp'+indexNotes).value = tipo;
                                $('docDespCarta_'+indexNotes).value = doc;
                                $('idTipoDesp'+indexNotes).value = tipo;
                            }
            
                            if (especie == '') {
                                $('especie'+indexNotes).selectedIndex = 0;
                            }else{
                                $('especie'+indexNotes).value = especie;
                            }
                            $('despesa_'+indexNotes).innerHTML = (id == 0 ? '' : id);
                            alteraTipoDespesa(indexNotes);
                            indexNotes++;
                        }

                        function totalNota(indexNota){
                            var total = 0;
                            for (i = 0; i < indexApp; ++i){
                                if ($('valorApp_'+indexNota+'_'+i) != null){
                                    total += parseFloat($('valorApp_'+indexNota+'_'+i).value);
                                }
                            }
                            $('valorNota'+indexNota).value = formatoMoeda(total);
                        }

                        var indexApp = 0;
                        function addApropriacao(indexNota, idApropriacao, conta, apropriacao, idVeiculo, veiculo, valor, incluindo, idUnd, und){
                            var _tr = '';
                            _tr = Builder.node('TR', {id:'trApropDesp'+indexNota+'_'+indexApp, className:'CelulaZebra1'},
                            [Builder.node('TD',''),
                                Builder.node('TD',
                                [Builder.node('INPUT', {type:'hidden', name:'idApropriacao_'+indexNota+'_'+indexApp, id:'idApropriacao_'+indexNota+'_'+indexApp,
                                        value:idApropriacao}),
                                    Builder.node('INPUT', {type:'text', name:'conta_'+indexNota+'_'+indexApp, id:'conta_'+indexNota+'_'+indexApp,
                                        size:'15', value:conta, className:'inputReadOnly8pt'}),
                                    Builder.node('INPUT', {type:'text', name:'apropriacao_'+indexNota+'_'+indexApp, id:'apropriacao_'+indexNota+'_'+indexApp,
                                        size:'35', value:apropriacao, className:'inputReadOnly8pt'}),
                                    Builder.node('INPUT', {type:'button', name:'localizaApp_'+indexNota+'_'+indexApp, id:'localizaApp_'+indexNota+'_'+indexApp,
                                        value:'...', className:'botoes',
                                        onClick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=20\',\'Plano_'+indexNota+'_'+indexApp+'\');'})
                                ]),
                                Builder.node('TD',
                                [Builder.node('INPUT', {type:'hidden', name:'idVeiculo_'+indexNota+'_'+indexApp, id:'idVeiculo_'+indexNota+'_'+indexApp,
                                        value:idVeiculo}),
                                    Builder.node('INPUT', {type:'text', name:'veiculo_'+indexNota+'_'+indexApp, id:'veiculo_'+indexNota+'_'+indexApp,
                                        size:'12', value:veiculo, className:'inputReadOnly8pt'}),
                                    Builder.node('INPUT', {type:'button', name:'localizaVei_'+indexNota+'_'+indexApp, id:'localizaVei_'+indexNota+'_'+indexApp,
                                        value:'...', className:'botoes',
                                        onClick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=24\',\'Veiculo_'+indexNota+'_'+indexApp+'\');'})
                                ]),
                                Builder.node('TD',
                                [Builder.node('INPUT', {type:'text', name:'valorApp_'+indexNota+'_'+indexApp, id:'valorApp_'+indexNota+'_'+indexApp,
                                        size:'8', maxLength:'12', value:formatoMoeda(valor), className:'fieldMin',
                                        onchange:'seNaoFloatReset($(\'valorApp_'+indexNota+'_'+indexApp+'\'), \'0.00\');totalNota('+indexNota+')'})
                                ]),
                                Builder.node('TD',
                                [Builder.node('INPUT', {type:'hidden', name:'idUnd_'+indexNota+'_'+indexApp, id:'idUnd_'+indexNota+'_'+indexApp,
                                        value:idUnd}),
                                    Builder.node('INPUT', {type:'text', name:'und_'+indexNota+'_'+indexApp, id:'und_'+indexNota+'_'+indexApp,
                                        size:'5', value:und, className:'inputReadOnly8pt'}),
                                    Builder.node('INPUT', {type:'button', name:'localizaUnd_'+indexNota+'_'+indexApp, id:'localizaUnd_'+indexNota+'_'+indexApp,
                                        value:'...', className:'botoes',
                                        onClick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=39\',\'Und_'+indexNota+'_'+indexApp+'\');'})
                                ]),
                                Builder.node('TD', (!incluindo ? '' :
                                    [Builder.node('IMG', {src:'img/lixo.png', title:'Excluir Despesa', className:'imagemLink',
                                        onClick:'excluirApp('+indexNota+','+indexApp+');'})
                                ])),
                                Builder.node('TD',''),
                                Builder.node('TD','')
                            ]);
                            $('TBODYNOTES'+indexNota).appendChild(_tr);

                            $('conta_'+indexNota+'_'+indexApp).readOnly = true;
                            $('apropriacao_'+indexNota+'_'+indexApp).readOnly = true;
                            $('veiculo_'+indexNota+'_'+indexApp).readOnly = true;
                            $('und_'+indexNota+'_'+indexApp).readOnly = true;
                            if (!incluindo){
                                $('valorApp_'+indexNota+'_'+indexApp).readOnly = true;
                                $('localizaVei_'+indexNota+'_'+indexApp).style.display = "none";
                                $('localizaUnd_'+indexNota+'_'+indexApp).style.display = "none";
                                $('localizaApp_'+indexNota+'_'+indexApp).style.display = "none";
                                $('valorApp_'+indexNota+'_'+indexApp).style.backgroundColor = '#FFFFF1';
                            }
                            indexApp++;
                        }

                        function limpaDestinatarioCodigo(){
                            $('iddestinatario').value = '0';
                            $('des_codigo').value = '';
                            $('dest_rzs').value = '';
                            $('dest_cnpj').value = '';
                        }
                        var windowDestinatario = null;

                        //  -- inicio localiza rematente pelo codigo
                        function localizaDestinatarioCodigo(campo, valor, isDestEntrega){
                            //objeto funcao usado na requisicao Ajax(uma espécie de evento)
                            function e(transport){
                                var resp = transport.responseText;
                                espereEnviar("",false);
                                //se deu algum erro na requisicao...
                                if (resp == 'null'){
                                    alert('Erro ao Localizar Cliente.');
                                    return false;
                                }else if (resp == 'INA'){
                                    limpaDestinatarioCodigo();
                                    alert('Cliente Inativo.');
                                    return false;
                                }else if(resp == ''){
                                    limpaDestinatarioCodigo();
                                    //$("pontoReferencia").value = "";
                                    if (confirm("Cliente Não Encontrado, Deseja Cadastrá-lo Agora?")){
                                        window.open('./cadcliente?acao=iniciar','Cliente','top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                                    }
                                    return false;
                                }else{
                                    var cliControl = eval('('+resp+')');

                                    $('iddestinatario').value = cliControl.idcliente;
                                    $('des_codigo').value = cliControl.idcliente;
                                    $('dest_rzs').value = cliControl.razao;
                                    $('dest_cnpj').value = cliControl.cnpj;
                                    aoClicarNoLocaliza('Destinatario');
                                }
                            }//funcao e()

                            if (valor != ''){
                                espereEnviar("",true);
                                tryRequestToServer(function(){
                                    new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor="+valor+"&idfilial=0&campo="+campo,{method:'post', onSuccess: e, onError: e});
                                });
                            }
                        }

                        function limpaRemetenteCodigo(){
                            $('idremetente').value = '0';
                            $('rem_codigo').value = '';
                            $('rem_rzs').value = '';
                            $('rem_cnpj').value = '';
                        }

                        //  -- inicio localiza rematente pelo codigo
                        function localizaRemetenteCodigo(campo, valor, isRemColeta){

                            //objeto funcao usado na requisicao Ajax(uma espécie de evento)
                            function e(transport){
                                var resp = transport.responseText;
                                espereEnviar("",false);
                                //se deu algum erro na requisicao...
                                if (resp == 'null'){
                                    alert('Erro ao localizar cliente.');
                                    return false;
                                }else if (resp == 'INA'){
                                    limpaRemetenteCodigo();
                                    alert('Cliente inativo.');
                                    return false;
                                }else if(resp == ''){
                                    limpaRemetenteCodigo();
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
                                    
                                    // campos de endereço de coleta
                                    aoClicarNoLocaliza('Remetente');

                                }
                            }//funcao e()

                            if (valor != ''){
                                espereEnviar("",true);
                                tryRequestToServer(function(){
                                    new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor="+valor+"&idfilial=0&campo="+campo,{method:'post', onSuccess: e, onError: e});
                                });
                            }
                        }

                        function totaisNotas(){
                            //atualizando totais
                            $("totalNF").innerHTML = sumValorNotes('<%=venda.getId()%>');
                            $("totalPeso").innerHTML = sumPesoNotes('<%=venda.getId()%>');
                            $("totalVol").innerHTML = sumVolumeNotes('<%=venda.getId()%>');
                        }

                        function applyEventInNote(idColeta) {
                            var lastIndex = (getNextIndexFromTableRoot('<%=venda.getId()%>', 'tableNotes0') - 1);

                            //aplicando o evento ao ultimo nf_valor adicionado
                            var lastVlNote = $("nf_valor"+lastIndex+"_id<%=venda.getId()%>");
                            if (lastVlNote != null){
                                lastVlNote.onchange = function(){
                                    seNaoFloatReset(lastVlNote,"0.00");
                                    //atualizando totais
                                    $("totalNF").innerHTML = sumValorNotes('<%=venda.getId()%>');
                                };
                            }

                            //aplicando o evento ao ultimo nf_peso adicionado
                            var lastVlPeso = getObj("nf_peso"+lastIndex+"_id<%=venda.getId()%>");
                            if (lastVlPeso != null){
                                lastVlPeso.onchange = function(){
                                    seNaoFloatReset(lastVlPeso,"0.00");
                                    //atualizando totais
                                    $("totalPeso").innerHTML = sumPesoNotes('<%=venda.getId()%>');
                                };
                            }

                            //aplicando o evento ao ultimo nf_volume adicionado
                            var lastVlVolume = $("nf_volume"+lastIndex+"_id<%=venda.getId()%>");
                            if (lastVlVolume != null){
                                lastVlVolume.onchange = function(){
                                    seNaoFloatReset(lastVlVolume,"0.00");
                                    //atualizando totais
                                    $("totalVol").innerHTML = sumVolumeNotes('<%=venda.getId()%>');
                                };
                            }
                        }
                        
                        function localizaClienteCodigo(campo, valor) {
                            console.log("chegou aqui");
                            //objeto funcao usado na requisicao Ajax(uma espécie de evento)
                            function e(transport) {
                                var resp = transport.responseText;
                         
                                espereEnviar("", false);
                                //se deu algum erro na requisicao...
                                if (resp == 'null') {
                                    alert('Erro ao localizar cliente.');
                                    return false;
                                } else if (resp == 'INA') {
                                    $('idconsignatario').value = '0';
                                    $('cliente').value = '';
                                    $('con_rzs').value = '';
                                    $('rem_cidade').value = '';
                                    $('rem_uf').value = '';
                                    $('rem_cnpj').value = '';
                                    $('rem_email').value = '';
                                    $('remtabelaproduto').value = 'f';
                                    alert('Cliente inativo.');
                                    return false;
                                } else if (resp == '') {
                                    $('idconsignatario').value = '0';
                                    $('rem_codigo').value = '';
                                    $('con_rzs').value = '';
                                    $('rem_cidade').value = '';
                                    $('rem_uf').value = '';
                                    $('rem_cnpj').value = '';
                                    $('rem_email').value = '';
                                    $('remtabelaproduto').value = 'f';

                                    if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")) {
                                        window.open('./cadcliente?acao=iniciar', 'Cliente', 'top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                                    }
                                    return false;
                                } else {
                                    
                                    var cliControl = eval('(' + resp + ')');
//                                    $('idconsignatario').value = cliControl.idcliente;

                                    try {
                                        $('idconsignatario').value = cliControl.idcliente;
                                    $('con_rzs').value = cliControl.razao;
                                    $('con_cnpj').value = cliControl.cnpj;//idconsignatario
//                                    $('rem_cnpj').value = cliControl.cnpj;//idconsignatario
                                    $("ven_rzs").value = cliControl.vendedor;
//                                    $("rem_rzs").value = cliControl.razao;//Remetente
                                    $("idvendedor").value = cliControl.idvendedor;
                                    $("comissaovendedor").value = cliControl.vlcomissao_vendedor;
                                   

                                    var filial = $("idfilial").value;

                                    if (cliControl.tipo_origem_frete == "f" && $("cidadeFilial_" + filial) != null) {
                                        var idCidadeFl = ($("cidadeFilial_" + filial).value).split("!!")[0];
                                        var cidadeFl = ($("cidadeFilial_" + filial).value).split("!!")[1];
                                        var ufFl = ($("cidadeFilial_" + filial).value).split("!!")[2];

//                                        $("cid_id_origem").value = idCidadeFl;
//                                        $('cid_nome_origem').value = cidadeFl;
//                                        $('cid_uf_origem').value = ufFl;

                                    } else {

//                                        $("cid_id_origem").value = cliControl.idcidade;
//                                        $('cid_nome_origem').value = cliControl.cidade;
//                                        $('cid_uf_origem').value = cliControl.uf;
                                    }
                                    $("con_idcidade").value = cliControl.idcidade;
//                                    $('cid_nome_origem').value = cliControl.cidade;
//                                    $('cid_uf_origem').value = cliControl.uf;

//                                    $("endereco_col").value = cliControl.endereco_col;
//                                    $("bairro_col").value = cliControl.bairro_col;
//                                    $('cid_nome_coleta').value = cliControl.cidade_col;
//                                    $('cid_uf_coleta').value = cliControl.uf_col;
//                                    $("cid_id_coleta").value = cliControl.idcidade_col;

//                                    $("tipofrete").value = cliControl.tipotaxa;
//                                    $("rem_email").value = cliControl.email;
//                                    $('remtabelaproduto').value = cliControl.is_tabela_apenas_produto;
//                                    $('remtipofpag').value = cliControl.tipofpag;
//                                    $('rem_pgt').value = cliControl.pgt;

//                                    getTipoProdutos();
//                                    getCondicaoPagto();
                                    }catch(e){
                                        console.log(e);
                                        alert(e);
                                    }
                                }
                            }//funcao e()

                            if (valor != '') {
                                espereEnviar("", true);
                                tryRequestToServer(function() {
                                    new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor=" + valor + "&idfilial=0&campo=" + campo, {method: 'post', onSuccess: e, onError: e});
                                });
                            }
                        }
                        
                        function localizarCidadeNFSe(){
                            launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CIDADE_NFSE%>','Cidade');
                        }
                        
                        function mostrarEsconderCidadesNFSe(valor){
                            if (valor == "1" ) {
                                $("idcidade").value = $("fi_idcidade").value;
                                $("cidade").value = ($("fi_cidade").value == null || $("fi_cidade").value == 'null' ? '' : $("fi_cidade").value);
                                $("uf").value = ($("fi_uf").value == null || $("fi_uf").value == 'null' ? '' : $("fi_uf").value);
                                $("divLblCidade").style.display = "";
                                $("divInpCidade").style.display = "";
                                $("btnLocalizaCidadeNFSe").style.display = "none";
                            }else if(valor == "2"){
                                $("idcidade").value = $("con_idcidade").value;
                                $("cidade").value = ($("con_cidade").value == null || $("con_cidade").value == 'null' ? '' : $("con_cidade").value);
                                $("uf").value = ($("con_uf").value == null || $("con_uf").value == 'null' ? '' : $("con_uf").value);
                                $("divLblCidade").style.display = "";
                                $("divInpCidade").style.display = "";
                                $("btnLocalizaCidadeNFSe").style.display = "";
                            }else if (valor == "3" ) {
                                $("idcidade").value = $("fi_idcidade").value;
                                $("cidade").value = ($("fi_cidade").value == null || $("fi_cidade").value == 'null' ? '' : $("fi_cidade").value);
                                $("uf").value = ($("fi_uf").value == null || $("fi_uf").value == 'null' ? '' : $("fi_uf").value);
                                $("divLblCidade").style.display = "";
                                $("divInpCidade").style.display = "";
                                $("btnLocalizaCidadeNFSe").style.display = "none";
                            }else{
                                $("cidade").value = "";
                                $("idcidade").value = "0";
                                $("divLblCidade").style.display = "none";
                                $("divInpCidade").style.display = "none";
                                $("btnLocalizaCidadeNFSe").style.display = "none";
                            }
                        }
                        
                        
        //função para validar se o plano de custo já exite;
        function checkPlanoCustoRepetido(indexPlano){
            var planoAtual = $('idplcustopadrao').value;
            for (var i = 0; i < indexApp; i++) {
                //varre todos os planos
                if((($("idApropriacao_"+indexPlano+'_'+i)) != null && ($("idApropriacao_"+indexPlano+'_'+i)) != undefined) 
                        && (planoAtual == ($("idApropriacao_"+indexPlano+'_'+i)).value)){
                    return true;
                    break;
                }
            }
            return false;
        }
        
        
        function pesquisarAuditoria() {    
            console.log("countLog: "+countLog);
            for (var i = 1; i <= countLog; i++) {
                if ($("tr1Log_" + i) != null) {
                    Element.remove(("tr1Log_" + i));
                }
                if ($("tr2Log_" + i) != null) {
                    Element.remove(("tr2Log_" + i));
                }
            }
            countLog = 0;
            var rotina = "cadvenda";
            var dataDe = $("dataDeAuditoria").value;
            var dataAte = $("dataAteAuditoria").value;
            var id = '<%=(venda != null ? venda.getId() : 0)%>'; 
            consultarLog(rotina, id, dataDe, dataAte);
        }       
        
        function habilitarAverbacao() {
            if ($("ckprotocoloAverbacao").checked == true) {
                $("protocoloAverbacao").disabled = false;
            } else {
                $("protocoloAverbacao").disabled = true;
            }
        }
               
        function verDesp(id){
            window.open("./caddespesa?acao=editar&id="+id+"&ex=false", "Despesa" , "top=0,resizable=yes,status=1,scrollbars=1");
        }
        
        function usarClienteRemetente(){
            if($("idconsignatario").value != '0' && $("idremetente").value == '0' && $('tipoNota').value == 'l'){
                $("rem_rzs").value = $("con_rzs").value;
                $("idremetente").value = $("idconsignatario").value;
                $("rem_cnpj").value = formatCpfCnpj($("con_cnpj").value, true , true);
                $("rem_codigo").value = $("idconsignatario").value;
                $("idcidadeorigem").value = ($("con_idcidade").value == '0' ? $("con_cidadeID").value: $("con_idcidade").value);
            }
        }
        </script>

        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>Lan&ccedil;amento de Nota de Servi&ccedil;o</title>
    </head>
    <style type="text/css">
        <!--
        .cellNotes {
            font-size: 10px;
            background-color:#E6E6E6;
        }
        .textfieldsObs{
            font-size:9px;
            clear: both;
            border: 0.3;
            padding: 1px;
        }        
        -->
    </style>

    <body onLoad="_onload();applyFormatter();alteraTipo();">
        <img src="img/banner.gif">
        <br>
        <%-- Tipo de servico  --%>
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
        <input type="hidden" id="is_logistico" name="is_logistico" value="">
        <input type="hidden" id="quantidade_casas_decimais_quantidade" value="0">
        <input type="hidden" id="quantidade_casas_decimais_valor" value="0">
        <input type="hidden" id="exigibilidade_iss" value="0">
        <%-- Apropriação --%>
        <input type="hidden" id="idplanocusto">
        <input type="hidden" id="plcusto_conta">
        <input type="hidden" id="plcusto_descricao">
        <input type="hidden" name="con_analise_credito" id="con_analise_credito" value="<%=(carrega_venda ? venda.getCliente().isAnaliseCredito() : "f")%>">
        <input type="hidden" name="con_valor_credito" id="con_valor_credito" value="<%=(carrega_venda ? venda.getCliente().getCreditoDisponivel() : 0)%>">
        <input type="hidden" name="con_is_bloqueado" id="con_is_bloqueado" value="<%=(carrega_venda ? venda.getCliente().isCreditoBloqueado() : "f")%>">
        <input type="hidden" id="idfornecedor" value="0">
        <input type="hidden" id="fornecedor" value="">
        <input type="hidden" id="contaplcusto" value="">
        <input type="hidden" id="descricaoplcusto" value="">
        <input type="hidden" id="idplcustopadrao" value="0">
        <input type="hidden" name="id_und_forn" id="id_und_forn" value="0">
        <input type="hidden" name="sigla_und_forn" id="sigla_und_forn" value="0">
        <input type="hidden" id="idplanocusto_despesa">
        <input type="hidden" id="plcusto_conta_despesa">
        <input type="hidden" id="plcusto_descricao_despesa">
        <!-- Conteudo -->
        <input type="hidden" id="desc_prod" name="desc_prod" value="">
        <!--Cidades do consignatario-->
        <input type="hidden" id="con_cidade" value="<%=(carrega_venda ? venda.getCidadePrestacaoNFSeId().getDescricaoCidade() : "")%>">
        <input type="hidden" id="con_uf" value="<%=(carrega_venda ? venda.getCidadePrestacaoNFSeId().getUf() : "")%>">
        <input type="hidden" id="con_idcidade" value="<%=(carrega_venda ? venda.getCidadePrestacaoNFSeId().getIdcidade() : "")%>">
        <!--Cidade da filial-->
        <input type="hidden" id="fi_cidade" value="<%=(carrega_venda ? venda.getFilial().getCidade().getDescricaoCidade() : Apoio.getUsuario(request).getFilial().getCidade().getDescricaoCidade())%>">
        <input type="hidden" id="fi_uf" value="<%=(carrega_venda ? venda.getFilial().getCidade().getUf() : Apoio.getUsuario(request).getFilial().getCidade().getUf())%>">
        <input type="hidden" id="fi_idcidade" value="<%=(carrega_venda ? venda.getFilial().getCidade().getIdcidade() : Apoio.getUsuario(request).getFilial().getCidade().getIdcidade())%>">
        <!-- valida carecteres especiais -->
        <input type="hidden" id="observacaoCarecteres" name="observacaoCarecteres" value="">
        <input type="hidden" id="complementoCarecteres" name="complementoCarecteres" value="">
        <input type="hidden" id="maxServico" name="maxServico" value="0">
        <input type="hidden" id="con_cnpj" name="con_cnpj" value="<%=(carrega_venda ? venda.getCliente().getCnpj(): "")%>">
        <input type="hidden" id="con_cidadeID" name="con_cidadeID" value="<%=(carrega_venda ? venda.getCliente().getCidade().getIdcidade(): "null")%>">
        
        <input type="hidden" name="especieOriginal" id="especieOriginal" value="">
        <input type="hidden" name="serieOriginal" id="serieOriginal" value="">
        <input type="hidden" name="idfilialOriginal" id="idfilialOriginal" value="">
        <input type="hidden" name="agency_idOriginal" id="agency_idOriginal" value="">
        <input type="hidden" name="numeroOriginal" id="numeroOriginal" value="">

        <div align="center">
            <table width="90%" align="center" class="bordaFina" >
                <tr>
                    <td width="613" align="left">
                        <b>Lan&ccedil;amento de Nota de Servi&ccedil;o </b>
                    </td>
                    <%   if ((acao.equals("editar")) && (nivelUser >= 4) && (request.getParameter("ex") == null)) {
                    %>	      <td width="15">
                        <input name="excluir" type="button" class="botoes" value="Excluir" onClick="javascript:tryRequestToServer(function(){excluir('<%=(carrega_venda ? venda.getId() : 0)%>');});">
                    </td>
                    <%}%>    
                    <td width="56" >
                        <input  name="Button" type="button" class="botoes" value="Voltar para Consulta" onClick="tryRequestToServer(function(){voltar();})">
                    </td>
                </tr>
            </table>
        </div>
        <br>
        <form id="form1"  method="post" target="pop">
            <div align="center">
                <table width="90%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                    <tr class="tabela">
                        <td colspan="8" align="center">Dados Principais</td>
                    </tr>
                    <tr>
                        <td width="10%" class="TextoCampos">Filial:</td>
                        <td width="15%" class="CelulaZebra2">
                            <input type="hidden" id="numeroCtrcId" name="numeroCtrcId" value="<%=(carrega_venda ? venda.getCtrcId() : 0)%>">
                            <input type="hidden" id="objCountIdxNotes" name="objCountIdxNotes" value="0">
                            <label for="fi_abreviatura">
                                <input type="text" size="10"  id="fi_abreviatura" readonly class="inputReadOnly" value="<%=(carrega_venda ? venda.getFilial().getAbreviatura() : Apoio.getUsuario(request).getFilial().getAbreviatura())%>" />
                                <input type="button" id="botFilial" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FILIAL%>','Filial')" value="..." />
                            </label>
                            <input type="hidden" id="idfilial" name="idfilial" value="<%=(carrega_venda ? venda.getFilial().getIdfilial() : Apoio.getUsuario(request).getFilial().getIdfilial())%>" />
                        </td>
                        <td width="10%" class="TextoCampos">Ag&ecirc;ncia:</td>
                        <td width="15%" class="CelulaZebra2">
                            <label for="ag_abreviatura">
                                <input type="text" size="12"  id="ag_abreviatura" readonly="readonly" class="inputReadOnly" value="<%=Apoio.coalesce((carrega_venda ? venda.getAgencia().getAbreviatura() : Apoio.getUsuario(request).getAgencia().getAbreviatura()), "")%>" />
                            </label>
                            <input type="hidden"  id="agency_id" name="agency_id"  value="<%=(carrega_venda ? venda.getAgencia().getId() : Apoio.getUsuario(request).getAgencia().getId())%>" />
                        </td>
                        <td width="10%" class="TextoCampos">CFOP:</td>
                        <td width="15%" class="CelulaZebra2">
                            <label for="cfop">
                                <input class="inputReadOnly" type="text" size="7" id="cfop" readonly  value="<%=(carrega_venda ? venda.getCfop().getCfop() : cfg.getCfopNotaServico().getCfop())%>" />
                                <input type="button" id="botCfop" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CFOP%>','Cfop')" value="..." />
                            </label>
                            <input type="hidden" id="idcfop" name="idcfop"  value="<%=(carrega_venda ? venda.getCfop().getIdcfop() : cfg.getCfopNotaServico().getIdcfop())%>" />
                        </td>
                        <td width="10%" class="TextoCampos">Nº Pedido:</td>
                        <td width="15%" class="CelulaZebra2">
                            <input class="inputtexto" type="text" size="10" id="pedido_cliente" name="pedido_cliente" maxlength="20" value="<%=(carrega_venda ? venda.getPedidoCliente() : "")%>" />
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">Esp&eacute;cie:</td>
                        <td class="CelulaZebra2">
                            <input type="text" id="especie" name="especie" size="4" maxlength="3" value="<%=(carrega_venda ? venda.getEspecie() : (Apoio.getUsuario(request).getFilial().getStUtilizacaoNfse() == 'M' ? "NFE" : "NFS"))%>" onChange="getNextSale()" class="inputtexto" />
                        </td>
                        <td class="TextoCampos">S&eacute;rie:</td>
                        <td class="CelulaZebra2">
                            <input type="text"  id="serie" name="serie" size="4" maxlength="3"  
                                   value="<%= (carrega_venda ? venda.getSerie() : (Apoio.getUsuario(request).getFilial().isUtilizacaoNFSeG2ka() ? (Apoio.getUsuario(request).getFilial().getCidade().getCod_ibge().equals("5201108"))
                                                                                                                                                    ? "8" 
                                                                                                                                                    : (Apoio.getUsuario(request).getFilial().getCidade().getCod_ibge().equals("3509502") ? "NF"
                                                                                                                                                    : Apoio.getUsuario(request).getFilial().getCidade().getCod_ibge().equals("4208203") ? "RP1" : "RPS") 
                                                                                    : (Apoio.getUsuario(request).getFilial().getStUtilizacaoNfse() == 'S' 
                                                                                                                                                    ? cfg.getSeriePadraoNotaServico() 
                                                                                                                                                    : (Apoio.getUsuario(request).getFilial().getCidade().getCod_ibge().equals("5201108")) ? "8" 
                                                                                                                                                    : (Apoio.getUsuario(request).getFilial().getCidade().getCod_ibge().equals("4208203")) ? "RP1" 
                                                                                                                                                    : (Apoio.getUsuario(request).getFilial().getCidade().getCod_ibge().equals("3509502")  && Apoio.getUsuario(request).getFilial().isUtilizacaoNFSeG2ka() ? "NF" : "RPS"))
                                                                                    )) %>" onChange="getNextSale()" class="inputtexto" />
                        </td>
                        <td class="TextoCampos">N&uacute;mero:</td>
                        <td class="CelulaZebra2">
                            <input  type="text" id="numero" name="numero" size="7" maxlength="7" value="<%=venda.getNumero()%>" class="inputtexto"/>
                        </td>
                        <td class="TextoCampos">Emiss&atilde;o:</td>
                        <td class="CelulaZebra2">
                            <input type="text" name="emissao_em" id="emissao_em" size="10" maxlength="10" class="fieldDate" onBlur="alertInvalidDate(this)" value="<%=(carrega_venda ? Apoio.fmt(venda.getEmissaoEm()) : Apoio.getDataAtual())%>" />
                        </td>
                    </tr>
                    <%if (Apoio.getUsuario(request).getFilial().getStUtilizacaoNfse() == 'M') {%>
                        <%if(!Apoio.getUsuario(request).getFilial().isUtilizacaoNFSeG2ka()){%>
                            <tr>
                                <td colspan="3" class="TextoCampos">Nota <%if (acao.equals("iniciar")) {%>a ser <%}%>substituída (NFS-e):</td>
                                <td class="CelulaZebra2">
                                    <input class="required inputReadOnly" type="text" size="10" id="notasubs" readonly="readonly"  value="<%=venda.getVendaSubs().getNumero()%>" />
                                    <%if (acao.equals("iniciar")) {%>
                                    <input type="button" class="botoes" onclick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.NOTA_SERVICO%>','Nota_De_Servico')" value="...">
                                    <%}%>
                                    <input type="hidden"  id="idnotasubs" name="idnotasubs" value="<%=venda.getVendaSubs().getId()%>"  />
                                </td>
                                <td class="TextoCampos">NFS-e:</td>
                                <td class="CelulaZebra2">
                                    <input class="required inputReadOnly" type="text" size="10" id="nfse" readonly="readonly"  value="<%=venda.getNumeroNFSe()%>" />
                                </td>
                                <td class="TextoCampos">RPS:</td>
                                <td class="CelulaZebra2">
                                    <input class="required inputReadOnly" type="text" size="10" id="rps" readonly="readonly"  value="<%=venda.getNumeroRPS()%>"/>
                                </td>
                            </tr>
                        <%}%>
                    <%}%>
                    <tr>
                        <td class="TextoCampos">Tipo:</td>
                        <td class="CelulaZebra2">
                            <select name="tipoNota" id="tipoNota" style="font-size:8pt;width:120px;" class="fieldMin" onchange="alteraTipo();">
                                <option value="n" selected>Normal</option>
                                <option value="l">Entrega Local(Cobrança)</option>
                                <option value="b">Cortesia</option>
                                <option value="p">Pallet</option>
                            </select>
                        </td>
                        <td colspan="2" class="TextoCampos">
                            <div align="center">
                                <input type="checkbox" name="is_cancelado" id="is_cancelado" <%= (venda.isCancelado() ? "checked=true" : "")%>  onclick="escondeMostraCancelamento(this.checked)"/>
                                Cancelado
                                <label name="lbCancelamentoEm" id="lbCancelamentoEm"><%=(venda.getCanceladoEm() == null ? "" : " em " + new SimpleDateFormat("dd/MM/yyyy").format(venda.getCanceladoEm()))%></label>
                            </div>
                        </td>
                        <td class="TextoCampos">
                            <label name="lbMotivoCancelamento" id="lbMotivoCancelamento">Motivo:</label>
                        </td>
                        <td colspan="3" class="CelulaZebra2">
                            <textarea name="motivoCancelamento" id="motivoCancelamento" class="inputtexto" rows="2" style="width:290px"><%=venda.getMotivoCancelamento()%></textarea>
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">Cliente:</td>
                        <td colspan="3" class="CelulaZebra2">
                            <input name="idconsignatario" type="text" id="idconsignatario" maxlength="5" size="4" value="<%=venda.getCliente().getIdcliente()%>" onKeyUp="javascript:if (event.keyCode == 13)
                                        localizaClienteCodigo('idcliente', this.value)" class="inputTexto">
                            <input class="required inputReadOnly" type="text" size="40" id="con_rzs" readonly="readonly" value="<%=venda.getCliente().getRazaosocial()%>" />
                            <input type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CONSIGNATARIO_DE_CONHECIMENTO%>','Consignatario')" value="..." />
                            <input type="hidden" id="con_pgt" name="con_pgt" value="30" />
                        </td>
                        <td class="TextoCampos">Vendedor:</td>
                        <td colspan="3" class="CelulaZebra2">
                            <input class="inputReadOnly" type="text" size="25" id="ven_rzs" readonly  value="<%=venda.getVendedor().getRazaosocial()%>" />
                            <input type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.VENDEDOR%>','Vendedor')" value="..." />
                            <img src="img/borracha.gif" border="0" class="imagemLink" onClick="$('idvendedor').value = '0'; $('ven_rzs').value = ''; ">
                            <input type="hidden"  id="idvendedor" name="idvendedor"  value="<%=venda.getVendedor().getIdfornecedor()%>"  />
                            <label style="display:<%=(nivelComissao == 0 ? "none" : "")%>;"> % </label>
                            <input type="text" class="inputTexto" style="display:<%=(nivelComissao == 0 ? "none" : "")%>;"  onChange="javascript:seNaoFloatReset(this,'0.00');" size="4" maxlength="12" id="comissaovendedor" name="comissaovendedor"  value="<%=venda.getComissaoVendedor()%>"  />
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos" colspan="2">
                            C&oacute;digo de Natureza da Opera&ccedil;&atilde;o:
                        </td>
                        <td class="CelulaZebra2" colspan="2">
                            <select name="naturezaOperacao" class="inputtexto" id="naturezaOperacao" onchange="javascript:mostrarEsconderCidadesNFSe(this.value);">
                                <option value="0" selected >Não Informado</option>
                                <option value="1">Tributação no Município</option>
                                <option value="2">Tributação Fora do Município</option>
                                <option value="3">Isenção</option>
                                <option value="4">Imune</option>
                                <option value="5">Exigibilidade Suspensa por Decisão Judicial</option>
                                <option value="6">Exigibilidade Suspensa por Procedimento Administrativo</option>
                            </select>
                        </td>
                        <td class="TextoCampos">
                            <div id="divLblCidade" name="divLblCidade" style="display: none">
                                <label>Cidade:</label>                                        
                            </div>
                        </td>
                        <td class="CelulaZebra2" colspan="3">
                            <div id="divInpCidade" name="divInpCidade" style="display: none">
                                <input id="cidade" name="cidade" class="inputReadOnly" type="text" size="20" readonly="" value="" />
                                <input id="uf" name="uf" class="inputReadOnly" type="text" size="3" readonly="" value="" />
                                <input id="idcidade" name="idcidade" type="hidden" value=""/>
                                <input id="btnLocalizaCidadeNFSe" name="btnLocalizaCidadeNFSe" type="button" class="botoes" onclick="javascript:localizarCidadeNFSe();" value="...">                                        
                            </div>
                        </td>
                    </tr>
                </table>
                <br>
                <div id="container" style="width:90%" align="center">
                    <div align="center">
                        <ul id="tabs">
                            <li>
                                <a href="#tab1"><strong>Itens da Nota de Servi&ccedil;o</strong></a>
                            </li>
                            <li>
                                <a href="#tab2"><strong>Informa&ccedil;&otilde;es Financeiras</strong></a>
                            </li>
                            <li>
                                <a href="#tab4" id="trNF"><strong>Informa&ccedil;&otilde;es Entrega</strong></a>
                            </li>
                            <li>
                                <a href="#tab3"><strong>Despesas Agregadas</strong></a>
                            </li>
                            <li>
                                <% if (utilizacaoNFSeG2ka) {%>
                                    <a href="#tab5"><strong>Dados NFS-e</strong></a>
                                <% } %>
                            </li>
                            <li>
                                <a href="#tab6"><strong>Auditoria</strong></a>
                            </li>
                        </ul>
                    </div>
                    <div class="panel" id="tab1">
                        <fieldset>
                            <table width="100%" border="0" class="bordaFina" align="center">
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
                                    <td class="CelulaZebra2"><input type="button" id="botAddOs" class="botoes" value="Adicionar servi&ccedil;os da OS" onClick="javascript:tryRequestToServer(function(){selecionaOS();});"></td>
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
                                                    <!--<td width="7%" >% ISS </td>-->
                                                    <!--<td width="9%" >Valor ISS</td>-->
                                                    <!--<td width="5%" >Trib</td>-->
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
                                                        <input type="hidden"  id="totalImpostosRetido" >
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
                                                        <input name="valorLiquido" type="text" class="inputReadOnly" id="valorLiquido"  onBlur="javascript:seNaoFloatReset(this,'0.00');" value="0.00" size="8" maxlength="12" readonly>
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
                        </fieldset>
                    </div>
                    <div class="panel" id="tab2">
                        <fieldset>
                            <table width="100%" border="0" class="bordaFina" align="center">
                                <tr class="tabela">
                                    <td width="100%">
                                        <div align="center">Duplicatas a Receber</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <table width="100%" border="0" class="bordaFina" align="center">
                                            <tr>
                                                <td width="15%" class="TextoCampos">QTD de Parcelas: </td>
                                                <td width="7%" class="CelulaZebra2">
                                                    <input type="text"  id="parcelCount" value="<%=venda.getDuplicatas().size() == 0 ? 1 : venda.getDuplicatas().size()%>" onChange="seNaoIntReset(this,'0');" size="4" class="inputtexto"/>
                                                </td>
                                                <td width="13%" class="CelulaZebra2">
                                                    <div align="center">
                                                        <input name="btCriarDupls" type="button" class="botoes" id="btCriarDupls" onClick="doParcels();" value="Criar Duplicatas" />
                                                    </div>
                                                </td>
                                                <td width="17%" class="TextoCampos"><b>Hist&oacute;rico Financeiro:</b></td>
                                                <td width="48%" class="CelulaZebra2">
                                                    <input name="descricao_historico" size="55" id="descricao_historico" class="fieldMin" maxlength="120" value="<%=venda.getHistorico().trim()%>">
                                                    <input type="button" class="botoes" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.HISTORICO_DE_LANCAMENTO%>', 'Historico');">
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <!-- Duplicatas -->
                                        <table width="100%" height="100%" border="0" cellpadding="0">
                                            <tbody id="table_parcels" name="table_parcels">
                                                <tr class="Celula">
                                                    <td width="8%">Parcela</td>
                                                    <td width="10%">Vencimento</td>
                                                    <td width="10%">Valor</td>
                                                    <td width="12%">Fatura</td>
                                                    <td width="12%">Dt.Pago</td>
                                                    <td width="10%">Vl.Pago</td>
                                                    <td width="12%">Conta</td>
                                                    <td width="8%">Docum.</td>
                                                    <td width="11%">Status</td>
                                                    <td width="7%"></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                        <!-- FIM Duplicatas -->
                                    </td>
                                </tr>
                                <tr>
                                    <td class="tabela">
                                        <div align="center">Apropria&ccedil;&otilde;es</div>
                                        <input name="id_und" type="hidden" id="id_und" value="0">
                                        <input name="sigla_und" type="hidden" id="sigla_und" value="aasdf">
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <table width="100%" height="100%" border="0" cellpadding="0">
                                            <tbody id="table_aprop" name="table_aprop">
                                                <tr class="Celula">
                                                    <td width="4%">
                                                        <div align="center">
                                                            <img src="./img/add.gif" border="0" alt="Add" style="cursor:pointer;" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=13','Apropriacao')" />
                                                        </div>
                                                    </td>
                                                    <td width="12%">Conta</td>
                                                    <td width="40%">Descri&ccedil;&atilde;o</td>
                                                    <td width="17%">Ve&iacute;culo</td>
                                                    <td width="12%"><div align="right">Valor</div></td>
                                                    <td width="15%">Und de Custo </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </div>
                    <div class="panel" id="tab3">
                        <fieldset>
                            <table width="100%" border="0" class="bordaFina" align="center">
                                <tr class="tabela">
                                    <td width="100%">
                                        <div align="center">Despesas Agregadas a Essa Nota de Servi&ccedil;o</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="7">
                                        <table border="0" cellpadding="0" cellspacing="1" width="100%">
                                            <tbody id="desp_notes">
                                                <tr class="celula">
                                                    <td width="2%" >
                                                        <img src="img/add.gif" border="0" class="imagemLink" title="Adicionar uma nova Nota fiscal" onClick="javascript:addNotes(0,'','','','',$('emissao_em').value,$('emissao_em').value,0,'',0,'',0,'',0);">
                                                    </td>
                                                    <td width="8%">Despesa</td>
                                                    <td width="6%">Esp&eacute;cie</td>
                                                    <td width="4%">S&eacute;rie</td>
                                                    <td width="6%">NF</td>
                                                    <td width="9%">Emiss&atilde;o</td>
                                                    <td width="28%">Fornecedor</td>
                                                    <td width="28%">Hist&oacute;rico</td>
                                                    <td width="7%">Valor</td>
                                                    <td width="2%">
                                                        <input type="hidden" id="qtdApp" name="qtdApp" value="0">
                                                        <input type="hidden" id="qtdNotas" name="qtdNotas" value="0">
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </div>
                    <div class="panel" id="tab4">
                        <fieldset>
                            <table width="100%" border="0" class="bordaFina" align="center">
                                <tr class="tabela">
                                    <td colspan="8">
                                        <div align="center">
                                            <font color="red">ATEN&Ccedil;&Atilde;O: Essa aba dever&aacute; ser preenchida apenas em caso de emissão de NFS para cada entrega local.</font>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="10%" class="TextoCampos">Coleta Nº:</td>
                                    <td width="15%" class="CelulaZebra2">
                                        <label id="numcoleta"></label><strong>&nbsp;<b><%=(venda.getColeta().getNumero() == null ? "&nbsp;" : venda.getColeta().getNumero())%></b>&nbsp;&nbsp;</strong>
                                        <input name="localiza_coleta" type="button" class="botoes" id="localiza_coleta" value="..." onClick="javascript:(getNotes(<%=venda.getId()%>)==''?launchPopupLocate('./localiza_coleta.jsp?idfilial='+$('idfilial').value, 'Coleta'):alert('Inclusão/Alteração da coleta não permitida, pois já existe, no mínimo, 1 nota fiscal lançada.'));">
                                        <img src="img/borracha.gif" border="0" class="imagemLink" onClick="(getNotes(<%=venda.getId()%>)==''?limpaColeta():alert('Alteração da coleta não permitida, pois já existe, no mínimo, 1 nota fiscal lançada.'));">
                                        <input type="hidden" name="idcoleta" id="idcoleta" value="<%=(carrega_venda ? venda.getColeta().getId() : 0)%>">
                                    </td>
                                    <td width="10%" class="TextoCampos">Nº Carga:</td>
                                    <td width="15%" class="CelulaZebra2">
                                        <input type="text" name="numCarga" id="numCarga" class="fieldMin" value="<%=(/*carrega_venda ?*/venda.getNumeroCarga())%>">
                                    </td>
                                    <td width="10%" class="TextoCampos">House AWB:</td>
                                    <td width="15%" class="CelulaZebra2">
                                        <input type="text" name="house_awb" size="13" maxlength="15" id="house_awb" class="fieldMin" value="<%=(/*carrega_venda ?*/venda.getHouseAwb())%>">
                                    </td>
                                    <td width="10%" class="TextoCampos">Master AWB:</td>
                                    <td width="15%" class="CelulaZebra2">
                                        <input type="text" name="master_awb" size="13" maxlength="15" id="master_awb" class="fieldMin" value="<%=(/*carrega_venda ?*/venda.getMasterAwb())%>">
                                    </td>
                                </tr>	
                                <tr>
                                    <td class="TextoCampos">Local Coleta:</td>
                                    <td class="CelulaZebra2">
                                        <input name="local_coleta" type="text" id="local_coleta" size="17" maxlength="50" style="font-size:8pt;" value="<%=(venda.getLocalColeta() == null ? "" : venda.getLocalColeta())%>" class="fieldMin">
                                    </td>
                                    <td class="TextoCampos">Local Entrega:</td>
                                    <td class="CelulaZebra2">
                                        <input name="entrega" type="text" id="entrega" size="17" maxlength="30" style="font-size:8pt;" value="<%=venda.getEntrega()%>" class="fieldMin">
                                    </td>
                                    <td class="TextoCampos">Tipo Produto:</td>
                                    <td class="CelulaZebra2">
                                        <select name="tipoproduto" onChange="getObj('vlmercadoria').focus();alteraTipoProduto();" id="tipoproduto" class="fieldMin" style="width:110px;">
                                            <option value="0">Nenhum</option>
                                            <% ResultSet product_types = TipoProduto.all(Apoio.getConnectionFromUser(request), 0, false,venda.getTipoProduto().getId());
                                                while (product_types != null && product_types.next()) {%>
                                            <option value="<%=product_types.getString("id")%>" style="background-color:#FFFFFF" <%=(carrega_venda && product_types.getInt("id") == venda.getTipoProduto().getId() ? "Selected" : "")%>> <%=product_types.getString("descricao")%> </option>
                                            <%}%>
                                        </select>
                                    </td>
                                    <td class="TextoCampos"></td>
                                    <td class="CelulaZebra2"></td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">Motorista: </td>
                                    <td class="CelulaZebra2" colspan="7">
                                        <input type="text" class="inputReadOnly8pt" id="motor_nome" name="motor_nome" value="<%= carrega_venda && venda.getNomeMotorista() != null ? venda.getNomeMotorista() : "" %>"> 
                                        <input type="hidden" class="text" id="idmotorista" name="idmotorista" value="<%= carrega_venda ? venda.getIdMotorista() : 0 %>">
                                        <input name="button6" type="button" class="botoes" onClick="javascript : tryRequestToServer(function(){launchPopupLocate('./localiza?categoria=loc_motorista&acao=consultar&idlista=10','Motorista');});" value="...">
                                        <strong>
                                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar motorista" onClick="getObj('idmotorista').value = '0';getObj('motor_nome').value = '';">
                                        </strong>
                                    </td>
                                </tr>
                                <tr class="tabela">
                                    <td colspan="4">
                                        <div align="center">Remetente</div>
                                    </td>
                                    <td colspan="4">
                                        <div align="center">Destinat&aacute;rio</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">Raz&atilde;o Social:</td>
                                    <td colspan="3" class="CelulaZebra2">
                                        <input name="idremetente" type="hidden" id="idremetente" size="3" value="<%=String.valueOf(venda.getRemetente().getIdcliente())%>" onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo('idcliente', this.value, false)" class="fieldMin">
                                        <input name="idcidadeorigem" type="hidden" id="idcidadeorigem" size="3" value="<%=String.valueOf(venda.getRemetente().getCidade().getIdcidade())%>">
                                        <input name="rem_codigo" type="hidden" id="rem_codigo" size="3" value="<%=String.valueOf(venda.getRemetente().getIdcliente())%>" onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo('idcliente', this.value, false)" class="fieldMin">
                                        <input name="rem_cnpj" type="text" class="inputReadOnly8pt" id="rem_cnpj" maxlength="23" size="20" value="<%=venda.getRemetente().getCnpj()%>" onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo('cnpj',this.value, false)">
                                        <input name="rem_rzs" type="text" class="inputReadOnly8pt" id="rem_rzs" size="30" value="<%=venda.getRemetente().getRazaosocial()%>" >
                                        <input name="button3" type="button" class="botoes" onClick="launchPopupLocate('./localiza?categoria=loc_cliente&acao=consultar&idlista=3','Remetente');" value="...">
                                        <strong>
                                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="getObj('idremetente').value = '0';getObj('rem_codigo').value = '';getObj('rem_rzs').value = '';getObj('rem_cnpj').value = '';">
                                        </strong>
                                    </td>
                                    <td class="TextoCampos">Raz&atilde;o Social:</td>
                                    <td colspan="3" class="CelulaZebra2">
                                        <input name="iddestinatario" type="hidden" id="iddestinatario" size="3" value="<%=String.valueOf(venda.getDestinatario().getIdcliente())%>" onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo('idcliente', this.value, false)" class="fieldMin">
                                        <input name="cidade_destino_id" type="hidden" id="cidade_destino_id" size="3" value="<%=String.valueOf(venda.getDestinatario().getCidade().getIdcidade())%>">
                                        <input name="des_codigo" type="hidden" id="des_codigo" size="3" value="<%=String.valueOf(venda.getDestinatario().getIdcliente())%>" onKeyUp="javascript:if (event.keyCode==13) localizaDestinatarioCodigo('idcliente',this.value, false)" class="fieldMin">
                                        <input name="dest_cnpj" type="text" class="inputReadOnly8pt" id="dest_cnpj" maxlength="18" size="20" value="<%=venda.getDestinatario().getCnpj()%>" onKeyUp="javascript:if (event.keyCode==13) localizaDestinatarioCodigo('cnpj',this.value, false)">
                                        <input name="dest_rzs" type="text" class="inputReadOnly8pt" id="dest_rzs" size="30" value="<%=venda.getDestinatario().getRazaosocial()%>">
                                        <input name="button32" type="button" class="botoes" onClick="launchPopupLocate('./localiza?categoria=loc_cliente&acao=consultar&idlista=4','Destinatario')" value="...">
                                        <strong>
                                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Destinat&aacute;rio" onClick="javascript:getObj('iddestinatario').value = '0';javascript:getObj('dest_rzs').value = '';getObj('dest_cnpj').value = '';">
                                        </strong> 
                                    </td>
                                </tr>
                            </table>
                            <table width="100%" border="0" class="bordaFina" align="center">
                                <tr class="tabela">
                                    <td width="100%">
                                        <div align="center">Notas Fiscais</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="11"> 
                                        <table id="tableNotes0" border="0" cellpadding="1" cellspacing="2" style="width:100%; height:100%; border: 1 solid #000">
                                            <tr>
                                                <td width="3%" class="cellNotes">
                                                    <img src="img/add.gif" border="0" title="Adicionar uma nova Nota fiscal" class="imagemLink" onClick="javascript:addNewNote('0','tableNotes0','true','<%=cfg.isBaixaEntregaNota()%>');countIdxNotes++;">
                                                </td>
                                                <td class="cellNotes" colspan="2"></td>
                                                <td class="cellNotes">N&uacute;mero</td>
                                                <td class="cellNotes">S&eacute;rie</td>
                                                <td class="cellNotes">Emiss&atilde;o</td>
                                                <td class="cellNotes">Valor</td>
                                                <td class="cellNotes">Peso</td>
                                                <td class="cellNotes">Volume</td>
                                                <td class="cellNotes">Embalagem</td>
                                                <td class="cellNotes">Conte&uacute;do</td>
                                                <td class="cellNotes">Base Icms</td>
                                                <td class="cellNotes">Vl. Icms</td>
                                                <td class="cellNotes">Icms S.Trib.</td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="11">
                                        <table border="0" cellpadding="0" cellspacing="0" style="width:100%; height:100%; border: 1 solid #000">
                                            <tr class="cellNotes">
                                                <td width="10%"><div align="right">QTD NOTAS:</div></td>
                                                <td width="6%"><label id="qtdNF" >(0)</label></td>
                                                <td width="10%">
                                                    <div align="right">TOTAIS&nbsp;&nbsp;</div>            
                                                    <div align="right"></div>
                                                </td>
                                                <td width="9%"><label id="totalNF" name="totalNF">0.00</label></td>
                                                <td width="7%">
                                                    <label id="totalPeso" name="totalPeso">0.00</label>            
                                                    <div align="right"></div>
                                                </td>
                                                <td width="36%"><label id="totalVol" name="totalVol">0.00</label></td>
                                                <td width="22%">&nbsp;</td>
                                            </tr>
                                        </table>                                
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </div>                                                
                    <% if(utilizacaoNFSeG2ka) {%>
                    <div class="panel" id="tab5">     
                         <% if(carrega_venda && venda.getStatusNFSe().equals("C")){%>
                         <table width="100%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                           <tr>
                               <td class="tabela" colspan="2"><div align="center" class="style1">Dados De Averbação</div></td>
                           </tr>

                           <tr>
                               <td class="TextoCampos">Protocolo de Averbação:</td>
                               <td  class="CelulaZebra2">
                                   <input type="checkbox" name="ckprotocoloAverbacao" id ="ckprotocoloAverbacao" onclick="javascript:habilitarAverbacao();" <%=(carrega_venda && venda.getProtocoloAverbacao()!=null && !venda.getProtocoloAverbacao().equals("")?  "checked=true": "")%>/>
                                   <input type="text" class="inputTexto" id="protocoloAverbacao" name="protocoloAverbacao" value="<%=(carrega_venda && venda.getProtocoloAverbacao()!=null ? venda.getProtocoloAverbacao() : "" )%>"/>
                               </td>                        
                           </tr>
                           
                       </table>
                        <%}%>
                        <fieldset class="TextoCampos">
                            <caption>
                                <div align="center"><b><font color="red">Atenção: As informações desse campo serão transmitidas para prefeitura no campo discriminação do serviço, substituindo a descrição do serviço informado na nota</font></b></div>
                                <div align="center"><b>Discriminação dos Serviços</b></div>
                            </caption>
                            <table width="100%" border="0" class="bordaFina" align="center">
                                <tr class="tabela">
                                    <td>
                                       <textarea cols="80" rows="15" id="descricaoServico" name="descricaoServico" style="width: 100%; height: 100%px;"><%=venda.getDescricaoServicoNFSeG2ka()%></textarea>                                                        
                                    </td>        
                                </tr>        
                            </table>                                    
                        </fieldset>
                       </div>
                       <%}%>   
                    <div class="panel" id="tab6">
                        <fieldset>
                            <table id="tableAuditoria" width="100%" class="bordaFina" align="center" name="tableAuditoria">
                                <tbody id="tbAuditoriaCabecalho">
                                    <tr>
                                        <td colspan="6"  class="tabela"><div align="center">Auditoria</div></td>
                                    </tr>
                                    <tr class="celula">
                                        <td colspan="3"  align="left">
                                            <label>Data da Ação:</label>
                                            <input type="text" class="fieldDate" id="dataDeAuditoria" maxlength="10" size="10" onBlur="alertInvalidDate(this)" value="" />
                                            <label> Até  </label>
                                            <input type="text" class="fieldDate" id="dataAteAuditoria" size="10" maxlength="10" onBlur="alertInvalidDate(this)" value="" />
                                        </td>
                                        <td colspan=""  >
                                            <input class="botoes" type="button" id="btPesquisarAuditoria" value=" Pesquisar " onclick="pesquisarAuditoria();" >
                                        </td>
                                        <td colspan="2"  ></td>
                                    </tr>
                                    <tr class="celula">
                                        <td width="3%"></td>
                                        <td width="17%">Usuário</td>
                                        <td width="15%">Data</td>
                                        <td width="15%">Ação</td>
                                        <td width="10%">IP</td>
                                        <td width="50%"></td>
                                    </tr>
                                </tbody>
                                <tbody id="tbAuditoriaConteudo">
                                </tbody>                                                  
                            </table>                        
                        </fieldset>
                    </div>                    
                </div>
                <br>
                <table width="90%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                    <tr>
                        <td class="tabela"><div align="center" class="style1">Dados Adicionais</div></td>
                    </tr>
                    <tr>
                        <td width="100%">
                            <table width="100%" border="0" align="center" cellpadding="2" cellspacing="1">
                                <tr>
                                    <td width="15%" class="TextoCampos">Observa&ccedil;&atilde;o:</td>
                                    <td width="35%" class="CelulaZebra2">
                                        <input name="obs_desc" id="obs_desc" type="hidden" />
                                        <input name="observacao" id="observacao1" size="50" maxlength="59" value="<%=venda.getObservacao()[0]%>" class="textfieldsObs" /><br>
                                        <input name="observacao" id="observacao2" size="50" maxlength="59" value="<%=venda.getObservacao()[1]%>" class="textfieldsObs" /><br>
                                        <input name="observacao" id="observacao3" size="50" maxlength="59" value="<%=venda.getObservacao()[2]%>" class="textfieldsObs" /><br>
                                        <input name="observacao" id="observacao4" size="50" maxlength="59" value="<%=venda.getObservacao()[3]%>" class="textfieldsObs" /><br>
                                        <input name="observacao" id="observacao5" size="50" maxlength="59" value="<%=venda.getObservacao()[4]%>" class="textfieldsObs" /><br>
                                    </td>
                                    <td width="2%" class="TextoCampos">
                                        <input type="button" class="botoes" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.OBSERVACAO%>', 'Observacao');">
                                    </td>
                                    <td width="48%" class="TextoCampos"></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                   
                    <%if (!acao.equals("iniciar")) {%>
                    <tr>
                        <td class="tabela"><div align="center">Auditoria</div></td>
                    </tr>
                    <tr>
                        <td>
                            <table width="100%"  border="0">
                                <tr>
                                    <td width="10%" class="TextoCampos">Incluso em: </td>
                                    <td width="40%" class="CelulaZebra2">Em: <%=(venda.getCreatedAt() == null ? "" : formatador.format(venda.getCreatedAt()))%><br>Por: <%=venda.getCreatedBy().getNome()%></td>
                                    <td width="10%" class="TextoCampos">Alterado em: </td>
                                    <td width="40%" class="CelulaZebra2">Em: <%=(venda.getUpdatedAt() == null ? "" : formatador.format(venda.getUpdatedAt()))%><br>Por: <%=venda.getUpdatedBy().getNome()%></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <%}%>
                    <tr>
                        <td class="CelulaZebra2">
                            <div align="center">
                                <%if (nivelUser > 1) {%>
                                <input style="text-align: center;" class="botoes" type="button" onclick="return salvar()" id="btSalvar" name="btSalvar" value="   Salvar   "/>
                                <%}%>
                            </div>
                        </td>
                    </tr>
                </table>
            </div>
        </form>
    </body>
</html>
