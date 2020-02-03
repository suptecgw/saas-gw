
<%@page import="usuario.BeanUsuario"%>
<%@page import="conhecimento.ocorrencia.BeanOcorrenciaCtrc"%>
<%@page import="conhecimento.ocorrencia.Ocorrencia"%>
<%@page import="conhecimento.aeroporto.Aeroporto"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri = "http://java.sun.com/jsp/jstl/functions" prefix = "fn" %>
<%@page import="br.com.gwsistemas.contratodefrete.pedagio.SolucoesPedagio"%>
<%@page import="br.com.gwsistemas.contratodefrete.pedagio.SolucoesPedagioBO"%>
<%@page import="cliente.faixaPeso.FaixaPeso"%>
<%@page import="java.util.Collection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="cliente.tipoProduto.TipoProduto"%>
<%@page import="fornecedor.fornecedorGrupoCliente.BeanFornecedorGrupoCliente"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="fornecedor.TipoControleContaCorrente"%>
<%@page contentType="text/html" language="java"
         import="fornecedor.*,
         nucleo.Apoio,
         java.text.DecimalFormat,
         java.text.SimpleDateFormat,
         java.util.Vector,
         java.util.Date,
         mov_banco.banco.*,
         java.sql.ResultSet,
         nucleo.BeanConfiguracao,
         nucleo.BeanLocaliza,
         nucleo.webservice.WebServiceCep,
         cidade.*,
         nucleo.*,
         java.io.PrintWriter" %>

<% int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadfornecedor") : 0);
    int nivelCnpjInvalido = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadastra_cnpj_forn_errado") : 0);
    //testando se a sessao eh valida e se o usuario tem acesso
    if (Apoio.getUsuario(request) == null || nivelUser == 0) {
        response.sendError(response.SC_FORBIDDEN);
    }
%>

<%
    String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    BeanCadFornecedor cadfornec = new BeanCadFornecedor();
%>

<jsp:useBean id="fornec" class="fornecedor.BeanFornecedor" /><%
//ATENÇÃO useBean preenche os campos do bean com os inputs que tiverem o mesmo nome
    boolean carregafornec = false;
    boolean erro = false;
    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
    //Carregando as configuraões independente da ação
    BeanConfiguracao cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    //Carregando as configurações
    cfg.CarregaConfig();
    Collection<TipoProduto> product_types = TipoProduto.allRepresentante(Apoio.getConnectionFromUser(request));
    Collection<TipoProduto> productTypesAereo = TipoProduto.RepresentanteAereo(Apoio.getConnectionFromUser(request));
    cadfornec.setConexao(Apoio.getUsuario(request).getConexao());
    Collection<TarifaEspecificaAero> tarifasEspecificas = cadfornec.mostrarTarifasEspecificas();
    //SolucoesPedagioBO
    SolucoesPedagioBO solucoesPedagioBO = null;

    if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar") || acao.equals("excluir")) {
        cadfornec.setConexao(Apoio.getUsuario(request).getConexao());

        if ((acao.equals("editar")) && (request.getParameter("id") != null)) {
            cadfornec.getFornecedor().setIdfornecedor(Integer.parseInt(request.getParameter("id")));
            carregafornec = cadfornec.LoadAllPropertys();
            fornec = (carregafornec ? cadfornec.getFornecedor() : null);
            product_types = TipoProduto.allRepresentante(Apoio.getConnectionFromUser(request));
            request.setAttribute("fornecs", fornec);                                                                                                                            
        } else if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir") || acao.equals("excluir"))) {
%><jsp:setProperty name="fornec" property="*" /><%
            //setando os atributos que nao podem ser setados dinamicamente(acoes: atualizar/incluir)
            boolean erroValidado = false;
            String mgsValidacao = "";
            FaixaPeso fp = null;
            TabelaPrecoCompanhiaAerea tpcia = null;
            Aeroporto aeroOrigem = null;
            Aeroporto aeroDestino = null;
            TipoProduto tipoProd = null;
            TarifaEspecificaAero tarifaEspecifica = null;
            TabPrecoCiaAereaFaixaPeso fpCiaAerea = null;
            Collection<TabPrecoCiaAereaFaixaPeso> listaFpCiaAerea = null;

            if (acao.equals("atualizar") || acao.equals("incluir")) {
                fornec.getCidade().setIdcidade(Integer.parseInt(request.getParameter("idcidadeorigem")));
                fornec.getHistoricoPadrao().setIdHistorico(Integer.parseInt(request.getParameter("idhist")));
                fornec.getPlanoCustoPadrao().setIdconta(Integer.parseInt(request.getParameter("idplanocusto_despesa")));
                cadfornec.getVendedor().setTipoVendedor(Integer.parseInt(request.getParameter("tipo_vendedor")));
                fornec.setTipoCgc(request.getParameter("tipocgc"));
                fornec.setIdentInscest(request.getParameter("identinscest"));
                fornec.setExpedicaoRG(Apoio.getFormatData(request.getParameter("dataexpedicaorg")));
                fornec.setOrgaoInscmu(request.getParameter("orgaoinscmu"));
                fornec.setTipoPeso(request.getParameter("tipoPeso_0"));
                fornec.setValorFaixaPesoExcedente(Apoio.parseFloat(request.getParameter("vlPrecoExcedente_0")));
                // Aba Tabela Preço Cia Aérea 
                fornec.setModeloMinutaDespacho(Apoio.parseInt(request.getParameter("modeloMinuta")));
                fornec.setContaCorrenteCiaAerea(request.getParameter("numconta"));
                int qtdFaixaPeso = Apoio.parseInt(request.getParameter("qtdFaixaPeso_0"));
                for (int i = 1; i <= qtdFaixaPeso; i++) {
                    fp = new FaixaPeso();
                    fp.setId(Apoio.parseInt(request.getParameter("idFaixa_0_" + i)));
                    fp.setPesoInicial(Apoio.parseFloat(request.getParameter("pesoInicio_0_" + i)));
                    fp.setPesoFinal(Apoio.parseFloat(request.getParameter("pesoFinal_0_" + i)));
                    fp.setValorFaixa(Apoio.parseFloat(request.getParameter("valorPeso_0_" + i)));
                    fp.setTipoValor(request.getParameter("slcFaixaPeso_0_" + i));
                    fornec.getFaixasPeso().add(fp);
                }
                
                int qtdTabelaPrecoCiaAerea = Apoio.parseInt(request.getParameter("qtdTabPreceCiaAerea"));
                for (int i = 1; i <= qtdTabelaPrecoCiaAerea; i++) {
                    if(request.getParameter("tabelaId_" + i) != null) {
                        tpcia = new TabelaPrecoCompanhiaAerea();
                        tpcia.setId(Apoio.parseInt(request.getParameter("tabelaId_" + i)));
                        aeroOrigem = new Aeroporto();
                        aeroOrigem.setId(Apoio.parseInt(request.getParameter("aeroportoColetaId_" + i)));
                        aeroDestino = new Aeroporto();
                        aeroDestino.setId(Apoio.parseInt(request.getParameter("aeroportoEntregaId_" + i)));
                        tpcia.setAeroOrigem(aeroOrigem);
                        tpcia.setAeroDestino(aeroDestino);
                        tpcia.setValorExcedente(Apoio.parseDouble(request.getParameter("excedente_" + i)));
                        tpcia.setValorFixo(Apoio.parseDouble(request.getParameter("fixo_" + i)));
                        tipoProd = new TipoProduto();
                        tipoProd.setId(Apoio.parseInt(request.getParameter("tipoProduto_" + i)));
                        tpcia.setTipoProduto(tipoProd);
                        tarifaEspecifica = new TarifaEspecificaAero();
                        tarifaEspecifica.setId(Apoio.parseInt(request.getParameter("tarifaEspecifica_" + i)));
                        tpcia.setTarifaEspecifica(tarifaEspecifica);
                        tpcia.setTaxaColeta(Apoio.parseDouble(request.getParameter("taxaColeta_" + i)));
                        tpcia.setTaxaEntrega(Apoio.parseDouble(request.getParameter("taxaEntrega_" + i)));
                        tpcia.setTaxaCapatazia(Apoio.parseDouble(request.getParameter("taxaCapatazia_" + i)));
                        tpcia.setTaxaFixa(Apoio.parseDouble(request.getParameter("taxaFixa_" + i)));
                        tpcia.setTaxaDesembaraco(Apoio.parseDouble(request.getParameter("taxaDesembaraco_" + i)));
                        tpcia.setPercentualSeguro(Apoio.parseDouble(request.getParameter("seguro_" + i)));
                        tpcia.setFreteMinimo(Apoio.parseDouble(request.getParameter("freteMinimo_" + i)));
                        tpcia.setIsExcluido(Apoio.parseBoolean(request.getParameter("isExcluido_" + i)));

                        int qtdFaixaPesoCiaAerea = Apoio.parseInt(request.getParameter("qtdTabFaixaPeso_"+i));
                        listaFpCiaAerea = new ArrayList<>();
                        for(int j = 1; j <= qtdFaixaPesoCiaAerea; j++) {
                            if(request.getParameter("tpFaixaPesoId_"+i+"_"+j) != null) {
                                fpCiaAerea = new TabPrecoCiaAereaFaixaPeso();
                                fpCiaAerea.setId(Apoio.parseInt(request.getParameter("tpFaixaPesoId_"+i+"_"+j)));
                                fpCiaAerea.setPesoInicial(Apoio.parseDouble(request.getParameter("pesoinicial_"+i+"_"+j)));
                                fpCiaAerea.setPesoFinal(Apoio.parseDouble(request.getParameter("pesofinal_"+i+"_"+j)));
                                fpCiaAerea.setValorQuilo(Apoio.parseDouble(request.getParameter("valorporquilo_"+i+"_"+j)));
                                fpCiaAerea.setTipoValor(request.getParameter("tpValor_".concat(String.valueOf(i)).concat("_").concat(String.valueOf(j))));
                                fpCiaAerea.setIsExcluido(Apoio.parseBoolean(request.getParameter("isExcluidoFP_"+i+"_"+j)));
                                listaFpCiaAerea.add(fpCiaAerea);
                            }
                        }
                        tpcia.setFaixasPeso(listaFpCiaAerea);

                        fornec.getTabPrecoCiaAerea().add(tpcia);
                    }
                }

                fornec.getAeroporto().setId(Apoio.parseInt(request.getParameter("aeroporto_id")));
                //fornec.getGcf().setId(Integer.parseInt(request.getParameter("grupo_id")));
                fornec.getPlanoConta().setId(Integer.parseInt(request.getParameter("idContaProvisao")));
                
                fornec.getSolucaoPedagio().setId(Apoio.parseInt(request.getParameter("solucoesPedagio")));
                try {
                    Apoio.validarEmail(request.getParameter("emailValidado"));
                } catch (Exception ex) {
                    erroValidado = true;
                    mgsValidacao = ex.getMessage();
                }


                fornec.setEmail(request.getParameter("emailValidado")); 

                //********************* Adicionando os grupos ao Bean Fornecedor  ***********************
                int qtdGrupos = Apoio.parseInt(request.getParameter("qtdGrupos"));
                if (qtdGrupos > 0) {
                    for (int i = 1; i <= qtdGrupos; i++) {
                        BeanFornecedorGrupoCliente bfgc = new BeanFornecedorGrupoCliente();
                        bfgc.setId(Apoio.parseInt(request.getParameter("fornecedorGrupoId" + i)));
                        bfgc.getGrupoCliente().setId(Apoio.parseInt(request.getParameter("grupoId" + i)));
                        fornec.getFornecedorGrupoCliente().add(bfgc);
                    }
                }
                fornec.getContaIrrfRetido().setId(Integer.parseInt(request.getParameter("idIrrfRetido")));

                fornec.setIntegraFiscal(request.getParameter("integrafiscal") == null ? false : true);
                fornec.setPercentualAgente(Float.parseFloat(request.getParameter("perc_abastecimento")));

                fornec.setAjudante(request.getParameter("chkAjudante") == null ? false : true);
                fornec.setRedespachante(request.getParameter("chkRedespachante") == null ? false : true);
                fornec.setVendedor(request.getParameter("chkVendedor") == null ? false : true);
                fornec.setAgentePagador(request.getParameter("chkAgentePagador") == null ? false : true);
                fornec.setAgenteCarga(request.getParameter("chkAgenteCarga") == null ? false : true);
                fornec.setAgenteFactoring(request.getParameter("chkAgenteFactoring") == null ? false : true);
                fornec.setProprietario(request.getParameter("chkProprietario") == null ? false : true);
                        
                fornec.setSeguradora(request.getParameter("chkFornecedorSeguradora") == null ? false : true);
                fornec.setCompanhiaAerea(request.getParameter("chkCompanhiaAerea") == null ? false : true);
                fornec.setFornecedorCombustivel(request.getParameter("chkFornecedorCombustivel") == null ? false : true);
                fornec.setNumeroRntrc((request.getParameter("numeroRntrc").equals("") ? 0 : Long.parseLong(request.getParameter("numeroRntrc"))));
                fornec.setNomeFantasia(request.getParameter("fantasia"));
                fornec.setContaBancaria(request.getParameter("contaBancaria"));
                fornec.setAgenciaBancaria(request.getParameter("agenciaBancaria"));
                fornec.setFavorecido(request.getParameter("favorecido"));
                fornec.getBanco().setIdBanco(Integer.parseInt(request.getParameter("bancoId")));
                fornec.setCartaoPamcard(request.getParameter("cartaoPamcard"));
                fornec.setCartaoNdd(Long.parseLong(request.getParameter("cartaoNdd")));
                fornec.setCartaoTicketFrete(Long.parseLong(request.getParameter("cartaoTicketFrete")));
                fornec.setCpfCnpj(request.getParameter("cpfcnpj"));
                fornec.setContaBancaria2(request.getParameter("contaBancaria2"));
                fornec.setAgenciaBancaria2(request.getParameter("agenciaBancaria2"));
                fornec.setFavorecido2(request.getParameter("favorecido2"));
                fornec.getBanco2().setIdBanco(Integer.parseInt(request.getParameter("bancoId2")));
                fornec.getUnidadeCusto().setId(Integer.parseInt(request.getParameter("id_und")));
                fornec.setPercentualDescontoSaldoFrete(Double.parseDouble(request.getParameter("percentualDesconto")));
                fornec.setPercentualCtrcContratoFrete(Double.parseDouble(request.getParameter("percentualCTRC")));
                fornec.setCriadoPor(Apoio.getUsuario(request));
                fornec.setAlteradoPor(Apoio.getUsuario(request));
                fornec.setNotaFiscalHistoricoContabil(request.getParameter("notaFiscalHistorico") == null ? false : true);
                fornec.setMovimentoHistoricoContabil(request.getParameter("movimentoHistorico") == null ? false : true);
                fornec.setFornecedorHistoricoContabil(request.getParameter("fornecedorHistorico") == null ? false : true);
                fornec.setTac(request.getParameter("isTac") == null ? false : true);
                fornec.setDataNascimento(Apoio.getFormatData(request.getParameter("dataNascimentoS")));
                fornec.setNumeroLogradouro(request.getParameter("logradouro"));
                fornec.setDdd(Apoio.parseInt(request.getParameter("ddd")));
                fornec.setDdd2(Apoio.parseInt(request.getParameter("ddd2")));
                fornec.setIdTabArea(Apoio.parseInt(request.getParameter("idTabArea")));
                fornec.setTipoTaxa(Short.parseShort(request.getParameter("tipoTaxa")));
                fornec.setTituloEleitor(request.getParameter("tituloEleitor"));
                fornec.setZonaEleitoral(Apoio.parseInt(request.getParameter("zonaEleitoral")));
                fornec.setSecaoEleitoral(Apoio.parseInt(request.getParameter("secaoEleitoral")));
                fornec.setCartaoRepom(request.getParameter("cartaoRepom"));
                fornec.getTipoProdutoType().setId(Apoio.parseInt(request.getParameter("tipoProdutoId")));
                fornec.setAvistaDesconsiderarContabilizarProvisao(Apoio.parseBoolean(request.getParameter("avistaDesconsiderarContabilizarProvisao")));
                fornec.setSempreConsiderarClanoCusto(Apoio.parseBoolean(request.getParameter("sempreConsiderarClanoCusto")));
                fornec.setDesativarFornecedor(Apoio.parseBoolean(request.getParameter("desativarFornecedor")));
                fornec.setBaseCubagem(Apoio.parseDouble(request.getParameter("baseCubagem")));
                fornec.setValorTde(Apoio.parseDouble(request.getParameter("valorTde")));
                fornec.setMaiorPrecoPesoPercentual(Apoio.parseBoolean(request.getParameter("isUsarMaiorPrecoPeso")));
                fornec.setTipoCalculoPercentualCte(request.getParameter("considerarValor"));
                fornec.setLogin(request.getParameter("loginRepresentante"));
                fornec.setSenha(request.getParameter("senhaRepresentante"));
                
                fornec.setGerenciadorRisco(Apoio.parseBoolean(request.getParameter("gerenciadorRisco")));
                
                fornec.setTipoContaAdiantamentoExpers(request.getParameter("tipoConta")); //Mesmo com o nome de expers, o campo é comum a todos, independente de expers ou não.
                //campos do DOM
                int maxArea = Apoio.parseInt(request.getParameter("countArea"));
                TabelaPrecoRedespacho tpr;
                for (int i = 1; i <= maxArea; i++) {
                    if (request.getParameter("areaId_" + i) != null) {
                        tpr = new TabelaPrecoRedespacho();
                        tpr.setId(Apoio.parseInt(request.getParameter("id_" + i)));
                        tpr.getArea().setId(Apoio.parseInt(request.getParameter("areaId_" + i)));
                        tpr.getArea().setDescricao(request.getParameter("area_" + i));
                        tpr.setVlfreteminimo(Apoio.parseFloat(request.getParameter("vlFreteMinArea_" + i)));
                        tpr.setVlsobfrete(Apoio.parseFloat(request.getParameter("vlSobFreteArea_" + i)));
                        tpr.setVlKgAte(Apoio.parseFloat(request.getParameter("vlKgAteArea_" + i)));
                        tpr.setVlPrecoFaixa(Apoio.parseFloat(request.getParameter("vlPrecoFaixaArea_" + i)));
                        tpr.setVlsobpeso(Apoio.parseFloat(request.getParameter("vlSobPesoArea_" + i)));
                        tpr.setVlsobkm(Apoio.parseFloat(request.getParameter("vlSobKm_" + i)));
                        tpr.setTipoTaxa(Short.parseShort(request.getParameter("tipoTaxa_" + i)));
                        tpr.setAdVlEm(Apoio.parseFloat(request.getParameter("adVlEmArea_" + i)));
                        tpr.setVlGris(Apoio.parseFloat(request.getParameter("vlGrisArea_" + i)));
                        tpr.getTipoProdutoType().setId(Apoio.parseInt(request.getParameter("tipoProdutoArea_" + i)));
                        tpr.setPrevisaoEntrega(Apoio.parseInt(request.getParameter("vlPrevisaoEntregaArea_" + i)));
                        tpr.setTipoPrevisaoEntrega(request.getParameter("tipoPrevisaoEntregaArea_" + i));
                        tpr.setTaxaFixa(Apoio.parseFloat(request.getParameter("vlTaxaFixaArea_" + i)));
                        tpr.setCteAutomaticoAereo(request.getParameter("chkCteAutoAereoArea_" + i) == null ? false : true);
                        tpr.setTipoArredodamentoPeso(request.getParameter("tipoArredodamentoArea_" + i));
                        tpr.setTipoPeso(request.getParameter("tipoPeso_" + i));
                        tpr.setTipoArredodamentoPeso(request.getParameter("rTipoArredodamento_" + i));
                        tpr.setValorFaixaPesoExcedente(Apoio.parseFloat(request.getParameter("vlPrecoExcedente_" + i)));
                        tpr.setAutomaticoColeta(request.getParameter("chkAutoColeta_" + i) == null ? false : true);
                        tpr.setBaseCubagem(Apoio.parseDouble(request.getParameter("baseCubagem_"+i)));
                        tpr.setValorTde(Apoio.parseDouble(request.getParameter("valorTde_"+i)));
                        tpr.setMaiorPrecoPesoPercentual(Apoio.parseBoolean(request.getParameter("isUsarMaiorPrecoPeso_"+i)));
                        tpr.setTipoCalculoPercentualCte(request.getParameter("considerarValor_"+i));

                        qtdFaixaPeso = Apoio.parseInt(request.getParameter("qtdFaixaPeso_" + i));
                        
                        
                        for (int j = 1; j <= qtdFaixaPeso; j++) {
                            
                            fp = new FaixaPeso();
                            fp.setId(Apoio.parseInt(request.getParameter("idFaixa_" + i + "_" + j)));
                            fp.setPesoInicial(Apoio.parseFloat(request.getParameter("pesoInicio_" + i + "_" + j)));
                            fp.setPesoFinal(Apoio.parseFloat(request.getParameter("pesoFinal_" + i + "_" + j)));
                            fp.setValorFaixa(Apoio.parseFloat(request.getParameter("valorPeso_" + i + "_" + j)));
                            fp.setTipoValor(request.getParameter("slcFaixaPeso_" + i + "_" + j));
                            fp.setTabela(tpr);
                            tpr.getFaixasPeso().add(fp);
                        }

                        fornec.getTbPrecoRedespacho().add(tpr);
                    }
                }
                //*********************** TipoProduto cia arereo****************************************   
                 int qtdAereo = Apoio.parseInt(request.getParameter("inpQtdProdAereo"));
                 ArrayList<TipoProdutoCiaAerea> listaTpca = new ArrayList<>();
                    if(qtdAereo > 0){
                        for (int i = 1; i <= qtdAereo; i++) {
                            TipoProduto tp = new TipoProduto();
                                tp.setId(Apoio.parseInt(request.getParameter("slcAereo_"+ i)));
                                tp.setDescricao(request.getParameter("inpTipoProdutoCiaAereaDes_"+ i));
                            TipoProdutoCiaAerea tpca = new TipoProdutoCiaAerea();
                                tpca.setId(Apoio.parseInt(request.getParameter("inpIdTabelaPrecoCiaAerea_"+ i)));
                                tpca.setTipoProdutoAereo(tp);
                                tpca.setOrdem(Apoio.parseInt(request.getParameter("inputOrdem"+ i))); 
                            listaTpca.add(tpca);
                        }
                        fornec.setTpca(listaTpca);
                        
                        
                    }
               
                int maxOcorrencia = Apoio.parseInt(request.getParameter("maxOcorrencia"));

                fornec.setIdsOcorrenciaExcluir(request.getParameter("ocorrenciaExcluir"));
              
                if (maxOcorrencia != 0) {
                    Ocorrencia ocorrenciaMotosita;
                    for (int i = 0; i < maxOcorrencia; i++) {
                        if (request.getParameter("idOcorrencia_" + i) != null) {
                            ocorrenciaMotosita = new Ocorrencia();
                            BeanOcorrenciaCtrc ocorrencia = new BeanOcorrenciaCtrc();
                            ocorrencia.setId(Apoio.parseInt(request.getParameter("idOcorrenciaCTRC_" + i)));
                            ocorrenciaMotosita.setOcorrencia(ocorrencia);

                            ocorrenciaMotosita.setId(Apoio.parseInt(request.getParameter("idOcorrencia_" + i)));
                            ocorrenciaMotosita.setOcorrenciaEm(Apoio.getFormatData(request.getParameter("dataOcorrencia_" + i)));
                            ocorrenciaMotosita.setOcorrenciaAs(Apoio.getFormatTime(request.getParameter("horaOcorrencia_" + i)));
                            ocorrenciaMotosita.setObservacaoOcorrencia(request.getParameter("descricaoOcorrencia_" + i));
                            BeanUsuario usuarioOcorrencia = new BeanUsuario();
                            int idUsuarioOcorrencia = Apoio.parseInt(request.getParameter("idUsuarioInclusao_" + i));
                            usuarioOcorrencia.setIdusuario(idUsuarioOcorrencia);
                            ocorrenciaMotosita.setUsuarioOcorrencia(usuarioOcorrencia);
                            ocorrenciaMotosita.setResolvido(Apoio.parseBoolean(request.getParameter("resolvido_" + i)));
                            ocorrenciaMotosita.setResolucaoAs(Apoio.getFormatTime(request.getParameter("horaResolucao_" + i)));
                            ocorrenciaMotosita.setResolucaoEm(Apoio.getFormatData(request.getParameter("dataResolucao_" + i)));
                            ocorrenciaMotosita.setObservacaoResolucao(request.getParameter("descricaoResolucao_" + i));
                            BeanUsuario usuarioResolucao = new BeanUsuario();
                            int idUsuarioResolucao = Apoio.parseInt(request.getParameter("idUsuarioResolucao_" + i));
                            usuarioResolucao.setIdusuario(idUsuarioResolucao);
                            ocorrenciaMotosita.setUsuarioResolucao(usuarioResolucao);
                            fornec.getOcorrenciaFornecedor().add(ocorrenciaMotosita);
            }
                    }
                }  
            }

            // 08/07/2018
            fornec.setTipoDescontoContaCorrente(Apoio.parseInt(request.getParameter("tipoDescontoContaCorrente")));
            fornec.setTipoControleContaCorrente(TipoControleContaCorrente.getTipoControleContaCorrente(request.getParameter("tipoControleContaCorrenteSelect")));
            
            fornec.setFuncionario(Apoio.parseBoolean(request.getParameter("chkFuncionario")));

            cadfornec.setFornecedor(fornec);
            cadfornec.setExecutor(Apoio.getUsuario(request));
            if (!erroValidado) {
                if (acao.equals("atualizar")) {
                    erro = !cadfornec.Atualiza();
                } else if (acao.equals("incluir") && nivelUser >= 3) {
                    erro = !cadfornec.Inclui();
                    if(cadfornec.getErros().indexOf("rcpf_cnpj_key") > -1){
                        cadfornec.setErros("Fornecedor já cadastrado no sistema! ");
                    }
                } else if (acao.equals("excluir") && nivelUser >= 4) {
                    erro = !cadfornec.Deleta();
                        if(cadfornec.getErros().indexOf("fk_idfornecedor") > -1){
                            cadfornec.setErros("Não é possível excluir Fornecedor, existe uma despesa para o mesmo! ");
                        }
                    }
                }

               String scr = "";
//            if (!acao.equals("excluir")) {
                if (erro || erroValidado) {
                    scr = "<script>"
                            + "window.opener.document.getElementById('salvar').disabled = false;"
                            + "alert('" + (erroValidado ? mgsValidacao : cadfornec.getErros()) + "');"
                            + "window.opener.document.getElementById('salvar').value = 'Salvar';";
                        scr += "window.close();"
                            + "</script>";
                    acao = (acao.equals("atualizar") ? "editar" : "iniciar");
                } else {
                    scr = "<script>"
                            + "window.opener.document.location.replace('ConsultaControlador?codTela=14');"
                            + "window.close();"
                            + "</script>";
                }
//            }

            response.getWriter().append(scr);
            response.getWriter().close();
        }
    }
    if (acao.equals("deletarGrupo")) {
        cadfornec.setConexao(Apoio.getUsuario(request).getConexao());
        cadfornec.setExecutor(Apoio.getUsuario(request));
        int idGrupo = Apoio.parseInt(request.getParameter("idFornecedorG"));
        cadfornec.deletarGrupo(idGrupo);

    }
    if (acao.equals("deletarArea")) {
        cadfornec.setConexao(Apoio.getUsuario(request).getConexao());
        cadfornec.setExecutor(Apoio.getUsuario(request));
        int idAreaApagar = Apoio.parseInt(request.getParameter("idAreaApagar"));
        cadfornec.deletarArea(idAreaApagar);

    } 
      

    if (acao.equals("excluirTipoProdutoCiaAerea")) {
        cadfornec.setConexao(Apoio.getUsuario(request).getConexao());
        cadfornec.setExecutor(Apoio.getUsuario(request));
        int idAereaApagar = Apoio.parseInt(request.getParameter("idTipoProdutoCiaAerea"));
        cadfornec.excluirTipoProdutoCiaAerea(idAereaApagar);

    }

    if (acao.equals("getEnderecoByCep")) {
        WebServiceCep webServiceCep = WebServiceCep.searchCep(request.getParameter("cep"));
        String resposta = "";

        if (webServiceCep.wasSuccessful()) {
            BeanConsultaCidade daoCidade = new BeanConsultaCidade();
            daoCidade.setConexao(Apoio.getUsuario(request).getConexao());
            int idCidade = daoCidade.localizarIdCidade(webServiceCep.getCidade(), webServiceCep.getUf());
            String bairro = webServiceCep.getBairro().length() < 25 ? webServiceCep.getBairro().toUpperCase() : webServiceCep.getBairro().toUpperCase().substring(0, 24);

            resposta = "@@" + webServiceCep.getLogradouroFull().toUpperCase() + "@@"
                    + bairro + "@@"
                    + (idCidade != 0 ? webServiceCep.getCidade().toUpperCase() : "") + "@@"
                    + (idCidade != 0 ? idCidade : "0") + "@@"
                    + webServiceCep.getUf().toUpperCase() + "@@";

            //PrintWriter out = response.getWriter();
            out.println(resposta);
            out.close();
        } else {
            resposta = "@@" + "@@" + "@@" + "@@" + "0@@" + "@@";
            //PrintWriter out = response.getWriter();
            out.println(resposta);
            out.close();
        }
    }
%>
<c:set var="carregafornec" value="<%= carregafornec %>"/>
<script language="javascript" src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script> 
<script language="JavaScript" type="text/javascript" src="script/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="script/situacaoPessoa.js"></script>
<script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoesTelaFornecedor.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoesTelaCadFornecedor.js"></script>

<script language="javascript" type="text/javascript">
    jQuery.noConflict();
    
    var qtdGrupos = 0;
    var indexGrupo = 0;
    
    arAbasGenerico = new Array();
    arAbasGenerico[0] = new stAba('tdDadosFinanceiroContabil','dvInfoFinanceiroContabil');
    arAbasGenerico[1] = new stAba('tdDadosFornecedor','dvInfoFornecedor1');
    arAbasGenerico[2] = new stAba('tdTabPreco','dvInfoTabPreco');
    arAbasGenerico[3] = new stAba('tdTabPrecoCiaAerea','dvInfoTabPrecoCiaAerea');
    arAbasGenerico[4] = new stAba('tdAbaAuditoria','divAuditoria');
    arAbasGenerico[5] = new stAba('tdDadosOcorrencia','div-ocorrencia');
     
    var listTpPeso = new Array();
    listTpPeso[0] = new Option("1", "Fixo");
    listTpPeso[1] = new Option("2", "Faixa");
    
    function duasCasasDecimais(){
        var valor = parseFloat(colocarPonto($("vlsobpeso").value)).toFixed(4);
        var valorArredondado = valor;
        $("vlsobpeso").value = valorArredondado;
    }
    
    function duasCasasDecimaisDom(count){
        var valor = parseFloat(colocarPonto($("vlSobPesoArea_"+count).value)).toFixed(4);
        var valorArredondado = valor;
        $("vlSobPesoArea_"+count).value = valorArredondado;
    }
    
    
    function FornecedorGrupoCliente(id, idFornecedor, nomeFornecedor, idGrupo, descricaoGrupo){
        this.id = id != undefined ? id : 0;
        this.idForncedor = (idFornecedor != undefined) ? idFornecedor : 0;
        this.nomeFornecedor = (nomeFornecedor != undefined) ? nomeFornecedor : "";
        this.idGrupo =  (idGrupo != undefined) ? idGrupo : 0;
        this.descricaoGrupo = (descricaoGrupo != undefined) ? descricaoGrupo : "";
    }
    
    function excluirGrupo(index){
        
        var grupo = $('descricaoGrupo'+index).value;
        var idFornecedorG = $('fornecedorGrupoId' + index).value;
        var linha =  $('trFornecedorGrupo' + index);
        if(confirm('Deseja excluir o grupo '+ grupo +'!')){
            if(confirm("Tem certeza?")){
                if (idFornecedorG != 0) {
                    new Ajax.Request("./cadfornecedor.jsp?acao=deletarGrupo&idFornecedorG="+idFornecedorG),
                    {
                        method:'get',
                        onSuccess: function(){ alert('Grupo '+ grupo + ' removido com sucesso!') },
                        onFailure: function(){ alert('Erro ao excluir o grupo '+ grupo +'!') }
                        
                    }
                }else{/*$("iptSiglaOpcional_"+index1+"_"+index2).checked=true;*/}
                Element.remove($(linha));
                qtdGrupos--;
                $('qtdGrupos').value = qtdGrupos;
            }
        
    
        }
    }
    function abrirLocalizarGrupoCliente(index){
        indexGrupo = index;
        launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.GRUPO_CLI_FOR%>','Grupo');
    }
        
    function limparGrupo(index){
        $("grupoId"+index).value =   0;
        $("descricaoGrupo"+index).value = "";
    }
    function addFornecedorGrupoCliente(fornecedorGCliente){
        if(fornecedorGCliente == undefined | fornecedorGCliente == null){
            fornecedorGCliente = new FornecedorGrupoCliente();
        }
        qtdGrupos ++;
       
        //*********************** Recuperando a Tbody ****
        var tbodyGrupos = $("tbodyFgc");
        //*********************** Nova Linha **************
        var novaLinha = new Element("tr",{
            id:"trFornecedorGrupo"+qtdGrupos,
            className:"CelulaZebra2"
        });
        //*********************** TD Em Branco ************
        var tdEmBranco = new Element("td",{
            className:"TextoCampos",
            style: "text-align:center"
        });
       
        //************************* IMG Excluir **********
        
        var imgExcluir =  Builder.node("img",{
            name: "imgExcluir"+qtdGrupos,
            id: "imgExcluir"+qtdGrupos,
            src: "img/lixo.png",
            className: "imagemLink",
            onClick: "excluirGrupo(" + qtdGrupos + ");"
        });
        //tdEmBranco.innerHTML = "Grupo: ";
        tdEmBranco.appendChild(imgExcluir);
        novaLinha.appendChild(tdEmBranco);
         
        //*********************** Id Fornecedor Grupo Id ******
        var hiddenFornecedorGrupoId = new Element("input",{
            type:"hidden",
            name:"fornecedorGrupoId"+qtdGrupos,
            id:"fornecedorGrupoId"+qtdGrupos,
            value: fornecedorGCliente.id
        });
       
        
        //************************* Grupo Id ********************
        var hiddenGrupoId = new Element("input",{
            type:"hidden",
            name:"grupoId"+qtdGrupos,
            id:"grupoId"+qtdGrupos,
            value: fornecedorGCliente.idGrupo
        });
        
        //**************************** TD Grupo ****************
        var tdGrupo = new Element("td",{
            colspan: 3
        });
        //************************** Input Descrica Grupo **********
        var inputGrupoDescricao = new Element("input",{
            type:"text",
            id:"descricaoGrupo"+qtdGrupos,
            name:"descricaoGrupo"+qtdGrupos,
            size:"21",
            className:"inputReadOnly",
            readonly:"true",
            value: fornecedorGCliente.descricaoGrupo
        });
        tdGrupo.appendChild(inputGrupoDescricao)
        //************************* Button Grupo ********************
        var buttonGrupo = Builder.node("input",{
            type:"button",
            id:"btnGrupo"+ qtdGrupos,
            name:"btnGrupo"+ qtdGrupos,
            value:"...",
            className:"inputBotaoMin",
            onclick: "abrirLocalizarGrupoCliente("+qtdGrupos+")"
        })
        tdGrupo.appendChild(buttonGrupo);
        //******************************* Imagem Borracha ************************** 
        var imgBorracha =  Builder.node("img",{
            name: "imgBorracha"+qtdGrupos,
            id: "imgBorracha"+qtdGrupos,
            src: "img/borracha.gif",
            title: "Limpar plano custo padr&atilde;o",
            className: "imagemLink",
            style: "margin-left: 5px;",
            onClick: onClick="limparGrupo("+qtdGrupos+");"
        });
        tdGrupo.appendChild(imgBorracha);
        
        //*********************** TD Em Branco ************
        var tdEmBranco2 = new Element("td");
        
        // novaLinha.appendChild(tdEmBranco2);
        novaLinha.appendChild(hiddenFornecedorGrupoId);
        novaLinha.appendChild(hiddenGrupoId);
        novaLinha.appendChild(tdEmBranco);//Adicionando a td em branco a Tbody
        novaLinha.appendChild(tdGrupo);
        tbodyGrupos.appendChild(novaLinha);
        $("qtdGrupos").value = qtdGrupos;
    }
    
    // implementação de tipos de produtos cia aerea.
        var qtdAereo = 0;
        var qtdTabelaAereo = 0;
        var tCiaAerea = null; 
        var tp = null; 
        var listaTiposProdutoAereoBanco = new Array();
        
    function carregar(){
        <c:forEach var="tabelaPrecoCiaAerea" items="${fornecs.tabPrecoCiaAerea}" varStatus="row">
                addTabelaPrecoCiaAerea(listaIdTP, listaDescTP, listaIdTE, listaCodTE, listaDescTE);
                jQuery('#tabelaId_${row.count}').val('${tabelaPrecoCiaAerea.id}');
                jQuery('#aeroportoColeta_${row.count}').val('${tabelaPrecoCiaAerea.aeroOrigem.nome}');
                jQuery('#aeroportoColetaId_${row.count}').val('${tabelaPrecoCiaAerea.aeroOrigem.id}');
                jQuery('#aeroportoEntrega_${row.count}').val('${tabelaPrecoCiaAerea.aeroDestino.nome}');
                jQuery('#aeroportoEntregaId_${row.count}').val('${tabelaPrecoCiaAerea.aeroDestino.id}');
                jQuery('#excedente_${row.count}').val(formatoMoeda('${tabelaPrecoCiaAerea.valorExcedente}'));
                jQuery('#fixo_${row.count}').val(formatoMoeda('${tabelaPrecoCiaAerea.valorFixo}'));
                jQuery('#tipoProduto_${row.count}').val('${tabelaPrecoCiaAerea.tipoProduto.id}');
                jQuery('#tarifaEspecifica_${row.count}').val('${tabelaPrecoCiaAerea.tarifaEspecifica.id}');
                jQuery('#taxaColeta_${row.count}').val(formatoMoeda('${tabelaPrecoCiaAerea.taxaColeta}'));
                jQuery('#taxaEntrega_${row.count}').val(formatoMoeda('${tabelaPrecoCiaAerea.taxaEntrega}'));
                jQuery('#taxaCapatazia_${row.count}').val(formatoMoeda('${tabelaPrecoCiaAerea.taxaCapatazia}'));
                jQuery('#taxaFixa_${row.count}').val(formatoMoeda('${tabelaPrecoCiaAerea.taxaFixa}'));
                jQuery('#taxaDesembaraco_${row.count}').val(formatoMoeda('${tabelaPrecoCiaAerea.taxaDesembaraco}'));
                jQuery('#seguro_${row.count}').val(formatoMoeda('${tabelaPrecoCiaAerea.percentualSeguro}'));
                jQuery('#freteMinimo_${row.count}').val(formatoMoeda('${tabelaPrecoCiaAerea.freteMinimo}'));
                <c:forEach var="faixaPeso" items="${tabelaPrecoCiaAerea.faixasPeso}" varStatus="ordem">
                    adicionarDOMFaixaPeso('${row.count}');
                    jQuery('#tpFaixaPesoId_${row.count}_${ordem.count}').val('${faixaPeso.id}');
                    jQuery('#pesoinicial_${row.count}_${ordem.count}').val(formatoMoeda('${faixaPeso.pesoInicial}'));
                    jQuery('#pesofinal_${row.count}_${ordem.count}').val(formatoMoeda('${faixaPeso.pesoFinal}'));
                    jQuery('#valorporquilo_${row.count}_${ordem.count}').val(formatoMoeda('${faixaPeso.valorQuilo}'));
                    jQuery("#tpValor_${row.count}_${ordem.count}").val('${faixaPeso.tipoValor}');
                </c:forEach>
        </c:forEach>

        <%for (TipoProduto p : productTypesAereo) {%>
                   listaTiposProdutoAereoBanco[++qtdAereo] = new Option("<%=p.getId()%>", "<%=p.getDescricao()%>"); 
       <%}%>
           
           
    <% if(fornec != null && fornec.getTpca() != null){
           for (TipoProdutoCiaAerea elem : fornec.getTpca()){%>
            
                 // tipo do produto
               tp = new  TipoProdCiaAerea();
                    tp.id= "<%=elem.getTipoProdutoAereo().getId() %>";
                    tp.descricao = "<%=elem.getTipoProdutoAereo().getDescricao() == null ? "":elem.getTipoProdutoAereo().getDescricao() %>";
    
                // tabela preco cia aerea. 
               tCiaAerea = new  TabelaPrecoCiaAerea(); 
                    tCiaAerea.id = "<%=elem.getId()%>";
                    tCiaAerea.listaTiposProdutoAereo =  listaTiposProdutoAereoBanco ;   
                    tCiaAerea.tipoProdCiaArea = tp;
                    tCiaAerea.ordem ="<%= elem.getOrdem()%>";

                addTipoProdutoCiaAerea(tCiaAerea);   
            <%}%>  

       <%}%>
          
       <%for (Ocorrencia oco : fornec.getOcorrenciaFornecedor()) {%>
                   var ocorrencia = new Ocorrencia();                

                    ocorrencia.idOcorrenciaCTRC = '<%=oco.getOcorrencia().getId()%>';
                    ocorrencia.idOcorrencia = '<%=oco.getId()%>';
                    ocorrencia.ocorrencia = '<%=oco.getOcorrencia().getCodigo()%>' + " - " + '<%=oco.getOcorrencia().getDescricao()%>';
                    ocorrencia.dataInclusao = '<%=Apoio.getFormatData(oco.getInclusaEm())%>';
                    ocorrencia.horaInclusao = '<%=Apoio.getFormatTimeParent(oco.getInclusaAS())%>';
                    ocorrencia.dataOcorrencia = '<%=Apoio.getFormatData(oco.getOcorrenciaEm())%>';
                    ocorrencia.horaOcorrencia = '<%=Apoio.getFormatTimeParent(oco.getOcorrenciaAs())%>';
                    ocorrencia.descricaoOcorrencia = '<%=oco.getObservacaoOcorrencia()%>';
                    ocorrencia.usuarioInclusao = '<%=oco.getUsuarioOcorrencia().getNome()%>';
                    ocorrencia.idUsuarioInclusao = '<%=oco.getUsuarioOcorrencia().getIdusuario()%>';
                    ocorrencia.resolvido = '<%=oco.isResolvido()%>';
                    ocorrencia.resolvidoEm = '<%=Apoio.getFormatData(oco.getResolucaoEm())%>';
                    ocorrencia.resolvidoAs = '<%=Apoio.getFormatTimeParent(oco.getResolucaoAs())%>';
                    ocorrencia.descricaoResolucao = '<%=oco.getObservacaoResolucao()%>';
                    ocorrencia.usuarioResolucao = '<%=oco.getUsuarioResolucao().getNome()%>';
                    ocorrencia.idUsuarioResolucao = '<%=oco.getUsuarioResolucao().getIdusuario()%>';
                    ocorrencia.obrigaResolucao = '<%=oco.getOcorrencia().isObrigaResolucao()%>';
                    
                    addDomOcorrencia(ocorrencia);
                   
       <%}
       %>
   
            
            
    } 
    
    
             // criando objeto tipo produto.
    function TipoProdCiaAerea(id, descricao) {
        
        this.id = (id == undefined || id == null ? 0 : id);
        this.descricao = (descricao == undefined || descricao == null ? "" : descricao);
    }
    
    // criando objeto Tabela Precao Cia Aerea.
    function TabelaPrecoCiaAerea(id,listaTiposProdutoAereo,tipoProdCiaArea,ordem){
        
        this.id = (id != null && id != undefined)? id:0;
        this.listaTiposProdutoAereo = (listaTiposProdutoAereo != null && listaTiposProdutoAereo != undefined)? listaTiposProdutoAereo:null;
        this.tipoProdCiaArea = (tipoProdCiaArea != null && tipoProdCiaArea != undefined)? tipoProdCiaArea: new TipoProdCiaAerea();    
        this.ordem = (ordem != null && ordem != undefined)? ordem :qtdProdAereo;
    }
    
     
    
  
    
    var qtdProdAereo = 0;
    function addTipoProdutoCiaAerea(tabelaPrecoCiaAerea){
       
       qtdProdAereo++;
         if(tabelaPrecoCiaAerea == undefined || tabelaPrecoCiaAerea == null){
            tabelaPrecoCiaAerea = new TabelaPrecoCiaAerea();
           
        }
        
        
        var classe = (qtdProdAereo % 2 == 1 ? "CelulaZebra2NoAlign" : "CelulaZebra1NoAlign");
        var tabela = $("tbodyTpca");
        
        var _trPrincipal = Builder.node("tr",{id:"trPrincipal_"+qtdProdAereo, className:"tabela"});
        var _tdAux = Builder.node("td",{id:"tdAux_"+qtdProdAereo, className:classe, align:"left" });
        var _tdExcluir = Builder.node("td",{id:"tdExcluir_"+qtdProdAereo, className:classe, align:"left" });
        var _tdAereo = Builder.node("td",{id:"tdAereo_"+qtdProdAereo, className:classe });
        var _tdOrdena = Builder.node("td",{id:"tdOrdena_"+qtdProdAereo, className:classe});       
       
        
        var inputOrdem = Builder.node("INPUT",{
            
            id:"inputOrdem"+qtdProdAereo,
            name:"inputOrdem"+qtdProdAereo,
            className:"fieldMin",
            size:"3",
            maxlength: "2",
            onkeypress:"mascara(this, soNumeros)", 
            value:(tabelaPrecoCiaAerea.ordem != null && tabelaPrecoCiaAerea.ordem != undefined ) ? tabelaPrecoCiaAerea.ordem :qtdProdAereo,
            onchange:"validarCampoOrdem("+qtdProdAereo+");"
        });
        

        var _slcAereo = Builder.node("select",{
            id:"slcAereo_"+qtdProdAereo, 
            name:"slcAereo_"+qtdProdAereo, 
            className:"inputtexto",
            style:"width:100px" 
        });

         var _inpExcluirTipoProdutoCiaAerea = Builder.node("img",{
            id:"inpExcluirTipoProdutoCiaAerea_"+qtdProdAereo,
            name:"inpExcluirTipoProdutoCiaAerea_"+qtdProdAereo,
            type:"button",
            className:"imagemLink",
            src:"img/lixo.png",
            width:"20px",                       
            heigth:"20px",
            onclick:"javascript:tryRequestToServer(function(){excluirTipoProdutoCiaAerea("+qtdProdAereo+")});"
        });
        
          var _inpHidIdTipoProdutoCiaAerea = Builder.node("input",{
            id:"inpIdTipoProdutoCiaAerea_"+qtdProdAereo,
            name:"inpIdTipoProdutoCiaAerea_"+qtdProdAereo,
            type:"hidden",
            value: tabelaPrecoCiaAerea.tipoProdCiaArea.id
        });  
        
          
        var _inpTipoProdutoCiaAereaDes = Builder.node("input",{
            id:"inpTipoProdutoCiaAereaDes_"+qtdProdAereo,
            name:"inpTipoProdutoCiaAereaDes_"+qtdProdAereo,
            type:"hidden",
            value: tabelaPrecoCiaAerea.tipoProdCiaArea.descricao
           
        });
        
        
       var  inpIdTabelaPrecoCiaAerea = Builder.node("input",{
            id:"inpIdTabelaPrecoCiaAerea_"+qtdProdAereo,
            name:"inpIdTabelaPrecoCiaAerea_"+qtdProdAereo,
            type:"hidden",
            value: tabelaPrecoCiaAerea.id
           
        });
        
        optSelecione = Builder.node("option", {value: 0},'Selecione');
        
        // Montando colunas.
        _tdExcluir.appendChild(_inpExcluirTipoProdutoCiaAerea);
        _tdExcluir.appendChild(_inpHidIdTipoProdutoCiaAerea);
        _tdExcluir.appendChild(_inpTipoProdutoCiaAereaDes);        
        _tdAereo.appendChild(_slcAereo);
        _tdOrdena.appendChild(inputOrdem);
        
       // Montando linhas.
       //_trPrincipal.appendChild(_tdAux);
        _trPrincipal.appendChild(inpIdTabelaPrecoCiaAerea);
        _trPrincipal.appendChild(_tdExcluir);        
        _trPrincipal.appendChild(_tdAereo);
        _trPrincipal.appendChild(_tdOrdena);
        tabela.appendChild(_trPrincipal);
        
        $("inpQtdProdAereo").value = qtdProdAereo;
            
         
        // monta select com os produtos cia aerea.  
        _slcAereo.appendChild(optSelecione);
        povoarSelectAerea($("slcAereo_"+qtdProdAereo),listaTiposProdutoAereoBanco, tabelaPrecoCiaAerea.tipoProdCiaArea.id);
        //sconsole.log($("inpIdTabelaPrecoCiaAerea_").value);   
        povoarSelect();
      
         
    }
    
    function povoarSelectAerea(elemento,listaCiaAerea, valor) {
      
    var optLayout = null;
    
   
    if (listaCiaAerea != null && listaCiaAerea != undefined) {
                
            for (var i = 1; i <= listaCiaAerea.length; i++) {

                if (listaCiaAerea[i] != null && listaCiaAerea[i] != undefined) {

                    optLayout = Builder.node("option", {
                        value: listaCiaAerea[i].valor 

                    });
                    
                    
                    Element.update(optLayout, listaCiaAerea[i].descricao);
                    elemento.appendChild(optLayout);

                }
            }

            if (valor == 0) {
                elemento.selectedIndex = 0;

            }else  {
                elemento.value = valor; 
            }
             

        }
    }

    function validarCampoOrdem(index){
        
        var ordem = $("inputOrdem"+index);
        if ((ordem.value == 0) || (ordem.value < 0) ) {
           alert("Valor inválido!");
        }else{
          return;
        }  
    }
    
    
    function excluirTipoProdutoCiaAerea(index){
        if (confirm("Deseja mesmo excluir este tipo de produto?")){
            var idTipoProdutoCiaAerea = $("inpIdTabelaPrecoCiaAerea_"+index).value;
            jQuery.ajax({
            url: "./cadfornecedor",
            dataType: "text",
            method : "post",
            async : false,
            data: {
                idTipoProdutoCiaAerea :idTipoProdutoCiaAerea,
                acao : "excluirTipoProdutoCiaAerea"
            },
            success: function() {
                 Element.remove("trPrincipal_"+index);  
            },error: function(){
                alert("Erro ao excluir o tipo do produto.");
            }
            });
            // trata erro quando era excluido uma linha do dom sem ser a ultima, dulplicava valores.
            qtdProdAereo--;
            

            // evita de enviar valor nulo para a base depois de excluir um tipo de produto no DOM.
           $("inpQtdProdAereo").value = qtdProdAereo;
           
        }
    }
    
    
 // implementação de tipos de produtos cia aerea(Fim).   
    function carregarCidadeAjax(textResposta){
        try{
            var lista = jQuery.parseJSON(textResposta);
            var cidade = null;
            var length = (lista.cidade != undefined && lista.cidade.length != undefined ? lista.cidade.length : 1);
            
            if (length > 1) {
                cidade = lista.cidade[0];
            }else{
                cidade = lista.cidade;
            }
            
            $("cid_origem").value = cidade.descricaoCidade;
            $("uf_origem").value = cidade.uf;
            $("idcidadeorigem").value = cidade.idcidade;
        }catch(e){
            alert(e);
        }
    }
    
    function getCidadeAjax(cidDesc, ufDesc){
        espereEnviar("",false);
        new Ajax.Request("ConsultaSituacaoControlador?acao=carregarCidadeAjax&cidDesc="+ cidDesc+"&cidUf="+ufDesc,{
            method:"get",
            onSuccess: function(transport){
                
                carregarCidadeAjax(transport.responseText);
                //alert(textResposta.responseJSON);
            },
            onFailure: function(){}
        });
    }
    
    
    var i = 0;
    var areaLimpa = new Area();
   
    var listaTiposProduto = new Array();
                
    <%for (TipoProduto p : product_types) {%>
        listaTiposProduto[++i] = new Option("<%=p.getId()%>", "<%=p.getDescricao()%>"); 
    <%}%> 
            
        areaLimpa.tiposProdutos = listaTiposProduto;
          
        function setDefault(){
            //Apoio.to_curr(fornec.getVlsobpeso()) : "0.00")
            $("qtdGrupos").value = qtdGrupos;        
            if(<%=carregafornec%>){
            var faixa = null;
            
            <%for(FaixaPeso fp : fornec.getFaixasPeso()){%>
                    faixa = new Tabela();
                    faixa.id = "<%=fp.getId()%>";
                    faixa.tipoValor = "<%=fp.getTipoValor()%>";
                    faixa.valor = "<%=fp.getValorFaixa()%>";
                    faixa.pesoInicial = "<%=fp.getPesoInicial()%>";
                    faixa.pesoFinal = "<%=fp.getPesoFinal()%>";
                    addFaixaPeso(faixa, "tbFaixaPeso_0", 0);
            <%}%>
                
                
    <% for (int i = 0; i < fornec.getTbPrecoRedespacho().size(); i++) {%>                
                var area = new Area();                
                area.id = <%=fornec.getTbPrecoRedespacho().get(i).getId()%>;
                area.tipoTaxa = <%=fornec.getTbPrecoRedespacho().get(i).getTipoTaxa()%>;
                area.tipoPeso = <%=fornec.getTbPrecoRedespacho().get(i).getTipoPeso()%>;
                area.area = "<%=fornec.getTbPrecoRedespacho().get(i).getArea().getSigla()%>";
                area.areaId = <%=fornec.getTbPrecoRedespacho().get(i).getArea().getId()%>;
                area.vlFreteMin = <%=fornec.getTbPrecoRedespacho().get(i).getVlfreteminimo()%>;
                area.vlSobFrete = <%=fornec.getTbPrecoRedespacho().get(i).getVlsobfrete()%>;
                area.vlKgAte = <%=fornec.getTbPrecoRedespacho().get(i).getVlKgAte()%>;
                area.vlPrecoFaixa = <%=fornec.getTbPrecoRedespacho().get(i).getVlPrecoFaixa()%>;
                area.vlSobPeso = <%=fornec.getTbPrecoRedespacho().get(i).getVlsobpeso()%>;
                area.vlSobKm = <%=fornec.getTbPrecoRedespacho().get(i).getVlsobkm()%>;
                area.adVlEm = <%=fornec.getTbPrecoRedespacho().get(i).getAdVlEm()%>;
                area.vlGris = <%=fornec.getTbPrecoRedespacho().get(i).getVlGris()%>;
                area.tipoProdutoId = <%=fornec.getTbPrecoRedespacho().get(i).getTipoProdutoType().getId()%>;
                area.tiposProdutos = listaTiposProduto;                
                area.previsaoEntrega = <%=fornec.getTbPrecoRedespacho().get(i).getPrevisaoEntrega()%>;
                area.tipoPrevisaoEntrega = "<%=fornec.getTbPrecoRedespacho().get(i).getTipoPrevisaoEntrega()%>";
                area.tipoArredodamentoPeso = "<%=fornec.getTbPrecoRedespacho().get(i).getTipoArredodamentoPeso()%>";
                area.vlTaxaFixa = <%=fornec.getTbPrecoRedespacho().get(i).getTaxaFixa()%>;
                area.chkCteAutoAereo = <%=fornec.getTbPrecoRedespacho().get(i).isCteAutomaticoAereo()%>;
                area.chkAutoColeta = <%=fornec.getTbPrecoRedespacho().get(i).isAutomaticoColeta()%>;
                area.valorExcedente = <%=fornec.getTbPrecoRedespacho().get(i).getValorFaixaPesoExcedente()%>;
                area.baseCubagem = '<%=fornec.getTbPrecoRedespacho().get(i).getBaseCubagem() %>';
                area.valorTde = '<%=fornec.getTbPrecoRedespacho().get(i).getValorTde() %>';
                area.isUsarMaiorPreco = '<%=fornec.getTbPrecoRedespacho().get(i).isMaiorPrecoPesoPercentual() %>';
                area.tipoCalculo = '<%=fornec.getTbPrecoRedespacho().get(i).getTipoCalculoPercentualCte() %>';
                addArea(area);
                    $('divCteAutoAereoArea_'+<%=i + 1%>).style.display = "";
                
                <%for (FaixaPeso fp : fornec.getTbPrecoRedespacho().get(i).getFaixasPeso()) {%>
                    faixa = new Tabela();
                    faixa.id = "<%=fp.getId()%>";
                    faixa.tipoValor = "<%=fp.getTipoValor()%>";
                    faixa.valor = "<%=fp.getValorFaixa()%>";
                    faixa.pesoInicial = "<%=fp.getPesoInicial()%>";
                    faixa.pesoFinal = "<%=fp.getPesoFinal()%>";
                    faixa.indexTab = <%=i + 1%>;
                    addFaixaPeso(faixa, "tbFaixaPeso_<%=i + 1%>", <%=i + 1%>);
                <%}%>
                //function Area(area,areaId,vlFreteMin,vlSobFrete,vlKgAte,vlPrecoFaixa,vlSobPeso){
    <%}%>
    <%for (int i = 0; i < fornec.getFornecedorGrupoCliente().size(); i++) {%>
                fgc = new FornecedorGrupoCliente();
                fgc.id = <%= fornec.getFornecedorGrupoCliente().get(i).getId()%>;
                fgc.idFornecedor = <%= fornec.getFornecedorGrupoCliente().get(i).getFornecedor().getId()%>;
                fgc.idGrupo = <%= fornec.getFornecedorGrupoCliente().get(i).getGrupoCliente().getId()%>;
                fgc.descricaoGrupo = "<%= fornec.getFornecedorGrupoCliente().get(i).getGrupoCliente().getDescricao()%>";
                addFornecedorGrupoCliente(fgc); 
    <% }%>
        
            }
        
            $("tipoTaxa").value = <%=fornec.getTipoTaxa()%>;
            $("tipoProdutoId").value = <%=fornec.getTipoProdutoType().getId()%>;
            
            alterarTipoTaxa();
            povoarSelect($('tipoPeso_0'), listTpPeso);
            AlternarAbasGenerico('tdDadosFinanceiroContabil','dvInfoFinanceiroContabil');
            $('tipoPeso_0').value = '<%=(carregafornec && (fornec.getTipoPeso() != null && !fornec.getTipoPeso().equals("")) ? fornec.getTipoPeso() : 1)%>';
            $('tipoPrevisaoEntrega').value = '<%=(carregafornec && (fornec.getTipoPrevisaoEntrega() != null && !fornec.getTipoPrevisaoEntrega().equals("")) ? fornec.getTipoPrevisaoEntrega() : "u")%>';
            $('vlPrecoExcedente_0').value = colocarVirgula(parseFloat('<%=(carregafornec ? fornec.getValorFaixaPesoExcedente() : 0)%>'));
            alterarTipoPeso();mostrarInfoRepresentante();mostrarInfoTabPrecoCiaAerea();
          
        }
    
        function getEnderecoByCep(cep, isIgnoraEndereco){
            espereEnviar("",true);	  		
            new Ajax.Request("./jspcadcliente.jsp?acao=getEnderecoByCep&cep="+ cep,
            {
                method:"get",
                onSuccess: function(transport){
                    var response = transport.responseText;
                    carregaCepAjax(response, isIgnoraEndereco);
                },
                onFailure: function(){ }
            });
        }

        function carregaCepAjax(resposta, isIgnoraEndereco){
            
            var rua = resposta.split("@@")[1];
            var bairro = resposta.split("@@")[2];
            var cidade = resposta.split("@@")[4];
            var idCidade = resposta.split("@@")[5];
            var uf = resposta.split("@@")[6];

            //visto com deivid que havia uma validacao aqui, foi removida.
            $("endereco").value = rua;
            $("bairro").value = bairro;
            $("cid_origem").value = cidade;
            $("uf_origem").value = uf;
            $("idcidadeorigem").value = idCidade;
            
            espereEnviar("",false);	  		
        }
    
        function atribuicombos(){
    <%
        if (fornec != null) {%>
                getObj("tipo_vendedor").value = "<%=cadfornec.getVendedor().getTipoVendedor()%>";
                getObj("tipocgc").value = "<%=fornec.getTipoCgc()%>";
                getObj("solucoesPedagio").value = "<%=fornec.getSolucaoPedagio().getId()%>";
                getObj("tipoConta").value = "<%=fornec.getTipoContaAdiantamentoExpers()%>";
    <%}%>
            getTipoCgc();
        }

        function voltar(){
            var goValue = parseFloat(isIE()? -2 : -1);
            if ((isIE() && history.length == 0) || (!isIE() && history.length == 1))
                parent.document.location.replace("ConsultaControlador?codTela=14");
            else {
                history.back(); 
                history.go(goValue); 
            }
        }

        function salva(acao){
            var isObrigaRNTRC = '<%=cfg.isRntrc()%>';
            
            function ev(resp, st){
                if (st == 200){
                    if (resp.split("<=>")[1] != ""){
                        alert(resp.split("<=>")[1]);
                    }else{
                        voltar();
                    }
                }else{
                    alert("Status "+st+"\n\nNão conseguiu realizar o acesso ao servidor!");
                }   
                document.getElementById("salvar").disabled = false;
                document.getElementById("salvar").value = "Salvar";    
            }

            var cgc = "";
            if($('tipocgc').value == 'F'){
                cgc = formatCpfCnpj($("cpfcnpj").value,false,false);
            } else {
                cgc = formatCpfCnpj($("cpfcnpj").value,false,true);
            }
       
            /*Bloco de instrucoes
             */
    
        
            if (!($("desativarFornecedor").checked)) {
    
    
            if (wasNull("razaosocial,cpfcnpj")){
                alert("Preencha os campos corretamente!");
                return false;
          
            }else if (<%=cfg.isNome_fantasia_fornecedor_obrigatorio()%> && ($('fantasia').value == '' ) && $("tipocgc").value == 'J'){
                alert ("Informe o nome fantasia corretamente.");    
                return false;
            } else if (<%=cfg.isCep_fornecedor_obrigatorio()%> &&  ($('cep').value == '' ) ){
                alert ("Informe o CEP corretamente.");    
                return false;
            }else if (<%=cfg.isEndereco_fornecedor_obrigatorio()%> && ($('endereco').value == '' )  ){
                
//                alert ("Informe o endereço corretamente.");    
//                return false;
            }else if(<%=cfg.isEndereco_fornecedor_obrigatorio()%> && ($('bairro').value == '' ) ){
//                alert ("Informe o bairro corretamente.");    
//                return false;
            }else if(<%=cfg.isEndereco_fornecedor_obrigatorio()%> && ($('cid_origem').value == '' ) ){
//                alert ("Informe o cidade corretamente.");    
//                return false;
            }else if (<%=cfg.isConta_contabil_fornecedor_obrigatorio()%> &&  ($('idContaProvisao').value == '0' ) ){
                alert ("Informe a conta contábil corretamente.");    
                return false;
            }else if (<%=cfg.isIe_fornecedor_obrigatorio()%> &&  ($('identinscest').value == '' ) ){
                alert ("Informe a inscrição estadual/RG corretamente.");    
                return false;
            }else if ($('integrafiscal').checked || $('validaChk').checked){
                var cnpj = $('cpfcnpj').value;

                if($('tipocgc').value == 'F'){
                    if(!isCpf(cnpj)){
                        alert("CPF inválido!");
                        $('cpfcnpj').focus();
                        return false;
                    }
                }else{
                    if(!isCnpj(cnpj)){
                        alert("CNPJ inválido!");
                        $('cpfcnpj').focus();
                        return false;
                    }                        
                }
            }
            if((<%= cfg.isProprietarioDataNascimentoObrigatorio() %>) && ($("chkProprietario").checked) && ($("dataNascimentoS").value == '' )){
//                showErro("O campo de Data de Nascimento é obrigatorio quando o fornecedor for do tipo Proprietário!. ",$("dataNascimentoS"))
//                return false;
            }else if(<%= cfg.isProprietarioEnderecoObrigatorio() %> && ($("chkProprietario").checked) && ($("endereco").value == "")){
//                showErro("O campo de Endereço é obrigatorio quando o fornecedor for do tipo Proprietário!. ",$("endereco"))
//                return false;
            }else if(<%= cfg.isProprietarioRgOrgaoObrigatorio() %>  && ($("chkProprietario").checked) && ($("identinscest").value == "")){
//                showErro("O campo de RG/IE é obrigatorio quando o fornecedor for do tipo Proprietário!. ",$("identinscest"))
//                return false;
            }else if(<%= cfg.isProprietarioTelefoneObrigatorio() %> && ($("chkProprietario").checked) && ($("fone1").value == "")){
//                showErro("O campo de Telefone é obrigatorio quando o fornecedor for do tipo Proprietário!. ",$("fone1"))
//                return false;
            }else if(<%= cfg.isProprietarioPisPasepObrigatorio() %> && ($("chkProprietario").checked) && ($("tipocgc").value == "F" && $("pisPasep").value == "")){
//                showErro("O campo de Pis/Pasep é obrigatorio quando o fornecedor for do tipo Proprietário!. ",$("pisPasep"))
//                return false;
            }
            if($('chkProprietario').checked){
                if(isObrigaRNTRC == "true" && ($('numeroRntrc').value == 0 || $('numeroRntrc').value == "" || $('numeroRntrc').value == null)){
//                    alert ("Informe o número do RNTRC corretamente!");
//                return false;
                }
            }
            
            var i=1;
            while($("areaId_"+i) != undefined && $("areaId_"+i) != null){
                if($("areaId_"+i).value == 0){
                    alert ("Informe a área corretamente.");
                    return false;
                }
                i++
            }
            
            for(var i = 1 ; i <= qtdGrupos; i++){
                if($("descricaoGrupo"+i).value == ""){
                    if(i > 1){
                        alert(i+"º grupo não informado!");
                    }else{
                        alert("Grupo não informado!");
                    }
                    $("btnGrupo"+i).focus();
                    return false;
                }
            }
            
            
                if($("loginRepresentante").value.trim().length > 0 && ($("senhaRepresentante").value === "" || $("repetir").value === "") ){
                    alert("Informe uma senha para este fornecedor.");
                    return false;
                }else if( $("loginRepresentante").value.trim().length === 0 && ($("senhaRepresentante").value.trim().length > 0 || $("repetir").value.trim().length > 0) ){
                    alert("Informe um login para este fornecedor.");
                    return false;
                }else if($("senhaRepresentante").value !== $("repetir").value){
                    alert("As senhas informadas não são iguais.");
                    return false;
                }
            }
            
            if ($('chkCompanhiaAerea').checked  == true && !validaFaixasPeso()){
                return false;
            }
            
            if (countOcorrenciaFornecedor > 0) {
                for (var i = 0; i < countOcorrenciaFornecedor; i++) {
                    if ($('dataOcorrencia_'+ i)) {
                        let data = $('dataOcorrencia_'+ i).value;
                        let hora = $('horaOcorrencia_'+ i).value;
                        
                        let resolvido = $('resolvido_'+ i).checked;
                        let dataResolucao = $('dataResolucao_'+ i).value;
                        let horaResolucao = $('horaResolucao_'+ i).value;

                        if (data === '' || hora === '') {
                            showErro('informe a data e hora da ocorrencia corretamente');
                            return false;
                        }

                        if (resolvido) {
                            if (dataResolucao === '' || horaResolucao === '') {
                                    showErro('informe a data e hora da resolução da ocorrencia corretamente');
                                    return false;
                                }
                            }
                        }
                    }
                }
            
            
            $("salvar").disabled = true;
            $("salvar").value = "Enviando...";
            if (acao == "atualizar")
                acao += "&idfornecedor=<%=(carregafornec ? cadfornec.getFornecedor().getIdfornecedor() : 0)%>";
                
            $('formulario').action = "./cadfornecedor.jsp?acao=" + acao + "&cpfcnpj=" + cgc;
            window.open('about:blank', 'pop', 'width=210, height=100');
            $('formulario').submit();
            
                      
        }
        
                  
        function excluirFornecedor(id){
            if (confirm("Deseja mesmo excluir este fornecedor?")){
                if(confirm("Tem certeza?")){
                window.open('./cadfornecedor.jsp?acao=excluir&idfornecedor='+id, 'pop', 'width=210, height=100');
                
                
//                    if (id != 0) {
//                        new Ajax.Request("./cadfornecedor.jsp?acao=excluir&idfornecedor="+id),
//                        {
//                            method:'get',
//                            onSuccess: function(){ alert('Grupo '+ grupo + ' removido com sucesso!') },
//                            onFailure: function(){ alert('Erro ao excluir o grupo '+ grupo +'!') }
//                        
//                        }
//                    }else{/*$("iptSiglaOpcional_"+index1+"_"+index2).checked=true;*/}
//                    Element.remove($(linha));
//                    qtdGrupos--;
//                    $('qtdGrupos').value = qtdGrupos;
                }
   
            }
          
            //requisitaAjax("./cadfornecedor?acao=excluir&idfornecedor="+id, ev);
        }
        
        
        //Funções relacionadas a aeroportos !!!! -->
                
        function mostrarInfoRepresentante(){
            
            if($('chkRedespachante').checked  == true){
                visivel($('tdAeroporto'));
                visivel($("trAltera"));
                visivel($('tdTabPreco'));
                
            }else{
                invisivel($('tdTabPreco'));
                invisivel($('tdAeroporto'));
                $('aeroportoDesc').value = '';
                $('aeroporto_id').value = '';
                $('aeroporto').value = '';
                invisivel($("trAltera"));
            }
            
        }
        
        function mostrarInfoTabPrecoCiaAerea(){
            if($('chkCompanhiaAerea').checked  == true){
                visivel($('tdTabPrecoCiaAerea'));
                    visivel($('dviTipoProdutoAereo'));
                    
                
            }else{
                invisivel($('tdTabPrecoCiaAerea'));
                invisivel($('dviTipoProdutoAereo'));
                
            }
        }
        
       
        
        function limpaAeroporto(){
            $("aeroportoDesc").value = "";
            $("aeroporto_id").value = 0;
        }
            
        // Fim das Funções relacionadas a aeroportos !!!! -->
        
        
        function aoClicarNoLocaliza(idjanela)
        {          
            if (idjanela == "Plano_de_contas"){
                $("idContaProvisao").value = $("plano_contas_id").value;
                $("codigoContaProvisao").value = $("cod_conta").value;
                $("descricaoPlanoConta").value = $("plano_conta_descricao").value;
            }else  if (idjanela == "IRRF_retido"){
                $("idIrrfRetido").value = $("plano_contas_id").value;
                $("codigoIrrfRetido").value = $("cod_conta").value;                        
                $("descricaoIrrfRetido").value = $("plano_conta_descricao").value;
            }else if ((idjanela == "Area")){
                $("area_"+$("indexAux").value).value = $("sigla_area").value; 
                $("areaId_"+$("indexAux").value).value = $("area_id").value;
                if($("area_id").value != 0){
                    $("divCteAutoAereoArea_"+$("indexAux").value).style.display = "";
                }
            }else if((idjanela == "Grupo")){
                if(indexGrupo != 0){
                    $("grupoId"+indexGrupo).value =   $("grupo_id").value;
                    $("descricaoGrupo"+indexGrupo).value =   $("grupo").value;
                }
                
            }else if((idjanela == "Aeroporto")){
                $("aeroportoDesc").value =   $("aeroporto").value;
            }else if (idjanela.indexOf("Aeroporto_Coleta") > -1) {
                var index = idjanela.split("_")[2];
                $("aeroportoColeta_"+index).value = $("aeroporto").value;
                $("aeroportoColetaId_"+index).value = $("aeroporto_id_orig").value;
            }else if (idjanela.indexOf("Aeroporto_Entrega") > -1) {
                var index = idjanela.split("_")[2];
                $("aeroportoEntrega_"+index).value = $("aeroporto").value;
                $("aeroportoEntregaId_"+index).value = $("aeroporto_id_dest").value;
            } else if(idjanela == "Ocorrencia_Ctrc") {
               
               let usuario = '<%=Apoio.getUsuario(request).getNome()%>';
               let idUsuario = '<%=Apoio.getUsuario(request).getId()%>';
               let ocorrencia_id = $('ocorrencia_id').value;        
               let ocorrencia = $('ocorrencia').value;
               let descricao_ocorrencia = $('descricao_ocorrencia').value;
               let dataAtual = '<%=Apoio.getDataAtual()%>';
               let horaAtual = '<%=Apoio.getHoraAtual()%>';
               let obrigaResolucao = $('obriga_resolucao').value;

               addNovaOcorrencia(idUsuario, usuario, ocorrencia_id, ocorrencia, descricao_ocorrencia, dataAtual, horaAtual, obrigaResolucao);
            }
        }
        

        function getTipoCgc(){
            if ($('tipocgc').value == 'J'){
                $('lbIe').innerHTML = '*I.E.:';
                $('lbIm').innerHTML = 'I.M.:';
                $('trPis').style.display = 'none';
                $('dataexplabel').style.display = 'none';
                $('dataexpinput').style.display = 'none';
            }else{
                $('lbIe').innerHTML = 'R.G.:';
                $('lbIm').innerHTML = 'Org.:';
                $('trPis').style.display = '';
                $('dataexplabel').style.display = '';
                $('dataexpinput').style.display = '';
            }
        }

        function getAjudaPercentual(){
            var mensagem = "Esse campo serve para o sistema calcular o valor do contrato de frete automaticamente ao incluir um CTRC, segue abaixo uma simulação:\n" +
                "1.000,00 = Valor do CTRC\n"+
                "   120,00 = Valor do ICMS\n"+
                "     50,00 = Valor do Seguro\n"+
                "   130,00 = Custo de viagem\n"+
                "   700,00 = Valor líquido\n"+
                "Nesse exemplo vamos utilizar 50%, sendo assim o valor do contrato de frete será 35,00.\n"+
                "Observações:\n"+
                "1) Essa funcionalidade só funcionará caso esteja habilitada em configurações a opção (Gerar contrato de frete automaticamente ao incluir um CTRC). \n"+
                "2) Esse percentual terá prioridade caso o valor do contrato de frete também esteja informado no cadastro de rota. \n";
            alert(mensagem);
        }
  
        function abrirConsultarCliente(){
            var camposConsultaCliente = new CamposSituacaoPessoa();
            camposConsultaCliente.idCNPJ = "cpfcnpj";
            camposConsultaCliente.idRazaoSocial = "razaosocial" ;
            camposConsultaCliente.idNomeFantasia = "fantasia";
            camposConsultaCliente.idCep = "cep";
            camposConsultaCliente.idLogradouro = "endereco";
            camposConsultaCliente.idLogradouroNumero = "logradouro";
            camposConsultaCliente.idBairro = "bairro";
            camposConsultaCliente.idCidade = "cid_origem";
            camposConsultaCliente.idUf = "uf_origem";
            try {
                if ($("cpfcnpj").value !="") {
                    tryRequestToServer(function(){
                        abrirLocaliza("ConsultaSituacaoControlador?acao=iniciarConsultarPessoaJuridica&cnpj="+$("cpfcnpj").value+"&campos="+encodeURIComponent(camposConsultaCliente.toStr()), "conSitPessoa");
                    });
                }
            } catch (e) { 
                alert(e);
            }
        }
        
        function abrirLocalizarArea(linha){
            try{
                $("indexAux").value = linha;
                post_cad = window.open('./localiza?acao=consultar&idlista=34','Area',
                'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
            }catch(e){
                alert(e);
            }
        }
      
        function limparArea(linha){
            $("area_"+linha).value = "Area";
            $("areaId_"+linha).value = "0";
        }
        function Area(id,tipoTaxa,area,areaId,vlFreteMin,vlSobFrete,vlKgAte,vlPrecoFaixa,vlSobPeso,vlSobKm,adVlEm,vlGris,
        tiposProdutos,tiposProdutoId,previsaoEntrega,tipoPrevisaoEntrega,vlTaxaFixa,chkCteAutoAereo,tipoArredodamentoPeso, tipoPeso, valorExcedente, chkAutoColeta,
        baseCubagem,valorTde,isUsarMaiorPreco,tipoCalculo){
            this.id = (id != null && id != undefined)?id:"0";
            this.valorExcedente = (valorExcedente != null && valorExcedente != undefined)?valorExcedente:0;
            this.tipoTaxa = (tipoTaxa != null && tipoTaxa != undefined)?tipoTaxa:0;
            this.tipoPeso = (tipoPeso != null && tipoPeso != undefined && tipoPeso != '')?tipoPeso:1;
            this.area = (area != null && area != undefined && area !="null")?area:"";
            this.areaId = (areaId != null && areaId != undefined)?areaId:"0";
            this.vlFreteMin = (vlFreteMin != null && vlFreteMin != undefined)?vlFreteMin:"0.00";
            this.vlSobFrete = (vlSobFrete != null && vlSobFrete != undefined)?vlSobFrete:"0.00";
            this.vlKgAte = (vlKgAte != null && vlKgAte != undefined)?vlKgAte:"0.00";
            this.vlPrecoFaixa = (vlPrecoFaixa != null && vlPrecoFaixa != undefined)? vlPrecoFaixa:"0.00";
            this.vlSobPeso = (vlSobPeso != null && vlSobPeso != undefined)? vlSobPeso:"0.00";
            this.vlSobKm = (vlSobKm != null && vlSobKm != undefined)? vlSobKm:"0.00";
            this.adVlEm = (adVlEm != null && adVlEm != undefined)? adVlEm:"0.00";
            this.vlGris = (vlGris != null && vlGris != undefined)? vlGris:"0.00";
            this.tiposProdutos = (tiposProdutos != null && tiposProdutos != undefined)? tiposProdutos:0;
            this.tipoProdutoId = (tiposProdutoId != null && tiposProdutoId != undefined)? tiposProdutoId:0;
            this.previsaoEntrega = (previsaoEntrega != null && previsaoEntrega != undefined)? previsaoEntrega:0;
            this.tipoPrevisaoEntrega = (tipoPrevisaoEntrega != null && tipoPrevisaoEntrega != undefined && tipoPrevisaoEntrega != '')? tipoPrevisaoEntrega:"u";
            this.vlTaxaFixa = (vlTaxaFixa != null && vlTaxaFixa != undefined)? vlTaxaFixa:"0.00";            
            this.chkCteAutoAereo = (chkCteAutoAereo != null && chkCteAutoAereo != undefined) ? chkCteAutoAereo : "";
            this.tipoArredodamentoPeso = (tipoArredodamentoPeso != null && tipoArredodamentoPeso != undefined) ? tipoArredodamentoPeso : "n";
            this.chkAutoColeta =   (chkAutoColeta!=null && chkAutoColeta!=undefined)? chkAutoColeta : "";
            this.baseCubagem =   (baseCubagem!=null && baseCubagem!=undefined)? baseCubagem : "0.00";
            this.valorTde =   (valorTde!=null && valorTde!=undefined)? valorTde : "0.00";
            this.isUsarMaiorPreco =   (isUsarMaiorPreco!=null && isUsarMaiorPreco!=undefined)? isUsarMaiorPreco : "false";
            this.tipoCalculo =   (tipoCalculo!=null && tipoCalculo!=undefined)? tipoCalculo : "b";
                        
        }
        
        
        var countArea = 0;
        function addArea(area){
            var callSeNaoFloatReset = "seNaoFloatReset(this,'0.00')"; 
            try{
                if(area == null || area == undefined){
                    area = new Area();
                }
                   
                var lista = area.tiposProdutos;
                countArea++;
                var _tbBase = $("tbBase");
                
                var _tr = Builder.node("tr",{name:"trArea_"+countArea,id:"trArea_"+countArea,className:((countArea % 2)== 0 ? "CelulaZebra1" : "CelulaZebra2")});                
                var _tr2 = Builder.node("tr",{name:"trArea2_"+countArea,id:"trArea2_"+countArea,className:((countArea % 2)== 0 ? "CelulaZebra1" : "CelulaZebra2")});                
                var _tr1 = Builder.node("tr",{name:"trArea1_"+countArea,id:"trArea1_"+countArea,className:((countArea % 2)== 0 ? "CelulaZebra1" : "CelulaZebra2")});                
                var _td0 = Builder.node("td",{name:"tdVlArea_"+countArea,id:"tdVlArea_"+countArea, width:"13%"});
                var _td1 = Builder.node("td",{name:"tdVlTipoArea_"+countArea,id:"tdVlTipoArea_"+countArea, width:"6%"});
                var _td2 = Builder.node("td",{name:"tdVlAtekgArea_"+countArea,id:"tdVlAtekgArea_"+countArea, width:"7%"});
                var _td3 = Builder.node("td",{name:"tdVlPrecoFaixaArea_"+countArea,id:"tdVlPrecoFaixaArea_"+countArea, width:"9%"});
                var _td4 = Builder.node("td",{name:"tdVlSobPesoArea_"+countArea,id:"tdVlSobPesoArea_"+countArea, width:"9%"});
                var _td5 = Builder.node("td",{name:"tdVlTipoProdutoArea_"+countArea,id:"tdVlTipoProdutoArea_"+countArea, width:"6%"});
                var _td12 = Builder.node("td",{name:"tdVlsobKm_"+countArea,id:"tdVlsobKm_"+countArea, width:"5%"});
                var _td6 = Builder.node("td",{name:"tdVlAdVlEmArea_"+countArea,id:"tdVlAdVlEmArea_"+countArea, width:"6%"});
                var _td7 = Builder.node("td",{name:"tdVlGrisArea_"+countArea,id:"tdVlGrisArea_"+countArea, width:"5%"});
                var _td8 = Builder.node("td",{name:"tdVlTaxaFixaArea_"+countArea,id:"tdVlTaxaFixaArea_"+countArea, width:"5%"});
                var _td9 = Builder.node("td",{name:"tdVlFreteMinArea_"+countArea,id:"tdVlFreteMinArea_"+countArea, width:"7%"});
                var _td10 = Builder.node("td",{name:"tdVlPrevisaoEntregaArea_"+countArea,id:"tdVlPrevisaoEntregaArea_"+countArea, width:"10%"});
                var _td11 = Builder.node("td",{name:"tdCteAutoAereoArea_"+countArea, id:"tdCteAutoAereoArea_"+countArea, colspan:"3"});
                var _td13 = Builder.node("td",{name:"tdTipoArredodamentoPeso_"+countArea, id:"tdTipoArredodamentoPeso_"+countArea, colspan:"3"});
                var _td14 = Builder.node("td",{name:"tdAutoColetas_"+countArea, id:"tdAutoColetas_"+countArea, colspan:"6"});
                
                var _td15 = Builder.node("td",{name:"tdBaseCubagem_"+countArea, id:"tdBaseCubagem_"+countArea, colspan: "2"});
                var _td16 = Builder.node("td",{name:"tdValorTde_"+countArea, id:"tdValorTde_"+countArea, colspan: "2"});
                var _td17 = Builder.node("td",{name:"tdUsarMaiorPreco_"+countArea, id:"tdUsarMaiorPreco_"+countArea, colspan: "2"});
                var _td18 = Builder.node("td",{name:"tdTipoCalculo_"+countArea, id:"tdTipoCalculo_"+countArea, colspan: "7"});
                
                var _imgExcluir = Builder.node("img",{name:"excluirArea",id:"excluirArea",src:"img/lixo.png",style:"float:left",className:"img/lixo.png",onClick:"deleteArea("+countArea+")"});
                // Id da TabelaPrecoRedespacho
                var _inpId = Builder.node("input",{type:"hidden",value:area.id,id:"id_"+countArea,name:"id_"+countArea});
                
                var _inpArea = Builder.node("input",{name:"area_"+countArea,id:"area_"+countArea,className:"inputReadOnly8pt",size:"10",value:(area.area == "")?"Area":area.area,readOnly:true});
                var _inpAreaId = Builder.node("input",{name:"areaId_"+countArea,id:"areaId_"+countArea,type:"hidden",value:area.areaId});
                var _inpAreaIdApagar = Builder.node("input",{name:"areaIdApagar_"+countArea,id:"areaIdApagar_"+countArea,type:"hidden",value:area.id});
                var _btArea = Builder.node("input",{name:"btArea_"+countArea,id:"btArea_"+countArea,type:"button",value:"...",className:"inputBotaoMin",onClick:"abrirLocalizarArea("+countArea+")"});
                //var _img = Builder.node("img",{src:"img/borracha.gif",alt:"", name:"borrachaArea",className:"imagemLink", id:"borrachaArea",onClick:"limparArea("+countArea+")"});
                
                var _inpFreteMin = Builder.node("input",{name:"vlFreteMinArea_"+countArea,id:"vlFreteMinArea_"+countArea,className:"fieldMin",onBlur:"seNaoFloatReset(this,'0.00')",size:"8",value:area.vlFreteMin,style:'float:left;', clickin:"true"}); 
                var _inpSobFrete = Builder.node("input",{name:"vlSobFreteArea_"+countArea,id:"vlSobFreteArea_"+countArea,className:"fieldMin",onBlur:"seNaoFloatReset(this,'0.00')",size:"8",value:area.vlSobFrete,style:'float:left;', clickin:"true"});
                var _inpVlKgAte = Builder.node("input",{name:"vlKgAteArea_"+countArea,id:"vlKgAteArea_"+countArea,className:"fieldMin",onBlur:"seNaoFloatReset(this,'0.00')",size:"8",value:area.vlKgAte});
                var _inpPrecoFaixa = Builder.node("input",{name:"vlPrecoFaixaArea_"+countArea,id:"vlPrecoFaixaArea_"+countArea,className:"fieldMin",onBlur:"seNaoFloatReset(this,'0.00')",size:"8",value:area.vlPrecoFaixa,style:'float:left;', clickin:"true"});
                var _inpSobPeso = Builder.node("input",{name:"vlSobPesoArea_"+countArea,id:"vlSobPesoArea_"+countArea,className:"fieldMin",size:"8",onblur:"seNaoFloatResetQuatroCasasDecimais(this,'0.0000')",value:area.vlSobPeso,style:'float:left;', clickin:"true"});
                var _inpSobKm = Builder.node("input",{name:"vlSobKm_"+countArea,id:"vlSobKm_"+countArea,className:"fieldMin",onBlur:"seNaoFloatReset(this,'0.00')",size:"8",maxLength:"8",value:area.vlSobKm,style:'float:left;', clickin:"true"});
                var _inpAdVlEm = Builder.node("input", {name:"adVlEmArea_"+countArea, id:"adVlEmArea_"+countArea, className:"fieldMin", onBlur:"seNaoFloatReset(this,'0.00')",size:"8",maxLength:"8",value:area.adVlEm,style:'float:left;', clickin:"true"});
                var _inpGris = Builder.node("input", {name:"vlGrisArea_"+countArea, id:"vlGrisArea_"+countArea, className:"fieldMin", onBlur:"seNaoFloatReset(this,'0.00')",size:"8",maxLength:"8",value:area.vlGris,style:'float:left;', clickin:"true"});
                var _inpPrevisaoEntrega = Builder.node("input", {name:"vlPrevisaoEntregaArea_"+countArea, id:"vlPrevisaoEntregaArea_"+countArea, className:"fieldMin", onKeyPress: "mascara(this, soNumeros)", onBlur:"seNaoIntReset(this,'0')",size:"3",maxLength:"5",value:area.previsaoEntrega, clickin:"true"});
                var _inpTaxaFixa = Builder.node("input", {name:"vlTaxaFixaArea_"+countArea, id:"vlTaxaFixaArea_"+countArea, className:"fieldMin", onBlur:"seNaoFloatReset(this,'0.00')",size:"8",maxLength:"8",value:area.vlTaxaFixa,style:'float:left;', clickin:"true"});
                if(area.chkCteAutoAereo){
                    var _inpCteAutoAereo = Builder.node("input",{name:"chkCteAutoAereoArea_"+countArea, id:"chkCteAutoAereoArea_"+countArea, className:"fieldMin", type:"checkbox", value:"checkbox", checked:""});
                }else{
                    var _inpCteAutoAereo = Builder.node("input",{name:"chkCteAutoAereoArea_"+countArea, id:"chkCteAutoAereoArea_"+countArea, className:"fieldMin", type:"checkbox", value:"checkbox"});
                } 
                
                if(area.chkAutoColeta){
                    var _inpCteAutoColetas = Builder.node("input",{name:"chkAutoColeta_"+countArea, id:"chkAutoColeta_"+countArea, className:"fieldMin", type:"checkbox", value:"checkbox", checked:""});
                }else{
                    var _inpCteAutoColetas = Builder.node("input",{name:"chkAutoColeta_"+countArea, id:"chkAutoColeta_"+countArea, className:"fieldMin", type:"checkbox", value:"checkbox"});
                } 
                
                
                // novos campos - 03-04-2014
                var _impTipoNaoArredodamentoPeso = Builder.node("input",{id:"rTipoArredodamentoNao_"+countArea,name:"rTipoArredodamento_"+countArea, className:"fieldMin",type:"radio", value:"n"});
                var _impTipoPadraoArredodamentoPeso = Builder.node("input",{id:"rTipoArredodamentoPadrao_"+countArea,name:"rTipoArredodamento_"+countArea, className:"fieldMin",type:"radio", value:"p"});
                var _impTipoCimaArredodamentoPeso = Builder.node("input",{id:"rTipoArredodamentoPraCima_"+countArea,name:"rTipoArredodamento_"+countArea, className:"fieldMin",type:"radio", value:"c"});
                var _inpPesoInicial = Builder.node("input", {name:"pesoInicialArea_"+countArea, id:"pesoInicialArea_"+countArea, className:"fieldMin", onBlur:"seNaoFloatReset(this,'0.00')",size:"8",maxLength:"8",value:area.adVlEm,style:'float:left;', clickin:"true"});
                var _inpPesoFinal = Builder.node("input", {name:"pesoFinalArea_"+countArea, id:"pesoFinalArea_"+countArea, className:"fieldMin", onBlur:"seNaoFloatReset(this,'0.00')",size:"8",maxLength:"8",value:area.adVlEm,style:'float:left;', clickin:"true"});
                
                switch(area.tipoArredodamentoPeso){
                    case "n":
                        _impTipoNaoArredodamentoPeso.checked = true;
                        break;
                    case "p":
                        _impTipoPadraoArredodamentoPeso.checked = true;
                        break;
                    case "c":
                        _impTipoCimaArredodamentoPeso.checked = true;
                        break;
                }

                var _select = Builder.node("select",{name:"tipoTaxa_"+countArea,id:"tipoTaxa_"+countArea,className:"inputtexto",onChange:"alterarTipoTaxa("+countArea+")",style:"width:80px;"});
                var _opt0 = Builder.node("option",{value:"0"},'Por Peso');
                var _opt2 = Builder.node("option",{value:"2"}, '% Frete');
                var _opt3 = Builder.node("option",{value:"3"}, 'Valor Combinado');
                var _opt5 = Builder.node("option",{value:"5"}, 'Por KM');
                
                _select.appendChild(_opt0);
                _select.appendChild(_opt2);
                _select.appendChild(_opt3);
                _select.appendChild(_opt5);
        
                if (area.tipoTaxa != "") {
                    _select.value = area.tipoTaxa;
                }else{
                    _select.selectedIndex = 0;
                }
                
                var _selectPeso = Builder.node("select",{name:"tipoPeso_"+countArea,id:"tipoPeso_"+countArea,className:"inputtexto",onChange:"alterarTipoPeso("+countArea+")",style:"width:80px;"});
                povoarSelect(_selectPeso, listTpPeso);
                if (area.id != 0) {
                    _selectPeso.value = area.tipoPeso;
                }else{
                    _selectPeso.selectedIndex = 0;
                }
                var _qtdFaixaPeso = Builder.node("input",{name:"qtdFaixaPeso_"+countArea,id:"qtdFaixaPeso_"+countArea, value: 0, type: "hidden"});
                
                var _selectPrevisaoEntrega = Builder.node("select",{name:"tipoPrevisaoEntregaArea_"+countArea,id:"tipoPrevisaoEntregaArea_"+countArea,className:"inputtexto",style:"width:80px;"});
                var _optPrevisaoEntrega0 = Builder.node("option",{value:"u"}, 'Dias Uteis');
                var _optPrevisaoEntrega1 = Builder.node("option",{value:"c"}, 'Dias Corridos');
                var _optPrevisaoEntrega2 = Builder.node("option",{value:"e"}, 'Dias Corrigos com entrega em dia útil');               
                
                
                _selectPrevisaoEntrega.appendChild(_optPrevisaoEntrega0);
                _selectPrevisaoEntrega.appendChild(_optPrevisaoEntrega1);
                _selectPrevisaoEntrega.appendChild(_optPrevisaoEntrega2);           
                
                _selectPrevisaoEntrega.value = area.tipoPrevisaoEntrega;
                               
                
                var _selectTipoProduto = Builder.node("select",{name:"tipoProdutoArea_"+countArea,id:"tipoProdutoId_"+countArea,className:"inputtexto",style:"width:80px;"});
                var _optTipoProduto0 = Builder.node("option",{value:"0"}, 'Nenhum');
                
                _selectTipoProduto.appendChild(_optTipoProduto0);                           
                   
                
                var _optTipoProduto1;
                
                for(var i = 1; i < lista.length; i++){                    
                    _optTipoProduto1 = Builder.node("option", {
                        value:lista[i].valor
                    });
                    Element.update(_optTipoProduto1, lista[i].descricao);
                    _selectTipoProduto.appendChild(_optTipoProduto1); 
                }
                
                _selectTipoProduto.value = area.tipoProdutoId;
                
                var _selectArredodamentoPeso = Builder.node("select",{name:"tipoArredodamentoPesoArea_"+countArea,id:"tipoArredodamentoPesoArea_"+countArea,className:"inputtexto",onChange:"",style:"width:150px;"});
                var _optArredodamentoPeso01 = Builder.node("option",{value:"n"},'Não Arredondar');
                var _optArredodamentoPeso02 = Builder.node("option",{value:"p"},'Arredondar Padrão');
                var _optArredodamentoPeso03 = Builder.node("option",{value:"c"},'Arredondar Pra Cima');
                
                _selectArredodamentoPeso.appendChild(_optArredodamentoPeso01);
                _selectArredodamentoPeso.appendChild(_optArredodamentoPeso02);
                _selectArredodamentoPeso.appendChild(_optArredodamentoPeso03);
                
                _selectArredodamentoPeso.value = area.tipoArredodamentoPeso;
                
                var _baseCubagem = Builder.node("input",{type:"text",value:"0.00",id:"baseCubagem_"+countArea,name:"baseCubagem_"+countArea,className:"fieldMin", size:"8", onBlur: callSeNaoFloatReset , maxlength: "8", onkeypress:"mascara(this, soNumeros)", clickin:"true"});
                var _valorTde = Builder.node("input",{type:"text",value:"0.00",id:"valorTde_"+countArea,name:"valorTde_"+countArea,className:"fieldMin", size:"8", onBlur: callSeNaoFloatReset , maxlength: "8", onkeypress:"mascara(this, soNumeros)", clickin:"true" });
                var _usarMaiorPrecoPeso = Builder.node("input",{type:"checkbox",id:"isUsarMaiorPrecoPeso_"+countArea,name:"isUsarMaiorPrecoPeso_"+countArea,className:"inputtexto"});
                var _considerarValorbruto = Builder.node("input",{type:"radio",value:"b",id:"considerarValorBruto_"+countArea,name:"considerarValor_"+countArea,className:"inputtexto"});
                var _considerarValorLiquido = Builder.node("input",{type:"radio",value:"l",id:"considerarValorLiquido_"+countArea,name:"considerarValor_"+countArea,className:"inputtexto"});
                _baseCubagem.value = area.baseCubagem > 0 ? parseFloat(area.baseCubagem) : "0.00";
                _valorTde.value = area.valorTde > 0 ? parseFloat(area.valorTde) : "0.00";
                if(area.isUsarMaiorPreco == 'true'){
                    _usarMaiorPrecoPeso.checked = 'true';
                }
                if(area.tipoCalculo == 'l'){
                    _considerarValorLiquido.checked = 'true';
                }else{
                    _considerarValorbruto.checked = 'true';
                }
                var _div0 = Builder.node("div",{align:"left"});
                var _div1 = Builder.node("div",{align:"center"});
                var _div2 = Builder.node("div",{align:"left",style:"", id:"divAteKgArea_"+countArea});
                var _div3 = Builder.node("div",{align:"left",style:"",id:"divVlPrecoFaixaArea_"+countArea});
                var _div4 = Builder.node("div",{align:"left",style:"",id:"divVlSobPesoArea_"+countArea});
                var _div5 = Builder.node("div",{align:"left"});
                var _div6 = Builder.node("div",{align:"left"});
                var _div7 = Builder.node("div",{align:"left"});
                var _div8 = Builder.node("div",{align:"left"});
                var _div9 = Builder.node("div",{align:"left"});
                var _div10 = Builder.node("div",{align:"left"});
                var _div11 = Builder.node("div",{align:"left",style:"display: none", id:"divSobFreteArea_"+countArea});
                var _div12 = Builder.node("div",{align:"left",style:"display: none",id:"divCteAutoAereoArea_"+countArea});
                var _div13 = Builder.node("div",{align:"left"});
                var _div14 = Builder.node("div",{align:"left",style:"display: none", id:"divPesoInicialArea_"+countArea});
                var _div15 = Builder.node("div",{align:"left",style:"display: none", id:"divPesoFinalArea_"+countArea});
                var _div16 = Builder.node("div",{align:"left",style:"display:",id:"divCteAutoColetas_"+countArea});
                var _div17 = Builder.node("div",{align:"left",style:"display: none", id:"divUsarMaiorPreco_"+countArea});
                var _div18 = Builder.node("div",{align:"left",style:"display: none",id:"divTipoCalculo_"+countArea});
                
                var _label0 = Builder.node("label",{});
                _label0.innerHTML = "&nbsp;";
                
                var _label1 = Builder.node("label",{align:"left",style:"display: none;float:left",id:"lblSobFrete_"+countArea});
                _label1.innerHTML = "Sob&nbsp;%&nbsp;Frete:";
                
                var _label2 = Builder.node("label",{align:"left",style:"float:left"});
                _label2.innerHTML = "";
                
                var _label3 = Builder.node("label",{align:"left"});
                _label3.innerHTML = "Km";
                
                var _label4 = Builder.node("label",{align:"left",style:"float:left",id:"lblAte_"+countArea});
                _label4.innerHTML = "Até:";
                
                var _label5 = Builder.node("label",{align:"left",style:"",id:"lblKg_"+countArea});
                _label5.innerHTML = "Kg";
                
                var _label6 = Builder.node("label",{align:"left",style:"float:left",id:"lblCobrar_"+countArea});
                _label6.innerHTML = "(R$):";
                
                var _label7 = Builder.node("label",{align:"left",style:"float:left",id:"lblExcedente_"+countArea});
                _label7.innerHTML = "Exce:";
                
                var _label8 = Builder.node("label",{align:"left"});
                _label8.innerHTML = "Definir automaticamente esse representante para ENTREGAS nas cidades dessa área.";
                
                var _label9 = Builder.node("label",{align:"left"});
                _label9.innerHTML = "Não Arredondar";
                
                var _label10 = Builder.node("label",{align:"left"});
                _label10.innerHTML = "Arredondar Padrão";
                
                var _label11 = Builder.node("label",{align:"left"});
                _label11.innerHTML = "Arredondar Pra Cima";
                
                var _label12 = Builder.node("label",{align:"left",style:"float:left",id:"lblPesoInicial_"+countArea});
                _label12.innerHTML = "Peso Inicial:&nbsp";
                
                var _label13 = Builder.node("label",{align:"left",style:"float:left",id:"lblPesoFinal_"+countArea});
                _label13.innerHTML = "Peso Final:&nbsp";
                
                var _label14 = Builder.node("label",{align:"left"});
                _label14.innerHTML = "Definir automaticamente esse representante para COLETAS nas cidades dessa área.";
                
                var _label15 = Builder.node("label",{align:"left"});
                _label15.innerHTML = "Arredondar por peso:";
                
                var _label16 = Builder.node("label",{align:"left"});
                _label16.innerHTML = "Base da Cubagem: ";
                var _label17 = Builder.node("label",{align:"left"});
                _label17.innerHTML = "Valor TDE: ";
                var _label18 = Builder.node("label",{align:"left"});
                _label18.innerHTML = " Utilizar maior preço entre peso KG e % Frete ";
                var _label19 = Builder.node("label",{align:"left"});
                _label19.innerHTML = "Considerar: ";
                var _label20 = Builder.node("label",{align:"left"});
                _label20.innerHTML = " Valor Bruto do CT-e (com ICMS) ";
                var _label21 = Builder.node("label",{align:"left"});
                _label21.innerHTML = " Valor Liquido do CT-e (sem ICMS) ";
                var _label22 = Builder.node("label",{});
                _label22.innerHTML = "&nbsp;";
                
                
                var tdExtra = Builder.node("td",{colspan: "13"});
                var tableExtra = Builder.node("table",{className: "bordaFina", width: "100%"});
                var trExtra = Builder.node("tr");
                
                var tdchkbox = Builder.node("td",{colspan: "13"});
                var tablechkbox = Builder.node("table",{className: "bordaFina", width: "100%"});
                var trchkbox1 = Builder.node("tr",{className:((countArea % 2)== 0 ? "CelulaZebra1" : "CelulaZebra2")});
                var trchkbox2 = Builder.node("tr",{className:((countArea % 2)== 0 ? "CelulaZebra1" : "CelulaZebra2")});
                
                
                
                _div0.appendChild(_imgExcluir);
                _div1.appendChild(_inpId);
                _div1.appendChild(_inpArea);
                _div1.appendChild(_inpAreaId);
                _div1.appendChild(_inpAreaIdApagar);
                _div1.appendChild(_btArea);
                //_div1.appendChild(_img);                
                _div2.appendChild(_label4);
                _div2.appendChild(_inpVlKgAte);
                _div2.appendChild(_label5);
                _div3.appendChild(_label6);
                _div3.appendChild(_inpPrecoFaixa);
                _div4.appendChild(_label7);
                _div4.appendChild(_inpSobPeso);
                _div5.appendChild(_label2);
                _div5.appendChild(_inpSobKm);
                _div5.appendChild(_label3);
                _div6.appendChild(_inpAdVlEm);
                _div7.appendChild(_inpGris);
                _div8.appendChild(_inpTaxaFixa);               
                _div9.appendChild(_inpFreteMin);
                _div10.appendChild(_inpPrevisaoEntrega);                
                _div10.appendChild(_label0);
                _div10.appendChild(_selectPrevisaoEntrega);                
                _div11.appendChild(_inpSobFrete);
               
                _div12.appendChild(_inpCteAutoColetas)
                _div12.appendChild(_label14); 
                _div16.appendChild(_inpCteAutoAereo);
                _div16.appendChild(_label8);
                // _div13.appendChild(_selectArredodamentoPeso);
                _div13.appendChild(_label15);
                _div13.appendChild(_impTipoNaoArredodamentoPeso);
                _div13.appendChild(_label9);                
                _div13.appendChild(_impTipoPadraoArredodamentoPeso);
                _div13.appendChild(_label10);                
                _div13.appendChild(_impTipoCimaArredodamentoPeso);
                _div13.appendChild(_label11);
                
                _div14.appendChild(_label12);
                _div14.appendChild(_inpPesoInicial);
                _div15.appendChild(_label13);
                _div15.appendChild(_inpPesoFinal);
                
                _td0.appendChild(_div0);
                _td0.appendChild(_div1);
                _td1.appendChild(_select);
                _td1.appendChild(_label22);
                _td1.appendChild(_selectPeso);
                _td1.appendChild(_qtdFaixaPeso);
                _td5.appendChild(_selectTipoProduto);
                _td2.appendChild(_div2);
                _td2.appendChild(_label1);
                _td2.appendChild(_div11);
                _td2.appendChild(_div14);
                //_td2.appendChild(_label2);
                //_td2.appendChild(_div5);                
                _td3.appendChild(_div3);
                _td3.appendChild(_div15);
                _td4.appendChild(_div4);
                //_td12.appendChild(_label2);
                _td12.appendChild(_div5);
                _td6.appendChild(_div6);
                _td7.appendChild(_div7);
                _td8.appendChild(_div8);                
                _td9.appendChild(_div9);
                _td10.appendChild(_div10);
                _td11.appendChild(_div13);
                _td13.appendChild(_div12);
                _td14.appendChild(_div16);
                
                _td15.appendChild(_label16);
                _td15.appendChild(_baseCubagem);
                _td16.appendChild(_label17);
                _td16.appendChild(_valorTde);
                
                _div17.appendChild(_usarMaiorPrecoPeso);
                _div17.appendChild(_label18);
                _td17.appendChild(_div17);
                _div18.appendChild(_label19);
                _div18.appendChild(_considerarValorbruto);
                _div18.appendChild(_label20);
                _div18.appendChild(_considerarValorLiquido);
                _div18.appendChild(_label21);
                _td18.appendChild(_div18);
                
                _tr.appendChild(_td0);
                _tr.appendChild(_td1);
                _tr.appendChild(_td5);
                _tr.appendChild(_td2);
                _tr.appendChild(_td3);
                _tr.appendChild(_td4);
                _tr.appendChild(_td12);
                _tr.appendChild(_td6);
                _tr.appendChild(_td7);
                _tr.appendChild(_td8);
                _tr.appendChild(_td9);
                _tr.appendChild(_td10);
                
                trchkbox1.appendChild(_td11);
                trchkbox1.appendChild(_td14);
                trchkbox2.appendChild(_td13);
                tablechkbox.appendChild(trchkbox1);
                tablechkbox.appendChild(trchkbox2);
                tdchkbox.appendChild(tablechkbox);
                _tr1.appendChild(tdchkbox);
                
                _tr2.appendChild(_td15);
                _tr2.appendChild(_td16);
                _tr2.appendChild(_td17);
                _tr2.appendChild(_td18);
                tableExtra.appendChild(_tr2);
                tdExtra.appendChild(tableExtra);
                trExtra.appendChild(tdExtra);
                
                _tbBase.appendChild(_tr1);
                _tbBase.appendChild(_tr);
                _tbBase.appendChild(trExtra);
                
                addTrFaixaPeso(countArea, _tbBase, area.valorExcedente);
                alterarTipoPeso(countArea);
                alterarTipoTaxa(countArea);            
                $("countArea").value = countArea;
                jQuery('input[clickin=true]').blur();

            }catch(e){
                alert(e);
            }
        }       
        
        function deleteArea(index){
            var area = $('area_'+index).value;
            var idArea = $('areaIdApagar_' + index).value;
            var linha =  $('trArea_' + index);
            var linha1 =  $('trArea1_' + index);
            var linha2 =  $('trArea2_' + index);
            var linhaFaixaFixo =  $('trTabelaFaixaPeso_' + index);
        
            if(confirm('Deseja excluir a area '+ area +'!')){
                if(confirm("Tem certeza?")){
                    if (idArea != 0){
                        new Ajax.Request("./cadfornecedor.jsp?acao=deletarArea&idAreaApagar=" + idArea),
                        {
                            method:'get',
                            onSuccess: function(){
                                Element.remove($(linha));
                                Element.remove($(linha1));
                                Element.remove($(linha2));
                                //countArea--;
                                $("countArea").value = countArea;
                                alert("Area  "+ area + " removida com sucesso!");} ,
                            onFailure: function(){ alert("Erro ao excluir a area"+ area +"!") }
                        
                        }
                    }else{
                
                    }
                    Element.remove($(linha));                
                    Element.remove($(linha1));        
                    Element.remove($(linha2));
                    Element.remove($(linhaFaixaFixo));                
                    //countArea--;                
                    $("countArea").value = countArea;
                }
        
    
            }
            
            
        }
        function alterarTipoTaxa(index){            
            try{
                if($("tipoTaxa").value == "0" ){                    
                    $("divVlAtekg").style.display = "";
                    $("tdVlAuxAteKg").style.display = "";
                    <%--$("vlKgAte").value = <%=fornec.getVlKgAte()%>;--%>
                    $("tdvlTipoProduto").style.display = "";
                    $("tdlblCobrar").style.display = "";
                    $("tdlblCobrar").innerHTML = " (R$):  ";
                    $("tdlblsobKm").innerHTML = " Por:  ";
                    $("tdVlPrecoFaixa").style.display = "";
                    <%--$("vlPrecoFaixa").value = <%=fornec.getVlPrecoFaixa()%>;--%>
                    $("divVlPrecoFaixa").style.display = "";
                    $("tdlblExcedente").style.display = "";                    
                    $("tdlblExcedente").innerHTML = " Exce:";                    
                    $("tdVlSobPeso").style.display = "";
                    $("divVlSobPeso").style.display = "";
                    <%--$("vlsobpeso").value = <%=fornec.getVlsobpeso()%>;--%>
                    // $("divVlSobKm").style.display = "none";
                    // $("vlsobkm").value = "0.00";
                    $("tdlbladValorEm").style.display = "";
                    $("tdAdVlEm").style.display = "";
                    $("tdlblgris").style.display = "";
                    $("tdvlGris").style.display = "";
                    $("tdlblTaxaFixa").style.display = "";
                    $("tdvlTaxaFixa").style.display = "";
                    $("tdlblFreteMinino").style.display = "";
                    $("tdvlFreteMinino").style.display = "";
                    $("tdlblTipoEntrega").style.display = "";
                    $("tdvlPrevisaoEntrega").style.display = "";                                       
                    $("tdlblAuxAteKg").innerHTML = " Até: ";                                       
                    $("divVlSobFrete").style.display = "none";                    
                    $("vlsobfrete").value = "0.00";
                    visivel($("tipoPeso_0"));
                    visivel($("divUsarMaiorPreco"));
                    visivel($("divUsarMaiorPreco_"+index));
                    invisivel($("divTipoCalculo"));
                }else if($("tipoTaxa").value == "2" ){                    
                    $("divVlAtekg").style.display = "none";
                    $("tdVlAuxAteKg").style.display = "";
                    $("vlKgAte").value = "0.00";
                    $("tdvlTipoProduto").style.display = "";
                    $("tdlblCobrar").style.display = "";
                    $("tdlblCobrar").innerHTML = "  ";
                    $("tdVlPrecoFaixa").style.display = "";
                    $("vlPrecoFaixa").value = "0.00";
                    $("divVlPrecoFaixa").style.display = "none";
                    $("tdlblExcedente").style.display = "";
                    $("tdlblExcedente").innerHTML = " "; 
                    $("tdlblsobKm").innerHTML = " Por:  ";
                    $("tdVlSobPeso").style.display = "";
                    $("divVlSobPeso").style.display = "none";
                    $("vlsobpeso").value = "0.00";
                    // $("divVlSobKm").style.display = "none";
                    // $("vlsobkm").value = "0.00";
                    $("tdlbladValorEm").style.display = "";
                    $("tdAdVlEm").style.display = "";
                    $("tdlblgris").style.display = "";
                    $("tdvlGris").style.display = "";
                    $("tdlblTaxaFixa").style.display = "";
                    $("tdvlTaxaFixa").style.display = "";
                    $("tdlblFreteMinino").style.display = "";
                    $("tdvlFreteMinino").style.display = "";
                    $("tdlblTipoEntrega").style.display = "";
                    $("tdvlPrevisaoEntrega").style.display = "";                    
                    $("divVlSobFrete").style.display = "";
                    $("vlsobfrete").value = <%=fornec.getVlsobfrete()%>;
                    $("tdlblAuxAteKg").innerHTML = " Sob % Frete:  ";                                       
                    invisivel($("tipoPeso_0"));
                    visivel($("divUsarMaiorPreco"));
                    visivel($("divUsarMaiorPreco_"+index));
                    visivel($("divTipoCalculo"));
                }else if($("tipoTaxa").value == "5" ){                    
                    $("divVlAtekg").style.display = "none";
                    $("tdVlAuxAteKg").style.display = "";
                    $("tdVlAuxAteKg").style.display = "";
                    $("vlKgAte").value = "0.00";
                    $("tdlblCobrar").style.display = "";
                    $("tdlblCobrar").innerHTML = "   ";
                    $("tdVlPrecoFaixa").style.display = "";
                    $("divVlPrecoFaixa").style.display = "none";
                    $("vlPrecoFaixa").value = "0.00";
                    $("tdlblExcedente").style.display = "";
                    $("tdlblExcedente").innerHTML = ""; 
                    $("tdVlSobPeso").style.display = "";                    
                    $("divVlSobPeso").style.display = "none";                                        
                    $("vlsobpeso").value = "0.00";
                    // $("divVlSobKm").style.display = "";
                    $("tdlbladValorEm").style.display = "";
                    $("tdAdVlEm").style.display = "";
                    $("tdlblgris").style.display = "";
                    $("tdvlGris").style.display = "";
                    $("tdlblTaxaFixa").style.display = "";
                    $("tdvlTaxaFixa").style.display = "";
                    $("tdlblFreteMinino").style.display = "";
                    $("tdvlFreteMinino").style.display = "";
                    $("tdlblTipoEntrega").style.display = "";
                    $("tdvlPrevisaoEntrega").style.display = "";                    
                    $("divVlSobFrete").style.display = "none";
                    $("tdlblsobKm").innerHTML = " Por:  ";
                    $("vlsobfrete").value = "0.00";
                    $("tdlblAuxAteKg").innerHTML = "  ";                                       
                    invisivel($("tipoPeso_0"));
                    invisivel($("divUsarMaiorPreco"));
                    invisivel($("divTipoCalculo"));
                }else if($("tipoTaxa").value == "3"){
                    $("tdlblsobKm").innerHTML = " Por:  ";
                     $("divVlAtekg").style.display = "none";
                    invisivel($("tipoPeso_0"));
                    invisivel($("divUsarMaiorPreco"));
                    invisivel($("divTipoCalculo"));
                }
                if(index != null || index != undefined){
                    if($("tipoTaxa_"+index).value == "0"){
                        $("divAteKgArea_"+index).style.display = "";
                        $("tdVlAtekgArea_"+index).style.display = "";                        
                        $("tdVlTipoProdutoArea_"+index).style.display = "";                                                                        
                        $("tdVlPrecoFaixaArea_"+index).style.display = "";
                        $("divVlPrecoFaixaArea_"+index).style.display = "";
                        $("tdVlSobPesoArea_"+index).style.display = "";                        
                        $("divVlSobPesoArea_"+index).style.display = "";                        
                        // $("divPorKmArea_"+index).style.display = "none";
                        // $("lblPor_"+index).style.display = "none";
                        // $("lblKm_"+index).style.display = "none";
                        // $("vlSobKm_"+index).value = "0.00";
                        $("tdVlAdVlEmArea_"+index).style.display = "";                        
                        $("tdVlGrisArea_"+index).style.display = "";
                        $("tdVlTaxaFixaArea_"+index).style.display = "";
                        $("tdVlFreteMinArea_"+index).style.display = "";
                        $("tdVlPrevisaoEntregaArea_"+index).style.display = "";                   
                        $("divSobFreteArea_"+index).style.display = "none";
                        $("lblSobFrete_"+index).style.display = "none";                                                
                        $("vlSobFreteArea_"+index).value = "0.00";
                        $("divPesoInicialArea_"+index).style.display = "none";
                        $("divPesoFinalArea_"+index).style.display = "none";
                        $("pesoInicialArea_"+index).value = "0.00";
                        $("pesoFinalArea_"+index).value = "0.00";
                        visivel($("tipoPeso_"+index));
                        visivel($("trArea2_"+index));
                        visivel($("divUsarMaiorPreco_"+index));
                        invisivel($("divTipoCalculo_"+index));
                    }else if($("tipoTaxa_"+index).value == "2"){
                        var i = index;
                        $("divAteKgArea_"+index).style.display = "none";
                        $("tdVlAtekgArea_"+index).style.display = "";
                        $("vlKgAteArea_"+index).value = "0.00";
                        $("tdVlTipoProdutoArea_"+index).style.display = "";
                        $("tdVlPrecoFaixaArea_"+index).style.display = "";
                        $("divVlPrecoFaixaArea_"+index).style.display = "none";
                        $("vlPrecoFaixaArea_"+index).value = "0.00";
                        $("tdVlSobPesoArea_"+index).style.display = "";
                        $("vlSobPesoArea_"+index).value = "0.00";
                        $("divVlSobPesoArea_"+index).style.display = "none";
                        // $("divPorKmArea_"+index).style.display = "none"; 
                        // $("vlSobKm_"+index).value = "0.00";
                        // $("lblPor_"+index).style.display = "none";
                        // $("lblKm_"+index).style.display = "none";
                        $("tdVlAdVlEmArea_"+index).style.display = "";                        
                        $("tdVlGrisArea_"+index).style.display = "";
                        $("tdVlTaxaFixaArea_"+index).style.display = "";
                        $("tdVlFreteMinArea_"+index).style.display = "";
                        $("tdVlPrevisaoEntregaArea_"+index).style.display = "";
                        $("divSobFreteArea_"+index).style.display = "";
                        $("lblSobFrete_"+index).style.display = "";         
                        $("divPesoInicialArea_"+index).style.display = "none";
                        $("divPesoFinalArea_"+index).style.display = "none";
                        $("pesoInicialArea_"+index).value = "0.00";
                        $("pesoFinalArea_"+index).value = "0.00";
                        invisivel($("tipoPeso_"+index));
                        visivel($("trArea2_"+index));
                        visivel($("divUsarMaiorPreco_"+index));
                        visivel($("divTipoCalculo_"+index));
                    }else if($("tipoTaxa_"+index).value == "5"){
                        $("divAteKgArea_"+index).style.display = "none";
                        $("tdVlAtekgArea_"+index).style.display = "";
                        $("vlKgAteArea_"+index).value = "0.00";
                        $("tdVlTipoProdutoArea_"+index).style.display = "";
                        $("tdVlPrecoFaixaArea_"+index).style.display = "";
                        $("divVlPrecoFaixaArea_"+index).style.display = "none";
                        $("vlPrecoFaixaArea_"+index).value = "0.00";
                        $("tdVlSobPesoArea_"+index).style.display = "";
                        $("divVlSobPesoArea_"+index).style.display = "none";
                        $("vlSobPesoArea_"+index).value = "0.00";                        
                        // $("divPorKmArea_"+index).style.display = "";
                        // $("lblPor_"+index).style.display = "";
                        // $("lblKm_"+index).style.display = "";
                        $("tdVlAdVlEmArea_"+index).style.display = "";
                        $("tdVlGrisArea_"+index).style.display = "";
                        $("tdVlTaxaFixaArea_"+index).style.display = "";
                        $("tdVlFreteMinArea_"+index).style.display = "";
                        $("tdVlPrevisaoEntregaArea_"+index).style.display = "";
                        $("divSobFreteArea_"+index).style.display = "none";
                        $("lblSobFrete_"+index).style.display = "none";
                        $("vlSobFreteArea_"+index).value = "0.00";
                        $("divPesoInicialArea_"+index).style.display = "none";
                        $("divPesoFinalArea_"+index).style.display = "none";
                        $("pesoInicialArea_"+index).value = "0.00";
                        $("pesoFinalArea_"+index).value = "0.00";
                        invisivel($("tipoPeso_"+index));
                        visivel($("trArea2_"+index));
                        invisivel($("divUsarMaiorPreco_"+index));
                        invisivel($("divTipoCalculo_"+index));
                    }else if($("tipoTaxa_"+index).value == "3"){
                        visivel($("trArea2_"+index));
                        invisivel($("divUsarMaiorPreco_"+index));
                        invisivel($("divTipoCalculo_"+index));
                    }
                }
            }catch(e){
                alert(e);
            }
            
        }
        
        function alterarTipoPeso(index){
            try {
                index = (index == null || index == undefined ? 0 : index);
                if ($('tipoPeso_' + index).value == "2") {
                    visivel($('trTabelaFaixaPeso_' + index));
                }else{
                    invisivel($('trTabelaFaixaPeso_' + index));
                }
            } catch (e) { 
                alert(e);
            }
        }
        
        function Tabela(id,pesoInicial, pesoFinal, valor,tipoValor, index, indexTab){
            this.id = (id==null||id==undefined ? 0 : id);
            this.index = (index==null||index==undefined ? 0 : index);
            this.indexTab = (indexTab==null||indexTab==undefined ? 0 : indexTab);
            this.pesoInicial = (pesoInicial == null || pesoInicial == undefined ? 0 : pesoInicial);
            this.pesoFinal = (pesoFinal == null || pesoFinal == undefined ? 0 : pesoFinal);
            this.valor = (valor == null || valor == undefined ? 0 : valor);
            this.tipoValor = (tipoValor == null || tipoValor == undefined ? 0 : tipoValor);
        }
        
        function addTrFaixaPeso(index, _tbody, vlExcedente){
            try {
                index = (index == null || index == undefined ? 0 : index);
                vlExcedente = (vlExcedente == null || vlExcedente == undefined ? 0 : vlExcedente);
                var classe = ((index % 2) != 0 ? 'CelulaZebra2' : 'CelulaZebra1');
                
                var _tr = Builder.node("tr",{id:"trTabelaFaixaPeso_" +index});
                var _td = Builder.node("td",{colsPan:"12", className: classe});
                var _table = Builder.node("table",{width: "50%",className: "bordaFina tabelaZeradaSemPerc"});
                var _tbodyTitulo = Builder.node("tbody");
                var _tr_addFaixa = Builder.node("tr",{className: classe});
                var _td_addFaixa = Builder.node("td",{colsPan:"4"});
                var _div_addFaixa = Builder.node("div", {align: "left"});
                var _img_addFaixa = Builder.node("img", {
                    className: "imagemLink",
                    src: "img/add.gif",
                    onClick: "addFaixaPeso(null, ('tbFaixaPeso_"+ index+"'), "+index+");",
                    title: "Adicionar uma nova faixa de peso."
                });
                var _label_addFaixa = Builder.node("label", "Adicionar Faixas de Peso");
                var _b_titulo = Builder.node("b");
                _b_titulo.appendChild(_label_addFaixa);
                //----- 
                var _tr_colunas = Builder.node("tr",{className: classe});
                var _td_de = Builder.node("td",{width: "25%"});
                var _td_ate = Builder.node("td",{width: "25%"});
                var _td_valor = Builder.node("td",{width: "25%"});
                var _td_tp = Builder.node("td",{width: "25%"});
                
                var _b_de = Builder.node("b", "De (Kg)");
                var _b_ate = Builder.node("b","Até (Kg)");
                var _b_valor = Builder.node("b","Valor R$");
                
                //-----------
                var _tbodyContainer = Builder.node("tbody", {id: "tbFaixaPeso_" + index});
                
                //--------------
                var _tbodyExcedente = Builder.node("tbody");
                var _trExcedente = Builder.node("tr", {className: classe});
                var _labelExcedente = Builder.node("label", "Excedente:");
                var _tdExcedenteDesc = Builder.node("td", {className: "styleNum"});
                var _tdExcedenteValor = Builder.node("td",{colsPan:"3"});
                
                var _inp_excedente = Builder.node("input",{
                    type:"text",className:"inputTexto styleNum", size:"10", 
                    value: colocarVirgula(vlExcedente),
                    maxlength:"10", 
                    name:"vlPrecoExcedente_"+index,
                    id:"vlPrecoExcedente_"+index,
                    onKeyPress: "mascara(this, reais)"
                });
                
                
                _div_addFaixa.appendChild(_img_addFaixa);
                _div_addFaixa.appendChild(_b_titulo);
                _td_addFaixa.appendChild(_div_addFaixa);
                _tr_addFaixa.appendChild(_td_addFaixa);
                _tbodyTitulo.appendChild(_tr_addFaixa);
                
                _td_de.appendChild(_b_de);
                _td_ate.appendChild(_b_ate);
                _td_valor.appendChild(_b_valor);
                
                _tr_colunas.appendChild(_td_de);
                _tr_colunas.appendChild(_td_ate);
                _tr_colunas.appendChild(_td_valor);
                _tr_colunas.appendChild(_td_tp);
                _tbodyTitulo.appendChild(_tr_colunas);
                
                _tdExcedenteDesc.appendChild(_labelExcedente);
                _tdExcedenteValor.appendChild(_inp_excedente);
                _trExcedente.appendChild(_tdExcedenteDesc);
                _trExcedente.appendChild(_tdExcedenteValor);
                _tbodyExcedente.appendChild(_trExcedente);
                
                _table.appendChild(_tbodyTitulo);
                _table.appendChild(_tbodyContainer);
                _table.appendChild(_tbodyExcedente);
                _td.appendChild(_table);
                _tr.appendChild(_td);
                
                
                _tbody.appendChild(_tr);
            } catch (e) { 
                alert(e);
            }
        }
        
        function addFaixaPeso(tabela, _tbody, indexTab){
            try {
                if(tabela==null || tabela==undefined){
                    tabela = new Tabela();
                    tabela.indexTab = indexTab;
                }
                
                tabela.index = parseInt($("qtdFaixaPeso_"+tabela.indexTab).value, 10) + 1;
                
                var classe = ((tabela.indexTab % 2) != 0 ? 'CelulaZebra2' : 'CelulaZebra1');
                
                var _tr = Builder.node("TR",{
                    className:classe
                });//tr do tipo terrestre, fluvial e maritimo

                //td do peso inicial
                var td_1_1 = Builder.node("td",{
                    className:classe
                });

                var inp_1_1 = Builder.node("input",{
                    type:"text", className:"fieldMin2 styleNum", size:"6",
                    value: colocarVirgula(tabela.pesoInicial),
                    maxlength:"10", 
                    name:"pesoInicio_"+tabela.indexTab+"_"+tabela.index, 
                    id:"pesoInicio_"+tabela.indexTab+"_"+tabela.index,
                    onKeyPress: "mascara(this, reais)"
                });
                td_1_1.appendChild(inp_1_1);

                //td do peso final
                var td_1_2 = Builder.node("td",{
                    className:classe
                });

                var inp_1_2 = Builder.node("input",{
                    type:"text",className:"fieldMin2 styleNum", size:"6", 
                    value: colocarVirgula(tabela.pesoFinal),
                    maxlength:"10", 
                    name:"pesoFinal_"+tabela.indexTab+"_"+tabela.index,
                    id:"pesoFinal_"+tabela.indexTab+"_"+tabela.index,
                    onKeyPress: "mascara(this, reais)"
                });
                td_1_2.appendChild(inp_1_2);

                //td do peso final
                var td_1_3 = Builder.node("td",{
                    className:classe + " styleNum"
                });

                var inp_1_3 = Builder.node("input",{
                    type:"text",className:"fieldMin2 styleNum", 
                    value: colocarVirgula(tabela.valor),
                    name:"valorPeso_"+tabela.indexTab+"_"+tabela.index,
                    size:"6", 
                    maxlength:"10", 
                    id:"valorPeso_"+tabela.indexTab+"_"+tabela.index,
                    onKeyPress: "mascara(this, reais)"
                });

                var inp_1_h = Builder.node("input",{
                    type:"hidden", 
                    value: tabela.id,
                    name:"idFaixa_"+tabela.indexTab+"_"+tabela.index,
                    id:"idFaixa_"+tabela.indexTab+"_"+tabela.index
                });

                var inp_1_h2 = Builder.node("input",{
                    type:"hidden", 
                    value: 0,
                    id:"hi_valorPeso_"+tabela.indexTab+"_"+tabela.index, 
                    name:"hi_valorPeso_"+tabela.indexTab+"_"+tabela.index   
                });

                td_1_3.appendChild(inp_1_h2);
                td_1_3.appendChild(inp_1_h);
                td_1_3.appendChild(inp_1_3);

                //td do tipo do valor
                var td_1_4 = Builder.node("td",{
                    className:classe
                });
                var slc_1 = Builder.node("select", {
                    name:"slcFaixaPeso_"+tabela.indexTab+"_"+tabela.index,
                    className:"fieldMin2", 
                    id:"slcFaixaPeso_"+tabela.indexTab+"_"+tabela.index
                },
                [
                    Builder.node('OPTION', {value:'f'}, 'FIXO'),
                    Builder.node('OPTION', {value:'k'}, 'KG'),
                    Builder.node('OPTION', {value:'t'}, 'TON')
                ]);

                if (tabela.id != 0) {
                    slc_1.value = tabela.tipoValor;
                }else{
                    slc_1.selectedIndex = 0;
                }
                td_1_4.appendChild(slc_1);

                _tr.appendChild(td_1_1);
                _tr.appendChild(td_1_2);
                _tr.appendChild(td_1_3);
                _tr.appendChild(td_1_4);

                $(_tbody).appendChild(_tr);
                $("qtdFaixaPeso_"+tabela.indexTab).value = tabela.index;
                inp_1_1.focus();
            } catch (e) { 
                alert(e);
            }
        }
        
        
        //Apaga dados da conta comtábil
        function limparContaContabil(){
            $("idContaProvisao").value = "0";
            $("codigoContaProvisao").value = "";
            $("descricaoPlanoConta").value = "";
        }
        
        function mostrarSolucaoPedagio(){
            if($('chkProprietario').checked == true){
             visivel($('solucaoPedagio'));
             visivel($('solucoesPedagio'));
            }else{
             invisivel($('solucaoPedagio'));
             invisivel($('solucoesPedagio'));
             
                 
                
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
                var rotina = "fornecedor";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = <%=(carregafornec ? fornec.getIdfornecedor() : 0)%>;
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
    
    function setDataAuditoria(){
            $("dataDeAuditoria").value="<%=carregafornec ? Apoio.getDataAtual() :  "" %>" ;   
            $("dataAteAuditoria").value="<%=carregafornec ? Apoio.getDataAtual() : "" %>" ;   

        }
        
    function localizarContaContabil(conta){
        var idConta = conta.value;
        var idCampo = conta.id;
        
        jQuery.ajax({
            url: "./PlanoContaControlador?",
            dataType: "text",
            method : "post",
            async : false,
            data: {
                conta: idConta,
                acao : "localizarContaContabil"
            },
            success: function(data) {
                var conta = jQuery.parseJSON(data);
                espereEnviar("",false);
                if (conta == null){
                    alert("Plano de contas não encontrado!");
                    return false;
                }else if(conta == ''){
                    alert("Plano de contas não encontrado!");
                    return false;
                }else if(conta.erro == 'true'){
                    alert("Plano de contas não encontrado!");
                    return false;
                }else{
                    if (idCampo == "codigoContaProvisao") {
                        $("idContaProvisao").value = conta.id;
                        $("codigoContaProvisao").value = conta.codigo;                        
                        $("descricaoPlanoConta").value = conta.descricao;
                    } else if (idCampo = "codigoIrrfRetido") {
                        $("idIrrfRetido").value = conta.id;
                        $("codigoIrrfRetido").value = conta.codigo;                        
                        $("descricaoIrrfRetido").value = conta.descricao;                        
                    }
                }
            },error: function(){
                alert("Erro inesperado, favor refazer a operação.");
            }
        });
    }
    
    function limparContaIrrfRetido(){
        $("idIrrfRetido").value = "0";
        $("codigoIrrfRetido").value = "";
        $("descricaoIrrfRetido").value = "";
    }
             
    function resolveuOcorrencia(idx){
        if ($('resolvido_'+idx).checked){            
            $('usuarioResolucao_' + idx).innerHTML = '<%=Apoio.getUsuario(request).getNome()%>';
            $('idUsuarioResolucao_' + idx).value = '<%=Apoio.getUsuario(request).getId()%>';
            $('dataResolucao_' + idx).value = '<%=Apoio.getDataAtual()%>';
            $('horaResolucao_' + idx).value = '<%=new SimpleDateFormat("HH:mm").format(new Date())%>';
        }else{
            $('usuarioResolucao_' + idx).innerHTML = '';
            $('idUsuarioResolucao_' + idx).value = '';
            $('dataResolucao_' + idx).value = '';
            $('horaResolucao_' + idx).value = '';
        }
    }
     
    var listaIdTP = "";
    var listaDescTP = "";
    <%for (TipoProduto p : productTypesAereo) {%>
        if(listaIdTP == "") {
            listaIdTP = listaIdTP + "<%=p.getId()%>";
            listaDescTP = listaDescTP + "<%=p.getDescricao()%>";
        } else {
            listaIdTP = listaIdTP + ";<%=p.getId()%>";
            listaDescTP = listaDescTP + ";<%=p.getDescricao()%>";
        }
    <%}%>
    var listaIdTE = "";
    var listaCodTE = "";
    var listaDescTE = "";
    <%for (TarifaEspecificaAero te : tarifasEspecificas) {%>
        if(listaIdTE == "") {
            listaIdTE = listaIdTE + "<%=te.getId()%>";
            listaCodTE = listaCodTE + "<%=te.getCodigo()%>";
            listaDescTE = listaDescTE + "<%=te.getDescricao()%>";
        } else {
            listaIdTE = listaIdTE + ";<%=te.getId()%>";
            listaCodTE = listaCodTE + ";<%=te.getCodigo()%>";
            listaDescTE = listaDescTE + ";<%=te.getDescricao()%>";
        }
    <%}%>
</script>
<html>
    <head>

        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">
        <style type="text/css">
            <!--
            .styleCenter {text-align: center}
            .styleNum {text-align: right}
            -->
        </style>
        <title>Cad. Fornecedor - Webtrans</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="javascript:atribuicombos();applyFormatter();setDefault();mostrarSolucaoPedagio();setDataAuditoria();carregar()">
        <form id="formulario" name="formulario" method="post" target="pop">
            <!-- Campos ocultos -->
            <input type="hidden" id="idhist" name="idhist" value="<%=(carregafornec ? fornec.getHistoricoPadrao().getIdhistorico() : 0)%>">
            <input type="hidden" id="idcidadeorigem" name="idcidadeorigem" value="<%=(carregafornec ? fornec.getCidade().getIdcidade() : 0)%>">
            <input type="hidden" id="idplanocusto_despesa" name="idplanocusto_despesa"   value="<%=(carregafornec ? fornec.getPlanoCustoPadrao().getIdconta() : 0)%>">
            <input type="hidden" id="grupo_id" name="grupo_id" value="0">
            <input type="hidden" id="grupo" name="grupo" value="">
            <!--<input type="hidden" id="plano_contas_id" name="plano_contas_id" value="< %=(carregafornec ? fornec.getPlanoConta().getId() : 0)%>">-->
            <!--<input type="hidden" id="cod_conta" name="cod_conta" value="< %=(carregafornec ? fornec.getPlanoConta().getId() : 0)%>">-->
            <!--<input type="hidden" id="conta_provisao_id" name="conta_provisao_id" value="< %=(carregafornec ? fornec.getPlanoConta().getId() : 0)%>">-->
            <!--<input type="hidden" id="irrf_retido_id" name="irrf_retido_id" value="< %=(carregafornec ? fornec.getContaIrrfRetido().getId() : 0)%>">-->
            <input type="hidden" id="cod_conta" name="cod_conta" value=""/>
            <input type="hidden" id="plano_conta_descricao" name="plano_conta_descricao" value=""/>
            <input type="hidden" id="plano_contas_id" name="plano_contas_id" value="0"/>
            <input type="hidden" id="id_und" name="id_und" value="<%=(carregafornec ? fornec.getUnidadeCusto().getId() : 0)%>">
            <input type="hidden" id="isTac" name="isTac" value="<%=(carregafornec ? fornec.isTac() : false)%>">
            <input name="cartaoPamcard" type="hidden" id="cartaoPamcard" value="<%=(carregafornec ? fornec.getCartaoPamcard() : "")%>" >
            <input name="cartaoNdd" type="hidden" id="cartaoNdd" value="<%=(carregafornec ? fornec.getCartaoNdd() : 0)%>" >
            <input name="cartaoTicketFrete" type="hidden" id="cartaoTicketFrete" value="<%=(carregafornec ? fornec.getCartaoTicketFrete() : 0)%>" >

            <input type="hidden" name="cartaoRepom" id="cartaoRepom" value="<%=(carregafornec ? fornec.getCartaoRepom() : "")%>" >
            <input type="hidden" name="bancoId2" id="bancoId2" value="<%=(carregafornec ? fornec.getBanco2().getIdBanco() : 0)%>">
            <input type="hidden" name="agenciaBancaria2" id="agenciaBancaria2" value="<%=(carregafornec ? fornec.getAgenciaBancaria2() : "")%>">
            <input type="hidden" name="contaBancaria2" id="contaBancaria2" value="<%=(carregafornec ? fornec.getContaBancaria2() : "")%>">
            <input type="hidden" name="favorecido2" id="favorecido2" value="<%=(carregafornec ? fornec.getFavorecido2() : "")%>">
            <input type="hidden" name="area_id" id="area_id" value="0"/>
            <input type="hidden" name="sigla_area" id="sigla_area" value=""/>
            <input type="hidden" name="indexAux" id="indexAux" value="0"/>
            <input type="hidden" name="countArea" id="countArea" value="0"/>
            <input type="hidden" name="tituloEleitor" id="tituloEleitor" value="<%=(carregafornec ? fornec.getTituloEleitor() : "")%>"/>
            <input type="hidden" name="zonaEleitoral" id="zonaEleitoral" value="<%=(carregafornec ? fornec.getZonaEleitoral() : 0)%>"/>
            <input type="hidden" name="secaoEleitoral" id="secaoEleitoral" value="<%=(carregafornec ? fornec.getSecaoEleitoral() : 0)%>"/>
            <input type="hidden" id="aeroporto" value=""/>
            <input type="hidden" id="aeroporto_id_orig" value=""/>
            <input type="hidden" id="aeroporto_id_dest" value=""/>
            <input type="hidden" id="ordemtpca" name="ordemtpca" value="">

            <input type="hidden" name="ocorrencia_id" id="ocorrencia_id" value="0"> 
            <input type="hidden" name="ocorrencia" id="ocorrencia"> 
            <input type="hidden" name="descricao_ocorrencia" id="descricao_ocorrencia">  
            <input type="hidden" name="maxOcorrencia" id="maxOcorrencia" value="0"> 
            <input type="hidden" name="ocorrenciaExcluir" id="ocorrenciaExcluir">
            <input type="hidden" name="obriga_resolucao" id="obriga_resolucao">

            <!-- Fim -->
            <img src="img/banner.gif" >
            <br>
            <table width="98%" align="center" class="bordaFina" >
                <tr>
                    <td width="70%">
                        <div align="left">
                            <b>Cadastro de Fornecedor </b>
                        </div>
                    </td>
                    <td width="20%">
                        <%  //se o paramentro vier com valor entao nao pode excluir
                            if ((acao.equals("editar")) && (nivelUser >= 4) && (request.getParameter("ex") == null)) {%>
                        <input name="excluir" type="button" class="botoes" id="excluir" value="Excluir"
                               onClick="javascript:tryRequestToServer(function(){excluirFornecedor(<%=(carregafornec ? fornec.getIdfornecedor() : 0)%>);});">
                        <%}
                            if (acao.equals("iniciar")) {%>
                        <input  name="Button" type="button" class="botoes" value="Importar dados do motorista" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.IMPORTAR_MOTORISTA%>','Motorista')">
                        <%}%>
                    </td>
                    <td width="10%" >
                        <input  name="Button" type="button" class="botoes" value="Voltar para Consulta" onClick="javascript:voltar();">
                    </td>
                </tr>
            </table>
            <br>
            <div id="dvInfoPrincipais">
                <table width="98%" border="0" align="center" class="bordaFina">
                    <tr class="tabela"> 
                        <td colspan="5" >
                            <div align="center">Dados Principais </div>
                        </td>
                    </tr>
                    <tr> 
                        <td class="TextoCampos">*Raz&atilde;o Social: </td>
                        <td colspan="2" class="CelulaZebra2">

                            <input name="razaosocial" type="text" id="razaosocial" size="50" maxlength="50" value="<%=(carregafornec ? fornec.getRazaosocial() : "")%>" class="inputtexto">
                        </td>
                        <td width="97" class="TextoCampos">C&oacute;digo:</td>
                        <td width="194" class="CelulaZebra2">
                            <b><%=(carregafornec) ? String.valueOf(fornec.getIdfornecedor()) : ""%></b>
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">*Nome Fantasia: </td>
                        <td colspan="2" class="CelulaZebra2">
                            <input name="fantasia" type="text" id="fantasia" size="50" maxlength="50" value="<%=(carregafornec ? fornec.getNomeFantasia() : "")%>" class="inputtexto">
                        </td>
                        <td class="TextoCampos">&nbsp;</td>
                        <td class="CelulaZebra2">&nbsp;</td>
                    </tr>
                    <tr> 
                        <td class="TextoCampos">*Cep:</td>
                        <td width="207" class="CelulaZebra2">
                            <input name="cep" type="text" id="cep" size="9" maxlength="9" value="<%=(carregafornec ? fornec.getCep() : "")%>" onchange="getEnderecoByCep(this.value, false)" class="inputtexto">
                        </td>
                        <td class="TextoCampos">
                            <div align="right">Data de Nascimento:</div>
                        </td>
                        <td class="CelulaZebra2" colspan="2">
                            <input value="<%=carregafornec ? fornec.getDataNascimento() != null ? fmt.format(fornec.getDataNascimento()) : "" : ""%>"  name="dataNascimentoS" type="text" id="dataNascimentoS" size="9" maxlength="10" onBlur="alertInvalidDate(this,true)" class="fieldDate">
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">*Endereço: </td>
                        <td colspan="2" class="CelulaZebra2">
                            <input name="endereco" type="text" id="endereco" size="40" maxlength="70" value="<%=(carregafornec ? fornec.getEndereco() : "")%>" class="inputtexto">
                            <input name="logradouro" type="text" id="logradouro" size="5" maxlength="10" value="<%=(carregafornec ? fornec.getNumeroLogradouro() : "")%>" class="inputtexto"/>
                        </td>

                        <td colspan="2" class="CelulaZebra2"</td>
                    </tr>
                    <tr> 
                        <td class="TextoCampos">Bairro:</td>
                        <td class="CelulaZebra2">
                            <input name="bairro" type="text" id="bairro" size="25" maxlength="25" value="<%=(carregafornec ? fornec.getBairro() : "")%>" class="inputtexto">
                        </td>
                        <td class="TextoCampos">Cidade:</td>
                        <td colspan="2" class="CelulaZebra2">
                            <input type="text" class="inputReadOnly" id="cid_origem" size="25" readonly value="<%=(carregafornec ? fornec.getCidade().getDescricaoCidade() : "")%>">
                            <input type="text" class="inputReadOnly" id="uf_origem" size="2" readonly value="<%=(carregafornec ? fornec.getCidade().getUf() : "")%>">
                            <input type="button" class="inputBotaoMin" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CIDADE_ORIGEM%>','Cidade')" value="...">
                            <img src="img/borracha.gif" align="absbottom" class="imagemLink" title="Limpar Cidade" onClick="getObj('cid_origem').value='';getObj('uf_origem').value='';getObj('idcidadeorigem').value='0';"> 
                        </td>
                    </tr>

                    <tr>
                        <td colspan="5">
                            <table width="100%"  border="0" cellspacing="1" cellpadding="2">
                                <tr>
                                    <td width="11%" class="TextoCampos">
                                        <select name="tipocgc" id="tipocgc" onChange="getTipoCgc();" class="inputtexto">
                                            <option value="J" selected>CNPJ</option>
                                            <option value="F">CPF</option>
                                        </select>       
                                    </td>
                                    <td width="22%" class="CelulaZebra2">
                                        <input name="cpfcnpj" type="text" id="cpfcnpj" size="18" maxlength="18" value="<%=(carregafornec ? fornec.getCpfCnpj() : "")%>" onKeyPress="javascript:digitaCnpj();" class="inputtexto">
                                        <img src="img/receita.png" height="25" border="0" align="absbottom" title="Clique aqui para consultar o CNPJ na Receita Federal." onclick="abrirConsultarCliente();" />
                                    </td>
                                    <td width="18%" class="CelulaZebra2">
                                        <input type="checkbox" name="validaChk" id="validaChk" value="checkbox" checked <%=(nivelCnpjInvalido == 4 ? "" : "disabled")%>>
                                        Valida CPF/CNPJ 
                                    </td>
                                    <td width="8%" class="TextoCampos">
                                        <label id="lbIe" name="lbIe">*I.E.:</label>
                                    </td>
                                    <td width="10%" class="CelulaZebra2">
                                        <input name="identinscest" type="text" id="identinscest" size="20" maxlength="20" value="<%=(carregafornec ? fornec.getIdentInscest() : "")%>" class="inputtexto"></td>
                                    <td width="5%" class="TextoCampos">
                                        <label id="lbIm" name="lbIm">I.M.:</label>
                                    </td>
                                    <td width="5%" class="CelulaZebra2">
                                        <input name="orgaoinscmu" type="text" id="orgaoinscmu" size="18" maxlength="20" value="<%=(carregafornec ? fornec.getOrgaoInscmu() : "")%>" class="inputtexto">
                                    </td>
                                     <td id="dataexplabel" width="8%" class="TextoCampos">
                                        <label for="dataexpedicaorg">Data de Expedição: </label>
                                    </td>
                                     <td id="dataexpinput" width="9%" class="CelulaZebra2">
                                        <input name="dataexpedicaorg" id="dataexpedicaorg" size="15" maxlength="15" value="<%=carregafornec ? fornec.getExpedicaoRG()!= null ? fmt.format(fornec.getExpedicaoRG()) : "" : ""%>"  onBlur="alertInvalidDate(this,true)" class="fieldDate">
                                    </td>
                                </tr>
                                <tr name="trPis" id="trPis">
                                    <td class="TextoCampos">
                                        <label id="lbPis" name="lbPis">Pis/Pasep:</label>
                                    </td>
                                    <td class="CelulaZebra2">
                                        <input name="pisPasep" type="text" id="pisPasep" size="18" maxlength="20" value="<%=(carregafornec ? fornec.getPisPasep() : "")%>" class="inputtexto">
                                    </td>
                                    <td colspan="2" class="TextoCampos">Quantidade de dependentes: </td>
                                    <td class="CelulaZebra2">
                                        <input name="quantidadeDependentes" type="text" id="quantidadeDependentes" size="10" maxlength="20" value="<%=(carregafornec ? fornec.getQuantidadeDependentes() : "")%>" class="inputtexto">
                                    </td>
                                    <td class="TextoCampos">&nbsp;</td>
                                    <td class="CelulaZebra2">&nbsp;</td>
                                    <td class="TextoCampos">&nbsp;</td>
                                    <td class="TextoCampos">&nbsp;</td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="5" >
                            <table width="100%"  border="0" cellspacing="1" cellpadding="2">
                                <tr>
                                    <td width="12%" class="TextoCampos">Contato:</td>
                                    <td width="20%" class="CelulaZebra2">
                                        <input name="contato" type="text" id="contato" size="20" maxlength="20" value="<%=(carregafornec ? fornec.getContato() : "")%>" class="inputtexto">
                                    </td>
                                    <td width="13%" class="TextoCampos">E-mail:</td>
                                    <td colspan="3" class="CelulaZebra2">
                                        <input name="emailValidado" type="text" id="emailValidado" size="40" maxlength="200" value="<%=(carregafornec ? fornec.getEmail() : "")%>" class="inputtexto">
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">Telefone:</td>
                                    <td class="CelulaZebra2">
                                        <input name="ddd" type="text" id="ddd" value="<%=(carregafornec && fornec.getDdd() != 0 ? fornec.getDdd() : "")%>" size="2" maxlength="2" class="inputtexto">
                                        <input name="fone1" type="text" id="fone1" size="13" maxlength="13" value="<%=(carregafornec ? fornec.getFone1() : "")%>" class="inputtexto">
                                    </td>
                                    <td class="TextoCampos">Celular:</td>
                                    <td width="21%" class="CelulaZebra2">
                                        <input name="celular" type="text" id="celular" size="13" maxlength="13" value="<%=(carregafornec ? fornec.getCelular() : "")%>" class="inputtexto">
                                    </td>
                                    <td width="17%" class="TextoCampos">Fax:</td>
                                    <td width="17%" class="CelulaZebra2">
                                        <input name="ddd2" type="text" id="ddd2" value="<%=(carregafornec && fornec.getDdd2() != 0 ? fornec.getDdd2() : "")%>" size="2" maxlength="2" class="inputtexto">
                                        <input name="fone2" type="text" id="fone2" size="13" maxlength="13" value="<%=(carregafornec ? fornec.getFone2() : "")%>" class="inputtexto">
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr class="CelulaZebra2"> 
                        <td width="33%" class="TextoCampos">Observa&ccedil;&atilde;o:</td> 
                        <td width="33%" class="CelulaZebra2">
                            <div align="center">
                                <label>
                                    <textarea name="observacao" cols="65" rows="3" id="observacao"><%=(carregafornec && fornec.getObservacao() != null ? fornec.getObservacao() : "")%></textarea>
                                </label>
                            </div>
                        </td>
                        <td width="33%" class="TextoCampos" colspan="3">
                            <div align="center">
                                <label>                            
                                    <input id="desativarFornecedor" type="checkbox" value="checkbox" name="desativarFornecedor"
                                           <%=(carregafornec ? (fornec.isDesativarFornecedor() ? "checked" : "") : "")%>/>Desativar Fornecedor
                                </label>
                            </div>
                        </td>
                    </tr>
                    <tr class="CelulaZebra2"> 
                        <td width="33%" class="TextoCampos"><input type="checkbox" id="gerenciadorRisco" name="gerenciadorRisco" 
                                value="checkbox" <%= (carregafornec ? (fornec.isGerenciadorRisco()? "checked": ""): "")%>/>
                            Gerenciador de Risco</td> 
                        <td colspan="4" class="TextoCampos"></td>
                    </tr>    
                </table>
            </div>
            <div id="dvAba">
                <br/>
                <table align="center"  width="98%">
                    <tr>
                        <td>
                            <table width="80%">
                                <tr>
                                    <td width="20%" id="tdDadosFinanceiroContabil" class="menu-sel" onclick="AlternarAbasGenerico('tdDadosFinanceiroContabil','dvInfoFinanceiroContabil')"> Informações Financeira/Contábil </td>
                                    <td width="20%" id="tdDadosOcorrencia" class="menu" onclick="AlternarAbasGenerico('tdDadosOcorrencia','div-ocorrencia')">Ocorr&ecirc;ncia</td>
                                    <td width="20%" id="tdDadosFornecedor" class="menu" onclick="AlternarAbasGenerico('tdDadosFornecedor','dvInfoFornecedor1')"> Tipo do Fornecedor </td>
                                    <td width="20%" id="tdTabPreco" class="menu" onclick="AlternarAbasGenerico('tdTabPreco','dvInfoTabPreco')"> Tabelas de Pre&ccedil;o</td>
                                    <td width="20%" id="tdTabPrecoCiaAerea" class="menu" onclick="AlternarAbasGenerico('tdTabPrecoCiaAerea','dvInfoTabPrecoCiaAerea')"> Tabela Preço Cia Aérea</td>
                                    <td style='display: <%=carregafornec && nivelUser == 4 ? "" : "none"%>' width="20%" id="tdAbaAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>
                                    <td width="40%" </td> 
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </div>                    
            <div id="dvInfoFinanceiroContabil">   
                <table width="98%" border="0" align="center" class="bordaFina">
                    <tr>
                        <td colspan="5" align="center">
                            <table width="100%"  class="bordaFina" cellspacing="1" cellpadding="2">
                                <tr>
                                    <td width="19%" class="TextoCampos">Conta Banc&aacute;ria: </td>
                                    <td width="12%" class="CelulaZebra2">
                                        <input name="contaBancaria" type="text" id="contaBancaria" size="13" maxlength="15" value="<%=(carregafornec ? fornec.getContaBancaria() : "")%>" class="inputtexto">
                                    </td>
                                    <td width="12%" class="TextoCampos">Ag&ecirc;ncia:</td>
                                    <td width="14%" class="CelulaZebra2">
                                        <span class="CelulaZebra2">
                                            <input name="agenciaBancaria" type="text" id="agenciaBancaria" size="13" maxlength="15" value="<%=(carregafornec ? fornec.getAgenciaBancaria() : "")%>" class="inputtexto">
                                        </span>
                                    </td>
                                    <td width="11%" class="TextoCampos">Banco:</td>
                                    <td width="52%" class="CelulaZebra2">
                                        <select name="bancoId" id="bancoId" class="inputtexto">
                                            <% BeanConsultaBanco banco = new BeanConsultaBanco();
                                                banco.setConexao(Apoio.getUsuario(request).getConexao());
                                                banco.MostrarTudo();
                                                ResultSet rs = banco.getResultado();
                                                while (rs.next()) {%>
                                            <option value="<%=rs.getString("idbanco")%>" <%=(carregafornec && rs.getInt("idbanco") == fornec.getBanco().getIdBanco() ? "selected" : "")%>  ><%=rs.getString("numero") + "-" + rs.getString("descricao")%></option>
                                            <%}%>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">Favorecido:</td>
                                    <td class="CelulaZebra2">
                                        <input name="favorecido" type="text" id="favorecido" size="50" maxlength="50" value="<%=(carregafornec ? fornec.getFavorecido() : "")%>" class="inputtexto">
                                    </td>
                                    <td width ="20%" class="TextoCampos">Tipo de Conta: </td>
                                    <td  class="CelulaZebra2" colspan="4">
                                        <select class="inputtexto" id="tipoConta" name="tipoConta">
                                            <option value="c" selected="">Conta Corrente</option>
                                            <option value="p">Conta Poupança</option>
                                        </select>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr style="display:<%=(cfg.getIsContabil() || cfg.getIsFiscal() ? "" : "none")%>;">
                        <td height="17" colspan="6" >
                            <table width="100%"  border="0" class="bordaFina" >
                                <tr>
                                    <td width="12%" class="TextoCampos">*Conta cont&aacute;bil: </td>
                                    <td width="25%" class="CelulaZebra2">
                                        <input type="hidden" id="idContaProvisao" name="idContaProvisao" value="<%=(carregafornec && fornec != null ? fornec.getPlanoConta().getId() : "0")  %>" />
                                        <input type="text" class="inputReadOnly" id="descricaoPlanoConta" name="descricaoPlanoConta" size="25" value="<%=(carregafornec && fornec != null ? fornec.getPlanoConta().getDescricao():"")  %>" />
                                        <input name="codigoContaProvisao" type="text" id="codigoContaProvisao" size="7"  class="inputTexto" value="<%=(carregafornec ? fornec.getPlanoConta().getCodigo() : "")%>" onkeypress="if (event.keyCode==13) localizarContaContabil(this);">
                                        <strong>
                                            <input name="localiza_conta" type="button" class="inputBotaoMin" id="localiza_conta" value="..." 
                                                   onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.PLANO_CONTAS%>', 'Plano_de_contas')">
                                            <strong>
                                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limparContaContabil()">
                                            </strong> 
                                        </strong>
                                    </td>
                                    <td width="12%" class="TextoCampos">Conta IRRF Retido: </td>
                                    <td width="25%" class="CelulaZebra2">
                                        <input name="idIrrfRetido" type="hidden" id="idIrrfRetido" value="<%=(carregafornec ? fornec.getContaIrrfRetido().getId() : "0")%>">
                                        <input name="descricaoIrrfRetido" type="text" id="descricaoIrrfRetido" size="25" readonly class="inputReadOnly" value="<%=(carregafornec ? fornec.getContaIrrfRetido().getDescricao() : "")%>">
                                        <input name="codigoIrrfRetido" type="text" id="codigoIrrfRetido" size="7"  class="inputTexto" value="<%=(carregafornec ? fornec.getContaIrrfRetido().getCodigo() : "")%>" onkeypress="if (event.keyCode==13) localizarContaContabil(this);">
                                        <strong>
                                            <input name="localiza_conta" type="button" class="inputBotaoMin" id="localiza_conta" value="..." 
                                                   onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.PLANO_CONTAS%>', 'IRRF_retido')">
                                            <strong>
                                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:limparContaIrrfRetido();">
                                            </strong> 
                                        </strong>
                                    </td>
                                    <td width="26%" class="TextoCampos">
                                        <span class="CelulaZebra2">
                                            <div align="center">
                                                
                                            <input name="integrafiscal" type="checkbox" id="integrafiscal" value="checkbox" <%=(carregafornec && fornec.isIntegraFiscal() ? "checked" : "")%>>
                                            Enviar dados para o Contábil/Fiscal 
                                            </div>
                                        </span>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="TextoCampos">Acrescentar os seguintes campos no histórico contábil:</td>
                                    <td class="CelulaZebra2" colspan="3">
                                        <input name="notaFiscalHistorico" type="checkbox" id="notaFiscalHistorico" value="checkbox" <%=(carregafornec ? (fornec.isNotaFiscalHistoricoContabil() ? "checked" : "") : "checked")%>>Número da Nota Fiscal
                                        <input name="movimentoHistorico" type="checkbox" id="movimentoHistorico" value="checkbox" <%=(carregafornec ? (fornec.isMovimentoHistoricoContabil() ? "checked" : "") : "")%>>Número do Movimento
                                        <input name="fornecedorHistorico" type="checkbox" id="fornecedorHistorico" value="checkbox" <%=(carregafornec ? (fornec.isFornecedorHistoricoContabil() ? "checked" : "") : "checked")%>>Nome do Fornecedor
                                    </td>
                                </tr>
                                <tr>
                                    <td class="CelulaZebra2" colspan="3">
                                        <label>
                                            &nbsp&nbsp<input name="avistaDesconsiderarContabilizarProvisao" type="checkbox" id="avistaDesconsiderarContabilizarProvisao" value="true" <%=(carregafornec && fornec.isAvistaDesconsiderarContabilizarProvisao() ? "checked" : "")%> />
                                            Para lançamentos à vista, Desconsiderar o campo "contabilizar provisão" no cadastro do Plano de Custo.                                            
                                        </label>
                                    </td>
                                    <td class="CelulaZebra2" colspan="5">
                                        <label>
                                            <input name="sempreConsiderarClanoCusto" type="checkbox" id="sempreConsiderarClanoCusto" value="true" <%=(carregafornec && fornec.isSempreConsiderarClanoCusto() ? "checked" : "")%> />
                                            Nas baixas desse fornecedor sempre considerar o débito na conta contábil do Plano de Custo.                                              
                                        </label>
                                    </td> 
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </div>

                                            <div id="div-ocorrencia">
                                                <table width="98%" align="center" class="bordaFina">
                                                    <tr class="tabela">
                                                        <td>
                                                            <div align="center"
                                                                 <strong>Adicionar Ocorr&ecirc;ncia</strong>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr name="trOcorrencia" id="trOcorrencia">
                                                        <td colspan="3">
                                                            <table align="center" width="100%" class="bordaFina">
                                                                <tbody  id="tbOcorrenciaForn" name="tbOcorrenciaForn">
                                                                    <tr class="celulaZebra1">
                                                                        <td width="10" align="center" class="celula">
                                                                            <img class="imagemLink" width="20px" src="img/add.gif" alt="addCampo" name="imgLixo" id="imgLixo" onClick="novaOcorrencia();">
                                                                        </td>
                                                                        <td align="center" width="20%">Ocorrência</td>
                                                                        <td align="center" width="10%">Data/Hora da inclusão</td>
                                                                        <td align="center" width="10%">Data/Hora da ocorrência</td>
                                                                        <td align="center" width="10%">Descrição da ocorrência</td>
                                                                        <td align="center" width="10%">Usuário inclusão</td>
                                                                        <td align="center" width="6%">Resolvida</td>
                                                                        <td align="center" width="10%">Data/hora da resolução</td>
                                                                        <td align="center" width="10%">Descrição da resolução</td>
                                                                        <td align="center" width="10%">Usuário resolução</td>
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </div>

            <div id="dvInfoFornecedor1">
                <table width="98%" border="0" align="center" class="bordaFina">
                    <tr class="tabela"> 
                        <td colspan="5" align="center">Dados padr&otilde;es para lan&ccedil;amentos</td>
                    </tr>
                    <tr> 
                        <td class="TextoCampos">Hist&oacute;rico: </td>
                        <td colspan="4" class="CelulaZebra2">
                            <input name="codigo_historico" type="text" class="inputReadOnly" id="codigo_historico" onBlur="javascript:seNaoIntReset(this,'0');" value="<%=(carregafornec ? fornec.getHistoricoPadrao().getCodigo_historico() : "")%>" size="2" maxlength="3">
                            <input type="button" class="inputBotaoMin"  value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.HISTORICO_DE_LANCAMENTO%>','Historico')">
                            <img src="img/borracha.gif" width="27" height="20" border="0" align="absbottom" class="imagemLink" title="Limpar Hist&ograve;rico" onClick="getObj('descricao_historico').value='';getObj('idhist').value='0';getObj('codigo_historico').value='';">    
                            <textarea id="descricao_historico"  cols="45" rows="2" class="inputReadOnly" readonly><%=(carregafornec ? fornec.getHistoricoPadrao().getDescHistorico() : "")%></textarea>      
                        </td>
                    </tr>
                    <tr> 
                        <td class="TextoCampos">Plano Custo: </td>
                        <td colspan="3" class="CelulaZebra2">
                            <input name="plcusto_conta_despesa" type="text" class="inputReadOnly" id="plcusto_conta_despesa" size="15" readonly value="<%=(carregafornec ? fornec.getPlanoCustoPadrao().getConta() : "")%>"> 
                            <input name="plcusto_descricao_despesa" type="text" class="inputReadOnly" id="plcusto_descricao_despesa" size="30" readonly value="<%=(carregafornec ? fornec.getPlanoCustoPadrao().getDescricao() : "")%>"> 
                            <input type="button" class="inputBotaoMin" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.PLANO_CUSTO_DESPESA%>','Plano_Centro_Custo')" value="..."> 
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar plano custo padr&atilde;o" onClick="getObj('plcusto_conta_despesa').value='';getObj('idplanocusto_despesa').value='0';getObj('plcusto_descricao_despesa').value='';">
                        </td>
                        <td class="CelulaZebra2">UND Custo:
                            <input name="sigla_und" type="text" class="inputReadOnly" id="sigla_und" size="3" readonly value="<%=(carregafornec ? fornec.getUnidadeCusto().getSigla() : "")%>">
                            <input type="button" class="inputBotaoMin" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.UNIDADE_CUSTO%>','Unidade_Custo')" value="...">
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar plano custo padr&atilde;o" onClick="getObj('sigla_und').value='';getObj('id_und').value='0';">
                        </td>
                    </tr>

                    <input type="hidden" name="qtdGrupos" id="qtdGrupos" value="0"/>
                    <tr>
                        <td colspan="5">
                            <table class="bordaFina" width="100%">
                                <tbody id="tbodyFgc">
                                    <tr class="celula">
                                        <td width="4%"  align="center"> <img width="16px" onClick="addFornecedorGrupoCliente();" alt="addCampo" src="img/novo.gif" class="imagemLink"/></td>
                                        <td width="25%">Grupo</td>
                                        <td width="25%"></td>
                                        <td></td>
                                    </tr>
                                </tbody>
                            </table>
                            <input type="hidden" name="max" id="max" value="0"/>

                        </td>
                    </tr>
                </table>

                <table width="98%" border="0" align="center" class="bordaFina">
                    <tr class="tabela"> 
                        <td colspan="12" align="center" class="tabela">Tipo do Fornecedor </td>
                    </tr>

                    <tr>
                        <td width="19%" class="celula">
                            <div align="left">
                                <input name="chkAjudante" type="checkbox" id="chkAjudante" value="checkbox" <%=(carregafornec && fornec.isAjudante() ? "checked" : "")%> > 
                                Ajudante 
                            </div>
                        </td>
                        <td width="11%" class="TextoCampos">Valor di&aacute;ria:</td>
                        <td width="7%" class="CelulaZebra2" >
                            <input name="vlDiaria" type="text" id="vlDiaria" class="fieldMin" onChange="seNaoFloatReset(this,'0.00')"
                                   size="8" maxlength="10" value="<%=(carregafornec ? Apoio.to_curr(fornec.getVlDiaria()) : "0.00")%>">
                        </td>
                        <td width="10%" class="TextoCampos">&nbsp;</td>
                        <td width="7%" class="CelulaZebra2">&nbsp;</td>
                        <td width="13%" class="CelulaZebra2">&nbsp;</td>
                        <td width="6%" class="CelulaZebra2">&nbsp;</td>
                        <td width="7%" class="CelulaZebra2">&nbsp;</td>
                        <td width="12%" class="TextoCampos">&nbsp;</td>
                        <td width="8%" class="CelulaZebra2">&nbsp;</td>
                    </tr>
                    <tr>
                        <td width="19%" class="celula">
                            <div align="left">
                                <input name="chkFuncionario" type="checkbox" id="chkFuncionario" value="checkbox" ${carregafornec && fornecs.funcionario ? "checked" : ""}>
                                <label for="chkFuncionario">Funcionário</label>
                            </div>
                        </td>
                        <td colspan="9" class="CelulaZebra2"></td>
                    </tr>
                    <tr>
                        <td class="celula">
                            <div align="left">                                        
                                <input name="chkVendedor" type="checkbox" id="chkVendedor" value="checkbox" <%=(carregafornec && fornec.isVendedor() ? "checked" : "")%>> 
                                Vendedor 
                            </div>
                        </td>
                        <td class="TextoCampos">Classe:</td>
                        <td colspan="2" class="CelulaZebra2">
                            <select name="tipo_vendedor" id="tipo_vendedor" class="inputtexto">
                                <option value="0" selected>Free-lance</option>
                                <option value="1">Funcion&aacute;rio</option>
                                <option value="2">Representante</option>
                            </select>
                        </td>
                        <td class="TextoCampos">&nbsp;</td>
                        <td class="CelulaZebra2">&nbsp;</td>
                        <td class="CelulaZebra2">&nbsp;</td>
                        <td class="CelulaZebra2">&nbsp;</td>
                        <td class="CelulaZebra2">&nbsp;</td>
                        <td class="CelulaZebra2">&nbsp;</td>
                    </tr>
                    <tr>
                        <td class="celula">
                            <div align="left">
                                <input name="chkAgentePagador" type="checkbox" id="chkAgentePagador" value="checkbox" <%=(carregafornec && fornec.isAgentePagador() ? "checked" : "")%>> 
                                Agente pagador  
                            </div>
                        </td>
                        <td class="TextoCampos">% Abastec:</td>
                        <td class="CelulaZebra2">
                            <input name="perc_abastecimento" type="text" id="perc_abastecimento" class="fieldMin" onChange="seNaoFloatReset(this,'0.00')"
                                   size="8" maxlength="10" value="<%=(carregafornec ? Apoio.to_curr(fornec.getPercentualAgente()) : "0.00")%>">
                        </td>
                        <td class="CelulaZebra2">&nbsp;</td>
                        <td class="TextoCampos">&nbsp;</td>
                        <td class="CelulaZebra2">&nbsp;</td>
                        <td class="TextoCampos">&nbsp;</td>
                        <td class="CelulaZebra2">&nbsp;</td>
                        <td class="CelulaZebra2">&nbsp;</td>
                        <td class="CelulaZebra2">&nbsp;</td>
                    </tr>
                    <tr>
                        <td class="celula">
                            <div align="left">
                                <input name="chkAgenteFactoring" type="checkbox" id="chkAgenteFactoring" value="checkbox" <%=(carregafornec && fornec.isAgenteFactoring() ? "checked" : "")%>> 
                                Agente de factoring  
                            </div>
                        </td>
                        <td colspan="3" class="celula" >
                            <input name="chkFornecedorSeguradora" type="checkbox" id="chkFornecedorSeguradora" value="checkbox" <%=(carregafornec && fornec.isSeguradora() ? "checked" : "")%>>
                            Seguradora
                        </td>
                        <td colspan="3" class="celula">
                            <input name="chkCompanhiaAerea" type="checkbox" id="chkCompanhiaAerea" onclick="mostrarInfoTabPrecoCiaAerea(this.value)" value="checkbox" <%=(carregafornec && fornec.isCompanhiaAerea() ? "checked" : "")%>>
                            Companhia a&eacute;rea 
                        </td>
                        <td colspan="3" class="celula">
                            <input name="chkFornecedorCombustivel" type="checkbox" id="chkFornecedorCombustivel" value="checkbox" <%=(carregafornec && fornec.isFornecedorCombustivel() ? "checked" : "")%>>
                            Forn. combust&iacute;vel 
                        </td>
                    </tr>
                    <tr>
                        <td class="celula">
                            <div align="left">
                                <input name="chkAgenteCarga" type="checkbox" id="chkAgenteCarga" value="checkbox" <%=(carregafornec && fornec.isAgenteCarga() ? "checked" : "")%>>
                                Agente de carga
                            </div>
                        </td>
                        <td class="TextoCampos">&nbsp;</td>
                        <td class="CelulaZebra2">&nbsp;</td>
                        <td class="TextoCampos">&nbsp;</td>
                        <td class="CelulaZebra2">&nbsp;</td>
                        <td class="CelulaZebra2">&nbsp;</td>
                        <td class="CelulaZebra2">&nbsp;</td>
                        <td class="CelulaZebra2">&nbsp;</td>
                        <td class="CelulaZebra2">&nbsp;</td>
                        <td class="CelulaZebra2">&nbsp;</td>
                    </tr>
                    <tr>
                        <td class="celula" rowspan="2">
                            <div align="left">
                                <input name="chkProprietario" type="checkbox" id="chkProprietario" value="checkbox" onclick="mostrarSolucaoPedagio(this.value)" <%=(carregafornec && fornec.isProprietario() ? "checked" : "")%>>
                                Propriet&aacute;rio
                            </div>
                        </td>
                        <td class="TextoCampos">N&uacute;mero RNTRC:</td>
                        <td colspan="2" class="CelulaZebra2">
                            <input name="numeroRntrc" type="text" class="inputtexto" id="numeroRntrc" size="20"
                                   maxlength="25" value="<%=(carregafornec ? fornec.getNumeroRntrc() : "")%>" onChange="seNaoIntReset(this,'')">
                        </td>
                        <td colspan="2" class="TextoCampos">% Desconto conta corrente:</td>
                        <td colspan="4" class="CelulaZebra2">
                            <input name="percentualDesconto" type="text" id="percentualDesconto" size="4" maxlength="6"
                                   value="<%=(carregafornec ? Apoio.to_curr(cadfornec.getFornecedor().getPercentualDescontoSaldoFrete()) : Apoio.to_curr(cfg.getPercentualPadraoDescontoContaCorrente()))%>"
                                   onChange="seNaoFloatReset(this,'0.00')" class="inputtexto">
                            <select class="inputtexto" id="tipoDescontoContaCorrente" name="tipoDescontoContaCorrente">
                                <option value="1" <%=(carregafornec && cadfornec.getFornecedor().getTipoDescontoContaCorrente() == 1 ? "selected" : !carregafornec && cfg.getTipoDescontoContaCorrente() == 1 ? "selected" : "")%>>
                                    Sobre o saldo do frete
                                </option>
                                <option value="2" <%=(carregafornec && cadfornec.getFornecedor().getTipoDescontoContaCorrente() == 2 ? "selected" : !carregafornec && cfg.getTipoDescontoContaCorrente() == 2 ? "selected" : "")%>>
                                    Sobre o valor do frete
                                </option>
                            </select>
                        
                                <label>Controlar o conta corrente</label>
                                <c:set var="cadfornec" value="<%=cadfornec%>" />
                                <select name="tipoControleContaCorrenteSelect" id="tipoControleContaCorrenteSelect" class="inputtexto">
                                    <c:forEach var="tp"  items="<%=TipoControleContaCorrente.values()%>">
                                        <option value="${tp.tipoControleContaCorrente}" ${(cadfornec != null &&  tp eq cadfornec.fornecedor.tipoControleContaCorrente) ? 'selected' : ''}  >
                                            ${fn:toLowerCase(tp)}</option>
                                    </c:forEach>
                                    
                                </select>
                                <label>por placa</label>
                            </td> 
                    </tr>
                    <tr>
                        <td class="TextoCampos" id="solucaoPedagio" name="solucaoPedagio">Soluç&atilde;o do Ped&aacute;gio:</td>
                        <td class="TextoCampos">
                            <div align="left">
                                <select id="solucoesPedagio" name="solucoesPedagio" class="inputtexto" style="width:105px;">
                                    <option value="0">Selecione</option>
                                    <% solucoesPedagioBO = new SolucoesPedagioBO();

                                        Collection<SolucoesPedagio> solucoesPedagio = solucoesPedagioBO.mostrarTodos(true, Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe());

                                        for (SolucoesPedagio pedagio : solucoesPedagio) {

                                            pedagio.getId();
                                            pedagio.getCodigo();
                                            pedagio.getDescricao();

                                    %>
                                    <option value="<%=pedagio.getId()%>"><%=pedagio.getCodigo() + "-" + pedagio.getDescricao()%></option>
                                    <%}%>
                                </select>
                            </div>
                        </td>
                        <td colspan="6" class="TextoCampos">% do valor do CTRC (Valor do frete - ICMS - seguro - custo de viagem) aplicado ao gerar um contrato de frete:</td>
                        <td class="CelulaZebra2" colspan="2">
                            <input name="percentualCTRC" type="text" id="percentualCTRC" size="4" maxlength="6" value="<%=(carregafornec ? Apoio.to_curr(cadfornec.getFornecedor().getPercentualCtrcContratoFrete()) : "0.00")%>" onChange="seNaoFloatReset(this,'0.00')" class="inputtexto">
                            <img src="img/ajuda.png" border="0" title="Clique aqui pra saber a utilidade desse campo." align="absbottom" class="imagemLink" onClick="javascript:getAjudaPercentual();">
                        </td>
                    </tr>
                    <tr>
                        <td style="background-color:#7FB2CC;" class="celula" >
                            <div align="left">
                                <input name="chkRedespachante" type="checkbox" id="chkRedespachante" onclick="mostrarInfoRepresentante(this.value)" value="checkbox" <%=(carregafornec && fornec.isRedespachante() ? "checked" : "")%>> 
                                <input name="idTabArea" type="hidden" id="idTabArea" value="<%=(carregafornec ? fornec.getIdTabArea() : "0")%>"> 
                                Representante
                            </div>
                        </td>
                        <td class="celulaZebra2"  colspan="9">
                            <div style="display: none" id="tdAeroporto"  name="tdAeroporto" align="left">
                                Aeroporto:
                                <input name="aeroportoDesc" id="aeroportoDesc" class="inputReadOnly8pt" value="<%=(carregafornec ? (fornec.getAeroporto().getNome() == null ? "" : fornec.getAeroporto().getNome()) : "")%>" size="13" readonly/> 
                                <input type="button" name="btAeroporto" id="btAeroporto" class="inputBotaoMin" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.AEROPORTO%>', 'Aeroporto')" style="text-align: center"/>
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaAeroporto()">
                                <input name="aeroporto_id" id="aeroporto_id" type="hidden" value="<%=(carregafornec ? fornec.getAeroporto().getId() : 0)%>"/>
                            </div>
                        </td>                                                                                                            
                    </tr>
                    <tr id="trAltera" style="display:none">
                        <td colspan="10">
                            <table  width="100%" class="bordaFina">
                                <tr>
                                    <td class="tabela" align="center" colspan="6">Alterar Senha</td>
                                </tr>
                                <tr>
                                    <td width="13.33%" class="TextoCampos" >Login:</td>
                                    <td width="20%" class="CelulaZebra2">
                                        <input name="loginRepresentante" size="14" type="text" class="inputtexto" id="loginRepresentante" autocomplete="false" maxlength="13" value="<%=(carregafornec ? (fornec.getLogin() == null ? "" : fornec.getLogin()) : "")%>">
                                       <!--acrescentei este campo extra para enganar o firefox, pois a tag autocomplete=off não funcionou-->
                                        <input name="login" size="14" type="text" class="inputtexto" id="login" style="display:none;" autocomplete="false" maxlength="13" value="<%=(carregafornec ? (fornec.getLogin() == null ? "" : fornec.getLogin()) : "")%>">
                                    </td>
                                    <td width="13.33%" class="TextoCampos">*Senha:</td>
                                    <td width="20%" class="CelulaZebra2">
                                       <!--acrescentei este campo extra para enganar o firefox, pois a tag autocomplete=off não funcionou-->
                                        <input name="senha" size="14" type="password" autocomplete="off" class="inputtexto" id="senha" style="display:none;" maxlength="13" value="<%=(carregafornec ? (fornec.getSenha() == null ? "" : fornec.getSenha()) : "")%>">
                                        <input name="senhaRepresentante" size="14" type="password" autocomplete="off" class="inputtexto" id="senhaRepresentante" maxlength="13" value="<%=(carregafornec ? (fornec.getSenha() == null ? "" : fornec.getSenha()) : "")%>">
                                    </td>
                                    <td width="13.33%" class="TextoCampos">*Repetir:</td>
                                    <td width="20%" class="CelulaZebra2"><input name="repetir" size="14" type="password" class="inputtexto" id="repetir" maxlength="13" value="<%=(carregafornec ? (fornec.getSenha() == null ? "" : fornec.getSenha()) : "")%>"></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </div>
            <div id="dvInfoTabPreco" style="display: none" >
                <table width="98%" align="center" class="bordaFina">
                    <tr>
                        <td style="background-color:#7FB2CC;" class="celula" colspan="12">
                            <div align="left">
                                <img class="imagemLink" border="0" title="Adicionar uma nova area." src="img/add.gif" style="float:left" onclick="if($(chkRedespachante).checked == true ){addArea(areaLimpa);}else{alert('Para adicionar áreas o fornecedor precisa ser representante. ')}">
                                <div></div>
                                <label>&nbsp;Adicionar Tabelas de Preço</label>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos" width="10%" style="background-color:#7FB2CC;" id="tdlblarea" name="tdlblarea"><div align="left">Area</div></td>
                        <td class="TextoCampos" width="10%" style="background-color:#7FB2CC;" id="tdlbltipo" name="tdlbltipo" ><div align="left">Tipo</div></td>
                        <td class="TextoCampos" width="5%" style="background-color:#7FB2CC;" id="lblvlTipoProduto"> <div align="left">Tipo Produto</div></td>                                    
                        <td class="TextoCampos" width="7%" style="background-color:#7FB2CC; text-align: left" id="tdlblAuxAteKg" align="left">
                            <!--<div align="left" id="divlblAtekg" name="divlblAtekg" style="display: none">Até(kg):</div>
                            <div align="left" style="display: none" id="divlblSobFrete" name="divlblSobFrete">Sob % Frete:</div>
                            <div align="left" style="display: none" id="divlblSobKm" name="divlblSobKm">Por Km:</div>-->
                        </td>
                        <td class="TextoCampos" width="5%" style="background-color:#7FB2CC; text-align: left" id="tdlblCobrar" name="tdlblCobrar" >
                            <!--<div align="left" style="display: none">Cobrar(R$)</div>-->
                        </td>
                        <td class="TextoCampos" width="5%" style="background-color:#7FB2CC; text-align: left" id="tdlblExcedente" name="tdlblExcedente" >
                            <!--<div align="left" style="display: none">Excedente</div></td>-->
                        </td>
                        <td class="TextoCampos" width="8%" style="background-color:#7FB2CC; text-align: left" id="tdlblsobKm" name="tdlblsobKm" ></td>
                        <td class="TextoCampos" width="5%" style="background-color:#7FB2CC;" id="tdlbladValorEm" name="tdlbladValorEm" ><div align="left">AdValorem</div></td>
                        <td class="TextoCampos" width="5%" style="background-color:#7FB2CC;" id="tdlblgris" name="tdlblgris" ><div align="left">Gris</div></td>
                        <td class="TextoCampos" width="5%" style="background-color:#7FB2CC;" id="tdlblTaxaFixa" name="tdlblTaxaFixa" ><div align="left">Taxa Fixa</div></td>
                        <td class="TextoCampos" width="5%" style="background-color:#7FB2CC;" id="tdlblFreteMinino" name="tdlblFreteMinino" ><div align="left">Frete Min.</div></td>
                        <td class="TextoCampos" width="5%" style="background-color:#7FB2CC;" id="tdlblTipoEntrega" name="tdlblTipoEntrega" ><div align="left">Tipo Entrega</div></td>                                 
                    </tr>
                    <tr>
                        <td class="TextoCampos" style="background-color:#7FB2CC;"><div align="left">Tabela Principal</div></td>
                        <td class="TextoCampos" style="background-color:#7FB2CC;" width="6%">
                            <div align="left" >
                                <select id="tipoTaxa" name="tipoTaxa" class="inputtexto" onchange="alterarTipoTaxa();" style="width:80px;">
                                    <option value="0">Por Peso</option>
                                    <option value="2">% Frete</option>
                                    <option value="3">Valor Combinado</option>
                                    <option value="5">Por KM</option>
                                </select>
                                <select id="tipoPeso_0"  name="tipoPeso_0" class="inputtexto" onchange="alterarTipoPeso();" style="width:80px;">
                                </select>
                                <input type="hidden" id="qtdFaixaPeso_0" name="qtdFaixaPeso_0" value="0" />
                            </div>
                        </td>
                        <td class="TextoCampos" style="background-color:#7FB2CC;" id="tdvlTipoProduto" width="6%">
                            <div align="left" >
                                <select name="tipoProdutoId" id="tipoProdutoId" class="inputtexto" style="width:80px;">
                                    <option value="0">Nenhum</option>
                                    <%for (TipoProduto p : product_types) {%>
                                    <option value="<%=p.getId()%>" <%=(carregafornec && (fornec.getTipoProdutoType().getId() == p.getId()) ? "Selected" : "")%>><%=p.getDescricao()%> </option>
                                    <%}%>
                                </select>
                            </div>
                        </td>
                        <td class="TextoCampos"  style="background-color:#7FB2CC;" id="tdVlAuxAteKg" width="10%">
                            <div align="left" id="divVlAtekg">
                                <input name="vlKgAte" type="text" class="fieldMin" id="vlKgAte" onChange="seNaoFloatReset(this,'0.00')" size="8" maxlength="10" value="<%=(carregafornec ? Apoio.to_curr(fornec.getVlKgAte()) : "0.00")%>">                                            
                                Kg
                            </div>
                            <div align="left" style="display: none" id="divVlSobFrete">
                                <input name="vlsobfrete" type="text" class="fieldMin" id="vlsobfrete" onChange="seNaoFloatReset(this,'0.00')" size="8" maxlength="10" value="<%=(carregafornec ? Apoio.to_curr(fornec.getVlsobfrete()) : "0.00")%>">                                            
                            </div>
                            <!-- <div align="left" style="display: none" id="divVlSobKm">
                                 Por:
                                 <input name="vlsobkm" type="text" class="fieldMin" id="vlsobkm" onChange="seNaoFloatReset(this,'0.00')" size="8" maxlength="10" value="<%=(carregafornec ? Apoio.to_curr(fornec.getVlsobkm()) : "0.00")%>">
                                 Km
                             </div>-->
                        </td>
                        <td class="CelulaZebra2" style="background-color:#7FB2CC;" id="tdVlPrecoFaixa" width="5%">
                            <div align="left" id="divVlPrecoFaixa">
                                <input name="vlPrecoFaixa" type="text" class="fieldMin" id="vlPrecoFaixa" onChange="seNaoFloatReset(this,'0.00')" size="8" maxlength="10" value="<%=(carregafornec ? Apoio.to_curr(fornec.getVlPrecoFaixa()) : "0.00")%>">
                            </div>
                        </td>    
                        <td class="CelulaZebra2" style="background-color:#7FB2CC;" id="tdVlSobPeso" width="6%">
                            <div align="left" id="divVlSobPeso">
                                <input name="vlsobpeso" type="text" class="fieldMin" id="vlsobpeso" onChange="duasCasasDecimais()" size="8" value="<%=(carregafornec ? fornec.getVlsobpeso() : "0.00")%>">     
                            </div>
                        </td>                                    
                        <td class="CelulaZebra2" style="background-color:#7FB2CC;" id="tdsobKm" width="6%">
                            <div align="left">
                                <input name="vlsobkm" type="text" class="fieldMin" id="vlsobkm" onChange="seNaoFloatReset(this,'0.00')" size="8" maxlength="10" value="<%=(carregafornec ? Apoio.to_curr(fornec.getVlsobkm()) : "0.00")%>">Km
                            </div>
                        </td>
                        <td class="CelulaZebra2" style="background-color:#7FB2CC;" id="tdAdVlEm" width="5%">
                            <div align="left">
                                <input name="adVlEm" type="text" class="fieldMin" id="adVlEm" onchange="seNaoFloatReset(this,'0.00')" size="8" maxlength="10" value="<%=(carregafornec ? Apoio.to_curr(fornec.getAdVlEm()) : "0.00")%>">
                            </div>
                        </td>
                        <td class="CelulaZebra2" style="background-color:#7FB2CC;" id="tdvlGris" width="5%">
                            <div align="left">
                                <input name="vlGris" type="text" class="fieldMin" id="vlGris" onchange="seNaoFloatReset(this,'0.00')" size="8" maxlength="10" value="<%=(carregafornec ? Apoio.to_curr(fornec.getVlGris()) : "0.00")%>">
                            </div>
                        </td>
                        <td class="CelulaZebra2" style="background-color:#7FB2CC;" id="tdvlTaxaFixa" width="5%">
                            <div align="left">
                                <input name="taxaFixa" type="text" class="fieldMin" id="taxaFixa" onchange="seNaoFloatReset(this,'0.00')" size="8" maxlength="10" value="<%=(carregafornec ? Apoio.to_curr(fornec.getTaxaFixa()) : "0.00")%>">
                            </div>
                        </td>
                        <td class="CelulaZebra2" style="background-color:#7FB2CC;" id="tdvlFreteMinino" width="7%">
                            <div align="left">
                                <input name="vlfreteminimo" type="text" id="vlfreteminimo" class="fieldMin" onChange="seNaoFloatReset(this,'0.00')" size="8" maxlength="10" value="<%=(carregafornec ? Apoio.to_curr(fornec.getVlfreteminimo()) : "0.00")%>">
                            </div>
                        </td>
                        <td class="TextoCampos" style="background-color:#7FB2CC;" id="tdvlPrevisaoEntrega" width="12%">    
                            <div align="left" >
                                <input name="previsaoEntrega" type="text" class="fieldMin" id="previsaoEntrega" onkeypress="mascara(this, soNumeros)" onchange="seNaoIntReset(this,'0')" size="3" maxlength="5" value="<%=(carregafornec ? fornec.getPrevisaoEntrega() : 0)%>">
                                <select id="tipoPrevisaoEntrega" name="tipoPrevisaoEntrega" class="inputtexto" style="width:80px;">
                                    <option value="u" selected >Dias Uteis</option>
                                    <option value="c">Dias Corridos</option>
                                    <option value="e">Dias Corridos com entrega em dia útil</option>                                                
                                </select>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="13">
                            <table class="bordaFina" width="100%">
                                <tr class="CelulaZebra1">
                                    <td id="tdBaseCubagem" width="17%" name="tdBaseCubagem">
                                        <label align="left">Base da Cubagem: </label>
                                        <input id="baseCubagem" class="fieldMin" type="text" onkeypress="mascara(this, soNumeros)" size="8" onchange="seNaoFloatReset(this,'0.00')" maxlength="8" name="baseCubagem" value="<%= carregafornec && fornec.getBaseCubagem() > 0 ? Apoio.to_curr(fornec.getBaseCubagem()) : "0.00"%>">
                                    </td>
                                    <td id="tdValorTde" width="13%" name="tdValorTde">
                                        <label align="left">Valor TDE: </label>
                                        <input id="valorTde" class="fieldMin" type="text"  onkeypress="mascara(this, soNumeros)" size="8" onchange="seNaoFloatReset(this,'0.00')" maxlength="8" name="valorTde" value="<%= carregafornec && fornec.getValorTde() > 0 ? Apoio.to_curr(fornec.getValorTde()) : "0.00"%>">
                                    </td>
                                    <td id="tdUsarMaiorPreco" width="26%" name="tdUsarMaiorPreco">
                                        <div id="divUsarMaiorPreco">
                                            <input id="isUsarMaiorPrecoPeso" class="inputtexto" type="checkbox" name="isUsarMaiorPrecoPeso" <%= carregafornec && fornec.isMaiorPrecoPesoPercentual() ? "checked" : ""%>>
                                            <label align="left"> Utilizar maior preço entre peso KG e % Frete </label>
                                        </div>
                                    </td>
                                    <td id="tdTipoCalculo" width="45%" name="tdTipoCalculo">
                                        <div id="divTipoCalculo">
                                            <label align="left">Considerar: </label>
                                            <input id="considerarValorBruto" class="inputtexto" type="radio" name="considerarValor" value="b" <%= carregafornec ? (fornec.getTipoCalculoPercentualCte().equalsIgnoreCase("b") ? "checked" : "") : "checked"%> >
                                            <label align="left"> Valor Bruto do CT-e (com ICMS) </label>                                         
                                            <input id="considerarValorLiquido" class="inputtexto" type="radio" name="considerarValor" value="l" <%= carregafornec && fornec.getTipoCalculoPercentualCte().equalsIgnoreCase("l") ? "checked" : ""%> >
                                            <label align="left"> Valor Liquido do CT-e (sem ICMS) </label>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr id="trTabelaFaixaPeso_0">
                        <td colspan="12" width="100%" class="celulaZebra1" >
                            <table width="50%" class="bordaFina tabelaZeradaSemPerc">
                                <tbody class="">
                                    <tr class="celulaZebra1">
                                        <td colspan="4">
                                            <div align="left">
                                                <img class="imagemLink" border="0" title="Adicionar uma nova faixa de peso." src="img/add.gif" style="float:left" onclick="addFaixaPeso(null, ('tbFaixaPeso_0'), 0)">
                                                <b><label>&nbsp;Adicionar Faixas de Peso</label></b>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr class="celulaZebra1">
                                        <td width="25%">De (Kg)</td>
                                        <td width="25%">Até (Kg)</td>
                                        <td width="25%" align="left">Valor R$</td>
                                        <td width="25%" align="center"></td>
                                    </tr>
                                </tbody>
                                <tbody id="tbFaixaPeso_0"></tbody>
                                <tbody >
                                    <tr class="celulaZebra1">
                                        <td class="styleNum">Excedente:</td>
                                        <td colspan="4">
                                            <input id="vlPrecoExcedente_0" name="vlPrecoExcedente_0" class="inputTexto styleNum" size="10" onkeypress="mascara(this,reais)" value="0,00" />
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </td>
                    </tr>
                    <tbody colspan="10" id="tbBase" name="tbBase">
                    </tbody>                                
                </table>
            </div>
            <div id="dvInfoTabPrecoCiaAerea" style="display: none;" width="50%">
                <table id="tableDOMtp" width="98%" align="left" class="bordaFina" style="margin-left: 1%;">
                    <tr class="tabela"> 
                        <td colspan="15" align="center">
                            <div align="center">Tabelas de preço Cia. Aérea</div>
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos" width="2%" style="background-color:#7FB2CC;" id="tdtopoadd" name="tdtopoadd">
                            <div align="center">
                                <img class="imagemLink" border="0" title="Adicionar uma nova tabela." src="img/add.gif" onclick="if($(chkCompanhiaAerea).checked == true ){addTabelaPrecoCiaAerea(listaIdTP, listaDescTP, listaIdTE, listaCodTE, listaDescTE);}else{alert('Para adicionar áreas o fornecedor precisa ser uma companhia aerea.')}">
                                <input type="hidden" id="qtdTabPreceCiaAerea" name="qtdTabPreceCiaAerea" value="0" />
                            </div>
                        </td>
                        <td class="TextoCampos" width="2%" style="background-color:#7FB2CC;" id="tdtopovermais" name="tdtopovermais">
                            
                        </td>
                        <td class="TextoCampos" width="6%" style="background-color:#7FB2CC;" id="tdlblorigem" name="tdlblorigem">
                            <div align="left">Aeroporto Origem</div>
                        </td>
                        <td class="TextoCampos" width="6%" style="background-color:#7FB2CC;" id="tdlbldestino" name="tdlbldestino">
                            <div align="left">Aeroporto Destino</div>
                        </td>
                        <td class="TextoCampos" width="1%" style="background-color:#7FB2CC;" id="tdlblexcedente" name="tdlblexcedente">
                            <div align="left">Valor Excedente</div>
                        </td>
                        <td class="TextoCampos" width="1%" style="background-color:#7FB2CC;" id="tdlblfixo" name="tdlblfixo">
                            <div align="left">Valor Fixo</div>
                        </td>
                        <td class="TextoCampos" width="1%" style="background-color:#7FB2CC;" id="tdlbltipoproduto" name="tdlbltipoproduto">
                            <div align="left">Tipo de Produtos</div>
                        </td>
                        <td class="TextoCampos" width="1%" style="background-color:#7FB2CC;" id="tdlbltarifaespecifica" name="tdlbltarifaespecifica">
                            <div align="left">Tarifa Específica</div>
                        </td>
                        <td class="TextoCampos" width="1%" style="background-color:#7FB2CC;" id="tdlbltaxacoleta" name="tdlbltaxacoleta">
                            <div align="left">Taxa de Coleta</div>
                        </td>
                        <td class="TextoCampos" width="1%" style="background-color:#7FB2CC;" id="tdlbltaxaentrega" name="tdlbltaxaentrega">
                            <div align="left">Taxa de Entrega</div>
                        </td>
                        <td class="TextoCampos" width="1%" style="background-color:#7FB2CC;" id="tdlbltaxacapatazia" name="tdlbltaxacapatazia">
                            <div align="left">Taxa de Capatazia</div>
                        </td>
                        <td class="TextoCampos" width="1%" style="background-color:#7FB2CC;" id="tdlbltaxafixa" name="tdlbltaxafixa">
                            <div align="left">Taxa Fixa</div>
                        </td>
                        <td class="TextoCampos" width="1%" style="background-color:#7FB2CC;" id="tdlbltaxadesembaraco" name="tdlbltaxadesembaraco">
                            <div align="left">Taxa de Desembaraço</div>
                        </td>
                        <td class="TextoCampos" width="1%" style="background-color:#7FB2CC;" id="tdlblseguro" name="tdlblseguro">
                            <div align="left">% Seguro</div>
                        </td>
                        <td class="TextoCampos" width="1%" style="background-color:#7FB2CC;" id="tdlblfreteminimo" name="tdlblfreteminimo">
                            <div align="left">Frete Mínimo</div>
                        </td>
                    </tr>
                </table>
                    <div id="dviTipoProdutoAereo" style="display: none;">
                        <table id="main-tables" class="bordaFina celulaZebra2" border="0" width="98%" align="left"  style="margin-left:1%"> <!-- Alterar tamanho da janela tipo de produtos aereo-->
                            <tbody  id="corpo-tabela" width="80%">
                                <tr class="tabela"> 
                                    <td colspan="5" align="center">
                                        <div align="center">Tipos de produtos cia aérea</div>
                                    </td>
                                </tr>  
                                <input id="inpQtdProdAereo" name="inpQtdProdAereo" value="" type="hidden">
                                <tr>
                                    <td width="100%">
                                        <table class="bordaFina" width=30%">
                                            <tbody name="tbDomAereo">
                                                <tr class="celula">
                                                    <td align="left" width="1%">
                                                         <img align="left"  onClick="addTipoProdutoCiaAerea();" alt="addCampo" src="img/add.gif" class="imagemLink"/>
                                                    </td>
                                                    <td align="center" width="55%"><label> Produtos</label></td></td>
                                                   <td align="left" width="1%" >Ordem</td>
                                                </tr>
                                            </tbody>
                                            <tbody id="tbodyTpca"></tbody>
                                            <table id="footer" class="bordaFina" align="right" width="100%" style="margin-right:1px">
                                                <tbody>
                                                     <tr >
                                                        <td class="CelulaZebra2" >
                                                            Nº conta corrente:
                                                            <input name="numconta"  id="numconta" type="text"  size="11" maxlength="12"   onkeypress="mascara(this, soNumeros)" value="<%= (carregafornec && fornec.getContaCorrenteCiaAerea() != null  ? fornec.getContaCorrenteCiaAerea() : "") %>" class="inputtexto">
                                                        </td> 
                                                        <td class="CelulaZebra2"  >
                                                            Modelo Minuta de Despacho:
                                                            <select id="modeloMinuta" name="modeloMinuta" class="inputtexto">
                                                                <option value="0" <%= (carregafornec && fornec.getModeloMinutaDespacho() == 0 ? "selected" : "")%> >TAM Cargo</option>
                                                                <option value="1" <%= (carregafornec && fornec.getModeloMinutaDespacho() == 1 ? "selected" : "")%> >Azul Cargo</option>
                                                                <option value="2" <%= (carregafornec && fornec.getModeloMinutaDespacho() == 2 ? "selected" : "")%> >Avianca Cargo</option>
                                                            </select>
                                                        </td>
                                                    </tr>    
                                            </table>
                                        <input type="hidden" name="max" id="max" value="0"/>
                                    </td>
                                </tr> 
                            </tbody>  
                        </table>
                                </tr>             
                            </tbody>  
                        </table>
                   </div>
            </div>
             <div id="divAuditoria" >
                <table width="98%" border="0" align="center" class="bordaFina" id="tableAuditoria" style='display: <%=carregafornec && nivelUser == 4 ? "" : "none"%>'>
                    <tr>
                        <td>
                            <%@include file="/gwTrans/template_auditoria.jsp" %>
                        </td>
                    </tr>    
                    <tr>
                        <td colspan="6" align="center">
                            <table width="100%" class="bordaFina">
                                <tr>
                                    <td width="10%" class="TextoCampos">Incluso:</td>
                                    <td width="40%" class="CelulaZebra2">Em:<%=(cadfornec.getFornecedor().getCriadoEm() != null ? fmt.format(cadfornec.getFornecedor().getCriadoEm()) : "")%><br>
                                        Por: <%=cadfornec.getFornecedor().getCriadoPor().getNome() != null ? cadfornec.getFornecedor().getCriadoPor().getNome() : ""%> 
                                    </td>
                                    <td width="10%" class="TextoCampos">Alterado:</td>
                                    <td width="40%" class="CelulaZebra2">Em:<%=(cadfornec.getFornecedor().getAlteradoEm() != null ? fmt.format(cadfornec.getFornecedor().getAlteradoEm()) : "")%><br>
                                        Por: <%=cadfornec.getFornecedor().getAlteradoPor().getNome() != null ? cadfornec.getFornecedor().getAlteradoPor().getNome() : ""%> 
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>                
                </table>
             </div> 
              <br/>                      
                <table width="98%" border="0" align="center" class="bordaFina">
                    <tr class="CelulaZebra2"> 
                        <td colspan="6"> 
                            <% if (nivelUser >= 2) {%>
                    <center>
                        <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>');});">
                    </center>
                    <%}%>
                    </td>
                    </tr>
                </table>
                 
        </form>
     </body>
</html>
