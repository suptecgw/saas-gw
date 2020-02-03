<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="nucleo.autorizacao.tipoautorizacao.TipoAutorizacao"%>
<%@page import="br.com.gwsistemas.viagem.descontoMotorista.ViagemDescontoMotorista"%>
<%@page import="java.util.GregorianCalendar"%>
<%@page import="java.util.Calendar"%>
<%@page import="conhecimento.duplicata.BeanDuplicata"%>
<%@page import="br.com.gwsistemas.conhecimento.ConhecimentoBO"%>
<%@page import="br.com.gwsistemas.abastecimento.bomba.Bomba"%>
<%@page import="br.com.gwsistemas.abastecimento.bomba.BombaBO"%>
<%@page import="br.com.gwsistemas.abastecimento.tanque.Tanque"%>
<%@page import="br.com.gwsistemas.abastecimento.tanque.TanqueBO"%>
<%@page import="br.com.gwsistemas.abastecimento.Abastecimento"%>
<%@page import="br.com.gwsistemas.veiculo.combustivel.Combustivel"%>
<%@page import="br.com.gwsistemas.veiculo.combustivel.CombustivelBO"%>
<%@page import="viagem.BeanViagemRota"%>
<%@page import="mov_banco.BeanCadMovBanco"%>
<%@page import="java.util.Collection"%>
<%@page import="usuario.BeanUsuario"%>
<%@ page contentType="text/html" language="java"
         import="nucleo.*, 
         viagem.*,
         java.text.SimpleDateFormat,
         java.util.Date,
         java.sql.ResultSet,
         java.net.*" %>

<script language="javascript" type="text/javascript" src="script/<%=Apoio.noCacheScript("mascaras.js")%>"></script>
<script language="javascript" src="script/<%=Apoio.noCacheScript("funcoes.js")%>" type=""></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("builder.js")%>"   type="text/javascript"></script>
<script language="JavaScript"  src="script/<%=Apoio.noCacheScript("prototype_1_7_2.js")%>" type="text/javascript"></script>
<script type="text/javascript" src="script/<%=Apoio.noCacheScript("fabtabulous.js")%>"></script>
<script language="JavaScript"  src="script/<%=Apoio.noCacheScript("jquery.js")%>" type="text/javascript"></script>
<script language="JavaScript"  src="script/<%=Apoio.noCacheScript("LogAcoesAuditoria.js")%>" type="text/javascript"></script>
<script src="${homePath}/script/funcoesTelaADV.js?v=${random.nextInt()}"></script>

<%
    BeanUsuario autenticado = Apoio.getUsuario(request);
    int nivelUserDesconto = (autenticado != null ? autenticado.getAcesso("lanviagemdescontomotorista") : 0);
    int nivelCtrc = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadconhecimento") : 0);
    int nivelUser = (autenticado != null ? autenticado.getAcesso("lanviagem") : 0);
    int nivelUserRota = (autenticado != null ? autenticado.getAcesso("cadrota") : 0);
    int nivelAlteraNumero = (autenticado != null ? autenticado.getAcesso("alteranumeroadv") : 0);
    int nivelAlteraValor = (autenticado != null ? autenticado.getAcesso("alteravalorabastecimento") : 0);
    if (autenticado == null || nivelUser == 0) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
    }
    int nivelUserDespesaFilial = (autenticado != null ? autenticado.getAcesso("landespfl") : 0);
    int nivelUserDespesaPrazo = (autenticado != null ? autenticado.getAcesso("landespesaviagemprazo") : 0);
    
    boolean limitarUsuarioAlterarContas = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
    boolean limitarUsuarioVisualizarContas = false;
    int idUsuario = Apoio.getUsuario(request).getIdusuario();
%>
<jsp:useBean id="cadviag" class="viagem.BeanCadViagem" />
<jsp:useBean id="viag" class="viagem.BeanViagem" />
<jsp:useBean id="mobileBO" class="br.com.gwsistemas.gwmobile.MobileBO" />

<%String acao = (request.getParameter("acao") == null || nivelUser == 0 ? "" : request.getParameter("acao"));
    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
    cadviag = new BeanCadViagem();
    cadviag.setConexao(Apoio.getUsuario(request).getConexao());
    cadviag.setExecutor(Apoio.getUsuario(request));
    boolean carregaViag = !(acao.equals("incluir") || acao.equals("atualizar") || acao.equals("iniciar"));
    String ctrcsId = "";
    String ctrcs = "";
    double totalCtrc = 0;
    BeanConfiguracao cfg = null;
    cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    
    //Carregando as configurações
    cfg.CarregaConfig();
    String dataAtual = fmt.format(new Date());
    BeanViagemRota percurso = null;
    Abastecimento abastecimento = null;

    if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar") || acao.equals("atualizar_baixado")
            || acao.equals("excluir") || acao.equals("baixar") || acao.equals("iniciarbaixa")
            || acao.equals("baixado") || acao.equals("excluirBaixa")) {

        if (acao.equals("editar") || acao.equals("iniciarbaixa") || acao.equals("baixado")) {
            cadviag.getViagem().setId(Apoio.parseInt(request.getParameter("id")));
            carregaViag = cadviag.LoadAllPropertys();
            viag = (carregaViag ? cadviag.getViagem() : null);
            for (int x = 0; x < viag.getCtrc().length; x++) {
                ctrcs += (ctrcs.equals("") ? viag.getCtrc()[x].getNumero() : "," + viag.getCtrc()[x].getNumero());
                ctrcsId += (ctrcsId.equals("") ? viag.getCtrc()[x].getId() : "," + viag.getCtrc()[x].getId());
                totalCtrc += viag.getCtrc()[x].getTotalReceita();
            }

            request.setAttribute("carregaViag", carregaViag);
            request.setAttribute("viagem", viag);
        } else if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir") || acao.equals("excluir") || acao.equals("atualizar_baixado")
                || acao.equals("baixar") || acao.equals("excluirBaixa"))) {
            //setando os atributos que nao podem ser setados dinamicamente(acoes: atualizar/incluir)
            if (acao.equals("atualizar") || acao.equals("incluir") || acao.equals("baixar") || acao.equals("atualizar_baixado")) {
                viag.setId(acao.equals("atualizar") || acao.equals("baixar") || acao.equals("atualizar_baixado") ? Apoio.parseInt(request.getParameter("id")) : 0);
                viag.getFilial().setIdfilial(Apoio.parseInt(request.getParameter("idfilial")));
                viag.setNumViagem(request.getParameter("numviagem"));
                viag.setSaidaEm(Apoio.paraDate(request.getParameter("saidaem")));
                viag.getMotorista().setIdmotorista(Apoio.parseInt(request.getParameter("idmotorista")));
                viag.getVeiculo().setIdveiculo(Apoio.parseInt(request.getParameter("veiculo_id")));
                viag.getCarreta().setIdveiculo(Apoio.parseInt(request.getParameter("idcarreta")));
                viag.getBiTrem().setIdveiculo(Apoio.parseInt(request.getParameter("idbitrem")));
                viag.setOrigem(request.getParameter("origem"));
                viag.setDestino(request.getParameter("destino"));
                viag.setObservacao(URLDecoder.decode(request.getParameter("observacao"), "UTF-8"));
                viag.setCancelada(Apoio.parseBoolean(request.getParameter("isCancelada")));
                viag.setMotivoCancelamento(URLDecoder.decode(request.getParameter("motivoCancelamento").trim(), "UTF-8"));
                viag.setValorPrevistoViagem(Apoio.parseDouble(request.getParameter("valorPrevistoViagem")));
                //Cavalo 
                viag.setKmSaida(Apoio.parseInt(request.getParameter("km_saida")));
                viag.setKmChegada(Apoio.parseInt(request.getParameter("kmChegada")));
                //Carreta
                viag.setKmSaidaCarreta(Apoio.parseInt(request.getParameter("Carreta_km_saida")));
                viag.setKmChegadaCarreta(Apoio.parseInt(request.getParameter("Carreta_kmChegada")));
                viag.getCarreta().setTipoControleKm(request.getParameter("car_tipo_controle_km"));
                //Bitrem
                viag.setKmSaidaBitrem(Apoio.parseInt(request.getParameter("Bitrem_km_saida")));
                viag.setKmChegadaBitrem(Apoio.parseInt(request.getParameter("Bitrem_kmChegada")));
                viag.getBiTrem().setTipoControleKm(request.getParameter("bi_tipo_controle_km"));
                
                viag.setAcrescimoComissaoMotorista(Apoio.parseDouble(request.getParameter("acrescimos")));
                // 18-11-2013 - Paulo
                viag.getAjudante1().setIdfornecedor(Apoio.parseInt(request.getParameter("idAjudante1")));
                viag.getAjudante2().setIdfornecedor(Apoio.parseInt(request.getParameter("idAjudante2")));
                viag.getAjudante1().setRazaosocial(request.getParameter("nomeAjudante1"));
                viag.getAjudante2().setRazaosocial(request.getParameter("nomeAjudante2"));
                
                viag.setPrevisaoRetornoEm(Apoio.paraDate(request.getParameter("previsaoRetornoEm")));
                
                // novos campos 14-03-2014
                viag.setQuantidadeDiariaMotorista(Apoio.parseInt(request.getParameter("quantidadeDiariaMotorista")));
                viag.setQuantidadeDiariaAjudante(Apoio.parseInt(request.getParameter("quantidadeDiariaAjudante")));
                viag.setQuantidadeDiariaAjudante2(Apoio.parseInt(request.getParameter("quantidadeDiariaAjudante2")));
                viag.setQuantidadePernoiteMotorista(Apoio.parseInt(request.getParameter("quantidadePernoiteMotorista")));
                viag.setQuantidadePernoiteAjudante(Apoio.parseInt(request.getParameter("quantidadePernoiteAjudante")));
                viag.setQuantidadePernoiteAjudante2(Apoio.parseInt(request.getParameter("quantidadePernoiteAjudante2")));
                viag.setQuantidadeAlimentacaoMotorista(Apoio.parseInt(request.getParameter("quantidadeAlimentacaoMotorista")));
                viag.setQuantidadeAlimentacaoAjudante(Apoio.parseInt(request.getParameter("quantidadeAlimentacaoAjudante")));
                viag.setQuantidadeAlimentacaoAjudante2(Apoio.parseInt(request.getParameter("quantidadeAlimentacaoAjudante2")));
                viag.setValorDiariaMotorista(Apoio.parseDouble(request.getParameter("diariaMotorista")));
                viag.setValorDiariaAjudante(Apoio.parseDouble(request.getParameter("diariaAjudante")));
                viag.setValorDiariaAjudante2(Apoio.parseDouble(request.getParameter("diariaAjudante2")));
                viag.setValorPernoiteMotorista(Apoio.parseDouble(request.getParameter("pernoiteMotorista")));
                viag.setValorPernoiteAjudante(Apoio.parseDouble(request.getParameter("pernoiteAjudante")));
                viag.setValorPernoiteAjudante2(Apoio.parseDouble(request.getParameter("pernoiteAjudante2")));
                viag.setValorAlimentacaoMotorista(Apoio.parseDouble(request.getParameter("alimentacaoMotorista")));
                viag.setValorAlimentacaoAjudante(Apoio.parseDouble(request.getParameter("alimentacaoAjudante")));
                viag.setValorAlimentacaoAjudante2(Apoio.parseDouble(request.getParameter("alimentacaoAjudante2")));
                viag.getFuncionario().setIdfornecedor(Apoio.parseInt(request.getParameter("idFuncionario")));
                viag.getFuncionario().setRazaosocial(request.getParameter("nomeFuncionario"));
                
                viag.setBaixada(false);

                // Rotas
                int maxRota = Apoio.parseInt(request.getParameter("maxRota"));
                for (int z = 0; z <= maxRota; z++) {
                    if (request.getParameter("idCidadeOrigem_" + z) != null) {
                        percurso = new BeanViagemRota();
                        percurso.setId(Apoio.parseInt(request.getParameter("idLancamento_" + z)));
                        percurso.getRota().setId(Apoio.parseInt(request.getParameter("idViagemRota_" + z)));
                        percurso.getRota().setDescricao(request.getParameter("rotaDescricao_" + z));
                        percurso.getCidadeOrigem().setIdcidade(Apoio.parseInt(request.getParameter("idCidadeOrigem_" + z)));
                        percurso.getCidadeDestino().setIdcidade(Apoio.parseInt(request.getParameter("idCidadeDestino_" + z)));
                        percurso.setObservacao(request.getParameter("observacaoRota_" + z));
                        percurso.setDataSaida(Apoio.paraDate(request.getParameter("rotaDataSaida"+z)));
                        percurso.setKmSaida(Apoio.parseInt(request.getParameter("rotaKmSaida" + z)));
                        percurso.setDataChegada(Apoio.paraDate(request.getParameter("rotaDataChegada"+z)));
                        percurso.setKmChegada(Apoio.parseInt(request.getParameter("rotaKmChegada" + z)));
                        percurso.getRota().setVlDiariaMotorista(Apoio.parseDouble(request.getParameter("diariaMotorista_" + z)));
                        percurso.getRota().setVlPernoiteMotorista(Apoio.parseDouble(request.getParameter("pernoiteMotorista_" + z)));
                        percurso.getRota().setVlAlimentacaoMotorista(Apoio.parseDouble(request.getParameter("alimentacaoMotorista_" + z)));
                        
                        viag.getRotas().add(percurso);
                    }
                }
                
                //Abastecimento
                int maxAbast = Apoio.parseInt(request.getParameter("maxAbast"));
                for (int z = 1; z <= maxAbast; z++) {
                    if (request.getParameter("veiculo_id") != null && request.getParameter("dtAbastecimento_" + z) != null) {
                        abastecimento = new Abastecimento();
                        abastecimento.setId(Apoio.parseInt(request.getParameter("idAbast_" + z)));
                        abastecimento.getMotorista().setIdmotorista(Apoio.parseInt(request.getParameter("idmotorista")));
                        abastecimento.getVeiculo().setIdveiculo(Apoio.parseInt(request.getParameter("veiculo_id")));
                        abastecimento.setAbastecimentoEm(Apoio.getFormatData(request.getParameter("dtAbastecimento_" + z)));
                        abastecimento.setCategoria(request.getParameter("listaCategoriaAbast_" + z));
                        
                        if(abastecimento.getCategoria() != null){
                            if(abastecimento.getCategoria().equals("pr")){
                            abastecimento.getTanque().setId(Apoio.parseInt(request.getParameter("listaTanqueAbast_" + z)));
                            abastecimento.getBomba().setId(Apoio.parseInt(request.getParameter("bombaAbast_" + z)));
                            }
                        }

                        abastecimento.setKm(Apoio.parseInt(request.getParameter("kmAbast_" + z)));
                        abastecimento.setHorimetro(Apoio.parseInt(request.getParameter("HorimetroAbast_" + z)));
                        abastecimento.getFornecedor().setIdfornecedor(Apoio.parseInt(request.getParameter("idFornecedorAbast_" + z)));
                        abastecimento.setNumComprovante(request.getParameter("comprovanteAbast_" + z));
                        abastecimento.getCombustivel().setId(Apoio.parseInt(request.getParameter("combustivelAbast_" + z)));
                        abastecimento.setQuantidade(Apoio.parseFloat(request.getParameter("quantidadeAbast_" + z)));
                        abastecimento.setValorLitro(Apoio.parseFloat(request.getParameter("valorLitroAbast_" + z)));
                        if(request.getParameter("encheuAbast_" + z) != null){
                            if(request.getParameter("encheuAbast_" + z).equals("encheu")){ 
                                abastecimento.setEncheu(true);                                             
                            }
                        }else{
                            abastecimento.setEncheu(false);
                        }

                        viag.getAbastecimento().add(abastecimento);
                    }
                }

                if (request.getParameter("saidaas") != null && !request.getParameter("saidaas").equals("")) {
                    viag.setSaidaAs(new SimpleDateFormat("HH:mm").parse(request.getParameter("saidaas")));
                }
                
                if(request.getParameter("previsaoRetornoAs") != null && !request.getParameter("previsaoRetornoAs").equals("")){
                    viag.setPrevisaoRetornoAs(new SimpleDateFormat("HH:mm").parse(request.getParameter("previsaoRetornoAs")));
                }
                
                //Preenchendo o array dos conhecimentos
                if (!request.getParameter("ctrcs").trim().equals("")) {
                    int qtdCtrc = request.getParameter("ctrcs").split(",").length;
                    BeanConhecimento[] arrayCtrcs = new BeanConhecimento[qtdCtrc];

                    for (int k = 0; k < qtdCtrc; ++k) {
                        BeanConhecimento ct = new BeanConhecimento();
                        ct.setId(Apoio.parseInt(request.getParameter("ctrcs").split(",")[k]));
                        arrayCtrcs[k] = ct;
                    }
                    
                    viag.setCtrc(arrayCtrcs);
                }
                //Preenchendo o array dos adiantamentos
                int qtdAdiant = Apoio.parseInt(request.getParameter("qtdAdiant"));
                int xy = 0;
                //Preenchendo o array dos mov_banco
                BeanMovBanco[] arBanco = new BeanMovBanco[(qtdAdiant == 0 ? 2 : (qtdAdiant * 2) + 2)];
                
                //Acerto do saldo
                boolean isAcerto = Apoio.parseBoolean(request.getParameter("isAcerto"));
                if (acao.equals("baixar")) {
                    float valorAcerto = Apoio.parseFloat(request.getParameter("valorAcertado"));
                    if (valorAcerto != 0) {
                        BeneficiarioViagem beneficiarioViagem = BeneficiarioViagem.obterBeneficiarioPorTipo(request.getParameter("selectBeneficiario"));
                        String mensagemHistorico = "";
                        
                        BeanMovBanco mb = new BeanMovBanco();
                        mb.getConta().setIdConta(Apoio.parseInt(isAcerto ? request.getParameter("idContaAdiant") : request.getParameter("contaAcerto")));
                        mb.setValor(valorAcerto * -1);
                        mb.setDtEntrada(fmt.parse(request.getParameter("acertoem")));
                        mb.setDtEmissao(fmt.parse(request.getParameter("acertoem")));
                        mb.getUsuario().setIdusuario(Apoio.getUsuario(request).getIdusuario());

                        switch (beneficiarioViagem) {
                            case AJUDANTE:
                                mensagemHistorico = (isAcerto ? "ACERTO" : "REEMBOLSO") + " DE VIAGEM AJUDANTE: " + request.getParameter("nomeAjudante1") + ", VIAGEM " + request.getParameter("numviagem");
                                break;
                            case FUNCIONARIO:
                                mensagemHistorico = (isAcerto ? "ACERTO" : "REEMBOLSO") + " DE VIAGEM FUNCIONÁRIO: " + request.getParameter("nomeFuncionario") + ", VIAGEM " + request.getParameter("numviagem");
                                break;
                            case MOTORISTA:
                            default:
                                mensagemHistorico = (isAcerto ? "ACERTO" : "REEMBOLSO") + " DE VIAGEM MOTORISTA: " + request.getParameter("motor_nome") + ", VIAGEM " + request.getParameter("numviagem");
                                break;
                        }

                        mb.setHistorico(mensagemHistorico);
                        mb.getHistorico_id().setIdHistorico(0);
                        if (isAcerto) { //se For um acerto
                            switch (beneficiarioViagem) {
                                case AJUDANTE:
                                    mb.getFuncionario().setIdfornecedor(Apoio.parseInt(request.getParameter("idAjudante1")));
                                    break;
                                case FUNCIONARIO:
                                    mb.getFuncionario().setIdfornecedor(Apoio.parseInt(request.getParameter("idFuncionario")));
                                    break;
                                case MOTORISTA:
                                default:
                                    mb.getMotorista().setIdmotorista(Apoio.parseInt(request.getParameter("idmotorista")));
                                    break;
                            }
                        } else {
                            mb.setCheque(Apoio.parseBoolean(request.getParameter("isReembolsoCheque")));
                        }
                        mb.setDocum(request.getParameter("docAcerto"));
                        if (mb.isCheque()) {
                            mb.setNominal(request.getParameter("motor_nome"));
                        }
                        mb.setTipo("t");
                        arBanco[xy++] = mb;
                        //Preechendo os dados do crédito
                        mb = new BeanMovBanco();
                        mb.getConta().setIdConta(Apoio.parseInt(isAcerto ? request.getParameter("contaAcerto") : request.getParameter("idContaAdiant")));
                        mb.setValor(valorAcerto);
                        mb.setDtEntrada(fmt.parse(request.getParameter("acertoem")));
                        mb.setDtEmissao(fmt.parse(request.getParameter("acertoem")));
                        mb.getUsuario().setIdusuario(Apoio.getUsuario(request).getIdusuario());
                        mb.setHistorico((isAcerto ? "ACERTO" : "REEMBOLSO") + " DE VIAGEM MOTORISTA: " + request.getParameter("motor_nome") + ", VIAGEM " + request.getParameter("numviagem"));
                        mb.getHistorico_id().setIdHistorico(0);
                        mb.setDocum(request.getParameter("docAcerto"));
                        if (mb.isCheque()) {
                            mb.setNominal(request.getParameter("motor_nome"));
                        }
                        if (!isAcerto) { //se não For um acerto
                            switch (beneficiarioViagem) {
                                case AJUDANTE:
                                    mb.getFuncionario().setIdfornecedor(Apoio.parseInt(request.getParameter("idAjudante1")));
                                    break;
                                case FUNCIONARIO:
                                    mb.getFuncionario().setIdfornecedor(Apoio.parseInt(request.getParameter("idFuncionario")));
                                    break;
                                case MOTORISTA:
                                default:
                                    mb.getMotorista().setIdmotorista(Apoio.parseInt(request.getParameter("idmotorista")));
                                    break;
                            }
                            mb.setReembolso(true);
                        }
                        mb.setTipo("t");
                        arBanco[xy++] = mb;
                    }
                }
                
                int qtdCtrc = 0;
                for(int i = 0; i<=qtdAdiant;i++){
                    if(request.getParameter("contaAdiant" + i) != null && request.getParameter("contaAdiant" + i).equals( "-1")){
                        qtdCtrc++;
                    }
                }    
                
                GregorianCalendar cal = (GregorianCalendar) Calendar.getInstance();
                cal.add(Calendar.MONTH, 1);
                BeanDuplicata dup;
                int proxCtrc = 0;
                for (int x = 0; x < qtdAdiant; ++x) {
                    if (request.getParameter("contaAdiant" + x) != null && Apoio.parseBoolean(request.getParameter("incluindo" + x))) {
                        BeanMovBanco mb;
                        BeneficiarioViagem beneficiarioViagem = BeneficiarioViagem.obterBeneficiarioPorTipo(request.getParameter("selectBeneficiario"));

                        //Preechendo os dados do débito
                        if(!request.getParameter("contaAdiant" + x).equals( "-1") ){
                            mb = new BeanMovBanco();

                            mb.setCheque(request.getParameter("usaCheque_" + x) != null ? true : false);
                            mb.getConta().setIdConta(Apoio.parseInt(request.getParameter("idContaDebito" + x)));
                            mb.setValor(Apoio.parseFloat(request.getParameter("valorAdiant" + x)) * -1);
                            mb.setDtEntrada(fmt.parse(request.getParameter("dataAdiant" + x)));
                            mb.setDtEmissao(fmt.parse(request.getParameter("dataAdiant" + x)));
                            mb.getUsuario().setIdusuario(Apoio.getUsuario(request).getIdusuario());
                            mb.setHistorico(request.getParameter("histAdiant" + x));
                            mb.getHistorico_id().setIdHistorico(0);
                            if (mb.isCheque()){
                                mb.setNominal(request.getParameter("motor_nome"));
                            }
                            if (cfg.isControlarTalonario() && mb.isCheque()) {
                                mb.setDocum(request.getParameter("docAdiant1_" + x));
                            } else {
                                mb.setDocum(request.getParameter("docAdiant" + x));
                            }
                        
                            mb.setTipo("t");
                            arBanco[xy++] = mb;
                            //Preechendo os dados do crédito
                            mb = new BeanMovBanco();
                            mb.setCheque(request.getParameter("usaCheque_" + x) != null ? true : false);
                            mb.getConta().setIdConta(Apoio.parseInt(request.getParameter("idContaAdiant")));
                            mb.setValor(Apoio.parseFloat(request.getParameter("valorAdiant" + x)));
                            mb.setDtEntrada(fmt.parse(request.getParameter("dataAdiant" + x)));
                            mb.setDtEmissao(fmt.parse(request.getParameter("dataAdiant" + x)));
                            mb.getUsuario().setIdusuario(Apoio.getUsuario(request).getIdusuario());
                            mb.setHistorico(request.getParameter("histAdiant" + x));
                            mb.getHistorico_id().setIdHistorico(0);

                            switch (beneficiarioViagem) {
                                case AJUDANTE:
                                    mb.getFuncionario().setIdfornecedor(Apoio.parseInt(request.getParameter("idAjudante1")));
                                    break;
                                case FUNCIONARIO:
                                    mb.getFuncionario().setIdfornecedor(Apoio.parseInt(request.getParameter("idFuncionario")));
                                    break;
                                case MOTORISTA:
                                default:
                                    mb.getMotorista().setIdmotorista(Apoio.parseInt(request.getParameter("idmotorista")));
                                    break;
                            }
                            if (cfg.isControlarTalonario() && mb.isCheque()) {
                                mb.setDocum(request.getParameter("docAdiant1_" + x));
                            } else {
                                mb.setDocum(request.getParameter("docAdiant" + x));
                            }
                       
                            mb.setTipo("t");
                            arBanco[xy++] = mb;
                        }else{
                            mb = new BeanMovBanco();
                            mb.setCheque(request.getParameter("usaCheque_" + x) != null ? true : false);
                            mb.getConta().setIdConta(Apoio.parseInt(request.getParameter("idContaAdiant")));
                            mb.setValor(Apoio.parseFloat(request.getParameter("valorAdiant" + x)));
                            mb.setDtEntrada(Apoio.paraDate(request.getParameter("dataAdiant" + x)));
                            mb.setDtEmissao(Apoio.paraDate(request.getParameter("dataAdiant" + x)));
                            mb.getUsuario().setIdusuario(Apoio.getUsuario(request).getIdusuario());
                            mb.setHistorico(request.getParameter("histAdiant" + x));
                            mb.getHistorico_id().setIdHistorico(0);
                            switch (beneficiarioViagem) {
                                case AJUDANTE:
                                    mb.getFuncionario().setIdfornecedor(Apoio.parseInt(request.getParameter("idAjudante1")));
                                    break;
                                case FUNCIONARIO:
                                    mb.getFuncionario().setIdfornecedor(Apoio.parseInt(request.getParameter("idFuncionario")));
                                    break;
                                case MOTORISTA:
                                default:
                                    mb.getMotorista().setIdmotorista(Apoio.parseInt(request.getParameter("idmotorista")));
                                    break;
                            }
                            if (cfg.isControlarTalonario() && mb.isCheque()) {
                                mb.setDocum(request.getParameter("docAdiant1_" + x));
                            } else {
                                mb.setDocum(request.getParameter("docAdiant" + x));
                            }
                            mb.setFreteViagemValor(Apoio.parseDouble(request.getParameter("valorCtrc" + x)));
                            mb.setFreteViagemAdiantamentoDinheiro(Apoio.parseDouble(request.getParameter("valorCtrcAdt" + x)));
                            mb.setFreteViagemAdiantamentoCheque(Apoio.parseDouble(request.getParameter("valorCtrcAdtCheque" + x)));
                            mb.setFreteViagemSaldoFinal(Apoio.parseDouble(request.getParameter("valorCtrcSaldo" + x)));
                            mb.setFreteViagemPeso(Apoio.parseDouble(request.getParameter("pesoCtrc" + x)));
                            mb.setTipo("r");
                          
                            
                            
                            BeanConhecimento ctrc = new BeanConhecimento();
                            ConhecimentoBO conBO = new ConhecimentoBO(Apoio.getUsuario(request));
                            
                            ctrc.setSerie("V");
                            ctrc.setEspecie("CTR");
                            ctrc.setTipoServico("n");
                            ctrc.setValorFrete(Apoio.parseFloat(request.getParameter("valorCtrc" + x)));
                            ctrc.setEmissaoEm(Apoio.getFormatData(request.getParameter("data_" + x)));
                            ctrc.getRemetente().setIdcliente(Apoio.parseInt(request.getParameter("idRemetente_" + x)));
                            ctrc.getDestinatario().setIdcliente(Apoio.parseInt(request.getParameter("idDestinatario_" + x)));
                            ctrc.getCliente().setIdcliente(Apoio.parseInt(request.getParameter("idRemetente_" + x)));                            
                            ctrc.getFilial().setIdfilial(Apoio.parseInt(request.getParameter("idfilial")));
                            ctrc.getMotorista().setIdmotorista(Apoio.parseInt(request.getParameter("idmotorista")));
                            ctrc.getVeiculo().setIdveiculo(Apoio.parseInt(request.getParameter("veiculo_id")));
                            ctrc.getCarreta().setIdveiculo(Apoio.parseInt(request.getParameter("idcarreta")));
                            ctrc.getBiTrem().setIdveiculo(Apoio.parseInt(request.getParameter("idbitrem")));
                            ctrc.getCidadeOrigem().setIdcidade(Apoio.parseInt(request.getParameter("idCidadeRemetente_" + x)));
                            ctrc.getCidadeDestino().setIdcidade(Apoio.parseInt(request.getParameter("idCidadeDestinatario_" + x)));
                            ctrc.setTipoFpag("p");
                            ctrc.setHistorico(request.getParameter("histAdiant" + x));
                            ctrc.setCfop(cfg.getCfopDefault());
                            ctrc.setCategoria("ct");
                            ctrc.setBaseCalculo(Apoio.parseFloat(request.getParameter("valorCtrc" + x)));
                            ctrc.setTipoTaxa(3);
                            ctrc.setTotalReceita(Apoio.parseDouble(request.getParameter("valorCtrc" + x)));  
                            ctrc.setAliquota(0);
                            ctrc.getTipoveiculo().setId(-1);
                            ctrc.setCreditoViagemTripId(Apoio.parseInt(request.getParameter("id")));
                            
                            int idxParcel = 1;
                            //Criando a primeira parcela do CTRC
                            double valorMov = Apoio.parseDouble(request.getParameter("valorCtrcAdt" + x));
                             if(valorMov > 0){ 
                                dup = new BeanDuplicata();
                                dup.setDuplicata(idxParcel);
                                dup.setDtvenc(new Date());
                                dup.setVlduplicata(valorMov);
                                dup.setVlpago(valorMov);
                                dup.setDtpago(new Date());
                                dup.setBaixado(true);
                                ctrc.setPago(true);
                                
                                ctrc.getDuplicatas().add(idxParcel-1, dup);
                                idxParcel++;
                            }

                            //Criando a segunda parcela do CTRC
                            valorMov = Apoio.parseDouble(request.getParameter("valorCtrcAdtCheque" + x));
                            if(valorMov > 0){
                                dup = new BeanDuplicata();
                                dup.setDuplicata(idxParcel);
                                dup.setDtvenc(new Date());
                                dup.setVlduplicata(valorMov);
                                
                                ctrc.getDuplicatas().add(idxParcel-1, dup);
                                idxParcel++;
                            }
                                                                                  
                            //Criando a terceira parcela do CTRC
                            valorMov = Apoio.parseDouble(request.getParameter("valorCtrcSaldo" + x));
                            if(valorMov > 0){
                                dup = new BeanDuplicata();
                                dup.setDuplicata(idxParcel);
                                dup.setDtvenc(cal.getTime());
                                dup.setVlduplicata(valorMov);
                                
                                ctrc.getDuplicatas().add(idxParcel-1, dup);
                            }
                            
                            if(proxCtrc == 0) {
                                proxCtrc = Apoio.parseInt(conBO.ProxCtrc(ctrc.getSerie(), ctrc.getEspecie(), ctrc.getFilial().getIdfilial(), ctrc.getAgencia().getId(), "").split("<=>")[0]);
                            }else {
                                proxCtrc++;
                            }

                            ctrc.setNumero(Apoio.repeatStr("0", 7 - ("" + proxCtrc).length()) + proxCtrc);
                            mb.setCtrc(ctrc);
                            
                            arBanco[xy++] = mb;
                        }
                    }
                }
                
                //se tiver baixando 
                if (acao.equals("baixar") || acao.equals("atualizar") || acao.equals("editar") || acao.equals("incluir")) {
                    viag.setBaixada(acao.equals("baixar") ? true : false);
                    if (Apoio.parseDouble(request.getParameter("saldoMotorista")) == 0) {
                        viag.setSaldoAnteriorZerado(true);
                    } else {
                        viag.setSaldoAnteriorZerado(false);
                    }
                    
                    viag.setChegadaEm((request.getParameter("chegadaem") == null ? null : Apoio.paraDate(request.getParameter("chegadaem"))));
                    if (request.getParameter("chegadaas") != null && !request.getParameter("chegadaas").equals("")) {
                        viag.setChegadaAs(new SimpleDateFormat("HH:mm").parse(request.getParameter("chegadaas")));
                    }
                    viag.setAcertoEm((request.getParameter("acertoem") == null ? null : Apoio.paraDate(request.getParameter("acertoem"))));
                    if (request.getParameter("acertoas") != null && !request.getParameter("acertoas").equals("")) {
                        viag.setAcertoAs(new SimpleDateFormat("HH:mm").parse(request.getParameter("acertoas")));
                    }
                    //Carregando as despesas
                    int qtdNotas = Apoio.parseInt(request.getParameter("qtdNotas"));
                    BeanDespesa[] dp = new BeanDespesa[qtdNotas];
                    for (int x = 0; x < qtdNotas; ++x) {
                        if (request.getParameter("tipoDesp" + x) != null && request.getParameter("idNota" + x).equals("0")) {
                            dp[x] = new BeanDespesa();
                            dp[x].getFilial().setIdfilial(Apoio.parseInt(request.getParameter("idfilial")));
                            dp[x].setAVista(request.getParameter("tipoDesp" + x).equals("a") ? true : false);
                            dp[x].getEspecie_().setId(Apoio.parseInt(request.getParameter("especie" + x)));
                            dp[x].setSerie(request.getParameter("serie" + x));
                            dp[x].setNfiscal(request.getParameter("nf" + x));
                            dp[x].setDtEmissao(Apoio.paraDate(request.getParameter("dataNota" + x)));
                            dp[x].setDtEntrada(Apoio.paraDate(request.getParameter("dataNota" + x)));
                            dp[x].setCompetencia(request.getParameter("dataNota" + x).substring(3, 10));
                            dp[x].getFornecedor().setIdfornecedor(Apoio.parseInt(request.getParameter("idfornecedor" + x)));
                            dp[x].getHistorico().setIdHistorico(Apoio.parseInt(request.getParameter("idhistoricoNota" + x)));
                            dp[x].setDescHistorico(request.getParameter("historicoNota" + x));
                            dp[x].setValor(Apoio.parseFloat(request.getParameter("valorNota" + x)));
                            dp[x].setComissaoMotorista(Apoio.parseBoolean(request.getParameter("isComissaoMotorista_" + x)));
                            //atribuindo as parcelas
                            BeanDuplDespesa[] du = new BeanDuplDespesa[1];
                            du[0] = new BeanDuplDespesa();
                            du[0].setDtvenc(Apoio.paraDate(request.getParameter("dataVenc" + x)));
                            du[0].setVlduplicata(Apoio.parseFloat(request.getParameter("valorNota" + x)));
                            //Caso o lançamento seja a vista
                            if (dp[x].isAVista()) {
                                du[0].setVlduplicata(Apoio.parseFloat(request.getParameter("valorNota" + x)));
                                du[0].setVlacrescimo(0);
                                du[0].setVldesconto(0);
                                du[0].getFpag().setIdFPag(1);
                                du[0].setVlpago(Apoio.parseFloat(request.getParameter("valorNota" + x)));
                                du[0].setDtpago(Apoio.paraDate(request.getParameter("dataNota" + x)));
                                du[0].getMovBanco().getConta().setIdConta(Apoio.parseInt(request.getParameter("idContaAdiant")));
                                du[0].getMovBanco().setValor(Apoio.parseFloat(request.getParameter("valorNota" + x)));
                                du[0].getMovBanco().setDtEntrada(Apoio.paraDate(request.getParameter("dataNota" + x)));
                                du[0].getMovBanco().setDtEmissao(Apoio.paraDate(request.getParameter("dataNota" + x)));
                                du[0].getMovBanco().setConciliado(true);
                                du[0].getMovBanco().getHistorico_id().setIdHistorico(Apoio.parseInt(request.getParameter("idhistoricoNota" + x)));
                                du[0].getMovBanco().setHistorico(request.getParameter("historicoNota" + x));
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
                                    ap[j].setDescricaoApropriacao(request.getParameter("descricao_plano_" + x + "_" + y));
                                    ap[j].setAbateDaComissaoMotoristaADV(request.getParameter("isAbateComissao_" + x + "_" + y) != null);
                                    j++;
                                }
                            }
                            dp[x].setApropriacoes(ap);
                        }
                    }
                    viag.setDespesa(dp);
                }//fim baixar
                cadviag.setArBanco(arBanco); //estou setando aqui porque na baixa poderá ter mais algum movimento na mov_banco
            }
            
            viag.setBeneficiario(BeneficiarioViagem.obterBeneficiarioPorTipo(request.getParameter("selectBeneficiario")));
            cadviag.setViagem(viag);
            cadviag.setExecutor(Apoio.getUsuario(request));
            boolean erro = false;
            String hashAutorizacao = "";
            if(!acao.equals("excluir")){
                //caso o usuario precise de autorizacao para salvar o manfiesto, vai ser gerado o hash.
                String cfgPermitirLancamentoOSAbertoVeiculo = request.getParameter("cfgPermitirLancamentoOSAbertoVeiculo");
                int miliSegundos = Apoio.parseInt(request.getParameter("miliSegundos"));
                boolean osAbertoVeiculo = Apoio.parseBoolean(request.getParameter("os_aberto_veiculo"));
                if (cfgPermitirLancamentoOSAbertoVeiculo.equals("PS") && osAbertoVeiculo && miliSegundos > 0) {
                    hashAutorizacao = Apoio.gerarHash(miliSegundos, cadviag.getViagem().getVeiculo().getIdveiculo(),0);
                }
            
            }
            
            if (acao.equals("atualizar")) {
                erro = !cadviag.Atualiza(hashAutorizacao);
            } else if (acao.equals("atualizar_baixado") && nivelUser >= 3) {
                erro = !cadviag.AtualizaBaixado();
            } else if (acao.equals("incluir") && nivelUser >= 3) {
                erro = !cadviag.Inclui(hashAutorizacao);
            } else if (acao.equals("baixar") && nivelUser >= 2) {
                erro = !cadviag.Baixar();
            } else if (acao.equals("excluir") && nivelUser >= 4) {
                viag.setId(Apoio.parseInt(request.getParameter("id")));
                cadviag.setViagem(viag);
                erro = !cadviag.Deleta(); 
            } else if (acao.equals("excluirBaixa") && nivelUser >= 4) {
                viag.setId(Apoio.parseInt(request.getParameter("id")));
                cadviag.setViagem(viag);
                erro = !cadviag.ExcluirBaixa();
            }
            if(acao.equals("excluir")){
                %><script language="javascript"><%
                    if (cadviag.getErros().indexOf("advancing_drivers_trip_id_fkey") > -1) {
                        %>
                            alert("Erro ao excluir, existe adiantamentos ou despesas lançadas na viagem!");
                            location.replace("./consulta_viagem.jsp?acao=iniciar");
                        <%    
                    }else if(cadviag.getErros().indexOf("credito_viagem_trip_id_fkey") > -1){
                        %>
                            alert("Erro ao excluir, existe minuta(s) lançadas na viagem!");
                            location.replace("./consulta_viagem.jsp?acao=iniciar");
                        <%  
                    }else{
                        response.sendRedirect("./consulta_viagem.jsp?acao=iniciar");
                    }
                %></script><%
            }

            // EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
            if (!acao.equals("excluir")) {
                String scr = "";
                if (erro) {
                    if (acao.equals("baixar")){
                        scr = "<script>"
                            + "window.opener.document.getElementById('baixar').disabled = false;"
                            + "window.opener.document.getElementById('baixar').value = 'Salvar';";
                    }else{
                        scr = "<script>"
                            + "window.opener.document.getElementById('salvar').disabled = false;"
                            + "window.opener.document.getElementById('salvar').value = 'Salvar';";
                    }
                    if (cadviag.getErros().indexOf("trips_numviagem_key") > 0) {
                        String suggestId = cadviag.getProximaViagem();
                        scr += "if (confirm('A viagem " + cadviag.getViagem().getNumViagem() + " já existe. \\n "
                                + "Deseja que o sistema crie com o número" + suggestId + "?')){"
                                + "window.opener.document.getElementById('numviagem').value = '" + suggestId + "';"
                                + "window.opener.document.getElementById('salvar').onclick();"
                                + "}";

                    }else if(cadviag.getErros().indexOf("fk_conta") > -1) {
                        scr += "alert('" + "ATENÇÃO: Antes de realizar essa operação, Selecione a conta padrão para controle de adiantamento de viagens configurada em configurações." + "');";
                    }else if(cadviag.getErros().indexOf("viagem_autorizacao_liberacao_hash_fkey") > -1){
                        scr += "alert('"+"ATENÇÃO: A inclusão do veículo não foi liberada e existe OS em aberto para o mesmo. Para utilizá-lo é preciso da autorização do supervisor."+"');";
                    }else {
                        scr += "alert('" + cadviag.getErros() + "');";
                    }
                    scr += "window.close();"
                            + "</script>";
                    acao = (acao.equals("atualizar") ? "editar" : "iniciar");
                } else {// <-- Se nao teve erro redirecione para a consulta
                    scr = "<script>"
                            + "window.opener.document.location.replace('./consulta_viagem.jsp?acao=iniciar');"
                            + "window.close();"
                            + "</script>";
                }
                response.getWriter().append(scr);
                response.getWriter().close();
            }
        }//acao de atualizar ou incluir
    }//não esta sendo usado
    
    Collection<Combustivel> listaComb = null;
    Collection<Tanque> listaTanque = null;
    Collection<Bomba> listaBomba = null;
    
    if(acao.equals("iniciar") || acao.equals("editar") || acao.equals("iniciarbaixa") || acao.equals("baixado")){
        CombustivelBO combustivelBO = new CombustivelBO();
        listaComb = combustivelBO.mostrarTodos((acao.equals("iniciar")?0:viag.getVeiculo().getIdveiculo()));
        
        TanqueBO tanqueBO = new TanqueBO();
        listaTanque = tanqueBO.mostrarTodos();
        
        BombaBO bombaBO = new BombaBO();
        listaBomba = bombaBO.mostrarTodos();
    }

    if (acao.equals("excluirRota")) {
        int id = Apoio.parseInt(request.getParameter("idRota"));
        int idTrip = Apoio.parseInt(request.getParameter("idTrip"));
        cadviag.DeletaRota(id, idTrip);
    }
    
    if (acao.equals("excluirAbastecimento")) {
        int id = Apoio.parseInt(request.getParameter("idAbastecimento"));
        int idTrip = Apoio.parseInt(request.getParameter("idTrip"));
        cadviag.DeletaAbastecimento(id, idTrip);
    }
    
    if (acao.equals("proxCheque")) {
        String setor = request.getParameter("setor") == null ? "" : request.getParameter("setor");;
        setor = "o";
        if (cfg.isControlarTalonario()) {
//            ConsultaTalaoCheque tc = new ConsultaTalaoCheque();
//
//            tc.setConexao(Apoio.getUsuario(request).getConexao());
//            int idConta = request.getParameter("idConta") != null ? Apoio.parseInt(request.getParameter("idConta")) : cfg.getConta_padrao_id().getIdConta();
//
//            Collection<TalaoCheque> lista = new ArrayList<TalaoCheque>();
//            tc.consultarDoc(idConta, Apoio.getUsuario(request).getFilial().getIdfilial(), setor, Apoio.getUsuario(request));
//            ResultSet rsCT1 = tc.getResultado();
//
//            TalaoCheque talaoCheque = null;
//            while (rsCT1.next()) {
//                talaoCheque = new TalaoCheque();
//                talaoCheque.setNumeroInicial(rsCT1.getString("docum"));
//                lista.add(talaoCheque);
//            }
//
//            XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
//            xstream.setMode(XStream.NO_REFERENCES);
//            xstream.alias("talaoCheque", TalaoCheque.class);
//            String json = xstream.toXML(lista);
//            response.getWriter().append(json);
        } else {
            BeanCadMovBanco movBanco = new BeanCadMovBanco();
            movBanco.setConexao(Apoio.getUsuario(request).getConexao());
            String resultado = movBanco.getProxCheque(Apoio.parseInt(request.getParameter("idConta")));
            response.getWriter().append(resultado);
        }
        response.getWriter().close();
    }
%>

<script language="javascript" type="text/javascript">
    var homePath = '${homePath}';

    jQuery.noConflict();
    var indexAdiant = 0;
    var indexCtrc = 0;
    var indexNotes = 0;
    var indexApp = 0;
    var dataAtual = '<%=dataAtual%>';
    var totAcerto = 0;
    
    function novoVal(index){
        $("valorCtrc" + index).value = parseFloat($("valorCtrcAdt" + index).value) + parseFloat($("valorCtrcSaldo" + index).value) + parseFloat($("valorCtrcAdtCheque" + index).value);
    }

    function prepararAddComissao(){
		if (parseFloat($("valorAPagar").value) != 0){
			if (getIndexDespesaComissao() == 0) {
				addNotes(0,'','','','','','','<%=(carregaViag ? viag.getVeiculo().getIdproprietario() : "0")%>'
                                ,'<%=(carregaViag ? viag.getVeiculo().getNomeproprietario() : "")%>',0,'Pagamento de Comissao do Motorista ' + '<%=(carregaViag ? viag.getMotorista().getNome() : "")%>',$("valorAPagar").value,true); 
                                
				addApropriacao(getIndexDespesaComissao(),
                                 '<%= cfg.getPlanoCustoComissaoMotorista().getIdconta()%>'
                                 ,'<%= cfg.getPlanoCustoComissaoMotorista().getConta()%>',//3
                                 '<%= cfg.getPlanoCustoComissaoMotorista().getDescricao()%>'//4
                                ,'<%=(carregaViag ? String.valueOf(viag.getVeiculo().getIdveiculo()) : "0")%>',//5
                                 '<%=(carregaViag ? String.valueOf(viag.getVeiculo().getPlaca()) : "")%>'//6
                                ,$("valorAPagar").value,//7
                                '',//8
                                0,'','',false,'','');
                        
			}else{
			    var xy = getIndexDespesaComissao();
				for (f=0; f < indexApp; f++){
					if($('idApropriacao_'+xy+'_'+f) != null){
						$('valorApp_'+xy+'_'+f).value = $("valorAPagar").value;
					}
				}	
			}
			totalNota(getIndexDespesaComissao());
		}	
    }

    function alteraValor(index){
        $("valorCtrcAdt" + index).value = $("valorAdiant" + index).value;
    }
    
    //Função para não deixar digitar nada além de números
    function numeros(count){
        var campo = $("comprovanteAbast_"+count);
        if (isNaN(campo.value )){
            campo.value = campo.value.substr( 0 , campo.value.length - 1 );
        }
    }
    
    function excluirAbastecimento(index){
        var id = $("idAbast_"+index).value;
        var idTrip = <%= viag.getId() %>;
        if(confirm("Deseja excluir o Abastecimento ?")){
            if(confirm("Tem certeza?")){
                Element.remove($("tr2_"+index));
                
                valorTotalAbastecimento();
                
                if (id != 0) {
                    new Ajax.Request("./cadviagem.jsp?acao=excluirAbastecimento&idAbastecimento="+id+"&idTrip="+idTrip,
                    {
                        method:'get',
                        onSuccess: function(){ alert('Item removido com sucesso!') },
                        onFailure: function(){ alert('Something went wrong...') }
                    });     
                }
            }
        }
    }
    
    function abrirLocalizarFornecedor(linha){
       document.getElementById("linha").value = linha;
       launchPopupLocate('./localiza?acao=consultar&idlista=21','newFornecedor');
    }
    
    function adicionaAbastecimento(){
        var idVeiculo = $("idveiculo").value;
        var veiculo = "";
        
        if(idVeiculo == 0){
            alert("Selecione o Veículo primeiro!");
        }else{
            addAbastecimento('${dataAtual}', 'vi', '','','1,000','0','true','0,000','0','','','','0','0','0');
        }        
    }
    
    //Caluclar duplicata de talão de cheque
    function calcularTalaoCheque(index){
        var maxAdiantamento = $("maxAdiantamento").value;
        var adiantamento = $("docAdiant1_"+index).value;
                for (i = 0; i <= maxAdiantamento; i++) {
                    if(adiantamento != 0){
                        if(i != index){
                            if(adiantamento == $("docAdiant1_"+i).value){
                                $("docAdiant1_"+index).value = "0";
                                alert("Você não pode fazer duas despesas com o mesmo talão! " );
                                }
                            }
                        }
                    }
     }
    

    function aoCarregar(){
        $("descontoMotorista").style.display = "none";
        
        if (<%=carregaViag%>){
            addCtrc('<%=ctrcsId%>','<%=ctrcs%>','');
            <%
            for (int x = 0; x < viag.getMovBanco().length; x++) {
                    if (x == 0) {%>
                        $('saldoMotorista').value = formatoMoeda(<%=viag.getMovBanco()[x].getSaldoAnterior()%>);
                    <%}%>
                // 21 paremetros em addAdiantamento
                addAdiantamento('<%=fmt.format(viag.getMovBanco()[x].getDtEntrada())%>', <%=viag.getMovBanco()[x].getValor()%>, '<%=viag.getMovBanco()[x].getHistorico()%>', '<%=viag.getMovBanco()[x].getDocum()%>',<%=viag.getMovBanco()[x].getConta().getIdConta()%>,false,<%=viag.getMovBanco()[x].getIdLancamento()%>, <%=viag.getMovBanco()[x].isCheque()%>, '<%=(viag.getMovBanco()[x].getCtrc().getEmissaoEm() == null ? "" : fmt.format(viag.getMovBanco()[x].getCtrc().getEmissaoEm()))%>', '<%=viag.getMovBanco()[x].getCtrc().getValorFrete()%>', '<%=viag.getMovBanco()[x].getCtrc().getDestinatario().getIdcliente()%>','<%=viag.getMovBanco()[x].getCtrc().getDestinatario().getRazaosocial()%>','<%=viag.getMovBanco()[x].getCtrc().getRemetente().getIdcliente()%>','<%=viag.getMovBanco()[x].getCtrc().getRemetente().getRazaosocial()%>', 
                                <%=viag.getMovBanco()[x].getFreteViagemValor()%>, <%=viag.getMovBanco()[x].getFreteViagemAdiantamentoDinheiro()%>,
                                <%=viag.getMovBanco()[x].getFreteViagemAdiantamentoCheque()%>, <%=viag.getMovBanco()[x].getFreteViagemSaldoFinal()%>, <%=viag.getMovBanco()[x].getFreteViagemPeso()%>, '<%=viag.getMovBanco()[x].getConta().getDescricao()%>',<%=viag.getMovBanco()[x].isSincronizadoMobile()%>, <%=viag.getMovBanco()[x].isOrigemMobile()%>);
            <%}%>
                
            totalAdiantamento();
            <%if (acao.equals("iniciarbaixa") || acao.equals("baixado") || acao.equals("editar")) {
                    BeanDespesa d = new BeanDespesa();
                    BeanApropDespesa ap = new BeanApropDespesa();
                    for (int x = 0; x < viag.getDespesa().length; x++) {
                        d = viag.getDespesa()[x];
                                    
                        boolean comissao_motorista;
                        comissao_motorista = d.isComissaoMotorista();
                        %>
                        addNotes(<%=d.getIdmovimento()%>,'<%=(d.isAVista() ? 'a' : 'p')%>','<%=d.getEspecie_().getId()%>', '<%=d.getSerie()%>', '<%=d.getNfiscal()%>', '<%=fmt.format(d.getDtEmissao())%>','<%= d.getDuplicatas()[0].getDtvenc()!= null ? (fmt.format(d.getDuplicatas()[0].getDtvenc())) : "" %>',<%=d.getFornecedor().getIdfornecedor()%>,'<%=d.getCompetencia()%>',<%=d.getHistorico().getIdhistorico()%>,'<%=d.getDescHistorico()%>',<%=d.getValor()%>,<%=comissao_motorista%>, <%=d.isOrigemGwmobile()%>);

                        <%for (int y = 0; y < viag.getDespesa()[x].getApropriacoes().length; y++) {
                                ap = viag.getDespesa()[x].getApropriacoes()[y];%>
                                addApropriacao(indexNotes - 1, <%=ap.getPlanocusto().getIdconta()%>, '<%=ap.getPlanocusto().getConta()%>', '<%=ap.getPlanocusto().getDescricao()%>', <%=ap.getVeiculo().getIdveiculo()%>, '<%=ap.getVeiculo().getPlaca()%>', <%=ap.getValor()%>, false, <%=ap.getUndCusto().getId()%>, '<%=ap.getUndCusto().getSigla()%>', '<%=ap.getDescricaoApropriacao()%>', <%=ap.isAbateDaComissaoMotoristaADV()%>,'','');
                        <%}
                    }%>
                totalDespesasAvista();
                totalAcerto();
            <%}%>

            var rota = null;

            <%for (BeanViagemRota perc : viag.getRotas()) {%>
                    rota = new ViagemRota();
                    rota.idViagemRota = "<%=perc.getRota().getId()%>";
                    rota.idLancamento = "<%=perc.getId()%>";
                    rota.rotaDescricao = "<%=perc.getRota().getDescricao()%>";
                    rota.idCidadeOrigem = "<%=perc.getCidadeOrigem().getIdcidade()%>";
                    rota.cidadeOrigem = "<%=perc.getCidadeOrigem().getDescricaoCidade()%>";
                    rota.ufOrigem = "<%=perc.getCidadeOrigem().getUf()%>";
                    rota.idCidadeDestino = "<%=perc.getCidadeDestino().getIdcidade()%>";
                    rota.cidadeDestino = "<%=perc.getCidadeDestino().getDescricaoCidade()%>";
                    rota.ufDestino = "<%=perc.getCidadeDestino().getUf()%>";
                    rota.observacaoRota = "<%=perc.getObservacao()%>";
                    rota.dataSaida = "<%= (perc.getDataSaida() !=  null) ? Apoio.getFormatData(perc.getDataSaida(), "dd/MM/yyyy") : "" %>";
                    rota.kmSaida = "<%= perc.getKmSaida() %>";
                    rota.dataChegada = "<%=  (perc.getDataChegada() != null) ? Apoio.getFormatData(perc.getDataChegada(), "dd/MM/yyyy"): "" %>";
                    rota.kmChegada = "<%= perc.getKmChegada() %>";
                    rota.diariaMotoristaAtualRota = "<%= perc.getRota().getVlDiariaMotorista() %>";
                    rota.pernoiteMotoristaAtualRota = "<%= perc.getRota().getVlPernoiteMotorista() %>";
                    rota.alimentacaoMotoristaAtualRota = "<%= perc.getRota().getVlAlimentacaoMotorista() %>";
                    addViagemRota(rota);
            <%}%>
                
            var abastecimento = null;

            <%for (Abastecimento abaste : viag.getAbastecimento()) {%>
                    abastecimento = new ViagemAbastecimento();
                    abastecimento.dtAbastecimento = "<%=fmt.format(abaste.getAbastecimentoEm())%>";
                    abastecimento.categoria = "<%=abaste.getCategoria()%>";
                    abastecimento.tanque = "<%=abaste.getTanque().getId()%>";
                    abastecimento.bomba = "<%=abaste.getBomba().getId()%>";
                    abastecimento.quantidade = "<%=abaste.getQuantidade()%>";
                    abastecimento.km = "<%=abaste.getKm()%>";
                    abastecimento.encheu = "<%=abaste.isEncheu()%>";
                    abastecimento.valorLitro = "<%=abaste.getValorLitro()%>";
                    abastecimento.idFornecedor = "<%=abaste.getFornecedor().getIdfornecedor()%>";
                    abastecimento.fornecedor = "<%=abaste.getFornecedor().getRazaosocial()%>";
                    abastecimento.comprovante = "<%=abaste.getNumComprovante()%>";
                    abastecimento.combustivel = "<%=abaste.getCombustivel().getId()%>";
                    abastecimento.id = "<%=abaste.getId()%>";
                    abastecimento.veiculoId = "<%=abaste.getVeiculo().getIdveiculo()%>";
                    abastecimento.horimetro = "<%=abaste.getHorimetro()%>";                    
                    abastecimento.media = "<%=abaste.getMedia()%>";
                    abastecimento.isOrigemMobile = <%=abaste.getOrigemMobile()%>;
                    addAbastecimento(abastecimento);
            <%}%>
                    calcularTotalMedia(countAbast);
                
                  
            var desc = null;
                        
            <%for (ViagemDescontoMotorista desconto : viag.getDesconto()) {%>
                    desc = new ViagemDescontoMotorista();
                    desc.idViagemDescontoMotorista = "<%=desconto.getId()%>";
                    desc.idPlanoCusto = "<%=desconto.getPlanoCusto().getIdconta()%>";
                    desc.descricaoPlanoCusto = "<%=desconto.getPlanoCusto().getDescricao()%>";
                    desc.valor = formatoMoeda("<%=desconto.getValor()%>");
                    desc.historico = "<%=desconto.getHistorico()%>";
                    
                    addDesconto(desc);
            <%}%>
                         
            if('<%=viag.getDesconto()%>'.length != "2"){
                $("descontoMotorista").style.display = "";
            }
            calcularTotalPlano();
            if($("valorCtrcAdt0") != null){
            escondeAdiantamentoMotorista();
            }
         }
    }
    
    function escondeAdiantamentoMotorista(){
        var index = $("maxAdiantamento").value;
        for (var i = 0; i <= index; i++) {
            if($("valorCtrcAdt"+i).value != "0,00" || $("valorCtrcAdtCheque"+i).value != "0,00"){
                $("valorCtrcAdt"+i).readOnly = true;
                $("valorCtrcAdt"+i).className = "inputReadOnly";
                $("valorCtrcAdtCheque"+i).readOnly = true;
                $("valorCtrcAdtCheque"+i).className = "inputReadOnly";
            }
        }
    }

    function isValidaKm(){
        var kmSai = $('km_saida').value;
        var kmEnt = $('kmChegada').value;
        var rtn = true;
        //o setor analise disse para verificar apenas o cavalo.
        if (<%= cfg.isObrigaKmChegadaAdv() %>) {
            //Cavalo : 
            if (kmSai != 0 && kmEnt != 0){
                if (parseFloat(kmSai) > parseFloat(kmEnt)){
                    alert('KM de Chegada do Cavalo Não Pode ser Menor que o KM de Saída!');
                    rtn = false;
                }
            }
        }
        //Carreta : 
        kmSai = $("Carreta_km_saida").value;
        kmEnt = $("Carreta_kmChegada").value;
        if (kmSai != 0 && kmEnt != 0){
            if (parseFloat(kmSai) > parseFloat(kmEnt)){
                alert('KM de Chegada da Carreta Não Pode ser Menor que o KM de Saída!');
                rtn = false;
            }
        }
        kmSai = $("Bitrem_km_saida").value;
        kmEnt = $("Bitrem_kmChegada").value;
        //Bitrem :
        if (kmSai != 0 && kmEnt != 0){
            if (parseFloat(kmSai) > parseFloat(kmEnt)){
                alert('KM de Chegada do Bitrem Não Pode ser Menor que o KM de Saída!');
                rtn = false;
            }
        }
      return rtn;
    }

    function salvar(acao){
        
        var abas = $("maxAbast").value;
        var adia = $("maxAdiantamento").value;
        
        for(var j = 1; j<= abas;j++){
            if($("dtAbastecimento_" + j) != null){
                if($("dtAbastecimento_" + j).value == ""){
                    alert("A Data do Abastecimento Não pode ser Vazia!");
                    return false;
                }
            }
            
            if($("combustivelAbast_" + j) != null){
                if($("combustivelAbast_" + j).value == "0"){
                    alert("Selecione um Combustível!");
                    return false;
                }
            }
        }
        
		if (acao != 'atualizar_baixado'){
			for(var j = 0; j<= adia;j++){
                           if ($("incluindo"+j) != null && ($("incluindo"+j).value == true || $("incluindo"+j).value == 'true')){
    				if($("data_" + j) != null){
					if($("data_" + j).value == "" && $("contaAdiant" + j).value == "-1"){
						alert("A Data do Adiantamento Não pode ser Vazia!");
						return false;
					}
				}
				
				if($("idRemetente_" + j) != null){
					if($("idRemetente_" + j).value == "0" && $("contaAdiant" + j).value == "-1"){
						alert("Selecione o Remetente no Adiantamento!");
						return false;
					}
				}
				
				if($("idDestinatario_" + j) != null){
					if($("idDestinatario_" + j).value == "0" && $("contaAdiant" + j).value == "-1"){
						alert("Selecione o Destinatário no Adiantamento!");
						return false;
					}
				}
                           }
			}
		}
        
        if($("cancelado").checked && $("motivoCancelamento").value.trim() == ""){
            alert("Informe o Motivo do Cancelamento da Viagem !");
            return false;
        }
        
        if (($('selectBeneficiario').value === 'm') && (!isValidaKm())){
                return false;
        }

            if (acao != 'atualizar_baixado'){
                for (var i = 0 ;i <= indexAdiant; i++){
                    if ($("contaAdiant"+i) != null && ($("incluindo"+i).value == true || $("incluindo"+i).value == 'true')){
                        if ($("contaAdiant"+i).value == "0"){
                            return alert("Ao Incluir o Adiantamento deve ser Informada a Conta!");
                            habilitar($('usaCheque_'+i));
                        }
                        if (parseFloat($("valorAdiant"+i).value) == 0 ){ //&& $("contaAdiant"+i).value != "-1" // retirei a conta da validação pois mesmo criando duplicata a trigger bloqueia
                            return alert("Ao Incluir o Adiantamento o Valor Deverá ser Informado!");
                        }
                        if($('usaCheque_'+i).checked && ((<%=cfg.isControlarTalonario()%> && $("docAdiant1_"+i).value=="") || (<%=!cfg.isControlarTalonario()%> && $("docAdiant"+i).value=="")) && acao !="atualizar"){
                            alert("Informe o Documento!")
                            return false;
                        }
                        if($("contaAdiant"+i).value == "-1"){
                            if(roundABNT(parseFloat($("valorAdiant"+i).value),2) != roundABNT(parseFloat($("valorCtrcAdt"+i).value),2) && 
                               roundABNT(parseFloat($("valorAdiant"+i).value),2) != roundABNT(parseFloat($("valorCtrcAdtCheque"+i).value),2)){
                                return alert("Atenção! Ao incluir um Crédito Viagem Retorno, Valor do Crédito deve ser igual ao valor em Dinheiro ou em Cheque!");
                            }
                        }
                    }	
                }
            }	

        //Validando as rotas
        var l = $("maxRota").value;
        for (var ii = 0 ;ii <= l; ii++){
            if ($("idCidadeOrigem_" + ii) != null){
                if ($("idCidadeOrigem_" + ii).value == '0'){
                    alert("Informe a Cidade Origem da Rota Corretamente!");
                    return false;
                }
                if ($("idCidadeDestino_" + ii).value == '0'){
                    alert("Informe a Cidade Destino da Rota Corretamente!");
                    return false;
                }
            }
        }
        //não tava validando o null quando vem tipo string - Cassimiro
        for (var qtdAdian = 0; qtdAdian <= indexAdiant; qtdAdian++) {
            if ($("histAdiant"+qtdAdian) == null && $("histAdiant"+qtdAdian) == "null" && $("histAdiant"+qtdAdian).value == "") {
                return alert("O 'Histórico do Adiantamento' não pode ficar em branco!");
            }
        }
        
        for (var qtdNotas = 0; qtdNotas < indexNotes; qtdNotas++) {
            
            if ($("idfornecedor"+qtdNotas) != undefined && $("idfornecedor"+qtdNotas).value == 0) {
                return alert("O 'Fornecedor' não pode ficar em branco!");
            }else if($("historicoNota"+qtdNotas) != undefined && $("historicoNota"+qtdNotas).value == ''){
                return alert("O 'Histórico da despesa' não pode ficar em branco!");            
            }
            
            for (var qtdAprop = 0; qtdAprop < indexApp; qtdAprop++) {
                if ($("idApropriacao_"+qtdNotas+"_"+qtdAprop) != null || $("idApropriacao_"+qtdNotas+"_"+qtdAprop) != undefined) {
                    if ($("idApropriacao_"+qtdNotas+"_"+qtdAprop).value == '' || $("idApropriacao_"+qtdNotas+"_"+qtdAprop).value == 0) {
                        return alert("O 'Plano de custo' não pode ficar em branco!");    
                    }
                }    
                if ($("idUnd_"+qtdNotas+"_"+qtdAprop) != null || $("idUnd_"+qtdNotas+"_"+qtdAprop) != undefined) {
                    if ($("idUnd_"+qtdNotas+"_"+qtdAprop).value == '' || $("idUnd_"+qtdNotas+"_"+qtdAprop).value == 0) {
                        return alert("O 'Unidade de custo' não pode ficar em branco!");    
                    }
                }                    
            }        
        }

        if (wasNull("numviagem")) {
            return alert("Preencha o Número da Viagem Corretamente!");
        } else if (! validaData($("saidaem").value)) {
            return alert("Data de Saída Incorreta. Formato correto: dd/MM/yyyy");
        } else if ($('selectBeneficiario').value === 'm' && $("idmotorista").value == '0') {
            return alert("Informe o Motorista Corretamente!");
        } else if ($('selectBeneficiario').value === 'a' && $('idAjudante1').value === '0') {
            return alert('Informe o Ajudante 1 corretamente!');
        } else if ($('selectBeneficiario').value === 'f' && $('idFuncionario').value === '0') {
            return alert('Informe o Funcionário corretamente!');
        } else {
            $("salvar").disabled = true;
            $("salvar").value = "Enviando...";
            if (acao == "atualizar" || acao == "atualizar_baixado"){
                acao += "&id="+<%=(carregaViag ? cadviag.getViagem().getId() : 0)%>;

            }else if ($("impedir_viagem_motorista").value == "t"){
                alert("O Motorista Informado Possui Alguma Viagem em Aberto, Finalize a Viagem Anterior Antes de Criar uma Nova.");
                $("salvar").disabled = false;
                $("salvar").value = "Salvar";
                return false;
            }

            $('formAd').action = "./cadviagem.jsp?acao="+acao+"&ctrcs="+concatCtrc()+"&qtdAdiant="+indexAdiant+"&qtdNotas="+indexNotes+"&qtdApp="+indexApp+"&isAcerto=false"
                +"&isCancelada="+$("cancelado").checked+"&motivoCancelamento=" + $("motivoCancelamento").value
                +"&"+concatFieldValueUnescape('saidaas,idfilial,numviagem,saidaem,idmotorista,origem,destino,idContaAdiant,'
                +'veiculo_id,idcarreta,idbitrem,valorPrevistoViagem,km_saida,kmChegada,acrescimos,previsaoRetornoEm,'
                +'quantidadeDiariaMotorista,quantidadeDiariaAjudante,quantidadeDiariaAjudante2,quantidadePernoiteMotorista,'
                +'quantidadePernoiteAjudante,quantidadePernoiteAjudante2,quantidadeAlimentacaoMotorista,quantidadeAlimentacaoAjudante,'
                +'quantidadeAlimentacaoAjudante2,diariaMotorista,diariaAjudante,diariaAjudante2,pernoiteMotorista,pernoiteAjudante,'
                +'pernoiteAjudante2,alimentacaoMotorista,alimentacaoAjudante,alimentacaoAjudante2,selectBeneficiario,idFuncionario,nomeFuncionario');

            window.open('about:blank', 'pop', 'width=210, height=100');
            $('formAd').submit();
        }
    }

    function validaFornec(){
        for (x=0; x < indexNotes; x++){
            if($('fornecedor'+x) != null && $('fornecedor'+x).value == ''){
                $('fornecedor'+x).style.background ="#FFE8E8";
                return false;
            }
        }
      return true;
    }

    function validaHist(){
        for (x=0; x < indexNotes; x++){
            if($('historicoNota'+x) != null && $('historicoNota'+x).value == ''){
                $('historicoNota'+x).style.background ="#FFE8E8";
                return false;
            }
        }
      return true;
    }

    function verDesp(id){
        window.open("./caddespesa?acao=editar&id="+id+"&ex=false", "Despesa" , "top=0,resizable=yes,status=1,scrollbars=1");
    }

    function verFpag(idx){
        //objeto funcao usado na requisicao Ajax(uma espécie de evento)
        function e(transport){
            var textoresposta = transport.responseText;
            espereEnviar("",false);

            //se deu algum erro na requisicao...
            if (textoresposta == "-1"){
                alert('Houve algum problema ao requistar o novo cheque, favor informar manualmente.');
                return false;
            }else{
                <%if (cfg.isControlarTalonario()) {%>
                    var lista = jQuery.parseJSON(textoresposta);

                    var listCheque = lista.list[0].documento;

                    var documento;
                    var isPrimeiro = true;

                    var slct = $("docAdiant1_"+idx);

                    var opt = null;

                    Element.update(slct);

                    opt = new Element("option", {
                        value: "0",
                        selected: true
                    })

                    Element.update(opt, " ---- ");
                    slct.appendChild(opt);

                    var length = (listCheque!= undefined && listCheque.length != undefined ? listCheque.length : 1);
                    for(var i = 0; i < length; i++){
                        if(length > 1){
                            documento = listCheque[i];
                        }else{
                            documento = listCheque;
                        }

                        if(documento != null && documento != undefined){
                            if(isPrimeiro){
                                opt = new Element("option", {
                                    value: documento                                    
                                })
                            }else{
                                opt = new Element("option", {
                                    value: documento
                                })
                            }

                            Element.update(opt, documento);
                            slct.appendChild(opt);
                            isPrimeiro = false;

                        }
                    }

                <%} else {%>
                    $('docAdiant'+idx).value = textoresposta;
                <%}%>
            }
        }//funcao e()
        if(parseInt($('contaAdiant'+idx).value) != 0){
            <%if (cfg.isControlarTalonario()) {%>
                invisivel($('docAdiant'+idx));
                visivel($('docAdiant1_'+idx));
            <%} else {%>
                visivel($('docAdiant'+idx));
                invisivel($('docAdiant1_'+idx));
            <%}%>

            espereEnviar("",true);

            tryRequestToServer(function(){
                new Ajax.Request("TalaoChequeControlador?acao=proxCheque&idConta="+$('contaAdiant'+idx).value,{method:'post', onSuccess: e, onError: e});
            });
        }
    }

    function verFpagReembolso(){
        //objeto funcao usado na requisicao Ajax(uma espécie de evento)
        function e(transport){
            var textoresposta = transport.responseText;
            espereEnviar("",false);

            //se deu algum erro na requisicao...
            if (textoresposta == "-1"){
                alert('Houve algum problema ao requistar o novo cheque, favor informar manualmente.');
                return false;
            }else{
                <%if (cfg.isControlarTalonario()) {%>
                    var lista = jQuery.parseJSON(textoresposta);

                    var listCheque = lista.list[0].documento;

                    var documento;
                    var isPrimeiro = true;

                    var slct = $("docAcertoSelect");

                    var opt = null;

                    Element.update(slct);

                    opt = new Element("option", {
                        value: ""
                    })

                    Element.update(opt, " ---- ");
                    slct.appendChild(opt);

                    var length = (listCheque!= undefined && listCheque.length != undefined ? listCheque.length : 1);
                    for(var i = 0; i < length; i++){
                        if(length > 1){
                            documento = listCheque[i];
                        }else{
                            documento = listCheque;
                        }

                        if(documento != null && documento != undefined){

                            if(isPrimeiro){
                                opt = new Element("option", {
                                    value: documento,
                                    selected: isPrimeiro+""
                                })
                            }else{
                                opt = new Element("option", {
                                    value: documento
                                })
                            }

                            Element.update(opt, documento);
                            slct.appendChild(opt);
                            isPrimeiro = false;

                        }
                    }

                <%} else {%>
                    $('docAcerto').value = textoresposta;
                <%}%>
            }
        }//funcao e()
        if(parseInt($('contaAcerto').value) != 0){
            if (<%=cfg.isControlarTalonario()%> && $('isReembolsoCheque').checked) {
                invisivel($('docAcerto'));
                visivel($('docAcertoSelect'));
				espereEnviar("",true);

				tryRequestToServer(function(){
					new Ajax.Request("TalaoChequeControlador?acao=proxCheque&idConta="+$('contaAcerto').value,{method:'post', onSuccess: e, onError: e});
				});
            }else {
                visivel($('docAcerto'));
				if ($('docAcertoSelect').style.display == ''){
					invisivel($('docAcertoSelect'));
				}
            }
        }
    }

    function isUsarCheque(i){
        if($("usaCheque_"+i).checked){
            verFpag(i);
        }else{
            visivel($('docAdiant'+i));
            invisivel($('docAdiant1_'+i));
        }
    }

    function baixar(){
        //validação baixar viagem com crédito de viagem retorno
        var adia = $("maxAdiantamento").value;
        var totalDebitos = 0;
        var totalCreditos = 0;
        if (acao != 'atualizar_baixado'){
            for(var j = 0; j<= adia;j++){
                if ($("incluindo"+j) != null && ($("incluindo"+j).value == true || $("incluindo"+j).value == 'true')){
                     if($("data_" + j) != null){
                         if($("data_" + j).value == "" && $("contaAdiant" + j).value == "-1"){
                                 alert("A Data do Adiantamento Não pode ser Vazia!");
                                 return false;
                         }
                     }
				
                     if($("idRemetente_" + j) != null){
                         if($("idRemetente_" + j).value == "0" && $("contaAdiant" + j).value == "-1"){
                                    alert("Selecione o Remetente no Adiantamento!");
                                    return false;
                         }
                     }
				
                     if($("idDestinatario_" + j) != null){
                         if($("idDestinatario_" + j).value == "0" && $("contaAdiant" + j).value == "-1"){
                                    alert("Selecione o Destinatário no Adiantamento!");
                                    return false;
                         }
                     }
                
                }
                if($("valorDebAdiant" + j) != null && $('idContaDebito' + j) != null && $('idContaDebito' + j).value != 0){
                     totalDebitos = parseFloat(totalDebitos) + parseFloat($("valorDebAdiant" + j).value);
                }
                           
                if($("valorAdiant" + j) != null){
                     totalCreditos = parseFloat(totalCreditos) + parseFloat($("valorAdiant" + j).value);
                }
                           
            }
            
            if (parseFloat($("totalAcerto").value) > 0){
                totalDebitos = parseFloat($("totalDespesas").value) + parseFloat($("valorAcertado").value) + parseFloat(totalDebitos);
            }else{
                totalDebitos = parseFloat($("totalDespesas").value) - parseFloat($("valorAcertado").value) + parseFloat(totalDebitos);
            }
            
            if (<%=!cfg.isBaixarAdvSaldoZerado()%> && parseFloat(totalDebitos).toFixed(2) != parseFloat(totalCreditos).toFixed(2)){
                alert('Atenção! O saldo da viagem deverá ser zero!\r\nTotal de Créditos:'+totalCreditos+'\r\nTotal de Débitos:'+totalDebitos);
                return false;
            }

        }
        
            for (var i = 0 ;i <= indexAdiant; i++){
                if ($("contaAdiant"+i) != null && ($("incluindo"+i).value == true || $("incluindo"+i).value == 'true')){
                    if ($("contaAdiant"+i).value == "0"){
                        return alert("Ao incluir o Adiantamento deve ser Informada a Conta!");
                        habilitar($('usaCheque_'+i));
                    }
                }
            }

        var acao = '';
        if (wasNull("numviagem")) {
            return alert("Preencha o Número da Viagem Corretamente!");
        } else if (! validaData($("saidaem").value)) {
            return alert("Data de Saída Incorreta. Formato Correto: dd/MM/yyyy");
        } else if (! validaData($("chegadaem").value)) {
            return alert("Data de Chegada Incorreta. Formato Correto: dd/MM/yyyy");
        } else if ($('selectBeneficiario').value === 'm' && $("idmotorista").value == '0') {
            return alert("Informe o Motorista Corretamente!");
        } else if ($('selectBeneficiario').value === 'a' && $('idAjudante1').value === '0') {
            return alert('Informe o Ajudante 1 corretamente!');
        } else if ($('selectBeneficiario').value === 'f' && $('idFuncionario').value === '0') {
            return alert('Informe o Funcionário corretamente!');
        } else if (!validaFornec() || !validaHist()) {
            return alert("Informe todos os dados Corretamente.");
        } else if (<%=cfg.isUnidadeCustoObrigatoria()%> && !getUnidadeCusto() ) {
            return alert("Informe a Unidade de Custo Corretamente na Apropriação.");
        } else if (!isValidaKm()){
            return false;
        }else if($("saidaem").value ==  $("chegadaem").value){
            if($("saidaas").value >  $("chegadaas").value){
                return alert("A Hora de Chegada não pode ser menor que a Hora de Saída!");
            }            
        }
        
        
        //Validação ao baixar a viagem a data de saída não pode ser maior que a data de chegada
        var saida = $("saidaem").value;
        var chegada = $("chegadaem").value;
        var hSaida = $("saidaas").value;
        var hChegada = $("chegadaas").value;
        
        var diaSaida = saida.split("/")[0];
        var mesSaida = saida.split("/")[1];
        
        var anoSaida = saida.split("/")[2];
        var anoChegada = chegada.split("/")[2];
        
        var diaChegada = chegada.split("/")[0];
        var mesChegada = chegada.split("/")[1];
        
        var horaSaida = hSaida.split(":")[0];
        var horaChegada = hChegada.split(":")[0];
        
        var minSaida = hSaida.split(":")[1];
        var minChegada = hChegada.split(":")[1];


        
        if(anoSaida > anoChegada ){
            alert("A Data de Chegada não pode ser menor que a Data de Saída!");
            return false;
        }else if(anoSaida == anoChegada){
            if(mesSaida > mesChegada){
                alert("O mês da Chegada não pode ser menor que o mês da Saída!");
                return false;
            }else 
                if(mesSaida == mesChegada){
                    if(diaSaida > diaChegada){
                        alert("O dia da Chegada não pode ser menor que o dia da Saída!");
                        return false;
                    }else 
                      if(diaSaida == diaChegada){
                        if(horaSaida > horaChegada){
                            alert("A hora da Chegada não pode ser menor que a hora da Saída!");
                            return false;
                        }else 
                            if(horaSaida == horaChegada){
                                if(minSaida > minChegada || minSaida == minChegada ){
                                    alert("O minuto da Chegada não pode ser menor que o minuto da Saída!");
                                    return false;
                                }
                            }
                        }
                    }
                }
                    $("baixar").disabled = true;
                    $("baixar").value = "Enviando...";
                                var xDocAcerto = $('docAcerto').value;
                    if (<%=cfg.isControlarTalonario()%> && $('isReembolsoCheque').checked) {
                                        xDocAcerto = $('docAcertoSelect').value;
                                }

                    acao += "baixar&id="+<%=(carregaViag ? cadviag.getViagem().getId() : 0)%>;
                    //$('formAd').target="pop";
                    window.open('about:blank', 'pop', 'width=210, height=100');
                    $('formAd').action = "./cadviagem.jsp?acao="+acao+"&docAcerto="+xDocAcerto+
                                    "&isReembolsoCheque="+$('isReembolsoCheque').checked+"&ctrcs="+concatCtrc()+"&qtdAdiant="+indexAdiant+"&qtdNotas="+indexNotes+"&qtdApp="+indexApp+"&isAcerto="+($('acerto').style.display == "none" ? "false" : "true")+
                                    "&Carreta_kmChegada = " + $("Carreta_kmChegada").value + "&Carreta_km_saida = " + $("Carreta_km_saida").value + "&Bitrem_kmChegada = " + $("Bitrem_kmChegada").value + "&Bitrem_km_saida = " + $("Bitrem_km_saida").value +
                                    "&bi_tipo_controle_km = " + $("bi_tipo_controle_km").value + "&car_tipo_controle_km = " + $("car_tipo_controle_km").value + 
                        "&"+concatFieldValueUnescape('saidaas,idfilial,numviagem,saidaem,idmotorista,origem,destino,idContaAdiant,chegadaem,chegadaas,acertoem,acertoas,veiculo_id,idcarreta,idbitrem,contaAcerto,valorAcertado,saldoMotorista,valorPrevistoViagem,km_saida,kmChegada,acrescimos,selectBeneficiario,idAjudante1,nomeAjudante1,idFuncionario,nomeFuncionario');
                    //submitPopupForm($('formAd'));

                    $('formAd').submit();
    }

    function display(id, index){
        if(id == "-1"){
            $('tr2'+index).style.display = "";
        }else{
            $('tr2'+index).style.display = "none";
        }
    }

    function excluirBaixa(){
        if (confirm("Deseja Mesmo Excluir a Baixa dessa Viagem?")){
            $("excluirBaixa").disabled = true;
            $("excluirBaixa").value = "Enviando...";

            $('formAd').target="pop";
            $('formAd').action = "./cadviagem.jsp?acao=excluirBaixa&id="+<%=cadviag.getViagem().getId()%>;

            window.open('about:blank', 'pop', 'width=210, height=100');
            $('formAd').submit();
            //submitPopupForm($('formAd'));
        }
    }

    function voltar(){
        tryRequestToServer(function(){parent.document.location.replace("./consulta_viagem.jsp?acao=iniciar")});
    }

    function excluir(id){
        if (confirm("Deseja Mesmo Excluir esta Viagem?"))
            parent.document.location.replace("./cadviagem.jsp?acao=excluir&id="+id);
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

    function localizaCtrc(){
        var post_cad = window.open('./pops/seleciona_ctrc_viagem.jsp?acao=iniciar&idmotorista='+$('idmotorista').value+'&idfilial='+$('idfilial').value+"&ctrcs="+concatCtrc(),'CTRC',
                      'top=80,left=10,height=400,width=1200,resizable=yes,status=3,scrollbars=1');
    }

    function imprimeRecibo(incluindo, idMovBanco){
        if (incluindo){
            alert('Antes de Imprimir o Recibo Você Deverá Salvar a Viagem.');
        }else{
            launchPDF('./consulta_viagem.jsp?acao=imprimirRecibo&modelo=1&idMovBanco='+idMovBanco,'recibo');
        }
    }


    function addCtrc(ids, ctrcs,valorCtrc){ 
        var _tr = '';
        var _td = '';
        var ctrc = '';
        var id = 0;
        var contTd = 0;
        var contTr = 1;

        var qtd = ids.split(',').length;

        indexCtrc = 0;

        $('lbCtrcs').innerHTML = "";

        //Criando a Table
        if (qtd >= 1){
            
            
            $('lbCtrcs').appendChild(Builder.node('table', {width:'100%', id:'xTbCtrcMestre', border:'1', className:'CelulaZebra2'}));
            $('xTbCtrcMestre').appendChild(Builder.node('tbody', {id:'xTbCtrc'}));
            _tr = Builder.node('TR', {id:'tr'+contTr});
            $('xTbCtrc').appendChild(_tr);
            for (x=0;x<qtd;x++){
                id = ids.split(',')[x];
                ctrc = ctrcs.split(',')[x];
                if (contTd == -1){
                    contTr++;
                    contTd = 0;
                    _tr = Builder.node('TR', {id:'tr'+contTr, className:'CelulaZebra2'});
                    $('xTbCtrc').appendChild(_tr);
                }
                _td = Builder.node('TD', {width:'10%'},
                                  [Builder.node('INPUT', {name:'ctrc_id'+indexCtrc,id:'ctrc_id'+indexCtrc,value:id, type:'hidden'}),
								   Builder.node('DIV', {className:'linkEditar',onClick:'editarSale('+id+');'},
								   [ctrc])]);
                $('tr'+contTr).appendChild(_td);
                
                if (valorCtrc != "") {
                    //Adicionando o valor total de ctrcs adicionado
                    $("totalCtrc").value = colocarVirgula(roundABNT(valorCtrc,2));
                }
                
                if (contTd==9)
                    contTd = -1;
                else
                    contTd++;

                indexCtrc++;
            }
        }
    }

    function editarSale(id){
		if (<%=nivelCtrc == 0%>){
			alert('Você não tem privilégios suficientes para executar essa ação!');
		}else{
			tryRequestToServer(function(){window.open('./frameset_conhecimento?acao=editar&id='+id+'&ex=false', 'CTRC' , 'top=0,resizable=yes');});
		}
	}		
    
    function getIndexDespesaComissao(){
        var retorno = 0;
        for (i = 0; i <= indexNotes; i++) {
            if ($("isComissaoMotorista_"+ i) != null && $("isComissaoMotorista_"+ i).value == "true") {
                retorno = i;
            }
        }
        return retorno;
    }

    function popImg(id){
        window.open('./ImagemControlador?acao=carregar&idDespesa='+id,'imagensDespesa','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
    }
    
    //21 parametros em addAdiantamento
    function addAdiantamento(data, valor, historico, doc, conta, incluindo, idMovBanco, isCheque,dataEmissao,valorFrete,idDestinatario,destinatario,idConsignatario,consignatario,valorFreteRetorno,valorDinheiroRetorno,valorChequeRetorno,valorSaldoRetorno,pesoCTRC, descricaoConta, isSincronizadoMobile, isOrigemMobile){
        try{
            var idViagem = <%=viag.getId() != 0 ? viag.getId() : null%>;
            var imgSincronizadoMobile;
            if(isSincronizadoMobile){
                imgSincronizadoMobile =  "img/smart3.png";
            }else{
                imgSincronizadoMobile = "img/smartphone.png";
            }

        conta = (parseInt(idMovBanco) != 0 && parseInt(conta) == 0 && idConsignatario != 0 ? -1 : conta);
        var _tr = '';
        var _td = '';
        _tr = Builder.node('TR', {
            id:'tr'+indexAdiant, 
            name:'tr'+indexAdiant, 
            className:'CelulaZebra2'},
        
        [Builder.node('TD',
            [Builder.node('IMG', {
                 name:'imgRecibo'+indexAdiant, 
                 id:'imgRecibo'+indexAdiant,
                 src:'img/pdf.jpg', 
                 border:'0', 
                 width:'19', 
                 height:'19', 
                 title:'Imprimir Recibo', 
                 className:'imagemLink',
                 onClick:'imprimeRecibo('+incluindo+','+idMovBanco+');'})
            ]),

            Builder.node('TD',
                [Builder.node('IMG', {
                    name:'sincronizarMobile_'+indexAdiant,
                    id:'sincronizarMobile_'+indexAdiant,
                    src: imgSincronizadoMobile,
                    border:'0',
                    width:'19',
                    height:'19',
                    title:'Sincronizar Para GW Mobile',
                    className:'imagemLink',
                    onClick:'sincronizarAdiantamentoGWMobile('+idViagem+','+idMovBanco+','+'\'<%=acao%>\''+');'})
                ]),

            Builder.node('TD',
                [Builder.node('IMG', {
                    name: 'origemMobile',
                    src: 'img/icone-gw-mobile.png',
                    width: '25',
                    height: '25',
                    border: '0',
                    align: "center",
                    style: "display:"+ (isOrigemMobile ? "" : "none")
                })]
            ),
            
                
            Builder.node('TD',
            [Builder.node('INPUT', {
                 type:'text', 
                 name:'dataAdiant'+indexAdiant, 
                 id:'dataAdiant'+indexAdiant,
                 size:'11', 
                 maxLength:'10', 
                 value:data, 
                 className:'fieldMin',
                 onBlur:'alertInvalidDate($(\'dataAdiant'+indexAdiant+'\'));',
                 onKeyDown:'fmtDate($(\'dataAdiant'+indexAdiant+'\') , event);',
                 onKeyUp:'fmtDate($(\'dataAdiant'+indexAdiant+'\') , event);',
                 onKeyPress:'fmtDate($(\'dataAdiant'+indexAdiant+'\') , event);'}),
                
            Builder.node('INPUT', {
                 type:'hidden', 
                 name:'incluindo'+indexAdiant, 
                 id:'incluindo'+indexAdiant, 
                 value:incluindo})
            ]),
            Builder.node('TD',
            [Builder.node('INPUT', {
                 type:'text', 
                 name:'histAdiant'+indexAdiant, 
                 id:'histAdiant'+indexAdiant,
                 size:'45', 
                 maxLength:'120', 
                 value:historico, 
                 className:'fieldMin'})
            ]),
            
            Builder.node('TD', ((valor >= 0 )? '' :
                [Builder.node('INPUT', {
                    type:'text', 
                    name:'valorDebAdiant'+indexAdiant, 
                    id:'valorDebAdiant'+indexAdiant,
                    size:'8', 
                    maxLength:'12', 
                    value:formatoMoeda(valor*-1), 
                    className:'fieldMin'})
            ])),
            
            Builder.node('TD', (valor < 0 ? '' :
                [Builder.node('INPUT', {
                    type:'text', 
                    name:'valorAdiant'+indexAdiant, 
                    id:'valorAdiant'+indexAdiant,
                    size:'8', 
                    maxLength:'12', 
                    value:formatoMoeda(valor), 
                    className:'fieldMin',
                    onchange:'seNaoFloatReset($(\'valorAdiant'+indexAdiant+'\'), \'0.00\');alteraTipoDespesa();alteraValor(' + indexAdiant + ');novoVal(' + indexAdiant + ');totalAdiantamento();'})
            ])),
            
            Builder.node('TD',
            [Builder.node('SELECT', {
                name:'contaAdiant'+indexAdiant, 
                id:'contaAdiant'+indexAdiant, 
                className:'fieldMin', 
                onchange:'javascript:$(\'idContaDebito'+indexAdiant+'\').value = this.value;isUsarCheque('+indexAdiant+'); display(this.value,' + indexAdiant + '); totalAdiantamento();'},[
                    Builder.node('OPTION', {
                        value:"0" , 
                        selected:true}, '-- Selecione --'),
        <%  
            BeanConsultaConta conta = new BeanConsultaConta();
            conta.setConexao(Apoio.getUsuario(request).getConexao());
            conta.mostraContasViagem((nivelUserDespesaFilial >= 3 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), limitarUsuarioAlterarContas, idUsuario);

            ResultSet rsconta = conta.getResultado();
            while (rsconta.next()) {
                if (rsconta.getInt("idconta") != cfg.getConta_adiantamento_viagem_id().getIdConta()) {
        %>          
                    ('<%=rsconta.getString("idconta")%>' != conta ? Builder.node('OPTION', {value:<%=rsconta.getString("idconta")%> , selected:false}, '<%=rsconta.getString("numero") + "-" + rsconta.getString("digito_conta") + " " + rsconta.getString("banco")%>') : ""),
        <%               
                }
            }
          rsconta.close();
        %>                                                     
                    Builder.node('OPTION', {value:"-1" , selected:false}, 'CRÉDITO VIAGEM RETORNO'),
                          
                    (descricaoConta != '' ? Builder.node('OPTION', {value: conta+"" , selected:false}, descricaoConta+"") : "")
                ]),
                    
                    Builder.node('INPUT', {
                        type:'hidden', 
                        name:'idContaDebito'+indexAdiant, 
                        id:'idContaDebito'+indexAdiant, 
                        value:'0'})
                ]),
                    Builder.node('TD', {id:"tdIsCheque_"+indexAdiant},[
                    Builder.node("INPUT", {
                        type:"checkbox", 
                        id:"usaCheque_"+indexAdiant, 
                        name:"usaCheque_"+indexAdiant, 
                        onClick:"isUsarCheque("+indexAdiant+")", 
                        title:"Utilizar Cheques"})
                ]),
                    Builder.node('TD',{id:"tdDoc_"+indexAdiant},
                [
                    Builder.node('INPUT', {
                        type:'text', 
                        name:'docAdiant'+indexAdiant, 
                        id:'docAdiant'+indexAdiant,
                        size:'8', 
                        maxLength:'7', 
                        value:doc, 
                        className:'fieldMin'}),
                    Builder.node('SELECT', {
                        name:'docAdiant1_'+indexAdiant, 
                        id:'docAdiant1_'+indexAdiant,
                        className:'fieldMin',
                        onchange: 'calcularTalaoCheque('+indexAdiant+')'})
                ]),
                    Builder.node('TD',
                    [Builder.node('IMG', {
                        src:'img/lixo.png', 
                        title:'Excluir adiantamento', 
                        className:'imagemLink',
                        onClick:'excluirAdiantamento('+incluindo+','+indexAdiant+');'})
                ])
            ]);
            
            $('tbAdiant').appendChild(_tr);

            //$('contaAdiant'+indexAdiant).disabled = true;	
            var _tr2 = Builder.node('TR', {
                id:'tr2'+indexAdiant, 
                name:'tr2'+indexAdiant});
                            
            var _td2 = Builder.node('TD', {colSpan: '12'});
            
            var _table2 = Builder.node('TABLE', {
                width:'100%', 
                className:'bordaFina'});
                            
            var _tbody2 = Builder.node('TBODY');
            var _tr2Table = Builder.node('TR');
            var _td2Table1 = Builder.node('TD',{width:'10%', className:'TextoCampos'},'Data:');
            var _td2Table2 = Builder.node('TD',{
                                width:'10%', 
                                className:'CelulaZebra2'});

            var _inpData = Builder.node("INPUT", {
                type: "text", 
                name: 'data_' + indexAdiant, 
                id: 'data_' + indexAdiant, 
                value: dataEmissao, 
                size: "11", 
                className:"fieldDateMin", 
                onblur:"alertInvalidDate(this);", 
                onkeypress : "fmtDate(this, event)", 
                maxlength:"10"});

            _td2Table2.appendChild(_inpData);
            
            var _td2Table3 = Builder.node('TD',{
                width:'10%', 
                className:'TextoCampos'},'Valor Frete:');
                                
            var _td2Table4 = Builder.node('TD',{
                width:'10%', 
                className:'CelulaZebra2'});
                                
            var _inpValor = Builder.node('INPUT', {
                type:'text', 
                name:'valorCtrc'+indexAdiant, 
                id:'valorCtrc'+indexAdiant, 
                size:'8', 
                maxLength:'12', 
                value:formatoMoeda(valorFreteRetorno), 
                className:'inputReadOnly', 
                readonly:true ,
                onBlur:'novoVal(' + indexAdiant + ');' ,
                onchange:'seNaoFloatReset($(\'valorCtrc'+indexAdiant+'\'), \'0.00\');'});
            _td2Table4.appendChild(_inpValor);
            
            var _td2Table5 = Builder.node('TD',{
                width:'10%', 
                className:'TextoCampos'},'Em Dinheiro:');
                                
            var _td2Table6 = Builder.node('TD',{
                width:'10%', 
                className:'CelulaZebra2'});
                
            var _inpAdt = Builder.node('INPUT', {
                type:'text', 
                name:'valorCtrcAdt'+indexAdiant, 
                id:'valorCtrcAdt'+indexAdiant, 
                size:'8', 
                maxLength:'12', 
                value:formatoMoeda(valorDinheiroRetorno), 
                className:'inputtexto', 
                onBlur:'novoVal(' + indexAdiant + ');' ,
                onchange:'seNaoFloatReset($(\'valorCtrcAdt'+indexAdiant+'\'), \'0.00\'); novoVal(' + indexAdiant + ');alteraTipoDespesa();'});
            _td2Table6.appendChild(_inpAdt);
            
            var _td2TableLbCheque = Builder.node('TD',{
                width:'10%', 
                className:'TextoCampos'},'Em cheque:');
                
            var _td2TableCheque = Builder.node('TD',{
                width:'10%', 
                className:'CelulaZebra2'});

            var _inpAdtCheque = Builder.node('INPUT', {
                type:'text', 
                name:'valorCtrcAdtCheque'+indexAdiant, 
                id:'valorCtrcAdtCheque'+indexAdiant, 
                size:'8', 
                maxLength:'12', 
                value:formatoMoeda(valorChequeRetorno), 
                className:'inputtexto', 
                onBlur:'novoVal(' + indexAdiant + ');' ,
                onchange:'seNaoFloatReset($(\'valorCtrcAdtCheque'+indexAdiant+'\'), \'0.00\'); novoVal(' + indexAdiant + ');alteraTipoDespesa();'});
            _td2TableCheque.appendChild(_inpAdtCheque);


            var _td2Table7 = Builder.node('TD',{
                width:'10%', 
                className:'TextoCampos'},'Saldo:');
                
            var _td2Table8 = Builder.node('TD',{
                width:'10%', 
                className:'CelulaZebra2'});
                
            var _inpSaldo = Builder.node('INPUT', {
                type:'text', 
                name:'valorCtrcSaldo'+indexAdiant, 
                id:'valorCtrcSaldo'+indexAdiant, 
                size:'8', 
                maxLength:'12', 
                value:formatoMoeda(valorSaldoRetorno), 
                className:'inputtexto', 
                onchange:'seNaoFloatReset($(\'valorCtrcSaldo'+indexAdiant+'\'), \'0.00\');novoVal(' + indexAdiant + ');alteraTipoDespesa();'});
            _td2Table8.appendChild(_inpSaldo);

            _tr2Table.appendChild(_td2Table1);
            _tr2Table.appendChild(_td2Table2);
            _tr2Table.appendChild(_td2Table3);
            _tr2Table.appendChild(_td2Table4);
            _tr2Table.appendChild(_td2Table5);
            _tr2Table.appendChild(_td2Table6);
            _tr2Table.appendChild(_td2TableLbCheque);
            _tr2Table.appendChild(_td2TableCheque);
            _tr2Table.appendChild(_td2Table7);
            _tr2Table.appendChild(_td2Table8);

            var _tr2Table2 = Builder.node('TR');
            var _td2Table2_1 = Builder.node('TD',{
                className:'TextoCampos'},'Remetente:');
                
            var _td2Table2_2 = Builder.node('TD',{
                colSpan:'3', 
                className:'CelulaZebra2'});
            
            // ID remetente
            var hid1_ = Builder.node("INPUT",{
                type:"hidden",
                id:"idRemetente_"+indexAdiant,
                name:"idRemetente_"+indexAdiant,
                value: idConsignatario});
        
            // ID cidade
            var hid3_ = Builder.node("INPUT",{
                type:"hidden",
                id:"idCidadeRemetente_"+indexAdiant,
                name:"idCidadeRemetente_"+indexAdiant,
                value: ""});
        
            // Remetente
            var inp1_ = Builder.node("INPUT",{
                type:"text",
                id:"remetente_"+indexAdiant,
                name:"remetente_"+indexAdiant,
                value: "",
                size: "25",
                value: consignatario,
                className:"inputtexto" });
            readOnly(inp1_);
         
            var bot1_ = Builder.node("INPUT",{
                className:"inputBotaoMin", 
                id:"localizaRemetente_"+indexAdiant,
                name:"localizaRemetente_"+indexAdiant,
                type:"button", 
                value:"...",
                onClick:"localizarRemetente(this);"});
            
            var _img1= Builder.node("IMG",{
                src:"img/borracha.gif",
                className:"imagemLink",
                onClick:"javascript:$('idRemetente_"+indexAdiant+"').value='0';$('remetente_"+indexAdiant+"').value='';"});

            _td2Table2_2.appendChild(hid1_);
            _td2Table2_2.appendChild(hid3_);
            _td2Table2_2.appendChild(inp1_);
            _td2Table2_2.appendChild(bot1_);
            _td2Table2_2.appendChild(_img1);
                  
            var _td2Table2_3 = Builder.node('TD',{className:'TextoCampos'},'Destinatário:');
            
            var _td2Table2_4 = Builder.node('TD',{
                                   colSpan:'3', 
                                   className:'CelulaZebra2'});
            
            // ID destinatario
            var hid2_ = Builder.node("INPUT",{
                type:"hidden",
                id:"idDestinatario_"+indexAdiant,
                name:"idDestinatario_"+indexAdiant,
                value: idDestinatario});
        
            // Destinatario
            var inp2_ = Builder.node("INPUT",{
                type:"text",
                id:"destinatario_"+indexAdiant,
                name:"destinatario_"+indexAdiant,
                value: "",
                size: "25",
                value: destinatario,
                className:"inputtexto" });
            readOnly(inp2_);
            
			// ID cidade destinatario
            var hidCidDest_ = Builder.node("INPUT",{
                type:"hidden",
                id:"idCidadeDestinatario_"+indexAdiant,
                name:"idCidadeDestinatario_"+indexAdiant,
                value: ""});
             
            var bot2_ = Builder.node("INPUT",{className:"inputBotaoMin", 
                id:"localizaDestinatario_"+indexAdiant,
                name:"localizaDestinatario_"+indexAdiant,
                type:"button", value:"...",
                onClick:"localizarDestinatario(this);"});
            
            var _img2= Builder.node("IMG",{
                src:"img/borracha.gif",
                className:"imagemLink",
                onClick:"javascript:$('idDestinatario_"+indexAdiant+"').value='0';$('destinatario_"+indexAdiant+"').value='';"});

            _td2Table2_4.appendChild(hid2_);
            _td2Table2_4.appendChild(inp2_);
            _td2Table2_4.appendChild(hidCidDest_);
            _td2Table2_4.appendChild(bot2_);
            _td2Table2_4.appendChild(_img2);

            var _tdPeso = Builder.node('TD',{
                className:'TextoCampos'},'Peso:');
                
            var _tdValorPeso = Builder.node('TD',{
                className:'CelulaZebra2'});
                
            var _inpPeso = Builder.node('INPUT', {
                type:'text', 
                name:'pesoCtrc'+indexAdiant, 
                id:'pesoCtrc'+indexAdiant, 
                size:'8', 
                maxLength:'12', 
                value:formatoMoeda(pesoCTRC), 
                className:'inputtexto'});
            
            _tdValorPeso.appendChild(_inpPeso);

            _tr2Table2.appendChild(_td2Table2_1);
            _tr2Table2.appendChild(_td2Table2_2);
            _tr2Table2.appendChild(_td2Table2_3);
            _tr2Table2.appendChild(_td2Table2_4);
            _tr2Table2.appendChild(_tdPeso);
            _tr2Table2.appendChild(_tdValorPeso);

            _tbody2.appendChild(_tr2Table);
            _tbody2.appendChild(_tr2Table2);
			
            _table2.appendChild(_tbody2);
            _td2.appendChild(_table2);
            _tr2.appendChild(_td2);
            $('tbAdiant').appendChild(_tr2);
			
	    
            if(idConsignatario != 0 || idDestinatario != 0){
                $('tr2'+indexAdiant).style.display = "";
            }else{
                $('tr2'+indexAdiant).style.display = "none";
            }
            
            invisivel($('docAdiant1_'+indexAdiant));
            $('usaCheque_'+indexAdiant).checked = isCheque;
            $('contaAdiant'+indexAdiant).style.width = '120px';
            if (!incluindo) {
                $('dataAdiant'+indexAdiant).readOnly = true;
                $('histAdiant'+indexAdiant).readOnly = true;
                $('contaAdiant'+indexAdiant).disabled = true;
                $('docAdiant'+indexAdiant).readOnly = true;
                $('docAdiant1_'+indexAdiant).readOnly = true;
                $('dataAdiant'+indexAdiant).style.backgroundColor = '#FFFFF1';
                $('histAdiant'+indexAdiant).style.backgroundColor = '#FFFFF1';
                $('contaAdiant'+indexAdiant).style.backgroundColor = '#FFFFF1';
                $('docAdiant'+indexAdiant).style.backgroundColor = '#FFFFF1';
                $('docAdiant1_'+indexAdiant).style.backgroundColor = '#FFFFF1';

                desabilitar($('usaCheque_'+indexAdiant));

                if (conta != 0){
                    $('contaAdiant'+indexAdiant).value = conta;
                    $('idContaDebito'+indexAdiant).value = conta;
                }else{
                    $('contaAdiant'+indexAdiant).style.display = "none";
                }
                if (valor < 0){
                    $('valorDebAdiant'+indexAdiant).readOnly = true;
                    $('valorDebAdiant'+indexAdiant).style.backgroundColor = '#FFFFF1';
                    $('imgRecibo'+indexAdiant).style.display = 'none';
                }else{
                    $('valorAdiant'+indexAdiant).readOnly = true;
                    $('valorAdiant'+indexAdiant).style.backgroundColor = '#FFFFF1';
                }
            }else{
                $('contaAdiant'+indexAdiant).value = '0';
                $('idContaDebito'+indexAdiant).value = 'conta';
            }
            
            isAlteraMotorista();
            
            $("maxAdiantamento").value = indexAdiant;

            if(isOrigemMobile && valor >= 0){
                var adiant = $('contaAdiant'+indexAdiant);
                var dataCredito = $('data_'+indexAdiant);
                dataCredito.value = data;
                adiant.style.display = '';
                adiant.value = '-1';
                adiant.onchange();
            }
            
            indexAdiant++;
        }catch(e){
            console.error(e);
        }
    }

    function addNotes(id, tipo, especie, serie, nf, data, venc, idfornecedor, fornecedor, idhist, historico, valor, comissaoMotorista,isOrigemGwmobile){
        var acao = '<%=acao%>';
        var incluindo = (id == 0 ? true : false);
        var _tr = '';
        var _td = '';
        var niveDespesa = '<%=autenticado.getAcesso("caddespesa")%>';
        var _opt1 = Builder.node('OPTION', {value:'a'}, 'À Vista');
        var _opt2 = Builder.node('OPTION', {value:'p'}, 'À Prazo');
        let permissaoOutrasFiliais = <%= autenticado.getAcesso("landespfl") > 2 %>;
        data = (data == "" || data == undefined ? dataAtual: data);
        venc = (venc == "" || venc == undefined ? dataAtual: venc);

        if(id == 0 && acao != "iniciarbaixa" && <%=nivelUserDespesaPrazo != 4%>) {
            alert('Você Não tem Privilégios Suficientes para Incluir uma Despesa a prazo no ADV!')
            return null;
        }
        
        if(!permissaoOutrasFiliais && $("idfilial").value != '<%= autenticado.getFilial().getId()%>') {
            alert('Atenção! Seu usuário não possui Privilégios Suficientes para Incluir uma Despesa para Outra Filial!')
            return null;
        }
        
        _tr = Builder.node('TR', {
                  id:'trdesp'+indexNotes, 
                  className:'CelulaZebra2'},
              
            [
            Builder.node('TD',indexNotes+1),
                Builder.node('TD',{align:"center"},[
                Builder.node("div", {id:"anexoDespesa_"+indexNotes})
            ]),
                Builder.node('TD',{align:"center"},[
                Builder.node("div", {id:"origemMobile_"+indexNotes})
            ]),

                Builder.node('TD',{align:"center"},[
                Builder.node("div", {id:"numDespesa_"+indexNotes})
            ]),
            
            Builder.node('TD',
                [Builder.node('SELECT', {
                    name:'tipoDesp'+indexNotes, 
                    id:'tipoDesp'+indexNotes, 
                    className:'fieldMin', 
                    onchange:'javascript:alteraTipoDespesa();$(\'idTipoDesp'+indexNotes+'\').value = this.value;'},[]),
                
                Builder.node('INPUT', {
                   type:'hidden', 
                   name:'idTipoDesp'+indexNotes, 
                   id:'idTipoDesp'+indexNotes,
                   value:tipo}),
                Builder.node("INPUT",{
                    type:"hidden",
                    id:"isComissaoMotorista_"+indexNotes,
                    name:"isComissaoMotorista_"+indexNotes,
                    value: comissaoMotorista})
            ]),
            
            Builder.node('TD',
                [Builder.node('SELECT', {
                    name:'especie'+indexNotes, 
                    id:'especie'+indexNotes, 
                    className:'fieldMin'},
                [
            <%                                    
            Especie es = new Especie();
            ResultSet rsEsp = es.all(Apoio.getUsuario(request).getConexao());
            while (rsEsp.next()) {%>
                  Builder.node('OPTION', {value:'<%=rsEsp.getString("id")%>'}, '<%=rsEsp.getString("especie")%>'),
        <%   
            }
          rsEsp.close();
        %>                                 
                    ])]),
                    Builder.node('TD',
                    [Builder.node('INPUT', {
                        type:'text', 
                        name:'serie'+indexNotes, 
                        id:'serie'+indexNotes,
                        size:'4', 
                        maxLength:'3', 
                        value:serie, 
                        className:'fieldMin'}),
                    
                     Builder.node('INPUT',{
                         type:'hidden', 
                         name:'idNota'+indexNotes, 
                         id:'idNota'+indexNotes, 
                         value:id},'')
                 ]),
                    
                    Builder.node('TD',
                    [Builder.node('INPUT', {
                         type:'text', 
                         name:'nf'+indexNotes, 
                         id:'nf'+indexNotes,
                         size:'7', 
                         maxLength:'10', 
                         value:nf, 
                         className:'fieldMin'})
                    ]),
                    
                    Builder.node('TD',
                    [Builder.node('INPUT', {
                         type:'text', 
                         name:'dataNota'+indexNotes, 
                         id:'dataNota'+indexNotes,
                         size:'12', 
                         maxLength:'10', 
                         value:data, 
                         className:'fieldMin',
                         onBlur:'alertInvalidDate($(\'dataNota'+indexNotes+'\'));',
                         onKeyDown:'fmtDate($(\'dataNota'+indexNotes+'\') , event);',
                         onKeyUp:'fmtDate($(\'dataNota'+indexNotes+'\') , event);',
                         onKeyPress:'fmtDate($(\'dataNota'+indexNotes+'\') , event);'})
                    ]),
                    
                    Builder.node('TD',
                    [Builder.node('INPUT', {
                         type:'hidden', 
                         name:'idfornecedor'+indexNotes, 
                         id:'idfornecedor'+indexNotes,
                         value:idfornecedor}),
                     
                        Builder.node('INPUT', {
                            type:'text', 
                            name:'fornecedor'+indexNotes, 
                            id:'fornecedor'+indexNotes,
                            size:'23', 
                            maxLength:'80', 
                            value:fornecedor, 
                            className:'inputReadOnly8pt'}),
                        
                        Builder.node('INPUT', {
                            type:'button', 
                            name:'localizaForn_'+indexNotes, 
                            id:'localizaForn_'+indexNotes,
                            value:'...', 
                            className:'inputBotaoMin',
                            onClick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=21\',\'Fornecedor_'+indexNotes+'\');'
                        })
                    ]),
                    
                    Builder.node('TD',
                    [Builder.node('INPUT', {
                        type:'hidden', 
                        name:'idhistoricoNota'+indexNotes, 
                        id:'idhistoricoNota'+indexNotes,
                        value:idhist}),
                    
                        Builder.node('INPUT', {
                            type:'text', 
                            name:'historicoNota'+indexNotes, 
                            id:'historicoNota'+indexNotes,
                            size:'25', 
                            maxLength:'200', 
                            value:historico, 
                            className:'fieldMin'}),
                        
                        Builder.node('INPUT', {
                            type:'button', 
                            name:'localizaHist_'+indexNotes, 
                            id:'localizaHist_'+indexNotes,
                            value:'...', 
                            className:'inputBotaoMin',
                            onClick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=14\',\'Historico_'+indexNotes+'\');'
                        })
                    ]),
                    Builder.node('TD',
                    [Builder.node('INPUT', {
                        type:'text', 
                        name:'valorNota'+indexNotes, 
                        id:'valorNota'+indexNotes,
                        size:'8', 
                        maxLength:'12', 
                        value:formatoMoeda(valor), 
                        className:'inputReadOnly8pt',
                        onchange:'seNaoFloatReset($(\'valorNota'+indexNotes+'\'), \'0.00\');'})
                    ]),
                    Builder.node('TD', (!incluindo ? '' :
                        [Builder.node('IMG', {
                            src:'img/lixo.png', 
                            title:'Excluir Despesa', 
                            className:'imagemLink',
                            onClick:'excluirNota('+indexNotes+');'})
                    ]))
                ]);
                $('desp_notes').appendChild(_tr);

                if(parseInt(niveDespesa) > 0  && id != 0  && id!= "0"){
                    $("numDespesa_"+indexNotes).appendChild(Builder.node('LABEL', {
                                                                name:'idDespesa_'+indexNotes,
                                                                id:'idDespesa_'+indexNotes,
                                                                value:id,
                                                                className:'linkEditar',
                                                                onClick:'javascript:verDesp('+id+');'},id));
                }else if (id != 0  && id!= "0"){
                    $("numDespesa_"+indexNotes).innerHTML= id;
                }
                if(parseInt(niveDespesa) > 0  && id != 0  && id!= "0"){
                    $("anexoDespesa_"+indexNotes).appendChild(Builder.node('TD',
                        [Builder.node('IMG', {
                            name: 'anexoDespesa'+indexNotes,
                            id:'anexoDespesa'+indexNotes,
                            src: 'img/jpg.png',
                            width: '20',
                            height: '20',
                            border: '0',
                            align: "center",
                            title: 'Imagens de documentos',
                            className: 'imagemLink',
                            onClick: 'popImg(' + id + ')'
                        })]
                    ));
                }else if (id != 0  && id!= "0"){
                    $("anexoDespesa_"+indexNotes).innerHTML= '';
                }
                if(parseInt(niveDespesa) > 0  && isOrigemGwmobile){
                    $("origemMobile_"+indexNotes).appendChild(Builder.node('TD',
                        [Builder.node('IMG', {
                            name: 'origemMobile'+indexNotes,
                            id:'origemMobile'+indexNotes,
                            src: 'img/icone-gw-mobile.png',
                            width: '25',
                            height: '25',
                            border: '0',
                            align: "center",
                            title: 'Sincronizada pelo GW Mobile'
                        })]
                    ));
                }else if (id != 0  && id!= "0"){
                    $("origemMobile_"+indexNotes).innerHTML= '';
                }
                if((acao != "editar" && acao != "iniciar") || tipo === 'a'){
                    $('tipoDesp'+indexNotes).appendChild(_opt1);
                    //tipo= "p";
                }


                //tudo isso por conta do IE
                if(tipo == ""){
                    if(acao == "editar" || acao == "iniciar") {
                        if (<%=nivelUserDespesaPrazo == 4%>){
                            tipo = "p";
                        }
                    }else if(acao == "iniciarbaixa"){
                        tipo = "a";
                    }
                }

                if (<%=nivelUserDespesaPrazo == 4%>){
                    $('tipoDesp'+indexNotes).appendChild(_opt2);
                }

                $('tipoDesp'+indexNotes).value = tipo;
                $('idTipoDesp'+indexNotes).value = tipo;
                $('fornecedor'+indexNotes).readOnly = true;
                $('valorNota'+indexNotes).readOnly = true;

                //Criando a tabela de Apropriações
                _tr = Builder.node('TR', {id:'trApropDesp'+indexNotes},
                [Builder.node('TD',{colSpan:'13'},
                    [Builder.node('TABLE', {id:'TB'+indexNotes, width:'100%', border:'0'},
                        [Builder.node('TBODY', {id:'TBODYNOTES'+indexNotes},
                            [Builder.node('TR', {className:'CelulaZebra1'},
                                [Builder.node('TD', {width:'2%'}, (!incluindo ? '' :
                                        [Builder.node('IMG', {
                                            src:'img/add.gif', 
                                            title:'Adicionar Apropriação', 
                                            className:'imagemLink',
                                            onClick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=20\',\'Plano_'+indexNotes+'\');'})
                                    ])),
                                    Builder.node('TD', {width:'1%'}, (!incluindo ? '' :
                                        [Builder.node('IMG',{
                                            src:'img/calculadora.png',
                                            title: 'Calcular diárias, pernoites e alimentações',
                                            className:'imagemLink',
                                            onClick: 'javascript:addDiarias('+indexNotes+');'})
                                    ])),
                                    Builder.node('TD', {width:'33%'}, 'Plano de custo'),
                                    Builder.node('TD', {width:'19%', id:'idDescDespesa'}, 'Descrição'),
                                    Builder.node('TD', {width:'12%'}, 'Veículo'),
                                    Builder.node('TD', {width:'7%'}, 'Valor'),
                                    Builder.node('TD', {width:'8%'}, 'Und. custo'),
                                    Builder.node('TD', {width:'9%'}, 'Vencimento:'),
                                    Builder.node('TD', {width:'10%'},
                                    [Builder.node('INPUT', {
                                        type:'text', 
                                        name:'dataVenc'+indexNotes, 
                                        id:'dataVenc'+indexNotes,
                                        size:'12', 
                                        maxLength:'10', 
                                        value:venc, 
                                        className:'fieldMin',
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
                if (especie == "" || especie == 0) {
                    $('especie'+indexNotes).selectedIndex = 0;
                }else{
                    $('especie'+indexNotes).value = especie;
                }
                if (!incluindo){
                    $('especie'+indexNotes).disabled = true;
                    $('tipoDesp'+indexNotes).disabled = true;
                    $('serie'+indexNotes).readOnly = true;
                    $('nf'+indexNotes).readOnly = true;
                    $('dataNota'+indexNotes).readOnly = true;
                    $('dataVenc'+indexNotes).readOnly = true;
                    $('historicoNota'+indexNotes).readOnly = true;
                    $('localizaForn_'+indexNotes).style.display = "none";
                    $('localizaHist_'+indexNotes).style.display = "none";
                    $('especie'+indexNotes).style.backgroundColor = '#FFFFF1';
                    $('tipoDesp'+indexNotes).style.backgroundColor = '#FFFFF1';
                    $('serie'+indexNotes).style.backgroundColor = '#FFFFF1';
                    $('nf'+indexNotes).style.backgroundColor = '#FFFFF1';
                    $('dataNota'+indexNotes).style.backgroundColor = '#FFFFF1';
                    $('dataVenc'+indexNotes).style.backgroundColor = '#FFFFF1';
                    $('historicoNota'+indexNotes).style.backgroundColor = '#FFFFF1';
                    $('tipoDesp'+indexNotes).value = tipo;
                    $('idTipoDesp'+indexNotes).value = tipo;
                }

                indexNotes++;
            }

    function isAlteraMotorista(){
        var existeAdiamtamento = false;
        for(var i = 0; i <= indexAdiant; i++){
            if($("incluindo"+i) != null){
                existeAdiamtamento = true;
            }
        }

        if (existeAdiamtamento) {
            jQuery('#selectBeneficiario').attr('disabled', 'disabled');

            switch ($('selectBeneficiario').value) {
                case 'm':
                    invisivel($("btMoto"));
                    invisivel($("lixoMoto"));
                    break;
                case 'a':
                    invisivel($('localiza_ajudante'));
                    invisivel($('borrachaAj'));
                    break;
                case 'f':
                    invisivel($('localizarFuncionario'));
                    invisivel($('limparFuncionario'));
                    break;
            }
        } else {
            jQuery('#selectBeneficiario').removeAttr('disabled');

            switch ($('selectBeneficiario').value) {
                case 'm':
                    visivel($("btMoto"));
                    visivel($("lixoMoto"));
                    break;
                case 'a':
                    visivel($('localiza_ajudante'));
                    visivel($('borrachaAj'));
                    break;
                case 'f':
                    visivel($('localizarFuncionario'));
                    visivel($('limparFuncionario'));
                    break;
            }
        }
    }

    function addApropriacao(indexNota, idApropriacao, conta, apropriacao, idVeiculo, veiculo, valor, incluindo, idUnd, und, obsPlano, isAbateComissao,idfornecedor,fornecedor){
        var _tr = '';
        _tr = Builder.node('TR', {
            id:'trApropDesp'+indexNota+'_'+indexApp, 
            className:'CelulaZebra1'},
        [Builder.node('TD', (!incluindo ? '' :
		    [Builder.node('IMG', {
                    src:'img/lixo.png', 
                    title:'Excluir Despesa', 
                    className:'imagemLink',
                    onClick:'excluirApp('+indexNota+','+indexApp+');'})
			])),
            Builder.node('TD',{}),
            Builder.node('TD',
            [Builder.node('INPUT', {
                type:'hidden', 
                name:'idApropriacao_'+indexNota+'_'+indexApp, 
                id:'idApropriacao_'+indexNota+'_'+indexApp,
                value:idApropriacao}),
            Builder.node('INPUT', {
                type:'text', 
                name:'conta_'+indexNota+'_'+indexApp, 
                id:'conta_'+indexNota+'_'+indexApp,
                size:'13', 
                value:conta, 
                className:'inputReadOnly8pt'}),
            
            Builder.node('INPUT', {
                type:'text', 
                name:'apropriacao_'+indexNota+'_'+indexApp, 
                id:'apropriacao_'+indexNota+'_'+indexApp,
                size:'30', 
                value:apropriacao, 
                className:'inputReadOnly8pt'}),
            
            Builder.node('INPUT', {
                type:'button', 
                name:'localizaApp_'+indexNota+'_'+indexApp, 
                id:'localizaApp_'+indexNota+'_'+indexApp,
                value:'...', 
                className:'botoes',
                onClick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=20\',\'Plano_'+indexNota+'_'+indexApp+'\');'})
            ]),

            Builder.node('TD', 
                            (
                                    [
                                            Builder.node('INPUT', {
                                            type:'text', 
                                            name:'descricao_plano_'+indexNota+'_'+indexApp, 
                                            id:'descricao_plano_'+indexNota+'_'+indexApp,
                                            size:'27', 
                                            value:obsPlano, 
                                            className:'fieldMin'})							
                                    ]
                            ),
                                    (
                                        [
                                            Builder.node('INPUT', {
                                                type:'hidden', 
                                                name:'idFornecedor_'+indexNota+'_'+indexApp, 
                                                id:'idFornecedor_'+indexNota+'_'+indexApp,
                                                size:'27', 
                                                value:idfornecedor, 
                                                className:'fieldMin'}),

                                            Builder.node('INPUT', {
                                                type:'text', 
                                                name:'fornecedor_'+indexNota+'_'+indexApp, 
                                                id:'fornecedor_'+indexNota+'_'+indexApp,
                                                size:'27', 
                                                value:fornecedor, 
                                                className:'inputReadOnly8pt'}),

                                            Builder.node('INPUT', {
                                                type:'button', 
                                                name:'localizarFornecedor_'+indexNota+'_'+indexApp,
                                                id:'localizarFornecedor_'+indexNota+'_'+indexApp,
                                                value:'...', 
                                                className:'botoes',
                                                onClick:'javascript:abrirLocalizarFornecedor('+indexNota+')'})
                                        ])
                                    ),
            
            Builder.node('TD',
            [Builder.node('INPUT', {
                type:'hidden', 
                name:'idVeiculo_'+indexNota+'_'+indexApp, 
                id:'idVeiculo_'+indexNota+'_'+indexApp,
                value:idVeiculo}),
            
            Builder.node('INPUT', {
                type:'text', 
                name:'veiculo_'+indexNota+'_'+indexApp, 
                id:'veiculo_'+indexNota+'_'+indexApp,
                size:'12', 
                value:veiculo, 
                className:'inputReadOnly8pt'}),
            
            Builder.node('INPUT', {
                type:'button', 
                name:'localizaVei_'+indexNota+'_'+indexApp, 
                id:'localizaVei_'+indexNota+'_'+indexApp,
                value:'...', 
                className:'botoes',
                onClick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=24\',\'Veiculo_'+indexNota+'_'+indexApp+'\');'})
            ]),
            
            Builder.node('TD',
            [Builder.node('INPUT', {
                type:'text', 
                name:'valorApp_'+indexNota+'_'+indexApp, 
                id:'valorApp_'+indexNota+'_'+indexApp,
                size:'8', 
                maxLength:'12', 
                value:formatoMoeda(valor), 
                className:'fieldMin',
                onchange:'seNaoFloatReset($(\'valorApp_'+indexNota+'_'+indexApp+'\'), \'0.00\');totalNota('+indexNota+');'})
            ]),
                        
            Builder.node('TD',
            [Builder.node('INPUT', {
                type:'hidden', 
                name:'idUnd_'+indexNota+'_'+indexApp, 
                id:'idUnd_'+indexNota+'_'+indexApp,
                value:idUnd}),
            
            Builder.node('INPUT', {
                type:'text', 
                name:'und_'+indexNota+'_'+indexApp, 
                id:'und_'+indexNota+'_'+indexApp,
                size:'5', 
                value:und, 
                className:'inputReadOnly8pt'}),
            
            Builder.node('INPUT', {
                type:'button', 
                name:'localizaUnd_'+indexNota+'_'+indexApp, 
                id:'localizaUnd_'+indexNota+'_'+indexApp,
                value:'...', 
                className:'botoes',
                onClick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=39\',\'Und_'+indexNota+'_'+indexApp+'\');'})
            ]),
            
            Builder.node('TD',{colSpan:'2'},
						[
							Builder.node('INPUT', {
							type:'checkbox', 
							name:'isAbateComissao_'+indexNota+'_'+indexApp, 
							id:'isAbateComissao_'+indexNota+'_'+indexApp,
                                                        onClick:'javascript:totalNota('+indexNota+');'
                                                        }),
							Builder.node('LABEL', 'Abater da comissão')
						]
						)
        ]);
        
        $('TBODYNOTES'+indexNota).appendChild(_tr);

		
        $('isAbateComissao_'+indexNota+'_'+indexApp).checked = isAbateComissao;	
        $('conta_'+indexNota+'_'+indexApp).readOnly = true;
        $('apropriacao_'+indexNota+'_'+indexApp).readOnly = true;
        $('veiculo_'+indexNota+'_'+indexApp).readOnly = true;
        $('und_'+indexNota+'_'+indexApp).readOnly = true;
        
        
        if (idfornecedor != "") {
            $('idFornecedor_'+indexNota+'_'+indexApp).style.display = "";
            $('fornecedor_'+indexNota+'_'+indexApp).style.display = "";
            $('localizarFornecedor_'+indexNota+'_'+indexApp).style.display = "none";
            $('idDescDespesa').innerHTML = "Descrição/Fornecedor";
            
        }else{
            $('idFornecedor_'+indexNota+'_'+indexApp).style.display = "none";
            $('fornecedor_'+indexNota+'_'+indexApp).style.display = "none";
            $('localizarFornecedor_'+indexNota+'_'+indexApp).style.display = "none";
        }
        
        if (!incluindo){
            $('valorApp_'+indexNota+'_'+indexApp).readOnly = true;
            $('localizaVei_'+indexNota+'_'+indexApp).style.display = "none";
            $('localizaApp_'+indexNota+'_'+indexApp).style.display = "none";
            $('valorApp_'+indexNota+'_'+indexApp).style.backgroundColor = '#FFFFF1';
			$('isAbateComissao_'+indexNota+'_'+indexApp).disabled = true;
			$('descricao_plano_'+indexNota+'_'+indexApp).readOnly = false;
        }
        indexApp++;
        
        $("qtdAprop").value = indexApp;

    }

    function alteraTipoDespesa(){
        totalAdiantamento();
        totalDespesasAvista();
        totalAcerto();
    }

    function concatCtrc() {
        var ct = "";
        for (i = 0; i < indexCtrc; ++i){
            ct += (ct == "" ?  $("ctrc_id"+i).value : "," +  $("ctrc_id"+i).value);
        }
      return ct;
    }

    function excluirAdiantamento(incluindo, indexAdiant){
        if (incluindo){
            if (confirm("Deseja Mesmo Excluir este Adiantamento?"))
                Element.remove('tr'+indexAdiant);
                Element.remove('tr2'+indexAdiant);
        }else{
            if(confirm('A exclusão desse Adiantamento só Poderá ser Efetuada pela Rotina de Conciliação Bancária.\n'
                    +'Deseja que o sistema redirecione para tela de conciliação bancária?')){
                    var data = $("dataAdiant"+ indexAdiant).value;
                    var valorA = 0;
                    var numViagem = parseInt($("numviagem").value,10);
                    var motoristaNome = $("motor_nome").value;
                    var motoristaId = $("idmotorista").value;

                    if ($("valorDebAdiant"+ indexAdiant) != null){
                        valorA = $("valorDebAdiant"+ indexAdiant).value;
                    }    
                    if ($("valorAdiant"+ indexAdiant) != null){
                        valorA = $("valorAdiant"+ indexAdiant).value;
                    }    

                    window.open("./jspconciliacaobanco.jsp?visualizarViagem=1&tipodata=dtentrada&conta=0"
                    +"&tipoConsultaCheque=4&dtinicial="+data+"&dtfinal="+data+"&conciliado=todos"+"&doc="+numViagem
                    +"&creditos=ambos&idmotorista="+ motoristaId +"&motor_nome="+motoristaNome
                    +"&valor1="+valorA+"&valor2="+valorA+"&idfilial=0&idfornecedor=0&mostrarTotais=false&isChequeCancelado=false"
                    +"idfornecedor=0","Conciliacao","top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1");
              }
                /*
                 *"./conciliacaobanco?acao=consultar&"+concatFieldValue("tipodata,dtinicial,dtfinal,conta,conciliado,doc,idmotorista,motor_nome,creditos,valor1,valor2")+
                       "&mostrarTotais="+$('mostrarTotais').checked+"&docDe="+$("docDe").value+"&docAte="+$("docAte").value+"&tipoConsultaCheque="+$("tipoConsultaCheque").value+
                       "&idfornecedor="+$('idfornecedor').value+"&fornecedor="+$("fornecedor").value + "&idMotivo=" + $("motivoCancelarCheque").value + "&isChequeCancelado=" + $("mostrarApenasChequesCancelados").checked +
                       "&idfilial="+idFilial);
                 **/
            
        }
        totalAdiantamento();
        totalAcerto();
        isAlteraMotorista();
    }

    function excluirApp(indexNota, indexAprop){
        if (confirm("Deseja Mesmo Excluir esta Apropriação?")){
            Element.remove('trApropDesp'+indexNota+'_'+indexAprop);
            totalNota(indexNota);
        }
    }

    function excluirNota(indexNota){
        if (confirm("Deseja Mesmo Excluir esta Despesa?")){
            Element.remove('trdesp'+indexNota);
            Element.remove('trApropDesp'+indexNota);
            totalDespesasAvista();
            totalAcerto();
        }
    }

    function aoClicarNoLocaliza(idjanela){
        
        //localizando fornecedor
        if(idjanela.split('_')[0] == 'Fornecedor'){
            $('fornecedor'+idjanela.split('_')[1]).value = $('fornecedor').value;
            $('idfornecedor'+idjanela.split('_')[1]).value = $('idfornecedor').value;
            $('historicoNota'+idjanela.split('_')[1]).value = $('descricao_historico').value;
            if ($('idplcustopadrao').value != '0'){
                addApropriacao(idjanela.split('_')[1], $('idplcustopadrao').value, $('contaplcusto').value, $('descricaoplcusto').value, $('veiculo_id').value, $('veiculo').value, 0, true, $("id_und_forn").value, $("sigla_und_forn").value, '', false,"","");
            }
        }else if(idjanela.split('_')[0] == 'Historico'){
            $('historicoNota'+idjanela.split('_')[1]).value = $('descricao_historico').value;
            $('idhistoricoNota'+idjanela.split('_')[1]).value = $('idhist').value;
        }else if(idjanela.split('_')[0] == 'Plano'){
            if (idjanela.split('_')[2] == null){
                addApropriacao(idjanela.split('_')[1], $('idplanocusto_despesa').value, $('plcusto_conta_despesa').value, $('plcusto_descricao_despesa').value, $('veiculo_id').value, $('veiculo').value, 0, true, 0, '', '', false,"","");
            }else{
                $('idApropriacao_'+idjanela.split('_')[1]+'_'+idjanela.split('_')[2]).value = $('idplanocusto_despesa').value;
                $('conta_'+idjanela.split('_')[1]+'_'+idjanela.split('_')[2]).value = $('plcusto_conta_despesa').value;
                $('apropriacao_'+idjanela.split('_')[1]+'_'+idjanela.split('_')[2]).value = $('plcusto_descricao_despesa').value;
            }
        }else if(idjanela.split('_')[0] == 'Veiculo'){
            var bloqueado = validarBloqueioVeiculo("veiculo");
            if(!bloqueado){
                if (idjanela.split('_')[1] == null){
                    $('veiculo_id').value = $('idveiculo').value;
                    $('veiculo').value = $('vei_placa').value;
                }else{
                    $('idVeiculo_'+idjanela.split('_')[1]+'_'+idjanela.split('_')[2]).value = $('idveiculo').value;
                    $('veiculo_'+idjanela.split('_')[1]+'_'+idjanela.split('_')[2]).value = $('vei_placa').value;
                }
                abrirLoginSupervisor('<%=cfg.getPermitirLancamantoOSAbertoVeiculo()%>',<%=TipoAutorizacao.ADV_VEICULO_MANUTECAO.ordinal()%>,0,0);
            }
        }else if(idjanela.split('_')[0] == 'Und'){
            $('idUnd_'+idjanela.split('_')[1]+'_'+idjanela.split('_')[2]).value = $('id_und').value;
            $('und_'+idjanela.split('_')[1]+'_'+idjanela.split('_')[2]).value = $('sigla_und').value;
        }else if(idjanela.split('_')[0] == 'Motorista'){
            var bloqueado = validarBloqueioVeiculoMotorista("veiculo_motorista,carreta_motorista,bitrem_motorista");
            if(!bloqueado){
                $('veiculo_id').value = $('idveiculo').value;
                $('veiculo').value = $('vei_placa').value;
                abrirLoginSupervisor('<%=cfg.getPermitirLancamantoOSAbertoVeiculo()%>',<%=TipoAutorizacao.ADV_VEICULO_MANUTECAO.ordinal()%>,0,0);

                $("Carreta_km_saida").value = $("car_km_atual").value;
                $("Bitrem_km_saida").value = $("bi_km_atual").value;
                carregarSaldo();
                camposReadOnly();
            }
        }else if(idjanela.split('_')[0] == 'Rota'){
            $('idViagemRota_' + $("linhaRota").value).value = $('rota_id').value;
            $('rotaDescricao_' + $("linhaRota").value).value = $('rota_desc').value;
            $('cidadeOrigem_' + $("linhaRota").value).value = $('cidade_origem').value+ "-" + $('uf_origem_rota').value;
            $('idCidadeOrigem_' + $("linhaRota").value).value = $('cidade_origem_id').value;
            $('cidadeDestino_' + $("linhaRota").value).value = $('cidade_destino').value+ "-" + $('uf_destino_rota').value;
            $('idCidadeDestino_' + $("linhaRota").value).value = $('cidade_destino_id').value;
           
            //funcao subtrair
            subtrairValoresMotoristaRota($('diariaMotorista_' + $("linhaRota").value).value, $('pernoiteMotorista_' + $("linhaRota").value).value, $('alimentacaoMotorista_' + $("linhaRota").value).value);
            
            $('diariaMotorista_' + $("linhaRota").value).value = $('vl_diaria_motorista').value;
            $('pernoiteMotorista_' + $("linhaRota").value).value = $('vl_pernoite_motorista').value;
            $('alimentacaoMotorista_' + $("linhaRota").value).value = $('vl_alimentacao_motorista').value;
            
            // funcao somar
            somaValoresMotoristaRota($('diariaMotorista_' + $("linhaRota").value).value, $('pernoiteMotorista_' + $("linhaRota").value).value, $('alimentacaoMotorista_' + $("linhaRota").value).value);
            
        }else if(idjanela == 'Cidade_Origem'){
            $('idCidadeOrigem_' + $("linhaRota").value).value = $('idcidadeorigem').value;
            $('cidadeOrigem_' + $("linhaRota").value).value = $('cid_origem').value + "-" + $('uf_origem').value;
        }else if(idjanela == 'Cidade_Destino'){
            $('idCidadeDestino_' + $("linhaRota").value).value = $('idcidadedestino').value;
            $('cidadeDestino_' + $("linhaRota").value).value = $('cid_destino').value + "-" + $('uf_destino').value;
        }else if(idjanela == 'newFornecedor'){
            var campo3 = "idFornecedorAbast_"+document.getElementById("linha").value;
            var campo4 = "fornecedorAbast_"+document.getElementById("linha").value;
            getObj(campo3).value = getObj("idfornecedor").value
            getObj(campo4).value = getObj("fornecedor").value
        }else if(idjanela == 'Remetente'){
            $('idRemetente_' + $("linhaAdiantamento").value).value = $('idremetente').value;
            $('remetente_' + $("linhaAdiantamento").value).value = $('rem_rzs').value;
            $('idCidadeRemetente_' + $("linhaAdiantamento").value).value = $('idcidadeorigem').value;
        }else if(idjanela == 'Destinatario'){
            $('idDestinatario_' + $("linhaAdiantamento").value).value = $('iddestinatario').value;
            $('destinatario_' + $("linhaAdiantamento").value).value = $('dest_rzs').value;
            $('idCidadeDestinatario_' + $("linhaAdiantamento").value).value = $('cidade_destino_id').value;
        }else if(idjanela == 'Ajudante' && testar == 1){
            $('idAjudante1').value = $('idajudante').value;
            $('nomeAjudante1').value = $('nome').value;

            carregarSaldo(1);
        }else if(idjanela == 'Ajudante' && testar == 2){
            $('idAjudante2').value = $('idajudante').value;
            $('nomeAjudante2').value = $('nome').value;
        }else if(idjanela == 'Bitrem'){
            var bloqueado = validarBloqueioVeiculo("bitrem");
            if(!bloqueado){
                $("Bitrem_km_saida").value = $("bi_km_atual").value;
                camposReadOnly("b");
            }
        }else if(idjanela == 'Carreta'){
            var bloqueado = validarBloqueioVeiculo("carreta");
            if(!bloqueado){
                $("Carreta_km_saida").value = $("car_km_atual").value;
                camposReadOnly("c");
            }
        } else if (idjanela === 'Funcionario') {
            $('idFuncionario').value = $('idfornecedor').value;
            $('nomeFuncionario').value = $('fornecedor').value;

            carregarSaldo(2);
        }


    }

    function subtrairValoresMotoristaRota(vlDiariaMotorista, vlPernoiteMotorista, vlAlimentacaoMotorista){
        $('diariaMotorista').value = colocarVirgula(parseFloat($("diariaMotorista").value) - parseFloat(vlDiariaMotorista));
        $('pernoiteMotorista').value = colocarVirgula(parseFloat($("pernoiteMotorista").value) - parseFloat(vlPernoiteMotorista));
        $('alimentacaoMotorista').value = colocarVirgula(parseFloat($("alimentacaoMotorista").value) - parseFloat(vlAlimentacaoMotorista));
    }
    
    function somaValoresMotoristaRota(vlDiariaMotorista, vlPernoiteMotorista, vlAlimentacaoMotorista){
        $('diariaMotorista').value = formatoMoeda(parseFloat(colocarPonto($("diariaMotorista").value)) + parseFloat(vlDiariaMotorista));
        $('pernoiteMotorista').value = formatoMoeda(parseFloat(colocarPonto($("pernoiteMotorista").value)) + parseFloat(vlPernoiteMotorista));
        $('alimentacaoMotorista').value = formatoMoeda(parseFloat(colocarPonto($("alimentacaoMotorista").value)) + parseFloat(vlAlimentacaoMotorista));
        calcularTotalPlano();
    }
    
    function verVeiculo(tipo){
        var mostrar = false;
        var idVeiculo = 0;
        if (tipo == 'V' && $('veiculo_id').value != '0'){
            idVeiculo = $('veiculo_id').value;
            mostrar = true;
        }else if (tipo == 'C' && $('idcarreta').value != '0'){
            idVeiculo = $('idcarreta').value;
            mostrar = true;
        }else if (tipo == 'B' && $('idbitrem').value != '0'){
            idVeiculo = $('idbitrem').value;
            mostrar = true;
        }

        if (mostrar)
            window.open('./cadveiculo?acao=editar&id=' + idVeiculo ,'Veículo','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
    }
    
    function verAjudante(opcao){
        var mostrar = false;
        var idAjudante = 0;        
        if(opcao == 1 && $('idAjudante1').value != '0'){
            idAjudante = $('idAjudante1').value;
            mostrar = true;
        }else if(opcao == 2 && $('idAjudante2').value != '0'){
            idAjudante = $('idAjudante2').value;
            mostrar = true;
        }
        if(mostrar){
            window.open('./cadfornecedor?acao=editar&id='+ idAjudante, 'Ajudante','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
        }
    }

    function totalNota(indexNota){
        var total = 0;
        for (i = 0; i < indexApp; ++i){
            if ($('valorApp_'+indexNota+'_'+i) != null){
                total += parseFloat($('valorApp_'+indexNota+'_'+i).value);
            }
        }
        $('valorNota'+indexNota).value = formatoMoeda(total);
        totalDespesasAvista();
        totalAcerto();
    }

    function totalAdiantamento(){
        totalCreditoViagemRetorno();

        <%if (acao.equals("iniciarbaixa") || acao.equals("baixado")) {%>
                var tot = parseFloat($('saldoMotorista').value);
                var total = 0;
                var liq = 0;
                var comissao = 0;
                var pagar = 0;
                
                for (x=0; x < indexAdiant; x++){
                    if($('valorAdiant'+x) != null){
                        tot += parseFloat($('valorAdiant'+x).value);
                        
                        if($('contaAdiant'+x).value == "-1"){
                            total += parseFloat($('valorCtrc' + x).value)
                        }
                    }
                    
                    if ($('histAdiant'+x).value.substring(0,20) == 'Acerto do Motorista:'){
                        totAcerto += parseFloat($('valorDebAdiant'+x).value);
                    }
                }
                
                $('totalAdiantado').value = formatoMoeda(tot);
                $('totalCreditoViagemRetorno').value = formatoMoeda(total);
                
                liq = parseFloat($('totalCreditoViagemRetorno').value) + parseFloat($('valorPrevistoViagem').value);
                $('valorLiquido').value = formatoMoeda(liq); 
                
                comissao = ((parseFloat($('percentual_comissao_frete').value) * parseFloat($('valorLiquido').value)) / 100);
                $('comissao').value = formatoMoeda(comissao);

                pagar = parseFloat($('comissao').value) - parseFloat($('totalDesconto').value) + parseFloat($('acrescimos').value);
                $('valorAPagar').value = formatoMoeda(pagar);
                
                for(x=0; x<= indexNotes; x++){
                    for(y=0; y<= indexApp; y++){
                        if($('isComissaoMotorista_'+x) != null){
                            if($('isComissaoMotorista_'+x).value == "true" && $('valorApp_' + x + '_' + y)!= null){
                                $('valorApp_' + x + '_' + y).value = $('valorAPagar').value;
                                $('valorNota' + x).value = $('valorAPagar').value;
                            }
                        }
                    }
                }
        <%}%>
    }
    
    function totalCreditoViagemRetorno(){
        <%if (acao.equals("editar") || acao.equals("iniciar")) {%>
                var total = 0;
                
                for (x=0; x <= $('maxAdiantamento').value; x++){
                    if($('valorAdiant'+x) != null){
                        if($('contaAdiant'+x).value == "-1"){
                            total += parseFloat($('valorAdiant' + x).value)
                        }
                    }
                }

                $('totalCreditoViagemRetorno').value = formatoMoeda(total);
        <%}%>        
    }

    function totalDespesasAvista(){
        var tot=0;
        var totGasto=0;
        var total;
        var comissao;
        var pagar;
        
        <%if (acao.equals("iniciarbaixa") || acao.equals("baixado")) {%>
                for (x=0; x < indexNotes; x++){
                    if($('valorNota'+x) != null && $('tipoDesp'+x).value == 'a'){
                        tot += parseFloat($('valorNota'+x).value);
					}
					for (f=0; f < indexApp; f++){
						if($('idApropriacao_'+x+'_'+f) != null){
							if ($('isAbateComissao_'+x+'_'+f).checked){
								totGasto += parseFloat($('valorApp_'+x+'_'+f).value);
							}
						}
					}	
                }
                
                $('totalDespesas').value = formatoMoeda(tot);
                $('valorGasto').value = formatoMoeda(totGasto); 
                
                total = parseFloat($('valorPrevistoViagem').value) - parseFloat($('valorGasto').value) + parseFloat($('totalCreditoViagemRetorno').value);
                $('valorLiquido').value = formatoMoeda(total);
                comissao = ((parseFloat($('percentual_comissao_frete').value) * parseFloat($('valorLiquido').value)) / 100);
                $('comissao').value = formatoMoeda(comissao);
                pagar = parseFloat($('comissao').value) - parseFloat($('totalDesconto').value) + parseFloat($('acrescimos').value);
                $('valorAPagar').value = formatoMoeda(pagar);
                //atualizando o valor da comissão na despesa
		if (getIndexDespesaComissao() != 0) {
        	    var xy = getIndexDespesaComissao();
	  	    for (f=0; f < indexApp; f++){
                        if($('idApropriacao_'+xy+'_'+f) != null){
                            $('valorApp_'+xy+'_'+f).value = $("valorAPagar").value;
			}
		    }	
		}

                mudaCor(); 
        <%}%>
    }

    function totalAcerto(){
        <%if (acao.equals("iniciarbaixa") || acao.equals("baixado")) {%>
            var totAd = parseFloat($('totalAdiantado').value);
            var totDesp = parseFloat($('totalDespesas').value);
            var resultado = parseFloat(totAd - totDesp - totAcerto);
        <%if (!acao.equals("baixado")) {%>
            if (resultado < 0){
                $('acerto').style.display = 'none';
                $('reembolso').style.display = '';
                $('valorAcertado').value = formatoMoeda(resultado*-1);
            }else{
                $('acerto').style.display = '';
                $('reembolso').style.display = 'none';
                $('valorAcertado').value = formatoMoeda(resultado);
            }
        <%}%>
            $('totalAcerto').value = formatoMoeda(resultado);
        <%}%>
    }

    function getUnidadeCusto(){
        for (z = 0; z <= indexNotes; ++z){
            for (i = 0; i <= indexApp; ++i){
                if ($('idUnd_'+z+'_'+i) != null){
                    if ($('idUnd_'+z+'_'+i).value == '0'){
                        return false;
                    }
                }
            }
        }
        return true;
    }

    function pediMotivo(){
        if ($("cancelado").checked){
            document.getElementById('motivoCancelamento').style.display = '';
            $('lbMotivoCancelamento').innerHTML = 'Motivo:';
        }else {
            document.getElementById('motivoCancelamento').style.display = 'none';
            $('lbMotivoCancelamento').innerHTML = '';
        }
    }

    function inicioCampo(elemento){
        elemento.value = elemento.value.trim();
    }
    
    function validaTipoCalculo(){
        var max = $("maxAbast").value;
        var campoNone = ($("tipoCalculo").value == "km" ? "HorimetroAbast_" : "kmAbast_");
        var campo = ($("tipoCalculo").value == "km" ? "kmAbast_" : "HorimetroAbast_");

        for(var i = 1; i <= max; i++){
            if ($(campo+i) != null){
                $(campoNone+i).style.display = "none";
                $(campo+i).style.display = "";
            }
        }
    }
    
    function divideAbast(posicao){
        var qtdLitros = parseFloat(colocarPonto($("quantidadeAbast_" + posicao).value));
        var valorLitro = parseFloat(colocarPonto($("valorLitroAbast_" + posicao).value));
        var totalAbastecimento  = parseFloat(colocarPonto($("totalAbast_" +posicao).value));
        var resultado = 0;

        if (qtdLitros == 0){
            resultado = totalAbastecimento  / valorLitro;
            $("quantidadeAbast_" + posicao).value = colocarVirgula(resultado,3);
        }else {
            resultado = totalAbastecimento  / qtdLitros;
            $("valorLitroAbast_" + posicao).value = colocarVirgula(resultado,3);
        }
    }

    function multiplicaAbast(posicao){
        var qtdLitros = parseFloat(colocarPonto($("quantidadeAbast_" + posicao).value));
        var valorLitro = parseFloat(colocarPonto($("valorLitroAbast_" + posicao).value));         
        var resultado = 0;      

        resultado = qtdLitros * valorLitro;
        
        $("totalAbast_" + posicao).value = colocarVirgula(resultado,3);
        
       // var total = $("totalAbast_" + posicao).value; 
        
//        resultadoTotalAbastecimento = valorLitro + total;
//       
//        
//        
//        
//                 total= colocarVirgula(resultado,3);
//       qtdTotal += resultadoTotalAbastecimento;
//       
       valorTotalAbastecimento();
        
       
        
    }
    
    function carregarBomba(elemento){
        var idTanque = elemento.value;
        var id = elemento.id.split("_")[1];
        //carrega bombas dependendo de tanque
        new Ajax.Request('BombaControlador?acao=carregarBomba' + '&idTanque=' + idTanque,
        {
            method:'get',
            onSuccess: function(transport){
                var response = transport.responseText;
                var resposta = response;
                carregarAjaxBomba(resposta,id);
            },
            onFailure: function() { alert('Something went wrong...')}
        });
    }
    
    function ValidaCategoria(elemento){
        var categoria = elemento.value;
        var nivelAlteraValor = <%=(nivelAlteraValor)%>
        var id = elemento.id.split("_")[1];
        
        if (categoria =='pr'){ //aparece em tanque / bomba
            $("lbTanque_"+id).style.display= "";
            $("listaTanqueAbast_"+id).style.display= "";
            $("lbBomba_"+id).style.display= "";
            $("bombaAbast_"+id).style.display= "";
            $("lbFornecedor_"+id).style.display= "none";
            $("fornecedorAbast_"+id).style.display = "none";
            $("botaoFornecedorAbast_"+id).style.display = "none";
            $("lbComprovante_"+id).style.display= "none";
            $("comprovanteAbast_"+id).style.display = "none";
            carregarBomba($("listaTanqueAbast_"+ countAbast));
            if (nivelAlteraValor == 4) {
                notReadOnly($("totalAbast_"+id), 'fieldMin');
                notReadOnly($("valorLitroAbast_"+id), 'fieldMin');
            } else {
                readOnly($("totalAbast_"+id), 'inputReadOnly8pt');
                readOnly($("valorLitroAbast_"+id), 'inputReadOnly8pt')
            }
        }else if (categoria =='co'){//aparece fornecedor / num comprovante
            $("lbTanque_"+id).style.display= "none";
            $("listaTanqueAbast_"+id).style.display= "none";
            $("lbBomba_"+id).style.display= "none";
            $("bombaAbast_"+id).style.display= "none";
            $("lbFornecedor_"+id).style.display= "";
            $("fornecedorAbast_"+id).style.display = "";
            $("botaoFornecedorAbast_"+id).style.display = "";
            $("lbComprovante_"+id).style.display= "";
            $("comprovanteAbast_"+id).style.display = "";
            if (nivelAlteraValor == 4) {
                notReadOnly($("totalAbast_"+id), 'fieldMin');
                notReadOnly($("valorLitroAbast_"+id), 'fieldMin');
            } else {
                readOnly($("totalAbast_"+id), 'inputReadOnly8pt');
                readOnly($("valorLitroAbast_"+id), 'inputReadOnly8pt')
            }
        }else if (categoria =='vi'){
            $("lbTanque_"+id).style.display= "none";
            $("listaTanqueAbast_"+id).style.display= "none";
            $("lbBomba_"+id).style.display= "none";
            $("bombaAbast_"+id).style.display= "none";
            $("lbFornecedor_"+id).style.display= "";
            $("fornecedorAbast_"+id).style.display = "";
            $("botaoFornecedorAbast_"+id).style.display = "";
            $("lbComprovante_"+id).style.display= "";
            $("comprovanteAbast_"+id).style.display = "";
            notReadOnly($("totalAbast_"+id), 'fieldMin');
            notReadOnly($("valorLitroAbast_"+id), 'fieldMin');
        }
    }

    function localizarCidadeOrigem(obj){
        $("linhaRota").value = obj.name.split("_")[1];
        launchPopupLocate('./localiza?acao=consultar&idlista=11','Cidade_Origem');
    }
    
    function localizarCidadeDestino(obj){
        $("linhaRota").value = obj.name.split("_")[1];
        launchPopupLocate('./localiza?acao=consultar&idlista=12','Cidade_Destino');
    }

    function localizarRota(obj){
        $("linhaRota").value = obj.name.split("_")[1];
        launchPopupLocate('./localiza?acao=consultar&idlista=63','Rota') ;
    }
    
    function localizarRemetente(obj){
        $("linhaAdiantamento").value = obj.name.split("_")[1];
        launchPopupLocate('./localiza?acao=consultar&idlista=03','Remetente');
    }

    function localizarDestinatario(obj){
        $("linhaAdiantamento").value = obj.name.split("_")[1];
        launchPopupLocate('./localiza?acao=consultar&idlista=04','Destinatario');
    }
    var testar = 0;
    function localizarAjudante1(obj){
       // $("idajudante").value = obj.name.split("_")[1];
        testar = 1;
        launchPopupLocate('./localiza?acao=consultar&idlista=25','Ajudante');
    }
    function localizarAjudante2(obj){
        testar = 2;
       // $("idajudante").value = obj.name.split("_")[1];        
        launchPopupLocate('./localiza?acao=consultar&idlista=25','Ajudante');
    }
        
    function ViagemRota(idViagemRota, idLancamento, rotaDescricao, idCidadeOrigem , cidadeOrigem , 
                        idCidadeDestino , cidadeDestino , observacaoRota, ufOrigem, ufDestino,
                        dataSaida,kmSaida,dataChegada,kmChegada, diariaMotoristaAtualRota, pernoiteMotoristaAtualRota, alimentacaoMotoristaAtualRota){
                            
        this.idViagemRota = (idViagemRota != undefined ? idViagemRota : 0);
        this.idLancamento = (idLancamento != undefined ? idLancamento : 0);
        this.rotaDescricao = (rotaDescricao != undefined ? rotaDescricao : "");
        this.idCidadeOrigem = (idCidadeOrigem != undefined ? idCidadeOrigem : 0);
        this.cidadeOrigem = (cidadeOrigem != undefined ? cidadeOrigem : "");
        this.idCidadeDestino = (idCidadeDestino != undefined ? idCidadeDestino : 0);
        this.cidadeDestino  = (cidadeDestino != undefined ? cidadeDestino : "");
        this.observacaoRota  = (observacaoRota != undefined ? observacaoRota : "");
        this.ufOrigem = (ufOrigem != undefined ? ufOrigem : "");
        this.ufDestino = (ufDestino != undefined ? ufDestino : "");
        this.dataSaida = (dataSaida != undefined ? dataSaida : "");
        this.kmSaida = (kmSaida != undefined ? kmSaida : 0);
        this.dataChegada = (dataChegada != undefined ? dataChegada : "");
        this.kmChegada = (kmChegada != undefined ? kmChegada : 0);
        this.diariaMotoristaAtualRota = (diariaMotoristaAtualRota != undefined ? diariaMotoristaAtualRota : 0);
        this.pernoiteMotoristaAtualRota = (pernoiteMotoristaAtualRota != undefined ? pernoiteMotoristaAtualRota : 0);
        this.alimentacaoMotoristaAtualRota = (alimentacaoMotoristaAtualRota != undefined ? alimentacaoMotoristaAtualRota : 0);
    }
    
    
    
    function ViagemAbastecimento(dtAbastecimento, categoria,tanque, bomba,quantidade,
                                 km, encheu, valorLitro,idFornecedor,fornecedor,comprovante,
                                 combustivel,id, veiculoId, horimetro, media,isOrigemMobile){

        this.dtAbastecimento = (dtAbastecimento != undefined ? dtAbastecimento : dataAtual);
        this.categoria = (categoria != undefined ? categoria : 'vi');
        this.tanque = (tanque != undefined ? tanque : "");
        this.bomba = (bomba != undefined ? bomba : "");
        this.quantidade = (quantidade != undefined ? quantidade : '1,000');
        this.km = (km != undefined ? km : 0);
        this.encheu  = (encheu != undefined ? encheu : true);
        this.valorLitro  = (valorLitro != undefined ? valorLitro : '0,000');
        this.idFornecedor = (idFornecedor != undefined ? idFornecedor : 0);
        this.fornecedor = (fornecedor != undefined ? fornecedor : "");
        this.comprovante = (comprovante != undefined ? comprovante : "");
        this.combustivel = (combustivel != undefined ? combustivel : "0");
        this.id = (id != undefined ? id : 0);
        this.veiculoId = (veiculoId != undefined ? veiculoId : 0);
        this.horimetro = (horimetro != undefined ? horimetro : 0);        
        this.media = (media != undefined ? media : '0,00');
        this.isOrigemMobile = (isOrigemMobile != undefined ? isOrigemMobile : false);
        
    }
    
    function ViagemDescontoMotorista(idViagemDescontoMotorista, idPlanoCusto, descricaoPlanoCusto, 
                                     valor , historico){
                                         
        this.idViagemDescontoMotorista = (idViagemDescontoMotorista != undefined ? idViagemDescontoMotorista : 0);
        this.idPlanoCusto = (idPlanoCusto != undefined ? idPlanoCusto : 0);
        this.descricaoPlanoCusto = (descricaoPlanoCusto != undefined ? descricaoPlanoCusto : "");
        this.valor = (valor != undefined ? valor : 0);
        this.historico = (historico != undefined ? historico : "");
    }

    function removerRota(index){
        var descricao = $("rotaDescricao_"+index).value;
        var id = $("idLancamento_"+index).value;
        if(confirm("Deseja Excluir a Rota \'"+descricao+"\'?")){
            if(confirm("Tem certeza?")){

                var vlDiaria = roundABNT(parseFloat($("diariaMotorista").value) - parseFloat($("diariaMotorista_" + index).value));
                var vlPernoite = roundABNT(parseFloat($("pernoiteMotorista").value) - parseFloat($("pernoiteMotorista_" + index).value));
                var vlAlimentacao = roundABNT(parseFloat($("alimentacaoMotorista").value) - parseFloat($("alimentacaoMotorista_" + index).value));

                $('diariaMotorista').value = formatoMoeda(vlDiaria);
                $('pernoiteMotorista').value = formatoMoeda(vlPernoite);
                $('alimentacaoMotorista').value = formatoMoeda(vlAlimentacao);
                
                calcularTotalPlano();
                Element.remove($("trRota_"+index));
                if (id != 0) {
                    new Ajax.Request("./cadviagem.jsp?acao=excluirRota&idRota="+id,
                    {
                        method:'get',
                        onSuccess: function(){ alert('Item removido com sucesso!') },
                        onFailure: function(){ alert('Something went wrong...') }
                    });     
                }
            }
        }
    }

    var countRota = 0;
    function addViagemRota(rota){
        countRota++;

        if(rota == null || rota == undefined){
            rota = new ViagemRota();
        }

        //campos
        var hid1_ = Builder.node("INPUT",{
            type:"hidden",
            id:"idViagemRota_"+countRota,
            name:"idViagemRota_"+countRota,
            value: rota.idViagemRota});

        var hid2_ = Builder.node("INPUT",{
            type:"hidden",
            id:"idCidadeOrigem_"+countRota,
            name:"idCidadeOrigem_"+countRota,
            value: rota.idCidadeOrigem});

        var hid3_ = Builder.node("INPUT",{
            type:"hidden",
            id:"idCidadeDestino_"+countRota,
            name:"idCidadeDestino_"+countRota,
            value: rota.idCidadeDestino});

        var hid4_ = Builder.node("INPUT",{
            type:"hidden",
            id:"idLancamento_"+countRota,
            name:"idLancamento_"+countRota,
            value: rota.idLancamento});
        
        var hid5_ = Builder.node("INPUT",{
            type:"hidden",
            id:"diariaMotorista_"+countRota,
            name:"diariaMotorista_"+countRota,
            value: formatoMoeda(rota.diariaMotoristaAtualRota)});
        
        var hid6_ = Builder.node("INPUT",{
            type:"hidden",
            id:"pernoiteMotorista_"+countRota,
            name:"pernoiteMotorista_"+countRota,
            value: formatoMoeda(rota.pernoiteMotoristaAtualRota)});
        
        var hid7_ = Builder.node("INPUT",{
            type:"hidden",
            id:"alimentacaoMotorista_"+countRota,
            name:"alimentacaoMotorista_"+countRota,
            value: formatoMoeda(rota.alimentacaoMotoristaAtualRota)});
                

        // Descricao Rota
        var inp1_ = Builder.node("INPUT",{
            type:"text",
            id:"rotaDescricao_"+countRota,
            name:"rotaDescricao_"+countRota,
            value: rota.rotaDescricao,
            size: "7",
            className:"inputtexto"});
        readOnly(inp1_);

        // Cidade Origem
        var inp2_ = Builder.node("INPUT",{
            type:"text",
            id:"cidadeOrigem_"+countRota,
            name:"cidadeOrigem_"+countRota,
            value: rota.cidadeOrigem + "-" + rota.ufOrigem,
            size: "12",
            className:"inputtexto" });
        readOnly(inp2_);

        // Cidade Destino
        var inp3_ = Builder.node("INPUT",{
            type:"text",
            id:"cidadeDestino_"+countRota,
            name:"cidadeDestino_"+countRota,
            value: rota.cidadeDestino + "-" + rota.ufDestino,
            size: "12",
            className:"inputtexto" });
        readOnly(inp3_);

        //Observacao
        var inp4_ = Builder.node("INPUT",{
            type:"text",
            id:"observacaoRota_"+countRota,
            name:"observacaoRota_"+countRota,
            size : "12" ,
            value: rota.observacaoRota,
            className:"inputtexto" });

        var _img0 = Builder.node("IMG",{
            src:"img/lixo.png",
            onClick:"removerRota("+countRota+");"});

        var _img1 = Builder.node("IMG",{
            src:"img/borracha.gif",
            className:"imagemLink",
            onClick:"javascript:$('idViagemRota_"+countRota+"').value='0';$('rotaDescricao_"+countRota+"').value='';"});

        var _img2= Builder.node("IMG",{
            src:"img/borracha.gif",
            className:"imagemLink",
            onClick:"javascript:$('idCidadeOrigem_"+countRota+"').value='0';$('cidadeOrigem_"+countRota+"').value='';"});

        var _img3= Builder.node("IMG",{
            src:"img/borracha.gif",
            className:"imagemLink",
            onClick:"javascript:$('idCidadeDestino_"+countRota+"').value='0';$('cidadeDestino_"+countRota+"').value='';"});

        var bot0_ = Builder.node("INPUT",{className:"inputBotaoMin",
            id:"localizaRota_"+countRota,
            name:"localizaRota_"+countRota,
            type:"button", value:"...",
            onClick:"localizarRota(this);"});

        var bot1_ = Builder.node("INPUT",{className:"inputBotaoMin", 
            id:"localizaCidadeOrigem_"+countRota,
            name:"localizaCidadeOrigem_"+countRota,
            type:"button", value:"...",
            onClick:"localizarCidadeOrigem(this);"});

        var bot2_ = Builder.node("INPUT",{className:"inputBotaoMin",
            id:"localizaCidadeDestino_"+countRota,
            name:"localizaCidadeDestino_"+countRota,
            type:"button",
            value:"...",
            onClick:"localizarCidadeDestino(this);"});
        //Data de Saída
        var inputDtSaida = Builder.node("input",{
            type:"text",size:10,name:"rotaDataSaida"+countRota, 
            id:"rotaDataSaida"+countRota, className:'fieldDateMin', 
            value: rota.dataSaida,onkeypress:"fmtDate(this, event)",
            maxlength:"10",size:"11",onBlur:"alertInvalidDate(this)"
        })
        //Kilometragem de Saida
        var inputKmSaida = Builder.node("input",{
            type:"text", id:"rotaKmSaida"+countRota,
            name:"rotaKmSaida"+countRota, size:"10",
            className:"fieldMin styleValor",
            value: rota.kmSaida,
            onKeyPress: "mascara(this, soNumeros)"
        })
        //Data de Chegada
        var inputDtChegada = Builder.node("input",{
            type:"text",size:10,name:"rotaDataChegada"+countRota, 
            id:"rotaDataChegada"+countRota, className:'fieldDateMin', 
            value: rota.dataChegada,onkeypress:"fmtDate(this, event)",
            maxlength:"10",size:"11",onBlur:"alertInvalidDate(this)"
        })
        //Kilometragem de Chegada
        var inputKmChegada = Builder.node("input",{
            type:"text", id:"rotaKmChegada"+countRota,
            name:"rotaKmChegada"+countRota, size:"10",
            className:"fieldMin styleValor",
            value: rota.kmChegada,
            onKeyPress: "mascara(this, soNumeros)"
        })
        
        var td0_ = Builder.node("TD",{});
        var td1_ = Builder.node("TD",{});
        var td2_ = Builder.node("TD",{});
        var td3_ = Builder.node("TD",{});
        var td4_ = Builder.node("TD",{});
        var td5_ = Builder.node("TD",{});
        var td6_ = Builder.node("TD",{});
        var td7_ = Builder.node("TD",{});
        var td8_ = Builder.node("TD",{});
        var td9_ = Builder.node("TD",{});
        var td10_ = Builder.node("TD",{});
        var td11_ = Builder.node("TD",{});        
        

        td0_.appendChild(_img0);

        td1_.appendChild(hid1_);
        td1_.appendChild(inp1_);
        td1_.appendChild(bot0_);
        td1_.appendChild(_img1);

        td2_.appendChild(hid2_);
        td2_.appendChild(inp2_);
        td2_.appendChild(bot1_);
        td2_.appendChild(_img2);
        
        td3_.appendChild(inputDtSaida);
        
        td4_.appendChild(inputKmSaida);
        
        td5_.appendChild(hid3_);
        td5_.appendChild(inp3_);
        td5_.appendChild(bot2_);
        td5_.appendChild(_img3);
        
        td6_.appendChild(inputDtChegada);
        
        td7_.appendChild(inputKmChegada);

        td8_.appendChild(hid4_);
        td8_.appendChild(inp4_);
        
        td9_.appendChild(hid5_);
        td10_.appendChild(hid6_);
        td11_.appendChild(hid7_);
        
        var tr1_ = Builder.node("TR",{
            className:"CelulaZebra2",
            id:"trRota_"+countRota});

        tr1_.appendChild(td0_);
        tr1_.appendChild(td1_);
        tr1_.appendChild(td2_);
        tr1_.appendChild(td3_);
        tr1_.appendChild(td4_);
        tr1_.appendChild(td5_);
        tr1_.appendChild(td6_);
        tr1_.appendChild(td7_);
        tr1_.appendChild(td8_);
        tr1_.appendChild(td9_);
        tr1_.appendChild(td10_);
        tr1_.appendChild(td11_);
        
        
        //inserindo outra tabela que possuirá a tabela com os tipos de veiculos

        $("tbRota").appendChild(tr1_);

        $("maxRota").value = countRota;
    }
    
    
    
    var countAbast = 0;
    function addAbastecimento(abastecim){
        if($("veiculo_id").value == 0){
            alert("Selecione o Veículo Primeiro!");
            return false;
        }        
       
        if(abastecim == null || abastecim == undefined){
            abastecim = new ViagemAbastecimento();
        }
        
        countAbast++;
        $('trAbastecimento').style.display = "";

        var _tr = Builder.node("tr", {
            name: "tr2_" + countAbast, 
            id: "tr2_" + countAbast,  
            className: "CelulaZebra2"});

        var _td0 = Builder.node("td");

        var _img0 = Builder.node('IMG', abastecim.isOrigemMobile ?  {
                        name: 'origemMobileAbastecimento'+indexNotes,
                        id:'origemMobileAbastecimento'+indexNotes,
                        src: 'img/icone-gw-mobile.png',
                        width: '25',
                        height: '25',
                        border: '0',
                        align: "center",
                        title: 'Sincronizada pelo GW Mobile'
                    } : '');
        _td0.appendChild(_img0);



        // td Veiculo
        var _td1 = Builder.node("td");
        
        var _ip1 = Builder.node("select", {
            name: "veiculoAbast_" + countAbast, 
            id: "veiculoAbast_" + countAbast , 
            className: "fieldMin", 
            onchange:"ValidaCategoria(this);", 
            style:"width:75px"});
        
        var _op1 = Builder.node("option", {
            value: $("veiculo_id").value});
        
        Element.update(_op1, $("veiculo").value);
        _ip1.appendChild(_op1);
        
        if($("equipadoCarr").value != "k" && $("equipadoCarr").value != ""){
            var _op1_1 = Builder.node("option", {
                value: $("idcarreta").value});
            
            Element.update(_op1, $("car_placa").value);
            _ip1.appendChild(_op1_1);
        }
        
        if($("equipadoBi").value != 'k' && $("equipadoBi").value != ''){
            var _op1_2 = Builder.node("option", {
                value: $("idbiTrem").value});
            
            Element.update(_op1, $("bi_placa").value);
            _ip1.appendChild(_op1_2);
        }
   
        _td1.appendChild(_ip1);
        
        //data abastecimento e idAbastecimento
        var _td2 = Builder.node("td");//novo elemento campo
        
        var _ip2_2 = Builder.node("input", {
            name: "dtAbastecimento_" + countAbast, 
            id: "dtAbastecimento_" + countAbast,
            type: "text", 
            value: abastecim.dtAbastecimento, 
            size: "11", 
            className:"fieldDateMin", 
            onblur:"alertInvalidDate(this);", 
            onkeypress : "fmtDate(this, event)", 
            maxlength:"10"});
        
        var _ip2_1 = Builder.node("input", {
            name: "idAbast_" + countAbast, 
            id: "idAbast_" + countAbast,
            type: "hidden", 
            value: abastecim.id});
        
        _td2.appendChild(_ip2_1);
        _td2.appendChild(_ip2_2); // Atualiza

        //Categoria
        var _td3 = Builder.node("td");
        
        var _ip3 = Builder.node("select", {
            name: "listaCategoriaAbast_" + countAbast, 
            id: "listaCategoriaAbast_" + countAbast , 
            className: "fieldMin", 
            onchange:"ValidaCategoria(this);", 
            style:"width:70px"});
        
        var _op3 = Builder.node("option", {
            value: 'pr'});
        
        Element.update(_op3, "Próprio");
        _ip3.appendChild(_op3);
        
        var _op3 = Builder.node("option", {
            value: 'co'});
        
        Element.update(_op3, "Conveniados");
        _ip3.appendChild(_op3);
        
        var _op3 = Builder.node("option", {
            value: 'vi'});
        
        Element.update(_op3, "À vista");
        _ip3.appendChild(_op3);
        
        _td3.appendChild(_ip3);
        _ip3.value = abastecim.categoria;
        
        //tanque
        var _td4 = Builder.node("td");
        
        var _lbTanque4 = Builder.node("label", {
            name: "lbTanque_"+countAbast, 
            id:"lbTanque_"+countAbast, 
            style:"margin-left:5px"});
        
        var _ipTanque4 = Builder.node("select", {
            name: "listaTanqueAbast_" + countAbast, 
            id: "listaTanqueAbast_" + countAbast , 
            className: "fieldMin", 
            onchange:"carregarBomba(this);carregarValorLitro(this.value,"+countAbast+")" , 
            style:"width:80px"});
        
        <%if (listaTanque != null){
            for(Tanque tipoTanque : listaTanque){%>
                var _opTanque4 = Builder.node("option", {
                    value: <%=tipoTanque.getId()%>});
                
                Element.update(_opTanque4, "<%=tipoTanque.getDescricao()%>");
                _ipTanque4.appendChild(_opTanque4); 
          <%}
        }%>
        _ipTanque4.value = abastecim.tanque;

        //bomba
        var _lbBomba4 = Builder.node("label", {
            name: "lbBomba_"+countAbast, 
            id:"lbBomba_"+countAbast, 
            style:"margin-left:5px"});
        
        var _ipBomba4 = Builder.node("select", {
            name: "bombaAbast_" + countAbast, 
            id: "bombaAbast_" + countAbast , 
            className: "fieldMin", 
            style:"width:80px"});
        
        <%if (listaBomba != null){
            for(Bomba tipoBomba : listaBomba){%>
                var _opBomba4 = Builder.node("option", {
                    value: <%=tipoBomba.getId()%>});
                
                Element.update(_opBomba4, "<%=tipoBomba.getDescricao()%>");
                _ipBomba4.appendChild(_opBomba4);
        <%}
        }%>
        _ipBomba4.value = abastecim.bomba;

        //fornecedor
        var _lbFornecedor4 = Builder.node("label", {
            name: "lbFornecedor_"+countAbast, 
            id:"lbFornecedor_"+countAbast, 
            style:"margin-left:5px"});
        
        var _ipFornecedor4 = Builder.node("input", {
            name: "fornecedorAbast_" + countAbast, 
            id: "fornecedorAbast_" + countAbast, 
            type:"text", 
            value: abastecim.fornecedor, 
            size: "13", 
            className: "inputReadOnly", 
            readonly:true});
        
        var _ipFornecedorId4 = Builder.node("input", {
            name: "idFornecedorAbast_" + countAbast, 
            id: "idFornecedorAbast_" + countAbast, 
            type:"hidden", 
            value: abastecim.idFornecedor});
        
        var _ipFornecedorBotao4 = Builder.node("input", {
            name: "botaoFornecedorAbast_"+countAbast, 
            id: "botaoFornecedorAbast_"+countAbast, 
            type:"button", 
            value: "...", 
            style:"margin-left:5px",
            className: "inputBotaoMin", 
            onClick:"abrirLocalizarFornecedor(" + countAbast + ")"});

        //Comprovante
        var _lbComprovante4 = Builder.node("label", {
            name: "lbComprovante_"+countAbast, 
            id:"lbComprovante_"+countAbast, 
            style:"margin-left:4px"});
        
        var _ipComprovante4 = Builder.node("input", {
            name: "comprovanteAbast_" + countAbast, 
            id: "comprovanteAbast_" + countAbast, 
            type:"text", 
            value: abastecim.comprovante, 
            size: "6",
            maxlength: 10,
            onkeyup:'numeros('+countAbast+')',
            className: "fieldMin"});

        _td4.appendChild(_lbTanque4);
        _td4.appendChild(_ipTanque4);
        _td4.appendChild(_lbBomba4);
        _td4.appendChild(_ipBomba4);
        _td4.appendChild(_lbFornecedor4);
        _td4.appendChild(_ipFornecedor4);
        _td4.appendChild(_ipFornecedorId4);
        _td4.appendChild(_ipFornecedorBotao4);
        _td4.appendChild(_lbComprovante4);
        _td4.appendChild(_ipComprovante4);
    
       //combustivel
        var _td6 = Builder.node("td");

        var _ipCombustivel6 = Builder.node("select", {name: "combustivelAbast_" + countAbast, id: "combustivelAbast_" + countAbast, className: "fieldMin"});
        var isPrimeiro = true;
        var primeiro = "";
        var _opCombustivel6;
        var _ipHCombustivel6;
        var _ipHCombustivel6_1;
        var _ipHCombustivel6_2;
        var primeiroAbast = 0;
        _opCombustivel6 = Builder.node("option", {value: "0"});
        Element.update(_opCombustivel6, "Selecione");
        _ipCombustivel6.appendChild(_opCombustivel6);
        <%if (listaComb != null){
            for(Combustivel comb : listaComb){%>
            _opCombustivel6 = Builder.node("option", {
                value: "<%=comb.getId()%>"});
            
            primeiroAbast = "<%=comb.getId()%>";
            
            _ipHCombustivel6 = Builder.node("input", {
                type:"hidden",
                value: '<%=comb.getPlanoCusto().getIdconta()%>', 
                id:"combustivelAbast_" + countAbast + "_<%=comb.getId()%>", 
                name:"combustivelAbast_" + countAbast + "_<%=comb.getId()%>"});
            
            _ipHCombustivel6_1 = Builder.node("input", {
                type:"hidden",
                value: '<%=comb.getPlanoCusto().getConta()%>', 
                id:"contaCombustivelAbast_" + countAbast + "_<%=comb.getId()%>", 
                name:"contaCombustivelAbast_" + countAbast + "_<%=comb.getId()%>"});
            
            _ipHCombustivel6_2 = Builder.node("input", {
                type:"hidden",
                value: '<%=comb.getPlanoCusto().getDescricao()%>', 
                id:"descricaoCombustivelAbast_" + countAbast + "_<%=comb.getId()%>", 
                name:"descricaoCombustivelAbast_" + countAbast + "_<%=comb.getId()%>"});
            
            Element.update(_opCombustivel6, "<%=comb.getDescricao()%>");
            _ipCombustivel6.appendChild(_opCombustivel6);
            
            _td6.appendChild(_ipHCombustivel6);
            _td6.appendChild(_ipHCombustivel6_1);
            _td6.appendChild(_ipHCombustivel6_2);
        <%}
        }%>

        _td6.appendChild(_ipCombustivel6);
        _ipCombustivel6.value = abastecim.combustivel;
       
        //Quantidade
        var _td7 = Builder.node("td");
        var _ipValorLitro7 = Builder.node("input", {
            name: "quantidadeAbast_" + countAbast, 
            id: "quantidadeAbast_" + countAbast,
            style:"margin-left:5px", 
            type:"text", 
            value: colocarVirgula(abastecim.quantidade,3) , 
            size: "6", 
            className: "fieldMin",
            onKeyPress:"mascara(this, reais,3)", 
            onBlur:"setZero(this), multiplicaAbast(" + countAbast + "), zeraMedia("+countAbast+");"});
        
        _td7.appendChild(_ipValorLitro7);

        //valor litro
        var _td8 = Builder.node("td");
        var _ipQuantidade8 = Builder.node("input", {
            name: "valorLitroAbast_" + countAbast, 
            id: "valorLitroAbast_" + countAbast, 
            type:"text", 
            value: colocarVirgula(abastecim.valorLitro,3), 
            size: "5",
            readOnly: true,
            className: "fieldMin",
            onKeyPress:"mascara(this, reais,3)", 
            onBlur:"setZero(this), multiplicaAbast(" + countAbast + ");"});
        //
        _td8.appendChild(_ipQuantidade8);

        //total abastecimento
        var _td5 = Builder.node("td");
        var _ipTotal = Builder.node("input", {
            name: "totalAbast_" + countAbast, 
            id: "totalAbast_" + countAbast, 
            type:"text", 
            value: colocarVirgula(abastecim.valorLitro,3), 
            size: "5",
            readOnly: true,
            className: "fieldMin",
            onkeypress:"mascara(this, reais,3)", 
            onblur:"setZero(this), divideAbast("+countAbast+"), valorTotalAbastecimento();"});
        
        _td5.appendChild(_ipTotal);

        //km
        var _td9 = Builder.node("td");
        var _ipKm9 = Builder.node("input", {
            name: "kmAbast_" + countAbast, 
            id: "kmAbast_" + countAbast, 
            type:"text", 
            value: abastecim.km, 
            size: "6", 
            className: "fieldMin",
            onkeypress:"mascara(this, soNumeros), zeraMedia("+countAbast+")"});
        
        //horimetro
        var _ipHorim5 = Builder.node("input", {
            name: "HorimetroAbast_" + countAbast, 
            id: "HorimetroAbast_" + countAbast, 
            type:"text", 
            value: abastecim.horimetro, 
            size: "6", 
            className: "fieldMin",
            onkeypress:"mascara(this, soNumeros), zeraMedia("+countAbast+")"});
        
        _td9.appendChild(_ipKm9);
        _td9.appendChild(_ipHorim5);

        //encheu
        var _td10 = Builder.node("td", {
            align:"center"});
        
        var _ipEncheu10 = Builder.node("input", {
            name: "encheuAbast_" + countAbast, 
            id: "encheuAbast_" + countAbast, 
            type:"checkbox", 
            size: "8", 
            value: "encheu"});
        
        _td10.appendChild(_ipEncheu10);

        //excluir
        var _td11 = Builder.node("td");
        var _ipExcluir11 = Builder.node("img", {
            src: "img/lixo.png",  
            onclick:"excluirAbastecimento("+ countAbast +");"});
        
        _td11.appendChild(_ipExcluir11);
        
        
        //MEDIA
        var _tdMedia = Builder.node("td",{class:"textoCampos"});
        var _labelMedia = Builder.node("label", {id:"media_"+countAbast});
        _labelMedia.innerHTML = colocarVirgula(parseFloat(abastecim.media));
        if (abastecim.encheu=='false' || abastecim == undefined) {
            _labelMedia.style.display = "none";
        }
        _tdMedia.update(_labelMedia);

        _tr.appendChild(_td0);
        _tr.appendChild(_td1);
        _tr.appendChild(_td2);
        _tr.appendChild(_td3);
        _tr.appendChild(_td4);
        _tr.appendChild(_td6);
        _tr.appendChild(_td7);
        _tr.appendChild(_td8);
        _tr.appendChild(_td5);
        _tr.appendChild(_td9);
        _tr.appendChild(_td10);
        _tr.appendChild(_tdMedia);
        _tr.appendChild(_td11);

        //implementa
        $("abastecimento").appendChild(_tr);
        
        $("encheuAbast_"+countAbast).checked = (abastecim.encheu=='false'?false:true);
        $("lbTanque_"+countAbast).innerHTML="Tanque: ";
        $("lbBomba_"+countAbast).innerHTML="Bomba: ";
        $("lbFornecedor_"+countAbast).innerHTML="For.: ";
        $("lbComprovante_"+countAbast).innerHTML="Comp.: ";

        ValidaCategoria($("listaCategoriaAbast_"+countAbast));

        if (abastecim.categoria == "pr"){
            carregarBomba($("listaTanqueAbast_"+countAbast));
        }

        $("combustivelAbast_"+countAbast).value = abastecim.combustivel;
        if (abastecim.combustivel == 0){
            $("combustivelAbast_"+countAbast).value = primeiroAbast;
        }else{
            $("combustivelAbast_"+countAbast).value = abastecim.combustivel;
        }
        $("maxAbast").value = countAbast;        

        applyFormatter();
        multiplicaAbast(countAbast);
        if($("tipoCalculo").value == "km"){
            $("HorimetroAbast_"+countAbast).style.display = "none";
            $("kmAbast_"+countAbast).style.display = "";
        }else{
            $("HorimetroAbast_"+countAbast).style.display = "";
            $("kmAbast_"+countAbast).style.display = "none";
        }
    }

    function calcularTotalMedia(count){
        var litros = parseFloat(0);
        for(var i = 1; i <= countAbast; i++){
            litros = parseFloat(litros) + parseFloat($("quantidadeAbast_"+i).value);
        }
        if($("kmAbast_"+countAbast)!=null){
            $("totalMedia").innerHTML = colocarVirgula(parseFloat((($("kmAbast_"+countAbast).value - $("kmAbast_1").value)) / litros));
        }
    }

    function zeraMedia(index){
        $("media_"+index).innerHTML = "---";
        $("totalMedia").innerHTML = "---";
    }
    
    function carregarValorLitro(id,index){
        <%if (listaTanque != null){
            for(Tanque tipoTanque : listaTanque){%>
                if(id == <%=tipoTanque.getId()%>){
                    $("valorLitroAbast_"+index).value = colocarVirgula('<%=tipoTanque.getValorLitro()%>',4);
                    multiplicaAbast(index);
                }
                
                
          <%}
        }%>
        
    }
    
    var countDesconto = 0;
    function addDesconto(desconto){
        countDesconto++;

        if(desconto == null || desconto == undefined){
            desconto = new ViagemDescontoMotorista();
        }
        
        // Id Desconto
        var hid1_ = Builder.node("INPUT",{
            type:"hidden",
            id:"idViagemDescontoMotorista_"+countDesconto,
            name:"idViagemDescontoMotorista_"+countDesconto,
            value: desconto.idViagemDescontoMotorista});
        
        // Id plano de custo
        var hid2_ = Builder.node("INPUT",{
            type:"hidden",
            id:"idPlanoCusto_"+countDesconto,
            name:"idPlanoCusto_"+countDesconto,
            value: desconto.idPlanoCusto});

        // Descricao plano de custo
        var inp1_ = Builder.node("INPUT",{
            type:"text",
            id:"descricaoPlanoCusto_"+countDesconto,
            name:"descricaoPlanoCusto_"+countDesconto,
            value: desconto.descricaoPlanoCusto,
            size: "25",
            className:"inputtexto"});
        readOnly(inp1_);

        // valor
        var inp2_ = Builder.node("INPUT",{
            type:"text",
            id:"valor_"+countDesconto,
            name:"valor_"+countDesconto,
            value: desconto.valor,
            size: "7",
            className:"inputtexto" });
        readOnly(inp2_);
        
        calculaDesconto(desconto.valor);

        // historico
        var inp3_ = Builder.node("INPUT",{
            type:"text",
            id:"historico_"+countDesconto,
            name:"historico_"+countDesconto,
            value: desconto.historico,
            size: "65",
            className:"inputtexto" });
        readOnly(inp3_);

        var td0_ = Builder.node("TD",{
            width:"25%",
            align:"center"});
        
        var td1_ = Builder.node("TD",{
            width:"7%",
            align:"center"});
        
        var td2_ = Builder.node("TD",{
            width:"40%",
            align:"center"});

        td0_.appendChild(hid1_);
        td0_.appendChild(hid2_);
        td0_.appendChild(inp1_);

        td1_.appendChild(inp2_);

        td2_.appendChild(inp3_);

        var tr1_ = Builder.node("TR",{
            className:"CelulaZebra2",
            id:"trDesconto_"+countDesconto});

        tr1_.appendChild(td0_);
        tr1_.appendChild(td1_);
        tr1_.appendChild(td2_);

        $("tbDesconto").appendChild(tr1_);

        $("maxDesconto").value = countDesconto;
        
        calculaDesconto();
    }
    
    function calculaDesconto(valor){
        if(valor!= undefined){
            var format;
            var total = $("totalDesconto").value;

            format = parseFloat(total) + parseFloat(valor);
            
            $("totalDesconto").value = formatoMoeda(format);
            $("desconto").value = formatoMoeda(format);
            
            totalDespesasAvista()
        }
    }
    
    function mudaCor(){
        var valor = $("valorAPagar").value;
        
        if(valor<0){
            $("valorAPagar").style.color='red';
        }else{
            $("valorAPagar").style.color='black';
        }
    }
    
    function calcularTotalPlano(){
        
            var totalDiariaMotorista = parseFloat($('diariaMotorista').value) * parseFloat($('quantidadeDiariaMotorista').value);
            $('totalDiariaMotorista').value = formatoMoeda(totalDiariaMotorista);
            
            var totalDiariaAjudante = parseFloat($('diariaAjudante').value) * parseFloat($('quantidadeDiariaAjudante').value);
            $('totalDiariaAjudante').value = formatoMoeda(totalDiariaAjudante);
            
            var totalDiariaAjudante2 = parseFloat($('diariaAjudante2').value) * parseFloat($('quantidadeDiariaAjudante2').value);
            $('totalDiariaAjudante2').value = formatoMoeda(totalDiariaAjudante2);
            
            var totalPernoiteMotorista = parseFloat($('pernoiteMotorista').value) * parseFloat($('quantidadePernoiteMotorista').value);
            $('totalPernoiteMotorista').value = formatoMoeda(totalPernoiteMotorista);
            
            var totalPernoiteAjudante = parseFloat($('pernoiteAjudante').value) * parseFloat($('quantidadePernoiteAjudante').value);
            $('totalPernoiteAjudante').value = formatoMoeda(totalPernoiteAjudante);
            
            var totalPernoiteAjudante2 = parseFloat($('pernoiteAjudante2').value) * parseFloat($('quantidadePernoiteAjudante2').value);
            $('totalPernoiteAjudante2').value = formatoMoeda(totalPernoiteAjudante2);
            
            var totalAlimentacaoMotorista = parseFloat($('alimentacaoMotorista').value) * parseFloat($('quantidadeAlimentacaoMotorista').value);
            $('totalAlimentacaoMotorista').value = formatoMoeda(totalAlimentacaoMotorista);
            
            var totalAlimentacaoAjudante = parseFloat($('alimentacaoAjudante').value) * parseFloat($('quantidadeAlimentacaoAjudante').value);
            $('totalAlimentacaoAjudante').value = formatoMoeda(totalAlimentacaoAjudante);
            
            var totalAlimentacaoAjudante2 = parseFloat($('alimentacaoAjudante2').value) * parseFloat($('quantidadeAlimentacaoAjudante2').value);
            $('totalAlimentacaoAjudante2').value = formatoMoeda(totalAlimentacaoAjudante2);
        
    }
    
    function addDiarias(index){
        //----------------inicio diaria, pernoite e alimentação motorista----------------------
        var idDiariaMotorista = '<%=cfg.getPlanoCustoDiariaMotorista().getIdconta()%>';
        var contaDiariaMotorista = '<%=cfg.getPlanoCustoDiariaMotorista().getConta()%>';
        var descricaoDiariaMotorista = '<%=cfg.getPlanoCustoDiariaMotorista().getDescricao()%>';
        var totalDiariaMotorista = $('totalDiariaMotorista').value;

        if (totalDiariaMotorista != 0) {
            addApropriacao(index,idDiariaMotorista,contaDiariaMotorista,descricaoDiariaMotorista,$('veiculo_id').value,$('veiculo').value,totalDiariaMotorista,true,'','','Diaria Motorista',false,"","");
        }
        var idPernoiteMotorista = '<%=cfg.getPlanoCustoPernoiteMotorista().getIdconta()%>';
        var contaPernoiteMotorista = '<%=cfg.getPlanoCustoPernoiteMotorista().getConta()%>';
        var descricaoPernoiteMotorista = '<%=cfg.getPlanoCustoPernoiteMotorista().getDescricao()%>';
        var totalPernoiteMotorista = $('totalPernoiteMotorista').value;
        if (totalPernoiteMotorista != 0) {            
            addApropriacao(index,idPernoiteMotorista,contaPernoiteMotorista,descricaoPernoiteMotorista,$('veiculo_id').value,$('veiculo').value,totalPernoiteMotorista,true,'','','Pernoite Motorista',false,"","");
        }
        var idAlimentacaoMotorista = '<%=cfg.getPlanoCustoAlimentacaoMotorista().getIdconta()%>';
        var contaAlimentacaoMotorista = '<%=cfg.getPlanoCustoAlimentacaoMotorista().getConta()%>';
        var descricaoAlimentacaoMotorista = '<%=cfg.getPlanoCustoAlimentacaoMotorista().getDescricao()%>';
        var totalAlimentacaoMotorista = $('totalAlimentacaoMotorista').value;
        if (totalAlimentacaoMotorista != 0) {
            addApropriacao(index,idAlimentacaoMotorista,contaAlimentacaoMotorista,descricaoAlimentacaoMotorista,$('veiculo_id').value,$('veiculo').value,totalAlimentacaoMotorista,true,'','','Alimentação Motorista',false,"","");
        }
        //-------------------------------fim diaria, pernoite e alimentação motorista-----------------------
        
        //------------------inicio diaria, pernoite e aliementação ajudante 1 --------------------------------
        var idDiariaAjudante = '<%=cfg.getPlanoCustoDiariaAjudante().getIdconta()%>';
        var contaDiariaAjudante = '<%=cfg.getPlanoCustoDiariaAjudante().getConta()%>';
        var descricaoDiariaAjudante = '<%=cfg.getPlanoCustoDiariaAjudante().getDescricao()%>';
        var totalDiariaAjudante = $('totalDiariaAjudante').value;
        if (totalDiariaAjudante != 0) {
            addApropriacao(index,idDiariaAjudante,contaDiariaAjudante,descricaoDiariaAjudante,$('veiculo_id').value,$('veiculo').value,totalDiariaAjudante,true,'','','Diaria Ajudante 1',false,"","");
        }
        var idPernoiteAjudante = '<%=cfg.getPlanoCustoPernoiteAjudante().getIdconta()%>';
        var contaPernoiteAjudante = '<%=cfg.getPlanoCustoPernoiteAjudante().getConta()%>';
        var descricaoPernoiteAjudante = '<%=cfg.getPlanoCustoPernoiteAjudante().getDescricao()%>';
        var totalPernoiteAjudante = $('totalPernoiteAjudante').value;
        if (totalPernoiteAjudante != 0) {            
            addApropriacao(index,idPernoiteAjudante,contaPernoiteAjudante,descricaoPernoiteAjudante,$('veiculo_id').value,$('veiculo').value,totalPernoiteAjudante,true,'','','Pernoite Ajudante 1',false,"","");
        }
        var idAlimentacaoAjudante = '<%=cfg.getPlanoCustoAlimentacaoAjudante().getIdconta()%>';
        var contaAlimentacaoAjudante = '<%=cfg.getPlanoCustoAlimentacaoAjudante().getConta()%>';
        var descricaoAlimentacaoAjudante = '<%=cfg.getPlanoCustoAlimentacaoAjudante().getDescricao()%>';
        var totalAlimentacaoAjudante = $('totalAlimentacaoAjudante').value;
        if (totalAlimentacaoAjudante != 0) {
            addApropriacao(index,idAlimentacaoAjudante,contaAlimentacaoAjudante,descricaoAlimentacaoAjudante,$('veiculo_id').value,$('veiculo').value,totalAlimentacaoAjudante,true,'','','Alimentação Ajudante 1',false,"","");
        }
        //--------------------------fim diaria, pernoite, alimentacao ajudante 1----------------------------------
        
        //------------------inicio diaria, pernoite e aliementação ajudante 2 --------------------------------        
        var totalDiariaAjudante2 = $('totalDiariaAjudante2').value;
        if (totalDiariaAjudante2 != 0) {
            addApropriacao(index,idDiariaAjudante,contaDiariaAjudante,descricaoDiariaAjudante,$('veiculo_id').value,$('veiculo').value,totalDiariaAjudante2,true,'','','Diaria Ajudante 2',false,"","");
        }
        var totalPernoiteAjudante2 = $('totalPernoiteAjudante2').value;
        if (totalPernoiteAjudante2 != 0) {
            addApropriacao(index,idPernoiteAjudante,contaPernoiteAjudante,descricaoPernoiteAjudante,$('veiculo_id').value,$('veiculo').value,totalPernoiteAjudante2,true,'','','Pernoite Ajudante 2',false,"","");
        }
        var totalAlimentacaoAjudante2 = $('totalAlimentacaoAjudante2').value;
        if (totalAlimentacaoAjudante2 != 0) {
            addApropriacao(index,idAlimentacaoAjudante,contaAlimentacaoAjudante,descricaoAlimentacaoAjudante,$('veiculo_id').value,$('veiculo').value,totalAlimentacaoAjudante2,true,'','','Alimentação Ajudante 2',false,"","");
        }
        
        
        var qtdAbastecimento = $("maxAbast").value;


            //Adicionando Abastecimentos
            var totalAbast = 0;
            var idPlano = "0";
            var contaPlano = "";
            var descricaoPlano = "";
            var idFornecedor = "";
            var fornecedor = "";
            
            for(i = 1; i <= qtdAbastecimento; i++){
                
               idFornecedor = $("idFornecedorAbast_" + i).value;
               fornecedor = $("fornecedorAbast_" + i).value;
               
                if ($('listaCategoriaAbast_'+i).value == 'vi'){
                    var valueI = $('combustivelAbast_'+i).value;
                    if ($('contaCombustivelAbast_'+i+"_"+valueI) != null){
                        if ($('combustivelAbast_'+i+"_"+valueI).value != 0){
                            totalAbast += parseFloat(colocarPonto($('totalAbast_' + i).value));
                            if (idPlano == "0"){
                                idPlano = $('combustivelAbast_'+i+'_'+valueI).value;
                                contaPlano = $('contaCombustivelAbast_'+i+'_'+valueI).value;
                                descricaoPlano = $('descricaoCombustivelAbast_'+i+'_'+valueI).value;
                            }
                        }
                    }
                }
            }
        
            if (parseFloat(totalAbast) != 0){
                
                    addApropriacao(index,idPlano,contaPlano,descricaoPlano,
                        $('idveiculo').value,$('veiculo').value,totalAbast,true,'','','Abastecimento',false,idFornecedor,fornecedor);
            }

        
        
        
        //--------------------------fim diaria, pernoite, alimentacao ajudante 2----------------------------------
        var qtdAprop = $("qtdAprop").value;
        var qtdDespesa = index;
        totalNota(qtdDespesa);
    }
    
    function camposReadOnly(tipoVeiculo){
             //carreta
             if($("car_tipo_controle_km").value == "a"){
                 $("trCarretaKm").style.display = "";
             }else{
                 $("trCarretaKm").style.display = "none";
             }
             
             //bitrem
             if($("bi_tipo_controle_km").value == "a"){
                 $("trBitremKm").style.display = "";
             }else{
                 $("trBitremKm").style.display = "none";
             }
         }
         
         
        function CamposApenasEmBaixar(){
            if(<%=(acao.equals("iniciarbaixa") || acao.equals("baixado"))%>){
                $("lbKmChegada").style.display = "";
                $("kmChegada").style.display = "";
                $("Carreta_kmChegada").style.display = "";
                $("Bitrem_kmChegada").style.display = "";
            }else{
                $("lbKmChegada").style.display = "none";
                $("kmChegada").style.display = "none";
                $("Carreta_kmChegada").style.display = "none";
                $("Bitrem_kmChegada").style.display = "none";
            }
        }
        
        function valorTotalAbastecimento(){
            
            var totalAbastecimento = 0.00;
            for(var i=1; i <= $("maxAbast").value; i++){               
                if($("totalAbast_" + i)!=null){
                    totalAbastecimento += parseFloat(colocarPonto($("totalAbast_" + i).value)); 
                }
            }
            $("idTotalAbastecimento").value = colocarVirgula(totalAbastecimento, 3);
        }
        
        function validaPermissaoFilial(){
           let permissaoOutrasFiliais = <%= autenticado.getAcesso("landespfl") > 2 %>;
           let qtd_despesas = jQuery("[id^=idTipoDesp]").length;
            if(!permissaoOutrasFiliais && qtd_despesas > 0){
                alert("Atenção! Seu usuário não tem permissao para mudar a filial, quando existem Despesas lançadas. Favor remover as Despesas!");
            }else{
                launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FILIAL%>','Filial');
            }
        }
        
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
            var rotina = "trips";
            var dataDe = $("dataDeAuditoria").value;
            var dataAte = $("dataAteAuditoria").value;
            var id = <%=( carregaViag ? cadviag.getViagem().getId() : 0)%>;
            consultarLog(rotina, id, dataDe, dataAte);
            }

            function setDataAuditoria(){
               $("dataDeAuditoria").value = '<%= Apoio.getDataAtual() %>'; 
               $("dataAteAuditoria").value = '<%= Apoio.getDataAtual() %>'; 

            }
    function validarBloqueioVeiculo(tipo){
       var bloqueado = false;
            if($("is_bloqueado").value == "t" && tipo == "veiculo"){
                        setTimeout(function(){
                        alert("O veículo " + $("vei_placa").value + " está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
                        $("idveiculo").value = "0";
                        $("vei_placa").value = "";
                        $("veiculo_id").value = "0";
                        $("veiculo").value = "";
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
            if($("is_bloqueado").value == "t" && tipo == "bitrem"){
                        setTimeout(function(){
                        alert("O Bi-trem " + $("bi_placa").value + " está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
                        $("idbitrem").value = "0";
                        $("bi_placa").value = "";
                        bloqueado = true;
                        },100);
            }
            return bloqueado;
    }
    function validarBloqueioVeiculoMotorista(filtrosM){
        var bloqueado = false;
        var filtros = filtrosM;
        for(var i = 0; i<= filtros.split(",").length ; i++){
        if($("is_moto_veiculo_bloq").value == "t" && filtros.split(",")[i] == "veiculo_motorista"){
            setTimeout(function (){
                   alert("O veiculo " + $("vei_placa").value + ", vinculado ao motorista " +$("motor_nome").value+ ", está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("moto_veiculo_bloq_motivo").value);
                    $("idveiculo").value = "0";
                    $("vei_placa").value = "";
                    $('veiculo_id').value = "0";
                    $('veiculo').value = "";
                    bloqueado = true;
            },100);
        }else if($("is_moto_carreta_bloq").value == "t" && filtros.split(",")[i] == "carreta_motorista"){
                setTimeout(function (){
                    alert("A carreta " + $("car_placa").value + ", vinculada ao motorista " +$("motor_nome").value+ ", está bloqueada e não poderá ser utilizada no lançamento. \r\n Motivo: " + $("moto_carreta_bloq_motivo").value);
                    $("idcarreta").value = "0";
                    $("car_placa").value = "";
                    bloqueado = true;
                 
                },100);
        }else if($("is_moto_bitrem_bloq").value == "t" && filtros.split(",")[i] == "bitrem_motorista"){
                setTimeout(function (){
                    alert("O bi-trem " + $("bi_placa").value + ", vinculada ao motorista " +$("motor_nome").value+ ", está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("moto_bitrem_bloq_motivo").value);
                    $("idbitrem").value = "0";
                    $("bi_placa").value = "";
                    bloqueado = true;
                 
                },100);
            }
        }
        return bloqueado;
    }
</script>

<%@page import="conhecimento.BeanConhecimento"%>
<%@page import="mov_banco.conta.BeanConsultaConta"%>
<%@page import="mov_banco.BeanMovBanco"%>
<%@page import="despesa.especie.Especie"%>
<%@page import="despesa.BeanDespesa"%>
<%@page import="despesa.duplicata.BeanDuplDespesa"%>
<%@page import="despesa.apropriacao.BeanApropDespesa"%>
<%@ page import="br.com.gwsistemas.viagem.BeneficiarioViagem" %>
<%@ page import="br.com.gwsistemas.gwmobile.MobileControlador" %>
<%@ page import="br.com.gwsistemas.gwmobile.MobileBO" %>
<%@ page import="despesa.BeanCadDespesa" %>
<%@ page import="javax.xml.transform.Result" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">

        <title>Webtrans - Lan&ccedil;amento de Viagem</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <link rel="stylesheet" href="stylesheets/tabs.css" type="text/css" media="all">
        <style type="text/css">
            <!--
                .cellNotes {
                font-size: 10px;
                background-color:#E6E6E6;
                }
                .styleValor{
                    text-align: right;
                }
            -->
        </style>
    </head>
   <body onLoad="javascript:aoCarregar();applyFormatter();pediMotivo();camposReadOnly();CamposApenasEmBaixar();setDataAuditoria()">
     <div align="center">
        <img src="img/banner.gif" >
        <br>
        <table width="95%" align="center" class="bordaFina" >
            <tr>
                <td width="613" align="left">
                    <b><%=(acao.equals("iniciarbaixa") ? "Fechamento de Viagem " : "Abertura de Viagem ")%></b>
                </td>
                
                    <%  //se o paramentro vier com valor entao nao pode excluir
                    if ((acao.equals("editar")) && (nivelUser >= 4) && (request.getParameter("ex") == null)) {%>
                        <td width="15">
                            <input name="excluir" type="button" class="botoes" value="Excluir"
                                   onClick="javascript:tryRequestToServer(function(){excluir('<%=(carregaViag ? viag.getId() : 0)%>');});">
                        </td>
                    <%}%>
                <td width="56">
                    <input  name="bt_consultar" type="button" id="bt_consultar" class="botoes" value="Voltar para Consulta" onClick="voltar()">
                </td>
            </tr>
        </table>
        <br>
        <form method="post" id="formAd" target="pop">
            <input type="hidden" id="viagemId" name="viagemId" value="${carregaViag ? viagem.id : 0}">
            <input type="hidden" id="idmotorista" value="<%=(carregaViag && viag.getBeneficiario() == BeneficiarioViagem.MOTORISTA ? String.valueOf(viag.getMotorista().getIdmotorista()) : "0")%>">
            <input type="hidden" id="idfilial" value="<%=(carregaViag ? String.valueOf(viag.getFilial().getIdfilial()) : (nivelUser > 0 ? String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()) : ""))%>">
            <input type="hidden" id="idContaAdiant" value="<%=cfg.getConta_adiantamento_viagem_id().getIdConta()%>">
            <input type="hidden" id="idfornecedor" value="0">
            <input type="hidden" id="fornecedor" value="">
            <input type="hidden" id="idhist" value="0">
            <input type="hidden" id="descricao_historico" value="">
            <input type="hidden" id="contaplcusto" value="">
            <input type="hidden" id="idplcustopadrao" value="0">
            <input type="hidden" id="descricaoplcusto" value="">
            <input type="hidden" id="idveiculo" value="0">
            <input type="hidden" id="vei_placa" value="">
            <input type="hidden" id="idplanocusto_despesa">
            <input type="hidden" id="plcusto_conta_despesa">
            <input type="hidden" id="plcusto_descricao_despesa">
            <input type="hidden" id="veiculo_id" value="<%=(carregaViag ? String.valueOf(viag.getVeiculo().getIdveiculo()) : "0")%>">
            <input type="hidden" id="idcarreta" value="<%=(carregaViag ? String.valueOf(viag.getCarreta().getIdveiculo()) : "0")%>">
            <input type="hidden" id="idbitrem" value="<%=(carregaViag ? String.valueOf(viag.getBiTrem().getIdveiculo()) : "0")%>">
            <input type="hidden" id="id_und">
            <input type="hidden" id="sigla_und">
            <input type="hidden" id="id_und_forn">
            <input type="hidden" id="sigla_und_forn">
            <input type="hidden" id="impedir_viagem_motorista" name="impedir_viagem_motorista" value="f">
            <input type="hidden" id="maxRota" name="maxRota" value="0">
            <input type="hidden" id="maxAbast" name="maxAbast" value="0">
            <input type="hidden" id="linhaRota" name="linhaRota" value="0">
            <input type="hidden" id="linhaAdiantamento" name="linhaAdiantamento" value="0">
            <input type="hidden" id="idremetente" name="idremetente">
            <input type="hidden" id="idcidadeorigem" name="idcidadeorigem" value="<%=(carregaViag ? viag.getFilial().getCidade().getIdcidade() : (nivelUser > 0 ? Apoio.getUsuario(request).getFilial().getCidade().getIdcidade() : "0"))%>">
            <input type="hidden" id="rem_rzs" name="rem_rzs">
            <input type="hidden" id="iddestinatario" name="iddestinatario">
            <input type="hidden" id="dest_rzs" name="dest_rzs">
            <input type="hidden" id="rota_id" name="rota_id">
            <input type="hidden" id="rota_desc" name="rota_desc">
            <input type="hidden" id="cidade_origem" name="cidade_origem">
            <input type="hidden" id="uf_origem_rota" name="uf_origem_rota">
            <input type="hidden" id="cidade_destino" name="cidade_destino">
            <input type="hidden" id="uf_destino_rota" name="uf_destino_rota">
            <input type="hidden" id="cidade_destino_id" name="cidade_destino_id">
            <input type="hidden" id="cidade_origem_id" name="cidade_origem_id">
            <input type="hidden" id="idcidadeorigem" name="idcidadeorigem">
            <input type="hidden" id="cid_origem" name="cid_origem">
            <input type="hidden" id="uf_origem" name="uf_origem">
            <input type="hidden" id="idcidadedestino" name="idcidadedestino">
            <input type="hidden" id="cid_destino" name="cid_destino">
            <input type="hidden" id="uf_destino" name="uf_destino">
            <input type="hidden" id="equipadoCarr" name="equipadoCarr" value="" />
            <input type="hidden" id="equipadoBi" name="equipadoBi" value="" />
            <input type="hidden" id="linha" name="linha" value="">
            <input type="hidden" id="maxAdiantamento" name="maxAdiantamento" value="0">
            <input type="hidden" id="maxDesconto" name="maxDesconto" value="0">
            <input type="hidden" id="percentual_comissao_frete" name="percentual_comissao_frete" value="<%=(carregaViag && viag.getBeneficiario() == BeneficiarioViagem.MOTORISTA ? String.valueOf(viag.getMotorista().getPercentualComissaoFrete()) : "0")%>">
            <input type="hidden" id="idproprietarioveiculo" name="idproprietarioveiculo" value="0">
            <input type="hidden" id="idajudante" name="idajudante" value="0">
            <input type="hidden" id="nome" name="nome" value="0">
            <input type="hidden" id="vl_diaria_motorista" name="vl_diaria_motorista" value="0,00">
            <input type="hidden" id="vl_pernoite_motorista" name="vl_pernoite_motorista" value="0,00">
            <input type="hidden" id="vl_alimentacao_motorista" name="vl_alimentacao_motorista" value="0,00">
            <input type="hidden" id="qtdAprop" name="qtdAprop" value="0">
            
            <input type="hidden" id="car_tipo_controle_km" name="car_tipo_controle_km" value="<%= (carregaViag ? viag.getCarreta().getTipoControleKm() : "") %>">
            <input type="hidden" id="bi_tipo_controle_km"  name="bi_tipo_controle_km" value="<%= (carregaViag ? viag.getBiTrem().getTipoControleKm() : "") %>">
            <input type="hidden" id="car_km_atual"  name="car_km_atual" value="">
            <input type="hidden" id="bi_km_atual"  name="bi_km_atual" value="">
            <input type="hidden" name="os_aberto_veiculo" id="os_aberto_veiculo" value="<%=(carregaViag && viag.getVeiculo().isOsAbertoVeiculo() ? "t" : "f")%>">
            <input type="hidden" name="miliSegundos"  id="miliSegundos" value="0">
            <input type="hidden" name="cfgPermitirLancamentoOSAbertoVeiculo"  id="cfgPermitirLancamentoOSAbertoVeiculo" value="<%=cfg.getPermitirLancamantoOSAbertoVeiculo()%>">
            <input type="hidden" name="motivo_bloqueio" id="motivo_bloqueio">    
            <input type="hidden" name="is_bloqueado" id="is_bloqueado">    
            <input type="hidden" name="moto_veiculo_bloq_motivo" id="moto_veiculo_bloq_motivo">    
            <input type="hidden" name="is_moto_veiculo_bloq" id="is_moto_veiculo_bloq">    
            <input type="hidden" name="moto_carreta_bloq_motivo" id="moto_carreta_bloq_motivo">    
            <input type="hidden" name="is_moto_carreta_bloq" id="is_moto_carreta_bloq"> 
            <input type="hidden" name="moto_bitrem_bloq_motivo" id="moto_bitrem_bloq_motivo">    
            <input type="hidden" name="is_moto_bitrem_bloq" id="is_moto_bitrem_bloq">             
            
            <table width="95%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr>
                    <td colspan="9">
                        <table width="100%">
                            <tr>
                                <td class="tabela" colspan="9" align="center">Dados Viagem</td>
                            </tr>
                        </table>                
                    </td>
                </tr>
                <tr>
                    <td colspan="9">
                        <table width="100%">
                            <tr>
                                <td class="TextoCampos">Filial:</td>
                                <td class="CelulaZebra2" width="13%">
                                    <input name="fi_abreviatura" type="text" class="inputReadOnly" id="fi_abreviatura" size="13" maxlength="12" readonly="true" value="<%=(carregaViag ? viag.getFilial().getAbreviatura() : (nivelUser > 0 ? Apoio.getUsuario(request).getFilial().getAbreviatura() : ""))%>">
                                    <input name="button2" type="button" class="botoes" onClick="validaPermissaoFilial()" value="...">
                                </td>
                                <td class="TextoCampos">Beneficiário:</td>
                                <td class="CelulaZebra2" width="12%">
                                    <select id="selectBeneficiario" name="selectBeneficiario" class="inputtexto">
                                        <option value="m" ${!carregaViag ? "selected" : viag.beneficiario.tipo eq "m" ? "selected" : ""}>Motorista</option>
                                        <option value="a" ${carregaViag && viagem.beneficiario.tipo eq "a" ? "selected" : ""}>Ajudante</option>
                                        <option value="f" ${carregaViag && viagem.beneficiario.tipo eq "f" ? "selected" : ""}>Funcionário</option>
                                    </select>
                                </td>
                                <td class="TextoCampos" width="6%">N&uacute;mero:</td>
                                <td class="CelulaZebra2" width="6%">
                                    <input name="numviagem" type="text" id="numviagem" size="6" maxlength="6" onChange="seNaoIntReset(this,'')" value="<%=carregaViag ? viag.getNumViagem() : cadviag.getProximaViagem()%>" <%=(nivelAlteraNumero == 4 ? "" : "readonly='true'")%> class="<%=(nivelAlteraNumero == 4 ? "inputtexto" : "inputReadOnly")%>">
                                </td>
                                <td class="TextoCampos" width="8%">Data Sa&iacute;da:</td>
                                <td class="CelulaZebra2" width="14%">
                                    <input name="saidaem" type="text" id="saidaem" size="10" maxlength="10" onBlur="alertInvalidDate(this)" class="fieldDate"
                                    value="<%=(carregaViag ? fmt.format((viag.getSaidaEm() != null ? viag.getSaidaEm() : new Date())) : Apoio.getDataAtual())%>">
                                    <input name="saidaas" type="text" id="saidaas" size="5" onkeyup="mascaraHora(this)" maxlength="5"  value="<%=(carregaViag && viag.getSaidaAs() != null ? new SimpleDateFormat("HH:mm").format(viag.getSaidaAs()) : new SimpleDateFormat("HH:mm").format(new Date()))%>" class="inputtexto">
                                </td>                    
                                <td class="TextoCampos" width="12%">Previsao Retorno:</td>
                                <td class="CelulaZebra2">
                                    <input name="previsaoRetornoEm" type="text" id="previsaoRetornoEm" size="10" maxlength="10" onBlur="alertInvalidDate(this,'false')" class="fieldDate"
                                    value="<%=(carregaViag ? viag.getPrevisaoRetornoEm() != null ? fmt.format(viag.getPrevisaoRetornoEm()) : "" : "")%>">
                                    <input name="previsaoRetornoAs" type="text" id="previsaoRetornoAs" size="5" onkeyup="mascaraHora(this)" maxlength="5"  
                                    value="<%=(carregaViag && viag.getPrevisaoRetornoAs() != null ? new SimpleDateFormat("HH:mm").format(viag.getPrevisaoRetornoAs()) : "")%>" class="inputtexto">
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr id="trMotorista">
                    <td colspan="9">
                        <table width="100%">
                            <tr>
                                <td class="TextoCampos" width="7%"><div align="right">Motorista:</div></td>
                                <td class="CelulaZebra2" width="20%">
                                    <input name="motor_nome" type="text" class="inputReadOnly" id="motor_nome" size="23" value="<%=(carregaViag && viag.getBeneficiario() == BeneficiarioViagem.MOTORISTA ? viag.getMotorista().getNome() : "")%>" readonly="true">
                                    <input name="btMoto" id="btMoto" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=10','Motorista')" value="...">
                                    <img src="img/borracha.gif" border="0" id="lixoMoto" align="absbottom" class="imagemLink" title="Limpar Motorista" onClick="javascript:getObj('idmotorista').value = 0;javascript:getObj('motor_nome').value = '';"> 
                                    <img src="img/page_edit.png" border="0" onClick="javascript:verMotorista();" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                </td>
                                <td class="TextoCampos">Diária:</td>
                                <td class="CelulaZebra2">
                                    <input id="diariaMotorista" name="diariaMotorista" type="text" value="<%=(carregaViag ? viag.getValorDiariaMotorista() : "0.00")%>" class="inputtexto"  size="4" onblur="calcularTotalPlano();" onchange="seNaoFloatReset(this, '0.00');">
                                </td>
                                <td class="TextoCampos">Qtd:</td>
                                <td class="CelulaZebra2">
                                    <input id="quantidadeDiariaMotorista" name="quantidadeDiariaMotorista" type="text" value="<%=(carregaViag ? viag.getQuantidadeDiariaMotorista() : "0")%>" class="inputtexto" size="2" onblur="calcularTotalPlano();" onchange="seNaoIntReset(this, '0');">
                                </td>
                                <td class="TextoCampos">Total:</td>
                                <td class="CelulaZebra2">
                                    <input id="totalDiariaMotorista" name="totalDiariaMotorista" type="text" value="0.00" class="inputtexto" size="4" onchange="seNaoFloatReset(this, '0.00');" onblur="calcularTotalPlano();" readonly>
                                </td>
                                <td class="TextoCampos">Pernoite:</td>
                                <td class="CelulaZebra2">
                                    <input id="pernoiteMotorista" name="pernoiteMotorista" type="text" value="<%=(carregaViag ? viag.getValorPernoiteMotorista() : cfg.getValorPernoiteViagem())%>" class="inputtexto" size="4" onblur="calcularTotalPlano();" onchange="seNaoFloatReset(this, '0.00');" >
                                </td>
                                <td class="TextoCampos">Qtd:</td>
                                <td class="CelulaZebra2">
                                    <input id="quantidadePernoiteMotorista" name="quantidadePernoiteMotorista" type="text" value="<%=(carregaViag ? viag.getQuantidadePernoiteMotorista() : "0")%>" class="inputtexto" size="2" onblur="calcularTotalPlano();" onchange="seNaoIntReset(this, '0');">
                                </td>
                                <td class="TextoCampos">Total:</td>
                                <td class="CelulaZebra2">
                                    <input id="totalPernoiteMotorista" name="totalPernoiteMotorista" type="text" value="0.00" class="inputtexto" size="4" onchange="seNaoFloatReset(this, '0.00');" onblur="calcularTotalPlano();" readonly>
                                </td>
                                <td class="TextoCampos">Alim.</td>
                                <td class="CelulaZebra2">
                                    <input id="alimentacaoMotorista" name="alimentacaoMotorista" type="text" value="<%=(carregaViag ? viag.getValorAlimentacaoMotorista() : cfg.getValorAlimentacaoViagem())%>" class="inputtexto" size="4" onblur="calcularTotalPlano();" onchange="seNaoFloatReset(this, '0.00');">
                                </td>
                                <td class="TextoCampos">Qtd:</td>
                                <td class="CelulaZebra2">
                                    <input id="quantidadeAlimentacaoMotorista" name="quantidadeAlimentacaoMotorista" type="text" value="<%=(carregaViag ? viag.getQuantidadeAlimentacaoMotorista() : "0")%>" class="inputtexto" size="2" onblur="calcularTotalPlano();" onchange="seNaoIntReset(this, '0');">
                                </td>
                                <td class="TextoCampos">Total:</td>
                                <td class="CelulaZebra2">
                                    <input id="totalAlimentacaoMotorista" name="totalAlimentacaoMotorista" type="text" value="0.00" class="inputtexto" size="4" onchange="seNaoFloatReset(this, '0.00');" onblur="calcularTotalPlano();" readonly>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr id="trAjudante1">
                    <td colspan="9">
                        <table width="100%">
                            <tr>
                                <td class="TextoCampos" width="7%"><div align="right">Ajudante 1:</div></td>
                                <td class="CelulaZebra2" width="20%">
                                    <input type="hidden" id="idAjudante1" name="idAjudante1" value="<%=(carregaViag ? String.valueOf(viag.getAjudante1().getIdfornecedor()) : "0")%>">
                                    <input name="nomeAjudante1" id="nomeAjudante1" type="text" class="inputReadOnly" size="23" readonly value="<%=(carregaViag && viag.getAjudante1().getRazaosocial() != null ? viag.getAjudante1().getRazaosocial() : "")%>"/>
                                    <input type="button" class="botoes" name="localiza_ajudante" id="localiza_ajudante" onclick="localizarAjudante1(this)" value="..."/>
                                    <img src="img/borracha.gif" alt="" class="imagemLink" id="borrachaAj" onclick="$('nomeAjudante1').value='';$('idAjudante1').value='0'"/>
                                    <img src="img/page_edit.png" alt="" name="lupa1" class="imagemLink" id="lupa1" style="vertical-align: bottom" title="ver cadastro" onclick="javascript:verAjudante(1)"/>     
                                </td>
                                <td class="TextoCampos">Diária:</td>
                                <td class="CelulaZebra2">
                                    <input id="diariaAjudante" name="diariaAjudante" type="text" value="<%=(carregaViag ? viag.getValorDiariaAjudante() : "0.00")%>" class="inputtexto" size="4" onblur="javascript:calcularTotalPlano();" onchange="seNaoFloatReset(this, '0.00');">
                                </td>
                                <td class="TextoCampos">Qtd:</td>
                                <td class="CelulaZebra2">
                                    <input id="quantidadeDiariaAjudante" name="quantidadeDiariaAjudante" type="text" value="<%=(carregaViag ? viag.getQuantidadeDiariaAjudante() : "0")%>" class="inputtexto" size="2" onblur="javascript:calcularTotalPlano();" onchange="seNaoIntReset(this, '0');">
                                </td>
                                <td class="TextoCampos">Total:</td>
                                <td class="CelulaZebra2">
                                    <input id="totalDiariaAjudante" name="totalDiariaAjudante" type="text" value="0.00" class="inputtexto" size="4" onchange="seNaoFloatReset(this, '0.00');" readonly>
                                </td>
                                <td class="TextoCampos">Pernoite:</td>
                                <td class="CelulaZebra2">
                                    <input id="pernoiteAjudante" name="pernoiteAjudante" type="text" value="<%=(carregaViag ? viag.getValorPernoiteAjudante() : cfg.getValorPernoiteViagem())%>" class="inputtexto" size="4" onblur="javascript:calcularTotalPlano();" onchange="seNaoFloatReset(this, '0.00');">
                                </td>
                                <td class="TextoCampos">Qtd:</td>
                                <td class="CelulaZebra2">
                                    <input id="quantidadePernoiteAjudante" name="quantidadePernoiteAjudante" type="text" value="<%=(carregaViag ? viag.getQuantidadePernoiteAjudante() : "0")%>" class="inputtexto" size="2" onblur="javascript:calcularTotalPlano();" onchange="seNaoIntReset(this, '0');">
                                </td>
                                <td class="TextoCampos">Total:</td>
                                <td class="CelulaZebra2">
                                    <input id="totalPernoiteAjudante" name="totalPernoiteAjudante" type="text" value="0.00" class="inputtexto" size="4" onchange="seNaoFloatReset(this, '0.00');" readonly>
                                </td>
                                <td class="TextoCampos">Alim.</td>
                                <td class="CelulaZebra2">
                                    <input id="alimentacaoAjudante" name="alimentacaoAjudante" type="text" value="<%=(carregaViag ? viag.getValorAlimentacaoAjudante() : cfg.getValorAlimentacaoViagem())%>" class="inputtexto" size="4" onblur="javascript:calcularTotalPlano();" onchange="seNaoFloatReset(this, '0.00');">
                                </td>
                                <td class="TextoCampos">Qtd:</td>
                                <td class="CelulaZebra2">
                                    <input id="quantidadeAlimentacaoAjudante" name="quantidadeAlimentacaoAjudante" type="text" value="<%=(carregaViag ? viag.getQuantidadeAlimentacaoAjudante() : "0")%>" class="inputtexto" size="2" onblur="javascript:calcularTotalPlano();" onchange="seNaoIntReset(this, '0');">
                                </td>
                                <td class="TextoCampos">Total:</td>
                                <td class="CelulaZebra2">
                                    <input id="totalAlimentacaoAjudante" name="totalAlimentacaoAjudante" type="text" value="0.00" class="inputtexto" size="4" onchange="seNaoFloatReset(this, '0.00');" readonly>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr id="trAjudante2">
                    <td colspan="9">
                        <table width="100%">
                            <tr>
                                <td class="TextoCampos" width="7%"><div align="right">Ajudante 2:</div></td>
                                <td class="CelulaZebra2" width="20%">
                                    <input type="hidden" id="idAjudante2" name="idAjudante2" value="<%=(carregaViag ? String.valueOf(viag.getAjudante2().getIdfornecedor()) : "0")%>">
                                    <input name="nomeAjudante2" id="nomeAjudante2" type="text" class="inputReadOnly" size="23" readonly value="<%=(carregaViag && viag.getAjudante2().getRazaosocial() != null ? viag.getAjudante2().getRazaosocial() : "")%>"/>
                                    <input type="button" class="botoes" name="localiza_ajudante" id="localiza_ajudante" onclick="localizarAjudante2(this)" value="..."/>
                                    <img src="img/borracha.gif" alt="" class="imagemLink" id="borrachaAj" onclick="$('nomeAjudante2').value='';$('idAjudante2').value='0'"/>
                                    <img src="img/page_edit.png" alt="" name="lupa1" class="imagemLink" id="lupa1" style="vertical-align: bottom" title="ver cadastro" onclick="javascript:verAjudante(2)"/>
                                </td>
                                <td class="TextoCampos">Diária:</td>
                                <td class="CelulaZebra2">
                                    <input id="diariaAjudante2" name="diariaAjudante2" type="text" value="<%=(carregaViag ? viag.getValorDiariaAjudante2() : "0.00")%>" class="inputtexto" size="4" onblur="javascript:calcularTotalPlano();" onchange="seNaoFloatReset(this, '0.00');">
                                </td>
                                <td class="TextoCampos">Qtd:</td>
                                <td class="CelulaZebra2">
                                    <input id="quantidadeDiariaAjudante2" name="quantidadeDiariaAjudante2" type="text" value="<%=(carregaViag ? viag.getQuantidadeDiariaAjudante2() : "0")%>" class="inputtexto" size="2" onblur="javascript:calcularTotalPlano();" onchange="seNaoIntReset(this, '0');">
                                </td>
                                <td class="TextoCampos">Total:</td>
                                <td class="CelulaZebra2">
                                    <input id="totalDiariaAjudante2" name="totalDiariaAjudante2" type="text" value="0.00" class="inputtexto" size="4" onchange="seNaoFloatReset(this, '0.00');" readonly>
                                </td>
                                <td class="TextoCampos">Pernoite:</td>
                                <td class="CelulaZebra2">
                                    <input id="pernoiteAjudante2" name="pernoiteAjudante2" type="text" value="<%=(carregaViag ? viag.getValorPernoiteAjudante2() : cfg.getValorPernoiteViagem())%>" class="inputtexto" size="4" onblur="javascript:calcularTotalPlano();" onchange="seNaoFloatReset(this, '0.00');">
                                </td>
                                <td class="TextoCampos">Qtd:</td>
                                <td class="CelulaZebra2">
                                    <input id="quantidadePernoiteAjudante2" name="quantidadePernoiteAjudante2" type="text" value=<%=(carregaViag ? viag.getQuantidadePernoiteAjudante2() : "0")%> class="inputtexto" size="2" onblur="javascript:calcularTotalPlano();" onchange="seNaoIntReset(this, '0');">
                                </td>
                                <td class="TextoCampos">Total:</td>
                                <td class="CelulaZebra2">
                                    <input id="totalPernoiteAjudante2" name="totalPernoiteAjudante2" type="text" value="0.00" class="inputtexto" size="4" onchange="seNaoFloatReset(this, '0.00');" readonly>
                                </td>
                                <td class="TextoCampos">Alim.</td>
                                <td class="CelulaZebra2">
                                    <input id="alimentacaoAjudante2" name="alimentacaoAjudante2" type="text" value="<%=(carregaViag ? viag.getValorAlimentacaoAjudante2() : cfg.getValorAlimentacaoViagem())%>" class="inputtexto" size="4" onblur="javascript:calcularTotalPlano();" onchange="seNaoFloatReset(this, '0.00');">
                                </td>
                                <td class="TextoCampos">Qtd:</td>
                                <td class="CelulaZebra2">
                                    <input id="quantidadeAlimentacaoAjudante2" name="quantidadeAlimentacaoAjudante2" type="text" value="<%=(carregaViag ? viag.getQuantidadeAlimentacaoAjudante2() : "0")%>" class="inputtexto" size="2" onblur="javascript:calcularTotalPlano();" onchange="seNaoIntReset(this, '0');">
                                </td>
                                <td class="TextoCampos">Total:</td>
                                <td class="CelulaZebra2">
                                    <input id="totalAlimentacaoAjudante2" name="totalAlimentacaoAjudante2" type="text" value="0.00" class="inputtexto" size="4" onchange="seNaoFloatReset(this, '0.00');" readonly>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr id="trFuncionario">
                    <td colspan="9">
                        <table width="100%">
                            <tr>
                                <td class="TextoCampos" width="7%"><div align="right">Funcionário:</div></td>
                                <td class="CelulaZebra2">
                                    <input type="hidden" id="idFuncionario" name="idFuncionario" value="${carregaViag ? viagem.funcionario.idfornecedor : "0"}">
                                    <input name="nomeFuncionario" id="nomeFuncionario" type="text" class="inputReadOnly" size="50" readonly value="${carregaViag and not empty viagem.funcionario.razaosocial ? viagem.funcionario.razaosocial : ""}">
                                    <input type="button" class="botoes" name="localizarFuncionario" id="localizarFuncionario" value="...">
                                    <img src="img/borracha.gif" alt="" class="imagemLink" id="limparFuncionario" onclick="$('idFuncionario').value = '0'; $('nomeFuncionario').value = '';">
                                    <img src="img/page_edit.png" alt="" name="verCadastroFuncionario" class="imagemLink" id="verCadastroFuncionario" style="vertical-align: bottom" title="Ver cadastro do funcionário">
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos">Ve&iacute;culo:</td>
                    <td class="CelulaZebra2">
                        <input name="veiculo" type="text" class="inputReadOnly" id="veiculo" value="<%=(carregaViag ? viag.getVeiculo().getPlaca() : "")%>" size="8" readonly="true">
                        <input name="localiza_veiculo" type="button" class="botoes" id="localiza_veiculo" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=7','Veiculo')" value="...">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Ve&iacute;culo" onClick="javascript:getObj('veiculo_id').value = 0;javascript:getObj('veiculo').value = '';"> 
                        <img src="img/page_edit.png" border="0" onClick="javascript:verVeiculo('V');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                    </td>
                    <td class="TextoCampos">Carreta:</td>
                    <td class="CelulaZebra2">
                        <input name="car_placa" type="text" class="inputReadOnly" id="car_placa" value="<%=(carregaViag && viag.getCarreta() != null ? viag.getCarreta().getPlaca() : "")%>" size="8" readonly="true">
                        <input name="localiza_veiculo2" type="button" class="botoes" id="localiza_veiculo2" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=9','Carreta')" value="...">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Carreta" onClick="javascript:getObj('idcarreta').value = 0;javascript:getObj('car_placa').value = '';"> 
                        <img src="img/page_edit.png" border="0" onClick="javascript:verVeiculo('C');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                    </td>
                    <td class="TextoCampos">Bi-trem:</td>
                    <td class="CelulaZebra2" >
                        <input name="bi_placa" type="text" class="inputReadOnly" id="bi_placa" value="<%=(carregaViag && viag.getCarreta() != null ? viag.getBiTrem().getPlaca() : "")%>" size="8" readonly="true">
                        <input name="localiza_bitrem" type="button" class="botoes" id="localiza_bitrem" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=51','Bitrem')" value="...">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Carreta" onClick="javascript:getObj('idbitrem').value = 0;javascript:getObj('bi_placa').value = '';"> 
                        <img src="img/page_edit.png" border="0" onClick="javascript:verVeiculo('B');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                    </td>                    
                </tr>                
                <tr <%=(carregaViag && !viag.isBaixada() && !acao.equals("iniciarbaixa") ? "" : "style='display: none'")%>>
                    <td class="TextoCampos" colspan="2">
                        <div align="center"> 
                            <input <%=(carregaViag && viag.isCancelada() && !acao.equals("iniciarbaixa") ? "checked" : "")%> type="checkbox" id="cancelado" name="cancelado" onclick="pediMotivo();"/>
                            <label>Cancelada</label>
                        </div>	
                    </td>                
                    <td class="TextoCampos">
                        <label id="lbMotivoCancelamento" name="lbMotivoCancelamento">Motivo:</label>
                    </td>
                    <td class="CelulaZebra2" colspan="5">
                        <textarea name="motivoCancelamento" cols="50" rows="2" id="motivoCancelamento" class="inputtexto" <%=(carregaViag && !viag.isBaixada() && viag.isCancelada() ? "" : "style='display: none'")%> onfocus="inicioCampo(this);"><%=(carregaViag && !viag.isBaixada() && !acao.equals("iniciarbaixa") ? viag.getMotivoCancelamento().trim() : "")%></textarea>
                    </td>
                </tr>
            </table>
            <br>
            <div id="container" style="width: 95%" align="center">
                <div align="center">
                    <ul id="tabs">
                        <li>
                            <a href="#tab1">
                                <strong>Adiantamentos/Presta&ccedil;&atilde;o</strong>
                            </a>
                        </li>
                        <li>
                            <a href="#tab2">
                                <strong>Percurso</strong>
                            </a>
                        </li>
                        <li>
                            <a href="#tab3">
                                <strong>Documentos(CT)</strong>
                            </a>
                        </li>
                        <li>
                            <a href="#tab4">
                                <strong>gwFrota</strong>
                            </a>
                        </li>
                        <li  style='display: <%= carregaViag && nivelUser == 4 ? "" : "none" %>'>
                            <a href="#tab5">
                                <strong>GW Mobile</strong>
                            </a>
                        </li>
                        <li  style='display: <%= carregaViag && nivelUser == 4 ? "" : "none" %>'>
                            <a href="#tab6">
                                <strong>Auditoria</strong>
                            </a>
                        </li>
                    </ul>
                </div>
                <div class="panel" id="tab1">
                    <fieldset>
                        <table width="100%" border="0" class="bordaFina">
                            <tr class="tabela" >
                                <td colspan="3" align="center">Movimentação Financeira do beneficiário</td>
                            </tr>
                            <tr>
                                <td width="56%" class="TextoCampos">Saldo de Viagens Anteriores:</td> 
                                <td width="19%" class="CelulaZebra2">
                                    <input name="saldoMotorista" type="text" class="inputReadOnly" id="saldoMotorista"  value="<%=carregaViag ? viag.getSaldoAnterior() : "0.00"%>" size="6" maxlength="12" readonly="">
                                    <%if (!acao.equals("iniciar") && !acao.equals("editar")) {%>
                                         <input  name="zera_saldo" type="button" class="botoes" id="zera_saldo" onClick="javascript:zeraSaldoAnterior();" value="Zerar" />
                                    <%}%>
                                </td> 
                                <td width="35%" class="CelulaZebra2" align="center">
                                    <input  name="add_adiant" type="button" class="botoes" id="add_adiant" value="Incluir adiantamento" style="display:<%=(acao.equals("baixado")?"none":"")%>" />
                                </td> 
                            </tr>
                            <tr>
                                <td colspan = "3">
                                    <table width="100%" id="tbAdiantMestre" name="tbAdiantMestre" border="0">
                                         <tbody id="tbAdiant" name="tbAdiant">
                                             <tr id="trTitulo" name="trTitulo" class="Celula">
                                                <td width="2%"></td>
                                                 <td width="2%"></td>
                                                 <td width="2%"></td>
                                                <td width="9%">Data</td>
                                                <td width="34%">Hist&oacute;rico</td>
                                                <td width="8%">D&eacute;bito</td>
                                                <td width="8%">Cr&eacute;dito</td>
                                                <td width="27%">Conta</td>
                                                <td width="4%">Chq</td>
                                                <td width="6%">Doc</td>
                                                <td width="2%"></td>
                                             </tr>
                                         </tbody>
                                    </table>                    
                                </td>
                            </tr>
                        </table>
                        <%if (!acao.equals("iniciar") && !acao.equals("editar")) {%>
                            <table width="100%" border="0" class="bordaFina">
                                <tr>
                                    <td colspan="6" class="tabela">
                                        <div align="center">Presta&ccedil;&atilde;o de Contas</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">
                                        Data Chegada: 
                                    </td>
                                    <td class="CelulaZebra2">
                                        <input name="chegadaem" type="text" id="chegadaem" size="10" maxlength="10" onBlur="alertInvalidDate(this);$('acertoem').value = this.value;" class="fieldDate"
                                               value="<%=(carregaViag ? fmt.format((viag.getChegadaEm() != null ? viag.getChegadaEm() : new Date())) : Apoio.getDataAtual())%>">
                                        &agrave;s
                                        <input name="chegadaas" type="text" id="chegadaas" onBlur="$('acertoas').value = this.value;" size="6" maxlength="5"  value="<%=(carregaViag && viag.getChegadaAs() != null ? new SimpleDateFormat("HH:mm").format(viag.getChegadaAs()) : new SimpleDateFormat("HH:mm").format(new Date()))%>" class="inputtexto" onkeyup="mascaraHora(this)">                                
                                    </td>
                                    <td class="TextoCampos">
                                        Data do Acerto: 
                                    </td>
                                    <td colspan="3" class="CelulaZebra2">
                                        <input name="acertoem" type="text" id="acertoem" size="10" maxlength="10" onBlur="alertInvalidDate(this)" class="fieldDate"
                                               value="<%=(carregaViag ? fmt.format((viag.getAcertoEm() != null ? viag.getAcertoEm() : new Date())) : Apoio.getDataAtual())%>">
                                        &agrave;s
                                        <input name="acertoas" type="text" id="acertoas" size="6" maxlength="5"  value="<%=(carregaViag && viag.getAcertoAs() != null ? new SimpleDateFormat("HH:mm").format(viag.getAcertoAs()) : new SimpleDateFormat("HH:mm").format(new Date()))%>" class="inputtexto" onkeyup="mascaraHora(this)">                                
                                    </td>
                                </tr>
                                <tr class="celula">
                                    <td width="16%" >Adiantamento</td>
                                    <td width="18%" >Despesas &agrave; Vista</td>
                                    <td width="14%" >Resultado</td>
                                    <td width="10%" >
                                        <label id="acerto">Acerto</label>
                                        <label id="reembolso" style="display:none">Reembolso</label>
                                    </td>
                                    <td width="42%" >Conta Acerto</td>
                                </tr>
                                <tr>
                                    <td class="CelulaZebra2">
                                         <input name="totalAdiantado" type="text" class="inputReadOnly" id="totalAdiantado"  value="0.00" size="5" maxlength="12" readonly="">
                                    </td>
                                    <td class="CelulaZebra2">
                                        <input name="totalDespesas" type="text" class="inputReadOnly" id="totalDespesas"  value="0.00" size="5" maxlength="5" readonly="">
                                    </td>
                                    <td class="CelulaZebra2">
                                        <input name="totalAcerto" type="text" class="inputReadOnly" id="totalAcerto"  value="0.00" size="5" maxlength="12" readonly="">
                                    </td>
                                    <%if (acao.equals("baixado")) {%>
                                        <td colspan="4" class="TextoCampos"></td>
                                    <%} else {%>
                                        <td class="CelulaZebra2">
                                            <input name="valorAcertado" type="text" id="valorAcertado" size="5" maxlength="12"  value="0.00" onChange="seNaoFloatReset(this, '0.00');" class="inputtexto">
                                        </td>
                                        <td class="CelulaZebra2">
                                            <font size="1">
                                                <select name="contaAcerto" id="contaAcerto" class="fieldMin" style="width: 140px;" onClick="verFpagReembolso();">
                                                    <%//Carregando todas as contas cadastradas
                                                        BeanConsultaConta contaP = new BeanConsultaConta();
                                                        conta.setConexao(Apoio.getUsuario(request).getConexao());
                                                        conta.mostraContasViagem((nivelUserDespesaFilial > 1 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), limitarUsuarioAlterarContas, idUsuario);
                                                        ResultSet rscontaP = conta.getResultado();
                                                        while (rscontaP.next()) {
                                                            if (rscontaP.getInt("idconta") != cfg.getConta_adiantamento_viagem_id().getIdConta()) {
                                                    %>
                                                                <option value="<%=rscontaP.getString("idconta")%>" <%=(rscontaP.getInt("idconta") == cfg.getConta_padrao_id().getIdConta() ? "selected" : "")%>> <%=rscontaP.getString("numero") + "-" + rscontaP.getString("digito_conta") + " / " + rscontaP.getString("banco")%></option>
                                                        <%}
                                                    }
                                                    rscontaP.close();%>
                                                </select>
												<input name="isReembolsoCheque" type="checkbox" id="isReembolsoCheque"  value="checkbox" onClick="javascript:verFpagReembolso();" >
                                                Em cheque:
                                                <input name="docAcerto" type="text" id="docAcerto" size="6" maxlength="12"  value="" class="inputtexto">
												<%if(cfg.isControlarTalonario()){%>
													<select name="docAcertoSelect" id="docAcertoSelect" class="fieldMin" style="display:none;">
														<option value="" > ---- </option>          
													</select>
												<%}%>
                                            </font>
                                        </td>
                                    <%}%>
                                </tr>
                            </table>
                        <%}%>
                        <table width="100%" border="0" class="bordaFina">
                            <tbody id="desp_notes">
                                <tr class="tabela">
                                    <td colspan="13" align="center">Despesas</td>
                                </tr>
                                <tr>
								    <td colspan="13">
										<table width="100%" border="0" class="bordaFina">
											<tr>
												<td width="40%" class="TextoCampos">Valor Previsto para as Despesas dessa Viagem:</td>
												<td width="10%" class="CelulaZebra2">
													<input name="valorPrevistoViagem" type="text" class="fieldmin" id="valorPrevistoViagem" value="<%=carregaViag ? viag.getValorPrevistoViagem() : "0.00"%>" size="8" maxlength="12" onchange="seNaoFloatReset(this, '0.00');totalDespesasAvista();">
												</td>
												<td width="40%" class="TextoCampos">
													Total de Cr&eacute;dito de Viagem Retorno:
												</td>
												<td width="10%" class="CelulaZebra2">
													<input name="totalCreditoViagemRetorno" type="text" class="inputReadOnly8pt" readonly="" id="totalCreditoViagemRetorno" value="0" size="8" maxlength="12" onchange="seNaoFloatReset(this, '0.00');">
												</td>
											</tr>
										</table>
									</td>
                                </tr>
                                <tr>
                                    <td width="2%" class="CelulaZebra2">
                                        <%if (!acao.equals("baixado")){%>
                                            <img src="img/add.gif" border="0" class="imagemLink " title="Adicionar uma nova Nota fiscal" onClick="javascript:addNotes(0,'','','','','','',0,'',0,'',0,false);">
                                    </td>
                                        <%}%>
                                    <td width="2%" class="CelulaZebra2NoAlign" align="center"></td>
                                    <td width="2%" class="CelulaZebra2NoAlign" align="center"></td>
                                    <td width="8%" class="CelulaZebra2NoAlign" align="center">Despesa</td>
                                    <td width="8%" class="CelulaZebra2">Tipo/Mov</td>
                                    <td width="6%" class="CelulaZebra2">Esp&eacute;cie</td>
                                    <td width="4%" class="CelulaZebra2">S&eacute;rie</td>
                                    <td width="6%" class="CelulaZebra2">NF</td>
                                    <td width="9%" class="CelulaZebra2">Emiss&atilde;o</td>
                                    <td width="24%" class="CelulaZebra2">Fornecedor</td>
                                    <td width="24%" class="CelulaZebra2">Hist&oacute;rico</td>
                                    <td width="7%" class="CelulaZebra2">Valor</td>
                                    <td width="2%" class="CelulaZebra2"></td>
                                </tr>
                            </tbody>
                        </table>
                        <table width="100%" border="0" class="bordaFina" style="display:<%=(cfg.getPlanoCustoComissaoMotorista().getIdconta() != 0 && acao.equals("iniciarbaixa") ? "" : "none")%>">
							<tr class="tabela">
								<td align="center" colspan="7">Informações para pagamento da comissão do motorista</td>
							</tr>
							<tr class="celula">
								<td width="13%">Valor Gasto</td>
								<td width="13%">B. Cálculo</td>
								<td width="13%">Comissão</td>
								<td width="13%">Desconto</td>
								<td width="13%">Acréscimos</td>
								<td width="13%">A pagar</td>
								<td width="22%"></td>
							</tr>
							<tr class="celula">
								<td class="CelulaZebra2">
                                    <input name="valorGasto" type="text" class="inputReadOnly8pt" id="valorGasto" value="" size="8" maxlength="12" readonly="" onchange="seNaoFloatReset(this, '0.00');">
								</td>
								<td class="CelulaZebra2">
                                    <input name="valorLiquido" type="text" class="inputReadOnly8pt" id="valorLiquido" value="" size="8" maxlength="12" readonly="" onchange="seNaoFloatReset(this, '0.00');">
								</td>
								<td class="CelulaZebra2">
                                    <input name="comissao" type="text" class="inputReadOnly8pt" id="comissao" value="" size="8" maxlength="12" readonly="" onchange="seNaoFloatReset(this, '0.00');">
								</td>
								<td class="CelulaZebra2">
                                    <input name="desconto" type="text" class="inputReadOnly8pt" id="desconto" value="" size="7" maxlength="12" onchange="seNaoFloatReset(this, '0.00');" readonly="">
								</td>
								<td class="CelulaZebra2">
                                    <input name="acrescimos" type="text" class="fieldMin" id="acrescimos" value="<%=(carregaViag ? viag.getAcrescimoComissaoMotorista() : 0)%>" size="7" maxlength="12" onchange="seNaoFloatReset(this, '0.00');totalDespesasAvista();">
								</td>
								<td class="CelulaZebra2">
                                    <input name="valorAPagar" type="text" class="inputReadOnly8pt" id="valorAPagar" value="" size="8" maxlength="12" onchange="seNaoFloatReset(this, '0.00');totalAdiantamento();" readonly="">
								</td>
								<td class="CelulaZebra2">
                                    <%if (acao.equals("iniciarbaixa")) {%>
                                        <input  name="gerarDespesa" type="button" class="botoes" id="gerarDespesa" onClick="javascript:prepararAddComissao();" value="Gerar Comissão" />
                                    <%}%>
								</td>
							</tr>
                        </table>
                        <table width="100%" border="0" class="bordaFina" id="descontoMotorista">
                            <tbody id="tbDesconto">
                                <tr class="tabela">
                                    <td colspan="11" align="center">Descontos Extras do Motorista</td>
                                </tr>
                                <tr>
                                    <td width="8%" class="CelulaZebra2NoAlign" align="center" >Plano de Custo</td>
                                    <td width="8%" class="CelulaZebra2NoAlign" align="center" >Valor</td>
                                    <td width="50%" class="CelulaZebra2NoAlign" align="center" >Hist&oacute;rico</td>
                                </tr>
                            </tbody>
                            <tr class="tabela">
                                <td width="8%" class="CelulaZebra2NoAlign" align="center" >Total de Descontos:</td>
                                <td class="CelulaZebra2NoAlign" align="center">
                                    <input name="totalDesconto" type="text" class="inputReadOnly" id="totalDesconto"  value="0.00" size="7" maxlength="12" readonly="">
                                </td>
                                <td colspan="4" class="CelulaZebra2NoAlign">
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </div>
                <div class="panel" id="tab2">
                    <fieldset>
                        <table width="100%" border="0" class="bordaFina">
                            <tr class="tabela">
                                <td colspan="2" align="center">Percurso</td>
                            </tr>
                            <tr>
                                <td width="25%" class="TextoCampos">Descri&ccedil;&atilde;o da Origem:</td>
                                <td width="75%" class="CelulaZebra2">
                                    <input name="origem" type="text" id="origem" onBlur="this.value = this.value.substring(0,200);" value="<%=(carregaViag ? viag.getOrigem() : "")%>" size="60" class="inputtexto">
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Descri&ccedil;&atilde;o do Destino:</td>
                                <td class="CelulaZebra2">
                                    <input name="destino" type="text" id="destino" onBlur="this.value = this.value.substring(0,200);" value="<%=(carregaViag ? viag.getDestino() : "")%>" size="60" class="inputtexto">
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <table border="0" cellpadding="0" cellspacing="1" width="100%">
                                        <tbody id="tbRota">
                                            <tr class="celula">
                                                <td width="2%" >
                                                    <img src="img/add.gif" border="0" class="imagemLink " title="Adicionar uma nova Rota" onClick="javascript:addViagemRota();">
                                                </td>
                                                <td width="17%" align="center" >Rota</td>
                                                <td width="20%" align="center" >Cidade Origem</td>
                                                <td width="9%" align="center" >Data Saída</td>
                                                <td width="9%" align="center" >KM Saída</td>
                                                <td width="20%" align="center" >Cidade Destino</td>
                                                <td width="9%" align="center" >Data Chegada</td>
                                                <td width="9%" align="center" >KM Chegada</td>
                                                <td width="14%" align="center" >Observa&ccedil;&atilde;o</td>
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
                        <table width="100%" border="0" class="bordaFina">
                            <tr class="tabela">
                                <td colspan="2" align="center">CT(s) Dessa Viagem</td>
                            </tr>
                            <tr>
                                <td width="25%" class="TextoCampos">
                                    <div align="center">
                                        <input  name="localiza_ctrc" type="button" class="botoes" id="localiza_ctrc" onClick="javascript:localizaCtrc();" value="Selecionar CTRCs" />
                                    </div>	
                                </td>
                                <td width="75%" class="TextoCampos"></td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <label id="lbCtrcs" name="lbCtrcs"></label>                    
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">
                                    Total CT(s) Selecionados:
                                </td>
                                <td class="CelulaZebra2">
                                    <span class="CelulaZebra2">
                                        <input name="totalCtrc" type="text" class="inputReadOnly" id="totalCtrc"  value="<%=totalCtrc%>" size="8" maxlength="10" readonly>
                                    </span>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </div>
                <div class="panel" id="tab4">
                    <fieldset>
                        <table width="100%" border="0" class="bordaFina">
                            <tr class="tabela">
                                <td align="center" colspan="3">
                                    <font color="red">
                                        As Informa&ccedil;&otilde;es dessa aba S&oacute; Dever&atilde;o ser Preenchidas Caso a Empresa Tamb&eacute;m Utilize o M&oacute;dulo gwFrota, pois os Relat&oacute;rios de M&eacute;dia de Combust&iacute;vel S&oacute; Poder&atilde;o ser Visualizados pelo M&oacute;dulo gwFrota.
                                    </font>	
                                </td>
                            </tr>
                            <tr>
                                <td align="10%" class="CelulaZebra2"></td>
                                <td align="40%" class="CelulaZebra2">Km Sa&iacute;da:</td>
                                <td align="40%" class="CelulaZebra2">
                                    <label id="lbKmChegada">
                                    Km Chegada:
                                    </label>
                                </td>
                            </tr>
                            <tr>
                                <td align="10%" class="TextoCampos">Cavalo: </td>
                                <td align="40%" class="CelulaZebra2">
                                    <input name="km_saida" type="text" class="fieldmin" id="km_saida"  value="<%=carregaViag ? viag.getKmSaida() : "0"%>" size="8" maxlength="12" onchange="seNaoIntReset(this, '0');">
                                </td>
                                <td align="40%" class="CelulaZebra2">
                                    <input name="kmChegada" type="text" class="fieldmin" id="kmChegada"  value="<%=carregaViag ? viag.getKmChegada() : "0"%>" size="8" maxlength="12" onchange="seNaoIntReset(this, '0');">
                                </td>
                            </tr>
                            <tr id="trCarretaKm">
                                <td align="10%" class="TextoCampos">Carreta: </td>
                                <td align="40%" class="CelulaZebra2">
                                    <input name="Carreta_km_saida" type="text" class="fieldmin" id="Carreta_km_saida"  value="<%=carregaViag ? viag.getKmSaidaCarreta() : "0"%>" size="8" maxlength="12" onchange="seNaoIntReset(this, '0');">
                                </td>
                                <td align="40%" class="CelulaZebra2">
                                    <input name="Carreta_kmChegada" type="text" class="fieldmin" id="Carreta_kmChegada"  value="<%=carregaViag ? viag.getKmChegadaCarreta() : "0"%>" size="8" maxlength="12" onchange="seNaoIntReset(this, '0');">
                                </td>
                            </tr>
                            <tr id="trBitremKm">
                                <td align="10%" class="TextoCampos">Bitrem: </td>
                                <td align="40%" class="CelulaZebra2">
                                    <input name="Bitrem_km_saida" type="text" class="fieldmin" id="Bitrem_km_saida"  value="<%=carregaViag ? viag.getKmSaidaBitrem() : "0"%>" size="8" maxlength="12" onchange="seNaoIntReset(this, '0');">
                                </td>
                                <td align="40%" class="CelulaZebra2">
                                    <input name="Bitrem_kmChegada" type="text" class="fieldmin" id="Bitrem_kmChegada"  value="<%=carregaViag ? viag.getKmChegadaBitrem() : "0"%>" size="8" maxlength="12" onchange="seNaoIntReset(this, '0');">
                                </td>
                            </tr>
                        </table>
                        <table width="100%" border="0" class="bordaFina">
                            <tr class="tabela">
                                <td colspan="4" align="right">
                                    <label style="margin-right:14%">Abastecimentos Desta Viagem:</label>
                                    <input type="button" style="margin-right:5%" value="      Incluir Abastecimento    " class="inputbotao" onclick="addAbastecimento();"/>
                                </td>
                            </tr>
                            <tr name="trAbastecimento" id="trAbastecimento" style="display: none;">
                                <td colspan="6">
                                    <table width="100%" class="bordaFina" cellspacing="1" cellpadding="1">
                                        <tbody id="abastecimento" name="abastecimento" onload="applyFormatter();">
                                            <tr>
                                                <td width="2%" class="CelulaZebra2"></td>
                                                <td width="5%" class="CelulaZebra2">
                                                    <input type="hidden" value="0" name="maxAbast" id="maxAbast" />
                                                    <select name="CombustivelAbastecimento" class="inputtexto" id="CombustivelAbastecimento" style="display: none;">
                                                    </select>
                                                </td>
                                                <td width="9%" class="CelulaZebra2">Data</td>
                                                <td width="9%" class="CelulaZebra2">Categoria</td>
                                                <td width="36%" class="CelulaZebra2">&nbsp;</td>
                                                <td width="9%" class="CelulaZebra2">Comb.</td>
                                                <td width="4%" class="CelulaZebra2">Qtd</td>
                                                <td width="5%" class="CelulaZebra2">Unit.</td>
                                                <td width="5%" class="CelulaZebra2">Total</td>
                                                <td width="5%" class="CelulaZebra2">
                                                    <select name="tipoCalculo" class="fieldMin" id="tipoCalculo" style="width:50px" onChange="validaTipoCalculo()">
                                                        <option value="km" >Km</option>
                                                        <option value="horimetro" >Horim.</option>
                                                    </select>
                                                </td>
                                                <td width="5%" class="CelulaZebra2">Encheu</td>
                                                <td width="7%" class="CelulaZebra2NoAlign" align="center">Média</td>
                                                <td width="1%" class="CelulaZebra2">&nbsp;</td>
                                            </tr>                                            
                                        </tbody>
                                        <tr class="tabela">
                                            <td colspan="8" align="right"></td>
                                            <td colspan="3" align="left">                                    
                                                <input id="idTotalAbastecimento" type="text" class="inputReadOnly8pt" value="0,000" size="5" readonly="true"/>
                                            </td>
                                            <td align="right">
                                                <label id="totalMedia"></label>  
                                            </td>
                                            <td align="right">
                                            </td>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </div>
                                <div class="panel" id="tab5">
                                    <fieldset>
                                        <table width="100%" border="0" class="bordaFina">
                                            <tbody id="tbGwMobile" name="tbGwMobile">
                                            <tr>
                                                <td colspan="7"  class="tabela"><div align="center">GW Mobile</div></td>
                                            </tr>
                                            <tr>
                                                <td colspan="7"  class="">
                                                    <table width="100%" class="bordaFina">
                                                        <c:if test="<%= (carregaViag && viag.isSincronizadoMobile()) %>">
                                                            <tr class="celulaZebra2">
                                                                <td width="20%">Status:</td>
                                                                <td width="80%" colspan="3" style="font-weight: bold">Sincronizado</td>
                                                            </tr>
                                                            <tr class="celulaZebra2">
                                                                <td width="20%">Usuário que sincronizou: </td>
                                                                <td width="20%"> <%= viag.getUsuarioSincronizacaoMobile().getNome() %> </td>
                                                                <td width="20%">Data de sincronização:</td>
                                                                <td width="20%"> <%= Apoio.formatData(viag.getDataSincronizacaoMobile(), "dd/MM/yyyy") +" "+ viag.getHoraSincronizacaoMobile() %> </td>
                                                            </tr>
                                                        </c:if>
                                                        <c:if test="<%= (carregaViag && !viag.isSincronizadoMobile()) %>">
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
                                    </fieldset>                
                                </div>
                <div class="panel" id="tab6">
                    <fieldset>
                        <table width="100%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina" style='display: <%= carregaViag && nivelUser == 4 ? "" : "none" %>'>
                            <tr>
                                <td  colspan="7">
                                    <table width="100%" align="center" cellpadding="1" cellspacing="1" class="bordaFina">
                                        <%@include file="/gwTrans/template_auditoria.jsp" %>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td width="10%" class="TextoCampos">Incluso:</td>
                                <td width="45%" class="CelulaZebra2">
                                    Em: <%=(carregaViag ? fmt.format((viag.getCreatedAt() != null ? viag.getCreatedAt() : new Date())) : "")%>
                                    <br>
                                    Por: <%=(carregaViag) ? viag.getCreatedBy().getNome() : ""%>
                                </td>
                                <td width="10%" class="TextoCampos">Alterado:</td>
                                <td width="45%" class="CelulaZebra2">
                                    Em: <%=(carregaViag && viag.getUpdatedAt() != null) ? fmt.format(viag.getUpdatedAt()) : ""%>
                                    <br>
                                    Por: <%=(carregaViag && viag.getUpdatedBy().getNome() != null ? viag.getUpdatedBy().getNome() : "")%>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </div>

            </div>
            <br>
            <table width="95%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr>
                    <td class="tabela" colspan="2" align="center">Outras Informa&ccedil;&otilde;es</td>
                </tr>
                <tr>
                    <td width="20%" class="TextoCampos">Observa&ccedil;&atilde;o:</td>
                    <td width="80%" class="CelulaZebra2">
                        <textarea name="observacao" rows="4" cols="55" id="observacao" class="inputtexto"><%=(carregaViag ? viag.getObservacao() : "")%></textarea>
                    </td>
                </tr>
            </table>           
        </form>
                    <br/>
        <table width="95%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
            <tr class="CelulaZebra2">
                <td>
                    <% if (nivelUser >= 2) {%>
                        <center>
                            <%if (acao.equals("iniciarbaixa")) {%>
                                  <input name="baixar" type="button" class="botoes" id="baixar" value="Baixar" onClick="javascript:tryRequestToServer(function(){baixar();});">
                            <%} else if (acao.equals("baixado") && nivelUser == 4) {%>
                                  <input name="salvar" type="button" class="botoes" id="salvar" value="  Salvar  " onClick="javascript:tryRequestToServer(function(){salvar('atualizar_baixado');});">
                                  <input name="excluirBaixa" type="button" class="botoes" id="excluirBaixa" value="  Excluir Baixa  " onClick="javascript:tryRequestToServer(function(){excluirBaixa();});">
                            <%} else if (!acao.equals("baixado")) {%>
                                  <input name="salvar" type="button" class="botoes" id="salvar" value="  Salvar  " onClick="javascript:tryRequestToServer(function(){salvar('<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>');});">
                            <%}%>
                        </center>
                    <%}%>
                </td>
            </tr>
        </table>
     </div>
  </body>
</html>
