<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="nucleo.autorizacao.tipoautorizacao.TipoAutorizacao"%>
<%@page import="nucleo.Auditoria.Auditoria"%>
<%@page import="conhecimento.cartafrete.BeanCadCartaFrete"%>
<%@page import="conhecimento.cartafrete.BeanPagamentoCartaFrete"%>
<%@page import="fpag.BeanConsultaFPag"%>
<%@page import="com.sun.xml.internal.ws.message.saaj.SAAJHeader"%>
<%@page import="despesa.apropriacao.BeanApropDespesa"%>
<%@page import="mov_banco.conta.BeanConta"%>
<%@page import="mov_banco.conta.BeanConsultaConta"%>
<%@page import="despesa.BeanDespesa"%>
<%@page import="despesa.duplicata.BeanDuplDespesa"%>
<%@page import="despesa.especie.Especie"%>
<%@page import="conhecimento.coleta.BeanCidadesColeta"%>

<%@ page contentType="text/html" language="java"
         import="nucleo.*,
         cliente.*,
         org.json.simple.JSONObject,
         conhecimento.ocorrencia.Ocorrencia,
         conhecimento.coleta.*,
         conhecimento.orcamento.Cubagem,
         conhecimento.coleta.navio.*,
         conhecimento.coleta.terminal.*,
         conhecimento.coleta.tipoContainer.*,
         java.text.DecimalFormat,
         cidade.*,
         java.text.SimpleDateFormat,
         java.util.Vector,
         java.util.Date,
         tipo_veiculos.ConsultaTipo_veiculos,
         java.sql.ResultSet,
         java.net.*,
         com.sagat.bean.*" %>

<jsp:useBean id="cadcol" class="conhecimento.coleta.BeanCadColeta" />
<jsp:useBean id="col" class="conhecimento.coleta.BeanColeta" />
<jsp:useBean id="cadCarta" class="conhecimento.cartafrete.BeanCadCartaFrete" />

<%@page import="cliente.tipoProduto.TipoProduto"%>
<%@page import="venda.Tributacao"%>
<%@page import="venda.BeanVendaServico"%>
<%@page import="br.com.gwsistemas.movimentacao.pallets.MovimentacaoPallets"%>
<%@ page import="org.apache.commons.lang3.StringUtils" %>

<% 
    int nvAlFrete = Apoio.getUsuario(request).getAcesso("alttabprecolanccontrfrete");
    
    String fpagCartaFrete = "";
    
    int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadcoleta") : 0);
    
    int nivelAnaliseCredito = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("analisecreditocliente") : 0);
    
    int nivelUserFl = (nivelUser == 0 ? 0 : Apoio.getUsuario(request).getAcesso("lanconhfl"));
    int nivelUserAdiantamento = (Apoio.getUsuario(request) != null? Apoio.getUsuario(request).getAcesso("alterapercadiant") : 0);
    if (Apoio.getUsuario(request) == null || nivelUser == 0) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
    }
    boolean allowChangeTablePrice = (Apoio.getUsuario(request).getAcesso("alteratipofretecte") == 4);
    boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
    int idUsuario = Apoio.getUsuario(request).getIdusuario();

    //String notas = "";
    String acao = (request.getParameter("acao") == null || nivelUser == 0 ? "" : request.getParameter("acao"));
    col = new BeanColeta();
    

    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat fmtHora = new SimpleDateFormat("HH:mm");
    BeanConfiguracao cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    cfg.CarregaConfig();

// -----------------------------------------------------------------
    if (acao.equals("getNotaByNumero")) { // ajax necessário para trazer as notas que são da tramontina
        String numero = (request.getParameter("numero"));//numero da nota fiscal
        String cliente = (request.getParameter("cliente")); //id do cliente
        //String excetoIds = "0"; //ids que já foram incluidos
        cadcol = new BeanCadColeta();
        cadcol.setConexao(Apoio.getUsuario(request).getConexao());
        JSONObject jo = new JSONObject();

        ResultSet tabela = cadcol.getNotaByNumeroCliente(numero, cliente);
        if (tabela != null && tabela.next()) {
            for (int i = 1; i <= tabela.getMetaData().getColumnCount(); ++i) {

                if (tabela.getString(i) != null) {
                    if ((tabela.getString(i).equals("f") || tabela.getString(i).equals("t")) && tabela.getMetaData().getColumnName(i).startsWith("is")) {
                        jo.put(tabela.getMetaData().getColumnName(i), tabela.getBoolean(i) + "");
                    } else if (tabela.getMetaData().getColumnName(i).startsWith("emissao")) {
                        Date data = new Date();
                        data = tabela.getDate(i);
                        String dataEmissao = data != null ? new SimpleDateFormat("dd/MM/yyyy").format(data) + "" : "";
                        jo.put(tabela.getMetaData().getColumnName(i), dataEmissao);
                    } else {
                        jo.put(tabela.getMetaData().getColumnName(i), tabela.getString(i));
                    }
                } else {
                    jo.put(tabela.getMetaData().getColumnName(i), "");
                }

            }
            tabela.close();

            response.getWriter().append(jo.toString().replace("\"false\"", "false").replace("\"true\"", "true"));
        } else {
            response.getWriter().append("load=0");
        }

        response.getWriter().close();
        acao = "getNotaByNumero";
    }
    //------------------------------------------------------------------
    
    if(acao.equals("excluirNotaColeta")){
        
        Auditoria auditoria = new Auditoria();
        auditoria.setIp(request.getRemoteHost());
        auditoria.setAcao("Excluir Nota Coleta");
        auditoria.setRotina("Alterar Coleta");
        auditoria.setUsuario(Apoio.getUsuario(request));
        auditoria.setModulo("WebTrans Coleta");
        
        cadcol.removerNotaColeta(Apoio.parseInt(request.getParameter("idNota")), Apoio.getUsuario(request).getConexao(), auditoria);
    }
    //removendo o ajudante e adicionando a auditoria
    if(acao.equals("excluirAjudanteColeta")){
        Auditoria auditoria = new Auditoria();
        auditoria.setIp(request.getRemoteHost());
        auditoria.setAcao("Excluir Ajudante");
        auditoria.setRotina("Alterar Coleta");
        auditoria.setUsuario(Apoio.getUsuario(request));
        auditoria.setModulo("WebTrans Coleta");
        
        cadcol.removerAjudanteColeta(Apoio.parseInt(request.getParameter("idAjudante")),Apoio.parseInt(request.getParameter("idColeta")), Apoio.getUsuario(request).getConexao(), auditoria);
    }
    //Remover Ocorrência da coleta
    if(acao.equals("removerOcorrenciaColeta")){
    cadcol = new BeanCadColeta();
    cadcol.setConexao(Apoio.getUsuario(request).getConexao());
     int user = Apoio.getUsuario(request).getIdusuario();
        Auditoria auditoria = new Auditoria();
        auditoria.setIp(request.getRemoteHost());
        auditoria.setAcao("Excluir Ocorrencia Coleta");
        auditoria.setRotina("Alterar Coleta");
        auditoria.setUsuario(Apoio.getUsuario(request));
        auditoria.setModulo("WebTrans Coleta");
        
        String idOcorrenciaCTe = request.getParameter("idOcorrenciaCTe");
        String idOcorrencia = request.getParameter("idOcorrencia");
        String idColeta = request.getParameter("idColeta");
        cadcol.removerOcorrenciaColeta(idOcorrenciaCTe, idOcorrencia, auditoria, idColeta, user);
        
    }
    if(acao.equals("removerCidadeColeta")){
    cadcol = new BeanCadColeta();
    cadcol.setConexao(Apoio.getUsuario(request).getConexao());
    int user = Apoio.getUsuario(request).getIdusuario();
        Auditoria auditoria = new Auditoria();
        auditoria.setIp(request.getRemoteHost());
        auditoria.setAcao("Excluir Cidade Coleta");
        auditoria.setRotina("Alterar Coleta");
        auditoria.setUsuario(Apoio.getUsuario(request));
        auditoria.setModulo("WebTrans Coleta");
        
        String pdId = request.getParameter("pdId");
        String idColeta = request.getParameter("idColeta");
        cadcol.removerCidadeColeta(pdId, idColeta, auditoria, user);
        
    }
    
    
    cadcol = new BeanCadColeta();
    cadcol.setConexao(Apoio.getUsuario(request).getConexao());
    boolean carregacol = !(acao.equals("incluir") || acao.equals("atualizar") || acao.equals("iniciar"));
    //Carregando as taxas de ISS
    ResultSet rs2 = Tributacao.all("id,descricao, codigo", Apoio.getUsuario(request).getConexao());
    String taxes = "";


    while (rs2.next()) {
        taxes += (taxes.equals("") ? "" : "!!-") + rs2.getInt("id") + ":.:" + rs2.getString("codigo");
    }
    rs2.close();
    //Função para excluir itens da nota fiscal na coleta.
   
    if (acao != null && (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar") || acao.equals("excluir"))) {

        if (acao.equals("editar")) {
            cadcol.getColeta().setId(Integer.parseInt(request.getParameter("id")));
            carregacol = cadcol.LoadAllPropertys();
            col = (carregacol ? cadcol.getColeta() : null);
        } else if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir") || acao.equals("excluir"))) {
            //setando os atributos que nao podem ser setados dinamicamente(acoes: atualizar/incluir)
            if (acao.equals("atualizar") || acao.equals("incluir")) {

                //col.setId(acao.equals("atualizar") ? Integer.parseInt(request.getParameter("idcoleta") == null ? "0" : request.getParameter("idcoleta")) : 0);
                col.setId(Apoio.parseInt(request.getParameter("idcoleta")));
                col.getFilial().setIdfilial(Apoio.parseInt(request.getParameter("idfilial")));
                col.setNumero(request.getParameter("numcoleta"));
                col.setSolicitadaEm(Apoio.paraDate(request.getParameter("dtsolicitacao")));
                col.getCliente().setIdcliente(Apoio.parseInt(request.getParameter("idremetente_cl")));
                col.getRemetenteColeta().setIdcliente(Apoio.parseInt(request.getParameter("idremetente_coleta")));
                //col.getCliente().setRazaosocial(URLDecoder.decode(request.getParameter("rem_rzs_cl"), "UTF-8"));
                col.getCliente().setRazaosocial(request.getParameter("rem_rzs_cl"));
                col.getCliente().setFone(request.getParameter("rem_fone"));
                col.getCliente().setCnpj(request.getParameter("rem_cnpj_cl"));

                //col.getCliente().setEndereco(URLDecoder.decode(request.getParameter("rem_endereco"), "UTF-8"));
                col.getCliente().setEndereco(request.getParameter("rem_endereco"));

                //col.getCliente().setBairro(URLDecoder.decode(request.getParameter("rem_bairro"), "UTF-8"));
                col.getCliente().setBairro(request.getParameter("rem_bairro"));
                col.getCliente().getCidade().setIdcidade(Apoio.parseInt(request.getParameter("idcidadeorigem")));
                col.getDestinatario().setIdcliente(Apoio.parseInt(request.getParameter("iddestinatario_cl")));
                col.getDestinatarioEntrega().setIdcliente(Apoio.parseInt(request.getParameter("iddestinatario_entrega")));
                //col.getDestinatario().setRazaosocial(URLDecoder.decode(request.getParameter("dest_rzs_cl"), "UTF-8"));
                col.getDestinatario().setRazaosocial(request.getParameter("dest_rzs_cl"));
                col.setClientePagador(request.getParameter("clientepagador"));
                //col.setContato(URLDecoder.decode(request.getParameter("contato"), "UTF-8"));
                col.setContato(request.getParameter("contato"));
                //col.setPontoReferencia(URLDecoder.decode(request.getParameter("pontoReferencia"), "UTF-8"));
                col.setPontoReferencia(request.getParameter("pontoReferencia"));
                col.setPedidoCliente(request.getParameter("numpedido"));
                col.setNumeroRT(request.getParameter("rt"));
                col.getMotorista().setIdmotorista(Apoio.parseInt(request.getParameter("idmotorista")));
                col.setLiberacaoSeguradora(request.getParameter("motor_liberacao"));
                col.getVeiculo().setIdveiculo(Apoio.parseInt(request.getParameter("idveiculo")));
                col.getCarreta().setIdveiculo(request.getParameter("idcarreta").equals("0") ? 0 : Integer.parseInt(request.getParameter("idcarreta")));
                col.getBiTrem().setIdveiculo(request.getParameter("idbitrem").equals("0") ? 0 : Integer.parseInt(request.getParameter("idbitrem")));
                col.getTriTrem().setIdveiculo(request.getParameter("idtritrem").equals("0") ? 0 : Integer.parseInt(request.getParameter("idtritrem")));
                col.setTipoTaxa(Apoio.parseInt(request.getParameter("tipotaxa")));
                col.getTipoVeiculo().setId(Apoio.parseInt(request.getParameter("tipoveiculo")));
                col.getTipoProduto().setId(Apoio.parseInt(request.getParameter("tipoproduto")));
                col.setValorCombinado(Apoio.parseFloat(request.getParameter("vlcombinado")));
                col.setQtdeEntregas(Apoio.parseInt(request.getParameter("qtde_entregas")));
                col.setValorPernoite(Apoio.parseDouble(request.getParameter("valorPernoite")));
                col.setRecebedor(request.getParameter("recebedor"));
                //col.setObs(URLDecoder.decode(request.getParameter("obs"), "UTF-8"));
                col.setObs(request.getParameter("obs"));
                col.setColetaEm(request.getParameter("dtcoleta").equals("") ? null : Apoio.paraDate(request.getParameter("dtcoleta")));
                col.setColetaAs(request.getParameter("hrcoleta"));
                col.setPesoSolicitado(Apoio.parseFloat(request.getParameter("pesoSolicitado")));
                col.setVolumeSolicitado(Apoio.parseInt(request.getParameter("volumeSolicitado")));
                col.setValorMercadoriaSolicitada(Apoio.parseDouble(request.getParameter("mercadoriasolicitada")));
                col.setEmbalagemSolicitada(request.getParameter("embalagemSolicitada"));
                col.setConteudoSolicitada(request.getParameter("conteudoSolicitada"));

                col.setUrbano(Apoio.parseBoolean(request.getParameter("urbano")));
                col.setCategoria(request.getParameter("tipoPedido"));
                //
                col.setNumeroContainer(request.getParameter("numeroContainer"));
                col.setNumeroGenset(request.getParameter("genset"));
                col.setPesoContainer(Apoio.parseFloat(request.getParameter("pesoContainer")));
                col.setValorContainer(Apoio.parseFloat(request.getParameter("valorContainer")));
                col.setValorGenset(Apoio.parseDouble(request.getParameter("valorGenset")));
                col.setGensetHorimetroInicial(Apoio.parseInt(request.getParameter("horimInicial")));
                col.setGensetHorimetroFinal(Apoio.parseInt(request.getParameter("horimFinal")));
                col.getTipoContainer().setId(Apoio.parseInt(request.getParameter("tipoContainer")));
                col.setEntregaContainerEm(Apoio.paraDate(request.getParameter("entregaContainerEm")));
                col.setEntregaContainerAs(request.getParameter("entregaContainerAs")); //06/08/13
                col.setNumeroLacre(request.getParameter("lacre_container"));
                col.setNumeroBooking(request.getParameter("booking"));
                col.getNavio().setId(Apoio.parseInt(request.getParameter("navio").equals("") ? "0" : request.getParameter("navio")));
                col.setNumeroViagemNavio(request.getParameter("viagemContainer"));
                col.getArmador().setIdcliente(Apoio.parseInt(request.getParameter("idarmador").equals("") ? "0" : request.getParameter("idarmador")));
                col.getTerminal().setId(Apoio.parseInt(request.getParameter("terminal").equals("") ? "0" : request.getParameter("terminal")));
                col.getConsignatario().setIdcliente(Apoio.parseInt(request.getParameter("idconsignatario_con").equals("") ? "0" : request.getParameter("idconsignatario_con")));
                col.setTipoColeta(request.getParameter("tipoColeta"));
                col.setNumeroCarga(request.getParameter("numeroCarga"));       
                col.setValorPedagio(Apoio.parseDouble(request.getParameter("valorPedagio")));
                col.setPedagioRoteirizador(Apoio.parseBoolean(request.getParameter("isPedagioRoteirizador")));
                
                String pd = "0";
                int indexCob = Apoio.parseInt(request.getParameter("indexCob"));
                for (int i = 0; i <= indexCob; i++) {
                    if (request.getParameter("pedido_cobranca_id" + i) != null) {
                        pd += "," + request.getParameter("pedido_cobranca_id" + i);
                    }
                }

                BeanColetaDespesa pedidoDespesa = null;
                int indexDesp = Apoio.parseInt(request.getParameter("maxDespesa"));
                for (int i = 0; i <= indexDesp; i++) {
                    if (request.getParameter("idFornecedor_" + i) != null && request.getParameter("idDepesa_" + i).equals("0")) {
                        pedidoDespesa = new BeanColetaDespesa();
                        pedidoDespesa.getDespesa().setFilial(col.getFilial());
                        pedidoDespesa.getDespesa().setIdmovimento(Apoio.parseInt(request.getParameter("idDepesa_" + i)));
                        pedidoDespesa.getDespesa().setAVista(request.getParameter("tipoDesp_" + i).equals("a"));
                        pedidoDespesa.getDespesa().getEspecie_().setEspecie(request.getParameter("especieDesp_" + i));
                        pedidoDespesa.getDespesa().setSerie(request.getParameter("serie_" + i));
                        pedidoDespesa.getDespesa().setNfiscal(request.getParameter("notaFiscal_" + i));
                        pedidoDespesa.getDespesa().setDtEmissao(Apoio.getFormatData(request.getParameter("dtDespesa_" + i)));
                        pedidoDespesa.getDespesa().setDtEntrada(Apoio.getFormatData(request.getParameter("dtDespesa_" + i)));
                        pedidoDespesa.getDespesa().setCompetencia(request.getParameter("dtDespesa_" + i).substring(3, 10));
                        pedidoDespesa.getDespesa().getFornecedor().setIdfornecedor(Apoio.parseInt(request.getParameter("idFornecedor_" + i)));
                        pedidoDespesa.getDespesa().getHistorico().setIdHistorico(Apoio.parseInt(request.getParameter("idHistorico_" + i)));
                        pedidoDespesa.getDespesa().setDescHistorico(request.getParameter("historico_" + i));
                        pedidoDespesa.getDespesa().setValor(Apoio.parseDouble(request.getParameter("valorDespesa_" + i)));
                        pedidoDespesa.getDespesa().setUsuarioLancamento(Apoio.getUsuario(request));
                        BeanDuplDespesa[] du = new BeanDuplDespesa[1];
                        du[0] = new BeanDuplDespesa();
                        du[0].setDtvenc(Apoio.getFormatData(request.getParameter("dtVencimento_" + i)));
                        du[0].setVlduplicata(pedidoDespesa.getDespesa().getValor());
                        //Caso o lançamento seja a vista
                        if (pedidoDespesa.getDespesa().isAVista()) {
                            du[0].setBaixado(true);
                            du[0].setVlacrescimo(0);
                            du[0].setVldesconto(0);
                            du[0].getFpag().setIdFPag(Apoio.parseBoolean(request.getParameter("isCheque_" + i)) ? 3 : 1);// se não for cheque será não especificado
                            du[0].setVlpago(pedidoDespesa.getDespesa().getValor());
                            du[0].setDtpago(pedidoDespesa.getDespesa().getDtEmissao());
                            //movimentacao bancaria
                            du[0].getMovBanco().setConciliado(false);
                            du[0].getMovBanco().getConta().setIdConta(Apoio.parseInt(request.getParameter("contaDesp_" + i)));
                            du[0].getMovBanco().setValor(Apoio.parseFloat(request.getParameter("valorDespesa_" + i)));
                            du[0].getMovBanco().setDtEntrada(pedidoDespesa.getDespesa().getDtEmissao());
                            du[0].getMovBanco().setDtEmissao(pedidoDespesa.getDespesa().getDtEmissao());
                            du[0].getMovBanco().setHistorico_id(pedidoDespesa.getDespesa().getHistorico());
                            du[0].getMovBanco().setHistorico(pedidoDespesa.getDespesa().getHistorico().getDescHistorico());
                            du[0].getMovBanco().setCheque(Apoio.parseBoolean(request.getParameter("isCheque_" + i)));

                            if (cfg.isControlarTalonario() && du[0].getMovBanco().isCheque()) {
                                du[0].getMovBanco().setDocum(request.getParameter("documDesp2_" + i));
                            } else {
                                du[0].getMovBanco().setDocum(request.getParameter("documDesp_" + i));
                            }
                            du[0].getMovBanco().setNominal("");
                        }
                        pedidoDespesa.getDespesa().setDuplicatas(du);

                        //plano  de custo
                        int qtdApp = Apoio.parseInt(request.getParameter("maxPlano_" + i));
                        BeanApropDespesa[] ap = new BeanApropDespesa[qtdApp];
                        int j = 0; //Não posso utilizar o y pois o array do jsp não está na ordem correta da despesa.
                        for (int y = 1; y <= qtdApp; ++y) {
                            if (request.getParameter("idApropriacao_" + i + "_" + y) != null) {
                                ap[j] = new BeanApropDespesa();
                                ap[j].getPlanocusto().setIdconta(Apoio.parseInt(request.getParameter("idApropriacao_" + i + "_" + y)));
                                ap[j].setFilial(pedidoDespesa.getDespesa().getFilial());
                                ap[j].getVeiculo().setIdveiculo(Apoio.parseInt(request.getParameter("idVeiculoAprop_" + i + "_" + y)));
                                ap[j].getUndCusto().setId(Apoio.parseInt(request.getParameter("idUndAprop_" + i + "_" + y)));
                                ap[j].setValor(Apoio.parseDouble(request.getParameter("valorAprop_" + i + "_" + y)));
                                j++;
                            }
                        }
                        pedidoDespesa.getDespesa().setApropriacoes(ap);
                        //fim plano de custo

                        col.getDespesas().add(pedidoDespesa);


                    }
                }

                //col.setPedidoCobranca(request.getParameter("pedidosCob"));
                col.setPedidoCobranca(pd);
                //col.setCobranca(Boolean.parseBoolean(request.getParameter("is_cobranca")));
                col.setCobranca(request.getParameter("chk_coleta_cobranca") != null ? true : false);
                col.setValorFrete(Apoio.parseDouble(request.getParameter("valorFrete")));
                col.setValorAdiantamento(Apoio.parseDouble(request.getParameter("valorAdiantamento")));
                col.setValorSaldo(Apoio.parseDouble(request.getParameter("valorSaldo")));
                col.setHorarioAtendimento(request.getParameter("horario_atendimento"));
                col.getOrcamento().setId(Apoio.parseInt(request.getParameter("orcamento_id")));
                if(Apoio.parseBoolean(request.getParameter("chk_carta_automatica_coleta"))){
                    col.setValorFrete(Apoio.parseDouble(request.getParameter("cartaLiquido")));
                    col.setValorAdiantamento(Apoio.parseDouble(request.getParameter("cartaValorAdiantamento")));
                    col.setValorSaldo(Apoio.parseDouble(request.getParameter("cartaValorSaldo")));
                }
                
                col.setChegadaEm(Apoio.paraDate(request.getParameter("dtChegada")));
                col.setChegadaAs(request.getParameter("hrChegada"));
                col.setEntregaEm(Apoio.paraDate(request.getParameter("dtSaida")));
                col.setEntregaAs(request.getParameter("hrSaida"));

                //col.setCancelado(Boolean.parseBoolean(request.getParameter("cancelada")));
                col.setCancelado(request.getParameter("cancelada") != null ? true : false);

                col.setMotivoCancelamento(URLDecoder.decode(request.getParameter("motivo"), "UTF-8"));

                col.getTransportador().setIdcliente(request.getParameter("idtransportador") == null ? 0 : Integer.parseInt(request.getParameter("idtransportador")));

                col.setValorRateioDiaria(Apoio.parseFloat(request.getParameter("diaria")));
                col.setValorRateioAjudante(Apoio.parseFloat(request.getParameter("diariaajud")));

                col.setTaxaRoubo(Apoio.parseFloat(request.getParameter("taxa_roubo")));
                col.setTaxaRouboUrbano(Apoio.parseFloat(request.getParameter("taxa_roubo_urbano")));
                col.setTaxaTombamento(Apoio.parseFloat(request.getParameter("taxa_tombamento")));
                col.setTaxaTombamentoUrbano(Apoio.parseFloat(request.getParameter("taxa_tombamento_urbanform2idClienteo")));

                if (request.getParameter("cidade_destino_id") != null && !request.getParameter("cidade_destino_id").equals("")) {
                    col.getCidadeDestino().setIdcidade(Apoio.parseInt(request.getParameter("cidade_destino_id")));
                }

                if (request.getParameter("previsao") != null) {
                    col.setPrevisaoEm(Apoio.paraDate(request.getParameter("previsao")));
                }
                if (request.getParameter("prog_data") != null && !request.getParameter("prog_data").equals("")) {
                    col.setColetaProgramaEm(Apoio.paraDate(request.getParameter("prog_data")));
                }
                if (request.getParameter("prog_hora") != null && !request.getParameter("prog_hora").equals("")) {
                    col.setColetaProgramadaAs(new SimpleDateFormat("HH:mm").parse(request.getParameter("prog_hora")));
                }

                col.setEnderecoEntrega(request.getParameter("endereco_entrega"));
                col.setBairroEntrega(request.getParameter("bairro_entrega"));
                
                    String cfgPermitirLancamentoOSAbertoVeiculo = request.getParameter("cfgPermitirLancamentoOSAbertoVeiculo");
                    int miliSegundos = Apoio.parseInt(request.getParameter("miliSegundos"));
                    int cidadeOrigem = Apoio.parseInt(request.getParameter("idcidadeorigem"));
                    boolean osAbertoVeiculo = Apoio.parseBoolean(request.getParameter("os_aberto_veiculo"));
                    String hashAutorizacao = "";
                    
                    if (cfgPermitirLancamentoOSAbertoVeiculo.equals("PS") && osAbertoVeiculo && miliSegundos > 0) {
                        hashAutorizacao = Apoio.gerarHash(miliSegundos, col.getVeiculo().getIdveiculo(), cidadeOrigem);
                    }
                    
                    col.setHashSupervisor(hashAutorizacao);
                    
                int indAjud = Apoio.parseInt(request.getParameter("indAjud"));
                BeanAjudanteColeta ajuds[] = new BeanAjudanteColeta[indAjud];
                BeanAjudanteColeta aj = null;
                int h1 = 0;
                for (int j = 1; j <= indAjud; j++) {
                    if (request.getParameter("idAjud" + j) != null) {
                        aj = new BeanAjudanteColeta();
                        aj.getAjudante().setIdfornecedor(Apoio.parseInt(request.getParameter("idAjud" + j)));
                        aj.setValor(Apoio.parseFloat(request.getParameter("ajudVl" + j)));
                        ajuds[h1] = aj;
                        h1++;
                    }
                }
                col.setAjudantes(ajuds);

                //Cidades de destino
                int indCid = Apoio.parseInt(request.getParameter("idxCid"));
                BeanCidadesColeta cids[] = new BeanCidadesColeta[indCid];
                BeanCidadesColeta cid = null;
                int jx = 0;
                for (int j = 1; j <= indCid; j++) {
                    if (request.getParameter("cidadeDestinoId_" + j) != null) {
                        cid = new BeanCidadesColeta();
                        cid.getCidade().setIdcidade(Apoio.parseInt(request.getParameter("cidadeDestinoId_" + j)));
                        cid.getColeta().setId(Apoio.parseInt(request.getParameter("idcoleta")));
                        cid.setId(Apoio.parseInt(request.getParameter("pdId_"+j)));
                        cids[jx] = cid;
                        jx++;
                    }
                }
                col.setCidadesDestino(cids);

                int idxOco = Apoio.parseInt(request.getParameter("idxOco"));
                Ocorrencia ocos[] = new Ocorrencia[idxOco];
                Ocorrencia oco = null;
                int h2 = 0;
                for (int j = 1; j <= idxOco; j++) {
                    if (request.getParameter("ocorrenciaId_" + j) != null) {
                        oco = new Ocorrencia();
                        oco.getOcorrencia().setId(Apoio.parseInt(request.getParameter("ocorrenciaId_" + j)));
                        //oco.getColeta().setId(col.getId());
                        oco.setId(Apoio.parseInt(request.getParameter("idCol_" + j)));
                        oco.getUsuarioOcorrencia().setIdusuario(Apoio.getUsuario(request).getIdusuario());
                        oco.setOcorrenciaEm(Apoio.paraDate(request.getParameter("ocorrenciaEmCol_" + j)));
                        oco.setOcorrenciaAs(Apoio.paraHora(request.getParameter("ocorrenciaAsCol_" + j)));
                        oco.setObservacaoOcorrencia(request.getParameter("obsOcorrenciaCol_" + j));
                        oco.getProduto().setId(Apoio.parseInt(request.getParameter("ocoIdProduto_" + j)));
                        oco.setQuantidade(Apoio.parseDouble(request.getParameter("quantidadeOcorrencia"+j)));
                        oco.getNotaFiscal().setIdnotafiscal(Apoio.parseInt(request.getParameter("idNotaFiscalOcorrencia"+j)));
                        oco.getNotaFiscal().setNumero(request.getParameter("numeroNotaFiscalOcorrencia"+j));
                        ocos[h2] = oco;
                        h2++;
                    }
                }
                
                col.setOcorrencias(ocos);
                
                int qtdNotas = Apoio.parseInt(request.getParameter("objCountIdxNotes"));
                NotaFiscal arNf[] = new NotaFiscal[qtdNotas + 1];
                NotaFiscal nf;
                ItemNotaFiscal itemnf;
                Cubagem cubnf;
                int cole = col.getId();
                int h = 0;
                String sufix = "";
                for (int j = 1; j <= qtdNotas; ++j) {
                    if (request.getParameter("nf_numero" + j + "_id" + cole) != null) {

                        nf = new NotaFiscal();
                        nf.setIdnotafiscal(Apoio.parseInt(request.getParameter("nf_idnota_fiscal" + j + "_id" + cole)));
                        nf.setNumero(request.getParameter("nf_numero" + j + "_id" + cole));
                        nf.setSerie(request.getParameter("nf_serie" + j + "_id" + cole));
                        nf.setEmissao(Apoio.paraDate(request.getParameter("nf_emissao" + j + "_id" + cole)));
                        nf.setValor(Apoio.parseDouble(request.getParameter("nf_valor" + j + "_id" + cole).replaceAll(",", ".")));
                        nf.setVl_base_icms(Apoio.parseFloat(request.getParameter("nf_base_icms" + j + "_id" + cole).replaceAll(",", ".")));
                        nf.setVl_icms(request.getParameter("nf_icms" + j + "_id" + cole).trim().equals("") ? 0 : Float.parseFloat(request.getParameter("nf_icms" + j + "_id" + cole).replaceAll(",", ".")));
                        nf.setVl_icms_frete(request.getParameter("nf_icms_frete" + j + "_id" + cole).trim().equals("") ? 0 : Float.parseFloat(request.getParameter("nf_icms_frete" + j + "_id" + cole).replaceAll(",", ".")));
                        nf.setVl_icms_st(request.getParameter("nf_icms_st" + j + "_id" + cole).trim().equals("") ? 0 : Float.parseFloat(request.getParameter("nf_icms_st" + j + "_id" + cole).replaceAll(",", ".")));
                        nf.setPeso(Apoio.parseDouble(request.getParameter("nf_peso" + j + "_id" + cole).replaceAll(",", ".")));
                        nf.setVolume(Apoio.parseFloat(request.getParameter("nf_volume" + j + "_id" + cole).replaceAll(",", ".")));
                        nf.setEmbalagem(request.getParameter("nf_embalagem" + j + "_id" + cole));
                        nf.setConteudo(request.getParameter("nf_conteudo" + j + "_id" + cole));
                        nf.setPedido(request.getParameter("nf_pedido" + j + "_id" + cole));
                        nf.setLargura(Apoio.parseFloat(request.getParameter("nf_largura" + j + "_id" + cole).replaceAll(",", ".")));
                        nf.setAltura(Apoio.parseFloat(request.getParameter("nf_altura" + j + "_id" + cole).replaceAll(",", ".")));
                        nf.setComprimento(Apoio.parseFloat(request.getParameter("nf_comprimento" + j + "_id" + cole).replaceAll(",", ".")));
                        nf.setMetroCubico(Apoio.parseFloat(request.getParameter("nf_metroCubico" + j + "_id" + cole).replaceAll(",", ".")));
                        nf.getMarcaVeiculo().setIdmarca(Apoio.parseInt(request.getParameter("nf_id_marca_veiculo" + j + "_id" + cole)));
                        nf.setModeloVeiculo(request.getParameter("nf_modelo_veiculo" + j + "_id" + cole));
                        nf.setAnoVeiculo(request.getParameter("nf_ano_veiculo" + j + "_id" + cole));
                        nf.setCorVeiculo(Apoio.parseInt(request.getParameter("nf_cor_veiculo" + j + "_id" + cole)));
                        nf.setChassiVeiculo(request.getParameter("nf_chassi_veiculo" + j + "_id" + cole));

                        //novos campos
                        nf.setAgendado(new Boolean(request.getParameter("nf_is_agendado" + j + "_id" + cole)));
                        nf.setDataAgenda(Apoio.paraDate(request.getParameter("nf_data_agenda" + j + "_id" + cole)));
                        nf.setHoraAgenda(request.getParameter("nf_hora_agenda" + j + "_id" + cole));
                        nf.setObservacaoAgenda(request.getParameter("nf_obs_agenda" + j + "_id" + cole));

                        nf.getCfop().setIdcfop(request.getParameter("nf_cfopId" + j + "_id" + cole).trim().equals("") ? 0 : Integer.parseInt(request.getParameter("nf_cfopId" + j + "_id" + cole)));
                        //nf.getCfop().setCfop(request.getParameter("nf_cfop" + j + "_id" + cole));
                        nf.setChaveNFe(request.getParameter("nf_chave_nf" + j + "_id" + cole));
                        nf.setPrevisaoEm(Apoio.paraDate(request.getParameter("nf_previsao_entrega" + j + "_id" + cole)));
                        nf.setPrevisaoAs(request.getParameter("nf_previsao_as" + j + "_id" + cole));
                        nf.getDestinatario().setIdcliente(Integer.parseInt(request.getParameter("nf_id_destinatario" + j + "_id" + cole)));
                        if(col.getDestinatario().getIdcliente() != 0){
                                nf.setDestinatario(col.getDestinatario());
                        }
                        nf.getCriadoPor().setIdusuario(Apoio.getUsuario(request).getIdusuario());
                        nf.getAlteradoPor().setIdusuario(Apoio.getUsuario(request).getIdusuario());
                        nf.setTipoDocumento(request.getParameter("nf_tipoDocumento" + j + "_id" + cole));

                        sufix = j + "_id" + cole;

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
                                int idProdutoNota = Apoio.parseInt(request.getParameter("produtoId"+ sufix + s));
                                if(idProdutoNota > 0){//Caso o usuário tenha usado o localizar produto e seleciona algum produto.
                                    itemnf.getProduto().setId(idProdutoNota);
                                }
                                itemnf.setBasePaletizacao(Apoio.parseInt(request.getParameter("basePallet"+ sufix + s)));
                                itemnf.setAlturaPaletizacao(Apoio.parseInt(request.getParameter("alturaPallet"+ sufix + s)));
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

                        arNf[h] = nf;
                        h++;
                    }
                }
                    
                col.setNotaFiscal(arNf);
               //-------------------------- Carregando os dados da contrato de Frete ----
                
                col.getContratoFrete().setRetencaoImpostoOperadoraCFe(Apoio.parseBoolean(request.getParameter("is_retencao_impostos_operadora_cfe")));
                col.getContratoFrete().setData(Apoio.paraDate(Apoio.getDataAtual()));
                col.getContratoFrete().setVldependentes(0);
                col.getContratoFrete().setVlbaseir(Apoio.parseFloat(request.getParameter("baseIR")));
                col.getContratoFrete().setAliqir(Apoio.parseFloat(request.getParameter("aliqIR")));
                col.getContratoFrete().setVlir(Apoio.parseFloat(request.getParameter("valorIR")));
                col.getContratoFrete().setVlJaRetido(Apoio.parseFloat(request.getParameter("inss_prop_retido")));
                col.getContratoFrete().setVlOutrasEmpresas(0);
                col.getContratoFrete().setVlbaseinss(Apoio.parseFloat(request.getParameter("baseINSS")));
                col.getContratoFrete().setAliqinss(Apoio.parseFloat(request.getParameter("aliqINSS")));
                col.getContratoFrete().setVlinss(Apoio.parseFloat(request.getParameter("valorINSS")));
                col.getContratoFrete().setBaseSestSenat(Apoio.parseFloat(request.getParameter("baseINSS")));
                col.getContratoFrete().setAliqsestsenat(Apoio.parseFloat(request.getParameter("aliqSEST")));
                col.getContratoFrete().setVlsestsenat(Apoio.parseFloat(request.getParameter("valorSEST")));
                col.getContratoFrete().setVlAvaria(0);
                col.getContratoFrete().setVlFreteMotorista(Apoio.parseFloat(request.getParameter("cartaValorFrete")));
                col.getContratoFrete().setOutrosdescontos(Apoio.parseFloat(request.getParameter("cartaOutros")));
                col.getContratoFrete().setObsoutrosdescontos("");
                if (!col.getContratoFrete().isRetencaoImpostoOperadoraCFe()) {
                    col.getContratoFrete().setReterImpostos(request.getParameter("chk_reter_impostos") != null ? true : false);
                } else {
                    col.getContratoFrete().setReterImpostos(false);
                }
                col.getContratoFrete().setVlImpostos(Apoio.parseFloat(request.getParameter("cartaImpostos")));
                col.getContratoFrete().setValorPedagio(Apoio.parseDouble(request.getParameter("cartaPedagio")));
                col.getContratoFrete().setVlLiquido(Apoio.parseFloat(request.getParameter("cartaLiquido")));
                col.getContratoFrete().setVlOutrasDeducoes(Apoio.parseFloat(request.getParameter("cartaRetencoes")));
                col.getContratoFrete().getFilial().setIdfilial(Apoio.parseInt(request.getParameter("idfilial")));
                col.getContratoFrete().getMotorista().setIdmotorista(Apoio.parseInt(request.getParameter("idmotorista")));
                col.getContratoFrete().getMotorista().setNome(request.getParameter("motor_nome"));
                col.getContratoFrete().getVeiculo().setIdveiculo(Apoio.parseInt(request.getParameter("idveiculo")));
                col.getContratoFrete().getContratado().setIdfornecedor(Apoio.parseInt(request.getParameter("idproprietarioveiculo")));
                col.getContratoFrete().getContratado().getPlanoCustoPadrao().setIdconta(Apoio.parseInt(request.getParameter("plano_proprietario")));
                col.getContratoFrete().getContratado().getUnidadeCusto().setId(Apoio.parseInt(request.getParameter("und_proprietario")));
                col.getContratoFrete().getCarreta().setIdveiculo(Apoio.parseInt(request.getParameter("idcarreta")));
                //-------------- Perguntar a Deivid ----------------------
                col.getContratoFrete().getRota().setId(Apoio.parseInt(request.getParameter("id_rota_viagem")));
                col.getContratoFrete().setObservacao(request.getParameter("obs_carta_frete"));

                col.getContratoFrete().setValorAbastecimento(Apoio.parseDouble(request.getParameter("abastecimentos")));

                if (request.getParameter("ids_abastecimentos") != null) {
                    for (String abastecimentoId : StringUtils.split(request.getParameter("ids_abastecimentos"), ",")) {
                        int id = Apoio.parseInt(abastecimentoId);

                        col.getContratoFrete().getAbastecimentoIds().add(id);
                    }
                }

                BeanPagamentoCartaFrete[] arrayPagtoCarta = null;

                if (request.getParameter("cartaValorCC") != null && Apoio.parseDouble(request.getParameter("cartaValorCC")) > 0) {
                    arrayPagtoCarta = new BeanPagamentoCartaFrete[3];
                } else {
                    arrayPagtoCarta = new BeanPagamentoCartaFrete[2];
                }

                //Dados do adiantamento
                BeanPagamentoCartaFrete pgCarta = new BeanPagamentoCartaFrete();
                pgCarta.setId(0);
                pgCarta.setTipoPagamento("a");
                pgCarta.setValor(Apoio.parseFloat(request.getParameter("cartaValorAdiantamento")));
                pgCarta.setData(Apoio.paraDate(request.getParameter("cartaDataAdiantamento")));
                pgCarta.getFpag().setIdFPag(Apoio.parseInt(request.getParameter("cartaFPagAdiantamento")));
                pgCarta.setDocumento(request.getParameter(cfg.isControlarTalonario() ? "cartaDocAdiantamento_cb" : "cartaDocAdiantamento"));
                pgCarta.getAgente().setIdfornecedor(Apoio.parseInt(request.getParameter("idagente")));
                pgCarta.getAgente().getPlanoCustoPadrao().setIdconta(Apoio.parseInt(request.getParameter("plano_agente")));
                pgCarta.getAgente().getUnidadeCusto().setId(Apoio.parseInt(request.getParameter("und_agente")));
                pgCarta.setPercAbastecimento(0);
                pgCarta.getDespesa().setIdmovimento(0);
                pgCarta.setBaixado(false);
                if (request.getParameter("contaAdt") != null && !request.getParameter("contaAdt").equals("")) {
                    pgCarta.getConta().setIdConta(Apoio.parseInt(request.getParameter("contaAdt")));
                }
                pgCarta.setSaldoAutorizado(false);
                pgCarta.setTipoFavorecido("m");
                pgCarta.setContaBancaria("");
                pgCarta.setAgenciaBancaria("");
                pgCarta.setFavorecido("");
                pgCarta.getBanco().setIdBanco(1);

                arrayPagtoCarta[0] = pgCarta;

                //Dados do saldo
                pgCarta = new BeanPagamentoCartaFrete();
                pgCarta.setId(0);
                pgCarta.setTipoPagamento("s");
                pgCarta.setValor(Apoio.parseFloat(request.getParameter("cartaValorSaldo")));
                pgCarta.setData(Apoio.paraDate(request.getParameter("cartaDataSaldo")));
                pgCarta.getFpag().setIdFPag(Apoio.parseInt(request.getParameter("cartaFPagSaldo")));
                pgCarta.setDocumento(request.getParameter("cartaDocSaldo"));
                pgCarta.getAgente().setIdfornecedor(Apoio.parseInt(request.getParameter("idagentesaldo")));
                pgCarta.getAgente().getPlanoCustoPadrao().setIdconta(Apoio.parseInt(request.getParameter("plano_agente_saldo")));
                pgCarta.getAgente().getUnidadeCusto().setId(Apoio.parseInt(request.getParameter("und_agente_saldo")));
                pgCarta.setPercAbastecimento(0);
                pgCarta.getDespesa().setIdmovimento(0);
                pgCarta.setBaixado(false);
                pgCarta.setSaldoAutorizado(false);
                pgCarta.setTipoFavorecido("m");
                pgCarta.setContaBancaria("");
                pgCarta.setAgenciaBancaria("");
                pgCarta.setFavorecido("");
                pgCarta.getBanco().setIdBanco(1);
                arrayPagtoCarta[1] = pgCarta;

                if (request.getParameter("cartaValorCC") != null && Apoio.parseDouble(request.getParameter("cartaValorCC")) > 0) {
                    pgCarta = new BeanPagamentoCartaFrete();
                    pgCarta.setId(0);
                    pgCarta.setTipoPagamento("a");
                    pgCarta.setValor(Apoio.parseDouble(request.getParameter("cartaValorCC")));
                    pgCarta.setData(Apoio.paraDate(request.getParameter("cartaDataCC")));
                    pgCarta.getFpag().setIdFPag(Apoio.parseInt(request.getParameter("cartaFPagCC")));
                    pgCarta.setDocumento("");
                    pgCarta.getAgente().setIdfornecedor(0);
                    pgCarta.getAgente().getPlanoCustoPadrao().setIdconta(0);
                    pgCarta.getAgente().getUnidadeCusto().setId(0);
                    pgCarta.setPercAbastecimento(0);
                    pgCarta.getDespesa().setIdmovimento(0);
                    pgCarta.setBaixado(false);
                    pgCarta.setConta(cfg.getContaAdiantamentoFornecedor());
                    pgCarta.setSaldoAutorizado(false);
                    pgCarta.setTipoFavorecido("m");
                    pgCarta.setContaBancaria("");
                    pgCarta.setAgenciaBancaria("");
                    pgCarta.setFavorecido("");
                    pgCarta.getBanco().setIdBanco(1);
                    pgCarta.setContaCorrente(true);
                    arrayPagtoCarta[2] = pgCarta;
                }

                col.getContratoFrete().setPagamento(arrayPagtoCarta);
                //-------------- Despesa de Viagens ------------
                int countDespesaCarta = Apoio.parseInt(request.getParameter("countDespesaCarta"));
                BeanDespesa[] dpArray = new BeanDespesa[countDespesaCarta];
                BeanDespesa dp;
                BeanApropDespesa[] ap;
                BeanDuplDespesa[] du;
                for (int kk = 1; kk <= countDespesaCarta; ++kk) {
                    
                    if (request.getParameter("vlDespCarta_" + kk) != null) {
                        dp = new BeanDespesa();
                        dp.getFilial().setIdfilial(Apoio.parseInt(request.getParameter("idfilial")));
                        dp.setAVista(request.getParameter("DespPago_" + kk) != null);
                        dp.getEspecie_().setEspecie("");
                        dp.setSerie("");
                        dp.setNfiscal(col.getNumero());
                        dp.setDtEmissao(Apoio.paraDate(request.getParameter("dtsolicitacao")));
                        dp.setDtEntrada(Apoio.paraDate(request.getParameter("dtsolicitacao")));
                        dp.setCompetencia(request.getParameter("dtsolicitacao").substring(3, 10));
                        dp.getFornecedor().setIdfornecedor(Apoio.parseInt(request.getParameter("idFornDespCarta_" + kk)));
                        dp.getHistorico().setIdHistorico(0);
                        dp.setDescHistorico("Pagamento de " + request.getParameter("planoDespCarta_" + kk) + " CONF. CTRC:" + col.getNumero());
                        dp.setValor(Apoio.parseFloat(request.getParameter("vlDespCarta_" + kk)));

                        //atribuindo as parcelas
                        du = new BeanDuplDespesa[1];
                        du[0] = new BeanDuplDespesa();
                        du[0].setDtvenc(Apoio.paraDate(request.getParameter("vlDespVencimento_" + kk)));
                        du[0].setVlduplicata(Apoio.parseFloat(request.getParameter("vlDespCarta_" + kk)));
                        if (dp.isAVista()) {
                            du[0].setBaixado(true);
                            du[0].setNumeroBoleto("");
                            du[0].setValorPis(0);
                            du[0].setValorCofins(0);
                            du[0].setValorCssl(0);
                            du[0].getFpag().setIdFPag(request.getParameter("chqDespCarta_" + kk) == null ? 1 : 3);
                            du[0].setVlacrescimo(0);
                            du[0].setVlpago(Apoio.parseFloat(request.getParameter("vlDespCarta_" + kk)));
                            du[0].setCriaPcs(false);
                            du[0].setVldesconto(0);
                            du[0].setDtpago(Apoio.paraDate(request.getParameter("dtsolicitacao")));
                            //Movimentacao bancária
                            du[0].getMovBanco().getConta().setIdConta(Apoio.parseInt(request.getParameter("contaDespCarta_" + kk)));
                            du[0].getMovBanco().setValor(Apoio.parseFloat(request.getParameter("vlDespCarta_" + kk)));
                            du[0].getMovBanco().setDtEntrada(Apoio.paraDate(request.getParameter("dtsolicitacao")));
                            du[0].getMovBanco().setDtEmissao(Apoio.paraDate(request.getParameter("dtsolicitacao")));
                            du[0].getMovBanco().setConciliado(false);
                            du[0].getMovBanco().setHistorico(dp.getDescHistorico());
                            if (cfg.isControlarTalonario() && du[0].getFpag().getIdFPag() == 3) {
                                du[0].getMovBanco().setDocum(request.getParameter("docDespCarta_cb_" + kk));
                            } else {
                                du[0].getMovBanco().setDocum(request.getParameter("docDespCarta_" + kk));
                            }
                            du[0].getMovBanco().setNominal("");
                            du[0].getMovBanco().getHistorico_id().setIdHistorico(0);
                            du[0].getMovBanco().setCheque(du[0].getFpag().getIdFPag() == 3);
                        }
                        dp.setDuplicatas(du);

                        //atribuindo as apropriacoes
                        ap = new BeanApropDespesa[1];
                        ap[0] = new BeanApropDespesa();
                        ap[0].getPlanocusto().setIdconta(Apoio.parseInt(request.getParameter("idPlanoDespCarta_" + kk)));
                        ap[0].getFilial().setIdfilial(Apoio.parseInt(request.getParameter("idfilial")));
                        ap[0].getVeiculo().setIdveiculo(0);
                        ap[0].getUndCusto().setId(0);
                        ap[0].setValor(Apoio.parseFloat(request.getParameter("vlDespCarta_" + kk)));
                        dp.setApropriacoes(ap);
                        
                        dpArray[kk -1] = dp;
                    }
                }
                
                col.getContratoFrete().setDespesa(dpArray);
                
                //CarrString sufix = j + "_id0";egando os serviços
                int qtdServ = Apoio.parseInt(request.getParameter("qtdServ"));
                BeanVendaServico serv[] = new BeanVendaServico[qtdServ];
                for (int i = 1; i < qtdServ; ++i) {
                    if (request.getParameter("id" + i) != null) {
                        BeanVendaServico vs = new BeanVendaServico();
                        vs.setId(Apoio.parseInt(request.getParameter("id" + i)));
                        vs.getTipo_servico().setId(Apoio.parseInt(request.getParameter("id_servico" + i)));
                        vs.setQtdDias(Apoio.parseInt(request.getParameter("qtdDias_" + i)));
                        vs.setQuantidade(Apoio.parseFloat(request.getParameter("qtd" + i)));
                        vs.setValor(Apoio.parseDouble(request.getParameter("vl_unitario" + i)));
                        vs.setIss(Apoio.parseDouble(request.getParameter("perc_iss" + i)));
                        vs.getTributacao().setId(Apoio.parseInt(request.getParameter("trib" + i)));
                        vs.getNotaFiscal().setIdnotafiscal(Apoio.parseInt(request.getParameter("notaServico" + i)));
                        vs.setEmbutirISS(request.getParameter("embutirISS_" + i) == null ? false : true);
                        serv[i] = vs;
                    }
                }
                col.setServicos(serv);

                MovimentacaoPallets pallets = null;
                int max = Integer.parseInt(request.getParameter("max"));

                int mp = 0;
                for (int m = 1; m <= max; m++) {
                    pallets = new MovimentacaoPallets();
                    if (request.getParameter("nota_" + m) != "0" && request.getParameter("data_" + m) != "" && request.getParameter("pallet_" + m) != "" && request.getParameter("idpallet_" + m) != "0" && request.getParameter("quantidade_" + m) != "") {
                        pallets.setId(Apoio.parseInt(request.getParameter("idItem_" + m)));
                        pallets.getCliente().setIdcliente(Apoio.parseInt(request.getParameter("idcliente_" + m)));
                        pallets.setNota(Apoio.parseInt(request.getParameter("nota_" + m).equals("") ? "0" : request.getParameter("nota_" + m)));
                        pallets.setTipo(request.getParameter("tipo_" + m));


                        if (pallets.getTipo().equals("c")) {
                            pallets.setQuantidade(Apoio.parseInt(request.getParameter("quantidade_" + m)));
                        } else {
                            int qt = Apoio.parseInt(request.getParameter("quantidade_" + m));

                            int t = qt * -1;
                            pallets.setQuantidade(t);
                        }

                        pallets.getPallet().setId(Apoio.parseInt(request.getParameter("idpallet_" + m)));
                        pallets.setData(Apoio.getFormatData(request.getParameter("data_" + m)));


                        //adicionando a lista
                        col.getItens().add(pallets);
                    }
                }
            }
            
            if (request.getParameter("resp_coleta") != null && !request.getParameter("resp_coleta").isEmpty()) {
                col.getRepresentante().setId(Apoio.parseInt(request.getParameter("resp_coleta").split("#@#")[1]));
            }
            
            cadcol.setColeta(col);
            cadcol.setExecutor(Apoio.getUsuario(request));
         
            boolean erro = false;
            if (acao.equals("atualizar")) {
                erro = !cadcol.Atualiza(Apoio.getConfiguracao(request));
            } else if (acao.equals("incluir") && nivelUser >= 3) {
                //cadcol.setGambiRequest(request);
                erro = !cadcol.Inclui(Apoio.parseBoolean(request.getParameter("chk_carta_automatica_coleta")), Apoio.getConfiguracao(request));
            } else if (acao.equals("excluir") && nivelUser >= 4) {
                col.setId(Apoio.parseInt(request.getParameter("idcoleta")));
                cadcol.setColeta(col);
                erro = !cadcol.Deleta();
                
            }

            String scr = "";
            //if (!acao.equals("excluir")) {
            if (erro) {
                if (cadcol.getErros().indexOf("un_coleta_idfilial_numcoleta_ano") > 0) {
                    String suggestId = cadcol.getProximaColeta(cadcol.getColeta().getFilial().getIdfilial(), Integer.parseInt(Apoio.getDataAtual().substring(6)));

                    //scr += "<script>alert(" + suggestId + ");";
                    scr += "<script>";
                    scr += "if (confirm('A coleta " + cadcol.getColeta().getNumero() + " já existe. Deseja que o sistema crie com o número " + suggestId + "?')) "
                            + "{ "
                            + "window.opener.document.getElementById('numcoleta').value = '" + suggestId + "';"
                            + //"alert(window.opener.document.getElementById('numcoleta').value);" +
                            "window.opener.document.getElementById('salva').onclick(); "
                            + " }else{"
                            + "window.close();"
                            + "window.opener.document.getElementById('salva').disabled = false;"
                            + "window.opener.document.getElementById('salva').value = 'Salvar';"
                            + "} "
                            + "</script>";
                } else if (cadcol.getErros().trim().equalsIgnoreCase("Um resultado foi retornado quando nenhum era esperado.")) {
                    scr = "<script>"
                        + "window.opener.document.location.replace('ConsultaControlador?codTela=24');"
                        + "window.close();"
                        + "</script>";

                } else if(cadcol.getErros().indexOf(" is still referenced from table cartafrete_manifesto") > 0){
                    scr += "<script>";
                    scr += "alert('Não é possível excluir a coleta, pois ela está vinculada a um Contrato de Frete!.');";
                    scr += "window.close();"
                            + "window.opener.document.getElementById('salva').disabled = false;"
                            + "window.opener.document.getElementById('salva').value = 'Salvar';"
                            + "</script>";
                } else if(cadcol.getErros().indexOf("coleta_autorizacao_liberacao_hash_fkey") > 0){
                    scr += "<script>";
                    scr += "alert('ATENÇÃO: A inclusão do veículo não foi liberada e existe OS em aberto para o mesmo. Para utilizá-lo é preciso da autorização do supervisor.');";
                    scr += "window.close();"
                            + "window.opener.document.getElementById('salva').disabled = false;"
                            + "window.opener.document.getElementById('salva').value = 'Salvar';"
                            + "</script>";
                } else if(cadcol.getErros().indexOf("fk_nota_fiscal_remcliente") > 0){
                     scr += "<script>";
                    scr += "alert('ATENÇÃO: Ao cadastrar uma Nota Fiscal é obrigatório que o remetente esteja cadastrado!');";
                    scr += "window.close();"
                            + "window.opener.document.getElementById('salva').disabled = false;"
                            + "window.opener.document.getElementById('salva').value = 'Salvar';"
                            + "</script>";
                }else{
                    scr += "<script>";
                    scr += "alert('" + cadcol.getErros() + "');";
                    scr += "window.close();"
                            + "window.opener.document.getElementById('salva').disabled = false;"
                            + "window.opener.document.getElementById('salva').value = 'Salvar';"
                            + "</script>";
                }
                acao = (acao.equals("atualizar") ? "editar" : "iniciar");
            } else {
                scr = "<script>"
                        + "window.opener.document.location.replace('ConsultaControlador?codTela=24');"
                        + "window.close();"
                        + "</script>";
            }

            response.getWriter().append(scr);
            response.getWriter().close();
            //}


        }//acao de atualizar ou incluir
    } else {
        if (acao != null && acao.equals("localizarPesoContainer")) {
            String resposta = cadcol.retornaPesoContainer(Apoio.parseInt(request.getParameter("idContainer")));
            response.getWriter().println(resposta);
        }
    }

    String notas = "";
    if (col != null) {
        ResultSet rs3 = cadcol.allNotasColeta("idnota_fiscal, numero", Apoio.getUsuario(request).getConexao(), col.getId());

        while (rs3.next()) {
            notas += (notas.equals("") ? "" : "!!-") + rs3.getInt("idnota_fiscal") + ":.:" + rs3.getString("numero");
        }
        rs3.close();
    }
%>

<script language="javascript" type="text/javascript">
    //jQuery.noConflict();
    var countDespesa = 0 ;
    var countDespesaPlanoCusto = 0;
    var dataAtual = '<%= fmt.format(new Date())%>';
    var callMascaraReais = "mascara(this,reais);";
    
    var homePath = '${homePath}';
    
    function diminuirTotal(){
        $("totalNF").value = sumValorNotes('<%=col.getId()%>');
        $("totalVol").innerHTML = sumVolumeNotes('<%=col.getId()%>');
        $("totalPeso").value = sumPesoNotes('<%=col.getId()%>')
    }
    
    function removerNotaFiscalAjax(idNota){        
          tryRequestToServer(function(){
            new Ajax.Request("./cadcoleta.jsp?acao=excluirNotaColeta&idNota="+idNota,{
                method:'post', 
                onSuccess: ""
                ,
                onError: ""
            });
        });
                
    }
    //ajax de exclusão do ajudante
    function removerAjudanteAjax(indice){
        var idAjudante = $("idAjud"+indice).value;
        var idColeta = $("idcoleta").value;
        if (confirm("Deseja mesmo excluir o(s) ajudante(s) desta coleta?")){
          tryRequestToServer(function(){
            new Ajax.Request("./cadcoleta.jsp?acao=excluirAjudanteColeta&idAjudante="+idAjudante+"&idColeta="+idColeta,
                {
                    method:'get',
                    onSuccess: function(){
                        alert('Campo removido com sucesso!')
                        Element.remove($('trAjud'+indice));
                        $("indAjud").value--;
                    },
                    onFailure: function(){ alert('Something went wrong...') }
                });
            });
        }
    }
    
    function incluiNF(){
        addNewNote('<%=col.getId()%>','node_notes','true','<%=cfg.isBaixaEntregaNota()%>',$("tipoPadraoDocumento"));
        countIdxNotes++;
        getTipoColeta();
    }

    function getTipoColeta(){
        if (<%=acao.equals("iniciar")%>){
            if ($('numeroContainer').value.trim() == ''){
                $('tipoColeta').value = 'pr';
            }else{
                if (countIdxNotes == 0 ){
                    $('tipoColeta').value = 'co';
                }else{
                    $('tipoColeta').value = 'en';
                }
            }
        }
    }

    function localizaConsignatarioCodigo(campo, valor){
        function e(transport){
            var resp = transport.responseText;
            espereEnviar("",false);
            //se deu algum erro na requisicao...
            if (resp == 'null'){
                alert('Erro ao localizar cliente.');
                return false;
            }else if (resp == 'INA'){
                $('idconsignatario_con').value = '0';
                $('con_codigo_con').value = '';
                $('con_rzs_con').value = '';
                alert('Cliente inativo.');
                return false;
            }else if(resp == ''){
                $('idconsignatario_con').value = '0';
                $('con_codigo_con').value = '';
                $('con_rzs_con').value = '';

                if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")){
                    window.open('./cadcliente?acao=iniciar','Cliente','top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                }
                return false;
            }else{
                var cliControl = eval('('+resp+')');
                $('idconsignatario_con').value = cliControl.idcliente;
                $('con_codigo_con').value = cliControl.idcliente;
                $('con_cnpj_con').value = cliControl.cnpj;
                $('con_rzs_con').value = cliControl.razao;
                $("con_is_bloqueado").value = cliControl.is_bloqueado;
                $("mensagem_usuario_coleta").value = cliControl.mensagem_usuario_coleta;
                $("id_rota_viagem").value = cliControl.id_rota_viagem;
                if($("mensagem_usuario_coleta").value != null && $("mensagem_usuario_coleta").value != ""){
                    setTimeout(function(){alert("Mensagem importante para emissão de Coleta do cliente "+ $("con_rzs_con").value+": "+$("mensagem_usuario_coleta").value);
                    }
                            ),100
                }
                changeClientePagador("c");
            }
            
        }//funcao e()

        if (valor != ''){
            espereEnviar("",true);
            tryRequestToServer(function(){
                new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor="+valor+"&idfilial=0&campo="+campo,{method:'post', onSuccess: e, onError: e});
            });
        }
    }

    //indexacao da apropriacao
    var indexAjud = new Array();
    var indexCob = 0;
    var countIdxNotes = 0;


    function localizaconsignatario(){
        windowConsignatario = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=<%=BeanLocaliza.CONSIGNATARIO_DE_CONHECIMENTO%>','Consignatario',
        'top=80,left=70,height=500,width=700,resizable=yes,status=1,scrollbars=1');
    }
    //function salvar(acao){
    function salvar(){
        try{
            var valorSaldo = parseFloat($("valorSaldo").value);
            var valorAdiantamento = parseFloat($("valorAdiantamento").value);
            var valorFrete = parseFloat($("valorFrete").value);
            var totalSalAdia = valorSaldo + valorAdiantamento;
            var contratoOk = true;
            if (valorFrete!=  (roundABNT(valorAdiantamento + valorSaldo))){
                return alert("O valor do frete deve ser igual a soma do valor do saldo com o valor do adiantamento.");
            }

            if ($("cancelada").checked && ($("motivo").value).trim()==""){
                alert("Para que seja cancelada é necessário informar o motivo.");
                return null;
            }

            //obtendo notas devidamente concatenadas
                        var notes = getNotes("<%=col.getId()%>");
            if (notes == null)
                return null;
            if($("entregaContainerEm").value!=""){
                alertInvalidDate($("entregaContainerEm"));
            }
            
            
            if (<%=cfg.isUnidadeCustoObrigatoria()%>) {
                var err = null;
                jQuery.each(jQuery('[id^=idDepesa_]'), function(index, element){
                    var erro = true;
                    jQuery.each(jQuery('[id^=idUndAprop_'+(index+1)+'_]'), function(i, e) {
                        if (e.value && e.value != '0') {
                            erro = false;
                        }
                    });
                    if (erro) {
                        err = "Informe a unidade de custo corretamente nas apropriações!";
                        return;
                    }
                });

                if (err) {
                    alert(err);
                    return;
                }
            }
            
            if (wasNull("numcoleta,rem_rzs_cl,dtsolicitacao"))
                return alert("Preencha os campos corretamente!");
            else if (! validaData(getObj("dtsolicitacao").value))
                return alert("Data de solicitação incorreta. Formato correto: dd/MM/yyyy");
            else if (getObj("dtcoleta").value!='' && ! validaData(getObj("dtcoleta").value))
                return alert("Data da coleta incorreta. Formato correto: dd/MM/yyyy");
            else if (getObj("is_obriga_carreta").value =='t' && getObj("idcarreta").value=="0")
                return alert("É obrigado informar a carreta!");
            else if (getObj("dtcoleta").value!='' && wasNull("motor_nome,vei_placa")){
                return alert("Preencha os campos corretamente!");
            
            }else {
                //Caso o check do contrato de frete automático esteja marcado, o sistema validará os campos obrigatório do contrato.
                if($("chk_carta_automatica_coleta") != null && $("chk_carta_automatica_coleta").checked){
                     var erro = validarContratoFrete();
                     if(erro != ""){
                         alert(erro)
                         return false;
                     }
                }
                
                $("objCountIdxNotes").value = countIdxNotes;
                $("idxOco").value = idxOco;

                $("tipoveiculo").value = ($("tipoveiculo").value == '' ? '-1' : $("tipoveiculo").value);

                $("salva").disabled = true;
                $("salva").value = "Enviando...";

                $("tipotaxa").disabled = false;
                $("tipoveiculo").disabled = false;

                if (<%=!carregacol%>){
                    if ($("end_cli").value.trim() == $("rem_endereco").value.trim()){
                        //$("idcidadeorigem").value = "0";
                        //$("rem_bairro").value = "";
                        //$("rem_endereco").value= "";
                    }
                }
                
                window.open('about:blank', 'pop', 'width=210, height=100');
                $("formulario").action="./cadcoleta?"+getServ()+"&idxCid="+idxCid;
                $("formulario").submit();
            }
            
            //   A REGRA DE VALIDAÇÃO PARA O LOGIN DE SUPERVISOR, TRATA-SE DE VEÍCULOS QUE ESTEJAM NA OS, SENDO ASSIM NA ESCOLHA DO VEICULO
            //   QUANDO O VEÍCULO É CARREGADO SEJA PELO MOTORISTA OU PELO LOCALIZA DIRETAMENTE JÁ É FEITA A VALIDAÇÃO, 
            //   SENDO ASSIM, COMENTEI ESTA VALIDAÇÃO POIS CRIAVA UM ERRO NA TELA. O FOMULÁRIO ERA SALVO COM SUCESSOE E O POP-UP DE SERVIDOR CONTINUAVA ABERTO.
//            if(< %=carregacol%>){
//               var codigoIbge = '< %=(carregacol ? col.getDestinatario().getCidadeCol().getCod_ibge() : 0)%>';
//               validacaoAlterarLoginSupervisor(codigoIbge,$("codigo_ibge_origem").value);
//            }
            
        }catch(e){
            alert(e);
            
        }
    }

    
    function calcularPedagio(){
        if($("idcidadeorigem").value == 0){
            alert("Atenção: Não é possível calcular o Pedágio sem a cidade de origem!");
            return false;
        }
        if($("idcidadedestino").value == 0){
            alert("Atenção: Não é possível calcular o Pedágio sem a cidade de destino!");
            return false;
        }
        
        if($("stUtilizacaoCfe").value=="D"){
            
            
            var ibgeCidadeOrigem = $("codigo_ibge_origem").value;
            var ibgeCidadeDestino = $("codIbgeDestino").value;
            var maxCidades = $("maxCidades").value;
            var codcategoriaNddVeiculo= $("codcategoriaNddVeiculo").value;
            var codcategoriaNddCarreta= $("codcategoriaNddCarreta").value;
            var codCategoriaNdd = 0;
            if($("idcarreta").value == "0"){
                codCategoriaNdd = codcategoriaNddVeiculo;
                if(codCategoriaNdd == "null"){
                    alert("Atenção: Escolha um veículo com Categoria Ndd!");
                    return false;            
                }
            }else{
                codCategoriaNdd = codcategoriaNddCarreta;
                if(codCategoriaNdd == "null"){
                    alert("Atenção: Escolha uma carreta com Categoria Ndd!");
                    return false;            
                }
            }
            //validacao para origem e destino na mesma cidade e não tem ponto de parada não gera pedagio
            if (maxCidades == '1'){
                if ($("cidadeDestinoId_1").value == $("idcidadeorigem").value) {
                    alert("Origem e destino são iguais, não poderá gerar pedágio");
                    return false;
                }
            }
            
            var codCidades= "";
            //if(maxCidades>=1){              
                for(var i=1; i<=maxCidades; i++){
                   if ($("codDestino_"+i) != null) {
                       if($("codDestino_"+i).value != ibgeCidadeDestino){
                           codCidades+= ","+$("codDestino_"+i).value;
                       }
                   }
               }
               codCidades += ","+ibgeCidadeDestino;
            //}
            //codCidades += ","+ibgeCidadeDestino;
            var valorPedagio =""; 
            espereEnviar("Aguarde...",true);
            function e(transport){
                     var textoresposta = transport.responseText;
                     if (textoresposta == "-1") {
                        alert('Houve algum problema ao requistar o calculo do pedágio, favor tente novamente. ');
                        return false;
                     }else{                        
                        var nddPedagio =jQuery.parseJSON(textoresposta).nddPedagio;
                        if (nddPedagio.codigo != 164) {                           
                            alert(nddPedagio.mensagem);
                            espereEnviar("Aguarde...",false);
                            return false;
                        }
                        valorPedagio += colocarVirgula(nddPedagio.valor);
                        $("valorPedagio").value = valorPedagio;

                     }
                     espereEnviar("Aguarde...",false);
            }   
                 new Ajax.Request("NddControlador?acao=calcularPedagioNddColetaAjax&categoriaNdd=0&&nomeRota=&ibgeCidadeOrigem="+ibgeCidadeOrigem+"&ibgeCidadeDestino="+ibgeCidadeDestino+"&codigoCategoriaNdd="+codCategoriaNdd+"&maxCidades="+maxCidades+"&codCidades="+codCidades,{method:'post',onSuccess:e,onError: e});            
        }
    }
    
    
    
    function excluirItemNotaFiscalColeta(coleta,index){
        var linha = $("trItemNota_"+ index);
        var id = parseInt($("idItemNota_"+index).value,10);
        var descricao = ($("descricaoItemNota_"+ index) == null ? "" : $("descricaoItemNota_"+ index).value);
        if(confirm("Deseja excluir " + descricao +"?")){
            if(confirm("Tem certeza?")){
                if (id != 0) {
                    new Ajax.Request("ConhecimentoControlador?acao=excluirItemNota&rotina=cl&idItem="+id,{
                        method:'get',
                        onSuccess: function(){
                            alert(descricao + " foi excluido(a) com sucesso!"); 
                            Element.remove(linha);
                            calcMetro(coleta);
                            totalItensNota(coleta);
                        },
                        onFailure: function(){ alert('Erro ao excluir '+ descricao+ "!");return false }
                    });     
                 }else{
                    Element.remove(linha);
                    calcMetro(coleta);
                    totalItensNota(coleta);

                 }
            }
       }
    }

    function localizaProduto(idx){
        var idCliente = $("idremetente_cl").value;
        if (idCliente == "" || idCliente == "0"){
            return alert("Para adicionar o produto é antes é necessário informar o cliente.");
        }
       
        launchPopupLocate('./localiza?acao=consultar&idlista=50&paramaux='+idCliente,'Produto_'+idx);
    }

    //------------------------------------------ feito em 15/04/2010 -----------
    var idxOco = 0;
    function addOcorrencia(id, ocorrencia_id, ocorrencia, ocorrenciaEm, ocorrenciaAs, usuarioOcorrencia,
    observacaoOcorrencia, idProduto, descricaoProduto, codigoProduto, 
    idNotaFiscalOcorrencia,numeroNotaFiscalOcorrencia,quantidadeOcorrencia){
        idxOco++;

        var _tr = '';
        _tr = Builder.node('TR', {id:'trCol_'+idxOco, name:'trCol_'+idxOco, className:'CelulaZebra'+(idxOco % 2 ? 1 : 2)},
        
        [Builder.node('TD',
            [Builder.node('IMG', {src:'img/lixo.png', title:'Apagar ocorrência da coleta.', className:'imagemLink',
                    onClick:'removerOcorrencia('+idxOco+');'}),
                Builder.node('INPUT', {type:'hidden', name:'ocorrenciaId_'+idxOco, id:'ocorrenciaId_'+idxOco,
                    value:ocorrencia_id}),
                Builder.node('INPUT', {type:'hidden', name:'ocoIdProduto_'+idxOco, id:'ocoIdProduto_'+idxOco,
                    value:idProduto}),
                Builder.node('INPUT', {type:'hidden', name:'idCol_'+idxOco, id:'idCol_'+idxOco,
                    value:id})
            ]),
            Builder.node('TD',
            [Builder.node('LABEL', {name:'ocorrenciaCol_'+idxOco, id:'ocorrenciaCol_'+idxOco}),
            ]),
         
         Builder.node('TD',
            [Builder.node('INPUT', {type:'text', name:'ocorrenciaEmCol_'+idxOco, id:'ocorrenciaEmCol_'+idxOco,
                    value:ocorrenciaEm, className:'fieldMin', size:'12', maxLength:'10',
                    onBlur:'alertInvalidDate($(\'ocorrenciaEmCol_'+idxOco+'\'));',
                    onKeyDown:'fmtDate($(\'ocorrenciaEmCol_'+idxOco+'\') , event);',
                    onKeyUp:'fmtDate($(\'ocorrenciaEmCol_'+idxOco+'\') , event);',
                    onKeyPress:'fmtDate($(\'ocorrenciaEmCol_'+idxOco+'\') , event);'}),
                Builder.node('INPUT', {type:'text', name:'ocorrenciaAsCol_'+idxOco, id:'ocorrenciaAsCol_'+idxOco,
                    value:ocorrenciaAs, className:'fieldMin', size:'6', maxLength:'5'})
            ]),
           
           Builder.node('TD',
            [Builder.node('INPUT', {type:'text', name:'obsOcorrenciaCol_'+idxOco, id:'obsOcorrenciaCol_'+idxOco,
                    value:observacaoOcorrencia, className:'fieldMin', size:'37', maxLength:''})]),
           
           Builder.node('TD',
                [Builder.node('INPUT', {type:'text', name:'quantidadeOcorrencia'+idxOco, id:'quantidadeOcorrencia'+idxOco,
                    value:quantidadeOcorrencia, className:'fieldMin styleValor', size:'8', maxLength:'',onBlur: "seNaoFloatReset(this,'0')"})]),
                    
           Builder.node('TD',[
                Builder.node('input',{
                    type:'hidden',id:'idNotaFiscalOcorrencia'+idxOco,name:'idNotaFiscalOcorrencia'+idxOco
                    ,value:idNotaFiscalOcorrencia
                }),
                Builder.node('INPUT', {type:'text', name:'numeroNotaFiscalOcorrencia'+idxOco, id:'numeroNotaFiscalOcorrencia'+idxOco,
                    value:numeroNotaFiscalOcorrencia, className:'fieldMin', size:'12', maxLength:'12'
                    ,className:"inputReadOnly8pt2", readonly:"true"
                }),
                Builder.node('INPUT', {type:'button', name:'btnLocalizarNotaFiscalOcorrencaia'+idxOco, id:'btnLocalizarNotaFiscalOcorrencaia'+idxOco,
                    className:'botoes', value:"...",style:"margin-left:2px",
                    onClick:"localizarNotaFiscalOcorrencia("+ idxOco +")"
                })
                
            ]),
           
           Builder.node('TD',[   
                Builder.node('INPUT', {type:'button', name:'botaoProd_'+idxOco, id:'botaoProd_'+idxOco,
                    className:'botoes', value:"...",
                    onClick:"localizaProduto("+ idxOco +")"}),
                Builder.node('LABEL', {name:'ocoProdutoCol_'+idxOco, id:'ocoProdutoCol_'+idxOco})
            ])
        ]);

        $('corpoOcor').appendChild(_tr);

        //Atribuindo valores nas labels
        $('ocorrenciaCol_'+idxOco).innerHTML = ocorrencia;
    <%if (cfg.isGeraGEMColeta()) {%>
            $('ocoProdutoCol_'+idxOco).innerHTML = " " + codigoProduto + " " + descricaoProduto + " ";
            $('botaoProd_'+idxOco).style.display = "";
    <%} else {%>
            $('botaoProd_'+idxOco).style.display = "none";
    <%}%>

            //$('usuarioOcorrenciaCol_'+idxOco).innerHTML = usuarioOcorrencia;
            //$('usuarioResolucao_Ct'+ctrc+'idx'+idxOco).innerHTML = usuarioResolucao;
            /*
    if (isResolvido){
        $('isResolvido_Ct'+ctrc+'idx'+idxOco).checked = true;
        $('obsResolucao_Ct'+ctrc+'idx'+idxOco).readOnly = false;
        $('resolvidoEm_Ct'+ctrc+'idx'+idxOco).readOnly = false;
        $('resolvidoAs_Ct'+ctrc+'idx'+idxOco).readOnly = false;
    }else{
        $('isResolvido_Ct'+ctrc+'idx'+idxOco).checked = false;
        $('obsResolucao_Ct'+ctrc+'idx'+idxOco).readOnly = true;
        $('resolvidoEm_Ct'+ctrc+'idx'+idxOco).readOnly = true;
        $('resolvidoAs_Ct'+ctrc+'idx'+idxOco).readOnly = true;
    }
             *//*
    if (id != '0'){
        $('obsOcorrencia_Ct'+ctrc+'idx'+idxOco).readOnly = true;
        $('obsOcorrencia_Ct'+ctrc+'idx'+idxOco).style.backgroundColor = '#FFFFF1';
        $('ocorrenciaEm_Ct'+ctrc+'idx'+idxOco).readOnly = true;
        $('ocorrenciaEm_Ct'+ctrc+'idx'+idxOco).style.backgroundColor = '#FFFFF1';
        $('ocorrenciaAs_Ct'+ctrc+'idx'+idxOco).readOnly = true;
        $('ocorrenciaAs_Ct'+ctrc+'idx'+idxOco).style.backgroundColor = '#FFFFF1';
    }    */

            //idxOco++;

        }

        var indAjud = 0;
        function addAjudante(idAjud, nome, telefone, telefone2, valor) {
            indAjud++;
            var indice = 1;
            if (getObj("trAjud1") != null)
                indice = parseFloat(getObj("corpoAjud").lastChild.id.substring(6, 9)) + 1;
    
            var trLine = makeElement("TR", "class=CelulaZebra"+((indice % 2) == 0 ? 1 : 2)+"&id=trAjud"+indice);
            //criando Ajudante
            var inIdAjud = makeElement("INPUT", "type=hidden&id=idAjud"+indice+"&value="+idAjud);
            var tdNome = makeElement("TD", "id=tdAjud1" + indice + "&innerHTML="+nome);
            var tdFone1 = makeElement("TD", "id=tdAjud1" + indice + "&innerHTML="+telefone);
            var tdFone2 = makeElement("TD", "id=tdAjud1" + indice + "&innerHTML="+telefone2);
            trLine.appendChild(inIdAjud);
            trLine.appendChild(makeElement("TD",""));
            trLine.appendChild(tdNome);
            trLine.appendChild(tdFone1);
            trLine.appendChild(tdFone2);
            //criando campo valor
            var inValor = makeElement("INPUT", "id=ajudVl" + indice + "&type=TEXT&onchange=seNaoFloatReset(getObj('ajudVl"+indice+"'),'0.00')&"+
                "maxLength=10&size=7&class=inputtexto&value="+valor);
            trLine.appendChild(appendObj(makeElement("TD",""), inValor));
            //incluindo na lista o botao de excluir Ajudante
            trLine.appendChild(appendObj(makeElement("TD",""),
            makeElement("IMG","src=img/lixo.png&title=Excluir&class=imagemLink&onclick=removerAjudanteAjax('"+indice+"')")));
            getObj("corpoAjud").appendChild(trLine);
            //adicionando o indice no array(como o array começa em 0 subtraimos 1)
            indexAjud[indice - 1] = true;


            $("indAjud").value = indAjud;
        }
        //comentei pois criei uma função ajax de exclusão do ajudante
//        function delAjudante(indiceAjud) {
//            if (confirm("Deseja mesmo excluir este ajudante?"))
//                getObj("trAjud" + indiceAjud).parentNode.removeChild(getObj("trAjud" + indiceAjud));
//            //removendo o indice no array(como o array começa em 0 subtraimos 1)
//            indexAjud[indiceAjud - 1] = false;
//        }

        function concatAjud() {
            var ajud = "";
            for (i = 1; i <= indexAjud.length; ++i)
                if (indexAjud[i - 1] == true)
                    ajud += getObj("idAjud"+i).value+"N"+getObj("ajudVl"+i).value + (i == indexAjud.length? "" : "L");
            return escape(ajud);
        }

        // javascript não possui replaceall
        function replaceAll(string, token, newtoken) {
            while (string.indexOf(token) != -1) {
                string = string.replace(token, newtoken);
            }
            return string;
        }
        
        function validacaoAlterarLoginSupervisor(codigoIbgeCarregado, codigoIbgeLocaliza){
            if (codigoIbgeCarregado != codigoIbgeLocaliza) {
                abrirLoginSupervisor('<%=cfg.getPermitirLancamantoOSAbertoVeiculo()%>',<%=TipoAutorizacao.COLETA_VEICULO_MANUTECAO.ordinal()%>,$("idcidadeorigem").value,0);
            }
        }

        function aoClicarNoLocaliza(idjanela){
            var index1 = $("idPallet").value;
            var index2 = $("idCliente").value;
            var index = $("indexAux").value;
            var plano;
            var indexProduto = $("doomAuxiliar").value;
            //Nota Fiscal Ocorrência
            if(idjanela == "NotaFiscalOcorrencia"){
                var index = indexProduto;//Recuperando o index da ocorrência da coleta.
                $("idNotaFiscalOcorrencia"+index).value = $("idnota_fiscal").value;
                $("numeroNotaFiscalOcorrencia"+index).value = $("numero_nf").value;
            }
            //Produto Nota
            if(idjanela == "ProdutoNota"){
                //Localizar todos os elementos que tenham o nome do id passado por parâmetro.
                var idsProduto = document.getElementsByName("produtoId"+indexProduto);
                var basesP = document.getElementsByName("basePallet"+indexProduto);
                var alturasP = document.getElementsByName("alturaPallet"+indexProduto);
                //Dependendo de quantos tem o mesmo id ele vai setar
                for(var i = 0; i <= idsProduto.length;i++){
                    if(idsProduto[i] != null){
                        idsProduto[i].value = $("produto_id").value;
                        basesP[i].value = $("base_paletizacao").value;
                    }
                    if(basesP[i] != null){
                        basesP[i].value = $("base_paletizacao").value;
                    }
                    if(alturasP[i] != null){
                        alturasP[i].value = $("altura_paletizacao").value;
                    }
                }
                $("descricaoItemNota_"+ indexProduto).value = $("descricao_produto").value;
            }
            
            //Despesa Carta
            if (idjanela.substring(0,25) == 'Fornecedor_Contrato_Frete'){
	    var idxForn = idjanela.split('_')[3];
		$('idFornDespCarta_'+idxForn).value = $('idfornecedor').value;
		$('fornDespCarta_'+idxForn).value = $('fornecedor').value;
		$('idPlanoDespCarta_'+idxForn).value = $('idplcustopadrao').value;
		$('planoDespCarta_'+idxForn).value = $('contaplcusto').value + '-' + $('descricaoplcusto').value;
            }
            if (idjanela.substring(0,20) == 'Plano_Contrato_Frete'){
	    var idxPlano = idjanela.split('_')[3];
		$('idPlanoDespCarta_'+idxPlano).value = $('idplanocusto_despesa').value;
		$('planoDespCarta_'+idxPlano).value = $('plcusto_conta_despesa').value + '-' + $('plcusto_descricao_despesa').value;
            }
            
            
            if(idjanela == 'Fornecedor'){
                $('fornecedor_'+index).value = $('fornecedor').value;
                $('idFornecedor_'+index).value = $('idfornecedor').value;
                $('historico_'+index).value = $('descricao_historico').value;
                if($('idplcustopadrao').value != "0"){
                    plano = new ApropriacaoDespesa();
                    plano.idApropriacao = $('idplcustopadrao').value;
                    plano.conta = $('contaplcusto').value;
                    plano.apropriacao = $('descricaoplcusto').value;
                    plano.und = $('sigla_und_forn').value;
                    plano.idUnd = $('id_und_forn').value;
                    plano.veiculo = $("vei_placa").value;
                    plano.idVeiculo = $("idveiculo").value;
                    addPropriacao(index, plano);
                }
            }
            
            if(idjanela == 'Unidade_de_Custo'){
                $('undAprop_'+index).value = $('sigla_und').value;
                $('idUndAprop_'+index).value = $('id_und').value;
            }
            
            if(idjanela == 'Plano'){
                if(index.split("_")[1] == "undefined"){
                    plano = new ApropriacaoDespesa();
                    plano.idApropriacao = $("idplanocusto_despesa").value;
                    plano.conta = $("plcusto_conta_despesa").value;
                    plano.apropriacao = $("plcusto_descricao_despesa").value;
                    plano.veiculo = $("vei_placa").value;
                    plano.idVeiculo = $("idveiculo").value;
                    
                    addPropriacao(index.split("_")[0], plano);
                }else{
                    // alert(index)
                    $("conta_"+ index).value = $("plcusto_conta_despesa").value;
                    $("idApropriacao_"+ index).value = $("idplanocusto_despesa").value;
                    $("apropriacao_"+ index).value = $("plcusto_descricao_despesa").value;
                }
                
                
            }
            
            if(idjanela == 'Historico'){
                $('historico_'+index).value = $('descricao_historico').value;
                $('idHistorico_'+index).value = $('idhist').value;
            }
            
            if (idjanela == "Cliente") {
                $("idcliente_"+ index2).value  = $("idconsignatario").value;
                $("cliente_"+ index2).value  = $("con_rzs").value;
            }
            
            if (idjanela == "Consignatario") {
                $("idconsignatario_con").value  = $("idconsignatario").value;
                $("con_codigo_con").value  = $("con_codigo").value;
                $("con_cnpj_con").value  = $("con_cnpj").value;
                $("con_rzs_con").value  = $("con_rzs").value;
                if($("mensagem_usuario_coleta").value != null && $("mensagem_usuario_coleta").value != ""){
                    setTimeout(function(){alert("Mensagem importante para emissão de Coleta do cliente "+ $("con_rzs_con").value+": "+$("mensagem_usuario_coleta").value);
                    }
                            ),100
                }
                changeClientePagador("c");
            }


            if (idjanela == "Pallet") {
                $("idpallet_"+ index1).value  = $("id").value;
                $("pallet_"+ index1).value  = $("descricao").value;
            }
            
            function indiceJanela(initPos, finalPos) { return idjanela.substring(initPos, finalPos); }
            if (idjanela == "marca"){
                $('inIdMarcaVeiculo').value = $('idmarca').value;
                $('inMarcaVeiculo').value = $('descricao').value;
            }
            //localizando ocorrencias
            if (idjanela.indexOf("Ocorrencia_Coleta") > -1){
                addOcorrencia(0, $("ocorrencia_id").value,
                $("ocorrencia").value + '-' + $("descricao_ocorrencia").value,
                '<%=Apoio.getDataAtual()%>', '<%=new SimpleDateFormat("HH:mm").format(new Date())%>',
                '<%=Apoio.getUsuario(request).getLogin()%>','','0','','',0,'',0);
            }
            if (idjanela.indexOf("Ajudante") > -1){
                addAjudante(getObj("idajudante").value,getObj("nome").value,getObj("fone1").value,getObj("fone2").value,getObj("vldiaria").value);
            }else if (idjanela.indexOf("Destinatario") > -1){ //localizando destinatario
                $('iddestinatario_cl').value = $('iddestinatario').value;
//                $('idcidadedestino').value = $('iddestinatario').value;
                $('des_codigo_cl').value = $('des_codigo').value;
                $('dest_cnpj_cl').value = $('dest_cnpj').value;
                $('dest_rzs_cl').value = $('dest_rzs').value;
                $("uf_dest").value   = $("dest_uf").value;
                $("cidade_destino").value  = $("dest_cidade").value;
                $("endereco_entrega").value = $("dest_endereco").value;
                $("bairro_entrega").value = $("dest_bairro").value;
                $("codigo_ibge_destino").value = $("cod_ibge").value;
                if($("mensagem_usuario_coleta_des").value != null && $("mensagem_usuario_coleta_des").value != ""){
                    setTimeout(function(){alert("Mensagem importante para emissão de Coleta do cliente "+ $("dest_rzs_cl").value+": "+$("mensagem_usuario_coleta_des").value);
                    }
                            ),100
                }
                changeClientePagador("d");
                addCidadeDestino($("cidade_destino_id").value,$("dest_cidade").value,$("dest_uf").value, $("cod_ibge").value,'0');
            }else if (idjanela.indexOf("Cliente_Entrega") > -1){ //localizando destinatario entrega
                $('iddestinatario_entrega').value = $('iddestinatario').value;
                $('des_ent_codigo').value = $('des_codigo').value;
                $('dest_ent_cnpj').value = $('dest_cnpj').value;
                $('dest_ent_rzs').value = $('dest_rzs').value;
                $("uf_dest").value   = $("dest_uf").value;
                $("cidade_destino").value  = $("dest_cidade").value;
                $("endereco_entrega").value = $("dest_endereco").value;
                $("bairro_entrega").value = $("dest_bairro").value;
				
            }else if (idjanela.indexOf("Remetente") > -1){
                
            
                // *_cli traz do cliente e depois compara
                $('idremetente_cl').value = $('idremetente').value;
                $('rem_codigo_cl').value = $('rem_codigo').value;
                $('rem_cnpj_cl').value = $('rem_cnpj').value;
                $('rem_rzs_cl').value = $('rem_rzs').value;
                $("codigo_ibge_origem").value = $("cod_ibge").value;
                if ($("cidade_col").value == ""){ //se não possuir coleta
                    $("idcidadeorigem").value = $("rem_idcidade").value;
                    $("cid_cli").value = $("rem_idcidade").value;
                    $("bai_cli").value = $("rem_bairro").value;
                    $("end_cli").value = $("rem_endereco").value;
                }else{
                    $("idcidadeorigem").value = $("idcidade_col").value;
                    $("rem_idcidade").value = $("idcidade_col").value;
                    $("rem_bairro").value = $("bairro_col").value;
                    $("rem_endereco").value = $("endereco_col").value;
                    $('rem_cidade').value = $('cidade_col').value;
                    $('rem_uf').value = $('uf_col').value;
                }
                $("fone_cli").value = $("rem_fone").value;
                $("pontoReferencia").value = $("referencia_coleta").value;
                $("tipoPadraoDocumento").value =  $("tipo_documento_padrao").value;
                if($("mensagem_usuario_coleta_rem").value != null && $("mensagem_usuario_coleta_rem").value != ""){
                    setTimeout(function(){alert("Mensagem importante para emissão de Coleta do cliente "+ $("rem_rzs_cl").value+": "+$("mensagem_usuario_coleta_rem").value);
                    }
                            ),100
                }
                
                changeClientePagador("r");
            }else if (idjanela.indexOf("Cliente_Coleta") > -1){
            
                // *_cli traz do cliente e depois compara
                $('idremetente_coleta').value = $('idremetente').value;
                $('rem_col_codigo').value = $('rem_codigo').value;
                $('rem_col_cnpj').value = $('rem_cnpj').value;
                $('rem_col_rzs').value = $('rem_rzs').value;
            
                if ($("cidade_col").value == ""){ //se não possuir coleta
                    $("idcidadeorigem").value = $("rem_idcidade").value;
                    $("cid_cli").value = $("rem_idcidade").value;
                    $("bai_cli").value = $("rem_bairro").value;
                    $("end_cli").value = $("rem_endereco").value;
                }else{
                    $("idcidadeorigem").value = $("idcidade_col").value;
                    $("rem_idcidade").value = $("idcidade_col").value;
                    $("rem_bairro").value = $("bairro_col").value;
                    $("rem_endereco").value = $("endereco_col").value;
                    $('rem_cidade').value = $('cidade_col').value;
                    $('rem_uf').value = $('uf_col').value;
                }
                $("fone_cli").value = $("rem_fone").value;
                $("pontoReferencia").value = $("referencia_coleta").value;
            }else if (idjanela.indexOf("Cidade_destino") > -1){
                $("cidade_destino_id").value = $("idcidadedestino").value;
                $("cidade_destino").value = $("cid_destino").value;
                $("uf_dest").value = $("uf_destino").value;
                $("codIbgeDestino").value = $("codigo_ibge_destino").value;
                addCidadeDestino($("idcidadedestino").value,$("cid_destino").value,$("uf_destino").value,$("codigo_ibge_destino").value,'0');
            }else if (idjanela.indexOf("Cidades_destino") > -1){
                addCidadeDestino($("idcidadedestino").value,$("cid_destino").value,$("uf_destino").value,$("codigo_ibge_destino").value,'0');
            }else if (idjanela.indexOf("Servico") > -1){
                addServ(
                        'node_servs',
                        0,
                        $('type_service_id').value,
                        $('type_service_descricao').value,
                        '1',
                        $('type_service_valor').value, 
                        $('type_service_valor').value,
                        $('type_service_iss_percent').value,
                        '0', $('tax_id').value, 
                        '<%=taxes%>',
                        '0', 
                        '', 
                        '',
                        '0',
                        '',
                        $('is_usa_dias').value,
                        '1',
                        "<%=notas%>",
                        "0",
                        $("embutir_iss").value, 
                        true,
                        "",
                        "0",
                        "0",
                        "",
                        '<%=cfg.getTipoCalculaIss()%>'
                        );
            }else if (idjanela == "Observacao"){
                var obs = "" + $("obs_desc").value;
                obs = replaceAll(obs, "<BR>","");
                obs = replaceAll(obs, "<br>","");
                obs = replaceAll(obs, "</br>","");;
                obs = replaceAll(obs, "</BR>","");
                $("obs").value = obs;
            }else if (idjanela=="Cidade"){
                $('rem_cidade').value = $('cid_origem').value;
                $('rem_uf').value = $('uf_origem').value;
            } else if (idjanela == "Motorista"){
                $("codcategoriaNddVeiculo").value = $("codigo_categoria_ndd").value;
                if ($("bloqueado").value == 't') {
                    alert('Esse motorista está bloqueado. Motivo: ' + $("motivobloqueio").value);
                    $("motor_nome").value = '';
                    $("idmotorista").value = '';
                }else{
                    $("tipoveiculo").value = $("tipo_veiculo_motorista").value;
                }
                var filtros = "veiculo_motorista,carreta_motorista,bitrem_motorista,tritrem_motorista";
                for(var i = 0 ; i<= filtros.split(",").length; i ++){
                    validarBloqueioVeiculoMotorista(filtros.split(",")[i]);
                }
                <%if (cfg.isCartaFreteAutomaticaColeta() && acao.equalsIgnoreCase("iniciar")){ %>
                    if ($('vei_prop_cgc').value.length == 14 || ($('is_tac').value == 't' || $('is_tac').value == 'true' || $('is_tac').value == true )){
                        $('chk_reter_impostos').checked = true;
                    }else{
                        $('chk_reter_impostos').checked = false;
                    }
                <%}%>
                carregarAbastecimentos();
                    abrirLoginSupervisor('<%=cfg.getPermitirLancamantoOSAbertoVeiculo()%>',<%=TipoAutorizacao.COLETA_VEICULO_MANUTECAO.ordinal()%>,$("idcidadeorigem").value,0);
            } else if (idjanela == "Veiculo"){
                validarBloqueioVeiculo("veiculo");
                <%if (cfg.isCartaFreteAutomaticaColeta() && acao.equalsIgnoreCase("iniciar")){ %>
                    if ($('vei_prop_cgc').value.length == 14 || ($('is_tac').value == 't' || $('is_tac').value == 'true' || $('is_tac').value == true )){
                        $('chk_reter_impostos').checked = true;
                    }else{
                        $('chk_reter_impostos').checked = false;
                    }
                <%}%>
                carregarAbastecimentos();
                abrirLoginSupervisor('<%=cfg.getPermitirLancamantoOSAbertoVeiculo()%>',<%=TipoAutorizacao.COLETA_VEICULO_MANUTECAO.ordinal()%>,$("idcidadeorigem").value,0);
                $("categoriaNddVeiculo").value = $("categoria_ndd_id").value;
                $("codcategoriaNddVeiculo").value = $("cod_categoria_ndd").value;
            } else if (idjanela == "Carreta"){
                validarBloqueioVeiculo("carreta");
                <%if (cfg.isCartaFreteAutomaticaColeta() && acao.equalsIgnoreCase("iniciar")){ %>
                    if ($('vei_prop_cgc').value.length == 14 || ($('is_tac').value == 't' || $('is_tac').value == 'true' || $('is_tac').value == true )){
                        $('chk_reter_impostos').checked = true;
                    }else{
                        $('chk_reter_impostos').checked = false;
                    }
                <%}%>    
                $("categoriaNddCarreta").value = $("categoria_ndd_id").value;
                $("codcategoriaNddCarreta").value = $("cod_categoria_ndd").value;
            } else if (idjanela == "Orcamento"){
                $("pesoSolicitado").value = $("peso_solicitado").value;
                $("volumeSolicitado").value = $("volume_solicitado").value;
                $("rem_is_bloqueado").value = $("is_bloqueado_rem").value;
                
                changeClientePagador($("clientepagador").value);
                if ($('type_service_id') != null && $('type_service_id').value != 0 && $('type_service_id').value != "") {
                    addServ(
                            'node_servs',
                            0, 
                            $('type_service_id').value, 
                            $('type_service_descricao').value,
                            $('type_service_quantidade').value, 
                            $('type_service_valor').value, 
                            $('type_service_valor').value,
                            $('type_service_iss_percent').value, 
                            '0', 
                            $('tax_id').value, 
                            '<%=taxes%>',
                            '0', 
                            '', 
                            '',
                            '0',
                            '',
                            $('is_usa_dias').value,
                            '1',
                            "<%=notas%>",
                            "0",
                            $("embutir_iss").value, 
                            true,
                            "",
                            "0",
                            "0",
                            "",
                            '<%=cfg.getTipoCalculaIss()%>'
                            );
                }
                
            }else if (idjanela == "Cfop_Nota_fiscal"){
                $('inCfopId').value = $('idcfop').value;
                $('inCfop').value = $('cfop').value;
            }else if (idjanela.split("__")[0] == "Cfop_Nota_fiscal_nfe"){
                var idxCfopNfe = idjanela.split("__")[1];
                $('nf_cfop'+idxCfopNfe).value = $('cfop').value;
                $('nf_cfopId'+idxCfopNfe).value = $('idcfop').value;
            } else if(idjanela.split("__")[0] == "Produto_ctrcs_nf_item"){
                var idxProdNF = idjanela.split("__")[1];       
                $('nf_conteudo'+idxProdNF).value = $('desc_prod').value; 
                $('basePallet'+idxProdNF).value = $('produto_base_paletizacao').value; 
                $('alturaPallet'+idxProdNF).value = $('produto_altura_paletizacao').value; 
            }else if(idjanela.split("__")[0] == "Produto_ctrcs_nf"){
                var idxProdNF = idjanela.split("__")[1];       
                $('nf_conteudo'+idxProdNF).value = $('desc_prod').value; 
            }else if(idjanela == "Filial"){
                $("stUtilizacaoCfe").value = $("st_utilizacao_cfe").value;
                if($("stUtilizacaoCfe").value == 'D') {
                    $("isPedagioRoteirizador").value = true;
                }else{
                    if ($("valorPedagio") != null) {
                        $("valorPedagio").value = '0.00';
                    }
                    $("isPedagioRoteirizador").value = false;
                }
            }else if(idjanela == "bitrem,"){
                validarBloqueioVeiculo("bitrem");
            }else {                   
                for(var i = 1; i <= idxOco; i++){
                    if (idjanela == "Produto_"+i){
                        $('ocoProdutoCol_'+i).innerHTML = $("codigo_produto").value + " " + $("descricao_produto").value;
                        //                $("ocoProdCod_"+i).value = $("codigo_produto").value;
                        //                $("ocoProdDesc_"+i).value = $("descricao_produto").value;
                        $("ocoIdProduto_"+i).value = $("produto_id").value;
                    }
                }
            }
            if((idjanela == "Motorista") || idjanela == "Veiculo" || idjanela == "Carreta"){
                var tipoVeiculoMotorista = $("tipo_veiculo_motorista");
                var tipoVeiculoVeiculo = $("tipo_veiculo_veiculo").value;
                var tipoVeiculoCarreta = $("tipo_veiculo_carreta").value;

                if(idjanela == "Carreta" && tipoVeiculoCarreta != 0) {
                    tipoVeiculoMotorista.value = tipoVeiculoCarreta;
                } else if (idjanela == "Veiculo" && tipoVeiculoVeiculo != 0 && $('idcarreta').value == '0') {
                    tipoVeiculoMotorista.value = tipoVeiculoVeiculo;
                }
                $("tipoveiculo").value =  tipoVeiculoMotorista.value;
                preparaIniciarCfe();
            }
            if(<%=carregacol%>){
                var codigoIbge = '<%=(carregacol ? col.getDestinatario().getCidadeCol().getCod_ibge() : 0)%>';
               validacaoAlterarLoginSupervisor(codigoIbge,$("codigo_ibge_origem").value);
            }

        }
    
        function limpaConsignatario(){
            getObj("idconsignatario_con").value = "0";
            getObj("con_codigo_con").value = "0";
            getObj("con_cnpj_con").value = "";
            getObj("con_rzs_con").value = "";
        }

        function aoCarregar(){
            //$("trMovimentacao").style.display = "none";
            try{ 
    <%
        if (carregacol) {%>
    
    
                    if (<%=col.isCancelado()%>){
                        $("cancelada").checked = true;
                        mostraMotivoCancelamento();
                    }
    <% }%>


    <%  if (carregacol && !acao.equals("excluir")) {%>    //atribuindo o tipo de taxa

                $("clientepagador").value = "<%=col.getClientePagador()%>";
                $("urbano").value = "<%=col.isUrbano()%>";
                $("tipoPedido").value = "<%=col.getCategoria()%>";

                $("tipoColeta").value = "<%=col.getTipoColeta()%>";
                
                $("entregaContainerEm").value = "<%= col.getEntregaContainerEm()!=null? new SimpleDateFormat("dd/MM/yyyy").format(col.getEntregaContainerEm()): ""%>";
                $("entregaContainerAs").value = "<%= col.getEntregaContainerAs()!=null ? col.getEntregaContainerAs() :""%>";
                
                changeClientePagador($("clientepagador").value);
                getObj("tipotaxa").value = "<%=col.getTipoTaxa()%>";

                if ($('idremetente_coleta').value != 0){
                    getClienteColeta(false);
                }
                if ($('iddestinatario_entrega').value != 0){
                    getClienteEntrega(false);
                }
		
                if (<%=col.isCobranca()%>){
                    $('chk_coleta_cobranca').checked = true;
                    mostraCobranca();
                    if (<%=!col.getPedidoCobranca().equals("0") && !col.getPedidoCobranca().equals("") && col.getPedidoCobranca() != null%>){
                        addColetaCobranca('<%=col.getPedidoCobranca().split("!!")[0]%>', '<%=col.getPedidoCobranca().split("!!")[1]%>');
                    }
                }
    <%  }%>

    <%  if (carregacol) {
            //adicioonando os ajudantes
            for (int u = 0; u < col.getAjudantes().length; ++u) {
                BeanAjudanteColeta ajc = col.getAjudantes()[u];
    %>
                addAjudante("<%=ajc.getAjudante().getIdfornecedor()%>",
                "<%=ajc.getAjudante().getRazaosocial()%>",
                "<%=ajc.getAjudante().getFone1()%>",
                "<%=ajc.getAjudante().getFone2()%>",
                "<%=ajc.getValor()%>");
    <%       }

        for (int ui = 0; ui < col.getCidadesDestino().length; ++ui) {
            BeanCidadesColeta cd = col.getCidadesDestino()[ui];
    %>
                addCidadeDestino("<%=cd.getCidade().getIdcidade()%>",
                "<%=cd.getCidade().getDescricaoCidade()%>",
                "<%=cd.getCidade().getUf()%>",
                "<%=cd.getCidade().getCod_ibge()%>",
                 "<%=cd.getId() %>");
    <%       }



        // adicionando as notas fiscais
        if (!acao.equals("excluir") && !acao.equals("localizaClienteCodigo") && !acao.equals("getNotaByNumero")) {

            for (int b = 0; b < col.getNotasfiscais().size(); ++b) {

                NotaFiscal n = (NotaFiscal) col.getNotasfiscais().get(b);

    %>
                var prefixo = addNote('<%=col.getId()%>',
                'node_notes',
                '<%=n.getIdnotafiscal()%>',
                '<%=n.getNumero()%>',
                '<%=n.getSerie()%>',
                '<%=(n.getEmissao() != null ? new SimpleDateFormat("dd/MM/yyyy").format(n.getEmissao()) : "")%>',
                '<%=n.getValor()%>',
                '<%=n.getVl_base_icms()%>',
                '<%=n.getVl_icms()%>',
                '<%=n.getVl_icms_st()%>',
                '<%=n.getVl_icms_frete()%>',
                '<%=n.getPeso()%>',
                '<%=n.getVolume()%>',
                '<%=n.getEmbalagem()%>',
                '<%=n.getConteudo()%>',
    <%=n.getIdconhecimento()%>,
                '<%=n.getPedido()%>',
                false,
                '<%=n.getLargura()%>',
                '<%=n.getAltura()%>',
                '<%=n.getComprimento()%>',
                '<%=n.getMetroCubico()%>',
                '<%=n.getMarcaVeiculo().getIdmarca()%>',
                '<%=n.getMarcaVeiculo().getDescricao()%>',
                '<%=n.getModeloVeiculo()%>',
                '<%=n.getAnoVeiculo()%>',
                '<%=n.getCorVeiculo()%>',
                '<%=n.getChassiVeiculo()%>',
                '<%=n.getItemNotaFiscal().length%>',
                'true',
                '<%=n.getCfop().getIdcfop()%>',
                '<%=n.getCfop().getCfop()%>',
                '<%=n.getChaveNFe()%>',
                '<%=n.isAgendado()%>', //novos campos
                '<%=n.getDataAgenda() != null ? new SimpleDateFormat("dd/MM/yyyy").format(n.getDataAgenda()) : ""%>',
                '<%=n.getHoraAgenda()%>',
                '<%=n.getObservacaoAgenda()%>','<%=cfg.isBaixaEntregaNota()%>',
                '<%=n.getPrevisaoEm() != null ? new SimpleDateFormat("dd/MM/yyyy").format(n.getPrevisaoEm()) : ""%>',
                '<%=n.getPrevisaoAs()%>',
                '<%=n.getDestinatario().getIdcliente()%>',
                '<%=n.getDestinatario().getRazaosocial()%>',
                <%=n.isImportadaEdi()%>,
                '<%=n.getCubagens().length%>',0,
                '<%=n.getTipoDocumento()%>'
            );
                countIdxNotes++;

    <% for (int c = 0; c < n.getItemNotaFiscal().length; ++c) {
            ItemNotaFiscal item = n.getItemNotaFiscal()[c];
    %>
                addUpdateNotaFiscal2('trNote'+prefixo,
                '<%=n.getIdnotafiscal()%>',
                '<%=item.getId()%>',
                prefixo,
                '<%=(item.getProduto().getId() > 0) ? item.getProduto().getDescricao() : item.getDescricao() %>',
                '<%=item.getQuantidade()%>',
                '<%=item.getValor()%>',
                (<%=c%>+1),
                '<%=(item.getProduto().getId() > 0) ? item.getProduto().getId() : "0" %>',
                '<%=item.getBasePaletizacao() %>',
                '<%=item.getAlturaPaletizacao() %>'
                ,'editar');
                

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

            }//for
        }
        //adicionando os serviços


        for (int x = 0; x < col.getServicos().length; ++x) {
            BeanVendaServico vs = col.getServicos()[x];
    %>  
                addServ(
                'node_servs',
                "<%=vs.getId()%>",
                "<%=vs.getTipo_servico().getId()%>",
                "<%=vs.getTipo_servico().getDescricao()%>",
                "<%=vs.getQuantidade()%>",
                "<%=vs.getValor()%>",
                "<%=vs.getValorTotal()%>",
                "<%=vs.getIss()%>",
                "<%=vs.getValorISS()%>",
                "<%=vs.getTributacao().getId()%>",
                "<%=taxes%>",
                "0",
                "",
                "",
                "0",
                "",
                "<%=vs.getTipo_servico().isUsaDias()%>",
                "<%=vs.getQtdDias()%>",
                "<%=notas%>",
                "<%=vs.getNotaFiscal().getIdnotafiscal()%>",
                <%=vs.isEmbutirISS()%>,
                false,
                <%=vs.getNotaFiscal().getIdnotafiscal()%>,
                "0",
                "0",
                "",
                '<%=cfg.getTipoCalculaIss()%>'
            );
    <%      }

        //adicionando as ocorrencias
        for (int x = 0; x < col.getOcorrencias().length; ++x) {
            Ocorrencia o = col.getOcorrencias()[x];

    %>
                //addOcorrencia(id, ocorrencia_id, ocorrencia, ocorrenciaEm, ocorrenciaAs, usuarioOcorrencia,observacaoOcorrencia)
                addOcorrencia("<%=o.getId()%>",
                "<%=o.getOcorrencia().getId()%>",
                "<%=o.getOcorrencia().getDescricao()%>",
                "<%=(o.getOcorrenciaEm() != null ? new SimpleDateFormat("dd/MM/yyyy").format(o.getOcorrenciaEm()) : "")%>",
                "<%=(o.getOcorrenciaAs() != null ? new SimpleDateFormat("HH:mm").format(o.getOcorrenciaAs()) : "")%>",
                "<%=o.getUsuarioOcorrencia().getLogin()%>",
                "<%=o.getObservacaoOcorrencia()%>",
                "<%=o.getProduto().getId()%>",
                "<%=o.getProduto().getDescricao()%>",
                "<%=o.getProduto().getCodigo()%>",
                "<%= o.getNotaFiscal().getIdnotafiscal() %>",
                "<%= (o.getNotaFiscal().getNumero() != null) ? o.getNotaFiscal().getNumero() : "" %>",
                "<%= o.getQuantidade() %>");
    <%      }
    %>
		 
    <%
        }//if
%>
        
    <%


        for (MovimentacaoPallets palle : col.getItens()) {%>
            
                    var pallets = new ItemMovimentacao('<%=palle.getId()%>','<%=palle.getData()%>', '<%=palle.getNota()%>','<%=palle.getTipo()%>', '<%=palle.getCliente().getIdcliente()%>',
                    '<%=palle.getCliente().getRazaosocial()%>', '<%=palle.getQuantidade()%>', 
                    '<%=palle.getPallet().getId()%>', '<%=palle.getPallet().getDescricao()%>');

                    addItensMovimentacao(pallets);
        
    <%

        }


    %>
    <%for (BeanColetaDespesa pedidoDespesa : col.getDespesas()) {%>
                //ATENÇÃO ADICIONAR O DOM APARTIR DESTE FOREACH
                var despesa =  new Despesa();
                despesa.id = <%=pedidoDespesa.getDespesa().getIdmovimento()%>;
                despesa.tipo = <%=pedidoDespesa.getDespesa().isAVista()%> ? "a":"p";
                despesa.data = "<%=pedidoDespesa.getDespesa().getDtEmissaoStr()%>";
                despesa.serie = "<%=pedidoDespesa.getDespesa().getSerie()%>" ;
                despesa.especie= "<%=pedidoDespesa.getDespesa().getEspecie_().getEspecie()%>";
                despesa.nf = <%=pedidoDespesa.getDespesa().getNfiscal()%>;
                despesa.fornecedor = "<%=pedidoDespesa.getDespesa().getFornecedor().getRazaosocial()%>";
                despesa.idFornecedor = <%=pedidoDespesa.getDespesa().getFornecedor().getIdfornecedor()%>;
                despesa.historico = "<%=pedidoDespesa.getDespesa().getDescHistorico()%>";
                despesa.valor = <%=pedidoDespesa.getDespesa().getValor()%>;
    <% BeanDuplDespesa[] dupl = pedidoDespesa.getDespesa().getDuplicatas();%>
                despesa.venc = "<%=dupl[0].getDtVenc()%>";
                despesa.doc = "<%=dupl[0].getMovBanco().getDocum()%>";
                despesa.idConta = <%=dupl[0].getMovBanco().getConta().getIdConta()%>;
                despesa.isCheque = <%=dupl[0].getMovBanco().isCheque()%>;
            
            
                addDespesa(despesa);
                var ap;
            
    <%for (BeanApropDespesa ap : pedidoDespesa.getDespesa().getApropriacoes()) {%> 
                            
                ap = new ApropriacaoDespesa();
                ap.apropriacao = "<%=ap.getPlanocusto().getDescricao()%>";
                ap.idApropriacao = <%=ap.getPlanocusto().getIdconta()%>;
                ap.conta = "<%=ap.getPlanocusto().getConta()%>";
                ap.idUnd = <%=ap.getUndCusto().getId()%>;
                ap.und = "<%=ap.getUndCusto().getSigla()%>";
                ap.idVeiculo = <%=ap.getVeiculo().getIdveiculo()%>;
                ap.veiculo = "<%=ap.getVeiculo().getPlaca()%>";
                ap.incluindo = false;
                ap.valor = <%=ap.getValor()%>;
                
                addPropriacao($("maxDespesa").value, ap);
    <%}%>

    <%}%>      
        
                //alteraTipo();
                totaisNotas();
                alteraUrbano();
                totalHorimetro();
            //Funcão para remover todos os ícones de lixeiras das despesas na hora de editar
            if($("idcoleta").value != 0){
            var index = 1;
            
            if($("maxPlano_" + index) != null){
            
                var maxPlano = $("maxPlano_" + index).value;
                var sair = true;

                while(sair){
                   for (var i = 1; i <= maxPlano; i++) {
                        if($("pcLixo_" + index + "_" + i) != null){
                             $("pcLixo_" + index + "_" + i).style.visibility = "hidden";
                             $("pcLixoDespesa_" + index).style.visibility = "hidden";
                        }
                        else if($("pcLixo_" + index + "_" + i) == null){
                             sair = false;
                        }
                    }
                    index++;
                    }
                }
            }
            }catch(e){
                alert(e)    
            }
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
                };
            }
            var lastQtd = $("qtd"+lastIndex);
            if (lastQtd != null){
                lastQtd.onchange = function(){
                    seNaoFloatReset(lastQtd,"1");
                    //atualizando totais
                    validaTipoTributacao(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                    getCalculaTotalServ(lastIndex,<%=cfg.getTipoCalculaIss()%>);

                };
            }
            var lastDias = $("qtdDias_"+lastIndex);
            if (lastDias != null){
                lastDias.onchange = function(){
                    seNaoFloatReset(lastQtd,"1");
                    //atualizando totais
                    validaTipoTributacao(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                    getCalculaTotalServ(lastIndex,<%=cfg.getTipoCalculaIss()%>);

                };
            }
            var lastIss = $("perc_iss"+lastIndex);
            if (lastIss != null){
                lastIss.onchange = function(){
                    seNaoFloatReset(lastIss,"0.00");
                    //atualizando totais
                    validaTipoTributacao(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                    getCalculaTotalServ(lastIndex,<%=cfg.getTipoCalculaIss()%>);

                };
            }
            var lastTrib = $("trib"+lastIndex);
            if (lastTrib != null){
                lastTrib.onchange = function(){
                    validaTipoTributacao(lastIndex,<%=cfg.getTipoCalculaIss()%>);
                };
            }
        
        }

        function changeClientePagador(pagador){
            if (pagador == 'd' && $("clientepagador").value == 'd'){
                $('tipotaxa').value = ($('dest_rzs_cl').value != '' ? $('dest_tipotaxa').value : -1);
            }else{
                $('tipotaxa').value = ($('rem_rzs_cl').value != '' ? $('rem_tipotaxa').value : -1);
            }
            if ($('tipotaxa').value == ''){
                $('tipotaxa').value = '-1';
            }
            //Análise de crédito
            if ((pagador == 'd' && $("clientepagador").value == 'd') && $('des_is_bloqueado').value == 't'){
                
                if (confirm('Existem pendências financeiras para o cliente ' + $('dest_rzs_cl').value + ', a coleta poderá ser realizada, mas a emissão do Conhecimento de transporte será bloqueada para esse cliente. Deseja visualizar a situação do cliente?')){
                    <%if (nivelAnaliseCredito == 4) {%>
                        window.open("./analise_credito.jsp?acao=consultar&idconsignatario="+$('iddestinatario_cl').value+"&con_rzs="+$('dest_rzs_cl').value+"&con_cnpj="+$('dest_cnpj').value, "Analise" , 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
                    <%} else {%>
                        alert("ATENÇÃO: Você não tem privilégios suficientes para executar essa ação. Para acessar essa rotina você deverá solicitar apermissão 080 ao usuário administrador de sua empresa.");
                    <%}%>
                }
            }
            if ((pagador == 'r' && $("clientepagador").value == 'r') && $('rem_is_bloqueado').value == 't'){
            
                if (confirm('Existem pendências financeiras para o cliente ' + $('rem_rzs_cl').value + ' consulte o setor financeiro, a coleta poderá ser realizada, mas a emissão do Conhecimento de transporte será bloqueada para esse cliente. Deseja visualizar a situação do cliente?')){
                    <%if (nivelAnaliseCredito == 4) {%>
                            window.open("./analise_credito.jsp?acao=consultar&idconsignatario="+$('idremetente_cl').value+"&con_rzs="+$('rem_rzs_cl').value+"&con_cnpj="+$('rem_cnpj_cl').value, "Analise" , 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
                    <%} else {%>
                         alert("ATENÇÃO: Você não tem privilégios suficientes para executar essa ação. Para acessar essa rotina você deverá solicitar apermissão 080 ao usuário administrador de sua empresa.");
                    <%}%>
                }
            }
            if ((pagador == 'c' && $("clientepagador").value == 'c') && $('con_is_bloqueado').value == 't'){
            
                if (confirm('Existem pendências financeiras para o cliente ' + $('con_rzs_con').value + ' consulte o setor financeiro, a coleta poderá ser realizada, mas a emissão do Conhecimento de transporte será bloqueada para esse cliente. Deseja visualizar a situação do cliente?')){
                    <%if (nivelAnaliseCredito == 4) {%>
                            window.open("./analise_credito.jsp?acao=consultar&idconsignatario="+$('idconsignatario_con').value+"&con_rzs="+$('con_rzs_con').value+"&con_cnpj="+$('con_cnpj_con').value, "Analise" , 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
                    <%} else {%>
                         alert("ATENÇÃO: Você não tem privilégios suficientes para executar essa ação. Para acessar essa rotina você deverá solicitar apermissão 080 ao usuário administrador de sua empresa.");
                    <%}%>
                }
            }

            if (pagador == 'c' && $("clientepagador").value == 'c'){
                $("trConsignatario").style.display = "";
                $("trConsignatario2").style.display = "";
            }else if($("clientepagador").value == 'c' && $("idconsignatario_con").value != '0'){
                $("trConsignatario").style.display = "";
                $("trConsignatario2").style.display = "";
            }else{
                //se o pagador for CONSIGNATARIO, não tem por que apagar as linhas do consignatario.
                if ($("clientepagador").value == 'c') {
                    return;
                }
                $("trConsignatario").style.display = "none";
                $("trConsignatario2").style.display = "none";
            }
        }

        function verVeiculo(tipo){
            var mostrar = false;
            var idVeiculo = 0;
            if (tipo == 'V' && $('idveiculo').value != '0'){
                idVeiculo = $('idveiculo').value;
                mostrar = true;
            }else if (tipo == 'C' && $('idcarreta').value != '0'){
                idVeiculo = $('idcarreta').value;
                mostrar = true;
            }else if (tipo == 'B' && $('idbitrem').value != '0'){
                idVeiculo = $('idbitrem').value;
                mostrar = true;
            }else if (tipo == 'T' && $('idtritrem').value != '0'){
                idVeiculo = $('idtritrem').value;
                mostrar = true;
            }
                 
            if (mostrar)
                window.open('./cadveiculo?acao=editar&id=' + idVeiculo ,'Veículo','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
        }

        function verMotorista(){
            var mostrar = false;
            var idMotorista = 0;
            if ($('idmotorista').value != '0'){
                idMotorista = $('idmotorista').value;
                mostrar = true;
            }
                 
            if (mostrar)
                window.open('./cadmotorista?acao=editar&id=' + idMotorista ,'Motorista','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
        }
  
    
        function limpaDestinatarioCodigo(){
            $('iddestinatario_cl').value = '0';
            $('des_codigo_cl').value = '';
            $('dest_rzs_cl').value = '';
            $('dest_cidade').value = '';
            $('dest_uf').value = '';
            $('dest_cnpj_cl').value = '';
            $('dest_tipotaxa').value = '-1';
            $("cidade_destino_id").value = "0";
            $("des_is_bloqueado").value = "f";
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
                    alert('Erro ao localizar cliente.');
                    return false;
                }else if (resp == 'INA'){
                    limpaDestinatarioCodigo();
                    alert('Cliente inativo.');
                    return false;
                }else if(resp == ''){
                    limpaDestinatarioCodigo();
                    //$("pontoReferencia").value = "";
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
                    $('uf_destino').value = cliControl.uf;
                    $('dest_cnpj').value = cliControl.cnpj;
                    $('dest_tipotaxa').value = cliControl.tipotaxa;
                    $("cidade_destino_id").value = cliControl.idcidade;
                    $("idcidadedestino").value = cliControl.idcidade;
                    $("dest_bairro").value = cliControl.bairro;
                    $("dest_endereco").value = cliControl.endereco;
                    $("des_is_bloqueado").value = cliControl.is_bloqueado;
                    $("taxa_roubo").value = cliControl.taxa_roubo;
                    $("taxa_roubo_urbano").value = cliControl.taxa_roubo_urbano;
                    $("taxa_tombamento").value = cliControl.taxa_tombamento;
                    $("taxa_tombamento_urbano").value = cliControl.taxa_tombamento_urbano;
                    $("cod_ibge").value = cliControl.cod_ibge;
                    $("mensagem_usuario_coleta_des").value = cliControl.mensagem_usuario_coleta;
                    if ($("id_rota_viagem") !== null && $("id_rota_viagem") !== undefined) {
                        $("id_rota_viagem").value = cliControl.id_rota_viagem;

                    }
                    if ($("distancia_km") !== null && $("distancia_km") !== undefined) {
                        $("distancia_km").value = cliControl.distanciakm;
                    }
                    if (isDestEntrega){
                        aoClicarNoLocaliza('Cliente_Entrega');
                    }else{
                        aoClicarNoLocaliza('Destinatario');
                    }
                }
            }//funcao e()

            if (valor != ''){
                espereEnviar("",true);
                tryRequestToServer(function(){
                    new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor="+valor+"&idfilial=0&remUF="+$('rem_uf').value+"&idcidadeorigem="+$('idcidadeorigem').value+"&campo="+campo,{method:'post', onSuccess: e, onError: e});
                });
            }
        }

        function verCliente(tipo){
            var mostrar = false;
            var idCliente = 0;
            if (tipo == 'R' && $('idremetente_cl').value != '0'){
                idCliente = $('idremetente_cl').value;
                mostrar = true;
            }else if (tipo == 'RC' && $('idremetente_coleta').value != '0'){
                idCliente = $('idremetente_coleta').value;
                mostrar = true;
            }else if (tipo == 'D' && $('iddestinatario_cl').value != '0'){
                idCliente = $('iddestinatario_cl').value;
                mostrar = true;
            }else if (tipo == 'DC' && $('iddestinatario_entrega').value != '0'){
                idCliente = $('iddestinatario_entrega').value;
                mostrar = true;
            }else if (tipo == 'T' && $('idtransportador').value != '0'){
                idCliente = $('idtransportador').value;
                mostrar = true;
            }else if (tipo == 'C' && $('idconsignatario').value != '0'){
                idCliente = $('idconsignatario_con').value;
                mostrar = true;
            }
                 
            if (mostrar)
                window.open('./cadcliente?acao=editar&id=' + idCliente ,'Cliente','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
        }
        //Função para apenas visualizar a nota fiscal.
        function visualizarNota(idNotaFiscal){
            if(idNotaFiscal != 0){
                window.open("NotaFiscalControlador?acao=carregar&idNota="+idNotaFiscal+"&visualizar=true&cnpjDest="+$("dest_cnpj_cl").value,
                        "visualizarNota" , 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
            }else{
                alert("Nota fiscal ainda não foi salva!");
            }
        }

        function totaisNotas(){
            //atualizando totais
            $("totalNF").value = sumValorNotes('<%=col.getId()%>');
//            $("totalPeso").innerHTML = sumPesoNotes('<%=col.getId()%>').toFixed(2);
//            $("totalPeso").innerHTML = sumPesoNotes('<%=col.getId()%>');
            $("totalVol").innerHTML = sumVolumeNotes('<%=col.getId()%>');
        }

        function applyEventInNote(idColeta) {
            var lastIndex = (getNextIndexFromTableRoot('<%=col.getId()%>', 'tableNotes0') - 1);

            //aplicando o evento ao ultimo nf_valor adicionado
            var lastVlNote = $("nf_valor"+lastIndex+"_id<%=col.getId()%>");
            if (lastVlNote != null){
                lastVlNote.onchange = function(){
                    $("totalNF").value = sumValorNotes('<%=col.getId()%>');
                    seNaoFloatReset(lastVlNote,"0.00");
                    //atualizando totais
                    $("totalNF").value = sumValorNotes('<%=col.getId()%>');
                    if($('calculo_valor_contrato_frete').value === 'nf'){
                        preparaIniciarCfe();
                    }
                };
            }
            var lastVlPeso = getObj("nf_peso"+lastIndex+"_id<%=col.getId()%>");
            if (lastVlPeso != null) {
                lastVlPeso.onchange = function(){
                $("totalPeso").value = sumPesoNotes('<%=col.getId()%>');
                    seNaoFloatReset(lastVlPeso,"0.00");
                $("totalPeso").value = sumPesoNotes('<%=col.getId()%>');

                    if($('calculo_valor_contrato_frete').value === 'ct' && $('tipo_calculo_percentual_valor_cfe').value === 'fp'){
                         preparaIniciarCfe();
                    }
                };
                //aplicando o evento ao ultimo nf_volume adicionado
                var lastVlVolume = $("nf_volume"+lastIndex+"_id<%=col.getId()%>");
                if (lastVlVolume != null) {
                    lastVlVolume.onchange = function(){
                        $("totalVol").innerHTML = sumVolumeNotes('<%=col.getId()%>');
                    }
                    seNaoFloatReset(lastVlVolume,"0.00");
                    //atualizando totais
                    $("totalVol").innerHTML = sumVolumeNotes('<%=col.getId()%>');
                };
            }
        }
        function mostraCobranca(){

            if ($('chk_coleta_cobranca').checked){
                $('tr_cobranca').style.display = "";
            }else{
                $('tr_cobranca').style.display = "none";
            }
        }

        function localizaColeta(){
            if ($v('idremetente_cl') != '0' && $v('idremetente_cl') != '0'){
                var post_cad = window.open('./pops/seleciona_coleta.jsp?acao=iniciar&idcliente='+$('idremetente_cl').value+"&coletas="+concatPed(),'CTRC',
                'top=80,left=60,height=400,width=900,resizable=yes,status=3,scrollbars=1');
            }else{
                alert('Informe o cliente corretamente.');
            }
        }

        function addColetaCobranca(ids, pedidos){
            var _tr = '';
            var _td = '';
            var ctrc = '';
            var id = 0;
            var contTd = 0;
            var contTr = 0;

            var qtd = ids.split(',').length;
    
            indexCob = 0;

            $('lbCobranca').innerHTML = "";
    
            //Criando a Table

            if (qtd >= 1){
                $('lbCobranca').appendChild(Builder.node('table', {width:'100%', id:'tbCobrancaMestre', border:'1', className:'CelulaZebra2'}));
                $('tbCobrancaMestre').appendChild(Builder.node('tbody', {id:'tbCobranca'}));
                _tr = Builder.node('TR', {id:'tr'+contTr});
                $('tbCobranca').appendChild(_tr);
    
                for (x=0;x<qtd;x++){
                    id = ids.split(',')[x];
                    ped = pedidos.split(',')[x];
                    if (contTd == -1){
                        contTr++;
                        contTd = 0;
                        _tr = Builder.node('TR', {id:'tr'+contTr, className:'CelulaZebra2'});
                        $('tbCobranca').appendChild(_tr);
                    }
                    _td = Builder.node('TD', {width:'10%'}, [ Builder.node('INPUT', {name:'pedido_cobranca_id'+indexCob,id:'pedido_cobranca_id'+indexCob,value:id, type:'hidden'}),
                        ped]);
                    $('tr'+contTr).appendChild(_td);
                    if (contTd==9)
                        contTd = -1;
                    else
                        contTd++;

                    indexCob++;
                
                    $("indexCob").value = indexCob;

                }
            }

        }

        function concatPed() {
            var pd = "0";
            for (i = 0; i < indexCob; ++i){
                pd += "," + $("pedido_cobranca_id"+i).value;
            }
            return pd;
        }

        function removerOcorrencia(idx){
            var idOcorrenciaCTe = $("ocorrenciaId_"+idx).value;
            var idOcorrencia = $("idCol_"+idx).value;
            var idColeta = $("idcoleta").value;
            try{
                if (confirm("Deseja mesmo apagar a ocorrência desta coleta?")){
//                    Element.remove('trCol_'+idx);
                    
                    new Ajax.Request("./cadcoleta.jsp?acao=removerOcorrenciaColeta&idOcorrenciaCTe="+idOcorrenciaCTe+"&idOcorrencia="+idOcorrencia+"&idColeta="+idColeta, 
                        {
                            method:'get',
                            onSuccess: function(){
                                alert('Campo removido com sucesso!')
                                Element.remove($('trCol_'+idx));
                            },
                            onFailure: function(){ alert('Something went wrong...') }
                        });
                }
                
            }catch(erro){
                alert(erro);
            }
        }
	
        function limpaRemetenteCodigo(){
            $('idremetente_cl').value = '0';
            $('rem_codigo_cl').value = '';
            $('rem_rzs_cl').value = '';
            $('rem_cidade').value = '';
            $('rem_uf').value = '';
            $('rem_cnpj_cl').value = '';
            $('rem_fone').value = '';
            $('rem_tipotaxa').value = '-1';
            $("rem_is_bloqueado").value = "f";
            $("pontoReferencia").value = "";
            $("endereco_col").value = "";
            $("bairro_col").value = "";
            $('cidade_col').value = "";
            $('uf_col').value ="";
            $("idcidade_col").value = "0";
            $("horario_atendimento").value = "";
            $("referencia_coleta").value = "";
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
                    $('rem_cidade').value = cliControl.cidade;
                    $('rem_uf').value = cliControl.uf;
                    $('rem_cnpj').value = cliControl.cnpj;
                    $('rem_tipotaxa').value = cliControl.tipotaxa;
                    $('rem_endereco').value = cliControl.endereco;
                    $('rem_bairro').value = cliControl.bairro;
                    $("rem_idcidade").value = cliControl.idcidade;
                    $("endereco_col").value = cliControl.endereco_col;
                    $("bairro_col").value = cliControl.bairro_col;
                    $('cidade_col').value = cliControl.cidade_col;
                    $('uf_col').value = cliControl.uf_col;
                    $("idcidade_col").value = cliControl.idcidade_col;
                    $("horario_atendimento").value = cliControl.horario_coleta;
                    $("rem_fone").value = cliControl.fone;
                    $("rem_is_bloqueado").value = cliControl.is_bloqueado;
                    $("referencia_coleta").value = cliControl.referencia_coleta;
                    $("taxa_roubo").value = cliControl.taxa_roubo;
                    $("taxa_roubo_urbano").value = cliControl.taxa_roubo_urbano;
                    $("taxa_tombamento").value = cliControl.taxa_tombamento;
                    $("taxa_tombamento_urbano").value = cliControl.taxa_tombamento_urbano;
                    $("tipo_documento_padrao").value = cliControl.documentoPadrao;
                    $("cod_ibge").value = cliControl.cod_ibge;
                    $("mensagem_usuario_coleta_rem").value = cliControl.mensagem_usuario_coleta;
                    if ($("id_rota_viagem") !== null && $("id_rota_viagem") !== undefined) {
                        $("id_rota_viagem").value = cliControl.id_rota_viagem;
                    }
                    if ($("distancia_km") !== null && $("distancia_km") !== undefined) {
                        $("distancia_km").value = cliControl.distanciakm;
                    }

                    // campos de endereço de coleta
                    if (isRemColeta){
                        aoClicarNoLocaliza('Cliente_Coleta');
                    }else{
                        aoClicarNoLocaliza('Remetente');
                    }
				
                    if (campo == 'c.razaosocial'){
                        getObj('dest_rzs_cl').focus();
                    }
                }
            }//funcao e()

            if (valor != ''){
                espereEnviar("",true);
                tryRequestToServer(function(){
                    new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor="+valor+"&idfilial=0&destUF="+$('uf_destino').value+"&idcidadedestino="+$('idcidadedestino').value+"&campo="+campo,{method:'post', onSuccess: e, onError: e});
                });
            }
        }

        function editarRomaneio(idRomaneio){
            window.open("./cadromaneio?acao=editar&id="+idRomaneio, "LocRomaneio" , 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
        }

        function editarCarta(idCarta){
            stCfe = '<%=col.getFilial().getStUtilizacaoCfe()%>';
            if (stCfe == 'N'){
                window.open("./cadcartafrete?acao=editar&id="+idCarta, "LocCarta" , 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
            }else{
                window.open("./ContratoFreteControlador?acao=iniciarEditar&id="+idCarta, "LocCarta" , 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
            }    
        }
	
        
        function localizaOrcamento(){
            filial = $("idfilial").value;
            if (filial == "0"){
                alert("Para efetuar a localização informe a filial.");
                return false;
            }
            launchPopupLocate('./localiza?acao=consultar&idlista=45&paramaux='+filial,'Orcamento');
        }

        function removerCidade(idx){
            var pdId = $("pdId_"+idx).value;
            var idColeta = $("idcoleta").value;
            if (confirm("Deseja mesmo apagar a cidade de destino desta coleta?")){
                try{

                        new Ajax.Request("./cadcoleta.jsp?acao=removerCidadeColeta&pdId="+pdId+"&idColeta="+idColeta, 
                            {
                                method:'get',
                                onSuccess: function(){
                                      Element.remove('tdCid_'+idx);
                                },
                                onFailure: function(){ alert('Something went wrong...') }
                            });
                }catch(erro){
                    alert(erro);
                }
            }
        }
        
        var idxCid = 0;
        var linhaCid = 0;
        function addCidadeDestino(idCidade,cidade,uf, codIbge, pdId){
            //if ($(idCidade) != null){
            //  alert('Cidade já inclusa!');
            //return null;
            //}
            if (idxCid % 4 == 0){
                linhaCid++;
                var _tr = '';
                _tr = Builder.node('TR', {id:'trCid_'+linhaCid, name:'trCid_'+linhaCid});
                $('corpoCidades').appendChild(_tr);
            }
            idxCid++;
            //alert(linhaCid);
            var _td = '';
            _td = Builder.node('TD', {id:'tdCid_'+idxCid, name:'tdCid_'+idxCid, className:'CelulaZebra2', width:'25%'},
            [Builder.node('IMG', {src:'img/lixo.png', title:'Apagar cidade de destino da coleta.', className:'imagemLink',
                    onClick:'removerCidade('+idxCid+');'}),
                Builder.node('LABEL', {name:'cidadeDestino_'+idxCid, id:'cidadeDestino_'+idxCid},cidade),
                Builder.node('LABEL', {name:'ufDestino_'+idxCid, id:'ufDestino_'+idxCid},"-"+uf),
                Builder.node('INPUT', {type:'hidden', name:'cidadeDestinoId_'+idxCid, id:'cidadeDestinoId_'+idxCid, value:idCidade}),
                Builder.node('INPUT', {type:'hidden', name:idCidade, id:idCidade, value:idCidade}),
                Builder.node('INPUT', {type:'hidden', name:'codDestino_'+idxCid, id:'codDestino_'+idxCid, value:codIbge}),
                Builder.node('INPUT', {type:'hidden', name:'pdId_'+idxCid, id:'pdId_'+idxCid, value:pdId})
            ]);

            $('trCid_'+linhaCid).appendChild(_td);
            $("maxCidades").value = idxCid;

        }

        function alteraUrbano(){

            if ($('urbano').value == 'false'){
                $('trUrbano').style.display = 'none';
            }else{
                $('trUrbano').style.display = '';
            }

        }
	
        function mostraDestinos(){
            if ($('trCidadesDestino').style.display==''){
                $('trCidadesDestino').style.display='none';	
                $('lbMostraDestinos').innerHTML = 'Visualizar/Adicionar mais Destinos';
            }else{
                $('trCidadesDestino').style.display='';	
                $('lbMostraDestinos').innerHTML = 'Ocultar Destinos';
            }
        }
	
        function mostraMotivoCancelamento(){
            if ($('cancelada').checked){
                $('trMotivoCancelamento').style.display = '';
            }else{
                $('trMotivoCancelamento').style.display = 'none';
            }
        }
	
        function getClienteColeta(isAbrirLocaliza){
            if ($('trClienteColeta').style.display == 'none'){
                $('lbClienteColeta').style.display = 'none';
                $('trClienteColeta').style.display = '';
            }
            if (isAbrirLocaliza){
                launchPopupLocate('./localiza?categoria=loc_cliente&acao=consultar&paramaux2='+$('uf_dest').value+'&idlista=3','Cliente_Coleta');
            }	
        }
 
        function getClienteEntrega(isAbrirLocaliza){
            if ($('trClienteEntrega').style.display == 'none'){
                $('lbClienteEntrega').style.display = 'none';
                $('trClienteEntrega').style.display = '';
            }
            if (isAbrirLocaliza){
                launchPopupLocate('./localiza?categoria=loc_cliente&paramaux2='+$('rem_uf').value+'&acao=consultar&idlista=4','Cliente_Entrega');
            }	
        }

        function localizaPesoContainer(id){
            var idContainer = id;
            function e(transport){
                var resp = transport.responseText;
                espereEnviar("",false);
                $("pesoContainer").value = resp.split("!!")[0];
                $("valorContainer").value = resp.split("!!")[1];
                // Element.update($("pesoContainer").value,resp.split("!!")[0]);
            }
            if (idContainer != 0){
                espereEnviar("",true);
                tryRequestToServer(function(){
                    new Ajax.Request("./cadcoleta.jsp?acao=localizarPesoContainer&idContainer="+idContainer,{
                        method:'post',
                        onSuccess: e,
                        onError: e
                    });
                });
            }
            
        }
     
        function abrirLocalizarCliente(index){
            $("idCliente").value = index;
            launchPopupLocate('./localiza?acao=consultar&idlista=5&fecharJanela=true','Cliente')
        }
    
        function abrirLocalizarPallet(index){
            $("idPallet").value = index;
            launchPopupLocate('./localiza?acao=consultar&idlista=66&fecharJanela=true','Pallet')
        }
        
        function localizarProdutoNota(index){
            $("doomAuxiliar").value = index;
            var idRemetente = $("rem_codigo_cl").value;
            var idDestinatario = $("des_codigo_cl").value;
            popLocate(50, "ProdutoNota","","paramaux="+ idRemetente+"&paramaux2="+ idDestinatario);
        }
        
        function localizarNotaFiscalOcorrencia(index){
            $("doomAuxiliar").value = index;
            popLocate(46, "NotaFiscalOcorrencia","","&paramaux="+"<%=col.getId()%>");
        }
        
        function limparCliente (id){
            $("idcliente_"+ id).value = 0;
            $("cliente_"+ id).value = "";
        }
        
         function limparProdutoNota(index){
            //Localizar todos os elementos que o nome do id passado por parâmetro.
            var campos = document.getElementsByName("produtoId"+index);
            //Dependendo de quantos tem o mesmo id ele vai setar
            for(var i = 0; i <= campos.length;i++){
               if(campos[i] != null){
                  campos[i].value = "0";
               }
             }
             
             $("descricaoItemNota_"+index).value = "";
        }
    
        function limparPallet (id){
            $("idpallet_"+ id).value = 0;
            $("pallet_"+ id).value = "";
        } 
     
        function excluirM(id, index){
            if(confirm("Deseja excluir esta movimentação ?")){
                if(confirm("Tem certeza?")){
                    new Ajax.Request("MovimentacaoPalletsControlador?acao=excluir2&id="+id,
                    {
                        method:'get',
                        onSuccess: function(){ alert('Movimentação removido com sucesso!') 
                            $("idLinha_" + index).style.display = "none"},
                        onFailure: function(){ alert('Something went wrong...') }
                    });     
                }
            }
        }

        function ItemMovimentacao(id, data, nota, tipo, idCliente, cliente, quantidade, idPallet, pallet){
            this.id = (id != undefined && id != null ? id : 0);
            this.data = (data != undefined ? data : $("dtsolicitacao").value);
            this.nota = (nota != undefined && nota!= null ? nota : "");
            this.tipo = (tipo != undefined ? tipo : "");
            this.idCliente = (idCliente != undefined && idCliente != null ? idCliente : 0);
            this.cliente = (cliente != undefined && cliente!= null ? cliente : "");
            this.quantidade = (quantidade != undefined && quantidade != null ? quantidade : "");
            this.idPallet = (idPallet != undefined && idPallet!= null ? idPallet : 0);
            this.pallet = (pallet != undefined ? pallet : "");
        }       
    
        var countItensMovimentacao = 0;
    
        function addItensMovimentacao(itensMovimentacao){
            $("trMovimentacao").style.display = "";
            try{
                if (itensMovimentacao == null || itensMovimentacao == undefined){
                    itensMovimentacao = new ItemMovimentacao();
                } 
                
                countItensMovimentacao++;    
                //var homePath = $("homePath").value;
                var tabelaBase = $("tbMovimentacao");
                
                var tr =  Builder.node("tr" , {
                    className:"CelulaZebra2",
                    id:"idLinha_" + countItensMovimentacao  
                });
                
                var td0 = Builder.node("td" , {
                    align: "center"
                });
                var img0 = Builder.node("img",{
                    className:"imagemLink",
                    src: "img/lixo.png",
                    onclick:"excluirM("+ itensMovimentacao.id + "," + countItensMovimentacao +");"
                
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
                
                var td4 = Builder.node("td" , {
                    align :"center"
                
                });
                
                var td5 = Builder.node("td" , {
                    align :"center"
                
                });
                
                var td6 = Builder.node("td" , {
                    align :"center"
                
                });
               
          
                var inpId = Builder.node("input" , {
                    type  : "hidden" ,
                    name  : "idItem_" + countItensMovimentacao ,
                    id    : "idItem_" + countItensMovimentacao ,
                    value : itensMovimentacao.id
                });
                
                var inp2 = Builder.node("input" , {
                    type  : "hidden" ,
                    name  : "idcliente_" + countItensMovimentacao ,
                    id    : "idcliente_" + countItensMovimentacao ,
                    value : itensMovimentacao.idCliente
                });
                

                var text1 = Builder.node ("input", {
                    id : "cliente_" + countItensMovimentacao ,
                    name : "cliente_" + countItensMovimentacao ,
                    className:"fieldMin",
                    type  : "text" ,
                    size  : "20",
                    maxLength : "40" ,
                    value : itensMovimentacao.cliente
               
                });
                readOnly(text1);
                    
            
                var btn2 = Builder.node("input" , {
                    id : "botaoItens_" + countItensMovimentacao ,
                    name : "botaoItens" + countItensMovimentacao ,
                    className : "inputBotaoMin" ,    
                    onclick:"abrirLocalizarCliente(" + countItensMovimentacao + ")",
                    type : "button" ,
                    value : "..."
                });
                
                var img2 = Builder.node("img" , {
                    id: "borracha" ,
                    className:"imagemLink",
                    src: "img/borracha.gif",
                    onclick:"limparCliente("+ countItensMovimentacao +");"
                });
                
                
                var text2 = Builder.node ("input", {
                    id : "nota_" + countItensMovimentacao ,
                    name : "nota_" + countItensMovimentacao ,
                    className:"fieldMin",
                    type  : "text" ,
                    size  : "15",
                    maxLength : "8" ,
                    onkeypress : "mascara(this, soNumeros)",
                    value : (itensMovimentacao.nota == '' ? '0' : itensMovimentacao.nota)
               
                });
                
                var slcTipo = Builder.node ("select", {
                    id : "tipo_" + countItensMovimentacao ,
                    name : "tipo_" + countItensMovimentacao ,
                    className:"fieldMin",
                    type  : "text" ,
                    size  : "1",
                    maxLength : "2" 
               
                });
                
                var _optC = Builder.node('OPTION', {value:'c'}, "Entrada");
                var _optD = Builder.node('OPTION', {value:'d'}, "Saída");
                
                slcTipo.appendChild(_optC);
                slcTipo.appendChild(_optD);
                slcTipo.value = itensMovimentacao.tipo;
                
                
                var text4 = Builder.node ("input", {
                    id : "quantidade_" + countItensMovimentacao ,
                    name : "quantidade_" + countItensMovimentacao ,
                    className:"fieldMin",
                    type  : "text" ,
                    size  : "10",
                    maxLength : "10",
                    onkeypress : "mascara(this, soNumeros)",
                    value : itensMovimentacao.quantidade
               
                });
                
                
                var inp3 = Builder.node("input" , {
                    type  : "hidden" ,
                    name  : "idpallet_" + countItensMovimentacao ,
                    id    : "idpallet_" + countItensMovimentacao ,
                    value : itensMovimentacao.idPallet
                });
                
 
                var text5 = Builder.node ("input", {
                    id : "pallet_" + countItensMovimentacao ,
                    name : "pallet_" + countItensMovimentacao ,
                    className:"fieldMin",
                    type  : "text" ,
                    size  : "15",
                    maxLength : "20",
                    value : itensMovimentacao.pallet
               
                });
                readOnly(text5);
            
                var btn3 = Builder.node("input" , {
                    id : "botaoItens_" + countItensMovimentacao ,
                    name : "botaoItens" + countItensMovimentacao ,
                    className : "inputBotaoMin" ,    
                    onclick:"abrirLocalizarPallet(" + countItensMovimentacao + ")",
                    type : "button" ,
                    value : "..."
                });
                
                var img3 = Builder.node("img" , {
                    id: "borracha" ,
                    className:"imagemLink",
                    src: "img/borracha.gif",
                    onclick:"limparPallet("+ countItensMovimentacao +");"
                });
                
                var text6 = Builder.node ("input", {
                    id : "data_" + countItensMovimentacao ,
                    name : "data_" + countItensMovimentacao ,
                    className:"fieldDateMin",
                    type  : "text" ,
                    size  : "12",
                    onBlur: "alertInvalidDate(this,true)",
                    maxLength : "10" ,
                    value : itensMovimentacao.data
               
                });
                    
             
                td1.appendChild(inpId);
                td1.appendChild(text2);
                
                td2.appendChild(inp2);
                td2.appendChild(text1);
                td2.appendChild(btn2);
                td2.appendChild(img2);
                
                td3.appendChild(text6);
                
                td4.appendChild(inp3);
                td4.appendChild(text5);
                td4.appendChild(btn3);
                td4.appendChild(img3);
                
                td5.appendChild(text4);
                                
                td6.appendChild(slcTipo);
                
                tr.appendChild(td0);
                tr.appendChild(td1);
                tr.appendChild(td2);
                tr.appendChild(td3);
                tr.appendChild(td4);
                tr.appendChild(td5);
                tr.appendChild(td6);
                
                tabelaBase.appendChild(tr);
                $("max").value = countItensMovimentacao;
                applyFormatter();
            }catch(ex){
                alert(ex);
            }
        }
        /*function Despesa(){
       
   }*/     
        function Despesa(id,tipo,data,serie,especie,nf,fornecedor,idFornecedor,historico,valor,venc,doc,idConta,isCheque){
            this.id = (id== null || id == undefined? 0 : id);
            this.tipo = (tipo== null || tipo == undefined? "" :tipo); 
            this.data = (data== null || data == undefined? dataAtual : data);
            this.serie = (serie== null || serie == undefined? "" : serie);
            this.especie = (especie == null || especie == undefined? "" : especie);
            this.nf = (nf == null || nf == undefined? "" : nf);
            this.fornecedor = (fornecedor == null || fornecedor == undefined? "" : fornecedor);
            this.idFornecedor = (idFornecedor == null || idFornecedor == undefined? 0 : idFornecedor);
            this.historico = (historico == null || historico == undefined? "" : historico);
            this.valor = (valor == null || valor == undefined? "0,00" : valor);
            this.venc = (venc == null || venc == undefined? dataAtual : venc);
            this.doc = (doc == null || doc == undefined? "" : doc);
            this.idConta = (idConta == null || idConta == undefined? "" : idConta);
            this.isCheque = (isCheque == null || isCheque == undefined? "" : isCheque);
        } 
        function addDespesa(despesa){
            countDespesa++;
            if(despesa == null|| despesa == undefined){
                despesa = new Despesa();
            }
            //chamada de funcoes
            var callVerDocumDesp  = "verDocumDesp("+countDespesa+");";
            var callLocalizarFornecedor  = "abrirLocalizarFornecedor("+countDespesa+");";
            var callLocalizarHistorico  = "abrirLocalizarHistorico("+countDespesa+");";
            var callLocalizarPlano  = (despesa.id != 0)?"":"abrirLocalizaPlanoCusto("+countDespesa+");";
            var callVerContaDesp  = "verContaDespesa("+countDespesa+");";
            var callVerDesp = "verDesp(" + despesa.id + ");";
            var _table = Builder.node("TABLE",{width:"100%",className:"bordaFina"});
            var _tBody = Builder.node("TBODY",{id:"tBodyPlano_"+countDespesa});
            var _td0 = Builder.node("TD",{colSpan:10});

            var _tr1 = Builder.node("TR",{id:"tr_"+countDespesa});//tr
            var _tr2 = Builder.node("TR",{id:"trContaDespesa_"+countDespesa});//tr
            var _tr3_1 = Builder.node("TR",{id:"trPlanoCusto_"+countDespesa, className:"celula"});//tr
            var _tr3 = Builder.node("TR",{id:"trDespesas_"+countDespesa});//tr
            //td's
            var _td1 = Builder.node("TD", {className:"textoCamposNoAlign",align:"center"});
            var _td2 = Builder.node("TD", {className:"textoCamposNoAlign",align:"left"});
            var _td3 = Builder.node("TD", {className:"textoCamposNoAlign",align:"left"});
            var _td4 = Builder.node("TD", {className:"textoCamposNoAlign",align:"left"});
            var _td5 = Builder.node("TD", {className:"textoCamposNoAlign",align:"left"});
            var _td6 = Builder.node("TD", {className:"textoCamposNoAlign",align:"left"});
            var _td7 = Builder.node("TD", {className:"textoCamposNoAlign",align:"left"});
            var _td8 = Builder.node("TD", {className:"textoCamposNoAlign",align:"left"});
            var _td9 = Builder.node("TD", {className:"textoCamposNoAlign",align:"left"});
            var _td10 = Builder.node("TD", {className:"textoCamposNoAlign",align:"left"});

            var _td2_0 = Builder.node("TD", {className:"textoCamposNoAlign",align:"left"});
            var _td2_1 = Builder.node("TD", {className:"textoCamposNoAlign",align:"left", colSpan:4});
            var _td2_2 = Builder.node("TD", {className:"textoCamposNoAlign",align:"left", colSpan:5});


            var _td3_1 = Builder.node("TD", {align:"center", width:"3%"});
            var _td3_2 = Builder.node("TD", {align:"left", width:"40%"});
            var _td3_3 = Builder.node("TD", {align:"left", width:"12%"});
            var _td3_4 = Builder.node("TD", {align:"left", width:"8%"});
            var _td3_5 = Builder.node("TD", {align:"left", width:"10%"});
            var _td3_6 = Builder.node("TD", {align:"left", width:"3%"});
            var _td3_7 = Builder.node("TD", {align:"left", width:"10%"});
            var _td3_8 = Builder.node("TD", {align:"left", width:"14%"});

            //label
            var _lab1 = Builder.node("LABEL");
            var _lab2 = Builder.node("LABEL");
            var _lab3 = Builder.node("LABEL");
            var _lab4 = Builder.node("LABEL");
            var _lab5 = Builder.node("LABEL");
            var _lab6 = Builder.node("LABEL");           
            var _lab7 = Builder.node("LABEL", {className: 'linkEditar', onClick: callVerDesp});
            Element.update(_lab7, despesa.id);
            //input's
            var _inp1 = Builder.node("INPUT", {type:"text",size:8,name:"serie_"+countDespesa, id:"serie_"+countDespesa, className:'fieldMin', value:despesa.serie,maxLength:"3" });
            var _inp2 = Builder.node("INPUT", {type:"text",size:8,name:"notaFiscal_"+countDespesa,id: "notaFiscal_"+countDespesa, className:'fieldMin', value:despesa.nf });
            var _inp3 = Builder.node("INPUT", {type:"text",size:10,name:"dtDespesa_"+countDespesa, id:"dtDespesa_"+countDespesa, className:'fieldDateMin', value:despesa.data,onkeypress:"fmtDate(this, event)" ,maxlength:"10"});
            var _inp9 = Builder.node("INPUT", {type:"text",size:10,name:"dtVencimento_"+countDespesa, id:"dtVencimento_"+countDespesa, className:'fieldDateMin', value: despesa.venc,onkeypress:"fmtDate(this, event)",maxlength:"10"});
            var _inp4 = Builder.node("INPUT", {type:"text",size:30,name:"fornecedor_"+countDespesa, id:"fornecedor_"+countDespesa, className:'inputReadOnly8pt', value:despesa.fornecedor });
            var _inp5 = Builder.node("INPUT", {type:"hidden",name:"idFornecedor_"+countDespesa, id:"idFornecedor_"+countDespesa, value: despesa.idFornecedor});
            var _inp13 = Builder.node("INPUT", {type:"hidden",name:"idDepesa_"+countDespesa, id:"idDepesa_"+countDespesa, value: despesa.id});
            var _inp6 = Builder.node("INPUT", {type:"text",size:30,name:"historico_"+countDespesa, id:"historico_"+countDespesa, className:'fieldMin', value: despesa.historico});
            var _inp7 = Builder.node("INPUT", {type:"hidden",name:"idHistorico_"+countDespesa, id:"idHistorico_"+countDespesa, value: ""});
            var _inp8 = Builder.node("INPUT", {type:"text",size:8,name:"valorDespesa_"+countDespesa, id:"valorDespesa_"+countDespesa, className:'fieldMin', value: colocarVirgula(despesa.valor)});
            var _inp10 = Builder.node("INPUT", {type:"hidden",name:"maxPlano_"+countDespesa, id:"maxPlano_"+countDespesa, value: 0});
            var _inp11 = Builder.node("INPUT", {type:"text",size:8,name:"documDesp_"+countDespesa,id: "documDesp_"+countDespesa, className:'fieldMin', value:""});

            var _inp12 = Builder.node("INPUT", {type:"checkbox", name:"isCheque_"+countDespesa,id: "isCheque_"+countDespesa, className:'fieldMin', onClick: callVerDocumDesp});
            var _but1 = Builder.node('INPUT', {type:'button', name:'localizaForn_'+countDespesa, id:'localizaForn_'+countDespesa,value:'...', className:'inputBotaoMin',onClick:callLocalizarFornecedor});
            var _but2 = Builder.node('INPUT', {type:'button', name:'localizaHist_'+countDespesa, id:'localizaHist_'+countDespesa,value:'...', className:'inputBotaoMin',onClick:callLocalizarHistorico});
            
            var imgLixo = Builder.node("IMG",{src:"img/lixo.png", name:"pcLixoDespesa_"+countDespesa, id:"pcLixoDespesa_"+countDespesa, onClick:"removerDespesas("+countDespesa+");"});//lixeira para excluir a despesa
            var _img1 = Builder.node('IMG', {src:'img/add.gif', title:'Adicionar Apropriação', className:'imagemLink',onClick:callLocalizarPlano});
            var _slc1 = Builder.node('SELECT', {name:'tipoDesp_'+countDespesa, id:'tipoDesp_'+countDespesa, className:'fieldMin', onchange: callVerContaDesp});
            var _slc2 = Builder.node('SELECT', {name:'especieDesp_'+countDespesa, id:'especieDesp_'+countDespesa, className:'fieldMin'});
            var _slc3 = Builder.node('SELECT', {name:'contaDesp_'+countDespesa, id:'contaDesp_'+countDespesa, className:'fieldMin', onchange: callVerDocumDesp});
            var _slc4 = Builder.node('SELECT', {name:'documDesp2_'+countDespesa, id:'documDesp2_'+countDespesa, className:'fieldMin'});
            var _optA = Builder.node('OPTION', {value:"a"});
            var _optP = Builder.node('OPTION', {value:"p"});
        
            /* if(despesa.tipo == "p"){
            _slc1.appendChild(Element.update(_optA, "Pago"));//avista
            _slc1.appendChild(Element.update(_optP, "A Pagar"));//prazo
        }else if(despesa.tipo == "a"){
            _slc1.appendChild(Element.update(_optP, "A Pagar"));//prazo
            _slc1.appendChild(Element.update(_optA, "Pago"));//avista
        }else{*/
            _slc1.appendChild(Element.update(_optP, "A Pagar"));//prazo
            _slc1.appendChild(Element.update(_optA, "Pago"));//avista
            _slc1.value = despesa.tipo;
            /*}*/
       
       
       
            var optEspecie = null;
    <%for (Especie especie : Especie.mostrarTodos(cadcol.getConexao())) {
    %>
            optEspecie = Builder.node("option", {
                value: "<%=especie.getId()%>"
            });            
            Element.update(optEspecie, "<%=especie.getEspecie()%>");
            _slc2.appendChild(optEspecie);
    <%
        }
    %>
            //combo conta  
            var optConta = null;  
    <%for (BeanConta conta : BeanConsultaConta.mostraContas(Apoio.getUsuario(request).getFilial().getIdfilial(), true, cadcol.getConexao(), limitarUsuarioVisualizarConta, idUsuario)) {
    %> 
            optConta = Builder.node("option", {
                value: "<%=conta.getIdConta()%>"
            });
            Element.update(optConta, "<%=conta.getNumero()%>");
            _slc3.appendChild(optConta);
    <%
        }
    %>        
            //Area em construção
            /*if(listaEspecie != null && listaEspecie != undefined ){
        var optEspecie = null;
        for(var i = 1; i < listaEspecie.length; i++){
            
            optEspecie = Builder.node("option", {
                value: listaEspecie[i].valor
            });            
            Element.update(optEspecie, listaEspecie[i].descricao);
            _slc2.appendChild(optEspecie);
        }

        var optConta = null;
        for(var i = 0; i < listaConta.length; i++){
            optConta = Builder.node("option", {
                value: listaConta[i].valor
            });
            Element.update(optConta, listaConta[i].descricao);
            _slc3.appendChild(optConta);
        }
   }*/
            //fim da area em construcao
            //referente a tr 1
            _td1.appendChild(imgLixo);
            _td1.appendChild(_inp10);
            _td1.appendChild(_inp13);
            if (despesa.id != "0") {
                _td2.appendChild(_lab7);
            }
            _td2.appendChild(_slc1);
            _td3.appendChild(_slc2);
            _td4.appendChild(_inp1);
            _td5.appendChild(_inp2);
            _td6.appendChild(_inp3);
            _td7.appendChild(_inp4);
            _td7.appendChild(_inp5);
            _td7.appendChild(_but1);
            _td8.appendChild(_inp6);
            _td8.appendChild(_inp7);
            _td8.appendChild(_but2);
            _td9.appendChild(_inp8);


            _tr1.appendChild(_td1);
            _tr1.appendChild(_td2);
            _tr1.appendChild(_td3);
            _tr1.appendChild(_td4);
            _tr1.appendChild(_td5);
            _tr1.appendChild(_td6);
            _tr1.appendChild(_td7);
            _tr1.appendChild(_td8);
            _tr1.appendChild(_td9);
            _tr1.appendChild(_td10);

            //referente a tr2
            Element.update(_lab6, " Cheque ");

            _td2_1.appendChild(_slc3);
            _td2_2.appendChild(_inp12);
            _td2_2.appendChild(_lab6);
            _td2_2.appendChild(_inp11);
            _td2_2.appendChild(_slc4);
            //_td2_1.appendChild(_slc3);

            _tr2.appendChild(_td2_0);
            _tr2.appendChild(_td2_1);
            _tr2.appendChild(_td2_2);

            //referente a tr3
            //preparando a linha com plano de custo

            Element.update(_lab1, "Plano de Custo");
            Element.update(_lab2, "Veículo");
            Element.update(_lab3, "Valor");
            Element.update(_lab4, "Und. Custo");
            Element.update(_lab5, "Vencimento:");
            

            _td3_1.appendChild(_img1);
            _td3_2.appendChild(_lab1);
            _td3_3.appendChild(_lab2);
            _td3_4.appendChild(_lab3);
            _td3_5.appendChild(_lab4);
            _td3_7.appendChild(_lab5);
            _td3_8.appendChild(_inp9);

            _tr3_1.appendChild(_td3_1);
            _tr3_1.appendChild(_td3_2);
            _tr3_1.appendChild(_td3_3);
            _tr3_1.appendChild(_td3_4);
            _tr3_1.appendChild(_td3_5);
            _tr3_1.appendChild(_td3_6);
            _tr3_1.appendChild(_td3_7);
            _tr3_1.appendChild(_td3_8);


            _tBody.appendChild(_tr3_1);
            _table.appendChild(_tBody);
            _td0.appendChild(_table);
            _tr3.appendChild(_td0);


            invisivel(_tr2);
            invisivel(_slc4);

            readOnly(_inp8, "inputReadOnly8pt");

            $("bodyDespesa").appendChild(_tr1);
            $("bodyDespesa").appendChild(_tr2);
            $("bodyDespesa").appendChild(_tr3);
            $("maxDespesa").value= countDespesa;
        
            if (despesa.id != 0) {
                $("tipoDesp_"+countDespesa).disabled = true;
                $("especieDesp_"+countDespesa).disabled = true;
                $("serie_"+countDespesa).readOnly = true;
                $("notaFiscal_"+countDespesa).readOnly = true;
                $("dtDespesa_"+countDespesa).readOnly = true;
                $("fornecedor_"+countDespesa).readOnly = true;
                $("localizaForn_"+countDespesa).style.display ="none";
                $("historico_"+countDespesa).readOnly = true;
                $("localizaHist_"+countDespesa).style.display ="none";
                $("dtVencimento_"+countDespesa).readOnly = true;
            }
        }
        
        
        function verDesp(idDesp) {
            window.open("./caddespesa?acao=editar&id=" + idDesp + "&ex=false", "Despesa", "top=0,resizable=yes,status=1,scrollbars=1");
            
        }
    
    
        function ApropriacaoDespesa(idApropriacao, conta, apropriacao, idVeiculo, veiculo, valor, incluindo, idUnd, und){
            this.idApropriacao = (idApropriacao== null || idApropriacao == undefined? 0 : idApropriacao);
            this.conta = (conta == null || conta == undefined? 0 : conta);
            this.apropriacao = (apropriacao == null || apropriacao == undefined? "" : apropriacao);
            this.idVeiculo = (idVeiculo == null || idVeiculo == undefined? 0 : idVeiculo);
            this.veiculo = (veiculo == null || veiculo == undefined? "" : veiculo);
            this.valor = (valor == null || valor == undefined? 0 : valor);
            this.incluindo = (incluindo == null || incluindo == undefined? true : incluindo);
            this.idUnd = (idUnd == null || idUnd == undefined? "" : idUnd);
            this.und = (und == null || und == undefined? "" : und);
        }
        function addPropriacao(indexDespesa,plano){
            if(plano == null || plano == undefined){
                plano= new ApropriacaoDespesa();
            }

            countDespesaPlanoCusto = parseInt($("maxPlano_"+indexDespesa).value);
            ++countDespesaPlanoCusto;
        
            var callCalcularDespesaValor  = "calcularDespesaValor("+countDespesa+","+countDespesaPlanoCusto+");";
            var callLocalizarUnidadeCusto  = "abrirLocalizarUndCusto('"+countDespesa+"_"+countDespesaPlanoCusto+"');";
            var callLocalizarVeiculo  = "abrirLocalizarVeiculo('"+countDespesa+"_"+countDespesaPlanoCusto+"');";
            var callLocalizarPlano  = "abrirLocalizaPlanoCusto("+indexDespesa+","+countDespesaPlanoCusto+");";
            var _tr1 = Builder.node("TR",{id:"tr_"+indexDespesa+"_"+countDespesaPlanoCusto, className:"celula"});
            var imgLixo = Builder.node("IMG",{src:"img/lixo.png", name:"pcLixo_"+indexDespesa+"_"+countDespesaPlanoCusto, id:"pcLixo_"+indexDespesa+"_"+countDespesaPlanoCusto, onClick:"removerPlanoCusto("+indexDespesa+","+countDespesaPlanoCusto+");"});            
            var _inp1 = Builder.node("INPUT", {type:"text",size:12 ,name:"conta_"+indexDespesa+"_"+countDespesaPlanoCusto, id:"conta_"+indexDespesa+"_"+countDespesaPlanoCusto, className:'inputReadOnly8pt', readOnly: true, value: plano.conta});
            var _inp2 = Builder.node("INPUT", {type:"text",size:30 ,name:"apropriacao_"+indexDespesa+"_"+countDespesaPlanoCusto, id:"apropriacao_"+indexDespesa+"_"+countDespesaPlanoCusto, className:'inputReadOnly8pt', readOnly: true, value: plano.apropriacao});
            var _inp3 = Builder.node("INPUT", {type:"hidden",name:"idApropriacao_"+indexDespesa+"_"+countDespesaPlanoCusto, id:"idApropriacao_"+indexDespesa+"_"+countDespesaPlanoCusto, className:'fieldMin', value: plano.idApropriacao});
            var _inp4 = Builder.node("INPUT", {type:"text",size:10 ,name:"veiculoAprop_"+indexDespesa+"_"+countDespesaPlanoCusto, id:"veiculoAprop_"+indexDespesa+"_"+countDespesaPlanoCusto, className:'inputReadOnly8pt', readOnly: true, value: plano.veiculo});
            var _inp5 = Builder.node("INPUT", {type:"hidden",name:"idVeiculoAprop_"+indexDespesa+"_"+countDespesaPlanoCusto, id:"idVeiculoAprop_"+indexDespesa+"_"+countDespesaPlanoCusto, className:'fieldMin', value: plano.idVeiculo});
            var _inp6 = Builder.node("INPUT", {type:"text",size:8 ,name:"valorAprop_"+indexDespesa+"_"+countDespesaPlanoCusto, id:"valorAprop_"+indexDespesa+"_"+countDespesaPlanoCusto, className:'fieldMin', value: colocarVirgula(plano.valor), onBlur: callCalcularDespesaValor, onKeyPress:callMascaraReais});
            var _inp7 = Builder.node("INPUT", {type:"hidden",name:"idUndAprop_"+indexDespesa+"_"+countDespesaPlanoCusto, id:"idUndAprop_"+indexDespesa+"_"+countDespesaPlanoCusto, className:'fieldMin', value: plano.idUnd});
            var _inp8 = Builder.node("INPUT", {type:"text",size:6 ,name:"undAprop_"+indexDespesa+"_"+countDespesaPlanoCusto, id:"undAprop_"+indexDespesa+"_"+countDespesaPlanoCusto, className:'inputReadOnly8pt', readOnly: true, value: plano.und});
            var _but1 = Builder.node('INPUT', {type:'button', name:'localizaAprop_'+indexDespesa+"_"+countDespesaPlanoCusto, id:'localizaAprop_'+indexDespesa+"_"+countDespesaPlanoCusto,value:'...', className:'inputBotaoMin',onClick: callLocalizarPlano});
            var _but2 = Builder.node('INPUT', {type:'button', name:'localizaVeic_'+indexDespesa+"_"+countDespesaPlanoCusto, id:'localizaVeic_'+indexDespesa+"_"+countDespesaPlanoCusto,value:'...', className:'inputBotaoMin',onClick: callLocalizarVeiculo});
            var _but3 = Builder.node('INPUT', {type:'button', name:'localizaUnd_'+indexDespesa+"_"+countDespesaPlanoCusto, id:'localizaUnd_'+indexDespesa+"_"+countDespesaPlanoCusto,value:'...', className:'inputBotaoMin',onClick: callLocalizarUnidadeCusto});
            var _td1 = Builder.node("TD", {align:"center"});
            var _td2 = Builder.node("TD", {align:"left"});
            var _td3 = Builder.node("TD", {align:"left"});
            var _td4 = Builder.node("TD", {align:"left"});
            var _td5 = Builder.node("TD", {align:"left"});
            var _td6 = Builder.node("TD", {align:"left"});
            var _td7 = Builder.node("TD", {align:"left"});
            var _td8 = Builder.node("TD", {align:"left"});

            _td1.appendChild(imgLixo);
            _td2.appendChild(_inp1);
            _td2.appendChild(_inp2);
            _td2.appendChild(_but1);
            _td2.appendChild(_inp3);
            _td3.appendChild(_inp4);
            _td3.appendChild(_inp5);
            //_td3.appendChild(_but2);
            _td4.appendChild(_inp6);
            _td5.appendChild(_inp7);
            _td5.appendChild(_inp8);
            _td5.appendChild(_but3);

            _tr1.appendChild(_td1);
            _tr1.appendChild(_td2);
            _tr1.appendChild(_td3);
            _tr1.appendChild(_td4);
            _tr1.appendChild(_td5);
            _tr1.appendChild(_td6);
            _tr1.appendChild(_td7);
            _tr1.appendChild(_td8);
                
            $("tBodyPlano_"+indexDespesa).appendChild(_tr1);
        
            if($("idDepesa_"+indexDespesa).value != 0){
                /*$("conta_"+indexDespesa+"_"+countDespesaPlanoCusto).readOnly = true;
            $("apropriacao_"+indexDespesa+"_"+countDespesaPlanoCusto).readOnly = true;*/
                $('localizaAprop_'+indexDespesa+"_"+countDespesaPlanoCusto).style.display = "none";
                $('localizaUnd_'+indexDespesa+"_"+countDespesaPlanoCusto).style.display = "none";
                $('valorAprop_'+indexDespesa+"_"+countDespesaPlanoCusto).readOnly = true;
            }
            
            $("maxPlano_"+indexDespesa).value = countDespesaPlanoCusto;

        }
    
        function verDocumDesp(linha){
            if($("isCheque_"+linha)!= null && $("isCheque_"+linha).checked){
                controlarCheque(${configuracao.controlarTalonario}, $("documDesp2_"+linha), $("documDesp_"+linha), $('contaDesp_'+linha).value);
            }
        }
        function abrirLocalizarFornecedor(index){
            $("indexAux").value = index;
            launchPopupLocate('./localiza?acao=consultar&idlista=21&fecharJanela=true','Fornecedor')
        }
        function abrirLocalizarHistorico(index){
            $("indexAux").value = index;
            launchPopupLocate('./localiza?acao=consultar&idlista=14&fecharJanela=true','Historico')
        }
        function abrirLocalizaPlanoCusto(indexDespesa, indexPlano){
            $("indexAux").value = indexDespesa+"_"+indexPlano;
            launchPopupLocate('./localiza?acao=consultar&idlista=20&fecharJanela=true','Plano')
        }
        function verContaDespesa(index){
            if($("tipoDesp_"+index).value=="a"){
                visivel($("trContaDespesa_"+index));
            }else{
                invisivel($("trContaDespesa_"+index));
            }
        }
        function abrirLocalizarUndCusto(index){
            if($("indexAux") != null){
                $("indexAux").value = index;
            }
            launchPopupLocate('./localiza?acao=consultar&idlista=39&fecharJanela=true','Unidade_de_Custo');        
        }
    
        function calcularDespesaValor(indexDesp, indexPlano){
            var vlDesp = $("valorDespesa_"+indexDesp);
            var maxPlano = parseInt($("maxPlano_"+indexDesp).value);

            var valor = 0;

            for(var i = 1; i<= maxPlano; i++){
                if($("valorAprop_"+indexDesp+"_"+i) != null){
                    valor += parseFloat(colocarPonto($("valorAprop_"+indexDesp+"_"+i).value));
                }
            }
            vlDesp.value = colocarVirgula(valor);
        }
        
        //------------------------------------------------ Início Frete  -------------------
       var countDespesaCarta = 0;
       function validarContratoFrete(){
           var erro = "";
           var erroViagem = ""
           var cont = 0;
           //Verificando se o percentual de adiantamento está dentro do permitido no cadastro do motorista.
            if (<%= nivelUser == 0%>){
                    var percPermitido = $('perc_adiant').value;
                    var totalAdtmo = $('cartaValorAdiantamento').value;
                    var xTotalLiquido = $('cartaLiquido').value;
                    var percAdtmo = parseFloat(totalAdtmo) * 100 / parseFloat(xTotalLiquido);
                    if (parseFloat(percAdtmo) > parseFloat(percPermitido)){
                        cont++;
                        erro +=  cont+'-Para esse motorista só é permitido ' + percPermitido + '% de adiantamento!\n';
                    }
            }
            
            if (<%=cfg.isControlarTalonario()%>){
                if (parseFloat($('cartaValorAdiantamento').value) != 0 && $('cartaFPagAdiantamento').value == '3' && $('cartaDocAdiantamento_cb').value == ''){
                   cont++;
                   erro += cont+"-Informe o número do cheque corretamente para o adiantamento.\n";
                }
            }else{
                if (parseFloat($('cartaValorAdiantamento').value) != 0 && $('cartaFPagAdiantamento').value == '3' && $('cartaDocAdiantamento').value == ''){
                   cont++;
                   erro += cont+"-Informe o número do cheque corretamente para o adiantamento.\n";
                }
            }
 
            if ($('motor_liberacao_carta').value == ''){
                cont++;
                erro += cont+"-Informe a liberação do motorista corretamente.\n";
            }
            if($("cartaValorFrete").value == "0.00"){
                cont++;
                erro += cont+"-Informe o valor frete.\n";
            }
            //Validação das despesas
            for(var dd = 0; dd <= parseInt(countDespesaCarta); dd++){
                
                if ($('trDespCarta_'+dd) != null){
                    if (parseFloat($('vlDespCarta_'+dd).value) <= 0 || $('idFornDespCarta_'+dd).value == '0' || $('idPlanoDespCarta_'+dd).value == '0'){
                       if(erroViagem == ""){
                          cont++;
                          erroViagem  = cont+"-Para gerar a despesa de viagem do contrato de frete é necessário informar o 'Valor', 'Fornecedor' e o 'Plano de Custo'.\n";  
                       }
                       //erroViagem += erroViagem != "" ? "" : 
                    }
                    if($("DespPagar_"+dd).checked){
                        if($("vlDespVencimento_"+dd).value == "" || $("vlDespVencimento_"+dd).value.length < 10){
                            cont++;
                            erroViagem += cont+ "-Informe o vencimento da despesa de viagem " + dd + ".\n";
                        }
                    }
                    
                    if ($('DespPago_'+dd).checked && $('chqDespCarta_'+dd).checked){
                        if (<%=cfg.isControlarTalonario()%>){
                            if($('docDespCarta_cb_'+dd).value == ''){
                                cont++;
                                erroViagem += cont+"-Informe o número do cheque corretamente para a despesa de viagem.\n";
                            }
                        }else{
                            if($('docDespCarta_'+dd).value == ''){
                                cont++;
                                erro += cont+"-Informe o número do cheque corretamente para a despesa de viagem.\n";
                            }
                        }
                    }
                }
            }
            if (isRetencaoImpostoOpeCFe()) {
                let totSaldo = parseFloat($("cartaValorSaldo").value);
                let ir = parseFloat($("valorIRInteg").value);
                let inss = parseFloat($("valorINSSInteg").value);
                let sest = parseFloat($("valorSESTInteg").value);
                if (totSaldo < (ir + inss + sest)) {
                    erro += (cont++) +("ATENÇÃO: Não é possivel salvar o contrato pois a provisão dos impostos ("
                                +colocarVirgula((ir + inss + sest))+") é maior que o saldo ("+colocarVirgula(totSaldo)+").");
                }
            }
            erro += erroViagem;
           return erro;
       }
       
        function removerDespCarta(idxCarta, isCarta){
            if (isCarta){
		if (confirm("Deseja mesmo excluir esta despesa do contrato de frete?")){
			Element.remove('trDespCarta_'+idxCarta);
			Element.remove('trDespCarta2_'+idxCarta);
		}
            }else{
		if (confirm("Deseja mesmo excluir esta despesa do adiantamento de viagem?")){
			Element.remove('trDespADV_'+idxCarta);
		}
            }
        }
        
        function removerPlanoCusto(despesa, linha){
            if (confirm("Deseja mesmo excluir este Plano de Custo ?")){
                    Element.remove('tr_'+ despesa + "_" + linha);
            }
        }
    
        function removerDespesas(despesa){
            if (confirm("Deseja mesmo excluir este Despesa ?")){
                    Element.remove('tr_'+ despesa);
                    Element.remove('trPlanoCusto_'+ despesa);
                    Element.remove('trContaDespesa_'+ despesa);
                    Element.remove('trDespesas_'+ despesa);
                    
            }
        }
        
        function gerarContratoFrete(){
            if($("chk_carta_automatica_coleta").checked){
                $("linhaValorCarga").style.display = "none";
            }else{
                $("linhaValorCarga").style.display = "";
            }
        }
        
        function incluiDespesaCarta(){
            $("trDespesaCarta").style.display = "";
                var descricaoClassName = ((countDespesaCarta % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1");
            countDespesaCarta++;
            var trDespCarta = Builder.node("TR",{name:"trDespCarta_"+countDespesaCarta, id:"trDespCarta_"+countDespesaCarta, className:descricaoClassName});
                //TD Lixo
            var tdDespLixo = Builder.node("TD",{width:"2%"});
                var imgDespLixo = Builder.node("IMG",{src:"img/lixo.png", onClick:"removerDespCarta("+countDespesaCarta+",true);"});
            tdDespLixo.appendChild(imgDespLixo);

                //TD Valor
            var tdDespValor = Builder.node("TD",{width:"8%"});
            var vlDespCarta = Builder.node("INPUT",{type:"text",id:"vlDespCarta_"+countDespesaCarta, name:"vlDespCarta_"+countDespesaCarta, size:"5", maxLength:"12", value: "0.00", className:"fieldmin", onchange: "seNaoFloatReset($('vlDespCarta_"+countDespesaCarta+"'), 0.00);calcularFreteCarreteiro();"});
            tdDespValor.appendChild(vlDespCarta);

                //TD Fornecedor
            var tdDespForn = Builder.node("TD",{width:"45%"});
            var idFornDespCarta = Builder.node("INPUT",{type:"hidden",id:"idFornDespCarta_"+countDespesaCarta, name:"idFornDespCarta_"+countDespesaCarta, size:"10", maxLength:"60", value: "0", className:"inputReadOnly8pt", readOnly:true});
            var fornDespCarta = Builder.node("INPUT",{type:"text",id:"fornDespCarta_"+countDespesaCarta, name:"fornDespCarta_"+countDespesaCarta, size:"26", maxLength:"60", value: "Fornecedor", className:"inputReadOnly8pt", readOnly:true});
            var btFornDespCarta = Builder.node("INPUT",{className:"botoes", id:"localizaFornecedorDesp_"+countDespesaCarta, name:"localizaFornecedorDesp_"+countDespesaCarta, type:"button", value:"...", onClick:"javascript:window.open('./localiza?acao=consultar&idlista=21','Fornecedor_Contrato_Frete_"+countDespesaCarta+"','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');"});
            tdDespForn.appendChild(idFornDespCarta);
            tdDespForn.appendChild(fornDespCarta);
            tdDespForn.appendChild(btFornDespCarta);

                //TD Plano
            var tdDespPlano = Builder.node("TD",{width:"45%"});
            var idPlanoDespCarta = Builder.node("INPUT",{type:"hidden",id:"idPlanoDespCarta_"+countDespesaCarta, name:"idPlanoDespCarta_"+countDespesaCarta, size:"10", maxLength:"60", value: "0", className:"inputReadOnly8pt", readOnly:true});
            var planoDespCarta = Builder.node("INPUT",{type:"text",id:"planoDespCarta_"+countDespesaCarta, name:"planoDespCarta_"+countDespesaCarta, size:"26", maxLength:"60", value: "Plano Custo", className:"inputReadOnly8pt", readOnly:true});
            var btPlanoDespCarta = Builder.node("INPUT",{className:"botoes", id:"localizaPlanoDesp_"+countDespesaCarta, name:"localizaPlanoDesp_"+countDespesaCarta, type:"button", value:"...", onClick:"javascript:window.open('./localiza?acao=consultar&idlista=20','Plano_Contrato_Frete_"+countDespesaCarta+"','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');"});
            tdDespPlano.appendChild(idPlanoDespCarta);
            tdDespPlano.appendChild(planoDespCarta);
            tdDespPlano.appendChild(btPlanoDespCarta);

            trDespCarta.appendChild(tdDespLixo);
            trDespCarta.appendChild(tdDespValor);
            trDespCarta.appendChild(tdDespForn);
            trDespCarta.appendChild(tdDespPlano);

                $("tbDespesaCarta").appendChild(trDespCarta);

                //Adicionando a segunda linha
            var trDespCarta2 = Builder.node("TR",{name:"trDespCarta2_"+countDespesaCarta, id:"trDespCarta2_"+countDespesaCarta});
                var tdDespCarta2 = Builder.node("TD",{colSpan:"4"});
                var tblDespCarta2 = Builder.node("TABLE",{width:"100%"});
                var tbdDespCarta2 = Builder.node("TBODY");
            var trDespCarta2_1 = Builder.node("TR",{className:descricaoClassName});

                //TD isPago
            var tdDespPago = Builder.node("TD",{width:"29%"});
            var DespPago = Builder.node("INPUT",{type:"radio", id:"DespPago_"+countDespesaCarta, name:"DespPago_"+countDespesaCarta, onClick:"$('DespPagar_"+countDespesaCarta+"').checked = !this.checked;getFpagDespCarta("+countDespesaCarta+");"});
            var lbDespPago = Builder.node("LABEL",{id:"lbDespPago_"+countDespesaCarta, name:"lbDespPago_"+countDespesaCarta});
            var DespPagar = Builder.node("INPUT",{type:"radio", id:"DespPagar_"+countDespesaCarta, name:"DespPagar_"+countDespesaCarta, checked:"true", onClick:"$('DespPago_"+countDespesaCarta+"').checked = !this.checked;getFpagDespCarta("+countDespesaCarta+");"});
            var lbDespPagar = Builder.node("LABEL",{id:"lbDespPagar_"+countDespesaCarta, name:"lbDespPagar_"+countDespesaCarta});
            tdDespPago.appendChild(DespPago);
            tdDespPago.appendChild(lbDespPago);
            tdDespPago.appendChild(DespPagar);
            tdDespPago.appendChild(lbDespPagar);

                //TD vencimento
            var tdDespVencimento = Builder.node("TD",{width:"71%"});
            var lbDespVencimento = Builder.node("LABEL",{id:"lbDespVencimento_"+countDespesaCarta, name:"lbDespVencimento_"+countDespesaCarta});
            var vlDespVencimento = Builder.node("INPUT",{type:"text",id:"vlDespVencimento_"+countDespesaCarta, name:"vlDespVencimento_"+countDespesaCarta, size:"9", maxLength:"10", value: "<%=(Apoio.getDataAtual())%>", className:"fieldDate", style:"font-size:8pt;", onChange:"javascript:alertInvalidDate(this);"});
            var contaDespCarta = Builder.node("SELECT",{id:"contaDespCarta_"+countDespesaCarta, name:"contaDespCarta_"+countDespesaCarta, className:"fieldMin", style:"width:120px;", onChange:"getFpagDespCarta("+countDespesaCarta+");"});
                <%if (cfg.isCartaFreteAutomaticaColeta() && acao.equals("iniciar")){
                        BeanConsultaConta contaAd = new BeanConsultaConta();
                        contaAd.setConexao(Apoio.getUsuario(request).getConexao());
                        contaAd.mostraContas(0, true, limitarUsuarioVisualizarConta, idUsuario);
                        ResultSet rsCDespCarta = contaAd.getResultado();
                        while (rsCDespCarta.next()){%>
                                var optionContaDespCarta = Builder.node("OPTION",{value:"<%=rsCDespCarta.getString("idconta")%>"},"<%=rsCDespCarta.getString("numero") +"-"+ rsCDespCarta.getString("digito_conta") +" / "+ rsCDespCarta.getString("banco")%>");
                                contaDespCarta.appendChild(optionContaDespCarta);
                        <%}rsCDespCarta.close();
                }%>
                var chqDespCarta = Builder.node("INPUT",{type:"checkbox", id:"chqDespCarta_"+countDespesaCarta, name:"chqDespCarta_"+countDespesaCarta, onClick:"getFpagDespCarta("+countDespesaCarta+");", checked:"true"});
                var lbChqDespCarta = Builder.node("LABEL",{id:"lbChqDespCarta_"+countDespesaCarta, name:"lbChqDespCarta_"+countDespesaCarta});
                var docDespCarta = Builder.node("INPUT",{type:"text",id:"docDespCarta_"+countDespesaCarta, name:"docDespCarta_"+countDespesaCarta, size:"10", maxLength:"12", value: "", className:"fieldmin"});
                var docDespCarta_cb = Builder.node("SELECT",{id:"docDespCarta_cb_"+countDespesaCarta, name:"docDespCarta_cb_"+countDespesaCarta, className:"fieldMin"});

                tdDespVencimento.appendChild(lbDespVencimento);
                tdDespVencimento.appendChild(vlDespVencimento);
                tdDespVencimento.appendChild(contaDespCarta);
                tdDespVencimento.appendChild(chqDespCarta);
                tdDespVencimento.appendChild(lbChqDespCarta);
                tdDespVencimento.appendChild(docDespCarta);
                tdDespVencimento.appendChild(docDespCarta_cb);

            trDespCarta2_1.appendChild(tdDespPago);
            trDespCarta2_1.appendChild(tdDespVencimento);
            tbdDespCarta2.appendChild(trDespCarta2_1);
            tblDespCarta2.appendChild(tbdDespCarta2);
            tdDespCarta2.appendChild(tblDespCarta2);

            trDespCarta2.appendChild(tdDespCarta2);

                $("tbDespesaCarta").appendChild(trDespCarta2);

                $("lbDespPago_"+countDespesaCarta).innerHTML = "Pago";
                $("lbDespPagar_"+countDespesaCarta).innerHTML = "A Pagar";
                $("lbDespVencimento_"+countDespesaCarta).innerHTML = "Vencimento:";
                $("lbChqDespCarta_"+countDespesaCarta).innerHTML = "Cheque    ";
                applyFormatter(document, $("vlDespVencimento_"+countDespesaCarta));
                getFpagDespCarta(countDespesaCarta);

                $("countDespesaCarta").value = countDespesaCarta;

        }

        function getFpagDespCarta(idxCarta){
            var isPago = $('DespPago_'+idxCarta).checked;
            $('vlDespVencimento_'+idxCarta).style.display = 'none';
            $("lbDespVencimento_"+idxCarta).style.display = 'none';
            $('contaDespCarta_'+idxCarta).style.display = 'none';
            $("chqDespCarta_"+idxCarta).style.display = 'none';
            $("lbChqDespCarta_"+idxCarta).style.display = 'none';
            $('docDespCarta_'+idxCarta).style.display = 'none';
            $('docDespCarta_cb_'+idxCarta).style.display = 'none';
            if (isPago){
                    $('contaDespCarta_'+idxCarta).style.display = '';
                    $("chqDespCarta_"+idxCarta).style.display = '';
                    $("lbChqDespCarta_"+idxCarta).style.display = '';
                    if (<%=cfg.isControlarTalonario()%> && $("chqDespCarta_"+idxCarta).checked){
                            $('docDespCarta_cb_'+idxCarta).style.display = '';
                            function e(transport){

                                    var textoresposta = transport.responseText;

                                    carregarAjaxTalaoCheque(textoresposta, $('docDespCarta_cb_'+idxCarta));
                                    
                            }//funcao e()

                            tryRequestToServer(
                                    function(){
                                            new Ajax.Request("TalaoChequeControlador?acao=proxCheque&setor=o&idConta="+$('contaDespCarta_'+idxCarta).value,{method:'post', onSuccess: e, onError: e});
                                    }
                            );
                            
                    }else{
                            $('docDespCarta_'+idxCarta).style.display = '';
                    }
            }else{
                    $('vlDespVencimento_'+idxCarta).style.display = '';
                    $("lbDespVencimento_"+idxCarta).style.display = '';
            }
}
        
        function calculaSest(baseCalculo){
            var aliquota = parseFloat(<%=cfg.getSestSenatAliq()%>);
            var sest = new Sest(baseCalculo, aliquota);
            if (isRetencaoImpostoOpeCFe()) {
                $("valorSESTInteg").value = formatoMoeda(sest.valorFinal);
            } else {
                $("baseSEST").value = formatoMoeda(sest.baseCalculo);
                $("aliqSEST").value = formatoMoeda(sest.aliquota);
                $("valorSEST").value = formatoMoeda(sest.valorFinal);
            }
            return sest;
        }
        
        function calculaIR(inss){
            var faixas = new Array();
            faixas[0] = new Faixa(0, parseFloat(<%=cfg.getIrDe1()%>), 0, 0);
            faixas[1] = new Faixa(parseFloat(<%=cfg.getIrDe1()%>), parseFloat(<%=cfg.getIrAte1()%>), parseFloat(<%=cfg.getIrAliq1()%>), parseFloat(<%=cfg.getIrdeduzir1()%>));
            faixas[2] = new Faixa(parseFloat(<%=cfg.getIrDe2()%>), parseFloat(<%=cfg.getIrAte2()%>), parseFloat(<%=cfg.getIrAliq2()%>), parseFloat(<%=cfg.getIrDeduzir2()%>));
            faixas[3] = new Faixa(parseFloat(<%=cfg.getIrDe3()%>), parseFloat(<%=cfg.getIrAte3()%>), parseFloat(<%=cfg.getIrAliq3()%>), parseFloat(<%=cfg.getIrDeduzir3()%>));
            faixas[4] = new Faixa(parseFloat(<%=cfg.getIrAte3()%>), 99999999, parseFloat(<%=cfg.getIrAliqAcima()%>), parseFloat(<%=cfg.getIrdeduzirAcima()%>));
            var baseIRJaRetida = $('base_ir_prop_retido').value;
            var valorIRJaRetido = $('ir_prop_retido').value;
            var isDeduzirInssIr = '<%=cfg.isDeduzirINSSIR()%>';
            var ir = new IR(inss.valorFrete, percentualBase, faixas, inss.valorFinal, baseIRJaRetida, valorIRJaRetido, 0, 0,false, isDeduzirInssIr );
            $("valorIR").value = formatoMoeda(ir.valorFinal);
            $("baseIR").value = formatoMoeda(ir.baseCalculo);
            $("aliqIR").value = formatoMoeda(ir.aliquota); var percentualBase = parseFloat(<%=cfg.getIrAliqBaseCalculo()%>);
            var faixas = new Array();
            faixas[0] = new Faixa(0, parseFloat(<%=cfg.getIrDe1()%>), 0, 0);
            faixas[1] = new Faixa(parseFloat(<%=cfg.getIrDe1()%>), parseFloat(<%=cfg.getIrAte1()%>), parseFloat(<%=cfg.getIrAliq1()%>), parseFloat(<%=cfg.getIrdeduzir1()%>));
            faixas[2] = new Faixa(parseFloat(<%=cfg.getIrDe2()%>), parseFloat(<%=cfg.getIrAte2()%>), parseFloat(<%=cfg.getIrAliq2()%>), parseFloat(<%=cfg.getIrDeduzir2()%>));
            faixas[3] = new Faixa(parseFloat(<%=cfg.getIrDe3()%>), parseFloat(<%=cfg.getIrAte3()%>), parseFloat(<%=cfg.getIrAliq3()%>), parseFloat(<%=cfg.getIrDeduzir3()%>));
            faixas[4] = new Faixa(parseFloat(<%=cfg.getIrAte3()%>), 99999999, parseFloat(<%=cfg.getIrAliqAcima()%>), parseFloat(<%=cfg.getIrdeduzirAcima()%>));
            var baseIRJaRetida = $('base_ir_prop_retido').value;
            var valorIRJaRetido = $('ir_prop_retido').value;

            var ir = new IR(inss.valorFrete, percentualBase, faixas, inss.valorFinal, baseIRJaRetida, valorIRJaRetido, 0, 0,false, isDeduzirInssIr );
            if (isRetencaoImpostoOpeCFe()) {
                $("valorIRInteg").value = formatoMoeda(ir.valorFinal);
            } else {
                $("valorIR").value = formatoMoeda(ir.valorFinal);
                $("baseIR").value = formatoMoeda(ir.baseCalculo);
                $("aliqIR").value = formatoMoeda(ir.aliquota);
           }
        }
        
        function calculaInss(){
            var valorFrete = parseFloat($("cartaValorFrete").value);

            if (${configuracao.deduzirImpostosOutrasRetencoesCfe}) {
                var valor = parseFloat($('cartaRetencoes').value);

                if (isNaN(valor)) {
                    valor = 0;
                }

                valorFrete -= valor;
            }

        var percentualBase = parseFloat(<%=cfg.getInssAliqBaseCalculo()%>);
        var valorJaRetido = parseFloat($("inss_prop_retido").value);
        var teto = parseFloat(<%=cfg.getTetoInss()%>);

        var faixas = new Array();

        faixas[0] = new Faixa(0, <%=cfg.getInssAte()%>, <%=cfg.getInssAliqAte()%>);
        faixas[1] = new Faixa(<%=cfg.getInssDe1()%>, <%=cfg.getInssAte1()%>, <%=cfg.getInssAliq1()%>);
        faixas[2] = new Faixa(<%=cfg.getInssDe2()%>, <%=cfg.getInssAte2()%>, <%=cfg.getInssAliq2()%>);
        faixas[3] = new Faixa(<%=cfg.getInssDe3()%>, <%=cfg.getInssAte3()%>, <%=cfg.getInssAliq3()%>);
		var baseINSSJaRetida = $('base_inss_prop_retido').value;
		var valorINSSJaRetido = $('inss_prop_retido').value;
        var inss = new Inss(valorFrete, percentualBase, faixas, teto, valorJaRetido, baseINSSJaRetida);
        if (isRetencaoImpostoOpeCFe()) {
            $("valorINSSInteg").value = formatoMoeda(inss.valorFinal);
        } else {
            $("baseINSS").value = formatoMoeda(inss.baseCalculo);
            $("aliqINSS").value = formatoMoeda(inss.aliquota);
            $("valorINSS").value = formatoMoeda(inss.valorFinal);
        }

        return inss;
    }
    
        function alteraFpag(tipo){
	if (tipo == 'a'){
		$('agente').style.display = 'none';
		$('localiza_agente_adiantamento').style.display = 'none';
		$('contaAdt').style.display = 'none';
		if ($('cartaFPagAdiantamento').value == '8'){ //Carta frete
			$('agente').style.display = '';
			$('localiza_agente_adiantamento').style.display = '';
		}else if($('cartaFPagAdiantamento').value == '3' && <%=cfg.isBaixaAdiantamentoCartaFrete()%>){
			$('contaAdt').style.display = '';
			if(<%=cfg.isControlarTalonario()%>){
				function e(transport){
					var textoresposta = transport.responseText
					carregarAjaxTalaoCheque(textoresposta, $('cartaDocAdiantamento_cb'));
				}//funcao e()
				$('cartaDocAdiantamento_cb').style.display = "";

				tryRequestToServer(function(){
					new Ajax.Request("TalaoChequeControlador?acao=proxCheque&setor=o&idConta="+$('contaAdt').value,{method:'post', onSuccess: e, onError: e});
				});
			}
		}
	}else{
		$('agentesaldo').style.display = 'none';
		$('localiza_agente_saldo').style.display = 'none';
		if ($('cartaFPagSaldo').value == '8'){
			$('agentesaldo').style.display = '';
			$('localiza_agente_saldo').style.display = '';
		}
	}
}

         function calcularFreteCarreteiro(){
             var PercFreteCadastroProp = parseFloat($('percentual_ctrc_contrato_frete').value);
             if (PercFreteCadastroProp > 0){
		var totalFreteCadastroProp = 0;
		var totalSeguroProp = 0;
		if ($('is_urbano2').checked){
		   totalSeguroProp = parseFloat(parseFloat($('vlmercadoria').value) * (parseFloat($('taxa_roubo_urbano').value) + parseFloat($('taxa_tombamento_urbano').value)) / 100);
		}else{
		   totalSeguroProp = parseFloat(parseFloat($('vlmercadoria').value) * (parseFloat($('taxa_roubo').value) + parseFloat($('taxa_tombamento').value)) / 100);
		}
		var totalDespViagemProp = 0;
		for(var di = 0; di <= parseInt(countADV); di++){
			if ($('trADV_'+di) != null){
				totalDespViagemProp += parseFloat($('vlADV_'+di).value);
			}
		}
		for(var dd = 0; dd <= parseInt(countDespesaADV); dd++){
			if ($('trDespADV_'+dd) != null){
				totalDespViagemProp += parseFloat($('vlDespADV_'+dd).value);
			}
		}
		for(var dc = 0; dc <= parseInt(countDespesaCarta); dc++){
			if ($('trDespCarta_'+dc) != null){
				totalDespViagemProp += parseFloat($('vlDespCarta_'+dc).value);
			}
		}

		var totalLiquidoProp = parseFloat(parseFloat($('total').value) - parseFloat($('icms').value) - parseFloat(totalSeguroProp) - parseFloat(totalDespViagemProp));
		totalFreteCadastroProp = parseFloat(totalLiquidoProp * parseFloat(PercFreteCadastroProp) / 100) + parseFloat($("rota_taxa_fixa").value);
		$('cartaValorFrete').value = formatoMoeda(totalFreteCadastroProp);
		$('valor_maximo_rota').value = formatoMoeda(totalFreteCadastroProp);
	 }
    var freteCarreteiro = parseFloat($('cartaValorFrete').value);
    var freteOutros = parseFloat($('cartaOutros').value);
    var fretePedagio = parseFloat($('cartaPedagio').value);
    var freteLiquido = 0;

	calculaImpostos();

     freteLiquido = parseFloat(freteCarreteiro + freteOutros + fretePedagio - parseFloat($('cartaImpostos').value) - parseFloat(colocarPonto($('cartaRetencoes').value)) - parseFloat($("abastecimentos").value));

     $('cartaLiquido').value = formatoMoeda(freteLiquido);

     if ($('tipo_desconto_prop').value == '2' && parseFloat($('debito_prop').value) > 0 && parseFloat($('percentual_desconto_prop').value) > 0) {
         // ^--- Sobre o valor do frete
         var vlCC = (freteCarreteiro * parseFloat(colocarVirgula($('percentual_desconto_prop').value))) / 100;

         if (vlCC > parseFloat($('debito_prop').value)) {
             vlCC = $('debito_prop').value;
         }

         freteLiquido = freteLiquido - vlCC;
     }

	 $('cartaValorAdiantamento').value = formatoMoeda(parseFloat(freteLiquido) * parseFloat($('perc_adiant').value) / 100);
	 var sld = parseFloat(freteLiquido) - parseFloat($('cartaValorAdiantamento').value);
	 sld = parseFloat(sld) < 0 ? 0 : sld;

	 //Verificando se vai descontar do conta corrente
	 if (parseFloat($('debito_prop').value) > 0 && parseFloat($('percentual_desconto_prop').value) > 0 ){
		$('trCartaCC').style.display = '';
         if ($('tipo_desconto_prop').value != '2') {
             // ^--- Se não for sobre o valor do frete
             var percentual_desconto = parseFloat($('percentual_desconto_prop').value);
             var vlCC = (sld == 0 ? 0 : parseFloat(parseFloat(percentual_desconto) * parseFloat(sld) / 100));
             if (parseFloat(vlCC) > parseFloat($('debito_prop').value)) {
                 vlCC = $('debito_prop').value;
             }
             sld = parseFloat(parseFloat(formatoMoeda(sld)) - parseFloat(formatoMoeda(vlCC)));
         }
		$('cartaValorCC').value = formatoMoeda(vlCC);
	 }else{
		$('trCartaCC').style.display = 'none';
		$('cartaValorCC').value = '0.00';
	 }

	 $('cartaValorSaldo').value = formatoMoeda(parseFloat(sld));
	 alteraFpag('s');

}
        
        function validarFreteCarreteiro(){
        var freteCarreteiroX = parseFloat($('cartaValorFrete').value);
        var freteMaximoCarreteiroX = parseFloat($('valor_maximo_rota').value);
        if (<%=nvAlFrete < 4%>){
                    if (parseFloat(freteCarreteiroX) > parseFloat(freteMaximoCarreteiroX)){
                            alert('Você não tem privilégio suficiente para aumentar o valor do frete');
                            $('cartaValorFrete').value = formatoMoeda(freteMaximoCarreteiroX);
                    }
	}
}
        
        function calculaImpostos(){
            calcularRetencoes();
        var isReter = $("chk_reter_impostos").checked;
            if(isReter){
            var inss = calculaInss();
            calculaSest(inss.baseCalculo);
            calculaIR(inss);
		$('cartaImpostos').value = formatoMoeda(parseFloat($("valorINSS").value) + parseFloat($("valorSEST").value) + parseFloat($("valorIR").value));
            }else{
		$('cartaImpostos').value = '0.00';
		$("valorINSS").value = '0.00';
		$("valorSEST").value = '0.00';
		$("valorIR").value = '0.00';
            }
}

  function pesquisarAuditoria() {  
        if(countLog!=null  && countLog!=undefined ){
                for (var i = 1; i <= countLog; i++) {
                    if ($("tr1Log_" + i) != null) {
                        Element.remove(("tr1Log_" + i));
                    }
                    if ($("tr2Log_" + i) != null) {
                        Element.remove(("tr2Log_" + i));
                    }
                }}
                countLog = 0;
                var rotina = "pedidos";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = <%=(carregacol ?  cadcol.getColeta().getId() : 0)%>;
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
    
    function setDataAuditoria(){
            $("dataDeAuditoria").value="<%=carregacol ? Apoio.getDataAtual() :  "" %>" ;   
            $("dataAteAuditoria").value="<%=carregacol ? Apoio.getDataAtual() : "" %>" ;   

        }

    function preparaIniciarCfe(){
        var cartaValorFrete = 0;
        if ($('cartaValorFrete') !== null && $('cartaValorFrete') !== undefined) {
            if (parseFloat($('percentual_valor_cte_calculo_cfe').value) <= 0) {
                if ($('tipo_valor_rota').value == 'f') {
                    cartaValorFrete = parseFloat($('valor_rota').value);
                } else if ($('tipo_valor_rota').value == 'p') {
                    var pesoColeta = parseFloat($('totalPeso').value) > 0 ? parseFloat($('totalPeso').value) : parseFloat($('pesoSolicitado').value);
                    cartaValorFrete = roundABNT(parseFloat(parseFloat($('valor_rota').value) * (pesoColeta / 1000)), 2);
                    $('valor_maximo_rota').value = formatoMoeda($('cartaValorFrete').value);
                } else if ($('tipo_valor_rota').value == 'c') {
                    cartaValorFrete = roundABNT(parseFloat(parseFloat($('vlcombinado').value) * (parseFloat($('valor_rota').value) / 100)), 2);
                    $('valor_maximo_rota').value = formatoMoeda($('cartaValorFrete').value);
                } else if ($('tipo_valor_rota').value == 'n') {
                    var valormercadoria = (parseFloat($('totalNF').value) > 0 ? parseFloat($('totalNF').value) : parseFloat($('mercadoriasolicitada').value));
                    cartaValorFrete = roundABNT(parseFloat(valormercadoria * (parseFloat($('valor_rota').value) / 100)), 2);
                    $('valor_maximo_rota').value = formatoMoeda($('cartaValorFrete').value);
                } else if ($('tipo_valor_rota').value == 'n') {
                    var valormercadoria = (parseFloat($('totalNF').value) > 0 ? parseFloat($('totalNF').value) : parseFloat($('mercadoriasolicitada').value));
                    cartaValorFrete = roundABNT(parseFloat(valormercadoria * (parseFloat($('valor_rota').value) / 100)), 2);
                    $('valor_maximo_rota').value = formatoMoeda($('cartaValorFrete').value);
                } else if ($('tipo_valor_rota').value == 'k') {
                    cartaValorFrete = roundABNT(parseFloat((parseFloat($('distancia_km').value)) * (parseFloat($('valor_rota').value))), 2);
                    $('valor_maximo_rota').value = formatoMoeda($('cartaValorFrete').value);
                }

                if (cartaValorFrete < parseFloat($('rota_valor_minimo').value)) {
                    cartaValorFrete = parseFloat($('rota_valor_minimo').value);
                }
            } else {
                cartaValorFrete = calcularTabelaMotorista();
            }
            $('cartaValorFrete').value = formatoMoeda(cartaValorFrete + parseFloat($("rota_taxa_fixa").value));
            validarFreteCarreteiro();
            calcularFreteCarreteiro();
        }
    }

    function calcularAdiantamento(){
        if (<%=nivelUserAdiantamento == 0%>){
                var percPermitido = $('perc_adiant').value;
                var totalAdtmo = $('cartaValorAdiantamento').value;
                var xTotalLiquido = $('cartaLiquido').value;
                var percAdtmo = parseFloat(totalAdtmo) * 100 / parseFloat(xTotalLiquido);
                if (parseFloat(percAdtmo) > parseFloat(percPermitido)){
                    alertMsg('Para esse motorista só é permitido ' + percPermitido + '% de adiantamento!');
                    $('cartaValorAdiantamento').value = (formatoMoeda(parseFloat($("cartaLiquido").value) * $('perc_adiant').value / 100));
                    $("cartaValorSaldo").value = formatoMoeda(parseFloat($("cartaLiquido").value) - parseFloat($("cartaValorAdiantamento").value));
                return false;
            }else{$("cartaValorSaldo").value = formatoMoeda(parseFloat($("cartaLiquido").value) - parseFloat($("cartaValorAdiantamento").value));}
        }else{$("cartaValorSaldo").value = formatoMoeda(parseFloat($("cartaLiquido").value) - parseFloat($("cartaValorAdiantamento").value)) ;}
    }

    function calcularSaldo() {
           // se o saldo for positivo:
           if((parseFloat($("valorFrete").value) - parseFloat($("valorAdiantamento").value)) > 0 ){
               // Saldo = Frete - Adiantamento;
               $("valorSaldo").value = (parseFloat($("valorFrete").value) - parseFloat($("valorAdiantamento").value));
               seNaoFloatReset($("valorSaldo"), '0.00');
           }else{
               if ((parseFloat($("valorFrete").value) - parseFloat($("valorAdiantamento").value)) < 0 ){
                   // mesma mensagem da tela de contrato de frete:
                   alert("Valor de pagamento não pode ser menor que 0 (zero)!");
                   $("valorSaldo").value = '0.00';
               }
           }
    }
</script>

<html>
    <head>
        <script src="assets/js/jquery-1.9.1.min.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="script/coleta.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script defer src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/assets/js/jquery-ui.min.js?v=${random.nextInt()}" type="text/javascript"></script>
        
        <script language="javascript" src="script/<%=Apoio.noCacheScript("funcoes.js")%>" type=""></script>
        <script language="javascript" src="script/<%=Apoio.noCacheScript("funcoesTelaColeta.js")%>" type=""></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("notaFiscal-util.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("builder.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("prototype_1_6.js")%>" type="text/javascript"></script>
        <script language="javascript" type="text/javascript" src="script/<%=Apoio.noCacheScript("mascaras.js")%>"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("impostos.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("LogAcoesAuditoria.js")%>" type="text/javascript"></script>
        <script type="text/javascript" src="script/<%=Apoio.noCacheScript("fabtabulous.js")%>"></script>
        <script type="text/javascript" src="script/<%=Apoio.noCacheScript("funcoesTelaColeta.js")%>"></script>

        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("servicos-util_backup.js")%>" type="text/javascript"></script>
        <script src="assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">

        <title>Webtrans - Lan. Coleta / OS</title>
        <link href="css/coleta.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link href="estilo.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
        <link href="assets/css/inputs-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="stylesheets/tabs.css?v=${random.nextInt()}" type="text/css" media="all">
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

    <body onLoad="javascript:aoCarregar();applyFormatter();setDataAuditoria();" onKeyUp="executarAtalhos(event.keyCode);">
        <form method="post" action="./cadcoleta" id="formulario" target="pop" accept-charset="ISO-8859-1">
            <input type="hidden" name="doomAuxiliar" id="doomAuxiliar" value="0">
            <input type="hidden" name="id" id="id" value="0">
            <input type="hidden" name="descricao_produto" id="descricao_produto" value="">
            <input type="hidden" name="acao" id="acao" value="<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>">
            <input type="hidden" id="idxOco" name="idxOco" value="0">
            <input type="hidden" id="objCountIdxNotes" name="objCountIdxNotes" value="0">
            <input type="hidden" id="indexCob" name="indexCob" value="0">
            <input type="hidden" id="indAjud" name="indAjud" value="0">
            <input type="hidden" id="is_obriga_carreta" name="is_obriga_carreta" value="<%=(carregacol && col.getVeiculo().getTipo_veiculo().isObrigaCarreta() ? "t" : "f")%>">
            <input type="hidden" id="idcoleta" name="idcoleta" value="<%=(carregacol ? col.getId() : 0)%>">
            <!-- Nota fiscal Ocorrência -->
            <input type="hidden" name="idnota_fiscal" id="idnota_fiscal" value="0">
            <input type="hidden" name="numero_nf" id="numero_nf" value="">
            <!-- Grande gambiarra -->
            <input type="hidden" id="dest_cidade" name="dest_cidade" value="">
            <input type="hidden" id="dest_uf" name="dest_uf" value="">

            <input type="hidden" id="cidade_destino_id" name="cidade_destino_id" value="<%=(carregacol ? col.getCidadeDestino().getIdcidade() : 0)%>">
            <!-- fim da Grande gambiarra -->

            <!-- COMPARATIVO PARA SALVA NO BANCO (SE USUARIO ALTEROU)-->
            <input type="hidden" id="end_cli" value="<%=(carregacol ? col.getLocalColeta() : "")%>">
            <input type="hidden" id="bai_cli" value="">
            <input type="hidden" id="cid_cli" value="">
            <input type="hidden" id="fone_cli" value="<%=(carregacol ? col.getCliente().getFone() : "")%>">

            <!-- Endereço Coleta -->
            <input type="hidden" name="idcidade_col" id="idcidade_col" value="0">
            <input type="hidden" name="uf_col" id="uf_col" value="">
            <input type="hidden" name="cidade_col" id="cidade_col" value="">
            <input type="hidden" id="endereco_col" name="endereco_col" value="">
            <input type="hidden" id="bairro_col" name="bairro_col" value="">
            <input type="hidden" id="cidade_col" name="cidade_col" value="">

            <!-- Campos ocultos -->
            <input type="hidden" name="rem_idcidade" id="rem_idcidade" value="<%=(carregacol ? col.getCliente().getCidade().getIdcidade() : 0)%>">
            <input type="hidden" name="idcidadeorigem" id="idcidadeorigem" value="<%=(carregacol ? col.getCliente().getCidade().getIdcidade() : 0)%>">
            <input type="hidden" name="codIbgeOrigem" id="codIbgeOrigem" value="0">
            <input type="hidden" name="uf_origem" id="uf_origem" value="">
            <input type="hidden" name="cid_origem" id="cid_origem" value="">
            <input type="hidden" name="bloqueado" id="bloqueado" value="">
            <input type="hidden" name="motivobloqueio" id="motivobloqueio" value="">

            <input type="hidden" name="peso_solicitado" id="peso_solicitado" value="">
            <input type="hidden" name="volume_solicitado" id="volume_solicitado" value="">
            <input type="hidden" name="orcamento_id" id="orcamento_id" value="<%=(carregacol ? col.getOrcamento().getId() : 0)%>">

            <input type="hidden" id="idcidadedestino" value="<%=(carregacol ? col.getCidadeDestino().getIdcidade() : 0)%>">
            <input type="hidden" id="codIbgeDestino" name="codIbgeDestino" value="<%=(carregacol ?  col.getDestinatario().getCidadeCol().getCod_ibge(): "")%>">
            <!-- id do ajudante -->
            <input type="hidden" id="idajudante" value="">
            <input type="hidden" id="nome" value="">
            <input type="hidden" id="fone1" value="">
            <input type="hidden" id="fone2" value="">
            <input type="hidden" id="vldiaria" value="">
            <!-- id do remetente -->
            <input type="hidden" id="idremetente" name="idremetente" value="<%=(carregacol ? String.valueOf(col.getCliente().getIdcliente()) : "0")%>">
            <input type="hidden" id="idremetente_cl" name="idremetente_cl" value="<%=(carregacol ? String.valueOf(col.getCliente().getIdcliente()) : "0")%>">
            <input type="hidden" id="idremetente_coleta" name="idremetente_coleta" value="<%=(carregacol ? String.valueOf(col.getRemetenteColeta().getIdcliente()) : "0")%>">
            <input type="hidden" id="idarmador" name="idarmador" value="<%=(carregacol ? String.valueOf(col.getArmador().getIdcliente()) : "0")%>">
            <input type="hidden" id="iddestinatario" name="iddestinatario" value="0">
            <input type="hidden" id="iddestinatario_cl" name="iddestinatario_cl" value="<%=(carregacol ? String.valueOf(col.getDestinatario().getIdcliente()) : "0")%>">
            <input type="hidden" id="iddestinatario_entrega" name="iddestinatario_entrega" value="<%=(carregacol ? String.valueOf(col.getDestinatarioEntrega().getIdcliente()) : "0")%>">
            <input type="hidden" id="referencia_coleta" name="referencia_coleta" value="">
            <input type="hidden" id="tipo_documento_padrao" value="<%= (carregacol? col.getCliente().getTipoDocumentoPadrao() : "NE") %>">
            <!-- id do motorista -->
            <input type="hidden" id="idmotorista" name="idmotorista" value="<%=(carregacol ? String.valueOf(col.getMotorista().getIdmotorista()) : "0")%>">
            <!-- id dos veículos -->
            <input type="hidden" id="idveiculo" name="idveiculo" value="<%=(carregacol ? String.valueOf(col.getVeiculo().getIdveiculo()) : "0")%>">
            <input type="hidden" id="idcarreta" name="idcarreta" value="<%=(carregacol ? String.valueOf(col.getCarreta().getIdveiculo()) : "0")%>">
            <input type="hidden" id="idbitrem" name="idbitrem" value="<%=(carregacol ? String.valueOf(col.getBiTrem().getIdveiculo()) : "0")%>">
            <input type="hidden" id="idtritrem" name="idtritrem" value="<%=(carregacol ? String.valueOf(col.getTriTrem().getIdveiculo()) : "0")%>">
            <input type="hidden" id="is_tac" name="is_tac" value="f">
            
            <input type="hidden" id="categoria_ndd_id" name="categoria_ndd_id" value="0">
            <input type="hidden" id="cod_categoria_ndd" name="cod_categoria_ndd" value="0">
            <input type="hidden" id="categoriaNddVeiculo" name="categoriaNddVeiculo" value="0">
            <input type="hidden" id="categoriaNddCarreta" name="categoriaNddCarreta" value="0">
            <input type="hidden" id="codcategoriaNddVeiculo" name="codcategoriaNddVeiculo" value="<%=(carregacol ? String.valueOf(col.getVeiculo().getBeanCadVeiculo().getCategoriaNdd().getCod()) : "0")%>">
            <input type="hidden" id="codcategoriaNddCarreta" name="codcategoriaNddCarreta" value="<%=(carregacol ? String.valueOf(col.getCarreta().getBeanCadVeiculo().getCategoriaNdd().getCod()) : "0")%>">
            
            <!-- Filial do lancamento -->
            <input type="hidden" name="idfilial" id="idfilial" value="<%=(carregacol ? col.getFilial().getIdfilial() : (nivelUser > 0 ? Apoio.getUsuario(request).getFilial().getIdfilial() : 0))%>">
            <input type="hidden" name="is_retencao_impostos_operadora_cfe" id="is_retencao_impostos_operadora_cfe" value="<%=(carregacol ? col.getFilial().isRetencaoImpostoOperadoraCFe() : (nivelUser > 0 ? Apoio.getUsuario(request).getFilial().isRetencaoImpostoOperadoraCFe() : 0))%>">
            <input type="hidden" name="stUtilizacaoCfe" id="stUtilizacaoCfe" value="<%=Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe()%>">
            <input type="hidden" name="st_utilizacao_cfe" id="st_utilizacao_cfe" value="0">
            <input type="hidden" name="isPedagioRoteirizador" id="isPedagioRoteirizador" value="<%=(carregacol ? (col.isPedagioRoteirizador()) : (Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe()=='D'))%>">
            

            <input name="idmarca" id="idmarca" type="hidden" value="0">
            <input name="descricao" id="descricao" type="hidden" value="">

            <input name="idcfop" id="idcfop" type="hidden" value="0">
            <input name="cfop" id="cfop" type="hidden" value="">
            <input name="codigo_categoria_ndd" id="codigo_categoria_ndd" type="hidden" value="">

            <%-- Análise de crédito  --%>
            <input type="hidden" id="rem_is_bloqueado" value="f">
            <input type="hidden" id="des_is_bloqueado" value="f">
            <input type="hidden" id="con_is_bloqueado" value="f">
            <%-- Tipo de taxa padrao  --%>
            <input type="hidden" id="rem_tipotaxa">
            <input type="hidden" id="dest_tipotaxa">
            <%-- Tipo de veiculo padrao  --%>
            <input type="hidden" id="rem_tipoveiculo">
            <input type="hidden" id="dest_tipoveiculo">
            <%-- Tipo de servico  --%>
            <input type="hidden" id="type_service_id">
            <input type="hidden" id="type_service_descricao">
            <input type="hidden" id="type_service_valor">
            <input type="hidden" id="type_service_quantidade">
            
            <input type="hidden" id="type_service_iss_percent">
            <input type="hidden" id="tax_id">
            <input type="hidden" id="obs_desc" name="obs_desc" value="">
            <input type="hidden" id="is_usa_dias" name="is_usa_dias" value="">
            <input type="hidden" id="embutir_iss">
            <!-- Ocorrencia -->
            <input type="hidden" id="ocorrencia" name="ocorrencia" value="">
            <input type="hidden" id="ocorrencia_id" name="ocorrencia_id" value="">
            <input type="hidden" id="descricao_ocorrencia" name="descricao_ocorrencia" value="">
            <!-- Produto -->
            <input type="hidden" id="produto_id" name="produto_id" value="0">
            <input type="hidden" id="codigo_produto" name="codigo_produto" value="">
            <input type="hidden" id="descricao_produto" name="descricao_produto" value="">
            <input type="hidden" name="produto_base_paletizacao" id="produto_base_paletizacao" value="0">
            <input type="hidden" name="produto_altura_paletizacao" id="produto_altura_paletizacao" value="0">
            
            <input type="hidden" name="fornecedor" id="fornecedor" value="0" size="10" class="inputtexto" /> 
            <input type="hidden" name="idfornecedor" id="idfornecedor" value="0" size="10" class="inputtexto" /> 
            <input type="hidden" name="descricao_historico" id="descricao_historico" value="0" size="10" class="inputtexto" />
            <input type="hidden" name="idhist" id="idhist" value="0" size="10" class="inputtexto" />
            <input type="hidden" name="plcusto_conta_despesa" id="plcusto_conta_despesa" value="0" size="10" class="inputtexto" /> 
            <input type="hidden" name="plcusto_descricao_despesa" id="plcusto_descricao_despesa" value="0" size="10" class="inputtexto" />
            <input type="hidden" name="idplanocusto_despesa" id="idplanocusto_despesa" value="0" size="10" class="inputtexto" /> 
            <input type="hidden" name="id_und_forn" id="id_und_forn" value="0" size="10" class="inputtexto" /> 
            <input type="hidden" name="id_und" id="id_und" value="0" size="10" class="inputtexto" /> 
            <input type="hidden" name="sigla_und_forn" id="sigla_und_forn" value="0" size="10" class="inputtexto" /> 
            <input type="hidden" name="sigla_und" id="sigla_und" value="0" size="10" class="inputtexto" />
            <input type="hidden" name="veiculo_id" id="veiculo_id" value="0" size="10" class="inputtexto" /> 
            <input type="hidden" name="veiculo" id="veiculo" value="0" size="10" class="inputtexto" />
            <input type="hidden" name="idplcustopadrao" id="idplcustopadrao" value="0" size="10" class="inputtexto" />
            <input type="hidden" name="contaplcusto" id="contaplcusto" value="0" size="10" class="inputtexto" /> 
            <input type="hidden" name="descricaoplcusto" id="descricaoplcusto" value="0" size="10" class="inputtexto" />
            <input type="hidden" id="desc_prod" name="desc_prod" value="">
            <!-- Conteudo desc_prod-->
            <input type="hidden" name="os_aberto_veiculo" id="os_aberto_veiculo" value="0">
            <input type="hidden" name="miliSegundos"  id="miliSegundos" value="">
            <input type="hidden" name="cfgPermitirLancamentoOSAbertoVeiculo"  id="cfgPermitirLancamentoOSAbertoVeiculo" value="<%=cfg.getPermitirLancamantoOSAbertoVeiculo()%>">
            <input type="hidden" name="codigo_ibge_origem" id="codigo_ibge_origem" value="<%=(carregacol ? col.getCidadeDestino().getCod_ibge()  : "")%>">
            <input type="hidden" name="codigo_ibge_destino" id="codigo_ibge_destino" value="<%=(carregacol ?  col.getDestinatario().getCidadeCol().getCod_ibge(): "")%>">
            <input type="hidden" name="cod_ibge" id="cod_ibge">    
            <input type="hidden" name="motivo_bloqueio" id="motivo_bloqueio">    
            <input type="hidden" name="is_bloqueado" id="is_bloqueado" value="">    
            <input type="hidden" name="moto_veiculo_bloq_motivo" id="moto_veiculo_bloq_motivo">    
            <input type="hidden" name="is_moto_veiculo_bloq" id="is_moto_veiculo_bloq">    
            <input type="hidden" name="moto_carreta_bloq_motivo" id="moto_carreta_bloq_motivo">    
            <input type="hidden" name="is_moto_carreta_bloq" id="is_moto_carreta_bloq"> 
            <input type="hidden" name="moto_bitrem_bloq_motivo" id="moto_bitrem_bloq_motivo">    
            <input type="hidden" name="moto_tritrem_bloq_motivo" id="moto_tritrem_bloq_motivo">    
            <input type="hidden" name="is_moto_bitrem_bloq" id="is_moto_bitrem_bloq">
            <input type="hidden" name="is_moto_tritrem_bloq" id="is_moto_tritrem_bloq">
            <input type="hidden" name="mensagem_usuario_coleta_rem" id="mensagem_usuario_coleta_rem" value="">
            <input type="hidden" name="mensagem_usuario_coleta_des" id="mensagem_usuario_coleta_des" value="">
            <input type="hidden" name="mensagem_usuario_coleta" id="mensagem_usuario_coleta" value="">
            <input type="hidden" name="is_bloqueado_rem" id="is_bloqueado_rem" value="">    
             
            <input type="hidden" name="maxCidades" id="maxCidades" value="0">    
            <input type="hidden" id="json_taxas" name="json_taxas" class="inputReadOnly8pt" readonly="true">
            <input type="hidden" id="calculo_valor_contrato_frete" name="calculo_valor_contrato_frete" readonly="true">
            <input type="hidden" id="tipo_calculo_percentual_valor_cfe" name="tipo_calculo_percentual_valor_cfe" readonly="true">
            <input type="hidden" id="percentual_valor_cte_calculo_cfe" name="percentual_valor_cte_calculo_cfe" readonly="true">
            <!-- Fim -->

            <img src="img/banner.gif" >
            <br>

            <div align="center">
                <table width="80%" align="center" class="bordaFina" >
                    <tr>
                        <td width="613" align="left">
                            <b>Lan&ccedil;amento de Coleta / OS</b>
                        </td>
                        <%  //se o paramentro vier com valor entao nao pode excluir
                            if ((acao.equals("editar")) && (nivelUser >= 4) && (request.getParameter("ex") == null)) {%>
                        <td width="15">
                            <input name="excluir" type="button" class="botoes" value="Excluir"
                                   onClick="javascript:tryRequestToServer(function(){excluirColeta('<%=(carregacol ? col.getId() : 0)%>');});">
                        </td>
                        <%}%>
                        <td width="56" >
                            <input  name="bt_consultar" type="button" id="bt_consultar" class="botoes" value="Voltar para Consulta" onClick="javascript:tryRequestToServer(function(){voltar();});">
                        </td>
                    </tr>
                </table>
                <br>
                <table width="80%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                    <tr>
                        <td colspan="8" class="tabela">
                            <div align="center">Dados principais </div>
                        </td>
                    </tr>
                    <tr>
                        <td width="9%"  class="TextoCampos">Filial:</td>
                        <td width="18%" class="CelulaZebra2">
                            <input name="fi_abreviatura" type="text" class="inputReadOnly8pt" id="fi_abreviatura" size="13" maxlength="12" readonly="true" 
                                   value="<%=(carregacol ? col.getFilial().getAbreviatura() : (nivelUser > 0 ? Apoio.getUsuario(request).getFilial().getAbreviatura() : ""))%>">

                            <%if (nivelUserFl > 0 && acao.equals("iniciar")) {%>
                            <input name="button2" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FILIAL%>','Filial')" value="...">
                            <%}%>

                        </td>
                        <td width="8%" class="TextoCampos">N&uacute;mero:</td>
                        <td width="10%" class="CelulaZebra2">
                            <input name="numcoleta" type="text" id="numcoleta" size="7" maxlength="6" onChange="seNaoIntReset(this,'')" value="<%=carregacol ? col.getNumero() : cadcol.getProximaColeta(Apoio.getUsuario(request).getFilial().getIdfilial(), Integer.parseInt(Apoio.getDataAtual().substring(6)))%>" class="fieldMin">
                        </td>
                        <td width="14%" class="TextoCampos">Tipo:</td>
                        <td width="20%" class="CelulaZebra2">
                            <select name="tipoPedido" id="tipoPedido" onChange="" class="fieldMin">
                                <option value="am">Ambas</option>
                                <option value="co" selected>Coleta</option>
                                <option value="os">Ordem de servi&ccedil;o</option>
                            </select>
                        </td>
                        <td width="9%" class="TextoCampos">Or&ccedil;amento:</td>
                        <td width="12%" class="CelulaZebra2">
                            <input name="orcamento_numero" class="inputReadOnly8pt" type="text" id="orcamento_numero" size="7" value="<%=carregacol ? col.getOrcamento().getNumero() : ""%>" readonly >
                            <input name="button3" type="button" class="botoes" onClick="localizaOrcamento();" value="...">
                        </td>
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">Solicita&ccedil;&atilde;o:</td>
                        <td class="CelulaZebra2">
                            <input name="dtsolicitacao" type="text" id="dtsolicitacao" size="9" maxlength="10" onBlur="alertInvalidDate(this)" class="fieldDate"
                                   value="<%=(carregacol ? fmt.format((col.getSolicitadaEm() != null ? col.getSolicitadaEm() : new Date())) : Apoio.getDataAtual())%>">
                            às 
                            <input name="hrsolicitacao" class="inputReadOnly8pt" type="text" id="hrsolicitacao" size="5" value="<%=carregacol ? (col.getHrSolicitacao() != null ? fmtHora.format(col.getHrSolicitacao()) : "") : ""%>" readonly>
                        </td>
                        <td class="TextoCampos">Previs&atilde;o:</td>
                        <td class="CelulaZebra2">
                            <input name="previsao" type="text" id="previsao" size="9" maxlength="10" value="<%=(carregacol && col.getPrevisaoEm() != null ? new SimpleDateFormat("dd/MM/yyyy").format(col.getPrevisaoEm()) : Apoio.getDataAtual())%>" onblur="alertInvalidDate(this)" class="fieldDate">
                        </td>
                        <td class="TextoCampos">Programada Para:</td>
                        <td class="CelulaZebra2">
                            <input name="prog_data" type="text" id="prog_data" size="9" maxlength="10" value="<%=(carregacol && col.getColetaProgramaEm() != null ? new SimpleDateFormat("dd/MM/yyyy").format(col.getColetaProgramaEm()) : "")%>" onBlur="alertInvalidDate(this, true)" class="fieldDate">
                            &agrave;s 
                            <input name="prog_hora" class="fieldMin" type="text" id="prog_hora" size="5" maxlength="5"  value="<%=(carregacol && col.getColetaProgramadaAs() != null ? new SimpleDateFormat("HH:mm").format(col.getColetaProgramadaAs()) : "")%>" onkeyup="mascaraHora(this)">
                        </td>
                        <td colspan="2" class="TextoCampos">
                            <div align="center">
                                <input name="cancelada" type="checkbox" id="cancelada"  value="checkbox" onClick="javascript:mostraMotivoCancelamento();" >
                                Cancelada
                            </div>
                        </td>
                    </tr>
                    <tr id="trMotivoCancelamento" name="trMotivoCancelamento" style="display:none;">
                        <td class="TextoCampos">Motivo:</td>
                        <td colspan="7" class="CelulaZebra2">
                            <textarea cols="100" rows="2" id="motivo" class="fieldMin" name="motivo" onBlur=""><%=(carregacol ? col.getMotivoCancelamento() : "")%></textarea>
                        </td>
                    </tr>
                </table>
                <br>
                <div id="container" style="width: 80%" align="center">
                    <div align="center">
                        <ul id="tabs">
                            <li>
                                <a href="#tab1" id="aTab1">
                                    <strong>Clientes[F4]</strong>
                                </a>
                            </li>
                            <li>
                                <a href="#tab2" id="aTab2">
                                    <strong>Dados da Coleta[F8]</strong>
                                </a>
                            </li>
                            <li>
                                <a href="#tab3" id="aTab3">
                                    <strong>Notas Fiscais[F9]</strong>
                                </a>
                            </li>
                            <li>
                                <a href="#tab4" id="aTab4">
                                    <strong>Servi&ccedil;os[F10]</strong>
                                </a>
                            </li>
                            <li>
                                <a href="#tab5" id="aTab5">
                                    <strong>Ocorr&ecirc;ncias</strong>
                                </a>
                            </li>
                            <li>
                                <a href="#tab6" id="aTab6">
                                    <strong>Despesas da coleta</strong>
                                </a>
                            </li>
                            <li style='display: <%= carregacol && nivelUser == 4 ? "" : "none" %>' >
                                <a href="#tab7" id="aTab7">
                                    <strong>Auditoria</strong>
                                </a>
                            </li>
                        </ul>
                    </div>
                    <div class="panel" id="tab1">
                        <fieldset>
                            <table width="100%" border="0" class="bordaFina" align="center">
                                <tr>
                                    <td class="TextoCampos">Resp. Pagto:</td>
                                    <td class="CelulaZebra2" colspan="7">
                                        <select name="clientepagador" id="clientepagador" onChange="changeClientePagador(this.value)" class="fieldMin">
                                            <option value="d">Destinat&aacute;rio (FOB)</option>
                                            <option value="r" selected>Remetente (CIF)</option>
                                            <option value="c">Terceiro (CON)</option>
                                        </select>
                                    </td>                
                                   
                                    <td class="CelulaZebra2"><div align="center"><%=(carregacol ? (col.isAutomatica() ? "Coleta Automática: SIM" : "Coleta Automática: NÃO") : "")%></div></td>
                                </tr>	
                                <tr>
                                    <td colspan="9" class="tabela">
                                        <div align="center">Cliente/Remetente</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">Raz&atilde;o Social:</td>
                                    <td colspan="3" class="CelulaZebra2">
                                        <input name="rem_codigo_cl" type="text" id="rem_codigo_cl" size="3" value="<%=(carregacol ? String.valueOf(col.getCliente().getIdcliente()) : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo('idcliente', this.value, false)" class="fieldMin">
                                        <input name="rem_cnpj_cl" type="text" class="inputReadOnly8pt" id="rem_cnpj_cl" maxlength="23" size="20" value="<%=(carregacol ? col.getCliente().getCnpj() : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo('cnpj',this.value, false)">
                                        <input name="rem_rzs_cl" type="text" class="inputReadOnly8pt" id="rem_rzs_cl" size="40" value="<%=(carregacol ? col.getCliente().getRazaosocial() : "")%>" >
                                        <input name="button3" type="button" class="botoes" onclick="abrirLocalizarRemetente();" value="...">
                                        <input type="hidden" id="tipoPadraoDocumento" value="<%= (carregacol ? col.getCliente().getTipoDocumentoPadrao() : "NE") %>">
                                        <strong>
                                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="getObj('idremetente_cl').value = '0';getObj('rem_codigo_cl').value = '';getObj('rem_rzs_cl').value = '';getObj('rem_cnpj_cl').value = '';">
                                        </strong>
                                        <img src="img/page_edit.png" border="0" onClick="javascript:verCliente('R');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                    </td>
                                    <td colspan="5" class="TextoCampos">
                                        <input name="rem_codigo" type="hidden" id="rem_codigo" size="3" value="" class="fieldMin">
                                        <input name="rem_cnpj" type="hidden" class="inputReadOnly8pt" id="rem_cnpj" maxlength="23" size="20" value="" >
                                        <input name="rem_rzs" type="hidden" class="inputReadOnly8pt" id="rem_rzs" size="40" value="" >
                                        <div align='center'>
                                            <label name='lbClienteColeta' id='lbClienteColeta' class='linkEditar' onclick="javascript:tryRequestToServer(function(){getClienteColeta(true);});">Coletar em outra empresa</label>
                                        </div>
                                    </td>
                                   
                                </tr>	
                                <tr id="trClienteColeta" name="trClienteColeta" style="display:none;">
                                    <td class="TextoCampos">Cliente Coleta:</td>
                                    <td colspan="3" class="CelulaZebra2">
                                        <input name="rem_col_codigo" type="text" id="rem_col_codigo" size="3" value="<%=(carregacol ? String.valueOf(col.getRemetenteColeta().getIdcliente()) : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo('idcliente', this.value, true)" class="fieldMin">
                                        <input name="rem_col_cnpj" type="text" class="inputReadOnly8pt" id="rem_col_cnpj" maxlength="23" size="20" value="<%=(carregacol ? col.getRemetenteColeta().getCnpj() : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo('cnpj',this.value, true)">
                                        <input name="rem_col_rzs" type="text" class="inputReadOnly8pt" id="rem_col_rzs" size="40" value="<%=(carregacol ? col.getRemetenteColeta().getRazaosocial() : "")%>" >
                                        <input name="button3" type="button" class="botoes" onClick="getClienteColeta(true);" value="...">
                                        <strong>
                                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="getObj('idremetente_coleta').value = '0';getObj('rem_col_codigo').value = '';getObj('rem_col_rzs').value = '';getObj('rem_col_cnpj').value = '';">
                                        </strong>
                                        <img src="img/page_edit.png" border="0" onClick="javascript:verCliente('RC');"
                                             title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                    </td>
                                    <td class="TextoCampos"></td>
                                    <td class="CelulaZebra2" colspan="4"></td>
                                </tr>	
                                <tr>
                                    <td width="12%" class="TextoCampos">Local coleta:</td>
                                    <td width="29%" class="CelulaZebra2">
                                        <input name="rem_endereco" type="text" class="inputReadOnly8pt" id="rem_endereco" size="40" value="<%=(carregacol ? (col.getCliente().getEndereco() ==null || col.getCliente().getEndereco().equals("null")? "" : col.getCliente().getEndereco() ): "")%>">
                                    </td>
                                    <td width="9%" class="TextoCampos">Bairro:</td>
                                    <td width="20%" class="CelulaZebra2">
                                        <input name="rem_bairro" type="text" class="inputReadOnly8pt" id="rem_bairro" size="20" maxlength="25" value="<%=(carregacol ? col.getCliente().getBairro() : "")%>" >
                                    </td>
                                    <td width="8%" class="TextoCampos">Cidade:</td>
                                    <td width="22%" class="CelulaZebra2" colspan="4">
                                        <input name="rem_cidade" type="text" class="inputReadOnly8pt" id="rem_cidade" size="17" value="<%=(carregacol ? col.getCliente().getCidade().getDescricaoCidade() : "")%>" readonly="true">
                                        <input name="rem_uf" type="text" class="inputReadOnly8pt" id="rem_uf" size="1" value="<%=(carregacol ? col.getCliente().getCidade().getUf() : "")%>" readonly="true">
                                        <input name="localiza_cidade" type="button" class="botoes" id="localiza_cidade" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=11&paramaux2='+$('uf_dest').value+'&paramaux='+$('idcidadedestino').value,'Cidade','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">Pt. Refer&ecirc;ncia:</td>
                                    <td colspan = "8" class="CelulaZebra2">
                                        <input name="pontoReferencia" type="text" id="pontoReferencia" value="<%=(carregacol ? col.getPontoReferencia() : "")%>" size="120" maxlength="150" class="fieldMin">
                                    </td>
                                </tr>	
                                <tr>
                                    <td class="TextoCampos">Hor&aacute;rio Atd.:</td>
                                    <td colspan="3" class="CelulaZebra2">
                                        <input name="horario_atendimento" type="text" id="horario_atendimento" value="<%=(carregacol && col.getHorarioAtendimento() != null ? col.getHorarioAtendimento() : "")%>" size="80" maxlength="75" class="fieldMin">
                                    </td>
                                    <td  class="TextoCampos">Fone:</td>
                                    <td colspan="4" class="CelulaZebra2">
                                        <input name="rem_fone" type="text" class="inputReadOnly8pt" id="rem_fone" size="13" maxlength="20" value="<%=(carregacol ? col.getCliente().getFone() : "")%>">
                                    </td>
                                </tr>	
                                <tr>
                                    <td class="TextoCampos">Contato:</td>
                                    <td class="CelulaZebra2">
                                        <input name="contato" type="text" id="contato" value="<%=(carregacol ? col.getContato() : "")%>" size="30" maxlength="30" class="fieldMin">
                                    </td>
                                    <td class="TextoCampos">Pedido:</td>
                                    <td class="CelulaZebra2">
                                        <input name="numpedido" type="text" id="numpedido" value="<%=(carregacol ? col.getPedidoCliente() : "")%>" size="10" maxlength="20" class="fieldMin">
                                    </td>
                                    <td class="TextoCampos">Número de Carga</td>
                                    <td class="CelulaZebra2">
                                        <input name="numeroCarga" id="numeroCarga" type="text" value="<%=carregacol ? col.getNumeroCarga() : ""%>" size="10" maxlength="20" class="fieldMin" />
                                    </td>
                                    <td class="TextoCampos">Número RT:</td>
                                    <td colspan="2" class="CelulaZebra2">
                                        <input name="rt" type="text" id="rt" value="<%=(carregacol ? col.getNumeroRT() : "")%>" size="10" maxlength="20" class="fieldMin">
                                    </td>
                                </tr>	
                                <tr>
                                    <td colspan="9" class="tabela">
                                        <div align="center">Destinat&aacute;rio</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">Raz&atilde;o Social:</td>
                                    <td colspan="3" class="CelulaZebra2">
                                        <input name="des_codigo_cl" type="text" id="des_codigo_cl" size="3" value="<%=(carregacol ? String.valueOf(col.getDestinatario().getIdcliente()) : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaDestinatarioCodigo('idcliente',this.value, false)" class="fieldMin">
                                        <input name="dest_cnpj_cl" type="text" class="inputReadOnly8pt" id="dest_cnpj_cl" maxlength="18" size="20" value="<%=(carregacol ? col.getDestinatario().getCnpj() : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaDestinatarioCodigo('cnpj',this.value, false)">
                                        <input name="dest_rzs_cl" type="text" class="inputReadOnly8pt" id="dest_rzs_cl" size="40" value="<%=(carregacol && col.getDestinatario().getRazaosocial() != null ? col.getDestinatario().getRazaosocial() : "")%>">
                                        
                                        <input name="button32" type="button" class="botoes" onClick="abrirLocalizarDestinatario();" value="...">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Destinat&aacute;rio" onClick=" javascript:getObj('cidade_destino_id').value = '0'; javascript:getObj('cid_destino').value = '';javascript:getObj('uf_destino').value = ''; javascript:getObj('cidade_destino').value = '';javascript:getObj('idcidadedestino').value = '0';javascript:getObj('bairro_entrega').value = '';javascript:getObj('uf_dest').value = ''; javascript:getObj('cidade_destino').value = ''; javascript:getObj('endereco_entrega').value = ''; javascript:getObj('iddestinatario').value = '0';javascript:getObj('iddestinatario_cl').value = '0';javascript:getObj('dest_rzs_cl').value = '';javascript:getObj('des_codigo_cl').value = '';javascript:getObj('dest_cnpj_cl').value = '';">
                                        
                                        <img src="img/page_edit.png" border="0" onClick="javascript:verCliente('D');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                    </td>
                                    <td colspan="5" class="TextoCampos">
                                        <input name="des_codigo" type="hidden" id="des_codigo" size="3" value="" class="fieldMin">
                                        <input name="dest_cnpj" type="hidden" class="inputReadOnly8pt" id="dest_cnpj" maxlength="18" size="20" value="">
                                        <input name="dest_rzs" type="hidden" class="inputReadOnly8pt" id="dest_rzs" size="40" value="">
                                        <div align='center'>
                                            <label name='lbClienteEntrega' id='lbClienteEntrega' class='linkEditar' onclick="javascript:tryRequestToServer(function(){getClienteEntrega(true);});">Entregar em outra empresa</label>
                                        </div>
                                    </td>
                                </tr>	
                                <tr id="trClienteEntrega" name="trClienteEntrega" style="display:none;">
                                    <td class="TextoCampos">Cliente Entrega:</td>
                                    <td colspan="3" class="CelulaZebra2">
                                        <input name="des_ent_codigo" type="text" id="des_ent_codigo" size="3" value="<%=(carregacol ? String.valueOf(col.getDestinatarioEntrega().getIdcliente()) : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaDestinatarioCodigo('idcliente',this.value, true)" class="fieldMin">
                                        <input name="dest_ent_cnpj" type="text" class="inputReadOnly8pt" id="dest_ent_cnpj" maxlength="18" size="20" value="<%=(carregacol ? col.getDestinatarioEntrega().getCnpj() : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaDestinatarioCodigo('cnpj',this.value, true)">
                                        <input name="dest_ent_rzs" type="text" class="inputReadOnly8pt" id="dest_ent_rzs" size="40" value="<%=(carregacol && col.getDestinatarioEntrega().getRazaosocial() != null ? col.getDestinatarioEntrega().getRazaosocial() : "")%>">
                                        <input name="button32" type="button" class="botoes" onClick="javascript:getClienteEntrega(true);" value="...">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Destinat&aacute;rio" onClick="javascript:getObj('iddestinatario_entrega').value = '0';javascript:getObj('dest_ent_rzs').value = '';javascript:getObj('dest_ent_cnpj').value = ''; javascript:getObj('des_ent_codigo').value = '';javascript:getObj('cidade_destino_id').value = '0'; javascript:getObj('cid_destino').value = '';javascript:getObj('uf_destino').value = ''; javascript:getObj('cidade_destino').value = '';javascript:getObj('idcidadedestino').value = '0';javascript:getObj('bairro_entrega').value = '';javascript:getObj('uf_dest').value = ''; javascript:getObj('cidade_destino').value = ''; javascript:getObj('endereco_entrega').value = '';">
                                        <img src="img/page_edit.png" border="0" onClick="javascript:verCliente('DC');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                    </td>
                                    <td class="CelulaZebra2" colspan="5"></td>
                                    
                                </tr>	
                                <tr>
                                    <td class="TextoCampos">Local entrega:</td>
                                    <td class="CelulaZebra2">
                                        <input name="endereco_entrega" type="text" class="inputReadOnly8pt" id="endereco_entrega" size="40" value="<%=(carregacol ? col.getEnderecoEntrega() : "")%>">
                                    </td>
                                    <td class="TextoCampos">Bairro:</td>
                                    <td class="CelulaZebra2">
                                        <input name="bairro_entrega" type="text" class="inputReadOnly8pt" id="bairro_entrega" size="20" maxlength="25" value="<%=(carregacol ? col.getBairroEntrega() : "")%>" >
                                    </td>
                                   
                                    <td colspan="5" class="CelulaZebra2">
                                        <input name="dest_endereco" type="hidden" class="inputReadOnly8pt" id="dest_endereco" size="40" value="">
                                        <input name="dest_bairro" type="hidden" class="inputReadOnly8pt" id="dest_bairro" size="40" value="">
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">Cidade Destino:</td>
                                    <td class="CelulaZebra2">
                                        <input name="cid_destino" type="hidden" class="inputReadOnly8pt" id="cid_destino" size="19" value="<%=(carregacol && col.getCidadeDestino().getDescricaoCidade() != null ? col.getCidadeDestino().getDescricaoCidade() : "")%>" readonly="true">
                                        <input name="uf_destino" type="hidden" class="inputReadOnly8pt" id="uf_destino" size="1" value="<%=(carregacol && col.getCidadeDestino().getUf() != null ? col.getCidadeDestino().getUf() : "")%>" readonly="true">
                                        <input name="cidade_destino" type="text" class="inputReadOnly8pt" id="cidade_destino" size="19" value="<%=(carregacol && col.getCidadeDestino().getDescricaoCidade() != null ? col.getCidadeDestino().getDescricaoCidade() : "")%>" readonly="true">
                                        <input name="uf_dest" type="text" class="inputReadOnly8pt" id="uf_dest" size="1" value="<%=(carregacol && col.getCidadeDestino().getUf() != null ? col.getCidadeDestino().getUf() : "")%>" readonly="true">
                                        <input type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=12&paramaux2='+$('rem_uf').value+'&paramaux='+$('idcidadeorigem').value,'Cidade_destino')" value="...">
                                    </td>
                                    <td colspan="2" class="TextoCampos">
                                        <div align='center'>
                                            <label name='lbMostraDestinos' id='lbMostraDestinos' class='linkEditar' onclick="javascript:tryRequestToServer(function(){mostraDestinos();});">Visualizar/Adicionar mais Destinos</label>
                                        </div>
                                    </td>
                                    <td colspan="5" class="TextoCampos" ></td>                                    
                                </tr>	
                                <tr name="trCidadesDestino" id="trCidadesDestino" style="display:none">
                                    <td colspan="6">
                                        <table width="100%" border="0" cellspacing="1" cellpadding="2">
                                            <tr>
                                                <td width="2%" class="TextoCampos">
                                                    <img src="img/add.gif" border="0" title="Adicionar uma nova cidade de destino" class="imagemLink" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=12','Cidades_destino');">
                                                </td>
                                                <td width="98%" class="TextoCampos">
                                                    <table width="100%" border="1">
                                                        <tbody id="corpoCidades">
                                                        </tbody>
                                                    </table>
                                                </td>	
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr style="display: none" id="trConsignatario" name="trConsignatario">
                                    <td colspan="9" class="tabela">
                                        <div align="center">Consignat&aacute;rio</div>
                                    </td>
                                </tr>
                                <tr style="display: none" id="trConsignatario2" name="trConsignatario2">
                                    <td class="TextoCampos">Raz&atilde;o Social:</td>
                                    <td colspan="3" class="CelulaZebra2">
                                        <input type="hidden" name="idconsignatario_con" id="idconsignatario_con" value="<%=(carregacol ? String.valueOf(col.getConsignatario().getIdcliente()) : "")%>">
                                        <input name="con_codigo_con" type="text" id="con_codigo_con" size="3" value="<%=(carregacol ? String.valueOf(col.getConsignatario().getIdcliente()) : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaConsignatarioCodigo('idcliente', this.value)" class="fieldMin">
                                        <input name="con_cnpj_con" type="text" class="inputReadOnly8pt" id="con_cnpj_con" maxlength="18" size="20" value="<%=(carregacol ? col.getConsignatario().getCnpj() : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaConsignatarioCodigo('cnpj',this.value)">
                                        <input name="con_rzs_con" type="text" class="inputReadOnly8pt" id="con_rzs_con" size="40" value="<%=(carregacol && col.getConsignatario().getRazaosocial() != null ? col.getConsignatario().getRazaosocial() : "")%>" readonly="true">
                                        <input name="button32" type="button" class="botoes" onClick="javascript:localizaconsignatario()" value="...">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Destinat&aacute;rio" onClick="limpaConsignatario()">
                                        <img src="img/page_edit.png" border="0" onClick="javascript:verCliente('C');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                    </td>
                                    <td class="TextoCampos"></td>
                                    <td class="CelulaZebra2" colspan="4"></td>
                                </tr>	
                                <tr>
                                    <td colspan="9" class="tabela">
                                        <div align="center">Tabela de pre&ccedil;o</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="9">
                                        <table width="100%" border="0" class="bordaFina" align="center">
                                            <tr>
                                                <td class="TextoCampos">Tipo Frete:</td>
                                                <td class="CelulaZebra2">
                                                    <select name="tipotaxa" id="tipotaxa" style="font-size:8pt; " <%=!allowChangeTablePrice ? "disabled='disabled'" : ""%> class="fieldMin">
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
                                                <td class="TextoCampos">Tipo Ve&iacute;culo:</td>
                                                <td class="CelulaZebra2">
                                                    <select name="tipoveiculo" id="tipoveiculo" style="font-size:8pt; width:100px;" <%=!allowChangeTablePrice ? "disabled='disabled'" : ""%> class="fieldMin" onchange="calcularFreteCarreteiro();">
                                                        <option value="-1">Nenhum</option>
                                                        <%ConsultaTipo_veiculos tipo = new ConsultaTipo_veiculos();
                                                            tipo.setConexao(Apoio.getUsuario(request).getConexao());
                                                            //alteracao referente a historia 3231
                                                            tipo.mostraTipos(true,col.getTipoVeiculo().getId());
                                                            ResultSet rs = tipo.getResultado();
                                                            while (rs.next()) {%>
                                                        <option value="<%=rs.getString("id")%>"
                                                                style="background-color:#FFFFFF"
                                                                <%=(carregacol && rs.getInt("id") == col.getTipoVeiculo().getId() ? "Selected" : "")%>><%=rs.getString("descricao")%>
                                                        </option>
                                                        <%}%>
                                                    </select>
                                                    <input name="tipo_veiculo_motorista" type="hidden" id="tipo_veiculo_motorista" value="0">
                                                    <input name="tipo_veiculo_veiculo" type="hidden" id="tipo_veiculo_veiculo" value="0">
                                                    <input name="tipo_veiculo_carreta" type="hidden" id="tipo_veiculo_carreta" value="0">
                                                </td>
                                                <td class="TextoCampos">Produto/Opera&ccedil;&atilde;o:</td>
                                                <td class="CelulaZebra2">
                                                    <select name="tipoproduto" id="tipoproduto" style="font-size:8pt; width:100px;" class="fieldMin">
                                                        <option value="0">-- Nenhum --</option>
                                                        <%ResultSet product_types = TipoProduto.all(Apoio.getConnectionFromUser(request), 0, false, 0);
                                                            while (product_types.next()) {%>
                                                        <option value="<%=product_types.getString("id")%>"
                                                                style="background-color:#FFFFFF"
                                                                <%=(carregacol && product_types.getInt("id") == col.getTipoProduto().getId() ? "Selected" : "")%>> <%=product_types.getString("descricao")%> </option>
                                                        <%}%>
                                                    </select>
                                                </td>
                                                <td class="TextoCampos">Valor Combinado:</td>
                                                <td class="CelulaZebra2">
                                                    <input name="vlcombinado" type="text" id="vlcombinado" size="8" maxlength="12"  onBlur="javascript:seNaoFloatReset(this,'0.00'); preparaIniciarCfe();" value="<%=(carregacol ? Apoio.to_curr(col.getValorCombinado()) : "0.00")%>" class="fieldMin">
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
                                <tr>
                                    <td width="16%" class="TextoCampos">Coleta realizada em:</td>
                                    <td width="20%" class="CelulaZebra2">
                                        <input name="dtcoleta" type="text" id="dtcoleta" size="10" maxlength="10" value="<%=(carregacol && col.getColetaEm() != null) ? fmt.format(col.getColetaEm()) : ""%>" onBlur="alertInvalidDate(this, true)" class="fieldDate">
                                        &agrave;s
                                        <input name="hrcoleta" type="text" id="hrcoleta" size="5" maxlength="5" value="<%=(carregacol ? col.getColetaAs() : "")%>" onkeyup="mascaraHora(this)" class="fieldMin">
                                    </td>
                                    <td width="17%" class="TextoCampos">Atrav&eacute;s do romaneio:</td>
                                    <td width="12%" class="CelulaZebra2">
                                        <%=(carregacol && !col.getRomaneio().getNumRomaneio().equals("") ? "<div align='rigth' class='linkEditar' onclick='javascript:tryRequestToServer(function(){editarRomaneio(" + col.getRomaneio().getIdRomaneio() + ");});'>" + col.getRomaneio().getNumRomaneio() + "</div> " : "")%>
                                    </td>
                                    <td width="5%" class="TextoCampos">Tipo:</td>
                                    <td width="18%" class="CelulaZebra2">
                                        <select name="tipoColeta" id="tipoColeta" class="fieldMin" style="width:130px;">
                                            <option value="pr" selected>Coleta Normal</option>
                                            <option value="co">Coleta com Container (Vai vazio e volta carregado)</option>
                                            <option value="en">Entrega com Container (Vai carregado e volta vazio)</option>
                                        </select>
                                    </td>
                                    <td width="6%" class="TextoCampos">Urbana:</td>
                                    <td width="6%" class="CelulaZebra2">
                                        <select name="urbano" id="urbano" onChange="javascript:alteraUrbano();" class="fieldMin">
                                            <option value="true">Sim</option>
                                            <option value="false" selected>N&atilde;o</option>
                                        </select>
                                    </td>
                                </tr>	
                                <tr id="trUrbano">
                                    <td colspan="8">
                                        <table width="100%" border="0" cellspacing="1" cellpadding="2">
                                            <tr>
                                                <td>
                                                <td class="TextoCampos">Data/Hora da chegada: </td>
                                                <td class="CelulaZebra2">
                                                    <input name="dtChegada" type="text" id="dtChegada" size="8" maxlength="10" onBlur="alertInvalidDate(this,true)" class="fieldDate"
                                                           value="<%=(carregacol ? (col.getChegadaEm() != null ? fmt.format(col.getChegadaEm()) : "") : "")%>">
                                                    <input name="hrChegada" type="text" id="hrChegada" size="5" maxlength="5" onkeyup="mascaraHora(this)" value="<%=carregacol ? col.getChegadaAs() : ""%>" class="fieldMin">
                                                </td>
                                                <td class="TextoCampos">Data/Hora da entrega: </td>
                                                <td class="CelulaZebra2">
                                                    <input name="dtSaida" type="text" id="dtSaida" size="8" maxlength="10" onBlur="alertInvalidDate(this,true)" class="fieldDate"
                                                           value="<%=(carregacol ? (col.getEntregaEm() != null ? fmt.format(col.getEntregaEm()) : "") : "")%>">
                                                    <input name="hrSaida" type="text" id="hrSaida" size="5" maxlength="5" onkeyup="mascaraHora(this)" value="<%=carregacol ? col.getEntregaAs() : ""%>" class="fieldMin">
                                                </td>
                                                <td class="TextoCampos">Recebedor: </td>
                                                <td class="CelulaZebra2">
                                                    <input name="recebedor" type="text" id="recebedor" size="30" maxlength="100"  value="<%=carregacol ? col.getRecebedor() : ""%>" class="fieldMin">
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan = "8">
                                        <table width="100%" border="0" cellspacing="1" cellpadding="2">
                                            <tr>
                                                <td colspan="8" class="tabela">
                                                    <div align="center">Dados da Carga</div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td width="15%" class="TextoCampos">QTD Entregas:</td>
                                                <td width="10%" class="CelulaZebra2">
                                                    <input name="qtde_entregas" type="text" id="qtde_entregas" value="<%=(carregacol ? col.getQtdeEntregas() : 1)%>"  size="3" maxlength="9" class="fieldMin">
                                                </td>
                                                <td width="15%" class="TextoCampos">Peso Solicitado:</td>
                                                <td width="10%" class="CelulaZebra2">
                                                    <input name="pesoSolicitado" type="text" id="pesoSolicitado" size="8" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.000');" value="<%=(carregacol ? Apoio.to_curr(col.getPesoSolicitado()) : "0.000")%>">Kg
                                                </td>
                                                <td width="15%" class="TextoCampos">Volume Solicitado:</td>
                                                <td width="10%" class="CelulaZebra2">
                                                    <input name="volumeSolicitado" type="text" id="volumeSolicitado" size="5" class="fieldMin" maxlength="5"  onBlur="javascript:seNaoIntReset(this,'0');" value="<%=(carregacol ? col.getVolumeSolicitado() : 0)%>">
                                                </td>
                                                <td width="15%" class="TextoCampos">Valor Mercadoria:</td>
                                                <td width="10%" class="CelulaZebra2">
                                                    <input name="mercadoriasolicitada" type="text" id="mercadoriasolicitada" size="8" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.00'); preparaIniciarCfe();" value="<%=(carregacol ? Apoio.to_curr(col.getValorMercadoriaSolicitada()) : "0.00")%>">
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos">Embal./Esp&eacute;cie:</td>
                                                <td colspan="3" class="CelulaZebra2">
                                                    <input name="embalagemSolicitada" type="text" id="embalagemSolicitada" value="<%=(carregacol ? col.getEmbalagemSolicitada() : "")%>"  size="20" maxlength="20" class="fieldMin">
                                                </td>
                                                <td class="TextoCampos">Conte&uacute;do:</td>
                                                <td colspan="3" class="CelulaZebra2">
                                                    <input name="conteudoSolicitada" type="text" id="conteudoSolicitada" value="<%=(carregacol ? col.getConteudoSolicitada() : "")%>"  size="30" maxlength="30" class="fieldMin">
                                                </td>
                                            </tr>
                                            <%if (Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe()=='D'){%>
                                                <tr >
                                                <td width="15%" class="TextoCampos">Valor Pedágio:</td>
                                                <td width="10%" class="CelulaZebra2">
                                                    <input name="valorPedagio" type="text" id="valorPedagio" size="8" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.00');" value="<%=(carregacol ? Apoio.to_curr(col.getValorPedagio()) : "0.00")%>">
                                                    <img src="img/pedagio1.png" width="40px" height="30px" alt="" name="calcPedagio" title="Clique aqui para calcular o pedágio." class="imagemLink" id="calcPedagio" onclick="javascript:calcularPedagio()" />&nbsp;&nbsp;
                                                </td>
                                                <td colspan="6" class="CelulaZebra2"></td>
                                                </tr>
                                            <%}%>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="8" class="tabela">
                                        <div align="center">Dados do Container</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="8">
                                        <table width="100%" border="0" cellspacing="1" cellpadding="2">
                                            <tr>
                                                <td width="8%" class="TextoCampos">N&uacute;mero:</td>
                                                <td width="12%" class="CelulaZebra2">
                                                    <input name="numeroContainer" type="text" id="numeroContainer" onChange="getTipoColeta();" value="<%=(carregacol ? col.getNumeroContainer() : "")%>" size="12" maxlength="30" class="fieldMin">
                                                </td>
                                                <td width="8%" class="TextoCampos">Tipo:</td>
                                                <td width="12%" class="CelulaZebra2">
                                                    <select name="tipoContainer" id="tipoContainer" style="font-size:8pt;width:80px;" class="fieldMin" onchange="localizaPesoContainer(this.value);">
                                                        <option value="0" selected>Selecione</option>
                                                        <%
                                                            ConsultaTipoContainer tpContainer = new ConsultaTipoContainer();
                                                            tpContainer.setConexao(Apoio.getUsuario(request).getConexao());
                                                            tpContainer.MostrarTudo();
                                                            ResultSet rsTp = tpContainer.getResultado();
                                                            while (rsTp.next()) {%>
                                                        <option value="<%=rsTp.getString("id")%>"
                                                                style="background-color:#FFFFFF"
                                                                <%=(carregacol && rsTp.getInt("id") == col.getTipoContainer().getId() ? "Selected" : "")%>><%=rsTp.getString("descricao")%>
                                                        </option>

                                                        <%}
                                                            rsTp.close();%>
                                                    </select>
                                                </td>
                                                <td width="10%" class="TextoCampos">GENSET:</td>
                                                <td width="12%" class="CelulaZebra2">
                                                    <input name="genset" type="text" id="genset" value="<%=(carregacol ? col.getNumeroGenset() : "")%>" size="12" maxlength="30" class="fieldMin">
                                                </td>
                                                <td width="6%" class="TextoCampos">Lacre:</td>
                                                <td width="12%" class="CelulaZebra2">
                                                    <input name="lacre_container" type="text" id="lacre_container" value="<%=(carregacol ? col.getNumeroLacre() : "")%>" size="10" maxlength="30" class="fieldMin">
                                                </td>
                                                <td width="8%" class="TextoCampos">Booking:</td>
                                                <td width="12%" class="CelulaZebra2">
                                                    <input name="booking" type="text" id="booking" value="<%=(carregacol ? col.getNumeroBooking() : "")%>" size="13" maxlength="30" class="fieldMin">
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos">Peso:</td>
                                                <td class="CelulaZebra2">
                                                    <input name="pesoContainer" type="text" id="pesoContainer" size="8" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.000');" value="<%=(carregacol ? Apoio.to_curr(col.getPesoContainer()) : "0.000")%>">Kg
                                                </td>
                                                <td class="TextoCampos">Valor Ctn:</td>
                                                <td class="CelulaZebra2">
                                                    <input name="valorContainer" type="text" id="valorContainer" size="8" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.00');" value="<%=(carregacol ? Apoio.to_curr(col.getValorContainer()) : "0.00")%>">
                                                </td>
                                                <td class="TextoCampos">Valor Genset:</td>
                                                <td class="CelulaZebra2">
                                                    <input name="valorGenset" type="text" id="valorGenset" size="8" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.00');" value="<%=(carregacol ? Apoio.to_curr(col.getValorGenset()) : "0.00")%>">
                                                </td>
                                                <td class="TextoCampos">Horím.:</td>
                                                <td class="CelulaZebra2">
                                                    <input name="horimInicial" type="text" id="horimInicial" value="<%=(carregacol ? col.getGensetHorimetroInicial() : "0")%>" size="5" maxlength="10" class="fieldMin" onChange="seNaoIntReset(this,'0');totalHorimetro();">
                                                    <input name="horimFinal" type="text" id="horimFinal" value="<%=(carregacol ? col.getGensetHorimetroFinal() : "0")%>" size="5" maxlength="10" class="fieldMin" onChange="seNaoIntReset(this,'0');totalHorimetro();">
                                                    <label name="lbHorim" id="lbHorim"></label>
                                                </td>
                                                <td class="TextoCampos">Navio:</td>
                                                <td class="CelulaZebra2">
                                                    <select name="navio" id="navio" style="font-size:8pt;width:85px;" class="fieldMin">
                                                        <option value="0" selected>Selecione o navio</option>
                                                        <%ConsultaNavio navio = new ConsultaNavio();
                                                            navio.setConexao(Apoio.getUsuario(request).getConexao());
                                                            navio.mostraTodos();
                                                            ResultSet rsN = navio.getResultado();
                                                            while (rsN.next()) {%>
                                                        <option value="<%=rsN.getString("id")%>" style="background-color:#FFFFFF" <%=(carregacol && rsN.getInt("id") == col.getNavio().getId() ? "Selected" : "")%>><%=rsN.getString("descricao")%></option>
                                                        <%}
                                                            rsN.close();%>
                                                    </select>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos">Armador:</td>
                                                <td colspan="3" class="CelulaZebra2">
                                                    <input name="armador" type="text" class="inputReadOnly8pt" id="armador" size="20" value="<%=(carregacol && col.getArmador().getRazaosocial() != null ? col.getArmador().getRazaosocial() : "")%>">
                                                    <input name="button5" type="button" class="botoes" onClick="launchPopupLocate('./localiza?categoria=loc_cliente&acao=consultar&idlista=52','Armador')" value="...">
                                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Armador" onClick="javascript:getObj('idarmador').value = '0';javascript:getObj('armador').value = '';">
                                                </td>
                                                <td class="TextoCampos">Terminal:</td>
                                                <td class="CelulaZebra2">
                                                    <select name="terminal" id="terminal" style="font-size:8pt;width:85px;" class="fieldMin">
                                                        <option value="0" selected>Selecione o terminal</option>
                                                        <%ConsultaTerminal term = new ConsultaTerminal();
                                                            term.setConexao(Apoio.getUsuario(request).getConexao());
                                                            term.MostrarTudo();
                                                            ResultSet rsT = term.getResultado();
                                                            while (rsT.next()) {%>
                                                        <option value="<%=rsT.getString("id")%>" style="background-color:#FFFFFF" <%=(carregacol && rsT.getInt("id") == col.getTerminal().getId() ? "Selected" : "")%>><%=rsT.getString("descricao")%></option>
                                                        <%}
                                                            rsT.close();%>
                                                    </select>
                                                </td>
                                                <td class="TextoCampos">Viagem:</td>
                                                <td class="CelulaZebra2">
                                                    <input name="viagemContainer" type="text" id="viagemContainer" value="<%=(carregacol ? col.getNumeroViagemNavio() : "")%>" size="7" maxlength="10" class="fieldMin">
                                                </td>
                                                <td class="TextoCampos">Entrega:</td>
                                                <td class="CelulaZebra2">
                                                    <input name="entregaContainerEm" type="text" id="entregaContainerEm" value="<%=(carregacol || col.getEntregaContainerEm()==null?"": fmt.format(col.getEntregaContainerEm()))%>" size="10" maxlength="10" class="fieldDate" onBlur="alertInvalidDate(this, true)"/> às 
                                                    <input name="entregaContainerAs" type="text" id="entregaContainerAs" value="<%=(carregacol || col.getEntregaContainerAs()==null?"": col.getEntregaContainerAs())%>" size="5" maxlength="5"  class="fieldMin" onkeyup="mascaraHora(this)">
                                                    
                                                </td>
                                            </tr>	
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="8" class="tabela">
                                        <div align="center">Respons&aacute;vel pela coleta</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="8">
                                        <table width="100%" border="0" cellspacing="1" cellpadding="2">
                                            <tr>
                                                <td class="TextoCampos">Motorista:</td>
                                                <td colspan="2" class="CelulaZebra2">
                                                    <input name="motor_nome" type="text" class="inputReadOnly8pt" id="motor_nome" size="45" value="<%=(carregacol ? col.getMotorista().getNome() : "")%>" readonly="true">
                                                    <%if(col.getContratoFrete().getIdcartafrete() == 0){%>
                                                    <input name="button" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&paramaux=carta&paramaux2=IS NULL'+'&paramaux3='+parseFloat($('id_rota_viagem') ? $('id_rota_viagem').value : '0')+'&idlista=10&fecharJanela=true','Motorista')" value="...">
                                                    <%}%>
                                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Motorista" onClick="javascript:getObj('idmotorista').value = 0;getObj('motor_nome').value = '';">
                                                    <img src="img/page_edit.png" border="0" onClick="javascript:verMotorista();" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                                </td>
                                                <td class="TextoCampos">Libera&ccedil;&atilde;o:</td> 
                                                <td class="CelulaZebra2">
                                                    <input name="motor_liberacao" type="text" id="motor_liberacao" value="<%=(carregacol ? col.getLiberacaoSeguradora() : "")%>"  size="20" maxlength="20" class="fieldMin">
                                                </td>
                                                <td class="TextoCampos" colspan="3"></td>
                                            </tr>
                                            <tr>
                                                <td width="13%" class="TextoCampos">Ve&iacute;culo:</td>
                                                <td width="12%" class="CelulaZebra2">
                                                    <input name="vei_placa" type="text" class="inputReadOnly8pt" id="vei_placa" value="<%=(carregacol ? col.getVeiculo().getPlaca() : "")%>" size="10" readonly="true">
                                                    <%if(col.getContratoFrete().getIdcartafrete() == 0){%>
                                                    <input name="localiza_veiculo" type="button" class="botoes" id="localiza_veiculo" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=7&paramaux2=IS NULL'+'&paramaux3='+parseFloat($('id_rota_viagem') ? $('id_rota_viagem').value : '0'),'Veiculo')" value="...">
                                                    <%}%>
                                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Ve&iacute;culo" onClick="javascript:getObj('idveiculo').value = 0;javascript:getObj('vei_placa').value = '';validarTipoVeiculo('v');">
                                                    <img src="img/page_edit.png" border="0" onClick="javascript:verVeiculo('V');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                                </td>
                                                <td width="10%" class="TextoCampos">Carreta:</td>
                                                <td width="12%" class="CelulaZebra2">
                                                    <input name="car_placa" type="text" class="inputReadOnly8pt" id="car_placa" value="<%=(carregacol && col.getCarreta() != null ? col.getCarreta().getPlaca() : "")%>" size="10" readonly="true">
                                                    <%if(col.getContratoFrete().getIdcartafrete() == 0){%>
                                                    <input name="localiza_veiculo2" type="button" class="botoes" id="localiza_veiculo2" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=9&paramaux2=IS NULL'+'&paramaux3='+parseFloat($('id_rota_viagem') ? $('id_rota_viagem').value : '0'),'Carreta')" value="...">
                                                    <%}%>
                                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Carreta" onClick="javascript:getObj('idcarreta').value = 0;javascript:getObj('car_placa').value = '';validarTipoVeiculo('c');">
                                                    <img src="img/page_edit.png" border="0" onClick="javascript:verVeiculo('C');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                                </td>
                                                <td width="10%" class="TextoCampos">Bi-Trem:</td>
                                                <td width="12%" class="CelulaZebra2">
                                                    <input name="bi_placa" type="text" class="inputReadOnly8pt" id="bi_placa" value="<%=(carregacol && col.getCarreta() != null ? col.getBiTrem().getPlaca() : "")%>" size="10" readonly="true">
                                                    <%if(col.getContratoFrete().getIdcartafrete() == 0){%>
                                                    <input name="localiza_veiculo2" type="button" class="botoes" id="localiza_veiculo2" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=51','bitrem')" value="...">
                                                    <%}%>
                                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Carreta" onClick="javascript:getObj('idbitrem').value = 0;javascript:getObj('bi_placa').value = '';">
                                                    <img src="img/page_edit.png" border="0" onClick="javascript:verVeiculo('B');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                                </td>
                                                <td width="10%" class="TextoCampos">3º Reboque:</td>
                                                <td width="12%" class="CelulaZebra2">
                                                    <input name="tri_placa" type="text" class="inputReadOnly8pt" id="tri_placa" value="<%=(carregacol && col.getCarreta() != null ? col.getTriTrem().getPlaca() : "")%>" size="10" readonly="true">
                                                    <%if(col.getContratoFrete().getIdcartafrete() == 0){%>
                                                    <input name="localiza_veiculo2" type="button" class="botoes" id="localiza_veiculo2" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=92','tritrem')" value="...">
                                                    <%}%>
                                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar tritrem_placa" onClick="javascript:getObj('idtritrem').value = 0;javascript:getObj('tri_placa').value = '';">
                                                    <img src="img/page_edit.png" border="0" onClick="javascript:verVeiculo('T');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos">Transportadora:</td> 
                                                <td colspan="7" class="CelulaZebra2">
                                                    <input name="transp_codigo" type="text" id="transp_codigo" readonly class="inputReadOnly8pt" size="3" value="<%=(carregacol ? String.valueOf(col.getTransportador().getIdcliente()) : "")%>" >
                                                    <input name="transp_cnpj" type="text" readonly class="inputReadOnly8pt" id="transp_cnpj" maxlength="23" size="20" value="<%=(carregacol ? col.getTransportador().getCnpj() : "")%>">
                                                    <input name="transp_rzs" type="text" readonly class="inputReadOnly8pt" id="transp_rzs" size="40" value="<%=(carregacol ? col.getTransportador().getRazaosocial() : "")%>" >
                                                    <input name="button4" type="button" class="botoes" onClick="launchPopupLocate('./localiza?categoria=loc_cliente&acao=consultar&idlista=47','Transportador');" value="...">
                                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="getObj('idtransportador').value = '0';getObj('transp_rzs').value = '';getObj('transp_codigo').value = '';getObj('transp_cnpj').value = '';">
                                                    <img src="img/page_edit.png" border="0" onClick="javascript:verCliente('T');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                                    <input type="hidden" id="idtransportador" value="<%=(carregacol ? String.valueOf(col.getTransportador().getIdcliente()) : "0")%>" name="idtransportador">
                                                </td>
                                                
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos">Representante:</td>
                                                <td colspan="7" class="CelulaZebra2">
                                                    <input name="resp_coleta" type="text" readonly class="inputReadOnly8pt" id="resp_coleta" size="40" value="<%=(carregacol && col.getRepresentante().getId() != 0 ? col.getRepresentante().getNome().concat("#@#").concat(String.valueOf(col.getRepresentante().getId())) : "")%>" >
                                                    <input name="button4" type="button" class="botoes" onClick="controlador.acao('abrirLocalizar','localizarRepresentante');" value="...">
                                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="removerValorInput('resp_coleta')">
                                                </td>
                                            </tr>
                                        </table>		
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="8" class="tabela">
                                        <div align="center">Ajudante(s)</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="8">
                                        <table width="100%" border="0" cellspacing="1" cellpadding="2">
                                            <tbody id="corpoAjud">
                                                <tr class="Celula">
                                                    <td width="5%">
                                                        <div align="center">
                                                            <img src="img/add.gif" border="0" title="Adicionar ajudante" class="imagemLink" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=25','Ajudante');">
                                                        </div>
                                                    </td>
                                                    <td width="35%">
                                                        <div align="left">Nome</div>
                                                    </td>
                                                    <td width="20%">
                                                        <div align="left">Telefone</div>
                                                    </td>
                                                    <td width="20%">
                                                        <div align="left">2&ordm; Telefone</div>
                                                    </td>
                                                    <td width="15%">
                                                        <div align="right">Valor</div>
                                                    </td>
                                                    <td width="5%">
                                                        <div align="center"></div>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr class="tabela">
                                    <td width="100%" colspan="8">
                                        <div align="center">Movimenta&ccedil;&atilde;o de Pallets</div>
                                    </td>
                                </tr>
                                <tr name="trMovimentacao" id="trMovimentacao">
                                    <td colspan="8">
                                        <input type="hidden" name="max" id="max" value="0">
                                        <input type="hidden" id="idconsignatario"></input>
                                        <input type="hidden" id="con_rzs"></input>
                                        <input type="hidden" id="con_codigo" />
                                        <input type="hidden" id="con_cnpj" />
                                        <input type="hidden" name="indexAux" id="indexAux" value="0" size="10" class="inputtexto" /> 
                                        <input type="hidden" id="id"></input>
                                        <input type="hidden" id="descricao"></input>
                                        <input type="hidden" id="idCliente" value="">
                                        <input type="hidden" id="idPallet" value="">
                                        <table width="100%" border="0" class="bordaFina">
                                            <tbody id="tbMovimentacao" name="tbMovimentacao">
                                                <tr class="CelulaZebra1" >
                                                    <td width="2%">
                                                        <img src="img/add.gif" border="0" title="atribuir valor &agrave; tabela abaixo" class="imagemLink" style="vertical-align:middle;" onClick="addItensMovimentacao()">
                                                    </td>
                                                    <td width="12%" align="center">Nº Nota</td>
                                                    <td width="25%" align="center">Cliente</td>
                                                    <td width="8%" align="center">Data</td>
                                                    <td width="20%" align="center">Pallet</td>
                                                    <td width="8%" align="center">Quantidade</td>
                                                    <td width="6%" align="center">Tipo</td>
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
                                    <td>
                                        <div align="center">Notas Fiscais </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td> 
                                        <table width="100%" id="node_notes" border="0" cellpadding="1" cellspacing="2" style="width:100%; height:100%; border: 1 solid #000">
                                            <tr>
                                                <td width="1%" class="cellNotes">
                                                    <img src="img/add.gif" border="0" title="Adicionar uma nova Nota fiscal [F2]" class="imagemLink" onClick="javascript:incluiNF();">
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
                                                <td width="10%">
                                                    <div align="right">QTD NOTAS:</div>
                                                </td>
                                                <td width="6%">
                                                    <label id="qtdNF" >(0)</label>
                                                </td>
                                                <td width="10%">
                                                    <div align="right">TOTAIS&nbsp;&nbsp;</div>
                                                </td>
                                                <td width="9%">
                                                    <input id="totalNF" name="totalNF" value="0.00" readonly="true" size="10" class="inputReadOnly8pt"/>
                                                </td>
                                                <td width="7%">
                                                    <input id="totalPeso" name="totalPeso" value="0.00" readonly="true" size="10" class="inputReadOnly8pt"/>
                                                </td>
                                                <td width="36%">
                                                    <label id="totalVol" name="totalVol">0.00</label>
                                                </td>
                                                <td width="22%">&nbsp;</td>
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
                                <tr id="trOS" name="trOS">
                                    <td class="tabela">
                                        <div align="center">Servi&ccedil;os</div>
                                    </td>
                                </tr>
                                <tr id="tbOS" name="tbOS">
                                    <td>
                                        <table border="0" cellpadding="0" cellspacing="0" style="width:100%; height:100%; border: 1 solid #000">
                                            <tbody id="node_servs">
                                                <tr class="cellNotes"><!--class="cellNotes"-->
                                                    <td width="2%">
                                                        <img src="img/add.gif" border="0" title="Adicionar um novo serviço na OS" class="imagemLink" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=36','Servico')">
                                                    </td>
                                                    <td width="31%" >Servi&ccedil;o</td>
                                                    <td width="7%" >
                                                        <div id="lbDias" name="lbDias" style="display:none">Dias</div>
                                                    </td>
                                                    <td width="7%" >Quant.</td>
                                                    <td width="10%" >Unit&aacute;rio</td>
                                                    <td width="10%" >Total</td>
                                                    <td width="7%" >% ISS </td>
                                                    <td width="9%" >Valor ISS</td>
                                                    <td width="5%" >Trib</td>
                                                    <td width="5%" >Emb. ISS</td>
                                                    <td width="11%" >Nota Fiscal</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </div>			
                    <div class="panel" id="tab5">
                        <fieldset>
                            <table width="100%" border="0" class="bordaFina" align="center">
                                <tr>
                                    <td class="tabela">
                                        <div align="center">Ocorr&ecirc;ncias</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <table width="100%" border="0">
                                            <tbody id="corpoOcor">
                                                <tr class="Celula">
                                                    <td width="3%">
                                                        <div align="center">
                                                            <img src="img/add.gif" border="0" title="Adicionar Ocorrências" class="imagemLink" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=48','Ocorrencia_Coleta');">
                                                        </div>
                                                    </td>
                                                    <td width="18%">
                                                        <div align="left">
                                                            Descri&ccedil;&atilde;o
                                                        </div>
                                                    </td>
                                                    <td width="12%">
                                                        <div align="left">
                                                            Ocorr&ecirc;ncia em
                                                           
                                                        </div>
                                                    </td>
                                                    <td width="30%">
                                                        <div align="left">
                                                            Observa&ccedil;&atilde;o
                                                        </div>
                                                    </td>
                                                    <td width="9%">
                                                        <div align="left">
                                                            Quantidade
                                                        </div>
                                                    </td>
                                                    <td width="12%">
                                                        <div align="center">
                                                            Nota Fiscal
                                                        </div>
                                                    </td>
                                                    <td width="18%">
                                                        <div align="left">
                                                            <%if (cfg.isGeraGEMColeta()) {%>
                                                            Produto(gwLogis)
                                                            <%}%>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </div>			
                    <div class="panel" id="tab6">
                        <fieldset>
                            <table width="100%" border="0" class="bordaFina" align="center">
                                <tr>
                                    <td colspan = "8" class="tabela">
                                        <div align="center">Despesas em caso de carga fracionada</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="15%" class="TextoCampos">Di&aacute;ria:</td>
                                    <td width="10%" class="CelulaZebra2">
                                        <input name="diaria" class="fieldMin" type="text" id="diaria" onChange="seNaoFloatReset(this,'0.00')" value="<%=(carregacol ? Apoio.to_curr(col.getValorRateioDiaria()) : "0.00")%>" size="10" maxlength="10">
                                    </td>
                                    <td width="15%" class="TextoCampos">Ajudante:</td>
                                    <td width="10%" class="CelulaZebra2">
                                        <input name="diariaajud" type="text" id="diariaajud" onChange="seNaoFloatReset(this,'0.00')" value="<%=(carregacol ? Apoio.to_curr(col.getValorRateioAjudante()) : "0.00")%>" size="10" maxlength="10" class="fieldMin">
                                    </td>
                                    <td width="15%" class="TextoCampos">Pernoite:</td>
                                    <td width="10%" class="CelulaZebra2">
                                        <input name="valorPernoite" type="text" id="valorPernoite" onChange="seNaoFloatReset(this,'0.00')" value="<%=(carregacol ? Apoio.to_curr(col.getValorPernoite()) : "0.00")%>" size="10" maxlength="10" class="fieldMin">
                                    </td>
                                    <td width="15%" class="TextoCampos"></td>
                                    <td width="10%" class="CelulaZebra2"></td>
                                </tr>
                                <tr>
                                    <td colspan = "8" class="tabela">
                                        <div align="center">Despesas em caso de carga fechada</div>
                                    </td>
                                </tr>
                                <tr id="linhaValorCarga">
                                    <td class="TextoCampos">Valor Contrato:</td>
                                    <td class="CelulaZebra2">
                                        <input name="valorFrete" type="text" id="valorFrete" onBlur="javascript:seNaoFloatReset(this,'0.00');" value="<%=(carregacol ? Apoio.to_curr(col.getValorFrete()) : "0.00")%>" size="10" maxlength="30" class="fieldMin">
                                    </td>
                                    <td class="TextoCampos">Adiantamento:</td>
                                    <td class="CelulaZebra2">
                                        <input name="valorAdiantamento" type="text" id="valorAdiantamento" onBlur="javascript:seNaoFloatReset(this,'0.00');calcularSaldo()" value="<%=(carregacol ? Apoio.to_curr(col.getValorAdiantamento()) : "0.00")%>" size="10" maxlength="30" class="fieldMin">
                                    </td>
                                    <td class="TextoCampos">Saldo:</td>
                                    <td class="CelulaZebra2">
                                        <input name="valorSaldo" type="text" id="valorSaldo" onBlur="javascript:seNaoFloatReset(this,'0.00');" value="<%=(carregacol ? Apoio.to_curr(col.getValorSaldo()) : "0.00")%>" size="10" maxlength="30" class="fieldMin">
                                    </td>
                                    <td class="TextoCampos">Nº Contrato:</td>
                                    <td class="CelulaZebra2">
                                        <%=(carregacol && col.getContratoFrete().getIdcartafrete() != 0 ? "<div align='rigth' class='linkEditar' onclick='javascript:tryRequestToServer(function(){editarCarta(" + col.getContratoFrete().getIdcartafrete() + ");});'>" + col.getContratoFrete().getIdcartafrete() + "</div> " : "")%>
                                    </td>
                                </tr>
                                <%if (cfg.isCartaFreteAutomaticaColeta() && acao.equalsIgnoreCase("iniciar")){ %>
                                <tr>
                                    <td colspan = "8" class="tabela">
                                        <div align="center">Despesas com Contrato de Frete</div>
                                    </td>
                                </tr>
                              
                                <tr><!-- Início dos campos do frete -->
                                    <td colspan="8">
                                        <table width="100%">
                                            <tr>
                                                <td colspan="3" class="tabela" align="center">
                                                    <input name="chk_carta_automatica_coleta" type="checkbox" id="chk_carta_automatica_coleta" onclick="gerarContratoFrete()" value="checkbox"> Gerar Contrato de Frete com o Proprietário
                                                </td>
                                                <input name="plano_proprietario" type="hidden" id="plano_proprietario" class="inputReadOnly8pt" size="20" readonly="true" value="0">
						<input name="und_proprietario" type="hidden" id="und_proprietario" class="inputReadOnly8pt" size="20" readonly="true" value="0">
						<input name="valor_rota" type="hidden" id="valor_rota" class="inputReadOnly8pt" size="20" readonly="true" value="0">
						<input name="valor_maximo_rota" type="hidden" id="valor_maximo_rota" class="inputReadOnly8pt" size="20" value="0">
						<input name="id_rota_viagem" type="hidden" id="id_rota_viagem" class="inputReadOnly8pt" size="20" value="0">
						<input name="tipo_valor_rota" type="hidden" id="tipo_valor_rota" class="inputReadOnly8pt" size="20" readonly="true" value="f">
						<input name="debito_prop" type="hidden" id="debito_prop" size="10" value="0">
						<input name="percentual_desconto_prop" type="hidden" id="percentual_desconto_prop" size="10" value="0">
						<input name="percentual_ctrc_contrato_frete" type="hidden" id="percentual_ctrc_contrato_frete" size="10" value="0">
						<input name="valor_rota_viagem_2" type="hidden" id="valor_rota_viagem_2" class="inputReadOnly8pt" size="20" readonly="true" value="0">
						<input name="valor_pedagio_rota" type="hidden" id="valor_pedagio_rota" class="inputReadOnly8pt" size="20" readonly="true" value="0">
						<input name="rota_taxa_fixa" type="hidden" id="rota_taxa_fixa" class="inputReadOnly8pt" size="20" value="0">
						<input name="distancia_km" type="hidden" id="distancia_km" class="inputReadOnly8pt" size="20" value="0">
						<input name="valor_entrega_rota" type="hidden" id="valor_entrega_rota" class="inputReadOnly8pt" size="20" readonly="true" value="0">
						<input name="qtd_entregas_rota" type="hidden" id="qtd_entregas_rota" class="inputReadOnly8pt" size="20" readonly="true" value="0">
						<input name="base_ir_prop_retido" type="hidden" id="base_ir_prop_retido" class="inputReadOnly8pt" size="20" readonly="true" value="0">
						<input name="ir_prop_retido" type="hidden" id="ir_prop_retido" class="inputReadOnly8pt" size="20" readonly="true" value="0">
						<input name="base_inss_prop_retido" type="hidden" id="base_inss_prop_retido" class="inputReadOnly8pt" size="20" readonly="true" value="0">
						<input name="inss_prop_retido" type="hidden" id="inss_prop_retido" value="0.00" size="8" maxlength="12" class="inputReadOnly8pt style1" readonly>
                                                <input type="hidden" name="perc_adiant" id="perc_adiant" value="0">
                                                <input type="hidden" name="countDespesaCarta" id="countDespesaCarta" value="0">
                                                <input name="tipo_desconto_prop" type="hidden" id="tipo_desconto_prop" value="0.00">
                                                <input name="motorista_valor_minimo" type="hidden" id="motorista_valor_minimo" value="0.00">
                                                <input name="rota_valor_minimo" type="hidden" id="rota_valor_minimo" value="0.00">
                                            </tr>
                                            <tr>
                                                <td width="10%" class="TextoCampos">Proprietário:</td>
                                                <td width="40%" class="CelulaZebra2">
                                                    <input name="vei_prop" type="text" id="vei_prop" class="inputReadOnly8pt" size="40" readonly="true" value="">
                                                    <input name="vei_prop_cgc" type="text" id="vei_prop_cgc" class="inputReadOnly8pt" size="20" readonly="true" value="">
                                                    <input type="hidden" name="idproprietarioveiculo" id="idproprietarioveiculo" value="0">
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos">Seguradora:</td>
                                                <td class="CelulaZebra2">
						<input name="nome_seguradora" type="text" id="nome_seguradora" class="inputReadOnly8pt" size="27" readonly="true" value="">
						<input name="localiza_seguradora" type="button" class="botoes" id="localiza_seguradora" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=57','Seguradora','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
						Liberação:<input name="motor_liberacao_carta" type="text" id="motor_liberacao_carta" class="fieldMin" size="15" value="">
						<input name="seguradora_id" type="hidden" id="seguradora_id" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos" width="25%">Agente de carga:</td>
                                                <td class="CelulaZebra2" width="75%">
                                                        <input name="nome_agente_carga" type="text" id="nome_agente_carga" class="inputReadOnly8pt" value="" size="40"  readonly="true">
                                                        <input name="localiza_agente_carga" type="button" class="botoes" id="localiza_agente_carga" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.AGENTE_CARGA%>', 'Agente_carga');" style="font-size:8pt;">
                                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Agente de Carga" onClick="javascript:getObj('idagente_carga').value = 0;javascript:getObj('nome_agente_carga').value = '';">
                                                        <input type="hidden" id="idagente_carga" name="idagente_carga" value="0">
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="TextoCampos">Observação:</td>
                                                <td class="CelulaZebra2">
                                                        <input name="obs_carta_frete" type="text" id="obs_carta_frete" class="fieldMin" value="" size="60" >
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="3">
                                                    <table width="100%" border="0" cellspacing="1" cellpadding="2">
							<tr class="Celula">
								<td width="16%" >Frete</td>
								<td width="16%" >Outros</td>
								<td width="16%" >Pedágio</td>
								<td width="21%" class="style1"><input name="chk_reter_impostos" type="checkbox" id="chk_reter_impostos" value="checkbox" onClick="calcularFreteCarreteiro();"> Impostos</td>
								<td width="16%" class="style1" >Desconto</td>
                                <td width="8%" class="style1" ${(not configuracao.descontoAutomaticoAbastecimento) ? "style='display: none;'" : ""}><label for="abastecimentos">Abast.</label></td>
								<td width="15%" >Líquido</td>
							</tr>
							<tr>
								<td class="CelulaZebra2"><input name="cartaValorFrete" type="text" id="cartaValorFrete" value="0.00" size="8" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.00');validarFreteCarreteiro();calcularFreteCarreteiro();"></td>
								<td class="CelulaZebra2"><input name="cartaOutros" type="text" id="cartaOutros" value="0.00" size="8" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.00');calcularFreteCarreteiro();"></td>
								<td class="CelulaZebra2"><input name="cartaPedagio" type="text" id="cartaPedagio" value="0.00" size="8" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.00');calcularFreteCarreteiro();"></td>
								<td class="CelulaZebra2">
									<input name="cartaImpostos" type="text" id="cartaImpostos" value="0.00" size="8" maxlength="12" class="inputReadOnly8pt style1" onBlur="javascript:seNaoFloatReset(this,'0.00');" readOnly>
									<img src="img/calculadora.png" border="0" align="absbottom" class="imagemLink" title="Detalhar Impostos" onClick="$('trImpostosCarta').style.display = '';">
								</td>
								<td class="CelulaZebra2">
                                    <input id="percentualRetencao" name="percentualRetencao" type="text"
                                           class="fieldMin style1" size="5" maxlength="9" value="0"
                                           onchange="seNaoFloatReset(this, '0.00'); calcularFreteCarreteiro();">&nbsp;%
                                    <input name="cartaRetencoes" type="text" id="cartaRetencoes" value="0.00" size="8"
                                           maxlength="12" class="fieldMin style1"
                                           onBlur="javascript:seNaoFloatReset(this,'0.00');calcularFreteCarreteiro();">
									<input name="mot_outros_descontos_carta" type="hidden" id="mot_outros_descontos_carta" value="0.00" size="8" maxlength="12">
                                    <c:set var="cfg" value="<%=cfg%>" />
                                    <c:choose>
                                        <c:when test="${param.acao eq 'iniciar' && cfg.tipoVlConMotor eq 'f' && cfg.vlConMotor != 0}">
                                            <script>
                                                $('cartaRetencoes').value = colocarVirgula(parseFloat('${cfg.vlConMotor}'));
                                                readOnly($('percentualRetencao'), 'inputReadOnly8pt');
                                            </script>
                                        </c:when>
                                        <c:when test="${param.acao eq 'iniciar' && cfg.tipoVlConMotor eq 'p' && cfg.vlConMotor != 0}">
                                            <script>
                                                $('percentualRetencao').value = parseFloat('${cfg.vlConMotor}');
                                                readOnly($('cartaRetencoes'), 'inputReadOnly8pt');
                                            </script>
                                        </c:when>
                                    </c:choose>
								</td>
                                <td class="celulaZebra2 style1" ${(not cfg.descontoAutomaticoAbastecimento) ? "style='display: none;'" : ""}>
                                    <input id="abastecimentos" name="abastecimentos" type="text"
                                           class="fieldMin style1 inputReadOnly" size="9" maxlength="9" value="0,00"
                                           onchange="seNaoFloatReset(this, '0,00')" readonly>
                                    <input type="hidden" name="ids_abastecimentos" id="ids_abastecimentos">
                                </td>
								<td class="CelulaZebra2"><input name="cartaLiquido" type="text" id="cartaLiquido" value="0.00" size="8" maxlength="12" class="inputReadOnly8pt" readonly onBlur="javascript:seNaoFloatReset(this,'0.00');"></td>
							</tr>
							<tr id="trImpostosCarta" name="trImpostosCarta" style="display:none;">
								<td class="TextoCampos">INSS:</td>
								<td class="CelulaZebra2">
                                                                    <input name="valorINSSInteg" type="hidden" id="valorINSSInteg" value="0.00" size="8" maxlength="12">
                                                                    <input name="valorINSS" type="text" id="valorINSS" value="0.00" size="8" maxlength="12" class="inputReadOnly8pt style1" readonly>
                                                                    <input name="baseINSS" type="hidden" id="baseINSS" value="0.00" size="8" maxlength="12">
                                                                    <input name="aliqINSS" type="hidden" id="aliqINSS" value="0.00" size="8" maxlength="12">
								</td>
								<td class="TextoCampos">SEST:</td>
								<td class="CelulaZebra2">
                                                                    <input name="valorSESTInteg" type="hidden" id="valorSESTInteg" value="0.00" size="8" maxlength="12">
                                                                    <input name="valorSEST" type="text" id="valorSEST" value="0.00" size="8" maxlength="12" class="inputReadOnly8pt style1" readonly>
                                                                    <input name="baseSEST" type="hidden" id="baseSEST" value="0.00" size="8" maxlength="12">
                                                                    <input name="aliqSEST" type="hidden" id="aliqSEST" value="0.00" size="8" maxlength="12">
								</td>
								<td class="TextoCampos">IR:</td>
								<td class="CelulaZebra2">
                                                                    <input name="valorIRInteg" type="hidden" id="valorIRInteg" value="0.00" size="8" maxlength="12">
                                                                    <input name="valorIR" type="text" id="valorIR" value="0.00" size="8" maxlength="12" class="inputReadOnly8pt style1" readonly>
                                                                    <input name="baseIR" type="hidden" id="baseIR" value="0.00" size="8" maxlength="12">
                                                                    <input name="aliqIR" type="hidden" id="aliqIR" value="0.00" size="8" maxlength="12">
								</td>
							</tr>
						</table>
					
                                                </td>
                                            </tr>
                                        </table>
                                        
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="8">
						<table width="100%" border="0" cellspacing="1" cellpadding="2">
							<tr class="Celula">
								<td width="10%"></td>
								<td width="12%">Valor</td>
								<td width="18%">Data</td>
								<td width="17%">F. Pag</td>
								<td width="28%">Conta/Ag.Pag.</td>
								<td width="15%">Doc</td>
							</tr>
							<tr>
								<td class="TextoCampos">Adiant.:</td>
                                                                <td class="TextoCampos"><input name="cartaValorAdiantamento" type="text" id="cartaValorAdiantamento" value="0.00" size="6" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.00');alteraFpag('a');calcularAdiantamento();"></td>
								<td class="TextoCampos"><input name="cartaDataAdiantamento" type="text" id="cartaDataAdiantamento" value="<%=(Apoio.getDataAtual())%>" class="fieldDate" onChange="javascript:alertInvalidDate(this);" size="9" maxlength="10" style="font-size:8pt;"></td>
								<td class="TextoCampos">
									<select name="cartaFPagAdiantamento" id="cartaFPagAdiantamento" class="fieldMin" style="width:70px;" onChange="javascript:alteraFpag('a');">
                                                                            <%if (cfg.isCartaFreteAutomaticaColeta() && acao.equalsIgnoreCase("iniciar")){
											BeanConsultaFPag fpag = new BeanConsultaFPag();
											fpag.setConexao(Apoio.getUsuario(request).getConexao());
											fpag.MostrarTudoCartaFrete(String.valueOf(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe()));
											ResultSet rsFpag = fpag.getResultado();
											while (rsFpag.next()){
												fpagCartaFrete += "<option value='"+rsFpag.getString("idfpag")+"' " + (rsFpag.getInt("idfpag") == cfg.getFpag().getIdFPag() ? "selected" : "") +" >"+rsFpag.getString("descfpag")+"</option>";
											}
											rsFpag.close();
                						}%>
										<%=fpagCartaFrete%>
									</select>
								</td>
								<td class="TextoCampos">
									<select name="contaAdt" id="contaAdt" class="fieldMin" style="width:120px;display:none;" onChange="javascript:alteraFpag('a');">
                                                                            <%if (cfg.isCartaFreteAutomaticaColeta() && acao.equals("iniciar")){
											BeanConsultaConta contaAd = new BeanConsultaConta();
											contaAd.setConexao(Apoio.getUsuario(request).getConexao());
											contaAd.mostraContas(0, true, limitarUsuarioVisualizarConta, idUsuario);
											ResultSet rsC = contaAd.getResultado();
											while (rsC.next()){%>
												<option value="<%=rsC.getString("idconta")%>"><%=rsC.getString("numero") +"-"+ rsC.getString("digito_conta") +" / "+ rsC.getString("banco")%></option>
											<%}rsC.close();
										}%>
									</select>
									<input name="agente" type="text" id="agente" class="inputReadOnly8pt" size="14" readonly="true" value="" style="display:none;">
									<input name="localiza_agente_adiantamento" type="button" class="botoes" id="localiza_agente_adiantamento" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=16','Agente','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');" style="display:none;">
									<input name="idagente" type="hidden" id="idagente" class="inputReadOnly8pt" size="15" readonly="true" value="0">
									<input name="plano_agente" type="hidden" id="plano_agente" class="inputReadOnly8pt" size="15" readonly="true" value="0">
									<input name="und_agente" type="hidden" id="und_agente" class="inputReadOnly8pt" size="15" readonly="true" value="0">
								</td>
								<td class="CelulaZebra2">
									<%if (cfg.isControlarTalonario()){%>
										<select name="cartaDocAdiantamento_cb" id="cartaDocAdiantamento_cb" class="fieldMin">
										</select>
									<%}else{%>
										<input name="cartaDocAdiantamento" type="text" id="cartaDocAdiantamento" size="6" maxlength="12" class="fieldMin">
									<%}%>
								</td>
							</tr>
							<tr>
								<td class="TextoCampos">Saldo:</td>
								<td class="TextoCampos"><input name="cartaValorSaldo" type="text" id="cartaValorSaldo" value="0.00" size="6" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.00');alteraFpag('s');calcularAdiantamento();"></td>
								<td class="TextoCampos"><input name="cartaDataSaldo" type="text" id="cartaDataSaldo" value="<%=(Apoio.getDataAtual())%>" class="fieldDate" onChange="javascript:alertInvalidDate(this);" size="9" maxlength="10" style="font-size:8pt;"></td>
								<td class="TextoCampos">
									<select name="cartaFPagSaldo" id="cartaFPagSaldo" class="fieldMin" style="width:70px;" onChange="javascript:alteraFpag('s');">
										<%if (cfg.isCartaFreteAutomaticaColeta() && acao.equalsIgnoreCase("iniciar")){%>
                                                                                    <%=fpagCartaFrete%>
                                                                                <%}%>
									</select>
								</td>
								<td class="TextoCampos">
									<input name="agentesaldo" type="text" id="agentesaldo" class="inputReadOnly8pt" size="14" readonly="true" value="" style="display:none;">
									<input name="localiza_agente_saldo" type="button" class="botoes" id="localiza_agente_saldo" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=19','Agente_Saldo','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');" style="display:none;">
									<input name="idagentesaldo" type="hidden" id="idagentesaldo" class="inputReadOnly8pt" size="15" readonly="true" value="0">
									<input name="plano_agente_saldo" type="hidden" id="plano_agente_saldo" class="inputReadOnly8pt" size="15" readonly="true" value="0">
									<input name="und_agente_saldo" type="hidden" id="und_agente_saldo" class="inputReadOnly8pt" size="15" readonly="true" value="0">
								</td>
								<td class="CelulaZebra2"><input name="cartaDocSaldo" type="text" id="cartaDocSaldo" size="6" maxlength="12" class="fieldMin"></td>
							</tr>
							<tr name="trCartaCC" id="trCartaCC" style="display:none;">
								<td class="TextoCampos">C/C.:</td>
								<td class="TextoCampos"><input name="cartaValorCC" type="text" id="cartaValorCC" value="0.00" size="6" maxlength="12" class="fieldMin" readonly></td>
								<td class="TextoCampos"><input name="cartaDataCC" type="text" id="cartaDataCC" value="<%=(Apoio.getDataAtual())%>" class="fieldDate" onChange="javascript:alertInvalidDate(this);" size="9" maxlength="10" style="font-size:8pt;"></td>
								<td class="TextoCampos"><input name="cartaFPagCC" type="hidden" id="cartaFPagCC" value="2"></td>
								<td class="TextoCampos"><input name="contaCC" type="hidden" id="contaCC" value="<%=(cfg.getContaAdiantamentoFornecedor().getIdConta())%>"></td>
								<td class="CelulaZebra2"></td>
							</tr>
						</table>
					</td>
                                </tr>
                                <tr >
                                    <td colspan="8">
                                        <table width="100%">
                                            <tr class="Celula">
                                              <td width="5%">
                                                <img src="img/add.gif" border="0" onClick="incluiDespesaCarta();" title="Adicionar uma despesa" class="imagemLink">
                                              </td>
                                              <td  colspan="2" width="95%">Despesas de viagem</td>
                                            </tr>
                                        </table>
                                    </td>
                                    
                                </tr>
                                <tr id="trDespesaCarta" name="trDespesaCarta" style="display:none;" >
                                <td colspan="8">
                                        <input name="fornecedor" type="hidden" id="fornecedor" class="inputReadOnly8pt" size="15" readonly="true" value="Fornecedor">
                                        <input type="hidden" name="idfornecedor" id="idfornecedor" value="0">
                                        <input name="idplanocusto_despesa" type="hidden" id="idplanocusto_despesa" class="inputReadOnly8pt" size="25" readonly="true" value="0">
                                        <input name="plcusto_descricao_despesa" type="hidden" id="plcusto_descricao_despesa" class="inputReadOnly8pt" size="25" readonly="true" value="">
                                        <input name="plcusto_conta_despesa" type="hidden" id="plcusto_conta_despesa" class="inputReadOnly8pt" size="25" readonly="true" value="">
                                        <input name="idplcustopadrao" type="hidden" id="idplcustopadrao" class="inputReadOnly8pt" size="25" readonly="true" value="0">
                                        <input name="descricaoplcusto" type="hidden" id="descricaoplcusto" class="inputReadOnly8pt" size="25" readonly="true" value="">
                                        <input name="contaplcusto" type="hidden" id="contaplcusto" class="inputReadOnly8pt" size="25" readonly="true" value="">
                                        <table width="100%">
                                            <tbody id="tbDespesaCarta"></tbody>
                                        </table>
                                </td>
                                
				</tr>
                                <!-- Fim dos campos do Frete -->
                                <% } %>
                                <tr>
                                    <td colspan = "8" class="tabela">
                                        <div align="center">Taxas de seguro</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan = "4" class="celula">Roubo</td>
                                    <td colspan = "4" class="celula">Tombamento</td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">Normal:</td>
                                    <td class="CelulaZebra2">
                                        <input name="taxa_roubo" class="inputReadOnly8pt" type="text" id="taxa_roubo" onChange="seNaoFloatReset(this,'0.00')" value="<%=(carregacol ? col.getTaxaRoubo() : "0.000")%>" size="10" maxlength="10" readonly>
                                    </td>
                                    <td class="TextoCampos">Urbano:</td>
                                    <td class="CelulaZebra2">
                                        <input name="taxa_roubo_urbano" class="inputReadOnly8pt" type="text" id="taxa_roubo_urbano" onChange="seNaoFloatReset(this,'0.00')" value="<%=(carregacol ? col.getTaxaRouboUrbano() : "0.000")%>" readonly size="10" maxlength="10">
                                    </td>
                                    <td class="TextoCampos">Normal:</td>
                                    <td class="CelulaZebra2">
                                        <input name="taxa_tombamento" class="inputReadOnly8pt" type="text" id="taxa_tombamento" onChange="seNaoFloatReset(this,'0.00')" value="<%=(carregacol ? col.getTaxaTombamento() : "0.000")%>" readonly size="10" maxlength="10">
                                    </td>
                                    <td class="TextoCampos">Urbano:</td>
                                    <td class="CelulaZebra2">
                                        <input name="taxa_tombamento_urbano" class="inputReadOnly8pt" type="text" id="taxa_tombamento_urbano" onChange="seNaoFloatReset(this,'0.00')" value="<%=(carregacol ? col.getTaxaTombamentoUrbano() : "0.000")%>" readonly size="10" maxlength="10">
                                    </td>
                                </tr>

                                <tr>
                                    <td colspan="9">
                                        <table width="100%">
                                            <tr>
                                                <td class="tabela" colspan="10">
                                                    <div align="center">Despesas da Coleta</div>
                                                </td>
                                            </tr>
                                            <tr class="celula">
                                                <td width="3%">
                                                    <div align="center">
                                                        <img src="img/add.gif" border="0" class="imagemLink"
                                                             title="Adicionar uma nova despesa" onClick="addDespesa();"></span>
                                                        <input type="hidden" id="maxDespesa" name="maxDespesa"
                                                               value="0" />
                                                    </div>
                                                </td>
                                                <td width="8%"><div align="center">Despesa</div></td>
                                                <td width="6%"><div align="center">Espécie</div></td>
                                                <td width="7%"><div align="center">Série</div></td>
                                                <td width="7%"><div align="center">NF</div></td>
                                                <td width="8%"><div align="center">Emissão</div></td>
                                                <td width="25%"><div align="center">Fornecedor</div></td>
                                                <td width="25%"><div align="center">Historico</div></td>
                                                <td width="8%"><div align="center">Valor</div></td>
                                                <td width="3%"><div align="center"></div></td>
                                            </tr>
                                            <tbody id="bodyDespesa" name="bodyDespesa" >

                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </div>
                    <div class="panel" id="tab7" style='display: <%= carregacol && nivelUser == 4 ? "" : "none" %>'>
                        <fieldset>
                            <table width="100%" border="0" class="bordaFina" align="center">
                               <tr>
                                    <td colspan="3"  class="tabela">
                                        <div><%@include file="/gwTrans/template_auditoria.jsp" %></div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="8">
                                        <table width="100%"  border="0">
                                            <tr>
                                                <td width="15%" class="TextoCampos">Incluso:</td>
                                                <td width="35%" class="CelulaZebra2">Em: <%=(carregacol ? fmt.format((col.getCreatedAt() != null ? col.getCreatedAt() : new Date())) : "")%><br>Por: <%=(carregacol) ? col.getCreatedBy().getNome() : ""%></td>
                                                <td width="15%" class="TextoCampos">Alterado:</td>
                                                <td width="35%" class="CelulaZebra2">Em: <%=(carregacol && col.getUpdateAt() != null) ? fmt.format(col.getUpdateAt()) : ""%><br>Por: <%=(carregacol && col.getUpdatedBy().getNome() != null ? col.getUpdatedBy().getNome() : "")%></td>
                                            </tr>
                              </table>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>   
                    </div>                  
                </div>
            </div>
            <br>
            <div align="center">
                <table width="80%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                    <tr>
                        <td colspan="3" class="tabela">
                            <div align="center">Outras Informa&ccedil;&otilde;es</div>
                        </td>
                    </tr>
                    <tr>
                        <td width="10%" class="TextoCampos">Observa&ccedil;&atilde;o:</td>
                        <td width="60%" class="CelulaZebra2">
                            <textarea cols="80" rows="5" id="obs" name="obs" class="fieldMin" onBlur=""><%=(carregacol ? col.getObs() : "")%></textarea>
                            <input name="button2" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=28','Observacao');" value="...">
                        </td>
                        <td width="30%" class="TextoCampos">
                            <div align="center" style="display:<%=(carregacol && !col.getNumeroPedidoCobranca().equals("") ? "none" : "")%>;">
                                <input name="chk_coleta_cobranca" type="checkbox" id="chk_coleta_cobranca"  value="checkbox" onClick="javascript:mostraCobranca();" >
                                Coleta / OS apenas para cobran&ccedil;a 
                            </div>
                            <label style="display:<%=(carregacol && !col.getNumeroPedidoCobranca().equals("") ? "" : "none")%>;">Cobrada na coleta/OS Nº:<%=(carregacol ? col.getNumeroPedidoCobranca() : "")%></label>
                            </div>
                        </td>
                    </tr>
                    <tr name="tr_cobranca" id="tr_cobranca" style="display:none ">
                        <td colspan="3">
                            <table width="100%"  border="0" cellspacing="1" cellpadding="2">
                                <tr class="celula">
                                    <td width="50%">
                                        <div align="center">Coletas/OS dessa coleta de cobran&ccedil;a</div>
                                    </td>
                                    <td width="50%">
                                        <div align="center">
                                            <input  name="bt_selecionar_coleta" type="button" id="bt_selecionar_coleta" class="botoes" value="Selecionar Coletas/OS" onClick="javascript:tryRequestToServer(function(){localizaColeta();});">
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <label id="lbCobranca"></label>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                  </table>
                <br>
                <table width="80%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                    <tr class="CelulaZebra2">
                        <td colspan="8">
                            <% if (nivelUser >= 2) {%>
                    <center>
                        <input name="salva" type="button" class="botoes" id="salva" value="Salvar" onClick="javascript:tryRequestToServer(function(){salvar();});">
                    </center>
                    <%}%>
                    </td>
                    </tr>
                </table>
            </div>
        </form>
        <div class="localiza">
        </div>
        <div class="cobre-tudo"></div>
    </body>
</html>
