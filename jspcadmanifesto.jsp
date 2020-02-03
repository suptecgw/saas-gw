<%@page import="cidade.BeanCidade"%>
<%@page import="java.util.TimeZone"%>
<%@page import="java.util.Calendar"%>
<%@page import="fornecedor.TarifaEspecificaAero"%>
<%@page import="br.com.gwsistemas.embalagem.Embalagem"%>
<%@page import="br.com.gwsistemas.embalagem.EmbalagemDAO"%>
<%@page import="cliente.tipoProduto.TipoProduto"%>
<%@page import="conhecimento.manifesto.ajudante.ManifestoAjudante"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.Connection"%>
<%@page import="conhecimento.manifesto.gerenciandorrisco.ManifestoIsca"%>
<%@page import="conhecimento.manifesto.gerenciandorrisco.ManifestoParada"%>
<%@page import="conhecimento.manifesto.gerenciandorrisco.ManifestoEscolta"%>
<%@page import="fornecedor.BeanFornecedor"%>
<%@page import="fornecedor.BeanCadFornecedor"%>
<%@page import="br.com.gwsistemas.gwmdfe.CondutoresMDFe"%>
<%@page import="com.thoughtworks.xstream.io.json.JettisonMappedXmlDriver"%>
<%@page import="com.thoughtworks.xstream.XStream"%>
<%@page import="nucleo.autorizacao.tipoautorizacao.TipoAutorizacao"%>
<%@page import="rota.Rota"%> 
<%@page import="rota.CadRota"%>
<%@page import="conhecimento.awb.BeanConsultaAWB"%>
<%@page import="conhecimento.awb.BeanAWB"%>
<%@page import="conhecimento.awb.BeanCadAWB"%>
<%@page import="nucleo.Auditoria.Auditoria"%>
<%@page import="br.com.gwsistemas.movimentacao.pallets.MovimentacaoPallets"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Collection"%>
<%@page import="conhecimento.ocorrencia.Ocorrencia"%>
<%@ page contentType="text/html" language="java"
         import="java.sql.ResultSet,
         java.text.*,
         nucleo.*,
         motorista.*,
         conhecimento.manifesto.*,
         java.util.Date,
         fornecedor.BeanConsultaFornecedor,
         java.util.Vector,
         conhecimento.*" errorPage="" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<script language="JavaScript" src="script/<%=Apoio.noCacheScript("builder.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("prototype_1_7_2.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("ie.js")%>" type="text/javascript"></script>
<script language="javascript" src="script/<%=Apoio.noCacheScript("funcoes.js")%>" type="text/javascript"></script>
<script language="javascript" src="script/<%=Apoio.noCacheScript("LogAcoesAuditoria.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="${homePath}/script/jQuery/jquery.js?v=${random.nextInt()}"></script>
<script language="javascript" src="script/funcoesTelaCadManifesto.js?v=${random.nextInt()}" type="text/javascript"></script>

<%
            BeanUsuario autenticado = Apoio.getUsuario(request);
             // privilégio de permissao. Ex.: if (nivelUser == 4) <usuario pode excluir
            int nivelUser = autenticado.getAcesso("cadmanifesto");
            int nivelImpresso = autenticado.getAcesso("alterarmanifestoimpresso");
            int nivelMDFeCOnfirmado = autenticado.getAcesso("altmdfeconfirmado");
            int nivelCondutorMDFe = autenticado.getAcesso("condutoradicionalmdfe");
            //testando se a sessao é válida e se o usuário tem acesso
            if ((autenticado == null) || (nivelUser == 0)) {
                response.sendError(response.SC_FORBIDDEN);
            }
            //fim da MSA
            
%>
<%//ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de

            String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
            String acaoanterior = (request.getParameter("acaoanterior") == null ? "" : request.getParameter("acaoanterior"));
            boolean carregamanif = false;
            BeanCadManifesto cadmanif = null;
            BeanManifesto manif = null;
            BeanConsultaManifesto mostractrc = null;
            BeanConfiguracao cfg = null;
            DecimalFormat df = new DecimalFormat("0.00");
            boolean iscarregaawb = false;
            BeanCadAWB cadawb = null;
            BeanAWB awb = null;
            BeanConsultaAWB carregaAwb = null;
            TarifaEspecificaAero tarifaEspecifica;
            //instanciando um formatador de simbolos
            DecimalFormatSymbols dfs = new DecimalFormatSymbols();
            dfs.setDecimalSeparator('.');
            DecimalFormat vlrformat = new DecimalFormat("0.00", dfs);
            vlrformat.setDecimalSeparatorAlwaysShown(true);
            //Variáveis que servirão para armazenar os valores do loop dos conhecimentos
            int linha = 0;
            int linhaOco = 0;
            float qtd = 0;
            float peso = 0;
            Double pesoReal = 0.0;
            Double volumeReal = 0.0;
            float notas = 0;
            double frete = 0;
            //Instaciando variável para formatação de datas
            SimpleDateFormat formato = new SimpleDateFormat("dd/MM/yyyy");
            SimpleDateFormat formatoHora = new SimpleDateFormat("HH:mm");
            String hora = formatoHora.format(new Date());
            Calendar c = Calendar.getInstance();
            String data = formato.format(new Date());
            
            // se a filial usa horario VERAO e se a UF estiver na lista vai pegar com time zone.
            if (autenticado.getFilial().isIsAtivarHoraVerao()
                    && (Apoio.getConfiguracao(request).getListaUfTimeZone().get(autenticado.getFilial().getUf())) != null) {
                String timeZone = Apoio.getConfiguracao(request).getListaUfTimeZone().get(autenticado.getFilial().getUf());
                c.setTimeZone(TimeZone.getTimeZone(timeZone));
                c.add(Calendar.HOUR, 1);
                hora = Apoio.getFormatTime(c.getTime());
                data = formato.format(c.getTime());
            }
            
            //Carregando as configuraões independente da ação
            cfg = new BeanConfiguracao();
            cfg.setConexao(autenticado.getConexao());
            //Carregando as configurações
            cfg.CarregaConfig();
            CadRota cadRota = new CadRota(autenticado.getConexao());
            Collection<Rota> rotas = cadRota.mostrarTodos();
            // carregando os tipos de produtos cia aerea. 
            Collection<TipoProduto> productTypesAereo = TipoProduto.RepresentanteAereo(Apoio.getConnectionFromUser(request));
            // carregando os tipos de embalagens. 
            EmbalagemDAO embalagem= null;
            Collection<Embalagem> embalagemLista = EmbalagemDAO.listaEmbalagem(Apoio.getConnectionFromUser(request));
            //Metódo para excluir uma ocorrencia.
            if(acao.equals("excluir")) {
                    BeanCadManifesto beanCM = new BeanCadManifesto();
                    beanCM.setExecutor(autenticado);
                    beanCM.setConexao(autenticado.getConexao());
                    int id = Integer.parseInt(request.getParameter("id"));
                    int idManif = Integer.parseInt(request.getParameter("idManif"));
                    int idUser = autenticado.getIdusuario();
                    Auditoria aud = new Auditoria();
                    aud.setIp(request.getRemoteHost());
                    aud.setAcao("Excluir uma ocorrencia do manifesto");
                    aud.setRotina("Alterar Manifesto");
                    aud.setUsuario(autenticado);
                    aud.setModulo("Webtrans Manifesto");                   
                    beanCM.exluirOcorrencia(id, aud, idUser, idManif);
            } 
            //Método para excluir condutor
            if(acao.equals("excluirCondutor")){
                int id = Integer.parseInt(request.getParameter("id_"));
                BeanCadManifesto beanCM = new BeanCadManifesto();
                beanCM.setExecutor(autenticado);
                beanCM.setConexao(autenticado.getConexao());
                Auditoria auditoria = new Auditoria();
                auditoria.setIp(request.getRemoteHost());
                auditoria.setAcao("Excluir um condutor do manifesto");
                auditoria.setRotina("Alterar Manifesto");
                auditoria.setUsuario(autenticado);
                auditoria.setModulo("Webtrans Manifesto");
                beanCM.excluirCondutor(id, auditoria);
            }
             if(acao.equals("excluirParadas")){
                int id = Integer.parseInt(request.getParameter("idParadas"));
                BeanCadManifesto beanCM = new BeanCadManifesto();
                beanCM.setExecutor(autenticado);
                beanCM.setConexao(autenticado.getConexao());
                
                Auditoria auditoria = new Auditoria();
                auditoria.setIp(request.getRemoteHost());
                auditoria.setAcao("Excluir um condutor do manifesto");
                auditoria.setRotina("Alterar Manifesto");
                auditoria.setUsuario(autenticado);
                auditoria.setModulo("Webtrans Manifesto");
                
                beanCM.excluirParada(id, auditoria);
            }
            if(acao.equals("iniciar") || acao.equals("editar")) {
                // Carregando tarifas específicas.
                BeanCadFornecedor cadForn = new BeanCadFornecedor();
                cadForn.setConexao(autenticado.getConexao());
                request.setAttribute("tarifasEspecificas", cadForn.mostrarTarifasEspecificas());
            }
            //instrucoes em comum entre as acoes
            if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar") || acao.equals("calcula")) {    //instanciando o bean de cadastro
                cadmanif = new BeanCadManifesto();
                cadmanif.setExecutor(autenticado);
                cadmanif.setConexao(autenticado.getConexao());
                cadawb = new BeanCadAWB();
                cadawb.setExecutor(autenticado);
                cadawb.setConexao(autenticado.getConexao());
                mostractrc = new BeanConsultaManifesto();
                mostractrc.setConexao(autenticado.getConexao());
                boolean erroAntesSalvar = false;
                String msgErroAntesSalvar = "";
                awb = new BeanAWB();
                //executando a acao desejada
                //ao solicitar alteração o bean será carregado com todos os dados do id atual
                if ((acao.equals("editar")) && (request.getParameter("id") != null)) {
                    int idmanifesto = Integer.parseInt(request.getParameter("id"));
                    cadmanif.getManifesto().setIdmanifesto(idmanifesto);
                    //carregando o conhecimento por completo
                    cadmanif.LoadAllPropertys();
                    String param = cadmanif.getManifesto().getStatusManifesto();
                    manif = cadmanif.getManifesto();
                    if(manif instanceof BeanAWB){
                        awb = (BeanAWB) manif;
                        request.setAttribute("awb", awb);
                    }
                    request.setAttribute("statusManifesto", param);
                    
           
                    
                } else //ao clicar no salvar dessa tela
                if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir"))) {
                    Collection listaOco = new ArrayList();
                    Ocorrencia oco = null;
                    int qtdOco = Integer.parseInt(request.getParameter("qtdOco"));
                    int pp = 0;
                    for (int i = 1; i <= qtdOco; i++) {
                        oco = new Ocorrencia();
                        if (request.getParameter("ocorrenciaId_" + i) != null) {
                            oco.setId(Integer.parseInt(request.getParameter("ocorrenciaId_" + i)));
                            oco.setOcorrenciaManifestoId(Integer.parseInt(request.getParameter("ocorrenciaManifestoId_" + i)));
                            oco.setListaIds(request.getParameter("listaIds_" + i));
                            oco.getOcorrencia().setId(Integer.parseInt(request.getParameter("ocorrenciaIdCtrc_" + i)));
                            oco.setOcorrenciaEm(Apoio.paraDate(request.getParameter("ocorrenciaEm_" + i)));
                            oco.setOcorrenciaAs(Apoio.paraHora(request.getParameter("ocorrenciaAs_" + i)));
                            oco.getUsuarioOcorrencia().setIdusuario(Integer.parseInt(request.getParameter("idUsuarioOcorrencia_" + i)));
                            oco.setObservacaoOcorrencia(request.getParameter("obsOcorrencia_" + i));
                            oco.setResolvido(Boolean.parseBoolean(request.getParameter("isResolvido_" + i)));
                            if (oco.isResolvido()) {
                                oco.setResolucaoEm(Apoio.paraDate(request.getParameter("resolvidoEm_" + i)));
                                oco.setResolucaoAs(Apoio.paraHora(request.getParameter("resolvidoAs_" + i)));
                                oco.getUsuarioResolucao().setIdusuario(Integer.parseInt(request.getParameter("idUsuarioResolucao_" + i)));
                                oco.setObservacaoResolucao(request.getParameter("obsResolucao_" + i));
                            }
                            //adicionando a lista
                            listaOco.add(oco);
                        }
                       }
                        Collection listaPallets = new ArrayList();
                        MovimentacaoPallets pallets = null;
                        int max = Integer.parseInt(request.getParameter("max"));
                        int mp = 0;
                        for (int m = 1; m <= max; m++) {
                            pallets = new MovimentacaoPallets();
                            if (request.getParameter("nota_" + m) != "0" && request.getParameter("data_" + m) != "" && request.getParameter("pallet_" + m) != "" && request.getParameter("idpallet_" + m) != "0" && request.getParameter("quantidade_" + m) != "") {
                                pallets.setId(Integer.parseInt(request.getParameter("idItem_" + m)));
                                pallets.getCliente().setIdcliente(Integer.parseInt(request.getParameter("idcliente_" + m)));
                                pallets.setNota(Integer.parseInt(request.getParameter("nota_" + m).equals("")?"0":request.getParameter("nota_" + m)));
                                pallets.setTipo(request.getParameter("tipo_" + m));
                                if(pallets.getTipo().equals("c")){
                                     pallets.setQuantidade(Apoio.parseInt(request.getParameter("quantidade_" + m)));
                               }else{
                                     int qt = Apoio.parseInt(request.getParameter("quantidade_" + m));
                                     int t = qt * -1;
                                     pallets.setQuantidade(t);
                               }
                                pallets.getPallet().setId(Apoio.parseInt(request.getParameter("idpallet_" + m)));
                                pallets.setData(Apoio.getFormatData(request.getParameter("data_" + m)));
                            //adicionando a lista
                            listaPallets.add(pallets);
                        }else{
                                %>
                             alert("Preencha os campos Corretamente!")
                                <%         
                        }
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


                        //colecao de motorista para ser utilizada no DOM de addCondutoresAdicionais
                        Collection listaMotorista = new ArrayList<CondutoresMDFe>();
                        CondutoresMDFe condutores = null;
                        int maxCondutores = Apoio.parseInt(request.getParameter("maxCondutores"));
                        if(maxCondutores>0){
                            for(int i = 1; i <= maxCondutores; i++){
                                condutores = new CondutoresMDFe();
                                if(request.getParameter("idMotorista_" + i) != "0" && request.getParameter("nomeMotorista_" + i) != "" && request.getParameter("id_" + i) != null){
                                    condutores.setId(Integer.parseInt(request.getParameter("id_" + i)));
                                    condutores.setIdMotorista(Apoio.parseInt(request.getParameter("idMotorista_" + i)));
                                    condutores.setNomeMotorista(request.getParameter("nomeMotorista_" + i));
                                    listaMotorista.add(condutores);
                                }
                            }
                        }
                    //Instanciando o objeto
                    if((request.getParameter("tipo_movimento")).equals("a")){
                        manif = new BeanAWB();
                    }else{
                        manif = new BeanManifesto();
                    }
                    //populando o JavaBeanidmanifesto
                    manif.setNmanifesto(request.getParameter("nmanifesto"));
                    manif.setSubCodigo(request.getParameter("subCodigo"));
                    manif.getFilial().setIdfilial(Integer.parseInt(request.getParameter("idfilial")));
                    manif.getFilial().setStUtilizacaoMDFe(request.getParameter("stUtilizacaoMdfe").charAt(0));
                    manif.getFilialdestino().setIdfilial(Integer.parseInt(request.getParameter("idfilial2")));
                    manif.getMotorista().setIdmotorista((request.getParameter("motoristaID").equals("") ? 0 : Integer.parseInt(request.getParameter("motoristaID"))));
                    manif.getCavalo().setIdveiculo(request.getParameter("veiculoId").equals("") ? 0 : Integer.parseInt(request.getParameter("veiculoId")));
                    manif.getCarreta().setIdveiculo(Integer.parseInt(request.getParameter("carretaID")));
                    manif.getBiTrem().setIdveiculo(Integer.parseInt(request.getParameter("bitremID")));
                    manif.getCidadeorigem().setIdcidade(Integer.parseInt(request.getParameter("cidadeOrigemId")));
                    manif.getCidadedestino().setIdcidade(Integer.parseInt(request.getParameter("idcidadedestino")));
                    manif.setDtsaida(Apoio.paraDate(request.getParameter("dtsaida")));
                    manif.setHrsaida(request.getParameter("hrsaida"));
                    manif.setObs(request.getParameter("obs"));
                    manif.setConferente(request.getParameter("conferente"));
                    manif.setArrumador(request.getParameter("arrumador"));
                    manif.setAjudante(request.getParameter("ajudante"));
                    manif.getConferenteNew().setId(Apoio.parseInt(request.getParameter("conferenteId")));
                    manif.getArrumadorNew().setId(Apoio.parseInt(request.getParameter("arrumadorId")));
                    manif.getAjudanteNew().setId(Apoio.parseInt(request.getParameter("ajudanteId")));


                    ManifestoAjudante conf = null;
                    for(int idxFunc = 0; idxFunc <= Apoio.parseInt(request.getParameter("qtdFuncionario"));idxFunc++){
                        conf = new ManifestoAjudante();
                        conf.setId(Apoio.parseInt(request.getParameter("idFuncionarioManifesto_"+idxFunc)));
                        conf.getAjudante().setIdfornecedor(Apoio.parseInt(request.getParameter("idFuncionario_"+idxFunc)));
                        conf.setTipo(Apoio.parseInt(request.getParameter("tipoFuncionario_"+idxFunc)));
                        conf.setRemovido(Apoio.parseBoolean(request.getParameter("isRemovido_"+idxFunc)));
                        manif.getListaConferentes().add(conf);
                    }

                    manif.setNumeroLacre(request.getParameter("numeroLacre"));
                    manif.setDtprevista((request.getParameter("dtprevista").equals("") ? null : Apoio.paraDate(request.getParameter("dtprevista"))));
                    manif.setHrprevista((request.getParameter("hrprevista").equals("") ? null : request.getParameter("hrprevista")));
                    manif.setLibmotorista(request.getParameter("motoristaLiberacao"));
                    //campo do numero de protocolo de averbacao (08/10/2013) Anderson
                    manif.setNumeroProtocoloAverbacao((request.getParameter("protocoloAverbacao").equals("") ? null : request.getParameter("protocoloAverbacao")));
                    manif.setTipoDestino(request.getParameter("tipoDestino"));
                    manif.getRedespachante().setIdfornecedor(Integer.parseInt(request.getParameter("idredespachante")));
                    manif.getRota().setId(Apoio.parseInt(request.getParameter("rota")));
                    manif.getPercurso().setId(Apoio.parseInt(request.getParameter("percurso")));
                    manif.setIsPreManifesto(Apoio.parseBoolean(request.getParameter("ismanifesto")));
                    manif.setValorMaximoManifesto(Apoio.parseDouble(request.getParameter("valorMaximoSeguradora")));
                    manif.setCodigoPgr(Apoio.parseInt(request.getParameter("codigoPgr")));
                    manif.getAgenteCarga().setIdfornecedor(Integer.parseInt(request.getParameter("idagente_carga")));
                    manif.setValorCustoGerenciamento(Apoio.parseDouble(request.getParameter("valorCustoGerenciamento")));
                    //campos para cidade e endereços de saida para a buonny
                    manif.getFilialEnderecoSaidaBuonny().setId(Apoio.parseInt(request.getParameter("slcEnderecoSaidaBuonny")));
                    manif.setSerieMdfe(request.getParameter("serieMdfe"));
                    manif.getFilialdestino().setCidadeAtendidas(Apoio.parseBoolean(request.getParameter("chk_cidade_atendidas")));
                    manif.getTriTrem().setIdveiculo(Apoio.parseInt(request.getParameter("tritremID")));
                    cfg.setTipoOrdenacaoCteManifesto(request.getParameter("ordenacaoCfeManifesto"));
//                    manif.getFilialEnderecoSaidaBuonny().getEndereco().getCidade().setIdcidade(Apoio.parseInt(request.getParameter("idCidadeSaidaBuonny")));
                    //Dados companhia aerea
                    manif.setTipo(request.getParameter("tipo_movimento"));
                    if(manif instanceof BeanAWB){
                        awb = (BeanAWB) manif;
                        awb.setNumeroAWB(request.getParameter("numeroAWB"));
                        awb.setNumero(request.getParameter("numeroCTE"));
                        awb.setNumeroVoo(request.getParameter("numeroVoo"));
                        awb.setChaveAcessoAwb(request.getParameter("chaveCTE"));
                        awb.setMatriculaAeronave(request.getParameter("matriculaAero"));
                        awb.setNacAeronave(request.getParameter("nacAero"));
                        awb.setValorFrete(Double.parseDouble(request.getParameter("valorFrete")));
                        awb.getCidadeDestino().setIdcidade(Apoio.parseInt(request.getParameter("idcidadedestino")));
                        awb.getCidadeOrigem().setIdcidade(Apoio.parseInt(request.getParameter("cidadeOrigemId")));
                        awb.getCompanhiaAerea().setIdfornecedor(Apoio.parseInt(request.getParameter("idcompanhia")));
                        awb.getCompanhiaAerea().setRazaosocial(request.getParameter("companhia_aerea"));
                        awb.setEmissaoEm(request.getParameter("emissaoEm").equals("")?Apoio.paraDate(request.getParameter("dtsaida")):Apoio.paraDate(request.getParameter("emissaoEm")));
                        awb.setEmissaoAs(request.getParameter("emissaoAs"));
                        awb.setPrevisaoEmbarqueEm(request.getParameter("previsaoEmbarqueEm").equals("")?null:Apoio.paraDate(request.getParameter("previsaoEmbarqueEm")));
                        awb.setPrevisaoEmbarqueAs(request.getParameter("previsaoEmbarqueAs"));
                        awb.setPercIcms(Apoio.parseDouble(request.getParameter("valorIcms")));
                        awb.setVolumes(Apoio.parseDouble(request.getParameter("volumesAWB")));
                        awb.setPesoTaxado(Apoio.parseDouble(request.getParameter("pesoAWB")));
                        awb.getCfop().setIdcfop(Apoio.parseInt(request.getParameter("idcfop")));
                        awb.getAeroportoOrigem().setId(Apoio.parseInt(request.getParameter("aeroportoColetaId")));
                        awb.getAeroportoDestino().setId(Apoio.parseInt(request.getParameter("aeroportoEntregaId")));
                         // novos campos 16/02/2018.
                        awb.setTipoProdutoOperacaoId(Apoio.parseInt(request.getParameter("tipo_produto_operacao")));   
                        awb.setTipoPagamento(Apoio.parseInt(request.getParameter("tipoPg")));
                        awb.setTipoEntrega(Apoio.parseInt(request.getParameter("tipoRetirada")));
                        awb.setTipoEmbalagemId(Apoio.parseInt(request.getParameter("tipoEmbalagem")));
                        awb.setDescricaoConteudo(request.getParameter("conteudoDes"));
                        //Novos campos 02/04/2018
                        awb.setValorFixo(Apoio.parseDouble(request.getParameter("valorFixo")));
                        awb.setFreteNacional(Apoio.parseDouble(request.getParameter("freteNacional")));
                        awb.setAdvalorem(Apoio.parseDouble(request.getParameter("advalorem")));
                        awb.setTaxaColeta(Apoio.parseDouble(request.getParameter("taxaColeta")));
                        awb.setTaxaEntrega(Apoio.parseDouble(request.getParameter("taxaEntrega")));
                        awb.setTaxaCapatazia(Apoio.parseDouble(request.getParameter("taxaCapatazia")));
                        awb.setTaxaFixa(Apoio.parseDouble(request.getParameter("taxaFixa")));
                        awb.setTaxaDesembaraco(Apoio.parseDouble(request.getParameter("taxaDesembaraco")));
                        awb.setValorAWBCalculado(Apoio.parseDouble(request.getParameter("vlAWBCalculado")));
                        tarifaEspecifica = new TarifaEspecificaAero();
                        tarifaEspecifica.setId(Apoio.parseInt(request.getParameter("tarifaEspecifica")));
                        awb.setTarifaEspecifica(tarifaEspecifica);
                    }
                    manif.getSeguradora().setIdfornecedor(Integer.parseInt(request.getParameter("seguradora")));
                    //adicionando as ocorrencias
                    manif.setOcorrencias(listaOco);
                    //adicionando as movimentações
                    manif.setItens(listaPallets);
                    //adicionando as iscas
                    manif.setIscas(listIscas);
                    //adicionando os condutores
                    manif.setListaCondutoresMDFe(listaMotorista);
                    //Preenchendo o array dos conhecimentos
                    int qtdCtrc = request.getParameter("ctrcs").split(",").length;
                    int qtdLinhasCTe = Apoio.parseInt(request.getParameter("qtdLinhasCTe"));
//                    BeanConhecimento[] arrayCtrcs = new BeanConhecimento[qtdLinhasCTe];                    
                    BeanConhecimento ct = null;
                    for (int k = 0; k < qtdLinhasCTe; ++k) {
                        ct = new BeanConhecimento();
                        if(request.getParameter("idCTe_"+k) != null){
//                            ct.setId(Integer.parseInt(request.getParameter("ctrcs").split(",")[k]));
//                            ct.setIcmsBarreira(Float.parseFloat(request.getParameter("pesos").split(",")[k]));
//                            ct.setGeraPinSuframa(request.getParameter("isPin"+k) != null);
                            ct.setId(Integer.parseInt(request.getParameter("idCTe_"+k)));
                            //Utilizando o atributo ICMSBarreira provisoriamente para não precisar criar um outro atributo apenas para esse processo
                            ct.setIcmsBarreira(Apoio.parseFloat(request.getParameter("peso_"+k)));
                            ct.setPesoReal(Apoio.parseDouble(request.getParameter("pesoReal_"+k)));
                            ct.setVolumeReal(Apoio.parseDouble(request.getParameter("volumeReal_"+k)));
                            ct.setGeraPinSuframa(request.getParameter("isPin_"+k) != null);
                            ct.setNovoRegistro(Apoio.parseBoolean(request.getParameter("novoRegistro_"+k)));
//                            arrayCtrcs[k] = ct;                            
                            manif.getListaBeanConhecimento().add(ct);
                        }
                    }
//                    manif.setCtrc(arrayCtrcs);
                    //Preenchendo o array dos tripulantes
                    String tripulantes = request.getParameter("tripulantes");
                    int qtdTrip = tripulantes.split("!!").length;
                    BeanCadMotorista[] arrayTrip = new BeanCadMotorista[qtdTrip];
                    BeanCadMotorista m = null;
                    for (int k = 0; k < qtdTrip; k++) {
                        if (!tripulantes.split("!!")[k].equals("")) {
                            m = new BeanCadMotorista();
                            m.setIdmotorista(Integer.parseInt(tripulantes.split("!!")[k]));
                            arrayTrip[k] = m;
                        }
                    }
                    manif.setTripulante(arrayTrip);
                    //Apenas para ação incluir
                    if (acao.equals("incluir")) {
                        manif.setDtlancamento(Apoio.paraDate(Apoio.getDataAtual()));
                        manif.setUsuariolancamento(autenticado);
                    }//Apenas para ação atualizar
                    else if (acao.equals("atualizar")) {
                        manif.setDtalteracao(Apoio.paraDate(Apoio.getDataAtual()));
                        manif.setUsuarioalteracao(autenticado);
                        manif.setIdmanifesto(Integer.parseInt(request.getParameter("id")));
                    }
                    //idParadas_    local_ tipo_  maxParadas
                    int maxParadas = Apoio.parseInt(request.getParameter("maxParadas"));
                    ManifestoParada parada = null;
                    for(int i=1; i<=maxParadas; i++){
                        parada = new ManifestoParada();
                        parada.setId(Apoio.parseInt(request.getParameter("idParadas_"+i)));
                        parada.getCidade().setIdcidade(Apoio.parseInt(request.getParameter("idCidadeParadas_"+i)));
                        parada.setLocal(request.getParameter("local_"+i));
                        parada.setTipo(Apoio.parseInt(request.getParameter("tipo_"+i)));
                        if (parada.getCidade().getIdcidade() != 0) {
                            manif.getParadas().add(parada);
                        }else{
                            erroAntesSalvar = true;
                            msgErroAntesSalvar = "O campo \"cidade\" da aba Gerenciador de Risco não pode ficar em branco.";
                        }
                    }
                    ManifestoEscolta escolta = null;
                    escolta = new ManifestoEscolta();
                    escolta.setId(Apoio.parseInt(request.getParameter("idEscolta")));
                    escolta.getFornecedor().setIdfornecedor(Apoio.parseInt(request.getParameter("fornecedorEscolta")));
                    escolta.getVeiculo().setIdveiculo(Apoio.parseInt(request.getParameter("idveiculoEscolta")));
                    escolta.setTelefoneAgente(request.getParameter("telefoneEscolta"));
                    escolta.setNomeAgente(request.getParameter("nomeEscolta"));
                    manif.setEscolta(escolta);
                    //veiculo
//                    manif.getTecnologiaRastreamentoVeiculo().setId(Apoio.parseInt(request.getParameter("tecVeiculo")));
//                    manif.getTipoComunicacaoRastreamentoVeiculo().setId(Apoio.parseInt(request.getParameter("tipoTecVeiculo")));
//                    manif.setNumeroEquipamentoVeiculo(request.getParameter("numEquipVeiculo"));
//                    //carreta
//                    manif.getTecnologiaRastreamentoCarreta().setId(Apoio.parseInt(request.getParameter("tecCarreta")));
//                    manif.getTipoComunicacaoRastreamentoCarreta().setId(Apoio.parseInt(request.getParameter("tipoTecCarreta")));
//                    manif.setNumeroEquipamentoCarreta(request.getParameter("numEquipCarreta"));
//                    //bitrem
//                    manif.getTecnologiaRastreamentoBitrem().setId(Apoio.parseInt(request.getParameter("tecBitrem")));
//                    manif.getTipoComunicacaoRastreamentoBitrem().setId(Apoio.parseInt(request.getParameter("tipoTecBitrem")));
//                    manif.setNumeroEquipamentoBitrem(request.getParameter("numEquipBitrem"));
                    // marcaIsca tipoTecIsca  numeroEquipIsca loginIsca senhaIsca
                    //Isca
                    ManifestoIsca isca = null;
                    isca = new ManifestoIsca();
                    isca.setId(Apoio.parseInt(request.getParameter("idIsca")));
                    isca.setMarca(request.getParameter("marcaIsca"));
                    isca.setTipoComunicacaoRastreador(request.getParameter("tipoTecIsca"));
                    isca.setNumeroEquipamento(request.getParameter("numeroEquipIsca"));
                    isca.setLogin(request.getParameter("loginIsca"));
                    isca.setSenha(request.getParameter("senhaIsca"));
                    manif.setIsca(isca);
                    manif.setProtocoloGoldenService(request.getParameter("protocoloGoldenService"));
                    //Instanciando o BeanCadManifesto
                    cadmanif.setManifesto(manif);
                    cadawb.setAwb(awb);
                    cadmanif.setCadAWB(cadawb);
                    //caso o usuario precise de autorizacao para salvar o manfiesto, vai ser gerado o hash.
                    String cfgPermitirLancamentoOSAbertoVeiculo = request.getParameter("cfgPermitirLancamentoOSAbertoVeiculo");
                    int miliSegundos = Apoio.parseInt(request.getParameter("miliSegundos"));
//                    int cidadeOrigem = Apoio.parseInt(request.getParameter("codigo_ibge_origem"));
//                    int cidadeDestino = Apoio.parseInt(request.getParameter("codigo_ibge_destino"));
                    int idCidadeOrigem = Apoio.parseInt(request.getParameter("cidadeOrigemId"));
                    int idCidadeDestino = Apoio.parseInt(request.getParameter("idcidadedestino"));
                    boolean osAbertoVeiculo = Apoio.parseBoolean(request.getParameter("os_aberto_veiculo"));
                    String hashAutorizacao = "";
                    if (cfgPermitirLancamentoOSAbertoVeiculo.equals("PS") && osAbertoVeiculo && miliSegundos > 0) {
                        hashAutorizacao = Apoio.gerarHash(miliSegundos, manif.getCavalo().getIdveiculo(), idCidadeOrigem, idCidadeDestino);
                    } 
                    //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
                    //3º teste de erro naquela acao executada.
                    String idCTeRemover = request.getParameter("idCTeRemover");
                    boolean erro = false;
                    manif.setIsManifestoPontoControle(Apoio.parseBoolean(request.getParameter("manifestoPontoControle")));
                    manif.setTipoEmitenteMDFe(Apoio.parseInt(request.getParameter("tipoEmitenteMDFe")));
                    manif.setCodigoPgr(Apoio.parseInt(request.getParameter("codigoPgr")));
                    int maxAjudantes = Apoio.parseInt(request.getParameter("qtdAjudantes"));
                    ManifestoAjudante manifestoAjudante = null;
                    for (int i = 1; i <= maxAjudantes; i++) {
                        manifestoAjudante = new ManifestoAjudante();
                        manifestoAjudante.setId(Apoio.parseInt(request.getParameter("idAjudante_" + i)));
                        manifestoAjudante.getAjudante().setIdfornecedor(Apoio.parseInt(request.getParameter("idFornecedor_" + i)));
                        if (manifestoAjudante.getAjudante().getIdfornecedor() == 0) {
                            manifestoAjudante.setNome(request.getParameter("nomeAjudante_" + i));
                            manifestoAjudante.setCpf(request.getParameter("cpfAjudante_" + i));
                        }
                        if ((manifestoAjudante.getCpf() != null && !manifestoAjudante.getCpf().isEmpty())
                            || manifestoAjudante.getAjudante().getIdfornecedor() > 0) {
                            manif.getManifestoAjudantes().add(manifestoAjudante);
                        } else{
                            erroAntesSalvar = true;
                            msgErroAntesSalvar = "O campo \"CPF\" da lista de Ajudantes da aba Gerenciador de Risco não pode ficar em branco.";
                        }
                    }
                    // Tipo de transporte para o Monitora
                    manif.setTipoTransporte(Apoio.parseInt(request.getParameter("tipoTransporte")));
                    manif.setStatusCarga(Apoio.parseInt(request.getParameter("statusCarga")));

                    // SE zero deixar o padrão
                    if (manif.getStatusCarga() == 0) {
                        manif.setStatusCarga(1);//padrão na classe BeanManifesto
                    }

                    if (!erroAntesSalvar) {
                        erro = !((acao.equals("incluir") && nivelUser >= 3)
                                ? cadmanif.Inclui(hashAutorizacao, idCTeRemover) : cadmanif.Atualiza(hashAutorizacao, idCTeRemover));

                        if (Apoio.parseBoolean(request.getParameter("chkProtocoloAverbacao")) && autenticado.getAcesso("lanaverbacaoCTeManual") == NivelAcessoUsuario.CONTROLE_TOTAL.getNivel()) {
                            AverbacaoBO averbacaoBO = new AverbacaoApisulBO300();
                            DocumentoAverbacao documentoAverbacao = new DocumentoAverbacao();
                            documentoAverbacao.setProtocolo(request.getParameter("protocoloAverbacao"));
                            documentoAverbacao.setCodigoErro(null);
                            documentoAverbacao.setDescricaoCompleta("Averbado com Sucesso!");
                            documentoAverbacao.setVersaoAverbacao("300");
                            documentoAverbacao.getMdfe().setId(manif.getIdmanifesto() == 0 ? cadmanif.getManifesto().getIdmanifesto() : manif.getIdmanifesto());
                            documentoAverbacao.getMdfe().setEventoMDFe(EventoMDFe.CONFIRMADO);

                            averbacaoBO.insertProtocoloAverbacao(documentoAverbacao, ModeloDocumentoAverbacao.MDFE);
                        }

                    }else{
                        erro = true;
                        cadmanif.setErros(msgErroAntesSalvar);
                    }
//EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
%><script language="JavaScript" type="text/javascript"><%
                    if (erro) {
                        acao = (acao.equals("atualizar") ? "editar" : "iniciar");
    %>
        if(<%=(cadmanif.getErros().contains("manifesto_autorizacao_liberacao_hash_fkey"))%>){
            alert("ATENÇÃO: A inclusão do veículo não foi liberada e existe OS em aberto para o mesmo. Para utilizá-lo é preciso da autorização do supervisor.");
        }if(<%=(cadmanif.getErros().contains("manifesto_funcionario_manifesto_id_funcionario_id_key"))%>){
            alert("Existem Funcionários Adicionais duplicados!");
        }else if(<%=(cadmanif.getErros().contains("condutores_mdfe_motorista_manifesto_uk"))%>){
            alert("Existem Condutores Adicionais duplicados!");
        }else{
            alert('<%=(cadmanif.getErros().replaceAll("\\r\\n|\\r|\\n", " "))%>');                
        }
        window.opener.habilitaSalvar(true);
    <%
                            manif = cadmanif.getManifesto();
                        } else {
    %>
        if (window.opener != null)
    <%// O parametro 'aosalvar' receberá 0 para salvar e sair ou 1 para salvar e incluir outro
                            String irPara = "ConsultaControlador?codTela=28";
                            String scr = "";
                            scr = "<script>";
                            if (request.getParameter("idmovs") != null) {
                                scr += "window.open('./matricidectrc.ctrc?&idmovs=" + request.getParameter("idmovs") + "&driverImpressora=" + request.getParameter("driverImpressora") + "');";
                            }
                            ;

                            scr += "window.opener.document.location.replace('" + irPara + "');"
                                    + " window.close();"
                                    + "</script>";


                            response.getWriter().append(scr);
                            response.getWriter().close();

                        }%>
                            window.close();
</script>

<%   }
            }
            if (acao.equals("carregarOcorrencia")) {
                String resultado = "";
                mostractrc = new BeanConsultaManifesto();
                mostractrc.setConexao(autenticado.getConexao());
                mostractrc.consultarOcorrencias(Integer.parseInt(request.getParameter("manifestoId")));
                ResultSet rs = mostractrc.getResultado();
                while (rs.next()) {
                    resultado += (resultado.equals("") ? "" : "!!000!!")
                            + rs.getString("id") + "!!999!!"
                            + rs.getString("ocorrencia_ctrc_id") + "!!999!!"
                            + rs.getString("codigo_ocorrencia") + "-" + rs.getString("descricao_ocorrencia") + "!!999!!"
                            + formato.format(rs.getDate("ocorrencia_em")) + "!!999!!"
                            + formatoHora.format(rs.getTime("ocorrencia_as")) + "!!999!!"
                            + rs.getString("usuario_ocorrencia") + "!!999!!"
                            + rs.getString("observacao_ocorrencia") + "!!999!!"
                            + rs.getString("is_resolvido") + "!!999!!"
                            + (rs.getDate("resolucao_em") == null ? "" : formato.format(rs.getDate("ocorrencia_em"))) + "!!999!!"
                            + (rs.getTime("resolucao_as") == null ? "" : formatoHora.format(rs.getTime("ocorrencia_as"))) + "!!999!!"
                            + rs.getString("usuario_resolucao") + "!!999!!"
                            + rs.getString("observacao_resolucao") + "!!999!!"
                            + rs.getString("manifesto_id");

                }
                response.getWriter().append(resultado);
                response.getWriter().close();
            }
            Collection<CTeManifesto> listaCTeManif = null;
            CTeManifesto cte = null;
            if(acao.equals("carregarCTeManifesto")){
                mostractrc = new BeanConsultaManifesto();
//                Collection<CTeManifesto> listaCTeManif = null;
                mostractrc.setConexao(autenticado.getConexao());
                String ctrc = request.getParameter("CTes");
                String tipoConsulta = request.getParameter("tipoConsulta");
                String serie = request.getParameter("serie");
                boolean cteManifestado = Apoio.parseBoolean(request.getParameter("cteManifestado"));
                int idFilialOrigem = Apoio.parseInt(request.getParameter("idFilial"));
                int idFilialDestino = Apoio.parseInt(request.getParameter("idFilial2"));
                boolean isCidadeAtendidas = Apoio.parseBoolean(request.getParameter("isCidadeAtendidas"));
                String tipoDestino = request.getParameter("tipoDestino");
                Connection con = Conexao.getConnection();
                String resultado = "";
                ResultSet rs = null;
                boolean deuCerto = mostractrc.MostraCtrc(ctrc,tipoConsulta, serie, cteManifestado, idFilialOrigem, idFilialDestino, isCidadeAtendidas, tipoDestino,con);
                if(deuCerto){
                    rs = mostractrc.getResultado();
                    listaCTeManif = new ArrayList<CTeManifesto>();
//                    CTeManifesto cte = null;
                    while (rs.next()) {
                        cte = new CTeManifesto();
                        cte.setIdMovimento(rs.getInt("idmovimento"));
                        cte.setDataEmissao(rs.getDate("dtemissao"));
                        cte.setNumeroFiscal(rs.getString("nfiscal"));
                        cte.setSerie(rs.getString("serie"));
                        cte.getRemetente().setRazaosocial(rs.getString("remetente"));
                        cte.getDestinatario().setRazaosocial(rs.getString("destinatario"));
                        cte.setTotalPrestacao(rs.getDouble("totalprestacao"));
                        cte.getMotorista().setIdmotorista(rs.getInt("idmotorista"));
                        cte.getMotorista().setNome(rs.getString("motorista"));
                        cte.getMotorista().setVencimentocnh(rs.getDate("vencimentocnh"));
                        cte.getMotorista().setLiberacao(rs.getString("liberacao_motorista"));
                        cte.getMotorista().setTipo(rs.getString("tipo_motorista"));
                        cte.getMotorista().setVencimento_lib(rs.getDate("validade_lib"));
                        cte.getVeiculo().setIdveiculo(rs.getInt("idveiculo"));
                        cte.getVeiculo().setPlaca(rs.getString("placa_veiculo"));
                        cte.getVeiculo().setOsAbertoVeiculo(rs.getBoolean("os_aberto_veiculo"));
                        cte.getCarreta().setIdveiculo(rs.getInt("idcarreta"));
                        cte.getCarreta().setPlaca(rs.getString("placa_carreta"));
                        cte.getCidadeOrigem().setIdcidade(rs.getInt("idcidadeorigem"));
                        cte.getCidadeOrigem().setDescricaoCidade(rs.getString("cidadeorigem"));
                        cte.getCidadeOrigem().setCidade(rs.getString("cidadeorigem"));
                        cte.getCidadeOrigem().setUf(rs.getString("uforigem"));
                        cte.getCidadeDestino().setIdcidade(rs.getInt("idcidadedestino"));
                        cte.getCidadeDestino().setDescricaoCidade(rs.getString("cidadedestino"));
                        cte.getCidadeDestino().setCidade(rs.getString("cidadedestino"));
                        cte.getCidadeDestino().setUf(rs.getString("ufdestino"));
                        cte.setCteBaixado(rs.getBoolean("ctrc_baixado"));
                        cte.setTotalNFVolume(rs.getDouble("totnf_volume"));
                        cte.setTotalNFPeso(rs.getDouble("totnf_peso"));
                        cte.setTotalNFValor(rs.getDouble("totnf_valor"));
                        cte.getCidadeOrigemCTe().setIdcidade(rs.getInt("idorigem_ctrc"));
                        cte.getCidadeOrigemCTe().setDescricaoCidade(rs.getString("cidade_ori_ctrc"));
                        cte.getCidadeOrigemCTe().setCidade(rs.getString("cidade_ori_ctrc"));
                        cte.getCidadeOrigemCTe().setUf(rs.getString("uf_ori_ctrc"));
                        cte.getCidadeOrigemCTe().setCod_ibge(rs.getString("cod_ibge_origem"));
                        cte.getCidadeDestinoCTe().setIdcidade(rs.getInt("iddestino_ctrc"));
                        cte.getCidadeDestinoCTe().setDescricaoCidade(rs.getString("cidade_dest_ctrc"));
                        cte.getCidadeDestinoCTe().setCidade(rs.getString("cidade_dest_ctrc"));
                        cte.getCidadeDestinoCTe().setUf(rs.getString("uf_dest_ctrc"));
                        cte.getCidadeDestinoCTe().setCod_ibge(rs.getString("cod_ibge_destino"));
                        cte.getMotorista().setTipo(rs.getString("tipo_motorista"));
                        cte.setDistanciaCTe(rs.getInt("distancia_origem_destino"));
                        cte.setIsCidadePermitida(rs.getBoolean("existe_cidade"));
                        cte.getBitrem().setIdveiculo(rs.getInt("idbitrem"));
                        cte.getBitrem().setPlaca(rs.getString("placa_bitrem"));
                        listaCTeManif.add(cte);
                    }
                }
                XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
                xstream.setMode(XStream.NO_REFERENCES);
                xstream.alias("listaCTeManif", listaCTeManif.getClass());
                String json = xstream.toXML(listaCTeManif);
                response.getWriter().append(json);
                response.getWriter().close();
                if(con != null){
                    try {
                        con.close();
                    } catch (SQLException ex) {
                        System.out.println(ex.getMessage());
                    }
                    con = null;
                }
            }
            if(acao.equals("removerCTeManifesto")){
                BeanCadManifesto removerCTe = new BeanCadManifesto();
                String idRemoverCTeManif = request.getParameter("idCTeRemover");
                int idCTeManifesto = Apoio.parseInt(request.getParameter("idCTeManif"));
                boolean removido = removerCTe.removerCTeManifesto(idRemoverCTeManif, idCTeManifesto);
                XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
                xstream.setMode(XStream.NO_REFERENCES);
                xstream.alias("removido", Boolean.class);
                String json = xstream.toXML(removido);
                response.getWriter().append(json);
                response.getWriter().close();
            }
            
            if(acao.equals("getProximoNumeroManifesto")){
                BeanCadManifesto cadManifesto = new BeanCadManifesto();
                cadManifesto.setExecutor(autenticado);
                cadManifesto.setConexao(autenticado.getConexao());
                int idFilial = Apoio.parseInt(request.getParameter("idFilial"));
                int idFilialDestino = Apoio.parseInt(request.getParameter("idFilialDestino"));
                String serieMdfe = request.getParameter("serieMdfe");
                String stUtilizacaoMdfe = request.getParameter("stUtilizacaoMdfe");
                Date dataSaida = Apoio.getFormatData(request.getParameter("dataSaida"));
                cadManifesto.getManifesto().getFilial().setIdfilial(idFilial);
                cadManifesto.getManifesto().getFilialdestino().setIdfilial(idFilialDestino);
                cadManifesto.getManifesto().setSerieMdfe(serieMdfe);
                cadManifesto.getManifesto().getFilial().setStUtilizacaoMDFe(stUtilizacaoMdfe.charAt(0));
                cadManifesto.getManifesto().setDtsaida(dataSaida);
                String numeroManifesto = cadManifesto.getProximoNmanifesto(cfg.getTipoSequenciaManifesto());
                XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
                xstream.setMode(XStream.NO_REFERENCES);
                xstream.alias("numeroManifesto", String.class);
                String json = xstream.toXML(numeroManifesto);
                response.getWriter().append(json);
                response.getWriter().close();
            }
            
            if (acao.equals("calcula")) {
                manif = new BeanManifesto();
                //Recuperando os valores na tela
                if (!acaoanterior.equals("iniciar") && request.getParameter("id") != null) {
                    manif.setIdmanifesto(Integer.parseInt(request.getParameter("id")));
                }
                manif.setIsPreManifesto(Apoio.parseBoolean(request.getParameter("ismanifesto")));
                manif.setNmanifesto(request.getParameter("nmanifesto"));
                manif.setSubCodigo(request.getParameter("subCodigo"));
                manif.setDtsaida(Apoio.paraDate(request.getParameter("dtsaida")));
                manif.setHrsaida(request.getParameter("hrsaida"));
                if (!request.getParameter("idmotorista").equals("")) {
                    manif.getMotorista().setIdmotorista(Integer.parseInt(request.getParameter("idmotorista")));
                }
                manif.getMotorista().setNome(request.getParameter("nomeMotorista"));
                manif.getMotorista().setTipo(request.getParameter("tipo"));
                manif.getMotorista().setVencimentocnh((request.getParameter("motor_vencimentocnh").equals("") ? null : Apoio.paraDate(request.getParameter("motor_vencimentocnh"))));              
                manif.setLibmotorista(request.getParameter("motoristaLiberacao"));
                if (!request.getParameter("idcavalo").equals("")) {
                    manif.getCavalo().setIdveiculo(Integer.parseInt(request.getParameter("idcavalo")));
                }
                manif.getCavalo().setPlaca(request.getParameter("vei_placa"));
                if (!request.getParameter("idcarreta").equals("")) {
                    manif.getCarreta().setIdveiculo(Integer.parseInt(request.getParameter("idcarreta")));
                }
                manif.getCarreta().setPlaca(request.getParameter("car_placa"));
                if (!request.getParameter("idbitrem").equals("")) {
                    manif.getBiTrem().setIdveiculo(Integer.parseInt(request.getParameter("idbitrem")));
                }
                manif.getBiTrem().setPlaca(request.getParameter("bi_placa"));
                if (!request.getParameter("cidadeOrigemId").equals("")) {
                    manif.getCidadeorigem().setIdcidade(Integer.parseInt(request.getParameter("cidadeOrigemId")));
                }
                manif.getCidadeorigem().setCidade(request.getParameter("cidadeOrigem"));
                manif.getCidadeorigem().setUf(request.getParameter("ufOrigem"));
                if (!request.getParameter("idcidadedestino").equals("")) {
                    manif.getCidadedestino().setIdcidade(Integer.parseInt(request.getParameter("idcidadedestino")));
                }
                manif.getCidadedestino().setCidade(request.getParameter("cid_destino"));
                manif.getCidadedestino().setUf(request.getParameter("uf_destino"));
                manif.getFilial().setIdfilial(Integer.parseInt(request.getParameter("idfilial")));
                manif.getFilial().setAbreviatura(request.getParameter("abreviatura"));
                manif.getFilial().getCidade().setUf(request.getParameter("fi_uf_origem"));
                manif.getFilialdestino().setIdfilial(Integer.parseInt(request.getParameter("idfilial2")));
                manif.getFilialdestino().setAbreviatura(request.getParameter("abreviatura2"));
                manif.getFilialdestino().getCidade().setUf(request.getParameter("fi_uf_destino"));
                manif.setObs(Apoio.coalesce(request.getParameter("obs"), ""));
                manif.setConferente(request.getParameter("conferente"));
                manif.setArrumador(request.getParameter("arrumador"));
                manif.setNumeroLacre(request.getParameter("numeroLacre"));
                manif.setAjudante(request.getParameter("ajudante"));
                manif.setDtprevista((request.getParameter("dtprevista").equals("") ? null : Apoio.paraDate(request.getParameter("dtprevista"))));
                manif.setHrprevista(request.getParameter("hrprevista"));
                manif.setTipoDestino(request.getParameter("tipoDestino"));
                manif.getRedespachante().setIdfornecedor(Integer.parseInt(request.getParameter("idredespachante")));
                manif.getRedespachante().setRazaosocial(request.getParameter("redspt_rzs"));
                manif.getAgenteCarga().setIdfornecedor(Integer.parseInt(request.getParameter("idagente_carga")));
                manif.getAgenteCarga().setRazaosocial(request.getParameter("nome_agente_carga"));
                manif.setTipo(request.getParameter("tipo_movimento"));
                manif.getSeguradora().setIdfornecedor(Integer.parseInt(request.getParameter("seguradora")));
                manif.setValorCustoGerenciamento(Apoio.parseDouble(request.getParameter("valorCustoGerenciamento")));
                manif.setCodigoPgr(Apoio.parseInt(request.getParameter("codigoPgr")));
                manif.setStatusManifesto(request.getParameter("statusManifesto"));
                if(request.getParameter("tipo_movimento").equals("a")){
                        //awb = (BeanAWB) manif;
                        awb.setNumeroAWB(request.getParameter("numeroAWB"));
                        awb.setNumero(request.getParameter("numeroCTE"));
                        awb.setNumeroVoo(request.getParameter("numeroVoo"));
                        awb.setValorFrete(Double.parseDouble(request.getParameter("valorFrete")));
                        awb.getCidadeDestino().setIdcidade(Integer.parseInt(request.getParameter("idcidadedestino")));
                        awb.getCidadeOrigem().setIdcidade(Integer.parseInt(request.getParameter("cidadeOrigemId")));
                        awb.getCompanhiaAerea().setIdfornecedor(Integer.parseInt(request.getParameter("idcompanhia")));
                        awb.getCompanhiaAerea().setRazaosocial(request.getParameter("companhia_aerea"));
                        awb.setEmissaoEm(request.getParameter("emissaoEm").equals("")?null:Apoio.paraDate(request.getParameter("emissaoEm")));
                        awb.setEmissaoAs(request.getParameter("emissaoAs"));
                        awb.setPrevisaoEmbarqueEm(request.getParameter("previsaoEmbarqueEm").equals("")?null:Apoio.paraDate(request.getParameter("previsaoEmbarqueEm")));
                        awb.setPrevisaoEmbarqueAs(request.getParameter("previsaoEmbarqueAs"));
                        awb.setPercIcms(Apoio.parseDouble(request.getParameter("valorIcms")));
                        awb.setChaveAcessoAwb(request.getParameter("chaveCTE"));
                        awb.setVolumes(Apoio.parseDouble(request.getParameter("volumesAWB")));
                        awb.setPesoTaxado(Apoio.parseDouble(request.getParameter("pesoAWB")));
                        awb.getCfop().setIdcfop(Apoio.parseInt(request.getParameter("idcfop")));
                        awb.getCfop().setCfop(request.getParameter("cfop"));
                        awb.getAeroportoOrigem().setId(Apoio.parseInt(request.getParameter("aeroportoColetaId")));
                        awb.getAeroportoOrigem().setNome(request.getParameter("aeroportoColeta"));
                        awb.getAeroportoDestino().setId(Apoio.parseInt(request.getParameter("aeroportoEntregaId")));
                        awb.getAeroportoDestino().setNome(request.getParameter("aeroportoEntrega"));
                        // novos campos 16/02/2018.
                        awb.setTipoProdutoOperacaoId(Apoio.parseInt(request.getParameter("tipo_produto_operacao")));   
                        awb.setTipoPagamento(Apoio.parseInt(request.getParameter("tipoPg")));
                        awb.setTipoEntrega(Apoio.parseInt(request.getParameter("tipoRetirada")));
                        awb.setTipoEmbalagemId(Apoio.parseInt(request.getParameter("tipoEmbalagem")));
                        awb.setDescricaoConteudo(request.getParameter("conteudoDes"));
                        //Novos campos 02/04/2018
                        awb.setValorFixo(Apoio.parseDouble(request.getParameter("valorFixo")));
                        awb.setFreteNacional(Apoio.parseDouble(request.getParameter("freteNacional")));
                        awb.setAdvalorem(Apoio.parseDouble(request.getParameter("advalorem")));
                        awb.setTaxaColeta(Apoio.parseDouble(request.getParameter("taxaColeta")));
                        awb.setTaxaEntrega(Apoio.parseDouble(request.getParameter("taxaEntrega")));
                        awb.setTaxaCapatazia(Apoio.parseDouble(request.getParameter("taxaCapatazia")));
                        awb.setTaxaFixa(Apoio.parseDouble(request.getParameter("taxaFixa")));
                        awb.setTaxaDesembaraco(Apoio.parseDouble(request.getParameter("taxaDesembaraco")));
                        tarifaEspecifica = new TarifaEspecificaAero();
                        tarifaEspecifica.setId(Apoio.parseInt(request.getParameter("tarifaEspecifica")));
                        awb.setTarifaEspecifica(tarifaEspecifica);
                    }
                acao = "iniciar";
                if (request.getParameter("acaoanterior").equals("editar")) {
                    manif.getUsuariolancamento().setNome(request.getParameter("usulancamento"));
                    manif.setDtlancamento(Apoio.paraDate(request.getParameter("dtlancamento")));
                    manif.getUsuarioalteracao().setNome(request.getParameter("usualteracao"));
                    manif.setDtalteracao(Apoio.paraDate(request.getParameter("dtalteracao")));
                    acao = "editar";
                }
                String ctes = request.getParameter("ctrcs");
                ctes = ctes.replace("!!", ",");
                if(!ctes.equals("")){
                // Resgatando todos os ctrcs selecionados
                    if (mostractrc.MostraCtrc(ctes,"","",false,0,0,false,"",autenticado.getConexao().getConexao())) {
                        int qtds = ctes.split(",").length;
                        BeanConhecimento[] arrayCt = new BeanConhecimento[qtds];
                        int k = 0;
                        ResultSet rs = mostractrc.getResultado();
                        while (rs.next()) {
                            BeanConhecimento ct = new BeanConhecimento();
                            ct.setId(rs.getInt("idmovimento"));
                            ct.setRedespachoPago(rs.getBoolean("ctrc_baixado"));
                            ct.setEmissaoEm(formato.format(rs.getDate("dtemissao")));
                            ct.setNumero(rs.getString("nfiscal"));
                            ct.getRemetente().setRazaosocial(rs.getString("remetente"));
                            ct.getDestinatario().setRazaosocial(rs.getString("destinatario"));
                            ct.getCidadeOrigem().setDescricaoCidade(rs.getString("cidade_ori_ctrc"));
                            ct.getCidadeDestino().setDescricaoCidade(rs.getString("cidade_dest_ctrc"));
                            ct.getCidadeOrigem().setUf(rs.getString("uf_ori_ctrc"));                            
                            ct.getCidadeDestino().setUf(rs.getString("uf_dest_ctrc"));
                            ct.getCidadeDestino().setIdcidade(rs.getInt("iddestino_ctrc"));
                            if (rs.getInt("idmotorista") != 0) {
                                manif.getMotorista().setIdmotorista(rs.getInt("idmotorista"));
                                manif.getMotorista().setNome(rs.getString("motorista"));
                                manif.getMotorista().setTipo(rs.getString("tipo_motorista"));
                                manif.getMotorista().setVencimentocnh(rs.getDate("vencimentocnh"));
                                manif.setLibmotorista(rs.getString("liberacao_motorista").equals("") ? request.getParameter("motoristaLiberacao") : rs.getString("liberacao_motorista"));
                                manif.getCavalo().setIdveiculo(rs.getInt("idveiculo"));
                                manif.getCavalo().setPlaca(rs.getString("vei_placa"));
                                manif.getCarreta().setIdveiculo(rs.getInt("idcarreta"));
                                manif.getCarreta().setPlaca(rs.getString("placaCarreta"));
                            }
                            manif.getCidadeorigem().setIdcidade(rs.getInt("idorigem_ctrc"));
                            manif.getCidadeorigem().setCidade(rs.getString("cidade_ori_ctrc"));
                            manif.getCidadeorigem().setUf(rs.getString("uf_ori_ctrc"));
                            manif.getCidadedestino().setIdcidade(rs.getInt("iddestino_ctrc"));
                            manif.getCidadedestino().setCidade(rs.getString("cidade_dest_ctrc"));
                            manif.getCidadedestino().setUf(rs.getString("uf_dest_ctrc"));
                            List nfs = new Vector();
                            nfs.add(new NotaFiscal());
                            ((NotaFiscal) nfs.get(0)).setVolume(rs.getFloat("totnf_volume"));
                            ((NotaFiscal) nfs.get(0)).setPeso(rs.getFloat("totnf_peso"));
                            ((NotaFiscal) nfs.get(0)).setValor(rs.getFloat("totnf_valor"));
                            ((NotaFiscal) nfs.get(0)).getConhecimento().setPesoReal(rs.getDouble("totnf_peso"));
                            ((NotaFiscal) nfs.get(0)).getConhecimento().setVolumeReal(rs.getDouble("totnf_volume"));
                            ct.setNotasfiscais(nfs);
                            ct.setValorOutros(rs.getFloat("totalprestacao"));
                            arrayCt[k] = ct;
                            k++;
                        }
                        manif.setCtrc(arrayCt);
                    }
                }
                // Resgatando todos
                String tripulantes = request.getParameter("tripulantes");
                if (tripulantes.trim().length() != 0) {
                    BeanCadMotorista mostratrip = new BeanCadMotorista();
                    mostratrip.setConexao(autenticado.getConexao());
                    ResultSet rs = mostratrip.MostraTripulantes(tripulantes);
                    if (!rs.wasNull()) {
                        int qtds = request.getParameter("tripulantes").split("!!").length;
                        BeanCadMotorista[] arrayTr = new BeanCadMotorista[qtds];
                        int k = 0;
                        while (rs.next()) {
                            mostratrip = new BeanCadMotorista();
                            //BeanConhecimento ct = new BeanConhecimento();
                            mostratrip.setIdmotorista(rs.getInt("idmotorista"));
                            mostratrip.setNome(rs.getString("nome"));
                            mostratrip.getFuncaoTripulante().setDescricao(rs.getString("trip_funcao"));
                            arrayTr[k] = mostratrip;
                            k++;
                        }
                        rs.close();
                        manif.setTripulante(arrayTr);
                    }
                }
%>
<%}
            if (acao.equals("AjaxRemoverAjudante")) {
                // Remover ajudante
                String id = request.getParameter("ajudanteId");
                BeanCadManifesto removerAjudante = new BeanCadManifesto();
                removerAjudante.setConexao(autenticado.getConexao());
                removerAjudante.setExecutor(autenticado);
                Auditoria auditoria = new Auditoria();
                auditoria.setIp(request.getRemoteHost());
                auditoria.setAcao("Excluir um ajudante do manifesto");
                auditoria.setRotina("Alterar Manifesto");
                auditoria.setUsuario(autenticado);
                auditoria.setModulo("Webtrans Manifesto");
                removerAjudante.excluirAjudante(Apoio.parseInt(id), auditoria);
            }
            request.setAttribute("nivelAlterarValoresAWB", Apoio.getAcesso(autenticado, "alterarValorAWB"));
            //Variavel usada para saber se o usuario esta editando
            carregamanif = ((manif != null) && (manif.getFilial() != null) && (!acao.equals("incluir") && !acao.equals("atualizar")) && cadmanif.getErros().isEmpty());
            request.setAttribute("carregamanif", carregamanif);
%>
<script language="JavaScript" type="text/javascript">
//------------------------------------------ feito em 27/04/2010 por Jonas ----------- inico
jQuery.noConflict();
var countCondutoresAdicionais = 0;
var countItensMovimentacao = 0;
var countItensIscas = 0;
//variaveis usada para os totais do ctes
var qtdVolume = 0;
var qtdVolumeReal = 0;
var qtdPeso = 0;
var qtdPesoReal = 0;
var qtdValorNF = 0;
var qtdValorFrete = 0;
 function stAbMN(menu, conteudo) {
    this.menu = menu;
    this.conteudo = conteudo;
    }
    var arAbasMN  = new Array();
   arAbasMN[0] = new stAbMN('tdAbaDadosPrincipais','tdCelDadosPrincipais');
   arAbasMN[1] = new stAbMN('tdAbaOcorrencia','tdCelOcorrencia');
   arAbasMN[2] = new stAbMN('tdAbaPallet','tdCelPallet');
   arAbasMN[3] = new stAbMN('tdAbaGerenciadorRisco','tdCelGerenciadorRisco');
   arAbasMN[4] = new stAbMN('tdAbaAuditoria','tdCelAuditoria');
   arAbasMN[5] = new stAbMN('tbGwMobile','tab3');
    function AlternarAbasManifesto(menu, conteudo) {
         if (arAbasMN != null) {
            for (i = 0; i < arAbasMN.length; i++) {
                if (arAbasMN[i] != null && arAbasMN[i] != undefined) {
                    m = document.getElementById(arAbasMN[i].menu);
                    m.className = 'menu';
                    for (var j = 0, max = arAbasMN[i].conteudo.split(",").length; j < max; j++) {
                        c = document.getElementById(arAbasMN[i].conteudo.split(",")[j]);
                        if (c != null) {
                            invisivel(c, false);
                        } else if ($(arAbasMN[i].conteudo.split(",")[j].replace("div", "tr")) != null) {
                            invisivel($(arAbasMN[i].conteudo.split(",")[j].replace("div", "tr")), false);
                        }
                    }
                }
            }
            m = document.getElementById(menu);
            m.className = 'menu-sel';
            for (var i = 0, max = conteudo.split(",").length; i < max; i++) {
                c = document.getElementById(conteudo.split(",")[i]);
                if (c != null) {
                    visivel(c, false);
                } else if ($(conteudo.split(",")[i].replace("div", "tr")) != null) {
                    visivel($(conteudo.split(",")[i].replace("div", "tr")), false);
                }
            }
        } else {
            alert("Inicialize a variavel arAbasGenerico!");
        }
    }   
function aoCarregar(){
    // $("trMovimentacao").style.display = "none";
    // se não tem permissao para alterar os valores de um AWB
    if ('${nivelAlterarValoresAWB}' !== '4' ) {
        //deixa os campos de valor readonly e com a class readonly;
        jQuery("#valorFixo").attr('readonly', true);
        jQuery("#freteNacional").attr('readonly', true);
        jQuery("#advalorem").attr('readonly', true);
        jQuery("#taxaColeta").attr('readonly', true);
        jQuery("#taxaEntrega").attr('readonly', true);
        jQuery("#taxaCapatazia").attr('readonly', true);
        jQuery("#taxaFixa").attr('readonly', true);
        jQuery("#taxaDesembaraco").attr('readonly', true);
        jQuery("#tarifaEspecifica").attr( "disabled", true );
        jQuery("#valorFixo").addClass('inputReadOnly');
        jQuery("#freteNacional").addClass('inputReadOnly');
        jQuery("#advalorem").addClass('inputReadOnly');
        jQuery("#taxaColeta").addClass('inputReadOnly');
        jQuery("#taxaEntrega").addClass('inputReadOnly');
        jQuery("#taxaCapatazia").addClass('inputReadOnly');
        jQuery("#taxaFixa").addClass('inputReadOnly');
        jQuery("#taxaDesembaraco").addClass('inputReadOnly');
    }
    //Cadastrando o manifesto ele carrega do valor da filial
    <%if(!carregamanif){%>
            if($("is_ativar_valor").value == "t" || $("is_ativar_valor").value == "true" ){
//                if($("valor_max").value.split(".")[1].length < 2){
//                   $("valor_max").value = $("valor_max").value + "0"; 
//                }
                if ($("valorMaximoSeguradora") != null && $("valorMaximoSeguradora") != undefined){
                    $("valorMaximoSeguradora").value = fmtReais($("valor_max").value,2);
                }
            }else{
                if ($("valorMaximoSeguradora") != null && $("valorMaximoSeguradora") != undefined){
                    $("valorMaximoSeguradora").value = fmtReais('000',2);
                }
            }
            if(jQuery('#codigoPgr')[0]) {
                $("codigoPgr").value = "0";
            }
    <%}else{%>
    //Carregando o manifesto ele popula o valor maximo salvo nele
            if($("is_ativar_valor").value == "t" || $("is_ativar_valor").value == "true" ){
                var valorMaximoManifesto = '<%=manif.getValorMaximoManifesto()%>';

                if(valorMaximoManifesto.split(".")[1].length < 2){
                   valorMaximoManifesto = valorMaximoManifesto + "0"; 
                }
                if ($("valorMaximoSeguradora") != null && $("valorMaximoSeguradora") != undefined){
                    $("valorMaximoSeguradora").value = fmtReais(valorMaximoManifesto,2);
                }
            }else{
                if ($("valorMaximoSeguradora") != null && $("valorMaximoSeguradora") != undefined){
                    $("valorMaximoSeguradora").value = fmtReais('000',2);
                }
            }
    <%}  if (carregamanif) {
                    //adicioonando os ajudantes
                    BeanCadMotorista m = null;

                    if (manif.getTripulante() != null) {
                        for (int u = 0; u < manif.getTripulante().length; u++) {
                            m = manif.getTripulante()[u];
                            if (m != null) {
    %>
        addTripulante("<%=m.getIdmotorista()%>",
        "<%=m.getNome()%>",
        "<%=m.getFuncaoTripulante().getDescricao()%>");
        //addTripulante(id, descricao, funcao)

    <%       }
              }
          }
          Iterator iOco = manif.getOcorrencias().iterator();
          Ocorrencia oco = null;
          while (iOco.hasNext()) {
              oco = (Ocorrencia) iOco.next();

    %>
        var ocorrencia = new Ocorrencia('<%=oco.getId()%>','<%=oco.getOcorrenciaManifestoId()%>', '<%=oco.getListaIds()%>','<%=oco.getOcorrencia().getId()%>', '<%=oco.getOcorrencia().getDescricao()%>',
        '<%=formato.format(oco.getOcorrenciaEm())%>', '<%=formatoHora.format(oco.getOcorrenciaAs())%>',
        '<%=oco.getUsuarioOcorrencia().getLogin()%>', '<%=oco.getUsuarioOcorrencia().getIdusuario()%>',
        '<%=oco.getObservacaoOcorrencia()%>', <%=oco.isResolvido()%>, '<%=(oco.getResolucaoEm() == null ? "" : formato.format(oco.getResolucaoEm()))%>',
        '<%=(oco.getResolucaoAs() == null ? "" : formatoHora.format(oco.getResolucaoAs()))%>', '<%=oco.getUsuarioOcorrencia().getLogin()%>',
        '<%=oco.getUsuarioOcorrencia().getIdusuario()%>', '<%=oco.getObservacaoResolucao()%>',<%= oco.getOcorrencia().isObrigaResolucao() %>);
    addOcorrencia(ocorrencia);

    <%
                    }
                
            for(MovimentacaoPallets palle: manif.getItens()){%>
            
                var pallets = new ItemMovimentacao('<%=palle.getId()%>','<%=palle.getData()%>', '<%=palle.getNota()%>','<%=palle.getTipo()%>', '<%=palle.getCliente().getIdcliente()%>',
            '<%=palle.getCliente().getRazaosocial()%>', '<%=palle.getQuantidade()%>', 
            '<%=palle.getPallet().getId()%>', '<%=palle.getPallet().getDescricao()%>');

            addItensMovimentacao(pallets);
        
     <%
     
            }

             for(MovimentacaoIscas isca: manif.getIscas()){%>
                            var iscas = new ItemIsca('<%=isca.getId()%>','<%=Apoio.getFormatData(isca.getDataSaida())%>', '<%=Apoio.getFormatData(isca.getDataChegada())%>','<%=isca.getNumeroIsca()%>');
                            addIscas(iscas);
    <%

            }

            for(CondutoresMDFe condutores : manif.getListaCondutoresMDFe()){%>
                $("trCondutores").style.display = "none";
                var condutores = new condutorAdicional('<%=condutores.getId()%>', '<%=condutores.getIdMotorista()%>', '<%=condutores.getNomeMotorista()%>', 
                '<%=condutores.isIncluido()%>', '<%=condutores.getProtocolo()%>', '<%=condutores.isAverbado()%>', '<%=condutores.getProtocoloAverbacao()%>', '<%=condutores.getDescCompleta()%>');
                
                addCondutoresAdicionais(condutores);
            
            <%
          }
          for(ManifestoParada paradas : manif.getParadas()){%>
          
                var parada =  new Parada('<%=paradas.getId()%>', '<%=paradas.getCidade().getIdcidade()%>', '<%=paradas.getCidade().getDescricaoCidade()%>', 
                '<%=paradas.getCidade().getUf()%>', '<%=paradas.getLocal()%>', '<%=paradas.getTipo()%>');
               
                
                addParadas(parada);
            
             <%
          }
        
                // Ajudantes
                %>
                    if($("statusManifesto").value=='C'){
                        $("tipoEmitenteMDFe").disabled = true;                                    
                    }else{
                        $("tipoEmitenteMDFe").disabled = false;         
                    }
                        
                    var ajudanteTable = $('tbodyAjudantes');
                <%
                    for (ManifestoAjudante ajudante : manif.getManifestoAjudantes()) { %>
                        var ajudante = new Ajudante('<%= ajudante.getId() %>', '<%= ajudante.getNome() %>', '<%= ajudante.getCpf() %>', '<%= ajudante.getAjudante().getIdfornecedor() %>');
                        
                        addAjudante(ajudante, ajudanteTable);
                <%  }

           
                for(ManifestoAjudante conferente : manif.getListaConferentes()){%>
                    var forn = new Fornecedor('<%= conferente.getId() %>', '<%= conferente.getAjudante().getId() %>', '<%= conferente.getAjudante().getRazaosocial() %>', '<%= conferente.getTipo() %>');
                    addFuncionario(forn);
                <%}                 

            }
            
            
    %>
            jQuery("[id^=tipoFuncionario_]").attr('disabled', true);
      // add for nullPoint.
//        foi retirado porque existe uma permissão para validar, 
//        se o usuario tem permissão para poderá alterar o MDF-e cancelados, confirmados e encerrados.  
//        if($("statusManifesto").value == "L"){
//            $("salvar").style.display = "none";
//        }
       
        if(<%=(autenticado.getFilial().getStUtilizacaoBuonnyRoteirizador() != 'N')%>){
                $("lblEnderecoSaidaBuonny").style.display = '';
                $("slcEnderecoSaidaBuonny").style.display = '';
                carregarEnderecoCidadeSaidaBuonny();
            <% if(carregamanif){ %>
                setTimeout(function(){carregarSlcEndCidSaidaBuonny(<%=manif.getFilialEnderecoSaidaBuonny().getId()%>)},100);                 
            <%}%>
        }
        
        <%//carregar os ctes com novo objeto criado cteManifesto.
            if(carregamanif){
                for(CTeManifesto ctes : manif.getListaCTeManifesto()){
        %>
              var cteManif = new CTeManifesto(<%=ctes.getIdMovimento()%>,'<%=ctes.getDataEmissao()%>','<%=ctes.getNumeroFiscal()%>','<%=ctes.getRemetente().getRazaosocial()%>',
              '<%=ctes.getDestinatario().getRazaosocial()%>','<%=ctes.getCidadeOrigem().getDescricaoCidade()%>' + '-' + '<%=ctes.getCidadeOrigem().getUf()%>','<%=ctes.getCidadeDestino().getDescricaoCidade()%>'+ '-' + '<%=ctes.getCidadeDestino().getUf()%>',formatoMoeda(<%=ctes.getTotalNFVolume()%>),
              formatoMoeda(<%=ctes.getVolumeReal()%>),(<%=ctes.getTotalNFPeso()%>),(<%=ctes.getPesoReal()%>),formatoMoeda(<%=ctes.getTotalNFValor()%>),
              formatoMoeda(<%=ctes.getTotalPrestacao()%>),<%=ctes.isGeraPinSuframa()%>,<%=ctes.getIdManifesto()%>,'<%=ctes.getSerie()%>',<%= ctes.isNovoRegistro() %>,<%= ctes.getCidadeDestino().getIdcidade()%>);
              addCTeManifesto(cteManif,$("tbodyCTeManifesto"));
        <%
                }
                %>
                <% if(manif.getTipo().equals("a") && acao.equals("editar")){%>
                     var idCidadesAtendidasAero="";
                     <%for(BeanCidade cid :awb.getAeroportoDestino().getIdsCidadeAtendida()){ %>
                        idCidadesAtendidasAero = idCidadesAtendidasAero +","+  <%=cid.getIdcidade()%>;
                     <%}%>
                    //request.setAttribute("cidadesAtendidasAeroporto", idCidadesAtendidasAero); 
                        $("cidades_atendidas_id").value = idCidadesAtendidasAero.substring(1);
                <%}%>    
                
               calcularQtdTotais();
                calcularVolume();
                calcularVolumeReal();
                calcularPeso();
                calcularPesoReal();
                calcularNotaFiscal();
                calcularFrete(); 
                
           <% }
        %>//fim do carregar cte

        validacaoPIN();
        
    }
    
    function carregarSlcEndCidSaidaBuonny(filialEndSaidaBuonnyId){
        $("slcEnderecoSaidaBuonny").value = filialEndSaidaBuonnyId;
    }

    var idxTrib = 0;
    function addTripulante(id, descricao, funcao){
        idxTrib++;

        var _tr = '';
        _tr = Builder.node('TR', {id:'trTrib_'+idxTrib, name:'trTrib_'+idxTrib, className:'CelulaZebra'+(idxTrib % 2 ? 1 : 2)},
        [Builder.node('TD',
            [Builder.node('IMG', {src:'img/lixo.png', title:'Apagar o tripulante do manifesto.',
                    className:'imagemLink',
                    onClick:'removerTripulante('+idxTrib+');'}),
                Builder.node('INPUT', {type:'hidden', name:'idTrib_'+idxTrib, id:'idTrib_'+idxTrib,
                    value:id})
            ]),
            Builder.node('TD',
            [Builder.node('LABEL', {name:'descricaoTrib_'+idxTrib, id:'descricaoTrib_'+idxTrib}),
            ]),
            Builder.node('TD',
            [Builder.node('LABEL', {name:'funcaoTrib_'+idxTrib, id:'funcaoTrib_'+idxTrib})
            ])
        ]);

        $('corpoTrib').appendChild(_tr);

        //Atribuindo valores nas labels
        $('descricaoTrib_'+idxTrib).innerHTML = descricao;
        $('funcaoTrib_'+idxTrib).innerHTML = funcao;
    }

    function isTripulanteExiste(id,index){
//        isTripulanteExiste($("idtrip").value);
        for(var i = 0;i < index;i++){
            if($("idTrib_"+i) != null && $("idTrib_"+i) != undefined){
                if(id == $("idTrib_"+i).value){
                    setTimeout(function(){alert("Tripulante já adicionado.")},100);
                    Element.remove('trTrib_'+i);
                    return false;
                }
            }    
        }
    }
    
    function removerTripulante(idx){
        if (confirm("Deseja mesmo apagar o tripulante deste manifesto?")){
            Element.remove('trTrib_'+idx);
        }
    }
    
    function getRotaPercurso(){
        function e(transport){
            var textoresposta = transport.responseText;
            
            var acao = '<%=(carregamanif ? "2": "1" ) %>';
            var rota_ant = '${cadContratoFrete.rota.id}';
            //se deu algum erro na requisicao...
            if (textoresposta == "-1"){
                alert('Houve algum problema ao requistar os percursos, favor tente novamente. ');
                return false;
            }else{
               // var obJson = JSON.parse(textoresposta);
                var obJson =jQuery.parseJSON(textoresposta);
                
                var rota = obJson.rota;
                
                var listPercurso = rota.percursos[0].percurso;
                var percurso;
                var slct = $("percurso");
                
                var valor = $("percurso").value;
                var desc = "Percurso";
                
                //Quando a rota for retirada do manifesto tem que ser tirada do banco também.
                //Por isso quando for retirado a rota o percurso também tem que ser retirado 
                //do banco para quando for confirmar o manifesto ele não dar erro.
                if($("rota").value == ""){
                    valor = "";
                }
                
                removeOptionSelected("percurso");
                if(listPercurso== null || listPercurso== undefined){
                    slct.appendChild(Builder.node('OPTION', {value:valor}, desc));
                }else{
                    slct.appendChild(Builder.node('OPTION',{value:''},'Selecione'));
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
                
                slct.selectedIndex = 0;
                
                if(acao == '2'){
                    slct.value = '<%=(carregamanif ? manif.getPercurso().getId() : 0)%>';
                }else{
                    slct.selectedIndex = 0;
                }
            }
        }//funcao e()
        tryRequestToServer(function(){
            new Ajax.Request("cadrota.jsp?acao=carregarRotaPercursoAjax&rota="+$('rota').value,{method:'post', onSuccess: e, onError: e});
        });
    }
    //------------------------------------------ feito em 27/04/2010 por Jonas ----------- fim

    //--------------------------- Ocorrência -------------------------------- inicio
    var idxOco = 1;
    var ctrcAux = '0';
    var zebraAux = '1'

    function Ocorrencia(id, ocorrenciaManifestoId, listaIds, idOcoCtrc ,descricao, ocorrenciaEm, ocorrenciaAs, usuarioOcorrencia,idUsuarioOcorrencia, observacaoOcorrencia, isResolvido, resolvidoEm, resolvidoAs, usuarioResolucao, idUsuarioResolucao,observacaoResolucao,isObrigaResolucao){
        this.id = id;
        this.ocorrenciaManifestoId = ocorrenciaManifestoId;
        this.listaIds = listaIds;
        this.descricao = descricao;
        this.idOcoCtrc = idOcoCtrc;
        this.ocorrenciaEm = ocorrenciaEm;
        this.ocorrenciaAs = ocorrenciaAs;
        this.usuarioOcorrencia = usuarioOcorrencia;
        this.idUsuarioOcorrencia = idUsuarioOcorrencia;
        this.observacaoOcorrencia = observacaoOcorrencia;
        this.isResolvido = isResolvido;
        this.resolvidoEm = resolvidoEm;
        this.resolvidoAs = resolvidoAs;
        this.usuarioResolucao = usuarioResolucao;
        this.idUsuarioResolucao = idUsuarioResolucao;
        this.observacaoResolucao = observacaoResolucao;
        this.isObrigaResolucao = isObrigaResolucao;
    }

    function removerOcorrencia(idx,id){
        var idmanif = $("id").value;
           if(confirm("Deseja excluir esta movimentação ?")){
                    Element.remove('trOco_'+idx);
                    if(confirm("Tem certeza?")){
                    new Ajax.Request("./cadmanifesto?acao=excluir&id="+id+"&idManif="+idmanif,
                {
                    method:'post',
                    onSuccess: function(){ alert('Ocorrencia removida com sucesso!') },
                    onFailure: function(){ alert('Something went wrong...') }
                });     
            }
         }

        }
        var existe = false;
        for (var i = 1; i <= idxOco; i++){
            if($("ocorrenciaId_"+i)!=null){
                existe = true;
            }
        }
        if(!existe){
            if($("trOcorrencia") != undefined && $("trOcorrencia") != null){
                $("trOcorrencia").style.display ="none";                
            }
        }
    

    function resolveuOcorrencia(idx){
        if ($('isResolvido_'+idx).checked){
            $('isResolvido_'+idx).value = true;
            $('usuarioResolucao_'+idx).innerHTML = '<%=autenticado.getLogin()%>';
            $('idUsuarioResolucao_'+idx).value = '<%=autenticado.getIdusuario()%>';
            $('obsResolucao_'+idx).readOnly = false;
            $('resolvidoEm_'+idx).readOnly = false;
            $('resolvidoEm_'+idx).value = '<%=Apoio.getDataAtual()%>';
            $('resolvidoAs_'+idx).readOnly = false;
            $('resolvidoAs_'+idx).value = '<%=new SimpleDateFormat("HH:mm").format(new Date())%>';
        }else{
            $('isResolvido_'+idx).value = false;
            $('usuarioResolucao_'+idx).innerHTML = '';
            $('idUsuarioResolucao_'+idx).value = 0;
            $('obsResolucao_'+idx).readOnly = true;
            $('resolvidoEm_'+idx).readOnly = true;
            $('resolvidoEm_'+idx).value = '';
            $('resolvidoAs_'+idx).readOnly = true;
            $('resolvidoAs_'+idx).value = '';
        }
    }

    function novaOcorrencia(ctrc, zebra){
        ctrcAux = ctrc;
        zebraAux = zebra;
        post_cad = window.open('./localiza?acao=consultar&idlista=40','Ocorrencia_Ctrc',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }

    function addOcorrencia(ocorrencia){

        if($("ocorrenciaId_1")==null){
            $("trOcorrencia").style.display="";
        }
        //criando tr
        var tr_ = Builder.node("tr", {
            id:"trOco_"+idxOco,
            name:"trOco_"+idxOco,
            className:"CelulaZebra"+(idxOco%2==0?1:2)
        });



        // criando td 1
        var td1_ = Builder.node("TD");

        // criando imagem
        var img1_ =  Builder.node("IMG", {src:"img/lixo.png", title:"Apagar ocorrência do CTRC.", className:"imagemLink",onClick:"removerOcorrencia("+idxOco+","+ocorrencia.ocorrenciaManifestoId+");"});
        var inp1_ = Builder.node("INPUT", {type:"hidden", name:"ocorrenciaId_"+idxOco, id:"ocorrenciaId_"+idxOco,
            value:ocorrencia.id});
        var inp54_ = Builder.node("INPUT", {type:"hidden", name:"ocorrenciaIdCtrc_"+idxOco, id:"ocorrenciaIdCtrc_"+idxOco,
            value:ocorrencia.idOcoCtrc});
        var inp55_ = Builder.node("INPUT", {type:"hidden", name:"ocorrenciaManifestoId_"+idxOco, id:"ocorrenciaManifestoId_"+idxOco,
            value:ocorrencia.ocorrenciaManifestoId});
        var inp56_ = Builder.node("INPUT", {type:"hidden", name:"listaIds_"+idxOco, id:"listaIds_"+idxOco,
            value:ocorrencia.listaIds});
        td1_.appendChild(img1_);
        td1_.appendChild(inp1_);
        td1_.appendChild(inp54_);
        td1_.appendChild(inp55_);
        td1_.appendChild(inp56_);
        //criando td 2
        var td2_ = Builder.node("TD");
        var lab1_ = Builder.node("LABEL", {name:"ocorrencia_"+idxOco, id:"ocorrencia_"+idxOco});

        td2_.appendChild(lab1_);

        //criando td 3
        var td3_ = Builder.node("TD");
        var inp3_ ;
        var inp4_ ;
        
        if(ocorrencia.id==0){
            
            inp3_= Builder.node("INPUT", {
                type:"text",
                name:"ocorrenciaEm_"+idxOco,
                id:"ocorrenciaEm_"+idxOco,
                value:ocorrencia.ocorrenciaEm,
                className:"inputtexto",
                size:"10",
                maxLength:"10",
                onBlur:"alertInvalidDate($('ocorrenciaEm_"+idxOco+"'));",
                onKeyDown:"fmtDate($('ocorrenciaEm_"+idxOco+"') , event);",
                onKeyUp:"fmtDate($('ocorrenciaEm_"+idxOco+"') , event);",
                onKeyPress:"fmtDate($('ocorrenciaEm_"+ idxOco+"') , event);"});

            inp4_ = Builder.node("INPUT", {type:"text", name:"ocorrenciaAs_"+idxOco, id:"ocorrenciaAs_"+idxOco,
                value:ocorrencia.ocorrenciaAs, className:"fieldMin", size:"5", maxLength:"5"});

        }else{
            inp3_= Builder.node("INPUT", {
                type:"text", 
                name:"ocorrenciaEm_"+idxOco,
                id:"ocorrenciaEm_"+idxOco,
                value:ocorrencia.ocorrenciaEm,
                className:"fieldMin",
                size:"10",
                maxLength:"10",
                readOnly: true,
                onBlur:"alertInvalidDate($('ocorrenciaEm_"+idxOco+"'));",
                onKeyDown:"fmtDate($('ocorrenciaEm_"+idxOco+"') , event);",
                onKeyUp:"fmtDate($('ocorrenciaEm_"+idxOco+"') , event);",
                onKeyPress:"fmtDate($('ocorrenciaEm_"+ idxOco+"') , event);"});

            inp4_ = Builder.node("INPUT", {type:"text", readOnly:true,name:"ocorrenciaAs_"+idxOco, id:"ocorrenciaAs_"+idxOco,
                value:ocorrencia.ocorrenciaAs, className:"fieldMin", size:"5", maxLength:"5"});
        }
        td3_.appendChild(inp3_);
        td3_.appendChild(inp4_);

        //criando td 4
        var td4_ = Builder.node("TD");
        var lab2_ = Builder.node("LABEL", {name:"usuarioOcorrencia_"+idxOco, id:"usuarioOcorrencia_"+idxOco});
        var inp44_ = Builder.node("INPUT", {type:"hidden", name:"idUsuarioOcorrencia_"+idxOco, id:"idUsuarioOcorrencia_"+idxOco,
            value:ocorrencia.idUsuarioOcorrencia});
        td4_.appendChild(inp44_);
        td4_.appendChild(lab2_);
        //criando td 5
        var td5_ = Builder.node("TD");

        var inp5_;
        if(ocorrencia.id==0){
            inp5_= Builder.node("INPUT", {type:"text", name:"obsOcorrencia_"+idxOco, id:"obsOcorrencia_"+idxOco,
                value:ocorrencia.observacaoOcorrencia, className:"fieldMin", size:"28", maxLength:""});
        }else{
            inp5_= Builder.node("INPUT", {type:"text", readOnly:true,name:"obsOcorrencia_"+idxOco, id:"obsOcorrencia_"+idxOco,
                value:ocorrencia.observacaoOcorrencia, className:"fieldMin", size:"28", maxLength:""});
        }
        td5_.appendChild(inp5_);

        
        //criando td 6
        var inp6_= Builder.node("INPUT", {type:"checkbox", name:"isResolvido_"+idxOco, id:"isResolvido_"+idxOco,
            value:ocorrencia.isResolvido,  onClick:"resolveuOcorrencia("+idxOco+");"});
        //criando td 7
        var td7_ = Builder.node("TD");
        var inp7_ ;
        if(ocorrencia.isResolvido){
            inp7_ = Builder.node("INPUT", {
                type:"text", name:"resolvidoEm_"+idxOco, id:"resolvidoEm_"+idxOco,
                value: ocorrencia.resolvidoEm, className:"fieldMin", size:"12", maxLength:"10",
                onBlur:"alertInvalidDate($('resolvidoEm_"+idxOco+"'),true);",
                onKeyDown:"fmtDate($('resolvidoEm_"+idxOco+"') , event);",
                onKeyUp:"fmtDate($('resolvidoEm_"+idxOco+"') , event);",
                onKeyPress:"fmtDate($('resolvidoEm_"+idxOco+"') , event);"});
        }else{
            inp7_ = Builder.node("INPUT", {
                type:"text", name:"resolvidoEm_"+idxOco, id:"resolvidoEm_"+idxOco,
                value: "", className:"fieldMin", size:"12", maxLength:"10",
                onBlur:"alertInvalidDate($('resolvidoEm_"+idxOco+"'),true);",
                onKeyDown:"fmtDate($('resolvidoEm_"+idxOco+"') , event);",
                onKeyUp:"fmtDate($('resolvidoEm_"+idxOco+"') , event);",
                onKeyPress:"fmtDate($('resolvidoEm_"+idxOco+"') , event);"});

        }
        
        var inp8_;
        if(ocorrencia.isResolvido){
            inp8_= Builder.node("INPUT", {type:"text", name:"resolvidoAs_"+idxOco, id:"resolvidoAs_"+idxOco,
                value:ocorrencia.resolvidoAs, className:"fieldMin", size:"6", maxLength:"5"});
        }else{
            inp8_= Builder.node("INPUT", {type:"text", name:"resolvidoAs_"+idxOco, id:"resolvidoAs_"+idxOco,
                value:"", className:"fieldMin", size:"6", maxLength:"5"});
        }
        if(ocorrencia.isObrigaResolucao == true ){
            td7_.appendChild(inp6_);
            td7_.appendChild(inp7_);
            td7_.appendChild(inp8_);
        }

        //criando td 8
        var td8_ = Builder.node("TD");
            var lab3_ = Builder.node("LABEL", {name:"usuarioResolucao_"+idxOco, id:"usuarioResolucao_"+idxOco});
        var inp34_ = Builder.node("INPUT", {type:"hidden", name:"idUsuarioResolucao_"+idxOco, id:"idUsuarioResolucao_"+idxOco,
            value:ocorrencia.idUsuarioResolucao});
        if(ocorrencia.isObrigaResolucao == true){
            td8_.appendChild(inp34_);
            td8_.appendChild(lab3_);
        }
        //criando td 9
        var td9_ = Builder.node("TD");
        var inp9_;
        if(ocorrencia.isResolvido){
            inp9_= Builder.node("INPUT", {
                type:"text",
                name:"obsResolucao_"+idxOco,
                id:"obsResolucao_"+idxOco,
                value:ocorrencia.observacaoResolucao,
                className:"fieldMin",
                size:"28",
                maxLength:""
            });
	
        }else{
            inp9_= Builder.node("INPUT", {
                type:"text",
                name:"obsResolucao_"+idxOco,
                id:"obsResolucao_"+idxOco,
                value:ocorrencia.observacaoResolucao,
                className:"fieldMin",
                size:"28",
                maxLength:""
            });

        }
        if(ocorrencia.isObrigaResolucao == true){
            td9_.appendChild(inp9_);
        }
        tr_.appendChild(td1_);
        tr_.appendChild(td2_);
        tr_.appendChild(td3_);
        tr_.appendChild(td4_);
        tr_.appendChild(td5_);
        
        tr_.appendChild(td7_);
        tr_.appendChild(td8_);
        
        tr_.appendChild(td9_);

        
        $('tbOcorrencia').appendChild(tr_);
        $('ocorrencia_'+idxOco).innerHTML = ocorrencia.descricao;
        $('usuarioOcorrencia_'+idxOco).innerHTML = ocorrencia.usuarioOcorrencia;
        if(ocorrencia.isObrigaResolucao == true){

        //Atribuindo valores nas labels
        $('usuarioResolucao_'+idxOco).innerHTML = ocorrencia.isResolvido?ocorrencia.usuarioResolucao:"";
        if (ocorrencia.isResolvido){
            $('isResolvido_'+idxOco).checked = true;
            $('obsResolucao_'+idxOco).readOnly = false;
            $('resolvidoEm_'+idxOco).readOnly = false;
            $('resolvidoAs_'+idxOco).readOnly = false;
        }else{
            $('isResolvido_'+idxOco).checked = false;
            $('obsResolucao_'+idxOco).readOnly = true;
            $('resolvidoEm_'+idxOco).readOnly = true;
            $('resolvidoAs_'+idxOco).readOnly = true;
        }

        if (ocorrencia.id != '0'){
            $('obsOcorrencia_'+idxOco).readOnly = true;
            $('obsOcorrencia_'+idxOco).style.backgroundColor = '#FFFFF1';
            $('ocorrenciaEm_'+idxOco).readOnly = true;
            $('ocorrenciaEm_'+idxOco).style.backgroundColor = '#FFFFF1';
            $('ocorrenciaAs_'+idxOco).readOnly = true;
            $('ocorrenciaAs_'+idxOco).style.backgroundColor = '#FFFFF1';
        }
        }
        $("qtdOco").value = idxOco;
        idxOco++;
        

    }

    function check() {
        if (wasNull("idfilial,dtsaida,hrsaida,cidadeOrigemId,idcidadedestino")){
            return false;
        }
        if ($('tipo_movimento').value == 'm'){
            if (!wasNull("nomeMotorista,veiculoPlaca,motoristaLiberacao")){
                return true;
            }else{
                return false;
            }
        }else if ($('tipo_movimento').value == 'a'){
            var dataEmissaoCte = $("emissaoEm").value;
            var anoCTe = dataEmissaoCte.split("/")[2];
            var dataAtual = '<%=Apoio.getDataAtual()%>';
           
            if ($('idcompanhia').value == '0'){
                alert('Informe a companhia aérea corretamente');
                return false;
            }else if($('destinatario_awb').value == 'rd' &&  $('idredespachante').value == '0'){
                alert('Informe o redespachante corretamente');
                return false;
            }else if(anoCTe<2010){
                alert("Data de Emissão do CT-e não pode ser inferior a ano 2010!");
                return false;
            }else if (converterDataUSA(dataEmissaoCte) > converterDataUSA(dataAtual)) {
               alert("Data de Emissão do CT-e não pode ser maior que a data atual!");
               return false;
               
            }else{
                comparaCidCtesCidAeroAtendida();
                console.log("Passou aqui!");
                return true;
            }
        }else{
            if (wasNull("nomeMotorista,veiculoPlaca")){
                return false;
            }else{
                return true;
            }
        }
    }

    function atribuicombos(){
        alteraTipo();
    }

    function manifestaCtrc(){
        if (<%=(cfg.isManifestarCtrcVariasVezes() ? "true" : "false")%>){
            visivel($('lbmostratudo'));
            visivel($('mostratudo'));
        }else {
            invisivel($('lbmostratudo'));
            invisivel($('mostratudo'));
        }
        if ($('mostratudo') != null) {
            $('mostratudo').checked = false;
        }
    }

    function voltar(){
        tryRequestToServer(function(){document.location.replace("ConsultaControlador?codTela=28")});
    }

    function selecionar_rc(qtdLinhas,acao){
        post_cad = window.open('./selecionactrc?acao=iniciar&marcados='+verificaCtrcs(qtdLinhas)+'&acaoDoPai='+acao+'&filial='+$("idfilial").value+'&mostratudo='+(getObj("mostratudo") == null ? false : getObj("mostratudo").checked)+'&dtinicial='+
            incData($('dtsaida').value,-7) + '&dtfinal='+ $('dtsaida').value + '&tipoDestino='+$('tipoDestino').value + '&idfilial2=' + $('idfilial2').value+ '&isFilialCidadesAtendidas='+ $('chk_cidade_atendidas').value+ '&tipo='+ $('tipo_movimento').value,'CtrcManifesto',
        'top=50,left=0,height=600,width=950,resizable=yes,status=1,scrollbars=1');
    }


function localizaCompanhiaAerea(){
    post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.COMPANHIA_AEREA%>','companhia',
    'top=80,left=150,height=400,width=800,resizable=yes,status=1,scrollbars=1');
}

//    function verificaCtrcs(qtdLinhas){
//        var retorno = "";
//        for (i = 0; i <= qtdLinhas - 1; ++i){
//            if (retorno == "")
//                retorno += $("linha-"+i).value;
//            else
//                retorno += ","+$("linha-"+i).value;
//        }
//        return (retorno);
//    }
    function verificaCtrcs(qtdLinhas){
        var retorno = "";
        for (i = 0; i <= qtdLinhas; ++i){
            if($("idCTe_"+i) != null || $("idCTe_"+i) != undefined ){
                if(jQuery("#trCTeManifesto_"+i).is(':visible')){
                    if (retorno == "")
                        retorno += $("idCTe_"+i).value;
                    else
                        retorno += ","+$("idCTe_"+i).value;                    
                }
            }
        }
        return (retorno);
    }

    function concatPesoCtrcs(qtdLinhas){
        var retorno = "";
        for (i = 0; i <= qtdLinhas; ++i){
            if ($("peso_"+i) != null || $("peso_"+i) != undefined) {
                if(jQuery("#trCTeManifesto_"+i).is(':visible')){
                    if (retorno == "")
                        retorno += $("peso_"+i).value;
                    else
                        retorno += ","+$("peso_"+i).value;
                }
            }
        }
        return (retorno);
    }

    function validacaoPIN(){
        var i = 0;
        while ($("peso_"+i) != null){
            if ($('uf_destino').value == 'AM' || $('uf_destino').value == 'RR' || $('uf_destino').value == 'AC'){
                $("isPin_"+i).style.display = "";
                $("divPin").style.display = "";
            }else{
                $("isPin_"+i).style.display = "none";
                $("divPin").style.display = "none";
            }
            i++;
        }    
    }

    function calcula(ctrcs,qtdLinhas,acao){
        var temp = ""
        if ($("cidadeOrigem").value == "" || $("cid_destino").value == "")
            alert("Escolha as cidades de origem e destino corretamente.");
        else
        {
            if (ctrcs == '0'){
                ctrcs = verificaCtrcs(qtdLinhas);
            }
            if (acao == "editar"){
                temp = "&dtlancamento="+$("dtlancamento").value+
                    "&usulancamento="+$("usulancamento").value+
                    "&dtalteracao="+$("dtalteracao").value+
                    "&usualteracao="+$("usualteracao").value+
                    "&id=<%=(carregamanif ? manif.getIdmanifesto() : 0)%>";
            }
            document.location.replace("./cadmanifesto?acao=calcula"+
                "&acaoanterior="+acao+
                "&ctrcs="+ctrcs+
                "&tripulantes="+getTripulantes()+
                "&nmanifesto="+$("nmanifesto").value+
                "&subCodigo="+$("subCodigo").value+
                "&idmotorista="+$("motoristaID").value+
                "&nomeMotorista="+$("nomeMotorista").value+
                "&motor_vencimentocnh="+$("motor_vencimentocnh").value+
                "&obs="+$("obs").value+
                "&motoristaLiberacao="+$("motoristaLiberacao").value+
                "&tipo="+$("tipo").value+
                "&idcavalo="+$("veiculoId").value+
                "&vei_placa="+$("veiculoPlaca").value+
                "&idcarreta="+$("carretaID").value+
                "&car_placa="+$("carretaPlaca").value+
                "&idbitrem="+$("bitremID").value+
                "&bi_placa="+$("bitremPlaca").value+
                "&cidadeOrigemId="+$("cidadeOrigemId").value+
                "&cidadeOrigem="+$("cidadeOrigem").value+
                "&ufOrigem="+$("ufOrigem").value+
                "&idcidadedestino="+$("idcidadedestino").value+
                "&cid_destino="+$("cid_destino").value+
                "&uf_destino="+$("uf_destino").value+
                "&dtsaida="+$("dtsaida").value+
                "&hrsaida="+$("hrsaida").value+
                temp +
                "&abreviatura="+$("fi_abreviatura").value+
                "&idfilial="+$("idfilial").value+
                "&fi_uf_origem="+$("fi_uf_origem").value+
                "&abreviatura2="+$("fi_abreviatura2").value+
                "&idfilial2="+$("idfilial2").value+
                "&fi_uf_destino="+$("fi_uf_destino").value+
                "&conferente="+$("conferente").value+
                "&numeroLacre="+$("numeroLacre").value+
                "&arrumador="+$("arrumador").value+
                "&ajudante="+$("ajudante").value+
                "&dtprevista="+$("dtprevista").value+
                "&hrprevista="+$("hrprevista").value+
                "&tipo_movimento="+$("tipo_movimento").value+
                "&idcompanhia="+$("idcompanhia").value+
                "&companhia_aerea="+$("companhia_aerea").value+
                "&idredespachante="+$("idredespachante").value+
                "&redespachante="+$("redspt_rzs").value+
                "&serieDoc="+$("serieDoc").value+
                "&numeroDoc="+$("numeroDoc").value+
                "&remetente_awb="+$("remetente_awb").value+
                "&destinatario_awb="+$("destinatario_awb").value+
                "&frete_peso="+$("frete_peso").value+
                "&frete_valor="+$("frete_valor").value+
                "&taxa_emergencia="+$("taxa_emergencia").value+
                "&taxa_transportador="+$("taxa_transportador").value+
                "&responsavelRetirada="+$("responsavelRetirada").value+
                "&taxa_entrega="+$("taxa_entrega").value+
                "&seguradora="+$("seguradora").value+
                "&total_prestacao="+$("total_prestacao").value+
                "&base_calculo="+$("base_calculo").value+
                "&aliquota_icms="+$("aliquota_icms").value+
                "&tipoDestino="+$("tipoDestino").value+
                "&redspt_rzs="+$("redspt_rzs").value+
                "&idagente_carga="+$("idagente_carga").value+
                "&nome_agente_carga="+$("nome_agente_carga").value+
                "&perc_icms="+$("perc_icms").value+
                "&emissaoEm="+$("emissaoEm").value+
                "&emissaoAs="+$("emissaoAs").value+
                "&numeroAWB="+$("numeroAWB").value+
                "&numeroCTE="+$("numeroCTE").value+
                "&chaveCTE="+$("chaveCTE").value+
                "&volumesAWB="+$("volumesAWB").value+
                "&pesoAWB="+$("pesoAWB").value+
                "&idcfop="+$("idcfop").value+
                "&cfop="+$("cfop").value+
                "&aeroportoColeta="+$("aeroportoColeta").value+
                "&aeroportoColetaId="+$("aeroportoColetaId").value+
                "&aeroportoEntrega="+$("aeroportoEntrega").value+
                "&aeroportoEntregaId="+$("aeroportoEntregaId").value+
                "&valorCustoGerenciamento="+$("valorCustoGerenciamento").value+
                "&codigoPgr=" + $("codigoPgr").value +
                "&numeroVoo="+$("numeroVoo").value+
                "&valorFrete="+$("valorFrete").value+
                "&previsaoEmbarqueEm="+$("previsaoEmbarqueEm").value+
                "&previsaoEmbarqueAs="+$("previsaoEmbarqueAs").value+
                "&companhia_aerea="+$("companhia_aerea").value+
                "&idcompanhia="+$("idcompanhia").value+
                "&valorIcms="+$("valorIcms").value+
                "&protocoloAverbacao=" + $("protocoloAverbacao").value+
                "&statusManifesto="+$("statusManifesto").value+
                "&slcEnderecoSaidaBuonny="+$("slcEnderecoSaidaBuonny").value+
                "&chk_cidade_atendidas="+$("chk_cidade_atendidas").value+
                "&serieMdfe="+$("serieMdfe").value+
                "&tipo_produto_operacao="+$("tipo_produto_operacao").value+
                "&tipoPg="+$("tipoPg").value+
                "&tipoRetirada="+$("tipoRetirada").value+
                "&tipoEmbalagem="+$("tipoEmbalagem").value+
                "&conteudoDes="+$("conteudoDes").value);
//                "&idCidadeSaidaBuonny="+$("idCidadeSaidaBuonny").value);
              /*  $("formulario").action = "./cadmanifesto?acao="+ acao +
                "&ctrcs="+verificaCtrcs(qtdLinhas)+
                "&tripulantes="+getTripulantes()+temp+
                "&pesos="+concatPesoCtrcs(qtdLinhas);*/
        }

    }

    function habilitaSalvar(opcao){
        $("salvar").disabled = !opcao;
        $("salvar").value = (opcao ? "Salvar" : "Enviando...");
    }

    function getTripulantes(){
        var i = 1;
        var retorno = "";

        for (i  = 1; i <= idxTrib; i++){
            if ($("idTrib_" + i) != null){
                retorno += ($("idTrib_" + i).value + "!!");
            }
        }

        return retorno;
    }
    
   
    function salva(acao,qtdLinhas,pesoTotal){
        var count = 0;
        var valor = calcularNotaFiscal();
        for (var i = 0; i < qtdLinhas; i++) {
            if ($("idCTe_"+i) != "null" || $("idCTe_"+i).value != ""){
                count++;
            }               
        }
        
        if (!validarSelects()) {
            return false;
        }
        if(!validarPrevisaoChegada()){
            return false;
        }
       
        jQuery("[id^=tipoFuncionario_]").removeAttr('disabled');
        
        
        if (count == 0) {
            alert("Informe no mínimo 1 CT-e!");                
        }else
        if ($("motoristaLiberacao").value == "" && $('tipo_movimento') == 'm'){
            alert("O preenchimento do campo 'liberação' do motorista é de preenchimento obrigatório, sem esse número o motorista não poderá seguir viagem. Favor informar.");
            //data de emissão da carteira de Identidade
        }else if (<%=!autenticado.getFilial().isGeraSequenciaCtrcManifesto()%> && $('nmanifesto').value == ''){
            alert ("Informe o número do manifesto corretamente.");
        }else if ( !validaData($("dtsaida"))){
            alert ("Informe a data de saída corretamente. Formato válido: dd/mm/aaaa");
            $("dtsaida").style.background ="#FFE8E8";
        }
        else if ($("idfilial2").value == 0 && $("idredespachante").value == 0){
            alert ("Informe a filial de destino corretamente");
        }
        else if($("tipoDestino").value=="rd" && $("idredespachante").value==0){
            alert("Escolha um redespachante!");
            $("redspt_rzs").style.background ="#FFE8E8";
        }else if(($("is_ativar_valor").value == "true" && ($("valorMaximoSeguradora") != null && $("valorMaximoSeguradora") != undefined ? $("valorMaximoSeguradora").value != "0,00" : "") && ($("valorMaximoSeguradora") != null && $("valorMaximoSeguradora") != undefined ? parseFloat($("valorMaximoSeguradora").value.replace('.','').replace(',','.')) : "") < parseFloat(valor))){
            alert("O valor total do manifesto("+reais(valor,2)+") é maior que o valor limite da filial de origem("+reais($("valorMaximoSeguradora").value,2)+").");
        }else if (check()){
            habilitaSalvar(false);
            if (acao == "atualizar")
                acao += "&id=<%=(carregamanif ? manif.getIdmanifesto() : 0)%>";

            var print = '';

            $("acao").value = '<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>';

//            if($("idfilial2").value != "0" && $("idredespachante").value != "0"){
//               if($("tipoDestino").value == "fl"){
//                  $("idredespachante").value = "0";
//                  $("redspt_rzs").value = "";
//              }else{
//                  $("idfilial2").value = "0";
//                  $("fi_abreviatura2").value = "";
//              }
//            }
            //window.open('', '', 'width=210, height=100');
            /*$("formulario").action = "./cadmanifesto?acao="+ acao + "&" +
                "ctrcs="+verificaCtrcs(qtdLinhas)+
                "&pesos="+concatPesoCtrcs(qtdLinhas)+
                "&pesosReais="+concatPesoRealCtrcs(qtdLinhas)+
                "&nmanifesto="+$("nmanifesto").value+
                "&subCodigo="+$("subCodigo").value+
                "&idmotorista="+$("motoristaID").value+
                "&motor_liberacao="+$("motoristaLiberacao").value+
                "&idcavalo="+$("veiculoId").value+
                "&idcarreta="+$("idcarreta").value+
                "&idbitrem="+$("bitremID").value+
                "&idcidadeorigem="+$("idcidadeorigem").value+
                "&idcidadedestino="+$("idcidadedestino").value+
                "&dtsaida="+$("dtsaida").value+
                "&hrsaida="+$("hrsaida").value+
                "&idfilial="+$("idfilial").value+
                "&idfilial2="+$("idfilial2").value+
                "&conferente="+$("conferente").value+
                "&arrumador="+$("arrumador").value+
                "&ajudante="+$("ajudante").value+
                "&dtprevista="+$("dtprevista").value+
                "&hrprevista="+$("hrprevista").value+
                "&tipo_movimento="+$("tipo_movimento").value+
                "&idcompanhia="+$("idcompanhia").value+
                "&idredespachante="+$("idredespachante").value+
                "&serieDoc="+$("serieDoc").value+
                "&numeroDoc="+$("numeroDoc").value+
                "&remetente_awb="+$("remetente_awb").value+
                "&destinatario_awb="+$("destinatario_awb").value+
                "&frete_peso="+$("frete_peso").value+
                "&frete_valor="+$("frete_valor").value+
                "&taxa_emergencia="+$("taxa_emergencia").value+
                "&taxa_transportador="+$("taxa_transportador").value+
                "&responsavelRetirada="+$("responsavelRetirada").value+
                "&taxa_entrega="+$("taxa_entrega").value+
                "&total_prestacao="+$("total_prestacao").value+
                "&base_calculo="+$("base_calculo").value+
                "&aliquota_icms="+$("aliquota_icms").value+
                "&tripulantes="+getTripulantes()+
                "&seguradora="+$("seguradora").value+
                "&idagente_carga="+$("idagente_carga").value+
                "&perc_icms="+$("perc_icms").value+
                "&protocoloAverbacao" + $("protocoloAverbacao").value;*/
                //$("formulario").action = "./cadmanifesto?acao="+ acao
                jQuery("#tarifaEspecifica").removeAttr('disabled');
                var separadorManifesto;
               // var arrayCte = verificaCtrcs($("qtdLinhasCTe").value).split(",");
                $("motoristaLiberacao").disabled = false;
                window.open('about:blank', 'pop', 'width=210, height=100');
               // while (arrayCte.length > 0) {
                 //   separadorManifesto = arrayCte.splice(0,200); //separando o CTE em blocos de 200 (Evita erro 400 - Bad Request)
                $("ctrcs").value = verificaCtrcs($("qtdLinhasCTe").value);
                $("formulario").action = "./cadmanifesto?acao="+ acao +"&motoristaLiberacao="+$("motoristaLiberacao").value+
                "&tripulantes="+getTripulantes()+
                "&pesos="+concatPesoCtrcs($("qtdLinhasCTe").value)+
                "&tipoDestino="+$("tipoDestino").value;
                $("tipoEmitenteMDFe").disabled =false;
            $("formulario").submit();
           //     }
           jQuery("#tarifaEspecifica").attr('disabled', true);
           jQuery("[id^=tipoFuncionario_]").attr('disabled', true);
            $("tipoEmitenteMDFe").disabled =true;


        }else
            alert("Preencha os campos corretamente!");
     }
     
    function localizarCidadeSaidaBuonny(){
        post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CIDADE_ORIGEM%>','cidade_saida_buonny',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }

    function localizafilial(){
        post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FILIAL%>','filial_origem',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }

    function localizafilial2(){
        post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FILIAL_DESTINO%>','filial_destino',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }

    function localizacid_origem(){
        post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CIDADE_ORIGEM%>','origem',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }

    function localizacid_destino(){
        post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CIDADE_DESTINO%>','destino',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }

    function localizacavalo(){
        post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.VEICULO%>','cavalo',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }

    function localizacarreta(){
        post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CARRETA%>','carreta',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }

    function localizabitrem(){
        post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.BITREM%>','BiTrem',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }
    
    function localizatritrem(){
        post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.TRI_TREM%>','3º_Reboque',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }

    function localizamotorista(){
        post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.MOTORISTA%>','motorista',
        'top=80,left=150,height=400,width=800,resizable=yes,status=1,scrollbars=1');
    }

    function localizaAgente(){
        post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.AGENTE_CARGA%>','agente_carga',
        'top=80,left=150,height=400,width=800,resizable=yes,status=1,scrollbars=1');
    }

    function localizacompanhia(){
        post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.COMPANHIA_AEREA%>','companhia',
        'top=80,left=150,height=400,width=800,resizable=yes,status=1,scrollbars=1');
    }

    function localizaredespachante(){
        post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REDESPACHANTE%>','redespachante',
        'top=80,left=150,height=400,width=800,resizable=yes,status=1,scrollbars=1');
    }

    function excluirmanifesto(idmanifesto){
        if (confirm("Deseja mesmo excluir este manifesto?")){
            location.replace("./consultamanifesto?acao=excluir&id="+idmanifesto);
        }
    }
    
    
    function localizaCidadeParadas(index){
        post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CIDADE_ORIGEM%>','Cidades_'+index,
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }
    
     function localizaVeiculoEscolta(){
        post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.VEICULO%>','Veiculo_Escolta',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }

    function aoClicarNoLocaliza(idjanela){
        var index1 = $("idPallet").value;
        var index2 = $("idCliente").value;
        var index3 = $("idCondutor").value;
        
        if (idjanela == "Cliente") {
            $("idcliente_"+ index2).value  = $("idconsignatario").value;
            $("cliente_"+ index2).value  = $("con_rzs").value;
        }
        
        if (idjanela == "filial_origem") {
            $("fi_uf_origem").value  = $("fi_uf").value;
            $("stUtilizacaoMdfe").value = $("st_utilizacao_mdfe").value;
            $("serieMdfe").value = $("serie_mdfe").value;
//            if($("valor_max").value.split(".")[1].length < 2){
//               $("valor_max").value = $("valor_max").value + "0"; 
//            }
            if ($("valorMaximoSeguradora") != null && $("valorMaximoSeguradora") != undefined){
                $("valorMaximoSeguradora").value = fmtReais($("valor_max").value,2);
            }
        }

        if (idjanela == "filial_destino") {
            $("fi_uf_destino").value  = $("fi_uf").value;
            $("chk_cidade_atendidas").value  = $("is_ativa_cidade").value;
            validacaoPIN();
            setCidadeDestino();
        }
        
        if (idjanela == "Pallet") {
            $("idpallet_"+ index1).value  = $("id").value;
            $("pallet_"+ index1).value  = $("descricao").value;
        }
        if(idjanela == "Condutor"){
            $("idMotorista_"+ index3).value = $("idmotorista").value;
            $("nomeMotorista_"+ index3).value = $("motor_nome").value;
         
            
        }

        if(idjanela.split("_")[0] == "Cidades"){
            // idCidadeParadas         cidadeParadas             ufParadas        
            //idcidadeorigem  cid_origem uf_origem
            var index = idjanela.split("_")[1];
            $("idCidadeParadas_"+index).value = $("idcidadeorigem").value;
            $("cidade_"+index).value = $("cid_origem").value;
            $("uf_"+index).value = $("uf_origem").value;
            
        }
        
        var index = $("indexAux").value;
           // console.log("motor_liberacao: "+ $("motor_liberacao").value);
        if (idjanela == "motorista"){
            $("nomeMotorista").value = $("motor_nome").value;
            $("motoristaID").value = $("idmotorista").value;
            var bloqueado = validarBloqueioVeiculoMotorista("veiculo_motorista,carreta_motorista,bitrem_motorista,tritrem_motorista");
            if(!bloqueado){
                $("veiculoPlaca").value = $("vei_placa").value;
                $("veiculoId").value = $("idveiculo").value;
                    $("idveiculoRastreamento").value = $("veiculoId").value;
                        try{
                var tecVeiculo = $("tecnologia_rastreamento_veiculo").value;
                var tipoTecVeiculo = $("tipo_comunicacao_rastreamento_veiculo").value;
                var placa = $("vei_placa").value;
                var numEquiVeic = $("numero_equipamento_veiculo").value;

                    $('veiculoRastreamento').innerHTML = (placa == null ? "" : placa);
                $('tecVeiculo').innerHTML = (tecVeiculo == null ? "" : tecVeiculo);
                $('tipoTecVeiculo').innerHTML = (tipoTecVeiculo == null ? "" : tipoTecVeiculo );
                $('numEquipVeiculo').innerHTML = (numEquiVeic == null ? "" : numEquiVeic );
                        }catch(e){
                            alert("veiculo: "+e);
                        }

                $("carretaPlaca").value = $("car_placa").value;
                $("carretaID").value = $("idcarreta").value;
                $("idcarretaRastreamento").value = $("carretaID").value;
                
                $("bitremID").value = $("idbitrem").value;
                $("bitremPlaca").value = $("bi_placa").value;
                
                $("tritremPlaca").value = $("tri_placa").value;
                $("tritremID").value = $("idtritrem").value;
                
                   try{
                var placaCarreta = $("carretaPlaca").value;
                var tecCarreta = $("tecnologia_rastreamento_carreta").value;
                var tipoTecCarreta = $("tipo_comunicacao_rastreamento_carreta").value;
                var numEquiCarreta = $("numero_equipamento_carreta").value;

                $('carretaRastreamento').innerHTML = (placaCarreta == null ? "" : placaCarreta);
                $('tecCarreta').innerHTML = (tecCarreta == null ? "" : tecCarreta);
                $('tipoTecCarreta').innerHTML = (tipoTecCarreta == null ? "" : tipoTecCarreta);
                $('numEquipCarreta').innerHTML = (numEquiCarreta == null ? "" : numEquiCarreta);

                }catch(e){
                    alert("carreta: "+e);
                }


                $("motoristaLiberacao").value = $("motor_liberacao").value;
                    if ($("tipo").value == "c"){
                        $("motoristaLiberacao").disabled = false;
                    }else{
                        $("motoristaLiberacao").disabled = true;
                    }
                    abrirLoginSupervisor('<%=cfg.getPermitirLancamantoOSAbertoVeiculo()%>',<%=TipoAutorizacao.MANIFESTO_VEICULO_MANUTECAO.ordinal()%>,$("cidadeOrigemId").value,$("idcidadedestino").value);
            }
        }
        
        if(idjanela == "carreta"){
           var bloqueado = validarBloqueioVeiculo("carreta");
           if (!bloqueado) {
    
            $("carretaID").value = $("idcarreta").value;
            $("carretaPlaca").value = $("car_placa").value;

            $("idcarretaRastreamento").value = $("carretaID").value;
                  
            
            var placaCarreta = $("carretaPlaca").value;
            var tecCarreta = $("tecnologia_rastreamento_carreta").value;
            var tipoTecCarreta = $("tipo_comunicacao_rastreamento_carreta").value;
            var numEquiCarreta = $("numero_equipamento_carreta").value;
            
            $('carretaRastreamento').innerHTML = (placaCarreta == null ? " " : placaCarreta);
            $('tecCarreta').innerHTML = (tecCarreta == null ? " " : tecCarreta);
            $('tipoTecCarreta').innerHTML = (tipoTecCarreta == null ? " " : tipoTecCarreta );
            $('numEquipCarreta').innerHTML = (numEquiCarreta == null ? " " : numEquiCarreta);
            }
            
        
        }
        
        if(idjanela == "BiTrem"){
             var bloqueado = validarBloqueioVeiculo("bitrem");
           if (!bloqueado) {
            $("bitremID").value = $("idbitrem").value;
            $("bitremPlaca").value = $("bi_placa").value;
            
            $("idbitremRastreamento").value = $("bitremID").value;
            var placaBitrem = $("bitremPlaca").value;
            var tecBitrem = $("tecnologia_rastreamento_bitrem").value;
            var tipoTecBitrem = $("tipo_comunicacao_rastreamento_bitrem").value;
            var numEquiBitrem = $("numero_equipamento_bitrem").value;
            $('bitremRastreamento').innerHTML = (placaBitrem == null ? " " : placaBitrem);
            $('tecBitrem').innerHTML = (tecBitrem == null ? " " : tecBitrem) ;
            $('tipoTecBitrem').innerHTML = (tipoTecBitrem == null ? " " : tipoTecBitrem);
            $('numEquipBitrem').innerHTML = (numEquiBitrem == null ?  " " : numEquiBitrem);
        
            }
        }
            if(idjanela == "3º_Reboque"){
                var bloqueado = validarBloqueioVeiculo("tritrem");
                if (!bloqueado) {
                $("tritremID").value = $("idtritrem").value;
                $("tritremPlaca").value = $("tri_placa").value;
            }
        }
            if(idjanela == "redespachante"){
                setCidadeDestino();
            }
        function indiceJanela(initPos, finalPos) { return idjanela.substring(initPos, finalPos); }
        //localizando ajudante
        if (idjanela.indexOf("motorista") > -1){
            if($("bloqueado").value == 't' || $("motivobloqueio").value != ""){//juntei 2 if para não aparecer 2 alerts, caso de erro ver a validação que existia abaixo
                alert('Esse motorista está bloqueado. Motivo: ' + $("motivobloqueio").value);
                $("nomeMotorista").value = '';
                $("motor_vencimentocnh").value = '';
                $("motoristaLiberacao").value = '';
                $("motoristaID").value = '';
            }
        }else if (idjanela.indexOf("Tripulante") > -1){
            if ($("bloqueado").value == 't'){
                alert('Esse tripulante está bloqueado. Motivo: ' + $("motivobloqueio").value);
                $("trip_nome").value = '';
                //$("trip_vencimentocnh").value = '';
                $("idtrip").value = '';
                $("trip_funcao").value = '';
            }else{
                var id = $("idtrip").value;
                var descricao = $("trip_nome").value;
                var funcao = $("trip_funcao").value;
                addTripulante(id, descricao, funcao);
            }
        }else if (idjanela == "Observacao"){
            var obs = "" + $("obs_desc").value;
            obs = replaceAll(obs, "<BR>"," ");
            obs = replaceAll(obs, "<br>"," ");
            obs = replaceAll(obs, "</br>"," ");
            obs = replaceAll(obs, "</BR>"," ");
            $("obs").value = obs;
        }


        if(idjanela == "Ocorrencia_Ctrc"){
            var ocorrencia = new Ocorrencia(0,0,'',//
            $("ocorrencia_id").value, //2
            $("ocorrencia").value+" - "+$("descricao_ocorrencia").value,//3
            '<%=Apoio.getDataAtual()%>',//4
            '<%=new SimpleDateFormat("HH:mm").format(new Date())%>',//5
            '<%=autenticado.getLogin()%>',//6
            '<%=autenticado.getIdusuario()%>',//7
            '',//8
            false,//9
            '',//10
            '',//11
            '',//12
            0,//13
            '',//14
            $("obriga_resolucao").value);//15

            addOcorrencia(ocorrencia);
        }
        
        if(idjanela == "Aeroporto_Coleta"){
            $("aeroportoColeta").value = $("aeroporto").value
            $("aeroportoColetaId").value = $("aeroporto_id").value
        }
        
        if(idjanela == "Aeroporto_Entrega"){
            $("aeroportoEntrega").value = $("aeroporto").value
            $("aeroportoEntregaId").value = $("aeroporto_id").value
        }
        
        if (idjanela == "origem") {
            $("cidadeOrigem").value = $("cid_origem").value;
            $("ufOrigem").value = $("uf_origem").value;
            $("cidadeOrigemId").value = $("idcidadeorigem").value;
            var stUtilizaBuonnyRoteirizador = '<%=(autenticado.getFilial().getStUtilizacaoBuonnyRoteirizador() != 'N')%>';            
            if(stUtilizaBuonnyRoteirizador == "true"){
                carregarEnderecoCidadeSaidaBuonny();                
            }
            
            if(<%=carregamanif%>){
//               var codigoIbgeOrigem = '< %=(manif != null ? manif.getCidadeorigem().getCod_ibge() : 0)%>';
//               validacaoAlterarLoginSupervisor(codigoIbgeOrigem,$("codigo_ibge_origem").value);
               var idCidadeOrigem = '<%=(manif != null ? manif.getCidadeorigem().getIdcidade() : 0)%>';
               validacaoAlterarLoginSupervisor(idCidadeOrigem,$("cidadeOrigemId").value);
            }
        }
        
        if (idjanela == "destino") {
        
            if(<%=carregamanif%>){
               var idCidadeDestino = '<%=(manif != null ? manif.getCidadedestino().getIdcidade() : 0)%>';
               validacaoAlterarLoginSupervisor(idCidadeDestino,$("idcidadedestino").value);
            }
    
        }
        
//        if (idjanela == "cidade_saida_buonny") {
//            $("cidadeSaidaBuonny").value = $("cid_origem").value;
//            $("ufSaidaBuonny").value = $("uf_origem").value;
//            $("idCidadeSaidaBuonny").value = $("idcidadeorigem").value;
//            carregarEnderecoCidadeSaidaBuonny();
//        }

        if (idjanela == "Veiculo_Escolta") {
            $("veiculoEscolta").value = $("vei_placa").value;
            $("idveiculoEscolta").value = $("idveiculo").value;
        }
        
        
        if (idjanela == "cavalo") {
        var bloqueado = validarBloqueioVeiculo("veiculo");
            if (!bloqueado) {

                $("veiculoPlaca").value = $("vei_placa").value;
                $("veiculoId").value = $("idveiculo").value;
                    abrirLoginSupervisor('<%=cfg.getPermitirLancamantoOSAbertoVeiculo()%>',<%=TipoAutorizacao.MANIFESTO_VEICULO_MANUTECAO.ordinal()%>,$("cidadeOrigemId").value,$("idcidadedestino").value);

                var placa = $("veiculoPlaca").value;
                var tecVeiculo = $("tecnologia_rastreamento_veiculo").value;
                var tipoTecVeiculo = $("tipo_comunicacao_rastreamento_veiculo").value;
                var placa = $("veiculoPlaca").value;
                var numEquiVeic = $("numero_equipamento_veiculo").value;
                $("idveiculoRastreamento").value = $("veiculoId").value;
                //$("veiculoRastreamento").value = $("veiculoPlaca").value;
                $('veiculoRastreamento').innerHTML = (placa == null ? "" : placa);
                $('tecVeiculo').innerHTML = (tecVeiculo == null ? "" : tecVeiculo);
                $('tipoTecVeiculo').innerHTML = (tipoTecVeiculo == null ? "" : tipoTecVeiculo);
                $('numEquipVeiculo').innerHTML = (numEquiVeic == null ? "" : numEquiVeic);

            }
        }
        
        if(idjanela == "selecionaCTe"){
            $("idveiculo").value = $("veiculoId").value; // Definindo novamente o valor do veiculo(cavalo) na variável que é chamaada pela validação de supervisor
            abrirLoginSupervisor('<%=cfg.getPermitirLancamantoOSAbertoVeiculo()%>',<%=TipoAutorizacao.MANIFESTO_VEICULO_MANUTECAO.ordinal()%>,$("cidadeOrigemId").value,$("idcidadedestino").value);                
        }else if (idjanela == "Conferente") {
            $("conferente").value = $("nome_funcionario").value;
            $("conferenteId").value = $("id_funcionario").value;
        }else if (idjanela == "Arrumador") {
            $("arrumador").value = $("nome_funcionario").value;
            $("arrumadorId").value = $("id_funcionario").value;
        }else if (idjanela == "Ajudante") {
            var indexFunc = $("index_funcionario").value;
            $("idFuncionario_" + indexFunc).value = $("idajudante").value;
            $("nomeFuncionario_" + indexFunc).value = $("nome").value;
            $("tipoFuncionario_"+indexFunc).disabled = "true";
        }
        
        validacaoPIN();
        
//       if (idjanela == "Ajudante") {
//            addAjudante(new Ajudante(0, $("nome").value, '', $("idajudante").value), $('tbodyAjudantes'));
//       }
        
        if (idjanela === 'Funcionario') {
            var indexFunc = $("index_funcionario").value;
            $("idFuncionario_" + indexFunc).value = $("id_funcionario").value;
            $("nomeFuncionario_" + indexFunc).value = $("nome_funcionario").value;
            $("tipoFuncionario_"+indexFunc).disabled = "true";
        } else if (idjanela === 'Fornecedor') {
            var indexFunc = $("index_funcionario").value;
            $("idFuncionario_" + indexFunc).value = $("idfornecedor").value;
            $("nomeFuncionario_" + indexFunc).value = $("fornecedor").value;
            $("tipoFuncionario_"+indexFunc).disabled = "true";
    }
    }
    
    function validacaoAlterarLoginSupervisor(idCidadeCarregado, idCidadeLocaliza){
        if (idCidadeCarregado != idCidadeLocaliza) {
            abrirLoginSupervisor('<%=cfg.getPermitirLancamantoOSAbertoVeiculo()%>',<%=TipoAutorizacao.MANIFESTO_VEICULO_MANUTECAO.ordinal()%>,$("cidadeOrigemId").value,$("idcidadedestino").value);
        }
    }

    function limpaAeroportoEntrega(){
        $("aeroportoEntrega").value = "";
        $("aeroportoEntregaId").value = "0";
    }

    function limpaAeroportoColeta(){
        $("aeroportoColeta").value = "";
        $("aeroportoColetaId").value = "0";
    }

    function verVeiculo(tipo){
        var mostrar = false;
        var idVeiculo = 0;
        if (tipo == 'V' && $('veiculoId').value != '0'){
            idVeiculo = $('veiculoId').value;
            mostrar = true;
        }else if (tipo == 'C' && $('carretaID').value != '0'){
            idVeiculo = $('carretaID').value;
            mostrar = true;
        }else if (tipo == 'S' && $('idveiculoEscolta').value != '0' && $('idveiculoEscolta').value != ''){//adicionado a validacao do campo vazio
            idVeiculo = $('idveiculoEscolta').value;
            mostrar = true;
        }else if (tipo == 'T' && $('tritremID').value != '0'){
            idVeiculo = $('tritremID').value;
            mostrar = true;
        }else if (tipo == 'B' && $("bitremID").value != '0'){
            idVeiculo = $('bitremID').value;
            mostrar = true;
        }

        if (mostrar){//colocando chave no IF
            window.open('./cadveiculo?acao=editar&id=' + idVeiculo ,'Veículo','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
        }
    }

    function verMotorista(){
        var mostrar = false;
        var idMotorista = 0;
        if ($('motoristaID').value != '0'){
            idMotorista = $('motoristaID').value;
            mostrar = true;
        }
        if (mostrar)
            window.open('./cadmotorista?acao=editar&id=' + idMotorista ,'Motorista','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
    }

    function verCompanhia(){
        var mostrar = false;
        var idCompanhia = 0;
        if ($('idcompanhia').value != '0'){
            idCompanhia = $('idcompanhia').value;
            mostrar = true;
        }

        if (mostrar)
            window.open('./cadfornecedor?acao=editar&id=' + idCompanhia ,'Fornecedor','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
    }

    function verCtrc(id){
        window.open("./frameset_conhecimento?acao=editar&id="+id+"&ex=false", "Conhecimento" , "top=0,resizable=yes");
    }

    function alteraTipo(){
        
        $('tr_companhia').style.display = "none";
        $('tr_valorAWB').style.display = "none";
        $('tr_motorista').style.display = "";
        $('tr_lbmotorista').style.display = "";
        $('trTrip1').style.display = "none";
        $('trTrip2').style.display = "none";
        
        $('TDLabelLiberacaoMotorista').style.display = "none";
        $('motoristaLiberacao').style.display = "none";
   
        if ($('tipo_movimento').value == 'm'){
            $('tr_motorista').style.display = "";
            $('tr_lbmotorista').style.display = "";
            $('tit_a').innerHTML = "Relação do(s) CT-e(s) Deste Manifesto";
            visivel($('lbmostratudo'));
            visivel($('mostratudo'));
            if ($('selecionarctrc') != null) {
                $('selecionarctrc').value = "Selecionar CT-e(s)";
            }
            $('lbMotorista').innerHTML = "Motorista:";
            $('lbVeiculo').innerHTML = "Veículo:";
            $('lbCarreta').style.display = "";
            $('carretaPlaca').style.display = "";
            $('localiza_carreta').style.display = "";
            $('imgCarreta').style.display = "";
            $('borrachaCarreta').style.display = "";
            $('lbBiTrem').style.display = "";
            $('lbBi').style.display = "";
            $('lbTriTrem').style.display = "";
            $('lbTri').style.display = "";
            
            $('TDLabelLiberacaoMotorista').style.display = "";
            $('motoristaLiberacao').style.display = "";
        }else if ($('tipo_movimento').value == 'a'){
            $('tit_a').innerHTML = "Relação do(s) CT-e(s) Deste Manifesto";
            visivel($('lbmostratudo'));
            visivel($('mostratudo'));
            if ($('selecionarctrc') != null) {
                $('selecionarctrc').value = "Selecionar CT-e(s)";
            }
            $('tr_companhia').style.display = "";
            $('tr_valorAWB').style.display = "";
            
            $('TDLabelLiberacaoMotorista').style.display = "none";
            $('motoristaLiberacao').style.display = "none";
        }else{
            $('tit_a').innerHTML = "Relação do(s) CT-e(s) Deste Manifesto";
            visivel($('lbmostratudo'));
            visivel($('mostratudo'));
            if ($('selecionarctrc') != null) {
                $('selecionarctrc').value = "Selecionar CT-e(s)";
            }
            $('tr_companhia').style.display = "none";
            $('tr_valorAWB').style.display = "none";
            $('tr_motorista').style.display = "";
            $('tr_lbmotorista').style.display = "";
            $('lbMotorista').innerHTML = "Comandante:";
            $('lbVeiculo').innerHTML = "Embarcação:";
            $('lbCarreta').style.display = "none";
            $('carretaPlaca').style.display = "none";
            $('localiza_carreta').style.display = "none";
            $('imgCarreta').style.display = "none";
            $('borrachaCarreta').style.display = "none";
            $('trTrip1').style.display = "";
            $('trTrip2').style.display = "";
            $('lbBiTrem').style.display = "none";
            $('lbBi').style.display = "none";
            $('lbTriTrem').style.display = "none";
            $('lbTri').style.display = "none";
            
            $('TDLabelLiberacaoMotorista').style.display = "";
            $('motoristaLiberacao').style.display = "";
        }
    }
    
    function abrirLocalizarCliente(index){
         $("idCliente").value = index
         launchPopupLocate('./localiza?acao=consultar&idlista=5&fecharJanela=true','Cliente')
    }
    
    function abrirLocalizarPallet(index){
         $("idPallet").value = index;
         launchPopupLocate('./localiza?acao=consultar&idlista=66&fecharJanela=true','Pallet')
    }
    
    function abrirLocalizarMotorista(index){
        $("idCondutor").value = index;
        launchPopupLocate('./localiza?acao=consultar&idlista=10&fecharJanela=true','Condutor')
    }
    
    function limparCliente (id){
        $("idcliente_"+ id).value = 0;
        $("cliente_"+ id).value = "";
    }
    
    function limparPallet (id){
        $("idpallet_"+ id).value = 0;
        $("pallet_"+ id).value = "";
    }
    
    function excluirFilho(id, index){
         var idmanif = $("id").value;
            if(confirm("Deseja excluir esta movimentação ?")){
                if(confirm("Tem certeza?")){
                    //AJAX chama o controlador de MovimentacaoPallets pois manifesto não contém controlador no webtrans
                            new Ajax.Request("MovimentacaoPalletsControlador?acao=excluir2&id="+id+"&idManif="+idmanif+"&modulo=Webtrans",
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
            this.data = (data != undefined ? data : $("dtsaida").value);
            this.nota = (nota != undefined && nota!= null ? nota : "");
            this.tipo = (tipo != undefined ? tipo : "d");
            this.idCliente = (idCliente != undefined && idCliente != null ? idCliente : 0);
            this.cliente = (cliente != undefined && cliente!= null ? cliente : "");
            this.quantidade = (quantidade != undefined && quantidade != null ? quantidade : "");
            this.idPallet = (idPallet != undefined && idPallet!= null ? idPallet : 0);
            this.pallet = (pallet != undefined ? pallet : "");
    }       
    
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
                    onClick:"excluirFilho("+ itensMovimentacao.id + "," + countItensMovimentacao +");"
                               
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
                
                // 
                var text1 = Builder.node ("input", {
                    id : "cliente_" + countItensMovimentacao ,
                    name : "cliente_" + countItensMovimentacao ,
                    className:"fieldMin",
                    type  : "text" ,
                    size  : "30",
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
                    value : itensMovimentacao.nota
               
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
                
                slcTipo.appendChild(_optD);
                slcTipo.appendChild(_optC);
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
                
                //
                var text5 = Builder.node ("input", {
                    id : "pallet_" + countItensMovimentacao ,
                    name : "pallet_" + countItensMovimentacao ,
                    className:"fieldMin",
                    type  : "text" ,
                    size  : "20",
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
                    
             
             //   td1.appendChild(inp1);
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
        
        function calcularicms(){
            var valor = $("valorIcms").value;
            var frete = parseFloat($("valorFrete").value);
            frete = roundABNT(((frete/100)*valor),2);
            $("valorTotalIcms").value = frete;
        }
        
        function calcularPesoReal(){
            try{ 
                var qtdCtrc = $("qtdLinhasCTe").value;
                var pesoRealTotal = 0;
                for(var i = 0; i < qtdCtrc; i++){
                    if(jQuery("#trCTeManifesto_"+i).is(':visible')){
                        pesoRealTotal = parseFloat(pesoRealTotal) + parseFloat($("pesoReal_"+i).value);                        
                    }
                }
                $("totalPesoReal").innerHTML = colocarPonto(colocarVirgula(pesoRealTotal,3));
             }catch(e){
                alert(e);    
            }
        }
        
        function calcularVolumeReal(){
            try{ 
               var qtdCtrc = $("qtdLinhasCTe").value;
               var pesoVolumeTotal = 0;
               
               for(var i = 0;i<qtdCtrc; i++){
                   if(jQuery("#trCTeManifesto_"+i).is(':visible')){
                       pesoVolumeTotal = parseFloat(pesoVolumeTotal) + parseFloat($("volumeReal_"+i).value);                       
                   }
               }
               
               $("totalVolumeReal").innerHTML = formatoMoeda(pesoVolumeTotal);
               
            }catch(e){
               alert(e);    
            }
        }
        
        function calcularVolume(){
            try{ 
               var qtdCtrc = $("qtdLinhasCTe").value;
               var volumeTotal = 0;
               
               for(var i = 0;i<qtdCtrc; i++){
                   if(jQuery("#trCTeManifesto_"+i).is(':visible')){
                       volumeTotal = parseFloat(volumeTotal) + parseFloat($("volume_"+i).innerHTML);                       
                   }
               }
               
               $("quantidade").innerHTML = formatoMoeda(volumeTotal);
               
            }catch(e){
               alert(e);    
            }
        }
        
        function calcularPeso(){
            try{ 
               var qtdCtrc = $("qtdLinhasCTe").value;
               var pesoTotal = 0;
               
               for(var i = 0;i<qtdCtrc; i++){
                   if(jQuery("#trCTeManifesto_"+i).is(':visible')){
                       pesoTotal = parseFloat(pesoTotal) + parseFloat($("pesoLbl_"+i).innerHTML);                       
                   }
               }
               
               $("peso").innerHTML = colocarPonto(colocarVirgula(pesoTotal,3));
               
            }catch(e){
               alert(e);    
            }
        }
        
        function calcularNotaFiscal(){
            try{ 
               var qtdCtrc = $("qtdLinhasCTe").value;
               var notaFiscalTotal = 0;
               
               for(var i = 0;i<qtdCtrc; i++){
                   if(jQuery("#trCTeManifesto_"+i).is(':visible')){
                       notaFiscalTotal = parseFloat(notaFiscalTotal) + parseFloat($("notaFiscalLbl_"+i).innerHTML);                       
                   }
               }
               
               $("total_notas").innerHTML = formatoMoeda(notaFiscalTotal);
               return formatoMoeda(notaFiscalTotal);
               
            }catch(e){
               alert(e);    
            }
        }
        
        function calcularFrete(){
            try{ 
               var qtdCtrc = $("qtdLinhasCTe").value;
               var freteTotal = 0;
               
               for(var i = 0;i<qtdCtrc; i++){
                   if(jQuery("#trCTeManifesto_"+i).is(':visible')){
                       freteTotal = parseFloat(freteTotal) + parseFloat($("frete_"+i).innerHTML);                       
                   }
               }
               
               $("frete").innerHTML = formatoMoeda(freteTotal);
               
            }catch(e){
               alert(e);    
            }
        }
        
        function calcularQtdTotais(){
            var qtdLinhaCTe = 0;
            var qtdLinha = $("qtdLinhasCTe").value;
            for(var qtd = 0; qtd < qtdLinha; qtd++){
                if($("trCTeManifesto_"+qtd) != null){
                    qtdLinhaCTe++;
                    $("quantidade_linha").innerHTML = qtdLinhaCTe;                    
                }
//                if(jQuery("#trCTeManifesto_"+qtd).is(':visible')){
//                    qtdLinhaCTe++;
//                    $("quantidade_linha").innerHTML = qtdLinhaCTe;                    
//                }
            }
        }
        
        function localizacfop(){
            post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CFOP%>','Cfop',
            'top=80,left=150,height=400,width=600,resizable=yes,status=1,scrollbars=1');
        }
//        var numCtrcs= "";
        
//        function showNumCtrcs(){
//            var ctrc = $("numeroConsulta").value;
//                if(numCtrcs == undefined){
//                    numCtrcs = ctrc;
//                }else{
//                    numCtrcs += ", \n"+ctrc;                
//                }
//                alert("CTRC(s) selecionado(s): \n"+numCtrcs);
//        }
        
//        function pesquisarCtrcManifesto(acao){
//            var chaveAcesso = $('chaveacesso').value;
//            var serie = $('serieConsulta').value;
//            var numero = $('numeroConsulta').value;
//            var idfilial = $("idfilial").value;
//            if(chaveAcesso=='' && numero==''){
//                return alert("Preencha a chave ou número do CTRC!")
//            }
//                     
//            function e(transport){
//                var resp = transport.responseText;
//                if (resp == 'null'){
//                    alert('Erro ao localizar Ctrc/Coleta.');
//                    return false;
//                }else { 
//                    calcula(resp,0,acao);
//                }
//            }
//
//            tryRequestToServer(function(){
//                
//                new Ajax.Request("./cadmanifesto?acao=localizaCtrcAjax&chaveAcesso="+chaveAcesso+"&serie="+serie+"&numero=" +numCtrcs+"&idfilial="+idfilial,{method:'post', onSuccess: e, onError: e});
//            });
//           
//        }
        
        function carregarEnderecoCidadeSaidaBuonny(){
            var cidadeOrigemId = $("cidadeOrigemId").value;
            var idFilial = $("idfilial").value;
            jQuery.ajax({
                    url: '<c:url value="/ManifestoBuonnyControlador" />',
                    dataType: "text",
                    method: "post",
                    data: {
                        idCidadeSaidaBuonny : cidadeOrigemId,
                        idFilial : idFilial,                        
                        acao : "carregarEnderecoCidadeSaidaBuonny"
                    },
                    success: function(data) {
                        
                        var listaEndereco = JSON.parse(data).endereco[0].entry;
                       
                        var length = (listaEndereco != undefined && listaEndereco.length != undefined ? listaEndereco.length : 1);
                        $("slcEnderecoSaidaBuonny").update("");                       
                        if(length > 1){
                            
                            for(var end = 0; end < length; end++){
                                var int = JSON.parse(data).endereco[0].entry[end].int;    
                                var string = JSON.parse(data).endereco[0].entry[end].string;    
                                montarSlcEndereco(int,string);                                
                            }
                            
                        }else{
                            if (listaEndereco != undefined) {
                                var int = JSON.parse(data).endereco[0].entry.int;
                                var string = JSON.parse(data).endereco[0].entry.string;
                                montarSlcEndereco(int,string);    
                            }else{
//                                $("divEnderecoSaidaBuonny").style.display = 'none';
                                $("lblEnderecoSaidaBuonny").style.display = 'none';
                                $("slcEnderecoSaidaBuonny").style.display = 'none';
                                if($("cidadeOrigem").value != ''){
                                    alert("Atenção: Não existem Endereços de Saídas para o Roteirizador Buonny \n Cidade : " + $("cidadeOrigem").value + "!");                                    
                                }
                            }
                        }
                        
                    }
                });
        }
        
        function montarSlcEndereco(int, string){
//            $("divEnderecoSaidaBuonny").style.display = '';
            $("lblEnderecoSaidaBuonny").style.display = '';
            $("slcEnderecoSaidaBuonny").style.display = '';
            var enderecoSaida = $("slcEnderecoSaidaBuonny");
                
                var optionEndereco = Builder.node("option", {
                            value: int
                });
                
                Element.update(optionEndereco, string);
                enderecoSaida.appendChild(optionEndereco);
        }
         
        
                
        function calcularValoresCtrcManifesto(){
            calcularQtdTotais();
            calcularVolume();
            calcularVolumeReal();
            calcularPeso();
            calcularPesoReal();
            calcularNotaFiscal();
            calcularFrete();
            
            if ($("tipo").value == "c"){
                $("motoristaLiberacao").disabled = false;
            }else{
                $("motoristaLiberacao").disabled = true;
            }
            
        }
        
        
        function alteraTipoConsulta(valorCombo){
            if (valorCombo == "CTRC") {
                $("lblChaveAcesso").style.display = "none";
                $("lblInpChaveAcesso").style.display = "none";
                $("lblSerieNumero").style.display = "";
                $("lblInpSerieNumero").style.display = "";
                $("lblInpNumeroConsulta").style.display = "";
                $("lblNumeroLocalizador").style.display = "none";
                $("lblInpNumeroLocalizador").style.display = "none";
                retorno = "0";
            }else if(valorCombo == "CHAVE_CTE"){
                $("lblChaveAcesso").style.display = "";
                $("lblInpChaveAcesso").style.display = "";
                $("lblSerieNumero").style.display = "none";
                $("lblInpSerieNumero").style.display = "none";
                $("lblInpNumeroConsulta").style.display = "none";
                $("lblNumeroLocalizador").style.display = "none";
                $("lblInpNumeroLocalizador").style.display = "none";
                retorno = "0";
            }else if(valorCombo == "N_LOCALIZADOR"){
                $("lblChaveAcesso").style.display = "none";
                $("lblInpChaveAcesso").style.display = "none";
                $("lblSerieNumero").style.display = "none";
                $("lblInpSerieNumero").style.display = "none";
                $("lblInpNumeroConsulta").style.display = "none";
                $("lblNumeroLocalizador").style.display = "";
                $("lblInpNumeroLocalizador").style.display = "";
                retorno = "0";
            }

        }
        
        
        function incluirCTeManifestoAjax(CTes, idCampo, acao){
            var nomeCampo = idCampo.id;
            var numeroConsulta = idCampo.value;
            var idFilial = $("idfilial").value;
            if (CTes == "") {
                alert("Atenção: Para efetuar a consulta informe o número ou clique em 'Selecionar CT-e(s)'.");
                return false;
            }
            
            jQuery.ajax({
                url: '<c:url value="./cadmanifesto" />',
                dataType: "text",
                method: "post",
                data: {
                    numeroConsulta: numeroConsulta,
                    nomeCampo: nomeCampo,
                    CTes: CTes,
                    idFilial : idFilial,
                    acao : "localizarCTeManifesto"
                },
                success: function(data) {
                    var resp = JSON.parse(data).resultado;
                    if (resp == ''){ 
                        if (idCampo.id == "numeroConsulta") {
                            alert('Atenção: Não foi encontrado nenhum CT-e com Série/Número : ' + idCampo.value + '!');    
                        }else if(idCampo.id == "chaveAcesso"){
                            alert('Atenção: Não foi encontrado nenhum CT-e com a Chave Acesso : ' + idCampo.value + '!');                                
                        }
                        return false;
                    }else { 
                        calcula(resp,0,acao);
                    }


                }
            });
        }
        
        function adicionarCTeManifesto(){
        
            if ($("chaveAcesso").value == "" && $("numeroConsulta").value == "" && $("numeroLocalizador").value == "") {
                alert("Atenção: Para efetuar a consulta informe o número ou clique em 'Selecionar CT-e(s)'.");
                return false;
            }else if ($("numeroConsulta").value != "") {
                    var numeroCTe = $("numeroConsulta").value;
                    var serie = $("serieConsulta").value;
                    $("numeroConsulta").value = "";
                    carregarCTeManifestoAjax(numeroCTe,"numeroCTe",serie);
            }else if($("chaveAcesso").value){
                    var chaveAcesso = $("chaveAcesso").value;                
                    $("chaveAcesso").value = "";
                    carregarCTeManifestoAjax(chaveAcesso,"chaveAcesso","");
            } else if ($('numeroLocalizador').value !== '') {
                var numeroLocalizador = $('numeroLocalizador').value;
                $('numeroLocalizador').value = '';
                carregarCTeManifestoAjax(numeroLocalizador, "numeroLocalizador", "");
            }
            
        }
        
        function toUpperCase(serie){
            $("serieConsulta").value = serie.toUpperCase();
        }
        
        function carregarCTeManifestoAjax(cteSelecionados,tipoConsulta, serie){
            //console.log("carregarCTeManifestoAjax: "+cteSelecionados+ " tipocon: "+tipoConsulta);
            var cteAdd = "0";
            var cteNAdd = "0";
            var cteRemover = "0";
            var cteNRemover = "0";
            var count = 0;
            var idCTeManif = "0";
            
            //if para verificar de onde estou fazendo a pesquisa, se for localiza, numero do cte ou chaveAcesso
            //nesse caso só vai precisar entrar no if se for pesquisado localiza
            if (tipoConsulta == "localiza") {
                
                //for para percorrer todos os ctes que foram adiconados, comparando com os que serão adiconado
                //pego o id do cte que é para ser removido do DOM e pego o que não precisa ser removido.
                for (var qtd = 0; qtd < $("qtdLinhasCTe").value; qtd++) {
                    if($("idCTeManif_"+qtd) != null){
                        if($("idCTeManif_"+qtd).value != 0){
                            idCTeManif = $("idCTeManif_"+qtd).value;
                        }                        
                    }
                    
                count = 0;
                    for (var slc = 0; slc < cteSelecionados.split(",").length; slc++) {
                        //console.log("for:");
                    if($("idCTe_"+qtd) != null){
                            if($("idCTe_"+qtd).value == cteSelecionados.split(",")[slc]){
                                count++;
                            }
                            //verifico os ctes que foram adicionados antes nesse mesmo cte, aí coloco ele visivel novamente, não precisa mais pesquisar-lo.
                        if(!jQuery("#trCTeManifesto_"+qtd).is(':visible') && $("idCTe_"+qtd).value == cteSelecionados.split(",")[slc]){
                            jQuery("#trCTeManifesto_"+qtd).show();
                        }
                    }
                    }
//                    if($("idCTe_"+qtd) != null){
//                        if (count == 0) {
//                            cteRemover += "," + $("idCTe_"+qtd).value;
//                            $("idCTeRemover").value += "," + $("idCTe_"+qtd).value;
//                        }else{
//                            cteNRemover += "," + $("idCTe_"+qtd).value;
//                        }                        
//                    }
                }
                //console.log("saiu for:");
                //for para percorrer os ctes que está sendo adicionado com o que estão no DOM
                //pego o id do cte para adicionar e pego o id do cte para não adicionar.
                for (var slc = 0; slc < cteSelecionados.split(",").length; slc++) {            
                    count = 0;
                    for (var qtd = 0; qtd < $("qtdLinhasCTe").value; qtd++) {
                        if($("idCTe_"+qtd) != null){
                            if(cteSelecionados.split(",")[slc] == $("idCTe_"+qtd).value){
                                count++;
                            }                    
                        }
                    }
                    if ($("qtdLinhasCTe").value > 0) {
                        if (count == 0) {
                            cteAdd += "," + cteSelecionados.split(",")[slc];
                        }else{
                            cteNAdd += "," + cteSelecionados.split(",")[slc];                            
                        }  
                    }
                }
                
                //if para adicionar os ctes no DOM
                if(cteAdd != "0"){
                    cteSelecionados = "0," + cteAdd.replace("0,","");
                }else if(cteNAdd.replace("0,","") == cteSelecionados){
                    cteSelecionados = "0," + cteAdd.replace("0,","");
                }
            
                //if para remover os ctes do DOM
//                if (cteRemover != "0") {
//                    
//
//                    var idCTeRemover = "0," + cteRemover.replace("0,","");
//                    if (idCTeManif != "0") {
//                        removerCTeManifesto(idCTeRemover);    
//                    }else{
//                        removerCTeManifesto(idCTeRemover);                            
//                    }
//                }
                
            //quando a consulta for feito pela tela principal de manifesto.
            }else if(tipoConsulta == "numeroCTe"){
                //for para percorrer todos os ctes que foram adiconados no DOM, comparando com o novo que vai ser adicionado.
                //comparação feita com o número do cte e a serie.
                var validacao = validacaoCTeManifesto(cteSelecionados, $("serieConsulta").value);
                if(validacao == "false" || validacao == false){
                    return false;
                }
            }
            
            if ($("tipo").value == "c"){
                $("motoristaLiberacao").disabled = false;
            }else{
                $("motoristaLiberacao").disabled = true;
            }
            
            var cteManifestado = ($("mostratudo") == null ? false : $("mostratudo").checked);
            
            var idFilial = $("idfilial").value;
            var idFilial2 = $("idfilial2").value;
            var isCidadeAtendidas = $("chk_cidade_atendidas").value;
            var tipoDestino = $("tipoDestino").value;
            if (cteSelecionados != "0,0") {
    
                //por fim vou fazer a pesquisa via ajax para adicionar os ctes no DOM.
                jQuery.ajax({
                    url: '<c:url value="./cadmanifesto" />',
                    dataType: "text",
                    method: "post",
                    async:false,
                    data: {
                        tipoDestino : tipoDestino,
                        isCidadeAtendidas : isCidadeAtendidas,
                        CTes: cteSelecionados,
                        tipoConsulta: tipoConsulta,
                        serie: serie,
                        cteManifestado: cteManifestado,
                        idFilial : idFilial,
                        idFilial2 : idFilial2,
                        acao : "carregarCTeManifesto"
                    },
                    success: function(data) {
                        //limpado array de cidades destino dos cte(s).
                        listaIdsCidadeDestino=[];

                        var list = JSON.parse(data).list[0];
                        if(list == ""){
                            alert("CT-e não encontrado!");
                            return false;
                        }
                        
                        
                        if (list != "") {

                            var listCTeManifesto;
                           // console.log(list);
                            if(list["conhecimento.manifesto.CTeManifesto"]){
                                listCTeManifesto = list["conhecimento.manifesto.CTeManifesto"];
                            }else{
                                listCTeManifesto = list[Object.keys(list)[0]];
                            }
                            var length = (listCTeManifesto != undefined && listCTeManifesto.length != undefined ? listCTeManifesto.length : 1)

                            if (length > 1) {    
                                for (var i = 0; i < length; i++) {
                                   var cte = listCTeManifesto[i];

                                   if(tipoConsulta == "chaveAcesso"){
                                       var validacao = validacaoCTeManifesto(cte.numeroFiscal, cte.serie);
                                       if(validacao == "false" || validacao == false){
                                           return false;
                                       }

                                   }
                                   
                                   if(isCidadeAtendidas == "true" && tipoDestino == "fl" && cte.isCidadePermitida == false){
                                       alert("Cidade do cte não faz parte das cidades atendidas pela filial");
                                       return false;
                                   }

                                   var dataEmissao = formatDateJSON(cte.dataEmissao);
                                   var vencimentoCNH = formatDateJSON(cte.motorista.vencimentocnh);
                                   //console.log("cte.motorista.idmotorista "+cte.motorista.idmotorista);
                                   var cteManif = new CTeManifesto(cte.idMovimento, dataEmissao, cte.numeroFiscal, cte.remetente.razaosocial, cte.destinatario.razaosocial, 
                                   cte.cidadeOrigemCTe.cidade + "-" + cte.cidadeOrigemCTe.uf, cte.cidadeDestinoCTe.cidade + "-" + cte.cidadeDestinoCTe.uf, formatoMoeda(cte.totalNFVolume), formatoMoeda(cte.totalNFVolume), 
                                   (cte.totalNFPeso), (cte.totalNFPeso), formatoMoeda(cte.totalNFValor), formatoMoeda(cte.totalPrestacao), false, 0, cte.serie,true,cte.cidadeDestinoCTe.idcidade );
                                   addCTeManifesto(cteManif,$("tbodyCTeManifesto"));
                                    if($("is_ativar_valor").value == "t" || $("is_ativar_valor").value == "true" ){
//                                        if($("valor_max").value.split(".")[1].length < 2){
//                                            $("valor_max").value = $("valor_max").value + "0"; 
//                                        }
                                        if ($("valorMaximoSeguradora") != null && $("valorMaximoSeguradora") != undefined){
                                            $("valorMaximoSeguradora").value = fmtReais($("valor_max").value,2);
                                        }
                                    }

                                   carregarDadosCTeManifesto(
                                           cte.motorista.idmotorista,
                                           cte.motorista.nome,
                                           cte.motorista.liberacao,
                                           vencimentoCNH,
                                           cte.cidadeOrigemCTe.idcidade,
                                           cte.cidadeOrigemCTe.cidade,
                                           cte.cidadeOrigemCTe.uf,
                                           cte.cidadeDestinoCTe.idcidade,
                                           cte.cidadeDestinoCTe.cidade,
                                           cte.cidadeDestinoCTe.uf,
                                           cte.veiculo.idveiculo,
                                           cte.veiculo.placa,cte.veiculo.osAbertoVeiculo,
                                           cte.carreta.idveiculo,
                                           cte.carreta.placa,cte.motorista.tipo,
                                           cte.distanciaCTe,
                                           cte.bitrem.idveiculo,
                                           cte.bitrem.placa
                                           ); 

                                   validacaoPIN();
                                }
                            }else{
                                var dataEmissao = formatDateJSON(listCTeManifesto.dataEmissao);
                                var vencimentoCNH = formatDateJSON(listCTeManifesto.motorista.vencimentocnh);

                                if(tipoConsulta == "chaveAcesso"){
                                   var validacao = validacaoCTeManifesto(listCTeManifesto.numeroFiscal, listCTeManifesto.serie);
                                   if(validacao == "false" || validacao == false){
                                       return false;
                                   }
                                }

                                if(isCidadeAtendidas == "true" && tipoDestino == "fl" && listCTeManifesto.isCidadePermitida == false){
                                    alert("Cidade do cte não faz parte das cidades atendidas pela filial");
                                    return false;
                                }
                                var cteManif = new CTeManifesto(listCTeManifesto.idMovimento, dataEmissao, listCTeManifesto.numeroFiscal, listCTeManifesto.remetente.razaosocial, listCTeManifesto.destinatario.razaosocial, 
                                listCTeManifesto.cidadeOrigemCTe.cidade, listCTeManifesto.cidadeDestinoCTe.cidade + "-" + listCTeManifesto.cidadeDestinoCTe.uf, formatoMoeda(listCTeManifesto.totalNFVolume), formatoMoeda(listCTeManifesto.totalNFVolume), 
                                (listCTeManifesto.totalNFPeso), (listCTeManifesto.totalNFPeso), formatoMoeda(listCTeManifesto.totalNFValor), formatoMoeda(listCTeManifesto.totalPrestacao), false, 0, listCTeManifesto.serie,true,listCTeManifesto.cidadeDestinoCTe.idcidade);

                                addCTeManifesto(cteManif,$("tbodyCTeManifesto"));
                                
                                if($("is_ativar_valor").value == "t" || $("is_ativar_valor").value == "true" ){
//                                    if($("valor_max").value.split(".")[1].length < 2){
//                                       $("valor_max").value = $("valor_max").value + "0"; 
//                                    }
                                        if($("valorMaximoSeguradora") != null && $("valorMaximoSeguradora") != undefined){
                                            $("valorMaximoSeguradora").value = fmtReais($("valor_max").value,2);
                                        }
                                }
                                //console.log("listCTeManifesto.motorista.idmotorista: "+listCTeManifesto.motorista.idmotorista)
                                carregarDadosCTeManifesto(
                                        listCTeManifesto.motorista.idmotorista,
                                        listCTeManifesto.motorista.nome,
                                        listCTeManifesto.motorista.liberacao,
                                        vencimentoCNH,
                                        listCTeManifesto.cidadeOrigemCTe.idcidade,
                                        listCTeManifesto.cidadeOrigemCTe.cidade,
                                        listCTeManifesto.cidadeOrigemCTe.uf,
                                        listCTeManifesto.cidadeDestinoCTe.idcidade,
                                        listCTeManifesto.cidadeDestinoCTe.cidade,
                                        listCTeManifesto.cidadeDestinoCTe.uf,
                                        listCTeManifesto.veiculo.idveiculo,
                                        listCTeManifesto.veiculo.placa,
                                        listCTeManifesto.veiculo.osAbertoVeiculo,
                                        listCTeManifesto.carreta.idveiculo,
                                        listCTeManifesto.carreta.placa,
                                        listCTeManifesto.motorista.tipo,
                                        listCTeManifesto.distanciaCTe,
                                        listCTeManifesto.bitrem.idveiculo,
                                        listCTeManifesto.bitrem.placa);

                                validacaoPIN();
                            }
                        }
                        
                        calcularValoresCtrcManifesto();
                        desabilitarFilial();
                        
                    }
                });
            }
        }
        //function para remover os ctes do DOM, que não foram salvos antes.
        function removerCTeManifesto(idCTeRemover){
//            limparTotais();
            for (var qtd = 0; qtd < $("qtdLinhasCTe").value; qtd++) {
                if($("idCTeManif_"+qtd) != null){
                    for(var rem = 0; rem < idCTeRemover.split(",").length; rem++){
                        if($("idCTe_"+qtd) != null){
                            if($("idCTe_"+qtd).value == idCTeRemover.split(",")[rem]){
                        Element.remove("trCTeManifesto_"+qtd);                                    
                            }
                        }
                    }    
                }
            }
            calcularQtdTotais();
            calcularVolume();
            calcularVolumeReal();
            calcularPeso();
            calcularPesoReal();
            calcularNotaFiscal();
            calcularFrete();
        }
        //function para remover os ctes do DOM que já foram salvos.
        function removerCTeManifestoAjax(idCTeRemover, idCTeManif){
            
            jQuery.ajax({
                    url: '<c:url value="./cadmanifesto" />',
                    dataType: "text",
                    method: "post",
                    data: {
                        idCTeRemover: idCTeRemover,                  
                        idCTeManif: idCTeManif,                  
                        acao : "removerCTeManifesto"
                    },
                    success: function(data) {
                        
                        var removido = JSON.parse(data).boolean;
                        if(removido){
                            removerCTeManifesto(idCTeRemover);
                        }else{
                            alert("Atencão: Não foi possivel remover o CTe");
                        }
                    }
                });
        
        }
        
        function carregarDadosCTeManifesto(
            idMotorista,
            nomeMotorista,
            liberacaoMotorista,
            vencimentoCNH,
            idCidadeOrigem,
            cidadeOrigem,
            ufOrigem,
            idCidadeDestino,
            cidadeDestino,
            ufDestino,
            idVeiculo,
            placaVeiculo,
            osAbertoVeiculo,
            idCarreta,
            placaCarreta,
            tipoMotorista,
            distanciaCTe,
            idbitrem,
            placaBitrem
            ){ 
           if(idMotorista != 0){
               //dados do motorista
               $("motoristaID").value = idMotorista;
               $("nomeMotorista").value = nomeMotorista;
               $("motoristaLiberacao").value = liberacaoMotorista;
               $("tipo").value = tipoMotorista;
               $("motor_vencimentocnh").value = vencimentoCNH;
           }
         if($("ordenacaoCfeManifesto").value == "c"){  
               //dados da cidade origem
               $("cidadeOrigemId").value = idCidadeOrigem;
               $("cidadeOrigem").value = cidadeOrigem;
               $("ufOrigem").value = ufOrigem;
               //dados da cidade destino
               $("idcidadedestino").value = idCidadeDestino;
               $("cid_destino").value = cidadeDestino;
               $("uf_destino").value = ufDestino;
            }else if ($("ordenacaoCfeManifesto").value == "d") {
                if (distanciaCTe > parseFloat($("maior_km_cte").value)) {
                    $("maior_km_cte").value = parseFloat(distanciaCTe);
                    $("cidadeOrigemId").value = idCidadeOrigem;
                    $("cidadeOrigem").value = cidadeOrigem;
                    $("ufOrigem").value = ufOrigem;
                    //dados da cidade destino
                    $("idcidadedestino").value = idCidadeDestino;
                    $("cid_destino").value = cidadeDestino;
                    $("uf_destino").value = ufDestino;
                }
            }
           if(idVeiculo != 0){
               //dados do veiculo
               $("veiculoId").value = idVeiculo;
               $("veiculoPlaca").value = placaVeiculo;
               $("os_aberto_veiculo").value = osAbertoVeiculo;               
               $("carretaID").value = idCarreta;
               $("carretaPlaca").value = placaCarreta;
               $("bitremID").value = idbitrem;
               $("bitremPlaca").value = placaBitrem;
           }
           
           aoClicarNoLocaliza("selecionaCTe");
           
        }
        
        function validacaoCTeManifesto(cteSelecionados, serie){
            var retorno = true;
            for (var qtd = 0; qtd < $("qtdLinhasCTe").value; qtd++) {
                if($("idCTe_"+qtd) != null){
                    if(($("numeroCTe_"+qtd).value == cteSelecionados) && ($("serieCTe_"+qtd).value == serie) && jQuery("#trCTeManifesto_"+qtd).is(':visible')){
                        alert("Atenção: CTe " + cteSelecionados + " já foi adicionado!");
                        retorno = false;
                    } 
                    if(($("numeroCTe_"+qtd).value == cteSelecionados) && ($("serieCTe_"+qtd).value == serie) && !jQuery("#trCTeManifesto_"+qtd).is(':visible')){
                        jQuery("#trCTeManifesto_"+qtd).show();
                        var idCTe = $("idCTe_"+qtd).value;
                        var cteRemover = $("idCTeRemover").value;
                        $("idCTeRemover").value = cteRemover.replace(idCTe,"0");
                        retorno = false;
                    } 
                }
            }
            return retorno;
        }
        
        function getProximoNumeroManifesto(){
            <%if(carregamanif){%>                
            
                var serieMdfe = $("serieMdfe").value;
                var idFilial = $("idfilial").value;
                var idFilialDestino = $("idfilial2").value;
                var stUtilizacaoMdfe = $("stUtilizacaoMdfe").value;
                var dataSaida = $("dtsaida").value;
                var serieMdfeCarregado = $("serieMdfeCarregado").value;
                var nmanifesto = $("numeroManifesto").value;
                
                if(serieMdfeCarregado != serieMdfe){
                    
                    jQuery.ajax({
                        url: '<c:url value="/jspcadmanifesto.jsp" />',
                        dataType: "text",
                        method: "post",
                        data: {
                            serieMdfe : serieMdfe,
                            idFilial : idFilial,                        
                            idFilialDestino : idFilialDestino,
                            stUtilizacaoMdfe : stUtilizacaoMdfe,
                            dataSaida : dataSaida,
                            acao : "getProximoNumeroManifesto"
                        },
                        success: function(data) {

                            var nManifesto = JSON.parse(data).numeroManifesto;

                            $("nmanifesto").value = nManifesto;


                        }
                    });
                
                }else{
                    $("nmanifesto").value = nmanifesto;
                }
                
            <%}%>
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
    var rotina = "manifesto";
    var dataDe = $("dataDeAuditoria").value;
    var dataAte = $("dataAteAuditoria").value;
    var id = <%=(carregamanif ? cadmanif.getManifesto().getIdmanifesto() : 0)%>;
    consultarLog(rotina, id, dataDe, dataAte);
    }
    
    function setDataAuditoria(){
       $("dataDeAuditoria").value = '<%= Apoio.getDataAtual() %>'; 
       $("dataAteAuditoria").value = '<%= Apoio.getDataAtual() %>'; 
        
    }
    function setCidadeDestino(){
           setTimeout(function(){
                    if (($("ordenacaoCfeManifesto").value) == "f") {
                        if($("tipoDestino").value == "fl"){
                          if (confirm("Deseja alterar a cidade destino do manifesto para a cidade da filial de destino?")) {
                            $("cid_destino").value = $("fi_cidade").value;
                            $("uf_destino").value = $("fi_uf").value;
                            $("idcidadedestino").value = $("fi_cidade_id").value;
                          }
                        } else if($("tipoDestino").value == "rd"){
                            if(confirm("Deseja alterar a cidade destino do manifesto para a cidade do representante de destino?")) {
                                $("cid_destino").value = $("nome_cidade_redespachante").value;
                                $("uf_destino").value = $("uf_redespachante").value;
                                $("idcidadedestino").value = $("id_cidade_redespachante").value;
                            }
                        }
                    }   
                },100);     
    }
    
    
        function Parada(id, idcidade, cidade, uf, local, tipo){
            this.id = (id != undefined && id != null ? id : 0);            
            this.idcidade = (idcidade != undefined && idcidade != null ? idcidade : 0);            
            this.cidade = (cidade != undefined && cidade != null ? cidade : "");
            this.uf = (uf != undefined && uf != null ? uf : "");
            this.local = (local != undefined && local != null ? local : "");
            this.tipo = (tipo != undefined && tipo != null ? tipo : "");            
        }
        var countParadas =0;
        
        function addParadas(parada){
            $("trParada").style.display = "";
            if(parada == null || parada == undefined){
                parada = new Parada();
            }
            //tbParadas

            countParadas++;

           // var tabela = $("tbParadas");


            var tr_ = Builder.node("tr", {
                id: "trParada_" + countParadas,
                name: "trParada_" + countParadas,
                className: "CelulaZebra2",
                align: "center"
            });



            var tdCidade = Builder.node("td", {
                 align: "center",
                 colspan: "1"

            });
            var tdLocal = Builder.node("td", {
                align: "center",
                colspan: "1"
            });
            var tdTipo = Builder.node("td", {
                align: "center",
                colspan: "1"
            });
            var tdBlank = Builder.node("td", {
                align: "center",
                colspan: "1"
            });
            var tdExcluir = Builder.node("td", {
                align: "center",
                colspan: "1"
            });


            var imagemExcluir = Builder.node("img", {
                src: "img/lixo.png",
                title: "Excluir motorista",
                className: "imagemLink",
                onclick: "excluirParadas("+countParadas+","+parada.id+");",
            });

            var inputHiddenIdParada = Builder.node("input", {
                id: "idParadas_" + countParadas,
                name: "idParadas_" + countParadas,
                type: "hidden",                
                value: parada.id

            });

            var inputHiddenIdCidade = Builder.node("input", {
                id: "idCidadeParadas_" + countParadas,
                name: "idCidadeParadas_" + countParadas,
                type: "hidden",
                value: parada.idcidade

            });

            // idParadas_  idCidadeParadas_   cidade_  uf_  local_ tipo_  maxEscolta

            var inputCidade = Builder.node("input", {
                type: "text",
                className: "inputReadOnly",
                id: "cidade_" + countParadas,
                name: "cidade_" + countParadas,
                size: "20",
                readOnly: "true",
                value: parada.cidade

            });

            var inputUf = Builder.node("input", {
                type: "text",
                className: "inputReadOnly",
                id: "uf_" + countParadas,
                name: "uf_" + countParadas,
                size: "3",
                readOnly: "true",
                value: parada.uf

            });

            var pesquisarCidade = Builder.node("input", {
                    type: "button",
                    className: "inputBotaoMin",
                    id: "botaoCidade_" + countParadas,
                    name: "botaoCidade_" + countParadas,
                    onclick: "localizaCidadeParadas("+countParadas+");",
                    value: "..."

            });

            var inputLocal = Builder.node("input", {
                type: "text",
                className: "inputtexto",
                id: "local_" + countParadas,
                name: "local_" + countParadas,
                size: "35",            
                value: parada.local

            });

            var inputTipo = Builder.node("input", {
                type: "text",
                className: "inputtexto",
                id: "tipo_" + countParadas,
                name: "tipo_" + countParadas,
                size: "10",         
                value: parada.tipo

            });
            
            var _slc1= Builder.node('SELECT', {name: 'tipo_' + countParadas, id: 'tipo_' + countParadas, className: 'fieldMin'});
            var _opt1 = Builder.node('OPTION', {value: "1"});
            var _opt2 = Builder.node('OPTION', {value: "2"});
            var _opt3 = Builder.node('OPTION', {value: "3"});
            var _opt4 = Builder.node('OPTION', {value: "4"});
            var _opt9 = Builder.node('OPTION', {value: "9"});

            _slc1.appendChild(_opt1);
            _slc1.appendChild(_opt2);
            _slc1.appendChild(_opt3);
            _slc1.appendChild(_opt4);
            _slc1.appendChild(_opt9);
            
            _slc1.appendChild(Element.update(_opt1, "Alimentação"));
            _slc1.appendChild(Element.update(_opt2, "Descanso"));
            _slc1.appendChild(Element.update(_opt3, "Entrega"));
            _slc1.appendChild(Element.update(_opt4, "Fiscalização"));
            _slc1.appendChild(Element.update(_opt9, "Outras"));
            if(parada.tipo==""){
                _slc1.selectedIndex = 0;
                
            }else{
               _slc1.value =  parada.tipo;               
            }
            

            tdCidade.appendChild(inputHiddenIdParada);
            tdCidade.appendChild(inputHiddenIdCidade);
            tdCidade.appendChild(inputCidade);
            tdCidade.appendChild(inputUf);
            tdCidade.appendChild(pesquisarCidade);
            tdLocal.appendChild(inputLocal);
            tdTipo.appendChild(_slc1);
            tdExcluir.appendChild(imagemExcluir);

            //POVOANDO AS TR'S
            tr_.appendChild(tdExcluir);
            tr_.appendChild(tdCidade);
            tr_.appendChild(tdLocal);
            tr_.appendChild(tdTipo);
            tr_.appendChild(tdBlank);

            $("tbParadas").appendChild(tr_);
            $("maxParadas").value = countParadas;


        }
    
    
    function excluirParadas(excluirIndex, id){
           if(confirm("Deseja excluir este Parada?")){
                    if(confirm("Tem certeza?")){
                    Element.remove('trParada_'+excluirIndex); 
                    $("maxParadas").value = parseFloat($("maxParadas").value)-1;
                    new Ajax.Request("./cadmanifesto?acao=excluirParadas&idParadas="+id,
                {
                    method:'post',
                    onSuccess: function(){ alert('Parada removida com sucesso!') },
                    onFailure: function(){ alert('Something went wrong...') }
                });     
            }
        }

    }
    
    
    function getTipoComunicacaoRastreamento(valor){
            var idTecnologia;
            var tipoTecnologia ;
            
            if(valor == "cavalo"){
                idTecnologia = $("tecVeiculo").value;
                tipoTecnologia = $("tipoTecVeiculo");
            }else if(valor == "carreta"){
                idTecnologia = $("tecCarreta").value;
                tipoTecnologia = $("tipoTecCarreta");
            }else if(valor == "bitrem"){
                idTecnologia = $("tecBitrem").value;
                tipoTecnologia = $("tipoTecBitrem");
            }
            
          
          
//            new Ajax.Request("./TipoComunicacaoRastreamentoControlador?acao=tipoComunicacao&idTecnologia="+idTecnologia,{method:'post',onSuccess:e,onError: e});             
            jQuery.ajax({
                    url: '<c:url value="/TipoComunicaoRastreamentoControlador" />',
                    dataType: "text",
                    method: "post",
                    data: {
                        idTecnologia : idTecnologia,
                        acao : "tipoComunicacao"
                    },
                    success: function(data) {
                       
                       var tipoComRast = JSON.parse(data);
                       tipoTecnologia.value = tipoComRast.tipoComunicacaoRastreamento.id;
                       
//                       console.log("JSON.parse(data): "+JSON.parse(data));
//                       var textoresposta = data.responseText;
//                        console.log("textoresposta: "+textoresposta);
//                        var tipoComunicacaoRastreamento =jQuery.parseJSON(textoresposta).tipoComunicacaoRastreamento;
//                        $("tipoComunicacao").value = tipoComunicacaoRastreamento.id;
                        
                    }
                });
        }
    
    
    function desabilitarFilial(){
        var maxCte = $("qtdLinhasCTe").value;
        var existeCte = false;
    
        for (var qtdCte = 0; qtdCte <= maxCte; qtdCte++) {
            if ($("idCTe_" + qtdCte) != null) {
                existeCte = true;
                break;
            }    
        }
        if (existeCte == true) {
             ($("localiza_filial2") == null ? '' : $("localiza_filial2").style.display = "none");
             ($("localiza_filial") == null ? '' : $("localiza_filial").style.display = "none");
             ($("botao_redspt") == null ? '' : $("botao_redspt").style.display = "none");
             ($("localiza_redespachante") == null ? '' : $("localiza_redespachante").style.display = "none");
             $("tipoDestino").disabled = true;
        }
        
    }
    
    function validarBloqueioVeiculo(tipo){
       var bloqueado = false;
            if($("is_bloqueado").value == "t" && tipo == "veiculo"){
                        setTimeout(function(){
                        alert("O veículo " + $("vei_placa").value + " está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
                        $("idveiculo").value = "0";
                        $("vei_placa").value = "";
                        $("veiculoPlaca").value = "";
                        $("veiculoId").value = "0";
                        bloqueado = true;
                        },100);
            }
            if($("is_bloqueado").value == "t" && tipo == "carreta"){
                        setTimeout(function(){
                        alert("A carreta " + $("car_placa").value + " está bloqueada e não poderá ser utilizada no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
                        $("idcarreta").value = "0";
                        $("car_placa").value = "";
                        $("carretaID").value = "0";
                        $("carretaPlaca").value = "";
                        bloqueado = true;
                        },100);
            }
            if($("is_bloqueado").value == "t" && tipo == "bitrem"){
                        setTimeout(function(){
                        alert("O Bi-trem " + $("bi_placa").value + " está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
                        $("idbitrem").value = "0";
                        $("bi_placa").value = "";
                        $("bitremID").value = "0";
                        $("bitremPlaca").value = "";
                        bloqueado = true;
                        },100);
            }
            if($("is_bloqueado").value == "t" && tipo == "tritrem"){
                        setTimeout(function(){
                        alert("O 3º Reboque " + $("tri_placa").value + " está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
                        $("idtritrem").value = "0";
                        $("tri_placa").value = "";
                        $("tritremID").value = "0";
                        $("tritremPlaca").value = "";
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
                    $("veiculoPlaca").value = "";
                    $("veiculoId").value = "0";
                    bloqueado = true;
            },100);
        }else if($("is_moto_carreta_bloq").value == "t" && filtros.split(",")[i] == "carreta_motorista"){
                setTimeout(function (){
                    alert("A carreta " + $("car_placa").value + ", vinculada ao motorista " +$("motor_nome").value+ ", está bloqueada e não poderá ser utilizada no lançamento. \r\n Motivo: " + $("moto_carreta_bloq_motivo").value);
                    $("idcarreta").value = "0";
                    $("car_placa").value = "";
                    $("carretaID").value = "0";
                    $("carretaPlaca").value = "";
                    bloqueado = true;
                 
                },100);
        }else if($("is_moto_bitrem_bloq").value == "t" && filtros.split(",")[i] == "bitrem_motorista"){
                setTimeout(function (){
                    alert("O bi-trem " + $("bi_placa").value + ", vinculada ao motorista " +$("motor_nome").value+ ", está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("moto_bitrem_bloq_motivo").value);
                    $("idbitrem").value = "0";
                    $("bi_placa").value = "";
                    $("bitremID").value = "0";
                    $("bitremPlaca").value = "";
                    bloqueado = true;
                 
                },100);
        }else if($("is_moto_tritrem_bloq").value == "t" && filtros.split(",")[i] == "tritrem_motorista"){
                setTimeout(function (){
                    alert("O 3º Reboque " + $("tri_placa").value + ", vinculado ao motorista " +$("motor_nome").value+ ", está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("moto_tritrem_bloq_motivo").value);
                    $("idtritrem").value = "0";
                    $("tri_placa").value = "";
                    $("tritremID").value = "0";
                    $("tritremPlaca").value = "";
                    bloqueado = true;
                 
                },100);
            }
        }
        return bloqueado;
    }
    
    function Ajudante(id, nome, cpf, idfornecedor) {
        this.id = (id == undefined || id == null ? 0 : id);
        this.nome = (nome == undefined || nome == null ? "" : nome);
        this.cpf = (cpf == undefined || cpf == null ? "" : cpf);
        this.idfornecedor = (idfornecedor == undefined || idfornecedor == null ? 0 : idfornecedor);
    }

    var countAjudante = 0;
    
    function addAjudante(ajudante, table) {
        try {
            if (ajudante == null || ajudante == undefined) {
                ajudante = new Ajudante();
            }
            
            var index = $("indexAux").value;
            
            if (index == "") {
                countAjudante++;

                var classe = "CelulaZebra2NoAlign";
                var callRemoverAjudante = "removerAjudante(" + countAjudante + ");"
                var _tr = Builder.node("tr", {id: "trAjudante_" + countAjudante, className: classe});
                var _tdRemove = Builder.node("td", {id: "tdAjudanteRemove_" + countAjudante, align: "center"});
                var _tdAjudanteNome = Builder.node("td", {id: "tdAjudanteNome_" + countAjudante});
                var _tdAjudanteCPF = Builder.node("td", {id: "tdAjudanteCPF_" + countAjudante});
                var _td4 = Builder.node("td");

                var _inpId = Builder.node("input", {
                    id: "idAjudante_" + countAjudante,
                    name: "idAjudante_" + countAjudante,
                    type: "hidden",
                    className: "inputTexto",
                    value: ajudante.id
                });
                var _inpIdFornecedor = Builder.node("input", {
                    id: "idFornecedor_" + countAjudante,
                    name: "idFornecedor_" + countAjudante,
                    type: "hidden",
                    className: "inputTexto",
                    value: ajudante.idfornecedor
                });
                var _inpImg = Builder.node("img", {
                    id: "imgAjudanteRemove_" + countAjudante,
                    name: "imgAjudanteRemove_" + countAjudante,
                    src: "img/lixo.png",
                    onclick: callRemoverAjudante
                });
                var _inpNome = Builder.node("input", {
                    id: "nomeAjudante_" + countAjudante,
                    name: "nomeAjudante_" + countAjudante,
                    type: "text",
                    size: "50",
                    maxLength: "100",
                    className: "inputTexto",
                    value: ajudante.nome
                });
                var _inpCPF = Builder.node("input", {
                    id: "cpfAjudante_" + countAjudante,
                    name: "cpfAjudante_" + countAjudante,
                    type: "text",
                    size: "50",
                    maxLength: "50",
                    className: "inputTexto",
                    value: ajudante.cpf
                });
                var _inpLocalizaAjudante = Builder.node("input", {
                    id: "localizaAjudante_" + countAjudante,
                    name: "localizaAjudante_" + countAjudante,
                    type: "button",
                    class: "inputBotaoMin",
                    value: "...",
                    onClick: "abrirLocalizarAjudante(" + countAjudante + ");"
                });

                _tdRemove.appendChild(_inpId);
                _tdRemove.appendChild(_inpIdFornecedor);
                _tdRemove.appendChild(_inpImg);
                _tdAjudanteNome.appendChild(_inpNome);
                _tdAjudanteCPF.appendChild(_inpCPF);
                _td4.appendChild(_inpLocalizaAjudante);
                _tr.appendChild(_tdRemove);
                _tr.appendChild(_tdAjudanteNome);
                _tr.appendChild(_tdAjudanteCPF);
                _tr.appendChild(_td4);
                table.appendChild(_tr);

                $("qtdAjudantes").value = countAjudante;
            } else {
                $("idFornecedor_" + index).value = ajudante.idfornecedor;
                $("nomeAjudante_" + index).value = ajudante.nome;
                $("cpfAjudante_" + index).value = "AUTO-PREENCHIMENTO";
            }
            
            // reiniciar index
            $("indexAux").value = "";

            visivel(table);
        } catch (ex) {
            alert(ex);
        }
    }
    
    function removerAjudante(index) {
        try {
            var id = $("idAjudante_" + index).value;
            
            if (confirm("Tem certeza que deseja remover o ajudante?")) {
                Element.remove('trAjudante_' + index);
                
                countAjudante--;
                
                $("qtdAjudantes").value = countAjudante;
                
                if (parseInt(id) != 0) {
                    tryRequestToServer(function(){
                        new Ajax.Request("./cadmanifesto?acao=AjaxRemoverAjudante&ajudanteId=" + id, {
                            method:'post', 
                            onSuccess: "alert('Ajudante removido com sucesso!')",
                            onError: "alert('Não foi possivel remover o ajudante!')"
                        });
                    });
                }
            }
        } catch (e) {
            alert(e);
        }
    }
    
    function abrirLocalizarAjudante(index) {
        if ($("indexAux") != null) {
            $("indexAux").value = index;
        }
        
        launchPopupLocate('./localiza?acao=consultar&idlista=25', 'Ajudante');
    }
    
    function aeroportoAtendimentoDestino(){
        var cidadeAtendidas = $("id=[cidadeDestino_]").value;
        console.log("AS cidades atendidas: "+ cidadeAtendidas)
    }
    
</script>
<%@page import="com.sagat.bean.NotaFiscal"%>
<%@page import="java.util.List"%>
<%@ page import="usuario.BeanUsuario" %>
<%@ page import="br.com.gwsistemas.eutil.NivelAcessoUsuario" %>
<%@ page import="br.com.gwsistemas.gwcte.averbacao.apisul.AverbacaoApisulBO300" %>
<%@ page import="br.com.gwsistemas.gwcte.averbacao.DocumentoAverbacao" %>
<%@ page import="br.com.gwsistemas.gwcte.averbacao.ModeloDocumentoAverbacao" %>
<%@ page import="br.com.gwsistemas.gwmdfe.EventoMDFe" %>
<%@ page import="br.com.gwsistemas.gwcte.averbacao.AverbacaoBO" %>
<%@ page import="br.com.gwsistemas.movimentacao.iscas.MovimentacaoIscas" %>
<html>
<head>
    <script language="javascript" src="script/<%=Apoio.noCacheScript("funcoes_gweb.js")%>" type=""></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language"  content="pt-br">
        <META HTTP-EQUIV="Page-Enter" CONTENT = "RevealTrans (Duration=1, Transition=12)">
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("funcoesTelaManifesto.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("notaFiscal-util.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("servicos-util.js")%>" type="text/javascript"></script>
        <script language="javascript" type="text/javascript" src="script/<%=Apoio.noCacheScript("mascaras.js")%>"></script>
        <title>WebTrans - Manifesto</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">

        <c:set var="autenticado" value="<%= autenticado %>"/>
        <c:set var="mostrar_averbacao" value='<%= carregamanif ? (manif.getFilial().isTransmitirMDFeSeguradora() && !manif.getFilial().getTipoUtilizacaoApisul().equals("N")) : (autenticado.getFilial().isTransmitirMDFeSeguradora() && !autenticado.getFilial().getTipoUtilizacaoApisul().equals("N")) %>'/>
        <c:set var="status_mdfe" value='<%= carregamanif ? manif.getStatusManifesto() : "P" %>'/>
        <c:set var="tem_permissao_averbar_manualmente" value='<%= autenticado.getAcesso("lanaverbacaoCTeManual") == NivelAcessoUsuario.CONTROLE_TOTAL.getNivel() %>'/>
        <c:set var="tem_permissao_condutor_adicional"
               value='<%= carregamanif && (acao.equals("editar") || acao.equals("atualizar"))
                           && nivelCondutorMDFe == NivelAcessoUsuario.CONTROLE_TOTAL.getNivel() && (manif.getStatusManifesto().equals("C") || manif.getStatusManifesto().equals("R")) %>'/>
        <c:set var="manifesto_id" value="<%= carregamanif ? manif.getIdmanifesto() : 0 %>"/>
        <c:set var="manifesto_numero" value="<%= carregamanif ? manif.getNmanifesto() : 0 %>"/>
        <c:set var="manifesto_filial" value="<%= carregamanif ? manif.getFilial().getIdfilial() : 0 %>"/>

        <script src="${homePath}/assets/alerts/alerts-min.js?v=${random.nextInt()}"></script>
        <jsp:include page="/importAlerts.jsp">
            <jsp:param name="caminhoImg" value="assets/img/gw-trans.png"/>
            <jsp:param name="nomeUsuario" value="${autenticado.nome}"/>
        </jsp:include>

        <script>
            var homePath = '${homePath}';
            var mostrarAverbacao = '${mostrar_averbacao}' === 'true';
            var manifestoId = '${manifesto_id}';
            var manifestoNumero = '${manifesto_numero}';
            var manifestoFilial = '${manifesto_filial}';
        </script>

        <style>
            .modal-content {
                text-align: left;
            }
        </style>
    </head>

    <body onLoad="javascript:applyFormatter();atribuicombos(); manifestaCtrc();aoCarregar();slcTpDestino();alteraTipo();calcularicms();getRotaPercurso();AlternarAbasManifesto('tdAbaDadosPrincipais','tdCelDadosPrincipais');setDataAuditoria();desabilitarFilial();">
        <form method="post" action="./cadmanifesto" id="formulario" target="pop">
            <div align="center">
                <img src="img/banner.gif"><br>
                <!-- CAMPOS OCULTOS -->
                <!-- FALTA O CODIGO DA FILIAL-->
                <input type="hidden" name="obs_desc" id="obs_desc" >
                <input type="hidden" name="acao" id="acao" value="<%=acao%>">
                <input type="hidden" name="id" id="id"  value="<%=(carregamanif ? manif.getIdmanifesto() : 0)%>">
                <input type="hidden" name="valor_max" id="valor_max" value="<%=(carregamanif ? df.format(manif.getFilial().getValorMaximo()): df.format(autenticado.getFilial().getValorMaximo()))%>">
                <input type="hidden" name="is_ativar_valor" id="is_ativar_valor" value="<%=(carregamanif ? manif.getFilial().isIsAtivaControleValorManifesto(): autenticado.getFilial().isIsAtivaControleValorManifesto())%>">
                <input type="hidden" name="idfilial" id="idfilial" value="<%=(carregamanif ? manif.getFilial().getIdfilial() : autenticado.getFilial().getIdfilial())%>">
                <input type="hidden" name="idfilial2" id="idfilial2" value="<%=(carregamanif ? manif.getFilialdestino().getIdfilial() : autenticado.getFilial().getIdfilial())%>">
                <input type="hidden" name="idcidadeorigem" id="idcidadeorigem" value="">
                <input type="hidden" name="cid_origem" id="cid_origem" value="">
                <input type="hidden" name="uf_origem" id="uf_origem" value="">
                <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="<%=(carregamanif ? manif.getCidadedestino().getIdcidade() : autenticado.getFilial().getCidade().getIdcidade())%>">
                <input type="hidden" name="veiculoId" id="veiculoId" value="<%=(carregamanif ? String.valueOf(manif.getCavalo().getIdveiculo()) : "0")%>">
                <input type="hidden" name="carretaID" id="carretaID" value="<%=(carregamanif ? String.valueOf(manif.getCarreta().getIdveiculo()) : "0")%>">
                <input type="hidden" name="idcarreta" id="idcarreta">
                <input type="hidden" name="bitremID" id="bitremID" value="<%=(carregamanif ? String.valueOf(manif.getBiTrem().getIdveiculo()) : "0")%>">
                <input type="hidden" name="motoristaID" id="motoristaID" value="<%=(carregamanif ? String.valueOf(manif.getMotorista().getIdmotorista()) : "0")%>">
                <input type="hidden" name="idcompanhia" id="idcompanhia" value="<%=(carregamanif ? awb != null ? String.valueOf(awb.getCompanhiaAerea().getId()) : "0" : "0")%>">
                <input type="hidden" name="idredespachante" id="idredespachante" value="<%=(carregamanif ? String.valueOf(manif.getRedespachante().getIdfornecedor()) : "0")%>">
                <input type="hidden" name="tipo" id="tipo" value="<%=(carregamanif ? String.valueOf(manif.getMotorista().getTipo()) : "")%>">
                <input type="hidden" name="bloqueado" id="bloqueado" value="">
                <input type="hidden" name="motivobloqueio" id="motivobloqueio" value="">
                <input type="hidden" name="idcavalo" id="idcavalo" value="<%=(carregamanif ? String.valueOf(manif.getCavalo().getIdveiculo()) : "0")%>">
                <input type="hidden" name="vei_placa" id="vei_placa">
                <input type="hidden" name="car_placa" id="car_placa">
                <input type="hidden" name="idbitrem" id="idbitrem">
                <input type="hidden" name="bi_placa" id="bi_placa">
                <input type="hidden" name="motor_nome" id="motor_nome" value="">
                <input type="hidden" id="maxCondutores" name="maxCondutores" value="0"/>
                <input type="hidden" id="idCondutor" name="idCondutor" value=""/>
                <input type="hidden" id="idmotorista_col" name="idmotorista_col"/>
                <input type="hidden" id="st_utilizacao_mdfe" name="st_utilizacao_mdfe"/>
                
                <input type="hidden" name="idtrip" id="idtrip" value="0">
                <input type="hidden" name="trip_nome" id="trip_nome" value="">
                <input type="hidden" name="trip_funcao" id="trip_funcao" value="">
                <!-- ocorrencia-->
                <input type="hidden" id="ocorrencia" name="ocorrencia" value="">
                <input type="hidden" id="ocorrencia_id" name="ocorrencia_id" value="">
                <input type="hidden" id="descricao_ocorrencia" name="descricao_ocorrencia" value="">
                <input type="hidden" id="obriga_resolucao" name="obriga_resolucao" value="">
                <input type="hidden" id="statusManifesto" name="statusManifesto" value="${statusManifesto}">
                <input type="hidden" name="os_aberto_veiculo" id="os_aberto_veiculo" value="<%=(carregamanif && manif.getCavalo().isOsAbertoVeiculo() ? "t" : "f")%>">
                <input type="hidden" name="miliSegundos"  id="miliSegundos" value="0">
                <input type="hidden" name="cfgPermitirLancamentoOSAbertoVeiculo"  id="cfgPermitirLancamentoOSAbertoVeiculo" value="<%=cfg.getPermitirLancamantoOSAbertoVeiculo()%>">
                <input type="hidden" name="codigo_ibge_origem" id="codigo_ibge_origem" value="<%=(carregamanif ? manif.getCidadeorigem().getCod_ibge() : autenticado.getFilial().getCidade().getCod_ibge())%>">
                <input type="hidden" name="codigo_ibge_destino" id="codigo_ibge_destino" value="<%=(carregamanif ? manif.getCidadedestino().getCod_ibge() : autenticado.getFilial().getCidade().getCod_ibge())%>">
                <input type="hidden" name="qtdLinhasCTe" id="qtdLinhasCTe" value="0">
                <input type="hidden" name="idCTeRemover" id="idCTeRemover" value="0">
                <input type="hidden" name="idManifesto" id="idManifesto" value="<%=(carregamanif ? manif.getIdmanifesto() : 0)%>">
                <!--condutor-->
                <input type="hidden" name="idmotorista" id="idmotorista" value="<%=(carregamanif ? manif.getMotorista().getId(): 0)%>">
                <input type="hidden" name="idveiculo" id="idveiculo" value="0">
                
                <input type="hidden" name="motor_liberacao" id="motor_liberacao" value="0">
                <input type="hidden" name="serie_mdfe" id="serie_mdfe" value="">
                <input type="hidden" name="ordenacaoCfeManifesto"  id="ordenacaoCfeManifesto" value="<%=cfg.getTipoOrdenacaoCteManifesto()%>">
                
                <input type="hidden" name="maxParadas" id="maxParadas" value="0">
                
                <input type="hidden" name="tecnologia_rastreamento_id_veiculo" id="tecnologia_rastreamento_id_veiculo" value="0">
                <input type="hidden" name="tecnologia_rastreamento_veiculo" id="tecnologia_rastreamento_veiculo" value="">
                <input type="hidden" name="tipo_tecnologia_rastreamento_id_veiculo" id="tipo_tecnologia_rastreamento_id_veiculo" value="0">
                <input type="hidden" name="tipo_comunicacao_rastreamento_veiculo" id="tipo_comunicacao_rastreamento_veiculo" value="">
                <input type="hidden" name="numero_equipamento_veiculo" id="numero_equipamento_veiculo" value="">
               
                <input type="hidden" name="tecnologia_rastreamento_id_carreta" id="tecnologia_rastreamento_id_carreta" value="0">
                <input type="hidden" name="tecnologia_rastreamento_carreta" id="tecnologia_rastreamento_carreta" value="">
                <input type="hidden" name="tipo_tecnologia_rastreamento_id_carreta" id="tipo_tecnologia_rastreamento_id_carreta" value="0">
                <input type="hidden" name="tipo_comunicacao_rastreamento_carreta" id="tipo_comunicacao_rastreamento_carreta" value="">
                <input type="hidden" name="numero_equipamento_carreta" id="numero_equipamento_carreta" value="">
                
                <input type="hidden" name="tecnologia_rastreamento_id_bitrem" id="tecnologia_rastreamento_id_bitrem" value="0">
                <input type="hidden" name="tecnologia_rastreamento_bitrem" id="tecnologia_rastreamento_bitrem" value="">
                <input type="hidden" name="tipo_tecnologia_rastreamento_id_bitrem" id="tipo_tecnologia_rastreamento_id_bitrem" value="0">
                <input type="hidden" name="tipo_comunicacao_rastreamento_bitrem" id="tipo_comunicacao_rastreamento_bitrem" value="">
                <input type="hidden" name="numero_equipamento_bitrem" id="numero_equipamento_bitrem" value="">
                <input type="hidden" name="motivo_bloqueio" id="motivo_bloqueio">    
                <input type="hidden" name="is_bloqueado" id="is_bloqueado">    
                <input type="hidden" name="moto_veiculo_bloq_motivo" id="moto_veiculo_bloq_motivo">    
                <input type="hidden" name="is_moto_veiculo_bloq" id="is_moto_veiculo_bloq">    
                <input type="hidden" name="moto_carreta_bloq_motivo" id="moto_carreta_bloq_motivo">    
                <input type="hidden" name="is_moto_carreta_bloq" id="is_moto_carreta_bloq"> 
                <input type="hidden" name="moto_bitrem_bloq_motivo" id="moto_bitrem_bloq_motivo">    
                <input type="hidden" name="is_moto_bitrem_bloq" id="is_moto_bitrem_bloq"> 
                <input type="hidden" name="moto_tritrem_bloq_motivo" id="moto_tritrem_bloq_motivo" value="">    
                <input type="hidden" name="is_moto_tritrem_bloq" id="is_moto_tritrem_bloq" value=""> 
                <input type="hidden" name="tritremID" id="tritremID" value="<%=(carregamanif ? String.valueOf(manif.getTriTrem().getIdveiculo()) : "0")%>">
                <input type="hidden" name="idtritrem" id="idtritrem">
                <input type="hidden" name="tri_placa" id="tri_placa">
                <input type="hidden" name="fi_cidade_id," id="fi_cidade_id">
                <input type="hidden" name="maior_km_cte" id="maior_km_cte" value="<%=( carregamanif ? manif.getMaiorKMCte() : 0 )%>">
                <input type="hidden" name="ctrcs" id="ctrcs" value="">
                
                
                <!-- campo localiza lista 25 - Ajudantes -->
                <input type="hidden" name="idajudante" id="idajudante">
                <input type="hidden" name="nome" id="nome">
                <input type="hidden" name="idfornecedor" id="idfornecedor">
                <input type="hidden" name="fornecedor" id="fornecedor">
                <input type="hidden" name="qtdFuncionario" id="qtdFuncionario">
            </div>
                
            <table width="90%" align="center" class="bordaFina">
                <tr>
                    <td width="570">
                        <div align="left">
                            <b>Manifesto</b>
                        </div>
                    </td>
                    <% if ((acao.equals("editar")) && (nivelUser >= 4) && (Boolean.parseBoolean(request.getParameter("ex")))) //se o paramentro vier com valor entao nao pode excluir
                                {%>
                    <td width="59">
                        <input name="excluir" type="button" class="botoes" id="excluir" value="Excluir" onClick="javascript:excluirmanifesto(<%=(carregamanif ? manif.getIdmanifesto() : 0)%>)">
                    </td>
                        <%}%>
                    <td width="55" >
                        <input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:voltar();">
                    </td>
                </tr>
            </table>
            <br>
            <table width="90%" border="0" align="center" cellpadding="0" cellspacing="0" class="bordaFina">
              
                <tr>
                    <td colspan="3"> 
                        <table width="100%" border="0" cellpadding="0" cellspacing="1">
                            <tr>
                                <td colspan="7">
                                    <table width="100%" border="0">
                                        <tr>
                                            <td width="5%" class="TextoCampos">N&uacute;mero:</td>
                                            <td width="5%" class="CelulaZebra2">
                                                <span class="CelulaZebra2">
                                                    <input name="nmanifesto" type="text" id="nmanifesto" class="inputReadOnly" value="<%=(carregamanif ? manif.getNmanifesto() : "")%>" size="6" maxlength="6" <%=(carregamanif ? "" : "readonly")%> <%=(carregamanif ? manif.getStatusManifesto().charAt(0) == 'C' ? "readonly" : "" : "")%> />
                                                    <input name="numeroManifesto" type="hidden" id="numeroManifesto" value="<%=(carregamanif ? manif.getNmanifesto() : "")%>" />
                                                    <input name="subCodigo" type="text" id="subCodigo" class="inputReadOnly" style="display:<%=(cfg.isSubCodigoManifesto() ? "" : "none")%>;" value="<%=(carregamanif ? manif.getSubCodigo() : "")%>" size="1" maxlength="3" <%=(carregamanif ? "" : "readonly")%>>
                                                </span>
                                            </td>
                                            <td width="5%"  class="TextoCampos">Série MDF-e:</td>
                                            <td width="5%"  class="CelulaZebra2">
                                                <input type="text" id="serieMdfe" name="serieMdfe" value="<%=(carregamanif ? (manif.getSerieMdfe() == null ? autenticado.getFilial().getSerieMdfe() : manif.getSerieMdfe()) : autenticado.getFilial().getSerieMdfe())%>" <%=(carregamanif ? manif.getStatusManifesto().charAt(0) == 'C' ? "readonly" : "" : "")%> class="<%=(carregamanif ? manif.getStatusManifesto().charAt(0) == 'C' ? "inputReadOnly" : "inputtexto" : "inputtexto")%>" size="5" maxlength="8" onchange="javascript:getProximoNumeroManifesto();" />
                                                <input type="hidden" id="serieMdfeCarregado" name="serieMdfeCarregado" value="<%=(carregamanif ? (manif.getSerieMdfe() == null ? autenticado.getFilial().getSerieMdfe() : manif.getSerieMdfe()) : autenticado.getFilial().getSerieMdfe())%>" />
                                            </td>
                                            <td width="5%" class="TextoCampos">Tipo:</td>
                                            <td width="13%" class="CelulaZebra2">
                                                <select name="tipo_movimento" id="tipo_movimento" onChange="alteraTipo();" class="inputtexto">
                                                    <option value="m" <%=(carregamanif? manif.getTipo().equals("m") ? "selected" : "" : "selected")%>>Rodoviario</option>
                                                    <option value="a" <%=(carregamanif? manif.getTipo().equals("a") ? "selected" : "" : "")%>>Aéreo</option>
                                                    <option value="f" <%=(carregamanif? manif.getTipo().equals("f") ? "selected" : "" : "")%>>Aquaviario </option> 
                                                </select>                                        
                                            </td>
                                            <td colspan="2" class="CelulaZebra2">
                                                <div align="center">
                                                    <input type="checkbox" name="manifestoPontoControle" id="manifestoPontoControle" <%=(carregamanif ? (manif.isIsManifestoPontoControle()? "checked" : ""): (cfg.isIsManifestoPontoControle() ? " checked " : ""))%>>
                                                    <label id="lbmanifesto"> Ativar Ponto de Controle(gwMobile) </label>
                                                </div>
                                            </td>
                                            <td width="10%" class="TextoCampos" >Filial origem: </td>
                                            <td width="15%" class="CelulaZebra2">
                                                <input name="fi_abreviatura" id="fi_abreviatura" type="text" size="12" class="inputReadOnly"
                                                       readonly value="<%=(carregamanif ? manif.getFilial().getAbreviatura() : autenticado.getFilial().getAbreviatura())%>">                                                
                                                <input name="fi_uf_origem" id="fi_uf_origem" type="text" size="1" class="inputReadOnly" readonly value="<%=(carregamanif ? manif.getFilial().getCidade().getUf() : autenticado.getFilial().getCidade().getUf())%>">
                                                <input name="stUtilizacaoMdfe" id="stUtilizacaoMdfe" type="hidden" value="<%=(carregamanif ? manif.getFilial().getStUtilizacaoMDFe() : autenticado.getFilial().getStUtilizacaoMDFe())%>" />
                                                <%if (autenticado.getAcesso("lanconhfl") > 0 && acao.equals("iniciar")) {%>
                                                    <input name="localiza_filial" type="button" class="inputBotaoMin" id="localiza_filial" value="..." onClick="javascript:localizafilial();">
                                                <%}%>                                        
                                            </td>
                                            <td width="8%" class="TextoCampos">Data sa&iacute;da: </td>
                                            <td width="14%" class="CelulaZebra2">
                                                <input name="dtsaida" type="text" id="dtsaida" value="<%=(carregamanif ? formato.format(manif.getDtsaida()) : data)%>" size="9" maxlength="10"
                                                       onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" class="fieldDate"/>
                                                &agrave;s
                                                <input name="hrsaida" type="text" onkeyup="mascaraHora(this)" id="hrsaida" value="<%=(carregamanif && manif.getHrsaida() != null ? manif.getHrsaida() : hora)%>" size="4" maxlength="8" class="inputtexto">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2" class="TextoCampos">Tipo Emitente MDF-e:</td>
                                            <td colspan="2" class="CelulaZebra2">
                                                <select name="tipoEmitenteMDFe" id="tipoEmitenteMDFe" class="inputtexto" style="width: 120%">
                                                    <option value="1" <%=(carregamanif && manif.getTipoEmitenteMDFe()==1 ? "selected" : "")%>>Prestador de serviço de transporte</option>
                                                    <option value="2" <%=(carregamanif && manif.getTipoEmitenteMDFe()==2 ? "selected" : "")%>>Transportador de Carga Própria</option>                                       
                                                    <option value="3" <%=(carregamanif && manif.getTipoEmitenteMDFe()==3 ? "selected" : "")%>>Prestador de serviço de transporte que emitirá CT-e Globalizado</option>                                       
                                                </select>
                                            </td>
                                            
                                            
                                            
                                            <td width="5%" class="TextoCampos"></td>
                                            <td width="5%" class="CelulaZebra2">
                                              
                                            </td>
                                            <td colspan="2" class="CelulaZebra2">
                                                <div align="center">
                                                    <input type="checkbox" name="ismanifesto" id="ismanifesto" <%=(carregamanif ? (manif.isIsPreManifesto() ? "checked" : ""): "")%>>
                                                    <label id="lbmanifesto">Pr&eacute; Manifesto (Separação)</label>
                                                </div>
                                            </td>
                                            <td class="TextoCampos">
                                                <select id="tipoDestino" name="tipoDestino" onchange="slcTpDestino()" class="inputtexto" >
                                                    <option value="fl" <%=carregamanif && manif.getTipoDestino().equals("fl") ? "selected" : ""%> >Filial destino:</option>
                                                    <option value="rd" <%=carregamanif && manif.getTipoDestino().equals("rd") ? "selected" : ""%>>Representante destino:</option>
                                                </select>
                                            </td>
                                            <td class="CelulaZebra2">
                                                <div id="inp_fl" >
                                                    <input type="hidden" id="chk_cidade_atendidas" name="chk_cidade_atendidas" value="<%=(carregamanif ? manif.getFilialdestino().isCidadeAtendidas() : autenticado.getFilial().isCidadeAtendidas())%>">
                                                    <input name="fi_abreviatura2" id="fi_abreviatura2" type="text" size="12" class="inputReadOnly" readonly value="<%=(carregamanif ? manif.getFilialdestino().getAbreviatura() : autenticado.getFilial().getAbreviatura())%>">
                                                    <input name="fi_uf_destino" id="fi_uf_destino" type="text" size="1" class="inputReadOnly" readonly value="<%=(carregamanif ? manif.getFilialdestino().getCidade().getUf() : autenticado.getFilial().getCidade().getUf())%>">
                                                    <%if (acao.equals("iniciar")) {%>
                                                        <input name="localiza_filial2" type="button" class="inputBotaoMin" id="localiza_filial2" value="..." onClick="javascript:localizafilial2();">
                                                    <%}%>                                                    
                                                    <input name="fi_uf" id="fi_uf" type="hidden" size="1" class="inputReadOnly" readonly value="">
                                                    <input name="is_ativa_cidade" id="is_ativa_cidade" type="hidden" size="1" class="inputReadOnly" readonly value="">
                                                    <input type="hidden" id="fi_cidade" name="fi_cidade" value="<%= carregamanif ? manif.getFilial().getCidade().getDescricaoCidade() : autenticado.getFilial().getCidade().getDescricaoCidade() %>">
                                                </div>
                                                <div id="inp_rd" style="display: none">
                                                    <input name="redspt_rzs" id="redspt_rzs" type="text" size="12" class="inputReadOnly" readonly value="<%=(carregamanif ? manif.getRedespachante().getRazaosocial() : "")%>">
                                                    <input name="localiza_redespachante" type="button" class="inputBotaoMin" id="localiza_redespachante" value="..." onClick="javascript:localizaredespachante();">
                                                    <img id="botao_redspt" src="img/borracha.gif" border="0"  align="absbottom" class="imagemLink" onClick="limpaRedespachante();">
                                                     <input type="hidden" id="id_cidade_redespachante" name="id_cidade_redespachante" value="<%= carregamanif ? manif.getRedespachante().getCidade().getIdcidade() : autenticado.getFilial().getCidade().getIdcidade()%>">
                                                     <input type="hidden" id="nome_cidade_redespachante" name="nome_cidade_redespachante" value="<%= carregamanif ? manif.getRedespachante().getCidade().getDescricaoCidade() : autenticado.getFilial().getCidade().getIdcidade()%>">
                                                     <input type="hidden" id="uf_redespachante" name="uf_redespachante" value="<%= carregamanif ? manif.getRedespachante().getCidade().getUf() : autenticado.getFilial().getCidade().getUf()%>">
                                                </div>
                                            </td>
                                            <td class="TextoCampos">Previs&atilde;o chegada: </td>
                                            <td class="CelulaZebra2">
                                                <input name="dtprevista" type="text" id="dtprevista" value="<%=(carregamanif && manif.getDtprevista() != null ? formato.format(manif.getDtprevista()) : "")%>" size="9" maxlength="10"
                                                       onblur="alertInvalidDate(this,true)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" class="fieldDate"/>
                                                &agrave;s
                                                <input name="hrprevista" type="text" onkeyup="mascaraHora(this)" id="hrprevista" value="<%=(carregamanif ? manif.getHrprevista() : "")%>" size="4" maxlength="8" class="inputtexto">
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
                    
            <table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center"> 
                <tr class="tabela" id="">

                    <td id="tdAbaDadosPrincipais" class="menu-sel" onclick="AlternarAbasManifesto('tdAbaDadosPrincipais','tdCelDadosPrincipais')"> <center> Dados Principais </center></td>
                    <td id="tdAbaOcorrencia" class="menu" onclick="AlternarAbasManifesto('tdAbaOcorrencia','tdCelOcorrencia')"> Ocorrências</td>
                    <td id="tdAbaPallet" class="menu" onclick="AlternarAbasManifesto('tdAbaPallet','tdCelPallet')"> Pallet / Iscas </td>
                    <td id="tdAbaGerenciadorRisco" class="menu" onclick="AlternarAbasManifesto('tdAbaGerenciadorRisco','tdCelGerenciadorRisco')"> Averbação / Gerenciador de Risco </td>
                    <td id="tbGwMobile" class="menu_sel" width="10%" onclick="AlternarAbasManifesto('tbGwMobile','tab3')">GW Mobile</td>
                    <td style='display: <%= carregamanif && nivelUser == 4 ? "" : "none" %>' id="tdAbaAuditoria" class="menu" onclick="AlternarAbasManifesto('tdAbaAuditoria','tdCelAuditoria')">Auditoria</td>
                </tr>
            </table>
            
          
            <table id="tdCelDadosPrincipais" width="90%" border="0" align="center" cellpadding="0" cellspacing="0" class="bordaFina">
                <tr>
                    <td> 
                        <table width="100%" border="0" cellpadding="0" cellspacing="1">        
                            <tr class="tabela">
                                <td colspan="7"> 
                                    <div align="center">
                                        <label id="tit_a" name="tit_a">Relação dos CT-e(s) Deste Manifesto</label>
                                    </div>
                                </td>
                            </tr>
                            <tr class="CelulaZebra2" colspan="8" style="display:<%= ((carregamanif) && (cadmanif.isExisteCartaFrete())) == true ? "none" : "" %>">
                                <td>
                                    <%if (carregamanif && !acao.equals("iniciar")) {%>
                                        <%if (nivelUser >= 2 && (nivelMDFeCOnfirmado == 4 || manif.getStatusManifesto() == null || !Apoio.in(manif.getStatusManifesto(), "L", "C", "R"))) {%>
                                            <input name="selecionarctrc" type="button" class="botoes" id="selecionarctrc" value="Selecionar CT-e(s)" onClick="javascript:tryRequestToServer(function(){selecionar_rc($('qtdLinhasCTe').value,'<%=acao%>');});">
                                            <label id="lbmostratudo" name="lbmostratudo">
                                                <input name="mostratudo" type="checkbox" <%=cfg.isManifestarCtrcVariasVezes() ? "" : "disabled"%> id="mostratudo" value="checkbox">
                                                Mostrar CT-e(s) j&aacute; Manifestados
                                            </label>
                                        <%}%>
                                    <%} else {%>
                                            <input name="selecionarctrc" type="button" class="botoes" id="selecionarctrc" value="Selecionar CT-e(s)" onClick="javascript:tryRequestToServer(function(){selecionar_rc($('qtdLinhasCTe').value,'<%=acao%>');});">
                                            <label id="lbmostratudo" name="lbmostratudo">
                                                <input name="mostratudo" type="checkbox" <%=cfg.isManifestarCtrcVariasVezes() ? "" : "disabled"%> id="mostratudo" value="checkbox">
                                                Mostrar CT-e(s) j&aacute; Manifestados
                                            </label>
                                    <%}%>
                                    &nbsp;
                                    &nbsp;
                                    &nbsp;
                                    &nbsp;
                                    Tipo:
                                    <select id="tipoConsulta" onChange="alteraTipoConsulta(this.value)" class="inputtexto" style="width: 110px">
                                        <option value="CTRC" selected>CT-e</option>
                                        <option value="CHAVE_CTE">Chave de Acesso CT-e</option>
                                        <option value="N_LOCALIZADOR">Nº Localizador</option>
                                    </select>
                                    <label id="lblChaveAcesso" style="display: none">
                                        Chave de Acesso:
                                    </label>
                                    <label id="lblSerieNumero">
                                        Série/Número:
                                    </label>
                                    <label id="lblNumeroLocalizador" style="display: none">
                                        Nº Localizador:
                                    </label>
                                    <label id="lblInpChaveAcesso" style="display: none">
                                        <!--<input name="chaveAcesso" type="text" class="inputtexto" id="chaveAcesso" size="44" maxlength="44" value="" onKeyPress="mascara(this, soNumeros); if (event.keyCode==13) incluirCTeManifestoAjax(this,'<%=acao%>');"/>-->                                        
                                        <input name="chaveAcesso" type="text" class="inputtexto" id="chaveAcesso" size="44" maxlength="44" value="" onKeyPress="mascara(this, soNumeros); if (event.keyCode==13) adicionarCTeManifesto();"/>                                        
                                    </label>
                                    <label id="lblInpSerieNumero">
                                        <input name="serieConsulta" type="text" class="inputtexto" id="serieConsulta" size="1" onchange="toUpperCase(this.value);" value="<%=String.valueOf(autenticado.getFilial().getStUtilizacaoCte()).equals("N") ? cfg.getSeriePadraoCtrc() : "1"%>"/>
                                        <b>&nbsp;/&nbsp;</b>
                                    </label>
                                    <label id="lblInpNumeroConsulta">
                                        <!--<input name="numeroConsulta" type="text" class="inputtexto" id="numeroConsulta" size="7" value="" onKeyPress="mascara(this, soNumeros); if (event.keyCode==13) incluirCTeManifestoAjax(this,'<%=acao%>');"/>-->
                                        <input name="numeroConsulta" type="text" class="inputtexto" id="numeroConsulta" size="7" value="" onKeyPress="mascara(this, soNumeros); if (event.keyCode==13) adicionarCTeManifesto();"/>
                                    </label> 
                                    <label id="lblInpNumeroLocalizador">
                                        <input name="numeroLocalizador" type="text" class="inputtexto" id="numeroLocalizador" size="20" maxlength="20" value="" onKeyPress="mascara(this, soNumeros); if (event.keyCode==13) adicionarCTeManifesto();"/>
                                    </label>
                                                                            
                                        <input id="btAddCTe" name="btAddCTe" type="button" class="botoes" value="Adicionar" onClick="adicionarCTeManifesto();">                                        
                                </td>
                            </tr>
                            <tr>
                                <td colspan="7">
                                    <table width="100%" border="0" cellpadding="0" cellspacing="1">
                                            <!--<tbody>-->
                                            <tr class="Celula">
                                                <td width="7%" class="Celula">
                                                    <div align="center">Emiss&atilde;o</div>
                                                </td>
                                                <td width="5%" class="Celula">
                                                    <div align="center">CT-e</div>
                                                </td>
                                                <td width="16%" class="Celula">
                                                    <div align="center">Remetente</div>
                                                </td>
                                                <td width="9%" class="Celula">
                                                    <div align="center">Origem</div>
                                                </td>
                                                <td width="16%" class="Celula">
                                                    <div align="center">Destinat&aacute;rio</div>
                                                </td>
                                                <td width="9%" class="Celula">
                                                    <div align="center">Destino</div>
                                                </td>
                                                <td width="5%" class="Celula">
                                                    <div align="center">Vol(s)</div>
                                                </td>
                                                <td width="5%" class="Celula">
                                                    <div align="center">Vol(s) Real</div>
                                                </td>
                                                <td width="6%" class="Celula">
                                                    <div align="center">Peso</div>
                                                </td>
                                                <td width="6%" class="Celula">
                                                    <div align="center">Peso Real</div>
                                                </td>
                                                <td width="7%" class="Celula">
                                                    <div align="center">R$ NF(s)</div>
                                                </td>
                                                <td width="7%" class="Celula">
                                                    <div align="center">R$ Frete</div>
                                                </td>
                                                <td width="2%" class="Celula">
                                                    <div align="center" id="divPin" name="divPin">PIN</div>
                                                </td>
                                            </tr>
                                            <input id="cidadesDestinosCte" name="cidadesDestinosCte" type="hidden" value="">
                                            <tbody style="display: none" id="tbodyCTeManifesto" name="tbodyCTeManifesto"></tbody>
                                            <!--< % //variaveis da paginacao
                                        
                                                boolean ctrcBaixado = false;
                                                if (carregamanif) {
                                                    //Percorrendo o vetor
                                                    for (linha = 0; linha <= manif.getCtrc().length - 1; ++linha) {
                                                        ctrcBaixado = (ctrcBaixado ? true : manif.getCtrc()[linha].isRedespachoPago());
                                                        NotaFiscal nfTotal = ((NotaFiscal) manif.getCtrc()[linha].getNotasfiscais().get(0));
                                                      
                                            %>
                                            <tr class="< %=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                                                <td>
                                                    <div align="center">
                                                        <input name="< %="linha-" + linha%>" id="< %="linha-" + linha%>" type="hidden" value="< %=manif.getCtrc()[linha].getId()%>">
                                                        < %=(manif.getCtrc()[linha].getEmissaoEm() != null ? formato.format(manif.getCtrc()[linha].getEmissaoEm()) : "")%>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div align="center" class="linkEditar" onClick="javascript:tryRequestToServer(function(){verCtrc('< %=manif.getCtrc()[linha].getId()%>');});">< %=manif.getCtrc()[linha].getNumero()%></div>
                                                </td>
                                                <td colspan="2">
                                                    <div align="center">< %=manif.getCtrc()[linha].getRemetente().getRazaosocial()%></div>
                                                </td>
                                                <td colspan="2">
                                                    <div align="center">< %= manif.getCtrc()[linha].getCidadeOrigem().getDescricaoCidade()%>-< %= manif.getCtrc()[linha].getCidadeOrigem().getUf()%></div>
                                                </td>
                                                <td colspan="2">
                                                    <div align="center">< %=manif.getCtrc()[linha].getDestinatario().getRazaosocial()%></div>
                                                </td>
                                                <td colspan="2">
                                                    <div align="center">< %= manif.getCtrc()[linha].getCidadeDestino().getDescricaoCidade()%>-< %= manif.getCtrc()[linha].getCidadeDestino().getUf()%></div>
                                                </td>
                                                <td>
                                                    <div align="right">< %=Apoio.to_curr(nfTotal.getVolume())%></div>
                                                </td>
                                                <td>
                                                    <div align="right">
                                                    <input size="6" style="text-align: right" onblur="seNaoFloatReset(this, '0.00'), calcularVolumeReal()" name="volumeReal_< %=linha%>" id="volumeReal_< %=linha%>" class="inputTexto" value="< %= Apoio.to_curr(nfTotal.getConhecimento().getVolumeReal() )%>" />
                                                    </div>
                                                </td>
                                                <td>
                                                    <div align="right">
                                                        < %=Apoio.to_curr(nfTotal.getPeso())%>
                                                        <input type="hidden" name="peso< %=linha%>" id="peso< %=linha%>" value="< %=Apoio.to_curr(nfTotal.getPeso())%>">
                                                    </div>
                                                </td>
                                                <td>
                                                    <div align="right">
                                                    <input size="6" style="text-align: right" name="pesoReal_< %=linha%>" onblur="seNaoFloatReset(this, '00.0'), calcularPesoReal();" id="pesoReal_< %=linha%>" class="inputTexto" value="< %= nfTotal.getConhecimento().getPesoReal() %>" />
                                                    </div>
                                                </td>
                                                <td>
                                                    <div align="right">< %=Apoio.to_curr(nfTotal.getValor())%></div>
                                                </td>
                                                <td>
                                                    <div align="right">< %=Apoio.to_curr(manif.getCtrc()[linha].getVltotal())%></div>
                                                </td>
                                                <td>
                                                    <div align="right"><input name="isPin< %=linha%>" type="checkbox" id="isPin< %=linha%>" value="checkbox" alt="Gerar PIN para o SUFRAMA" < %= (nfTotal.getConhecimento().isGeraPinSuframa() ? "checked" : "") %>></div>
                                                </td>
                                            </tr>
                                            < %
                                                        qtd = qtd + nfTotal.getVolume();
                                                        peso = peso + nfTotal.getPeso();
                                                        pesoReal = pesoReal + nfTotal.getConhecimento().getPesoReal();
                                                        volumeReal = volumeReal + nfTotal.getConhecimento().getVolumeReal();
                                                        notas = notas + (float) nfTotal.getValor();
                                                        frete = frete + manif.getCtrc()[linha].getVltotal();
                                                    }//For
                                                    manif.setVltotalnf(notas);
                                                }
                                            %>
                                        </tbody>-->
                                        <tbody>
                                            <tr >
                                                <td class="TextoCampos">
<!--                                                    <div align="left" >
                                                        < %if (carregamanif && !acao.equals("iniciar")) {%>
                                                            < %if (nivelUser >= 2 && (nivelMDFeCOnfirmado == 4 || manif.getStatusManifesto() == null || !Apoio.in(manif.getStatusManifesto(), "L", "C", "R"))) {%>
                                                                <input name="selecionarctrc" type="button" class="botoes" id="selecionarctrc" value="Selecionar CT-e(s)" onClick="javascript:tryRequestToServer(function(){selecionar_rc($('qtdLinhasCTe').value,'< %=acao%>');});">
                                                                <input name="mostratudo" type="checkbox" id="mostratudo" value="checkbox">
                                                                <label id="lbmostratudo" name="lbmostratudo">Mostrar CT-e(s) j&aacute; Manifestados</label>
                                                            < %}%>
                                                        < %} else {%>                                                            
                                                                <input name="selecionarctrc" type="button" class="botoes" id="selecionarctrc" value="Selecionar CT-e(s)" onClick="javascript:tryRequestToServer(function(){selecionar_rc($('qtdLinhasCTe').value,'< %=acao%>');});">
                                                                <input name="mostratudo" type="checkbox" id="mostratudo" value="checkbox">
                                                                <label id="lbmostratudo" name="lbmostratudo">Mostrar CT-e(s) j&aacute; Manifestados</label>
                                                        < %}%>
                                                    </div>  -->
                                                </td>
                                                <td class="TextoCampos"></td>
                                                <td class="TextoCampos"></td>
                                                <td class="TextoCampos"></td>
                                                <td class="TextoCampos">
                                                    <strong>Totais:</strong>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <div align="right">
                                                        <strong>
                                                            <label id="quantidade_linha"> </label><label> CT-e(s)</label>
                                                        </strong>
                                                    </div>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <div align="right">
                                                        <strong>
                                                            <label id="quantidade"> </label>
                                                        </strong>
                                                    </div>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <div align="right">
                                                        <strong>
                                                            <label id="totalVolumeReal"></label>
                                                        </strong>
                                                    </div>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <div align="right">
                                                        <strong>
                                                            <label id="peso"></label>
                                                        </strong>
                                                    </div>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <div align="right">
                                                        <strong>
                                                            <label id="totalPesoReal"></label>
                                                        </strong>
                                                    </div>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <div align="right">
                                                        <strong>
                                                            <label id="total_notas" name="total_notas"></label>
                                                        </strong>
                                                    </div>
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <div align="right">
                                                        <strong>
                                                            <label id="frete"></label>
                                                        </strong>
                                                    </div>
                                                </td>
                                                <td class="CelulaZebra2">
                                                </td>
                                            </tr>
<!--                                            <tr style="display: none">
                                                 <td class="TextoCampos" colspan="4">
                                                    <div align="left" >
                                                        < %if (carregamanif && !acao.equals("iniciar")) {%>
                                                            < %if (nivelUser >= 2 && (nivelMDFeCOnfirmado == 4 || manif.getStatusManifesto() == null || !Apoio.in(manif.getStatusManifesto(), "L", "C", "R"))) {%>
                                                                <input name="selecionarctrc" type="button" class="botoes" id="selecionarctrc" value="Selecionar CT-e(s)" onClick="javascript:tryRequestToServer(function(){selecionar_rc(<%=linha%>,'<%=acao%>');});">
                                                                <input name="mostratudo" type="checkbox" id="mostratudo" value="checkbox">
                                                                <label id="lbmostratudo" name="lbmostratudo">Mostrar CT-e(s) j&aacute; Manifestados</label>
                                                            < %}%>
                                                        < %} else {%>
                                                            <input name="selecionarctrc" type="button" class="botoes" id="selecionarctrc" value="Selecionar CT-e(s)" onClick="javascript:tryRequestToServer(function(){selecionar_rc(<%=linha%>,'<%=acao%>');});">
                                                            <input name="mostratudo" type="checkbox" id="mostratudo" value="checkbox">
                                                            <label id="lbmostratudo" name="lbmostratudo">Mostrar CT-e(s) j&aacute; Manifestados</label>
                                                        < %}%>
                                                    </div>  
                                                        </td>
                                               <td class="TextoCampos"  >
                                                    Chave de Acesso:
                                                </td>
                                                </td>
                                                <td class="CelulaZebra2" colspan="2">
                                                    <input name="chaveacesso" type="text" class="inputtexto" id="chaveacesso" size="44" maxlength="44" value="" onKeyPress="mascara(this, soNumeros)">
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <label id="lbSerie">Série/Número:
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <input name="serieConsulta" type="text" class="inputtexto" id="serieConsulta" size="1" value="< %=String.valueOf(autenticado.getFilial().getStUtilizacaoCte()).equals("N") ? cfg.getSeriePadraoCtrc() : "1"%>"><b>&nbsp;/</b></label>
                                                    <input name="numeroConsulta" type="text" class="inputtexto" id="numeroConsulta" size="7" value="" onKeyPress="mascara(this, soNumeros)">                                                
                                                </td>
                                                <td class="CelulaZebra2">
                                                    <input id="btAddctrc2" type="button" class="botoes" value="OK" onClick="showNumCtrcs()"></td>
                                                <td class="CelulaZebra2"><input id="btFim" type="button" class="botoes" value="Finalizar" onClick="pesquisarCtrcManifesto('< %=acao%>')"></td>
                                                <td class="CelulaZebra2"></td>
                                                <td class="CelulaZebra2"></td>
                                                <td class="CelulaZebra2"></td>
                                             </tr>-->
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                              <tr class="Celula">
                    <td colspan="3">Trecho</td>
                </tr>    
                <tr>
                    <td colspan="3">
                        <table width="100%">
                            <tr>
                                <td width="10%" class="TextoCampos">Cidade de Origem:</td>
                                <td width="30%" class="CelulaZebra2"> 
                                        <input name="cidadeOrigem" type="text" id="cidadeOrigem" class="inputReadOnly" value="<%=(carregamanif ? manif.getCidadeorigem().getCidade() : autenticado.getFilial().getCidade().getDescricaoCidade())%>" size="15" readonly="true">
                                        <input name="ufOrigem" type="text" id="ufOrigem" class="inputReadOnly" value="<%=(carregamanif ? manif.getCidadeorigem().getUf() : autenticado.getFilial().getCidade().getUf())%>" size="2" readonly>
                                        <input type="hidden" name="cidadeOrigemId" id="cidadeOrigemId" value="<%=(carregamanif ? manif.getCidadeorigem().getIdcidade() : autenticado.getFilial().getCidade().getIdcidade())%>">
                                        <input name="localiza_cid_origem" type="button" class="inputBotaoMin" <%=(carregamanif ? manif.getStatusManifesto().charAt(0) == 'C' ? "disabled" : "" : "")%> id="localiza_cid_origem" value="..." onClick="javascript:localizacid_origem();">
                                        
                                        <label id="lblEnderecoSaidaBuonny" style="display: none">End.:</label>
                                        <select id="slcEnderecoSaidaBuonny" name="slcEnderecoSaidaBuonny" class="inputtexto" style="width:100px; display: none"></select>
                                </td>
                                <td width="10%" class="TextoCampos">Cidade de Destino:</td>
                                <td width="20%" class="CelulaZebra2"> 
                                        <input name="cid_destino" type="text" id="cid_destino" class="inputReadOnly" value="<%=(carregamanif ? manif.getCidadedestino().getCidade() : autenticado.getFilial().getCidade().getDescricaoCidade())%>" size="15" readonly="true">
                                        <input name="uf_destino" type="text" id="uf_destino" class="inputReadOnly" value="<%=(carregamanif ? manif.getCidadedestino().getUf() : autenticado.getFilial().getCidade().getUf())%>" size="2" readonly="true">
                                        <input name="localiza_cid_destino" type="button" class="inputBotaoMin" id="localiza_cid_destino" <%=(carregamanif ? manif.getStatusManifesto().charAt(0) == 'C' ? "disabled" : "" :  "")%> value="..." onClick="javascript:localizacid_destino();">
                                </td>
                                <td width="9%" class="TextoCampos">Rota (MDF-e):</td>
                                <td width="26%" class="CelulaZebra2"> 
                                        <select id="rota" style="width: 120px" name="rota" class="inputTexto" onchange="getRotaPercurso();" />
                                            <option value="">----Selecione-----</option>
                                            <%for (Rota rota : rotas){%>
                                                <option value="<%=rota.getId()%>" <%=(carregamanif && manif.getRota().getId() == rota.getId() ? "selected" : "")%> ><%=rota.getDescricao()%></option>
                                            <%}%>
                                        </select>
                                        <select id="percurso" style="width: 100px" name="percurso" class="inputTexto" />
                                        </select>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr id="tr_lbmotorista" name="tr_lbmotorista">
                    <td colspan="3" class="tabela"> 
                        <div align="center">Dados Motorista (Rodoviário)</div>
                    </td>
                </tr>
                <tr id="tr_motorista" name="tr_motorista">
                    <td colspan="3">
                        <table width="100%">
                            <tr>
                                <td width="8%" class="TextoCampos">
                                    <label id="lbMotorista" name="lbMotorista">Motorista:</label>
                                </td>
                                <td width="20%" class="CelulaZebra2">
                                    <input name="nomeMotorista" type="text" id="nomeMotorista" class="inputReadOnly" value="<%=(carregamanif ? manif.getMotorista().getNome() : "")%>" size="30" readonly="true">
                                        <input name="localiza_motorista" type="button" class="inputBotaoMin" id="localiza_motorista" value="..." onClick="javascript:localizamotorista();">
                                        <img src="img/page_edit.png" border="0" onClick="javascript:verMotorista();"
                                             title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                        <input name="motor_vencimentocnh" type="hidden" id="motor_vencimentocnh" style="background-color:#FFFFF1" value="<%=(carregamanif && manif.getMotorista().getVencimentocnh() != null ? formato.format(manif.getMotorista().getVencimentocnh()) : "")%>" size="15" readonly="true">
                                </td> 
                                <td width="8%" class="TextoCampos">
                                    <label id="TDLabelLiberacaoMotorista">Nº Liberação:</label>
                                </td>
                                <td width="20%" class="CelulaZebra2">
                                    <input name="" type="text" id="motoristaLiberacao"  value="<%=(carregamanif ? (manif.getLibmotorista() != null ? manif.getLibmotorista() : "") : "")%>" size="30" maxlength="20" class="inputtexto" <%=(carregamanif && manif.getMotorista().getTipo().equals("c") ? "" : "disabled" )%> >
                                </td> 
                                <td width="8%" class="TextoCampos">Agente Carga:</td>
                                <td width="31%" class="CelulaZebra2" colspan="3">
                                    <input name="nome_agente_carga" type="text" id="nome_agente_carga" class="inputReadOnly" value="<%=(carregamanif ? manif.getAgenteCarga().getRazaosocial() : "")%>" size="30" readonly="true">
                                    <input name="localiza_agente_carga" type="button" class="inputBotaoMin" id="localiza_agente_carga" value="..." onClick="javascript:localizaAgente();">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Agente de Carga" onClick="javascript:getObj('idagente_carga').value = 0;javascript:getObj('nome_agente_carga').value = '';">
                                    <input type="hidden" id="idagente_carga" name="idagente_carga" value="<%=(carregamanif ? manif.getAgenteCarga().getIdfornecedor() : "0")%>">
                                </td> 
                            </tr>
                            <tr>
                                <td class="TextoCampos">
                                    <label id="lbVeiculo" name="lbVeiculo">Ve&iacute;culo:</label>
                                </td>
                                <td class="CelulaZebra2">
                                    <input name="veiculoPlaca" type="text" id="veiculoPlaca" class="inputReadOnly" size="7" value="<%=(carregamanif ? manif.getCavalo().getPlaca() : "")%>" readonly="true">
                                    <strong>
                                        <input name="localiza_cavalo" type="button" class="inputBotaoMin" id="localiza_cavalo" value="..." onClick="javascript:localizacavalo();">
                                        <img src="img/page_edit.png" border="0" onClick="javascript:verVeiculo('V');"
                                             title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                    </strong>
                                </td>
                                <td class="TextoCampos">
                                    <label id="lbCarreta" name="lbCarreta">Carreta:</label>
                                </td>
                                <td class="CelulaZebra2">
                                    <input name="carretaPlaca" type="text" id="carretaPlaca" class="inputReadOnly" value="<%=(carregamanif && manif.getCarreta().getPlaca() != null ? manif.getCarreta().getPlaca() : "")%>" size="7" readonly="true">
                                    <strong>
                                        <input name="localiza_carreta" type="button" class="inputBotaoMin" id="localiza_carreta" value="..." onClick="javascript:localizacarreta();">
                                        <strong>
                                            <img id="imgCarreta" name="imgCarreta" src="img/page_edit.png" border="0" onClick="javascript:verVeiculo('C');"
                                                title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; "><img src="img/borracha.gif" id="borrachaCarreta" name="borrachaCarreta" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('carretaPlaca').value='';getObj('carretaID').value=0;">
                                        </strong>
                                    </strong>
                                </td>
                                <td class="TextoCampos">
                                    <label id="lbBi" name="lbBi">Bi-Trem:</label>
                                </td>
                                <td class="CelulaZebra2">
                                    <label id="lbBiTrem" name="lbBiTrem">
                                        <input name="bitremPlaca" type="text" id="bitremPlaca" class="inputReadOnly" value="<%=(carregamanif && manif.getBiTrem().getPlaca() != null ? manif.getBiTrem().getPlaca() : "")%>" size="7" readonly="true">
                                        <strong>
                                            <input name="localiza_bitrem" type="button" class="inputBotaoMin" id="localiza_bitrem" value="..." onClick="javascript:localizabitrem();">
                                            <strong>
                                                <img id="imgCarreta2" name="imgCarreta" src="img/page_edit.png" border="0" onClick="javascript:verVeiculo('B');"
                                                    title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('bitremPlaca').value='';getObj('bitremID').value=0;">
                                            </strong>
                                        </strong>
                                    </label>
                                </td>
                                <td class="TextoCampos">
                                    <label id="lbTri" name="lbTri">3º Reboque:</label>
                                </td>
                                <td class="CelulaZebra2">
                                    <label id="lbTriTrem" name="lbTriTrem">
                                        <input name="tritremPlaca" type="text" id="tritremPlaca" class="inputReadOnly" value="<%=(carregamanif && manif.getTriTrem().getPlaca() != null ? manif.getTriTrem().getPlaca() : "")%>" size="7" readonly="true">
                                        <strong>
                                            <input name="localiza_tritrem" type="button" class="inputBotaoMin" id="localiza_tritrem" value="..." onClick="javascript:localizatritrem();">
                                            <strong>
                                                <img id="imgCarreta3" name="imgCarreta" src="img/page_edit.png" border="0" onClick="javascript:verVeiculo('T');"
                                                    title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('tritremPlaca').value='';getObj('tritremID').value=0;">
                                            </strong>
                                        </strong>
                                    </label>
                                </td>
                            </tr>
                        </table>
                        
                    </td>
                </tr>
                <tr id="trTrip1">
                    <td colspan="6"  class="tabela">
                        <div align="center">Dados dos Tripulantes</div>
                    </td>
                </tr>
                <tr id="trTrip2">
                    <td colspan="6" >
                        <table width="100%" border="0">
                            <tbody id="corpoTrib">
                                <tr class="Celula">
                                    <td width="3%">
                                        <div align="center">
                                            <img src="img/add.gif" border="0" title="Adicionar Tripulantes" class="imagemLink"
                                                 onClick="launchPopupLocate('./localiza?acao=consultar&idlista=49','Tripulante');">                                                
                                        </div>                                            
                                    </td>
                                    <td width="70%">
                                        <div align="left">
                                            Nome                                                
                                        </div>                                            
                                    </td>
                                    <td width="30%">
                                        <div align="left">Fun&ccedil;&atilde;o</div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>                            
                    </td>
                </tr>
                 <tr id="tr_companhia">
                     <td colspan="3">
                        <table class="bordaFina" width="100%">
                            <tr>
                                <td colspan="8" class="tabela"><div align="center">Dados Do AWB (Aéreo)</div></td>
                            </tr>
                            <tr>
                                <td width="10%" class="TextoCampos">Número AWB:</td>
                                <td width="23%" class="CelulaZebra2">
                                    <input type="text" name="numeroAWB" id="numeroAWB" maxlength="20" size="20" class="inputTexto" value="<%=(carregamanif ? awb.getNumeroAWB():"")%>">
                                </td>
                                <td width="11%" class="TextoCampos">Número CT-e:</td>
                                <td width="23%" class="CelulaZebra2">
                                    <input type="text" name="numeroCTE" id="numeroCTE" maxlength="20" size="20" class="inputTexto" value="<%=(carregamanif ? awb.getNumero():"")%>">
                                </td>
                                <td width="10%" class="TextoCampos">Chave CT-e:</td>
                                <td width="23%" class="CelulaZebra2">
                                    <input type="text" name="chaveCTE" id="chaveCTE" maxlength="44" size="40" class="inputTexto" value="<%=(carregamanif ? awb.getChaveAcessoAwb():"")%>">
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Emissão CT-e:</td>
                                <td class="CelulaZebra2">
                                    <input name="emissaoEm" type="text" id="emissaoEm" value="<%=carregamanif ? awb.getEmissaoEmStr() : Apoio.getDataAtual()%>" size="9" maxlength="10" class="fieldDate" onblur='alertInvalidDate(this,true)' >
                                    &agrave;s
                                    <input name="emissaoAs" type="text" onkeyup="mascaraHora(this)" id="emissaoAs" value="<%=(carregamanif ? (awb.getEmissaoAs() == null ? "" : awb.getEmissaoAs()) : hora)%>" size="4" maxlength="8" class="inputtexto">
                                </td>
                                <td class="TextoCampos">CFOP:</td>
                                <td class="CelulaZebra2">
                                    <input type="hidden" name="idcfop" id="idcfop" value="<%=(carregamanif ? String.valueOf(awb.getCfop().getIdcfop()) : "0")%>">
                                    <input name="cfop" type="text" id="cfop" size="5" maxlength="5" readonly value="<%=(carregamanif ? awb.getCfop().getCfop() : "")%>" class="inputReadOnly">
                                    <input name="localiza_cfop" type="button" class="inputBotaoMin" id="localiza_cfop" value="..." onClick="javascript:localizacfop();">
                                    <img src="img/borracha.gif" border="0" class="imagemLink" onClick="javascript:$('idcfop').value='0';$('cfop').value='';">
                                </td>
                                <td class="TextoCampos"></td>
                                <td class="CelulaZebra2"></td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Companhia Aérea:</td>
                                <td class="CelulaZebra2">
                                    <input name="companhia_aerea" type="text" id="companhia_aerea" class="inputReadOnly" value="<%=(carregamanif ? awb != null ? awb.getCompanhiaAerea().getRazaosocial() :"" :"")%>" size="30" readonly="true">
                                    <input name="localiza_companhia" type="button" class="inputBotaoMin" id="localiza_companhia" value="..." onClick="javascript:localizaCompanhiaAerea();">
                                    <input type="hidden" id="aeroporto" name="aeroporto" value="">
                                    <input type="hidden" id="aeroporto_id" name="aeroporto_id" value="">
                                </td>
                                <td class="TextoCampos">Aeroporto Origem:</td>
                                <td class="CelulaZebra2">
                                    <input name="aeroportoColeta" id="aeroportoColeta" class="inputReadOnly" value="<%=(carregamanif ? awb.getAeroportoOrigem().getNome() : "")%>" size="20" readonly="true"/>
                                    <input name="btAero" type="button" id="btAero" class="inputBotaoMin" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=73', 'Aeroporto_Coleta')" style="text-align: center"/>
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaAeroportoColeta();">
                                    <input name="aeroportoColetaId" id="aeroportoColetaId" type="hidden" value="<%=(carregamanif ? awb.getAeroportoOrigem().getId() : "0")%>"/>
                                </td>
                                <td class="TextoCampos">Aeroporto Destino:</td>
                                <td class="CelulaZebra2">
                                    <input name="aeroportoEntrega" id="aeroportoEntrega" class="inputReadOnly" value="<%=(carregamanif ? awb.getAeroportoDestino().getNome() : "")%>" size="20" readonly="true"/>
                                    <input name="btAero" type="button" id="btAero" class="inputBotaoMin" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=73', 'Aeroporto_Entrega')" onchange="validaCidadesatendidasAeroporto()" style="text-align: center"/>
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaAeroportoEntrega()">
                                    <input name="aeroportoEntregaId" id="aeroportoEntregaId" type="hidden" value="<%=(carregamanif ? awb.getAeroportoDestino().getId() : "0")%>"/>
                                    <input name="idCidadesAtendidasAeroporto" id="idCidadesAtendidasAeroporto" type="hidden" value="<%=(carregamanif && awb.getAeroportoDestino().getIdsCidadeAtendida() != null ? awb.getAeroportoDestino().getIdsCidadeAtendida() : "0")%>"/>
                                    <input name="cidades_atendidas_id" id="cidades_atendidas_id" type="hidden">
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Nº Vôo:</td>
                                <td class="CelulaZebra2">
                                    <input type="text" name="numeroVoo" id="numeroVoo" maxlength="10" size="10" class="inputTexto" value="<%=(carregamanif ? awb.getNumeroVoo():"")%>">
                                </td>
                                <td class="TextoCampos">Previsão Embarque:</td>
                                <td class="CelulaZebra2">
                                    <input name="previsaoEmbarqueEm" type="text" id="previsaoEmbarqueEm" onblur="alertInvalidDate(this,true)" value="<%=(carregamanif && awb.getPrevisaoEmbarqueEm() != null ? formato.format(awb.getPrevisaoEmbarqueEm()) : "")%>" size="9" maxlength="10" class="fieldDate">
                                    &agrave;s
                                    <input name="previsaoEmbarqueAs" type="text" onkeyup="mascaraHora(this)" id="previsaoEmbarqueAs" value="<%=(carregamanif && awb.getPrevisaoEmbarqueAs() != null ? awb.getPrevisaoEmbarqueAs() : "")%>" size="4" maxlength="8" class="inputtexto">
                                </td>
                                <td class="TextoCampos">Matrícula / País da aeronave:</td>
                                <td class="CelulaZebra2">
                                    <input type="text" name="matriculaAero" id="matriculaAero" maxlength="10" size="10" class="inputTexto" value="<%=(carregamanif ? awb.getMatriculaAeronave():"")%>"> / 
                                    <input type="text" name="nacAero" id="nacAero" maxlength="3" size="3" class="inputTexto" value="<%=(carregamanif ? awb.getNacAeronave():"")%>">
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Qtd de Volumes:</td>
                                <td class="CelulaZebra2">
                                    <input id="volumesAWB" name="volumesAWB" size="10" maxlength="10" onblur="seNaoFloatReset(this,'0.00');" class="inputtexto" value="<%=(carregamanif ? vlrformat.format(awb.getVolumes()) : "0.00")%>" />
                                </td>
                                <td class="TextoCampos">Peso Taxado:</td>
                                <td class="CelulaZebra2">
                                    <input id="pesoAWB" name="pesoAWB" size="10" maxlength="10" onblur="seNaoFloatReset(this,'0.000');" class="inputtexto" value="<%=(carregamanif ? vlrformat.format(awb.getPesoTaxado()) : "0.000")%>" />
                                </td>
                                <td class="TextoCampos">Nº da Despesa:</td>
                                <td class="CelulaZebra2">
                                    <%if(carregamanif && awb != null && awb.getDespesa().getIdmovimento() != 0){%>
                                        <b><%=awb.getDespesa().getIdmovimento()%></b>
                                    <%}%>
                                </td>
   <!--Adicionando novos campos no AWB  -->
                                 <tr>
                                <td class="TextoCampos">Tipo de Produto/Operação:</td>
                                <td class="CelulaZebra2" >
                                    <select name="tipo_produto_operacao" id="tipo_produto_operacao" class="inputtexto">
                                        <option value="0" selected="selected">Selecione</option>
                                        <%for (TipoProduto p : productTypesAereo) {%>
                                                <option value="<%=p.getId()%>" <%=( carregamanif && (awb.getTipoProdutoOperacaoId() == p.getId())? "selected": "")  %> ><%=p.getDescricao()%></option>
                                         <%}%>
                                    </select> 
                                </td>
                                <td class="TextoCampos" id="lbTipoPg" name="lbTsipoPg" >
                                   Tipo de Pagamento:
                                </td>
                                <td class="CelulaZebra2">
                                    <select name="tipoPg" id="tipoPg" class="inputtexto">
                                        <option value="0" selected="selected">Selecione</option>
                                        <option value="1" <%= (carregamanif  && awb.getTipoPagamento() == 1 ? "selected" : "")%>>Pago na origem</option>
                                        <option value="2" <%= (carregamanif  && awb.getTipoPagamento() == 2 ? "selected" : "")%>>A pagar no destino</option>
                                        <option value="3" <%= (carregamanif  && awb.getTipoPagamento() == 3 ? "selected" : "")%>>Débito em C/C</option>
                                    </select> 
                                </td>
                                <td class="TextoCampos">
                                   Tipo de Entrega:  
                                </td>
                                <td class="CelulaZebra2">
                                    <select name="tipoRetirada" id="tipoRetirada"  class="inputtexto">
                                        <option value="0" selected="selected">Selecione</option>
                                        <option value="1" <%= (carregamanif  && awb.getTipoEntrega() == 1 ? "selected" : "")%>>Retira no aeroporto</option>
                                        <option value="2" <%= (carregamanif  && awb.getTipoEntrega() == 2 ? "selected" : "")%>>Entrega Domiciliar</option> 
                                    </select> 
                                </td>
                            </tr>
                            <tr>
                               <td class="TextoCampos">
                                   Tipo de Embalagem:
                               </td>
                               <td class="CelulaZebra2">
                                    <select name="tipoEmbalagem" id="tipoEmbalagem"  class="inputtexto">
                                       <option value="0" selected="selected">Selecione</option>
                                        <% for (Embalagem e : embalagemLista) {%>
                                        <option value="<%= e.getId()%>" <%=(carregamanif && ( awb.getTipoEmbalagemId() == e.getId() ) ? "selected" : "") %>><%= e.getDescricao()%></option> 
                                        <%}%>
                                    </select> 
                               </td>
                                <td class="TextoCampos" >Descrição do conteúdo:</td>
                                <td class="CelulaZebra2" rowspan="4">
                                    <textarea  cols="80" rows="5" id="conteudoDes"  name="conteudoDes" class="fieldMin" ><%=((carregamanif) && (awb.getDescricaoConteudo() != null) ? awb.getDescricaoConteudo() : "")%></textarea>
                                </td>
                                <td class="CelulaZebra2"></td>
                                <td class="CelulaZebra2"></td>
                            </tr>
                        </table>                            
                    </td>
                </tr>
                <tr id="tr_valorAWB">
                    <td colspan="3">
                        <table class="bordaFina" width="100%">
                            <tr>
                                <td colspan="8" class="tabela"><div align="center">Valores do AWB (Aéreo)</div></td>
                            </tr>
                            <tr>
                                <td width="10%" class="TextoCampos">Tarifa Específica:</td>
                                <td width="23%" class="CelulaZebra2">
                                    <select name="tarifaEspecifica" id="tarifaEspecifica" class="inputtexto" style="width: 200px;">
                                        <option value="0">Selecione</option>
                                        <c:forEach var="tarifa" items="${tarifasEspecificas}" varStatus="row">
                                            <option value="${tarifa.id}" ${carregamanif && awb.tarifaEspecifica.id == tarifa.id ? 'selected' : ''}>${tarifa.codigo} - ${tarifa.descricao}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <td class="TextoCamposNoAlign" align="left" colspan="8">
                                    <input type="button" id="pegarTabelaPreco" value="Calcular Tabela de Preço" class="botoes" style="margin-left: 10%;">
                                </td>
                                                           
                            </tr>
                            <tr>
                                <td width="10%" class="TextoCampos">Valor Fixo:</td>
                                <td width="23%" class="CelulaZebra2">
                                    <input type="text" name="valorFixo" id="valorFixo" onblur="seNaoFloatReset(this,'0.000');" maxlength="11" size="10" class="inputTexto" value="<%=(carregamanif ? (awb.getValorFixo()!= null ? vlrformat.format(awb.getValorFixo()) : "0,00") : "0,00")%>" style="text-align: right">
                                </td>
                                <td width="11%" class="TextoCampos">Frete Nacional:</td>
                                <td width="23%" class="CelulaZebra2">
                                    <input type="text" name="freteNacional" id="freteNacional" onblur="seNaoFloatReset(this,'0.000');" maxlength="11" size="10" class="inputTexto" value="<%=(carregamanif ? (awb.getFreteNacional()!= null ? vlrformat.format(awb.getFreteNacional()) : "0,00") : "0,00")%>" style="text-align: right">
                                </td>
                                <td width="10%" class="TextoCampos">ADVALOREM:</td>
                                <td width="23%" class="CelulaZebra2">
                                    <input type="text" name="advalorem" id="advalorem" onblur="seNaoFloatReset(this,'0.000');" maxlength="11" size="10" class="inputTexto" value="<%=(carregamanif ? (awb.getAdvalorem()!= null ? vlrformat.format(awb.getAdvalorem()) : "0,00") : "0,00")%>" style="text-align: right">
                                </td>
                            </tr>
                            <tr>
                                <td width="10%" class="TextoCampos">Taxa de Coleta:</td>
                                <td width="23%" class="CelulaZebra2">
                                    <input type="text" name="taxaColeta" id="taxaColeta" onblur="seNaoFloatReset(this,'0.000');" maxlength="11" size="10" class="inputTexto" value="<%=(carregamanif ? (awb.getTaxaColeta()!= null ? vlrformat.format(awb.getTaxaColeta()) : "0,00") : "0,00")%>" style="text-align: right">
                                </td>
                                <td width="11%" class="TextoCampos">Taxa de Entrega:</td>
                                <td width="23%" class="CelulaZebra2">
                                    <input type="text" name="taxaEntrega" id="taxaEntrega" onblur="seNaoFloatReset(this,'0.000');" maxlength="11" size="10" class="inputTexto" value="<%=(carregamanif ? (awb.getTaxaEntrega()!= null ? vlrformat.format(awb.getTaxaEntrega()) : "0,00") : "0,00")%>" style="text-align: right">
                                </td>
                                <td width="10%" class="TextoCampos">Taxa de Capatazia:</td>
                                <td width="23%" class="CelulaZebra2">
                                    <input type="text" name="taxaCapatazia" id="taxaCapatazia" onblur="seNaoFloatReset(this,'0.000');" maxlength="11" size="10" class="inputTexto" value="<%=(carregamanif ? (awb.getTaxaCapatazia()!= null ? vlrformat.format(awb.getTaxaCapatazia()) : "0,00") : "0,00")%>" style="text-align: right">
                                </td>
                            </tr>
                            <tr>
                                <td width="10%" class="TextoCampos">Taxa Fixa:</td>
                                <td width="23%" class="CelulaZebra2">
                                    <input type="text" name="taxaFixa" id="taxaFixa" onblur="seNaoFloatReset(this,'0.000');" maxlength="11" size="10" class="inputTexto" value="<%=(carregamanif ? (awb.getTaxaFixa() != null ? vlrformat.format(awb.getTaxaFixa()) : "0,00") : "0,00")%>" style="text-align: right">
                                </td>
                                <td width="11%" class="TextoCampos">Taxa de Desembaraço:</td>
                                <td width="23%" class="CelulaZebra2">
                                    <input type="text" name="taxaDesembaraco" id="taxaDesembaraco" onblur="seNaoFloatReset(this,'0.000');" maxlength="11" size="10" class="inputTexto" value="<%=(carregamanif ? (awb.getTaxaDesembaraco()!= null ? vlrformat.format(awb.getTaxaDesembaraco()) : "0,00") : "0,00")%>" style="text-align: right">
                                </td>
                                 <td width="10%" class="TextoCampos">Valor AWB (Calculado):</td>
                                <td width="23%" class="CelulaZebra2">                                   
                                    <input type="text" name="vlAWBCalculado" id="vlAWBCalculado" onblur="seNaoFloatReset(this,'0.000');" maxlength="11" size="10" readOnly="true" class="inputReadOnly" value="<%=(carregamanif ? (awb.getValorAWBCalculado()!= null ? vlrformat.format(awb.getValorAWBCalculado()) : "0,00") : "0,00")%>" style="text-align: right">                               
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Valor do AWB:</td>
                                <td class="CelulaZebra2">
                                    <input type="text" name="valorFrete" id="valorFrete" maxlength="10" size="10" align="right"  class="inputTexto" onchange="seNaoFloatReset(this,'0.00');calcularicms();" value="<%=carregamanif ? vlrformat.format(awb.getValorFrete()):"0.00"%>"  style="text-align: right">
                                </td>
                                <td class="TextoCampos">Alíquota ICMS:</td>
                                <td class="CelulaZebra2">
                                    <input id="valorIcms" name="valorIcms" size="10" maxlength="10" onblur="seNaoFloatReset(this,'0.00');calcularicms();" class="inputtexto" value="<%=(carregamanif ? awb.getPercIcms() == null ? "0" : vlrformat.format(awb.getPercIcms()) : "0.00")%>" style="text-align: right"/>
                                </td>
                                <td class="TextoCampos">Valor ICMS:</td>
                                <td class="CelulaZebra2">
                                    <input id="valorTotalIcms" name="valorTotalIcms" size="10" readOnly class="inputReadOnly" style="text-align: right"/>
                                </td>
                            </tr>
                        </table>                            
                    </td>
                </tr>
                <input name="serieDoc" type="hidden" id="serieDoc" size="4" maxlength="3" align="right" >
                <input name="numeroDoc" type="hidden" id="numeroDoc" size="8" maxlength="6" align="right" >
                <select name="remetente_awb" id="remetente_awb" style="display: none"></select>
                <select name="destinatario_awb" id="destinatario_awb" style="display: none"></select>
                <input name="frete_peso" type="hidden" id="frete_peso" align="right" value="0.00" onChange="javascript:calculaAwb(true);" onBlur="javascript:seNaoFloatReset(this,'0.00');" size="4" >
                <input name="frete_valor" type="hidden" id="frete_valor" align="right" value="0.00" onChange="javascript:calculaAwb(true);" onBlur="javascript:seNaoFloatReset(this,'0.00');" size="4" >
                <input name="taxa_emergencia" type="hidden" id="taxa_emergencia" align="right" value="0.00" onChange="javascript:calculaAwb(true);" onBlur="javascript:seNaoFloatReset(this,'0.00');" size="4" >
                <input name="taxa_transportador" type="hidden" id="taxa_transportador" align="right" value="0.00" onChange="javascript:calculaAwb(true);" onBlur="javascript:seNaoFloatReset(this,'0.00');" size="4" >
                <select name="responsavelRetirada" id="responsavelRetirada" style="display: none"></select>
                <input name="taxa_entrega" type="hidden" id="taxa_entrega" align="right" value="0.00" onChange="javascript:recalcula(true);" onBlur="javascript:seNaoFloatReset(this,'0.00');" size="4" >
                <input name="total_prestacao" type="hidden" class="inputReadOnly" id="total_prestacao" onBlur="javascript:seNaoFloatReset(this,'0.00');" value="0.00" size="4" readonly align="right">
                <input name="base_calculo" type="hidden" id="base_calculo" align="right" value="0.00" onChange="javascript:calculaAwb(false);" onBlur="javascript:seNaoFloatReset(this,'0.00');" size="4" >
                <input name="aliquota_icms" type="hidden" id="aliquota_icms" align="right" value="0.00" onChange="javascript:calculaAwb(true);" onBlur="javascript:seNaoFloatReset(this,'0.00');" size="4" >
                <input name="perc_icms" type="hidden" class="inputReadOnly" id="perc_icms" onBlur="javascript:seNaoFloatReset(this,'0.00');" value="0.00" size="4" align="right" readonly>
                
                <input type="hidden" name="id_funcionario" id="id_funcionario" value="0">
                <input type="hidden" name="nome_funcionario" id="nome_funcionario" value="">
                <input type="hidden" name="index_funcionario" id="index_funcionario" value="0">
                                                
                <tr class="tabela">
                    <td> 
                        <div align="center">Informa&ccedil;&otilde;es do seguro da carga (Averbação) </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="1">
                            <tr>
                                <td width="13%" class="TextoCampos">Seguradora:</td>
                                <td width="20%" class="CelulaZebra2">
                                    <select name="seguradora" id="seguradora" class="inputtexto" style="width: 200px;">
                                        <option value="0" selected>Não selecionada</option>
                                        <%BeanConsultaFornecedor conFor = new BeanConsultaFornecedor();
                                                    conFor.setConexao(autenticado.getConexao());
                                                    conFor.mostraSeguradoras();
                                                    ResultSet rsFor = conFor.getResultado();
                                                    while (rsFor.next()) {%>
                                        <option value="<%=rsFor.getString("idfornecedor")%>" <%=(carregamanif && rsFor.getInt("idfornecedor") == manif.getSeguradora().getIdfornecedor() ? "selected" : "")%> ><%=rsFor.getString("razaosocial")%></option>
                                        <%}
                                                    rsFor.close();%>
                                    </select>                                        
                                </td>
                                <td width="13%" class="TextoCampos">Custo Gerenc. Risco:</td>
                                <td width="21%" class="CelulaZebra2">
                                    <input type="text" name="valorCustoGerenciamento" id="valorCustoGerenciamento" maxlength="10" size="10" align="right"  class="inputTexto" onchange="seNaoFloatReset(this,'0.00');" value="<%=carregamanif ? vlrformat.format(manif.getValorCustoGerenciamento()):"0.00"%>">
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <c:if test="${!mostrar_averbacao}">
                    <tr>
                        <td colspan="8">
                            <table width="100%" border="0">
                                <tr class="CelulaZebra2">
                                    <td width="40%" align="right">
                                        <label for="chkProtocoloAverbacao">Protocolo de Averbação:</label>
                                    </td>
                                    <td width="60%">
                                        <c:if test="${tem_permissao_averbar_manualmente}">
                                            <input type="checkbox" id="chkProtocoloAverbacao" name="chkProtocoloAverbacao" onclick="ativarAverbacaoManual();">
                                        </c:if>
                                        <input type="text" name="protocoloAverbacao" id="protocoloAverbacao"
                                               value="<%= (carregamanif ? manif.getNumeroProtocoloAverbacao() : "")%>"
                                               size="50" maxlength="50" class="inputReadOnly" readonly>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </c:if>
                <tr class="tabela">
                    <td colspan="6"> 
                        <div align="center">Outros</div>
                    </td>
                </tr>
                <tr bgcolor="#FFFFFF">
                    <td height="26" colspan="6"> 
                        <table width="100%" border="0" cellspacing="1">
                            <tr>
                                <td colspan="8">
                                    <table width="100%" border="0">
                                        <tr>
                                            <td  rowspan="4" class="CelulaZebra2" width="65%">Observa&ccedil;&atilde;o:
                                                <textarea cols="80" rows="5" maxlength="500" id="obs"  name="obs" class="fieldMin" ><%=(carregamanif ? manif.getObs() : "")%></textarea>
                                                <input name="button2" type="button" class="inputBotaoMin" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=28','Observacao');" value="...">                            
                                            </td>
                                        </tr>
                                        <tr class="">
                                            <td colspan="2">
                                                <table id="fornecedores" width='100%' class="bordaFina">
                                                    <tr class="tabela">
                                                        <td colspan="4"><div align="center">Funcionários</div></td>
                                                        
                                                    </tr>
                                        <tr>
                                                        <td class="CelulaZebra1" colspan="">
                                                            <img src="img/add.gif" border="0" title="" class="imagemLink" style="vertical-align:middle;" onClick="addFuncionario(null);">
                                            </td>
                                                        <td class="Celula" colspan="">
                                                            Funcionário
                                                        </td>
                                                        <td class="Celula" colspan="">
                                                            Tipo
                                                        </td>
                                        </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="15%" class="TextoCampos">N&uacute;mero do Lacre:</td>
                                            <td width="30%" class="CelulaZebra2">
                                                <input name="numeroLacre" type="text" id="numeroLacre"  value="<%=(carregamanif ? manif.getNumeroLacre() : "")%>" size="32" maxlength="100" class="inputtexto">
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <c:if test="${tem_permissao_condutor_adicional}">
                                <tr>
                                    <td colspan="8">
                                        <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0"
                                               class="bordaFina">
                                            <tr>
                                                <td>
                                                    <table width="100%" border="0" cellpadding="0" cellspacing="1">
                                                        <tr class="celula">
                                                            <td width="1%">
                                                                <c:if test="${status_mdfe eq 'C'}">
                                                                    <img src="img/add.gif" border="0"
                                                                         title="atribuir valor &agrave; tabela abaixo"
                                                                         class="imagemLink"
                                                                         style="vertical-align:middle;"
                                                                         onClick="addCondutoresAdicionais()">
                                                                </c:if>
                                                            </td>
                                                            <td height="16" width="99%" colspan="7">
                                                                <div align="left">Condutores Adicionais</div>
                                                            </td>
                                                        </tr>
                                                        <tr id="trCondutores">
                                                            <td colspan="8">
                                                                <table width="100%" border="0" class="bordaFina">
                                                                    <tbody id="tbCondutores">
                                                                    <tr class="CelulaZebra1">
                                                                        <td width="2%"></td>
                                                                        <td width="15%" align="center">
                                                                            <strong>Motoristas</strong>
                                                                        </td>
                                                                        <td width="15%" align="center"></td>
                                                                        <td width="50%" align="center"></td>
                                                                    </tr>
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
                            </c:if>
                        </table>
                    </td>
                </tr>
             </table>
                    </td>
                </tr>
            </table>
             <table  id="tdCelOcorrencia" width="90%" border="0" align="center" cellpadding="0" cellspacing="0" class="bordaFina">                                
                <tr>
                    <td> 
                        <table width="100%" border="0" cellpadding="0" cellspacing="1">        
                            <tr class="celula">
                                <td width="1%"> 
                                    <img src="img/add.gif" border="0" title="atribuir valor &agrave; tabela abaixo" class="imagemLink" style="vertical-align:middle;" onClick="novaOcorrencia('0', ((idxOco%2)==0)?'1':'2')">
                                </td>
                                <td height="16" width="99%" colspan="7"> 
                                    <div align="left">Ocorr&ecirc;ncia(s)</div>
                                </td>
                            </tr>
                            <tr name="trOcorrencia" id="trOcorrencia" style="display: none">
                                <td colspan="8">
                                    <input type="hidden" name="qtdOco" id="qtdOco" value="<%=linhaOco%>">
                                    <table width="100%" border="0" class="bordaFina">
                                        <tbody id="tbOcorrencia" name="tbOcorrencia">
                                            <tr class="CelulaZebra1" >
                                                <td width="2%"></td>
                                                <td width="20%">Descri&ccedil;&atilde;o</td>
                                                <td width="12%">Ocorr&ecirc;ncia em</td>
                                                <td width="9%">Usu&aacute;rio</td>
                                                <td width="16%">Observação ocorr&ecirc;ncia</td>
                                                <td width="16%">Resolvido em</td>
                                                <td width="9%">Usu&aacute;rio</td>
                                                <td width="16%">Observa&ccedil;&atilde;o resolu&ccedil;&atilde;o</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                  </tr>
             </table>
             <table id="tdCelPallet" width="90%" border="0" align="center" cellpadding="0" cellspacing="0" class="bordaFina">
                  <tr>
                    <td> 
                        <table width="100%" border="0" cellpadding="0" cellspacing="1">
                            <tr class="tabela">
                                <td width="100%" colspan="8">
                                    <div align="center" class="tabela">Pallets</div>
                                </td>
                            </tr>
                            <tr class="celula">
                                <td width="2%">
                                    <img src="img/add.gif" border="0" title="atribuir valor &agrave; tabela abaixo" class="imagemLink" style="vertical-align:middle;" onClick="addItensMovimentacao()">
                                </td>
                                <td height="16" width="99%" colspan="7"> 
                                    <div align="left">Movimenta&ccedil;&atilde;o de Pallets</div>
                                </td>
                            </tr>
                            <tr name="trMovimentacao" id="trMovimentacao">
                                <td colspan="8">
                                    <input type="hidden" name="max" id="max" value="0">
                                    <input type="hidden" id="idconsignatario"></input>
                                    <input type="hidden" id="con_rzs"></input>
                                    <input type="hidden" id="indexAux"></input>
                                    <input type="hidden" id="id"></input>
                                    <input type="hidden" id="descricao"></input>
                                    <input type="hidden" id="idCliente" value="">
                                    <input type="hidden" id="idPallet" value="">
                                    <table width="100%" border="0" class="bordaFina">
                                        <tbody id="tbMovimentacao" name="tbMovimentacao">
                                            <tr class="CelulaZebra1" >
                                                <td width="2%"></td>
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
                    </td>
                  </tr>
                 <tr>
                    <td>
                        <table width="100%" border="0" cellpadding="0" cellspacing="1">
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
                    </td>
                 </tr>
            </table>
            
            <table id="tdCelGerenciadorRisco" width="90%" border="0" align="center" cellpadding="0" cellspacing="0" class="bordaFina">
                                <tr class="celula">
                    <td  width="100%" > 
                        <div align="center" class="tabela">Averbação</div>
                                    </td>
                                </tr>
                <tr>
                                        <td colspan="8">
                                                <table width="100%" border="0" class="bordaFina">
                                                        <tr class="CelulaZebra1">
                                <td width="40%" align="right">
                                    <label>Valor máximo das notas permitido pela seguradora:</label>
                                            </td>
                                <td width="60%">
                                    <input type="text" class="inputReadOnly" id="valorMaximoSeguradora" name="valorMaximoSeguradora" size="20" readonly="true" value=""/>
                                </td>
                                        </tr> 
                        </table>
                    </td>
                  </tr>
                        
                <c:if test="${mostrar_averbacao}">
                <tr class="celula">
                    <td  width="100%" > 
                            <div align="center" class="tabela">Averbação AT&M</div>
                    </td>
                </tr>
                <tr>
                    <td colspan="8">
                        <table width="100%" border="0" class="bordaFina">
                            <tr class="CelulaZebra1">
                                <td width="40%" align="right">
                                        <label for="chkProtocoloAverbacao">Protocolo de Averbação:</label>
                                </td>
                                <td width="60%">
                                        <c:if test="${tem_permissao_averbar_manualmente}">
                                            <input type="checkbox" id="chkProtocoloAverbacao" name="chkProtocoloAverbacao" onclick="ativarAverbacaoManual();">
                                        </c:if>
                                        <input type="text" name="protocoloAverbacao" id="protocoloAverbacao"
                                               value="<%= (carregamanif ? manif.getNumeroProtocoloAverbacao() : "")%>"
                                               size="50" maxlength="50" class="inputReadOnly" readonly>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                </c:if>
                <%if (autenticado.getFilial().getFilialGerenciadorRisco().getGerenciadorRisco().getId() != 1
                            && autenticado.getFilial().getFilialGerenciadorRisco().getGerenciadorRisco().getId() != 2
                            && autenticado.getFilial().getFilialGerenciadorRisco().getStUtilizacao() != 0) {%>
                    <tr class="celula">
                        <td  width="100%" > 
                            <div align="center" class="tabela">Gerenciador de Risco</div>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="8">
                            <table width="100%" border="0" class="bordaFina">
                                <tr class="CelulaZebra1">
                                    <td width="40%" align="right">
                                        <label for="gerenciadoraRisco">Gerenciadora de risco:</label>
                                    </td>
                                    <td width="60%">
                                        <label id="gerenciadoraRisco"><%= carregamanif ? manif.getDescricaoGerenciadoraRisco() : 0%></label>
                                    </td>
                                </tr>
                                <tr class="CelulaZebra1">
                                    <td width="40%" align="right">
                                        <label for="codigoPgr">Código do PGR para Monitoramento:</label>
                                    </td>
                                    <td width="60%">
                                        <input type="text" class="inputtexto"
                                               id="codigoPgr" name="codigoPgr" size="20"
                                               value="<%= carregamanif ? manif.getCodigoPgr() : "0"%>">
                                    </td>
                                </tr>
                                <tr class="CelulaZebra1">
                                    <td width="40%" align="right">
                                        <label for="codigoMonitoramento">Número Autorização:</label>
                                    </td>
                                    <td width="60%">
                                        <input type="text" class="inputReadOnly" id="codigoMonitoramento" name="codigoMonitoramento" size="20" readonly="readonly" value="<%= carregamanif ? manif.getCodigoMonitoramento() : 0%>">
                                    </td>
                                </tr>
                                <tr class="CelulaZebra1">
                                    <td width="40%" align="right">
                                        <label for="statusMonitoramento">Status monitoramento:</label>
                                    </td>
                                    <td width="60%">
                                        <input type="text" class="inputReadOnly" id="statusMonitoramento" name="codigoMonitoramento" size="20" value="<%= (carregamanif ? manif.getStatusMonitoramento() : "Pendente")%>" readonly="readonly">
                                    </td>
                                </tr>
                                <tr class="CelulaZebra1">
                                    <td width="40%" align="right">
                                        <label for="tipoTransporte">Tipo de transporte:</label>
                                    </td>
                                    <td width="60%">
                                        <select name="tipoTransporte" id="tipoTransporte" class="inputtexto">
                                            <option value="1" <%=(carregamanif && manif.getTipoTransporte() == 1 ? "selected" : "")%>>Transferência</option>
                                            <option value="2" <%=(carregamanif && manif.getTipoTransporte() == 2 ? "selected" : "")%>>Distribuição</option>
                                            <option value="3" <%=(carregamanif && manif.getTipoTransporte() == 3 ? "selected" : "")%>>Materia Prima</option>
                                            <option value="4" <%=(carregamanif && manif.getTipoTransporte() == 4 ? "selected" : "")%>>Mista</option>
                                            <option value="5" <%=(carregamanif && manif.getTipoTransporte() == 5 ? "selected" : "")%>>Retorno</option>
                                        </select>
                                    </td>
                                </tr>
                                <tr class="CelulaZebra1">
                                    <td width="40%" align="right">
                                        <label for="statusCarga">Status do Carregamento:</label>
                                    </td>
                                    <td width="60%">
                                        <select name="statusCarga" id="statusCarga" class="inputtexto">
                                            <option value="1" <%=(carregamanif && manif.getStatusCarga() == 1 ? "selected" : "")%>>Carregado</option>
                                            <option value="2" <%=(carregamanif && manif.getStatusCarga() == 2 ? "selected" : "")%>>Descarregado</option>
                                        </select>
                                    </td>
                                </tr>
                                <tr class="tabela">
                                    <td align="center" colspan="4">
                                        <div align="center">Ajudantes</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" colspan="4" width="100%">
                                        <table class="bordaFina" width="100%">
                                            <tr class="CelulaZebra1NoAlign">
                                                <td align="center" colspan="1" width="2%">
                                                    <img src="img/add.gif" onclick="addAjudante(null, $('tbodyAjudantes'))" alt="add.gif">
                                                    <input type="hidden" name="qtdAjudantes" id="qtdAjudantes" value="0" />
                                                </td>
                                                <td>Nome</td>
                                                <td>CPF</td>
                                                <td align="center" colspan="1" width="2%"></td>
                                            </tr>
                                            <tbody style="display: none" id="tbodyAjudantes"></tbody>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                <% } %>
                <%if (autenticado.getFilial().getFilialGerenciadorRisco().getGerenciadorRisco().getId() == 2
                            && autenticado.getFilial().getFilialGerenciadorRisco().getStUtilizacao() != 0) {%>
                <tr>
                    <td>
                <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="bordaFina">                       
                    <tr>
                        <td>
                          <table width="100%" border="0" cellpadding="0" cellspacing="1">        
                                <tr class="celula">
                                    <td  width="100%" > 
                                        <div align="center" class="tabela">Gerenciador de Risco</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="8">
                                        <table width="100%" border="0" class="bordaFina">
                                         
                                                <tr class="CelulaZebra1">                                                    
                                                    <td width="5%" align="center"><b>Veículo</b></td>
                                                    <td width="10%" align="center"><b>Tecnologia de Rastreamento</b></td>
                                                    <td width="10%" align="center"><b>Tipo de Comunicação</b></td>
                                                    <td width="10%" align="center"><b>Número Equipamento</b></td>
                                                    <td width="10%" align="center"></td>
                                                    <td width="40%" align="center"></td>
                                                </tr>
                                                <tr class="CelulaZebra2">          
                                                    <td colspan="1"><div align="center">
                                                            <label id="veiculoRastreamento" name="veiculoRastreamento"><%=(carregamanif && manif.getCavalo().getPlaca() != null ? manif.getCavalo().getPlaca() : "")%></label>
                                                        </div>
                                                        <input type="hidden" id="idveiculoRastreamento" name="idveiculoRastreamento" value="<%=(carregamanif && manif.getCavalo().getIdveiculo() != 0 ? manif.getCavalo().getIdveiculo(): 0)%>" />
                                                    </td>
                                                    <td colspan="1"><div align="center">
                                                        
                                                        <label id="tecVeiculo" name="tecVeiculo"><%=(carregamanif && manif.getTecnologiaRastreamentoVeiculo().getDescricao()!= null ? manif.getTecnologiaRastreamentoVeiculo().getDescricao() : "")%></label>
                                                        </div></td>
                                                    <td colspan="1"><div align="center">                                                            
                                                        <label id="tipoTecVeiculo" name="tipoTecVeiculo"><%=(carregamanif && manif.getTipoComunicacaoRastreamentoVeiculo().getDescricao()!= null ? manif.getTipoComunicacaoRastreamentoVeiculo().getDescricao() : "")%></label>
                                                      </div></td>
                                                    <td colspan="1"><div align="center"><label id="numEquipVeiculo" name="numEquipVeiculo"><%=(carregamanif && manif.getNumeroEquipamentoVeiculo() != null ? manif.getNumeroEquipamentoVeiculo(): "")%></label></div>                            
                                                       </td>
                                                    <td colspan="2"></td>
                                                </tr>
                                                <tr class="CelulaZebra2">          
                                                    <td colspan="1"><div align="center">    <label id="carretaRastreamento" name="carretaRastreamento"> <%=(carregamanif && manif.getCarreta().getPlaca() != null ? manif.getCarreta().getPlaca() : "")%></label></div>
                                                        <input type="hidden" class="inputTexto" id="idcarretaRastreamento" name="idcarretaRastreamento" value="<%=(carregamanif && manif.getCarreta().getIdveiculo() != 0 ? manif.getCarreta().getIdveiculo(): 0)%>" />
                                                    </td>
                                                    <td colspan="1">
                                                        <div align="center">
                                                  
                                                        <label id="tecCarreta" name="tecCarreta"><%=(carregamanif && manif.getTecnologiaRastreamentoCarreta().getDescricao()!= null ? manif.getTecnologiaRastreamentoCarreta().getDescricao() : "")%></label>
                                                    
                                                        </div></td> 
                                                         
                                                    <td colspan="1"><div align="center">
                                                            
                                                        <label id="tipoTecCarreta" name="tipoTecCarreta"><%=(carregamanif && manif.getTipoComunicacaoRastreamentoCarreta().getDescricao()!= null ? manif.getTipoComunicacaoRastreamentoCarreta().getDescricao() : "")%></label>
                                                            </div></td>
                                                     <td colspan="1"><div align="center">
                                                             <label id="numEquipCarreta" name="numEquipCarreta"><%=(carregamanif && manif.getNumeroEquipamentoCarreta() != null ? manif.getNumeroEquipamentoCarreta(): "")%></label>
                                                        </td>
                                                    <td colspan="2"></td>
                                                </tr>
                                                <tr class="CelulaZebra2">          
                                                    <td colspan="1"><div align="center"> <label id="bitremRastreamento" name="bitremRastreamento"><%=(carregamanif && manif.getBiTrem().getPlaca() != null ? manif.getBiTrem().getPlaca() : "")%></label></div>
                                                        <input type="hidden" class="inputTexto" id="idbitremRastreamento" name="idbitremRastreamento" value="<%=( carregamanif && manif.getBiTrem().getIdveiculo() != 0 ? manif.getBiTrem().getIdveiculo(): "")%>" />
                                                    </td>
                                                    <td colspan="1"> <div align="center">
                                                            <label id="tecBitrem" name="tecBitrem"><%=(carregamanif && manif.getTecnologiaRastreamentoBitrem().getDescricao()!= null ? manif.getTecnologiaRastreamentoBitrem().getDescricao() : "")%></label>
                                                        </div></td>   
                                                            
                                                    <td colspan="1"><div align="center">
                                                         <label id="tipoTecBitrem" name="tipoTecBitrem"><%=(carregamanif && manif.getTipoComunicacaoRastreamentoBitrem().getDescricao()!= null ? manif.getTipoComunicacaoRastreamentoBitrem().getDescricao() : "")%></label>
                                                        </div></td>
                                                     <td colspan="1"><div align="center"><label id="numEquipBitrem" name="numEquipBitrem"><%=(carregamanif && manif.getNumeroEquipamentoBitrem() !=null ? manif.getNumeroEquipamentoBitrem(): "")%></label></div>                                                            
                                                     </td>
                                                    <td colspan="2"></td>
                                                </tr>
                                                <tr class="CelulaZebra1">                                                    
                                                    <td colspan="4" align="center"><b>Escolta</b></td>                                                    
                                                    <td colspan="2" align="center"></td>                                                    
                                                </tr>
                                                <tr class="CelulaZebra1"><td colspan="1" align="center"><b>Fornecedor</b></td>
                                                    <td colspan="1" align="center"><b>Veículo</b></td>
                                                    <td colspan="1" align="center"><b>Nome Agente</b></td>
                                                    <td colspan="1" align="center"><b>Telefone Agente</b></td>
                                                    <td colspan="1" align="center"></td>     
                                                    <td colspan="1" align="center"></td>
                                                    
                                                </tr>
                                                
                                                 <tr class="CelulaZebra2">                                                    
                                                    <td colspan="1" align="center"> 
                                                        <input type="hidden"  id="idEscolta" name="idEscolta" value="<%=(carregamanif ? manif.getEscolta().getId(): "0")%>">
                                                        <select id="fornecedorEscolta" name="fornecedorEscolta" class="fieldMin" style="width:100pt;" >  
                   
                                                        <%      // Carregando todas as Categorias tipo PAMCARD
                                                            BeanCadFornecedor beanCadFornecedor = new BeanCadFornecedor();
                                                            beanCadFornecedor.setConexao(autenticado.getConexao());
                                                            Collection<BeanFornecedor> fornecedores = beanCadFornecedor.mostrarTodosGerenciadores();
                                                                    
                                                           
                                                         
                                                            for (BeanFornecedor fornecedor : fornecedores) {%>
                                                            <option value="<%=fornecedor.getIdfornecedor()%>"> <%=fornecedor.getRazaosocial()%></option> 
                                                        <%}%>
                                                       </select>
                                                    </td>
                                                    <td colspan="1" align="center">
                                                        <input type="hidden"  id="idveiculoEscolta" name="idveiculoEscolta" value="<%=(carregamanif ? manif.getEscolta().getVeiculo().getIdveiculo() : "")%>" />
                                                        <input type="text" class="inputReadOnly" id="veiculoEscolta" name="veiculoEscolta" size="9" readonly="" value="<%=(carregamanif && manif.getEscolta().getVeiculo().getPlaca() != null ? manif.getEscolta().getVeiculo().getPlaca(): "")%>"/>
                                                        <input name="localiza_cavalo" type="button" class="inputBotaoMin" id="localiza_cavalo" value="..." onClick="javascript:localizaVeiculoEscolta();">
                                                        <img src="img/page_edit.png" border="0" onClick="javascript:verVeiculo('S');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                                    </td>
                                                    <td colspan="1" align="center"><input type="text" class="inputTexto" id="nomeEscolta" name="nomeEscolta" value="<%=(carregamanif && manif.getEscolta().getNomeAgente() != null ? manif.getEscolta().getNomeAgente() : "")%>" maxlength="100"/></td>
                                                    <td colspan="1" align="center"><input size="10" type="text" class="inputTexto" id="telefoneEscolta" name="telefoneEscolta" value="<%=(carregamanif && manif.getEscolta().getTelefoneAgente() != null ? manif.getEscolta().getTelefoneAgente(): "")%>"/></td>
                                                                             
                                                    <td colspan="2" align="center"></td>                                                    
                                                                             
                                                </tr>
                                                  <tr class="CelulaZebra1">                                                    
                                                    <td colspan="4" align="center"><b>Paradas</b></td>                                                     
                                                    <td colspan="2" align="center"></td>                                                    
                                                  </tr>
                                                  
                                                  
                                                  <tr name="trParada" id="trParada">
                                                        <td colspan="8">
                                                            <table width="100%" border="0" class="bordaFina">
                                                                <tbody id="tbParadas" name="tbParadas">
                                                                    <tr class="CelulaZebra1">
                                                                        <td width="2%" align="center"><img src="img/add.gif" border="0" title="Adicionar Paradas" class="imagemLink" style="vertical-align:middle;" onClick="addParadas()"></td>
                                                                        <td width="18%" align="center"><b>Cidade/UF</b></td>
                                                                        <td width="20%" align="center"><b>Local</b></td>
                                                                        <td width="8%" align="center"><b>Tipo</b></td>
                                                                        <td colspan="2" align="center"></td>                         
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                        </td>
                                                   </tr> 
                                                   
                                                   <tr class="CelulaZebra1">                                                    
                                                    <td colspan="4" align="center"><b>Isca</b></td>                                                    
                                                    <td colspan="2" align="center"></td>                                                    
                                                </tr>
                                                <tr class="CelulaZebra1"><td colspan="1" align="center"><b>Marca</b></td>
                                                    <td colspan="1" align="center"><b>Tipo Comunicação</b></td>
                                                    <td colspan="1" align="center"><b>Número Equipamento</b></td>
                                                    <td colspan="1" align="center"><b>Login</b></td>
                                                    <td colspan="1" align="center"><b>Senha</b></td>
                                                    <td colspan="1" align="center"></td>     
                                                    
                                                </tr>
                                                
                                                <tr class="CelulaZebra2">                                                    
                                                    <td colspan="1" align="center">
                                                        <input type="hidden"  id="idIsca" name="idIsca" value="<%=(carregamanif && manif.getIsca().getId()!= 0 ? manif.getIsca().getId(): "0")%>"/>
                                                        <input type="text" class="inputTexto" size="15" id="marcaIsca" name="marcaIsca" value="<%=(carregamanif ? (manif.getIsca().getMarca()== null || manif.getIsca().getMarca().trim().equals("null")) ? "" : manif.getIsca().getMarca() : "")%>"/>
                                                    </td>                                                    
                                                    <td colspan="1" align="center">
                                                        <select id="tipoTecIsca" name="tipoTecIsca" class="fieldMin" style="width:100pt;">
                                                            <option value="1"<%= (carregamanif ? (manif.getIsca().getTipoComunicacaoRastreador() != null ? (manif.getIsca().getTipoComunicacaoRastreador().equals("1") ? "selected" : "") : "") : "" ) %> >Celular</option>
                                                            <option value="2"<%= (carregamanif ? (manif.getIsca().getTipoComunicacaoRastreador() != null ? (manif.getIsca().getTipoComunicacaoRastreador().equals("2") ? "selected" : "") : "") : "" ) %>>RF</option>
                                                            
                                                        </select>    
                                                    </td>                                                    
                                                    <td colspan="1" align="center"><input type="text" class="inputTexto" id="numeroEquipIsca" name="numeroEquipIsca" value="<%=(carregamanif ? (manif.getIsca().getNumeroEquipamento()==(null)? "" : manif.getIsca().getNumeroEquipamento()) : "")%>"/></td>                                                    
                                                    <td colspan="1" align="center"><input size="10" type="text" class="inputTexto" id="loginIsca" name="loginIsca" value="<%=(carregamanif ? (manif.getIsca().getLogin()==(null)? "" : manif.getIsca().getLogin()): "")%>"/></td>                                                                                                                                 
                                                    <td colspan="1" align="center"><input size="10" type="password" class="inputTexto" id="senhaIsca" name="senhaIsca" value="<%=(carregamanif ? (manif.getIsca().getSenha()==(null)? "" : manif.getIsca().getSenha()): "")%>"/></td>                                                    
                                                    <td colspan="1" align="center"></td>                                                   
                                                                             
                                                </tr>
                                                 <tr class="CelulaZebra1">                                                    
                                                    <td colspan="4" align="center"><b>Inserir Protocolo Manualmente</b></td>                                                    
                                                    <td colspan="2" align="center"></td>                                                    
                                                </tr>
                                                
                                                <tr class="CelulaZebra2">                                                    
                                                    <td colspan="1" align="center">
                                                       <b> Protocolo:</b>                                                       
                                                    </td>                                                    
                                                    <td colspan="1" align="center">
                                                         <input type="text" class="inputTexto" size="15" id="protocoloGoldenService" name="protocoloGoldenService" value="<%=(carregamanif ? manif.getProtocoloGoldenService(): "")%>">
                                                    </td>                                                    
                                                    <td colspan="2" align="center"></td>                                                   
                                                    <td colspan="2" align="center"></td>                                                   
                                                                             
                                                </tr>
                                                
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
              <%}else {%>
                    <!--criando os campos para que não de erro no JS procurando o valor de nulo.-->
                    <tbody id="tbParadas" name="tbParadas">
                        <tr name="trParada" id="trParada">
                            <td>
                                <input style='display: none' name="localiza_cavalo" type="button" class="inputBotaoMin" id="localiza_cavalo" value="..." onClick="javascript:localizaVeiculoEscolta();">
                                <input type="hidden" id="idveiculoRastreamento" name="idveiculoRastreamento" value="<%=(carregamanif ? manif.getCavalo().getIdveiculo(): 0)%>" />
                                <input type="hidden" class="inputTexto" id="idcarretaRastreamento" name="idcarretaRastreamento" value="<%=(carregamanif ? manif.getCarreta().getIdveiculo(): 0)%>" />
                                <input type="hidden" class="inputTexto" id="idbitremRastreamento" name="idbitremRastreamento" value="<%=(carregamanif ? manif.getBiTrem().getIdveiculo(): "")%>" />
                                <input type="hidden"  id="idEscolta" name="idEscolta" value="<%=(carregamanif ? manif.getEscolta().getId(): "0")%>">
                                <input type="hidden"  id="idveiculoEscolta" name="idveiculoEscolta" value="<%=(carregamanif ? manif.getEscolta().getVeiculo().getIdveiculo() : "")%>" />
                                <input type="hidden"  id="idIsca" name="idIsca" value="<%=(carregamanif ? manif.getIsca().getId(): "0")%>">
                                <input type="hidden" class="inputReadOnly" id="veiculoEscolta" name="veiculoEscolta" size="9" readonly="" value="<%=(carregamanif ? manif.getEscolta().getVeiculo().getPlaca(): "")%>"/>
                                <input type="hidden" class="inputTexto" id="nomeEscolta" name="nomeEscolta" value="<%=(carregamanif ? manif.getEscolta().getNomeAgente() : "")%>"/>
                                <input type="hidden" class="inputTexto" id="telefoneEscolta" name="telefoneEscolta" value="<%=(carregamanif ? manif.getEscolta().getTelefoneAgente(): "")%>"/>
                                <input type="hidden" class="inputTexto" size="15" id="marcaIsca" name="marcaIsca" value="<%=(carregamanif ? manif.getIsca().getMarca(): "")%>">
                                <input type="hidden" class="inputTexto" id="numeroEquipIsca" name="numeroEquipIsca" value="<%=(carregamanif ? (manif.getIsca().getNumeroEquipamento()==(null)? "" : manif.getIsca().getNumeroEquipamento()) : "")%>"/>
                                <input type="hidden" class="inputTexto" size="15" id="protocoloGoldenService" name="protocoloGoldenService" value="<%=(carregamanif ? manif.getProtocoloGoldenService(): "")%>">
                                <input size="10" type="hidden" class="inputTexto" id="loginIsca" name="loginIsca" value="<%=(carregamanif ? (manif.getIsca().getLogin()==(null)? "" : manif.getIsca().getLogin()): "")%>"/>
                                <input size="10" type="hidden" class="inputTexto" id="senhaIsca" name="senhaIsca" value="<%=(carregamanif ? (manif.getIsca().getSenha()==(null)? "" : manif.getIsca().getSenha()): "")%>"/>
                                
                                <select id="fornecedorEscolta" name="fornecedorEscolta" style="display: none" ></select>
                                <label style="display: none" id="veiculoRastreamento" name="veiculoRastreamento"></label>
                                <label style="display: none" id="tecVeiculo" name="tecVeiculo"></label>
                                <label style="display: none" id="tipoTecVeiculo" name="tipoTecVeiculo"></label>
                                <label style="display: none" id="numEquipVeiculo" name="numEquipVeiculo"></label>
                                <label style="display: none" id="carretaRastreamento" name="carretaRastreamento"></label>
                                <label style="display: none" id="tecCarreta" name="tecCarreta"></label>
                                <label style="display: none" id="tipoTecCarreta" name="tipoTecCarreta"></label>
                                <label style="display: none" id="numEquipCarreta" name="numEquipCarreta"></label>
                                <label style="display: none" id="bitremRastreamento" name="bitremRastreamento"></label>
                                <label style="display: none" id="tecBitrem" name="tecBitrem"></label>
                                <label style="display: none" id="tipoTecBitrem" name="tipoTecBitrem"></label>
                                <label style="display: none" id="numEquipBitrem" name="numEquipBitrem"></label>

                            </td>
                        </tr>
                    </tbody>
                <% } %>
            </table>           
                        
                        
                        
            <table id="tdCelAuditoria" width="90%" border="0" align="center" cellpadding="1" cellspacing="1" class="bordaFina" style='display: <%= carregamanif && nivelUser == 4 ? "" : "none" %>'>          
                
                <tr>
                    <td><%@include file="/gwTrans/template_auditoria.jsp" %></td>
                </tr>
                <tr>
                    <td width="100%" colspan="6">
                        <table width="100%">
                            <tr>
                                <td width="10%" height="24" class="TextoCampos">Inclu&iacute;do em:</td>
                                <td width="10%" class="CelulaZebra2">
                                    <input name="dtlancamento" type="text" id="dtlancamento" class="inputReadOnly" value="<%=(carregamanif && manif.getUsuariolancamento().getNome() != null ? formato.format(manif.getDtlancamento()) : "")%>" size="10" readonly="true">
                                </td>
                                <td width="5%" class="TextoCampos">Por:</td>
                                <td width="25%" class="CelulaZebra2">
                                    <input name="usulancamento" type="text" id="usulancamento" class="inputReadOnly" value="<%=(carregamanif && manif.getUsuariolancamento().getNome() != null? manif.getUsuariolancamento().getNome() : "")%>" size="25" readonly="true">
                                </td>
                                <td width="10%" class="TextoCampos">Alterado em:</td>
                                <td width="10%"class="TextoCampos">
                                    <input name="dtalteracao" type="text" id="dtalteracao" class="inputReadOnly" value="<%=(carregamanif && manif.getDtalteracao() != null ? formato.format(manif.getDtalteracao()) : "")%>" size="10" readonly="true">
                                </td>
                                <td width="5%" class="TextoCampos">Por:</td>
                                <td width="25%" class="CelulaZebra2">
                                    <input name="usualteracao" type="text" id="usualteracao" class="inputReadOnly" value="<%=(carregamanif && manif.getDtalteracao() != null ? manif.getUsuarioalteracao().getNome() : "")%>" size="25" readonly="true">
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
              </table>
                    <div id="tab3" style="display: none">
                        <table width="90%" border="0" class="bordaFina" align="center">
                            <tbody id="tbGwMobile" name="tbGwMobile">
                                <tr>
                                    <td colspan="7"  class="tabela"><div align="center">Gw Mobile</div></td>
                                </tr>
                                <tr>
                                    <td colspan="7"  class="">
                                        <table width="100%" class="bordaFina">
                                            <c:if test="<%= (carregamanif && manif.isMobileSincronizado()) %>">
                                                <tr class="celulaZebra2">
                                                    <td width="20%">Status:</td>
                                                    <td width="80%" colspan="3" style="font-weight: bold">Sincronizado</td>
                                                </tr>
                                                <tr class="celulaZebra2">
                                                    <td width="20%">Usuário que sincronizou: </td>
                                                    <td width="20%"> <%= manif.getUsuarioSincronizacaoMobile().getNome() %> </td>
                                                    <td width="20%">data sincronização:</td>
                                                    <td width="20%"> <%= manif.getDataSincronizacaoMobile() +" "+ manif.getHoraSincronizacaoMobile() %> </td>
                                                </tr>
                                            </c:if>
                                            <c:if test="<%= !(carregamanif && manif.isMobileSincronizado()) %>">
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
            <br/>
               <table width="90%" border="0" align="center" cellpadding="0" cellspacing="0" class="bordaFina">                  
                <tr class="CelulaZebra2">
                    <td colspan="6">
                        <table width="100%" border="0" cellspacing="1">
                            <tr class="CelulaZebra2">
                                <td width="100%">
                                    <div align="center">
                                        <%if (carregamanif && !acao.equals("iniciar")) {%>
                                               <%if (nivelUser >= 2 && nivelImpresso == 4 && (nivelMDFeCOnfirmado == 4 || manif.getStatusManifesto() == null || !Apoio.in(manif.getStatusManifesto(), "L", "C", "R"))) {%>
                                                   <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>',$('qtdLinhasCTe').value,<%=peso%>);});">
                                               <%}else{%>
                                                   <label>MDF-e <%=(manif.getStatusManifesto().charAt(0) == 'C' ? "Confirmado" : (manif.getStatusManifesto().charAt(0) == 'L' ? "Cancelado" : (manif.getStatusManifesto().charAt(0) == 'R' ? "Encerrado" : "")))%>. Você não tem permissão para alterar esse manifesto. (Código da Permissão: 314)</label>
                                               <%}%>
                                        <%} else {%>
                                            <%if (nivelUser >= 2) {%>
                                               <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>',$('qtdLinhasCTe').value,<%=peso%>);});">
                                            <%}%>
                                        <%}%>
                                    </div>
                                    <div align="center"></div>
                                    <div align="left"> </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
                 </td>
             </tr>
        </table>
        <div class="cobre-tudo"></div>
        </form>
        <div class="bloqueio-enviando-averbacao" style="display: none;">
            <img class="gif-bloq-tela" src="${homePath}/img/espere_new.gif" alt="" style="display: inline-block;">
            <strong class="gif-bloq-tela"
                    style="display: inline-block;margin-left:-95px;font-size:20px;margin-top:70px;">
                Enviando averbação...
            </strong>
        </div>
        <div class="bloqueio-tela"></div>
    </body>
</html>
