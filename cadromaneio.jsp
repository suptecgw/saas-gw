<%@page import="filial.BeanFilial"%>
<%@page import="com.thoughtworks.xstream.io.json.JettisonMappedXmlDriver"%>
<%@page import="com.thoughtworks.xstream.XStream"%>
<%@page import="nucleo.autorizacao.tipoautorizacao.TipoAutorizacao"%>
<%@page import="br.com.gwsistemas.configuracao.email.caixaSaida.CaixaSaidaBO"%>
<%@page import="br.com.gwsistemas.configuracao.email.caixaSaida.CaixaSaida"%>
<%@page import="cliente.tipoProduto.ConsultaTipoProduto"%>
<%@page import="br.com.gwsistemas.cfe.ndd.CategoriaVeiculoNddBO"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@page import="br.com.gwsistemas.cfe.pamcard.CategoriaVeiculoBO"%>
<%@page import="conhecimento.cartafrete.BeanPagamentoCartaFrete"%>
<%@page import="mov_banco.conta.BeanConsultaConta"%>
<%@page import="fpag.BeanConsultaFPag"%>
<%@ page contentType="text/html" language="java"
         import="nucleo.Apoio,nucleo.imagem.Imagem,java.io.File,conhecimento.BeanConsultaConhecimento,nucleo.EnviaEmail,
         java.sql.*,nucleo.imagem.ConhecimentoImagemDAO,usuario.BeanUsuario,nucleo.BeanConfiguracao,
         nucleo.BeanLocaliza,
         conhecimento.romaneio.BeanConsultaRomaneio,
         conhecimento.romaneio.BeanCadRomaneio,
         conhecimento.romaneio.BeanCtrcRomaneio,
         conhecimento.coleta.BeanAjudanteColeta,
         java.text.SimpleDateFormat" %>

<script language="JavaScript"  src="script/<%=Apoio.noCacheScript("ie.js")%>" type="text/javascript"></script>
<script language="javascript" src="script/<%=Apoio.noCacheScript("funcoes.js")%>" type=""></script>
<script language="JavaScript"  src="script/<%=Apoio.noCacheScript("funcoes_gweb.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("impostos.js")%>" type="text/javascript"></script>
<script language="JavaScript"  src="script/<%=Apoio.noCacheScript("builder.js")%>"   type="text/javascript"></script>
<script language="JavaScript"  src="script/<%=Apoio.noCacheScript("prototype_1_6.js")%>" type="text/javascript"></script>
<script language="JavaScript"  src="script/<%=Apoio.noCacheScript("jquery.js")%>" type="text/javascript"></script>
<script language="JavaScript"  src="script/<%=Apoio.noCacheScript("mascaras.js")%>" type="text/javascript"></script>
<script language="JavaScript"  src="script/<%=Apoio.noCacheScript("LogAcoesAuditoria.js")%>" type="text/javascript"></script>
<script language="javascript" src="${homePath}/script/funcoesTelaCadRomaneio.js?v=${random.nextInt()}" type="text/javascript"></script>

<% 
    
    String fpagCartaFrete = "";
    
    int nivelUser = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadromaneio") : 0);
    int nivelAnaliseCredito = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("analisecreditocliente") : 0);
    int nivelUserCtrc = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadconhecimento") : 0);
    int nivelUserColeta = Apoio.getUsuario(request).getAcesso("cadcoleta");
    int nivelUserAlteraImposto = Apoio.getUsuario(request).getAcesso("alteraimpostoscartafrete");
    int nvAlFrete = Apoio.getUsuario(request).getAcesso("alttabprecolanccontrfrete");
    int nivelUserAutorizarPagamento = Apoio.getUsuario(request).getAcesso("liberarromaneioparapagamento");
    int nivelUserAutorizarContrato = Apoio.getUsuario(request).getAcesso("autorizarcontrato");
    int nivelUserMarcarComprovanteBaixaEntradaCte = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("marcarComprovBaixaEntradaCte") : 0);
    SimpleDateFormat fmtHora = new SimpleDateFormat("HH:mm");
    String horaAtual;
    // se a filial usa horario VERAO e se a UF estiver na lista vai pegar com time zone.
    if (Apoio.getUsuario(request).getFilial().isIsAtivarHoraVerao() 
            && (null != Apoio.getConfiguracao(request).getListaUfTimeZone().get(Apoio.getUsuario(request).getFilial().getUf()))) {
        String timeZone = Apoio.getConfiguracao(request).getListaUfTimeZone().get(Apoio.getUsuario(request).getFilial().getUf());
        // colocando a logica de Godzila
        Calendar c = Calendar.getInstance();
        c.setTime(Apoio.fmt(Apoio.getDataAtual().concat(" ").concat(Apoio.getHoraAtual()),"dd/MM/yyyy HH:mm"));
        c.setTimeZone(TimeZone.getTimeZone(timeZone));
        c.add(Calendar.HOUR, 1);
        horaAtual = fmtHora.format(c.getTime());
    }else{
        horaAtual = Apoio.getHoraAtual();
    }
    
    boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
    int idUsuario = Apoio.getUsuario(request).getIdusuario();

    if (Apoio.getUsuario(request) == null || nivelUser == 0) {
        response.sendError(response.SC_FORBIDDEN);
    }
    
    BeanConfiguracao cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    //Carregando as configurações
    cfg.CarregaConfig();
    
    boolean isAutorizaPagamento = false;

%>
<jsp:useBean id="cadrom" class="conhecimento.romaneio.BeanCadRomaneio" />
<jsp:useBean id="rom" class="conhecimento.romaneio.BeanRomaneio" />

<%String acao = (request.getParameter("acao") == null || nivelUser == 0 ? "" : request.getParameter("acao"));
    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
    cadrom = new BeanCadRomaneio();
    cadrom.setConexao(Apoio.getUsuario(request).getConexao());
    boolean carregarom = !(acao.equals("incluir") || acao.equals("atualizar") || acao.equals("iniciar"));

    if (acao.equals("localizaCtrcColeta")) {
        String resultado = "";
        //String campo = (request.getParameter("campo") == null ? "idcliente" : request.getParameter("campo"));

        BeanConsultaRomaneio consultaRomaneio = new BeanConsultaRomaneio();
        String filial = "";
        String valor = request.getParameter("valor") == null ? "" : " nfiscal = '" + request.getParameter("valor") + "'";
        String serie = request.getParameter("serieConsulta") == null ? "" : request.getParameter("serieConsulta");
        serie = (serie.equals("") || request.getParameter("tipo").equals("COLETA") ? "" : " AND serie = '" + serie + "'");
        //
        String tipo = "";
        String remetente = "";

        if (request.getParameter("tipo").equals("NUMERO_NFE")) {
            tipo = "";
            remetente = (request.getParameter("idRemetente") == "0" || request.getParameter("idRemetente") == null) ? "" : " and idremetente=" + request.getParameter("idRemetente");
            valor = request.getParameter("valor") == null ? "" : " (select idconhecimento from nota_fiscal where numero ='" + request.getParameter("valor") + "' AND serie = '" + request.getParameter("serieConsulta") + "' " + remetente + " LIMIT 1)= idmovimento ";
            serie = "";
        } else if (request.getParameter("tipo").equals("CHAVE_NFE")) {
            tipo = "";//'5104'
//            remetente = (request.getParameter("idRemetente") == "0" || request.getParameter("idRemetente") == null) ? "" : " and idremetente=" + request.getParameter("idRemetente");
            valor = request.getParameter("valor") == null ? "" : " (select idconhecimento from nota_fiscal where chave_acesso ='" + request.getParameter("valor") + "' " + remetente + " )= idmovimento ";
            serie = "";
        } else if (request.getParameter("tipo").equals("CHAVE_CTE")) {
            tipo = "";
            valor = request.getParameter("valor") == null ? "" : " chave_acesso_cte = '" + request.getParameter("valor") + "' and chave_acesso_cte <> '0 '";
            serie = "";
        } else if (request.getParameter("tipo").equals("CHAVE_NFE_NUMERO")) {
            tipo = "";
            remetente = (request.getParameter("idRemetente") == "0" || request.getParameter("idRemetente") == null) ? " and idremetente= 0 " : " and idremetente= " + request.getParameter("idRemetente");
            valor = request.getParameter("valor") == null ? "" : " (select idconhecimento from nota_fiscal where chave_acesso ='" + request.getParameter("valor") + "' " + remetente + " LIMIT 1) = idmovimento ";
            serie = "";
        } else if ("N_LOCALIZADOR".equals(request.getParameter("tipo"))) {
            tipo = "";
            valor = request.getParameter("valor") == null ? "" : " numero_localizador_conhecimento = " + Apoio.SqlFix(request.getParameter("valor")) + " and numero_localizador_conhecimento <> '0' ";
            serie = "";
        } else {
            tipo = " and tipo = '" + request.getParameter("tipo") + "'";
            if (request.getParameter("tipo").equals("COLETA")) {
                filial = " and filial_id = '" + request.getParameter("filial") + "'";
            } else {
                filial = " and filial_id = '" + request.getParameter("filialCombo") + "'";
            }
        }

        consultaRomaneio.setConexao(Apoio.getUsuario(request).getConexao());
        boolean retorno = consultaRomaneio.consultaCtrcColetaAjax(valor, filial, tipo, serie);

        ResultSet rs = null;

        if (!retorno) {
            resultado = "null";
        } else {
            rs = consultaRomaneio.getResultado();
            if (rs.next()) {
                resultado = rs.getInt("idmovimento") + "!=!"
                        + rs.getString("nfiscal") + "!=!"
                        + fmt.format(rs.getDate("dtemissao")) + "!=!"
                        + rs.getString("filial") + "!=!"
                        + rs.getString("remetente") + "!=!"
                        + rs.getString("destinatario") + "!=!"
                        + rs.getFloat("totalPrestacao") + "!=!"
                        + rs.getString("tipo") + "!=!"
                        + "false" + "!=!"
                        + rs.getString("peso") + "!=!"
                        + rs.getString("volume") + "!=!"
                        + rs.getDate("baixa_em") + "!=!"
                        + rs.getInt("idromaneio") + "!=!" + //idromaneio
                        rs.getBoolean("is_resolvido") + "!=!" + //ctrc resolvido
                        rs.getString("romaneio") + "!=!" + //Número romaneio
                        rs.getString("is_bloqueado") + "!=!" + //Número romaneio
                        rs.getString("cubagem") + "!=!" + //Cubagem
                        rs.getString("cidade_destino_id") + "!=!" + //id da cidade de destino
                        rs.getString("cidade_destino") + "!=!" + //cidade de destino
                        rs.getString("uf_destino") + "!=!" + //uf de destino
                        rs.getString("consignatario_id") + "!=!" + //consignatario_id
                        rs.getDouble("valor_nf") + "!=!" + //valorNF
                        rs.getDouble("valor_frete") + "!=!" +
                        rs.getDouble("valor_peso") + "!=!" + 
                        rs.getDate("dtchegada") + "!=!"+
                        rs.getString("tipo_ctrc") + "!=!"+
                        rs.getString("idromaneio"); 
                        
                        //addCtrc(idCtrc, nfiscal, emissao, filial, remetente, destinatario, valor, tipo, transferencia,peso,volume,isBloqueado, isBaixado, dataBaixa, ultimaOcorrencia, cubagem, numNotaFiscal, chaveacesso, clienteOcorrenciaEspecifica, idRemetente, idConsignatario, valorNF) {
                        
            }
        }
        response.getWriter().append(resultado);
        response.getWriter().close();
    }
    
    if(acao.equalsIgnoreCase("recalcularValorMotorista")){
        int idRota = Apoio.parseInt(request.getParameter("idRota"));
        int idCliente = Apoio.parseInt(request.getParameter("idCliente"));
        int idVeiculo = Apoio.parseInt(request.getParameter("idVeiculo"));
        int idCarreta = Apoio.parseInt(request.getParameter("idCarreta"));
        int idDocumento = Apoio.parseInt(request.getParameter("idDocumento"));
        String tipo = request.getParameter("tipo");
        double peso = Apoio.parseDouble(request.getParameter("peso"));
        double valorNota = Apoio.parseDouble(request.getParameter("valorNota"));
        double valorCTe = Apoio.parseDouble(request.getParameter("valorCTe"));
        double valorFreteCte = Apoio.parseDouble(request.getParameter("valorFreteCte"));
        double valorPesoCte = Apoio.parseDouble(request.getParameter("valorPesoCte"));
        
        double valorMotorista = cadrom.getTabelaPrecoRomaneio(idRota, idCliente, idVeiculo, idCarreta, idDocumento, tipo, peso, valorNota, valorCTe, cfg.getPercentualToleranciaPeso(), valorFreteCte, valorPesoCte);
        
        XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
        xstream.setMode(XStream.NO_REFERENCES);
        xstream.alias("valorMotorista", String.class);
        
        String json = xstream.toXML(valorMotorista);
        
        
        response.getWriter().append(json);
        response.getWriter().close();
    }  

    if (!acao.equals("") && !acao.equals("iniciar")) {
        if (acao.equals("editar") || acao.equals("iniciar_baixa")) {
            cadrom.getRomaneio().setIdRomaneio(Apoio.parseInt(request.getParameter("id")));
            carregarom = cadrom.LoadAllPropertys(nucleo.Apoio.getConfiguracao(request));
            rom = (carregarom ? cadrom.getRomaneio() : null);
                          
            
//            //Enviando e-mail
//            String msgErro = "";
//        
//            BeanUsuario autenticado = cfg.getExecutor();
//            ConhecimentoImagemDAO conhecimentoImagemDAO = new ConhecimentoImagemDAO(autenticado);
//
//            //Enviando e-mail para os clientes
//            EnviaEmail m = new EnviaEmail();
//            m.setCon(cfg.getExecutor().getConexao());
//            m.carregaCfg();
//
//            BeanConsultaConhecimento ct = new BeanConsultaConhecimento();
//            ct.setConexao(cfg.getExecutor().getConexao());
//            ct.setExecutor(cfg.getExecutor());
////            ct.consultarCtrcEmail(ctrcsEmail, 2);
//
//            ResultSet rsCt = ct.getResultado();
//            String anexarComprovante = null;
//
//            String msg = "";
//            SimpleDateFormat formatoData = new SimpleDateFormat("dd/MM/yyyy");
//            SimpleDateFormat formatoHora = new SimpleDateFormat("HH:mm");
//            boolean enviou = false;
//            while (rsCt.next()) {
//                anexarComprovante = rsCt.getString("comprovante");
//                if (cfg == null) {
//                    cfg = new BeanConfiguracao();
//                    cfg.setConexao(cfg.getExecutor().getConexao());
//                    cfg.CarregaConfig();
//                }
//                String texto = cfg.getMensagemEntrega();
//                texto = texto.replaceAll("@@nome_cliente", rsCt.getString("cliente"));
//                texto = texto.replaceAll("@@cnpj_cliente", rsCt.getString("cnpj_cliente"));
//                texto = texto.replaceAll("@@nota_fiscal", rsCt.getString("notas") == null ? "" : rsCt.getString("notas"));
//                texto = texto.replaceAll("@@pedido_nf", rsCt.getString("pedido_nf") == null ? "" : rsCt.getString("pedido_nf"));
//                texto = texto.replaceAll("@@emissao_ctrc", formatoData.format(rsCt.getDate("emissao_em")));
//                texto = texto.replaceAll("@@nome_transportadora", cfg.getExecutor().getFilial().getRazaosocial());
//                texto = texto.replaceAll("@@ctrc", rsCt.getString("ctrc"));
//                texto = texto.replaceAll("@@data_chegada", (rsCt.getDate("chegada_em") == null ? "" : formatoData.format(rsCt.getDate("chegada_em"))));
//                texto = texto.replaceAll("@@data_entrega", formatoData.format(rsCt.getDate("baixa_em")) + (rsCt.getTime("entrega_as") != null && !rsCt.getString("entrega_as").equals("00:00:00") ? " as " + formatoHora.format(rsCt.getTime("entrega_as")) : ""));
//                texto = texto.replaceAll("@@previsao_entrega", (rsCt.getDate("previsao_entrega_em") == null ? "" : formatoData.format(rsCt.getDate("previsao_entrega_em"))));
//                texto = texto.replaceAll("@@observacao_entrega", rsCt.getString("observacao_baixa"));
//                texto = texto.replaceAll("@@remetente", rsCt.getString("remetente"));
//                texto = texto.replaceAll("@@destinatario", rsCt.getString("destinatario"));
//                //Novos a partir 24/09
//                texto = texto.replaceAll("@@volume", rsCt.getString("tot_volume"));
//                texto = texto.replaceAll("@@peso", rsCt.getString("tot_peso"));
//                texto = texto.replaceAll("@@valor_mercadoria", rsCt.getString("tot_valor"));
//                texto = texto.replaceAll("@@valor_frete", rsCt.getString("valor_frete"));
//                texto = texto.replaceAll("@@cidade_destino", rsCt.getString("cidade_destinatario"));
//
//                msg = texto;
//
//                if (anexarComprovante.equals("s")) {
//
//                    m.setAnexos(new ArrayList<File>());
//
//                    String home = Apoio.getHomePath().replaceAll("WEB-INF", "img/conhecimento");
//                    Collection<Imagem> conhecimentoImagems = conhecimentoImagemDAO.carregar(rsCt.getInt("ctrc_id"), home);
//                    for (Imagem img : conhecimentoImagems) {
//                        img.getCaminho();
//
//                        File f = new File(img.getCaminho());
//                        m.getAnexos().add(f);
//                    }
//
//                }
//
//                m.setAssunto("Confirmacao de entrega NF: " + (rsCt.getString("notas") == null ? "" : rsCt.getString("notas")) + " - Mensagem automática da " + cfg.getExecutor().getFilial().getRazaosocial());
//                m.setMensagem(msg);
//                m.setPara(rsCt.getString("email"));
//                enviou = m.EnviarEmail();
//                if (!enviou) {
//                    msgErro += "Ocorreu o seguinte erro ao enviar e-mail: " + m.getErro() + "\r\n"
//                            + "Cliente: " + rsCt.getString("cliente") + "\r\n"
//                            + "CTRC: " + rsCt.getString("ctrc") + "\r\n";
//                }
//            }
//            rsCt.close();
//            //Fim enviando e-mail
        
  
                
        } else if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir") || acao.equals("excluir") || acao.equals("baixar") || acao.equals("excluirBaixa"))) {
            //setando os atributos que nao podem ser setados dinamicamente(acoes: atualizar/incluir)
            if (acao.equals("atualizar") || acao.equals("incluir")) {
                
                rom.setIdRomaneio(acao.equals("atualizar") ? Apoio.parseInt(request.getParameter("idromaneio")) : 0);
                rom.getFilial().setIdfilial(Apoio.parseInt(request.getParameter("idfilial")));
                rom.getFilial().getNaturezaCargaContratoFrete().setCod(Apoio.parseInt(request.getParameter("cod_natureza")));
                rom.setNumRomaneio(request.getParameter("numromaneio"));
                rom.setDtRomaneio(Apoio.paraDate(request.getParameter("dtromaneio")));
                rom.setHrRomaneio(Apoio.paraHora(request.getParameter("hrromaneio")));
                rom.getMotorista().setIdmotorista(Apoio.parseInt(request.getParameter("idmotorista")));
                rom.getCavalo().setIdveiculo(Apoio.parseInt(request.getParameter("idveiculo")));
                rom.getCarreta().setIdveiculo(request.getParameter("idcarreta").equals("0") ? 0 : Apoio.parseInt(request.getParameter("idcarreta")));
                rom.setVlRateioDiaria(Apoio.parseFloat(request.getParameter("diaria")));
                rom.setVlRateioAjudante(Apoio.parseFloat(request.getParameter("diariaajud")));
                rom.setObservacao(request.getParameter("observacao"));
                rom.getCidadeOrigem().setIdcidade(Apoio.parseInt(request.getParameter("idcidadeorigem")));
                rom.getCidadeDestino().setIdcidade(Apoio.parseInt(request.getParameter("idcidadedestino")));
                rom.setIsPreRomaneio(Apoio.parseBoolean(request.getParameter("ispreromaneio")));
                rom.setIsRomaneioPontoControle(Apoio.parseBoolean(request.getParameter("romaneioPontoControle")));
                //adicionando os ajudantes
                if (!request.getParameter("ajudantes").equals("")) {
                    String[] strAjud = request.getParameter("ajudantes").split("&");
                    BeanAjudanteColeta ajuds[] = new BeanAjudanteColeta[strAjud.length];
                    for (int i = 0; i < strAjud.length; ++i) {
                        BeanAjudanteColeta aj = new BeanAjudanteColeta();
                        aj.getAjudante().setIdfornecedor(Apoio.parseInt(strAjud[i].split(",")[0]));
                        aj.setValor(Apoio.parseFloat(strAjud[i].split(",")[1]));
                        ajuds[i] = aj;
                    }
                    rom.setAjudantes(ajuds);
                }
                //adicionando os ctrcs
                if (!request.getParameter("ctrcs").equals("")) {
                    
                    //A ordem das posições abaixo tem que está na mesmo ordem das posições que está no jsp
                    String[] strCtrc = request.getParameter("ctrcs").split("@@@");
                    
                    BeanCtrcRomaneio ctrcs[] = new BeanCtrcRomaneio[strCtrc.length];
                    String tipo = "";
                    for (int i = 0; i < strCtrc.length; ++i) {
                        BeanCtrcRomaneio ct = new BeanCtrcRomaneio();
                        tipo = strCtrc[i].split("!!")[1];
                        ct.setId(Apoio.parseInt(strCtrc[i].split("!!")[14]));
                        if (tipo.equals("COLETA")) {
                            ct.getColeta().setId(Apoio.parseInt(strCtrc[i].split("!!")[0]));
                            ct.getCtrc().setId(0);
                        } else {
                            ct.getColeta().setId(0);
                            ct.getCtrc().setId(Apoio.parseInt(strCtrc[i].split("!!")[0]));
                        }
                        ct.setTipo(tipo);
                        ct.setTransferencia(new Boolean(strCtrc[i].split("!!")[2]));
                        ct.setOrdem(Apoio.parseInt(strCtrc[i].split("!!")[11]));
                        ct.setIsRemoverRomaneioCtrc(Apoio.parseBoolean(strCtrc[i].split("!!")[15]));
                        
                        boolean isAutorizado = false;
                        if (request.getParameter("inpHidDocPagt_"+(i+1)) != null) {
                            isAutorizado = (request.getParameter("inpChkAutorizacao_"+(i+1)) != null ? (request.getParameter("inpChkAutorizacao_"+(i+1)).equals("s") ? true : false) : false);
                            ct.getCtrc().setAutorizadoPagamento(isAutorizado);
                            ct.getCtrc().getUsuarioAutorizacao().setIdusuario(Apoio.parseInt(request.getParameter("inpHidIdUsuarioAutorizador_"+(i+1))));
                            ct.getCtrc().getRotaAutorizacao().setId(Apoio.parseInt(request.getParameter("inpHidIdRota_"+(i+1))));
                            ct.getCtrc().setValorMotorista(Apoio.parseDouble(request.getParameter("inpHidValorMotorista_"+(i+1))));
                        }
                        
                        ctrcs[i] = ct;
                    } 
                    rom.setCtrcs(ctrcs);
                }
                int index = 0;
                //------------------------------Carregando os dados do contrato de frete-------             
                rom.getContratoFrete().setData(Apoio.paraDate(Apoio.getDataAtual()));
                rom.getContratoFrete().setVldependentes(Apoio.parseFloat(request.getParameter("vlDependentes")));
                rom.getContratoFrete().setQtdDependentes(Apoio.parseInt(request.getParameter("qtddependentes")));
                rom.getContratoFrete().setVlbaseir(Apoio.parseFloat(request.getParameter("baseIR")));
                rom.getContratoFrete().setAliqir(Apoio.parseFloat(request.getParameter("aliqIR")));
                rom.getContratoFrete().setVlir(Apoio.parseFloat(request.getParameter("valorIR")));
                rom.getContratoFrete().setVlJaRetido(Apoio.parseFloat(request.getParameter("inss_prop_retido")));
                rom.getContratoFrete().setVlOutrasEmpresas(0);
                rom.getContratoFrete().setVlbaseinss(Apoio.parseFloat(request.getParameter("baseINSS")));
                rom.getContratoFrete().setAliqinss(Apoio.parseFloat(request.getParameter("aliqINSS")));
                rom.getContratoFrete().setVlinss(Apoio.parseFloat(request.getParameter("valorINSS")));
                rom.getContratoFrete().setBaseSestSenat(Apoio.parseFloat(request.getParameter("baseSEST")));
                rom.getContratoFrete().setAliqsestsenat(Apoio.parseFloat(request.getParameter("aliqSEST")));
                rom.getContratoFrete().setVlsestsenat(Apoio.parseFloat(request.getParameter("valorSEST")));
                rom.getContratoFrete().setVlAvaria(0);
                rom.getContratoFrete().setVlFreteMotorista(Apoio.parseFloat(request.getParameter("cartaValorFrete")));
                rom.getContratoFrete().setOutrosdescontos(Apoio.parseFloat(request.getParameter("cartaOutros")));
                rom.getContratoFrete().setObsoutrosdescontos("");
                rom.getContratoFrete().setReterImpostos(request.getParameter("chk_reter_impostos") != null ? true : false);
                rom.getContratoFrete().setVlImpostos(Apoio.parseFloat(request.getParameter("cartaImpostos")));
                rom.getContratoFrete().setValorPedagio(Apoio.parseDouble(request.getParameter("cartaPedagio")));
                rom.getContratoFrete().setValorDescarga(Apoio.parseDouble(request.getParameter("vlDescarga")));
                rom.getContratoFrete().setValorTonelada(Apoio.parseFloat(request.getParameter("vlTonelada")));
                rom.getContratoFrete().setVlLiquido(Apoio.parseFloat(request.getParameter("cartaLiquido")));
                rom.getContratoFrete().setVlOutrasDeducoes(Apoio.parseFloat(request.getParameter("cartaRetencoes")));
                rom.getContratoFrete().getFilial().setIdfilial(Apoio.parseInt(request.getParameter("idfilial")));
                rom.getContratoFrete().getMotorista().setIdmotorista(Apoio.parseInt(request.getParameter("idmotorista")));
                rom.getContratoFrete().getMotorista().setNome(request.getParameter("motor_nome"));
                rom.getContratoFrete().getVeiculo().setIdveiculo(Apoio.parseInt(request.getParameter("idveiculo")));
                rom.getContratoFrete().getContratado().setIdfornecedor(Apoio.parseInt(request.getParameter("idproprietarioveiculo")));
                rom.getContratoFrete().getContratado().getPlanoCustoPadrao().setIdconta(Apoio.parseInt(request.getParameter("plano_proprietario")));
                rom.getContratoFrete().getContratado().getUnidadeCusto().setId(Apoio.parseInt(request.getParameter("und_proprietario")));
                rom.getContratoFrete().getCarreta().setIdveiculo(Apoio.parseInt(request.getParameter("idcarreta")));
                rom.getContratoFrete().setObservacao(request.getParameter("obs_carta_frete"));
                rom.getContratoFrete().setDataPartida(Apoio.paraDate(request.getParameter("dataPartida")));
                rom.getContratoFrete().setDataTermino(Apoio.paraDate(request.getParameter("dataTermino")));
                rom.getContratoFrete().getRota().setId(Apoio.parseInt(request.getParameter("rota")));
                rom.getContratoFrete().getPercurso().setId(Apoio.parseInt(request.getParameter("percurso")));
                rom.getContratoFrete().setEixosSuspensos(Apoio.parseInt(request.getParameter("eixosSuspensos")));
                rom.getContratoFrete().getCategoriaVeiculo().setId(Apoio.parseInt(request.getParameter("categoria_pamcard_id")));
                rom.getContratoFrete().getCategoriaVeiculoNdd().setId(Apoio.parseInt(request.getParameter("categoria_ndd_id")));
                rom.getContratoFrete().getNatureza().setCod(Apoio.parseInt(request.getParameter("natureza_cod")));
                rom.getContratoFrete().getTipoProduto().setId(Apoio.parseInt(request.getParameter("tipoProduto")));
                rom.getContratoFrete().setPedagioIdaVolta(Apoio.parseBoolean(request.getParameter("isPedagioIdaVolta")));
                rom.getContratoFrete().setPrecisaAutorizacao(Apoio.parseBoolean(request.getParameter("isSolicitaAutorizacao")));
                rom.getContratoFrete().setMotivoAutorizacao(request.getParameter("motivoSolicitacao"));
                rom.getContratoFrete().setRetencaoImpostoOperadoraCFe(Apoio.parseBoolean(request.getParameter("is_retencao_impostos_operadora_cfe")));
                if (rom.getContratoFrete().isRetencaoImpostoOperadoraCFe()) {
                    rom.getContratoFrete().setReterImpostos(false);
                }

                rom.getContratoFrete().setValorAbastecimento(Apoio.parseDouble(request.getParameter("abastecimentos")));
                if (request.getParameter("ids_abastecimentos") != null) {
                    for (String abastecimentoId : StringUtils.split(request.getParameter("ids_abastecimentos"), ",")) {
                        int id = Apoio.parseInt(abastecimentoId);

                        rom.getContratoFrete().getAbastecimentoIds().add(id);
                    }
                }

                BeanPagamentoCartaFrete[] arrayPagtoCarta = new BeanPagamentoCartaFrete[3];
                
                BeanPagamentoCartaFrete pgCarta = new BeanPagamentoCartaFrete();
                pgCarta.setId(0);
                pgCarta.setTipoPagamento("a");
                pgCarta.setValor(Apoio.parseDouble(request.getParameter("cartaValorAdiantamento")));
                pgCarta.setData(Apoio.paraDate(request.getParameter("cartaDataAdiantamento")));
                pgCarta.getFpag().setIdFPag(Apoio.parseInt(request.getParameter("cartaFPagAdiantamento")));
//                pgCarta.setDocumento(request.getParameter(cfg.isControlarTalonario() ? "cartaDocAdiantamento_cb" : "cartaDocAdiantamento"));
                pgCarta.setDocumento(request.getParameter("cartaDocAdiantamento"));
                pgCarta.getAgente().setIdfornecedor(Apoio.parseInt(request.getParameter("idagente")));
                pgCarta.getAgente().getPlanoCustoPadrao().setIdconta(Apoio.parseInt(request.getParameter("plano_agente")));
                pgCarta.getAgente().getUnidadeCusto().setId(Apoio.parseInt(request.getParameter("und_agente")));
                pgCarta.setPercAbastecimento(0);
                pgCarta.getDespesa().setIdmovimento(0);
                pgCarta.setBaixado(false);
                if(request.getParameter("contaAdt") != null && !request.getParameter("contaAdt").equals("")){
                    pgCarta.getConta().setIdConta(Apoio.parseInt(request.getParameter("contaAdt")));                    
                }
                pgCarta.setSaldoAutorizado(false);
                pgCarta.setTipoFavorecido(request.getParameter("favorecidoAdiantamento"));
                pgCarta.setContaBancaria("");
                pgCarta.setAgenciaBancaria("");
                pgCarta.setFavorecido("");
                pgCarta.getBanco().setIdBanco(1);
                
                arrayPagtoCarta[index] = pgCarta;
                
                pgCarta = new BeanPagamentoCartaFrete();
                pgCarta.setId(0);
                pgCarta.setTipoPagamento("s");
                pgCarta.setValor(Apoio.parseDouble(request.getParameter("cartaValorSaldo")));
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
                pgCarta.setTipoFavorecido(request.getParameter("favorecidoSaldo"));
                pgCarta.setContaBancaria("");
                pgCarta.setAgenciaBancaria("");
                pgCarta.setFavorecido("");
                pgCarta.getBanco().setIdBanco(1);
                
                //campos CIOT
                index++;
                arrayPagtoCarta[index] = pgCarta;
                
                
                if(Apoio.parseBoolean(request.getParameter("controlarTarifasBancariasContratado"))){ 
                    pgCarta = new BeanPagamentoCartaFrete();
                    pgCarta.setId(0);
                    pgCarta.setTipoPagamento("a");//
                    pgCarta.setValor(Apoio.parseDouble(request.getParameter("cartaValorTarifa")));
                    pgCarta.setData(Apoio.paraDate(request.getParameter("cartaDataTarifa")));
                    pgCarta.getFpag().setIdFPag(Apoio.parseInt(request.getParameter("cartaFPagTarifa")));
                    pgCarta.setDocumento(request.getParameter("cartaDocTarifa"));
                    pgCarta.getAgente().setIdfornecedor(Apoio.parseInt(request.getParameter("idagenteTarifa")));
                    pgCarta.getAgente().getPlanoCustoPadrao().setIdconta(Apoio.parseInt(request.getParameter("plano_agente_Tarifa")));
                    pgCarta.getAgente().getUnidadeCusto().setId(Apoio.parseInt(request.getParameter("und_agente_Tarifa")));
                    pgCarta.setPercAbastecimento(0);
                    pgCarta.getDespesa().setIdmovimento(0);
                    pgCarta.setBaixado(false);
                    pgCarta.setSaldoAutorizado(false);
                    pgCarta.setTipoFavorecido(request.getParameter("favorecidoTarifa"));
                    if(request.getParameter("contaTarifa") != null && !request.getParameter("contaTarifa").equals("")){
                        pgCarta.getConta().setIdConta(Apoio.parseInt(request.getParameter("contaTarifa")));                    
                    }
                    pgCarta.setContaBancaria("");
                    pgCarta.setAgenciaBancaria("");
                    pgCarta.setFavorecido("");
                    pgCarta.getBanco().setIdBanco(1);
                    pgCarta.setParcelaTarifa(true);
                    
                    index++;
                    arrayPagtoCarta[index] = pgCarta;
                }
                //Conta corrente
                if (Float.parseFloat(request.getParameter("cartaValorCC")) > 0) {
                    //Dados do saldo
                    pgCarta = new BeanPagamentoCartaFrete();
                    pgCarta.setId(0);
                    pgCarta.setTipoPagamento("a");
                    pgCarta.setValor(Float.parseFloat(request.getParameter("cartaValorCC")));
                    pgCarta.setData(Apoio.paraDate(request.getParameter("cartaDataCC")));
                    pgCarta.getFpag().setIdFPag(Apoio.parseInt(request.getParameter("cartaFPagCC")));
                    pgCarta.setDocumento("");
                    pgCarta.getAgente().setIdfornecedor(0);
                    pgCarta.getAgente().getPlanoCustoPadrao().setIdconta(0);
                    pgCarta.getAgente().getUnidadeCusto().setId(0);
                    pgCarta.setPercAbastecimento(0);
                    pgCarta.getDespesa().setIdmovimento(0);
                    pgCarta.setBaixado(false);
                    if (request.getParameter("contaCC") != null && !request.getParameter("contaCC").equals("")) {
                        pgCarta.getConta().setIdConta(Apoio.parseInt(request.getParameter("contaCC")));
                    }
                    pgCarta.setSaldoAutorizado(false);
                    pgCarta.setTipoFavorecido("p");
                    pgCarta.setContaBancaria("");
                    pgCarta.setAgenciaBancaria("");
                    pgCarta.setFavorecido("");
                    pgCarta.getBanco().setIdBanco(1);
                    pgCarta.setContaCorrente(true);
                    index++;
                    arrayPagtoCarta[index] = pgCarta;
                    
                }
                
                rom.getContratoFrete().setPagamento(arrayPagtoCarta);

                //---------------------Fim contrato de Frete----------------------------
            }

            MovimentacaoIscas movIsca = null;
            List<MovimentacaoIscas> listIscas = new ArrayList<>();
            int maxIsca = Apoio.parseInt(request.getParameter("maxIsca"));
            for (int i = 1; i <= maxIsca; i++) {
                movIsca = new MovimentacaoIscas();
                movIsca.setId(Apoio.parseLong(request.getParameter("idMovimentacaoIsca_"+i)));
                movIsca.setIdIsca(Apoio.parseLong(request.getParameter("idIsca_"+i)));
                movIsca.setDataSaida(Apoio.getFormatSqlData(request.getParameter("data_isca_saida_"+i)));
                movIsca.setDataChegada(Apoio.getFormatSqlData(request.getParameter("data_isca_chegada_"+i)));

                listIscas.add(movIsca);
            }

            //adicionando as iscas
            rom.setIscas(listIscas);

            cadrom.setRomaneio(rom);
            cadrom.setExecutor(Apoio.getUsuario(request));
            
            String hashAutorizacao = "";
            if (!acao.equals("excluir")) {
                
                if (request.getParameter("os_aberto_veiculo") != null) {
                    //caso o usuario precise de autorizacao para salvar o manfiesto, vai ser gerado o hash.
                    String cfgPermitirLancamentoOSAbertoVeiculo = request.getParameter("cfgPermitirLancamentoOSAbertoVeiculo");
                    int miliSegundos = Apoio.parseInt(request.getParameter("miliSegundos"));
                    int idCidadeOrigem = Apoio.parseInt(request.getParameter("idcidadeorigem"));
                    int idCidadeDestino = Apoio.parseInt(request.getParameter("idcidadedestino"));
                    boolean osAbertoVeiculo = Apoio.parseBoolean(request.getParameter("os_aberto_veiculo"));
                    if (cfgPermitirLancamentoOSAbertoVeiculo.equals("PS") && osAbertoVeiculo && miliSegundos > 0) {
                        hashAutorizacao = Apoio.gerarHash(miliSegundos, cadrom.getRomaneio().getCavalo().getIdveiculo(),0);
                    }
                }
            }

            if (acao.equals("atualizar")) {
                cadrom.Atualiza(1, hashAutorizacao, nucleo.Apoio.getConfiguracao(request));
            } else if (acao.equals("incluir") && nivelUser >= 3) {
                cadrom.Inclui(Apoio.parseBoolean(request.getParameter("isCartaAutomaticaRomaneio")), hashAutorizacao, Apoio.getConfiguracao(request));
            } else if (acao.equals("excluir") && nivelUser >= 4) {
                rom.setIdRomaneio(Apoio.parseInt(request.getParameter("idromaneio")));
                cadrom.setRomaneio(rom);                
                cadrom.Deleta();
            } else if (acao.equals("excluirBaixa") && nivelUser >= 2) {
                boolean excluirCTe = Apoio.parseBoolean(request.getParameter("excluirCTe"));
                boolean excluirOcorrCTe = Apoio.parseBoolean(request.getParameter("excluirOcorrCTe"));
                rom.setIdRomaneio(Apoio.parseInt(request.getParameter("idromaneio")));
                cadrom.setRomaneio(rom);                
                cadrom.excluirBaixa(excluirCTe, excluirOcorrCTe);
            } else if (acao.equals("baixar")) {
//                 rom.setIdCtrcs(request.getParameter("ctrcs").split(","));
                //adicionando os ctrcs
                Ocorrencia[] arOcorrencia;
                Ocorrencia ocor;
                if (!request.getParameter("ctrcs").equals("")) {
                    String[] strCtrc = request.getParameter("ctrcs").split("@@@");
                    
                    
                    BeanCtrcRomaneio ctrcs[] = new BeanCtrcRomaneio[strCtrc.length];
                    for (int i = 0; i < strCtrc.length; ++i) {
                        
                        BeanCtrcRomaneio ct = new BeanCtrcRomaneio();
                        ct.setId(Apoio.parseInt(strCtrc[i].split("@@@")[0].split("!!")[13]));//pegando o id de romaneio_ctrc
                        if (strCtrc[i].split("@@@")[0].split("!!")[1].equals("COLETA")) {
                            ct.getColeta().setId(Apoio.parseInt(strCtrc[i].split("@@@")[0].split("!!")[0]));
                            ct.getColeta().setObs(strCtrc[i].split("@@@")[0].split("!!")[3]);
                            //GAMBI - Estou usando o atributo isPago temporariamente, para informar se vou querer ou não baixar o ctrc.
                            ct.getColeta().setUrbano(Apoio.parseBoolean(strCtrc[i].split("@@@")[0].split("!!")[4]));
                            ct.getCtrc().setId(0);
                            arOcorrencia = new Ocorrencia[1];
                            ocor = new Ocorrencia();
                            ocor.getOcorrencia().setId(Apoio.parseInt(strCtrc[i].split("@@@")[0].split("!!")[7]));
                            ocor.setObservacaoOcorrencia(strCtrc[i].split("@@@")[0].split("!!")[3]);
                            arOcorrencia[0] = ocor;
                            ct.getCtrc().setOcorrenciaCtrc(arOcorrencia);
                            //GAMBI - Estou usando o atributo isPago temporariamente, para informar se vou querer ou não baixar o ctrc.
                            ct.getCtrc().setPago(Apoio.parseBoolean(strCtrc[i].split("@@@")[0].split("!!")[4]));
                            
                            ct.getCtrc().setBaixaEm(strCtrc[i].split("@@@")[0].split("!!")[8] == null || strCtrc[i].split("@@@")[0].split("!!")[8].equals("") ? Apoio.paraDate(request.getParameter("dtentrega")) : Apoio.paraDate(strCtrc[i].split("@@@")[0].split("!!")[8]));
                            ct.getCtrc().setEntregaAs(strCtrc[i].split("@@@")[0].split("!!")[9] == null || strCtrc[i].split("@@@")[0].split("!!")[9].equals("") ? "" : strCtrc[i].split("@@@")[0].split("!!")[9]);
                            ct.setIsMobileConcluido(Apoio.parseBoolean(strCtrc[i].split("!!")[15]));
                        } else {
                            ct.getCtrc().setId(Apoio.parseInt(strCtrc[i].split("@@@")[0].split("!!")[0]));
                            ct.getCtrc().setObservacaoBaixa(strCtrc[i].split("@@@")[0].split("!!")[3]);
                            ct.getCtrc().setIsCompEntrega(Apoio.parseBoolean(strCtrc[i].split("@@@")[0].split("!!")[6]));
                            arOcorrencia = new Ocorrencia[1];
                            ocor = new Ocorrencia();
                            ocor.getOcorrencia().setId(Apoio.parseInt(strCtrc[i].split("@@@")[0].split("!!")[7]));
                            ocor.setObservacaoOcorrencia(strCtrc[i].split("@@@")[0].split("!!")[3]);
                            
                            // Quantidade de CTRC na tela
                            int qtdCtrc = Apoio.parseInt(request.getParameter("totalCts"));
                                for (int oco = 0; oco <= qtdCtrc; oco++) {
                                    ocor.setResolvido(Apoio.parseBoolean(request.getParameter("isResolvido"+oco)));//IsResolvido
                                }
                            
                            arOcorrencia[0] = ocor;
                            ct.getCtrc().setOcorrenciaCtrc(arOcorrencia);
                            //GAMBI - Estou usando o atributo isPago temporariamente, para informar se vou querer ou não baixar o ctrc.
                            
                            //isBaixado for false faz.. se não tiver data de entrega adicione false em pago, caso contrario adicione true;
                            boolean pago =(!Apoio.parseBoolean(strCtrc[i].split("@@@")[0].split("!!")[4]) ? (strCtrc[i].split("@@@")[0].split("!!")[11].equals("") ? false : true): true);
                            
                            boolean isJaBaixado = (!Apoio.parseBoolean(strCtrc[i].split("@@@")[0].split("!!")[4]) && (!strCtrc[i].split("@@@")[0].split("!!")[11].equals("")) ? true : false);
                            
                            ct.getCtrc().setIsJaBaixado(isJaBaixado);
                            
                            String dataBaixaEm  = (!Apoio.parseBoolean(strCtrc[i].split("@@@")[0].split("!!")[4])?
                                    (!strCtrc[i].split("@@@")[0].split("!!")[8].equals("") ? (strCtrc[i].split("@@@")[0].split("!!")[8]) : 
                                            (!strCtrc[i].split("@@@")[0].split("!!")[11].equals("")? strCtrc[i].split("@@@")[0].split("!!")[11] : request.getParameter("dtentrega"))) :
                                            (strCtrc[i].split("@@@")[0].split("!!")[8] == null || strCtrc[i].split("@@@")[0].split("!!")[8].equals("") ?
                                            (request.getParameter("dtentrega")) : (strCtrc[i].split("@@@")[0].split("!!")[8])));
                            
                            ct.getCtrc().setPago(pago);
                            ct.getCtrc().setBaixaEm(Apoio.paraDate(dataBaixaEm));
                            ct.getCtrc().setEntregaAs(strCtrc[i].split("@@@")[0].split("!!")[9] == null || strCtrc[i].split("@@@")[0].split("!!")[9].equals("") ? "" : strCtrc[i].split("@@@")[0].split("!!")[9]);
                            ct.getColeta().setId(0);
                            ct.setIsMobileConcluido(Apoio.parseBoolean(strCtrc[i].split("!!")[15]));
                            
                        }
                        
                        ct.setTipo(strCtrc[i].split("@@@")[0].split("!!")[1]);
                        ct.setTransferencia(new Boolean(strCtrc[i].split("@@@")[0].split("!!")[2]));
                        boolean isAutorizado=false;
                        if (request.getParameter("inpHidDocPagt_"+(i+1)) != null) {
                            
                            isAutorizado = (request.getParameter("inpChkAutorizacao_"+(i+1)) != null ? (request.getParameter("inpChkAutorizacao_"+(i+1)).equals("s") ? true : false) : false);
                            
                            ct.getCtrc().setAutorizadoPagamento(isAutorizado);
                            ct.getCtrc().getUsuarioAutorizacao().setIdusuario(Apoio.parseInt(request.getParameter("inpHidIdUsuarioAutorizador_"+(i+1))));
                            ct.getCtrc().getRotaAutorizacao().setId(Apoio.parseInt(request.getParameter("inpHidIdRota_"+(i+1))));
                            ct.getCtrc().setValorMotorista(Apoio.parseDouble(request.getParameter("inpHidValorMotorista_"+(i+1))));
                        }
                        ctrcs[i] = ct;
                    }
                    rom.setCtrcs(ctrcs);
                }
                cadrom.setRomaneio(rom);
                cadrom.getRomaneio().setIdRomaneio(Apoio.parseInt(request.getParameter("id")));
                cadrom.getRomaneio().setDtEntrega(Apoio.paraDate(request.getParameter("dtentrega")));
                cadrom.setCfg(Apoio.getConfiguracao(request));
                cadrom.setExecutor(Apoio.getUsuario(request));
                cadrom.baixar();
                
            int idromaneio = Apoio.parseInt(request.getParameter("id"));
            cadrom.getRomaneio().setIdRomaneio(Apoio.parseInt(request.getParameter("id")));
            carregarom = cadrom.LoadAllPropertys();
            rom = (carregarom ? cadrom.getRomaneio() : null);
                             
            
//            //Enviando e-mail
            String msgErro = "";
            String ctrcsEmail= "";
        
            BeanUsuario autenticado = cfg.getExecutor();
            ConhecimentoImagemDAO conhecimentoImagemDAO = null;

            //Enviando e-mail para os clientes
            EnviaEmail m = new EnviaEmail();
            m.setCon(Apoio.getUsuario(request).getConexao());
            m.carregaCfg();

            BeanConsultaConhecimento ct = new BeanConsultaConhecimento();
            ct.setConexao(Apoio.getUsuario(request).getConexao());
            ct.setExecutor(Apoio.getUsuario(request));
            ct.consultarEmailRomaneio(idromaneio,2,"");

            ResultSet rsCt = ct.getResultado();
            String anexarComprovante = null;
            Boolean chkEmailBaixaCtrc;

            String msg = "";
            SimpleDateFormat formatoData = new SimpleDateFormat("dd/MM/yyyy");
            SimpleDateFormat formatoHora = new SimpleDateFormat("HH:mm");
            boolean enviou = false;
            while (rsCt.next()) {
                anexarComprovante = rsCt.getString("comprovante");
                chkEmailBaixaCtrc = rsCt.getBoolean("is_envia_email_baixa_ctrc");
                
                if (cfg == null) {
                    cfg = new BeanConfiguracao();
                    cfg.setConexao(Apoio.getUsuario(request).getConexao());
                    cfg.CarregaConfig();
                }
                String texto = cfg.getMensagemEntrega();
                texto = texto.replaceAll("@@nome_cliente", rsCt.getString("cliente"));
                texto = texto.replaceAll("@@cnpj_cliente", rsCt.getString("cnpj_cliente"));
                texto = texto.replaceAll("@@nota_fiscal", rsCt.getString("notas") == null ? "" : rsCt.getString("notas"));
                texto = texto.replaceAll("@@pedido_nf", rsCt.getString("pedido_nf") == null ? "" : rsCt.getString("pedido_nf"));
                texto = texto.replaceAll("@@emissao_ctrc", formatoData.format(rsCt.getDate("emissao_em")));
                texto = texto.replaceAll("@@nome_transportadora", Apoio.getUsuario(request).getFilial().getRazaosocial());
                texto = texto.replaceAll("@@ctrc", rsCt.getString("ctrc"));
//                texto = texto.replaceAll("@@dtchegada", (rsCt.getDate("dtchegada") == null ? "" : formatoData.format(rsCt.getDate("dtchegada"))));
                texto = texto.replaceAll("@@dtchegada", (rsCt.getDate("chegada_em") == null ? "" : formatoData.format(rsCt.getDate("chegada_em"))));
                texto = texto.replaceAll("@@data_entrega", formatoData.format(rsCt.getDate("baixa_em")) + (rsCt.getTime("entrega_as") != null && !rsCt.getString("entrega_as").equals("00:00:00") ? " as " + formatoHora.format(rsCt.getTime("entrega_as")) : ""));
                texto = texto.replaceAll("@@previsao_entrega", (rsCt.getDate("previsao_entrega_em") == null ? "" : formatoData.format(rsCt.getDate("previsao_entrega_em"))));
                texto = texto.replaceAll("@@observacao_entrega", rsCt.getString("observacao_baixa"));
                texto = texto.replaceAll("@@remetente", rsCt.getString("remetente"));
                texto = texto.replaceAll("@@destinatario", rsCt.getString("destinatario"));
                //Novos a partir 24/09
                texto = texto.replaceAll("@@volume", rsCt.getString("tot_volume"));
                texto = texto.replaceAll("@@peso", rsCt.getString("tot_peso"));
                texto = texto.replaceAll("@@valor_mercadoria", rsCt.getString("tot_valor"));
                texto = texto.replaceAll("@@valor_frete", rsCt.getString("valor_frete"));
                texto = texto.replaceAll("@@cidade_destino", rsCt.getString("cidade_destinatario"));
                texto = texto.replaceAll("@@numero_carga", rsCt.getString("numero_carga"));
                texto = texto.replaceAll("@@data_chegada", (rsCt.getDate("chegada_em") == null ? "" : formatoData.format(rsCt.getDate("chegada_em")))); // adicionado por conta de ao enviar emails de romaneio a variável não era reconhecida

                msg = texto;
                if (anexarComprovante.equals("s")) {
                    m.setAnexos(new ArrayList<File>());
                    String home = Apoio.getHomePath().replaceAll("WEB-INF", "img/conhecimento");
                    conhecimentoImagemDAO = new ConhecimentoImagemDAO(Apoio.getUsuario(request));
                    Collection<Imagem> conhecimentoImagems = conhecimentoImagemDAO.carregar(rsCt.getInt("ctrc_id"), home);
                    for (Imagem img : conhecimentoImagems) {
                        img.getCaminho();
                        File f = new File(img.getCaminho());
                        m.getAnexos().add(f);
                    }
                }
                m.setAssunto("Confirmacao de entrega NF: "+rsCt.getString("notas")+" - Mensagem automática da " + Apoio.getUsuario(request).getFilial().getRazaosocial());
                m.setMensagem(msg);
                m.setPara(rsCt.getString("email"));
                
                CaixaSaida caixaSaida = new CaixaSaida();
                CaixaSaidaBO caixaSaidaBO = new CaixaSaidaBO();
                String mensagemEnvio = "";
                    if (chkEmailBaixaCtrc) {
                        if (!cfg.getIsEnviarEntreHorario() && cfg.getPreferenciaEnvioEmail().equals("a")) {
                            enviou = m.EnviarEmail();
                            if (!enviou) {
                                mensagemEnvio = "r";
                                msgErro += "Ocorreu o seguinte erro ao enviar e-mail: " + m.getErro() + "\r\n"
                                        + "Cliente: " + rsCt.getString("cliente") + "\r\n"
                                        + "CTRC: " + rsCt.getString("ctrc") + "\r\n";
                            } else {
                                mensagemEnvio = "e";
                            }
                        } else {
                            mensagemEnvio = "p";
                        }
                        caixaSaida = caixaSaida.converterEnvioEmailParaCaixaSaida(m, Apoio.getUsuario(request), cfg.getEmailEntrega().getId(), mensagemEnvio);
                        caixaSaidaBO.salvarEmailCaixaSaida(caixaSaida, Apoio.getUsuario(request));
                    }
            }
            rsCt.close();
//            //Fim enviando e-mail
        
            }
            //response.getWriter().append("err<=>" + cadrom.getErros());
            String retorno = "";
            if (acao.equals("excluir") || acao.equals("excluirBaixa")){
                if(cadrom.getErros().startsWith("ERRO: atualização ou exclusão em tabela romaneio viola restrição de chave estrangeira")){
                    response.getWriter().append("err<=>" + "Não é possível fazer a exclusão deste Romaneio pois o mesmo está sendo utilizado em um Contrato de Frete!");
                }else{
                        response.getWriter().append("err<=>" + cadrom.getErros());
                    }
                response.getWriter().close();
            }else{
                if (cadrom.getErros() != null && !cadrom.getErros().equals("")) {
                    String msgErro = cadrom.getErros().replace("\"", "").replace("\n", "").replace("\r", "");
                    if (acao.equals("baixar")) {
                        if(cadrom.getErros().indexOf("duplicacao_ocorrencia_nao_permitida") > -1){
                            retorno  = "<script>";
                            retorno += "alert('" + "ATENÇÃO: Ocorrência duplicada, CT-e já possui essa ocorrência vinculada!" + "');";
                        }else{
                            retorno  = "<script>";
//                            retorno += "window.resizeTo(window.outerWidth + "+(msgErro.length() * 2)+", window.outerHeight + "+(msgErro.length() * 2)+");";
                            retorno += "alert('" + cadrom.getErros().replace("\"", "").replace("\n", "").replace("\r", "") + "');";                        
//                            retorno += "window.opener.document.getElementById('salvar').disabled = false;";
//                            retorno += "window.opener.document.getElementById('salvar').value = 'Salvar';";
                        }
                    }else{
                        if(cadrom.getErros().indexOf("romaneio_ctrc_ordem_duplicado") > -1){
                            retorno  = "<script>";
                            retorno += "alert('" + "ATENÇÃO: A Ordem da entrega está igual!" + "');";
                            retorno += "window.opener.document.getElementById('salvar').disabled = false;";
                            retorno += "window.opener.document.getElementById('salvar').value = 'Salvar';";
                        }else if(cadrom.getErros().indexOf("romaneio_autorizacao_liberacao_hash_fkey") > -1){
                            retorno = "<script>";
                            retorno += "alert('ATENÇÃO: A inclusão do veículo não foi liberada e existe OS em aberto para o mesmo. Para utilizá-lo é preciso da autorização do supervisor.');";
                            retorno += "window.opener.document.getElementById('salvar').disabled = false;";
                            retorno += "window.opener.document.getElementById('salvar').value = 'Salvar';";
                        }else if(cadrom.getErros().indexOf("un_numromaneio_filial") > -1){
                            retorno = "<script>"
                                    + " if(confirm('ATENÇÃO: O numero do Romaneio " + rom.getNumRomaneio() + " já existe, Deseja que o sistema crie com o número " 
                                    + cadrom.getProximoRomaneio(Apoio.getUsuario(request).getFilial().getIdfilial()) 
                                    + "?')){"
                                    + "    if(window.opener != null){"
                                    + "        if(window.opener.numromaneio != null){"
                                    + "            window.opener.numromaneio.value = '"+cadrom.getProximoRomaneio(Apoio.getUsuario(request).getFilial().getIdfilial())+"';"
                                    + "        }"
                                    + "        if(window.opener.numromaneio != null){"
                                    + "            window.opener.jQuery('#salvar').click();"
                                    + "        }"
                                    + "    }"
                                    + "}";
                            retorno += "window.opener.document.getElementById('salvar').disabled = false;";
                            retorno += "window.opener.document.getElementById('salvar').value = 'Salvar';";
                        }else{
                            retorno  = "<script>";
    //                        retorno += "window.resizeTo(window.outerWidth + "+(msgErro.length() * 2)+", window.outerHeight + "+(msgErro.length() * 2)+");";
                            retorno += "alert('" + cadrom.getErros().replace("\"", "").replace("\n", "").replace("\r", "") + "');";                        
                            retorno += "window.opener.document.getElementById('salvar').disabled = false;";
                            retorno += "window.opener.document.getElementById('salvar').value = 'Salvar';";
                        }
                    }
                    retorno += "window.close();";
                    retorno += "</script>";
                    response.getWriter().print(retorno);
                }else{
                    nucleo.Apoio.redirecionaPop(response.getWriter(), "./consultaromaneio?acao=iniciar");            
                    response.getWriter().flush();
                    response.getWriter().close();
                }            
            }
        }
    }
%>
<script language="javascript" type="text/javascript">
    jQuery.noConflict();
    arAbasGenerico = new Array();
    arAbasGenerico[0] = new stAba('tbDadosCtsColeta','tab1');
    //arAbasGenerico[1] = new stAba('tbAjudante','tab2');
    arAbasGenerico[2] = new stAba('tbGwMobile','tab3');
    arAbasGenerico[3] = new stAba('tbDadosContratoFrete','tab4');
    arAbasGenerico[4] = new stAba('tbAuditoria','tab5');
    arAbasGenerico[5] = new stAba('tbFusionTrak','tab6');
    arAbasGenerico[6] = new stAba('tbIscasAba','tab7');

    //indexacao dos ajudantes e ctrc
    var indexAjud = new Array();
    var indexCtrc = new Array();
    var tipoAcaoRomaneio = '<%= cfg.getAcaoCteRomaneioExistente() %>';
    var validarValorMaximoTabelaRotaPermissao = '<%= nvAlFrete != 4 || nivelUserAutorizarContrato != 4 %>' === 'true';

    function incluirCtrcColetaAjax(){
        var valor = $("numeroConsulta").value;
        var serieConsulta = $("serieConsulta").value;
        var filialCombo = $("filialCombo").value.split("!!")[1];
        var filialComboId = $("filialCombo").value.split("!!")[0];
        var filial = $("idfilial").value;
        var tipo = $("tipoConsulta").value;
        var idRemetente = $("idremetente").value;
        

        if(valor == ""){
            alert("Para efetuar a consulta informe o número ou clique em 'Adicionar CT-e(s) / Coleta(s)'.");
            return false;
        }

        for (var i = 1; i <= indexCtrc.length; ++i){
            if($("idCtrc"+i) != null){
                if(tipo == "COLETA"){
                    if($("idCtrc"+i).value == valor
                        && $("filialHidden"+i).value == $("fi_abreviatura").value
                        && $("tipoCtrc"+i).value == tipo){
                        alert("A Coleta " + valor + " já foi inserida.");
                        return false;
                    }
                }else if(tipo == "CHAVE_NFE_NUMERO"){
                    if($("idCtrc"+i).value == valor){
                        alert("O CT " + valor + " já foi inserido.");
                        return false;
                    }
                }else{
                    if($("idCtrc"+i).value == valor
                        && $("filialHidden"+i).value == filialCombo
                        && $("tipoCtrc"+i).value == tipo){
                        alert("O CT " + valor + " já foi inserido.");
                        return false;
                    }
                }
            }
        }

        function e(transport){
            var resp = transport.responseText;
            console.log(resp);
            console.log(resp.split('!=!'));
            var isTransferencia = "false";
            espereEnviar("",false);
            //alert(resp.split('!=!')[15]);
            //se deu algum erro na requisicao...
            
            if (resp == 'null'){
                alert('Erro ao localizar CT-e/Coleta.');
                return false;
            }else if(resp == ''){
                
                if ($("tipoConsulta").value == "CTRC") {
                    alert("CT-e Rodoviário de número: "+ $("numeroConsulta").value +" não encontrado");
                    return false;
                }else if ($("tipoConsulta").value == "CHAVE_CTE") {
                    alert("CT-e com Chave de Acesso de número: "+ $("numeroConsulta").value +" não encontrado");
                    return false;
                }else if($("tipoConsulta").value == "NUMERO_NFE"){
                    alert("NF-e de número: "+ $("numeroConsulta").value + " não encontrado");
                    return false;
                }else if ($("tipoConsulta").value == "CHAVE_NFE") {
                    alert("NF-e com Chave de Acesso: "+ $("numeroConsulta").value +" não encontrado");
                    return false;
                }else if ($("tipoConsulta").value == "CHAVE_NFE_NUMERO") {
                    alert("NF-e de número: "+ $("numeroConsulta").value +" não encontrado");
                    return false;
                }else if ($("tipoConsulta").value == "CTA") {
                    alert("CT-e Aéreo de número: "+ $("numeroConsulta").value +" não encontrado");
                    return false;
                }else if ($("tipoConsulta").value == "CTQ") {
                    alert("CT-e Aquaviário de número: "+ $("numeroConsulta").value +" não encontrado");
                    return false;
                }else if ($("tipoConsulta").value == "NFS") {
                    alert("NFS de número: "+ $("numeroConsulta").value +" não encontrado");
                    return false;
                }else if ($("tipoConsulta").value == "COLETA") {
                    alert("NFS de número: "+ $("numeroConsulta").value +" não encontrado");
                    return false;
                }else if ($("tipoConsulta").value == "N_LOCALIZADOR") {
                    alert("Nº Localizador: " + $("numeroConsulta").value + " não encontrado");
                    return false;
                }
                
//                if (< %=cfg.isCtrcsConfirmadosParaRomaneio() == true%>) {
//                    alert("CT-e/Coleta não foi localizado");
//                    return false;
//                }
            }else if (resp.split('!=!')[11] != "null" && ($("tipoConsulta").value == "CTRC" || $("tipoConsulta").value == "NUMERO_NFE" || $("tipoConsulta").value == "CHAVE_NFE_NUMERO" || $("tipoConsulta").value == "CHAVE_NFE" || $("tipoConsulta").value == "CHAVE_CTE")){
                    alert("CT-e já foi baixado");
                    return false;
                    
                }else if(tipoAcaoRomaneio === 'a' && (resp.split('!=!')[26] != 'null' && resp.split('!=!')[26] != '')){
                    alert("Inclusão não permitida, o CT-e/Coleta está vinculado em outro romaneio.");
                    return false;
                } else if(resp.split('!=!')[12] != "0"){
                
                if (resp.split('!=!')[13] == "true"){
                    if (isJaExiste(resp.split('!=!')[0], resp.split('!=!')[7])){
                        alert('ATENÇÃO: ' + tipo + ' ' + resp.split('!=!')[1] + ' já foi adicionado!');
                        return false;
                    }
                    if(<%=cfg.isRomanearCtrcSemChegada() == false%> && resp.split('!=!')[24] == "null" && (resp.split('!=!')[7] != "COLETA" && resp.split('!=!')[25] != 'd')){
                        alert("CT-e "+ $("numeroConsulta").value +" sem data de chegada");
                        return false;
                    }
                        if(confirm("CT-e/Coleta está atrelado ao romaneio "+resp.split('!=!')[14]+", \n deseja transferi-lo para esse romaneio?" )){
                            isTransferencia = "true";
                            $("numeroConsulta").value = "";
                            addCtrc(
                            resp.split('!=!')[0], //idCtrc
                            resp.split('!=!')[1], //nfiscal
                            resp.split('!=!')[2], //emissao
                            resp.split('!=!')[3], //filial
                            resp.split('!=!')[4], //remetente
                            resp.split('!=!')[5], //destinatario
                            resp.split('!=!')[6], //valor
                            resp.split('!=!')[7], //tipo
                            isTransferencia, //transferencia
                            resp.split('!=!')[9], //peso
                            resp.split('!=!')[10], //volume
                            resp.split('!=!')[15], //isBloqueado
                            false, //isBaixado
                            '', //dataBaixa
                            '', //ultimaOcorrencia
                            resp.split('!=!')[16], //cubagem
                            '', //numNotaFiscal
                            '', //chaveacesso
                            false, //clienteOcorrenciaEspecifica
                            0, //idRemetente
                            resp.split('!=!')[20], //idConsignatario
                            resp.split('!=!')[21], //valorNF
                            false,
                            resp.split('!=!')[22],
                            resp.split('!=!')[23],
                            resp.split('!=!')[24]
                        );

                        //addCtrc(idCtrc, nfiscal, emissao, filial, remetente, destinatario, valor, tipo, transferencia,peso,volume,isBloqueado, isBaixado, dataBaixa, ultimaOcorrencia, cubagem, numNotaFiscal, chaveacesso, clienteOcorrenciaEspecifica, idRemetente, idConsignatario, valorNF) {

                        }else{
                            $("numeroConsulta").value = "";
                            return false;
                        }
                }else{
                    alert("Existe uma ocorrência não resolvida para este CT-e.");
                }
            }else{
                if (resp.split('!=!')[13] == "true"){
                    
                    if(<%=cfg.isRomanearCtrcSemChegada() == false%> && resp.split('!=!')[24] == "null" && (resp.split('!=!')[7] != "COLETA" && resp.split('!=!')[25] != 'd')){
                        alert("CT-e "+ $("numeroConsulta").value +" sem data de chegada");
                        return false;
                    }
                    $("numeroConsulta").value = "";
                    addCtrc(
                    resp.split('!=!')[0], //idCtrc
                    resp.split('!=!')[1], //nfiscal
                    resp.split('!=!')[2], //emissao
                    resp.split('!=!')[3], //filial
                    resp.split('!=!')[4], //remetente
                    resp.split('!=!')[5], //destinatario
                    resp.split('!=!')[6], //valor
                    resp.split('!=!')[7], //tipo
                    "false", //transferencia
                    resp.split('!=!')[9], //peso
                    resp.split('!=!')[10], //volume
                    resp.split('!=!')[15], //isBloqueado
                    false, //isBaixado
                    '', //dataBaixa
                    '', //ultimaOcorrencia
                    resp.split('!=!')[16], //cubagem
                    '', //numNotaFiscal
                    '', //chaveacesso
                    false, //clienteOcorrenciaEspecifica
                    0, //idRemetente
                    resp.split('!=!')[20], //idConsignatario
                    resp.split('!=!')[21], //valorNF
                    false,
                    resp.split('!=!')[22], //valor frete cte
                    resp.split('!=!')[23], //valor peso cte
                    resp.split('!=!')[24]
                    );
        
                    //addCtrc(idCtrc, nfiscal, emissao, filial, remetente, destinatario, valor, tipo, transferencia,peso,volume,isBloqueado, isBaixado, dataBaixa, ultimaOcorrencia, cubagem, numNotaFiscal, chaveacesso, clienteOcorrenciaEspecifica, idRemetente, idConsignatario, valorNF) {
            
                    $('idcidadedestino').value = resp.split('!=!')[17];//Id da cidade de destino
                    $('cid_destino').value = resp.split('!=!')[18];//cidade de destino
                    $('uf_destino').value = resp.split('!=!')[19];//uf de destino
            
                    <%if (cfg.isCartaFreteAutomaticaRomaneio()&& acao.equalsIgnoreCase("iniciar")){ %>
                        getRota();
                    <%}%>
                    
                }else{
                    alert("Existe uma ocorrência não resolvida para este CT-e.");
                }
            }
        }

        espereEnviar("",true);
        tryRequestToServer(function(){
            new Ajax.Request("./cadromaneio.jsp?acao=localizaCtrcColeta&valor="+valor+"&serieConsulta="+serieConsulta+
                "&filialCombo=" +filialComboId+"&filial="+filial+
                "&tipo=" + tipo+"&idRemetente="+idRemetente,{method:'post', onSuccess: e, onError: e});
        });
    }

    function alteraTipoConsulta(valorCombo){
        if(valorCombo == "COLETA"){
            $("filialCombo").style.display = "none";
            $("lbFilial").style.display = "none";
            $("numeroConsulta").size = "7";
            $("lbSerie").style.display = "";
            $("serieConsulta").style.display = "";
            $("lbRemetente").style.display = "none";
        }else if(valorCombo == "CHAVE_CTE"){
            $("filialCombo").style.display = "";
            $("lbFilial").style.display = "";
            $("numeroConsulta").size = "44";
            $("numeroConsulta").maxLength = "44";
            $("lbFilial").style.display = "none";
            $("filialCombo").style.display = "none";
            $("lbSerie").style.display = "none";
            $("serieConsulta").style.display = "none";
            $("lbRemetente").style.display = "none";
        }else if(valorCombo == "CHAVE_NFE"){
            $("filialCombo").style.display = "";
            $("lbFilial").style.display = "";
            $("numeroConsulta").size = "44";
            $("numeroConsulta").maxLength = "44";
            $("lbFilial").style.display = "none";
            $("filialCombo").style.display = "none";
            $("lbSerie").style.display = "none";
            $("serieConsulta").style.display = "none";
            $("lbRemetente").style.display = "none";
        }else if(valorCombo == "NUMERO_NFE"){
            $("filialCombo").style.display = "none";
            $("lbFilial").style.display = "none";
            $("numeroConsulta").size = "10";
            $("numeroConsulta").maxLength = "10";
            $("lbSerie").style.display = "";
            $("serieConsulta").style.display = "";
            $("lbRemetente").style.display = "";
        }else if(valorCombo=="CHAVE_NFE_NUMERO"){
            $("filialCombo").style.display = "none";
            $("lbFilial").style.display = "none";
            $("numeroConsulta").size = "44";
            $("numeroConsulta").maxLength = "44";
            $("lbSerie").style.display = "none";
            $("serieConsulta").style.display = "none";
            $("lbRemetente").style.display = "";
        }else if(valorCombo == "N_LOCALIZADOR"){
            $("numeroConsulta").size = "20";
            $("numeroConsulta").maxLength = "20";
            $("lbFilial").style.display = "none";
            $("filialCombo").style.display = "none";
            $("lbSerie").style.display = "none";
            $("serieConsulta").style.display = "none";
            $("lbRemetente").style.display = "none";
        }else{
            $("numeroConsulta").size = "7";
            $("numeroConsulta").maxLength = "14";
            $("filialCombo").style.display = "";
            $("lbFilial").style.display = "";
            $("lbFilial").style.display = "";
            $("filialCombo").style.display = "";
            $("lbSerie").style.display = "";
            $("serieConsulta").style.display = "";
            $("lbRemetente").style.display = "none";
        }

    }
    function salvar(acao){

        function ev(resp, st){
            if (st == 200)
                if (resp.split("<=>")[1] != undefined && resp.split("<=>")[1] != ""){
                    alert(resp.split("<=>")[1]);
                }
            else
                voltar();
            else
                alert("Status "+st+"\n\nNão conseguiu realizar o acesso ao servidor!");
			   
            getObj("salvar").disabled = false;
            getObj("salvar").value = "Salvar";
        }
        var qtd = jQuery("tr[id*=trCtrc]").length;
        var temCTRC = false;
        for (var i = 1; i <= qtd; i++) {
            
            if ($("trCtrc"+i).visible()) {
                temCTRC = true;
            }
        }
        
        if (!temCTRC) {
            alert("Informe no mínimo 1 CT-e ou 1 Coleta!");//msg pega de outra msg já existente.
            return false;
        }
        
        if($("idcidadedestino").value == 0){
            alert("Cidade de destino não pode ficar em branco!");
            return null;
        }

        if($("idcidadeorigem").value == 0){
            alert("Cidade de origem não pode ficar em branco!");
            return null;
        }

        /* Bloco de instrucoes */
        if (wasNull("numromaneio,dtromaneio,fi_abreviatura,motor_nome,vei_placa"))
            return alert("Preencha os campos corretamente!");
        else{
            
            if($("chkCartaAutomaticaRomaneio") != null && $("chkCartaAutomaticaRomaneio").checked){
                 var erro = validarContratoFrete();
                 if(erro != ""){
                     alert(erro)
                     return false;
                 }
            }
            
            if(parseFloat($("capacidade_cubagem2").value) > 0 && $("idcarreta").value!='0'){
                if(parseFloat($("capacidade_cubagem2").value) < parseFloat($("totalCubagem").value)){
                    if (!confirm("A cubagem total da carga é maior que a capacidade da carreta, deseja continuar?")){
                        return null;
                    }
                }
            }else{
                if(parseFloat($("capacidade_cubagem").value) > 0 && $("idveiculo").value!='0'){
                    if(parseFloat($("capacidade_cubagem").value) < parseFloat($("totalCubagem").value)){
                        if (!confirm("A cubagem total da carga é maior que a capacidade do veículo, deseja continuar?")){
                            return null;
                        }
                    } 
                }
            }
            var totSaldo = parseFloat($("cartaValorSaldo").value);
            var ir = parseFloat($("valorIRInteg").value);
            var inss = parseFloat($("valorINSSInteg").value);
            var sest = parseFloat($("valorSESTInteg").value);
            if (isRetencaoImpostoOperadoraCFe()) {
                if (totSaldo < (ir + inss + sest)) {
                    alert("ATENÇÃO: Não é possivel salvar o contrato pois a provisão dos impostos ("
                            +colocarVirgula((ir + inss + sest))+") é maior que o saldo ("+colocarVirgula(totSaldo)+").");
                    return null;
                }
            }
            
//            if (< %=carregarom%>) {
//                var codIbgeOrigem = '< %=rom.getCidadeOrigem().getCod_ibge()%>';
//                var codIbgeDestino = '< %=rom.getCidadeDestino().getCod_ibge()%>';
//                if (codIbgeOrigem != $("codigo_ibge_origem").value || codIbgeDestino != $("codigo_ibge_destino").value) {
//                    abrirLoginSupervisor('< %=cfg.getPermitirLancamantoOSAbertoVeiculo()%>',< %=TipoAutorizacao.ROMANEIO_VEICULO_MANUTECAO.ordinal()%>);
//                }
//            }
            
            if (acao == "atualizar"){
                acao += "&idromaneio=<%=(carregarom ? cadrom.getRomaneio().getIdRomaneio() : 0)%>";
            }   
            
            var ctrcsConcat = concatCtrc(false,false,true);
            $("ctrcs").value = ctrcsConcat;
            if (ctrcsConcat == '') {
                alert('Informe no mínimo 1 CT-e ou 1 Coleta!');
                return null;
            }

            document.getElementById("salvar").disabled = true;
            document.getElementById("salvar").value = "Enviando...";

            var ispreromaneio = $("ispreromaneio").checked;           
            var isCartaAutomaticaRomaneio = $("chkCartaAutomaticaRomaneio").checked;
            var isPedagioIdaVolta = $("pedagioIdaVolta").checked;
            var isSolicitaAutorizacao = $("solicitarAutorizacao").checked;
            var cartaDocAdiantamento = "";
            <%if(cfg.isControlarTalonario()){%>
                cartaDocAdiantamento = $("cartaDocAdiantamento_cb").value;
              <%} else {%>
                 cartaDocAdiantamento = $("cartaDocAdiantamento").value;
             <%}%>
                 //foi retirado do get o '&ctrcs="+ctrcsConcat"' e inserido em um hidden e enviado via post.
//            $("formBaixa").action = "./cadromaneio?acao="+acao+"&ajudantes="+concatAjud()+"&ctrcs="+ctrcsConcat+
            $("formBaixa").action = "./cadromaneio?acao="+acao+"&ajudantes="+concatAjud()+
                    "&ispreromaneio="+ispreromaneio+
                    "&isCartaAutomaticaRomaneio="+isCartaAutomaticaRomaneio+
                    "&isPedagioIdaVolta="+isPedagioIdaVolta+
                    "&is_retencao_impostos_operadora_cfe="+isRetencaoImpostoOperadoraCFe()+
                    "&isSolicitaAutorizacao="+isSolicitaAutorizacao+
                    "&cartaDocAdiantamento="+cartaDocAdiantamento+"&"+
            concatFieldValue('idfilial,numromaneio,dtromaneio,hrromaneio,idmotorista,idveiculo,idcarreta,diaria,diariaajud,observacao,idcidadedestino,idcidadeorigem,baseIR,aliqIR,valorIR,'+
            'inss_prop_retido,baseINSS,aliqINSS,valorINSS,baseSEST,aliqSEST,valorSEST,cartaValorFrete,cartaOutros,chk_reter_impostos,cartaImpostos,cartaPedagio,cartaLiquido,'+
            'cartaRetencoes,idfilial,idmotorista,motor_nome,idveiculo,idproprietarioveiculo,plano_proprietario,und_proprietario,idcarreta,obs_carta_frete,countDespesaCarta,'+
            'cartaValorAdiantamento,cartaDataAdiantamento,cartaFPagAdiantamento,idagente,plano_agente,und_agente,contaAdt,'+
            'cartaValorSaldo,cartaDataSaldo,cartaFPagSaldo,cartaDocSaldo,idagentesaldo,plano_agente_saldo,und_agente_saldo,categoria_pamcard_id,categoria_ndd_id,'+
            'dataPartida,dataTermino,eixosSuspensos,rota,percurso,natureza_cod,vlDescarga,vlTonelada,tipoProduto,motivoSolicitacao,' +
            'cartaValorCC,cartaDataCC,cartaFPagCC,contaCC,favorecidoSaldo,favorecidoAdiantamento,cfgPermitirLancamentoOSAbertoVeiculo,miliSegundos,os_aberto_veiculo,codigo_ibge_origem,codigo_ibge_destino'+
            ',contaTarifa, cartaValorTarifa, cartaDataTarifa, cartaFPagTarifa, favorecidoTarifa, cartaDocTarifa, idagenteTarifa, plano_agente_Tarifa, und_agente_Tarifa, controlarTarifasBancariasContratado'
            );
            window.open("", "pop2", "top=10,left=20,height=20,width=70");
            $("formBaixa").submit();
            
        }
    }
    var count=0;
    var numeroAnterior= "";
    
    
    function getCount(numeroConsulta){
        if(numeroConsulta != numeroAnterior){
            numeroAnterior = numeroConsulta;
            count++;
        }else{
            numeroAnterior = numeroConsulta;
        }
    }
    
    
    function validaChaveAcesso(chave){
        if(chave.length){
            return false;
        }
    }
    
    function marcarDesmarcar(){
        
        var i=1;      
        var numeroConsulta = ($("numero").value);              
        var tipoConsulta = $("tipoConsulta").value;
      
        for(i=1; i<idxCtrc; i++){
            var isAchou = false;
            var notaFiscal = (document.getElementById("lbNF1"+i).innerHTML);           
            var chaveacesso = $("chaveAcesso"+i).value;  // "12345678911234567891123456789112345678911234";
                   
            if(chaveacesso.length<44){
                alert('Chave de Acesso inválida!');
            }else{
                if (tipoConsulta == ("CHAVE_NFE_NUMERO")){
                    var nserie = chaveacesso.substring(22, 25);
                    var nfiscal= chaveacesso.substring(25, 34);
                    //var numeroserie = numeroConsulta.substring(22, 25);
                    var numerofiscal = numeroConsulta.substring(25, 34);
                    if(numerofiscal == nfiscal){
                        isAchou = true;
                    }else{
                        isAchou = false;
                    }
                }else{
                    if(numeroConsulta == chaveacesso){
                        isAchou = true;
                    }else{
                        isAchou = false;
                    }
                }
                
                if(isAchou){
                    if(($("optbarrasnao").checked)){
                        $("ck"+i).checked = false;
                        if ($("chkNaoConfirmouBarras"+i).checked){
                            alert('Você já selecionou essa entrega!');
                        }else{
                            if ($("chkConfirmouBarras"+i).checked == false && $("chkNaoConfirmouBarras"+i).checked == false){
                                getCount(numeroConsulta);
                                $("countCtColeta").innerHTML = count + "/"+(idxCtrc-1);
                            }
                            $("chkNaoConfirmouBarras"+i).checked = true;
                            $("imgOK"+i).style.display = "none";
                            $("imgNAOOK"+i).style.display = "";
                            $("chkConfirmouBarras"+i).checked = false;
                        }    
                        $("numero").value = "";
                    }else if($("optbarrassim").checked){
                        $("ck"+i).checked = true;
                        if ($("chkConfirmouBarras"+i).checked){
                            alert('Você já selecionou essa entrega!');
                        }else{
                            if ($("chkConfirmouBarras"+i).checked == false && $("chkNaoConfirmouBarras"+i).checked == false){
                                getCount(numeroConsulta);
                                $("countCtColeta").innerHTML = count + "/"+(idxCtrc-1);
                            }
                            $("chkConfirmouBarras"+i).checked = true;
                            $("chkNaoConfirmouBarras"+i).checked = false;
                            $("imgOK"+i).style.display = "";
                            $("imgNAOOK"+i).style.display = "none";
                        }
                        $("numero").value = "";
                    }
                    break;
                }   
            }
            if (i == idxCtrc-1){
                alert('Chave de acesso não encontrada!');
                $("numero").value = "";
            }    
        }
    }
    
    function voltar(){
        document.location.replace('./consultaromaneio?acao=iniciar');
    }

    function excluir(id){
        function ev(resp, st){
            if (st == 200)
                if (resp.split("<=>")[1] != "")
                    alert(resp.split("<=>")[1]);
            else
                voltar();
            else
                alert("Status "+st+"\n\nNão conseguiu realizar o acesso ao servidor!");
        }
        if (confirm("Deseja mesmo excluir este romaneio?"))
            requisitaAjax("./cadromaneio?acao=excluir&idromaneio="+id, ev);
    }

    function addAjudante(idAjud, nome, telefone, telefone2, valor) {
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
        trLine.appendChild(tdNome);
        trLine.appendChild(tdFone1);
        trLine.appendChild(tdFone2);
        //criando campo valor
        var inValor = makeElement("INPUT", "id=ajudVl" + indice + "&type=TEXT&onchange=javascript:seNaoFloatReset(getObj('ajudVl"+indice+"'),'0.00');acumAjud();&"+
            "maxLength=10&size=10&class=inputtexto&value="+formatoMoeda(valor));
        trLine.appendChild(appendObj(makeElement("TD",""), inValor));
        //incluindo na lista o botao de excluir Ajudante
    <%      if (!acao.equals("iniciar_baixa")) {%>
            trLine.appendChild(appendObj(makeElement("TD",""),
            makeElement("IMG","src=img/lixo.png&title=Excluir&class=imagemLink&onclick=delAjudante('"+indice+"')")));
    <%      }
    %>
            getObj("corpoAjud").appendChild(trLine);
            //adicionando o indice no array(como o array começa em 0 subtraimos 1)
            indexAjud[indice - 1] = true;
            //Adicionando o valor no total dos ajudantes
            acumAjud();
        }

        function delAjudante(indiceAjud) {
            if (confirm("Deseja mesmo excluir este ajudante?"))
                getObj("trAjud" + indiceAjud).parentNode.removeChild(getObj("trAjud" + indiceAjud));
            //removendo o indice no array(como o array começa em 0 subtraimos 1)
            indexAjud[indiceAjud - 1] = false;
            //Apagando o valor no total dos ajudantes
            acumAjud();
        }

        function concatAjud() {
            var ajud = "";
            for (i = 1; i <= indexAjud.length; ++i)
                if (indexAjud[i - 1] == true)
                    ajud += getObj("idAjud"+i).value+","+getObj("ajudVl"+i).value + (i == indexAjud.length? "" : "&");
            return escape(ajud);
        }

        function acumAjud() {
            var ajud = 0;
            for (i = 1; i <= indexAjud.length; ++i)
                if (indexAjud[i - 1] == true)
                    ajud =  parseFloat(ajud) + parseFloat(getObj("ajudVl"+i).value);
            getObj("diariaajud").value = formatoMoeda(parseFloat(ajud));
        }


        // javascript não possui replaceall
        function replaceAll(string, token, newtoken) {
            while (string.indexOf(token) != -1) {
                string = string.replace(token, newtoken);
            }
            return string;
        }

        function aoClicarNoLocaliza(idjanela){
            function indiceJanela(initPos, finalPos) { return idjanela.substring(initPos, finalPos); }
            //localizando ajudante
            if (idjanela.indexOf("Ajudante") > -1){
                addAjudante(getObj("idajudante").value,getObj("nome").value,getObj("fone1").value,getObj("fone2").value,getObj("vldiaria").value);
            }else if (idjanela.indexOf("Ctrc") > -1){
                if($("idromaneio").value != 'null' && $("idromaneio").value != '' && tipoAcaoRomaneio === 'a'){
                    alert("Inclusão não permitida, o CT-e/Coleta está vinculado em outro romaneio.");
                } else if($("baixa_em").value != 'null' && $("baixa_em").value != '' && ($("tipoConsulta").value == "CTRC" || $("tipoConsulta").value == "NUMERO_NFE" || $("tipoConsulta").value == "CHAVE_NFE_NUMERO" || $("tipoConsulta").value == "CHAVE_NFE" || $("tipoConsulta").value == "CHAVE_CTE")){
                    alert("CT-e já foi baixado");
                } else if(<%=!cfg.isRomanearCtrcSemChegada()%> && $("data_chegada_ctrc").value == null && $("data_chegada_ctrc").value == '' && ($("tipo").value != 'COLETA' || $("tipo_ctrc") != 'd')){
                    alert("CT-e "+ $("numeroConsulta").value +" sem data de chegada");
                }else{
                if (getObj("ctrc_resolvido").value == "t"){
                    addCtrc(
                            getObj("idmovimento").value, //idCtrc
                            getObj("nfiscal").value, //nfiscal
                            getObj("dtemissao").value, //emissao
                            getObj("filial").value, //filial
                            getObj("remetente").value, //remetente
                            getObj("destinatario").value, //destinatario
                            getObj("totalprestacao").value, //valor
                            getObj("tipo").value, //tipo
                            "false", //transferencia
                            getObj("peso").value, //peso
                            getObj("volume").value, //volume
                            getObj("is_bloqueado").value, //isBloqueado
                            false, //isBaixado
                            "", //dataBaixa
                            "", //ultimaocorrencia
                            getObj("cubagem").value, //cubagem
                            '', //numNotaFiscal
                            '', //chaveacesso
                            false, //clienteOcorrenciaEspecifica
                            0, //idRemetente
                            getObj("consignatario_id").value, //idConsignatario
                            getObj("valor_nf").value, //valorNF
                            getObj("obriga_resolucao").value, //Obrigar Resolução
                            getObj("valor_frete").value, //valor frete cte
                            getObj("valor_peso").value, // valor peso cte
                            getObj("dtchegada").value // data chegada
                    );
                    //addCtrc(idCtrc, nfiscal, emissao, filial, remetente, destinatario, valor, tipo, transferencia,peso,volume,isBloqueado, isBaixado, dataBaixa, ultimaOcorrencia, cubagem, numNotaFiscal, chaveacesso, clienteOcorrenciaEspecifica, idRemetente, idConsignatario, valorNF) {
                } else {
                    alert("Existe uma ocorrência não resolvida para este CT-e.");
                }
            }
            }else if (idjanela == "Ocorrencia_Cliente" || idjanela == "Ocorrencia"){
                $('ocorrencia'+$('ocorrencia_idx').value).value = $('ocorrencia').value;
                $('idOcorrencia'+$('ocorrencia_idx').value).value = $('ocorrencia_id').value;
                $('isResolvido'+$('ocorrencia_idx').value).value = $('obriga_resolucao').value;
                
            }else if (idjanela == "Observacao"){
                var obs = "" + $("obs_desc").value;
                obs = replaceAll(obs, "<BR>","\n");
                obs = replaceAll(obs, "<br>","\n");
                obs = replaceAll(obs, "</br>","\n");
                obs = replaceAll(obs, "</BR>","\n");
                $("observacao").value = obs;
            }else if(idjanela == "Motorista"){
                if ($("bloqueado").value == 't' && $("motivobloqueio").value != ""){
                    setTimeout(function(){alert('Esse motorista está bloqueado. Motivo: ' + $("motivobloqueio").value)},100);
                    $("motor_nome").value = '';
                    $("idmotorista").value = '';
                }
                var filtros = "veiculo_motorista,carreta_motorista";
                for(var i = 0 ; i<= filtros.split(",").length; i ++){
                    validarBloqueioVeiculoMotorista(filtros.split(",")[i]);
                }
                carregarAbastecimentos();
                abrirLoginSupervisor('<%=cfg.getPermitirLancamantoOSAbertoVeiculo()%>',<%=TipoAutorizacao.ROMANEIO_VEICULO_MANUTECAO.ordinal()%>,0,0);
                 <% if(cfg.isCartaFreteAutomaticaRomaneio() && acao.equalsIgnoreCase("iniciar")){%>
                    if($('vei_prop_cgc').value.length == 14 || ($('is_tac').value == 't' || $('is_tac').value == 'true' || $('is_tac').value == true)){
                        $('chk_reter_impostos').checked = true;
                    }else{
                        $('chk_reter_impostos').checked = false;
                    }
                <%}%>
            }else if (idjanela == 'Veiculo'){
                var bloqueado = validarBloqueioVeiculo("veiculo");
                if(!bloqueado){
                    <%if (cfg.isCartaFreteAutomaticaColeta() && acao.equalsIgnoreCase("iniciar")){ %>
                        if ($('vei_prop_cgc').value.length == 14 || ($('is_tac').value == 't' || $('is_tac').value == 'true' || $('is_tac').value == true )){
                            $('chk_reter_impostos').checked = true;
                        }else{
                            $('chk_reter_impostos').checked = false;
                        }
                    <%}%>
                    carregarAbastecimentos();
                    abrirLoginSupervisor('<%=cfg.getPermitirLancamantoOSAbertoVeiculo()%>',<%=TipoAutorizacao.ROMANEIO_VEICULO_MANUTECAO.ordinal()%>,0,0);
                }
            }else if (idjanela == 'Carreta'){
                var bloqueado = validarBloqueioVeiculo("carreta");
                if(!bloqueado){
                <%if (cfg.isCartaFreteAutomaticaRomaneio()&& acao.equalsIgnoreCase("iniciar")){ %>
                    if ($('vei_prop_cgc').value.length == 14 || ($('is_tac').value == 't' || $('is_tac').value == 'true' || $('is_tac').value == true )){
                        $('chk_reter_impostos').checked = true;
                    }else{
                        $('chk_reter_impostos').checked = false;
                    }
                <%}%>
                }
            }else if (idjanela == 'Filial'){
                $('idcidadeorigem').value = $('fi_idcidade').value;
                $('cid_origem').value = $('fi_cidade').value;
                $('uf_origem').value = $('fi_uf').value;
                
                
                setTimeout(function(){
                    if ($("cod_natureza").value != $("natureza_cod").value) {
                        if (confirm("Deseja alterar a natureza de carga para a natureza padrão da filial?")) {
                            $("natureza_cod").value = $("cod_natureza").value;
                            $("natureza_cod_desc").value = $("codigo_natureza").value;
                            $("natureza_desc").value = $("descricao_natureza").value;
                        }
                    }
                },100);
                calcularFreteCarreteiro();
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
            }
            if(idjanela == "locCtrcColetaCadRomaneio"){
                    if($("cidade_destino_id").value != 0){
                        $('cid_destino').value = $("cidade_destino").value;
                        $('idcidadedestino').value = $("cidade_destino_id").value;
                        <%if (cfg.isCartaFreteAutomaticaRomaneio()&& acao.equalsIgnoreCase("iniciar")){ %>
                            getRota();
                        <%}%>
                    }
                }
            if(idjanela == "Cidade_Origem"){
                <%if (cfg.isCartaFreteAutomaticaRomaneio()&& acao.equalsIgnoreCase("iniciar")){ %>
                    getRota();
                <%}%>
                if (<%=carregarom%>) {
                    validacaoAlterarLoginSurpervisor(<%=(carregarom ? rom.getCidadeOrigem().getIdcidade() : 0)%>,$("idcidadeorigem").value);
                }
            }
            
            if(idjanela == "Cidade_Destino"){
                <%if (cfg.isCartaFreteAutomaticaRomaneio()&& acao.equalsIgnoreCase("iniciar")){ %>
                    getRota();
                <%}%>
                if (<%=carregarom%>) {
                    validacaoAlterarLoginSurpervisor(<%=(carregarom ? rom.getCidadeDestino().getIdcidade() : 0)%>,$("idcidadedestino").value);                    
                }
            }
            
        }
        
        function validacaoAlterarLoginSurpervisor(idCidadeCarregado, idCidadeLocalizado){
            if (idCidadeCarregado != idCidadeLocalizado) {
                abrirLoginSupervisor('<%=cfg.getPermitirLancamantoOSAbertoVeiculo()%>',<%=TipoAutorizacao.ROMANEIO_VEICULO_MANUTECAO.ordinal()%>,0,0);
            }
        }

        function aoCarregar(){
            $('trCheckContrato').style.display = 'none';
            $('trContrato').style.display = 'none';
            $("natureza_cod").value = $("cod_natureza").value;
            $("natureza_cod_desc").value = $("codigo_natureza").value;
            $("natureza_desc").value = $("descricao_natureza").value;
            validacaoValorKM();            
            $("is_retencao_impostos_operadora_cfe").value = <c:out  value="${usuario.filial.retencaoImpostoOperadoraCFe}" default="false"/>;
            <%
            BeanUsuario autenticado = Apoio.getUsuario(request);
            if(autenticado.getFilial().isControlarTarifasBancariasContratado() && (autenticado.getFilial().getStUtilizacaoCfe()== 'P' || autenticado.getFilial().getStUtilizacaoCfe()== 'D'
                || autenticado.getFilial().getStUtilizacaoCfe()== 'A') ){   %>     
              $("trTarifas").style.display = "";
              $("controlarTarifasBancariasContratado").value = 'true';
              $("qtdSaques").value = ('${usuario.filial.quantidadeSaquesContratoFrete}');
              $("valorPorSaques").value = colocarVirgula('${usuario.filial.valorSaquesContratoFrete}');
              $("qtdTransf").value = ('${usuario.filial.quantidadeTransferenciasContratoFrete}');
              $("valorTransf").value = colocarVirgula('${usuario.filial.valorTransferenciasContratoFrete}');
              
              calculaTotalTarifas();
                <% if(autenticado.getFilial().getStUtilizacaoCfe()== 'D'){%>    
                    //  $("qtdSaques").readonly = 'true';
                    //  $("valorPorSaques").readonly = 'true';
                     // $("qtdTransf").readonly = 'true';
                    //  $("valorTransf").readonly = 'true';
                      $("vlTarifas").readOnly = 'true';
                      $("trTarifas2").style.display = "none";
                      $("qtdSaques").readOnly = true;
                      $("valorPorSaques").readOnly = true;
                      $("qtdTransf").readOnly = true;
                      $("valorTransf").readOnly = true;
                      $("totalSaques").readOnly = true;
                      $("totalTransf").readOnly = true;
                      $("vlTarifas").className = 'inputReadOnly8pt';
                      $("qtdSaques").className = 'inputReadOnly8pt';
                      $("valorPorSaques").className = 'inputReadOnly8pt';
                      $("qtdTransf").className = 'inputReadOnly8pt';
                      $("valorTransf").className = 'inputReadOnly8pt';//className:'inputReadOnly8pt'
                      $("totalSaques").className = 'inputReadOnly8pt';
                      $("totalTransf").className = 'inputReadOnly8pt';
                <%} else if(autenticado.getFilial().getStUtilizacaoCfe()== 'P'){%>
                    $("trTarifas2").style.display = "";
                <%}%>
            <%}%>
            
            
            <%if (carregarom) {
                isAutorizaPagamento = (!cfg.isRomaneioAutorizacaoPagamento() ? true : cfg.isRomaneioAutorizacaoPadrao());
                
                //adicioonando os ajudantes
                for (int u = 0; u < rom.getAjudantes().length; ++u) {
                    BeanAjudanteColeta ajr = rom.getAjudantes()[u];
                    %>addAjudante("<%=ajr.getAjudante().getIdfornecedor()%>",
                    "<%=ajr.getAjudante().getRazaosocial()%>",
                    "<%=ajr.getAjudante().getFone1()%>",
                    "<%=ajr.getAjudante().getFone2()%>",
                    "<%=ajr.getValor()%>");
                <%}

                //adicionando os ctrcs
                for (int x = 0; x < rom.getCtrcs().length; ++x) {
                    BeanCtrcRomaneio ctr = rom.getCtrcs()[x];
                    //Beanc ctrc = (BeanCtrcRomaneio) ctr.getCtrc().getNotasfiscais()[0];
                    %>
                    addCtrc(
                        "<%=ctr.getCtrc().getId()%>", //idCtrc
                        "<%=ctr.getCtrc().getNumero()%>", //nfiscal
                        "<%=fmt.format(ctr.getCtrc().getEmissaoEm())%>", //emissao
                        "<%=ctr.getCtrc().getFilial().getAbreviatura()%>", //filial
                        "<%=ctr.getCtrc().getRemetente().getRazaosocial()%>", //remetente
                        "<%=ctr.getCtrc().getDestinatario().getRazaosocial()%>", //destinatario
                        "<%=ctr.getCtrc().getBaseCalculo()%>", //valor
                        "<%=ctr.getTipo()%>", //tipo
                        "false", //transferencia
                        "<%=ctr.getCtrc().getCubagemMetro()%>", //peso
                        "<%=ctr.getCtrc().getCubagemBase()%>", //volume
                        "f", //isBloqueado
                        "<%=ctr.getCtrc().getBaixaEm() != null%>", //isBaixado
                        "<%=(ctr.getCtrc().getBaixaEm() == null ? "" : fmt.format(ctr.getCtrc().getBaixaEm()) + " às " + ctr.getCtrc().getEntregaAs())%>", //dataBaixa
                        "<%=ctr.getCtrc().getOcorrencia().getDescricao()%>", //ultimaOcorrencia
                        "<%=ctr.getCtrc().getCubagem_metro2()%>", //cubagem
                        "<%=ctr.getCtrc().getNota().getNumero()%>", //numNotaFiscal
                        "<%=ctr.getCtrc().getNota().getChaveNFe()%>", //chaveacesso
                        "<%=ctr.getCtrc().getCliente().isOcorrenciasClientes()%>", //clienteOcorrenciaEspecifica
                        "<%=ctr.getCtrc().getRemetente().getId()%>",// idRemetente
                        "<%=ctr.getCtrc().getCliente().getId()%>",// idConsignatario
                        "<%=ctr.getValorNota()%>", //valorNF
                        false,
                        "<%=ctr.getCtrc().getValorFrete()%>",
                        "<%=ctr.getCtrc().getValorPeso()%>",
                        "<%= ctr.getLatitude() %>",
                        "<%= ctr.getLongitude()%>",
                        "<%= ctr.getCtrc().getCidadeDestino().getUf() %>",
                        "<%= ctr.getCtrc().getCidadeDestino().getBairro().getDescricao() %>",
                        "<%= ctr.getCtrc().getCidadeDestino().getDescricaoCidade() %>",
                        "<%= ctr.getCtrc().getEnderecoEntrega().getLograoduro() %>",
                        "<%= ctr.getCtrc().getEnderecoEntrega().getBairro()%>",
                        "<%= ctr.getCtrc().getPorcentagemBateria()  %>",
                        "<%= ctr.getId() %>",
                        "<%= ctr.isIsMobileConcluido() %>",
                        "",
                        "<%= (ctr.getCtrc().getOcorrenciaCtrc() != null && ctr.getCtrc().getOcorrenciaCtrc().length > 0 ? ctr.getCtrc().getOcorrenciaCtrc()[0].getId() : "") %>"
                    );
                    //addCtrc(idCtrc, nfiscal, emissao, filial, remetente, destinatario, valor, tipo, transferencia,peso,volume,isBloqueado, isBaixado, dataBaixa, ultimaOcorrencia, cubagem, numNotaFiscal, chaveacesso, clienteOcorrenciaEspecifica, idRemetente, idConsignatario) {
                    
                    
                    //Quando o id do usuario for maior que 0 pego a informação da tabela que foi alterada romaneio_ctrc.
                    <%if(ctr.getCtrc().getUsuarioAutorizacao().getIdusuario() > 0){
                        isAutorizaPagamento = ctr.getCtrc().isAutorizadoPagamento();
                    }%>
                        
                    <%if(cfg.isRomaneioAutorizacaoPagamento()){%>
                        var idUsuarioAutorizado = "<%=ctr.getCtrc().getUsuarioAutorizacao().getIdusuario() == 0 ? Apoio.getUsuario(request).getIdusuario() : ctr.getCtrc().getUsuarioAutorizacao().getIdusuario()%>";
                        var nomeUsuarioAutorizado = "<%=ctr.getCtrc().getUsuarioAutorizacao().getIdusuario() == 0 ? Apoio.getUsuario(request).getNome() : ctr.getCtrc().getUsuarioAutorizacao().getNome()%>";
                        var descricaoRota = "<%=ctr.getCtrc().getRotaAutorizacao().getDescricao() == null ? "Rota não encontrada" : ctr.getCtrc().getRotaAutorizacao().getDescricao()%>";
                        
                        var documentoPagamento = new DocumentoPagamento("<%=ctr.getCtrc().getId()%>","<%=isAutorizaPagamento%>","<%=ctr.getTipo()%>","<%=ctr.getCtrc().getNumero()%>","<%=fmt.format(ctr.getCtrc().getEmissaoEm())%>",
                                "<%=ctr.getCtrc().getFilial().getAbreviatura()%>","<%=ctr.getCtrc().getFilial().getIdfilial()%>","<%=ctr.getCtrc().getRemetente().getRazaosocial()%>",
                                "<%=ctr.getCtrc().getRemetente().getIdcliente()%>","<%=ctr.getCtrc().getDestinatario().getRazaosocial()%>","<%=ctr.getCtrc().getDestinatario().getIdcliente()%>",
                                "<%=ctr.getCtrc().getCidadeDestino().getDescricaoCidade()%>","<%=ctr.getCtrc().getCidadeDestino().getIdcidade()%>","<%=ctr.getCtrc().getCidadeDestino().getUf()%>",
                                nomeUsuarioAutorizado,idUsuarioAutorizado,descricaoRota,"<%=ctr.getCtrc().getRotaAutorizacao().getId()%>","<%=ctr.getCtrc().getValorMotorista()%>","<%=nivelUserAutorizarPagamento%>");

                        addDocumentoPagamento(documentoPagamento);
                        atualizarQtdCteColeta();
                        $("diaria").readOnly = true;
                        $("diaria").className = "inputReadOnly";
                    <%}%>
                <%}
                
                for(MovimentacaoIscas isca: rom.getIscas()){%>
                    var iscas = new ItemIsca('<%=isca.getId()%>','<%=Apoio.getFormatData(isca.getDataSaida())%>', '<%=Apoio.getFormatData(isca.getDataChegada())%>','<%=isca.getNumeroIsca()%>');
                    addIscas(iscas);
            <%  }
            }else{%>
                if (<%=cfg.isCartaFreteAutomaticaRomaneio()%>){
                    $('trCheckContrato').style.display = '';
                    $('categoria_ndd_id').style.display = 'none';
                    $('categoria_pamcard_id').style.display = 'none';
                    $('complTextoContrato').innerHTML = '';
                    if($('st_utilizacao_cfe').value == 'P'){
                        $('categoria_pamcard_id').style.display = '';
                        $('complTextoContrato').innerHTML = '(PAMCARD)';
                    }else if ($('st_utilizacao_cfe').value == 'D'){
                        $('categoria_ndd_id').style.display = '';
                        $('complTextoContrato').innerHTML = '(NDD CARGO)';
                    }else if ($('st_utilizacao_cfe').value == 'R'){
                        $('complTextoContrato').innerHTML = '(REPOM)';
                    } else if ($('st_utilizacao_cfe').value == 'A'){
                        $('complTextoContrato').innerHTML = '(TARGET)';
                    }
                    //Colocando as permissões
                    if (<%=nivelUserAlteraImposto < 4%>){
                        $('titchkImposto').style.display = 'none';
                    }
                    if (<%=nvAlFrete < 4%>){
                        desabilitarCampo('cartaValorFrete');
                        $('cartaPedagio').readOnly = true;
                        $('cartaPedagio').className = 'inputReadOnly';
                        $('vlDescarga').readOnly = true;
                        $('vlDescarga').className = 'inputReadOnly';
                        $('cartaOutros').readOnly = true;
                        $('cartaOutros').className = 'inputReadOnly';
                        $('vlTonelada').readOnly = true;
                        $('vlTonelada').className = 'inputReadOnly';
                        $('divSolicitarAutorizacao').style.display = '';
                    }
                    
                }    
            <%}%>
            if ($("countCtColeta") != null && $("countCtColeta") != undefined) {
                $("countCtColeta").innerHTML = "0" + "/"+(<%=rom.getCtrcs().length%>);
            }
            <%if(cfg.isRomaneioAutorizacaoPagamento()){%>
                custoEntregaColeta();
            <%}%>
                
            <%if (acao.equals("iniciar_baixa")) {%>
                
            for (var i = 1; i < idxCtrc; i++){ 
                if ($("ck"+i) != null) {
                    if($("ck"+i).checked == true){
                       $("marcarTodos").checked = true;
                    }else{
                       $("marcarTodos").checked = false;
                    }
                    if ($("isCompEntrega"+i) != null) {
                        $("isCompEntrega"+i).checked = true;
                    }
                }
            }
        <%}%>
            
           if(($('cartaFPagAdiantamento').value == '3' || $('cartaFPagAdiantamento').value == '4') && <%=cfg.isBaixaAdiantamentoCartaFrete()%>){
                $('contaAdt').style.display = '';
           }else{
                $('contaAdt').style.display = 'none';
           }
            
        }

        
        function localizaOcorrencia(idx, tipo){
            $("ocorrencia_idx").value = idx;
            paramAux = $("idCtrc"+idx).value;
            if(tipo == "COLETA"){
            post_cad = window.open('./localiza?acao=consultar&idlista=48','Ocorrencia',
            'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
            }else if(tipo == "CTRC" || tipo == "CTA"){
                if($("hiddenOcorrenciaCliente"+idx).value == 'false' || $("hiddenOcorrenciaCliente"+idx).value == 'f'){
                    post_cad = window.open('./localiza?acao=consultar&idlista=40','Ocorrencia',
                    'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
                }else if($("hiddenOcorrenciaCliente"+idx).value == 'true' || $("hiddenOcorrenciaCliente"+idx).value == 't'){
                    post_cad = window.open('./localiza?acao=consultar&idlista=85&paramaux='+paramAux,'Ocorrencia_Cliente',
                    'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
                }
            }
        }

        function limpar(indice){
            $("ocorrencia"+indice).value = "";
            $("idOcorrencia"+indice).value = "";
        }

        function mostraCTRC(idx){
            var id = $("idCtrc"+idx).value;
            if ($("tipoCtrc"+idx).value == 'COLETA'){
                if (<%=nivelUserColeta == 0%>){
                    alert('Você não tem privilégios sufucientes para visualizar a Coleta!');
                }else{
                    window.open('./cadcoleta.jsp?acao=editar&id='+id+'&ex=false', 'Coleta' , 'top=0,resizable=yes,status=1,scrollbars=1');
                }
            }else{
                if (<%=nivelUserCtrc == 0%>){
                    alert('Você não tem privilégios sufucientes para visualizar o CT!');
                }else{
                    window.open("./frameset_conhecimento?acao=editar&id="+id+"&ex=false", "Conhecimento" , "top=0,resizable=yes");
                }
            }
        }
        
        function seNaoInt(index){
            seNaoIntReset($("inputOrdem"+index),"0");
        }

        function isJaExiste(xId, xTipo){
            var retorno = false;
            for(i=1; i<idxCtrc; i++){
                if ($('idCtrc'+i) != null){
                    if ($('idCtrc'+i).value == xId && $('tipoCtrc'+i).value == xTipo){
                        retorno = true;
                        break;
                    }    
                }    
            }
            return retorno;
        }
        
        function regraPosData(index){
            if ($("tipoCtrc"+index).value == "CTRC") {
                if ($("dtEntrega"+index).value != "") {
                    $("isCompEntrega"+index).checked = true;
                }else{
                    $("isCompEntrega"+index).checked = false;
                }
            }
        }
        
        var idxCtrc = 1;
        function addCtrc(idCtrc, nfiscal, emissao, filial, remetente, destinatario, valor, tipo, transferencia,peso,volume,isBloqueado, 
            isBaixado, dataBaixa, ultimaOcorrencia, cubagem, numNotaFiscal, chaveacesso, clienteOcorrenciaEspecifica, idRemetente, 
            idConsignatario, valorNF, isResolvido, valorFreteCte, valorPesoCte, latitude, longitude, destinoUf, destinoBairro, destinoCidade, destinoEndereco,
            variavel_nao_definida_antes, porcBateria,idCtrcRomaneio,isMobileConcluido,comprovanteEntrega,ocorrenciaId) {
            
            var notafiscal = (numNotaFiscal==null)? "": numNotaFiscal; 
            var chave = chaveacesso==null? "" : chaveacesso;
            
            if (isJaExiste(idCtrc, tipo)){
                alert('ATENÇÃO: ' + tipo + ' ' + nfiscal + ' já foi adicionado!');
                return null;
            }    
           
            if (isBloqueado == 't' || isBloqueado == 'true'){
                if (!confirm('Existem pendências financeiras para o cliente. Deseja continuar?')){
                    return null;
                }
            }
            destinatario = replaceAll(destinatario, '&', '');
            remetente = replaceAll(remetente, '&', '');
            var indice = idxCtrc;
            //if (getObj("trCtrc1") != null)
            //indice = parseFloat(getObj("corpoCtrc").lastChild.id.substring(6, 9)) + 1;
    
            var trLine = makeElement("TR", "class=CelulaZebra"+((indice % 2) == 0 ? 1 : 2)+"&id=trCtrc"+indice);
            //criando Ajudante
            var inIdCtrc = makeElement("INPUT", "type=hidden&id=idCtrc"+indice+"&value="+idCtrc);
            var inIdCtrcRomaneio = makeElement("INPUT", "type=hidden&id=idCtrcRomaneio_"+indice+"&name=idCtrcRomaneio_"+indice+"&value="+idCtrcRomaneio);
            var inFilial = makeElement("INPUT", "type=hidden&id=filialHidden"+indice+"&value="+filial);
            var inTipoCtrc = makeElement("INPUT", "type=hidden&id=tipoCtrc"+indice+"&value="+tipo);
            var inCubagem = makeElement("INPUT", "type=hidden&id=cubagemHidden"+indice+"&value="+cubagem);
            var inChaveAceso = makeElement("INPUT", "type=hidden&id=chaveAcesso"+indice+"&value="+chave);   
            var inIdRemetente = makeElement("INPUT", "type=hidden&id=hiddenRemetente"+indice+"&value="+idRemetente);   
            var inIdConsignatario = makeElement("INPUT", "type=hidden&id=hiddenConsignatario"+indice+"&value="+idConsignatario);   
            var isRemoverRomaneioCtrc = makeElement("INPUT", "type=hidden&id=isRemoverRomaneioCtrc_"+indice+"&value=false");   
            
            var inHiddenPeso = makeElement("INPUT", "type=hidden&id=hiddenPeso"+indice+"&value="+formatoMoeda(peso));
            var inHiddenVolume = makeElement("INPUT", "type=hidden&id=hiddenVolume"+indice+"&value="+formatoMoeda(volume));
            var inHiddenValor = makeElement("INPUT", "type=hidden&id=hiddenValor"+indice+"&value="+formatoMoeda(valor));
            var inHiddenValorNF = makeElement("INPUT", "type=hidden&id=hiddenValorNF"+indice+"&value="+formatoMoeda(valorNF));
            var inHiddenValorFreteCte = makeElement("INPUT", "type=hidden&id=hiddenValorFreteCte_"+indice+"&value="+formatoMoeda(valorFreteCte));
            var inHiddenValorPesoCte = makeElement("INPUT", "type=hidden&id=hiddenValorPesoCte_"+indice+"&value="+formatoMoeda(valorPesoCte));
            //Oderm
            var inputOrdem = makeElement("INPUT", "type=text&size=3&class=fieldMin&id=inputOrdem"+indice
                +"&onchange=seNaoInt("+indice+")&value="+indice);
        
            var isResolvidoTd = makeElement("INPUT", "type=hidden&id=isResolvido"+indice+"&value="+isResolvido);
            
            var tdOrdem = makeElement("TD", "id=tdOrdem"+indice);
            
            tdOrdem.appendChild(inputOrdem);
            tdOrdem.appendChild(isResolvidoTd);
            
            var inTransferencia = makeElement("INPUT", "type=hidden&id=transferenciaHidden"+indice+"&value="+transferencia);
            var inHiddenOcorrenciaCliente = makeElement("INPUT", "type=hidden&id=hiddenOcorrenciaCliente"+indice+"&value="+clienteOcorrenciaEspecifica);
            var tdTipo = makeElement("TD", "id=tdCtrc1" + indice);
            var lblTipo = makeElement("label", "id=lblTipo" + indice + "&innerHTML="+tipo);
            tdTipo.appendChild(lblTipo);
            var chkConfirmouBarras = makeElement("INPUT","type=checkbox&id=chkConfirmouBarras"+indice);
            var chkNaoConfirmouBarras = makeElement("INPUT","type=checkbox&id=chkNaoConfirmouBarras"+indice);
            var imgOK = makeElement("IMG","src=img/ok.png&width=20&height=20&border=0&class=imagemLink&id=imgOK"+indice);
            var imgNAOOK = makeElement("IMG","src=img/cancelar.png&width=21&height=22&border=0&class=imagemLink&id=imgNAOOK"+indice);
            
            var dtBaixa = dataBaixa==""? "" : dataBaixa.replace("às", "").trim(); 
            
            var inDataBaixa = makeElement("INPUT", "type=hidden&id=dataBaixa"+indice+"&value="+dtBaixa);
            
            tdTipo.appendChild(chkConfirmouBarras);
            tdTipo.appendChild(chkNaoConfirmouBarras);
            
            var tdNfiscal = makeElement("TD");
            var lbNfiscal = makeElement("DIV", "id=lbCtrc1" + indice + "&innerHTML="+nfiscal+"&className=linkEditar&onclick=mostraCTRC("+indice+");");
            var lbNfNumeroNF = makeElement("DIV", "id=lbNF1" + indice + "&innerHTML=NF:"+notafiscal);
            tdNfiscal.appendChild(lbNfiscal);
            if (notafiscal != ''){
                tdNfiscal.appendChild(lbNfNumeroNF);
            }
            tdNfiscal.appendChild(inChaveAceso);
            tdNfiscal.appendChild(imgOK);
            tdNfiscal.appendChild(imgNAOOK);
            
            var tdEmissao = makeElement("TD", "id=tdCtrc1" + indice + "&innerHTML="+emissao);
            var tdFilial = makeElement("TD", "id=tdCtrc1" + indice + "&innerHTML="+filial);
            var tdRemetente = makeElement("TD", "id=tdCtrc1" + indice + "&innerHTML="+remetente);
            var tdDestinatario = makeElement("TD", "id=tdCtrc1" + indice + "&innerHTML="+destinatario);
            var tdFrete = makeElement("TD", "id=tdCtrc1" + indice + "&align=right&innerHTML="+formatoMoeda(valor));
            var tdPeso = makeElement("TD", "id=tdCtrc1" + indice + "&align=right&innerHTML="+formatoMoeda(peso));
            var tdVolume = makeElement("TD", "id=tdCtrc1" + indice + "&align=right&innerHTML="+formatoMoeda(volume));
            var tdValor = makeElement("TD", "id=tdCtrc1" + indice + "&align=right&innerHTML="+formatoMoeda(valorNF));
            var tdCubagem = makeElement("TD", "id=tdCtrc1" + indice + "&align=right&innerHTML="+cubagem);
           
            var inIdOcorrencia = makeElement("INPUT", "type=hidden&id=idOcorrencia"+indice+"&value=0");
            var isBaixadoCte = makeElement("INPUT", "type=hidden&id=isBaixado"+indice+"&value="+isBaixado);

            trLine.appendChild(inIdCtrc);
            trLine.appendChild(inIdCtrcRomaneio);
            trLine.appendChild(inChaveAceso);
            trLine.appendChild(inFilial);
            trLine.appendChild(inTipoCtrc);
            trLine.appendChild(inHiddenPeso);
            trLine.appendChild(inHiddenVolume);
            trLine.appendChild(inHiddenValor);
            trLine.appendChild(inHiddenValorNF);
            trLine.appendChild(inHiddenValorFreteCte);
            trLine.appendChild(inHiddenValorPesoCte);
            trLine.appendChild(inTransferencia);
            trLine.appendChild(inDataBaixa);
            trLine.appendChild(inHiddenOcorrenciaCliente);
            trLine.appendChild(inIdRemetente);
            trLine.appendChild(inIdConsignatario);
            trLine.appendChild(isRemoverRomaneioCtrc);
            trLine.appendChild(inIdOcorrencia);
            trLine.appendChild(isBaixadoCte);
            trLine.appendChild(inCubagem==undefined? "" : inCubagem);     
            
            
    <%if (acao.equals("iniciar_baixa")) {%>
                        
            //if (!isBaixado){
            if (isMobileConcluido == 'true') {
                trLine.appendChild(appendObj(makeElement("TD",""),
                makeElement("img","src=img/caminhao.png&width=40px&height=20px")));
            }else{
                trLine.appendChild(appendObj(makeElement("TD",""),
                makeElement("INPUT","type=checkbox&id=ck"+indice)));
            }
            //}
    <%}%>
            trLine.appendChild(tdOrdem);
            trLine.appendChild(tdTipo);
            trLine.appendChild(inChaveAceso);
            trLine.appendChild(tdNfiscal);
            trLine.appendChild(tdEmissao);
            trLine.appendChild(tdFilial);
            trLine.appendChild(tdRemetente);
            trLine.appendChild(tdDestinatario);
            trLine.appendChild(tdFrete);
            trLine.appendChild(tdPeso);
            trLine.appendChild(tdVolume);
            trLine.appendChild(tdValor);
            trLine.appendChild(tdCubagem==undefined? null:tdCubagem)
    <%      if (acao.equals("iniciar_baixa")) {%>
            
            var validarData = "alertInvalidDate(this),regraPosData(" + indice + ")";
            var validarHora = "mascaraHora(this)";
            
            var tdObs = makeElement("TD", "innerHTML=Data:  ");
            var inDtEntrega = makeElement("INPUT", "type=text&class=fieldDateMin&size=10&onblur="+validarData+"&id=dtEntrega"+indice);
            var inHrEntrega = makeElement("INPUT", "type=text&class=fieldMin&size=3&onKeyUp="+validarHora+"&id=hrEntrega"+indice);
            var inObs = makeElement("INPUT", "type=text&class=fieldMin&size=30&maxLength=150&id=obs"+indice);
            var trEntrega = makeElement("TD", "");
            var labelEntrega = makeElement("label", "innerHTML=Comprov. Entrega ");
            var inpCompEntrega = makeElement("INPUT","type=checkbox&id=isCompEntrega"+indice+ (comprovanteEntrega ? "checked" : ""));
            
            tdObs.appendChild(inDtEntrega);
            tdObs.appendChild(inHrEntrega);
            tdObs.appendChild(inObs);
            
            var nivel = '<%= (nivelUserMarcarComprovanteBaixaEntradaCte) %>';//Permissão 332 - Preencher campo de comprovante de entrega ao baixar a entrega de um CT-e
            
            if (nivel  != 0 && inTipoCtrc.value == "CTRC") {
                tdObs.appendChild(trEntrega);
                tdObs.appendChild(inpCompEntrega);
                tdObs.appendChild(labelEntrega);
            }
            
            trLine.appendChild(tdObs);
            //Campo OCORRENCIA
            trLine.appendChild(appendObj(makeElement("TD",""),
            makeElement("INPUT","type=text&id=ocorrencia"+indice+"&size=2&length=2&value=&readOnly=true&class=inputReadOnly8pt")));
            //Campo LOCALIZAR OCORRENCIA
            trLine.appendChild(appendObj(makeElement("TD",""),
            makeElement("INPUT","type=button&id=btOcorrencia"+indice+"&value=...&class=inputBotaoMin&onclick=localizaOcorrencia("+indice + ",'" + tipo + "');")));
            //Campo LIMPAR OCORRENCIA
            trLine.appendChild(appendObj(makeElement("TD",""),
            makeElement("IMG","src=img/borracha.gif&onclick=limpar("+indice +")&id=brLimparOco"+indice)));
    <%      }%>
            //incluindo na lista o botao de excluir CTRC
    <%      if (!acao.equals("iniciar_baixa")) {%>
            trLine.appendChild(appendObj(makeElement("TD",""),
            makeElement("IMG","src=img/lixo.png&title=Excluir&class=imagemLink&onclick=delCtrc('"+indice+"')")));
    <%      }%>
            getObj("corpoCtrc").appendChild(trLine);
    <%      if (acao.equals("iniciar_baixa")) {%>
            //**GAMBI
            if (getObj("ck"+indice) != null) {
                getObj("ck"+indice).checked = true;
            }
    <%      }%>
            //Se o CTRC estiver baixado mostrar os dados da baixa.
    <%if (acao.equals("iniciar_baixa")) {%>
            if (isBaixado == 't' || isBaixado == 'true' || isBaixado == true || ultimaOcorrencia != ''){
                if (isBaixado == 't' || isBaixado == 'true' || isBaixado == true) {
                    if (getObj("ck"+indice) != null) {
                        getObj("ck"+indice).checked = false;
                        getObj("ck"+indice).readOnly = true;
                    }
                    getObj("ocorrencia"+indice).readOnly = true;
                    getObj("btOcorrencia"+indice).style.display = "none";
                    getObj("brLimparOco"+indice).style.display = "none";
                    getObj("ocorrencia"+indice).value = ultimaOcorrencia.split("-")[0];
                }
                
                
                // criando a linha 2.
                var trLine2 = makeElement("TR", "class=CelulaZebra"+((indice % 2) == 0 ? 1 : 2)+"&id=trCtrc2"+indice);
                // TD de data de entrega.
                var tdLine2_1 = makeElement("TD", "id=tdCtrc2_1" + indice + "&innerHTML=Data Entrega: "+dataBaixa+"&colSpan=5");
                // TD de ULTIMA OCORRENCIA.
                var tdLine2_2 = makeElement("TD", 
                    "id=tdCtrc2_2" + indice + 
                    "&innerHTML=Última Ocorrência: "+ultimaOcorrencia+"="+
                    "&colSpan=6"
                );
        
                var tdVerAnexos = makeElement("TD",
                    "id=tdCtrc2_3"+ //vou continuar os nomes mesmo sendo ruim a leitura;
                    "&colSpan=2"
                );
                
                var linkVerAnexo = makeElement("A",
                    "innerHTML=ver anexos"+
                    "&onclick=javascript: popImg('"+idCtrc+"', '"+ocorrenciaId+"');"+
                    "&class=linkEditar"
                );
        
                var tdPorcBateria = makeElement("TD",
                    "id=tdCtrc2_5"
                );
        
                var labelPorcBateria = makeElement("label",
                    ""
                );
                labelPorcBateria.innerHTML="Bateria: "+porcBateria+"%";
        
                var tdCompararLocalMapa = makeElement("TD",
                    "id=tdCtrc2_4"+
                    "&colSpan=3"
                );
        
                var imgLocalMapa = makeElement("img",
                    "src=img/gmaps.png"+
                    "&width=19" +
                    "&height=19" +
                    "&border=0" +
                    "&align=right" +
                    "&class=imagemLink" +
                    "&title=Mapa" +
                    "&onclick=javascrip:rotasNoMaps('"+latitude+"','"+longitude+"','"+destinoUf+"','"+destinoCidade+"','"+destinoEndereco+"','"+destinoBairro+"');"
                );
                
                tdVerAnexos.appendChild(linkVerAnexo);
                tdPorcBateria.appendChild(labelPorcBateria);
                tdCompararLocalMapa.appendChild(imgLocalMapa);
                
//                var ip_DataBaixa = 
                trLine2.appendChild(tdLine2_1);
                trLine2.appendChild(tdLine2_2);
                trLine2.appendChild(tdVerAnexos);
                trLine2.appendChild(tdPorcBateria);
                trLine2.appendChild(tdCompararLocalMapa);
                
                
                getObj("corpoCtrc").appendChild(trLine2);
                
                if (dataBaixa == ''){
                    if (getObj("lblTipo"+indice).innerHTML == 'COLETA') {
                        getObj("ocorrencia"+indice).value ='<%= cfg.getOcorrenciaRomaneio().getCodigo()%>';
                        getObj("idOcorrencia"+indice).value = '<%= cfg.getOcorrenciaRomaneio().getId()%>';
                    }else if(getObj("lblTipo"+indice).innerHTML == 'CTRC'){
                        getObj("ocorrencia"+indice).value ='<%= cfg.getOcorrenciaRomaneio().getCodigo()%>';
                        getObj("idOcorrencia"+indice).value = '<%= cfg.getOcorrenciaRomaneio().getId()%>';                        
                    }
                }    
            }else{
                if (getObj("lblTipo"+indice).innerHTML == 'COLETA') {
                    getObj("ocorrencia"+indice).value ='<%= cfg.getOcorrenciaRomaneioColeta().getCodigo()%>';
                    getObj("idOcorrencia"+indice).value = '<%= cfg.getOcorrenciaRomaneioColeta().getId()%>';
                }else if(getObj("lblTipo"+indice).innerHTML == 'CTRC'){
                    getObj("ocorrencia"+indice).value ='<%= cfg.getOcorrenciaRomaneio().getCodigo()%>';
                    getObj("idOcorrencia"+indice).value = '<%= cfg.getOcorrenciaRomaneio().getId()%>';                        
                }                
            }
    <%}%>

            //adicionando o indice no array(como o array começa em 0 subtraimos 1)
            indexCtrc[indice - 1] = true;

            CalculosAddCtrc();
           
            $("lbCtrc1" + indice).className = 'linkEditar';
            
            if ($('imgOK'+indice) != null){
                $('imgOK'+indice).style.display = "none";
                $('imgNAOOK'+indice).style.display = "none";
            }
            if ($('chkNaoConfirmouBarras'+indice)!= null){
                $('chkNaoConfirmouBarras'+indice).style.display = "none";
                $('chkConfirmouBarras'+indice).style.display = "none";
            }
              
            idxCtrc++;
            applyFormatter();
        }

        function rotasNoMaps(latitude,longitude, uf, cidade, endereco, bairro){
            var destinos = "";
            
            destinos = endereco + " " + bairro + " " + cidade + " " + uf;
            
            var origem =  latitude+","+longitude;
            //if copiado de funcoestelactrc
            if(origem == undefined || origem == null || origem.indexOf("null") > -1){
                alert("Não foi possível identificar o local da baixa, campos latitude e/ou longitudes não foi encontrado!");
                return false;
            }

            if (origem == null || destinos == null)
                    return null;
            var url = "http://maps.google.com/maps?saddr="+origem + "&daddr="+destinos;
            window.open(url,"googMaps","top=0, height=650, width=800, scrollbars=yes,resizable=yes");

        }


        function popImg(idconhecimento, ocorrencia_id){
            window.open('./ImagemControlador?acao=carregar&idconhecimento='+idconhecimento + '&ocorrencia_id=' + ocorrencia_id,
            'imagensConhecimento','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
        }

        function delCtrc(indiceCtrc) {
            if (confirm("Deseja mesmo excluir este CT-e do romaneio?")){
//                getObj("trCtrc" + indiceCtrc).parentNode.removeChild(getObj("trCtrc" + indiceCtrc));
                jQuery("#isRemoverRomaneioCtrc_" + indiceCtrc).val("true");
                jQuery("#trCtrc" + indiceCtrc).hide();
            
                //removendo o indice no array(como o array começa em 0 subtraimos 1)
//                indexCtrc[indiceCtrc - 1] = false;
                CalculosAddCtrc();
            }
        }
    

        function CalculosAddCtrc(){
            var totalCts = 0, totalColeta = 0, totalPeso = 0, totalVolumes = 0, totalValor = 0, totalCubagem=0, totalValorNF=0, totalValorFreteCte = 0, totalValorPesoCte = 0;
            
            for (i = 1; i <= indexCtrc.length; ++i){
                if (indexCtrc[i - 1] == true){
                    if ($("tipoCtrc"+i).value == "COLETA" ){
                        totalColeta++;
                    }else {
                        totalCts++;
                    }
                                          
                    totalPeso += parseFloat($("hiddenPeso"+i).value);
                    totalVolumes += parseFloat($("hiddenVolume"+i).value);
                    totalValor += parseFloat($("hiddenValor"+i).value);   
                    totalValorNF += parseFloat($("hiddenValorNF"+i).value);   
                    
                    totalCubagem += parseFloat($("cubagemHidden"+i).value);
                    
                    totalValorFreteCte += parseFloat($("hiddenValorFreteCte_"+i).value);
                    totalValorPesoCte += parseFloat($("hiddenValorPesoCte_"+i).value);
                                 
                }
            }
        
                       
            
            $("totalColeta").value = totalColeta;
            $("lbTotalColeta").innerHTML = $("totalColeta").value;         
            $("totalCts").value = totalCts;
            $("lbTotalCts").innerHTML = $("totalCts").value;
            $("totalPeso").value = formatoMoeda(totalPeso);
            $("lbTotalPeso").innerHTML = $("totalPeso").value;
            $("pesoTonelada").value = totalPeso/1000;
            $("labTotalPesoTon").innerHTML = formatoMoeda(totalPeso/1000) + " TON";
            $("totalVolumes").value = formatoMoeda(totalVolumes);
            $("lbTotalVolume").innerHTML = $("totalVolumes").value;
            $("totalValor").value = formatoMoeda(totalValor);
            $("lbTotalFrete").innerHTML = $("totalValor").value;
            $("totalCubagem").value = totalCubagem.toFixed(4);
            $("lbTotalCubagem").innerHTML = $("totalCubagem").value;
            $("totalValorNF").value = formatoMoeda(totalValorNF);
            $("lbTotalValorNF").innerHTML = $("totalValorNF").value;
            $("totalValorFreteCte").value = formatoMoeda(totalValorFreteCte);
            $("totalValorPesoCte").value = formatoMoeda(totalValorPesoCte);

            if(parseFloat($("capacidade_cubagem2").value) > 0 && $("idcarreta").value!='0'){
                if(parseFloat($("capacidade_cubagem2").value) < parseFloat($("totalCubagem").value)){
                    alert("ATENÇÃO! A cubagem total da carga é maior que a capacidade da carreta.");
                } 
            }else{
                if(parseFloat($("capacidade_cubagem").value) > 0 && $("idveiculo").value!='0'){
                    if(parseFloat($("capacidade_cubagem").value) < parseFloat($("totalCubagem").value)){
                        alert("ATENÇÃO! A cubagem total da carga é maior que a capacidade do veículo.");
                    } 
                }
            }  
        }
        
        /*
         * Ao mexer neste código abaixo, verificar a ordem dos campos no objeto CTRC, pos essa mesma ordem 
         * é usada acima no controlador que está na mesma página.
         * Se for adicionar algum campo a mais, tentar usar as posições que já existem
         * @returns {ctrc}
         */
        function concatCtrc(baixando,apenasId,transferencia) {
            try {
                var ctrc = "";
                for (i = 1; i <= indexCtrc.length; ++i)
                    if (indexCtrc[i - 1] == true)
                        if (apenasId){
                            ctrc += $("idCtrc"+i).value
                                + (i == indexCtrc.length? "" : ",");
                        }else{
                            ctrc += $("idCtrc"+i).value + '!!' + $("tipoCtrc"+i).value
                                 + (transferencia ? '!!' + $("transferenciaHidden"+i).value : '!!-')
                                 + (baixando ? '!!' + ($("obs"+i).value==''?' ':$("obs"+i).value) + '!!' + ($("ck" + i) != null ? $("ck" + i).checked : false) + '!!' + $('hiddenOcorrenciaCliente'+i).value + '!!' + ($("isCompEntrega"+i) != null && $("isCompEntrega"+i) != undefined ? $("isCompEntrega"+i).checked : "") + '!!' +
                                 $('idOcorrencia'+i).value + '!!' + $("dtEntrega"+i).value + '!!' + $("hrEntrega"+i).value : '!!-!!-!!-!!-!!-!!-!!-!!-')
                                 + '!!' + $("inputOrdem"+i).value +"!!"+$("dataBaixa"+i).value+ '!!-!!'+$("idCtrcRomaneio_"+i).value +"!!"+$("isRemoverRomaneioCtrc_"+i).value
                                 + '!!' + ($("ck"+i) == null ? 'true' : 'false')// se existe ck é por que não foi baixado pelo mobile.
                                 + (i == indexCtrc.length? "" : "@@@");
                                

                }
                return ctrc;
            } catch (e) { 
                alert(e);
            }
             
        }
        
        function ctrcsConfirmados(){
            var result= "";
           
//          Campo comentado, essa validação foi feito na propria visão vlocaliza_ctrc_romaneio
//            if('<cfg.isCtrcsConfirmadosParaRomaneio()'=='true'){
//                result= "and is_cte_confirmado(v.serie, v.especie, v.sale_id)";   
//            }else{
//                result=" and true ";
//            }
            return result;
        }
        
        
        function validarEntrega(){
            if(count<idxCtrc){
                alert("Ainda faltam "+(idxCtrc)-count+ "CT/Coletas!");
                return false;
            }
        }

        function baixar(id) {
            
            var isIncluirOcorrencia = <%=cfg.isObrigarOcorrenciaBaixCtrc()%>;
            var isBaixar = false;
            
            if(count > 0 && count<(idxCtrc-1)){
                var x = (idxCtrc-1)- count;
                if(!confirm("Falta(m) selecionar pelo leitor "+x+" CT(s). Deseja salvar mesmo assim?")){
                    return false;
                }    
            }    
            
            for (var i = 1; i <= indexCtrc.length; i++) {
                if (getObj("ck"+i) != null && getObj("ck"+i).checked) {
                    if(isIncluirOcorrencia && $("idOcorrencia"+i).value == 0 && $("isBaixado"+i).value == "false"){
                        isBaixar = true;
                        break;
                    }
                }
            }
            
            if (isBaixar) {
                alert("Não é possível baixar o CT-e sem ocorrência!");
                return false;
            }
            
            function ev(resp, st){
                if (st == 200)
                    if (resp.split("<=>")[1] != ""){
                        alert(resp.split("<=>")[1]);
                    }else
                    voltar();
                else
                    alert("Status "+st+"\n\nNão conseguiu acessar o servidor!");
            }
            /*BLOCO de Instrucoes*/
            var ctrcs = concatCtrc(true,false,true);
            if (ctrcs == ""){
                alert("Marque pelo menos um CT-e.");
                return false;
            }
            $("id").value = id;
            $("ctrcs").value = ctrcs;
            $("dtentregabx").value = $('dtentrega').value;
            $("formBaixa").action = "./cadromaneio?acao=baixar&dtentrega="+$('dtentrega').value;
            window.open("", "pop2",  "top=10,left=20,height=20,width=70");
            $("formBaixa").submit();
            //var url = "./cadromaneio?acao=baixar&id="+id+"&ctrcs="+ctrcs+"&dtentrega="+$('dtentrega').value;
            //requisitaAjax(url, ev);
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
        
        function localizarCidadeOri(){
            launchPopupLocate('./localiza?acao=consultar&idlista=11' + '&paramaux=' + $('idcidadedestino').value, 'Cidade_Origem');
        }

        function localizarCidadeDest(){            
            launchPopupLocate('./localiza?acao=consultar&idlista=12'  + '&paramaux=' + $('idcidadeorigem').value, 'Cidade_Destino');
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
                totalFreteCadastroProp = parseFloat(totalLiquidoProp * parseFloat(PercFreteCadastroProp) / 100);

                $('cartaValorFrete').value = formatoMoeda(totalFreteCadastroProp + parseFloat($('tab_valor_fixo').value));
                $('valor_maximo_rota').value = formatoMoeda(totalFreteCadastroProp);
                
            }

            var freteCarreteiro = parseFloat($('cartaValorFrete').value);
            var freteOutros = parseFloat($('cartaOutros').value);
            var fretePedagio = parseFloat($('cartaPedagio').value);
            var freteDescarga = parseFloat($('vlDescarga').value);
            var freteLiquido = 0;
            $('lbBaseImpostos').innerHTML = '0.00';

            calculaImpostos();
            freteLiquido = parseFloat(freteCarreteiro + freteOutros + fretePedagio + freteDescarga - parseFloat($('cartaImpostos').value) -  parseFloat(colocarPonto($('cartaRetencoes').value)) - parseFloat($("abastecimentos").value));

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
            
            $('diaria').value = $('cartaValorFrete').value;

        } 
        
        function gerarContratoFreteRomaneio(){            
            if($("chkCartaAutomaticaRomaneio").value){
                $("linhaValorCarga").style.display = "none";
            }else{
                $("linhaValorCarga").style.display = "";
            }
        }
        
        function validarFreteCarreteiro(){
            // Verificar se o usuário NÃO tem permissão de:
            // * "(CONTRATO DE FRETE) Alterar o valor do contrato desconsiderando o valor que será calculado automaticamente pela tabela de preço."
            // * "(CONTRATO DE FRETE) Autorizar contrato de frete com valor maior que o definido na tabela de preço."
            // Se não tiver, caso tenha tabela de rota, deverá validar se o valor do contrato não extrapola o valor máximo da tabela.
            // A validação só será feita para o tipo de tabela rota "Valor fixo" e "R$/KM"
            if (valueBefore !== null && valueBefore !== '0,00' && valueBefore !== this.value
                && validarValorMaximoTabelaRotaPermissao
                && !$('solicitarAutorizacao').checked
                && ($('tab_tipo_valor').value === 'f' || $('tab_tipo_valor').value === 'k')) {
                let valorFrete = 0;

                if ($('tab_tipo_valor').value === 'f') {
                    valorFrete = parseFloat($("cartaValorFrete").value);
                } else if ($('tab_tipo_valor').value === 'k') {
                    valorFrete = parseFloat($("valorPorKM").value);
                }

                let valorMaximoTabela = parseFloat($('tab_valor_maximo').value);

                if (valorFrete > valorMaximoTabela) {
                    if ($('tab_tipo_valor').value === 'f') {
                        alert('Valor do contrato maior que o máximo permitido para rota. Você deverá solicitar autorização para lançar esse valor.')
                    } else if ($('tab_tipo_valor').value === 'k') {
                        alert('Valor do KM maior que o máximo permitido para rota. Você deverá solicitar autorização para lançar esse valor.')
                    }

                    valueBefore = '0,00';

                    getTabelaPreco();
                }
            }
        }
        
        function calculaSest(baseCalculo){
            var aliquota = parseFloat(<%=cfg.getSestSenatAliq()%>);
            var sest = new Sest(baseCalculo, aliquota);
            
            if (isRetencaoImpostoOperadoraCFe()) {
                $("valorSESTInteg").value = formatoMoeda(sest.valorFinal);
            } else {
                $("baseSEST").value = formatoMoeda(sest.baseCalculo);
                $("aliqSEST").value = formatoMoeda(sest.aliquota);
                $("valorSEST").value = formatoMoeda(sest.valorFinal);
            }
            return sest;
        }
        
        function calculaIR(inss){
            var percentualBase = parseFloat(<%=cfg.getIrAliqBaseCalculo()%>);
            var faixas = new Array();
            faixas[0] = new Faixa(0, parseFloat(<%=cfg.getIrDe1()%>), 0, 0);
            faixas[1] = new Faixa(parseFloat(<%=cfg.getIrDe1()%>), parseFloat(<%=cfg.getIrAte1()%>), parseFloat(<%=cfg.getIrAliq1()%>), parseFloat(<%=cfg.getIrdeduzir1()%>));
            faixas[2] = new Faixa(parseFloat(<%=cfg.getIrDe2()%>), parseFloat(<%=cfg.getIrAte2()%>), parseFloat(<%=cfg.getIrAliq2()%>), parseFloat(<%=cfg.getIrDeduzir2()%>));
            faixas[3] = new Faixa(parseFloat(<%=cfg.getIrDe3()%>), parseFloat(<%=cfg.getIrAte3()%>), parseFloat(<%=cfg.getIrAliq3()%>), parseFloat(<%=cfg.getIrDeduzir3()%>));
            faixas[4] = new Faixa(parseFloat(<%=cfg.getIrAte3()%>), 99999999, parseFloat(<%=cfg.getIrAliqAcima()%>), parseFloat(<%=cfg.getIrdeduzirAcima()%>));
            var baseIRJaRetida = $('base_ir_prop_retido').value;
            var valorIRJaRetido = $('ir_prop_retido').value;
            var isCalculaDependentes = '<%=cfg.isConsideraDependentesIr()%>';
            var valorPorDependente = '<%=cfg.getIrVlDependente()%>';
            var isDeduzirINSSIR = '<%=cfg.isDeduzirINSSIR()%>'
            var ir = new IR(inss.valorFrete, percentualBase, faixas, inss.valorFinal, baseIRJaRetida, valorIRJaRetido, $("qtddependentes").value, valorPorDependente, isCalculaDependentes, isDeduzirINSSIR);
            
            if (isRetencaoImpostoOperadoraCFe()) {
                $("valorIRInteg").value = formatoMoeda(ir.valorFinal);
            } else {
                $("valorIR").value = formatoMoeda(ir.valorFinal);
                $("baseIR").value = formatoMoeda(ir.baseCalculo);
                $("aliqIR").value = formatoMoeda(ir.aliquota); 
                $("vlDependentes").value = colocarVirgula(valorPorDependente);
            }
            
        }
        
        function calculaInss(){
            var valorFrete = parseFloat($("cartaValorFrete").value);
            if (<%=cfg.isOutrosRetemImposto()%>){
                valorFrete += parseFloat($('cartaOutros').value);
            }    
            if (<%=cfg.isDescargaRetemImposto()%>){
                valorFrete += parseFloat($('vlDescarga').value);
            }

            if (<%=cfg.isDeduzirImpostosOutrasRetencoesCfe()%>) {
                var valor = parseFloat($('cartaRetencoes').value);

                if (isNaN(valor)) {
                    valor = 0;
                }

                valorFrete -= valor;
            }

            $('lbBaseImpostos').innerHTML = formatoMoeda(valorFrete);
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

            if (isRetencaoImpostoOperadoraCFe()) {
                $("valorINSSInteg").value = formatoMoeda(inss.valorFinal);
            } else {
                $("baseINSS").value = formatoMoeda(inss.baseCalculo);
                $("aliqINSS").value = formatoMoeda(inss.aliquota);
                $("valorINSS").value = formatoMoeda(inss.valorFinal);
            }


            return inss;
        }     
        function limparImpostos(){
            $('cartaImpostos').value = '0.00';
            $("valorINSS").value = '0.00';
            $("valorSEST").value = '0.00';
            $("valorIR").value = '0.00';
        }
        function calculaImpostos(){
            calcularRetencoes();

            var isReter = $("chk_reter_impostos").checked;
            if(isReter){
                var inss = calculaInss();
                calculaSest(inss.baseCalculo);
                calculaIR(inss);
                $('cartaImpostos').value = formatoMoeda(parseFloat($("valorINSS").value) + parseFloat($("valorSEST").value) + parseFloat($("valorIR").value));
                if (isRetencaoImpostoOperadoraCFe()) {
                    $("chk_reter_impostos").checked = false;
                    alert("ATENÇÃO: Os impostos serão calculados no momento da quitação do saldo!");
                    limparImpostos();
                }
            }else{
                limparImpostos();
                if (isRetencaoImpostoOperadoraCFe()) {
                    var inss = calculaInss();
                    calculaSest(inss.baseCalculo);
                    calculaIR(inss);
                    $('cartaImpostos').value = formatoMoeda(parseFloat($("valorINSS").value) + parseFloat($("valorSEST").value) + parseFloat($("valorIR").value));
                }
            }
        }
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
 
            if($("cartaValorFrete").value == "0.00"){
                cont++;
                erro += cont+"-Informe o valor frete.\n";
            }
            
            if($('solicitarAutorizacao').checked && $('motivoSolicitacao').value == ''){
                cont++;
                erro += cont+"-Informe o motivo da solicitação de alteração do valor do frete.\n";
            }    
            
            if ($('st_utilizacao_cfe').value == 'P' || $('st_utilizacao_cfe').value == 'D' || $('st_utilizacao_cfe').value == 'R' || $('st_utilizacao_cfe').value == 'A'){
                if($('dataPartida').value == ''){
                    cont++;
                    erro += cont+"-Informe a data de partida (CIOT).\n";
                }    

                if($('dataTermino').value == ''){
                    cont++;
                    erro += cont+"-Informe a data de término da viagem (CIOT).\n";
                }    

                if($('rota').value == '0' || $('rota').value == ''){
                    cont++;
                    erro += cont+"-Informe a rota (CIOT).\n";
                }
                
                if (($('st_utilizacao_cfe').value == 'P' && $('categoria_pamcard_id').value == '0') || ($('st_utilizacao_cfe').value == 'D' && $('categoria_ndd_id').value == '0')){
                    cont++;
                    erro += cont+"-Informe a categoria do veículo (CIOT).\n";
                }  
                
                if($('st_utilizacao_cfe').value == 'P' && $("natureza_cod").value == 0){
                    cont++;
                    erro += cont+"-Informe a natureza da carga corretamente (CIOT).\n";
                }
                
            }
            
            erro += erroViagem;
            return erro;
       }
       
        function alteraFpag(tipo){
            if (tipo == 'a'){
                $('agente').style.display = 'none';
                $('localiza_agente_adiantamento').style.display = 'none';
                $('contaAdt').style.display = 'none';
                if ($('cartaFPagAdiantamento').value == '8'){ //Carta frete
                        $('agente').style.display = '';
                        $('localiza_agente_adiantamento').style.display = '';
                        $('contaAdt').style.display = 'none';
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
                }else if($('cartaFPagAdiantamento').value == '4' && <%=cfg.isBaixaAdiantamentoCartaFrete()%>){
                    $('contaAdt').style.display = '';
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
        
        function carregarAjaxTalaoCheque(textoresposta, elemento){
    
            if (textoresposta == "-1"){
                alert('Houve algum problema ao requistar o novo cheque, favor informar manualmente.');
                return false;
            }else{

                var lista = jQuery.parseJSON(textoresposta);
                var listCheque = lista.list[0].documento;
                var talaoCheque;
                var slct = elemento;
                var isPrimeiro = true;

                var valor = "";
                removeOptionSelected(elemento.id);
                slct.appendChild(Builder.node('OPTION', {value:valor}, valor));
                var length = (listCheque!= undefined && listCheque.length != undefined ? listCheque.length : 1);

                for(var i = 0; i < length; i++){
                    if(length > 1){
                        talaoCheque = listCheque[i];
                        valor += (isPrimeiro ? talaoCheque:"");

                    }else{
                        talaoCheque = listCheque;
                    }
                    if(talaoCheque != null && talaoCheque != undefined){
                        slct.appendChild(Builder.node('OPTION', {value:talaoCheque}, talaoCheque));
                    }
                    isPrimeiro = false;
                }
                slct.value = valor;
            }
        }
        
        function geraContrato(){
            if($('chkCartaAutomaticaRomaneio').checked){
                $('trContrato').style.display = '';
                $('diaria').readOnly = true;
                $('diaria').className = 'inputReadOnly';
            }else{
                $('trContrato').style.display = 'none';
                $('diaria').readOnly = false;
                $('diaria').className = 'inputtexto';
            }

            getTabelaPreco();
        }

        function getRota(){

            function e(transport){
                var textoresposta = transport.responseText;

                var acao = '${param.acao}';
                var rota_ant = '${cadContratoFrete.rota.id}';
                
                //se deu algum erro na requisicao...
                if (textoresposta == "-1"){
                    alert('Houve algum problema ao requistar as rotas, favor tente novamente. ');
                    return false;
                }else{
                    
                    var rotaX =jQuery.parseJSON(textoresposta).list[0].rota;
                    var listRota = rotaX;
                    var rotaY;
                    var slct = $("rota");
                    var rotaIdAnt = slct.value;

                    removeOptionSelected("rota");
                    slct.appendChild(Builder.node('OPTION', {value:"0"}, "Rota não informada"));
                    var length = (listRota != undefined && listRota.length != undefined ? listRota.length : 1);

                    for(var i = 0; i < length; i++){

                        if(length > 1){
                            rotaY = listRota[i];
                            if(i == 0){
                                valor = listRota[i].id;
                            }
                        }else{
                            rotaY = listRota;
                        }
                        if (rotaY.distancia > 0) {
                            $("quantidadeKm").value = rotaY.distancia;    
                        }
                        if(rotaY != null && rotaY != undefined){
                            slct.appendChild(Builder.node('OPTION', {value: rotaY.id}, rotaY.descricao));
                            if (length > 1){
                                slct.value = rotaIdAnt;
                            }else{
                                slct.value = rotaY.id;
                                getRotaPercurso();
                            }
                            if (slct.value != 0){
                                getTabelaPreco();
                            }    
                        }
                    }
                }
            }//funcao e()
            var cidadesOrigem = $('idcidadeorigem').value;
            var cidadesDestino = $('idcidadedestino').value;
            var isRotaColeta = false;
            var isRotaTransferencia = false;
            var isRotaEntrega = true;
            
            tryRequestToServer(function(){
                new Ajax.Request("ContratoFreteControlador?acao=carregarRotaAjax&cidadesOrigem="+cidadesOrigem+"&cidadesDestino="+cidadesDestino+"&isRotaColeta="+isRotaColeta+"&isRotaEntrega="+isRotaEntrega+"&isRotaTransferencia="+isRotaTransferencia,{method:'post', onSuccess: e, onError: e});
            });
        }

        function getRotaPercurso(){

            function e(transport){
                var textoresposta = transport.responseText;

                //se deu algum erro na requisicao...
                if (textoresposta == "-1"){
                    alert('Houve algum problema ao requistar os percursos, favor tente novamente. ');
                    return false;
                }else{
                    
                    var rota =jQuery.parseJSON(textoresposta).rota;
                    if(rota.dataPrevista != undefined){
//                        if($("dataTermino").value.trim() == ""){                            
                            $("dataTermino").value = rota.dataPrevista;
//                        }
                    }
                    
                    var listPercurso = rota.percursos[0].percurso;
                    var percurso;
                    var slct = $("percurso");

                    var valor = $("percurso").value;
                    var desc = "----------";

                    removeOptionSelected("percurso");
                    if(listPercurso== null || listPercurso== undefined){
                        slct.appendChild(Builder.node('OPTION', {value:valor}, desc));
                    }
                    var length = (listPercurso != undefined && listPercurso.length != undefined ? listPercurso.length : 1);

                    for(var i = 0; i < length; i++){

                        if(length > 1){
                            percurso = listPercurso[i];
                            if(i == 0){
                                valor = listPercurso[i].id;
                            }
                        }else{
                            percurso = listPercurso;
                        }
                        if(percurso != null && percurso != undefined){
                            slct.appendChild(Builder.node('OPTION', {value: percurso.id}, percurso.descricao));
                        }
                    }
                    slct.value = valor;
                }
            }//funcao e()
            tryRequestToServer(function(){
                new Ajax.Request("ContratoFreteControlador?acao=carregarRotaPercursoAjax&rota="+$('rota').value + "&dataPartida=" + $("dataPartida").value,{method:'post', onSuccess: e, onError: e});
            });
        }

        function verSeTemRota(){
            if ($('rota').value == '0' && $('rota').length == 1){
                alert('ATENÇÃO: Para carregar as rotas, clique no botão (atualizar) ao lado.\r\n\r\nOBS: Caso essa mensagem persista, verifique se existe uma rota cadastrada para a origem: ' + $('cid_origem').value + '-' + $('uf_origem').value + ' e o destino: ' + $('cid_destino').value + '-' + $('uf_destino').value + ' .');
            }
        }   
        
        function abrirLocalizaNatureza(){            
            launchPopupLocate('./localiza?acao=consultar&idlista=64&fecharJanela=true','Natureza')
        }

        function calculaValorTonelada(){
            if ($("vlTonelada").readOnly == false){
                $("cartaValorFrete").value = formatoMoeda(parseFloat($("vlTonelada").value) * parseFloat($("pesoTonelada").value));
                calcularFreteCarreteiro();
                validacaoValorTonelada();
            }    
        }

        function validacaoValorTonelada(){
            //Permissao de alteração de valores
            <%if(nvAlFrete != 4){%>
                if (!$("solicitarAutorizacao").checked){
                    desabilitarCampo('cartaValorFrete');
                    $("vlTonelada").readOnly = true;
                    $("vlTonelada").className = "inputReadOnly";
                    desabilitarCampo('valorPorKM');
                }    
                return false;
            <%}%>
            if ($("cartaValorFrete").value > 0 && $("vlTonelada").value == 0 && ($("valorPorKM").value == 0 || $("quantidadeKm").value == 0)){
                $("vlTonelada").className = 'inputReadOnly';
                $("vlTonelada").readOnly = true;
                $("quantidadeKm").readOnly = true;
                $("quantidadeKm").className = 'inputReadOnly';
                desabilitarCampo('valorPorKM');
            }else if($("vlTonelada").value > 0){
                desabilitarCampo('cartaValorFrete');
                desabilitarCampo('valorPorKM');
                $("quantidadeKm").readOnly = true;
                $("quantidadeKm").className = 'inputReadOnly';
                $("vlTonelada").readOnly = false;
                $("vlTonelada").className = "inputTexto";
            } else if($("valorPorKM").value > 0 && $("quantidadeKm").value > 0){
                desabilitarCampo('cartaValorFrete');
                $("vlTonelada").className = 'inputReadOnly';
                $("vlTonelada").readOnly = true;
                habilitarCampo('valorPorKM');
                $("quantidadeKm").readOnly = false;
                $("quantidadeKm").className = 'inputTexto';
            }else if($("valorPorKM").value == 0 || $("quantidadeKm").value == 0){
                desabilitarCampo('cartaValorFrete');
                $("vlTonelada").className = 'inputTexto';
                $("vlTonelada").readOnly = false;
                habilitarCampo('valorPorKM');
                $("quantidadeKm").readOnly = false;
                $("quantidadeKm").className = 'inputTexto';
            }           
            
        }
        
        function bloquearCamposValorContrato(){
            if($('cartaValorFrete').value == 0){
                desabilitarCampo('cartaValorFrete');
                $("vlTonelada").className = 'inputTexto';
                $("vlTonelada").readOnly = false;
                habilitarCampo('valorPorKM');
                $("quantidadeKm").readOnly = false;
                $("quantidadeKm").className = 'inputTexto';                
            }else{
                $("vlTonelada").className = 'inputReadOnly';
                $("vlTonelada").readOnly = true;
                desabilitarCampo('valorPorKM');
                $("quantidadeKm").readOnly = true;
                $("quantidadeKm").className = 'inputReadOnly';                
                
            }
  
        }
        function liberarCamposQuantidade(){
            if($('quantidadeKm').value == 0){
                $("vlTonelada").className = 'inputTexto';
                $("vlTonelada").readOnly = false;
                habilitarCampo('valorPorKM');
                desabilitarCampo('cartaValorFrete');               
            }else if($('quantidadeKm').value > 0 && $('valorPorKM').value > 0){
                $("vlTonelada").className = 'inputReadOnly';
                $("vlTonelada").readOnly = true;
                habilitarCampo('valorPorKM');
                desabilitarCampo('cartaValorFrete');
                $("quantidadeKm").className = 'inputTexto';
                $("quantidadeKm").readOnly = false;
                
            }
            
            <%if(nvAlFrete != 4){%>
                if (!$("solicitarAutorizacao").checked){
                    desabilitarCampo('cartaValorFrete');
                    $("vlTonelada").readOnly = true;
                    $("vlTonelada").className = "inputReadOnly";
                    desabilitarCampo('valorPorKM');
                }    
                return false;
            <%}%>
  
        }
        
        function liberarCamposValorPorKM(){
            
            if($("valorPorKM").value == 0){
                $("vlTonelada").className = 'inputTexto';
                $("vlTonelada").readOnly = false;
                habilitarCampo('valorPorKM');
                desabilitarCampo('cartaValorFrete');
                $("cartaValorFrete").value = "0.00";                
            }else if($("valorPorKM").value > 0 && $("quantidadeKm").value > 0){
                $("vlTonelada").className = 'inputReadOnly';
                $("vlTonelada").readOnly = true;
                habilitarCampo('valorPorKM');
                desabilitarCampo('cartaValorFrete');
                $("quantidadeKm").className = 'inputTexto';
                $("quantidadeKm").readOnly = false;
                
            }
  
        }
        function bloquearCamposValorTonelada(){
            if($("vlTonelada").value != ""){
                if($("vlTonelada").value > 0){
                    desabilitarCampo('cartaValorFrete');
                    desabilitarCampo('valorPorKM');
                    $("quantidadeKm").readOnly = true;
                    $("quantidadeKm").className = 'inputReadOnly';
                }else{
                    habilitarCampo('cartaValorFrete');
                    habilitarCampo('valorPorKM');
                    $("quantidadeKm").readOnly = false;
                    $("quantidadeKm").className = 'inputTexto';
                }
            }else{
                desabilitarCampo('cartaValorFrete');
                habilitarCampo('valorPorKM');
                $("quantidadeKm").readOnly = false;
                $("quantidadeKm").className = 'inputTexto';                                
            }
  
        }
        
        function getTabelaPreco(){
            function e(transport){
                var textoresposta = transport.responseText;
                $('detalhesTabRota').style.display = "none";
                $('tabTipoCalculo').innerHTML = '';
                $('tabTipoVeiculo').innerHTML = '';
                $('tabTipoProduto').innerHTML = 'Produto/Operação:';
                $('tabTipoCliente').innerHTML = 'Cliente:';
                $('tabValorCalculo').innerHTML = '';
                
                //se deu algum erro na requisicao...
                if (textoresposta == "-1"){
                    alert('Houve algum problema ao requistar a tabela de preço, favor tente novamente. ');
                    return false;
                }else{
                    var tabRotaX =jQuery.parseJSON(textoresposta).tabRota;
                    
                    if(tabRotaX.id == '0'){
                        if (parseFloat($('percentual_valor_cte_calculo_cfe').value) === 0) {
                            alert('Tabela de preço não encontrada para a rota escolhida!');
                        }
//                        $('vlFreteMotorista').value = '0.00';
                        $('cartaValorFrete').value = '0.00';
                        $('cartaPedagio').value = '0.00';
                        calcularTabelaMotorista();
                        calcularFreteCarreteiro();
                        return false;
                    }    
                    var tipoCalculoX = 'Não encontrado';
                    var tipoValorX = '';                    

                    if (tabRotaX.tipoValor == 'p'){
                        tipoCalculoX = 'Peso/TON';
                        tipoValorX = colocarVirgula(tabRotaX.valor) + '/TON';
                    }else if (tabRotaX.tipoValor == 'f'){
                        tipoCalculoX = 'Valor Fixo';
                        tipoValorX = colocarVirgula(tabRotaX.valor);
                    }else if (tabRotaX.tipoValor == 'c'){
                        tipoCalculoX = '% CT-e';
                        tipoValorX = colocarVirgula(tabRotaX.valor) + '%';
                    }else if (tabRotaX.tipoValor == 'n'){
                        tipoCalculoX = '% NF-e';
                        tipoValorX = colocarVirgula(tabRotaX.valor) + '%';
                    }else if (tabRotaX.tipoValor == 'k'){
                        tipoCalculoX = 'RS/KM';
                        tipoValorX = colocarVirgula(tabRotaX.valor);
                    }  
                    
                    //Mostrando o labelpar ao usuário
                    if (tabRotaX.distancia > 0) {
                        $("quantidadeKm").value = tabRotaX.distancia;    
                    }
                    $('detalhesTabRota').style.display = "";
                    $('tabTipoCalculo').innerHTML = 'Tipo cálculo:'+tipoCalculoX;
                    $('tabTipoVeiculo').innerHTML = 'Veículo:'+tabRotaX.tipoVeiculo.descricao;
                    if (tabRotaX.tipoProduto.descricao != ''){
                        $('tabTipoProduto').innerHTML = 'Operação:'+tabRotaX.tipoProduto.descricao;
                    }
                    if (tabRotaX.cliente.razaosocial != ''){
                        $('tabTipoCliente').innerHTML = 'Cliente:'+tabRotaX.cliente.razaosocial;
                    }
                    $('tabValorCalculo').innerHTML = 'Valor tabela:'+tipoValorX;
                    //campos para calcular a tabela
                    $('cartaPedagio').value = colocarVirgula(tabRotaX.valorPedagio);
                    $('tab_tipo_valor').value = tabRotaX.tipoValor;
                    $('tab_valor').value = tabRotaX.valor;
                    $('tab_valor_maximo').value = tabRotaX.valorMaximo;
                    $('tab_valor_fixo').value = tabRotaX.valorTaxaFixa;
                    $('tab_valor_entrega').value = tabRotaX.valorEntrega;
                    $('tab_qtd_entrega').value = tabRotaX.quantidadeEntregas;
                    $('tab_valor_excedente').value = tabRotaX.valorPesoExcedente;
                    $('tab_id').value = tabRotaX.id;
                    $('considerarCampoCte').value = tabRotaX.considerarCampoCte;
                    if(tabRotaX.tipoValor == 'k'){
                        
                        $("valorDoKM").value = tipoValorX;
                        $("valorPorKM").value = tipoValorX;
                    }else{
                        $("valorDoKM").value = "0.00";
                        $("valorPorKM").value = "0.00";
                    }
                    $('tabela_is_deduzir_pedagio').value = tabRotaX.deduzirPedagio;
                    $('tabela_is_carregar_pedagio_ctes').value = tabRotaX.carregarPedagio;
                    $('rota_valor_minimo').value = tabRotaX.valorMinimo;
                    $('rota_is_nfe_por_entrega').value = tabRotaX.calcularPercentualNFePorEntrega;
                                        
                    calcularTabelaMotorista();
                    calculaFreteTabela();
                    validacaoValorTonelada();
                    atualizarCampos(tabRotaX.tipoValor);
                    
                }
            }//funcao e()
            
            var idTipoProduto = $('tipoProduto').value;
            
            //Buscar o cliente dos documentos
            var mxDc = indexCtrc.length;
            var idClienteTabela = '0';
            for (i = 1; i <= mxDc; i++) {
                if ($("idCtrc" + i) != null) {
                    idClienteTabela = $("hiddenConsignatario" + i).value;
                }
            }

            if ($('rota').value == '0' && parseFloat($('percentual_valor_cte_calculo_cfe').value) === 0){
                alert('Para calcular o frete a rota deverá ser informada!');
                return false;
            }
            //Buscando o tipo de veiculo
            var idVeiculoTabela = 0;
            if ($('idveiculo').value != '0' && $('idveiculo').value != ''){
                idVeiculoTabela = $('idveiculo').value;
            }    
            if ($('idcarreta').value != '0' && $('idcarreta').value != ''){
                idVeiculoTabela = $('idcarreta').value;
            }
            if (idVeiculoTabela == '0'){
                alert('Para calcular o frete o veículo deverá ser informado!');
                return false;
            }
            
            tryRequestToServer(function(){
                new Ajax.Request("ContratoFreteControlador?acao=carregarTabelaRotaAjax&rotaId="+$('rota').value+"&veiculoId="+idVeiculoTabela+"&clienteId="+idClienteTabela+"&tipoProdutoId="+idTipoProduto,{method:'post', onSuccess: e, onError: e});
            });

        }
        
        function atualizarCampos(tipo){
            if(tipo == "p"){
                desabilitarCampo('cartaValorFrete');
                $('vlTonelada').className = 'inputTexto';
                $('vlTonelada').readOnly = false;
                desabilitarCampo('valorPorKM');
                $("quantidadeKm").className = 'inputReadOnly';
                $("quantidadeKm").readOnly = true;
            }else if(tipo == "f"){
                habilitarCampo('cartaValorFrete');
                $('vlTonelada').className = 'inputReadOnly';
                $('vlTonelada').readOnly = true;
                desabilitarCampo('valorPorKM');
                $("quantidadeKm").className = 'inputReadOnly';
                $("quantidadeKm").readOnly = true;
            }else if(tipo == "c"){
                habilitarCampo('cartaValorFrete');
                $('vlTonelada').className = 'inputReadOnly';
                $('vlTonelada').readOnly = true;
                desabilitarCampo('valorPorKM');
                $("quantidadeKm").className = 'inputReadOnly';
                $("quantidadeKm").readOnly = true;
            }else if(tipo == "n"){
                habilitarCampo('cartaValorFrete');
                $('vlTonelada').className = 'inputReadOnly';
                $('vlTonelada').readOnly = true;
                desabilitarCampo('valorPorKM');
                $("quantidadeKm").className = 'inputReadOnly';
                $("quantidadeKm").readOnly = true;
            }else if(tipo == "k"){
                desabilitarCampo('cartaValorFrete');
                $('vlTonelada').className = 'inputReadOnly';
                $('vlTonelada').readOnly = true;
                habilitarCampo('valorPorKM');
                $("quantidadeKm").className = 'inputTexto';
                $("quantidadeKm").readOnly = false;
                
            }
        }

        function calculaFreteTabela(){
            var tb_vlFrete = 0;
            var tb_tipoValor = $('tab_tipo_valor').value;
            var tb_valor = $('tab_valor').value;
            var tb_peso = $('pesoTonelada').value;
            var tb_valor_frete = $('totalValor').value;
            var tb_valor_nota = $('totalValorNF').value;
            var tb_qtd_entregas = $('totalCts').value;
            var considerarCampoCte = $("considerarCampoCte").value;
            var tbValorFreteCte = $("totalValorFreteCte").value;
            var tbValorPesoCte = $("totalValorPesoCte").value;
            
            $('vlTonelada').value = '0.00';
            // Só irá calcular o valor do frete se o motorista não tiver tabela de preço.
            if (parseFloat($('percentual_valor_cte_calculo_cfe').value) <= 0) {
                if (tb_tipoValor == 'p') {
                    tb_vlFrete = parseFloat(tb_valor) * parseFloat(tb_peso);
                    $('vlTonelada').value = formatoMoeda(tb_valor);
                } else if (tb_tipoValor == 'f') {
                    tb_vlFrete = parseFloat(tb_valor);
                } else if (tb_tipoValor == 'c') {
                    if (considerarCampoCte == 'tp') {//tp = pelo total da prestação
                        tb_vlFrete = parseFloat(tb_valor_frete) * parseFloat(tb_valor) / 100;
                        $('tabTipoCalculo').innerHTML += ", Total da Prestação"
                    } else if (considerarCampoCte == 'fp') { //fp = pelo frete peso
                        tb_vlFrete = parseFloat(tbValorPesoCte) * parseFloat(tb_valor) / 100;
                        $('tabTipoCalculo').innerHTML += ", Frete Peso"
                    } else if (considerarCampoCte == 'fv') {// fv = pelo frete valor                    
                        tb_vlFrete = parseFloat(tbValorFreteCte) * parseFloat(tb_valor) / 100;
                        $('tabTipoCalculo').innerHTML += ", Frete Valor"
                    }
                } else if (tb_tipoValor == 'n') {
                    if ($('rota_is_nfe_por_entrega').value === 'false') {
                        tb_vlFrete = parseFloat(tb_valor_nota) * parseFloat(tb_valor) / 100;
                    } else {
                        var valorDaNota = getValorNotas(parseFloat(tb_valor), parseFloat($('rota_valor_minimo').value));
                        tb_vlFrete = valorDaNota;
                    }                    
                } else if (tb_tipoValor == 'k') {
                    tb_vlFrete = calculaValorKM();
                    if (tb_vlFrete == undefined) {
                        tb_vlFrete = 0;
                    }
                }

                if (tb_vlFrete < parseFloat($('rota_valor_minimo').value)) {
                    tb_vlFrete = parseFloat($('rota_valor_minimo').value);
                    $('tabTipoCalculo').innerHTML += ", Valor Mínimo"
                }

                tb_vlFrete += parseFloat($('tab_valor_fixo').value);
            } else {
                // Pega o valor do frete calculado pela tabela do motorista
                tb_vlFrete = $('cartaValorFrete').value;
            }

            //Verificando o peso excedente
            var pesoSuportado = parseInt($('vei_cap_carga').value) + parseInt($('car_cap_carga').value);
            var pesoFrete = parseInt($("totalPeso").value);
            var pesoTolerancia = '<%=cfg.getPercentualToleranciaPeso()%>';
            pesoSuportado = parseInt(pesoSuportado) + parseInt((parseInt(pesoSuportado) * parseFloat(pesoTolerancia) / 100));
            var pesoExcedente = parseInt(pesoFrete) - parseInt(pesoSuportado);
            if (parseInt(pesoExcedente) > 0){
                tb_vlFrete = parseFloat(tb_vlFrete) + parseFloat((parseFloat($('tab_valor_excedente').value) * parseInt(pesoExcedente)));
            }    
            
            //Verificando a quantidade de entregas
            var qtdEntregasValidas = parseFloat(tb_qtd_entregas) - parseFloat($('tab_qtd_entrega').value) + parseFloat((parseFloat($('tab_qtd_entrega').value) == 0 ? 0 : 1));
            var vlEntrega = parseFloat(parseFloat(qtdEntregasValidas)) * parseFloat($('tab_valor_entrega').value);
            if (parseFloat(vlEntrega) > 0){
                tb_vlFrete = parseFloat(tb_vlFrete) + parseFloat(vlEntrega);
            }
            if ($('tabela_is_deduzir_pedagio').value === 'true') {
                tb_vlFrete -= parseFloat($('cartaPedagio').value);
            }
            if (tb_tipoValor == 'k') {
                $('cartaValorFrete').value = tb_vlFrete;
            }else{
                $('cartaValorFrete').value = formatoMoeda(roundABNT(tb_vlFrete,2));
            }
            calcularFreteCarreteiro();
            validacaoValorTonelada();
        }
        
        function solicitaAutorizacao(){
            
            if ($('solicitarAutorizacao').checked){
                $('lbMotivoAutorizacao').style.display = '';
                $('motivoSolicitacao').style.display = '';
                habilitarCampo('cartaValorFrete');
                $('vlTonelada').className = 'inputTexto';
                $('vlTonelada').readOnly = false;
                habilitarCampo('valorPorKM');
                $("quantidadeKm").readOnly = false;
                $("quantidadeKm").className = 'inputtexto';
            }else{
                $('lbMotivoAutorizacao').style.display = 'none';
                $('motivoSolicitacao').style.display = 'none';
                $("quantidadeKm").readOnly = false;
                $("quantidadeKm").className = 'inputtexto';
            }    
            validacaoValorTonelada();
        }
        
        function calculaValorKM(){
            var retorno = 0;
            var valorPorKm = parseFloat($('valorPorKM').value);
            var qtdPorKm = parseFloat($('quantidadeKm').value);
            
            if(valorPorKm > 0 && parseFloat($('vlTonelada').value) == 0){
                
               retorno = (valorPorKm * qtdPorKm);
               $('cartaValorFrete').value = formatoMoeda(retorno);
               
               validacaoValorKM();
               
               return retorno;
            }
        }
        
        function validacaoValorKM(){
            if($("valorDoKM").value == 0 && $("vlTonelada").value == 0){
                habilitarCampo('valorPorKM');
            }else{
                desabilitarCampo('valorPorKM');
                $("vlTonelada").readOnly = true;
                $("vlTonelada").className = "inputReadOnly";   
            }
            liberarCamposQuantidade();
        }
        
        function marcarTodosCTeColeta(){            
           for (var i = 1; i < idxCtrc; i++){               
                if ($("marcarTodos").checked) {
                     $("ck"+i).checked = true;              
                }else{
                     $("ck"+i).checked = false;                                                
                }
            }
        }
        
        function DocumentoPagamento(idDocPagt, isAutorizacao, tipo, numero, emissao, filial, idFilial, remetente, idRemetente, destinatario, idDestinatario, 
            cidade, idCidade, uf, usuarioAutorizacao, idUsuarioAutorizacao, rota, idRota, valorMotorista, permissaoPagamento){
                
            this.idDocPagt = (idDocPagt == undefined || idDocPagt == null ? 0: idDocPagt);
            this.isAutorizacao = (isAutorizacao == undefined || isAutorizacao == null ? "false": isAutorizacao);
            this.tipo = (tipo == undefined || tipo == null ? "": tipo);
            this.numero = (numero == undefined || numero == null ? "": numero);
            this.emissao = (emissao == undefined || emissao == null ? '<%=Apoio.getDataAtual()%>': emissao);
            this.filial = (filial == undefined || filial == null ? "": filial);
            this.idFilial = (idFilial == undefined || idFilial == null ? 0: idFilial);
            this.remetente = (remetente == undefined || remetente == null ? "": remetente);
            this.idRemetente = (idRemetente == undefined || idRemetente == null ? 0: idRemetente);
            this.destinatario = (destinatario == undefined || destinatario == null ? "": destinatario);
            this.idDestinatario = (idDestinatario == undefined || idDestinatario == null ? 0: idDestinatario);
            this.cidade = (cidade == undefined || cidade == null ? "": cidade);
            this.idCidade = (idCidade == undefined || idCidade == null ? "": idCidade);
            this.uf = (uf == undefined || uf == null ? "": uf);
            this.usuarioAutorizacao = (usuarioAutorizacao == undefined || usuarioAutorizacao == null ? "": usuarioAutorizacao);
            this.idUsuarioAutorizacao = (idUsuarioAutorizacao == undefined || idUsuarioAutorizacao == null ? 0: idUsuarioAutorizacao);
            this.rota = (rota == undefined || rota == null ? "": rota);
            this.idRota = (idRota == undefined || idRota == null ? 0: idRota);
            this.valorMotorista = (valorMotorista == undefined || valorMotorista == null ? 0.00: valorMotorista);
            this.permissaoPagamento = (permissaoPagamento == undefined || permissaoPagamento == null ? 0: permissaoPagamento);
        }
        
        
        var countDocumentoPagamento = 0;
        function addDocumentoPagamento(documentoPagamento){
            
            
            if (documentoPagamento == undefined || documentoPagamento == null) {
                documentoPagamento = new DocumentoPagamento();
            }
            
            countDocumentoPagamento++;
            var celulaZebra = ((countDocumentoPagamento % 2) == 0 ? 'CelulaZebra1' : 'CelulaZebra2');
            
            var _tr = Builder.node("tr",{id:"trDocumentoPagamento_"+countDocumentoPagamento, className:celulaZebra});
            
            var _tdAutorizacao = Builder.node("td",{id:"tdAutorizacao_"+countDocumentoPagamento, name:"tdAutorizacao_"+countDocumentoPagamento});
            var _tdTipo = Builder.node("td",{id:"tdTipo_"+countDocumentoPagamento, name:"tdTipo_"+countDocumentoPagamento});
            var _tdNumeroDocumento = Builder.node("td",{id:"tdNumeroDocumento_"+countDocumentoPagamento, name:"tdNumeroDocumento_"+countDocumentoPagamento});
            var _tdEmissao = Builder.node("td",{id:"tdEmissao_"+countDocumentoPagamento, name:"tdEmissao_"+countDocumentoPagamento});
            var _tdFilial = Builder.node("td",{id:"tdFilial_"+countDocumentoPagamento, name:"tdFilial_"+countDocumentoPagamento});
            var _tdRemDest = Builder.node("td",{id:"tdRemDest_"+countDocumentoPagamento, name:"tdRemDest_"+countDocumentoPagamento});
            var _tdCidadeUf = Builder.node("td",{id:"tdCidadeUf_"+countDocumentoPagamento, name:"tdCidadeUf_"+countDocumentoPagamento});
            var _tdUsuarioAutorizador = Builder.node("td",{id:"tdUsuarioAutorizador_"+countDocumentoPagamento, name:"tdUsuarioAutorizador_"+countDocumentoPagamento});
            var _tdRota = Builder.node("td",{id:"tdRota_"+countDocumentoPagamento, name:"tdRota_"+countDocumentoPagamento});
            var _tdValorMotorista = Builder.node("td",{id:"tdValorMotorista_"+countDocumentoPagamento, name:"tdValorMotorista_"+countDocumentoPagamento});
            var _tdRecalcular = Builder.node("td",{id:"tdRecalcular_"+countDocumentoPagamento, name:"tdRecalcular_"+countDocumentoPagamento});
            
            var _divAutorizacao = Builder.node("div",{id:"divAutorizacao_"+countDocumentoPagamento,name:"divAutorizacao_"+countDocumentoPagamento,align:"center"});
            var _divValorMotorista = Builder.node("div",{id:"divValorMotorista"+countDocumentoPagamento,name:"divValorMotorista"+countDocumentoPagamento,align:"right"});
            var _divRecalcular = Builder.node("div",{id:"divRecalcular_"+countDocumentoPagamento,name:"divRecalcular_"+countDocumentoPagamento,align:"center"});
            
            var lblAutorizacaoSim = Builder.node("label",{
                id:"lblAutorizacaoSim_"+countDocumentoPagamento,
                name:"lblAutorizacaoSim_"+countDocumentoPagamento
            });
            
            lblAutorizacaoSim.innerHTML = "&nbsp;Sim&nbsp;";
            
            var lblAutorizacaoNao = Builder.node("label",{
                id:"lblAutorizacaoNao_"+countDocumentoPagamento,
                name:"lblAutorizacaoNao_"+countDocumentoPagamento
            });
            
            lblAutorizacaoNao.innerHTML = "&nbsp;Não&nbsp;";
            
            var _inpCheckAutorizacaoSim = Builder.node("input",{
                id:"inpChkAutorizacaoSim_"+countDocumentoPagamento,
                name:"inpChkAutorizacao_"+countDocumentoPagamento,
                type:"radio",
                value:"s",
                onchange:"custoEntregaColeta()"
//                value:documentoPagamento.isAutorizacao
            });
            
            var _inpCheckAutorizacaoNao = Builder.node("input",{
                id:"inpChkAutorizacaoNao_"+countDocumentoPagamento,
                name:"inpChkAutorizacao_"+countDocumentoPagamento,
                type:"radio",
                value:"n",
                onchange:"custoEntregaColeta()"
//                value:documentoPagamento.isAutorizacao
            });
            //Quando o id do usuario que autorizou for 0, considero o primeiro acesso, onde ainda não foi salvo as informações de pagamento,
            //então faço o critério pela permissão e configuração.
            if(documentoPagamento.idUsuarioAutorizacao == 0){
                if (documentoPagamento.permissaoPagamento == 4 && documentoPagamento.isAutorizacao == "true") {
                    _inpCheckAutorizacaoSim.checked = true;                
                }else if(documentoPagamento.permissaoPagamento == 4 && documentoPagamento.isAutorizacao == "false"){
                    _inpCheckAutorizacaoNao.checked = true;                
                }else if(documentoPagamento.permissaoPagamento == 0){
                    _inpCheckAutorizacaoNao.checked = true;                
                    _inpCheckAutorizacaoNao.disabled = true;                
                    _inpCheckAutorizacaoSim.disabled = true;                
                }                
            }else{//Caso o id do usuario for maior que 0, então já foi salvo as informações de pagamento, então vou pegar da tabela romaneio_ctrc.
                if(documentoPagamento.isAutorizacao == "true"){
                    _inpCheckAutorizacaoSim.checked = true;
                }else if(documentoPagamento.isAutorizacao == "false"){
                    _inpCheckAutorizacaoNao.checked = true;
                }
                //Caso a permissão for retirada do usuario, fica bloqueado, mas com as informações da ultima vez que foi alterado.
                if(documentoPagamento.permissaoPagamento == 0){
                    _inpCheckAutorizacaoNao.disabled = true;
                    _inpCheckAutorizacaoSim.disabled = true;
                }
            }
            
            var _inpHidDocPagt = Builder.node("input",{
                id:"inpHidDocPagt_"+countDocumentoPagamento,
                name:"inpHidDocPagt_"+countDocumentoPagamento,
                type:"hidden",
                value:documentoPagamento.idDocPagt
            });            
            
            var _inpHidTipo = Builder.node("input",{
                id:"inpHidTipo_"+countDocumentoPagamento,
                name:"inpHidTipo_"+countDocumentoPagamento,
                type:"hidden",
                value:documentoPagamento.tipo
            });            
            
            var _inpHidNumeroDocumento = Builder.node("input",{
                id:"inpHidNumeroDocumento_"+countDocumentoPagamento,
                name:"inpHidNumeroDocumento_"+countDocumentoPagamento,
                type:"hidden",
                value:documentoPagamento.numero
            });
            
            var _inpHidEmissao = Builder.node("input",{
                id:"inpHidEmissao_"+countDocumentoPagamento,
                name:"inpHidEmissao_"+countDocumentoPagamento,
                type:"hidden",
                value:documentoPagamento.emissao
            });            
            
            var _inpHidFilial = Builder.node("input",{
                id:"inpHidIdFilial_"+countDocumentoPagamento,
                name:"inpHidIdFilial_"+countDocumentoPagamento,
                type:"hidden",
                value:documentoPagamento.idFilial
            });            
            
            var _inpHidRem = Builder.node("input",{
                id:"inpHidIdRem_"+countDocumentoPagamento,
                name:"inpHidIdRem_"+countDocumentoPagamento,
                type:"hidden",
                value:documentoPagamento.idRemetente
            });            
            
            var _inpHidDest = Builder.node("input",{
                id:"inpHidIdDest_"+countDocumentoPagamento,
                name:"inpHidIdDest_"+countDocumentoPagamento,
                type:"hidden",
                value:documentoPagamento.idDestinatario
            });            
            
            var _inpHidCidade = Builder.node("input",{
                id:"inpHidIdCidade_"+countDocumentoPagamento,
                name:"inpHidIdCidade_"+countDocumentoPagamento,
                type:"hidden",
                value:documentoPagamento.idCidade
            });       
            
            var _inpHidUsuarioAutorizador = Builder.node("input",{
                id:"inpHidIdUsuarioAutorizador_"+countDocumentoPagamento,
                name:"inpHidIdUsuarioAutorizador_"+countDocumentoPagamento,
                type:"hidden",
                value:documentoPagamento.idUsuarioAutorizacao
            });            
            
            var _inpHidRota = Builder.node("input",{
                id:"inpHidIdRota_"+countDocumentoPagamento,
                name:"inpHidIdRota_"+countDocumentoPagamento,
                type:"hidden",
                value:documentoPagamento.idRota
            });            
            
            var _inpHidValorMotorista = Builder.node("input",{
                id:"inpHidValorMotorista_"+countDocumentoPagamento,
                name:"inpHidValorMotorista_"+countDocumentoPagamento,
                type:"hidden",
                value:colocarVirgula(documentoPagamento.valorMotorista)
            });
            
            var _inpBtnRecalcular = Builder.node("img",{
                id:"inpBtnRecalcular_"+countDocumentoPagamento,
                name:"inpBtnRecalcular_"+countDocumentoPagamento,
                className:"imagemLink",
                src:"img/atualiza.png",
                title:"Recalcular o valor do Motorista",
                onclick:"javascript:tryRequestToServer(function(){recalcularValorMotorista("+countDocumentoPagamento+");});"
            });
            
            var _lblTipo = Builder.node("label",{id:"lblTipo_"+countDocumentoPagamento,name:"lblTipo_"+countDocumentoPagamento});
            _lblTipo.innerHTML = documentoPagamento.tipo;
            
            var _lblNumeroDocumento = Builder.node("label",{id:"lblNumeroDocumento_"+countDocumentoPagamento,name:"lblNumeroDocumento_"+countDocumentoPagamento});
            _lblNumeroDocumento.innerHTML = documentoPagamento.numero;
            
            var _lblEmissao = Builder.node("label",{id:"lblEmissao_"+countDocumentoPagamento,name:"lblEmissao_"+countDocumentoPagamento});
            _lblEmissao.innerHTML = documentoPagamento.emissao;
            
            var _lblFilial = Builder.node("label",{id:"lblFilial_"+countDocumentoPagamento,name:"lblFilial_"+countDocumentoPagamento});
            _lblFilial.innerHTML = documentoPagamento.filial;
            
            var _lblRemDest = Builder.node("label",{id:"lblRemDest_"+countDocumentoPagamento,name:"lblRemDest_"+countDocumentoPagamento});
            _lblRemDest.innerHTML = documentoPagamento.remetente + " / " + documentoPagamento.destinatario;
            
            var _lblCidadeUf = Builder.node("label",{id:"lblCidadeUf_"+countDocumentoPagamento,name:"lblCidadeUf_"+countDocumentoPagamento});
            _lblCidadeUf.innerHTML = documentoPagamento.cidade + " / " + documentoPagamento.uf;
            
            var _lblUsuarioAutorizador = Builder.node("label",{id:"lblUsuarioAutorizador_"+countDocumentoPagamento,name:"lblUsuarioAutorizador_"+countDocumentoPagamento});
            _lblUsuarioAutorizador.innerHTML = documentoPagamento.usuarioAutorizacao;
            
            var _lblRota = Builder.node("label",{id:"lblRota_"+countDocumentoPagamento,name:"lblRota_"+countDocumentoPagamento});
            _lblRota.innerHTML = documentoPagamento.rota;
            
            var _lblValorMotorista = Builder.node("label",{id:"lblValorMotorista_"+countDocumentoPagamento,name:"lblValorMotorista_"+countDocumentoPagamento});
            _lblValorMotorista.innerHTML = colocarVirgula(documentoPagamento.valorMotorista);
            
            //**********************TD*************************//
            _divAutorizacao.appendChild(_inpCheckAutorizacaoSim);
            _divAutorizacao.appendChild(lblAutorizacaoSim);
            _divAutorizacao.appendChild(_inpCheckAutorizacaoNao);
            _divAutorizacao.appendChild(lblAutorizacaoNao);
            _divAutorizacao.appendChild(_inpHidDocPagt);
            _tdAutorizacao.appendChild(_divAutorizacao);
            _tdTipo.appendChild(_lblTipo);
            _tdTipo.appendChild(_inpHidTipo);
            _tdNumeroDocumento.appendChild(_lblNumeroDocumento);
            _tdNumeroDocumento.appendChild(_inpHidNumeroDocumento);
            _tdEmissao.appendChild(_lblEmissao);
            _tdEmissao.appendChild(_inpHidEmissao);
            _tdFilial.appendChild(_lblFilial);
            _tdFilial.appendChild(_inpHidFilial);
            _tdRemDest.appendChild(_lblRemDest);
            _tdRemDest.appendChild(_inpHidRem);
            _tdRemDest.appendChild(_inpHidDest);
            _tdCidadeUf.appendChild(_lblCidadeUf);
            _tdCidadeUf.appendChild(_inpHidCidade);
            _tdUsuarioAutorizador.appendChild(_lblUsuarioAutorizador);
            _tdUsuarioAutorizador.appendChild(_inpHidUsuarioAutorizador);
            _tdRota.appendChild(_lblRota);
            _tdRota.appendChild(_inpHidRota);
            _divValorMotorista.appendChild(_lblValorMotorista)
            _divValorMotorista.appendChild(_inpHidValorMotorista)
            _tdValorMotorista.appendChild(_divValorMotorista);
            if (documentoPagamento.idRota > 0) {
                _divRecalcular.appendChild(_inpBtnRecalcular);    
            }
            _tdRecalcular.appendChild(_divRecalcular);
            //**********************TD*************************//
            
            //************TR*****************//
            _tr.appendChild(_tdAutorizacao);
            _tr.appendChild(_tdTipo);
            _tr.appendChild(_tdNumeroDocumento);
            _tr.appendChild(_tdEmissao);
            _tr.appendChild(_tdFilial);
            _tr.appendChild(_tdRemDest);
            _tr.appendChild(_tdCidadeUf);
            _tr.appendChild(_tdUsuarioAutorizador);
            _tr.appendChild(_tdRota);
            _tr.appendChild(_tdValorMotorista);
            _tr.appendChild(_tdRecalcular);
            //************TR*****************//
            
            $("maxDocPagt").value = countDocumentoPagamento;
            $("tbDocumentoPagamento").appendChild(_tr);
            
        }
        
        function custoEntregaColeta(){
            var maxDocPagt = $("maxDocPagt").value;
            var valorDiaria = 0;
            for (var qtdDocPagt = 1; qtdDocPagt <= maxDocPagt; qtdDocPagt++) {                
                if($("inpChkAutorizacaoSim_"+qtdDocPagt).checked){
                    valorDiaria = valorDiaria + parseFloat(colocarPonto($("inpHidValorMotorista_"+qtdDocPagt).value));                  
                }                
                $("diaria").value = colocarVirgula(valorDiaria);                    
            }
        }
        
        function recalcularValorMotorista(index){
            
            espereEnviar("Aguarde...",true);
            
            var idRota = $("inpHidIdRota_"+index).value;
            var idCliente = $("inpHidIdRem_"+index).value;            
            var idVeiculo = $("idveiculo").value;
            var idCarreta = $("idcarreta").value;
            var idDocumento = $("inpHidDocPagt_"+index).value;
            var tipo = $("inpHidTipo_"+index).value;
            var peso = $("hiddenPeso"+index).value;
            var valorNota = $("hiddenValorNF"+index).value;
            var valorCTe = $("hiddenValor"+index).value;
            var descricaoRota = $("lblRota_"+index).innerHTML;
            var valorFreteCte = $("hiddenValorFreteCte_"+index).value;
            var valorPesoCte = $("hiddenValorPesoCte_"+index).value;
            
            function e(transport){
                var textoresposta = transport.responseText;
                var valorMotorista = jQuery.parseJSON(textoresposta).double;
                
                if(valorMotorista > 0){
                    $("lblValorMotorista_"+index).innerHTML = colocarVirgula(valorMotorista);
                    $("inpHidValorMotorista_"+index).value = colocarVirgula(valorMotorista);
                }else{
                    alert("Atenção: Rota '" + descricaoRota + "' não possui tabela de preço!");
                }
                espereEnviar("Aguarde...",false);
            }
        
            new Ajax.Request("./cadromaneio?acao=recalcularValorMotorista&idRota="+idRota+"&idCliente="+idCliente+"&idVeiculo="+idVeiculo+"&idCarreta="+idCarreta+"&idDocumento="+idDocumento
                    +"&tipo="+tipo+"&peso="+peso+"&valorNota="+valorNota+"&valorCTe="+valorCTe+"&valorFreteCte="+valorFreteCte+"&valorPesoCte="+valorPesoCte,
            {
                method:'post', 
                onSuccess: e, 
                onError: e
            });
        }
        
        function atualizarQtdCteColeta(){
            var maxDocPagt = $("maxDocPagt").value;
            
            if (maxDocPagt > 0) {
                $("lbTotalColetaDocPagt").innerHTML = $("totalColeta").value;
                $("lbTotalCtsDocPagt").innerHTML = $("totalCts").value;    
            } 
        }
        
        function pesquisarAuditoria() {
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
                var rotina = "romaneio";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = <%=(carregarom ? cadrom.getRomaneio().getIdRomaneio() : 0)%>;
                consultarLog(rotina, id, dataDe, dataAte);
            }
            
        function setDataAuditoria(){
              $("dataDeAuditoria").value = '<%= Apoio.getDataAtual() %>';
              $("dataAteAuditoria").value = '<%= Apoio.getDataAtual() %>';
          }  
        
        function calculaTotalTarifas(){
            
            $("totalSaques").value = colocarVirgula(parseFloat($("qtdSaques").value) * parseFloat($("valorPorSaques").value));

            $("totalTransf").value = colocarVirgula(parseFloat($("qtdTransf").value) * parseFloat($("valorTransf").value));
            
            if($("st_utilizacao_cfe").value == 'P'){
                $("vlTarifas").value = colocarVirgula(parseFloat($("totalSaques").value) + parseFloat($("totalTransf").value));
                $("vlTarifas").readonly = 'true';
                $("cartaValorTarifa").value = $("vlTarifas").value;
            }
          
        }
        
        function atribuiValores(){
           var max = <%= rom.getCtrcs().length %>;
            for (var i = 1; i <= max; i++) {
               $("dtEntrega"+i).value = $("dtVariasOco").value;
               $("hrEntrega"+i).value = $("horaVariasOco").value;
               $("obs"+i).value = $("observacaoOco").value;
                if ($("isCompEntrega"+i) != null) {
                   $("isCompEntrega"+i).checked = $("chkTodasCompEntrega").checked;
                }
            }
        }

        function validarBloqueioVeiculo(tipo){
            var bloqueado = false;
                if($("is_bloqueado").value == "t" && tipo == "veiculo"){
                    setTimeout(function(){
                            alert("O veículo " + $("vei_placa").value + " está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
                            $("idveiculo").value = "0";
                            $("vei_placa").value = "";
                            bloqueado = true;
                    },100);
                }
                if($("is_bloqueado").value == "t" && tipo == "carreta"){
                    setTimeout(function(){
                            alert("A carreta " + $("car_placa").value + " está bloqueada e não poderá ser utilizada no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
                            $("idcarreta").value = "0";
                            $("car_placa").value = "";
                            bloqueado = true;
                    },100);
                }
                return bloqueado;
        }

        function validarBloqueioVeiculoMotorista(filtros){
            if($("is_moto_veiculo_bloq").value == "t" && filtros == "veiculo_motorista"){
                setTimeout(function (){
                       alert("O veiculo " + $("vei_placa").value + ", vinculado ao motorista " +$("motor_nome").value+ ", está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("moto_veiculo_bloq_motivo").value);
                        $("idveiculo").value = "0";
                        $("vei_placa").value = "";
                },100);
            }else if($("is_moto_carreta_bloq").value == "t" && filtros == "carreta_motorista"){
                    setTimeout(function (){
                        alert("A carreta " + $("car_placa").value + ", vinculada ao motorista " +$("motor_nome").value+ ", está bloqueada e não poderá ser utilizada no lançamento. \r\n Motivo: " + $("moto_carreta_bloq_motivo").value);
                        $("idcarreta").value = "0";
                        $("car_placa").value = "";
                    },100);
            }        
        }

    function calcularTabelaMotorista() { 
        var percentualValor = parseFloat($('percentual_valor_cte_calculo_cfe').value);

        if (percentualValor !== 0) {
            $('detalhesTabRota').style.display = "";
            $('tabTipoCalculo').innerHTML = 'Tipo cálculo: tabela de motorista';

            var vlFrete = 0;

            var tbValorFrete = parseFloat($('totalValor').value); // Pelo total da prestação
            var tbValorPesoCte = parseFloat($("totalValorPesoCte").value); // Pelo frete peso
            var tbValorFreteCte = parseFloat($("totalValorFreteCte").value); // Pelo frete valor
            var tdValorNotaFiscal = parseFloat($("totalValorNF").value); // pela nota fiscal

            var tipoCalculoPercentualValorCFe = $('tipo_calculo_percentual_valor_cfe').value;
            
            if ($('calculo_valor_contrato_frete').value === 'ct') {

                if (tipoCalculoPercentualValorCFe === 'tp') {
                    // tp = pelo total da prestação
                    vlFrete = tbValorFrete * (percentualValor / 100);

                    $('tabValorCalculo').innerHTML = 'Valor tabela: ' + percentualValor + '% sobre o total da prestação.';
                } else if (tipoCalculoPercentualValorCFe === 'fp') {
                    // fp = pelo frete peso
                    vlFrete = tbValorPesoCte * (percentualValor / 100);

                    $('tabValorCalculo').innerHTML = 'Valor tabela: ' + percentualValor + '% sobre o frete peso.';
                } else if (tipoCalculoPercentualValorCFe === 'fv') {
                    // fv = pelo frete valor
                    vlFrete = tbValorFreteCte * (percentualValor / 100);

                    $('tabValorCalculo').innerHTML = 'Valor tabela: ' + percentualValor + '% sobre o frete valor.';
                }
            } else if ($('calculo_valor_contrato_frete').value === 'nf') {                
                if ($('rota_is_nfe_por_entrega').value === 'false') {
                    vlFrete = tdValorNotaFiscal * (percentualValor / 100);
                    $('tabValorCalculo').innerHTML = 'Valor tabela: ' + percentualValor + '% sobre o da Mercadoria.';
                } else {
                    var valorDaNota = getValorNotas(percentualValor, parseFloat($('motorista_valor_minimo').value));
                    vlFrete = valorDaNota;
                    $('tabValorCalculo').innerHTML = 'Valor tabela: ' + percentualValor + '% NF-e por Entrega.';   
                }
            }
            vlFrete += parseFloat($('tab_valor_fixo').value);

            if (vlFrete < parseFloat($('motorista_valor_minimo').value)) {
                vlFrete = parseFloat($('motorista_valor_minimo').value);
                $('tabValorCalculo').innerHTML = 'Valor mínimo: R$ ' + parseFloat($('motorista_valor_minimo').value).toFixed(2) + '.';
            }

            $('cartaValorFrete').value = roundABNT(vlFrete,2);
        }
    }

    function calcularRetencoes() {
        var vlDeducoes = 0;

        var elementoValorOutrasRetencoes = $('cartaRetencoes');
        var elementoPercentualRetencao = $('percentualRetencao');
        var elementoValorLiquido = $('cartaValorFrete');

        var valorRetencao = parseFloat(elementoValorOutrasRetencoes.value);
        var valorPercentualRetencao = parseFloat(elementoPercentualRetencao.value);
        var valorLiquido = 0;

        if (elementoValorLiquido.value.indexOf(',') !== -1) {
            // Tela de importação CTRC em Lote, o campo é formatado como reais (pontos e vírgulas).
            valorLiquido = parseFloat(colocarPonto(elementoValorLiquido.value));
        } else {
            // Tela de CTRC normal, o campo só é formatado com pontos para decimais.
            valorLiquido = parseFloat(elementoValorLiquido.value);
        }

        if (valorPercentualRetencao < 0) {
            elementoPercentualRetencao.value = '0';
            vlDeducoes = 0;
            notReadOnly(elementoValorOutrasRetencoes);
            alert('O percentual não pode ser menor que 0%!');
        } else if (valorPercentualRetencao > 100) {
            elementoPercentualRetencao.value = '0';
            vlDeducoes = 0;
            notReadOnly(elementoValorOutrasRetencoes);
            alert('O percentual não pode ser maior que 100%!');
        } else {
            if (valorRetencao === 0 && valorPercentualRetencao === 0) {
                notReadOnly(elementoValorOutrasRetencoes,);
                notReadOnly(elementoPercentualRetencao);
            } else if (valorPercentualRetencao !== 0 && valorRetencao === 0 && !elementoValorOutrasRetencoes.readOnly) {
                readOnly(elementoValorOutrasRetencoes);
            } else if (valorPercentualRetencao === 0 && valorRetencao !== 0 && elementoValorOutrasRetencoes.readOnly) {
                notReadOnly(elementoValorOutrasRetencoes);
            } else if (valorRetencao !== 0 && valorPercentualRetencao === 0 && !elementoPercentualRetencao.readOnly) {
                readOnly(elementoPercentualRetencao);
            } else if (valorRetencao === 0 && valorPercentualRetencao !== 0 && elementoPercentualRetencao.readOnly) {
                notReadOnly(elementoPercentualRetencao);
            }

            // Calcular
            if (valorPercentualRetencao !== 0 && elementoValorOutrasRetencoes.readOnly) {
                vlDeducoes = (valorLiquido * valorPercentualRetencao) / 100;
                vlDeducoes += (valorLiquido * parseFloat($("mot_outros_descontos_carta").value)) / 100;
            } else if (elementoPercentualRetencao.readOnly) {
                vlDeducoes = valorRetencao;
            }

            elementoValorOutrasRetencoes.value = colocarVirgula(vlDeducoes, null);
        }
    }

    function carregarAbastecimentos() {
        jQuery.post('${homePath}/ContratoFreteControlador', {
                'acao': 'carregarAbastecimentos',
                'idveiculo': jQuery("#idveiculo").val()
            }, function (data) {
                var obj = JSON.parse(data);
                jQuery('#abastecimentos').val(parseFloat(obj['total_abastecimento']).toFixed(2));
                jQuery('#lbAbastecimento').text(obj['abastecimentos'].join(', '));
                jQuery('#ids_abastecimentos').val(obj['abastecimentos_ids'].join(','));
            }
        );
    }
    
    function jsonTaxas() {
        
        var valorInputTaxas = $("json_taxas").value;
        var taxa = 0;
        if (valorInputTaxas) {
            var tabela = JSON.parse(valorInputTaxas);
            if (tabela) {
                for (i in tabela) {
                    if (tabela[i].tipo_veiculo == $("tipo_veiculo_motorista").value) {
                        taxa = parseFloat(tabela[i].valor);
                    }
                }
            }
        }        
        return taxa;
    }
    
    function isRetencaoImpostoOperadoraCFe(){
        var isRetencaoImpostoOperadoraCFe = ($("is_retencao_impostos_operadora_cfe").value === "true" || $("is_retencao_impostos_operadora_cfe").value === "t");
        return (isRetencaoImpostoOperadoraCFe);
    }
    
    function validarTipoVeiculo(tipo) {
        var tipoVeiculoMotorista = $("tipo_veiculo_motorista");
        var tipoVeiculoVeiculo = $("tipo_veiculo_veiculo");
        var tipoVeiculoCarreta = $("tipo_veiculo_carreta");

        if(tipo =='c'){
            if((tipoVeiculoMotorista.value == '0' || tipoVeiculoMotorista.value == tipoVeiculoCarreta.value) || (tipoVeiculoMotorista.value != '0' && tipoVeiculoMotorista.value != tipoVeiculoCarreta.value)){
                tipoVeiculoMotorista.value = tipoVeiculoVeiculo.value;
            }
            tipoVeiculoCarreta.value = '0';
        }else{
            if((tipoVeiculoMotorista.value == '0' || tipoVeiculoMotorista.value == tipoVeiculoVeiculo.value ) && tipoVeiculoCarreta.value != '0'){
                tipoVeiculoMotorista.value = tipoVeiculoCarreta.value;
            }else if((tipoVeiculoMotorista.value == '0' || tipoVeiculoMotorista.value == tipoVeiculoVeiculo.value ) && tipoVeiculoCarreta.value == '0'){
                tipoVeiculoMotorista.value = '0';
            }
            tipoVeiculoVeiculo.value = '0';
        }
    }
    
    function getValorNotas(percentualValor, valorMinimo) {
        
        var idsColeta = "";
        var idsRomaneio = "";
        var idsManifesto = "";
        var idsCTRC = "";
        
        var notas = "";

        for (var i = 1; i < idxCtrc; i++) {
            if ($("tipoCtrc"+i).value === 'MANIFESTO') {
                if (idsManifesto === "") {
                    idsManifesto = $("idCtrc"+i).value;
                } else {
                    idsManifesto += "," + $("idCtrc"+i).value;
                }
            } else if ($("tipoCtrc"+i).value === 'COLETA') {
                if (idsColeta === "") {
                    idsColeta = $("idCtrc"+i).value;
                } else {
                    idsColeta += "," + $("idCtrc"+i).value;
                }
            } else if ($("tipoCtrc"+i).value === 'CTRC') {
                if (idsCTRC === "") {
                    idsCTRC = $("idCtrc"+i).value;
                } else {
                    idsCTRC += "," + $("idCtrc"+i).value;
                }
            }
            
        }
            
        var valorDaNota = 0;

        jQuery.ajax({
            url: 'ContratoFreteControlador',
            type: 'POST',
            async: false,
            data: {
                'acao': 'carregarValorNotas',
                'idsManifesto': idsManifesto,
                'idsColeta': idsColeta,
                'idsRomaneio': idsRomaneio,
                'idsCTRC': idsCTRC
            },
            success: function (data, textStatus, jqXHR) {
                if (data) {
                    data = JSON.parse(data);
                    
                    var valorNota;
                    
                        jQuery.each(data, function (index, nota) {
                                valorNota = nota.valor * (percentualValor / 100);

                                if (valorNota < parseFloat(valorMinimo)) {
                                    valorNota = parseFloat(valorMinimo);
                                }

                                valorDaNota += parseFloat(valorNota);
                    });
                }
            }
        });
        return valorDaNota;
}

    function habilitarCampo(campo) {
        $(campo).removeClassName("inputReadOnly");
        $(campo).addClassName("inputTexto");
        $(campo).readOnly = false;
    }

    function desabilitarCampo(campo) {
        $(campo).removeClassName("inputTexto");
        $(campo).addClassName("inputReadOnly");
        $(campo).readOnly = true;
    }
</script>
<%@page import="conhecimento.ocorrencia.Ocorrencia"%>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="br.com.gwsistemas.roteirizacao.TipoSincronizacaoRoteirizacao" %>
<%@ page import="org.apache.commons.lang3.StringUtils" %>
<%@ page import="br.com.gwsistemas.movimentacao.iscas.MovimentacaoIscas" %>
<%@ page import="java.util.*" %>
<html>
    <head>       
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">

        <title>Lan. Romaneio - Webtrans</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style1 {font-size: 10px}
            .styleRed {
                color: #990000
            }
            -->
        </style>
    </head>

    <body onLoad="aoCarregar();applyFormatter();AlternarAbasGenerico('tbDadosCtsColeta','tab1');setDataAuditoria();
                  applyChangeHandler();">

        <!-- Campos ocultos -->
        <input type="hidden" name="bloqueado" id="bloqueado" value="">
        <input type="hidden" name="motivobloqueio" id="motivobloqueio" value="">
        <!-- Adicionar cts / coleta -->
        <input type="hidden" id="ctrc_resolvido" value="">

        <!-- Dados do ajudante -->
        <input type="hidden" id="idajudante" value="">
        <input type="hidden" id="nome" value="">
        <input type="hidden" id="fone1" value="">
        <input type="hidden" id="fone2" value="">
        <input type="hidden" id="vldiaria" value="">
        <!-- Dados do CTRC -->
        <input type="hidden" id="idmovimento" value="">
        <input type="hidden" id="nfiscal" value="">
        <input type="hidden" id="dtemissao" value="">
        <input type="hidden" id="filial" value="">
        <input type="hidden" id="is_retencao_impostos_operadora_cfe" value="">
        <input type="hidden" id="remetente" value="">
        <input type="hidden" id="destinatario" value="">
        <input type="hidden" id="totalprestacao" value="">
        <input type="hidden" id="consignatario_id" value="">
        <input type="hidden" id="valor_nf" value="0">
        <input type="hidden" id="valor_frete" value="0">
        <input type="hidden" id="valor_peso" value="0">
        <input type="hidden" id="tipo" value="">
        <input type="hidden" id="peso" value="">
        <input type="hidden" id="is_bloqueado" value="f">
        <input type="hidden" id="volume" value="">
        <input type="hidden" id="cubagem" value="">
        <input type="hidden" id="dtchegada" value="0">
        
        <!-- id do motorista -->
        <input type="hidden" id="idmotorista" value="<%=(carregarom ? String.valueOf(rom.getMotorista().getIdmotorista()) : "0")%>">
        <!-- id dos veículos -->
        <input type="hidden" id="idveiculo" value="<%=(carregarom ? String.valueOf(rom.getCavalo().getIdveiculo()) : "0")%>">
        <input type="hidden" id="idcarreta" value="<%=(carregarom ? String.valueOf(rom.getCarreta().getIdveiculo()) : "0")%>">
        <!-- Filial do lancamento -->
        <input type="hidden" id="idfilial" value="<%=(carregarom ? rom.getFilial().getIdfilial() : (nivelUser > 0 ? Apoio.getUsuario(request).getFilial().getIdfilial() : 0))%>">
        <input type="hidden" id="ocorrencia" name="ocorrencia" value="">
        <input type="hidden" id="ocorrencia_id" name="ocorrencia_id" value="">
        <input type="hidden" id="ocorrencia_idx" name="ocorrencia_idx" value="">
        <input type="hidden" id="obs_desc" name="obs_desc" value="">
        <!-- Cidade destino do localiza ctrcs romaneio -->
        <input type="hidden" id="cidade_destino" name="cidade_destino" value="">
        <input type="hidden" id="cidade_destino_id" name="cidade_destino_id" value="">
        <input name="capacidade_cubagem" type="hidden" id="capacidade_cubagem" value="<%=(carregarom ? String.valueOf(rom.getCavalo().getCubagemVeiculo()) : "0.0000")%>"></td>
        <input name="capacidade_cubagem2" type="hidden" id="capacidade_cubagem2" value="<%=(carregarom ? String.valueOf(rom.getCarreta().getCubagemVeiculo()) : "0.0000")%>"></td>
        <input type="hidden" id="is_tac" name="is_tac" value="f">
        <input type="hidden" id="obriga_resolucao" name="obriga_resolucao" value="">
        <input type="hidden" name="miliSegundos"  id="miliSegundos" value="0">
        <input type="hidden" name="codigo_ibge_origem" id="codigo_ibge_origem" value="<%=(carregarom ? rom.getCidadeOrigem().getCod_ibge() : Apoio.getUsuario(request).getFilial().getCidade().getCod_ibge())%>">
        <input type="hidden" name="codigo_ibge_destino" id="codigo_ibge_destino" value="<%=(carregarom ? rom.getCidadeDestino().getCod_ibge() : Apoio.getUsuario(request).getFilial().getCidade().getCod_ibge())%>">
        <input type="hidden" name="valorDoKM" id="valorDoKM" value="0"/>
        <input name="considerarCampoCte" id="considerarCampoCte" type="hidden" value="false" />
        <input name="controlarTarifasBancariasContratado" id="controlarTarifasBancariasContratado" type="hidden" value="false" />
        <input type="hidden" name="motivo_bloqueio" id="motivo_bloqueio">    
        <input type="hidden" name="is_bloqueado" id="is_bloqueado">    
        <input type="hidden" name="moto_veiculo_bloq_motivo" id="moto_veiculo_bloq_motivo">    
        <input type="hidden" name="is_moto_veiculo_bloq" id="is_moto_veiculo_bloq">    
        <input type="hidden" name="moto_carreta_bloq_motivo" id="moto_carreta_bloq_motivo">    
        <input type="hidden" name="is_moto_carreta_bloq" id="is_moto_carreta_bloq"> 
        <input type="hidden" name="moto_bitrem_bloq_motivo" id="moto_bitrem_bloq_motivo">    
        <input type="hidden" name="is_moto_bitrem_bloq" id="is_moto_bitrem_bloq">
        <input type="hidden" name="idromaneio" id="idromaneio" value="">
        <input type="hidden" name="baixa_em" id="baixa_em" value="">
        <input type="hidden" name="tipo_ctrc" id="tipo_ctrc" value="">
        <input type="hidden" name="data_chegada_ctrc" id="data_chegada_ctrc">
        <input type="hidden" id="json_taxas" readonly="true">
        <input type="hidden" id="tipo_veiculo_id" name="tipo_veiculo_id" readonly="true">
        <input type="hidden" id="calculo_valor_contrato_frete" name="calculo_valor_contrato_frete" readonly="true">
        <input name="tipo_veiculo_motorista" type="hidden" id="tipo_veiculo_motorista" class="inputReadOnly8pt" value="0" size="9" readonly="true">
        <input name="tipo_veiculo_veiculo" type="hidden" id="tipo_veiculo_veiculo" class="inputReadOnly8pt" value="0" size="9" readonly="true">
        <input name="tipo_veiculo_carreta" type="hidden" id="tipo_veiculo_carreta" class="inputReadOnly8pt" value="0" size="9" readonly="true">
        <input name="rota_is_nfe_por_entrega" type="hidden" id="rota_is_nfe_por_entrega" value="0.00">
        <!-- Fim -->

        <img src="img/banner.gif" >
<br>
<table width="98%" align="center" class="bordaFina" >
    <tr>
        <td width="613" align="left"><b>Lan&ccedil;amento de Romaneio</b></td>
        <%  //se o paramentro vier com valor entao nao pode excluir
            if ((acao.equals("editar")) && (nivelUser >= 4) && (request.getParameter("ex") == null)) {%>
        <td width="15"><input name="excluir" type="button" class="botoes" value="Excluir"
                              onClick="javascript:tryRequestToServer(function(){excluir('<%=(carregarom ? rom.getIdRomaneio() : 0)%>');});"></td>
            <%}%>
        <td width="56" ><input  name="Button" type="button" class="botoes" value="Voltar para Consulta" onClick="javascript:tryRequestToServer(function(){voltar();});"></td>
    </tr>
</table>
<br>
<form method="post"  id="formBaixa" action="" target="pop2">
    <input type="hidden" id="id" name="id" value="">            
    <input type="hidden" id="ctrcs" name="ctrcs" value="">
    <input type="hidden" id="dtentregabx" name="dtentregabx" value="">
    <input name="totalCts" type="hidden" id="totalCts" size="7" value="0.00">
    <input type="hidden" name="os_aberto_veiculo" id="os_aberto_veiculo" value="<%=(carregarom && rom.getCavalo().isOsAbertoVeiculo() ? "t" : "f")%>">
    <input type="hidden" name="cfgPermitirLancamentoOSAbertoVeiculo"  id="cfgPermitirLancamentoOSAbertoVeiculo" value="<%=cfg.getPermitirLancamantoOSAbertoVeiculo()%>">

<table width="98%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
    <tr>
        <td colspan="8"  class="tabela"><div align="center">Dados Principais</div></td>
    </tr>
    <tr>
        <td width="10%" class="TextoCampos">
            <font size="3">Número:</font>
        </td>
        <td width="10%" class="CelulaZebra2">
            <input name="numromaneio" type="text" id="numromaneio" size="6" maxlength="6" onChange="seNaoIntReset(this,'')" 
                   value="<%=carregarom ? rom.getNumRomaneio() : cadrom.getProximoRomaneio(Apoio.getUsuario(request).getFilial().getIdfilial())%>" 
                   style="font-size:14pt;" <%= (carregarom && rom.isMobileSincronizado() ? " readOnly='true' class='inputReadOnly' " : " class='inputtexto' ") %>>
            <br>
            <input type="checkbox" name="ispreromaneio" id="ispreromaneio" <%=(carregarom ? (rom.isIsPreRomaneio() ? "checked" : "") : "")%>>
            <label id="lbmanifesto">Pr&eacute; Romaneio</label>
        </td>
        <td width="5%" class="TextoCampos">Data:</td>
        <td width="20%" class="CelulaZebra2">
            <input name="dtromaneio" type="text" id="dtromaneio" size="10" maxlength="10" value="<%=carregarom ? (rom.getDtRomaneio() == null ? "" : fmt.format(rom.getDtRomaneio())) : Apoio.getDataAtual()%>" onblur="alertInvalidDate(this)" class="fieldDate" >
            <input name="hrromaneio" type="text" id="hrromaneio" size="5" maxlength="10" value="<%=carregarom ? (rom.getHrRomaneio() == null ? "" : fmtHora.format(rom.getHrRomaneio())) : horaAtual %>" onkeyup="mascaraHora(this)" class="inputReadOnly" readonly >
            <br>
            <input type="checkbox" id="romaneioPontoControle" name="romaneioPontoControle" <%= (carregarom ? (rom.isIsRomaneioPontoControle() ? "checked='true'" : "") : "") %> <%= (acao.equals("iniciar_baixa") ? "disabled='true'" : (cfg.isIsRomaneioPontoControle() ? "checked='true'" : "") ) %>> Ativar Ponto de Controle(gwMobile)
        </td>
        <td width="10%" class="TextoCampos">Filial:</td>
        <td width="18%" class="CelulaZebra2">
            <input name="fi_abreviatura" type="text" class="inputReadOnly" id="fi_abreviatura" size="10" maxlength="12" readonly="true" value="<%=(carregarom ? rom.getFilial().getAbreviatura() : (nivelUser > 0 ? Apoio.getUsuario(request).getFilial().getAbreviatura() : ""))%>">
            <input name="fi_idcidade" type="hidden" id="fi_idcidade" value="0">
            <input name="fi_cidade" type="hidden" id="fi_cidade" value="">
            <input name="fi_uf" type="hidden" id="fi_uf" value="">
            <input name="st_utilizacao_cfe" type="hidden" id="st_utilizacao_cfe" value="<%=(carregarom ? rom.getFilial().getStUtilizacaoCfe() : Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe())%>">
            <input name="cod_natureza" id="cod_natureza" type="hidden" value="<%=(carregarom ? rom.getFilial().getNaturezaCargaContratoFrete().getCod() : (nivelUser > 0 ? Apoio.getUsuario(request).getFilial().getNaturezaCargaContratoFrete().getCod() : "0"))%>"/>
            <input name="codigo_natureza" id="codigo_natureza" type="hidden" value="<%=(carregarom ? rom.getFilial().getNaturezaCargaContratoFrete().getCodigo(): (nivelUser > 0 ? Apoio.getUsuario(request).getFilial().getNaturezaCargaContratoFrete().getCodigo(): "0"))%>"/>
            <input name="descricao_natureza" id="descricao_natureza" type="hidden" value="<%=(carregarom ? rom.getFilial().getNaturezaCargaContratoFrete().getDescricao(): (nivelUser > 0 ? Apoio.getUsuario(request).getFilial().getNaturezaCargaContratoFrete().getDescricao() : "0"))%>"/>
            <%if (acao.equals("iniciar")) {%>
                <input name="button2" type="button" class="inputBotaoMin" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FILIAL%>','Filial')" value="...">
            <%}%>
        </td>
        <td width="5%" class="TextoCampos">Data da Baixa:</td>
        <td width="20%" class="CelulaZebra2">
            <%if (acao.equals("iniciar_baixa")){%>
            <input name="dtentrega" type="text" id="dtentrega" size="10" maxlength="10" value="<%=Apoio.getDataAtual()%>" onBlur="alertInvalidDate(this)" class="fieldDate" >
            <%} else {%>
            <%=(carregarom && rom.getDtEntrega() != null ? fmt.format(rom.getDtEntrega()) : "")%>
            <%}%>
        </td>
    </tr>
    <tr>
        <td class="TextoCampos">Motorista:</td>
        <td class="CelulaZebra2" colspan="3">
            <input name="motor_nome" type="text" class="inputReadOnly" id="motor_nome" size="37" value="<%=(carregarom ? (rom.getMotorista().getNome() != null ? rom.getMotorista().getNome() : "") : "")%>" readonly="true">
            <input type="hidden" id="percentual_valor_cte_calculo_cfe" name="percentual_valor_cte_calculo_cfe">
            <input type="hidden" id="tipo_calculo_percentual_valor_cfe" name="tipo_calculo_percentual_valor_cfe">
            <input name="button" type="button" class="inputBotaoMin" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=10&paramaux=carta','Motorista')" value="...">
            <strong><img src="img/page_edit.png" border="0"
                         onClick="javascript:tryRequestToServer(function(){verMotorista()});"
                         title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; "></strong>
        </td>
        <td class="TextoCampos">Ve&iacute;culo:</td>
        <td class="CelulaZebra2">
            <input name="vei_placa" type="text" class="inputReadOnly" id="vei_placa" value="<%=(carregarom ? rom.getCavalo().getPlaca() : "")%>" size="5" readonly="true">
            <input name="vei_cap_carga" type="hidden" class="inputReadOnly" id="vei_cap_carga" value="0" size="10" readonly="true">
            <input name="localiza_veiculo" type="button" class="inputBotaoMin" id="localiza_veiculo" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=7','Veiculo')" value="...">
            <strong><img src="img/page_edit.png" border="0"
                         onClick="javascript:tryRequestToServer(function(){verVeiculo('V')});"
                         title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; "></strong></td>
        <td class="TextoCampos">Carreta:</td>
        <td class="CelulaZebra2">
            <input name="car_placa" type="text" class="inputReadOnly" id="car_placa" value="<%=(carregarom && rom.getCarreta() != null ? rom.getCarreta().getPlaca() : "")%>" size="5" readonly="true">
            <input name="car_cap_carga" type="hidden" class="inputReadOnly" id="car_cap_carga" value="0" size="10" readonly="true">
            <input name="localiza_veiculo2" type="button" class="inputBotaoMin" id="localiza_veiculo2" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=9','Carreta')" value="...">
            <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Carreta" onClick="javascript:getObj('idcarreta').value = 0;javascript:getObj('car_placa').value = '';validarTipoVeiculo('c');">
                <strong> <img src="img/page_edit.png" border="0"
                              onClick="javascript:tryRequestToServer(function(){verVeiculo('C')});"
                              title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                </strong></strong>
        </td>
    </tr>
    <tr>
        <td class="TextoCampos" rowspan="2">Observa&ccedil;&atilde;o:</td>
        <td colspan="3" class="CelulaZebra2" rowspan="2">
            <textarea name="observacao" cols="50" style="width: 318px; height: 85px;" rows="4" id="observacao" class="inputtexto"><%=(carregarom ? rom.getObservacao() : "")%></textarea>
            <input name="button2" type="button" class="inputBotaoMin" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=28','Observacao');" value="...">
        </td>
        <td  class="TextoCampos">Cidade de origem:</td>
        <td colspan="3" class="CelulaZebra2">
            <input type="text" name="cid_origem" id="cid_origem" size="35" class="inputReadOnly" value="<%=(carregarom && rom.getCidadeOrigem().getDescricaoCidade() != null ? rom.getCidadeOrigem().getDescricaoCidade() : Apoio.getUsuario(request).getFilial().getCidade().getDescricaoCidade())%>" readonly="true">
            <input type="text" name="uf_origem" size="2" id="uf_origem" class="inputReadOnly" value="<%=(carregarom && rom.getCidadeOrigem().getUf()!= null ? rom.getCidadeOrigem().getUf(): Apoio.getUsuario(request).getFilial().getCidade().getUf())%>" readonly="true">
            <input type="hidden" name="idcidadeorigem" id="idcidadeorigem" class="inputReadOnly" value="<%=(carregarom && rom.getCidadeOrigem().getIdcidade() != 0 ? rom.getCidadeOrigem().getIdcidade() : Apoio.getUsuario(request).getFilial().getCidade().getIdcidade())%>" >
            <input type="button" name="localizaCidade" id="localizaCidade" class="inputBotaoMIn" value="..." onclick="localizarCidadeOri();">
        </td>
    </tr>
    <tr>
        <td  class="TextoCampos">Cidade de destino:</td>
        <td colspan="3" class="CelulaZebra2">
            <input type="text" name="cid_destino" id="cid_destino" size="35" class="inputReadOnly" value="<%=(carregarom && rom.getCidadeDestino().getDescricaoCidade() != null ? rom.getCidadeDestino().getDescricaoCidade() : Apoio.getUsuario(request).getFilial().getCidade().getDescricaoCidade())%>" readonly="true">
            <input type="text" name="uf_destino" size="2" id="uf_destino" class="inputReadOnly" value="<%=(carregarom && rom.getCidadeDestino().getUf()!= null ? rom.getCidadeDestino().getUf(): Apoio.getUsuario(request).getFilial().getCidade().getUf())%>" readonly="true">
            <input type="hidden" name="idcidadedestino" id="idcidadedestino" class="inputReadOnly" value="<%=(carregarom && rom.getCidadeDestino().getIdcidade() != 0 ? rom.getCidadeDestino().getIdcidade() : Apoio.getUsuario(request).getFilial().getCidade().getIdcidade())%>" >
            <input type="button" name="localizaCidade" id="localizaCidade" class="inputBotaoMIn" value="..." onclick="localizarCidadeDest();">
        </td>
    </tr>
</table>
    <br>
    <table align="center" width="98%">
        <tbody>
            <tr>
                <td>
                    <table width="100%">
                        <td id="tbDadosCtsColeta" width="20%" class="menu_sel" onclick="AlternarAbasGenerico('tbDadosCtsColeta','tab1')">Dados dos CT-e(s) / Coleta(s)</td>
                        <td id="tbDadosContratoFrete" width="20%" class="menu_sel" onclick="AlternarAbasGenerico('tbDadosContratoFrete','tab4')">Custos com Terceiros</td>
                        <td id="tbIscasAba" width="20%" class="menu_sel" onclick="AlternarAbasGenerico('tbIscasAba','tab7')">Iscas</td>
                        <td id="tbGwMobile" class="menu_sel" width="10%" onclick="AlternarAbasGenerico('tbGwMobile','tab3')">GW Mobile</td>
                        <td id="tbFusionTrak" style='display: <%= carregarom && autenticado.getFilial().getStUtilizacaoFusionTrakRoteirizador() != 'N' ? "" : "none" %>' class="menu_sel" width="10%" onclick="AlternarAbasGenerico('tbFusionTrak','tab6')">Integração FUSION</td>
                        <td style='display: <%= carregarom && nivelUser == 4 ? "" : "none" %>' id="tbAuditoria" class="menu_sel" width="10%" onclick="AlternarAbasGenerico('tbAuditoria','tab5')">Auditoria</td>
                        <td width="40%" ></td>
                    </table>
                </td>
            </tr>
        </tbody>        
    </table>
    <div id="container" align="center" style="width: 100%">
        <div id="tab1" style="">
            <table width="98%" border="0" class="bordaFina">
                <tbody id="tbDadosCtsColeta" name="tbDadosCtsColeta">
                    <tr>
                        <td colspan="7"  class="tabela"><div align="center">Dados dos CT-e(s) / Coleta(s)</div></td>
                    </tr>
                    <%if (!acao.equals("iniciar_baixa")) {%>
                    <tr>
                        <td class="CelulaZebra2" colspan="7">
                            <input id="btAddctrc" type="button" class="botoes" value="Adicionar CT-e(s) / Coleta(s)"
                                   onClick="javascript:tryRequestToServer(function(){launchPopupLocate('./localiza?acao=consultar&idlista=26&fecharJanela=false&paramaux='+concatCtrc(false,true,false)+'&paramaux2='+ctrcsConfirmados(),'locCtrcColetaCadRomaneio')})">
                            &nbsp;
                            Tipo:
                            <select id="tipoConsulta" onChange="alteraTipoConsulta(this.value)" class="inputtexto" style="width: 110">
                                <option value="CTRC">CT Rodoviário</option>
                                <option value="CHAVE_CTE">Chave de Acesso CT-e</option>
                                <option value="NUMERO_NFE">Número NF-e</option>
                                <option value="CHAVE_NFE">Chave de Acesso NF-e</option>
                                <option value="CHAVE_NFE_NUMERO">Chave de Acesso NF-e (Filtrar pelo número NF)</option>
                                <option value="CTA">CT Aéreo</option>
<!--                                <option value="CTF">CTF</option>
                                <option value="CTM">CTM</option>-->
                                <option value="CTQ">CT Aquaviário</option>
                                <option value="NFS">NFS</option>                        
                                <option value="COLETA">Coleta</option>
                                <option value="N_LOCALIZADOR">Nº Localizador</option>
                            </select>
                    
                            <label id="lbRemetente" style="display: none">
                                Remetente:
                                <input id="rem_rzs" name="rem_rzs" class="inputReadOnly8pt2" value="" readonly>
                                <input id="idremetente" name="idremetente" type="hidden" value="0">
                                <input id="btLocalizaRemetente" name="btLocalizaRemetente" type="button" onclick="launchPopupLocate('./localiza?acao=consultar&idlista=03','Remetente')" class="inputBotaoMin" value="..." >
                            </label>
                            <label id="lbFilial">                    
                                Filial:
                            </label>
                            <select id="filialCombo" name="filialCombo" class="inputtexto">
                                <%      //Carregando todas as contas cadastradas
                                    BeanFilial filial = new BeanFilial();
                                    filial.all(Apoio.getUsuario(request).getConexao());
                                    ResultSet rsfilial = filial.all(Apoio.getUsuario(request).getConexao());
                                    while (rsfilial.next()) {%>
                                <option value="<%=rsfilial.getString("idfilial") + "!!" + rsfilial.getString("abreviatura")%>" <%=(rsfilial.getInt("idfilial") == Apoio.getUsuario(request).getFilial().getIdfilial() ? "selected" : "")%>> <%=rsfilial.getString("abreviatura")%></option>
                                <%}%>
                            </select>
                        <label id="lbSerie">Série/Número:
                            <input name="serieConsulta" type="text" class="inputtexto" id="serieConsulta" size="1" value="<%=String.valueOf(Apoio.getUsuario(request).getFilial().getStUtilizacaoCte()).equals("N") ? cfg.getSeriePadraoCtrc() : "1"%>"><b>&nbsp;/</b></label>
                        <input name="numeroConsulta" type="text" class="inputtexto" id="numeroConsulta" size="7" value="" onKeyPress="javascript:if (event.keyCode==13) incluirCtrcColetaAjax()">
                        <input id="btAddctrc2" type="button" class="botoes" value="OK" onClick="incluirCtrcColetaAjax()">
                    </td>
                </tr>
                <%} else {%>
                <tr>
                    <td id="tdTipoConsulta" class="TextoCampos">Ler Cód. Barras:</td>
                    <td class="CelulaZebra2" colspan="3"> 
                        <select id="tipoConsulta" class="inputtexto" style="width: 200">
                            <option value="NFS">Chave de Acesso NF-e (Filtrar pela Chave Completa)</option>                        
                            <option value="CHAVE_NFE_NUMERO">Chave de Acesso NF-e (Filtrar pelo número NF)</option>
                        </select>
                        Marcar como entregue:
                        <input name="optbarras" id="optbarrassim" type="radio" value="S" checked>Sim
                        <input name="optbarras" id="optbarrasnao" type="radio" value="N">Não
                        <input type="text" size="40" id="numero" class="fieldMin" onkeyup="javascript:if (event.keyCode == 13){marcarDesmarcar()};">
                        <input type="button" size="8" class="botoes" value="Marcar" id="marcarck" onclick="marcarDesmarcar()"></td>
                        <td class="CelulaZebra2" style="text-align: center">
                            <label class="textoCampos"><b>Observação Data/Hora:</b></label> 
                            <br>
                            <input name="dtVariasOco" id="dtVariasOco" value="<%=Apoio.getDataAtual()%>" type="text" size="9" class="fieldMin"  maxlength="12" align="Right" onblur="alertInvalidDate(this, true)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                            <font size="1">
                            às
                            </font>
                            <input name="horaVariasOco" type="text" id="horaVariasOco" class="fieldMin" onkeyup="mascaraHora(this)" size="4" maxlength="5"  value=""/>
                            <br>
                            <input name="observacaoOco" id="observacaoOco" value="" type="text" size="20" class="fieldMin"  maxlength="150" align="Right" />
                            <img src="img/add.gif" border="0" title="atribuir valor &agrave; tabela abaixo" class="imagemLink" style="vertical-align:middle;" onClick="javascript:atribuiValores();">
                            <br>
                            <input type="checkbox" id="chkTodasCompEntrega" >
                            Comprovante Entrega
                        </td>
                    <td class="CelulaZebra2"><label id="countCtColeta"></label></td>
                </tr>
                <%}%>
                <tr>
                    <td colspan="8" >
                        <table width="100%" border="0">
                            <tbody id="corpoCtrc">
                                <tr class="Celula">
                                    <%          if (acao.equals("iniciar_baixa")) {
                                        %>            <td><input name="marcarTodos" id="marcarTodos" title="Marcar Todos" type="checkbox" onclick="marcarTodosCTeColeta();">
                                        <div align="center"></div></td>
                                    <%          }
                                    %>
                                    <td width="3%"><div align="left">Seq.</div></td>
                                    <td width="5%"><div align="left">Tipo</div></td>
                                    <td width="10%"><div align="left">Número</div></td>
                                    <td width="6%"><div align="left">Emissão</div></td>
                                    <td width="6%"><div align="left">Filial</div></td>
                                    <td width="13%"><div align="left">Remetente</div></td>
                                    <td width="14%"><div align="left">Destinatário</div></td>
                                    <td width="5%"><div align="right">Frete</div></td>
                                    <td width="5%"><div align="right">Peso</div></td>
                                    <td width="5%"><div align="right">Vol(s)</div></td>
                                    <td width="5%"><div align="right">Valor</div></td>
                                    <td width="5%"><div align="right">Cubagem</div></td>
                                    <%if (!acao.equals("iniciar_baixa")) {
                                    %>  <td width="3%"><div align="left"></div></td>
                                    <%} else {
                                    %>
                                        <td width="14%">Observa&ccedil;&atilde;o Ocor. </td>
                                        <td width="3%">Ocor. </td>
                                        <td width="2%"></td>
                                        <td width="2%"></td>
                                    <%}%>
                                </tr>
                            </tbody>
                            <tr class="Celula">
                                <%          if (acao.equals("iniciar_baixa")) {
                                %>            <td></td>
                                <%          }
                                %>
                                <td colspan="2"><div align="right">QTD CT-e(s):</div></td>
                                <td>
                                    <div align="left">
                                        <b><label id="lbTotalCts">0</label></b> 
                                        <input name="totalCts" type="hidden" id="totalCts" size="7" readonly class="inputReadOnly" value="0.00"/>
                                    </div>
                                </td>
                                <td colspan="2"><div align="right">QTD Coleta(s):</div></td>
                                <td>
                                    <div align="left">
                                        <b><label id="lbTotalColeta">0</label></b> 
                                        <input name="totalColeta" type="hidden" id="totalColeta" size="7" readonly  class="inputReadOnly" value="0.00"/>
                                    </div>
                                </td>
                                <td><div align="left"></div></td>
                                <td>
                                    <div align="right">
                                        <b><label id="lbTotalFrete">0.00</label></b> 
                                       <input name="totalValor" type="hidden" id="totalValor" size="7" readonly class="inputReadOnly" value="0.00"/>
                                       <input name="totalValorFreteCte" type="hidden" id="totalValorFreteCte" size="7" readonly class="inputReadOnly" value="0.00"/>
                                       <input name="totalValorPesoCte" type="hidden" id="totalValorPesoCte" size="7" readonly class="inputReadOnly" value="0.00"/>
                                    </div>
                                </td>
                                <td>
                                    <div align="right">
                                        <b><label id="lbTotalPeso">0.00</label></b> 
                                        <input name="totalPeso" type="hidden" id="totalPeso" size="7" readonly class="inputReadOnly" value="0.00"/>
                                    </div>
                                </td>
                                <td>
                                    <div align="right">
                                        <b><label id="lbTotalVolume">0.00</label></b> 
                                        <input name="totalVolumes" type="hidden" id="totalVolumes" size="7" readonly class="inputReadOnly" value="0.00"/>
                                    </div>
                                </td>
                                <td>
                                    <div align="right">
                                        <b><label id="lbTotalValorNF">0.00</label></b> 
                                        <input name="totalValorNF" type="hidden" id="totalValorNF" size="7" readonly class="inputReadOnly" value="0.00"/>
                                    </div>
                                </td>
                                <td>
                                    <div align="right">
                                        <b><label id="lbTotalCubagem">0.00</label></b> 
                                       <input name="totalCubagem" type="hidden" id="totalCubagem" size="7" readonly class="inputReadOnly" value="0.00"/>
                                    </div>
                                </td>
                                <%if (!acao.equals("iniciar_baixa")) {
                                %>  <td><div></div></td>
                                <%} else {
                                %>
                                    <td></td>
                                    <td></td>
                                    <td></td>
                                    <td></td>
                                <%}%>
                            </tr>
                        </table>
                    </td>
                </tr>
        </table>
    </div>
        <div id="tab3" style="display: none">
            <table width="98%" border="0" class="bordaFina">
                <tbody id="tbGwMobile" name="tbGwMobile">
                    <tr>
                        <td colspan="7"  class="tabela"><div align="center">Gw Mobile</div></td>
                    </tr>
                    <tr>
                        <td colspan="7"  class="">
                            <table width="100%" class="bordaFina">
                                <c:if test="<%= (carregarom && rom.isMobileSincronizado()) %>">
                                    <tr class="celulaZebra2">
                                        <td width="20%">Status:</td>
                                        <td width="80%" colspan="3" style="font-weight: bold">Sincronizado</td>
                                    </tr>
                                    <tr class="celulaZebra2">
                                        <td width="20%">Usuário que sincronizou: </td>
                                        <td width="20%"> <%= rom.getUsuarioSincronizacaoMobile().getNome() %> </td>
                                        <td width="20%">data sincronização:</td>
                                        <td width="20%"> <%= rom.getDataSincronizacaoMobile() +" "+ rom.getHoraSincronizacaoMobile() %> </td>
                                    </tr>
                                </c:if>
                                <c:if test="<%= !(carregarom && rom.isMobileSincronizado()) %>">
                                <tr class="celulaZebra2">
                                    <td width="20%">Status:</td>
                                    <td width="80%" style="font-weight: bold">Não Sincronizado</td>
                                </tr>
                                </c:if>
                            </table>
                        </td>
                    </tr>                    
                </tbody>                
            </table>
        </div>
        <div id="tab4" style="display: none">
            <table width="98%" border="0" class="bordaFina">
                <tbody id="tbAjudante" name="tbAjudante">
                    <tr>
                        <td colspan="7"  class="tabela"><div align="center">Custo com Ajudantes</div></td>
                    </tr>
                    <%if (!acao.equals("iniciar_baixa")) {%>
                    <tr>
                        <td colspan="7" class="CelulaZebra2"><input id="btAddaj" type="button" class="botoes" value="Adicionar ajudante"
                                                                    onClick="launchPopupLocate('./localiza?acao=consultar&idlista=25','Ajudante')"></td>
                    </tr>
                    <%}%>                    
                    <tr>
                        <td colspan="7" >
                            <table width="100%" border="0">
                                <tbody id="corpoAjud">
                                    <tr class="Celula">
                                        <td width="41%"><div align="center">Nome</div></td>
                                        <td width="20%"><div align="center">Telefone</div></td>
                                        <td width="20%"><div align="center">2&ordm; Telefone</div></td>
                                        <td width="16%"><div align="center">Valor</div></td>
                                        <%if (!acao.equals("iniciar_baixa")) {%>
                                          <td width="3%"><div align="center"></div></td>
                                        <%}%>
                                    </tr>
                                </tbody>
                                <tr class="Celula">
                                    <td ><div align="center"></div></td>
                                    <td ><div align="center"></div></td>
                                    <td ><div align="right">Total custo ajudante:</div></td>
                                    <td >
                                        <div align="left">
                                            <input name="diariaajud" type="text" id="diariaajud" class="inputReadOnly" onChange="seNaoFloatReset(this,'0.00')" value="<%=(carregarom ? Apoio.to_curr(rom.getVlRateioAjudante()) : "0.00")%>" size="10" maxlength="10" readonly="true">
                                        </div>
                                    </td>
                                    <%if (!acao.equals("iniciar_baixa")) {%>
                                      <td ><div align="center"></div></td>
                                    <%}%>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </tbody>
            </table>
            <%if(cfg.isRomaneioAutorizacaoPagamento()){%>
                <table width="90%" border="0" class="bordaFina">
                    <tr>
                        <td colspan="11" class="tabela"><div align="center">Documento para Pagamento</div></td>                
                    </tr>
                    <tr class="Celula">
                        <td width="12%">Autorizado</td>
                        <td width="5%">Tipo</td>
                        <td width="7%">Numero</td>
                        <td width="7%">Emissão</td>
                        <td width="7%">Filial</td>
                        <td width="25%">Remetente/Destinatário</td>
                        <td width="8%">Cidade/UF</td>
                        <td width="8%">Usuario</td>
                        <td width="8%">Rota</td>
                        <td width="8%">Valor Motorista</td>
                        <td width="5%"></td>
                    </tr>
                    <tbody id="tbDocumentoPagamento" name="tbDocumentoPagamento">
                    <input type="hidden" id="maxDocPagt" name="maxDocPagt" value="0"/>
                    </tbody>
                    <tr>
                        <td class="TextoCampos" colspan="2">
                            <label>
                                <b>QTD CT-e(s):</b>
                            </label>
                        </td>
                        <td class="CelulaZebra2" colspan="2">
                            <label id="lbTotalCtsDocPagt" ></label>                        
                        </td>
                        <td class="TextoCampos">
                            <label>
                                <b>QTD Coleta(s):</b>
                            </label>
                        </td>
                        <td class="CelulaZebra2" colspan="6">
                            <label id="lbTotalColetaDocPagt"></label>                        
                        </td>
                    </tr>
                </table>
            <%}%>                                                    
            <table width="98%" border="0" class="bordaFina">
                <tbody id="tbDadosContratoFrete" name="tbDadosContratoFrete">
                    <tr>
                        <td colspan="8" class="tabela"><div align="center">Custo com o Proprietário do Veículo</div></td>
                    </tr>
                    <tr>
                        <td class="TextoCampos" width="10%">Custo de Entrega/Coleta:</td>
                        <td class="CelulaZebra2" width="15%">
                            <input name="diaria" type="text" id="diaria" onChange="seNaoFloatReset(this,'0.00')" value="<%=(carregarom ? Apoio.to_curr(rom.getVlRateioDiaria()) : "0.00")%>" class="inputtexto" size="10" maxlength="10">
                        </td>
                        <td class="TextoCampos" width="10%"></td>
                        <td class="TextoCampos" width="15%"></td>
                        <td class="TextoCampos" width="10%"></td>
                        <td class="TextoCampos" width="15%"></td>
                        <td class="TextoCampos" width="10%"></td>
                        <td class="TextoCampos" width="15%"></td>
                    </tr>
                    <tr id="trCheckContrato">
                        <td colspan="8" class="celula">
                            <div align="center">
                                <input name="chkCartaAutomaticaRomaneio" type="checkbox" id="chkCartaAutomaticaRomaneio" value="" onchange="javascript:geraContrato();">
                                <label for="chkCartaAutomaticaRomaneio">Gerar contrato de frete automaticamente ao salvar o romaneio</label> <label id="complTextoContrato"></label>
                            </div>
                        </td>                      
                    </tr>
                    <tr id="trContrato" style="display: none;">
                        <td colspan="8">
                            <table width="100%" class="bordaFina">
                                <tr>
                                    <td width="10%" class="TextoCampos">Data Partida:
                                        <input name="plano_proprietario" type="hidden" id="plano_proprietario" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                        <input name="und_proprietario" type="hidden" id="und_proprietario" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                        <input name="valor_rota" type="hidden" id="valor_rota" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                        <input name="valor_maximo_rota" type="hidden" id="valor_maximo_rota" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                        <input name="tipo_valor_rota" type="hidden" id="tipo_valor_rota" class="inputReadOnly8pt" size="20" readonly="true" value="f">
                                        <input name="debito_prop" type="hidden" id="debito_prop" size="10" value="0">
                                        <input name="percentual_desconto_prop" type="hidden" id="percentual_desconto_prop" size="10" value="0">
                                        <input name="percentual_ctrc_contrato_frete" type="hidden" id="percentual_ctrc_contrato_frete" size="10" value="0">
                                        <input name="valor_rota_viagem_2" type="hidden" id="valor_rota_viagem_2" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                        <input name="valor_pedagio_rota" type="hidden" id="valor_pedagio_rota" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                        <input name="valor_entrega_rota" type="hidden" id="valor_entrega_rota" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                        <input name="qtd_entregas_rota" type="hidden" id="qtd_entregas_rota" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                        <input name="base_ir_prop_retido" type="hidden" id="base_ir_prop_retido" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                        <input name="ir_prop_retido" type="hidden" id="ir_prop_retido" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                        <input name="base_inss_prop_retido" type="hidden" id="base_inss_prop_retido" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                        <input name="inss_prop_retido" type="hidden" id="inss_prop_retido" value="0.00" size="8" maxlength="12" class="inputReadOnly8pt style1" readonly>
                                        <input type="hidden" name="perc_adiant" id="perc_adiant" value="0">
                                        <input type="hidden" name="countDespesaCarta" id="countDespesaCarta" value="0">
                                        <input name="tipo_desconto_prop" type="hidden" id="tipo_desconto_prop" value="0.00">
                                    </td>
                                    <td width="15%" class="CelulaZebra2">
                                        <input type="text" onBlur="alertInvalidDate(this,true)" size="10" maxlength="10" name="dataPartida" id="dataPartida" onchange="getRotaPercurso()" class="fieldDate" class="inputtexto" value="<%=Apoio.getDataAtual()%>" />
                                    </td>
                                    <td width="10%" class="TextoCampos">Data Término:</td>
                                    <td width="15%" class="CelulaZebra2">
                                        <input type="text" onBlur="alertInvalidDate(this,true)" size="10" maxlength="10" name="dataTermino" id="dataTermino" class="fieldDate" class="inputtexto" />
                                    </td>
                                    <td width="10%" class="TextoCampos">Rota:</td>
                                    <td width="15%" class="CelulaZebra2">
                                        <select name="rota" id="rota" class="inputtexto" onchange="getRotaPercurso();if(this.value != '0'){getTabelaPreco();}" onkeypress="verSeTemRota();" onclick="verSeTemRota();">
                                            <option value="0">Rota não informada</option>
                                            <c:forEach var="rota" varStatus="status" items="${listaRota}">
                                                <option value=${rota.id}>${rota.descricao}</option>
                                            </c:forEach>
                                        </select>
                                        <img src="img/atualiza.png" alt="" name="carregaRota" title="Clique aqui para atualizar as rotas de acordo com as cidades de destino do romaneio." class="imagemLink" id="carregaRota" onclick="getRota()" />
                                    </td>
                                    <td width="10%" class="TextoCampos">Percurso:</td>
                                    <td width="15%" class="CelulaZebra2">
                                        <select name="percurso" id="percurso" class="inputtexto">
                                            <option value="0">----------</option>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">Contratado:</td>
                                    <td class="CelulaZebra2" colspan="3">
                                        <input name="vei_prop_cgc" type="text" id="vei_prop_cgc" class="inputReadOnly8pt" size="20" readonly="true" value="">
                                        <input name="vei_prop" type="text" id="vei_prop" class="inputReadOnly8pt" size="40" readonly="true" value="">
                                        <input type="hidden" name="idproprietarioveiculo" id="idproprietarioveiculo" value="0">
                                    </td>
                                    <td class="TextoCampos">Eixos Suspensos:</td>
                                    <td class="CelulaZebra2">
                                        <input type="text" class="inputTexto" name="eixosSuspensos" id="eixosSuspensos" size="3" onkeypress="mascara(this, soNumeros)" maxlength="1" value="0">
                                    </td>
                                    <td class="TextoCampos">Categoria Veículo:</td>
                                    <td class="CelulaZebra2">
                                        <select class="inputtexto" id="categoria_pamcard_id" name="categoria_pamcard_id" style="width: 150px;">
                                            <option value="0">Não informado</option>
                                            <%
                                              CategoriaVeiculoBO categoriaVeiculoBO = new CategoriaVeiculoBO();
                                              Collection lista = categoriaVeiculoBO.listar(Apoio.getUsuario(request));
                                            %>                                
                                            <c:forEach var="categoria" varStatus="status"
                                                       items="<%=lista%>">
                                                <option value="${categoria.id}">${categoria.descricao}</option>
                                            </c:forEach>
                                        </select>
                                        <select class="inputtexto" id="categoria_ndd_id" name="categoria_ndd_id" style="width: 150px;">
                                            <option value="0">Não informado</option>
                                            <%
                                              CategoriaVeiculoNddBO categoriaVeiculoNddBO = new CategoriaVeiculoNddBO();
                                              Collection listaNDD = categoriaVeiculoNddBO.listar(Apoio.getUsuario(request));
                                            %>                                
                                            <c:forEach var="categoria" varStatus="status"
                                                       items="<%=listaNDD%>">
                                                <option value="${categoria.id}">${categoria.descricao}</option>
                                            </c:forEach>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">OBS Contrato:</td>
                                    <td class="CelulaZebra2" colspan="3">
                                        <textarea name="obs_carta_frete" cols="59" rows="3" id="obs_carta_frete" class="inputtexto"></textarea>
                                    </td>
                                    <td class="TextoCampos">Natureza Carga:</td>
                                    <td class="CelulaZebra2">
                                        <input type="text"class="inputReadOnly8pt" name="natureza_cod_desc" id="natureza_cod_desc" size="3" readonly> 
                                        <input type="text"class="inputReadOnly8pt" name="natureza_desc" id="natureza_desc" size="12" readonly> 
                                        <input type="button" class="inputBotaoMin" id="botaoCarreta" onclick="abrirLocalizaNatureza()" value="..." /> 
                                        <input type="hidden" name="natureza_cod" id="natureza_cod" value="0" /> 
                                    </td>
                                    <td class="TextoCampos">Produto/Operação:</td>
                                    <td class="CelulaZebra2">
                                        <select name="tipoProduto" id="tipoProduto" class="inputtexto" style="width: 150px;" onchange="getTabelaPreco();">
                                            <option value="0" selected>Não informado</option>
                                            <%
                                              ConsultaTipoProduto tpProduto = new ConsultaTipoProduto();
                                              Collection listaProd = tpProduto.mostrarTodos(Apoio.getUsuario(request).getConexao());
                                            %>                                
                                            <c:forEach var="tpProd" varStatus="status" items="<%=listaProd%>">
                                                <option value="${tpProd.id}" >${tpProd.descricao}</option>
                                            </c:forEach>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="8">
                                        <table width="100%" border="0" align="center">
                                            <tr>
                                                <td width="50%">
                                                    <table width="100%" border="0" class="bordaFina" align="center">
                                                        <tr>
                                                            <td class="celula" colspan="3">Cálculo do Frete</td>
                                                        </tr>
                                                        <tr>
                                                            <td class='TextoCampos'><b>R$/Tonelada:</b></td>
                                                            <td class='CelulaZebra2'><input onchange="bloquearCamposValorTonelada();"
                                                                    name="vlTonelada" onblur="calculaValorTonelada();"
                                                                    onkeypress="mascara(this, reais)" id="vlTonelada"
                                                                    type="text" class="inputtexto" size="5" maxlength="12"
                                                                    value="0,00" />&nbsp;&nbsp;<label><b>*</b></label>
                                                                <label id="labTotalPesoTon" name="labTotalPesoTon">0,00&nbsp;TON</label>
                                                                <input name="pesoTonelada" id="pesoTonelada" type="hidden" class="inputtexto"  value="0"/>
                                                            </td>
                                                            <td class='CelulaZebra2'>
                                                                <div id="divSolicitarAutorizacao" name="divSolicitarAutorizacao" style="display:none;">
                                                                    <input type="checkbox" class="inputTexto" name="solicitarAutorizacao" id="solicitarAutorizacao" onclick="javascript:solicitaAutorizacao();if(!this.checked){getTabelaPreco()}"/>
                                                                    <label for="solicitarAutorizacao">Solicitar Autorização para Frete maior que a tabela</label>
                                                                </div>
                                                                <label id="lbMotivoAutorizacao" name="lbMotivoAutorizacao" style="display:none;">Motivo:</label>
                                                                <textarea class="inputTexto" cols="37" rows="3" id="motivoSolicitacao" name="motivoSolicitacao" style="display:none;"><c:out value="${cadContratoFrete.motivoAutorizacao}"/></textarea>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class='TextoCampos'><b>R$/KM:</b></td>
                                                            <td class='CelulaZebra2'>
                                                                <input name="valorPorKM" onblur="seNaoFloatReset(this,'0.00');this.value=formatoMoeda(this.value);validarFreteCarreteiro();calculaValorKM();calculaImpostos();liberarCamposValorPorKM();" id="valorPorKM" type="text" class="inputReadOnly changeHandler" size="5" maxlength="12" value="0.00" />&nbsp;&nbsp;
                                                                <label><b>*</b></label>
                                                                <input name="quantidadeKm" onchange="calculaValorKM();calculaImpostos();liberarCamposQuantidade();" id="quantidadeKm" type="text" class="inputtexto" size="8" maxlength="12" value="0" />
                                                                <label id="labTotalKM" name="labTotalKM">&nbsp;KM</label>
                                                            </td>
                                                            <td class='CelulaZebra2' colspan="10"></td>
                                                        </tr>
                                                        <tr>
                                                            <td class='TextoCampos'><b>Valor Contrato:</b></td>
                                                            <td class='CelulaZebra2'>
                                                                <input name="cartaValorFrete" onblur="bloquearCamposValorContrato();seNaoFloatReset(this,'0.00');validarFreteCarreteiro();calcularFreteCarreteiro();" type="text" id="cartaValorFrete" value="0.00" size="9" maxlength="12" class="inputtexto changeHandler" >
                                                                <img src="img/calculadora.png" alt="" name="carregaTabela" title="Clique aqui para calcular o frete pela tabela de preço da rota escolhida." class="imagemLink" id="carregaTabela" onclick="getTabelaPreco()" />
                                                            </td>
                                                            <td class='CelulaZebra2'>
                                                                <div id="detalhesTabRota" name="detalhesTabRota" style="display:none;">
                                                                    <label id="tabTipoVeiculo"></label><br>
                                                                    <label id="tabTipoProduto"></label><br>
                                                                    <label id="tabTipoCliente"></label><br>
                                                                    <label id="tabTipoCalculo"></label><br>
                                                                    <b><label id="tabValorCalculo"></label></b>
                                                                </div>
                                                                <input name="tab_tipo_valor" id="tab_tipo_valor" type="hidden" value="" />
                                                                <input name="tab_valor" id="tab_valor" type="hidden" value="0" />
                                                                <input name="tab_valor_maximo" id="tab_valor_maximo" type="hidden" value="0" />
                                                                <input name="tab_valor_fixo" id="tab_valor_fixo" type="hidden" value="0" />
                                                                <input name="tab_valor_entrega" id="tab_valor_entrega" type="hidden" value="0" />
                                                                <input name="tab_qtd_entrega" id="tab_qtd_entrega" type="hidden" value="0" />
                                                                <input name="tab_valor_excedente" id="tab_valor_excedente" type="hidden" value="0" />
                                                                <input name="tab_id" id="tab_id" type="hidden" value="0" />
                                                                <input name="tabela_is_deduzir_pedagio" id="tabela_is_deduzir_pedagio" type="hidden" value="false">
                                                                <input name="tabela_is_carregar_pedagio_ctes" id="tabela_is_carregar_pedagio_ctes" type="hidden" value="false">
                                                                <input name="motorista_valor_minimo" type="hidden" id="motorista_valor_minimo" value="0.00">
                                                                <input name="rota_valor_minimo" type="hidden" id="rota_valor_minimo" value="0.00">
                                                            </td>
                                                        </tr>
                                                        <%if (cfg.isOutrosRetemImposto()){%>
                                                            <tr>
                                                                <td class="textoCampos">Outros:</td>
                                                                <td class="celulaZebra2">
                                                                    <input name="cartaOutros" type="text" id="cartaOutros" value="0.00" size="9" maxlength="12" class="inputtexto" onBlur="javascript:seNaoFloatReset(this,'0.00');calcularFreteCarreteiro();">
                                                                    &nbsp;&nbsp;(+)
                                                                </td>
                                                                <td class="celulaZebra2">Descrição Outros: <input
                                                                        name="obsOutros" id="obsOutros" type="text" class="inputtexto"
                                                                        maxlength="60" size="23" value="" />
                                                                </td>
                                                            </tr>
                                                        <%}%>
                                                        <%if (cfg.isDescargaRetemImposto()){%>
                                                            <tr>
                                                                <td class="textoCampos">Descarga:</td>
                                                                <td class="celulaZebra2">
                                                                    <input name="vlDescarga" onBlur="javascript:seNaoFloatReset(this,'0.00');calcularFreteCarreteiro();" id="vlDescarga" type="text" class="inputtexto" size="9" maxlength="10" value="0.00" />
                                                                    &nbsp;&nbsp;(+)
                                                                </td>
                                                                <td class="celulaZebra2"></td>
                                                            </tr>
                                                        <%}%>
                                                        <tr id="trBaseImpostos">
                                                            <td class='TextoCampos'><b>Base Retenção:</b></td>
                                                            <td class='CelulaZebra2'><b><label id="lbBaseImpostos"></label></b></td>
                                                            <td class='CelulaZebra2'>
                                                                <div id="titchkImposto"><input name="chk_reter_impostos" type="checkbox" id="chk_reter_impostos" value="checkbox" onClick="calcularFreteCarreteiro();"> Reter Impostos (IRRF,INSS e SEST/SENAT)</div>
                                                                <input name="cartaImpostos" type="hidden" id="cartaImpostos" value="0.00" size="8" maxlength="12" class="inputReadOnly8pt style1" onBlur="javascript:seNaoFloatReset(this,'0.00');" readOnly>
                                                            </td>
                                                        </tr>
                                                        <tr id="trIR">
                                                            <td class="textoCampos styleRed">Valor IRRF:</td>
                                                            <td class="celulaZebra2 styleRed">
                                                                <input name="valorIRInteg" type="hidden" id="valorIRInteg" value="0.00" size="8" maxlength="12">
                                                                <input name="valorIR" type="text" id="valorIR" value="0.00" size="9" maxlength="12" class="inputReadOnly styleRed" readonly>
                                                                <input name="vlDependentes" type="hidden" id="vlDependentes" value="0.00" size="9" maxlength="12" class="inputReadOnly styleRed" readonly>
                                                                <input name="qtddependentes" type="hidden" id="qtddependentes" value="0.00" size="9" maxlength="12" class="inputReadOnly styleRed" readonly>
                                                                &nbsp;&nbsp;(-)
                                                                <input name="baseIR" type="hidden" id="baseIR" value="0.00" size="8" maxlength="12">
                                                                <input name="aliqIR" type="hidden" id="aliqIR" value="0.00" size="8" maxlength="12">
                                                            </td>
                                                            <td class="textoCampos"></td>
                                                        </tr>
                                                        <tr id="trINSS">
                                                            <td class="textoCampos styleRed">INSS:</td>
                                                            <td class="celulaZebra2 styleRed">
                                                                <input name="valorINSSInteg" type="hidden" id="valorINSSInteg" value="0.00" size="8" maxlength="12">
                                                                <input name="valorINSS" type="text" id="valorINSS" value="0.00" size="9" maxlength="12" class="inputReadOnly styleRed" readonly>
                                                                &nbsp;&nbsp;(-)
                                                                <input name="baseINSS" type="hidden" id="baseINSS" value="0.00" size="8" maxlength="12">
                                                                <input name="aliqINSS" type="hidden" id="aliqINSS" value="0.00" size="8" maxlength="12">
                                                            </td>
                                                            <td class="textoCampos"></td>
                                                        </tr>
                                                        <tr id="trSestSenat">
                                                            <td class="textoCampos styleRed">Sest/Senat:</td>
                                                            <td class="celulaZebra2 styleRed">
                                                                <input name="valorSESTInteg" type="hidden" id="valorSESTInteg" value="0.00" size="8" maxlength="12">
                                                                <input name="valorSEST" type="text" id="valorSEST" value="0.00" size="9" maxlength="12" class="inputReadOnly styleRed" readonly>
                                                                &nbsp;&nbsp;(-)
                                                                <input name="baseSEST" type="hidden" id="baseSEST" value="0.00" size="8" maxlength="12">
                                                                <input name="aliqSEST" type="hidden" id="aliqSEST" value="0.00" size="8" maxlength="12">
                                                            </td>
                                                            <td class="textoCampos"></td>
                                                        </tr>
                                                        <tr>
                                                            <td class="textoCampos styleRed">Outras retenções:</td>
                                                            <td class="celulaZebra2 styleRed">
                                                                <input id="percentualRetencao" name="percentualRetencao" type="text"
                                                                       class="inputtexto styleRed" size="5" maxlength="9" value="0"
                                                                       onchange="seNaoFloatReset(this, '0.00'); calcularFreteCarreteiro();">&nbsp;&nbsp;%
                                                                <input name="cartaRetencoes" type="text"
                                                                       id="cartaRetencoes" value="0.00" size="9"
                                                                       maxlength="12" class="inputtexto styleRed"
                                                                       onBlur="javascript:seNaoFloatReset(this,'0.00');calcularFreteCarreteiro();">&nbsp;&nbsp;(-)
                                                                <input name="mot_outros_descontos_carta" type="hidden" id="mot_outros_descontos_carta" value="0.00" size="8" maxlength="12">
                                                                <c:set var="cfg" value="<%=cfg%>" />
                                                                <c:choose>
                                                                    <c:when test="${param.acao eq 'iniciar' && cfg.tipoVlConMotor eq 'f' && cfg.vlConMotor != 0}">
                                                                        <script>
                                                                            $('cartaRetencoes').value = colocarVirgula(parseFloat('${cfg.vlConMotor}'));
                                                                            readOnly($('percentualRetencao'));
                                                                        </script>
                                                                    </c:when>
                                                                    <c:when test="${param.acao eq 'iniciar' && cfg.tipoVlConMotor eq 'p' && cfg.vlConMotor != 0}">
                                                                        <script>
                                                                            $('percentualRetencao').value = parseFloat('${cfg.vlConMotor}');
                                                                            readOnly($('cartaRetencoes'));
                                                                        </script>
                                                                    </c:when>
                                                                </c:choose>
                                                            </td>
                                                            <td class="textoCampos"></td>
                                                        </tr>
                                                        <tr ${(not cfg.descontoAutomaticoAbastecimento) ? "style='display: none;'" : ""}>
                                                            <td class="textoCampos styleRed"><label for="abastecimentos">Abastecimentos:</label></td>
                                                            <td class="celulaZebra2">
                                                                <input id="abastecimentos" name="abastecimentos" type="text"
                                                                       class="inputtexto inputReadOnly styleRed" size="9" maxlength="9" value="0,00"
                                                                       onchange="seNaoFloatReset(this, '0,00')" readonly >&nbsp;&nbsp;&nbsp;(-)
                                                            </td>
                                                            <td class="celulaZebra2 styleRed" colspan="8">
                                                                <label>Referente aos abastecimentos: <span id="lbAbastecimento"></span></label>
                                                                <input type="hidden" name="ids_abastecimentos" id="ids_abastecimentos">
                                                            </td>
                                                        </tr>
                                                        <%if (!cfg.isOutrosRetemImposto()){%>
                                                            <tr>
                                                                <td class="textoCampos">Outros:</td>
                                                                <td class="celulaZebra2">
                                                                    <input name="cartaOutros" type="text" id="cartaOutros" value="0.00" size="9" maxlength="12" class="inputtexto" onBlur="javascript:seNaoFloatReset(this,'0.00');calcularFreteCarreteiro();">
                                                                    &nbsp;&nbsp;(+)
                                                                </td>
                                                                <td class="celulaZebra2">Descrição Outros:<input
                                                                        name="obsOutros" id="obsOutros" type="text" class="inputTexto"
                                                                        maxlength="60" size="23" value="" />
                                                                </td>
                                                            </tr>
                                                        <%}%>
                                                        <tr>
                                                            <td class="textoCampos">Pedágio:</td>
                                                            <td class="celulaZebra2">
                                                                <input name="cartaPedagio" type="text" id="cartaPedagio" value="0.00" size="9" maxlength="12" class="inputtexto" onBlur="javascript:seNaoFloatReset(this,'0.00');calcularFreteCarreteiro();">
                                                                &nbsp;&nbsp;(+)
                                                            </td>
                                                            <td class="celulaZebra2">
                                                               <input type="checkbox" class="inputTexto" name="pedagioIdaVolta" id="pedagioIdaVolta" /> Valor do ped&aacute;gio referente a Ida e Volta
                                                            </td>
                                                        </tr>
                                                        <%if (!cfg.isDescargaRetemImposto()){%>
                                                            <tr>
                                                                <td class="textoCampos">Descarga:</td>
                                                                <td class="celulaZebra2">
                                                                    <input name="vlDescarga" onBlur="javascript:seNaoFloatReset(this,'0.00');calcularFreteCarreteiro();" id="vlDescarga" type="text" class="inputtexto" size="9" maxlength="10" value="0.00" />
                                                                    &nbsp;&nbsp;(+)
                                                                </td>
                                                                <td class="celulaZebra2"></td>
                                                            </tr>
                                                        <%}%>
                                                        
                                                         <tr id="trTarifas" style="display: none">
                                                            <td class="textoCampos">Total Tarifas:</td>
                                                            <td class="celulaZebra2">
                                                                <input name="vlTarifas" id="vlTarifas"  onkeypress="mascara(this, reais)" 
                                                                       type="text" class="inputtexto" size="9" maxlength="10" value="0,00" />&nbsp;&nbsp;(+)</td>
                                                            <td colspan="1" class="TextoCampos" >
                                                                <div align="left" id="valorTarifasSaque">Saque:
                                                                <input name="qtdSaques" type="text" id="qtdSaques" value="" class="inputTexto" size="2" maxlength="3" onkeypress="soNumeros(this.value)" onblur="javascript:calculaTotalTarifas();">

                                                                (*)
                                                                <input name="valorPorSaques" type="text" id="valorPorSaques" value="" class="inputTexto" size="3" onkeypress="soNumeros(this.value)" onblur="javascript:calculaTotalTarifas();">
                                                                =
                                                                <input name="totalSaques" type="text" id="totalSaques" value="" class="inputTexto" size="5" onkeypress="soNumeros(this.value)" >
                                                                </div>
                                                           
                                                                <div align="left" id="valorTarifasTransf">Transf.:
                                                                <input name="qtdTransf" type="text" id="qtdTransf" value="" class="inputTexto" size="2" maxlength="5" onkeypress="soNumeros(this.value)" onblur="javascript:calculaTotalTarifas();">

                                                                (*)
                                                                <input name="valorTransf" type="text" id="valorTransf" value="" class="inputTexto" size="3"  onkeypress="soNumeros(this.value)" onblur="javascript:calculaTotalTarifas();">
                                                                = 
                                                                <input name="totalTransf" type="text" id="totalTransf" value="" class="inputTexto" size="5"  onkeypress="soNumeros(this.value)">
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        
                                                        
                                                        <tr>
                                                            <td width='20%' class="textoCampos"><b>Valor L&iacute;quido:</b></td>
                                                            <td width='25%' class="celulaZebra2">
                                                                <input name="cartaLiquido" type="text" id="cartaLiquido" value="0.00" size="9" maxlength="12" class="inputReadOnly" readonly onBlur="javascript:seNaoFloatReset(this,'0.00');">
                                                                &nbsp;&nbsp;(=)
                                                            </td>
                                                            <td width='55%' class="textoCampos"></td>
                                                        </tr>                      
                                                    </table>
                                                </td>
                                                <td width="50%" style="vertical-align:top;">
                                                    <table width="100%" border="0" cellspacing="1" cellpadding="2" class="bordaFina">
                                                        <tr class="celula">
                                                            <td colspan="6">Dados do Pagamento</td>
                                                        </tr>
                                                        <tr class="celula">
                                                            <td width="15%"></td>
                                                            <td width="15%">Valor</td>
                                                            <td width="15%">Data</td>
                                                            <td width="15%">F. Pag.</td>
                                                            <td width="25%">Conta/Ag. Pag.</td>
                                                            <td width="15%">Doc</td>
                                                        </tr>
                                                        <tr>
                                                            <td class="TextoCampos">Adiantamento:</td>
                                                            <td class="TextoCampos">
                                                                <input name="cartaValorAdiantamento" type="text" id="cartaValorAdiantamento" value="0.00" size="6" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.00');alteraFpag('a');">
                                                            </td>
                                                            <td class="TextoCampos">
                                                                <input name="cartaDataAdiantamento" type="text" id="cartaDataAdiantamento" value="<%=(Apoio.getDataAtual())%>" class="fieldDate" onChange="javascript:alertInvalidDate(this);" size="9" maxlength="10" style="font-size:8pt;">
                                                            </td>
                                                            <td class="TextoCampos">
                                                                <select name="cartaFPagAdiantamento" id="cartaFPagAdiantamento" class="fieldMin" style="width:70px;" onChange="javascript:alteraFpag('a');">
                                                                    <%if (cfg.isCartaFreteAutomaticaRomaneio() && acao.equalsIgnoreCase("iniciar")){
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
                                                                <select name="favorecidoAdiantamento" id="favorecidoAdiantamento" class="fieldMin" style="width:70px;">
                                                                    <%if (Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == 'N'){%>
                                                                        <option value="t">Terceiro</option>
                                                                    <%}%>
                                                                    <option value="m">Motorista</option>
                                                                    <option value="p" selected>Proprietário</option>
                                                                </select>
                                                            </td>
                                                            <td class="TextoCampos">
                                                                    <select name="contaAdt" id="contaAdt" class="fieldMin" style="width:120px;display:none;" onChange="javascript:alteraFpag('a');">
                                                                        <%if (cfg.isCartaFreteAutomaticaRomaneio() && acao.equals("iniciar")){
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
                                                            <td class="TextoCampos"><input name="cartaValorSaldo" type="text" id="cartaValorSaldo" value="0.00" size="6" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.00');alteraFpag('s');"></td>
                                                            <td class="TextoCampos"><input name="cartaDataSaldo" type="text" id="cartaDataSaldo" value="<%=(Apoio.getDataAtual())%>" class="fieldDate" onChange="javascript:alertInvalidDate(this);" size="9" maxlength="10" style="font-size:8pt;"></td>
                                                            <td class="TextoCampos">
                                                                <select name="cartaFPagSaldo" id="cartaFPagSaldo" class="fieldMin" style="width:70px;" onChange="javascript:alteraFpag('s');">
                                                                        <%if (cfg.isCartaFreteAutomaticaRomaneio() && acao.equalsIgnoreCase("iniciar")){%>
                                                                            <%=fpagCartaFrete%>
                                                                        <%}%>
                                                                </select>
                                                                <select name="favorecidoSaldo" id="favorecidoSaldo" class="fieldMin" style="width:70px;">
                                                                    <%if (Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == 'N'){%>
                                                                        <option value="t">Terceiro</option>
                                                                    <%}%>
                                                                    <option value="m">Motorista</option>
                                                                    <option value="p" selected>Proprietário</option>
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
                                                       
                                                        <tr id="trTarifas2" style="display: none">
                                                            <td class="TextoCampos">Adiantamento:</td>
                                                            <td class="TextoCampos"><input name="cartaValorTarifa" type="text" id="cartaValorTarifa" value="0.00" size="6" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.00');alteraFpag('s');" readonly="true"></td>
                                                            <td class="TextoCampos"><input name="cartaDataTarifa" type="text" id="cartaDataTarifa" value="<%=(Apoio.getDataAtual())%>" class="fieldDate" onChange="javascript:alertInvalidDate(this);" size="9" maxlength="10" style="font-size:8pt;" readonly="true"></td>
                                                            <td class="TextoCampos">
                                                                <select name="cartaFPagTarifa" id="cartaFPagTarifa" class="fieldMin" style="width:70px;" onChange="javascript:alteraFpag('s');" readonly="true">
                                                                        <%if (cfg.isCartaFreteAutomaticaRomaneio() && acao.equalsIgnoreCase("iniciar")){%>
                                                                            <%=fpagCartaFrete%>
                                                                        <%}%>
                                                                </select>
                                                                <select name="favorecidoTarifa" id="favorecidoTarifa" class="fieldMin" style="width:70px;" readonly="true">
                                                                    <%if (Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == 'N'){%>
                                                                        <option value="t">Terceiro</option>
                                                                    <%}%>
                                                                    <option value="m">Motorista</option>
                                                                    <option value="p" selected>Proprietário</option>
                                                                </select>
                                                            </td>  
                                                            <td class="TextoCampos">
                                                                <select name="contaTarifa" id="contaTarifa" class="fieldMin" style="width:120px;" readonly="true">
                                                                        <%if (cfg.isCartaFreteAutomaticaRomaneio() && acao.equals("iniciar")){
                                                                                    BeanConsultaConta contaAd = new BeanConsultaConta();
                                                                                    contaAd.setConexao(Apoio.getUsuario(request).getConexao());
                                                                                    contaAd.mostraContas(0, true, limitarUsuarioVisualizarConta, idUsuario);
                                                                                    ResultSet rsC = contaAd.getResultado();
                                                                                    while (rsC.next()){%>
                                                                                            <option value="<%=rsC.getString("idconta")%>"><%=rsC.getString("numero") +"-"+ rsC.getString("digito_conta") +" / "+ rsC.getString("banco")%></option>
                                                                                    <%}rsC.close();
                                                                            }%>
                                                                    </select>
                                                                    <input name="agenteTarifa" type="text" id="agenteTarifa" class="inputReadOnly8pt" size="14" readonly="true" value="" style="display:none">
                                                                    <input name="localiza_agente_Tarifa" type="button" class="botoes" id="localiza_agente_Tarifa" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=89','Agente','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');" style="display:none">
                                                                    <input name="idagenteTarifa" type="hidden" id="idagenteTarifa" class="inputReadOnly8pt" size="15" readonly="true" value="0">
                                                                    <input name="plano_agente_Tarifa" type="hidden" id="plano_agente_Tarifa" class="inputReadOnly8pt" size="15" readonly="true" value="0">
                                                                    <input name="und_agente_Tarifa" type="hidden" id="und_agente_Tarifa" class="inputReadOnly8pt" size="15" readonly="true" value="0">
                                                            </td>
                                                            <td class="CelulaZebra2"><input name="cartaDocTarifa" type="hidden" id="cartaDocTarifa" size="6" maxlength="12" class="fieldMin"></td>
                                                        </tr>
                                                                                                                    
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>    
                                    </td>
                                </tr>
                            </table>
                        </td>                      
                    </tr>
                </tbody>
            </table>
        </div>
        <div id="tab5">
                
                        <table width="98%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina" style='display: <%= carregarom && nivelUser == 4 ? "" : "none" %>'>

                                <%@include file="/gwTrans/template_auditoria.jsp" %>

                                <tr>
                                    <td colspan="7">
                                        <table width="100%"  border="0" cellspacing="1" cellpadding="2">
                                            <tr>
                                                <td width="15%" class="TextoCampos">Incluso:</td>
                                                <td width="35%" class="CelulaZebra2">Em: <%=(carregarom && rom.getDtLancamento() != null) ? fmt.format(rom.getDtLancamento()) : ""%>
                                                    <br>
                                                    Por: <%=(carregarom) ? rom.getUsuarioLancamento().getNome() : ""%></td>
                                                <td width="15%" class="TextoCampos">Alterado:</td>
                                                <td width="35%" class="CelulaZebra2">Em: <%=(carregarom && rom.getDtAlteracao() != null) ? fmt.format(rom.getDtAlteracao()) : ""%><br>
                                                    Por: <%=(carregarom && rom.getUsuarioAlteracao().getNome() != null) ? rom.getUsuarioAlteracao().getNome() : ""%> </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                                 
                    </div>                  
        <div id="tab6" style="display: none">
            <table width="98%" border="0" class="bordaFina">
                <tbody>
                    <tr>
                        <td colspan="7" class="tabela"><div align="center">Detalhes</div></td>
                    </tr>
                    <tr>
                        <td colspan="7">
                            <table width="100%" class="bordaFina">
                                <% if (carregarom) { %>
                                    <tr class="CelulaZebra2">
                                        <td width="20%">Status:</td>
                                        <td width="80%" colspan="3" style="font-weight: bold"><%= rom.getStatusEnvioRoteirizacao().getDescricao() %></td>
                                    </tr>
                                    <% if (rom.getStatusEnvioRoteirizacao() != TipoSincronizacaoRoteirizacao.PENDENTE) {%>
                                        <tr class="CelulaZebra2">
                                            <td width="20%">Usuário que enviou: </td>
                                            <td width="20%"><%= rom.getUsuarioEnvioRoteirizacao().getNome() %></td>
                                            <td width="20%">data e hora de envio: </td>
                                            <td width="20%"><%= rom.getDataHoraEnvioRoteirizacao().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")) %></td>
                                        </tr>
                                        <% if (rom.getStatusEnvioRoteirizacao() == TipoSincronizacaoRoteirizacao.SINCRONIZADO || rom.getStatusEnvioRoteirizacao() == TipoSincronizacaoRoteirizacao.CONFIRMADO) {%>
                                        <tr class="CelulaZebra2">
                                            <td width="20%">Usuário que sincronizou: </td>
                                            <td width="20%"><%= rom.getUsuarioSincronizadoRoteirizacao().getNome() %></td>
                                            <td width="20%">data e hora de sincronização: </td>
                                            <td width="20%"><%= rom.getDataHoraSincronizadoRoteirizacao().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")) %></td>
                                        </tr>
                                        <% } %>
                                        <% if (rom.getStatusEnvioRoteirizacao() == TipoSincronizacaoRoteirizacao.CONFIRMADO) {%>
                                            <tr class="CelulaZebra2">
                                                <td width="20%">Usuário que confirmou: </td>
                                                <td width="20%"><%= rom.getUsuarioConfirmacaoRoteirizacao().getNome() %></td>
                                                <td width="20%">data e hora de confirmação: </td>
                                                <td width="20%"><%= rom.getDataHoraConfirmacaoRoteirizacao().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")) %></td>
                                            </tr>
                                        <% } %>
                                    <% } %>
                                <% } %>
                            </table>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        <div id="tab7" style="display: none">
            <table width="98%" border="0" class="bordaFina">
                <tr class="tabela">
                    <td width="100%" colspan="8">
                        <div align="center">Iscas</div>
                    </td>
                </tr>
                <tr name="trIscas" id="trIscas">
                    <td colspan="8">
                        <input type="hidden" name="maxIsca" id="maxIsca" value="0">
                        <input type="hidden" id="numero_isca" value="">
                        <input type="hidden" id="idIscas" value="">
                        <table width="100%" border="0" class="bordaFina">
                            <tbody id="tbIscas" name="tbIscas">
                            <tr class="CelulaZebra2" >
                                <td width="1%"></td>
                                <td width="20%" align="left" style="font-weight:bold">Digite o Número da Isca e tecle Enter
                                    <input name="numIsca" id="numIsca" type="text" class="inputtexto" value="" maxlength="40" onkeyup="javascript:if (event.keyCode==13) addNewIsca()">
                                    <input id="btAddIsca" name="btAddIsca" type="button" class="botoes" value="Adicionar" onClick="addNewIsca();"></td>
                                <td width="12%" align="center"></td>
                                <td width="8%" align="center"></td>
                            </tr>
                            <tr class="CelulaZebra1" >
                                <td width="1%"></td>
                                <td width="20%" align="center">Isca</td>
                                <td width="12%" align="center">Data Saída</td>
                                <td width="8%" align="center">Data Chegada</td>
                            </tr>
                            </tbody>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
    </div>
    </form>
    <br>
    <table width="98%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
        <tr class="CelulaZebra2">
            <td colspan="7">
        <center>
            <%if (nivelUser >= 2) {%>
            <%if (carregarom && rom.getContratoFrete().getIdcartafrete() != 0 && !acao.equals("iniciar_baixa")) {%>
            Este romaneio já foi vinculado ao contrato de frete <%=rom.getContratoFrete().getIdcartafrete()%>. Alteração não permitida.
            <%} else if (acao.equals("iniciar_baixa")) {%>
            <input name="baixar" type="button" class="botoes" id="baixar" value="Baixar" onClick="tryRequestToServer(function(){baixar(<%=(rom != null ? rom.getIdRomaneio() : 0)%>)});">
            <%} else {%>
            <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salvar('<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>');});">
            <%}
                }%>
        </center>
    </td>
    </tr>
    </table>
       
</body>
</html>
